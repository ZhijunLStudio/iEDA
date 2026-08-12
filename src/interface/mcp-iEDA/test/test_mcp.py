#!/usr/bin/env python
# -*- encoding: utf-8 -*-
'''
@File : test_mcp.py
@Time : 2025/07/24 12:44:42
@Author : simin tao
@Version : 1.0
@Contact : taosm@pcl.ac.cn
@Desc : test mcp ieda.
'''


import unittest
import os
import sys
import tempfile
import importlib.util
from pathlib import Path
from unittest import mock

current_dir = os.path.split(os.path.abspath(__file__))[0]
root_dir = current_dir.rsplit("/", 1)[0]

sys.path.append(root_dir)

os.environ["iEDA"] = "/home/taosimin/iEDA24/iEDA/scripts/design/sky130_gcd/iEDA"
os.environ["WORKSPACE"] = "/home/taosimin/iEDA24/iEDA/scripts/design/sky130_gcd"

server_path = Path(root_dir) / "src/mcp_ieda/server.py"
server_spec = importlib.util.spec_from_file_location("mcp_ieda_server_under_test", server_path)
server_module = importlib.util.module_from_spec(server_spec)
server_spec.loader.exec_module(server_module)
mcp_write_enabled = server_module.mcp_write_enabled
run_ieda = server_module.run_ieda


class TestRuniEDA(unittest.TestCase):
    def setUp(self):
        self._old_write = os.environ.pop("MCP_IEDA_WRITE", None)

    def tearDown(self):
        if self._old_write is not None:
            os.environ["MCP_IEDA_WRITE"] = self._old_write
        else:
            os.environ.pop("MCP_IEDA_WRITE", None)

    def test_mcp_defaults_to_read_only(self):
        self.assertFalse(mcp_write_enabled())
        with self.assertRaises(PermissionError):
            run_ieda(Path("/tmp/missing_ieda"), Path("/tmp/missing.tcl"))

    def test_run_uses_argv_without_shell_when_authorized(self):
        with tempfile.TemporaryDirectory() as tmp:
            ieda = Path(tmp) / "iEDA"
            script = Path(tmp) / "run.tcl"
            ieda.write_text("#!/bin/sh\n")
            script.write_text("puts ok\n")
            os.environ["MCP_IEDA_WRITE"] = "1"

            with mock.patch.object(server_module.subprocess, "run") as run_mock:
                run_mock.return_value.returncode = 0
                result = run_ieda(ieda, script)

            run_mock.assert_called_once_with([str(ieda), "-script", str(script)], check=False)
            self.assertEqual(result["schema_version"], "ieda.mcp.run_result.v1")
            self.assertTrue(result["ok"])
            self.assertEqual(result["rc"], 0)
            self.assertEqual(result["product_assertion"], "process_rc_zero")

    def test_missing_script_is_error_when_authorized(self):
        with tempfile.TemporaryDirectory() as tmp:
            ieda = Path(tmp) / "iEDA"
            ieda.write_text("#!/bin/sh\n")
            os.environ["MCP_IEDA_WRITE"] = "1"
            with self.assertRaises(FileNotFoundError):
                run_ieda(ieda, Path(tmp) / "missing.tcl")


if __name__ == "__main__":
    suite = unittest.TestLoader().loadTestsFromTestCase(TestRuniEDA)
    unittest.TextTestRunner(verbosity=2).run(suite)
