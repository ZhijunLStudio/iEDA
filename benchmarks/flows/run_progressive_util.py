#!/usr/bin/env python3
"""
渐进式利用率测试脚本：支持 40% → 50% → 55% → 60% → 65%
基于 run_full_flow_65pct.py 改造，支持任意利用率参数
"""

from pathlib import Path
import subprocess
import os
import sys
import json
import argparse
from datetime import datetime

REPO_ROOT = Path("/home/lxq/AiEDA/iEDA.ai")
FOUNDRY_ROOT = Path("/home/lxq/AiEDA/Foundary")

# 利用率 → 芯片尺寸映射（假设 65% @ 580x580 为基准）
# cell_area ≈ 0.65 * 580 * 580 = 218660 um²
UTIL_TO_DIE_SIZE = {
    35: 800,  # 218660 / 0.35 = 624743 → 790 um
    40: 750,  # 218660 / 0.40 = 546650 → 739 um
    45: 700,  # 218660 / 0.45 = 486022 → 697 um
    50: 670,  # 218660 / 0.50 = 437320 → 661 um
    55: 640,  # 218660 / 0.55 = 397564 → 630 um
    60: 610,  # 218660 / 0.60 = 364433 → 604 um
    65: 580,  # 218660 / 0.65 = 336400 → 580 um (baseline)
    70: 560,  # 218660 / 0.70 = 312371 → 559 um
}

def get_pdk_config(design_name, util_pct):
    """获取 PDK 配置"""
    if "sky130" in design_name or design_name == "aes":
        return {
            "pdk": "sky130",
            "tech_lef": FOUNDRY_ROOT / "sky130/lef/sky130_fd_sc_hd.tlef",
            "cell_lef": FOUNDRY_ROOT / "sky130/lef/sky130_fd_sc_hd_merged.lef",
            "lib": FOUNDRY_ROOT / "sky130/lib/sky130_fd_sc_hd__tt_025C_1v80.lib",
            "site": "unithd",
            "tapcell": "sky130_fd_sc_hd__tap_1",
            "endcap": "sky130_fd_sc_hd__fill_1",
            "pin_layer": "met5",
            "cts_buffers": "sky130_fd_sc_hd__buf_1 sky130_fd_sc_hd__buf_2 sky130_fd_sc_hd__buf_4 sky130_fd_sc_hd__buf_8",
            "bottom_routing": "met1",
            "top_routing": "met5",
            "insert_buffer": "sky130_fd_sc_hd__buf_8",
            "filler_cells": "sky130_fd_sc_hd__fill_8 sky130_fd_sc_hd__fill_4 sky130_fd_sc_hd__fill_2 sky130_fd_sc_hd__fill_1",
        }
    elif "nangate45" in design_name:
        return {
            "pdk": "nangate45",
            "tech_lef": FOUNDRY_ROOT / "nangate45/lef/NangateOpenCellLibrary.tech.lef",
            "cell_lef": FOUNDRY_ROOT / "nangate45/lef/NangateOpenCellLibrary.macro.mod.lef",
            "lib": FOUNDRY_ROOT / "nangate45/lib/NangateOpenCellLibrary_typical.lib",
            "site": "FreePDK45_38x28_10R_NP_162NW_34O",
            "tapcell": "TAPCELL_X1",
            "endcap": "TAPCELL_X1",
            "pin_layer": "metal3",
            "cts_buffers": "BUF_X1 BUF_X2 BUF_X4 BUF_X8",
            "bottom_routing": "metal1",
            "top_routing": "metal10",
            "insert_buffer": "BUF_X8",
            "filler_cells": "FILLCELL_X32 FILLCELL_X16 FILLCELL_X8 FILLCELL_X4 FILLCELL_X2 FILLCELL_X1",
        }
    elif "asap7" in design_name:
        workspace = REPO_ROOT / f"benchmarks/results/aes13_{util_pct}pct/{design_name}/workspace"
        return {
            "pdk": "asap7",
            "tech_lef": workspace / "tech/asap7_tech_1x_with_rc.lef",
            "cell_lef": FOUNDRY_ROOT / "asap7/lef/asap7sc7p5t_27_R_1x_201211.lef",
            "lib": FOUNDRY_ROOT / "asap7/lib/asap7sc7p5t_AO_RVT_TT_nldm_201020.lib",
            "site": "asap7sc7p5t",
            "tapcell": "TAPCELL_ASAP7_75t_R",
            "endcap": "TAPCELL_ASAP7_75t_R",
            "pin_layer": "M4",
            "cts_buffers": "BUFx2_ASAP7_75t_R BUFx4_ASAP7_75t_R BUFx6_ASAP7_75t_R",
            "bottom_routing": "M2",
            "top_routing": "M7",
            "insert_buffer": "BUFx4_ASAP7_75t_R",
            "filler_cells": "FILLERxp5_ASAP7_75t_R FILLER_ASAP7_75t_R",
        }
    elif "ics55" in design_name:
        return {
            "pdk": "ics55",
            "tech_lef": FOUNDRY_ROOT / "ics55/prtech/techLEF/N551P6M_ieda.lef",
            "cell_lef": FOUNDRY_ROOT / "ics55/IP/STD_cell/ics55_LLSC_H7C_V1p10C100/ics55_LLSC_H7CR/lef/ics55_LLSC_H7CR_ieda.lef",
            "lib": FOUNDRY_ROOT / "ics55/IP/STD_cell/ics55_LLSC_H7C_V1p10C100/ics55_LLSC_H7CR/liberty/ics55_LLSC_H7CR_typ_tt_1p2_25_nldm.lib",
            "site": "core7",
            "tapcell": "FILLTAPH7R",
            "endcap": "FILLTAPH7R",
            "pin_layer": "MET3",
            "cts_buffers": "BUFX1H7R BUFX2H7R BUFX4H7R BUFX8H7R",
            "bottom_routing": "MET1",
            "top_routing": "MET5",
            "insert_buffer": "BUFX8H7R",
            "filler_cells": "FILLER64H7R FILLER32H7R FILLER16H7R FILLER8H7R FILLER4H7R FILLER2H7R",
        }
    else:
        raise ValueError(f"Unknown PDK for design: {design_name}")

