#!/usr/bin/env python3
"""Autonomous local-GP search on top of the iEDA GP session tool.

For each requested parent iteration this script:
  1. creates a deterministic parent checkpoint (one fresh random start),
  2. derives a region seed from that parent's hottest overflow bin,
  3. runs one fresh iEDA process where every local/global candidate pair is
     branched from the SAME parent checkpoint,
  4. copies both child checkpoints and the parent grid report as evidence,
  5. writes results/search.json with a recommendation.

Usage:
  python3 benchmarks/flows/run_gp_agent_search.py \
      --design s1238 --case-root ... --input-def ... --config ... \
      --parents 20 60 100 200 400
"""
from __future__ import annotations

import argparse
import json
import re
import shlex
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "benchmarks/flows"))
from gp_agent import REPO_ROOT, PLV_CASES_ROOT, write_tcl, run_ieda  # noqa: E402


def parse_candidate_lines(stdout: str):
    rows = []
    cur_tag = None
    for line in stdout.splitlines():
        if line.startswith("CAND_BEGIN "):
            cur_tag = line.split()[1]
            continue
        if line.startswith("CAND_END "):
            cur_tag = None
            continue
        m = re.search(r"iPL gp\.run \(candidate, (\d+) iterations\).*?stop_reason=(\S+).*?iterations=(\d+)-(\d+) "
                      r"hpwl=(\d+) overflow=([0-9.e+-]+).*?route_util=([0-9.e+-]+)", line)
        if m and cur_tag:
            rows.append({
                "tag": cur_tag,
                "requested": int(m.group(1)),
                "stop_reason": m.group(2),
                "start_iter": int(m.group(3)),
                "end_iter": int(m.group(4)),
                "winner_hpwl": int(m.group(5)),
                "winner_overflow": float(m.group(6)),
                "winner_route_util": float(m.group(7)),
            })
        vm = re.search(r"candidate_verdict=(\S+).*?local=(\S+)\s+global=(\S+)", line)
        if vm and rows and "candidate_verdict" not in rows[-1]:
            rows[-1]["candidate_verdict"] = vm.group(1)
            rows[-1]["local_checkpoint"] = vm.group(2)
            rows[-1]["global_checkpoint"] = vm.group(3)
    return rows


