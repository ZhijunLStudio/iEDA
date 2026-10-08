"""Resolve the files a placement timing evaluation needs, then run it.

Timing is the next rung above the fair ruler: it needs the cell library and the
clock constraint, not just geometry. Paths are resolved into the isolated
workspace and written into a per-design config directory so nothing points back
at the historical source tree.
"""
import glob
import json
import os
import re
import shutil
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import rsi_lib as R

TIMING_TCL = HERE / "tcl/timing_eval.tcl"
_CFG_CACHE = {}


def _pick(pattern, prefer=None):
    hits = sorted(glob.glob(pattern))
    if not hits:
        return None
    if prefer:
        for h in hits:
            if prefer in os.path.basename(h):
                return h
    return hits[0]


def _pick_lib(foundry):
    """One library per design, resolved by a documented priority list.

    The foundries name their timing libraries differently, and a design only has
    one variant in this benchmark, so the choice is deterministic: sky130 speed
    and corner suffix first, the nangate45 merged library next, then a typical
    corner of whatever liberty files exist. Memory and stub libraries are never
    picked as the main library.
    """
    order = ["**/*tt_025C_1v80*.lib", "**/merged.lib", "**/*_tt_*nldm.lib",
             "**/*tt*.lib", "**/*_nldm.lib", "**/*.lib"]
    for pat in order:
        hits = [h for h in sorted(glob.glob(str(Path(foundry) / pat), recursive=True))
                if not re.search(r"fakeram|fill_stub|_hold_|_drv_", os.path.basename(h))]
        if hits:
            return hits[0]
    return None


def _resolve_tech_lef(fd, lef, design):
    """Tech LEF for an arbitrary DEF/LEF pair.

    Priority: the design's own declaration (with the foundry placeholder
    substituted), then a sibling of the cell LEF whose name says "tech", then a
    sibling obtained by stripping the usual cell-library markers, then the
    sky130-style merged-to-tlef rename, and only then the cell LEF itself.
    """
    bd = R.IEDA_ROOT / "benchmarks/designs" / design
    dj = bd / "design.json"
    if dj.exists():
        try:
            inputs = (json.loads(dj.read_text()) or {}).get("inputs") or {}
            declared = inputs.get("tech_lef")
            if declared:
                cand = declared.replace("$PDK", str(fd))
                if Path(cand).exists():
                    return cand
        except Exception:
            pass
    if lef:
        cand = str(lef).replace("_merged.lef", ".tlef")
        if cand != str(lef) and Path(cand).exists():
            return cand
        d = Path(lef).parent
        sibs = [str(p) for p in sorted(d.glob("*.lef")) if str(p) != str(lef)]
        for p in sibs:
            if "tech" in os.path.basename(p).lower():
                return p
        base = os.path.basename(str(lef))
        stripped = re.sub(r"(_ecos|_merged|_ant|_ieda|\.macro(\.mod|\.rect)?)", "", base)
        for p in sibs:
            if re.sub(r"(_ecos|_merged|_ant|_ieda|\.macro(\.mod|\.rect)?)", "",
                      os.path.basename(p)) == stripped:
                return p
        if sibs:
            return min(sibs, key=lambda p: os.path.getsize(p))
    return _pick(str(fd / "lef/*.tlef"), "hd")


def resolve(design, rec):
    fd = Path(R.foundry_of(rec))
    lef = rec.get("lef") or R.lef_of(rec)
    variant = None
    m = re.search(r"(sky130_fd_sc_\w+|fd_sc_\w+)", os.path.basename(lef or ""))
    if m:
        variant = m.group(1)
    tlef = _resolve_tech_lef(fd, lef, design)
    lib = _pick_lib(fd)
    bd = R.IEDA_ROOT / "benchmarks/designs" / design
    sdc = _pick(str(bd / "sdc/*.sdc"))
    if not sdc:
        sdc = _pick(str(rec.get("case_root", "")) + "/*.sdc")
    if not sdc:
        sdc = _pick(str(rec.get("case_root", "")) + "/**/*.sdc")
    netlist = _pick(str(bd / "netlist/*.v"))
    if not netlist:
        netlist = _pick(str(rec.get("case_root", "")) + "/**/*.v")
    return {"tech_lef": tlef, "lef": lef, "lib": lib, "sdc": sdc,
            "netlist": netlist, "design_dir": str(bd) if bd.exists() else None}


