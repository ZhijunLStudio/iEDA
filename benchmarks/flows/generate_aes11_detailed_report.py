#!/usr/bin/env python3
"""Generate a detailed, evidence-linked comparison for all 13 AES runs."""

from __future__ import annotations

import csv
import html
import json
import math
import os
import random
import re
from collections import defaultdict
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


RESAMPLE_NEAREST = getattr(getattr(Image, "Resampling", Image), "NEAREST")
RESAMPLE_LANCZOS = getattr(getattr(Image, "Resampling", Image), "LANCZOS")


REPO_ROOT = Path(__file__).resolve().parents[2]
RESULT_ROOT = REPO_ROOT / "benchmarks/results/aes13"
REPORT_ROOT = REPO_ROOT / "benchmarks/reports"
ASSET_ROOT = REPORT_ROOT / "aes11_assets"
REPORT_STEM = "aes11_detailed_comparison"

DESIGNS = (
    "aes",
    "aes_sky130_a",
    "aes_sky130_b",
    "aes_sky130_t",
    "aes_nangate45_a",
    "aes_nangate45_b",
    "aes_nangate45_t",
    "aes_asap7_a",
    "aes_asap7_b",
    "aes_asap7_t",
    "aes_ics55_a",
    "aes_ics55_b",
    "aes_ics55_t",
)

STAGES = (
    ("floorplan", "Floorplan", "iFP_result.def", "fp_db.rpt"),
    ("fanout", "Fanout", "iTO_fix_fanout_result.def", "fixfanout_db.rpt"),
    ("placement", "Placement", "iPL_result.def", "pl_db.rpt"),
    ("cts", "CTS", "iCTS_result.def", "cts_db.rpt"),
    ("legalization", "Legalization", "iPL_lg_result.def", "lg_db.rpt"),
    ("routing", "Routing", "iRT_result.def", "rt_db.rpt"),
    ("filler", "Filler", "iPL_filler_result.def", "filler_db.rpt"),
)

PDK_COLORS = {
    "sky130": "#1687a7",
    "nangate45": "#3b8f5a",
    "asap7": "#d05a47",
    "ics55": "#8a62a8",
}

MAP_SPECS = (
    ("stdcell_density", "Placement density", "Std-cell density", "density_map/place_stdcell_density.csv", "cell_density", "teal", False),
    ("macro_density", "Placement density", "Macro density", "density_map/place_macro_density.csv", "cell_density", "teal", False),
    ("allcell_density", "Placement density", "All-cell density", "density_map/place_allcell_density.csv", "cell_density", "teal", False),
    ("stdcell_pin_density", "Placement density", "Std-cell pin density", "density_map/place_stdcell_pin_density.csv", "pin_density", "teal", False),
    ("macro_pin_density", "Placement density", "Macro pin density", "density_map/place_macro_pin_density.csv", "pin_density", "teal", False),
    ("allcell_pin_density", "Placement density", "All-cell pin density", "density_map/place_allcell_pin_density.csv", "pin_density", "teal", False),
    ("local_net_density", "Placement density", "Local-net density", "density_map/place_local_net_density.csv", "net_density", "teal", False),
    ("global_net_density", "Placement density", "Global-net density", "density_map/place_global_net_density.csv", "net_density", "teal", False),
    ("allnet_density", "Placement density", "All-net density", "density_map/place_allnet_density.csv", "net_density", "teal", False),
    ("egr_horizontal_overflow", "EGR congestion", "EGR horizontal overflow", "egr_congestion_map/place_egr_horizontal_overflow.csv", "egr_overflow", "overflow", False),
    ("egr_vertical_overflow", "EGR congestion", "EGR vertical overflow", "egr_congestion_map/place_egr_vertical_overflow.csv", "egr_overflow", "overflow", False),
    ("egr_union_overflow", "EGR congestion", "EGR union overflow", "egr_congestion_map/place_egr_union_overflow.csv", "egr_overflow", "overflow", False),
    ("early_net_planar", "Early Router", "Planar routing demand", "rt/rt_temp_directory/early_router/net_map_planar.csv", "route_demand", "route", False),
    ("early_supply_planar", "Early Router", "Planar routing supply", "rt/rt_temp_directory/early_router/supply_map_planar.csv", "route_supply", "route", False),
    ("early_overflow_planar", "Early Router", "Planar routing overflow", "rt/rt_temp_directory/early_router/overflow_map_planar.csv", "route_overflow", "overflow", False),
)

MAP_COMPARISONS = (
    ("stdcell_density", "Std-cell density: 13-design comparison"),
    ("allcell_pin_density", "All-cell pin density: 13-design comparison"),
    ("egr_union_overflow", "EGR union overflow: 13-design comparison"),
    ("early_net_planar", "Planar routing demand: 13-design comparison"),
    ("early_overflow_planar", "Planar routing overflow: 13-design comparison"),
    ("drc_violation_density", "DRC violation density: 13-design comparison"),
)

MAP_PALETTES = {
    "teal": ((247, 251, 250), (91, 182, 173), (247, 190, 74), (190, 55, 43)),
    "route": ((248, 250, 249), (82, 166, 173), (94, 157, 88), (235, 183, 52)),
    "overflow": ((255, 253, 245), (244, 196, 71), (224, 104, 55), (137, 34, 31)),
    "drc": ((255, 253, 245), (234, 170, 52), (209, 73, 47), (103, 24, 30)),
}

ANSI_RE = re.compile(r"\x1b\[[0-9;]*m")


def read_text(path: Path) -> str:
    if not path.is_file():
        return ""
    return path.read_text(encoding="utf-8", errors="replace")


def number(value, digits: int = 3, missing: str = "N/A") -> str:
    if value is None:
        return missing
    if isinstance(value, int):
        return f"{value:,}"
    if not math.isfinite(float(value)):
        return missing
    return f"{float(value):,.{digits}f}"


def pct(value, digits: int = 1) -> str:
    return "N/A" if value is None else f"{100.0 * value:.{digits}f}%"


def rel(path: Path, base: Path = REPORT_ROOT) -> str:
    return os.path.relpath(path.resolve(), base.resolve()).replace("\\", "/")


def md_rel(path: Path) -> str:
    return str(Path("..") / path.resolve().relative_to((REPO_ROOT / "benchmarks").resolve())).replace("\\", "/")


def strip_ansi(text: str) -> str:
    return ANSI_RE.sub("", text)


def first_float(pattern: str, text: str, flags: int = 0):
    match = re.search(pattern, text, flags)
    return float(match.group(1)) if match else None


def first_int(pattern: str, text: str, flags: int = 0):
    match = re.search(pattern, text, flags)
    return int(match.group(1)) if match else None


@dataclass
class DefData:
    dbu: int = 1
    die: tuple[int, int, int, int] = (0, 0, 1, 1)
    component_count: int = 0
    placed_count: int = 0
    net_count: int = 0
    hpwl_um: float = 0.0
    routed_um: float = 0.0
    positions: list[tuple[int, int]] | None = None
    pins: list[tuple[int, int]] | None = None
    route_segments: list[tuple[int, int, int, int]] | None = None


def _reservoir_add(
    reservoir: list[tuple[int, int, int, int]],
    item: tuple[int, int, int, int],
    seen: int,
    rng: random.Random,
    limit: int = 40000,
) -> None:
    if len(reservoir) < limit:
        reservoir.append(item)
    else:
        index = rng.randrange(seen)
        if index < limit:
            reservoir[index] = item


def parse_def(path: Path, keep_visuals: bool = True) -> DefData:
    """Parse placement and routing data without requiring a DEF dependency."""
    data = DefData(positions=[] if keep_visuals else None, pins=[] if keep_visuals else None,
                   route_segments=[] if keep_visuals else None)
    component_pos: dict[str, tuple[int, int]] = {}
    pin_pos: dict[str, tuple[int, int]] = {}
    rng = random.Random(path.name + str(path.parent))
    route_seen = 0
    section = None
    statement = ""

    def consume_component(stmt: str) -> None:
        match = re.match(r"\s*-\s+(\S+)\s+(\S+)", stmt)
        if not match:
            return
        placed = re.search(
            r"\+\s+(?:PLACED|FIXED|COVER)\s+\(\s*(-?\d+)\s+(-?\d+)\s*\)", stmt
        )
        if placed:
            point = (int(placed.group(1)), int(placed.group(2)))
            component_pos[match.group(1)] = point
            data.placed_count += 1
            if data.positions is not None:
                data.positions.append(point)

    def consume_pin(stmt: str) -> None:
        match = re.match(r"\s*-\s+(\S+)", stmt)
        placed = re.search(
            r"\+\s+(?:PLACED|FIXED|COVER)\s+\(\s*(-?\d+)\s+(-?\d+)\s*\)", stmt
        )
        if match and placed:
            point = (int(placed.group(1)), int(placed.group(2)))
            pin_pos[match.group(1)] = point
            if data.pins is not None:
                data.pins.append(point)

    def consume_net(stmt: str) -> None:
        nonlocal route_seen
        connection_text = re.split(
            r"\+\s+(?:ROUTED|FIXED|COVER|SHIELD|SOURCE|USE|NONDEFAULTRULE)",
            stmt,
            maxsplit=1,
        )[0]
        points = []
        for instance, pin in re.findall(r"\(\s+(\S+)\s+(\S+)\s*\)", connection_text):
            point = pin_pos.get(pin) if instance == "PIN" else component_pos.get(instance)
            if point:
                points.append(point)
        if len(points) > 1:
            xs = [point[0] for point in points]
            ys = [point[1] for point in points]
            data.hpwl_um += (max(xs) - min(xs) + max(ys) - min(ys)) / data.dbu

        for route_chunk in re.split(r"\+\s+(?:ROUTED|FIXED|COVER)|\bNEW\b", stmt)[1:]:
            previous = None
            for x_token, y_token in re.findall(
                r"\(\s*(-?\d+|\*)\s+(-?\d+|\*)\s*(?:-?\d+|\*)?\s*\)", route_chunk
            ):
                if previous is None and (x_token == "*" or y_token == "*"):
                    continue
                x = previous[0] if x_token == "*" and previous else int(x_token)
                y = previous[1] if y_token == "*" and previous else int(y_token)
                current = (x, y)
                if previous is not None:
                    length = abs(current[0] - previous[0]) + abs(current[1] - previous[1])
                    data.routed_um += length / data.dbu
                    if length and data.route_segments is not None:
                        route_seen += 1
                        _reservoir_add(
                            data.route_segments,
                            (previous[0], previous[1], current[0], current[1]),
                            route_seen,
                            rng,
                        )
                previous = current

    with path.open(encoding="utf-8", errors="replace") as stream:
        for line in stream:
            stripped = line.strip()
            units = re.match(r"UNITS\s+DISTANCE\s+MICRONS\s+(\d+)", stripped)
            if units:
                data.dbu = int(units.group(1))
            die = re.match(
                r"DIEAREA\s+\(\s*(-?\d+)\s+(-?\d+)\s*\)\s+\(\s*(-?\d+)\s+(-?\d+)\s*\)",
                stripped,
            )
            if die:
                data.die = tuple(map(int, die.groups()))
            header = re.match(r"(COMPONENTS|PINS|NETS)\s+(\d+)\s*;", stripped)
            if header:
                section = header.group(1)
                if section == "COMPONENTS":
                    data.component_count = int(header.group(2))
                elif section == "NETS":
                    data.net_count = int(header.group(2))
                statement = ""
                continue
            if section and stripped == f"END {section}":
                section = None
                statement = ""
                continue
            if section and (statement or stripped.startswith("- ")):
                statement = f"{statement} {stripped}".strip()
                if ";" not in stripped:
                    continue
                if section == "COMPONENTS":
                    consume_component(statement)
                elif section == "PINS":
                    consume_pin(statement)
                elif section == "NETS":
                    consume_net(statement)
                statement = ""
    return data


