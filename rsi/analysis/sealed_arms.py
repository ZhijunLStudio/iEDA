"""Arms A0/A1/A2 evaluated per split, including the sealed designs.

A0  no write-back: the start candidate is the answer.
A1  a loop with a fixed acceptance rule (one rung), 16 rounds.
A2  the same loop but the rule is the fair ruler (Pareto), i.e. the strongest
    available verifier: the protocol's A2 arm is the improver updating its rule, and
    in this replay the strongest-rule arm is the closest executable proxy for it.
    The live A2 implementation (stage3_arms.py) switches its own rule online; the
    replay version is reported here because it needs no new compute.

The sealed designs are reported here and nowhere else. They were measured as part of
the candidate pool before the split existed, and they are never used to choose a
policy, a threshold or a hyperparameter: the comparison below is a report, which is
what the protocol reserves them for.

Output: per split, the true gain of each arm and the gain per unit cost, so the paper
can state the result on held-out designs rather than on the designs that suggested the
method.
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
from dynamics_replay import load_pool, replay

ARMS = {"A0 (start state, no write-back)": None,
        "A1 (fixed rung, unlegalized wirelength)": "V1u_unlegal_hpwl",
        "A1 (fixed rung, legalized wirelength)": "V1_legal_hpwl",
        "A2 (fair ruler, Pareto)": "V2_ruler"}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=str(R.RSI_ROOT / "runs/v2"))
    ap.add_argument("--rounds", type=int, default=16)
    ap.add_argument("--seeds", default="1000,1001,1002,1003,1004")
    ap.add_argument("--out", default=str(R.RSI / "paper/figures"))
    args = ap.parse_args()
    import splits as SP
    s = SP.load()
    seeds = [int(x) for x in args.seeds.split(",")]
    res = defaultdict(lambda: defaultdict(list))
    costs = defaultdict(lambda: defaultdict(list))
    for split in ("dev", "val", "sealed", "ood"):
        for n in s.get(split, []):
            pool = load_pool(args.root, n)
            if len(pool) < 10:
                continue
            for sd in seeds:
                for arm, rung in ARMS.items():
                    if rung is None:
                        keys = list(pool)
                        from dynamics import precentile
                        rk_h = precentile([pool[k]["hpwl"] for k in keys])
                        rk_e = precentile([pool[k]["egr"] for k in keys])
                        truth = {k: 0.5 * (a + b) for k, a, b in zip(keys, rk_h, rk_e)}
                        start = (0.80, 3, 1000)
                        if start not in truth:
                            continue
                        res[split][arm].append(0.0)
                        costs[split][arm].append(0.0)
                        continue
                    r = replay(n, pool, rung, sd, args.rounds)
                    if not r:
                        continue
                    res[split][arm].append(r["final_dqT"])
                    costs[split][arm].append(r["cost"])
    lines = ["# Arms by split, including the sealed designs", "",
             "Seeds per cell: %d. Rounds: %d. True gain is measured on the fair ruler by" % (len(seeds), args.rounds),
             "rank inside each design's candidate pool; cost is the measured per-stage sum.", "",
             "| split | arm | n | median true gain | median cost (s) | gain per s |",
             "|---|---|---|---|---|---|"]
    for split in ("dev", "val", "sealed", "ood"):
        for arm in ARMS:
            v = res[split].get(arm) or []
            c = costs[split].get(arm) or []
            if not v:
                continue
            mc = st.median(c) if c else 0.0
            lines.append("| %s | %s | %d | %+.4f | %.0f | %s |" % (
                split, arm, len(v), st.median(v), mc,
                ("%.2e" % (st.median(v) / mc) if mc else "n/a")))
    (R.RSI / "analysis/out").mkdir(parents=True, exist_ok=True)
    (R.RSI / "analysis/out/sealed_arms.md").write_text("\n".join(lines) + "\n")
    Path(R.RSI / "analysis/out/sealed_arms.json").write_text(json.dumps(
        {k: {a: v for a, v in d.items()} for k, d in res.items()}, indent=1, default=str))

    splits_present = [x for x in ("dev", "val", "sealed", "ood") if res[x]]
    arms = [a for a in ARMS if any(res[x].get(a) for x in splits_present)]
    x = np.arange(len(splits_present))
    w = 0.8 / max(len(arms), 1)
    fig, ax = plt.subplots(figsize=(8.4, 4.2))
    for i, arm in enumerate(arms):
        ys = [st.median(res[sp][arm]) if res[sp].get(arm) else np.nan for sp in splits_present]
        ax.bar(x + i * w, ys, w, label=arm)
    ax.axhline(0, color="k", lw=0.8)
    ax.set_xticks(x + 0.4 - w / 2, splits_present, fontsize=8)
    ax.set_ylabel("median true gain over 16 rounds", fontsize=8)
    ax.set_title("Arms by split, sealed designs reported once and used for nothing else", fontsize=9)
    ax.legend(fontsize=6)
    ax.grid(axis="y", alpha=0.3)
    fig.tight_layout()
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    fig.savefig(out / "fig9_arms_by_split.png", dpi=200)
    plt.close(fig)
    print("\n".join(lines))
    return 0


if __name__ == "__main__":
    sys.exit(main())
