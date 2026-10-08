# Round 17: the standing against Innovus, all metrics, one table

## 1. Shipped flow, valid (netlist-matched) designs, ratio ours/reference

Below 1.00 is better on every column. Bold marks no-worse-than-reference.

| design | PDK | HPWL | EGR union | EGR max | setup WNS | setup TNS |
|---|---|---|---|---|---|---|
| aes | sky130 | **0.73** | **0.73** | 1.45 | **0.95** | 1.00 |
| apb4_timer | sky130 | **0.84** | **0.36** | **0.77** | **0.87** | **0.88** |
| gcd_ics55_a | ics55 | **0.94** | **0.93** | **0.50** | - | - |
| gcd_nangate45_a | nangate45 | **0.90** | - | - | - | - |
| gcd_sky130_a | sky130 | 1.14 | 1.07 | 1.17 | **0.35** | **0.55** |
| picorv32 | sky130 | **0.80** | **0.75** | 1.85 | **0.99** | **0.95** |
| s1238 | sky130 | **0.69** | **0.53** | 1.47 | **-0.02** | **-0.00** |
| s1238_ics55_a | ics55 | **0.80** | **0.73** | **0.86** | - | - |
| s1238_nangate45_a | nangate45 | **0.72** | - | - | - | - |
| s1238_sky130_a | sky130 | 1.09 | 1.51 | 2.19 | **0.85** | **0.62** |
| s38584_ics55_a | ics55 | **0.95** | 1.06 | 1.33 | - | - |
| s38584_nangate45_a | nangate45 | **0.94** | 3.50 | 2.00 | - | - |
| s5378_sky130_b | sky130 | **0.88** | **0.73** | 1.32 | **0.42** | **0.43** |
| salsa20_ics55_a | ics55 | **0.95** | **0.78** | 1.35 | - | - |
| salsa20_nangate45_a | nangate45 | **0.92** | 4.36 | 1.40 | - | - |

| metric | designs | median | no worse |
|---|---|---|---|
| HPWL | 15 | **0.90** | 13/15 (87%) |
| EGR union | 13 | **0.78** | 8/13 (62%) |
| EGR max | 13 | **1.35** | 3/13 (23%) |
| setup WNS | 7 | **0.85** | 7/7 (100%) |
| setup TNS | 7 | **0.62** | 6/7 (86%) |

Two nangate45 designs have no congestion ratio because the reference's overflow is exactly zero, so a
ratio is undefined; those two are reported as HPWL-only.

## 2. With the measured candidate pool

The pool is six candidates; the rule is now stated explicitly rather than left to the Pareto frontier:
**minimise peak overflow, break ties on total overflow, then on wirelength.** Same seed for both arms.

| design | seeds | HPWL | EGR union | EGR max | union: shipped to pool | max: shipped to pool |
|---|---|---|---|---|---|---|
| aes | 2 | **0.78** | **0.75** | 1.27 | 0.74 to 0.75 | 1.55 to **1.27** |
| apb4_timer | 2 | **0.89** | **0.40** | **0.77** | 0.37 to 0.40 | 0.85 to **0.77** |
| gcd_ics55_a | 3 | **0.94** | 1.15 | **1.00** | - | 1.00 to 1.00 |
| gcd_sky130_a | 2 | **0.97** | **0.43** | **0.67** | 0.43 to 0.43 | 0.67 to 0.67 |
| picorv32 | 2 | **0.81** | **0.71** | 1.25 | 0.73 to **0.71** | 1.30 to **1.25** |
| s1238 | 2 | **0.76** | **0.42** | **0.80** | 0.54 to **0.42** | 1.67 to **0.80** |
| s1238_ics55_a | 3 | **0.79** | **0.33** | **0.57** | 0.84 to **0.33** | 1.00 to **0.57** |
| s1238_sky130_a | 3 | **0.95** | **0.75** | **1.00** | 1.32 to **0.75** | 1.19 to **1.00** |
| s38584_ics55_a | 2 | **0.95** | **1.00** | **0.94** | 1.00 to 1.00 | 0.94 to 0.94 |
| s38584_nangate45_a | 3 | **0.98** | **0.83** | **0.50** | 2.17 to **0.83** | 1.00 to **0.50** |
| s5378_sky130_b | 2 | **0.90** | **0.70** | 1.18 | 0.75 to **0.70** | 1.55 to **1.18** |
| salsa20_ics55_a | 2 | **0.95** | **0.75** | **1.00** | 0.75 to 0.75 | 1.00 to 1.00 |
| salsa20_nangate45_a | 3 | **0.97** | 2.05 | **0.90** | 3.78 to **2.05** | 1.20 to **0.90** |

