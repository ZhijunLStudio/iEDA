# Round 3: the density-penalty ramp is the lever, and the congestion path is gated behind it

## 1. Outcome in one line

Found the first source-level lever that moves the objective, and found that iEDA's entire
congestion-aware global-placement path is currently unreachable because of it. It is not yet
a win on the goal metric across the board; the honest result is a wirelength gain on 11 of 12
matched designs plus a large peak-congestion gain on the two designs where the peak is worst.

## 2. The structural finding: a congestion-aware GP path exists and is switched off

placer_run_gp accepts -congestion_effort, documented in PLAPI.cc as:

| level | meaning |
|---|---|
| 0 | off |
| 5 | joint density-congestion targets |
| 6 | constraint-first: per-bin density multipliers, only violating bins hold pressure |
| 7 | **real iRT trial-route overflow feedback** |

The plain flow - the one the regression uses and the one every number in this campaign was
measured with - never passes the option, so it runs at 0. A routability-driven path that
feeds back from the actual router is already written and dormant.

## 3. The finding that connects everything: all three levels diverge at the default settings

Levels 5, 6 and 7 all abort with

    overflow and HPWL diverged

on s1238_sky130_a (and 6 on salsa20_sky130_a). The solver's own message names the cause:

    The reason may be max_phi_cof value: try to decrease max_phi_cof

Decreasing it to 1.02 makes all three levels run. So the congestion path is not merely
switched off; it is gated behind a parameter that makes it fail when switched on.

## 4. The mechanism, read out of the source

NesterovPlace.cc:

    line 1396-1399   obtainPhiCoef: ret_coef is bounded above by max_phi_coef
    line 1815        one-time decay: max_phi_coef *= 0.985 the first time overflow < 0.35
    line 1840        _density_penalty *= phi_coef

so max_phi_coef is the **ceiling on the per-iteration growth rate of the density penalty**.
The configured value is 1.05 in the design configs, and the one-time decay makes the
effective ceiling 1.05 * 0.985 = 1.03425. During the fine-placement phase, where the
wirelength trend is favourable every iteration, phi_coef sits at that ceiling, so the penalty
grows as 1.03425^N - about **29x over 100 iterations**. At 1.02 the effective ceiling is
1.005 and the penalty essentially plateaus.

A sweep on gcd_sky130_a (congestion off, so only this parameter moves):

| max_phi_coef | HPWL | EGR union | EGR max |
|---|---|---|---|
| 1.05 (default) | 8,595,054 | 2,526 | 32 |
| 1.03 | 6,952,594 | 899 | 24 |
| **1.02** | **6,910,861** | **717** | **16** |
| 1.01 | diverges | - | - |

There is an interior optimum with a stability floor below it: too steep and the fine phase
crushes wirelength, too shallow and the penalty cannot control overflow and the run diverges.

**This also explains Round 1.** There I tested min_phi_coef (the downward bound) and found it
was a byte-identical no-op. The lever is the upward bound. And it explains Round 2: the
clustering that GP produces is not what damages the final result, because lowering the ramp
*lowers* the clustering pressure yet *improves* the routing - which only makes sense if the
damage was being done by over-pushing density relative to wirelength.

## 5. The honest 12-design result

max_phi_coef 1.05 -> 1.02, congestion off, 12 matched designs, same evaluator:

| design | dHPWL | dUNION | dMAX | base max | new max |
|---|---|---|---|---|---|
| gcd_ics55_a | -0.3% | +18.9% | +66.7% | 3 | 5 |
| gcd_nangate45_a | +0.2% | - | - | 0 | 0 |
| **gcd_sky130_a** | **-19.6%** | **-71.6%** | **-50.0%** | 32 | **16** |
| s1238_ics55_a | -0.9% | +2.3% | 0.0% | 12 | 12 |
| s1238_nangate45_a | -0.9% | +200.0% | +150.0% | 2 | 5 |
| **s1238_sky130_a** | **-13.5%** | **-51.0%** | **-30.8%** | 52 | **36** |
| s38584_ics55_a | -0.2% | +6.1% | 0.0% | 24 | 24 |
| s38584_nangate45_a | -0.9% | +90.5% | +25.0% | 4 | 5 |
| s38584_sky130_a | -0.1% | +1.7% | +8.7% | 46 | 50 |
| salsa20_ics55_a | -2.2% | -17.5% | -34.8% | 46 | 30 |
| salsa20_nangate45_a | -1.9% | -21.3% | -14.3% | 14 | 12 |
| salsa20_sky130_a | -1.6% | -1.2% | +2.8% | 72 | 74 |

median dHPWL **-0.9%** (better on **11/12**), median dUNION **+1.7%** (better on 5/11),
median dMAX **0.0%** (better on 4/11, equal on 2).

**What this does and does not establish.**

It **does** establish: a real wirelength improvement, consistent in direction on 11 of 12
designs, and a large peak-congestion improvement on the two designs with by far the worst
peaks (-50% and -31%). Those two effects are far outside the noise floor.

