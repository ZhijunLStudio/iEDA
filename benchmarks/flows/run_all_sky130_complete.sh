#!/bin/bash
# 批量运行所有AES设计并生成完整报告和GDS

BENCHMARK_ROOT="/home/lxq/AiEDA/iEDA.ai/benchmarks"
FLOWS_DIR="$BENCHMARK_ROOT/flows"
DESIGNS_DIR="$BENCHMARK_ROOT/designs"

# 所有AES设计列表
ALL_DESIGNS=(
    "aes_sky130_a"
    "aes_sky130_b"
    "aes_sky130_t"
    "aes_core_sky130_a"
)

echo "=========================================="
echo "批量运行AES设计 - 生成完整DEF和GDS"
echo "开始时间: $(date)"
echo "=========================================="
echo ""

cd "$FLOWS_DIR"

# 统计
total=0
success=0
failed=0

for design in "${ALL_DESIGNS[@]}"; do
    ((total++))
    echo "----------------------------------------"
    echo "[$total/4] 运行: $design"
    echo "开始时间: $(date)"
    echo "----------------------------------------"

    # 运行完整流程
    timeout 1800 bash run_aes_simple.sh "$design" > /tmp/run_${design}.log 2>&1

    if [ $? -eq 0 ]; then
        echo "✓ $design 完成"
        ((success++))

        # 生成报告
        python3 generate_stage_report.py "$DESIGNS_DIR/$design" 2>/dev/null

        # 更新文件信息
        python3 update_report_files.py "$DESIGNS_DIR/$design" 2>/dev/null

    else
        echo "✗ $design 失败"
        ((failed++))
    fi

    echo ""
done

echo "=========================================="
echo "批量运行完成"
echo "结束时间: $(date)"
echo "=========================================="
echo ""
echo "统计:"
echo "  总数: $total"
echo "  成功: $success"
echo "  失败: $failed"
echo ""
