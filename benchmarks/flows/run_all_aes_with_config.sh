#!/bin/bash
# 统一入口：为 13 套 AES 在同一套参数下生成配置并批量运行

set -euo pipefail

BENCHMARK_ROOT="/home/lxq/AiEDA/iEDA.ai/benchmarks"
FLOW_DIR="$BENCHMARK_ROOT/flows"
RESULT_ROOT="$BENCHMARK_ROOT/results/aes13"

aes_designs=(
    "aes"
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
)

TARGET_UTILIZATION="${AES_TARGET_UTILIZATION:-0.70}"
TARGET_UTILIZATION="$(printf %.2f "$TARGET_UTILIZATION")"
THREADS="${AES_THREAD_COUNT:-8}"
THREADS="${THREADS}"  # 占位，保持参数显示兼容

echo "========================================"
echo "批量配置并运行 13 套 AES"
echo "开始时间: $(date +%F %T %z)"
echo "目标利用率: $TARGET_UTILIZATION"
echo "并发: ${AES_JOBS:-1}"
echo "输出目录: $RESULT_ROOT"
echo "========================================"
echo ""

# 1. 批量配置 PDK（保留原有流程，便于审计）
for design in "${aes_designs[@]}"; do
    echo "  配置设计: $design"
    python3 "$FLOW_DIR/configure_pdk.py" "$BENCHMARK_ROOT/designs/$design" 2>&1 | grep -E "(✓|✔|✗|Error|warning|WARN)" || true
done

echo ""

echo "========================================"
echo "开始 AES13 批次"
echo "========================================"

run_args=(
    --jobs "${AES_JOBS:-1}"
    --target-utilization "$TARGET_UTILIZATION"
    --output-root "$RESULT_ROOT"
)

if [ -n "${AES_PROFILE_CACHE:-}" ]; then
    run_args+=(--profile-cache-mode "$AES_PROFILE_CACHE")
fi

python3 "$FLOW_DIR/run_13_aes_batch.sh" "${run_args[@]}"

echo ""
echo "========================================"
echo "阶段：生成统一总报告"
echo "========================================"
python3 "$FLOW_DIR/generate_comparison_report.py" --run-root "$RESULT_ROOT"

echo ""
echo "批量完成: $(date +%F %T %z)"
echo "========================================"
