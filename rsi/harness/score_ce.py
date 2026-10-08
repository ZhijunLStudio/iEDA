"""Score the congestion-effort DEFs that are already on disk.

The re-check script runs the two efforts and then measures; the runs are done for two designs but its
rows have not been written, so this scores the placement files directly against the same legalised
references the standing uses, inside one process.
"""
import json, os, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
os.environ["IEDA_BIN"] = str(W/"ieda/build/bin/iEDA-nosshim")
sys.path.insert(0, str(W/"ieda/rsi/harness")); sys.path.insert(0, str(W/"ieda/benchmarks/flows"))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
from gp_metrics_compare import hpwl as ihpwl

D = R.load_designs()
def rt(a, b): return round(a/b, 4) if (a is not None and b not in (None, 0)) else None
print("  %-20s %-5s %-22s %s" % ("design", "ce", "hpwl / union / max vs ref", "vs ce0"))
for d in [x for x in sys.argv[1].split(",") if x]:
    rec = D[d]
    ref_wd = W/"runs"/"standingB"/d/"ref"
    tr = R.truth_metrics(ref_wd, rec, with_egr=True)
    hp_r = ihpwl(ref_wd/"placement.def", Path(rec["lef"])) if rec.get("lef") else None
    ru, rm = tr.get("egr_total_overflow_union"), tr.get("egr_max_overflow_union")
    base = None
    for ce in [0, 4]:
        wd = W/"runs"/"ceR"/d/("ce%d" % ce)
        if not (wd/"placement.def").exists():
            print("  %-20s %-5d (not run)" % (d, ce)); continue
        t = R.truth_metrics(wd, rec, with_egr=True)
        hp = ihpwl(wd/"placement.def", Path(rec["lef"])) if rec.get("lef") else None
        u, m = t.get("egr_total_overflow_union"), t.get("egr_max_overflow_union")
        cur = {"hpwl": rt(hp, hp_r), "union": rt(u, ru), "max": rt(m, rm)}
        delta = ""
        if base is not None:
            delta = "dHPWL %+d%%  dunion %+d  dmax %+d" % (
                (cur["hpwl"]/base["hpwl"] - 1)*100 if (cur["hpwl"] and base["hpwl"]) else 0,
                (u - base_u) if u is not None and base_u is not None else 0,
                (m - base_m) if m is not None and base_m is not None else 0)
        else:
            base, base_u, base_m = cur, u, m
        print("  %-20s %-5d %6s %6s %6s   %s" % (d, ce, cur["hpwl"], cur["union"], cur["max"], delta), flush=True)
