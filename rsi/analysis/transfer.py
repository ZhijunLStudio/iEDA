"""Transfer: does a policy chosen on the source technology still win elsewhere?

Metric (protocol section 3.1, TR). A preference learned on the source domain is the
ordering of policies by final truth rank. Transfer is measured two ways:

  TR_ratio   rank achieved by the source-best policy on the target, divided by the
             rank achieved by the target-best policy (1.0 = the source choice was
             already optimal there)
  TR_rank    Spearman correlation between the source policy ordering and the target
             policy ordering (1.0 = the preference carries over unchanged)

Out-of-distribution targets are the non-sky130 technologies, which differ in
library, cell height and routing stack.
"""
import argparse
import json
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
from fidelity import spearman
from dynamics_replay import load_pool
from scheduling_pool import POLICIES, simulate

SOURCE = "sky130"
BUDGET = 140.0


def policy_table(designs, roots, seeds):
    by = defaultdict(lambda: defaultdict(list))
    for n in designs:
        pool = load_pool(roots, n)
        if len(pool) < 10:
            continue
        for pol in POLICIES:
            for sd in seeds:
                try:
                    r = simulate(n, pool, pol, sd, max_cost=BUDGET)
                except Exception:
                    r = None
                if r:
                    by[n][pol["name"]].append(r["truth"])
    return by


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=str(R.RSI_ROOT / "runs/v2"))
    ap.add_argument("--seeds", default="1000,1001,1002")
    ap.add_argument("--out", default=str(R.RSI / "paper/figures"))
    args = ap.parse_args()
    designs = R.load_designs()
    seeds = [int(s) for s in args.seeds.split(",")]
    groups = defaultdict(list)
    for n, rec in designs.items():
        p = load_pool(args.root, n)
        if len(p) >= 10:
            groups[rec.get("pdk") or "?"].append(n)
    table = {}
    for pdk, names in sorted(groups.items()):
        table[pdk] = policy_table(names, args.root, seeds)
    # per-policy median across designs, per PDK
    med = {}
    for pdk, per_design in table.items():
        med[pdk] = {}
        for pol in POLICIES:
            vals = [st.median(v[pol["name"]]) for v in per_design.values() if v.get(pol["name"])]
            if vals:
                med[pdk][pol["name"]] = st.median(vals)
    lines = ["# Transfer of an evaluation-budget preference across technologies", "",
             "Budget per run: %.0f s. Seed count: %d. Designs per technology are listed"
             % (BUDGET, len(seeds)), "at the end.", "",
             "## Median final truth rank by technology (higher is better)", "",
             "| policy | " + " | ".join(sorted(med)) + " |",
             "|---" * (len(med) + 1) + "|"]
    for pol in POLICIES:
        cells = []
        for pdk in sorted(med):
            v = med[pdk].get(pol["name"])
            cells.append("%.3f" % v if v is not None else "n/a")
        lines.append("| %s | %s |" % (pol["name"], " | ".join(cells)))
    src = med.get(SOURCE, {})
    lines += ["", "## Transfer metrics relative to the source technology", "",
              "| target | source-best policy | source-best rank on target | target-best policy | target-best rank | TR_ratio | TR_rank (Spearman of policy orderings) |",
              "|---|---|---|---|---|---|---|"]
    if src:
        sb = max(src, key=src.get)
        order = sorted(src, key=lambda p: src[p], reverse=True)
        for pdk in sorted(med):
            if pdk == SOURCE:
                continue
            t = med[pdk]
            if not t:
                continue
            tb = max(t, key=t.get)
            tr_ratio = (t.get(sb, 0.0) / tb_rank) if (tb_rank := t.get(tb, 0.0)) else float("nan")
            common = [p for p in order if p in t]
            rho = spearman([src[p] for p in common], [t[p] for p in common]) if len(common) >= 4 else None
            lines.append("| %s | %s | %.3f | %s | %.3f | %.3f | %s |" % (
                pdk, sb, t.get(sb, float("nan")), tb, tb_rank, tr_ratio,
                ("%.3f" % rho) if rho is not None else "n/a"))
    lines += ["", "## Designs per technology", ""]
    for pdk in sorted(groups):
        lines.append("- %s (%d): %s" % (pdk, len(groups[pdk]), ", ".join(sorted(groups[pdk]))))
    (R.RSI / "analysis/out").mkdir(parents=True, exist_ok=True)
    (R.RSI / "analysis/out/transfer.md").write_text("\n".join(lines) + "\n")
    Path(R.RSI / "analysis/out/transfer.json").write_text(json.dumps(
        {"median_by_pdk": med, "groups": {k: v for k, v in groups.items()}, "budget": BUDGET}, indent=1))

    fig, ax = plt.subplots(figsize=(7.6, 4.4))
    pdks = sorted(med)
    x = np.arange(len(pdks))
    w = 0.8 / max(len(POLICIES), 1)
    for i, pol in enumerate(POLICIES):
        ys = [med[p].get(pol["name"], np.nan) for p in pdks]
        ax.bar(x + i * w, ys, w, label=pol["name"])
    ax.set_xticks(x + 0.4 - w / 2, pdks, fontsize=8)
    ax.set_ylabel("median final truth rank at %.0f s" % BUDGET, fontsize=8)
    ax.set_title("Does the policy preference carry across technologies?", fontsize=9)
    ax.legend(fontsize=6, ncol=2)
    ax.grid(axis="y", alpha=0.3)
    fig.tight_layout()
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    fig.savefig(out / "fig8_transfer.png", dpi=200)
    plt.close(fig)
    print("\n".join(lines[:40]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
