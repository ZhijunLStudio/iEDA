#!/usr/bin/env python3
"""Inventory RCX/SPEF resources for P0 signoff planning."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


PDKS = ("sky130", "nangate45", "asap7", "ics55")


def files(root: Path, pattern: str) -> list[str]:
    if not root.exists():
        return []
    return sorted(str(path) for path in root.rglob(pattern) if path.is_file() and path.stat().st_size > 0)


def synthetic_manifest_files(flow_root: Path) -> list[str]:
    return files(flow_root, "*synthetic_rcx_manifest.json")


def trusted_foundry_files(paths: list[str], foundry_root: Path) -> list[str]:
    foundry_prefix = str(foundry_root.resolve())
    return [path for path in paths if str(Path(path).resolve()).startswith(foundry_prefix)]


def inventory(foundry_root: Path, repo_root: Path) -> dict:
    result = {
        "schema": "c-rcx-inventory/v1",
        "foundry_root": str(foundry_root),
        "pdks": {},
    }
    for pdk in PDKS:
        pdk_root = foundry_root / pdk
        flow_root = repo_root / "benchmarks" / "flows" / "rcx" / pdk
        itf_files = files(pdk_root, "*.itf") + files(flow_root, "*.itf")
        captab_files = files(pdk_root, "*.captab") + files(flow_root, "*.captab")
        spef_files = files(pdk_root, "*.spef") + files(flow_root, "*.spef")
        openrcx_rules = files(pdk_root, "rcx_patterns.rules") + files(flow_root, "rcx_patterns.rules")
        mapping_files = files(flow_root, "layer_mapping.txt")
        synthetic_manifests = synthetic_manifest_files(flow_root)
        foundry_itf_files = trusted_foundry_files(itf_files, foundry_root)
        foundry_captab_files = trusted_foundry_files(captab_files, foundry_root)
        result["pdks"][pdk] = {
            "itf_files": itf_files,
            "captab_files": captab_files,
            "spef_files": spef_files,
            "openrcx_rules": openrcx_rules,
            "mapping_files": mapping_files,
            "synthetic_rcx_manifests": synthetic_manifests,
            "synthetic_ircx_ready": bool(itf_files and captab_files and mapping_files and synthetic_manifests),
            "foundry_trusted_ircx_ready": bool(foundry_itf_files and foundry_captab_files and mapping_files),
            "trusted_ircx_ready": bool(foundry_itf_files and foundry_captab_files and mapping_files),
            "fallback_available": bool(spef_files or openrcx_rules),
            "gaps": [
                gap
                for gap, missing in (
                    ("missing_itf", not itf_files),
                    ("missing_captab", not captab_files),
                    ("missing_mapping", not mapping_files),
                )
                if missing
            ],
        }
    return result


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--foundry-root", type=Path, default=Path("/home/lxq/AiEDA/Foundary"))
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--output", type=Path, default=Path("benchmarks/flows/rcx/rcx_resource_inventory.json"))
    args = parser.parse_args()

    payload = inventory(args.foundry_root, args.repo_root)
    output = args.output if args.output.is_absolute() else args.repo_root / args.output
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    print(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
