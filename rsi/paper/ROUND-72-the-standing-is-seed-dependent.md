# Round 72: the standing is seed-dependent, and most of it does not survive multi-seed

## 1. Outcome in one line

At seed 1000 the standing is 5/15 and reproduces across two full passes. **Multi-seed, only 2 of those 5
still pass on every seed**, and the design this round's gain came from passes on **1 of 4**.

## 2. The measurement is now clean enough to ask the question

Rounds 67-70 fixed the instrument (a callee overriding the caller's thread pin; the in-flight trial route
reading back per-layer overflow maps left by earlier measurements in a reused directory). Two complete
passes at seed 1000 agree on 14 of 15 designs byte-for-byte. Only then is a multi-seed question
answerable, because with the earlier instrument a repeated seed did not even give a repeated answer.

## 3. The measurement, with the placer thread count pinned

The four ics55 designs ship `PL.num_threads = 16` and their placement regions use `schedule(dynamic)`,
so their result follows machine load; the other eleven ship `num_threads = 1`. With the count pinned to
1 and `OMP_NUM_THREADS=1`, seeds 1000-1003, one flow at a time, same binary, same config, same ruler:

| design | seed 1000 | 1001 | 1002 | 1003 | seeds passing |
|---|---|---|---|---|---|
| gcd_nangate45_a | PASS | PASS | PASS | PASS | **4/4** |
| s1238_ics55_a | PASS | PASS | PASS | PASS | **4/4** |
| s1238_nangate45_a | PASS | PASS | PASS | fail (union 4, max 2 vs 0,0) | 3/4 |
| apb4_timer | PASS | fail (union 1.063, max 1.250) | fail (max 1.250) | PASS | 2/4 |
| **gcd_ics55_a** | PASS (union 0.80) | fail (union 2.30) | fail (union 1.25) | fail (union 2.10) | **1/4** |

**Designs passing on all four seeds: 2 of 15.** The seed-1000 number is 5 of 15.

For context, further confirmation that the gcd_ics55_a pass is fragile: seed 1000 gives union 16 with the
placer pinned to one thread, and union 37 with the shipped config for ics55 (`num_threads=16`) when run
as the first design in a fresh process - the same seed, the same command, a different answer, because the
parallel reduction order follows load.

## 4. What this means, stated without hedging

**The gain reported in round 71 is withdrawn as an established improvement.** It is real at seed 1000 and
it is why the seed-1000 count is 5 rather than 4, but the objective's own rule is paired multi-seed
evidence, and this design passes on 1 of 4 seeds. Under that rule the increment is not attributable.

**More importantly, the finding generalises to every standing number this campaign has produced.** All of
them - 3/15, 4/15, 5/15 - are single-seed (1000) numbers, and this round shows that three of the five
seed-1000 passers fail on at least one other seed. The campaign's own noise measurement (median union
spread 5.9%, p90 26%; peak spread up to 66% on individual designs) predicted exactly this, and its
single-seed standing was never a stable property of the tree.

**What the objective's metric should therefore be.** "Each design, each measurable dimension, no worse
than Innovus" is a statement about a seed, not about the tree. The honest form is a **pass rate per design
over a stated seed population**, and the headline becomes "designs passing on every measured seed". On
that form this tree is at **2 of 15**. Any future change must move *that* number, and a change that gains a
design at one seed and loses it at another has gained nothing.

## 5. The one thing that did improve this round

Not the pass count - the ability to ask the question at all. Before rounds 67-70, a repeated seed did not
give a repeated answer, so no multi-seed statement was possible in either direction, and the campaign's
"seed spread" measurements were confounded with its own measurement defect. The instrument now repeats
within a batch (14/15 byte-identical), and the residual is localised to the shipped `num_threads=16`
setting on the four ics55 designs.

## 6. Next

1. **Adopt the per-seed pass rate as the objective's metric** and re-derive the baseline in that form: run
   all 15 designs at seeds 1000-1003 (roughly 4x the cost of one pass) and report pass rate per design
   and the count passing on all seeds. Do this for the unmodified tree as well, so the comparison is
   like-for-like in the same form.
2. **Fix the shipped `num_threads=16` nondeterminism** - either make the reduction order independent of
   the worker assignment, or pin the count in the shipped configs - so the ics55 designs are reproducible
   at the configuration the product actually ships.
3. Only then resume source changes, judged by whether they raise the all-seed count.

## 7. State

- **In the tree**: SR-10, SR-11, SR-21, the round-67 thread-pin fix, the round-70 measurement-directory
  fix. **iEDA-det3 = 83ee2f75** is the current build.
- **Standing**: 5/15 at seed 1000 (reproduced twice); **2/15 on every seed** among the designs measured
  multi-seed.
- **Withdrawn this round**: round 71's "the standing is 5/15" as an established improvement.
- Artifacts: runs/seedtest, runs/seednt1, runs/seedrob, and the per-seed logs.
