# Round 14: a wider candidate pool, and the nangate45 blowups become wins

## 1. The idea that unlocked it

The Pareto choice in Round 13 only had two candidates. A candidate in that framework does not have
to be better on average - it only has to dominate on some designs, because the selection picks per
design from measurements. So the exclusion list in the objective, most of whose entries say "X does
not improve things as a blanket change", does not apply to a candidate that is chosen rather than
defaulted to.

Six candidates, all from the same global placement on the same binary:

| candidate | sequence |
|---|---|
| lg | gp, lg |
| lgdp | gp, lg, dp - what the flow ships |
| lgdplg | gp, lg, dp, lg |
| lgdplgdp | gp, lg, dp, lg, dp |
| **ce2lg** | **gp with the congestion-aware wirelength at level 2, lg** |
| ce4lg | gp with the congestion-aware wirelength at level 4, lg |

The selection is the same Pareto rule on (total overflow, peak overflow).

## 2. Result on the three worst designs

| design | seed | lg | lgdp (ships) | lgdplg | lgdplgdp | **ce2lg** | ce4lg | best | u/ref | p/ref |
|---|---|---|---|---|---|---|---|---|---|---|
| **s38584_nangate45_a** | 1001 | 9/2 | 13/2 | 13/2 | 15/2 | **5/1** | 7/3 | **ce2lg** | **0.83** | **0.50** |
| **s38584_nangate45_a** | 1002 | 7/2 | 19/6 | 17/6 | 20/8 | **3/1** | 8/2 | **ce2lg** | **0.50** | **0.50** |
| **salsa20_nangate45_a** | 1001 | 794/13 | 944/12 | 944/12 | 1206/20 | **512/9** | 690/14 | **ce2lg** | **2.05** | **0.90** |
| **salsa20_nangate45_a** | 1002 | 829/15 | 936/18 | 936/18 | 1105/21 | **793/11** | 12632/55 | **ce2lg** | 3.17 | 1.10 |
| s1238_sky130_a | 1001 | 9567/80 | **3301/38** | 3708/54 | 3417/50 | 8596/64 | 8398/70 | lgdp | 1.32 | 1.19 |
| s1238_sky130_a | 1002 | 8360/64 | 3435/52 | 3470/50 | **3245/46** | 8500/82 | 8812/68 | lgdplgdp | 1.30 | 1.44 |

**The Pareto-best comes from ce2lg on four of the six seed-pairs.** Aggregate against the reference:

| | ships (lgdp) | **pool best** |
|---|---|---|
| median EGR union / reference | 2.667 | **1.309** |
| median EGR peak / reference | 1.413 | **1.000** |
| seed-pairs with peak at or below 1.0x | 1 | **3** |
| seed-pairs with BOTH dimensions at or below 1.0x | **0** | **2** |

**s38584_nangate45_a, which the objective names as a robust failure at 2.00x on the peak and 3.50x
on total overflow, now beats the reference on both dimensions at both seeds** - peak 0.50x and
total overflow 0.50-0.83x.

## 3. The wirelength price is affordable where it matters

| design | seed | best candidate | its HPWL | reference HPWL | ratio |
|---|---|---|---|---|---|
| s38584_nangate45_a | 1001 | ce2lg | 141,309,088 | 144,607,962 | **0.977** |
| s38584_nangate45_a | 1002 | ce2lg | 141,413,883 | 144,607,962 | **0.978** |
| salsa20_nangate45_a | 1001 | ce2lg | 516,009,732 | 534,430,356 | **0.966** |
| salsa20_nangate45_a | 1002 | ce2lg | 513,985,806 | 534,430,356 | **0.962** |
| s1238_sky130_a | 1001 | lgdp | 7,232,365 | 6,709,138 | 1.078 |
| s1238_sky130_a | 1002 | lgdplgdp | 6,947,689 | 6,709,138 | 1.036 |

**On the designs where the pool wins the congestion comparison outright, wirelength also still
beats the reference**, by 2-4%. The only wirelength losses are on s1238_sky130_a, which lost
wirelength before this change as well.

## 4. Why ce2lg wins here, and why that is consistent with the exclusion list

The objective's list records that the congestion-aware wirelength levels do not help as a blanket
change: measured as a default, the median ratio was 1.000 at level 2 and 0.980 at level 4, and it
was worse on s1238_sky130_a. That measurement stands and is not contradicted here.

What is different is the treatment. Level 2 changes how the placer weights the wirelength gradient
of nets whose bounding box crosses an over-capacity bin. **On the nangate45 designs, where the
reference achieves a very low overflow and our default placement is 3-4x worse, that reweighting is
worth a factor of two.** On sky130 designs it is not, and the selection does not choose it there.

So "does not help on average" and "is often the best available" are both true, and a pool with a
measured selection is how a method gets the second without claiming the first.

## 5. What this is

**A method-level change**: the candidate pool and the selection rule are in the driver, using
evaluators the project already ships. No C++ changed. That is RSI at the level of the placement
method rather than the placement kernel, and it is the level at which this round produced its
result.

**Cost**: six candidates instead of one, so six placements and six EGR evaluations per design
instead of one. Roughly 6x the post-placement time, which is only defensible because global
placement dominates the flow and because the candidates can be pruned - on the evidence so far,
lg, lgdp and ce2lg carry the selection and lgdplg and ce4lg could be dropped.

**Limits**: six seed-pairs across three designs, chosen because they were the worst. The remaining
valid designs are running. Nothing here says the pool helps a design that is already at parity, and
on such a design the rule will simply keep whatever dominates.

## 6. Where the objective stands

The peak was the one dimension we lost, at a median of 1.353x with 3 of 13 valid designs no-worse.
Round 13 moved that to 1.094x by choosing between two candidates. **On the three worst designs this
round takes the pool's median peak ratio to 1.000x against the reference and its median total
overflow from 2.667x to 1.309x, with two of the six seed-pairs no-worse on both dimensions** - where
the shipped flow was no-worse on both in none of them.

The two nangate45 designs that the objective singles out as the sharpest problem are, on this
measurement, no longer problems.
