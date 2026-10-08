"""Net-topology demand: which bins do the nets ask for, ours versus the reference?

Cell-count clustering did not explain peak congestion (Round 2). The other candidate is net
topology: a bin overflows because of the routing demand crossing it, which depends on where
nets reach, not only on how many cells sit there.

This builds a RUDY-style demand map directly from the DEFs - for every net, take the
bounding box of its pins and charge its demand to the bins the box covers - and compares
our placement with the reference's on the same die and netlist. Same parser, same grid, so
the comparison is like for like. Pin positions are approximated by instance origins; both
sides get the same approximation.

Reported per design: max bin demand, the share of demand in the busiest 1% of bins, and the
correlation between our demand map and the reference's (how much the hot spots agree).

Usage: python3 netdemand.py design1,design2
"""
import collections
import json
import re
import statistics as st
import sys
from pathlib import Path

sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import rsi_lib as R

COMP = re.compile(r"^\s*-\s+(\S+)\s+(\S+)\s+\+\s+(?:PLACED|FIXED)\s+\(\s*(\d+)\s+(\d+)\s*\)")
DIE = re.compile(r"DIEAREA\s*\(\s*(\d+)\s+(\d+)\s*\)\s*\(\s*(\d+)\s+(\d+)\s*\)")


def parse(def_path, nbins=64):
    txt = Path(def_path).read_text(errors="ignore")
    m = DIE.search(txt)
    if not m:
        return None
    x0, y0, x1, y1 = (int(v) for v in m.groups())
    w, h = max(x1 - x0, 1), max(y1 - y0, 1)
    pos = {}
    for line in txt.splitlines():
        mm = COMP.match(line)
        if mm:
            pos[mm.group(1)] = (int(mm.group(3)), int(mm.group(4)))
    # nets: collect the instance names referenced on each net
    nets = []
    cur = None
    in_net = False
    for line in txt.splitlines():
        s = line.strip()
        if s.startswith("NETS"):
            in_net = True
            continue
        if not in_net:
            continue
        if s in ("END NETS",) or s.startswith("END DESIGN"):
            break
        if s.startswith("- "):
            cur = []
            nets.append(cur)
            # iEDA writes the net name and its first pins on one line
            # ("- G29 ( U444 B1 ) ( DFF_0/Q_reg Q )") while Innovus writes the name on
            # its own line and the pins on following lines. Handle both.
            s_rest = s
        elif cur is not None and s.startswith("("):
            s_rest = s
        else:
            continue
        for mm in re.finditer(r"\(\s*(\S+)\s+\S+\s*\)", s_rest):
            cur.append(mm.group(1))
    grid = [[0.0] * nbins for _ in range(nbins)]
    used = 0
    for pins in nets:
        pts = [pos[p] for p in pins if p in pos]
        if len(pts) < 2:
            continue
        used += 1
        bx0 = min(p[0] for p in pts); bx1 = max(p[0] for p in pts)
        by0 = min(p[1] for p in pts); by1 = max(p[1] for p in pts)
        ix0 = min(nbins - 1, max(0, int((bx0 - x0) / w * nbins)))
        ix1 = min(nbins - 1, max(0, int((bx1 - x0) / w * nbins)))
        iy0 = min(nbins - 1, max(0, int((by0 - y0) / h * nbins)))
        iy1 = min(nbins - 1, max(0, int((by1 - y0) / h * nbins)))
        ncell = (ix1 - ix0 + 1) * (iy1 - iy0 + 1)
        share = 1.0 / ncell
        for ix in range(ix0, ix1 + 1):
            for iy in range(iy0, iy1 + 1):
                grid[iy][ix] += share
    flat = [v for row in grid for v in row]
    tot = sum(flat) or 1.0
    occ = sorted(v for v in flat if v > 0)
    k = max(1, len(occ) // 100)
    return {"nets_used": used, "max_bin": max(flat), "total": tot,
            "busiest1pct_share": sum(occ[-k:]) / tot if occ else 0.0,
            "grid": grid}


def pearson(a, b):
    fa = [v for row in a for v in row]
    fb = [v for row in b for v in row]
    n = len(fa)
    ma, mb = st.mean(fa), st.mean(fb)
    num = sum((x - ma) * (y - mb) for x, y in zip(fa, fb))
    da = sum((x - ma) ** 2 for x in fa) ** 0.5
    db = sum((y - mb) ** 2 for y in fb) ** 0.5
    return num / (da * db) if da and db else None


D = R.load_designs()
names = [x for x in (sys.argv[1].split(",") if len(sys.argv) > 1 else []) if x]
res = []
for d in names:
    rec = D.get(d)
    if not rec:
        continue
    ours = R.RUNS / "srciter" / "sweep" / "baseV2" / d / "placement.def"
    ref = rec.get("innovus_def")
    if not ours.exists() or not ref:
        print("skip", d)
        continue
    a = parse(ours)
    b = parse(ref)
    if not a or not b:
        print("parse failed", d)
        continue
    row = {"design": d, "pdk": rec.get("pdk"),
           "our_max": a["max_bin"], "ref_max": b["max_bin"],
           "max_ratio": a["max_bin"] / max(b["max_bin"], 1e-9),
           "our_busy1pct": a["busiest1pct_share"], "ref_busy1pct": b["busiest1pct_share"],
           "busy_ratio": a["busiest1pct_share"] / max(b["busiest1pct_share"], 1e-9),
           "map_pearson": pearson(a["grid"], b["grid"]),
           "nets": a["nets_used"]}
    res.append(row)
    print(json.dumps({k: (round(v, 4) if isinstance(v, float) else v) for k, v in row.items()}))
Path(R.RUNS, "netdemand.json").write_text(json.dumps(res, indent=1))
print("wrote", R.RUNS / "netdemand.json")
