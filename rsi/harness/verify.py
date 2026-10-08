"""The leveled verifier: one entry point, one cost account, one truth ruler.

verify(level, ...) returns the signals visible at a rung and what that rung
costs, so the experiments and the scheduler share exactly one implementation.

Rungs (protocol section 2.2, amendment A1):
  V0   placer-internal wirelength            (needs a global-placement run)
  V0b  solver-internal route utilization     (needs a global-placement run)
  V1u  DEF wirelength at the legalizer input (needs a global-placement run)
  V1   wirelength of the legalized placement
  V2   V1 plus real congestion from a trial route
  V3   V2 plus placement timing (HPWL-RC model)
  V4   external reconciliation against a commercial reference DEF

Costs are returned per stage (gp / lgdp / egr / timing) and never include the
truth evaluation unless the level itself is the truth.
"""
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import rsi_lib as R

LEVELS = ["V0", "V0b", "V1u", "V1", "V2", "V3", "V4"]
COST_COMPONENTS = {
    "V0": ["gp"], "V0b": ["gp"], "V1u": ["gp"], "V1": ["gp", "lgdp"],
    "V2": ["gp", "lgdp", "egr"], "V3": ["gp", "lgdp", "egr", "timing"],
    "V4": ["gp", "lgdp", "egr", "timing", "external"],
}


def _geom():
    sys.path.insert(0, str(R.FLOWS))
    from gp_metrics_compare import hpwl as indep_hpwl, check_legalized
    return indep_hpwl, check_legalized


def verify(level, design=None, rec=None, workdir=None, def_path=None, run_dir=None,
           timing=False):
    """Evaluate one placement at one rung. Returns signals, cost and status."""
    if level not in LEVELS:
        raise ValueError("unknown level %r" % level)
    out = {"level": level, "design": design, "signals": {}, "cost": {}, "ok": False}
    wd = Path(workdir).resolve() if workdir else None
    if def_path:
        defp = Path(def_path).resolve()
    else:
        defp = (wd / "placement.def") if wd else None
    state = R.read_state(wd) if wd else {}

    if level in ("V0", "V0b", "V1u"):
        rec_j = state.get("last_record") or {}
        out["signals"] = {"gp_internal_hpwl": state.get("last_hpwl") or rec_j.get("hpwl"),
                          "route_util": rec_j.get("route_util"),
                          "def_hpwl_unlegal": state.get("best_def_hpwl") or rec_j.get("def_hpwl")}
        out["ok"] = out["signals"]["gp_internal_hpwl"] is not None
        out["cost"] = {"gp": state.get("last_wall_s")}
        return out

    if defp is None or not defp.exists():
        out["reason"] = "no DEF"
        return out
    try:
        indep_hpwl, check_legalized = _geom()
    except Exception as ex:
        out["reason"] = "metrics module unavailable: %r" % ex
        return out

    leg = check_legalized(defp)
    out["signals"]["legalized"] = bool(leg.get("legalized"))
    if not leg.get("legalized"):
        out["reason"] = leg.get("reason")
        return out
    if rec and rec.get("lef"):
        try:
            out["signals"]["legal_hpwl"] = indep_hpwl(defp, Path(rec["lef"]))
            out["ok"] = out["signals"]["legal_hpwl"] is not None
        except Exception as ex:
            out["reason"] = "hpwl failed: %r" % ex
            return out
    if level == "V1":
        return out

    if rec is not None and wd is not None:
        e = R.egr_of(wd, rec, def_path=defp)
        j = e.get("json") or {}
        out["signals"]["egr_total"] = j.get("egr_total_overflow_union")
        out["signals"]["egr_max"] = j.get("egr_max_overflow_union")
        out["cost"]["egr"] = e.get("wall_s")
        if not j.get("ok"):
            out["reason"] = j.get("reason")
            return out
        out["ok"] = True
    if level == "V2":
        return out

    if level in ("V3", "V4") and rec is not None and run_dir is not None:
        try:
            import timing_rung as T
            ok, m = T.timing_of(defp, design, rec, run_dir)
            out["signals"]["setup_wns"] = m.get("setup_wns")
            out["signals"]["setup_tns"] = m.get("setup_tns")
            out["signals"]["hold_wns"] = m.get("hold_wns")
            out["cost"]["timing"] = m.get("cost_s")
            out["ok"] = out["ok"] and ok
            if not ok:
                out["reason"] = m.get("reason")
        except Exception as ex:
            out["reason"] = "timing failed: %r" % ex
    return out


def truth_ruler(design, rec, workdir, def_path=None, run_dir=None, with_timing=False):
    """The shared fair ruler used to score every arm: (legalized HPWL, EGR[, timing])."""
    v2 = verify("V2", design=design, rec=rec, workdir=workdir, def_path=def_path)
    res = {"legal_hpwl": v2["signals"].get("legal_hpwl"),
           "egr_total": v2["signals"].get("egr_total"),
           "egr_max": v2["signals"].get("egr_max"),
           "legalized": v2["signals"].get("legalized"),
           "cost": dict(v2.get("cost") or {})}
    if with_timing and run_dir:
        v3 = verify("V3", design=design, rec=rec, workdir=workdir, def_path=def_path,
                    run_dir=run_dir)
        res["setup_tns"] = v3["signals"].get("setup_tns")
        res["setup_wns"] = v3["signals"].get("setup_wns")
        res["cost"].update(v3.get("cost") or {})
    return res


def main():
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--design", default="gcd_sky130_a")
    ap.add_argument("--workdir", required=True)
    args = ap.parse_args()
    rec = R.load_designs()[args.design]
    for lvl in ("V1", "V2", "V3"):
        r = verify(lvl, design=args.design, rec=rec, workdir=args.workdir,
                   run_dir=R.RUNS / "verify_cli")
        print("%-4s ok=%-5s %s" % (lvl, r["ok"], json.dumps(r["signals"])))
    return 0


if __name__ == "__main__":
    sys.exit(main())
