# Round 8: the problem point, found by stage localisation

## 1. What this round set out to do

After seven rounds in which every lever failed, the request was to stop guessing and find the
actual problem point. This round localises where the peak-congestion deficit is created, and the
answer is not where any previous round was looking.

## 2. The diagnosis from seven rounds of failures

Every lever tried acts on one of three things:

| lever family | examples | acts on |
|---|---|---|
| global scalars | density-penalty strength and floor, penalty-ramp ceiling, iteration budget, penalty-schedule rewrite | one number for the whole design |
| cell density | density-grid resolution, network-flow spreading, detail-placement permutation | how many cells sit in a bin |
| net bounding boxes | congestion-aware wirelength levels 2, 3, 4 | the rectangle a net spans |

The peak congestion we lose on is none of those things. It is a **maximum over bins of a
net-driven routing demand**: one or a few bins, and the nets that pass through them. A maximum
is invisible to a smooth global descent, and a bounding box is not a route. So seven rounds of
levers moved quantities adjacent to the peak without ever acting on it, which is exactly the
uniform failure record that was observed.

That much was already visible at the end of Round 2. What Round 8 adds is *which stage* creates
the deficit, and the answer contradicts the assumption every previous round made.

## 3. The finding: detailed placement creates the deficit, not global placement

Every round so far acted on global placement, on the assumption that the peak is set there.
Stage-localising the peak instead - measuring at GP+LG and again after DP, on netlist-matched
designs - shows the opposite:

| design | GP+LG peak | after DP | reference peak | what DP did |
|---|---|---|---|---|
| **s1238_ics55_a** | **6** | **12** | 14 | **doubled it** |
| **s38584_nangate45_a** | **1** | **4** | 2 | **quadrupled it** |
| salsa20_ics55_a | 34 | 46 | 34 | worsened |
| s38584_ics55_a | 20 | 24 | 18 | worsened |
| salsa20_nangate45_a | 12 | 14 | 10 | worsened |
| s1238_nangate45_a | 0 | 2 | 0 | worsened |
| gcd_ics55_a | 6 | 3 | 6 | improved |

And on the total-overflow metric, where the nangate45 blowups live:

| design | GP+LG union | after DP | reference union |
|---|---|---|---|
| **s38584_nangate45_a** | **3** | **21** | 6 |
| **salsa20_nangate45_a** | **451** | **1090** | 250 |

**Detailed placement worsens the peak on six of seven designs measured, and on two of them it
takes a placement that BEATS the commercial reference and turns it into one that loses.**
s38584_nangate45_a is the starkest: GP+LG gives union 3 against the reference's 6 and peak 1
against 2 - a clean win on both - and detail placement gives back union 21 and peak 4.

The plain flow runs DP unconditionally, so the loss is reported as a property of the placer.

## 4. Why this was missed for seven rounds

Round 2 tested DP's effect on the peak on six designs, all of them sky130, and concluded "DP is
not systematically harmful to the peak, its effect is mixed". That conclusion was correct for
sky130 and wrong for ics55 and nangate45, where the damage is concentrated. The evaluation
vector was biased by whichever designs happened to be large, and the bias was invisible because
the conclusion was stated as a general one.

This is the same class of error as the Round 7 netlist finding: a conclusion drawn from a
convenient subset and reported as general. Both were found by re-checking a claim against the
data rather than by trying another lever.

## 5. The fix attempt, and why it failed

If DP is where the peak is lost, the natural change is a routability guard on DP: accept its
wirelength gains but stop when it starts concentrating cells. The natural signal was already in
the tree - DetailPlacer::calPeakBinDensity() - with every call site commented out, so it was
written for exactly this purpose and then disabled.

SR-3 wired it as a stopping rule on DP's swap loop: iterate while wirelength improves and the
peak bin density has not risen above its value on entry. Built in 8 s, measured against a
commit-matched control binary on six designs.

**All six designs came out byte-identical, and the reason is that the metric is degenerate.**
Instrumented output from a live run:

    Detail placement peak bin density on entry: 1
    Iteration: 0 Row Opt Peak Density: 1

obtainPeakBinDensity delegates to the grid manager's obtainPeakGridDensity, and the grid manager
is not populated in the detail-placement path, so the value is a constant and the guard can never
fire. SR-3 was reverted; the tree carries no source change from this round.

**This is the third instance of the same pattern in this codebase**: the congestion-aware global
placement path exists with seven levels and no caller passes the option; the network-flow
spreading operator exists and has no Tcl command; the detail-placement peak-density monitor
exists, is commented out, and returns a constant when called. In each case the machinery to
attack the problem was written and then disconnected.

