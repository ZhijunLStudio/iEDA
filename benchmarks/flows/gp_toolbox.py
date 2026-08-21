#!/usr/bin/env python3
"""Python toolbox backing the fine-grained iEDA GP tools.

This module reads the same artifacts that gp_agent.py produces:
- workdir/gp_agent_state.json
- workdir/pl/gp_experiments.jsonl
- workdir/pl/gp_grid_report.json
- workdir/*.json checkpoints
- placement/input DEF for net topology

It implements inspect/diagnose/propose semantics from GPA_NEXT_PLAN.md.
No iEDA subprocess is started by any read-only function in this module.
"""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any, Iterable

INST_NAME_RE = re.compile(r"^\s*-\s+(\S+)\s+(.+?)\s*;\s*$")
PIN_PAIR_RE = re.compile(r"\(\s*(\S+)\s+(\S+)\s*\)")


def load_json(path: str | Path) -> dict | None:
    p = Path(path)
    if not p.exists():
        return None
    try:
        data = json.loads(p.read_text())
        return data if isinstance(data, dict) else None
    except Exception:
        return None


def workdir_context(workdir: str | Path) -> dict:
    state = load_json(Path(workdir) / "gp_agent_state.json") or {}
    return state


def latest_checkpoint(workdir: str | Path) -> str | None:
    state = workdir_context(workdir)
    cp = state.get("latest_checkpoint")
    if not cp:
        ledger = load_json(Path(workdir) / "pl/gp_experiments.jsonl")
        if ledger:
            cp = ledger.get("checkpoint")
    if cp and Path(cp).exists():
        return cp
    # Fallback for search workdirs that only keep checkpoint files.
    best: tuple[int, str] | None = None
    for item in checkpoint_list(workdir):
        key = (int(item.get("iteration") or 0), item["checkpoint"])
        if best is None or key > best:
            best = key
    return best[1] if best else None


def resolve_checkpoint(workdir: str | Path, checkpoint: str | None) -> dict:
    if checkpoint:
        cp = Path(checkpoint)
        if not cp.exists():
            raise ValueError(f"checkpoint does not exist: {checkpoint}")
        data = load_json(cp)
        if data is None:
            raise ValueError(f"checkpoint is not valid JSON: {checkpoint}")
        return data
    cp = latest_checkpoint(workdir)
    if not cp:
        raise ValueError(f"no checkpoint in workdir {workdir}; run gp_start first")
    data = load_json(cp)
    if data is None:
        raise ValueError(f"latest checkpoint is not valid JSON: {cp}")
    return data


def checkpoint_path(workdir: str | Path, checkpoint: str | None) -> str:
    if checkpoint:
        return str(Path(checkpoint))
    cp = latest_checkpoint(workdir)
    if not cp:
        raise ValueError(f"no checkpoint in workdir {workdir}")
    return cp


def metric(value: Any, available: bool, reason: str | None = None) -> dict:
    return {"value": value if available else None, "available": available,
            "reason": reason if not available else None}


def checkpoint_metrics(cp: dict, path: str) -> dict:
    config = cp.get("config_state") or {}
    timing_on = bool(config.get("is_timing_effort", 0))
    congestion_on = bool(config.get("is_congestion_effort", 0))
    timing_stale = not timing_on
    rudy_stale = not congestion_on
    records = cp.get("iteration_records") or []
    last_timing_iter = None
    last_rudy_iter = None
    for rec in reversed(records):
        if last_timing_iter is None and timing_on:
            last_timing_iter = rec.get("iter")
        if last_rudy_iter is None and congestion_on:
            last_rudy_iter = rec.get("iter")
    return {
        "checkpoint_path": path,
        "iteration": cp.get("current_iter"),
        "hpwl": metric(cp.get("prev_hpwl"), True),
        "density_overflow": metric(cp.get("sum_overflow"), True),
        "overflowing_bin_count": None,  # filled from grid report by status()
        "peak_bin_density": None,
        "rudy_route_util_max": metric(cp.get("final_route_util"), congestion_on,
                                      "congestion_effort is off" if rudy_stale else None),
        "timing_iter": last_timing_iter,
        "rudy_iter": last_rudy_iter,
        "setup_wns": metric(None, timing_on, "timing_effort is off"),
        "hold_wns": metric(None, timing_on, "timing_effort is off"),
        "step_length": metric(cp.get("final_step_length"), True),
        "fidelity": "gp",
    }


def grid_report(workdir: str | Path, checkpoint: str | None = None) -> dict | None:
    # gp_agent.py currently always dumps the report for the active session at
    # the latest iteration. Prefer the explicit artifact; checkpoint-specific
    # bin reports are a future iEDA-side addition.
    path = Path(workdir) / "pl/gp_grid_report.json"
    return load_json(path)


