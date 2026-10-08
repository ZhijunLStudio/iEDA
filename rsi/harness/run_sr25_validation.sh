#!/bin/bash
# Resilient, single-instance wrapper for the SR-25 four-seed validation.
#
# Round 79: the previous wrapper had no lock, and two earlier launches I believed were dead were still
# running, so three sweeps raced over the same work directories and corrupted each other's cells. This
# version takes an exclusive lock and refuses to start if one is already held.
set -u
cd "$(dirname "$0")/../../.."
LOCK=/tmp/sr25_validation.lock
exec 9>"$LOCK"
if ! flock -n 9; then
  echo "another validation is already running; exiting" | tee -a /tmp/ms25_wrap.log
  exit 1
fi
echo "=== wrapper start $(date) pid=$$ ===" >> /tmp/ms25_wrap.log
for attempt in $(seq 1 60); do
  n=$(ls runs/seedcells_sr25 2>/dev/null | wc -l)
  if [ "$n" -ge 60 ]; then echo "COMPLETE $n cells at $(date)" >> /tmp/ms25_wrap.log; break; fi
  echo "--- attempt $attempt at $(date): $n/60 cells ---" >> /tmp/ms25_wrap.log
  python3 ieda/rsi/harness/multi_seed_sweep.py --arms sr25 --seeds 1000,1001,1002,1003 \
      --workers 4 --outdir seedcells_sr25 >> /tmp/ms25_wrap.log 2>&1
  sleep 15
done
echo "=== wrapper done $(date) ===" >> /tmp/ms25_wrap.log
