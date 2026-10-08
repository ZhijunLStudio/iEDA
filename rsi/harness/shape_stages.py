"""Where does the clustering come from: GP, legalization, or detailed placement?

The earlier comparison measured the clustering of the FINAL placement (the plain flow
includes LG and DP) and found ours heavier-tailed than the reference. That does not say
which stage produced it. This measures the shape after each stage on the same placement,
and also after the reference, so the culprit is localized rather than guessed.

Note: GP-only output is not legalized, so its shape is not a like-for-like comparison with
the reference; it is included to see how much LG and DP move the statistic.
"""
import json, sys
from pathlib import Path
sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import placement_shape as PS
import rsi_lib as R
import timing_rung as T

DESIGNS = ["gcd_sky130_a", "s1238_sky130_a", "aes", "s38584_sky130_a", "salsa20_sky130_a"]
TCL = Path("/home/lizhijun/work/ieda-rsi/ieda/rsi/harness/tcl/pl_stage.tcl")
D = R.load_designs()
OUT = R.RUNS / "shape_stages"; OUT.mkdir(parents=True, exist_ok=True)
res = []
for d in DESIGNS:
    rec = D.get(d)
    if not rec: continue
    wd = OUT / d; wd.mkdir(parents=True, exist_ok=True)
    p = T.resolve(d, rec)
    R.gp_candidate(d, rec, wd, target_density=0.80, congestion_effort=0, iterations=300, legalize=False)
    row = {"design": d, "pdk": rec.get("pdk")}
    row["gp"] = PS.parse_placement(wd / "placement.def")
    for tag in ("lg", "lgdp"):
        env = {"CONFIG_DIR": str(Path(rec["case_root"]) / "iEDA_config"), "RESULT_DIR": str(wd),
               "TECH_LEF": p["tech_lef"], "LEF": p["lef"], "LIB": p["lib"], "SDC": p["sdc"],
               "PL_CONFIG": str(wd / "pl_derived_config.json"),
               "INPUT_DEF": str(wd / "placement.def"), "OUTPUT_DEF": str(wd / "placement.def"),
               "STAGE": tag}
        R.run_cmd([str(R.IEDA_ROOT / "bin/iEDA"), "-script", str(TCL)], cwd=wd, timeout=3600, env=env)
        row[tag] = PS.parse_placement(wd / "placement.def")
    ref = rec.get("innovus_def")
    row["reference"] = PS.parse_placement(ref) if ref else None
    res.append(row)
    print(json.dumps({k: row[k] for k in ("design", "pdk")}))
    print("   %-12s gini=%-7s max=%-5s | %-12s gini=%-7s max=%-5s | %-12s gini=%-7s max=%-5s | %-12s gini=%-7s max=%-5s" % (
        "GP", (row["gp"] or {}).get("gini"), (row["gp"] or {}).get("max_bin"),
        "+LG", (row["lg"] or {}).get("gini"), (row["lg"] or {}).get("max_bin"),
        "+LG+DP", (row["lgdp"] or {}).get("gini"), (row["lgdp"] or {}).get("max_bin"),
        "reference", (row["reference"] or {}).get("gini"), (row["reference"] or {}).get("max_bin")))
    sys.stdout.flush()
(OUT / "shape_stages.json").write_text(json.dumps(res, indent=1))
print("done")
