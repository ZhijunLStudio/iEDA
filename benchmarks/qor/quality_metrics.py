#!/usr/bin/env python3
"""Collect post-route QoR with explicit evidence and failure semantics."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import math
import re
import subprocess
from datetime import datetime
from pathlib import Path
from typing import Any, Iterable


SCHEMA_VERSION = "1.1"
STRICT_GATES = (
    "G7_spef_backed_sta",
    "G7_constraint_coverage",
    "G9_activity_backed_power",
    "G5_congestion_summary",
    "G11_drc_clean",
    "G10_ir_drop",
    "GDS_signoff",
)


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def canonical_sha256(value: Any) -> str:
    encoded = json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=True).encode("ascii")
    return hashlib.sha256(encoded).hexdigest()


def file_record(path: Path) -> dict[str, Any]:
    resolved = path.resolve()
    return {
        "path": str(resolved),
        "sha256": sha256_file(resolved),
        "size_bytes": resolved.stat().st_size,
    }


def read_text(path: Path) -> str:
    if not path.is_file():
        return ""
    return path.read_text(encoding="utf-8", errors="replace")


def first_float(pattern: str, text: str) -> float | None:
    match = re.search(pattern, text, re.MULTILINE | re.IGNORECASE)
    return float(match.group(1)) if match else None


def metric(
    value: Any,
    unit: str,
    source: str,
    *,
    status: str = "checked",
    reason: str | None = None,
    confidence: str = "high",
) -> dict[str, Any]:
    if value is None and status == "checked":
        status = "refused"
        confidence = "none"
        reason = reason or "source exists but the metric was not parseable"
    return {
        "value": value,
        "unit": unit,
        "source": source,
        "status": status,
        "reason": reason,
        "confidence": confidence,
    }


def unavailable_metric(unit: str, source: str, status: str, reason: str) -> dict[str, Any]:
    return metric(None, unit, source, status=status, reason=reason, confidence="none")


def gate(status: str, reason: str | None, evidence: Iterable[str]) -> dict[str, Any]:
    return {"status": status, "reason": reason, "evidence": list(evidence)}


def parse_timing(report_path: Path) -> dict[str, Any]:
    text = read_text(report_path)
    rows = []
    row_re = re.compile(
        r"^\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*(max|min)\s*\|"
        r"\s*([+-]?[0-9.]+)[rf]?\s*\|\s*([+-]?[0-9.]+)\s*\|"
        r"\s*([+-]?[0-9.]+)\s*\|\s*([+-]?[0-9.]+)\s*\|\s*([^|]+?)\s*\|$",
        re.MULTILINE,
    )
    for match in row_re.finditer(text):
        try:
            rows.append(
                {
                    "type": match.group(3),
                    "delay": float(match.group(4)),
                    "slack": float(match.group(7)),
                }
            )
        except ValueError:
            continue
    setup = [row for row in rows if row["type"] == "max"]
    hold = [row for row in rows if row["type"] == "min"]
    # iSTA emits aggregate TNS in a separate ASCII table after the path rows.
    # Do not infer TNS from a truncated path report when that table is absent.
    tns: dict[str, float] = {}
    tns_row_re = re.compile(
        r"^\|\s*[^|]+?\s*\|\s*(max|min)\s*\|\s*([+-]?[0-9.]+)\s*\|\s*$",
        re.MULTILINE,
    )
    for match in tns_row_re.finditer(text):
        try:
            tns[match.group(1)] = float(match.group(2))
        except ValueError:
            continue
    net_delays = [
        float(value)
        for value in re.findall(r"path net delay\s*\|[^\n]*\|\s*([+-]?[0-9.]+)\(", text)
    ]
    return {
        "setup_wns_ns": min((row["slack"] for row in setup), default=None),
        "hold_wns_ns": min((row["slack"] for row in hold), default=None),
        "setup_tns_ns": tns.get("max"),
        "hold_tns_ns": tns.get("min"),
        "worst_path_delay_ns": max((row["delay"] for row in setup), default=None),
        "reported_paths": len(rows),
        "reported_net_delay_paths": len(net_delays),
        "nonzero_net_delay_paths": sum(abs(value) > 0.0 for value in net_delays),
    }


def parse_power(report_path: Path) -> dict[str, float | None]:
    text = read_text(report_path)
    return {
        "total_w": first_float(r"Total Power\s*==\s*([0-9.eE+-]+)\s*W", text),
        "switch_w": first_float(r"Net Switch Power\s*==\s*([0-9.eE+-]+)", text),
        "internal_w": first_float(r"Cell Internal Power\s*==\s*([0-9.eE+-]+)", text),
        "leakage_w": first_float(r"Cell Leakage Power\s*==\s*([0-9.eE+-]+)", text),
    }


def parse_wirelength(report_path: Path) -> dict[str, float]:
    text = read_text(report_path)
    dbu_match = re.search(r"\| DBU\s*\|\s*(\d+)", text)
    dbu = int(dbu_match.group(1)) if dbu_match else 1
    values: dict[str, float] = {}
    for model in ("HPWL", "FLUTE", "EGR"):
        match = re.search(rf"\| {model}\s*\|\s*([0-9.]+)\s*\|", text)
        if match:
            values[model.lower()] = float(match.group(1)) / dbu
    return values


def parse_drc(report_path: Path) -> int | None:
    text = re.sub(r"\x1b\[[0-9;]*m", "", read_text(report_path))
    totals = re.findall(r"\|\s*Total\s*\|\s*(\d+)\s*\|\s*100\.00%\s*\|", text)
    if totals:
        return int(totals[-1])
    rows = re.findall(r"\|\s*[a-z][a-z0-9_]+\s*\|\s*(\d+)\s*\|\s*[0-9.]+%\s*\|", text)
    return sum(map(int, rows)) if rows else None


def load_congestion_summary(result_dir: Path) -> dict[str, dict[str, float | int]] | None:
    summary_path = result_dir / "congestion_summary.json"
    if not summary_path.is_file():
        return None
    try:
        payload = json.loads(summary_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None
    if payload.get("schema") != "C-CONG" or not payload.get("valid"):
        return None
    maps = payload.get("maps") or {}
    parsed: dict[str, dict[str, float | int]] = {}
    for direction in ("horizontal", "vertical", "union"):
        node = maps.get(direction)
        if not isinstance(node, dict):
            return None
        parsed[direction] = {
            "bin_count": int(node.get("bin_count", 0)),
            "total": float(node.get("total", 0.0)),
            "max": float(node.get("max", 0.0)),
            "mean": float(node.get("mean", 0.0)),
            "top_1_pct_mean": float(node.get("top_1_pct_mean", 0.0)),
            "top_5_pct_mean": float(node.get("top_5_pct_mean", 0.0)),
            "nonzero_bin_pct": float(node.get("nonzero_bin_pct", 0.0)),
        }
    return parsed


def parse_overflow_csv(path: Path) -> dict[str, float | int]:
    values: list[float] = []
    with path.open(newline="", encoding="utf-8") as stream:
        for row_number, row in enumerate(csv.reader(stream), start=1):
            for column_number, token in enumerate(row, start=1):
                stripped = token.strip()
                if not stripped:
                    raise ValueError(f"empty value at row {row_number}, column {column_number}")
                value = float(stripped)
                if not math.isfinite(value) or value < 0:
                    raise ValueError(
                        f"invalid overflow {stripped!r} at row {row_number}, column {column_number}"
                    )
                values.append(value)
    if not values:
        raise ValueError("overflow map is empty")
    ordered = sorted(values, reverse=True)

    def top_mean(fraction: float) -> float:
        count = max(1, math.ceil(len(ordered) * fraction))
        return sum(ordered[:count]) / count

    return {
        "bin_count": len(values),
        "total": sum(values),
        "max": max(values),
        "mean": sum(values) / len(values),
        "top_1_pct_mean": top_mean(0.01),
        "top_5_pct_mean": top_mean(0.05),
        "nonzero_bin_pct": 100.0 * sum(value > 0 for value in values) / len(values),
    }


def parse_ir(report_path: Path) -> dict[str, float | None]:
    text = read_text(report_path)
    return {
        "worst_v": first_float(r"(?:worst|max(?:imum)?)\s+(?:ir[-_ ]?drop|drop)[^0-9+-]*([0-9.eE+-]+)", text),
        "average_v": first_float(r"(?:average|avg)\s+(?:ir[-_ ]?drop|drop)[^0-9+-]*([0-9.eE+-]+)", text),
    }


def evidence(path: Path | None, source: str, missing_status: str, missing_reason: str) -> dict[str, Any]:
    if path is not None and path.is_file() and path.stat().st_size > 0:
        return {
            "source": source,
            "status": "checked",
            "reason": None,
            "path": str(path.resolve()),
            "sha256": sha256_file(path),
        }
    return {
        "source": source,
        "status": missing_status,
        "reason": missing_reason,
        "path": str(path.resolve()) if path is not None else None,
        "sha256": None,
    }


def git_identity(repo_root: Path) -> tuple[str | None, bool | None]:
    try:
        commit = subprocess.run(
            ["git", "rev-parse", "HEAD"],
            cwd=repo_root,
            text=True,
            capture_output=True,
            check=True,
        ).stdout.strip()
        dirty = bool(
            subprocess.run(
                ["git", "status", "--porcelain"],
                cwd=repo_root,
                text=True,
                capture_output=True,
                check=True,
            ).stdout
        )
        return commit, dirty
    except (OSError, subprocess.CalledProcessError):
        return None, None


def build_quality_summary(
    *,
    design: str,
    pdk: str,
    strategy: str,
    workspace: Path,
    repo_root: Path,
    input_signature: dict[str, Any],
    route_iterations: int,
    quality_gate: str,
    stages: dict[str, Any],
    spef_path: Path | None = None,
    spef_source: str = "none",
    vcd_path: Path | None = None,
    vcd_top: str | None = None,
    ir_report: Path | None = None,
) -> dict[str, Any]:
    result_dir = workspace / "result"
    timing_report = result_dir / "timing" / "aes_cipher_top.rpt"
    timing_log = result_dir / "logs" / "timing.log"
    power_report = result_dir / "power" / "aes_cipher_top.pwr"
    wirelength_report = result_dir / "report" / "wirelength.rpt"
    drc_report = result_dir / "report" / "drc" / "iRT_drc.rpt"
    gds = result_dir / "final.gds"
    final_def = result_dir / "iRT_result.def"

    spef_ev = evidence(
        spef_path,
        spef_source,
        "unsupported" if spef_source == "none" else "refused",
        "no SPEF/RCX configuration was supplied" if spef_source == "none" else "configured SPEF is missing or empty",
    )
    activity_source = "vcd" if vcd_path is not None else "none"
    activity_ev = evidence(
        vcd_path,
        activity_source,
        "skipped",
        "no VCD/SAIF activity source was supplied; default toggle is not signoff evidence",
    )
    sdc_records = [item for item in input_signature.get("inputs", []) if str(item.get("path", "")).endswith(".sdc")]
    constraints_ev = {
        "source": "sdc",
        "status": "checked" if timing_log.is_file() else "skipped",
        "reason": None if timing_log.is_file() else "timing log is unavailable",
        "path": sdc_records[-1]["path"] if sdc_records else None,
        "sha256": sdc_records[-1]["sha256"] if sdc_records else None,
    }

    metrics: dict[str, dict[str, Any]] = {}
    timing = parse_timing(timing_report) if timing_report.is_file() else {}
    timing_source = str(timing_report.resolve())
    for name, unit in (
        ("setup_wns_ns", "ns"),
        ("hold_wns_ns", "ns"),
        ("setup_tns_ns", "ns"),
        ("hold_tns_ns", "ns"),
        ("worst_path_delay_ns", "ns"),
        ("reported_paths", "count"),
        ("reported_net_delay_paths", "count"),
        ("nonzero_net_delay_paths", "count"),
    ):
        metrics[f"timing.{name}"] = (
            metric(timing.get(name), unit, timing_source)
            if timing_report.is_file()
            else unavailable_metric(unit, timing_source, "skipped", "timing report is missing")
        )

    unconstrained = set(
        re.findall(
            r"(?:input|output) port\s+(\S+)\s+is not constrained",
            read_text(timing_log),
            re.IGNORECASE,
        )
    )
    metrics["timing.unconstrained_endpoint_count"] = (
        metric(len(unconstrained), "count", str(timing_log.resolve()))
        if timing_log.is_file()
        else unavailable_metric("count", str(timing_log.resolve()), "skipped", "timing log is missing")
    )

    power = parse_power(power_report) if power_report.is_file() else {}
    power_confidence = "high" if activity_ev["status"] == "checked" else "low"
    power_reason = None if power_confidence == "high" else "power used no traceable activity source"
    for name in ("total_w", "switch_w", "internal_w", "leakage_w"):
        metrics[f"power.{name}"] = (
            metric(
                power.get(name),
                "W",
                str(power_report.resolve()),
                confidence=power_confidence,
                reason=power_reason,
            )
            if power_report.is_file()
            else unavailable_metric("W", str(power_report.resolve()), "skipped", "power report is missing")
        )

    wirelength = parse_wirelength(wirelength_report) if wirelength_report.is_file() else {}
    for model in ("hpwl", "flute", "egr"):
        metrics[f"wirelength.{model}_um"] = (
            metric(wirelength.get(model), "um", str(wirelength_report.resolve()))
            if wirelength_report.is_file()
            else unavailable_metric("um", str(wirelength_report.resolve()), "skipped", "wirelength report is missing")
        )

    congestion_valid = True
    summary_maps = load_congestion_summary(result_dir)
    for direction in ("horizontal", "vertical", "union"):
        map_path = result_dir / "egr_congestion_map" / f"place_egr_{direction}_overflow.csv"
        try:
            if summary_maps is not None:
                summary = summary_maps[direction]
                provenance = str((result_dir / "congestion_summary.json").resolve())
            else:
                summary = parse_overflow_csv(map_path)
                provenance = str(map_path.resolve())
            for key, value in summary.items():
                unit = "percent" if key.endswith("pct") else ("count" if key == "bin_count" else "overflow")
                metrics[f"congestion.{direction}.{key}"] = metric(value, unit, provenance)
        except (OSError, ValueError, KeyError) as exc:
            congestion_valid = False
            for key in ("bin_count", "total", "max", "mean", "top_1_pct_mean", "top_5_pct_mean", "nonzero_bin_pct"):
                unit = "percent" if key.endswith("pct") else ("count" if key == "bin_count" else "overflow")
                metrics[f"congestion.{direction}.{key}"] = unavailable_metric(
                    unit, str(map_path.resolve()), "refused", str(exc)
                )

    drc_total = parse_drc(drc_report) if drc_report.is_file() else None
    metrics["drc.total"] = (
        metric(drc_total, "count", str(drc_report.resolve()))
        if drc_report.is_file()
        else unavailable_metric("count", str(drc_report.resolve()), "skipped", "DRC report is missing")
    )
    route_elapsed = stages.get("routing", {}).get("elapsed_sec")
    metrics["routing.iterations"] = metric(route_iterations, "count", "flow argument --rt-max-iterations")
    metrics["routing.runtime_sec"] = metric(
        route_elapsed,
        "s",
        "stage result",
        status="checked" if route_elapsed is not None else "skipped",
        reason=None if route_elapsed is not None else "routing stage was resumed or not run",
        confidence="high" if route_elapsed is not None else "none",
    )

    ir = parse_ir(ir_report) if ir_report is not None and ir_report.is_file() else {}
    for name in ("worst_v", "average_v"):
        metrics[f"ir_drop.{name}"] = (
            metric(ir.get(name), "V", str(ir_report.resolve()))
            if ir_report is not None and ir_report.is_file()
            else unavailable_metric("V", "iIR report", "unsupported", "iIR/PDN evidence was not supplied")
        )
    metrics["gds.exists"] = metric(gds.is_file() and gds.stat().st_size > 0, "boolean", str(gds.resolve()))

    timing_stage_ok = stages.get("timing", {}).get("status") != "failed"
    power_stage_ok = stages.get("power", {}).get("status") != "failed"
    timing_available = timing_stage_ok and timing_report.is_file() and timing.get("reported_paths", 0) > 0
    nonzero_net_delay = timing.get("nonzero_net_delay_paths", 0) > 0
    activity_valid = power_stage_ok and activity_ev["status"] == "checked" and (power.get("switch_w") or 0.0) > 0.0
    constraint_valid = timing_log.is_file() and not unconstrained
    drc_available = drc_total is not None
    drc_clean = drc_total == 0 if drc_available else False
    ir_valid = ir.get("worst_v") is not None and ir.get("average_v") is not None

    gates = {
        "G7_spef_backed_sta": gate(
            "pass" if timing_available and spef_ev["status"] == "checked" and nonzero_net_delay else "fail",
            None
            if timing_available and spef_ev["status"] == "checked" and nonzero_net_delay
            else "post-route STA lacks SPEF evidence or every reported path has zero net delay",
            ("timing.nonzero_net_delay_paths", "provenance.spef"),
        ),
        "G7_constraint_coverage": gate(
            "pass" if constraint_valid else ("fail" if timing_log.is_file() else "not_run"),
            None if constraint_valid else "unconstrained endpoints remain or timing log is unavailable",
            ("timing.unconstrained_endpoint_count", "provenance.constraints"),
        ),
        "G9_activity_backed_power": gate(
            "pass" if activity_valid else ("fail" if power_report.is_file() else "not_run"),
            None if activity_valid else "power lacks VCD/SAIF evidence or switching power is not positive",
            ("power.switch_w", "provenance.activity"),
        ),
        "G5_congestion_summary": gate(
            "pass" if congestion_valid else "fail",
            None if congestion_valid else "one or more EGR overflow maps are missing, empty, or invalid",
            tuple(f"congestion.{direction}.top_1_pct_mean" for direction in ("horizontal", "vertical", "union")),
        ),
        "G11_drc_clean": gate(
            "pass" if drc_clean else ("fail" if drc_available else "not_run"),
            None if drc_clean else "DRC violations remain or DRC was not run",
            ("drc.total",),
        ),
        "G10_ir_drop": gate(
            "pass" if ir_valid else ("fail" if ir_report is not None else "not_run"),
            None if ir_valid else "worst/average IR-drop and a real PDN/current model are unavailable",
            ("ir_drop.worst_v", "ir_drop.average_v"),
        ),
        "GDS_signoff": gate(
            "pass" if gds.is_file() and drc_clean else "fail",
            None if gds.is_file() and drc_clean else "GDS exists only as a flow artifact; DRC clean is required",
            ("gds.exists", "drc.total"),
        ),
    }

    binary_record = None
    input_records = []
    for item in input_signature.get("inputs", []):
        path = Path(item["path"])
        record = {
            "path": str(path.resolve()),
            "sha256": item["sha256"],
            "size_bytes": path.stat().st_size if path.is_file() else 0,
        }
        if path.resolve() == (repo_root / "bin" / "iEDA").resolve():
            binary_record = record
        else:
            input_records.append(record)
    artifact_paths = [final_def, gds, timing_report, power_report, wirelength_report, drc_report]
    artifact_paths.extend(
        result_dir / "egr_congestion_map" / f"place_egr_{direction}_overflow.csv"
        for direction in ("horizontal", "vertical", "union")
    )
    if spef_source == "ircx" and spef_path is not None:
        artifact_paths.append(spef_path)
    artifacts = [file_record(path) for path in artifact_paths if path.is_file() and path.stat().st_size > 0]
    git_commit, dirty = git_identity(repo_root)
    build_manifest = {"binary": binary_record, "git_commit": git_commit, "dirty": dirty}
    build_manifest["manifest_sha256"] = canonical_sha256(build_manifest)
    all_passed = all(gates[name]["status"] == "pass" for name in STRICT_GATES)
    any_run = any(item["status"] != "not_run" for item in gates.values())

    return {
        "schema_version": SCHEMA_VERSION,
        "design": design,
        "pdk": pdk,
        "strategy": strategy,
        "stage": "post_route",
        "timestamp": datetime.now().astimezone().isoformat(),
        "quality_gate": quality_gate,
        "overall_status": "pass" if all_passed else ("fail" if any_run else "incomplete"),
        "manifest": {
            "inputs": input_records,
            "input_sha256": canonical_sha256(input_records),
            "build": build_manifest,
            "artifacts": artifacts,
            "artifact_sha256": canonical_sha256(artifacts),
        },
        "provenance": {
            "route_iterations": route_iterations,
            "spef": spef_ev,
            "activity": {**activity_ev, "top": vcd_top},
            "constraints": constraints_ev,
        },
        "metrics": metrics,
        "gates": gates,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("workspace", type=Path)
    parser.add_argument("--design", required=True)
    parser.add_argument("--pdk", required=True)
    parser.add_argument("--strategy", required=True)
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--route-iterations", type=int, default=1)
    parser.add_argument("--quality-gate", choices=("report", "strict"), default="report")
    parser.add_argument("--spef", type=Path)
    parser.add_argument("--spef-source", choices=("provided", "ircx", "none"), default="none")
    parser.add_argument("--vcd", type=Path)
    parser.add_argument("--vcd-top")
    parser.add_argument("--ir-report", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    signature_path = args.workspace / "input_signature.json"
    signature = json.loads(signature_path.read_text(encoding="utf-8"))
    summary = build_quality_summary(
        design=args.design,
        pdk=args.pdk,
        strategy=args.strategy,
        workspace=args.workspace,
        repo_root=args.repo_root,
        input_signature=signature,
        route_iterations=args.route_iterations,
        quality_gate=args.quality_gate,
        stages={},
        spef_path=args.spef,
        spef_source=args.spef_source,
        vcd_path=args.vcd,
        vcd_top=args.vcd_top,
        ir_report=args.ir_report,
    )
    output = args.output or args.workspace.parent / "quality_summary.json"
    output.write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    print(output)
    return 1 if args.quality_gate == "strict" and summary["overall_status"] != "pass" else 0


if __name__ == "__main__":
    raise SystemExit(main())
