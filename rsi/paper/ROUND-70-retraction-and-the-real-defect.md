# Round 70: retraction of the round-69 race claim, and the defect that was actually there

## 1. Retraction first

Round 69 reported that `WAWirelengthGradient` races because the gradient loop is parallel over nets while
the storage is indexed by pin, so a pin shared by several nets would be written concurrently.

**That is wrong and is withdrawn.** `ipl::Node` holds a single `NetWork* _network` and `set_network()`
is called once per pin, so each pin belongs to exactly one network and appears exactly once in the
network list the loop iterates. Each slot has exactly one writer at any thread count. The code I quoted
(lines 417 and 436) is not a race. I inferred it from the shape of the loop instead of checking the
data model, which is the specific error this campaign has a rule against.

## 2. Localisation, done properly this time

Three repeats per condition, comparing the placement DEF, on the fixed binary:

| design | pipeline | OMP=1 | OMP=4 |
|---|---|---|---|
| gcd_sky130_a | GP+LG | f598a996 x3 | f598a996 x3 - **identical across thread counts** |
| gcd_sky130_a | GP+LG+DP | 0d4aa4d9 x3 | 16c8c4d0 x3 - **differs across thread counts** |
| gcd_ics55_a | GP+LG | bc6187d0 x3 | bc6187d0 x3 - identical across thread counts |

**Global placement and legalisation are a function of their inputs, at any thread count. The variation
enters at detail placement.** That is consistent with what is in the tree: the modified `runDP` is the
only stage that calls the congestion evaluator, and the unmodified tree is byte-reproducible precisely
because it does not.

## 3. The defect that was actually there

Found in the guard's own decisions. The same input placement is reported with two different totals:

    run A   [SR-11] detail placement kept: peak overflow 3 -> 6, total overflow 35 -> 27
    run B   [SR-11] detail placement kept: peak overflow 3 -> 6, total overflow 35 -> 22
    run C   [SR-11] detail placement kept: peak overflow 3 -> 6, total overflow 35 -> 27

Same "before" (35), same peak (6), different "after". The guard compares those numbers, so its decision -
and therefore the placement iEDA writes - depends on the run rather than on the input.

**Mechanism.** The in-process trial route writes one `overflow_map_<layer>.csv` and one
`net_map_<layer>.csv` per routing layer into `<output>/rt/rt_temp_directory/early_router`, and
`evalproCongestion` then builds the numbers by **reading those files back**:

    congestion_api.cpp     egrMap(stage)  -> evalUnionEGR(stage, rt_dir_path)
    congestion_eval.cpp    evalUnionEGR   -> evalEGR(rt_dir_path, "union", "place_egr_union_overflow.csv")
                           evalEGR        -> reads overflow_map_<layer>.csv from rt_dir_path

The directory is reused for every measurement in the process and is never cleared. A layer file left by
an earlier measurement - a layer the current route did not rewrite, or one left by a previous design in
the same working directory - is read as though it described the current placement. That is exactly the
"measurement of a byte-identical DEF differs between directories" observation recorded in round 66 and
dismissed there as being about the wrong files; it was the measurement's own input.

**Fix.** Clear that directory before each in-process measurement, so the measurement is a function of the
placement alone (`PLAPI::notifyPLCongestionInfo`). Built as **iEDA-det3 = 83ee2f75**.

## 4. What the fix achieves, measured

| condition | before the fix | after the fix |
|---|---|---|
| gcd_ics55_a, 3 sequential runs, OMP=1 | 2 of 3 differed | **3 of 3 identical** |
| gcd_sky130_a, 3 sequential runs, OMP=1 | 2 differed across sessions | **3 of 3 identical** |
| 3 different designs concurrent, run twice, OMP=1 | differed | **byte-identical between the two runs** (gcd_ics55_a fbf93633, s1238_ics55_a 5159608f, s38584_ics55_a 37275346) |
| gcd_ics55_a alone compared with gcd_ics55_a inside a 3-design concurrent run | differed (union 17 vs 37) | same value within a session |

Reproducibility **within a session is now achieved, including under concurrency with different designs
in flight**. That is the property an A/B comparison needs, and it is a real improvement over rounds 67-69.

## 5. What is still not achieved, stated plainly

**A residual variation between sessions remains.** The same three-design concurrent set produced
gcd_ics55_a at union 16 in one session and union 18 in another, each reproducing exactly within its own
session. Thread count still changes the result as well (gcd_sky130_a DP gives 0d4aa4d9 at OMP=1 and
16c8c4d0 at OMP=4), which is expected for any algorithm whose reductions are order dependent, but it
means the standing is only valid at a pinned thread count.

So: the tree is reproducible **within a batch** now, which is the condition the campaign's iron rule
requires; it is not yet reproducible **between batches**, which is the condition its conclusion needs.
That residual is not identified and is not guessed at here.

## 6. State

- **In the tree**: SR-10, SR-11, SR-21, the round-67 thread-pin fix, and the round-70 measurement-directory
  fix. Binaries: iEDA-base c9761dc9, iEDA-ctl16 f9581627, iEDA-sr21 62f55d58, iEDA-det2 74899997,
  **iEDA-det3 83ee2f75 (current)**.
- **Withdrawn this round**: the round-69 race claim, as a false mechanism.
- **Standing**: unchanged at 4/15 until measured on iEDA-det3; the round-69 table was measured on iEDA-det2
  and must be re-taken.
- **Next**: (1) re-take the 15-design standing on iEDA-det3 under the adopted protocol; (2) chase the
  cross-session residual; (3) then re-adjudicate SR-11 and SR-21 on an instrument that repeats within a
  batch, and resume improving the objective.
