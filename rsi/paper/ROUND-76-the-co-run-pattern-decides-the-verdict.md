# Round 76: the co-run pattern decides the verdict, so the round-74 baseline was not the protocol it claimed

## 1. What was observed

`apb4_timer` at seed 1002, same binary (`iEDA-det3`), same seed, same command sequence, same ruler,
`OMP_NUM_THREADS=1`, placer config pinned to `num_threads=1` and verified byte-identical between settings:

| how it was run | union | peak | vs reference peak 16 | verdict |
|---|---|---|---|---|
| 6 designs in flight (round 74 sweep) | 2029 | 17 | 1.06x | fail |
| 4 designs in flight (round 75 pre-screen) | 1985 | 16 | 1.00x | pass |
| **one flow at a time, 8 sequential repeats** | **2066** | **16** | **1.00x** | **pass, 8/8 identical** |

Three different placements for one cell, and the sequential setting is perfectly stable: **8 of 8 runs
identical** to the last digit (union 2066, peak 16, hpwl 15688453).

So the variation is not run-to-run randomness. It is a function of **how many flows are in flight**, and
each setting is internally reproducible.

## 2. Why this matters more than the numbers

Round 68 established "one flow at a time" as the required protocol and round 74 built the baseline in the
metric form that round 72 showed was needed. **But the round-74 sweep was launched with `--workers 6`,
so its 60 cells were measured with six designs in flight - the opposite of the protocol it is quoted
under.** The same is true of the SR-23 and SR-24 acceptance tables in round 75.

Consequences, stated plainly:

1. **The round-74 table is not the adopted protocol.** Its per-seed verdicts for the current tree
   (apb4_timer 1/4, and by implication others) may differ when measured one at a time. `apb4_timer` is a
   demonstrated case: 1/4 concurrent, at least 2/4 sequential.
2. **The round-75 withdrawal of SR-23 and SR-24 rests on concurrent-pattern numbers.** They regressed
   `salsa20_ics55_a@1003` from peak 35 to 38, which is 3 bins and therefore outside the observed 1-2 bin
   coupling, so the direction is probably robust - but it is not established.
3. **Both the tree and the unmodified tree need the baseline re-taken one flow at a time** before any
   acceptance decision, because the criterion is per-cell and the cells move.

## 3. What is established and what is not

**Established.** The instrument repeats within a fixed co-run setting (8/8). Concurrency changes the
result at the 1-2 bin level even with the round-70 measurement fix and `num_threads=1`. Therefore a
verdict is only meaningful with the co-run pattern fixed and stated, and the round-74/75 tables have the
wrong pattern for the protocol they are quoted under.

**Not established.** Which pattern is "right". One-at-a-time was adopted because it is the setting that
isolates the source change; it is also the slow one (`aes` is ~600 s per flow at one thread). The
concurrent setting is what the campaign's original batch harness used, so the historical numbers are
concurrent-pattern numbers.

**Not identified.** The mechanism by which processes running *different designs* influence each other.
Checked and excluded: shared working directory contents (a flow leaves no file outside its own workdir),
case-directory modification, the placer config, the fixed round-70 EGR directory, and thread count. The
round-70 fix removed the cross-design coupling for `gcd_ics55_a` in one test and clearly does not remove
it here, so the remaining cause is something else shared - most plausibly a resource that is sized from
the machine (cache/pages, OpenMP runtime state, or a memory/hugepage effect changing floating-point
timing-sensitivity), and it is **not** guessed at here.

## 4. Action

1. **Re-take the baseline one flow at a time**, both arms, same seeds. That is 120 sequential cells and it
   is the long pole; it must be run with a strictly serial sweep and nothing else on the machine.
2. Until that exists, **quote no per-cell verdict**; the round-74 table is marked provisional in this
   record.
3. Re-check SR-23/SR-24 only if the serial baseline shows their 3-bin regression persists.
4. Only then resume source changes, against the serial baseline.

## 5. State

- **Tree**: unchanged, `iEDA-det3` = `83ee2f75` (round 75's changes were withdrawn).
- **Instrument**: `multi_seed_sweep.py` supports `--workers 1`; the serial sweep is what the protocol
  requires and what round 74/75 did not do.
- **New evidence**: 8 sequential repeats of one cell, identical; the same cell differs by 1-2 bins when
  six flows share the machine.
