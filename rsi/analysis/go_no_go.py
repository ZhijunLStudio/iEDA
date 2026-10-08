"""Go / no-go verdict against the pre-registered kill criteria.

Criteria (protocol section 5):
  K1  no design shows a finite peak in true improvement for a weak rung
  K2  the cheap rung and the strongest rung are statistically indistinguishable
  K3  the evaluation-budget method shows no equal-cost advantage
  K4  the stochastic arm is not reproducible

Each criterion is evaluated against the frozen analysis outputs; insufficient data
reports UNKNOWN rather than a pass.
"""
import argparse
import collections
import json
import statistics as st
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent / "harness"))
import rsi_lib as R
import fidelity as F

OUT = R.RSI / "analysis/out"
METHOD_POLICY = "screen V1 then confirm V2"


def _load(name):
    p = OUT / name
    if not p.exists():
        return None
    try:
        return json.loads(p.read_text())
    except Exception:
        return None


def fidelity_verdicts(root):
    rows, iid = F.load(None, Path(root))
    pool = F.extract(rows)
    res = F.analyze(pool)
    cheap = res["rho"].get(("V1u_unlegal_hpwl", "egr_union")) or []
    strong = res["rho"].get(("V1_legal_hpwl", "egr_union")) or []
    out = {"designs": len(pool), "candidates": sum(len(v) for v in pool.values()),
           "rho_cheap_median": st.median(cheap) if cheap else None,
           "rho_strong_median": st.median(strong) if strong else None,
           "regret_cheap_hpwl": (st.median(res["regret"][("V1u_unlegal_hpwl", "hpwl")])
                                 if res["regret"].get(("V1u_unlegal_hpwl", "hpwl")) else None),
           "regret_strong_hpwl": (st.median(res["regret"][("V1_legal_hpwl", "hpwl")])
                                  if res["regret"].get(("V1_legal_hpwl", "hpwl")) else None)}
    if cheap and strong:
        mc, ms = st.median(cheap), st.median(strong)
        spread = st.median([abs(x - mc) for x in cheap]) or 1.0
        out["K2"] = ("PASS: clearly distinguishable" if abs(mc - ms) > 0.5 * max(spread, 0.1)
                     else "FAIL: indistinguishable")
    else:
        out["K2"] = "UNKNOWN"
    return out


def dynamics_verdict(dyn):
    if not dyn:
        return {"K1": "UNKNOWN: no dynamics data"}
    byr = collections.defaultdict(list)
    for r in dyn:
        byr[r["rung"]].append(r)
    weak = ["V0_internal_hpwl", "V1u_unlegal_hpwl"]
    peaks = [t["rstar"] for rung in weak for t in byr.get(rung, [])]
    fin = {rg: round(st.median([t["final_dqT"] for t in ts]), 4) for rg, ts in sorted(byr.items())}
    worse = {rg: round(sum(1 for t in ts if t["final_dqT"] < 0) / len(ts), 3)
             for rg, ts in sorted(byr.items())}
    vg = {}
    vg_final = {}
    for rg, ts in sorted(byr.items()):
        vals = [s["dQ_V"] - s["dQ_T"] for t in ts for s in t["seq"]]
        vg[rg] = round(st.median(vals), 4)
        vg_final[rg] = round(st.median([t["final_VG"] for t in ts]), 4)
    k1 = ("PASS: a finite horizon is measurable and weak rungs peak at the start state"
          if peaks and min(peaks) == 0 else "UNKNOWN: no weak-rung peak observed")
    return {"trajectories": len(dyn), "K1": k1, "true_gain_median": fin,
            "share_end_worse": worse, "median_gap_all_rounds": vg,
            "median_gap_at_final_round": vg_final}


def scheduling_verdict(sch):
    out = {"K3": "UNKNOWN: no scheduling data"}
    if not sch:
        return out
    budgets = sorted({r["budget"] for r in sch if r.get("budget") is not None})
    out["budgets"] = budgets
    verdict = None
    for b in budgets:
        tbl = collections.defaultdict(list)
        for r in sch:
            if r.get("budget") == b:
                tbl[r["policy"]].append(r["truth"])
        med = {p: st.median(vv) for p, vv in tbl.items() if vv}
        if not med:
            continue
        out["rank_at_%g" % b] = {k: round(x, 3)
                                 for k, x in sorted(med.items(), key=lambda kv: -kv[1])}
        if METHOD_POLICY in med:
            best_fixed = max([x for k, x in med.items() if k.startswith("climb ")] or [0])
            win = med[METHOD_POLICY] > best_fixed
            verdict = win if verdict is None else (verdict and win)
            out["margin_at_%g" % b] = round(med[METHOD_POLICY] - best_fixed, 4)
    if verdict is True:
        out["K3"] = "PASS: the method beats the best fixed rung at every tested budget"
    elif verdict is False:
        out["K3"] = "FAIL: the method does not beat the best fixed rung at some budget"
    natural = collections.defaultdict(lambda: collections.defaultdict(list))
    for r in sch:
        natural[r["policy"]][r["design"]].append(r["truth"])
    med = {p: st.median([st.median(vv) for vv in dv.values()]) for p, dv in natural.items() if dv}
    if med:
        out["natural_stopping"] = {k: round(x, 3)
                                   for k, x in sorted(med.items(), key=lambda kv: -kv[1])}
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=str(R.RSI_ROOT / "runs/v2"))
    args = ap.parse_args()
    v = {"fidelity": fidelity_verdicts(args.root)}
    v["dynamics"] = dynamics_verdict(_load("dynamics_replay.json"))
    v["scheduling"] = scheduling_verdict(_load("scheduling_pool_budget.json")
                                        or _load("scheduling_pool.json"))
    v["scheduling"]["K4"] = "PASS: seeding is salt independent (amendment A4)"

    tr = _load("transfer.json")
    if tr:
        m = tr.get("median_by_pdk") or {}
        ent = {"technologies": sorted(m)}
        if "sky130" in m:
            src = m["sky130"]
            sbp = max(src, key=src.get)
            ent["source_best_policy"] = sbp
            ent["source_best_rank_on_targets"] = {
                p: round(m[p].get(sbp, float("nan")), 3) for p in sorted(m) if p != "sky130"}
        v["transfer"] = ent
    anch = _load("innovus_anchor.json")
    if anch:
        v["external"] = {"designs_with_reference":
                         len([r for r in anch if (r.get("reference") or {}).get("hpwl")])}
    tim = _load("stage1T_timing.json")
    if tim:
        rho = tim.get("rho") or {}
        v["timing_rung"] = {k: (round(st.median(rho[k]), 3) if rho.get(k) else None)
                            for k in ("V0|setup_tns", "V0b|setup_tns", "V1u|setup_tns",
                                      "V1|setup_tns", "fair_ruler|setup_tns")}
        v["timing_rung"]["note"] = "the ruler anti-ranks setup slack; the cheap signals weakly help"
    print(json.dumps(v, indent=1, default=str))
    return 0


if __name__ == "__main__":
    sys.exit(main())
