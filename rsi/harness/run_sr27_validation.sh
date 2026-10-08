#!/bin/bash
# Single-instance wrapper for the SR-27 validation (segment chooser restricted to segments that are no
# worse than the entry state on either scored number).
set -u
cd "$(dirname "$0")/../../.."
LOCK=/tmp/sr27_validation.lock
exec 9>"$LOCK"
if ! flock -n 9; then echo "already running; exiting" | tee -a /tmp/sr27_wrap.log; exit 1; fi
echo "=== wrapper start $(date) pid=$$ ===" >> /tmp/sr27_wrap.log
for attempt in $(seq 1 80); do
  n=$(ls runs/seedcells_sr27 2>/dev/null | wc -l)
  if [ "$n" -ge 60 ]; then echo "COMPLETE $n cells at $(date)" >> /tmp/sr27_wrap.log; break; fi
  echo "--- attempt $attempt at $(date): $n/60 ---" >> /tmp/sr27_wrap.log
  python3 ieda/rsi/harness/multi_seed_sweep.py --arms sr27 --seeds 1000,1001,1002,1003 \
      --workers 4 --outdir seedcells_sr27 >> /tmp/sr27_wrap.log 2>&1
  sleep 15
done
echo "=== wrapper done $(date) ===" >> /tmp/sr27_wrap.log
