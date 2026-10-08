"""Measure GP's congestion-effort levels 5 and 7 against the shipped default (0).

Levels 2, 3 and 4 modify the wirelength gradient and are on the excluded list. Levels 5, 6 and 7 do
not: level 5 lowers the per-bin density screen on hot RUDY grids so the density penalty itself diffuses
cells out of a wiring hotspot, and level 7 feeds real trial-route overflow back into the solver. The
one dimension iEDA loses is peak congestion, and the signature is that our total overflow is often
BETTER than the reference while the peak is worse - i.e. our overflow is concentrated. Diffusing cells
out of hotspots targets exactly that.

This is reconnaissance: it measures options that already exist and is not an improvement claim.
"""
import json, os, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
sys.path.insert(0, str(W/"ieda/rsi/harness"))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

D = R.load_designs()
os.environ["IEDA_BIN"] = str(R.IEDA_ROOT/"build/bin/iEDA")
ds = [x for x in sys.argv[1].split(",") if x]
arms = [int(x) for x in (sys.argv[2].split(",") if len(sys.argv) > 2 else [0,5])]
out=[]
for d in ds:
    rec = D[d]
    cfg = json.loads(Path(rec["pl_config"]).read_text()); pl = cfg.get("PL", cfg)
    td = float(pl.get("GP",{}).get("Density",{}).get("target_density",0.8))
    mi = int(pl.get("GP",{}).get("Nesterov",{}).get("max_iter",2000))
    for ce in arms:
        wd = R.RUNS/"cesweep"/("%s_ce%d" % (d, ce)); wd.mkdir(parents=True, exist_ok=True)
        gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed 1000"
              " -report_route_util 1 -congestion_effort %d" % (mi, td, ce))
        rc,o,e = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)), Path(rec["pl_config"]),
                            Path(rec["input_def"]), [gp,"placer_run_gp -mode accept","placer_run_lg","placer_run_dp"],
                            def_save=True)
        row={"design":d,"ce":ce,"rc":rc}
        try:
            from gp_metrics_compare import hpwl as ihpwl
            lef = rec.get("lef")
            if lef and (wd/"placement.def").exists(): row["hpwl"]=ihpwl(wd/"placement.def", Path(lef))
        except Exception: pass
        t = R.truth_metrics(wd, rec, with_egr=True)
        row["union"]=t.get("egr_total_overflow_union"); row["max"]=t.get("egr_max_overflow_union")
        out.append(row); print(json.dumps(row), flush=True)
Path(R.RUNS,"cesweep").mkdir(parents=True, exist_ok=True)
Path(R.RUNS,"cesweep","all.json").write_text(json.dumps(out,indent=1))
print("done")