def prepare_config(design, rec, run_dir):
    key = design
    if key in _CFG_CACHE:
        return _CFG_CACHE[key]
    paths = resolve(design, rec)
    src = Path(rec["case_root"]) / "iEDA_config"
    dst = Path(run_dir) / ("timing_cfg/%s" % design)
    dst.mkdir(parents=True, exist_ok=True)
    for f in ("flow_config.json",):
        s = src / f
        if s.exists():
            shutil.copy(s, dst / f)
    dbc = src / "db_default_config.json"
    db = json.loads(dbc.read_text()) if dbc.exists() else {"INPUT": {}}
    inp = db.setdefault("INPUT", {})
    if paths["tech_lef"]:
        inp["tech_lef_path"] = paths["tech_lef"]
    if paths["lef"]:
        inp["lef_paths"] = paths["lef"]
    if paths["lib"]:
        inp["lib_path"] = paths["lib"]
    if paths["sdc"]:
        inp["sdc_path"] = paths["sdc"]
    if paths["netlist"]:
        inp["verilog_path"] = paths["netlist"]
    inp["def_path"] = ""
    db.setdefault("OUTPUT", {})["output_dir_path"] = str(dst / "out")
    (dst / "db_default_config.json").write_text(json.dumps(db, indent=4))
    _CFG_CACHE[key] = (dst, paths)
    return _CFG_CACHE[key]


def timing_of(def_path, design, rec, run_dir, timeout=5400):
    """Return (ok, metrics) for the placement timing evaluation of one DEF."""
    cfg, paths = prepare_config(design, rec, run_dir)
    if not (paths["lib"] and paths["sdc"] and paths["lef"] and paths["tech_lef"]):
        return False, {"reason": "missing library/sdc/lef", "paths": paths}
    rd = Path(run_dir) / ("timing_out/%s" % design)
    rd.mkdir(parents=True, exist_ok=True)
    env = {"CONFIG_DIR": str(cfg), "RESULT_DIR": str(rd), "INPUT_DEF": str(def_path),
           "TECH_LEF": paths["tech_lef"], "LEF": paths["lef"], "LIB": paths["lib"],
           "SDC": paths["sdc"]}
    cmd = [str(R.IEDA_ROOT / "bin/iEDA"), "-script", str(TIMING_TCL)]
    r = R.run_cmd(cmd, cwd=rd, timeout=timeout, env=env)
    txt = (r["stdout"] or "") + (r["stderr"] or "")
    out = {}
    for key, pat in (("setup_wns", r"Setup WNS:\s*(-?[\d.eE+-]+)"),
                     ("setup_tns", r"Setup TNS:\s*(-?[\d.eE+-]+)"),
                     ("hold_wns", r"Hold WNS:\s*(-?[\d.eE+-]+)"),
                     ("hold_tns", r"Hold TNS:\s*(-?[\d.eE+-]+)"),
                     ("suggest_freq", r"Suggest freq:\s*(-?[\d.eE+-]+)")):
        mm = re.findall(pat, txt)
        if mm:
            try:
                out[key] = float(mm[-1])
            except ValueError:
                pass
    out["cost_s"] = r["wall_s"]
    out["cpu_s"] = r["cpu_s"]
    out["rc"] = r["rc"]
    ok = "setup_wns" in out
    if not ok:
        out["reason"] = "no timing line parsed"
        out["tail"] = txt[-500:]
    return ok, out
