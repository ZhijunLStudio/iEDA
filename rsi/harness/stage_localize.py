"""Where is the peak deficit created: floorplan, global placement, legalisation, or DP?

Every lever tried in seven rounds acted on global placement. If the peak deficit is already
present in the input DEF that placement receives, then none of those levers could have fixed it,
which would explain the uniform failure record and redirect the work.

Measured per stage, on valid netlist-matched designs that are robust peak failures:
  input    - the DEF placement is handed (the floorplan result)
  gp+lg    - after global placement and legalisation
  gp+lg+dp - the full flow
and the reference placement for context.

EGR needs a legal placement, so the input stage is only reported when the evaluator accepts it.
"""
import json
import shutil
import sys
from pathlib import Path

sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

DESIGNS = ["gcd_nangate45_a", "s1238_nangate45_a", "gcd_ics55_a", "s1238_ics55_a",
           "s38584_ics55_a", "aes", "apb4_timer", "picorv32",
           "salsa20_sky130_a", "s5378_sky130_b", "gcd_sky130_a", "s1238"]


def egr_of(defp, rec, tag):
    wd = R.RUNS / "stageloc" / tag
    wd.mkdir(parents=True, exist_ok=True)
    shutil.copy(defp, wd / "placement.def")
    t = R.truth_metrics(wd, rec, with_egr=True)
    return t.get("egr_total_overflow_union"), t.get("egr_max_overflow_union")


D = R.load_designs()
out = []
for d in DESIGNS:
    rec = D.get(d)
    if not rec:
        continue
    row = {"design": d, "pdk": rec.get("pdk")}
    # input
    try:
        u, m = egr_of(rec["input_def"], rec, "%s_input" % d)
        row["input"] = {"union": u, "max": m}
    except Exception as ex:
        row["input"] = {"err": repr(ex)[:80]}
    # gp+lg and gp+lg+dp
    cfg = json.loads(Path(rec["pl_config"]).read_text())
    pl = cfg.get("PL", cfg)
    td = float(pl.get("GP", {}).get("Density", {}).get("target_density", 0.8))
    mi = int(pl.get("GP", {}).get("Nesterov", {}).get("max_iter", 2000))
    gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed 1000"
          " -report_route_util 1" % (mi, td))
    for tag, cmds in (("gplg", [gp, "placer_run_gp -mode accept", "placer_run_lg"]),
                      ("gplgdp", [gp, "placer_run_gp -mode accept", "placer_run_lg", "placer_run_dp"])):
        wd = R.RUNS / "stageloc" / ("%s_%s" % (d, tag))
        wd.mkdir(parents=True, exist_ok=True)
        rc, o, e = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)),
                              Path(rec["pl_config"]), Path(rec["input_def"]), cmds, def_save=True)
        try:
            u, m = egr_of(wd / "placement.def", rec, "%s_%s_ev" % (d, tag))
            row[tag] = {"union": u, "max": m}
        except Exception as ex:
            row[tag] = {"err": repr(ex)[:80]}
    try:
        u, m = egr_of(rec["innovus_def"], rec, "%s_ref" % d)
        row["ref"] = {"union": u, "max": m}
    except Exception as ex:
        row["ref"] = {"err": repr(ex)[:80]}
    out.append(row)
    print(json.dumps(row))
    sys.stdout.flush()
Path(R.RUNS, "stageloc").mkdir(parents=True, exist_ok=True)
Path(R.RUNS, "stageloc", "all.json").write_text(json.dumps(out, indent=1))
print("done")