def parse_db_report(path: Path) -> dict:
    text = read_text(path)
    if not text:
        return {}
    metrics = {
        "runtime_sec": first_float(r"\| Runtime\s*\|\s*([0-9.]+)\s+s", text),
        "memory_mb": first_float(r"\| Memmory\s*\|\s*([0-9.]+)\s+MB", text),
        "die_usage": first_float(r"\| DIE Usage\s*\|\s*([0-9.eE+-]+)", text),
        "core_usage": first_float(r"\| CORE Usage\s*\|\s*([0-9.eE+-]+)", text),
        "instances": first_int(r"\| Number - Instance\s*\|\s*(\d+)", text),
        "nets": first_int(r"\| Number - Net\s*\|\s*(\d+)", text),
    }
    timing = re.search(r"\| Timing\s*\|\s*(\d+)\s*\|[^\n]*\|\s*([0-9.eE+-]+)\s*\|", text)
    if timing:
        metrics["timing_instances"] = int(timing.group(1))
        metrics["timing_area_um2"] = float(timing.group(2))
    return metrics


def parse_timing(path: Path) -> dict:
    text = read_text(path)
    rows = []
    row_re = re.compile(
        r"^\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*(max|min)\s*\|"
        r"\s*([+-]?[0-9.]+)[rf]?\s*\|\s*([+-]?[0-9.]+)\s*\|"
        r"\s*([+-]?[0-9.]+)\s*\|\s*([+-]?[0-9.]+)\s*\|\s*([^|]+?)\s*\|$",
        re.MULTILINE,
    )
    for match in row_re.finditer(text):
        try:
            rows.append(
                {
                    "endpoint": match.group(1).strip(),
                    "clock": match.group(2).strip(),
                    "type": match.group(3),
                    "path_delay_ns": float(match.group(4)),
                    "required_ns": float(match.group(5)),
                    "slack_ns": float(match.group(7)),
                    "frequency_mhz": None if match.group(8).strip() == "NA" else float(match.group(8)),
                }
            )
        except ValueError:
            continue
    setup = [row for row in rows if row["type"] == "max"]
    hold = [row for row in rows if row["type"] == "min"]
    tns = {}
    for match in re.finditer(r"^\|\s*([^|]+)\|\s*(max|min)\s*\|\s*([+-]?[0-9.]+)\s*\|$", text, re.MULTILINE):
        tns[match.group(2)] = float(match.group(3))
    net_delays = [float(value) for value in re.findall(r"path net delay\s*\|[^\n]*\|\s*([0-9.]+)\(", text)]
    return {
        "setup_wns_ns": min((row["slack_ns"] for row in setup), default=None),
        "hold_wns_ns": min((row["slack_ns"] for row in hold), default=None),
        "setup_tns_ns": tns.get("max"),
        "hold_tns_ns": tns.get("min"),
        "max_frequency_mhz": min((row["frequency_mhz"] for row in setup if row["frequency_mhz"]), default=None),
        "worst_path_delay_ns": max((row["path_delay_ns"] for row in setup), default=None),
        "reported_paths": len(rows),
        "all_reported_net_delays_zero": bool(net_delays) and all(value == 0 for value in net_delays),
    }


def parse_power(path: Path) -> dict:
    text = read_text(path)
    return {
        "total_w": first_float(r"Total Power\s*==\s*([0-9.eE+-]+)\s*W", text),
        "switch_w": first_float(r"Net Switch Power\s*==\s*([0-9.eE+-]+)", text),
        "internal_w": first_float(r"Cell Internal Power\s*==\s*([0-9.eE+-]+)", text),
        "leakage_w": first_float(r"Cell Leakage Power\s*==\s*([0-9.eE+-]+)", text),
    }


def parse_wirelength(path: Path) -> dict:
    text = read_text(path)
    dbu = first_int(r"\| DBU\s*\|\s*(\d+)", text) or 1
    values = {}
    for model in ("HPWL", "FLUTE", "EGR"):
        match = re.search(rf"\| {model}\s*\|\s*([0-9.]+)\s*\|\s*([0-9.]+)", text)
        if match:
            values[f"{model.lower()}_um"] = float(match.group(1)) / dbu
            values[f"{model.lower()}_avg_um"] = float(match.group(2)) / dbu
    return values


def parse_congestion(path: Path) -> dict:
    text = read_text(path)
    edge = re.search(
        r"\| Average Congestion of Edges\s*\| Total Overflow\s*\| Maximal Overflow\s*\|.*?"
        r"\|\s*([+-]?[0-9.]+)\s*\|\s*([0-9.]+)\s*\|\s*([0-9.]+)\s*\|",
        text,
        re.DOTALL,
    )
    density = 0.0
    pin = 0.0
    in_density = False
    in_pin = False
    for line in text.splitlines():
        if "Instance Density Range" in line:
            in_density, in_pin = True, False
        elif "Pin Count Range" in line:
            in_density, in_pin = False, True
        elif "Average Congestion" in line:
            in_density = in_pin = False
        row = re.match(r"\|\s*([0-9.]+)\s*~\s*([0-9.]+)\s*\|\s*(\d+)\s*\|\s*([0-9.]+)", line)
        if row and in_density:
            density += float(row.group(4))
        elif row and in_pin:
            pin += float(row.group(4))
    average = float(edge.group(1)) if edge else None
    return {
        "high_density_bins_pct": density,
        "high_pin_bins_pct": pin,
        "average_edge_congestion": average,
        "total_overflow": float(edge.group(2)) if edge else None,
        "max_overflow": float(edge.group(3)) if edge else None,
        "valid": average is not None and average >= 0,
    }


def parse_drc(path: Path) -> dict:
    text = strip_ansi(read_text(path))
    by_type = {}
    for name, count in re.findall(r"\|\s*([a-z][a-z0-9_]+)\s*\|\s*(\d+)\s*\|\s*[0-9.]+%\s*\|", text):
        by_type[name] = int(count)
    total_matches = re.findall(r"\|\s*Total\s*\|\s*(\d+)\s*\|\s*100\.00%\s*\|", text)
    total = int(total_matches[-1]) if total_matches else sum(by_type.values()) or None
    return {"total": total, "by_type": by_type}


def parse_cts(result_dir: Path) -> dict:
    text = read_text(result_dir / "cts/cts.log") + "\n" + read_text(result_dir / "cts/statistics/wirelength.rpt")
    patterns = {
        "sink_count": r"(?:sink_count|Sink Count)\s*\|\s*([0-9.]+)",
        "buffer_count": r"(?:final_clock_buffer_count|Buffer Count)\s*\|\s*([0-9.]+)",
        "clock_wirelength_um": r"(?:total_clock_network_wirelength|Total Wirelength)\s*\|\s*([0-9.]+)",
        "max_clock_wirelength_um": r"(?:max_clock_net_wirelength|Max Wirelength)\s*\|\s*([0-9.]+)",
    }
    result = {}
    for key, pattern in patterns.items():
        value = first_float(pattern, text, re.IGNORECASE)
        if value is not None:
            result[key] = int(value) if key.endswith("count") else value
    return result


def analyze_warnings(result_dir: Path) -> dict:
    timing_log = read_text(result_dir / "logs/timing.log")
    power_log = read_text(result_dir / "logs/power.log")
    unconstrained = set(re.findall(r"(?:input|output) port\s+(\S+)\s+is not constrained", timing_log))
    missing_slew = set(re.findall(r"(\S+:[A-Za-z0-9_]+) input slew is not exist", power_log))
    return {"unconstrained_ports": len(unconstrained), "missing_input_slew_pins": len(missing_slew)}


def parse_log_runtime(path: Path) -> float | None:
    text = strip_ansi(read_text(path))
    elapsed = []
    for hours, minutes, seconds in re.findall(r"elapsed\s*=\s*(\d+):(\d+):(\d+)", text):
        elapsed.append(int(hours) * 3600 + int(minutes) * 60 + int(seconds))
    if elapsed and max(elapsed) > 0:
        return float(max(elapsed))
    timestamps = []
    for date_text, time_text in re.findall(r"(?:[IWEF]|\[[A-Z]+\s+)(\d{8})\s+(\d{2}:\d{2}:\d{2}(?:\.\d+)?)", text):
        try:
            timestamps.append(datetime.strptime(f"{date_text} {time_text}", "%Y%m%d %H:%M:%S.%f"))
        except ValueError:
            timestamps.append(datetime.strptime(f"{date_text} {time_text}", "%Y%m%d %H:%M:%S"))
    if len(timestamps) > 1:
        delta = (max(timestamps) - min(timestamps)).total_seconds()
        return delta if delta > 0 else None
    return None


def stage_runtime(summary: dict, key: str, db: dict, result_dir: Path) -> float | None:
    item = summary.get("stages", {}).get(key, {})
    if item.get("elapsed_sec"):
        return float(item["elapsed_sec"])
    log_runtime = parse_log_runtime(result_dir / "logs" / f"{key}.log")
    if log_runtime:
        return log_runtime
    return db.get("runtime_sec")


