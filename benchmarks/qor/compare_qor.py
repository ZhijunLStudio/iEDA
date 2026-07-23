#!/usr/bin/env python3
"""Compare two QoR summaries metric-by-metric without a weighted score."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parents[2]
if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))

from benchmarks.qor.validate_qor import validate_summary


HIGHER_IS_BETTER = {
    "timing.setup_wns_ns",
    "timing.hold_wns_ns",
}
LOWER_PREFIXES = (
    "power.",
    "wirelength.",
    "congestion.",
    "drc.",
    "ir_drop.",
    "routing.runtime_sec",
)


def direction(name: str) -> str:
    if name in HIGHER_IS_BETTER:
        return "higher"
    if name.startswith(LOWER_PREFIXES):
        return "lower"
    return "diagnostic"


def compare(baseline: dict[str, Any], candidate: dict[str, Any]) -> dict[str, Any]:
    rows = []
    names = sorted(set(baseline["metrics"]) | set(candidate["metrics"]))
    for name in names:
        base_metric = baseline["metrics"].get(name)
        cand_metric = candidate["metrics"].get(name)
        base_value = base_metric.get("value") if base_metric else None
        cand_value = cand_metric.get("value") if cand_metric else None
        metric_direction = direction(name)
        absolute_delta = None
        relative_delta = None
        verdict = "not_comparable"
        if (
            isinstance(base_value, (int, float))
            and not isinstance(base_value, bool)
            and isinstance(cand_value, (int, float))
            and not isinstance(cand_value, bool)
        ):
            absolute_delta = cand_value - base_value
            if base_value != 0:
                relative_delta = absolute_delta / abs(base_value)
            if metric_direction == "higher":
                verdict = "improved" if absolute_delta > 0 else ("regressed" if absolute_delta < 0 else "unchanged")
            elif metric_direction == "lower":
                verdict = "improved" if absolute_delta < 0 else ("regressed" if absolute_delta > 0 else "unchanged")
            else:
                verdict = "changed" if absolute_delta != 0 else "unchanged"
        rows.append(
            {
                "metric": name,
                "unit": (cand_metric or base_metric or {}).get("unit"),
                "direction": metric_direction,
                "baseline": base_value,
                "candidate": cand_value,
                "absolute_delta": absolute_delta,
                "relative_delta": relative_delta,
                "verdict": verdict,
                "baseline_status": base_metric.get("status") if base_metric else "missing",
                "candidate_status": cand_metric.get("status") if cand_metric else "missing",
            }
        )

    gate_rows = []
    gate_names = sorted(set(baseline["gates"]) | set(candidate["gates"]))
    rank = {"not_run": 0, "fail": 1, "pass": 2}
    for name in gate_names:
        base_status = baseline["gates"].get(name, {}).get("status", "not_run")
        cand_status = candidate["gates"].get(name, {}).get("status", "not_run")
        gate_rows.append(
            {
                "gate": name,
                "baseline": base_status,
                "candidate": cand_status,
                "verdict": "improved" if rank[cand_status] > rank[base_status] else (
                    "regressed" if rank[cand_status] < rank[base_status] else "unchanged"
                ),
            }
        )
    return {
        "design": candidate["design"],
        "pdk": candidate["pdk"],
        "baseline_manifest": baseline["manifest"]["build"],
        "candidate_manifest": candidate["manifest"]["build"],
        "metrics": rows,
        "gates": gate_rows,
        "summary": {
            "metric_improvements": sum(row["verdict"] == "improved" for row in rows),
            "metric_regressions": sum(row["verdict"] == "regressed" for row in rows),
            "gate_improvements": sum(row["verdict"] == "improved" for row in gate_rows),
            "gate_regressions": sum(row["verdict"] == "regressed" for row in gate_rows),
            "weighted_score": None,
            "decision_rule": "hard gates and each metric are reported independently",
        },
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    baseline = json.loads(args.baseline.read_text(encoding="utf-8"))
    candidate = json.loads(args.candidate.read_text(encoding="utf-8"))
    errors = validate_summary(baseline) + validate_summary(candidate)
    if errors:
        raise ValueError("invalid QoR summary: " + "; ".join(errors))
    if (baseline["design"], baseline["pdk"]) != (candidate["design"], candidate["pdk"]):
        raise ValueError("QoR comparison requires the same design and PDK")
    result = compare(baseline, candidate)
    output = args.output or args.candidate.with_name("qor_comparison.json")
    output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(output)
    return 1 if result["summary"]["gate_regressions"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
