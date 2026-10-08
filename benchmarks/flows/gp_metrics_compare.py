#!/usr/bin/env python3
"""Same-evaluator placement comparison: HPWL + density + congestion + timing.

Every DEF is loaded by the SAME iEDA evaluators (no per-vendor scoring):
  - HPWL:       benchmarks/flows/def_hpwl_eval.py        (pure python, DEF-level)
  - density:    iEDA run_density_eval                     (cell-density peak/mean)
  - congestion: iEDA run_congestion_eval -model egr       (iRT early trial route,
                 i.e. the authoritative router overflow used for iEDA vs Innovus)
  - timing:     iEDA run_timing_eval -routing_type HPWL   (pre-route geometric RC)

Robustness / generalization notes:
  * temp dirs are cleaned up even on failure (try/finally + shutil.rmtree)
  * missing SDC degrades gracefully (timing skipped, density still runs)
  * every path is derived from the repo root; no hard-coded cross-repo paths
  * foundry_dir / macro-lef auto-resolve from pdk when not given (registry-driven)
  * a crashed evaluator still yields a structured {ok:false, ...} entry instead
    of silently dropping egr_* fields (the caller can distinguish "no data" from
    "not congested")

Usage (explicit):
  python3 benchmarks/flows/gp_metrics_compare.py \
    --design s1238 \
    --case-root <case> --macro-lef <lef> --foundry-dir <foundry> \
    --congestion-model egr --no-timing \
    raw=<innovus.def> candidate=<placement.def>

Usage (registry-driven: --design is enough, foundry/lef auto-resolved):
  python3 benchmarks/flows/gp_metrics_compare.py \
    --design s1238 --registry benchmarks/flows/deepseek_harness/designs.json \
    --congestion-model egr --no-timing \
    raw=<innovus.def> candidate=<placement.def>
"""
from __future__ import annotations

import argparse
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
IEDa_BIN = Path(os.environ.get("IEDA_BIN", REPO / "build/bin/iEDA"))
TIMING_EVAL_TCL = REPO / "benchmarks/flows/eval_timing_metrics.tcl"

# sys.executable is EMPTY when python3 is spawned as a plain interpreter on this
# box (no venv), which makes every subprocess.run([PY_EXE, ...]) fail with
# PermissionError. Resolve a real interpreter once and reuse it.
PY_EXE = sys.executable or shutil.which("python3") or shutil.which("python") or "python3"

try:
    from gp_agent import _derive_pdk_env
except Exception:  # pragma: no cover - gp_agent is a sibling in the same dir
    def _derive_pdk_env(foundry_dir: Path) -> dict:
        return {}


def resolve_lef(foundry_dir: Path, explicit: str | None = None) -> Path | None:
    """PDK-agnostic cell-LEF resolver used by this evaluator (NOT gp_agent's).

    Excludes tech/IO/pad LEFs and prefers merged/stdcell libraries, so a new
    foundry without a registry "lef" entry still resolves the correct cell LEF
    instead of silently picking an IO or tech LEF.
    """
    if explicit and Path(explicit).exists():
        return Path(explicit)
    if not Path(foundry_dir).is_dir():
        return None

    def is_cell_lef(p: Path) -> bool:
        lp = str(p).lower()
        if any(k in lp for k in ("techlef", "prtech", "/tech", "io_", "io/", "pad", "ant")):
            return False
        return True

    all_lef = sorted(Path(foundry_dir).rglob("*.lef"))
    merged = [p for p in all_lef if "merged" in p.name.lower() and is_cell_lef(p)]
    stdcell = [p for p in all_lef if ("stdcell" in str(p).lower() or "sc" in p.name.lower()) and is_cell_lef(p)]
    rest = [p for p in all_lef if is_cell_lef(p)]
    for pool in (merged, stdcell, rest):
        if pool:
            return pool[0]
    return None



