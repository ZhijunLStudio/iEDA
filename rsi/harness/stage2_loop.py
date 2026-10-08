"""Stage 2: self-improvement dynamics under different verifier rungs.

An adaptive search over (target_density, congestion_effort, seed). The loop sees
ONLY its rung's signal; the harness separately scores every candidate with the
fair ruler, so believed-vs-true trajectories, VG_r and r* are measurable.

Candidates are cached per (design, td, ce, seed) independently of the rung, so
all rungs are evaluated on the SAME candidate pool (paired comparison) and the
shared work is paid once.

Charged cost per rung (protocol section 2.2):
  V0  gp-internal hpwl       gp
  V1u unlegalized DEF hpwl   gp
  V1  legalized hpwl         gp + lgdp
  V2  legalized hpwl + EGR   gp + lgdp + egr
"""
import argparse
import fcntl
import json
import multiprocessing as mp
import os
import random
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import rsi_lib as R

CODE_PATHS = [str(HERE / "rsi_lib.py"), str(HERE / "stage2_loop.py")]
IID = R.improver_id("stage2-pareto-job-v6", CODE_PATHS)
BIN_FP = R.binary_fingerprint()

RUNGS = ["V0_internal_hpwl", "V1u_unlegal_hpwl", "V1_legal_hpwl", "V2_ruler"]
TD_LO, TD_HI, TD_STEP = 0.50, 0.95, 0.05
CE_LO, CE_HI = 0, 8
SEEDS = [1000, 1001, 1002, 1003]
ITERS = 300
CORES_PER_RUN = 8
MAX_WORKERS = 56
EXPLORE_EPS = 0.05
COST_OF = {
    "V0_internal_hpwl": ("gp",),
    "V1u_unlegal_hpwl": ("gp",),
    "V1_legal_hpwl": ("gp", "lgdp"),
    "V2_ruler": ("gp", "lgdp", "egr"),
}


def worker_coreset():
    wid = mp.current_process()._identity
    idx = (wid[1] if len(wid) > 1 else 0)
    base = (idx % MAX_WORKERS) * CORES_PER_RUN
    return "%d-%d" % (base, base + CORES_PER_RUN - 1)


def cand_tag(td, ce, seed):
    return "td%03d_ce%d_s%d" % (int(round(td * 100)), int(ce), int(seed))


def _usable(prev):
    b = prev.get("believed") or {}
    t = prev.get("true") or {}
    return (prev.get("status") == "ok"
            and b.get("V1_hpwl_indep") is not None
            and t.get("egr_total_overflow_union") is not None)


def evaluate(design, rec, td, ce, seed, root):
    """Candidate evaluation, serialized per candidate directory.

    Several loops (different rungs or seeds) can request the same candidate at the
    same time. They must not run concurrently in one workdir, or one loop's iEDA
    run overwrites the other's placement.def and both results become silently
    wrong. An exclusive lock plus a re-check under the lock makes the cache both
    race-free and shared.
    """
    os.environ["RSI_CPUSET"] = worker_coreset()
    tag = cand_tag(td, ce, seed)
    wd = Path(root) / ("stage2_candidates/%s/%s" % (design, tag))
    run_id = "%s|%s|%s" % (design, tag, IID)
    done = wd / "DONE.json"
    wd.mkdir(parents=True, exist_ok=True)
    lock_path = wd / ".lock"
    with open(lock_path, "w") as lf:
        d0 = time.time()
        fcntl.flock(lf, fcntl.LOCK_EX)
        waited = time.time() - d0
        try:
            if done.exists():
                try:
                    prev = json.loads(done.read_text())
                    # A cached measurement is a property of the candidate, not of the
                    # loop that requested it: the placement and its scores depend on
                    # the solver, the design and the knob values, so a new loop
                    # generation must not invalidate it. Only the solver identity and
                    # usability matter.
                    fp = prev.get("binary_fp")
                    if _usable(prev) and (fp is None or fp == BIN_FP):
                        prev["lock_wait_s"] = round(waited, 2)
                        return prev
                    # A failure, a foreign measurement, or one produced by a different
                    # solver must never be reused: recompute.
                    done.unlink(missing_ok=True)
                except Exception:
                    pass
            return _evaluate_locked(design, rec, td, ce, seed, root, wd, tag, run_id)
        finally:
            fcntl.flock(lf, fcntl.LOCK_UN)