def checkpoint_list(workdir: str | Path) -> list[dict]:
    root = Path(workdir)
    items: list[dict] = []
    for path in sorted(root.glob("*.json")):
        name = path.name
        if name in ("gp_agent_state.json", "search.json"):
            continue
        data = load_json(path)
        if not data or "current_iter" not in data:
            continue
        items.append({
            "checkpoint": str(path),
            "name": name,
            "iteration": data.get("current_iter"),
            "hpwl": data.get("prev_hpwl"),
            "overflow": data.get("sum_overflow"),
            "stop_reason": data.get("stop_reason"),
            "finished": data.get("finished_iter", 0) >= (data.get("current_iter") or 0),
        })
    items.sort(key=lambda x: (x["iteration"] or 0, x["name"]))
    return items


def design_status(workdir: str | Path, checkpoint: str | None = None) -> dict:
    try:
        cp = resolve_checkpoint(workdir, checkpoint)
    except Exception as error:
        return {"ok": False, "workdir": str(workdir), "reason": str(error),
                "hint": "run kind=start or kind=full first"}
    cp_path = checkpoint_path(workdir, checkpoint)
    out = checkpoint_metrics(cp, cp_path)
    out["ok"] = True
    config_state = cp.get("config_state") or {}
    out["effective_config"] = {
        "target_density": config_state.get("target_density"),
        "target_overflow": config_state.get("target_overflow"),
        "init_density_penalty": config_state.get("init_density_penalty"),
        "is_opt_congestion": bool(config_state.get("is_opt_congestion")),
        "congestion_effort_level": config_state.get("congestion_effort_level", 1),
        "is_opt_timing": bool(config_state.get("is_opt_timing")),
        "bin_cnt_x": config_state.get("bin_cnt_x"),
        "bin_cnt_y": config_state.get("bin_cnt_y"),
    }
    grid = grid_report(workdir)
    if grid:
        out["overflowing_bin_count"] = metric(grid.get("overflowing_bin_count"), True)
        out["peak_bin_density"] = metric(grid.get("peak_density"), True)
        out["grid_bin_cnt"] = metric((grid.get("bin_cnt_x"), grid.get("bin_cnt_y")), True)
    else:
        out["overflowing_bin_count"] = metric(None, False, "gp_grid_report.json missing")
        out["peak_bin_density"] = metric(None, False, "gp_grid_report.json missing")
    out["checkpoint_list"] = [x["name"] for x in checkpoint_list(workdir)[-20:]]
    out["timing_stale"] = out["timing_iter"] != out["iteration"]
    out["rudy_stale"] = out["rudy_iter"] != out["iteration"]
    out["metric_units"] = {
        "hpwl": "gp_internal_solver_hpwl",
        "overflow": "gp_internal_density_overflow_ratio",
        "route_util": "gp_internal_rudy_max_util",
        "timing": "gp_internal_ista_if_enabled",
    }
    out["note"] = ("status.hpwl is the solver-internal HPWL; it is NOT the same scale as "
                   "def_hpwl_eval / local_restart_hpwl. Compare DEF-level numbers only "
                   "with local_restart's *_def_hpwl fields or gp_verify_lg.")
    return out


def diagnose_hotspots(workdir: str | Path, checkpoint: str | None = None, top_n: int = 5) -> dict:
    cp = resolve_checkpoint(workdir, checkpoint)
    grid = grid_report(workdir)
    if not grid:
        return {"ok": False, "reason": "gp_grid_report.json missing"}
    bins = sorted(grid.get("bins", []), key=lambda b: b.get("overflow_area", 0), reverse=True)[:max(1, top_n)]
    return {
        "ok": True,
        "checkpoint_path": checkpoint_path(workdir, checkpoint),
        "iteration": cp.get("current_iter"),
        "hotspots": [
            {
                "row": b.get("row"),
                "col": b.get("col"),
                "bbox": f"{b.get('ll_x')} {b.get('ll_y')} {b.get('ur_x')} {b.get('ur_y')}",
                "density": b.get("density"),
                "overflow_area": b.get("overflow_area"),
            }
            for b in bins
        ],
    }


def load_net_topology(def_path: str | Path) -> list[dict]:
    text = Path(def_path).read_text(errors="ignore")
    nets_start = text.find("\nNETS")
    nets_end = text.find("\nEND NETS")
    if nets_start < 0 or nets_end < 0:
        raise ValueError("DEF has no NETS section")
    block = text[nets_start:nets_end]
    nets: list[dict] = []
    current: dict | None = None
    for raw in block.splitlines():
        line = raw.strip()
        if not line or line.startswith("NETS"):
            continue
        # `- name` may carry pins on the same line or on following lines.
        if line.startswith("-"):
            if current:
                nets.append(current)
            body = line[1:].strip()
            first_space = body.find(" ")
            if first_space < 0:
                current = {"name": body, "pins": []}
            else:
                current = {"name": body[:first_space], "pins": []}
                line = body[first_space:]
            if ";" in line:
                line = line[:line.index(";")]
        if current is None:
            continue
        if line.startswith("+"):
            line = line[1:].strip()
        if ";" in line:
            line = line[:line.index(";")]
        current["pins"].extend(PIN_PAIR_RE.findall(line))
    if current:
        nets.append(current)
    return nets


