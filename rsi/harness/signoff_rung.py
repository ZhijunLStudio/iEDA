"""Signoff rung: take a placement DEF through clock tree, routing and DRC.

This is the rung above placement timing. It is expensive (minutes to tens of
minutes per candidate) and is therefore used sparingly: to check whether the fair
ruler's preference still holds when the verdict is a routed design with a DRC
result, rather than another geometric proxy.

The flow stages are the project's own scripts. Each honours INPUT_DEF, OUTPUT_DEF,
RESULT_DIR, CONFIG_DIR, TCL_SCRIPT_DIR, FOUNDRY_DIR and SDC_FILE, which is what
lets one placed DEF be pushed through the same path a full flow would use.
"""
import argparse
import fcntl
import json
import os
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import rsi_lib as R

SCRIPTS = None


def script_dir(pdk):
    global SCRIPTS
    if SCRIPTS is None:
        SCRIPTS = R.IEDA_ROOT / "scripts/design" / ("%s_gcd" % pdk) / "script"
    return SCRIPTS


SIGNOFF_TCL = HERE / "tcl/signoff_stage.tcl"


def run_stage(name, tcl, design, rec, work, def_in, def_out=None, timeout=7200, extra_env=None):
    sd = script_dir(rec.get("pdk") or "sky130")
    env = {"CONFIG_DIR": str(Path(rec["case_root"]) / "iEDA_config"),
           "RESULT_DIR": str(work),
           "TCL_SCRIPT_DIR": str(sd),
           "FOUNDRY_DIR": str(R.foundry_of(rec)),
           "STAGE": name,
           "INPUT_DEF": str(def_in)}
    sdc = None
    try:
        bd = R.IEDA_ROOT / "benchmarks/designs" / design
        cands = sorted(bd.glob("sdc/*.sdc"))
        if cands:
            sdc = str(cands[0])
        else:
            c2 = sorted(Path(rec["case_root"]).glob("*.sdc"))
            if c2:
                sdc = str(c2[0])
    except Exception:
        pass
    if sdc:
        env["SDC_FILE"] = sdc
        env["SDC"] = sdc
        env["LIB"] = str(R.lef_of(rec)).replace("_merged.lef", "__none__")
    lib = None
    try:
        import glob as _g
        fd = Path(R.foundry_of(rec))
        hits = sorted(_g.glob(str(fd / "**/*tt_025C_1v80*.lib"), recursive=True))
        if not hits:
            hits = sorted(_g.glob(str(fd / "lib/*.lib"))) or sorted(_g.glob(str(fd / "**/merged.lib"), recursive=True))
        hits = [h for h in hits if "_hold_" not in h and "fakeram" not in h and "fill_stub" not in h]
        if hits:
            lib = hits[0]
    except Exception:
        pass
    tl = None
    try:
        import glob as _g
        hits = sorted(_g.glob(str(Path(R.lef_of(rec)).parent / "*.tlef")))
        if hits:
            tl = hits[0]
    except Exception:
        pass
    if lib:
        env["LIB"] = lib
    if tl:
        env["TECH_LEF"] = tl
    env["LEF"] = str(R.lef_of(rec))
    if def_out:
        env["OUTPUT_DEF"] = str(def_out)
    if extra_env:
        env.update(extra_env)
    cmd = [str(R.IEDA_ROOT / "bin/iEDA"), "-script", str(SIGNOFF_TCL)]
    r = R.run_cmd(cmd, cwd=work, timeout=timeout, env=env)
    txt = (r["stdout"] or "") + (r["stderr"] or "")
    return {"stage": name, "rc": r["rc"], "wall_s": r["wall_s"], "cpu_s": r["cpu_s"],
            "tail": txt[-400:]}


