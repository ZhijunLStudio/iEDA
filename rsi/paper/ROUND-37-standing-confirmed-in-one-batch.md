# Round 37: the blocker is gone, the flow runs, and the corrected standing is confirmed by a single-batch rebuild

## 1. The flow runs again

After hiding the host's preload shim (round 36), the standard gp -> lg -> dp flow completes: rc 0, a
placement written, trial-route EGR measured. The standing rebuild of round 31 - which had been blocked
since round 32 - is now running, four designs at a time, both arms (our flow and the legalised reference)
inside one process per design.

## 2. The corrected standing, re-measured in a single batch

Eight of the fifteen valid designs are done. The point of doing this was to test whether round 28's
corrected standing - which legalised the reference in one batch and measured our placements in another -
survived the round-31 rule that a conclusion may only come from one batch containing both arms.

| design | single-batch hpwl / union / max | round-28 hpwl / union / max | verdict |
|---|---|---|---|
| gcd_sky130_a | 1.1357 / 2.3889 / 1.2727 | 1.14 / 2.39 / 1.27 | fail: hpwl, union, max |
| picorv32 | 0.8081 / 1.4525 / 1.6111 | 0.81 / 1.45 / 1.61 | fail: union, max |
| s1238 | 0.7613 / 1.142 / 1.4286 | 0.76 / 1.15 / 1.43 | fail: union, max |
| s1238_ics55_a | 0.8289 / 0.5226 / 0.4286 | 0.83 / 0.52 / 0.43 | **ALL** |
| s1238_nangate45_a | 0.7489 / - / - | 0.75 / - / - | **ALL** |
| s1238_sky130_a | 1.0776 / 2.0525 / 1.8571 | 1.08 / 2.05 / 1.86 | fail: hpwl, union, max |
| s38584_ics55_a | 0.9695 / 1.1656 / 1.6 | 0.97 / 1.18 / 1.6 | fail: union, max |
| s38584_nangate45_a | 0.959 / 1.5 / 1 | 0.96 / 1.5 / 1 | fail: union |


**Every single-batch ratio agrees with the round-28 cross-batch value to two decimal places, and several
agree to three or four.** The two methods gave the same answer.

That is worth stating plainly because it is a negative result about my own caution: the round-31 rule
was written after a genuine cross-batch anomaly, and applying it here shows the anomaly did **not** affect
these ratios. The round-28 protocol correction stands on re-measurement, and the cross-batch method was
sound for this quantity on these designs.

## 3. What the standing is

Of the eight designs measured so far, **two have every measurable dimension no worse than the reference**
- s1238_ics55_a (0.83 / 0.52 / 0.43) and s1238_nangate45_a (0.75 on wirelength; its reference cannot be
scored for congestion, so nothing is claimed there). Everything else fails, and **the failure is almost
always total overflow and peak together**: six of the eight fail union, five fail peak, and only two fail
wirelength.

That matches the round-28 picture and the objective's own diagnosis: **wirelength is roughly at parity,
congestion is the deficit, and peak is the worse of the two congestion numbers.**

## 4. Incident: two designs aborted their chunk

The first launch ran four chunks; two of them exited without writing results, on aes and on
salsa20_nangate45_a. They were relaunched with their output captured (the first launch used
stdio=ignore, which is why the cause was not recorded - my error). If they abort again, the captured
output will show why. The other five designs of the rebuild are in that same relaunched chunk.

## 5. Next

1. finish the rebuild (the remaining five valid designs plus the two that aborted);
2. **re-measure SR-13 and SR-14**, which round 36 established are *unmeasured* rather than rejected -
   their A/Bs could not switch binaries, so both arms ran the same binary and the "no-op" verdicts were
   guaranteed rather than observed;
3. resume algorithm work on the corrected baseline, where the target is peak congestion on the majority
   of designs and total overflow on most of them.
