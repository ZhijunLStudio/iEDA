#!/usr/bin/env python3
"""Minimal JSON Agent CLI for the iEDA GP session tool.

Every action is one fresh iEDA process (checkpoint-per-call). The process
publishes an append-only experiment ledger; this CLI reads the last ledger
record and returns a small JSON object, so Claude Code can drive GP with a
regular Bash tool call.

Examples:
  python3 benchmarks/flows/gp_agent.py start \
      --case-root docs/ipl/pl_vis/cases/s1238 \
      --input-def results/innovus_gp_compare/s1238/ieda_in_unplaced.def \
      --config results/innovus_gp_compare/s1238/pl_clean_config.json \
      --workdir /tmp/gp_agent_s1238 --iterations 60 --seed 42

  python3 benchmarks/flows/gp_agent.py candidate \
      --workdir /tmp/gp_agent_s1238 --iterations 20 \
      --scope hotspot --scope-active-ratio 0.2 --halo-hops 2

  python3 benchmarks/flows/gp_agent.py accept --workdir /tmp/gp_agent_s1238
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

REPO_ROOT = Path(__file__).resolve().parents[2]
IEDa_BIN = Path(os.environ.get("IEDA_BIN", REPO_ROOT / "build/bin/iEDA"))
PLV_CASES_ROOT = Path(os.environ.get("PLV_CASES_ROOT", "/home/lizhijun/work/iEDA/docs/ipl/pl_vis/cases"))


def parse_bool(value: str | bool) -> bool:
    if isinstance(value, bool):
        return value
    return value.lower() in ("1", "true", "yes", "on")


def write_tcl(workdir: Path, case_root: Path, foundry_dir: Path, config: Path, input_def: Path, commands: list[str],
              def_save: bool = False) -> Path:
    workdir.mkdir(parents=True, exist_ok=True)
    tcl = workdir / "gp_agent.tcl"
    tcl.write_text(
        f"""flow_init -config {shlex.quote(str(case_root / 'iEDA_config/flow_config.json'))}\n"""
        f"""db_init -config {shlex.quote(str(case_root / 'iEDA_config/db_default_config.json'))} -output_dir_path {shlex.quote(str(workdir))}\n"""
        f"""source {shlex.quote(str(case_root / 'script/DB_script/db_path_setting.tcl'))}\n"""
        f"""source {shlex.quote(str(case_root / 'script/DB_script/db_init_lef.tcl'))}\n"""
        f"""def_init -path {shlex.quote(str(input_def))}\n"""
        f"""init_pl -config {shlex.quote(str(config))}\n"""
        + "\n".join(commands)
        + ("\n" if commands else "")
        + (f"def_save -path {shlex.quote(str(workdir / 'placement.def'))}\n" if def_save else "")
        + "flow_exit\n"
    )
    return tcl


def run_ieda(workdir: Path, case_root: Path, foundry_dir: Path, config: Path, input_def: Path,
             commands: list[str], def_save: bool = False) -> tuple[int, str, str]:
    tcl = write_tcl(workdir, case_root, foundry_dir, config, input_def, commands, def_save)
    env = os.environ.copy()
    env.update({
        "CONFIG_DIR": str(case_root / "iEDA_config"),
        "RESULT_DIR": str(workdir),
        "TCL_SCRIPT_DIR": str(case_root / "script"),
        "FOUNDRY_DIR": str(foundry_dir),
        "SDC_FILE": str(case_root / f"{case_root.name}.sdc"),
    })
    proc = subprocess.run([str(IEDa_BIN), "-script", str(tcl)], cwd=REPO_ROOT, env=env,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=1800)
    return proc.returncode, proc.stdout, proc.stderr


def last_ledger(workdir: Path) -> dict:
    path = workdir / "pl/gp_experiments.jsonl"
    if not path.exists():
        return {}
    lines = [ln for ln in path.read_text(errors="ignore").splitlines() if ln.strip()]
    return json.loads(lines[-1]) if lines else {}


def update_state(workdir: Path, extra: dict | None = None) -> dict:
    state_path = workdir / "gp_agent_state.json"
    state = {}
    if state_path.exists():
        try:
            state = json.loads(state_path.read_text())
        except Exception:
            state = {}
    record = last_ledger(workdir)
    state.update({
        "workdir": str(workdir),
        "last_mode": record.get("mode"),
        "last_stop_reason": record.get("stop_reason"),
        "last_iteration": record.get("end_iteration"),
        "last_hpwl": record.get("hpwl"),
        "last_overflow": record.get("overflow"),
        "last_route_util": record.get("route_util"),
    })
    if record.get("checkpoint"):
        state["latest_checkpoint"] = record["checkpoint"]
    if extra:
        state.update(extra)
    state_path.write_text(json.dumps(state, indent=2))
    return state


def scope_args(args: argparse.Namespace) -> list[str]:
    out = ["-scope", args.scope]
    if args.scope in ("hotspot",):
        out += ["-scope_active_ratio", str(args.scope_active_ratio)]
    if args.scope in ("random", "longnet"):
        out += ["-scope_active_count", str(args.scope_active_count)]
    if args.scope == "instances":
        out += ["-scope_instances", args.scope_instances]
    if args.scope == "region":
        if args.scope_region:
            out += ["-scope_region", "{" + args.scope_region + "}"]
    out += ["-scope_halo_coeff", str(args.halo_coeff), "-scope_halo_hops", str(args.halo_hops)]
    out += ["-scope_density_target", str(args.scope_density_target),
            "-scope_density_ratio", str(args.scope_density_ratio)]
    return out


def common_arg_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser()
    p.add_argument("--workdir", required=True)
    p.add_argument("--case-root")
    p.add_argument("--input-def")
    p.add_argument("--config")
    p.add_argument("--foundry-dir", default=str(REPO_ROOT / "scripts/foundry/sky130"))
    p.add_argument("--iterations", type=int, default=20)
    p.add_argument("--seed", type=int, default=1000)
    p.add_argument("--checkpoint")
    p.add_argument("--scope", choices=["global", "hotspot", "random", "instances", "region", "longnet"], default="global")
    p.add_argument("--scope-active-ratio", type=float, default=0.2)
    p.add_argument("--scope-active-count", type=int, default=100)
    p.add_argument("--scope-instances", default="")
    p.add_argument("--scope-region", default="")
    p.add_argument("--halo-coeff", type=float, default=0.5)
    p.add_argument("--halo-hops", type=int, default=2)
    p.add_argument("--target-density", type=float, default=-1.0)
    p.add_argument("--congestion-effort", type=int, default=-1)
    p.add_argument("--report-route-util", type=int, default=1)
    return p


def load_workdir_context(args: argparse.Namespace) -> tuple[Path, Path, Path, Path, Path]:
    workdir = Path(args.workdir)
    state_path = workdir / "gp_agent_state.json"
    state = json.loads(state_path.read_text()) if state_path.exists() else {}
    case_root = Path(args.case_root or state.get("case_root"))
    input_def = Path(args.input_def or state.get("input_def"))
    config = Path(args.config or state.get("config"))
    foundry = Path(args.foundry_dir or state.get("foundry_dir", REPO_ROOT / "scripts/foundry/sky130"))
    return workdir, case_root, input_def, config, foundry


def save_context(state: dict, args: argparse.Namespace, workdir: Path, case_root: Path, input_def: Path,
                 config: Path, foundry: Path) -> None:
    state.update({"case_root": str(case_root), "input_def": str(input_def), "config": str(config),
                  "foundry_dir": str(foundry)})
    (workdir / "gp_agent_state.json").write_text(json.dumps(state, indent=2))


def cmd_start(args: argparse.Namespace) -> int:
    workdir = Path(args.workdir)
    case_root = Path(args.case_root)
    input_def = Path(args.input_def)
    config = Path(args.config)
    foundry = Path(args.foundry_dir)
    cmd = [f"placer_run_gp -mode start -iterations {args.iterations} -seed {args.seed}"]
    if args.random_init == 0:
        cmd[-1] += " -random_init 0"
    if args.seed_anchor_strength > 0:
        cmd[-1] += f" -seed_anchor_strength {args.seed_anchor_strength}"
    if args.target_density > 0:
        cmd[-1] += f" -target_density {args.target_density}"
    if args.init_density_penalty >= 0:
        cmd[-1] += f" -init_density_penalty {args.init_density_penalty}"
    if args.min_phi_coef >= 0:
        cmd[-1] += f" -min_phi_coef {args.min_phi_coef}"
    if args.max_phi_coef >= 0:
        cmd[-1] += f" -max_phi_coef {args.max_phi_coef}"
    if args.congestion_effort >= 0:
        cmd[-1] += f" -congestion_effort {args.congestion_effort}"
    if args.report_route_util:
        cmd[-1] += " -report_route_util 1"
    rc, out, err = run_ieda(workdir, case_root, foundry, config, input_def, cmd, def_save=True)
    record = last_ledger(workdir)
    if rc != 0:
        print(json.dumps({"ok": False, "rc": rc, "stderr_tail": err[-2000:]}))
        return 1
    state = update_state(workdir, {"case_root": str(case_root), "input_def": str(input_def),
                                   "config": str(config), "foundry_dir": str(foundry)})
    print(json.dumps({"ok": True, "state": state, "record": record}, indent=2))
    return 0


def require_context(args: argparse.Namespace):
    workdir, case_root, input_def, config, foundry = load_workdir_context(args)
    if not case_root.exists() or not input_def.exists() or not config.exists():
        print(json.dumps({"ok": False, "reason": "missing workdir context; run start first"}))
        sys.exit(2)
    return workdir, case_root, input_def, config, foundry


def resolve_checkpoint(args: argparse.Namespace, workdir: Path) -> str | None:
    if args.checkpoint:
        return args.checkpoint
    state_path = workdir / "gp_agent_state.json"
    if not state_path.exists():
        return None
    return json.loads(state_path.read_text()).get("latest_checkpoint")


def cmd_advance(args: argparse.Namespace) -> int:
    workdir, case_root, input_def, config, foundry = require_context(args)
    ckpt = resolve_checkpoint(args, workdir)
    if not ckpt or not Path(ckpt).exists():
        print(json.dumps({"ok": False, "reason": "no checkpoint; run start first"}))
        return 1
    cmd = [f"placer_run_gp -mode resume -checkpoint {shlex.quote(str(ckpt))} -iterations {args.iterations}"]
    if args.report_route_util:
        cmd[-1] += " -report_route_util 1"
    rc, out, err = run_ieda(workdir, case_root, foundry, config, input_def, cmd, def_save=True)
    record = last_ledger(workdir)
    if rc != 0:
        print(json.dumps({"ok": False, "rc": rc, "stderr_tail": err[-2000:]}))
        return 1
    state = update_state(workdir)
    print(json.dumps({"ok": True, "state": state, "record": record}, indent=2))
    return 0


def cmd_local_run(args: argparse.Namespace) -> int:
    """Apply a scope for N iterations WITHOUT a global control branch."""
    workdir, case_root, input_def, config, foundry = require_context(args)
    ckpt = resolve_checkpoint(args, workdir)
    if not ckpt or not Path(ckpt).exists():
        print(json.dumps({"ok": False, "reason": "no checkpoint; run start first"}))
        return 1
    cmds = [
        f"placer_run_gp -mode restore -checkpoint {shlex.quote(str(ckpt))}",
        f"placer_run_gp -mode advance -iterations {args.iterations} " + " ".join(scope_args(args)),
        "placer_run_gp -mode accept",
    ]
    rc, out, err = run_ieda(workdir, case_root, foundry, config, input_def, cmds, def_save=True)
    record = last_ledger(workdir)
    if rc != 0:
        print(json.dumps({"ok": False, "rc": rc, "stderr_tail": err[-2000:]}))
        return 1
    state = update_state(workdir)
    save_context(state, args, workdir, case_root, input_def, config, foundry)
    print(json.dumps({"ok": True, "state": state, "record": record}, indent=2))
    return 0


def parse_def_components(def_path: str | Path) -> dict[str, tuple[int, int]]:
    text = Path(def_path).read_text(errors="ignore")
    comp_start = text.find("\nCOMPONENTS")
    comp_end = text.find("\nEND COMPONENTS")
    if comp_start < 0 or comp_end < 0:
        return {}
    out: dict[str, tuple[int, int]] = {}
    pattern = re.compile(r"^\s*-\s+(\S+)\s+\S+.*?\+\s+(?:FIXED|PLACED)\s*\(\s*(-?\d+)\s+(-?\d+)\s*\)", re.M)
    for m in pattern.finditer(text[comp_start:comp_end]):
        out[m.group(1)] = (int(m.group(2)), int(m.group(3)))
    return out


def cmd_verify_lg(args: argparse.Namespace) -> int:
    """Run LG in a throwaway workdir as a read-only oracle for a checkpoint."""
    workdir, case_root, input_def, config, foundry = require_context(args)
    ckpt = resolve_checkpoint(args, workdir)
    if not ckpt or not Path(ckpt).exists():
        print(json.dumps({"ok": False, "reason": "no checkpoint; run start first"}))
        return 1
    cp = json.loads(Path(ckpt).read_text())
    names = cp.get("instance_names") or []
    before = cp.get("instance_density_coords") or []
    if not names or len(names) != len(before):
        print(json.dumps({"ok": False, "reason": "checkpoint has no instance coordinates"}))
        return 1
    temp = Path(workdir) / "_lg_verify"
    import shutil
    if temp.exists():
        shutil.rmtree(temp)
    temp.mkdir(parents=True)
    cmds = [
        f"placer_run_gp -mode restore -checkpoint {shlex.quote(str(ckpt))}",
        "placer_run_gp -mode accept",
        "placer_run_lg",
    ]
    rc, out, err = run_ieda(temp, case_root, foundry, config, input_def, cmds, def_save=True)
    if rc != 0:
        print(json.dumps({"ok": False, "stage": "lg", "rc": rc, "stderr_tail": err[-2000:]}))
        return 1
    lg_def = temp / "placement.def"
    after = parse_def_components(lg_def)
    idx = {name: i for i, name in enumerate(names)}
    pairs = []
    missing = 0
    for name, xy in after.items():
        i = idx.get(name)
        if i is None:
            missing += 1
            continue
        dx = xy[0] - float(before[i][0])
        dy = xy[1] - float(before[i][1])
        pairs.append((abs(dx) + abs(dy), dx, dy, name))
    pairs.sort(reverse=True)
    max_disp = pairs[0][0] if pairs else 0.0
    avg_disp = sum(p[0] for p in pairs) / len(pairs) if pairs else 0.0
    hpwl = None
    if lg_def.exists():
        try:
            hpwl_proc = subprocess.run(
                [sys.executable, str(REPO_ROOT / "benchmarks/flows/def_hpwl_eval.py"),
                 str(Path(foundry) / "lef/sky130_fd_sc_hd_merged.lef"), str(lg_def)],
                text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=600)
            m = re.search(r"HPWL=(\d+)", hpwl_proc.stdout)
            if m:
                hpwl = int(m.group(1))
        except Exception:
            hpwl = None
    print(json.dumps({
        "ok": True,
        "checkpoint": str(ckpt),
        "iteration": cp.get("current_iter"),
        "lg_success": True,
        "lg_def": str(lg_def),
        "lg_max_displacement": max_disp,
        "lg_avg_displacement": avg_disp,
        "lg_displacement_pairs": len(pairs),
        "lg_missing_instances": missing,
        "lg_hpwl": hpwl,
        "fidelity": "lg",
    }, indent=2))
    return 0


def parse_candidate_stdout(out: str) -> dict:
    info = {}
    m = re.search(r"candidate_verdict=(\S+).*?local=(\S+)\s+global=(\S+)", out)
    if m:
        info["candidate_verdict"] = m.group(1)
        info["candidate_local_checkpoint"] = m.group(2)
        info["candidate_global_checkpoint"] = m.group(3)
    return info


def cmd_candidate(args: argparse.Namespace) -> int:
    workdir, case_root, input_def, config, foundry = require_context(args)
    ckpt = resolve_checkpoint(args, workdir)
    if not ckpt or not Path(ckpt).exists():
        print(json.dumps({"ok": False, "reason": "no checkpoint; run start first"}))
        return 1
    cmds = [
        f"placer_run_gp -mode restore -checkpoint {shlex.quote(str(ckpt))}",
        f"placer_run_gp -mode candidate -iterations {args.iterations} "
        + " ".join(scope_args(args))
        + f" -candidate_overflow_penalty {args.overflow_penalty}",
        "catch {placer_run_gp -mode accept}",
    ]
    rc, out, err = run_ieda(workdir, case_root, foundry, config, input_def, cmds, def_save=True)
    record = last_ledger(workdir)
    candidate = parse_candidate_stdout(out)
    if rc != 0:
        print(json.dumps({"ok": False, "rc": rc, "stderr_tail": err[-2000:]}))
        return 1
    state = update_state(workdir, {"last_candidate": candidate})
    print(json.dumps({"ok": True, "state": state, "record": record, "candidate": candidate}, indent=2))
    return 0


def cmd_accept(args: argparse.Namespace) -> int:
    workdir, case_root, input_def, config, foundry = require_context(args)
    ckpt = resolve_checkpoint(args, workdir)
    if not ckpt or not Path(ckpt).exists():
        print(json.dumps({"ok": False, "reason": "no checkpoint; run start first"}))
        return 1
    cmds = [
        f"placer_run_gp -mode restore -checkpoint {shlex.quote(str(ckpt))}",
        "placer_run_gp -mode accept",
    ]
    rc, out, err = run_ieda(workdir, case_root, foundry, config, input_def, cmds, def_save=True)
    if rc != 0:
        print(json.dumps({"ok": False, "rc": rc, "stderr_tail": err[-2000:]}))
        return 1
    print(json.dumps({"ok": True, "state": update_state(workdir)}, indent=2))
    return 0


def cmd_compare(args: argparse.Namespace) -> int:
    def load(p):
        return json.loads(Path(p).read_text())
    a = load(args.checkpoint_a)
    b = load(args.checkpoint_b)
    same_origin = a.get("config_fingerprint") == b.get("config_fingerprint") and a.get("instance_names") == b.get("instance_names")
    same_budget = a.get("current_iter") == b.get("current_iter")
    left_hpwl, left_ov = int(a.get("prev_hpwl", 0)), float(a.get("sum_overflow", 0))
    right_hpwl, right_ov = int(b.get("prev_hpwl", 0)), float(b.get("sum_overflow", 0))
    target = float(a.get("config_state", {}).get("target_overflow", 0.1))
    penalty = float(getattr(args, "overflow_penalty", 0.0))
    lf = left_ov <= target + 1e-5
    rf = right_ov <= target + 1e-5
    if not same_origin or not same_budget:
        verdict = "incomparable"
    elif lf and rf:
        verdict = "equal" if abs(left_hpwl - right_hpwl) <= max(1, left_hpwl // 100000) else ("left" if left_hpwl < right_hpwl else "right")
    elif lf != rf:
        verdict = "left" if lf else "right"
    else:
        ldom = left_hpwl <= right_hpwl and left_ov <= right_ov and (left_hpwl < right_hpwl or left_ov < right_ov)
        rdom = right_hpwl <= left_hpwl and right_ov <= left_ov and (right_hpwl < left_hpwl or right_ov < left_ov)
        if ldom:
            verdict = "left"
        elif rdom:
            verdict = "right"
        elif penalty > 0 and left_hpwl > 0 and right_hpwl > 0:
            le = max(0.0, left_ov - target)
            re = max(0.0, right_ov - target)
            score = (left_hpwl - right_hpwl) / right_hpwl + penalty * (le - re) / max(re, target, 1e-4)
            verdict = "equal" if abs(score) <= 1e-4 else ("left" if score < 0 else "right")
        else:
            verdict = "incomparable"
    print(json.dumps({"ok": True, "same_origin": same_origin, "same_budget": same_budget, "verdict": verdict,
                      "left": {"iter": a.get("current_iter"), "hpwl": left_hpwl, "overflow": left_ov},
                      "right": {"iter": b.get("current_iter"), "hpwl": right_hpwl, "overflow": right_ov}}, indent=2))
    return 0


def cmd_status(args: argparse.Namespace) -> int:
    workdir = Path(args.workdir)
    state_path = workdir / "gp_agent_state.json"
    state = json.loads(state_path.read_text()) if state_path.exists() else {}
    print(json.dumps({"ok": True, "state": state, "record": last_ledger(workdir)}, indent=2))
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    for name, fn in [("start", cmd_start), ("advance", cmd_advance), ("local_run", cmd_local_run),
                     ("candidate", cmd_candidate), ("verify_lg", cmd_verify_lg),
                     ("accept", cmd_accept), ("compare", cmd_compare), ("status", cmd_status)]:
        sp = sub.add_parser(name)
        if name in ("start", "advance", "candidate"):
            for a in ["workdir", "case-root", "input-def", "config", "foundry-dir", "iterations", "seed",
                      "checkpoint", "scope", "scope-active-ratio", "scope-active-count", "scope-instances",
                      "scope-region", "halo-coeff", "halo-hops", "target-density", "report-route-util",
                      "scope-density-target", "scope-density-ratio", "overflow-penalty", "random-init",
                      "seed-anchor-strength", "init-density-penalty", "min-phi-coef", "max-phi-coef",
                      "congestion-effort"]:
                # reuse common parser option definitions
                pass
    # Simpler: attach common options to every parser manually.
    for sp in parser._subparsers._group_actions[0].choices.values():
        if sp.prog.endswith(("start", "advance", "local_run", "candidate")):
            for args_, kwargs in [
                (("--workdir",), {"required": True}),
                (("--case-root",), {}), (("--input-def",), {}), (("--config",), {}),
                (("--foundry-dir",), {"default": str(REPO_ROOT / "scripts/foundry/sky130")}),
                (("--iterations",), {"type": int, "default": 20}),
                (("--seed",), {"type": int, "default": 1000}), (("--checkpoint",), {}),
                (("--random-init",), {"type": int, "default": 1}),
                (("--seed-anchor-strength",), {"type": float, "default": 0.0}),
                (("--scope",), {"choices": ["global", "hotspot", "random", "instances", "region", "longnet"], "default": "global"}),
                (("--scope-active-ratio",), {"type": float, "default": 0.2}),
                (("--scope-active-count",), {"type": int, "default": 100}),
                (("--scope-instances",), {"default": ""}), (("--scope-region",), {"default": ""}),
                (("--scope-density-target",), {"type": float, "default": 1.0}),
                (("--scope-density-ratio",), {"type": float, "default": 0.0}),
                (("--halo-coeff",), {"type": float, "default": 0.5}),
                (("--halo-hops",), {"type": int, "default": 2}),
                (("--target-density",), {"type": float, "default": -1.0}),
                (("--init-density-penalty",), {"type": float, "default": -1.0}),
                (("--min-phi-coef",), {"type": float, "default": -1.0}),
                (("--max-phi-coef",), {"type": float, "default": -1.0}),
                (("--congestion-effort",), {"type": int, "default": -1}),
                (("--report-route-util",), {"type": int, "default": 1}),
                (("--overflow-penalty",), {"type": float, "default": 0.0}),
            ]:
                sp.add_argument(*args_, **kwargs)
        elif sp.prog.endswith(("accept", "verify_lg")):
            sp.add_argument("--workdir", required=True)
            sp.add_argument("--case-root"); sp.add_argument("--input-def"); sp.add_argument("--config")
            sp.add_argument("--foundry-dir"); sp.add_argument("--checkpoint")
        elif sp.prog.endswith("compare"):
            sp.add_argument("--checkpoint-a", required=True)
            sp.add_argument("--checkpoint-b", required=True)
            sp.add_argument("--overflow-penalty", type=float, default=0.0)
        elif sp.prog.endswith("status"):
            sp.add_argument("--workdir", required=True)
    args = parser.parse_args()
    return {"start": cmd_start, "advance": cmd_advance, "local_run": cmd_local_run,
            "candidate": cmd_candidate, "verify_lg": cmd_verify_lg, "accept": cmd_accept,
            "compare": cmd_compare, "status": cmd_status}[args.command](args)


if __name__ == "__main__":
    raise SystemExit(main())