def get_netlist_and_top(design_name):
    """确定正确的 netlist 和 top module"""
    netlist_dir = REPO_ROOT / f"benchmarks/designs/{design_name}/netlist"
    if (netlist_dir / "aes_cipher_top.v").exists():
        return netlist_dir / "aes_cipher_top.v", "aes_cipher_top"
    else:
        return netlist_dir / "aes.v", "aes"

def get_die_area(util_pct):
    """根据利用率计算芯片尺寸"""
    die_size = UTIL_TO_DIE_SIZE[util_pct]
    margin = 10
    return f"0.0 0.0 {die_size}.0 {die_size}.0", f"{margin}.0 {margin}.0 {die_size - margin}.0 {die_size - margin}.0"

def run_stage(design_name, stage_name, script_path, env, timeout=3600):
    """运行单个 iEDA 阶段"""
    util_pct = env.get("UTIL_PCT", "65")
    workspace = REPO_ROOT / f"benchmarks/results/aes13_{util_pct}pct/{design_name}/workspace"
    ieda_bin = REPO_ROOT / "bin/iEDA"
    log_file = workspace / f"result/logs/{stage_name}.log"

    print(f"  [{stage_name}] running...", flush=True)

    result = subprocess.run(
        [str(ieda_bin), "-script", str(script_path)],
        cwd=workspace,
        env=env,
        capture_output=True,
        text=True,
        timeout=timeout
    )

    log_file.parent.mkdir(parents=True, exist_ok=True)
    with open(log_file, 'w') as f:
        f.write(result.stdout)
        f.write("\n")
        f.write(result.stderr)

    if result.returncode == 0:
        print(f"  [{stage_name}] ✓ success", flush=True)
        return True
    else:
        print(f"  [{stage_name}] ✗ failed (code {result.returncode})", flush=True)
        return False

