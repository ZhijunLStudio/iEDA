#!/bin/bash
# flock-protected wrapper for the initial-GP congestion-effort A/B. One flow at a time.
# Round 93: launched this way because every ad-hoc background launch in this campaign (rounds 79, 86, 88, 92)
# ended up confounded by a process I did not know was running.
set -u
cd "$(dirname "$0")/../../.."
LOCK=/tmp/initial_gp_effort.lock
exec 9>"$LOCK"
if ! flock -n 9; then echo "already running; exiting"; exit 1; fi
echo "=== initial-GP effort A/B start $(date) pid=$$ ===" >> /tmp/effab.log
python3 ieda/rsi/harness/initial_gp_effort_ab.py 's5378_sky130_b,s1238' '0,4' 1000 >> /tmp/effab.log 2>&1
echo "=== done $(date) ===" >> /tmp/effab.log
