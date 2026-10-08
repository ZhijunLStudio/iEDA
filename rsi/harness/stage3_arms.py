"""Three-arm runner: A0 control, A1 frozen improver, A2 improver that also
updates its own acceptance rule.

A0  no write-back: the start candidate is the answer. Baseline.
A1  a loop whose acceptance rule is fixed for the whole run (one verifier rung).
A2  a loop that also edits its own acceptance rule: it records, per rung, how often
    an accept on that rung is later confirmed to be Pareto-non-worse on the truth
    components, and switches to the rung with the better record once it has enough
    evidence. Switching the rule is the A1/A2 distinction in the protocol.

The loop never sees the truth for accepting; the harness scores every held state
with the truth afterwards so the arms are compared on one ruler. Cost is charged
per rung exactly as the leveled verifier charges it.
"""
import argparse
import json
import random
import sys
import time
from collections import defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import rsi_lib as R
import stage2_loop as S

CODE_PATHS = [str(HERE / "rsi_lib.py"), str(HERE / "stage2_loop.py"), str(HERE / "stage3_arms.py")]
IID = R.improver_id("stage3-arms-v2", CODE_PATHS)

SIG_KEY = {"V0_internal_hpwl": "V0_gp_internal_hpwl",
           "V1u_unlegal_hpwl": "V1u_def_hpwl_unlegal",
           "V1_legal_hpwl": "V1_hpwl_indep"}
CANDIDATE_RUNGS = ["V0_internal_hpwl", "V1u_unlegal_hpwl", "V1_legal_hpwl"]
AUDIT_EVERY = 4
MIN_AUDITS = 2


def signal_of(rung, payload):
    key = SIG_KEY.get(rung)
    return payload["believed"].get(key) if key else None


def run_arm(design, rec, arm, seed, rounds, root, start_rung="V1_legal_hpwl"):
    rnd = random.Random(R.stable_seed(design, arm, seed))
    start = S.evaluate(design, rec, 0.80, 3, seed, root)
    if not S._usable(start):
        return {"design": design, "arm": arm, "status": "no_reference"}
    cur = (0.80, 3, seed)
    cur_payload = start
    cur_comp = S.comps(start)
    cur_sig = signal_of(start_rung, start)
    active = start_rung
    audits = defaultdict(lambda: [0, 0])
    cum = 0.0
    held = [{"round": 0, "cand": cur, "rung": None if arm == "A0" else active,
             "hpwl": cur_comp[0], "egr": cur_comp[1], "cost": 0.0, "cum_cost": 0.0}]
    for rd in range(1, rounds + 1):
        if arm == "A0":
            break
        cand = S.propose(rnd, *cur)
        if cand[:2] == cur[:2]:
            cand = (cur[0], min(S.CE_HI, cur[1] + 1), cur[2])
        try:
            p = S.evaluate(design, rec, cand[0], cand[1], cand[2], root)
        except Exception as ex:
            held.append({"round": rd, "error": repr(ex)})
            continue
        if not S._usable(p):
            held.append({"round": rd, "skipped": "unscored",
                         "cost": S.rung_cost(p, active)})
            continue
        c = S.rung_cost(p, active)
        cum += c
        comp = S.comps(p)
        acc = False
        if active == "V2_ruler":
            acc = S.pareto_better(comp, cur_comp)
            if not acc and rnd.random() < S.EXPLORE_EPS:
                acc = True
        else:
            s = signal_of(active, p)
            if s is not None and cur_sig is not None:
                if s < cur_sig or rnd.random() < S.EXPLORE_EPS:
                    acc = True
                    cur_sig = s
        held.append({"round": rd, "cand": cand, "rung": active, "hpwl": comp[0], "egr": comp[1],
                     "accepted": acc, "cost": c, "cum_cost": round(cum, 3)})
        if acc:
            cur, cur_payload, cur_comp = cand, p, comp
        if arm == "A2" and active != "V2_ruler" and rd % AUDIT_EVERY == 0:
            verifier = active
            audits[verifier][1] += 1
            if S.pareto_better(comp, cur_comp) or not S.pareto_better(cur_comp, comp):
                audits[verifier][0] += 1
            if audits[verifier][1] >= MIN_AUDITS:
                rates = {rg: (v[0] / v[1]) for rg, v in audits.items() if v[1] >= MIN_AUDITS}
                if rates:
                    best = max(rates, key=rates.get)
                    if best != active and rates[best] > rates.get(active, 0):
                        active = best
    out = {"design": design, "arm": arm, "seed": seed, "status": "ok", "improver_id": IID,
           "start_rung": start_rung, "final_rung": active, "held": held,
           "cost_total": round(cum, 3),
           "audits": {k: v for k, v in audits.items()}}
    d = Path(root) / ("stage3/%s" % design)
    d.mkdir(parents=True, exist_ok=True)
    (d / ("arm_%s_s%d.json" % (arm, seed))).write_text(json.dumps(out))
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--designs", default="")
    ap.add_argument("--arms", default="A0,A1,A2")
    ap.add_argument("--rounds", type=int, default=12)
    ap.add_argument("--seeds", default="1000")
    ap.add_argument("--root", default=str(R.RSI_ROOT / "runs/v2"))
    args = ap.parse_args()
    R.ensure_dirs()
    designs = R.load_designs()
    names = [n for n in (args.designs.split(",") if args.designs else []) if n] or sorted(designs)
    arms = [a for a in args.arms.split(",") if a]
    seeds = [int(s) for s in args.seeds.split(",")]
    print(json.dumps({"stage": 3, "improver_id": IID, "arms": arms, "designs": len(names),
                      "rounds": args.rounds, "seeds": seeds}))
    sys.stdout.flush()
    t0 = time.time()
    out = []
    for n in names:
        if n not in designs:
            continue
        for arm in arms:
            for sd in seeds:
                try:
                    out.append(run_arm(n, designs[n], arm, sd, args.rounds, args.root))
                except Exception as ex:
                    out.append({"design": n, "arm": arm, "seed": sd, "status": "job_error",
                                "error": repr(ex)})
        print("done %s (%.0fs)" % (n, time.time() - t0))
        sys.stdout.flush()
    ok = [o for o in out if o.get("status") == "ok"]
    print("arms complete: %d/%d in %.0fs" % (len(ok), len(out), time.time() - t0))
    return 0


if __name__ == "__main__":
    sys.exit(main())
