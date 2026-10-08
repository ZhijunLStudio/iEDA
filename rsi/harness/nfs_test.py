"""Does the network-flow spread stage reduce cell clustering, and what does it cost?

Pipeline A (baseline): GP -> LG -> DP
Pipeline B (candidate): GP -> NFS -> LG -> DP

NFS's own contract: it consumes a post-global-placement DEF and produces a lower-density
placement with residual overlap, so it belongs between GP and LG.
"""
import json, sys, time
from pathlib import Path
sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import placement_shape as PS
import rsi_lib as R
import timing_rung as T

DESIGNS = ["aes", "s38584_sky130_a", "salsa20_sky130_a", "s1238_sky130_a", "gcd_sky130_a"]
TCL = Path("/home/lizhijun/work/ieda-rsi/ieda/rsi/harness/tcl/pl_stage.tcl")
D = R.load_designs()
OUT = R.RUNS / "nfs"; OUT.mkdir(parents=True, exist_ok=True)


def stage(wd, rec, p, tag, timeout=3600):
    env = {"CONFIG_DIR": str(Path(rec["case_root"]) / "iEDA_config"), "RESULT_DIR": str(wd),
           "TECH_LEF": p["tech_lef"], "LEF": p["lef"], "LIB": p["lib"], "SDC": p["sdc"],
           "PL_CONFIG": str(wd / "pl_derived_config.json"),
           "INPUT_DEF": str(wd / "placement.def"), "OUTPUT_DEF": str(wd / "placement.def"),
           "STAGE": tag}
    return R.run_cmd([str(R.IEDA_ROOT / "bin/iEDA"), "-script", str(TCL)], cwd=wd,
                     timeout=timeout, env=env)


res = []
for d in DESIGNS:
    rec = D[d]; p = T.resolve(d, rec)
    row = {"design": d, "pdk": rec.get("pdk")}
    for arm in ("A", "B"):
        wd = OUT / ("%s_%s" % (d, arm)); wd.mkdir(parents=True, exist_ok=True)
        R.gp_candidate(d, rec, wd, target_density=0.80, congestion_effort=0, iterations=300, legalize=False)
        g = PS.parse_placement(wd / "placement.def")
        seq = [("gp", g)]
        rcs = {}
        if arm == "B":
            r = stage(wd, rec, p, "nfs"); rcs["nfs"] = r["rc"]
            seq.append(("nfs", PS.parse_placement(wd / "placement.def")))
        r = stage(wd, rec, p, "lg"); rcs["lg"] = r["rc"]
        seq.append(("lg", PS.parse_placement(wd / "placement.def")))
        r = stage(wd, rec, p, "lgdp"); rcs["lgdp"] = r["rc"]
        seq.append(("lgdp", PS.parse_placement(wd / "placement.def")))
        row[arm] = {"gini": {k: (v or {}).get("gini") for k, v in seq},
                    "max_bin": {k: (v or {}).get("max_bin") for k, v in seq},
                    "rc": rcs,
                    "final_hpwl": __import__("gp_metrics_compare_fallback", fromlist=["x"]).hpwl(wd / "placement.def", Path(R.lef_of(rec))) if False else None}
    res.append(row)
    print(json.dumps(row, default=str))
    sys.stdout.flush()
(OUT / "nfs.json").write_text(json.dumps(res, indent=1, default=str))
print("done")
