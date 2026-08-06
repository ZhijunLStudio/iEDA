from __future__ import annotations

import copy
import unittest

from benchmarks.qor.validate_quality_gate import validate_quality_gate


def gate(name: str, status: str, domain: str, reason: str | None = None) -> dict:
    return {
        "name": name,
        "status": status,
        "severity": "hard",
        "domain": domain,
        "reason": reason,
        "evidence": {"primary": {"path": f"/tmp/{name}.json", "exists": status == "pass"}},
    }


class QualityGateValidatorTest(unittest.TestCase):
    def sample_payload(self) -> dict:
        gates = [
            gate("flow_completion", "pass", "flow"),
            gate("layout_export", "pass", "flow"),
            gate("drc_clean", "fail", "signoff", "residual detailed-route DRC is non-zero"),
            gate("constraints_loaded", "fail", "signoff", "configured SDC is missing or empty"),
            gate("spef_backed_sta", "fail", "signoff", "timing report path net delay samples are all zero"),
            gate("activity_backed_power", "fail", "signoff", "power uses vectorless/default activity"),
            gate("ir_drop_analyzed", "fail", "signoff", "IR-drop analysis evidence is missing"),
            gate("congestion_summary", "pass", "signoff"),
        ]
        return {
            "schema": "c-quality-gate/v2",
            "schema_version": 2,
            "stage": "post_route",
            "flow_success": True,
            "signoff_success": False,
            "overall_status": "fail",
            "flow_status": "pass",
            "signoff_status": "fail",
            "gates": gates,
        }

    def test_flow_pass_signoff_fail_is_valid_when_evidence_is_explicit(self) -> None:
        self.assertEqual(validate_quality_gate(self.sample_payload()), [])

    def test_schema_reason_and_summary_are_checked(self) -> None:
        payload = self.sample_payload()
        payload["schema"] = "c-quality-gate/v1"
        payload["gates"][2]["reason"] = None
        payload["signoff_success"] = True
        errors = validate_quality_gate(payload)
        self.assertTrue(any("schema" in error for error in errors))
        self.assertTrue(any("non-pass gate" in error for error in errors))
        self.assertTrue(any("signoff_success" in error for error in errors))

    def test_missing_evidence_path_is_rejected_for_p0_gates(self) -> None:
        payload = self.sample_payload()
        payload["gates"][4] = copy.deepcopy(payload["gates"][4])
        payload["gates"][4]["evidence"] = {"timing_net_delay": {"sample_count": 6}}
        errors = validate_quality_gate(payload)
        self.assertTrue(any("spef_backed_sta" in error and "evidence" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