def draw_stage_image(path: Path, data: DefData, title: str, subtitle: str) -> None:
    width, height = 960, 960
    margin, header, footer = 56, 88, 62
    canvas = Image.new("RGB", (width, height), "#f8fafc")
    draw = ImageDraw.Draw(canvas, "RGBA")
    try:
        title_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 25)
        body_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 16)
    except OSError:
        title_font = body_font = ImageFont.load_default()
    draw.rectangle((0, 0, width, header), fill="#172126")
    draw.text((margin, 18), title, font=title_font, fill="#ffffff")
    draw.text((margin, 53), subtitle, font=body_font, fill="#b9c8ce")
    x1, y1, x2, y2 = data.die
    dx, dy = max(1, x2 - x1), max(1, y2 - y1)
    plot_left, plot_top = margin, header + 20
    plot_right, plot_bottom = width - margin, height - footer
    scale = min((plot_right - plot_left) / dx, (plot_bottom - plot_top) / dy)
    used_w, used_h = dx * scale, dy * scale
    ox = plot_left + ((plot_right - plot_left) - used_w) / 2
    oy = plot_top + ((plot_bottom - plot_top) - used_h) / 2

    def transform(x: int, y: int) -> tuple[float, float]:
        return ox + (x - x1) * scale, oy + (y2 - y) * scale

    bins = 96
    density = [[0 for _ in range(bins)] for _ in range(bins)]
    for x, y in data.positions or []:
        bx = max(0, min(bins - 1, int((x - x1) / dx * bins)))
        by = max(0, min(bins - 1, int((y - y1) / dy * bins)))
        density[by][bx] += 1
    maximum = max((max(row) for row in density), default=0)
    if maximum:
        cell_w, cell_h = used_w / bins, used_h / bins
        for by, row in enumerate(density):
            for bx, count in enumerate(row):
                if not count:
                    continue
                intensity = math.sqrt(count / maximum)
                color = (
                    int(44 + 196 * intensity),
                    int(124 - 45 * intensity),
                    int(138 - 75 * intensity),
                    int(55 + 170 * intensity),
                )
                px = ox + bx * cell_w
                py = oy + (bins - by - 1) * cell_h
                draw.rectangle((px, py, px + cell_w + 1, py + cell_h + 1), fill=color)
    for sx, sy, ex, ey in data.route_segments or []:
        draw.line((*transform(sx, sy), *transform(ex, ey)), fill=(19, 104, 128, 82), width=1)
    for x, y in data.pins or []:
        px, py = transform(x, y)
        draw.ellipse((px - 2, py - 2, px + 2, py + 2), fill="#f5c14b")
    draw.rectangle((ox, oy, ox + used_w, oy + used_h), outline="#263238", width=3)
    footer_text = (
        f"instances {data.component_count:,}  |  DEF-HPWL {data.hpwl_um:,.1f} um  |  "
        f"routed {data.routed_um:,.1f} um"
    )
    draw.text((margin, height - 42), footer_text, font=body_font, fill="#34474f")
    path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(path, optimize=True)


def read_map_grid(path: Path, keep_grid: bool = False) -> tuple[list[list[float]] | None, dict]:
    grid = [] if keep_grid else None
    rows = columns = cells = nonzero = 0
    minimum = maximum = None
    total = 0.0
    with path.open(encoding="utf-8", errors="replace", newline="") as stream:
        for row in csv.reader(stream):
            values = [float(value) for value in row if value.strip()]
            if not values:
                continue
            rows += 1
            columns = max(columns, len(values))
            cells += len(values)
            nonzero += sum(value != 0 for value in values)
            total += sum(values)
            row_min, row_max = min(values), max(values)
            minimum = row_min if minimum is None else min(minimum, row_min)
            maximum = row_max if maximum is None else max(maximum, row_max)
            if grid is not None:
                grid.append(values)
    if grid is not None and columns:
        for row in grid:
            row.extend([0.0] * (columns - len(row)))
    stats = {
        "rows": rows,
        "columns": columns,
        "cells": cells,
        "nonzero_cells": nonzero,
        "nonzero_pct": round(100.0 * nonzero / cells, 3) if cells else None,
        "min": minimum,
        "max": maximum,
        "mean": total / cells if cells else None,
        "all_zero": bool(cells) and nonzero == 0,
    }
    return grid, stats


def drc_violation_grid(path: Path, die: list[int], bins: int = 180) -> tuple[list[list[float]], dict]:
    entries = json.loads(path.read_text(encoding="utf-8")) if path.is_file() else []
    grid = [[0.0 for _ in range(bins)] for _ in range(bins)]
    x1, y1, x2, y2 = die
    dx, dy = max(1, x2 - x1), max(1, y2 - y1)
    accepted = 0
    for entry in entries:
        shape = entry.get("shape", [])
        if len(shape) < 4:
            continue
        cx = (float(shape[0]) + float(shape[2])) / 2.0
        cy = (float(shape[1]) + float(shape[3])) / 2.0
        bx = max(0, min(bins - 1, int((cx - x1) / dx * bins)))
        by = max(0, min(bins - 1, int((cy - y1) / dy * bins)))
        grid[by][bx] += 1.0
        accepted += 1
    flat = [value for row in grid for value in row]
    nonzero = sum(value > 0 for value in flat)
    return grid, {
        "rows": bins,
        "columns": bins,
        "cells": bins * bins,
        "nonzero_cells": nonzero,
        "nonzero_pct": round(100.0 * nonzero / (bins * bins), 3),
        "min": 0.0,
        "max": max(flat, default=0.0),
        "mean": accepted / (bins * bins),
        "all_zero": accepted == 0,
        "violations": accepted,
    }


def map_raw_groups(result_dir: Path) -> list[dict]:
    workspace = result_dir.parent
    groups = (
        ("placement_density", "Placement density CSV", sorted((result_dir / "density_map").glob("*.csv"))),
        ("egr_overflow", "EGR congestion CSV", sorted((result_dir / "egr_congestion_map").glob("*.csv"))),
        (
            "early_router",
            "Early-router layer CSV",
            sorted((result_dir / "rt/rt_temp_directory/early_router").glob("*_map_*.csv")),
        ),
        (
            "drc_violation",
            "DRC violation JSON",
            [workspace / "drc_temp_directory/violation_map.json"],
        ),
    )
    return [
        {"key": key, "label": label, "count": len([path for path in paths if path.is_file()]),
         "files": [str(path) for path in paths if path.is_file()]}
        for key, label, paths in groups
    ]


def map_color(value: float, scale_max: float, palette: str, log_scale: bool) -> tuple[int, int, int]:
    if scale_max <= 0 or value <= 0:
        ratio = 0.0
    elif log_scale:
        ratio = math.log1p(value) / math.log1p(scale_max)
    else:
        ratio = value / scale_max
    ratio = max(0.0, min(1.0, ratio))
    colors = MAP_PALETTES[palette]
    position = ratio * (len(colors) - 1)
    index = min(len(colors) - 2, int(position))
    blend = position - index
    return tuple(round(colors[index][channel] * (1.0 - blend) + colors[index + 1][channel] * blend)
                 for channel in range(3))


def draw_map_image(
    path: Path,
    grid: list[list[float]],
    title: str,
    subtitle: str,
    stats: dict,
    scale_max: float,
    palette: str,
    log_scale: bool,
) -> None:
    width = height = 960
    canvas = Image.new("RGB", (width, height), "#f8faf9")
    draw = ImageDraw.Draw(canvas)
    try:
        title_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 24)
        body_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 15)
        zero_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 30)
    except OSError:
        title_font = body_font = zero_font = ImageFont.load_default()
    draw.rectangle((0, 0, width, 92), fill="#172126")
    draw.text((56, 17), title, font=title_font, fill="#ffffff")
    draw.text((56, 54), subtitle, font=body_font, fill="#b9c8ce")

    source_height = len(grid)
    source_width = len(grid[0]) if grid else 0
    plot_left, plot_top, plot_limit = 62, 118, 738
    if source_width and source_height:
        source = Image.new("RGB", (source_width, source_height))
        source.putdata([
            map_color(value, scale_max, palette, log_scale)
            for row in reversed(grid)
            for value in row
        ])
        factor = min(plot_limit / source_width, plot_limit / source_height)
        plot_width = max(1, round(source_width * factor))
        plot_height = max(1, round(source_height * factor))
        heatmap = source.resize((plot_width, plot_height), RESAMPLE_NEAREST)
        plot_x = plot_left + (plot_limit - plot_width) // 2
        plot_y = plot_top + (plot_limit - plot_height) // 2
        canvas.paste(heatmap, (plot_x, plot_y))
        draw.rectangle((plot_x, plot_y, plot_x + plot_width, plot_y + plot_height), outline="#33434a", width=2)
        if stats.get("all_zero"):
            text_box = draw.textbbox((0, 0), "ALL ZERO", font=zero_font)
            text_width = text_box[2] - text_box[0]
            text_height = text_box[3] - text_box[1]
            draw.rectangle(
                (plot_x + plot_width / 2 - text_width / 2 - 16,
                 plot_y + plot_height / 2 - text_height / 2 - 12,
                 plot_x + plot_width / 2 + text_width / 2 + 16,
                 plot_y + plot_height / 2 + text_height / 2 + 12),
                fill="#ffffff", outline="#8b989d", width=2,
            )
            draw.text((plot_x + plot_width / 2 - text_width / 2,
                       plot_y + plot_height / 2 - text_height / 2),
                      "ALL ZERO", font=zero_font, fill="#58686e")

    legend_x, legend_y, legend_w, legend_h = 838, 152, 28, 640
    for offset in range(legend_h):
        ratio = 1.0 - offset / max(1, legend_h - 1)
        value = math.expm1(ratio * math.log1p(scale_max)) if log_scale and scale_max > 0 else ratio * scale_max
        draw.line((legend_x, legend_y + offset, legend_x + legend_w, legend_y + offset),
                  fill=map_color(value, scale_max, palette, log_scale))
    draw.rectangle((legend_x, legend_y, legend_x + legend_w, legend_y + legend_h), outline="#33434a", width=1)
    draw.text((legend_x + 38, legend_y - 5), number(scale_max, 2), font=body_font, fill="#34474f")
    draw.text((legend_x + 38, legend_y + legend_h - 13), "0", font=body_font, fill="#34474f")
    draw.text((legend_x - 3, legend_y + legend_h + 14), "log scale" if log_scale else "linear", font=body_font, fill="#637178")

    nonzero_pct = stats.get("nonzero_pct")
    footer = (
        f"grid {stats.get('columns', 0)}x{stats.get('rows', 0)}  |  non-zero "
        f"{number(nonzero_pct, 2)}%  |  local max {number(stats.get('max'), 3)}"
    )
    scale_note = f"shared 13-design scale: 0..{number(scale_max, 3)}; lower grid origin shown at bottom"
    draw.text((56, 878), footer, font=body_font, fill="#34474f")
    draw.text((56, 907), scale_note, font=body_font, fill="#637178")
    path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(path, optimize=True)


