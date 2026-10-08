# Round record: corrected baseline, and four rejected hypotheses about peak congestion

## 1. The corrected baseline (the round's deliverable)

32 designs, plain (config-driven) flow, single frozen binary (md5 c9761dc9), one seed,
compared against the commercial reference DEF with one evaluator.

| dimension | median ratio | no worse than the reference |
|---|---|---|
| HPWL | **0.924** | 25 / 32 |
| EGR union | **0.835** | 20 / 32 |
| EGR max | **1.358** | **5 / 32** |
| all three at once | | 5 / 32 |

This replaces the numbers this goal was written against (HPWL 0.935 / 20, union 1.049 / 14,
max 1.956 / 8, all-three 8/32), which came from the regressive generation path. See
CORRECTION-anchoring.md.

**What it means for the objective.** We are already better than the reference on both
wirelength (0.924x) and total congestion (0.835x). The single remaining systematic gap is
**EGR max** (1.358x, and no worse on only 5 of 32 designs). The objective's phrasing
"congestion is the problem" is therefore too broad; peak congestion is the problem, and
the two nangate45 "catastrophes" in the goal text do not exist in this baseline.

Worst designs by EGR max ratio: s1238_sky130_a 2.19x, apb4_uart_sky130_b 2.08x,
s38584_nangate45_a 2.00x, s1488_sky130_b 1.88x, picorv32 1.85x. The gap is a broad
1.4-2.2x on the peak, not a few outliers.

## 2. Where the clustering comes from (stage-localized)

Shape statistics after each stage, versus the reference (instances per 64x64 bin):

| design | gini GP | +LG | +LG+DP | reference | max bin GP | +LG | +LG+DP | reference |
|---|---|---|---|---|---|---|---|---|
| gcd_sky130_a | 0.345 | 0.336 | 0.339 | 0.326 | 5 | 5 | 5 | 5 |
| s1238_sky130_a | 0.324 | 0.322 | 0.324 | 0.311 | 5 | 5 | 5 | 5 |
| aes | 0.564 | 0.467 | 0.508 | 0.235 | 438 | 139 | 145 | 23 |
| s38584_sky130_a | 0.512 | 0.358 | 0.358 | 0.271 | 46 | 16 | 16 | 18 |
| salsa20_sky130_a | 0.466 | 0.363 | 0.359 | 0.196 | 97 | 30 | 29 | 27 |

Small designs are already at parity. On large designs global placement is the source,
legalization repairs most of it, and **detailed placement raises it again** (aes 0.467 to
0.508). That last step is a concrete next target: DP is the cheapest stage and it is
re-clustering.

## 3. The shape indicator is a weak proxy (honest negative)

Correlation with our own EGR max over the 32-design baseline:

| indicator | vs EGR max | discordance | vs EGR union | vs HPWL |
|---|---|---|---|---|
| our gini | +0.358 | 36% | +0.510 | +0.410 |
| our max bin | +0.553 | 27% | +0.768 | **+0.960** |
| gini delta vs reference | +0.501 | 31% | +0.570 | +0.643 |
| max-bin ratio vs reference | +0.272 | 39% | +0.395 | +0.404 |

Better than no information (50% discordance) but not a clean screen, and max bin
correlates with HPWL at +0.96, so using it to screen for EGR max would mostly be tracking
the objective we must not give away. **Not adopted as a screening signal.** The indicator
remains useful as a description of the mechanism.

## 4. Four hypotheses tested and rejected

All four were cheap, and three of them needed no source change at all: they are
config-only experiments, which also means any effect cannot be called an algorithm change
(it is not one).

**H1 - forbid relaxing the density penalty while above the overflow target (SR-1, a source
change).** The change was:

    if (_sum_overflow > target_overflow && phi_coef < 1.0F) phi_coef = 1.0F;

Result: byte-identical placements. Reason, found by reading the two branches: phi_coef < 1
requires the wirelength to worsen by more than reference_hpwl in a single iteration, while
overflow > target holds only early, when wirelength is still improving so phi_coef is about
1.05. **The two conditions are effectively disjoint.** SR-1 is dead code in practice.
Committed as a no-op with this explanation rather than reverted silently.

**H2 - never let the penalty shrink (min_phi_coef = 1.0, config only).** Result: 9 of 9
tested designs byte-identical on all three dimensions (8 in the first batch, plus aes
specifically because it was the design where the penalty was suspected of collapsing). One
design (s1488_sky130_b) got worse: +3.09% HPWL, +9.04% union, +6.25% max.

