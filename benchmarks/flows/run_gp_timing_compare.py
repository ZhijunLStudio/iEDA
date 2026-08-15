#!/usr/bin/env python3
"""Timing-driven GP comparison: Innovus noPrePlaceOpt+t vs iEDA timing GP.

For each design this script:
  1. reuses the existing Innovus timing DEF (innovus_placed_nodel_timing.def)
     and derives an unplaced DEF from it, so iEDA solves the same full netlist;
  2. runs iEDA GP with is_timing_effort=1 through the session CLI;
  3. evaluates HPWL (def_hpwl_eval.py) and HPWL-based placement timing
     (eval_timing_metrics.tcl) for four placements:
       Innovus noPrePlaceOpt WL-only, Innovus noPrePlaceOpt timing,
       iEDA GP WL-only, iEDA GP timing;
  4. writes result.json under --result-root.

Usage:
  python3 benchmarks/flows/run_gp_timing_compare.py --designs s1238 apb4_timer picorv32 aes
"""
from __future__ import annotations

import argparse
import json
import re
import shlex
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
IEDa_BIN = Path(__import__("os").environ.get("IEDA_BIN", REPO_ROOT / "build/bin/iEDA"))
PLV_CASES_ROOT = Path("/home/lizhijun/work/iEDA/docs/ipl/pl_vis/cases")
HPWL_EVAL = REPO_ROOT / "benchmarks/flows/def_hpwl_eval.py"
TIMING_EVAL_TCL = PLV_CASES_ROOT / "eval_timing_metrics.tcl"
FOUNDRY_DIR = REPO_ROOT / "scripts/foundry/sky130"
MACRO_LEF = FOUNDRY_DIR / "lef/sky130_fd_sc_hd_merged.lef"
ATTEMPTS = (600, 520, 400)


def sh(p: Path | str) -> str:
    return shlex.quote(str(p))


def find_sdc(case_root: Path) -> Path:
    hits = sorted(case_root.glob("*.sdc"))
    if not hits:
        raise FileNotFoundError(f"no .sdc under {case_root}")
    # Some cases name the file after the macro (apb4.sdc) instead of the case.
    if len(hits) == 1:
        return hits[0]
    preferred = case_root / f"{case_root.name}.sdc"
    return preferred if preferred in hits else hits[0]


def derive_unplaced_def(src_path: Path, out_path: Path) -> None:
    src = src_path.read_text()
    start = src.find("\nCOMPONENTS")
    header_end = src.find("\n", start + 1)
    end = src.find("END COMPONENTS")
    blocks: list[list[str]] = []
    cur: list[str] | None = None
    for line in src[header_end:end].splitlines():
        if re.match(r"\s*-\s+", line):
            if cur is not None:
                blocks.append(cur)
            cur = [line]
        elif cur is not None:
            cur.append(line)
    if cur is not None:
        blocks.append(cur)
    out = []
    for block in blocks:
        joined = " ".join(block)
        m = re.match(r"\s*-\s+(\S+)\s+(\S+)", joined)
        if not m:
            out.append(joined)
            continue
        out.append(f"{m.group(0).rstrip()} + UNPLACED ;")
    merged = src[:start] + "\n" + src[start + 1 : header_end] + "\n" + "\n".join(out) + "\n" + src[end:]
    out_path.write_text(merged)


def make_timing_config(case_root: Path, out: Path) -> None:
    cfg = json.load(open(case_root / "iEDA_config/pl_default_config.json"))["PL"]
    cfg["is_timing_effort"] = 1
    cfg["is_congestion_effort"] = 0
    cfg["num_threads"] = 1
    cfg.setdefault("GP", {}).setdefault("Nesterov", {})["opt_overflow_list"] = [0.15, 0.20, 0.25, 0.30]
    out.write_text(json.dumps({"PL": cfg}, indent=2))


