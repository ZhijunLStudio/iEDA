"""Three seeds on the pipeline variants, same seeds for both arms.

A single seed showed "gp lg dp lg dp" cutting the peak on s38584_nangate45_a from 4 to 2, tying the
reference, while worsening it on two other designs. Given the measured seed spread on this metric,
the direction has to be established across seeds before it means anything.
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

PASSES = {"B0": 1, "B2": 2, "B4": 3}
ARMS = {k: ["placer_run_lg", "placer_run_dp"] * n for k, n in PASSES.items()}
DESIGNS = ["s1238_ics55_a", "s38584_nangate45_a"]
SEEDS = [1001, 1002, 1003]
D = R.load_designs()
out = []
for d in DESIGNS:
    rec = D.get(d)
    if not rec:
        continue
    cfg = json.loads(Path(rec["pl_config"]).read_text())
    pl = cfg.get("PL", cfg)
    td = float(pl.get("GP", {}).get("Density", {}).get("target_density", 0.8))
    mi = int(pl.get("GP", {}).get("Nesterov", {}).get("max_iter", 2000))
    for seed in SEEDS:
        for arm, tail in ARMS.items():
            wd = R.RUNS / "postdps" / ("%s_%s_s%d" % (d, arm, seed))
            wd.mkdir(parents=True, exist_ok=True)
            gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed %d"
                  " -report_route_util 1" % (mi, td, seed))
            rc, o, e = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)),
                                  Path(rec["pl_config"]), Path(rec["input_def"]),
                                  [gp, "placer_run_gp -mode accept"] + tail, def_save=True)
            row = {"design": d, "pdk": rec.get("pdk"), "arm": arm, "seed": seed, "rc": rc}
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
Path(R.RUNS, "postdps").mkdir(parents=True, exist_ok=True)
Path(R.RUNS, "postdps", "all.json").write_text(json.dumps(out, indent=1))
print("done")
