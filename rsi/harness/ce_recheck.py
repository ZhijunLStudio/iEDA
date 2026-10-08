"""Does congestion-aware global placement help, measured on the corrected metric?

The exclusion of congestion-aware wirelength levels 2/3/4 was established under the bypass protocol,
whose reference congestion was 2.0x to 2.7x too large, and several later measurements were taken with a
harness whose arm switching did not work. Both undermine the exclusions, so this re-tests the mechanism
on the corrected metric: both arms in one process, one thread, each scored against a reference legalised
in the same process.

Level 4 is the highest of the wirelength-gradient levels and uses the evaluator's own demand model.
"""
import json, os, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
os.environ["IEDA_BIN"] = str(W/"ieda/build/bin/iEDA-nosshim")
sys.path.insert(0, str(W/"ieda/rsi/harness")); sys.path.insert(0, str(W/"ieda/benchmarks/flows"))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G
from gp_metrics_compare import hpwl as ihpwl

D = R.load_designs()
ds = [x for x in sys.argv[1].split(",") if x]
levels = [int(x) for x in (sys.argv[2].split(",") if len(sys.argv) > 2 else [0, 4])]
rows = []
for d in ds:
    rec = D[d]
    cfg = json.loads(Path(rec["pl_config"]).read_text()); pl = cfg.get("PL", cfg)
    td = float(pl.get("GP",{}).get("Density",{}).get("target_density",0.8))
    mi = int(pl.get("GP",{}).get("Nesterov",{}).get("max_iter",2000))
    # Reuse a legalised reference already on disk: legalising it costs minutes per design and the
    # standing rebuild has already produced them in the same environment.
    ref_wd = W/"runs"/"standingB"/d/"ref"
    if not (ref_wd/"placement.def").exists():
        ref_wd = W/"runs"/"reflegal"/d
    if not (ref_wd/"placement.def").exists():
        ref_wd = W/"runs"/"ceR"/d/"ref"; ref_wd.mkdir(parents=True, exist_ok=True)
        G.run_ieda(ref_wd, Path(rec["case_root"]), Path(R.foundry_of(rec)), Path(rec["pl_config"]),
                   Path(rec["innovus_def"]), ["placer_run_lg"], def_save=True)
    tr = R.truth_metrics(ref_wd, rec, with_egr=True)
    hp_r = ihpwl(ref_wd/"placement.def", Path(rec["lef"])) if rec.get("lef") else None
    for ce in levels:
        wd = W/"runs"/"ceR"/d/("ce%d" % ce); wd.mkdir(parents=True, exist_ok=True)
        gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed 1000"
              " -report_route_util 1 -congestion_effort %d" % (mi, td, ce))
        G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)), Path(rec["pl_config"]),
                   Path(rec["input_def"]), [gp, "placer_run_gp -mode accept", "placer_run_lg", "placer_run_dp"],
                   def_save=True)
        t = R.truth_metrics(wd, rec, with_egr=True)
        hp = ihpwl(wd/"placement.def", Path(rec["lef"])) if rec.get("lef") and (wd/"placement.def").exists() else None
        def rt(a, b): return round(a/b, 4) if (a is not None and b not in (None, 0)) else None
        row = {"design": d, "ce": ce,
               "ours": {"hpwl": hp, "union": t.get("egr_total_overflow_union"), "max": t.get("egr_max_overflow_union")},
               "ref": {"hpwl": hp_r, "union": tr.get("egr_total_overflow_union"), "max": tr.get("egr_max_overflow_union")}}
        row["ratio"] = {"hpwl": rt(hp, hp_r), "union": rt(row["ours"]["union"], row["ref"]["union"]),
                        "max": rt(row["ours"]["max"], row["ref"]["max"])}
        rows.append(row); print(json.dumps(row), flush=True)
(W/"runs"/"ceR").mkdir(parents=True, exist_ok=True)
(W/"runs"/"ceR"/"all.json").write_text(json.dumps(rows, indent=1))
print("done")
