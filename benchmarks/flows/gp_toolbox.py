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


def quantile_summary(values: list[float]) -> dict | None:
    """Text-readable distribution shape for a TEXT LLM (not a histogram).

    The agent is not multimodal: bucket counts force it to mentally reconstruct
    a shape and are blind to tail steepness. Quantiles + threshold counts let it
    read "where the body is and how long the tail is" directly, e.g.
    P50=0.93 P95=1.82 P99=2.03 max=2.31 reads as "tail already breaks the 2.0
    ceiling and is steep". Histograms/heatmaps belong in saved PNG/SVG artifacts
    for human audit, never in the agent context (iron rule).
    """
    if not values:
        return None
    s = sorted(values)
    n = len(s)

    def q(p: float) -> float:
        # nearest-rank quantile (matches numpy percentile default closely enough)
        idx = max(0, min(n - 1, int(round((n - 1) * p))))
        return float(s[idx])

    return {
        "count": n,
        "p50": round(q(0.50), 4),
        "p90": round(q(0.90), 4),
        "p95": round(q(0.95), 4),
        "p99": round(q(0.99), 4),
        "max": round(s[-1], 4),
        "min": round(s[0], 4),
    }


def _read_util_matrix(workdir: Path) -> tuple[list[list[float]], dict]:
    """Read the cached 64x64 RUDY map: (rows, congestion_result.json)."""
    congestion = load_json(Path(workdir) / "congestion_result.json") or {}
    util_path = Path(workdir) / "rudy_util.csv"
    rows: list[list[float]] = []
    if util_path.exists():
        for line in util_path.read_text().splitlines():
            vals = [float(t) for t in line.split(",") if t.strip() != ""]
            if vals:
                rows.append(vals)
    return rows, congestion


def merge_util_regions(rows: list[list[float]], congestion: dict, top_n: int = 8) -> list[dict]:
    """Merge connected violating RUDY bins (util >= threshold) into hot REGIONS.

    A per-bin executable list is noise: one local_run evacuates a region, not
    thousands of individual bins. Region = connected (4-neighbor) violating
    bins, summarized as bbox + peak/mean util + severity. This is the semantic
    object the agent can act on; the raw grid stays inside the EDA tool.
    """
    if not rows or not rows[0]:
        return []
    region = congestion.get("region")
    if not region or len(region) < 4:
        return []
    bin_x = int(congestion.get("bin_cnt_x") or 64)
    bin_y = int(congestion.get("bin_cnt_y") or 64)
    lx, ly, ux, uy = (float(v) for v in region[:4])
    size_x = (ux - lx) / bin_x
    size_y = (uy - ly) / bin_y
    HARD = 2.0

    # Build violating cells with geometry + row/col for connectivity.
    cells: list[dict] = []
    for r, row in enumerate(rows):
        if r >= bin_y:
            break
        y = ly + (bin_y - 1 - r) * size_y
        for c, util in enumerate(row):
            if c >= bin_x or util <= 1.0:
                continue
            x = lx + c * size_x
            cells.append({
                "row": r, "col": c,
                "ll_x": int(x), "ll_y": int(y),
                "ur_x": int(min(x + size_x, ux)), "ur_y": int(min(y + size_y, uy)),
                "util": float(util),
            })
    if not cells:
        return []

    # BFS connected components over violating cells (4-neighborhood).
    idx: dict[tuple[int, int], dict] = {(c["row"], c["col"]): c for c in cells}
    seen: set[tuple[int, int]] = set()
    groups: list[list[dict]] = []
    for key, cell in idx.items():
        if key in seen:
            continue
        stack = [key]
        seen.add(key)
        group = [cell]
        while stack:
            r, c = stack.pop()
            for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nk = (r + dr, c + dc)
                if nk in idx and nk not in seen:
                    seen.add(nk)
                    group.append(idx[nk])
                    stack.append(nk)
        groups.append(group)

    out: list[dict] = []
    for g in groups:
        peak = max(b["util"] for b in g)
        mean = sum(b["util"] for b in g) / len(g)
        out.append({
            "id": f"region-{len(out)}",
            "domain": "congestion",
            "bbox": f"{min(b['ll_x'] for b in g)} {min(b['ll_y'] for b in g)} "
                    f"{max(b['ur_x'] for b in g)} {max(b['ur_y'] for b in g)}",
            "bin_count": len(g),
            "peak_utilization": round(peak, 4),
            "mean_utilization": round(mean, 4),
            "severity": "bad-2" if peak >= HARD else "bad-1",
            "violation_depth": round(peak - 1.0, 4),
            "row_min": min(b["row"] for b in g), "row_max": max(b["row"] for b in g),
            "col_min": min(b["col"] for b in g), "col_max": max(b["col"] for b in g),
        })
    out.sort(key=lambda x: (-x["peak_utilization"], -x["bin_count"]))
    return out[:max(1, top_n)]


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


def _checkpoint_data(cp: str) -> dict:
    data = load_json(cp)
    if data is None:
        raise ValueError(f"checkpoint is not valid JSON: {cp}")
    return data


def resolve_checkpoint(workdir: str | Path, checkpoint: str | None) -> dict:
    """Resolve a checkpoint reference: a path, or the symbols latest/start."""
    if checkpoint and checkpoint not in ("latest", "current", "start", "first", "oldest"):
        cp = Path(checkpoint)
        if not cp.exists():
            raise ValueError(f"checkpoint does not exist: {checkpoint}")
        return _checkpoint_data(str(cp))
    if checkpoint in ("start", "first", "oldest"):
        items = checkpoint_list(workdir)
        if not items:
            raise ValueError(f"no checkpoints in workdir {workdir}; run ieda_gp_run kind=start or kind=full first")
        return _checkpoint_data(items[0]["checkpoint"])
    cp = latest_checkpoint(workdir)
    if not cp:
        raise ValueError(f"no checkpoint in workdir {workdir}; run ieda_gp_run kind=start or kind=full first")
    return _checkpoint_data(cp)


