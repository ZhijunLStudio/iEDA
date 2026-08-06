#!/bin/bash
# 监控 AES13 65% 利用率运行进度

echo "=========================================="
echo "AES13 65% 利用率流程监控"
echo "时间: $(date)"
echo "=========================================="
echo

RESULT_DIR="benchmarks/results/aes13_65pct"

# 检查进程
if pgrep -f "aes13_flow.py.*65pct" > /dev/null; then
    echo "✓ 流程正在运行"
    PID=$(pgrep -f "aes13_flow.py.*65pct")
    echo "  PID: $PID"
else
    echo "✗ 流程未运行"
fi
echo

# 统计完成进度
echo "设计完成状态:"
echo "----------------------------------------"
printf "%-20s %-10s %-10s %-10s\n" "Design" "Floorplan" "Placement" "Routing"

for design in aes aes_sky130_{a,b,t} aes_nangate45_{a,b,t} aes_asap7_{a,b,t} aes_ics55_{a,b,t}; do
    if [ -d "$RESULT_DIR/$design/workspace/result" ]; then
        fp=""; pl=""; rt=""
        [ -f "$RESULT_DIR/$design/workspace/result/iFP_result.def" ] && fp="✓"
        [ -f "$RESULT_DIR/$design/workspace/result/iPL_result.def" ] && pl="✓"
        [ -f "$RESULT_DIR/$design/workspace/result/iRT_result.def" ] && rt="✓"
        printf "%-20s %-10s %-10s %-10s\n" "$design" "$fp" "$pl" "$rt"
    fi
done
echo

# 统计
total=13
fp_done=$(find "$RESULT_DIR" -name "iFP_result.def" 2>/dev/null | wc -l)
pl_done=$(find "$RESULT_DIR" -name "iPL_result.def" 2>/dev/null | wc -l)
rt_done=$(find "$RESULT_DIR" -name "iRT_result.def" 2>/dev/null | wc -l)
gds_done=$(find "$RESULT_DIR" -name "final.gds" 2>/dev/null | wc -l)

echo "总体进度:"
echo "  Floorplan: $fp_done / $total"
echo "  Placement: $pl_done / $total"
echo "  Routing:   $rt_done / $total"
echo "  GDS:       $gds_done / $total"
echo

# 最新日志
latest_log=$(ls -t benchmarks/flows/logs/aes13-65pct-run-*.log 2>/dev/null | head -1)
if [ -n "$latest_log" ]; then
    echo "最新日志 (最后 15 行):"
    echo "----------------------------------------"
    tail -15 "$latest_log"
fi

echo
echo "=========================================="
echo "持续监控: watch -n 30 $0"
echo "=========================================="
