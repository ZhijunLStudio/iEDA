#!/usr/bin/env python3
"""Reproducible AES 13-design synthesis and iEDA physical-design flow."""

from __future__ import annotations

import argparse
import concurrent.futures
import hashlib
import json
import os
import platform
import re
import shutil
import socket
import subprocess
import sys
import time
from dataclasses import dataclass
from datetime import datetime
from functools import lru_cache
from pathlib import Path
from typing import Any, Iterable


REPO_ROOT = Path(__file__).resolve().parents[2]
BENCHMARK_ROOT = REPO_ROOT / "benchmarks"
DESIGNS_ROOT = BENCHMARK_ROOT / "designs"
OUTPUT_ROOT = BENCHMARK_ROOT / "results" / "aes13"
FOUNDRY_ROOT = Path("/home/lxq/AiEDA/Foundary")
IEDA_BIN = REPO_ROOT / "bin" / "iEDA"
YOSYS_BIN = Path("/home/lxq/AiEDA/micromamba/envs/ieda3d/bin/yosys")
KLAYOUT_BIN = shutil.which("klayout")
BUILD_LIB = Path("/home/lxq/AiEDA/micromamba/envs/ieda-build/lib")
FLOW_ARTIFACT_VERSION = 3
STAGE_CONTRACT_VERSION = "1.0"
DEFAULT_PROTOCOL = REPO_ROOT / "benchmarks/qor/parity_protocol.json"
THREAD_ENVIRONMENT_KEYS = (
    "OMP_NUM_THREADS",
    "OMP_THREAD_LIMIT",
    "OPENBLAS_NUM_THREADS",
    "MKL_NUM_THREADS",
    "BLIS_NUM_THREADS",
    "NUMEXPR_NUM_THREADS",
    "RAYON_NUM_THREADS",
    "ROUTING_THREADS",
    "IEDA_THREADS",
)
PROFILE_STAGE_BY_FLOW_STAGE = {
    "floorplan": "iFP",
    "fanout": "iNO",
    "placement": "iPL-GP",
    "cts": "iCTS",
    "legalization": "iPL-DP",
    "routing": "iRT",
    "rcx": "iRCX",
    "timing": "iSTA",
    "power": "iPW",
    "metrics": "evaluation",
    "drc": "iDRC",
    "filler": "iPL-filler",
    "gds": "GDS",
}

if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))

from benchmarks.qor.performance_profile import validate_record as validate_performance_record  # noqa: E402
from benchmarks.qor.quality_metrics import build_quality_summary, git_identity  # noqa: E402
from benchmarks.qor.validate_qor import validate_summary  # noqa: E402
from benchmarks.qor.validate_protocol import load_and_validate_protocol  # noqa: E402
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
    driving_pin: str
    bottom_routing_layer: str
    top_routing_layer: str


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
        driving_pin="X",
        bottom_routing_layer="met1",
        top_routing_layer="met5",
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
        driving_pin="Z",
        bottom_routing_layer="metal1",
        top_routing_layer="metal6",
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
        driving_pin="Y",
        bottom_routing_layer="M1",
        top_routing_layer="M6",
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
        driving_pin="Y",
        bottom_routing_layer="MET1",
        top_routing_layer="MET5",
    ),
}


@dataclass(frozen=True)
class Stage:
    name: str
    script: str
    expected: str | None = None
    required: bool = True
    requires: tuple[str, ...] = ()
    optional_requires: tuple[str, ...] = ()


STAGES = (
    Stage("floorplan", "iFP_script/run_iFP.tcl", "iFP_result.def"),
    Stage("fanout", "iNO_script/run_iNO_fix_fanout.tcl", "iTO_fix_fanout_result.def", requires=("floorplan",)),
    Stage("placement", "iPL_script/run_iPL.tcl", "iPL_result.def", requires=("fanout",)),
    Stage("cts", "iCTS_script/run_iCTS.tcl", "iCTS_result.def", requires=("placement",)),
    Stage("legalization", "iPL_script/run_iPL_legalization.tcl", "iPL_lg_result.def", requires=("cts",)),
    Stage("routing", "iRT_script/run_iRT.tcl", "iRT_result.def", requires=("legalization",)),
    Stage("rcx", "custom/run_rcx.tcl", requires=("routing",)),
    Stage(
        "timing", "custom/run_timing.tcl", "timing/aes_cipher_top.rpt", False,
        requires=("routing",), optional_requires=("rcx",),
    ),
    Stage(
        "power", "custom/run_power.tcl", "power/aes_cipher_top.pwr", False,
        requires=("routing",), optional_requires=("timing",),
    ),
    Stage("metrics", "custom/run_metrics.tcl", "report/wirelength.rpt", False, requires=("routing",)),
    Stage("drc", "iRT_script/run_iRT_DRC.tcl", "report/drc/iRT_drc.rpt", False, requires=("routing",)),
    Stage("filler", "iPL_script/run_iPL_filler.tcl", "iPL_filler_result.def", False, requires=("routing",)),
    Stage(
        "gds", "DB_script/run_def_to_gds_text.tcl", "final.gds", False,
        requires=("routing",), optional_requires=("filler",),
    ),
)

