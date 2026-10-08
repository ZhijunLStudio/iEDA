"""Repeat seeds on the two best individual candidates, to separate signal from noise.

The congestion metrics have a measured seed spread of 5.92% median and 26.05% at p90, and
most of the per-design effects this campaign has measured on EGR max are in the 10-30% band.
The goal requires that a claim exceed the noise floor or be established with repeated seeds,
so this runs the two candidates that looked best individually - the lowered density-ramp
ceiling, and the congestion-aware wirelength at level 2 - across three seeds each, against the
default configuration on the same binary.

Arms (all on the same binary, so this is a configuration comparison and is reported as such):
  base   : congestion level default (1), ramp ceiling 1.05
  phi102 : congestion level default (1), ramp ceiling 1.02
  l2     : congestion level 2,              ramp ceiling 1.05
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import placement_shape as PS
import rsi_lib as R

sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

ARMS = {"base": "", "phi102": " -max_phi_coef 1.02", "l2": " -congestion_effort 2",
        "l3": " -congestion_effort 3", "l4": " -congestion_effort 4",
        "l7": " -congestion_effort 7"}
SEEDS = [1001, 1002, 1003]


def go(d, rec, arm, seed):
    wd = R.RUNS / "seeds" / ("%s_%s_s%d" % (d, arm, seed))
    wd.mkdir(parents=True, exist_ok=True)
    cfg = json.loads(Path(rec["pl_config"]).read_text())
    pl = cfg.get("PL", cfg)
    td = float(pl.get("GP", {}).get("Density", {}).get("target_density", 0.8))
    mi = int(pl.get("GP", {}).get("Nesterov", {}).get("max_iter", 2000))
    gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed %d"
          " -report_route_util 1" % (mi, td, seed)) + ARMS[arm]
    rc, out, err = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)),
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
    row["egr_union"] = t.get("egr_total_overflow_union")
    row["egr_max"] = t.get("egr_max_overflow_union")
    sh = PS.parse_placement(wd / "placement.def")
    row["gini"] = (sh or {}).get("gini")
    return row


D = R.load_designs()
ds = [x for x in sys.argv[1].split(",") if x]
arms = [x for x in (sys.argv[2].split(",") if len(sys.argv) > 2 else ["base", "phi102", "l2"]) if x]
seeds = [int(x) for x in (sys.argv[3].split(",") if len(sys.argv) > 3 else SEEDS)]
out = []
for d in ds:
    rec = D.get(d)
    if not rec:
        continue
    for a in arms:
        for s in seeds:
            try:
                row = go(d, rec, a, s)
            except Exception as ex:
                row = {"design": d, "arm": a, "seed": s, "error": repr(ex)}
            out.append(row)
            print(json.dumps(row))
            sys.stdout.flush()
Path(R.RUNS, "seeds").mkdir(parents=True, exist_ok=True)
Path(R.RUNS, "seeds", "all.json").write_text(json.dumps(out, indent=1))
print("done")
