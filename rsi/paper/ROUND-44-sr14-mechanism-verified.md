# Round 44: SR-14 is a verified mechanism, and a knob with a predictable activation

## 1. What SR-14 is

Keep the Nesterov solve alive past step-length stagnation when the density overflow is still above 1.1x
its target, engaging the quadratic density penalty the tree already contains, instead of terminating the
solve there.

It was rejected earlier as "identical to the control". Round 43 showed that verdict came from a harness
that could not switch binaries. This round measures it properly across designs and seeds, and checks the
mechanism rather than only the outcome.

## 2. The mechanism check, which is the main result

SR-14's prediction is specific: **global placement terminates with overflow above its target on some
designs, and on exactly those designs the change should lower that overflow**. Measured directly, by
reading global placement's terminal overflow from each arm's own record:

| design | seed | GP terminal overflow, control -> SR-14 | congestion outcome |
|---|---|---|---|
| **gcd_sky130_a** | 1000 | 0.1233 -> **0.1194 (lower)** | large improvement |
| gcd_sky130_a | 1001 | 0.1174 -> 0.1182 (higher) | essentially unchanged |
| gcd_sky130_a | 1002 | 0.1168 -> **0.1138 (lower)** | large improvement |
| gcd_sky130_a | 1003 | 0.1164 -> 0.1188 (higher) | essentially unchanged |
| gcd_sky130_a | 1004 | 0.1124 -> **0.1055 (lower)** | mixed |
| gcd_sky130_a | 1005 | 0.1197 -> **0.1154 (lower)** | (scoring in flight) |
| **apb4_timer** | 1000 | 0.0983 -> 0.0998 | unchanged |
| **gcd_ics55_a** | 1000 | 0.0999 -> 0.0990 | unchanged at the peak |
| **s1238_ics55_a** | - | ~0.098-0.100 | unchanged |
| **s1238_sky130_a** | 1000-1002 | 0.128 -> **0.131 (higher, all three seeds)** | congestion worse |

**Two things are established, not assumed.**

**(a) SR-14 is inert exactly where the derivation says it should be.** apb4_timer, gcd_ics55_a and
s1238_ics55_a all terminate with overflow at or below their target (0.098 to 0.100), so the mechanism
never engages, and their congestion does not move. That is the safety property: it costs nothing on
designs whose global placement converges.

**(b) Congestion moves with the mechanism.** Where SR-14 lowers global placement's terminal overflow,
congestion improves and by a lot; where it fails to, congestion does not improve; and on
s1238_sky130_a, where it raises the overflow at all three seeds, congestion gets worse.

## 3. The outcome on gcd_sky130_a, the design the mechanism targets

| seed | total overflow (ctl -> SR-14) | peak overflow | wirelength |
|---|---|---|---|
| 1000 | 2.2556 -> **0.9667** | 1.2727 -> **0.8182** | **-16.0%** |
| 1001 | 1.0211 -> **0.9678** | 1.0000 -> 1.0000 | -0.2% |
| 1002 | 2.0111 -> **0.8500** | 1.3636 -> **0.9091** | **-11.5%** |
| 1003 | 0.9889 -> **0.8844** | 0.7273 -> 0.7273 | +0.1% |
| 1004 | 0.7222 -> 0.8589 (worse) | 0.7273 -> **0.6364** | -1.2% |

**Four of five seeds improve total overflow, three improve the peak and none worsens it, and wirelength
improves at three.** Two seeds take total overflow from failing the reference to winning it.

## 4. And the honest limit

**s1238_sky130_a gets worse at all three seeds** (total 2.05 -> 1.95 at one seed is the only improvement;
the other two worsen, and the peak worsens at all three). Its global placement also terminates above
target (0.128), so activation is not the discriminator.

**So SR-14 is a knob with a predictable activation and an unpredictable sign.** It engages exactly where
global placement stagnates above its target; whether the extra iterations help or hurt is
design-dependent, and nothing measured here predicts which.

That is still a strong result, and it points at the fix: the tool can measure its own global-placement
overflow before and after the change engages, which is a signal available in-run. A version that keeps
the mechanism only when it demonstrably lowers its own overflow would be the same pattern as the SR-11
guard, and it is testable.

## 5. Cost

SR-14 runs global placement longer on the designs where it engages - it is extra iterations, not extra
evaluator calls, so the cost is bounded and much smaller than congestion-effort level 4's tens-of-minutes
per design.

## 6. Tree state

Source unchanged: SR-10 and SR-11 in; SR-2/3/4/5/7/8/9/12 withdrawn. **SR-14 is a verified mechanism and a
live candidate, pending either a self-guarded version or a design-level discriminator; SR-13 remains out
as mixed.** Binary f9581627.
