#!/usr/bin/env python3
"""Reproducible AES 13-design synthesis and iEDA physical-design flow."""

from __future__ import annotations

import argparse
import concurrent.futures
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import time
from dataclasses import dataclass
from datetime import datetime
from functools import lru_cache
from pathlib import Path
from typing import Iterable


REPO_ROOT = Path(__file__).resolve().parents[2]
BENCHMARK_ROOT = REPO_ROOT / "benchmarks"
DESIGNS_ROOT = BENCHMARK_ROOT / "designs"
OUTPUT_ROOT = BENCHMARK_ROOT / "results" / "aes13"
FOUNDRY_ROOT = Path("/home/lxq/AiEDA/Foundary")
IEDA_BIN = REPO_ROOT / "bin" / "iEDA"
YOSYS_BIN = Path("/home/lxq/AiEDA/micromamba/envs/ieda3d/bin/yosys")
KLAYOUT_BIN = shutil.which("klayout")
BUILD_LIB = Path("/home/lxq/AiEDA/micromamba/envs/ieda-build/lib")
FLOW_ARTIFACT_VERSION = 2

if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))

from benchmarks.qor.quality_metrics import build_quality_summary  # noqa: E402
from benchmarks.qor.validate_qor import validate_summary  # noqa: E402
RTL_ROOT = Path(
    "/home/lxq/AiEDA/HS-3D_Problem/baseline/Open3DBench/"
    "OpenROAD-3D/flow/designs/src/aes"
)
RTL_FILES = (
    RTL_ROOT / "aes_cipher_top.v",
    RTL_ROOT / "aes_key_expand_128.v",
    RTL_ROOT / "aes_rcon.v",
    RTL_ROOT / "aes_sbox.v",
)

AES13_DESIGNS = (
    "aes",
    "aes_sky130_a",
    "aes_sky130_b",
    "aes_sky130_t",
    "aes_nangate45_a",
    "aes_nangate45_b",
    "aes_nangate45_t",
    "aes_asap7_a",
    "aes_asap7_b",
    "aes_asap7_t",
    "aes_ics55_a",
    "aes_ics55_b",
    "aes_ics55_t",
)


@dataclass(frozen=True)
class PDKConfig:
    template: str
    tech_lef: Path
    cell_lefs: tuple[Path, ...]
    sta_libs: tuple[Path, ...]
    synth_dff_lib: Path
    synth_comb_lib: Path
    site: str
    tapcell: str
    endcap: str
    pin_layer: str
    cts_buffers: tuple[str, ...]
    bottom_routing_layer: str
    top_routing_layer: str
    routing_threads: int


PDKS = {
    "sky130": PDKConfig(
        template="sky130_gcd",
        tech_lef=FOUNDRY_ROOT / "sky130/lef/sky130_fd_sc_hd.tlef",
        cell_lefs=(FOUNDRY_ROOT / "sky130/lef/sky130_fd_sc_hd_merged.lef",),
        sta_libs=(FOUNDRY_ROOT / "sky130/lib/sky130_fd_sc_hd__tt_025C_1v80.lib",),
        synth_dff_lib=FOUNDRY_ROOT / "sky130/lib/sky130_fd_sc_hd__tt_025C_1v80.lib",
        synth_comb_lib=FOUNDRY_ROOT / "sky130/lib/sky130_fd_sc_hd__tt_025C_1v80.lib",
        site="unithd",
        tapcell="sky130_fd_sc_hd__tap_1",
        endcap="sky130_fd_sc_hd__fill_1",
        pin_layer="met5",
        cts_buffers=(
            "sky130_fd_sc_hd__buf_1",
            "sky130_fd_sc_hd__buf_2",
            "sky130_fd_sc_hd__buf_4",
            "sky130_fd_sc_hd__buf_8",
        ),
        bottom_routing_layer="met1",
        top_routing_layer="met5",
        routing_threads=64,
    ),
    "nangate45": PDKConfig(
        template="nangate45_gcd",
        tech_lef=FOUNDRY_ROOT / "nangate45/lef/NangateOpenCellLibrary.tech.lef",
        cell_lefs=(FOUNDRY_ROOT / "nangate45/lef/NangateOpenCellLibrary.macro.mod.lef",),
        sta_libs=(FOUNDRY_ROOT / "nangate45/lib/NangateOpenCellLibrary_typical.lib",),
        synth_dff_lib=FOUNDRY_ROOT / "nangate45/lib/NangateOpenCellLibrary_typical.lib",
        synth_comb_lib=FOUNDRY_ROOT / "nangate45/lib/NangateOpenCellLibrary_typical.lib",
        site="FreePDK45_38x28_10R_NP_162NW_34O",
        tapcell="TAPCELL_X1",
        endcap="FILLCELL_X1",
        pin_layer="metal5",
        cts_buffers=("BUF_X1", "BUF_X2", "BUF_X4", "BUF_X8"),
        bottom_routing_layer="metal1",
        top_routing_layer="metal6",
        routing_threads=64,
    ),
    "asap7": PDKConfig(
        template="nangate45_gcd",
        tech_lef=FOUNDRY_ROOT / "asap7/lef/asap7_tech_1x_201209.lef",
        cell_lefs=(FOUNDRY_ROOT / "asap7/lef/asap7sc7p5t_27_R_1x_201211.lef",),
        sta_libs=(
            FOUNDRY_ROOT / "asap7/lib/asap7sc7p5t_SIMPLE_RVT_TT_nldm_201020.lib",
            FOUNDRY_ROOT / "asap7/lib/asap7sc7p5t_INVBUF_RVT_TT_nldm_201020.lib",
            FOUNDRY_ROOT / "asap7/lib/asap7sc7p5t_SEQ_RVT_TT_nldm_201020.lib",
        ),
        synth_dff_lib=FOUNDRY_ROOT / "asap7/lib/asap7sc7p5t_SEQ_RVT_TT_nldm_201020.lib",
        synth_comb_lib=FOUNDRY_ROOT / "asap7/lib/asap7sc7p5t_SIMPLE_RVT_TT_nldm_201020.lib",
        site="asap7sc7p5t",
        tapcell="TAPCELL_ASAP7_75t_R",
        endcap="FILLER_ASAP7_75t_R",
        pin_layer="M5",
        cts_buffers=(
            "BUFx2_ASAP7_75t_R",
            "BUFx4_ASAP7_75t_R",
            "BUFx8_ASAP7_75t_R",
        ),
        bottom_routing_layer="M1",
        top_routing_layer="M6",
        routing_threads=8,
    ),
    "ics55": PDKConfig(
        template="ics55_gcd",
        tech_lef=FOUNDRY_ROOT / "ics55/prtech/techLEF/N551P6M_ieda.lef",
        cell_lefs=(
            FOUNDRY_ROOT
            / "ics55/IP/STD_cell/ics55_LLSC_H7C_V1p10C100/"
            "ics55_LLSC_H7CR/lef/ics55_LLSC_H7CR_ieda.lef",
        ),
        sta_libs=(
            FOUNDRY_ROOT
            / "ics55/IP/STD_cell/ics55_LLSC_H7C_V1p10C100/"
            "ics55_LLSC_H7CR/liberty/ics55_LLSC_H7CR_typ_tt_1p2_25_nldm.lib",
        ),
        synth_dff_lib=FOUNDRY_ROOT
        / "ics55/IP/STD_cell/ics55_LLSC_H7C_V1p10C100/"
        "ics55_LLSC_H7CR/liberty/ics55_LLSC_H7CR_typ_tt_1p2_25_nldm.lib",
        synth_comb_lib=FOUNDRY_ROOT
        / "ics55/IP/STD_cell/ics55_LLSC_H7C_V1p10C100/"
        "ics55_LLSC_H7CR/liberty/ics55_LLSC_H7CR_typ_tt_1p2_25_nldm.lib",
        site="core7",
        tapcell="FILLTAPH7R",
        endcap="FILLTAPH7R",
        pin_layer="MET3",
        cts_buffers=("BUFX1H7R", "BUFX2H7R", "BUFX4H7R", "BUFX8H7R"),
        bottom_routing_layer="MET1",
        top_routing_layer="MET6",
        routing_threads=64,
    ),
}


