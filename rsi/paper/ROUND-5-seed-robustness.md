# Round 5: the seed spread dominates, and Round 3's result is retracted

## 1. Outcome in one line

The single-seed methodology that Rounds 1-4 rested on cannot resolve the effects those rounds
claimed. Repeating seeds shows the Round 3 headline does not reproduce, the candidates from this
round are not wins either, and two individually-positive changes combine into a worse result
than either. No source change in five rounds has been demonstrated to improve the objective
beyond noise.

## 2. What was tested this round

Rounds 1-4 had established that everything about where cells sit fails to control the peak.
Round 2's net-demand measurement said our peak bin asks for 1.85x the reference's demand on
30/30 designs. The remaining candidate was therefore the placement objective itself, and it
turns out to be already implemented and switched off.

WAWirelengthGradient, the default wirelength model, carries a family of congestion-aware net
treatments selected by a congestion effort level whose default is 1, hard-coded in
NesterovPlaceConfig.hh and never read from JSON. Level 1 is described in the code as leaving the
evaluator-visible peak bin mostly untouched. Levels 2 and 3 amplify the wirelength gradient of
nets whose bounding box crosses an over-congested bin, with the stated purpose of shrinking
exactly those net bounding boxes and attacking the peak. Level 4 uses the verify evaluator's own
demand model - no Gaussian blur, union max - so that the placement optimises the same numbers
the evaluation reports.

Separately, the congestion flag gates a larger change: once density overflow drops below 0.75,
global placement switches its wirelength force to a congestion-driven one computed from a
per-bin route demand evaluation, which at level 4 is aligned with the evaluator.

At one seed (1000) these looked like the best results of the campaign:

| design | baseline | level 2 | level 4 |
|---|---|---|---|
| gcd_sky130_a | 8,595,054 / 2,526 / 32 | 6,994,833 / 834 / 18 | 6,980,365 / 847 / 22 |
| s1238_sky130_a | 7,499,276 / 3,840 / 66 | 7,429,760 / 3,799 / 52 | 7,149,948 / 3,093 / 40 |

## 3. The seed spread is larger than the effects being sought

The goal's method requirement says a measurement must exceed the noise floor, quoting a median
HPWL spread of 0.86% and p90 4.33%, and congestion 5.92% / 26.05%. Measured directly here, on
the same binary and the same configuration, the spread on individual designs is far larger:

| design | HPWL spread | union spread | peak spread | peak values observed |
|---|---|---|---|---|
| gcd_sky130_a | 12.3% | 78.9% | **66.7%** | 16, 32 |
| gcd_ics55_a | 0.3% | 8.3% | **50.0%** | 6, 12 |
| s1238_sky130_a | 1.6% | 4.0% | **31.1%** | 38, 52 |
| gcd_nangate45_a | 0.0% | - | 0% | 0, 0 |

The baseline configuration alone moves our EGR max by up to two thirds across seeds. Every
per-design peak-congestion claim in this campaign, including Round 3's, was made from a single
seed, so all of them are within this spread.

## 4. Retraction: Round 3's density-ramp result does not reproduce

Round 3 reported that lowering the density-penalty ceiling (max_phi_coef 1.05 to 1.02) improved
wirelength on 11 of 12 matched designs, with EGR max better by 50% and 31% on the two designs
with the worst peaks. That was seed 1000.

At seeds 1001 and 1002, same binary, same configuration, paired so that the seed is held fixed
between the arms:

| arm | metric | median paired ratio | better | worse |
|---|---|---|---|---|
| phi102 | HPWL | **1.260** | **0 / 8** | **8 / 8** |
| | union | **9.237** | 0 / 7 | 7 / 7 |
| | EGR max | **3.055** | **0 / 7** | **7 / 7** |

Raw values for s1238_sky130_a, HPWL / union / peak:

| arm | seed 1000 | seed 1001 | seed 1002 |
|---|---|---|---|
| baseline | 7,225,417 / 3,594 / 52 | 7,232,365 / 3,301 / 38 | 7,118,190 / 3,435 / 52 |
| **phi102** | **6,243,023 / 1,761 / 36** | **8,870,843 / 5,438 / 66** | **9,232,702 / 5,820 / 68** |

