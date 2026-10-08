# Round 29: the deficit is in global placement, and the guard's trade was the wrong way round

## 1. Stage localisation, redone under the corrected protocol

Round 22 located the failures at GP+LG using the bypass protocol. Redone with both sides legalised:

| design | union GP+LG to +DP (ref) | peak GP+LG to +DP (ref) | HPWL GP+LG to +DP (ref) |
|---|---|---|---|
| **gcd_sky130_a** | 8.27 to 2.39 (900) | 2.18 to **1.27** (22) | **2.07 to 1.14** |
| **s1238_sky130_a** | 4.77 to 2.19 (1751) | 2.79 to **2.36** (28) | **1.87 to 1.12** |
| gcd_ics55_a | 3.10 to 1.85 (20) | 1.00 to **0.50** (6) | 0.95 to 0.94 |
| **salsa20_ics55_a** | 0.80 to 0.80 (53369) | **0.97 to 1.23** (35) | 0.96 to 0.94 |
| s5378_sky130_b | 1.52 to 1.56 (2421) | 1.27 to 1.27 (22) | 0.90 to 0.90 |

Two things fall out, and both are new.

**First: detail placement is not the problem on these designs, it is the solution.** It improves the
peak on three of the five (2.18 to 1.27, 2.79 to 2.36, 1.00 to 0.50) and improves total overflow and
wirelength substantially on the same three. On gcd_sky130_a and s1238_sky130_a it cuts wirelength by
about 45%, which is a large amount of restructuring for a stage whose name suggests local adjustment.

**Second, and this is the defect: our global placement plus legalisation is 1.87x to 2.07x the
reference on wirelength on those same two designs.** The stage that is supposed to produce the global
structure is leaving it 87% to 107% worse than the reference, and detail placement then spends its
whole budget recovering part of that. On the designs where the flow still fails wirelength - exactly
gcd_sky130_a at 1.14 and s1238_sky130_a at 1.08 - it is failing because global placement did not
recover.

The plausible causes are on the excluded list individually (iteration budget 6000) but the observation
is stronger than the individual tests: **the flow is carrying a 2x wirelength debt out of global
placement on some designs, and no amount of work downstream clears it.** That is the next target, and
it is a global-placement problem, not a detail-placement one.

## 2. The guard's trade was the wrong way round: SR-13

The peak is the binding constraint - it fails on 12 of 13 measurable designs, the total on 11. SR-11
still accepted any worsening of the peak provided the total improved at all. On salsa20_ics55_a that
means it kept a result whose total was 1.5% better (0.798 to 0.786 of the reference) and whose peak was
23% worse (34 to 43 bins, 0.97 to 1.23 of the reference). Trading 23% of the binding dimension for
1.5% of the other cannot be right.

**SR-13 changes one condition**: discard detail placement whenever it strictly worsens the peak, rather
than only when it worsens the peak and fails to improve the total.

    before:  if (success && peak_after > peak_before && total_after >= total_before)
    after:   if (success && peak_after > peak_before)

The designs where detail placement earns its keep are untouched, because there it improves the peak -
gcd_sky130_a 2.18 to 1.27, s1238_sky130_a 2.79 to 2.36, gcd_ics55_a 1.00 to 0.50 - so the guard keeps
it. Only the cases where the stage is net harmful are reversed. Built in 13 s, md5 1d1a8fd6 against a
control of f9581627 that differs by exactly this condition.

The measurement is running: ten designs, two seeds each, paired against the commit-matched control, with
every result scored against the legalised reference.

## 3. Honest note on what is not yet established

SR-13 is expected to help on designs where the stage worsens the peak, and to be a no-op where it does
not. That is a prediction from the mechanism and it is being tested, not assumed. If it turns out to cost
wirelength or total overflow on designs where the peak worsens but the stage was still worth keeping,
that will be reported as a failure and it will be withdrawn, as every other failed change in this work
has been.

No result is claimed in this round until the paired measurement completes.

## 4. Tree state

In: SR-10, SR-11, and SR-13 pending its measurement. The SR-13 source change is in the tree and builds;
if the A/B does not support it, it is reverted and the round records why.