@dataclass(frozen=True)
class Stage:
    name: str
    script: str
    expected: str | None = None
    required: bool = True


STAGES = (
    Stage("floorplan", "iFP_script/run_iFP.tcl", "iFP_result.def"),
    Stage("fanout", "iNO_script/run_iNO_fix_fanout.tcl", "iTO_fix_fanout_result.def"),
    Stage("placement", "iPL_script/run_iPL.tcl", "iPL_result.def"),
    Stage("cts", "iCTS_script/run_iCTS.tcl", "iCTS_result.def"),
    Stage("legalization", "iPL_script/run_iPL_legalization.tcl", "iPL_lg_result.def"),
    Stage("routing", "iRT_script/run_iRT.tcl", "iRT_result.def"),
    Stage("rcx", "custom/run_rcx.tcl"),
    Stage("timing", "custom/run_timing.tcl", "timing/aes_cipher_top.rpt", False),
    Stage("power", "custom/run_power.tcl", "power/aes_cipher_top.pwr", False),
    Stage("metrics", "custom/run_metrics.tcl", "report/wirelength.rpt", False),
    Stage("drc", "iRT_script/run_iRT_DRC.tcl", "report/drc/iRT_drc.rpt", False),
    Stage("filler", "iPL_script/run_iPL_filler.tcl", "iPL_filler_result.def", False),
    Stage("gds", "DB_script/run_def_to_gds_text.tcl", "final.gds", False),
)

FATAL_LOG_PATTERNS = (
    re.compile(r"can not find cell master", re.IGNORECASE),
    re.compile(r"can not open lef file", re.IGNORECASE),
    re.compile(r"segmentation fault", re.IGNORECASE),
    re.compile(r"floating point exception", re.IGNORECASE),
    re.compile(r"std::bad_alloc", re.IGNORECASE),
    re.compile(r"\b(?:run_sta|run_power|read_vcd|init_rcx|run_rcx|report_rcx) failed\b", re.IGNORECASE),
    re.compile(r"failed to (?:read SPEF|calculate VCD activity|parse VCD)", re.IGNORECASE),
    re.compile(r"VCD (?:file does not exist|scope not found|path is empty|file has no root scope)", re.IGNORECASE),
)

TARGET_UTILIZATION = {"a": 0.35, "b": 0.30, "t": 0.25, "baseline": 0.30}
MIN_CORE_SIDE = {"sky130": 500.0, "nangate45": 160.0, "asap7": 70.0, "ics55": 180.0}
CORE_MARGIN = {"sky130": 40.0, "nangate45": 20.0, "asap7": 10.0, "ics55": 20.0}


def load_design(name: str) -> dict:
    path = DESIGNS_ROOT / name / "design.json"
    if not path.is_file():
        raise FileNotFoundError(f"Missing design config: {path}")
    with path.open(encoding="utf-8") as stream:
        return json.load(stream)


def design_pdk(name: str, config: dict) -> str:
    if name == "aes":
        return "sky130"
    return str(config["pdk"])


def strategy_for(name: str) -> str:
    if name == "aes":
        return "baseline"
    return name.rsplit("_", 1)[-1]


def check_inputs(names: Iterable[str], synthesize: bool) -> None:
    missing = []
    for path in (IEDA_BIN,):
        if not path.is_file():
            missing.append(path)
    if synthesize:
        for path in (YOSYS_BIN, *RTL_FILES):
            if not path.is_file():
                missing.append(path)
    for name in names:
        config = load_design(name)
        pdk = PDKS[design_pdk(name, config)]
        for path in (pdk.tech_lef, *pdk.cell_lefs, *pdk.sta_libs):
            if not path.is_file():
                missing.append(path)
    if missing:
        raise FileNotFoundError("Missing required inputs:\n" + "\n".join(map(str, missing)))


def synthesize_design(name: str, config: dict, output_dir: Path, timeout: int) -> Path:
    pdk_name = design_pdk(name, config)
    pdk = PDKS[pdk_name]
    netlist_dir = DESIGNS_ROOT / name / "netlist"
    netlist_dir.mkdir(parents=True, exist_ok=True)
    netlist = netlist_dir / "aes_cipher_top.v"
    synth_log_dir = output_dir / "synthesis"
    synth_log_dir.mkdir(parents=True, exist_ok=True)
    synth_log = synth_log_dir / "yosys.log"

    commands = [*(f"read_verilog {path}" for path in RTL_FILES)]
    commands.extend(
        (
            "hierarchy -check -top aes_cipher_top",
            "synth -top aes_cipher_top -flatten",
            f"dfflibmap -liberty {pdk.synth_dff_lib}",
        )
    )
    abc_fast = " -fast" if pdk_name == "asap7" else ""
    commands.append(f"abc{abc_fast} -liberty {pdk.synth_comb_lib}")
    commands.extend(
        (
            "setundef -zero",
            "splitnets -ports",
            "clean -purge",
            f"write_verilog -noattr {netlist}",
            "stat",
        )
    )
    command_text = "; ".join(commands)
    print(f"  [synthesis] {name}: {pdk_name}/{strategy_for(name)}", flush=True)
    result = subprocess.run(
        [str(YOSYS_BIN), "-q", "-l", str(synth_log), "-p", command_text],
        cwd=REPO_ROOT,
        text=True,
        capture_output=True,
        timeout=timeout,
        check=False,
    )
    if result.returncode != 0 or not netlist.is_file() or netlist.stat().st_size == 0:
        details = (result.stdout + "\n" + result.stderr).strip()
        raise RuntimeError(f"Yosys failed for {name}; see {synth_log}\n{details[-2000:]}")
    return netlist


def read_lef_cell_areas(lefs: Iterable[Path]) -> dict[str, float]:
    areas: dict[str, float] = {}
    size_pattern = re.compile(r"^\s*SIZE\s+([0-9.]+)\s+BY\s+([0-9.]+)\s*;")
    for lef in lefs:
        current_macro = None
        with lef.open(encoding="utf-8", errors="replace") as stream:
            for line in stream:
                stripped = line.strip()
                if stripped.startswith("MACRO "):
                    current_macro = stripped.split(maxsplit=1)[1]
                    continue
                if current_macro:
                    match = size_pattern.match(line)
                    if match:
                        areas[current_macro] = float(match.group(1)) * float(match.group(2))
                        current_macro = None
    return areas