def checkpoint_path(workdir: str | Path, checkpoint: str | None) -> str:
    if checkpoint and checkpoint not in ("latest", "current", "start", "first", "oldest"):
        return str(Path(checkpoint))
    if checkpoint in ("start", "first", "oldest"):
        items = checkpoint_list(workdir)
        if not items:
            raise ValueError(f"no checkpoints in workdir {workdir}")
        return items[0]["checkpoint"]
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
    seen: set[str] = set()
    for path in sorted(list(root.glob("*.json")) + list(root.rglob("*.json"))):
        rel = str(path.relative_to(root))
        if "archive/" in rel or "_lg_verify" in rel:
            continue
        name = path.name
        if name in ("gp_agent_state.json", "search.json", "gp_metrics_compare.json",
                    "gp_full_metrics.json", "timing_paths.json", "congestion_result.json",
                    "result.json"):
            continue
        key = str(path)
        if key in seen:
            continue
        data = load_json(path)
        if not data or "current_iter" not in data:
            continue
        seen.add(key)
        items.append({
            "checkpoint": str(path),
            "name": rel,
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
                "hint": "run ieda_gp_run kind=start or kind=full first, then observe again"}
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
    # Die area + utilization facts (placement.def DIEAREA vs checkpoint instance area)
    try:
        placed = Path(workdir) / "placement.def"
        if placed.exists():
            text = placed.read_text(errors="ignore")
            m_die = re.search(r"^\s*DIEAREA\s*\(\s*([-\d]+)\s+([-\d]+)\s*\)\s*\(\s*([-\d]+)\s+([-\d]+)\s*\)", text, re.M | re.I)
            if m_die:
                llx, lly, urx, ury = (int(x) for x in m_die.groups())
                die_area = (urx - llx) * (ury - lly)
                inst_area = cp.get("total_inst_area")
                out["die_area"] = {"llx": llx, "lly": lly, "urx": urx, "ury": ury,
                                   "area": die_area, "unit": "def_units^2"}
                if inst_area:
                    util = float(inst_area) / float(die_area) if die_area else None
                    out["utilization"] = {"inst_area": float(inst_area), "die_area": die_area,
                                          "ratio": round(util, 4) if util is not None else None,
                                          "note": "ratio is inst_area/die_area of this design's own placement; use it only as a placement-density fact, not as a target"}
    except Exception:
        pass
    # DEF-level HPWL of the exported placement (same evaluator as verify metrics)
    try:
        placed = Path(workdir) / "placement.def"
        state = workdir_context(workdir)
        lef = state.get("lef")
        if placed.exists() and lef and Path(str(lef)).exists():
            import subprocess as _sp
            import sys as _sys
            from pathlib import Path as _P
            repo = _P(__file__).resolve().parents[2]
            proc = _sp.run([_PY_EXE, str(repo / "benchmarks/flows/def_hpwl_eval.py"),
                            str(lef), str(placed)], cwd=repo, stdout=_sp.PIPE,
                           stderr=_sp.DEVNULL, text=True, timeout=600)
            m = re.search(r"HPWL=(\d+)", proc.stdout or "")
            if m:
                out["def_hpwl"] = metric(int(m.group(1)), True)
                out["def_hpwl_unit"] = "def"
    except Exception:
        out["def_hpwl"] = metric(None, False, "def_hpwl eval failed; run a GP action first to record lef")
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

    if priority == "congestion":
        return propose_congestion_regions(workdir, checkpoint, top_n)

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
        peak = max(b.get("density", 0.0) for b in group)
        suggested = max(0.6, min(1.0, round(1.0 / peak, 2))) if peak > 0 else 1.0
        region = {
            "id": f"region-{gi + 1}",
            "kind": "density",
            "bin_indices": [b["row"] * cnt_x + b["col"] for b in group],
            "bbox": f"{bbox[0]} {bbox[1]} {bbox[2]} {bbox[3]}",
            "active_cell_count": len(active),
            "halo_cell_count": 0,
            "density_overflow": max(b.get("overflow_area", 0) for b in group),
            "peak_density": peak,
            "score": max(b.get("overflow_area", 0) for b in group),
            "reason": f"merged {len(group)} connected high-overflow bins",
            "density_target_options": [t for t in (0.6, 0.7, 0.8, 0.9, 1.0) if t >= suggested - 1e-9],
            "executable_action": {
                "tool": "ieda_gp_run",
                "kind": "local_run",
                "scope": "region",
                "scope_region": f"{bbox[0]} {bbox[1]} {bbox[2]} {bbox[3]}",
                "scope_density_target": suggested,
                "checkpoint": checkpoint_path(workdir, checkpoint),
            },
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
        # Dead-end guard: instead of failing, snap the request to the nearest
        # grid bin so the proposal stays executable (agents pass regions from
        # stale maps or other DEFs of different die size).
        bins = grid.get("bins", [])
        if not bins:
            return {"ok": False, "reason": "region does not overlap any GP bin"}
        cx = (llx + urx) / 2.0
        cy = (lly + ury) / 2.0
        nearest = min(bins, key=lambda b: ((b["ll_x"] + b["ur_x"]) / 2.0 - cx) ** 2 + ((b["ll_y"] + b["ur_y"]) / 2.0 - cy) ** 2)
        snapped = f"{nearest['ll_x']} {nearest['ll_y']} {nearest['ur_x']} {nearest['ur_y']}"
        llx, lly, urx, ury = nearest["ll_x"], nearest["ll_y"], nearest["ur_x"], nearest["ur_y"]
        overlap = [nearest]
        peak = max(b.get("density", 0.0) for b in overlap)
        suggested = max(0.6, min(1.0, round(1.0 / peak, 2)))
        return {"ok": True, "checkpoint_path": checkpoint_path(workdir, checkpoint),
                "iteration": cp.get("current_iter"), "region": snapped,
                "requested_region": region, "snapped": True, "overlapping_bins": 1,
                "peak_density": peak, "suggested_density_target": suggested,
                "density_target_options": [t for t in (0.5, 0.6, 0.7, 0.8, 0.9, 1.0) if t >= suggested - 1e-9],
                "reason": "requested region missed the grid; snapped to nearest bin"}
    peak = max(b.get("density", 0.0) for b in overlap)
    suggested = max(0.6, min(1.0, round(1.0 / peak, 2)))
    return {"ok": True, "checkpoint_path": checkpoint_path(workdir, checkpoint),
            "iteration": cp.get("current_iter"), "region": region,
            "overlapping_bins": len(overlap), "peak_density": peak,
            "suggested_density_target": suggested,
            "density_target_options": [t for t in (0.5, 0.6, 0.7, 0.8, 0.9, 1.0) if t >= suggested - 1e-9],
            "core_target_density_reference": (cp.get("config_state") or {}).get("target_density"),
            "executable_action": {
                "tool": "ieda_gp_run",
                "kind": "apply_region_density",
                "region": region,
                "scope_density_target": suggested,
            },
            "prediction_status": "unavailable"}


def propose_freeze(workdir: str | Path, region: str, checkpoint: str | None = None) -> dict:
    cp = resolve_checkpoint(workdir, checkpoint)
    names = cp.get("instance_names") or []
    coords = cp.get("instance_density_coords") or []
    active = instance_points_in_bbox(region, names, coords)
    inside = {name for name, _xy in active}
    outside = [name for name in names if name not in inside]
    return {"ok": True, "checkpoint_path": checkpoint_path(workdir, checkpoint),
            "iteration": cp.get("current_iter"), "region": region,
            "cells_in_region": len(inside), "freeze_cell_count": len(inside),
            "active_outside_cell_count": len(outside),
            "scope_instances": ",".join(outside),
            "executable_action": {
                "tool": "ieda_gp_run",
                "kind": "apply_freeze",
                "region": region,
            },
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
    if not checkpoint_a and not checkpoint_b:
        checkpoint_a = "start"
        checkpoint_b = "latest"
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

    # Density tunables: the FULL decision surface, never an if/else chain that
    # picks a subset based on current state (iron rule: EDA does not decide for
    # the agent). Every tunable exposes both directions, each with its current
    # value + the FACT of what it changes + a data-derived sample inside the
    # feasible band. The agent chooses; EDA only bounds the samples to the
    # physically meaningful band and never hints which one is "better".
    candidates.append({
        "id": "target_density_lower",
        "tunable": "target_density", "current": target_density,
        "sample": bounded(target_density - 0.05, 0.5, 0.95),
        "fact": "lower target density spreads cells more -> lower peak density and more even distribution, typically at the cost of longer wirelength",
        "config_override": {"target_density": bounded(target_density - 0.05, 0.5, 0.95)},
        "executable_action": {"tool": "ieda_gp_run", "kind": "start", "input_def": candidate_input_def,
                              "random_init": 0, "iterations": 20},
    })
    candidates.append({
        "id": "target_density_higher",
        "tunable": "target_density", "current": target_density,
        "sample": bounded(target_density + 0.05, 0.5, 0.95),
        "fact": "higher target density allows tighter packing -> shorter wirelength, but raises peak density and congestion risk",
        "config_override": {"target_density": bounded(target_density + 0.05, 0.5, 0.95)},
        "executable_action": {"tool": "ieda_gp_run", "kind": "start", "input_def": candidate_input_def,
                              "random_init": 0, "iterations": 20},
    })
    candidates.append({
        "id": "target_overflow_lower",
        "tunable": "target_overflow", "current": target_overflow,
        "sample": bounded(target_overflow * 0.5, 0.02, 0.5),
        "fact": "lower stop threshold keeps the density objective engaged longer before the solver declares convergence",
        "config_override": {"target_overflow": bounded(target_overflow * 0.5, 0.02, 0.5)},
        "executable_action": {"tool": "ieda_gp_run", "kind": "start", "input_def": candidate_input_def,
                              "random_init": 0, "iterations": 100},
    })
    candidates.append({
        "id": "init_density_penalty_higher",
        "tunable": "init_density_penalty", "current": init_penalty,
        "sample": round(init_penalty * 2.0, 8),
        "fact": "higher initial density penalty spreads cells sooner in the run",
        "config_override": {"init_density_penalty": round(init_penalty * 2.0, 8)},
        "executable_action": {"tool": "ieda_gp_run", "kind": "start", "input_def": candidate_input_def,
                              "random_init": 0, "iterations": 20},
    })
    candidates.append({
        "id": "init_density_penalty_lower",
        "tunable": "init_density_penalty", "current": init_penalty,
        "sample": round(max(0.0, init_penalty * 0.5), 8),
        "fact": "lower initial density penalty eases wirelength at the same overflow budget",
        "config_override": {"init_density_penalty": round(max(0.0, init_penalty * 0.5), 8)},
        "executable_action": {"tool": "ieda_gp_run", "kind": "start", "input_def": candidate_input_def,
                              "random_init": 0, "iterations": 20},
    })
    # Congestion tunable: solver-internal effort levels are wrapped into
    # SEMANTIC bands. The agent decides in semantics (mild / eval-aligned /
    # constraint-first), never in magic numbers; each band carries its concrete
    # effort number so the choice is executable. All bands are always present
    # (no if/else chain hiding some based on state).
    effort = int(config_state.get("congestion_effort_level") or 0)
    # ce6 (constraint-first) is the strongest congestion diffuser: it drives the
    # per-bin density screen so hot bins shed cells into rich ones. Empirically it
    # is REQUIRED for big/high-congestion designs (salsa20/s38584 nangate45 ce6
    # dropped peak RUDY from ~6 to ~1.9/1.2 while ce3/ce5 stayed ~6), and it is
    # harmless on small designs. Recommend it FIRST for high-congestion designs.
    congestion_bands = [
        {"id": "congestion_band_constraint_first", "band": "constraint-first", "effort": 6,
         "current": effort == 6, "recommended": True, "recommend_timing": True,
         "fact": "per-bin density screens: only bins violating their own target lower it, satisfied bins relax back; STRONGEST congestion diffusion (big/high-congestion designs need ce6: salsa20_nangate45 ce6 dropped peak 6->1.9); activates after wirelength phase, >=500 iterations. PAIR WITH timing=1: ce6 fixes congestion (hard ceiling) while timing-driven GP also optimizes setup/tns so the result is a FULL win (congestion+wirelength+timing) vs Innovus - s1238_ics55 ce6+timing beat Innovus on HPWL/RUDY/WNS/freq all at once."},
        {"id": "congestion_band_eval_aligned", "band": "eval-aligned", "effort": 4,
         "current": effort == 4,
         "fact": "optimizes the same plain-RUDY model the verify evaluator scores; pair with bin_cnt=64; activates after the wirelength phase, so needs >=500 iterations"},
        {"id": "congestion_band_mild", "band": "mild", "effort": 3,
         "current": effort == 3,
         "fact": "mild congestion penalty; cheap, low coupling to wirelength; activates only after the wirelength phase, so needs >=500 iterations to show any effect"},
    ]
    for band in congestion_bands:
        candidates.append({
            "id": band["id"],
            "tunable": "congestion_effort",
            "band": band["band"],
            "current": band["current"],
            "fact": band["fact"],
            "config_override": {"congestion_effort": band["effort"],
                                **({"bin_cnt": 64} if band["effort"] == 4 else {}),
                                **({"timing": 1} if band.get("recommend_timing") else {})},
            "executable_action": {"tool": "ieda_gp_run", "kind": "start", "input_def": candidate_input_def,
                                  "random_init": 0, "iterations": 500, "congestion_effort": band["effort"],
                                  **({"timing": 1} if band.get("recommend_timing") else {}),
                                  "report_route_util": 1},
        })
    if not config_state.get("is_opt_timing"):
        candidates.append({
            "id": "timing_effort_on",
            "hypothesis_fact": "timing objective is off; turning it on updates net weights from iSTA slacks (opt_overflow_list [0.15,0.20,0.25,0.30] is applied automatically)",
            "config_override": {"timing": 1},
            "executable_action": {"tool": "ieda_gp_run", "kind": "start", "input_def": candidate_input_def,
                                  "random_init": 0, "iterations": 100, "timing": 1, "report_route_util": 1},
        })
    phi_min = float(config_state.get("min_phi_coef") or 0.0)
    phi_max = float(config_state.get("max_phi_coef") or 0.0)
    if phi_max > 0 and phi_max < 0.99:
        candidates.append({
            "id": "phi_coef_up",
            "hypothesis_fact": f"max_phi_coef is {phi_max}; raising it keeps the density penalty from growing too fast",
            "config_override": {"max_phi_coef": round(min(0.99, phi_max + 0.05), 3)},
            "executable_action": {"tool": "ieda_gp_run", "kind": "start", "input_def": candidate_input_def,
                                  "random_init": 0, "iterations": 100, "report_route_util": 1},
        })
    if phi_min > 0:
        candidates.append({
            "id": "phi_coef_down",
            "hypothesis_fact": f"min_phi_coef is {phi_min}; lowering it lets the density penalty shrink further in late iterations",
            "config_override": {"min_phi_coef": round(max(0.5, phi_min - 0.05), 3)},
            "executable_action": {"tool": "ieda_gp_run", "kind": "start", "input_def": candidate_input_def,
                                  "random_init": 0, "iterations": 100, "report_route_util": 1},
        })
    candidates.append({
        "id": "seed_anchor_half",
        "tunable": "seed_anchor_strength",
        "current": 0.0,
        "sample": 0.5,
        "fact": "anchors every cell halfway to the input DEF positions; useful when the input placement already has a property worth preserving",
        "config_override": {"seed_anchor_strength": 0.5},
        "executable_action": {"tool": "ieda_gp_run", "kind": "start", "input_def": candidate_input_def,
                              "random_init": 0, "iterations": 100, "seed_anchor_strength": 0.5, "report_route_util": 1},
    })
    grid_bins = int(config_state.get("bin_cnt_x") or 0)
    if grid_bins > 0 and grid_bins < 64:
        candidates.append({
            "id": "congestion_grid_64",
            "hypothesis_fact": f"GP grid is {grid_bins}x{grid_bins} (adaptive), but the verify RUDY evaluator scores 64x64; matching the grid lets the solver see the same congestion spikes it is graded on",
            "config_override": {"bin_cnt": 64},
            "executable_action": {"tool": "ieda_gp_run", "kind": "start", "input_def": candidate_input_def,
                                  "random_init": 0, "iterations": 100, "bin_cnt": 64, "report_route_util": 1},
        })

    # Budget: the FACT (recent HPWL drift rate) is reported; the budget bands
    # are all present so the agent picks. EDA computes the drift but never maps
    # drift -> "use short batch" (that mapping is the agent's decision).
    batches = trajectory(workdir, 0).get("batches", [])
    hpwl_drift = None
    if len(batches) >= 2:
        first = batches[0].get("hpwl")
        last = batches[-1].get("hpwl")
        if isinstance(first, (int, float)) and isinstance(last, (int, float)) and first > 0:
            hpwl_drift = round(abs(last - first) / float(first), 4)
    budget_candidates = [
        {"id": "budget_short", "iterations": 20,
         "fact": "short probe batches are cheap"},
        {"id": "budget_medium", "iterations": 40,
         "fact": "medium batches balance checkpoint churn against progress"},
        {"id": "budget_long", "iterations": 100,
         "fact": "longer batches avoid frequent checkpoint churn"},
        {"id": "budget_congestion_activation", "iterations": 500,
         "fact": "congestion_effort activates only after the wirelength phase; >=500 iterations are required for congestion-effort differences to show"},
    ]

    return {"ok": True, "workdir": str(workdir), "checkpoint_path": checkpoint_path(workdir, checkpoint),
            "current": current, "hpwl_drift_over_history": hpwl_drift,
            "config_candidates": candidates, "budget_candidates": budget_candidates}


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


def trend_summary(workdir: str | Path, top_n: int = 6) -> dict | None:
    """Branch-history trajectory digest: facts only, no verdict.

    Each recent batch carries its metrics plus the delta against the previous
    batch, so the agent reads direction without re-deriving it. This is the
    "trend" element of the decision surface; raw batches stay in observe
    kind=trajectory.
    """
    tr = trajectory(workdir, 0)
    if not tr.get("ok"):
        return None
    batches = tr.get("batches") or []
    if not batches:
        return None
    recent = batches[-max(1, top_n):]
    out = {"batch_count_total": len(batches), "recent_batches": []}
    # Stall facts (no verdict): how many consecutive recent batches failed to
    # improve the solver's route-util peak. route_util is the solver-internal
    # LUT-RUDY peak (lower is better); the agent decides when this means
    # diminishing returns. Purely descriptive numbers.
    rts = [float(b.get("route_util")) for b in batches if isinstance(b.get("route_util"), (int, float))]
    if rts:
        best_all = min(rts)
        stall = 0
        running_best = rts[-1]
        for v in reversed(rts[:-1]):
            if v < running_best:
                running_best = v
                break
            stall += 1
        out["best_route_util_all"] = round(best_all, 6)
        out["best_route_util_recent"] = round(min(rts[-max(1, top_n):]), 6)
        out["route_util_stall_batches"] = stall
        out["note"] = ("route_util_stall_batches counts consecutive trailing batches without a new best route-util; "
                        "it is a fact about the recent trend, not a stop signal")
    prev = None
    for b in recent:
        hpwl = b.get("hpwl")
        overflow = b.get("overflow")
        route_util = b.get("route_util")
        entry = {
            "mode": b.get("mode"),
            "hpwl": hpwl,
            "overflow": overflow,
            "route_util": route_util,
        }
        if prev is not None:
            entry["hpwl_delta"] = (hpwl - prev["hpwl"]) if isinstance(hpwl, (int, float)) and isinstance(prev["hpwl"], (int, float)) else None
            entry["overflow_delta"] = (round(overflow - prev["overflow"], 6)
                                       if isinstance(overflow, (int, float)) and isinstance(prev["overflow"], (int, float)) else None)
            entry["route_util_delta"] = (round(route_util - prev["route_util"], 6)
                                         if isinstance(route_util, (int, float)) and isinstance(prev["route_util"], (int, float)) else None)
        out["recent_batches"].append(entry)
        prev = {"hpwl": hpwl, "overflow": overflow, "route_util": route_util}
    return out


def propose_congestion_regions(workdir: str | Path, checkpoint: str | None = None, top_n: int = 5) -> dict:
    """Regions from the cached RUDY utilization map (written by observe congestion_hotspots)."""
    cp = resolve_checkpoint(workdir, checkpoint)
    summary = load_json(Path(workdir) / "congestion_result.json") or {}
    util_path = Path(workdir) / "rudy_util.csv"
    if not util_path.exists():
        return {"ok": False, "reason": "no rudy_util.csv in workdir; run observe kind=congestion_hotspots first (cached per DEF)"}
    rows = []
    for line in util_path.read_text().splitlines():
        vals = [float(t) for t in line.split(",") if t.strip() != ""]
        if vals:
            rows.append(vals)
    region = summary.get("region")
    if not region or len(region) < 4:
        return {"ok": False, "reason": "congestion_result.json has no usable region"}
    bin_x = int(summary.get("bin_cnt_x") or 64)
    bin_y = int(summary.get("bin_cnt_y") or 64)
    lx, ly, ux, uy = region[:4]
    size_x = (ux - lx) / bin_x
    size_y = (uy - ly) / bin_y
    bins = []
    for r, row in enumerate(rows):
        y = ly + (bin_y - 1 - r) * size_y
        for c, util in enumerate(row):
            if util <= 1.0:
                continue
            x = lx + c * size_x
            bins.append({"row": r, "col": c, "utilization": util,
                         "llx": int(x), "lly": int(y), "urx": int(min(x + size_x, ux)), "ury": int(min(y + size_y, uy))})
    bins.sort(key=lambda b: -b["utilization"])
    selected = bins[: max(1, top_n)]
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
        merged.append({"bbox": rect, "utilization": b["utilization"],
                       "region": f"{rect[0]} {rect[1]} {rect[2]} {rect[3]}"})
    regions = []
    for m in merged:
        regions.append({
            "id": f"congestion-{len(regions) + 1}",
            "kind": "congestion",
            "bbox": m["region"],
            "peak_utilization": m["utilization"],
            "density_target_options": [0.6, 0.7, 0.8, 0.9, 1.0],
            "executable_action": {
                "tool": "ieda_gp_run", "kind": "local_run", "scope": "region",
                "scope_region": m["region"], "scope_density_target": 0.8,
                "checkpoint": checkpoint_path(workdir, checkpoint),
            },
            "prediction_status": "unavailable",
        })
    return {"ok": True, "checkpoint_path": checkpoint_path(workdir, checkpoint),
            "iteration": cp.get("current_iter"), "priority": "congestion",
            "bin_cnt": (bin_x, bin_y),
            "rudy_utilization_max": summary.get("rudy_utilization_max"),
            "regions": regions}


def violations_report(workdir: str | Path, checkpoint: str | None = None, check_timing: bool = True) -> dict:
    """Constraint-first problem inventory (balanced-GP contract, v2 semantics).

    Two-tier structure - the core fix after wave1/wave2 showed that summing
    all three domains into one "total_bad" lets an agent buy congestion relief
    with HPWL cuts, which are the very thing that CREATES wiring demand:

    TIER 1 - hard constraint (state acceptance gate):
      congestion (RUDY utilization). RUDY utilization = wiring demand /
      routing capacity, so 1.0 means a bin is exactly full and values far
      above 1.0 are physically unroutable. The state is UNACCEPTABLE when the
      peak RUDY exceeds HARD_RUDY_MAX (a physical constant, not a per-case
      number). Density/timing/HPWL optimization is only meaningful BELOW this
      ceiling - an agent must first get congestion under the cap, then optimize.

    TIER 2 - soft clearing targets (the optimization objective):
      density (solver grid bins over their target) and timing (negative-slack
      iSTA paths). These are the "short boards" to eliminate; they do NOT
      conflict with HPWL, so clearing them to zero is a coherent goal.

    total_bad_objects therefore counts ONLY tier-2 (density + timing).
    Congestion bad bins are still listed (with executable net/region actions)
    but they never enter total_bad_objects - they gate the whole state via
    congestion_hard_violation instead.

    - density bad: solver grid bins whose cell density exceeds their density
      target (grid_report). bad-2 when delta > 0.15, else bad-1.
    - congestion: cached verify-RUDY cells (congestion_result.json +
      rudy_util.csv). Hard-violated when peak util > HARD_RUDY_MAX.
    - timing bad: cached iSTA paths with negative slack (timing_paths.json).
    Each violating object emits the executable_action (region/instances) the
    run tool accepts verbatim, so the report doubles as the next-step list.
    """
    HARD_RUDY_MAX = 2.0  # physical: 2x routing capacity is unroutable for any PDK
    # Soft congestion pull: peak RUDY must also NOT REGRESS against the design's
    # own iEDA raw-GP baseline (gp_baseline_def). The hard ceiling alone only
    # rejects states above 2.0; without this second gate an agent can spend
    # congestion inside the 2.0 band to buy HPWL (apb4 wave4: 1.845 vs baseline
    # 1.513, still "hard-ok"). This is a TARGET, not a step - it uses iEDA's own
    # baseline, never Innovus, so it keeps the no-GT rule.
    # Soft congestion pull: peak RUDY must NOT REGRESS vs the design's own iEDA raw-GP
    # baseline (gp_baseline_def). Tolerance is 1.00 (not 1.02): the goal is to keep
    # congestion no worse than the design's own baseline floor, NOT +2% above it. This
    # is a TARGET, not a step, using the iEDA baseline (never Innovus) so the no-GT rule
    # holds. A candidate that is only *just* below the baseline (small margin) is still
    # considered "close to the floor" and is NOT a congestion win worth trading for HPWL.
    RUDY_REGRESSION_TOLERANCE = 1.00
    # Congestion clear target: peak RUDY must land at or below this to count as a
    # congestion WIN (not merely 'not regressed'). Derived ONLY from the iEDA raw-GP
    # baseline (never Innovus, keeps the no-GT rule), tightened by a factor so the
    # agent actually pushes congestion below its own floor instead of stopping just
    # under it. If the design's own baseline already exceeds the hard ceiling, this
    # collapses to the hard ceiling (the binding constraint).
    CONGESTION_CLEAR_TARGET_FACTOR = 0.95  # target = min(2.0, baseline*0.95)
    try:
        cp_path = checkpoint_path(workdir, checkpoint)
    except Exception:
        cp_path = None
    problems: list[dict] = []
    violations: dict = {"density": {"objects": [], "bad_1": 0, "bad_2": 0},
                        "congestion": {"objects": [], "bad_1": 0, "bad_2": 0},
                        "timing": {"objects": [], "bad_1": 0, "bad_2": 0}}
    total_bins = 0

    # Crossing-net cones for congestion objects (net-level evacuation exit):
    # hot bins whose demand comes from nets threading through them cannot be
    # fixed by moving the few cells inside the bin - the executable surface
    # must also offer the instance cones of those nets (scope=instances).
    crossing_nets: list = []
    cnj = load_json(Path(workdir) / "congestion_nets.json")
    if cnj:
        for net in (cnj.get("congestion_nets") or []):
            insts = [x for x in (net.get("instances") or []) if x]
            if net.get("bbox") and insts:
                crossing_nets.append(
                    {"bbox": tuple(int(v) for v in net["bbox"]), "net": net.get("net"),
                     "instances": insts, "instance_count": len(insts), "hpwl": net.get("hpwl")})

    # -- density (solver's own grid report, zero extra computation) --
    # Cross-check against the REAL cell density (peak_cell_density) from
    # gp_metrics_compare / gp_full_metrics. On small-die designs the solver
    # native density grid (e.g. 64x64) is proportionally wrong and can report
    # peak_bin_density 2-3 while the true cell density is ~0.15, which would
    # falsely accumulate density bad and block convergence. If the true cell
    # density is very low, clamp the grid peak to a small multiple of it and
    # flag the mismatch.
    grid = grid_report(workdir)
    true_cell_density = None
    for fname in ("gp_metrics_compare.json", "gp_full_metrics.json"):
        bd = load_json(Path(workdir) / fname)
        if not bd:
            continue
        dens_dat = ((bd.get("placements") or {}).get("candidate") or {}).get("density") or {}
        v = dens_dat.get("peak_cell_density")
        if isinstance(v, (int, float)) and v >= 0:
            true_cell_density = float(v)
            break
    density_scale_mismatch = true_cell_density is not None and true_cell_density < 0.30
    if grid:
        bins = grid.get("bins") or []
        total_bins = len(bins)
        for b in bins:
            target = b.get("density_target")
            if isinstance(target, (int, float)) and target <= 0:
                target = 1.0
            target = float(target or 1.0)
            peak = float(b.get("density") or 0.0)
            # If the grid is proportionally wrong (real cell density very low),
            # clamp the peak so a spurious 2-3 does not become a density bad.
            if density_scale_mismatch and true_cell_density is not None:
                peak = min(peak, max(target, true_cell_density * 2.0))
            delta = peak - target
            if delta <= 0:
                continue
            severity = "bad-2" if delta > 0.15 else "bad-1"
            bbox = f"{b.get('ll_x')} {b.get('ll_y')} {b.get('ur_x')} {b.get('ur_y')}"
            obj = {
                "id": f"density-bin({b.get('row')},{b.get('col')})",
                "domain": "density",
                "severity": severity,
                "peak_density": peak,
                "density_target": target,
                "violation_depth": round(delta, 4),
                "executable_action": {
                    "tool": "ieda_gp_run", "kind": "local_run", "scope": "region",
                    "scope_region": bbox,
                    "scope_density_target": round(min(1.0, max(0.6, target)), 2),
                    "checkpoint": cp_path,
                },
                "prediction_status": "unavailable",
            }
            violations["density"]["objects"].append(obj)
            problems.append(obj)

    # -- congestion (cached verify-RUDY map, same evaluator as verify metrics) --
    rows, congestion = _read_util_matrix(workdir)
    util_path = Path(workdir) / "rudy_util.csv"
    if util_path.exists() and rows:
        # FULL bin-level counts first (distribution facts; never truncated, and
        # independent of the region-level object view below).
        cong_bad_1 = 0
        cong_bad_2 = 0
        for row in rows:
            for util in row:
                if util >= HARD_RUDY_MAX:
                    cong_bad_2 += 1
                elif util > 1.0:
                    cong_bad_1 += 1
        # Region-level objects: connected violating bins merged into hot REGIONS.
        # One local_run evacuates a region, not thousands of individual bins, so
        # the per-bin list is exactly the context-window killer we removed. Each
        # region is the semantic object the agent acts on.
        for rg in merge_util_regions(rows, congestion, top_n=8):
            llx, lly, urx, ury = (int(v) for v in rg["bbox"].split())
            # Semantic summary, NOT the inlined instance list: a crossing net can
            # span thousands of cells (picorv32 region-22 had a 1615-instance net),
            # and inlining it is exactly the context-window dump we are removing.
            # Give net + count + hpwl as the direction; fetch the full executable
            # instance set on demand via propose kind=longnet_instances.
            net_cone_actions = [
                {
                    "tool": "ieda_gp_run", "kind": "local_run", "scope": "instances",
                    "net": nc["net"],
                    "instance_count": len(nc["instances"]),
                    "hpwl": nc["hpwl"],
                    "checkpoint": cp_path,
                    "note": "full scope_instances via observe/propose longnet_instances (not inlined to bound context)",
                }
                for nc in crossing_nets
                if nc["bbox"][2] >= llx and nc["bbox"][0] <= urx
                and nc["bbox"][3] >= lly and nc["bbox"][1] <= ury
            ][:3]
            obj = {
                "id": rg["id"],
                "domain": "congestion",
                "severity": rg["severity"],
                "peak_utilization": rg["peak_utilization"],
                "mean_utilization": rg["mean_utilization"],
                "bin_count": rg["bin_count"],
                "violation_depth": rg["violation_depth"],
                "executable_action": {
                    "tool": "ieda_gp_run", "kind": "local_run", "scope": "region",
                    "scope_region": rg["bbox"],
                    "scope_density_target": 0.8,
                    "checkpoint": cp_path,
                },
                "net_cone_actions": net_cone_actions,
                "prediction_status": "unavailable",
            }
            violations["congestion"]["objects"].append(obj)
            problems.append(obj)
        # Keep the FULL bin-level counts on the violation dict (drive the
        # distribution facts; objects are now the region-level semantic view).
        violations["congestion"]["bin_bad_1"] = cong_bad_1
        violations["congestion"]["bin_bad_2"] = cong_bad_2

    # -- timing (cached iSTA paths) --
    if check_timing:
        tp = load_json(Path(workdir) / "timing_paths.json")
        if tp:
            for p in tp.get("paths") or []:
                slack = p.get("slack")
                if slack is None or slack >= 0:
                    continue
                severity = "bad-2" if slack < 0 else "bad-1"
                instances = ",".join(p.get("instances") or [])
                obj = {
                    "id": f"path:{p.get('endpoint') or '?'}",
                    "domain": "timing",
                    "severity": severity,
                    "slack": slack,
                    "violation_depth": round(abs(slack), 4),
                    "instance_count": p.get("instance_count") or 0,
                    "executable_action": {
                        "tool": "ieda_gp_run", "kind": "local_run", "scope": "instances",
                        "scope_instances": instances,
                        "checkpoint": cp_path,
                    } if instances else None,
                    "prediction_status": "unavailable",
                }
                if obj["executable_action"] is None:
                    obj.pop("executable_action", None)
                violations["timing"]["objects"].append(obj)
                problems.append(obj)

    # ---- post-hoc timing budget: when timing_paths.json is empty (GP ran with
    # timing=0) but a real post-hoc STA exists (gp_metrics_compare/gp_full_metrics),
    # a negative setup/hold WNS or a large TNS is a genuine timing violation that
    # must count toward timing bad. Without this, a placement with setup_wns=-3.6
    # can be declared converged (the timing domain reads 0 because no per-path
    # timing objects exist when timing-driven GP was off). ----
    if check_timing:
        try:
            timing_vals = {"setup_wns_ns": None, "setup_tns_ns": None,
                           "hold_wns_ns": None, "hold_tns_ns": None}
            for fname in ("gp_metrics_compare.json", "gp_full_metrics.json"):
                bd = load_json(Path(workdir) / fname)
                if not bd:
                    continue
                cand = (bd.get("placements") or {}).get("candidate") or {}
                cm = cand.get("timing") or {}
                for k in timing_vals:
                    if timing_vals[k] is None and isinstance(cm.get(k), (int, float)):
                        timing_vals[k] = float(cm[k])
                if all(v is not None for v in timing_vals.values()):
                    break
            # Negative setup/hold WNS is a real violation (even a small one is a fail).
            wns = timing_vals.get("setup_wns_ns")
            tns = timing_vals.get("setup_tns_ns")
            hwn = timing_vals.get("hold_wns_ns")
            htn = timing_vals.get("hold_tns_ns")
            if any(v is not None and v < 0 for v in (wns, hwn)):
                worst = min([v for v in (wns, hwn) if v is not None and v < 0], default=None)
                obj = {
                    "id": "post-hoc-timing",
                    "domain": "timing",
                    "severity": "bad-1",
                    "slack": worst,
                    "violation_depth": round(abs(worst), 4) if worst is not None else 0.0,
                    "instance_count": 0,
                    "note": "post-hoc STA shows negative WNS (setup/hold) though timing-driven GP was off",
                    "executable_action": {"tool": "ieda_gp_run", "kind": "advance", "timing": 1,
                                          "checkpoint": cp_path},
                    "prediction_status": "unavailable",
                }
                violations["timing"]["objects"].append(obj)
                problems.append(obj)
        except Exception:
            pass

    # severity aggregation (FULL counts, computed before any listing cap - these
    # numbers drive converged/total_bad_objects and must never be truncated).
    # density/timing count their objects; congestion counts are bin-level facts
    # (objects are now the region-level semantic view, so summing them would
    # under-report the true violating-bin count).
    for dom in ("density", "timing"):
        objs = violations[dom]["objects"]
        violations[dom]["bad_1"] = sum(1 for o in objs if o["severity"] == "bad-1")
        violations[dom]["bad_2"] = sum(1 for o in objs if o["severity"] == "bad-2")
    violations["congestion"]["bad_1"] = violations["congestion"].get("bin_bad_1", 0)
    violations["congestion"]["bad_2"] = violations["congestion"].get("bin_bad_2", 0)

    # Cap the per-domain object LISTS for the wire (density/timing can still
    # overflow; congestion is already region-top-k). The full counts live in
    # bad_1/bad_2 plus the distribution field.
    MAX_LISTED_OBJECTS = 20
    for dom in ("density", "timing"):
        objs = violations[dom]["objects"]
        total = len(objs)
        if total > MAX_LISTED_OBJECTS:
            objs.sort(key=lambda o: (o.get("severity") != "bad-2",
                                     -o.get("violation_depth", 0.0)))
            violations[dom]["objects"] = objs[:MAX_LISTED_OBJECTS]
            violations[dom]["objects_truncated"] = True
            violations[dom]["objects_listed"] = MAX_LISTED_OBJECTS
            violations[dom]["objects_total"] = total

    # ---- hard constraint: congestion gates the whole state ----
    # Peak RUDY utilization above HARD_RUDY_MAX means wiring demand exceeds
    # 2x routing capacity in at least one bin: physically unroutable, so the
    # state is rejected regardless of how clean density/timing are. HPWL
    # optimization must happen BELOW this ceiling, never by crossing it.
    #
    # The candidate peak must reflect the CURRENT placement.def. Reading only
    # the session rudy_util.csv / congestion_result.json cache is unsafe: it is
    # refreshed solely by congestion_hotspots and goes stale the moment a later
    # accept rewrites placement.def (wave4 picorv32: cache said 1.82, final DEF
    # measured 2.09). Prefer the fresh same-evaluator number in
    # gp_metrics_compare.json / gp_full_metrics.json (written by verify/full on
    # the candidate DEF); otherwise use the cache with mtime staleness detection
    # so a stale peak can never certify convergence.
    def _file_mtime(path):
        try:
            return path.stat().st_mtime
        except Exception:
            return 0.0

    placed_path = Path(workdir) / "placement.def"
    placed_mtime = _file_mtime(placed_path) if placed_path.exists() else 0.0

    # Gather candidate-peak candidates from every available same-evaluator source
    # and take the FRESHEST one (max mtime). A source is stale only when it
    # predates placement.def; if any source is newer than the placement it wins,
    # so a fresh congestion_hotspots cache beats a stale verify JSON and vice
    # versa. This avoids both the false-"ok" (stale cache) and the false-"stale"
    # (fresh cache ignored because a stale verify JSON exists) failure modes.
    cand_sources: list[tuple[float, float, str]] = []  # (mtime, peak, source)
    for fname in ("gp_metrics_compare.json", "gp_full_metrics.json"):
        fpath = Path(workdir) / fname
        bdata = load_json(fpath)
        if not bdata:
            continue
        cand = (bdata.get("placements") or {}).get("candidate") or {}
        candd = cand.get("density") or {}
        val = candd.get("rudy_utilization_max")
        if isinstance(val, (int, float)) and val >= 0:
            cand_sources.append((_file_mtime(fpath), float(val), fname))
    cj_path = Path(workdir) / "congestion_result.json"
    cj = load_json(cj_path) or {}
    val = cj.get("rudy_utilization_max")
    if isinstance(val, (int, float)) and val >= 0:
        cand_sources.append((_file_mtime(cj_path), float(val), "congestion_result.json"))
    if util_path.exists():
        # Exclude the 1-bin border: a single border bin can hold all IO pins
        # and inflate rudy_utilization_max (e.g. ~50 on gcd) while interior
        # congestion stays well below 1.0. Use the interior peak so a border
        # I/O bin never trips the 2.0 hard ceiling as a false congestion.
        util_grid = []
        for line in util_path.read_text().splitlines():
            vals = [float(t) for t in line.split(",") if t.strip() != ""]
            if vals:
                util_grid.append(vals)
        if len(util_grid) >= 3 and len(util_grid[0]) >= 3:
            interior_peak = max(util_grid[i][j] for i in range(1, len(util_grid) - 1)
                                for j in range(1, len(util_grid[0]) - 1))
            border_peak = max(max(row) for row in util_grid)
            if border_peak > 2.0 and border_peak > interior_peak * 3:
                cand_sources.append((_file_mtime(util_path), float(interior_peak), "rudy_util.csv(interior, border-IO excluded)"))
            else:
                cand_sources.append((_file_mtime(util_path), float(border_peak), "rudy_util.csv"))
        elif util_grid:
            cand_sources.append((_file_mtime(util_path), max(max(r) for r in util_grid), "rudy_util.csv"))

    congestion_peak = None
    congestion_source = None
    congestion_stale = False
    if cand_sources:
        best_mtime, congestion_peak, congestion_source = max(cand_sources, key=lambda x: x[0])
        congestion_stale = placed_mtime > 0 and best_mtime < placed_mtime

    congestion_hard_violation = None
    if congestion_peak is None:
        congestion_hard_violation = {
            "status": "unknown",
            "peak_rudy_utilization": None,
            "hard_ceiling": HARD_RUDY_MAX,
            "note": "no congestion data for the current placement; run observe kind=congestion_hotspots or verify metrics first",
        }
    elif congestion_stale:
        congestion_hard_violation = {
            "status": "stale",
            "peak_rudy_utilization": None,
            "stale_peak_rudy_utilization": round(congestion_peak, 4),
            "hard_ceiling": HARD_RUDY_MAX,
            "source": congestion_source,
            "note": "congestion cache predates placement.def (the placement changed since the last congestion observation); peak_rudy_utilization is nulled because a stale number must never certify convergence - re-run congestion_hotspots/verify first",
        }
    elif congestion_peak > HARD_RUDY_MAX:
        congestion_hard_violation = {
            "status": "rejected",
            "peak_rudy_utilization": congestion_peak,
            "hard_ceiling": HARD_RUDY_MAX,
            "source": congestion_source,
            "note": "peak RUDY exceeds the physical routing-capacity ceiling; this state is unacceptable - reduce congestion first, only then optimize HPWL/density/timing below the cap",
        }
    else:
        congestion_hard_violation = {
            "status": "ok",
            "peak_rudy_utilization": congestion_peak,
            "hard_ceiling": HARD_RUDY_MAX,
            "source": congestion_source,
        }

    # ---- soft congestion pull: no regression vs iEDA raw-GP baseline ----
    # The raw baseline peak RUDY (iEDA's own gp_baseline_def, NOT Innovus) is
    # already computed by the full/verify actions into gp_metrics_compare.json
    # / gp_full_metrics.json (placements.raw.density.rudy_utilization_max).
    # Reading it costs nothing: it is the same 64x64 RUDY evaluator.
    baseline_peak = None
    for fname in ("gp_metrics_compare.json", "gp_full_metrics.json"):
        bdata = load_json(Path(workdir) / fname)
        if not bdata:
            continue
        rawp = (bdata.get("placements") or {}).get("raw") or {}
        rawd = rawp.get("density") or {}
        val = rawd.get("rudy_utilization_max")
        if isinstance(val, (int, float)) and val >= 0:
            baseline_peak = float(val)
            break
    # Congestion clear target (internal, never Innovus): the agent must land peak RUDY
    # at or below min(hard_ceiling, baseline*factor) to count as a real congestion WIN.
    # This is what makes the multi-objective pull concrete: 'below baseline' is not enough;
    # the candidate must clear the baseline floor by the factor (or meet the hard ceiling
    # if the design's own baseline already exceeds it).
    target_rudy_max = None
    if baseline_peak is not None:
        target_rudy_max = round(min(HARD_RUDY_MAX, baseline_peak * CONGESTION_CLEAR_TARGET_FACTOR), 4)
    congestion_regression = None
    if baseline_peak is not None and congestion_peak is not None and not congestion_stale:
        regressed = congestion_peak > baseline_peak * RUDY_REGRESSION_TOLERANCE
        # Congestion-margin fact: how far below the design's own raw-GP baseline the
        # candidate sits. A small margin (candidate close to baseline) means there may
        # be more congestion headroom to extract before declaring done; a large margin
        # means the candidate already pushed congestion well below the baseline. This is
        # a FACT (no verdict), so the agent can decide whether pushing congestion lower
        # is worth an HPWL/iteration trade. It is computed against the iEDA raw-GP baseline
        # only (never Innovus), keeping the no-GT rule.
        margin_pct = round((baseline_peak - congestion_peak) / baseline_peak, 4) if baseline_peak > 0 else None
        congestion_regression = {
            "status": "regressed" if regressed else "ok",
            "peak_rudy_utilization": round(congestion_peak, 4),
            "baseline_peak_rudy": round(baseline_peak, 4),
            "target_rudy_max": target_rudy_max,
            "below_target": (congestion_peak <= target_rudy_max) if target_rudy_max is not None else None,
            "tolerance": RUDY_REGRESSION_TOLERANCE,
            "congestion_margin_pct": margin_pct,
        }
        if regressed:
            congestion_regression["note"] = (
                "peak RUDY exceeds the iEDA raw-GP baseline peak (congestion regressed "
                "while staying under the 2.0 hard ceiling); reduce congestion before "
                "declaring convergence - HPWL gains must not come from growing wiring demand")
        elif congestion_peak > target_rudy_max:
            congestion_regression["note"] = (
                f"candidate peak {round(congestion_peak,4)} is above the congestion clear "
                f"target {target_rudy_max} (= min(hard ceiling, iEDA baseline * 0.95)); "
                "congestion is not yet a WIN - push peak RUDY at or below the target with a "
                "congestion-focused pass (local_congestion / apply_region_density / ce3 full) "
                "before declaring convergence")
        elif margin_pct is not None and margin_pct < 0.05:
            congestion_regression["note"] = (
                f"candidate peak is {round(margin_pct*100,1)}% below the iEDA raw-GP "
                f"baseline (target {target_rudy_max}); congestion is close to the floor, "
                "so a congestion-focused pass may still extract headroom (a fact)")
        else:
            congestion_regression["note"] = (
                f"candidate peak {round(congestion_peak,4)} <= clear target {target_rudy_max}; "
                "congestion is a genuine WIN below the design's own floor")
    else:
        congestion_regression = {
            "status": "unknown",
            "peak_rudy_utilization": round(congestion_peak, 4) if congestion_peak is not None else None,
            "note": "baseline peak RUDY unavailable, or the candidate peak is stale; run full or verify first to establish the iEDA raw baseline and a fresh candidate peak",
        }

    # ---- distribution view ----
    # Text-LLM decision surface, not a histogram. Quantiles read the shape
    # directly (body + tail steepness); histograms force the agent to mentally
    # reconstruct a shape and are blind to the tail. Threshold counts + hot
    # regions round out the actionable view. Raw grid never leaves the tool.
    congestion_dist = None
    if util_path.exists() and rows:
        all_util: list[float] = []
        for row in rows:
            all_util.extend(row)
        if all_util:
            q = quantile_summary(all_util)
            util_stale = placed_mtime > 0 and _file_mtime(util_path) < placed_mtime
            congestion_dist = {
                "quantiles": q,
                "spare_bin_count": sum(1 for v in all_util if v < 1.0),
                "violating_bin_count": sum(1 for v in all_util if v >= 1.0),
                "hard_violating_bin_count": sum(1 for v in all_util if v >= HARD_RUDY_MAX),
                "hot_regions": merge_util_regions(rows, congestion, top_n=8),
                "stale": util_stale,
                "source": "rudy_util.csv",
                "note": ("cached RUDY map predates placement.def; its shape/regions are stale - re-run congestion_hotspots/verify for the current map" if util_stale else "same-evaluator RUDY map (quantiles + threshold counts + top hot regions)"),
            }

    # density (solver-native grid): violating bins = density above their
    # target; spare bins = density well below target (real capacity to
    # receive relocated cells). Both are spatial, so mapping a violating bin
    # to its nearest spare bin is an actionable evacuation direction.
    density_dist = None
    if grid and total_bins:
        gbins = grid.get("bins") or []
        dens = [float(b.get("density") or 0.0) for b in gbins]
        tgt = [float(b.get("density_target") or 1.0) for b in gbins]
        if dens:
            violating = []
            spare = []
            for i, b in enumerate(gbins):
                d, t = dens[i], tgt[i]
                bbox = f"{b.get('ll_x')} {b.get('ll_y')} {b.get('ur_x')} {b.get('ur_y')}"
                if d > t:
                    violating.append({"bbox": bbox, "density": d, "target": t, "depth": round(d - t, 4)})
                elif d < 0.8 * t:
                    spare.append({"bbox": bbox, "density": d, "target": t, "spare": round(t - d, 4)})
            # 对每个最深的违规 bin，找空间上最近的 spare bin 作为疏散方向
            def nearest_spare(pbbox):
                plx, ply = [int(x) for x in pbbox.split()[:2]]
                best, bestd = None, float("inf")
                for r in spare:
                    rlx, rly = [int(x) for x in r["bbox"].split()[:2]]
                    d = abs(plx - rlx) + abs(ply - rly)
                    if d < bestd:
                        bestd, best = d, r
                return best
            violating_sorted = sorted(violating, key=lambda x: -x["depth"])[:8]
            evacuation_directions = []
            for p in violating_sorted:
                nr = nearest_spare(p["bbox"])
                if nr:
                    evacuation_directions.append({"violating_bin": p["bbox"], "depth": p["depth"],
                                                 "nearest_spare_bin": nr["bbox"], "spare": nr["spare"]})
            density_dist = {
                "bin_count": len(dens),
                "quantiles": quantile_summary(dens),
                "violating_bin_count": len(violating),
                "spare_bin_count": len(spare),
                "violating_regions": violating_sorted,
                "spare_bins": spare[:8],
                "evacuation_directions": evacuation_directions,
                "note": "spare_bins are the relocation destinations; evacuation_directions map each deep violation to its nearest spare bin. spare_bin_count==0 means there is no spare capacity to relocate into.",
            }

    # timing: slack is NOT transferable between paths, so there is no
    # "spare" to relocate - only the violating paths matter, each with the
    # instance set that can be shortened (scope=instances).
    timing_dist = None
    tp_all = load_json(Path(workdir) / "timing_paths.json")
    if tp_all:
        paths_all = tp_all.get("paths") or []
        violating = []
        for p in paths_all:
            s = float(p.get("slack") or 0.0)
            if s < 0:
                violating.append({
                    "endpoint": p.get("endpoint"),
                    "slack": round(s, 4),
                    "instances": p.get("instances") or [],
                    "instance_count": p.get("instance_count") or 0,
                })
        if violating:
            slacks = [v["slack"] for v in violating]
            timing_dist = {
                "violating_path_count": len(violating),
                "slack_quantiles": quantile_summary(slacks),
                "worst_paths": sorted(violating, key=lambda x: x["slack"])[:8],
                "summary": tp_all.get("timing_summary") or {},
                "note": "each worst_path carries the instances on it; shorten them with scope=instances to lift the slack. Only violating (negative-slack) paths are actionable. slack_quantiles read the multi-path shape (TNS needs more than the single worst WNS).",
            }

    # HPWL: only the longest nets matter for the agent's decision - they
    # drive congestion and are the cheapest wins (shorten their instance cone).
    # Net-length histograms/medians are decorative and are deliberately omitted.
    hpwl_dist = None
    try:
        ln = diagnose_longnets(workdir, checkpoint, top_n=20)
        if ln.get("ok") and ln.get("longnets"):
            nets = ln["longnets"]  # already sorted desc by hpwl
            if nets:
                hpwl_dist = {
                    "net_count": len(nets),
                    "max_net_hpwl": max(n["hpwl"] for n in nets),
                    "top_longest_nets": [
                        {"net": n["net"], "hpwl": n["hpwl"], "pin_count": n.get("pin_count")}
                        for n in nets[:8]
                    ],
                    "note": "top_longest_nets drive congestion; shorten their instance cone (propose_longnet_instances) to cut HPWL and congestion together. No histogram/median - those do not change any decision.",
                }
    except Exception:
        hpwl_dist = None

    # -- congestion clear-target problem (soft multi-objective) --
    # Even when peak RUDY is < 2.0 and <= the iEDA baseline (hard-ok, not regressed), if it
    # is still ABOVE the congestion clear target (= min(hard ceiling, baseline*0.95)), emit a
    # single top-level "congestion not yet a WIN" problem so the agent is told to push peak RUDY
    # to the target with a congestion-focused pass (local_congestion / apply_region_density /
    # ce3 full) - not trade it for HPWL. NEVER references Innovus (no-GT rule); the target is
    # derived only from the iEDA raw-GP baseline. For designs whose baseline already exceeds the
    # hard ceiling (ihp130: baseline 2.637), target collapses to 2.0 -> the object fires and the
    # design honestly stays not-converged (feasibility explains why).
    if (target_rudy_max is not None and congestion_peak is not None
            and not congestion_stale and congestion_peak <= HARD_RUDY_MAX
            and congestion_peak > target_rudy_max):
        problems.append({
            "id": "congestion-clear-target",
            "domain": "congestion",
            "severity": "bad-1",
            "peak_utilization": round(congestion_peak, 4),
            "target_rudy_max": target_rudy_max,
            "violation_depth": round(max(0.0, congestion_peak - target_rudy_max), 4),
            "executable_action": {
                "tool": "ieda_gp_run", "kind": "local_congestion",
                "top_bins": 4, "checkpoint": cp_path,
            },
            "prediction_status": "unavailable",
        })

    # cross-domain normalization for the unified problem ranking
    max_depth = 1.0
    if problems:
        max_depth = max(float(o["violation_depth"]) for o in problems) or 1.0
    for o in problems:
        o["score"] = round(0.5 * float(o["violation_depth"]) / max_depth
                           + (0.5 if o["severity"] == "bad-2" else 0.0), 4)

    problems.sort(key=lambda o: -o["score"])
    total_problems = len(problems)
    listed = problems[: max(3, min(12, len(problems)))]
    # total_bad counts ONLY the soft clearing targets (density + timing).
    # Congestion is NOT summed here: it gates the state via congestion_hard_violation.
    total_bad = (violations["density"]["bad_1"] + violations["density"]["bad_2"]
                 + violations["timing"]["bad_1"] + violations["timing"]["bad_2"])
    grid_meta = {}
    if total_bins and grid:
        grid_meta = {"bin_cnt": (grid.get("bin_cnt_x"), grid.get("bin_cnt_y")),
                     "note": "density bad counts come from the solver-native grid; very fine grids (e.g. 256x256) inflate bad-bin counts vs the 64x64 RUDY evaluator - prefer bin_cnt=64 runs for cross-domain comparability"}
    # Convergence is (total_bad == 0) AND (congestion_hard_violation.status == ok)
    # AND (no congestion regression vs the iEDA raw-GP baseline) AND (peak <= target_rudy_max).
    # The clear-target gate makes the multi-objective pull CONCRETE: the agent does not
    # converge by merely sitting under its own baseline or under the 2.0 hard ceiling - it
    # must land peak RUDY at or below min(hard ceiling, baseline*0.95). This stops it from
    # trading a congestion win (e.g. rudy 1.392) for a worse one (1.451) to shave HPWL.
    # For designs whose OWN baseline already exceeds the hard ceiling (ihp130 baseline 2.637),
    # target collapses to 2.0 so they honestly stay not-converged (feasibility explains why).
    # The target NEVER uses Innovus (no-GT rule); it is derived only from the iEDA baseline.
    regr_ok = congestion_regression["status"] in ("ok", "unknown")
    clear_ok = (target_rudy_max is None) or (congestion_peak is not None and congestion_peak <= target_rudy_max)
    converged = (total_bad == 0 and congestion_hard_violation["status"] == "ok" and regr_ok and clear_ok)
    # Multi-objective quality fact (no verdict, no Innovus): after the convergence
    # predicate is satisfied, report how much congestion headroom the candidate holds
    # below the design's own baseline floor. A small margin (e.g. <8%) means the
    # candidate is only marginally under the baseline and there is likely room to push
    # peak RUDY lower; a larger margin means congestion is comfortably below the floor.
    # This is what stops the agent from trading a congestion win (e.g. rudy 1.392) for
    # a worse one (e.g. 1.451) just to shave HPWL after convergence.
    _margin = (baseline_peak - congestion_peak) / baseline_peak if (baseline_peak is not None and congestion_peak is not None and baseline_peak > 0) else None
    converged_quality = {
        "congestion_margin_pct": round(_margin, 4) if _margin is not None else None,
        "candidate_peak": round(congestion_peak, 4) if congestion_peak is not None else None,
        "baseline_peak": round(baseline_peak, 4) if baseline_peak is not None else None,
        "quality_hint": ("candidate is close to the baseline congestion floor (small margin); "
                         "consider a congestion-focused pass before finalizing, or keep minimizing "
                         "peak RUDY alongside HPWL (multi-objective) rather than trading one for the other")
                         if (_margin is not None and _margin < 0.08) else None,
    }
    distribution = {
        "congestion": congestion_dist,
        "density": density_dist,
        "timing": timing_dist,
        "hpwl": hpwl_dist,
    }
    # Feasibility facts (no verdict): how the design's OWN raw-GP baseline sits
    # against the hard ceiling, and where the current candidate is relative to
    # both. This is the piece that tells the agent whether a gap is "narrow"
    # (baseline already under the ceiling, candidate near it) or "wide" (the
    # design's own baseline already exceeds the ceiling, so the 2.0 target is
    # especially demanding here). The agent still decides whether to keep
    # trying or stop; these are only numbers.
    feasibility = {
        "raw_baseline_peak": round(baseline_peak, 4) if baseline_peak is not None else None,
        "hard_ceiling": HARD_RUDY_MAX,
        "target_rudy_max": target_rudy_max,
        "candidate_at_or_below_target": (congestion_peak <= target_rudy_max)
            if (congestion_peak is not None and target_rudy_max is not None) else None,
        "baseline_exceeds_hard_ceiling": baseline_peak is not None and baseline_peak > HARD_RUDY_MAX,
        "candidate_peak": round(congestion_peak, 4) if congestion_peak is not None else None,
        "candidate_below_baseline": (congestion_peak < baseline_peak)
            if (congestion_peak is not None and baseline_peak is not None) else None,
        "congestion_margin_pct": (round((baseline_peak - congestion_peak) / baseline_peak, 4)
            if (baseline_peak is not None and congestion_peak is not None and baseline_peak > 0) else None),
    }
    return {"ok": True, "workdir": str(workdir), "checkpoint_path": cp_path,
            "converged_quality": converged_quality,
            "density_grid": grid_meta,
            "congestion_hard_violation": congestion_hard_violation,
            "congestion_regression": congestion_regression,
            "congestion_source": congestion_source,
            "congestion_stale": congestion_stale,
            "feasibility": feasibility,
            "converged": converged,
            "total_bad_objects": total_bad, "problem_count_total": total_problems,
            "listed": len(listed), "truncated": total_problems > len(listed),
            "distribution": distribution,
            "trend": trend_summary(workdir),
            "problem_list": listed, "violations": violations}


def propose_timing(workdir: str | Path, checkpoint: str | None = None, top_n: int = 3) -> dict:
    """Timing-path instance proposals from the cached iSTA report (observe timing_paths)."""
    tp = load_json(Path(workdir) / "timing_paths.json")
    if not tp:
        return {"ok": False, "reason": "timing_paths.json missing; run observe kind=timing_paths first (cached per DEF)"}
    paths = tp.get("paths") or []
    try:
        cp_path = checkpoint_path(workdir, checkpoint)
    except Exception:
        cp_path = None
    def instance_of(node_name: str) -> str | None:
        name = str(node_name).split("(")[0].strip()
        if ":" not in name:
            return None
        inst = name.split(":", 1)[0].strip()
        if not inst or inst.upper() == "PIN":
            return None
        return inst

    proposals = []
    selected_instances: list[str] = []
    seen: set[str] = set()
    for i, p in enumerate(paths[: max(1, top_n)]):
        insts: list[str] = []
        for node in p.get("nodes") or []:
            inst = instance_of((node or {}).get("name", ""))
            if inst and inst not in insts:
                insts.append(inst)
        for inst in p.get("instances") or []:
            if inst and inst not in insts:
                insts.append(inst)
        for inst in insts:
            if inst not in seen:
                seen.add(inst)
                selected_instances.append(inst)
        action: dict = {
            "tool": "ieda_gp_run", "kind": "local_run", "scope": "instances",
            "scope_instances": ",".join(selected_instances),
        }
        if cp_path:
            action["checkpoint"] = cp_path
        proposals.append({
            "id": f"timing-path-top-{i + 1}",
            "endpoint": p.get("endpoint"),
            "slack_ns": p.get("slack"),
            "instance_count": len(selected_instances),
            "instances": list(selected_instances),
            "executable_action": action,
            "prediction_status": "unavailable",
        })
    return {"ok": True, "timing_summary": tp.get("timing_summary"),
            "path_count": len(paths), "checkpoint_path": cp_path,
            "proposals": proposals}


def experiments(workdir: str | Path, top_n: int = 40, extra_workdirs: str | None = None) -> dict:
    """Aggregate already-computed results into an action→metric table + Pareto view.

    extra_workdirs (comma-separated) merges other sessions' traces for
    cross-session Pareto memory; every row carries its origin workdir."""
    root = Path(workdir)
    rows: list[dict] = []
    trace_path = root / "gp_agent_trace.jsonl"
    if trace_path.exists():
        for raw in trace_path.read_text(errors="ignore").splitlines():
            if not raw.strip():
                continue
            try:
                entry = json.loads(raw)
            except Exception:
                continue
            if entry.get("source") != "ieda_gp_run":
                continue
            res = entry.get("result") or {}
            if not res.get("ok"):
                continue
            rec = res.get("record") or {}
            args = entry.get("args") or []
            rows.append({
                "ts": entry.get("ts"),
                "kind": args[0] if args else None,
                "args": args,
                "mode": rec.get("mode"),
                "iterations": (rec.get("start_iteration"), rec.get("end_iteration")),
                "stop_reason": rec.get("stop_reason"),
                "hpwl_solver": rec.get("hpwl"),
                "def_hpwl": rec.get("def_hpwl"),
                "overflow": rec.get("overflow"),
                "route_util": rec.get("route_util"),
                "scope_effect": rec.get("scope_effect"),
                "checkpoint": rec.get("checkpoint_path"),
            })
    archived = []
    for mfile in sorted(root.glob("archive/*/gp_metrics_compare.json")):
        data = load_json(mfile)
        if not data:
            continue
        stamp = mfile.parent.name
        for label, p in (data.get("placements") or {}).items():
            dens = p.get("density") or {}
            tim = p.get("timing") or {}
            archived.append({
                "archive": stamp, "label": label, "def": p.get("def"),
                "hpwl": p.get("hpwl"),
                "rudy_max": dens.get("rudy_utilization_max"),
                "bins": dens.get("rudy_overflow_bin_count"),
                "rsum": dens.get("rudy_overflow_util_sum"),
                "wns": tim.get("setup_wns_ns"), "freq": tim.get("suggest_freq_mhz"),
            })
    if extra_workdirs:
        for extra in [Path(p) for p in str(extra_workdirs).split(",") if p.strip()]:
            if extra == root or not extra.exists():
                continue
            et = extra / "gp_agent_trace.jsonl"
            if et.exists():
                for raw in et.read_text(errors="ignore").splitlines():
                    if not raw.strip():
                        continue
                    try:
                        entry = json.loads(raw)
                    except Exception:
                        continue
                    if entry.get("source") != "ieda_gp_run":
                        continue
                    res = entry.get("result") or {}
                    if not res.get("ok"):
                        continue
                    rec = res.get("record") or {}
                    args = entry.get("args") or []
                    rows.append({
                        "workdir": str(extra),
                        "ts": entry.get("ts"),
                        "kind": args[0] if args else None,
                        "mode": rec.get("mode"),
                        "stop_reason": rec.get("stop_reason"),
                        "hpwl_solver": rec.get("hpwl"),
                        "def_hpwl": rec.get("def_hpwl"),
                        "overflow": rec.get("overflow"),
                        "route_util": rec.get("route_util"),
                        "checkpoint": rec.get("checkpoint_path"),
                    })
            for mfile in sorted(extra.glob("archive/*/gp_metrics_compare.json")):
                data = load_json(mfile)
                if not data:
                    continue
                for label, p in (data.get("placements") or {}).items():
                    dens = p.get("density") or {}
                    tim = p.get("timing") or {}
                    archived.append({"workdir": str(extra), "archive": mfile.parent.name, "label": label,
                                     "hpwl": p.get("hpwl"),
                                     "rudy_max": dens.get("rudy_utilization_max"),
                                     "bins": dens.get("rudy_overflow_bin_count"),
                                     "rsum": dens.get("rudy_overflow_util_sum"),
                                     "wns": tim.get("setup_wns_ns"), "freq": tim.get("suggest_freq_mhz")})
    rows.sort(key=lambda x: x.get("ts") or 0)
    total_actions = len(rows)
    pareto = []
    for r in rows:
        if r.get("def_hpwl") is None or r.get("route_util") is None:
            continue
        dominated = False
        for q in rows:
            if q is r or q.get("def_hpwl") is None or q.get("route_util") is None:
                continue
            if q["def_hpwl"] <= r["def_hpwl"] and q["route_util"] <= r["route_util"]                     and (q["def_hpwl"] < r["def_hpwl"] or q["route_util"] < r["route_util"]):
                dominated = True
                break
        if not dominated:
            pareto.append(r)
    if top_n and top_n > 0:
        rows = rows[-top_n:]
    return {"ok": True, "workdir": str(workdir), "action_count": total_actions,
            "workdirs_scanned": [str(Path(workdir))] + [str(Path(p)) for p in str(extra_workdirs or "").split(",") if p.strip()],
            "recent_actions": rows, "pareto_actions": pareto, "archive_metrics": archived}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("command", choices=["status", "checkpoints", "grid", "hotspots", "longnets", "trajectory", "violations", "propose_regions",
                                        "freeze_instances", "propose_longnet_instances", "propose_config",
                                        "propose_region_density", "propose_freeze", "unstable", "verify_delta",
                                        "propose_timing", "experiments"])
    ap.add_argument("--workdir", required=True)
    ap.add_argument("--workdirs")
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
    elif args.command == "propose_timing":
        print(json.dumps(propose_timing(args.workdir, args.checkpoint, args.top_n), indent=2))
    elif args.command == "experiments":
        print(json.dumps(experiments(args.workdir, args.top_n, args.workdirs), indent=2))
    elif args.command == "propose_longnet_instances":
        print(json.dumps(propose_longnet_instances(args.workdir, args.checkpoint, args.top_n, args.def_path), indent=2))
    elif args.command == "freeze_instances":
        print(json.dumps(freeze_instances(args.workdir, args.region, args.checkpoint), indent=2))
    elif args.command == "propose_regions":
        print(json.dumps(propose_regions(args.workdir, args.checkpoint, args.priority, args.top_n,
                                         args.min_cell_count, args.max_cell_count, args.def_path), indent=2))
    elif args.command == "violations":
        print(json.dumps(violations_report(args.workdir, args.checkpoint), indent=2))
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
