# Round 95: the final state is recorded, and SR-28 is one cell ahead of SR-26 with three cells to go

## 1. The durable deliverable

`rsi/paper/FINAL-STATE.md` (122 lines) now records the corrected end state, and `HANDOVER.md` points at it
from its first line. It states:

- **the objective is not met**: the measured count is **2/15 unmodified, 3/15 with the current tree**, not the
  "3 -> 4 -> 5" progression the handover recorded;
- the measurement recipe that makes a number meaningful (one flow at a time, OMP_NUM_THREADS=1, shipped
  placer config, the ruler against the legalised reference, seeds 1000-1003, both arms in one tuple);
- what is actually in the tree (SR-10, SR-11, SR-21, the round-67 thread-pin fix, the round-70
  measurement-directory fix, and the GP gated refinement);
- every change withdrawn by this work with its measured reason (SR-23, SR-24, SR-27, and the
  concurrent-pattern numbers as acceptance evidence);
- what is established about the mechanism;
- the instrument rule - a measurement is identified by (binary, design, seed, co-run pattern, thread
  settings) and every cache or resume path must key on that whole tuple;
- what remains: twelve designs not passing every seed, timing measurable on only 7 of 15, cost, and the
  unmodified arm not yet re-taken sequentially.

## 2. SR-28's interim result, measured on exactly the cells both arms share

41 cells measured in both SR-26 and SR-28:

| | SR-26 | SR-28 |
|---|---|---|
| passing cells | 22 | **23** |
| verdict flips vs SR-26 | - | **1, and it is a gain** |
| all-seed designs among the 10 designs with all 4 cells in both arms | 2 | 2 |

The single flip is `s1238_sky130_a` seed 1003: SR-26 (1443, 26) fail -> SR-28 (1540, 26) pass, taking that
design from two seeds to three, so it is a cell gain and not a primary gain - **the same shape on which
SR-25 -> SR-26 was accepted**.

The eleventh candidate design, `salsa20_ics55_a`, has SR-26 at 4/4 and SR-28 with one cell measured
(passing); its remaining three cells decide whether SR-28's primary stays equal or drops, and they are the
slow ones (~400 s each). So **SR-28's adjudication is not yet possible** and is deferred to the next round.

## 3. Why the extra segments only rarely win

In almost every cell the chosen best is one of segments 1-4 (effort 4) and the effort-0 segments 5-6 are
correctly not chosen - on one cell the steered segments reached peak 14 and the following effort-0 segment
gave peak 20, which the gate rejected. That is the expected behaviour of the design and it is why the
difference between SR-26 and SR-28 is one cell rather than a redesign.

## 4. State

- **Tree**: SR-26, `build/bin/iEDA` = `f6f81193`, the validated configuration.
- **Accepted result**: primary 2/15 -> 3/15, secondary 15/44 -> 25/44, 0 design-level regressions, measured
  sequentially and paired.
- **Running**: SR-28 sequential validation at 41/44, wrapper `rsi/harness/run_sr28_validation.sh`
  (flock-protected, restarts if interrupted), records `runs/seedcells_seq_sr28`.
- **Candidate not in the tree**: `iEDA-sr28` = 48cd5be3, one cell ahead of SR-26 on the shared cells.
- **Objective**: 3/15 against 15/15, two rounds left.
