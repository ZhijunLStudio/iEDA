# Round 68: the instrument, part 2 - three reproducible answers to the same question

## 1. Outcome in one line

The modified tree's placement is not a function of its inputs alone: the same binary, design, seed and
configuration produced **three different placements** depending on what else was running, and each
outcome reproduces exactly within its own setting. The OpenMP override found in round 67 is fixed and
was one real cause; a second, cross-process coupling is demonstrated but **not yet identified**.

## 2. What was fixed and verified

Round 67 fixed two things in the source: iRT no longer resets the process-wide OpenMP thread count to
its own default of 128, and the in-flight congestion measurement restores the caller's setting
afterwards. Both matter because ~48 of the tree's parallel regions do not name a thread count and
therefore inherit the process-wide value, and this host has 512 cores.

    measured, pre-fix:  OMP_NUM_THREADS=1 in the environment, MAX_THREADS_OBSERVED = 128
    measured, post-fix: the count stays at the caller's value

With the fix in place, one design run repeatedly under one condition is byte-reproducible:

| condition | runs | placement | ruler union |
|---|---|---|---|
| sequential, shipped config, OMP=1 | 4 | 80882c81 x4 | 17 |
| 6 concurrent copies of the same design, OMP=1 | 6 | 5a996196 x6 | 16 |
| 3 concurrent copies of the same design, OMP=1 | 3 | 5a996196 x3 | **9/9 identical** |

So the fix is real and the recipe "one flow at a time, OMP_NUM_THREADS=1" is byte-reproducible for
this design.

## 3. What is still wrong

The same design, same binary, same seed, same OMP pin, and a placer config that was **verified byte-identical**
between the two settings, gives two different answers depending on whether the co-running processes are
the same design or different designs:

| co-runners | placement | ruler union | reference | verdict |
|---|---|---|---|---|
| 6 copies of gcd_ics55_a | 5a996196 | **16** | 20 | PASS |
| 6 *different* designs | 7ce5837d | **37** | 20 | fail |
| sequential | 80882c81 | **17** | 20 | PASS |
| the 8-way sweep from round 67 | 7ce5837d | 37 | 20 | fail |

The 7ce5837d outcome was reproduced a second time by a fresh five-design pass, so this is not noise:
each setting is internally reproducible and they disagree with each other. Something couples processes
that write different designs, and it is not the placer config (compared with diff: identical) and not
the working directory path (the sequential runs used four different paths and agreed).

**Also checked and excluded as the cause:** the case directories have no files modified today; the
design config is never rewritten (mtime from workspace setup); there is no shared relative output
directory in the repository root; the EGR directory is derived from an absolute per-run output path;
and the unmodified tree never routes during placement, which is why it was always reproducible.

## 4. The ruler, by contrast, is sound

Worth separating, because it carries the conclusions:

- **Reproducible:** two complete passes over 14 designs returned identical union and max for every design.
- **Thread-insensitive:** one DEF measured at OMP_NUM_THREADS 1, 8, 32 and unset gave 37 every time.
- It evaluates a private snapshot of the DEF in a temporary directory and takes its directory as an
  explicit argument, so it neither reads nor writes the arm's own artifacts.

The ruler is therefore not the problem, and the round-66 standing (which is a ruler measurement of
stored DEFs) stands as a measurement. What is in doubt is the **flow that produces the DEFs**.

## 5. Standing on the fixed tree

14 of 15 designs measured with the fixed binary and the pinned-config recipe (aes is the slowest and
was still running). PASS means no worse than the legalised Innovus reference on all three dimensions.

| design | hpwl | union | max | fails |
|---|---|---|---|---|
| apb4_timer | 0.872 | 0.931 | 1.000 | - |
| gcd_nangate45_a | 0.888 | 1.000 | 1.000 | - |
| s1238_ics55_a | 0.829 | 0.523 | 0.429 | - |
| s1238_nangate45_a | 0.749 | 1.000 | 1.000 | - |
| gcd_ics55_a | 0.944 | 1.850 | 0.500 | union |
| gcd_sky130_a | 1.137 | 2.216 | 1.636 | hpwl,union,max |
| picorv32 | 0.808 | 1.453 | 1.611 | union,max |
| s1238 | 0.761 | 1.150 | 1.429 | union,max |
| s1238_sky130_a | 1.078 | 2.053 | 1.857 | hpwl,union,max |
| s38584_ics55_a | 0.969 | 1.166 | 1.600 | union,max |
| s38584_nangate45_a | 0.959 | 1.500 | 1.000 | union |
| s5378_sky130_b | 0.896 | 1.562 | 1.273 | union,max |
| salsa20_ics55_a | 0.944 | 0.821 | 1.229 | max |
| salsa20_nangate45_a | 0.941 | 1.886 | 1.714 | union,max |

**PASS 4 of 14 - the same count the previous tree recorded.** The determinism fix corrected *how* the
numbers are obtained, not what they are. gcd_sky130_a's peak also moved (1.273 to 1.636) between the
two configurations, which is itself a symptom of section 3 and a reason not to treat single numbers
from this tree as properties of the tree yet.

## 6. Consequences for the campaign, stated plainly

1. Every congestion number the campaign reports for a **modified** arm was measured with 8-15 designs
   in flight, without a placer thread pin that survives the router, and with the process-wide OpenMP
   count being raised to 128 mid-run by iRT. Those numbers are not attributable to the source changes.
   The 21-attempt ledger's verdicts rest on them.
2. Round 31's conclusion - "deterministic within a batch, not between batches" - is this effect seen
   from the outside. It was recorded as unexplained; it now has a mechanism for part of its range and a
   demonstrated residual for the rest.
3. The campaign's own iron rule ("a conclusion must come from a single batch") is necessary but **not
   sufficient**: the batch must also run every arm **in one configuration, one flow at a time, with a
   thread pin that survives the router**. Both arms of any comparison must share the co-run pattern.
4. aes costs about 600 s per flow with the router pinned to one thread, against the 40 s recorded when
   it was implicitly running 128-way. Determinism on this host is expensive, and the campaign's cost
   estimates were made with the router effectively unconstrained.

## 7. Protocol adopted for all further measurement

    one flow at a time (never concurrently), nothing else running on the measurement host,
    OMP_NUM_THREADS=1 in each iEDA process, shipped placer config,
    binary = the tree under test built with the round-67 fix,
    scoring by gp_metrics_compare.density(def, case_root, 200, foundry, "egr", 64) from runs/four_arm.json's fixed reference

Enforced by rsi/harness/gated_flow_sweep.py (workers=1, writes its table incrementally so a killed
run keeps its partial results).

## 8. State

- **In the tree**: SR-10, SR-11, SR-21 and the two round-67 determinism changes. Binaries: iEDA-base
  c9761dc9, iEDA-ctl16 f9581627, iEDA-sr21 62f55d58, **iEDA-det2 74899997** (current, fixed).
- **Open**: the cross-process coupling of section 3. Until it is found, a standing is only comparable
  within one co-run pattern, which is why the protocol above fixes that pattern to "alone".
- **Next**: finish the 15-design standing under the adopted protocol; then re-derive one previously
  accepted change's verdict under it (SR-11 and SR-21 are the only candidates) so the ledger has at
  least one verdict measured on a trustworthy instrument; then resume improving.