def _cell_lib_key(path: Path) -> str:
    """Normalize a liberty file name to its CELL-LIBRARY name by stripping the
    PVT-corner suffix. Different corner files of the SAME cell library share the
    same key; distinct cell libraries (hd vs hs vs each SRAM in sky130) keep
    distinct keys."""
    name = path.name
    m = re.search(r"_(?:ss|ff|tt|typ|typical)[._][a-z0-9_.]+\.lib$", name, re.IGNORECASE)
    if m:
        return name[: m.start()].rstrip("_")
    return name  # no corner suffix (macro/dummy/fill): treat as its own library


def _corner_worst_key(path: Path) -> tuple:
    """Rank corner files of one cell library; higher = slower/worse setup corner."""
    n = path.name.lower()
    score = 0
    if "rcworst" in n:
        score += 1000
    if "cworst" in n:
        score += 800
    if "rcbest" in n:
        score -= 500
    if "cbest" in n:
        score -= 600
    if "ss" in n:
        score += 200
    if "ff" in n:
        score -= 100
    if "125" in n or "100c" in n:
        score += 60
    if "m40" in n or "0c" in n:
        score -= 40
    if "1p08" in n:
        score += 30
    if "1p32" in n or "1p2" in n:
        score += 10
    return (score, str(path))


def timing_lib_path(foundry_dir: Path) -> str:
    """Build a deterministic LIB_PATH for the iSTA timing evaluator.

    The evaluator (run_timing_eval -> InitSTA::evalTiming) reads every .lib in
    LIB_PATH. Foundries ship several PVT corners per cell library (ics55 ships
    ff/ss/tt; sky130 ships two temps for hs), so iSTA sees MULTIPLE delay tables
    for the SAME cell and, with no operating-condition selection, picks one
    non-deterministically -> the same DEF yields different WNS/TNS across runs.

    Fix:
      1. pick a single process corner class: ss > tt/typ > ff;
      2. within that class, group files by cell-library name (_cell_lib_key) and
         keep ONE worst-case file per library, so every cell has exactly one
         delay table;
      3. keep corner-less libraries (fakeram macros, dummy/fill stubs) as-is.
    """
    if not Path(foundry_dir).is_dir():
        return ""
    libs = []
    for p in Path(foundry_dir).rglob("*.lib"):
        n = p.name.lower()
        if p.name.startswith("._") or ".orig" in n or ".tmp" in n:
            continue
        libs.append(p)
    ss, tt, ff, other = [], [], [], []
    for p in libs:
        n = p.name.lower()
        if "ss" in n:
            ss.append(p)
        elif "typ" in n or "tt" in n:
            tt.append(p)
        elif "ff" in n:
            ff.append(p)
        else:
            other.append(p)
    corner = ss or tt or ff or []
    by_lib: dict[str, list] = {}
    for p in corner:
        by_lib.setdefault(_cell_lib_key(p), []).append(p)
    picked = [max(ps, key=_corner_worst_key) for ps in by_lib.values()]
    return " " + " ".join(sorted(str(x) for x in picked + other)) + " "



def run(cmd: list[str], cwd=REPO, timeout=1800, env=None):
    return subprocess.run(cmd, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                          text=True, timeout=timeout, env=env)


def hpwl(def_path: Path, macro_lef: Path) -> int | None:
    p = run([PY_EXE, str(REPO / "benchmarks/flows/def_hpwl_eval.py"), str(macro_lef), str(def_path)])
    m = re.search(r"HPWL=(\d+)", p.stdout)
    return int(m.group(1)) if m else None

