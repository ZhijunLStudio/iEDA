#!/usr/bin/env python3
"""Run and compare the required 1/3/5 detailed-routing iteration sweep."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Any


REPO_ROOT = Path(__file__).resolve().parents[2]
FLOW = Path(__file__).with_name("aes13_flow.py")
DEFAULT_OUTPUT = REPO_ROOT / "benchmarks/results/aes13_route_sweep"


def metric_value(summary: dict[str, Any], name: str) -> Any:
    return summary.get("metrics", {}).get(name, {}).get("value")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--design", action="append", required=True)
    parser.add_argument("--iterations", nargs="+", type=int, default=[1, 3, 5])
    parser.add_argument("--output-root", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--no-synthesis", action="store_true")
    parser.add_argument("--resume", action="store_true")
    parser.add_argument("--timeout", type=int, default=7200)
    parser.add_argument("--jobs", type=int, default=1)
    parser.add_argument("--quality-gate", choices=("report", "strict"), default="report")
    parser.add_argument("--spef")
    parser.add_argument("--rcx-config")
    parser.add_argument("--rcx-corner")
    parser.add_argument("--vcd")
    parser.add_argument("--vcd-top")
    parser.add_argument("--ir-report")
    parser.add_argument("--constraint-policy", choices=("complete", "existing"), default="complete")
    parser.add_argument("--io-delay-pct", type=float, default=0.20)
    parser.add_argument("--clock-uncertainty-pct", type=float, default=0.05)
    parser.add_argument("--output-load", type=float, default=0.01)
    parser.add_argument("--driving-cell")
    parser.add_argument("--driving-pin", default="Y")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    iterations = tuple(dict.fromkeys(args.iterations))
    if any(value < 1 for value in iterations):
        raise ValueError("all --iterations values must be at least 1")
    root = args.output_root.expanduser().resolve()
    root.mkdir(parents=True, exist_ok=True)
    failures = []
    rows = []

    for iteration in iterations:
        iteration_root = root / f"iter_{iteration}"
        command = [
            sys.executable,
            str(FLOW),
            "--rt-max-iterations",
            str(iteration),
            "--output-root",
            str(iteration_root),
            "--timeout",
            str(args.timeout),
            "--jobs",
            str(args.jobs),
            "--quality-gate",
            args.quality_gate,
            "--constraint-policy",
            args.constraint_policy,
            "--io-delay-pct",
            str(args.io_delay_pct),
            "--clock-uncertainty-pct",
            str(args.clock_uncertainty_pct),
            "--output-load",
            str(args.output_load),
            "--driving-pin",
            args.driving_pin,
        ]
        for design in args.design:
            command.extend(("--design", design))
        if args.no_synthesis:
            command.append("--no-synthesis")
        if args.resume:
            command.append("--resume")
        for option, value in (
            ("--spef", args.spef),
            ("--rcx-config", args.rcx_config),
            ("--rcx-corner", args.rcx_corner),
            ("--vcd", args.vcd),
            ("--vcd-top", args.vcd_top),
            ("--ir-report", args.ir_report),
            ("--driving-cell", args.driving_cell),
        ):
            if value:
                command.extend((option, value))
        print(f"[route-sweep] iterations={iteration}", flush=True)
        result = subprocess.run(command, cwd=REPO_ROOT, check=False)
        if result.returncode != 0:
            failures.append({"iterations": iteration, "returncode": result.returncode})

        for design in args.design:
            path = iteration_root / design / "quality_summary.json"
            if not path.is_file():
                rows.append({"design": design, "iterations": iteration, "status": "missing"})
                continue
            summary = json.loads(path.read_text(encoding="utf-8"))
            rows.append(
                {
                    "design": design,
                    "iterations": iteration,
                    "status": summary["overall_status"],
                    "drc_total": metric_value(summary, "drc.total"),
                    "route_runtime_sec": metric_value(summary, "routing.runtime_sec"),
                    "egr_wirelength_um": metric_value(summary, "wirelength.egr_um"),
                    "union_total_overflow": metric_value(summary, "congestion.union.total"),
                    "quality_summary": str(path),
                }
            )

    analyses = {}
    for design in args.design:
        design_rows = sorted((row for row in rows if row["design"] == design), key=lambda row: row["iterations"])
        drc_values = [row.get("drc_total") for row in design_rows]
        comparable = len(design_rows) == len(iterations) and all(isinstance(value, (int, float)) for value in drc_values)
        monotonic = comparable and all(left >= right for left, right in zip(drc_values, drc_values[1:]))
        eligible = [row for row in design_rows if isinstance(row.get("drc_total"), (int, float))]
        recommended = min(
            eligible,
            key=lambda row: (
                row["drc_total"],
                row.get("route_runtime_sec") if isinstance(row.get("route_runtime_sec"), (int, float)) else float("inf"),
            ),
            default=None,
        )
        analyses[design] = {
            "drc_monotonic_non_increasing": monotonic,
            "comparable": comparable,
            "recommended_iterations": recommended["iterations"] if recommended else None,
            "reason": "minimum DRC, then minimum runtime" if recommended else "no complete DRC evidence",
        }

    output = {
        "timestamp": datetime.now().astimezone().isoformat(),
        "iterations": list(iterations),
        "rows": rows,
        "analysis": analyses,
        "failures": failures,
    }
    json_path = root / "route_iteration_sweep.json"
    json_path.write_text(json.dumps(output, indent=2) + "\n", encoding="utf-8")
    lines = [
        "# Detailed-routing iteration sweep",
        "",
        "| Design | Iterations | QoR | DRC | Route runtime (s) | EGR WL (um) | Union overflow |",
        "|---|---:|---|---:|---:|---:|---:|",
    ]
    for row in rows:
        lines.append(
            f"| {row['design']} | {row['iterations']} | {row['status']} | "
            f"{row.get('drc_total', 'N/A')} | {row.get('route_runtime_sec', 'N/A')} | "
            f"{row.get('egr_wirelength_um', 'N/A')} | {row.get('union_total_overflow', 'N/A')} |"
        )
    lines.extend(("", "## Decision", ""))
    for design, analysis in analyses.items():
        lines.append(
            f"- {design}: monotonic DRC={analysis['drc_monotonic_non_increasing']}; "
            f"recommended iterations={analysis['recommended_iterations']} ({analysis['reason']})."
        )
    (root / "route_iteration_sweep.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json_path)
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
