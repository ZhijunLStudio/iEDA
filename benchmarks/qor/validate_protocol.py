#!/usr/bin/env python3
"""Validate the frozen commercial-parity protocol without third-party packages."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path
from typing import Any


SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
REPORT_POINTS = ("post_place", "post_cts", "post_route", "signoff_sta")
BENCHMARK_TIERS = ("smoke", "daily", "weekly", "scale", "holdout")
REQUIRED_DELTAS = ("timing", "area", "wirelength", "power", "drc", "cts")
REQUIRED_MANIFEST_FIELDS = (
    "input_sha256",
    "binary_sha256",
    "build_manifest_sha256",
    "artifact_sha256",
)


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def validate_protocol(data: Any, protocol_path: Path) -> list[str]:
    errors: list[str] = []
    if not isinstance(data, dict):
        return ["root: expected object"]

    required = {
        "version",
        "protocol_id",
        "status",
        "primary_pnr_by_design",
        "implementation",
        "report_points",
        "metric_schema",
        "deltas",
        "performance",
        "manifest",
        "benchmark_sets",
        "signoff",
    }
    for key in sorted(required - data.keys()):
        errors.append(f"root: missing {key}")
    if data.get("status") != "frozen":
        errors.append("status: expected 'frozen'")
    if not isinstance(data.get("version"), str) or not data.get("version"):
        errors.append("version: expected non-empty string")
    if not isinstance(data.get("protocol_id"), str) or not data.get("protocol_id"):
        errors.append("protocol_id: expected non-empty string")
    report_points = data.get("report_points")
    if not isinstance(report_points, list) or tuple(report_points) != REPORT_POINTS:
        errors.append(f"report_points: expected {list(REPORT_POINTS)} in this order")

    implementation = data.get("implementation")
    if not isinstance(implementation, dict):
        errors.append("implementation: expected object")
    else:
        if implementation.get("ieda_effort") != "standard":
            errors.append("implementation.ieda_effort: expected 'standard'")
        if implementation.get("commercial_effort") != "standard":
            errors.append("implementation.commercial_effort: expected 'standard'")
        if not isinstance(implementation.get("fixed_seed"), int) or isinstance(
            implementation.get("fixed_seed"), bool
        ):
            errors.append("implementation.fixed_seed: expected integer")

    benchmark_sets = data.get("benchmark_sets")
    configured_designs: list[str] = []
    if not isinstance(benchmark_sets, dict):
        errors.append("benchmark_sets: expected object")
    else:
        for tier in BENCHMARK_TIERS:
            designs = benchmark_sets.get(tier)
            if not isinstance(designs, list) or any(not isinstance(item, str) or not item for item in designs):
                errors.append(f"benchmark_sets.{tier}: expected array of non-empty design names")
                continue
            if len(designs) != len(set(designs)):
                errors.append(f"benchmark_sets.{tier}: duplicate design")
            configured_designs.extend(designs)
        if isinstance(benchmark_sets.get("daily"), list) and len(benchmark_sets["daily"]) < 5:
            errors.append("benchmark_sets.daily: G1 requires at least five configurations")

    primary = data.get("primary_pnr_by_design")
    if not isinstance(primary, dict) or not primary:
        errors.append("primary_pnr_by_design: expected non-empty object")
    else:
        for design in sorted(set(configured_designs)):
            if design not in primary:
                errors.append(f"primary_pnr_by_design: missing {design}")
        for design, tool in primary.items():
            if tool not in {"innovus", "icc2"}:
                errors.append(f"primary_pnr_by_design.{design}: expected innovus or icc2")

    metric_schema = data.get("metric_schema")
    if not isinstance(metric_schema, dict):
        errors.append("metric_schema: expected object")
    else:
        schema_rel = metric_schema.get("path")
        expected_hash = metric_schema.get("sha256")
        if not isinstance(schema_rel, str) or not schema_rel:
            errors.append("metric_schema.path: expected non-empty string")
        elif Path(schema_rel).is_absolute():
            errors.append("metric_schema.path: expected path relative to protocol")
        else:
            schema_path = (protocol_path.parent / schema_rel).resolve()
            if not schema_path.is_file():
                errors.append(f"metric_schema.path: missing {schema_path}")
            elif not SHA256_RE.match(str(expected_hash or "")):
                errors.append("metric_schema.sha256: invalid SHA-256")
            elif sha256_file(schema_path) != expected_hash:
                errors.append("metric_schema.sha256: schema changed without a protocol version update")

    deltas = data.get("deltas")
    if not isinstance(deltas, dict):
        errors.append("deltas: expected object")
    else:
        for name in REQUIRED_DELTAS:
            item = deltas.get(name)
            if not isinstance(item, dict):
                errors.append(f"deltas.{name}: expected object")
                continue
            if item.get("direction") not in {"lower", "higher", "exact"}:
                errors.append(f"deltas.{name}.direction: invalid value")
            tolerance = item.get("relative_tolerance")
            if not isinstance(tolerance, (int, float)) or isinstance(tolerance, bool) or tolerance < 0:
                errors.append(f"deltas.{name}.relative_tolerance: expected non-negative number")

    performance = data.get("performance")
    if not isinstance(performance, dict):
        errors.append("performance: expected object")
    else:
        profile_schema = performance.get("profile_schema")
        if not isinstance(profile_schema, dict):
            errors.append("performance.profile_schema: expected object")
        else:
            schema_rel = profile_schema.get("path")
            expected_hash = profile_schema.get("sha256")
            if not isinstance(schema_rel, str) or not schema_rel:
                errors.append("performance.profile_schema.path: expected non-empty string")
            elif Path(schema_rel).is_absolute():
                errors.append("performance.profile_schema.path: expected path relative to protocol")
            else:
                schema_path = (protocol_path.parent / schema_rel).resolve()
                if not schema_path.is_file():
                    errors.append(f"performance.profile_schema.path: missing {schema_path}")
                elif not SHA256_RE.match(str(expected_hash or "")):
                    errors.append("performance.profile_schema.sha256: invalid SHA-256")
                elif sha256_file(schema_path) != expected_hash:
                    errors.append(
                        "performance.profile_schema.sha256: schema changed without a protocol version update"
                    )
        if not isinstance(performance.get("repeats"), int) or performance.get("repeats", 0) < 5:
            errors.append("performance.repeats: G21 requires at least five repeats")
        if performance.get("exclusive_host_required") is not True:
            errors.append("performance.exclusive_host_required: expected true")
        cache_modes = performance.get("cache_modes")
        if (
            not isinstance(cache_modes, list)
            or any(not isinstance(item, str) for item in cache_modes)
            or set(cache_modes) != {"cold", "warm"}
        ):
            errors.append("performance.cache_modes: expected cold and warm")
        required_stages = performance.get("required_stages")
        if (
            not isinstance(required_stages, list)
            or not required_stages
            or any(not isinstance(item, str) or not item for item in required_stages)
        ):
            errors.append("performance.required_stages: expected non-empty stage array")
        else:
            if len(required_stages) != len(set(required_stages)):
                errors.append("performance.required_stages: duplicate stage")
            if "e2e" not in required_stages:
                errors.append("performance.required_stages: missing e2e")
        threads = performance.get("threads")
        if not isinstance(threads, int) or isinstance(threads, bool) or threads < 1:
            errors.append("performance.threads: expected positive integer")
        noise_limit = performance.get("rerun_mad_ratio_max")
        if (
            not isinstance(noise_limit, (int, float))
            or isinstance(noise_limit, bool)
            or not 0 <= noise_limit < 1
        ):
            errors.append("performance.rerun_mad_ratio_max: expected number in [0, 1)")

    manifest = data.get("manifest")
    if not isinstance(manifest, dict):
        errors.append("manifest: expected object")
    else:
        required_fields = manifest.get("required_fields")
        if not isinstance(required_fields, list) or any(
            not isinstance(item, str) for item in required_fields
        ):
            errors.append("manifest.required_fields: expected array")
        else:
            missing = set(REQUIRED_MANIFEST_FIELDS) - set(required_fields)
            if missing:
                errors.append("manifest.required_fields: missing " + ", ".join(sorted(missing)))
        if manifest.get("hash_algorithm") != "sha256":
            errors.append("manifest.hash_algorithm: expected sha256")
        if manifest.get("dirty_build_policy") not in {"record", "reject"}:
            errors.append("manifest.dirty_build_policy: expected record or reject")

    signoff = data.get("signoff")
    expected_signoff = {"sta": "pt", "rcx": "starrc", "drc": "calibre", "power": "ptpx"}
    if not isinstance(signoff, dict):
        errors.append("signoff: expected object")
    else:
        for name, expected in expected_signoff.items():
            if signoff.get(name) != expected:
                errors.append(f"signoff.{name}: expected {expected}")
    return errors


def load_and_validate_protocol(path: Path) -> tuple[dict[str, Any], dict[str, Any]]:
    resolved = path.resolve()
    data = json.loads(resolved.read_text(encoding="utf-8"))
    errors = validate_protocol(data, resolved)
    if errors:
        raise ValueError("invalid parity protocol: " + "; ".join(errors))
    record = {
        "path": str(resolved),
        "sha256": sha256_file(resolved),
        "size_bytes": resolved.stat().st_size,
        "version": data["version"],
        "protocol_id": data["protocol_id"],
    }
    return data, record


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "protocol",
        type=Path,
        nargs="?",
        default=Path(__file__).with_name("parity_protocol.json"),
    )
    args = parser.parse_args()
    try:
        data = json.loads(args.protocol.read_text(encoding="utf-8"))
        errors = validate_protocol(data, args.protocol.resolve())
    except (OSError, json.JSONDecodeError) as exc:
        errors = [str(exc)]
    if errors:
        print(f"{args.protocol}: INVALID")
        for error in errors:
            print(f"  - {error}")
        return 1
    print(f"{args.protocol}: valid")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
