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
import select
import shlex
import socket
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
IEDa_BIN = Path(os.environ.get("IEDA_BIN", REPO_ROOT / "build/bin/iEDA"))
PLV_CASES_ROOT = Path(os.environ.get("PLV_CASES_ROOT", "/home/lizhijun/work/iEDA/docs/ipl/pl_vis/cases"))
PY_EXE = os.environ.get("PYTHON", sys.executable or "python3")
TREE_PATH = "gp_tree.json"


def resolve_lef(foundry_dir: Path, explicit: str | None = None) -> Path | None:
    """Resolve the macro LEF used for DEF-level HPWL evaluation."""
    if explicit:
        p = Path(explicit)
        if p.exists():
            return p
    # PDK-agnostic LEF resolution: prefer any *merged* cell LEF (the naming
    # convention every foundry dir uses for the union cell lib), then fall
    # back to the first .lef under the foundry dir. No PDK-name special case.
    hits = sorted(Path(foundry_dir).rglob("*merged*.lef")) or sorted(Path(foundry_dir).rglob("*.lef"))
    return hits[0] if hits else None


def def_hpwl_of(def_path: Path, lef: Path | None) -> int | None:
    """Same-evaluator DEF-level HPWL (def_hpwl_eval.py). Cheap: pure python."""
    if lef is None or not Path(def_path).exists():
        return None
    try:
        proc = subprocess.run(
            [PY_EXE, str(REPO_ROOT / "benchmarks/flows/def_hpwl_eval.py"), str(lef), str(def_path)],
            cwd=REPO_ROOT, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, timeout=600)
        m = re.search(r"HPWL=(\d+)", proc.stdout or "")
        return int(m.group(1)) if m else None
    except Exception:
        return None


def parse_bool(value: str | bool) -> bool:
    if isinstance(value, bool):
        return value
    return value.lower() in ("1", "true", "yes", "on")


def write_tcl(workdir: Path, case_root: Path, foundry_dir: Path, config: Path, input_def: Path, commands: list[str],
              def_save: bool = False, def_path: Path | None = None) -> Path:
    workdir.mkdir(parents=True, exist_ok=True)
    tcl = workdir / "gp_agent.tcl"
    tcl.write_text(
        f"""flow_init -config {shlex.quote(str(case_root / 'iEDA_config/flow_config.json'))}\n"""
        f"""db_init -config {shlex.quote(str(case_root / 'iEDA_config/db_default_config.json'))} -output_dir_path {shlex.quote(str(workdir))}\n"""
        f"""source {shlex.quote(str(case_root / 'script/DB_script/db_path_setting.tcl'))}\n"""
        f"""source {shlex.quote(str(case_root / 'script/DB_script/db_init_lib.tcl'))}\n"""
        f"""source {shlex.quote(str(case_root / 'script/DB_script/db_init_sdc.tcl'))}\n"""
        f"""source {shlex.quote(str(case_root / 'script/DB_script/db_init_lef.tcl'))}\n"""
        f"""def_init -path {shlex.quote(str(input_def))}\n"""
        f"""init_pl -config {shlex.quote(str(config))}\n"""
        + "\n".join(commands)
        + ("\n" if commands else "")
        + (f"def_save -path {shlex.quote(str(def_path or (workdir / 'placement.def')))}\n" if def_save else "")
        + "flow_exit\n"
    )
    return tcl


def _run_ieda_via_daemon(workdir: Path, commands: list[str], def_save: bool, def_path: Path | None) -> tuple[int, str, str] | None:
    """Try the persistent socket daemon first; return None when absent/broken."""
    if os.environ.get("GP_AGENT_NO_DAEMON") == "1":
        return None
    sock_path = workdir / ".ieda_daemon.sock"
    if not sock_path.exists():
        return None
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
            s.settimeout(30)  # 30s 超时快速 fallback 到直接 subprocess；daemon 被 kill 后残留 socket 会阻塞 1800s
            try:
                s.connect(str(sock_path))
            except (ConnectionRefusedError, OSError):
                # daemon 已死但 socket 文件残留：清理后下次直接走 subprocess
                try:
                    sock_path.unlink(missing_ok=True)
                except Exception:
                    pass
                return None
            req = {"commands": commands}
            if def_save:
                req["def_save"] = str(def_path or (workdir / "placement.def"))
            s.sendall((json.dumps(req) + "\n").encode())
            data = b""
            while True:
                chunk = s.recv(65536)
                if not chunk:
                    break
                data += chunk
            resp = json.loads(data.decode())
            return resp.get("rc", -1), resp.get("out", ""), resp.get("err", "")
    except Exception:
        # 任何 daemon 通信失败（超时/断连/协议错）都清残留 socket，
        # 下次调用直接走 subprocess，不再阻塞。
        try:
            sock_path.unlink(missing_ok=True)
        except Exception:
            pass
        return None


def _derive_pdk_env(foundry_dir: Path) -> dict:
    """Derive TECH_LEF_PATH/LEF_PATH/LIB_PATH/TAPCELL/ENDCAP env vars that copied
    case_roots (lxq pdh/aes13 workspace) expect in db_path_setting.tcl. Uses a
    RECURSIVE walk (ics55 keeps lef in prtech/techLEF + IP/.../lef, lib in
    IP/.../liberty, not the top-level lef/ lib/), and excludes AppleDouble ._
    resource-fork files. bal11-style case_roots derive these from $FOUNDRY_DIR
    and ignore the extras, so adding them is safe for both."""
    froot = Path(foundry_dir)
    lefs_all = []
    libs_all = []
    for p in froot.rglob("*.lef"):
        if p.name.startswith("._") or p.name.endswith(".tlef"):
            continue
        lefs_all.append(p)
    for p in froot.rglob("*.tlef"):
        if not p.name.startswith("._"):
            lefs_all.append(p)
    for p in froot.rglob("*.lib"):
        n = p.name.lower()
        if p.name.startswith("._") or ".orig" in n or ".tmp" in n:
            continue
        libs_all.append(p)
    def is_tech(p):
        lp = str(p).lower()
        return (".tlef" in p.name.lower() or "prtech" in lp or "techlef" in lp
                or ("tech" in p.name.lower() and "sc" not in p.name.lower()
                    and "macro" not in p.name.lower()))
    tech = None
    for p in sorted(lefs_all, key=lambda x: (0 if is_tech(x) else 1, str(x))):
        if is_tech(p):
            tech = p
            break
    lefs = [str(p) for p in sorted(lefs_all) if (tech is None or str(p) != str(tech)) and not is_tech(p)]
    libs = [str(p) for p in sorted(libs_all)]
    return {
        "TECH_LEF_PATH": str(tech) if tech else "",
        "LEF_PATH": (" " + " ".join(lefs) + " "),
        "LIB_PATH": (" " + " ".join(libs) + " "),
        "TAPCELL": "TAPCELL_X1",
        "ENDCAP": "FILLCELL_X1",
    }


def run_ieda(workdir: Path, case_root: Path, foundry_dir: Path, config: Path, input_def: Path,
             commands: list[str], def_save: bool = False, def_path: Path | None = None) -> tuple[int, str, str]:
    daemon_res = _run_ieda_via_daemon(workdir, commands, def_save, def_path)
    if daemon_res is not None:
        return daemon_res
    tcl = write_tcl(workdir, case_root, foundry_dir, config, input_def, commands, def_save, def_path)
    env = os.environ.copy()
    # SDC filename may not match the case directory name (e.g. case
    # apb4_timer ships apb4.sdc); the <name>.sdc -> any *.sdc -> default.sdc
    # ladder fixes timing-driven GP init on such cases.
    sdc = case_root / f"{case_root.name}.sdc"
    if not sdc.exists():
        sdc_candidates = sorted(case_root.glob("*.sdc"))
        sdc = sdc_candidates[0] if sdc_candidates else case_root / "default.sdc"
    env.update({
        "CONFIG_DIR": str(case_root / "iEDA_config"),
        "RESULT_DIR": str(workdir),
        "TCL_SCRIPT_DIR": str(case_root / "script"),
        "FOUNDRY_DIR": str(foundry_dir),
        "SDC_FILE": str(sdc),
    })
    # Also provide the TECH_LEF_PATH/LEF_PATH/LIB_PATH/TAPCELL/ENDCAP vars that copied
    # (lxq pdh/aes13) case_roots expect in db_path_setting.tcl; bal11-style case_roots
    # derive these from $FOUNDRY_DIR themselves and ignore the extras.
    env.update(_derive_pdk_env(foundry_dir))
    proc = subprocess.run([str(IEDa_BIN), "-script", str(tcl)], cwd=REPO_ROOT, env=env,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=1800)
    return proc.returncode, proc.stdout, proc.stderr


def last_gp_line(out: str) -> dict:
    """Parse the final `iPL gp.run` line; it carries the true terminal status,
    which the append-only ledger may not contain for terminal batches."""
    m = None
    for line in out.splitlines():
        mm = re.search(r"iPL gp\.run \(([^)]+)\) stop_reason=(\S+).*?iterations=(\d+)-(\d+) "
                       r"hpwl=(\d+) overflow=([0-9.eE+-]+).*?route_util=([0-9.eE+-]+)", line)
        if mm:
            m = mm
    if not m:
        return {}
    record = {
        "mode": m.group(1).split(",")[0].split()[-1],
        "stop_reason": m.group(2),
        "start_iteration": int(m.group(3)),
        "end_iteration": int(m.group(4)),
        "hpwl": int(m.group(5)),
        "overflow": float(m.group(6)),
        "route_util": float(m.group(7)),
    }
    effect = re.search(r"scope_effect active=(\d+) halo=(\d+) context=(\d+) context_moved=(\d+) max_displacement=([0-9.eE+-]+)", out)
    if effect:
        record["scope_effect"] = {
            "active_written": int(effect.group(1)),
            "halo_written": int(effect.group(2)),
            "context_written": int(effect.group(3)),
            "context_moved": int(effect.group(4)),
            "max_displacement": float(effect.group(5)),
        }
    return record


def last_ledger(workdir: Path) -> dict:
    path = workdir / "pl/gp_experiments.jsonl"
    if not path.exists():
        return {}
    lines = [ln for ln in path.read_text(errors="ignore").splitlines() if ln.strip()]
    return json.loads(lines[-1]) if lines else {}


def update_state(workdir: Path, extra: dict | None = None, record: dict | None = None, wrote_def: bool = False) -> dict:
    state_path = workdir / "gp_agent_state.json"
    state = {}
    if state_path.exists():
        try:
            state = json.loads(state_path.read_text())
        except Exception:
            state = {}
    if record is None:
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
    terminal_checkpoint = workdir / "pl/gp_session_checkpoint.json"
    checkpoint_hit = record.get("checkpoint") or record.get("checkpoint_path")
    if not checkpoint_hit and terminal_checkpoint.exists():
        checkpoint_hit = str(terminal_checkpoint)
    if checkpoint_hit:
        state["latest_checkpoint"] = checkpoint_hit
        # Only a run that actually wrote placement.def (def_save=True) may
        # update the materialized-DEF marker. restore/apply/fork move the
        # logical head without rewriting placement.def, so they must NOT touch
        # this marker - otherwise promote/accept would skip re-materializing
        # and copy a DEF that belongs to a different checkpoint.
        if wrote_def:
            state["placement_def_checkpoint"] = checkpoint_hit
    # Track the session-best DEF HPWL so every tool can see (and the plugin can
    # surface) whether the current run regressed the best placement. The agent
    # is expected to restore to best_checkpoint when an optimization regresses;
    # the plugin only REPORTS this - the agent still decides (end-to-end).
    cur_hpwl = record.get("def_hpwl")
    if cur_hpwl is not None and cur_hpwl > 0:
        best = state.get("best_def_hpwl")
        if best is None or cur_hpwl < best:
            state["best_def_hpwl"] = cur_hpwl
            state["best_checkpoint"] = checkpoint_hit or state.get("latest_checkpoint")
            state["best_def_hpwl_unit"] = record.get("def_hpwl_unit", "def")
    if extra:
        state.update(extra)
    # Regression flag: if the current DEF HPWL is >1% worse than the session
    # best, surface it so the agent (and the plugin) can see the run regressed.
    if wrote_def and "best_def_hpwl" in state and cur_hpwl is not None and cur_hpwl > 0:
        ratio = cur_hpwl / state["best_def_hpwl"]
        state["regressed_vs_best"] = ratio > 1.01
        state["def_hpwl_vs_best_ratio"] = ratio
    state_path.write_text(json.dumps(state, indent=2))
    return state


def scope_args(args: argparse.Namespace) -> list[str]:
    out = ["-scope", args.scope]
    if args.scope in ("hotspot",):
        out += ["-scope_active_ratio", str(args.scope_active_ratio)]
    if args.scope in ("random", "longnet"):
        out += ["-scope_active_count", str(args.scope_active_count)]
    if args.scope == "instances":
        out += ["-scope_instances", "{" + args.scope_instances + "}"]
    if args.scope == "region":
        if args.scope_region:
            out += ["-scope_region", "{" + args.scope_region + "}"]
    if getattr(args, "scope_seed", None) is not None:
        out += ["-scope_seed", str(args.scope_seed)]
    out += ["-scope_halo_coeff", str(args.halo_coeff), "-scope_halo_hops", str(args.halo_hops)]
    out += ["-scope_density_target", str(args.scope_density_target),
            "-scope_density_ratio", str(args.scope_density_ratio)]
    out += ["-scope_anneal_ratio", str(getattr(args, "scope_anneal_ratio", 0.0))]
    anchor_strength = getattr(args, "scope_anchor_strength", 0.0)
    if anchor_strength > 0.0:
        out += ["-scope_anchor_strength", str(anchor_strength)]
    return out


def common_arg_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser()
    p.add_argument("--workdir", required=True)
    p.add_argument("--case-root")
    p.add_argument("--input-def")
    p.add_argument("--config")
    p.add_argument("--foundry-dir")  # no PDK-specific default: caller/registry must supply it
    p.add_argument("--iterations", type=int, default=20)
    p.add_argument("--seed", type=int, default=1000)
    p.add_argument("--checkpoint")
    p.add_argument("--scope", choices=["global", "hotspot", "random", "instances", "region", "longnet"], default="global")
    p.add_argument("--scope-active-ratio", type=float, default=0.2)
    p.add_argument("--scope-active-count", type=int, default=100)
    p.add_argument("--scope-instances", default="")
    p.add_argument("--scope-region", default="")
    p.add_argument("--scope-anchor-strength", type=float, default=0.0)
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
    config = Path(state.get("config") or args.config)
    foundry = Path(args.foundry_dir or state.get("foundry_dir")) if (args.foundry_dir or state.get("foundry_dir")) else None
    return workdir, case_root, input_def, config, foundry


def save_context(state: dict, args: argparse.Namespace, workdir: Path, case_root: Path, input_def: Path,
                 config: Path, foundry: Path) -> None:
    state.update({"case_root": str(case_root), "input_def": str(input_def), "config": str(config),
                  "foundry_dir": str(foundry)})
    (workdir / "gp_agent_state.json").write_text(json.dumps(state, indent=2))


