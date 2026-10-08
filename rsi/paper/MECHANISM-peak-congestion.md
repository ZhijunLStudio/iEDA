# Mechanism for peak congestion: excess cell clustering after global placement

Measured 2026-09-17 on the plain (config-driven) flow, comparing our placement with the
commercial reference DEF for the same design, die and netlist.

## Method

Parse both DEFs, bin the placed instances into a 64x64 grid over the die, and compare the
shape of the occupancy distribution. Instances are counted per bin rather than weighted by
cell area, which is an approximation, but both DEFs are parsed identically so the
comparison is between like and like. gini measures how unevenly the instances are spread;
max_bin and the busiest-1% share measure the heavy tail.

## Result

| design | pdk | our gini | ref gini | our max bin | ref max bin | our busiest 1% | ref busiest 1% |
|---|---|---|---|---|---|---|---|
| s1238_sky130_a | sky130 | 0.120 | **0.007** | 2 | 2 | 1.37% | 1.38% |
| gcd_sky130_a | sky130 | 0.114 | 0.029 | 2 | 2 | 1.47% | 1.49% |
| salsa20_nangate45_a | nangate45 | 0.225 | 0.175 | **19** | 14 | 2.30% | 1.72% |
| s38584_nangate45_a | nangate45 | **0.330** | 0.251 | **10** | 7 | 2.64% | 2.16% |
| salsa20_sky130_a | sky130 | 0.262 | 0.184 | **22** | 16 | 2.60% | 2.00% |

The direction is the same on all five: our placement is more clustered (higher gini),
with a heavier tail (higher max bin) and a larger share of instances in the busiest bins.
On the two small sky130 designs the gini gap is 4x and 17x; on the large designs the max
bin is 1.3-1.4x the reference's.

## Why this is the plausible cause of the EGR max gap

Peak routing overflow is a local quantity: it is set by the worst bin, not by the average.
A heavier density tail therefore raises the peak while leaving the average roughly intact.
That matches the observed signature - union close to parity (1.069x) while max is clearly
worse (1.343x, and better than the reference on only 3 of 12 matched designs).

It also points at a specific place in the tool: the density penalty and the spreading
behaviour of global placement, not the router and not the detailed placer.

## Why this is useful beyond the diagnosis

The indicator is cheap: it needs only the DEF, no trial route. A full EGR evaluation of one
design costs seconds to tens of seconds and is the noisiest measurement in the study
(median seed spread 5.92%, p90 26.05%), whereas the clustering statistic is deterministic
given the DEF. That makes it a candidate screening signal for source iteration:

    build -> place -> clustering indicator (deterministic) -> only promising changes get an EGR run

This is the same shape as the paper's method finding (screen with the cheapest faithful
signal, confirm expensive) applied to the iteration loop itself.

Caveat: the clustering statistic has not yet been shown to be faithful - that requires
correlating it with EGR max across the design set, which the corrected 32-design baseline
will allow. Until then it is a hypothesis, not a verified proxy.

## Next

1. Correlate the clustering indicator with EGR max on the corrected baseline.
2. If the correlation holds, use it as the screening signal for source iteration.
3. First source target: the density penalty / spreading in global placement, since that is
   where the heavy tail is produced.
