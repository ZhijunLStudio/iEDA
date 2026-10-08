# Round 6: the timing baseline, and the all-dimension standing

## 1. Outcome in one line

The missing dimension is now measured: on the same static timing analysis, with the same
library and SDC, our placement has better setup timing than the commercial reference on 19 of
24 designs. With that, the campaign has a complete five-dimension standing, and we lead on four
of the five.

## 2. What the goal now asks

The objective was re-scoped from "close the peak-congestion gap" to "match or beat the
reference on every dimension: HPWL, total congestion, peak congestion, and timing". The method
constraints were rewritten around what Round 5 learned - repeat seeds, same-seed pairing,
commit-matched binaries - and the exhausted directions are recorded so they are not retried.

## 3. The timing baseline (new)

Earlier rounds had to write "timing has no reference". Running the project's own timing rung -
iSTA with an HPWL-based pre-route RC model, the same library and SDC for both arms - on both
placements of each design fixes that. What it measures is a placement-versus-placement
comparison under identical analysis, which is exactly what is needed here.

| dimension | n | median ratio | no worse |
|---|---|---|---|
| setup WNS | 24 | **0.789** | 19 / 24 (79%) |
| setup TNS | 19 | **0.551** | 16 / 19 (84%) |

Both WNS and TNS are negative on every design measured, so a ratio below 1 means a smaller
slack deficit, i.e. better timing. Selected values:

| design | our WNS | reference WNS | ratio | our TNS | reference TNS | ratio |
|---|---|---|---|---|---|---|
| gcd_sky130_a | -0.471 | -1.355 | 0.348 | -27.0 | -49.0 | 0.551 |
| s1488_sky130_b | -0.401 | -1.753 | 0.229 | -3.4 | -17.7 | 0.191 |
| s9234_sky130_b | -0.896 | -1.548 | 0.579 | -49.6 | -125.1 | 0.397 |
| aes_core_sky130_b | -5.568 | -8.829 | 0.631 | -15173 | -33268 | 0.456 |
| salsa20_sky130_a | -7.513 | -13.182 | 0.570 | -5510 | -6320 | 0.872 |
| apb4_uart_sky130_b | 2.209 | 1.060 | 2.083 | 0 | 0 | - |

Hold is 0.0 on both arms for every design measured, so hold is a tie rather than a win.

**Coverage and its limits.** 32 designs were attempted; 24 produced a result on both arms, and
all 24 are sky130. The ics55 designs fail while reading the LEF and the nangate45 designs crash
the timing tool with a Tcl stack trace - both are iSTA and PDK issues that arise on our
placement and the reference's alike, so they are a coverage limit of this measurement, not a
result about either placement. Timing on those two PDKs is not yet measured and is not claimed.

The measurement is also single-seed, like everything else in Rounds 1-4, so the counts carry
seed uncertainty. The margins here are large (median 0.79 and 0.55 with a third of designs below
0.5), so the direction is likely to survive repeats, but that has to be shown rather than
assumed.

## 4. The all-dimension standing

Ratio is ours over the reference; below 1 is better on every row.

| dimension | n | median ratio | no worse |
|---|---|---|---|
| HPWL | 32 | **0.924** | 25 / 32 (78%) |
| EGR union | 32 | **0.835** | 20 / 32 (62%) |
| **EGR max** | 32 | **1.358** | **5 / 32 (16%)** |
| setup WNS | 24 | **0.789** | 19 / 24 (79%) |
| setup TNS | 19 | **0.551** | 16 / 19 (84%) |

**We lead on four of five dimensions. Peak congestion is the only one we lose.** Only one design
is no-worse on all five (apb4_timer: 0.84 / 0.36 / 0.77 / 0.87 / 0.88), and five are no-worse on
the three placement dimensions. So the re-scoped objective is now a narrow, well-posed problem:
fix the peak without giving back wirelength, total congestion or timing.

## 5. The peak loss is a trade, not a pure loss

Looking at the designs where we lose on the peak, alongside the dimensions we win:

| design | EGR max | HPWL | EGR union | WNS | TNS |
|---|---|---|---|---|---|
| s1238_sky130_a | 2.19 | 1.09 | 1.51 | 0.85 | 0.62 |
| s1488_sky130_b | 1.88 | **0.80** | 1.40 | **0.23** | **0.19** |
| picorv32 | 1.85 | **0.80** | 0.75 | 0.99 | 0.95 |
| aes_core_sky130_b | 1.65 | 1.10 | 1.32 | **0.63** | **0.46** |
| apb4_clint_sky130_b | 1.50 | 0.93 | 1.16 | 0.95 | - |
| salsa20_sky130_a | 1.50 | 1.37 | 1.36 | **0.57** | - |