def diagnose_longnets(workdir: str | Path, checkpoint: str | None = None, top_n: int = 5,
                      def_path: str | None = None) -> dict:
    cp = resolve_checkpoint(workdir, checkpoint)
    names = cp.get("instance_names") or []
    coords = cp.get("instance_density_coords") or []
    if not names or len(names) != len(coords):
        return {"ok": False, "reason": "checkpoint has no instance density coordinates"}
    inst_idx = {name: i for i, name in enumerate(names)}
    if not def_path:
        state = workdir_context(workdir)
        def_path = state.get("input_def")
        if not def_path:
            return {"ok": False, "reason": "input_def is not recorded in workdir; pass def_path"}
    nets = load_net_topology(def_path)
    scored: list[dict] = []
    for net in nets:
        points: list[tuple[int, int]] = []
        for inst, _pin in net["pins"]:
            idx = inst_idx.get(inst)
            if idx is None:
                continue
            xy = coords[idx]
            points.append((int(xy[0]), int(xy[1])))
        if len(points) < 2:
            continue
        xs = [p[0] for p in points]
        ys = [p[1] for p in points]
        hpwl = max(xs) - min(xs) + max(ys) - min(ys)
        scored.append({"net": net["name"], "hpwl": hpwl, "pin_count": len(points)})
    scored.sort(key=lambda x: x["hpwl"], reverse=True)
    return {
        "ok": True,
        "checkpoint_path": checkpoint_path(workdir, checkpoint),
        "iteration": cp.get("current_iter"),
        "longnets": scored[: max(1, top_n)],
    }


def propose_longnet_instances(workdir: str | Path, checkpoint: str | None, top_n: int,
                              def_path: str | None) -> dict:
    """Return concrete, executable instance sets for the highest-HPWL nets.

    This is a proposal, not a decision: every returned set can be passed
    directly to gp.run kind=local_run scope=instances.
    """
    cp = resolve_checkpoint(workdir, checkpoint)
    names = cp.get("instance_names") or []
    coords = cp.get("instance_density_coords") or []
    if not names or len(names) != len(coords):
        return {"ok": False, "reason": "checkpoint has no instance density coordinates"}
    inst_idx = {name: i for i, name in enumerate(names)}
    if not def_path:
        state = workdir_context(workdir)
        def_path = state.get("input_def")
        if not def_path:
            return {"ok": False, "reason": "input_def is not recorded in workdir; pass def_path"}
    nets = load_net_topology(def_path)
    scored = []
    for net in nets:
        instances = []
        points = []
        for inst, _pin in net["pins"]:
            idx = inst_idx.get(inst)
            if idx is None:
                continue
            if inst not in instances:
                instances.append(inst)
            xy = coords[idx]
            points.append((int(xy[0]), int(xy[1])))
        if len(instances) < 2 or len(points) < 2:
            continue
        xs = [p[0] for p in points]
        ys = [p[1] for p in points]
        hpwl = max(xs) - min(xs) + max(ys) - min(ys)
        scored.append({"net": net["name"], "hpwl": hpwl, "pin_count": len(points),
                       "instances": instances})
    scored.sort(key=lambda x: x["hpwl"], reverse=True)
    scored = scored[: max(1, top_n)]

    # Facts: individual top nets.
    top_nets = [{"net": x["net"], "hpwl": x["hpwl"], "pin_count": x["pin_count"],
                 "instance_count": len(x["instances"])} for x in scored]

    # Executable proposals: union of the top k nets. The agent chooses the
    # coverage size; the kernel does not decide how many cells are "right".
    proposals = []
    selected_instances = []
    selected_nets = []
    seen = set()
    for net in scored:
        selected_nets.append(net["net"])
        for inst in net["instances"]:
            if inst not in seen:
                seen.add(inst)
                selected_instances.append(inst)
        proposals.append({
            "id": f"longnet-top-{len(selected_nets)}",
            "nets": list(selected_nets),
            "net_count": len(selected_nets),
            "instance_count": len(selected_instances),
            "max_net_hpwl": scored[0]["hpwl"],
            "instances": list(selected_instances),
            "executable_action": {
                "tool": "ieda_gp_run",
                "kind": "local_run",
                "scope": "instances",
                "scope_instances": ",".join(selected_instances),
                "checkpoint": checkpoint_path(workdir, checkpoint),
            },
            "prediction_status": "unavailable",
        })
    return {"ok": True, "checkpoint_path": checkpoint_path(workdir, checkpoint),
            "iteration": cp.get("current_iter"), "top_nets": top_nets,
            "proposals": proposals}


