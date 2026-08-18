#!/usr/bin/env python3
"""Regression for the same-evaluator placement metric suite.

For every sky130 benchmark design, evaluates raw GP / agent / Innovus DEFs
with gp_metrics_compare.py and checks the metric contract:

  hpwl       : positive integer
  density    : ok, finite, >= 0
  rudy       : finite, >= 0, model == rudy
  timing     : ok, finite setup WNS/TNS and hold WNS/TNS, setup_wns <= 0

Optional --repeat N runs each design N times and requires all numeric metrics
to match within 1e-6 relative tolerance (determinism check).
"""
from __future__ import annotations

import argparse
import json
import math
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]

CASES = {
    "s1238": ("/tmp/p0_converged/s1238/placement.def",
              "/tmp/gp_agent_real_s1238b/local_restart/placement.def",
              "benchmarks/results/innovus_gp_compare/s1238/innovus_placed.def"),
    "apb4_timer": ("/tmp/p0_converged/apb4_timer/placement.def",
                   "/tmp/gp_agent_real_apb4_a/local_restart/placement.def",
                   "benchmarks/results/innovus_gp_compare/apb4_timer/innovus_placed.def"),
    "picorv32": ("/tmp/p0_converged/picorv32/placement.def",
                 "/tmp/p0_converged/picorv32/placement.def",
                 "benchmarks/results/innovus_gp_compare/picorv32/innovus_placed.def"),
    "aes": ("/tmp/p0_converged/aes/placement.def",
            "/tmp/gp_agent_real_aes_a/local_restart/placement.def",
            "benchmarks/results/innovus_gp_compare/aes/innovus_placed.def"),
}


def finite(x) -> bool:
    return x is not None and math.isfinite(float(x))


def check(entry, where):
    problems = []
    if not isinstance(entry.get("hpwl"), int) or entry["hpwl"] <= 0:
        problems.append(f"{where}: hpwl invalid")
    den = entry.get("density") or {}
    if not den.get("ok"):
        problems.append(f"{where}: density not ok ({den.get('density_reason')})")
    elif not finite(den.get("peak_cell_density")) or den["peak_cell_density"] < 0:
        problems.append(f"{where}: density peak invalid {den.get('peak_cell_density')}")
    if not finite(den.get("rudy_max_congestion")) or den["rudy_max_congestion"] < 0:
        problems.append(f"{where}: rudy max invalid {den.get('rudy_max_congestion')}")
    if den.get("congestion_model") != "rudy":
        problems.append(f"{where}: congestion model mismatch")
    tim = entry.get("timing") or {}
    if not tim.get("ok"):
        problems.append(f"{where}: timing not ok ({tim.get('reason')})")
    else:
        for k in ("setup_wns_ns", "setup_tns_ns", "hold_wns_ns", "hold_tns_ns"):
            if not finite(tim.get(k)):
                problems.append(f"{where}: timing {k} invalid {tim.get(k)}")
        if finite(tim.get("setup_wns_ns")) and tim["setup_wns_ns"] > 0:
            problems.append(f"{where}: setup WNS positive {tim['setup_wns_ns']}")
    return problems


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--designs", nargs="+", default=list(CASES))
    ap.add_argument("--repeat", type=int, default=1)
    ap.add_argument("--skip-timing", action="store_true")
    ap.add_argument("--out-dir", default="/tmp/gp_evaluator_regression")
    args = ap.parse_args()
    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    all_problems = []
    for design in args.designs:
        case_root = Path(f"/home/lizhijun/work/iEDA/docs/ipl/pl_vis/cases/{design}")
        macro_lef = REPO / "scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef"
        raw, agent, innovus = CASES[design]
        runs = []
        for rep in range(args.repeat):
            out = out_dir / f"{design}_{rep}.json"
            cmd = [sys.executable, str(REPO / "benchmarks/flows/gp_metrics_compare.py"),
                   "--design", design, "--case-root", str(case_root), "--macro-lef", str(macro_lef),
                   "--out", str(out)]
            if args.skip_timing:
                cmd.append("--no-timing")
            cmd += [f"raw={raw}", f"agent={agent}", f"innovus={innovus}"]
            proc = subprocess.run(cmd, cwd=REPO, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            if proc.returncode != 0:
                all_problems.append(f"{design}: gp_metrics_compare rc={proc.returncode} stderr={proc.stderr[-500:]}")
                continue
            data = json.loads(out.read_text())
            runs.append(data)
            for name, entry in data.get("placements", {}).items():
                all_problems.extend(check(entry, f"{design}/{name}"))
        if len(runs) == args.repeat and args.repeat > 1:
            first = runs[0]["placements"]
            for rep in range(1, len(runs)):
                for name, entry in runs[rep]["placements"].items():
                    for key in ("hpwl",):
                        if entry.get(key) != first[name].get(key):
                            all_problems.append(f"{design}/{name}: nondeterministic {key}")
                    for key in ("peak_cell_density", "rudy_max_congestion", "rudy_total_congestion"):
                        a = (entry.get("density") or {}).get(key)
                        b = (first[name].get("density") or {}).get(key)
                        if a is None or b is None or not math.isclose(float(a), float(b), rel_tol=1e-6):
                            all_problems.append(f"{design}/{name}: nondeterministic density/{key} {a} vs {b}")
                    for key in ("setup_wns_ns", "setup_tns_ns", "hold_wns_ns", "hold_tns_ns"):
                        a = (entry.get("timing") or {}).get(key)
                        b = (first[name].get("timing") or {}).get(key)
                        if a is None or b is None or not math.isclose(float(a), float(b), rel_tol=1e-6):
                            all_problems.append(f"{design}/{name}: nondeterministic timing/{key} {a} vs {b}")

    summary = {"ok": not all_problems, "designs": args.designs, "repeat": args.repeat,
               "problems": all_problems}
    print(json.dumps(summary, indent=2))
    (out_dir / "summary.json").write_text(json.dumps(summary, indent=2))
    return 0 if not all_problems else 1


if __name__ == "__main__":
    raise SystemExit(main())
