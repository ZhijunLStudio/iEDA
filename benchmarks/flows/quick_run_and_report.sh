#!/bin/bash
# 快速运行物理设计流程并生成详细报告
#
# 用法:
#   ./quick_run_and_report.sh gcd_sky130_a
#   ./quick_run_and_report.sh aes_sky130_a aes_nangate45_a

set -e

cd "$(dirname "$0")/.."

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DESIGNS=("$@")

if [ ${#DESIGNS[@]} -eq 0 ]; then
    echo "用法: $0 <design1> [design2] ..."
    echo ""
    echo "示例设计:"
    echo "  gcd_sky130_a       - 小型测试 (~百门)"
    echo "  aes_sky130_a       - 中型设计 (~9K门)"
    echo "  aes_nangate45_a    - AES @ nangate45"
    echo ""
    exit 1
fi

OUTPUT_ROOT="results/flow_${TIMESTAMP}"
REPORT_FILE="reports/comparison_${TIMESTAMP}.md"

echo "=========================================="
echo "运行设计: ${DESIGNS[*]}"
echo "=========================================="

# 步骤1: 运行物理设计流程
echo ""
echo "[1/2] 运行物理设计流程..."

# aes13_flow.py 使用 --design (单数) 参数，需要为每个设计单独调用
for design in "${DESIGNS[@]}"; do
    echo "  运行设计: $design"
    python3 flows/aes13_flow.py \
        --design "$design" \
        --result-root "$OUTPUT_ROOT" \
        --no-synthesis \
        --jobs 1
done

# 步骤2: 生成详细报告
echo ""
echo "[2/2] 生成详细报告..."
python3 flows/generate_aes11_detailed_report.py \
    --run-root "$OUTPUT_ROOT" \
    --output "$REPORT_FILE"

# 显示结果
echo ""
echo "=========================================="
echo "完成！"
echo "=========================================="
echo "输出目录: $OUTPUT_ROOT"
echo "详细报告: $REPORT_FILE"
echo ""
echo "查看报告:"
echo "  cat $REPORT_FILE | less"
echo ""
