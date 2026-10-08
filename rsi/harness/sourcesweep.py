"""Source-iteration sweep: evaluate the current iEDA binary on a fixed design vector.

This is the loop's measuring stick. One invocation = one build; it runs the whole
placement pipeline per design and records every dimension the goal cares about, keyed
on the binary fingerprint so a result can never be attributed to the wrong build.

Pipeline per design: global placement (plain config) -> legalization -> detail placement
-> trial-route congestion -> placement timing. Nothing is scored at the GP stage, because
pre-legalization wirelength anti-ranks the final one (rho = -0.891 over the candidate
pool) and is not legalized.

Usage:
  python3 sourcesweep.py --tag base                 # record a baseline
  python3 sourcesweep.py --tag dp-v1 --patches a.patch
  python3 sourcesweep.py --compare base dp-v1       # print the delta table
"""
import argparse
import hashlib
import json
import os
import shutil
import statistics as st
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import placement_shape as PS
import rsi_lib as R
import timing_rung as T

# Four circuits x three usable PDKs. Same circuit across PDKs removes the circuit as a
# confound, so a change that only helps one netlist cannot masquerade as a method gain.
MATCHED = ["gcd_sky130_a", "gcd_ics55_a", "gcd_nangate45_a",
           "s1238_sky130_a", "s1238_ics55_a", "s1238_nangate45_a",
           "salsa20_sky130_a", "salsa20_ics55_a", "salsa20_nangate45_a",
           "s38584_sky130_a", "s38584_ics55_a", "s38584_nangate45_a"]

DIMS = ["hpwl", "egr_union", "egr_max", "gini", "max_bin", "setup_tns", "setup_wns"]


def apply_patch(rec, patch, wd):
    """Return a copy of the design record whose placement config carries the patch.

    Lets a hypothesis that is expressible as a configuration value (a penalty floor, a bin
    count, an iteration budget) be tested without touching source. That distinction
    matters for attribution: a config-testable effect is not evidence about the algorithm.
    """
    if not patch:
        return rec
    src = Path(rec["pl_config"])
    cfg = json.loads(src.read_text())
    for dotted, val in patch.items():
        node = cfg
        parts = dotted.split(".")
        for k in parts[:-1]:
            if k not in node or not isinstance(node[k], dict):
                node[k] = {}
            node = node[k]
        node[parts[-1]] = val
    dst = wd / "pl_config_patched.json"
    dst.write_text(json.dumps(cfg, indent=2))
    rec2 = dict(rec)
    rec2["pl_config"] = str(dst)
    return rec2


