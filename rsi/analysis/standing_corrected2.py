"""The standing recomputed with both sides in the same state.

The anchor scored the commercial DEF with the legalization gate bypassed; our numbers come from a
legalized placement. Measuring the same reference DEF both ways shows the gate inflates its total
overflow by 2.0x to 2.7x, so every union ratio in the standing was taken against a number that is far
too large. This legalises the reference with the same procedure we use, scores it, and reports the
corrected standing next to the old one so the size of the correction is visible.

Measurement only - no source change.
"""
import json, re, subprocess, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
sys.path.insert(0, str(W/"ieda/rsi/harness"))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G
from gp_metrics_compare import hpwl as ihpwl

D = R.load_designs()
A = {x["design"]: x for x in json.loads((W/"ieda/rsi/analysis/out/innovus_anchor.json").read_text())}
V = json.loads((W/"runs/curtree/all.json").read_text())[0] and {r["design"]: r for r in json.loads((W/"runs/curtree/all.json").read_text())}
T = {r["design"]: r for r in json.loads((W/"runs/timingbase/merged.json").read_text())}

def netcount(p):
    if not p or not Path(p).exists(): return None
    r = subprocess.run(["grep","-m1","-E","^NETS ",p], capture_output=True)
    m = re.search(rb"NETS\s+(\d+)", r.stdout); return int(m.group(1)) if m else None

valid=[d for d in D if netcount(D[d].get("input_def")) and netcount(D[d].get("innovus_def"))
       and abs(netcount(D[d]["innovus_def"])-netcount(D[d]["input_def"]))<=5]
print("valid designs: %d" % len(valid), flush=True)

out={}
for d in valid:
    rec=D[d]
    wd = W/"runs/reflegal"/d
    wd.mkdir(parents=True, exist_ok=True)
    if not (wd/"placement.def").exists():
        G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)), Path(rec["pl_config"]),
                   Path(rec["innovus_def"]), ["placer_run_lg"], def_save=True)
    t = R.truth_metrics(wd, rec, with_egr=True)
    lef = rec.get("lef")
    hp = ihpwl(wd/"placement.def", Path(lef)) if (lef and (wd/"placement.def").exists()) else None
    out[d]={"ref_hpwl": hp, "ref_union": t.get("egr_total_overflow_union"),
            "ref_max": t.get("egr_max_overflow_union")}
    print("  %-22s ref(lg) hpwl %-12s union %-8s max %-5s" % (d, hp, out[d]["ref_union"], out[d]["ref_max"]), flush=True)

(W/"runs/reflegal/all.json").write_text(json.dumps(out, indent=1))

def ratio(a,b): return (a/b) if (a is not None and b not in (None,0)) else None
print()
print("  %-20s %-9s | %7s %7s %7s | %7s %7s %7s | %s" % (
    "design","PDK","old h","old u","old m","new h","new u","new m","verdict (new)"))
newall=[]; newbad=[]
for d in valid:
    r=out.get(d) or {}
    v=V.get(d) or {}; a=(A.get(d) or {}).get("reference") or {}
    oh=ratio(v.get("hpwl"), a.get("hpwl")); ou=ratio(v.get("egr_union",v.get("union")), a.get("egr_total"))
    om=ratio(v.get("egr_max",v.get("max")), a.get("egr_max"))
    nh=ratio(v.get("hpwl"), r.get("ref_hpwl")); nu=ratio(v.get("egr_union",v.get("union")), r.get("ref_union"))
    nm=ratio(v.get("egr_max",v.get("max")), r.get("ref_max"))
    bad=[k for k,val in (("hpwl",nh),("union",nu),("max",nm)) if val is not None and val>1.0]
    verdict = "ALL" if not bad else "fail: "+",".join(bad)
    if not bad and all(x is not None for x in (nh,nu,nm)): newall.append(d)
    elif bad: newbad.append(d)
    print("  %-20s %-9s | %s | %s | %s" % (d, D[d].get("pdk"),
        " ".join("%6.2f"%x if x is not None else "     -" for x in (oh,ou,om)),
        " ".join("%6.2f"%x if x is not None else "     -" for x in (nh,nu,nm)), verdict))
print()
print("  three-metric all-better:  old %d  ->  NEW %d   %s" % (0, len(newall), newall))
print("  still failing at least one (corrected): %d  %s" % (len(newbad), newbad))
