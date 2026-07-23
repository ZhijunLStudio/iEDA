#!/usr/bin/env python3
"""Validate the required iEDA QoR contract without third-party packages."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


METRIC_KEYS = {"value", "unit", "source", "status", "reason", "confidence"}
METRIC_STATUSES = {"checked", "skipped", "unsupported", "refused"}
CONFIDENCES = {"high", "medium", "low", "none"}
GATE_STATUSES = {"pass", "fail", "not_run"}
SHA256_RE = re.compile(r"^[0-9a-f]{64}$")


def validate_summary(data: Any) -> list[str]:
    errors: list[str] = []
    required = {
        "schema_version", "design", "pdk", "strategy", "stage", "timestamp",
        "quality_gate", "overall_status", "manifest", "provenance", "metrics", "gates",
    }
    if not isinstance(data, dict):
        return ["root: expected object"]
    for key in sorted(required - data.keys()):
        errors.append(f"root: missing {key}")
    if data.get("schema_version") != "1.0":
        errors.append("schema_version: expected '1.0'")
    if data.get("stage") != "post_route":
        errors.append("stage: expected 'post_route'")
    if data.get("quality_gate") not in {"report", "strict"}:
        errors.append("quality_gate: expected report or strict")
    if data.get("overall_status") not in {"pass", "fail", "incomplete"}:
        errors.append("overall_status: invalid value")

    metrics = data.get("metrics")
    if not isinstance(metrics, dict) or not metrics:
        errors.append("metrics: expected non-empty object")
    else:
        for name, item in metrics.items():
            if not isinstance(item, dict):
                errors.append(f"metrics.{name}: expected object")
                continue
            missing = METRIC_KEYS - item.keys()
            if missing:
                errors.append(f"metrics.{name}: missing {', '.join(sorted(missing))}")
            if item.get("status") not in METRIC_STATUSES:
                errors.append(f"metrics.{name}.status: invalid value")
            if item.get("confidence") not in CONFIDENCES:
                errors.append(f"metrics.{name}.confidence: invalid value")
            if not isinstance(item.get("unit"), str) or not isinstance(item.get("source"), str):
                errors.append(f"metrics.{name}: unit/source must be strings")

    gates = data.get("gates")
    if not isinstance(gates, dict) or not gates:
        errors.append("gates: expected non-empty object")
    else:
        for name, item in gates.items():
            if not isinstance(item, dict):
                errors.append(f"gates.{name}: expected object")
                continue
            if item.get("status") not in GATE_STATUSES:
                errors.append(f"gates.{name}.status: invalid value")
            if not isinstance(item.get("evidence"), list):
                errors.append(f"gates.{name}.evidence: expected array")

    manifest = data.get("manifest", {})
    for group in ("inputs", "artifacts"):
        records = manifest.get(group) if isinstance(manifest, dict) else None
        if not isinstance(records, list):
            errors.append(f"manifest.{group}: expected array")
            continue
        for index, record in enumerate(records):
            prefix = f"manifest.{group}[{index}]"
            if not isinstance(record, dict):
                errors.append(f"{prefix}: expected object")
                continue
            if not SHA256_RE.match(str(record.get("sha256", ""))):
                errors.append(f"{prefix}.sha256: invalid SHA-256")
            if not isinstance(record.get("size_bytes"), int) or record.get("size_bytes", -1) < 0:
                errors.append(f"{prefix}.size_bytes: expected non-negative integer")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("summary", type=Path, nargs="+")
    args = parser.parse_args()
    failed = False
    for path in args.summary:
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
            errors = validate_summary(data)
        except (OSError, json.JSONDecodeError) as exc:
            errors = [str(exc)]
        if errors:
            failed = True
            print(f"{path}: INVALID")
            for error in errors:
                print(f"  - {error}")
        else:
            print(f"{path}: valid")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
