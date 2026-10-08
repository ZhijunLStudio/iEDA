import json, sys, time
from pathlib import Path
sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import rsi_lib as R, timing_rung as T
sys.path.insert(0, str(R.FLOWS))
from gp_metrics_compare import hpwl as ihpwl, check_legalized

DESIGNS = ["gcd_sky130_a", "s1238_sky130_a", "aes_sky130_a", "s38584_sky130_a",
           "gcd_ics55_a", "gcd_nangate45_a"]
TCL = Path("/home/lizhijun/work/ieda-rsi/ieda/rsi/harness/tcl/pl_stage.tcl")
D = R.load_designs()
OUT = R.RUNS / "lgdp2"; OUT.mkdir(parents=True, exist_ok=True)
res = []
for d in DESIGNS:
    rec = D[d]; lef = R.lef_of(rec); wd = OUT / d; wd.mkdir(parents=True, exist_ok=True)
    p = timing_rung = T.resolve(d, rec)
    R.gp_candidate(d, rec, wd, target_density=0.80, congestion_effort=3, iterations=300, legalize=False)
    row = {"design": d, "pdk": rec.get("pdk")}
    row["gp"] = ihpwl(wd / "placement.def", Path(lef))
    row["gp_legal"] = bool(check_legalized(wd / "placement.def").get("legalized"))
    for tag in ("lg", "lgdp"):
        env = {"CONFIG_DIR": str(Path(rec["case_root"]) / "iEDA_config"), "RESULT_DIR": str(wd),
               "TECH_LEF": p["tech_lef"], "LEF": p["lef"], "LIB": p["lib"], "SDC": p["sdc"],
               "PL_CONFIG": str(wd / "pl_derived_config.json"),
               "INPUT_DEF": str(wd / "placement.def"), "OUTPUT_DEF": str(wd / "placement.def"),
               "STAGE": tag}
        t0 = time.time()
        rr = R.run_cmd([str(R.IEDA_ROOT / "bin/iEDA"), "-script", str(TCL)], cwd=wd, timeout=3600, env=env)
        row["t_" + tag] = round(time.time() - t0, 1); row["rc_" + tag] = rr["rc"]
        try:
            row[tag] = ihpwl(wd / "placement.def", Path(lef))
            row[tag + "_legal"] = bool(check_legalized(wd / "placement.def").get("legalized"))
        except Exception:
            row[tag] = None
        if rr["rc"] != 0:
            row[tag + "_err"] = ((rr.get("stdout") or "") + (rr.get("stderr") or ""))[-180:]
    res.append(row); print(json.dumps(row)); sys.stdout.flush()
(OUT / "lgdp.json").write_text(json.dumps(res, indent=1))
print("done")
