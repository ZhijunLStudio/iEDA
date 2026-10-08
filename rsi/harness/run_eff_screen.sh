#!/bin/bash
# Screen the untried variant: congestion_effort on the INITIAL global placement (SR-26 only uses it on the
# finishing passes). Sequential, one flow at a time, log to /tmp/eff_wrap.log.
set -u
cd "$(dirname "$0")/../../.."
LOCK=/tmp/eff_screen.lock
exec 9>"$LOCK"
if ! flock -n 9; then echo "already running"; exit 1; fi
echo "=== eff screen start $(date) ===" >> /tmp/eff_wrap.log
python3 /tmp/efftest2.py 'picorv32,s1238,s5378_sky130_b,aes,salsa20_nangate45_a' '4' 1000 >> /tmp/eff_wrap.log 2>&1
echo "=== eff screen done $(date) ===" >> /tmp/eff_wrap.log