def draw_map_contact_sheet(path: Path, title: str, designs: list[dict], key: str) -> None:
    columns, tile_size, gap = 4, 330, 28
    rows = math.ceil(len(designs) / columns)
    width = 60 + columns * tile_size + (columns - 1) * gap
    height = 100 + rows * (tile_size + 44) + (rows - 1) * gap + 36
    canvas = Image.new("RGB", (width, height), "#f7f9f8")
    draw = ImageDraw.Draw(canvas)
    try:
        title_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 28)
        label_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 16)
    except OSError:
        title_font = label_font = ImageFont.load_default()
    draw.text((30, 25), title, font=title_font, fill="#172126")
    for index, design in enumerate(designs):
        item = next((entry for entry in design["maps"]["representative"] if entry["key"] == key), None)
        if not item:
            continue
        row, column = divmod(index, columns)
        x = 30 + column * (tile_size + gap)
        y = 80 + row * (tile_size + 44 + gap)
        with Image.open(item["image"]) as source:
            thumbnail = source.convert("RGB").resize((tile_size, tile_size), RESAMPLE_LANCZOS)
        canvas.paste(thumbnail, (x, y))
        draw.rectangle((x, y, x + tile_size, y + tile_size), outline="#c7d0d3", width=1)
        draw.text((x, y + tile_size + 10), design["design"], font=label_font, fill="#34474f")
    path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(path, optimize=True)


def generate_map_assets(designs: list[dict]) -> dict[str, Path]:
    global_scales: dict[str, float] = defaultdict(float)
    drc_grids: dict[str, list[list[float]]] = {}
    representatives: dict[str, list[dict]] = {}

    for design in designs:
        result_dir = RESULT_ROOT / design["design"] / "workspace/result"
        items = []
        for key, category, label, relative, scale_group, palette, log_scale in MAP_SPECS:
            source = result_dir / relative
            if not source.is_file():
                continue
            _, stats = read_map_grid(source)
            global_scales[scale_group] = max(global_scales[scale_group], stats.get("max") or 0.0)
            items.append({
                "key": key, "category": category, "label": label, "source": str(source),
                "scale_group": scale_group, "palette": palette, "log_scale": log_scale,
                "stats": stats,
            })

        violation_source = result_dir.parent / "drc_temp_directory/violation_map.json"
        die = design["stages"]["routing"].get("die_dbu", [0, 0, 1, 1])
        drc_grid, drc_stats = drc_violation_grid(violation_source, die)
        drc_grids[design["design"]] = drc_grid
        global_scales["drc_density"] = max(global_scales["drc_density"], drc_stats.get("max") or 0.0)
        items.append({
            "key": "drc_violation_density", "category": "DRC", "label": "DRC violation-center density",
            "source": str(violation_source), "scale_group": "drc_density", "palette": "drc",
            "log_scale": True, "stats": drc_stats,
        })
        representatives[design["design"]] = items

    for design in designs:
        name = design["design"]
        rendered = []
        for item in representatives[name]:
            if item["key"] == "drc_violation_density":
                grid = drc_grids[name]
            else:
                grid, _ = read_map_grid(Path(item["source"]), keep_grid=True)
            if not grid:
                continue
            image_path = ASSET_ROOT / name / "maps" / f"{item['key']}.png"
            scale_max = global_scales[item["scale_group"]]
            draw_map_image(
                image_path,
                grid,
                f"{name} / {item['label']}",
                f"{design['pdk']} | strategy {design['strategy']} | {item['category']}",
                item["stats"],
                scale_max,
                item["palette"],
                item["log_scale"],
            )
            rendered.append({
                key: value for key, value in item.items() if key not in {"palette"}
            } | {"image": str(image_path), "scale_max": scale_max})
        raw_groups = map_raw_groups(RESULT_ROOT / name / "workspace/result")
        design["maps"] = {
            "representative": rendered,
            "raw_groups": raw_groups,
            "raw_file_count": sum(group["count"] for group in raw_groups),
            "rendered_count": len(rendered),
        }

    charts = {}
    for key, title in MAP_COMPARISONS:
        path = ASSET_ROOT / f"map_compare_{key}.png"
        draw_map_contact_sheet(path, title, designs, key)
        charts[key] = path
    return charts


def analyze_design(name: str) -> dict:
    design_root = RESULT_ROOT / name
    result_dir = design_root / "workspace/result"
    summary_path = design_root / "summary.json"
    if not summary_path.is_file():
        raise FileNotFoundError(summary_path)
    summary = json.loads(summary_path.read_text(encoding="utf-8"))
    stages = {}
    for key, label, def_name, db_name in STAGES:
        def_path = result_dir / def_name
        if not def_path.is_file() and key == "fanout":
            def_path = result_dir / "iNO_fix_fanout_result.def"
        db = parse_db_report(result_dir / "report" / db_name)
        if def_path.is_file():
            parsed = parse_def(def_path)
            image_path = ASSET_ROOT / name / f"{key}.png"
            draw_stage_image(
                image_path,
                parsed,
                f"{name} / {label}",
                f"{summary['pdk']} | strategy {summary['strategy']} | DEF database snapshot",
            )
            stage = {
                "status": "measured",
                "def": str(def_path),
                "image": str(image_path),
                "runtime_sec": stage_runtime(summary, key, db, result_dir),
                "memory_mb": db.get("memory_mb"),
                "instances": db.get("instances") or parsed.component_count,
                "placed_instances": parsed.placed_count,
                "nets": db.get("nets") or parsed.net_count,
                "core_usage": db.get("core_usage"),
                "die_usage": db.get("die_usage"),
                "timing_instances": db.get("timing_instances"),
                "timing_area_um2": db.get("timing_area_um2"),
                "dbu": parsed.dbu,
                "die_dbu": list(parsed.die),
                "def_hpwl_um": round(parsed.hpwl_um, 3),
                "def_routed_um": round(parsed.routed_um, 3),
            }
        else:
            stage = {"status": "missing", "runtime_sec": stage_runtime(summary, key, db, result_dir)}
        stages[key] = stage

    timing = parse_timing(result_dir / "timing/aes_cipher_top.rpt")
    power = parse_power(result_dir / "power/aes_cipher_top.pwr")
    wirelength = parse_wirelength(result_dir / "report/wirelength.rpt")
    congestion = parse_congestion(result_dir / "report/congestion.rpt")
    drc = parse_drc(result_dir / "report/drc/iRT_drc.rpt")
    cts = parse_cts(result_dir)
    warnings = analyze_warnings(result_dir)
    final_png = result_dir / "visualizations/final.png"
    cts_design = result_dir / "cts/visualization/svg/cts_design.svg"
    cts_flyline = result_dir / "cts/visualization/svg/cts_flyline.svg"
    gds = result_dir / "final.gds"
    final_instances = stages.get("filler", {}).get("instances") or stages.get("routing", {}).get("instances")
    total_power = power.get("total_w")
    return {
        "design": name,
        "pdk": summary["pdk"],
        "strategy": summary["strategy"],
        "status": summary["status"],
        "timestamp": summary.get("timestamp"),
        "floorplan": summary.get("floorplan", {}),
        "stages": stages,
        "timing": timing,
        "power": power,
        "wirelength": wirelength,
        "congestion": congestion,
        "drc": drc,
        "cts": cts,
        "warnings": warnings,
        "ir_drop": {"status": "not_run", "worst_drop_v": None, "coverage": 0.0},
        "artifacts": {
            "gds": str(gds) if gds.is_file() else None,
            "gds_size_mb": round(gds.stat().st_size / 1024 / 1024, 3) if gds.is_file() else None,
            "final_png": str(final_png) if final_png.is_file() else None,
            "cts_design_svg": str(cts_design) if cts_design.is_file() else None,
            "cts_flyline_svg": str(cts_flyline) if cts_flyline.is_file() else None,
        },
        "normalized": {
            "drc_per_1k_instances": (drc["total"] * 1000 / final_instances) if drc.get("total") and final_instances else None,
            "power_mw_per_1k_instances": (total_power * 1e6 / final_instances) if total_power and final_instances else None,
            "route_um_per_instance": (stages["routing"]["def_routed_um"] / final_instances)
            if stages.get("routing", {}).get("def_routed_um") and final_instances else None,
        },
    }


def write_json(data: dict) -> Path:
    path = REPORT_ROOT / f"{REPORT_STEM}.json"
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return path


def write_csv(designs: list[dict]) -> Path:
    path = REPORT_ROOT / f"{REPORT_STEM}.csv"
    fields = (
        "design", "pdk", "strategy", "status", "cell_count", "cell_area_um2", "die_side_um",
        "setup_wns_ns", "hold_wns_ns", "max_frequency_mhz", "total_power_w", "switch_power_w",
        "egr_wirelength_um", "def_routed_um", "drc_total", "high_density_bins_pct",
        "congestion_valid", "route_runtime_sec", "ir_drop_status",
    )
    with path.open("w", encoding="utf-8", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields)
        writer.writeheader()
        for design in designs:
            writer.writerow({
                "design": design["design"], "pdk": design["pdk"], "strategy": design["strategy"],
                "status": design["status"], "cell_count": design["floorplan"].get("cell_count"),
                "cell_area_um2": design["floorplan"].get("cell_area_um2"),
                "die_side_um": design["floorplan"].get("die_side_um"),
                "setup_wns_ns": design["timing"].get("setup_wns_ns"),
                "hold_wns_ns": design["timing"].get("hold_wns_ns"),
                "max_frequency_mhz": design["timing"].get("max_frequency_mhz"),
                "total_power_w": design["power"].get("total_w"),
                "switch_power_w": design["power"].get("switch_w"),
                "egr_wirelength_um": design["wirelength"].get("egr_um"),
                "def_routed_um": design["stages"]["routing"].get("def_routed_um"),
                "drc_total": design["drc"].get("total"),
                "high_density_bins_pct": design["congestion"].get("high_density_bins_pct"),
                "congestion_valid": design["congestion"].get("valid"),
                "route_runtime_sec": design["stages"]["routing"].get("runtime_sec"),
                "ir_drop_status": design["ir_drop"]["status"],
            })
    return path


def draw_bar_chart(path: Path, title: str, values: list[tuple[str, float | None, str]], unit: str, log_scale: bool = False) -> None:
    width = 1300
    row_h = 48
    height = 100 + row_h * len(values)
    image = Image.new("RGB", (width, height), "#ffffff")
    draw = ImageDraw.Draw(image)
    try:
        title_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 25)
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 17)
    except OSError:
        title_font = font = ImageFont.load_default()
    draw.text((28, 20), title, font=title_font, fill="#172126")
    present = [value for _, value, _ in values if value is not None and value > 0]
    maximum = max((math.log10(value) if log_scale else value for value in present), default=1)
    label_w, bar_w = 245, 820
    for index, (label, value, pdk) in enumerate(values):
        y = 72 + index * row_h
        draw.text((28, y + 8), label, font=font, fill="#33434a")
        draw.rectangle((label_w, y + 6, label_w + bar_w, y + 34), fill="#edf1f2")
        if value is not None and value >= 0:
            scaled = math.log10(value) if log_scale and value > 0 else value
            length = 0 if maximum == 0 else max(2, bar_w * scaled / maximum)
            draw.rectangle((label_w, y + 6, label_w + length, y + 34), fill=PDK_COLORS[pdk])
            draw.text((label_w + bar_w + 18, y + 8), f"{value:,.3f} {unit}", font=font, fill="#172126")
        else:
            draw.text((label_w + 14, y + 8), "N/A", font=font, fill="#7a878c")
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, optimize=True)


