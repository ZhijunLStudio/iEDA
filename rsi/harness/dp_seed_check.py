"""Multi-seed confirmation that DP damages the peak, on the two clearest designs.

The stage-localisation run used one seed. The effects it found (peak 1 -> 4, 34 -> 43) are much
larger than the single-design seed spread, but the direction still has to be shown across seeds
before it is a conclusion rather than a draw.
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

DESIGNS = ["s38584_nangate45_a", "salsa20_ics55_a", "s1238_ics55_a"]
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
        gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed %d"
              " -report_route_util 1" % (mi, td, seed))
        for tag, cmds in (("gplg", [gp, "placer_run_gp -mode accept", "placer_run_lg"]),
                          ("gplgdp", [gp, "placer_run_gp -mode accept", "placer_run_lg", "placer_run_dp"])):
            wd = R.RUNS / "dpseed" / ("%s_%s_s%d" % (d, tag, seed))
            wd.mkdir(parents=True, exist_ok=True)
            rc, o, e = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)),
                                  Path(rec["pl_config"]), Path(rec["input_def"]), cmds, def_save=True)
            t = R.truth_metrics(wd, rec, with_egr=True)
            row = {"design": d, "pdk": rec.get("pdk"), "seed": seed, "stage": tag, "rc": rc,
                   "union": t.get("egr_total_overflow_union"), "max": t.get("egr_max_overflow_union")}
            out.append(row)
            print(json.dumps(row))
            sys.stdout.flush()
Path(R.RUNS, "dpseed").mkdir(parents=True, exist_ok=True)
Path(R.RUNS, "dpseed", "all.json").write_text(json.dumps(out, indent=1))
print("done")
