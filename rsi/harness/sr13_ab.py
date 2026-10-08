"""SR-13 against a commit-matched control: does reverting on any peak worsening help?

Control is the same source with SR-11's permissive rule (peak worse AND total not better); treated is
SR-13 (peak worse, full stop). Both contain SR-10. Multi-seed, same-seed pairing, and each result is
reported against the legalised reference so the standing is read in the corrected protocol.
"""
import json, os, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
sys.path.insert(0, str(W/"ieda/rsi/harness"))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G
from gp_metrics_compare import hpwl as ihpwl

D = R.load_designs()
REF = json.loads((W/"runs/reflegal/all.json").read_text())
BIN = {"ctl": R.IEDA_ROOT/"build/bin/iEDA-clean89", "sr13": R.IEDA_ROOT/"build/bin/iEDA-sr13"}
ds = [x for x in sys.argv[1].split(",") if x]
seeds = [int(x) for x in sys.argv[2].split(",")]
out = []
for d in ds:
    rec = D[d]
    cfg = json.loads(Path(rec["pl_config"]).read_text()); pl = cfg.get("PL", cfg)
    td = float(pl.get("GP",{}).get("Density",{}).get("target_density",0.8))
    mi = int(pl.get("GP",{}).get("Nesterov",{}).get("max_iter",2000))
    for seed in seeds:
        for arm, b in BIN.items():
            wd = R.RUNS/"sr13"/("%s_%s_s%d" % (d, arm, seed)); wd.mkdir(parents=True, exist_ok=True)
            os.environ["IEDA_BIN"] = str(b)
            gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed %d"
                  " -report_route_util 1" % (mi, td, seed))
            rc,o,e = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)), Path(rec["pl_config"]),
                                Path(rec["input_def"]), [gp,"placer_run_gp -mode accept","placer_run_lg","placer_run_dp"],
                                def_save=True)
            t = R.truth_metrics(wd, rec, with_egr=True)
            row = {"design":d,"arm":arm,"seed":seed,"rc":rc,
                   "union":t.get("egr_total_overflow_union"), "max":t.get("egr_max_overflow_union")}
            lef = rec.get("lef")
            if lef and (wd/"placement.def").exists(): row["hpwl"] = ihpwl(wd/"placement.def", Path(lef))
            out.append(row); print(json.dumps(row), flush=True)
Path(R.RUNS,"sr13").mkdir(parents=True, exist_ok=True)
Path(R.RUNS,"sr13","all.json").write_text(json.dumps(out, indent=1))
print("done")