def check_legalized(def_path: Path) -> dict:
    """Detect whether a placement DEF is site-aligned (legalized).

    A raw-GP placement has cells floating off the ROW grid; its HPWL/EGR look
    artificially good because cells overlap. This returns legalized:false so the
    EGR path can refuse to score such a DEF instead of producing a misleading
    comparison. Uses a >=90% aligned sample threshold to tolerate a few macros/IO
    pins that legitimately sit off-grid.
    """
    path = Path(def_path)
    if not path.exists():
        return {"legalized": False, "reason": "def missing", "sample": []}
    text = path.read_text(errors="ignore")
    origin_x = None
    step_x = None
    row_ys = set()
    # ROW ROW_0 unithd 39560 38080 FS DO 142 BY 1 STEP 460 0 ;
    for m in re.finditer(
        r"ROW\s+(\S+)\s+(\S+)\s+(\d+)\s+(\d+)\s+(\S+)\s+DO\s+(\d+)\s+BY\s+(\d+)\s+STEP\s+(\d+)\s+(\d+)",
        text,
    ):
        if origin_x is None:
            origin_x = int(m.group(3))
            step_x = int(m.group(8))
        row_ys.add(int(m.group(4)))
    if origin_x is None or step_x is None or step_x <= 0 or not row_ys:
        return {"legalized": False, "reason": "no usable ROW definition", "sample": []}
    # Only score COMPONENTS placements (PINS section may carry off-grid IO).
    comp_sec = text
    cm = re.search(r"COMPONENTS\s+\d+\s*;", text)
    em = re.search(r"END\s+COMPONENTS", text)
    if cm and em:
        comp_sec = text[cm.start():em.end()]
    placed = list(re.finditer(r"\+\s+PLACED\s+\(\s*(\d+)\s+(\d+)\s*\)", comp_sec))
    if not placed:
        return {"legalized": False, "reason": "no PLACED components", "sample": []}
    n = min(len(placed), 20)
    step = max(1, len(placed) // n)
    sample = []
    aligned = 0
    for i in range(0, len(placed), step):
        if len(sample) >= n:
            break
        x = int(placed[i].group(1))
        y = int(placed[i].group(2))
        ok = (x - origin_x) % step_x == 0 and y in row_ys
        sample.append({"x": x, "y": y, "aligned": ok})
        if ok:
            aligned += 1
    legal = len(sample) > 0 and aligned >= 0.9 * len(sample)
    return {
        "legalized": legal,
        "aligned": aligned,
        "sampled": len(sample),
        "origin_x": origin_x,
        "step_x": step_x,
        "reason": None if legal else "placement not site-aligned (cell overlap); run LG+DP before scoring",
        "sample": sample,
    }


def find_sdc(case_root: Path) -> Path | None:
    """Locate the SDC for a case, tolerating missing/oddly-named files."""
    if not case_root.is_dir():
        return None
    named = case_root / f"{case_root.name}.sdc"
    if named.exists():
        return named
    hits = sorted(case_root.glob("*.sdc"))
    return hits[0] if hits else None


def density(def_path: Path, case_root: Path, grid_size: int, foundry_dir: Path,
            congestion_model: str = "rudy", bin_cnt: int = 64) -> dict:
    """Run the SAME iEDA density + congestion evaluator on one DEF.

    Returns a structured dict. A crashed/empty evaluator yields ok:false with a
    reason, and egr_valid:false when congestion_model==egr, so consumers never
    mistake "evaluation failed" for "no congestion".
    """
    leg = check_legalized(def_path)
    work = Path(tempfile.mkdtemp(prefix="gp_density_eval_"))
    try:
        sdc = find_sdc(case_root)
        # DEF snapshot: copy the DEF into the private workdir BEFORE evaluating,
        # so a concurrently-rewritten placement.def (headless agent still
        # running) can never be read half-written and crash the evaluator.
        snap_def = work / "snapshot.def"
        shutil.copy2(def_path, snap_def)
        tcl = work / "density_eval.tcl"
        tcl.write_text(
            f"flow_init -config {shlex.quote(str(case_root / 'iEDA_config/flow_config.json'))}\n"
            f"db_init -config {shlex.quote(str(case_root / 'iEDA_config/db_default_config.json'))} -output_dir_path {shlex.quote(str(work))}\n"
            f"source {shlex.quote(str(case_root / 'script/DB_script/db_path_setting.tcl'))}\n"
            f"source {shlex.quote(str(case_root / 'script/DB_script/db_init_lef.tcl'))}\n"
            + (f"source {shlex.quote(str(case_root / 'script/DB_script/db_init_sdc.tcl'))}\n" if sdc else "")
            + f"def_init -path {shlex.quote(str(snap_def))}\n"
              f"run_density_eval -eval_output_path {shlex.quote(str(work))} -grid_size {grid_size} -stage place\n"
              f"run_congestion_eval -model {congestion_model} -bin_cnt_x {bin_cnt} -bin_cnt_y {bin_cnt} -eval_output_path {shlex.quote(str(work))}\n"
              f"flow_exit\n")
        env = os.environ.copy()
        env.update({"CONFIG_DIR": str(case_root / "iEDA_config"), "RESULT_DIR": str(work),
                    "TCL_SCRIPT_DIR": str(case_root / "script"),
                    "FOUNDRY_DIR": str(foundry_dir),
                    "SDC_FILE": str(sdc) if sdc else ""})
        env.update(_derive_pdk_env(Path(foundry_dir)))

        # Run with one retry: transient failures (e.g. resource contention while
        # 17 headless agents are concurrently placing) should not drop a case.
        p = run([str(IEDa_BIN), "-script", str(tcl)], env=env)
        if p.returncode != 0:
            p = run([str(IEDa_BIN), "-script", str(tcl)], env=env)

        result: dict = {"evaluator_rc": p.returncode, "legalized": leg["legalized"]}
        if congestion_model == "egr":
            # EGR metrics start as "invalid" and are only promoted to valid when
            # the trial router actually produced an overflow summary.
            result["egr_valid"] = False

        if p.returncode != 0:
            result["ok"] = False
            result["reason"] = f"iEDA evaluator exited with rc={p.returncode}"
            result["log_tail"] = p.stdout[-800:]
            return result

        result["ok"] = True
        csv = work / "density_map/place_allcell_density.csv"
        if csv.exists():
            try:
                values = []
                for line in csv.read_text().splitlines():
                    for token in line.split(","):
                        token = token.strip()
                        if token:
                            values.append(float(token))
                if values and all(v >= 0.0 for v in values):
                    result["peak_cell_density"] = max(values)
                    result["mean_cell_density"] = sum(values) / len(values)
                else:
                    result["ok"] = False
                    result["density_reason"] = "density csv contains negative values" if values else "density csv empty"
            except Exception:
                result["ok"] = False
                result["density_reason"] = "density csv unparsable"
        else:
            result["ok"] = False
            result["density_reason"] = "density csv missing"

        cj = work / "congestion_result.json"
        if cj.exists():
            try:
                cdata = json.loads(cj.read_text())
                result["congestion_model"] = cdata.get("model")
                if cdata.get("model") == "egr":
                    for _k in ("rudy_demand_max", "rudy_demand_total", "rudy_utilization_max",
                               "rudy_utilization_avg", "rudy_utilization_h_max", "rudy_utilization_v_max",
                               "rudy_overflow_bin_count", "rudy_overflow_util_sum", "congestion_bin_cnt"):
                        result.pop(_k, None)
                    result["egr_valid"] = bool(cdata.get("egr_valid"))
                    for _k in ("egr_total_overflow_horizontal", "egr_total_overflow_vertical",
                               "egr_total_overflow_union", "egr_max_overflow_horizontal",
                               "egr_max_overflow_vertical", "egr_max_overflow_union",
                               "egr_avg_overflow_horizontal", "egr_avg_overflow_vertical",
                               "egr_avg_overflow_union"):
                        if cdata.get(_k) is not None:
                            result[_k] = cdata[_k]
                    if not result.get("egr_valid"):
                        result["ok"] = False
                        result["congestion_reason"] = "EGR overflow summary marked invalid by evaluator"
                else:
                    result["rudy_demand_max"] = cdata.get("rudy_demand_max")
                    result["rudy_demand_total"] = cdata.get("rudy_demand_total")
                    result["rudy_utilization_max"] = cdata.get("rudy_utilization_max")
                    result["rudy_utilization_avg"] = cdata.get("rudy_utilization_avg")
                    result["rudy_utilization_h_max"] = cdata.get("rudy_utilization_h_max")
                    result["rudy_utilization_v_max"] = cdata.get("rudy_utilization_v_max")
                    result["rudy_overflow_bin_count"] = cdata.get("rudy_overflow_bin_count")
                    result["rudy_overflow_util_sum"] = cdata.get("rudy_overflow_util_sum")
                    result["congestion_bin_cnt"] = (cdata.get("bin_cnt_x"), cdata.get("bin_cnt_y"))
            except Exception as exc:
                result["ok"] = False
                result["congestion_reason"] = f"congestion json unparsable: {exc}"
        else:
            result["ok"] = False
            result["congestion_reason"] = "congestion json missing"
            if congestion_model == "egr":
                result["egr_valid"] = False

        return result
    finally:
        shutil.rmtree(work, ignore_errors=True)


def timing(def_path: Path, case_root: Path, foundry_dir: Path) -> dict:
    """Same pre-route HPWL-RC timing evaluator on one DEF. Skips gracefully when
    the SDC or the timing TCL is unavailable."""
    sdc = find_sdc(case_root)
    if not TIMING_EVAL_TCL.exists():
        return {"ok": False, "reason": "timing eval TCL missing", "timing_skipped": True}
    if sdc is None:
        return {"ok": False, "reason": "no SDC file for this case", "timing_skipped": True}
    work = Path(tempfile.mkdtemp(prefix="gp_timing_eval_"))
    try:
        snap_def = work / "snapshot.def"
        shutil.copy2(def_path, snap_def)
        env = os.environ.copy()
        env.update({"INPUT_DEF": str(snap_def), "RESULT_DIR": str(work),
                    "CONFIG_DIR": str(case_root / "iEDA_config"),
                    "TCL_SCRIPT_DIR": str(case_root / "script"),
                    "FOUNDRY_DIR": str(foundry_dir),
                    "SDC_FILE": str(sdc)})
        env.update(_derive_pdk_env(Path(foundry_dir)))
        # Override with a single-corner LIB_PATH so iSTA's delay model is
        # deterministic (see timing_lib_path docstring).
        env["LIB_PATH"] = timing_lib_path(Path(foundry_dir))
        p = run([str(IEDa_BIN), "-script", str(TIMING_EVAL_TCL)], env=env, timeout=1800)
        if p.returncode != 0:
            p = run([str(IEDa_BIN), "-script", str(TIMING_EVAL_TCL)], env=env, timeout=1800)
        tj = work / "timing_result.json"
        if p.returncode != 0 or not tj.exists():
            return {"ok": False, "rc": p.returncode, "log_tail": p.stdout[-800:]}
        data = json.loads(tj.read_text())
        clock = (data.get("HPWL", {}).get("clock_timings") or [{}])
        entry = clock[0] if clock else {}
        return {"ok": True, "setup_wns_ns": entry.get("setup_wns"), "setup_tns_ns": entry.get("setup_tns"),
                "hold_wns_ns": entry.get("hold_wns"), "hold_tns_ns": entry.get("hold_tns"),
                "suggest_freq_mhz": entry.get("suggest_freq")}
    finally:
        shutil.rmtree(work, ignore_errors=True)


def load_registry(registry: Path) -> dict:
    if not registry or not Path(registry).exists():
        return {}
    return json.loads(Path(registry).read_text())


def resolve_case_context(args, registry: dict) -> tuple[Path, Path, Path]:
    """Resolve (case_root, foundry_dir, macro_lef) from args or registry.

    Priority: explicit CLI arg > registry entry > pdk-derived default.
    """
    design = args.design
    entry = registry.get(design, {}) if registry else {}

    case_root = Path(args.case_root) if args.case_root else (Path(entry["case_root"]) if entry.get("case_root") else None)
    if case_root is None or not case_root.is_dir():
        raise SystemExit(f"design {design!r}: case_root not provided and not in registry")

    if args.foundry_dir:
        foundry_dir = Path(args.foundry_dir)
    elif entry.get("foundry_dir"):
        foundry_dir = Path(entry["foundry_dir"])
    else:
        pdk = entry.get("pdk", "sky130")
        foundry_dir = REPO / "scripts/foundry" / pdk
    if not foundry_dir.is_dir():
        raise SystemExit(f"design {design!r}: foundry_dir {foundry_dir} does not exist")

    if args.macro_lef:
        macro_lef = Path(args.macro_lef)
    elif entry.get("lef"):
        macro_lef = Path(entry["lef"])
    else:
        macro_lef = resolve_lef(foundry_dir)
    if macro_lef is None or not macro_lef.exists():
        raise SystemExit(f"design {design!r}: macro LEF not found (explicit={args.macro_lef}, registry={entry.get('lef')})")

    return case_root, foundry_dir, macro_lef


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--design", required=True)
    ap.add_argument("--case-root")
    ap.add_argument("--macro-lef")
    ap.add_argument("--foundry-dir")  # optional: resolved from pdk/registry when absent
    ap.add_argument("--registry", help="path to designs.json for auto case/foundry/lef resolution")
    ap.add_argument("--grid-size", type=int, default=200)
    ap.add_argument("--bin-cnt", type=int, default=64, help="congestion evaluator bin count (density uses --grid-size)")
    ap.add_argument("--congestion-model", choices=["rudy", "lutrudy", "egr"], default="rudy")
    ap.add_argument("--no-timing", action="store_true")
    ap.add_argument("--out")
    ap.add_argument("defs", nargs="+")
    args = ap.parse_args()

    registry = load_registry(args.registry) if args.registry else {}
    case_root, foundry_dir, macro_lef = resolve_case_context(args, registry)

    defs = []
    for item in args.defs:
        name, path = item.split("=", 1)
        defs.append((name, Path(path)))

    out = {"design": args.design, "case_root": str(case_root),
           "foundry_dir": str(foundry_dir), "macro_lef": str(macro_lef),
           "congestion_model": args.congestion_model, "placements": {}}
    for name, path in defs:
        if not path.exists():
            out["placements"][name] = {"def": str(path), "missing": True}
            print(json.dumps({"design": args.design, "placement": name, "def": str(path), "missing": True},
                             indent=2), flush=True)
            continue
        # Legalization gate for iEDA CANDIDATES only (改造三). A raw-GP candidate
        # with overlapping cells yields artificially-low HPWL/EGR and would
        # pollute the ledger with a fake "win". The "raw" label is the Innovus
        # reference and is NOT gated (its row grid is foreign to the DEF ROWs).
        if name != "raw" and args.congestion_model == "egr":
            leg = check_legalized(path)
            if not leg["legalized"]:
                entry = {"def": str(path), "hpwl": hpwl(path, macro_lef),
                         "legalized": False,
                         "reason": leg.get("reason", "unlegalized DEF"),
                         "density": {"ok": False, "egr_valid": False, "legalized": False,
                                     "reason": "unlegalized candidate DEF; run LG+DP before scoring"}}
                out["placements"][name] = entry
                print(json.dumps({"design": args.design, "placement": name, **entry}, indent=2), flush=True)
                continue
        entry = {"def": str(path), "hpwl": hpwl(path, macro_lef),
                 "density": density(path, case_root, args.grid_size, foundry_dir,
                                    args.congestion_model, args.bin_cnt)}
        if not args.no_timing and TIMING_EVAL_TCL.exists():
            entry["timing"] = timing(path, case_root, foundry_dir)
        out["placements"][name] = entry
        print(json.dumps({"design": args.design, "placement": name, **entry}, indent=2), flush=True)
    if args.out:
        Path(args.out).write_text(json.dumps(out, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
