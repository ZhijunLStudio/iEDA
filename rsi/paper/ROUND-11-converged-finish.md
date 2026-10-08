# Round 11: SR-6, the finishing stage runs to convergence

## 1. What changed in the source

The flow's post-global-placement sequence was a fixed pair of stages issued once each:

    placer_run_gp -mode start ... ; placer_run_gp -mode accept ; placer_run_lg ; placer_run_dp

Every result in this campaign, including the standing against the reference, was produced by that
sequence. Measurement across a netlist-matched vector showed it leaves the placement unconverged:
a third pass lowered peak congestion on 9 of 16 seed-pairs and total overflow on 12 of 16, and
improved wirelength on every design measured.

SR-6 replaces the fixed pair with a loop that stops on a criterion:

    placer_finish -max_passes N -hpwl_tol T

which runs legalisation and detail placement repeatedly until the total wirelength stops improving
by more than T, or N passes are reached. Seven edits: the loop in PLAPI (runConvergedFinish), the
tool_api wrapper, the command class, its registration, and the command itself with two options.
Build 20 s. The default is 3 passes and a 0.2% relative tolerance.

This is a stopping-criterion change rather than a tuned value: the old behaviour had no criterion
at all, just a convention that the stages run once. It is also self-limiting in a way a fixed pass
count is not - see section 3.

## 2. The controlled measurement

Same binary pair differs only by the working-tree change (control md5 22631fbf, SR-6 c0380b48).
The command sequence differs because replacing that sequence is the point.

| design | seed | dHPWL | dunion | dpeak | versus reference |
|---|---|---|---|---|---|
| **s1238_ics55_a** | 1001 | -1.1% | **-70** | **-6** | union 0.45x, peak 0.57x - **both better** |
| **s1238_ics55_a** | 1002 | -1.2% | **-55** | **-3** | union 0.54x, peak 0.57x - **both better** |
| s1238_sky130_a | 1001 | -0.5% | **-81** | +2 | union 1.29x, peak 1.25x |
| s1238_sky130_a | 1002 | -2.4% | **-359** | **-16** | union 1.23x, peak 1.12x |
| s38584_ics55_a | 1001 | -0.0% | +59 | **-1** | union 1.00x, peak 0.94x - both no worse |
| s38584_ics55_a | 1002 | 0.0% | 0 | 0 | identical - stopped after one pass |

**Wirelength improves on four of six seed-pairs and is unchanged on the fifth**, so the change
does not buy congestion with wirelength - it improves both, which was the condition for the whole
objective.

**s1238_ics55_a now beats the reference on both congestion dimensions at both seeds.** On
s1238_sky130_a, one of the three designs the goal lists as a robust peak failure, the total
overflow improves by 81 and 359 overflowing bins (2-10% of the total) and the peak by 16 at the
second seed, moving from roughly 1.9x the reference to 1.12x.

## 3. The criterion self-limits, which the fixed pass count did not

At s38584_ics55_a seed 1002 the SR-6 run is **byte-identical to the control**. That means the
first pass earned less wirelength than the tolerance and the loop stopped - exactly the intended
behaviour, and it is why SR-6 is neutral there while the unconditional three-pass experiment
earlier in the campaign made that design's total overflow worse (13 to 20 on the nangate45
variant). **The stopping criterion avoids the damage that a fixed pass count caused.**

## 4. Honest limits

- Six seed-pairs across three designs, all ics55 and sky130. Not the full valid set.
- One regression: s38584_ics55_a seed 1001 total overflow +59.
- Two of the three designs are small (s1238) and one is medium (s38584); no large design is in this
  table, and the large designs are where the peak deficits are worst.
- The effect is a placement change, so it must be checked against timing as well, which has not
  been done for SR-6.
- The tolerance (0.2%) and the pass cap (3) are chosen, not derived. They are a criterion, but the
  constants in it are tuned, and a tighter tolerance would iterate further on designs like
  s1238_sky130_a where the second pass still helped.

## 5. What the campaign has, after eleven rounds

