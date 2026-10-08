# Round record 2: exposing the network-flow spread stage, and three negative results

## 1. Outcome in one line

No QoR improvement this round. Three measurements that each remove a plausible fix, one
real tool gap found and closed, and one process-level trap found and fixed.

## 2. The tool gap: a density-aware operator with no way to reach it

Detail placement contains a network-flow cell-spreading operator:

| fact | value |
|---|---|
| implementation | operation/NFSpread.cc, 1177 lines, with overflow-aware bin selection |
| its own contract | takes a post-global-placement DEF, produces a lower-density placement that still has overlap, so it belongs between GP and LG |
| how it is invoked | PLAPI::runNetworkFlowSpread() -> DetailPlacer::runDetailPlaceNFS() |
| how it is exposed | **nowhere**: no Tcl command, no flow, no config flag |
| why that matters | the pipeline that placer_run_dp drives contains only wirelength-driven operators (row optimisation, instance swap, local reorder), which is consistent with the measured re-clustering |

**Change made**: exposed it as the Tcl command placer_run_nfs, following the existing DP
command pattern. Five small edits: command class declaration (tcl_ipl.h), registration
(tcl_register_pl.h), tool_api wrapper declaration and definition (ipl_io.h/.cpp), and the
Tcl command (tcl_ipl.cpp). Build: 17 s, 28 targets.

**Also added**: the stage now logs what it achieved (moved_count, overflow_before/after,
iterations, progress, reason). Before this it was silent whether it moved cells or found
nothing to do, which is indistinguishable from a no-op inside a multi-stage pipeline.

## 3. Negative result: the operator is not usable as it stands

**a. In a separate process it can only ever no-op.** Running

    def_init -> init_pl -> placer_run_nfs

takes 0.6 ms and reports "network flow spread had no overflow to reduce". The reason is
that NFSpread spreads over the density grid that global placement builds in memory, and a
fresh def_init leaves it empty: the stage's own report prints ABU {2,5,10,20} : 0, 0, 0, 0,
so every bin looks empty and there is nothing to spread. **NFSpread must run in the same
process as global placement.** Any future experiment with it must respect that.

**b. On the largest, most clustered design it fails.** aes, in-process, GP then NFS then LG
then DP: the NFS stage returns an error (rc=1) and the flow stops. The captured log shows
the operator did see overflow before failing - it printed a table with 214 overflowing bins
and Max OFAR 0.488884 - and the ABU values are zeros again, which points at the operator's
own grid and ABU accounting rather than at its input.

**c. Where it does run, it hurts.** gcd_sky130_a, same process, same GP, the only difference
being the inserted stage:

| arm | gini | HPWL | EGR union | EGR max |
|---|---|---|---|---|
| GP -> LG -> DP | 0.3398 | 8,185,835 | 1,999 | 26 |
| GP -> NFS -> LG -> DP | 0.3423 | 8,417,429 | 2,331 | **48** |

HPWL +2.8%, union +16.6%, **max +85%**. On the metric this goal is about, the stage makes
things clearly worse.

**Conclusion**: exposing the capability was right - a density-aware operator that no flow can
call is a defect in the tool surface - but the operator needs real work before it is a lever.
It is not the fix, and I am not going to tune it blind. Recorded, not hidden.

## 4. Negative result: detail placement's re-clustering does not cause peak congestion

DP visibly re-clusters cells. aes, identical global placement, stopping after LG versus
running DP:

| pipeline | gini | busiest bin | HPWL | EGR union | EGR max |
|---|---|---|---|---|---|
| GP -> LG | 0.3398 | 69 | 693,335,676 | 349,156 | **64** |
| GP -> LG -> DP | 0.458 | **145** | 669,615,597 | 354,014 | **64** |

DP more than doubles the busiest-bin occupancy (69 -> 145) and raises the clustering
statistic by 35%, while **EGR max does not move at all** and union moves 1.4%. It buys 3.4%
of wirelength for that.

So the instance-count clustering that DP introduces is **not** what drives peak routing
overflow. Together with Round 1's finding that the shape statistics are weak predictors
(gini vs EGR max rho = +0.358; busiest-bin +0.553 with a +0.960 correlation to HPWL), the
clustering story is now doubly disfavoured as the mechanism.

This kills the plan Round 1 ended with, namely making DP re-clustering the first source
target.

## 5. Characterisation of the gap that remains

EGR max, ours over the reference, on the corrected 32-design baseline:

| slice | median ratio |
|---|---|
| all designs | 1.36 (26 of 30 above 1) |
| by circuit | gcd 0.83 (we win), s38584 1.33, salsa20 1.40, s1238 1.52 |
| by PDK | ics55 1.10, sky130 1.33, nangate45 1.70 |

The gap is broad rather than driven by a few designs, but the **absolute magnitudes are
small**: median 31 overflowing bins for us against 26 for the reference. While we are better
on total congestion (union 0.835), we are slightly worse at the single worst spot.

## 6. A process-level trap found and fixed: two binaries

The tree contained two different iEDA binaries:

| path | md5 | what it was |
|---|---|---|
| bin/iEDA | c9761dc9 | a copy made at the end of the initial build, never refreshed |
| build/bin/iEDA | moving | the actual build output |

Different harness scripts used different paths: the sweeps invoke build/bin/iEDA (through
IEDA_BIN), while the stage scripts invoked bin/iEDA. That is why the first attempt to call
the new NFS command reported "invalid command name": the command existed in the build output
but the stage script was running the stale copy.

Fixed by replacing bin/iEDA with a symlink to build/bin/iEDA, so there is exactly one
binary. The stale file is kept as bin/iEDA.pre-symlink-20260917 until the change is
confirmed.