So the change is a large win at seed 1000 and a large loss at the next two seeds, while the
baseline is comparatively stable. Lowering the ramp ceiling does not make the solver better; it
makes it **less robust**, and the seed-1000 run happened to land well. The Round 3 headline is
retracted. The mechanism reading may still be right about what the constant does, but there is
no improvement to attribute to it.

## 5. This round's own candidates are not wins either

Same paired treatment, same binary, levels 2 and 4 against the default:

| arm | metric | median paired ratio | better | worse |
|---|---|---|---|---|
| level 2 | HPWL | 1.010 | 2 / 12 | 10 / 12 |
| | union | 1.107 | 2 / 11 | 9 / 11 |
| | EGR max | 1.065 | 3 / 11 | 8 / 11 |

Level 2 is much less harmful than phi102 but it is not an improvement. The one coherent pattern
is conditional: it helps where the baseline is congested and is neutral-to-harmful where the
baseline is already clean. On gcd_sky130_a, where the baseline itself ranged over 16 and 32
overflowing bins across seeds, level 2 gave 18 and 23 - better than the baseline's bad draw,
worse than its good one. That is the behaviour of a repair, not of an optimiser, and it means
the metric to report is a distribution, not a point.

## 6. Two individually-positive changes combine into a worse result

Tested deliberately, single seed, levels 2/4 combined with the lowered ceiling:

| design | dHPWL L2 | dHPWL L2+phi | dMAX L2 | dMAX L2+phi |
|---|---|---|---|---|
| gcd_nangate45_a | +14.2% | +15.0% | - | - |
| salsa20_ics55_a | +142.0% | - | +246.5% | - |
| s38584_nangate45_a | +91.0% | +125.5% | +2100% | +2625% |
| s38584_ics55_a | +100.0% | +167.7% | +245.8% | +362.5% |

Combining them is worse than either alone, often dramatically. Two changes that each look
mildly positive at one seed interfere destructively, which is further evidence that what is
being measured at one seed is trajectory luck rather than a controlled effect.

## 7. What this means for the campaign

**Every quantitative claim in Rounds 1-4 was made from a single seed and is therefore
provisional.** That includes the standing comparison against the reference: the corrected
baseline paired our placement against the reference using one seed each, so counts like "EGR max
no worse on 5 of 32" carry our own seed uncertainty, which the table above shows is up to 67% on
the peak for a single design.

The qualitative results survive because they did not depend on small margins: the level-fidelity
findings (pre-LG HPWL against legalised HPWL at rho -0.891, selection regret +19.7% HPWL and
+124.7% congestion), the replay and live dynamics results, the net-demand systematic (1.85x on
30 of 30 designs, which no seed choice can reverse), and the mechanism findings. The single-seed
standing numbers and the Round 3 improvement do not survive.

## 8. What I should have done earlier

The seed-repeat experiment is cheap - 72 runs, comparable to a single 32-design sweep - and it
should have preceded the second source change, not the fifth. The goal's method requirement
named the noise floor explicitly and required repeat seeds for claims below it; Round 3's
headline was claimed at 13-50% on a metric whose single-design seed spread is 31-67%, and I
should have seen that the 50% and 31% figures were not distinguishable from a good draw. The
cost of the omission is four rounds of build and measurement effort spent on candidates that do
not hold up.

## 9. Where this leaves the objective

Unmet, and now known to be harder to demonstrate than the goal text assumes. The honest next
step is not another source change: it is to re-establish the comparison against the reference
with repeated seeds on both sides, so that "we are worse at the peak" is a measured distribution
rather than a point estimate. If the gap does not survive that, the premise of the goal changes;
if it does, its size will determine whether it is attackable at all.

Two candidate source directions remain untested at the required number of seeds: the
congestion-aware net treatment (levels 2-4, which does look like a repair that helps exactly
where congestion is bad) and the net-weighting / objective direction from Round 2. Both should
be evaluated with seeds first and a source change only after.
