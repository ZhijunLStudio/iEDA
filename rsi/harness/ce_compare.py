"""Score ce0 and ce4 against the reference, measuring all three in this process.

The aggregate and the ce scorer were run at different times and their reference numbers differ by up to
15 percent on one design, so this measures the reference, effort 0 and effort 4 for each design inside one
process and reports the comparison. Effort 0 here is a separate run from the standing's; comparing the two
is itself a check on run-to-run stability.
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
agg = {r["design"]: r for r in json.loads((W/"runs/standingB/agg.json").read_text())}
rows = []
for d in [x for x in sys.argv[1].split(",") if x]:
    rec = D[d]; lef = rec.get("lef")
    def score(wd):
        if not (wd/"placement.def").exists(): return None
        t = R.truth_metrics(wd, rec, with_egr=True)
        return {"hpwl": ihpwl(wd/"placement.def", Path(lef)) if lef else None,
                "union": t.get("egr_total_overflow_union"), "max": t.get("egr_max_overflow_union")}
    ref = score(W/"runs"/"standingB"/d/"ref")
    c0 = score(W/"runs"/"ceR"/d/"ce0") or score(W/"runs"/"standingB"/d/"ours")
    c4 = score(W/"runs"/"ceR"/d/"ce4")
    if not (ref and c0 and c4):
        print("  %-20s incomplete" % d, flush=True); continue
    def rr(v, k): return round(v[k]/ref[k], 4) if (v[k] is not None and ref.get(k)) else None
    a = {"hpwl": rr(c0,"hpwl"), "union": rr(c0,"union"), "max": rr(c0,"max")}
    b = {"hpwl": rr(c4,"hpwl"), "union": rr(c4,"union"), "max": rr(c4,"max")}
    s = agg.get(d, {}).get("ratio", {})
    row = {"design": d, "ce0_here": a, "ce4": b, "standing": s,
           "delta": {k: (round(b[k]-a[k], 4) if (a[k] is not None and b[k] is not None) else None) for k in a}}
    rows.append(row)
    print("  %-20s ce0 %s | ce4 %s | d %s | standing %s" % (
        d, json.dumps(a), json.dumps(b), json.dumps(row["delta"]), json.dumps(s)), flush=True)
(W/"runs"/"ceR").mkdir(parents=True, exist_ok=True)
(W/"runs"/"ceR"/"compare.json").write_text(json.dumps(rows, indent=1))
print("scored %d" % len(rows))
