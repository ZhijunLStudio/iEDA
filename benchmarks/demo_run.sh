#!/bin/bash
# 示例：运行单个设计演示完整流程
# 这是一个最小化的演示，展示如何运行流程和生成报告

set -e

echo "========================================"
echo "iEDA 完整流程演示"
echo "========================================"
echo ""
echo "本脚本将演示如何运行一个小型设计 (gcd_sky130_a)"
echo "完整流程包括："
echo "  1. Floorplan (芯片规划)"
echo "  2. Fanout Fixing (扇出修复)"
echo "  3. Placement (布局)"
echo "  4. CTS (时钟树综合)"
echo "  5. Legalization (合法化)"
echo "  6. Routing (布线)"
echo "  7. Filler (填充)"
echo "  8. GDS生成"
echo "  9. 详细报告生成"
echo ""
echo "预计时间: 1-5分钟"
echo ""
read -p "按回车键开始..." dummy

cd "$(dirname "$0")/.."
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

./flows/quick_run_and_report.sh gcd_sky130_a

echo ""
echo "========================================"
echo "演示完成！"
echo "========================================"
echo ""
echo "现在你可以："
echo ""
echo "1. 查看详细报告："
echo "   cat reports/comparison_${TIMESTAMP}.md | less"
echo ""
echo "2. 查看生成的文件："
echo "   ls -lh results/flow_${TIMESTAMP}/gcd_sky130_a/workspace/result/"
echo ""
echo "3. 运行更多设计（多设计对比）："
echo "   ./flows/quick_run_and_report.sh aes_sky130_a aes_nangate45_a"
echo ""
echo "4. 查看完整使用指南："
echo "   cat FLOW_GUIDE.md"
echo ""
