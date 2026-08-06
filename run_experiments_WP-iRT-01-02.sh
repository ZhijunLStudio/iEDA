#!/bin/bash
# 实验：验证 WP-iRT-01 + WP-iRT-02 的组合效果
# 对比 Baseline vs 改进后的收敛性、稳定性和诊断能力

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "实验：WP-iRT-01 + WP-iRT-02 效果验证"
echo "=========================================="
echo ""
echo "目标："
echo "  1. 验证 plateau detection 能否检测到违例爆炸"
echo "  2. 验证 memory budget 能否防止 OOM"
echo "  3. 收集诊断信息（plateau_diagnostic.json, memory_diagnostic.json）"
echo "  4. 对比改进前后的运行时间和失败模式"
echo ""

# 配置
DESIGN="aes_sky130_a"
UTILIZATION="0.65"
OUTPUT_BASE="benchmarks/results/experiment_WP-iRT-01-02"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# 创建输出目录
mkdir -p "$OUTPUT_BASE"

# 实验配置
echo "实验配置："
echo "  设计: $DESIGN"
echo "  利用率: $UTILIZATION (已知会触发违例爆炸)"
echo "  输出: $OUTPUT_BASE"
echo ""

# ==========================================
# Experiment 1: 默认配置（中等敏感度）
# ==========================================
echo "=========================================="
echo "实验 1: 默认配置"
echo "=========================================="
echo "配置："
echo "  - Plateau check interval: 36 boxes"
echo "  - Plateau threshold: 1.5 (150% growth)"
echo "  - Memory budget: 8192 MB"
echo ""

export IEDA_RT_PLATEAU_CHECK_INTERVAL=36
export IEDA_RT_PLATEAU_EXPLOSION_THRESHOLD=1.5
export IEDA_RT_MAX_MEMORY_MB=8192

START_TIME=$(date +%s)

python3 benchmarks/flows/run_single_design.py \
  --design "$DESIGN" \
  --utilization "$UTILIZATION" \
  --output "$OUTPUT_BASE/exp1_default_${TIMESTAMP}" \
  2>&1 | tee "$OUTPUT_BASE/exp1_default_${TIMESTAMP}.log" || true

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "实验 1 完成，耗时: $DURATION 秒"
echo ""

# 检查结果
RESULT_DIR="$OUTPUT_BASE/exp1_default_${TIMESTAMP}/$DESIGN/workspace/result"
echo "检查生成的诊断文件："

if [ -f "$RESULT_DIR/plateau_diagnostic.json" ]; then
    echo "  ✅ plateau_diagnostic.json 已生成"
    echo "  内容："
    cat "$RESULT_DIR/plateau_diagnostic.json" | jq '.' 2>/dev/null || cat "$RESULT_DIR/plateau_diagnostic.json"
else
    echo "  ❌ plateau_diagnostic.json 未生成（可能未触发 plateau）"
fi

if [ -f "$RESULT_DIR/memory_diagnostic.json" ]; then
    echo "  ✅ memory_diagnostic.json 已生成"
    echo "  内容："
    cat "$RESULT_DIR/memory_diagnostic.json" | jq '.' 2>/dev/null || cat "$RESULT_DIR/memory_diagnostic.json"
else
    echo "  ℹ️  memory_diagnostic.json 未生成（内存未超限）"
fi

echo ""
echo "=========================================="

# ==========================================
# Experiment 2: 严格配置（高敏感度）
# ==========================================
echo ""
echo "=========================================="
echo "实验 2: 严格配置（更早检测）"
echo "=========================================="
echo "配置："
echo "  - Plateau check interval: 24 boxes (更频繁)"
echo "  - Plateau threshold: 1.2 (120% growth, 更严格)"
echo "  - Memory budget: 4096 MB (更低)"
echo ""

export IEDA_RT_PLATEAU_CHECK_INTERVAL=24
export IEDA_RT_PLATEAU_EXPLOSION_THRESHOLD=1.2
export IEDA_RT_MAX_MEMORY_MB=4096

START_TIME=$(date +%s)

python3 benchmarks/flows/run_single_design.py \
  --design "$DESIGN" \
  --utilization "$UTILIZATION" \
  --output "$OUTPUT_BASE/exp2_strict_${TIMESTAMP}" \
  2>&1 | tee "$OUTPUT_BASE/exp2_strict_${TIMESTAMP}.log" || true

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "实验 2 完成，耗时: $DURATION 秒"
echo ""

# 检查结果
RESULT_DIR="$OUTPUT_BASE/exp2_strict_${TIMESTAMP}/$DESIGN/workspace/result"
echo "检查生成的诊断文件："

if [ -f "$RESULT_DIR/plateau_diagnostic.json" ]; then
    echo "  ✅ plateau_diagnostic.json 已生成"
    cat "$RESULT_DIR/plateau_diagnostic.json" | jq '.' 2>/dev/null || cat "$RESULT_DIR/plateau_diagnostic.json"
