# Round 96: SR-28 accepted - the tree advances to a configuration that dominates SR-26

## 1. The measurement

SR-28's sequential validation completed, 44/44 cells, one flow at a time, flock-protected, alongside the
round-91 current-tree arm so the comparison is paired in one protocol.

| design | current tree | SR-26 | SR-28 |
|---|---|---|---|
| gcd_nangate45_a | PPPP 4/4 | PPPP 4/4 | PPPP 4/4 |
| s1238_ics55_a | PPPP 4/4 | PPPP 4/4 | PPPP 4/4 |
| salsa20_ics55_a | ..PP 2/4 | PPPP 4/4 | PPPP 4/4 |
| s1238_nangate45_a | PPP. 3/4 | PPP. 3/4 | PPP. 3/4 |
| gcd_sky130_a | .P.. 1/4 | P.PP 3/4 | P.PP 3/4 |
| **s1238_sky130_a** | .... 0/4 | P.P. 2/4 | **P.PP 3/4** |
| gcd_ics55_a | .... 0/4 | P..P 2/4 | P..P 2/4 |
| apb4_timer | P... 1/4 | ..P. 1/4 | ..P. 1/4 |
| s38584_ics55_a | .... 0/4 | ...P 1/4 | ...P 1/4 |
| s38584_nangate45_a | .... 0/4 | P... 1/4 | P... 1/4 |
| s1238 | .... 0/4 | .... 0/4 | .... 0/4 |

    primary    current 2/15  ->  SR-28 3/15      (SR-26 also 3/15)
    secondary  current 15/44 ->  SR-28 26/44     (SR-26 25/44)

    SR-28 vs current tree: 13 cell gains, 2 cell swaps, 1 design gain, 0 design regressions
    SR-28 vs SR-26:        1 cell gain (s1238_sky130_a@1003), 0 losses

**SR-28 strictly dominates SR-26** on the paired cells: same primary, one more passing cell, no cell lost.
So SR-28 is accepted and supersedes SR-26 in the tree, on the same rule SR-26 was accepted under.

## 2. What SR-28 is

SR-26's gated global-placement refinement with the segment schedule changed: segments 1-4 of 6 still
re-linearise at congestion effort 4, and **segments 5-6 re-linearise at the default effort 0** - a plain
re-linearise followed by one legalisation and one detail placement, at the cheap end because effort 0 does
not call the evaluator inside the Nesterov loop. The gate is unchanged: a segment is kept only if it is no
worse than the entry on either scored number and better on at least one, so adding candidates cannot make
the result worse than the entry.

The extra segments rarely win - in almost every cell the chosen best is one of the effort-4 segments - and
that is why the difference from SR-26 is one cell rather than a redesign. The one cell it wins is
`s1238_sky130_a` seed 1003.

## 3. Tree state

`build/bin/iEDA` rebuilt from the SR-28 source and it reproduces the measured binary exactly:

    build/bin/iEDA      48cd5be3770072811bf1feb6d95cdae2
    build/bin/iEDA-sr28 48cd5be3770072811bf1feb6d95cdae2
    build/bin/iEDA-sr26 f6f811931b470ee68e05767bb1528446   (superseded, kept)

## 4. The verdict tool now takes the arm from the command line

`paired_sequential_verdict.py` had the subject arm hardcoded, so asking it about any arm but SR-26 crashed
- and, worse, would have compared the wrong pair silently if the hardcoding had been in the arithmetic
rather than in a lookup. It now takes `--arms` and `--subject`, always treats `cur` as the baseline, and
refuses a verdict when an arm is empty or the arms differ in which cells are measured. Verified on both
pairs:

    cur vs sr28 : ACCEPT, primary 2 -> 3, secondary 15 -> 26
    cur vs sr26 : ACCEPT, primary 2 -> 3, secondary 15 -> 25

## 5. State and what remains

- **Tree**: SR-28, `build/bin/iEDA` = `48cd5be3`; the validated configuration.
- **Accepted result (paired, sequential, multi-seed)**: primary **2/15 -> 3/15**, secondary
  **15/44 -> 26/44**, 0 design-level regressions.
- **Objective**: 3/15 against 15/15. One round left.
- **Open**: twelve designs do not pass every seed; timing measurable on only 7 of 15; the refinement's cost;
  and the unmodified arm has still not been re-taken sequentially.
