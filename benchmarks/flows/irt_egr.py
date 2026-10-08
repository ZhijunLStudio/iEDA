#!/usr/bin/env python3
"""Routing-domain (iRT) authoritative EGR runner - domain-independent of placement.

This is the routing-domain CLI primitive. It reuses the domain-agnostic
gp_metrics_compare.density/check_legalized evaluators but does NOT import any
placement-domain code. Future iRT capabilities (DRC etc.) attach to this same
runner contract (see runner_contract.json).

Usage:
  python3 benchmarks/flows/irt_egr.py \
      --workdir <dir> --case-root <case> --foundry-dir <foundry> [--def-path <def>]
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO_ROOT / "benchmarks/flows"))

from gp_metrics_compare import density, check_legalized  # noqa: E402  (domain-agnostic evaluator)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--workdir", required=True)
    ap.add_argument("--case-root", required=True)
    ap.add_argument("--foundry-dir", required=True)
    ap.add_argument("--def-path", default="")
    args = ap.parse_args()

    workdir = Path(args.workdir)
    case_root = Path(args.case_root)
    foundry = Path(args.foundry_dir)
    def_path = Path(args.def_path) if args.def_path else workdir / "placement.def"

    if not case_root.exists() or not foundry.exists():
        print(json.dumps({"ok": False, "reason": "irt_egr: missing case_root/foundry_dir"}))
        return 1

    # legalization gate: overlapping cells fake a low EGR
    leg = check_legalized(def_path)
    if not leg["legalized"]:
        print(json.dumps({"ok": False, "legalized": False, "reason": leg.get("reason"),
                          "def": str(def_path), "sample": leg.get("sample", [])}, indent=2))
        return 1

    d = density(def_path, case_root, 200, foundry, "egr", 64)
    out = {"ok": bool(d.get("ok")), "legalized": True, "def": str(def_path),
           "egr_valid": bool(d.get("egr_valid"))}
    for k in ("egr_total_overflow_horizontal", "egr_total_overflow_vertical", "egr_total_overflow_union",
              "egr_max_overflow_horizontal", "egr_max_overflow_vertical", "egr_max_overflow_union",
              "egr_avg_overflow_horizontal", "egr_avg_overflow_vertical", "egr_avg_overflow_union"):
        if d.get(k) is not None:
            out[k] = d[k]
    if not out["ok"]:
        out["reason"] = d.get("reason") or d.get("congestion_reason")
    print(json.dumps(out, indent=2))
    return 0 if out["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