fi

if [ -f "$RESULT_DIR/memory_diagnostic.json" ]; then
    echo "  ✅ memory_diagnostic.json 已生成"
    cat "$RESULT_DIR/memory_diagnostic.json" | jq '.' 2>/dev/null || cat "$RESULT_DIR/memory_diagnostic.json"
fi

echo ""
echo "=========================================="

# ==========================================
# Experiment 3: 宽松配置（低敏感度）
# ==========================================
echo ""
echo "=========================================="
echo "实验 3: 宽松配置（允许更多增长）"
echo "=========================================="
echo "配置："
echo "  - Plateau check interval: 48 boxes (更少频率)"
echo "  - Plateau threshold: 2.0 (200% growth, 更宽松)"
echo "  - Memory budget: 8192 MB"
echo ""

export IEDA_RT_PLATEAU_CHECK_INTERVAL=48
export IEDA_RT_PLATEAU_EXPLOSION_THRESHOLD=2.0
export IEDA_RT_MAX_MEMORY_MB=8192

START_TIME=$(date +%s)

python3 benchmarks/flows/run_single_design.py \
  --design "$DESIGN" \
  --utilization "$UTILIZATION" \
  --output "$OUTPUT_BASE/exp3_relaxed_${TIMESTAMP}" \
  2>&1 | tee "$OUTPUT_BASE/exp3_relaxed_${TIMESTAMP}.log" || true

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "实验 3 完成，耗时: $DURATION 秒"
echo ""

# 检查结果
RESULT_DIR="$OUTPUT_BASE/exp3_relaxed_${TIMESTAMP}/$DESIGN/workspace/result"
echo "检查生成的诊断文件："

if [ -f "$RESULT_DIR/plateau_diagnostic.json" ]; then
    echo "  ✅ plateau_diagnostic.json 已生成"
    cat "$RESULT_DIR/plateau_diagnostic.json" | jq '.' 2>/dev/null || cat "$RESULT_DIR/plateau_diagnostic.json"
fi

if [ -f "$RESULT_DIR/memory_diagnostic.json" ]; then
    echo "  ✅ memory_diagnostic.json 已生成"
    cat "$RESULT_DIR/memory_diagnostic.json" | jq '.' 2>/dev/null || cat "$RESULT_DIR/memory_diagnostic.json"
fi

echo ""
echo "=========================================="

# ==========================================
# 对比总结
# ==========================================
echo ""
echo "=========================================="
echo "实验对比总结"
echo "=========================================="
echo ""

# 提取关键指标
echo "| 实验 | 配置 | Plateau 检测 | Memory 保护 | 运行时间 | Box 进度 |"
echo "|------|------|-------------|------------|---------|---------|"

for exp in exp1_default exp2_strict exp3_relaxed; do
    RESULT_DIR="$OUTPUT_BASE/${exp}_${TIMESTAMP}/$DESIGN/workspace/result"

    # 检测 plateau
    if [ -f "$RESULT_DIR/plateau_diagnostic.json" ]; then
        PLATEAU="✅ 检测到"
        BOX_PROGRESS=$(grep -o '"box_progress": "[^"]*"' "$RESULT_DIR/plateau_diagnostic.json" | cut -d'"' -f4)
    else
        PLATEAU="❌ 未触发"
        BOX_PROGRESS="未知"
    fi

    # 检测 memory
    if [ -f "$RESULT_DIR/memory_diagnostic.json" ]; then
        MEMORY="✅ 触发"
    else
        MEMORY="❌ 未触发"
    fi

    # 读取运行时间（从日志）
    LOG_FILE="$OUTPUT_BASE/${exp}_${TIMESTAMP}.log"
    if [ -f "$LOG_FILE" ]; then
        RUNTIME=$(grep -o "耗时: [0-9]* 秒" "$LOG_FILE" | grep -o "[0-9]*" || echo "未知")
    else
        RUNTIME="未知"
    fi

    echo "| $exp | 见上 | $PLATEAU | $MEMORY | ${RUNTIME}s | $BOX_PROGRESS |"
done

echo ""
echo "=========================================="
echo "实验完成！"
echo "=========================================="
echo ""
echo "下一步："
echo "  1. 查看详细日志: $OUTPUT_BASE/exp*.log"
echo "  2. 查看诊断 JSON: $OUTPUT_BASE/exp*/*/workspace/result/*.json"
echo "  3. 分析哪个配置最合适"
echo "  4. 根据结果决定是否需要 WP-iRT-03 (Adaptive Box Sizing)"
echo ""
echo "关键问题："
echo "  - Plateau detection 在哪个 box 触发？"
echo "  - 是否生成了有用的诊断信息？"
echo "  - 相比之前的 OOM，运行时间是否更短？"
echo "  - 用户体验是否改善（从静默失败到清晰诊断）？"
echo ""
