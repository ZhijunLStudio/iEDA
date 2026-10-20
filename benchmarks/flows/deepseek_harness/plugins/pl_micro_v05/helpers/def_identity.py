#!/usr/bin/env python3
"""Compare placement inputs without relying on directory/design labels."""
from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path
from def_hpwl_eval import parse_ports


def digest(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True, separators=(",", ":")).encode()).hexdigest()


def name(token):
    # DEF backslash escapes punctuation; it is not part of the object name.
    return re.sub(r"\\(.)", r"\1", token)


def identity(path):
    text = Path(path).read_text(errors="ignore")
    top = re.search(r"\bDESIGN\s+(\S+)\s*;", text)
    units = re.search(r"UNITS\s+DISTANCE\s+MICRONS\s+(\d+)", text)
    components = re.search(r"\bCOMPONENTS\s+\d+\s*;(.*?)\bEND\s+COMPONENTS", text, re.S)
    nets_section = re.search(r"(?:^|\n)\s*NETS\s+\d+\s*;(.*?)\bEND\s+NETS", text, re.S)
    if not top or not units or not components or not nets_section:
        raise ValueError("DEF missing design, units, components or nets")
    masters = {name(m.group(1)): name(m.group(2))
               for m in re.finditer(r"(?:^|\n)\s*-\s+(\S+)\s+(\S+)", components.group(1))}
    nets = []
    connected = set()
    for m in re.finditer(r"(?:^|\n)\s*-\s+(\S+)\s+(.*?);", nets_section.group(1), re.S):
        connections = m.group(2).split("+", 1)[0]
        endpoints = sorted((name(a), name(p))
                           for a, p in re.findall(r"\(\s*([^\s()]+)\s+([^\s()]+)\s*\)", connections))
        connected.update(a for a, _ in endpoints if a != "PIN")
        nets.append((name(m.group(1)), endpoints))
    row_specs = sorted(tuple(m.group(0).split()[2:]) for m in re.finditer(r"\bROW\s+[^;]+;", text))
    die = re.search(r"\bDIEAREA\s+([^;]+);", text)
    fixed_ports = sorted(parse_ports(text).items())
    connected_masters = sorted((a, masters.get(a)) for a in connected)
    return {"top": top.group(1), "units": int(units.group(1)), "components": len(masters),
            "connected_components": len(connected), "nets": len(nets),
            "netlist_sha256": digest([connected_masters, sorted(nets)]),
            "connectivity_sha256": digest([connected_masters, sorted(endpoints for _, endpoints in nets if endpoints)]),
            "floorplan_sha256": digest([int(units.group(1)), die.group(1).split() if die else None,
                                         row_specs, sorted(fixed_ports)]),
            "def_sha256": hashlib.sha256(Path(path).read_bytes()).hexdigest()}


def compare(a, b):
    left, right = identity(a), identity(b)
    return {"same_netlist": left["connectivity_sha256"] == right["connectivity_sha256"],
            "same_named_netlist": left["netlist_sha256"] == right["netlist_sha256"],
            "netlist_comparison": "identical connected masters and pin partitions; net aliases and empty nets may differ",
            "same_floorplan": left["floorplan_sha256"] == right["floorplan_sha256"],
            "left": left, "right": right}


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("left")
    ap.add_argument("right")
    args = ap.parse_args()
    result = compare(args.left, args.right)
    print(json.dumps(result, indent=2))
    raise SystemExit(0 if result["same_netlist"] and result["same_floorplan"] else 1)
