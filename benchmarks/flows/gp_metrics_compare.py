#!/usr/bin/env python3
"""Same-evaluator placement comparison: HPWL + density + timing.

Every DEF is loaded by the SAME iEDA evaluators:
  - HPWL:      benchmarks/flows/def_hpwl_eval.py
  - density:   iEDA `run_density_eval` (cell-density peak)
  - timing:    docs/ipl/pl_vis/cases/eval_timing_metrics.tcl (HPWL pre-route RC)

Usage:
  python3 benchmarks/flows/gp_metrics_compare.py \
    --design s1238 \
    --case-root /home/lizhijun/work/iEDA/docs/ipl/pl_vis/cases/s1238 \
    --macro-lef scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef \
    --grid-size 200 \
    raw=/tmp/p0_converged/s1238/placement.def \
    agent=/tmp/gp_agent_real_s1238b/accepted/placement.def \
    innovus=benchmarks/results/innovus_gp_compare/s1238/innovus_placed.def
"""
from __future__ import annotations

import argparse
import json
import re
import shlex
import subprocess
import sys
import tempfile
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
IEDa_BIN = Path(__import__("os").environ.get("IEDA_BIN", REPO / "build/bin/iEDA"))
TIMING_EVAL_TCL = Path("/home/lizhijun/work/iEDA/docs/ipl/pl_vis/cases/eval_timing_metrics.tcl")


def run(cmd: list[str], cwd=REPO, timeout=1800, env=None):
    return subprocess.run(cmd, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=timeout, env=env)


def hpwl(def_path: Path, macro_lef: Path):
    p = run([sys.executable, str(REPO / "benchmarks/flows/def_hpwl_eval.py"), str(macro_lef), str(def_path)])
    m = re.search(r"HPWL=(\d+)", p.stdout)
    return int(m.group(1)) if m else None


def density(def_path: Path, case_root: Path, grid_size: int, foundry_dir: Path, congestion_model: str = "rudy"):
    work = Path(tempfile.mkdtemp(prefix="gp_density_eval_"))
    tcl = work / "density_eval.tcl"
    tcl.write_text(
        f"flow_init -config {shlex.quote(str(case_root / 'iEDA_config/flow_config.json'))}\n"
        f"db_init -config {shlex.quote(str(case_root / 'iEDA_config/db_default_config.json'))} -output_dir_path {shlex.quote(str(work))}\n"
        f"source {shlex.quote(str(case_root / 'script/DB_script/db_path_setting.tcl'))}\n"
        f"source {shlex.quote(str(case_root / 'script/DB_script/db_init_lef.tcl'))}\n"
        f"def_init -path {shlex.quote(str(def_path))}\n"
        f"run_density_eval -eval_output_path {shlex.quote(str(work))} -grid_size {grid_size} -stage place\n"
        f"run_congestion_eval -model {congestion_model} -bin_cnt_x 64 -bin_cnt_y 64 -eval_output_path {shlex.quote(str(work))}\n"
        f"flow_exit\n")
    env = __import__("os").environ.copy()
    env.update({"CONFIG_DIR": str(case_root / "iEDA_config"), "RESULT_DIR": str(work),
                "TCL_SCRIPT_DIR": str(case_root / "script"),
                "FOUNDRY_DIR": str(foundry_dir),
                "SDC_FILE": str(next(case_root.glob("*.sdc")))})
    p = run([str(IEDa_BIN), "-script", str(tcl)], env=env)
    if p.returncode != 0:
        return {"ok": False, "rc": p.returncode, "log": p.stdout[-1000:]}
    result = {}
    csv = work / "density_map/place_allcell_density.csv"
    if csv.exists():
        try:
            values = []
            for line in csv.read_text().splitlines():
                for token in line.split(","):
                    token = token.strip()
                    if token:
                        values.append(float(token))
            if values and all(v >= 0.0 for v in values):
                result["ok"] = True
                result["peak_cell_density"] = max(values)
                result["mean_cell_density"] = sum(values) / len(values)
            else:
                result["ok"] = False
                result["density_reason"] = "density csv contains negative values" if values else "density csv empty"
        except Exception:
            result["ok"] = False
            result["density_reason"] = "density csv unparsable"
    else:
        result["ok"] = False
        result["density_reason"] = "density csv missing"
    cj = work / "congestion_result.json"
    if cj.exists():
        try:
            cdata = json.loads(cj.read_text())
            result["rudy_demand_max"] = cdata.get("rudy_demand_max")
            result["rudy_demand_total"] = cdata.get("rudy_demand_total")
            result["rudy_utilization_max"] = cdata.get("rudy_utilization_max")
            result["rudy_utilization_avg"] = cdata.get("rudy_utilization_avg")
            result["rudy_utilization_h_max"] = cdata.get("rudy_utilization_h_max")
            result["rudy_utilization_v_max"] = cdata.get("rudy_utilization_v_max")
            result["rudy_overflow_bin_count"] = cdata.get("rudy_overflow_bin_count")
            result["rudy_overflow_util_sum"] = cdata.get("rudy_overflow_util_sum")
            result["congestion_model"] = cdata.get("model")
            result["congestion_bin_cnt"] = (cdata.get("bin_cnt_x"), cdata.get("bin_cnt_y"))
        except Exception:
            result["congestion_reason"] = "congestion json unparsable"
    else:
        result["congestion_reason"] = "congestion json missing"
    return result


