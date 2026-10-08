# Round 59: SR-20 executes - the gate runs for the first time, bounded and making its own decisions

## 1. Why the first three attempts never ran

The flow issues three separate Tcl commands - placer_run_gp, placer_run_lg, placer_run_dp - and each maps
to its own API call. It never goes through a composite entry point. Verified mapping:

    placer_run_dp  ->  CmdPlacerRunDP::exec()  ->  PlacerIO::runDetailPlacement()  ->  PLAPI::runDP()

That is why SR-18 (placed in runConvergedFinish) and SR-19 (placed in runFlowResult) were both inert:
**neither function is on the command path the flow takes.** The location is as much a part of the change as
the logic, and three rounds were spent learning it.

## 2. SR-20's placement, and its first execution

SR-20 puts the gate in a new `PLAPI::runGatedFinish(max_extra_passes)` and calls it from
`PlacerIO::runDetailPlacement()`, immediately after the shipped `runDP()` - the function the command
actually lands in. Built as iEDA-sr20, md5 646b170a5b70e0a564fd572df138fde7.

The mandatory first check, before any congestion result is read:

    Start Detail Placement calls:  2      (shipped once, plus exactly one extra - bounded as designed)
    SR-20 log lines:               1      (it executed)
    [SR-20] extra pass 1/2: peak 3 -> 6, total 37 -> 27 (undone)
    run:                           rc 0, placement written

**The gate ran, measured, decided, and stopped.** The extra pass improved total overflow from 37 to 27 and
worsened the peak from 3 to 6, so under the rule - keep only if something improved and nothing worsened -
it was undone and the loop ended. On this design and seed SR-20 is therefore a no-op, which is the correct
behaviour for a Pareto-safe gate: it refused a trade that the objective's binding dimension would have
punished.

## 3. What is now different from the three failed attempts

| attempt | outcome | lesson carried into SR-20 |
|---|---|---|
| SR-15 | withdraw - broke a converging design with a misplaced continue | do not skip the loop body |
| SR-17 | withdraw - ran 62 passes where four were intended | bound the loop and log every pass |
| SR-18 | withdraw - never executed (runConvergedFinish is not on the command path) | place it where the flow runs |
| SR-19 | withdraw - never executed (runFlowResult is not on the command path either) | same |
| **SR-20** | **executes, bounded, decides** | all four |

Each failure produced one fact that the next attempt used. The chain is what a search looks like when the
measurement is honest: no single step was correct, and the sequence converged on a working instrument.

## 4. What is not yet claimed

**One design, one seed, and the result is a no-op.** SR-20's value depends entirely on whether it keeps the
gain on the designs where the ungated three-pass run helped - gcd_ics55_a at other seeds (where it went to
0.80 total overflow) and the other designs - and whether it stays inert where it should. That is the next
measurement, with the pass count asserted before the congestion numbers are read, which is now the standing
procedure.

Cost remains what round 54 measured: each extra pass is one legalisation, one detail placement and two
trial-route evaluations, about six minutes on these designs. On a design whose first extra pass is undone,
SR-20 pays for one pass and stops.

## 5. State

- **In the tree pending measurement**: SR-20. SR-10 and SR-11 remain.
- **Withdrawn with reasons**: SR-2/3/4/5/7/8/9/12/13/14/15/16, SR-17, SR-18, SR-19.
- **The multi-pass evidence stands**: three passes take gcd_ics55_a from 2.20x the reference's total
  overflow to 0.80x and its peak from 0.67x to 0.33x at no wirelength cost, s5378_sky130_b is inert, and
  s1238_sky130_a is damaged by the second pass.
- **Standing**: 4 of 15 designs no worse on every measurable dimension; wirelength fails 2 of 15, total
  overflow 8 of 13 on meaningful counts, peak 9 of 13.