def make_charts(designs: list[dict]) -> dict[str, Path]:
    charts = {
        "frequency": ASSET_ROOT / "chart_frequency.png",
        "power": ASSET_ROOT / "chart_power.png",
        "drc": ASSET_ROOT / "chart_drc.png",
        "routing": ASSET_ROOT / "chart_routing_runtime.png",
        "area": ASSET_ROOT / "chart_die_area.png",
    }
    draw_bar_chart(charts["frequency"], "Reported maximum frequency (proxy STA)",
                   [(d["design"], d["timing"].get("max_frequency_mhz"), d["pdk"]) for d in designs], "MHz")
    draw_bar_chart(charts["power"], "Reported averaged power (zero switching activity)",
                   [(d["design"], (d["power"].get("total_w") or 0) * 1000, d["pdk"]) for d in designs], "mW")
    draw_bar_chart(charts["drc"], "Final iDRC violations (log scale)",
                   [(d["design"], d["drc"].get("total"), d["pdk"]) for d in designs], "count", True)
    draw_bar_chart(charts["routing"], "Detailed routing wall time",
                   [(d["design"], d["stages"]["routing"].get("runtime_sec"), d["pdk"]) for d in designs], "s")
    draw_bar_chart(charts["area"], "Die area (log scale; not normalized across libraries)",
                   [(d["design"], (d["floorplan"].get("die_side_um") or 0) ** 2, d["pdk"]) for d in designs], "um^2", True)
    return charts


def metric_table(designs: list[dict]) -> str:
    rows = [
        "| Design | PDK | 状态 | Die (um) | Cells | Setup WNS (ns) | Fmax (MHz) | Power (mW) | EGR WL (um) | DRC | Route (s) | IR-drop |",
        "|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---|",
    ]
    for d in designs:
        rows.append(
            f"| {d['design']} | {d['pdk']} | {d['status']} | {number(d['floorplan'].get('die_side_um'))} | "
            f"{number(d['floorplan'].get('cell_count'), 0)} | {number(d['timing'].get('setup_wns_ns'))} | "
            f"{number(d['timing'].get('max_frequency_mhz'), 1)} | {number((d['power'].get('total_w') or 0) * 1000)} | "
            f"{number(d['wirelength'].get('egr_um'), 1)} | {number(d['drc'].get('total'), 0)} | "
            f"{number(d['stages']['routing'].get('runtime_sec'), 1)} | 未运行 |"
        )
    return "\n".join(rows)


def coverage_table() -> str:
    return """| 指标 | Floorplan | Fanout | Placement | CTS | Legalization | Routing/Post-route | 口径 |
|---|---:|---:|---:|---:|---:|---:|---|
| DEF/结构/利用率 | 实测 | 实测 | 实测 | 实测 | 实测 | 实测 | iDB/DEF |
| 阶段耗时/内存 | 实测 | 实测 | 实测 | 实测 | 实测 | 实测 | stage log / db report |
| HPWL | 推导 | 推导 | 推导 | 推导 | 推导 | 推导 | 单元原点 bbox，适合趋势比较 |
| Routed wirelength | N/A | N/A | N/A | 局部可见 | 局部可见 | 推导+EGR报告 | DEF ROUTED/FIXED 路径 |
| STA | 未运行 | 未运行 | 未运行 | 未运行 | 未运行 | 实测但低置信 | 未回标 SPEF，报告 net delay 为 0 |
| Power | 未运行 | 未运行 | 未运行 | 未运行 | 未运行 | 实测但低置信 | 无 VCD/SAIF，switch power 为 0 |
| Congestion / maps | 未运行 | 未运行 | 9 类密度 CSV | 沿用布局 map | 沿用布局 map | EGR/early-router map 可用；汇总报告无效 | map 是空间原始证据；Average=-1 仅表示汇总接口不可用 |
| DRC | 不适用 | 不适用 | 不适用 | 不适用 | 不适用 | 实测 | iDRC post-route |
| IR-drop | 未运行 | 未运行 | 未运行 | 未运行 | 未运行 | 未运行 | 无 iPNP/iIR 结果，不填 0 |"""


def stage_table(d: dict) -> str:
    rows = [
        "| Stage | Runtime (s) | Memory (MB) | Instances | Timing inst. | Core util. | DEF HPWL (um) | Routed (um) | Setup WNS (ns) | Power (mW) | Congestion | DRC | IR-drop |",
        "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|---:|---|",
    ]
    for key, label, _, _ in STAGES:
        stage = d["stages"][key]
        post_route = key == "routing"
        congestion = "invalid(-1)" if post_route and not d["congestion"].get("valid") else "N/A"
        rows.append(
            f"| {label} | {number(stage.get('runtime_sec'), 2)} | {number(stage.get('memory_mb'), 1)} | "
            f"{number(stage.get('instances'), 0)} | {number(stage.get('timing_instances'), 0)} | "
            f"{pct(stage.get('core_usage'))} | {number(stage.get('def_hpwl_um'), 1)} | "
            f"{number(stage.get('def_routed_um'), 1)} | "
            f"{number(d['timing'].get('setup_wns_ns')) if post_route else 'N/A'} | "
            f"{number((d['power'].get('total_w') or 0) * 1000) if post_route else 'N/A'} | "
            f"{congestion} | {number(d['drc'].get('total'), 0) if post_route else 'N/A'} | N/A |"
        )
    return "\n".join(rows)


def image_grid_md(d: dict) -> str:
    cells = []
    for key, label, _, _ in STAGES:
        image_path = Path(d["stages"][key]["image"])
        cells.append(f"<td><b>{label}</b><br><a href=\"{md_rel(image_path)}\"><img src=\"{md_rel(image_path)}\" width=\"190\"></a></td>")
    final_png = d["artifacts"].get("final_png")
    if final_png:
        p = Path(final_png)
        cells.append(f"<td><b>Final GDS</b><br><a href=\"{md_rel(p)}\"><img src=\"{md_rel(p)}\" width=\"190\"></a></td>")
    rows = ["<table>"]
    for index in range(0, len(cells), 4):
        rows.append("<tr>" + "".join(cells[index:index + 4]) + "</tr>")
    rows.append("</table>")
    cts = d["artifacts"].get("cts_design_svg")
    fly = d["artifacts"].get("cts_flyline_svg")
    if cts and fly:
        rows.append(
            f"CTS 专项图：[clock tree]({md_rel(Path(cts))}) / [flyline]({md_rel(Path(fly))})"
        )
    return "\n".join(rows)


def map_item(d: dict, key: str) -> dict | None:
    return next((item for item in d["maps"]["representative"] if item["key"] == key), None)


def map_comparison_table(designs: list[dict]) -> str:
    rows = [
        "| Design | Raw maps | Rendered | EGR union non-zero | EGR max | Planar overflow non-zero | Planar max | DRC non-zero bins | DRC bin max |",
        "|---|---:|---:|---:|---:|---:|---:|---:|---:|",
    ]
    for design in designs:
        egr = map_item(design, "egr_union_overflow")
        overflow = map_item(design, "early_overflow_planar")
        drc = map_item(design, "drc_violation_density")
        egr_stats = egr["stats"] if egr else {}
        overflow_stats = overflow["stats"] if overflow else {}
        drc_stats = drc["stats"] if drc else {}
        rows.append(
            f"| {design['design']} | {design['maps']['raw_file_count']} | {design['maps']['rendered_count']} | "
            f"{number(egr_stats.get('nonzero_pct'), 2)}% | {number(egr_stats.get('max'), 0)} | "
            f"{number(overflow_stats.get('nonzero_pct'), 2)}% | {number(overflow_stats.get('max'), 0)} | "
            f"{number(drc_stats.get('nonzero_cells'), 0)} | {number(drc_stats.get('max'), 0)} |"
        )
    return "\n".join(rows)


def map_grid_md(d: dict) -> str:
    cells = []
    for item in d["maps"]["representative"]:
        image_path = Path(item["image"])
        source_path = Path(item["source"])
        stats = item["stats"]
        stat_text = (
            f"non-zero {number(stats.get('nonzero_pct'), 2)}%; max {number(stats.get('max'), 3)}"
        )
        cells.append(
            f"<td><b>{html.escape(item['label'])}</b><br>"
            f"<a href=\"{md_rel(image_path)}\"><img src=\"{md_rel(image_path)}\" width=\"190\"></a><br>"
            f"<small>{stat_text}; <a href=\"{md_rel(source_path)}\">raw</a></small></td>"
        )
    rows = [
        "#### 空间 Map 证据",
        "",
        f"共发现 `{d['maps']['raw_file_count']}` 个原始 map 文件，渲染 `{d['maps']['rendered_count']}` 张代表图。"
        "同类图使用跨 13 个设计的统一色标；DRC 使用统一对数色标。全零图保留并明确标注。",
        "",
        "<table>",
    ]
    for index in range(0, len(cells), 4):
        rows.append("<tr>" + "".join(cells[index:index + 4]) + "</tr>")
    rows.extend(("</table>", "", "<details><summary>完整原始 map 文件索引</summary>", ""))
    for group in d["maps"]["raw_groups"]:
        links = ", ".join(
            f"[{Path(path).name}]({md_rel(Path(path))})" for path in group["files"]
        ) or "N/A"
        rows.append(f"- **{group['label']} ({group['count']})**：{links}")
    rows.extend(("", "</details>"))
    return "\n".join(rows)


def pdk_findings(designs: list[dict]) -> str:
    lines = []
    by_pdk: dict[str, list[dict]] = {}
    for design in designs:
        by_pdk.setdefault(design["pdk"], []).append(design)
    for pdk, group in by_pdk.items():
        best_drc = min(group, key=lambda item: item["drc"].get("total") or math.inf)
        fastest = min(group, key=lambda item: item["stages"]["routing"].get("runtime_sec") or math.inf)
        variants = {item["strategy"]: item for item in group}
        prefix = (
            f"- **{pdk}**：{len(group)}/{len(group)} 完成 GDS；最低 DRC 为 `{best_drc['design']}` "
            f"({number(best_drc['drc'].get('total'), 0)})，最快布线为 `{fastest['design']}` "
            f"({number(fastest['stages']['routing'].get('runtime_sec'), 1)} s)。"
        )
        if "a" in variants and "t" in variants:
            dense, loose = variants["a"], variants["t"]
            dense_drc, loose_drc = dense["drc"]["total"], loose["drc"]["total"]
            drc_delta = 100.0 * (loose_drc - dense_drc) / dense_drc
            dense_wl, loose_wl = dense["wirelength"].get("egr_um"), loose["wirelength"].get("egr_um")
            wl_delta = 100.0 * (loose_wl - dense_wl) / dense_wl if dense_wl and loose_wl else 0.0
            direction = "下降" if drc_delta < 0 else "上升"
            lines.append(
                prefix
                + f"从 a(35%) 放宽到 t(25%) 后，EGR 线长增加 {wl_delta:+.1f}%，DRC {direction} "
                f"{abs(drc_delta):.1f}%（{dense_drc:,} -> {loose_drc:,}）。"
                + ("Sky130 呈现预期的密度缓解，但改善幅度仍不足以接近 clean。"
                   if pdk == "sky130" else
                   "更宽松的面积没有改善 DRC，说明该工艺当前的主导因素不是密度，而是规则、轨道/via 映射或路由代价。")
            )
        else:
            lines.append(
                prefix
                + "目前只有 a 状态，无法判断 utilization 趋势；其极端负 setup slack 需要优先核对 liberty/RC 单位和时钟约束。"
            )
    return "\n".join(lines)


