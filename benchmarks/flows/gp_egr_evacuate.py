#!/usr/bin/env python3
"""EGR-hotspot evacuation: close the trial-route -> GP feedback loop.

For each round:
  1. trial-route the current placement (gp_egr_hotspots) -> top-N overflow bins;
  2. for each hot bin, run a region-scoped GP advance that lowers the density
     screen inside that bin (evacuates cells out of the wiring hotspot);
  3. LG -> DP -> def_save;
  4. re-measure EGR overflow; keep the move when max/total overflow improves.

This is the EGR (real router metric) counterpart of local_congestion, which
was RUDY-based.
"""
from __future__ import annotations
import argparse, json, shlex, shutil, subprocess, sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
PY_EXE = sys.executable or "python3"
sys.path.insert(0, str(REPO / "benchmarks/flows"))

from gp_agent import _derive_pdk_env, def_hpwl_of, resolve_lef, run_ieda  # noqa: E402
from gp_egr_hotspots import hotspots  # noqa: E402


def local_run(workdir, case_root, foundry, config, input_def, lef, region, density_target, iterations):
    cmd = [PY_EXE, str(REPO / "benchmarks/flows/gp_agent.py"), "local_run",
           "--workdir", str(workdir), "--case-root", str(case_root),
           "--input-def", str(input_def), "--config", str(config),
           "--foundry-dir", str(foundry), "--lef", str(lef),
           "--scope", "region", "--scope-region", region,
           "--scope-density-target", str(density_target),
           "--iterations", str(iterations)]
    p = subprocess.run(cmd, cwd=REPO, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=1800)
    try:
        payload = json.loads(p.stdout.strip())
    except Exception:
        payload = {"ok": False, "rc": p.returncode, "out": p.stdout[-500:]}
    return p.returncode == 0 and bool(payload.get("ok")), payload


def lg_dp(workdir, case_root, foundry, config, input_def):
    rc, out, err = run_ieda(workdir, case_root, foundry, config, workdir / "placement.def",
                            ["placer_run_lg", "placer_run_dp"], def_save=True)
    return rc == 0


def egr_measure(case_root, foundry, def_path, out_dir):
    return hotspots(case_root, foundry, def_path, out_dir, top_n=9999)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--case-root", required=True)
    ap.add_argument("--foundry-dir", required=True)
    ap.add_argument("--lef", required=True)
    ap.add_argument("--input-def", required=True)
    ap.add_argument("--config", required=True)
    ap.add_argument("--workdir", required=True)
    ap.add_argument("--top-n", type=int, default=6)
    ap.add_argument("--scope-density-target", type=float, default=0.7)
    ap.add_argument("--iterations", type=int, default=20)
    ap.add_argument("--rounds", type=int, default=1)
    args = ap.parse_args()

    workdir = Path(args.workdir)
    case_root = Path(args.case_root); foundry = Path(args.foundry_dir)
    config = Path(args.config); input_def = Path(args.input_def); lef = Path(args.lef)

    base_def = workdir / "base.def"
    shutil.copy2(workdir / "placement.def", base_def)
    rollback_ckpt = workdir / "pl/evac_rollback_checkpoint.json"
    ckpt = workdir / "pl/gp_session_checkpoint.json"
    if ckpt.exists():
        shutil.copy2(ckpt, rollback_ckpt)

    measure_dir = workdir / "egr_measure"
    base = egr_measure(case_root, foundry, base_def, measure_dir)
    if not base.get("ok"):
        print(json.dumps({"ok": False, "base": base}))
        return 1
    history = [{"phase": "base", "max": base["max_overflow"], "sum": base["overflow_sum"],
                "hpwl": def_hpwl_of(base_def, lef)}]
    print(json.dumps(history[-1]), flush=True)

    regions = [b["region"] for b in base.get("top", [])[:args.top_n]]
    for ri, region in enumerate(regions):
        ok, payload = local_run(workdir, case_root, foundry, config, input_def, lef,
                                region, args.scope_density_target, args.iterations)
        if not ok:
            history.append({"phase": f"evac{ri}", "region": region, "ok": False, **payload})
            continue
        if not lg_dp(workdir, case_root, foundry, config, input_def):
            history.append({"phase": f"lgdp{ri}", "region": region, "ok": False})
            continue
    # measure the final cumulative result
    final_def = workdir / "placement.def"
    meas = egr_measure(case_root, foundry, final_def, measure_dir)
    final_hpwl = def_hpwl_of(final_def, lef)
    new_key = (meas.get("max_overflow", 1e9), meas.get("overflow_sum", 1e18))
    base_key = (base["max_overflow"], base["overflow_sum"])
    improved = meas.get("ok") and new_key < base_key
    row = {"phase": "final", "max": meas.get("max_overflow"), "sum": meas.get("overflow_sum"),
           "hpwl": final_hpwl, "improved": improved}
    history.append(row)
    print(json.dumps(row), flush=True)

    if not improved:
        # restore the pre-evacuation checkpoint and placement
        if rollback_ckpt.exists():
            rc, out, err = run_ieda(workdir, case_root, foundry, config, input_def,
                                    [f"placer_run_gp -mode restore -checkpoint {shlex.quote(str(rollback_ckpt))}",
                                     "placer_run_gp -mode accept"], def_save=True)
            if rc == 0:
                lg_dp(workdir, case_root, foundry, config, input_def)
        shutil.copy2(base_def, workdir / "placement.def")
        row["rolled_back"] = True
    else:
        shutil.copy2(final_def, base_def)

    summary = {"base": {"max": base_key[0], "sum": base_key[1]},
               "final": {"max": new_key[0], "sum": new_key[1], "hpwl": final_hpwl},
               "improved": improved, "history": history}
    print(json.dumps(summary, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