def _attach_egr(record: dict, workdir: Path, case_root: Path, foundry: Path) -> dict:
    """--verify-egr: attach the authoritative iRT trial-route EGR to a run record.

    Unlegalized DEFs are refused (overlapping cells fake a low EGR). EGR is
    expensive (one iEDA evaluator startup), so this only runs when the agent
    explicitly asks for per-step feedback (verify_egr=1).
    """
    try:
        from gp_metrics_compare import density, check_legalized
        def_path = workdir / "placement.def"
        leg = check_legalized(def_path)
        record["legalized"] = leg["legalized"]
        if not leg["legalized"]:
            record["egr_valid"] = False
            record["egr_reason"] = leg.get("reason")
            return record
        d = density(def_path, case_root, 200, foundry, "egr", 64)
        record["egr_valid"] = bool(d.get("egr_valid"))
        for k in ("egr_total_overflow_horizontal", "egr_total_overflow_vertical", "egr_total_overflow_union",
                  "egr_max_overflow_horizontal", "egr_max_overflow_vertical", "egr_max_overflow_union",
                  "egr_avg_overflow_horizontal", "egr_avg_overflow_vertical", "egr_avg_overflow_union"):
            if d.get(k) is not None:
                record[k] = d[k]
        if not record["egr_valid"]:
            record["egr_reason"] = d.get("reason") or d.get("congestion_reason")
    except Exception as exc:
        record["egr_valid"] = False
        record["egr_reason"] = f"egr attach failed: {exc}"
    return record


def cmd_start(args: argparse.Namespace) -> int:
    workdir = Path(args.workdir)
    case_root = Path(args.case_root)
    input_def = Path(args.input_def)
    config = Path(args.config)
    if not args.foundry_dir:
        print(json.dumps({"ok": False, "reason": "cmd_start: --foundry-dir is required (no PDK-specific default)"}))
        return 1
    foundry = Path(args.foundry_dir)
    cmd = [f"placer_run_gp -mode start -iterations {args.iterations} -seed {args.seed}"]
    if args.random_init == 0:
        cmd[-1] += " -random_init 0"
    if args.seed_anchor_strength > 0:
        cmd[-1] += f" -seed_anchor_strength {args.seed_anchor_strength}"
    if args.target_density > 0:
        cmd[-1] += f" -target_density {args.target_density}"
    else:
        # ---startfix--- omitted target_density mismatches DEF die on some PDKs (esp ics55), segfault.
        cmd[-1] += " -target_density 0.5"
    if args.target_overflow > 0:
        cmd[-1] += f" -target_overflow {args.target_overflow}"
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
    # start publishes the placed coordinates into the in-memory session; accept
    # right after commits them so the single def_save below exports the placed
    # DEF (not the input DEF). This removes the old second restore+accept
    # process and halves start latency.
    cmd.append("placer_run_gp -mode accept")
    run_config = config
    derived_applied = False
    wants_timing = getattr(args, "timing", 0) == 1
    wants_bins = True  # always derive 64x64-aligned config (solver grid must match verify/RUDY 64x64)
    if wants_timing or wants_bins:
        try:
            workdir.mkdir(parents=True, exist_ok=True)
            cfg_data = json.loads(config.read_text())
            pl = cfg_data.get("PL", cfg_data)
            if wants_timing:
                pl["is_timing_effort"] = 1
                pl.setdefault("GP", {}).setdefault("Nesterov", {})["opt_overflow_list"] = [0.10, 0.12, 0.15, 0.20, 0.25, 0.30]
            if wants_bins:
                dens = pl.setdefault("GP", {}).setdefault("Density", {})
                dens["is_adaptive_bin"] = 0
                b = args.bin_cnt if args.bin_cnt > 0 else 64
                dens["bin_cnt_x"] = b
                dens["bin_cnt_y"] = b
            # Carry the agent-facing knobs INTO the derived config so they survive
            # placer (and so parallel td/ce sweep candidates actually differ).
            # Correct nested keys (verified against pl_clean_config.json):
            #   PL.GP.Density.target_density, PL.GP.Nesterov.target_overflow.
            # Writing the TOP-LEVEL pl["target_density"] / pl["target_overflow"]
            # produced "Configurator: unknown configuration key" and killed every
            # parallel candidate.
            a_td = getattr(args, "target_density", -1)
            if a_td > 0:
                # Override (not setdefault) so the CLI --target-density actually
                # takes effect over the config's default (R20 fix: setdefault
                # silently kept the config's 0.7, so td scans were no-ops).
                dens["target_density"] = a_td
            a_to = getattr(args, "target_overflow", -1)
            if a_to >= 0:
                pl.setdefault("GP", {}).setdefault("Nesterov", {})["target_overflow"] = a_to
            # congestion_effort_level is NOT a valid pl_config key (it is a
            # checkpoint-state key); only is_congestion_effort lives in the
            # pl config. Congestion_effort itself is passed to placer_run_gp
            # via CLI, so do not write an invalid key here.
            # is_congestion_effort is a BOOL (0/1) in the pl config; the level
            # is passed to placer_run_gp via CLI (-congestion_effort N). Do NOT
            # write the level into is_congestion_effort.
            a_ce = getattr(args, "congestion_effort", -1)
            if a_ce >= 0:
                pl["is_congestion_effort"] = 1 if a_ce > 0 else 0
            run_config = workdir / "pl_derived_config.json"
            run_config.write_text(json.dumps(cfg_data, indent=2))
            derived_applied = True
        except Exception:
            run_config = config
            derived_applied = False
    rc, out, err = run_ieda(workdir, case_root, foundry, run_config, input_def, cmd, def_save=True)
    record = last_gp_line(out) or last_ledger(workdir)
    if rc != 0:
        print(json.dumps({"ok": False, "rc": rc, "stderr_tail": err[-2000:]}))
        return 1
    extra = {"case_root": str(case_root), "input_def": str(input_def),
             "config": str(run_config), "foundry_dir": str(foundry)}
    # "state" is not yet bound here (update_state runs below); read the workdir
    # state file directly when --lef is not supplied.
    prev_state = {}
    _stp = workdir / "gp_agent_state.json"
    if _stp.exists():
        try:
            prev_state = json.loads(_stp.read_text())
        except Exception:
            prev_state = {}
    lef = resolve_lef(foundry, getattr(args, "lef", None) or prev_state.get("lef"))
    if lef is not None:
        extra["lef"] = str(lef)
    # Compute DEF HPWL BEFORE update_state so best_def_hpwl tracking sees it.
    record["def_hpwl"] = def_hpwl_of(workdir / "placement.def", lef)
    if record.get("def_hpwl") is not None:
        record["def_hpwl_unit"] = "def"
    state = update_state(workdir, extra, record=record, wrote_def=True)
    record["checkpoint_path"] = record.get("checkpoint") or state.get("latest_checkpoint")
    if getattr(args, "timing", 0) == 1:
        record["timing_effort"] = derived_applied
        record["timing_weight_updates"] = (out + err).count("Update netweight for timing improvement") if derived_applied else None
    if getattr(args, "bin_cnt", -1) > 0:
        record["bin_cnt_override"] = args.bin_cnt if derived_applied else None
    if getattr(args, "verify_egr", 0) == 1:
        record = _attach_egr(record, workdir, case_root, foundry)
    print(json.dumps({"ok": True, "state": state, "record": record}, indent=2))
    return 0


def require_context(args: argparse.Namespace):
    workdir, case_root, input_def, config, foundry = load_workdir_context(args)
    if not case_root.exists() or not input_def.exists() or not config.exists():
        print(json.dumps({"ok": False, "reason": "missing workdir context; run start first"}))
        sys.exit(2)
    return workdir, case_root, input_def, config, foundry


def cmd_plain(args: argparse.Namespace) -> int:
    """Plain full flow: placer_run_gp (NO cli knobs, uses the config's
    target_density/max_iter as-is) -> LG -> DP -> def_save.

    The default start-mode knobs (random_init=1, forced target_density 0.5,
    timing, congestion_effort) REGRESS the solver on small designs (s1238:
    plain GP 5.98M HPWL / EGR 3191 vs knobs 10.2M / 8465). This command
    reproduces the known-good config path end to end."""
    workdir = Path(args.workdir)
    case_root = Path(args.case_root)
    input_def = Path(args.input_def)
    config = Path(args.config)
    foundry = Path(args.foundry_dir)
    if not foundry.exists():
        print(json.dumps({"ok": False, "reason": "cmd_plain: --foundry-dir not found"}))
        return 1
    # Session-mode GP so a checkpoint is written (needed by the EGR-hotspot
    # evacuation loop), but WITHOUT the default start knobs that regress the
    # solver. Read target_density / max_iter straight from the config.
    try:
        cfg = json.loads(config.read_text())
        pl = cfg.get("PL", cfg)
        gp = pl.get("GP", {})
        dens = gp.get("Density", {})
        nest = gp.get("Nesterov", {})
        td = float(dens.get("target_density", pl.get("target_density", 0.8)))
        max_iter = int(nest.get("max_iter", 2000))
    except Exception:
        td = 0.8
        max_iter = 2000
    ri = getattr(args, "random_init", 1)
    seed = getattr(args, "seed", 1000)
    bin_cnt = getattr(args, "bin_cnt", -1)
    run_config = config
    if bin_cnt > 0:
        # R33: cmd_plain honors --bin-cnt by deriving a config with the bin
        # override (previously it silently ignored bin_cnt, so bc scans on plain
        # were no-ops). The config's is_adaptive_bin is disabled so bin_cnt takes.
        try:
            cfg_data = json.loads(config.read_text())
            pl = cfg_data.get("PL", cfg_data)
            dens = pl.setdefault("GP", {}).setdefault("Density", {})
            dens["is_adaptive_bin"] = 0
            dens["bin_cnt_x"] = bin_cnt
            dens["bin_cnt_y"] = bin_cnt
            run_config = workdir / "pl_derived_config.json"
            workdir.mkdir(parents=True, exist_ok=True)
            run_config.write_text(json.dumps(cfg_data, indent=2))
        except Exception:
            run_config = config
    cmds = [
        f"placer_run_gp -mode start -iterations {max_iter} -target_density {td} -random_init {ri} -seed {seed} -report_route_util 1",
        "placer_run_gp -mode accept",
        "placer_run_lg",
        "placer_run_dp",
    ]
    rc, out, err = run_ieda(workdir, case_root, foundry, run_config, input_def, cmds, def_save=True)
    if rc != 0:
        print(json.dumps({"ok": False, "rc": rc, "stderr_tail": err[-2000:]}))
        return 1
    state = update_state(workdir, wrote_def=True,
                         extra={"case_root": str(case_root), "input_def": str(input_def),
                                "config": str(config), "foundry_dir": str(foundry)})
    lef = resolve_lef(foundry, getattr(args, "lef", None) or state.get("lef"))
    record = last_gp_line(out) or last_ledger(workdir)
    if not record:
        record = {}
    # cmd_plain returns the session-mode run record (mode/hpwl/overflow/route_util
    # from the "iPL gp.run" line). If the ledger also has a terminal record, prefer
    # the run line for hpwl/overflow/route_util so the plain run is self-describing.
    if lef is not None:
        state = update_state(workdir, {"lef": str(lef)})
    record["def_hpwl"] = def_hpwl_of(workdir / "placement.def", lef)
    if record.get("def_hpwl") is not None:
        record["def_hpwl_unit"] = "def"
    if "target_density" not in record:
        record["target_density"] = td
    if "max_iter" not in record:
        record["max_iter"] = max_iter
    if record.get("mode") is not None:
        state = update_state(workdir, record=record, wrote_def=True)
    if getattr(args, "verify_egr", 0) == 1:
        record = _attach_egr(record, workdir, case_root, foundry)
    print(json.dumps({"ok": True, "state": state, "record": record}, indent=2))
    return 0


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
    if getattr(args, "congestion_effort", -1) >= 0:
        cmd[-1] += f" -congestion_effort {args.congestion_effort}"
    # def_save exports the committed source database; a resumed session must
    # commit first. Terminal resumes are already committed (accept is a no-op),
    # budget resumes are committed here, so the exported DEF is always the
    # resumed placement and never the input DEF.
    cmd.append("placer_run_gp -mode accept")
    rc, out, err = run_ieda(workdir, case_root, foundry, config, input_def, cmd, def_save=True)
    record = last_gp_line(out) or last_ledger(workdir)
    if rc != 0:
        print(json.dumps({"ok": False, "rc": rc, "stderr_tail": err[-2000:]}))
        return 1
    # DEF collapse guard: a resumed advance must never overwrite placement.def
    # with an unplaced/collapsed layout (def_hpwl 0 or >50% cells UNPLACED).
    # If that happens, restore the pre-call checkpoint so the workdir stays
    # valid instead of silently committing a broken DEF.
    # Compute DEF HPWL BEFORE update_state so best_def_hpwl tracking actually
    # sees the fresh value (previously update_state ran first with no def_hpwl
    # in record, so best tracking silently never updated).
    lef = resolve_lef(foundry, getattr(args, "lef", None))
    if lef is None:
        prev = {}
        _sp = workdir / "gp_agent_state.json"
        if _sp.exists():
            try:
                prev = json.loads(_sp.read_text())
            except Exception:
                prev = {}
        lef = prev.get("lef")
    record["def_hpwl"] = def_hpwl_of(workdir / "placement.def", lef)
    if record.get("def_hpwl") is not None:
        record["def_hpwl_unit"] = "def"
    state = update_state(workdir, wrote_def=True, record=record)
    if lef is not None and state.get("lef") != str(lef):
        state = update_state(workdir, {"lef": str(lef)})
    def_path = Path(workdir) / "placement.def"
    if def_path.exists():
        def_text = def_path.read_text(errors="ignore")
        placed = def_text.count("+ PLACED")
        unplaced = def_text.count("+ UNPLACED")
        total = placed + unplaced
        collapsed = (record.get("def_hpwl") in (None, 0)) or (total > 0 and unplaced > 0.5 * total)
        if collapsed:
            # roll back to the checkpoint this advance started from
            rollback_cmd = [f"placer_run_gp -mode restore -checkpoint {shlex.quote(str(ckpt))}", "placer_run_gp -mode accept"]
            run_ieda(workdir, case_root, foundry, config, input_def, rollback_cmd, def_save=True)
            print(json.dumps({"ok": False, "rc": 3, "reason": "advance collapsed the DEF (def_hpwl=0 or >50% UNPLACED); restored pre-call checkpoint"}))
            return 1
        # Regression guard: if this advance made the materialized DEF worse than
        # the session best (by >1%), roll back to the pre-call checkpoint so the
        # workdir never silently holds a regressed head. The agent can then
        # accept best_checkpoint (cmd_accept now prefers it).
        cur_def_hpwl = record.get("def_hpwl")
        best_hpwl = state.get("best_def_hpwl")
        if cur_def_hpwl is not None and best_hpwl is not None and best_hpwl > 0 and cur_def_hpwl > best_hpwl * 1.01:
            rollback_cmd = [f"placer_run_gp -mode restore -checkpoint {shlex.quote(str(ckpt))}", "placer_run_gp -mode accept"]
            run_ieda(workdir, case_root, foundry, config, input_def, rollback_cmd, def_save=True)
            update_state(workdir, wrote_def=True)
            print(json.dumps({"ok": False, "rc": 4, "reason": "advance regressed DEF HPWL vs best; restored pre-call checkpoint",
                              "best_def_hpwl": best_hpwl, "cur_def_hpwl": cur_def_hpwl}))
            return 1
    if getattr(args, "verify_egr", 0) == 1:
        record = _attach_egr(record, workdir, case_root, foundry)
    print(json.dumps({"ok": True, "state": state, "record": record}, indent=2))
    return 0


