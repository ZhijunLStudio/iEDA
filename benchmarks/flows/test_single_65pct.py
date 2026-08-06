#!/usr/bin/env python3
"""测试单个 AES 设计的 floorplan 阶段"""

from pathlib import Path
import subprocess
import os
import sys

# 路径设置
REPO_ROOT = Path("/home/lxq/AiEDA/iEDA.ai")
FOUNDRY_ROOT = Path("/home/lxq/AiEDA/Foundary")

design_name = sys.argv[1] if len(sys.argv) > 1 else "aes_sky130_a"
workspace = REPO_ROOT / f"benchmarks/results/aes13_65pct/{design_name}/workspace"
ieda_bin = REPO_ROOT / "bin/iEDA"

if not workspace.exists():
    print(f"Error: workspace not found: {workspace}")
    sys.exit(1)

# 确定正确的 netlist 文件和 top module
netlist_dir = REPO_ROOT / f"benchmarks/designs/{design_name}/netlist"
if (netlist_dir / "aes_cipher_top.v").exists():
    netlist_file = netlist_dir / "aes_cipher_top.v"
    top_module = "aes_cipher_top"
else:
    netlist_file = netlist_dir / "aes.v"
    top_module = "aes"

# 根据设计名确定 PDK
if "sky130" in design_name:
    pdk = "sky130"
    tech_lef = FOUNDRY_ROOT / "sky130/lef/sky130_fd_sc_hd.tlef"
    cell_lef = FOUNDRY_ROOT / "sky130/lef/sky130_fd_sc_hd_merged.lef"
    lib = FOUNDRY_ROOT / "sky130/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
    site = "unithd"
    tapcell = "sky130_fd_sc_hd__tap_1"
    endcap = "sky130_fd_sc_hd__fill_1"
    pin_layer = "met5"
    cts_buffers = "sky130_fd_sc_hd__buf_1 sky130_fd_sc_hd__buf_2 sky130_fd_sc_hd__buf_4 sky130_fd_sc_hd__buf_8"
    bottom_routing = "met1"
    top_routing = "met5"
    insert_buffer = "sky130_fd_sc_hd__buf_8"
    filler_cells = "sky130_fd_sc_hd__fill_8 sky130_fd_sc_hd__fill_4 sky130_fd_sc_hd__fill_2 sky130_fd_sc_hd__fill_1"
elif "nangate45" in design_name:
    pdk = "nangate45"
    tech_lef = FOUNDRY_ROOT / "nangate45/lef/NangateOpenCellLibrary.tech.lef"
    cell_lef = FOUNDRY_ROOT / "nangate45/lef/NangateOpenCellLibrary.macro.mod.lef"
    lib = FOUNDRY_ROOT / "nangate45/lib/NangateOpenCellLibrary_typical.lib"
    site = "FreePDK45_38x28_10R_NP_162NW_34O"
    tapcell = "TAPCELL_X1"
    endcap = "TAPCELL_X1"
    pin_layer = "metal3"
    cts_buffers = "BUF_X1 BUF_X2 BUF_X4 BUF_X8"
    bottom_routing = "metal1"
    top_routing = "metal10"
    insert_buffer = "BUF_X8"
    filler_cells = "FILLCELL_X32 FILLCELL_X16 FILLCELL_X8 FILLCELL_X4 FILLCELL_X2 FILLCELL_X1"
elif "asap7" in design_name:
    pdk = "asap7"
    tech_lef = workspace / "tech/asap7_tech_1x_with_rc.lef"
    cell_lef = FOUNDRY_ROOT / "asap7/lef/asap7sc7p5t_27_R_1x_201211.lef"
    lib = FOUNDRY_ROOT / "asap7/lib/asap7sc7p5t_AO_RVT_TT_nldm_201020.lib"
    site = "asap7sc7p5t"
    tapcell = "TAPCELL_ASAP7_75t_R"
    endcap = "TAPCELL_ASAP7_75t_R"
    pin_layer = "M4"
    cts_buffers = "BUFx2_ASAP7_75t_R BUFx4_ASAP7_75t_R BUFx6_ASAP7_75t_R"
    bottom_routing = "M2"
    top_routing = "M7"
    insert_buffer = "BUFx4_ASAP7_75t_R"
    filler_cells = "FILLERxp5_ASAP7_75t_R FILLER_ASAP7_75t_R"
