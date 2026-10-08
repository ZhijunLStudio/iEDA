# Round 58: SR-18 never ran, SR-19 ran and aborted, and the instrument caught the first in one run

## 1. SR-18 was inert by construction

SR-18 put the congestion-gated pass loop inside `PLAPI::runConvergedFinish`. **The shipped flow never calls
that function.** Counting the evidence from a completed run:

    SR-18 log lines in the run:  0
    placement.def:               written
    congestion at the SR-11 point:  peak 6 -> 3, total 62 -> 37
    the standing's own values:      peak 3,      total 37

The run completed normally and reproduced the standing exactly, with **zero** SR-18 lines. The shipped LG+DP
call sites are in `PLAPI::runFlowResult()` at lines 616 and 633, and the second `notifyPLWLInfo(2)` block is
at line 640.

**This is the same class of error as SR-17** - code that cannot do what it claims - and the per-pass
instrument added in round 57 turned it into a one-run diagnosis instead of an hour of wall clock. That is
the process working: the check I said I would run first is the check that found it.

## 2. SR-19 moved the gate to the shipped path, and aborted on its first iteration

SR-19 placed the same loop after the shipped `runDP()` in `runFlowResult`, bounded at two extra passes, with
one log line per pass. It built (md5 ea4a284ce23dbfb2bef1944c63ada7bb) and the run reached the loop: the last
line in global placement's log is the SR-11 decision at 09:13:58, which is immediately before the insertion
point.

Then the process disappeared - **no SR-19 line, no `placement.def`**, only the density and congestion map
directories from the measurements that had already run. The run aborted inside the loop's first iteration.

**The cause is not determined because the harness discarded stderr.** That is the second time this has
cost a diagnosis, and it is a gap in my own instrumentation rather than in iEDA: every harness script that
spawns iEDA with `stdio: ignore` throws away the one thing that would say what happened. Capturing stderr
with the output is now mandatory for every launch.

## 3. Both are out; the tree is clean

    SR-18 residual: 0    SR-19 residual: 0
    binary: f9581627     (the same hash the tree has had since round 30)

SR-18 was inert, and SR-19 aborts runs, so neither belongs in the tree.

## 4. What this line of work has established, and what it still needs

**Established, and it is the strongest result of this campaign:** the shipped flow runs legalisation and
detail placement once each, and running them three times takes gcd_ics55_a from 2.20x the reference's total
overflow to 0.80x and its peak from 0.67x to 0.33x, at no wirelength cost; s5378_sky130_b is exactly inert;
s1238_sky130_a is damaged by the second pass. Those three behaviours are distinguishable by the congestion
measurement, which is why a gate is the right shape.

**Needed:** a gate placed where the flow actually runs it, that does not abort, and whose failure mode is
visible. Three attempts have now failed on implementation rather than on the idea - SR-15 broke a converging
design with a misplaced continue, SR-17 ran 62 passes where four were intended, SR-18 never executed. The
common thread is that each was written in one edit and then measured once; the next attempt should be built
in a form where the loop's iteration count is asserted from the log before any congestion result is read,
and with stderr captured.

## 5. State

- **In the tree**: SR-10 and SR-11. Binary f9581627, source clean.
- **Withdrawn with reasons**: SR-2/3/4/5/7/8/9/12/13/14/15/16, SR-17 (unbounded), SR-18 (never executed),
  SR-19 (aborts).
- **Standing**: 4 of 15 designs no worse on every measurable dimension; wirelength fails 2 of 15, total
  overflow 8 of 13 on meaningful counts, peak 9 of 13.
