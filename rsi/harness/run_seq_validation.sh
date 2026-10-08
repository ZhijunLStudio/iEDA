#!/bin/bash
# Single-instance wrapper: the PROTOCOL-CORRECT validation, one flow at a time.
#
# Round 86: the co-run pattern changes cells by enough to flip verdicts (gcd_sky130_a seed 1003 passes 4/4
# sequentially at 747/14 and failed at 1004/19 with four flows in flight). Round 76 adopted one-flow-at-a-time
# precisely to isolate the source change, so the defensible numbers must be measured that way. Every earlier
# validation in this campaign ran several flows at once for speed, which is a protocol deviation.
#
# Covers the ten designs that pass at least one seed in some arm, since only those can move the primary count.
set -u
cd "$(dirname "$0")/../../.."
LOCK=/tmp/seq_validation.lock
exec 9>"$LOCK"
if ! flock -n 9; then echo "already running; exiting" | tee -a /tmp/seq_wrap.log; exit 1; fi
D=apb4_timer,gcd_ics55_a,gcd_nangate45_a,gcd_sky130_a,s1238,s1238_ics55_a,s1238_nangate45_a,s1238_sky130_a,s38584_ics55_a,s38584_nangate45_a,salsa20_ics55_a
echo "=== wrapper start $(date) pid=$$ ===" >> /tmp/seq_wrap.log
for attempt in $(seq 1 200); do
  n=$(ls runs/seedcells_seq_sr26 2>/dev/null | wc -l)
  m=$(ls runs/seedcells_seq_cur 2>/dev/null | wc -l)
  if [ "$n" -ge 44 ] && [ "$m" -ge 44 ]; then echo "COMPLETE cur=$m sr26=$n at $(date)" >> /tmp/seq_wrap.log; break; fi
  echo "--- attempt $attempt at $(date): cur=$m sr26=$n (target 44 each) ---" >> /tmp/seq_wrap.log
  python3 ieda/rsi/harness/multi_seed_sweep.py --arms sr26 --seeds 1000,1001,1002,1003 \
      --designs "$D" --workers 1 --outdir seedcells_seq_sr26 >> /tmp/seq_wrap.log 2>&1
  python3 ieda/rsi/harness/multi_seed_sweep.py --arms cur --seeds 1000,1001,1002,1003 \
      --designs "$D" --workers 1 --outdir seedcells_seq_cur >> /tmp/seq_wrap.log 2>&1
  sleep 15
done
echo "=== wrapper done $(date) ===" >> /tmp/seq_wrap.log
