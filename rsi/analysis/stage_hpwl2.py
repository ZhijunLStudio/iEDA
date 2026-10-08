"""Stage wirelength for the shipped configuration only, one run per valid design.

The previous pass read every run on disk including experimental arms and reported a median, which hid
the per-design picture. This reads the current-tree sweep, which is the standard flow at the shipped
configuration, and puts each stage next to the legalised reference.
"""
import json, re, subprocess
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
REF = json.loads((W/"runs/reflegal/all.json").read_text())
D = json.loads((W/"ieda/rsi/harness/designs.local.json").read_text())

def netcount(p):
    if not p or not Path(p).exists(): return None
    r = subprocess.run(["grep","-m1","-E","^NETS ",p], capture_output=True)
    m = re.search(rb"NETS\s+(\d+)", r.stdout); return int(m.group(1)) if m else None

def stage(d):
    p = W/"runs/curtree"/d/"pl/report/ipl_stage_report.json"
    if not p.exists(): return None
    j = json.loads(p.read_text())
    return ((j.get("global_placement") or {}).get("hpwl") or 0,
            (j.get("legalization") or {}).get("hpwl") or 0,
            (j.get("detail_placement") or {}).get("hpwl") or 0)

print("  %-22s %12s %12s %12s | %6s %6s | %7s %7s %7s" % (
    "design","GP","LG","DP","lg/gp","dp/lg","gp/ref","lg/ref","dp/ref"))
rs=[]
for d in sorted(D):
    if not (netcount(D[d].get("input_def")) and netcount(D[d].get("innovus_def"))): continue
    if abs(netcount(D[d]["innovus_def"])-netcount(D[d]["input_def"]))>5: continue
    s = stage(d); ref = (REF.get(d) or {}).get("ref_hpwl")
    if not (s and ref): continue
    g,l,dd = s
    rs.append((d, l/g, dd/l, g/ref, l/ref, dd/ref))
    print("  %-22s %12d %12d %12d | %5.2fx %5.2fx | %6.2fx %6.2fx %6.2fx" % (
        d, g, l, dd, l/g, dd/l, g/ref, l/ref, dd/ref))
print()
import statistics as st
print("  n=%d  median lg/gp %.3f  median dp/lg %.3f" % (len(rs), st.median(x[1] for x in rs), st.median(x[2] for x in rs)))
print("  median gp/ref %.3f   median lg/ref %.3f   median dp/ref %.3f" % (
    st.median(x[3] for x in rs), st.median(x[4] for x in rs), st.median(x[5] for x in rs)))
print("  worst dp/ref: %s" % ", ".join("%s %.2f" % (x[0], x[5]) for x in sorted(rs, key=lambda z:-z[5])[:5]))
print("  worst lg/gp:  %s" % ", ".join("%s %.2f" % (x[0], x[1]) for x in sorted(rs, key=lambda z:-z[1])[:5]))
