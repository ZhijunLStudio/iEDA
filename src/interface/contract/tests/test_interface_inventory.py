#!/usr/bin/env python3

import tempfile
import unittest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from interface_inventory import build_inventory


class InterfaceInventoryTest(unittest.TestCase):
    def test_detects_tcl_python_and_mcp_silent_success(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            tcl_dir = root / "src/interface/tcl/tcl_demo"
            py_dir = root / "src/interface/python/py_demo"
            mcp_dir = root / "src/interface/mcp-iEDA/src/mcp_ieda"
            api_dir = root / "src/operation/iDEMO/api"
            for directory in (tcl_dir, py_dir, mcp_dir, api_dir):
                directory.mkdir(parents=True)

            (tcl_dir / "tcl_demo.cpp").write_text(
                "unsigned CmdDemo::check()\n{\n  return 1;\n}\n"
                "unsigned CmdDemo::exec()\n{\n  do_work();\n  return 1;\n}\n"
            )
            (py_dir / "py_demo.cpp").write_text("bool demo()\n{\n  return true;\n}\n")
            (mcp_dir / "server.py").write_text(
                "subprocess.run(cmd, shell=True, check=True)\n"
                "return [TextContent(type=\"text\", text=\"successfully\")]\n"
            )
            (api_dir / "DEMOAPI.hh").write_text(
                "class DEMOAPI\n{\n public:\n  bool runDemo();\n  int reportDemo() const;\n};\n"
            )

            inventory = build_inventory(root)
            patterns = {item["pattern"] for item in inventory["silent_success_findings"]}
            self.assertIn("literal_success_return", patterns)
            self.assertIn("mcp_shell_execution", patterns)
            self.assertIn("success_text_without_product", patterns)
            self.assertEqual(inventory["summary"]["api_candidate_count"], 2)

    def test_inventory_is_deterministic(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            tcl_dir = root / "src/interface/tcl/tcl_demo"
            tcl_dir.mkdir(parents=True)
            (tcl_dir / "b.cpp").write_text("unsigned B::exec(){ return 1; }\n")
            (tcl_dir / "a.cpp").write_text("unsigned A::exec(){ return 1; }\n")

            first = build_inventory(root)
            second = build_inventory(root)
            self.assertEqual(first, second)


if __name__ == "__main__":
    unittest.main()
