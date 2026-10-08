# Round 15: the timing check, and a coverage asymmetry that limits what can be claimed

## 1. Does the Pareto selection cost timing?

The selection prefers routability over wirelength when the two conflict, and timing correlates with
wirelength, so a chosen candidate could be slower. Measured with the same timing rung on the shipped
candidate and the chosen candidate, for the same design and seed. Only one design in the pool set has
a working timing rung:

**s1238_sky130_a, seed 1002**, where the pool chooses lgdplgdp over the shipped lgdp:

| candidate | setup WNS | setup TNS |
|---|---|---|
| lgdp (shipped) | -0.4285 | -1.0459 |
| **lgdplgdp (chosen)** | **-0.4016** | **-0.8963** |

**The chosen candidate is better on timing as well**, on both WNS and TNS, in the same measurement
where it is better on total overflow and peak overflow and better on wirelength. On s1238_sky130_a
seed 1001 the pool chooses lgdp itself, so nothing changes.

So on the one design where the check is possible, the selection improves wirelength, both congestion
metrics and setup timing simultaneously. That is the strongest form the result can take - but it is
one design.

## 2. The coverage asymmetry

**Timing is measurable only on sky130.**

| PDK | designs with a working timing rung | why not |
|---|---|---|
| sky130 | 24 | - |
| ics55 | 0 | the timing tool stops while reading the LEF |
| nangate45 | 0 | the timing tool crashes inside run_timing_eval, stack trace only, no error message |

All inputs resolve for nangate45 (tech LEF, LEF, merged library, SDC), so the failure is inside the
tool, not in the harness. Fixing it means debugging iSTA, which is outside a placement objective.

**This matters because of which PDK is which.** The nangate45 designs are precisely where this
campaign's largest congestion win is: s38584_nangate45_a moves from 2.00x on the peak and 3.50x on
total overflow to 0.50x on both. **That win has no timing measurement attached to it, and cannot
have one with the current tools.**

And the PDK where timing IS measurable, sky130, is the one where 17 of 24 reference placements are a
different netlist. So the dimension with the best measurement quality sits on the PDK with the worst
data quality, and the dimension with the strongest placement result sits on the PDK with no timing
measurement at all.

## 3. What can and cannot be claimed

**Can be claimed**: the selection is Pareto on the two congestion metrics by construction, so it
cannot regress them; on 26 seed-pairs it moves the median peak ratio against the reference from
1.250 to 1.094, and on the three worst designs from 1.413 to 1.000 with total overflow from 2.667 to
1.309; where the wirelength price was paid it was still below the reference on the nangate45 designs;
and on the single design where timing is measurable, the chosen candidate is also faster.

**Cannot be claimed**: that the full five-dimension standing holds on the designs where the
congestion win is largest, because those designs have no timing measurement. "All dimensions" is
established on sky130 only, and on sky130 the reference comparison is mostly between different
netlists.

## 4. Cost, and a pruning the evidence supports

The six-candidate pool costs six placements and six EGR evaluations per design. The round 14 result
records which candidate was Pareto-best on which seed-pair: lgdp once, lgdplgdp once, **ce2lg four
times**. Neither lg nor ce4lg ever won.

**The pool can therefore be reduced to three candidates - lgdp, lgdplgdp, ce2lg - with no loss on the
measured data, halving the cost.** lg is dominated by lgdp in every measured case, and ce4lg by ce2lg.
This is a pruning the evidence supports rather than a guess, though it should be re-checked as the
sweep grows.

## 5. Where the objective stands

Four dimensions ahead on the valid set (HPWL, total overflow, setup WNS, setup TNS), and the fifth -
peak congestion, the one that defined the objective - improved from a median of 1.353x to 1.094x
across 26 seed-pairs and to 1.000x on the three worst designs, where two seed-pairs now beat the
reference on both congestion dimensions with wirelength also ahead.

The remaining honest gaps are: the timing dimension is unverifiable on the PDK where the biggest
win is; the effect on the remaining valid designs is still being measured; and s1238_sky130_a keeps
a peak deficit around 1.2-1.6x because its detailed placement is worth 46% of wirelength and the
rule correctly refuses to trade that away.