def write_gp_tcl(case_root: Path, workdir: Path, input_def: Path, config: Path, iters: int) -> Path:
    tcl = f"""flow_init -config {sh(case_root / 'iEDA_config/flow_config.json')}
db_init -config {sh(case_root / 'iEDA_config/db_default_config.json')} -output_dir_path {sh(workdir)}
source {sh(case_root / 'script/DB_script/db_path_setting.tcl')}
source {sh(case_root / 'script/DB_script/db_init_lib.tcl')}
source {sh(case_root / 'script/DB_script/db_init_sdc.tcl')}
source {sh(case_root / 'script/DB_script/db_init_lef.tcl')}
def_init -path {sh(input_def)}
init_pl -config {sh(config)}
placer_run_gp -mode start -iterations {iters} -seed 42 -report_route_util 1
catch {{placer_run_gp -mode accept}}
def_save -path {sh(workdir / 'ieda_timing.def')}
flow_exit
"""
    path = workdir / "ieda_timing_gp.tcl"
    path.write_text(tcl)
    return path


def run_ieda(workdir: Path, case_root: Path, sdc: Path, tcl: Path, log: Path) -> int:
    env = __import__("os").environ.copy()
    env.update({
        "CONFIG_DIR": str(case_root / "iEDA_config"),
        "RESULT_DIR": str(workdir),
        "TCL_SCRIPT_DIR": str(case_root / "script"),
        "FOUNDRY_DIR": str(FOUNDRY_DIR),
        "SDC_FILE": str(sdc),
    })
    with open(log, "w") as log_stream:
        proc = subprocess.run([str(IEDa_BIN), "-script", str(tcl)], cwd=REPO_ROOT, env=env,
                              stdout=log_stream, stderr=subprocess.STDOUT, timeout=3600)
    return proc.returncode


def run_timing_eval(case_root: Path, sdc: Path, input_def: Path, result_dir: Path, log: Path) -> tuple[int, dict]:
    result_dir.mkdir(parents=True, exist_ok=True)
    env = __import__("os").environ.copy()
    env.update({
        "INPUT_DEF": str(input_def),
        "RESULT_DIR": str(result_dir),
        "CONFIG_DIR": str(case_root / "iEDA_config"),
        "TCL_SCRIPT_DIR": str(case_root / "script"),
        "FOUNDRY_DIR": str(FOUNDRY_DIR),
        "SDC_FILE": str(sdc),
    })
    with open(log, "w") as log_stream:
        proc = subprocess.run([str(IEDa_BIN), "-script", str(TIMING_EVAL_TCL)], cwd=REPO_ROOT, env=env,
                              stdout=log_stream, stderr=subprocess.STDOUT, timeout=1800)
    timing_path = result_dir / "timing_result.json"
    timing = json.load(open(timing_path)) if timing_path.exists() else {}
    return proc.returncode, timing


def hpwl_of(def_path: Path) -> int | None:
    if not Path(def_path).exists():
        return None
    out = subprocess.run([sys.executable, str(HPWL_EVAL), str(MACRO_LEF), str(def_path)],
                         cwd=REPO_ROOT, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=600)
    if out.returncode != 0:
        return None
    m = re.search(r"HPWL=(\d+)", out.stdout)
    return int(m.group(1)) if m else None


def def_is_valid(def_path: Path) -> bool:
    if not Path(def_path).exists():
        return False
    text = Path(def_path).read_text(errors="ignore")
    if "( -1 -1 )" in text:
        return False
    return "END COMPONENTS" in text