def checkpoint_metrics(path: str):
    data = json.loads(Path(path).read_text())
    return {
        "iter": data.get("current_iter"),
        "hpwl": int(data.get("prev_hpwl", 0)),
        "overflow": float(data.get("sum_overflow", 0.0)),
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--design", required=True)
    ap.add_argument("--case-root")
    ap.add_argument("--input-def")
    ap.add_argument("--config")
    ap.add_argument("--workdir", default="/tmp/gp_agent_search")
    ap.add_argument("--parents", nargs="+", type=int, default=[20, 60, 100, 200, 400])
    ap.add_argument("--budget", type=int, default=20)
    ap.add_argument("--seed", type=int, default=42)
    ap.add_argument("--scopes", nargs="+", default=["longnet", "hotspot", "random", "region"])
    ap.add_argument("--penalties", nargs="+", type=float, default=[0.0, 2.0, 5.0])
    ap.add_argument("--active-count", type=int, default=100)
    ap.add_argument("--hotspot-ratio", type=float, default=0.2)
    ap.add_argument("--halo-hops", type=int, default=2)
    ap.add_argument("--halo-coeff", type=float, default=0.5)
    ap.add_argument("--congestion", type=int, default=0, help="start parents with congestion effort enabled")
    args = ap.parse_args()

    case_root = Path(args.case_root or f"{PLV_CASES_ROOT}/{args.design}")
    input_def = Path(args.input_def or f"{REPO_ROOT}/benchmarks/results/innovus_gp_compare/{args.design}/ieda_in_unplaced.def")
    config = Path(args.config or f"{REPO_ROOT}/benchmarks/results/innovus_gp_compare/{args.design}/pl_clean_config.json")
    foundry = REPO_ROOT / "scripts/foundry/sky130"
    workdir = Path(args.workdir) / args.design
    workdir.mkdir(parents=True, exist_ok=True)

    # ---------- 1. parent checkpoints ----------
    parent_cmds = []
    congestion_flag = " -congestion_effort 1" if args.congestion else ""
    for p in args.parents:
        parent_cmds.append(f"placer_run_gp -mode start -iterations {p} -seed {args.seed}{congestion_flag} -report_route_util 1")
        parent_cmds.append(f"file copy -force {shlex.quote(str(workdir / 'pl/gp_session_checkpoint.json'))} "
                           f"{shlex.quote(str(workdir / f'parent_{p}.json'))}")
        parent_cmds.append(f"file copy -force {shlex.quote(str(workdir / 'pl/gp_grid_report.json'))} "
                           f"{shlex.quote(str(workdir / f'parent_{p}_grid.json'))}")
        parent_cmds.append("placer_run_gp -mode close")
    rc, out, err = run_ieda(workdir, case_root, foundry, config, input_def, parent_cmds)
    if rc != 0:
        print(json.dumps({"ok": False, "stage": "parents", "rc": rc, "stderr_tail": err[-2000:]}))
        return 1

    regions = {}
    for p in args.parents:
        grid_path = workdir / f"parent_{p}_grid.json"
        try:
            grid = json.loads(grid_path.read_text())
            if grid.get("bins"):
                b = grid["bins"][0]
                regions[p] = f"{b['ll_x']} {b['ll_y']} {b['ur_x']} {b['ur_y']}"
            else:
                regions[p] = ""
        except Exception:
            regions[p] = ""

    # ---------- 2. candidate matrix from each parent ----------
    cmds = []
    for p in args.parents:
        parent_path = workdir / f"parent_{p}.json"
        cmds.append(f"puts \"CAND_PARENT {p}\"")
        for scope in args.scopes:
            scope_cmd = ["-scope", scope]
            if scope == "hotspot":
                scope_cmd += ["-scope_active_ratio", str(args.hotspot_ratio)]
            if scope in ("random", "longnet"):
                scope_cmd += ["-scope_active_count", str(args.active_count)]
            if scope == "region":
                region = regions.get(p, "")
                if region:
                    scope_cmd += ["-scope_region", "{" + region + "}"]
            scope_cmd += ["-scope_halo_coeff", str(args.halo_coeff), "-scope_halo_hops", str(args.halo_hops)]
            for penalty in args.penalties:
                tag = f"p{p}_{scope}_{penalty}"
                cmds.append(f"puts \"CAND_BEGIN {tag}\"")
                cmds.append(f"placer_run_gp -mode restore -checkpoint {shlex.quote(str(parent_path))}")
                cmds.append(f"placer_run_gp -mode candidate -iterations {args.budget} "
                            + " ".join(scope_cmd) + f" -candidate_overflow_penalty {penalty}")
                cmds.append(f"catch {{file copy -force {shlex.quote(str(workdir / 'pl/gp_candidate_local.json'))} "
                            f"{shlex.quote(str(workdir / f'{tag}_local.json'))}}}")
                cmds.append(f"catch {{file copy -force {shlex.quote(str(workdir / 'pl/gp_candidate_global.json'))} "
                            f"{shlex.quote(str(workdir / f'{tag}_global.json'))}}}")
                cmds.append("placer_run_gp -mode close")
                cmds.append(f"puts \"CAND_END {tag}\"")
    rc, out, err = run_ieda(workdir, case_root, foundry, config, input_def, cmds)
    if rc != 0:
        print(json.dumps({"ok": False, "stage": "candidates", "rc": rc, "stderr_tail": err[-2000:]}))
        return 1

    rows = parse_candidate_lines(out)
    # Attach child checkpoint metrics.
    for row in rows:
        local = workdir / f"{row['tag']}_local.json"
        global_cp = workdir / f"{row['tag']}_global.json"
        row["local"] = checkpoint_metrics(str(local)) if local.exists() else None
        row["global"] = checkpoint_metrics(str(global_cp)) if global_cp.exists() else None
    parents = {}
    for p in args.parents:
        cp = workdir / f"parent_{p}.json"
        parents[p] = checkpoint_metrics(str(cp)) if cp.exists() else None

    target = None
    with open(config) as f:
        cfg = json.load(f)
        target = float(cfg["PL"]["GP"]["Nesterov"].get("target_overflow", 0.1))

    # ---------- 3. recommendation ----------
    def winner_for(row: dict):
        # Candidate mode restores the local checkpoint only on left_better;
        # for right_better / incomparable / equal it keeps the global control.
        if row.get("candidate_verdict") == "left_better":
            return row.get("local"), "local"
        return row.get("global") or row.get("local"), "global"

    best = None
    for row in rows:
        m, side = winner_for(row)
        if m is None:
            continue
        feasible = m["overflow"] <= target + 1e-5
        # Lexicographic objective:
        #   1) feasible beats infeasible,
        #   2) feasible rows compare by HPWL,
        #   3) if nothing is feasible yet, get as close to the overflow
        #      target as possible (lower overflow first, HPWL as tie-break).
        better = False
        if best is None:
            better = True
        elif feasible != best["feasible"]:
            better = feasible
        elif feasible:
            better = m["hpwl"] < best["hpwl"]
        else:
            better = (m["overflow"] < best["overflow"]
                      or (m["overflow"] == best["overflow"] and m["hpwl"] < best["hpwl"]))
        if better:
            best = {"tag": row["tag"], "verdict": row.get("candidate_verdict", "terminal"),
                    "winner_side": side, "hpwl": m["hpwl"], "overflow": m["overflow"],
                    "feasible": feasible, "local": row.get("local"), "global": row.get("global"),
                    "parent": parents.get(int(row["tag"].split("_")[0][1:]))}
    result = {"ok": True, "design": args.design, "workdir": str(workdir), "parents": parents,
              "candidates": rows, "recommendation": best, "target_overflow": target}
    (workdir / "search.json").write_text(json.dumps(result, indent=2))
    print(json.dumps({"ok": True, "design": args.design, "workdir": str(workdir),
                      "num_candidates": len(rows), "recommendation": best,
                      "result": str(workdir / "search.json")}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
