#!/usr/bin/env python3
"""Paired multi-seed measurement of both arms, in the metric form rounds 72-73 established.

Pass/fail is seed dependent, so a single-seed count is not a property of the tree. This measures
(design, arm, seed) cells for a fixed seed set and reports, per design, how many seeds pass, plus the
two headline forms:

    primary    designs passing on EVERY seed of the set
    secondary  passing (design, seed) cells

Both arms are measured with the same ruler against the same legalised reference, from the same script
in the same session, at PL.num_threads=1 and OMP_NUM_THREADS=1.

Concurrency is allowed here (unlike rounds 67-69) because after the round-70 fix a set of different
designs running concurrently is byte-reproducible; --workers 4 is the default.

Cells are written to runs/seedcells/<arm>_<design>_s<seed>.json as they complete, so the sweep is
resumable and a killed run keeps everything already measured.

Usage:
    python3 multi_seed_sweep.py [--arms cur,base] [--seeds 1000,1001,1002,1003] [--workers 4] [--designs a,b]
"""
import argparse
import json
import os
import sys
import time
from concurrent.futures import ProcessPoolExecutor, as_completed
from pathlib import Path

HERE = Path(__file__).resolve().parent
W = HERE.parents[2]
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(W / "ieda" / "benchmarks" / "flows"))

# The modified tree under test, and the unmodified original.
ARMS = {"cur": "iEDA-det3", "base": "iEDA-base", "sr23": "iEDA-sr23", "sr24": "iEDA-sr24",
        "sr25": "iEDA-sr25", "sr26": "iEDA-sr26", "sr27": "iEDA-sr27", "sr28": "iEDA-sr28"}
OUT = W / "runs" / "seedcells"  # overwritten by --outdir when given

_D = None


def _init():
    global _D, R, G, density, ihpwl
    import rsi_lib as _R
    import gp_agent as _G
    from gp_metrics_compare import density as _den, hpwl as _hp
    R, G, density, ihpwl = _R, _G, _den, _hp
    _D = _R.load_designs()