def process_design(design: str, case_root: Path, result_root: Path) -> dict:
    workdir = result_root / design
    workdir.mkdir(parents=True, exist_ok=True)
    sdc = find_sdc(case_root)
    innovus_timing_def = case_root / "innovus_placed_nodel_timing.def"
    innovus_wl_def = case_root / "innovus_placed_nodel.def"
    ieda_wl_def = REPO_ROOT / "benchmarks/results/innovus_gp_compare_nodel" / design / "ieda_gp.def"
    if not innovus_timing_def.exists() or not innovus_wl_def.exists():
        raise FileNotFoundError(f"missing Innovus noPrePlaceOpt DEFs under {case_root}")

    unplaced = workdir / "ieda_in_unplaced.def"
    derive_unplaced_def(innovus_timing_def, unplaced)
    config = workdir / "pl_timing_config.json"
    make_timing_config(case_root, config)

    gp_ok = False
    last_log = workdir / "ieda_timing_gp.log"
    for iters in ATTEMPTS:
        for path in ["pl", "sta", "ieda_timing.def"]:
            p = workdir / path
            if p.is_dir():
                subprocess.run(["rm", "-rf", str(p)])
            elif p.exists():
                p.unlink()
        tcl = write_gp_tcl(case_root, workdir, unplaced, config, iters)
        rc = run_ieda(workdir, case_root, sdc, tcl, last_log)
        log_text = last_log.read_text(errors="ignore")
        m = re.search(r"iPL gp\.run \(start, (\d+) iterations\).*?stop_reason=(\S+).*?hpwl=(\d+) overflow=([0-9.eE+-]+)", log_text)
        gp_line = {"requested_iterations": iters, "stop_reason": m.group(2) if m else "rc_failed",
                   "iterations": int(m.group(1)) if m else None,
                   "hpwl": int(m.group(3)) if m else None,
                   "overflow": float(m.group(4)) if m else None,
                   "rc": rc}
        out_def = workdir / "ieda_timing.def"
        if rc == 0 and def_is_valid(out_def):
            gp_ok = True
            break
        print(json.dumps({"design": design, "attempt": iters, "rc": rc,
                          "valid_def": def_is_valid(out_def), "gp_line": gp_line}))
    if not gp_ok:
        return {"design": design, "ok": False, "reason": "iEDA timing GP failed", "log": str(last_log)}

    variants = {
        "innovus_wl": innovus_wl_def,
        "innovus_timing": innovus_timing_def,
        "ieda_wl": ieda_wl_def,
        "ieda_timing": workdir / "ieda_timing.def",
    }
    result: dict = {"design": design, "ok": True, "workdir": str(workdir), "sdc": str(sdc),
                    "gp": gp_line, "placements": {}}
    for name, def_path in variants.items():
        if name == "ieda_wl" and not Path(def_path).exists():
            result["placements"][name] = {"def": str(def_path), "missing": True}
            continue
        hpwl = hpwl_of(def_path)
        eval_dir = workdir / "timing_eval" / name
        eval_dir.mkdir(parents=True, exist_ok=True)
        eval_log = workdir / f"timing_eval_{name}.log"
        rc_eval, timing = run_timing_eval(case_root, sdc, def_path, eval_dir, eval_log)
        hpwl_timing = timing.get("HPWL", {}).get("clock_timings", [{}])
        entry = hpwl_timing[0] if hpwl_timing else {}
        result["placements"][name] = {
            "def": str(def_path), "hpwl": hpwl, "eval_rc": rc_eval,
            "setup_wns_ns": entry.get("setup_wns"), "setup_tns_ns": entry.get("setup_tns"),
            "hold_wns_ns": entry.get("hold_wns"), "hold_tns_ns": entry.get("hold_tns"),
            "suggest_freq_mhz": entry.get("suggest_freq"),
            "timing_json": str(eval_dir / "timing_result.json"), "eval_log": str(eval_log),
        }
    out_json = workdir / "result.json"
    out_json.write_text(json.dumps(result, indent=2))
    print(json.dumps({"design": design, "ok": True, "result": str(out_json), "gp": gp_line,
                      "summary": result["placements"]}, indent=2))
    return result


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--designs", nargs="+", default=["s1238", "apb4_timer", "picorv32", "aes"])
    ap.add_argument("--case-root", default=str(PLV_CASES_ROOT))
    ap.add_argument("--result-root", default=str(REPO_ROOT / "benchmarks/results/gp_timing_compare"))
    args = ap.parse_args()
    case_root = Path(args.case_root)
    result_root = Path(args.result_root)
    results = []
    for design in args.designs:
        results.append(process_design(design, case_root / design, result_root))
    (result_root / "summary.json").write_text(json.dumps(results, indent=2))
    failures = [r for r in results if not r.get("ok")]
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
