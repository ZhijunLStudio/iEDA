"""External anchoring (V4): reconcile our placements against Innovus references.

For every design that carries a commercial placed DEF we compute the same fair
ruler on the reference itself and on our own picks. The trial-route tool refuses
unlegalized DEFs, and commercial DEFs are not always site-aligned in the way the
gate checks, so the raw density routine is called directly here; the gate stays
in force everywhere a candidate is being scored.

Two questions:
  1. how far are we from the reference on the ruler (absolute gap)?
  2. does the rung that looks best on our ruler also look best next to the
     reference (i.e. is the ruler's preference externally confirmed)?
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
sys.path.insert(0, str(HERE.parent / "harness"))
import rsi_lib as R

IID = R.improver_id("innovus-anchor-v1", [str(HERE / "innovus_anchor.py")])


def raw_metrics(def_path, rec, label):
    """HPWL and trial-route congestion for an arbitrary DEF, no legalization gate."""
    sys.path.insert(0, str(R.FLOWS))
    from gp_metrics_compare import hpwl as indep_hpwl, density as raw_density
    out = {"label": label, "def": str(def_path)}
    try:
        if rec.get("lef"):
            out["hpwl"] = indep_hpwl(Path(def_path), Path(rec["lef"]))
    except Exception as ex:
        out["hpwl_error"] = repr(ex)
    try:
        d = raw_density(Path(def_path), Path(rec["case_root"]), 200, Path(R.foundry_of(rec)),
                        "egr", 64)
        out["egr_total"] = d.get("egr_total_overflow_union")
        out["egr_max"] = d.get("egr_max_overflow_union")
        out["egr_valid"] = d.get("egr_valid")
        if not d.get("ok"):
            out["egr_reason"] = d.get("reason") or d.get("congestion_reason")
    except Exception as ex:
        out["egr_error"] = repr(ex)
    return out


def one(a):
    design, rec, picks, root = a
    wid = mp.current_process()._identity
    idx = (wid[1] if len(wid) > 1 else 0)
    base = 448 + (idx % 8) * 8
    os.environ["RSI_CPUSET"] = "%d-%d" % (base, base + 7)
    res = {"design": design, "pdk": rec.get("pdk"), "innovus_hpwl_ref": rec.get("innovus_hpwl")}
    inv = rec.get("innovus_def")
    if inv and Path(inv).exists():
        res["reference"] = raw_metrics(inv, rec, "innovus")
    else:
        res["reference"] = {"error": "missing innovus_def"}
    for name, cand in (picks or {}).items():
        if cand and Path(cand).exists():
            res[name] = raw_metrics(cand, rec, name)
    try:
        R.design_status(design, "%s|%s" % (design, IID), "innovus-anchor", 0, "V4", IID, 0,
                        {}, res, {"wall_s": None, "cpu_s": None}, status="ok",
                        note="external reconciliation")
    except Exception:
        pass
    return res


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=str(R.RSI_ROOT / "runs/v2"))
    ap.add_argument("--workers", type=int, default=4)
    ap.add_argument("--out", default=str(R.RSI / "analysis/out/innovus_anchor.json"))
    args = ap.parse_args()
    root = Path(args.root)
    designs = R.load_designs()
    jobs = []
    for design, rec in sorted(designs.items()):
        picks = {}
        s1 = root / "stage1" / design
        if s1.is_dir():
            tr = None
            try:
                tr = json.loads((R.RSI / "analysis/out/stage1_fidelity.json").read_text())
                tr = (tr.get("per_design") or {}).get(design, {}).get("best_cand", "")
                tr = tr.replace("candidate=", "")
            except Exception:
                tr = None
            if tr and (s1 / tr / "placement.def").exists():
                picks["our_truth_best"] = str(s1 / tr / "placement.def")
            v0 = s1 / "td095_ce0_s1000" / "placement.def"
            if v0.exists():
                picks["our_v0_attractor"] = str(v0)
        jobs.append((design, rec, picks, str(root)))
    print(json.dumps({"stage": "anchor", "designs": len(jobs), "workers": args.workers}))
    sys.stdout.flush()
    t0 = time.time()
    out = []
    if args.workers <= 1:
        for j in jobs:
            out.append(one(j))
    else:
        with mp.Pool(args.workers) as pool:
            for res in pool.imap_unordered(one, jobs):
                out.append(res)
                if len(out) % 5 == 0:
                    print("anchored %d/%d elapsed %.0fs" % (len(out), len(jobs), time.time() - t0))
                    sys.stdout.flush()
    Path(args.out).parent.mkdir(parents=True, exist_ok=True)
    Path(args.out).write_text(json.dumps(out, indent=1))
    have = [r for r in out if (r.get("reference") or {}).get("hpwl")]
    print("anchored %d/%d with a usable reference HPWL in %.0fs" % (len(have), len(out), time.time() - t0))
    for r in have[:6]:
        print("  %-20s ref_hpwl=%-9s ours=%-9s ref_egr=%-6s ours_egr=%s" % (
            r["design"], r["reference"].get("hpwl"),
            (r.get("our_truth_best") or {}).get("hpwl"),
            r["reference"].get("egr_total"),
            (r.get("our_truth_best") or {}).get("egr_total")))
    return 0


if __name__ == "__main__":
    sys.exit(main())
