# Round 73: the paired multi-seed baseline, and what the modified tree actually buys

## 1. The comparison the objective actually needs

Round 72 established that pass/fail is seed-dependent, so the metric has to be stated over a seed
population. Here is the paired measurement: both binaries, the same five contested designs, seeds
1000-1003, `PL.num_threads` pinned to 1 and `OMP_NUM_THREADS=1`, one flow at a time, the same ruler
against the same legalised reference.

| design | unmodified passing | modified passing | direction |
|---|---|---|---|
| gcd_ics55_a | **0 / 4** | **1 / 4** | improved |
| gcd_nangate45_a | 4 / 4 | 4 / 4 | unchanged |
| s1238_ics55_a | 4 / 4 | 4 / 4 | unchanged |
| s1238_nangate45_a | **1 / 4** | **3 / 4** | improved |
| apb4_timer | **0 / 4** | **2 / 4** | improved |
| **total over 20 (design, seed) cells** | **9** | **14** | **+5** |

Per-seed detail, ratios against the reference:

    gcd_ics55_a        base   union 1.85 2.30 2.50 2.80          (never passes)
                       mod    union 0.80 2.30 1.25 2.10          (passes at seed 1000)
    apb4_timer         base   max   1.250 1.375 1.125 1.375     (never passes)
                       mod    max   1.000 1.250 1.250 1.000     (passes at 1000 and 1003)
    s1238_nangate45_a  base   union/max fail  pass  fail  fail
                       mod    pass pass pass fail
    gcd_nangate45_a    both   4/4, and the reference is 0/0 so any nonzero overflow loses
    s1238_ics55_a      both   4/4

## 2. What this establishes

**On the objective's literal form - designs passing on every measured seed - both trees are at 2/15 and
the change has bought nothing.** That is the honest reading of the strict criterion.

**On the pass-rate form - over the seed population actually measured - the modified tree is ahead by 5 of
20 contested cells**, and the three designs that move are exactly the three the campaign's congestion
changes were aimed at (ics55 and nangate45), not the sky130 ones.

Both readings are true and they answer different questions, which is worth stating because the campaign
has been reporting the single-seed count as though it were a property of the tree. It is not: at seed 1000
the modified tree is 5/15, base is 2/15, and the honest comparison at that seed is 5 against 2. Across four
seeds the same comparison is 14 against 9 cells, and 2 against 2 designs that never lose.

**A design that passes at one seed and fails at another has not been fixed.** gcd_ics55_a is now in that
category where before it was strictly failing; apb4_timer likewise. The correct description of the
campaign's result is "two designs moved from never-passing to sometimes-passing", not "coverage went from
4 to 5".

## 3. Why this round could measure it and earlier rounds could not

Before rounds 67-70 the same seed did not give the same answer, so a per-seed statement was not available
for the modified tree at all, and the campaign's seed-spread numbers were confounded with its own
measurement defect. The instrument now repeats within a batch (14 of 15 designs byte-identical across two
full passes). The residual is the shipped `num_threads=16` on the four ics55 designs, whose
`schedule(dynamic)` regions make the reduction order follow machine load; pinning the count removes it.

## 4. What to do with the objective

The objective as written - "on the 15 designs, every design and every measurable dimension no worse than
Innovus" - is only decidable with a seed population. Recommended form, which this round's data supports:

    primary   number of designs passing on EVERY seed of a fixed seed set (robustness)
    secondary total passing (design, seed) cells over that set (rate)
    baseline, unmodified tree, measured in the same form and in the same batch

Under that form the current state is: **primary 2/15, secondary 14/20 on the five contested designs for
the modified tree against 9/20 for the unmodified one**, with the sky130 failures and the two
wirelength-failing designs (gcd_sky130_a, s1238_sky130_a, both of whose global placement hits the
2000-iteration cap) still to be re-measured in this form.

## 5. Next

1. Extend both arms to all 15 designs at seeds 1000-1003 to complete the paired table (20 passes per arm
   at these costs; the four big designs dominate).
2. Fix the shipped `num_threads=16` nondeterminism so ics55 is reproducible at its shipped configuration.
3. Resume source changes, judged on the primary metric, with the cheapest remaining targets being the
   one-bin design s38584_nangate45_a and the peak-only failures salsa20_ics55_a and salsa20_nangate45_a.
