"""Is the trial-route measurement itself repeatable?

The same placement scored twice has given peak ratios of 1.1429 and 1.3143 on salsa20_ics55_a, a 15
percent difference. Every congestion conclusion in this work rests on that number, so this measures the
same placement file several times and reports the spread.
"""
import json, os, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
os.environ["IEDA_BIN"] = str(W/"ieda/build/bin/iEDA-nosshim")
sys.path.insert(0, str(W/"ieda/rsi/harness")); sys.path.insert(0, str(W/"ieda/benchmarks/flows"))
import rsi_lib as R

D = R.load_designs()
d = sys.argv[1]; n = int(sys.argv[2])
rec = D[d]
p = W/"runs"/"standingB"/d/"ours"/"placement.def"
print("  def:", p, "exists:", p.exists())
for i in range(n):
    e = R.egr_of(W/"runs"/"egrrep", rec, def_path=p)
    j = e.get("json") or {}
    print("  rep%d  union %-8s max %-6s (ok=%s)" % (i, j.get("egr_total_overflow_union"),
          j.get("egr_max_overflow_union"), j.get("ok")), flush=True)
