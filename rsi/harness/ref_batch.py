"""Legalise the reference for the designs the standing rebuild has not reached.

The reference DEF must be legalised before it can be scored at all, and on some designs that step is the
slow one. This does it for a list of designs, in parallel across processes, so the standing can be
completed without waiting on a single serial chunk.
"""
import json, os, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
os.environ["IEDA_BIN"] = str(W/"ieda/build/bin/iEDA-nosshim")
sys.path.insert(0, str(W/"ieda/rsi/harness")); sys.path.insert(0, str(W/"ieda/benchmarks/flows"))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

D = R.load_designs()
for d in [x for x in sys.argv[1].split(",") if x]:
    rec = D[d]
    wd = W/"runs"/"standingB"/d/"ref"; wd.mkdir(parents=True, exist_ok=True)
    if (wd/"placement.def").exists():
        print("%s ref already present" % d, flush=True); continue
    G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)), Path(rec["pl_config"]),
               Path(rec["innovus_def"]), ["placer_run_lg"], def_save=True)
    print("%s ref done: %s" % (d, (wd/"placement.def").exists()), flush=True)
print("done")
