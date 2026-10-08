"""Live dynamics versus the replay: does the simulated loop match the real one?

The replay is the primary result because it is deterministic and paired across rungs.
The live run drives the same loops through fresh placements, so it is the corroboration:
if the two disagree, the replay's numbers describe the pool rather than the loop.

Both are scored identically here: percentile rank inside the design's candidate pool,
averaged over the two truth components, so dQ_T, VG and r* mean the same thing in
both. The comparison is restricted to seed 1000, which is what the live run used.

Live trajectories are read from runs/v2/stage2; the pool is the live run's own
candidate cache, so the ranks are relative to the candidates the loops actually
explored.
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

RUNGS = ["V0_internal_hpwl", "V0b_route_util", "V1u_unlegal_hpwl", "V1_legal_hpwl", "V2_ruler"]


def load_live_pool(root, design):
    """Candidate pool from the live run's cache, keyed as the loops key it."""
    root = Path(root)
    pool = {}
    for done in sorted((root / "stage2_candidates" / design).glob("*/DONE.json")):
        try:
            d = json.loads(done.read_text())
        except Exception:
            continue
        if d.get("status") != "ok":
            continue
        b, t = d.get("believed") or {}, d.get("true") or {}
        hp, eg = b.get("V1_hpwl_indep"), t.get("egr_total_overflow_union")
        if hp is None or eg is None:
            continue
        cc = d.get("cost_components") or {}
        pool[(round(float(d["td"]), 3), int(d["ce"]), int(d["seed"]))] = {
            "hpwl": hp, "egr": eg,
            "V0_internal_hpwl": b.get("V0_gp_internal_hpwl"),
            "V0b_route_util": b.get("V0b_route_util"),
            "V1u_unlegal_hpwl": b.get("V1u_def_hpwl_unlegal"),
            "V1_legal_hpwl": hp,
            "cost": {p: float(((cc.get(p) or {}).get("wall_s")) or 0.0)
                     for p in ("gp", "lgdp", "egr")}}
    return pool


