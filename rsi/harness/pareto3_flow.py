"""Three candidates instead of two: legalised, detailed, and converged-finish.

Round 13 showed a Pareto choice between the legalised placement and the detailed placement is
strictly safe and improves the standing. Converged finishing (SR-6) is a third candidate with a
different profile - it improves wirelength on every design and congestion on some - so it belongs in
the same choice rather than being rejected as a default.

All three arms run on the SR-6 binary, which only adds a command, so the pair/three-way comparison
holds the binary fixed and varies only the command sequence:
  lg    - gp, lg
  lgdp  - gp, lg, dp
  fin   - gp, placer_finish -max_passes 3 -hpwl_tol 0.002
The selection reported is the Pareto-best of the three on (union, peak): a candidate is taken if no
other candidate is at least as good on both with at least one strict improvement.
"""
import json
import os
import sys
from pathlib import Path

sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

ARMS = {
    "lg": ["placer_run_lg"],
    "lgdp": ["placer_run_lg", "placer_run_dp"],
    "fin": ["placer_finish -max_passes 3 -hpwl_tol 0.002"],
}
D = R.load_designs()
ds = [x for x in sys.argv[1].split(",") if x]
seeds = [int(x) for x in (sys.argv[2].split(",") if len(sys.argv) > 2 else [1001, 1002])]
os.environ["IEDA_BIN"] = str(R.IEDA_ROOT / "build/bin/iEDA-sr6")
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
        for arm, tail in ARMS.items():
            wd = R.RUNS / "pareto3" / ("%s_%s_s%d" % (d, arm, seed))
            wd.mkdir(parents=True, exist_ok=True)
            gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed %d"
                  " -report_route_util 1" % (mi, td, seed))
            rc, o, e = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)),
                                  Path(rec["pl_config"]), Path(rec["input_def"]),
                                  [gp, "placer_run_gp -mode accept"] + tail, def_save=True)
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
Path(R.RUNS, "pareto3").mkdir(parents=True, exist_ok=True)
Path(R.RUNS, "pareto3", "all.json").write_text(json.dumps(out, indent=1))
print("done")
