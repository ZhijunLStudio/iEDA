"""Which nets build the peak demand, ours versus the reference?

Round 2 showed our placement asks for ~1.85x more routing demand at its worst spot than the
reference on 30/30 designs, and that the signal is net-topology, not cell counts. This goes
one level down: for the single worst bin in each placement, which nets cross it, and what
are those nets like?

The answer decides the lever. If our worst bin is fed by many short local nets, the cause is
local and the lever is spreading. If it is fed by a few long global nets - clock, resets,
high-fanout enables - the cause is how the placer shapes those nets, and no change to the
density model will touch it.

Same parser and grid for both sides; pin positions are instance origins for both.
"""
import collections
import json
import re
import statistics as st
import sys
from pathlib import Path

sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import rsi_lib as R

INST = re.compile(r"^\s*-\s+(\S+)\s+(\S+)\s+\+\s+(?:PLACED|FIXED)\s+\(\s*(\d+)\s+(\d+)\s*\)")
PIN = re.compile(r"\(\s*(\S+)\s+(\S+)\s*\)")
DIE = re.compile(r"DIEAREA\s*\(\s*(\d+)\s+(\d+)\s*\)\s*\(\s*(\d+)\s+(\d+)\s*\)")


def load(def_path, nbins=64):
    txt = Path(def_path).read_text(errors="ignore")
    m = DIE.search(txt)
    if not m:
        return None
    x0, y0, x1, y1 = (int(v) for v in m.groups())
    w, h = max(x1 - x0, 1), max(y1 - y0, 1)
    pos = {}
    for line in txt.splitlines():
        mm = INST.match(line)
        if mm:
            pos[mm.group(1)] = (int(mm.group(3)), int(mm.group(4)))
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
        if s.startswith("END NETS") or s.startswith("END DESIGN"):
            break
        if s.startswith("- "):
            nm = s.split()[1]
            cur = {"name": nm, "pins": []}
            nets.append(cur)
            rest = s
        elif cur is not None and s.startswith("("):
            rest = s
        else:
            continue
        for mm in PIN.finditer(rest):
            cur["pins"].append(mm.group(1))
    # demand map + per-bin contribution bookkeeping
    grid = [[0.0] * nbins for _ in range(nbins)]
    contributors = collections.defaultdict(list)   # (ix,iy) -> list of net dicts
    for nt in nets:
        pts = [pos[p] for p in nt["pins"] if p in pos]
        if len(pts) < 2:
            continue
        bx0 = min(p[0] for p in pts); bx1 = max(p[0] for p in pts)
        by0 = min(p[1] for p in pts); by1 = max(p[1] for p in pts)
        ix0 = min(nbins - 1, max(0, int((bx0 - x0) / w * nbins)))
        ix1 = min(nbins - 1, max(0, int((bx1 - x0) / w * nbins)))
        iy0 = min(nbins - 1, max(0, int((by0 - y0) / h * nbins)))
        iy1 = min(nbins - 1, max(0, int((by1 - y0) / h * nbins)))
        span = (ix1 - ix0 + 1) * (iy1 - iy0 + 1)
        share = 1.0 / span
        hw = (bx1 - bx0) + (by1 - by0)
        rec = {"name": nt["name"], "fanout": len(pts), "bbox_um": round(hw / 1000.0, 2),
               "share": share, "span_bins": span}
        for ix in range(ix0, ix1 + 1):
            for iy in range(iy0, iy1 + 1):
                grid[iy][ix] += share
                contributors[(ix, iy)].append(rec)
    return {"grid": grid, "contrib": contributors, "nbins": nbins,
            "die": (x0, y0, x1, y1, w, h), "nets": nets}


def worst_bin(info):
    best = None
    for iy in range(info["nbins"]):
        for ix in range(info["nbins"]):
            v = info["grid"][iy][ix]
            if best is None or v > best[0]:
                best = (v, ix, iy)
    return best


def describe(info, ix, iy, top=8):
    v, _, _ = worst_bin(info)
    nets = info["contrib"].get((ix, iy), [])
    fan = [n["fanout"] for n in nets]
    bb = [n["bbox_um"] for n in nets]
    sh = [n["share"] for n in nets]
    top_nets = sorted(nets, key=lambda n: -n["share"])[:top]
    return {"demand": round(v, 3), "n_nets": len(nets),
            "median_fanout": st.median(fan) if fan else 0,
            "median_bbox_um": round(st.median(bb), 2) if bb else 0,
            "p90_bbox_um": round(sorted(bb)[int(0.9 * (len(bb) - 1))], 2) if bb else 0,
            "share_from_top8": round(sum(n["share"] for n in top_nets) / v, 3) if v else 0,
            "top": [{"net": n["name"], "fo": n["fanout"], "bbox_um": n["bbox_um"],
                     "contrib": round(n["share"], 4)} for n in top_nets]}


D = R.load_designs()
names = [x for x in (sys.argv[1].split(",") if len(sys.argv) > 1 else []) if x]
out = []
for d in names:
    rec = D.get(d)
    if not rec:
        continue
    ours = R.RUNS / "srciter" / "sweep" / "baseV2" / d / "placement.def"
    ref = rec.get("innovus_def")
    if not ours.exists() or not ref or not Path(ref).exists():
        print("skip", d); continue
    a = load(ours); b = load(ref)
    if not a or not b:
        print("parse fail", d); continue
    va, ix, iy = worst_bin(a)
    vb, jx, jy = worst_bin(b)
    da = describe(a, ix, iy); db = describe(b, jx, jy)
    row = {"design": d, "pdk": rec.get("pdk"),
           "ours": da, "reference": db,
           "demand_ratio": va / max(vb, 1e-9)}
    out.append(row)
    print("%-22s ours demand %7.2f (%d nets, med fo %s, med bbox %sum, top8 share %s)"
          % (d, va, da["n_nets"], da["median_fanout"], da["median_bbox_um"], da["share_from_top8"]))
    print("%-22s ref  demand %7.2f (%d nets, med fo %s, med bbox %sum, top8 share %s)  ratio %.2f"
          % ("", vb, db["n_nets"], db["median_fanout"], db["median_bbox_um"], db["share_from_top8"],
             row["demand_ratio"]))
    for k in ("ours", "reference"):
        tops = ", ".join("%s(fo%d,%sum,%.2f)" % (t["net"], t["fo"], t["bbox_um"], t["contrib"])
                         for t in row[k]["top"][:4])
        print("      %-9s top: %s" % (k, tops[:150]))
    sys.stdout.flush()
Path(R.RUNS, "netpeak.json").write_text(json.dumps(out, indent=1))
print("wrote", R.RUNS / "netpeak.json")
