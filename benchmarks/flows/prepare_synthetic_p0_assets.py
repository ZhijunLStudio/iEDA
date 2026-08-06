#!/usr/bin/env python3
"""Prepare synthetic P0 smoke assets for AES module-quality experiments."""

from __future__ import annotations

import argparse
import importlib.util
import json
import subprocess
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
DESIGNS_ROOT = REPO_ROOT / "benchmarks" / "designs"
FLOWS_ROOT = REPO_ROOT / "benchmarks" / "flows"
ACTIVITY_ROOT = REPO_ROOT / "benchmarks" / "activity"
RCX_ROOT = FLOWS_ROOT / "rcx"
FOUNDRY_ROOT = Path("/home/lxq/AiEDA/Foundary")

PDK_TECH_LEF = {
    "sky130": FOUNDRY_ROOT / "sky130/lef/sky130_fd_sc_hd.tlef",
    "nangate45": FOUNDRY_ROOT / "nangate45/lef/NangateOpenCellLibrary.tech.lef",
    "asap7": FOUNDRY_ROOT / "asap7/lef/asap7_tech_1x_201209.lef",
    "ics55": FOUNDRY_ROOT / "ics55/prtech/techLEF/N551P6M.lef",
}


def load_module(path: Path, module_name: str):
    spec = importlib.util.spec_from_file_location(module_name, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"unable to load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def load_design(design: str) -> dict:
    with (DESIGNS_ROOT / design / "design.json").open(encoding="utf-8") as stream:
        return json.load(stream)


def aes12_designs() -> list[str]:
    return sorted(
        path.parent.name
        for path in DESIGNS_ROOT.glob("aes_*_?/design.json")
        if not path.parent.name.startswith("aes_core_")
    )


def physical_netlist_and_top(design: str, config: dict) -> tuple[Path, str]:
    generated = DESIGNS_ROOT / design / "netlist/aes_cipher_top.v"
    if generated.is_file():
        return generated, "aes_cipher_top"
    return DESIGNS_ROOT / design / config["inputs"]["netlist"], str(config["top"])


def prepare_activity(design: str, config: dict, *, cycles: int, max_internal: int) -> dict:
    generator = load_module(FLOWS_ROOT / "generate_synthetic_activity.py", "generate_synthetic_activity")
    netlist, top = physical_netlist_and_top(design, config)
    output_dir = ACTIVITY_ROOT / design
    output_dir.mkdir(parents=True, exist_ok=True)
    text = netlist.read_text(encoding="utf-8", errors="replace")
    signals = generator.parse_netlist_signals_for_top(text, top=top, max_internal=max_internal)
    vcd = output_dir / f"{top}.vcd"
    saif = output_dir / f"{top}.saif"
    stats = generator.write_vcd(vcd, top, signals, max(2, cycles))
    generator.write_saif(saif, top, signals, max(2, cycles))
    manifest = {
        "schema": "synthetic-activity/v1",
        "trusted": False,
        "design": design,
        "pdk": config.get("pdk"),
        "top": top,
        "netlist": str(netlist),
        "vcd": str(vcd),
        "saif": str(saif),
        **stats,
        "note": "Synthetic deterministic toggle activity for iPA smoke only; not RTL/gate simulation signoff stimulus.",
    }
    (output_dir / "activity_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    return manifest


def prepare_rcx(pdk: str) -> dict:
    mapping = RCX_ROOT / pdk / "layer_mapping.txt"
    tech_lef = PDK_TECH_LEF.get(pdk)
    if tech_lef is None or not tech_lef.is_file() or not mapping.is_file():
        return {
            "pdk": pdk,
            "status": "skipped",
            "reason": "missing tech LEF or layer mapping",
            "tech_lef": str(tech_lef) if tech_lef else None,
            "mapping": str(mapping),
        }
    output_dir = RCX_ROOT / pdk
    output_dir.mkdir(parents=True, exist_ok=True)
    cmd = [
        sys.executable,
        str(FLOWS_ROOT / "generate_synthetic_rcx.py"),
        "--pdk",
        pdk,
        "--tech-lef",
        str(tech_lef),
        "--mapping",
        str(mapping),
        "--output-dir",
        str(output_dir),
    ]
    process = subprocess.run(cmd, cwd=REPO_ROOT, text=True, capture_output=True, check=False)
    return {
        "pdk": pdk,
        "status": "success" if process.returncode == 0 else "failed",
        "returncode": process.returncode,
        "stdout": process.stdout.strip().splitlines(),
        "stderr": process.stderr.strip().splitlines(),
        "tech_lef": str(tech_lef),
        "mapping": str(mapping),
        "itf": str(output_dir / f"{pdk}.itf"),
        "captab": str(output_dir / f"{pdk}.captab"),
        "manifest": str(output_dir / f"{pdk}_synthetic_rcx_manifest.json"),
    }


def refresh_rcx_inventory() -> dict:
    inventory_module = load_module(FLOWS_ROOT / "inventory_rcx_resources.py", "inventory_rcx_resources")
    payload = inventory_module.inventory(FOUNDRY_ROOT, REPO_ROOT)
    output = RCX_ROOT / "rcx_resource_inventory.json"
    output.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    return payload


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--design", action="append", dest="designs", help="Design to prepare; default is AES12 non-core set.")
    parser.add_argument("--cycles", type=int, default=96)
    parser.add_argument("--max-internal", type=int, default=1600)
    parser.add_argument("--skip-activity", action="store_true")
    parser.add_argument("--skip-rcx", action="store_true")
    parser.add_argument("--output", type=Path, default=FLOWS_ROOT / "synthetic_p0_assets_manifest.json")
    args = parser.parse_args()

    designs = args.designs or aes12_designs()
    activity: list[dict] = []
    pdks: set[str] = set()
    if not args.skip_activity:
        for design in designs:
            config = load_design(design)
            pdks.add(str(config.get("pdk")))
            activity.append(prepare_activity(design, config, cycles=args.cycles, max_internal=args.max_internal))
    else:
        for design in designs:
            pdks.add(str(load_design(design).get("pdk")))

    rcx = [] if args.skip_rcx else [prepare_rcx(pdk) for pdk in sorted(pdks)]
    inventory = refresh_rcx_inventory()
    payload = {
        "schema": "synthetic-p0-assets/v1",
        "trusted": False,
        "designs": designs,
        "activity": activity,
        "rcx": rcx,
        "rcx_inventory": str(RCX_ROOT / "rcx_resource_inventory.json"),
        "inventory_summary": {
            pdk: {
                "synthetic_ircx_ready": data.get("synthetic_ircx_ready", False),
                "trusted_ircx_ready": data.get("trusted_ircx_ready", False),
                "gaps": data.get("gaps", []),
            }
            for pdk, data in inventory.get("pdks", {}).items()
        },
        "note": "Synthetic assets support smoke validation only; do not treat as foundry/signoff evidence.",
    }
    output = args.output if args.output.is_absolute() else REPO_ROOT / args.output
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    print(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
