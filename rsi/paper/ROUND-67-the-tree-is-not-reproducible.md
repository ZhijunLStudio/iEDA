# Round 67: the modified tree is not reproducible, and the cause is a callee overriding the caller's thread pin

## 1. Outcome in one line

Three identical runs of the current tree on one design, one seed, one batch produced **two different
placements**, one of which passes the reference and one of which fails it; the unmodified tree was
byte-identical on the same three runs. The cause is that the campaign's congestion measurement runs
iRT in-process, and iRT resets the process-wide OpenMP thread count from its own option. A two-line
fix restores reproducibility for sequential runs and takes gcd_ics55_a from fail to pass deterministically.

## 2. The measurement, and why it is the instrument that failed

Nothing in the campaign's conclusions can be stronger than this, so it was measured first.

Same binary, same design (gcd_ics55_a), same seed (1000), same command sequence, same batch,
OMP_NUM_THREADS=1 throughout:

| binary | runs | placement DEFs (md5 prefix) | ruler union | ruler max |
|---|---|---|---|---|
| iEDA-base (unmodified) | 3 | b7603486, b7603486, b7603486 | 37, 37, 37 | 3, 3, 3 |
| iEDA-sr21 (current tree) | 3 | 5a996196, 88d7021d, 5a996196 | **16, 37, 16** | 2, 3, 2 |
| iEDA-sr22 (this round's GP refinement, since reverted) | 3 | 22b0c613, 793fde9a, 79746ea4 | 21, 18, 15 | 3, 3, 2 |

The reference is union 20, max 6. **The current tree sometimes delivers a passing placement and
sometimes a failing one, from the same binary on the same input.** Whatever else is true, no
per-design verdict from this tree is currently a fact about the tree.

The decision log shows where it enters - the first guard reading already differs between runs that
should be identical:

    run A   [SR-11] detail placement kept: peak overflow 6 -> 3, total overflow 62 -> 37
    run B   [SR-11] detail placement kept: peak overflow 6 -> 4, total overflow 62 -> 42

The "before" number agrees (62); the "after" number does not. The placement going into detail
placement is the same; what detail placement produced, or what the evaluator reported of it, is not.

## 3. Cause

    src/operation/iRT/interface/RTInterface.cpp
      RTDM.getConfig().thread_number = getConfigValue(config_map, "-thread_number", 128);
      omp_set_num_threads(std::max(RTDM.getConfig().thread_number, 1));

iRT sets the **process-wide** OpenMP thread count from its own option, whose default is 128. A trial
route's overflow counts are integers produced by parallel reductions, so their value depends on how
the work was split - and anything gating on that value then makes a different decision per run. The
unmodified flow never routes during placement, which is exactly why it is byte-reproducible and the
modified one is not.

Verified directly, not inferred: sampling /proc/<pid>/status while the flow ran with
OMP_NUM_THREADS=1 in the environment gave **MAX_THREADS_OBSERVED = 128**.

**This also falsifies a documented verification step.** The handover's environment section says the
thread pin is verified by checking that the process has one thread. On the modified path that check
returns 128, so it was never actually performed there - the campaign believed it had pinned the
solver while the router, invoked from inside placement, was running on all cores.

## 4. The fix, and what it does and does not restore

Two changes, both about not letting a callee change what the caller measured:

1. **Honour an explicit thread count from the environment.** If OMP_NUM_THREADS is set, that becomes
   iRT's default instead of 128. A library overriding its caller's OpenMP configuration is a defect
   regardless of the campaign.
2. **Restore the OpenMP configuration after the measurement.** PLAPI::notifyPLCongestionInfo now
   saves omp_get_max_threads() before the congestion evaluation and restores it afterwards, so the
   router cannot leave the following placement stages - whose parallel reductions are order
   dependent - running at a different width than the caller pinned.

After both, four consecutive runs are byte-identical:

| binary | runs | DEFs | union |
|---|---|---|---|
| iEDA-det2 (this fix) | **4** | **80882c81 x4** | **17, 17, 17, 17** |

union 17 against a reference of 20, max 2 against 6, hpwl 4094306 against 4336162 (0.944).
**gcd_ics55_a passes reproducibly** - the design the campaign credited SR-21 with taking from 1.85x
to 0.80x, and which round 66 recorded as still failing at 1.85x. It appears the credited win was one
draw from this coin flip.

## 5. What is still broken: concurrency

The fix holds for sequential runs. It does not yet hold when designs are run the way the campaign
runs them. With eight flows in flight, the same fixed binary produced union 37 for gcd_ics55_a, the
failing branch:

    8-way concurrent, same binary, same design, same seed:  union=37  max=3
    sequential,        same binary, same design, same seed:  union=17  max=2

The harness launches iEDA with **cwd = the repository root** (gp_agent.run_ieda passes
cwd=REPO_ROOT), so concurrent runs share a working directory. The congestion evaluator's directory is
derived from the data manager's output path and falls back to "." when that is empty
(InitEGR: base = get_output_path(); if empty, base = "."), which puts concurrent runs in the same
"rt/rt_temp_directory" when the path is not supplied. The measurement above is consistent with that
and the exact path resolution is the next thing to establish.

**Consequence, stated plainly: every congestion number the campaign reports for a modified arm was
measured with concurrent runs, because the batch harness always ran designs in parallel. Those
numbers are therefore not attributable to the source changes.** The unmodified arms are unaffected in
principle because they never route during placement, which the byte-identical result above corroborates.

## 6. SR-22 (bounded, ruler-gated global-placement refinement): built, verified, reverted

Implemented as runGatedGPRefine on PLAPI, called from the finishing hook, running up to two segments
of GP re-linearisation at congestion effort 4 followed by one legalisation and one detail placement
each, keeping the best segment by peak-then-total and restoring it at the end.

It works as designed. Verified rather than assumed, from its own log:

    [SR-22] entry: peak 4 total 27
    [SR-22] segment 1/2 effort 4 iterations 300: peak 18 total 149 | best is segment 0 at peak 4 total 27
    [SR-22] segment 2/2 effort 4 iterations 300: peak 5 total 45  | best is segment 0 at peak 4 total 27
    [SR-22] restored segment 0: peak 4 total 27 instead of the last one at peak 5 total 45

Bounded, both segments executed, both rejected on the numbers, entry state restored. It is reverted
and not in the tree, for three measured reasons: it bought nothing on its only test (both segments
worse), it roughly doubled the flow time (35s against 16s), and it adds two more decisions to a
nondeterministic signal, turning three runs into three different placements. **A refinement cannot be
evaluated on an instrument that does not repeat**; the instrument comes first.

## 7. A second documented landmine that is now wrong

The handover says to build with COMPILER_PATH=/usr/bin:/usr/lib/gcc/x86_64-linux-gnu/10 to work
around the host preload shim. That shim is gone from this host (/etc/ld.so.preload does not exist),
and setting COMPILER_PATH now *breaks* the build with "cc1plus: error: too many filenames given" on
every translation unit. The correct action today is to build with no COMPILER_PATH at all; the
gcc-10 directory it names is not the compiler in use (g++ 11.4.0).

## 8. State

- **In the tree**: SR-10, SR-11, SR-21 (unchanged) plus the two determinism changes above.
  Binaries: iEDA-base c9761dc9, iEDA-ctl16 f9581627, iEDA-sr21 62f55d58 (pre-fix current tree),
  **iEDA-det2 74899997 (current tree with the determinism fix)**.
- **Reverted this round**: SR-22, with the reason in section 6.
- **Superseded pending re-measurement**: every congestion value in rounds 1-66 for a modified arm.
- New harness scripts: rsi/harness/egr_ruler_batch.py (round 66) and rsi/harness/gated_flow_sweep.py
  (runs the standard flow for a design set and reports the verdict against the stored reference).

## 9. Next, in order

1. Make the congestion measurement independent of concurrency (resolve the evaluation directory from
   the run's own output path, or serialise), then re-run three repeats of one design at full
   concurrency to confirm a single value.
2. Re-measure the 15-design standing with the fixed, deterministic tree - sequentially until 1 is
   done - and compare against the round-66 table rather than against any earlier number.
3. Only then evaluate any source change against the objective's rule: pass count up, nothing
   regressing.
