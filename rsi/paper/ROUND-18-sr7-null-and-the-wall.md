# Round 18: an SR-7 source change that did nothing, and the exact reason

## 1. What I changed in the source

Detail placement's swap loop accepts moves on wirelength alone, and stage-localised measurement
shows it raises peak congestion on six of seven netlist-matched designs, on two of them turning a
win against the reference into a loss. SR-7 gave the loop a stopping rule: record the placement and
a congestion quantity on entry, and if an iteration raises that quantity, undo the iteration's moves
and stop, keeping the legalised result.

The quantity was GridManager::obtainTotalOverflowArea(), a SUM over bins of
max(0, occupied - capacity). It was chosen deliberately because the metric already present in that
function, calPeakBinDensity(), is a MAXIMUM and is unusable: a legalised placement always has at
least one full bin, so it returns exactly 1.0 for every placement and cannot order two of them.
That was the reason the earlier SR-3 and SR-4 attempts were no-ops.

Built in 8 s. Measured against a commit-matched control - the control's md5 is identical to a build
of HEAD source, so the pair differs only by SR-7 - on s38584_nangate45_a and s1238_sky130_a.

**Both designs came out byte-identical.**

## 2. Why it did nothing: the sum is saturated too, in the other direction

    obtainPeakGridDensity()   = MAX over bins of (occupied / capacity)
                                legalised placement always has a full bin -> exactly 1.0 always
    obtainTotalOverflowArea() = SUM over bins of max(0, occupied - capacity)
                                detail placement produces a LEGAL placement, every bin is
                                inside capacity -> exactly 0.0 always

Both are quantities on the **density** grid, and both are constant on the set of placements detail
placement produces. Neither can order two placements, so no rule built on either can fire. The
instrumented run confirmed it: the guard's log line never printed a non-zero value and the loop
never tripped.

This closes the whole family: **the placer's density grid cannot distinguish between two legal
placements, so no stopping rule or acceptance test based on it can work.** That is the third
distinct attempt to build a congestion signal out of the density grid, and the reason is now known
rather than guessed.

## 3. Where the routing signal actually lives, and why it is unreachable

The routing-demand model in this codebase is BinGrid:

    void set_route_cap_h(int32_t num);
    void initNesInstanceTypeList(std::vector<NesInstance*>& nInst_list);
    void evalRouteDem(const std::vector<NetWork*>& network_list, int32_t thread_num,
                      bool plain_rudy = false, bool eval_aligned = false);
    float get_h_util_max() const;  float getUnionUtilMax() const;

It is used only by global placement, and its occupancy is populated from
std::vector<NesInstance*> - **global placement's instance type**. Detail placement works with
DPInstance, a different class in a different database. So BinGrid cannot be fed from detail
placement without converting every instance between the two representations, which is not a guard,
it is a subsystem rewrite.

GridManager, which detail placement does own, has only evalRouteUtil() and the util getters, and
those read fields that nothing populates on the detail-placement path.

**This is the wall, stated exactly**: to make detail placement congestion-aware it must have a
demand estimate it can compute itself, from the data it has - DPNet, DPPin and DPInstance.

## 4. The change that follows from this

A self-contained demand estimate inside detail placement, on the model global placement already
uses but computed locally: for each net take the bounding box of its pins, charge the net's demand
to each bin the box covers, sum per bin, and compare against a capacity derived from the routing
layers in the LEF. That is a RUDY-class estimate; it needs no BinGrid and no NesInstance, and it is
roughly sixty lines against data detail placement already holds.

Only once detail placement can compute a demand number can it reject a swap or stop a loop on
congestion - which is what every round from 8 onwards has been trying to do.

## 5. State of the tree

SR-7 is reverted; the tree carries no source change from this round. Five source changes have now
been attempted and withdrawn (SR-2 harmful, SR-3 and SR-4 no-ops, SR-5 mixed, SR-7 no-op), each
with a measured reason rather than an assumption. The only source changes still in the tree are the
two Tcl command exposures and one log line, from Rounds 2 and 8.

## 6. A correction to how this work has been structured

The candidate-pool work of Rounds 13 to 17 selects between command sequences using the project's
evaluators. It is a measurement harness that chooses, and it is not a change to iEDA's method. The
objective asks for iEDA to be made better, which means the source. The pool results stand as
evidence about where the candidates differ, but they are not the deliverable, and the loop that
matters is: run the standard flow, read the result, find the defect, change the source, measure.
