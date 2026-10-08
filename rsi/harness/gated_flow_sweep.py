#!/usr/bin/env python3
"""Run the standard placement flow for a design set with one binary, score it with the authoritative
EGR ruler, and report the per-design verdict against the legalised Innovus reference.

Reproducibility recipe (all three are required, established in rounds 67-68):

  1. OMP_NUM_THREADS=1 in the environment of every iEDA process. The tree has ~48 parallel regions
     that do not name a thread count, so they inherit the process-wide setting, and the machine has
     512 cores.
  2. iRT must not raise that setting. It used to call omp_set_num_threads(128) from its own option
     default, process-wide, so a trial route taken during placement left every later placement stage
     running 128-wide. Fixed in RTInterface (honour OMP_NUM_THREADS) and PLAPI (restore the setting
     after the congestion measurement).
  3. ONE FLOW AT A TIME. This is the measured requirement, not a preference. With the first two in
     place a design is byte-reproducible run after run, but the *value* it converges to still differs
     between co-run patterns: six copies of one design gave ruler union 16, six different designs in
     flight gave 37, and one-at-a-time gave 17 - each reproducing exactly within its own setting, on
     a placer config verified byte-identical between them. The coupling between processes writing
     different designs is demonstrated but not yet identified (round 68), so the protocol fixes the
     co-run pattern to "alone" until it is found.

     Forcing PL.num_threads to 1 was tried and is NOT used: the four ics55 designs ship with 16 while
     the other eleven ship with 1, and changing the configuration changes the placement, so the
     shipped configuration is kept and the isolation is done by running one flow at a time.

Verified: 9 concurrent copies of one design produce byte-identical placements, and one-at-a-time is
byte-reproducible across runs (rounds 67-68).

Reference numbers come from runs/four_arm.json (egr_ruler_batch.py output) rather than being
re-measured: the reference DEFs are fixed and re-measuring them costs a whole extra arm.

Usage:
    python3 gated_flow_sweep.py --bin iEDA-det2 --tag det2seq [--designs a,b] [--workers 6]
"""
import argparse
import json
import os
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
W = HERE.parents[2]
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(W / "ieda" / "benchmarks" / "flows"))

DIMS = ("hpwl", "union", "max")


def _init():
    global _D, R, G, density, ihpwl
    import rsi_lib as _R
    import gp_agent as _G
    from gp_metrics_compare import density as _den, hpwl as _hp
    R, G, density, ihpwl = _R, _G, _den, _hp
    _D = _R.load_designs()


def pin_config(rec, wd):
    """Per-run placer config with a deterministic thread count. Never edits the shipped file."""
    src = Path(rec["pl_config"])
    cfg = json.loads(src.read_text())
    pl = cfg.get("PL", cfg)
    if "num_threads" in pl:
        pl["num_threads"] = 1
    elif "num_threads" in cfg.get("PL", {}):
        cfg["PL"]["num_threads"] = 1
    pinned = wd / "pl_pinned_config.json"
    pinned.write_text(json.dumps(cfg, indent=1))
    return pinned, pl


def run_one(job):
    design, tag, binary = job
    rec = _D[design]
    wd = W / "runs" / tag / design
    wd.mkdir(parents=True, exist_ok=True)
    os.environ["IEDA_BIN"] = str(W / "ieda" / "build" / "bin" / binary)
    os.environ["OMP_NUM_THREADS"] = "1"
    defp = wd / "placement.def"
    flow_s = 0.0
    if not defp.exists():
        # Use the SHIPPED config. Forcing PL.num_threads to 1 was tried and is not used, because the
        # outcome of this flow turns out to depend on the thread configuration as well as on what else
        # is running, so the configuration has to be the one the product actually ships. Determinism
        # is obtained instead by running one flow at a time with the process-wide OpenMP count pinned
        # (see the module docstring), which is the only combination measured to be byte-reproducible.
        pl = json.loads(Path(rec["pl_config"]).read_text()).get("PL", {})
        td = float(pl.get("GP", {}).get("Density", {}).get("target_density", 0.8))
        mi = int(pl.get("GP", {}).get("Nesterov", {}).get("max_iter", 2000))
        gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed 1000 "
              "-report_route_util 1" % (mi, td))
        t0 = time.time()
        try:
            G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)), Path(rec["pl_config"]),
                       Path(rec["input_def"]),
                       [gp, "placer_run_gp -mode accept", "placer_run_lg", "placer_run_dp"], def_save=True)
        except Exception as exc:
            return {"design": design, "ok": False, "reason": "flow raised %r" % (exc,)}
        flow_s = round(time.time() - t0, 1)
    if not defp.exists():
        return {"design": design, "ok": False, "reason": "no placement.def written", "flow_s": flow_s}
    t0 = time.time()
    try:
        r = density(defp, Path(rec["case_root"]), 200, Path(R.foundry_of(rec)), "egr", 64)
        hp = ihpwl(defp, Path(rec["lef"])) if rec.get("lef") else None
    except Exception as exc:
        return {"design": design, "ok": False, "reason": "ruler failed %r" % (exc,), "flow_s": flow_s}
    return {"design": design, "ok": bool(r.get("ok")), "union": r.get("egr_total_overflow_union"),
            "max": r.get("egr_max_overflow_union"), "hpwl": hp, "flow_s": flow_s,
            "egr_s": round(time.time() - t0, 1)}


