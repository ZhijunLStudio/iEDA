#!/usr/bin/env python3
"""Build a deterministic interface silent-success and API-candidate inventory."""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable


SCHEMA_VERSION = "ieda.interface.inventory.v1"

SCAN_DIRS = (
    Path("src/interface/tcl"),
    Path("src/interface/python"),
    Path("src/interface/mcp-iEDA"),
)

API_DIRS = (
    Path("src/operation"),
    Path("src/platform/tool_manager/tool_api"),
)

HIGH_RISK_TOOLS = {
    "place",
    "cts",
    "route",
    "to",
    "sta",
    "report",
    "qor",
    "init",
    "read",
    "write",
    "flow",
}


@dataclass(frozen=True)
class InventoryFinding:
    file: str
    line: int
    mode: str
    tool: str
    pattern: str
    status: str
    severity: str
    test: str
    evidence: str


@dataclass(frozen=True)
class ApiCandidate:
    file: str
    line: int
    layer: str
    tool: str
    class_name: str
    method: str
    signature: str
    interface_status: str


def _repo_path(path: Path, root: Path) -> str:
    return path.relative_to(root).as_posix()


def _iter_source_files(root: Path, dirs: Iterable[Path]) -> Iterable[Path]:
    for rel_dir in dirs:
        abs_dir = root / rel_dir
        if not abs_dir.exists():
            continue
        for path in sorted(abs_dir.rglob("*")):
            if path.is_file() and path.suffix in {".cpp", ".cc", ".cxx", ".h", ".hh", ".hpp", ".py"}:
                yield path


def _mode_for(path: Path) -> str:
    parts = path.as_posix().split("/")
    if "mcp-iEDA" in parts:
        return "mcp"
    if "python" in parts:
        return "python"
    if "tcl" in parts:
        return "tcl"
    return "unknown"


def _tool_for(path: Path) -> str:
    parts = path.as_posix().split("/")
    for marker in ("tcl", "python"):
        if marker in parts:
            index = parts.index(marker)
            if index + 1 < len(parts):
                return parts[index + 1].replace("tcl_", "").replace("py_", "")
    if "mcp-iEDA" in parts:
        return "mcp"
    return "unknown"


def _severity(tool: str, pattern: str) -> str:
    if pattern in {"mcp_shell_execution", "mcp_write_tool_default_enabled"}:
        return "critical"
    if any(token in tool.lower() for token in HIGH_RISK_TOOLS):
        return "high"
    if pattern in {"literal_success_return", "default_check_success", "success_text_without_product"}:
        return "medium"
    return "low"


def _test_name(mode: str, tool: str, pattern: str) -> str:
    return f"interface_{mode}_{tool}_{pattern}_regression"


def _finding(path: Path, root: Path, line_no: int, pattern: str, evidence: str) -> InventoryFinding:
    mode = _mode_for(path)
    tool = _tool_for(path)
    return InventoryFinding(
        file=_repo_path(path, root),
        line=line_no,
        mode=mode,
        tool=tool,
        pattern=pattern,
        status="open",
        severity=_severity(tool, pattern),
        test=_test_name(mode, tool, pattern),
        evidence=evidence.strip(),
    )


def scan_silent_success(root: Path) -> list[InventoryFinding]:
    findings: list[InventoryFinding] = []
    for path in _iter_source_files(root, SCAN_DIRS):
        text = path.read_text(errors="ignore").splitlines()
        for index, raw_line in enumerate(text, start=1):
            line = raw_line.strip()
            compact = re.sub(r"\s+", " ", line)
            if "return 1;" in line:
                pattern = "literal_success_return"
                if "::check" in "".join(text[max(0, index - 8) : index + 1]):
                    pattern = "default_check_success"
                findings.append(_finding(path, root, index, pattern, compact))
            if re.search(r"\breturn\s+true\s*;", line):
                findings.append(_finding(path, root, index, "literal_success_return", compact))
            if re.search(r"\breturn\s+0\s*;", line) and _mode_for(path) == "tcl":
                findings.append(_finding(path, root, index, "literal_failure_return", compact))
            if re.search(r"\{\s*\}", line) and ("::" in line or line.startswith("def ")):
                findings.append(_finding(path, root, index, "empty_implementation", compact))
            if "shell=True" in line:
                findings.append(_finding(path, root, index, "mcp_shell_execution", compact))
            if "successfully" in line and "TextContent" in line and "json.dumps" not in line:
                findings.append(_finding(path, root, index, "success_text_without_product", compact))
            if "not found" in line and "TextContent" in line:
                findings.append(_finding(path, root, index, "missing_input_returns_text", compact))
            if "CMD_CLASS_DEFAULT_DEFINITION" in line:
                findings.append(_finding(path, root, index, "default_check_success_macro", compact))

    return sorted(findings, key=lambda item: (item.severity, item.file, item.line, item.pattern))


def _iter_api_headers(root: Path) -> Iterable[Path]:
    operation_root = root / "src/operation"
    if operation_root.exists():
        for path in sorted(operation_root.glob("*/api/*")):
            if path.is_file() and path.suffix in {".h", ".hh", ".hpp"}:
                yield path
    tool_api_root = root / "src/platform/tool_manager/tool_api"
    if tool_api_root.exists():
        for path in sorted(tool_api_root.glob("*/*")):
            if path.is_file() and path.suffix in {".h", ".hh", ".hpp"}:
                yield path