def netlist_cell_counts(netlist: Path) -> dict[str, int]:
    instance_pattern = re.compile(
        r"^\s*([A-Za-z_][A-Za-z0-9_$]*)\s+"
        r"(?:\\\S+|[A-Za-z_][A-Za-z0-9_$]*)\s*\(",
        re.MULTILINE,
    )
    ignored = {"module", "function", "task", "if", "for", "while", "case"}
    text = netlist.read_text(encoding="utf-8", errors="replace")
    defined_modules = set(
        re.findall(r"^\s*module\s+([A-Za-z_][A-Za-z0-9_$]*)", text, re.MULTILINE)
    )
    counts: dict[str, int] = {}
    for cell_type in instance_pattern.findall(text):
        if cell_type in ignored or cell_type in defined_modules:
            continue
        counts[cell_type] = counts.get(cell_type, 0) + 1
    return counts


def compute_floorplan(name: str, pdk_name: str, pdk: PDKConfig, netlist: Path) -> dict:
    areas = read_lef_cell_areas(pdk.cell_lefs)
    counts = netlist_cell_counts(netlist)
    unknown = sorted(cell_type for cell_type in counts if cell_type not in areas)
    if unknown:
        preview = ", ".join(unknown[:20])
        raise RuntimeError(
            f"{name}: {len(unknown)} instantiated cell types are absent from {pdk_name} LEF: {preview}"
        )
    cell_area = sum(areas[cell_type] * count for cell_type, count in counts.items())
    if cell_area <= 0:
        raise RuntimeError(f"{name}: unable to calculate positive standard-cell area")
    target = TARGET_UTILIZATION[strategy_for(name)]
    # Reserve 15% in each dimension for CTS, optimization, and legalization growth.
    calculated_side = (cell_area / target) ** 0.5 * 1.15
    core_side = max(MIN_CORE_SIDE[pdk_name], calculated_side)
    margin = CORE_MARGIN[pdk_name]
    die_side = core_side + 2.0 * margin
    return {
        "cell_area_um2": round(cell_area, 3),
        "cell_count": sum(counts.values()),
        "target_utilization": target,
        "die_area": f"0.0 0.0 {die_side:.3f} {die_side:.3f}",
        "core_area": f"{margin:.3f} {margin:.3f} {margin + core_side:.3f} {margin + core_side:.3f}",
        "die_side_um": round(die_side, 3),
        "core_side_um": round(core_side, 3),
    }


@lru_cache(maxsize=None)
def file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def build_input_signature(
    name: str,
    pdk_name: str,
    pdk: PDKConfig,
    netlist: Path,
    run_config: dict,
    evidence_paths: Iterable[Path],
) -> dict:
    config = load_design(name)
    sdc = DESIGNS_ROOT / name / config["inputs"]["sdc"]
    paths = tuple(dict.fromkeys((netlist, IEDA_BIN, sdc, pdk.tech_lef, *pdk.cell_lefs, *pdk.sta_libs, *evidence_paths)))
    return {
        "artifact_version": FLOW_ARTIFACT_VERSION,
        "design": name,
        "pdk": pdk_name,
        "run_config": run_config,
        "inputs": [
            {"path": str(path), "sha256": file_sha256(path)}
            for path in paths
        ],
    }


def build_effective_sdc(
    name: str,
    config: dict,
    pdk: PDKConfig,
    netlist: Path,
    output_dir: Path,
    args: argparse.Namespace,
) -> Path:
    source = DESIGNS_ROOT / name / config["inputs"]["sdc"]
    if args.constraint_policy == "existing":
        return source.resolve()

    text = source.read_text(encoding="utf-8", errors="replace").rstrip()
    clock = config["clocks"][0]
    period = float(clock["period_ns"])
    clock_name = str(clock["name"])
    clock_port = str(clock["port"])
    driving_cell = args.driving_cell or pdk.cts_buffers[0]
    netlist_text = netlist.read_text(encoding="utf-8", errors="replace")
    top = "aes_cipher_top" if netlist.name == "aes_cipher_top.v" else str(config["top"])
    module_match = re.search(
        rf"(?ms)^\s*module\s+{re.escape(top)}\b.*?^\s*endmodule\b",
        netlist_text,
    )
    if module_match is None:
        raise RuntimeError(f"{name}: top module {top!r} was not found in {netlist}")
    module_text = module_match.group(0)

    def ports_for(direction: str) -> list[str]:
        ports = []
        for declaration in re.findall(
            rf"(?m)^\s*{direction}\s+(?:wire\s+|reg\s+)?(?:\[[^\]]+\]\s*)?([^;]+);",
            module_text,
        ):
            for token in declaration.split(","):
                name_token = token.strip().split()[-1].lstrip("\\")
                if name_token:
                    ports.append(name_token)
        return sorted(set(ports))

    input_ports = [port for port in ports_for("input") if port != clock_port]
    output_ports = ports_for("output")
    if not input_ports or not output_ports:
        raise RuntimeError(f"{name}: failed to derive explicit top-level I/O ports from {netlist}")
    input_collection = "[get_ports {" + " ".join(input_ports) + "}]"
    output_collection = "[get_ports {" + " ".join(output_ports) + "}]"
    additions = [
        "",
        "# Added by aes13_flow.py --constraint-policy complete.",
    ]
    if not re.search(r"(?m)^\s*set_input_delay\b", text):
        additions.append(f"set_input_delay {period * args.io_delay_pct:.6g} -clock {clock_name} [all_inputs]")
    if not re.search(r"(?m)^\s*set_output_delay\b", text):
        additions.append(f"set_output_delay {period * args.io_delay_pct:.6g} -clock {clock_name} [all_outputs]")
    if not re.search(r"(?m)^\s*set_clock_uncertainty\b", text):
        additions.append(
            f"set_clock_uncertainty {period * args.clock_uncertainty_pct:.6g} [get_clocks {clock_name}]"
        )
    if not re.search(r"(?m)^\s*set_driving_cell\b", text):
        additions.append(
            f"set_driving_cell -lib_cell {driving_cell} -pin {args.driving_pin} {input_collection}"
        )
    if not re.search(r"(?m)^\s*set_load\b", text):
        additions.append(f"set_load {args.output_load:.6g} {output_collection}")
    additions.extend(
        (
            "",
            f"# iEDA constraint policy: io_delay_pct={args.io_delay_pct:.6g}, "
            f"clock_uncertainty_pct={args.clock_uncertainty_pct:.6g}, "
            f"output_load={args.output_load:.6g}, driving_cell={driving_cell}/{args.driving_pin}",
        )
    )
    effective = output_dir / "inputs/effective.sdc"
    effective.parent.mkdir(parents=True, exist_ok=True)
    effective.write_text(text + "\n" + "\n".join(additions) + "\n", encoding="utf-8")
    return effective.resolve()


def workspace_requires_reset(output_dir: Path, signature: dict, floorplan: dict) -> bool:
    workspace = output_dir / "workspace"
    if not workspace.exists():
        return False

    metadata_path = workspace / "input_signature.json"
    if metadata_path.is_file():
        try:
            with metadata_path.open(encoding="utf-8") as stream:
                return json.load(stream) != signature
        except (json.JSONDecodeError, OSError):
            return True

    summary_path = output_dir / "summary.json"
    if not summary_path.is_file():
        return True
    try:
        with summary_path.open(encoding="utf-8") as stream:
            previous_summary = json.load(stream)
        previous_count = previous_summary.get("floorplan", {}).get("cell_count")
    except (json.JSONDecodeError, OSError):
        return True
    return previous_count != floorplan["cell_count"]


