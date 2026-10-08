import json, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
sys.path.insert(0, str(W / "ieda/rsi/harness"))
import rsi_lib as R
D = json.loads((W / "ieda/rsi/harness/designs.local.json").read_text())
tmp = W / "runs" / "dirprobe6"; tmp.mkdir(parents=True, exist_ok=True)
print("  %-22s %-6s %8s %8s | %8s %8s | %s" % ("design", "arm", "union", "max", "tofH", "tofV", "V/H"))
for d in ("salsa20_nangate45_a", "s38584_nangate45_a", "apb4_timer"):
    for arm in ("sr10", "sr12"):
        p = W / "runs" / "srab" / ("%s_%s" % (d, arm)) / "placement.def"
        if not p.exists():
            print("  %-22s %-6s (missing)" % (d, arm)); continue
        j = (R.egr_of(tmp, D[d], def_path=p).get("json") or {})
        h = j.get("egr_total_overflow_horizontal"); v = j.get("egr_total_overflow_vertical")
        ratio = ("%.2f" % (v / max(h, 1))) if (h is not None and v is not None) else "-"
        print("  %-22s %-6s %8s %8s | %8s %8s | %s" % (
            d if arm == "sr10" else "", arm, j.get("egr_total_overflow_union"),
            j.get("egr_max_overflow_union"), h, v, ratio))
    print()