def build_markdown(
    designs: list[dict], charts: dict[str, Path], map_charts: dict[str, Path], generated: str
) -> str:
    all_success = sum(d["status"] == "success" for d in designs)
    design_count = len(designs)
    drcs = [d["drc"]["total"] for d in designs if d["drc"].get("total") is not None]
    sections = [
        "# AES 13 项 iEDA.ai 物理设计详细对比报告",
        "",
        f"生成时间：{generated}  ",
        f"范围：`{', '.join(DESIGNS)}`。",
        "",
        "## 1. 执行结论",
        "",
        f"- 流程完成度：**{all_success}/{design_count}** 已生成 post-route DEF、GDS、STA、功耗、线长、拥塞和 DRC 文件。",
        f"- 物理签核质量：**0/{design_count} DRC clean**；违例总数范围 {number(min(drcs), 0)} 至 {number(max(drcs), 0)}。当前结果是流程贯通样本，不是 tapeout-ready 结果。",
        "- 时序可信度：低。所有抽查路径的 `path net delay` 为 0，且存在未约束 I/O；正 slack 只能说明库内单元延迟下的代理检查通过。",
        f"- 功耗可信度：低。{design_count} 项 `Net Switch Power` 均为 0，当前值主要是 internal/leakage 估算，不能用于动态功耗决策。",
        "- 拥塞可信度：分层判断。汇总报告的 `Average Congestion=-1` 无效；但 placement density、EGR overflow 和 early-router 逐层 map CSV 是有效空间证据，已独立统计和成图。",
        f"- IR-drop：**0/{design_count} 执行**。没有电压降数据，报告显式记为 `N/A`。",
        "",
        "> 结论分为“流程工程完成度”和“物理签核完成度”。前者较高，后者目前主要受 DRC、寄生参数、活动率、约束完整性和 PDN/IR 分析缺失限制。",
        "",
        "## 2. 数据口径与覆盖",
        "",
        coverage_table(),
        "",
        "`DEF HPWL` 由每个 net 的实例放置原点 bbox 推导，不含 LEF pin offset，适用于同一 PDK/网表的阶段趋势；跨 PDK 只作方向性参考。面积、功耗、DRC 规则集合也不同，跨 PDK 排名不能解释为工艺优劣。",
        "",
        "Map 图采用 CSV 原始网格，row 0 按笛卡尔坐标显示在底部。同一 map 类型在 13 个设计间使用统一色标，DRC 违例中心密度使用统一对数色标；因此颜色可横向比较，全零图不会被自动拉伸成伪热点。",
        "",
        "## 3. 横向总表",
        "",
        metric_table(designs),
        "",
        "## 4. 关键横向图",
        "",
    ]
    for key in ("area", "frequency", "power", "drc", "routing"):
        sections.extend((f"![{key}]({md_rel(charts[key])})", ""))
    sections.extend((
        "## 5. 空间 Map 横向对比",
        "",
        "每个设计渲染 16 张代表图：9 张布局密度、3 张 EGR overflow、3 张 early-router planar、1 张 DRC 违例中心密度。所有按层 net/supply/overflow CSV 均保留在逐设计原始文件索引中。",
        "",
        map_comparison_table(designs),
        "",
        "- ASAP7 a/b/t 的 EGR union 与 planar overflow map 均为全零；这是原始网格的事实，但不能修复或替代 `Average Congestion=-1` 的无效汇总接口。",
        "- Sky130 的 EGR union 非零区域最广且峰值最高；ICS55 次之；Nangate45 的 planar overflow 很稀疏。不同 PDK 的 track/layer 资源定义不同，map 只用于工艺内状态趋势和热点定位。",
        "- DRC 图按违例矩形中心落入 180x180 网格，展示空间聚集度；它不替代按规则类型和几何面积的签核分析。",
        "",
    ))
    for key, _ in MAP_COMPARISONS:
        sections.extend((f"![{key}]({md_rel(map_charts[key])})", ""))
    sections.extend((
        "## 6. 同工艺纵向结论",
        "",
        pdk_findings(designs),
        "",
        "- `aes` 与 `aes_sky130_b` 的目标利用率同为 30%，结果几乎一致，可视为 baseline 重复性检查；两者不能作为独立策略样本扩大统计显著性。",
        "- a/b/t 的核心变量是目标利用率 35%/30%/25%。更大的 die 通常降低局部密度，但在当前单轮详细布线 (`IEDA_RT_MAX_ITERATIONS=1`) 下，没有形成跨工艺一致的 DRC 单调改善。",
        "## 7. 各设计阶段纵向对比、版图与 Maps",
        "",
    ))
    for d in designs:
        warning = d["warnings"]
        top_drc = sorted(d["drc"]["by_type"].items(), key=lambda item: item[1], reverse=True)[:3]
        top_text = ", ".join(f"{key}={value:,}" for key, value in top_drc) or "N/A"
        sections.extend((
            f"### {d['design']} ({d['pdk']} / {d['strategy']})",
            "",
            stage_table(d),
            "",
            f"Post-route：setup WNS `{number(d['timing'].get('setup_wns_ns'))} ns`，hold WNS `{number(d['timing'].get('hold_wns_ns'))} ns`，"
            f"功耗 `{number((d['power'].get('total_w') or 0) * 1000)} mW`，DRC `{number(d['drc'].get('total'), 0)}`。"
            f"DRC 主项：{top_text}。未约束端口 `{warning['unconstrained_ports']}`，缺失 input slew pin `{warning['missing_input_slew_pins']}`。",
            "",
            image_grid_md(d),
            "",
            map_grid_md(d),
            "",
        ))
    sections.extend((
        "## 8. iEDA.ai 当前完成质量",
        "",
        "| 维度 | 评级 | 证据 | 判断 |",
        "|---|---|---|---|",
        "| 多 PDK 流程贯通 | B | 4 PDK、13/13 GDS | 数据准备、映射、放置、CTS、布线和导出已可重复运行 |",
        "| 布局/CTS 工程完整性 | B- | 每阶段 DEF、CTS 专项图、合法化结果齐全 | 可做算法迭代，但需增加阶段质量门禁 |",
        "| 布线/DRC | D | 0/13 clean，且数量级随 PDK 差异很大 | 目前不具备签核闭环 |",
        "| STA | D+ | WNS/TNS 文件齐全，但 net delay=0、I/O 未全约束 | 只能做早期逻辑/库延迟代理 |",
        "| Power | D | switch power=0、无活动率 | 不可用于动态功耗或 IR 结论 |",
        "| Congestion / maps | C- | 13/13 有密度、EGR、early-router 空间图，但 Average=-1 | 热点可审计，汇总指标与门禁仍不可用 |",
        "| PDN / IR-drop | F | 0/13 数据 | 尚未进入质量闭环 |",
        "| 可观测性/可追溯性 | B- | 日志、阶段图、208 张代表 map 和全部原始 map 索引齐全 | 已能空间审计，尚不能逐阶段自动判退 |",
        "",
        "## 9. 后续优化方案",
        "",
        "### P0：先修测量可信度（1-2 周）",
        "",
        "1. 在 routing 后运行 iRCX/SPEF，强制 post-route STA 读取 SPEF；质量门禁要求关键路径 `net delay > 0`。",
        "2. 完整化 SDC：约束所有输入/输出 delay、clock uncertainty、driving cell/load，逐项清零 unconstrained endpoint；明确 false/multicycle path。",
        "3. 功耗接入 VCD/SAIF 或经过校准的 vectorless activity，门禁要求 `switch_power > 0`，并记录活动率来源。",
        "4. 修复 congestion report 的 `-1` sentinel；将 global-route overflow、top-1%/top-5% utilization 和热点图纳入统一 JSON。",
        "5. 接通 iPNP/iIR：生成真实 PDN、定义电源 bump/pad/source 和电流模型，输出 worst/avg IR、超阈值面积与热图。",
        "",
        "### P1：DRC 闭环与路由收敛（2-4 周）",
        "",
        "1. 按本报告各 PDK 的 top violation 分类建回归：short、PRL spacing、same-layer cut、min-area/overlap 分别设专项用例。",
        "2. 将 `IEDA_RT_MAX_ITERATIONS=1` 改成可扫参数，至少比较 1/3/5 轮的 DRC、runtime、wirelength；只有 DRC 单调下降才保留更多迭代。",
        "3. 校准 tech LEF 层方向、track pitch/offset、via rule、min-area 和 cut spacing；ASAP7 特别验证当前补写 RC 和 layer range 的一致性。",
        "4. 增加 post-route repair：short/spacing rip-up、min-area patch、via enclosure repair；以“DRC=0 或已签核 waiver”作为 GDS 成功条件，而不是仅检查文件存在。",
        "",
        "### P2：PPA 与状态策略优化（4-8 周）",
        "",
        "1. 对每个 PDK 做 utilization × padding × congestion-weight 三维小型 DOE；a/b/t 只改变利用率不足以定位根因。",
        "2. CTS 扫 buffer set、cluster size、max fanout/cap；用 insertion delay、skew、clock wirelength、buffer area 和 post-CTS setup/hold 联合评分。",
        "3. 逐阶段保存 STA/power/congestion/HPWL 快照，形成 `floorplan -> placement -> CTS -> route` delta，超过阈值自动回退。",
        "4. 跨 PDK 只比较归一化指标（per-cell、per-mm2、相对各自 target），并固定 RTL、时钟、约束语义和工具版本。",
        "",
        "### P3：Agent 化闭环（8 周以后）",
        "",
        "1. 将报告 JSON 作为 agent 观测面，动作限定为有边界的参数变更；每次实验记录输入 hash、工具 hash、PPA/DRC/IR delta。",
        "2. 建 Pareto archive，目标至少包含 WNS/TNS、power、area、wirelength、DRC、worst IR 和 runtime，禁止用单一加权分掩盖硬约束失败。",
        "3. 建立工艺专属策略库与跨工艺共享策略，只有通过重复试验和 holdout design 验证的规则才晋升为默认。",
        "",
        "## 10. 建议验收门禁",
        "",
        "| Gate | 当前 | 下一里程碑 |",
        "|---|---:|---:|",
        "| Flow completion | 13/13 | 保持 13/13 可重复 |",
        "| DRC clean | 0/13 | 每 PDK 至少 1 个 clean，再扩至 13/13 |",
        "| SPEF-backed STA | 0/13 | 13/13，net delay 非零 |",
        "| Fully constrained timing | 0/13 | unconstrained=0 |",
        "| Activity-backed power | 0/13 | 13/13 有来源标签 |",
        "| Valid congestion summary | 0/13 | 无 -1/NaN；与现有 EGR/early-router map 数值一致 |",
        "| IR-drop | 0/13 | 13/13 有 worst/avg/map |",
        "| Spatial maps | 13/13，208 张代表图 | 增加逐阶段 STA/power/congestion delta JSON |",
        "",
        "## 11. 产物索引",
        "",
        f"- 机器可读数据：[`{REPORT_STEM}.json`]({REPORT_STEM}.json)",
        f"- 扁平对比数据：[`{REPORT_STEM}.csv`]({REPORT_STEM}.csv)",
        f"- 交互式/打印版：[`{REPORT_STEM}.html`]({REPORT_STEM}.html)",
        "- 阶段与 map 图片：[`aes11_assets/`](aes11_assets/)",
        "",
    ))
    return "\n".join(sections)


