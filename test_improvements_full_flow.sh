#!/bin/bash
# 使用完整流程测试 WP-iRT-01 + WP-iRT-02

set -e

cd /home/lxq/AiEDA/iEDA.ai

echo "=========================================="
echo "WP-iRT-01 + WP-iRT-02 完整流程测试"
echo "=========================================="
echo ""

# 配置
DESIGN="aes_sky130_a"
OUTPUT_BASE="benchmarks/results/test_improvements"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="${OUTPUT_BASE}/${DESIGN}_${TIMESTAMP}"

mkdir -p "$OUTPUT_BASE"

echo "配置："
echo "  设计: $DESIGN"
echo "  输出: $OUTPUT_DIR"
echo "  环境变量:"
echo "    IEDA_RT_PLATEAU_CHECK_INTERVAL=36"
echo "    IEDA_RT_PLATEAU_EXPLOSION_THRESHOLD=1.5"
echo "    IEDA_RT_MAX_MEMORY_MB=8192"
echo ""

# 设置环境变量
export IEDA_RT_PLATEAU_CHECK_INTERVAL=36
export IEDA_RT_PLATEAU_EXPLOSION_THRESHOLD=1.5
export IEDA_RT_MAX_MEMORY_MB=8192

# 记录开始时间
START_TIME=$(date +%s)
echo "开始时间: $(date)"
echo ""

# 运行完整流程
echo "运行完整的 place → route → gds 流程..."
echo ""

python3 benchmarks/flows/run_full_flow_65pct.py \
  --designs "$DESIGN" \
  --output "$OUTPUT_DIR" \
  2>&1 | tee "${OUTPUT_DIR}.log"

EXIT_CODE=$?

# 记录结束时间
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "=========================================="
echo "测试完成"
echo "=========================================="
echo "退出码: $EXIT_CODE"
echo "运行时间: $((DURATION/60)) 分钟 $((DURATION%60)) 秒"
echo ""

# 检查结果
WORKSPACE="${OUTPUT_DIR}/${DESIGN}/workspace"
RESULT_DIR="${WORKSPACE}/result"

echo "检查生成的文件："
echo ""

# 检查 plateau diagnostic
if [ -f "${RESULT_DIR}/plateau_diagnostic.json" ]; then
    echo "✅ plateau_diagnostic.json 已生成"
    echo "内容："
    cat "${RESULT_DIR}/plateau_diagnostic.json"
    echo ""
else
    echo "❌ plateau_diagnostic.json 未生成"
fi

# 检查 memory diagnostic
if [ -f "${RESULT_DIR}/memory_diagnostic.json" ]; then
    echo "✅ memory_diagnostic.json 已生成"
    echo "内容："
    cat "${RESULT_DIR}/memory_diagnostic.json"
    echo ""
else
    echo "ℹ️  memory_diagnostic.json 未生成（内存未超限）"
fi

# 检查 DEF 文件
echo "生成的 DEF 文件："
ls -lh "${RESULT_DIR}"/*.def 2>/dev/null | tail -5 || echo "  未找到 DEF 文件"
echo ""

# 检查日志中的关键信息
echo "日志中的关键信息："
grep -E "(PLATEAU|EXPLOSION|VIOLATION|Memory budget)" "${OUTPUT_DIR}.log" | tail -20 || echo "  未找到关键信息"
echo ""

echo "=========================================="
echo "结果总结"
echo "=========================================="
echo "输出目录: $OUTPUT_DIR"
echo "日志文件: ${OUTPUT_DIR}.log"
echo "Workspace: $WORKSPACE"
echo ""

if [ $EXIT_CODE -eq 0 ]; then
    echo "状态: ✅ 流程完成（可能部分成功）"
else
    echo "状态: ⚠️  流程退出（退出码 $EXIT_CODE）"
fi

echo ""
echo "查看完整日志:"
echo "  cat ${OUTPUT_DIR}.log"
echo ""
echo "查看诊断文件:"
echo "  cat ${RESULT_DIR}/plateau_diagnostic.json"
echo "  cat ${RESULT_DIR}/memory_diagnostic.json"
echo ""