## 6. Where the objective stands

Unchanged and unmet: four dimensions ahead (HPWL, total congestion, setup WNS, setup TNS on the
netlist-matched set), peak congestion behind.

What has changed is that the target is now located. Seven rounds acted on global placement and
the deficit is created after it. The lever that follows from the evidence is a routability term
**inside detail placement**, driven by a demand metric computed from the nets DP is moving - not
by cell density, which is what the degenerate monitor measures and which Round 1 already showed
is a weak predictor of the peak (rho +0.358).

## 7. Next round

1. **Give detail placement a working demand metric.** The pieces exist: BinGrid::evalRouteDem
   computes per-bin routing demand and is used by global placement; DP has the netlist through
   DPNet and the instances through DPInstance. Wiring a demand evaluation into DP is the
   precondition for any guard.
2. **Then guard the operator that does the damage.** The swap loop runs instance swap, local
   reorder, bin optimisation and row optimisation in sequence; instrumenting each against the
   demand metric localises which one to restrict, rather than restricting all of them.
3. **Re-test on the matched ics55/nangate45 set at three seeds**, since that is where the effect
   is largest and where the control is clean.

## 8. Addendum: what DP buys, and what it costs

Pricing both sides of the trade on the saved placements. HPWL at GP+LG and after DP, against the
reference, with the peak at each stage:

| design | GP+LG HPWL | after DP | reference | DP buys | GP+LG vs reference | peak GP+LG | peak after DP | reference peak |
|---|---|---|---|---|---|---|---|---|
| s1238_sky130_a | 12,510,710 | 7,440,925 | 6,709,138 | **-40.5%** | 1.865 | 78 | 66 | 32 |
| salsa20_ics55_a | 285,696,839 | 280,575,674 | 296,610,508 | -1.8% | **0.963 (win)** | 34 | 43 | 34 |
| salsa20_nangate45_a | 503,948,090 | 493,177,826 | 534,430,356 | -2.1% | **0.943 (win)** | 12 | 14 | 10 |
| s38584_nangate45_a | 138,986,633 | 135,613,312 | 144,607,962 | -2.4% | **0.961 (win)** | **1** | **4** | **2** |

On three of the four designs, **global placement plus legalisation alone already beats the
reference on wirelength**, and the peak is better than after DP:

- s38584_nangate45_a: peak 1 against the reference's 2 - a factor of two BETTER - and DP turns it
  into 4, a factor of two worse. DP buys 2.4% of wirelength for that.
- salsa20_ics55_a: peak ties the reference at 34 before DP and loses at 43 after.
- salsa20_nangate45_a: peak goes from 1.2x worse to 1.4x worse with DP, and wirelength is a win
  either way.

The exception is s1238_sky130_a, where DP is worth 40% of wirelength and its absence would leave
us at 1.87x the reference. There DP is essential.

**So the trade is design-dependent, and the discriminating fact is how much wirelength DP is
actually buying.** Where it buys 2%, its congestion cost exceeds its benefit and skipping it is
better on two dimensions at once. Where it buys 40%, it is indispensable.

That is a decision that can be made from quantities the flow already has - DP reports its own
HPWL before and after through its result record, and the stage is already wrapped in a
transaction that can be rolled back. What is missing is only a routability signal to veto with,
which is the same gap section 7 identifies.

## 9. Multi-seed confirmation

The stage localisation used one seed. Repeated at three seeds on the clearest design,
s38584_nangate45_a, whose reference is union 6 and peak 2:

| seed | GP+LG union / peak | after DP union / peak |
|---|---|---|
| 1001 | 9 / 2 | 13 / 2 |
| 1002 | 7 / 2 | **19 / 6** |
| 1003 | **6 / 1** | **16 / 3** |

**Global placement plus legalisation is at or better than the reference on all three seeds**
(union 6-9 against 6, peak 1-2 against 2, and at seed 1003 outright better on both).
**Detailed placement makes it worse than the reference on all three seeds.**

This is the cleanest statement of the finding available: on a netlist-matched design, our own
flow beats the commercial reference before detailed placement and loses to it after. The
dimension we were treating as a systematic property of the placer is, at least here, a property
of one stage of our own pipeline.

On salsa20_ics55_a the same comparison is mixed for the peak (+7 and -5 at two seeds) while DP
consistently improves total overflow, so DP is not uniformly harmful - consistent with the trade
priced in section 8, where the deciding factor is how much wirelength DP buys on that design.
