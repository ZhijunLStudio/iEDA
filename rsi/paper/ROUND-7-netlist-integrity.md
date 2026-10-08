# Round 7: the reference netlists are not always the same design, and the corrected standing

## 1. Outcome in one line

A data-integrity check found that most sky130 reference placement files are a DIFFERENT netlist
from our input, which changes which comparisons are valid; restricting to the 15 designs where
both sides are the same netlist strengthens our position on four dimensions (HPWL 13/15,
setup WNS 7/7) and leaves peak congestion as the only loss (3/13).

## 2. The integrity finding

While investigating a 37% wirelength deficit on salsa20_sky130_a, I counted nets and components
in every reference placement file against our own input. They do not always match:

| design | our input | reference | difference |
|---|---|---|---|
| salsa20_sky130_a | 22,876 nets | 21,406 nets | **-1,470 (6.4%)** |
| aes_core_sky130_b | 20,657 | 18,772 | -1,885 |
| **aes_sky130_a** | **9,693** | **20,178** | **+10,485** |
| PPU_sky130_b | 7,663 | 7,234 | -429 |
| apb4_clint_sky130_b | 1,173 | 1,039 | -134 |
| gcd_sky130_a | 309 | 305 | -4 |

Across the set:

| group | designs | reference identical? |
|---|---|---|
| ics55 | 4 | **all identical** |
| nangate45 | 4 | **all identical** |
| sky130 | 24 | 7 identical, **17 different** |

**In 17 of 24 sky130 designs our placement is being compared against a placement of a different
netlist.**

**Direction matters.** In almost every case the reference has FEWER nets than we do (the
exceptions are aes_sky130_a, where it has more than twice as many, and the four designs with a
difference of four or fewer). A reference with fewer cells to place has a structurally easier
problem for both wirelength and congestion, so the bias is *against us*: our margins on those
designs are understated, and our deficits overstated.

**This does not invalidate the comparison; it makes the valid subset a separate report.** The
cause is not established - the reference files live under assets/innovus_rebuild, and a rebuild
that ran its own optimisation could easily drop or add cells - but the check is mechanical and
the conclusion does not depend on knowing why.

**Consequence for the campaign.** All sky130-based numbers in Rounds 1-6 inherit this. The
practical effect is that conclusions should be read from the matched subset, and that the
12-design evaluation vector is not fully clean: of its four sky130 members, gcd_sky130_a (-4)
and s1238_sky130_a (-1) are acceptable, while salsa20_sky130_a (-1,470, 6.4%) and
s38584_sky130_a (-176) are not.

## 3. The corrected standing: 15 netlist-matched designs

| dimension | n | median ratio | no worse |
|---|---|---|---|
| HPWL | 15 | **0.898** | **13 / 15 (87%)** |
| EGR union | 13 | **0.782** | 8 / 13 (62%) |
| EGR max | 13 | **1.353** | **3 / 13 (23%)** |
| setup WNS | 7 | **0.848** | **7 / 7 (100%)** |
| setup TNS | 7 | **0.618** | 6 / 7 (86%) |

Against the all-designs figures (HPWL 0.924 / 25 of 32, union 0.835 / 19 of 30, peak 1.358 /
4 of 30, WNS 0.789 / 19 of 24), the valid subset is **better on every dimension**: 87% versus
78% on wirelength, and setup timing is unbeaten at 7 of 7.

**We lead on four of five dimensions on the rigorously comparable set.** Peak congestion
remains the only loss, and it is a loss on 10 of 13.

## 4. A real nangate45 congestion problem, on valid comparisons

The original goal mentioned "two nangate45 congestion disasters". Those specific numbers were
artefacts of a regressive generation path (Round 1 correction: 3.5x and 4.4x, not 625x and
159x). But the underlying signal is real and these comparisons are netlist-matched:

| design | our union | reference union | ratio | our peak | reference peak |
|---|---|---|---|---|---|
| salsa20_nangate45_a | 1,090 | 250 | **4.36** | 14 | 10 |
| s38584_nangate45_a | 21 | 6 | **3.50** | 4 | 2 |

On nangate45 the reference achieves a very low total overflow and we do not. This is a
design-family-specific failure on a valid comparison, and it is a better-posed target than the
aggregate median because the reference values are small and stable.

## 5. The 37% wirelength deficit on salsa20_sky130_a was largely an artefact

That design was one of the five "robust peak failures" identified in Round 6, and its HPWL
ratio of 1.37 was the largest single deficit in the campaign. With a 1,470-net difference
between the two placements, that number compares different circuits and should not be used.

Of the five robust peak failures, **three are on netlist-matched designs and remain valid**
(s1238_sky130_a, salsa20_ics55_a, salsa20_nangate45_a) and two are not (salsa20_sky130_a,
s38584_sky130_a).

## 6. The congestion-aware levels do not fix the peak either

Tested at three seeds, paired against the baseline on the same seeds:

| design | level 2 peak ratio | level 4 peak ratio |
|---|---|---|
| s1238_sky130_a | 1.167 | 1.125 |
| salsa20_sky130_a | 1.083 | - |
| gcd_ics55_a | 0.500 | 0.333 |
| gcd_sky130_a | 1.000 | 1.000 |
| s1238_ics55_a | 1.000 | 0.714 |
| s1238_nangate45_a | 2.500 | 2.500 |

Both levels make the peak **worse** on s1238_sky130_a, the design that is a valid comparison and
a robust failure. They help gcd_ics55_a, which was seed-dependent anyway. So enabling either
level by default is not justified by this evidence, and the congestion-aware path is not the
answer to the peak deficit.

## 7. What this leaves

The peak is the last dimension, it is a real deficit on 10 of 13 valid designs, and every lever
tried in seven rounds has failed to move it in the right direction: density magnitude and floor,
iteration budget, grid resolution, network-flow spreading, detail-placement permutation, the
density-ramp schedule, and now the congestion-aware wirelength levels.

The one measurement that has never been contradicted is that the peak is a property of net
demand rather than cell distribution - 1.85x the reference's peak demand on 30 of 30 designs.
The untested lever consistent with that is net weighting: weight nets by the demand they route
through regions that are over capacity, so the placer prefers to shorten those specific nets
rather than to spread cells. The level-2 result is the degenerate version of that idea (it
scales a net's gradient by the overflow of the worst bin its bounding box touches), and it is
too crude: it acts on the bounding box rather than on the routing demand, and it acts with a
weak linear coefficient.

## 8. Next

1. Record the netlist-integrity caveat in the paper's evaluation section - it is a finding about
   the data, and any reader replicating this needs it.
2. Re-run the standing comparison on the 8 matched ics55/nangate45 designs, which are clean by
   construction and include the two nangate45 union blowups, so the target set is unambiguous.
3. Net weighting on the demand the nets actually place through over-capacity regions.