def replace_json_strings(value, replacements: dict[str, str]):
    if isinstance(value, dict):
        return {key: replace_json_strings(item, replacements) for key, item in value.items()}
    if isinstance(value, list):
        return [replace_json_strings(item, replacements) for item in value]
    if isinstance(value, str):
        result = value
        for old, new in replacements.items():
            result = result.replace(old, new)
        return result
    return value


def configure_asap7(workspace: Path) -> None:
    script_dir = workspace / "script"
    config_dir = workspace / "iEDA_config"
    path_tcl = """# ASAP7 paths are supplied by aes13_flow.py.
set TECH_LEF_PATH $::env(TECH_LEF_PATH)
set LEF_PATH $::env(LEF_PATH)
set LIB_PATH $::env(LIB_PATH)
set LIB_PATH_FIXFANOUT ${LIB_PATH}
set LIB_PATH_DRV ${LIB_PATH}
set LIB_PATH_HOLD ${LIB_PATH}
set LIB_PATH_SETUP ${LIB_PATH}
set SDC_PATH $::env(SDC_FILE)
if {[info exists ::env(SPEF_FILE)]} { set SPEF_PATH $::env(SPEF_FILE) }
"""
    (script_dir / "DB_script/db_path_setting.tcl").write_text(path_tcl, encoding="ascii")

    tracks = """# ASAP7 1x routing tracks (database units).
gern_track -layer M1 -x_start 18 -x_step 36 -y_start 18 -y_step 36
gern_track -layer M2 -x_start 18 -x_step 36 -y_start 18 -y_step 36
gern_track -layer M3 -x_start 18 -x_step 36 -y_start 18 -y_step 36
gern_track -layer M4 -x_start 24 -x_step 48 -y_start 24 -y_step 48
gern_track -layer M5 -x_start 24 -x_step 48 -y_start 24 -y_step 48
gern_track -layer M6 -x_start 32 -x_step 64 -y_start 32 -y_step 64
gern_track -layer M7 -x_start 32 -x_step 64 -y_start 32 -y_step 64
gern_track -layer M8 -x_start 40 -x_step 80 -y_start 40 -y_step 80
gern_track -layer M9 -x_start 40 -x_step 80 -y_start 40 -y_step 80
gern_track -layer Pad -x_start 40 -x_step 80 -y_start 40 -y_step 80
"""
    (script_dir / "iFP_script/module/create_tracks.tcl").write_text(tracks, encoding="ascii")
    pdn = """global_net_connect -net_name VDD -instance_pin_name VDD -is_power 1
global_net_connect -net_name VSS -instance_pin_name VSS -is_power 0
create_grid -layer_name M1 -net_name_power VDD -net_name_ground VSS -width 0.018
"""
    (script_dir / "iFP_script/module/pdn.tcl").write_text(pdn, encoding="ascii")

    # Convert the per-micron values in Foundary/asap7/setRC.tcl to LEF
    # sheet resistance and area capacitance. The source tech LEF omits RC.
    layer_rc = {
        "M1": (2.50002, 0.00631556),
        "M2": (0.435996, 0.00745889),
        "M3": (0.435996, 0.00717667),
        "M4": (0.402672, 0.00474833),
        "M5": (0.352248, 0.00555125),
        "M6": (0.331872, 0.00361719),
        "M7": (0.309504, 0.00415406),
        "M8": (0.297240, 0.00295550),
        "M9": (0.274960, 0.00337425),
    }
    source_tech_lef = PDKS["asap7"].tech_lef
    patched_tech_lef = workspace / "tech/asap7_tech_1x_with_rc.lef"
    patched_tech_lef.parent.mkdir(parents=True, exist_ok=True)
    current_layer = None
    patched_lines = []
    for line in source_tech_lef.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if stripped.startswith("LAYER "):
            current_layer = stripped.split(maxsplit=1)[1]
        if current_layer in layer_rc and stripped == f"END {current_layer}":
            resistance, capacitance = layer_rc[current_layer]
            patched_lines.extend(
                (
                    f"  RESISTANCE RPERSQ {resistance:.8f} ;",
                    f"  CAPACITANCE CPERSQDIST {capacitance:.8f} ;",
                    "  EDGECAPACITANCE 0.0 ;",
                )
            )
            current_layer = None
        patched_lines.append(line)
    patched_tech_lef.write_text("\n".join(patched_lines) + "\n", encoding="ascii")

    ifp_path = script_dir / "iFP_script/run_iFP.tcl"
    ifp = ifp_path.read_text(encoding="utf-8")
    ifp = ifp.replace("auto_place_pins -layer metal5", "auto_place_pins -layer M5")
    ifp = ifp.replace("-tapcell TAPCELL_X1", "-tapcell TAPCELL_ASAP7_75t_R")
    ifp = ifp.replace("-endcap FILLCELL_X1", "-endcap FILLER_ASAP7_75t_R")
    ifp_path.write_text(ifp, encoding="utf-8")

    replacements = {
        "BUF_X8": "BUFx8_ASAP7_75t_R",
        "BUF_X1": "BUFx2_ASAP7_75t_R",
        "FILLCELL_X8": "FILLER_ASAP7_75t_R",
        "FILLCELL_X4": "FILLER_ASAP7_75t_R",
        "FILLCELL_X2": "FILLER_ASAP7_75t_R",
        "FILLCELL_X1": "FILLER_ASAP7_75t_R",
        "metal10": "M7",
        "metal9": "M7",
        "metal8": "M7",
        "metal7": "M7",
        "metal6": "M6",
        "metal5": "M5",
        "metal4": "M4",
        "metal3": "M3",
        "metal2": "M2",
        "metal1": "M1",
    }
    for json_path in config_dir.glob("*.json"):
        if json_path.stat().st_size == 0:
            continue
        with json_path.open(encoding="utf-8") as stream:
            data = json.load(stream)
        data = replace_json_strings(data, replacements)
        if json_path.name == "cts_default_config.json":
            data["routing_layer"] = [4, 5]
            data["max_cap"] = "0.05"
            data["buffer_type"] = [
                "BUFx2_ASAP7_75t_R",
                "BUFx4_ASAP7_75t_R",
                "BUFx8_ASAP7_75t_R",
            ]
        with json_path.open("w", encoding="utf-8") as stream:
            json.dump(data, stream, indent=4)
            stream.write("\n")


