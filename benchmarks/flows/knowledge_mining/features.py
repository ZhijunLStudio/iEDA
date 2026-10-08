"""
features.py —— 数据感知层（实现版）

把异构原始数据（input_def / baseline placement.def / LEF / RUDY / EGR）
压成归一化、可跨设计比较的比例特征 x（见 DESIGN.md §5 特征词典）。

契约：
- 全部无量纲（比值/比例），禁止绝对量
- 硬约束：特征只来自「决策时点可算」的量，禁止 lookahead
- pre_pl 特征只需未布 DEF（input_def）+ LEF，无需位置
- post_baseline 特征需 baseline placement.def（有 PLACED 位置）+ RUDY/EGR 报告

数据源（已核对 CLI 输出）：
- pre_pl：input_def（iFP 未布 DEF，COMPONENTS 无位置）+ LEF
- post_baseline：baseline placement.def + gp_congestion_observe.py（RUDY 诊断）+ irt_egr.py（聚合 EGR）
- 复用 gp_congestion_observe.parse_die_and_core、def_hpwl_eval.parse_lef/split_def_blocks
"""

from __future__ import annotations

import importlib.util
import re
import sys
from pathlib import Path
from typing import Any, Dict, List, Tuple

# REPO_ROOT = iEDA.ai（本文件在 benchmarks/flows/knowledge_mining/，向上 3 层到仓库根）
REPO_ROOT = Path(__file__).resolve().parents[3]
FLOWS = REPO_ROOT / "benchmarks" / "flows"
sys.path.insert(0, str(FLOWS))

# 高扇出判定阈值：pin 数 >= 9（即 fanout >= 8）。特征定义参数，非知识魔法数。
HFANOUT_PIN_THRESHOLD = 9


