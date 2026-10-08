"""Two-way and three-way candidate selection, combined.

Two-way (Round 13): legalised vs detailed, Pareto on (union, peak).
Three-way: adds the converged finishing stage. All arms in the three-way run use the SR-6 binary,
so the comparison varies only the command sequence. Reported against the reference and against the
shipped flow's always-detailed choice.
"""
import collections
import json
import statistics as st
from pathlib import Path

W = Path("/home/lizhijun/work/ieda-rsi")
A = {x["design"]: x for x in json.loads((W / "ieda/rsi/analysis/out/innovus_anchor.json").read_text())}


def load(f):
    p = W / "runs" / f
    out = []
    if p.exists():
        for l in p.read_text().splitlines():
            l = l.strip()
            if l.startswith("{"):
                try:
                    out.append(json.loads(l))
                except Exception:
                    pass
    return out


def pareto_best(cands):
    """Index of the Pareto-best candidate on (union, peak); None if not comparable."""
    ok = [c for c in cands if c and c.get("union") is not None and c.get("max") is not None]
    if not ok:
        return None
    best = ok[0]
    for c in ok[1:]:
        if c["union"] <= best["union"] and c["max"] <= best["max"]:
            if c["union"] < best["union"] or c["max"] < best["max"]:
                best = c
    return best


print("=== three-way: legalised (lg) / detailed (lgdp) / converged finish (fin) ===")
rows = load("pareto3.log")
by = collections.defaultdict(dict)
for r in rows:
    by[(r["design"], r["seed"])][r["arm"]] = r
for k in sorted(by):
    v = by[k]
    if not all(a in v for a in ("lg", "lgdp", "fin")):
        continue
    ref = (A.get(k[0], {}) or {}).get("reference") or {}
    ru, rm = ref.get("egr_total"), ref.get("egr_max")
    best = pareto_best([v["lg"], v["lgdp"], v["fin"]])
    pick = [a for a in ("lg", "lgdp", "fin") if v[a] is best]
    print("  %-20s s%d | lg %6s/%-4s | lgdp %6s/%-4s | fin %6s/%-4s | best %6d/%-4d (%s) | ref %s/%s" % (
        k[0], k[1], v["lg"].get("union"), v["lg"].get("max"), v["lgdp"].get("union"),
        v["lgdp"].get("max"), v["fin"].get("union"), v["fin"].get("max"),
        best["union"], best["max"], (pick[0] if pick else "?"), ru, rm))

print()
print("=== two-way, all designs measured so far ===")
rows2 = load("pareto.log") + load("pareto2.log")
by2 = collections.defaultdict(dict)
for r in rows2:
    by2[(r["design"], r["seed"])][r["arm"]] = r
fires = 0
tot = 0
for k in sorted(by2):
    v = by2[k]
    if not ("lg" in v and "lgdp" in v):
        continue
    a, b = v["lg"], v["lgdp"]
    if a.get("union") is None or b.get("union") is None or a.get("max") is None or b.get("max") is None:
        continue
    tot += 1
    if a["union"] <= b["union"] and a["max"] <= b["max"] and (a["union"] < b["union"] or a["max"] < b["max"]):
        fires += 1
print("  two-way rule fires (LG strictly better on at least one, no worse on the other) on %d/%d seed-pairs" % (fires, tot))
