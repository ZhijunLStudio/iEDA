import json, subprocess, re
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
DEF = json.loads((W/"ieda/rsi/harness/designs.local.json").read_text())
A = {x["design"]: x for x in json.loads((W/"ieda/rsi/analysis/out/innovus_anchor.json").read_text())}
T = {r["design"]: r for r in json.loads((W/"runs/timingbase/merged.json").read_text())}

def netcount(p):
    if not p or not Path(p).exists(): return None
    r = subprocess.run(["grep","-m1","-E","^NETS ",p], capture_output=True)
    m = re.search(rb"NETS\s+(\d+)", r.stdout); return int(m.group(1)) if m else None

def ratio(a,b):
    if a is None or b in (None,0): return None
    return a/b

DIMS=["hpwl","union","max","wns","tns"]

def table(rows_by_design, title):
    print("=" * 96)
    print(title)
    print("=" * 96)
    print("  %-20s %-9s %7s %7s %7s %7s %7s | %s" % ("design","PDK","hpwl","union","max","wns","tns","verdict"))
    allb=[]; onlymax=[]; multi=[]
    for d in sorted(rows_by_design):
        r=rows_by_design[d]
        meas=[(k,r[k]) for k in DIMS if r[k] is not None]
        bad=[k for k,v in meas if v>1.0]
        if not bad: v="ALL"; allb.append(d)
        elif bad==["max"]: v="only max"; onlymax.append(d)
        else: v="fail: "+",".join(bad); multi.append(d)
        print("  %-20s %-9s %s | %s" % (d, r["pdk"],
            " ".join(("%6.2f"%r[k] if r[k] is not None else "     -") for k in DIMS), v))
    n=len(rows_by_design)
    core=[d for d in rows_by_design if all(rows_by_design[d][k] is not None for k in ("hpwl","union","max"))]
    coreok=[d for d in core if not [k for k in ("hpwl","union","max") if rows_by_design[d][k]>1.0]]
    five=[d for d in rows_by_design if all(rows_by_design[d][k] is not None for k in DIMS)
          and not [k for k in DIMS if rows_by_design[d][k]>1.0]]
    print()
    print("  valid designs:                        %2d" % n)
    print("  every measurable dimension no-worse:  %2d   %s" % (len(allb), allb))
    print("  blocked by EGR max ONLY:              %2d   %s" % (len(onlymax), onlymax))
    print("  blocked by two or more dimensions:    %2d   %s" % (len(multi), multi))
    print("  three-metric core all better:         %2d of %d  %s" % (len(coreok), len(core), coreok))
    print("  all five dimensions all better:       %2d   %s" % (len(five), five))
    return allb, onlymax, coreok

def build(src_rows):
    out={}
    for d, b in src_rows.items():
        rec=DEF.get(d) or {}
        if not (netcount(rec.get("input_def")) and netcount(rec.get("innovus_def"))): continue
        if abs(netcount(rec["innovus_def"])-netcount(rec["input_def"]))>5: continue
        ref=(A.get(d) or {}).get("reference") or {}
        t=T.get(d) or {}
        u = b.get("egr_union", b.get("union"))
        m = b.get("egr_max", b.get("max"))
        out[d]={"pdk":rec.get("pdk"),
                "hpwl":ratio(b.get("hpwl"), ref.get("hpwl")),
                "union":ratio(u, ref.get("egr_total")),
                "max":ratio(m, ref.get("egr_max")),
                "wns":ratio((t.get("ours") or {}).get("setup_wns"), (t.get("ref") or {}).get("setup_wns")),
                "tns":ratio((t.get("ours") or {}).get("setup_tns"), (t.get("ref") or {}).get("setup_tns"))}
    return out

base={r["design"]: r for r in json.loads((W/"runs/srciter/baseV2.json").read_text())["rows"]}
cur={r["design"]: r for r in json.loads((W/"runs/curtree/all.json").read_text())}
table(build(base), "SHIPPED FLOW (baseline, binary c9761dc9)")
table(build(cur),  "CURRENT TREE (SR-10 + SR-11, binary 7845cf63)")
