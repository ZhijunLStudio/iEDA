"""Multi-seed confirmation of the SR-11 guard.

The guard's decision is made by the tool from the evaluator's own numbers, so the question the seeds
answer is whether it fires consistently where it should and abstains consistently where it should.
Control and treated are the same source apart from the guard, built from the same commit.
"""
import json
import os
import sys
from pathlib import Path

sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

BIN = {"ctl": R.IEDA_ROOT / "build/bin/iEDA-sr10",
       "grd": R.IEDA_ROOT / "build/bin/iEDA-sr11"}
D = R.load_designs()
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
        for arm, b in BIN.items():
            wd = R.RUNS / "sr11seed" / ("%s_%s_s%d" % (d, arm, seed))
            wd.mkdir(parents=True, exist_ok=True)
            os.environ["IEDA_BIN"] = str(b)
            gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed %d"
                  " -report_route_util 1" % (mi, td, seed))
            rc, o, e = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)),
                                  Path(rec["pl_config"]), Path(rec["input_def"]),
                                  [gp, "placer_run_gp -mode accept", "placer_run_lg", "placer_run_dp"],
                                  def_save=True)
            row = {"design": d, "arm": arm, "seed": seed, "rc": rc}
            lef = R.lef_of(rec)
            try:
                from gp_metrics_compare import hpwl as ihpwl
                if lef and (wd / "placement.def").exists():
                    row["hpwl"] = ihpwl(wd / "placement.def", Path(lef))
            except Exception:
                pass
            t = R.truth_metrics(wd, rec, with_egr=True)
            row["union"] = t.get("egr_total_overflow_union")
            row["max"] = t.get("egr_max_overflow_union")
            out.append(row)
            print(json.dumps(row))
            sys.stdout.flush()
Path(R.RUNS, "sr11seed").mkdir(parents=True, exist_ok=True)
Path(R.RUNS, "sr11seed", "all.json").write_text(json.dumps(out, indent=1))
print("done")
