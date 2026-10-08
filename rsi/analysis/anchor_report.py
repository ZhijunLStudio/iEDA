"""External anchoring report: our picks against the commercial reference.

Primary use is the paired comparison of pick policies evaluated against the same
external reference with the same evaluator:
  truth-best pick (ruler-optimal)   vs   V0 attractor (what the cheap rung picks)

The absolute reading (our placement vs the reference) is reported too but with the
caveat that the reference was produced by a different tool with its own settings
and objectives, so it is an external anchor for the relative comparison rather
than a like-for-like signoff contest.
"""
import argparse
import json
import statistics as st
import sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent / "harness"))
import rsi_lib as R


def median(vals):
    vals = [v for v in vals if v is not None]
    return st.median(vals) if vals else None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--anchor", default=str(R.RSI / "analysis/out/innovus_anchor.json"))
    ap.add_argument("--out", default=str(R.RSI / "paper/figures"))
    args = ap.parse_args()
    A = json.loads(Path(args.anchor).read_text())
    rows = []
    for r in A:
        ref = r.get("reference") or {}
        if not ref.get("hpwl"):
            continue
        rows.append({"design": r["design"], "pdk": r.get("pdk"),
                     "ref_hpwl": ref.get("hpwl"), "ref_egr": ref.get("egr_total"),
                     "tb_hpwl": (r.get("our_truth_best") or {}).get("hpwl"),
                     "tb_egr": (r.get("our_truth_best") or {}).get("egr_total"),
                     "v0_hpwl": (r.get("our_v0_attractor") or {}).get("hpwl"),
                     "v0_egr": (r.get("our_v0_attractor") or {}).get("egr_total")})
    rh = [x["tb_hpwl"] / x["ref_hpwl"] for x in rows if x["tb_hpwl"]]
    vh = [x["v0_hpwl"] / x["ref_hpwl"] for x in rows if x["v0_hpwl"]]
    re_ = [x["tb_egr"] / x["ref_egr"] for x in rows if x["tb_egr"] is not None and x["ref_egr"]]
    ve = [x["v0_egr"] / x["ref_egr"] for x in rows if x["v0_egr"] is not None and x["ref_egr"]]
    paired_h = sum(1 for x in rows if x["tb_hpwl"] and x["v0_hpwl"] and x["tb_hpwl"] < x["v0_hpwl"])
    paired_e = sum(1 for x in rows if x["tb_egr"] is not None and x["v0_egr"] is not None
                   and x["tb_egr"] < x["v0_egr"])
    better_than_ref_h = sum(1 for x in rows if x["tb_hpwl"] and x["tb_hpwl"] < x["ref_hpwl"])
    lines = ["# External anchoring against the commercial reference", "",
             "Evaluator: the same independent HPWL evaluator and trial-route congestion",
             "model applied to the reference DEF and to our picks. Designs with a usable",
             "reference: %d." % len(rows), "",
             "## Relative to the reference (ratio, lower is better)", "",
             "| pick | HPWL / ref | congestion / ref |", "|---|---|---|",
             "| ruler-optimal (truth-best) | %.3f | %.3f |" % (median(rh), median(re_)),
             "| V0 attractor (cheap rung) | %.3f | %.3f |" % (median(vh), median(ve)), "",
             "## Paired comparison of the two pick policies", "",
             "- ruler-optimal HPWL lower than the V0 attractor on %d / %d designs" % (paired_h, len(rows)),
             "- ruler-optimal congestion lower than the V0 attractor on %d / %d designs" % (paired_e, len(rows)),
             "- ruler-optimal HPWL below the reference on %d / %d designs" % (better_than_ref_h, len(rows)), "",
             "## Caveat", "",
             "The reference was produced by a different tool with its own settings and",
             "objectives, so the absolute ratio is an external anchor, not a like-for-like",
             "signoff contest. The load-bearing statement is the paired one: on the same",
             "external yardstick, the pick made by the cheap verifier is worse than the pick",
             "made by the ruler, on almost every design.", "",
             "## Per design", "", "| design | pdk | ref HPWL | ruler HPWL | V0 HPWL | ref EGR | ruler EGR | V0 EGR |",
             "|---|---|---|---|---|---|---|---|"]
    for x in sorted(rows, key=lambda y: y["design"]):
        lines.append("| %s | %s | %s | %s | %s | %s | %s | %s |" % (
            x["design"], x["pdk"], x["ref_hpwl"], x["tb_hpwl"], x["v0_hpwl"],
            x["ref_egr"], x["tb_egr"], x["v0_egr"]))
    (R.RSI / "analysis/out/anchor_report.md").write_text("\n".join(lines) + "\n")

    fig, axes = plt.subplots(1, 2, figsize=(9.2, 3.6))
    for ax, key_tb, key_v0, ref_key, name in (
            (axes[0], "tb_hpwl", "v0_hpwl", "ref_hpwl", "HPWL"),
            (axes[1], "tb_egr", "v0_egr", "ref_egr", "congestion")):
        rt, rv = [], []
        for x in rows:
            if not x[ref_key]:
                continue
            if x[key_tb]:
                rt.append(100 * (x[key_tb] / x[ref_key] - 1))
            if x[key_v0]:
                rv.append(100 * (x[key_v0] / x[ref_key] - 1))
        bins = np.linspace(-60, 200, 27)
        ax.hist(rt, bins=bins, alpha=0.65, label="ruler-optimal pick", color="#2b6cb0")
        ax.hist(rv, bins=bins, alpha=0.65, label="cheap-rung pick (V0)", color="#c53030")
        ax.axvline(0, color="k", lw=0.8, ls="--")
        ax.set_xlabel("%s deviation from the commercial reference (%%)" % name, fontsize=8)
        ax.set_ylabel("designs", fontsize=8)
        ax.set_title(name, fontsize=9)
        ax.legend(fontsize=7)
        ax.grid(alpha=0.3)
    fig.suptitle("External yardstick: what the cheap verifier picks is worse", fontsize=9)
    fig.tight_layout()
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    fig.savefig(out / "fig7_external_anchor.png", dpi=200)
    plt.close(fig)
    print("\n".join(lines[:24]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
