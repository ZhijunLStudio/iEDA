"""Verification-aware scheduling, evaluated offline on the cached candidate pool.

The loop must reach a good placement under a total cost budget and may spend that
budget on cheap or expensive evaluations. Policies differ only in how they spend
it; the final placement is scored on the fair ruler (rank aggregation).

Policies
  greedy_V0 / greedy_V1u / greedy_V1 / greedy_V2
      sequential hill climb where each move is judged by that rung alone
  screen_confirm(k, m)
      draw k candidates, screen them at V0, confirm the best m at V2, move to the
      best confirmed one. Cheap screening buys breadth, the expensive rung buys
      correctness.

Cost per evaluation is the measured component cost (gp / lgdp / egr) of that
candidate, so a rung is charged exactly what it used. Comparison is at equal
cumulative cost.
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

CHARGED = {
    "V0": ("gp",),
    "V1u": ("gp",),
    "V1": ("gp", "lgdp"),
    "V2": ("gp", "lgdp", "egr"),
}


def load(root):
    rows = [json.loads(l) for l in (Path(root) / "ledger.jsonl").read_text().splitlines() if l.strip()]
    by_id, out = {}, defaultdict(list)
    for r in rows:
        if r.get("arm") != "stage2-loop":
            continue
        c0 = r.get("cand") or {}
        k = (r.get("design"), r.get("seed"), round(float(c0.get("target_density", -1)), 3),
             c0.get("congestion_effort"))
        by_id[k] = r
    for r in by_id.values():
        b, t = r.get("believed") or {}, r.get("true") or {}
        cc = r.get("cost_components") or {}
        hp, eg = b.get("V1_hpwl_indep"), t.get("egr_total_overflow_union")
        if hp is None or eg is None:
            continue
        cost = {p: float(((cc.get(p) or {}).get("wall_s")) or 0.0) for p in ("gp", "lgdp", "egr")}
        out[(r["design"], r.get("seed"))].append({
            "cand": r.get("cand") or {}, "sig": {
                "V0": b.get("V0_gp_internal_hpwl"),
                "V1u": b.get("V1u_def_hpwl_unlegal"),
                "V1": hp,
                "V2": None},
            "hpwl": hp, "egr": eg, "cost": cost})
    return out


def cost_of(c, rung):
    return sum(c["cost"][p] for p in CHARGED[rung])


def simulate(pool, policy, rng):
    """Replay-based policy simulation. Returns (cost, selected_index)."""
    n = len(pool)
    if n == 0:
        return None
    order = list(range(n))
    rng.shuffle(order)
    cursor = [0]
    spent = [0.0]

    def draw(k):
        picks = []
        for _ in range(k):
            if cursor[0] >= len(order):
                break
            picks.append(order[cursor[0]])
            cursor[0] += 1
        return picks

    def evaluate(i, rung):
        spent[0] += cost_of(pool[i], rung)
        return pool[i]

    cur = evaluate(draw(1)[0], policy["start_rung"])
    if policy["kind"] == "greedy":
        rung = policy["rung"]
        best = cur
        while True:
            cands = draw(1)
            if not cands:
                break
            c = evaluate(cands[0], rung)
            sv = c["sig"][rung]
            bv = best["sig"][rung]
            if rung == "V2":
                if c["hpwl"] <= best["hpwl"] and c["egr"] <= best["egr"]:
                    best = c
            elif sv is not None and bv is not None and sv < bv:
                best = c
        return spent[0], best
    k, m, srung = policy["k"], policy["m"], policy.get("screen_rung", "V0")
    best = cur
    while True:
        group = draw(k)
        if len(group) < 2:
            break
        if srung != "V2":
            for i in group:
                evaluate(i, srung)
        ranked = sorted(group, key=lambda i: (pool[i]["sig"][srung]
                                             if pool[i]["sig"].get(srung) is not None else 1e18))
        top = ranked[:m]
        for i in top:
            evaluate(i, "V2")
        top_true = [i for i in top if pool[i]["hpwl"] is not None and pool[i]["egr"] is not None]
        for i in top_true:
            c = pool[i]
            if pool[i]["hpwl"] <= best["hpwl"] and pool[i]["egr"] <= best["egr"]:
                best = c
                break
    return spent[0], best


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=str(R.RSI_ROOT / "runs/v2"))
    ap.add_argument("--out", default=str(R.RSI / "paper/figures"))
    ap.add_argument("--repeats", type=int, default=20)
    args = ap.parse_args()
    pools = load(args.root)
    pools = {k: v for k, v in pools.items() if len(v) >= 8}
    policies = [
        {"name": "greedy V0", "kind": "greedy", "rung": "V0", "start_rung": "V0"},
        {"name": "greedy V1u", "kind": "greedy", "rung": "V1u", "start_rung": "V1u"},
        {"name": "greedy V1", "kind": "greedy", "rung": "V1", "start_rung": "V1"},
        {"name": "greedy V2", "kind": "greedy", "rung": "V2", "start_rung": "V2"},
        {"name": "screen V0->V2 k8 m2", "kind": "sc", "k": 8, "m": 2,
         "start_rung": "V0", "screen_rung": "V0"},
        {"name": "screen V1u->V2 k8 m2", "kind": "sc", "k": 8, "m": 2,
         "start_rung": "V1u", "screen_rung": "V1u"},
        {"name": "screen V1->V2 k6 m2", "kind": "sc", "k": 6, "m": 2,
         "start_rung": "V1", "screen_rung": "V1"},
        {"name": "screen V1->V2 k10 m3", "kind": "sc", "k": 10, "m": 3,
         "start_rung": "V1", "screen_rung": "V1"},
    ]
    results = defaultdict(list)
    for key, pool in pools.items():
        n = len(pool)
        ranks = precentile([c["hpwl"] for c in pool])
        eranks = precentile([c["egr"] for c in pool])
        truth = [0.5 * (a + b) for a, b in zip(ranks, eranks)]
        idx = {id(c): i for i, c in enumerate(pool)}
        for pol in policies:
            for rep in range(args.repeats):
                rng = random.Random(R.stable_seed(key[0], key[1], pol["name"], rep))
                out = simulate(pool, pol, rng)
                if not out:
                    continue
                cost, best = out
                results[pol["name"]].append({"design": key[0], "cost": cost,
                                             "truth": truth[idx[id(best)]]})
    lines = ["# Verification-aware scheduling (offline replay on the cached pool)", "",
             "pool: %d design-seeds, %d policies" % (len(pools), len(policies)), "",
             "| policy | median cost | median final truth score | 25th pct | 75th pct |",
             "|---|---|---|---|---|"]
    fig, ax = plt.subplots(figsize=(6.4, 4.0))
    for pol in policies:
        v = results[pol["name"]]
        if not v:
            continue
        ts = [x["truth"] for x in v]
        cs = [x["cost"] for x in v]
        lines.append("| %s | %.0f | %.4f | %.4f | %.4f |" % (
            pol["name"], st.median(cs), st.median(ts),
            np.percentile(ts, 25), np.percentile(ts, 75)))
        ax.scatter([st.median(cs)], [st.median(ts)], s=45, label=pol["name"])
        ax.errorbar([st.median(cs)], [st.median(ts)],
                    yerr=[[st.median(ts) - np.percentile(ts, 25)],
                          [np.percentile(ts, 75) - st.median(ts)]], capsize=3)
    ax.set_xlabel("median cost spent (s, measured components)")
    ax.set_ylabel("final truth score (rank aggregate, 1 = best in pool)")
    ax.set_title("Equal-budget comparison of evaluation schedules", fontsize=9)
    ax.grid(alpha=0.3)
    ax.legend(fontsize=7)
    fig.tight_layout()
    outdir = Path(args.out)
    outdir.mkdir(parents=True, exist_ok=True)
    fig.savefig(outdir / "fig5_scheduling.png", dpi=200)
    plt.close(fig)
    (R.RSI / "analysis/out").mkdir(parents=True, exist_ok=True)
    (R.RSI / "analysis/out/stage3_scheduling.md").write_text("\n".join(lines) + "\n")
    print("\n".join(lines))
    return 0


if __name__ == "__main__":
    sys.exit(main())
