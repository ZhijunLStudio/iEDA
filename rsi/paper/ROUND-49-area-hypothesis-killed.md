# Round 49: a geometric hypothesis tested and killed, and a caveat on two of the failures

## 1. The hypothesis, and its refutation

The broad-overflow designs carry overflow on 30 to 40 per cent of the die at a shallow depth, which is
what a placement looks like when routing demand is too high everywhere. The obvious geometric cause would
be that our placer, optimising wirelength, shrinks the used area relative to the reference and so raises
local utilisation across the chip.

Measured from the placement files already on disk - the bounding box of placed cells, ours against the
reference's - and ranked against the total-overflow ratio:

| design | our bbox / ref bbox | total overflow ratio |
|---|---|---|
| s1238_ics55_a | 0.651 | 0.52 |
| s1238_nangate45_a | 0.503 | - |
| gcd_nangate45_a | 0.672 | - |
| gcd_ics55_a | 0.759 | 1.85 |
| s1238_sky130_a | 0.829 | 2.05 |
| s5378_sky130_b | 0.882 | 1.56 |
| aes | 0.931 | 1.36 |
| gcd_sky130_a | 0.977 | 2.39 |
| s1238 | 0.982 | 1.14 |
| apb4_timer | 0.989 | 0.93 |
| picorv32 | 0.996 | 1.45 |
| salsa20_ics55_a | 0.999 | 0.79 |
| s38584_nangate45_a | 1.003 | 1.50 |
| s38584_ics55_a | 1.005 | 1.17 |
| salsa20_nangate45_a | 1.006 | 1.89 |

**Spearman rank correlation: -0.055.** Essentially zero.

The apparent pattern is an artefact of the ends: the three designs where we use the least area include
both our worst total-overflow failure (gcd_ics55_a, 0.759) and two clean passes (s1238_ics55_a 0.651,
s1238_nangate45_a 0.503). **Our used area does not predict the congestion outcome**, and the hypothesis is
discarded. It is recorded because a geometric explanation of the broad signature would have been
actionable, and this rules one out.

## 2. Two of the ten total-overflow failures are not physically meaningful

Absolute totals, ours against the reference's:

| design | ours | reference | ratio | note |
|---|---|---|---|---|
| s38584_nangate45_a | **3** | **2** | 1.50 | negligible on both sides |
| gcd_ics55_a | **37** | **20** | 1.85 | small on both sides |
| s1238 | 1753 | 1535 | 1.14 | real |
| s38584_ics55_a | 3244 | 2783 | 1.17 | real |
| aes | 354032 | 260148 | 1.36 | real |
| picorv32 | 121153 | 83408 | 1.45 | real |
| s5378_sky130_b | 3776 | 2421 | 1.56 | real |
| salsa20_nangate45_a | 464 | 246 | 1.89 | real |
| s1238_sky130_a | 3594 | 1751 | 2.05 | real |
| gcd_sky130_a | 2150 | 900 | 2.39 | real |

**Eight of the ten total-overflow failures are on meaningful counts; two are ratios of near-zero numbers**
(three bins against two, thirty-seven against twenty) where the ratio overstates the physical problem. The
objective defines a failure as a ratio above 1.00, so they count as failures under its rule, but they
should not be read as congestion problems of the same kind as the other eight, and no mechanism is worth
building for a three-bin difference.

**This does not apply to the peak.** Peak counts are small by nature - the reference's peaks run from 7 to
36 bins - and a ratio of 1.27 there is a difference of six bins at the worst location on the die, which is
a real physical quantity. All nine peak failures stand.

## 3. Where this leaves the round

Two things are now known that were not:

1. **The broad-overflow signature is not an area-utilisation effect**, which removes the simplest
   geometric explanation for the largest failure group.
2. **The design set contains two "failures" that are artefacts of near-zero counts**, so the effective
   number of total-overflow failures to solve is eight, not ten.

Neither is progress toward the objective directly; both narrow where the answer can be. The next thing to
try should address the broad signature by some other route, and the most informative measurement available
is still the reference's own map, which the evaluator does not currently write into the reference work
directories - the cell-by-cell comparison remains blocked on that.

## 4. State

- **In the tree**: SR-10, SR-11. Binary f9581627.
- **Standing**: 4 of 15 designs no worse on every measurable dimension. Wirelength fails 2 of 15. Total
  overflow fails 10 of 13, of which **8 are on meaningful totals**. Peak fails 9 of 13, **all meaningful**.
- **Withdrawn with reasons**: SR-2/3/4/5/7/8/9/12/13/14/15/16.
