#!/bin/bash
# 实验：验证 WP-iRT-01 + WP-iRT-02 的组合效果（修正版）

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "实验：WP-iRT-01 + WP-iRT-02 效果验证"
echo "=========================================="
echo ""

# 配置
DESIGN="aes_sky130_a"
UTILIZATION="0.65"
OUTPUT_BASE="benchmarks/results/experiment_WP-iRT-01-02"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$OUTPUT_BASE"

echo "实验配置："
echo "  设计: $DESIGN"
echo "  利用率: $UTILIZATION"
echo "  输出: $OUTPUT_BASE"
echo "  使用脚本: benchmarks/flows/test_single_65pct.py"
echo ""

# ==========================================
# Experiment 1: 默认配置
# ==========================================
echo "=========================================="
echo "实验 1: 默认配置"
echo "=========================================="
echo "配置："
echo "  - Plateau check interval: 36 boxes"
echo "  - Plateau threshold: 1.5 (150%)"
echo "  - Memory budget: 8192 MB"
echo ""

export IEDA_RT_PLATEAU_CHECK_INTERVAL=36
export IEDA_RT_PLATEAU_EXPLOSION_THRESHOLD=1.5
export IEDA_RT_MAX_MEMORY_MB=8192

START_TIME=$(date +%s)

# 使用实际存在的脚本
python3 benchmarks/flows/test_single_65pct.py \
  "$DESIGN" \
  "$OUTPUT_BASE/exp1_default_${TIMESTAMP}" \
  2>&1 | tee "$OUTPUT_BASE/exp1_default_${TIMESTAMP}.log" || true

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "实验 1 完成，耗时: $DURATION 秒 ($((DURATION/60)) 分钟)"
echo ""

# 检查结果
RESULT_DIR="$OUTPUT_BASE/exp1_default_${TIMESTAMP}/$DESIGN/workspace/result"
echo "检查生成的诊断文件："

if [ -f "$RESULT_DIR/plateau_diagnostic.json" ]; then
    echo "  ✅ plateau_diagnostic.json 已生成"
    echo "  内容:"
    cat "$RESULT_DIR/plateau_diagnostic.json" 2>/dev/null || echo "    (无法读取)"
else
    echo "  ❌ plateau_diagnostic.json 未生成"
fi

if [ -f "$RESULT_DIR/memory_diagnostic.json" ]; then
    echo "  ✅ memory_diagnostic.json 已生成"
    cat "$RESULT_DIR/memory_diagnostic.json" 2>/dev/null || echo "    (无法读取)"
else
    echo "  ℹ️  memory_diagnostic.json 未生成（内存未超限）"
fi

# 检查日志中的关键信息
echo ""
echo "日志中的关键信息:"
grep -i "plateau\|explosion\|memory\|violation" "$OUTPUT_BASE/exp1_default_${TIMESTAMP}.log" | tail -20 || echo "  (未找到关键信息)"

echo ""
echo "=========================================="

# ==========================================
# 总结
# ==========================================
echo ""
echo "=========================================="
echo "实验 1 总结"
echo "=========================================="
echo ""
echo "输出目录: $OUTPUT_BASE/exp1_default_${TIMESTAMP}"
echo "日志文件: $OUTPUT_BASE/exp1_default_${TIMESTAMP}.log"
echo "运行时间: $((DURATION/60)) 分钟"
echo ""
echo "下一步:"
echo "  1. 查看完整日志: cat $OUTPUT_BASE/exp1_default_${TIMESTAMP}.log"
echo "  2. 检查 workspace: ls -lh $RESULT_DIR"
echo "  3. 根据结果决定是否运行 Exp 2/3"
echo ""
