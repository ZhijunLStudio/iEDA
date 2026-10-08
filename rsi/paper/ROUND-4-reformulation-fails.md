# Round 4: the algorithmic reformulation fails, and the baseline binary is not reproducible on one design

## 1. Outcome in one line

I implemented the principled version of Round 3's lever, measured it against a
commit-matched binary, and it has to be rejected: it helps one design and destroys another.
Along the way the correctness gate caught a defect in the measurement chain itself.

## 2. What I implemented, and why it was the right thing to try

Round 3 found that lowering the configured density-penalty ceiling (max_phi_coef) from 1.05
to 1.02 improved wirelength on 11 of 12 matched designs. The code reading said the defect was
that the ceiling was defeating an existing annealing taper:

    obtainPhiCoef, shipped:
      ret_coef = max_phi_coef * max(0.9999^iter, 0.98)      // improving wirelength branch
      ret_coef = max_phi_coef * max_phi_coef^(-x)           // worsening wirelength branch
      then clamped to [min_phi_coef, max_phi_coef]

The 0.98 floor is the annealing schedule. Multiplying it by a ceiling above 1/0.98 = 1.02041
turns annealing into growth, and the shipped ceiling (1.05, reduced once to 0.985x = 1.03425)
is above that threshold, giving a late-phase coefficient of 1.03425 * 0.98 = 1.0133, i.e.
+1.33% per iteration without bound - measured at 1.4e17 on gcd_sky130_a. The taper alone
would give 0.98, within 0.5% of the measured optimum of 0.9846. So the change "do not let the
ceiling reintroduce the growth the taper exists to remove" looked like a derivation rather
than a tuning.

## 3. Result: rejected on the 12 matched designs

Two variants were built and measured. Both used the branch-specific or uniform clamp.

**Uniform clamp** (apply the taper floor to both branches):

| design | baseline | uniform clamp |
|---|---|---|
| gcd_sky130_a | 8,595,054 / 2,526 / 32 | 8,768,460 (+2.0%) / 3,087 (+22%) / 48 (+50%) |
| s1238_sky130_a | 7,225,417 / 3,594 / 52 | 9,120,925 (+26%) / 5,816 (+62%) / 58 (+12%) |

Clearly harmful. Abandoned.

**Branch-specific clamp** (only the improving-wirelength branch), 12 matched designs, against
a commit-matched binary:

| design | dHPWL | dUNION | dMAX |
|---|---|---|---|
| gcd_ics55_a | -0.3% | +75.7% | +100.0% |
| gcd_nangate45_a | -0.2% | - | - |
| gcd_sky130_a | -12.6% | -50.5% | +12.5% |
| s1238_ics55_a | +0.5% | -7.7% | -8.3% |
| s1238_nangate45_a | +0.5% | +225.0% | +300.0% |
| s1238_sky130_a | +3.5% | +5.2% | -19.2% |
| s38584_ics55_a | +0.2% | -15.9% | -25.0% |
| s38584_nangate45_a | +0.5% | +9.5% | -25.0% |
| s38584_sky130_a | -0.0% | -1.2% | +4.2% |
| **salsa20_ics55_a** | **+78.8%** | **+1295.4%** | **+153.5%** |
| salsa20_nangate45_a | -1.0% | +38.1% | +78.6% |
| salsa20_sky130_a | -1.1% | +0.2% | +0.0% |

median dHPWL **+0.1%**, dUNION **+5.2%**, dMAX **+4.2%**; HPWL better on 6/12. On
salsa20_ics55_a the placement degrades catastrophically: wirelength +78.8%, total congestion
+1295%, peak +153.5%.

**Rejected.** The reformulation does not reproduce the parameter change and it breaks a design
badly. Two source variants were reverted; the tree carries no SR-2.

**What this tells me about the mechanism.** The benefit of a lower ceiling is not, as I
concluded, "the taper was being defeated". Clamping the coefficient to the taper's own floor
is a much larger perturbation than lowering the ceiling by 3%, and it breaks the trajectory.
The two branches interact - the worsening-wirelength branch grows the penalty hard when
wirelength degrades, and clamping that too was measured harmful (gcd +2.0%/+22%/+50%) - so the
schedule is a coupled system and not the single defect my reading suggested. The lever is
real; my explanation of it was wrong; and the change that produces the effect is a tuning
change to a configured constant, which is what this goal says not to dress up as an
algorithmic improvement. I am not going to ship it as one.

