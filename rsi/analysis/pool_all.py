"""Candidate-pool effect on every design measured so far, pooled across sweeps.

Combines the pool logs and applies the same Pareto rule, reporting per design whether a candidate
other than the shipped one wins, and what that does against the reference.
"""
import collections
import json
import statistics as st
from pathlib import Path

W = Path("/home/lizhijun/work/ieda-rsi")
A = {x["design"]: x for x in json.loads((W / "ieda/rsi/analysis/out/innovus_anchor.json").read_text())}
ARMS = ("lg", "lgdp", "lgdplg", "lgdplgdp", "ce2lg", "ce4lg")


def dom(a, b):
    if not a or not b or a.get("union") is None or b.get("union") is None or a.get("max") is None or b.get("max") is None:
        return False
    return a["union"] <= b["union"] and a["max"] <= b["max"] and (a["union"] < b["union"] or a["max"] < b["max"])


rows = []
for f in ("pool.log", "pool2.log", "pool_seed3.log"):
    p = W / "runs" / f
    if p.exists():
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

print("  %-20s %5s | %8s/%-5s %8s/%-5s | %-10s | %8s %8s | ref u/max" % (
    "design", "seed", "lgdp u", "p", "best u", "p", "best arm", "best/ref", "peak/ref"))
chosen = collections.Counter()
ship_u = []; ship_p = []; best_u = []; best_p = []
for k in sorted(by):
    v = by[k]
    if not all(a in v for a in ARMS):
        continue
    b = v["lgdp"]
    best = None
    for a in ARMS:
        c = v[a]
        if best is None or dom(c, best):
            best = c
    if best is None:
        continue
    nm = [a for a in ARMS if v[a] is best]
    chosen[nm[0] if nm else "?"] += 1
    ref = (A.get(k[0], {}) or {}).get("reference") or {}
    ru, rm = ref.get("egr_total"), ref.get("egr_max")
    if ru and rm:
        ship_u.append(b["union"] / ru); ship_p.append(b["max"] / rm)
        best_u.append(best["union"] / ru); best_p.append(best["max"] / rm)
    print("  %-20s %5d | %8s/%-5s %8s/%-5s | %-10s | %8s %8s | %s/%s" % (
        k[0], k[1], b.get("union"), b.get("max"), best.get("union"), best.get("max"),
        nm[0] if nm else "?", ("%.2f" % (best["union"] / ru)) if ru else "-",
        ("%.2f" % (best["max"] / rm)) if rm else "-", ru, rm))

print()
print("  Pareto-best arm counts: %s" % dict(chosen))
if ship_u:
    print()
    print("  %-36s %10s %10s" % ("", "ships lgdp", "pool best"))
    print("  %-36s %10.3f %10.3f" % ("median EGR union / reference", st.median(ship_u), st.median(best_u)))
    print("  %-36s %10.3f %10.3f" % ("median EGR peak / reference", st.median(ship_p), st.median(best_p)))
    print("  %-36s %10d %10d" % ("seed-pairs with BOTH <= 1.0x",
                                 sum(1 for a, b in zip(ship_u, ship_p) if a <= 1 and b <= 1),
                                 sum(1 for a, b in zip(best_u, best_p) if a <= 1 and b <= 1)))