On several of these the placement is substantially better on wirelength or timing while being
worse at the worst routing spot. That is consistent with everything measured since Round 1: our
placer is more willing than the reference to concentrate cells, which buys wirelength and timing
and costs peak routability. It also means a fix for the peak has to be judged against what it
takes back from the other four rows, and that the right frame is the per-design trade, not a
single number.

## 6. What this changes about the search

The peak is the only remaining target, and Rounds 1-5 have excluded: density-penalty magnitude
and floor, global-placement iteration budget, density-grid resolution, the network-flow spread
stage, detail-placement re-clustering, the density-penalty ramp schedule, and the
congestion-aware wirelength levels as a blanket improvement (they behave as a conditional
repair). Two individually-positive changes combine destructively.

What is left, and consistent with the evidence, is that the peak is a property of the demand
the nets place on the router rather than of where the cells sit - the net-demand measurement
showed 1.85x the reference's peak demand on 30 of 30 designs, and no cell-distribution lever
moved the peak. The untested levers are therefore in how the nets are shaped: net weighting, or
a demand term in the objective that is active only where demand exceeds capacity, which is the
one form the level-2 result suggests actually helps (it helped where congestion was bad and was
neutral where it was not).

## 7. Next round, in order

1. **Repeat seeds on the standing**, both arms, so that the four wins and the one loss are
   distributions rather than point estimates. This is required by the goal's method clause and
   is the precondition for any claim about the peak.
2. **Net weighting**, evaluated with seeds from the start: weight nets by the demand they put
   through currently-over-capacity regions, which is the algorithmic form of what level 2 does
   through a bounding-box artefact.
3. Extend timing coverage to ics55 and nangate45 if the iSTA failures are addressable; until
   then those PDKs are unmeasured on timing and must be reported that way.

## 8. Addendum: the peak deficit under repeated seeds

The standing in section 4 was single-seed per design. Measuring our placement at four seeds and
comparing the whole range against the reference's single value separates a real deficit from a
lucky or unlucky draw. Nine designs had completed all four seeds at the time of writing:

| design | our peak, 4 seeds | reference | verdict |
|---|---|---|---|
| gcd_nangate45_a | 0 .. 0 | 0 | robustly no-worse |
| s1238_ics55_a | 11 .. 14 | 14 | robustly no-worse |
| gcd_ics55_a | 3 .. 10 | 6 | seed-dependent |
| gcd_sky130_a | 16 .. 32 | 24 | seed-dependent |
| s1238_nangate45_a | 0 .. 2 | 0 | seed-dependent |
| **s1238_sky130_a** | **38 .. 70** | **32** | **robustly worse on all four seeds** |
| **salsa20_ics55_a** | **40 .. 46** | **34** | **robustly worse on all four seeds** |
| **salsa20_nangate45_a** | **12 .. 30** | **10** | **robustly worse on all four seeds** |
| **salsa20_sky130_a** | **72 .. 80** | **48** | **robustly worse on all four seeds** |

**The peak deficit is real on four of nine designs, and three of the four are the same circuit,
salsa20, on all three PDKs.** On the other five it is a tie or unresolved by seeds.

This is a materially better target than the aggregate "median 1.358, no worse on 5 of 32". The
deficit is not a general property of the placer; it is concentrated in salsa20 and in
s1238_sky130. A fix can now be judged on a small, unambiguous set instead of on a median that
mixes designs where we win the peak with designs where we lose it by a factor of 1.6.

It also explains why the earlier per-design claims looked inconsistent: on gcd the seed range
straddles the reference, so any single-seed comparison of that design - including several in
Rounds 3 and 5 - was reporting the draw, not the algorithm.

**What this implies for the search.** salsa20 is the largest matched circuit and the one with the
most nets; it is also where the Round 2 net-demand measurement found the largest demand excess
(23.8 against the reference's 19.2, and 1.24x). A circuit-specific peak failure on the
high-net-count designs is consistent with the demand explanation and inconsistent with the
cell-distribution explanations, all of which were tested and failed.