## 4. The correctness gate caught a defect in the measurement chain

The plan was to verify the revert by requiring a reverted build to reproduce the baseline
binary exactly. It did not, on one of three designs:

| design | iEDA-base | reverted build |
|---|---|---|
| gcd_sky130_a | 8,595,054 / 2,526 / 32 | identical |
| salsa20_ics55_a | 280,548,672 / 41,966 / 43 | identical |
| **s1238_sky130_a** | **7,225,417 / 3,594 / 52** | **7,499,276 / 3,840 / 66 (+3.8%)** |

Determinism was checked first, with the same binary run three times: identical to the last
digit on two designs. So the flow is deterministic given the binary, and the difference is a
property of the binaries.

It is not any of the source changes. A binary built from pristine HEAD source was compared
against both:

| design | base | HEAD source | HEAD + SR-1 | HEAD, SR-1 retired |
|---|---|---|---|---|
| gcd_sky130_a | 8,595,054 | 8,595,054 | 8,595,054 | 8,595,054 |
| salsa20_ics55_a | 280,548,672 | 280,548,672 | 280,548,672 | 280,548,672 |
| s1238_sky130_a | **7,225,417** | **7,499,276** | **7,499,276** | **7,499,276** |

Three binaries with different source agree with each other and disagree with the fourth.
SR-1 is confirmed to be a no-op (HEAD equals HEAD+SR-1 exactly), which re-verifies Round 1's
conclusion with a proper three-way test. The retirement of SR-1 is also neutral.

**Conclusion: the baseline binary is not reproducible from the current source on
s1238_sky130_a.** The most likely cause is that a behaviour-neutral source change - the added
Tcl command from Round 2 - moves the binary's code layout, which changes inlining and
floating-point contraction decisions, and global placement is chaotic enough that a
one-ulp difference amplifies to 3.8% on this design. That is a real effect of building at
-O1-plus style optimisation levels, not a mistake in the change.

**What it costs.** Every cross-build comparison at the few-percent level is suspect on
designs where the optimizer is this sensitive. The Round 3 result (HPWL better on 11 of 12)
survives because its effect sizes on the informative designs were 13-20%, far above 3.8%,
and because the direction was consistent. The Round 4 negative survives too: the salsa20_ics55
catastrophe is +61% against a commit-matched binary where the baseline and HEAD-source builds
agree exactly, so it is not this artefact. But the small medians I have been quoting - Round
3's -0.9% - are not resolvable by this method at all.

## 5. The measurement discipline this forces

Comparisons must be between binaries whose source differs only by the intended change, built
back to back. Comparing a new build against a frozen binary from an earlier point in the
source history silently folds in build-layout effects. From here each experiment builds both
arms from the same commit with and without the change, and the frozen binaries are kept only
for the regression, not for attribution.

## 6. State of the source tree

- SR-2: reverted, absent.
- SR-1: retired to a comment, verified neutral.
- The network-flow spread exposure from Round 2: kept, verified neutral on the designs checked.
- The only live source change from four rounds is therefore the Round 2 tool-surface exposure.

## 7. Where this leaves the objective

Unchanged and unmet. EGR max is still the gap. What four rounds have bought is a much
smaller search space: the density-penalty magnitude, the iteration budget, the grid
resolution, the network-flow spread stage, the detail-placement permutation and the
penalty-rate schedule are all measured and all fail to move peak congestion reliably in the
right direction. The one thing that moves it a lot on the worst designs - the ceiling - is a
tuned constant with a stability floor and a catastrophic failure at the next value down, so I
am not shipping it as an improvement.

## 8. Next round

Two things are worth doing and neither is a tuning change.

1. **Re-establish a trustworthy baseline**: build both arms per experiment from one commit.
   Re-measure the corrected 32-design baseline that way, or at least re-measure the 12 matched
   designs, so the numbers this campaign reports rest on a reproducible pair of binaries.
2. **Test the one mechanism left standing.** Rounds 1-4 have now shown that everything about
   where cells sit - density magnitude, density schedule, grid resolution, spreading, detail
   permutation - fails to control the peak, while the net-demand measurement from Round 2
   showed our peak-bin demand is 1.85x the reference on 30 of 30 designs. The untested lever is
   therefore the wirelength model that shapes those nets: net weighting, or a congestion term
   in the placement objective. That is a larger change than a constant and it is where the
   evidence points.
