#!/usr/bin/env python3
"""Generate a structural Verilog netlist from a placed DEF (components + nets)."""
from __future__ import annotations
import argparse, re, sys
from collections import defaultdict
from pathlib import Path

def parse_def(path):
    text = Path(path).read_text(errors="ignore")
    design = re.search(r"DESIGN\s+(\S+)", text).group(1)
    comps = {}
    sec = text[text.find("COMPONENTS") : text.find("END COMPONENTS")]
    for line in sec.splitlines():
        m = re.match(r"\s*-\s+(\S+)\s+(\S+)", line)
        if m: comps[m.group(1)] = m.group(2)
    ports = []
    sec = text[text.find("PINS") : text.find("END PINS")]
    for line in sec.splitlines():
        m = re.match(r"\s*-\s+(\S+)\s+\+\s+NET\s+(\S+)", line)
        if m:
            ports.append((m.group(1), "input" if re.search(r"DIRECTION\s+INPUT", line) else "output"))
    nets = defaultdict(list)
    ns = re.search(r"\nNETS\s", text)
    ne = text.find("END NETS")
    if ns and ne > ns.end():
        sec = text[ns.end() - len("NETS") - 1 : ne]
    else:
        sec = ""
    cur = None
    for line in sec.splitlines():
        m = re.match(r"\s*-\s+(\S+)", line)
        if m:
            cur = m.group(1); nets[cur] = []
        elif cur:
            for pin in re.finditer(r"\(\s*([^\s()]+)\s+([^\s()]+)\s*\)", line):
                nets[cur].append((pin.group(1), pin.group(2)))
    return design, comps, ports, nets

import re as _re
_names = {}
def san(name):
    if name in _names:
        return _names[name]
    base = _re.sub(r"[^A-Za-z0-9_]", "_", name.replace("\\", "/"))
    if base and base[0].isdigit():
        base = "n_" + base
    key = base
    n = 0
    while key in _names.values():
        n += 1
        key = f"{base}_{n}"
    _names[name] = key
    return key

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("def_file")
    ap.add_argument("out_verilog")
    args = ap.parse_args()
    design, comps, ports, nets = parse_def(args.def_file)
    out = []
    port_names = [san(p) for p, _ in ports]
    out.append(f"module {san(design)} (")
    for i, p in enumerate(port_names):
        out.append("  " + p + ("," if i < len(port_names) - 1 else "") )
    out.append(");")
    # Ports (non-ANSI redeclaration without wire keyword)
    for p, direction in ports:
        out.append(f"  {direction} {san(p)} ;")
    # Nets that are not ports -> wires
    net_ids = {}
    used = set()
    idx = 0
    for net in nets:
        # map port names to port identifier; else create wire n_idx
        port_name = next((p for p, _ in ports if p == net), None)
        if port_name is not None:
            net_ids[net] = san(port_name)
        else:
            net_ids[net] = f"n{idx}"
            used.add(net)
            idx += 1
    for net in used:
        out.append(f"  wire {net_ids[net]} ;")
    # Components
    for inst, cell in comps.items():
        pins = defaultdict(list)
        for net, conns in nets.items():
            for i, p in conns:
                if i == inst:
                    pins[p].append(net)
        conn = ", ".join(f".{san(p)}({net_ids[n]})" for p, nlist in pins.items() for n in nlist)
        out.append(f"  {san(cell)} {san(inst)} ( {conn} );")
    out.append("endmodule")
    Path(args.out_verilog).write_text("\n".join(out) + "\n")
    print(f"wrote {args.out_verilog}: {len(comps)} components, {len(nets)} nets")

if __name__ == "__main__":
    main()
