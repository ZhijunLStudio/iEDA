"""Does iterating the pipeline help beyond the two designs tested?

Three passes produced a clean six-of-six win against the reference on s1238_ics55_a and nothing on
s38584_nangate45_a. This runs one pass against three passes at three seeds across the netlist-
matched designs, so the net effect is measured rather than inferred from the two designs that
happened to be picked.
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

DESIGNS = sys.argv[1].split(",") if len(sys.argv) > 1 else []
SEEDS = [int(x) for x in (sys.argv[2].split(",") if len(sys.argv) > 2 else [1001, 1002, 1003])]
ARMS = {"B0": 1, "B4": 3}
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
        for arm, npass in ARMS.items():
            wd = R.RUNS / "conv" / ("%s_%s_s%d" % (d, arm, seed))
            wd.mkdir(parents=True, exist_ok=True)
            gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed %d"
                  " -report_route_util 1" % (mi, td, seed))
            cmds = [gp, "placer_run_gp -mode accept"] + ["placer_run_lg", "placer_run_dp"] * npass
            rc, o, e = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)),
                                  Path(rec["pl_config"]), Path(rec["input_def"]), cmds, def_save=True)
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
Path(R.RUNS, "conv").mkdir(parents=True, exist_ok=True)
Path(R.RUNS, "conv", "all.json").write_text(json.dumps(out, indent=1))
print("done")