def instance_points_in_bbox(bbox: str, names: list[str], coords: list[list[float]]) -> list[tuple[str, list[float]]]:
    llx, lly, urx, ury = map(int, bbox.split())
    out = []
    for i, xy in enumerate(coords):
        x, y = float(xy[0]), float(xy[1])
        if llx <= x <= urx and lly <= y <= ury:
            out.append((names[i], [x, y]))
    return out


def merge_connected_bins(bins: list[dict], cnt_x: int, cnt_y: int, top_n: int) -> list[list[dict]]:
    """Merge adjacent top overflow bins into connected groups."""
    chosen = bins[: max(1, top_n)]
    groups: list[list[dict]] = []
    used: set[int] = set()
    for b in chosen:
        key = b["row"] * cnt_x + b["col"]
        if key in used:
            continue
        group = [b]
        used.add(key)
        changed = True
        while changed:
            changed = False
            for other in chosen:
                okey = other["row"] * cnt_x + other["col"]
                if okey in used:
                    continue
                for member in group:
                    if abs(other["row"] - member["row"]) + abs(other["col"] - member["col"]) == 1:
                        group.append(other)
                        used.add(okey)
                        changed = True
                        break
        groups.append(group)
    return groups


def bbox_of_group(group: list[dict]) -> tuple[int, int, int, int]:
    return (min(b["ll_x"] for b in group), min(b["ll_y"] for b in group),
            max(b["ur_x"] for b in group), max(b["ur_y"] for b in group))


def expand_bbox(bbox: tuple[int, int, int, int], dx: int, dy: int,
                core: tuple[int, int, int, int]) -> tuple[int, int, int, int]:
    llx, lly, urx, ury = bbox
    cllx, clly, curx, cury = core
    return (max(cllx, llx - dx), max(clly, lly - dy), min(curx, urx + dx), min(cury, ury + dy))


def propose_regions(workdir: str | Path, checkpoint: str | None = None, priority: str = "density",
                    top_n: int = 5, min_cell_count: int = 20, max_cell_count: int = 200,
                    def_path: str | None = None) -> dict:
    cp = resolve_checkpoint(workdir, checkpoint)
    names = cp.get("instance_names") or []
    coords = cp.get("instance_density_coords") or []
    if not names or len(names) != len(coords):
        return {"ok": False, "reason": "checkpoint has no instance density coordinates"}

    if priority in ("longnet", "timing", "mixed"):
        if priority != "longnet":
            return {"ok": False, "reason": f"priority={priority} is not implemented; use density or longnet"}
        diag = diagnose_longnets(workdir, checkpoint, top_n=top_n, def_path=def_path)
        if not diag.get("ok"):
            return diag
        regions = []
        for ln in diag["longnets"]:
            net = ln["net"]
            # Get cell groups from net topology later; this v1 returns net seeds
            # with the instruction to feed them to gp_candidate via scope=longnet.
            regions.append({
                "id": f"net:{net}",
                "kind": "longnet",
                "net": net,
                "net_hpwl": ln["hpwl"],
                "reason": "top HPWL net from current checkpoint",
                "prediction_status": "unavailable",
            })
        return {"ok": True, "checkpoint_path": checkpoint_path(workdir, checkpoint),
                "iteration": cp.get("current_iter"), "priority": priority, "regions": regions}

    grid = grid_report(workdir)
    if not grid:
        return {"ok": False, "reason": "gp_grid_report.json missing"}
    bins = sorted(grid.get("bins", []), key=lambda b: b.get("overflow_area", 0), reverse=True)
    if not bins:
        return {"ok": False, "reason": "grid report contains no bins"}
    cnt_x, cnt_y = int(grid.get("bin_cnt_x", 0)), int(grid.get("bin_cnt_y", 0))
    core = (int(grid.get("core_ll_x", 0)), int(grid.get("core_ll_y", 0)),
            int(grid.get("core_ur_x", 0)), int(grid.get("core_ur_y", 0)))
    groups = merge_connected_bins(bins, cnt_x, cnt_y, top_n)
    regions = []
    for gi, group in enumerate(groups):
        bbox = bbox_of_group(group)
        dx = max(b["ur_x"] - b["ll_x"] for b in group) // 2
        dy = max(b["ur_y"] - b["ll_y"] for b in group) // 2
        active = instance_points_in_bbox(f"{bbox[0]} {bbox[1]} {bbox[2]} {bbox[3]}", names, coords)
        # Grow until the minimum cell count or the core boundary. The first
        # pass uses a half-bin step to stay local; subsequent passes use one
        # full bin step.
        if len(active) < min_cell_count:
            for step, size in [(0.5, (dx, dy))] + [(1.0, (2 * dx, 2 * dy))] * 8:
                prev = bbox
                expanded = expand_bbox(bbox, int(dx * step * 2) or dx, int(dy * step * 2) or dy, core)
                bbox = expanded
                active = instance_points_in_bbox(f"{bbox[0]} {bbox[1]} {bbox[2]} {bbox[3]}", names, coords)
                if len(active) >= min_cell_count or expanded == prev:
                    break
        if len(active) > max_cell_count:
            # keep the hottest bin only
            hot = max(group, key=lambda b: b.get("overflow_area", 0))
            bbox = (hot["ll_x"], hot["ll_y"], hot["ur_x"], hot["ur_y"])
            active = instance_points_in_bbox(f"{bbox[0]} {bbox[1]} {bbox[2]} {bbox[3]}", names, coords)
        region = {
            "id": f"region-{gi + 1}",
            "kind": "density",
            "bin_indices": [b["row"] * cnt_x + b["col"] for b in group],
            "bbox": f"{bbox[0]} {bbox[1]} {bbox[2]} {bbox[3]}",
            "active_cell_count": len(active),
            "halo_cell_count": 0,
            "density_overflow": max(b.get("overflow_area", 0) for b in group),
            "score": max(b.get("overflow_area", 0) for b in group),
            "reason": f"merged {len(group)} connected high-overflow bins",
            "prediction_status": "unavailable",
        }
        regions.append(region)
    return {"ok": True, "checkpoint_path": checkpoint_path(workdir, checkpoint),
            "iteration": cp.get("current_iter"), "priority": priority,
            "bin_cnt": (cnt_x, cnt_y), "regions": regions}