def write_custom_scripts(workspace: Path) -> None:
    custom = workspace / "script/custom"
    custom.mkdir(parents=True, exist_ok=True)
    common = """flow_init -config $::env(CONFIG_DIR)/flow_config.json
db_init -config $::env(CONFIG_DIR)/db_default_config.json -output_dir_path $::env(RESULT_DIR)
source $::env(TCL_SCRIPT_DIR)/DB_script/db_path_setting.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lef.tcl
"""
    rcx = common + """def_init -path $::env(RESULT_DIR)/iRT_result.def
init_rcx -config $::env(RCX_CONFIG)
run_rcx
report_rcx
flow_exit
"""
    timing = common + """source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lib.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_sdc.tcl
def_init -path $::env(RESULT_DIR)/iRT_result.def
if {[info exists ::env(SPEF_FILE)]} { db_init -spef_path $::env(SPEF_FILE) }
run_sta -output $::env(RESULT_DIR)/timing/
flow_exit
"""
    power = common + """source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lib.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_sdc.tcl
def_init -path $::env(RESULT_DIR)/iRT_result.def
if {[info exists ::env(SPEF_FILE)]} { db_init -spef_path $::env(SPEF_FILE) }
if {[info exists ::env(VCD_FILE)]} { read_vcd $::env(VCD_FILE) -top_name $::env(VCD_TOP_NAME) }
run_power -output $::env(RESULT_DIR)/power/
flow_exit
"""
    metrics = common + """def_init -path $::env(RESULT_DIR)/iRT_result.def
report_wirelength -path $::env(RESULT_DIR)/report/wirelength.rpt
report_congestion -path $::env(RESULT_DIR)/report/congestion.rpt
flow_exit
"""
    (custom / "run_rcx.tcl").write_text(rcx, encoding="ascii")
    (custom / "run_timing.tcl").write_text(timing, encoding="ascii")
    (custom / "run_power.tcl").write_text(power, encoding="ascii")
    (custom / "run_metrics.tcl").write_text(metrics, encoding="ascii")


def configure_pdk_scripts(workspace: Path, pdk: PDKConfig) -> None:
    script_dir = workspace / "script"
    path_tcl = """# PDK paths are supplied by aes13_flow.py.
set TECH_LEF_PATH $::env(TECH_LEF_PATH)
set LEF_PATH $::env(LEF_PATH)
set LIB_PATH $::env(LIB_PATH)
set LIB_PATH_FIXFANOUT ${LIB_PATH}
set LIB_PATH_DRV ${LIB_PATH}
set LIB_PATH_HOLD ${LIB_PATH}
set LIB_PATH_SETUP ${LIB_PATH}
set SDC_PATH $::env(SDC_FILE)
set SDC_FILE $::env(SDC_FILE)
set TAPCELL $::env(TAPCELL)
set ENDCAP $::env(ENDCAP)
if {[info exists ::env(SPEF_FILE)]} { set SPEF_PATH $::env(SPEF_FILE) }
"""
    (script_dir / "DB_script/db_path_setting.tcl").write_text(path_tcl, encoding="ascii")

    ifp_path = script_dir / "iFP_script/run_iFP.tcl"
    ifp = ifp_path.read_text(encoding="utf-8")
    for variable in ("PLACE_SITE", "IO_SITE", "CORNER_SITE"):
        ifp = re.sub(
            rf"(?m)^set {variable}\s+.*$",
            f"set {variable} $::env({variable})",
            ifp,
        )
    ifp = re.sub(
        r"(?m)^auto_place_pins -layer\s+\S+",
        "auto_place_pins -layer $::env(PIN_LAYER)",
        ifp,
    )
    ifp = re.sub(
        r"(?m)^(\s*-tapcell)\s+\S+",
        r"\1 $::env(TAPCELL)",
        ifp,
    )
    ifp = re.sub(
        r"(?m)^(\s*-endcap)\s+\S+",
        r"\1 $::env(ENDCAP)",
        ifp,
    )
    ifp_path.write_text(ifp, encoding="utf-8")

    irt_path = script_dir / "iRT_script/run_iRT.tcl"
    irt = irt_path.read_text(encoding="utf-8")
    irt = re.sub(
        r'-bottom_routing_layer\s+"[^"]+"',
        '-bottom_routing_layer "$::env(BOTTOM_ROUTING_LAYER)"',
        irt,
    )
    irt = re.sub(
        r'-top_routing_layer\s+"[^"]+"',
        '-top_routing_layer "$::env(TOP_ROUTING_LAYER)"',
        irt,
    )
    irt = re.sub(
        r"-thread_number\s+\d+",
        "-thread_number $::env(ROUTING_THREADS)",
        irt,
    )
    irt_path.write_text(irt, encoding="utf-8")

    cts_path = workspace / "iEDA_config/cts_default_config.json"
    with cts_path.open(encoding="utf-8") as stream:
        cts_config = json.load(stream)
    cts_config["buffer_type"] = list(pdk.cts_buffers)
    with cts_path.open("w", encoding="utf-8") as stream:
        json.dump(cts_config, stream, indent=4)
        stream.write("\n")


def prepare_workspace(name: str, config: dict, output_dir: Path, reset: bool) -> Path:
    pdk_name = design_pdk(name, config)
    pdk = PDKS[pdk_name]
    template = REPO_ROOT / "scripts/design" / pdk.template
    workspace = output_dir / "workspace"
    if reset and workspace.exists():
        suffix = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
        stale_workspace = output_dir / f"workspace.stale-{suffix}"
        workspace.rename(stale_workspace)
        print(f"  [workspace] archived stale results: {stale_workspace}", flush=True)
    workspace.mkdir(parents=True, exist_ok=True)
    shutil.copytree(template / "script", workspace / "script", dirs_exist_ok=True)
    shutil.copytree(template / "iEDA_config", workspace / "iEDA_config", dirs_exist_ok=True)
    result_dir = workspace / "result"
    for relative in ("logs", "report/drc", "drc", "timing", "power", "visualizations"):
        (result_dir / relative).mkdir(parents=True, exist_ok=True)
    if pdk_name == "asap7":
        configure_asap7(workspace)
    configure_pdk_scripts(workspace, pdk)
    write_custom_scripts(workspace)
    return workspace


