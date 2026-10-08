"""Generate the EGR map for the reference arm so both sides can be compared cell by cell."""
import json, os, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
os.environ["IEDA_BIN"] = str(W/"ieda/build/bin/iEDA-nosshim")
sys.path.insert(0, str(W/"ieda/rsi/harness")); sys.path.insert(0, str(W/"ieda/benchmarks/flows"))
import rsi_lib as R
D = R.load_designs()
for d in [x for x in sys.argv[1].split(",") if x]:
    rec = D[d]
    wd = W/"runs"/"standingB"/d/"ref"
    if not (wd/"placement.def").exists():
        print("%s: no ref def" % d, flush=True); continue
    R.egr_of(wd, rec, def_path=wd/"placement.def")
    p = wd/"egr_congestion_map/place_egr_union_overflow.csv"
    print("%s map: %s" % (d, p.exists()), flush=True)
print("done")
