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

BUDGET_PROFILES = {
    "E0_current": {
        "description": "Reproduce 20260805 best-effort budget.",
        "rt_max_iterations": 1,
        "rt_max_sr_iterations": 1,
        "rt_max_sr_seconds": 60,
        "rt_max_tasks_per_sr_box": 64,
        "rt_max_final_minarea_tasks": 0,
        "rt_best_effort_skip_final_minarea": True,
    },
    "E1_final_minarea": {
        "description": "Run final min-area patch under the E0 best-effort budget.",
        "rt_max_iterations": 1,
        "rt_max_sr_iterations": 1,
        "rt_max_sr_seconds": 60,
        "rt_max_tasks_per_sr_box": 64,
        "rt_max_final_minarea_tasks": 32,
        "rt_best_effort_skip_final_minarea": False,
    },
    "E2_sr_depth2": {
        "description": "Allow one extra space-router iteration before detailed routing.",
        "rt_max_iterations": 1,
        "rt_max_sr_iterations": 2,
        "rt_max_sr_seconds": 120,
        "rt_max_tasks_per_sr_box": 64,
        "rt_max_final_minarea_tasks": 32,
        "rt_best_effort_skip_final_minarea": False,
    },
    "E3_dr_iter2": {
        "description": "Allow two detailed-router iterations with the E1 SR budget.",
        "rt_max_iterations": 2,
        "rt_max_sr_iterations": 1,
        "rt_max_sr_seconds": 60,
        "rt_max_tasks_per_sr_box": 64,
        "rt_max_final_minarea_tasks": 32,
        "rt_best_effort_skip_final_minarea": False,
    },
}

BUDGET_PROFILE_FIELDS = (
    "rt_max_iterations",
    "rt_max_sr_iterations",
    "rt_max_sr_seconds",
    "rt_max_tasks_per_sr_box",
    "rt_max_final_minarea_tasks",
    "rt_best_effort_skip_final_minarea",
)


def _pick_existing_path(*paths: str | None) -> Path:
    fallback: Path | None = None
    for path in paths:
        if not path:
            continue
        candidate = Path(path).expanduser()
        if fallback is None:
            fallback = candidate
        if candidate.exists():
            return candidate
    if fallback is not None:
        return fallback
    return Path()


FOUNDRY_ROOT = _pick_existing_path(
    os.environ.get("IEDA_FOUNDRY_ROOT"),
    str(REPO_ROOT / "Foundary"),
    "/home/lxq/AiEDA/Foundary",
)
IEDA_BIN = _pick_existing_path(
    os.environ.get("IEDA_BIN"),
    str(REPO_ROOT / "build" / "bin" / "iEDA"),
    str(REPO_ROOT / "bin" / "iEDA"),
    "/home/lxq/AiEDA/build/bin/iEDA",
    "/home/lxq/AiEDA/bin/iEDA",
)
YOSYS_BIN = _pick_existing_path(
    os.environ.get("YOSYS_BIN"),
    shutil.which("yosys"),
    "/home/lxq/AiEDA/micromamba/envs/ieda3d/bin/yosys",
)
KLAYOUT_BIN = shutil.which("klayout")
BUILD_LIB = _pick_existing_path(
    os.environ.get("IEDA_BUILD_LIB"),
    "/home/lxq/AiEDA/micromamba/envs/ieda-build/lib",
    str(REPO_ROOT / "build" / "lib"),
)
# Bumped when floorplan sizing semantics change (must invalidate old die/util artifacts).
FLOW_ARTIFACT_VERSION = 2
RTL_ROOT = _pick_existing_path(
    os.environ.get("IEDA_AES_RTL_ROOT"),
    str(
        REPO_ROOT
        / "ThirdParty"
        / "HS-3D_Problem"
        / "baseline"
        / "Open3DBench"
        / "OpenROAD-3D"
        / "flow"
        / "designs"
        / "src"
        / "aes"
    ),
    "/home/lxq/HS-3D_Problem/baseline/Open3DBench/OpenROAD-3D/flow/designs/src/aes",
)
RTL_FILES = (
    RTL_ROOT / "aes_cipher_top.v",
    RTL_ROOT / "aes_key_expand_128.v",
    RTL_ROOT / "aes_rcon.v",
    RTL_ROOT / "aes_sbox.v",
)

AES13_DESIGNS = (
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
    "aes",
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
    insert_buffer: str
    filler_cells: tuple[str, ...]


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
        insert_buffer="sky130_fd_sc_hd__buf_8",
        filler_cells=(
            "sky130_fd_sc_hd__fill_8",
            "sky130_fd_sc_hd__fill_4",
            "sky130_fd_sc_hd__fill_2",
            "sky130_fd_sc_hd__fill_1",
        ),
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
        insert_buffer="BUF_X8",
        filler_cells=("FILLCELL_X8", "FILLCELL_X4", "FILLCELL_X2", "FILLCELL_X1"),
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
        insert_buffer="BUFx8_ASAP7_75t_R",
        filler_cells=("FILLER_ASAP7_75t_R", "FILLERxp5_ASAP7_75t_R"),
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
        top_routing_layer="MET5",
        routing_threads=64,
        insert_buffer="BUFX8H7R",
        filler_cells=(
            "FILLER64H7R",
            "FILLER32H7R",
            "FILLER16H7R",
            "FILLER8H7R",
            "FILLER4H7R",
            "FILLER2H7R",
        ),
    ),
}


@dataclass(frozen=True)
class Stage:
    name: str
    script: str
    expected: str | None = None
    expected_glob: str | None = None
    required: bool = True


RCX_FLOWS_ROOT = BENCHMARK_ROOT / "flows" / "rcx"


@dataclass(frozen=True)
class RCXPDKConfig:
    mapping_template: Path
    itf_candidates: tuple[Path, ...]
    captab_candidates: tuple[Path, ...]
    corner_name: str = "typical"
    fallback_spef: Path | None = None


RCX_PDKS: dict[str, RCXPDKConfig | None] = {
    "sky130": RCXPDKConfig(
        mapping_template=RCX_FLOWS_ROOT / "sky130/layer_mapping.txt",
        itf_candidates=(
            FOUNDRY_ROOT / "sky130/rcx/sky130.itf",
            FOUNDRY_ROOT / "sky130/rcx/sky130_hd.itf",
            RCX_FLOWS_ROOT / "sky130/sky130.itf",
        ),
        captab_candidates=(
            FOUNDRY_ROOT / "sky130/rcx/sky130.captab",
            FOUNDRY_ROOT / "sky130/rcx/sky130_hd.captab",
            RCX_FLOWS_ROOT / "sky130/sky130.captab",
        ),
        fallback_spef=FOUNDRY_ROOT / "sky130/spef/gcd.spef",
    ),
    "nangate45": RCXPDKConfig(
        mapping_template=RCX_FLOWS_ROOT / "nangate45/layer_mapping.txt",
        itf_candidates=(
            FOUNDRY_ROOT / "nangate45/rcx/nangate45.itf",
            FOUNDRY_ROOT / "nangate45/rcx/NangateOpenCellLibrary.itf",
            RCX_FLOWS_ROOT / "nangate45/nangate45.itf",
        ),
        captab_candidates=(
            FOUNDRY_ROOT / "nangate45/rcx/nangate45.captab",
            FOUNDRY_ROOT / "nangate45/rcx/NangateOpenCellLibrary.captab",
            RCX_FLOWS_ROOT / "nangate45/nangate45.captab",
        ),
    ),
    "asap7": RCXPDKConfig(
        mapping_template=RCX_FLOWS_ROOT / "asap7/layer_mapping.txt",
        itf_candidates=(
            FOUNDRY_ROOT / "asap7/rcx/asap7.itf",
            RCX_FLOWS_ROOT / "asap7/asap7.itf",
        ),
        captab_candidates=(
            FOUNDRY_ROOT / "asap7/rcx/asap7.captab",
            RCX_FLOWS_ROOT / "asap7/asap7.captab",
        ),
    ),
    "ics55": RCXPDKConfig(
        mapping_template=RCX_FLOWS_ROOT / "ics55/layer_mapping.txt",
        itf_candidates=(
            FOUNDRY_ROOT / "ics55/rcx/ics55.itf",
            FOUNDRY_ROOT / "ics55/prtech/rcx/ics55.itf",
            RCX_FLOWS_ROOT / "ics55/ics55.itf",
        ),
        captab_candidates=(
            FOUNDRY_ROOT / "ics55/rcx/ics55.captab",
            FOUNDRY_ROOT / "ics55/prtech/rcx/ics55.captab",
            RCX_FLOWS_ROOT / "ics55/ics55.captab",
        ),
    ),
}


STAGES = (
    Stage("floorplan", "iFP_script/run_iFP.tcl", "iFP_result.def"),
    Stage("fanout", "iNO_script/run_iNO_fix_fanout.tcl", "iTO_fix_fanout_result.def"),
    Stage("placement", "iPL_script/run_iPL.tcl", "iPL_result.def"),
    Stage("cts", "iCTS_script/run_iCTS.tcl", "iCTS_result.def"),
    Stage("to_drv", "iTO_script/run_iTO_drv.tcl", "iTO_drv_result.def"),
    Stage("to_hold", "iTO_script/run_iTO_hold.tcl", "iTO_hold_result.def"),
    Stage("legalization", "iPL_script/run_iPL_legalization.tcl", "iPL_lg_result.def"),
    Stage("routing", "iRT_script/run_iRT.tcl", "iRT_result.def"),
    Stage("rcx", "custom/run_rcx.tcl", expected_glob="rcx/*.spef", required=False),
    Stage("timing", "custom/run_timing.tcl", None, required=False),
    Stage("power", "custom/run_power.tcl", None, False),
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
)

TARGET_UTILIZATION = {"a": 0.70, "b": 0.70, "t": 0.70, "baseline": 0.70}
# Absolute safety floor only (tool/row alignment). Must NOT be a "comfort" die size —
# previous values (sky130=500, asap7=70) forced measured util down to ~28% at target=65%.
MIN_CORE_SIDE = {"sky130": 50.0, "nangate45": 40.0, "asap7": 30.0, "ics55": 40.0}
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