def validate_scope(args: argparse.Namespace) -> str | None:
    scope = args.scope
    if scope == "region" and not (args.scope_region or "").strip():
        # Auto-derive the top density-hotspot region from the current checkpoint
        # so a headless agent calling scope=region without an explicit rectangle
        # does not hard-fail. The region comes from the same grid report the
        # agent would otherwise read via observe kind=hotspots.
        derived = _auto_region_from_checkpoint(args)
        if derived:
            args.scope_region = derived
            return None
        return "scope=region requires scope_region 'llx lly urx ury' (could not auto-derive from hotspots)"
    if scope == "instances" and not (args.scope_instances or "").strip():
        return "scope=instances requires scope_instances 'inst1,inst2,...'"
    return None


def _auto_region_from_checkpoint(args: argparse.Namespace) -> str | None:
    import glob as _glob
    try:
        workdir = Path(args.workdir)
        # top density bin from the grid report, newest first
        reports = sorted(_glob.glob(str(workdir / "pl/gp_grid_report.json")))
        if not reports:
            return None
        rep = json.loads(Path(reports[-1]).read_text())
        bins = rep.get("bins") or []
        if not bins:
            return None
        hot = max(bins, key=lambda b: b.get("density", 0.0))
        r = hot.get("shape") or hot.get("region")
        if not r:
            return None
        # shape may be [llx,lly,urx,ury]
        if isinstance(r, list) and len(r) == 4:
            return f"{int(r[0])} {int(r[1])} {int(r[2])} {int(r[3])}"
        return str(r)
    except Exception:
        return None


