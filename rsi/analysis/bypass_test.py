"""Decide which protocol is correct: does the bypass itself change the score?

The anchor scores the commercial DEF with the legalization gate bypassed and gets a total overflow 2.0x
to 2.7x higher than when the same DEF is scored after legalization. Two explanations:
  (a) the commercial DEF is not legal by iEDA's rules, and illegality really costs that much;
  (b) the bypass path evaluates differently, and the inflation is an artefact of the code path.
HPWL is unchanged between the two, so the difference is not simply that cells moved.

This separates the two: score OUR OWN already-legal placement both ways. It is legal by construction, so
under (a) the two paths must agree.
"""
import json, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
sys.path.insert(0, str(W/"ieda/rsi/harness"))
sys.path.insert(0, str(W/"ieda/rsi/analysis"))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
from innovus_anchor import raw_metrics

D = R.load_designs()
print("  %-22s %-24s %-24s | ratio" % ("design", "our legal placement, bypass", "our legal placement, normal"))
for d in [x for x in sys.argv[1].split(",") if x]:
    rec = D[d]
    p = W/"runs/curtree"/d/"placement.def"
    if not p.exists():
        print("  %-22s (missing)" % d); continue
    raw = raw_metrics(p, rec, "ours")
    wd = W/"runs/curtree"/d
    nor = R.truth_metrics(wd, rec, with_egr=True)
    ru, rm = raw.get("egr_total"), raw.get("egr_max")
    nu, nm = nor.get("egr_total_overflow_union"), nor.get("egr_max_overflow_union")
    print("  %-22s %8s/%-8s %8s | %8s/%-8s %8s | u %.2f m %.2f" % (
        d, ru, rm, "", nu, nm, "",
        (ru/nu) if (ru and nu) else 0, (rm/nm) if (rm and nm) else 0))
    sys.stdout.flush()
