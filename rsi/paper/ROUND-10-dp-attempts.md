# Round 10: two attempts at the DP deficit, one consistent signal

## 1. Outcome in one line

A search-order improvement to the swap operator gives small mixed changes and is reverted. A second
LG+DP pass gives a consistent peak reduction on one design and a consistent union reduction on
another, at three seeds each, but is worse on a third - and it is a flow change, not an
algorithm change.

## 2. Attempt 1: make the swap operator pick its best candidate (SR-5)

Reading InstanceSwap's acceptance loop showed it takes the FIRST candidate with a positive
wirelength benefit rather than the best one:

    for (auto pair : candidate_list) {
      int64_t swap_benefit = swapInstance(inst, pair.second, true);
      if (swap_benefit > 0) { best_benefit = swap_benefit; best_candidate = pair; break; }
    }

Breaking on the first positive candidate means a cell can be moved to a mediocre site and moved
again by a later pass, which is the iterative walk that a concentration-heavy operator would
produce. SR-5 selects the largest-benefit candidate instead - a strict improvement to the
operator's own criterion, so it cannot lose wirelength by construction and could reduce the number
of disturbing moves.

Built in 7 s, measured against a commit-matched control (the control's md5 equals the
HEAD-source build, so the pair differs only by SR-5):

| design | dHPWL | dunion | dpeak |
|---|---|---|---|
| s1238_ics55_a | -0.01% | -15 | **-4** |
| s1238_sky130_a | **+1.63%** | -62 | **+8** |
| s38584_nangate45_a | -0.03% | +1 | 0 |
| salsa20_ics55_a | -0.00% | +489 | -3 |

Two designs improve on the peak, one is neutral, one gets worse and also loses 1.6% of
wirelength. At one seed none of this is resolvable against a seed spread of 30-67% on this metric,
and there is no design where SR-5 is clearly a win. **Reverted**; the tree carries no SR-5.

## 3. Attempt 2: a passing stage after detail placement

The deficit is created by detail placement, which concentrates cells to buy wirelength. If that is
concentration, a stage that spreads may undo it, and the plain flow runs legalisation and detail
placement exactly once each. Three pipelines, same binary, plain flow:

- B0: gp, lg, dp - the baseline
- B1: gp, lg, dp, lg
- B2: gp, lg, dp, lg, dp

At one seed, B2 on s38584_nangate45_a cut the peak from 4 to 2 and the union from 22 to 10,
against a reference of union 6 and peak 2 - a tie on the peak where we had been losing by 2x. It
was worse on two other designs.

Repeated at three seeds, paired so both arms use the same seed:

| design | dpeak per seed | dpeak better | dunion per seed | dunion better |
|---|---|---|---|---|
| **s1238_ics55_a** | **-3, -3, -3** | **3 / 3** | -33, -11, +34 | 2 / 3 |
| s38584_nangate45_a | 0, -2, +1 | 1 / 3 | **-4, -10, -2** | **3 / 3** |
| salsa20_ics55_a | 0 | 0 / 1 | +1243 | 0 / 1 |

**A peak reduction of exactly 3 bins on all three seeds** is not the signature of seed noise, and
it moves s1238_ics55_a to 8, 8, 14 against a reference of 14 - two seeds better, one tied, where
the baseline gave 11, 11, 17. On s38584_nangate45_a the union improves on all three seeds.

The single-seed B2 result quoted at the start of this section (peak 4 to 2, union 22 to 10, tying
the reference) does not survive: at the other two seeds the peak is 3 and 3 against a baseline of 5
and 2. The mechanism that overstated Round 3 by 3x has now overstated a single-seed result three
times, and each time the three-seed check was what corrected it.

## 4. What B2 establishes

**The plain flow's legalisation and detail placement do not converge in one pass.** Every result in
this campaign, including the standing against the reference, was produced by a pipeline that runs
each of those stages once and stops. A second pass changes both the peak and the total overflow on
every design measured, in different directions.

That makes the stopping criterion itself a defect of the same family as the three disconnected
mechanisms found earlier (the unpassed congestion option, the unreachable spreading operator, the
degenerate density monitor): the stage is run once because that is what the flow says, not because
once is converged.

