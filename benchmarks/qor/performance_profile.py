#!/usr/bin/env python3
"""Validate and compare controlled iEDA/commercial performance profiles."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import re
import statistics
import sys
from collections import defaultdict
from pathlib import Path
from typing import Any, Iterable

REPO_ROOT = Path(__file__).resolve().parents[2]
if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))

from benchmarks.qor.validate_protocol import load_and_validate_protocol


SCHEMA_VERSION = "1.0"
SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
TOOL_ROLES = {"ieda", "commercial"}
CACHE_MODES = {"cold", "warm"}
REQUIRED_FIELDS = {
    "schema_version", "tool_role", "tool", "design", "stage", "run_id",
    "repeat", "cache_mode", "wall_sec", "user_cpu_sec", "system_cpu_sec",
    "threads", "hostname", "binary_sha256", "build_manifest_sha256",
    "hardware_manifest_sha256", "input_manifest_sha256", "exclusive_host",
    "status", "comparable",
}
OPTIONAL_FIELDS = {"process_peak_bytes", "timestamp", "non_comparable_reason"}


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _is_number(value: Any) -> bool:
    return isinstance(value, (int, float)) and not isinstance(value, bool)


def validate_record(record: Any, prefix: str = "record") -> list[str]:
    if not isinstance(record, dict):
        return [f"{prefix}: expected object"]
    errors: list[str] = []
    for key in sorted(REQUIRED_FIELDS - record.keys()):
        errors.append(f"{prefix}: missing {key}")
    for key in sorted(record.keys() - REQUIRED_FIELDS - OPTIONAL_FIELDS):
        errors.append(f"{prefix}: unexpected {key}")
    if record.get("schema_version") != SCHEMA_VERSION:
        errors.append(f"{prefix}.schema_version: expected '{SCHEMA_VERSION}'")
    if record.get("tool_role") not in TOOL_ROLES:
        errors.append(f"{prefix}.tool_role: expected ieda or commercial")
    for key in ("tool", "design", "stage", "run_id", "hostname"):
        if not isinstance(record.get(key), str) or not record.get(key):
            errors.append(f"{prefix}.{key}: expected non-empty string")
    repeat = record.get("repeat")
    if not isinstance(repeat, int) or isinstance(repeat, bool) or repeat < 1:
        errors.append(f"{prefix}.repeat: expected positive integer")
    if record.get("cache_mode") not in CACHE_MODES:
        errors.append(f"{prefix}.cache_mode: expected cold or warm")
    for key in ("wall_sec", "user_cpu_sec", "system_cpu_sec"):
        value = record.get(key)
        invalid = (
            not _is_number(value)
            or not math.isfinite(float(value))
            or value < 0
            or (key == "wall_sec" and value == 0)
        )
        if invalid:
            qualifier = "positive" if key == "wall_sec" else "non-negative"
            errors.append(f"{prefix}.{key}: expected {qualifier} number")
    peak = record.get("process_peak_bytes")
    if peak is not None and (
        not isinstance(peak, int) or isinstance(peak, bool) or peak < 0
    ):
        errors.append(f"{prefix}.process_peak_bytes: expected non-negative integer")
    threads = record.get("threads")
    if not isinstance(threads, int) or isinstance(threads, bool) or threads < 1:
        errors.append(f"{prefix}.threads: expected positive integer")
    for key in (
        "binary_sha256",
        "build_manifest_sha256",
        "hardware_manifest_sha256",
        "input_manifest_sha256",
    ):
        if not SHA256_RE.match(str(record.get(key, ""))):
            errors.append(f"{prefix}.{key}: invalid SHA-256")
    if not isinstance(record.get("exclusive_host"), bool):
        errors.append(f"{prefix}.exclusive_host: expected boolean")
    if record.get("status") not in {"success", "failed"}:
        errors.append(f"{prefix}.status: expected success or failed")
    if not isinstance(record.get("comparable"), bool):
        errors.append(f"{prefix}.comparable: expected boolean")
    if record.get("comparable") is False and (
        not isinstance(record.get("non_comparable_reason"), str)
        or not record.get("non_comparable_reason")
    ):
        errors.append(f"{prefix}.non_comparable_reason: required when comparable is false")
    return errors


def load_jsonl(path: Path) -> tuple[list[dict[str, Any]], list[str]]:
    records: list[dict[str, Any]] = []
    errors: list[str] = []
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except OSError as exc:
        return [], [f"{path}: {exc}"]
    for line_number, line in enumerate(lines, 1):
        if not line.strip():
            continue
        try:
            record = json.loads(line)
        except json.JSONDecodeError as exc:
            errors.append(f"{path}:{line_number}: invalid JSON: {exc.msg}")
            continue
        record_errors = validate_record(record, f"{path}:{line_number}")
        errors.extend(record_errors)
        if not record_errors:
            records.append(record)
    if not records and not errors:
        errors.append(f"{path}: profile is empty")
    return records, errors


def robust_stats(values: Iterable[float]) -> dict[str, float | int]:
    samples = list(values)
    median = statistics.median(samples)
    mad = statistics.median(abs(value - median) for value in samples)
    return {
        "samples": len(samples),
        "median_sec": median,
        "mad_sec": mad,
        "mad_ratio": mad / median if median else 0.0,
        "min_sec": min(samples),
        "max_sec": max(samples),
    }


def _role_groups(
    records: list[dict[str, Any]], role: str, cache_mode: str
) -> dict[tuple[str, str], list[dict[str, Any]]]:
    groups: dict[tuple[str, str], list[dict[str, Any]]] = defaultdict(list)
    for record in records:
        if record["tool_role"] == role and record["cache_mode"] == cache_mode:
            groups[(record["design"], record["stage"])].append(record)
    return groups


def compare_profiles(
    ieda_records: list[dict[str, Any]],
    commercial_records: list[dict[str, Any]],
    protocol: dict[str, Any],
    *,
    cache_mode: str,
) -> dict[str, Any]:
    performance = protocol["performance"]
    repeats = performance["repeats"]
    expected_threads = performance["threads"]
    noise_max = performance["rerun_mad_ratio_max"]
    daily = protocol["benchmark_sets"]["daily"]
    required_stages = performance["required_stages"]
    errors: list[str] = []
    validated: dict[str, list[dict[str, Any]]] = {"ieda": [], "commercial": []}
    for label, records in (("ieda", ieda_records), ("commercial", commercial_records)):
        for index, record in enumerate(records):
            record_errors = validate_record(record, f"{label}[{index}]")
            errors.extend(record_errors)
            if not record_errors:
                validated[label].append(record)
    ieda_records = validated["ieda"]
    commercial_records = validated["commercial"]
    if cache_mode not in performance["cache_modes"]:
        errors.append(f"cache_mode: {cache_mode} is not enabled by the protocol")
    for label, records, expected_role in (
        ("ieda", ieda_records, "ieda"),
        ("commercial", commercial_records, "commercial"),
    ):
        wrong_roles = sorted(
            {
                record.get("tool_role")
                for record in records
                if record.get("tool_role") != expected_role
            }
        )
        if wrong_roles:
            errors.append(f"{label}: contains unexpected tool roles {wrong_roles}")

    ieda_groups = _role_groups(ieda_records, "ieda", cache_mode)
    commercial_groups = _role_groups(commercial_records, "commercial", cache_mode)
    measurements: list[dict[str, Any]] = []
    keys = sorted(set(ieda_groups) | set(commercial_groups))
    for design, stage in keys:
        role_stats: dict[str, dict[str, Any]] = {}
        comparable = True
        for role, groups in (("ieda", ieda_groups), ("commercial", commercial_groups)):
            group = groups.get((design, stage), [])
            repeats_seen = [record["repeat"] for record in group]
            reasons = []
            if len(set(repeats_seen)) != len(repeats_seen):
                reasons.append("duplicate repeat identifiers")
            if len(group) < repeats:
                reasons.append(f"requires at least {repeats} repeats, found {len(group)}")
            if any(record["status"] != "success" for record in group):
                reasons.append("contains failed runs")
            if any(not record["comparable"] for record in group):
                reasons.append("contains records marked non-comparable")
            if any(record["threads"] != expected_threads for record in group):
                reasons.append(f"threads differ from protocol value {expected_threads}")
            if performance["exclusive_host_required"] and any(
                not record["exclusive_host"] for record in group
            ):
                reasons.append("exclusive-host evidence is missing")
            if len({record["binary_sha256"] for record in group}) > 1:
                reasons.append("binary identity changed across repeats")
            if len({record["build_manifest_sha256"] for record in group}) > 1:
                reasons.append("build manifest changed across repeats")
            stats = robust_stats(record["wall_sec"] for record in group) if group else None
            if stats and stats["mad_ratio"] > noise_max:
                reasons.append(
                    f"normalized MAD {stats['mad_ratio']:.6f} exceeds {noise_max:.6f}"
                )
            if reasons:
                comparable = False
                errors.extend(f"{design}/{stage}/{role}: {reason}" for reason in reasons)
            role_stats[role] = {"statistics": stats, "reasons": reasons}

        both = ieda_groups.get((design, stage), []) + commercial_groups.get((design, stage), [])
        hosts = {record["hostname"] for record in both}
        hardware_hashes = {record["hardware_manifest_sha256"] for record in both}
        input_hashes = {record["input_manifest_sha256"] for record in both}
        if len(hosts) != 1:
            comparable = False
            errors.append(f"{design}/{stage}: profiles were not collected on one host")
        if len(input_hashes) != 1:
            comparable = False
            errors.append(f"{design}/{stage}: input manifests do not match")
        if len(hardware_hashes) != 1:
            comparable = False
            errors.append(f"{design}/{stage}: hardware manifests do not match")
        ieda_stats = role_stats["ieda"]["statistics"]
        commercial_stats = role_stats["commercial"]["statistics"]
        ratio = (
            ieda_stats["median_sec"] / commercial_stats["median_sec"]
            if comparable and ieda_stats and commercial_stats
            else None
        )
        measurements.append(
            {
                "design": design,
                "stage": stage,
                "cache_mode": cache_mode,
                "comparable": comparable,
                "ieda": role_stats["ieda"],
                "commercial": role_stats["commercial"],
                "median_ratio": ratio,
            }
        )

    e2e = {row["design"]: row for row in measurements if row["stage"] == "e2e"}
    measurement_index = {(row["design"], row["stage"]): row for row in measurements}
    missing_required = [
        f"{design}/{stage}"
        for design in daily
        for stage in required_stages
        if (design, stage) not in measurement_index
    ]
    incomplete_required = [
        f"{design}/{stage}"
        for design in daily
        for stage in required_stages
        if (design, stage) in measurement_index
        and not measurement_index[(design, stage)]["comparable"]
    ]
    missing_daily = [design for design in daily if design not in e2e]
    incomplete_daily = [
        design for design in daily if design in e2e and not e2e[design]["comparable"]
    ]
    ratios = {
        design: e2e[design]["median_ratio"]
        for design in daily
        if design in e2e and e2e[design]["median_ratio"] is not None
    }
    ratio_failures = {
        design: ratio
        for design, ratio in ratios.items()
        if ratio > performance["daily_e2e_ratio_max"]
    }
    le_one_count = sum(ratio <= 1.0 for ratio in ratios.values())
    if errors or missing_daily or incomplete_daily or missing_required or incomplete_required:
        status = "incomplete"
    elif ratio_failures or le_one_count < performance["daily_le_one_count_min"]:
        status = "fail"
    else:
        status = "pass"
    return {
        "schema_version": "1.0",
        "cache_mode": cache_mode,
        "protocol_id": protocol["protocol_id"],
        "measurement_count": len(measurements),
        "measurements": measurements,
        "comparability_errors": sorted(set(errors)),
        "g21": {
            "enabled": performance["g21_enable"],
            "status": status,
            "daily_designs": daily,
            "missing_daily_designs": missing_daily,
            "incomplete_daily_designs": incomplete_daily,
            "missing_required_measurements": missing_required,
            "incomplete_required_measurements": incomplete_required,
            "e2e_median_ratios": ratios,
            "ratio_failures": ratio_failures,
            "le_one_count": le_one_count,
            "required_le_one_count": performance["daily_le_one_count_min"],
            "e2e_ratio_max": performance["daily_e2e_ratio_max"],
        },
    }


def comparison_exit_code(comparison: dict[str, Any]) -> int:
    if comparison["g21"]["status"] == "incomplete":
        return 1
    if comparison["g21"]["enabled"] and comparison["g21"]["status"] != "pass":
        return 1
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ieda", type=Path, required=True, help="iEDA profile JSONL")
    parser.add_argument("--commercial", type=Path, required=True, help="commercial profile JSONL")
    parser.add_argument("--protocol", type=Path, default=Path(__file__).with_name("parity_protocol.json"))
    parser.add_argument("--cache-mode", choices=sorted(CACHE_MODES), required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    protocol, protocol_record = load_and_validate_protocol(args.protocol)
    ieda, errors = load_jsonl(args.ieda)
    commercial, commercial_errors = load_jsonl(args.commercial)
    errors.extend(commercial_errors)
    if errors:
        for error in errors:
            print(error)
        return 1
    comparison = compare_profiles(ieda, commercial, protocol, cache_mode=args.cache_mode)
    comparison["manifest"] = {
        "protocol": protocol_record,
        "ieda_profile": {"path": str(args.ieda.resolve()), "sha256": sha256_file(args.ieda)},
        "commercial_profile": {
            "path": str(args.commercial.resolve()),
            "sha256": sha256_file(args.commercial),
        },
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(comparison, indent=2) + "\n", encoding="utf-8")
    print(args.output)
    return comparison_exit_code(comparison)


if __name__ == "__main__":
    raise SystemExit(main())
