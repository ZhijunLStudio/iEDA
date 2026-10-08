"""Aggregate the standing from placement files already on disk, measuring both arms in one process.

The chunked rebuild writes its JSON only if the whole chunk finishes, so designs that completed before a
chunk died would otherwise be lost. This reads every design directory that has both arms' placement
files and scores them, so nothing already computed is thrown away.
"""
import json, os, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
os.environ["IEDA_BIN"] = str(W/"ieda/build/bin/iEDA-nosshim")
sys.path.insert(0, str(W/"ieda/rsi/harness"))
sys.path.insert(0, str(W/"ieda/benchmarks/flows"))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
from gp_metrics_compare import hpwl as ihpwl

D = R.load_designs()
base = W/"runs/standingB"
rows = []
for d in sorted(D):
    ours_wd, ref_wd = base/d/"ours", base/d/"ref"
    od, rd = ours_wd/"placement.def", ref_wd/"placement.def"
    if not (od.exists() and rd.exists()):
        continue
    rec = D[d]
    to = R.truth_metrics(ours_wd, rec, with_egr=True)
    tr = R.truth_metrics(ref_wd, rec, with_egr=True)
    lef = rec.get("lef")
    hp_o = ihpwl(od, Path(lef)) if lef else None
    hp_r = ihpwl(rd, Path(lef)) if lef else None
    def rt(a, b): return round(a/b, 4) if (a is not None and b not in (None, 0)) else None
    row = {"design": d, "pdk": rec.get("pdk"),
           "ours": {"hpwl": hp_o, "union": to.get("egr_total_overflow_union"), "max": to.get("egr_max_overflow_union")},
           "ref": {"hpwl": hp_r, "union": tr.get("egr_total_overflow_union"), "max": tr.get("egr_max_overflow_union")}}
    row["ratio"] = {"hpwl": rt(hp_o, hp_r), "union": rt(row["ours"]["union"], row["ref"]["union"]),
                    "max": rt(row["ours"]["max"], row["ref"]["max"])}
    rows.append(row)
    # write after every design so partial results survive a slow or dead run
    (base/"agg.json").write_text(json.dumps(rows, indent=1))
    print(json.dumps(row), flush=True)
(base/"agg.json").write_text(json.dumps(rows, indent=1))
print("aggregated %d designs" % len(rows))
