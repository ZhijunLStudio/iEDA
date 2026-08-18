#!/usr/bin/env python3
"""Generic agent loop on top of the iEDA GP primitives.

The policy is design-agnostic: it observes the same signals on every design,
then chooses a local action with the same rules. No design-name branches.

Policy:
  observe -> restore parent, inspect grid + diagnose hotspots/longnets
  decide  -> hotspot / longnet / region with density and anneal knobs
  act     -> local_restart with the chosen parameters
  verify  -> keep the lower-HPWL result among raw / baseline restart / local
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]


def run_py(script: str, *args, timeout=1800):
    proc = subprocess.run([sys.executable, str(REPO / "benchmarks/flows" / script), *args],
                          cwd=REPO, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=timeout)
    try:
        data = json.loads(proc.stdout) if proc.stdout.strip() else {}
    except Exception:
        data = {"ok": False, "rc": proc.returncode, "raw": proc.stdout[-800:]}
    data.setdefault("_rc", proc.returncode)
    data.setdefault("_err", proc.stderr[-800:])
    return data


def observe(workdir: Path, checkpoint: Path, case_root: Path, input_def: Path,
            config: Path, foundry: Path) -> dict:
    gp_agent = str(REPO / "benchmarks/flows/gp_agent.py")
    base = ["--workdir", str(workdir), "--case-root", str(case_root), "--input-def", str(input_def),
            "--config", str(config), "--foundry-dir", str(foundry)]
    subprocess.run([sys.executable, gp_agent, "restore", *base, "--checkpoint", str(checkpoint)],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, cwd=REPO)
    subprocess.run([sys.executable, gp_agent, "accept", *base, "--checkpoint", str(checkpoint)],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, cwd=REPO)
    grid = run_py("gp_toolbox.py", "grid", "--workdir", str(workdir), "--top-n", "8")
    hot = run_py("gp_toolbox.py", "hotspots", "--workdir", str(workdir), "--top-n", "8")
    long = run_py("gp_toolbox.py", "longnets", "--workdir", str(workdir), "--top-n", "8",
                  "--def-path", str(input_def))
    status = run_py("gp_toolbox.py", "status", "--workdir", str(workdir))
    return {"grid": grid, "hotspots": hot, "longnets": long, "status": status}


def decide_actions(obs: dict) -> list[dict]:
    """Design-agnostic proposal list. The loop tries every proposed action and
    keeps the best result, so the agent does not hard-code one scope per design.
    """
    grid = obs.get("grid") or {}
    hot = obs.get("hotspots") or {}
    long = obs.get("longnets") or {}
    status = obs.get("status") or {}
    bins = grid.get("bins") or []
    hotspots = hot.get("hotspots") or []
    longnets = long.get("longnets") or []
    peak_density = max([float(b.get("density", 0.0)) for b in bins], default=0.0)
    peak_overflow = max([float(h.get("overflow_area", 0)) for h in hotspots], default=0.0)
    hpwl = float((status.get("hpwl") or {}).get("value", 0) or 0)
    top_longnet_hpwl = float((longnets[0] or {}).get("hpwl", 0) if longnets else 0)
    longnet_share = top_longnet_hpwl / hpwl if hpwl > 0 else 0.0

    actions = []
    if longnet_share > 0.01:
        actions.append({"scope": "longnet", "density_target": 1.0, "anneal_ratio": 0.0})
    if hotspots and peak_overflow > 0 and peak_density > 1.05:
        density_target = round(max(0.75, min(0.95, 1.0 - 0.10 * (peak_density - 1.0))), 2)
        actions.append({"scope": "hotspot", "density_target": density_target, "anneal_ratio": 0.25})
    if not actions:
        actions.append({"scope": "region", "density_target": 0.90, "anneal_ratio": 0.25})
    for action in actions:
        action.update({"overflow_penalty": 0.005, "force_local": 1,
                       "reason": {"peak_density": peak_density, "peak_overflow": peak_overflow,
                                  "longnet_share": longnet_share}})
    return actions


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--design", required=True)
    ap.add_argument("--workdir", required=True)
    ap.add_argument("--case-root", required=True)
    ap.add_argument("--input-def", required=True)
    ap.add_argument("--config", required=True)
    ap.add_argument("--foundry-dir", required=True)
    ap.add_argument("--lef", required=True)
    ap.add_argument("--parent-checkpoint", required=True)
    ap.add_argument("--baseline-def", required=True)
    ap.add_argument("--parent-iterations", type=int, default=400)
    ap.add_argument("--max-rounds", type=int, default=2)
    args = ap.parse_args()

    root = Path(args.workdir)
    root.mkdir(parents=True, exist_ok=True)
    current_parent = Path(args.parent_checkpoint)
    best_def = Path(args.baseline_def)
    best_hpwl = None
    rounds = []
    for round_idx in range(args.max_rounds):
        obs_workdir = root / f"observe_{round_idx}"
        obs_workdir.mkdir(parents=True, exist_ok=True)
        obs = observe(obs_workdir, current_parent, Path(args.case_root), Path(args.input_def),
                      Path(args.config), Path(args.foundry_dir))
        decisions = decide_actions(obs)
        action_results = []
        original_baseline_def = Path(args.baseline_def)
        best_round_hpwl = best_hpwl
        best_round_def = original_baseline_def
        best_round_side = "raw"
        for action_idx, decision in enumerate(decisions):
            lr = run_py("gp_local_restart.py",
                        "--design", args.design, "--workdir", str(root / f"local_restart_{round_idx}_{action_idx}"),
                        "--case-root", args.case_root, "--input-def", args.input_def,
                        "--config", args.config, "--foundry-dir", args.foundry_dir, "--lef", args.lef,
                        "--checkpoint", str(current_parent), "--scope", decision["scope"],
                        "--overflow-penalty", str(decision["overflow_penalty"]),
                        "--scope-anneal-ratio", str(decision["anneal_ratio"]),
                        "--scope-density-target", str(decision["density_target"]),
                        "--force-local", "--baseline-def", str(original_baseline_def), timeout=3600)
            if not lr.get("ok"):
                action_results.append({"action": action_idx, "decision": decision, "error": lr})
                continue
            local_hpwl = lr.get("local_restart_hpwl")
            baseline_restart_hpwl = lr.get("baseline_restart_hpwl")
            raw_hpwl = lr.get("raw_gp_hpwl")
            candidates = []
            if local_hpwl is not None:
                candidates.append((local_hpwl, "local_restart", str(Path(lr["local_place"]))))
            if baseline_restart_hpwl is not None:
                candidates.append((baseline_restart_hpwl, "baseline_restart",
                                   str(Path(lr.get("baseline_restart_workdir", "")) / "placement.def")))
            if raw_hpwl is not None:
                candidates.append((raw_hpwl, "raw", str(original_baseline_def)))
            if not candidates:
                action_results.append({"action": action_idx, "decision": decision, "error": "no hpwl"})
                continue
            win_hpwl, win_side, win_def = min(candidates, key=lambda x: x[0])
            action_results.append({"action": action_idx, "decision": decision,
                                   "local_restart_hpwl": local_hpwl,
                                   "baseline_restart_hpwl": baseline_restart_hpwl,
                                   "raw_hpwl": raw_hpwl, "winner": win_side,
                                   "winner_hpwl": win_hpwl})
            if best_round_hpwl is None or win_hpwl < best_round_hpwl:
                best_round_hpwl, best_round_def, best_round_side = win_hpwl, Path(win_def), win_side
                # remember the local restart workdir for the next parent generation
                best_round_restart = Path(lr.get("restart_workdir", ""))
        improved = best_hpwl is not None and best_round_hpwl is not None and best_round_hpwl < best_hpwl - 1
        if best_round_hpwl is not None and (best_hpwl is None or best_round_hpwl < best_hpwl):
            best_hpwl, best_def = best_round_hpwl, best_round_def
        rounds.append({"round": round_idx, "actions": action_results,
                       "winner": best_round_side, "winner_hpwl": best_round_hpwl,
                       "improved_over_previous": improved})
        if best_round_side == "local_restart" and best_round_def is not None:
            next_place = best_round_def
            if next_place.exists():
                parent_dir = root / f"parent_{round_idx + 1}"
                parent_dir.mkdir(parents=True, exist_ok=True)
                subprocess.run([sys.executable, str(REPO / "benchmarks/flows/gp_agent.py"),
                                "start", "--workdir", str(parent_dir), "--case-root", args.case_root,
                                "--input-def", str(next_place), "--config", args.config,
                                "--foundry-dir", args.foundry_dir, "--iterations",
                                str(args.parent_iterations), "--seed", "42", "--random-init", "0",
                                "--report-route-util", "1"],
                               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, cwd=REPO)
                next_cp = parent_dir / "pl/gp_session_checkpoint.json"
                if next_cp.exists():
                    current_parent = next_cp
    out = {"ok": True, "design": args.design, "rounds": rounds,
           "best_hpwl": best_hpwl, "best_def": str(best_def)}
    print(json.dumps(out, indent=2))
    (root / "agent_loop_result.json").write_text(json.dumps(out, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
