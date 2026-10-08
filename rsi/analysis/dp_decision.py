"""Would deciding DP by its own wirelength gain work?

The oracle shows LG alone beats LG+DP on both congestion dimensions for 6 of 9 seed-pairs. DP is a
wirelength-recovery stage, so the natural decision rule is DP's own wirelength gain - a quantity DP
already reports - and the flow already wraps it in a rollback-capable transaction. This computes
that gain from the saved placements and shows what the rule would have chosen.
"""
import json
import sys
from pathlib import Path

W = Path("/home/lizhijun/work/ieda-rsi")
sys.path.insert(0, str(W / "ieda/rsi/harness"))
import rsi_lib as R
sys.path.insert(0, str(W / "ieda/benchmarks/flows"))
from gp_metrics_compare import hpwl as ihpwl

D = json.loads((W / "ieda/rsi/harness/designs.local.json").read_text())
A = {x["design"]: x for x in json.loads((W / "ieda/rsi/analysis/out/innovus_anchor.json").read_text())}

print("  %-22s %5s %7s | %12s %12s %8s | %5s %5s %5s | ref u/max" % (
    "design", "seed", "?gain", "LG hpwl", "LGDP hpwl", "gain %", "uL", "uD", "pick"))
for d in sorted(D):
    rec = D.get(d)
    if not rec:
        continue
    lef = R.lef_of(rec)
    if not lef:
        continue
    rm = ((A.get(d) or {}).get("reference") or {}).get("egr_max")
    ru = ((A.get(d) or {}).get("reference") or {}).get("egr_total")
    for seed in (1001, 1002, 1003):
        pa = W / "runs/dpseed" / ("%s_gplg_s%d" % (d, seed)) / "placement.def"
        pb = W / "runs/dpseed" / ("%s_gplgdp_s%d" % (d, seed)) / "placement.def"
        if not (pa.exists() and pb.exists()):
            continue
        ha, hb = ihpwl(pa, Path(lef)), ihpwl(pb, Path(lef))
        gain = 100.0 * (ha - hb) / ha if ha else 0
        print("  %-22s %5d %7s | %12s %12s %7.2f%% |" % (d, seed, "", ha, hb, gain), end=" ")
        # read the EGR from the dpseed log
        rows = []
        for l in (W / "runs/dpseed.log").read_text().splitlines():
            l = l.strip()
            if l.startswith("{"):
                try:
                    rows.append(json.loads(l))
                except Exception:
                    pass
        a = next((x for x in rows if x["design"] == d and x["seed"] == seed and x["stage"] == "gplg"), None)
        b = next((x for x in rows if x["design"] == d and x["seed"] == seed and x["stage"] == "gplgdp"), None)
        if a and b:
            pick = "LG" if a["max"] < b["max"] else ("DP" if b["max"] < a["max"] else "tie")
            print("%5s %5s %5s | %s/%s" % (a["max"], b["max"], pick, ru, rm))
        else:
            print()
