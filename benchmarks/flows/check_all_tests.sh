#!/bin/bash
# Quick status check for all progressive utilization tests

echo "=== Progressive Utilization Test Status ($(date +%H:%M:%S)) ==="
echo ""

for util in 40 50 55 60 65; do
    result_dir=$(ls -d /home/lxq/AiEDA/iEDA.ai/benchmarks/results/aes3_${util}pct* 2>/dev/null | tail -1)

    if [ -z "$result_dir" ]; then
        echo "${util}%: Not started"
        continue
    fi

    if [ -f "$result_dir/summary.json" ]; then
        status=$(jq -r '.summaries | map(.status) | if all(. == "success") then "✓ ALL SUCCESS" elif any(. == "success") then "⚠ PARTIAL" else "✗ FAILED" end' "$result_dir/summary.json" 2>/dev/null)
        designs=$(jq -r '.summaries[] | "\(.design):\(.status)"' "$result_dir/summary.json" | tr '\n' ' ')
        echo "${util}%: $status - $designs"
    else
        # Check if process is running
        if ps aux | grep -q "aes3_${util}pct.*aes13_flow.py" | grep -v grep; then
            echo "${util}%: 🔄 RUNNING"
        else
            echo "${util}%: ⏳ Incomplete"
        fi
    fi
done

echo ""
echo "=== Active Processes ==="
ps aux | grep "aes13_flow.py.*aes3_" | grep -v grep | awk '{print $2, $10, $11, $12, $13, $14, $15}'
