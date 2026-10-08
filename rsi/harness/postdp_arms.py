"""Does a passing stage after detailed placement recover the peak it gave away?

Evidence: detailed placement raises peak congestion on most netlist-matched designs and on two
turns a win against the reference into a loss. Its operations only accept moves on wirelength, and
the deficit appears in its first swap iteration. If the damage is concentration of cells and nets,
a stage that spreads - legalisation, or a second detail pass given a spread starting point - may
undo it.

Arms, all through the plain flow and the same binary:
  B0   gp -> lg -> dp                (the baseline plain pipeline)
  B1   gp -> lg -> dp -> lg          (re-legalise after dp)
  B2   gp -> lg -> dp -> lg -> dp    (re-legalise then a second dp pass)
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

ARMS = {
    "B0": ["placer_run_lg", "placer_run_dp"],
    "B1": ["placer_run_lg", "placer_run_dp", "placer_run_lg"],
    "B2": ["placer_run_lg", "placer_run_dp", "placer_run_lg", "placer_run_dp"],
}
DESIGNS = ["s38584_nangate45_a", "salsa20_ics55_a", "s1238_ics55_a", "s1238_sky130_a"]
D = R.load_designs()
out = []
for d in DESIGNS:
    rec = D.get(d)
    if not rec:
        continue
    for arm, tail in ARMS.items():
        wd = R.RUNS / "postdp" / ("%s_%s" % (d, arm))
        wd.mkdir(parents=True, exist_ok=True)
        cfg = json.loads(Path(rec["pl_config"]).read_text())
        pl = cfg.get("PL", cfg)
        td = float(pl.get("GP", {}).get("Density", {}).get("target_density", 0.8))
        mi = int(pl.get("GP", {}).get("Nesterov", {}).get("max_iter", 2000))
        gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed 1000"
              " -report_route_util 1" % (mi, td))
        cmds = [gp, "placer_run_gp -mode accept"] + tail
        rc, o, e = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)),
                              Path(rec["pl_config"]), Path(rec["input_def"]), cmds, def_save=True)
        row = {"design": d, "pdk": rec.get("pdk"), "arm": arm, "rc": rc}
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
Path(R.RUNS, "postdp").mkdir(parents=True, exist_ok=True)
Path(R.RUNS, "postdp", "all.json").write_text(json.dumps(out, indent=1))
print("done")
