#!/usr/bin/env python3
"""Map EGR overflow hotspots back to the NETS (and their movable drivers).

Reads iRT early_router route_planar.guide (per-net pin/wire grid coords) plus the
overflow_map_planar.csv, then for the top-N overflow bins reports:
  - which nets route through each hot bin;
  - which movable instance names drive those nets (pin name before ':').

This is the 'scope=instances' seed set for evacuating the CELLS THAT DRIVE the
wiring hotspot (not just the cells physically inside the bin).
"""
from __future__ import annotations
import argparse, json, re, sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / "benchmarks/flows"))
from gp_egr_hotspots import parse_gcell, parse_overflow_map, run_egr  # noqa: E402


def movable_instances(def_path: Path) -> set[str]:
    text = def_path.read_text(errors="ignore")
    comp = text[text.find("\nCOMPONENTS"):text.find("\nEND COMPONENTS")]
    names = set()
    # component lines: - name master + PLACED ( x y ) orient ;
    for m in re.finditer(r"^\s*-\s+(\S+)\s+\S+.*?\+\s+PLACED\s*\(", comp, re.M):
        names.add(m.group(1))
    return names


def parse_guide(guide_path: Path) -> list[dict]:
    """Return [{net, gcells:set, drivers:[inst], pins:[inst]}] per net."""
    nets = {}
    cur = None
    for line in guide_path.read_text().splitlines():
        parts = line.split()
        if not parts:
            continue
        if parts[0] == "guide":
            cur = parts[1]
            nets[cur] = {"net": cur, "gcells": set(), "drivers": set(), "pins": set()}
        elif cur is None:
            continue
        elif parts[0] == "pin":
            # pin grid_x grid_y real_x real_y layer energy name
            if not parts[1].lstrip("-").isdigit() or not parts[2].lstrip("-").isdigit():
                continue
            gx, gy = int(parts[1]), int(parts[2])
            name = parts[7] if len(parts) > 7 else ""
            inst = name.split(":")[0] if name else ""
            nets[cur]["gcells"].add((gx, gy))
            if inst:
                nets[cur]["pins"].add(inst)
                if len(parts) > 6 and parts[6] == "driven":
                    nets[cur]["drivers"].add(inst)
        elif parts[0] == "wire":
            # wire g1x g1y g2x g2y real... layer
            if not parts[1].lstrip("-").isdigit() or not parts[3].lstrip("-").isdigit():
                continue
            g1x, g1y, g2x, g2y = int(parts[1]), int(parts[2]), int(parts[3]), int(parts[4])
            for x in range(min(g1x, g2x), max(g1x, g2x) + 1):
                for y in range(min(g1y, g2y), max(g1y, g2y) + 1):
                    nets[cur]["gcells"].add((x, y))
    return list(nets.values())


def hotnets(case_root: Path, foundry: Path, def_path: Path, out_dir: Path, top_n: int) -> dict:
    rc = run_egr(case_root, foundry, def_path, out_dir)
    early = out_dir / "rt/rt_temp_directory/early_router"
    # authoritative UNION overflow map + the 3D route.guide (per-layer nets).
    ovf = out_dir / "egr_congestion_map/place_egr_union_overflow.csv"
    if not ovf.exists():
        ovf = early / "overflow_map_planar.csv"
    guide = early / "route.guide"
    if not guide.exists():
        guide = early / "route_planar.guide"
    if rc != 0 or not ovf.exists() or not guide.exists():
        return {"ok": False, "rc": rc}
    grid = parse_overflow_map(ovf)
    # top-N hot bins as (col,row) -> overflow
    hot = []
    for row, vals in enumerate(grid):
        for col, v in enumerate(vals):
            if v > 0:
                hot.append(((col, row), v))
    hot.sort(key=lambda kv: kv[1], reverse=True)
    hot_bins = {bc for bc, v in hot[:top_n]}

    nets = parse_guide(guide)
    movable = movable_instances(def_path)
    result = {"ok": True, "def": str(def_path), "top_bins": [], "instances": []}
    seen_inst = set()
    for bc, v in hot[:top_n]:
        crossing = [n for n in nets if bc in n["gcells"]]
        drivers = set()
        for n in crossing:
            drivers |= (n["drivers"] | n["pins"])
        movable_drivers = sorted(drivers & movable)
        result["top_bins"].append({"col": bc[0], "row": bc[1], "overflow": v,
                                   "net_count": len(crossing),
                                   "nets": [n["net"] for n in crossing[:10]],
                                   "instances": movable_drivers[:40]})
        for i in movable_drivers:
            if i not in seen_inst:
                seen_inst.add(i)
                result["instances"].append(i)
    return result


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--case-root", required=True)
    ap.add_argument("--foundry-dir", required=True)
    ap.add_argument("--def", required=True, dest="def_path")
    ap.add_argument("--out-dir", required=True)
    ap.add_argument("--top-n", type=int, default=6)
    args = ap.parse_args()
    result = hotnets(Path(args.case_root), Path(args.foundry_dir), Path(args.def_path), Path(args.out_dir), args.top_n)
    print(json.dumps(result, indent=2))
    return 0 if result.get("ok") else 1


if __name__ == "__main__":
    raise SystemExit(main())
