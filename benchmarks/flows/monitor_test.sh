#!/bin/bash
# Monitor AES 40% test progress

RESULT_DIR="/home/lxq/AiEDA/iEDA.ai/benchmarks/results/aes3_40pct_20260729"
LOG_FILE="/tmp/aes3_40pct_run2.log"

echo "=== AES 40% Utilization Test Monitor ==="
echo "Started: $(date)"
echo ""

while true; do
    clear
    echo "=== Test Progress ($(date +%H:%M:%S)) ==="
    echo ""

    if [ -f "$LOG_FILE" ]; then
        echo "Last 20 lines from test log:"
        tail -20 "$LOG_FILE"
    fi

    echo ""
    echo "=== Design Status ==="
    for design in aes_sky130_a aes_nangate45_a aes_ics55_a; do
        if [ -f "$RESULT_DIR/$design/summary.json" ]; then
            status=$(jq -r '.status' "$RESULT_DIR/$design/summary.json" 2>/dev/null)
            echo "$design: $status"
        else
            echo "$design: running..."
        fi
    done

    echo ""
    echo "Press Ctrl+C to exit monitor"

    # Check if test completed
    if [ -f "$RESULT_DIR/summary.json" ]; then
        echo ""
        echo "=== Test Completed ==="
        jq -r '.summaries[] | "\(.design): \(.status)"' "$RESULT_DIR/summary.json"
        break
    fi

    sleep 30
done

echo ""
echo "Final summary at: $RESULT_DIR/summary.json"
