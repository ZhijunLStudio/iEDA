#!/usr/bin/env python3
"""DeepSeek Harness MCP plugin for iEDA global placement (GP).

The harness mounts this stdio MCP server through @deepseek-ai/dsh-mcp-client;
the model then sees tools such as mcp__gp__gp_candidate and can drive the
iEDA GP agent on the designs listed in designs.json.

Every tool delegates to the checked-in Python CLIs under benchmarks/flows,
so behavior matches the manually executed GP workflows exactly.
"""
from __future__ import annotations

import json
import logging
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Any

from mcp.server.fastmcp import FastMCP

IEDA_ROOT = Path(os.environ.get("IEDA_ROOT", "/home/lizhijun/work/iEDA.ai")).resolve()
DESIGNS_JSON = Path(os.environ.get("GP_DESIGNS_JSON", str(Path(__file__).with_name("designs.json")))).resolve()
GP_AGENT = IEDA_ROOT / "benchmarks/flows/gp_agent.py"
HPWL_EVAL = IEDA_ROOT / "benchmarks/flows/def_hpwl_eval.py"
FULL_COMPARE = IEDA_ROOT / "benchmarks/flows/run_ipl_full_compare.py"
LEF = IEDA_ROOT / "scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef"

mcp = FastMCP("ieda-gp")


def _registry() -> dict[str, Any]:
    return json.loads(DESIGNS_JSON.read_text())


def _design(name: str) -> dict[str, Any]:
    reg = _registry()
    if name not in reg:
        raise ValueError(f"unknown design {name!r}; known designs: {sorted(reg)}")
    return reg[name]


def _run(cmd: list[str], timeout: int, cwd: str | None = None) -> dict[str, Any]:
    proc = subprocess.run(cmd, cwd=cwd, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=timeout)
    stdout = proc.stdout[-12000:]
    stderr_tail = proc.stderr[-4000:]
    parsed: Any = None
    try:
        parsed = json.loads(proc.stdout)
    except Exception:
        pass
    return {"rc": proc.returncode, "stdout": stdout, "stderr_tail": stderr_tail, "json": parsed}


def _read_json(path: str | Path) -> Any:
    p = Path(path)
    if not p.exists():
        return None
    try:
        return json.loads(p.read_text())
    except Exception:
        return None


def _agent(design_name: str, workdir: str, args: list[str], timeout: int) -> dict[str, Any]:
    design = _design(design_name)
    base = [
        sys.executable, str(GP_AGENT),
        "--workdir", str(workdir),
        "--case-root", design["case_root"],
        "--input-def", design["input_def"],
        "--config", design["pl_config"],
    ]
    return _run(base + args, timeout)


def _hpwl_for_def(def_path: str | Path) -> tuple[int, int]:
    result = _run([sys.executable, str(HPWL_EVAL), str(LEF), str(def_path)], timeout=1800)
    if result["rc"] != 0:
        raise RuntimeError(f"def_hpwl_eval failed rc={result['rc']}: {result['stderr_tail']}")
    match = re.search(r"HPWL=(\d+)", result["stdout"])
    if not match:
        raise RuntimeError(f"cannot parse HPWL from def_hpwl_eval output: {result['stdout'][-500:]}")
    return int(match.group(1)), 0


@mcp.tool()
def gp_baselines() -> dict[str, Any]:
    """List designs/PDKs, Innovus baseline HPWL, and the best iEDA GP result committed so far.

    Use this first to choose a design where the remaining headroom is largest.
    """
    out: dict[str, Any] = {}
    for name, design in _registry().items():
        out[name] = {
            "pdk": design["pdk"],
            "innovus_hpwl": design["innovus_hpwl"],
            "ieda_best_hpwl": design["ieda_best_hpwl"],
            "ieda_improvement_pct": round((1.0 - design["ieda_best_hpwl"] / design["innovus_hpwl"]) * 100.0, 3),
            "case_root": design["case_root"],
            "input_def": design["input_def"],
            "pl_config": design["pl_config"],
            "notes": design["notes"],
        }
    return out


@mcp.tool()
def gp_start(design: str, workdir: str, iterations: int = 20, random_init: int = 1, seed: int = 1000,
             target_density: float = -1.0, init_density_penalty: float = -1.0, min_phi_coef: float = -1.0,
             max_phi_coef: float = -1.0, congestion_effort: int = -1, seed_anchor_strength: float = 0.0,
             report_route_util: int = 1) -> dict[str, Any]:
    """Start a new iEDA GP session for a registered design.

    Returns the session state and last iteration record. Use gp_candidate or
    gp_advance afterwards; a fresh workdir is required for each independent search.
    """
    args = ["start", "--iterations", str(iterations), "--seed", str(seed),
            "--random-init", str(random_init), "--seed-anchor-strength", str(seed_anchor_strength),
            "--target-density", str(target_density), "--init-density-penalty", str(init_density_penalty),
            "--min-phi-coef", str(min_phi_coef), "--max-phi-coef", str(max_phi_coef),
            "--congestion-effort", str(congestion_effort), "--report-route-util", str(report_route_util)]
    result = _agent(design, workdir, args, timeout=7200)
    if result["rc"] != 0 or not isinstance(result["json"], dict):
        return result
    return result["json"]


