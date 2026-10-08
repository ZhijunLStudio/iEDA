"""How many of the congestion "failures" rest on tiny absolute counts?

A ratio of three bins to two is 1.5 and reads as a 50 per cent failure, but neither number is physically
meaningful. Separating failures on meaningful totals from failures on near-zero totals matters for
reading the standing, and for deciding what to work on.
"""
import json
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
agg = json.loads((W/"runs/standingB/agg.json").read_text())
print("  %-20s %10s %10s %8s | %10s %10s %8s | %s" % (
    "design","our union","ref union","ratio","our peak","ref peak","ratio","kind"))
tiny_u = tiny_m = 0; real_u = tiny_u_list = []
real_m = []; tiny_m_list = []
for r in sorted(agg, key=lambda x: x["design"]):
    o, f, q = r["ours"], r["ref"], r["ratio"]
    def kind(ours, ref, ratio):
        if ratio is None: return "n/a"
        if ratio <= 1.0: return "pass"
        # meaningful if the reference's own count is not negligible
        return "fail-real" if (ref is not None and ref >= 100) else "fail-TINY"
    ku = kind(o["union"], f["union"], q["union"])
    km = kind(o["max"], f["max"], q["max"])
    if ku == "fail-real": real_u.append(r["design"])
    if ku == "fail-TINY": tiny_u_list.append(r["design"])
    if km == "fail-real": real_m.append(r["design"])
    if km == "fail-TINY": tiny_m_list.append(r["design"])
    print("  %-20s %10s %10s %8s | %10s %10s %8s | u:%s m:%s" % (
        r["design"], o["union"], f["union"], q["union"], o["max"], f["max"], q["max"], ku, km))
print()
print("  union failures on meaningful totals (%d): %s" % (len(real_u), ", ".join(real_u)))
print("  union failures on TINY totals      (%d): %s" % (len(tiny_u_list), ", ".join(tiny_u_list)))
print("  peak  failures on meaningful totals (%d): %s" % (len(real_m), ", ".join(real_m)))
print("  peak  failures on TINY totals      (%d): %s" % (len(tiny_m_list), ", ".join(tiny_m_list)))
