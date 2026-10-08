"""SR-14: does keeping the solver alive past step-length stagnation help?

Control is the same source without SR-14 (f9581627); treated is 0c50cc35. The prediction from the
mechanism is specific: on the two designs whose global placement exits at overflow 1.23x and 1.28x
target it should lower that overflow and therefore lower legalization's wirelength cost, and on
designs that already reach the target it should change nothing. A prediction that specific is worth
testing as much for the controls as for the targets.
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
BIN = {"ctl": R.IEDA_ROOT/"build/bin/iEDA-clean89", "sr14": R.IEDA_ROOT/"build/bin/iEDA-sr14"}
for d in [x for x in sys.argv[1].split(",") if x]:
    rec = D[d]
    cfg = json.loads(Path(rec["pl_config"]).read_text()); pl = cfg.get("PL", cfg)
    td = float(pl.get("GP",{}).get("Density",{}).get("target_density",0.8))
    mi = int(pl.get("GP",{}).get("Nesterov",{}).get("max_iter",2000))
    ref = (REF.get(d) or {}).get("ref_hpwl")
    line = ["  %-20s" % d]
    for arm, b in BIN.items():
        wd = R.RUNS/"sr14"/("%s_%s" % (d, arm)); wd.mkdir(parents=True, exist_ok=True)
        os.environ["IEDA_BIN"] = str(b)
        gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed 1000"
              " -report_route_util 1" % (mi, td))
        G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)), Path(rec["pl_config"]),
                   Path(rec["input_def"]), [gp,"placer_run_gp -mode accept","placer_run_lg","placer_run_dp"],
                   def_save=True)
        j = json.loads((wd/"pl/report/ipl_stage_report.json").read_text())
        g = (j.get("global_placement") or {}).get("hpwl") or 0
        l = (j.get("legalization") or {}).get("hpwl") or 0
        dd = (j.get("detail_placement") or {}).get("hpwl") or 0
        ge = wd/"pl/gp_experiments.jsonl"
        ov = None
        if ge.exists():
            ov = json.loads(ge.read_text().strip().splitlines()[-1]).get("overflow")
        line.append("%s ov %-8s lg/gp %-5s dp/ref %-5s" % (
            arm, ("%.4f"%ov) if ov is not None else "-", ("%.2f"%(l/g)) if g else "-",
            ("%.2f"%(dd/ref)) if ref else "-"))
    print(" | ".join(line), flush=True)
Path(R.RUNS,"sr14").mkdir(parents=True, exist_ok=True)
print("done")
