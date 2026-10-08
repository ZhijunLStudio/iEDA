"""Stage localisation under the corrected protocol.

Round 22 located the failures at GP+LG, but that used the bypass protocol whose reference congestion
was 2.0x to 2.7x too large. With both sides legalised, this re-asks where the congestion is lost: is our
GP+LG already worse than the reference, or is it only after detail placement? The answer decides whether
the next source change belongs in global placement, in legalisation, or in detail placement.

Measurement only, no source change.
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
REF = json.loads((W/"runs/reflegal/all.json").read_text())
os.environ["IEDA_BIN"] = str(R.IEDA_ROOT/"build/bin/iEDA")
ds = [x for x in sys.argv[1].split(",") if x]
seeds = [int(x) for x in (sys.argv[2].split(",") if len(sys.argv) > 2 else [1000])]
out = []
for d in ds:
    rec = D[d]
    cfg = json.loads(Path(rec["pl_config"]).read_text()); pl = cfg.get("PL", cfg)
    td = float(pl.get("GP",{}).get("Density",{}).get("target_density",0.8))
    mi = int(pl.get("GP",{}).get("Nesterov",{}).get("max_iter",2000))
    for seed in seeds:
        gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed %d"
              " -report_route_util 1" % (mi, td, seed))
        for tag, tail in (("gplg", ["placer_run_lg"]), ("gplgdp", ["placer_run_lg","placer_run_dp"])):
            wd = R.RUNS/"stageloc2"/("%s_%s_s%d" % (d, tag, seed)); wd.mkdir(parents=True, exist_ok=True)
            rc,o,e = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)), Path(rec["pl_config"]),
                                Path(rec["input_def"]), [gp,"placer_run_gp -mode accept"]+tail, def_save=True)
            t = R.truth_metrics(wd, rec, with_egr=True)
            row = {"design":d, "stage":tag, "seed":seed, "rc":rc,
                   "union":t.get("egr_total_overflow_union"), "max":t.get("egr_max_overflow_union")}
            lef = rec.get("lef")
            if lef and (wd/"placement.def").exists(): row["hpwl"]=ihpwl(wd/"placement.def", Path(lef))
            out.append(row); print(json.dumps(row), flush=True)
Path(R.RUNS,"stageloc2").mkdir(parents=True, exist_ok=True)
Path(R.RUNS,"stageloc2","all.json").write_text(json.dumps(out, indent=1))
print("=== ratios vs the LEGALISED reference ===")
by = {}
for r in out: by[(r["design"], r["seed"], r["stage"])] = r
for d in ds:
    ref = REF.get(d) or {}
    ru, rm, rh = ref.get("ref_union"), ref.get("ref_max"), ref.get("ref_hpwl")
    for s in seeds:
        a, b = by.get((d,s,"gplg")), by.get((d,s,"gplgdp"))
        if not (a and b): continue
        f = lambda x,y: ("%.2f"%(x/y)) if (x is not None and y) else "-"
        print("  %-20s s%-5d  union gp+lg %s -> +dp %s (ref %s) | max %s -> %s (ref %s) | hpwl %s -> %s" % (
            d, s, f(a["union"],ru), f(b["union"],ru), ru, f(a["max"],rm), f(b["max"],rm), rm,
            f(a.get("hpwl"),rh), f(b.get("hpwl"),rh)))
print("done")
