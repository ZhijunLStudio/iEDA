"""Score the multi-pass runs from their placement files."""
import json, os, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
os.environ["IEDA_BIN"] = str(W/"ieda/build/bin/iEDA-nosshim")
sys.path.insert(0, str(W/"ieda/rsi/harness")); sys.path.insert(0, str(W/"ieda/benchmarks/flows"))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
from gp_metrics_compare import hpwl as ihpwl
D = R.load_designs()
p = W/"runs"/"passes"
res = {}
for d in sorted(os.listdir(p)):
    if not os.path.isdir(p/d): continue
    dd, _, pn = d.rpartition("_p")
    rec = D.get(dd);  lef = rec.get("lef") if rec else None
    ref_wd = W/"runs"/"standingB"/dd/"ref"
    if not rec or not (ref_wd/"placement.def").exists(): continue
    tr = R.truth_metrics(ref_wd, rec, with_egr=True)
    hp_r = ihpwl(ref_wd/"placement.def", Path(lef)) if lef else None
    wd = p/d
    if not (wd/"placement.def").exists(): continue
    t = R.truth_metrics(wd, rec, with_egr=True)
    hp = ihpwl(wd/"placement.def", Path(lef)) if lef else None
    def rr(a,b): return round(a/b,4) if (a is not None and b) else None
    res.setdefault(dd, {})[int(pn)] = {"hpwl": rr(hp,hp_r),
        "union": rr(t.get("egr_total_overflow_union"), tr.get("egr_total_overflow_union")),
        "max": rr(t.get("egr_max_overflow_union"), tr.get("egr_max_overflow_union"))}
for dd in sorted(res):
    print(dd + ":")
    for n in sorted(res[dd]):
        r = res[dd][n]
        print("   passes %d  hpwl %s  union %s  max %s" % (n, r["hpwl"], r["union"], r["max"]))
