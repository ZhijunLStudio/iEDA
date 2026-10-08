#!/usr/bin/env python3
"""Run the read-only iSTA timing evaluator for one DEF and return the worst
paths with instance sets that can be fed directly to scope=instances.

Backing implementation for ieda_gp_observe kind=timing_paths. No placement
state changes.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import shlex
import subprocess
import sys
from pathlib import Path


def ieda_bin() -> Path:
    root = Path(__file__).resolve().parents[2]
    return root / "build/bin/iEDA"


def instance_of(node_name: str):
    # "instance:pin (CELL)" -> instance
    name = node_name.split("(")[0].strip()
    if ":" not in name:
        return None
    inst = name.split(":", 1)[0].strip()
    if not inst or inst.upper() == "PIN":
        return None
    return inst


def extract_paths(report: dict, max_paths: int):
    paths = []
    for path in report.get("paths", [])[:max_paths]:
        instances = []
        for node in path.get("nodes") or []:
            inst = instance_of(node.get("name", ""))
            if inst and inst not in instances:
                instances.append(inst)
        nodes = path.get("nodes") or []
        paths.append({
            "endpoint": path.get("endpoint"),
            "slack": path.get("slack"),
            "arrive_time": path.get("arrive_time"),
            "require_time": path.get("require_time"),
            "start_point": nodes[0].get("name") if nodes else None,
            "end_point": nodes[-1].get("name") if nodes else None,
            "instance_count": len(instances),
            "scope_instances": ",".join(instances),
            "instances": instances,
        })
    return paths


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--case-root", required=True)
    ap.add_argument("--def", dest="def_path", required=True)
    ap.add_argument("--foundry-dir", required=True)
    ap.add_argument("--workdir", required=True)
    ap.add_argument("--max-path", type=int, default=3)
    args = ap.parse_args()

    case_root = Path(args.case_root)
    work = Path(args.workdir)
    work.mkdir(parents=True, exist_ok=True)
    sdc = case_root / f"{case_root.name}.sdc"
    if not sdc.exists():
        sdc = next(case_root.glob("*.sdc"))
    tcl = work / "gp_timing_paths.tcl"
    path_json = work / "timing_paths.json"
    tcl.write_text(
        "if {![info exists ::env(INPUT_DEF)] || $::env(INPUT_DEF) eq \"\"} { error \"Missing INPUT_DEF\" }\n"
        "if {![info exists ::env(RESULT_DIR)] || $::env(RESULT_DIR) eq \"\"} { error \"Missing RESULT_DIR\" }\n"
        "flow_init -config $::env(CONFIG_DIR)/flow_config.json\n"
        "db_init -config $::env(CONFIG_DIR)/db_default_config.json -output_dir_path $::env(RESULT_DIR)\n"
        "source $::env(TCL_SCRIPT_DIR)/DB_script/db_path_setting.tcl\n"
        "source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lib.tcl\n"
        "source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_sdc.tcl\n"
        "source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lef.tcl\n"
        "def_init -path $::env(INPUT_DEF)\n"
        "run_timing_eval -eval_output_path $::env(RESULT_DIR) -routing_type HPWL "
        f"-path_json {shlex.quote(str(path_json))} -max_path {args.max_path}\n"
        "flow_exit\n")
    env = os.environ.copy()
    env.update({"INPUT_DEF": str(args.def_path), "RESULT_DIR": str(work),
                "CONFIG_DIR": str(case_root / "iEDA_config"),
                "TCL_SCRIPT_DIR": str(case_root / "script"),
                "FOUNDRY_DIR": str(args.foundry_dir),
                "SDC_FILE": str(sdc)})
    proc = subprocess.run([str(ieda_bin()), "-script", str(tcl)], cwd=ieda_bin().parents[2],
                          env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=1800)
    if proc.returncode != 0:
        print(json.dumps({"ok": False, "rc": proc.returncode, "stderr_tail": proc.stderr[-2000:]}))
        return 1
    report = None
    if path_json.exists():
        try:
            report = json.loads(path_json.read_text())
        except Exception:
            report = None
    if report is None:
        print(json.dumps({"ok": False, "reason": "timing evaluator ran but produced no timing_paths.json", "workdir": str(work)}))
        return 1
    timing_summary = {}
    tj = work / "timing_result.json"
    if tj.exists():
        try:
            data = json.loads(tj.read_text())
            clock = (data.get("HPWL", {}).get("clock_timings") or [{}])
            timing_summary = clock[0] if clock else {}
        except Exception:
            pass
    paths = extract_paths(report, args.max_path)
    print(json.dumps({
        "ok": True,
        "evaluator": "run_timing_eval HPWL",
        "def": str(Path(args.def_path).resolve()),
        "timing_summary": timing_summary,
        "path_json": str(path_json),
        "path_count": len(paths),
        "paths": paths,
        "cost": {"elapsed_s": -1.0, "cacheable": True},
    }))
    return 0


if __name__ == "__main__":
    sys.exit(main())
