"""Stage 1 (definitive): verifier fidelity matrix.

Draws a knob-grid candidate pool per design, scores each candidate with the
cheap verifier signals and with the shared fair ruler, and writes one ledger
record per candidate (including failures, so nothing is silently dropped).

DONE.json is keyed on design+candidate+improver_id, so a code change invalidates
the cache rather than silently mixing improver generations.

Usage: /usr/bin/python3 stage1_pool.py --designs "<comma list>" --workers 48
"""
import argparse
import json
import multiprocessing as mp
import os
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
from gp_metrics_compare import hpwl as indep_hpwl, check_legalized

CODE_PATHS = [str(HERE / "rsi_lib.py"), str(HERE / "stage1_pool.py")]
IID = R.improver_id("stage1-knob-grid-v2", CODE_PATHS)

TD_GRID = [0.55, 0.60, 0.65, 0.70, 0.75, 0.80, 0.85, 0.90, 0.95]
CE_GRID = [0, 3, 7]
SEED_EXTRA = [1001, 1002]
ITERS = 300
CORES_PER_RUN = 8
MAX_WORKERS = 56


def candidate_list():
    cands = []
    for td in TD_GRID:
        for ce in CE_GRID:
            cands.append({"target_density": td, "congestion_effort": ce, "seed": 1000, "iterations": ITERS})
    for s in SEED_EXTRA:
        cands.append({"target_density": 0.80, "congestion_effort": 3, "seed": s, "iterations": ITERS})
    return cands


def cand_tag(c):
    return "td%03d_ce%d_s%d" % (int(round(c["target_density"] * 100)), c["congestion_effort"], c["seed"])


def worker_coreset():
    wid = mp.current_process()._identity
    idx = (wid[0] - 1) if wid else 0
    base = (idx % MAX_WORKERS) * CORES_PER_RUN
    return "%d-%d" % (base, base + CORES_PER_RUN - 1)


