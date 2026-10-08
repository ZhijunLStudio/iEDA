"""Per-stage wirelength for every completed flow run on disk.

The stage report records HPWL after global placement, after legalization and after detail placement. If
legalization reliably inflates wirelength, the flow is paying a structural cost at that stage and then
recovering it downstream, which is a defect in the legalizer rather than in the placer. Reading every
run already on disk costs nothing and shows whether the pattern is general.
"""
import json, re, subprocess
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
A = {x["design"]: x for x in json.loads((W/"ieda/rsi/analysis/out/innovus_anchor.json").read_text())}
REF = json.loads((W/"runs/reflegal/all.json").read_text())

rows = {}
for p in W.glob("runs/*/*/pl/report/ipl_stage_report.json"):
    d = p.parts[-4]
    if d.endswith("_ctl") or d.endswith("_sr13") or re.search(r"_s\d+$", d):
        continue
    try:
        j = json.loads(p.read_text())
    except Exception:
        continue
    g = (j.get("global_placement") or {}).get("hpwl") or 0
    l = (j.get("legalization") or {}).get("hpwl") or 0
    dd = (j.get("detail_placement") or {}).get("hpwl") or 0
    if g and l and dd:
        rows.setdefault(d, []).append((g, l, dd))

def netcount(p):
    if not p or not Path(p).exists(): return None
    r = subprocess.run(["grep","-m1","-E","^NETS ",p], capture_output=True)
    m = re.search(rb"NETS\s+(\d+)", r.stdout); return int(m.group(1)) if m else None

D = json.loads((W/"ieda/rsi/harness/designs.local.json").read_text())
print("  %-22s %12s %12s %12s | %7s %7s %7s | ref(lg)" % (
    "design","GP","LG","DP","lg/gp","dp/lg","dp/gp"))
for d in sorted(rows):
    g, l, dd = rows[d][-1]
    ref = (REF.get(d) or {}).get("ref_hpwl")
    print("  %-22s %12d %12d %12d | %6.2fx %6.2fx %6.2fx | %s" % (
        d, g, l, dd, l/g, dd/l, dd/g, ref))
print()
print("=== summary ===")
rs = []
for d in rows:
    g, l, dd = rows[d][-1]
    rs.append((d, l/g, dd/l))
up = [x for x in rs if x[1] > 1.0]
print("  runs read: %d" % len(rs))
print("  legalization inflates wirelength in %d of %d runs" % (len(up), len(rs)))
print("  median LG/GP = %.3f   median DP/LG = %.3f" % (
    sorted(x[1] for x in rs)[len(rs)//2], sorted(x[2] for x in rs)[len(rs)//2]))
print("  worst LG inflation: %s" % ", ".join("%s %.2fx" % (x[0], x[1]) for x in sorted(rs, key=lambda z:-z[1])[:6]))
