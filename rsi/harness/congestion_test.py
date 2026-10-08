"""Does the existing congestion-aware global placement mode reduce peak congestion?

placer_run_gp accepts -congestion_effort with levels documented in PLAPI.cc:
  0 = off (what the config-driven plain flow uses)
  5 = joint density-congestion targets
  6 = constraint-first balanced: per-bin density multipliers, only violating bins hold pressure
  7 = real iRT trial-route overflow feedback

The plain flow never sets it, so the whole congestion-aware path is dormant. This measures
what each level does to HPWL, EGR union and EGR max, against the same pipeline with the
level off. Everything else is identical, including the GP invocation.
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import placement_shape as PS
import rsi_lib as R

sys.path.insert(0, str(R.FLOWS))
import gp_agent as G


def go(d, rec, level, rep=""):
    wd = R.RUNS / "cong" / ("%s_ce%d%s" % (d, level, rep))
    wd.mkdir(parents=True, exist_ok=True)
    cfg = json.loads(Path(rec["pl_config"]).read_text())
    pl = cfg.get("PL", cfg)
    td = float(pl.get("GP", {}).get("Density", {}).get("target_density", 0.8))
    mi = int(pl.get("GP", {}).get("Nesterov", {}).get("max_iter", 2000))
    gp = "placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed 1000 -report_route_util 1" % (mi, td)
    if level:
        gp += " -congestion_effort %d" % level
    cmds = [gp, "placer_run_gp -mode accept", "placer_run_lg", "placer_run_dp"]
    rc, out, err = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)),
                              Path(rec["pl_config"]), Path(rec["input_def"]), cmds, def_save=True)
    Path("/tmp/cong_%s_%d%s.log" % (d, level, rep)).write_text(out or "")
    row = {"design": d, "level": level, "rep": rep, "rc": rc}
    sh = PS.parse_placement(wd / "placement.def")
    row["gini"] = (sh or {}).get("gini")
    row["max_bin"] = (sh or {}).get("max_bin")
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
    return row


D = R.load_designs()
ds = [x for x in (sys.argv[1].split(",") if len(sys.argv) > 1 else []) if x]
levels = [int(x) for x in (sys.argv[2].split(",") if len(sys.argv) > 2 else ["0", "5", "6"])]
reps = [x for x in (sys.argv[3].split(",") if len(sys.argv) > 3 else []) if x]
out = []
for d in ds:
    rec = D.get(d)
    if not rec:
        continue
    for lv in levels:
        for rep in (reps or [""]):
            try:
                row = go(d, rec, lv, rep)
            except Exception as ex:
                row = {"design": d, "level": lv, "rep": rep, "error": repr(ex)}
            out.append(row)
            print(json.dumps(row))
            sys.stdout.flush()
Path(R.RUNS, "cong").mkdir(parents=True, exist_ok=True)
Path(R.RUNS, "cong", "all.json").write_text(json.dumps(out, indent=1))
print("done")
