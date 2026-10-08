"""Corrected standing, read entirely from the authoritative anchor file.

An earlier analysis script hard-coded a reference union for salsa20_ics55_a as 3407, which is
s38584_ics55_a's value; the true reference is 54296, so that design was reported as losing total
overflow by 12.5x when it actually wins by 0.78x. Nothing here is hard-coded: every reference value
is read from innovus_anchor.json, and the netlist-integrity filter is applied as before.
"""
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


def netcount(p):
    if not p or not Path(p).exists():
        return None
    r = subprocess.run(["grep", "-m1", "-E", "^NETS ", p], capture_output=True)
    m = re.search(rb"NETS\s+(\d+)", r.stdout)
    return int(m.group(1)) if m else None


def rat(a, b):
    return (a / b) if (a is not None and b not in (None, 0)) else None


rows = []
for d in sorted(D):
    rec = D[d]
    n1, n2 = netcount(rec.get("input_def")), netcount(rec.get("innovus_def"))
    valid = (n1 is not None and n2 is not None and abs(n2 - n1) <= 5)
    b = B.get(d)
    a = (A.get(d) or {}).get("reference") or {}
    if not b or not a.get("egr_max"):
        continue
    t = T.get(d, {})
    to, tr = t.get("ours", {}), t.get("ref", {})
    rows.append({
        "design": d, "pdk": rec.get("pdk"), "valid": valid, "dnets": (n2 - n1) if (n1 and n2) else None,
        "hpwl": rat(b.get("hpwl"), a.get("hpwl")),
        "union": rat(b.get("egr_union"), a.get("egr_total")) if b.get("egr_union") is not None else None,
        "max": rat(b.get("egr_max"), a.get("egr_max")) if b.get("egr_max") is not None else None,
        "wns": rat(to.get("setup_wns"), tr.get("setup_wns")) if (to.get("ok") and tr.get("ok")) else None,
        "tns": rat(to.get("setup_tns"), tr.get("setup_tns")) if (to.get("ok") and tr.get("ok") and tr.get("setup_tns")) else None,
    })

print("=== CORRECTED standing, valid (netlist-matched) designs ===")
print("  %-22s %-10s %7s %7s | %7s %7s %7s %7s" % ("design", "pdk", "dnets", "hpwl", "union", "max", "wns", "tns"))
V = [r for r in rows if r["valid"]]
for r in sorted(V, key=lambda z: (z["pdk"], z["design"])):
    f = lambda k: ("%.2f" % r[k]) if r[k] is not None else "-"
    print("  %-22s %-10s %7s %7s | %7s %7s %7s %7s" % (
        r["design"], r["pdk"], r["dnets"], f("hpwl"), f("union"), f("max"), f("wns"), f("tns")))
print()
for k, lab in (("hpwl", "HPWL"), ("union", "EGR union"), ("max", "EGR max"), ("wns", "setup WNS"), ("tns", "setup TNS")):
    v = [r[k] for r in V if r[k] is not None]
    if v:
        print("  %-10s n=%-3d median %.3f   no-worse %d/%d (%.0f%%)" % (
            lab, len(v), st.median(v), sum(1 for x in v if x <= 1.0), len(v),
            100.0 * sum(1 for x in v if x <= 1.0) / len(v)))
print()
print("  same, over ALL %d designs with a reference (validity not filtered):" % len(rows))
for k, lab in (("hpwl", "HPWL"), ("union", "EGR union"), ("max", "EGR max"), ("wns", "setup WNS")):
    v = [r[k] for r in rows if r[k] is not None]
    if v:
        print("  %-10s n=%-3d median %.3f   no-worse %d/%d (%.0f%%)" % (
            lab, len(v), st.median(v), sum(1 for x in v if x <= 1.0), len(v),
            100.0 * sum(1 for x in v if x <= 1.0) / len(v)))
print()
print("=== designs where EGR max is worse, with the other four dimensions ===")
for r in sorted([x for x in V if x["max"] and x["max"] > 1.0], key=lambda z: -z["max"]):
    f = lambda k: ("%.2f" % r[k]) if r[k] is not None else "-"
    print("  %-22s %-10s max %s | hpwl %s union %s wns %s tns %s" % (
        r["design"], r["pdk"], f("max"), f("hpwl"), f("union"), f("wns"), f("tns")))
