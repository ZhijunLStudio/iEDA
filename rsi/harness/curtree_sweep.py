"""Measure the current tree (SR-10 + SR-11) on every netlist-matched design.

One command sequence, no selection: the standard gp -> lg -> dp flow with the tool's own guard
inside it. This is the harness being mechanical, as the objective requires.
"""
import json, os, re, subprocess, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
sys.path.insert(0, str(W/"ieda/rsi/harness"))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

D = R.load_designs()
DEF = json.loads((W/"ieda/rsi/harness/designs.local.json").read_text())

def netcount(p):
    if not p or not Path(p).exists(): return None
    r = subprocess.run(["grep","-m1","-E","^NETS ",p], capture_output=True)
    m = re.search(rb"NETS\s+(\d+)", r.stdout); return int(m.group(1)) if m else None

valid=[d for d in DEF if abs((netcount(DEF[d].get("innovus_def")) or 0)-(netcount(DEF[d].get("input_def")) or 0))<=5
       and netcount(DEF[d].get("innovus_def")) and netcount(DEF[d].get("input_def"))]
print("valid designs:", len(valid), flush=True)
os.environ["IEDA_BIN"] = str(R.IEDA_ROOT/"build/bin/iEDA")
out=[]
for d in valid:
    rec=D[d]
    cfg=json.loads(Path(rec["pl_config"]).read_text()); pl=cfg.get("PL",cfg)
    td=float(pl.get("GP",{}).get("Density",{}).get("target_density",0.8))
    mi=int(pl.get("GP",{}).get("Nesterov",{}).get("max_iter",2000))
    wd=R.RUNS/"curtree"/d; wd.mkdir(parents=True,exist_ok=True)
    gp=("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed 1000 -report_route_util 1"%(mi,td))
    rc,o,e=G.run_ieda(wd,Path(rec["case_root"]),Path(R.foundry_of(rec)),Path(rec["pl_config"]),Path(rec["input_def"]),
                      [gp,"placer_run_gp -mode accept","placer_run_lg","placer_run_dp"],def_save=True)
    row={"design":d,"pdk":rec.get("pdk"),"rc":rc}
    try:
        from gp_metrics_compare import hpwl as ihpwl
        row["hpwl"]=ihpwl(wd/"placement.def", Path(rec["ilef"])) if rec.get("ilef") else None
    except Exception: pass
    t=R.truth_metrics(wd,rec,with_egr=True)
    row["union"]=t.get("egr_total_overflow_union"); row["max"]=t.get("egr_max_overflow_union")
    out.append(row); print(json.dumps(row), flush=True)
(W/"runs/curtree").mkdir(parents=True,exist_ok=True)
(W/"runs/curtree/all.json").write_text(json.dumps(out,indent=1))
print("done")
