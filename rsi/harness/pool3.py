"""Candidates aimed at the two designs the pool has not yet fixed.

salsa20_nangate45_a stays at 2.0-3.2x the reference on total overflow with the best candidate so far
(ce2lg), and s1238_sky130_a keeps a peak of 1.2-1.4x because detail placement is worth 46% of its
wirelength and must not be dropped. This sweeps candidates built from the knobs that have shown
effect - the congestion-aware wirelength level, its combination with detail placement, and the
target density - on exactly those two designs.

In a measured pool a candidate needs no justification on average; it only has to be the best
available sometimes. That is why density and level variants belong here even though both were
rejected as defaults.
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
seeds = [int(x) for x in (sys.argv[2].split(",") if len(sys.argv) > 2 else [1001])]
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
        base = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed %d"
                " -report_route_util 1" % (mi, td, seed))
        # candidate name -> (gp command, tail)
        cands = {
            "ce2lgdp": (base + " -congestion_effort 2", ["placer_run_lg", "placer_run_dp"]),
            "ce2lgdplgdp": (base + " -congestion_effort 2", ["placer_run_lg", "placer_run_dp",
                                                             "placer_run_lg", "placer_run_dp"]),
            "ce3lg": (base + " -congestion_effort 3", ["placer_run_lg"]),
            "ce5lg": (base + " -congestion_effort 5", ["placer_run_lg"]),
            "ce6lg": (base + " -congestion_effort 6", ["placer_run_lg"]),
            "ce2td90lg": (base.replace("-target_density %s" % td, "-target_density 0.90")
                          + " -congestion_effort 2", ["placer_run_lg"]),
            "td70lg": (base.replace("-target_density %s" % td, "-target_density 0.70"),
                       ["placer_run_lg"]),
            "ce2it4000lg": (base.replace("-iterations %d" % mi, "-iterations 4000")
                            + " -congestion_effort 2", ["placer_run_lg"]),
        }
        for arm, (gpcmd, tail) in cands.items():
            wd = R.RUNS / "pool3" / ("%s_%s_s%d" % (d, arm, seed))
            wd.mkdir(parents=True, exist_ok=True)
            rc, o, e = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)),
                                  Path(rec["pl_config"]), Path(rec["input_def"]),
                                  [gpcmd, "placer_run_gp -mode accept"] + tail, def_save=True)
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
Path(R.RUNS, "pool3").mkdir(parents=True, exist_ok=True)
Path(R.RUNS, "pool3", "all.json").write_text(json.dumps(out, indent=1))
print("done")