def _interface_text(root: Path) -> str:
    chunks: list[str] = []
    for path in _iter_source_files(root, SCAN_DIRS):
        chunks.append(path.read_text(errors="ignore"))
    return "\n".join(chunks)


def scan_api_candidates(root: Path) -> list[ApiCandidate]:
    interface_text = _interface_text(root)
    candidates: list[ApiCandidate] = []
    class_name = ""
    in_public = False
    class_re = re.compile(r"\bclass\s+([A-Za-z_][A-Za-z0-9_]*)")
    method_re = re.compile(r"(?:\[\[nodiscard\]\]\s*)?(?:virtual\s+)?[A-Za-z_:<>,~*&\s]+\s+([A-Za-z_][A-Za-z0-9_]*)\s*\([^;{}]*\)\s*(?:const\s*)?;")

    for path in _iter_api_headers(root):
        rel_path = _repo_path(path, root)
        lines = path.read_text(errors="ignore").splitlines()
        for index, raw_line in enumerate(lines, start=1):
            line = raw_line.strip()
            class_match = class_re.search(line)
            if class_match:
                class_name = class_match.group(1)
                in_public = False
            if line.startswith("public:"):
                in_public = True
                continue
            if line.startswith(("private:", "protected:")):
                in_public = False
                continue
            if not in_public or not class_name:
                continue
            method_match = method_re.match(line)
            if not method_match:
                continue
            method = method_match.group(1)
            if method == class_name or method.startswith("~"):
                continue
            if method in {"operator", "begin", "end"}:
                continue
            exposed = method in interface_text or class_name in interface_text
            layer = "operation_api" if "/operation/" in f"/{rel_path}" else "platform_tool_api"
            tool = rel_path.split("/")[2] if layer == "operation_api" else rel_path.split("/")[-2]
            candidates.append(
                ApiCandidate(
                    file=rel_path,
                    line=index,
                    layer=layer,
                    tool=tool,
                    class_name=class_name,
                    method=method,
                    signature=line,
                    interface_status="referenced_by_interface" if exposed else "not_exposed_to_interface",
                )
            )

    return sorted(candidates, key=lambda item: (item.tool, item.file, item.line, item.method))


def build_inventory(root: Path) -> dict:
    findings = scan_silent_success(root)
    candidates = scan_api_candidates(root)
    summary: dict[str, object] = {
        "finding_count": len(findings),
        "api_candidate_count": len(candidates),
        "by_mode": {},
        "by_severity": {},
        "by_api_status": {},
    }
    for finding in findings:
        summary["by_mode"][finding.mode] = summary["by_mode"].get(finding.mode, 0) + 1
        summary["by_severity"][finding.severity] = summary["by_severity"].get(finding.severity, 0) + 1
    for candidate in candidates:
        summary["by_api_status"][candidate.interface_status] = summary["by_api_status"].get(candidate.interface_status, 0) + 1

    return {
        "schema_version": SCHEMA_VERSION,
        "scan_roots": [path.as_posix() for path in SCAN_DIRS],
        "summary": summary,
        "silent_success_findings": [asdict(item) for item in findings],
        "api_candidates": [asdict(item) for item in candidates],
    }


def to_markdown(inventory: dict) -> str:
    lines = [
        "# Interface Silent-Success Inventory",
        "",
        f"Schema: `{inventory['schema_version']}`",
        "",
        "## Summary",
        "",
        f"- Findings: {inventory['summary']['finding_count']}",
        f"- API candidates: {inventory['summary']['api_candidate_count']}",
        f"- By mode: `{json.dumps(inventory['summary']['by_mode'], sort_keys=True)}`",
        f"- By severity: `{json.dumps(inventory['summary']['by_severity'], sort_keys=True)}`",
        f"- By API status: `{json.dumps(inventory['summary']['by_api_status'], sort_keys=True)}`",
        "",
        "## Open Findings",
        "",
        "| Severity | Mode | Tool | File:line | Pattern | Status | Test |",
        "|---|---|---|---|---|---|---|",
    ]
    for item in inventory["silent_success_findings"]:
        lines.append(
            f"| {item['severity']} | {item['mode']} | {item['tool']} | `{item['file']}:{item['line']}` | "
            f"{item['pattern']} | {item['status']} | `{item['test']}` |"
        )
    lines.extend(
        [
            "",
            "## API Candidates",
            "",
            "| Tool | Layer | File:line | Class | Method | Status |",
            "|---|---|---|---|---|---|",
        ]
    )
    for item in inventory["api_candidates"]:
        lines.append(
            f"| {item['tool']} | {item['layer']} | `{item['file']}:{item['line']}` | "
            f"`{item['class_name']}` | `{item['method']}` | {item['interface_status']} |"
        )
    lines.append("")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", default=".", help="Repository root")
    parser.add_argument("--json", dest="json_path", help="Write JSON inventory")
    parser.add_argument("--markdown", dest="markdown_path", help="Write Markdown inventory")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    inventory = build_inventory(root)

    payload = json.dumps(inventory, indent=2, sort_keys=True) + "\n"
    if args.json_path:
        Path(args.json_path).write_text(payload)
    else:
        print(payload, end="")
    if args.markdown_path:
        Path(args.markdown_path).write_text(to_markdown(inventory))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
