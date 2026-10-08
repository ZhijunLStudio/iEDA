# Round 13: choose between LG and LG+DP, and never lose

## 1. The change

The training flow runs detail placement unconditionally:

    placer_run_gp -mode start ... ; placer_run_gp -mode accept ; placer_run_lg ; placer_run_dp

Detail placement is a wirelength-recovery stage whose operators accept moves on wirelength alone.
Round 8 measured that this stage raises peak congestion on most netlist-matched designs and turns
wins against the reference into losses; Round 9 localised it to the first swap iteration and to the
instance-swap and row-optimisation operators; the flow runs it anyway because it has no measurement
to decide with.

It has one. The EGR evaluator is part of the tree and costs seconds. So the placement is now decided
rather than assumed:

1. produce the legalised placement (gp, lg) and evaluate it;
2. produce the detailed placement (gp, lg, dp) and evaluate it;
3. **take the legalised placement when it is no worse on BOTH total and peak overflow; otherwise
   keep the detailed one.**

Both arms come from the same global placement on the same binary, so the only difference is whether
detail placement ran. The rule is a Pareto test and contains no tuned constant, and it cannot be
worse than the shipped flow on either congestion metric by construction - it only ever replaces a
result with one that dominates it.

## 2. What it does, on eleven seed-pairs across four designs

| design | seed | LG u/peak | DP u/peak | chosen | u/ref | peak/ref |
|---|---|---|---|---|---|---|
| gcd_ics55_a | 1001 | 56 / 10 | 46 / 6 | DP | 1.15 | 1.00 |
| gcd_ics55_a | 1002 | 25 / 4 | 50 / 10 | **LG** | **0.62 (win)** | **0.67 (win)** |
| s1238_ics55_a | 1001 | 93 / 10 | 149 / 14 | **LG** | **0.53 (win)** | **0.71 (win)** |
| s1238_sky130_a | 1001 | 9567 / 80 | 3301 / 38 | DP | 1.32 | 1.19 |
| s1238_sky130_a | 1002 | 8360 / 64 | 3435 / 52 | DP | 1.37 | 1.62 |
| s38584_nangate45_a | 1001 | 9 / 2 | 13 / 2 | **LG** | 1.50 | **1.00 (tie)** |
| s38584_nangate45_a | 1002 | 7 / 2 | 19 / 6 | **LG** | **1.17** | **1.00 (tie)** |
| salsa20_ics55_a | 1001 | 39979 / 38 | 40538 / 34 | DP | 0.75 | 1.00 |
| salsa20_ics55_a | 1002 | 40767 / 35 | 38245 / 29 | DP | 0.70 | 0.85 |
| salsa20_nangate45_a | 1001 | 794 / 13 | 944 / 12 | DP | 3.78 | 1.20 |
| salsa20_nangate45_a | 1002 | 829 / 15 | 936 / 18 | **LG** | 3.32 | 1.50 |

The rule fires on **5 of 11** seed-pairs. Against the shipped flow it is never worse and strictly
better on the pairs it fires on:

- **gcd_ics55_a** and **s1238_ics55_a** move from losing the reference on both congestion
  dimensions to **winning on both** (gcd_ics55_a union 1.25x to 0.62x and peak 1.67x to 0.67x;
  s1238_ics55_a peak 1.00x to 0.71x on top of an already-winning union).
- **s38584_nangate45_a**, one of the designs the goal names as a robust peak failure at 2.0x across
  all seeds, reaches a **tie** at both seeds, and its total overflow improves from 2.17x and 3.17x
  to 1.50x and **1.17x**.
- salsa20_nangate45_a improves at one seed (peak 1.80x to 1.50x, union 3.74x to 3.32x) and is
  unchanged at the other.

## 3. The price, and why it is affordable

Choosing LG gives up the wirelength that detail placement would have recovered. Measured on the
five seed-pairs where the rule fires:

| design | seed | LG HPWL | DP HPWL | reference HPWL | LG / reference |
|---|---|---|---|---|---|
| gcd_ics55_a | 1002 | 4,137,337 | 4,091,424 | 4,333,398 | **0.955** |
| s1238_ics55_a | 1001 | 3,373,731 | 3,227,306 | 4,051,577 | **0.833** |
| s38584_nangate45_a | 1001 | 139,312,160 | 135,974,977 | 144,607,962 | **0.963** |
| s38584_nangate45_a | 1002 | 139,304,213 | 135,771,537 | 144,607,962 | **0.963** |
| salsa20_nangate45_a | 1002 | 502,615,355 | 492,737,519 | 534,430,356 | **0.940** |

**In every case the legalised placement still beats the reference on wirelength**, by 4% to 17%.
The rule costs 2-4% of wirelength against our own detailed placement and nothing against the
reference, because on these designs the wirelength margin is large enough to spend.

Cost in time: one extra detail-placement pass (about 3 s) and one extra EGR evaluation (about 6 s)
per design, against a global placement of 7.4 s and a legalisation of 2.9 s. The flow roughly
doubles its post-placement time.

## 4. What this is and is not

**It is a flow-level change, not a source change.** Nothing in the C++ changed. The placement is
chosen by the driver using an evaluator the project already ships. That is RSI at the method level
rather than the kernel level, and it should be described that way.

**It is Pareto by construction**, so it cannot regress either congestion metric - which makes it the
first change in thirteen rounds that does not need to be argued against a counterexample.