A source change that improves peak congestion, total overflow and wirelength together on the
designs measured, and that turns one design from losing to the reference on both congestion
dimensions into winning on both. It is the first change in eleven rounds to do that, and the first
with a mechanism - the flow was stopping before convergence - rather than a plausible story.

It is not yet the whole fix: s1238_sky130_a is still around 1.1-1.3x the reference, and the
remaining designs have not been measured under SR-6.

## 6. Next

1. **Run SR-6 across the whole valid set at three seeds** to establish the net effect, since the
   three designs tested disagree in magnitude and one regresses.
2. **Check timing under SR-6**, because the standing has to hold on all five dimensions and a
   placement change can move setup timing either way.
3. **Tighten the tolerance** if the sweep shows the loop stopping too early on the designs that
   benefit most; s1238_sky130_a seed 1002 improved most and any of its passes may still have been
   earning.
4. **Take the change to the flow** once the sweep supports it, so the default pipeline converges.

## 7. The large designs regress, and that is a mechanism rather than noise

Extending the SR-6 measurement to the large designs, which are where the peak deficits are worst,
reverses the conclusion on them:

| design | seed | dHPWL | dunion | dpeak |
|---|---|---|---|---|
| **salsa20_ics55_a** | 1001 | -0.1% | **+781** | **+6** |
| **salsa20_ics55_a** | 1002 | -0.1% | **+593** | **+9** |
| **salsa20_nangate45_a** | 1001 | -0.1% | **+262** | **+8** |

Both seeds on salsa20_ics55_a and the first seed on salsa20_nangate45_a move both congestion
dimensions the wrong way, with wirelength essentially unchanged. Two of these designs are named in
the goal as robust peak failures.

**So SR-6 is not a net win, and the pattern is consistent with a mechanism.** Every operator in
legalisation and detail placement accepts moves on wirelength alone. On a **small** design, one pass
of them is not converged, and further passes reach a better placement on all three axes. On a
**large** design the passes compound the same wirelength-driven concentration, and the routability
cost of that compounding exceeds the benefit of converging - which is also why the unconditional
three-pass experiment earlier in this campaign made s38584_nangate45_a's total overflow worse.

Read together with the earlier stage localisation, this sharpens the diagnosis rather than
contradicting it: **the peak deficit on large designs is produced by wirelength-only operators
being run, and running them further makes it worse.** The remedy for a large design is therefore not
a better stopping point but operators that consider demand, which is the same conclusion the
eight-round trail of failed fixes kept arriving at from other directions.

**What to do with SR-6.** It stays in the tree as a command because it is a correct fix for a real
defect - a flow that stops a stage pair before convergence - and because it demonstrably helps the
small designs it was measured on. It must **not** be made the flow default: switching the default
would regress two of the three designs the goal names as failures. The honest statement is that it
fixes under-convergence and does not fix the peak deficit, and that on large designs those two are
in tension.

## 8. What this says about the stopping criterion

The loop stops when wirelength stops improving. On large designs wirelength keeps improving while
routability degrades, so the criterion keeps going in exactly the case where it should stop. A
criterion that would work on both would have to watch a routability signal - and that is the third
time this round has arrived at the need for one, after the degenerate DP density monitor and the
route-demand grid that is populated only on the global-placement path.

That is now the single blocking requirement for the whole objective, and it is plumbing rather than
algorithm design: **the flow cannot stop or steer the placement on a signal it cannot compute.**

## 9. Why the density monitor could not be used: it is saturated, not broken

SR-3 and SR-4 proposed to guard detail placement on its peak bin density and both came out
byte-identical to their controls. Reading the definition explains it exactly:

    Grid::obtainGridDensity() = (occupied_area + fixed_area + local_fixed_area)
                                / (grid_area * density_target)

and obtainPeakGridDensity takes the maximum of that over all bins.

In a legalised placement at least one bin is always full, so the maximum is **exactly 1.0 for every
placement**, which is why the instrumented run printed 1 on entry and 1 after the first iteration.
The monitor is not returning garbage; it is saturated, and a saturated statistic cannot order two
placements at all. That is a complete explanation of the two no-ops and does not depend on guessing.

