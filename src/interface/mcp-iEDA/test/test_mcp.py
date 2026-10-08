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

server_path = Path(root_dir) / "src/mcp_ieda/server.py"
server_spec = importlib.util.spec_from_file_location("mcp_ieda_server_under_test", server_path)
server_module = importlib.util.module_from_spec(server_spec)
server_spec.loader.exec_module(server_module)
mcp_write_enabled = server_module.mcp_write_enabled
run_ieda = server_module.run_ieda


class TestRuniEDA(unittest.TestCase):
    def setUp(self):
        self._old_write = os.environ.pop("MCP_IEDA_WRITE", None)
        self._old_workspace = os.environ.pop("MCP_IEDA_WORKSPACE", None)
        self._old_timeout = os.environ.pop("MCP_IEDA_TIMEOUT_SECONDS", None)

    def tearDown(self):
        if self._old_write is not None:
            os.environ["MCP_IEDA_WRITE"] = self._old_write
        else:
            os.environ.pop("MCP_IEDA_WRITE", None)
        if self._old_workspace is not None:
            os.environ["MCP_IEDA_WORKSPACE"] = self._old_workspace
        else:
            os.environ.pop("MCP_IEDA_WORKSPACE", None)
        if self._old_timeout is not None:
            os.environ["MCP_IEDA_TIMEOUT_SECONDS"] = self._old_timeout
        else:
            os.environ.pop("MCP_IEDA_TIMEOUT_SECONDS", None)

    def test_mcp_defaults_to_read_only(self):
        self.assertFalse(mcp_write_enabled())
        with self.assertRaises(PermissionError):
            run_ieda(Path("/tmp/missing_ieda"), Path("/tmp/missing.tcl"))

    def test_run_uses_argv_without_shell_when_authorized(self):
        with tempfile.TemporaryDirectory() as tmp:
            ieda = Path(tmp) / "iEDA"
            script = Path(tmp) / "run.tcl"
            ieda.write_text("#!/bin/sh\n")
            ieda.chmod(0o755)
            script.write_text("puts ok\n")
            os.environ["MCP_IEDA_WRITE"] = "1"
            os.environ["MCP_IEDA_WORKSPACE"] = tmp

            with mock.patch.object(server_module.subprocess, "run") as run_mock:
                run_mock.return_value.returncode = 0
                result = run_ieda(ieda, script)

            run_mock.assert_called_once_with(
                [str(ieda.resolve()), "-script", str(script.resolve())],
                check=False,
                cwd=Path(tmp).resolve(),
                timeout=3600,
            )
            self.assertEqual(result["schema_version"], "ieda.mcp.run_result.v1")
            self.assertTrue(result["ok"])
            self.assertEqual(result["rc"], 0)
            self.assertEqual(result["workspace_root"], str(Path(tmp).resolve()))
            self.assertEqual(result["script_path"], "run.tcl")
            self.assertEqual(result["product_assertion"], "not_asserted")

    def test_missing_script_is_error_when_authorized(self):
        with tempfile.TemporaryDirectory() as tmp:
            ieda = Path(tmp) / "iEDA"
            ieda.write_text("#!/bin/sh\n")
            ieda.chmod(0o755)
            os.environ["MCP_IEDA_WRITE"] = "1"
            os.environ["MCP_IEDA_WORKSPACE"] = tmp
            with self.assertRaises(FileNotFoundError):
                run_ieda(ieda, Path(tmp) / "missing.tcl")

    def test_script_outside_workspace_is_rejected(self):
        with tempfile.TemporaryDirectory() as workspace, tempfile.TemporaryDirectory() as other:
            ieda = Path(workspace) / "iEDA"
            script = Path(other) / "run.tcl"
            ieda.write_text("#!/bin/sh\n")
            ieda.chmod(0o755)
            script.write_text("puts unsafe\n")
            os.environ["MCP_IEDA_WRITE"] = "1"
            os.environ["MCP_IEDA_WORKSPACE"] = workspace
            with self.assertRaises(PermissionError):
                run_ieda(ieda, script)

    def test_missing_workspace_is_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            ieda = Path(tmp) / "iEDA"
            script = Path(tmp) / "run.tcl"
            ieda.write_text("#!/bin/sh\n")
            ieda.chmod(0o755)
            script.write_text("puts ok\n")
            os.environ["MCP_IEDA_WRITE"] = "1"
            with self.assertRaises(PermissionError):
                run_ieda(ieda, script)


if __name__ == "__main__":
    suite = unittest.TestLoader().loadTestsFromTestCase(TestRuniEDA)
    unittest.TextTestRunner(verbosity=2).run(suite)
