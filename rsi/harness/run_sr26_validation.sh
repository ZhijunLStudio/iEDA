#!/bin/bash
# Single-instance wrapper for the SR-26 validation (the refinement allowed to converge further, with a
# stagnation stop). Same protocol as every other arm: PL.num_threads=1 is written by the sweep, and
# OMP_NUM_THREADS=1 is set per cell by the sweep itself.
set -u
cd "$(dirname "$0")/../../.."
LOCK=/tmp/sr26_validation.lock
exec 9>"$LOCK"
if ! flock -n 9; then echo "already running; exiting" | tee -a /tmp/sr26_wrap.log; exit 1; fi
echo "=== wrapper start $(date) pid=$$ ===" >> /tmp/sr26_wrap.log
for attempt in $(seq 1 80); do
  n=$(ls runs/seedcells_sr26 2>/dev/null | wc -l)
  if [ "$n" -ge 60 ]; then echo "COMPLETE $n cells at $(date)" >> /tmp/sr26_wrap.log; break; fi
  echo "--- attempt $attempt at $(date): $n/60 ---" >> /tmp/sr26_wrap.log
  python3 ieda/rsi/harness/multi_seed_sweep.py --arms sr26 --seeds 1000,1001,1002,1003 \
      --workers 4 --outdir seedcells_sr26 >> /tmp/sr26_wrap.log 2>&1
  sleep 15
done
echo "=== wrapper done $(date) ===" >> /tmp/sr26_wrap.log
