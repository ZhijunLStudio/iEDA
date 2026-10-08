"""Is the cheap shape indicator a faithful proxy for EGR max?

The paper's method finding says: screen with the cheapest signal that preserves the truth
ordering, then confirm the survivors with the expensive one. Applying that to source
iteration needs a screening signal that (a) costs milliseconds, (b) is deterministic, and
(c) actually ranks designs/candidates the way EGR max does.

This script tests (c) for the placement-shape statistics against the commercial reference
and against our own EGR max, using the frozen DESIGN set of a sweep. It reports Spearman
correlations and, more usefully, the pairwise discordance rate: how often a design that is
more clustered than another is NOT the one with worse EGR max.

Usage:
  python3 analyse_cluster.py --tag baseV2
  python3 analyse_cluster.py --tag baseV2 --out cluster_report.md
"""
import argparse
import json
import os
import statistics as st
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent / "harness"))
import placement_shape as PS
import rsi_lib as R


def spearman(x, y):
    n = len(x)
    if n < 4:
        return None

    def rank(v):
        o = sorted(range(n), key=lambda i: v[i])
        r = [0.0] * n
        i = 0
        while i < n:
            j = i
            while j + 1 < n and v[o[j + 1]] == v[o[i]]:
                j += 1
            a = (i + j) / 2.0 + 1
            for k in range(i, j + 1):
                r[o[k]] = a
            i = j + 1
        return r
    rx, ry = rank(x), rank(y)
    mx, my = st.mean(rx), st.mean(ry)
    num = sum((a - mx) * (b - my) for a, b in zip(rx, ry))
    dx = sum((a - mx) ** 2 for a in rx) ** 0.5
    dy = sum((b - my) ** 2 for b in ry) ** 0.5
    return num / (dx * dy) if dx and dy else None


def discordance(vals, outs):
    """Fraction of pairs where a larger indicator does NOT mean a worse outcome."""
    a = b = 0
    for i in range(len(vals)):
        for j in range(i + 1, len(vals)):
            if vals[i] == vals[j] or outs[i] == outs[j]:
                continue
            if (vals[i] > vals[j]) == (outs[i] > outs[j]):
                a += 1
            else:
                b += 1
    return (b / (a + b)) if (a + b) else None


def build(tag, root):
    D = R.load_designs()
    rows = []
    base = Path(root) / "srciter"
    for d, rec in sorted(D.items()):
        wd = base / "sweep" / tag / d
        ours = wd / "placement.def"
        if not ours.exists():
            continue
        ref = rec.get("innovus_def")
        if not (ref and Path(ref).exists()):
            continue
        cmp_ = PS.compare(ours, ref)
        if not cmp_.get("delta"):
            continue
        rows.append({"design": d, "pdk": rec.get("pdk"),
                     "ours": cmp_["ours"], "reference": cmp_["reference"],
                     "delta": cmp_["delta"]})
    return rows


def enrich(rows, tag, root):
    """Attach our own EGR numbers from the sweep json when present."""
    p = Path(root) / "srciter" / ("%s.json" % tag)
    if not p.exists():
        return rows
    j = json.loads(p.read_text())
    by = {r["design"]: r for r in j.get("rows", [])}
    for r in rows:
        s = by.get(r["design"]) or {}
        r["egr_union"] = s.get("egr_union")
        r["egr_max"] = s.get("egr_max")
        r["hpwl"] = s.get("hpwl")
    return rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tag", required=True)
    ap.add_argument("--root", default=str(R.RSI_ROOT / "runs"))
    ap.add_argument("--out", default=None)
    args = ap.parse_args()
    rows = enrich(build(args.tag, args.root), args.tag, args.root)
    if not rows:
        print("no designs with both a placement and a reference for tag %s" % args.tag)
        return 1

    lines = ["# Is the cheap shape indicator a faithful proxy?", "",
             "tag: %s    designs: %d" % (args.tag, len(rows)), "",
             "## Shape versus the commercial reference", "",
             "| design | pdk | our gini | ref gini | gini delta | max-bin ratio | busiest-1% ratio |",
             "|---|---|---|---|---|---|---|"]
    for r in sorted(rows, key=lambda x: -x["delta"]["gini"]):
        lines.append("| %s | %s | %.4f | %.4f | %+.4f | %.3f | %.3f |" % (
            r["design"], r["pdk"], r["ours"]["gini"], r["reference"]["gini"],
            r["delta"]["gini"], r["delta"]["max_bin_ratio"], r["delta"]["busiest1pct_ratio"]))
    gd = [r["delta"]["gini"] for r in rows]
    mb = [r["delta"]["max_bin_ratio"] for r in rows]
    lines += ["", "median gini delta %+.4f (we are more clustered on %d/%d designs)" % (
        st.median(gd), sum(1 for v in gd if v > 0), len(gd)),
        "median max-bin ratio %.3f" % st.median(mb), ""]

    have = [r for r in rows if r.get("egr_max") is not None]
    if len(have) >= 5:
        lines += ["## Does shape predict EGR max (our own, on this design set)?", "",
                  "| indicator | vs EGR max (rho) | pairwise discordance | vs EGR union (rho) | vs HPWL (rho) |",
                  "|---|---|---|---|---|"]
        for lab, key in (("our gini", lambda r: r["ours"]["gini"]),
                         ("our max bin", lambda r: r["ours"]["max_bin"]),
                         ("our busiest-1% share", lambda r: r["ours"]["busiest1pct_share"]),
                         ("gini delta vs reference", lambda r: r["delta"]["gini"]),
                         ("max-bin ratio vs reference", lambda r: r["delta"]["max_bin_ratio"])):
            xs = [key(r) for r in have]
            em = [r["egr_max"] for r in have]
            eu = [r["egr_union"] for r in have]
            hp = [r["hpwl"] for r in have]
            lines.append("| %s | %s | %s | %s | %s |" % (
                lab,
                ("%+.3f" % spearman(xs, em)) if spearman(xs, em) is not None else "n/a",
                ("%.1f%%" % (100 * discordance(xs, em))) if discordance(xs, em) is not None else "n/a",
                ("%+.3f" % spearman(xs, eu)) if spearman(xs, eu) is not None else "n/a",
                ("%+.3f" % spearman(xs, hp)) if spearman(xs, hp) is not None else "n/a"))
        lines += ["", "A discordance of 0% means the indicator orders every pair the same way",
                  "the outcome does; 50% means it carries no information about the ordering.", ""]
    else:
        lines += ["## Shape versus EGR max", "",
                  "only %d designs have EGR numbers yet; the sweep is still running." % len(have), ""]

    txt = "\n".join(lines) + "\n"
    out = Path(args.out) if args.out else (R.RSI / "analysis/out" / ("cluster_%s.md" % args.tag))
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(txt)
    print(txt)
    return 0


if __name__ == "__main__":
    sys.exit(main())
