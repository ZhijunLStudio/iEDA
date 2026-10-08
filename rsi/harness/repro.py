"""Reproducibility of the per-stage wirelength, and of global placement's final overflow.

The same design, configuration, seed and binary gave legalization/global placement wirelength ratios of
1.40 and 1.01 in two different batches. A 40% structural cost that appears in one batch and not another
is not a property of the flow, and the "legalization is the defect" reading rests on it. This measures
the same configuration several times with one binary and reports the spread, at one thread and at eight.
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
d = sys.argv[1]; reps = int(sys.argv[2]); tag = sys.argv[3]
rec = D[d]
cfg = json.loads(Path(rec["pl_config"]).read_text()); pl = cfg.get("PL", cfg)
td = float(pl.get("GP",{}).get("Density",{}).get("target_density",0.8))
mi = int(pl.get("GP",{}).get("Nesterov",{}).get("max_iter",2000))
rows = []
for i in range(reps):
    wd = R.RUNS/"repro"/("%s_%s_r%d" % (d, tag, i)); wd.mkdir(parents=True, exist_ok=True)
    gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed 1000"
          " -report_route_util 1" % (mi, td))
    G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)), Path(rec["pl_config"]),
               Path(rec["input_def"]), [gp,"placer_run_gp -mode accept","placer_run_lg","placer_run_dp"],
               def_save=True)
    j = json.loads((wd/"pl/report/ipl_stage_report.json").read_text())
    g = (j.get("global_placement") or {}).get("hpwl") or 0
    l = (j.get("legalization") or {}).get("hpwl") or 0
    dd = (j.get("detail_placement") or {}).get("hpwl") or 0
    ge = wd/"pl/gp_experiments.jsonl"; ov = None
    if ge.exists(): ov = json.loads(ge.read_text().strip().splitlines()[-1]).get("overflow")
    rows.append((ov, g, l, dd)); print("  %s rep%d ov %-8s gp %-12d lg/gp %.3f dp/lg %.3f" % (
        tag, i, ("%.4f"%ov) if ov is not None else "-", g, (l/g) if g else 0, (dd/l) if l else 0), flush=True)
print("  %s: ov %s | lg/gp %s -> %s" % (tag, [r[0] for r in rows],
      ["%.3f"%((r[2]/r[1]) if r[1] else 0) for r in rows],
      "IDENTICAL" if len(set(r[1] for r in rows))==1 else "VARIES"))
Path(R.RUNS,"repro").mkdir(parents=True, exist_ok=True)
Path(R.RUNS,"repro",(d+"_"+tag+".json")).write_text(json.dumps(rows, indent=1))
