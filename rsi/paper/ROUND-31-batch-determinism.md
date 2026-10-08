# Round 31: the pipeline is deterministic within a batch and not between batches

## 1. The anomaly

gcd_sky130_a, seed 1000, iterations 2000, target density 0.8, binary f9581627, one thread:

| batch | runs | global placement | overflow | legalization / global placement |
|---|---|---|---|---|
| current-tree sweep | 1 | 10,717,785 | 0.1233 | 1.403 |
| gp1 (minimal script) | 3 | 10,717,785 (all 3) | 0.1233 | 1.403 |
| bin_check, binary f9581627 | 2 | 10,717,785 (both) | - | 1.403 |
| bin_check, binary 0c50cc35 | 2 | 10,717,785 (both) | - | 1.403 |
| repro, one thread | 5 | **7,364,089 (all 5)** | **0.1194** | **1.012** |
| repro, eight threads | 5 | **7,364,089 (all 5)** | **0.1194** | **1.012** |

Within every batch the result is identical across repetitions. Between the two groups it differs by 31%
in global-placement wirelength and by a factor of 1.4 in what the next stage costs.

## 2. What is ruled out

| candidate | how it was excluded |
|---|---|
| the binary | both md5s (f9581627 and 0c50cc35) now give 10,717,785 |
| the script | repro.py itself now gives 10,717,785, having given 7,364,089 before |
| the case config, netlist, LEF | mtimes 09-16 and 08-03, unchanged; md5s recorded |
| the generated Tcl | differs between the groups only in the output directory path |
| the environment | stripped to PATH, HOME and LD_LIBRARY_PATH with env -i: still 10,717,785 |
| thread count | the low regime appeared at both one thread and eight |
| the seed | fixed at 1000 in every run |
| run order within a batch | the five repeat runs are identical, so it is not ordering |
| address-space randomness | would not produce five identical runs |

**The low regime appeared twice and does not reproduce now.** Its cause is not identified, and since it
cannot be reproduced it cannot be bisected further by measurement.

## 3. What is established

**The pipeline is deterministic within a batch and not between batches.** That is the fact to carry, and
its consequence is a rule that overrides convenience:

> **A conclusion may only be drawn from a single batch that contains both arms.** Stage tables assembled
> from separate runs - "the sweep said 10.7M, a fresh run said 7.4M" - are not evidence, however
> reproducible each run is in itself.

This is the fourth protocol defect this work has found and the second that cannot be fixed by choosing
what to measure. The other three: the reference scored illegal (Round 28), a control binary containing
two changes (Round 24), and determinant only at one thread (Round 29). The common shape is a comparison
between things that are not comparable.

## 4. Consequence for the standing

The corrected standing reported in Round 28 legalised the reference in one batch and measured our
placements in another. **By the rule above, those ratios are provisional and must be rebuilt in a single
batch with both arms.** They are the best numbers available and they are not to be quoted as settled:

- designs no worse on every measurable dimension: 4 of 15 (provisional)
- wirelength loses on 3 of 15; total overflow on 11 of 13; peak on 12 of 13 (provisional)

No source change is claimed this round. The tree is unchanged: SR-10 and SR-11 in; SR-2, SR-3, SR-4,
SR-5, SR-7, SR-8, SR-9, SR-12, SR-13 and SR-14 withdrawn with recorded reasons.

## 5. Next, and why it is next

**Rebuild the standing in one batch with both arms.** Every later source change is judged against it, so
it has to be sound before any further algorithm work is worth doing: 15 valid designs, each measured as
our placement and as the legalised reference, in a single process. The scripts that do paired work
already run both arms in one process - sr_ab.py, sr13_ab.py, guard_check.py, bin_check.py, gp1.py - so
the standing harness becomes one more of those rather than a new kind of thing.

Only after that does a source change get made, and when it does, it is measured the same way.