**Self-correction.** H2's identical results disprove the mechanism I had inferred. I had
compared the configured init_density_penalty (8e-5) against the recorded runtime
density_penalty (1e-6 for aes) and concluded the penalty had collapsed 80x. In fact the
runtime penalty is initialized as (wirelength_grad_sum / density_grad_sum) *
init_density_penalty (NesterovPlace.cc near line 893), so the recorded 1e-6 is roughly the
initial value after that ratio, not the end of a decay. Since min_phi_coef = 1.0 changes
nothing, phi_coef was never below 1 and the penalty was never relaxed. **The penalty
schedule is not the mechanism.**

**H3 - give global placement more iterations (max_iter = 6000, config only).** Result on
the three designs that hit the 2000-iteration cap: gcd_sky130_a got worse (+3.99% HPWL,
+29.72% union, +21.43% max); s1238_sky130_a and s1488_sky130_b failed to produce metrics at
all. More density pressure does not reduce the peak.

**H4 - refine the density grid (adaptive off, 512x512, config only).** Result: inconsistent
and dominated by harm. apb4_uart_sky130_b improved on the peak (54 to 48, -11.1%) at +1.4%
HPWL; aes_core_sky130_b got much worse (76 to 96, +26.3%) at +9.9% HPWL; s1238_sky130_a
failed.

**Convergent conclusion.** Four different ways of pushing the density model harder
(stronger floor, no relaxation, more iterations, finer grid) either do nothing or make
things worse. The limiter is therefore not the magnitude or the stopping rule of the
density penalty. That eliminates a large family of obvious changes and is the main reason
this round is worth having.

## 5. Global placement convergence diagnostics (open lead)

Across the 32-design baseline: most designs stop after 430-584 iterations with overflow
about 0.099 (just inside the 0.1 target), but **three designs use the full 2000 iterations
and end above it**: gcd_sky130_a (0.1233), s1238_sky130_a (0.1280), s1488_sky130_b (0.1270).
The density penalty on those runs reaches 6e16 to 1.4e17, so the wirelength term becomes
negligible, and the peak congestion is still not resolved.

Open discrepancy worth chasing: the recorded effective_target_density is **0.60 for 25 of
32 designs and 0.70 for the nangate45 designs**, while every one of their placement configs
says target_density: 0.8. Whatever lowers it from 0.8 to 0.6 also changes what GP is trying
to achieve, and no result in this campaign has controlled for it. This is the highest-value
unknown remaining.

## 6. Harness changes (attribution and robustness)

1. **The binary is a frozen per-sweep input.** sourcesweep.py copies it to
   runs/srciter/bin-TAG/iEDA and records its md5; only that copy is invoked. Motivated by a
   real event: an earlier rebuild landed 17 minutes into a 32-design baseline and would have
   mixed two builds into one dataset. That dataset was discarded.
2. **Records merge incrementally**, so a sweep that dies part-way leaves a usable dataset.
3. **Log-based reconstruction** (analysis/reconstruct_sweep.py), with per-field provenance,
   for the case where a sweep printed results but never wrote its record. That is how the
   32-design baseline was recovered.
4. **Config-patch mode** (--config-patch with a JSON dict of dotted overrides), which is what
   made H2-H4 testable without touching source, and which makes it impossible to mistake a
   configuration effect for an algorithm improvement.
5. **Placement-shape statistics** as a first-class harness module
   (harness/placement_shape.py) plus a validation script (analysis/analyse_cluster.py).

## 7. A process-management error, recorded

While stopping one sweep I issued a blanket pkill on the iEDA binary, which killed the child
of a different, still-running sweep. gcd_sky130_a lost its metrics and had to be re-run.
Killing by process group (runs/*.pgid) is the only safe way to stop one of these runs, and
blanket kills of shared binaries must not be used while any sweep is in flight.

## 8. Next, in value order

1. **The effective-versus-configured target density discrepancy (0.60 versus 0.80).** It
   changes the objective GP is solving, no campaign result controls for it, and it is
   straightforward to trace in the source.
2. **Detailed placement re-clusters** (aes 0.467 to 0.508 after DP). DP is the cheapest
   stage, it has a clear mandate, and the effect is measured. First source target.
3. **The three non-converging designs**, once (1) is understood.
4. Do not pursue penalty-strength or grid-resolution changes without new evidence.