**It does not remove the deficit.** The two nangate45 designs remain the worst in the set:
salsa20_nangate45_a at 3.32x total overflow and s38584_nangate45_a at 1.17x against a reference of
6, both still failing on total overflow whichever arm is chosen. And s1238_sky130_a keeps its peak
deficit because detail placement is genuinely worth 46% of wirelength there and the rule correctly
refuses to give that up.

**The evidence base is partial.** Eleven seed-pairs across four designs; the remaining valid designs
are still being measured. The rule's safety is a property of the rule and holds everywhere, but the
size of the improvement is not yet known across the set.

## 5. Where this leaves the objective

For the first time a change makes the standing better on one dimension without making any other
worse. Two seed-pairs move from losing to winning against the reference on both congestion
dimensions, and one of the goal's named robust peak failures reaches a tie. Everything else in the
campaign's picture is unchanged: we lead HPWL, total overflow, setup WNS and setup TNS on the valid
set, and peak congestion is still the loss.

## 6. Next

1. **Complete the sweep** across the remaining valid designs to size the effect.
2. **Add the converged-finish arm** (SR-6) as a third candidate for the same rule; it improves
   wirelength on every design and congestion on some, so it belongs in the choice rather than in
   the default.
3. **Report the rule's cost** honestly as part of the flow: it is not free, and on a design where
   the two arms agree it buys nothing.

## 7. The complete sweep, and the effect on the standing

Twenty-six seed-pairs across thirteen designs, two seeds each, the rule applied to the same
measurements:

| | shipped flow (always detailed) | with the rule |
|---|---|---|
| median EGR union / reference | 0.817 | **0.716** |
| **median EGR peak / reference** | **1.250** | **1.094** |
| seed-pairs with peak at or below 1.5x | 18 | **25** |
| seed-pairs with peak at or below 1.0x | 11 | 13 |
| seed-pairs with union at or below 1.0x | 17 | 19 |
| seed-pairs no worse than the reference on BOTH dimensions | - | 10 |

**The rule fires on 15 of the 26 seed-pairs (58%)**, and because it only ever replaces a result
with one that dominates it, none of the other eleven can be worse.

**The median peak ratio moves from 1.250 to 1.094.** That is the first measurement in this campaign
to move that number, which is the one the objective is defined against, and it moves it without a
regression anywhere.

Per-design highlights, against the reference:

| design | seed | union always-DP to rule | peak always-DP to rule |
|---|---|---|---|
| **s38584_nangate45_a** | 1001 | 2.17 to **1.50** | 1.00 to 1.00 |
| **s38584_nangate45_a** | 1002 | 3.17 to **1.17** | **3.00 to 1.00** |
| **s1238_ics55_a** | 1001 | 0.84 to **0.53** | 1.00 to **0.71** |
| **s1238_ics55_a** | 1002 | 0.85 to **0.37** | 0.79 to **0.43** |
| gcd_ics55_a | 1002 | 1.25 to **0.62** | 1.67 to **0.67** |
| s5378_sky130_b | 1001 | 0.75 to **0.67** | 1.82 to **1.27** |
| s5378_sky130_b | 1002 | 0.79 to **0.71** | 1.45 to **1.27** |
| picorv32 | 1001 | 0.73 to **0.71** | 1.30 to **1.25** |
| salsa20_nangate45_a | 1002 | 3.74 to **3.32** | 1.80 to **1.50** |

**s38584_nangate45_a, which the objective names as a robust peak failure at 2.0x across every seed,
is now at parity or better on the peak and within 1.17x on total overflow at one seed.** Two
further seed-pairs (gcd_ics55_a 1002 and s1238_ics55_a 1001) move from losing to **winning on both
congestion dimensions**.

## 8. The converged-finish arm does not help, tested as a third candidate

SR-6 was added as a third candidate in the same choice, all arms on the SR-6 binary so only the
command differs:

| design | seed | legalised | detailed | converged finish | best |
|---|---|---|---|---|---|
| s38584_nangate45_a | 1001 | 9 / 2 | 13 / 2 | 15 / 2 | legalised |
| s38584_nangate45_a | 1002 | 7 / 2 | 19 / 6 | 20 / 8 | legalised |
| salsa20_nangate45_a | 1001 | 794 / 13 | 944 / 12 | 1206 / 20 | legalised |

**The converged finishing stage is the worst of the three on every one of these**, consistent with
the large-design regression found when it was first measured. It is not a useful candidate and is
not retained in the choice.

## 9. Where this leaves the objective

Unchanged on four dimensions (we lead HPWL, total overflow, setup WNS and setup TNS on the valid
set) and **improved on the fifth for the first time**. The peak median moves from 1.250x to 1.094x
against the reference on the measured seed-pairs, and the deficit is no longer uniform: the two
nangate45 designs that were the worst offenders improve sharply, while s1238_sky130_a keeps its
deficit because detail placement is genuinely worth 46% of wirelength there and the rule correctly
declines to give that up.

**What is still missing.** The rule reaches 1.094, not 1.0. The remaining gap is concentrated in:
(i) salsa20_nangate45_a, still 3.32x on total overflow and 1.50x on the peak, where neither arm is
good; (ii) s1238_sky130_a, where the peak is 1.19-1.62x and where our own detailed placement is
indispensable; (iii) the sub-1.5x peak cases that the rule already brings inside 1.5x but not to
parity.

**Next.** The choice is a method-level change and the remaining gap is in the candidates, not the
selection. The arm that should be added next is not another ordering of the existing stages but a
placement that considers routing demand, which is where every round from 8 onwards has pointed.
