#!/usr/bin/env python3
"""Common HPWL evaluator for two placement-only DEFs.

Reads cell LEF pin offsets and computes the same half-perimeter wirelength for
any DEF whose NETS section matches the compared designs. This intentionally
does NOT run EGR, so unlegalized GP placements are evaluated safely.

Usage:
    python3 def_hpwl_eval.py <cell.lef> <placed.def>
Prints:
    HPWL=<dbu> NETS=<n> SKIPPED=<n> DEF_UNITS=<n>
"""
import re
import sys
from pathlib import Path


def parse_lef(path):
    macros = {}
    units = 1000
    macro = None
    pin = None
    text = Path(path).read_text(errors="ignore")
    for raw in text.splitlines():
        line = raw.strip()
        u = line.upper()
        if u.startswith("UNITS DISTANCE MICRONS"):
            m = re.search(r"UNITS\s+DISTANCE\s+MICRONS\s+(\d+)", u)
            if m:
                units = int(m.group(1))
        if u.startswith("MACRO ") and "CLASS" not in u:
            macro = line.split()[1]
            macros[macro] = {"size": (0.0, 0.0), "pins": {}}
        elif macro and u.startswith("SIZE"):
            m = re.search(r"SIZE\s+([\d.]+)\s+BY\s+([\d.]+)", u)
            if m:
                macros[macro]["size"] = (float(m.group(1)), float(m.group(2)))
        elif macro and u.startswith("PIN "):
            pin = line.split()[1]
            macros[macro]["pins"][pin] = []
        elif macro and pin and u.startswith("END " + pin.upper()):
            pin = None
        elif macro and pin and u.startswith("RECT"):
            parts = line.split()
            if len(parts) >= 5:
                macros[macro]["pins"][pin].append([float(x) for x in parts[1:5]])
        elif macro and u.startswith("END MACRO"):
            macro = None
            pin = None

    for data in macros.values():
        for pin_name, rects in data["pins"].items():
            if rects:
                xs = [(r[0] + r[2]) / 2.0 for r in rects]
                ys = [(r[1] + r[3]) / 2.0 for r in rects]
                data["pins"][pin_name] = (sum(xs) / len(xs), sum(ys) / len(ys))
            else:
                data["pins"][pin_name] = (data["size"][0] / 2.0, data["size"][1] / 2.0)
    return macros, units


def transform_pin(px, py, w, h, orient):
    o = orient.upper()
    transforms = {
        "N": (px, py), "S": (w - px, h - py),
        "FN": (w - px, py), "FS": (px, h - py),
        "W": (h - py, px), "E": (py, w - px),
        "FW": (h - py, w - px), "FE": (py, px),
    }
    if o not in transforms:
        raise ValueError("unsupported DEF orientation: " + orient)
    return transforms[o]


def split_def_blocks(section_text):
    blocks = []
    cur = None
    for line in section_text.splitlines():
        if re.match(r"\s*-+\s+", line):
            if cur is not None:
                blocks.append(cur)
            cur = [line]
        elif cur is not None:
            cur.append(line)
    if cur is not None:
        blocks.append(cur)
    return blocks


def def_name(token):
    return re.sub(r"\\(.)", r"\1", token)


def parse_ports(text):
    """Physical IO pin centers in DEF DBU (shape offset and orientation included)."""
    section = re.search(r"(?:^|\n)\s*PINS\s+\d+\s*;(.*?)\bEND\s+PINS", text, re.S)
    ports = {}
    if not section:
        return ports
    for block in split_def_blocks(section.group(1)):
        joined = " ".join(block)
        name = re.match(r"\s*-\s+(\S+)", joined)
        placements = re.findall(r"(?:PLACED|FIXED|COVER)\s*\(\s*(-?\d+)\s+(-?\d+)\s*\)\s*([A-Z]+)", joined)
        if not name or len(placements) != 1:
            continue
        rectangles = re.findall(r"\bLAYER\s+\S+(?:\s+MASK\s+\d+)?\s*\(\s*(-?\d+)\s+(-?\d+)\s*\)\s*\(\s*(-?\d+)\s+(-?\d+)\s*\)", joined)
        # No rectangle means there is no measurable physical pin location.
        if not rectangles:
            continue
        px = sum((int(a) + int(c)) / 2 for a, b, c, d in rectangles) / len(rectangles)
        py = sum((int(b) + int(d)) / 2 for a, b, c, d in rectangles) / len(rectangles)
        x, y, orient = placements[0]
        rotations = {"N": (px, py), "W": (-py, px), "S": (-px, -py), "E": (py, -px),
                     "FN": (-px, py), "FS": (px, -py), "FW": (-py, -px), "FE": (py, px)}
        dx, dy = rotations[orient]
        ports[def_name(name.group(1))] = (int(x) + dx, int(y) + dy)
    return ports


