"""A/B: does inserting the network-flow spread stage between GP and LG help?

Pipeline A (baseline plain):  gp start -> gp accept -> lg -> dp
Pipeline B (candidate):       gp start -> gp accept -> nfs -> lg -> dp

Both run in ONE iEDA process, which is required: NFSpread spreads over the density grid
that global placement builds in memory. A separate def_init + placer_run_nfs process has
an empty grid (the log showed ABU 0,0,0,0 and the stage returned in 0.6 ms), so it can
only ever report "no overflow to reduce".

Reuses the project's own run_ieda so the GP invocation is byte-identical to the plain flow.
"""
import json
import statistics as st
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import placement_shape as PS
import rsi_lib as R

sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

MATCHED = ["gcd_sky130_a", "gcd_ics55_a", "gcd_nangate45_a",
           "s1238_sky130_a", "s1238_ics55_a", "s1238_nangate45_a",
           "salsa20_sky130_a", "salsa20_ics55_a", "salsa20_nangate45_a",
           "s38584_sky130_a", "s38584_ics55_a", "s38584_nangate45_a"]


def run(design, rec, root, tag, with_nfs):
    wd = Path(root) / ("nfsab/%s/%s" % (tag, design))
    wd.mkdir(parents=True, exist_ok=True)
    cfg = json.loads(Path(rec["pl_config"]).read_text())
    pl = cfg.get("PL", cfg)
    gp = pl.get("GP", {})
    td = float(gp.get("Density", {}).get("target_density", pl.get("target_density", 0.8)))
    max_iter = int(gp.get("Nesterov", {}).get("max_iter", 2000))
    cmds = [
        "placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed 1000 -report_route_util 1" % (max_iter, td),
        "placer_run_gp -mode accept",
    ]
    if with_nfs:
        cmds.append("placer_run_nfs")
    cmds += ["placer_run_lg", "placer_run_dp"]
    t0 = time.time()
    rc, out, err = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)),
                              Path(rec["pl_config"]), Path(rec["input_def"]), cmds, def_save=True)
    wall = round(time.time() - t0, 1)
    sh = PS.parse_placement(wd / "placement.def")
    sys.path.insert(0, str(R.FLOWS))
    from gp_metrics_compare import hpwl as ihpwl
    row = {"design": design, "pdk": rec.get("pdk"), "arm": ("B_nfs" if with_nfs else "A_base"),
           "rc": rc, "wall_s": wall, "gini": (sh or {}).get("gini"),
           "max_bin": (sh or {}).get("max_bin"),
           "busiest1pct": (sh or {}).get("busiest1pct_share")}
    try:
        lef = R.lef_of(rec)
        if lef and (wd / "placement.def").exists():
            row["hpwl"] = ihpwl(wd / "placement.def", Path(lef))
    except Exception as ex:
        row["hpwl_err"] = repr(ex)
    t = R.truth_metrics(wd, rec, with_egr=True)
    row["egr_union"] = t.get("egr_total_overflow_union")
    row["egr_max"] = t.get("egr_max_overflow_union")
    Path(root, "nfsab", tag, design).mkdir(parents=True, exist_ok=True)
    Path(root, "nfsab", tag, "%s_%s.json" % (design, row["arm"])).write_text(json.dumps(row, indent=1))
    return row


def main():
    ap_designs = sys.argv[1] if len(sys.argv) > 1 else ""
    tag = sys.argv[2] if len(sys.argv) > 2 else "v1"
    root = R.RUNS
    D = R.load_designs()
    names = [x for x in ap_designs.split(",") if x] or MATCHED
    res = []
    for d in names:
        rec = D.get(d)
        if not rec:
            continue
        for with_nfs in (False, True):
            try:
                row = run(d, rec, root, tag, with_nfs)
            except Exception as ex:
                row = {"design": d, "arm": ("B_nfs" if with_nfs else "A_base"), "error": repr(ex)}
            res.append(row)
            print(json.dumps({k: row.get(k) for k in
                              ("design", "arm", "rc", "wall_s", "gini", "max_bin", "hpwl", "egr_union", "egr_max")}))
            sys.stdout.flush()
    Path(root, "nfsab", tag).mkdir(parents=True, exist_ok=True)
    Path(root, "nfsab", tag, "all.json").write_text(json.dumps(res, indent=1))
    print("wrote", Path(root, "nfsab", tag, "all.json"))


if __name__ == "__main__":
    main()
