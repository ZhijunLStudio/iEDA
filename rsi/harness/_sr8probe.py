import json, os, sys
from pathlib import Path
sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

D = R.load_designs()
os.environ["IEDA_BIN"] = str(R.IEDA_ROOT / "build/bin/iEDA-sr8")
for d in ("s38584_nangate45_a", "s1238_sky130_a", "salsa20_nangate45_a", "s1238_ics55_a"):
    rec = D.get(d)
    if not rec:
        continue
    wd = R.RUNS / "sr8probe" / d
    wd.mkdir(parents=True, exist_ok=True)
    cfg = json.loads(Path(rec["pl_config"]).read_text())
    pl = cfg.get("PL", cfg)
    td = float(pl.get("GP", {}).get("Density", {}).get("target_density", 0.8))
    mi = int(pl.get("GP", {}).get("Nesterov", {}).get("max_iter", 2000))
    gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed 1000"
          " -report_route_util 1" % (mi, td))
    rc, out, err = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)),
                              Path(rec["pl_config"]), Path(rec["input_def"]),
                              [gp, "placer_run_gp -mode accept", "placer_run_lg", "placer_run_dp"],
                              def_save=True)
    txt = (out or "") + "\n" + (err or "")
    lines = [l for l in txt.splitlines() if "SR-8" in l]
    print("=== %s (rc=%d) ===" % (d, rc))
    for l in lines:
        i = l.find("SR-8")
        print("   ", l[i:i + 140])
    if not lines:
        print("    (no SR-8 lines; total chars %d)" % len(txt))
    sys.stdout.flush()
