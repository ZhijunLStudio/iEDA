# Round 94: tree hygiene again, and SR-28's interim result

## 1. The tree was holding an unvalidated candidate

Building SR-28 overwrote `build/bin/iEDA`, so the tree's binary became `48cd5be3` (SR-28) while the
**validated** configuration is SR-26 (`f6f81193`, accepted in round 91 under the paired sequential
protocol with primary 2/15 -> 3/15). A reader of the tree would again find an unmeasured configuration
where a measured one is claimed - the same state-hygiene error as round 82.

Restored: `src/operation/iPL/api/PLAPI.cc` and `ipl_io.cpp` back to the SR-26 commit, rebuilt, and the
result reproduces the validated binary exactly:

    build/bin/iEDA       f6f811931b470ee68e05767bb1528446
    build/bin/iEDA-sr26  f6f811931b470ee68e05767bb1528446
    build/bin/iEDA-sr28  48cd5be3770072811bf1feb6d95cdae2   (kept as a candidate)

The SR-28 validation is unaffected because it uses the saved `iEDA-sr28`.

## 2. SR-28's interim result: one cell better than SR-26, no losses

32 of 44 cells measured for all three arms. On exactly those 32 cells:

| arm | passing cells |
|---|---|
| current tree | 13 |
| SR-26 | 19 |
| **SR-28** | **20** |

**Exactly one verdict flip against SR-26, and it is a gain:**

    s1238_sky130_a seed 1003     SR-26 (1443, 26) fail  ->  SR-28 (1540, 26) PASS

with per-design marks (four seeds in order):

    s1238_sky130_a   cur ....   sr26 P.P.   sr28 P.PP

So SR-28 takes s1238_sky130_a from two seeds to three. It is still not an all-seed design (seed 1001
fails), so this is a cell gain rather than a primary gain - the same shape as SR-25 -> SR-26, which was
accepted on exactly that basis.

**Why the extra segments only rarely win:** in almost every cell the chosen best is one of segments 1-4
(the effort-4 ones), and the effort-0 segments 5-6 are correctly not chosen - e.g. on one cell the steered
segments reached peak 14 and the subsequent effort-0 segment gave peak 20, which the gate rejected. That is
the expected behaviour and it is why the difference between SR-26 and SR-28 is one cell rather than a
redesign.

## 3. What round 93 established, restated because it bounds what is left

    congestion-steered GP as a whole-run objective      -> worse (measured: s5378 union 1.518x -> 1.625x, s1238 1.124x -> 1.182x)
    congestion-steered GP as a bounded gated refinement -> better (SR-26, +1 all-seed design)
    a cheap non-steered refinement added to it          -> +1 cell so far (SR-28, pending the last 12)

and the never-passing designs' deficit is 21-201% on union with no measured mechanism that moves it.

## 4. State

- **Tree**: SR-26, `build/bin/iEDA` = `f6f81193`.
- **Accepted result**: primary 2/15 -> 3/15, secondary 15/44 -> 25/44, 0 design-level regressions.
- **Running**: SR-28 sequential validation at 32/44, wrapper `rsi/harness/run_sr28_validation.sh`,
  records `runs/seedcells_seq_sr28`.
- **Candidates not in the tree**: sr23, sr24, sr27 (withdrawn with measured reasons), sr28 (pending).
- **Objective**: 3/15 against 15/15, two rounds left.