def propose_region_density(workdir: str | Path, region: str, checkpoint: str | None = None) -> dict:
    cp = resolve_checkpoint(workdir, checkpoint)
    grid = grid_report(workdir)
    if not grid:
        return {"ok": False, "reason": "gp_grid_report.json missing"}
    llx, lly, urx, ury = map(int, region.split())
    overlap = []
    for b in grid.get("bins", []):
        blx, bly, bux, buy = b["ll_x"], b["ll_y"], b["ur_x"], b["ur_y"]
        if not (urx <= blx or llx >= bux or ury <= bly or lly >= buy):
            overlap.append(b)
    if not overlap:
        return {"ok": False, "reason": "region does not overlap any GP bin"}
    peak = max(b.get("density", 0.0) for b in overlap)
    suggested = max(0.6, min(1.0, round(1.0 / peak, 2)))
    return {"ok": True, "checkpoint_path": checkpoint_path(workdir, checkpoint),
            "iteration": cp.get("current_iter"), "region": region,
            "overlapping_bins": len(overlap), "peak_density": peak,
            "suggested_density_target": suggested,
            "prediction_status": "unavailable"}


def propose_freeze(workdir: str | Path, region: str, checkpoint: str | None = None) -> dict:
    cp = resolve_checkpoint(workdir, checkpoint)
    names = cp.get("instance_names") or []
    coords = cp.get("instance_density_coords") or []
    active = instance_points_in_bbox(region, names, coords)
    return {"ok": True, "checkpoint_path": checkpoint_path(workdir, checkpoint),
            "iteration": cp.get("current_iter"), "region": region,
            "cells_in_region": len(active), "freeze_cell_count": len(active),
            "prediction_status": "unavailable"}


def freeze_instances(workdir: str | Path, region: str, checkpoint: str | None = None) -> dict:
    """Return the complement instance list for one-batch freeze semantics.

    Freezing region R for a batch means marking every instance inside R as
    context (coefficient 0) and every other instance as active. gp_agent
    local_run then executes this scope without a global control branch.
    """
    cp = resolve_checkpoint(workdir, checkpoint)
    names = cp.get("instance_names") or []
    coords = cp.get("instance_density_coords") or []
    inside = {name for name, _xy in instance_points_in_bbox(region, names, coords)}
    outside = [name for name in names if name not in inside]
    return {
        "ok": True,
        "checkpoint_path": checkpoint_path(workdir, checkpoint),
        "iteration": cp.get("current_iter"),
        "region": region,
        "frozen_cell_count": len(inside),
        "active_outside_cell_count": len(outside),
        "scope": "instances",
        "scope_instances": ",".join(outside),
    }


def diagnose_unstable_region(workdir: str | Path, checkpoint_a: str | None, checkpoint_b: str | None,
                             top_n: int = 5) -> dict:
    a = resolve_checkpoint(workdir, checkpoint_a)
    b = resolve_checkpoint(workdir, checkpoint_b)
    na, nb = a.get("instance_names") or [], b.get("instance_names") or []
    ca, cb = a.get("instance_density_coords") or [], b.get("instance_density_coords") or []
    if na != nb or len(ca) != len(cb):
        return {"ok": False, "reason": "checkpoints are not comparable"}
    moved = []
    for i, name in enumerate(na):
        dx = float(ca[i][0]) - float(cb[i][0])
        dy = float(ca[i][1]) - float(cb[i][1])
        moved.append({"cell": name, "dx": dx, "dy": dy, "dist": (dx * dx + dy * dy) ** 0.5})
    moved.sort(key=lambda x: x["dist"], reverse=True)
    return {"ok": True, "checkpoint_a": checkpoint_path(workdir, checkpoint_a),
            "checkpoint_b": checkpoint_path(workdir, checkpoint_b),
            "iteration_a": a.get("current_iter"), "iteration_b": b.get("current_iter"),
            "most_moved": moved[: max(1, top_n)]}


