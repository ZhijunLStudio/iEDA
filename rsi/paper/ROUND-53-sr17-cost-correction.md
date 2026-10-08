# Round 53: SR-17 is running and its cost is much higher than I estimated - a correction

## 1. The cost correction, first

Round 52 recorded SR-17's cost as "two orders of magnitude below the congestion-effort knob" because it is
"more iterations of stages already in the flow". **That was wrong, and the runs have made it obvious.**

SR-17's gate takes a congestion measurement before and after each candidate pass. Each measurement is a
full trial-route evaluation. With up to three extra passes that is **up to eight trial-route evaluations
per design**, and a trial-route evaluation is exactly the expensive part that made the congestion-effort
knob cost tens of minutes per design.

**So SR-17 is not cheap.** It is cheaper than the knob only in that it stops as soon as a pass stops
helping, whereas the knob pays on every Nesterov iteration. On a design that improves across three passes
it pays for eight evaluations; on a design that stops after one it pays for two.

Measured on gcd_ics55_a: the control arm finished in the normal time, the SR-17 arm has been running about
twenty-five minutes and is still working, at 2900 per cent CPU. That is the real price of the gate.

## 2. What this changes about the proposal

The mechanism is still the best lever found - the multi-pass evidence is unambiguous - but **the
self-measuring gate is not free**, and for the three-pass case it is expensive. Two consequences:

1. any claim about SR-17 must carry this cost, not the cost I estimated in round 52;
2. a cheaper gate is worth looking for. The pass loop could take its decision from the placer's own
   density or wirelength signals and use the trial-route evaluation only when those are ambiguous - but
   round 51 already showed wirelength is flat across the passes while congestion halves, so wirelength
   cannot be the primary signal. Whether some cheaper in-process quantity tracks the congestion outcome is
   a question this campaign has not answered, and every attempt to build such a proxy so far (SR-8, SR-9)
   failed to track the evaluator.

**The honest position**: the gate is correct and expensive, and whether it is affordable depends on the
design and on how often it has to evaluate. That has to be measured, not assumed.

## 3. Where the round leaves the test

Four designs of SR-17 against the pinned control at one seed. Two control arms are complete; the two SR-17
arms are still running. The prediction being tested is specific:

- **gcd_ics55_a** should keep its passes and reproduce the 0.80 total overflow;
- **s5378_sky130_b** should discard one pass and end where the control ends;
- **s1238_sky130_a** should discard its pass and end where the control ends;
- **salsa20_ics55_a** should be unaffected unless the passes help.

No result is claimed this round. The determination is next round's first task, and it will be reported
with the measured cost attached.

## 4. State

- **In the tree pending measurement**: SR-17. SR-10 and SR-11 remain.
- **Withdrawn with reasons**: SR-2/3/4/5/7/8/9/12/13/14/15/16.
- **Standing**: 4 of 15 no worse on every measurable dimension; wirelength fails 2 of 15, total overflow
  8 of 13 on meaningful counts, peak 9 of 13.
- **The multi-pass evidence stands and is unaffected**: three passes take gcd_ics55_a from 2.20x the
  reference to 0.80x, s5378_sky130_b is inert, s1238_sky130_a is damaged by the second pass.
