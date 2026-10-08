"""Net effect of iterating the legalisation/detail-placement pipeline to convergence.

Reads every convergence-sweep log and reports, per design and in aggregate, the paired change from
one pass to three passes at the same seed, alongside how far each placement sits from the reference.
"""
import collections
import json
import re
import statistics as st
import subprocess
import sys
from pathlib import Path

W = Path("/home/lizhijun/work/ieda-rsi")
A = {x["design"]: x for x in json.loads((W / "ieda/rsi/analysis/out/innovus_anchor.json").read_text())}
D = json.loads((W / "ieda/rsi/harness/designs.local.json").read_text())


def netcount(p):
    if not p or not Path(p).exists():
        return None
    r = subprocess.run(["grep", "-m1", "-E", "^NETS ", p], capture_output=True)
    m = re.search(rb"NETS\s+(\d+)", r.stdout)
    return int(m.group(1)) if m else None


rows = []
for f in ("conv.log", "conv_sky.log"):
    p = W / "runs" / f
    if not p.exists():
        continue
    for l in p.read_text().splitlines():
        l = l.strip()
        if l.startswith("{"):
            try:
                rows.append(json.loads(l))
            except Exception:
                pass

by = collections.defaultdict(dict)
for r in rows:
    by[(r["design"], r["seed"])][r["arm"]] = r

agg = collections.defaultdict(lambda: {"dp": [], "du": [], "dh": [], "p0": [], "p4": [], "u0": [], "u4": []})
print("  %-22s %5s | %5s %5s %6s | %7s %7s %8s" % ("design", "seed", "p1", "p3", "dpeak", "u1", "u3", "dunion"))
for k in sorted(by):
    v = by[k]
    a, b = v.get("B0"), v.get("B4")
    if not (a and b):
        continue
    dp = (b["max"] - a["max"]) if (a.get("max") is not None and b.get("max") is not None) else None
    du = (b["union"] - a["union"]) if (a.get("union") is not None and b.get("union") is not None) else None
    dh = (100 * (b["hpwl"] / a["hpwl"] - 1)) if (a.get("hpwl") and b.get("hpwl")) else None
    g = agg[k[0]]
    if dp is not None:
        g["dp"].append(dp); g["p0"].append(a["max"]); g["p4"].append(b["max"])
    if du is not None:
        g["du"].append(du); g["u0"].append(a["union"]); g["u4"].append(b["union"])
    if dh is not None:
        g["dh"].append(dh)
    print("  %-22s %5d | %5s %5s %6s | %7s %7s %8s" % (
        k[0], k[1], a.get("max"), b.get("max"), dp, a.get("union"), b.get("union"), du))

print()
print("=== per design ===")
tot_dp = []; tot_du = []
for d in sorted(agg):
    g = agg[d]
    ru = ((A.get(d) or {}).get("reference") or {}).get("egr_total")
    rm = ((A.get(d) or {}).get("reference") or {}).get("egr_max")
    valid = ""
    a1, b1 = netcount(D.get(d, {}).get("input_def")), netcount(D.get(d, {}).get("innovus_def"))
    if a1 is not None and b1 is not None and abs(b1 - a1) <= 5:
        valid = "valid"
    if g["dp"]:
        tot_dp += g["dp"]; tot_du += g["du"]
        print("  %-22s %-6s peak %s->%s (better %d/%d)  union %s->%s (better %d/%d)  dHPWL %s  [ref %s/%s]" % (
            d, valid, g["p0"], g["p4"], sum(1 for x in g["dp"] if x < 0), len(g["dp"]),
            g["u0"], g["u4"], sum(1 for x in g["du"] if x < 0), len(g["du"]),
            ("%+.2f%%" % st.median(g["dh"])) if g["dh"] else "-", ru, rm))
print()
if tot_dp:
    print("  ALL designs paired: peak better on %d/%d seed-pairs, union better on %d/%d" % (
        sum(1 for x in tot_dp if x < 0), len(tot_dp), sum(1 for x in tot_du if x < 0), len(tot_du)))
    print("  median dpeak %+.1f, median dunion %+.1f" % (st.median(tot_dp), st.median(tot_du)))
