# Round 41: the congestion-effort exclusion is confirmed under the corrected protocol

## 1. Why it was re-tested

Every entry on the excluded list was established before the protocol fixes: the reference was scored
illegally, making its congestion 2.0x to 2.7x too large, and several measurements came from a harness
whose arm switching did not work. An exclusion is only as good as its measurement, so the most
suspicious entry - "congestion-aware wirelength is not a fix as an unconditional default" - was re-tested
properly.

Two designs had suggested it might be wrong: effort 4 improved total overflow and peak together on both,
taking s38584_ics55_a's total overflow from 1.17x the reference to 0.88x.

## 2. The full test

Effort 0 and effort 4 measured inside one process per design, against the reference from the same batch,
one thread, same binary, same seed. Ten designs are scored; four runs are still going.

| design | effort 0 (wirelength / total / peak) | effort 4 | change in total | change in peak | change in wirelength |
|---|---|---|---|---|---|
| **picorv32** | 0.81 / 1.45 / 1.61 | 0.82 / 1.45 / **1.28** | -0.005 | **-0.333** | +0.012 |
| s1238 | 0.76 / 1.14 / 1.43 | 0.69 / 1.31 / 1.36 | **+0.171** | -0.072 | -0.075 |
| s1238_ics55_a | 0.83 / 0.52 / 0.43 | 0.83 / 0.59 / 0.50 | **+0.065** | **+0.071** | -0.003 |
| **s1238_sky130_a** | 1.12 / 2.27 / 1.71 | 1.07 / **1.77** / **1.43** | **-0.500** | **-0.286** | -0.051 |
| **s38584_ics55_a** | 0.97 / 1.17 / 1.60 | 0.97 / **0.88** / **1.20** | **-0.285** | **-0.400** | +0.003 |
| s38584_nangate45_a | 0.96 / 1.50 / 1.00 | 0.97 / 1.50 / 1.00 | 0 | 0 | +0.012 |
| s5378_sky130_b | 0.90 / 1.56 / 1.27 | 0.90 / 1.58 / **1.18** | +0.019 | **-0.091** | +0.003 |
| **salsa20_ics55_a** | 0.94 / 0.80 / 1.31 | 0.96 / **0.78** / **1.20** | -0.015 | **-0.114** | +0.011 |
| **salsa20_nangate45_a** | 0.94 / 1.89 / 1.71 | 0.93 / **5.44** / **2.86** | **+3.55** | **+1.14** | -0.015 |

**Four designs improve total overflow and peak together. Two improve peak but worsen total. Two worsen
both, one of them catastrophically - salsa20_nangate45_a goes from 1.89x the reference to 5.44x.** One is
neutral and one has no congestion reference.

## 3. The conclusion

**The exclusion stands, and now it stands on a correct measurement.** Congestion-aware global placement is
a knob: it helps some designs a lot, hurts others, and on one design it destroys the placement. Adopting
it as a default would be the same mistake the entry describes.

This is worth stating with its cost, because the knob is not free: effort 4 calls the evaluator inside the
Nesterov loop, so a design takes tens of minutes instead of about one. A knob that both helps and destroys,
at tens of times the cost, is not adoptable.

## 4. What the test did settle

It found the two designs where it is worth having: **s1238_sky130_a** (total 2.27 to 1.77, peak 1.71 to
1.43, and wirelength 5% better) and **s38584_ics55_a** (total 1.17 to 0.88, peak 1.60 to 1.20). On those
it is the difference between failing and nearly passing on both congestion dimensions.

So the honest position is: **as a default, no - confirmed. As a design-conditional choice, there is a real
gain.** No design-level predictor separates the two groups in this data: the designs it helps and the
designs it hurts have overlapping effort-0 totals and peaks, so nothing in the standing tells them apart.
Finding one would be worth doing, and it cannot be done from what is measured so far.

## 5. An instrument check that came out of this

The same placement scored twice had given peak ratios of 1.1429 and 1.3143, which looked like measurement
noise and would have undermined every congestion conclusion. Measured directly: **four evaluations of the
same placement file give identical totals and peaks** (union 41960, peak 40). The trial-route measurement
is deterministic; the earlier disagreement was between different runs' reference sides, not noise in the
ruler.

## 6. Tree state

Source unchanged: SR-10 and SR-11 in; SR-2/3/4/5/7/8/9/12 withdrawn. **SR-13 and SR-14 remain unmeasured**
and are next after this. Binary f9581627.
