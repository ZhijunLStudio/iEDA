"""Number audit: every headline claim checked against the frozen analysis output.

The paper quotes numbers; this script re-derives each one from the analysis files and
compares it with the value printed in the paper. A mismatch is reported as a failure,
so the audit can be run as a pre-submission check rather than by eye.

Expected values are the ones in paper/RESULTS.md and the draft. Tolerances are absolute
and tight enough to catch a wrong number, loose enough to survive rounding.
"""
import argparse
import json
import statistics as st
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent / "harness"))
import rsi_lib as R

OUT = R.RSI / "analysis" / "out"
TOL = 5e-3


def j(name):
    p = OUT / name
    return json.loads(p.read_text()) if p.exists() else None


def median(vals):
    vals = [v for v in vals if v is not None]
    return st.median(vals) if vals else None


def check(results, label, got, want, tol=TOL):
    if got is None:
        results.append((label, "MISSING", want))
        return
    ok = abs(got - want) <= tol
    results.append((label, "ok" if ok else "MISMATCH", "got %.4f want %.4f" % (got, want)))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=str(R.RSI_ROOT / "runs/v2"))
    args = ap.parse_args()
    res = []

    # ---- fidelity
    f = j("stage1_fidelity.json")
    if f:
        rho = f.get("rho") or {}
        check(res, "rho unlegalized vs legalized hpwl",
              median(rho.get("V1u_unlegal_hpwl|legal_hpwl") or []), -0.891)
        check(res, "rho unlegalized vs congestion",
              median(rho.get("V1u_unlegal_hpwl|egr_union") or []), -0.922)
        check(res, "rho legalized vs congestion",
              median(rho.get("V1_legal_hpwl|egr_union") or []), 0.970)
        check(res, "rho route_util vs congestion",
              median(rho.get("V0b_route_util|egr_union") or []), 0.737)
        check(res, "designs in pool", float(len(f.get("per_design") or {})), 32, tol=0.5)

    # ---- timing
    t = j("stage1T_timing.json")
    if t:
        rho = t.get("rho") or {}
        check(res, "rho legalized vs setup TNS", median(rho.get("V1|setup_tns") or []), -0.471)
        check(res, "rho unlegalized vs setup TNS", median(rho.get("V1u|setup_tns") or []), 0.216)
        check(res, "rho route_util vs setup TNS", median(rho.get("V0b|setup_tns") or []), -0.213)

    # ---- dynamics
    d = j("dynamics_replay.json")
    if d:
        by = {}
        for x in d:
            by.setdefault(x["rung"], []).append(x)
        for rung, want in (("V0_internal_hpwl", -0.482), ("V1u_unlegal_hpwl", -0.500),
                           ("V1_legal_hpwl", 0.161), ("V2_ruler", 0.143)):
            check(res, "dQ_T %s" % rung,
                  median([x["final_dqT"] for x in by.get(rung, [])]), want)
        check(res, "VG V0", median([x["final_VG"] for x in by.get("V0_internal_hpwl", [])]), 1.218)
        check(res, "VG V1u", median([x["final_VG"] for x in by.get("V1u_unlegal_hpwl", [])]), 1.232)
        for rung, want in (("V0_internal_hpwl", 0.0), ("V1u_unlegal_hpwl", 0.0),
                           ("V1_legal_hpwl", 4.0), ("V2_ruler", 3.0)):
            check(res, "r* %s" % rung, float(median([x["rstar"] for x in by.get(rung, [])])), want, tol=0.5)
        for rung, want in (("V0_internal_hpwl", 0.93), ("V1u_unlegal_hpwl", 0.90),
                           ("V1_legal_hpwl", 0.10)):
            v = by.get(rung, [])
            if v:
                check(res, "share worse %s" % rung,
                      sum(1 for x in v if x["final_dqT"] < 0) / len(v), want, tol=0.02)
        check(res, "NSI V1", median([x["NSI"] for x in by.get("V1_legal_hpwl", [])]), 6.37e-4, tol=5e-6)
        check(res, "AR V0", median([x["absorption_rate"] for x in by.get("V0_internal_hpwl", []) if x.get("absorption_rate") is not None]), 0.33, tol=0.01)
        check(res, "AR V1", median([x["absorption_rate"] for x in by.get("V1_legal_hpwl", []) if x.get("absorption_rate") is not None]), 0.67, tol=0.01)

    # ---- mechanism
    m = j("mechanism.json")
    if m:
        by = {}
        for x in m:
            by.setdefault(x["rung"], []).append(x)
        check(res, "confirmed gain V0", median([x["confirmed_gain"] for x in by.get("V0_internal_hpwl", [])]), 0.214)
        check(res, "harmful loss V0", median([x["harmful_loss"] for x in by.get("V0_internal_hpwl", [])]), 0.732)
        check(res, "confirmed gain V2", median([x["confirmed_gain"] for x in by.get("V2_ruler", [])]), 0.554)
        check(res, "harmful loss V2", median([x["harmful_loss"] for x in by.get("V2_ruler", [])]), 0.339)

    # ---- scheduling
    s = j("scheduling_pool_budget.json") or j("scheduling_pool.json")
    if s:
        import collections
        tab = collections.defaultdict(list)
        for x in s:
            if x.get("budget") == 100.0:
                tab[x["policy"]].append(x["truth"])
        check(res, "policy screen V1 at 100s", median(tab.get("screen V1 then confirm V2", [])), 0.893)
        check(res, "policy climb V1 at 100s", median(tab.get("climb V1 (legalized wirelength)", [])), 0.804)

    # ---- transfer
    tr = j("transfer.json")
    if tr:
        med = (tr.get("median_by_pdk") or {})
        if "sky130" in med and "ics55" in med:
            check(res, "screen V1 rank on sky130", med["sky130"].get("screen V1 then confirm V2"), 0.902)
            check(res, "screen V1 rank on ics55", med["ics55"].get("screen V1 then confirm V2"), 0.893)
            check(res, "screen V1 rank on nangate45", med["nangate45"].get("screen V1 then confirm V2"), 0.799)

    # ---- anchor
    a = j("innovus_anchor.json")
    if a:
        rows = [x for x in a if (x.get("reference") or {}).get("hpwl")]
        ratios_tb = [(x["our_truth_best"] or {}).get("hpwl", 0) / x["reference"]["hpwl"]
                     for x in rows if (x.get("our_truth_best") or {}).get("hpwl")]
        ratios_v0 = [(x["our_v0_attractor"] or {}).get("hpwl", 0) / x["reference"]["hpwl"]
                     for x in rows if (x.get("our_v0_attractor") or {}).get("hpwl")]
        check(res, "anchor ruler hpwl ratio", median(ratios_tb), 0.935)
        check(res, "anchor cheap-rung hpwl ratio", median(ratios_v0), 1.089)
        wins = sum(1 for x in rows
                   if (x.get("our_truth_best") or {}).get("hpwl") and (x.get("our_v0_attractor") or {}).get("hpwl")
                   and x["our_truth_best"]["hpwl"] < x["our_v0_attractor"]["hpwl"])
        check(res, "anchor paired wins (of 32)", float(wins), 31.0, tol=0.5)

    # ---- sealed arms
    sa = j("sealed_arms.json")
    if sa:
        check(res, "sealed A1 unlegalized", median(sa.get("sealed", {}).get("A1 (fixed rung, unlegalized wirelength)") or []), -0.536)
        check(res, "sealed A2 ruler", median(sa.get("sealed", {}).get("A2 (fair ruler, Pareto)") or []), 0.125)

    # ---- live
    lv = j("live_vs_replay.json")
    if lv:
        live = lv.get("live") or []
        by = {}
        for x in live:
            by.setdefault(x["rung"], []).append(x)
        check(res, "live dQ_T V0",
              median([x["final_dqT"] for x in by.get("V0_internal_hpwl", [])]), -0.699)
        check(res, "live dQ_T V1u",
              median([x["final_dqT"] for x in by.get("V1u_unlegal_hpwl", [])]), -0.644)
        check(res, "live dQ_T V1",
              median([x["final_dqT"] for x in by.get("V1_legal_hpwl", [])]), 0.175)
        check(res, "live dQ_T V2",
              median([x["final_dqT"] for x in by.get("V2_ruler", [])]), 0.159)
        check(res, "live cells", float(len(live)), 128.0, tol=0.5)

    # ---- signoff spot check
    for label, fn, want in (("signoff geo_best DRC", "signoff_geo_best_drc.json", 155.0),
                            ("signoff v0_attractor DRC", "signoff_v0_attractor_drc.json", 332.0)):
        sg = j(fn)
        if sg:
            check(res, label, float(sg.get("violation_count") or -1), want, tol=0.5)

    bad = [r for r in res if r[1] != "ok"]
    print("number audit: %d checks, %d ok, %d problems" % (len(res), len(res) - len(bad), len(bad)))
    for label, status, detail in res:
        flag = "ok  " if status == "ok" else "FAIL"
        print("  %s %-42s %s" % (flag, label, detail))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
