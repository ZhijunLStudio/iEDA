"""Does the Pareto selection cost timing? Required check on the fifth dimension.

The selection prefers routability over wirelength when the two conflict, and timing correlates with
wirelength, so a chosen candidate could be slower. This runs the same timing rung on the shipped
candidate (lgdp) and on the pool-best candidate for the same design and seed, so the comparison is
like for like. Only designs whose timing rung works can be checked; the nangate45 designs crash it,
which is a coverage limit already recorded.
"""
import json
import sys
from pathlib import Path

W = Path("/home/lizhijun/work/ieda-rsi")
sys.path.insert(0, str(W / "ieda/rsi/harness"))
import rsi_lib as R
import timing_rung as T

A = {x["design"]: x for x in json.loads((W / "ieda/rsi/analysis/out/innovus_anchor.json").read_text())}
D = json.loads((W / "ieda/rsi/harness/designs.local.json").read_text())
ARMS = ("lg", "lgdp", "lgdplg", "lgdplgdp", "ce2lg", "ce4lg")


def dominates(a, b):
    if not a or not b or a.get("union") is None or b.get("union") is None or a.get("max") is None or b.get("max") is None:
        return False
    return a["union"] <= b["union"] and a["max"] <= b["max"] and (a["union"] < b["union"] or a["max"] < b["max"])


rows = []
for l in (W / "runs/pool.log").read_text().splitlines():
    l = l.strip()
    if l.startswith("{"):
        try:
            rows.append(json.loads(l))
        except Exception:
            pass
by = {}
for r in rows:
    by.setdefault((r["design"], r["seed"]), {})[r["arm"]] = r

out = []
for k in sorted(by):
    v = by[k]
    if not all(a in v for a in ARMS):
        continue
    best = None
    for a in ARMS:
        c = v[a]
        if c.get("union") is None or c.get("max") is None:
            continue
        if best is None or dominates(c, best):
            best = c
    if best is None:
        continue
    names = [a for a in ARMS if v[a] is best]
    d = k[0]
    rec = D.get(d)
    if not rec:
        continue
    for arm in {names[0] if names else "lgdp", "lgdp"}:
        wd = W / "runs/pool" / ("%s_%s_s%d" % (d, arm, k[1]))
        defp = wd / "placement.def"
        if not defp.exists():
            continue
        try:
            ok, m = T.timing_of(defp, d, rec, W / "runs/pooldim" / ("%s_%s_s%d" % (d, arm, k[1])))
        except Exception as ex:
            ok, m = False, {"reason": repr(ex)[:60]}
        out.append({"design": d, "seed": k[1], "arm": arm, "ok": ok,
                    "setup_wns": m.get("setup_wns"), "setup_tns": m.get("setup_tns"),
                    "reason": m.get("reason")})
        print(json.dumps(out[-1]))
        sys.stdout.flush()
Path(W / "runs/pooldim").mkdir(parents=True, exist_ok=True)
Path(W / "runs/pooldim", "all.json").write_text(json.dumps(out, indent=1))
print("done")
