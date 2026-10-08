"""Which valid designs robustly fail the peak, with the corrected reference values.

An earlier robust-failure list was built when one reference total overflow was mis-transcribed, and it
also predates the netlist-integrity filter. This rebuilds the list from the authoritative anchor file,
using every seed measurement available for each design (the base sweep at seed 1000 plus the
multi-seed sweeps), and reports the whole range against the reference rather than a point estimate.
"""
import collections
import json
import re
import statistics as st
import subprocess
from pathlib import Path

W = Path("/home/lizhijun/work/ieda-rsi")
A = {x["design"]: x for x in json.loads((W / "ieda/rsi/analysis/out/innovus_anchor.json").read_text())}
D = json.loads((W / "ieda/rsi/harness/designs.local.json").read_text())


def netcount(p):
    if not p or not Path(p).exists():
        return None
    r = subprocess.run(["grep", "-m1", "-E", "^NETS ", p], capture_output=True)
    m = re.search(rb"NETS\s+(\d+)", r.stdout)
    return int(m.group(1)) if m else None


def load(f):
    p = W / "runs" / f
    out = []
    if p.exists():
        for l in p.read_text().splitlines():
            l = l.strip()
            if l.startswith("{"):
                try:
                    out.append(json.loads(l))
                except Exception:
                    pass
    return out


# per (design) -> list of (max, union) from every available measurement of the shipped flow
meas = collections.defaultdict(list)
for r in json.loads((W / "runs/srciter/baseV2.json").read_text())["rows"]:
    if r.get("egr_max") is not None:
        meas[r["design"]].append((r["egr_max"], r.get("egr_union")))
for f, key in (("seeds_standing.log", "base"), ("seeds.log", "base"), ("dpseed.log", "gplgdp"), ("sr11seed.log", "ctl")):
    for r in load(f):
        if r.get("arm") not in (None, "base", "gplgdp", "ctl"):
            continue
        if r.get("max") is not None:
            meas[r["design"]].append((r["max"], r.get("union")))
        elif r.get("egr_max") is not None:
            meas[r["design"]].append((r["egr_max"], r.get("egr_union")))

print("  %-22s %-10s %8s %14s %8s  %s" % ("design", "pdk", "seeds", "our peak range", "ref peak", "verdict"))
rob = []
for d in sorted(D):
    n1, n2 = netcount(D[d].get("input_def")), netcount(D[d].get("innovus_def"))
    if not (n1 and n2 and abs(n2 - n1) <= 5):
        continue
    ref = (A.get(d) or {}).get("reference") or {}
    rm = ref.get("egr_max")
    if not rm:
        continue
    vals = [x[0] for x in meas.get(d, []) if x[0] is not None]
    if not vals:
        continue
    lo, hi = min(vals), max(vals)
    if lo > rm:
        v = "ROBUST: every seed worse"
        rob.append(d)
    elif hi <= rm:
        v = "robustly no-worse"
    else:
        v = "seed-dependent"
    print("  %-22s %-10s %8d %6d..%-7d %8d  %s" % (d, D[d].get("pdk"), len(vals), lo, hi, rm, v))
print()
print("  robust peak failures, corrected reference and netlist filter: %s" % rob)
