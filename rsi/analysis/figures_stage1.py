"""Figures for Stage 1 (verifier fidelity).

Reads the v2 ledger, restricts to one improver_id, and draws:
  fig1  rung x truth-component Spearman rho heatmap
  fig2  selection regret of each rung (median, bootstrap CI)
  fig3  the mechanism: unlegalized HPWL vs legalized HPWL vs EGR, by density
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
import fidelity as F


def load_v2(root=None):
    root = Path(root or (R.RSI_ROOT / "runs/v2"))
    rows = [json.loads(l) for l in (root / "ledger.jsonl").read_text().splitlines() if l.strip()]
    rows = [r for r in rows if r.get("arm") == "stage1-pool"]
    seen, ded = set(), []
    for r in rows:
        k = r.get("run_id")
        if k in seen:
            continue
        seen.add(k)
        ded.append(r)
    cnt = defaultdict(int)
    for r in ded:
        cnt[r.get("improver_id")] += 1
    iid = max(cnt.items(), key=lambda kv: kv[1])[0]
    return [r for r in ded if r.get("improver_id") == iid], iid


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=None)
    ap.add_argument("--out", default=str(R.RSI / "paper/figures"))
    args = ap.parse_args()
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    rows, iid = load_v2(args.root)
    pool = F.extract(rows)
    res = F.analyze(pool)
    n_cand = sum(len(v) for v in pool.values())
    print("iid", iid, "designs", len(pool), "candidates", n_cand)

    order_r = ["V0_gp_internal_hpwl", "V0b_route_util", "V1u_unlegal_hpwl",
               "V1x_state_best_hpwl", "V1_legal_hpwl", "V2_fair_ruler"]
    order_t = ["legal_hpwl", "egr_union", "egr_max"]
    M = np.full((len(order_r), len(order_t)), np.nan)
    for i, r in enumerate(order_r):
        for j, t in enumerate(order_t):
            v = res["rho"].get((r, t))
            if v:
                M[i, j] = st.median(v)
    fig, ax = plt.subplots(figsize=(6.2, 4.4))
    im = ax.imshow(M, cmap="RdBu_r", vmin=-1, vmax=1)
    ax.set_xticks(range(len(order_t)), order_t, rotation=20, ha="right")
    ax.set_yticks(range(len(order_r)), [r.replace("_", " ") for r in order_r], fontsize=8)
    for i in range(len(order_r)):
        for j in range(len(order_t)):
            if not math.isnan(M[i, j]):
                ax.text(j, i, "%+.2f" % M[i, j], ha="center", va="center", fontsize=8,
                        color="k" if abs(M[i, j]) < 0.6 else "w")
    ax.set_title("Verifier rung vs truth component: Spearman rho\n(median over %d designs, %d candidates)"
                 % (len(pool), n_cand), fontsize=9)
    fig.colorbar(im, ax=ax, shrink=0.8)
    fig.tight_layout()
    fig.savefig(out / "fig1_fidelity_heatmap.png", dpi=200)
    plt.close(fig)

    rungs = ["V0_gp_internal_hpwl", "V0b_route_util", "V1u_unlegal_hpwl", "V1_legal_hpwl"]
    labels = ["V0 internal\nHPWL", "V0b route\nutil", "V1u unlegal\nHPWL", "V1 legal\nHPWL"]
    hp, eg = [], []
    for r in rungs:
        hp.append([100 * v for v in res["regret"][(r, "hpwl")]])
        eg.append([100 * v for v in res["regret"][(r, "egr")]])
    fig, axes = plt.subplots(1, 2, figsize=(8.6, 3.4))
    for ax, data, name, col in ((axes[0], hp, "HPWL regret (%)", "#2b6cb0"),
                                (axes[1], eg, "EGR-union regret (%)", "#c05621")):
        med = [st.median(d) if d else 0.0 for d in data]
        lo, hi = [], []
        for i, d in enumerate(data):
            if len(d) >= 3:
                a, b = float(np.percentile(d, 2.5)), float(np.percentile(d, 97.5))
            else:
                a = b = med[i]
            lo.append(max(0.0, med[i] - a))
            hi.append(max(0.0, b - med[i]))
        ax.bar(range(len(rungs)), med, yerr=[lo, hi], color=col, alpha=0.85, capsize=3)
        ax.set_xticks(range(len(rungs)), labels, fontsize=7)
        ax.set_ylabel(name, fontsize=8)
        ax.axhline(0, color="k", lw=0.6)
        ax.grid(axis="y", alpha=0.3)
    fig.suptitle("Cost of a cheap verifier: how much worse the rung-selected best candidate is\n"
                 "(same pool; median over designs, bootstrap 95% CI)", fontsize=9)
    fig.tight_layout()
    fig.savefig(out / "fig2_selection_regret.png", dpi=200)
    plt.close(fig)

    xs, ys, cs = [], [], []
    for d, cands in pool.items():
        if len(cands) < 5:
            continue
        base = [c for c in cands if c["note"].endswith("td080_ce3_s1000")]
        if not base:
            continue
        b0 = base[0]
        for c in cands:
            v1u = c.get("V1u_unlegal_hpwl") or c.get("V1_def_hpwl_record")
            if not v1u or not b0.get("V1u_unlegal_hpwl") and not b0.get("V1_def_hpwl_record"):
                continue
            r0 = b0.get("V1u_unlegal_hpwl") or b0.get("V1_def_hpwl_record")
            if not r0:
                continue
            xs.append(v1u / r0 - 1.0)
            ys.append(c["legal_hpwl"] / b0["legal_hpwl"] - 1.0)
            cs.append(c["cand"].get("target_density", 0.0))
    if xs:
        fig, axes = plt.subplots(1, 2, figsize=(9.0, 3.6))
        s = axes[0].scatter([100 * v for v in xs], [100 * v for v in ys], c=cs, cmap="viridis", s=12)
        axes[0].axhline(0, color="k", lw=0.6)
        axes[0].axvline(0, color="k", lw=0.6)
        axes[0].set_xlabel("unlegalized DEF HPWL, rel. to reference (%)", fontsize=8)
        axes[0].set_ylabel("legalized HPWL, rel. to reference (%)", fontsize=8)
        axes[0].set_title("Legalization changes the ranking", fontsize=9)
        axes[0].grid(alpha=0.3)
        fig.colorbar(s, ax=axes[0], label="target_density", shrink=0.85)
        pairs = []
        for d, cands in pool.items():
            for c in cands:
                e = c.get("egr_union")
                tdl = c["cand"].get("target_density")
                if e is not None and tdl is not None:
                    pairs.append((tdl, e))
        byt = defaultdict(list)
        for t, e in pairs:
            byt[t].append(e)
        ts = sorted(byt)
        med = [st.median(byt[t]) for t in ts]
        q1 = [np.percentile(byt[t], 25) for t in ts]
        q3 = [np.percentile(byt[t], 75) for t in ts]
        axes[1].plot(ts, med, "o-", color="#c05621")
        axes[1].fill_between(ts, q1, q3, color="#c05621", alpha=0.2)
        axes[1].set_xlabel("target_density", fontsize=8)
        axes[1].set_ylabel("EGR union overflow (truth)", fontsize=8)
        axes[1].set_title("Density vs true congestion", fontsize=9)
        axes[1].grid(alpha=0.3)
        fig.tight_layout()
        fig.savefig(out / "fig3_mechanism.png", dpi=200)
        plt.close(fig)
    print("figures written to", out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
