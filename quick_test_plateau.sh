#!/bin/bash
# 快速验证 WP-iRT-01 Plateau Detection

echo "=========================================="
echo "Quick Test: Plateau Detection (WP-iRT-01)"
echo "=========================================="

# 配置
export IEDA_RT_PLATEAU_CHECK_INTERVAL=36
export IEDA_RT_PLATEAU_EXPLOSION_THRESHOLD=1.5

echo "Environment:"
echo "  IEDA_RT_PLATEAU_CHECK_INTERVAL=$IEDA_RT_PLATEAU_CHECK_INTERVAL"
echo "  IEDA_RT_PLATEAU_EXPLOSION_THRESHOLD=$IEDA_RT_PLATEAU_EXPLOSION_THRESHOLD"
echo ""

# 运行测试
cd /home/lxq/AiEDA/iEDA.ai

echo "Running aes_sky130_a @ 65% utilization..."
echo "Expected: Detection at box 72-108, clear error message"
echo ""

python3 benchmarks/flows/run_single_design.py \
  --design aes_sky130_a \
  --utilization 0.65 \
  --output benchmarks/results/test_plateau_WP-iRT-01

EXIT_CODE=$?

echo ""
echo "=========================================="
echo "Test completed with exit code: $EXIT_CODE"
echo "=========================================="

# 检查结果
RESULT_DIR="benchmarks/results/test_plateau_WP-iRT-01/aes_sky130_a/workspace/result"

if [ -f "$RESULT_DIR/plateau_diagnostic.json" ]; then
    echo "✅ plateau_diagnostic.json generated"
    cat "$RESULT_DIR/plateau_diagnostic.json"
else
    echo "❌ plateau_diagnostic.json NOT found"
fi

if [ $EXIT_CODE -ne 0 ]; then
    echo "✅ Non-zero exit code (expected for plateau detection)"
else
    echo "⚠️  Exit code is 0 (unexpected - should fail on plateau)"
fi
