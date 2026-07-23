#!/bin/bash
# 批量配置并运行所有13个AES设计

BENCHMARK_ROOT="/home/lxq/AiEDA/iEDA.ai/benchmarks"
FLOWS_DIR="$BENCHMARK_ROOT/flows"
DESIGNS_DIR="$BENCHMARK_ROOT/designs"

# 设计列表
DESIGNS=(
    "aes_sky130_a"
    "aes_sky130_b"
    "aes_sky130_t"
    "aes_nangate45_a"
    "aes_nangate45_b"
    "aes_nangate45_t"
    "aes_asap7_a"
    "aes_asap7_b"
    "aes_asap7_t"
    "aes_ics55_a"
    "aes_ics55_b"
    "aes_ics55_t"
    "aes_core_sky130_a"
)

echo "========================================"
echo "批量配置和运行13个AES设计"
echo "开始时间: $(date)"
echo "========================================"
echo ""

# 第一步：批量配置所有设计
echo "步骤1: 批量配置PDK..."
for design in "${DESIGNS[@]}"; do
    echo "  配置 $design..."
    python3 "$FLOWS_DIR/configure_pdk.py" "$DESIGNS_DIR/$design" 2>&1 | grep -E "(✓|✗|Error)"
done

echo ""
echo "步骤2: 批量运行设计..."
echo ""

# 第二步：批量运行
cd "$FLOWS_DIR"
bash run_13_aes_batch.sh

echo ""
echo "========================================"
echo "批量运行完成"
echo "结束时间: $(date)"
echo "========================================"

# 第三步：生成所有设计的报告
echo ""
echo "步骤3: 生成各设计的阶段报告..."
for design in "${DESIGNS[@]}"; do
    if [ -d "$DESIGNS_DIR/$design/workspace/result" ]; then
        echo "  生成 $design 报告..."
        python3 "$FLOWS_DIR/generate_stage_report.py" "$DESIGNS_DIR/$design" 2>&1 | grep -E "(✓|✗)"
    fi
done

echo ""
echo "所有任务完成！"
