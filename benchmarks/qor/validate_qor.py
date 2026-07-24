#!/usr/bin/env python3
"""Validate the required iEDA QoR contract without third-party packages."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path
from typing import Any


METRIC_KEYS = {"value", "unit", "source", "status", "reason", "confidence"}
METRIC_STATUSES = {"checked", "skipped", "unsupported", "refused"}
CONFIDENCES = {"high", "medium", "low", "none"}
GATE_STATUSES = {"pass", "fail", "not_run"}
SHA256_RE = re.compile(r"^[0-9a-f]{64}$")


def canonical_sha256(value: Any) -> str:
    encoded = json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=True).encode("ascii")
    return hashlib.sha256(encoded).hexdigest()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def validate_file_record(
    record: Any,
    prefix: str,
    errors: list[str],
    *,
    verify_files: bool,
) -> None:
    if not isinstance(record, dict):
        errors.append(f"{prefix}: expected object")
        return
    if not SHA256_RE.match(str(record.get("sha256", ""))):
        errors.append(f"{prefix}.sha256: invalid SHA-256")
    if not isinstance(record.get("size_bytes"), int) or record.get("size_bytes", -1) < 0:
        errors.append(f"{prefix}.size_bytes: expected non-negative integer")
    if not isinstance(record.get("path"), str) or not record.get("path"):
        errors.append(f"{prefix}.path: expected non-empty string")
        return
    if not verify_files:
        return
    path = Path(record["path"])
    if not path.is_file():
        errors.append(f"{prefix}: stale, file is missing: {path}")
        return
    if path.stat().st_size != record.get("size_bytes"):
        errors.append(f"{prefix}: stale, size changed: {path}")
    elif SHA256_RE.match(str(record.get("sha256", ""))) and sha256_file(path) != record["sha256"]:
        errors.append(f"{prefix}: stale, SHA-256 changed: {path}")


def validate_summary(data: Any, *, verify_files: bool = False) -> list[str]:
    errors: list[str] = []
    required = {
        "schema_version", "design", "pdk", "strategy", "stage", "timestamp",
        "quality_gate", "overall_status", "manifest", "provenance", "metrics", "gates",
    }
    if not isinstance(data, dict):
        return ["root: expected object"]
    for key in sorted(required - data.keys()):
        errors.append(f"root: missing {key}")
    if data.get("schema_version") != "1.1":
        errors.append("schema_version: expected '1.1'")
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
            validate_file_record(record, prefix, errors, verify_files=verify_files)
    if isinstance(manifest, dict):
        for records_name, digest_name in (("inputs", "input_sha256"), ("artifacts", "artifact_sha256")):
            records = manifest.get(records_name)
            digest = manifest.get(digest_name)
            if not SHA256_RE.match(str(digest or "")):
                errors.append(f"manifest.{digest_name}: invalid SHA-256")
            elif isinstance(records, list) and digest != canonical_sha256(records):
                errors.append(f"manifest.{digest_name}: does not match {records_name}")
        build = manifest.get("build")
        if not isinstance(build, dict):
            errors.append("manifest.build: expected object")
        else:
            binary = build.get("binary")
            if binary is not None:
                validate_file_record(
                    binary,
                    "manifest.build.binary",
                    errors,
                    verify_files=verify_files,
                )
            build_digest = build.get("manifest_sha256")
            build_payload = {key: value for key, value in build.items() if key != "manifest_sha256"}
            if not SHA256_RE.match(str(build_digest or "")):
                errors.append("manifest.build.manifest_sha256: invalid SHA-256")
            elif build_digest != canonical_sha256(build_payload):
                errors.append("manifest.build.manifest_sha256: does not match build identity")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("summary", type=Path, nargs="+")
    parser.add_argument(
        "--no-freshness-check",
        action="store_true",
        help="Validate archived JSON structure without re-hashing referenced files",
    )
    args = parser.parse_args()
    failed = False
    for path in args.summary:
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
            errors = validate_summary(data, verify_files=not args.no_freshness_check)
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
