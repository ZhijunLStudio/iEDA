"""Is the flow reproducible run to run?

The same design, seed, binary and command produced max overflow 43 in one batch and 34 in another.
If the flow is not deterministic then every same-seed comparison in this work is weakened, so this
measures the same configuration several times and reports whether the results are identical.

Two arms: the control binary as-is, and the same binary with OpenMP pinned harder, to see whether
threading is the source.
"""
import json, os, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
sys.path.insert(0, str(W/"ieda/rsi/harness"))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

D = R.load_designs()
d = sys.argv[1]
tag = sys.argv[2]
rep = int(sys.argv[3]) if len(sys.argv) > 3 else 3
rec = D[d]
cfg = json.loads(Path(rec["pl_config"]).read_text()); pl = cfg.get("PL", cfg)
td = float(pl.get("GP",{}).get("Density",{}).get("target_density",0.8))
mi = int(pl.get("GP",{}).get("Nesterov",{}).get("max_iter",2000))
os.environ["IEDA_BIN"] = str(R.IEDA_ROOT/"build/bin/iEDA-clean89")
rows = []
for i in range(rep):
    wd = R.RUNS/"determinism"/("%s_%s_r%d" % (d, tag, i)); wd.mkdir(parents=True, exist_ok=True)
    gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed 1000"
          " -report_route_util 1" % (mi, td))
    rc,o,e = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)), Path(rec["pl_config"]),
                        Path(rec["input_def"]), [gp,"placer_run_gp -mode accept","placer_run_lg","placer_run_dp"],
                        def_save=True)
    t = R.truth_metrics(wd, rec, with_egr=True)
    row = {"design":d,"tag":tag,"rep":i,"union":t.get("egr_total_overflow_union"),
           "max":t.get("egr_max_overflow_union")}
    rows.append(row); print(json.dumps(row), flush=True)
us = [r["union"] for r in rows]; ms = [r["max"] for r in rows]
print("  %s: union %s  max %s  -> %s" % (tag, us, ms, "IDENTICAL" if len(set(us))==1 and len(set(ms))==1 else "VARIES"))
Path(R.RUNS,"determinism").mkdir(parents=True, exist_ok=True)
Path(R.RUNS,"determinism",(d+"_"+tag+".json")).write_text(json.dumps(rows, indent=1))
