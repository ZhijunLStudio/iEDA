"""Run congestion-aware global placement (effort 4) for a design list.

The effort-0 side is already measured: it is the standing, and it is the same binary, seed and
configuration apart from this flag. Offering the congestion evaluator inside the Nesterov loop makes each
run take tens of minutes instead of one, so this writes only its own placements.
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
ce = int(sys.argv[2]) if len(sys.argv) > 2 else 4
for d in [x for x in sys.argv[1].split(",") if x]:
    rec = D[d]
    wd = W/"runs"/"ceR"/d/("ce%d" % ce); wd.mkdir(parents=True, exist_ok=True)
    if (wd/"placement.def").exists():
        print("%s ce%d already present" % (d, ce), flush=True); continue
    cfg = json.loads(Path(rec["pl_config"]).read_text()); pl = cfg.get("PL", cfg)
    td = float(pl.get("GP",{}).get("Density",{}).get("target_density",0.8))
    mi = int(pl.get("GP",{}).get("Nesterov",{}).get("max_iter",2000))
    gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed 1000"
          " -report_route_util 1 -congestion_effort %d" % (mi, td, ce))
    G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)), Path(rec["pl_config"]),
               Path(rec["input_def"]), [gp, "placer_run_gp -mode accept", "placer_run_lg", "placer_run_dp"],
               def_save=True)
    print("%s ce%d done: %s" % (d, ce, (wd/"placement.def").exists()), flush=True)
print("done")
