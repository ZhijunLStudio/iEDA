"""Is the fair ruler itself a proxy? Compare every signal against timing.

Joins the Stage 1 geometry records with the Stage 1T timing records on
(design, candidate), then asks two questions per design:

  rho   how well does each signal rank timing (setup WNS, setup TNS)?
  regret  if the fair ruler picks the best candidate for geometry, how much
          timing does that cost compared with the timing-best candidate?

The second question is the one that matters for the paper's framing: if a
geometry-optimal placement is not timing-optimal, then "truth" is a rung too.
"""
import argparse
import json
import math
import statistics as st
import sys
from collections import defaultdict
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent / "harness"))
import rsi_lib as R
from fidelity import spearman, bootstrap_ci, _v1u, SIGNAL, TRUTHS


def fmt_ci(v):
    if not v:
        return "n/a"
    lo, hi = bootstrap_ci(v)
    if lo is None:
        return "%+.3f (n=%d)" % (st.median(v), len(v))
    return "%+.3f [%+.3f,%+.3f]" % (st.median(v), lo, hi)


def load(root, iid_geom=None, iid_timing=None):
    root = Path(root)
    rows = [json.loads(l) for l in (root / "ledger.jsonl").read_text().splitlines() if l.strip()]
    geom = {}
    tim = {}
    for r in rows:
        arm = r.get("arm")
        key = (r.get("design"), (r.get("note") or "").replace("candidate=", ""))
        if arm == "stage1-pool":
            if iid_geom and r.get("improver_id") != iid_geom:
                continue
            b, t = r.get("believed") or {}, r.get("true") or {}
            geom[key] = {"V0": b.get("V0_gp_internal_hpwl"),
                         "V0b": b.get("V0b_route_util"),
                         "V1u": _v1u(b, t),
                         "V1": b.get("V1_hpwl_indep"),
                         "egr": t.get("egr_total_overflow_union"),
                         "egr_max": t.get("egr_max_overflow_union")}
        elif arm == "stage1-timing":
            if iid_timing and r.get("improver_id") != iid_timing:
                continue
            t = (r.get("true") or {}).get("timing") or {}
            if t:
                tim[key] = t
    return geom, tim


