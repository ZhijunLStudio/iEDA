#!/bin/bash
# 简化版 AES 运行脚本 - 基于参考 gcd 脚本

set -e

DESIGN=${1:-aes_sky130_a}
BENCHMARK_ROOT="/home/lxq/AiEDA/iEDA.ai/benchmarks"
DESIGN_DIR="$BENCHMARK_ROOT/designs/$DESIGN"
WORKSPACE="$DESIGN_DIR/workspace"

if [ ! -d "$DESIGN_DIR" ]; then
    echo "错误: 设计目录不存在: $DESIGN_DIR"
    exit 1
fi

# 读取设计配置
DESIGN_JSON="$DESIGN_DIR/design.json"
TOP_MODULE=$(jq -r '.top' "$DESIGN_JSON")
PDK=$(jq -r '.pdk' "$DESIGN_JSON")
NETLIST_REL=$(jq -r '.inputs.netlist' "$DESIGN_JSON")
SDC_REL=$(jq -r '.inputs.sdc' "$DESIGN_JSON")
TECH_LEF_REL=$(jq -r '.inputs.tech_lef' "$DESIGN_JSON")
CELLS_LEF_REL=$(jq -r '.inputs.cells_lef' "$DESIGN_JSON")
DIE_AREA=$(jq -r '.floorplan.die_area' "$DESIGN_JSON")
CORE_AREA=$(jq -r '.floorplan.core_area' "$DESIGN_JSON")

NETLIST_FILE="$DESIGN_DIR/$NETLIST_REL"
SDC_FILE="$DESIGN_DIR/$SDC_REL"

# 处理PDK路径变量
PDK_ROOT="/home/lxq/AiEDA/Foundary/$PDK"
TECH_LEF_FILE=$(echo "$TECH_LEF_REL" | sed "s|\$PDK|$PDK_ROOT|g")
CELLS_LEF_FILE=$(echo "$CELLS_LEF_REL" | sed "s|\$PDK|$PDK_ROOT|g")

echo "=============================================="
echo "运行设计: $DESIGN"
echo "=============================================="
echo "  Top: $TOP_MODULE"
echo "  PDK: $PDK"
echo "  Netlist: $NETLIST_FILE"
echo "  Die Area: $DIE_AREA"
echo "  Core Area: $CORE_AREA"
echo ""

# 确保工作空间已设置
if [ ! -d "$WORKSPACE/script" ]; then
    echo "设置工作空间..."
    /home/lxq/AiEDA/iEDA.ai/benchmarks/flows/setup_from_reference.sh "$DESIGN"
fi

cd "$WORKSPACE"

# 设置环境变量
export WORKSPACE="$WORKSPACE"
export CONFIG_DIR="$WORKSPACE/iEDA_config"
export FOUNDRY_DIR="/home/lxq/AiEDA/Foundary/$PDK"
export RESULT_DIR="$WORKSPACE/result"
export TCL_SCRIPT_DIR="$WORKSPACE/script"
export DESIGN_TOP="$TOP_MODULE"
export NETLIST_FILE="$NETLIST_FILE"
export SDC_FILE="$SDC_FILE"
export DIE_AREA="$DIE_AREA"
export CORE_AREA="$CORE_AREA"
export TECH_LEF_PATH="$TECH_LEF_FILE"
export LEF_PATH="$CELLS_LEF_FILE"
export LD_LIBRARY_PATH="/home/lxq/AiEDA/micromamba/envs/ieda-build/lib"

# 创建结果目录
mkdir -p "$RESULT_DIR"

echo "开始运行 iEDA 流程..."
echo ""

# 运行 iFP
echo ">>> [1/9] Floorplan (iFP)"
./iEDA -script script/iFP_script/run_iFP.tcl 2>&1 | tee "$RESULT_DIR/iFP.log"
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "✗ iFP 失败"
    exit 1
fi
echo "✓ iFP 完成"
echo ""

# 运行 iNO fix fanout
echo ">>> [2/9] Fix Fanout (iNO)"
./iEDA -script script/iNO_script/run_iNO_fix_fanout.tcl 2>&1 | tee "$RESULT_DIR/iNO.log"
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "✗ iNO 失败"
    exit 1
fi
echo "✓ iNO 完成"
echo ""

# 运行 iPL
echo ">>> [3/9] Placement (iPL)"
./iEDA -script script/iPL_script/run_iPL.tcl 2>&1 | tee "$RESULT_DIR/iPL.log"
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "✗ iPL 失败"
    exit 1
fi
echo "✓ iPL 完成"
echo ""

# 运行 iCTS
echo ">>> [4/9] Clock Tree (iCTS)"
./iEDA -script script/iCTS_script/run_iCTS.tcl 2>&1 | tee "$RESULT_DIR/iCTS.log"
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "✗ iCTS 失败"
    exit 1
fi
echo "✓ iCTS 完成"
echo ""

# 运行 iTO DRV
echo ">>> [5/9] Timing Opt - DRV (iTO)"
./iEDA -script script/iTO_script/run_iTO_drv.tcl 2>&1 | tee "$RESULT_DIR/iTO_drv.log"
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "✗ iTO DRV 失败"
    exit 1
fi
echo "✓ iTO DRV 完成"
echo ""

# 运行 iTO hold
echo ">>> [6/9] Timing Opt - Hold (iTO)"
./iEDA -script script/iTO_script/run_iTO_hold.tcl 2>&1 | tee "$RESULT_DIR/iTO_hold.log"
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "✗ iTO Hold 失败"
    exit 1
fi
echo "✓ iTO Hold 完成"
echo ""

# 运行 iPL legalization
echo ">>> [7/9] Legalization (iPL)"
./iEDA -script script/iPL_script/run_iPL_legalization.tcl 2>&1 | tee "$RESULT_DIR/iPL_leg.log"
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "✗ iPL Legalization 失败"
    exit 1
fi
echo "✓ iPL Legalization 完成"
echo ""

# 运行 iRT
echo ">>> [8/9] Routing (iRT)"
./iEDA -script script/iRT_script/run_iRT.tcl 2>&1 | tee "$RESULT_DIR/iRT.log"
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "✗ iRT 失败"
    exit 1
fi
echo "✓ iRT 完成"
echo ""

# 运行 iRT DRC
echo ">>> [9/9] DRC Check (iRT)"
./iEDA -script script/iRT_script/run_iRT_DRC.tcl 2>&1 | tee "$RESULT_DIR/iRT_DRC.log"
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "✗ iRT DRC 失败"
    exit 1
fi
echo "✓ iRT DRC 完成"
echo ""

# 总结
echo "=============================================="
echo "✓ 所有阶段完成"
echo "=============================================="
echo "结果目录: $RESULT_DIR"
echo ""
echo "生成的文件:"
ls -lh "$RESULT_DIR"/*.def 2>/dev/null || echo "  (未找到 DEF 文件)"
ls -lh "$RESULT_DIR"/*.rpt 2>/dev/null || echo "  (未找到报告文件)"