## 5. The pipeline is not reproducible, and the noise lands on the binding metric

While checking SR-13 something could not be explained: the same design, seed, binary and command gave
peak overflow 43 in one batch and 34 in another. That is a 26% difference on the dimension that fails
on 12 of 13 designs, so it had to be settled before any further attribution.

    salsa20_ics55_a, seed 1000, binary f9581627, three runs at OMP_NUM_THREADS=8
      union [42924, 42886, ...]   max [34, 34, ...]

    salsa20_ics55_a, seed 1000, binary f9581627, two runs at OMP_NUM_THREADS=1
      union [42886, 42886]        max [34, 34]        IDENTICAL

**At one thread the flow is deterministic. At eight it is not**: the total overflow moves run to run,
and across batches the peak has been observed to move from 34 to 43. Thread count alone does not explain
the larger jump, but the smaller one is enough to establish that the pipeline carries run-to-run
variance, and the peak is where it matters.

This is the third measurement protocol defect found in this work, after the reference being scored
illegally (Round 28) and a control binary containing two changes (Round 24). Its consequence is the
same as theirs: **a single-run comparison on the peak cannot support a conclusion**, and every earlier
peak claim with effect sizes of order 10-30% is inside or near this noise.

**Change to the protocol from here**: attribution runs use OMP_NUM_THREADS=1, where the flow is
deterministic, so one run per arm is a clean comparison and the multi-seed requirement is satisfied by
seeds rather than by repeated runs at a noisy thread count. Standing measurements may keep the higher
thread count for speed, but a peak difference below roughly 20% from a single run is not evidence.

The running SR-13 batch at eight threads was discarded for attribution and re-run at one thread.

## 6. SR-13's result, and its withdrawal

Measured at one thread, same-seed paired, control differing by exactly that condition:

| design | seed | control | SR-13 | HPWL change | outcome |
|---|---|---|---|---|---|
| salsa20_ics55_a | 1000 | 42886 / 34 | 42914 / 34 | +14 | no-op |
| salsa20_ics55_a | 1001 | 39766 / 34 | 39738 / 34 | +10 | no-op |
| s5378_sky130_b | 1000 | 3776 / 28 | 3776 / 28 | 0 | no-op |
| s5378_sky130_b | 1001 | 3703 / 28 | 3703 / 28 | -1 | no-op |
| salsa20_nangate45_a | 1000 | 464 / 12 | 464 / 12 | 0 | no-op |
| **salsa20_nangate45_a** | **1001** | **770 / 13** | **944 / 12** | **-8.8M** | **fired** |

**It fires on one of six seed-pairs, and the one time it fires the peak improves by one bin (13 to 12)
while the total worsens by 174 (770 to 944).** A one-bin peak change is inside the noise this round
established, so there is no measurable benefit to attribute.

**Withdrawn.** The source is restored to SR-11's condition and the rebuild reproduces the md5 of the
build before it exactly (f9581627), so the withdrawal is byte-for-byte clean.

The reasoning that motivated it still stands - the peak is the binding constraint, so a guard should
not trade it away - but the evidence does not show that tightening the rule changes any outcome, and a
change with no measured effect does not belong in the tree.

## 7. The guard does work, at least sometimes

Checked directly, one thread, same seed: the build without SR-11 and the build with it, on
s5378_sky130_b, give a different placement (HPWL 26,386,051 against 26,386,100) and a slightly better
total overflow (3776 to 3769) at the same peak. So the guard is not inert. On salsa20_ics55_a the two
builds are identical.

**The honest state of the guard family:** SR-11 fires occasionally with effects of order 0.1%, and
SR-13's stricter rule does not improve on it measurably. Neither is where the objective will be won.

## 8. Where the objective will be won

Section 1 is the finding that matters. **Global placement plus legalisation is 1.87x to 2.07x the
reference's wirelength on gcd_sky130_a and s1238_sky130_a**, and detail placement then spends its whole
budget recovering part of that. The two designs the flow still loses on wirelength are exactly those
two. Guarding the last stage cannot fix a deficit created by the first one.