def run_full_flow(design_name, util_pct):
    """运行单个设计的完整流程"""
    print(f"\n{'='*80}")
    print(f"Running {util_pct}% utilization flow: {design_name}")
    print(f"{'='*80}\n")

    workspace = REPO_ROOT / f"benchmarks/results/aes13_{util_pct}pct/{design_name}/workspace"
    pdk_cfg = get_pdk_config(design_name, util_pct)
    netlist_file, top_module = get_netlist_and_top(design_name)
    die_area, core_area = get_die_area(util_pct)

    # 构建环境变量
    env = os.environ.copy()
    env.update({
        "UTIL_PCT": str(util_pct),
        "WORKSPACE": str(workspace),
        "CONFIG_DIR": str(workspace / "iEDA_config"),
        "RESULT_DIR": str(workspace / "result"),
        "TCL_SCRIPT_DIR": str(workspace / "script"),
        "DESIGN_TOP": top_module,
        "TOP_NAME": top_module,
        "CLK_PORT_NAME": "clk",
        "NETLIST_FILE": str(netlist_file),
        "SDC_FILE": str(REPO_ROOT / f"benchmarks/designs/{design_name}/sdc/aes.sdc"),
        "DIE_AREA": die_area,
        "CORE_AREA": core_area,
        "USE_FIXED_BBOX": "True",
        "PLACE_SITE": pdk_cfg["site"],
        "IO_SITE": pdk_cfg["site"],
        "CORNER_SITE": pdk_cfg["site"],
        "TAPCELL": pdk_cfg["tapcell"],
        "ENDCAP": pdk_cfg["endcap"],
        "PIN_LAYER": pdk_cfg["pin_layer"],
        "BOTTOM_ROUTING_LAYER": pdk_cfg["bottom_routing"],
        "TOP_ROUTING_LAYER": pdk_cfg["top_routing"],
        "ROUTING_THREADS": "64",
        "TECH_LEF_PATH": str(pdk_cfg["tech_lef"]),
        "LEF_PATH": str(pdk_cfg["cell_lef"]),
        "LIB_PATH": str(pdk_cfg["lib"]),
        "TECH_LEF": str(pdk_cfg["tech_lef"]),
        "LEF_STDCELL": str(pdk_cfg["cell_lef"]),
        "LIB_STDCELL": str(pdk_cfg["lib"]),
        "GDS_FILE": str(workspace / "result/final.gds"),
        "CTS_BUFFER_LIST": pdk_cfg["cts_buffers"],
        "INSERT_BUFFER": pdk_cfg["insert_buffer"],
        "FILLER_CELLS": pdk_cfg["filler_cells"],
        "LD_LIBRARY_PATH": str(REPO_ROOT / "build/lib") + ":" + env.get("LD_LIBRARY_PATH", ""),
    })

    # 定义所有阶段
    stages = [
        ("floorplan", workspace / "script/iFP_script/run_iFP.tcl", 300),
        ("placement", workspace / "script/iPL_script/run_iPL.tcl", 1800),
        ("cts", workspace / "script/iCTS_script/run_iCTS.tcl", 1800),
        ("routing", workspace / "script/iRT_script/run_iRT.tcl", 7200),
    ]

    # 逐个运行
    for stage_name, script_path, timeout in stages:
        if not run_stage(design_name, stage_name, script_path, env, timeout):
            print(f"\n✗ {design_name} failed at {stage_name}\n")
            return False

    print(f"\n✓ {design_name} completed successfully!\n")
    return True

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="渐进式利用率测试")
    parser.add_argument("--util", type=int, required=True, choices=[35, 40, 45, 50, 55, 60, 65, 70],
                        help="目标利用率 (%)")
    parser.add_argument("--designs", nargs="+",
                        default=["aes_nangate45_a", "aes_sky130_a", "aes_ics55_a"],
                        help="要测试的设计列表")
    args = parser.parse_args()

    timestamp = datetime.now().strftime("%Y%m%d_%H%M")
    print(f"\n{'='*80}")
    print(f"Progressive Utilization Test: {args.util}% | {timestamp}")
    print(f"Target designs: {', '.join(args.designs)}")
    print(f"{'='*80}\n")

    success_count = 0
    failed_designs = []

    for design in args.designs:
        if run_full_flow(design, args.util):
            success_count += 1
        else:
            failed_designs.append(design)

    print(f"\n{'='*80}")
    print(f"Final result ({args.util}%): {success_count}/{len(args.designs)} designs completed")
    if failed_designs:
        print(f"Failed designs: {', '.join(failed_designs)}")
    print(f"{'='*80}\n")
