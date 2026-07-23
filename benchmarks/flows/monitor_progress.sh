#!/bin/bash
# 监控13个AES设计的运行进度

DESIGNS_DIR="/home/lxq/AiEDA/iEDA.ai/benchmarks/designs"

echo "========================================="
echo "13个AES设计运行进度监控"
echo "时间: $(date)"
echo "========================================="
echo ""

# 设计列表
DESIGNS=(
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
    "aes_core_sky130_a"
)

# 阶段列表
STAGES=("iFP" "iTO_fix_fanout" "iPL" "iCTS" "iTO_drv" "iTO_hold" "iPL_legalization" "iRT" "iRT_DRC")

total_designs=${#DESIGNS[@]}
completed=0
in_progress=0
not_started=0
failed=0

echo "设计进度概览:"
echo "----------------------------------------"

for design in "${DESIGNS[@]}"; do
    result_dir="$DESIGNS_DIR/$design/workspace/result"

    if [ ! -d "$result_dir" ]; then
        echo "[$design] 未开始"
        ((not_started++))
        continue
    fi

    # 检查各阶段完成情况
    completed_stages=0
    last_stage=""

    for stage in "${STAGES[@]}"; do
        def_file="$result_dir/${stage}_result.def"
        if [ -f "$def_file" ]; then
            ((completed_stages++))
            last_stage="$stage"
        else
            break
        fi
    done

    # 判断状态
    if [ $completed_stages -eq ${#STAGES[@]} ]; then
        echo "[$design] ✓ 完成 (${completed_stages}/${#STAGES[@]})"
        ((completed++))
    elif [ $completed_stages -eq 0 ]; then
        # 检查是否有日志文件（可能正在运行或失败）
        log_files=$(find "$result_dir" -name "*.log" 2>/dev/null | wc -l)
        if [ $log_files -gt 0 ]; then
            echo "[$design] ✗ 失败或进行中 (0/${#STAGES[@]})"
            ((in_progress++))
        else
            echo "[$design] ○ 未开始"
            ((not_started++))
        fi
    else
        echo "[$design] ⋯ 进行中 (${completed_stages}/${#STAGES[@]}) - 最后阶段: $last_stage"
        ((in_progress++))
    fi
done

echo ""
echo "========================================="
echo "统计摘要:"
echo "  总计: $total_designs"
echo "  完成: $completed"
echo "  进行中/失败: $in_progress"
echo "  未开始: $not_started"
echo "========================================="

# 检查批量运行进程
if ps aux | grep -q "[r]un_13_aes_batch.sh"; then
    echo "批量运行进程: 运行中"
else
    echo "批量运行进程: 未运行"
fi

echo ""
