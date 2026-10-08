#!/bin/bash
# Single-instance wrapper: re-measure the CURRENT TREE arm at the same 4-flow pattern the SR-25
# validation used, so the round-80 comparison is matched (round 76: the co-run pattern moves a cell by
# 1-2 bins, so both columns of an acceptance decision must come from one pattern).
set -u
cd "$(dirname "$0")/../../.."
LOCK=/tmp/cur4_validation.lock
exec 9>"$LOCK"
if ! flock -n 9; then echo "already running; exiting" | tee -a /tmp/cur4_wrap.log; exit 1; fi
echo "=== wrapper start $(date) pid=$$ ===" >> /tmp/cur4_wrap.log
for attempt in $(seq 1 60); do
  n=$(ls runs/seedcells_cur4 2>/dev/null | wc -l)
  if [ "$n" -ge 60 ]; then echo "COMPLETE $n cells at $(date)" >> /tmp/cur4_wrap.log; break; fi
  echo "--- attempt $attempt at $(date): $n/60 ---" >> /tmp/cur4_wrap.log
  python3 ieda/rsi/harness/multi_seed_sweep.py --arms cur --seeds 1000,1001,1002,1003 \
      --workers 4 --outdir seedcells_cur4 >> /tmp/cur4_wrap.log 2>&1
  sleep 15
done
echo "=== wrapper done $(date) ===" >> /tmp/cur4_wrap.log
