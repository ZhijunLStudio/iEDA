# Round 48: the shape of our congestion, and what it says about which defects we have

## 1. Two failure groups, not one

The standing splits the designs more finely than "congestion is bad". Profiling our own overflow maps -
how much of the die carries overflow, how deep the excess is and how concentrated it is - and putting
that next to the two ratios:

| design | total overflow | peak | cells carrying overflow | mean excess where >0 | top 10% share | fails |
|---|---|---|---|---|---|---|
| aes | 354032 | 58 | **40.5%** of the die | 9.52 | 54.6% | union, peak |
| picorv32 | 125165 | 74 | **36.9%** | 9.39 | 56.7% | union, peak |
| s1238 | 1970 | 44 | **29.5%** | 8.53 | 67.2% | union, peak |
| apb4_timer | 2117 | 20 | 16.5% | 3.81 | 85.1% | none |
| salsa20_ics55_a | 41960 | 40 | 16.5% | 4.84 | 89.0% | **peak only** |
| gcd_sky130_a | 2150 | 28 | 9.9% | 8.02 | 100% | union, peak, wirelength |
| s1238_sky130_a | 3594 | 52 | 8.6% | 16.64 | 100% | union, peak, wirelength |
| s5378_sky130_b | 4072 | 33 | 7.5% | 5.67 | 100% | union, peak |
| s38584_ics55_a | 3627 | 24 | 5.8% | 3.36 | 100% | union, peak |
| **salsa20_nangate45_a** | 1090 | 14 | **1.1%** | 2.42 | 100% | union, peak |
| **gcd_ics55_a** | 37 | 3 | **0.6%** | 1.48 | 100% | **union only (peak 0.50)** |
| **s38584_nangate45_a** | 21 | 4 | **0.1%** | 1.62 | 100% | **union only (peak 1.00)** |

**Two distinct signatures.**

**Broad overflow.** aes, picorv32 and s1238 carry overflow on 30 to 40 per cent of the die with a
comparatively shallow mean (8.5 to 9.5). Their total and peak fail together. This is what a placement
looks like when routing demand is spread widely over the chip.

**Concentrated overflow.** gcd_ics55_a, s38584_nangate45_a and salsa20_nangate45_a carry overflow on
0.1 to 1.1 per cent of the die. On the first two our **peak is at or better than the reference while our
total is 1.5x to 1.85x worse** - meaning the reference has a *higher* peak and a *lower* total than we do.

## 2. Why the second signature matters

For those designs, **we are spreading where the reference concentrates, and the total-overflow metric
punishes spreading.** That inverts the intuition used in every change so far: the instinct has been
"diffuse the cells to lower the peak", and on these designs the reference does the opposite - it accepts a
higher peak and gets a lower total.

It also explains why the congestion-effort knob helped some designs and destroyed others (salsa20_nangate45_a
went from 1.89x to 5.44x): a mechanism that spreads uniformly is the wrong instrument for a design where
the reference concentrates.

That is a hypothesis with a testable consequence, and it is the first thing this campaign has found that
distinguishes *which* congestion defect a design has rather than only how large it is.

## 3. What I could not finish this round

The cell-by-cell comparison needs the reference's maps, and the evaluator did not write them into the
reference work directories even though it scored those placements (it returns totals and peaks but no map
files there, while it writes maps for other runs). Until that is resolved the comparison above is against
our maps alone, with the reference represented by its two numbers.

## 4. State

- **In the tree**: SR-10, SR-11. Binary f9581627.
- **Standing**: 4 of 15 designs no worse on every measurable dimension; wirelength fails 2 of 15, total
  overflow 10 of 13, peak 9 of 13.
- **Withdrawn with reasons**: SR-2/3/4/5/7/8/9/12/13/14/15/16.
- **Next**: produce the reference maps, then test whether the two signatures separate the designs that
  respond to a spreading mechanism from the ones it damages.
