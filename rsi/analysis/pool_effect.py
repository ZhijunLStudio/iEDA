"""Which candidates in the pool ever dominate, and what the pool does to the standing.

For each (design, seed) the pool has six candidates from the same global placement. This reports
the Pareto-best of the pool against (a) what the flow ships (lgdp) and (b) the reference, so the
value of a wider pool is measured rather than asserted.
"""
import collections
import json
import statistics as st
from pathlib import Path

W = Path("/home/lizhijun/work/ieda-rsi")
A = {x["design"]: x for x in json.loads((W / "ieda/rsi/analysis/out/innovus_anchor.json").read_text())}

rows = []
for l in (W / "runs/pool.log").read_text().splitlines():
    l = l.strip()
    if l.startswith("{"):
        try:
            rows.append(json.loads(l))
        except Exception:
            pass

by = collections.defaultdict(dict)
for r in rows:
    by[(r["design"], r["seed"])][r["arm"]] = r

ARMS = ("lg", "lgdp", "lgdplg", "lgdplgdp", "ce2lg", "ce4lg")


def dominates(a, b):
    if a.get("union") is None or b.get("union") is None or a.get("max") is None or b.get("max") is None:
        return False
    return a["union"] <= b["union"] and a["max"] <= b["max"] and (a["union"] < b["union"] or a["max"] < b["max"])


print("  %-20s %5s | %s | %-9s | %9s %9s | ref u/max" % (
    "design", "seed", "".join("%8s" % a for a in ARMS), "best", "best u/ref", "best p/ref"))
wins = collections.Counter()
for k in sorted(by):
    v = by[k]
    if not all(a in v for a in ARMS):
        continue
    best = None
    for a in ARMS:
        c = v[a]
        if c.get("union") is None or c.get("max") is None:
            continue
        if best is None or dominates(c, best):
            best = c
    if best is None:
        continue
    names = [a for a in ARMS if v[a] is best]
    wins[names[0] if names else "?"] += 1
    ref = (A.get(k[0], {}) or {}).get("reference") or {}
    ru, rm = ref.get("egr_total"), ref.get("egr_max")
    cells = "".join("%8s" % ("%s/%s" % (v[a].get("union"), v[a].get("max"))) for a in ARMS)
    print("  %-20s %5d |%s | %-9s | %9s %9s | %s/%s" % (
        k[0], k[1], cells, ",".join(names),
        ("%.2f" % (best["union"] / ru)) if ru else "-",
        ("%.2f" % (best["max"] / rm)) if rm else "-", ru, rm))

print()
print("  Pareto-best comes from: %s" % dict(wins))
print()
print("=== pool versus the shipped flow (lgdp) and the reference ===")
ship_u = []; ship_p = []; pool_u = []; pool_p = []
for k in sorted(by):
    v = by[k]
    if "lgdp" not in v or not all(a in v for a in ARMS):
        continue
    ref = (A.get(k[0], {}) or {}).get("reference") or {}
    ru, rm = ref.get("egr_total"), ref.get("egr_max")
    if not (ru and rm):
        continue
    best = None
    for a in ARMS:
        c = v[a]
        if c.get("union") is None or c.get("max") is None:
            continue
        if best is None or dominates(c, best):
            best = c
    if best is None:
        continue
    ship_u.append(v["lgdp"]["union"] / ru); ship_p.append(v["lgdp"]["max"] / rm)
    pool_u.append(best["union"] / ru); pool_p.append(best["max"] / rm)
print("  %-34s %10s %10s" % ("", "ships lgdp", "pool best"))
print("  %-34s %10.3f %10.3f" % ("median EGR union / reference", st.median(ship_u), st.median(pool_u)))
print("  %-34s %10.3f %10.3f" % ("median EGR peak / reference", st.median(ship_p), st.median(pool_p)))
print("  %-34s %10d %10d" % ("seed-pairs with peak <= 1.0x", sum(1 for x in ship_p if x <= 1.0), sum(1 for x in pool_p if x <= 1.0)))
print("  %-34s %10d %10d" % ("seed-pairs with BOTH <= 1.0x", sum(1 for a, b in zip(ship_u, ship_p) if a <= 1 and b <= 1), sum(1 for a, b in zip(pool_u, pool_p) if a <= 1 and b <= 1)))
