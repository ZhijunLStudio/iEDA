"""Does running legalization and detail placement more than once help, measured properly?

The flow runs LG once and DP once. DP is worth 40 to 46 per cent of the wirelength on some designs and
improves congestion on others, so a second pass has somewhere to land. This was tested long ago as "SR-6"
and in the candidate-pool work, both under the bypass protocol whose reference congestion was 2.0x to 2.7x
too large, so it is re-measured here with both arms in one process and the reference legalised in the same
batch.

Passes: 1 = the shipped flow, 2 and 3 add another LG+DP each.
"""
import json, os, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
os.environ["IEDA_BIN"] = str(W/"ieda/build/bin/iEDA-nosshim")
sys.path.insert(0, str(W/"ieda/rsi/harness")); sys.path.insert(0, str(W/"ieda/benchmarks/flows"))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G
from gp_metrics_compare import hpwl as ihpwl

D = R.load_designs()
passes = [int(x) for x in sys.argv[2].split(",")]
rows = []
for d in [x for x in sys.argv[1].split(",") if x]:
    rec = D[d]; lef = rec.get("lef")
    ref_wd = W/"runs"/"standingB"/d/"ref"
    tr = R.truth_metrics(ref_wd, rec, with_egr=True)
    hp_r = ihpwl(ref_wd/"placement.def", Path(lef)) if lef and (ref_wd/"placement.def").exists() else None
    cfg = json.loads(Path(rec["pl_config"]).read_text()); pl = cfg.get("PL", cfg)
    td = float(pl.get("GP",{}).get("Density",{}).get("target_density",0.8))
    mi = int(pl.get("GP",{}).get("Nesterov",{}).get("max_iter",2000))
    for n in passes:
        wd = W/"runs"/"passes"/("%s_p%d" % (d, n)); wd.mkdir(parents=True, exist_ok=True)
        gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed 1000"
              " -report_route_util 1" % (mi, td))
        cmds = [gp, "placer_run_gp -mode accept"]
        for _ in range(n):
            cmds += ["placer_run_lg", "placer_run_dp"]
        G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)), Path(rec["pl_config"]),
                   Path(rec["input_def"]), cmds, def_save=True)
        t = R.truth_metrics(wd, rec, with_egr=True)
        hp = ihpwl(wd/"placement.def", Path(lef)) if lef and (wd/"placement.def").exists() else None
        def rr(a, b): return round(a/b, 4) if (a is not None and b) else None
        row = {"design": d, "passes": n, "hpwl": rr(hp, hp_r),
               "union": rr(t.get("egr_total_overflow_union"), tr.get("egr_total_overflow_union")),
               "max": rr(t.get("egr_max_overflow_union"), tr.get("egr_max_overflow_union"))}
        rows.append(row); print(json.dumps(row), flush=True)
(W/"runs"/"passes").mkdir(parents=True, exist_ok=True)
(W/"runs"/"passes"/("all_%s.json" % "-".join(sys.argv[1].split(",")[:2]))).write_text(json.dumps(rows, indent=1))
print("done")
