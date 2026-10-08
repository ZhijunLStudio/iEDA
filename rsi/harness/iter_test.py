"""Does global placement stop at its iteration cap without converging, and would more iterations help?

Two designs terminate with overflow 0.123 and 0.128 against a target of 0.1, and those are exactly the
two whose legalization then costs 40% wirelength. This asks whether the placer is still making progress
when it stops - in which case the flow needs a convergence rule - or whether it has plateaued above its
own target - in which case the density mechanism is inadequate and the cap is not the problem.

Diagnostic only; the option is a lever for the question, not a proposed fix.
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
os.environ["IEDA_BIN"] = str(R.IEDA_ROOT/"build/bin/iEDA")

for d in [x for x in sys.argv[1].split(",") if x]:
    rec = D[d]
    cfg = json.loads(Path(rec["pl_config"]).read_text()); pl = cfg.get("PL", cfg)
    td = float(pl.get("GP",{}).get("Density",{}).get("target_density",0.8))
    for it in (2000, 4000, 8000):
        wd = R.RUNS/"itertest"/("%s_it%d" % (d, it)); wd.mkdir(parents=True, exist_ok=True)
        gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed 1000"
              " -report_route_util 1" % (it, td))
        rc,o,e = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)), Path(rec["pl_config"]),
                            Path(rec["input_def"]), [gp,"placer_run_gp -mode accept","placer_run_lg","placer_run_dp"],
                            def_save=True)
        j = json.loads((wd/"pl/report/ipl_stage_report.json").read_text())
        g = (j.get("global_placement") or {}).get("hpwl") or 0
        l = (j.get("legalization") or {}).get("hpwl") or 0
        dd = (j.get("detail_placement") or {}).get("hpwl") or 0
        ge = (wd/"pl/gp_experiments.jsonl")
        ov = None
        if ge.exists():
            last = ge.read_text().strip().splitlines()[-1]
            ov = json.loads(last).get("overflow")
        ref = (REF.get(d) or {}).get("ref_hpwl")
        print("  %-18s iter %-5d gp_overfl %-8s | gp/ref %-6s lg/gp %-6s dp/ref %-6s" % (
            d, it, ("%.4f"%ov) if ov is not None else "-",
            ("%.2f"%(g/ref)) if ref else "-", ("%.2f"%(l/g)) if g else "-", ("%.2f"%(dd/ref)) if ref else "-"),
            flush=True)
Path(R.RUNS,"itertest").mkdir(parents=True, exist_ok=True)
