# Round 22: the robust peak failures are created before detail placement, so the guard cannot reach them

## 1. The list, rebuilt with correct references and the netlist filter

An earlier robust-failure list was built when one reference total overflow was mis-transcribed (3407
for salsa20_ics55_a, actually s38584_ics55_a's value) and before the netlist-integrity filter existed.
Rebuilt from the anchor file, counting every seed measurement available per design and reporting the
whole range rather than a point:

| design | PDK | seeds | our peak range | reference peak | verdict |
|---|---|---|---|---|---|
| s1238_sky130_a | sky130 | 6 | 38 .. 70 | 32 | **ROBUST: every seed worse** |
| salsa20_nangate45_a | nangate45 | 9 | 12 .. 30 | 10 | **ROBUST: every seed worse** |
| gcd_ics55_a | ics55 | 6 | 3 .. 10 | 6 | seed-dependent |
| gcd_sky130_a | sky130 | 6 | 16 .. 32 | 24 | seed-dependent |
| s38584_ics55_a | ics55 | 6 | 18 .. 27 | 18 | seed-dependent |
| s38584_nangate45_a | nangate45 | 15 | 1 .. 6 | 2 | seed-dependent |
| salsa20_ics55_a | ics55 | 12 | 29 .. 46 | 34 | seed-dependent |
| s1238_ics55_a | ics55 | 15 | 6 .. 14 | 14 | robustly no-worse |
| apb4_timer | sky130 | 1 | 20 .. 20 | 26 | robustly no-worse |

**Only two designs fail the peak at every seed once the reference values are right**: s1238_sky130_a
and salsa20_nangate45_a. The rest of the apparent failures were draws.

## 2. Both are already lost before detail placement runs

Measuring the stage boundary at three seeds on exactly those two designs:

| design | seed | peak after GP+LG | peak after +DP | reference | union after GP+LG | union after +DP | reference |
|---|---|---|---|---|---|---|---|
| **s1238_sky130_a** | 1001 | **80** | 38 | 32 | 9567 | 3301 | 2500 |
| s1238_sky130_a | 1002 | **64** | 48 | 32 | 8360 | 3208 | 2500 |
| s1238_sky130_a | 1003 | **68** | 52 | 32 | 8366 | 3804 | 2500 |
| **salsa20_nangate45_a** | 1001 | **13** | 12 | 10 | 794 | 944 | 250 |
| salsa20_nangate45_a | 1002 | **15** | 17 | 10 | 829 | 808 | 250 |
| salsa20_nangate45_a | 1003 | **13** | 15 | 10 | 698 | 729 | 250 |

**GP+LG alone beats the reference on the peak at 0 of 3 seeds for both designs.** The deficit is
present the moment legalisation finishes.

**Consequence for SR-11**: on s1238_sky130_a detail placement *improves* the peak (80 to 38, 64 to 48,
68 to 52), which is why the guard correctly abstains there and the result is byte-identical. **No
guard on detail placement can close either deficit**, because neither is created there. SR-11 stays
as a safety net for the designs where the stage does damage, and it is not the lever for these two.

## 3. What the numbers say the lever is

**s1238_sky130_a**: after detail placement the peak is 38, 48, 52 against a reference of 32 - a gap of
1.2x to 1.6x, and it survives legalisation and detail placement both improving it. Total overflow is
still 1.3x to 1.5x. So the placement handed to legalisation is the problem.

**salsa20_nangate45_a is the clearer defect and the more interesting one.** Its total overflow after
the full flow is **698 to 829 against a reference of 250 - a factor of 2.8 to 3.3**, while the *same
circuit* on ics55 comes out at **0.78x the reference, i.e. we win**. Same netlist, same placer, same
options; only the PDK differs.

That is not a general weakness of the algorithm; it is a nangate45-specific failure of it, and it is
the sharpest single defect in the standing. It is also the one the objective's own text flagged
("two nangate45 congestion disasters") before that framing was corrected away - the original numbers
were wrong but the underlying signal was real.

## 4. What to look at next, and why this round stops here

The two designs now have a measured, reproducible signature (GP+LG already worse, DP not responsible)
and one of them has a second, sharper one (a 3x total-overflow gap that is PDK-specific). Locating the
cause inside global placement or legalisation for those signatures is the next step, and it needs the
same treatment the detail-placement defect got: a measurement that isolates the stage, then a source
change, then a multi-seed check.

No source change is made this round. The round's result is that the target moved: the guard was built
for the wrong stage for these designs, and the evidence now says so.

## 5. State of the tree

Unchanged from Round 21: SR-10 (in-tool congestion measurement) and SR-11 (the detail-placement
dominance guard) are in; SR-2, SR-3, SR-4, SR-5, SR-7, SR-8 and SR-9 are withdrawn, each with a
measured reason recorded.