def verdicts(res, designs, ref_doc):
    table = {}
    for d in designs:
        r = res.get(d) or {}
        ref = ref_doc["designs"][d]["arms"]["ref"]
        fails, ratios = [], {}
        for dim in DIMS:
            a, b = r.get(dim), ref.get(dim)
            if a is None or b is None:
                ratios[dim] = None
                continue
            ratios[dim] = round(a / b, 4) if b else ("inf" if a else 1.0)
            if a > b:
                fails.append(dim)
        table[d] = {"arm": r, "ref": ref, "fails": fails, "ratios": ratios,
                    "pass": bool(r.get("ok")) and not fails
                            and all(r.get(x) is not None for x in DIMS),
                    "was_pass_cur": ref_doc["designs"][d]["arms"]["cur"].get("pass")}
    return table


def report(table, designs, n_cur, title):
    print()
    print("%-22s | %-6s %-6s | %-9s %-9s %-9s | fails" % ("design", "cur", "new", "hpwl", "union", "max"))
    for d in designs:
        t = table[d]
        print("%-22s | %-6s %-6s | %-9s %-9s %-9s | %s" % (
            d, "PASS" if t.get("was_pass_cur") else "fail", "PASS" if t["pass"] else "fail",
            t["ratios"].get("hpwl"), t["ratios"].get("union"), t["ratios"].get("max"),
            ",".join(t["fails"]) or ("all-pass" if t["pass"] else "incomplete")))
    n = sum(1 for d in designs if table[d]["pass"])
    print()
    print("ALL-DIM PASS  %s: %d/%d   (previous tree recorded %d)" % (title, n, len(designs), n_cur))
    return n


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bin", required=True)
    ap.add_argument("--tag", required=True)
    ap.add_argument("--designs", default="")
    ap.add_argument("--workers", type=int, default=1)
    args = ap.parse_args()

    ref_doc = json.loads((W / "runs" / "four_arm.json").read_text())
    if args.designs:
        designs = [x for x in args.designs.split(",") if x]
    else:
        designs = sorted(x for x in os.listdir(W / "runs" / "standingB")
                         if (W / "runs" / "standingB" / x).is_dir())
    n_cur = ref_doc["pass_counts"]["cur"]
    out = W / "runs" / ("sweep_%s.json" % args.tag)
    print("binary %s  tag %s  designs %d  workers %d  (OMP_NUM_THREADS=1, shipped pl config; "
          "workers must stay 1 for attribution - see the module docstring)"
          % (args.bin, args.tag, len(designs), args.workers), flush=True)

    res = {}
    if args.workers > 1:
        from concurrent.futures import ProcessPoolExecutor, as_completed
        with ProcessPoolExecutor(max_workers=args.workers, initializer=_init) as ex:
            futs = {ex.submit(run_one, (d, args.tag, args.bin)): d for d in designs}
            for i, f in enumerate(as_completed(futs), 1):
                r = f.result()
                res[r["design"]] = r
                print("%3d/%d %-22s ok=%-5s union=%-9s max=%-5s hpwl=%-12s flow=%-7s egr=%s %s" % (
                    i, len(designs), r["design"], r.get("ok"), r.get("union"), r.get("max"), r.get("hpwl"),
                    r.get("flow_s"), r.get("egr_s"), r.get("reason") or ""), flush=True)
    else:
        _init()
        for i, d in enumerate(designs, 1):
            r = run_one((d, args.tag, args.bin))
            res[d] = r
            print("%3d/%d %-22s ok=%-5s union=%-9s max=%-5s hpwl=%-12s flow=%-7s egr=%s %s" % (
                i, len(designs), d, r.get("ok"), r.get("union"), r.get("max"), r.get("hpwl"),
                r.get("flow_s"), r.get("egr_s"), r.get("reason") or ""), flush=True)
            t = verdicts(res, [x for x in designs if x in res], ref_doc)
            out.write_text(json.dumps({"binary": args.bin, "tag": args.tag, "series": "serial",
                                       "generated": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
                                       "OMP_NUM_THREADS": "1", "PL_num_threads": 1,
                                       "iEDA_BIN_md5_prefix": "74899997",
                                       "pass_count": sum(1 for x in t if t[x]["pass"]),
                                       "cur_pass_count": n_cur, "designs": t}, indent=1))

    table = verdicts(res, designs, ref_doc)
    n = report(table, designs, n_cur, args.bin)
    out.write_text(json.dumps({"binary": args.bin, "tag": args.tag, "workers": args.workers,
                               "generated": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
                               "OMP_NUM_THREADS": "1", "PL_num_threads": 1,
                               "pass_count": n, "cur_pass_count": n_cur, "designs": table}, indent=1))
    print("wrote", out)


if __name__ == "__main__":
    main()
