#!/usr/bin/env python3
"""EGR hotspot finder: trial-route a DEF and return the top-N overflow bins.

Parses iRT early_router outputs (gcell.info + overflow_map_planar.csv) and maps
each bin's (col,row) to physical DEF coordinates. This is the '试布线热点'
observation that drives region evacuation.

Usage:
  python3 benchmarks/flows/gp_egr_hotspots.py \\
    --case-root ... --foundry-dir ... --def placement.def --out-dir /tmp/hot \\
    --top-n 8
"""
from __future__ import annotations
import argparse, csv, json, os, shlex, subprocess, sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
IEDa_BIN = Path(os.environ.get("IEDA_BIN", REPO / "build/bin/iEDA"))
sys.path.insert(0, str(REPO / "benchmarks/flows"))
from gp_agent import _derive_pdk_env  # noqa: E402


def run_egr(case_root: Path, foundry: Path, def_path: Path, out_dir: Path) -> int:
    out_dir.mkdir(parents=True, exist_ok=True)
    tcl = out_dir / "egr_hotspots.tcl"
    tcl.write_text(
        f"flow_init -config {shlex.quote(str(case_root / 'iEDA_config/flow_config.json'))}\n"
        f"db_init -config {shlex.quote(str(case_root / 'iEDA_config/db_default_config.json'))} -output_dir_path {shlex.quote(str(out_dir))}\n"
        f"source {shlex.quote(str(case_root / 'script/DB_script/db_path_setting.tcl'))}\n"
        f"source {shlex.quote(str(case_root / 'script/DB_script/db_init_lib.tcl'))}\n"
        f"source {shlex.quote(str(case_root / 'script/DB_script/db_init_sdc.tcl'))}\n"
        f"source {shlex.quote(str(case_root / 'script/DB_script/db_init_lef.tcl'))}\n"
        f"def_init -path {shlex.quote(str(def_path))}\n"
        f"run_congestion_eval -model egr -eval_output_path {shlex.quote(str(out_dir))}\n"
        f"flow_exit\n")
    env = os.environ.copy()
    env.update({
        "CONFIG_DIR": str(case_root / "iEDA_config"), "RESULT_DIR": str(out_dir),
        "TCL_SCRIPT_DIR": str(case_root / "script"), "FOUNDRY_DIR": str(foundry),
        "SDC_FILE": str(next(case_root.glob("*.sdc"))),
    })
    env.update(_derive_pdk_env(foundry))
    p = subprocess.run([str(IEDa_BIN), "-script", str(tcl)], cwd=REPO, env=env,
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=1800)
    return p.returncode


def parse_gcell(gcell_path: Path) -> dict[tuple[int, int], tuple[int, int, int, int]]:
    """Map (col,row) -> (llx,lly,urx,ury). gcell.info line: x,y,llx,lly,urx,ury."""
    out = {}
    for line in gcell_path.read_text().splitlines():
        parts = [t for t in line.strip().split(",") if t != ""]
        if len(parts) < 6:
            continue
        x, y = int(parts[0]), int(parts[1])
        out[(x, y)] = (int(parts[2]), int(parts[3]), int(parts[4]), int(parts[5]))
    return out


def parse_overflow_map(csv_path: Path) -> list[list[float]]:
    """overflow_map_planar.csv: rows = y, columns = x."""
    grid = []
    for line in csv_path.read_text().splitlines():
        vals = [float(t) for t in line.split(",") if t.strip() != ""]
        if vals:
            grid.append(vals)
    return grid


def hotspots(case_root: Path, foundry: Path, def_path: Path, out_dir: Path, top_n: int) -> dict:
    rc = run_egr(case_root, foundry, def_path, out_dir)
    early = out_dir / "rt/rt_temp_directory/early_router"
    gcell = early / "gcell.info"
    # authoritative metric = the UNION overflow map (same one ieda_gp_verify
    # reports). overflow_map_planar.csv is the 2D projection and can diverge.
    ovf = out_dir / "egr_congestion_map/place_egr_union_overflow.csv"
    if not ovf.exists():
        ovf = early / "overflow_map_planar.csv"
    if rc != 0 or not gcell.exists() or not ovf.exists():
        return {"ok": False, "rc": rc, "gcell": gcell.exists(), "ovf": ovf.exists()}
    gmap = parse_gcell(gcell)
    grid = parse_overflow_map(ovf)
    bins = []
    for row, vals in enumerate(grid):
        for col, v in enumerate(vals):
            if v <= 0:
                continue
            region = gmap.get((col, row))
            if region is None:
                continue
            bins.append({"col": col, "row": row, "overflow": v,
                        "llx": region[0], "lly": region[1], "urx": region[2], "ury": region[3],
                        "region": f"{region[0]} {region[1]} {region[2]} {region[3]}"})
    bins.sort(key=lambda b: b["overflow"], reverse=True)
    top = bins[:top_n]
    total = sum(b["overflow"] for b in bins)
    # weighted-average overflow, identical formula to CongestionEval::evalAvgOverflow.
    # IMPORTANT: compute over the FULL grid (zeros included), not just non-zero bins,
    # so the percentage cutoffs match the C++ evaluator's 784-value denominator.
    all_vals = [v for row in grid for v in row]
    size = len(all_vals)
    idx_05 = max(1, (size * 5 + 999) // 1000)   # ceil(size*0.005)
    idx_1 = max(1, (size + 99) // 100)          # ceil(size*0.01)
    idx_2 = max(1, (size + 49) // 50)           # ceil(size*0.02)
    idx_5 = max(1, (size + 19) // 20)           # ceil(size*0.05)
    vals = sorted(all_vals, reverse=True)
    s05 = sum(vals[:idx_05])
    s1 = sum(vals[:idx_1])
    s2 = sum(vals[:idx_2])
    s5 = sum(vals[:idx_5])
    avg = (s05 * 0.4 + s1 * 0.3 + s2 * 0.2 + s5 * 0.1) / 4.0
    return {"ok": True, "def": str(def_path), "bin_total": len(bins),
            "overflow_sum": total, "max_overflow": top[0]["overflow"] if top else 0,
            "avg_overflow": avg, "top": top}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--case-root", required=True)
    ap.add_argument("--foundry-dir", required=True)
    ap.add_argument("--def", required=True, dest="def_path")
    ap.add_argument("--out-dir", required=True)
    ap.add_argument("--top-n", type=int, default=8)
    args = ap.parse_args()
    result = hotspots(Path(args.case_root), Path(args.foundry_dir), Path(args.def_path), Path(args.out_dir), args.top_n)
    print(json.dumps(result, indent=2))
    return 0 if result.get("ok") else 1


if __name__ == "__main__":
    raise SystemExit(main())
