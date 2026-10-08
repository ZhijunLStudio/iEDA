"""Mechanism accounting: which term of the model dominates?

Proposition 1 states E[dQ_T(r)] = p*g(r) - (1-p)*c*A(r): true improvement is the
confirmed gains minus the accumulated damage from harmful edits the verifier let
through. That decomposition is measurable, so instead of fitting a parametric curve we
account for it directly.

For every trajectory we split the accepted edits into confirmed (the truth improved)
and harmful (the truth got worse) and sum the two contributions to the final truth
change. The two terms then have to add up to the observed dQ_T, which is the identity
the model asserts, and the comparison between them shows which mechanism is driving
each rung.
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
from dynamics import precentile
from dynamics_replay import CHARGED, START, load_pool, proposals

RUNGS = ["V0_internal_hpwl", "V0b_route_util", "V1u_unlegal_hpwl", "V1_legal_hpwl", "V2_ruler"]
EPS = 0.10


def account(design, pool, rung, seed, rounds):
    rnd = __import__("random").Random(R.stable_seed("account", design, rung, seed))
    if START not in pool:
        return None
    keys = list(pool)
    rk_h = precentile([pool[k]["hpwl"] for k in keys])
    rk_e = precentile([pool[k]["egr"] for k in keys])
    truth = {k: 0.5 * (a + b) for k, a, b in zip(keys, rk_h, rk_e)}
    if rung == "V2_ruler":
        bel = dict(truth)
    else:
        vals = [pool[k][rung] for k in keys]
        if any(v is None for v in vals):
            return None
        bel = {k: v for k, v in zip(keys, precentile([float(v) for v in vals]))}
    cur = START
    gain = loss = 0.0
    n_conf = n_harm = n_neutral = 0
    cum = 0.0
    for _ in range(rounds):
        opts = proposals(rnd, pool, cur)
        if not opts:
            break
        cand = opts[rnd.randrange(len(opts))]
        cum += sum(pool[cand]["cost"][p] for p in CHARGED[rung])
        acc = False
        if rung == "V2_ruler":
            a, b = pool[cand], pool[cur]
            if (a["hpwl"] <= b["hpwl"] and a["egr"] <= b["egr"]
                    and (a["hpwl"] < b["hpwl"] or a["egr"] < b["egr"])):
                acc = True
        elif bel[cand] > bel[cur]:
            acc = True
        if not acc and rnd.random() < EPS:
            acc = True
        if acc:
            d = truth[cand] - truth[cur]
            if d > 0:
                gain += d
                n_conf += 1
            elif d < 0:
                loss += -d
                n_harm += 1
            else:
                n_neutral += 1
            cur = cand
    return {"design": design, "rung": rung, "seed": seed,
            "confirmed_gain": gain, "harmful_loss": loss,
            "net": gain - loss, "n_confirmed": n_conf, "n_harmful": n_harm,
            "n_neutral": n_neutral, "cost": round(cum, 3)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=str(R.RSI_ROOT / "runs/v2"))
    ap.add_argument("--rounds", type=int, default=16)
    ap.add_argument("--seeds", default="1000,1001,1002,1003,1004")
    ap.add_argument("--out", default=str(R.RSI / "paper/figures"))
    args = ap.parse_args()
    designs = R.load_designs()
    seeds = [int(s) for s in args.seeds.split(",")]
    res = []
    for n in sorted(designs):
        pool = load_pool(args.root, n)
        if len(pool) < 10:
            continue
        for rung in RUNGS:
            for sd in seeds:
                a = account(n, pool, rung, sd, args.rounds)
                if a:
                    res.append(a)
    byr = defaultdict(list)
    for r in res:
        byr[r["rung"]].append(r)
    lines = ["# Mechanism accounting: confirmed gains versus accumulated damage", "",
             "Per-trajectory decomposition of the final truth change. The two terms are",
             "measured separately. The identity net = confirmed gain - harmful loss holds",
             "exactly on every trajectory by construction; the table reports medians, and the",
             "median of a difference is not the difference of medians, which is why the two net",
             "columns differ slightly.", "",
             "| rung | confirmed gain | harmful loss | net (measured) | net (identity) | confirmed accepts | harmful accepts |",
             "|---|---|---|---|---|---|---|"]
    for rung in RUNGS:
        v = byr.get(rung) or []
        if not v:
            continue
        g = st.median([x["confirmed_gain"] for x in v])
        l = st.median([x["harmful_loss"] for x in v])
        net = st.median([x["net"] for x in v])
        lines.append("| %s | %+.4f | %+.4f | %+.4f | %+.4f | %.1f | %.1f |" % (
            rung, g, l, net, g - l,
            st.median([x["n_confirmed"] for x in v]), st.median([x["n_harmful"] for x in v])))
    (R.RSI / "analysis/out").mkdir(parents=True, exist_ok=True)
    (R.RSI / "analysis/out/mechanism.md").write_text("\n".join(lines) + "\n")
    Path(R.RSI / "analysis/out/mechanism.json").write_text(json.dumps(res))

    present = [r for r in RUNGS if byr.get(r)]
    x = np.arange(len(present))
    gains = [st.median([y["confirmed_gain"] for y in byr[r]]) for r in present]
    losses = [st.median([y["harmful_loss"] for y in byr[r]]) for r in present]
    nets = [st.median([y["net"] for y in byr[r]]) for r in present]
    fig, ax = plt.subplots(figsize=(8.6, 4.0))
    ax.bar(x - 0.22, gains, 0.4, label="confirmed gain", color="#2f855a")
    ax.bar(x + 0.22, [-l for l in losses], 0.4, label="harmful loss (negated)", color="#c53030")
    ax.plot(x, nets, "ko--", ms=6, label="net (measured)")
    ax.axhline(0, color="k", lw=0.8)
    ax.set_xticks(x, [r.replace("_", "\n") for r in present], fontsize=7)
    ax.set_ylabel("truth-rank change over 16 rounds", fontsize=8)
    ax.set_title("The two terms of the model, measured: damage outweighs gain when the verifier is weak", fontsize=9)
    ax.legend(fontsize=7)
    ax.grid(axis="y", alpha=0.3)
    fig.tight_layout()
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    fig.savefig(out / "fig11_mechanism.png", dpi=200)
    plt.close(fig)
    print("\n".join(lines))
    return 0


if __name__ == "__main__":
    sys.exit(main())