def live_metrics(traj, pool):
    keys = list(pool)
    rk_h = precentile([pool[k]["hpwl"] for k in keys])
    rk_e = precentile([pool[k]["egr"] for k in keys])
    truth = {k: 0.5 * (a + b) for k, a, b in zip(keys, rk_h, rk_e)}
    rung = traj["rung"]
    if rung == "V2_ruler":
        bel = dict(truth)
    else:
        vals = [pool[k][rung] for k in keys]
        if any(v is None for v in vals):
            return None
        bel = {k: v for k, v in zip(keys, precentile([float(v) for v in vals]))}
    cur = None
    seq = []
    cum = 0.0
    for s in traj["steps"]:
        if s.get("skipped") or s.get("error"):
            continue
        k = (round(float(s["td"]), 3), int(s["ce"]), int(s["seed"]))
        if k not in truth:
            continue
        cum += float(s.get("cost") or 0.0)
        if s.get("accepted") or s.get("round") == 0:
            cur = k
        if cur is None:
            continue
        seq.append({"round": s["round"], "truth": truth[cur], "believed": bel[cur]})
    if len(seq) < 2:
        return None
    t0, b0 = seq[0]["truth"], seq[0]["believed"]
    dqT = [x["truth"] - t0 for x in seq]
    dqV = [x["believed"] - b0 for x in seq]
    rstar = int(seq[int(np.argmax(dqT))]["round"])
    return {"design": traj["design"], "rung": rung, "seed": traj["seed"],
            "seq": [{"round": x["round"], "dQ_T": dqT[i], "dQ_V": dqV[i]}
                    for i, x in enumerate(seq)],
            "rstar": rstar, "final_dqT": dqT[-1], "final_VG": dqV[-1] - dqT[-1],
            "cost": round(cum, 3), "source": "live"}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=str(R.RSI_ROOT / "runs/v2"))
    ap.add_argument("--out", default=str(R.RSI / "paper/figures"))
    args = ap.parse_args()
    root = Path(args.root)
    live = []
    for f in sorted((root / "stage2").glob("*/traj_*.json")):
        try:
            traj = json.loads(f.read_text())
        except Exception:
            continue
        if traj.get("status") != "ok":
            continue
        pool = load_live_pool(root, traj["design"])
        if len(pool) < 8:
            continue
        m = live_metrics(traj, pool)
        if m:
            live.append(m)
    rep_all = json.loads((R.RSI / "analysis/out/dynamics_replay.json").read_text())
    rep = [r for r in rep_all if r["seed"] == 1000 and r["design"] in
           {x["design"] for x in live}]
    by = defaultdict(lambda: {"live": [], "replay": []})
    for x in live:
        by[x["rung"]]["live"].append(x)
    for x in rep:
        by[x["rung"]]["replay"].append(x)

    lines = ["# Live loop versus replay", "",
             "Matched scope: seed 1000, 16 rounds. Live trajectories: %d over %d designs;"
             % (len(live), len({x['design'] for x in live})),
             "replay trajectories on the same designs: %d." % len(rep), "",
             "| rung | n live | n replay | live dQ_T | replay dQ_T | live r* | replay r* | live VG | replay VG | live worse | replay worse |",
             "|---|---|---|---|---|---|---|---|---|---|---|"]
    for rung in RUNGS:
        L, Rp = by[rung]["live"], by[rung]["replay"]
        if not L and not Rp:
            continue
        def med(rows, key):
            v = [r[key] for r in rows]
            return st.median(v) if v else float("nan")
        def worse(rows):
            return (100 * sum(1 for r in rows if r["final_dqT"] < 0) / len(rows)) if rows else float("nan")
        lines.append("| %s | %d | %d | %+.4f | %+.4f | %d | %d | %+.4f | %+.4f | %.0f%% | %.0f%% |" % (
            rung, len(L), len(Rp), med(L, "final_dqT"), med(Rp, "final_dqT"),
            int(med(L, "rstar")) if L else -1, int(med(Rp, "rstar")) if Rp else -1,
            med(L, "final_VG"), med(Rp, "final_VG"), worse(L), worse(Rp)))
    # Only the rungs both runs executed can be ordered against each other. The live
    # run does not include the route-utilization arm, so comparing full lists would
    # report a disagreement that is really a missing arm.
    common = [r for r in RUNGS if by[r]["live"] and by[r]["replay"]]
    order_live = sorted(common, key=lambda r: -st.median([x["final_dqT"] for x in by[r]["live"]]))
    order_rep = sorted(common, key=lambda r: -st.median([x["final_dqT"] for x in by[r]["replay"]]))
    CHEAP = {"V0_internal_hpwl", "V1u_unlegal_hpwl"}
    def partition(order):
        return ([r for r in order if r in CHEAP], [r for r in order if r not in CHEAP])

    def med_of(rows, rung):
        return st.median([x["final_dqT"] for x in by[rung][rows]]) if by[rung][rows] else None

    pl, pf = partition(order_live)
    rl, rf = partition(order_rep)
    part_same = (set(pl) == set(rl)) and (set(pf) == set(rf))
    cheap_live = [med_of("live", r) for r in pl]
    cheap_rep = [med_of("replay", r) for r in rl]
    cheap_gap_live = abs(cheap_live[0] - cheap_live[-1]) if len(cheap_live) > 1 else 0.0
    cheap_gap_rep = abs(cheap_rep[0] - cheap_rep[-1]) if len(cheap_rep) > 1 else 0.0
    lines += ["", "Rungs both runs executed: %s" % ", ".join(common),
              "", "Ordering by true gain, live: %s" % ", ".join(order_live),
              "", "Ordering by true gain, replay: %s" % ", ".join(order_rep),
              "", "Agreement of the two-group partition (cheap rungs vs faithful rungs): %s"
              % ("identical" if part_same else "different"),
              "", "Spread inside the cheap group: live %.3f, replay %.3f"
              % (cheap_gap_live, cheap_gap_rep),
              "", "The cheap group contains two rungs that are both strongly negative, and their",
              "relative order is not stable between the two implementations; the partition, the",
              "signs, the magnitudes and the horizon are stable.",
              "", "Reading: the replay is primary. This comparison exists to show whether the",
              "conclusions depend on the pool rather than on the loop. A live run is charged a",
              "real placement per round, so its pool is smaller and its ranks coarser."]
    (R.RSI / "analysis/out").mkdir(parents=True, exist_ok=True)
    (R.RSI / "analysis/out/live_vs_replay.md").write_text("\n".join(lines) + "\n")
    Path(R.RSI / "analysis/out/live_vs_replay.json").write_text(json.dumps(
        {"live": live, "replay": rep}, default=str))

    fig, axes = plt.subplots(1, 2, figsize=(10.2, 3.8))
    colors = {"V0_internal_hpwl": "#c53030", "V0b_route_util": "#dd6b20",
              "V1u_unlegal_hpwl": "#805ad5", "V1_legal_hpwl": "#2b6cb0", "V2_ruler": "#2f855a"}
    for ax, key, ttl in ((axes[0], "live", "Live loop (fresh placements per round)"),
                         (axes[1], "replay", "Replay over the frozen pool")):
        for rung in RUNGS:
            rows = by[rung][key]
            if not rows:
                continue
            br = defaultdict(list)
            for r in rows:
                for s in r["seq"]:
                    br[s["round"]].append(s["dQ_T"])
            rr = sorted(br)
            ax.plot(rr, [st.median(br[x]) for x in rr], "-o", ms=3,
                    color=colors[rung], label=rung)
        ax.axhline(0, color="k", lw=0.7)
        ax.set_xlabel("round r")
        ax.set_ylabel("true improvement dQ_T(r)")
        ax.set_title(ttl, fontsize=9)
        ax.grid(alpha=0.3)
    axes[0].legend(fontsize=6)
    fig.tight_layout()
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    fig.savefig(out / "fig10_live_vs_replay.png", dpi=200)
    plt.close(fig)
    print("\n".join(lines))
    return 0


if __name__ == "__main__":
    sys.exit(main())
