#!/usr/bin/env python3
"""Overlay component placements from an Innovus defOut onto an input DEF that
still contains the logical netlist, producing a valid DEF for evaluation."""
from __future__ import annotations
import argparse, re
from pathlib import Path

def placements(path):
    text = Path(path).read_text(errors="ignore")
    comp_start = re.search(r"\nCOMPONENTS\s", text)
    comp_end = text.find("END COMPONENTS")
    if not comp_start or comp_end < 0:
        return {}
    sec = text[comp_start.start() + 1 : comp_end]
    result = {}
    cur = None
    for line in sec.splitlines():
        m = re.match(r"\s*-+\s+(\S+)\s+(\S+)", line)
        if m:
            if cur: result.update(cur)
            cur = {m.group(1): {"type": m.group(2), "rest": [line]}}
        elif cur:
            for name in list(cur):
                cur[name]["rest"].append(line)
    if cur: result.update(cur)
    out = {}
    for name, info in result.items():
        joined = " ".join(info["rest"])
        mp = re.search(r"(?:PLACED|FIXED)\s*\(\s*([-\d]+)\s+([-\d]+)\s*\)\s*([A-Z]+)", joined)
        if mp: out[name] = (mp.group(1), mp.group(2), mp.group(3))
    return out

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("input_def")
    ap.add_argument("placed_def")
    ap.add_argument("out_def")
    ap.add_argument("--fallback-def")
    args = ap.parse_args()
    text = Path(args.input_def).read_text(errors="ignore")
    placed = placements(args.placed_def)
    fallback = placements(args.fallback_def) if args.fallback_def else {}
    comp_start = text.find("COMPONENTS")
    comp_end = text.find("END COMPONENTS")
    if comp_start < 0 or comp_end < 0:
        raise SystemExit("input DEF has no COMPONENTS section")
    section = text[comp_start:comp_end]
    blocks = []
    cur = None
    for line in section.splitlines():
        m = re.match(r"\s*-+\s+(\S+)\s+(\S+)", line)
        if m:
            if cur: blocks.append(cur)
            cur = [line]
        elif cur is not None:
            cur.append(line)
    if cur: blocks.append(cur)
    new_section = ["COMPONENTS"]
    mapped = 0
    for block in blocks:
        joined = " ".join(block)
        mn = re.match(r"\s*-+\s+(\S+)\s+(\S+)", joined)
        if mn and mn.group(1) in placed:
            x, y, o = placed[mn.group(1)]
            new_section.append(f"    - {mn.group(1)} {mn.group(2)} + PLACED ( {x} {y} ) {o} ;")
            mapped += 1
        elif mn and mn.group(1) in fallback:
            x, y, o = fallback[mn.group(1)]
            new_section.append(f"    - {mn.group(1)} {mn.group(2)} + PLACED ( {x} {y} ) {o} ;")
        else:
            joined = joined.strip()
            if not joined.endswith(";"):
                joined += " ;"
            new_section.append(joined)
    text = text[:comp_start] + "\n".join(new_section) + "\n" + text[comp_end:]
    Path(args.out_def).write_text(text)
    print(f"overlay wrote {args.out_def}: mapped {mapped} components")

if __name__ == "__main__":
    main()
