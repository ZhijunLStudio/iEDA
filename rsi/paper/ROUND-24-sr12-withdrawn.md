# Round 24: SR-12 is withdrawn - a wrong control made me credit the guard's work to it

## 1. The attribution error

Round 23 compared two binaries and read the difference as SR-12's effect. They were not comparable:

| binary | md5 | contains |
|---|---|---|
| sr10 | aad1fef4 | HEAD only |
| sr11 | 7845cf63 | HEAD + SR-11 (detail-placement guard) |
| sr12 | 841df305 | HEAD + SR-11 + SR-12 (direction-aware coefficients) |

The comparison used **sr10 as the control and sr12 as the treated**, which differ by **two** changes.
Every number reported in Round 23 as SR-12's - s38584_nangate45_a going 21/4 to 0/0, salsa20_nangate45_a
going 1090 to 813 - was in fact mostly **SR-11**, the guard. The direction check was contaminated the
same way: it compared sr10 against sr12 and called the difference the directional tilt, when the guard
was in one of them.

The error was caught by re-reading the binary lineage rather than the numbers, and the corrected
comparison is control sr11 against treated sr12.

## 2. SR-12 on its own, against the correct control

Same seed, same lineage, the two binaries differing only by SR-12:

| design | control (sr11) | treated (sr12) | reference | SR-12 alone |
|---|---|---|---|---|
| **salsa20_nangate45_a** | 464 / 12 | **813 / 16** | 250 / 10 | **union +349 (+75%), peak +4 - much worse** |
| **apb4_timer** | 1928 / 16 | 2119 / 18 | 5626 / 26 | union +191 (+10%), peak +2 - worse |
| s38584_nangate45_a | 3 / 1 | **0 / 0** | 6 / 2 | union -3, peak -1 - better |
| gcd_nangate45_a | 0 / 0 | 0 / 0 | 0 / 0 | unchanged |

**One design better, one unchanged, two worse - and the worst of them is salsa20_nangate45_a, the
design the change was derived from, where total overflow rises 75%.** SR-12 is withdrawn.

## 3. The revert, verified byte-for-byte

The two changed files were restored from the commit before SR-12 and the tree rebuilt:

    residual occurrences of the new function: 0
    rebuilt md5: 7845cf63e54e74fa11bd2b06998982f0
    sr11    md5: 7845cf63e54e74fa11bd2b06998982f0

**Identical.** The source is byte-for-byte what produced sr11, so the withdrawal is exact and nothing
of SR-12 remains in the tool.

## 4. What survives from the direction investigation

The direction finding itself is real and was independently measured: our overflow on
salsa20_nangate45_a is 81 horizontal against 1009 vertical, on s38584_nangate45_a it is 0 against 21,
and the same circuit on ics55 tilts the other way. **The placer does treat horizontal and vertical
identically while the routing stack does not** - that part of the diagnosis stands, and the LEF does
carry the per-direction track counts the placer ignores.

What that round got wrong is the **fix**. Passing the coefficient pair as inverse capacity moves
overflow from one direction to the other without reducing the total: on salsa20_nangate45_a vertical
overflow did fall (1009 to 715), but the whole-flow result got worse because the guard had already
found a better answer (464) by a route that does not depend on direction at all. **Trading one
direction's overflow for the other's is not a congestion improvement**, and the evaluator's union
metric says so.

## 5. What this changes about the method

The rule that was violated is one this work already wrote down - source comparisons must use two
binaries built from the same commit, differing only by the change under test - and it was violated by
naming the wrong binary as the control, not by any measurement being wrong. Every number in Round 23
was correctly measured; it was attributed to the wrong cause.

**The check that catches it is cheap and is now part of the routine**: before reading any difference,
list what each binary contains. It cost one md5sum and one look at the build history.

## 6. Tree state after the withdraw

In: **SR-10** (in-tool congestion measurement) and **SR-11** (detail-placement dominance guard).
Withdrawn, each with a measured reason: SR-2 (harmful), SR-3, SR-4, SR-7, SR-8, SR-9 (no-ops or
proxies that do not track), SR-5 (mixed), **SR-12 (correct control shows it is worse on two of four)**.

The standing is therefore unchanged from Round 21, where SR-11 was measured: the peak, the dimension
the objective is about, is capped wherever detail placement damages it, and the two robustly failing
designs are still failing because their deficit is created before that stage.
