"""Does detail placement buy wirelength at the cost of peak congestion?

Arms, per design, all from the same global placement:
  GP+LG      : stop after legalization
  GP+LG+DP   : the baseline plain pipeline

If DP lowers HPWL but raises EGR max, then DP is trading the objective we have already
won (wirelength) for the one we are losing (peak congestion), and a density guard on DP's
moves is justified. If EGR max is unchanged or better, DP is not the cause and the search
should move elsewhere.

LG and DP are invoked in-process by the project's own run_ieda so the GP invocation is
identical to the baseline.
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import placement_shape as PS
import rsi_lib as R

sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

DESIGNS = ["aes", "s38584_sky130_a", "salsa20_sky130_a", "picorv32",
           "aes_core_sky130_b", "PPU_sky130_b"]


def go(d, rec, stop_after_lg):
    arm = "LG" if stop_after_lg else "LGDP"
    wd = R.RUNS / "dpcost" / ("%s_%s" % (d, arm))
    wd.mkdir(parents=True, exist_ok=True)
    cfg = json.loads(Path(rec["pl_config"]).read_text())
    pl = cfg.get("PL", cfg)
    td = float(pl.get("GP", {}).get("Density", {}).get("target_density", 0.8))
    mi = int(pl.get("GP", {}).get("Nesterov", {}).get("max_iter", 2000))
    cmds = ["placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed 1000 -report_route_util 1" % (mi, td),
            "placer_run_gp -mode accept",
            "placer_run_lg"]
    if not stop_after_lg:
        cmds.append("placer_run_dp")
    rc, out, err = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)),
                              Path(rec["pl_config"]), Path(rec["input_def"]), cmds, def_save=True)
    sh = PS.parse_placement(wd / "placement.def")
    row = {"design": d, "arm": arm, "rc": rc, "wall_s": None,
           "gini": (sh or {}).get("gini"), "max_bin": (sh or {}).get("max_bin")}
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
out = []
for d in DESIGNS:
    rec = D.get(d)
    if not rec:
        continue
    for lg_only in (True, False):
        try:
            r = go(d, rec, lg_only)
        except Exception as ex:
            r = {"design": d, "arm": ("LG" if lg_only else "LGDP"), "error": repr(ex)}
        out.append(r)
        print(json.dumps(r)); sys.stdout.flush()
Path(R.RUNS, "dpcost").mkdir(parents=True, exist_ok=True)
Path(R.RUNS, "dpcost", "all.json").write_text(json.dumps(out, indent=1))
print("done")