# ── 复用现有 parser ──────────────────────────────────────────────
def _load_module(modname: str, path: Path):
    spec = importlib.util.spec_from_file_location(modname, path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def _def_hpwl():
    return _load_module("def_hpwl_eval", FLOWS / "def_hpwl_eval.py")


def _cong_observe():
    return _load_module("gp_congestion_observe", FLOWS / "gp_congestion_observe.py")


# ── DEF 解析（无位置依赖）────────────────────────────────────────
def parse_def_units(def_text: str) -> int:
    m = re.search(r"UNITS\s+DISTANCE\s+MICRONS\s+(\d+)", def_text, re.I)
    return int(m.group(1)) if m else 1000


def parse_components(def_text: str) -> Dict[str, str]:
    """COMPONENTS 段 → {inst_name: macro_name}（全部组件，不要求有位置）。"""
    comp: Dict[str, str] = {}
    m = def_text.find("COMPONENTS")
    e = def_text.find("END COMPONENTS")
    if m < 0 or e < 0:
        return comp
    section = def_text[m:e]
    for block in _def_hpwl().split_def_blocks(section):
        joined = " ".join(block)
        mn = re.match(r"\s*-+\s+(\S+)\s+(\S+)", joined)
        if mn:
            comp[mn.group(1).replace("\\/", "/")] = mn.group(2)
    return comp


def parse_component_positions(def_text: str) -> Dict[str, Tuple[int, int]]:
    """COMPONENTS 段 → {inst_name: (x, y)}（仅 PLACED/FIXED 有位置）。"""
    comp: Dict[str, Tuple[int, int]] = {}
    m = def_text.find("COMPONENTS")
    e = def_text.find("END COMPONENTS")
    if m < 0 or e < 0:
        return comp
    section = def_text[m:e]
    for block in _def_hpwl().split_def_blocks(section):
        joined = " ".join(block)
        mn = re.match(r"\s*-+\s+(\S+)\s+(\S+)", joined)
        if not mn:
            continue
        mp = re.search(r"(?:PLACED|FIXED)\s*\(\s*([-\d]+)\s+([-\d]+)\s*\)", joined)
        if mp:
            comp[mn.group(1).replace("\\/", "/")] = (int(mp.group(1)), int(mp.group(2)))
    return comp


def parse_ports(def_text: str) -> Dict[str, Tuple[int, int]]:
    """PINS 段 → {pin_name: (x, y)}（IO 端口位置）。"""
    pins: Dict[str, Tuple[int, int]] = {}
    m = def_text.find("PINS")
    e = def_text.find("END PINS")
    if m < 0 or e < 0:
        return pins
    section = def_text[m:e]
    for block in _def_hpwl().split_def_blocks(section):
        joined = " ".join(block)
        mn = re.match(r"\s*-+\s+(\S+)\s+", joined)
        mp = re.search(r"(?:PLACED|FIXED)\s*\(\s*([-\d]+)\s+([-\d]+)\s*\)", joined) if mn else None
        if mn and mp:
            pins[mn.group(1)] = (int(mp.group(1)), int(mp.group(2)))
    return pins


def iter_signal_nets(def_text: str) -> List[Dict[str, Any]]:
    """解析 NETS 段（排除 SPECIALNETS 电源网），返回每个信号网的连接明细。

    返回 [{name, pin_count, pairs:[(inst,pin),...]}]。只统计 connectivity，
    不依赖位置；SPECIALNETS（+ USE POWER）被排除。
    """
    hpwl_mod = _def_hpwl()
    # 精确定位 NETS 段（\nNETS <count> ; 之后到 END NETS）
    nets_header = re.search(r"\nNETS\s+\d+\s*;", def_text)
    if not nets_header:
        return []
    section = def_text[nets_header.start(): def_text.find("END NETS", nets_header.start())]

    cleaned: List[str] = []
    for line in section.splitlines():
        s = line.strip()
        u = s.upper()
        if u.startswith("ROUTED") or u.startswith("+ ROUTED") or u.startswith("NEW"):
            continue
        # 保留 net 起始行和连接行；电源网会带 + USE POWER，下面按 net 过滤
        if s.startswith("-") or s.startswith("(") or s.startswith("+ USE") \
                or s.startswith("+ WEIGHT") or s.startswith("+ SOURCE"):
            cleaned.append(line)

    nets: List[Dict[str, Any]] = []
    cur: List[str] = []
    for line in cleaned:
        s = line.strip()
        if s.startswith("-") and not s.startswith("--"):
            if cur:
                _append_net(nets, cur)
            cur = [s]
        elif cur:
            cur.append(s)
    if cur:
        _append_net(nets, cur)
    # 过滤电源网（USE POWER / USE GROUND）
    return [n for n in nets if not n.get("is_power")]


def _append_net(nets: List[Dict], cur: List[str]):
    joined = " ".join(cur)
    name_m = re.match(r"\s*-\s*(\S+)", joined)
    net_name = name_m.group(1) if name_m else ""
    is_power = bool(re.search(r"\+?\s*USE\s+POWER", joined, re.I)) or bool(re.search(r"\+?\s*USE\s+GROUND", joined, re.I))
    pairs = re.findall(r"\(\s*([^\s()]+)\s+([^\s()]+)\s*\)", joined)
    # 去掉电源引脚（* 前缀）与纯通孔引用
    real_pairs = [(i, p) for i, p in pairs if not i.startswith("*")]
    nets.append({"name": net_name, "pin_count": len(real_pairs),
                 "pairs": real_pairs, "is_power": is_power})


# ── pre-PL 特征 ──────────────────────────────────────────────────
def pre_pl_features(input_def: str, lef: str) -> Dict[str, float]:
    """从 input_def（未布）+ LEF 算阶段 0 特征（纯解析，无 iEDA 运行）。

    fill_rate          = Σ(cell 面积) / core 面积（LEF SIZE 面积求和，位置无关）
    hfanout_ratio      = pin 数 >= 9 的网数 / 总网数
    hfanout_pin_share  = pin 数 >= 9 的网 pin 总数 / 总 pin
    die_aspect         = die 宽 / die 高
    cell_count         = 组件数（后续 log）
    """
    hpwl_mod = _def_hpwl()
    cong_mod = _cong_observe()
    def_path = Path(input_def)
    text = def_path.read_text(errors="ignore")

    macros, _lef_units = hpwl_mod.parse_lef(lef)
    def_units = parse_def_units(text)

    # core/die 尺寸
    geo = cong_mod.parse_die_and_core(def_path)
    core = geo.get("core") or geo.get("die")
    core_area = 0.0
    if core:
        lx, ly, ux, uy = core
        core_area = float(max(1, ux - lx) * max(1, uy - ly)) / (def_units * def_units)
    die = geo.get("die")
    die_aspect = 1.0
    if die and (die[3] - die[1]) > 0:
        die_aspect = float(die[2] - die[0]) / float(die[3] - die[1])

    # 组件面积（LEF SIZE 是 microns）与计数
    comps = parse_components(text)
    cell_area = 0.0
    cell_count = 0
    for _inst, macro in comps.items():
        if macro in macros:
            w, h = macros[macro]["size"]
            cell_area += w * h
            cell_count += 1

    fill_rate = (cell_area / core_area) if core_area > 0 else 0.0

    # fanout 统计（信号网）
    nets = iter_signal_nets(text)
    total_nets = len(nets)
    total_pins = 0
    hfanout_nets = 0
    hfanout_pins = 0
    for n in nets:
        pc = n["pin_count"]
        total_pins += pc
        if pc >= HFANOUT_PIN_THRESHOLD:
            hfanout_nets += 1
            hfanout_pins += pc
    hfanout_ratio = (hfanout_nets / total_nets) if total_nets else 0.0
    hfanout_pin_share = (hfanout_pins / total_pins) if total_pins else 0.0

    return {
        "fill_rate": fill_rate,
        "hfanout_ratio": hfanout_ratio,
        "hfanout_pin_share": hfanout_pin_share,
        "die_aspect": die_aspect,
        "cell_count": float(cell_count),
    }


# ── post-baseline 特征 ────────────────────────────────────────────
def post_baseline_features(baseline_def: str, rudy_report: Dict, egr_report: Dict) -> Dict[str, float]:
    """从 baseline placement（有位置）+ RUDY 诊断 + EGR 聚合算阶段 1 特征。

    net_bbox_span_p90 = 网 bbox 跨距 p90 / die 对角线（cell 中心近似）
    vh_ratio          = rudy_utilization_h_max / rudy_utilization_v_max
    overflow_ratio    = rudy_overflow_bin_count / (bin_cnt_x * bin_cnt_y)
    rudy_peak         = rudy_utilization_max
    rudy_egr_mismatch = normalize(rudy_peak) - normalize(egr_max)
    """
    cong_mod = _cong_observe()
    def_path = Path(baseline_def)
    text = def_path.read_text(errors="ignore")
    def_units = parse_def_units(text)

    geo = cong_mod.parse_die_and_core(def_path)
    die = geo.get("die")
    diag = 1.0
    if die:
        w = float(die[2] - die[0]) / def_units
        h = float(die[3] - die[1]) / def_units
        diag = (w * w + h * h) ** 0.5 or 1.0

    # net bbox span p90（用 cell 中心近似 + 端口位置）
    positions = parse_component_positions(text)
    ports = parse_ports(text)
    nets = iter_signal_nets(text)
    spans: List[float] = []
    for n in nets:
        pts: List[Tuple[int, int]] = []
        for inst, pin in n["pairs"]:
            if inst == "PIN":
                if pin in ports:
                    pts.append(ports[pin])
            elif inst in positions:
                pts.append(positions[inst])
        if len(pts) >= 2:
            xs = [p[0] for p in pts]
            ys = [p[1] for p in pts]
            span = float(max(xs) - min(xs) + max(ys) - min(ys)) / def_units
            spans.append(span)
    p90 = 0.0
    if spans:
        s = sorted(spans)
        p90 = s[min(len(s) - 1, int(len(s) * 0.9))]
    net_bbox_span_p90 = (p90 / diag) if diag else 0.0

    # RUDY 诊断特征
    bc = rudy_report.get("bin_cnt", [64, 64])
    bin_x = bc[0] or 64
    bin_y = bc[1] or 64
    overflow_bins = float(rudy_report.get("rudy_overflow_bin_count") or 0)
    rudy_peak = float(rudy_report.get("rudy_utilization_max") or 0.0)
    h_max = float(rudy_report.get("rudy_utilization_h_max") or 0.0)
    v_max = float(rudy_report.get("rudy_utilization_v_max") or 0.0)

    vh_ratio = (h_max / v_max) if v_max > 0 else 0.0
    overflow_ratio = overflow_bins / max(1.0, float(bin_x * bin_y))

    # rudy↔egr 背离度：各自归一（rudy 利用率 / 4 截断；egr 绝对值 / 100 截断）后相减
    egr_max = float((egr_report or {}).get("egr_max_overflow_union") or 0.0)
    rudy_norm = min(1.0, rudy_peak / 4.0)
    egr_norm = min(1.0, egr_max / 100.0)
    rudy_egr_mismatch = rudy_norm - egr_norm

    return {
        "net_bbox_span_p90": net_bbox_span_p90,
        "vh_ratio": vh_ratio,
        "overflow_ratio": overflow_ratio,
        "rudy_peak": rudy_peak,
        "rudy_egr_mismatch": rudy_egr_mismatch,
    }
