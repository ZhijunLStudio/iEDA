"""Net effect of the Pareto LG-vs-LG+DP rule, against the reference and against always running DP.

Reads every pareto sweep log. For each (design, seed) it has the LG placement and the LG+DP
placement from the same global placement, so the only difference is whether detail placement ran.
The rule takes LG when it is no worse on BOTH total and peak overflow, else DP. Reported against
(a) the reference and (b) the shipped flow, which always takes DP.
"""
import collections
import json
import statistics as st
import sys
from pathlib import Path

W = Path("/home/lizhijun/work/ieda-rsi")
A = {x["design"]: x for x in json.loads((W / "ieda/rsi/analysis/out/innovus_anchor.json").read_text())}

rows = []
for f in ("pareto.log", "pareto2.log"):
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

print("  %-20s %5s %8s %8s %5s %5s | %9s %9s | %-4s | ref u/max" % (
    "design", "seed", "u_LG", "u_DP", "p_LG", "p_DP", "rule_u", "rule_p", "pick"))
picks = collections.Counter()
gain_u = []; gain_p = []
rowsout = []
for k in sorted(by):
    v = by[k]
    a, b = v.get("lg"), v.get("lgdp")
    if not (a and b):
        continue
    if a.get("union") is None or b.get("union") is None or a.get("max") is None or b.get("max") is None:
        continue
    pareto = a["union"] <= b["union"] and a["max"] <= b["max"]
    pick = "LG" if pareto else "DP"
    picks[pick] += 1
    ru, rp = (a["union"], a["max"]) if pick == "LG" else (b["union"], b["max"])
    ref = (A.get(k[0], {}) or {}).get("reference") or {}
    gain_u.append(ru - b["union"]); gain_p.append(rp - b["max"])
    rowsout.append((k[0], k[1], ru, rp, ref.get("egr_total"), ref.get("egr_max")))
    print("  %-20s %5d %8d %8d %5d %5d | %9d %9d | %-4s | %s/%s" % (
        k[0], k[1], a["union"], b["union"], a["max"], b["max"], ru, rp, pick,
        ref.get("egr_total"), ref.get("egr_max")))

print()
print("  picks: %s" % dict(picks))
if gain_u:
    print("  median change from the rule vs always-DP: union %+.1f, peak %+.1f" % (
        st.median(gain_u), st.median(gain_p)))
    print("  rule improves union on %d/%d and peak on %d/%d" % (
        sum(1 for x in gain_u if x < 0), len(gain_u), sum(1 for x in gain_p if x < 0), len(gain_p)))
print()
print("=== how the rule changes the standing against the reference ===")
print("  %-20s %5s | %9s %9s | %9s %9s | %9s %9s" % (
    "design", "seed", "DP u/ref", "P u/ref", "DP peak/ref", "P peak/ref", "", ""))
for (d, s, ru, rp, refu, refm) in rowsout:
    if not refu or not refm:
        continue
    b = by[(d, s)]["lgdp"]
    print("  %-20s %5d | %9.2f %9.2f | %9.2f %9.2f" % (
        d, s, b["union"] / refu, ru / refu, b["max"] / refm, rp / refm))