def build_environment(
    name: str,
    config: dict,
    netlist: Path,
    workspace: Path,
    route_iterations: int,
    spef_path: Path | None,
    vcd_path: Path | None,
    vcd_top: str | None,
    rcx_config: Path | None,
    sdc_path: Path,
) -> tuple[dict[str, str], dict]:
    pdk_name = design_pdk(name, config)
    pdk = PDKS[pdk_name]
    result_dir = workspace / "result"
    top = "aes_cipher_top" if netlist.name == "aes_cipher_top.v" else config["top"]
    clock = config["clocks"][0]
    floorplan = compute_floorplan(name, pdk_name, pdk, netlist)
    workspace_tech_lef = workspace / "tech/asap7_tech_1x_with_rc.lef"
    tech_lef = workspace_tech_lef if pdk_name == "asap7" else pdk.tech_lef
    print(
        f"  [floorplan] cells={floorplan['cell_count']} area={floorplan['cell_area_um2']} um^2 "
        f"target={floorplan['target_utilization']:.0%} die={floorplan['die_side_um']} um",
        flush=True,
    )
    env = os.environ.copy()
    old_ld = env.get("LD_LIBRARY_PATH", "")
    env.update(
        {
            "WORKSPACE": str(workspace),
            "CONFIG_DIR": str(workspace / "iEDA_config"),
            "IEDA_CONFIG_DIR": str(workspace / "iEDA_config"),
            "RESULT_DIR": str(result_dir),
            "DEF_DIR": str(result_dir),
            "TCL_SCRIPT_DIR": str(workspace / "script"),
            "IEDA_TCL_SCRIPT_DIR": str(workspace / "script"),
            "FOUNDRY_DIR": str(FOUNDRY_ROOT / pdk_name),
            "PDK_DIR": str(FOUNDRY_ROOT / pdk_name),
            "DESIGN_TOP": top,
            "TOP_NAME": top,
            "CLK_PORT_NAME": str(clock["port"]),
            "NETLIST_FILE": str(netlist),
            "SDC_FILE": str(sdc_path),
            "DIE_AREA": floorplan["die_area"],
            "CORE_AREA": floorplan["core_area"],
            "DIE_BBOX": floorplan["die_area"],
            "CORE_BBOX": floorplan["core_area"],
            "CORE_UTIL": str(floorplan["target_utilization"]),
            "USE_FIXED_BBOX": "True",
            "PLACE_SITE": pdk.site,
            "IO_SITE": pdk.site,
            "CORNER_SITE": pdk.site,
            "TAPCELL": pdk.tapcell,
            "TAP_DISTANCE": "14",
            "ENDCAP": pdk.endcap,
            "PIN_LAYER": pdk.pin_layer,
            "BOTTOM_ROUTING_LAYER": pdk.bottom_routing_layer,
            "TOP_ROUTING_LAYER": pdk.top_routing_layer,
            "ROUTING_THREADS": str(pdk.routing_threads),
            "TECH_LEF_PATH": str(tech_lef),
            "LEF_PATH": " ".join(map(str, pdk.cell_lefs)),
            "LIB_PATH": " ".join(map(str, pdk.sta_libs)),
            "TECH_LEF": str(tech_lef),
            "LEF_STDCELL": " ".join(map(str, pdk.cell_lefs)),
            "LIB_STDCELL": " ".join(map(str, pdk.sta_libs)),
            "GDS_FILE": str(result_dir / "final.gds"),
            "IEDA_RT_MAX_ITERATIONS": str(route_iterations),
            "LD_LIBRARY_PATH": f"{BUILD_LIB}:{old_ld}" if old_ld else str(BUILD_LIB),
        }
    )
    if spef_path is not None:
        env["SPEF_FILE"] = str(spef_path)
    if vcd_path is not None:
        env["VCD_FILE"] = str(vcd_path)
        env["VCD_TOP_NAME"] = vcd_top or top
    if rcx_config is not None:
        env["RCX_CONFIG"] = str(rcx_config)
    return env, floorplan


def resolve_design_path(value: str | None, design: str) -> Path | None:
    if value is None:
        return None
    return Path(value.format(design=design)).expanduser().resolve()


def discover_rcx_spef(
    config_path: Path,
    top: str,
    corner: str | None,
    not_before_ns: int,
) -> Path:
    with config_path.open(encoding="utf-8") as stream:
        config = json.load(stream)
    output_value = config.get("output", ".")
    output_dir = Path(output_value)
    if not output_dir.is_absolute():
        output_dir = (config_path.parent / output_dir).resolve()
    candidates = sorted(
        path
        for path in output_dir.glob(f"{top}_*.spef")
        if path.stat().st_size > 0 and path.stat().st_mtime_ns >= not_before_ns
    )
    if corner:
        candidates = [path for path in candidates if f"_{corner}_" in path.name or path.name.startswith(f"{top}_{corner}.")]
    if len(candidates) != 1:
        detail = ", ".join(path.name for path in candidates) or "none"
        raise RuntimeError(
            f"iRCX must produce exactly one SPEF for the selected scenario; found {detail} in {output_dir}. "
            "Use --rcx-corner when the config contains multiple corners."
        )
    return candidates[0].resolve()


def log_has_fatal_error(log_text: str) -> str | None:
    for pattern in FATAL_LOG_PATTERNS:
        match = pattern.search(log_text)
        if match:
            return match.group(0)
    return None


def run_stage(
    stage: Stage,
    workspace: Path,
    env: dict[str, str],
    timeout: int,
    resume: bool,
) -> dict:
    result_dir = workspace / "result"
    expected = result_dir / stage.expected if stage.expected else None
    expected_alternates = []
    if stage.name == "fanout":
        expected_alternates = [result_dir / "iNO_fix_fanout_result.def"]
    if expected and not expected.is_file():
        expected = next((path for path in expected_alternates if path.is_file()), expected)
    if resume and expected and expected.is_file() and expected.stat().st_size > 0:
        print(f"    [{stage.name}] skipped (artifact exists)", flush=True)
        return {"status": "skipped", "artifact": str(expected)}

    script = workspace / "script" / stage.script
    log_file = result_dir / "logs" / f"{stage.name}.log"
    print(f"    [{stage.name}] running", flush=True)
    started_epoch_ns = time.time_ns()
    started = time.monotonic()
    try:
        stage_env = env.copy()
        if stage.name == "legalization":
            stage_env["INPUT_DEF"] = str(result_dir / "iCTS_result.def")
        elif stage.name == "filler":
            stage_env["INPUT_DEF"] = str(result_dir / "iRT_result.def")
        elif stage.name == "gds":
            filler_def = result_dir / "iPL_filler_result.def"
            stage_env["INPUT_DEF"] = str(
                filler_def if filler_def.is_file() else result_dir / "iRT_result.def"
            )
        process = subprocess.run(
            [str(IEDA_BIN), "-script", str(script)],
            cwd=workspace,
            env=stage_env,
            text=True,
            capture_output=True,
            timeout=timeout,
            check=False,
        )
        log_text = process.stdout + "\n" + process.stderr
        returncode = process.returncode
    except subprocess.TimeoutExpired as exc:
        stdout = exc.stdout.decode() if isinstance(exc.stdout, bytes) else (exc.stdout or "")
        stderr = exc.stderr.decode() if isinstance(exc.stderr, bytes) else (exc.stderr or "")
        log_text = stdout + "\n" + stderr + f"\nTIMEOUT after {timeout}s\n"
        returncode = 124
    log_file.write_text(log_text, encoding="utf-8", errors="replace")
    elapsed = time.monotonic() - started
    fatal = log_has_fatal_error(log_text)
    if stage.name == "drc" and expected and not expected.is_file() and "violation_type" in log_text:
        expected.write_text(log_text, encoding="utf-8", errors="replace")
    if expected and not expected.is_file():
        expected = next((path for path in expected_alternates if path.is_file()), expected)
    artifact_ok = expected is None or (expected.is_file() and expected.stat().st_size > 0)
    success = returncode == 0 and fatal is None and artifact_ok
    status = "success" if success else "failed"
    reason = None
    if returncode != 0:
        reason = f"exit code {returncode}"
    elif fatal:
        reason = fatal
    elif not artifact_ok:
        reason = f"missing artifact: {expected}"
    print(f"    [{stage.name}] {status} ({elapsed:.1f}s){': ' + reason if reason else ''}", flush=True)
    return {
        "status": status,
        "elapsed_sec": round(elapsed, 3),
        "started_epoch_ns": started_epoch_ns,
        "returncode": returncode,
        "log": str(log_file),
        "artifact": str(expected) if expected else None,
        "reason": reason,
    }