def net_hpwl_for_checkpoint(net: dict, inst_idx: dict, coords: list[list[float]]) -> float:
    points = []
    for inst, _pin in net["pins"]:
        idx = inst_idx.get(inst)
        if idx is not None:
            points.append((float(coords[idx][0]), float(coords[idx][1])))
    if len(points) < 2:
        return 0.0
    xs = [p[0] for p in points]
    ys = [p[1] for p in points]
    return max(xs) - min(xs) + max(ys) - min(ys)


def verify_delta(workdir: str | Path, checkpoint_a: str, checkpoint_b: str,
                 def_path: str | None = None) -> dict:
    a = resolve_checkpoint(workdir, checkpoint_a)
    b = resolve_checkpoint(workdir, checkpoint_b)
    same = (a.get("config_fingerprint") == b.get("config_fingerprint")
            and a.get("instance_names") == b.get("instance_names")
            and a.get("total_inst_area") == b.get("total_inst_area"))
    if not same:
        return {"ok": False, "reason": "checkpoints have different config or topology",
                "incomparable": True}
    def val(cp, key):
        return float(cp.get(key, 0.0) or 0.0)
    hpwl_delta = val(b, "prev_hpwl") - val(a, "prev_hpwl")
    ov_delta = val(b, "sum_overflow") - val(a, "sum_overflow")
    rudy_delta = val(b, "final_route_util") - val(a, "final_route_util")

    names = a.get("instance_names") or []
    ca, cb = a.get("instance_density_coords") or [], b.get("instance_density_coords") or []
    moved = []
    if names and len(names) == len(ca) == len(cb):
        for i, name in enumerate(names):
            dx = float(ca[i][0]) - float(cb[i][0])
            dy = float(ca[i][1]) - float(cb[i][1])
            if abs(dx) + abs(dy) > 1e-6:
                moved.append({"cell": name, "dx": dx, "dy": dy,
                              "l1": abs(dx) + abs(dy)})
    moved.sort(key=lambda x: x["l1"], reverse=True)

    affected_nets = []
    net_hpwl_delta_affected = None
    if def_path:
        try:
            nets = load_net_topology(def_path)
            idx = {name: i for i, name in enumerate(names)}
            moved_names = {m["cell"] for m in moved}
            for net in nets:
                touched = any(pin[0] in moved_names for pin in net["pins"])
                if not touched:
                    continue
                before = net_hpwl_for_checkpoint(net, idx, ca)
                after = net_hpwl_for_checkpoint(net, idx, cb)
                affected_nets.append({"net": net["name"], "hpwl_before": before,
                                      "hpwl_after": after, "hpwl_delta": after - before})
            affected_nets.sort(key=lambda x: abs(x["hpwl_delta"]), reverse=True)
            net_hpwl_delta_affected = sum(x["hpwl_delta"] for x in affected_nets)
        except Exception:
            affected_nets = []
            net_hpwl_delta_affected = None

    return {
        "ok": True,
        "checkpoint_a": checkpoint_path(workdir, checkpoint_a),
        "checkpoint_b": checkpoint_path(workdir, checkpoint_b),
        "iteration_delta": int(b.get("current_iter", 0) or 0) - int(a.get("current_iter", 0) or 0),
        "delta": {
            "hpwl": hpwl_delta,
            "density_overflow": ov_delta,
            "rudy_route_util_max": rudy_delta,
            "timing": {"available": False, "reason": "checkpoint does not persist setup/hold WNS"},
        },
        "dirty_closure": {
            "moved_cell_count": len(moved),
            "top_moved_cells": moved[:20],
            "affected_net_count": len(affected_nets),
            "affected_net_hpwl_delta": net_hpwl_delta_affected,
            "top_affected_nets": affected_nets[:20],
        },
        "fidelity": "gp",
    }


