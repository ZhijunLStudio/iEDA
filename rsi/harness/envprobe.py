import json, os, re, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
sys.path.insert(0, str(W/"ieda/rsi/harness")); import rsi_lib as R
sys.path.insert(0, str(R.FLOWS)); import gp_agent as G
os.environ["IEDA_BIN"] = str(R.IEDA_ROOT/"build/bin/iEDA")
d = sys.argv[1] if len(sys.argv) > 1 else "gcd_nangate45_a"
rec = R.load_designs()[d]
cfg = json.loads(Path(rec["pl_config"]).read_text()); pl = cfg.get("PL", cfg)
td = float(pl.get("GP",{}).get("Density",{}).get("target_density",0.7))
mi = int(pl.get("GP",{}).get("Nesterov",{}).get("max_iter",2000))
wd = W/"runs"/"ev"/d; wd.mkdir(parents=True, exist_ok=True)
gp = "placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed 1000 -report_route_util 1" % (mi, td)
rc, o, e = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)), Path(rec["pl_config"]),
                      Path(rec["input_def"]),
                      [gp, "placer_run_gp -mode accept", "placer_run_lg", "placer_run_dp"], def_save=True)
txt = (o or "") + chr(10) + (e or "")
print("rc =", rc, "| def:", (wd/"placement.def").exists())
den = re.findall(r"(?:Failed to create directory '[^']*'|Permission denied \[[^\]]*\])", txt)
print("denied (%d):" % len(den))
seen = []
for x in den:
    if x not in seen:
        seen.append(x)
for x in seen[-8:]:
    print("   ", x[:150])
t = R.truth_metrics(wd, rec, with_egr=True)
print("union:", t.get("egr_total_overflow_union"), "max:", t.get("egr_max_overflow_union"))
