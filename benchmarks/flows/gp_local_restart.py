#!/usr/bin/env python3
"""Local-perturb + relinearize strategy for the iEDA GP agent.

1. fork one local/global candidate pair from a parent checkpoint;
2. accept the local branch (or global when forced fallback);
3. start a fresh random_init=0 global GP from the accepted placement;
4. also re-start from the raw-GP converged DEF as the same-budget baseline;
5. evaluate both DEFs with def_hpwl_eval and return the comparison.
"""
from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "benchmarks/flows"))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--design", required=True)
    ap.add_argument("--workdir", required=True)
    ap.add_argument("--case-root")
    ap.add_argument("--input-def")
    ap.add_argument("--config")
    ap.add_argument("--lef")
    ap.add_argument("--foundry-dir")
    ap.add_argument("--checkpoint")
    ap.add_argument("--scope", default="longnet",
                    choices=["longnet", "hotspot", "random", "region", "instances"])
    ap.add_argument("--scope-active-count", type=int, default=100)
    ap.add_argument("--scope-active-ratio", type=float, default=0.2)
    ap.add_argument("--scope-region", default="")
    ap.add_argument("--scope-instances", default="")
    ap.add_argument("--halo-hops", type=int, default=2)
    ap.add_argument("--halo-coeff", type=float, default=0.5)
    ap.add_argument("--overflow-penalty", type=float, default=0.005)
    ap.add_argument("--scope-anneal-ratio", type=float, default=0.0)
    ap.add_argument("--scope-density-target", type=float, default=1.0)
    ap.add_argument("--candidate-iterations", type=int, default=20)
    ap.add_argument("--restart-iterations", type=int, default=600)
    ap.add_argument("--seed", type=int, default=42)
    ap.add_argument("--force-local", action="store_true",
                    help="restart from the local child even when the candidate verdict is not left_better")
    ap.add_argument("--baseline-def", default="")
    ap.add_argument("--python", default=sys.executable)
    args = ap.parse_args()

    repo = Path(__file__).resolve().parents[2]
    design = args.design
    case_root = Path(args.case_root or f"/home/lizhijun/work/iEDA/docs/ipl/pl_vis/cases/{design}")
    input_def = Path(args.input_def or f"{repo}/benchmarks/results/innovus_gp_compare/{design}/ieda_in_unplaced.def")
    config = Path(args.config or f"{repo}/benchmarks/results/innovus_gp_compare/{design}/pl_clean_config.json")
    lef = Path(args.lef or f"{repo}/scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef")
    foundry = Path(args.foundry_dir or f"{repo}/scripts/foundry/sky130")
    parent = Path(args.checkpoint or f"/tmp/gp_agent_search/{design}/parent_400.json")
    root = Path(args.workdir)
    # Do NOT wipe the whole workdir: it may contain the parent checkpoint or
    # other session artifacts the caller still needs. Only clear our own
    # run subdirectories.
    root.mkdir(parents=True, exist_ok=True)
    for sub in ("candidate", "accepted", "local_restart", "baseline_restart"):
        shutil.rmtree(root / sub, ignore_errors=True)

    def run(*argv):
        proc = subprocess.run([args.python, str(repo / "benchmarks/flows/gp_agent.py"), *argv],
                              cwd=repo, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
        try:
            return json.loads(proc.stdout) if proc.stdout.strip() else {"ok": False, "rc": proc.returncode}
        except Exception:
            return {"ok": False, "rc": proc.returncode, "raw": proc.stdout[-400:]}

    def hpwl(path: Path):
        if not path.exists():
            return None
        proc = subprocess.run([args.python, str(repo / "benchmarks/flows/def_hpwl_eval.py"), str(lef), str(path)],
                              cwd=repo, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
        m = re.search(r"HPWL=(\d+)", proc.stdout)
        return int(m.group(1)) if m else None

    scope_args = ["--scope", args.scope]
    if args.scope in ("longnet", "random"):
        scope_args += ["--scope-active-count", str(args.scope_active_count)]
    if args.scope == "hotspot":
        scope_args += ["--scope-active-ratio", str(args.scope_active_ratio)]
    if args.scope == "region" and args.scope_region:
        scope_args += ["--scope-region", args.scope_region]
    if args.scope == "instances" and args.scope_instances:
        scope_args += ["--scope-instances", args.scope_instances]

    parent_acc_dir = root / "parent_accepted"
    parent_acc_dir.mkdir(parents=True, exist_ok=True)
    run("restore", "--workdir", str(parent_acc_dir), "--case-root", str(case_root),
        "--input-def", str(input_def), "--config", str(config), "--foundry-dir", str(foundry),
        "--checkpoint", str(parent))
    run("accept", "--workdir", str(parent_acc_dir), "--case-root", str(case_root),
        "--input-def", str(input_def), "--config", str(config), "--foundry-dir", str(foundry),
        "--checkpoint", str(parent))
    parent_def_hpwl = hpwl(parent_acc_dir / "placement.def") if (parent_acc_dir / "placement.def").exists() else None
    parent_state_path = parent_acc_dir / "gp_agent_state.json"
    parent_def_overflow = None
    if parent_state_path.exists():
        try:
            parent_def_overflow = float(json.loads(parent_state_path.read_text()).get("last_overflow", 1.0))
        except Exception:
            parent_def_overflow = None
    parent_feasible = parent_def_overflow is not None and parent_def_overflow <= 0.12

    cand_dir = root / "candidate"
    cand_dir.mkdir()
    candidate = run("candidate", "--workdir", str(cand_dir), "--case-root", str(case_root),
                    "--input-def", str(input_def), "--config", str(config), "--foundry-dir", str(foundry),
                    "--checkpoint", str(parent),
                    "--iterations", str(args.candidate_iterations), *scope_args,
                    "--halo-hops", str(args.halo_hops), "--halo-coeff", str(args.halo_coeff),
                    "--overflow-penalty", str(args.overflow_penalty),
                    "--scope-anneal-ratio", str(args.scope_anneal_ratio),
                    "--scope-density-target", str(args.scope_density_target))
    if not candidate.get("ok") or not candidate.get("candidate"):
        return json.dumps({"ok": False, "stage": "candidate", "candidate": candidate}, indent=2)

    cand = candidate["candidate"]
    verdict = cand.get("candidate_verdict")
    local_cp = cand.get("candidate_local_checkpoint")
    global_cp = cand.get("candidate_global_checkpoint")
    chosen = local_cp if (verdict == "left_better" or args.force_local) else global_cp
    if not chosen or not Path(chosen).exists():
        chosen = global_cp or local_cp or str(parent)

    acc_dir = root / "accepted"
    acc_dir.mkdir()
    run("restore", "--workdir", str(acc_dir), "--case-root", str(case_root),
        "--input-def", str(input_def), "--config", str(config), "--foundry-dir", str(foundry), "--checkpoint", str(chosen))
    run("accept", "--workdir", str(acc_dir), "--case-root", str(case_root),
        "--input-def", str(input_def), "--config", str(config), "--foundry-dir", str(foundry), "--checkpoint", str(chosen))
    local_place = acc_dir / "placement.def"
    if not local_place.exists():
        return json.dumps({"ok": False, "stage": "accept", "chosen": chosen}, indent=2)

    restart_dir = root / "local_restart"
    restart_dir.mkdir()
    restart_input = local_place
    restart_state = {}
    for _attempt in range(3):
        run("start", "--workdir", str(restart_dir), "--case-root", str(case_root),
            "--input-def", str(restart_input), "--config", str(config), "--foundry-dir", str(foundry), "--iterations", str(args.restart_iterations),
            "--seed", str(args.seed), "--random-init", "0", "--report-route-util", "1")
        state_path = restart_dir / "gp_agent_state.json"
        if state_path.exists():
            restart_state = json.loads(state_path.read_text())
        overflow = float(restart_state.get("last_overflow", 1.0))
        if overflow <= 0.12:
            break
        next_place = restart_dir / "placement.def"
        if next_place.exists():
            restart_input = next_place
        else:
            break

    baseline_def = Path(args.baseline_def) if args.baseline_def else Path(f"/tmp/p0_converged/{design}/placement.def")
    baseline_restart_hpwl = None
    baseline_restart_dir = None
    if baseline_def.exists():
        baseline_restart_dir = root / "baseline_restart"
        baseline_restart_dir.mkdir()
        run("start", "--workdir", str(baseline_restart_dir), "--case-root", str(case_root),
            "--input-def", str(baseline_def), "--config", str(config), "--foundry-dir", str(foundry), "--iterations", str(args.restart_iterations),
            "--seed", str(args.seed), "--random-init", "0", "--report-route-util", "1")
        baseline_restart_hpwl = hpwl(baseline_restart_dir / "placement.def")

    local_restart_hpwl = hpwl(restart_dir / "placement.def")
    local_restart_overflow = float(restart_state.get("last_overflow", 1.0))
    local_restart_route_util = float(restart_state.get("last_route_util", 0.0))
    local_restart_feasible = local_restart_overflow <= 0.12
    raw_hpwl = hpwl(baseline_def)
    candidates = [(raw_hpwl, "raw_gp")] if raw_hpwl is not None else []
    if local_restart_hpwl is not None and local_restart_feasible:
        candidates.append((local_restart_hpwl, "local_restart"))
    if baseline_restart_hpwl is not None:
        candidates.append((baseline_restart_hpwl, "baseline_restart"))
    recommended_hpwl, recommended_side = min(candidates) if candidates else (None, "unknown")
    result = {
        "ok": True,
        "design": design,
        "candidate_verdict": verdict,
        "accepted_branch": "local" if chosen == local_cp else ("global" if chosen == global_cp else "parent"),
        "accepted_checkpoint": chosen,
        "local_restart_hpwl": local_restart_hpwl,
        "local_restart_hpwl_unit": "def",
        "parent_def_hpwl": parent_def_hpwl,
        "parent_def_hpwl_unit": "def",
        "parent_def_overflow": parent_def_overflow,
        "parent_feasible": parent_feasible,
        "local_restart_overflow": local_restart_overflow,
        "local_restart_route_util": local_restart_route_util,
        "local_restart_feasible": local_restart_feasible,
        "baseline_def": str(baseline_def),
        "raw_gp_hpwl": raw_hpwl,
        "raw_gp_hpwl_unit": "def",
        "baseline_restart_hpwl": baseline_restart_hpwl,
        "recommended_side": recommended_side,
        "recommended_hpwl": recommended_hpwl,
        "local_place": str(local_place),
        "restart_workdir": str(restart_dir),
        "baseline_restart_workdir": str(baseline_restart_dir),
    }
    (root / "result.json").write_text(json.dumps(result, indent=2))
    return json.dumps(result, indent=2)


if __name__ == "__main__":
    print(main())
