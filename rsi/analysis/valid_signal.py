"""Which layout property actually tracks peak congestion on the VALID design set?

Round 2 tested shape statistics against EGR max on six sky130 designs and found them weak. The
valid, netlist-matched set is dominated by ics55 and nangate45, where the peak deficits actually
live, and the large designs are exactly the ones that were never in that test. This recomputes a
family of structural properties for our placement and the reference on every valid design and
correlates each with the EGR max ratio, so the search for a signal is done on the set that matters.

Properties, all computable from the DEF alone:
  gini, max_bin, busiest-1%      instance-count shape on a 64x64 grid
  occ_overflow_sum               sum over bins of max(0, count - mean_count), the non-saturated
                                 analogue of the density monitor that returns a constant
  net_bbox_sum, net_bbox_p99     net bounding-box extent, total and 99th percentile
  nets_per_bin_p99               how many nets cross the busiest bins
"""
import collections
import json
import re
import statistics as st
import subprocess
import sys
from pathlib import Path

W = Path("/home/lizhijun/work/ieda-rsi")
sys.path.insert(0, str(W / "ieda/rsi/harness"))
import placement_shape as PS

D = json.loads((W / "ieda/rsi/harness/designs.local.json").read_text())
A = {x["design"]: x for x in json.loads((W / "ieda/rsi/analysis/out/innovus_anchor.json").read_text())}
B = {r["design"]: r for r in json.loads((W / "runs/srciter/baseV2.json").read_text())["rows"]}

INST = re.compile(r"^\s*-\s+(\S+)\s+(\S+)\s+\+\s+(?:PLACED|FIXED)\s+\(\s*(\d+)\s+(\d+)\s*\)")
PIN = re.compile(r"\(\s*(\S+)\s+(\S+)\s*\)")
DIE = re.compile(r"DIEAREA\s*\(\s*(\d+)\s+(\d+)\s*\)\s*\(\s*(\d+)\s+(\d+)\s*\)")


def netstats(def_path, nbins=64):
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
    grids = [[0] * nbins for _ in range(nbins)]
    for (x, y) in pos.values():
        bx = min(nbins - 1, max(0, int((x - x0) / w * nbins)))
        by = min(nbins - 1, max(0, int((y - y0) / h * nbins)))
        grids[by][bx] += 1
    flat = [v for row in grids for v in row]
    tot = sum(flat)
    mean = tot / float(nbins * nbins)
    occ_overflow = sum(max(0.0, v - mean) for v in flat)

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
            cur = []
            nets.append(cur)
            rest = s
        elif cur is not None and s.startswith("("):
            rest = s
        else:
            continue
        for mm in PIN.finditer(rest):
            cur.append(mm.group(1))
    bboxes = []
    for pins in nets:
        pts = [pos[p] for p in pins if p in pos]
        if len(pts) < 2:
            continue
        bx = (max(p[0] for p in pts) - min(p[0] for p in pts)) + (max(p[1] for p in pts) - min(p[1] for p in pts))
        bboxes.append(bx / 1000.0)
    bboxes.sort()
    sh = PS.parse_placement(def_path)
    return {"occ_overflow_sum": round(occ_overflow / max(mean, 1e-9), 3),
            "net_bbox_sum": round(sum(bboxes), 1),
            "net_bbox_p99": round(bboxes[int(0.99 * (len(bboxes) - 1))], 2) if bboxes else None,
            "net_bbox_max": round(bboxes[-1], 2) if bboxes else None,
            "gini": sh["gini"] if sh else None, "max_bin": sh["max_bin"] if sh else None,
            "nets": len(bboxes)}


def spearman(x, y):
    n = len(x)
    if n < 5:
        return None

    def rk(v):
        o = sorted(range(n), key=lambda i: v[i])
        r = [0.0] * n
        i = 0
        while i < n:
            j = i
            while j + 1 < n and v[o[j + 1]] == v[o[i]]:
                j += 1
            a = (i + j) / 2.0 + 1
            for k in range(i, j + 1):
                r[o[k]] = a
            i = j + 1
        return r
    rx, ry = rk(x), rk(y)
    mx, my = st.mean(rx), st.mean(ry)
    num = sum((p - mx) * (q - my) for p, q in zip(rx, ry))
    dx = sum((p - mx) ** 2 for p in rx) ** 0.5
    dy = sum((q - my) ** 2 for q in ry) ** 0.5
    return num / (dx * dy) if dx and dy else None


rows = []
for d in sorted(D):
    rec = D[d]
    ref = rec.get("innovus_def")
    ours = W / "runs/srciter/sweep/baseV2" / d / "placement.def"
    if not (ref and Path(ref).exists() and ours.exists()):
        continue
    a = netstats(ours)
    b = netstats(ref)
    bb = B.get(d); aa = (A.get(d) or {}).get("reference") or {}
    if not (a and b and bb and aa.get("egr_max")):
        continue
    if bb.get("egr_max") is None:
        continue
    rows.append({"design": d, "pdk": rec.get("pdk"),
                 "egr_max": bb["egr_max"] / max(aa["egr_max"], 1),
                 "occ": a["occ_overflow_sum"] / max(b["occ_overflow_sum"], 1e-9),
                 "bbox_sum": a["net_bbox_sum"] / max(b["net_bbox_sum"], 1e-9),
                 "bbox_p99": a["net_bbox_p99"] / max(b["net_bbox_p99"], 1e-9),
                 "bbox_max": a["net_bbox_max"] / max(b["net_bbox_max"], 1e-9),
                 "gini": (a["gini"] - b["gini"]) if (a["gini"] and b["gini"]) else None,
                 "max_bin": a["max_bin"] / max(b["max_bin"], 1)})

print("  %-22s %-10s %8s %8s %9s %9s %8s" % ("design", "pdk", "egr_max", "occ_ovf", "bbox_sum", "bbox_p99", "gini_d"))
for r in rows:
    print("  %-22s %-10s %8.2f %8.2f %9.2f %9.2f %8s" % (
        r["design"], r["pdk"], r["egr_max"], r["occ"], r["bbox_sum"], r["bbox_p99"],
        ("%+.3f" % r["gini"]) if r["gini"] is not None else "-"))
print()
print("=== correlation with the EGR max ratio (n=%d) ===" % len(rows))
em = [r["egr_max"] for r in rows]
for lab, k in (("occupancy-overflow sum ratio", "occ"), ("net bbox sum ratio", "bbox_sum"),
               ("net bbox p99 ratio", "bbox_p99"), ("net bbox max ratio", "bbox_max"),
               ("max-bin ratio", "max_bin"), ("gini delta", "gini")):
    xs = [r[k] for r in rows if r[k] is not None]
    es = [r["egr_max"] for r in rows if r[k] is not None]
    rho = spearman(xs, es)
    print("  %-30s rho %s" % (lab, ("%+.3f" % rho) if rho is not None else "n/a"))
