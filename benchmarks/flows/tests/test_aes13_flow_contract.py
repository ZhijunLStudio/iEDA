from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path
from unittest import mock

from benchmarks.flows import aes13_flow


class Aes13StageContractTest(unittest.TestCase):
    def test_pdk_contracts_use_real_driving_pins_and_routing_layers(self) -> None:
        self.assertEqual(aes13_flow.PDKS["sky130"].driving_pin, "X")
        self.assertEqual(aes13_flow.PDKS["nangate45"].driving_pin, "Z")
        self.assertEqual(aes13_flow.PDKS["asap7"].driving_pin, "Y")
        self.assertEqual(aes13_flow.PDKS["ics55"].driving_pin, "Y")
        self.assertEqual(aes13_flow.PDKS["ics55"].top_routing_layer, "MET5")
        self.assertEqual(aes13_flow.PDKS["sky130"].cts_buffers[-1], "sky130_fd_sc_hd__buf_8")
        self.assertEqual(aes13_flow.PDKS["nangate45"].cts_buffers[-1], "BUF_X8")
        self.assertEqual(aes13_flow.PDKS["asap7"].cts_buffers[-1], "BUFx8_ASAP7_75t_R")
        self.assertEqual(aes13_flow.PDKS["ics55"].cts_buffers[-1], "BUFX8H7R")

    def test_protocol_threads_drive_every_parallel_runtime(self) -> None:
        protocol_path = Path(__file__).resolve().parents[2] / "qor/parity_protocol.json"
        protocol = json.loads(protocol_path.read_text(encoding="utf-8"))
        performance = aes13_flow.resolve_performance_contract(protocol["performance"], None)
        self.assertEqual(performance["threads"], protocol["performance"]["threads"])
        self.assertEqual(performance["thread_source"], "protocol")
        self.assertEqual(performance["g21_mode"], "observational")
        self.assertEqual(performance["g21_comparability"], "non_comparable")

        env = aes13_flow.controlled_thread_environment(
            {"OMP_NUM_THREADS": "64", "UNRELATED": "kept"},
            performance["threads"],
        )
        for key in aes13_flow.THREAD_ENVIRONMENT_KEYS:
            self.assertEqual(env[key], str(performance["threads"]))
        self.assertEqual(env["UNRELATED"], "kept")

    def test_cli_thread_override_is_recorded_as_non_comparable(self) -> None:
        performance = aes13_flow.resolve_performance_contract(
            {"threads": 8, "g21_enable": True},
            4,
        )
        self.assertEqual(performance["threads"], 4)
        self.assertEqual(performance["protocol_threads"], 8)
        self.assertEqual(performance["thread_source"], "cli_override")
        self.assertEqual(performance["g21_mode"], "observational")
        self.assertEqual(performance["g21_comparability"], "non_comparable")
        with self.assertRaisesRegex(ValueError, "at least 1"):
            aes13_flow.resolve_performance_contract({"threads": 8}, 0)

    def make_workspace(self, root: Path) -> tuple[Path, aes13_flow.Stage, Path, Path]:
        workspace = root / "workspace"
        script = workspace / "script/custom/run.tcl"
        artifact = workspace / "result/out.def"
        (workspace / "result/logs").mkdir(parents=True)
        script.parent.mkdir(parents=True)
        script.write_text("puts contract-test\n", encoding="ascii")
        artifact.write_text("VERSION 5.8 ;\n", encoding="ascii")
        config = workspace / "iEDA_config/flow.json"
        config.parent.mkdir(parents=True)
        config.write_text('{"flow": "test"}\n', encoding="ascii")
        stage = aes13_flow.Stage("contract_test", "custom/run.tcl", "out.def")
        return workspace, stage, script, artifact

    def test_resume_requires_matching_manifest_and_artifact_hash(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            workspace, stage, script, artifact = self.make_workspace(Path(temp))
            signature_hash = "a" * 64
            result = {
                "status": "success",
                "returncode": 0,
                "artifact": str(artifact),
                "started_epoch_ns": 1,
                "elapsed_sec": 0.1,
            }
            aes13_flow.write_stage_manifest(stage, workspace, signature_hash, [], result)
            valid, _, _ = aes13_flow.validate_stage_manifest(stage, workspace, signature_hash, [])
            self.assertTrue(valid)

            artifact.write_text("changed\n", encoding="ascii")
            valid, reason, _ = aes13_flow.validate_stage_manifest(stage, workspace, signature_hash, [])
            self.assertFalse(valid)
            self.assertIn("artifact content changed", reason)

            artifact.write_text("VERSION 5.8 ;\n", encoding="ascii")
            script.write_text("puts changed-script\n", encoding="ascii")
            valid, reason, _ = aes13_flow.validate_stage_manifest(stage, workspace, signature_hash, [])
            self.assertFalse(valid)
            self.assertIn("fingerprint changed", reason)

    def test_old_artifact_cannot_mask_a_successful_no_output_process(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            workspace, stage, _, artifact = self.make_workspace(Path(temp))
            with mock.patch.object(aes13_flow, "IEDA_BIN", Path("/bin/true")):
                result = aes13_flow.run_stage(
                    stage,
                    workspace,
                    {},
                    timeout=10,
                    resume=True,
                    input_signature_sha256="b" * 64,
                    prerequisites=[],
                )
            self.assertEqual(result["returncode"], 0)
            self.assertEqual(result["status"], "failed")
            self.assertEqual(result["freshness"], "stale_or_missing")
            self.assertEqual(result["artifact"], str(artifact))
            self.assertFalse(artifact.exists())

    def test_any_generated_script_or_config_change_invalidates_manifest(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            workspace, stage, _, artifact = self.make_workspace(Path(temp))
            other_script = workspace / "script/custom/other.tcl"
            other_script.write_text("puts original\n", encoding="ascii")
            config = workspace / "iEDA_config/flow.json"
            signature_hash = "d" * 64
            aes13_flow.write_stage_manifest(
                stage,
                workspace,
                signature_hash,
                [],
                {"status": "success", "returncode": 0, "artifact": str(artifact)},
            )

            for path, replacement in (
                (other_script, "puts changed\n"),
                (config, '{"flow": "changed"}\n'),
            ):
                with self.subTest(path=path.relative_to(workspace)):
                    original = path.read_text(encoding="ascii")
                    path.write_text(replacement, encoding="ascii")
                    valid, reason, _ = aes13_flow.validate_stage_manifest(
                        stage, workspace, signature_hash, []
                    )
                    self.assertFalse(valid)
                    self.assertIn("fingerprint changed", reason)
                    path.write_text(original, encoding="ascii")

    def test_failed_drc_and_gds_reruns_remove_old_quality_evidence(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            workspace = Path(temp) / "workspace"
            (workspace / "result/logs").mkdir(parents=True)
            cases = (
                (
                    aes13_flow.Stage(
                        "drc", "custom/run_drc.tcl", "report/drc/iRT_drc.rpt", False
                    ),
                    ("report/drc/iRT_drc.rpt",),
                ),
                (
                    aes13_flow.Stage("gds", "custom/run_gds.tcl", "final.gds", False),
                    ("final.gds", "visualizations/final.png"),
                ),
            )
            for stage, relative_outputs in cases:
                with self.subTest(stage=stage.name):
                    script = workspace / "script" / stage.script
                    script.parent.mkdir(parents=True, exist_ok=True)
                    script.write_text("puts fail\n", encoding="ascii")
                    for relative in relative_outputs:
                        output = workspace / "result" / relative
                        output.parent.mkdir(parents=True, exist_ok=True)
                        output.write_text("stale\n", encoding="ascii")
                    with mock.patch.object(aes13_flow, "IEDA_BIN", Path("/bin/false")):
                        result = aes13_flow.run_stage(
                            stage,
                            workspace,
                            {},
                            timeout=10,
                            resume=False,
                            input_signature_sha256="e" * 64,
                            prerequisites=[],
                        )
                    self.assertEqual(result["status"], "failed")
                    for relative in relative_outputs:
                        self.assertFalse((workspace / "result" / relative).exists())

    def test_power_without_activity_is_explicitly_not_applicable(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            workspace = Path(temp) / "workspace"
            old_report = workspace / "result/power/aes_cipher_top.pwr"
            old_report.parent.mkdir(parents=True)
            old_report.write_text("stale power\n", encoding="ascii")
            power = next(stage for stage in aes13_flow.STAGES if stage.name == "power")
            result = aes13_flow.not_applicable_stage_result(power, workspace, None)
            self.assertEqual(result["status"], "not_applicable")
            self.assertIn("no VCD/SAIF", result["reason"])
            self.assertIn("forbidden", result["reason"])
            self.assertFalse(old_report.exists())
            self.assertIsNone(
                aes13_flow.not_applicable_stage_result(power, workspace, Path("activity.vcd"))
            )

    def test_failed_rerun_removes_the_previous_success_stamp(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            workspace, stage, script, artifact = self.make_workspace(Path(temp))
            signature_hash = "c" * 64
            aes13_flow.write_stage_manifest(
                stage,
                workspace,
                signature_hash,
                [],
                {"status": "success", "returncode": 0, "artifact": str(artifact)},
            )
            script.write_text("puts changed\n", encoding="ascii")
            with mock.patch.object(aes13_flow, "IEDA_BIN", Path("/bin/false")):
                result = aes13_flow.run_stage(
                    stage,
                    workspace,
                    {},
                    timeout=10,
                    resume=True,
                    input_signature_sha256=signature_hash,
                    prerequisites=[],
                )
            self.assertEqual(result["status"], "failed")
            self.assertFalse(aes13_flow.stage_manifest_path(workspace, stage).exists())

    def test_partial_or_error_batch_is_nonzero_for_a_full_run(self) -> None:
        self.assertEqual(aes13_flow.batch_exit_code([{"status": "success"}]), 0)
        self.assertEqual(
            aes13_flow.batch_exit_code(
                [
                    {
                        "status": "success",
                        "stages": {"power": {"status": "not_applicable"}},
                    }
                ]
            ),
            0,
        )
        for status in ("partial", "failed", "error", "prepared"):
            with self.subTest(status=status):
                self.assertEqual(aes13_flow.batch_exit_code([{"status": status}]), 1)
        self.assertEqual(
            aes13_flow.batch_exit_code([{"status": "partial"}], stop_after="routing"),
            0,
        )
        self.assertEqual(
            aes13_flow.batch_exit_code(
                [
                    {
                        "status": "partial",
                        "stages": {"timing": {"status": "failed"}},
                    }
                ],
                stop_after="gds",
            ),
            1,
        )
        self.assertEqual(
            aes13_flow.batch_exit_code([{"status": "prepared"}], prepare_only=True),
            0,
        )
        self.assertEqual(
            aes13_flow.batch_overall_status(
                [{"status": "success", "quality": {"overall_status": "fail"}}],
                0,
            ),
            "observational",
        )
        self.assertEqual(
            aes13_flow.batch_overall_status(
                [{"status": "success", "quality": {"overall_status": "pass"}}],
                0,
            ),
            "pass",
        )

    def test_profile_records_are_schema_valid_and_cannot_claim_g21(self) -> None:
        performance = aes13_flow.resolve_performance_contract(
            {"threads": 8, "g21_enable": True}, None
        )
        evidence = {
            "hostname": "controlled-test-host",
            "binary": {"sha256": "a" * 64},
            "build_manifest": {"sha256": "b" * 64},
            "hardware_manifest": {"sha256": "c" * 64},
            "exclusive_host": False,
            "comparable": False,
            "non_comparable_reason": performance["reason"],
        }
        summary = {
            "design": "aes_asap7_a",
            "status": "success",
            "stages": {
                "floorplan": {"status": "success", "elapsed_sec": 1.25},
                "routing": {"status": "success", "elapsed_sec": 2.5},
            },
        }
        records = aes13_flow.build_design_performance_records(
            summary,
            run_id="run-1",
            cache_mode="warm",
            performance=performance,
            evidence=evidence,
            input_manifest_sha256="d" * 64,
            e2e_wall_sec=4.0,
        )
        self.assertEqual([record["stage"] for record in records], ["iFP", "iRT", "e2e"])
        self.assertTrue(all(record["repeat"] == 1 for record in records))
        self.assertTrue(all(record["comparable"] is False for record in records))
        self.assertTrue(all(record["exclusive_host"] is False for record in records))
        self.assertTrue(all(record["user_cpu_sec"] == 0.0 for record in records))

        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "performance_profile.jsonl"
            profile = aes13_flow.write_performance_profile(path, records)
            self.assertEqual(profile["path"], str(path.resolve()))
            loaded = [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines()]
            self.assertEqual(loaded, records)
            invalid = dict(records[0])
            invalid.pop("binary_sha256")
            with self.assertRaisesRegex(ValueError, "binary_sha256"):
                aes13_flow.write_performance_profile(path, [invalid])

    def test_resumed_stage_does_not_create_fake_timing_or_e2e(self) -> None:
        performance = aes13_flow.resolve_performance_contract({"threads": 8}, None)
        evidence = {
            "hostname": "test-host",
            "binary": {"sha256": "a" * 64},
            "build_manifest": {"sha256": "b" * 64},
            "hardware_manifest": {"sha256": "c" * 64},
            "exclusive_host": False,
            "comparable": False,
            "non_comparable_reason": performance["reason"],
        }
        records = aes13_flow.build_design_performance_records(
            {
                "design": "aes",
                "status": "success",
                "stages": {
                    "floorplan": {"status": "skipped"},
                    "routing": {"status": "success", "elapsed_sec": 1.0},
                },
            },
            run_id="resume-run",
            cache_mode="warm",
            performance=performance,
            evidence=evidence,
            input_manifest_sha256="d" * 64,
            e2e_wall_sec=1.5,
        )
        self.assertEqual([record["stage"] for record in records], ["iRT"])


if __name__ == "__main__":
    unittest.main()
