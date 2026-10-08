#!/usr/bin/env python3
"""The authoritative four-arm standing for the congestion campaign, in one batch.

Why this exists
---------------
The campaign's headline ("3 of 15 designs pass with unmodified iEDA, 4 with the
current tree, 5 once SR-21 is included") came from scoring scripts with two
defects, both of which flattered the result:

  1. The ratio was computed as 'arm/ref if ref else None'. A reference with zero
     overflow therefore produced None, and None was counted as a pass. The
     reference IS exactly zero on two nangate45 designs, and unmodified iEDA asks
     for 4 and 2 overflow bins there, so the baseline was inflated by one design.

  2. The arms were scored in different batches, and this pipeline is reproducible
     within a batch but not across batches (see the round-31 record). The SR-21
     win that was credited (gcd_ics55_a union 1.85 to 0.80) does not survive
     re-measurement inside a single batch.

What it does
------------
Scores every arm of every design with the SAME ruler, in ONE batch:

    gp_metrics_compare.density(def, case_root, 200, foundry, "egr", 64)

That call runs iEDA's own density + EGR congestion evaluator on a private snapshot
of the DEF inside a temp directory, so it neither reads nor writes the arm's own
egr_congestion_map/ CSVs. Those CSVs are written by each run's own flow and are NOT
the ruler's output; they disagree with the ruler and with each other, and must not
be used for scoring.

Verdicts use a direct comparison (arm <= reference) rather than a ratio, so a
reference of zero is handled correctly instead of becoming a free pass.

Usage
-----
    OMP_NUM_THREADS=1 IEDA_BIN=<build>/bin/iEDA python3 egr_ruler_batch.py [--workers 14]

Outputs runs/four_arm.json and rsi/analysis/out/four_arm_standing.json.
"""
import argparse
import json
import os
import sys
import time
from concurrent.futures import ProcessPoolExecutor, as_completed
from pathlib import Path

HERE = Path(__file__).resolve().parent   # ieda/rsi/harness
W = HERE.parents[2]                      # the workspace root that holds runs/
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(W / "ieda" / "benchmarks" / "flows"))

ARMS = {
    "orig": "runs/origsweep/{d}/placement.def",
    "cur": "runs/standingB/{d}/ours/placement.def",
    "sr21": "runs/cur21sweep/{d}/placement.def",
    "ref": "runs/standingB/{d}/ref/placement.def",
}
DIMS = ("hpwl", "union", "max")

_D = None


def _init():
    global _D, R, density, ihpwl
    import rsi_lib as _R
    from gp_metrics_compare import density as _den, hpwl as _hp

    R, density, ihpwl = _R, _den, _hp
    _D = _R.load_designs()


def score(job):
    design, arm = job
    rec = _D[design]
    def_path = W / ARMS[arm].format(d=design)
    if not def_path.exists():
        return {"design": design, "arm": arm, "ok": False, "reason": "def missing"}
    t0 = time.time()
    try:
        r = density(def_path, Path(rec["case_root"]), 200, Path(R.foundry_of(rec)), "egr", 64)
    except Exception as exc:  # a crashed evaluator must not look like zero congestion
        return {"design": design, "arm": arm, "ok": False, "reason": repr(exc)}
    hpwl = None
    try:
        if rec.get("lef"):
            hpwl = ihpwl(def_path, Path(rec["lef"]))
    except Exception:
        hpwl = None
    return {
        "design": design, "arm": arm, "def": str(def_path),
        "wall_s": round(time.time() - t0, 1), "ok": bool(r.get("ok")),
        "egr_valid": r.get("egr_valid"),
        "union": r.get("egr_total_overflow_union"),
        "max": r.get("egr_max_overflow_union"),
        "hpwl": hpwl,
        "reason": r.get("reason") or r.get("congestion_reason"),
    }


