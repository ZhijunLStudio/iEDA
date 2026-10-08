# Round 75: a real defect in the guard, a correct fix, and why it must be withdrawn

## 1. The target

Round 74 identified two designs one step from the primary criterion: `apb4_timer` needed **one overflow
bin** of peak at seed 1002 (max 17 against a reference 16), and `salsa20_ics55_a` needed eight bins at
seed 1000. Either would take the primary count from 2/15 to 3/15.

## 2. The defect, found by reading the guard's own decisions

Re-running the blocking cell and reading its log:

    apb4_timer, seed 1002
    [SR-11] detail placement kept: peak 18 -> 18, total overflow 1652 -> 2060
    [SR-11] detail placement kept: peak 18 -> 17, total overflow 2060 -> 2031
    [SR-21] pass 2/2: peak 18 total 2024 | best is pass 1 at peak 17 total 2031
    -> final max 17

The first line is the defect. The guard's rule is "revert when the peak got worse AND the total did not
improve". That leaves **no branch for "the peak did not change and the total got worse"** - a strictly
dominated move, worse on one scored dimension and no better on the other - and it was accepted. Detail
placement left the peak at 18 and raised total overflow by 25% (1652 -> 2060), and that result became the
state the finishing passes went on to search from.

## 3. Two fixes, both measured on the full 60-cell instrument

**SR-23** - revert whenever the result is not better in peak-then-total order (the same order the
finishing passes use to pick their best pass, so it also makes the two decision points consistent).

**SR-24** - revert only the strictly dominated case (same peak, worse total), leaving the original branch
intact.

The reason for two: the first version also forbids "peak worse, total better", and the finishing passes
depend on that. Their keep-best search is explicitly designed for a non-monotone trajectory, and on
gcd_ics55_a the winning sequence is peak 3 -> 6 -> 2 with the total improving at the middle step. A
pre-screen confirmed it: SR-23 turned gcd_ics55_a's only passing seed back into a failure.

Full paired measurement, both arms at seeds 1000-1003, `num_threads=1`, `OMP_NUM_THREADS=1`:

| arm | primary (every seed) | secondary (of 60) | transitions from the current tree |
|---|---|---|---|
| unmodified | 2/15 | 12/60 | 5 gates lost |
| **current tree** | **2/15** | **17/60** | - |
| SR-23 | 2/15 | **16/60** | +1 (salsa20_ics55_a@1000), -2 (gcd_ics55_a@1000, salsa20_ics55_a@1003) |
| SR-24 | 2/15 | **16/60** | -1 (salsa20_ics55_a@1003) |

**Both are net losses.** Neither raises the primary count, and both turn a currently passing cell into a
failure (salsa20_ics55_a@1003, max 35 -> 38), which the objective's rule forbids outright.

**Both withdrawn.** The source is reverted and the tree is restored **byte for byte** to the round-74
build: `build/bin/iEDA` md5 `83ee2f75`, identical to `iEDA-det3`.

## 4. Why a locally correct rule is globally wrong here

The guard does not stand alone. It decides the state that `SR-21`'s keep-best search then traverses, and
that search is deliberately non-monotone. Rejecting a move that is locally dominated removes a state from
the explored path, and on salsa20_ics55_a that path was the one that reached the passing value: with the
dominated move rejected the search ends at peak 38 instead of 35.

So "never accept a dominated move" is true about a single decision and false about the system. A guard
inside a trajectory search cannot be validated by reasoning about the guard.

## 5. The finding that matters more: the target is inside the noise

While pre-screening, `apb4_timer` at seed 1002 produced **max 16 (pass)**. In the full sweep the same
configuration produced **max 18**. I checked the obvious explanations and they are excluded:

- the two pinned placer configs are **byte-identical** (`diff` on the pretty-printed JSON);
- same binary, same seed, same command sequence, same ruler, same reference;
- three further sequential repeats all give 18, so it is not simply a warm/cold first run.

That is the residual nondeterminism of round 70 reappearing, at **±1-2 bins**, which is exactly the size
of the target I was aiming at. Two consequences:

1. **`apb4_timer`'s one-bin gap cannot be used as a target or as evidence.** A cell that reads 16 or 18
   depending on the run cannot show whether a change closed a one-bin gap.
2. `salsa20_ics55_a`'s failing seed **moves** (1000 under the current tree, 1003 under SR-23), so the
   "eight bins at seed 1000" framing was also an artifact of which seed happened to be worst.

## 6. What this means for the objective

The primary criterion needs a design to pass on **every** seed, and the cell-level resolution of the
instrument is currently a few bins. The remaining near-miss designs are inside that resolution, so **no
guard-level or bin-level change can be credited or rejected reliably** until the residual is removed. The
large failures (aes 1.36x/1.78x, gcd_sky130_a 2.0-2.2x, picorv32 1.45x/1.61x and the rest of the eight
that never pass) are far outside it and remain the honest target.

**Next work item is therefore the instrument, not the guards:** eliminate the residual nondeterminism.
The diagnosed candidates are the float accumulations in `GridManager::evalRouteUtil` (two float sums
inside `omp critical`, order following thread interleaving, and dead code) and
`BinGrid::evalRouteDem`/`evalRouteCap` (`omp atomic` float accumulation over a `schedule(dynamic)`
loop feeding `h_util`, which the directional reweighting reads at every congestion-effort level), plus
the shipped `num_threads=16` on the four ics55 designs.

## 7. State

- **Tree**: restored byte-for-byte to `iEDA-det3` = `83ee2f75`; nothing from this round is in the tree.
- **Withdrawn with measured reasons**: SR-23 and SR-24 (section 3).
- **Kept**: the finding that the guard accepts strictly dominated moves (confirmed, unfixed by choice - the
  minimal fix is measured to be harmful); the demonstration that a one-bin target sits inside the
  instrument's residual.
- **Instrument**: 240 cells now on disk (base, cur, sr23, sr24) in `runs/seedcells/`, with
  `rsi/harness/multi_seed_sweep.py` arm-agnostic and its summary bug fixed (it assumed two arms).
- **Baseline to beat** (unchanged): primary 2/15, secondary 17/60 for the current tree; 2/15 and 12/60 for
  the unmodified tree.