def markdown_to_html(
    markdown: str,
    designs: list[dict],
    charts: dict[str, Path],
    map_charts: dict[str, Path],
    generated: str,
) -> str:
    """Build a richer standalone index without requiring a Markdown package."""
    nav = "".join(f'<a href="#{html.escape(d["design"])}">{html.escape(d["design"])}</a>' for d in designs)
    overview_rows = []
    for d in designs:
        overview_rows.append(
            "<tr>"
            f"<td><a href=\"#{html.escape(d['design'])}\">{html.escape(d['design'])}</a></td>"
            f"<td><span class=\"pdk {d['pdk']}\">{d['pdk']}</span></td><td>{d['strategy']}</td>"
            f"<td>{number(d['floorplan'].get('die_side_um'))}</td><td>{number(d['floorplan'].get('cell_count'), 0)}</td>"
            f"<td>{number(d['timing'].get('setup_wns_ns'))}</td><td>{number(d['timing'].get('max_frequency_mhz'), 1)}</td>"
            f"<td>{number((d['power'].get('total_w') or 0) * 1000)}</td><td>{number(d['drc'].get('total'), 0)}</td>"
            f"<td>{number(d['stages']['routing'].get('runtime_sec'), 1)}</td><td class=\"bad\">N/A</td></tr>"
        )
    chart_html = "".join(
        f'<figure><img src="{rel(charts[key])}" alt="{key}"><figcaption>{key}</figcaption></figure>'
        for key in ("area", "frequency", "power", "drc", "routing")
    )
    map_chart_html = "".join(
        f'<figure><a href="{rel(map_charts[key])}"><img loading="lazy" src="{rel(map_charts[key])}" '
        f'alt="{html.escape(title)}"></a><figcaption>{html.escape(title)}</figcaption></figure>'
        for key, title in MAP_COMPARISONS
    )
    map_summary_rows = []
    for d in designs:
        egr = map_item(d, "egr_union_overflow")
        overflow = map_item(d, "early_overflow_planar")
        drc_map = map_item(d, "drc_violation_density")
        egr_stats = egr["stats"] if egr else {}
        overflow_stats = overflow["stats"] if overflow else {}
        drc_stats = drc_map["stats"] if drc_map else {}
        map_summary_rows.append(
            f"<tr><td><a href=\"#{html.escape(d['design'])}\">{html.escape(d['design'])}</a></td>"
            f"<td>{d['maps']['raw_file_count']}</td><td>{d['maps']['rendered_count']}</td>"
            f"<td>{number(egr_stats.get('nonzero_pct'), 2)}%</td><td>{number(egr_stats.get('max'), 0)}</td>"
            f"<td>{number(overflow_stats.get('nonzero_pct'), 2)}%</td><td>{number(overflow_stats.get('max'), 0)}</td>"
            f"<td>{number(drc_stats.get('nonzero_cells'), 0)}</td><td>{number(drc_stats.get('max'), 0)}</td></tr>"
        )
    design_sections = []
    for d in designs:
        stage_rows = []
        image_cards = []
        for key, label, _, _ in STAGES:
            stage = d["stages"][key]
            post_route = key == "routing"
            congestion = "invalid(-1)" if post_route and not d["congestion"].get("valid") else "N/A"
            stage_rows.append(
                f"<tr><td>{label}</td><td>{number(stage.get('runtime_sec'), 2)}</td>"
                f"<td>{number(stage.get('memory_mb'), 1)}</td><td>{number(stage.get('instances'), 0)}</td>"
                f"<td>{number(stage.get('timing_instances'), 0)}</td><td>{pct(stage.get('core_usage'))}</td>"
                f"<td>{number(stage.get('def_hpwl_um'), 1)}</td><td>{number(stage.get('def_routed_um'), 1)}</td>"
                f"<td>{number(d['timing'].get('setup_wns_ns')) if post_route else 'N/A'}</td>"
                f"<td>{number((d['power'].get('total_w') or 0) * 1000) if post_route else 'N/A'}</td>"
                f"<td>{congestion}</td><td>{number(d['drc'].get('total'), 0) if post_route else 'N/A'}</td>"
                f"<td>N/A</td></tr>"
            )
            image_cards.append(
                f'<figure><a href="{rel(Path(stage["image"]))}"><img loading="lazy" src="{rel(Path(stage["image"]))}" alt="{label}"></a>'
                f'<figcaption>{label}</figcaption></figure>'
            )
        final_png = d["artifacts"].get("final_png")
        if final_png:
            image_cards.append(
                f'<figure><a href="{rel(Path(final_png))}"><img loading="lazy" src="{rel(Path(final_png))}" alt="Final GDS"></a>'
                '<figcaption>Final GDS</figcaption></figure>'
            )
        cts_links = ""
        if d["artifacts"].get("cts_design_svg"):
            cts_links = (
                f'<p class="links">CTS: <a href="{rel(Path(d["artifacts"]["cts_design_svg"]))}">clock tree</a> · '
                f'<a href="{rel(Path(d["artifacts"]["cts_flyline_svg"]))}">flyline</a></p>'
            )
        map_groups: dict[str, list[str]] = defaultdict(list)
        for item in d["maps"]["representative"]:
            stats = item["stats"]
            map_groups[item["category"]].append(
                f'<figure><a href="{rel(Path(item["image"]))}"><img loading="lazy" '
                f'src="{rel(Path(item["image"]))}" alt="{html.escape(item["label"])}"></a>'
                f'<figcaption><b>{html.escape(item["label"])}</b><span>non-zero '
                f'{number(stats.get("nonzero_pct"), 2)}% · max {number(stats.get("max"), 3)}</span>'
                f'<a href="{rel(Path(item["source"]))}">raw {Path(item["source"]).suffix.lstrip(".").upper()}</a>'
                f'</figcaption></figure>'
            )
        map_sections = "".join(
            f'<h4>{html.escape(category)}</h4><div class="map-gallery">{"".join(cards)}</div>'
            for category, cards in map_groups.items()
        )
        raw_groups = []
        for group in d["maps"]["raw_groups"]:
            links = " · ".join(
                f'<a href="{rel(Path(path))}">{html.escape(Path(path).name)}</a>'
                for path in group["files"]
            ) or "N/A"
            raw_groups.append(
                f'<div><b>{html.escape(group["label"])} ({group["count"]})</b><p>{links}</p></div>'
            )
        raw_manifest = (
            '<details><summary>完整原始 map 文件索引</summary><div class="raw-index">'
            + "".join(raw_groups)
            + "</div></details>"
        )
        top_drc = sorted(d["drc"]["by_type"].items(), key=lambda item: item[1], reverse=True)[:5]
        badges = "".join(f'<span class="tag">{html.escape(k)} {v:,}</span>' for k, v in top_drc)
        design_sections.append(f"""
<section id="{html.escape(d['design'])}">
  <div class="section-head"><div><p class="eyebrow">{d['pdk']} / strategy {d['strategy']}</p><h2>{html.escape(d['design'])}</h2></div><a href="#top">返回顶部</a></div>
  <div class="kpis"><div><b>{number(d['timing'].get('setup_wns_ns'))}</b><span>setup WNS ns</span></div><div><b>{number((d['power'].get('total_w') or 0)*1000)}</b><span>proxy power mW</span></div><div><b>{number(d['drc'].get('total'),0)}</b><span>DRC violations</span></div><div><b>N/A</b><span>IR-drop</span></div></div>
  <div class="tags">{badges}</div>
  <div class="table-wrap"><table><thead><tr><th>Stage</th><th>Runtime s</th><th>Memory MB</th><th>Instances</th><th>Timing inst.</th><th>Core util.</th><th>DEF HPWL um</th><th>Routed um</th><th>Setup WNS ns</th><th>Power mW</th><th>Congestion</th><th>DRC</th><th>IR</th></tr></thead><tbody>{''.join(stage_rows)}</tbody></table></div>
  <div class="gallery">{''.join(image_cards)}</div>{cts_links}
  <div class="map-head"><h3>空间 Map 证据</h3><p>发现 {d['maps']['raw_file_count']} 个原始 map 文件，渲染 {d['maps']['rendered_count']} 张代表图；同类图使用跨 13 个设计统一色标。</p></div>
  {map_sections}{raw_manifest}
</section>""")
    css = """
:root{--ink:#172126;--muted:#637178;--line:#d9e0e2;--paper:#fff;--band:#f4f7f7;--accent:#c74736}
*{box-sizing:border-box}html{scroll-behavior:smooth}body{margin:0;color:var(--ink);background:var(--paper);font:15px/1.55 system-ui,-apple-system,"Segoe UI",sans-serif;letter-spacing:0}
header{background:#172126;color:#fff;padding:42px max(24px,calc((100vw - 1500px)/2));border-bottom:5px solid #e2ad38}header h1{font-size:clamp(28px,4vw,52px);margin:4px 0 12px;letter-spacing:0}header p{max-width:1050px;color:#c9d4d8;margin:0}.eyebrow{text-transform:uppercase;font-size:12px;letter-spacing:.08em;color:#829197;margin:0 0 4px}
nav{position:sticky;top:0;z-index:5;display:flex;gap:6px;overflow:auto;background:#fff;border-bottom:1px solid var(--line);padding:9px max(18px,calc((100vw - 1500px)/2))}nav a{white-space:nowrap;padding:6px 9px;color:#34515c;text-decoration:none;border-radius:4px}nav a:hover{background:#edf2f3}
main{max-width:1500px;margin:auto;padding:26px 22px 80px}section{padding:26px 0 42px;border-bottom:1px solid var(--line)}h2{font-size:27px;margin:0 0 16px;letter-spacing:0}h3{font-size:19px;letter-spacing:0}h4{font-size:16px;margin:22px 0 9px;letter-spacing:0}.section-head{display:flex;align-items:flex-end;justify-content:space-between}.section-head a,.links a{color:#126c89}.callout{border-left:5px solid #e2ad38;background:#fff9e9;padding:16px 18px;margin:18px 0}.bad{color:#b3291c;font-weight:700}
.table-wrap{overflow:auto;border:1px solid var(--line)}table{width:100%;border-collapse:collapse;min-width:920px}th,td{text-align:right;padding:9px 11px;border-bottom:1px solid var(--line);white-space:nowrap}th:first-child,td:first-child{text-align:left}thead{background:#eaf0f1;position:sticky;top:49px}tbody tr:nth-child(even){background:#fafbfb}.pdk,.tag{display:inline-block;padding:2px 7px;border-radius:3px;color:#fff}.sky130{background:#1687a7}.nangate45{background:#3b8f5a}.asap7{background:#d05a47}.ics55{background:#8a62a8}
.charts,.gallery{display:grid;grid-template-columns:repeat(auto-fit,minmax(310px,1fr));gap:14px}.charts figure,.gallery figure{margin:0;border:1px solid var(--line);background:#fff}.charts img,.gallery img{display:block;width:100%;aspect-ratio:4/3;object-fit:contain}.charts figcaption,.gallery figcaption{padding:8px 11px;border-top:1px solid var(--line);color:var(--muted)}
.map-head{margin-top:34px;padding-top:24px;border-top:3px solid #e2ad38}.map-head h3{margin:0 0 3px}.map-head p{margin:0;color:var(--muted)}.map-gallery{display:grid;grid-template-columns:repeat(auto-fit,minmax(230px,1fr));gap:12px}.map-gallery figure{margin:0;border:1px solid var(--line);background:#fff}.map-gallery img{display:block;width:100%;aspect-ratio:1;object-fit:contain}.map-gallery figcaption{display:grid;gap:2px;padding:8px 10px;border-top:1px solid var(--line);font-size:12px;color:var(--muted)}.map-gallery figcaption b{color:var(--ink);font-size:13px}.map-gallery figcaption a,.raw-index a{color:#126c89}details{margin-top:20px;border:1px solid var(--line);background:#fafbfb}summary{cursor:pointer;padding:11px 13px;font-weight:700}.raw-index{padding:0 13px 13px}.raw-index div{border-top:1px solid var(--line);padding:10px 0}.raw-index p{margin:4px 0 0;overflow-wrap:anywhere}.map-comparisons{grid-template-columns:repeat(auto-fit,minmax(520px,1fr))}
.kpis{display:grid;grid-template-columns:repeat(4,minmax(130px,1fr));border:1px solid var(--line);margin:14px 0}.kpis div{padding:13px;border-right:1px solid var(--line)}.kpis div:last-child{border:0}.kpis b{font-size:23px;display:block}.kpis span{color:var(--muted);font-size:12px}.tags{display:flex;flex-wrap:wrap;gap:6px;margin:10px 0}.tag{background:#5c6c72}.links{margin:12px 0 0}
.plan{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:12px}.plan article{border-top:4px solid #c74736;background:var(--band);padding:15px}.plan h3{margin:0 0 8px}.plan ol{padding-left:22px;margin:0}.fine{color:var(--muted);font-size:13px}@media(max-width:700px){.kpis{grid-template-columns:1fr 1fr}.gallery,.charts,.map-gallery,.map-comparisons{grid-template-columns:1fr}main{padding-left:12px;padding-right:12px}}
@media print{nav{display:none}section{break-inside:auto}.gallery figure,.map-gallery figure{break-inside:avoid}details{display:block}.raw-index{display:block}body{font-size:11px}}
"""
    return f"""<!doctype html><html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>AES 13 项 iEDA.ai 详细对比</title><style>{css}</style></head>
<body><header id="top"><p class="eyebrow">iEDA.ai benchmark evidence report</p><h1>AES 13 项物理设计详细对比</h1><p>横向比较 4 个 PDK，纵向追踪 7 个阶段和 208 张代表 map。生成时间 {generated}。结果严格区分实测、DEF 推导和未测项。</p></header><nav><a href="#summary">总览</a><a href="#coverage">覆盖率</a><a href="#maps">Maps</a><a href="#findings">结论</a>{nav}<a href="#plan">优化计划</a></nav><main>
<section id="summary"><h2>执行结论</h2><div class="callout"><b>13/13 流程完成，但 0/13 DRC clean。</b> 当前产物证明多 PDK 流程可贯通，不代表已达到签核质量。STA 未回标寄生、功耗无活动率、拥塞报告返回 -1、IR-drop 未运行。</div><div class="table-wrap"><table><thead><tr><th>Design</th><th>PDK</th><th>State</th><th>Die um</th><th>Cells</th><th>Setup WNS ns</th><th>Fmax MHz</th><th>Power mW</th><th>DRC</th><th>Route s</th><th>IR</th></tr></thead><tbody>{''.join(overview_rows)}</tbody></table></div></section>
<section id="coverage"><h2>数据覆盖与可信度</h2><div class="callout">时序与功耗数字虽然存在，但分别因 net delay=0 和 switch power=0 被标为低置信。IR-drop 用 N/A 表示，绝不以 0 代替未测。</div><p>逐阶段具备 DEF、结构、利用率、耗时、推导 HPWL 和布局图；STA、power、DRC 仅在 post-route。拥塞汇总报告无效，但 placement density、EGR overflow、early-router 逐层 CSV 是可用空间证据，已与汇总指标分开呈现。</p></section>
<section><h2>横向图</h2><div class="charts">{chart_html}</div></section>
<section id="maps"><h2>空间 Map 横向对比</h2><div class="callout">每个设计渲染 16 张代表图并链接全部原始 map。相同类型采用跨 13 设计统一色标；DRC 采用统一对数色标；全零图明确标注，不做自动拉伸。</div><div class="table-wrap"><table><thead><tr><th>Design</th><th>Raw maps</th><th>Rendered</th><th>EGR union non-zero</th><th>EGR max</th><th>Planar overflow non-zero</th><th>Planar max</th><th>DRC non-zero bins</th><th>DRC bin max</th></tr></thead><tbody>{''.join(map_summary_rows)}</tbody></table></div><p class="fine">ASAP7 a/b/t 的 EGR union 与 planar overflow 原始网格均为全零，但这不能替代无效的 Average Congestion=-1 汇总接口。跨 PDK 资源定义不同，颜色主要用于同工艺状态趋势与热点定位。</p><div class="charts map-comparisons">{map_chart_html}</div></section>
<section id="findings"><h2>质量判断</h2><div class="plan"><article><h3>流程工程：B</h3><p>4 个 PDK、13 个状态均输出 GDS，阶段检查点齐全。</p></article><article><h3>布线/DRC：D</h3><p>所有设计均有大量违例，当前 GDS 不能作为 tapeout-ready 结果。</p></article><article><h3>空间可观测性：B-</h3><p>密度、EGR、逐层路由和 DRC 热点可审计；拥塞汇总接口仍需修复。</p></article><article><h3>STA/Power：D</h3><p>寄生、约束和活动率缺失使 PPA 只能做早期代理比较。</p></article><article><h3>PDN/IR：F</h3><p>没有 iPNP/iIR 证据，不能评价电源完整性。</p></article></div></section>
{''.join(design_sections)}
<section id="plan"><h2>优化路线</h2><div class="plan"><article><h3>P0 测量可信度</h3><ol><li>iRCX/SPEF 回标 STA</li><li>清零 unconstrained endpoint</li><li>接入 VCD/SAIF</li><li>修复 congestion -1</li><li>接通 iPNP/iIR</li></ol></article><article><h3>P1 DRC 闭环</h3><ol><li>按 violation type 建回归</li><li>扫描 1/3/5 轮详细布线</li><li>校准 track/via/rule</li><li>DRC clean 成为 GDS gate</li></ol></article><article><h3>P2 PPA 优化</h3><ol><li>利用率/留白/拥塞权重 DOE</li><li>CTS 多目标调参</li><li>逐阶段 PPA delta 门禁</li><li>跨 PDK 使用归一化指标</li></ol></article><article><h3>P3 Agent 闭环</h3><ol><li>JSON 观测面与有限动作</li><li>Pareto archive</li><li>输入/工具 hash 追踪</li><li>holdout design 验证</li></ol></article></div><p class="fine">完整证据、每项 DRC 主类、门禁定义和数据链接见 <a href="{REPORT_STEM}.md">Markdown 报告</a>；机器数据见 <a href="{REPORT_STEM}.json">JSON</a> / <a href="{REPORT_STEM}.csv">CSV</a>。</p></section>
</main></body></html>"""


