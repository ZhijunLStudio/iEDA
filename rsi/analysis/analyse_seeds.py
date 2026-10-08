"""Separate the arm effect from the seed effect with paired comparisons.

EGR max on these designs has a large seed-to-seed spread - on gcd_sky130_a the baseline
configuration alone ranges from 8 to 24 overflowing bins across seeds, a 67% spread - so a
single-seed arm-versus-baseline difference cannot be read as an effect. Both arms here use the
SAME seeds, so the paired ratio arm(seed)/base(seed) cancels the seed contribution, and what
remains is the arm effect plus residual noise that the pairing does not remove.

Reported per design and arm:
  median paired ratio over seeds   (the effect)
  seed spread of the baseline arm  (the scale a single-seed claim has to beat)
  whether the arms' seed ranges overlap (if they do, the effect is not resolved)

Usage: python3 analyse_seeds.py [log]
"""
import json
import statistics as st
import sys
from pathlib import Path

LOG = sys.argv[1] if len(sys.argv) > 1 else "/home/lizhijun/work/ieda-rsi/runs/seeds.log"
rows = []
for l in Path(LOG).read_text().splitlines():
    l = l.strip()
    if l.startswith("{"):
        try:
            rows.append(json.loads(l))
        except Exception:
            pass

by = {}
for r in rows:
    by.setdefault(r["design"], {}).setdefault(r["arm"], {})[r["seed"]] = r

METRICS = [("hpwl", "HPWL"), ("egr_union", "union"), ("egr_max", "peak")]


def spread(vals):
    if len(vals) < 2:
        return None
    med = st.median(vals)
    if med == 0:
        return 0.0 if max(vals) == 0 else None
    return 100.0 * (max(vals) - min(vals)) / abs(med)


def main():
    arms = sorted({a for d in by.values() for a in d})
    arms = [a for a in arms if a != "base"]
    for metric, label in METRICS:
        print("=" * 78)
        print("=== %s : paired arm/base ratio, and the baseline's own seed spread ===" % label)
        print("  %-20s %-8s %9s %9s %9s | %s" % ("design", "arm", "paired", "seedmin", "seedmax", "resolved?"))
        ratios_all = {}
        for d in sorted(by):
            base = by[d].get("base", {})
            bv = [base[s].get(metric) for s in sorted(base) if base[s].get(metric) is not None]
            bs = spread(bv)
            for a in arms:
                av = by[d].get(a, {})
                paired = []
                for s in sorted(set(base) & set(av)):
                    x, y = base[s].get(metric), av[s].get(metric)
                    if x and y is not None and x > 0:
                        paired.append(y / x)
                if not paired:
                    continue
                avv = [av[s].get(metric) for s in sorted(av) if av[s].get(metric) is not None]
                med = st.median(paired)
                ratios_all.setdefault(a, []).append(med)
                # resolved when the arm's whole seed range is on one side of the baseline's
                resolved = ""
                if avv and bv:
                    if max(avv) < min(bv):
                        resolved = "better"
                    elif min(avv) > max(bv):
                        resolved = "worse"
                    else:
                        resolved = "overlap"
                print("  %-20s %-8s %9.3f %9s %9s | %s" % (
                    d, a, med,
                    ("%.0f%%" % bs) if bs is not None else "-",
                    ("%.0f%%" % spread(avv)) if spread(avv) is not None else "-",
                    resolved))
        print()
        for a in arms:
            v = ratios_all.get(a, [])
            if v:
                print("  %-10s median paired ratio over designs %.3f   better on %d/%d   worse on %d/%d" % (
                    a, st.median(v), sum(1 for x in v if x < 1), len(v), sum(1 for x in v if x > 1), len(v)))
        print()


if __name__ == "__main__":
    main()
