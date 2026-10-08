"""Stage 2 dynamics analysis: believed vs true improvement, VG_r and r*.

For every trajectory we recompute a rank-based score so that the believed and the
true curves live on the same scale:

  pool    = every (td, ce, seed) candidate evaluated for that design+seed
  score   = mean percentile rank over the two truth components
            (legalized HPWL, EGR union), 1.0 = best in the pool
  believed rung score = percentile rank on that rung's signal
  dQ(r)   = score(held_r) - score(start)
  VG_r    = dQ_believed(r) - dQ_true(r)
  r*      = argmax_r dQ_true(r)

Rank aggregation is used instead of a weighted sum so that no arbitrary weight
enters the scientific claim (see protocol amendment A1).
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

RUNGS = ["V0_internal_hpwl", "V1u_unlegal_hpwl", "V1_legal_hpwl", "V2_ruler"]
SIGKEY = {"V0_internal_hpwl": "V0_gp_internal_hpwl",
          "V1u_unlegal_hpwl": "V1u_def_hpwl_unlegal",
          "V1_legal_hpwl": "V1_hpwl_indep"}


def precentile(better):
    """better: list of bool-free floats, lower is better -> percentile rank in [0,1]."""
    n = len(better)
    order = sorted(range(n), key=lambda i: better[i])
    out = [0.0] * n
    i = 0
    while i < n:
        j = i
        while j + 1 < n and better[order[j + 1]] == better[order[i]]:
            j += 1
        avg = 1.0 - (i + j) / 2.0 / max(n - 1, 1)
        for k in range(i, j + 1):
            out[order[k]] = avg
        i = j + 1
    return out


def load_candidates(root, design, seed):
    ef = Path(root) / "ops.jsonl"
    rowsp = [json.loads(l) for l in (Path(root) / "ledger.jsonl").read_text().splitlines() if l.strip()]
    rows = [r for r in rowsp if r.get("arm") == "stage2-loop" and r.get("design") == design
            and r.get("seed") == seed]
    # Identity is the candidate, not the ledger line: batches produced by different
    # improver generations must not be double counted, and the latest reading of a
    # candidate is the one to keep.
    by_id, out = {}, []
    for r in rows:
        c = r.get("cand") or {}
        k = (r.get("design"), r.get("seed"), round(float(c.get("target_density", -1)), 3),
             c.get("congestion_effort"))
        by_id[k] = r
    for r in by_id.values():
        b, t = r.get("believed") or {}, r.get("true") or {}
        hp, eg = b.get("V1_hpwl_indep"), t.get("egr_total_overflow_union")
        if hp is None or eg is None:
            continue
        cand = r.get("cand") or {}
        out.append({"td": cand.get("target_density"), "ce": cand.get("congestion_effort"),
                    "hpwl": hp, "egr": eg,
                    "sig": {k: b.get(v) for k, v in SIGKEY.items()}})
    return out


def analyze(root, seed_default=1000):
    root = Path(root)
    trajs = sorted((root / "stage2").glob("*/traj_*.json"))
    pooled = defaultdict(list)
    for f in trajs:
        t = json.loads(f.read_text())
        if t.get("status") != "ok":
            continue
        key = (t["design"], t["seed"])
        if key not in pooled:
            pooled[key] = load_candidates(root, t["design"], t["seed"])
    res = {}
    for f in trajs:
        t = json.loads(f.read_text())
        if t.get("status") != "ok":
            continue
        key = (t["design"], t["seed"])
        cands = pooled.get(key) or []
        if len(cands) < 6:
            continue
        keyf = lambda c: (round(c["td"], 3), int(c["ce"]))
        idx = {keyf(c): i for i, c in enumerate(cands)}
        rh = precentile([c["hpwl"] for c in cands])
        re_ = precentile([c["egr"] for c in cands])
        truth = [0.5 * (a + b) for a, b in zip(rh, re_)]
        bel = {}
        for rung, sk in SIGKEY.items():
            vals = [c["sig"].get(rung) for c in cands]
            if any(v is None for v in vals):
                bel[rung] = None
                continue
            bel[rung] = precentile([float(v) for v in vals])
        steps = t["steps"]
        held = []
        cur = None
        for s in steps:
            if s.get("error"):
                continue
            k = keyf(s)
            if s.get("accepted"):
                cur = k
            held.append(cur)
        rows = []
        for i, s in enumerate(steps):
            if s.get("error"):
                continue
            k = held[min(i, len(held) - 1)]
            if k is None or k not in idx:
                rows.append(None)
                continue
            j = idx[k]
            rung = t["rung"]
            bj = bel.get(rung)
            rows.append({"round": s.get("round"),
                         "truth": truth[j],
                         "believed": (bj[j] if bj else None) if rung in bel else truth[j]})
        start = next((r for r in rows if r), None)
        if not start:
            continue
        seq = []
        for r in rows:
            if not r:
                continue
            seq.append({"round": r["round"],
                        "dQ_T": r["truth"] - start["truth"],
                        "dQ_V": ((r["believed"] - start["believed"]) if r["believed"] is not None
                                 else None)})
        if not seq:
            continue
        dqT = [s["dQ_T"] for s in seq]
        rstar = int(seq[int(np.argmax(dqT))]["round"])
        res[(t["design"], t["rung"], t["seed"])] = {
            "design": t["design"], "rung": t["rung"], "seed": t["seed"],
            "seq": seq, "rstar": rstar, "final_dqT": dqT[-1], "max_dqT": max(dqT),
            "final_VG": (seq[-1]["dQ_V"] - seq[-1]["dQ_T"]) if seq[-1]["dQ_V"] is not None else None,
            "loop_cost": t.get("loop_cost_total"),
        }
    return res


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=str(R.RSI_ROOT / "runs/v2"))
    ap.add_argument("--out", default=str(R.RSI / "paper/figures"))
    args = ap.parse_args()
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    res = analyze(args.root)
    lines = ["# Stage 2 - self-improvement dynamics", "",
             "trajectories analysed: %d" % len(res), "",
             "| rung | n | median final dQ_true | median final VG | share final dQ_true<0 | median r* | share interior r* |",
             "|---|---|---|---|---|---|---|"]
    fig1, ax1 = plt.subplots(1, 2, figsize=(10.0, 3.8))
    colors = {"V0_internal_hpwl": "#c53030", "V1u_unlegal_hpwl": "#dd6b20",
              "V1_legal_hpwl": "#2b6cb0", "V2_ruler": "#2f855a"}
    for rung in RUNGS:
        sub = [v for v in res.values() if v["rung"] == rung]
        if not sub:
            continue
        finT = [v["final_dqT"] for v in sub]
        finV = [v["final_VG"] for v in sub if v["final_VG"] is not None]
        rs = [v["rstar"] for v in sub]
        interior = [v for v in sub if 0 < v["rstar"] < max(s["round"] for s in v["seq"])]
        neg = sum(1 for v in sub if v["final_dqT"] < 0)
        lines.append("| %s | %d | %+.4f | %+.4f | %.0f%% | %d | %.0f%% |" % (
            rung, len(sub), st.median(finT),
            (st.median(finV) if finV else float("nan")),
            100 * neg / len(sub), int(st.median(rs)), 100 * len(interior) / len(sub)))
        byround = defaultdict(list)
        for v in sub:
            for s in v["seq"]:
                byround[s["round"]].append(s["dQ_T"])
        rounds = sorted(byround)
        med = [st.median(byround[r]) for r in rounds]
        q1 = [np.percentile(byround[r], 25) for r in rounds]
        q3 = [np.percentile(byround[r], 75) for r in rounds]
        ax1[0].plot(rounds, med, "-o", ms=3, color=colors[rung], label=rung)
        ax1[0].fill_between(rounds, q1, q3, color=colors[rung], alpha=0.15)
        byV = defaultdict(list)
        for v in sub:
            for s in v["seq"]:
                if s["dQ_V"] is not None:
                    byV[s["round"]].append(s["dQ_V"])
        if byV:
            rr = sorted(byV)
            ax1[1].plot(rr, [st.median(byV[r]) for r in rr], "--", color=colors[rung], label=rung + " believed")
    ax1[0].axhline(0, color="k", lw=0.7)
    ax1[0].set_xlabel("improvement round r")
    ax1[0].set_ylabel("true improvement dQ_T(r)")
    ax1[0].set_title("True (fair-ruler) improvement trajectory", fontsize=9)
    ax1[0].legend(fontsize=7)
    ax1[0].grid(alpha=0.3)
    ax1[1].axhline(0, color="k", lw=0.7)
    ax1[1].set_xlabel("improvement round r")
    ax1[1].set_ylabel("believed improvement dQ_V(r)")
    ax1[1].set_title("Believed improvement: what each rung sees", fontsize=9)
    ax1[1].legend(fontsize=7)
    ax1[1].grid(alpha=0.3)
    fig1.tight_layout()
    fig1.savefig(out / "fig4_dynamics.png", dpi=200)
    plt.close(fig1)
    (Path(args.out).parent / "out").mkdir(parents=True, exist_ok=True)
    (Path(args.out).parent / "out" / "stage2_dynamics.md").write_text("\n".join(lines) + "\n")
    ser = {("%s|%s|%s" % k): {"rstar": v["rstar"], "final_dqT": v["final_dqT"],
                              "final_VG": v["final_VG"], "max_dqT": v["max_dqT"],
                              "loop_cost": v["loop_cost"]} for k, v in res.items()}
    (Path(args.out).parent / "out" / "stage2_dynamics.json").write_text(json.dumps(ser, indent=1))
    print("\n".join(lines))
    return 0


if __name__ == "__main__":
    sys.exit(main())
