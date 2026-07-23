from __future__ import annotations

import json
import tempfile
import unittest
from copy import deepcopy
from pathlib import Path

from benchmarks.qor.compare_qor import compare
from benchmarks.qor.quality_metrics import build_quality_summary, parse_overflow_csv
from benchmarks.qor.validate_qor import validate_summary


class QualityMetricsTest(unittest.TestCase):
    def test_overflow_statistics(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "map.csv"
            path.write_text("0,1\n2,5\n", encoding="ascii")
            result = parse_overflow_csv(path)
        self.assertEqual(result["total"], 8.0)
        self.assertEqual(result["max"], 5.0)
        self.assertEqual(result["nonzero_bin_pct"], 75.0)

    def test_overflow_rejects_empty_cells(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "map.csv"
            path.write_text("0,\n", encoding="ascii")
            with self.assertRaisesRegex(ValueError, "empty value"):
                parse_overflow_csv(path)

    def test_missing_signoff_evidence_is_explicit(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            workspace = root / "workspace"
            (workspace / "result").mkdir(parents=True)
            input_file = root / "input.v"
            input_file.write_text("module top; endmodule\n", encoding="ascii")
            signature = {
                "inputs": [
                    {
                        "path": str(input_file),
                        "sha256": "0" * 64,
                    }
                ]
            }
            summary = build_quality_summary(
                design="test",
                pdk="test_pdk",
                strategy="a",
                workspace=workspace,
                repo_root=root,
                input_signature=signature,
                route_iterations=3,
                quality_gate="strict",
                stages={},
            )
        self.assertEqual(summary["overall_status"], "fail")
        self.assertEqual(summary["provenance"]["spef"]["status"], "unsupported")
        self.assertEqual(summary["gates"]["G7_spef_backed_sta"]["status"], "fail")
        self.assertEqual(validate_summary(summary), [])
        json.dumps(summary)

        invalid = deepcopy(summary)
        del invalid["metrics"]["drc.total"]["source"]
        self.assertTrue(any("drc.total" in error for error in validate_summary(invalid)))

        comparison = compare(summary, deepcopy(summary))
        self.assertIsNone(comparison["summary"]["weighted_score"])
        self.assertEqual(comparison["summary"]["gate_regressions"], 0)


if __name__ == "__main__":
    unittest.main()
