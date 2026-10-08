"""Which binary reproduces the global placement that produced the 40% legalization cost?

The same design, configuration and seed gave global-placement wirelength 10,717,785 in the current-tree
sweep and 7,364,089 in five fresh runs, and the flow is deterministic in both. The two batches used
different binaries - the sweep predates the removal of the detail-placement demand estimator - so this
measures both binaries and reports the global-placement wirelength each produces.
"""
import json, os, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
sys.path.insert(0, str(W/"ieda/rsi/harness"))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

D = R.load_designs()
BINS = {}
for spec in sys.argv[3].split(","):
    name, path = spec.split("=")
    BINS[name] = R.IEDA_ROOT/("build/bin/" + path)
d = sys.argv[1]; reps = int(sys.argv[2])
rec = D[d]
cfg = json.loads(Path(rec["pl_config"]).read_text()); pl = cfg.get("PL", cfg)
td = float(pl.get("GP",{}).get("Density",{}).get("target_density",0.8))
mi = int(pl.get("GP",{}).get("Nesterov",{}).get("max_iter",2000))
for arm, b in BINS.items():
    md5 = os.popen("md5sum %s" % b).read().split()[0]
    vals = []
    for i in range(reps):
        wd = R.RUNS/"bincheck"/("%s_%s_r%d" % (d, arm, i)); wd.mkdir(parents=True, exist_ok=True)
        os.environ["IEDA_BIN"] = str(b)
        gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed 1000"
              " -report_route_util 1" % (mi, td))
        G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)), Path(rec["pl_config"]),
                   Path(rec["input_def"]), [gp,"placer_run_gp -mode accept","placer_run_lg","placer_run_dp"],
                   def_save=True)
        j = json.loads((wd/"pl/report/ipl_stage_report.json").read_text())
        g = (j.get("global_placement") or {}).get("hpwl") or 0
        l = (j.get("legalization") or {}).get("hpwl") or 0
        vals.append(g)
        print("  %-5s %s rep%d gp %-12d lg/gp %.3f" % (arm, md5[:8], i, g, (l/g) if g else 0), flush=True)
    print("  -> %-5s global placement values: %s" % (arm, sorted(set(vals))))
Path(R.RUNS,"bincheck").mkdir(parents=True, exist_ok=True)
