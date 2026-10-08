# Round 92: the initial-GP effort screen, and the same orchestration error a fourth time

## 1. The screen that was attempted

The never-passing designs fail on **both** congestion dimensions (union 1.21x-3.01x, max 1.09x-1.86x) while
already winning wirelength by 6-28%. SR-26 applies congestion effort 4 on the **finishing** passes,
bounded and gated. The untried variant is effort 4 on the **initial** global placement, so the placement is
congestion-aware from the start.

Screen: the tree binary with `placer_run_gp -mode start ... -congestion_effort 4` followed by accept, LG,
DP, scored by the ruler, one flow at a time, against effort 0 for the same designs and seed.

## 2. What happened

- **The first attempt crashed on a format string** (`e%=%d`) after one cell, so only picorv32 at effort 0
  completed: union 132685 (1.591x), peak 50 (1.389x) against a reference of 83408/36.
- **The relaunch was confounded**: the first screen's process was still running - I had assumed it was
  reaped when my launching shell was - so two screens were writing the same work directories. The second
  screen then found no DEF where the first was still writing one, and aborted.
- Both processes are now killed and verified gone (`pgrep` counts of iEDA and of the screen are both zero).

**This is the fourth time in this campaign that a measurement was confounded by a process I did not know
was running** (rounds 79, 86, 88, and now 92), and the pattern is identical every time: a background launch
whose lifetime I inferred from the shell that started it. The corrective that has worked is a wrapper script
with an `flock`, which is how the validations in rounds 86-91 were run; ad-hoc background launches are the
ones that fail. **I should not launch a measurement any other way from here on.**

## 3. What is known about the variant independently of this screen

The campaign's own record (round 41) measured congestion effort 4 and noted that it **calls the evaluator
inside the Nesterov loop**, making a design take "tens of minutes instead of about one". For an initial
global placement of 2000 iterations that is prohibitive as a default, and the screen's own behaviour is
consistent with it: a single effort-0 picorv32 flow took 397 s with SR-26's refinement included, and the
effort-4 run did not complete in the window.

So the variant is **not economically viable as a default**, and the honest status is: identified as the
mechanism that could address a 21-201% union deficit, unexplored because its cost is prohibitive, and its
screen this round is **inconclusive due to my own orchestration error**, not due to anything about the code.

## 4. The round's substantive result, for the record

Committed separately earlier this round: **SR-26 is accepted under the protocol-correct measurement** -
both arms complete at 44 cells each, one flow at a time, four seeds, giving

    primary   current 2/15  ->  SR-26 3/15
    secondary current 15/44 ->  SR-26 25/44
    design-level gains 1 (salsa20_ics55_a 2/4 -> 4/4)   design-level regressions 0

with 12 cell-level gains against 2 cell swaps that flip no design. That is the first change in this campaign
validated under the stricter protocol to improve the objective's count.

## 5. State

- **Tree**: SR-26, `build/bin/iEDA` = `f6f81193`, unchanged.
- **Accepted result**: primary 2/15 -> 3/15, 0 design regressions, measured sequentially and paired.
- **Objective**: 3/15 against a target of 15/15. The remaining eleven designs split into five that never
  pass (a demand-model deficit of 21-201% on union) and six that miss one or two seeds by 4-20% on one
  dimension.
- **Open, with the reason it is open**: the initial-GP effort-4 variant. Cost-prohibitive as a default,
  screen inconclusive, and the only mechanism identified that targets the never-passing designs' magnitude
  of deficit.
- **Process discipline**: no measurement to be launched except through an `flock`-protected wrapper.

## 6. Next

1. Re-run the initial-GP effort screen properly - wrapper with flock, one design first, and a bounded
   iteration count for the effort-4 arm so the cost is measurable rather than open-ended.
2. If effort 4 on the initial GP closes a large part of the 21-201% union gap on any never-passing design,
   the natural change is the same shape SR-26 already validated: run the initial GP both ways and keep the
   better one by the measured numbers, so the cost is paid once and only where it buys something.
3. Otherwise the remaining rounds are best spent on the six near-miss designs, where the deficit is 4-20%
   on a single dimension rather than a magnitude.
