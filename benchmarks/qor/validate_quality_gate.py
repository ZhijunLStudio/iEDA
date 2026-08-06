from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


REQUIRED_GATES = {
    "flow_completion",
    "layout_export",
    "drc_clean",
    "constraints_loaded",
    "spef_backed_sta",
    "activity_backed_power",
    "ir_drop_analyzed",
    "congestion_summary",
}

EVIDENCE_REQUIRED_GATES = {
    "constraints_loaded",
    "spef_backed_sta",
    "activity_backed_power",
    "ir_drop_analyzed",
}


def _is_bool(value: Any) -> bool:
    return isinstance(value, bool)


def _gate_map(payload: dict[str, Any]) -> dict[str, dict[str, Any]]:
    gates = payload.get("gates")
    if not isinstance(gates, list):
        return {}
    return {
        gate.get("name"): gate
        for gate in gates
        if isinstance(gate, dict) and isinstance(gate.get("name"), str)
    }


def _has_evidence_path(value: Any) -> bool:
    if isinstance(value, dict):
        path = value.get("path")
        if isinstance(path, str) and path:
            return True
        return any(_has_evidence_path(child) for child in value.values())
    if isinstance(value, list):
        return any(_has_evidence_path(child) for child in value)
    return False


def validate_quality_gate(payload: dict[str, Any], path: Path | None = None) -> list[str]:
    label = f"{path}: " if path else ""
    errors: list[str] = []

    if payload.get("schema") != "c-quality-gate/v2":
        errors.append(f"{label}schema must be c-quality-gate/v2")
    if payload.get("schema_version") != 2:
        errors.append(f"{label}schema_version must be 2")
    if not _is_bool(payload.get("flow_success")):
        errors.append(f"{label}flow_success must be boolean")
    if not _is_bool(payload.get("signoff_success")):
        errors.append(f"{label}signoff_success must be boolean")

    gates = _gate_map(payload)
    missing = sorted(REQUIRED_GATES - set(gates))
    if missing:
        errors.append(f"{label}missing gates: {', '.join(missing)}")

    flow_fail = 0
    signoff_fail = 0
    for name, gate in sorted(gates.items()):
        status = gate.get("status")
        severity = gate.get("severity")
        domain = gate.get("domain")
        evidence = gate.get("evidence")
        reason = gate.get("reason")
        if status not in {"pass", "fail", "warn", "not_run"}:
            errors.append(f"{label}{name}: invalid status {status!r}")
        if severity not in {"hard", "soft"}:
            errors.append(f"{label}{name}: invalid severity {severity!r}")
        if domain not in {"flow", "signoff", "evidence"}:
            errors.append(f"{label}{name}: invalid domain {domain!r}")
        if not isinstance(evidence, dict):
            errors.append(f"{label}{name}: evidence must be an object")
        if status in {"fail", "warn", "not_run"} and not reason:
            errors.append(f"{label}{name}: non-pass gate must include a failure reason")
        if name in EVIDENCE_REQUIRED_GATES and isinstance(evidence, dict) and not _has_evidence_path(evidence):
            errors.append(f"{label}{name}: evidence must include at least one non-empty path")
        if status == "fail" and domain == "flow":
            flow_fail += 1
        if status == "fail" and domain == "signoff":
            signoff_fail += 1

    expected_flow_success = flow_fail == 0
    if isinstance(payload.get("flow_success"), bool) and payload["flow_success"] != expected_flow_success:
        errors.append(f"{label}flow_success does not match flow-domain hard gates")

    expected_signoff_success = expected_flow_success and signoff_fail == 0
    if isinstance(payload.get("signoff_success"), bool) and payload["signoff_success"] != expected_signoff_success:
        errors.append(f"{label}signoff_success does not match signoff-domain hard gates")

    if payload.get("overall_status") != ("pass" if payload.get("signoff_success") else "fail"):
        errors.append(f"{label}overall_status must mirror signoff_success")

    return errors


def load_quality_gate(path: Path) -> dict[str, Any]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(payload, dict):
        raise ValueError(f"{path}: quality gate JSON root must be an object")
    return payload


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Validate iEDA quality_gate.json schema and evidence fields.")
    parser.add_argument("paths", nargs="+", type=Path, help="quality_gate.json file(s)")
    parser.add_argument("--expect-flow-success", action="store_true")
    parser.add_argument("--expect-signoff-fail", action="store_true")
    args = parser.parse_args(argv)

    errors: list[str] = []
    for path in args.paths:
        try:
            payload = load_quality_gate(path)
        except Exception as exc:  # noqa: BLE001 - CLI should report any parse error plainly.
            errors.append(str(exc))
            continue
        errors.extend(validate_quality_gate(payload, path))
        if args.expect_flow_success and payload.get("flow_success") is not True:
            errors.append(f"{path}: expected flow_success=true")
        if args.expect_signoff_fail and payload.get("signoff_success") is not False:
            errors.append(f"{path}: expected signoff_success=false")

    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
