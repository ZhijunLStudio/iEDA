#!/usr/bin/env python3
"""Simulated-annealing search over a CONTINUOUS GP parameter.

Used for parameters where neighbor states have similar energy (aniso_y,
congestion_effort, iterations). NOT for seed/bin_cnt (discrete, no local
continuity - use ieda_gp_parallel breadth scan instead; validated by the R51
salsa20_ics55 seed-2011 hit vs. the earlier failure of anneal-style seed walks).

Energy: by default def_hpwl (cheap, per-step DEF-level HPWL); --use-egr makes
energy = egr_max_overflow_union (authoritative congestion, expensive).

Each step runs gp_agent.py plain in its own workdir subdir, keeping the best
placement. Metropolis acceptance: always accept lower energy, accept higher
with exp(-dE/T); T follows T *= cooling each step.
"""
from __future__ import annotations

import argparse
import json
import math
import os
import random
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
PY_EXE = sys.executable or "python3"
GP_AGENT = REPO_ROOT / "benchmarks/flows/gp_agent.py"


def energy_of(workdir: Path, use_egr: bool) -> float | None:
    """Read energy from a workdir: def_hpwl (cheap) or EGR max union (authoritative)."""
    state = workdir / "gp_agent_state.json"
    if not state.exists():
        return None
    st = json.loads(state.read_text())
    if use_egr:
        # EGR needs an explicit run; call the new gp_agent egr command.
        case_root = Path(st["case_root"])
        foundry = Path(st["foundry_dir"])
        p = subprocess.run(
            [PY_EXE, str(GP_AGENT), "egr", "--workdir", str(workdir),
             "--case-root", str(case_root), "--foundry-dir", str(foundry)],
            cwd=REPO_ROOT, capture_output=True, text=True, timeout=3600)
        try:
            out = json.loads(p.stdout.strip())
            if out.get("ok") and out.get("egr_valid"):
                return float(out.get("egr_max_overflow_union"))
        except Exception:
            pass
        return None
    hpwl = st.get("best_def_hpwl") or st.get("def_hpwl")
    return float(hpwl) if hpwl is not None else None


def run_one(args, value: float, tag: str) -> tuple[Path, dict]:
    """Run one plain candidate with the continuous param pinned to value."""
    wd = Path(args.workdir) / f"anneal_{tag}"
    if wd.exists():
        import shutil
        shutil.rmtree(wd, ignore_errors=True)
    env = os.environ.copy()
    if args.param == "aniso_y":
        env["DENSITY_ANISO_Y"] = f"{value:.3f}"
    argv = [PY_EXE, str(GP_AGENT), "plain",
            "--workdir", str(wd),
            "--case-root", str(args.case_root),
            "--input-def", str(args.input_def),
            "--config", str(args.config),
            "--foundry-dir", str(args.foundry_dir),
            "--random-init", str(args.random_init),
            "--seed", str(args.seed),
            "--bin-cnt", str(args.bin_cnt)]
    if args.param == "iterations":
        argv += ["--iterations", str(int(value))]
    if args.param == "congestion_effort":
        argv += ["--congestion-effort", str(int(value))]
    if args.lef:
        argv += ["--lef", str(args.lef)]
    p = subprocess.run(argv, cwd=REPO_ROOT, capture_output=True, text=True, timeout=3600)
    try:
        rec = json.loads(p.stdout.strip())
    except Exception:
        rec = {"ok": False, "stderr_tail": (p.stderr or "")[-2000:]}
    return wd, rec


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--param", required=True, choices=["aniso_y", "congestion_effort", "iterations"])
    ap.add_argument("--lo", type=float, required=True)
    ap.add_argument("--hi", type=float, required=True)
    ap.add_argument("--t0", type=float, default=1.0, help="initial temperature (same unit as energy)")
    ap.add_argument("--cooling", type=float, default=0.8, help="T *= cooling each step")
    ap.add_argument("--steps", type=int, default=10)
    ap.add_argument("--seed", type=int, default=1000)
    ap.add_argument("--random-init", type=int, default=1)
    ap.add_argument("--bin-cnt", type=int, default=-1)
    ap.add_argument("--use-egr", action="store_true")
    ap.add_argument("--workdir", required=True)
    ap.add_argument("--case-root", required=True)
    ap.add_argument("--input-def", required=True)
    ap.add_argument("--config", required=True)
    ap.add_argument("--foundry-dir", required=True)
    ap.add_argument("--lef", default="")
    args = ap.parse_args()

    rng = random.Random(args.seed)
    cur = rng.uniform(args.lo, args.hi)
    wd0, rec0 = run_one(args, cur, "init")
    cur_e = energy_of(wd0, args.use_egr)
    best = {"value": cur, "energy": cur_e, "workdir": str(wd0)}
    T = args.t0
    traj = [{"step": 0, "value": cur, "energy": cur_e, "accepted": True, "T": T, "workdir": str(wd0)}]
    for step in range(1, args.steps + 1):
        cand = cur + rng.uniform(-1.0, 1.0) * (args.hi - args.lo) * 0.2
        cand = min(args.hi, max(args.lo, cand))
        wd, rec = run_one(args, cand, f"s{step}")
        cand_e = energy_of(wd, args.use_egr)
        accepted = False
        if cand_e is not None and (cur_e is None or cand_e <= cur_e):
            accepted = True
        elif cand_e is not None and cur_e is not None and T > 0:
            accepted = rng.random() < math.exp(-(cand_e - cur_e) / max(T, 1e-9))
        if accepted:
            cur, cur_e = cand, cand_e
        if cand_e is not None and (best["energy"] is None or cand_e < best["energy"]):
            best = {"value": cand, "energy": cand_e, "workdir": str(wd)}
        traj.append({"step": step, "value": cand, "energy": cand_e, "accepted": accepted,
                     "T": T, "workdir": str(wd)})
        T *= args.cooling
    print(json.dumps({"ok": True, "param": args.param, "use_egr": args.use_egr,
                      "best": best, "trajectory": traj}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
