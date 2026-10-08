#!/usr/bin/env python3
"""
gen_dataset.py —— 离线海量对照搜索驱动（无 LLM、无 DSH）

流程：designs.json + split.json → 每设计跑动作矩阵（子进程调 iEDA CLI）→
      产出 output/dataset.jsonl（append-only，结构化样本）+ output/run_cache.jsonl（幂等缓存）。

用法：
  python3 benchmarks/flows/knowledge_mining/gen_dataset.py \
      --designs gcd,s1238,s1488 --actions baseline,compress_td0.90,congest_ce6 \
      --seeds 1000,2000 --max-workers 4 [--dry-run]

缓存键：run_cache.jsonl 键 = (design_key, action, params_hash, seed, ieda_version)。
续跑安全：每个样本 append 写 dataset.jsonl，崩溃不丢已完成工作。
"""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from typing import Any, Dict, List, Optional

# iEDA.ai 仓库根（本文件在 benchmarks/flows/knowledge_mining/，向上 3 层）
REPO_ROOT = Path(__file__).resolve().parents[3]
FLOWS = REPO_ROOT / "benchmarks" / "flows"
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(FLOWS))

import features as FEAT  # noqa: E402

OUT_DIR = HERE / "output"
DATASET_PATH = OUT_DIR / "dataset.jsonl"
CACHE_PATH = OUT_DIR / "run_cache.jsonl"

GP_AGENT = FLOWS / "gp_agent.py"
IRT_EGR = FLOWS / "irt_egr.py"
DEF_HPWL = FLOWS / "def_hpwl_eval.py"
CONG_OBSERVE = FLOWS / "gp_congestion_observe.py"
TIMING_PATHS = FLOWS / "gp_timing_paths.py"

PYTHON = sys.executable or "python3"
TIMEOUT_S = 7200  # 2h per subprocess


# ── 动作矩阵 ──────────────────────────────────────────────────────
# 每个动作定义：type（物理动作）、command（gp_agent 子命令）、附加参数、是否需 baseline 前置
def build_actions(include_timing: bool) -> Dict[str, Dict[str, Any]]:
    # 动作空间扩展：td 5 档（细粒度剂量曲线）+ 疏散 2 档强度（温和，修复 divergence）
    acts: Dict[str, Dict[str, Any]] = {
        "baseline":        {"type": "baseline",          "command": "plain", "needs_baseline": False, "extra": ["--verify-egr", "1"]},
        "compress_td0.75": {"type": "compress_td",       "command": "plain", "td": 0.75, "needs_baseline": False},
        "compress_td0.80": {"type": "compress_td",       "command": "plain", "td": 0.80, "needs_baseline": False},
        "compress_td0.85": {"type": "compress_td",       "command": "plain", "td": 0.85, "needs_baseline": False},
        "compress_td0.90": {"type": "compress_td",       "command": "plain", "td": 0.90, "needs_baseline": False},
        "compress_td0.95": {"type": "compress_td",       "command": "plain", "td": 0.95, "needs_baseline": False},
        "congest_ce4":     {"type": "congest_ce",        "command": "start", "ce": 4,    "needs_baseline": False},
        "congest_ce6":     {"type": "congest_ce",        "command": "start", "ce": 6,    "needs_baseline": False},
        # 温和疏散：density_target 0.7/0.8（原 0.5 在高填充设计触发 divergence）
        "evacuate_region_g07": {"type": "evacuate_region", "command": "local_congestion", "scope": "region", "density_target": 0.7, "needs_baseline": True},
        "evacuate_region_g08": {"type": "evacuate_region", "command": "local_congestion", "scope": "region", "density_target": 0.8, "needs_baseline": True},
        "evacuate_instance":   {"type": "evacuate_instance", "command": "local_congestion", "scope": "instances", "needs_baseline": True},
    }
    if include_timing:
        acts["timing"] = {"type": "timing", "command": "start", "timing": 1, "needs_baseline": False}
    return acts


# ── JSON 工具 ────────────────────────────────────────────────────
def load_json(p: Path) -> Any:
    return json.loads(p.read_text())


def append_jsonl(p: Path, obj: Dict):
    p.parent.mkdir(parents=True, exist_ok=True)
    with p.open("a") as f:
        f.write(json.dumps(obj, ensure_ascii=False) + "\n")


def read_jsonl(p: Path) -> List[Dict]:
    if not p.exists():
        return []
    return [json.loads(l) for l in p.read_text().splitlines() if l.strip()]