def render_gds(result_dir: Path, timeout: int) -> dict:
    gds = result_dir / "final.gds"
    png = result_dir / "visualizations/final.png"
    if not gds.is_file():
        return {"status": "failed", "reason": "GDS unavailable"}
    script = result_dir / "visualizations/render_gds.py"
    script.write_text(
        "import pya\n"
        f"gds = {str(gds)!r}\n"
        f"png = {str(png)!r}\n"
        "view = pya.LayoutView()\n"
        "view.load_layout(gds, 0)\n"
        "view.max_hier()\n"
        "view.zoom_fit()\n"
        "view.save_image(png, 1600, 1600)\n",
        encoding="ascii",
    )
    env = os.environ.copy()
    env["QT_QPA_PLATFORM"] = "offscreen"
    process = subprocess.run(
        [sys.executable, str(script)],
        env=env,
        text=True,
        capture_output=True,
        timeout=min(timeout, 300),
        check=False,
    )
    log = result_dir / "logs/render_gds.log"
    log.write_text(process.stdout + "\n" + process.stderr, encoding="utf-8")
    success = process.returncode == 0 and png.is_file() and png.stat().st_size > 0
    return {
        "status": "success" if success else "failed",
        "gds": str(gds),
        "png": str(png),
        "log": str(log),
    }


def collect_artifacts(result_dir: Path) -> dict[str, list[str]]:
    patterns = {
        "def": "*.def",
        "gds": "*.gds*",
        "images": "*.png",
    }
    artifacts = {
        kind: [str(path) for path in sorted(result_dir.rglob(pattern)) if path.is_file()]
        for kind, pattern in patterns.items()
    }
    report_paths = set(result_dir.rglob("*.rpt")) | set(result_dir.rglob("*.pwr"))
    artifacts["reports"] = [str(path) for path in sorted(report_paths) if path.is_file()]
    return artifacts


def write_design_summary(output_dir: Path, summary: dict) -> None:
    json_path = output_dir / "summary.json"
    with json_path.open("w", encoding="utf-8") as stream:
        json.dump(summary, stream, indent=2)
        stream.write("\n")
    artifacts = summary["artifacts"]
    lines = [
        f"# {summary['design']}",
        "",
        f"- Status: {summary['status']}",
        f"- PDK: {summary['pdk']}",
        f"- Strategy: {summary['strategy']}",
        f"- Route iterations: {summary['route_iterations']}",
        f"- QoR quality: {summary['quality']['overall_status']}",
        f"- DEF files: {len(artifacts['def'])}",
        f"- GDS files: {len(artifacts['gds'])}",
        f"- Reports: {len(artifacts['reports'])}",
        f"- Images: {len(artifacts['images'])}",
        "",
        "## Stages",
        "",
        "| Stage | Status | Reason |",
        "|---|---|---|",
    ]
    for stage, data in summary["stages"].items():
        lines.append(f"| {stage} | {data['status']} | {data.get('reason') or ''} |")
    lines.extend(("", "## Artifacts", ""))
    for kind, paths in artifacts.items():
        lines.append(f"### {kind.upper()}")
        lines.append("")
        lines.extend(f"- `{Path(path).relative_to(output_dir)}`" for path in paths)
        lines.append("")
    (output_dir / "summary.md").write_text("\n".join(lines), encoding="utf-8")


def run_design(
    name: str,
    args: argparse.Namespace,
) -> dict:
    config = load_design(name)
    pdk_name = design_pdk(name, config)
    output_root = Path(args.output_root)
    output_dir = output_root / name
    output_dir.mkdir(parents=True, exist_ok=True)
    print(f"\n[{name}] PDK={pdk_name} strategy={strategy_for(name)}", flush=True)
    if args.synthesize:
        netlist = synthesize_design(name, config, output_dir, args.timeout)
    else:
        generated_netlist = DESIGNS_ROOT / name / "netlist/aes_cipher_top.v"
        configured_netlist = DESIGNS_ROOT / name / config["inputs"]["netlist"]
        netlist = generated_netlist if generated_netlist.is_file() else configured_netlist
    pdk = PDKS[pdk_name]
    floorplan = compute_floorplan(name, pdk_name, pdk, netlist)
    sdc_path = build_effective_sdc(name, config, pdk, netlist, output_dir, args)
    spef_path = resolve_design_path(args.spef, name)
    vcd_path = resolve_design_path(args.vcd, name)
    rcx_config = resolve_design_path(args.rcx_config, name)
    ir_report = resolve_design_path(args.ir_report, name)
    for label, path in (
        ("SPEF", spef_path),
        ("VCD", vcd_path),
        ("iRCX config", rcx_config),
        ("IR report", ir_report),
    ):
        if path is not None and (not path.is_file() or path.stat().st_size == 0):
            raise FileNotFoundError(f"{name}: {label} is missing or empty: {path}")
    evidence_paths = tuple(path for path in (sdc_path, spef_path, vcd_path, rcx_config, ir_report) if path is not None)
    run_config = {
        "route_iterations": args.rt_max_iterations,
        "spef": str(spef_path) if spef_path else None,
        "vcd": str(vcd_path) if vcd_path else None,
        "vcd_top": args.vcd_top,
        "rcx_config": str(rcx_config) if rcx_config else None,
        "rcx_corner": args.rcx_corner,
        "ir_report": str(ir_report) if ir_report else None,
        "constraints": {
            "policy": args.constraint_policy,
            "effective_sdc": str(sdc_path),
            "io_delay_pct": args.io_delay_pct,
            "clock_uncertainty_pct": args.clock_uncertainty_pct,
            "output_load": args.output_load,
            "driving_cell": args.driving_cell or pdk.cts_buffers[0],
            "driving_pin": args.driving_pin,
        },
    }
    signature = build_input_signature(name, pdk_name, pdk, netlist, run_config, evidence_paths)
    reset = (not args.resume and (output_dir / "workspace").exists()) or (
        args.resume and workspace_requires_reset(output_dir, signature, floorplan)
    )
    workspace = prepare_workspace(name, config, output_dir, reset)
    with (workspace / "input_signature.json").open("w", encoding="utf-8") as stream:
        json.dump(signature, stream, indent=2)
        stream.write("\n")
    env, floorplan = build_environment(
        name,
        config,
        netlist,
        workspace,
        args.rt_max_iterations,
        spef_path,
        vcd_path,
        args.vcd_top,
        rcx_config,
        sdc_path,
    )
    result_dir = workspace / "result"
    stage_results = {}
    status = "prepared"
    if not args.prepare_only:
        status = "success"
        for stage in STAGES:
            if stage.name == "rcx" and rcx_config is None:
                stage_results[stage.name] = {
                    "status": "not_run",
                    "reason": "external SPEF supplied" if spef_path else "no --rcx-config supplied",
                }
                if args.stop_after == stage.name:
                    status = "partial"
                    break
                continue
            stage_result = run_stage(stage, workspace, env, args.timeout, args.resume and not reset)
            stage_results[stage.name] = stage_result
            if stage.name == "rcx" and stage_result["status"] == "success":
                try:
                    spef_path = discover_rcx_spef(
                        rcx_config,
                        env["DESIGN_TOP"],
                        args.rcx_corner,
                        stage_result["started_epoch_ns"],
                    )
                    env["SPEF_FILE"] = str(spef_path)
                    stage_result["artifact"] = str(spef_path)
                except (OSError, ValueError, json.JSONDecodeError, RuntimeError) as exc:
                    stage_result["status"] = "failed"
                    stage_result["reason"] = str(exc)
            if stage_result["status"] == "failed" and stage.required:
                status = "failed"
                break
            if args.stop_after == stage.name:
                status = "partial"
                break
        if status != "failed" and (result_dir / "final.gds").is_file():
            stage_results["visualization"] = render_gds(result_dir, args.timeout)
            if stage_results["visualization"]["status"] != "success":
                status = "partial"
        if any(item["status"] == "failed" for item in stage_results.values()):
            status = "partial" if status != "failed" else status
    summary = {
        "design": name,
        "pdk": pdk_name,
        "strategy": strategy_for(name),
        "status": status,
        "timestamp": datetime.now().astimezone().isoformat(),
        "netlist": str(netlist),
        "workspace": str(workspace),
        "route_iterations": args.rt_max_iterations,
        "floorplan": floorplan,
        "stages": stage_results,
        "artifacts": collect_artifacts(result_dir),
    }
    spef_source = "ircx" if rcx_config is not None and spef_path is not None else ("provided" if spef_path else "none")
    quality = build_quality_summary(
        design=name,
        pdk=pdk_name,
        strategy=strategy_for(name),
        workspace=workspace,
        repo_root=REPO_ROOT,
        input_signature=signature,
        route_iterations=args.rt_max_iterations,
        quality_gate=args.quality_gate,
        stages=stage_results,
        spef_path=spef_path,
        spef_source=spef_source,
        vcd_path=vcd_path,
        vcd_top=args.vcd_top or env["DESIGN_TOP"],
        ir_report=ir_report,
    )
    validation_errors = validate_summary(quality)
    if validation_errors:
        raise RuntimeError("invalid quality summary: " + "; ".join(validation_errors))
    quality_path = output_dir / "quality_summary.json"
    quality_path.write_text(json.dumps(quality, indent=2) + "\n", encoding="utf-8")
    summary["quality"] = {
        "path": str(quality_path),
        "overall_status": quality["overall_status"],
        "gates": {name: item["status"] for name, item in quality["gates"].items()},
    }
    if args.quality_gate == "strict" and quality["overall_status"] != "pass":
        summary["status"] = "failed"
        summary["quality"]["reason"] = "one or more strict quality gates failed"
    write_design_summary(output_dir, summary)
    return summary