It **does not** establish: a systematic reduction in EGR max. The median is 0.0% and it is
better on only 4 of 11. On designs whose peak is already near zero the count rises slightly
(2 -> 5, 4 -> 5, 3 -> 5) - small in absolute terms but the wrong direction, and it is why the
median sits at 0.

**Caveat on the median.** The HPWL median of -0.9% is at the measured noise floor (median
0.86%, p90 4.33%). The claim that survives is "consistent direction on 11/12 plus two
large effects", not "a 0.9% median improvement". Repeat seeds are needed before quoting the
median.

## 6. Two further results from this round

**The congestion levels add something, but not much, and level 7 is impractical.** Comparing
the variants on the designs measured with each:

| design | metric | base | phi 1.02 | ce5+phi | ce6+phi | ce7+phi |
|---|---|---|---|---|---|---|
| s1238_sky130_a | max | 52 | 32 | 38 | 34 | 34 |
| s1238_sky130_a | HPWL | 7,225,417 | 6,243,023 | 6,294,941 | 6,332,142 | **6,187,155** |
| s1238_nangate45_a | union | 4 | 2 | **1** | - | 2 |
| salsa20_sky130_a | HPWL | 846,419,365 | **832,515,006** | 846,881,163 | 850,928,768 | 836,811,851 |

The congestion levels help on some designs (s1238_nangate45 union 4 -> 1) and hurt on others
(salsa20_sky130_a HPWL is 1.6% better with the parameter change alone than with ce5 added).
**Level 7, the real trial-route feedback path, took over 19 minutes on one design where the
plain flow takes about 35 seconds.** It is not usable as a default, whatever its quality.

**A methodological error found and fixed: core range changed the results.** The same binary
and the same input script produced HPWL 8,185,835 under a 32-core taskset range and 8,595,054
under a 64-core range. The cause: **48 of the 50 "pragma omp parallel" regions in the tree do
not specify num_threads**, so they inherit the visible-core count, and the parallel reductions
then reorder floating-point additions. Two repeats at the same range are byte-identical, so
the code is deterministic given the thread count - but the thread count was an unrecorded
variable in every earlier comparison. rsi_lib.run_cmd now sets OMP_NUM_THREADS (default 1,
overridable with RSI_OMP_THREADS), which makes a run depend on the input and the binary only.

## 7. What I got wrong, again

I nearly credited this to the congestion-aware path. The control - congestion_effort set to 0,
only max_phi_coef changed - was run deliberately to test attribution, and it produced *better*
results than the congestion variants on gcd_sky130_a (HPWL 6,910,861 against 6,929,889, max
16 against 20). Without that control I would have written up "enabling iEDA's congestion-aware
placement improves congestion" and it would have been wrong; the congestion path contributes
little here and the parameter change is the whole effect.

## 8. Next round: make this an algorithm change, not a tuning change

Changing a configured constant from 1.05 to 1.02 is a tuning change, and this goal explicitly
says not to present configuration differences as algorithmic improvement. The algorithmic
statement beneath it is:

> the density-penalty ramp is driven by the wirelength trend (obtainPhiCoef) and not by the
> overflow state, so it keeps climbing through the fine-placement phase, where it is both
> unnecessary and harmful - LG and DP spread better than the late GP iterations do.

The change that follows from that statement, and which I will implement and measure next, is
to drive the ramp from the overflow state instead:

1. while overflow is above target, allow the penalty to grow at the measured-good rate;
2. once overflow reaches target - the point where the existing code applies its one-off
   decay anyway - stop growing it;
3. keep the existing divergence guard as the safety net.

That change should reproduce the measured effect without hand-setting a constant per design,
which is what makes it a defensible algorithm change rather than a tuned value. It also has
to be shown not to break the three designs whose peak is near zero, which is where the
current parameter change is weakest.

## 9. Costs

- Incremental rebuild: 17 s (five-file change) and 8 s (one-file change).
- Global placement with the congestion levels at the default phi: aborts on s1238_sky130_a
  and salsa20_sky130_a; runs with 1.02.
- Level 7: over 19 minutes on one design against about 35 s for the plain flow.

---

## RETRACTION (added in Round 5)

The headline result of this round does not reproduce, and is withdrawn.

Everything above was measured at a single seed. Repeated at seeds 1001 and 1002, paired so the
seed is held fixed between the arms, the change is worse on every metric and every design:

| metric | median paired ratio | better | worse |
|---|---|---|---|
| HPWL | 1.260 | 0 / 8 | 8 / 8 |
| EGR union | 9.237 | 0 / 7 | 7 / 7 |
| EGR max | 3.055 | 0 / 7 | 7 / 7 |

On s1238_sky130_a the change gives 6,243,023 / 1,761 / 36 at seed 1000 and 8,870,843 / 5,438 /
66 and 9,232,702 / 5,820 / 68 at seeds 1001 and 1002, while the baseline stays near 7,200,000 /
3,400 / 45 across all three. The change makes the solver less robust rather than better, and
seed 1000 was a favourable draw.

The mechanism reading in sections 4 and 5 - what max_phi_coef does to the penalty ramp - is not
withdrawn: it is a description of the code. What is withdrawn is the claim that lowering it
improves the result. See ROUND-5-seed-robustness.md.
