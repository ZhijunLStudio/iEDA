#!/bin/bash
# 测试单个 AES 设计运行

set -e

DESIGN=${1:-aes_sky130_a}
BENCHMARK_ROOT="/home/lxq/AiEDA/iEDA.ai/benchmarks"
FLOWS_DIR="$BENCHMARK_ROOT/flows"
LOG_DIR="$BENCHMARK_ROOT/flows/logs"

mkdir -p "$LOG_DIR"

cd "$FLOWS_DIR"

echo "=============================================="
echo "测试运行设计: $DESIGN"
echo "=============================================="
echo ""

# 运行并记录日志
python3 test_single_design.py "$DESIGN" 2>&1 | tee "$LOG_DIR/${DESIGN}_test.log"

EXIT_CODE=${PIPESTATUS[0]}

echo ""
echo "=============================================="
if [ $EXIT_CODE -eq 0 ]; then
    echo "✓ 测试成功"
else
    echo "✗ 测试失败 (退出码: $EXIT_CODE)"
    echo "查看日志: $LOG_DIR/${DESIGN}_test.log"
fi
echo "=============================================="

exit $EXIT_CODE