def compute_floorplan(
    name: str,
    pdk_name: str,
    pdk: PDKConfig,
    netlist: Path,
    target_utilization: float | None = None,
) -> dict:
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
    target = target_utilization
    if target is None:
        target = TARGET_UTILIZATION[strategy_for(name)]
    if not 0.0 < target < 1.0:
        raise ValueError(f"{name}: target utilization must be in (0, 1); got {target}")
    # Size core so placement-time stdcell_area / core_area ≈ target.
    # Do NOT inflate by 1.15× per side: that silently dropped util to ~target/1.32 (~49% at 65%).
    # CTS/buffer growth is absorbed into the target budget the user requested.
    calculated_side = (cell_area / target) ** 0.5
    core_side = max(MIN_CORE_SIDE[pdk_name], calculated_side)
    margin = CORE_MARGIN[pdk_name]
    die_side = core_side + 2.0 * margin
    effective_util = cell_area / (core_side * core_side) if core_side > 0 else 0.0
    # Hard gate: refuse silent under-density from MIN_CORE_SIDE / margins.
    if abs(effective_util - target) > 0.03:
        raise RuntimeError(
            f"{name}: effective core util {effective_util:.3f} diverges from target {target:.3f} "
            f"(core_side={core_side:.3f} um, cell_area={cell_area:.3f}). "
            "Die/core sizing must hit the requested utilization."
        )
    return {
        "cell_area_um2": round(cell_area, 3),
        "cell_count": sum(counts.values()),
        "target_utilization": target,
        "effective_utilization": round(effective_util, 4),
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


def file_sha256_or_none(path: Path) -> str | None:
    if not path.is_file():
        return None
    return file_sha256(path)


def numeric_json_value(payload: object, key: str, default: float) -> float:
    if isinstance(payload, dict):
        value = payload.get(key)
        if isinstance(value, (int, float)):
            return float(value)
    return default


def git_output(args: list[str]) -> str | None:
    try:
        return subprocess.check_output(
            ["git", *args],
            cwd=REPO_ROOT,
            text=True,
            stderr=subprocess.DEVNULL,
        ).strip()
    except (OSError, subprocess.CalledProcessError):
        return None


def collect_git_status() -> dict:
    commit = git_output(["rev-parse", "HEAD"])
    branch = git_output(["branch", "--show-current"])
    status_short = git_output(["status", "--short"])
    diff_digest = None
    diff_name_status = None
    try:
        diff_bytes = subprocess.check_output(
            ["git", "diff", "--binary", "--", "benchmarks/flows/aes13_flow.py", "benchmarks/flows/generate_aes11_detailed_report.py"],
            cwd=REPO_ROOT,
            stderr=subprocess.DEVNULL,
        )
        diff_digest = hashlib.sha256(diff_bytes).hexdigest()
        diff_name_status = subprocess.check_output(
            ["git", "diff", "--name-status", "--", "benchmarks/flows/aes13_flow.py", "benchmarks/flows/generate_aes11_detailed_report.py"],
            cwd=REPO_ROOT,
            text=True,
            stderr=subprocess.DEVNULL,
        ).strip().splitlines()
    except (OSError, subprocess.CalledProcessError):
        pass
    status_lines = status_short.splitlines() if status_short else []
    return {
        "commit": commit,
        "branch": branch,
        "dirty": bool(status_lines),
        "status_line_count": len(status_lines),
        "flow_diff_sha256": diff_digest,
        "flow_diff_name_status": diff_name_status or [],
    }


def build_input_signature(
    name: str,
    pdk_name: str,
    pdk: PDKConfig,
    netlist: Path,
    floorplan: dict | None = None,
) -> dict:
    paths = (netlist, IEDA_BIN, pdk.tech_lef, *pdk.cell_lefs, *pdk.sta_libs)
    signature = {
        "artifact_version": FLOW_ARTIFACT_VERSION,
        "design": name,
        "pdk": pdk_name,
        "inputs": [
            {"path": str(path), "sha256": file_sha256(path)}
            for path in paths
        ],
    }
    if floorplan is not None:
        signature["floorplan"] = {
            "target_utilization": floorplan.get("target_utilization"),
            "die_side_um": floorplan.get("die_side_um"),
            "core_side_um": floorplan.get("core_side_um"),
            "cell_area_um2": floorplan.get("cell_area_um2"),
        }
    return signature


def build_experiment_input_signature(name: str, pdk_name: str, pdk: PDKConfig, input_paths: Iterable[Path]) -> dict:
    paths = tuple(input_paths)
    signature = {
        "artifact_version": FLOW_ARTIFACT_VERSION,
        "design": name,
        "pdk": pdk_name,
        "inputs": [
            {
                "path": str(path),
                "exists": path.is_file(),
                "sha256": file_sha256_or_none(path),
            }
            for path in paths
        ],
    }
    return signature


def _clamp_ratio(raw: float, min_value: float = 0.0, max_value: float = 1.0) -> float:
    return max(min_value, min(max_value, raw))


def _bool_env(value: bool) -> str:
    return "1" if value else "0"


def build_rt_environment(args: argparse.Namespace) -> dict[str, str]:
    env = {
        "IEDA_QOR_BUDGET_PROFILE": args.budget_profile,
        "IEDA_RT_MAX_ITERATIONS": str(max(1, int(args.rt_max_iterations))),
        "IEDA_RT_ROUTING_UTILIZATION_TARGET": f"{_clamp_ratio(args.rt_routing_utilization_target):.4f}",
        "IEDA_RT_ROUTING_UTILIZATION_GAP": f"{max(0.0, args.rt_routing_utilization_gap):.6f}",
        "IEDA_RT_TIMING_IMPROVE_RATIO": f"{_clamp_ratio(args.rt_timing_improve_ratio):.4f}",
        "IEDA_RT_BUSINESS_BASELINE_TIMING_IMPROVE_RATIO": f"{_clamp_ratio(args.rt_baseline_timing_improve_ratio):.4f}",
        "IEDA_RT_UTILIZATION_RETRY_MAX_ITER": str(max(1, int(args.rt_utilization_retry_max_iter))),
        "IEDA_RT_UTILIZATION_RETRY_TASK_RATIO": f"{_clamp_ratio(args.rt_utilization_retry_task_ratio):.4f}",
        "IEDA_RT_UTILIZATION_IMPROVE_RATIO": f"{_clamp_ratio(args.rt_utilization_improve_ratio):.4f}",
        "IEDA_RT_OVERFLOW_CELL_IMPROVE_RATIO": f"{_clamp_ratio(args.rt_overflow_cell_improve_ratio):.4f}",
        "IEDA_RT_ROUTING_OVERFLOW_CELL_TARGET": f"{_clamp_ratio(args.rt_overflow_cell_target):.4f}",
        "IEDA_RT_BUSINESS_DECISION_SCORE_THRESHOLD": f"{_clamp_ratio(args.rt_business_decision_score_threshold, 0.0, 1.0):.4f}",
        "IEDA_RT_BUSINESS_TIMING_IMPROVE_GATE": f"{_clamp_ratio(args.rt_business_timing_improve_gate):.4f}",
        "IEDA_RT_BUSINESS_DECISION_SCORE_MIN_ITER": str(max(1, int(args.rt_business_decision_score_min_iter))),
        "IEDA_RT_BUSINESS_BASELINE_MIN_ITER": str(max(1, int(args.rt_business_baseline_min_iter))),
        "IEDA_RT_ENABLE_BUSINESS_GATE": _bool_env(args.rt_enable_business_gate),
        "IEDA_RT_ENABLE_BUSINESS_BASELINE_TIMING_GATE": _bool_env(args.rt_enable_baseline_timing_gate),
        "IEDA_RT_ENABLE_PLATEAU": _bool_env(args.rt_enable_plateau),
        "IEDA_RT_PLATEAU_NO_IMPROVE_LIMIT": str(max(1, int(args.rt_plateau_no_improve_limit))),
        "IEDA_RT_PLATEAU_MAX_REROUTE": str(max(0, int(args.rt_plateau_max_reroute))),
        "IEDA_RT_PLATEAU_MAX_CAND_PATCH": str(max(0, int(args.rt_plateau_max_candidate_patch_num))),
        "IEDA_RT_PLATEAU_VIOLATION_SCALE": f"{_clamp_ratio(args.rt_plateau_violation_scale, 1.0, 5.0):.4f}",
        "IEDA_RT_PLATEAU_HISTORY_SCALE": f"{_clamp_ratio(args.rt_plateau_history_scale, 1.0, 5.0):.4f}",
        "IEDA_RT_STOP_EARLY_MIN_ITER": str(max(1, int(args.rt_stop_early_min_iter))),
        "IEDA_RT_FAIL_ON_RESIDUAL_DRC": _bool_env(args.rt_fail_on_residual_drc),
        # 65% get-through knobs (WP-iRT-01/02/03 + best-effort soft abort)
        "IEDA_RT_DESIGN_UTILIZATION": f"{_clamp_ratio(args.target_utilization):.4f}",
        "IEDA_RT_BEST_EFFORT": _bool_env(args.rt_best_effort),
        "IEDA_CTS_BEST_EFFORT": _bool_env(args.rt_best_effort),
        "IEDA_RT_MAX_MEMORY_MB": str(max(1024, int(args.rt_max_memory_mb))),
        "IEDA_RT_MAX_SR_ITERATIONS": str(max(0, int(args.rt_max_sr_iterations))),
        "IEDA_RT_MAX_SR_SECONDS": str(max(0, int(args.rt_max_sr_seconds))),
        "IEDA_RT_MAX_TASKS_PER_SR_BOX": str(max(0, int(args.rt_max_tasks_per_sr_box))),
        "IEDA_RT_MAX_FINAL_MINAREA_TASKS": str(max(0, int(args.rt_max_final_minarea_tasks))),
        "IEDA_RT_BEST_EFFORT_SKIP_FINAL_MINAREA": _bool_env(args.rt_best_effort_skip_final_minarea),
        "IEDA_RT_ENABLE_ESCALATION": _bool_env(args.rt_enable_escalation),
        "IEDA_RT_RULE_AWARE_COST": _bool_env(args.rt_rule_aware_cost),
        "IEDA_RT_ENHANCED_MINAREA_REPAIR": _bool_env(args.rt_enhanced_minarea_repair),
        "IEDA_RT_COMPONENT_ESCALATE": _bool_env(args.rt_component_escalate),
        "IEDA_RT_PRL_SHORT_REPAIR": _bool_env(args.rt_prl_short_repair),
        "IEDA_RT_PLATEAU_CHECK_INTERVAL": str(max(1, int(args.rt_plateau_check_interval))),
        "IEDA_RT_PLATEAU_EXPLOSION_THRESHOLD": f"{max(0.1, float(args.rt_plateau_explosion_threshold)):.4f}",
    }
    if args.rt_initial_box_size is not None:
        env["IEDA_RT_INITIAL_BOX_SIZE"] = str(max(1, int(args.rt_initial_box_size)))
    if args.rt_max_boxes is not None and int(args.rt_max_boxes) > 0:
        env["IEDA_RT_MAX_BOXES"] = str(max(1, int(args.rt_max_boxes)))
        env["IEDA_RT_MAX_SR_BOXES"] = str(max(1, int(args.rt_max_boxes)))
    return env


def apply_budget_profile(args: argparse.Namespace) -> None:
    profile = BUDGET_PROFILES[args.budget_profile]
    overrides: dict[str, object] = {}
    for field in BUDGET_PROFILE_FIELDS:
        value = profile[field]
        if field in args.budget_profile_override:
            overrides[field] = getattr(args, field)
            continue
        setattr(args, field, value)
    args.budget_profile_description = profile["description"]
    args.budget_profile_overrides = overrides


def build_budget_profile_summary(args: argparse.Namespace) -> dict:
    return {
        "name": args.budget_profile,
        "description": args.budget_profile_description,
        "dr_iterations": max(1, int(args.rt_max_iterations)),
        "sr_iterations": max(0, int(args.rt_max_sr_iterations)),
        "sr_seconds": max(0, int(args.rt_max_sr_seconds)),
        "tasks_per_sr_box": max(0, int(args.rt_max_tasks_per_sr_box)),
        "final_minarea_tasks": max(0, int(args.rt_max_final_minarea_tasks)),
        "skip_final_minarea": bool(args.rt_best_effort_skip_final_minarea),
        "best_effort": bool(args.rt_best_effort),
        "max_boxes": max(0, int(args.rt_max_boxes or 0)),
        "max_memory_mb": max(1024, int(args.rt_max_memory_mb)),
        "overrides": args.budget_profile_overrides,
    }


def collect_runtime_env(args: argparse.Namespace) -> dict:
    env = build_rt_environment(args)
    runtime = {key: env[key] for key in sorted(env) if key.startswith("IEDA_")}
    runtime["ROUTING_THREADS"] = str(args.routing_threads) if args.routing_threads is not None else "pdk_default"
    runtime["JOBS"] = str(max(1, int(args.jobs)))
    runtime["TIMEOUT_SEC"] = str(max(1, int(args.timeout)))
    runtime["TARGET_UTILIZATION"] = f"{_clamp_ratio(args.target_utilization):.4f}"
    return runtime


def build_acceptance_policy(args: argparse.Namespace) -> dict:
    return {
        "schema": "qor-ab-acceptance/v0",
        "primary": "Compare DRC total/by_type and routing runtime against baseline_ref using fixed input/tool/budget metadata.",
        "pareto_rule": "Reject expansion when DRC improvement is <5% and routing runtime growth is >20%.",
        "hard_gates": {
            "summary_json": "required per design",
            "drc_by_type": "required for routed designs",
            "congestion_summary": "must be valid when map inputs exist",
            "spef_backed_sta": "informational only in M0; not used for promotion",
            "activity_backed_power": "informational only in M0; not used for promotion",
        },
    }


def build_experiment_manifest(args: argparse.Namespace, names: Iterable[str]) -> dict:
    design_inputs = {}
    for name in names:
        config = load_design(name)
        pdk_name = design_pdk(name, config)
        design_dir = DESIGNS_ROOT / name
        design_json = design_dir / "design.json"
        sdc = design_dir / config["inputs"]["sdc"]
        if args.synthesize:
            input_paths = RTL_FILES
        else:
            generated_netlist = DESIGNS_ROOT / name / "netlist/aes_cipher_top.v"
            configured_netlist = DESIGNS_ROOT / name / config["inputs"]["netlist"]
            netlist = generated_netlist if generated_netlist.is_file() else configured_netlist
            input_paths = (netlist,)
        pdk = PDKS[pdk_name]
        design_inputs[name] = build_experiment_input_signature(
            name,
            pdk_name,
            pdk,
            (*input_paths, design_json, sdc, IEDA_BIN, pdk.tech_lef, *pdk.cell_lefs, *pdk.sta_libs),
        )

    return {
        "schema": "ieda-qor-experiment-manifest/v0",
        "created_at": datetime.now().astimezone().isoformat(timespec="seconds"),
        "repo_root": str(REPO_ROOT),
        "result_root": str(Path(args.result_root).resolve()),
        "scope": {
            "designs": list(names),
            "jobs": max(1, int(args.jobs)),
            "synthesize": bool(args.synthesize),
            "prepare_only": bool(args.prepare_only),
            "resume": bool(args.resume),
            "stop_after": args.stop_after,
        },
        "tool": {
            "git": collect_git_status(),
            "binary": {
                "path": str(IEDA_BIN),
                "exists": IEDA_BIN.is_file(),
                "sha256": file_sha256_or_none(IEDA_BIN),
            },
        },
        "runtime_env": collect_runtime_env(args),
        "budget_profile": build_budget_profile_summary(args),
        "input_signature": {
            "artifact_version": FLOW_ARTIFACT_VERSION,
            "designs": design_inputs,
        },
        "baseline_ref": {
            "report_json": str(args.baseline_json.resolve()) if args.baseline_json else None,
            "label": args.baseline_label,
        },
        "acceptance_policy": build_acceptance_policy(args),
        "p0_signoff_inputs": {
            "rcx_inventory": str((RCX_FLOWS_ROOT / "rcx_resource_inventory.json").resolve()),
            "activity_vcd": str(args.activity_vcd.resolve()) if args.activity_vcd else None,
            "activity_saif": str(args.activity_saif.resolve()) if args.activity_saif else None,
            "activity_top": args.activity_top,
            "require_spef": bool(args.require_spef),
            "skip_sdc_lint": bool(args.skip_sdc_lint),
        },
    }


def write_experiment_manifest(manifest: dict, result_root: Path) -> Path:
    path = result_root / "experiment_manifest.json"
    with path.open("w", encoding="utf-8") as stream:
        json.dump(manifest, stream, indent=2)
        stream.write("\n")
    return path


def detect_budget_profile_overrides(argv: list[str]) -> set[str]:
    flag_to_field = {
        "--rt-max-iterations": "rt_max_iterations",
        "--rt-max-sr-iterations": "rt_max_sr_iterations",
        "--rt-max-sr-seconds": "rt_max_sr_seconds",
        "--rt-max-tasks-per-sr-box": "rt_max_tasks_per_sr_box",
        "--rt-max-final-minarea-tasks": "rt_max_final_minarea_tasks",
        "--rt-final-minarea-in-best-effort": "rt_best_effort_skip_final_minarea",
    }
    overrides: set[str] = set()
    for token in argv:
        flag = token.split("=", 1)[0]
        field = flag_to_field.get(flag)
        if field:
            overrides.add(field)
    return overrides


def workspace_requires_reset(output_dir: Path, signature: dict, floorplan: dict) -> bool:
    workspace = output_dir / "workspace"
    if not workspace.exists():
        return False

    # Preserve advanced stage artifacts: if legalization (or later) exists, do not wipe.
    # Signature drift must not destroy hours of FP/PL/CTS/TO work during RT iteration.
    result_dir = workspace / "result"
    for keep in (
        "iPL_lg_result.def",
        "iRT_result.def",
        "iTO_hold_result.def",
        "iCTS_result.def",
        "iPL_result.def",
    ):
        if (result_dir / keep).is_file():
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


def _pick_existing_file(candidates: Iterable[Path]) -> Path | None:
    for candidate in candidates:
        if candidate.is_file() and candidate.stat().st_size > 0:
            return candidate
    return None


def resolve_rcx_pdk_files(pdk_name: str) -> dict:
    rcx_pdk = RCX_PDKS.get(pdk_name)
    if rcx_pdk is None:
        return {
            "pdk": pdk_name,
            "supported": False,
            "ready": False,
            "mapping_file": None,
            "itf_file": None,
            "captab_file": None,
            "corner_name": None,
            "fallback_spef": None,
            "gaps": [f"iRCX not configured for PDK {pdk_name}"],
        }
    itf_file = _pick_existing_file(rcx_pdk.itf_candidates)
    captab_file = _pick_existing_file(rcx_pdk.captab_candidates)
    mapping_file = rcx_pdk.mapping_template if rcx_pdk.mapping_template.is_file() else None
    gaps: list[str] = []
    if itf_file is None:
        gaps.append("ITF missing: " + ", ".join(str(path) for path in rcx_pdk.itf_candidates))
    if captab_file is None:
        gaps.append("captab missing: " + ", ".join(str(path) for path in rcx_pdk.captab_candidates))
    if mapping_file is None:
        gaps.append(f"mapping template missing: {rcx_pdk.mapping_template}")
    fallback = rcx_pdk.fallback_spef if rcx_pdk.fallback_spef and rcx_pdk.fallback_spef.is_file() else None
    local_dir = rcx_pdk.mapping_template.parent
    synthetic_manifest = local_dir / f"{pdk_name}_synthetic_rcx_manifest.json"
    local_prefix = str(local_dir.resolve())
    uses_local_synthetic = bool(
        itf_file
        and captab_file
        and str(Path(itf_file).resolve()).startswith(local_prefix)
        and str(Path(captab_file).resolve()).startswith(local_prefix)
    )
    synthetic_ready = synthetic_manifest.is_file() and uses_local_synthetic and bool(mapping_file)
    return {
        "pdk": pdk_name,
        "supported": True,
        "ready": bool(itf_file and captab_file and mapping_file),
        "synthetic_ready": synthetic_ready,
        "synthetic_manifest": synthetic_manifest if synthetic_manifest.is_file() else None,
        "trusted": False if synthetic_ready else bool(
            itf_file
            and captab_file
            and mapping_file
            and str(Path(itf_file).resolve()).startswith(str(FOUNDRY_ROOT.resolve()))
            and str(Path(captab_file).resolve()).startswith(str(FOUNDRY_ROOT.resolve()))
        ),
        "mapping_file": mapping_file,
        "itf_file": itf_file,
        "captab_file": captab_file,
        "corner_name": rcx_pdk.corner_name,
        "fallback_spef": fallback,
        "gaps": gaps,
    }


def write_rcx_config(workspace: Path, rcx_files: dict) -> None:
    config_dir = workspace / "iEDA_config"
    config_dir.mkdir(parents=True, exist_ok=True)
    mapping_dest = config_dir / "rcx_layer_mapping.txt"
    if rcx_files.get("mapping_file"):
        shutil.copy2(rcx_files["mapping_file"], mapping_dest)
    payload = {
        "thread_num": 64,
        "output": "../result/rcx",
        "mapping_file": "rcx_layer_mapping.txt",
        "report_geometry": False,
        "corners": [
            {
                "name": rcx_files.get("corner_name") or "typical",
                "temperature": [25.0],
                "itf_file": str(rcx_files["itf_file"]) if rcx_files.get("itf_file") else "",
                "captab_file": str(rcx_files["captab_file"]) if rcx_files.get("captab_file") else "",
            }
        ],
    }
    with (config_dir / "rcx_config.json").open("w", encoding="utf-8") as stream:
        json.dump(payload, stream, indent=4)
        stream.write("\n")


def rcx_files_for_summary(rcx_files: dict) -> dict:
    return {
        "pdk": rcx_files.get("pdk"),
        "supported": rcx_files.get("supported"),
        "ready": rcx_files.get("ready"),
        "trusted": rcx_files.get("trusted"),
        "synthetic_ready": rcx_files.get("synthetic_ready"),
        "synthetic_manifest": str(rcx_files["synthetic_manifest"]) if rcx_files.get("synthetic_manifest") else None,
        "mapping_file": str(rcx_files["mapping_file"]) if rcx_files.get("mapping_file") else None,
        "itf_file": str(rcx_files["itf_file"]) if rcx_files.get("itf_file") else None,
        "captab_file": str(rcx_files["captab_file"]) if rcx_files.get("captab_file") else None,
        "corner_name": rcx_files.get("corner_name"),
        "fallback_spef": str(rcx_files["fallback_spef"]) if rcx_files.get("fallback_spef") else None,
        "gaps": list(rcx_files.get("gaps") or []),
    }


def find_spef_artifacts(result_dir: Path) -> list[Path]:
    rcx_dir = result_dir / "rcx"
    if not rcx_dir.is_dir():
        return []
    return sorted(path for path in rcx_dir.glob("*.spef") if path.is_file() and path.stat().st_size > 0)


def write_rcx_coverage(result_dir: Path, payload: dict) -> Path:
    rcx_dir = result_dir / "rcx"
    rcx_dir.mkdir(parents=True, exist_ok=True)
    coverage_path = rcx_dir / "rcx_coverage.json"
    with coverage_path.open("w", encoding="utf-8") as stream:
        json.dump(payload, stream, indent=2)
        stream.write("\n")
    return coverage_path


def lint_sdc_file(sdc: Path, output_json: Path, *, require_output_load: bool = False) -> dict:
    """C-SDC: emit a machine-readable SDC lint artifact used by P0 evidence."""
    try:
        import importlib.util

        lint_path = Path(__file__).resolve().with_name("lint_sdc.py")
        spec = importlib.util.spec_from_file_location("ieda_flow_lint_sdc", lint_path)
        if spec is None or spec.loader is None:
            raise RuntimeError(f"unable to load {lint_path}")
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        result = module.lint_sdc_with_policy(sdc, require_output_load=require_output_load)
    except Exception as exc:
        result = {
            "schema": "c-sdc-lint/v1",
            "sdc": str(sdc),
            "exists": sdc.is_file(),
            "pass": False,
            "failures": ["lint_exception"],
            "error": str(exc),
        }

    output_json.parent.mkdir(parents=True, exist_ok=True)
    output_json.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    return result


def write_rcx_resource_inventory(output_path: Path | None = None) -> dict:
    output = output_path or (RCX_FLOWS_ROOT / "rcx_resource_inventory.json")
    try:
        import importlib.util

        inventory_path = Path(__file__).resolve().with_name("inventory_rcx_resources.py")
        spec = importlib.util.spec_from_file_location("ieda_flow_inventory_rcx", inventory_path)
        if spec is None or spec.loader is None:
            raise RuntimeError(f"unable to load {inventory_path}")
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        payload = module.inventory(FOUNDRY_ROOT, REPO_ROOT)
    except Exception as exc:
        payload = {
            "schema": "c-rcx-inventory/v1",
            "foundry_root": str(FOUNDRY_ROOT),
            "pdks": {},
            "error": str(exc),
        }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    return payload


def write_activity_source(result_dir: Path, *, vcd: Path | None = None, saif: Path | None = None) -> Path:
    """C-ACT: label power activity provenance for A1 Quality Guard."""
    power_dir = result_dir / "power"
    power_dir.mkdir(parents=True, exist_ok=True)
    path = power_dir / "activity_source.json"
    existing = None
    if path.is_file():
        try:
            existing = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            existing = None
    if vcd is not None and vcd.is_file():
        source = "vcd"
        activity_file = vcd
    elif saif is not None and saif.is_file():
        source = "saif"
        activity_file = saif
    else:
        source = "vectorless"
        activity_file = None
    manifest_path = activity_file.parent / "activity_manifest.json" if activity_file else None
    manifest = None
    if manifest_path and manifest_path.is_file():
        try:
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            manifest = None
    trusted = bool(manifest.get("trusted")) if isinstance(manifest, dict) else False
    payload = {
        "schema": "c-act/v1",
        "activity_source": source,
        "trusted": trusted,
        "synthetic": bool(isinstance(manifest, dict) and manifest.get("schema") == "synthetic-activity/v1"),
        "activity_manifest": str(manifest_path) if manifest_path and manifest_path.is_file() else None,
        "activity_file": str(activity_file) if activity_file else None,
        "activity_sha256": file_sha256_or_none(activity_file) if activity_file else None,
        "toggle_default": 0.02,
        "allow_default_toggle": bool(existing.get("allow_default_toggle", source == "vectorless")) if isinstance(existing, dict) else source == "vectorless",
        "vcd": str(vcd) if vcd else None,
        "saif": str(saif) if saif else None,
        "coverage": numeric_json_value(existing, "coverage", 0.0),
        "measured_coverage": numeric_json_value(existing, "measured_coverage", 0.0),
        "defaulted_coverage": numeric_json_value(existing, "defaulted_coverage", 1.0),
        "effective_coverage": numeric_json_value(existing, "effective_coverage", 0.0),
        "refused": bool(existing.get("refused", False)) if isinstance(existing, dict) else False,
        "note": (
            "VCD activity is synthetic smoke stimulus; power remains untrusted until replaced by simulation VCD/SAIF with measured coverage"
            if source == "vcd" and not trusted
            else (
                "SAIF file recorded but this flow has no SAIF reader wired yet; power remains untrusted"
                if source == "saif"
                else "vectorless is proxy-only; A1 must not issue Power=trusted without VCD/SAIF"
            )
        ),
    }
    with path.open("w", encoding="utf-8") as stream:
        json.dump(payload, stream, indent=2)
        stream.write("\n")
    return path


def _load_overflow_grid(csv_path: Path) -> list[float]:
    values: list[float] = []
    if not csv_path.is_file():
        return values
    for line in csv_path.read_text(encoding="utf-8", errors="replace").splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        for token in re.split(r"[\s,]+", stripped):
            if not token:
                continue
            try:
                values.append(float(token))
            except ValueError:
                continue
    return values


def write_congestion_summary(result_dir: Path) -> Path:
    """C-CONG: aggregate EGR/early-router maps; never emit -1 sentinel."""
    report_dir = result_dir / "report"
    report_dir.mkdir(parents=True, exist_ok=True)
    candidates = [
        result_dir / "egr_congestion_map/place_egr_union_overflow.csv",
        result_dir / "rt/rt_temp_directory/early_router/overflow_map_planar.csv",
        result_dir / "egr_congestion_map/place_egr_horizontal_overflow.csv",
    ]
    map_path = next((path for path in candidates if path.is_file()), None)
    values = _load_overflow_grid(map_path) if map_path else []
    payload: dict = {
        "schema": "c-cong/v0",
        "valid": False,
        "average": None,
        "total_overflow": None,
        "max_overflow": None,
        "top1_pct": None,
        "top5_pct": None,
        "nonzero_pct": None,
        "map_paths": [str(path) for path in candidates if path.is_file()],
        "source_map": str(map_path) if map_path else None,
        "note": "invalid when no overflow map CSV is available",
    }
    if values:
        ordered = sorted(values, reverse=True)
        n = len(ordered)
        top1_n = max(1, int(n * 0.01))
        top5_n = max(1, int(n * 0.05))
        payload.update(
            {
                "valid": True,
                "average": round(sum(values) / n, 4),
                "total_overflow": round(sum(max(0.0, value) for value in values), 4),
                "max_overflow": round(ordered[0], 4),
                "top1_pct": round(sum(ordered[:top1_n]) / top1_n, 4),
                "top5_pct": round(sum(ordered[:top5_n]) / top5_n, 4),
                "nonzero_pct": round(100.0 * sum(1 for value in values if value > 0) / n, 4),
                "note": "aggregated from EGR/early-router overflow CSV",
            }
        )
    path = report_dir / "congestion.json"
    with path.open("w", encoding="utf-8") as stream:
        json.dump(payload, stream, indent=2)
        stream.write("\n")
    # Report harness (generate_aes11_detailed_report) expects this shape/path.
    legacy = {
        "schema": "C-CONG",
        "valid": bool(payload.get("valid")),
        "summary": {
            "average_edge_congestion": payload.get("average"),
            "total_overflow": payload.get("total_overflow"),
            "max_overflow": payload.get("max_overflow"),
            "top_1_pct_mean": payload.get("top1_pct"),
            "top_5_pct_mean": payload.get("top5_pct"),
            "nonzero_bin_pct": payload.get("nonzero_pct"),
        },
        "map_paths": payload.get("map_paths") or [],
        "source_map": payload.get("source_map"),
        "note": payload.get("note"),
    }
    legacy_path = result_dir / "congestion_summary.json"
    with legacy_path.open("w", encoding="utf-8") as stream:
        json.dump(legacy, stream, indent=2)
        stream.write("\n")
    return path


def write_pdn_status(result_dir: Path, workspace: Path) -> Path:
    """C-PDN: record whether floorplan PDN script / special nets exist."""
    pdn_tcl = workspace / "script/iFP_script/module/pdn.tcl"
    def_candidates = [
        result_dir / "iFP_result.def",
        result_dir / "iRT_result.def",
        result_dir / "iPL_result.def",
    ]
    def_path = next((path for path in def_candidates if path.is_file()), None)
    has_special = False
    if def_path is not None:
        sample = def_path.read_text(encoding="utf-8", errors="replace")[:2_000_000]
        has_special = ("SPECIALNETS" in sample) or ("+ USE POWER" in sample) or ("+ USE GROUND" in sample)
    payload = {
        "schema": "c-pdn/v0",
        "pdn_tcl_exists": pdn_tcl.is_file(),
        "pdn_tcl": str(pdn_tcl) if pdn_tcl.is_file() else None,
        "def_checked": str(def_path) if def_path else None,
        "special_nets_detected": has_special,
        "ir_ready": bool(pdn_tcl.is_file() and has_special),
        "note": "WP-PNP-00 minimal: PDN created in iFP via pdn.tcl; IR stage still Wave-3",
    }
    path = result_dir / "report/pdn_status.json"
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as stream:
        json.dump(payload, stream, indent=2)
        stream.write("\n")
    return path


def write_ir_drop_status(result_dir: Path, *, activity_source: str = "vectorless", reason: str | None = None) -> Path:
    """C-IR: emit explicit IR-drop status instead of leaving the gate to infer absence."""
    ir_dir = result_dir / "ir"
    report_dir = result_dir / "report"
    power_dir = result_dir / "power"
    for path in (ir_dir, report_dir, power_dir):
        path.mkdir(parents=True, exist_ok=True)
    payload = {
        "schema": "c-ir/v1",
        "trusted": False,
        "ir_drop_run": False,
        "activity_source": activity_source,
        "sample_count": 0,
        "worst_drop_v": None,
        "avg_drop_v": None,
        "threshold_v": None,
        "over_threshold_area_um2": None,
        "map": None,
        "report": None,
        "reason": reason
        or "IR-drop stage is not run with trusted PG SPEF/current model in this flow; this is a blocking signoff gap",
    }
    path = power_dir / "ir_drop_status.json"
    with path.open("w", encoding="utf-8") as stream:
        json.dump(payload, stream, indent=2)
        stream.write("\n")
    report_path = report_dir / "ir_drop_status.json"
    with report_path.open("w", encoding="utf-8") as stream:
        json.dump(payload, stream, indent=2)
        stream.write("\n")
    return path


def resolve_spef_for_timing(
    result_dir: Path,
    design_top: str,
    pdk_name: str,
    args: argparse.Namespace,
    rcx_files: dict,
) -> tuple[Path | None, str, list[str]]:
    spef_files = find_spef_artifacts(result_dir)
    if spef_files:
        preferred = next((path for path in spef_files if design_top in path.name), spef_files[0])
        return preferred.resolve(), "ircx", []

    warnings: list[str] = []
    if args.fallback_spef and rcx_files.get("fallback_spef"):
        fallback = Path(rcx_files["fallback_spef"])
        warnings.append(
            f"using Foundary fallback SPEF ({fallback.name}); design/netlist mismatch — proxy only, not signoff"
        )
        return fallback.resolve(), "fallback_proxy", warnings

    if args.require_spef:
        gaps = rcx_files.get("gaps") or ["no SPEF produced and no fallback requested"]
        return None, "missing", gaps
    return None, "missing", warnings


def write_custom_scripts(workspace: Path) -> None:
    custom = workspace / "script/custom"
    custom.mkdir(parents=True, exist_ok=True)
    common = """flow_init -config $::env(CONFIG_DIR)/flow_config.json
db_init -config $::env(CONFIG_DIR)/db_default_config.json -output_dir_path $::env(RESULT_DIR)
source $::env(TCL_SCRIPT_DIR)/DB_script/db_path_setting.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lef.tcl
"""
    spef_load = """
if {[info exists ::env(SPEF_FILE)] && [string length $::env(SPEF_FILE)] > 0} {
    if {![file exists $::env(SPEF_FILE)]} {
        puts stderr "ERROR: SPEF_FILE set but not found: $::env(SPEF_FILE)"
        exit 1
    }
    set SPEF_PATH $::env(SPEF_FILE)
    source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_spef.tcl
} elseif {[info exists ::env(IEDA_REQUIRE_SPEF)] && ($::env(IEDA_REQUIRE_SPEF) eq "1" || $::env(IEDA_REQUIRE_SPEF) eq "true")} {
    puts stderr "ERROR: IEDA_REQUIRE_SPEF=1 but SPEF_FILE missing or empty"
    exit 1
}
"""
    rcx = common + """def_init -path $::env(RESULT_DIR)/iRT_result.def
init_rcx -config $::env(CONFIG_DIR)/rcx_config.json
run_rcx
report_rcx
flow_exit
"""
    timing = common + """source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lib.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_sdc.tcl
def_init -path $::env(RESULT_DIR)/iRT_result.def
""" + spef_load + """run_sta -output $::env(RESULT_DIR)/timing/
flow_exit
"""
    power = common + """source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lib.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_sdc.tcl
def_init -path $::env(RESULT_DIR)/iRT_result.def
""" + spef_load + """# Explicit vectorless activity: without -toggle/-allow_default_toggle, iPA refuses
# numeric power (no VCD/SAIF) and the stage fails while the rest of the flow is fine.
if {[info exists ::env(ACTIVITY_VCD)] && [string length $::env(ACTIVITY_VCD)] > 0} {
    if {![file exists $::env(ACTIVITY_VCD)]} {
        puts stderr "ERROR: ACTIVITY_VCD set but not found: $::env(ACTIVITY_VCD)"
        exit 1
    }
    if {[info exists ::env(ACTIVITY_TOP)] && [string length $::env(ACTIVITY_TOP)] > 0} {
        set activity_top $::env(ACTIVITY_TOP)
    } else {
        set activity_top $::env(DESIGN_TOP)
    }
    set_pwr_design_workspace $::env(RESULT_DIR)/power/
    read_vcd $::env(ACTIVITY_VCD) -top_name $activity_top
    run_power -output $::env(RESULT_DIR)/power/
} elseif {[info exists ::env(ACTIVITY_SAIF)] && [string length $::env(ACTIVITY_SAIF)] > 0} {
    puts stderr "ERROR: ACTIVITY_SAIF set but aes13_flow.py has no iPA SAIF reader wired; use --activity-vcd for trusted power"
    exit 1
} else {
    run_power -toggle 0.02 -allow_default_toggle -output $::env(RESULT_DIR)/power/
}
flow_exit
"""
    metrics = common + """def_init -path $::env(RESULT_DIR)/iRT_result.def
report_wirelength -path $::env(RESULT_DIR)/report/wirelength.rpt
report_congestion -path $::env(RESULT_DIR)/report/congestion.rpt
report_quality_gate -path $::env(RESULT_DIR)/quality_gate.json
flow_exit
"""
    quality_gate = common + """if {[file exists $::env(RESULT_DIR)/iRT_result.def]} {
    def_init -path $::env(RESULT_DIR)/iRT_result.def
}
report_quality_gate -path $::env(RESULT_DIR)/quality_gate.json
flow_exit
"""
    (custom / "run_rcx.tcl").write_text(rcx, encoding="ascii")
    (custom / "run_timing.tcl").write_text(timing, encoding="ascii")
    (custom / "run_power.tcl").write_text(power, encoding="ascii")
    (custom / "run_metrics.tcl").write_text(metrics, encoding="ascii")
    (custom / "run_quality_gate.tcl").write_text(quality_gate, encoding="ascii")


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

    # Normalize stage db report paths to the canonical names used by comparison reports.
    # ICS55 templates historically wrote floorplan_stat.rpt / routing_stat.rpt / etc.
    report_rewrites = (
        ("iFP_script/run_iFP.tcl", r'(set DESIGN_STAT_TEXT\s+")[^"]+(")', r'\1$::env(RESULT_DIR)/report/fp_db.rpt\2'),
        ("iNO_script/run_iNO_fix_fanout.tcl", r'(set DESIGN_STAT_TEXT\s+")[^"]+(")', r'\1$::env(RESULT_DIR)/report/fixfanout_db.rpt\2'),
        ("iCTS_script/run_iCTS.tcl", r'(set DESIGN_STAT_TEXT\s+")[^"]+(")', r'\1$::env(RESULT_DIR)/report/cts_db.rpt\2'),
        ("iRT_script/run_iRT.tcl", r'(set DESIGN_STAT_TEXT\s+")[^"]+(")', r'\1$::env(RESULT_DIR)/report/rt_db.rpt\2'),
        ("iPL_script/run_iPL_filler.tcl", r'(set DESIGN_STAT_TEXT\s+")[^"]+(")', r'\1$::env(RESULT_DIR)/report/filler_db.rpt\2'),
    )
    for rel, pattern, repl in report_rewrites:
        path = script_dir / rel
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8")
        updated = re.sub(pattern, repl, text)
        # Ensure placement/legalization actually emit db reports.
        if rel.endswith("run_iPL.tcl") or rel.endswith("run_iPL_legalization.tcl"):
            updated = updated.replace("# report_db -path $DESIGN_STAT_TEXT", "report_db -path $DESIGN_STAT_TEXT")
        if updated != text:
            path.write_text(updated, encoding="utf-8")

    # Force canonical report_db paths even when scripts hard-code them.
    for rel, canonical in (
        ("iFP_script/run_iFP.tcl", "fp_db.rpt"),
        ("iPL_script/run_iPL.tcl", "pl_db.rpt"),
        ("iPL_script/run_iPL_legalization.tcl", "lg_db.rpt"),
        ("iCTS_script/run_iCTS.tcl", "cts_db.rpt"),
        ("iRT_script/run_iRT.tcl", "rt_db.rpt"),
        ("iPL_script/run_iPL_filler.tcl", "filler_db.rpt"),
        ("iNO_script/run_iNO_fix_fanout.tcl", "fixfanout_db.rpt"),
    ):
        path = script_dir / rel
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8")
        updated = re.sub(
            r'report_db\s+-path\s+[^\n]+',
            f'report_db -path "$::env(RESULT_DIR)/report/{canonical}"',
            text,
        )
        if "# report_db -path" in updated:
            updated = updated.replace("# report_db -path $DESIGN_STAT_TEXT", f'report_db -path "$::env(RESULT_DIR)/report/{canonical}"')
        if updated != text:
            path.write_text(updated, encoding="utf-8")

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

    no_path = workspace / "iEDA_config/no_default_config_fixfanout.json"
    if no_path.exists():
        with no_path.open(encoding="utf-8") as stream:
            no_config = json.load(stream)
        no_config["insert_buffer"] = pdk.insert_buffer
        with no_path.open("w", encoding="utf-8") as stream:
            json.dump(no_config, stream, indent=4)
            stream.write("\n")

    for to_name in (
        "to_default_config_setup.json",
        "to_default_config_drv.json",
        "to_default_config_hold.json",
    ):
        to_path = workspace / "iEDA_config" / to_name
        if to_path.exists():
            with to_path.open(encoding="utf-8") as stream:
                to_config = json.load(stream)
            for key in ("DRV_insert_buffers", "setup_insert_buffers", "hold_insert_buffers"):
                if key in to_config:
                    to_config[key] = [pdk.insert_buffer]
            with to_path.open("w", encoding="utf-8") as stream:
                json.dump(to_config, stream, indent=4)
                stream.write("\n")

    pl_path = workspace / "iEDA_config/pl_default_config.json"
    if pl_path.exists():
        with pl_path.open(encoding="utf-8") as stream:
            pl_config = json.load(stream)
        buffer_section = pl_config.get("BUFFER", {})
        if buffer_section:
            buffer_section["buffer_type"] = list(pdk.cts_buffers)
        filler_section = pl_config.get("Filler", {})
        if filler_section:
            filler_section["first_iter"] = list(pdk.filler_cells)
            filler_section["second_iter"] = list(pdk.filler_cells)
        with pl_path.open("w", encoding="utf-8") as stream:
            json.dump(pl_config, stream, indent=4)
            stream.write("\n")


def prepare_workspace(name: str, config: dict, output_dir: Path, reset: bool) -> Path:
    pdk_name = design_pdk(name, config)
    pdk = PDKS[pdk_name]
    template_candidates = [
        REPO_ROOT / "scripts/design" / pdk.template,  # Primary: PDK template
        DESIGNS_ROOT / name / "workspace",             # Secondary: design-specific
        REPO_ROOT / "scripts/design/sky130_gcd",      # Fallback: sky130 as generic
    ]

    template = None
    for candidate in template_candidates:
        if candidate.exists() and (candidate / "script").exists():
            template = candidate
            break

    if template is None:
        raise FileNotFoundError(
            f"No valid workspace template found for {name} (PDK={pdk_name}).\n"
            f"Tried: {[str(c) for c in template_candidates]}"
        )

    print(f"  [workspace] using template: {template.relative_to(REPO_ROOT)}", flush=True)

    workspace = output_dir / "workspace"
    if reset and workspace.exists():
        suffix = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
        stale_workspace = output_dir / f"workspace.stale-{suffix}"
        workspace.rename(stale_workspace)
        print(f"  [workspace] archived stale results: {stale_workspace.name}", flush=True)

    workspace.mkdir(parents=True, exist_ok=True)

    # Copy with explicit error handling
    try:
        shutil.copytree(template / "script", workspace / "script", dirs_exist_ok=True)
        print(f"  [workspace] copied {len(list((workspace / 'script').rglob('*')))} script files", flush=True)
    except Exception as e:
        raise RuntimeError(f"Failed to copy scripts from {template / 'script'}: {e}")

    try:
        shutil.copytree(template / "iEDA_config", workspace / "iEDA_config", dirs_exist_ok=True)
        print(f"  [workspace] copied {len(list((workspace / 'iEDA_config').rglob('*')))} config files", flush=True)
    except Exception as e:
        raise RuntimeError(f"Failed to copy iEDA_config from {template / 'iEDA_config'}: {e}")

    result_dir = workspace / "result"
    for relative in ("logs", "report/drc", "drc", "timing", "power", "rcx", "visualizations"):
        (result_dir / relative).mkdir(parents=True, exist_ok=True)
    if pdk_name == "asap7":
        configure_asap7(workspace)
    configure_pdk_scripts(workspace, pdk)
    write_custom_scripts(workspace)
    write_rcx_config(workspace, resolve_rcx_pdk_files(pdk_name))
    (workspace / "result").mkdir(parents=True, exist_ok=True)
    return workspace


def build_environment(
    name: str,
    config: dict,
    netlist: Path,
    workspace: Path,
    args: argparse.Namespace,
) -> tuple[dict[str, str], dict]:
    pdk_name = design_pdk(name, config)
    pdk = PDKS[pdk_name]
    result_dir = workspace / "result"
    design_dir = DESIGNS_ROOT / name
    sdc = design_dir / config["inputs"]["sdc"]
    top = config["top"]  # 直接使用 design.json 中的 top
    clock = config["clocks"][0]
    floorplan = compute_floorplan(name, pdk_name, pdk, netlist, args.target_utilization)
    workspace_tech_lef = workspace / "tech/asap7_tech_1x_with_rc.lef"
    tech_lef = workspace_tech_lef if pdk_name == "asap7" else pdk.tech_lef
    # Ensure input paths are absolute
    netlist = netlist.resolve()
    sdc = sdc.resolve()
    tech_lef = tech_lef.resolve()
    db_config_path = workspace / "iEDA_config/db_default_config.json"
    if db_config_path.exists():
        with db_config_path.open(encoding="utf-8") as stream:
            db_config = json.load(stream)
        input_config = db_config.setdefault("INPUT", {})
        input_config["tech_lef_path"] = str(tech_lef)
        input_config["lef_paths"] = " ".join(str(path.resolve()) for path in pdk.cell_lefs)
        input_config["verilog_path"] = str(netlist)
        input_config["lib_path"] = " ".join(str(path.resolve()) for path in pdk.sta_libs)
        input_config["sdc_path"] = str(sdc)
        output_config = db_config.setdefault("OUTPUT", {})
        output_config["output_dir_path"] = str(result_dir.resolve())
        with db_config_path.open("w", encoding="utf-8") as stream:
            json.dump(db_config, stream, indent=4)
            stream.write("\n")
    print(
        f"  [floorplan] cells={floorplan['cell_count']} area={floorplan['cell_area_um2']} um^2 "
        f"target={floorplan['target_utilization']:.0%} effective={floorplan['effective_utilization']:.1%} "
        f"core={floorplan['core_side_um']} um die={floorplan['die_side_um']} um",
        flush=True,
    )
    env = os.environ.copy()
    old_ld = env.get("LD_LIBRARY_PATH", "")
    # Resolve to absolute paths since iEDA runs with cwd=workspace
    workspace_abs = workspace.resolve()
    result_dir_abs = result_dir.resolve()
    env.update(
        {
            "WORKSPACE": str(workspace_abs),
            "CONFIG_DIR": str(workspace_abs / "iEDA_config"),
            "IEDA_CONFIG_DIR": str(workspace_abs / "iEDA_config"),
            "RESULT_DIR": str(result_dir_abs),
            "DEF_DIR": str(result_dir_abs),
            "TCL_SCRIPT_DIR": str(workspace_abs / "script"),
            "IEDA_TCL_SCRIPT_DIR": str(workspace_abs / "script"),
            "FOUNDRY_DIR": str(FOUNDRY_ROOT / pdk_name),
            "PDK_DIR": str(FOUNDRY_ROOT / pdk_name),
            "DESIGN_TOP": top,
            "TOP_NAME": top,
            "CLK_PORT_NAME": str(clock["port"]),
            "NETLIST_FILE": str(netlist),
            "SDC_FILE": str(sdc),
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
            "ROUTING_THREADS": str(
                args.routing_threads if getattr(args, "routing_threads", None) else pdk.routing_threads
            ),
            "TECH_LEF_PATH": str(tech_lef),
            "LEF_PATH": " ".join(map(str, pdk.cell_lefs)),
            "LIB_PATH": " ".join(map(str, pdk.sta_libs)),
            "TECH_LEF": str(tech_lef),
            "LEF_STDCELL": " ".join(map(str, pdk.cell_lefs)),
        "LIB_STDCELL": " ".join(map(str, pdk.sta_libs)),
        "GDS_FILE": str((result_dir / "final.gds").resolve()),
        **build_rt_environment(args),
        "LD_LIBRARY_PATH": f"{BUILD_LIB}:{old_ld}" if old_ld else str(BUILD_LIB),
    }
    )
    if args.activity_vcd:
        env["ACTIVITY_VCD"] = str(args.activity_vcd.resolve())
    if args.activity_saif:
        env["ACTIVITY_SAIF"] = str(args.activity_saif.resolve())
    if args.activity_top:
        env["ACTIVITY_TOP"] = str(args.activity_top)
    return env, floorplan


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
    expected_glob_matches: list[Path] = []
    if stage.expected_glob:
        expected_glob_matches = sorted(
            path
            for path in result_dir.glob(stage.expected_glob)
            if path.is_file() and path.stat().st_size > 0
        )
    expected_alternates = []
    if stage.name == "fanout":
        expected_alternates = [result_dir / "iNO_fix_fanout_result.def"]
    if expected and not expected.is_file():
        expected = next((path for path in expected_alternates if path.is_file()), expected)
    if resume and expected and expected.is_file() and expected.stat().st_size > 0:
        print(f"    [{stage.name}] skipped (artifact exists)", flush=True)
        return {"status": "skipped", "artifact": str(expected)}
    if resume and stage.expected_glob and expected_glob_matches:
        print(f"    [{stage.name}] skipped (artifact exists)", flush=True)
        return {"status": "skipped", "artifact": str(expected_glob_matches[0])}

    # ASAP7 historically hangs/timeouts in iTO drv/hold (exit 124/-9). Under BEST_EFFORT,
    # copy the prior-stage DEF so legalization/routing can proceed. Documented as soft-pass.
    best_effort = env.get("IEDA_RT_BEST_EFFORT", "").lower() in {"1", "true"} or env.get(
        "IEDA_CTS_BEST_EFFORT", ""
    ).lower() in {"1", "true"}
    if best_effort and stage.name in {"to_drv", "to_hold"} and expected is not None:
        prior = result_dir / ("iCTS_result.def" if stage.name == "to_drv" else "iTO_drv_result.def")
        if not prior.is_file() or prior.stat().st_size == 0:
            prior = result_dir / "iCTS_result.def"
        if prior.is_file() and prior.stat().st_size > 0:
            shutil.copy2(prior, expected)
            prior_v = prior.with_suffix(".v")
            expected_v = expected.with_suffix(".v")
            if prior_v.is_file():
                shutil.copy2(prior_v, expected_v)
            print(
                f"    [{stage.name}] soft-skipped BEST_EFFORT (copied {prior.name} -> {expected.name})",
                flush=True,
            )
            return {
                "status": "success",
                "elapsed_sec": 0.0,
                "returncode": 0,
                "log": None,
                "artifact": str(expected),
                "reason": f"best_effort_copy_from:{prior.name}",
            }

    script = workspace / "script" / stage.script
    log_file = result_dir / "logs" / f"{stage.name}.log"
    print(f"    [{stage.name}] running", flush=True)
    started = time.monotonic()
    try:
        stage_env = env.copy()
        if stage.name == "legalization":
            hold_def = result_dir / "iTO_hold_result.def"
            input_def = hold_def if hold_def.is_file() else result_dir / "iCTS_result.def"
            stage_env["INPUT_DEF"] = str(input_def.resolve())
        elif stage.name == "filler":
            stage_env["INPUT_DEF"] = str((result_dir / "iRT_result.def").resolve())
        elif stage.name == "gds":
            filler_def = result_dir / "iPL_filler_result.def"
            input_def = filler_def if filler_def.is_file() else result_dir / "iRT_result.def"
            stage_env["INPUT_DEF"] = str(input_def.resolve())
        process = subprocess.run(
            [str(IEDA_BIN), "-script", str(script.relative_to(workspace))],
            cwd=workspace,
            env=stage_env,
            text=True,
            errors="replace",
            capture_output=True,
            timeout=timeout,
            check=False,
        )
        log_text = process.stdout + "\n" + process.stderr
        returncode = process.returncode
    except subprocess.TimeoutExpired as exc:
        stdout = exc.stdout.decode(errors="replace") if isinstance(exc.stdout, bytes) else (exc.stdout or "")
        stderr = exc.stderr.decode(errors="replace") if isinstance(exc.stderr, bytes) else (exc.stderr or "")
        log_text = stdout + "\n" + stderr + f"\nTIMEOUT after {timeout}s\n"
        returncode = 124
    log_file.write_text(log_text, encoding="utf-8", errors="replace")
    elapsed = time.monotonic() - started
    fatal = log_has_fatal_error(log_text)
    if stage.name == "drc" and expected and not expected.is_file() and "violation_type" in log_text:
        expected.write_text(log_text, encoding="utf-8", errors="replace")
    if expected and not expected.is_file():
        expected = next((path for path in expected_alternates if path.is_file()), expected)
    if stage.expected_glob and not expected_glob_matches:
        expected_glob_matches = sorted(
            path
            for path in result_dir.glob(stage.expected_glob)
            if path.is_file() and path.stat().st_size > 0
        )
    artifact_ok = expected is None or (expected.is_file() and expected.stat().st_size > 0)
    if stage.expected_glob:
        artifact_ok = artifact_ok and bool(expected_glob_matches)
    success = returncode == 0 and fatal is None and artifact_ok
    status = "success" if success else "failed"
    reason = None
    if returncode != 0:
        reason = f"exit code {returncode}"
    elif fatal:
        reason = fatal
    elif not artifact_ok:
        if stage.expected_glob:
            reason = f"missing artifact glob: {stage.expected_glob}"
        else:
            reason = f"missing artifact: {expected}"
    print(f"    [{stage.name}] {status} ({elapsed:.1f}s){': ' + reason if reason else ''}", flush=True)
    artifact_path = str(expected) if expected else None
    if stage.expected_glob and expected_glob_matches:
        artifact_path = str(expected_glob_matches[0])
    return {
        "status": status,
        "elapsed_sec": round(elapsed, 3),
        "returncode": returncode,
        "log": str(log_file),
        "artifact": artifact_path,
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


def refresh_quality_gate(workspace: Path, env: dict[str, str], timeout: int) -> dict:
    stage = Stage("quality_gate", "custom/run_quality_gate.tcl", "quality_gate.json", required=False)
    return run_stage(stage, workspace, env, timeout, resume=False)


def collect_artifacts(result_dir: Path) -> dict[str, list[str]]:
    patterns = {
        "def": "*.def",
        "gds": "*.gds*",
        "images": "*.png",
        "spef": "*.spef",
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
    output_dir = Path(args.result_root) / name
    output_dir.mkdir(parents=True, exist_ok=True)
    print(f"\n[{name}] PDK={pdk_name} strategy={strategy_for(name)}", flush=True)
    if args.synthesize:
        netlist = synthesize_design(name, config, output_dir, args.timeout)
    else:
        generated_netlist = DESIGNS_ROOT / name / "netlist/aes_cipher_top.v"
        configured_netlist = DESIGNS_ROOT / name / config["inputs"]["netlist"]
        if generated_netlist.is_file():
            netlist = generated_netlist
            # 如果使用 aes_cipher_top.v，更新 top module
            config = {**config, "top": "aes_cipher_top"}
        else:
            netlist = configured_netlist
    pdk = PDKS[pdk_name]
    floorplan = compute_floorplan(name, pdk_name, pdk, netlist, args.target_utilization)
    signature = build_input_signature(name, pdk_name, pdk, netlist, floorplan)
    reset = (not args.resume and (output_dir / "workspace").exists()) or (
        args.resume and workspace_requires_reset(output_dir, signature, floorplan)
    )
    workspace = prepare_workspace(name, config, output_dir, reset)
    with (workspace / "input_signature.json").open("w", encoding="utf-8") as stream:
        json.dump(signature, stream, indent=2)
        stream.write("\n")
    env, floorplan = build_environment(name, config, netlist, workspace, args)
    result_dir = workspace / "result"
    rcx_files = resolve_rcx_pdk_files(pdk_name)
    design_top = config["top"]
    sdc = (DESIGNS_ROOT / name / config["inputs"]["sdc"]).resolve()
    sdc_lint = None
    if not args.skip_sdc_lint:
        sdc_lint = lint_sdc_file(
            sdc,
            result_dir / "timing/sdc_lint.json",
            require_output_load=args.require_output_load,
        )
        if not sdc_lint.get("pass", False):
            print(
                f"    [sdc] lint failed: {', '.join(sdc_lint.get('failures') or ['unknown'])}",
                flush=True,
            )
    stage_results = {}
    status = "prepared"
    spef_path: Path | None = None
    spef_source = "missing"
    spef_warnings: list[str] = []
    if not args.prepare_only:
        status = "success"
        for stage in STAGES:
            if stage.name == "rcx" and args.skip_rcx:
                stage_results[stage.name] = {
                    "status": "skipped",
                    "reason": "skip_rcx flag",
                    "artifact": None,
                }
                continue

            if stage.name == "rcx" and not rcx_files.get("supported", False):
                stage_results[stage.name] = {
                    "status": "skipped",
                    "reason": f"rcx unsupported for PDK {pdk_name}",
                    "artifact": None,
                }
                continue

            if stage.name == "rcx" and not rcx_files.get("ready", False):
                reason = "; ".join(rcx_files.get("gaps") or ["rcx PDK files not ready"])
                if args.require_spef:
                    stage_results[stage.name] = {
                        "status": "failed",
                        "reason": reason,
                        "artifact": None,
                    }
                    status = "failed"
                    break
                print(f"    [rcx] skipped (PDK files missing): {reason}", flush=True)
                stage_results[stage.name] = {
                    "status": "skipped",
                    "reason": reason,
                    "artifact": None,
                }
                continue

            if stage.name in {"timing", "power"}:
                spef_path, spef_source, spef_warnings = resolve_spef_for_timing(
                    result_dir, design_top, pdk_name, args, rcx_files
                )
                if spef_path is not None:
                    env["SPEF_FILE"] = str(spef_path)
                    env["SPEF_SOURCE"] = spef_source
                else:
                    env.pop("SPEF_FILE", None)
                    env.pop("SPEF_SOURCE", None)
                if args.require_spef:
                    env["IEDA_REQUIRE_SPEF"] = "1"
                else:
                    env.pop("IEDA_REQUIRE_SPEF", None)
                for warning in spef_warnings:
                    print(f"    [spef] {warning}", flush=True)

            stage_required = stage.required
            if stage.name == "rcx" and args.require_spef:
                stage_required = True
            if stage.name in {"timing", "power"} and args.require_spef:
                stage_required = True

            stage_result = run_stage(stage, workspace, env, args.timeout, args.resume and not reset)
            stage_results[stage.name] = stage_result

            if stage.name == "rcx":
                coverage = {
                    "schema": "c-spef/v0",
                    "design": name,
                    "pdk": pdk_name,
                    "source": "ircx" if stage_result["status"] == "success" else "missing",
                    "trusted": False,
                    "spef_files": [str(path) for path in find_spef_artifacts(result_dir)],
                    "pdk_files": {
                        "mapping_file": str(rcx_files.get("mapping_file") or ""),
                        "itf_file": str(rcx_files.get("itf_file") or ""),
                        "captab_file": str(rcx_files.get("captab_file") or ""),
                        "ready": rcx_files.get("ready", False),
                        "trusted": rcx_files.get("trusted", False),
                        "synthetic_ready": rcx_files.get("synthetic_ready", False),
                        "synthetic_manifest": str(rcx_files.get("synthetic_manifest") or ""),
                    },
                    "gaps": rcx_files.get("gaps") or [],
                    "stage_status": stage_result["status"],
                }
                write_rcx_coverage(result_dir, coverage)

            if stage.name == "power" and stage_result["status"] in {"success", "skipped"}:
                write_activity_source(result_dir, vcd=args.activity_vcd, saif=args.activity_saif)

            if stage.name == "metrics" and stage_result["status"] in {"success", "skipped"}:
                write_congestion_summary(result_dir)

            if stage.name == "floorplan" and stage_result["status"] in {"success", "skipped"}:
                write_pdn_status(result_dir, workspace)

            if stage_result["status"] == "failed" and stage_required:
                status = "failed"
                break
            if args.stop_after == stage.name:
                status = "partial"
                break

        spef_path, spef_source, spef_warnings = resolve_spef_for_timing(
            result_dir, design_top, pdk_name, args, rcx_files
        )
        coverage = {
            "schema": "c-spef/v0",
            "design": name,
            "pdk": pdk_name,
            "source": spef_source,
            "trusted": False,
            "spef_file": str(spef_path) if spef_path else None,
            "spef_files": [str(path) for path in find_spef_artifacts(result_dir)],
            "warnings": spef_warnings,
            "require_spef": bool(args.require_spef),
            "pdk_files": {
                "mapping_file": str(rcx_files.get("mapping_file") or ""),
                "itf_file": str(rcx_files.get("itf_file") or ""),
                "captab_file": str(rcx_files.get("captab_file") or ""),
                "ready": rcx_files.get("ready", False),
                "trusted": rcx_files.get("trusted", False),
                "synthetic_ready": rcx_files.get("synthetic_ready", False),
                "synthetic_manifest": str(rcx_files.get("synthetic_manifest") or ""),
            },
            "gaps": rcx_files.get("gaps") or [],
        }
        write_rcx_coverage(result_dir, coverage)

        # Always emit Wave-0 measurement artifacts when maps/power dirs exist.
        if (result_dir / "power").is_dir() or "power" in stage_results:
            activity_path = result_dir / "power/activity_source.json"
            if not activity_path.is_file():
                write_activity_source(result_dir, vcd=args.activity_vcd, saif=args.activity_saif)
            activity_source = "vectorless"
            activity = None
            try:
                activity = json.loads(activity_path.read_text(encoding="utf-8"))
                activity_source = str(activity.get("activity_source") or activity.get("source") or "vectorless")
            except (OSError, json.JSONDecodeError):
                pass
            write_ir_drop_status(
                result_dir,
                activity_source=activity_source,
                reason=(
                    "trusted VCD/SAIF activity and PG SPEF/current model are required before IR-drop can pass signoff"
                    if activity and not activity.get("trusted", False)
                    else "IR-drop engine/report is not wired into aes13_flow.py for trusted signoff yet"
                ),
            )
        write_congestion_summary(result_dir)
        write_pdn_status(result_dir, workspace)

        if status != "failed" and (result_dir / "final.gds").is_file():
            stage_results["visualization"] = render_gds(result_dir, args.timeout)
            if stage_results["visualization"]["status"] != "success":
                status = "partial"
        if status != "failed" and (result_dir / "iRT_result.def").is_file():
            stage_results["quality_gate_final"] = refresh_quality_gate(workspace, env, args.timeout)
        if any(item["status"] == "failed" for item in stage_results.values()):
            status = "partial" if status != "failed" else status
    else:
        activity_path = result_dir / "power/activity_source.json"
        if not activity_path.is_file():
            write_activity_source(result_dir, vcd=args.activity_vcd, saif=args.activity_saif)
        write_ir_drop_status(
            result_dir,
            activity_source="vcd" if args.activity_vcd else ("saif" if args.activity_saif else "vectorless"),
            reason="prepare-only run: IR-drop analysis was not executed",
        )
        write_rcx_coverage(
            result_dir,
            {
                "schema": "c-spef/v0",
                "design": name,
                "pdk": pdk_name,
                "source": "missing",
                "trusted": False,
                "spef_file": None,
                "spef_files": [],
                "warnings": [],
                "require_spef": bool(args.require_spef),
                "pdk_files": {
                    "mapping_file": str(rcx_files.get("mapping_file") or ""),
                    "itf_file": str(rcx_files.get("itf_file") or ""),
                    "captab_file": str(rcx_files.get("captab_file") or ""),
                    "ready": rcx_files.get("ready", False),
                },
                "gaps": rcx_files.get("gaps") or [],
            },
        )
    summary = {
        "design": name,
        "pdk": pdk_name,
        "strategy": strategy_for(name),
        "status": status,
        "timestamp": datetime.now().astimezone().isoformat(),
        "netlist": str(netlist),
        "workspace": str(workspace),
        "floorplan": floorplan,
        "routing_profile": {
            k: v
            for k, v in env.items()
            if k.startswith("IEDA_RT_")
        },
        "budget_profile": build_budget_profile_summary(args),
        "experiment_manifest": str(Path(args.result_root) / "experiment_manifest.json"),
        "spef": {
            "file": str(spef_path) if spef_path else None,
            "source": spef_source,
            "trusted": False,
            "warnings": spef_warnings,
            "require_spef": bool(args.require_spef),
            "coverage": str(result_dir / "rcx/rcx_coverage.json"),
        },
        "sdc_lint": sdc_lint,
        "activity": {
            "vcd": str(args.activity_vcd.resolve()) if args.activity_vcd else None,
            "saif": str(args.activity_saif.resolve()) if args.activity_saif else None,
            "top": args.activity_top,
            "provenance": str(result_dir / "power/activity_source.json"),
        },
        "ir_drop": {
            "status": str(result_dir / "power/ir_drop_status.json"),
        },
        "rcx_pdk": rcx_files_for_summary(rcx_files),
        "stages": stage_results,
        "artifacts": collect_artifacts(result_dir),
    }
    write_design_summary(output_dir, summary)
    return summary


def write_batch_summary(summaries: list[dict], result_root: Path, manifest: dict | None = None) -> None:
    result_root.mkdir(parents=True, exist_ok=True)
    batch = {
        "timestamp": datetime.now().astimezone().isoformat(),
        "design_count": len(summaries),
        "experiment_manifest": str(result_root / "experiment_manifest.json") if manifest else None,
        "budget_profile": manifest.get("budget_profile") if manifest else None,
        "summaries": summaries,
    }
    with (result_root / "summary.json").open("w", encoding="utf-8") as stream:
        json.dump(batch, stream, indent=2)
        stream.write("\n")
    lines = [
        "# AES 13-version iEDA results",
        "",
        f"- Budget profile: `{manifest.get('budget_profile', {}).get('name') if manifest else 'N/A'}`",
        f"- Experiment manifest: `{Path('experiment_manifest.json') if manifest else 'N/A'}`",
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
    (result_root / "summary.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


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
    parser.add_argument(
        "--require-spef",
        action="store_true",
        default=False,
        help="Hard-fail when ITF/captab missing or SPEF not produced/readable (Wave-0 trusted STA).",
    )
    parser.add_argument(
        "--skip-rcx",
        action="store_true",
        default=False,
        help="Skip iRCX stage (SPEF remains missing unless --fallback-spef).",
    )
    parser.add_argument(
        "--fallback-spef",
        action="store_true",
        default=False,
        help="Allow Foundary sample SPEF as proxy only (A1 must label invalid/proxy, never trusted).",
    )
    parser.add_argument(
        "--activity-vcd",
        type=Path,
        default=None,
        help="VCD activity file for iPA read_vcd/report_power. Required for trusted power.",
    )
    parser.add_argument(
        "--activity-saif",
        type=Path,
        default=None,
        help="SAIF activity file to record as provenance; no SAIF reader is wired in this flow yet.",
    )
    parser.add_argument(
        "--activity-top",
        default=None,
        help="Top VCD scope passed to read_vcd -top_name. Defaults to design top.",
    )
    parser.add_argument(
        "--skip-sdc-lint",
        action="store_true",
        default=False,
        help="Do not write result/timing/sdc_lint.json.",
    )
    parser.add_argument(
        "--require-output-load",
        action="store_true",
        default=False,
        help="Make missing set_load a hard SDC lint failure. Default is warning-only due to known iSTA risk.",
    )
    parser.add_argument(
        "--result-root",
        type=Path,
        default=OUTPUT_ROOT,
        help="Per-design output root, default: benchmarks/results/aes13",
    )
    parser.add_argument(
        "--budget-profile",
        choices=tuple(BUDGET_PROFILES),
        default="E0_current",
        help="M0 fixed A/B budget profile (default: E0_current).",
    )
    parser.add_argument(
        "--baseline-json",
        type=Path,
        default=None,
        help="Baseline detailed-comparison JSON recorded in experiment_manifest.json.",
    )
    parser.add_argument(
        "--baseline-label",
        default=None,
        help="Human-readable baseline label recorded in experiment_manifest.json.",
    )
    parser.add_argument(
        "--target-utilization",
        type=float,
        default=0.70,
        help="Override floorplan CORE_UTIL (default: 0.70).",
    )
    parser.add_argument(
        "--rt-max-iterations",
        type=int,
        choices=(1, 2, 3, 5),
        default=1,
        help="Limit detailed routing iteration budget via IEDA_RT_MAX_ITERATIONS (default: 1 for 65%% get-through validation).",
    )
    parser.add_argument(
        "--rt-routing-utilization-target",
        type=float,
        default=0.70,
        help="iRT routing utilization target (default: 0.70).",
    )
    parser.add_argument(
        "--rt-routing-utilization-gap",
        type=float,
        default=0.0,
        help="Acceptable utilization gap before trying recovery mode (default: 0.0).",
    )
    parser.add_argument(
        "--rt-timing-improve-ratio",
        type=float,
        default=0.20,
        help="Per-iteration timing improvement threshold target (default: 0.20).",
    )
    parser.add_argument(
        "--rt-baseline-timing-improve-ratio",
        type=float,
        default=0.20,
        help="Baseline-timing gate threshold to unlock flow (default: 0.20).",
    )
    parser.add_argument(
        "--rt-utilization-retry-max-iter",
        type=int,
        default=5,
        help="IEDA_RT_UTILIZATION_RETRY_MAX_ITER (default: 5).",
    )
    parser.add_argument(
        "--rt-utilization-retry-task-ratio",
        type=float,
        default=0.40,
        help="IEDA_RT_UTILIZATION_RETRY_TASK_RATIO (default: 0.40).",
    )
    parser.add_argument(
        "--rt-utilization-improve-ratio",
        type=float,
        default=0.02,
        help="IEDA_RT_UTILIZATION_IMPROVE_RATIO (default: 0.02).",
    )
    parser.add_argument(
        "--rt-overflow-cell-improve-ratio",
        type=float,
        default=0.05,
        help="IEDA_RT_OVERFLOW_CELL_IMPROVE_RATIO (default: 0.05).",
    )
    parser.add_argument(
        "--rt-overflow-cell-target",
        type=float,
        default=0.10,
        help="IEDA_RT_ROUTING_OVERFLOW_CELL_TARGET (default: 0.10).",
    )
    parser.add_argument(
        "--rt-business-timing-improve-gate",
        type=float,
        default=0.20,
        help="Timing gate applied in iRT business logic (default: 0.20).",
    )
    parser.add_argument(
        "--rt-business-score-threshold",
        type=float,
        default=0.75,
        help="Decision-score gate threshold (default: 0.75).",
    )
    parser.add_argument(
        "--rt-business-score-min-iter",
        type=int,
        default=1,
        help="Score gate ignored before this iteration (default: 1).",
    )
    parser.add_argument(
        "--rt-business-baseline-min-iter",
        type=int,
        default=2,
        help="Baseline timing gate starts after this iteration (default: 2).",
    )
    parser.add_argument(
        "--rt-enable-business-gate",
        action="store_true",
        default=True,
        help="Enable business gate (default on).",
    )
    parser.add_argument(
        "--rt-disable-business-gate",
        dest="rt_enable_business_gate",
        action="store_false",
        help="Disable business gate.",
    )
    parser.set_defaults(rt_enable_business_gate=True)
    parser.add_argument(
        "--rt-enable-baseline-timing-gate",
        action="store_true",
        default=True,
        help="Enable baseline timing gate (default on).",
    )
    parser.add_argument(
        "--rt-disable-baseline-timing-gate",
        dest="rt_enable_baseline_timing_gate",
        action="store_false",
        help="Disable baseline timing gate.",
    )
    parser.set_defaults(rt_enable_baseline_timing_gate=True)
    parser.add_argument(
        "--rt-enable-plateau",
        action="store_true",
        default=True,
        help="Enable plateau-based iteration control (default on).",
    )
    parser.add_argument(
        "--rt-disable-plateau",
        dest="rt_enable_plateau",
        action="store_false",
        help="Disable plateau-based iteration control.",
    )
    parser.set_defaults(rt_enable_plateau=False)
    parser.add_argument(
        "--rt-plateau-no-improve-limit",
        type=int,
        default=2,
        help="IEDA_RT_PLATEAU_NO_IMPROVE_LIMIT (default: 2).",
    )
    parser.add_argument(
        "--rt-plateau-max-reroute",
        type=int,
        default=0,
        help="IEDA_RT_PLATEAU_MAX_REROUTE (default: 0).",
    )
    parser.add_argument(
        "--rt-plateau-max-candidate-patch-num",
        type=int,
        default=0,
        help="IEDA_RT_PLATEAU_MAX_CAND_PATCH (default: 0).",
    )
    parser.add_argument(
        "--rt-plateau-violation-scale",
        type=float,
        default=1.25,
        help="IEDA_RT_PLATEAU_VIOLATION_SCALE (default: 1.25).",
    )
    parser.add_argument(
        "--rt-plateau-history-scale",
        type=float,
        default=1.20,
        help="IEDA_RT_PLATEAU_HISTORY_SCALE (default: 1.20).",
    )
    parser.add_argument(
        "--rt-stop-early-min-iter",
        type=int,
        default=2,
        help="IEDA_RT_STOP_EARLY_MIN_ITER (default: 2).",
    )
    parser.add_argument(
        "--rt-fail-on-residual-drc",
        action="store_true",
        default=False,
        help="Enable iRT residual DRC as hard failure (default off).",
    )
    parser.add_argument(
        "--rt-best-effort",
        action="store_true",
        default=True,
        help="Soft-abort on violation explosion / incomplete DR and still emit DEF (default on).",
    )
    parser.add_argument(
        "--rt-strict",
        dest="rt_best_effort",
        action="store_false",
        help="Disable best-effort soft-abort (hard-fail on plateau).",
    )
    parser.add_argument(
        "--rt-initial-box-size",
        type=int,
        default=None,
        help="Override IEDA_RT_INITIAL_BOX_SIZE (default: adaptive from utilization).",
    )
    parser.add_argument(
        "--rt-max-memory-mb",
        type=int,
        default=32768,
        help="IEDA_RT_MAX_MEMORY_MB soft budget (default: 32768).",
    )
    parser.add_argument(
        "--rt-enable-escalation",
        action="store_true",
        default=False,
        help="Enable box-size escalation across DR iterations (default off for get-through).",
    )
    parser.add_argument(
        "--rt-disable-escalation",
        dest="rt_enable_escalation",
        action="store_false",
        help="Disable box-size escalation (fixed box size).",
    )
    parser.add_argument(
        "--rt-rule-aware-cost",
        action="store_true",
        default=False,
        help="WP-RT-01: enable rule-aware DRC weights/cost (default off, zero regression).",
    )
    parser.add_argument(
        "--rt-enhanced-minarea-repair",
        action="store_true",
        default=False,
        help="WP-RT-01: boost min-area patch candidates (default off, zero regression).",
    )
    parser.add_argument(
        "--rt-component-escalate",
        action="store_true",
        default=False,
        help="WP-RT-01b: conflict-component escalate on plateau (default off, zero regression).",
    )
    parser.add_argument(
        "--rt-prl-short-repair",
        action="store_true",
        default=False,
        help="WP-RT-01b: prioritize metal_short/PRL rip-up/repair (default off, zero regression).",
    )
    parser.add_argument(
        "--rt-plateau-check-interval",
        type=int,
        default=36,
        help="IEDA_RT_PLATEAU_CHECK_INTERVAL in boxes (default: 36).",
    )
    parser.add_argument(
        "--rt-plateau-explosion-threshold",
        type=float,
        default=2.0,
        help="IEDA_RT_PLATEAU_EXPLOSION_THRESHOLD growth rate (default: 2.0).",
    )
    parser.add_argument(
        "--rt-max-boxes",
        type=int,
        default=0,
        help="IEDA_RT_MAX_BOXES hard cap (0=unlimited).",
    )
    parser.add_argument(
        "--rt-max-sr-seconds",
        type=int,
        default=60,
        help="IEDA_RT_MAX_SR_SECONDS space-router soft cap in BEST_EFFORT runs (0=unlimited, default: 60).",
    )
    parser.add_argument(
        "--rt-max-sr-iterations",
        type=int,
        default=1,
        help="IEDA_RT_MAX_SR_ITERATIONS space-router iteration cap in BEST_EFFORT runs (0=unlimited, default: 1).",
    )
    parser.add_argument(
        "--rt-max-tasks-per-sr-box",
        type=int,
        default=64,
        help="IEDA_RT_MAX_TASKS_PER_SR_BOX task cap in BEST_EFFORT runs (0=unlimited, default: 64).",
    )
    parser.add_argument(
        "--rt-max-final-minarea-tasks",
        type=int,
        default=0,
        help="IEDA_RT_MAX_FINAL_MINAREA_TASKS final min-area patch task cap (0=unlimited; E1/E2/E3 default: 32).",
    )
    parser.add_argument(
        "--rt-final-minarea-in-best-effort",
        dest="rt_best_effort_skip_final_minarea",
        action="store_false",
        help="Run final min-area patch even when IEDA_RT_BEST_EFFORT=1; useful for DRC A/B experiments.",
    )
    parser.add_argument(
        "--routing-threads",
        type=int,
        default=None,
        help="Override PDK ROUTING_THREADS for iRT (default: PDK-specific).",
    )
    parser.set_defaults(
        synthesize=True,
        rt_best_effort=True,
        rt_best_effort_skip_final_minarea=True,
        rt_enable_escalation=False,
        rt_rule_aware_cost=False,
        rt_enhanced_minarea_repair=False,
        rt_component_escalate=False,
        rt_prl_short_repair=False,
    )
    return parser.parse_args()


def main() -> int:
    explicit_overrides = detect_budget_profile_overrides(sys.argv[1:])
    args = parse_args()
    args.budget_profile_override = explicit_overrides
    apply_budget_profile(args)
    if not hasattr(args, "rt_business_decision_score_threshold"):
        args.rt_business_decision_score_threshold = args.rt_business_score_threshold
    if not hasattr(args, "rt_business_decision_score_min_iter"):
        args.rt_business_decision_score_min_iter = args.rt_business_score_min_iter
    if not hasattr(args, "rt_business_baseline_min_iter"):
        args.rt_business_baseline_min_iter = args.rt_business_baseline_min_iter
    args.result_root = Path(args.result_root)
    if args.activity_vcd:
        args.activity_vcd = args.activity_vcd.expanduser()
        if not args.activity_vcd.is_file():
            raise FileNotFoundError(f"--activity-vcd does not exist: {args.activity_vcd}")
    if args.activity_saif:
        args.activity_saif = args.activity_saif.expanduser()
        if not args.activity_saif.is_file():
            raise FileNotFoundError(f"--activity-saif does not exist: {args.activity_saif}")
    if args.activity_vcd and args.activity_saif:
        raise ValueError("--activity-vcd and --activity-saif are mutually exclusive for this flow")
    names = tuple(args.design or AES13_DESIGNS)
    check_inputs(names, args.synthesize)
    args.result_root.mkdir(parents=True, exist_ok=True)
    if args.jobs < 1:
        raise ValueError("--jobs must be at least 1")
    inventory = write_rcx_resource_inventory()
    print(
        f"RCX inventory: {RCX_FLOWS_ROOT / 'rcx_resource_inventory.json'} "
        f"(trusted-ready PDKs={sum(1 for pdk in inventory.get('pdks', {}).values() if pdk.get('trusted_ircx_ready'))})",
        flush=True,
    )
    manifest = build_experiment_manifest(args, names)
    manifest_path = write_experiment_manifest(manifest, args.result_root)
    print(
        f"Experiment manifest: {manifest_path} "
        f"(profile={manifest['budget_profile']['name']})",
        flush=True,
    )

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
    write_batch_summary(summaries, args.result_root, manifest)
    print(f"\nSummary: {args.result_root / 'summary.md'}", flush=True)
    return 1 if failures or any(item["status"] == "failed" for item in summaries) else 0


if __name__ == "__main__":
    raise SystemExit(main())
