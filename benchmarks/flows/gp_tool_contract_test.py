#!/usr/bin/env python3
"""Cross-design / cross-PDK contract test for local_restart information.

For every case it checks that all HPWL fields the agent sees are in the SAME
unit and are equal to an independent def_hpwl_eval run on the corresponding
DEF. This is the tool-information audit, not a QoR benchmark.
"""
from __future__ import annotations

import argparse
import json
import math
import re
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]

CASES = {
    "s1238": {
        "design": "s1238",
        "parent": "/tmp/gp_agent_search/s1238/parent_400.json",
        "baseline": "/tmp/p0_converged/s1238/placement.def",
        "lef": "scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef",
        "scope": ["--scope", "longnet", "--scope-active-count", "100"],
    },
    "apb4_timer": {
        "design": "apb4_timer",
        "parent": "/tmp/gp_agent_search/apb4_timer/parent_400.json",
        "baseline": "/tmp/p0_converged/apb4_timer/placement.def",
        "lef": "scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef",
        "scope": ["--scope", "longnet", "--scope-active-count", "100"],
    },
    "picorv32": {
        "design": "picorv32",
        "parent": "/tmp/gp_agent_search/picorv32/parent_400.json",
        "baseline": "/tmp/p0_converged/picorv32/placement.def",
        "lef": "scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef",
        "scope": ["--scope", "hotspot", "--scope-active-ratio", "0.2"],
    },
    "aes": {
        "design": "aes",
        "parent": "/tmp/gp_agent_search/aes/parent_400.json",
        "baseline": "/tmp/p0_converged/aes/placement.def",
        "lef": "scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef",
        "scope": ["--scope", "hotspot", "--scope-active-ratio", "0.2"],
    },
    "nangate45_gcd": {
        "design": "nangate45_gcd",
        "parent": "/tmp/gp_nangate_parent300/pl/gp_session_checkpoint.json",
        "baseline": "/tmp/gp_nangate45_direct/placement.def",
        "case": "/tmp/nangate45_gcd",
        "input": "/tmp/nangate45_gcd/gcd_nangate45.def",
        "config": "/tmp/nangate45_gcd/pl_clean_config.json",
        "foundry": "/mnt/usb20t/PCL-167/data3/taosimin/OpenROAD/test/Nangate45",
        "lef": "/mnt/usb20t/PCL-167/data3/taosimin/OpenROAD/test/Nangate45/Nangate45_stdcell.lef",
        "scope": ["--scope", "longnet", "--scope-active-count", "40"],
    },
    "asap7_aes": {
        "design": "asap7_aes",
        "parent": "/tmp/gp_asap7_parent/pl/gp_session_checkpoint.json",
        "baseline": "/tmp/gp_asap7/placement.def",
        "case": "/tmp/asap7_aes",
        "input": "/tmp/asap7_aes/asap7_aes_initial.def",
        "config": "/tmp/asap7_aes/pl_clean_config.json",
        "foundry": "/mnt/usb20t/PCL-155/home/dengqinyi/iFlow/foundry/asap7",
        "lef": "/mnt/usb20t/PCL-155/home/dengqinyi/iFlow/foundry/asap7/lef/asap7sc7p5t_27_R_1x_201211.lef",
        "scope": ["--scope", "longnet", "--scope-active-count", "60"],
    },
    "ihp130_gcd": {
        "design": "ihp130_gcd",
        "parent": "/tmp/gp_ihp130_parent/pl/gp_session_checkpoint.json",
        "baseline": "/tmp/gp_ihp130_gcd/placement.def",
        "case": "/home/lizhijun/work/iEDA/scripts/design/ihp130_gcd",
        "input": "/home/lizhijun/work/iEDA/scripts/design/ihp130_gcd/result/iFP_result.def",
        "config": "/tmp/ihp130_gcd_pl_clean_config.json",
        "foundry": "/home/lizhijun/work/iEDA/scripts/foundry/ihp130",
        "lef": "/home/lizhijun/work/iEDA/scripts/foundry/ihp130/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_stdcell.lef",
        "scope": ["--scope", "hotspot", "--scope-active-ratio", "0.2"],
    },
}


def hpwl(lef: str, def_path: str) -> int | None:
    r = subprocess.run([sys.executable, str(REPO / "benchmarks/flows/def_hpwl_eval.py"), str(REPO / lef) if not Path(lef).is_absolute() else lef, def_path],
                       cwd=REPO, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    m = re.search(r"HPWL=(\d+)", r.stdout)
    return int(m.group(1)) if m else None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cases", nargs="+", default=list(CASES))
    ap.add_argument("--out", default="/tmp/gp_tool_contract_test")
    args = ap.parse_args()
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    problems = []
    results = {}
    for name in args.cases:
        c = CASES[name]
        workdir = out / name
        cmd = [sys.executable, str(REPO / "benchmarks/flows/gp_local_restart.py"),
               "--design", c["design"], "--workdir", str(workdir),
               "--checkpoint", c["parent"], "--force-local",
               "--baseline-def", str(REPO / c["baseline"] if not Path(c["baseline"]).is_absolute() else c["baseline"]),
               *c["scope"]]
        if c.get("case"):
            cmd += ["--case-root", c["case"], "--input-def", c["input"], "--config", c["config"],
                    "--foundry-dir", c["foundry"], "--lef", c["lef"]]
        r = subprocess.run(cmd, cwd=REPO, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if r.returncode != 0:
            problems.append(f"{name}: local_restart rc={r.returncode} {r.stderr[-400:]}")
            continue
        data = json.loads(r.stdout)
        results[name] = data
        lef = c["lef"] if Path(c["lef"]).is_absolute() else str(REPO / c["lef"])
        checks = []
        if data.get("raw_gp_hpwl_unit") != "def":
            checks.append("raw_gp_hpwl_unit != def")
        if data.get("local_restart_hpwl_unit") != "def":
            checks.append("local_restart_hpwl_unit != def")
        if data.get("parent_def_hpwl_unit") != "def":
            checks.append("parent_def_hpwl_unit != def")
        expected_raw = hpwl(lef, c["baseline"] if Path(c["baseline"]).is_absolute() else str(REPO / c["baseline"]))
        if expected_raw != data.get("raw_gp_hpwl"):
            checks.append(f"raw mismatch: result={data.get('raw_gp_hpwl')} def_hpwl_eval={expected_raw}")
        expected_local = hpwl(lef, str(workdir / "local_restart/placement.def"))
        if expected_local != data.get("local_restart_hpwl"):
            checks.append(f"local mismatch: result={data.get('local_restart_hpwl')} def_hpwl_eval={expected_local}")
        expected_parent = hpwl(lef, str(workdir / "parent_accepted/placement.def"))
        if expected_parent != data.get("parent_def_hpwl"):
            checks.append(f"parent mismatch: result={data.get('parent_def_hpwl')} def_hpwl_eval={expected_parent}")
        for k in ("local_restart_overflow", "local_restart_route_util"):
            v = data.get(k)
            if v is None or not math.isfinite(float(v)):
                checks.append(f"{k} invalid {v}")
        if checks:
            problems.append(f"{name}: " + "; ".join(checks))
        (out / f"{name}.json").write_text(json.dumps(data, indent=2))
    summary = {"ok": not problems, "cases": args.cases, "problems": problems}
    print(json.dumps(summary, indent=2))
    (out / "summary.json").write_text(json.dumps(summary, indent=2))
    return 0 if not problems else 1


if __name__ == "__main__":
    raise SystemExit(main())
