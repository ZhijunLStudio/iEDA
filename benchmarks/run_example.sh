#!/bin/bash
# 一键运行示例 - 运行AES设计并生成报告
# 使用现有的最佳结果目录

set -e

cd "$(dirname "$0")/.."

echo "=========================================="
echo "iEDA 流程演示"
echo "=========================================="
echo ""

# 检查现有结果
echo "检查现有结果目录..."
EXISTING_RESULTS=$(ls -dt results/aes13* 2>/dev/null | head -1)

if [ -n "$EXISTING_RESULTS" ] && [ -d "$EXISTING_RESULTS" ]; then
    echo "✓ 找到现有结果: $EXISTING_RESULTS"
    echo ""
    echo "选项："
    echo "  1. 使用现有结果生成报告"
    echo "  2. 运行新的流程"
    echo ""
    read -p "请选择 (1/2，默认1): " choice
    choice=${choice:-1}

    if [ "$choice" = "1" ]; then
        echo ""
        echo "使用现有结果生成报告..."
        python3 flows/simple_report_generator.py "$EXISTING_RESULTS" "reports/report_$(date +%s).md"
        echo ""
        echo "✓ 完成"
        exit 0
    fi
fi

# 运行新流程
echo ""
echo "运行新的物理设计流程..."
echo "提示: 这会运行完整的 floorplan → routing → GDS 流程"
echo ""

# 选择设计
echo "可用设计:"
echo "  1. aes_sky130_a (推荐)"
echo "  2. aes_nangate45_a"
echo "  3. aes_asap7_a"
echo "  4. 所有13个AES设计 (需要较长时间)"
echo ""
read -p "请选择 (1-4，默认1): " design_choice
design_choice=${design_choice:-1}

case $design_choice in
    1)
        DESIGN="aes_sky130_a"
        ;;
    2)
        DESIGN="aes_nangate45_a"
        ;;
    3)
        DESIGN="aes_asap7_a"
        ;;
    4)
        DESIGN="all"
        ;;
    *)
        DESIGN="aes_sky130_a"
        ;;
esac

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_ROOT="results/run_${TIMESTAMP}"

if [ "$DESIGN" = "all" ]; then
    echo ""
    echo "运行所有13个AES设计..."
    for d in aes_sky130_a aes_sky130_b aes_sky130_t \
             aes_nangate45_a aes_nangate45_b aes_nangate45_t \
             aes_asap7_a aes_asap7_b aes_asap7_t \
             aes_ics55_a aes_ics55_b aes_ics55_t aes; do
        echo "  → $d"
        python3 flows/aes13_flow.py --design "$d" --result-root "$OUTPUT_ROOT" --no-synthesis --jobs 1
    done
else
    echo ""
    echo "运行设计: $DESIGN"
    python3 flows/aes13_flow.py --design "$DESIGN" --result-root "$OUTPUT_ROOT" --no-synthesis --jobs 1
fi

# 生成报告
echo ""
echo "生成报告..."
REPORT_FILE="reports/report_${TIMESTAMP}.md"
python3 flows/simple_report_generator.py "$OUTPUT_ROOT" "$REPORT_FILE"

echo ""
echo "=========================================="
echo "✓ 完成！"
echo "=========================================="
echo "结果目录: $OUTPUT_ROOT"
echo "报告文件: $REPORT_FILE"
echo ""
echo "查看报告:"
echo "  cat $REPORT_FILE"
echo ""
