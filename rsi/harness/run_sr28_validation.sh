#!/bin/bash
# flock-protected wrapper: the SR-28 sequential validation (the eleven candidate designs, four seeds,
# one flow at a time). The current-tree arm already exists in runs/seedcells_seq_cur from round 91, so only
# this arm is measured and the comparison is paired in one protocol.
set -u
cd "$(dirname "$0")/../../.."
LOCK=/tmp/sr28_validation.lock
exec 9>"$LOCK"
if ! flock -n 9; then echo "already running; exiting"; exit 1; fi
D=apb4_timer,gcd_ics55_a,gcd_nangate45_a,gcd_sky130_a,s1238,s1238_ics55_a,s1238_nangate45_a,s1238_sky130_a,s38584_ics55_a,s38584_nangate45_a,salsa20_ics55_a
echo "=== sr28 sequential validation start $(date) pid=$$ ===" >> /tmp/sr28_wrap.log
for attempt in $(seq 1 120); do
  n=$(ls runs/seedcells_seq_sr28 2>/dev/null | wc -l)
  if [ "$n" -ge 44 ]; then echo "COMPLETE $n cells at $(date)" >> /tmp/sr28_wrap.log; break; fi
  echo "--- attempt $attempt at $(date): $n/44 ---" >> /tmp/sr28_wrap.log
  python3 ieda/rsi/harness/multi_seed_sweep.py --arms sr28 --seeds 1000,1001,1002,1003 \
      --designs "$D" --workers 1 --outdir seedcells_seq_sr28 >> /tmp/sr28_wrap.log 2>&1
  sleep 15
done
echo "=== done $(date) ===" >> /tmp/sr28_wrap.log