def write_batch_summary(summaries: list[dict], output_root: Path) -> None:
    output_root.mkdir(parents=True, exist_ok=True)
    batch = {
        "timestamp": datetime.now().astimezone().isoformat(),
        "design_count": len(summaries),
        "summaries": summaries,
    }
    with (output_root / "summary.json").open("w", encoding="utf-8") as stream:
        json.dump(batch, stream, indent=2)
        stream.write("\n")
    lines = [
        "# AES 13-version iEDA results",
        "",
        "| Design | PDK | Strategy | Status | DEF | GDS | Reports | PNG |",
        "|---|---|---|---|---:|---:|---:|---:|",
    ]
    for summary in summaries:
        artifacts = summary["artifacts"]
        lines.append(
            f"| {summary['design']} | {summary['pdk']} | {summary['strategy']} | "
            f"{summary['status']} | {len(artifacts['def'])} | {len(artifacts['gds'])} | "
            f"{len(artifacts['reports'])} | {len(artifacts['images'])} |"
        )
    lines.extend(
        (
            "",
            "Required reports are under each design's `workspace/result/report`, "
            "`workspace/result/timing`, and `workspace/result/power` directories.",
        )
    )
    (output_root / "summary.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--design",
        action="append",
        choices=AES13_DESIGNS,
        help="Run one design; repeat for multiple designs. Defaults to all 13.",
    )
    parser.add_argument("--no-synthesis", dest="synthesize", action="store_false")
    parser.add_argument("--prepare-only", action="store_true")
    parser.add_argument("--resume", action="store_true")
    parser.add_argument("--stop-after", choices=[stage.name for stage in STAGES])
    parser.add_argument("--timeout", type=int, default=7200, help="Per-stage timeout in seconds")
    parser.add_argument("--jobs", type=int, default=1, help="Number of designs to run concurrently")
    parser.add_argument("--rt-max-iterations", type=int, default=1)
    parser.add_argument("--spef", help="SPEF path; {design} is expanded for batch runs")
    parser.add_argument("--rcx-config", help="iRCX JSON config; {design} is expanded for batch runs")
    parser.add_argument("--rcx-corner", help="Select one iRCX corner when a config emits multiple SPEFs")
    parser.add_argument("--vcd", help="VCD path; {design} is expanded for batch runs")
    parser.add_argument("--vcd-top", help="VCD hierarchy scope, for example tb/dut/aes_cipher_top")
    parser.add_argument("--ir-report", help="Existing iIR report used as signoff evidence")
    parser.add_argument("--constraint-policy", choices=("complete", "existing"), default="complete")
    parser.add_argument("--io-delay-pct", type=float, default=0.20)
    parser.add_argument("--clock-uncertainty-pct", type=float, default=0.05)
    parser.add_argument("--output-load", type=float, default=0.01, help="Output load in the Liberty capacitance unit")
    parser.add_argument("--driving-cell", help="Override the PDK-specific input driving buffer")
    parser.add_argument("--driving-pin", default="Y", help="Driving cell output pin")
    parser.add_argument("--quality-gate", choices=("report", "strict"), default="report")
    parser.add_argument("--output-root", type=Path, default=OUTPUT_ROOT)
    parser.set_defaults(synthesize=True)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    names = tuple(args.design or AES13_DESIGNS)
    args.output_root = args.output_root.expanduser().resolve()
    if args.rt_max_iterations < 1:
        raise ValueError("--rt-max-iterations must be at least 1")
    if args.spef and args.rcx_config:
        raise ValueError("--spef and --rcx-config are mutually exclusive")
    if args.vcd_top and not args.vcd:
        raise ValueError("--vcd-top requires --vcd")
    if not 0.0 <= args.io_delay_pct < 1.0:
        raise ValueError("--io-delay-pct must be in [0, 1)")
    if not 0.0 <= args.clock_uncertainty_pct < 1.0:
        raise ValueError("--clock-uncertainty-pct must be in [0, 1)")
    if args.output_load < 0.0:
        raise ValueError("--output-load must be non-negative")
    check_inputs(names, args.synthesize)
    args.output_root.mkdir(parents=True, exist_ok=True)
    if args.jobs < 1:
        raise ValueError("--jobs must be at least 1")

    failures = 0

    def run_safely(name: str) -> dict:
        nonlocal failures
        try:
            return run_design(name, args)
        except Exception as exc:
            failures += 1
            print(f"[{name}] ERROR: {exc}", file=sys.stderr, flush=True)
            return {
                "design": name,
                "pdk": load_design(name).get("pdk", "sky130"),
                "strategy": strategy_for(name),
                "status": "error",
                "error": str(exc),
                "stages": {},
                "artifacts": {"def": [], "gds": [], "reports": [], "images": []},
            }

    if args.jobs == 1:
        summaries = [run_safely(name) for name in names]
    else:
        by_name = {}
        with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as executor:
            futures = {executor.submit(run_safely, name): name for name in names}
            for future in concurrent.futures.as_completed(futures):
                name = futures[future]
                by_name[name] = future.result()
        summaries = [by_name[name] for name in names]
    write_batch_summary(summaries, args.output_root)
    print(f"\nSummary: {args.output_root / 'summary.md'}", flush=True)
    return 1 if failures or any(item["status"] == "failed" for item in summaries) else 0


if __name__ == "__main__":
    raise SystemExit(main())