# ── 派生 config（compress_td 用；plain 不吃 --target-density，须写 config）──
def derive_config(base_cfg_path: str, td: float, out_dir: Path) -> str:
    cfg = load_json(Path(base_cfg_path))
    pl = cfg.get("PL", cfg)
    pl.setdefault("GP", {}).setdefault("Density", {})["target_density"] = td
    out = out_dir / "pl_derived_config.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(cfg, indent=2))
    return str(out)


# ── 子进程封装 ───────────────────────────────────────────────────
def run_cmd(cmd: List[str], cwd: Path, timeout: int = TIMEOUT_S) -> Dict[str, Any]:
    """跑一个 CLI，返回 {'rc','stdout','stderr'}；不抛异常。"""
    try:
        r = subprocess.run(cmd, cwd=str(cwd), capture_output=True, text=True, timeout=timeout)
        return {"rc": r.returncode, "stdout": r.stdout, "stderr": r.stderr}
    except subprocess.TimeoutExpired:
        return {"rc": -1, "stdout": "", "stderr": "timeout"}
    except Exception as e:  # noqa: BLE001
        return {"rc": -1, "stdout": "", "stderr": str(e)}


def run_json(cmd: List[str], cwd: Path) -> Dict[str, Any]:
    """跑 CLI 并尝试解析 stdout 为 JSON；失败返回 {'ok':False,...}。"""
    r = run_cmd(cmd, cwd)
    if r["rc"] != 0:
        return {"ok": False, "rc": r["rc"], "stderr_tail": r["stderr"][-800:]}
    try:
        return json.loads(r["stdout"])
    except json.JSONDecodeError:
        return {"ok": False, "rc": 0, "stdout_tail": r["stdout"][-800:]}


def gp_agent_cmd(command: str, workdir: Path, rec: Dict, foundry: str,
                 config: str, extra: List[str]) -> List[str]:
    return [PYTHON, str(GP_AGENT), command,
            "--workdir", str(workdir),
            "--case-root", str(rec["case_root"]),
            "--input-def", str(rec["input_def"]),
            "--config", config,
            "--foundry-dir", foundry,
            "--lef", str(rec.get("lef") or ""),
            *extra]


# ── 指标采集（权威：EGR + HPWL，都在 legalized placement.def 上测）──
def collect_metrics(rec: Dict, foundry: str, workdir: Path) -> Dict[str, Any]:
    """对一个 workdir 的 placement.def 采 EGR + HPWL。返回 {'egr':{...}, 'hpwl':...}。"""
    def_path = workdir / "placement.def"
    if not def_path.exists():
        return {"run_status": "no_placement"}

    egr = run_json([PYTHON, str(IRT_EGR),
                    "--workdir", str(workdir / "egr_eval"),
                    "--case-root", str(rec["case_root"]),
                    "--foundry-dir", foundry,
                    "--def-path", str(def_path)], REPO_ROOT)

    hpwl = None
    if rec.get("lef") and Path(rec["lef"]).exists():
        r = run_cmd([PYTHON, str(DEF_HPWL), str(rec["lef"]), str(def_path)], REPO_ROOT)
        # 输出形如 "HPWL=123 NETS=456 SKIPPED=0 DEF_UNITS=1000"
        for tok in r["stdout"].split():
            if tok.startswith("HPWL="):
                hpwl = float(tok.split("=", 1)[1])

    return {
        "run_status": "ok" if egr.get("ok") else "egr_failed",
        "egr": {
            "egr_total_overflow_union": egr.get("egr_total_overflow_union"),
            "egr_max_overflow_union": egr.get("egr_max_overflow_union"),
            "egr_avg_overflow_union": egr.get("egr_avg_overflow_union"),
            "egr_total_overflow_horizontal": egr.get("egr_total_overflow_horizontal"),
            "egr_total_overflow_vertical": egr.get("egr_total_overflow_vertical"),
        },
        "hpwl": hpwl,
        "legalized": egr.get("legalized"),
    }


def collect_rudy(rec: Dict, foundry: str, workdir: Path, def_path: Path) -> Dict[str, Any]:
    """gp_congestion_observe 读 RUDY 诊断（空间特征源，非标签）。

    写 rudy_util.csv + congestion_nets.json 到 workdir 根（cmd_local_congestion
    从此处读取热点图），返回 JSON 诊断报告（含 H/V 分离，从 congestion_result.json 补齐）。
    """
    out = run_json([PYTHON, str(CONG_OBSERVE),
                    "--case-root", str(rec["case_root"]),
                    "--def", str(def_path),
                    "--foundry-dir", foundry,
                    "--workdir", str(workdir),
                    "--bin-cnt-x", "64", "--bin-cnt-y", "64",
                    "--top-n", "8",
                    "--lef", str(rec.get("lef") or ""),
                    "--model", "rudy"], REPO_ROOT)
    # gp_congestion_observe 输出不含 H/V 分离，但 congestion_result.json 有；补齐。
    cj = workdir / "congestion_result.json"
    if cj.exists():
        try:
            cd = json.loads(cj.read_text())
            for k in ("rudy_utilization_h_max", "rudy_utilization_v_max"):
                if out.get(k) is None and cd.get(k) is not None:
                    out[k] = cd[k]
        except Exception:  # noqa: BLE001
            pass
    return out