def evaluate_one(design, rec, c, root):
    os.environ["RSI_CPUSET"] = worker_coreset()
    tag = cand_tag(c)
    wd = root / ("stage1/%s/%s" % (design, tag))
    run_id = "%s|%s|%s" % (design, tag, IID)
    done = wd / "DONE.json"
    if done.exists():
        try:
            prev = json.loads(done.read_text())
            if prev.get("improver_id") == IID:
                try:
                    p = prev.get("believed") or {}
                    t = prev.get("true") or {}
                    R.design_status(design, prev.get("run_id") or run_id, "stage1-pool", 0,
                                    "V0|V1|V2", IID, c["seed"], p, t,
                                    prev.get("cost") or {"wall_s": None, "cpu_s": None},
                                    status=prev.get("status") or "ok",
                                    note="candidate=%s cached=1" % tag,
                                    extra={"cand": c, "cached": True,
                                           "cost_components": prev.get("cost_components")
                                           or (prev.get("cost") or {}).get("components")})
                except Exception:
                    pass
                return prev
        except Exception:
            pass
    wd.mkdir(parents=True, exist_ok=True)
    t0 = time.time()
    try:
        r = R.gp_candidate(design, rec, wd, target_density=c["target_density"],
                           congestion_effort=c["congestion_effort"], seed=c["seed"],
                           iterations=c["iterations"])
        jrec = ((r.get("json") or {}).get("record") or {})
        defp = wd / "placement.def"
        ind = {}
        _lef = R.lef_of(rec)
        if defp.exists():
            try:
                ind["legalized"] = bool(check_legalized(defp).get("legalized"))
                if _lef:
                    ind["hpwl_indep"] = indep_hpwl(defp, Path(_lef))
            except Exception as ex:
                ind["error"] = repr(ex)
        believed = {
            "V0_gp_internal_hpwl": jrec.get("hpwl"),
            "V0b_route_util": jrec.get("route_util"),
            "V1u_def_hpwl_unlegal": jrec.get("def_hpwl"),
            "V1_hpwl_indep": ind.get("hpwl_indep"),
            "overflow": jrec.get("overflow"),
            "iterations_done": jrec.get("end_iteration"),
            "target_density": c["target_density"],
            "congestion_effort": c["congestion_effort"],
        }
        truth = R.truth_metrics(wd, rec, with_egr=True)
        inv = rec.get("innovus_hpwl")
        if inv and believed["V1_hpwl_indep"]:
            truth["innovus_hpwl"] = inv
            truth["hpwl_vs_innovus_ratio"] = round(believed["V1_hpwl_indep"] / inv, 4)
        egr_wall = truth.get("egr_cost_s", 0.0)
        components = {
            "gp": r.get("cost_gp"),
            "lgdp": r.get("cost_lgdp"),
            "egr": {"wall_s": egr_wall, "cpu_s": None},
        }
        cost = {"wall_s": round(r["wall_s"] + egr_wall, 3), "cpu_s": r["cpu_s"],
                "components": components}
        payload = {"design": design, "tag": tag, "run_id": run_id, "improver_id": IID,
                   "believed": believed, "true": truth, "cost": cost,
                   "status": "ok" if r["rc"] == 0 else "candidate_failed",
                   "total_wall_s": round(time.time() - t0, 3)}
        R.design_status(design, run_id, "stage1-pool", 0, "V0|V1|V2", IID, c["seed"],
                        believed, truth, cost, status=payload["status"],
                        note="candidate=%s" % tag,
                        extra={"cand": c, "legalized": ind.get("legalized"),
                               "dp_rc": r.get("dp_rc"), "cost_components": components})
        done.write_text(json.dumps(payload))
        return payload
    except Exception as ex:
        err = {"design": design, "tag": tag, "run_id": run_id, "improver_id": IID,
               "status": "error", "error": repr(ex), "cand": c}
        try:
            R.design_status(design, run_id, "stage1-pool", 0, "V0|V1|V2", IID, c["seed"],
                            {}, {}, {"wall_s": round(time.time() - t0, 3), "cpu_s": None},
                            status="error", note="candidate=%s error=%s" % (tag, repr(ex)[:200]),
                            extra={"cand": c})
        except Exception:
            pass
        return err


def _job(payload):
    design, rec, c, root = payload
    try:
        return evaluate_one(design, rec, c, Path(root))
    except Exception as ex:
        return {"design": design, "tag": cand_tag(c), "status": "job_error", "error": repr(ex)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--designs", default="")
    ap.add_argument("--workers", type=int, default=48)
    ap.add_argument("--root", default=str(R.RUNS))
    args = ap.parse_args()
    R.ensure_dirs()
    ph = R.check_protocol()
    designs = R.load_designs()
    names = [n for n in (args.designs.split(",") if args.designs else []) if n]
    if not names:
        names = sorted(designs.keys())
    cands = candidate_list()
    jobs = [(n, designs[n], c, args.root) for n in names if n in designs for c in cands]
    print(json.dumps({"stage": 1, "protocol": ph[:12], "improver_id": IID,
                      "designs": len(names), "candidates_per_design": len(cands),
                      "jobs": len(jobs), "workers": args.workers}))
    sys.stdout.flush()
    t0 = time.time()
    done = err = 0
    errfile = Path(args.root) / "stage1_errors.jsonl"
    with mp.Pool(args.workers) as pool:
        for res in pool.imap_unordered(_job, jobs):
            st = (res or {}).get("status")
            if st in ("error", "job_error", "candidate_failed"):
                err += 1
                with errfile.open("a") as f:
                    f.write(json.dumps(res, ensure_ascii=False) + "\n")
            done += 1
            if done % 40 == 0 or done == len(jobs):
                print("progress %d/%d errors=%d elapsed %.0fs" % (done, len(jobs), err, time.time() - t0))
                sys.stdout.flush()
    print("stage1 done in %.0fs errors=%d" % (time.time() - t0, err))


if __name__ == "__main__":
    main()
