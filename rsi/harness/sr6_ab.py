"""SR-6 against the single-pass flow, by binary and by command sequence.

Control : build/bin/iEDA-head (HEAD source), commands gp -> accept -> lg -> dp
SR-6    : build/bin/iEDA-sr6 (HEAD + the converged finishing command), commands
          gp -> accept -> placer_finish -max_passes N -hpwl_tol T

The working-tree change is the only difference between the two builds, so the pair isolates it;
the command sequence differs because the whole point of SR-6 is to replace the fixed pair of
stages with a loop that stops on a criterion.
"""
import json
import os
import sys
from pathlib import Path

sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

BIN = {"ctl": R.IEDA_ROOT / "build/bin/iEDA-head",
       "sr6": R.IEDA_ROOT / "build/bin/iEDA-sr6"}


def go(d, rec, arm, seed, max_passes=3, tol=0.002):
    wd = R.RUNS / "sr6ab" / ("%s_%s_s%d" % (d, arm, seed))
    wd.mkdir(parents=True, exist_ok=True)
    cfg = json.loads(Path(rec["pl_config"]).read_text())
    pl = cfg.get("PL", cfg)
    td = float(pl.get("GP", {}).get("Density", {}).get("target_density", 0.8))
    mi = int(pl.get("GP", {}).get("Nesterov", {}).get("max_iter", 2000))
    gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed %d"
          " -report_route_util 1" % (mi, td, seed))
    if arm == "ctl":
        cmds = [gp, "placer_run_gp -mode accept", "placer_run_lg", "placer_run_dp"]
    else:
        cmds = [gp, "placer_run_gp -mode accept",
                "placer_finish -max_passes %d -hpwl_tol %s" % (max_passes, tol)]
    os.environ["IEDA_BIN"] = str(BIN[arm])
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
    return row


D = R.load_designs()
ds = [x for x in sys.argv[1].split(",") if x]
seeds = [int(x) for x in (sys.argv[2].split(",") if len(sys.argv) > 2 else [1001, 1002])]
out = []
for d in ds:
    rec = D.get(d)
    if not rec:
        continue
    for s in seeds:
        for arm in ("ctl", "sr6"):
            try:
                row = go(d, rec, arm, s)
            except Exception as ex:
                row = {"design": d, "arm": arm, "seed": s, "error": repr(ex)}
            out.append(row)
            print(json.dumps(row))
            sys.stdout.flush()
Path(R.RUNS, "sr6ab").mkdir(parents=True, exist_ok=True)
Path(R.RUNS, "sr6ab", "all.json").write_text(json.dumps(out, indent=1))
print("done")