def _evaluate_locked(design, rec, td, ce, seed, root, wd, tag, run_id):
    r = R.gp_candidate(design, rec, wd, target_density=td, congestion_effort=ce,
                       seed=seed, iterations=ITERS)
    jrec = ((r.get("json") or {}).get("record") or {})
    hpwl_indep = None
    legal = None
    try:
        sys.path.insert(0, str(R.FLOWS))
        from gp_metrics_compare import hpwl as ihpwl, check_legalized
        _lef = R.lef_of(rec)
        defp = wd / "placement.def"
        if defp.exists():
            legal = bool(check_legalized(defp).get("legalized"))
            if _lef:
                hpwl_indep = ihpwl(defp, Path(_lef))
    except Exception:
        pass
    truth = R.truth_metrics(wd, rec, with_egr=True)
    believed = {
        "V0_gp_internal_hpwl": jrec.get("hpwl"),
        "V1u_def_hpwl_unlegal": jrec.get("def_hpwl"),
        "V1_hpwl_indep": hpwl_indep,
        "V0b_route_util": jrec.get("route_util"),
        "overflow": jrec.get("overflow"),
    }
    comp = {"gp": r.get("cost_gp"), "lgdp": r.get("cost_lgdp"),
            "egr": {"wall_s": truth.get("egr_cost_s", 0.0), "cpu_s": None}}
    payload = {"design": design, "tag": tag, "run_id": run_id, "improver_id": IID,
               "binary_fp": BIN_FP,
               "td": td, "ce": ce, "seed": seed, "believed": believed, "true": truth,
               "cost_components": comp, "legalized": legal,
               "status": "ok" if r["rc"] == 0 else "candidate_failed"}
    R.design_status(design, run_id, "stage2-loop", 0, "V0|V1u|V1|V2", IID, seed,
                    believed, truth,
                    {"wall_s": r["wall_s"] + truth.get("egr_cost_s", 0.0), "cpu_s": r["cpu_s"]},
                    status=payload["status"], note="candidate=%s" % tag,
                    extra={"cand": {"target_density": td, "congestion_effort": ce, "seed": seed},
                           "legalized": legal, "cost_components": comp})
    if _usable(payload):
        (wd / "DONE.json").write_text(json.dumps(payload))
    return payload


def make_signal(rung):
    def sig(p, ref):
        b, t = p["believed"], p["true"]
        if rung == "V0_internal_hpwl":
            v, r0 = b.get("V0_gp_internal_hpwl"), ref["V0_gp_internal_hpwl"]
            return (v / r0) if v and r0 else None
        if rung == "V1u_unlegal_hpwl":
            v, r0 = b.get("V1u_def_hpwl_unlegal"), ref["V1u_def_hpwl_unlegal"]
            return (v / r0) if v and r0 else None
        if rung == "V1_legal_hpwl":
            v, r0 = b.get("V1_hpwl_indep"), ref["V1_hpwl_indep"]
            return (v / r0) if v and r0 else None
        return None
    return sig


def comps(p):
    return (p["believed"].get("V1_hpwl_indep"), p["true"].get("egr_total_overflow_union"))


def pareto_better(a, b):
    """Project rule: a is accepted over b iff it loses on no dimension."""
    if a[0] is None or a[1] is None or b[0] is None or b[1] is None:
        return False
    no_worse = a[0] <= b[0] and a[1] <= b[1]
    strictly = a[0] < b[0] or a[1] < b[1]
    return no_worse and strictly


def truth_q(p, ref):
    return None


def rung_cost(p, rung):
    c = p.get("cost_components") or {}
    tot = 0.0
    for part in COST_OF[rung]:
        tot += float(((c.get(part) or {}).get("wall_s")) or 0.0)
    return tot


def propose(rnd, td, ce, seed):
    k = rnd.random()
    if k < 0.55:
        return (min(TD_HI, max(TD_LO, round(td + rnd.choice([-2, -1, 1, 2]) * TD_STEP, 3))), ce, seed)
    if k < 0.85:
        return (td, min(CE_HI, max(CE_LO, ce + rnd.choice([-3, -1, 1, 2, 3]))), seed)
    return (td, ce, rnd.choice(SEEDS))