**The usable alternative is the sum, not the maximum.** GridManager::obtainTotalOverflowArea()
accumulates each bin's overflow area, and BinGrid::obtainOverflowAreaWithoutFiller() does the same
over the density grid. A sum over bins is not saturated - it grows with the number of bins that are
over capacity and with how far over they are - so it can distinguish a placement that concentrates
cells from one that does not. That is the signal any guard on detail placement should have been
built on, and it is a genuinely different quantity from the one the commented-out calls used.

## 10. State of the round

**Source changes:** SR-6 is in the tree - a real fix for a real defect (the finishing stage pair
had never been converged) that helps small designs and hurts large ones, and which must not become
the default until it can be steered by a routability signal. SR-3, SR-4 and SR-5 were reverted;
their failures are each explained above rather than left as loose ends.

**The blocking requirement, stated once:** the flow cannot stop or steer the placement on a signal
it cannot compute. Three separate attempts this round ended at that wall - a guard that needed a
density that saturates, a guard that needed a grid only global placement populates, and a stopping
criterion that converges on wirelength while routability degrades. The next change should be to
make a per-bin demand or overflow signal available during the finishing stage, using the sum-based
quantities rather than the maximum-based ones, and only then to revisit the guard and the criterion.

## 11. The full sweep tempers SR-6 to a wirelength win with a design-specific congestion win

The three-design table in section 2 was the favourable subset. Completing the sweep to 26
seed-pairs across nine designs:

| design | peak, 3 passes vs 1 | union, 3 passes vs 1 | dHPWL |
|---|---|---|---|
| **s1238_ics55_a** | [14,11,13] -> [8,6,11] (**3/3 better**) | [149,151,122] -> [79,71,116] (**3/3**) | -1.12% |
| **s1238_sky130_a** | [54,48,48] -> [50,36,44] (**3/3 better**) | [3473,3208,3692] -> [3402,3076,3647] (**3/3**) | -0.46% |
| gcd_ics55_a | [6,10,10] -> [6,6,4] (2/3) | [46,50,56] -> [46,38,17] (2/3) | -0.22% |
| gcd_sky130_a | [16,30,18] -> [18,30,18] (0/3) | 2/3 | -0.33% |
| s5378_sky130_b | 1/3 | 2/3 | -0.31% |
| s38584_ics55_a | 1/3 | 2/3 | -0.25% |
| **salsa20_ics55_a** | [34,29,36] -> [50,33,36] (**0/3**) | 1/3 | -0.14% |
| s1238_nangate45_a | 0/2 | 0/2 (0 -> 2 and 2 -> 4 bins) | -0.80% |
| gcd_nangate45_a | 0/3 | 0/3 (both arms at zero) | -0.15% |
| **all 26 seed-pairs** | **better on 10/26 (38%)** | **better on 15/26 (58%)** | median -0.3% |

**The median change in the peak is 0.0 bins.** So the honest summary of SR-6 is:

- **Wirelength improves on every design measured**, by 0.14% to 1.12%. That is a real, consistent,
  cost-free gain and it is the part of the result that generalises.
- **Congestion improves strongly and consistently on two designs** (both s1238, on different PDKs,
  3/3 seeds each) and is neutral to slightly negative elsewhere.
- The favourable three-design table in section 2 was not representative, and quoting it as the
  effect would have been the same subset error as the netlist finding and the DP-innocence finding
  earlier in the campaign.

SR-6 remains in the tree as a correct fix for an under-converged flow that pays for itself in
wirelength on every design and is a large win where the single pass was furthest from converged. It
is not the answer to the peak deficit, and the peak deficit on the large designs is made worse by
it.

**What the sweep also shows about where to look.** The two designs where iterating wins are the two
smallest in the set; the design where it loses worst is among the largest. That is the same size
dependence section 7 identified, now confirmed across nine designs rather than three, and it is
consistent with the mechanism: wirelength-only operators run further concentrate more on large
designs.