def verdict(arm, ref):
    """Direct comparison; None when a required number is missing."""
    if not arm or not ref or not arm.get("ok") or not ref.get("ok"):
        return None
    out = {}
    for dim in DIMS:
        a, b = arm.get(dim), ref.get(dim)
        out[dim] = None if (a is None or b is None) else bool(a <= b)
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--workers", type=int, default=14)
    ap.add_argument("--out", default=None)
    ap.add_argument("--raw", default=None,
                    help="reuse a previous four_arm_raw.json instead of re-measuring")
    args = ap.parse_args()

    designs = sorted(x for x in os.listdir(W / "runs" / "standingB")
                     if (W / "runs" / "standingB" / x).is_dir())
    jobs = [(d, a) for d in designs for a in ARMS]
    print("scoring %d (design, arm) pairs with the EGR ruler" % len(jobs), flush=True)

    res = {}
    raw_path = W / "runs" / "four_arm_raw.json"
    if args.raw and Path(args.raw).exists():
        for k, v in json.loads(Path(args.raw).read_text()).items():
            d, a = k.split("|")
            res[(d, a)] = v
        print("reused %d measurements from %s" % (len(res), args.raw), flush=True)

    if not res:
      with ProcessPoolExecutor(max_workers=args.workers, initializer=_init) as ex:
        futs = [ex.submit(score, j) for j in jobs]
        for i, f in enumerate(as_completed(futs), 1):
            r = f.result()
            res[(r["design"], r["arm"])] = r
            print("%3d/%d %-22s %-5s union=%-9s max=%-6s hpwl=%-12s %ss %s" % (
                i, len(jobs), r["design"], r["arm"], r.get("union"), r.get("max"),
                r.get("hpwl"), r.get("wall_s"), r.get("reason") or ""), flush=True)
      raw_path.parent.mkdir(parents=True, exist_ok=True)
      raw_path.write_text(json.dumps({"%s|%s" % k: v for k, v in sorted(res.items())}, indent=1))
      print("wrote", raw_path, flush=True)

    table = {}
    for d in designs:
        row = {"design": d, "arms": {a: res[(d, a)] for a in ARMS}}
        ref = res[(d, "ref")]
        for a in ("orig", "cur", "sr21"):
            arm = res[(d, a)]
            v = verdict(arm, ref)
            row["arms"][a]["verdict"] = v
            row["arms"][a]["pass"] = None if v is None else all(x for x in v.values() if x is not None)
            if ref and arm.get("ok") and ref.get("ok"):
                ratios = {}
                for dim in DIMS:
                    x, y = arm.get(dim), ref.get(dim)
                    if x is None or y is None:
                        ratios[dim] = None
                    elif y == 0:
                        # A zero reference makes the ratio undefined. Report it as a
                        # sentinel instead of letting it become a free pass, which is
                        # exactly the defect that inflated the earlier baseline.
                        ratios[dim] = 1.0 if x == 0 else "inf"
                    else:
                        ratios[dim] = round(x / y, 4)
                row["arms"][a]["ratio"] = ratios
        row["fails_cur"] = [dim for dim in DIMS
                            if row["arms"]["cur"].get("verdict", {}).get(dim) is False]
        table[d] = row

    counts = {a: sum(1 for d in table if table[d]["arms"][a].get("pass")) for a in ("orig", "cur", "sr21")}
    doc = {
        "ruler": "gp_metrics_compare.density(def, case_root, 200, foundry, 'egr', 64)",
        "note": "single batch, one ruler for all arms; verdict is a direct comparison arm<=ref",
        "generated": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
        "iEDA_BIN": os.environ.get("IEDA_BIN"),
        "pass_counts": counts,
        "designs": table,
    }

    out = Path(args.out) if args.out else W / "runs" / "four_arm.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(doc, indent=1))
    durable = W / "ieda" / "rsi" / "analysis" / "out" / "four_arm_standing.json"
    durable.parent.mkdir(parents=True, exist_ok=True)
    durable.write_text(json.dumps(doc, indent=1))

    print()
    print("%-22s | %-6s %-6s %-6s | fails(cur)" % ("design", "orig", "cur", "sr21"))
    for d in designs:
        r = table[d]
        def mark(a):
            return "PASS" if r["arms"][a].get("pass") else ("fail" if r["arms"][a].get("pass") is not None else "?")
        print("%-22s | %-6s %-6s %-6s | %s" % (d, mark("orig"), mark("cur"), mark("sr21"),
                                              ",".join(r["fails_cur"]) or "all-pass"))
    print()
    print("ALL-DIM PASS  orig %(orig)d/%(n)d   cur %(cur)d/%(n)d   sr21 %(sr21)d/%(n)d" % dict(counts, n=len(designs)))
    print("wrote", out, "and", durable)


if __name__ == "__main__":
    main()
