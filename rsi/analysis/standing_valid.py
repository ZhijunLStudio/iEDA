"""Standing restricted to designs whose reference is the SAME netlist.

Found while investigating a wirelength anomaly on salsa20_sky130_a: the reference DEFs in
assets/innovus_rebuild are not always the same netlist as our input. On 17 of 24 sky130
designs the net counts differ, in most cases because the reference has FEWER nets than we do.
All ics55 and nangate45 references match exactly.

If the reference genuinely has fewer cells to place, then a raw HPWL or congestion ratio
against it is not like for like, and the direction of the error is against us - it makes the
reference look better than it is. That does not invalidate the comparison, but it means the
valid subset has to be reported separately.
"""
import json, os, re, statistics as st, subprocess, sys
from pathlib import Path

W = "/home/lizhijun/work/ieda-rsi"
D = json.loads(Path(W + "/ieda/rsi/harness/designs.local.json").read_text())
B = {r["design"]: r for r in json.loads(Path(W + "/runs/srciter/baseV2.json").read_text())["rows"]}
A = {x["design"]: x for x in json.loads(Path(W + "/ieda/rsi/analysis/out/innovus_anchor.json").read_text())}
T = {r["design"]: r for r in json.loads(Path(W + "/runs/timingbase/merged.json").read_text())}


def netcount(p):
    if not p or not os.path.exists(p):
        return None
    r = subprocess.run(["grep", "-m1", "-E", "^NETS ", p], capture_output=True)
    m = re.search(rb"NETS\s+(\d+)", r.stdout)
    return int(m.group(1)) if m else None


def rat(a, b):
    return (a / b) if (a is not None and b not in (None, 0)) else None


rows = []
for d in sorted(D):
    rec = D[d]
    a, b = netcount(rec.get("input_def")), netcount(rec.get("innodus_def") or rec.get("innovus_def"))
    if a is None or b is None:
        continue
    bb = B.get(d)
    aa = (A.get(d) or {}).get("reference") or {}
    t = T.get(d, {})
    to, tr = t.get("ours", {}), t.get("ref", {})
    rows.append({
        "design": d, "pdk": rec.get("pdk"), "dnets": b - a, "valid": abs(b - a) <= 5,
        "hpwl": rat(bb.get("hpwl"), aa.get("hpwl")) if bb else None,
        "union": rat(bb.get("egr_union"), aa.get("egr_total")) if bb else None,
        "max": rat(bb.get("egr_max"), aa.get("egr_max")) if bb else None,
        "wns": rat(to.get("setup_wns"), tr.get("setup_wns")) if (to.get("ok") and tr.get("ok")) else None,
        "tns": rat(to.get("setup_tns"), tr.get("setup_tns")) if (to.get("ok") and tr.get("ok") and tr.get("setup_tns")) else None,
    })

print("rows:", len(rows))


def summ(rs, label):
    print("=== %s (n=%d) ===" % (label, len(rs)))
    for k, lab in (("hpwl", "HPWL"), ("union", "EGR union"), ("max", "EGR max"),
                   ("wns", "setup WNS"), ("tns", "setup TNS")):
        v = [r[k] for r in rs if r[k] is not None]
        if not v:
            continue
        print("  %-10s n=%-3d median %.3f   no-worse %d/%d (%.0f%%)" % (
            lab, len(v), st.median(v), sum(1 for x in v if x <= 1.0), len(v),
            100.0 * sum(1 for x in v if x <= 1.0) / len(v)))
    print()


summ(rows, "ALL designs")
summ([r for r in rows if r["valid"]], "NETLIST-MATCHED only (valid comparison)")
print("=== the valid set ===")
for r in [x for x in rows if x["valid"]]:
    f = lambda v: ("%.2f" % v) if v is not None else "-"
    print("  %-22s %-10s dnets=%-6d hpwl %s union %s max %s wns %s tns %s" % (
        r["design"], r["pdk"], r["dnets"], f(r["hpwl"]), f(r["union"]), f(r["max"]), f(r["wns"]), f(r["tns"])))
