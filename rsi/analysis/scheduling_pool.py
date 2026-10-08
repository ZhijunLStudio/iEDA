"""Evaluation-budget policies on the frozen candidate pool (Section 7).

Same pool and same pairing logic as the dynamics replay: every policy draws from
the same evaluated candidates, is charged the measured per-stage cost, and its
final placement is scored on the truth by rank inside the pool.

Policies:
  climb on a fixed rung            greedy acceptance on that rung's signal
  climb on the truth-shaped rule    Pareto acceptance (the strongest rung)
  screen then confirm               draw k, rank by a screening rung, confirm the
                                    best m with the strongest rung, move to the
                                    best confirmed

A policy run ends when it has visited every candidate in the pool or reached a
round cap, so budget differences come only from what each evaluation costs.
"""
import argparse
import json
import random
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
from dynamics import precentile
from dynamics_replay import load_pool, proposals, CHARGED, START

POLICIES = [
    {"name": "climb V0 (internal wirelength)", "kind": "climb", "rung": "V0_internal_hpwl"},
    {"name": "climb V0b (route utilization)", "kind": "climb", "rung": "V0b_route_util"},
    {"name": "climb V1u (unlegalized wirelength)", "kind": "climb", "rung": "V1u_unlegal_hpwl"},
    {"name": "climb V1 (legalized wirelength)", "kind": "climb", "rung": "V1_legal_hpwl"},
    {"name": "climb V2 (fair ruler, Pareto)", "kind": "climb", "rung": "V2_ruler"},
    {"name": "screen V0 then confirm V2", "kind": "sc", "k": 8, "m": 2, "screen": "V0_internal_hpwl"},
    {"name": "screen V1u then confirm V2", "kind": "sc", "k": 8, "m": 2, "screen": "V1u_unlegal_hpwl"},
    {"name": "screen V1 then confirm V2", "kind": "sc", "k": 6, "m": 2, "screen": "V1_legal_hpwl"},
]


def simulate(design, pool, policy, seed, max_rounds=60, eps=0.10, max_cost=None):
    rnd = random.Random(R.stable_seed("policy", design, policy["name"], seed))
    if START not in pool:
        return None
    keys = list(pool)
    rk_h = precentile([pool[k]["hpwl"] for k in keys])
    rk_e = precentile([pool[k]["egr"] for k in keys])
    truth = {k: 0.5 * (a + b) for k, a, b in zip(keys, rk_h, rk_e)}
    bel = {}
    for rg in set(CHARGED):
        if rg == "V2_ruler":
            bel[rg] = dict(truth)
        else:
            vals = [pool[k][rg] for k in keys]
            if any(v is None for v in vals):
                bel[rg] = None
            else:
                bel[rg] = {k: v for k, v in zip(keys, precentile([float(v) for v in vals]))}
    def cost(k, rung):
        return sum(pool[k]["cost"][p] for p in CHARGED[rung])
    visited = set()
    spent = 0.0
    cur = START
    visited.add(cur)
    if policy["kind"] == "sc":
        spent += cost(cur, policy["screen"])
    else:
        spent += cost(cur, policy["rung"])
    for _ in range(max_rounds):
        if max_cost is not None and spent >= max_cost:
            break
        opts = [k for k in proposals(rnd, pool, cur) if k not in visited]
        if not opts:
            break
        if policy["kind"] == "climb":
            rung = policy["rung"]
            cand = opts[rnd.randrange(len(opts))]
            visited.add(cand)
            spent += cost(cand, rung)
            better = (bel[rung][cand] > bel[rung][cur]) if rung != "V2_ruler" else _pareto(pool, cand, cur)
            if better or rnd.random() < eps:
                cur = cand
        else:
            group = opts[:policy["k"]]
            if len(group) < 2:
                break
            sr = policy["screen"]
            for k in group:
                visited.add(k)
                spent += cost(k, sr)
            if bel[sr] is None:
                break
            top = sorted(group, key=lambda k: bel[sr][k], reverse=True)[:policy["m"]]
            for k in top:
                spent += cost(k, "V2_ruler")
            for k in top:
                if _pareto(pool, k, cur) or rnd.random() < eps:
                    cur = k
                    break
    return {"design": design, "policy": policy["name"], "seed": seed,
            "cost": round(spent, 3), "truth": truth[cur], "final": cur,
            "n_visited": len(visited)}