def cell(job):
    design, arm, seed, ref = job
    rec = _D[design]
    out = OUT / ("%s_%s_s%d.json" % (arm, design, seed))
    if out.exists():
        try:
            return json.loads(out.read_text())
        except Exception:
            pass

    os.environ["IEDA_BIN"] = str(W / "ieda" / "build" / "bin" / ARMS[arm])
    os.environ["OMP_NUM_THREADS"] = "1"

    # Pin the placer thread count. The four ics55 designs ship num_threads=16 and their placement
    # regions use schedule(dynamic), so their result follows machine load; pinning removes that
    # source of variation so the seed effect is the only thing being measured.
    cfg = json.loads(Path(rec["pl_config"]).read_text())
    pl = cfg.setdefault("PL", {})
    pl["num_threads"] = 1
    pinned = W / "runs" / ("pincfg_%s.json" % design)
    if not pinned.exists():
        pinned.write_text(json.dumps(cfg, indent=1))

    td = float(pl.get("GP", {}).get("Density", {}).get("target_density", 0.8))
    mi = int(pl.get("GP", {}).get("Nesterov", {}).get("max_iter", 2000))
    gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed %d "
          "-report_route_util 1" % (mi, td, seed))

    # The work directory is keyed by the output directory as well as by the cell, so two runs in
    # different co-run patterns can never reuse each other's placement. Without this the resume-check
    # below silently re-scored the other pattern's DEFs and produced a "sequential" table that was
    # really a re-measurement of concurrent placements (round 88).
    wd = W / "runs" / "seedwork" / OUT.name / ("%s_%s_s%d" % (arm, design, seed))
    result = {"design": design, "arm": arm, "seed": seed}
    try:
        if not (wd / "placement.def").exists():
            import shutil
            if wd.exists():
                shutil.rmtree(wd, ignore_errors=True)
            wd.mkdir(parents=True, exist_ok=True)
            t0 = time.time()
            G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)), pinned, Path(rec["input_def"]),
                       [gp, "placer_run_gp -mode accept", "placer_run_lg", "placer_run_dp"], def_save=True)
            result["flow_s"] = round(time.time() - t0, 1)
        defp = wd / "placement.def"
        if not defp.exists():
            result.update(ok=False, reason="no placement.def")
        else:
            r = density(defp, Path(rec["case_root"]), 200, Path(R.foundry_of(rec)), "egr", 64)
            hp = ihpwl(defp, Path(rec["lef"])) if rec.get("lef") else None
            u, m = r.get("egr_total_overflow_union"), r.get("egr_max_overflow_union")
            key = ("hpwl", "union", "max")
            fails = [k for k, v in zip(key, (hp, u, m))
                     if v is not None and ref[k] is not None and v > ref[k]]
            result.update(ok=bool(r.get("ok")), hpwl=hp, union=u, max=m, fails=fails,
                          pass_=(not fails) and hp is not None and u is not None and m is not None,
                          def_md5=__import__("hashlib").md5(defp.read_bytes()).hexdigest()[:8])
    except Exception as exc:
        result.update(ok=False, reason=repr(exc))
    OUT.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=1))
    return result


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--arms", default="cur,base")
    ap.add_argument("--seeds", default="1000,1001,1002,1003")
    ap.add_argument("--designs", default="")
    ap.add_argument("--workers", type=int, default=4)
    ap.add_argument("--outdir", default="seedcells",
                    help="runs/<outdir> for per-cell records; use a separate dir for a different "
                         "co-run pattern so the two are not confused (round 76)")
    args = ap.parse_args()

    global OUT
    OUT = W / "runs" / args.outdir

    ref_doc = json.loads((W / "runs" / "four_arm.json").read_text())
    refs = {d: ref_doc["designs"][d]["arms"]["ref"] for d in ref_doc["designs"]}
    designs = ([x for x in args.designs.split(",") if x] if args.designs
               else sorted(x for x in os.listdir(W / "runs" / "standingB")
                           if (W / "runs" / "standingB" / x).is_dir()))
    seeds = [int(x) for x in args.seeds.split(",") if x]
    arms = [x for x in args.arms.split(",") if x]

    jobs = [(d, a, s, refs[d]) for d in designs for a in arms for s in seeds]
    print("cells %d  (designs %d x arms %d x seeds %d)  workers %d"
          % (len(jobs), len(designs), len(arms), len(seeds), args.workers), flush=True)

    done = 0
    with ProcessPoolExecutor(max_workers=args.workers, initializer=_init) as ex:
        futs = {ex.submit(cell, j): j for j in jobs}
        for f in as_completed(futs):
            r = f.result()
            done += 1
            print("%3d/%d %-22s %-5s seed %-5d pass=%-5s union=%-9s max=%-6s hpwl=%-11s %s" % (
                done, len(jobs), r["design"], r["arm"], r["seed"], r.get("pass_"), r.get("union"),
                r.get("max"), r.get("hpwl"), r.get("reason") or ""), flush=True)

    # Report per design how many seeds each arm passes.
    print()
    print("%-22s | %-18s | %-18s" % ("design", "unmodified passes", "modified passes"))
    prim = {a: 0 for a in arms}
    sec = {a: 0 for a in arms}
    per = {}
    for d in designs:
        row = {}
        for a in arms:
            n = 0
            for s in seeds:
                p = OUT / ("%s_%s_s%d.json" % (a, d, s))
                if p.exists() and json.loads(p.read_text()).get("pass_"):
                    n += 1
            row[a] = n
            sec[a] += n
            if n == len(seeds):
                prim[a] += 1
        per[d] = row
        print("%-22s | %-18s | %-18s" % (d, "%d/%d" % (row.get("base", 0), len(seeds)),
                                         "%d/%d" % (row.get("cur", 0), len(seeds))))
    print()
    for a in arms:
        print("%-5s primary (passes on EVERY seed) %d/%d   secondary (cells) %d/%d"
              % (a, prim[a], len(designs), sec[a], len(designs) * len(seeds)))
    (W / "runs" / "multi_seed_summary.json").write_text(json.dumps(
        {"designs": designs, "seeds": seeds, "arms": arms, "per_design": per,
         "primary": prim, "secondary": sec}, indent=1))
    print("wrote runs/multi_seed_summary.json")


if __name__ == "__main__":
    main()
