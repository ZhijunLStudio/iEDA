from __future__ import annotations

import json
import unittest
from copy import deepcopy
from pathlib import Path

from benchmarks.qor.validate_protocol import validate_protocol


class ParityProtocolTest(unittest.TestCase):
    def setUp(self) -> None:
        self.path = Path(__file__).resolve().parents[1] / "parity_protocol.json"
        self.protocol = json.loads(self.path.read_text(encoding="utf-8"))

    def test_repository_protocol_is_frozen_and_valid(self) -> None:
        self.assertEqual(validate_protocol(self.protocol, self.path), [])

    def test_protocol_drift_is_rejected(self) -> None:
        changed = deepcopy(self.protocol)
        changed["performance"]["repeats"] = 1
        changed["performance"]["profile_schema"]["sha256"] = "0" * 64
        changed["performance"]["required_stages"] = ["iFP"]
        changed["report_points"] = ["post_route"]
        changed["metric_schema"]["sha256"] = "0" * 64
        errors = validate_protocol(changed, self.path)
        self.assertTrue(any("at least five repeats" in error for error in errors))
        self.assertTrue(any("performance.profile_schema" in error for error in errors))
        self.assertTrue(any("required_stages" in error for error in errors))
        self.assertTrue(any("report_points" in error for error in errors))
        self.assertTrue(any("schema changed" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
