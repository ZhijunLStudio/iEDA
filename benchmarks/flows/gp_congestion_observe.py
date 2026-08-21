#!/usr/bin/env python3
"""Run the read-only RUDY congestion evaluator for one DEF and derive
executable hotspot regions from the utilization map.

This is the backing implementation for ieda_gp_observe kind=congestion_hotspots.
It starts iEDA exactly once, reads the two CSVs the evaluator writes, and
returns facts + executable region rectangles. No placement state changes.
"""
from __future__ import annotations

import argparse
import importlib.util
import json
import shlex
import subprocess
import sys
from pathlib import Path


def ieda_bin() -> Path:
    root = Path(__file__).resolve().parents[2]
    return root / "build/bin/iEDA"


def parse_die_and_core(def_path: Path):
    text = def_path.read_text(errors="ignore")
    die = None
    for line in text.splitlines():
        s = line.strip().upper()
        if s.startswith("DIEAREA"):
            nums = list(map(int, __import__("re").findall(r"-?\d+", line)))
            die = tuple(nums[:4]) if len(nums) >= 4 else None
            break
    core = die
    min_x, min_y, max_x, max_y = 2**62, 2**62, -(2**62), -(2**62)
    for line in text.splitlines():
        if not line.strip().upper().startswith("ROW"):
            continue
        m = __import__("re").search(
            r"ROW\s+\S+\s+\S+\s+(-?\d+)\s+(-?\d+)\s+\S+\s+DO\s+(\d+)\s+BY\s+\d+\s+STEP\s+(-?\d+)\s+(-?\d+)",
            line, __import__("re").I)
        if not m:
            continue
        x0, y0 = int(m.group(1)), int(m.group(2))
        n, sx, sy = int(m.group(3)), int(m.group(4)), int(m.group(5))
        if sx == 0 and sy == 0:
            continue
        x1, y1 = x0 + n * sx, y0 + sy
        min_x, min_y = min(min_x, x0), min(min_y, y0)
        max_x, max_y = max(max_x, x1), max(max_y, y1)
    if min_x <= max_x and min_y <= max_y:
        core = (min_x, min_y, max_x, max_y)
    return {"die": die, "core": core}


def read_csv(path: Path):
    rows = []
    for line in path.read_text().splitlines():
        vals = [float(t) for t in line.split(",") if t.strip() != ""]
        if vals:
            rows.append(vals)
    return rows


def def_net_instances(def_path: Path, macros: dict, region):
    """Long nets whose HPWL bbox passes through the congestion region.

    Returns executable instance scopes (same instance names as the DEF) for
    scope=instances local GP.
    """
    import importlib.util
    spec = importlib.util.spec_from_file_location("def_hpwl_eval", Path(__file__).resolve().parent / "def_hpwl_eval.py")
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    text = Path(def_path).read_text(errors="ignore")
    comp = {}
    section = text[text.find("COMPONENTS") : text.find("END COMPONENTS")]
    for block in m.split_def_blocks(section):
        joined = " ".join(block)
        mn = __import__("re").match(r"\s*-+\s+(\S+)\s+(\S+)", joined)
        if not mn:
            continue
        mp = __import__("re").search(r"(?:PLACED|FIXED)\s*\(\s*([-\d]+)\s+([-\d]+)\s*\)\s*([A-Z]+)", joined)
        if mp:
            comp[mn.group(1).replace("\\/", "/")] = (mn.group(2), int(mp.group(1)), int(mp.group(2)), mp.group(3))
    pins = {}
    section = text[text.find("PINS") : text.find("END PINS")]
    for block in m.split_def_blocks(section):
        joined = " ".join(block)
        mn = __import__("re").match(r"\s*-+\s+(\S+)\s+", joined)
        mp = __import__("re").search(r"(?:PLACED|FIXED)\s*\(\s*([-\d]+)\s+([-\d]+)\s*\)\s*([A-Z]+)", joined) if mn else None
        if mn and mp:
            pins[mn.group(1)] = (int(mp.group(1)), int(mp.group(2)), mp.group(3))
    nets_start = __import__("re").search(r"\nNETS\s", text)
    nets_end = text.find("END NETS")
    section = text[nets_start.end() - len("NETS") - 1 : nets_end] if nets_start and nets_end > nets_start.end() else text[text.find("\nNETS ") : nets_end]
    cleaned = []
    for line in section.splitlines():
        s2 = line.strip()
        u = s2.upper()
        if u.startswith("ROUTED") or u.startswith("+ ROUTED") or u.startswith("NEW") or __import__("re").match(r"^[A-Z]+\d*\s+", s2):
            continue
        if s2.startswith("-") or s2.startswith("(") or s2.startswith("+ USE") or s2.startswith("+ WEIGHT") or s2.startswith("+ SOURCE"):
            cleaned.append(line)
    nets = []
    cur = None
    for line in cleaned:
        s2 = line.strip()
        if s2.startswith("-"):
            if cur is not None:
                nets.append(cur)
            cur = [s2]
        elif cur is not None:
            cur.append(s2)
    if cur is not None:
        nets.append(cur)

    def inst_abs(inst_name, pin_name):
        inst_name = inst_name.replace("\\/", "/")
        if inst_name not in comp or comp[inst_name][0] not in macros:
            return None
        macro, x, y, o = comp[inst_name]
        w, h = macros[macro]["size"]
        px, py = macros[macro]["pins"].get(pin_name, (w / 2.0, h / 2.0))
        qx, qy = m.transform_pin(px, py, w, h, o)
        return (x + qx, y + qy)

    region_lx, region_ly, region_ux, region_uy = region
    scored = []
    for net in nets:
        points = []
        instances = []
        for inst, pin in __import__("re").findall(r"\(\s*([^\s()]+)\s+([^\s()]+)\s*\)", " ".join(net)):
            inst = inst.replace("\\/", "/")
            if inst == "PIN":
                if pin in pins:
                    points.append((pins[pin][0], pins[pin][1]))
            else:
                p = inst_abs(inst, pin)
                if p is not None:
                    points.append(p)
                    if inst not in instances:
                        instances.append(inst)
        if len(points) < 2:
            continue
        xs = [p[0] for p in points]
        ys = [p[1] for p in points]
        lx, ly, ux, uy = min(xs), min(ys), max(xs), max(ys)
        ox = max(0, min(ux, region_ux) - max(lx, region_lx))
        oy = max(0, min(uy, region_uy) - max(ly, region_ly))
        overlap = ox * oy
        if overlap <= 0:
            continue
        region_area = max(1, (region_ux - region_lx) * (region_uy - region_ly))
        bbox_area = max(1, (ux - lx) * (uy - ly))
        score = (overlap / region_area) * (0.5 + 0.5 * (overlap / bbox_area))
        net_name = net[0].strip().split()
        net_name = net_name[1] if len(net_name) > 1 else net[0][1:].strip()
        scored.append({"net": net_name, "hpwl": int(ux - lx + uy - ly), "pin_count": len(points),
                       "instance_count": len(instances), "bbox": [lx, ly, ux, uy], "overlap_ratio": overlap / region_area,
                       "score": score, "scope_instances": ",".join(instances), "instances": instances})
    scored.sort(key=lambda x: -x["score"])
    return scored


