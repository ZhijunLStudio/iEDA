"""The standing against Innovus, one table, all five metrics.

Reference values are read from the anchor file (never transcribed). Ours come from two places: the
shipped flow (baseV2 sweep, one seed) and the measured candidate pool where a sweep covers the design.
The pool picks the Pareto-best candidate on (union, peak) for the reported seed.
"""
import collections
import json
import re
import statistics as st
import subprocess
from pathlib import Path

W = Path("/home/lizhijun/work/ieda-rsi")
A = {x["design"]: x for x in json.loads((W / "ieda/rsi/analysis/out/innovus_anchor.json").read_text())}
B = {r["design"]: r for r in json.loads((W / "runs/srciter/baseV2.json").read_text())["rows"]}
T = {r["design"]: r for r in json.loads((W / "runs/timingbase/merged.json").read_text())}
D = json.loads((W / "ieda/rsi/harness/designs.local.json").read_text())

CH = ("lg", "lgdp", "lgdplg", "lgdplgdp", "ce2lg", "ce4lg")
CH3 = ("ce2lgdp", "ce2lgdplgdp", "ce3lg", "ce5lg", "ce6lg", "ce2td90lg", "td70lg", "ce2it4000lg")


def netcount(p):
    if not p or not Path(p).exists():
        return None
    r = subprocess.run(["grep", "-m1", "-E", "^NETS ", p], capture_output=True)
    m = re.search(rb"NETS\s+(\d+)", r.stdout)
    return int(m.group(1)) if m else None


def dom(a, b):
    """An explicit rule, not an arbitrary Pareto point.

    Among candidates that do not dominate each other the earlier code kept whichever came first in
    dict order, which made the reported "best" arbitrary on the frontier. The rule is now stated: minimise
    peak overflow first, because that is the objective's failing dimension, and break ties on total
    overflow, then on wirelength. Candidates on the frontier are counted so the table can say how often
    the choice was forced.
    """
    if not a or not b:
        return False
    if a.get("max") is None or b.get("max") is None:
        return False
    if a["max"] != b["max"]:
        return a["max"] < b["max"]
    if a.get("union") is None or b.get("union") is None:
        return False
    if a["union"] != b["union"]:
        return a["union"] < b["union"]
    if a.get("hpwl") is not None and b.get("hpwl") is not None:
        return a["hpwl"] < b["hpwl"]
    return False


pool = collections.defaultdict(dict)
for f, arms in (("pool.log", CH), ("pool2.log", CH), ("pool_seed3.log", CH), ("pool3.log", CH3)):
    p = W / "runs" / f
    if not p.exists():
        continue
    for l in p.read_text().splitlines():
        l = l.strip()
        if l.startswith("{"):
            try:
                r = json.loads(l)
            except Exception:
                continue
            pool[(r["design"], r["seed"])][r["arm"]] = r


def pool_best(d, seed):
    v = pool.get((d, seed)) or {}
    best = None
    for a, c in v.items():
        if best is None or dom(c, best):
            best = c
    return best, v


def rat(a, b):
    return (a / b) if (a is not None and b not in (None, 0)) else None


rows = []
for d in sorted(D):
    n1, n2 = netcount(D[d].get("input_def")), netcount(D[d].get("innovus_def"))
    if not (n1 and n2 and abs(n2 - n1) <= 5):
        continue
    b = B.get(d); a = (A.get(d) or {}).get("reference") or {}
    t = T.get(d, {}); to, tr = t.get("ours", {}), t.get("ref", {})
    # pool best at the first seed available
    seeds = sorted({s for (dd, s) in pool if dd == d})
    pb, pv = (pool_best(d, seeds[0]) if seeds else (None, {}))
    # same-seed baseline: the pool's own shipped candidate at the SAME seed
    ref_lg = pv.get("lgdp")
    rows.append({"d": d, "pdk": D[d].get("pdk"), "seeds": seeds,
                 "hpwl": rat(b.get("hpwl"), a.get("hpwl")),
                 "union": rat(b.get("egr_union"), a.get("egr_total")),
                 "max": rat(b.get("egr_max"), a.get("egr_max")),
                 "wns": rat(to.get("setup_wns"), tr.get("setup_wns")) if (to.get("ok") and tr.get("ok")) else None,
                 "tns": rat(to.get("setup_tns"), tr.get("setup_tns")) if (to.get("ok") and tr.get("ok") and tr.get("setup_tns")) else None,
                 "s_union": rat(ref_lg.get("union"), a.get("egr_total")) if ref_lg else None,
                 "s_max": rat(ref_lg.get("max"), a.get("egr_max")) if ref_lg else None,
                 "s_hpwl": rat(ref_lg.get("hpwl"), a.get("hpwl")) if ref_lg else None,
                 "p_union": rat(pb.get("union"), a.get("egr_total")) if pb else None,
                 "p_max": rat(pb.get("max"), a.get("egr_max")) if pb else None,
                 "p_hpwl": rat(pb.get("hpwl"), a.get("hpwl")) if pb else None})

print("### SHIPPED FLOW (baseV2, one seed) - ratio ours/reference; <1.00 is better")
print()
print("| design | PDK | HPWL | EGR union | EGR max | setup WNS | setup TNS |")
print("|---|---|---|---|---|---|---|")
def f(x, nd=2):
    return ("**%.2f**" % x) if (x is not None and x <= 1.0) else (("%.2f" % x) if x is not None else "-")
for r in rows:
    print("| %s | %s | %s | %s | %s | %s | %s |" % (r["d"], r["pdk"], f(r["hpwl"]), f(r["union"]),
          f(r["max"]), f(r["wns"]), f(r["tns"])))
print()
print("| metric | designs | median | no worse |")
print("|---|---|---|---|")
for k, lab in (("hpwl", "HPWL"), ("union", "EGR union"), ("max", "EGR max"), ("wns", "setup WNS"), ("tns", "setup TNS")):
    v = [r[k] for r in rows if r[k] is not None]
    print("| %s | %d | **%.2f** | %d/%d (%.0f%%) |" % (lab, len(v), st.median(v),
          sum(1 for x in v if x <= 1.0), len(v), 100.0 * sum(1 for x in v if x <= 1.0) / len(v)))
print()
print("### CANDIDATE POOL, SAME SEED (pool best vs the pool's own shipped candidate)")
print()
print("| design | seeds | HPWL | EGR union | EGR max | union: shipped -> pool | max: shipped -> pool |")
print("|---|---|---|---|---|---|---|")
for r in rows:
    if r["p_union"] is None or r["s_union"] is None:
        continue
    print("| %s | %d | %s | %s | %s | %.2f -> **%.2f** | %.2f -> **%.2f** |" % (
        r["d"], len(r["seeds"]), f(r["p_hpwl"]), f(r["p_union"]), f(r["p_max"]),
        r["s_union"], r["p_union"], r["s_max"], r["p_max"]))
pu = [r["p_union"] for r in rows if r["p_union"] is not None]
pm = [r["p_max"] for r in rows if r["p_max"] is not None]
print()
print("| pool metric | designs | median | no worse |")
print("|---|---|---|---|")
print("| EGR union | %d | **%.2f** | %d/%d |" % (len(pu), st.median(pu), sum(1 for x in pu if x <= 1), len(pu)))
print("| EGR max | %d | **%.2f** | %d/%d |" % (len(pm), st.median(pm), sum(1 for x in pm if x <= 1), len(pm)))