def one(design, rec, root, tag, timeout=5400, patch=None):
    wd = Path(root) / ("sweep/%s/%s" % (tag, design))
    wd.mkdir(parents=True, exist_ok=True)
    out = {"design": design, "pdk": rec.get("pdk"), "workdir": str(wd)}
    rec = apply_patch(rec, patch, wd)
    out["config_patch"] = patch
    t0 = time.time()
    r = R.gp_plain(design, rec, wd, seed=1000, timeout=timeout)
    out["rc_plain"] = r["rc"]
    out["t_plain"] = round(r["wall_s"], 1)
    st_ = R.read_state(wd)
    out["def_hpwl_record"] = st_.get("best_def_hpwl")
    try:
        sys.path.insert(0, str(R.FLOWS))
        from gp_metrics_compare import hpwl as ihpwl, check_legalized
        defp = wd / "placement.def"
        if defp.exists():
            out["legalized"] = bool(check_legalized(defp).get("legalized"))
            lef = R.lef_of(rec)
            if lef:
                out["hpwl"] = ihpwl(defp, Path(lef))
    except Exception as ex:
        out["hpwl_error"] = repr(ex)
    # Shape statistics: cheap, deterministic given the DEF, and the suspected driver of
    # peak congestion (which is a local quantity). Recorded on every sweep so the
    # indicator can be correlated with EGR max without re-running anything.
    try:
        sh = PS.parse_placement(wd / "placement.def")
        if sh:
            out["gini"] = sh.get("gini")
            out["max_bin"] = sh.get("max_bin")
            out["busiest1pct_share"] = sh.get("busiest1pct_share")
    except Exception as ex:
        out["shape_error"] = repr(ex)
    t = R.truth_metrics(wd, rec, with_egr=True)
    out["egr_union"] = t.get("egr_total_overflow_union")
    out["egr_max"] = t.get("egr_max_overflow_union")
    out["egr_ok"] = t.get("egr_ok")
    out["t_egr"] = t.get("egr_cost_s")
    if out.get("hpwl") is None and out.get("egr_union") is None:
        out["status"] = "no_metrics"
    else:
        out["status"] = "ok"
    out["t_total"] = round(time.time() - t0, 1)
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tag", required=True)
    ap.add_argument("--designs", default="")
    ap.add_argument("--root", default=str(R.RUNS / "srciter"))
    ap.add_argument("--compare", nargs=2, default=None)
    ap.add_argument("--patches", default="")
    ap.add_argument("--bin", default="", help="explicit iEDA binary; default build/bin/iEDA")
    ap.add_argument("--config-patch", default="", help='JSON dict of dotted-path overrides, e.g. {"PL.GP.Nesterov.min_phi_coef":1.0}')
    args = ap.parse_args()
    root = Path(args.root)
    root.mkdir(parents=True, exist_ok=True)
    # The binary is an explicit, versioned input, copied into the run directory. Every
    # stage of this sweep invokes that copy, so rebuilding build/bin/iEDA while a sweep
    # is in flight cannot mix two builds into one dataset. (That happened once: a
    # rebuild landed mid-sweep and invalidated a 32-design baseline.)
    src_bin = Path(args.bin) if args.bin else (R.IEDA_ROOT / "build/bin/iEDA")
    run_bin = root / ("bin-%s" % args.tag) / "iEDA"
    run_bin.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src_bin, run_bin)
    os.environ["IEDA_BIN"] = str(run_bin)
    bin_md5 = hashlib.md5(run_bin.read_bytes()).hexdigest()
    print("binary %s -> %s (md5 %s)" % (src_bin, run_bin, bin_md5))
    D = R.load_designs()

    if args.compare:
        a, b = args.compare
        return report(root, a, b)

    patch = json.loads(args.config_patch) if args.config_patch else None
    if patch:
        print("config patch: %s" % json.dumps(patch))
    fp_before = R.binary_fingerprint()
    names = [x for x in (args.designs.split(",") if args.designs else []) if x] or MATCHED
    rows = []
    for d in names:
        rec = D.get(d)
        if not rec:
            print("skip unknown", d); continue
        row = one(d, rec, root, args.tag, patch=patch)
        rows.append(row)
        print("  %-22s hpwl=%-11s egr_union=%-8s egr_max=%-6s t=%.0fs" % (
            d, row.get("hpwl"), row.get("egr_union"), row.get("egr_max"), row.get("t_total")))
        sys.stdout.flush()
    # Incremental: merge into the existing record for this tag rather than replacing it,
    # so a sweep that dies part-way (or a single design re-run) leaves a usable dataset
    # instead of losing everything measured so far.
    p = root / ("%s.json" % args.tag)
    prev = {}
    if p.exists():
        try:
            prev = json.loads(p.read_text())
        except Exception:
            prev = {}
    by = {r["design"]: r for r in prev.get("rows", [])}
    for r in rows:
        if r.get("status") == "ok" or r["design"] not in by:
            by[r["design"]] = r
    allrows = list(by.values())
    rec = {"tag": args.tag, "binary": str(run_bin), "binary_md5": bin_md5,
           "binary_fp_before": fp_before, "binary_fp_after": R.binary_fingerprint(),
           "patches": args.patches, "n": len(allrows), "rows": allrows,
           "last_run_designs": [r["design"] for r in rows],
           "summary": {k: (st.median([r[k] for r in allrows if r.get(k) is not None])
                           if any(r.get(k) is not None for r in allrows) else None) for k in DIMS}}
    p.write_text(json.dumps(rec, indent=1))
    print("=== %s summary (medians) ===" % args.tag)
    print("   " + "  ".join("%s=%s" % (k, rec["summary"][k]) for k in DIMS))
    print("   binary %s -> %s" % (fp_before, rec["binary_fp_after"]))
    return 0


def report(root, a, b):
    A = json.loads((root / ("%s.json" % a)).read_text())
    B = json.loads((root / ("%s.json" % b)).read_text())
    ai = {r["design"]: r for r in A["rows"]}
    bi = {r["design"]: r for r in B["rows"]}
    print("=== %s -> %s ===" % (a, b))
    if A.get("binary_fp_after") == B.get("binary_fp_after"):
        print("  WARNING: the binary fingerprint did not change; this is not a source change")
    print("  %-22s %8s %8s %8s | %8s %8s | %8s %8s" % (
        "design", "hpwl_a", "hpwl_b", "d%", "egrU_a", "egrU_b", "egrM_a", "egrM_b"))
    d_h, d_e, d_m = [], [], []
    for d in sorted(set(ai) & set(bi)):
        x, y = ai[d], bi[d]
        dh = de = dm = None
        if x.get("hpwl") and y.get("hpwl"): dh = 100*(y["hpwl"]/x["hpwl"]-1); d_h.append(dh)
        if x.get("egr_union") and y.get("egr_union") and x["egr_union"] > 0:
            de = 100*(y["egr_union"]/x["egr_union"]-1); d_e.append(de)
        if x.get("egr_max") and y.get("egr_max") and x["egr_max"] > 0:
            dm = 100*(y["egr_max"]/x["egr_max"]-1); d_m.append(dm)
        print("  %-22s %8s %8s %8s | %8s %8s | %8s %8s" % (
            d, x.get("hpwl"), y.get("hpwl"), ("%+.2f%%" % dh) if dh is not None else "-",
            x.get("egr_union"), y.get("egr_union"),
            x.get("egr_max"), y.get("egr_max")))
    def med(v):
        return ("%+.2f%%" % st.median(v)) if v else "n/a"
    print("  median delta:  hpwl %s   egr_union %s   egr_max %s   (negative is better)"
          % (med(d_h), med(d_e), med(d_m)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
