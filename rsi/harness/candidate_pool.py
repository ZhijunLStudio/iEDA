"""A pool of cheap candidates, to be selected per design by the Pareto rule.

The Pareto choice moved the median peak ratio because a candidate only has to dominate on SOME
designs to be worth having. This builds a pool wider than the one ordering the flow uses, and tests
which candidates ever dominate where the deficit is worst. None of these is claimed as a blanket
improvement - the point is that the selection picks per design and takes the best available.

Candidates, all from the same global placement and the same binary:
  lg       gp, lg
  lgdp     gp, lg, dp                        (what the flow ships)
  lgdplg   gp, lg, dp, lg                     (round 10 showed this helps sometimes)
  lgdplgdp gp, lg, dp, lg, dp
  ce2lg    gp with the congestion-aware wirelength at level 2, lg
  ce4lg    gp with the congestion-aware wirelength at level 4, lg
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

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
        gpbase = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed %d"
                  " -report_route_util 1" % (mi, td, seed))
        cands = {
            "lg": [gpbase, "placer_run_gp -mode accept", "placer_run_lg"],
            "lgdp": [gpbase, "placer_run_gp -mode accept", "placer_run_lg", "placer_run_dp"],
            "lgdplg": [gpbase, "placer_run_gp -mode accept", "placer_run_lg", "placer_run_dp", "placer_run_lg"],
            "lgdplgdp": [gpbase, "placer_run_gp -mode accept", "placer_run_lg", "placer_run_dp",
                         "placer_run_lg", "placer_run_dp"],
            "ce2lg": [gpbase + " -congestion_effort 2", "placer_run_gp -mode accept", "placer_run_lg"],
            "ce4lg": [gpbase + " -congestion_effort 4", "placer_run_gp -mode accept", "placer_run_lg"],
        }
        for arm, cmds in cands.items():
            wd = R.RUNS / "pool" / ("%s_%s_s%d" % (d, arm, seed))
            wd.mkdir(parents=True, exist_ok=True)
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
Path(R.RUNS, "pool").mkdir(parents=True, exist_ok=True)
Path(R.RUNS, "pool", "all.json").write_text(json.dumps(out, indent=1))
print("done")
