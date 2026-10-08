# Round 9: which detail-placement operator creates the deficit

## 1. Outcome in one line

The deficit is created in detailed placement's FIRST swap iteration, and ablating the operators
identifies instance swap (and row optimisation) as the actors - but at three seeds the effect is
design-dependent and is not a fix.

## 2. Why the machinery approach was abandoned

Round 8 ended with the plan "wire a working demand metric into DP, then guard with it". That was
attempted as SR-4: the existing density monitor (calPeakBinDensity) was called with the grid
populated first, which was the defect in SR-3.

It still returns 1. GridManager::obtainPeakGridDensity takes the max of each bin's density, and
after DPOperator::updateGridManager populates occupied_area the result is still exactly 1 for
every bin - the grid metadata the density is normalised against is not set up on this path.
Rather than continue in the plumbing, the guard approach was dropped and the operator
ablation below was used instead, because it identifies the culprit with no new code at all.

## 3. The damage is in the first swap iteration

The swap loop runs up to ten iterations. Capping it at 1, 2, 3 and 5 iterations, against an
otherwise identical control binary:

| design | cap 10 (control) | cap 1 | cap 2 | cap 3 | cap 5 |
|---|---|---|---|---|---|
| s1238_ics55_a | union 130, peak 12 | identical | identical | identical | identical |
| s38584_nangate45_a | union 21, peak 4 | identical | identical | identical | identical |
| salsa20_ics55_a | union 42439, peak 46 | identical | peak 43 | identical | - |

**Capping the iteration count changes nothing on two of three designs**, so the damage is not
accumulated over iterations - it is done by the first one, and on two designs the loop already
converges after it. That rules out "run DP for less long" as the lever and points at the
operators inside that first iteration: global swap, vertical swap, local reorder, row
optimisation.

## 4. Operator ablation, one seed

All four operators can be switched off through PL.DP, so this needs no source change. Seed 1000:

| design | arm | HPWL | union | peak | peak vs reference |
|---|---|---|---|---|---|
| **s38584_nangate45_a** | base | 135,613,312 | 21 | 4 | +2.00x |
| | **no_swap** | 137,153,892 (+1.1%) | **6** | **1** | **+0.50x** |
| | no_reorder | 135,613,312 | 21 | 4 | +2.00x |
| | **no_rowopt** | 138,986,765 (+2.5%) | **3** | **1** | **+0.50x** |
| s1238_ics55_a | base | 3,230,485 | 130 | 12 | +0.86x |
| | no_swap | 3,291,725 | 109 | 10 | +0.71x |
| | no_reorder | 3,230,485 | 130 | 12 | +0.86x |
| | no_rowopt | 3,371,591 | 80 | 6 | +0.43x |
| salsa20_ics55_a | base | 280,575,674 | 42,439 | 46 | +1.35x |
| | no_swap | 283,388,377 | 43,253 | 36 | +1.06x |
| | no_reorder | 280,548,672 | 41,966 | 43 | +1.26x |
| | no_rowopt | 285,697,488 | 42,650 | 34 | +1.00x |
| s1238_sky130_a | base | 7,499,276 | 3,840 | 66 | +2.06x |
| | **no_swap** | **11,328,447 (+51%)** | 7,810 | 88 | +2.75x |
| | no_reorder | 7,282,756 | 3,659 | 62 | +1.94x |
| | **no_rowopt** | **12,510,685 (+67%)** | 8,130 | 66 | +2.06x |

Three things stand out. Local reorder is inert - disabling it changes nothing on two designs and
almost nothing on the third. Instance swap and row optimisation are the actors. And on
s1238_sky130_a, the one design where detailed placement earns 40% of its wirelength, disabling
either is catastrophic, doubling the total overflow.

## 5. The same ablation at three seeds, paired

Seed 1000 alone would have supported a strong claim. Repeating on the same seeds for both arms:

| design | union ratio (median) | seeds better | median change in peak | median dHPWL |
|---|---|---|---|---|
| s38584_nangate45_a | **0.769** | **3 / 3** | **-1.0** | +1.22% |
| s1238_ics55_a | 0.911 | 1 / 2 | -1.5 | +2.31% |
| **salsa20_ics55_a** | **1.029** | **0 / 3** | **+9.0** | +1.16% |

Per seed, s38584_nangate45_a: union 13 to 10, 19 to 15, 16 to 9; peak 2 to 2, 6 to 5, 3 to 2.
salsa20_ics55_a: union 40,538 to 40,610, 38,245 to 41,416, and peak 34 to 43, 29 to 38, then one
seed better.

**Disabling instance swap consistently reduces our congestion deficit on s38584_nangate45_a and
consistently worsens it on salsa20_ics55_a.** The direction depends on the design.

It also does not reverse the deficit even where it helps: at the three seeds, s38584_nangate45_a
goes from union 13/19/16 to 10/15/9 against a reference of 6, and from peak 2/6/3 to 2/5/2 against
a reference of 2. The seed-1000 figures in section 4 - union 21 to 6, peak 4 to 1, which tie and
beat the reference - were a favourable draw, and quoting them as the effect would have overstated
it by the same mechanism that invalidated Round 3.

## 6. What this round establishes and what it does not

**Establishes**: the peak deficit is created inside detailed placement, in its first swap
iteration; local reorder is not responsible; instance swap and row optimisation are; and the two
operators are essential on s1238_sky130_a, where disabling either doubles total overflow.

**Does not establish**: a fix. Disabling the operator is not one - it is a config change, it goes
the wrong way on one of three designs, and it is catastrophic on a fourth. It is also not an
algorithmic improvement under the goal's own rule about configuration differences.

**A negative that matters**: this is the second time a single-seed result overstated an effect by
roughly a factor of three (Round 3 was the first). Both would have been caught by the same
three-seed check the goal's method clause requires, and in this case the check was run before
the claim rather than after.

## 7. Where the objective stands

Unchanged: four dimensions ahead on the netlist-matched set (HPWL 13/15, union 8/13, setup WNS
7/7, setup TNS 6/7), peak congestion behind (3/13).

Nine rounds in, the peak has been localised to two operators in one stage, and every attempted
fix has failed for one of two reasons: the signal it needed was not available (the density
monitor returns a constant; the route-demand grid is populated only in the global-placement
path), or the effect was a single-seed artefact. The remaining honest options are:

1. **Make instance swap demand-aware rather than binary.** The ablation shows the operator helps
   some designs and hurts others; a rule that accepts a swap only when it does not increase the
   demand through the affected bins would keep s1238_sky130_a's 40% and drop the damage elsewhere.
   This needs a per-swap demand evaluation, which is the plumbing that has repeatedly failed.
2. **Weaken the operator instead of removing it** - bound its displacement, or restrict it to nets
   whose bounding box is local - which needs no new metric and is testable now.
3. **Accept the measured trade explicitly**: run DP only when its wirelength gain exceeds a
   threshold, since the gain is what distinguishes s1238_sky130_a (40%) from the designs where it
   costs 1-2% and damages the peak. The flow already records DP's before-and-after HPWL.