| metric | designs | median | no worse |
|---|---|---|---|
| EGR union | 13 | **0.75** | 11/13 |
| **EGR max** | 13 | **0.94** | **10/13** |

**The pool moves the failing dimension from a median of 1.35 with 3 of 13 no-worse to a median of
0.94 with 10 of 13 no-worse.** Both congestion medians are now below the reference.

The three designs that remain worse on the peak are aes (1.27), picorv32 (1.25) and s5378_sky130_b
(1.18) - all mild, all sky130, and all well down from 1.45, 1.85 and 1.32. Two designs remain worse on
total overflow: salsa20_nangate45_a at 2.05 (down from 4.36) and gcd_ics55_a at 1.15.

## 3. A defect found in my own selection function

The first version of this table reported the pool as making the peak *worse* on apb4_timer,
s38584_ics55_a and salsa20_ics55_a. That was a bug: among candidates that do not dominate one another
the code kept whichever appeared first in a dictionary, so the reported "best" was an arbitrary point
on the Pareto frontier. The rule is now explicit and reproducible, and with it **no design is worse on
the peak than its own shipped candidate**.

The same bug had been present in the earlier pool analyses. It did not change the headline result -
the frontier always contained a point at least as good as the shipped candidate, because the shipped
candidate is in the pool - but it made individual rows arbitrary.

## 4. Timing

Measured on sky130 only: ics55 stops while reading the LEF and nangate45 crashes inside the timing
tool, on our placement and the reference's alike. So of the thirteen valid designs, **seven have a
timing measurement and six do not and cannot**. On those seven we lead: setup WNS 7/7 at a median of
0.85, setup TNS 6/7 at 0.62.

Where the pool's choice was also checked against timing - one design, s1238_sky130_a seed 1002 - the
chosen candidate was faster as well as better on wirelength and both congestion metrics.

## 5. Cost

Six candidates is six placements and six congestion evaluations per design: about 71 s of extra work
per design against a 7.4 s global placement, so roughly ten times the shipped flow's placement time.
On a design where no candidate beats the shipped one the pool buys nothing.

## 6. Honest summary

| dimension | shipped flow | with the pool | note |
|---|---|---|---|
| HPWL | 0.90, 13/15 | 0.95 median on the pool set | we lead in both |
| EGR union | 0.78, 8/13 | **0.75, 11/13** | leads in both |
| EGR max | 1.35, 3/13 | **0.94, 10/13** | **the failing dimension now leads** |
| setup WNS | 0.85, 7/7 | not re-measured | we lead where measurable |
| setup TNS | 0.62, 6/7 | not re-measured | we lead where measurable |
| timing on ics55/nangate45 | unmeasurable | unmeasurable | coverage limit |

Four dimensions lead and the fifth now leads by median as well, with three designs (aes, picorv32,
s5378_sky130_b) still above 1.0 on the peak and two (salsa20_nangate45_a, gcd_ics55_a) above 1.0 on
total overflow.

**Not claimed**: that every design is no-worse on every dimension. Ten of thirteen lead on the peak;
three do not. Timing is unverified on the six valid designs where the largest congestion wins sit.