STAGE_ADDITIONAL_OUTPUTS = {
    "fanout": ("iNO_fix_fanout_result.def",),
    "metrics": (
        "report/congestion.rpt",
        "egr_congestion_map/place_egr_horizontal_overflow.csv",
        "egr_congestion_map/place_egr_vertical_overflow.csv",
        "egr_congestion_map/place_egr_union_overflow.csv",
    ),
    "gds": ("visualizations/final.png",),
}

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


def resolve_performance_contract(
    performance_protocol: dict[str, Any], cli_threads: int | None
) -> dict[str, Any]:
    protocol_threads = performance_protocol["threads"]
    if cli_threads is not None and cli_threads < 1:
        raise ValueError("--threads must be at least 1")
    overridden = cli_threads is not None
    threads = cli_threads if overridden else protocol_threads
    if overridden:
        reason = (
            f"CLI thread override ({threads}) bypasses frozen protocol value "
            f"({protocol_threads}); the single-pass AES13 runner is not G21-comparable"
        )
    else:
        reason = (
            "single-pass AES13 runner does not enforce exclusive-host, cache-state, "
            "or repeated-sample controls"
        )
    return {
        "threads": threads,
        "protocol_threads": protocol_threads,
        "thread_source": "cli_override" if overridden else "protocol",
        "g21_mode": "observational",
        "g21_comparability": "non_comparable",
        "reason": reason,
    }


def controlled_thread_environment(base: dict[str, str], threads: int) -> dict[str, str]:
    env = base.copy()
    for key in THREAD_ENVIRONMENT_KEYS:
        env[key] = str(threads)
    return env


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


def synthesize_design(
    name: str,
    config: dict,
    output_dir: Path,
    timeout: int,
    threads: int,
) -> Path:
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
        env=controlled_thread_environment(os.environ, threads),
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


def current_file_record(path: Path) -> dict[str, Any]:
    """Return an uncached content identity for mutable stage artifacts."""
    resolved = path.resolve()
    digest = hashlib.sha256()
    with resolved.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    stat = resolved.stat()
    return {
        "path": str(resolved),
        "sha256": digest.hexdigest(),
        "size_bytes": stat.st_size,
    }


def canonical_sha256(value: Any) -> str:
    encoded = json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=True).encode("ascii")
    return hashlib.sha256(encoded).hexdigest()


def _proc_field(path: Path, field: str) -> str | None:
    try:
        with path.open(encoding="utf-8", errors="replace") as stream:
            for line in stream:
                key, separator, value = line.partition(":")
                if separator and key.strip() == field:
                    return value.strip()
    except OSError:
        return None
    return None


def hardware_manifest() -> dict[str, Any]:
    numa_path = Path("/sys/devices/system/node/online")
    try:
        numa_nodes = numa_path.read_text(encoding="ascii").strip()
    except OSError:
        numa_nodes = None
    return {
        "schema_version": "1.0",
        "hostname": socket.gethostname(),
        "machine": platform.machine(),
        "platform": platform.platform(),
        "kernel_release": platform.release(),
        "cpu_model": _proc_field(Path("/proc/cpuinfo"), "model name"),
        "microcode": _proc_field(Path("/proc/cpuinfo"), "microcode"),
        "logical_cpu_count": os.cpu_count(),
        "numa_nodes": numa_nodes,
        "memory_total": _proc_field(Path("/proc/meminfo"), "MemTotal"),
    }


def write_json_evidence(path: Path, payload: dict[str, Any]) -> dict[str, Any]:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    temporary.replace(path)
    return current_file_record(path)