def parse_def(path, macros):
    text = Path(path).read_text(errors="ignore")
    m = re.search(r"UNITS\s+DISTANCE\s+MICRONS\s+(\d+)", text, re.I)
    def_units = int(m.group(1)) if m else 1000

    # Components
    comp = {}
    section = text[text.find("COMPONENTS") : text.find("END COMPONENTS")]
    for block in split_def_blocks(section):
        joined = " ".join(block)
        mn = re.match(r"\s*-+\s+(\S+)\s+(\S+)", joined)
        if not mn:
            continue
        name = def_name(mn.group(1))
        macro = def_name(mn.group(2))
        mp = re.search(r"(?:PLACED|FIXED|COVER)\s*\(\s*([-\d]+)\s+([-\d]+)\s*\)\s*([A-Z]+)", joined)
        if mp:
            comp[name] = (macro, int(mp.group(1)), int(mp.group(2)), mp.group(3))

    # Ports
    pins = parse_ports(text)

    # NETS: keep only connectivity lines, strip routed geometry.
    nets_start = re.search(r"\nNETS\s", text)
    nets_end = text.find("END NETS")
    section = text[nets_start.end() - len("NETS") - 1 : nets_end] if nets_start and nets_end > nets_start.end() else text[text.find("\nNETS ") : nets_end]
    cleaned = []
    for line in section.splitlines():
        s = line.strip()
        u = s.upper()
        if u.startswith("ROUTED") or u.startswith("+ ROUTED"):
            continue
        if u.startswith("NEW") or re.match(r"^[A-Z]+\d*\s+", s):
            continue
        if s.startswith("-") or s.startswith("(") or s.startswith("+ USE") or s.startswith("+ WEIGHT") or s.startswith("+ SOURCE"):
            cleaned.append(line)

    nets = []
    cur = None
    for line in cleaned:
        s = line.strip()
        if s.startswith("-"):
            if cur is not None:
                nets.append(cur)
            cur = [s]
        elif cur is not None:
            cur.append(s)
    if cur is not None:
        nets.append(cur)

    def inst_abs(inst_name, pin_name):
        inst_name, pin_name = def_name(inst_name), def_name(pin_name)
        if inst_name not in comp:
            return None
        macro, x, y, o = comp[inst_name]
        if macro not in macros:
            return None
        w, h = macros[macro]["size"]
        if pin_name not in macros[macro]["pins"]:
            return None
        px, py = macros[macro]["pins"][pin_name]
        qx, qy = transform_pin(px, py, w, h, o)
        return (x + qx * def_units, y + qy * def_units)

    hpwl = 0.0
    net_count = 0
    skipped = 0
    for net in nets:
        points = []
        endpoints = re.findall(r"\(\s*([^\s()]+)\s+([^\s()]+)\s*\)", " ".join(net))
        missing = False
        for inst, pin in endpoints:
            inst, pin = def_name(inst), def_name(pin)
            if inst == "PIN":
                if pin in pins:
                    x, y = pins[pin]
                    points.append((x, y))
                else:
                    missing = True
            else:
                p = inst_abs(inst, pin)
                if p is not None:
                    points.append(p)
                else:
                    missing = True
        if len(endpoints) >= 2 and missing:
            skipped += 1
            continue
        if len(points) >= 2:
            xs = [p[0] for p in points]
            ys = [p[1] for p in points]
            hpwl += (max(xs) - min(xs)) + (max(ys) - min(ys))
            net_count += 1
    return int(round(hpwl)), net_count, skipped, def_units


def main():
    if len(sys.argv) != 3:
        print(__doc__)
        return 2
    macros, _ = parse_lef(sys.argv[1])
    hpwl, net_count, skipped, def_units = parse_def(sys.argv[2], macros)
    print(f"HPWL={hpwl} NETS={net_count} SKIPPED={skipped} DEF_UNITS={def_units}")
    return 0 if skipped == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())
