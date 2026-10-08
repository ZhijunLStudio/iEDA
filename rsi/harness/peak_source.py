"""For the two robustly peak-failing designs, is the deficit present before detail placement?

SR-11 keeps or reverts detail placement, and it abstains on s1238_sky130_a because the stage helps
there. If the deficit on the robust failures already exists at GP+LG then no guard on detail
placement can close it and the next source change has to target global placement or legalisation.
This measures both stages at three seeds on those two designs.
"""
import json
import os
import sys
from pathlib import Path

sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

D = R.load_designs()
os.environ["IEDA_BIN"] = str(R.IEDA_ROOT / "build/bin/iEDA-sr10")  # no guard, so stages are visible
ds = [x for x in sys.argv[1].split(",") if x]
seeds = [int(x) for x in (sys.argv[2].split(",") if len(sys.argv) > 2 else [1001, 1002, 1003])]
out = []
for d in ds:
    rec = D.get(d)
    if not rec:
        continue
    cfg = json.loads(Path(rec["pl_config"]).read_text())
    pl = cfg.get("PL", cfg)
    td = float(pl.get("GP", {}).get("Density", {}).get("target_density", 0.8))
    mi = int(pl.get("GP", {}).get("Nesterov", {}).get("max_iter", 2000))
    for seed in seeds:
        gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed %d"
              " -report_route_util 1" % (mi, td, seed))
        for tag, tail in (("gplg", ["placer_run_lg"]), ("gplgdp", ["placer_run_lg", "placer_run_dp"])):
            wd = R.RUNS / "peaksrc" / ("%s_%s_s%d" % (d, tag, seed))
            wd.mkdir(parents=True, exist_ok=True)
            rc, o, e = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)),
                                  Path(rec["pl_config"]), Path(rec["input_def"]),
                                  [gp, "placer_run_gp -mode accept"] + tail, def_save=True)
            t = R.truth_metrics(wd, rec, with_egr=True)
            row = {"design": d, "stage": tag, "seed": seed, "rc": rc,
                   "union": t.get("egr_total_overflow_union"), "max": t.get("egr_max_overflow_union")}
            out.append(row)
            print(json.dumps(row))
            sys.stdout.flush()
Path(R.RUNS, "peaksrc").mkdir(parents=True, exist_ok=True)
Path(R.RUNS, "peaksrc", "all.json").write_text(json.dumps(out, indent=1))
print("done")
