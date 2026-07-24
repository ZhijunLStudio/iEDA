from __future__ import annotations

import json
import tempfile
import unittest
from copy import deepcopy
from pathlib import Path

from benchmarks.qor.performance_profile import (
    compare_profiles,
    comparison_exit_code,
    load_jsonl,
    robust_stats,
    validate_record,
)


class PerformanceProfileTest(unittest.TestCase):
    def setUp(self) -> None:
        path = Path(__file__).resolve().parents[1] / "parity_protocol.json"
        self.protocol = json.loads(path.read_text(encoding="utf-8"))

    def record(
        self,
        role: str,
        design: str,
        repeat: int,
        wall_sec: float,
        *,
        stage: str = "e2e",
    ) -> dict:
        return {
            "schema_version": "1.0",
            "tool_role": role,
            "tool": "iEDA" if role == "ieda" else "innovus",
            "design": design,
            "stage": stage,
            "run_id": f"{role}-{design}-{repeat}",
            "repeat": repeat,
            "cache_mode": "warm",
            "wall_sec": wall_sec,
            "user_cpu_sec": wall_sec * 4,
            "system_cpu_sec": 0.1,
            "threads": self.protocol["performance"]["threads"],
            "hostname": "controlled-host",
            "binary_sha256": ("a" if role == "ieda" else "b") * 64,
            "build_manifest_sha256": ("d" if role == "ieda" else "e") * 64,
            "hardware_manifest_sha256": "c" * 64,
            "input_manifest_sha256": (design.encode("ascii").hex() + "0" * 64)[:64],
            "exclusive_host": True,
            "status": "success",
            "comparable": True,
        }

    def profiles(self, ratio: float = 0.9) -> tuple[list[dict], list[dict]]:
        ieda = []
        commercial = []
        for design in self.protocol["benchmark_sets"]["daily"]:
            for stage in self.protocol["performance"]["required_stages"]:
                for repeat in range(1, 6):
                    commercial.append(
                        self.record("commercial", design, repeat, 10.0, stage=stage)
                    )
                    ieda.append(
                        self.record("ieda", design, repeat, 10.0 * ratio, stage=stage)
                    )
        return ieda, commercial

    def test_record_validation_and_jsonl_line_number(self) -> None:
        invalid = self.record("ieda", "aes", 1, 1.0)
        invalid["comparable"] = False
        invalid["unexpected"] = "rejected"
        invalid["wall_sec"] = float("nan")
        self.assertTrue(any("non_comparable_reason" in error for error in validate_record(invalid)))
        self.assertTrue(any("unexpected unexpected" in error for error in validate_record(invalid)))
        self.assertTrue(any("wall_sec" in error for error in validate_record(invalid)))
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "profile.jsonl"
            path.write_text("{}\nnot-json\n", encoding="ascii")
            records, errors = load_jsonl(path)
            self.assertEqual(records, [])
            self.assertTrue(any(f"{path}:2" in error for error in errors))

    def test_robust_stats_use_median_and_mad(self) -> None:
        stats = robust_stats([10.0, 10.0, 10.0, 10.0, 1000.0])
        self.assertEqual(stats["median_sec"], 10.0)
        self.assertEqual(stats["mad_sec"], 0.0)

    def test_daily_g21_passes_with_five_controlled_repeats(self) -> None:
        ieda, commercial = self.profiles()
        comparison = compare_profiles(ieda, commercial, self.protocol, cache_mode="warm")
        self.assertEqual(comparison["g21"]["status"], "pass")
        self.assertEqual(comparison["g21"]["le_one_count"], 5)
        self.assertEqual(comparison_exit_code(comparison), 0)

    def test_missing_repeat_and_manifest_mismatch_are_incomplete(self) -> None:
        ieda, commercial = self.profiles()
        ieda.pop()
        commercial[0]["input_manifest_sha256"] = "f" * 64
        comparison = compare_profiles(ieda, commercial, self.protocol, cache_mode="warm")
        self.assertEqual(comparison["g21"]["status"], "incomplete")
        self.assertEqual(comparison_exit_code(comparison), 1)
        self.assertTrue(any("requires at least 5 repeats" in error for error in comparison["comparability_errors"]))
        self.assertTrue(any("input manifests do not match" in error for error in comparison["comparability_errors"]))

    def test_host_control_and_hardware_identity_are_required(self) -> None:
        ieda, commercial = self.profiles()
        ieda[0]["exclusive_host"] = False
        commercial[0]["hardware_manifest_sha256"] = "f" * 64
        comparison = compare_profiles(ieda, commercial, self.protocol, cache_mode="warm")
        self.assertEqual(comparison["g21"]["status"], "incomplete")
        self.assertTrue(any("exclusive-host" in error for error in comparison["comparability_errors"]))
        self.assertTrue(any("hardware manifests" in error for error in comparison["comparability_errors"]))

    def test_missing_required_stage_is_incomplete(self) -> None:
        ieda, commercial = self.profiles()
        design = self.protocol["benchmark_sets"]["daily"][0]
        commercial = [
            record
            for record in commercial
            if not (record["design"] == design and record["stage"] == "iRT-DR")
        ]
        comparison = compare_profiles(ieda, commercial, self.protocol, cache_mode="warm")
        self.assertEqual(comparison["g21"]["status"], "incomplete")
        self.assertIn(
            f"{design}/iRT-DR",
            comparison["g21"]["incomplete_required_measurements"],
        )

    def test_ratio_failure_only_gates_when_enabled(self) -> None:
        ieda, commercial = self.profiles(ratio=2.0)
        comparison = compare_profiles(ieda, commercial, self.protocol, cache_mode="warm")
        self.assertEqual(comparison["g21"]["status"], "fail")
        self.assertEqual(comparison_exit_code(comparison), 0)
        gated_protocol = deepcopy(self.protocol)
        gated_protocol["performance"]["g21_enable"] = True
        gated = compare_profiles(ieda, commercial, gated_protocol, cache_mode="warm")
        self.assertEqual(comparison_exit_code(gated), 1)


if __name__ == "__main__":
    unittest.main()
