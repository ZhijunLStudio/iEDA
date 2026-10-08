"""Establish the timing baseline that this campaign has never had.

The goal asks to match or beat the commercial reference on timing, and every statement so far
has had to say "timing has no reference". This runs the SAME static timing analysis, with the
same pre-route HPWL RC model and the same library and SDC, on both placements of each design -
ours and the commercial one - so that the comparison is like for like and depends only on where
the cells are.

Two things to watch:
  - the reference DEF may contain cells or nets the design's library does not have, in which
    case the STA either fails or silently drops paths; a failure is reported, not hidden.
  - STA on an unrouted placement is intrinsically approximate, so the numbers are meaningful as
    a placement-vs-placement comparison, not as a signoff result.

Usage: python3 timing_baseline.py design1,design2 [tag]
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import rsi_lib as R
import timing_rung as T

D = R.load_designs()
ds = [x for x in sys.argv[1].split(",") if x] if len(sys.argv) > 1 else []
tag = sys.argv[2] if len(sys.argv) > 2 else "baseV2"

out = []
for d in ds:
    rec = D.get(d)
    if not rec:
        continue
    row = {"design": d, "pdk": rec.get("pdk")}
    arms = {
        "ours": R.RUNS / "srciter" / "sweep" / tag / d / "placement.def",
        "ref": Path(rec["innovus_def"]) if rec.get("innovus_def") else None,
    }
    for arm, defp in arms.items():
        if defp is None or not Path(defp).exists():
            row[arm] = {"ok": False, "reason": "def missing: %s" % defp}
            continue
        try:
            ok, m = T.timing_of(defp, d, rec, R.RUNS / "timingbase" / ("%s_%s" % (d, arm)))
            m["ok"] = ok
            row[arm] = {k: m.get(k) for k in ("ok", "setup_wns", "setup_tns", "hold_wns", "hold_tns", "cost_s", "reason")}
        except Exception as ex:
            row[arm] = {"ok": False, "reason": repr(ex)}
    out.append(row)
    a, b = row.get("ours", {}), row.get("ref", {})
    print(json.dumps({"design": d, "pdk": row.get("pdk"),
                      "ours": {k: a.get(k) for k in ("ok", "setup_wns", "setup_tns", "hold_tns")},
                      "ref": {k: b.get(k) for k in ("ok", "setup_wns", "setup_tns", "hold_tns")}}))
    sys.stdout.flush()

Path(R.RUNS, "timingbase").mkdir(parents=True, exist_ok=True)
Path(R.RUNS, "timingbase", "stamp_%s.json" % (tag + "_" + str(len(ds)))).write_text(json.dumps(out, indent=1))
print("wrote", R.RUNS / "timingbase" / ("stamp_%s.json" % (tag + "_" + str(len(ds)))))