def timing(def_path: Path, case_root: Path, foundry_dir: Path):
    work = Path(tempfile.mkdtemp(prefix="gp_timing_eval_"))
    env = __import__("os").environ.copy()
    env.update({"INPUT_DEF": str(def_path), "RESULT_DIR": str(work),
                "CONFIG_DIR": str(case_root / "iEDA_config"),
                "TCL_SCRIPT_DIR": str(case_root / "script"),
                "FOUNDRY_DIR": str(foundry_dir),
                "SDC_FILE": str(next(case_root.glob("*.sdc")))})
    p = run([str(IEDa_BIN), "-script", str(TIMING_EVAL_TCL)], env=env, timeout=1800)
    tj = work / "timing_result.json"
    if p.returncode != 0 or not tj.exists():
        return {"ok": False, "rc": p.returncode, "log": p.stdout[-1000:]}
    data = json.loads(tj.read_text())
    clock = (data.get("HPWL", {}).get("clock_timings") or [{}])
    entry = clock[0] if clock else {}
    return {"ok": True, "setup_wns_ns": entry.get("setup_wns"), "setup_tns_ns": entry.get("setup_tns"),
            "hold_wns_ns": entry.get("hold_wns"), "hold_tns_ns": entry.get("hold_tns"),
            "suggest_freq_mhz": entry.get("suggest_freq")}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--design", required=True)
    ap.add_argument("--case-root", required=True)
    ap.add_argument("--macro-lef", required=True)
    ap.add_argument("--foundry-dir", default=str(REPO / "scripts/foundry/sky130"))
    ap.add_argument("--grid-size", type=int, default=200)
    ap.add_argument("--congestion-model", choices=["rudy", "lutrudy"], default="rudy")
    ap.add_argument("--no-timing", action="store_true")
    ap.add_argument("--out")
    ap.add_argument("defs", nargs="+")
    args = ap.parse_args()
    case_root = Path(args.case_root)
    macro_lef = Path(args.macro_lef)
    defs = []
    for item in args.defs:
        name, path = item.split("=", 1)
        defs.append((name, Path(path)))
    out = {"design": args.design, "placements": {}}
    for name, path in defs:
        if not path.exists():
            out["placements"][name] = {"def": str(path), "missing": True}
            continue
        entry = {"def": str(path), "hpwl": hpwl(path, macro_lef),
                 "density": density(path, case_root, args.grid_size, Path(args.foundry_dir), args.congestion_model)}
        if not args.no_timing and TIMING_EVAL_TCL.exists():
            entry["timing"] = timing(path, case_root, Path(args.foundry_dir))
        out["placements"][name] = entry
        print(json.dumps({"design": args.design, "placement": name, **entry}, indent=2), flush=True)
    if args.out:
        Path(args.out).write_text(json.dumps(out, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