def hotspots(util_rows, region, bin_cnt_x, bin_cnt_y, top_n):
    lx, ly, ux, uy = region
    size_x = (ux - lx) / bin_cnt_x
    size_y = (uy - ly) / bin_cnt_y
    bins = []
    for r, row in enumerate(util_rows):
        # CSV rows are printed bottom-up.
        y = ly + (bin_cnt_y - 1 - r) * size_y
        for c, util in enumerate(row):
            if util <= 1.0:
                continue
            x = lx + c * size_x
            bins.append({"row": r, "col": c, "utilization": util,
                         "llx": int(x), "lly": int(y),
                         "urx": int(min(x + size_x, ux)), "ury": int(min(y + size_y, uy))})
    bins.sort(key=lambda b: -b["utilization"])
    # Sub-1.0 fallback: when no bin overflows, seed the congestion-net cone
    # from the hottest bins anyway - designs like asap7 (Innovus-level
    # spreading, rudy_max ~0.77) still have a demand peak worth shortening.
    if not bins:
        all_bins = []
        for r, row in enumerate(util_rows):
            y = ly + (bin_cnt_y - 1 - r) * size_y
            for c, util in enumerate(row):
                if util <= 0.0:
                    continue
                x = lx + c * size_x
                all_bins.append({"row": r, "col": c, "utilization": util,
                                 "llx": int(x), "lly": int(y),
                                 "urx": int(min(x + size_x, ux)), "ury": int(min(y + size_y, uy))})
        all_bins.sort(key=lambda b: -b["utilization"])
        bins = all_bins[: top_n]
    selected = bins[:top_n]
    # Merge adjacent overflow bins into executable rectangles.
    merged = []
    used = set()
    for i, b in enumerate(selected):
        if i in used:
            continue
        rect = [b["llx"], b["lly"], b["urx"], b["ury"]]
        changed = True
        while changed:
            changed = False
            for j, c in enumerate(selected):
                if j in used or i == j:
                    continue
                if not (rect[2] >= c["llx"] and rect[0] <= c["urx"] and rect[3] >= c["lly"] and rect[1] <= c["ury"]):
                    continue
                rect[0] = min(rect[0], c["llx"]); rect[1] = min(rect[1], c["lly"])
                rect[2] = max(rect[2], c["urx"]); rect[3] = max(rect[3], c["ury"])
                used.add(j); changed = True
        merged.append({"bbox": rect, "utilization": b["utilization"],
                       "region": f"{rect[0]} {rect[1]} {rect[2]} {rect[3]}"})
    return selected, merged


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--case-root", required=True)
    ap.add_argument("--def", dest="def_path", required=True)
    ap.add_argument("--foundry-dir", required=True)
    ap.add_argument("--workdir", required=True)
    ap.add_argument("--bin-cnt-x", type=int, default=64)
    ap.add_argument("--bin-cnt-y", type=int, default=64)
    ap.add_argument("--top-n", type=int, default=8)
    ap.add_argument("--lef")
    ap.add_argument("--model", choices=["rudy", "lutrudy"], default="rudy")
    args = ap.parse_args()

    case_root = Path(args.case_root)
    work = Path(args.workdir)
    work.mkdir(parents=True, exist_ok=True)
    sdc = case_root / f"{case_root.name}.sdc"
    if not sdc.exists():
        sdc = next(case_root.glob("*.sdc"))
    tcl = work / "gp_congestion_observe.tcl"
    tcl.write_text(
        f"flow_init -config {shlex.quote(str(case_root / 'iEDA_config/flow_config.json'))}\n"
        f"db_init -config {shlex.quote(str(case_root / 'iEDA_config/db_default_config.json'))} -output_dir_path {shlex.quote(str(work))}\n"
        f"source {shlex.quote(str(case_root / 'script/DB_script/db_path_setting.tcl'))}\n"
        f"source {shlex.quote(str(case_root / 'script/DB_script/db_init_lef.tcl'))}\n"
        f"def_init -path {shlex.quote(str(args.def_path))}\n"
        f"run_congestion_eval -model {args.model} -bin_cnt_x {args.bin_cnt_x} -bin_cnt_y {args.bin_cnt_y} -eval_output_path {shlex.quote(str(work))}\n"
        "flow_exit\n")
    env = __import__("os").environ.copy()
    env.update({"CONFIG_DIR": str(case_root / "iEDA_config"), "RESULT_DIR": str(work),
                "TCL_SCRIPT_DIR": str(case_root / "script"), "FOUNDRY_DIR": str(args.foundry_dir),
                "SDC_FILE": str(sdc)})
    proc = subprocess.run([str(ieda_bin()), "-script", str(tcl)], cwd=ieda_bin().parents[2],
                          env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=1800)
    if proc.returncode != 0:
        print(json.dumps({"ok": False, "rc": proc.returncode, "stderr_tail": proc.stderr[-2000:]}))
        return 1
    summary = {}
    cj = work / "congestion_result.json"
    if cj.exists():
        summary = json.loads(cj.read_text())
    util_rows = read_csv(work / "rudy_util.csv") if (work / "rudy_util.csv").exists() else []
    region = summary.get("region")
    if not region:
        geo = parse_die_and_core(Path(args.def_path))
        region = geo["core"]
    top_bins, regions = [], []
    if util_rows and region:
        top_bins, regions = hotspots(util_rows, region, args.bin_cnt_x, args.bin_cnt_y, args.top_n)
    congestion_nets = []
    if regions and region:
        spec = importlib.util.spec_from_file_location("def_hpwl_eval", Path(__file__).resolve().parent / "def_hpwl_eval.py")
        mm = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mm)
        macros, _ = mm.parse_lef(str(case_root / "script/DB_script/db_path_setting.tcl")) if False else (None, None)
        lef_candidates = [Path(args.lef)] if args.lef and Path(args.lef).exists() else (sorted(Path(args.foundry_dir).rglob("*merged*.lef")) or sorted(Path(args.foundry_dir).rglob("*.lef")))
        if lef_candidates:
            macros, _ = mm.parse_lef(str(lef_candidates[0]))
            congestion_nets = def_net_instances(Path(args.def_path), macros, regions[0]["bbox"])[: args.top_n]
    with open(work / "congestion_nets.json", "w") as _cf:
        json.dump({"def": str(Path(args.def_path).resolve()), "regions": regions, "congestion_nets": congestion_nets}, _cf, indent=2)
    print(json.dumps({
        "ok": True,
        "def": str(Path(args.def_path).resolve()),
        "region": region,
        "model": args.model,
        "bin_cnt": [args.bin_cnt_x, args.bin_cnt_y],
        "rudy_demand_max": summary.get("rudy_demand_max"),
        "rudy_demand_total": summary.get("rudy_demand_total"),
        "rudy_utilization_max": summary.get("rudy_utilization_max"),
        "rudy_utilization_avg": summary.get("rudy_utilization_avg"),
        "rudy_overflow_bin_count": summary.get("rudy_overflow_bin_count"),
        "rudy_overflow_util_sum": summary.get("rudy_overflow_util_sum"),
        "demand_map": summary.get("rudy_demand_map_path"),
        "util_map": summary.get("rudy_util_map_path"),
        "top_bins": top_bins,
        "regions": regions,
        "congestion_nets": congestion_nets,
        "cost": {"elapsed_s": -1.0, "cacheable": True},
    }))
    return 0


if __name__ == "__main__":
    sys.exit(main())
