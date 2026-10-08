"""Re-judge SR-13 and SR-14 with a harness that actually switches binaries.

Both were "rejected" on evidence that could not switch binaries - the same binary ran in both arms, so the
"no-op" verdicts were guaranteed rather than observed. This runs control and treated per seed with the
corrected protocol: the binary is chosen per arm via IEDA_BIN (resolved at call time since round 36),
gp_agent runs as a subprocess so it inherits the environment, and the reference comes from the standing
rebuild, which was legalised in this environment.

Usage: sr_rejudge.py <test: sr13|sr14> <designs> <seeds>
"""
import json, os, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
sys.path.insert(0, str(W/"ieda/rsi/harness")); sys.path.insert(0, str(W/"ieda/benchmarks/flows"))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G
from gp_metrics_compare import hpwl as ihpwl

BINS = {"ctl": "build/bin/iEDA-ctl16-nosshim",     # SR-10 + SR-11 (f9581627, rebuilt clean)
        "sr13": "build/bin/iEDA-sr13-nosshim",    # SR-10 + SR-13
        "sr14": "build/bin/iEDA-sr14-nosshim",   # SR-10 + SR-11 + SR-14
        "sr16": "build/bin/iEDA-sr16-nosshim",   # SR-10 + SR-11 + SR-16 (no continue)
        "sr17": "build/bin/iEDA-sr17-nosshim"}    # SR-10 + SR-11 + SR-17 (congestion-gated passes)

test = sys.argv[1]
arm = test
ds = [x for x in sys.argv[2].split(",") if x]
seeds = [int(x) for x in sys.argv[3].split(",")]
D = R.load_designs()
out = []
for d in ds:
    rec = D[d]; lef = rec.get("lef")
    ref_wd = W/"runs"/"standingB"/d/"ref"
    tr = R.truth_metrics(ref_wd, rec, with_egr=True)
    hp_r = ihpwl(ref_wd/"placement.def", Path(lef)) if lef and (ref_wd/"placement.def").exists() else None
    for seed in seeds:
        for a in ("ctl", arm):
            os.environ["IEDA_BIN"] = str(W/"ieda"/BINS[a])
            wd = W/"runs"/"srrej"/test/("%s_%s_s%d" % (d, a, seed)); wd.mkdir(parents=True, exist_ok=True)
            cfg = json.loads(Path(rec["pl_config"]).read_text()); pl = cfg.get("PL", cfg)
            td = float(pl.get("GP",{}).get("Density",{}).get("target_density",0.8))
            mi = int(pl.get("GP",{}).get("Nesterov",{}).get("max_iter",2000))
            gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed %d"
                  " -report_route_util 1" % (mi, td, seed))
            G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)), Path(rec["pl_config"]),
                       Path(rec["input_def"]), [gp, "placer_run_gp -mode accept", "placer_run_lg", "placer_run_dp"],
                       def_save=True)
            t = R.truth_metrics(wd, rec, with_egr=True)
            hp = ihpwl(wd/"placement.def", Path(lef)) if lef and (wd/"placement.def").exists() else None
            row = {"test": test, "design": d, "arm": a, "seed": seed,
                   "hpwl": hp, "union": t.get("egr_total_overflow_union"), "max": t.get("egr_max_overflow_union"),
                   "ref": {"hpwl": hp_r, "union": tr.get("egr_total_overflow_union"), "max": tr.get("egr_max_overflow_union")}}
            out.append(row); print(json.dumps(row), flush=True)
(W/"runs"/"srrej"/test).mkdir(parents=True, exist_ok=True)
(W/"runs"/"srrej"/test/("res_%s.json" % "-".join(ds[:2]))).write_text(json.dumps(out, indent=1))
print("done")
