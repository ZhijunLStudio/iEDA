#!/usr/bin/env python3
"""Trial-route (EGR) feedback into the GP loop — session-level outer loop.

For each round: run GP (start) at target_density -> LG (legalize) -> EGR trial
route -> read the ROUTER overflow metrics. Lower target_density while the
router is over its target, relax when clean, and keep the best placement by
min(egr_total_overflow_union, tie-break min HPWL). This is the '布线器指标'
objective driving the GP loop (not RUDY).

Usage:
  python3 benchmarks/flows/gp_egr_refine.py \\
    --design s1238 --case-root ... --input-def ... --config ... \\
    --foundry-dir scripts/foundry/sky130 --lef ... --workdir /tmp/refine \\
    --iterations 400 --seed 1000 --congestion-effort 6 \\
    --initial-density 0.7 --min-density 0.45 --density-step 0.05 --rounds 4
"""
from __future__ import annotations

import argparse, json, os, shlex, subprocess, sys, tempfile
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
IEDa_BIN = Path(os.environ.get("IEDA_BIN", REPO / "build/bin/iEDA"))
sys.path.insert(0, str(REPO / "benchmarks/flows"))

from gp_agent import _derive_pdk_env, def_hpwl_of, resolve_lef, run_ieda, write_tcl  # noqa: E402


def egr_eval(workdir: Path, case_root: Path, foundry_dir: Path, def_path: Path) -> dict:
    tmp = Path(tempfile.mkdtemp(prefix="gp_egr_eval_"))
    tcl = tmp / "egr_eval.tcl"
    tcl.write_text(
        f"flow_init -config {shlex.quote(str(case_root / 'iEDA_config/flow_config.json'))}\n"
        f"db_init -config {shlex.quote(str(case_root / 'iEDA_config/db_default_config.json'))} -output_dir_path {shlex.quote(str(tmp))}\n"
        f"source {shlex.quote(str(case_root / 'script/DB_script/db_path_setting.tcl'))}\n"
        f"source {shlex.quote(str(case_root / 'script/DB_script/db_init_lib.tcl'))}\n"
        f"source {shlex.quote(str(case_root / 'script/DB_script/db_init_sdc.tcl'))}\n"
        f"source {shlex.quote(str(case_root / 'script/DB_script/db_init_lef.tcl'))}\n"
        f"def_init -path {shlex.quote(str(def_path))}\n"
        f"run_congestion_eval -model egr -eval_output_path {shlex.quote(str(tmp))}\n"
        f"flow_exit\n")
    env = os.environ.copy()
    env.update({
        "CONFIG_DIR": str(case_root / "iEDA_config"), "RESULT_DIR": str(tmp),
        "TCL_SCRIPT_DIR": str(case_root / "script"), "FOUNDRY_DIR": str(foundry_dir),
        "SDC_FILE": str(next(case_root.glob("*.sdc"))),
    })
    env.update(_derive_pdk_env(Path(foundry_dir)))
    p = subprocess.run([str(IEDa_BIN), "-script", str(tcl)], cwd=REPO, env=env,
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=1800)
    if p.returncode != 0:
        return {"ok": False, "rc": p.returncode, "log": p.stdout[-800:]}
    cj = tmp / "congestion_result.json"
    if not cj.exists():
        return {"ok": False, "reason": "congestion_result.json missing"}
    data = json.loads(cj.read_text())
    return {
        "ok": True,
        "egr_total_overflow_union": data.get("egr_total_overflow_union"),
        "egr_max_overflow_union": data.get("egr_max_overflow_union"),
        "egr_avg_overflow_union": data.get("egr_avg_overflow_union"),
        "egr_total_overflow_horizontal": data.get("egr_total_overflow_horizontal"),
        "egr_total_overflow_vertical": data.get("egr_total_overflow_vertical"),
        "egr_valid": data.get("egr_valid"),
    }


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--design", required=True)
    ap.add_argument("--case-root", required=True)
    ap.add_argument("--input-def", required=True)
    ap.add_argument("--config", required=True)
    ap.add_argument("--foundry-dir", required=True)
    ap.add_argument("--lef")
    ap.add_argument("--workdir", required=True)
    ap.add_argument("--iterations", type=int, default=400)
    ap.add_argument("--seed", type=int, default=1000)
    ap.add_argument("--congestion-effort", type=int, default=6)
    ap.add_argument("--initial-density", type=float, default=0.7)
    ap.add_argument("--min-density", type=float, default=0.45)
    ap.add_argument("--density-step", type=float, default=0.05)
    ap.add_argument("--rounds", type=int, default=4)
    ap.add_argument("--target-overflow", type=float, default=0.0)
    ap.add_argument("--no-dp", action="store_true")
    ap.add_argument("--out", default="")
    args = ap.parse_args()
    args.dp = not args.no_dp

    workdir = Path(args.workdir); workdir.mkdir(parents=True, exist_ok=True)
    case_root = Path(args.case_root); foundry = Path(args.foundry_dir)
    config = Path(args.config); input_def = Path(args.input_def)
    lef = resolve_lef(foundry, args.lef)

    best = None
    rows = []
    for rnd in range(args.rounds):
        density = max(args.min_density, args.initial_density - rnd * args.density_step)
        cmd = [
            f"placer_run_gp -mode start -iterations {args.iterations} -seed {args.seed} "
            f"-target_density {density:.4f} -congestion_effort {args.congestion_effort} -report_route_util 1",
            "placer_run_gp -mode accept",
        ]
        rc, out, err = run_ieda(workdir, case_root, foundry, config, input_def, cmd, def_save=True)
        if rc != 0:
            rows.append({"round": rnd, "density": density, "gp_rc": rc, "err": err[-300:]})
            continue
        # legalize so the trial router can find access points
        rc, out, err = run_ieda(workdir, case_root, foundry, config, workdir / "placement.def", ["placer_run_lg"], def_save=True)
        if rc != 0:
            rows.append({"round": rnd, "density": density, "lg_rc": rc, "err": err[-300:]})
            continue
        # detailed placement refines both HPWL and router congestion (DP needs LG first)
        if args.dp:
            rc, out, err = run_ieda(workdir, case_root, foundry, config, workdir / "placement.def", ["placer_run_dp"], def_save=True)
            if rc != 0:
                rows.append({"round": rnd, "density": density, "dp_rc": rc, "err": err[-300:]})
                continue
        egr = egr_eval(workdir, case_root, foundry, workdir / "placement.def")
        hpwl = def_hpwl_of(workdir / "placement.def", lef)
        row = {"round": rnd, "density": density, "hpwl": hpwl, **egr}
        rows.append(row)
        print(json.dumps(row), flush=True)
        if not egr.get("ok"):
            continue
        key = (egr.get("egr_total_overflow_union") or 0, hpwl or 0)
        if best is None or key < best[0]:
            best = (key, workdir / "placement.def", row)
        if egr.get("egr_total_overflow_union") == 0 and egr.get("egr_max_overflow_union") == 0:
            break

    summary = {"design": args.design, "best": None, "rows": rows}
    if best is not None:
        best_def = workdir / "placement.def"
        summary["best"] = {
            "def": str(best_def), "key": best[0], **{k: v for k, v in best[2].items() if k != "round"},
        }
        summary["best"]["round"] = best[2]["round"]
    if args.out:
        Path(args.out).write_text(json.dumps(summary, indent=2))
    print(json.dumps({"summary": summary}, indent=2))
    return 0 if best is not None else 1


if __name__ == "__main__":
    raise SystemExit(main())
