"""Dynamics by replay over the frozen candidate pool.

The live dynamics run (stage2_loop) is slow because every round needs a fresh
placement. The same question can be asked with no new compute at all, by replaying
the loop over the candidate pool that Stage 1 already evaluated with the truth.
The replay is fully deterministic and paired across rungs: every rung sees the same
candidates, the same start, and the same truth, so the only thing that differs is
the signal the loop is allowed to look at.

This is a replay of the loop, not the loop itself. It is reported as such, and the
live run is kept as corroboration.

Quantity of interest, per (design, rung, seed):
  believed(r)  percentile rank of the rung's own signal at the held state
  truth(r)     mean percentile rank of (legalized HPWL, congestion union)
  dQ_T(r)      truth(r) - truth(0)          true improvement
  dQ_V(r)      believed(r) - believed(0)    perceived improvement
  VG_r         dQ_V(r) - dQ_T(r)
  r*           the round that maximizes dQ_T
  NSI          final dQ_T / total measured cost
Costs are the recorded per-candidate stage costs, so a rung is charged exactly
what it used and NSI is comparable across rungs.
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

RUNGS = ["V0_internal_hpwl", "V0b_route_util", "V1u_unlegal_hpwl", "V1_legal_hpwl", "V2_ruler"]
CHARGED = {"V0_internal_hpwl": ("gp",), "V0b_route_util": ("gp",),
           "V1u_unlegal_hpwl": ("gp",), "V1_legal_hpwl": ("gp", "lgdp"),
           "V2_ruler": ("gp", "lgdp", "egr")}
TD_STEPS = [0.55, 0.60, 0.65, 0.70, 0.75, 0.80, 0.85, 0.90, 0.95]
CES = [0, 3, 7]
SEEDS = [1000, 1001, 1002]
START = (0.80, 3, 1000)


def load_pool(root, design):
    rows = [json.loads(l) for l in (Path(root) / "ledger.jsonl").read_text().splitlines() if l.strip()]
    by = {}
    for r in rows:
        if r.get("arm") != "stage1-pool" or r.get("design") != design:
            continue
        c = r.get("cand") or {}
        td, ce, sd = c.get("target_density"), c.get("congestion_effort"), c.get("seed")
        if td is None or ce is None or sd is None:
            continue
        b, t = r.get("believed") or {}, r.get("true") or {}
        cc = r.get("cost_components") or r.get("cost") or {}
        hp, eg = b.get("V1_hpwl_indep"), t.get("egr_total_overflow_union")
        if hp is None or eg is None:
            continue
        cost = {p: float(((cc.get(p) or {}).get("wall_s")) or 0.0) for p in ("gp", "lgdp", "egr")}
        k = (round(float(td), 3), int(ce), int(sd))
        has_cost = any(v > 0 for v in cost.values())
        if k in by and not has_cost and any(v > 0 for v in by[k]["cost"].values()):
            # Rows appended on a cache hit may omit the cost components. The
            # measurement must not be lost, so a row without cost never replaces a
            # row that has it.
            continue
        by[k] = {
            "key": (round(float(td), 3), int(ce), int(sd)),
            "V0_internal_hpwl": b.get("V0_gp_internal_hpwl"),
            "V0b_route_util": b.get("V0b_route_util"),
            "V1u_unlegal_hpwl": b.get("V1u_def_hpwl_unlegal"),
            "V1_legal_hpwl": hp,
            "V2_ruler": None,
            "hpwl": hp, "egr": eg, "cost": cost}
    return by


def proposals(rnd, pool, key, tries=12):
    out = []
    td, ce, sd = key
    for _ in range(tries):
        k = rnd.random()
        if k < 0.6:
            i = TD_STEPS.index(td) if td in TD_STEPS else None
            if i is None:
                continue
            j = max(0, min(len(TD_STEPS) - 1, i + rnd.choice([-2, -1, 1, 2])))
            cand = (TD_STEPS[j], ce, sd)
        elif k < 0.9:
            j = CES.index(ce) if ce in CES else None
            if j is None:
                continue
            cand = (td, CES[max(0, min(len(CES) - 1, j + rnd.choice([-1, 1])))], sd)
        else:
            cand = (td, ce, rnd.choice([s for s in SEEDS if s != sd]))
        cand = (round(cand[0], 3), int(cand[1]), int(cand[2]))
        if cand in pool and cand != key and cand not in out:
            out.append(cand)
    return out


def replay(design, pool, rung, seed, rounds, eps=0.10):
    if START not in pool:
        return None
    rnd = random.Random(R.stable_seed("replay", design, rung, seed))
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
    t0, b0 = truth[cur], bel[cur]
    seq = [{"round": 0, "key": cur, "truth": t0, "believed": b0, "cost": 0.0}]
    cum = 0.0
    for rd in range(1, rounds + 1):
        opts = proposals(rnd, pool, cur)
        if not opts:
            break
        cand = opts[rnd.randrange(len(opts))]
        c = sum(pool[cand]["cost"][p] for p in CHARGED[rung])
        cum += c
        acc = False
        if rung == "V2_ruler":
            if (pool[cand]["hpwl"] <= pool[cur]["hpwl"] and pool[cand]["egr"] <= pool[cur]["egr"]
                    and (pool[cand]["hpwl"] < pool[cur]["hpwl"] or pool[cand]["egr"] < pool[cur]["egr"])):
                acc = True
        elif bel[cand] > bel[cur]:
            acc = True
        if not acc and rnd.random() < eps:
            acc = True
        seq.append({"round": rd, "key": cand, "truth": truth[cand], "believed": bel[cand],
                    "cost": c, "cum_cost": round(cum, 3), "accepted": acc})
        if acc:
            cur = cand
    held = []
    curk = START
    n_acc = n_harmful = n_confirmed = 0
    for s in seq:
        if s.get("accepted") and s["round"] > 0:
            n_acc += 1
            if truth[s["key"]] < truth[curk]:
                n_harmful += 1
            if truth[s["key"]] > truth[curk]:
                n_confirmed += 1
            curk = s["key"]
        held.append({"round": s["round"], "key": curk, "truth": truth[curk],
                     "believed": bel[curk], "cost": s["cost"]})
    dqT = [h["truth"] - held[0]["truth"] for h in held]
    dqV = [h["believed"] - held[0]["believed"] for h in held]
    rstar = int(held[int(np.argmax(dqT))]["round"])
    spent = cum if cum > 0 else 1e-9
    return {"design": design, "rung": rung, "seed": seed,
            "seq": [{"round": h["round"], "dQ_T": dqT[i], "dQ_V": dqV[i]} for i, h in enumerate(held)],
            "rstar": rstar, "final_dqT": dqT[-1], "max_dqT": max(dqT),
            "final_VG": dqV[-1] - dqT[-1], "cost": round(cum, 3),
            "NSI": round(dqT[-1] / spent, 8), "n_rounds": len(held) - 1,
            "final_key": held[-1]["key"],
            "n_accepted": n_acc, "n_accepted_harmful": n_harmful,
            "n_accepted_confirmed": n_confirmed,
            "absorption_rate": (round(n_confirmed / n_acc, 4) if n_acc else None)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=str(R.RSI_ROOT / "runs/v2"))
    ap.add_argument("--rounds", type=int, default=16)
    ap.add_argument("--seeds", default="1000,1001,1002,1003,1004")
    ap.add_argument("--designs", default="")
    ap.add_argument("--out", default=str(R.RSI / "paper/figures"))
    args = ap.parse_args()
    designs = R.load_designs()
    names = [n for n in (args.designs.split(",") if args.designs else []) if n] or sorted(designs)
    seeds = [int(s) for s in args.seeds.split(",")]
    res = []
    for n in names:
        pool = load_pool(args.root, n)
        if len(pool) < 10:
            continue
        for rung in RUNGS:
            for sd in seeds:
                r = replay(n, pool, rung, sd, args.rounds)
                if r:
                    res.append(r)
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    (R.RSI / "analysis/out").mkdir(parents=True, exist_ok=True)
    (R.RSI / "analysis/out/dynamics_replay.json").write_text(json.dumps(res))

    byr = defaultdict(list)
    for r in res:
        byr[r["rung"]].append(r)
    lines = ["# Dynamics by replay over the frozen candidate pool", "",
             "pool: %d designs, %d trajectories (rounds up to %d, %d seeds)" % (
                 len(set(r["design"] for r in res)), len(res), args.rounds, len(seeds)), "",
             "| rung | n | cost (s) | dQ_T(final) | worse | VG(final) | r* | interior r* | NSI | accepted | of which harmful | AR (confirmed share) |",
             "|---|---|---|---|---|---|---|---|---|---|---|---|"]
    colors = {"V0_internal_hpwl": "#c53030", "V0b_route_util": "#dd6b20",
              "V1u_unlegal_hpwl": "#805ad5", "V1_legal_hpwl": "#2b6cb0", "V2_ruler": "#2f855a"}
    fig, axes = plt.subplots(1, 3, figsize=(13.0, 3.8))
    for rung in RUNGS:
        sub = byr.get(rung) or []
        if not sub:
            continue
        finT = [r["final_dqT"] for r in sub]
        finV = [r["final_VG"] for r in sub]
        rs = [r["rstar"] for r in sub]
        interior = [r for r in sub if 0 < r["rstar"] < max(s["round"] for s in r["seq"])]
        neg = sum(1 for r in sub if r["final_dqT"] < 0)
        nsi = [r["NSI"] for r in sub if r["NSI"] is not None]
        acc = [r["n_accepted"] for r in sub]
        harm = [r["n_accepted_harmful"] for r in sub]
        ar = [r["absorption_rate"] for r in sub if r["absorption_rate"] is not None]
        lines.append("| %s | %d | %.0f | %+.4f | %.0f%% | %+.4f | %d | %.0f%% | %.2e | %.1f | %.1f | %.2f |" % (
            rung, len(sub), st.median([r["cost"] for r in sub]), st.median(finT),
            100 * neg / len(sub), st.median(finV), int(st.median(rs)),
            100 * len(interior) / len(sub), (st.median(nsi) if nsi else float("nan")),
            st.median(acc), st.median(harm), (st.median(ar) if ar else float("nan"))))
        def curve(key):
            byrd = defaultdict(list)
            for r in sub:
                for s in r["seq"]:
                    byrd[s["round"]].append(s[key])
            rr = sorted(byrd)
            return rr, [st.median(byrd[x]) for x in rr], \
                [np.percentile(byrd[x], 25) for x in rr], [np.percentile(byrd[x], 75) for x in rr]
        for ax, key, ylab, ttl in ((axes[0], "dQ_T", "true improvement dQ_T(r)",
                                    "True improvement by rung"),
                                   (axes[1], "dQ_V", "believed improvement dQ_V(r)",
                                    "Believed improvement by rung")):
            rr, med, q1, q3 = curve(key)
            ax.plot(rr, med, "-o", ms=3, color=colors[rung], label=rung)
            ax.fill_between(rr, q1, q3, color=colors[rung], alpha=0.15)
            if key == "dQ_T":
                ax.axhline(0, color="k", lw=0.7)
            ax.set_xlabel("round r")
            ax.set_ylabel(ylab)
            ax.set_title(ttl, fontsize=9)
            ax.grid(alpha=0.3)
        vg = defaultdict(list)
        for r in sub:
            for i, s in enumerate(r["seq"]):
                vg[i].append(s["dQ_V"] - s["dQ_T"])
        rr = sorted(vg)
        axes[2].plot(rr, [st.median(vg[x]) for x in rr], "-o", ms=3, color=colors[rung], label=rung)
    axes[0].legend(fontsize=7)
    axes[2].axhline(0, color="k", lw=0.7)
    axes[2].set_xlabel("round r")
    axes[2].set_ylabel("verifiability gap VG_r")
    axes[2].set_title("Gap between believed and true improvement", fontsize=9)
    axes[2].grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig(out / "fig4_dynamics.png", dpi=200)
    plt.close(fig)
    (R.RSI / "analysis/out/dynamics_replay.md").write_text("\n".join(lines) + "\n")
    print("\n".join(lines))
    return 0


if __name__ == "__main__":
    sys.exit(main())
