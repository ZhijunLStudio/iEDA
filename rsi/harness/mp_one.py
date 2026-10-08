import os, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
sys.path.insert(0, str(W/"ieda/rsi/harness")); sys.path.insert(0, str(W/"ieda/benchmarks/flows"))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
from gp_metrics_compare import hpwl as ihpwl
dd = sys.argv[1]
D = R.load_designs(); rec = D[dd]
ref = W/"runs"/"standingB"/dd/"ref"
tr = R.truth_metrics(ref, rec, with_egr=True)
hpr = ihpwl(ref/"placement.def", Path(rec["lef"]))
lines = [dd]
for n in (1,2,3):
    wd = W/"runs"/"passes"/("%s_p%d" % (dd, n))
    if not (wd/"placement.def").exists(): continue
    t = R.truth_metrics(wd, rec, with_egr=True)
    hp = ihpwl(wd/"placement.def", Path(rec["lef"]))
    f = lambda a,b: ("%.3f" % (a/b)) if (a is not None and b) else "-"
    lines.append("   p%d  hpwl %s  union %s  max %s" % (n, f(hp,hpr),
        f(t.get("egr_total_overflow_union"), tr.get("egr_total_overflow_union")),
        f(t.get("egr_max_overflow_union"), tr.get("egr_max_overflow_union"))))
print("\n".join(lines))
