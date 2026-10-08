"""Which stage moves the placement, and by how much? GP vs +LG vs +LG+DP.

Runs the same candidate (td=0.80, ce=3, seed=1000) on six designs spanning the three
usable PDKs and the S/M/L scales, measuring the independent legalized-format wirelength
after each stage. This tells you whether the stage you skip is the stage that matters.
"""
import json, sys, time
from pathlib import Path
sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
from gp_metrics_compare import hpwl as ihpwl

DESIGNS = ["gcd_sky130_a", "s1238_sky130_a", "aes_sky130_a", "s38584_sky130_a",
           "gcd_ics55_a", "gcd_nangate45_a"]
OUT = R.RUNS / "stagesplit"
OUT.mkdir(parents=True, exist_ok=True)
D = R.load_designs()
res = []
for d in DESIGNS:
    rec = D.get(d)
    if not rec:
        print("skip", d); continue
    lef = R.lef_of(rec)
    wd = OUT / d
    stage = {}
    t0 = time.time()
    # 1. global placement only
    r = R.gp_candidate(d, rec, wd, target_density=0.80, congestion_effort=3, iterations=300, legalize=False)
    t_gp = time.time() - t0
    try:
        stage["gp"] = ihpwl(wd / "placement.def", Path(lef))
    except Exception as e:
        stage["gp"] = None
    # 2. + legalization
    t1 = time.time()
    cmd = [R.PY, "gp_agent.py", "lg", "--workdir", str(wd), "--case-root", rec["case_root"],
           "--foundry-dir", R.foundry_of(rec)]
    if lef: cmd += ["--lef", lef]
    R.run_cmd(cmd, timeout=3600)
    t_lg = time.time() - t1
    try:
        stage["gp_lg"] = ihpwl(wd / "placement.def", Path(lef))
    except Exception:
        stage["gp_lg"] = None
    # 3. + detailed placement
    t2 = time.time()
    cmd = [R.PY, "gp_agent.py", "dp", "--workdir", str(wd), "--case-root", rec["case_root"],
           "--foundry-dir", R.foundry_of(rec)]
    if lef: cmd += ["--lef", lef]
    R.run_cmd(cmd, timeout=3600)
    t_dp = time.time() - t2
    try:
        stage["gp_lg_dp"] = ihpwl(wd / "placement.def", Path(lef))
    except Exception:
        stage["gp_lg_dp"] = None
    stage.update({"design": d, "pdk": rec.get("pdk"), "t_gp": round(t_gp, 1),
                  "t_lg": round(t_lg, 1), "t_dp": round(t_dp, 1)})
    res.append(stage)
    print(json.dumps(stage))
    sys.stdout.flush()
(OUT / "stagesplit.json").write_text(json.dumps(res, indent=1))
print("done")
