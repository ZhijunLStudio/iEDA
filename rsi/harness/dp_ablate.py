"""Which detail-placement operator raises peak congestion?

Stage localisation showed DP worsens the peak, and an iteration cap showed the damage happens in
the first swap iteration, which runs global swap, vertical swap, local reorder and row
optimisation in sequence. All four can be switched off through PL.DP, so this ablates them one at
a time and measures the peak, wirelength and total overflow. A config ablation identifies the
culprit; turning that into a source change is the follow-up.
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

ARMS = {
    "base": {},
    "no_swap": {"enable_instance_swap": 0},
    "no_reorder": {"enable_local_reorder": 0},
    "no_rowopt": {"enable_row_opt": 0},
}
DESIGNS = ["s38584_nangate45_a", "salsa20_ics55_a", "s1238_ics55_a", "s1238_sky130_a"]
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
    for arm, patch in ARMS.items():
        wd = R.RUNS / "dpabl" / ("%s_%s" % (d, arm))
        wd.mkdir(parents=True, exist_ok=True)
        c = json.loads(Path(rec["pl_config"]).read_text())
        p2 = c.get("PL", c)
        p2.setdefault("DP", {}).update(patch)
        cf = wd / "pl_config_patched.json"
        cf.write_text(json.dumps(c, indent=2))
        gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed 1000"
              " -report_route_util 1" % (mi, td))
        rc, o, e = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)),
                              cf, Path(rec["input_def"]),
                              [gp, "placer_run_gp -mode accept", "placer_run_lg", "placer_run_dp"],
                              def_save=True)
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
Path(R.RUNS, "dpabl").mkdir(parents=True, exist_ok=True)
Path(R.RUNS, "dpabl", "all.json").write_text(json.dumps(out, indent=1))
print("done")
