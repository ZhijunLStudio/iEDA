#!/bin/bash
# 完整物理设计流程运行脚本
# 用法: ./run_design_with_report.sh <design_name> [designs...]
#
# 示例:
#   ./run_design_with_report.sh gcd_sky130_a
#   ./run_design_with_report.sh aes_sky130_a aes_nangate45_a aes_asap7_a

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BENCHMARK_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_ROOT="$BENCHMARK_ROOT/results/flow_$TIMESTAMP"
REPORT_DIR="$BENCHMARK_ROOT/reports"

# 检查参数
if [ $# -lt 1 ]; then
    echo "用法: $0 <design1> [design2] [design3] ..."
    echo ""
    echo "可用设计示例:"
    echo "  - gcd_sky130_a        (小型测试设计)"
    echo "  - aes_sky130_a        (中型加密模块)"
    echo "  - aes_nangate45_a     (nangate45 PDK)"
    echo "  - aes_asap7_a         (asap7 PDK)"
    echo ""
    exit 1
fi

DESIGNS=("$@")

echo "========================================"
echo "iEDA 完整物理设计流程"
echo "========================================"
echo "设计列表: ${DESIGNS[*]}"
echo "输出目录: $OUTPUT_ROOT"
echo "报告目录: $REPORT_DIR"
echo "时间戳: $TIMESTAMP"
echo "========================================"
echo ""

# 创建输出目录
mkdir -p "$OUTPUT_ROOT"
mkdir -p "$REPORT_DIR"

# 运行每个设计
echo "步骤 1/3: 运行物理设计流程"
echo "----------------------------------------"

cd "$BENCHMARK_ROOT"

# 使用 aes13_flow.py 运行设计
python3 flows/aes13_flow.py \
    --designs "${DESIGNS[@]}" \
    --output-root "$OUTPUT_ROOT" \
    --skip-synthesis \
    --workers 1

echo ""
echo "✓ 流程运行完成"
echo ""

# 生成详细报告
echo "步骤 2/3: 生成详细对比报告"
echo "----------------------------------------"

REPORT_FILE="$REPORT_DIR/comparison_${TIMESTAMP}.md"

python3 flows/generate_aes11_detailed_report.py \
    --run-root "$OUTPUT_ROOT" \
    --output "$REPORT_FILE"

echo ""
echo "✓ 报告生成完成: $REPORT_FILE"
echo ""

# 显示结果摘要
echo "步骤 3/3: 结果摘要"
echo "----------------------------------------"

for design in "${DESIGNS[@]}"; do
    DESIGN_DIR="$OUTPUT_ROOT/$design"
    if [ -d "$DESIGN_DIR" ]; then
        echo "设计: $design"

        # 检查关键文件
        if [ -f "$DESIGN_DIR/workspace/result/iRT_result.def" ]; then
            echo "  ✓ 布线完成 (DEF)"
        fi

        if [ -f "$DESIGN_DIR/workspace/result/final.gds" ]; then
            echo "  ✓ GDS 生成"
        fi

        # 统计文件
        RESULT_DIR="$DESIGN_DIR/workspace/result"
        if [ -d "$RESULT_DIR" ]; then
            DEF_COUNT=$(find "$RESULT_DIR" -name "*.def" | wc -l)
            RPT_COUNT=$(find "$RESULT_DIR" -name "*.rpt" | wc -l)
            echo "  - DEF 文件: $DEF_COUNT"
            echo "  - 报告文件: $RPT_COUNT"
        fi

        echo ""
    else
        echo "设计: $design"
        echo "  ✗ 未找到结果目录"
        echo ""
    fi
done

# 最终总结
echo "========================================"
echo "全部完成！"
echo "========================================"
echo ""
echo "结果位置:"
echo "  - 设计输出: $OUTPUT_ROOT"
echo "  - 详细报告: $REPORT_FILE"
echo ""
echo "查看报告:"
echo "  cat $REPORT_FILE"
echo ""
echo "查看某个设计的详细结果:"
for design in "${DESIGNS[@]}"; do
    echo "  tree $OUTPUT_ROOT/$design/workspace/result"
done
echo ""