elif "ics55" in design_name:
    pdk = "ics55"
    tech_lef = FOUNDRY_ROOT / "ics55/prtech/techLEF/N551P6M_ieda.lef"
    cell_lef = FOUNDRY_ROOT / "ics55/IP/STD_cell/ics55_LLSC_H7C_V1p10C100/ics55_LLSC_H7CR/lef/ics55_LLSC_H7CR_ieda.lef"
    lib = FOUNDRY_ROOT / "ics55/IP/STD_cell/ics55_LLSC_H7C_V1p10C100/ics55_LLSC_H7CR/liberty/ics55_LLSC_H7CR_typ_tt_1p2_25_nldm.lib"
    site = "core7"
    tapcell = "FILLTAPH7R"
    endcap = "FILLTAPH7R"
    pin_layer = "MET3"
    cts_buffers = "BUFX1H7R BUFX2H7R BUFX4H7R BUFX8H7R"
    bottom_routing = "MET1"
    top_routing = "MET5"
    insert_buffer = "BUFX8H7R"
    filler_cells = "FILLER64H7R FILLER32H7R FILLER16H7R FILLER8H7R FILLER4H7R FILLER2H7R"
else:
    print(f"Unknown PDK for design: {design_name}")
    sys.exit(1)

# 构建完整环境变量
env = os.environ.copy()
env.update({
    "WORKSPACE": str(workspace),
    "CONFIG_DIR": str(workspace / "iEDA_config"),
    "IEDA_CONFIG_DIR": str(workspace / "iEDA_config"),
    "RESULT_DIR": str(workspace / "result"),
    "DEF_DIR": str(workspace / "result"),
    "TCL_SCRIPT_DIR": str(workspace / "script"),
    "IEDA_TCL_SCRIPT_DIR": str(workspace / "script"),
    "FOUNDRY_DIR": str(FOUNDRY_ROOT / pdk),
    "PDK_DIR": str(FOUNDRY_ROOT / pdk),
    "DESIGN_TOP": top_module,
    "TOP_NAME": top_module,
    "CLK_PORT_NAME": "clk",
    "NETLIST_FILE": str(netlist_file),
    "SDC_FILE": str(REPO_ROOT / f"benchmarks/designs/{design_name}/sdc/aes.sdc"),
    "DIE_AREA": "0.0 0.0 580.0 580.0",
    "CORE_AREA": "10.0 10.0 570.0 570.0",
    "DIE_BBOX": "0.0 0.0 580.0 580.0",
    "CORE_BBOX": "10.0 10.0 570.0 570.0",
    "CORE_UTIL": "0.6",
    "USE_FIXED_BBOX": "True",
    "PLACE_SITE": site,
    "IO_SITE": site,
    "CORNER_SITE": site,
    "TAPCELL": tapcell,
    "TAP_DISTANCE": "14",
    "ENDCAP": endcap,
    "PIN_LAYER": pin_layer,
    "BOTTOM_ROUTING_LAYER": bottom_routing,
    "TOP_ROUTING_LAYER": top_routing,
    "ROUTING_THREADS": "64",
    "TECH_LEF_PATH": str(tech_lef),
    "LEF_PATH": str(cell_lef),
    "LIB_PATH": str(lib),
    "TECH_LEF": str(tech_lef),
    "LEF_STDCELL": str(cell_lef),
    "LIB_STDCELL": str(lib),
    "GDS_FILE": str(workspace / "result/final.gds"),
    "CTS_BUFFER_LIST": cts_buffers,
    "INSERT_BUFFER": insert_buffer,
    "FILLER_CELLS": filler_cells,
    "LD_LIBRARY_PATH": str(REPO_ROOT / "build/lib") + ":" + env.get("LD_LIBRARY_PATH", ""),
})

print(f"{'='*80}")
print(f"Testing floorplan for: {design_name}")
print(f"{'='*80}")
print(f"Workspace: {workspace}")
print(f"PDK: {pdk}")
print(f"Tech LEF: {tech_lef.name}")
print(f"Cell LEF: {cell_lef.name}")
print(f"Running iEDA...")
print()

script = workspace / "script/iFP_script/run_iFP.tcl"
log_file = workspace / "result/logs/floorplan.log"

result = subprocess.run(
    [str(ieda_bin), "-script", str(script)],
    cwd=workspace,
    env=env,
    capture_output=True,
    text=True,
    timeout=60
)

# 写入日志
log_file.parent.mkdir(parents=True, exist_ok=True)
with open(log_file, 'w') as f:
    f.write(result.stdout)
    f.write("\n")
    f.write(result.stderr)

print(f"Return code: {result.returncode}")

if result.returncode == 0:
    print("✓ SUCCESS")
    # 检查输出文件
    def_file = workspace / "result/iFP_result.def"
    if def_file.exists():
        print(f"✓ DEF generated: {def_file}")
        print(f"  Size: {def_file.stat().st_size} bytes")
    else:
        print("✗ DEF file not found")
else:
    print("✗ FAILED")
    print(f"\nLast 30 lines of output:")
    lines = (result.stdout + "\n" + result.stderr).split("\n")
    for line in lines[-30:]:
        print(f"  {line}")

print(f"\nFull log: {log_file}")
sys.exit(result.returncode)