def analyze(geom, tim):
    pools = defaultdict(list)
    for k, g in geom.items():
        if k not in tim:
            continue
        t = tim[k]
        if t.get("setup_tns") is None or g.get("V1") is None or g.get("egr") is None:
            continue
        pools[k[0]].append({"tag": k[1], "V0": g["V0"], "V0b": g["V0b"], "V1u": g["V1u"],
                            "V1": g["V1"], "egr": g["egr"], "egr_max": g["egr_max"],
                            "setup_tns": t["setup_tns"], "setup_wns": t.get("setup_wns"),
                            "hold_wns": t.get("hold_wns")})
    rho = defaultdict(list)
    per_design = {}
    regret = {"geo_pick_vs_timing": [], "timing_pick_vs_geo": []}
    for d, cands in pools.items():
        if len(cands) < 6:
            continue
        pd = {"n": len(cands)}
        sigs = {"V0": lambda c: c["V0"], "V0b": lambda c: c["V0b"], "V1u": lambda c: c["V1u"],
                "V1": lambda c: c["V1"], "fair_ruler": lambda c: None}
        tcomp = {"setup_tns": lambda c: c["setup_tns"], "setup_wns": lambda c: c["setup_wns"],
                 "hold_wns": lambda c: c["hold_wns"]}
        for tn, tf in tcomp.items():
            ys = [tf(c) for c in cands]
            if any(y is None for y in ys):
                continue
            for sn, sf in list(sigs.items()) + [("fair_ruler", lambda c: 0.5 * (
                    c["V1"] / min(x["V1"] for x in cands) + c["egr"] / max(min(x["egr"] for x in cands), 1)))]:
                xs = [sf(c) for c in cands]
                if any(x is None for x in xs):
                    continue
                r = spearman([float(x) for x in xs], [float(y) for y in ys])
                if r is not None:
                    rho[(sn, tn)].append(r)
                    pd.setdefault("rho", {})["%s|%s" % (sn, tn)] = round(r, 3)
        bhp = min(c["V1"] for c in cands)
        beg = max(min(c["egr"] for c in cands), 1)
        for c in cands:
            c["geo"] = 0.5 * (c["V1"] / bhp + c["egr"] / beg)
        geo_best = min(cands, key=lambda c: c["geo"])
        tim_best = max(cands, key=lambda c: c["setup_tns"])
        pd["geo_best"] = geo_best["tag"]
        pd["timing_best"] = tim_best["tag"]
        pd["same_pick"] = geo_best["tag"] == tim_best["tag"]
        if tim_best["setup_tns"] != 0:
            regret["geo_pick_vs_timing"].append(
                (geo_best["setup_tns"] - tim_best["setup_tns"]) / max(abs(tim_best["setup_tns"]), 1e-9))
        if bhp:
            regret["timing_pick_vs_geo"].append(tim_best["V1"] / bhp - 1.0)
        per_design[d] = pd
    return rho, regret, per_design, pools


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=str(R.RSI_ROOT / "runs/v2"))
    ap.add_argument("--out", default=str(R.RSI / "paper/figures"))
    args = ap.parse_args()
    geom, tim = load(args.root)
    print("geometry records %d, timing records %d, joined %d"
          % (len(geom), len(tim), sum(1 for k in geom if k in tim)))
    rho, regret, per_design, pools = analyze(geom, tim)
    lines = ["# Stage 1T - is the fair ruler itself a proxy?", "",
             "joined candidates: %d over %d designs" % (sum(len(v) for v in pools.values()), len(pools)), "",
             "## Spearman rho of each signal against timing (median over designs)", "",
             "| signal | vs setup TNS | vs setup WNS | vs hold WNS |", "|---|---|---|---|"]
    for sn in ("V0", "V0b", "V1u", "V1", "fair_ruler"):
        lines.append("| %s | %s | %s | %s |" % (
            sn, fmt_ci(rho.get((sn, "setup_tns"))), fmt_ci(rho.get((sn, "setup_wns"))),
            fmt_ci(rho.get((sn, "hold_wns")))))
    g = regret["geo_pick_vs_timing"]
    t = regret["timing_pick_vs_geo"]
    same = sum(1 for p in per_design.values() if p.get("same_pick"))
    lines += ["", "## Selection disagreement", "",
              "- designs where the geometry-best candidate is also the timing-best: %d / %d"
              % (same, len(per_design)),
              "- picking on geometry, timing TNS loss relative to the timing-best: median %+.3f (n=%d)"
              % (st.median(g) if g else float("nan"), len(g)),
              "- picking on timing, legalized HPWL penalty relative to the geometry-best: median %+.2f%% (n=%d)"
              % (100 * st.median(t) if t else float("nan"), len(t)),
              "", "## Per design", "", "| design | n | geometry-best | timing-best | same |",
              "|---|---|---|---|---|"]
    for d, pd in sorted(per_design.items()):
        lines.append("| %s | %d | %s | %s | %s |" % (d, pd["n"], pd.get("geo_best"), pd.get("timing_best"),
                                                     "yes" if pd.get("same_pick") else "no"))
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    (R.RSI / "analysis/out").mkdir(parents=True, exist_ok=True)
    (R.RSI / "analysis/out/stage1T_timing.md").write_text("\n".join(lines) + "\n")
    (R.RSI / "analysis/out/stage1T_timing.json").write_text(json.dumps(
        {"rho": {"%s|%s" % k: v for k, v in rho.items()},
         "regret": regret, "per_design": per_design}, indent=1))

    if g and t:
        fig, axes = plt.subplots(1, 2, figsize=(9.0, 3.6))
        axes[0].hist([100 * x for x in g], bins=18, color="#2b6cb0", alpha=0.85)
        axes[0].axvline(0, color="k", lw=0.7)
        axes[0].set_xlabel("timing TNS loss when selecting on geometry (%)", fontsize=8)
        axes[0].set_ylabel("designs", fontsize=8)
        axes[0].set_title("The fair ruler misranks timing", fontsize=9)
        axes[0].grid(alpha=0.3)
        axes[1].hist([100 * x for x in t], bins=18, color="#c05621", alpha=0.85)
        axes[1].axvline(0, color="k", lw=0.7)
        axes[1].set_xlabel("legalized HPWL penalty when selecting on timing (%)", fontsize=8)
        axes[1].set_title("and the reverse", fontsize=9)
        axes[1].grid(alpha=0.3)
        fig.tight_layout()
        fig.savefig(out / "fig6_timing_vs_ruler.png", dpi=200)
        plt.close(fig)
    print("\n".join(lines[:26]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
