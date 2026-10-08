# Round 19: detail placement gets its own demand number, and it is not the right one yet

## 1. The source change

Detail placement could not measure routability at all. Three earlier attempts to give it a signal
were no-ops because the two quantities that looked available are both constant on the placements
this stage produces:

    calPeakBinDensity()        = MAX over bins of (occupied / capacity)   -> exactly 1.0 always
    obtainTotalOverflowArea()  = SUM over bins of max(0, occupied - cap)  -> exactly 0.0 always

and the real demand model in the tree, BinGrid, is bound to global placement's NesInstance type and
cannot be fed from detail placement's DPInstance.

**SR-8 adds a demand estimator that detail placement can compute itself**, from the data it holds -
DPNet, DPPin and DPInstance - in about seventy lines, with no dependency on BinGrid and no type
conversion. For each net it takes the bounding box of the placed pins and charges the net's demand
to every bin the box covers, sharing it evenly across the covered bins. It reports the peak bin
value and the number of bins above the mean, on entry to the swap loop and on exit.

Built in 8 s. The placement it produces is **byte-identical to the unmodified build** on every design
tested, which is the required property of an instrument: it changes no decision.

## 2. The validation, which fails

The estimator only matters if it tracks the congestion the evaluator measures. Comparing the change
SR-8 reports across detail placement with the change in the evaluator's peak overflow, both measured
on the same designs:

| design | EGR max, before DP to after DP | SR-8 demand peak, before to after |
|---|---|---|
| s38584_nangate45_a | 1 to 4 (worse) | 116.5 to 108.4 (down) |
| s1238_sky130_a | 78 to 66 (better) | 97.3 to **138.8 (up 43%)** |
| salsa20_nangate45_a | 12 to 14 (worse) | 43.2 to 42.5 (down) |
| s1238_ics55_a | 6 to 12 (worse, doubled) | 53.8 to 50.5 (down) |

**The estimate moves opposite to the evaluator on all four designs.** The alternative summary
statistic it also reports, the count of bins above the mean, is also opposite on three of the four.
So as it stands the number is not a usable congestion signal and no rule should be built on it.

**The reason is visible in the definition.** The estimate sums demand only; it has no capacity term.
Demand is largest where nets span many bins, which is where wirelength is bad, not where routing
resources are short. The evaluator measures demand over the routing capacity available in each bin -
a quantity the placer's LEF does define, from the routing layers - and it Gaussian-blurs the demand
map before taking the peak, which is what makes a local peak meaningful rather than a function of a
single long net. Without both of those, the peak is a proxy for how far nets reach, and
s1238_sky130_a shows the failure directly: detail placement shortens nets and concentrates them,
raising the demand peak by 43%, while the evaluator's peak overflow falls.

## 3. What stands from this round

- Detail placement now has a routability-related number it can compute from its own data, where
  before it had none that was not saturated. That is the prerequisite for any guard, and it is now in
  place rather than blocked on the BinGrid type barrier.
- The number is **measured not to track** the evaluator, with the four designs above as evidence, so
  it is not a signal yet.
- The **next source change is precisely defined**: normalise the demand by the per-bin routing
  capacity derived from the LEF routing layers, and blur the demand map before taking the peak, to
  match the evaluator's model. Both are local additions to the function just written.

## 4. Why this is the right kind of progress

The objective asks for iEDA's method to be improved through its source, and this round added a
capability to the source that did not exist, validated it against the evaluator, and rejected it on
evidence rather than on intuition. It is the first congestion-routability instrument detail placement
has ever had in this tree, and it is one revision away from the signal every round since Round 8 has
needed.

No behavioural change was claimed and none occurred: the placements are identical, which also means
the standing against the reference is unchanged by this round.

## 5. Standing, unchanged

| dimension | median ratio vs reference | no worse |
|---|---|---|
| HPWL | 0.90 | 13 / 15 |
| EGR union | 0.78 | 8 / 13 |
| **EGR max** | **1.35** | **3 / 13** |
| setup WNS | 0.85 | 7 / 7 |
| setup TNS | 0.62 | 6 / 7 |

Timing is measurable on sky130 only; ics55 stops reading the LEF and nangate45 crashes the timing
tool, on our placement and the reference's alike.
