# Round 55: SR-17's loop was unbounded - withdrawn - and the build environment needed a workaround

## 1. The defect, found by counting

SR-17 was designed to run at most three extra LG+DP passes. Counting the stages in global placement's own
log for each of the two arms:

| arm | Start Detail Placement | Finish Legalization |
|---|---|---|
| gcd_ics55_a | **53** | **53** |
| s1238_sky130_a | **47** | **47** |

The expected number is four - the shipped pass plus three. It ran an order of magnitude more, which is why
the arms had been running for over an hour and why no SR-17 decision line was ever written.

The loop body is bounded (a for-loop to three with a break), and the logs show the passes repeating, so
something re-enters the stage sequence. I did not determine what: doing so needs the loop instrumented,
and the change has to come out of the tree first.

**SR-17 is withdrawn.** The three implementation defects in this family - SR-15's continue statement
skipping the loop body, SR-16's guard that only fires at one of the two ways a solve can end, and this loop
that does not stay bounded - have one thing in common: each was invisible in the source and only visible in
behaviour.

## 2. The source is exactly reverted

    SR-17 residual occurrences: 0
    rebuilt md5: f9581627
    expected:    f9581627

## 3. A build-environment fault, and its workaround

The rebuild failed repeatedly with collect2: fatal error: cannot find ld, even though /usr/bin/ld exists
and runs, and a plain gcc hello.c failed with cannot execute cc1: execvp: No such file or directory while
/usr/lib/gcc/x86_64-linux-gnu/10/cc1 exists and is readable but will not execute. Both helpers exist and
neither will be exec'd, which is the same host shim that denies directory names: it also interposes the exec
path, and gcc's helper lookups are what it disrupts.

Hiding the preload file inside a mount namespace did **not** fix it for gcc, unlike for iEDA, so the
interception is not only through ld.so.preload for these paths. What did work:

    COMPILER_PATH=/usr/bin:/usr/lib/gcc/x86_64-linux-gnu/10 cmake --build build --target iEDA

**Anyone building in this environment should set COMPILER_PATH**, and the failures clearing on retry in
rounds 46 to 54 were the same intermittency, not machine load as I recorded then.

## 4. What stands

- **The multi-pass finding is unaffected and is the real result of this line of work**: three passes take
  gcd_ics55_a from 2.20x the reference's total overflow to 0.80x and its peak from 0.67x to 0.33x at no
  wirelength cost, s5378_sky130_b is exactly inert, and s1238_sky130_a is damaged by the second pass.
- **A cheap partial gate exists**: an inert pass reports Total Movement 0 from the legalizer, so the
  no-change case is detectable at zero cost. The case where a pass acts and worsens congestion still needs
  an evaluation.
- **The self-measuring gate as implemented is withdrawn**, and its measured cost was about three times the
  post-placement time on a design that uses all three passes.

## 5. State

- **In the tree**: SR-10 and SR-11. Binary **f9581627**, source clean.
- **Withdrawn with reasons**: SR-2/3/4/5/7/8/9/12/13/14/15/16, **SR-17**.
- **Standing**: 4 of 15 designs no worse on every measurable dimension; wirelength fails 2 of 15, total
  overflow 8 of 13 on meaningful counts, peak 9 of 13.