def loop_for(design, rec, rung, seed, rounds, root):
    rnd = random.Random(R.stable_seed(design, rung, seed))
    sig = make_signal(rung)
    start = evaluate(design, rec, 0.80, 3, seed, root)
    ref = {"V0_gp_internal_hpwl": start["believed"].get("V0_gp_internal_hpwl"),
           "V1u_def_hpwl_unlegal": start["believed"].get("V1u_def_hpwl_unlegal"),
           "V1_hpwl_indep": start["believed"].get("V1_hpwl_indep"),
           "egr_total_overflow_union": start["true"].get("egr_total_overflow_union")}
    if ref.get("V1_hpwl_indep") is None or ref.get("egr_total_overflow_union") is None:
        return {"design": design, "rung": rung, "seed": seed, "status": "no_reference"}
    if rung in ("V0_internal_hpwl", "V1u_unlegal_hpwl", "V1_legal_hpwl"):
        if ref.get({"V0_internal_hpwl": "V0_gp_internal_hpwl",
                    "V1u_unlegal_hpwl": "V1u_def_hpwl_unlegal",
                    "V1_legal_hpwl": "V1_hpwl_indep"}[rung]) is None:
            return {"design": design, "rung": rung, "seed": seed, "status": "no_reference"}
    cur = (0.80, 3, seed)
    cur_sig = sig(start, ref)
    cur_comp = comps(start)
    cs = comps(start)
    steps = [{"round": 0, "td": cur[0], "ce": cur[1], "seed": cur[2], "signal": cur_sig,
              "hpwl": cs[0], "egr": cs[1], "accepted": True, "cost": rung_cost(start, rung)}]
    cum = rung_cost(start, rung)
    for rd in range(1, rounds + 1):
        cand = propose(rnd, *cur)
        if cand[0] == cur[0] and cand[1] == cur[1]:
            cand = (cur[0], min(CE_HI, max(CE_LO, cur[1] + 1)), cur[2])
        tag = cand_tag(*cand)
        try:
            p = evaluate(design, rec, cand[0], cand[1], cand[2], root)
        except Exception as ex:
            steps.append({"round": rd, "error": repr(ex)})
            continue
        if not _usable(p):
            # A candidate whose truth could not be measured must not silently enter
            # the trajectory: half the truth would be missing exactly where the
            # analysis later looks. It is skipped and recorded as such.
            steps.append({"round": rd, "td": cand[0], "ce": cand[1], "seed": cand[2],
                          "skipped": "unscored", "cost": rung_cost(p, rung)})
            continue
        s = sig(p, ref)
        c = rung_cost(p, rung)
        cum += c
        acc = False
        pc = comps(p)
        if rung == "V2_ruler":
            if pareto_better(pc, cur_comp):
                acc = True
            elif rnd.random() < EXPLORE_EPS:
                acc = True
        elif s is not None and cur_sig is not None:
            if s < cur_sig:
                acc = True
            elif rnd.random() < EXPLORE_EPS:
                acc = True
        steps.append({"round": rd, "td": cand[0], "ce": cand[1], "seed": cand[2],
                      "signal": s, "hpwl": pc[0], "egr": pc[1], "accepted": acc,
                      "cost": c, "cum_cost": round(cum, 3), "tag": tag})
        if acc:
            cur, cur_sig, cur_comp = cand, s, pc
    out = {"design": design, "rung": rung, "seed": seed, "status": "ok",
           "improver_id": IID, "ref": ref, "steps": steps,
           "loop_cost_total": round(cum, 3), "explore_eps": EXPLORE_EPS}
    d = Path(root) / ("stage2/%s" % design)
    d.mkdir(parents=True, exist_ok=True)
    (d / ("traj_%s_s%d.json" % (rung, seed))).write_text(json.dumps(out))
    return out


def _job(a):
    """One job runs every rung for one (design, seed) sequentially.

    Parallelising per rung instead would make several workers request the same
    start candidate at once and spend their time waiting on the candidate lock;
    each job also shares its own candidate cache without any locking.
    """
    design, rec, seed, rounds, root, rungs = a
    out = []
    for rung in rungs:
        try:
            out.append(loop_for(design, rec, rung, seed, rounds, Path(root)))
        except Exception as ex:
            out.append({"design": design, "rung": rung, "seed": seed,
                        "status": "job_error", "error": repr(ex)})
    bad = [o for o in out if o.get("status") != "ok"]
    return {"design": design, "seed": seed, "n": len(out), "bad": bad}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--designs", default="")
    ap.add_argument("--rounds", type=int, default=30)
    ap.add_argument("--seeds", default="1000,1001")
    ap.add_argument("--workers", type=int, default=32)
    ap.add_argument("--root", default=str(R.RUNS))
    ap.add_argument("--rungs", default=",".join(RUNGS))
    args = ap.parse_args()
    R.ensure_dirs()
    ph = R.check_protocol()
    designs = R.load_designs()
    names = [n for n in (args.designs.split(",") if args.designs else []) if n] or sorted(designs)
    seeds = [int(s) for s in args.seeds.split(",")]
    rungs = [s for s in args.rungs.split(",") if s]
    jobs = [(n, designs[n], sd, args.rounds, args.root, rungs)
            for n in names if n in designs for sd in seeds]
    print(json.dumps({"stage": 2, "protocol": ph[:12], "improver_id": IID,
                      "designs": len(names), "rungs": rungs, "seeds": seeds,
                      "rounds": args.rounds, "loops": len(jobs), "workers": args.workers,
                      "explore_eps": EXPLORE_EPS}))
    sys.stdout.flush()
    t0 = time.time()
    done = err = 0
    ef = Path(args.root) / "stage2_errors.jsonl"
    ef.unlink(missing_ok=True)
    with mp.Pool(args.workers) as pool:
        for res in pool.imap_unordered(_job, jobs):
            for b in (res or {}).get("bad") or []:
                err += 1
                with ef.open("a") as f:
                    f.write(json.dumps(b, ensure_ascii=False) + "\n")
            done += 1
            print("jobs %d/%d bad=%d elapsed %.0fs" % (done, len(jobs), err, time.time() - t0))
            sys.stdout.flush()
    print("stage2 done in %.0fs errors=%d" % (time.time() - t0, err))


if __name__ == "__main__":
    main()
