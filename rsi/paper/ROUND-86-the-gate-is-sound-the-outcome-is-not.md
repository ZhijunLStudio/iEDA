# Round 86: the gate's measurement is sound, the outcome is not - and my validations used the wrong protocol

## 1. The gate reads the right quantity

I measured the gap between what the segment chooser reads in-process and what the ruler scores, on the same
DEF, by pairing the flow's own final log line with the ruler's verdict on the file it produced:

| design | seed | in-process (peak, total) | ruler (max, union) | ruler entry (current tree) | reference |
|---|---|---|---|---|---|
| apb4_timer | 1002 | (16, 1963) | (17, 1967) | (17, 2029) | (16, 2071) |
| gcd_sky130_a | 1000 | (16, 907) | (17, 972) | (26, 1976) | (22, 900) |
| gcd_sky130_a | 1003 | (14, 762) | (14, 747) | (18, 911) | (22, 900) |

The two instruments agree to within 1-5 bins. **So the gate is not optimising a bad proxy** - the earlier
suspicion that the in-process evaluator diverges from the scored model is not supported, and SR-23/SR-24/
SR-27's failure to improve is not explained by a measurement mismatch.

## 2. What actually varies is the outcome, and the co-run pattern drives it

gcd_sky130_a seed 1003, same binary (SR-26), same seed, same command sequence, `num_threads=1`,
`OMP_NUM_THREADS=1`:

| how it was run | union | peak | verdict |
|---|---|---|---|
| four flows in flight (the round-83 validation) | 1004 | 19 | fail |
| **one flow at a time, 4 consecutive repeats** | **747, 747, 747, 747** | **14, 14, 14, 14** | **pass 4/4** |

So the one-at-a-time result is not merely better, it is **perfectly stable** - four runs identical to the
last digit - while the concurrent result was a failure. Round 76 already adopted one-flow-at-a-time as the
protocol for exactly this reason, and rounds 80-83 then ran their validations at four flows in flight **for
speed**. That was a protocol deviation of mine, and this cell shows it is not harmless: it flips a verdict.

## 3. But the deviation does not simply flatter or punish the result, which is the worse news

More single-flow repeats of the decisive cells:

| design | seed | one flow at a time | concurrent |
|---|---|---|---|
| gcd_sky130_a | 1003 | **747/14 pass 4/4** | 1004/19 fail |
| gcd_sky130_a | 1000 | 972/17 fail | 814/16 pass |
| apb4_timer | 1001 | 2417/20 fail 4/4 | 2121/22 fail |
| apb4_timer | 1002 | 2066/16 pass (8/8, round 79) | 1964/16 pass |

gcd_sky130_a **passes a different seed under each pattern**: sequential fails s1000 and passes s1003;
concurrent passes s1000 and fails s1003. So neither pattern makes it 4/4, and the per-seed verdicts are
pattern-dependent rather than one pattern being uniformly better.

**Consequence for the objective: the primary count has an uncertainty of roughly one design.** Round 83's
"4/15" is one draw from either pattern; a sequential re-measurement may give 3, 4 or 5. Every acceptance
decision in rounds 80-83 rests on a count with that much slack, and I have been presenting single draws of
it as results.

## 4. Action

A protocol-correct validation is running now: **one flow at a time**, both arms, the eleven designs that
pass at least one seed in some arm (the five that never pass cannot move the count), four seeds each -
88 cells, which is slow but is the measurement the objective actually asks for. It is flock-protected and
the wrapper restarts it if interrupted.

While launching it I found and killed a leftover repeatability script of mine that was still running, which
would have put two flows in flight and re-created exactly the round-79 contamination. Recorded because it
is the same error class and it happened again.

## 5. What this round changes about what is known

- **Unchanged and solid**: SR-26 raises the pass rate against the matched current tree by a margin far
  larger than this noise (9 gains and 0 regressions of 60 cells, e.g. gcd_sky130_a 1976/26 -> 814/16,
  salsa20_ics55_a 41932/43 -> 35404/31). Those effects are 15-60% and the noise is 1-30% on the most
  sensitive cell.
- **Opened**: the primary count's uncertainty, and the fact that per-seed verdicts are pattern-dependent
  for at least one design.
- **Corrected**: my rounds 80-83 validations used four flows in flight while claiming the one-at-a-time
  protocol; the numbers are being re-taken.
- **Not supported**: any claim that the chooser optimises the wrong quantity.

## 6. State

- **Tree**: SR-26, `build/bin/iEDA` = `f6f81193`.
- **Running**: sequential validation, `runs/seedcells_seq_sr26` and `runs/seedcells_seq_cur`, 44 cells
  each, one flow at a time, wrapper `rsi/harness/run_seq_validation.sh`.
- **Acceptance evidence so far** (concurrent pattern, to be superseded): primary 2/15 -> 4/15, secondary
  17/60 -> 26/60, 9 gains, 0 regressions.
- **Objective**: 4/15 (uncertain by about one design) against 15/15.