def _pareto(pool, a, b):
    return (pool[a]["hpwl"] <= pool[b]["hpwl"] and pool[a]["egr"] <= pool[b]["egr"]
            and (pool[a]["hpwl"] < pool[b]["hpwl"] or pool[a]["egr"] < pool[b]["egr"]))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=str(R.RSI_ROOT / "runs/v2"))
    ap.add_argument("--seeds", default="1000,1001,1002,1003,1004")
    ap.add_argument("--designs", default="")
    ap.add_argument("--out", default=str(R.RSI / "paper/figures"))
    ap.add_argument("--budgets", default="",
                    help="comma list of cost caps; when set, every policy runs at each cap")
    args = ap.parse_args()
    budgets = [float(x) for x in args.budgets.split(",") if x]
    designs = R.load_designs()
    names = [n for n in (args.designs.split(",") if args.designs else []) if n] or sorted(designs)
    seeds = [int(s) for s in args.seeds.split(",")]
    res = []
    for n in names:
        pool = load_pool(args.root, n)
        if len(pool) < 10:
            continue
        for pol in POLICIES:
            for sd in seeds:
                for b in (budgets or [None]):
                    try:
                        r = simulate(n, pool, pol, sd, max_cost=b)
                    except Exception:
                        r = None
                    if r:
                        r["budget"] = b
                        res.append(r)
    byp = defaultdict(list)
    for r in res:
        byp[(r["policy"], r.get("budget"))].append(r)
    lines = ["# Evaluation-budget policies on the frozen pool", "",
             "pool: %d designs, %d seeds per cell, charged at measured per-stage cost."
             % (len(set(r["design"] for r in res)), len(seeds)), ""]
    if budgets:
        lines += ["## Equal-budget comparison (final truth rank; higher is better)", "",
                  "| policy | " + " | ".join("%.0fs" % b for b in budgets) + " |",
                  "|---" * (len(budgets) + 1) + "|"]
        for pol in POLICIES:
            cells = []
            for b in budgets:
                v = byp.get((pol["name"], b)) or []
                cells.append("%.3f" % st.median([x["truth"] for x in v]) if v else "n/a")
            lines.append("| %s | %s |" % (pol["name"], " | ".join(cells)))
    lines += ["", "## Unbudgeted runs (natural stopping point)", "",
              "| policy | median cost (s) | median final truth rank | 25th | 75th |",
              "|---|---|---|---|---|"]
    for pol in POLICIES:
        v = byp.get((pol["name"], None)) or []
        if not v:
            continue
        ts = [x["truth"] for x in v]
        cs = [x["cost"] for x in v]
        lines.append("| %s | %.0f | %.4f | %.4f | %.4f |" % (
            pol["name"], st.median(cs), st.median(ts),
            np.percentile(ts, 25), np.percentile(ts, 75)))
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    (R.RSI / "analysis/out").mkdir(parents=True, exist_ok=True)
    # Budgeted and unbudgeted runs are different experiments and must not overwrite
    # each other: the paper quotes the budgeted one, and a plain regression run
    # previously clobbered it.
    suffix = "_budget" if budgets else ""
    dd = R.RSI / "analysis/out"
    (dd / ("scheduling_pool%s.md" % suffix)).write_text("\n".join(lines) + "\n")
    (dd / ("scheduling_pool%s.json" % suffix)).write_text(json.dumps(res))

    fig, ax = plt.subplots(figsize=(7.6, 4.4))
    if budgets:
        for pol in POLICIES:
            xs, ys = [], []
            for b in budgets:
                v = byp.get((pol["name"], b)) or []
                if v:
                    xs.append(b)
                    ys.append(st.median([x["truth"] for x in v]))
            if xs:
                ax.plot(xs, ys, "-o", ms=4, label=pol["name"])
                ax.annotate(pol["name"].split(" (")[0], (xs[-1], ys[-1]),
                            textcoords="offset points", xytext=(5, 4), fontsize=7)
        ax.set_xlabel("cost budget (s, measured components)")
        ax.set_ylabel("median final truth rank (1 = best in pool)")
        ax.set_title("Equal-budget comparison of evaluation policies", fontsize=9)
        ax.legend(fontsize=7)
    else:
        for pol in POLICIES:
            v = byp.get((pol["name"], None)) or []
            if not v:
                continue
            ts = [x["truth"] for x in v]
            cs = [x["cost"] for x in v]
            ax.errorbar([st.median(cs)], [st.median(ts)],
                        yerr=[[st.median(ts) - np.percentile(ts, 25)],
                              [np.percentile(ts, 75) - st.median(ts)]],
                        fmt="o", capsize=4, ms=6, label=pol["name"])
        ax.set_xlabel("cost spent (s, measured components)")
        ax.set_ylabel("final truth rank (1 = best in pool)")
        ax.set_title("Evaluation policies at their natural stopping point", fontsize=9)
        ax.legend(fontsize=7)
    ax.grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig(out / "fig5_scheduling.png", dpi=200)
    plt.close(fig)
    print("\n".join(lines))
    return 0


if __name__ == "__main__":
    sys.exit(main())
