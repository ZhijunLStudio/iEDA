# Round 25: how many designs beat Innovus on every dimension

## The count

| | shipped flow | **current tree (SR-10 + SR-11)** |
|---|---|---|
| valid designs | 15 | 15 |
| **every measurable dimension no-worse** | 5 | **6** |
| three-metric core (wirelength, total overflow, peak overflow) all better | 3 of 13 | **4 of 13** |
| all five dimensions (including setup WNS and TNS) all better | 1 | **1** |

The one design that beats the reference on all five at once is **apb4_timer** (wirelength 0.84, total
overflow 0.34, peak 0.62, setup WNS 0.87, setup TNS 0.88). It is the only design where all five are
both measurable and better, because timing can only be measured on sky130.

## The single gate is peak congestion

| group | count | designs |
|---|---|---|
| every measurable dimension no-worse | **6** | apb4_timer, gcd_ics55_a, gcd_nangate45_a, s1238_ics55_a, s1238_nangate45_a, s38584_nangate45_a |
| **blocked by EGR max alone** | **5** | picorv32, s1238, s38584_ics55_a, s5378_sky130_b, salsa20_ics55_a |
| blocked by two or more dimensions | 4 | aes, gcd_sky130_a, s1238_sky130_a, salsa20_nangate45_a |

**Five designs fail on exactly one number**: peak overflow 1.26 to 1.45 against the reference. Their
wirelength, total overflow and - where measurable - timing are all already better. So the answer to
"how many" is bounded by a single dimension, and resolving it moves the count from 6 to 11 of 15.

## What the guard changed, per design

| design | total overflow | peak overflow | verdict |
|---|---|---|---|
| s38584_nangate45_a | 3.50 to **0.50** | 2.00 to **0.50** | fail to **ALL** |
| salsa20_nangate45_a | 4.36 to **1.86** | 1.40 to 1.20 | still blocked |
| s1238_ics55_a | 0.73 to **0.46** | 0.86 to **0.43** | ALL, by a wider margin |
| picorv32 | 0.75 to 0.72 | 1.85 to **1.45** | still blocked |
| s1238_sky130_a | 1.51 to 1.44 | 2.19 to **1.62** | still blocked |
| s5378_sky130_b | 0.73 to 0.68 | 1.32 to 1.27 | still blocked |
| salsa20_ics55_a | 0.78 to 0.77 | 1.35 to 1.26 | still blocked |
| apb4_timer | 0.36 to 0.34 | 0.77 to **0.62** | ALL, by a wider margin |

Wirelength pays between 0 and 10% relative on the designs where the guard fires (s1238 0.69 to 0.76 is
the largest), and is unchanged where it does not.

## The caveat that matters

**This table is one seed.** The multi-seed check of the guard (12 seed-pairs, Round 21 addendum) found
it fires on 4 of them and abstains byte-identically on the other 8, because at those seeds detail
placement did not damage congestion in the first place. So:

- where the guard fires, the result is **never worse** than without it, by construction;
- the no-worse count of 6 is the count **at seed 1000**, and at other seeds some of those designs were
  already no-worse without the guard;
- the honest statement is that the guard removes the tail, and the count of designs no-worse on every
  dimension is **between 5 and 6 depending on the seed**, not a fixed 6.

## What would move the number

Everything points at one target: **peak congestion, five designs short by 1.26x to 1.45x**. Two of the
five (s1238, s5378_sky130_b) are also the designs whose deficit is created before detail placement, so
the fix is in global placement or legalisation rather than in the guard. That is the next source
change, and it is worth 5 designs if it works.
