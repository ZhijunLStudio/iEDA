# Round 16: the candidate pool crosses the reference on both congestion metrics

## 1. The result

Five designs, ten seed-pairs, six candidates each. The Pareto rule selects per design and seed, and
the pool's best is compared with what the flow ships (gp, lg, dp) and with the reference.

| design | seed | shipped union/peak | **pool best** | chosen by | pooled union/ref | pooled peak/ref |
|---|---|---|---|---|---|---|
| gcd_ics55_a | 1001 | 46 / 6 | 46 / 6 | lgdp | 1.15 | 1.00 |
| gcd_ics55_a | 1002 | 50 / 10 | **25 / 4** | lg | **0.62** | **0.67** |
| **s1238_ics55_a** | 1001 | 149 / 14 | **59 / 8** | lgdplgdp | **0.33** | **0.57** |
| **s1238_ics55_a** | 1002 | 141 / 11 | **65 / 6** | lg | **0.37** | **0.43** |
| s1238_sky130_a | 1001 | 3301 / 38 | 3301 / 38 | lgdp | 1.32 | 1.19 |
| s1238_sky130_a | 1002 | 3435 / 52 | **3245 / 46** | lgdplgdp | 1.30 | 1.44 |
| **s38584_nangate45_a** | 1001 | 13 / 2 | **5 / 1** | ce2lg | **0.83** | **0.50** |
| **s38584_nangate45_a** | 1002 | 19 / 6 | **3 / 1** | ce2lg | **0.50** | **0.50** |
| salsa20_nangate45_a | 1001 | 944 / 12 | **512 / 9** | ce2lg | 2.05 | **0.90** |
| salsa20_nangate45_a | 1002 | 936 / 18 | **793 / 11** | ce2lg | 3.17 | 1.10 |

Aggregate:

| | ships (lgdp) | **pool best** |
|---|---|---|
| median EGR union / reference | 1.347 | **0.992** |
| **median EGR peak / reference** | **1.194** | **0.783** |
| seed-pairs no worse on BOTH dimensions | 2 | **5** |

**Both medians cross 1.0.** On this set the placement chosen by the pool beats the reference on the
median of total overflow and on the median of peak overflow, where the shipped flow loses on both.

## 2. The pool is genuinely needed: no single candidate would do

Which candidate the rule picks:

| candidate | times chosen |
|---|---|
| lg | 2 |
| lgdp (shipped) | 2 |
| lgdplgdp | 2 |
| ce2lg | 4 |
| lgdplg | 0 |
| ce4lg | 0 |

**Four different candidates win somewhere and no candidate wins a majority.** A single fixed
alternative would lose on the designs where a different one dominates: lg wins on s1238_ics55_a seed
1002 and gcd_ics55_a seed 1002, ce2lg wins on all the nangate45 seed-pairs, lgdplgdp on
s1238_sky130_a seed 1002, and the shipped lgdp on the two seed-pairs where nothing dominates it.

That is also the answer to why this was not visible earlier: the campaign kept testing one change at
a time against a single baseline and asking whether it helped *on average*. Here each change is one
of several and the question is only whether it is ever best.

## 3. s1238_ics55_a is the clearest case

One of the three designs the objective names as a robust peak failure at every seed. The reference is
union 177, peak 14.

| candidate | seed 1001 | seed 1002 |
|---|---|---|
| shipped lgdp | 149 / 14 | 141 / 11 |
| **selected** | **59 / 8** | **65 / 6** |
| versus reference | union 0.33x, peak 0.57x | union 0.37x, peak 0.43x |

**Both congestion dimensions improve by a factor of two to three against the reference.**

## 4. What is not claimed

- Five designs, ten seed-pairs, two seeds each. Three seeds is the standard the goal sets; these
  sweeps used two because the pool costs six placements per design. The seed-to-seed spread on these
  metrics is large, so the aggregate medians are indicative rather than established at the required
  rigour.
- Timing is verified on one design only (Round 15), because the timing tool runs only on sky130.
- The three nangate45/ics55 designs with the largest congestion wins have **no** timing measurement
  and cannot have one.
- The remaining valid designs are still being measured.
- The pool's cost is six placements and six EGR evaluations per design; the round-15 data supports
  pruning to three candidates (lgdp, lgdplgdp, ce2lg), but two of the ten seed-pairs above are won by
  lg, so lg must stay as well. The pool is **four** candidates: lg, lgdp, lgdplgdp, ce2lg.

## 5. Where the objective stands

For the first time the measured median of the objective's failing dimension is below the reference -
0.783 against 1.194 for the shipped flow - on the designs where the deficit was defined. Four
dimensions were already ahead. The honest summary of the whole standing is:

| dimension | status |
|---|---|
| HPWL | ahead, 13/15 valid designs, median 0.898 |
| EGR union | ahead, median 0.782 valid / 0.992 on this pool set from 1.347 |
| **EGR max** | **0.783 median on this pool set, from 1.194; still 1.19-1.44 on s1238_sky130_a** |
| setup WNS | ahead, 7/7 measurable |
| setup TNS | ahead, 6/7 measurable |
| timing on ics55/nangate45 | **unmeasurable** |

## 6. Addendum: a third seed, and a correction to the pruning advice

Adding seed 1003 to the designs already measured, fourteen seed-pairs across six designs:

| | ships (lgdp) | **pool best** |
|---|---|---|
| median EGR union / reference | 1.285 | **0.831** |
| median EGR peak / reference | 1.194 | **0.783** |
| seed-pairs no worse on BOTH | 4 | **8** |

**s1238_ics55_a now has all three seeds measured**, and all three improve by two to three times on
both dimensions against a reference of union 177 and peak 14:

| seed | shipped | selected | selected by | union/ref | peak/ref |
|---|---|---|---|---|---|
| 1001 | 149 / 14 | 59 / 8 | lgdplgdp | 0.33 | 0.57 |
| 1002 | 141 / 11 | 65 / 6 | lg | 0.37 | 0.43 |
| 1003 | 122 / 13 | **59 / 6** | **ce4lg** | 0.33 | 0.43 |

### Correction: the pool cannot be pruned to three candidates

Round 15 advised reducing the pool to lgdp, lgdplgdp and ce2lg, on the grounds that lg and ce4lg had
never won. **That advice was wrong and is withdrawn.** With the third seed and the wider design set
the Pareto-best counts are:

| candidate | times chosen |
|---|---|
| lg | 2 |
| lgdp | 2 |
| lgdplgdp | 2 |
| ce4lg | **4** |
| ce2lg | **4** |
| lgdplg | **0** |

**Five of the six candidates win somewhere, and ce4lg - which the pruning advice would have removed -
wins four times, as often as ce2lg.** Only lgdplg has never won, and dropping it alone would not cut
the cost meaningfully.

The general lesson repeats the one from section 2: a candidate that looks useless on the data
available while a sweep is still running can be the most valuable one once more designs are in. The
pruning advice was made from six seed-pairs on three designs and did not survive fourteen on six.

### What the pool costs, with this in hand

Six placements and six EGR evaluations per design. At the flow's measured rates - global placement
7.4 s, legalisation 2.9 s, detail placement 2.9 s, an EGR evaluation about 6 s - that is roughly
6 x (2.9 + 2.9 + 6) = 71 s per design on top of a 7.4 s global placement, so the method costs about
ten times the shipped flow's placement time. On a design where no candidate dominates, it buys
nothing.
