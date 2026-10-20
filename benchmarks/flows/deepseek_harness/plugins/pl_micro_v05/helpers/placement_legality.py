"""Independent DEF placement checks: all cells, row bounds and overlaps.

This is a placement gate, not a power-connectivity or routing signoff check.
Unlike the old sampled alignment heuristic, site-aligned overlapping cells fail.
"""
from __future__ import annotations

import hashlib
import math
import re
from pathlib import Path

from def_hpwl_eval import parse_lef


def check_legalized(def_path: Path, macro_lef: Path | None = None) -> dict:
    path = Path(def_path)
    result = {"legalized": False, "checks": ["placed", "row_site", "row_bounds", "overlap"],
              "power_connectivity_checked": False, "sample": []}
    if not path.is_file():
        return {**result, "reason": "DEF missing"}
    text = path.read_text(errors="ignore")
    result["def_sha256"] = hashlib.sha256(path.read_bytes()).hexdigest()
    if macro_lef is None or not Path(macro_lef).is_file():
        return {**result, "reason": "cell LEF required to check all cell bounds and overlaps"}
    macros, _ = parse_lef(macro_lef)
    lef_text = Path(macro_lef).read_text(errors="ignore")
    block_macros = set(re.findall(r"MACRO\s+(\S+)\s+CLASS\s+BLOCK\b", lef_text))
    units_match = re.search(r"UNITS\s+DISTANCE\s+MICRONS\s+(\d+)", text)
    if not units_match:
        return {**result, "reason": "DEF units missing"}
    units = int(units_match.group(1))
    rows = {}
    for m in re.finditer(r"\bROW\s+\S+\s+\S+\s+(-?\d+)\s+(-?\d+)\s+\S+\s+"
                         r"DO\s+(\d+)\s+BY\s+(\d+)\s+STEP\s+(-?\d+)\s+(-?\d+)", text):
        x, y, nx, ny, sx, sy = map(int, m.groups())
        if nx > 0 and ny > 0 and sx > 0:
            for dy in range(ny):
                rows.setdefault(y + dy * sy, []).append((x, x + nx * sx, sx))
    if not rows:
        return {**result, "reason": "no usable ROW definition"}
    section = re.search(r"\bCOMPONENTS\s+(\d+)\s*;(.*?)\bEND\s+COMPONENTS", text, re.S)
    if not section:
        return {**result, "reason": "COMPONENTS section missing"}
    cells = []
    errors = []
    blocks = list(re.finditer(r"(?:^|\n)\s*-\s+(\S+)\s+(\S+)\s+(.*?);", section.group(2), re.S))
    if len(blocks) != int(section.group(1)):
        errors.append({"type": "component_count", "declared": int(section.group(1)), "parsed": len(blocks)})
    row_ys = sorted(rows)
    row_gaps = [b - a for a, b in zip(row_ys, row_ys[1:]) if b > a]
    heights = [round(m["size"][1] * units) for name, m in macros.items()
               if name not in block_macros and m["size"][1] > 0]
    row_height = min(row_gaps or heights or [1])
    for match in blocks:
        name, macro, attrs = match.groups()
        pos = re.search(r"\+\s+(PLACED|FIXED|COVER)\s*\(\s*(-?\d+)\s+(-?\d+)\s*\)\s*(\S+)", attrs)
        if not pos:
            errors.append({"type": "unplaced", "instance": name})
            continue
        if macro not in macros:
            errors.append({"type": "unknown_macro", "instance": name, "macro": macro})
            continue
        status, x, y, orient = pos.groups()
        x, y = int(x), int(y)
        w, h = (round(v * units) for v in macros[macro]["size"])
        if orient in ("E", "W", "FE", "FW"):
            w, h = h, w
        if w <= 0 or h <= 0:
            errors.append({"type": "invalid_cell_size", "instance": name})
            continue
        if status == "PLACED" and macro not in block_macros:
            valid_rows = h % row_height == 0 and all(
                any((x - ox) % sx == 0 and x >= ox and x + w <= ux
                    for ox, ux, sx in rows.get(yy, []))
                for yy in range(y, y + h, row_height))
            if not valid_rows:
                errors.append({"type": "row_site_or_bounds", "instance": name, "x": x, "y": y})
        cells.append((name, x, y, x + w, y + h))
    # Bucket by row-height bands, then compare only intersecting x intervals.
    buckets = {}
    for cell in cells:
        for band in range(math.floor((cell[2] - row_ys[0]) / row_height),
                          math.floor((cell[4] - 1 - row_ys[0]) / row_height) + 1):
            buckets.setdefault(band, []).append(cell)
    overlaps = set()
    for bucket in buckets.values():
        active = []
        for cell in sorted(bucket, key=lambda c: c[1]):
            active = [other for other in active if other[3] > cell[1]]
            for other in active:
                if min(cell[4], other[4]) > max(cell[2], other[2]):
                    overlaps.add(tuple(sorted((cell[0], other[0]))))
            active.append(cell)
    errors.extend({"type": "overlap", "instances": pair} for pair in sorted(overlaps))
    result.update({"legalized": bool(cells) and not errors, "component_count": len(blocks),
                   "checked_cells": len(cells), "row_count": len(rows), "overlap_count": len(overlaps),
                   "violation_count": len(errors), "sample": errors[:20],
                   "reason": None if cells and not errors else "placement checks failed"})
    return result