# ── 缓存 ─────────────────────────────────────────────────────────
def _hash(v: Any) -> str:
    return hashlib.sha256(json.dumps(v, sort_keys=True).encode()).hexdigest()[:16]


def cache_key(design_key: str, action: str, seed: int, ieda_version: str, params: Dict) -> str:
    return f"{design_key}|{action}|{seed}|{ieda_version}|{_hash(params)}"


def load_cache() -> Dict[str, Dict]:
    out: Dict[str, Dict] = {}
    for line in read_jsonl(CACHE_PATH):
        if line.get("key"):
            out[line["key"]] = line.get("result", {})
    return out


def save_cache(key: str, result: Dict):
    append_jsonl(CACHE_PATH, {"key": key, "result": result})


# ── 主流程 ──────────────────────────────────────────────────────
def run_one(design_key: str, logical: str, split: str, action_name: str,
            act: Dict, rec: Dict, foundry: str, seed: int, ieda_version: str,
            cache: Dict, args) -> Optional[Dict]:
    """跑一个 (design, action, seed)，返回样本 dict（或 None 表示缓存未命中且失败）。"""
    out_root = Path(args.out_root) / design_key
    workdir = out_root / f"{action_name}_seed{seed}"
    params = {k: v for k, v in act.items() if k not in ("command", "needs_baseline", "type")}
    key = cache_key(design_key, action_name, seed, ieda_version, params)

    # 缓存命中：直接返回缓存的 metrics（features 需重新关联）
    if key in cache:
        return None  # 样本在 assemble 阶段用缓存 metrics 组装，不在此返回

    workdir.mkdir(parents=True, exist_ok=True)
    config = str(rec["pl_config"])

    if act["type"] == "compress_td":
        config = derive_config(rec["pl_config"], act["td"], workdir)
        extra = []
    elif act["type"] == "congest_ce":
        extra = ["--congestion-effort", str(act["ce"]), "--random-init", "1", "--seed", str(seed)]
    elif act["type"] == "timing":
        extra = ["--timing", "1", "--random-init", "1", "--seed", str(seed)]
    elif act["type"] == "baseline":
        extra = ["--seed", str(seed), "--random-init", "1", "--verify-egr", "1"]
    elif act["type"].startswith("evacuate"):
        # 疏散需要 baseline checkpoint：从 baseline 工作目录复制，再写 RUDY 图
        base_wd = out_root / f"baseline_seed{seed}"
        if not (base_wd / "pl" / "gp_session_checkpoint.json").exists():
            return None  # baseline 未就绪
        if workdir.exists():
            shutil.rmtree(workdir)
        shutil.copytree(base_wd, workdir)
        # local_congestion 读 workdir/rudy_util.csv 选热点，须先 observe（对 baseline 当前 def）
        collect_rudy(rec, foundry, workdir, workdir / "placement.def")
        scope = act["scope"]
        dt = act.get("density_target", 0.5)
        extra = ["--scope", scope, "--top-bins", "3", "--rounds", "2",
                 "--density-target", str(dt), "--iterations", "20"]
    else:
        extra = ["--seed", str(seed), "--random-init", "1"]

    cmd = gp_agent_cmd(act["command"], workdir, rec, foundry, config, extra)
    if args.dry_run:
        print(f"[dry-run] {design_key} {action_name} seed={seed}: {' '.join(cmd)}")
        return None

    res = run_json(cmd, REPO_ROOT)
    if not res.get("ok"):
        save_cache(key, {"run_status": "gp_failed", "detail": res.get("reason") or res.get("stderr_tail")})
        return None

    # local_congestion 返回 ok:true 但 failed_steps>0 表示疏散 diverged 且 rollback 失败，
    # checkpoint 可能已损坏，placement 未真正疏散。此时记 evacuate_diverged，不再 accept。
    if act["command"] == "local_congestion":
        total_steps = int(res.get("targets", 0)) * int(res.get("rounds", 0))
        failed_steps = int(res.get("failed_steps", 0))
        if total_steps > 0 and failed_steps >= total_steps:
            save_cache(key, {"run_status": "evacuate_diverged",
                             "detail": f"all {failed_steps}/{total_steps} evacuation steps diverged"})
            return None

    # start / local_congestion 只产出 GP（未合法化），须 accept 补 LG+DP 才能公平评分。
    if act["command"] in ("start", "local_congestion"):
        acc = run_json(gp_agent_cmd("accept", workdir, rec, foundry, config, []), REPO_ROOT)
        if not acc.get("ok"):
            save_cache(key, {"run_status": "accept_failed", "detail": acc.get("reason") or acc.get("stderr_tail")})
            return None

    metrics = collect_metrics(rec, foundry, workdir)
    save_cache(key, metrics)
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--designs", default="", help="逗号分隔的 design_key；空=split.json 全部")
    ap.add_argument("--actions", default="", help="逗号分隔的动作名；空=全部")
    ap.add_argument("--seeds", default="1000,2000,3000")
    ap.add_argument("--max-workers", type=int, default=4)
    ap.add_argument("--out-root", default=str(OUT_DIR / "runs"))
    ap.add_argument("--split", default="train,test,ood")
    ap.add_argument("--include-timing", action="store_true", help="纳入 timing 动作（H2）")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    designs_reg = load_json(FLOWS / "deepseek_harness" / "designs.json")
    split_cfg = load_json(HERE / "split.json")
    # 版本 = iEDA 二进制 hash（只随工具重建变化，不随脚本提交变化，保证续跑缓存稳定）
    ieda_bin = REPO_ROOT / "build" / "bin" / "iEDA"
    if ieda_bin.exists():
        ieda_version = hashlib.sha256(ieda_bin.read_bytes()).hexdigest()[:12]
    else:
        ieda_version = run_cmd(["git", "rev-parse", "--short", "HEAD"], REPO_ROOT)["stdout"].strip()

    # 组装设计清单（split → design_key → record）
    want_splits = [s.strip() for s in args.split.split(",") if s.strip()]
    design_entries: List[Dict] = []
    for sp in want_splits:
        for e in split_cfg.get(sp, []):
            dk = e["design_key"]
            if dk not in designs_reg:
                print(f"[warn] {dk} 不在 designs.json，跳过", file=sys.stderr)
                continue
            design_entries.append({"logical": e["logical_design"], "design_key": dk,
                                   "split": sp, "rec": designs_reg[dk]})

    if args.designs:
        want = set(d.strip() for d in args.designs.split(",") if d.strip())
        design_entries = [d for d in design_entries if d["design_key"] in want]

    acts = build_actions(args.include_timing)
    if args.actions:
        want_a = set(a.strip() for a in args.actions.split(",") if a.strip())
        acts = {k: v for k, v in acts.items() if k in want_a}

    seeds = [int(s) for s in args.seeds.split(",") if s.strip()]
    cache = load_cache()

    # 组装任务
    tasks = []
    for de in design_entries:
        rec = de["rec"]
        foundry = rec.get("foundry_dir") or str(REPO_ROOT / "scripts" / "foundry" / rec["pdk"])
        for an, act in acts.items():
            for seed in seeds:
                tasks.append((de, an, act, foundry, seed))

    print(f"[gen_dataset] 设计 {len(design_entries)} 动作 {len(acts)} seeds {len(seeds)} → 任务 {len(tasks)}"
          f" (ieda={ieda_version})", file=sys.stderr)

    # 并行执行（baseline 先跑，疏散依赖 baseline checkpoint，故按序分组）
    # 简化：先跑非 evacuate，再跑 evacuate（保证 baseline 已就绪）
    non_evac = [t for t in tasks if not t[2]["type"].startswith("evacuate")]
    evac = [t for t in tasks if t[2]["type"].startswith("evacuate")]

    def _run(t):
        de, an, act, foundry, seed = t
        return run_one(de["design_key"], de["logical"], de["split"], an, act, de["rec"],
                       foundry, seed, ieda_version, cache, args)

    for batch, label in ((non_evac, "非疏散"), (evac, "疏散")):
        if not batch:
            continue
        print(f"[gen_dataset] 阶段 {label}：{len(batch)} 任务", file=sys.stderr)
        with ThreadPoolExecutor(max_workers=args.max_workers) as ex:
            futs = {ex.submit(_run, t): t for t in batch}
            for i, fut in enumerate(as_completed(futs)):
                t = futs[fut]
                try:
                    fut.result()
                except Exception as e:  # noqa: BLE001
                    print(f"[error] {t[0]['design_key']} {t[1]}: {e}", file=sys.stderr)
                if (i + 1) % 10 == 0:
                    print(f"[progress] {i + 1}/{len(batch)}", file=sys.stderr)

    print("[gen_dataset] 完成。运行 assemble_dataset.py 组装 dataset.jsonl", file=sys.stderr)


if __name__ == "__main__":
    main()