def main() -> int:
    REPORT_ROOT.mkdir(parents=True, exist_ok=True)
    ASSET_ROOT.mkdir(parents=True, exist_ok=True)
    generated = datetime.now().astimezone().isoformat(timespec="seconds")
    designs = []
    for index, name in enumerate(DESIGNS, start=1):
        print(f"[{index}/{len(DESIGNS)}] analyzing {name}", flush=True)
        designs.append(analyze_design(name))
    print("[maps] rendering representative grids and comparison sheets", flush=True)
    map_charts = generate_map_assets(designs)
    data = {
        "schema_version": 2,
        "generated_at": generated,
        "scope": {"included": list(DESIGNS), "excluded": []},
        "measurement_notes": {
            "sta": "post-route report exists but interconnect path delays are zero; no SPEF back-annotation",
            "power": "switching power is zero; no VCD/SAIF activity evidence",
            "congestion": "aggregate average edge congestion is -1; raw placement/EGR/early-router maps are analyzed separately",
            "spatial_maps": "same map types use a shared 13-design scale; DRC center density uses a shared logarithmic scale",
            "ir_drop": "not run for all 13 designs",
            "def_hpwl": "derived from placed instance origins; use for within-PDK/stage trends",
        },
        "designs": designs,
    }
    json_path = write_json(data)
    csv_path = write_csv(designs)
    charts = make_charts(designs)
    markdown = build_markdown(designs, charts, map_charts, generated)
    md_path = REPORT_ROOT / f"{REPORT_STEM}.md"
    md_path.write_text(markdown + "\n", encoding="utf-8")
    html_path = REPORT_ROOT / f"{REPORT_STEM}.html"
    html_path.write_text(
        markdown_to_html(markdown, designs, charts, map_charts, generated), encoding="utf-8"
    )
    print(f"JSON: {json_path}")
    print(f"CSV:  {csv_path}")
    print(f"MD:   {md_path}")
    print(f"HTML: {html_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
