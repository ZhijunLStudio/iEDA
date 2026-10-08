"""Does the detail-placement guard fire at all under the deterministic protocol?

SR-13 never fires at one thread, and it is the strict version of SR-11, so SR-11 should never fire
either. SR-11 is the only behavioural change in the tree, so whether it does anything decides whether
the source work of the last several rounds has had any effect. This compares the build without it
against the build with it, same seed, one thread, so the answer is not a thread artefact.
"""
import json, os, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
sys.path.insert(0, str(W/"ieda/rsi/harness"))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G
from gp_metrics_compare import hpwl as ihpwl

D = R.load_designs()
BIN = {"noguard": R.IEDA_ROOT/"build/bin/iEDA-sr10", "guard": R.IEDA_ROOT/"build/bin/iEDA-sr11"}
ds = [x for x in sys.argv[1].split(",") if x]
seeds = [int(x) for x in sys.argv[2].split(",")]
out = []
for d in ds:
    rec = D[d]
    cfg = json.loads(Path(rec["pl_config"]).read_text()); pl = cfg.get("PL", cfg)
    td = float(pl.get("GP",{}).get("Density",{}).get("target_density",0.8))
    mi = int(pl.get("GP",{}).get("Nesterov",{}).get("max_iter",2000))
    for seed in seeds:
        for arm, b in BIN.items():
            wd = R.RUNS/"guardcheck"/("%s_%s_s%d" % (d, arm, seed)); wd.mkdir(parents=True, exist_ok=True)
            os.environ["IEDA_BIN"] = str(b)
            gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed %d"
                  " -report_route_util 1" % (mi, td, seed))
            rc,o,e = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)), Path(rec["pl_config"]),
                                Path(rec["input_def"]), [gp,"placer_run_gp -mode accept","placer_run_lg","placer_run_dp"],
                                def_save=True)
            t = R.truth_metrics(wd, rec, with_egr=True)
            row = {"design":d,"arm":arm,"seed":seed,"rc":rc,
                   "union":t.get("egr_total_overflow_union"), "max":t.get("egr_max_overflow_union")}
            lef = rec.get("lef")
            if lef and (wd/"placement.def").exists(): row["hpwl"] = ihpwl(wd/"placement.def", Path(lef))
            out.append(row); print(json.dumps(row), flush=True)
Path(R.RUNS,"guardcheck").mkdir(parents=True, exist_ok=True)
Path(R.RUNS,"guardcheck","all.json").write_text(json.dumps(out, indent=1))
by = {(r["design"], r["seed"]): {} for r in out}
for r in out: by[(r["design"], r["seed"])][r["arm"]] = r
print("=== guard effect (same placement iff HPWL agrees) ===")
for k in sorted(by):
    a, b = by[k].get("noguard"), by[k].get("guard")
    if not (a and b): continue
    same = a.get("hpwl") == b.get("hpwl")
    print("  %-22s s%-5d  hpwl %s vs %s  | union %s vs %s  max %s vs %s  -> %s" % (
        k[0], k[1], a.get("hpwl"), b.get("hpwl"), a.get("union"), b.get("union"),
        a.get("max"), b.get("max"), "IDENTICAL PLACEMENT" if same else "DIFFERENT"))
print("done")