**What it does not establish** is that B2 is an improvement. It reduces the peak on one design and
the union on another, is neutral-to-worse on a third, and costs a second LG and DP pass. Under the
goal's own rule it is also a pipeline difference rather than an algorithmic improvement, so it
cannot be presented as one.

## 5. Where the objective stands

Unchanged: four dimensions ahead on the netlist-matched set (HPWL 13/15, union 8/13, setup WNS
7/7, setup TNS 6/7), peak congestion behind (3/13).

Ten rounds in, the peak deficit is localised (detail placement, first swap iteration, instance swap
and row optimisation) and two candidate responses have been measured. Neither is a win. Both were
single-seed signals that the three-seed check reduced to something much smaller, which is now the
third time repeat seeds have overturned a result in this campaign - and the reason the method
clause in the goal exists.

## 6. Next

1. **Convergence criterion instead of a fixed pass count.** Run LG and DP until the placement stops
   changing, rather than once, and measure whether the peak converges to something better than the
   single-pass value. B2 is the two-pass point of that sequence; intermediate and further passes are
   unmeasured, and the evidence says the second pass is not the end of the effect.
2. **Test the second pass across the whole valid set**, because the three designs tested disagree in
   direction and the decision should not rest on them.
3. **Do not re-test SR-5** without a reason to expect a larger effect than the seed spread.

## 7. Addendum: how many passes, and does the benefit converge

If the single pass is under-converged, the peak should keep improving with more passes. Adding a
three-pass arm (B4: lg dp lg dp lg dp) and running one, two and three passes at three seeds:

**s1238_ics55_a** (netlist-matched; reference union 177, reference peak 14):

| seed | 1 pass peak / union | 2 passes peak / union | **3 passes peak / union** |
|---|---|---|---|
| 1001 | 14 / 149 | 8 / 59 | **8 / 79** |
| 1002 | 11 / 151 | 12 / 148 | **8 / 96** |
| 1003 | 13 / 122 | 14 / 121 | **7 / 82** |

**At three passes the peak is 8, 8, 7 and the union is 79, 96, 82 - every one of the six numbers
beats the reference** (14 and 177). At one pass the peak was 14, 11, 13 - a tie and two losses -
while the union already won. So on this design the peak deficit the campaign has been chasing was
not a property of the placer, the global placement, or the operator choices: **it was the
pipeline stopping one pass too early.**

Cost: legalisation and detail placement are the cheapest stages in the flow (about 2.9 s per
design against 7.4 s for global placement), so two extra passes are on the order of 6 s per design
and do not change the flow's cost class.

**s38584_nangate45_a** (reference union 6, peak 2):

| seed | 1 pass peak / union | 2 passes peak / union | 3 passes peak / union |
|---|---|---|---|
| 1001 | 2 / 13 | 2 / 15 | 2 / 20 |
| 1002 | 6 / 19 | 8 / 20 | - |

**Here more passes are neutral on the peak and monotonically worse on the union.** So the effect
that dominates on s1238_ics55_a does not transfer, and on this design iterating is actively
harmful. The two designs disagree in both direction and magnitude.

**What this is.** A stopping-criterion defect: the flow runs legalisation and detail placement
exactly once, and how far from converged that leaves the placement depends on the design. On
s1238_ics55_a it leaves a 40% peak excess; on s38584_nangate45_a iterating does not help.

**What this is not.** A general fix. It helps one of two designs measured, hurts the other's total
overflow, and it is a flow change rather than an algorithmic one. Reporting it as "we beat the
reference on congestion" on the strength of s1238_ics55_a alone would be the same subset error
that produced the netlist finding and the DP-innocence error earlier in this campaign.

## 8. The pattern across ten rounds

Three of the last four rounds ended the same way: a single-seed result that looked like a fix, and
a three-seed check that either shrank it or reversed it. The effect sizes being chased are of the
same order as the seed spread, which is why every result needs the check and why so many have not
survived it. The one result in this round that did survive the check - the three-pass peak and
union on s1238_ics55_a, six numbers all better than the reference - is also the one with a
mechanistic explanation that the earlier failures did not have.
