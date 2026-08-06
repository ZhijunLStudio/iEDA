#!/bin/bash
# 监控 AES13 流程进度

RESULT_ROOT="${1:-benchmarks/results/aes13_60pct}"

echo "=========================================="
echo "AES13 流程进度监控"
echo "结果目录: $RESULT_ROOT"
echo "时间: $(date)"
echo "=========================================="
echo

# 检查正在运行的 Python 进程
if pgrep -f "aes13_flow.py" > /dev/null; then
    echo "✓ 流程正在运行"
    PIDS=$(pgrep -f "aes13_flow.py")
    echo "  PIDs: $PIDS"
else
    echo "✗ 未检测到运行中的 aes13_flow.py"
fi
echo

# 检查各设计的完成状态
echo "设计完成状态:"
echo "----------------------------------------"
for design in aes aes_sky130_{a,b,t} aes_nangate45_{a,b,t} aes_asap7_{a,b,t} aes_ics55_{a,b,t}; do
    if [ -d "$RESULT_ROOT/$design" ]; then
        # 检查关键文件
        has_def=""
        has_gds=""
        has_sta=""

        if [ -f "$RESULT_ROOT/$design/workspace/result/final.def" ]; then
            has_def="DEF"
        fi
        if [ -f "$RESULT_ROOT/$design/workspace/result/final.gds" ]; then
            has_gds="GDS"
        fi
        if [ -f "$RESULT_ROOT/$design/workspace/result/timing/post_route_setup.rpt" ]; then
            has_sta="STA"
        fi

        status="$has_def $has_gds $has_sta"
        if [ -z "$status" ]; then
            status="进行中..."
        fi

        printf "  %-20s %s\n" "$design" "$status"
    fi
done
echo

# 统计完成数量
total_designs=13
completed_gds=$(find "$RESULT_ROOT" -name "final.gds" 2>/dev/null | wc -l)
completed_sta=$(find "$RESULT_ROOT" -name "post_route_setup.rpt" 2>/dev/null | wc -l)

echo "总体进度:"
echo "  GDS 完成: $completed_gds / $total_designs"
echo "  STA 完成: $completed_sta / $total_designs"
echo

# 显示最近的日志
if [ -f "$RESULT_ROOT/../logs/aes13-60pct-run-"*.log ]; then
    latest_log=$(ls -t benchmarks/flows/logs/aes13-60pct-run-*.log 2>/dev/null | head -1)
    if [ -n "$latest_log" ]; then
        echo "最近日志 (最后 10 行):"
        echo "----------------------------------------"
        tail -10 "$latest_log"
    fi
fi

echo
echo "=========================================="
echo "刷新: watch -n 30 $0 $RESULT_ROOT"
echo "=========================================="
