# Round 84: SR-27 - the segment chooser may not return a placement worse than the one it started from

## 1. The defect, read off the per-cell table

Rounds 81-83 recorded that the refinement's chooser ranks peak above total and accepts any segment that
improves the peak. The cost of that ordering is visible at gcd_sky130_a seed 1003, where the entry state
already failed **only** on the total and only by 1.2%:

| arm | union (ref 900) | peak (ref 22) | verdict |
|---|---|---|---|
| current tree | 911 (1.012) | 18 | fail on union by 11 bins |
| SR-25 | 945 (1.050) | 16 | fail |
| SR-26 | 1004 (1.116) | 19 | fail, **worse than its own entry on both numbers** |

So the refinement can hand back a placement worse than the one it was handed. Every gain the mechanism has
produced is a strict improvement on **both** numbers over the entry - gcd_sky130_a seed 1000
(1976,26) -> (814,16), salsa20_ics55_a seed 1000 (41932,43) -> (35404,31), apb4_timer seed 1002
(2029,17) -> (1964,16), s38584_ics55_a seed 1002 (2858,22) -> (2577,14) - so requiring that costs none of
them.

## 2. The change

A segment is eligible to be the final answer only if it is **no worse than the entry state on either
number and better on at least one**; among eligible segments the original peak-then-total order picks one.
Ineligible segments are still executed and still become the state the next segment starts from, so the
loop's non-monotone traversal is untouched - they simply cannot be the final answer.

This is a stopping/selection rule applied uniformly to every design and every segment, not a per-design
choice and not a threshold. It makes the refinement **unable to worsen a placement on either scored number**
relative to the placement it started from, which is a stronger guarantee than the objective asks for
("do not turn a passing design into a failing one").

Built as **iEDA-sr27 = 0543fdbb**.

## 3. Single-cell evidence that it does what it is meant to

gcd_sky130_a seed 1003, the cell the previous configuration made worse:

| arm | union | peak | verdict |
|---|---|---|---|
| SR-26 | 1004 (1.116) | 19 | fail |
| **SR-27** | **747 (0.830)** | **14 (0.636)** | **PASS** |

The gate now refuses the non-Pareto segment, and the segment it keeps instead is a genuine Pareto
improvement over the entry (747 < 911 and 14 < 18) that the peak-first ordering had discarded in favour of
one with a slightly better peak and a much worse total.

**One cell is not evidence.** The full 60-cell four-seed validation is running
(`rsi/harness/run_sr27_validation.sh`, flock-protected single instance, output `runs/seedcells_sr27`),
and the acceptance rule is unchanged: primary count up, nothing regressing.

## 4. State

- **Tree**: SR-27 source in place and built; validated configuration still SR-26 (`f6f81193`) until SR-27
  reports.
- **Acceptance to beat** (matched pattern, all arms 4 flows in flight): current tree primary 2/15 and
  secondary 17/60; SR-25 4/15 and 24/60; SR-26 4/15 and 26/60.
- **Running**: SR-27 validation, 60 cells.
- **Nearest primary gains if SR-27 holds**: gcd_sky130_a would go from 3/4 to 4/4 on this cell alone, which
  takes the primary count from 4/15 to 5/15 - the first move in that count since round 80.