**Did this invalidate earlier results?** Checked: the stale copy's md5 (c9761dc9) is
identical to build/bin/iEDA-base, the baseline binary. So the Round 1 stage-localisation and
LG/DP measurements were made with the base binary and remain valid; they were characterising
the baseline. The sweeps were unaffected because they always used build/. Recorded because
it is the same class of hazard as the mid-sweep rebuild fixed in Round 1, and it would have
been easy to mis-attribute the "invalid command name" to the source change instead of to the
path duplication.

## 7. What is now ruled out for peak congestion

| hypothesis | how tested | result |
|---|---|---|
| density penalty too weak or never relaxed | source change, then config (Round 1) | no effect |
| penalty floor (never shrink) | config | byte-identical |
| more global-placement iterations | config | worse |
| finer density grid | config | inconsistent, mostly worse |
| network-flow spreading | exposed and run | worse where it runs, fails on the largest design |
| detail-placement re-clustering | stop after LG versus run DP | peak congestion unchanged |

Six ways of moving cells around harder, all neutral or harmful. The remaining explanations
are about what the placement demands of the router rather than about where the cells are:
net topology, pin distribution, or the interaction between the placer's objective and the
router's capacity model. That is where the next round should look, which means reading the
router's demand model rather than the placer's density model.

## 8. Next round, in value order

1. **Read the router's demand model** (evalRouteDem, route capacity) and compare, for one
   design, which bins overflow and which nets cause them, ours versus the reference. This is
   the first measurement that would distinguish a net-topology effect from a
   cell-distribution effect.
2. Finish the DP-innocence sweep across the six matched large designs (running) for a
   citable table rather than one design.
3. If net topology is the driver, the lever is in how the placer shapes long nets
   (wirelength model weights, net weighting), not in density.
4. Do not tune NFSpread without first fixing its ABU and grid accounting.

## 9. Addendum: DP innocence over six matched large designs, and the net-demand measurement

### 9.1 Correction to section 4

Section 4 rested on one design (aes). Extended to six matched large designs, all from one
global placement, stopping after LG versus running DP:

| design | LG hpwl | LGDP hpwl | dHPWL | LG max | DP max | LG busiest | DP busiest | LG gini | DP gini |
|---|---|---|---|---|---|---|---|---|---|
| PPU_sky130_b | 316,216,320 | 311,039,160 | -1.6% | 64 | **58** | 30 | 30 | 0.452 | 0.456 |
| aes | 693,335,676 | 669,615,597 | -3.4% | 64 | 64 | 69 | **145** | 0.340 | 0.458 |
| aes_core_sky130_b | 1,094,251,339 | 1,075,951,528 | -1.7% | 76 | 76 | 42 | 51 | 0.471 | 0.481 |
| picorv32 | 249,439,460 | 245,785,834 | -1.5% | 54 | **74** | 28 | 54 | 0.351 | 0.491 |
| s38584_sky130_a | 220,955,331 | 218,352,980 | -1.2% | 54 | **46** | 18 | 18 | 0.317 | 0.325 |
| salsa20_sky130_a | 868,794,575 | 846,368,174 | -2.6% | 70 | **74** | 31 | 33 | 0.235 | 0.254 |

Median dHPWL **-1.65%**, improving on **6/6**. Median change in EGR max **0 bins**, but it
moves by more than two bins on **4/6** - and in both directions: PPU -6 and s38584 -8
(better), picorv32 +20 and salsa20 +4 (worse). Clustering increases on **6/6**.

**Correction**: "detail placement's re-clustering does not cause peak congestion" should be
"detail placement's re-clustering is not the mechanism, and its effect on the peak is
mixed". The aes case where a 2x increase in busiest-bin occupancy left EGR max untouched
still stands and is the cleanest single demonstration, but DP is not systematically harmful
to the peak - on two of six designs it helps materially. That weakens the case for
restricting DP's moves and strengthens the conclusion that instance-count clustering is not
the control variable.

### 9.2 Net-demand over the full design set

A RUDY-style demand map built directly from each DEF - for every net, the bounding box of
its pins charged to the bins the box covers - compared like for like against the reference
on the same die and netlist, same grid, same parser. This is computable without running a
router.

| design | ours | reference | peak ratio | map correlation (Pearson) |
|---|---|---|---|---|
| gcd_sky130_a | 2.13 | 1.72 | 1.24 | 0.60 |
| s1238_sky130_a | 2.54 | 1.62 | 1.57 | 0.69 |
| salsa20_sky130_a | 23.80 | 19.24 | 1.24 | 0.64 |
| aes | 36.26 | 13.61 | 2.66 | 0.11 |

Over all 30 designs with a reference: the demand peak ratio is above 1 on **30/30**, median
**1.854**. Our placement asks the router for materially more routing demand at its worst
spot than the commercial placer does, on every circuit and every PDK, at every size.

Correlations against the outcome we care about:

| signal | vs EGR max ratio | discordance | vs HPWL ratio | vs EGR union ratio |
|---|---|---|---|---|
| net-demand peak ratio | +0.128 | 47% | -0.173 | -0.071 |
| busiest-1% ratio | -0.034 | 51% | - | - |

**So the signal is a systematic mechanism observation, not a usable ranking signal.** It is
true on every design and therefore says nothing about which design to work on; its
discordance against EGR max is 47%, i.e. barely better than chance as an ordering. It does
not track HPWL (rho -0.17) which is the one thing it had to avoid.

**What it does establish.** The peak is a property of where the nets reach, not of how many
cells sit in a bin. Four independent measurements now agree on the negative side - cell
counts, clustering statistics, penalty strength, and grid resolution all fail to explain or
move the peak - and this is the first measurement to point at the net topology itself. The
lever, if there is one, is in how the placer shapes the worst nets, not in the density model.