def propose_config(workdir: str | Path, checkpoint: str | None = None) -> dict:
    """Propose bounded config candidates as executable ieda_gp_run start actions."""
    cp = resolve_checkpoint(workdir, checkpoint)
    if not cp:
        return {"ok": False, "reason": "no checkpoint in workdir; run gp start first"}
    config_state = cp.get("config_state") or {}
    overflow = float(cp.get("sum_overflow", float("nan")))
    hpwl = int(cp.get("cur_hpwl") or cp.get("prev_hpwl") or 0)
    target_density = float(config_state.get("target_density", 0.8))
    target_overflow = float(config_state.get("target_overflow", 0.1))
    init_penalty = float(config_state.get("init_density_penalty", 1e-4))
    current = {
        "iteration": cp.get("current_iter"),
        "hpwl": hpwl,
        "overflow": overflow,
        "target_density": target_density,
        "target_overflow": target_overflow,
        "init_density_penalty": init_penalty,
        "is_opt_congestion": bool(config_state.get("is_opt_congestion")),
        "is_opt_timing": bool(config_state.get("is_opt_timing")),
    }
    candidate_input_def = str(Path(workdir) / "placement.def")
    if not Path(candidate_input_def).exists():
        candidate_input_def = str(workdir_context(workdir).get("input_def") or "")
    candidates = []
    def bounded(v, lo, hi):
        return round(min(max(v, lo), hi), 4)

    if not (overflow <= target_overflow + 1e-4):
        candidates.append({
            "id": "overflow_threshold_down",
            "hypothesis_fact": f"current overflow {overflow:.4f} is above target {target_overflow:.4f}; a lower stop threshold keeps the density objective engaged longer",
            "config_override": {"target_overflow": bounded(target_overflow * 0.5, 0.02, 0.5)},
            "executable_action": {"tool": "ieda_gp_run", "kind": "start", "input_def": candidate_input_def,
                                  "random_init": 0, "iterations": 100},
        })
        candidates.append({
            "id": "density_relief",
            "hypothesis_fact": f"current overflow {overflow:.4f} is above target {target_overflow:.4f}",
            "config_override": {"target_density": bounded(target_density - 0.05, 0.5, 0.95)},
            "executable_action": {"tool": "ieda_gp_run", "kind": "start", "input_def": candidate_input_def,
                                  "random_init": 0, "iterations": 20},
        })
        if init_penalty > 0:
            candidates.append({
                "id": "density_penalty_up",
                "hypothesis_fact": f"current init_density_penalty is {init_penalty:g}; higher starts spread cells sooner",
                "config_override": {"init_density_penalty": round(init_penalty * 2.0, 8)},
                "executable_action": {"tool": "ieda_gp_run", "kind": "start", "input_def": candidate_input_def,
                                      "random_init": 0, "iterations": 20},
            })
    else:
        candidates.append({
            "id": "density_allowance",
            "hypothesis_fact": f"overflow {overflow:.4f} is inside target; allowing higher target density may reduce HPWL",
            "config_override": {"target_density": bounded(target_density + 0.05, 0.5, 0.95)},
            "executable_action": {"tool": "ieda_gp_run", "kind": "start", "input_def": candidate_input_def,
                                  "random_init": 0, "iterations": 20},
        })
        if init_penalty > 0:
            candidates.append({
                "id": "density_penalty_down",
                "hypothesis_fact": f"current init_density_penalty is {init_penalty:g}; lower starts ease wirelength at same overflow budget",
                "config_override": {"init_density_penalty": round(init_penalty * 0.5, 8)},
                "executable_action": {"tool": "ieda_gp_run", "kind": "start", "input_def": candidate_input_def,
                                      "random_init": 0, "iterations": 20},
            })
    if not config_state.get("is_opt_congestion"):
        candidates.append({
            "id": "congestion_effort_on",
            "hypothesis_fact": "congestion objective is currently off; turn it on and evaluate route_util in the same batch",
            "config_override": {"congestion_effort": 1},
            "executable_action": {"tool": "ieda_gp_run", "kind": "start", "input_def": candidate_input_def,
                                  "random_init": 0, "iterations": 20, "report_route_util": 1},
        })

    batches = trajectory(workdir, 0).get("batches", [])
    budget_candidates = []
    if len(batches) >= 2:
        first = batches[0].get("hpwl")
        last = batches[-1].get("hpwl")
        if isinstance(first, int) and isinstance(last, int) and first > 0:
            settled = abs(last - first) / float(first) < 0.005
        else:
            settled = False
        if settled:
            budget_candidates.append({"id": "budget_short", "iterations": 20,
                                      "hypothesis_fact": "recent HPWL changed less than 0.5%; short probe batches are cheap"})
        else:
            budget_candidates.append({"id": "budget_long", "iterations": 100,
                                      "hypothesis_fact": "recent HPWL is still moving; longer batch avoids frequent checkpoint churn"})
    else:
        budget_candidates.append({"id": "budget_default", "iterations": 40,
                                  "hypothesis_fact": "too little trajectory data; use medium batch"})

    return {"ok": True, "workdir": str(workdir), "checkpoint_path": checkpoint_path(workdir, checkpoint),
            "current": current, "config_candidates": candidates, "budget_candidates": budget_candidates}


