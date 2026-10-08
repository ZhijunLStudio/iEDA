"""Stage 1T: add the timing rung to the Stage 1 candidate pool.

Runs the placement timing evaluation (HPWL-RC model) on every candidate DEF that
Stage 1 already produced, and appends one ledger record per candidate. This makes
it possible to ask whether the fair ruler itself agrees with timing - i.e.
whether the truth we have been using is another proxy.

Only candidates whose DEF still exists are processed, and results are cached in a
TIMING.json beside the candidate so a re-run is free.
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
import timing_rung as T

CODE_PATHS = [str(HERE / "rsi_lib.py"), str(HERE / "timing_rung.py"), str(HERE / "stage1_timing.py")]
IID = R.improver_id("stage1-timing-v1", CODE_PATHS)

BASE_CORES = 384
CORES_PER_RUN = 8
N_CORESETS = 16


def coreset():
    wid = mp.current_process()._identity
    idx = (wid[1] if len(wid) > 1 else 0)
    base = BASE_CORES + (idx % N_CORESETS) * CORES_PER_RUN
    return "%d-%d" % (base, base + CORES_PER_RUN - 1)


def one(a):
    design, rec, cand_dir, root = a
    os.environ["RSI_CPUSET"] = coreset()
    cand_dir = Path(cand_dir)
    tag = cand_dir.name
    cache = cand_dir / "TIMING.json"
    if cache.exists():
        try:
            prev = json.loads(cache.read_text())
            if prev.get("status") == "ok":
                return prev
            # A failure is never a result: caching it would turn a resolvable
            # path problem into a permanent hole (the same hazard as A3).
            cache.unlink(missing_ok=True)
        except Exception:
            cache.unlink(missing_ok=True)
    defp = cand_dir / "placement.def"
    if not defp.exists():
        return {"design": design, "tag": tag, "status": "no_def"}
    try:
        ok, m = T.timing_of(defp, design, rec, root)
    except Exception as ex:
        ok, m = False, {"reason": repr(ex)}
    payload = {"design": design, "tag": tag, "status": "ok" if ok else "timing_failed",
               "timing": m}
    try:
        ledger_believed = {"V1_hpwl_indep": None}
        done = cand_dir / "DONE.json"
        if done.exists():
            d = json.loads(done.read_text())
            ledger_believed = d.get("believed") or {}
        R.design_status(design, "%s|%s|%s" % (design, tag, IID), "stage1-timing", 0,
                        "V3", IID, 0, ledger_believed,
                        {"timing": {k: v for k, v in m.items() if k in
                                    ("setup_wns", "setup_tns", "hold_wns", "hold_tns", "suggest_freq")},
                         "timing_ok": ok, "timing_cost_s": m.get("cost_s"),
                         "timing_reason": m.get("reason")},
                        {"wall_s": m.get("cost_s"), "cpu_s": m.get("cpu_s")},
                        status=payload["status"], note="candidate=%s" % tag)
        if payload["status"] == "ok":
            cache.write_text(json.dumps(payload))
    except Exception:
        pass
    return payload


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=str(R.RSI_ROOT / "runs/v2"))
    ap.add_argument("--workers", type=int, default=16)
    ap.add_argument("--designs", default="")
    args = ap.parse_args()
    root = Path(args.root)
    R.ensure_dirs()
    designs = R.load_designs()
    only = [x for x in args.designs.split(",") if x]
    jobs = []
    for d in sorted((root / "stage1").iterdir()):
        if not d.is_dir() or (only and d.name not in only):
            continue
        rec = designs.get(d.name)
        if not rec:
            continue
        for c in sorted(d.iterdir()):
            if c.is_dir() and (c / "placement.def").exists():
                jobs.append((d.name, rec, str(c), str(root)))
    print(json.dumps({"stage": "1T", "improver_id": IID, "jobs": len(jobs),
                      "workers": args.workers, "core_base": BASE_CORES}))
    sys.stdout.flush()
    t0 = time.time()
    done = fail = 0
    with mp.Pool(args.workers) as pool:
        for res in pool.imap_unordered(one, jobs):
            if (res or {}).get("status") != "ok":
                fail += 1
            done += 1
            if done % 50 == 0 or done == len(jobs):
                print("timing %d/%d failed=%d elapsed %.0fs" % (done, len(jobs), fail, time.time() - t0))
                sys.stdout.flush()
    print("stage1T done in %.0fs failed=%d" % (time.time() - t0, fail))


if __name__ == "__main__":
    main()
