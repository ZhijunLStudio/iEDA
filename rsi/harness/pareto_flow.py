"""Pick between LG and LG+DP per design by a Pareto rule on the two congestion metrics.

The oracle over saved placements showed LG alone beats LG+DP on both congestion dimensions for 6 of
9 seed-pairs, and on s1238_ics55_a it produces a placement that beats the reference on both
dimensions at every seed - where the shipped flow, which always runs DP, loses. The flow always runs
DP because it has no measurement to decide with; the EGR evaluator is available and costs seconds.

Rule, no tuned constants: take the LG placement if it is no worse than the DP placement on BOTH
total overflow and peak overflow; otherwise keep the DP placement. Both arms come from the same
global placement and the same binary, so the only difference is whether DP ran.

Arms produced per (design, seed):
  lg     - gp, lg
  lgdp   - gp, lg, dp
and the rule's selection is computed from their EGR results.
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

ARMS = {"lg": ["placer_run_lg"], "lgdp": ["placer_run_lg", "placer_run_dp"]}
D = R.load_designs()
ds = [x for x in sys.argv[1].split(",") if x]
seeds = [int(x) for x in (sys.argv[2].split(",") if len(sys.argv) > 2 else [1001, 1002])]
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
        for arm, tail in ARMS.items():
            wd = R.RUNS / "pareto" / ("%s_%s_s%d" % (d, arm, seed))
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
Path(R.RUNS, "pareto").mkdir(parents=True, exist_ok=True)
Path(R.RUNS, "pareto", "all.json").write_text(json.dumps(out, indent=1))
print("done")