def cmd_local_run(args: argparse.Namespace) -> int:
    """Apply a scope for N iterations WITHOUT a global control branch."""
    scope_error = validate_scope(args)
    if scope_error:
        print(json.dumps({"ok": False, "reason": scope_error}))
        return 1
    workdir, case_root, input_def, config, foundry = require_context(args)
    ckpt = resolve_checkpoint(args, workdir)
    if not ckpt or not Path(ckpt).exists():
        print(json.dumps({"ok": False, "reason": "no checkpoint; run start first"}))
        return 1
    # Snapshot the pre-call checkpoint and pre-call DEF-level HPWL. A scope run
    # that diverges can write a collapsed placement.def while still returning
    # rc=0 (wave7 aes: def_hpwl 57687823), so detect it by the same DEF-level
    # evaluator and roll back - this is an output-sanity guard, not a decision.
    import shutil as _shutil
    original_ckpt = workdir / "pl/rollback_checkpoint.json"
    _shutil.copy2(ckpt, original_ckpt)
    _state_pre = json.loads((workdir / "gp_agent_state.json").read_text()) if (workdir / "gp_agent_state.json").exists() else {}
    _pre_lef = resolve_lef(foundry, getattr(args, "lef", None) or _state_pre.get("lef"))
    _pre_def_hpwl = def_hpwl_of(workdir / "placement.def", _pre_lef)
    cmds = [
        f"placer_run_gp -mode restore -checkpoint {shlex.quote(str(ckpt))}",
        f"placer_run_gp -mode advance -iterations {args.iterations} -report_route_util 1 " + " ".join(scope_args(args)),
        "placer_run_gp -mode accept",
    ]
    rc, out, err = run_ieda(workdir, case_root, foundry, config, input_def, cmds, def_save=True)
    record = last_gp_line(out) or last_ledger(workdir)
    if rc != 0:
        print(json.dumps({"ok": False, "rc": rc, "stderr_tail": err[-2000:]}))
        return 1
    _post_def_hpwl = def_hpwl_of(workdir / "placement.def", _pre_lef)
    if _pre_def_hpwl and _post_def_hpwl and _pre_def_hpwl > 0 and _post_def_hpwl < 0.5 * _pre_def_hpwl:
        cmds_rb = [
            f"placer_run_gp -mode restore -checkpoint {shlex.quote(str(original_ckpt))}",
            "placer_run_gp -mode accept",
        ]
        rc_rb, _out_rb, _err_rb = run_ieda(workdir, case_root, foundry, config, input_def, cmds_rb, def_save=True)
        print(json.dumps({"ok": False, "rolled_back": rc_rb == 0,
                          "reason": "scope run collapsed placement.def (DEF-level HPWL dropped below half the pre-call value); workdir restored to the pre-call checkpoint",
                          "pre_def_hpwl": _pre_def_hpwl, "post_def_hpwl": _post_def_hpwl,
                          "stderr_tail": err[-800:]}, indent=2))
        return 1
    before = {}
    try:
        parent = json.loads(Path(ckpt).read_text())
        before = {"iteration": parent.get("current_iter"), "hpwl": parent.get("prev_hpwl"),
                  "overflow": parent.get("sum_overflow"), "route_util": parent.get("final_route_util")}
    except Exception:
        before = None
    delta = {}
    if before and record.get("hpwl") is not None and record.get("overflow") is not None:
        delta = {"hpwl": record["hpwl"] - before["hpwl"],
                 "overflow": record["overflow"] - before["overflow"]}
        if before.get("route_util") is not None and record.get("route_util") is not None:
            delta["route_util"] = record["route_util"] - before["route_util"]
    state = update_state(workdir, record=record, wrote_def=True)
    save_context(state, args, workdir, case_root, input_def, config, foundry)
    lef = resolve_lef(foundry, getattr(args, "lef", None) or state.get("lef"))
    if lef is not None and state.get("lef") != str(lef):
        state = update_state(workdir, {"lef": str(lef)})
    record["def_hpwl"] = def_hpwl_of(workdir / "placement.def", lef)
    if record.get("def_hpwl") is not None:
        record["def_hpwl_unit"] = "def"
    print(json.dumps({"ok": True, "state": state, "record": record,
                      "before": before, "delta": delta}, indent=2))
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
    placed_def = Path(workdir) / "placement.def"
    if not ckpt or not Path(ckpt).exists():
        ckpt = None
    if not ckpt and not placed_def.exists():
        print(json.dumps({"ok": False, "reason": "no checkpoint and no placement.def; run start first"}))
        return 1
    cp = None
    names: list[str] = []
    before: list[list[float]] = []
    input_for_lg = input_def
    if ckpt:
        cp = json.loads(Path(ckpt).read_text())
        names = cp.get("instance_names") or []
        before = cp.get("instance_density_coords") or []
    else:
        comps = parse_def_components(placed_def)
        names = list(comps.keys())
        before = [[float(x), float(y)] for x, y in comps.values()]
        input_for_lg = placed_def
    if not names or len(names) != len(before):
        print(json.dumps({"ok": False, "reason": "no placement coordinates"}))
        return 1
    temp = Path(workdir) / "_lg_verify"
    import shutil
    if temp.exists():
        shutil.rmtree(temp)
    temp.mkdir(parents=True)
    if ckpt:
        cmds = [
            f"placer_run_gp -mode restore -checkpoint {shlex.quote(str(ckpt))}",
            "placer_run_gp -mode accept",
            "placer_run_lg",
        ]
    else:
        cmds = ["placer_run_lg"]
    rc, out, err = run_ieda(temp, case_root, foundry, config, input_for_lg, cmds, def_save=True)
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
            lef = resolve_lef(foundry, getattr(args, "lef", None))
            if lef is not None:
                hpwl_proc = subprocess.run(
                    [PY_EXE, str(REPO_ROOT / "benchmarks/flows/def_hpwl_eval.py"),
                     str(lef), str(lg_def)],
                    text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=600)
                m = re.search(r"HPWL=(\d+)", hpwl_proc.stdout)
                if m:
                    hpwl = int(m.group(1))
        except Exception:
            hpwl = None
    print(json.dumps({
        "ok": True,
        "checkpoint": str(ckpt),
        "iteration": cp.get("current_iter") if cp else None,
        "verified_from": str(ckpt) if cp else str(placed_def),
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
    scope_error = validate_scope(args)
    if scope_error:
        print(json.dumps({"ok": False, "reason": scope_error}))
        return 1
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
    record = last_gp_line(out) or last_ledger(workdir)
    candidate = parse_candidate_stdout(out)
    if rc != 0:
        print(json.dumps({"ok": False, "rc": rc, "stderr_tail": err[-2000:]}))
        return 1
    if not candidate and record.get("stop_reason") in ("target_reached", "overflow_target_miss"):
        terminal_cp = workdir / "pl/gp_session_checkpoint.json"
        if terminal_cp.exists():
            candidate = {
                "candidate_verdict": "left_better" if record.get("stop_reason") == "target_reached" else "right_better",
                "candidate_local_checkpoint": str(terminal_cp),
                "candidate_global_checkpoint": str(ckpt),
                "terminal_local": True,
            }
    for side, key in (("local", "candidate_local_checkpoint"), ("global", "candidate_global_checkpoint")):
        child_path = candidate.get(key)
        if child_path and Path(child_path).exists():
            try:
                child = json.loads(Path(child_path).read_text())
                candidate[f"{side}_metrics"] = {
                    "iteration": child.get("current_iter"),
                    "hpwl": child.get("prev_hpwl"),
                    "overflow": child.get("sum_overflow"),
                    "step_length": child.get("final_step_length"),
                    "route_util": child.get("final_route_util"),
                }
            except Exception:
                candidate[f"{side}_metrics"] = None
    state = update_state(workdir, {"last_candidate": candidate}, wrote_def=True)
    print(json.dumps({"ok": True, "state": state, "record": record, "candidate": candidate}, indent=2))
    return 0


def read_rudy_map(workdir: Path) -> tuple[list[list[float]], dict]:
    """Read the cached RUDY map written by observe kind=congestion_hotspots."""
    util_path = workdir / "rudy_util.csv"
    if not util_path.exists():
        raise ValueError("no rudy_util.csv in workdir; run observe kind=congestion_hotspots first (cached per DEF)")
    rows = []
    for line in util_path.read_text().splitlines():
        vals = [float(t) for t in line.split(",") if t.strip() != ""]
        if vals:
            rows.append(vals)
    summary_path = workdir / "congestion_result.json"
    summary = json.loads(summary_path.read_text()) if summary_path.exists() else {}
    return rows, summary


def congestion_regions(workdir: Path, top_bins: int, threshold: float) -> list[dict]:
    """Top overflowing bins of the TRUE verify-RUDY map, merged into rects."""
    rows, summary = read_rudy_map(workdir)
    region = summary.get("region")
    if not region or len(region) < 4:
        raise ValueError("congestion_result.json has no usable region")
    bin_x = int(summary.get("bin_cnt_x") or 64)
    bin_y = int(summary.get("bin_cnt_y") or 64)
    lx, ly, ux, uy = region[:4]
    size_x = (ux - lx) / bin_x
    size_y = (uy - ly) / bin_y
    bins = []
    for r, row in enumerate(rows):
        y = ly + (bin_y - 1 - r) * size_y
        for c, util in enumerate(row):
            if util <= threshold:
                continue
            x = lx + c * size_x
            bins.append({"row": r, "col": c, "utilization": util,
                         "llx": int(x), "lly": int(y),
                         "urx": int(min(x + size_x, ux)), "ury": int(min(y + size_y, uy))})
    bins.sort(key=lambda b: -b["utilization"])
    selected = bins[: max(1, top_bins)]
    merged: list[dict] = []
    used: set[int] = set()
    for i, b in enumerate(selected):
        if i in used:
            continue
        rect = [b["llx"], b["lly"], b["urx"], b["ury"]]
        changed = True
        while changed:
            changed = False
            for j, c in enumerate(selected):
                if j in used or i == j:
                    continue
                if not (rect[2] >= c["llx"] and rect[0] <= c["urx"] and rect[3] >= c["lly"] and rect[1] <= c["ury"]):
                    continue
                rect[0] = min(rect[0], c["llx"]); rect[1] = min(rect[1], c["lly"])
                rect[2] = max(rect[2], c["urx"]); rect[3] = max(rect[3], c["ury"])
                used.add(j); changed = True
        pad_x = int(size_x)
        pad_y = int(size_y)
        rect[0] = max(int(lx), rect[0] - pad_x); rect[1] = max(int(ly), rect[1] - pad_y)
        rect[2] = min(int(ux), rect[2] + pad_x); rect[3] = min(int(uy), rect[3] + pad_y)
        merged.append({"utilization": b["utilization"], "region": f"{rect[0]} {rect[1]} {rect[2]} {rect[3]}"})
    return merged


def cmd_local_congestion(args: argparse.Namespace) -> int:
    """Verify-RUDY-driven evacuation: pick the top overflow bins of the TRUE
    evaluator's cached map and run scope=region evacuations. This is the tool
    form of the loop the s1238 session proved (2.768 -> 2.207 RUDY max)."""
    workdir, case_root, input_def, config, foundry = require_context(args)
    targets: list[dict] = []
    if getattr(args, "scope", "region") == "instances":
        # Congestion-net cones: the nets crossing the hot bins (the demand
        # peaks are made by nets, not by the few cells inside the bin).
        nets_path = Path(workdir) / "congestion_nets.json"
        if not nets_path.exists():
            print(json.dumps({"ok": False, "reason": "no congestion_nets.json in workdir; run observe kind=congestion_hotspots first (cached per DEF)"}))
            return 1
        nets_data = json.loads(nets_path.read_text())
        nets = (nets_data.get("congestion_nets") or [])[: max(1, args.top_bins)]
        for net in nets:
            insts = [x for x in (net.get("instances") or []) if x]
            if insts:
                targets.append({"kind": "instances", "label": str(net.get("net")), "instances": insts})
        if not targets:
            print(json.dumps({"ok": False, "reason": "congestion_nets.json has no usable instance sets"}))
            return 1
    else:
        # The cached RUDY map must describe the CURRENT placement.def. A stale
        # map (written for an older placement) makes the evacuation target the
        # wrong region, which is exactly the path that collapsed placement.def
        # (def_hpwl 57687823) in wave7 aes. Refuse a stale map instead of
        # acting on it: re-observe congestion_hotspots first.
        util_path = Path(workdir) / "rudy_util.csv"
        placed_path = Path(workdir) / "placement.def"
        if util_path.exists() and placed_path.exists():
            if util_path.stat().st_mtime < placed_path.stat().st_mtime:
                print(json.dumps({"ok": False,
                                  "reason": "cached RUDY map predates placement.def (stale); run observe kind=congestion_hotspots first to refresh the map for the current placement"}))
                return 1
        try:
            regions = congestion_regions(workdir, args.top_bins, args.congestion_threshold)
        except ValueError as error:
            print(json.dumps({"ok": False, "reason": str(error)}))
            return 1
        if not regions:
            print(json.dumps({"ok": False, "reason": "no bins above the congestion threshold in the cached RUDY map"}))
            return 1
        targets = [{"kind": "region", "label": r["region"], "region": r["region"]} for r in regions]
    rounds = max(1, args.rounds)
    results = []
    ckpt = resolve_checkpoint(args, workdir)
    # Snapshot the pre-call checkpoint to a private copy: a failed advance can
    # rewrite the live checkpoint in place, and the rollback must restore the
    # exact pre-call state, not the diverged one.
    original_ckpt = workdir / "pl/rollback_checkpoint.json"
    import shutil as _shutil
    _shutil.copy2(ckpt, original_ckpt)
    def rollback():
        cmds = [
            f"placer_run_gp -mode restore -checkpoint {shlex.quote(str(original_ckpt))}",
            "placer_run_gp -mode accept",
        ]
        return run_ieda(workdir, case_root, foundry, config, input_def, cmds, def_save=True)

    for rnd in range(rounds):
        for target in targets:
            if target["kind"] == "instances":
                cmds = [
                    f"placer_run_gp -mode restore -checkpoint {shlex.quote(str(ckpt))}",
                    f"placer_run_gp -mode advance -iterations {args.iterations} -report_route_util 1 "
                    f"-scope instances -scope_instances {{{','.join(target['instances'])}}} "
                    f"-scope_halo_coeff {args.halo_coeff} -scope_halo_hops {args.halo_hops}",
                    "placer_run_gp -mode accept",
                ]
                retried = False
                rc, out, err = run_ieda(workdir, case_root, foundry, config, input_def, cmds, def_save=True)
                record = last_gp_line(out) or last_ledger(workdir)
                if rc != 0:
                    rc_rb, _out_rb, _err_rb = rollback()
                    ckpt = original_ckpt
                    results.append({"round": rnd + 1, "kind": "instances", "net": target["label"],
                                    "failed": True, "rolled_back": rc_rb == 0,
                                    "reason": "net-cone step failed"})
                    continue
                results.append({"round": rnd + 1, "kind": "instances", "net": target["label"],
                                "instance_count": len(target["instances"]),
                                "hpwl": record.get("hpwl"), "overflow": record.get("overflow"),
                                "route_util": record.get("route_util")})
                ckpt = workdir / "pl/gp_session_checkpoint.json"
                if not ckpt.exists():
                    ckpt = resolve_checkpoint(args, workdir)
                continue
            rect = target["region"]
            cmds = [
                f"placer_run_gp -mode restore -checkpoint {shlex.quote(str(ckpt))}",
                f"placer_run_gp -mode advance -iterations {args.iterations} -report_route_util 1 "
                f"-scope region -scope_region {{{rect}}} -scope_density_target {args.density_target} "
                f"-scope_density_ratio 1 -scope_halo_coeff {args.halo_coeff} -scope_halo_hops {args.halo_hops}",
                "placer_run_gp -mode accept",
            ]
            rc, out, err = run_ieda(workdir, case_root, foundry, config, input_def, cmds, def_save=True)
            retried = False
            if rc != 0 and "diverged" in (out + err):
                # One-RUDY-bin evacuations can trigger a local density-penalty
                # spike; retry once with a gentler target before giving up.
                cmds_gentle = [
                    f"placer_run_gp -mode restore -checkpoint {shlex.quote(str(ckpt))}",
                    f"placer_run_gp -mode advance -iterations {args.iterations} -report_route_util 1 "
                    f"-scope region -scope_region {{{rect}}} -scope_density_target 0.8 "
                    f"-scope_density_ratio 0.5 -scope_halo_coeff {args.halo_coeff} -scope_halo_hops 2",
                    "placer_run_gp -mode accept",
                ]
                rc, out, err = run_ieda(workdir, case_root, foundry, config, input_def, cmds_gentle, def_save=True)
                retried = True
            record = last_gp_line(out) or last_ledger(workdir)
            if rc != 0:
                # A diverged advance can rewrite the live checkpoint; restore
                # the clean pre-call state and continue with the remaining
                # regions instead of aborting the whole batch.
                rc_rb, _out_rb, _err_rb = rollback()
                ckpt = original_ckpt
                results.append({"round": rnd + 1, "kind": "region", "region": rect,
                                "failed": True, "rolled_back": rc_rb == 0,
                                "reason": "evacuation diverged" + (" (after gentle retry)" if retried else "")})
                continue
            results.append({"round": rnd + 1, "kind": "region", "region": rect,
                            "gentle_retry": retried,
                            "hpwl": record.get("hpwl"), "overflow": record.get("overflow"),
                            "route_util": record.get("route_util")})
            ckpt = workdir / "pl/gp_session_checkpoint.json"
            if not ckpt.exists():
                ckpt = resolve_checkpoint(args, workdir)
    state = update_state(workdir, record=record, wrote_def=True)
    lef = resolve_lef(foundry, getattr(args, "lef", None) or state.get("lef"))
    record["def_hpwl"] = def_hpwl_of(workdir / "placement.def", lef)
    if record.get("def_hpwl") is not None:
        record["def_hpwl_unit"] = "def"
    failed_steps = sum(1 for x in results if x.get("failed"))
    print(json.dumps({"ok": True, "rounds": rounds, "targets": len(targets),
                      "failed_steps": failed_steps,
                      "evacuations": results, "state": state, "record": record}, indent=2))
    return 0


def _ieda_daemon_env(case_root: Path, workdir: Path, foundry: Path) -> dict:
    env = os.environ.copy()
    sdc = case_root / f"{case_root.name}.sdc"
    if not sdc.exists():
        cands = sorted(case_root.glob("*.sdc"))
        sdc = cands[0] if cands else case_root / "default.sdc"
    env.update({
        "CONFIG_DIR": str(case_root / "iEDA_config"),
        "RESULT_DIR": str(workdir),
        "TCL_SCRIPT_DIR": str(case_root / "script"),
        "FOUNDRY_DIR": str(foundry),
        "SDC_FILE": str(sdc),
    })
    # The daemon must also carry the PDK env vars (TECH_LEF_PATH/LEF_PATH/LIB_PATH/
    # TAPCELL/ENDCAP) that ics55-style db_path_setting.tcl reads directly from the
    # environment. Without these the daemon-hosted ics55 runs fail with
    # "no such variable (read trace on ::env(TECH_LEF_PATH))".
    env.update(_derive_pdk_env(Path(foundry)))
    return env


def cmd_daemon(args: argparse.Namespace) -> int:
    """Persistent iEDA session served over a Unix socket at
    <workdir>/.ieda_daemon.sock. Each request is one JSON line
    {commands: [...], def_save: path}; the response is {rc, out, err}.
    run_ieda() prefers this socket so the db_init/def_init/init_pl fixed
    cost is paid once per workdir instead of once per run."""
    workdir, case_root, input_def, config, foundry = load_workdir_context(args)
    if not (case_root.exists() and input_def.exists() and config.exists() and foundry and foundry.exists()):
        print(json.dumps({"event": "init", "rc": 2, "reason": "daemon requires full workdir context; run start first"}), flush=True)
        return 2
    workdir.mkdir(parents=True, exist_ok=True)
    env = _ieda_daemon_env(case_root, workdir, foundry)
    init_cmds = [
        f"flow_init -config {shlex.quote(str(case_root / 'iEDA_config/flow_config.json'))}",
        f"db_init -config {shlex.quote(str(case_root / 'iEDA_config/db_default_config.json'))} -output_dir_path {shlex.quote(str(workdir))}",
        f"source {shlex.quote(str(case_root / 'script/DB_script/db_path_setting.tcl'))}",
        f"source {shlex.quote(str(case_root / 'script/DB_script/db_init_lib.tcl'))}",
        f"source {shlex.quote(str(case_root / 'script/DB_script/db_init_sdc.tcl'))}",
        f"source {shlex.quote(str(case_root / 'script/DB_script/db_init_lef.tcl'))}",
        f"def_init -path {shlex.quote(str(input_def))}",
        f"init_pl -config {shlex.quote(str(config))}",
    ]
    proc_holder: dict[str, subprocess.Popen | None] = {"p": None}

    def _spawn() -> subprocess.Popen:
        p = subprocess.Popen([str(IEDa_BIN)], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                             stderr=subprocess.STDOUT, text=True, bufsize=0, env=env, cwd=REPO_ROOT)
        proc_holder["p"] = p
        return p

    def _send(p: subprocess.Popen, cmds: list[str], marker: str) -> tuple[int, str]:
        try:
            p.stdin.write("\n".join(cmds) + f"\nputs {marker}\n")
            p.stdin.flush()
        except Exception as e:
            return -1, f"stdin write failed: {e}"
        out_lines: list[str] = []
        # R21 fix: iEDA can hang in pipe_read (no output) after a corrupted
        # in-memory state (e.g. start's embedded accept). A bare blocking
        # readline() then wedges the daemon forever AND the headless agent that
        # is waiting on it. Poll stdout with select() so an unresponsive iEDA
        # times out cleanly (caller then falls back to a fresh subprocess).
        deadline = time.monotonic() + 1800
        try:
            fd = p.stdout.fileno()
        except Exception:
            fd = None
        buf = ""
        while True:
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                return -1, "".join(out_lines) + "\n[daemon timeout: iEDA produced no output for 1800s]"
            if fd is not None:
                try:
                    r, _, _ = select.select([fd], [], [], min(remaining, 60))
                except (ValueError, OSError):
                    r = []
                if not r:
                    continue
            try:
                chunk = p.stdout.read1(65536) if hasattr(p.stdout, "read1") else p.stdout.read(65536)
            except Exception as e:
                return -1, "".join(out_lines) + f"\n[stdout read failed: {e}]"
            if not chunk:
                return -1, "".join(out_lines)
            buf += chunk
            while "\n" in buf:
                line, buf = buf.split("\n", 1)
                if marker in line:
                    return 0, "".join(out_lines)
                out_lines.append(line + "\n")

    def _restart() -> int:
        """Kill a wedged iEDA and respawn a fresh initialized session. Returns
        the init rc (0 = healthy again)."""
        p = proc_holder["p"]
        if p is not None:
            try:
                p.kill()
                p.wait(timeout=10)
            except Exception:
                pass
            proc_holder["p"] = None
        p = _spawn()
        rc_init, out_init = _send(p, init_cmds, "__INIT_DONE__")
        return rc_init

    proc = _spawn()
    rc_init, out_init = _send(proc, init_cmds, "__INIT_DONE__")
    if rc_init != 0:
        print(json.dumps({"event": "init", "rc": rc_init, "out_tail": out_init[-400:]}), flush=True)
        return 1
    sock_path = workdir / ".ieda_daemon.sock"
    if sock_path.exists():
        sock_path.unlink()
    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    server.bind(str(sock_path))
    server.listen(4)
    print(json.dumps({"event": "init", "rc": 0, "sock": str(sock_path)}), flush=True)
    try:
        while True:
            conn, _ = server.accept()
            try:
                conn.settimeout(1800)
                data = b""
                while True:
                    chunk = conn.recv(65536)
                    if not chunk:
                        break
                    data += chunk
                    if data.endswith(b"\n"):
                        break
                req = json.loads(data.decode())
                cmds = req.get("commands") or []
                def_path = req.get("def_save")
                all_cmds = list(cmds)
                if def_path:
                    all_cmds.append(f"def_save -path {shlex.quote(str(def_path))}")
                rc, out = _send(proc_holder["p"], all_cmds, "__CMD_DONE__")
                # R21 fix: when iEDA wedged (rc<0 from a timeout/pipe error), the
                # in-memory session is unusable. Respawn a fresh initialized one
                # so SUBSEQUENT requests still work, and return the error to this
                # caller so run_ieda falls back to a fresh subprocess for THIS
                # request (which re-runs def_init -> restore -> accept -> LG/DP).
                if rc < 0:
                    try:
                        _restart()
                    except Exception:
                        pass
                conn.sendall(json.dumps({"rc": rc, "out": out, "err": ""}).encode())
            except Exception as e:
                try: conn.sendall(json.dumps({"rc": -1, "out": "", "err": str(e)}).encode())
                except Exception: pass
            finally:
                conn.close()
    finally:
        server.close()
        p = proc_holder["p"]
        if p is not None:
            try:
                p.stdin.write("flow_exit\n"); p.stdin.flush()
                p.wait(timeout=30)
            except Exception:
                p.kill()
    return 0



def load_tree(workdir: Path) -> dict:
    p = workdir / TREE_PATH
    if p.exists():
        try:
            return json.loads(p.read_text())
        except Exception:
            pass
    return {"nodes": {}, "branches": [], "head": None}


def save_tree(workdir: Path, tree: dict) -> dict:
    (workdir / TREE_PATH).write_text(json.dumps(tree, indent=2))
    return tree


def _tree_ckpt_dir(workdir: Path) -> Path:
    d = workdir / "pl" / "gp_tree_ckpts"
    d.mkdir(parents=True, exist_ok=True)
    return d


def _immutable_copy(workdir: Path, node_id: str, src_path: str | None) -> str | None:
    """Copy a checkpoint into the tree's immutable store. Tree nodes must never
    point at live terminal pointers (gp_session_checkpoint.json is overwritten
    by candidate/accept), so every node owns a private copy."""
    if not src_path or not Path(src_path).exists():
        return None
    import shutil
    dst = _tree_ckpt_dir(workdir) / f"{node_id}.json"
    shutil.copy2(src_path, dst)
    return str(dst)


def register_node(workdir: Path, checkpoint_path: str | None, parent: str | None,
                  metrics: dict | None, decision_label: str, status: str = "alive",
                  set_head: bool = True) -> dict:
    """Append a checkpoint node to the durable tree and return it."""
    tree = load_tree(workdir)
    node_id = f"n{len(tree['nodes']) + 1}"
    node = {
        "id": node_id,
        "parent": parent,
        "checkpoint_path": checkpoint_path,
        "metrics": metrics or {},
        "decision_label": decision_label,
        "status": status,
    }
    tree["nodes"][node_id] = node
    if set_head:
        tree["head"] = node_id
    save_tree(workdir, tree)
    return node


def _cp_metrics(ckpt_path: str | None) -> dict:
    if not ckpt_path or not Path(ckpt_path).exists():
        return {}
    try:
        cp = json.loads(Path(ckpt_path).read_text())
        return {
            "iteration": cp.get("current_iter"),
            "hpwl": cp.get("prev_hpwl"),
            "overflow": cp.get("sum_overflow"),
            "route_util": cp.get("final_route_util"),
        }
    except Exception:
        return {}


def _root_workdir(workdir: Path) -> Path:
    """The delivery root a forked worktree must copy its placement.def back to.

    Scoring/accounting always reads the ROOT workdir's placement.def, not a
    fork's. A fork records its root in gp_agent_state.json; the original
    workdir is its own root. This is a plain delivery fact, not a decision.
    """
    state_path = workdir / "gp_agent_state.json"
    if state_path.exists():
        try:
            state = json.loads(state_path.read_text())
        except Exception:
            state = {}
        root = state.get("root_workdir")
        if root and Path(root) != workdir:
            return Path(root)
    return workdir


def _deliver_to_root(workdir: Path, def_path: Path | None = None) -> dict:
    """Copy the branch's accepted placement.def (and metrics) to the delivery
    root so scoring sees the result instead of a stale first-run DEF.

    Also carries the branch's logical head into the root state so the root never
    reports a stale latest_checkpoint/placement_def_checkpoint after a promote:
    a forked branch that is promoted is exactly the state the scoring layer
    should read. This is a delivery FACT, not a decision about which branch wins
    (the agent chooses what to promote; this layer only materialises it)."""
    import shutil
    root = _root_workdir(workdir)
    src_def = def_path or (workdir / "placement.def")
    out = {"root_workdir": str(root), "delivered_placement_def": None,
           "delivered_checkpoint": None, "delivered_def_is_root": False}
    if root == workdir:
        out["delivered_def_is_root"] = src_def.exists()
        return out
    if not src_def.exists():
        return out
    root.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src_def, root / "placement.def")
    out["delivered_placement_def"] = str(root / "placement.def")
    for name in ("gp_metrics_compare.json", "gp_full_metrics.json"):
        src = workdir / name
        if src.exists():
            shutil.copy2(src, root / name)
    # Carry the branch head checkpoint pointer so scoring reads the promoted
    # state, not a stale root-side pointer.
    st_path = workdir / "gp_agent_state.json"
    if st_path.exists():
        try:
            st = json.loads(st_path.read_text())
        except Exception:
            st = {}
        ckpt = st.get("latest_checkpoint")
        if ckpt:
            out["delivered_checkpoint"] = ckpt
            rstate = root / "gp_agent_state.json"
            rs = {}
            if rstate.exists():
                try: rs = json.loads(rstate.read_text())
                except Exception: rs = {}
            rs["latest_checkpoint"] = ckpt
            rs["workdir"] = str(root)
            rstate.write_text(json.dumps(rs, indent=2))
    return out


def _def_already_materialized(workdir: Path, ckpt: str | None) -> bool:
    """True when placement.def is already the materialization of ckpt.

    update_state records latest_checkpoint after every run that writes
    placement.def, so if the checkpoint being promoted/accepted is exactly that
    one, re-running restore+accept would re-materialize a DIFFERENT (often
    worse) DEF and clobber the good one. Use the on-disk DEF instead.
    """
    if not ckpt or not (workdir / "placement.def").exists():
        return False
    state_path = workdir / "gp_agent_state.json"
    if not state_path.exists():
        return False
    try:
        state = json.loads(state_path.read_text())
    except Exception:
        return False
    return state.get("placement_def_checkpoint") == ckpt


def cmd_tree(args: argparse.Namespace) -> int:
    """Read the durable branch tree (eval primitive: no side effects)."""
    workdir = Path(args.workdir)
    tree = load_tree(workdir)
    for nid, node in tree["nodes"].items():
        node["metrics_snapshot"] = _cp_metrics(node.get("checkpoint_path"))
    print(json.dumps({"ok": True, "workdir": str(workdir), "tree": tree}, indent=2))
    return 0


def cmd_apply(args: argparse.Namespace) -> int:
    """apply = run a candidate batch WITHOUT committing (no accept, no
    placement.def overwrite, branch head unchanged)."""
    scope_error = validate_scope(args)
    if scope_error:
        print(json.dumps({"ok": False, "reason": scope_error}))
        return 1
    if args.scope == "global":
        print(json.dumps({"ok": False, "reason": "apply (kCandidate) requires a local scope "
                          "(instances|region|hotspot|longnet|random); pass scope_region or "
                          "scope_instances, or use advance for the plain global baseline"}))
        return 1
    workdir, case_root, input_def, config, foundry = require_context(args)
    ckpt = resolve_checkpoint(args, workdir)
    if not ckpt or not Path(ckpt).exists():
        print(json.dumps({"ok": False, "reason": "no checkpoint; run start first"}))
        return 1

    # kCandidate OVERWRITES pl/gp_session_checkpoint.json (the live terminal
    # pointer) with the global control. Snapshot the parent into the tree's
    # immutable store BEFORE running so the head survives the clobber.
    tree = load_tree(workdir)
    parent_node_id = None
    for nid, node in tree["nodes"].items():
        if node.get("checkpoint_path") == str(ckpt):
            parent_node_id = nid
            break
    if parent_node_id is None:
        parent_node_id = f"n{len(tree['nodes']) + 1}"
        parent_imm = _immutable_copy(workdir, parent_node_id, ckpt)
        register_node(workdir, parent_imm, None, _cp_metrics(parent_imm),
                      "root", "alive", set_head=True)
    else:
        parent_imm = tree["nodes"][parent_node_id].get("checkpoint_path")

    cmds = [
        f"placer_run_gp -mode restore -checkpoint {shlex.quote(str(ckpt))}",
        f"placer_run_gp -mode candidate -iterations {args.iterations} "
        + " ".join(scope_args(args))
        + f" -candidate_overflow_penalty {args.overflow_penalty}",
    ]
    rc, out, err = run_ieda(workdir, case_root, foundry, config, input_def, cmds, def_save=False)
    record = last_gp_line(out) or last_ledger(workdir)
    candidate = parse_candidate_stdout(out)
    if rc != 0:
        print(json.dumps({"ok": False, "rc": rc, "stderr_tail": err[-2000:]}))
        return 1

    child_live = (candidate.get("candidate_local_checkpoint") if candidate else None)         or str(workdir / "pl/gp_candidate_local.json")
    if not Path(child_live).exists():
        print(json.dumps({"ok": False, "reason": f"candidate produced no local checkpoint: {child_live}"}))
        return 1

    child_id = f"n{len(load_tree(workdir)['nodes']) + 1}"
    child_imm = _immutable_copy(workdir, child_id, child_live)
    node = register_node(workdir, child_imm, parent_node_id, _cp_metrics(child_imm),
                         args.decision_label or f"apply:{args.scope}", "alive", set_head=False)

    # Re-point the resolved head at the parent's immutable copy (terminal was
    # clobbered). placement.def is untouched because no accept ran.
    state = json.loads((workdir / "gp_agent_state.json").read_text()) if (workdir / "gp_agent_state.json").exists() else {}
    state["latest_checkpoint"] = parent_imm
    state["workdir"] = str(workdir)
    (workdir / "gp_agent_state.json").write_text(json.dumps(state, indent=2))

    print(json.dumps({
        "ok": True, "node": node, "parent_node": parent_node_id,
        "parent_checkpoint": parent_imm, "child_checkpoint": child_imm,
        "record": record, "candidate": candidate,
    }, indent=2))
    return 0


def cmd_promote(args: argparse.Namespace) -> int:
    """promote = accept the given checkpoint as the branch head: restore+accept
    writes placement.def and the tree/state point at it. The accepted DEF is
    delivered back to the scoring root workdir."""
    workdir, case_root, input_def, config, foundry = require_context(args)
    ckpt = resolve_checkpoint(args, workdir)
    if not ckpt or not Path(ckpt).exists():
        print(json.dumps({"ok": False, "reason": "no checkpoint; run start first"}))
        return 1
    def_path = workdir / "placement.def"
    if _def_already_materialized(workdir, ckpt):
        reused = True
    else:
        reused = False
        cmds = [
            f"placer_run_gp -mode restore -checkpoint {shlex.quote(str(ckpt))}",
            "placer_run_gp -mode accept",
        ]
        rc, out, err = run_ieda(workdir, case_root, foundry, config, input_def, cmds, def_save=True)
        if rc != 0:
            print(json.dumps({"ok": False, "rc": rc, "stderr_tail": err[-2000:]}))
            return 1
    tree = load_tree(workdir)
    promoted_id = None
    for nid, node in tree["nodes"].items():
        if node.get("checkpoint_path") == str(ckpt):
            node["status"] = "promoted"
            tree["head"] = nid
            promoted_id = nid
    save_tree(workdir, tree)
    state = json.loads((workdir / "gp_agent_state.json").read_text()) if (workdir / "gp_agent_state.json").exists() else {}
    state["latest_checkpoint"] = str(ckpt)
    state["placement_def_checkpoint"] = str(ckpt)
    state["workdir"] = str(workdir)
    (workdir / "gp_agent_state.json").write_text(json.dumps(state, indent=2))
    delivery = _deliver_to_root(workdir, def_path)
    print(json.dumps({"ok": True, "promoted_node": promoted_id, "checkpoint": str(ckpt),
                      "placement_def": str(def_path), "reused_def": reused,
                      **delivery}, indent=2))
    return 0


def _parallel_start_one(args: argparse.Namespace, label: str, cand: dict) -> dict:
    """Run one candidate start in its own forked worktree (own process)."""
    import shutil
    workdir = Path(args.workdir)
    # Always fork from the DELIVERY ROOT (main workdir), never from a
    # parallel sub-worktree: the agent may call parallel again from a
    # candidate workdir (it sees the sub-worktree path in the result), and
    # nesting parallel/parallel/... would fork from a stale branch instead of
    # the main placement. root_workdir is the scored delivery point.
    try:
        st_src = json.loads((workdir / "gp_agent_state.json").read_text()) if (workdir / "gp_agent_state.json").exists() else {}
        root = Path(st_src.get("root_workdir") or str(workdir))
    except Exception:
        root = workdir
    dst = root / "parallel" / label
    dst.mkdir(parents=True, exist_ok=True)
    # fork context (NOT tree): parallel candidates are independent probes from
    # the same starting placement; the caller keeps the branch tree pristine.
    for name in ("gp_agent_state.json",):
        srcf = root / name
        if srcf.exists():
            shutil.copy2(srcf, dst / name)
    (dst / "pl").mkdir(parents=True, exist_ok=True)
    ckpt = resolve_checkpoint(args, root)
    if ckpt and Path(ckpt).exists():
        shutil.copy2(ckpt, dst / "pl" / "gp_session_checkpoint.json")
    st = json.loads((dst / "gp_agent_state.json").read_text()) if (dst / "gp_agent_state.json").exists() else {}
    st["workdir"] = str(dst)
    st["root_workdir"] = str(root)
    (dst / "gp_agent_state.json").write_text(json.dumps(st, indent=2))
    # build start argv from cand
    argv = [PY_EXE, str(REPO_ROOT / "benchmarks" / "flows" / "gp_agent.py"), "start",
            "--workdir", str(dst),
            "--case-root", str(args.case_root),
            "--input-def", str(args.input_def),
            "--config", str(args.config),
            "--foundry-dir", str(args.foundry_dir),
            "--iterations", str(cand.get("iterations", args.iterations)),
            "--seed", str(cand.get("seed", args.seed)),
            "--random-init", str(cand.get("random_init", args.random_init)),
            "--congestion-effort", str(cand.get("congestion_effort", -1)),
            "--target-density", str(cand.get("target_density", -1)),
            "--target-overflow", str(cand.get("target_overflow", -1)),
            "--timing", str(cand.get("timing", 0)),
            "--bin-cnt", str(cand.get("bin_cnt", -1)),
            "--report-route-util", "1",
    ]
    if args.lef:
        argv += ["--lef", args.lef]
    try:
        r = subprocess.run(argv, cwd=REPO_ROOT, capture_output=True, text=True, timeout=3600)
        parsed = None
        for candidate in (r.stdout.strip(), r.stdout.strip().splitlines()[-1] if r.stdout.strip() else ""):
            if not candidate:
                continue
            try:
                parsed = json.loads(candidate)
                break
            except Exception:
                continue
        if parsed is None:
            parsed = {"ok": False, "stderr_tail": (r.stderr or "")[-2000:]}
        rec = parsed.get("record") or {}
        # P2: surface the authoritative 64x64 verify RUDY (rudy_utilization_max / overflow
        # sum) in the parallel result, so the agent selects on the SAME scale it is graded on.
        # The solver-internal route_util (blurred/cap-normalized) can read far below the
        # 64x64 verify peak and mislead selection. Read the candidate worktree's cached
        # gp_metrics_compare.json if present (the start/verify may have refreshed it); do NOT
        # re-run the evaluator here (would be an expensive full verify per candidate).
        verify_rudy_max = verify_rsum = None
        egr_available = False
        egr_total_union = egr_max_union = egr_max_h = egr_max_v = egr_avg_union = None
        cmp_path = dst / "gp_metrics_compare.json"
        if cmp_path.exists():
            try:
                cdat = json.loads(cmp_path.read_text())
                candp = (cdat.get("placements") or {}).get("candidate") or {}
                cdens = candp.get("density") or {}
                crudy = cdens.get("rudy_utilization_max")
                vrsum = cdens.get("rudy_overflow_util_sum")
                verify_rudy_max = round(float(crudy), 4) if crudy is not None else None
                verify_rsum = round(float(vrsum), 4) if vrsum is not None else None
                # 真实 EGR（权威拥塞信号）：候选 worktree 若有已跑的 compare json 就复用
                if cdens.get("egr_max_overflow_union") is not None:
                    egr_available = True
                    egr_total_union = cdens.get("egr_total_overflow_union")
                    egr_max_union = cdens.get("egr_max_overflow_union")
                    egr_max_h = cdens.get("egr_max_overflow_horizontal")
                    egr_max_v = cdens.get("egr_max_overflow_vertical")
                    egr_avg_union = cdens.get("egr_avg_overflow_union")
            except Exception:
                verify_rudy_max = verify_rsum = None
        return {"label": label, "ok": bool(parsed.get("ok")),
                "def_hpwl": rec.get("def_hpwl"), "route_util": rec.get("route_util"),
                "overflow": rec.get("overflow"), "workdir": str(dst),
                "verify_rudy_max": verify_rudy_max, "verify_rsum": verify_rsum,
                "egr_available": egr_available,
                "egr_total_union": egr_total_union, "egr_max_union": egr_max_union,
                "egr_max_h": egr_max_h, "egr_max_v": egr_max_v, "egr_avg_union": egr_avg_union,
                "reason": parsed.get("reason") or parsed.get("stderr_tail")}
    except Exception as e:
        return {"label": label, "ok": False, "workdir": str(dst), "reason": str(e)}


def cmd_parallel(args: argparse.Namespace) -> int:
    """Parallel candidate probe: fork N independent worktrees from the
    current placement and run one start per candidate concurrently. Returns
    one record per label. Mechanism only - the agent supplies the candidate
    set and reads the results."""
    workdir, case_root, input_def, config, foundry = require_context(args)
    if not getattr(args, "foundry_dir", None):
        args.foundry_dir = str(foundry)
    # candidates come from --candidates JSON string or stdin
    cand_raw = getattr(args, "candidates", "") or ""
    if not cand_raw.strip():
        cand_raw = sys.stdin.read()
    try:
        candidates = json.loads(cand_raw)
    except Exception as e:
        print(json.dumps({"ok": False, "reason": f"candidates JSON parse failed: {e}"}))
        return 1
    if not isinstance(candidates, list) or not candidates:
        print(json.dumps({"ok": False, "reason": "candidates must be a non-empty list"}))
        return 1
    results = []
    with ThreadPoolExecutor(max_workers=min(len(candidates), 16)) as pool:
        futures = [pool.submit(_parallel_start_one, args, c.get("label") or f"c{i}", c)
                   for i, c in enumerate(candidates)]
        for f in futures:
            results.append(f.result())
    # Sort by the authoritative EGR union max first (the iEDA-vs-Innovus congestion
    # grade), then 64x64 verify RUDY peak, then solver-internal route_util. sort_key
    # tells the agent which scale decided the order so it never trusts route_util
    # when EGR is available.
    def _cand_key(r):
        if r.get("egr_available") and r.get("egr_max_union") is not None:
            return (0, float(r["egr_max_union"]), "egr")
        v = r.get("verify_rudy_max")
        if v is not None:
            return (1, float(v), "rudy")
        ru = r.get("route_util")
        return (2, float(ru) if ru is not None else float("inf"), "route_util")
    results.sort(key=lambda r: _cand_key(r)[:2])
    for r in results:
        r["sort_key"] = _cand_key(r)[2]
    print(json.dumps({"ok": True, "count": len(results), "results": results}, indent=2))
    return 0


def cmd_fork(args: argparse.Namespace) -> int:
    """fork = copy a checkpoint to a NEW workdir as an independent branch root."""
    src_workdir = Path(args.workdir)
    ckpt = resolve_checkpoint(args, src_workdir)
    if not ckpt or not Path(ckpt).exists():
        print(json.dumps({"ok": False, "reason": "no checkpoint to fork"}))
        return 1
    dst_workdir = Path(args.fork_target)
    if dst_workdir.exists() and any(dst_workdir.iterdir()):
        print(json.dumps({"ok": False, "reason": f"fork target {dst_workdir} already exists and is non-empty"}))
        return 1
    import shutil
    dst_workdir.mkdir(parents=True, exist_ok=True)
    # Copy only the context state (case_root/input_def/config/foundry/lef) and
    # NOT gp_tree.json: a fork is a NEW independent branch root, so the target
    # tree must start fresh with just the forked node.
    src_state = src_workdir / "gp_agent_state.json"
    if src_state.exists():
        shutil.copy2(src_state, dst_workdir / "gp_agent_state.json")
    (dst_workdir / "pl").mkdir(parents=True, exist_ok=True)
    terminal = dst_workdir / "pl" / "gp_session_checkpoint.json"
    shutil.copy2(ckpt, terminal)
    root_imm = _immutable_copy(dst_workdir, "n1", terminal)
    register_node(dst_workdir, root_imm, None, _cp_metrics(root_imm),
                  args.decision_label or "fork", "alive", set_head=True)
    # latest_checkpoint must point at the immutable root so a later apply
    # resolves and finds this exact node (the live terminal is clobbered by
    # the first candidate in the fork).
    state = json.loads((dst_workdir / "gp_agent_state.json").read_text()) if (dst_workdir / "gp_agent_state.json").exists() else {}
    state["latest_checkpoint"] = root_imm
    state["workdir"] = str(dst_workdir)
    # Track the delivery root so a later promote/accept copies the branch's
    # placement.def back to the workdir scoring actually reads. A fork inherits
    # its source's root; the original workdir is its own root.
    src_state_obj = json.loads((src_workdir / "gp_agent_state.json").read_text()) if (src_workdir / "gp_agent_state.json").exists() else {}
    state["root_workdir"] = src_state_obj.get("root_workdir") or str(src_workdir)
    (dst_workdir / "gp_agent_state.json").write_text(json.dumps(state, indent=2))
    print(json.dumps({"ok": True, "forked_workdir": str(dst_workdir),
                      "checkpoint": root_imm, "source_checkpoint": str(ckpt)}, indent=2))
    return 0


def cmd_prune(args: argparse.Namespace) -> int:
    """prune = mark a branch dead (keep metrics for audit, drop the workdir)."""
    workdir = Path(args.workdir)
    tree = load_tree(workdir)
    pruned = []
    if args.prune_node:
        if args.prune_node in tree["nodes"]:
            tree["nodes"][args.prune_node]["status"] = "pruned"
            pruned.append(args.prune_node)
    else:
        for nid, node in tree["nodes"].items():
            if node.get("status") == "alive":
                node["status"] = "pruned"
                pruned.append(nid)
    save_tree(workdir, tree)
    print(json.dumps({"ok": True, "pruned_nodes": pruned,
                      "note": "workdir kept for metrics audit; nodes marked pruned"}, indent=2))
    return 0


def cmd_restore(args: argparse.Namespace) -> int:
    """rollback = point the head at ANY ancestor checkpoint without running iEDA."""
    workdir = Path(args.workdir)
    ckpt = resolve_checkpoint(args, workdir)
    if not ckpt or not Path(ckpt).exists():
        print(json.dumps({"ok": False, "reason": "no checkpoint"}))
        return 1
    state = json.loads((workdir / "gp_agent_state.json").read_text()) if (workdir / "gp_agent_state.json").exists() else {}
    state["latest_checkpoint"] = str(ckpt)
    state["workdir"] = str(workdir)
    (workdir / "gp_agent_state.json").write_text(json.dumps(state, indent=2))
    tree = load_tree(workdir)
    for nid, node in tree["nodes"].items():
        if node.get("checkpoint_path") == str(ckpt):
            tree["head"] = nid
    save_tree(workdir, tree)
    print(json.dumps({"ok": True, "checkpoint": str(ckpt), "head": tree.get("head")}, indent=2))
    return 0
def cmd_accept(args: argparse.Namespace) -> int:
    workdir, case_root, input_def, config, foundry = require_context(args)
    ckpt = resolve_checkpoint(args, workdir)
    if not ckpt or not Path(ckpt).exists():
        print(json.dumps({"ok": False, "reason": "no checkpoint; run start first"}))
        return 1
    # Accept the session-best checkpoint by default: agents repeatedly advance
    # past the best placement and then accept the regressed head. Unless the
    # caller pins --checkpoint explicitly, deliver best_checkpoint so the final
    # DEF is the best DEF-level HPWL this session ever produced.
    if not args.checkpoint:
        state = json.loads((workdir / "gp_agent_state.json").read_text()) if (workdir / "gp_agent_state.json").exists() else {}
        best = state.get("best_checkpoint")
        if best and Path(best).exists() and best != ckpt:
            ckpt = best
    def_path = workdir / "placement.def"
    if _def_already_materialized(workdir, ckpt):
        reused = True
    else:
        reused = False
        cmds = [
            f"placer_run_gp -mode restore -checkpoint {shlex.quote(str(ckpt))}",
            "placer_run_gp -mode accept",
        ]
        rc, out, err = run_ieda(workdir, case_root, foundry, config, input_def, cmds, def_save=True)
        if rc != 0:
            print(json.dumps({"ok": False, "rc": rc, "stderr_tail": err[-2000:]}))
            return 1
    state = update_state(workdir, wrote_def=True)
    # 改造三：交付即合法。accept 提交的 GP 结果是未合法化的（cell 可重叠），
    # 直接交付会让 EGR/HPWL 假低。这里检测并自动补 LG+DP，保证交付 DEF
    # 一定是 site 对齐、可公平评分的合法布局。
    legalized = None
    try:
        from gp_metrics_compare import check_legalized
        leg = check_legalized(def_path)
        legalized = leg["legalized"]
        if not legalized:
            cmds_legal = ["placer_run_lg", "placer_run_dp"]
            rc_lg, out_lg, err_lg = run_ieda(workdir, case_root, foundry, config, def_path, cmds_legal, def_save=True)
            if rc_lg == 0:
                legalized = check_legalized(def_path)["legalized"]
            else:
                legalized = False
            # R21 fix: when the daemon-hosted iEDA session's in-memory state was
            # left corrupted by start's embedded accept (random_init=1 + a reset
            # anchor), placer_run_lg can re-export the INPUT def (77 PLACED) and
            # check_legalized keeps returning false. Fall back to a FRESH
            # subprocess that re-runs def_init -> restore checkpoint -> accept ->
            # LG -> DP so the delivered DEF is the checkpoint's placement, not the
            # stale input layout.
            if not legalized:
                prev_no_daemon = os.environ.get("GP_AGENT_NO_DAEMON")
                os.environ["GP_AGENT_NO_DAEMON"] = "1"
                try:
                    cmds_fresh = [
                        f"placer_run_gp -mode restore -checkpoint {shlex.quote(str(ckpt))}",
                        "placer_run_gp -mode accept",
                        "placer_run_lg",
                        "placer_run_dp",
                    ]
                    rc_f, out_f, err_f = run_ieda(workdir, case_root, foundry, config, input_def, cmds_fresh, def_save=True)
                    if rc_f == 0:
                        legalized = check_legalized(def_path)["legalized"]
                finally:
                    if prev_no_daemon is None:
                        os.environ.pop("GP_AGENT_NO_DAEMON", None)
                    else:
                        os.environ["GP_AGENT_NO_DAEMON"] = prev_no_daemon
    except Exception:
        legalized = None
    delivery = _deliver_to_root(workdir, def_path)
    print(json.dumps({"ok": True, "state": state, "reused_def": reused,
                      "legalized": legalized, **delivery}, indent=2))
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


def cmd_apply_anchor(args: argparse.Namespace) -> int:
    """Re-anchor in-scope Active cells toward the session-anchor coordinates
    (the input-DEF positions captured at session start): movement is scaled by
    (1 - scope_anchor_strength) around those positions. The session's own
    evidence asked for this: pulling hot-region cells back toward the Innovus
    positions is the most targeted fix for sub-1.0 RUDY peaks."""
    scope_error = validate_scope(args)
    if scope_error:
        print(json.dumps({"ok": False, "reason": scope_error}))
        return 1
    strength = args.scope_anchor_strength
    if not (0.0 < strength <= 1.0):
        print(json.dumps({"ok": False, "reason": "scope_anchor_strength must be in (0,1]"}))
        return 1
    workdir, case_root, input_def, config, foundry = require_context(args)
    ckpt = resolve_checkpoint(args, workdir)
    if not ckpt or not Path(ckpt).exists():
        print(json.dumps({"ok": False, "reason": "no checkpoint; run start first"}))
        return 1
    original_ckpt = workdir / "pl/rollback_checkpoint.json"
    import shutil as _shutil
    _shutil.copy2(ckpt, original_ckpt)
    cmds = [
        f"placer_run_gp -mode restore -checkpoint {shlex.quote(str(ckpt))}",
        f"placer_run_gp -mode advance -iterations {args.iterations} -report_route_util 1 "
        + " ".join(scope_args(args)),
        "placer_run_gp -mode accept",
    ]
    rc, out, err = run_ieda(workdir, case_root, foundry, config, input_def, cmds, def_save=True)
    record = last_gp_line(out) or last_ledger(workdir)
    if rc != 0:
        cmds_rb = [
            f"placer_run_gp -mode restore -checkpoint {shlex.quote(str(original_ckpt))}",
            "placer_run_gp -mode accept",
        ]
        rc_rb, _out_rb, _err_rb = run_ieda(workdir, case_root, foundry, config, input_def, cmds_rb, def_save=True)
        print(json.dumps({"ok": False, "rc": rc, "rolled_back": rc_rb == 0,
                          "reason": "apply_anchor diverged; workdir rolled back to the pre-call checkpoint",
                          "stderr_tail": err[-1200:]}))
        return 1
    state = update_state(workdir, record=record, wrote_def=True)
    def_hpwl = record.get("def_hpwl")
    if def_hpwl is None:
        lef = resolve_lef(foundry, input_def)
        def_hpwl = def_hpwl_of(workdir / "placement.def", lef)
    print(json.dumps({"ok": True, "state": state, "record": record,
                      "def_hpwl": def_hpwl, "anchor_strength": strength}, indent=2))
    return 0


def _run_lg_dp(args: argparse.Namespace, stage: str) -> int:
    """Run legalization (placer_run_lg) or detailed placement (placer_run_dp)
    on the current checkpoint placement, then accept + def_save. Stage must be
    'lg' or 'dp'. iEDA runs these as standalone commands AFTER a GP session;
    we restore the GP checkpoint, run the stage, accept and export."""
    workdir = Path(args.workdir)
    case_root = Path(args.case_root)
    # input_def / config may be absent for lg/dp (runtime.agent only injects them
    # on start); fall back to the session state / derived / default config.
    input_def_p = getattr(args, "input_def", None)
    if not input_def_p:
        st = json.loads((workdir / "gp_agent_state.json").read_text()) if (workdir / "gp_agent_state.json").exists() else {}
        input_def_p = st.get("input_def") or str(case_root / "result" / "iFP_result.def")
    input_def = Path(input_def_p)
    config_p = getattr(args, "config", None)
    if not config_p:
        for cand in (workdir / "pl_derived_config.json", workdir / "iEDA_config" / "pl_default_config.json",
                     case_root / "iEDA_config" / "pl_default_config.json"):
            if cand.exists():
                config_p = str(cand); break
    config = Path(config_p or (case_root / "iEDA_config" / "pl_default_config.json"))
    foundry = Path(args.foundry_dir)
    if not foundry.exists():
        print(json.dumps({"ok": False, "reason": "cmd_' + stage + ': --foundry-dir not found"}))
        return 1
    ckpt = resolve_checkpoint(args, workdir)
    if not ckpt or not Path(ckpt).exists():
        print(json.dumps({"ok": False, "reason": "no checkpoint; run GP start first"}))
        return 1
    mode_cmd = 'placer_run_lg' if stage == 'lg' else 'placer_run_dp'
    # DP: restoring a TIMING checkpoint runs NesterovPlace::initTimingAnnotation()
    # and aborts (rc=-6). DP does not need the GP timing checkpoint; instead we
    # def_init the CURRENT placement.def + init_pl + placer_run_dp + def_save so
    # DP refines the existing placement directly. LG can keep the restore path.
    if stage == 'dp' and (workdir / 'placement.def').exists():
        # PLAPI runDP() calls checkLegality() BEFORE runDetailPlace(); the
        # incoming placement (GP result) is not yet aligned to row/orient, so
        # checkLegality fails with power_alignment before DP even runs. Run LG
        # first (legalizer aligns row + orient), THEN detail placement.
        cmds = ['placer_run_lg', 'placer_run_dp']
        rc, out, err = run_ieda(workdir, case_root, foundry, config, workdir / 'placement.def', cmds, def_save=True)
    else:
        cmd = [
            f"placer_run_gp -mode restore -checkpoint {shlex.quote(str(ckpt))}",
            mode_cmd,
        ]
        rc, out, err = run_ieda(workdir, case_root, foundry, config, input_def, cmd, def_save=True)
    record = last_gp_line(out) or last_ledger(workdir)
    if rc != 0:
        print(json.dumps({"ok": False, "rc": rc, "stderr_tail": err[-2000:]}))
        return 1
    state = update_state(workdir, wrote_def=True)
    lef = resolve_lef(foundry, getattr(args, "lef", None) or state.get("lef"))
    if lef is not None and state.get("lef") != str(lef):
        state = update_state(workdir, {"lef": str(lef)})
    record["def_hpwl"] = def_hpwl_of(workdir / "placement.def", lef)
    if record.get("def_hpwl") is not None:
        record["def_hpwl_unit"] = "def"
    print(json.dumps({"ok": True, "state": state, "record": record}, indent=2))
    return 0


def cmd_lg(args: argparse.Namespace) -> int:
    return _run_lg_dp(args, "lg")


def cmd_dp(args: argparse.Namespace) -> int:
    return _run_lg_dp(args, "dp")

def cmd_egr(args: argparse.Namespace) -> int:
    """Single-DEF authoritative EGR (iRT trial-route overflow) with the
    legalization gate. This is the cheap per-step feedback signal for the agent:
    read the REAL router overflow (union + H/V) instead of the solver-internal
    route_util. Unlegalized DEFs are refused (overlapping cells fake a low EGR).
    """
    from gp_metrics_compare import density, check_legalized
    workdir = Path(args.workdir)
    state = json.loads((workdir / "gp_agent_state.json").read_text()) if (workdir / "gp_agent_state.json").exists() else {}
    def_path = Path(args.def_path) if getattr(args, "def_path", None) else workdir / "placement.def"
    case_root = Path(args.case_root or state.get("case_root"))
    foundry = Path(args.foundry_dir or state.get("foundry_dir")) if (args.foundry_dir or state.get("foundry_dir")) else None
    if not case_root.exists() or not foundry or not foundry.exists():
        print(json.dumps({"ok": False, "reason": "cmd_egr: missing case_root/foundry_dir (run start first)"}))
        return 1
    leg = check_legalized(def_path)
    if not leg["legalized"]:
        print(json.dumps({"ok": False, "legalized": False, "reason": leg.get("reason"),
                          "def": str(def_path), "sample": leg.get("sample", [])}, indent=2))
        return 1
    d = density(def_path, case_root, 200, foundry, "egr", 64)
    out = {"ok": bool(d.get("ok")), "legalized": True, "def": str(def_path),
           "egr_valid": bool(d.get("egr_valid"))}
    for k in ("egr_total_overflow_horizontal", "egr_total_overflow_vertical", "egr_total_overflow_union",
              "egr_max_overflow_horizontal", "egr_max_overflow_vertical", "egr_max_overflow_union",
              "egr_avg_overflow_horizontal", "egr_avg_overflow_vertical", "egr_avg_overflow_union"):
        if d.get(k) is not None:
            out[k] = d[k]
    if not out["ok"]:
        out["reason"] = d.get("reason") or d.get("congestion_reason")
    print(json.dumps(out, indent=2))
    return 0 if out["ok"] else 1


PRIORS_PATH = REPO_ROOT / "benchmarks/flows/deepseek_harness/case_priors.json"
KNOWLEDGE_PATH = REPO_ROOT / "benchmarks/flows/deepseek_harness/knowledge.json"


def load_knowledge() -> dict:
    try:
        return json.loads(KNOWLEDGE_PATH.read_text())
    except Exception:
        return {"rules": [], "facts": {}}


def _belief_update(rule: dict, outcome: str, evidence: dict) -> dict:
    """拉普拉斯平滑信念更新（knowledge_schema.json 的 update_rules）。

    R22 跨设计去重：evidence 按 distinct case(design) 计数。同一设计反复
    confirm 只算 1 个独立证据——单设计重复是 pseudo-replication，不是独立验证，
    会虚假抬高置信度（旧 ce2 规则 3 个 confirm 全来自 s38584_sky130_a 就是反例）。
    只有 >=2 个不同设计 confirm 才 status=confirmed；1 个设计只能 partial
    （fact 级，尚未达到"可迁移知识"门槛）。
    confidence = distinct_confirm / (distinct_confirm + distinct_falsify + 1)。
    <0.2 标 dead（不删，留审计）。
    """
    rule.setdefault("evidence", []).append(evidence)
    # R23b 矛盾证据排除：同一 design 对同一 rule 若同时出现 confirm 与 falsify
    # （agent 误写 evidence 类型导致），该 design 不进入任何计数——宁缺毋滥，
    # 避免一条错误证据同时污染 c 与 f 两侧置信度。只认无争议 design。
    per_case: dict = {}
    for e in rule["evidence"]:
        d = e.get("case") or "?"
        if e.get("outcome") in ("confirm", "falsify"):
            per_case.setdefault(d, set()).add(e.get("outcome"))
        # falsify_scope_out 不进入任何计数：它是"该规则不适用于此 case"的边界证据
    confirm_designs = set()
    falsify_designs = set()
    for d, outs in per_case.items():
        if "confirm" in outs and "falsify" in outs:
            continue  # 矛盾证据，排除
        if "confirm" in outs:
            confirm_designs.add(d)
        else:
            falsify_designs.add(d)
    c = len(confirm_designs)
    f = len(falsify_designs)
    rule["confidence"] = round(c / (c + f + 1), 4)
    rule["confirm_designs"] = sorted(confirm_designs)
    rule["falsify_designs"] = sorted(falsify_designs)
    if f == 0:
        # 跨设计门槛：同 pdk >=2 个不同设计确认才是知识；单设计只是 fact
        rule["status"] = "confirmed" if c >= 2 else ("partial" if c == 1 else "unverified")
    else:
        rule["status"] = "narrowed" if rule["confidence"] >= 0.2 else "dead"
    rule["updated_at"] = __import__("datetime").datetime.utcnow().isoformat() + "Z"
    return rule


def load_case_priors() -> dict:
    try:
        return json.loads(PRIORS_PATH.read_text())
    except Exception:
        return {"buckets": {}, "negative_rules": [], "per_design": {}}


def cell_count_of(def_path: Path) -> int | None:
    try:
        text = Path(def_path).read_text(errors="ignore")
        m = re.search(r"COMPONENTS\s+(\d+)\s*;", text)
        return int(m.group(1)) if m else None
    except Exception:
        return None


def _size_bucket(cells: int | None) -> str:
    # R23 精细规模桶：sky130 的 ce2/ce3 效应在 1k/3k/15k 处不连续，
    # 粗桶 small/mid/big 会把 1k-3k 与 5k-15k 混为一桶，导致规则在桶内
    # 被 <3k 设计证伪而永远无法 confirmed。拆成 4 桶：
    #   small     < 1000
    #   mid_small 1000..2999  (ce2 收益窗口，HPWL 代价≈0，ce3 无效)
    #   mid_large 3000..14999 (ce3>ce2 窗口，HPWL 代价随 cells 上升)
    #   big       >= 15000
    if cells is None:
        return "mid_large"
    if cells < 1000:
        return "small"
    if cells < 3000:
        return "mid_small"
    if cells < 15000:
        return "mid_large"
    return "big"


def _pdk_of(foundry_dir: Path | None) -> str:
    if not foundry_dir:
        return "unknown"
    name = str(foundry_dir).lower()
    for pdk in ("sky130", "nangate45", "ics55", "ihp130"):
        if pdk in name:
            return pdk
    return "unknown"


def _parse_tradeoff(raw: str) -> dict:
    """解析 tradeoff 三维字段。格式：'direction|delta'（如 'down|-4~10%'）或纯 delta（如 '-4%'）。
    返回 {direction, delta}，缺 direction 时按 delta 首字符推断（'-'=down, '+'=up, 否则 flat）。"""
    raw = (raw or "").strip()
    if not raw:
        return {"direction": "", "delta": ""}
    if "|" in raw:
        direction, _, delta = raw.partition("|")
        return {"direction": direction.strip(), "delta": delta.strip()}
    # 纯 delta：按首字符推断方向
    d = raw
    direction = ""
    if d.startswith("-"):
        direction = "down"
    elif d.startswith("+"):
        direction = "up"
    elif d.startswith("~") or d.startswith("0") or "flat" in d.lower() or "不变" in d or "基本" in d:
        direction = "flat"
    return {"direction": direction, "delta": d}


def cmd_prior(args: argparse.Namespace) -> int:
    """Read/update the two-layer knowledge base.

    Layer 1 (rules, knowledge.json): falsifiable hypotheses with confidence/scope.
    Layer 2 (facts, knowledge.json + case_priors.json per_design): per-design audit.

    kind=read : bucket priors + falsifiable rules + per-design facts.
    kind=update: four operations via --evidence:
      (default)           append a free-text note to per_design facts
      --evidence hypothesis --note "..."   add a new falsifiable rule (unverified)
      --evidence confirm   --rule-id <id>  belief update: confidence up
      --evidence falsify   --rule-id <id> [--note "why"] [--scope-pdk p] [--scope-cells c]
                                           belief update: narrow scope + confidence down
    """
    priors = load_case_priors()
    knowledge = load_knowledge()
    workdir = Path(args.workdir)
    state = json.loads((workdir / "gp_agent_state.json").read_text()) if (workdir / "gp_agent_state.json").exists() else {}
    foundry = Path(args.foundry_dir or state.get("foundry_dir")) if (args.foundry_dir or state.get("foundry_dir")) else None
    _input_def_raw = getattr(args, "input_def", None) or state.get("input_def")
    input_def = Path(_input_def_raw) if _input_def_raw else None
    design = getattr(args, "design", None) or state.get("design") or workdir.name
    pdk = getattr(args, "pdk", None) or _pdk_of(foundry)
    _def_path_raw = getattr(args, "def_path", None) or input_def
    cells = cell_count_of(Path(_def_path_raw) if _def_path_raw else None)
    bucket = f"{pdk}_{_size_bucket(cells)}"
    import datetime as _dt
    now = _dt.datetime.utcnow().isoformat() + "Z"

    if getattr(args, "kind", "read") == "update":
        evidence = (getattr(args, "evidence", "") or "").strip()
        note = (getattr(args, "note", "") or "").strip()
        rule_id = (getattr(args, "rule_id", "") or "").strip()

        # 操作 1: hypothesis（新增可证伪规则）
        if evidence == "hypothesis":
            if not note:
                print(json.dumps({"ok": False, "reason": "hypothesis requires --note (假设文本)"}))
                return 1
            size_bucket = getattr(args, "scope_cells", "") or _size_bucket(cells)
            rule = {
                "id": "rule_" + now.replace("-", "").replace(":", "").replace(".", ""),
                "hypothesis": note,
                # 新形态：物理决策层（condition + decision + tradeoff + tool_mapping + falsify_if）
                "condition": {
                    "pdk": getattr(args, "scope_pdk", "") or pdk or None,
                    "size_bucket": size_bucket or None,
                    "cells_range": getattr(args, "scope_physical", "") or None,
                    "bottleneck": {
                        "metric": getattr(args, "scope_bottleneck", "") or None,
                        "source": getattr(args, "scope_source", "") or None,
                        "subclass": getattr(args, "scope_subclass", "") or None,
                    },
                    "observable": getattr(args, "observable", "") or "",
                },
                "decision": {
                    "do": getattr(args, "decision_do", "") or "",
                    "mechanism": getattr(args, "decision_mechanism", "") or "",
                    "category": getattr(args, "action_category", "") or None,
                    "subclass": getattr(args, "action_subclass", "") or None,
                },
                "tradeoff": {
                    "egr": _parse_tradeoff(getattr(args, "tradeoff_egr", "")),
                    "hpwl": _parse_tradeoff(getattr(args, "tradeoff_hpwl", "")),
                    "timing": _parse_tradeoff(getattr(args, "tradeoff_timing", "")),
                },
                "tool_mapping": {
                    "ieda": getattr(args, "tool_mapping", "") or "",
                },
                "prediction": getattr(args, "prediction", "") or "",
                "falsify_if": getattr(args, "falsify_if", "") or "",
                # 旧字段（兼容 + 降级）：action 降级为 tool_mapping 的旋钮名，effect/cost 由 tradeoff 回填
                "action": getattr(args, "action", "") or getattr(args, "tool_mapping", "") or "",
                "scope": {
                    "pdk": getattr(args, "scope_pdk", "") or pdk or None,
                    "cells": size_bucket,
                    "bottleneck": getattr(args, "scope_bottleneck", "") or None,
                    "physical": getattr(args, "scope_physical", "") or None,
                    "domain": "placement",
                },
                "effect": {
                    "metric": getattr(args, "effect_metric", "") or "egr",
                    "direction": getattr(args, "effect_direction", "") or _parse_tradeoff(getattr(args, "tradeoff_egr", "")).get("direction", ""),
                    "delta": getattr(args, "effect_delta", "") or _parse_tradeoff(getattr(args, "tradeoff_egr", "")).get("delta", ""),
                },
                "cost": {
                    "metric": getattr(args, "cost_metric", "") or "hpwl",
                    "direction": getattr(args, "cost_direction", "") or _parse_tradeoff(getattr(args, "tradeoff_hpwl", "")).get("direction", ""),
                    "delta": getattr(args, "cost_delta", "") or _parse_tradeoff(getattr(args, "tradeoff_hpwl", "")).get("delta", ""),
                },
                "guidance": getattr(args, "guidance", "") or "",
                "evidence": [],
                "confidence": 0.0,
                "status": "unverified",
                "kind": "quantitative" if (getattr(args, "effect_delta", "") or getattr(args, "tradeoff_egr", "") or "").strip() else "qualitative",
                "created_at": now,
                "updated_at": now,
            }
            knowledge.setdefault("rules", []).append(rule)
            KNOWLEDGE_PATH.write_text(json.dumps(knowledge, indent=2, ensure_ascii=False))
            print(json.dumps({"ok": True, "op": "hypothesis", "rule": rule}, indent=2, ensure_ascii=False))
            return 0

        # 操作 2/3: confirm/falsify 信念更新
        if evidence in ("confirm", "falsify"):
            if not rule_id:
                print(json.dumps({"ok": False, "reason": evidence + " requires --rule-id"}))
                return 1
            rule = next((r for r in knowledge.get("rules", []) if r["id"] == rule_id), None)
            if not rule:
                # R23 legacy-id remap：旧粗桶 id（如 ce2_... 无 __bucket 后缀）已迁移拆分为
                # id__<bucket>；仍在运行的旧-context agent 用旧 id 写 confirm/falsify 时，
                # 按本 case 的 fine bucket 精确路由（无该子规则则从兄弟子规则克隆新建）。
                case_bucket = _size_bucket(cells)
                remap_id = f"{rule_id}__{case_bucket}"
                rule = next((r for r in knowledge.get("rules", []) if r["id"] == remap_id), None)
                if not rule:
                    siblings = [r for r in knowledge.get("rules", []) if r["id"].startswith(rule_id + "__")]
                    if siblings:
                        import copy as _copy
                        rule = _copy.deepcopy(siblings[0])
                        rule["id"] = remap_id
                        rule.setdefault("scope", {})["cells"] = case_bucket
                        rule["evidence"] = []
                        rule["confirm_designs"] = []
                        rule["falsify_designs"] = []
                        rule["confidence"] = 0.0
                        rule["status"] = "unverified"
                        knowledge.setdefault("rules", []).append(rule)
            if not rule:
                print(json.dumps({"ok": False, "reason": f"unknown rule id: {rule_id}"}))
                return 1
            # scope 内外判定：case 的 pdk/cells-bucket/bottleneck 是否落在 rule scope 内
            # R24: 加入 bottleneck.source 比较——新知识形态里 source 是关键物理边界
            #（密度型 vs 连接型规律完全不同），scope_out 必须包含 source。
            scope = rule.get("scope") or {}
            cond = rule.get("condition") or {}
            case_bucket = _size_bucket(cells)
            scope_out = False
            if scope.get("pdk") and scope.get("pdk") != pdk:
                scope_out = True
            if scope.get("cells") and scope.get("cells") != case_bucket:
                scope_out = True
            # condition.bottleneck.source 匹配：若规则声明了 source，而 case 的 source 不匹配
            #（agent 通过 --scope-source 传入本 case 的 source），记 scope_out。
            rule_source = (cond.get("bottleneck") or {}).get("source")
            case_source = getattr(args, "scope_source", None)
            if rule_source and case_source and rule_source != case_source:
                scope_out = True
            outcome = evidence
            if scope_out:
                # R22: scope 外的观察（无论 confirm 还是 falsify）都不是本规则
                # scope 内的证据——它只说明"此规则不适用于这个 case"，记为
                # falsify_scope_out 边界证据，不进入 confirm/falsify 计数。
                outcome = "falsify_scope_out"
            ev = {"case": design, "outcome": outcome, "detail": note or design, "at": now}
            _belief_update(rule, outcome, ev)
            if evidence == "falsify":
                # 反例优先收窄 scope（agent 显式给收窄目标，不给则只降置信度）
                sp = getattr(args, "scope_pdk", None)
                sc = getattr(args, "scope_cells", None)
                if sp or sc:
                    if sp:
                        rule["scope"]["pdk"] = sp
                    if sc:
                        rule["scope"]["cells"] = sc
                    if rule["status"] != "dead":
                        rule["status"] = "narrowed"
            KNOWLEDGE_PATH.write_text(json.dumps(knowledge, indent=2, ensure_ascii=False))
            print(json.dumps({"ok": True, "op": evidence, "rule": rule}, indent=2, ensure_ascii=False))
            return 0

        # 操作 0（默认）: append note 到 facts
        if not note:
            print(json.dumps({"ok": False, "reason": "update requires --note (or --evidence hypothesis/confirm/falsify)"}))
            return 1
        facts = knowledge.setdefault("facts", {}).setdefault(design, {})
        facts.setdefault("notes", []).append(note)
        facts["pdk"] = pdk
        facts["cells"] = cells
        facts["bucket"] = bucket
        KNOWLEDGE_PATH.write_text(json.dumps(knowledge, indent=2, ensure_ascii=False))
        print(json.dumps({"ok": True, "op": "note", "updated": design, "bucket": bucket, "notes": facts["notes"]}, indent=2, ensure_ascii=False))
        return 0

    # read 返回精简视图（避免 17 条规则 + 长 evidence 撑爆工具输出截断）。
    # scope 匹配本设计 或 status=confirmed 的规则给完整 brief；其余只给一行摘要。
    def _rule_brief(r: dict) -> dict:
        cond = r.get("condition") or {}
        tr = r.get("tradeoff") or {}
        return {
            "id": r.get("id"),
            "status": r.get("status"),
            "knowledge_value": r.get("knowledge_value"),
            "archived": bool(r.get("archived")),
            "confidence": r.get("confidence"),
            "condition": {
                "pdk": cond.get("pdk"),
                "size_bucket": cond.get("size_bucket"),
                "bottleneck": cond.get("bottleneck"),
                "observable": (cond.get("observable") or "")[:120],
            },
            "decision": r.get("decision"),
            "tradeoff": {
                "egr": {"direction": tr.get("egr", {}).get("direction"), "delta": (tr.get("egr", {}).get("delta") or "")[:60]},
                "hpwl": {"direction": tr.get("hpwl", {}).get("direction"), "delta": (tr.get("hpwl", {}).get("delta") or "")[:60]},
                "timing": {"direction": tr.get("timing", {}).get("direction"), "delta": (tr.get("timing", {}).get("delta") or "")[:60]},
            },
            "tool_mapping": r.get("tool_mapping"),
            "falsify_if": (r.get("falsify_if") or "")[:120],
            "guidance": (r.get("guidance") or "")[:120],
            "confirm_designs": r.get("confirm_designs", []),
            "falsify_designs": r.get("falsify_designs", []),
        }
    def _match(r: dict) -> bool:
        cond = r.get("condition") or {}
        return cond.get("pdk") == pdk and cond.get("size_bucket") == _size_bucket(cells)
    rules_out = []
    for r in knowledge.get("rules", []):
        if _match(r) or r.get("status") == "confirmed":
            rules_out.append(_rule_brief(r))
        else:
            cond = r.get("condition") or {}
            rules_out.append({
                "id": r.get("id"),
                "status": r.get("status"),
                "knowledge_value": r.get("knowledge_value"),
                "archived": bool(r.get("archived")),
                "pdk": cond.get("pdk"),
                "size_bucket": cond.get("size_bucket"),
                "do": (r.get("decision") or {}).get("do", "")[:60],
            })
    # 排序：匹配本设计优先；未归档的知识次之；归档(常识)最后
    def _sort_key(item: dict) -> int:
        if "decision" in item and _match(next((r for r in knowledge.get("rules", []) if r.get("id") == item.get("id")), {})):
            return 0
        if item.get("archived"):
            return 3
        if item.get("status") == "confirmed":
            return 1
        return 2
    rules_out.sort(key=_sort_key)
    out = {
        "ok": True,
        "design": design,
        "pdk": pdk,
        "cells": cells,
        "bucket": bucket,
        "rules": rules_out,
        "per_design_notes": (knowledge.get("facts", {}).get(design) or {}).get("notes", [])[-15:],
    }
    print(json.dumps(out, indent=2, ensure_ascii=False))
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
                     ("candidate", cmd_candidate), ("local_congestion", cmd_local_congestion),
                     ("apply_anchor", cmd_apply_anchor),
                     ("verify_lg", cmd_verify_lg), ("restore", cmd_restore),
                     ("accept", cmd_accept), ("compare", cmd_compare), ("status", cmd_status),
                     ("apply", cmd_apply), ("promote", cmd_promote), ("rollback", cmd_restore),
                     ("fork", cmd_fork), ("prune", cmd_prune), ("tree", cmd_tree), ("daemon", cmd_daemon), ("parallel", cmd_parallel), ("lg", cmd_lg), ("dp", cmd_dp), ("plain", cmd_plain), ("egr", cmd_egr), ("prior", cmd_prior)]:
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
        if sp.prog.endswith(("start", "advance", "local_run", "candidate", "local_congestion", "apply_anchor", "apply", "lg", "dp", "plain")):
            for args_, kwargs in [
                (("--workdir",), {"required": True}),
                (("--case-root",), {}), (("--input-def",), {}), (("--config",), {}),
                (("--foundry-dir",), {}),  # no PDK-specific default: caller must pass the registry foundry_dir
                (("--iterations",), {"type": int, "default": 20}),
                (("--seed",), {"type": int, "default": 1000}), (("--checkpoint",), {}),
                (("--random-init",), {"type": int, "default": 1}),
                (("--seed-anchor-strength",), {"type": float, "default": 0.0}),
                (("--scope",), {"choices": ["global", "hotspot", "random", "instances", "region", "longnet"], "default": "global"}),
                (("--scope-active-ratio",), {"type": float, "default": 0.2}),
                (("--scope-active-count",), {"type": int, "default": 100}),
                (("--scope-seed",), {"type": int, "default": 1000}),
                (("--scope-instances",), {"default": ""}), (("--scope-region",), {"default": ""}),
                (("--scope-density-target",), {"type": float, "default": 1.0}),
                (("--scope-density-ratio",), {"type": float, "default": 0.0}),
                (("--halo-coeff",), {"type": float, "default": 0.5}),
                (("--halo-hops",), {"type": int, "default": 2}),
                (("--scope-anneal-ratio",), {"type": float, "default": 0.0}),
                (("--scope-anchor-strength",), {"type": float, "default": 0.0}),
                (("--target-density",), {"type": float, "default": -1.0}),
                (("--target-overflow",), {"type": float, "default": -1.0}),
                (("--init-density-penalty",), {"type": float, "default": -1.0}),
                (("--min-phi-coef",), {"type": float, "default": -1.0}),
                (("--max-phi-coef",), {"type": float, "default": -1.0}),
                (("--congestion-effort",), {"type": int, "default": -1}),
                (("--report-route-util",), {"type": int, "default": 1}), (("--lef",), {}),
                (("--timing",), {"type": int, "default": 0}),
                (("--bin-cnt",), {"type": int, "default": -1}),
                (("--verify-egr",), {"type": int, "default": 0}),
                (("--rounds",), {"type": int, "default": 2}),
                (("--top-bins",), {"type": int, "default": 3}),
                (("--congestion-threshold",), {"type": float, "default": 1.0}),
                (("--density-target",), {"type": float, "default": 0.5}),
                (("--overflow-penalty",), {"type": float, "default": 0.0}),
            ]:
                sp.add_argument(*args_, **kwargs)
        elif sp.prog.endswith("parallel"):
            sp.add_argument("--workdir", required=True)
            sp.add_argument("--case-root"); sp.add_argument("--input-def"); sp.add_argument("--config")
            sp.add_argument("--foundry-dir"); sp.add_argument("--checkpoint")
            sp.add_argument("--iterations", type=int, default=20); sp.add_argument("--seed", type=int, default=1000)
            sp.add_argument("--random-init", type=int, default=1); sp.add_argument("--candidates", default="")
        elif sp.prog.endswith("daemon"):
            sp.add_argument("--workdir", required=True)
            sp.add_argument("--case-root"); sp.add_argument("--input-def"); sp.add_argument("--config")
            sp.add_argument("--foundry-dir")
        elif sp.prog.endswith(("accept", "verify_lg", "restore", "promote", "rollback", "tree")):
            sp.add_argument("--workdir", required=True)
            sp.add_argument("--case-root"); sp.add_argument("--input-def"); sp.add_argument("--config")
            sp.add_argument("--foundry-dir"); sp.add_argument("--checkpoint")
        elif sp.prog.endswith("fork"):
            sp.add_argument("--workdir", required=True)
            sp.add_argument("--checkpoint")
            sp.add_argument("--fork-target", required=True)
        elif sp.prog.endswith("prune"):
            sp.add_argument("--workdir", required=True)
            sp.add_argument("--prune-node")
        elif sp.prog.endswith("compare"):
            sp.add_argument("--checkpoint-a", required=True)
            sp.add_argument("--checkpoint-b", required=True)
            sp.add_argument("--overflow-penalty", type=float, default=0.0)
        elif sp.prog.endswith("status"):
            sp.add_argument("--workdir", required=True)
        elif sp.prog.endswith("egr"):
            sp.add_argument("--workdir", required=True)
            sp.add_argument("--case-root"); sp.add_argument("--foundry-dir"); sp.add_argument("--def-path")
        elif sp.prog.endswith("prior"):
            sp.add_argument("--workdir", required=True)
            sp.add_argument("--case-root"); sp.add_argument("--input-def"); sp.add_argument("--foundry-dir")
            sp.add_argument("--design"); sp.add_argument("--pdk"); sp.add_argument("--def-path")
            sp.add_argument("--kind", default="read"); sp.add_argument("--note", default="")
            sp.add_argument("--evidence", default=""); sp.add_argument("--rule-id", default="")
            sp.add_argument("--scope-pdk", default=""); sp.add_argument("--scope-cells", default="")
            sp.add_argument("--scope-bottleneck", default=""); sp.add_argument("--scope-physical", default="")
            sp.add_argument("--scope-source", default=""); sp.add_argument("--scope-subclass", default="")
            sp.add_argument("--observable", default="")
            sp.add_argument("--decision-do", default=""); sp.add_argument("--decision-mechanism", default="")
            sp.add_argument("--action-category", default=""); sp.add_argument("--action-subclass", default="")
            sp.add_argument("--tool-mapping", default=""); sp.add_argument("--falsify-if", default="")
            sp.add_argument("--tradeoff-egr", default=""); sp.add_argument("--tradeoff-hpwl", default=""); sp.add_argument("--tradeoff-timing", default="")
            sp.add_argument("--action", default="")
            sp.add_argument("--effect-metric", default=""); sp.add_argument("--effect-direction", default=""); sp.add_argument("--effect-delta", default="")
            sp.add_argument("--cost-metric", default=""); sp.add_argument("--cost-direction", default=""); sp.add_argument("--cost-delta", default="")
            sp.add_argument("--prediction", default=""); sp.add_argument("--guidance", default="")
    for sp in parser._subparsers._group_actions[0].choices.values():
        if not any(a.dest == "lef" for a in sp._actions):
            sp.add_argument("--lef")
        if sp.prog.endswith(("apply", "fork")) and not any(a.dest == "decision_label" for a in sp._actions):
            sp.add_argument("--decision-label", default="")
    args = parser.parse_args()
    return {"start": cmd_start, "advance": cmd_advance, "local_run": cmd_local_run,
            "candidate": cmd_candidate, "local_congestion": cmd_local_congestion,
            "apply_anchor": cmd_apply_anchor,
            "verify_lg": cmd_verify_lg, "restore": cmd_restore,
            "accept": cmd_accept, "compare": cmd_compare, "status": cmd_status,
            "apply": cmd_apply, "promote": cmd_promote, "rollback": cmd_restore,
            "fork": cmd_fork, "prune": cmd_prune, "tree": cmd_tree, "daemon": cmd_daemon, "parallel": cmd_parallel, "lg": cmd_lg, "dp": cmd_dp, "plain": cmd_plain, "egr": cmd_egr, "prior": cmd_prior}[args.command](args)


if __name__ == "__main__":
    raise SystemExit(main())
