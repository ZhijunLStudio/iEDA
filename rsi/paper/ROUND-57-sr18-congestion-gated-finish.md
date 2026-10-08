# Round 57: SR-18, the congestion-gated finish loop, built and instrumented from the start

## 1. What changed, and why it is the minimal form

Round 56 established the right structure: `PLAPI::runConvergedFinish(max_passes, hpwl_rel_tol)` already runs
legalisation and detail placement up to `max_passes` times, bounded by its argument, with a wirelength
tolerance as the stop. The one thing wrong with it is the tolerance.

**SR-18 replaces that stop with a congestion one**: before each pass it measures, after each pass it
measures again, and a pass is kept only if either congestion number improved and neither got worse;
otherwise the pass is undone - instance positions restored, derived managers refreshed - and the loop stops.
The wirelength tolerance is kept as a secondary stop so the original behaviour survives when congestion is
not available.

Three properties make this different from SR-17, which was withdrawn for running 62 passes where four were
intended:

1. **it is bounded by an existing API argument**, not by a bound written into a new loop;
2. **it is instrumented from the first build** - one log line per pass with the pass index, both congestion
   numbers and the wirelength, so a repeat of last round's surprise would be visible immediately from the
   log rather than after an hour of wall clock;
3. it edits a function that already existed and already had one caller shape, rather than adding a new
   stage sequence.

Built as iEDA-sr18, md5 ead38b5e1bfdc75785e78079aa12501d, against the control iEDA-ctl16 at f9581627.

## 2. What the first check must be

**Counting passes.** Last round the defect was found by counting `Start Detail Placement` per process: the
shipped flow calls it once, and the SR-17 arms called it 62 and 56 times. That check costs one command and
catches exactly this class of failure, so it is the first thing to run against SR-18 - before any congestion
result is read.

Then the four-design prediction, which is the same one SR-17 was to be tested against and is specific
enough to be refuted:

- **gcd_ics55_a** - should keep its passes and reach the 0.80 total overflow the ungated three-pass run
  produced (from 2.20x the reference);
- **s5378_sky130_b** - should undo its first extra pass and end where the control ends (it was exactly inert);
- **s1238_sky130_a** - should undo its extra pass and end where the control ends (the second pass made both
  congestion numbers worse);
- **salsa20_ics55_a** - should be unaffected unless the extra passes help it.

## 3. An incident worth recording

The two SR-17 arms from two rounds ago were **still running**, 74 minutes of CPU each, after I recorded
them as killed. The kill pattern used the binary name in the command line, and the processes are spawned
through a wrapper, so the pattern matched something other than the running processes. They were killed by
PID this time and the process table is clean.

**The lesson is about the harness, not the code**: process cleanup must be verified by listing, not by
issuing a kill and assuming it worked. The same mistake has cost compute twice now.

## 4. Cost, which is the one number that matters for adoption

Each pass costs one legalisation plus one detail placement plus two trial-route evaluations. Measured on
these designs, one pass was about six minutes, dominated by the evaluations. With three passes that is
roughly three times the post-placement time of the flow on a design that uses them all, and close to the
shipped cost on a design that stops after one.

**SR-18 is therefore a deliberate trade, not a free improvement**, and it has to be reported as one.

## 5. State

- **In the tree pending measurement**: SR-18. SR-10 and SR-11 remain.
- **Withdrawn with reasons**: SR-2/3/4/5/7/8/9/12/13/14/15/16, SR-17 (unbounded).
- **The multi-pass evidence stands**: three passes take gcd_ics55_a from 2.20x the reference's total
  overflow to 0.80x and its peak from 0.67x to 0.33x at no wirelength cost, s5378_sky130_b is inert, and
  s1238_sky130_a is damaged by the second pass.
- **Standing**: 4 of 15 designs no worse on every measurable dimension; wirelength fails 2 of 15, total
  overflow 8 of 13 on meaningful counts, peak 9 of 13.
