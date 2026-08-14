#!/usr/bin/env python3
"""Convert Innovus 2000-units DEFs (pl_vis cases) to iEDA-compatible
placement-only DEFs in 1000-units: keep header/DIEAREA/ROW/COMPONENTS/PINS,
halve only COORDINATES, drop NETS/SPECIALNETS/VIAS/TRACKS routing sections.

Usage: python3 def2placement_1000.py <in.def> <out.def>
"""
import re
import sys

NUM = re.compile(r"(?<![A-Za-z0-9_])-?\d+(?![A-Za-z0-9_])")

def scale_all(line):
    return NUM.sub(lambda m: str(int(int(m.group(0)) / 2)), line)

def scale_tracks(line):
    # "TRACKS X 240 DO 286 STEP 480 LAYER li1 ;"
    parts = line.split()
    out = []
    i = 0
    while i < len(parts):
        tok = parts[i]
        if tok == "TRACKS":
            out.append(tok); i += 1
            out.append(parts[i]); i += 1  # X/Y
            out.append(str(int(int(parts[i]) / 2))); i += 1  # start
        elif tok == "STEP":
            out.append(tok); i += 1
            out.append(str(int(int(parts[i]) / 2))); i += 1  # step
        else:
            out.append(tok); i += 1
    return " ".join(out)

def scale_row(line):
    # "ROW ROW_0 unithd 0 0 FS DO 172 BY 1 STEP 920 0 ;"
    # scale origin x/y (tokens 2,3) and the STEP pair; keep DO/BY counts.
    parts = line.split()
    out = []
    i = 0
    while i < len(parts):
        tok = parts[i]
        if tok == "ROW":
            out.append(tok); i += 1
            out.append(parts[i]); i += 1  # name
            out.append(parts[i]); i += 1  # site
            out.append(str(int(int(parts[i]) / 2))); i += 1  # origin x
            out.append(str(int(int(parts[i]) / 2))); i += 1  # origin y
        elif tok == "STEP":
            out.append(tok); i += 1
            out.append(str(int(int(parts[i]) / 2))); i += 1  # step x
            out.append(str(int(int(parts[i]) / 2))); i += 1  # step y
        else:
            out.append(tok); i += 1
    return " ".join(out)

def main():
    in_path, out_path = sys.argv[1], sys.argv[2]
    with open(in_path) as f:
        lines = f.readlines()

    out = []
    section = None  # 'components' | 'pins' | 'nets' | 'drop'
    drop_kws = ("SLOTS", "FILLS", "NONDEFAULTRULES", "SCANCHAINS", "GROUPS", "IOTIMINGS")

    for raw in lines:
        line = raw.rstrip("\n")
        s = line.strip()
        u = s.upper()

        if s == "END COMPONENTS" or s == "END PINS":
            section = None
            out.append(line + "\n")
            continue
        if s == "END NETS" or s == "END SPECIALNETS" or s == "END VIAS" or s == "END BLOCKAGES" or s == "END REGIONS":
            section = None
            out.append(line + "\n")
            continue
        if section == "components":
            out.append(line + "\n")  # entries carry no coordinates
            continue
        if section in ("pins", "nets", "vias", "blockages", "regions"):
            out.append(scale_all(line) + "\n")  # LAYER/PLACED/ROUTED/RECT coords
            continue
        if section == "drop":
            if s.startswith("END"):
                section = None
            continue

        if u.startswith("COMPONENTS"):
            section = "components"
            out.append(line + "\n")  # keep the count
            continue
        if u.startswith("PINS"):
            section = "pins"
            out.append(line + "\n")  # keep the count
            continue
        if u.startswith("NETS"):
            section = "nets"
            out.append(line + "\n")  # keep the count
            continue
        if u.startswith("SPECIALNETS"):
            section = "nets"
            out.append(line + "\n")  # keep the count
            continue
        if u.startswith("VIAS"):
            section = "vias"
            out.append(line + "\n")  # keep the count
            continue
        if u.startswith("BLOCKAGES"):
            section = "blockages"
            out.append(line + "\n")  # keep the count
            continue
        if u.startswith("REGIONS"):
            section = "regions"
            out.append(line + "\n")  # keep the count
            continue
        if u.startswith("UNITS"):
            out.append("UNITS DISTANCE MICRONS 1000 ;\n")
            continue
        if u.startswith("GCELLGRID"):
            continue  # single-line, no END terminator
        if any(u.startswith(kw) for kw in drop_kws):
            section = "drop"
            continue
        if u.startswith("DIEAREA"):
            out.append(scale_all(line) + "\n")
            continue
        if u.startswith("ROW "):
            out.append(scale_row(line) + "\n")
            continue
        if u.startswith("TRACKS"):
            out.append(scale_tracks(line) + "\n")
            continue
        if s == "END DESIGN":
            out.append("END DESIGN\n")
            continue
        out.append(line + "\n")

    with open(out_path, "w") as f:
        f.writelines(out)
    print(f"converted {in_path} -> {out_path}")

if __name__ == "__main__":
    main()
