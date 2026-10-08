#!/usr/bin/env python3
"""EGR hotnet evacuation: the trial-route -> GP feedback loop, done properly.

Instead of evacuating the CELLS INSIDE a hot bin (which barely moves 4-5 cells),
this maps each hot bin back to the NETS that route through it (route_planar.guide),
collects the movable instances that DRIVE those nets, and runs a scope=instances
GP advance with a lowered density screen to pull those drivers out of the hotspot.

Loop (per round):
  hotnets(top-1 bin) -> local_run(scope=instances, screen, iters) -> LG -> DP
  -> re-measure EGR; keep when (max,sum) improves, else restore the checkpoint.

Stops when max_overflow <= --target-max or no round improves.
"""
from __future__ import annotations
import argparse, json, shlex, shutil, subprocess, sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / "benchmarks/flows"))

from gp_agent import def_hpwl_of, run_ieda  # noqa: E402
from gp_egr_hotnets import hotnets  # noqa: E402
from gp_egr_hotspots import hotspots  # noqa: E402


def local_inst(workdir, case_root, foundry, config, input_def, lef, insts, screen, iters):
    cmd = [sys.executable, str(REPO / "benchmarks/flows/gp_agent.py"), "local_run",
           "--workdir", str(workdir), "--case-root", str(case_root),
           "--input-def", str(input_def), "--config", str(config),
           "--foundry-dir", str(foundry), "--lef", str(lef),
           "--scope", "instances", "--scope-instances", ",".join(insts),
           "--scope-density-target", str(screen), "--iterations", str(iters)]
    p = subprocess.run(cmd, cwd=REPO, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=1800)
    try:
        payload = json.loads(p.stdout.strip())
    except Exception:
        payload = {"ok": False}
    return p.returncode == 0 and bool(payload.get("ok")), payload


def lgdp(workdir, case_root, foundry, config, input_def):
    rc, _, _ = run_ieda(workdir, case_root, foundry, config, workdir / "placement.def",
                        ["placer_run_lg", "placer_run_dp"], def_save=True)
    return rc == 0


def rollback(workdir, case_root, foundry, config, input_def):
    ckpt = workdir / "pl/iter_ckpt.json"
    if not ckpt.exists():
        return False
    rc, _, _ = run_ieda(workdir, case_root, foundry, config, input_def,
                        [f"placer_run_gp -mode restore -checkpoint {shlex.quote(str(ckpt))}",
                         "placer_run_gp -mode accept"], def_save=True)
    if rc != 0:
        return False
    return lgdp(workdir, case_root, foundry, config, input_def)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--case-root", required=True)
    ap.add_argument("--foundry-dir", required=True)
    ap.add_argument("--lef", required=True)
    ap.add_argument("--input-def", required=True)
    ap.add_argument("--config", required=True)
    ap.add_argument("--workdir", required=True)
    ap.add_argument("--target-max", type=float, default=30)
    ap.add_argument("--top-n", type=int, default=2)
    ap.add_argument("--screen", type=float, default=0.55)
    ap.add_argument("--iterations", type=int, default=30)
    ap.add_argument("--rounds", type=int, default=6)
    args = ap.parse_args()

    workdir = Path(args.workdir)
    case_root = Path(args.case_root); foundry = Path(args.foundry_dir)
    config = Path(args.config); input_def = Path(args.input_def); lef = Path(args.lef)
    if not (workdir / "placement.def").exists():
        print(json.dumps({"ok": False, "reason": "no placement.def; run plain first"}))
        return 1
    if not (workdir / "pl/gp_session_checkpoint.json").exists():
        print(json.dumps({"ok": False, "reason": "no gp_session_checkpoint.json; run plain (session mode) first"}))
        return 1

    measure_dir = workdir / "egr_measure"
    base = hotspots(case_root, foundry, workdir / "placement.def", measure_dir, top_n=9999)
    if not base.get("ok"):
        print(json.dumps({"ok": False, "base": base}))
        return 1
    best = {"max": base["max_overflow"], "sum": base["overflow_sum"],
            "hpwl": def_hpwl_of(workdir / "placement.def", lef)}
    history = [{"phase": "base", **best}]
    print(json.dumps(history[-1]), flush=True)

    # Accumulate hotnet drivers across the top-N bins (a single top-1 bin can
    # have zero movable drivers — e.g. only macro/IO pins route through it —
    # which must not stop the loop). Iterate bins until we have some drivers.
    for rnd in range(args.rounds):
        hn = hotnets(case_root, foundry, workdir / "placement.def", workdir / "hotnets", top_n=args.top_n)
        insts = hn.get("instances", [])
        if not insts:
            # widen progressively instead of stopping
            for n in (args.top_n * 2, args.top_n * 4, args.top_n * 8):
                hn = hotnets(case_root, foundry, workdir / "placement.def", workdir / "hotnets", top_n=n)
                insts = hn.get("instances", [])
                if insts:
                    break
        if not insts:
            break
        shutil.copy2(workdir / "pl/gp_session_checkpoint.json", workdir / "pl/iter_ckpt.json")
        ok, payload = local_inst(workdir, case_root, foundry, config, input_def, lef, insts,
                                args.screen, args.iterations)
        if not ok or not lgdp(workdir, case_root, foundry, config, input_def):
            history.append({"phase": f"r{rnd}", "ok": False, **payload})
            break
        meas = hotspots(case_root, foundry, workdir / "placement.def", measure_dir, top_n=9999)
        key = (meas.get("max_overflow", 1e9), meas.get("overflow_sum", 1e18))
        hpwl = def_hpwl_of(workdir / "placement.def", lef)
        row = {"phase": f"r{rnd}", "max": meas.get("max_overflow"),
               "sum": meas.get("overflow_sum"), "hpwl": hpwl, "n_inst": len(insts)}
        if meas.get("ok") and key < (best["max"], best["sum"]):
            best = {"max": key[0], "sum": key[1], "hpwl": hpwl}
            row["kept"] = True
        else:
            row["kept"] = False
            rollback(workdir, case_root, foundry, config, input_def)
        history.append(row)
        print(json.dumps(row), flush=True)
        if best["max"] <= args.target_max:
            break

    summary = {"ok": True, "best": best, "history": history}
    print(json.dumps(summary, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
