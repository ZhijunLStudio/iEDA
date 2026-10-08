"""Do we pack the cells into less area than the reference does?

The broad-overflow designs carry overflow on 30 to 40 per cent of the die at a shallow depth, which is
what a placement looks like when routing demand is too high everywhere rather than concentrated. One
geometric cause would be that our placer, optimising wirelength, shrinks the used area relative to the
reference and so raises local utilisation across the chip. That is computable from the placement files
already on disk.
"""
import json, re
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")

def profile(defp, lef):
    """Return (cell bbox area, sum of cell areas) for placed instances."""
    txt = Path(defp).read_text(errors="ignore")
    xmin = ymin = 10**18; xmax = ymax = -10**18
    n = 0
    for m in re.finditer(r"-\s+(\S+)\s+(\S+)\s+\+\s+(PLACED|FIXED)\s*\(\s*(-?\d+)\s+(-?\d+)\s*\)\s+(\S+)", txt):
        _, _, _, x, y, _ = m.groups()
        x = int(x); y = int(y)
        xmin = min(xmin, x); ymin = min(ymin, y); xmax = max(xmax, x); ymax = max(ymax, y)
        n += 1
    if n == 0: return None
    bbox = (xmax - xmin) * (ymax - ymin)
    return {"n": n, "bbox_w": xmax - xmin, "bbox_h": ymax - ymin, "bbox_area": bbox}

agg = json.loads((W/"runs/standingB/agg.json").read_text())
D = json.loads((W/"ieda/rsi/harness/designs.local.json").read_text())
print("  %-20s %10s %10s %8s | %6s %6s %6s | %s" % (
    "design","bbox ours","bbox ref","ratio","u rat","m rat","h rat","fails"))
for r in sorted(agg, key=lambda x: x["design"]):
    d = r["design"]
    o = profile(W/"runs"/"standingB"/d/"ours"/"placement.def", None)
    f = profile(W/"runs"/"standingB"/d/"ref"/"placement.def", None)
    if not (o and f):
        print("  %-20s incomplete" % d); continue
    ratio = o["bbox_area"] / f["bbox_area"]
    bad = [k for k in ("union","max","hpwl") if r["ratio"][k] is not None and r["ratio"][k] > 1.0]
    print("  %-20s %10d %10d %8.3f | %6s %6s %6s | %s" % (
        d, o["bbox_area"], f["bbox_area"], ratio,
        r["ratio"]["union"], r["ratio"]["max"], r["ratio"]["hpwl"], ",".join(bad) or "ALL"))
