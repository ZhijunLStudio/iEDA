"""Are the reference values and ours measured in comparable states?

The anchor script scores the commercial DEF with the legalization gate bypassed. Our own numbers come
from a placement that went through legalization. If the two states score differently, the standing is
comparing two different things. This measures the SAME reference DEF both ways on several designs.
"""
import json, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
sys.path.insert(0, str(W/"ieda/rsi/harness"))
sys.path.insert(0, str(W/"ieda/rsi/analysis"))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G
from innovus_anchor import raw_metrics   # the bypass helper the anchor itself used

D = R.load_designs()
A = {x["design"]: x for x in json.loads((W/"ieda/rsi/analysis/out/innovus_anchor.json").read_text())}
print("  %-16s %-22s %-22s | %s" % ("design", "reference, gate bypassed", "reference, legalised", "ratio raw/legalised"))
for d in [x for x in sys.argv[1].split(",") if x]:
    rec = D[d]
    raw = raw_metrics(Path(rec["innovus_def"]), rec, "innovus")
    wd = W/"runs/reflegal"/d
    leg = R.truth_metrics(wd, rec, with_egr=True) if (wd/"placement.def").exists() else {}
    ru, rm = raw.get("egr_total"), raw.get("egr_max")
    lu, lm = leg.get("egr_total_overflow_union"), leg.get("egr_max_overflow_union")
    anchored = (A.get(d, {}) or {}).get("reference") or {}
    print("  %-16s %8s/%-6s %8s | %8s/%-6s %8s | union %.2f  max %.2f   anchor says %s/%s" % (
        d, ru, rm, "", lu, lm, "",
        (ru/lu) if (ru and lu) else 0, (rm/lm) if (rm and lm) else 0,
        anchored.get("egr_total"), anchored.get("egr_max")))
    sys.stdout.flush()
