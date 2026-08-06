#!/usr/bin/env python3
"""Generate synthetic iRCX ITF/captab files from tech LEF routing layers."""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass
from pathlib import Path


@dataclass
class RoutingLayer:
    name: str
    width: float = 0.1
    spacing: float = 0.1
    rpsq: float = 0.25
    cpersqdist: float = 2.0e-5
    edgecap: float = 2.0e-5


@dataclass
class ViaLayer:
    name: str
    resistance: float = 5.0


def parse_tech_lef(path: Path, wanted_layers: set[str]) -> tuple[list[RoutingLayer], list[ViaLayer]]:
    routing: list[RoutingLayer] = []
    vias: list[ViaLayer] = []
    current_name: str | None = None
    current: dict[str, float | bool] = {}
    for raw in path.read_text(encoding="utf-8", errors="replace").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("LAYER "):
            current_name = line.split()[1]
            current = {"routing": False}
            continue
        if current_name is None:
            continue
        if line == f"END {current_name}":
            if current_name in wanted_layers:
                if current.get("routing"):
                    routing.append(
                        RoutingLayer(
                            name=current_name,
                            width=float(current.get("width", 0.1)),
                            spacing=float(current.get("spacing", 0.1)),
                            rpsq=float(current.get("rpsq", 0.25)),
                            cpersqdist=float(current.get("cpersqdist", 2.0e-5)),
                            edgecap=float(current.get("edgecap", 2.0e-5)),
                        )
                    )
                else:
                    vias.append(ViaLayer(name=current_name, resistance=float(current.get("resistance", 5.0))))
            current_name = None
            current = {}
            continue
        if "TYPE ROUTING" in line:
            current["routing"] = True
        if match := re.match(r"WIDTH\s+([-+0-9.eE]+)\s*;", line):
            current["width"] = float(match.group(1))
        if match := re.match(r"SPACING\s+([-+0-9.eE]+)\s*;", line):
            current["spacing"] = float(match.group(1))
        if match := re.match(r"RESISTANCE\s+RPERSQ\s+([-+0-9.eE]+)\s*;", line):
            current["rpsq"] = float(match.group(1))
        elif match := re.match(r"RESISTANCE\s+([-+0-9.eE]+)\s*;", line):
            current["resistance"] = float(match.group(1))
        if match := re.match(r"CAPACITANCE\s+CPERSQDIST\s+([-+0-9.eE]+)\s*;", line):
            current["cpersqdist"] = float(match.group(1))
        if match := re.match(r"EDGECAPACITANCE\s+([-+0-9.eE]+)\s*;", line):
            current["edgecap"] = float(match.group(1))
    return routing, vias


def read_mapping_layers(path: Path) -> set[str]:
    layers: set[str] = set()
    for raw in path.read_text(encoding="utf-8", errors="replace").splitlines():
        stripped = raw.strip()
        if not stripped or stripped.startswith("#"):
            continue
        parts = stripped.split()
        if len(parts) >= 2:
            layers.add(parts[1])
    return layers


def write_itf(path: Path, routing: list[RoutingLayer], vias: list[ViaLayer]) -> None:
    lines = [
        "$ Synthetic RCX model generated for iEDA smoke validation; not foundry signoff data.",
        "TECHNOLOGY = synthetic_iEDA",
        "GLOBAL_TEMPERATURE = 25",
        "BACKGROUND_ER = 3.9",
        "HALF_NODE_SCALE_FACTOR = 1.0",
        "USE_SI_DENSITY = NO",
        "",
        "DIELECTRIC substrate {",
        "  ER = 3.9",
        "  THICKNESS = 0.2",
        "  MEASURED_FROM = TOP_OF_CHIP",
        "}",
    ]
    height = 0.2
    for layer in routing:
        diel = f"diel_{layer.name}"
        lines.extend(
            [
                "",
                f"DIELECTRIC {diel} {{",
                "  ER = 3.9",
                "  THICKNESS = 0.2",
                f"  MEASURED_FROM = {layer.name}",
                f"  ASSOCIATED_CONDUCTOR = {layer.name}",
                "}",
                "",
                f"CONDUCTOR {layer.name} {{",
                f"  WMIN = {layer.width:g}",
                f"  SMIN = {layer.spacing:g}",
                "  THICKNESS = 0.14",
                f"  T0 = {height:g}",
                f"  RPSQ = {layer.rpsq:g}",
                "  CRT1 = 0.0039",
                "  CRT2 = 0.0",
                "}",
            ]
        )
        height += 0.2
    routing_names = [layer.name for layer in routing]
    for via in vias:
        idx_match = re.search(r"(\d+)$", via.name)
        idx = int(idx_match.group(1)) if idx_match else 1
        if idx - 1 < 0 or idx >= len(routing_names):
            continue
        lines.extend(
            [
                "",
                f"VIA {via.name} {{",
                f"  FROM = {routing_names[idx - 1]}",
                f"  TO = {routing_names[idx]}",
                f"  RPV = {via.resistance:g}",
                "  AREA = 0.01",
                "  CRT1 = 0.0039",
                "  CRT2 = 0.0",
                "}",
            ]
        )
    lines.append("")
    path.write_text("\n".join(lines), encoding="ascii")


