#!/usr/bin/env python3

import json
import tempfile
import unittest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from command_contract import (
    CommandContract,
    CommandContractError,
    CommandProduct,
    evaluate_command_result,
    python_return_or_raise,
    run_python_command,
    tcl_rc,
)


class CommandContractTest(unittest.TestCase):
    def test_success_requires_api_dependency_product_and_schema(self):
        with tempfile.TemporaryDirectory() as tmp:
            product_path = Path(tmp) / "report.json"
            product_path.write_text(json.dumps({"schema_version": "demo.v1"}))
            contract = CommandContract(
                name="report_demo",
                allowed_options=frozenset({"-output"}),
                dependencies=("db_loaded",),
                products=(CommandProduct("report", product_path, schema_value="demo.v1"),),
            )

            result = evaluate_command_result(
                contract,
                api_success=True,
                options={"-output": str(product_path)},
                satisfied_dependencies=("db_loaded",),
            )

            self.assertTrue(result.ok)
            self.assertEqual(result.rc, 0)
            self.assertEqual(tcl_rc(result), 1)
            self.assertTrue(python_return_or_raise(result)["ok"])

    def test_unknown_option_is_error_unless_compat_is_explicit(self):
        contract = CommandContract(name="run_demo", allowed_options=frozenset({"-config"}))
        with self.assertRaises(CommandContractError):
            evaluate_command_result(contract, api_success=True, options={"-typo": "x"})

        compat = CommandContract(name="run_demo", allowed_options=frozenset({"-config"}), compat_mode=True)
        result = evaluate_command_result(compat, api_success=True, options={"-typo": "x"})
        self.assertTrue(result.compat_mode)

    def test_failures_propagate_to_tcl_rc_and_python_exception(self):
        contract = CommandContract(name="run_demo", dependencies=("route_done",))
        result = evaluate_command_result(contract, api_success=True, options={}, satisfied_dependencies=())

        self.assertFalse(result.ok)
        self.assertEqual(result.rc, 1)
        self.assertEqual(tcl_rc(result), 0)
        with self.assertRaises(CommandContractError):
            python_return_or_raise(result)

    def test_python_wrapper_does_not_swallow_api_failure(self):
        contract = CommandContract(name="run_demo")
        with self.assertRaisesRegex(CommandContractError, "api failed"):
            run_python_command(contract, lambda: False, options={})


if __name__ == "__main__":
    unittest.main()