def prepare_performance_evidence(
    output_root: Path, performance: dict[str, Any]
) -> dict[str, Any]:
    git_commit, dirty = git_identity(REPO_ROOT)
    binary = current_file_record(IEDA_BIN)
    build = write_json_evidence(
        output_root / "performance/build_manifest.json",
        {
            "schema_version": "1.0",
            "binary": binary,
            "git_commit": git_commit,
            "dirty": dirty,
        },
    )
    hardware = write_json_evidence(
        output_root / "performance/hardware_manifest.json",
        hardware_manifest(),
    )
    return {
        "binary": binary,
        "build_manifest": build,
        "hardware_manifest": hardware,
        "hostname": socket.gethostname(),
        "exclusive_host": False,
        "comparable": False,
        "non_comparable_reason": performance["reason"],
    }


def build_performance_record(
    *,
    design: str,
    stage: str,
    status: str,
    wall_sec: float,
    run_id: str,
    cache_mode: str,
    performance: dict[str, Any],
    evidence: dict[str, Any],
    input_manifest_sha256: str,
) -> dict[str, Any]:
    record = {
        "schema_version": "1.0",
        "tool_role": "ieda",
        "tool": "iEDA",
        "design": design,
        "stage": stage,
        "run_id": run_id,
        "repeat": 1,
        "cache_mode": cache_mode,
        "wall_sec": max(float(wall_sec), 1e-9),
        "user_cpu_sec": 0.0,
        "system_cpu_sec": 0.0,
        "threads": performance["threads"],
        "hostname": evidence["hostname"],
        "binary_sha256": evidence["binary"]["sha256"],
        "build_manifest_sha256": evidence["build_manifest"]["sha256"],
        "hardware_manifest_sha256": evidence["hardware_manifest"]["sha256"],
        "input_manifest_sha256": input_manifest_sha256,
        "exclusive_host": evidence["exclusive_host"],
        "status": status,
        "comparable": evidence["comparable"],
        "non_comparable_reason": evidence["non_comparable_reason"],
    }
    errors = validate_performance_record(record)
    if errors:
        raise ValueError("invalid performance profile record: " + "; ".join(errors))
    return record


def build_design_performance_records(
    summary: dict[str, Any],
    *,
    run_id: str,
    cache_mode: str,
    performance: dict[str, Any],
    evidence: dict[str, Any],
    input_manifest_sha256: str,
    e2e_wall_sec: float,
) -> list[dict[str, Any]]:
    records = []
    has_resumed_stage = False
    for flow_stage, result in summary.get("stages", {}).items():
        if flow_stage not in PROFILE_STAGE_BY_FLOW_STAGE:
            continue
        if result.get("status") == "skipped":
            has_resumed_stage = True
            continue
        if result.get("status") not in {"success", "failed"}:
            continue
        elapsed = result.get("elapsed_sec")
        if not isinstance(elapsed, (int, float)) or isinstance(elapsed, bool):
            continue
        records.append(
            build_performance_record(
                design=summary["design"],
                stage=PROFILE_STAGE_BY_FLOW_STAGE[flow_stage],
                status=result["status"],
                wall_sec=elapsed,
                run_id=run_id,
                cache_mode=cache_mode,
                performance=performance,
                evidence=evidence,
                input_manifest_sha256=input_manifest_sha256,
            )
        )
    if records and not has_resumed_stage:
        records.append(
            build_performance_record(
                design=summary["design"],
                stage="e2e",
                status="success" if summary.get("status") == "success" else "failed",
                wall_sec=e2e_wall_sec,
                run_id=run_id,
                cache_mode=cache_mode,
                performance=performance,
                evidence=evidence,
                input_manifest_sha256=input_manifest_sha256,
            )
        )
    return records