@mcp.tool()
def gp_candidate(design: str, workdir: str, iterations: int = 20, scope: str = "longnet",
                 scope_active_ratio: float = 0.2, scope_active_count: int = 100, scope_region: str = "",
                 halo_coeff: float = 0.5, halo_hops: int = 2, overflow_penalty: float = 2.0,
                 scope_density_target: float = 1.0, scope_density_ratio: float = 0.0,
                 checkpoint: str = "") -> dict[str, Any]:
    """Run one local-vs-global GP candidate from a checkpoint.

    The returned verdict already contains a safe rollback decision. Prefer the
    winning checkpoint for the next stage. scope may be global/hotspot/random/
    instances/region/longnet; scope_region is four integers 'llx lly urx ury'.
    """
    if not checkpoint:
        state_path = Path(workdir) / "gp_agent_state.json"
        state = _read_json(state_path) or {}
        checkpoint = state.get("latest_checkpoint", "")
    args = ["candidate", "--iterations", str(iterations), "--scope", scope,
            "--scope-active-ratio", str(scope_active_ratio), "--scope-active-count", str(scope_active_count),
            "--scope-region", scope_region, "--halo-coeff", str(halo_coeff), "--halo-hops", str(halo_hops),
            "--overflow-penalty", str(overflow_penalty),
            "--scope-density-target", str(scope_density_target), "--scope-density-ratio", str(scope_density_ratio)]
    if checkpoint:
        args += ["--checkpoint", str(checkpoint)]
    result = _agent(design, workdir, args, timeout=7200)
    if result["rc"] != 0 or not isinstance(result["json"], dict):
        return result
    payload = result["json"]
    # Enrich verdict with HPWL/overflow of both candidates so the model can
    # reason about the actual Pareto tradeoff, not just the verdict string.
    comparison = payload.get("candidate") or {}
    if comparison:
        local_path = comparison.get("candidate_local_checkpoint", "")
        global_path = comparison.get("candidate_global_checkpoint", "")
        local = _read_json(local_path) or {}
        global_ = _read_json(global_path) or {}
        comparison = {
            **comparison,
            "local_metrics": {"iter": local.get("current_iter"), "hpwl": local.get("prev_hpwl"), "overflow": local.get("sum_overflow")},
            "global_metrics": {"iter": global_.get("current_iter"), "hpwl": global_.get("prev_hpwl"), "overflow": global_.get("sum_overflow")},
        }
        payload = {**payload, "candidate": comparison}
    return payload


@mcp.tool()
def gp_advance(design: str, workdir: str, iterations: int = 100, checkpoint: str = "",
               report_route_util: int = 1) -> dict[str, Any]:
    """Advance an existing GP session toward its overflow target.

    Use this after gp_start or a winning gp_candidate stage to finish placement.
    """
    if not checkpoint:
        state_path = Path(workdir) / "gp_agent_state.json"
        state = _read_json(state_path) or {}
        checkpoint = state.get("latest_checkpoint", "")
    args = ["advance", "--iterations", str(iterations), "--report-route-util", str(report_route_util)]
    if checkpoint:
        args += ["--checkpoint", str(checkpoint)]
    result = _agent(design, workdir, args, timeout=7200)
    return result["json"] if result["rc"] == 0 and isinstance(result["json"], dict) else result


@mcp.tool()
def gp_report(workdir: str) -> dict[str, Any]:
    """Report the current iEDA GP session state, ledger record, and candidate paths."""
    state = _read_json(Path(workdir) / "gp_agent_state.json") or {}
    ledger_path = Path(workdir) / "pl/gp_experiments.jsonl"
    last_ledger: Any = None
    if ledger_path.exists():
        lines = [ln for ln in ledger_path.read_text(errors="ignore").splitlines() if ln.strip()]
        if lines:
            last_ledger = json.loads(lines[-1])
    return {"state": state, "last_ledger": last_ledger}


@mcp.tool()
def gp_eval_def(design: str, def_path: str) -> dict[str, Any]:
    """Evaluate a placement DEF with the common HPWL script and compare vs Innovus.

    This is the canonical cross-tool comparison used by the GP workflows.
    """
    hpwl, _ = _hpwl_for_def(def_path)
    d = _design(design)
    return {
        "design": design,
        "def": def_path,
        "hpwl": hpwl,
        "innovus_hpwl": d["innovus_hpwl"],
        "innovus_ratio": round(hpwl / d["innovus_hpwl"], 6),
        "improvement_pct_vs_innovus": round((1.0 - hpwl / d["innovus_hpwl"]) * 100.0, 3),
        "vs_ieda_best_pct": round((1.0 - hpwl / d["ieda_best_hpwl"]) * 100.0, 3),
    }


@mcp.tool()
def gp_full_compare(design: str, result_root: str, timing: bool = False, timeout_seconds: int = 7200) -> dict[str, Any]:
    """Run the full iEDA GP->LG->DP placement flow for one design.

    timing=true enables timing-driven GP. The result is the same JSON produced
    by run_ipl_full_compare.py and contains the Innovus ratio.
    """
    args = [sys.executable, str(FULL_COMPARE), "--designs", design, "--result-root", str(result_root)]
    if timing:
        args += ["--timing"]
    result = _run(args, timeout=timeout_seconds, cwd=str(IEDA_ROOT))
    if result["rc"] != 0 or not isinstance(result["json"], dict):
        return result
    return result["json"]


if __name__ == "__main__":
    # FastMCP and the MCP SDK log protocol traffic through stdlib logging.
    # The harness consumes JSON-RPC on stdout, so logging must never touch it.
    for handler in logging.root.handlers[:]:
        logging.root.removeHandler(handler)
    logging.basicConfig(stream=sys.stderr, level=logging.WARNING, force=True)
    mcp.run(transport="stdio")
