"""Multi-seed confirmation that disabling the instance-swap operator removes the peak deficit.

Single-seed ablation localised the damage to instance swap (and row optimisation) on the ics55 and
nangate45 designs, with no effect from local reorder. This repeats the swap ablation at three
seeds against the same binary, so the conclusion does not rest on one trajectory.
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
ARMS = {"base": {}, "no_swap": {"enable_instance_swap": 0}}
D = R.load_designs()
out = []
for d in DESIGNS:
    rec = D.get(d)
    if not rec:
        continue
    for seed in SEEDS:
        for arm, patch in ARMS.items():
            wd = R.RUNS / "dpswap" / ("%s_%s_s%d" % (d, arm, seed))
            wd.mkdir(parents=True, exist_ok=True)
            c = json.loads(Path(rec["pl_config"]).read_text())
            p2 = c.get("PL", c)
            td = float(p2.get("GP", {}).get("Density", {}).get("target_density", 0.8))
            mi = int(p2.get("GP", {}).get("Nesterov", {}).get("max_iter", 2000))
            p2.setdefault("DP", {}).update(patch)
            cf = wd / "pl_config_patched.json"
            cf.write_text(json.dumps(c, indent=2))
            gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed %d"
                  " -report_route_util 1" % (mi, td, seed))
            rc, o, e = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)),
                                  cf, Path(rec["input_def"]),
                                  [gp, "placer_run_gp -mode accept", "placer_run_lg", "placer_run_dp"],
                                  def_save=True)
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
Path(R.RUNS, "dpswap").mkdir(parents=True, exist_ok=True)
Path(R.RUNS, "dpswap", "all.json").write_text(json.dumps(out, indent=1))
print("done")
