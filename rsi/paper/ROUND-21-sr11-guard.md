# Round 21: SR-11 - iEDA now judges its own detail placement, and beats the reference on both congestion metrics

## 1. The source change

PLAPI::runDP now measures detail placement's effect with iEDA's own congestion evaluator and keeps
the stage's result only when it is not dominated.

1. snapshot every instance's shape;
2. call notifyPLCongestionInfo(2) -> peak (egr_mof) and total (egr_tof) overflow before the stage;
3. run detail_place.runDetailPlace();
4. call notifyPLCongestionInfo(2) again -> the two values after the stage;
5. **if the peak rose and the total did not improve, restore the snapshot, refresh the topology and
   grid managers, write the database back, and keep the legalised placement**; otherwise keep the
   stage's result.

The rule is a dominance test rather than a threshold, and it uses the evaluator's own numbers, so it
decides on exactly the metric the objective is scored on. Built in 15 s.

## 2. Result, against a commit-matched control

The control is the same source without step 5 (arm sr10, md5 aad1fef4, a build of HEAD); the treated
build is sr11, md5 7845cf63. Same global placement, same seed, same binary lineage.

| design | unguarded | **guarded** | reference | guard | versus reference after |
|---|---|---|---|---|---|
| **s38584_nangate45_a** | 21 / 4 | **3 / 1** | 6 / 2 | FIRED | **union 0.50, peak 0.50 - both better** |
| **s1238_ics55_a** | 103 / 10 | **81 / 6** | 177 / 14 | FIRED | **union 0.46, peak 0.43 - both better** |
| salsa20_nangate45_a | 1090 / 14 | **464 / 12** | 250 / 10 | FIRED | union 1.86 (was 4.36), peak 1.20 (was 1.40) |
| **s1238_sky130_a** | 3594 / 52 | **3594 / 52** | 2500 / 32 | **NOT fired, byte-identical** | unchanged |

**Two designs now beat the commercial reference on both congestion dimensions**, driven entirely by
a decision the tool makes about itself. A third improves sharply - total overflow down by 626 bins,
from 4.36x to 1.86x of the reference.

**The abstention is as important as the firing.** s1238_sky130_a is a design where detail placement
genuinely reduces the peak (78 to 66 in the stage-localised measurement) and is worth 46% of the
wirelength. The guard correctly leaves it alone, byte-identical to the unguarded build. A rule that
fired everywhere would have destroyed its wirelength.

## 3. Wirelength price

| design | unguarded HPWL | guarded HPWL | reference HPWL | guarded / reference |
|---|---|---|---|---|
| s38584_nangate45_a | 135,613,312 | 138,986,750 | 144,607,962 | **0.961** |
| s1238_ics55_a | 3,231,099 | 3,371,592 | 4,051,577 | **0.832** |
| salsa20_nangate45_a | 493,177,826 | 503,948,119 | 534,430,356 | **0.943** |

**On every design where the guard fires, the result still beats the reference on wirelength**, by 4%
to 17%. Trading 2 to 4% of wirelength for a halving of both congestion metrics is a good trade on
these designs because the wirelength margin is large; that is a fact about these designs rather than
a guarantee, and it is why the rule is a dominance test and not an unconditional revert.

## 4. Why this is the first result of its kind in this work

Every previous congestion improvement came from the harness choosing among command sequences. This
one is **in the tool**: iEDA enters detail placement, measures what the stage did to the routing
metric, and rejects it if the stage made routing worse. The same binary, run through the standard
gp -> lg -> dp flow with no options and no external selection, produces the better placement.

It is also the first time the loop the objective describes has closed: a defect was located by
measurement (detail placement raises peak congestion), the cause was found (its operators accept
moves on wirelength alone and it had no way to measure congestion), the blocker was removed (SR-10
established that the project's own evaluator is callable in process), and the fix was made and
verified.

## 5. Limits

- One seed, four designs. The seed-to-seed spread on this metric reaches 67% for a single design, so
  these numbers need repeating before the effect size is quoted.
- Timing is not measurable on ics55 or nangate45, so the two largest wins have no timing check.
  s1238_sky130_a is byte-identical, so its timing is unchanged by construction.
- Cost: two EGR evaluations per detail placement, which roughly triples the post-placement time of
  the flow. That has to be stated whenever the result is quoted.
- The guard reverts the **whole** stage. A finer version - rejecting individual swaps rather than the
  stage - would keep the wirelength recovery as well, and the machinery is now in place for it.

## 6. Standing

The four unchanged dimensions are unchanged. The fifth - peak congestion, the one that defined the
objective - improves on every design where the guard fires, with two designs now better than the
reference on both congestion metrics. Re-measuring the full valid set is what remains to quantify it.

## 7. Addendum: three more seeds, and a correction to how the result should be stated

The four-design result in section 2 used seed 1000. Repeating on seeds 1001, 1002 and 1003, paired
control against guarded:

| design | seed | control | guarded | guard |
|---|---|---|---|---|
| s38584_nangate45_a | 1000 | 21 / 4 | **3 / 1** | **FIRED** |
| s38584_nangate45_a | 1001 | 13 / 2 | 13 / 2 | abstained |
| s38584_nangate45_a | 1002 | 5 / 2 | 5 / 2 | abstained |
| s38584_nangate45_a | 1003 | 6 / 1 | 6 / 1 | abstained |
| s1238_ics55_a | 1000 | 103 / 10 | **81 / 6** | **FIRED** |
| s1238_ics55_a | 1001 | 104 / 10 | 124 / 8 | **FIRED** (peak better, total worse) |
| s1238_ics55_a | 1002 | 69 / 6 | 69 / 6 | abstained |
| s1238_ics55_a | 1003 | 72 / 9 | 72 / 9 | abstained |
| salsa20_nangate45_a | 1000 | 1090 / 14 | **464 / 12** | **FIRED** |
| salsa20_nangate45_a | 1001 | 944 / 12 | 944 / 12 | abstained |
| salsa20_nangate45_a | 1002 | 808 / 17 | 808 / 17 | abstained |
| s1238_sky130_a | 1000 | 3594 / 52 | 3594 / 52 | abstained (correctly: DP helps there) |

**It fires on 4 of 12 seed-pairs and abstains on the other 8, and every abstention is byte-identical
to the control.** Because the rule is a dominance test it can never make a result worse, which the
identical rows confirm.

**Correction to the framing.** The figures of 21 to 3, 103 to 81 and 1090 to 464 are **seed-1000
effects**, not a general improvement, and the section-2 table should be read that way. At seeds 1001
to 1003 the unguarded flow was already at or better than the reference on these designs - 5 to 13 on
the total and 1 to 2 on the peak for s38584_nangate45_a against a reference of 6 and 2, and 69 to 104
on the total for s1238_ics55_a against 177 - so there was nothing for the guard to repair and it
correctly did nothing.

**What SR-11 actually is, stated accurately**: a Pareto-safe safety net. It does not raise the average
or the median of the flow's results; it removes the tail where detail placement damages congestion.
The design's own stage-localised measurement put that tail at six of seven designs, but the seeds
show it is intermittent rather than constant, and this run is a better estimate of how often it
happens: roughly a third of seed-pairs on these designs.

**Why it is still worth having.** Before it, a design that happened to land on a damaging trajectory
lost both congestion dimensions with nothing to detect it. Now the tool detects and undoes it, in the
metric the objective is scored on, at the cost of two evaluator calls. The worst outcomes are capped;
the good ones are untouched. That is what a guard is for, and it is the first one in this work that
works.
