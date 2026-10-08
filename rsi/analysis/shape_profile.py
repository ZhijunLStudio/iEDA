"""What shape does our congestion have relative to the reference's?

Total overflow and peak are two numbers from the same map, and they fail independently across designs.
This profiles the maps: how many cells carry overflow, how deep the excess is where it occurs, and how
concentrated it is. Those distinguish a placement whose overflow is spread thin over many cells from one
where it is concentrated in a few, which are different defects with different fixes.
"""
import json
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")

def cells(p):
    r = []
    for line in Path(p).read_text().strip().splitlines():
        r.append([float(x) if x not in ("", "nan") else 0.0 for x in line.split(",")])
    return r

def prof(p):
    g = cells(p)
    ny = len(g); nx = len(g[0]) if ny else 0
    v = sorted((g[y][x] for y in range(ny) for x in range(nx)), reverse=True)
    tot = sum(v)
    over = [x for x in v if x > 0]
    n = nx * ny
    top1 = sum(v[:max(1, n // 100)])
    return {"nx": nx, "ny": ny, "sum": tot, "n_over": len(over), "peak": v[0] if v else 0.0,
            "mean_over": (sum(over) / len(over) if over else 0.0),
            "top1pct_share": (100.0 * top1 / tot if tot else 0.0),
            "shape": "%dx%d" % (nx, ny)}

print("  %-16s %-9s %8s %8s %8s %9s %8s" % ("design", "arm", "sum", "peak", "cells>0", "mean>0", "top1%"))
for d in ["s1238","picorv32","apb4_timer","gcd_ics55_a","salsa20_ics55_a","s38584_ics55_a","s5378_sky130_b"]:
    for arm in ("ours", "ref"):
        p = W/"runs"/"standingB"/d/arm/"egr_congestion_map/place_egr_union_overflow.csv"
        if not p.exists():
            print("  %-16s %-9s (no map)" % (d, arm)); continue
        q = prof(p)
        print("  %-16s %-9s %8.0f %8.0f %8d %9.2f %7.1f%%" % (
            d, arm, q["sum"], q["peak"], q["n_over"], q["mean_over"], q["top1pct_share"]))
    print()