def trajectory(workdir: str | Path, top_n: int = 0) -> dict:
    """Return the append-only batch history. Facts only, no verdict or advice."""
    ledger = Path(workdir) / "pl/gp_experiments.jsonl"
    if not ledger.exists():
        return {"ok": False, "reason": "pl/gp_experiments.jsonl missing"}
    rows = []
    for raw in ledger.read_text().splitlines():
        if not raw.strip():
            continue
        try:
            row = json.loads(raw)
        except Exception:
            continue
        rows.append({
            "mode": row.get("mode"),
            "start_iteration": row.get("start_iteration"),
            "end_iteration": row.get("end_iteration"),
            "hpwl": row.get("hpwl"),
            "overflow": row.get("overflow"),
            "route_util": row.get("route_util"),
            "stop_reason": row.get("stop_reason"),
            "scope": row.get("scope"),
            "checkpoint": row.get("checkpoint"),
        })
    if top_n and top_n > 0:
        rows = rows[-top_n:]
    return {"ok": True, "workdir": str(workdir), "batch_count": len(rows), "batches": rows}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("command", choices=["status", "checkpoints", "grid", "hotspots", "longnets", "trajectory", "propose_regions",
                                        "freeze_instances", "propose_longnet_instances", "propose_config",
                                        "propose_region_density", "propose_freeze", "unstable", "verify_delta"])
    ap.add_argument("--workdir", required=True)
    ap.add_argument("--checkpoint")
    ap.add_argument("--checkpoint-a")
    ap.add_argument("--checkpoint-b")
    ap.add_argument("--def-path")
    ap.add_argument("--priority", default="density")
    ap.add_argument("--region")
    ap.add_argument("--top-n", type=int, default=5)
    ap.add_argument("--min-cell-count", type=int, default=20)
    ap.add_argument("--max-cell-count", type=int, default=200)
    args = ap.parse_args()

    if args.command == "status":
        print(json.dumps(design_status(args.workdir, args.checkpoint), indent=2))
    elif args.command == "checkpoints":
        print(json.dumps({"ok": True, "checkpoints": checkpoint_list(args.workdir)}, indent=2))
    elif args.command == "grid":
        cp = resolve_checkpoint(args.workdir, args.checkpoint)
        grid = grid_report(args.workdir)
        if not grid:
            print(json.dumps({"ok": False, "reason": "gp_grid_report.json missing"}, indent=2))
            return 1
        sorted_bins = sorted(grid.get("bins", []), key=lambda b: b.get("overflow_area", 0), reverse=True)
        bins = sorted_bins if args.top_n <= 0 else sorted_bins[:max(1, args.top_n)]
        print(json.dumps({"ok": True, "checkpoint_path": checkpoint_path(args.workdir, args.checkpoint),
                          "iteration": cp.get("current_iter"), "bin_cnt": (grid.get("bin_cnt_x"), grid.get("bin_cnt_y")),
                          "bins": bins}, indent=2))
    elif args.command == "hotspots":
        print(json.dumps(diagnose_hotspots(args.workdir, args.checkpoint, args.top_n), indent=2))
    elif args.command == "longnets":
        print(json.dumps(diagnose_longnets(args.workdir, args.checkpoint, args.top_n, args.def_path), indent=2))
    elif args.command == "trajectory":
        print(json.dumps(trajectory(args.workdir, args.top_n), indent=2))
    elif args.command == "propose_longnet_instances":
        print(json.dumps(propose_longnet_instances(args.workdir, args.checkpoint, args.top_n, args.def_path), indent=2))
    elif args.command == "freeze_instances":
        print(json.dumps(freeze_instances(args.workdir, args.region, args.checkpoint), indent=2))
    elif args.command == "propose_regions":
        print(json.dumps(propose_regions(args.workdir, args.checkpoint, args.priority, args.top_n,
                                         args.min_cell_count, args.max_cell_count, args.def_path), indent=2))
    elif args.command == "propose_config":
        print(json.dumps(propose_config(args.workdir, args.checkpoint), indent=2))
    elif args.command == "propose_region_density":
        print(json.dumps(propose_region_density(args.workdir, args.region, args.checkpoint), indent=2))
    elif args.command == "propose_freeze":
        print(json.dumps(propose_freeze(args.workdir, args.region, args.checkpoint), indent=2))
    elif args.command == "unstable":
        print(json.dumps(diagnose_unstable_region(args.workdir, args.checkpoint_a, args.checkpoint_b, args.top_n), indent=2))
    elif args.command == "verify_delta":
        print(json.dumps(verify_delta(args.workdir, args.checkpoint_a, args.checkpoint_b, args.def_path), indent=2))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except SystemExit:
        raise
    except Exception as error:
        print(json.dumps({"ok": False, "error": str(error),
                          "reason": "gp_toolbox command failed before producing a result"}, indent=2))
        raise SystemExit(1)
