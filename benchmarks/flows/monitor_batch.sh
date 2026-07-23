#!/bin/bash
# 监控批量运行进度

DESIGNS_DIR="/home/lxq/AiEDA/iEDA.ai/benchmarks/designs"

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

clear
echo "========================================="
echo "AES设计批量运行进度监控"
echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================="
echo ""

completed=0
in_progress=0
not_started=0

for design in "${DESIGNS[@]}"; do
    result_dir="$DESIGNS_DIR/$design/workspace/result"

    if [ ! -d "$result_dir" ]; then
        printf "%-25s  ○ 未开始\n" "[$design]"
        ((not_started++))
        continue
    fi

    # 统计完成的阶段
    stages=0
    [ -f "$result_dir/iFP_result.def" ] && ((stages++))
    [ -f "$result_dir/iPL_result.def" ] && ((stages++))
    [ -f "$result_dir/iCTS_result.def" ] && ((stages++))
    [ -f "$result_dir/iTO_drv_result.def" ] && ((stages++))
    [ -f "$result_dir/iTO_hold_result.def" ] && ((stages++))
    [ -f "$result_dir/iPL_lg_result.def" ] && ((stages++))
    [ -f "$result_dir/iRT_result.def" ] && ((stages++))

    if [ $stages -ge 6 ]; then
        printf "%-25s  ✓ 完成 (%d/7阶段)\n" "[$design]" "$stages"
        ((completed++))
    elif [ $stages -gt 0 ]; then
        printf "%-25s  ⋯ 进行中 (%d/7阶段)\n" "[$design]" "$stages"
        ((in_progress++))
    else
        printf "%-25s  ✗ 失败/未开始\n" "[$design]"
        ((not_started++))
    fi
done

echo ""
echo "========================================="
echo "统计:"
echo "  完成: $completed"
echo "  进行中: $in_progress"
echo "  未开始/失败: $not_started"
echo "========================================="