def drc_count(work):
    """Violation count from the DRC detail file, whichever format the stage wrote."""
    out = {}
    for pat in ("report/drc_summary.json", "drc/detail.json", "report/violations.json",
                "drc/detail.drc", "report/drc/iRT_drc.rpt", "report/drc.rpt"):
        p = Path(work) / pat
        if not p.exists():
            continue
        try:
            txt = p.read_text(errors="ignore")
        except Exception:
            continue
        out["file"] = pat
        out["lines"] = len(txt.splitlines())
        if pat.endswith(".json"):
            try:
                d = json.loads(txt)
                if isinstance(d, dict):
                    for k in ("violation_count", "violation_num", "count", "total", "num"):
                        if k in d:
                            out["violations"] = d[k]
                            break
                    if "violations" not in out and isinstance(d.get("drc"), dict):
                        for k in ("violation_num", "total"):
                            if k in d["drc"]:
                                out["violations"] = d["drc"][k]
            except Exception:
                pass
        if "violations" not in out:
            m = re.findall(r"(?i)violation[s]?\s*[:=]\s*(\d+)", txt)
            if m:
                out["violations"] = int(m[-1])
            else:
                out["violations_approx"] = max(0, len([l for l in txt.splitlines()
                                                       if l.strip() and not l.startswith("#")]) - 1)
    return out


def signoff(design, rec, def_in, work, timeout=7200, with_to=False):
    """Signoff chain for one placement, serialized per work directory.

    Two invocations that share a work directory would each write iCTS_result.def and
    the routing temp tree at the same time and the results would look plausible while
    being a mixture of two runs. An exclusive lock is taken for the whole chain.
    """
    import fcntl
    work = Path(work)
    work.mkdir(parents=True, exist_ok=True)
    lock = open(work / ".lock", "w")
    fcntl.flock(lock, fcntl.LOCK_EX)
    sd = script_dir(rec.get("pdk") or "sky130")
    stages = []
    cts_out = work / "iCTS_result.def"
    stages.append(run_stage("cts", None, design, rec, work, def_in, cts_out, timeout=timeout))
    if not cts_out.exists():
        fcntl.flock(lock, fcntl.LOCK_UN)
        return {"design": design, "ok": False, "stages": stages,
                "reason": "CTS produced no DEF"}
    rt_out = work / "iRT_result.def"
    stages.append(run_stage("rt", None, design, rec, work, cts_out, rt_out, timeout=timeout))
    if not rt_out.exists():
        fcntl.flock(lock, fcntl.LOCK_UN)
        return {"design": design, "ok": False, "stages": stages,
                "reason": "routing produced no DEF"}
    stages.append(run_stage("drc", None, design, rec, work, rt_out, None, timeout=timeout))
    d = drc_count(work)
    fcntl.flock(lock, fcntl.LOCK_UN)
    return {"design": design, "ok": True, "stages": stages, "drc": d,
            "cost_s": round(sum(s["wall_s"] for s in stages), 2),
            "def_in": str(def_in), "def_routed": str(rt_out)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--design", default="gcd_sky130_a")
    ap.add_argument("--defs", default="", help="comma list of label=path")
    ap.add_argument("--work", default="")
    ap.add_argument("--root", default=str(R.RSI_ROOT / "runs/v2"))
    args = ap.parse_args()
    rec = R.load_designs()[args.design]
    out = []
    for item in [x for x in args.defs.split(",") if x]:
        label, _, p = item.partition("=")
        work = Path(args.work or (R.RUNS / ("signoff/%s_%s" % (args.design, label))))
        res = signoff(args.design, rec, p, work)
        res["label"] = label
        out.append(res)
        R.design_status(args.design, "%s|signoff|%s" % (args.design, label), "signoff", 0,
                        "V4", R.improver_id("signoff-v1", [str(HERE / "signoff_rung.py")]), 0,
                        {"drc": res.get("drc")}, {"ok": res.get("ok")},
                        {"wall_s": res.get("cost_s"), "cpu_s": None},
                        status="ok" if res.get("ok") else "failed",
                        note="label=%s" % label)
        print(json.dumps({k: v for k, v in res.items() if k != "stages"}, default=str))
        for s in res["stages"]:
            print("   %-4s rc=%-4s wall=%.0fs" % (s["stage"], s["rc"], s["wall_s"]))
        sys.stdout.flush()
    return 0


if __name__ == "__main__":
    sys.exit(main())