def write_captab(path: Path, routing: list[RoutingLayer]) -> None:
    lines = ["# Synthetic RCX capacitance table; values derived from tech LEF order of magnitude."]
    for idx, layer in enumerate(routing):
        ground_base = max(layer.cpersqdist * max(layer.width, 0.01) * 1000.0, 0.001)
        coupling_base = max(layer.edgecap * 1000.0, 0.001)
        distances = [max(layer.spacing, 0.02), max(layer.spacing * 2.0, 0.04), max(layer.spacing * 4.0, 0.08)]
        below_contexts = ["SUBSTRATE"] + [lower.name for lower in routing[:idx]]
        above_contexts = [upper.name for upper in routing[idx + 1 :]]
        for below_idx, below in enumerate(below_contexts):
            distance_scale = 1.0 + 0.15 * below_idx
            lines.extend(["", f"A {layer.name} OVER {below}"])
            for distance in distances:
                lines.append(
                    f"{distance:.6g} "
                    f"{coupling_base / ((1.0 + distance) * distance_scale):.6g} "
                    f"{ground_base * (1.0 + distance) * distance_scale:.6g}"
                )
            for above_idx, above in enumerate(above_contexts):
                shield_scale = 1.0 + 0.10 * above_idx
                lines.extend(["", f"B {layer.name} OVER {below} UNDER {above}"])
                for distance in distances:
                    lines.append(
                        f"{distance:.6g} "
                        f"{0.8 * coupling_base / ((1.0 + distance) * distance_scale * shield_scale):.6g} "
                        f"{1.2 * ground_base * (1.0 + distance) * distance_scale * shield_scale:.6g}"
                    )
    lines.append("")
    path.write_text("\n".join(lines), encoding="ascii")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--pdk", default="nangate45")
    parser.add_argument("--tech-lef", type=Path, required=True)
    parser.add_argument("--mapping", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    args = parser.parse_args()

    wanted = read_mapping_layers(args.mapping)
    routing, vias = parse_tech_lef(args.tech_lef, wanted)
    if not routing:
        raise RuntimeError(f"no routing layers found in {args.tech_lef}")
    args.output_dir.mkdir(parents=True, exist_ok=True)
    itf = args.output_dir / f"{args.pdk}.itf"
    captab = args.output_dir / f"{args.pdk}.captab"
    write_itf(itf, routing, vias)
    write_captab(captab, routing)
    manifest = {
        "schema": "synthetic-rcx/v1",
        "trusted": False,
        "pdk": args.pdk,
        "tech_lef": str(args.tech_lef),
        "mapping": str(args.mapping),
        "itf": str(itf),
        "captab": str(captab),
        "routing_layers": [layer.__dict__ for layer in routing],
        "via_layers": [layer.__dict__ for layer in vias],
        "note": "Synthetic ITF/captab for iEDA extraction smoke only; not foundry signoff data.",
    }
    (args.output_dir / f"{args.pdk}_synthetic_rcx_manifest.json").write_text(
        json.dumps(manifest, indent=2) + "\n", encoding="utf-8"
    )
    print(itf)
    print(captab)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
