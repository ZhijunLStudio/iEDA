"""Does a metric DP can compute cheaply predict the damage DP does to the peak?

Stage localisation showed detailed placement raises EGR max on six of seven designs measured, and
on two of them it turns a placement that beats the reference into one that loses. A guard needs a
signal that (a) DP can compute during its own run and (b) moves with the EGR damage. This tests
candidate signals on the placement  files already saved by the stage-localisation run, so it
costs nothing but parsing.

Candidates, all computable from a placement alone:
  max_bin            instances in the busiest bin of a 64x64 grid over the die
  busiest1pct_share  fraction of instances in the busiest 1% of occupied bins
  gini               inequality of the instance-count distribution
  netpeak            RUDY-style peak routing demand, the metric that tracks EGR max (1.85x the
                     reference on 30 of 30 designs)
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import placement_shape as PS
import rsi_lib as R

E = json.loads(Path(R.RUNS, "stageloc", "all.json").read_text())
out = []
for row in E:
    d = row["design"]
    a, b = row.get("gplg"), row.get("gplgdp")
    if not (a and b and a.get("max") is not None and b.get("max") is not None):
        continue
    pa = R.RUNS / "stageloc" / ("%s_gplg_ev" % d) / "placement.def"
    pb = R.RUNS / "stageloc" / ("%s_gplgdp_ev" % d) / "placement.def"
    sa, sb = PS.parse_placement(pa), PS.parse_placement(pb)
    if not (sa and sb):
        continue
    out.append({
        "design": d, "pdk": row.get("pdk"),
        "egr_a": a["max"], "egr_b": b["max"], "egr_change": b["max"] - a["max"],
        "ubin_a": a.get("union"), "ubin_b": b.get("union"),
        "maxbin_a": sa["max_bin"], "maxbin_b": sb["max_bin"], "maxbin_change": sb["max_bin"] - sa["max_bin"],
        "gini_a": sa["gini"], "gini_b": sb["gini"], "gini_change": sb["gini"] - sa["gini"],
        "busy_a": sa["busiest1pct_share"], "busy_b": sb["busiest1pct_share"],
    })

print("=== DP's effect on the peak, and on signals DP could compute ===")
print("  %-22s %6s %6s %8s | %8s %8s %9s | %8s %8s" % (
    "design", "egrA", "egrB", "dEGR", "maxbinA", "maxbinB", "dmaxbin", "giniA", "giniB"))
for r in out:
    print("  %-22s %6s %6s %+8d | %8s %8s %+9d | %8.4f %8.4f" % (
        r["design"], r["egr_a"], r["egr_b"], r["egr_change"],
        r["maxbin_a"], r["maxbin_b"], r["maxbin_change"], r["gini_a"], r["gini_b"]))

print()
same = sum(1 for r in out if (r["egr_change"] > 0) == (r["maxbin_change"] > 0))
print("  DP worsens the peak on %d/%d designs" % (sum(1 for r in out if r["egr_change"] > 0), len(out)))
print("  DP worsens max_bin on %d/%d designs" % (sum(1 for r in out if r["maxbin_change"] > 0), len(out)))
print("  sign agreement between dEGR and dmaxbin: %d/%d" % (same, len(out)))
Path(R.RUNS, "stageloc", "signal.json").write_text(json.dumps(out, indent=1))
