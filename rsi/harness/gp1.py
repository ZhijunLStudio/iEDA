"""Minimal global-placement run, to bisect the cross-batch difference.

bin_check and curtree produce global placement 10717785; repro and sr14_test produce 7364089, on the
same design, config, seed and binary. This is the smallest possible script that runs the same thing, so
that bisecting towards either shape has a starting point. It also dumps the environment the child
inherits, since that is the one thing the harness does not record.
"""
import json, os, sys, subprocess
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
sys.path.insert(0, str(W/"ieda/rsi/harness"))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

print("  nproc:", subprocess.run(["nproc"], capture_output=True).stdout.decode().strip())
for k in ("RSI_CPUSET","RSI_OMP_THREADS","OMP_NUM_THREADS","IEDA_BIN","LD_LIBRARY_PATH","TMPDIR","MALLOC_ARENA_MAX"):
    print("  env %-18s = %s" % (k, os.environ.get(k)))
print("  python:", sys.executable, flush=True)

D = R.load_designs()
d = sys.argv[1]; reps = int(sys.argv[2])
rec = D[d]
cfg = json.loads(Path(rec["pl_config"]).read_text()); pl = cfg.get("PL", cfg)
td = float(pl.get("GP",{}).get("Density",{}).get("target_density",0.8))
mi = int(pl.get("GP",{}).get("Nesterov",{}).get("max_iter",2000))
print("  td=%s mi=%s" % (td, mi), flush=True)
os.environ["IEDA_BIN"] = str(R.IEDA_ROOT/"build/bin/iEDA")
print("  IEDA_BIN now %s md5 %s" % (
    os.environ["IEDA_BIN"],
    subprocess.run(["md5sum", os.environ["IEDA_BIN"]], capture_output=True).stdout.decode().split()[0][:8]), flush=True)
vals = []
for i in range(reps):
    wd = R.RUNS/"gp1"/("%s_r%d" % (d, i)); wd.mkdir(parents=True, exist_ok=True)
    gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed 1000"
          " -report_route_util 1" % (mi, td))
    G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)), Path(rec["pl_config"]),
               Path(rec["input_def"]), [gp,"placer_run_gp -mode accept","placer_run_lg","placer_run_dp"],
               def_save=True)
    j = json.loads((wd/"pl/report/ipl_stage_report.json").read_text())
    g = (j.get("global_placement") or {}).get("hpwl") or 0
    l = (j.get("legalization") or {}).get("hpwl") or 0
    ov = None
    ge = wd/"pl/gp_experiments.jsonl"
    if ge.exists(): ov = json.loads(ge.read_text().strip().splitlines()[-1]).get("overflow")
    vals.append(g)
    print("  rep%d gp %-12d ov %-9s lg/gp %.3f" % (i, g, ("%.4f"%ov) if ov is not None else "-", (l/g) if g else 0), flush=True)
print("  REGIME: %s  (A=7364089, B=10717785)" % ("A" if vals[0] < 9e6 else "B"))
Path(R.RUNS,"gp1").mkdir(parents=True, exist_ok=True)