def write_performance_profile(path: Path, records: list[dict[str, Any]]) -> dict[str, Any] | None:
    if not records:
        path.unlink(missing_ok=True)
        return None
    validation_errors = [
        error
        for index, record in enumerate(records)
        for error in validate_performance_record(record, f"record[{index}]")
    ]
    if validation_errors:
        raise ValueError("invalid performance profile: " + "; ".join(validation_errors))
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(
        "".join(json.dumps(record, sort_keys=True) + "\n" for record in records),
        encoding="utf-8",
    )
    temporary.replace(path)
    return current_file_record(path)


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
            {
                "path": str(path.resolve()),
                "sha256": file_sha256(path),
                "size_bytes": path.stat().st_size,
            }
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
    driving_pin = args.driving_pin or pdk.driving_pin
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
            f"set_driving_cell -lib_cell {driving_cell} -pin {driving_pin} {input_collection}"
        )
    if not re.search(r"(?m)^\s*set_load\b", text):
        additions.append(f"set_load {args.output_load:.6g} {output_collection}")
    additions.extend(
        (
            "",
            f"# iEDA constraint policy: io_delay_pct={args.io_delay_pct:.6g}, "
            f"clock_uncertainty_pct={args.clock_uncertainty_pct:.6g}, "
            f"output_load={args.output_load:.6g}, driving_cell={driving_cell}/{driving_pin}",
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

    no_path = workspace / "iEDA_config/no_default_config_fixfanout.json"
    with no_path.open(encoding="utf-8") as stream:
        no_config = json.load(stream)
    no_config["insert_buffer"] = pdk.cts_buffers[-1]
    with no_path.open("w", encoding="utf-8") as stream:
        json.dump(no_config, stream, indent=4)
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
    threads: int,
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
    env = controlled_thread_environment(dict(os.environ), threads)
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


def stage_manifest_path(workspace: Path, stage: Stage) -> Path:
    return workspace / "result" / "manifests" / f"{stage.name}.json"


def generated_workspace_records(workspace: Path) -> list[dict[str, Any]]:
    records = []
    for directory in ("script", "iEDA_config"):
        root = workspace / directory
        if not root.is_dir():
            continue
        for path in sorted(candidate for candidate in root.rglob("*") if candidate.is_file()):
            record = current_file_record(path)
            record["path"] = path.relative_to(workspace).as_posix()
            records.append(record)
    return records


def stage_output_paths(stage: Stage, workspace: Path) -> list[Path]:
    result_dir = workspace / "result"
    relative_paths = []
    if stage.expected:
        relative_paths.append(stage.expected)
    relative_paths.extend(STAGE_ADDITIONAL_OUTPUTS.get(stage.name, ()))
    return [result_dir / relative for relative in dict.fromkeys(relative_paths)]


def clear_stage_evidence(stage: Stage, workspace: Path) -> None:
    stage_manifest_path(workspace, stage).unlink(missing_ok=True)
    for path in stage_output_paths(stage, workspace):
        path.unlink(missing_ok=True)


def stage_not_applicable_reason(stage: Stage, vcd_path: Path | None) -> str | None:
    if stage.name == "power" and vcd_path is None:
        return (
            "no VCD/SAIF activity evidence was provided; "
            "vectorless power fallback is forbidden"
        )
    return None


def not_applicable_stage_result(
    stage: Stage, workspace: Path, vcd_path: Path | None
) -> dict[str, Any] | None:
    reason = stage_not_applicable_reason(stage, vcd_path)
    if reason is None:
        return None
    clear_stage_evidence(stage, workspace)
    outputs = stage_output_paths(stage, workspace)
    return {
        "status": "not_applicable",
        "returncode": None,
        "artifact": str(outputs[0]) if outputs else None,
        "artifacts": [],
        "reason": reason,
        "freshness": "not_produced",
    }


def stage_prerequisite_records(stage: Stage, stage_results: dict[str, dict]) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    for name in (*stage.requires, *stage.optional_requires):
        result = stage_results.get(name)
        required = name in stage.requires
        if result is None or result.get("status") not in {"success", "skipped"}:
            if required:
                raise RuntimeError(f"{stage.name} requires successful stage {name}")
            continue
        paths = result.get("artifacts") or ([result.get("artifact")] if result.get("artifact") else [])
        artifacts = []
        for value in paths:
            path = Path(value)
            if not path.is_file() or path.stat().st_size == 0:
                if required:
                    raise RuntimeError(f"{stage.name} prerequisite {name} has missing artifact: {path}")
                continue
            artifacts.append(current_file_record(path))
        if required and not artifacts:
            raise RuntimeError(f"{stage.name} prerequisite {name} has no verified artifact")
        if artifacts:
            records.append({"stage": name, "artifacts": artifacts})
    return records


def stage_fingerprint(
    stage: Stage,
    workspace: Path,
    input_signature_sha256: str,
    prerequisites: list[dict[str, Any]],
) -> tuple[str, dict[str, Any]]:
    script = workspace / "script" / stage.script
    script_record = current_file_record(script)
    payload = {
        "contract_version": STAGE_CONTRACT_VERSION,
        "stage_contract": {
            "name": stage.name,
            "script": stage.script,
            "expected": stage.expected,
            "required": stage.required,
            "requires": list(stage.requires),
            "optional_requires": list(stage.optional_requires),
        },
        "input_signature_sha256": input_signature_sha256,
        "script": script_record,
        "generated_workspace": generated_workspace_records(workspace),
        "prerequisites": prerequisites,
    }
    return canonical_sha256(payload), payload


def validate_stage_manifest(
    stage: Stage,
    workspace: Path,
    input_signature_sha256: str,
    prerequisites: list[dict[str, Any]],
) -> tuple[bool, str, dict[str, Any] | None]:
    path = stage_manifest_path(workspace, stage)
    script = workspace / "script" / stage.script
    if not path.is_file():
        return False, "success manifest is missing", None
    if not script.is_file() or script.stat().st_size == 0:
        return False, f"stage script is missing or empty: {script}", None
    try:
        manifest = json.loads(path.read_text(encoding="utf-8"))
        fingerprint, _ = stage_fingerprint(stage, workspace, input_signature_sha256, prerequisites)
    except (OSError, json.JSONDecodeError, ValueError) as exc:
        return False, f"manifest cannot be validated: {exc}", None
    if manifest.get("contract_version") != STAGE_CONTRACT_VERSION:
        return False, "stage contract version changed", manifest
    if manifest.get("stage") != stage.name or manifest.get("status") != "success":
        return False, "manifest does not record successful completion of this stage", manifest
    if manifest.get("returncode") != 0:
        return False, "manifest return code is not zero", manifest
    if manifest.get("fingerprint") != fingerprint:
        return False, "script, input, or prerequisite fingerprint changed", manifest
    artifact_records = manifest.get("artifacts")
    if not isinstance(artifact_records, list) or not artifact_records:
        return False, "manifest has no stage artifacts", manifest
    for record in artifact_records:
        try:
            current = current_file_record(Path(record["path"]))
        except (KeyError, OSError) as exc:
            return False, f"manifest artifact is missing: {exc}", manifest
        if current != record:
            return False, f"artifact content changed: {record.get('path')}", manifest
    return True, "manifest and artifact hashes match", manifest


def write_stage_manifest(
    stage: Stage,
    workspace: Path,
    input_signature_sha256: str,
    prerequisites: list[dict[str, Any]],
    result: dict[str, Any],
) -> dict[str, Any]:
    if result.get("status") != "success" or result.get("returncode") != 0:
        raise ValueError(f"cannot stamp unsuccessful stage {stage.name}")
    artifact_paths = result.get("artifacts") or ([result.get("artifact")] if result.get("artifact") else [])
    artifacts = []
    for value in artifact_paths:
        path = Path(value)
        if path.is_file() and path.stat().st_size > 0:
            artifacts.append(current_file_record(path))
    if not artifacts:
        raise ValueError(f"cannot stamp {stage.name}: no non-empty artifact")
    script = workspace / "script" / stage.script
    fingerprint, payload = stage_fingerprint(stage, workspace, input_signature_sha256, prerequisites)
    manifest = {
        **payload,
        "stage": stage.name,
        "fingerprint": fingerprint,
        "status": "success",
        "returncode": 0,
        "started_epoch_ns": result.get("started_epoch_ns"),
        "elapsed_sec": result.get("elapsed_sec"),
        "completed_at": datetime.now().astimezone().isoformat(),
        "artifacts": artifacts,
    }
    path = stage_manifest_path(workspace, stage)
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(".json.tmp")
    temporary.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    temporary.replace(path)
    result["manifest"] = str(path)
    result["manifest_sha256"] = current_file_record(path)["sha256"]
    result["artifacts"] = [item["path"] for item in artifacts]
    result["artifact"] = artifacts[0]["path"]
    result["freshness"] = "executed_and_hashed"
    return manifest


def run_stage(
    stage: Stage,
    workspace: Path,
    env: dict[str, str],
    timeout: int,
    resume: bool,
    input_signature_sha256: str,
    prerequisites: list[dict[str, Any]],
) -> dict:
    result_dir = workspace / "result"
    expected = result_dir / stage.expected if stage.expected else None
    expected_alternates: list[Path] = []
    if stage.name == "fanout":
        expected_alternates = [result_dir / "iNO_fix_fanout_result.def"]

    script = workspace / "script" / stage.script
    if resume:
        valid, reason, manifest = validate_stage_manifest(
            stage, workspace, input_signature_sha256, prerequisites
        )
        if valid and manifest is not None:
            artifacts = [item["path"] for item in manifest["artifacts"]]
            print(f"    [{stage.name}] skipped ({reason})", flush=True)
            return {
                "status": "skipped",
                "returncode": 0,
                "artifact": artifacts[0],
                "artifacts": artifacts,
                "manifest": str(stage_manifest_path(workspace, stage)),
                "manifest_sha256": current_file_record(stage_manifest_path(workspace, stage))["sha256"],
                "freshness": "manifest_verified",
                "reason": reason,
            }
        print(f"    [{stage.name}] resume rejected: {reason}; rerunning", flush=True)
    clear_stage_evidence(stage, workspace)
    started = time.monotonic()
    if not script.is_file() or script.stat().st_size == 0:
        return {
            "status": "failed",
            "elapsed_sec": time.monotonic() - started,
            "returncode": 2,
            "artifact": str(expected) if expected else None,
            "reason": f"missing or empty stage script: {script}",
            "freshness": "not_produced",
        }
    log_file = result_dir / "logs" / f"{stage.name}.log"
    print(f"    [{stage.name}] running", flush=True)
    started_epoch_ns = time.time_ns()
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
    expected_candidates = [path for path in (expected, *expected_alternates) if path is not None]
    fresh_artifacts = [
        path
        for path in expected_candidates
        if path.is_file() and path.stat().st_size > 0 and path.stat().st_mtime_ns >= started_epoch_ns
    ]
    if fresh_artifacts:
        expected = fresh_artifacts[0]
    artifact_ok = stage.expected is None or bool(fresh_artifacts)
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
        "artifacts": [str(expected)] if artifact_ok and expected is not None else [],
        "reason": reason,
        "freshness": "executed_fresh" if artifact_ok else "stale_or_missing",
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
    e2e_started = time.monotonic()
    config = load_design(name)
    pdk_name = design_pdk(name, config)
    output_root = Path(args.output_root)
    output_dir = output_root / name
    output_dir.mkdir(parents=True, exist_ok=True)
    print(f"\n[{name}] PDK={pdk_name} strategy={strategy_for(name)}", flush=True)
    if args.synthesize:
        netlist = synthesize_design(name, config, output_dir, args.timeout, args.performance["threads"])
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
    evidence_paths = tuple(
        path
        for path in (sdc_path, spef_path, vcd_path, rcx_config, ir_report, args.protocol_path)
        if path is not None
    )
    run_config = {
        "protocol_sha256": args.protocol_record["sha256"],
        "performance": args.performance,
        "route_iterations": args.rt_max_iterations,
        "spef": str(spef_path) if spef_path else None,
        "vcd": str(vcd_path) if vcd_path else None,
        "vcd_top": args.vcd_top,
        "rcx_config": str(rcx_config) if rcx_config else None,
        "rcx_corner": args.rcx_corner,
        "ir_report": str(ir_report) if ir_report else None,
        "pdk_contract": {
            "bottom_routing_layer": pdk.bottom_routing_layer,
            "top_routing_layer": pdk.top_routing_layer,
            "insert_buffer": pdk.cts_buffers[-1],
        },
        "constraints": {
            "policy": args.constraint_policy,
            "effective_sdc": str(sdc_path),
            "io_delay_pct": args.io_delay_pct,
            "clock_uncertainty_pct": args.clock_uncertainty_pct,
            "output_load": args.output_load,
            "driving_cell": args.driving_cell or pdk.cts_buffers[0],
            "driving_pin": args.driving_pin or pdk.driving_pin,
        },
        "floorplan": floorplan,
    }
    signature = build_input_signature(name, pdk_name, pdk, netlist, run_config, evidence_paths)
    input_signature_sha256 = canonical_sha256(signature)
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
        args.performance["threads"],
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
            not_applicable = not_applicable_stage_result(stage, workspace, vcd_path)
            if not_applicable is not None:
                stage_results[stage.name] = not_applicable
                print(f"    [{stage.name}] not applicable: {not_applicable['reason']}", flush=True)
                if args.stop_after == stage.name:
                    status = "partial"
                    break
                continue
            prerequisites = stage_prerequisite_records(stage, stage_results)
            stage_result = run_stage(
                stage,
                workspace,
                env,
                args.timeout,
                args.resume and not reset,
                input_signature_sha256,
                prerequisites,
            )
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
            if stage_result["status"] == "success":
                try:
                    write_stage_manifest(
                        stage,
                        workspace,
                        input_signature_sha256,
                        prerequisites,
                        stage_result,
                    )
                except (OSError, ValueError) as exc:
                    stage_result["status"] = "failed"
                    stage_result["reason"] = f"stage success manifest failed: {exc}"
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
        "schema_version": "1.0",
        "run_id": args.run_id,
        "design": name,
        "pdk": pdk_name,
        "strategy": strategy_for(name),
        "status": status,
        "timestamp": datetime.now().astimezone().isoformat(),
        "netlist": str(netlist),
        "workspace": str(workspace),
        "route_iterations": args.rt_max_iterations,
        "manifest": {
            "stage_contract_version": STAGE_CONTRACT_VERSION,
            "input_signature_sha256": input_signature_sha256,
            "protocol": args.protocol_record,
            "performance": args.performance,
        },
        "performance": args.performance,
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
    quality["provenance"]["performance"] = args.performance
    validation_errors = validate_summary(quality, verify_files=True)
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
    profile_records = build_design_performance_records(
        summary,
        run_id=args.run_id,
        cache_mode=args.profile_cache_mode,
        performance=args.performance,
        evidence=args.performance_evidence,
        input_manifest_sha256=input_signature_sha256,
        e2e_wall_sec=time.monotonic() - e2e_started,
    )
    profile_record = write_performance_profile(
        output_dir / "performance_profile.jsonl", profile_records
    )
    summary["performance_profile"] = (
        {**profile_record, "record_count": len(profile_records), "status": "observational"}
        if profile_record
        else {
            "status": "not_measured",
            "reason": "no freshly executed stage was available for profiling",
        }
    )
    write_design_summary(output_dir, summary)
    return summary


def batch_exit_code(
    summaries: list[dict], *, prepare_only: bool = False, stop_after: str | None = None
) -> int:
    has_execution_failure = any(
        summary.get("status") in {"error", "failed"}
        or any(stage.get("status") == "failed" for stage in summary.get("stages", {}).values())
        for summary in summaries
    )
    if has_execution_failure:
        return 1
    allowed = {"prepared"} if prepare_only else ({"partial"} if stop_after else {"success"})
    return 0 if summaries and all(summary.get("status") in allowed for summary in summaries) else 1


def batch_overall_status(summaries: list[dict], exit_code: int) -> str:
    if exit_code != 0:
        return "fail"
    quality_statuses = [summary.get("quality", {}).get("overall_status") for summary in summaries]
    return "pass" if quality_statuses and all(status == "pass" for status in quality_statuses) else "observational"


def write_batch_performance_profile(
    summaries: list[dict[str, Any]], output_root: Path
) -> dict[str, Any] | None:
    records: list[dict[str, Any]] = []
    for summary in summaries:
        profile = summary.get("performance_profile", {})
        path_value = profile.get("path") if isinstance(profile, dict) else None
        if not path_value:
            continue
        path = Path(path_value)
        try:
            lines = path.read_text(encoding="utf-8").splitlines()
        except OSError as exc:
            raise RuntimeError(f"cannot collect performance profile {path}: {exc}") from exc
        for line_number, line in enumerate(lines, 1):
            try:
                record = json.loads(line)
            except json.JSONDecodeError as exc:
                raise RuntimeError(
                    f"invalid performance profile JSON at {path}:{line_number}: {exc.msg}"
                ) from exc
            errors = validate_performance_record(record, f"{path}:{line_number}")
            if errors:
                raise RuntimeError("invalid performance profile: " + "; ".join(errors))
            records.append(record)
    profile_record = write_performance_profile(
        output_root / "performance_profile.jsonl", records
    )
    return (
        {**profile_record, "record_count": len(records), "status": "observational"}
        if profile_record
        else None
    )


def write_batch_summary(
    summaries: list[dict],
    output_root: Path,
    expected_designs: Iterable[str],
    run_id: str,
    protocol_record: dict[str, Any],
    expected_exit_code: int,
    quality_gate: str,
    performance: dict[str, Any],
) -> None:
    output_root.mkdir(parents=True, exist_ok=True)
    performance_profile = write_batch_performance_profile(summaries, output_root)
    design_records = []
    for summary in summaries:
        summary_path = output_root / summary["design"] / "summary.json"
        if (
            summary.get("run_id") == run_id
            and summary_path.is_file()
            and summary_path.stat().st_size > 0
        ):
            design_records.append(current_file_record(summary_path))
    status_counts: dict[str, int] = {}
    for summary in summaries:
        status = str(summary.get("status", "unknown"))
        status_counts[status] = status_counts.get(status, 0) + 1
    batch = {
        "schema_version": "1.0",
        "run_id": run_id,
        "timestamp": datetime.now().astimezone().isoformat(),
        "overall_status": batch_overall_status(summaries, expected_exit_code),
        "execution_status": "pass" if expected_exit_code == 0 else "fail",
        "quality_gate": quality_gate,
        "performance": performance,
        "expected_designs": list(expected_designs),
        "design_count": len(summaries),
        "status_counts": status_counts,
        "manifest": {
            "protocol": protocol_record,
            "performance": performance,
            "binary": current_file_record(IEDA_BIN) if IEDA_BIN.is_file() else None,
            "performance_profile": performance_profile,
            "design_summaries": design_records,
            "design_summaries_sha256": canonical_sha256(design_records),
        },
        "summaries": summaries,
    }
    with (output_root / "summary.json").open("w", encoding="utf-8") as stream:
        json.dump(batch, stream, indent=2)
        stream.write("\n")
    lines = [
        "# AES 13-version iEDA results",
        "",
        f"- Run ID: {run_id}",
        f"- Overall status: {batch['overall_status']}",
        f"- Execution status: {batch['execution_status']}",
        f"- Quality gate: {quality_gate}",
        f"- Protocol SHA-256: {protocol_record['sha256']}",
        f"- Threads: {performance['threads']} ({performance['thread_source']})",
        f"- G21: {performance['g21_mode']} / {performance['g21_comparability']}",
        f"- G21 reason: {performance['reason'] or '-'}",
        f"- Performance profile: {performance_profile['path'] if performance_profile else 'not measured'}",
        "",
        "| Design | PDK | Strategy | Flow | Quality | DEF | GDS | Reports | PNG |",
        "|---|---|---|---|---|---:|---:|---:|---:|",
    ]
    for summary in summaries:
        artifacts = summary["artifacts"]
        lines.append(
            f"| {summary['design']} | {summary['pdk']} | {summary['strategy']} | "
            f"{summary['status']} | {summary.get('quality', {}).get('overall_status', '-')} | "
            f"{len(artifacts['def'])} | {len(artifacts['gds'])} | "
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
    parser.add_argument("--driving-pin", help="Override the PDK-specific driving cell output pin")
    parser.add_argument("--quality-gate", choices=("report", "strict"), default="report")
    parser.add_argument("--protocol", type=Path, default=DEFAULT_PROTOCOL)
    parser.add_argument(
        "--threads",
        type=int,
        help="Override protocol threads; records the run as G21 non-comparable",
    )
    parser.add_argument(
        "--profile-cache-mode",
        choices=("cold", "warm"),
        default="warm",
        help="Label this observational sample; the runner does not enforce cache state",
    )
    parser.add_argument("--output-root", type=Path, default=OUTPUT_ROOT)
    parser.set_defaults(synthesize=True)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    names = tuple(args.design or AES13_DESIGNS)
    args.output_root = args.output_root.expanduser().resolve()
    args.protocol_path = args.protocol.expanduser().resolve()
    args.protocol, args.protocol_record = load_and_validate_protocol(args.protocol_path)
    args.performance = resolve_performance_contract(args.protocol["performance"], args.threads)
    args.run_id = (
        datetime.now().astimezone().strftime("aes13-%Y%m%dT%H%M%S%z")
        + f"-{time.time_ns()}"
    )
    missing_protocol_designs = sorted(set(names) - set(args.protocol["primary_pnr_by_design"]))
    if missing_protocol_designs:
        raise ValueError(
            "parity protocol has no frozen primary PnR for: " + ", ".join(missing_protocol_designs)
        )
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
    if args.jobs < 1:
        raise ValueError("--jobs must be at least 1")
    check_inputs(names, args.synthesize)
    args.output_root.mkdir(parents=True, exist_ok=True)
    args.performance_evidence = prepare_performance_evidence(
        args.output_root, args.performance
    )
    args.performance["profile_evidence"] = args.performance_evidence

    def run_safely(name: str) -> dict:
        try:
            return run_design(name, args)
        except Exception as exc:
            print(f"[{name}] ERROR: {exc}", file=sys.stderr, flush=True)
            return {
                "schema_version": "1.0",
                "run_id": args.run_id,
                "design": name,
                "pdk": load_design(name).get("pdk", "sky130"),
                "strategy": strategy_for(name),
                "status": "error",
                "timestamp": datetime.now().astimezone().isoformat(),
                "error": str(exc),
                "manifest": {
                    "protocol": args.protocol_record,
                    "performance": args.performance,
                },
                "performance": args.performance,
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
    exit_code = batch_exit_code(
        summaries,
        prepare_only=args.prepare_only,
        stop_after=args.stop_after,
    )
    write_batch_summary(
        summaries,
        args.output_root,
        names,
        args.run_id,
        args.protocol_record,
        exit_code,
        args.quality_gate,
        args.performance,
    )
    print(f"\nSummary: {args.output_root / 'summary.md'}", flush=True)
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
