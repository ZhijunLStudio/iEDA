# Source iteration: change SR-1 and the loop that measures it

## SR-1: do not relax the density pressure while the placement is above its overflow target

File: src/operation/iPL/source/module/global_placer/electrostatic_placer/NesterovPlace.cc
(the density penalty update at the end of an iteration)

The penalty schedule reacted only to the wirelength trend:

    phi_coef = obtainPhiCoef((cur_hpwl - prev_hpwl) / reference_hpwl, iter)
    density_penalty *= phi_coef

obtainPhiCoef returns roughly max_phi_coef (~1.05, penalty grows) when wirelength improves,
and below 1 (penalty shrinks) when wirelength worsens. Nothing in the schedule reacts to
overflow. Measured on this tree: global placement does converge to its internal
target_overflow (median overflow/target = 1.00) but the placement it produces is more
cell-clustered than the commercial reference (gini 0.11-0.33 against 0.007-0.25, busiest
bin 1.3-1.4x), and peak trial-route congestion is the one dimension where we are clearly
worse than the reference (1.343x, no worse on 3 of 12 matched designs).

The change:

    if (_sum_overflow > _nes_config.get_target_overflow() && phi_coef < 1.0F) {
      phi_coef = 1.0F;
    }

This only forbids relaxing the penalty while overflow is above target. It never raises the
coefficient above what the wirelength heuristic allows, so the penalty cannot grow faster
than before - it can only stop shrinking early. That keeps the change interpretable: if the
placement gets less clustered, the cause is the removed relaxation, not a stronger push.

Predicted direction: lower peak density, therefore lower EGR max; risk of HPWL regression,
which is the dimension we are currently better on and must not give away.

## Two methodology fixes in the loop itself

1. **The binary is now a frozen, explicit input.** sourcesweep.py takes --bin, copies it
   into the run directory (runs/srciter/bin-<tag>/iEDA) and records its md5; every stage of
   the sweep invokes that copy.

   Why: a rebuild of build/bin/iEDA landed 17 minutes into a 32-design baseline and the
   remaining designs would have run a different binary. The baseline was discarded. The
   harness now makes that impossible, and the md5 is recorded so a dataset can be shown to
   come from one build.

   Verified: the running baseline's frozen copy has md5 c9761dc9, identical to iEDA-base.

2. **Two versioned binaries exist side by side** (build/bin/iEDA-base, build/bin/iEDA-sr1)
   so a comparison never depends on which build happens to be current.

## Lane note

This change touches src/operation/iPL, which per the repository conventions belongs to the
parity lane (deterministic kernels, QoR, performance), while this workspace is on an agent
branch. It is committed here so the work is not lost, and flagged so the branch placement
can be decided deliberately rather than by accident.

## How the change will be judged

Against the same 32-design frozen-binary baseline, on the matched 12-design cross-PDK
vector first. Accept only if:
- EGR max improves beyond the noise floor (median seed spread 5.92%, p90 26.05%), and
- HPWL does not regress beyond its noise floor (median 0.86%, p90 4.33%).

Anything inside the noise floor needs repeated seeds to claim.
