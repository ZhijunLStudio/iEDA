import json, os, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
sys.path.insert(0, str(W/"ieda/rsi/harness")); sys.path.insert(0, str(W/"ieda/benchmarks/flows"))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
from gp_metrics_compare import hpwl as ihpwl
D = R.load_designs()
out = []
for dd in ["gcd_ics55_a","s5378_sky130_b","picorv32","s38584_ics55_a","salsa20_ics55_a"]:
    rec = D[dd]; ref = W/"runs"/"standingB"/dd/"ref"
    if not (ref/"placement.def").exists():
        out.append("%s no-ref" % dd); continue
    tr = R.truth_metrics(ref, rec, with_egr=True)
    hpr = ihpwl(ref/"placement.def", Path(rec["lef"])) if rec.get("lef") else None
    out.append(dd)
    for n in (1,2,3):
        wd = W/"runs"/"passes"/("%s_p%d" % (dd, n))
        if not (wd/"placement.def").exists(): continue
        t = R.truth_metrics(wd, rec, with_egr=True)
        hp = ihpwl(wd/"placement.def", Path(rec["lef"])) if rec.get("lef") else None
        def f(a, b): return ("%.3f" % (a/b)) if (a is not None and b) else "-"
        out.append("   p%d  hpwl %s  union %s  max %s" % (n, f(hp, hpr),
            f(t.get("egr_total_overflow_union"), tr.get("egr_total_overflow_union")),
            f(t.get("egr_max_overflow_union"), tr.get("egr_max_overflow_union"))))
Path("/tmp/mp_out.txt").write_text("\n".join(out))
print("written")
