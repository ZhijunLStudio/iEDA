"""What does detailed placement buy, and what does it cost?

Stage localisation showed DP worsens the peak on most netlist-matched designs and on two designs
turns a win against the reference into a loss. The question that decides what to do about it is
the trade: DP improves wirelength, and we have wirelength margin. This prices both sides on the
placements the stage-localisation run already saved, so it costs only evaluation.

Reported per design: HPWL at GP+LG and after DP, and the reference, so the wirelength DP buys can
be compared with the wirelength we would still have without it.
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
from gp_metrics_compare import hpwl as ihpwl

E = json.loads(Path(R.RUNS, "stageloc", "all.json").read_text())
D = R.load_designs()
A = {x["design"]: x for x in json.loads(Path(R.ieda if False else Path("/home/lizhijun/work/ieda-rsi/ieda/rsi/analysis/out/innovus_anchor.json")).read_text())}
out = []
print("  %-22s %12s %12s %12s %9s %9s | %6s %6s" % (
    "design", "GP+LG hpwl", "+DP hpwl", "ref hpwl", "DP gain", "vs ref", "egrA", "egrB"))
for row in E:
    d = row["design"]
    rec = D.get(d)
    if not rec:
        continue
    lef = R.lef_of(rec)
    if not lef:
        continue
    pa = R.RUNS / "stageloc" / ("%s_gplg_ev" % d) / "placement.def"
    pb = R.RUNS / "stageloc" / ("%s_gplgdp_ev" % d) / "placement.def"
    if not (pa.exists() and pb.exists()):
        continue
    ha = ihpwl(pa, Path(lef))
    hb = ihpwl(pb, Path(lef))
    ref = ((A.get(d) or {}).get("reference") or {}).get("hpwl")
    gain = 100.0 * (hb / ha - 1) if ha else None
    vsref = (ha / ref) if (ha and ref) else None
    out.append({"design": d, "pdk": rec.get("pdk"), "hpwl_gplg": ha, "hpwl_dp": hb,
                "ref": ref, "dp_gain_pct": gain, "gplg_vs_ref": vsref,
                "egr_gplg": (row.get("gplg") or {}).get("max"),
                "egr_dp": (row.get("gplgdp") or {}).get("max"),
                "ref_max": (row.get("ref") or {}).get("max")})
    print("  %-22s %12s %12s %12s %8s%% %9s | %6s %6s" % (
        d, ha, hb, ref, ("%.2f" % gain) if gain is not None else "-",
        ("%.3f" % vsref) if vsref is not None else "-",
        (row.get("gplg") or {}).get("max"), (row.get("gplgdp") or {}).get("max")))
Path(R.RUNS, "stageloc", "dptrade.json").write_text(json.dumps(out, indent=1))
import statistics as st
g = [x["dp_gain_pct"] for x in out if x["dp_gain_pct"] is not None]
print()
print("  median wirelength DP buys: %.2f%%" % st.median(g))
