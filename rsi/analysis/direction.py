"""The directional split of the congestion gap, ours versus reference.

The evaluator reports overflow per routing direction, and the placement's own LEF fixes how many
routing tracks each direction has. If a deficit is concentrated in one direction while the other is
fine, the placement is misusing the capacity it has rather than running short of it overall, and that
is a different defect with a different fix.
"""
import json
import sys
from pathlib import Path

W = Path("/home/lizhijun/work/ieda-rsi")
sys.path.insert(0, str(W / "ieda/rsi/harness"))
import rsi_lib as R

D = json.loads((W / "ieda/rsi/harness/designs.local.json").read_text())
tmp = W / "runs" / "dirprobe3"
tmp.mkdir(parents=True, exist_ok=True)

print("  %-22s %-5s %8s %8s | %8s %8s | %8s %8s" % (
    "design", "who", "union", "max", "tofH", "tofV", "mofH", "mofV"))
res = {}
for d in ("salsa20_nangate45_a", "salsa20_ics55_a", "s38584_nangate45_a", "s1238_sky130_a"):
    rec = D[d]
    for who, defp in (("ours", W / "runs/srciter/sweep/baseV2" / d / "placement.def"),
                      ("ref", Path(rec["innovus_def"]))):
        if not defp.exists():
            continue
        j = (R.egr_of(tmp, rec, def_path=defp).get("json") or {})
        res[(d, who)] = j
        print("  %-22s %-5s %8s %8s | %8s %8s | %8s %8s" % (
            d if who == "ours" else "", who,
            j.get("egr_total_overflow_union"), j.get("egr_max_overflow_union"),
            j.get("egr_total_overflow_horizontal"), j.get("egr_total_overflow_vertical"),
            j.get("egr_max_overflow_horizontal"), j.get("egr_max_overflow_vertical")))
    print()

print("=== ours as a multiple of the reference, per direction ===")
print("  %-22s %10s %10s %10s %10s" % ("design", "union", "totalH", "totalV", "which dominates"))
for d in ("salsa20_nangate45_a", "salsa20_ics55_a", "s38584_nangate45_a", "s1238_sky130_a"):
    a, b = res.get((d, "ours")), res.get((d, "ref"))
    if not (a and b):
        continue
    def r(x, y):
        x, y = a.get(x), b.get(y)
        return (x / y) if (x is not None and y not in (None, 0)) else None
    th, tv = a.get("egr_total_overflow_horizontal"), a.get("egr_total_overflow_vertical")
    dom = "vertical" if (th is not None and tv is not None and tv > 3 * max(th, 1)) else "both"
    print("  %-22s %10s %10s %10s %10s" % (
        d, ("%.2f" % r("egr_total_overflow_union", "egr_total_overflow_union")) if r("egr_total_overflow_union", "egr_total_overflow_union") else "-",
        ("%.2f" % r("egr_total_overflow_horizontal", "egr_total_overflow_horizontal")) if r("egr_total_overflow_horizontal", "egr_total_overflow_horizontal") else "-",
        ("%.2f" % r("egr_total_overflow_vertical", "egr_total_overflow_vertical")) if r("egr_total_overflow_vertical", "egr_total_overflow_vertical") else "-",
        dom))
Path(W / "runs", "direction.json").write_text(json.dumps({"%s|%s" % k: v for k, v in res.items()}, indent=1))
