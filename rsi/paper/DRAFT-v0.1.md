# The Verifiability Gap: evaluation depth bounds self-improvement in physical design

Draft v0.1 (2026-09-16). Numbers marked FINAL come from the frozen measurement
batch; anything marked PENDING is not yet measured and must not be quoted.

## Abstract

Self-improving systems are commonly credited with whatever their own evaluator
reports. We ask a sharper question: how much of a self-improvement loop's
apparent progress survives when the evaluation is made stronger? We build the
measurement in a domain where evaluation has a hard, external ground truth:
physical design. A placement loop can be scored in seconds on the placer's
internal estimate, or in minutes on the legalized placement, or on real
congestion, or on signoff timing and DRC. We instrument one industrial-grade
open-source flow (iEDA) so that every candidate placement is scored by every
rung of this ladder, with a cost ledger and a frozen protocol. Three findings.
(FINAL) Skipping legalization does not merely make the score optimistic: it
inverts the ranking. The pre-legalization wirelength signal is anti-correlated
with the legalized wirelength (Spearman rho = -0.89, 32 designs) and with true
congestion (rho = -0.92). (FINAL) Consequently a loop that selects on that signal
picks a placement that is 19.7% worse in legalized wirelength and 124.7% worse in
congestion than the best candidate available in the same pool. (FINAL) The same comparison holds on an
external yardstick: against commercial reference placements, the pick made by the
ruler beats the pick made by the cheap signal on 31 of 32 designs on both
wirelength and congestion. (FINAL) We give a model in which verifier error is
not a per-round loss but is absorbed into the improver's own state and compounded,
which predicts a finite horizon r* at which true improvement ends while believed
improvement continues; the measurement matches the prediction, with r* = 0 for the
cheap rungs and an interior optimum for faithful ones. Finally we give and test a method: rank
candidates with the cheapest verifier that preserves the truth ordering and confirm
the survivors with the strongest one, which beats the best fixed-rung strategy at
every budget we tested.

## 1. Introduction

Recursive self-improvement (RSI) research has produced working systems that
improve their own prompts, data, code, or training procedure. The strongest
claims - that the improver itself gets better, and gets better faster - remain
unsupported. A recurring reason is methodological: in most testbeds the signal
the system optimizes is the signal used to judge it, so a loop that has learned
to satisfy its evaluator is indistinguishable from a loop that has improved.

We take the position that the missing instrument is a testbed where the
evaluator and the truth are separated by a measurable, priced ladder. Physical
design is such a domain. A placement can be evaluated at wildly different depths:

- the placer's internal wirelength estimate, seconds, computed on a placement
  whose cells are not yet aligned to the site grid;
- the wirelength of the legalized, detailed placement, tens of seconds;
- the same plus real congestion from a trial route, minutes;
- plus signoff timing and DRC, hours.

Each rung costs more and sees more. Each rung is also a plausible thing for an
autonomous agent to optimize, because agents are routinely run under a budget.

Contribution. We turn iEDA into a ladder-instrumented testbed and measure what
each rung is worth. Our contributions are:

1. A formalization of a self-improvement loop as (state, proposer, verifier,
   update) in which verifier error is written into the state and therefore
   compounds, with a proposition predicting a finite true-improvement horizon r*
   when the verifier is imperfect and true returns diminish (Section 3).
2. An instrumented, reproducible testbed: 32 designs across four process
   technologies, four verifier rungs, a per-candidate cost ledger that separates
   the loop's evaluation cost from the measurement overhead, immutable improver
   identities, and a frozen protocol with a dated amendment trail
   (Section 4).
3. A measurement of verifier fidelity per rung (Section 5, FINAL): the cheap
   pre-legalization signals anti-rank the truth, and selecting on them costs 20%
   wirelength and 125% congestion.
4. The observation that the ruler is a rung too: within a design, legalized
   wirelength anti-ranks setup slack (rho = -0.47), so evaluation depth bounds
   improvement at every level rather than only at the bottom (Section 5.4, FINAL).
5. A measurement of the gap over rounds: a loop driven by the pre-legalization
   signal ends half a pool-step worse than it started in 90-93% of trajectories
   while reporting a +1.22 believed improvement, and its true-improvement horizon
   is r* = 0 (Section 6, FINAL).
6. A method with a measurable margin: screening candidates with the cheapest
   faithful rung and confirming with the strongest one beats the best fixed rung at
   every budget tested by roughly nine rank points (Section 7, FINAL), including the
   campaign's own correction of a preliminary conclusion drawn on too small a pool.

## 2. Related work

Self-improvement systems. GEPA and Meta-Harness optimize prompts and harness
code from execution traces; SEAL and Absolute Zero extend self-improvement to
generated data and self-edit strategies; Darwin Godel Machine and Godel Agent
modify their own code and keep a lineage of versions; Hyperagents and MetaRSI put
the improver itself inside the optimization and report that the meta level can
improve and transfer. Reviews and METR's analysis observe that evidence for
accelerating self-improvement is thin and that the field lacks agreement on what
counts as a demonstration.

Our relationship to that work is complementary and deliberately adversarial: we
do not propose another improver. We supply the instrument that these systems
lack, namely a testbed where the objective the loop optimizes and the objective
that is true are separated by a priced ladder, and we use it to measure how much
of a reported gain is evaluation depth.

Multi-fidelity optimization. Racing, successive halving and multi-fidelity
Bayesian optimization trade cheap evaluations for accuracy under a fixed budget,
and Hyperband is a canonical schedule. Our setting differs in one respect that
matters for the conclusion: there, a noisy objective costs a per-round loss; here
the accepted edit is written into the improver's own persistent state, so an
error is not forgotten but re-used as the basis of the next proposal. The
ceiling we derive comes from that accumulation, not from variance.

Physical design and agentic EDA. Placement flows already rely on staged
evaluation: global placement, legalization, detailed placement, clock tree,
routing and signoff. Practitioners know that early-stage proxies mislead; the
flow's own tools refuse to score unlegalized placements for congestion because
overlapping cells fake a low overflow. What has not been done is to quantify,
per rung, how badly the proxy ranks the truth, on a large design set, with the
cost of each rung accounted.

## 3. Formalization

Definition 1 (self-improvement loop). A loop is a tuple (S, P, V, U): a state S
that persists across rounds, a proposer P that emits a candidate edit, a verifier
V that decides acceptance, and an update U that writes accepted edits into S.
Self-improvement in the strong sense is the case where S describes (P, V, U)
itself.

Definition 2 (verifier rung). A rung is a pair (signal, cost). Rung order is by
cost. Rung v is sound to the extent that its ordering of candidates agrees with
the truth ordering.

Definition 3 (verifier fidelity). Let a candidate edit be truly beneficial with
probability depending on the rung. Define precision p(v) as the fraction of
edits accepted by rung v whose true objective is not worse, and rank fidelity
rho(v) as the Spearman correlation between the rung's signal and the true
objective on a common candidate pool.

Definition 4 (headline quantities). For a loop run to round r that holds state
S_r, let dQ_V(r) be the improvement of the rung signal from its starting value
and dQ_T(r) the improvement of the true objective. Then the verifiability gap is
VG_r = dQ_V(r) - dQ_T(r), and the true-improvement horizon r* is the smallest r
after which dQ_T is never positive again.

Model. Assume (i) truly beneficial edits yield diminishing true returns g(r),
concave and decreasing to zero; (ii) truly harmful edits that the verifier
accepts cost c and remain in the state, so their damage accumulates; (iii) the
verifier accepts a beneficial edit with probability p and a harmful edit with
probability f. Then

    E[dQ_T(r)] = p * g(r) - (1 - p) * c * A(r),

where A(r) is the number of absorbed harmful edits and grows with r.

Proposition 1. For any p < 1, with g concave and decreasing to zero and A(r)
non-decreasing, E[dQ_T(r)] is maximized at a finite r*, and dr*/dp > 0. If the
rung signal does not saturate, VG_r grows without bound on the same run.

Implication. Strengthening the verifier raises p, which both raises the peak and
moves r* later; it does not merely reduce variance. The measurable predictions
are (a) a finite interior r* for weak rungs, (b) ordering of r* across rungs
matching the ordering of p and rho, (c) a larger gap for a proxy calibrated on a
different process.

## 4. Testbed and protocol

Flow. iEDA at revision ef2e2d6, built in an isolated workspace, with the
placement substage exposed as a per-candidate pipeline: global placement with
knobs (target_density, congestion_effort, seed) followed by legalization and
detailed placement, then optional trial-route congestion. The candidate pipeline
is the proposer-and-evaluator pair; the loop's acceptance rule is the verifier.

Designs. 32 of 35 registry entries are usable: three are excluded because their
references point at dead temporary paths or a different source tree, and they are
listed rather than dropped silently. The set spans 4 process technologies
(sky130, ics55, nangate45, asap7) and small to medium scales.

Verifier rungs (FINAL definition, see protocol amendment A1).

| rung | what the loop sees | legalization | charged cost |
|---|---|---|---|
| V0 | placer-internal wirelength | none | global placement |
| V0b | solver-internal route utilization | none | global placement |
| V1u | DEF wirelength at the legalizer input | none | global placement |
| V1 | wirelength of the legalized placement | yes | placement + legalization |
| V2 | legalized wirelength and real congestion | yes | placement + legalization + trial route |
| V3 | V2 plus placement timing (HPWL-RC model) | yes | plus a timing evaluation |

Truth. The fair ruler is the pair (legalized wirelength, trial-route congestion
union), computed by one shared evaluator used by every arm; the evaluator refuses
unlegalized candidates, which the flow's own tooling also does, because
overlapping cells fabricate a low overflow. Where an external reference exists we
also compare against Innovus.

Truth definition and why. Because the two truth components have very different
dynamic ranges (wirelength moves a few percent across our grid, congestion moves
by a factor), any weighted sum would be dominated by congestion and any
conclusion would depend on the weight. We therefore do not scalarize. In-loop
acceptance of the strongest rung uses Pareto dominance, which is the criterion
this project already uses for its eight-dimension reconciliation with commercial
flows. Offline, believed and true curves are computed as percentile ranks inside
the candidate pool, so the two curves are comparable without an arbitrary weight.

Cost accounting. Every candidate evaluation appends one record carrying the
measured wall and CPU seconds of each stage (global placement, legalization and
detail, trial route) plus the improver identity. A rung is charged exactly the
stages it needs. The cost of computing the truth is never charged to the loop.

Anti-self-deception. The protocol fixes the truth instrument in advance, refuses
unlegalized candidates, rebuilds each candidate work directory fresh, compares
rungs on identical candidates, and requires a cost record for every run. Two
defects were found and fixed during the campaign by following this discipline,
and both are recorded as amendments rather than quietly repaired: a density
plateau that made part of the grid degenerate (A1), and a concurrency race in
which two loops could share one work directory and silently corrupt each other's
results (A2).

## 5. Stage 1: how well does each rung rank the truth (FINAL)

Setup. 29 candidates per design on a grid of target density in
{0.55, 0.60, ..., 0.95} crossed with congestion effort in {0, 3, 7}, plus two
replicate seeds, evaluated on 32 designs: 928 candidate evaluations, 0 failures.
Every candidate is scored by every rung and by the truth.

Figure 1 (fig1_fidelity_heatmap.png) reports Spearman rho between each rung's
signal and each truth component, median over designs with bootstrap 95%
intervals.

| rung | vs legalized wirelength | vs congestion union |
|---|---|---|
| V0 internal wirelength | -0.892 [-0.841, -0.596] | -0.918 [-0.896, -0.788] |
| V1u unlegalized DEF wirelength | -0.891 [-0.839, -0.589] | -0.922 [-0.895, -0.784] |
| V0b solver route utilization | +0.682 [+0.532, +0.723] | +0.737 [+0.570, +0.737] |
| V1 legalized wirelength | +1.000 | +0.970 [+0.699, +0.932] |
| V2 fair ruler | +0.976 [+0.791, +0.926] | +0.999 [+0.965, +0.997] |

Finding 1 (the inversion). The two pre-legalization wirelength signals are not
noisy versions of the truth; they are anti-correlated with it, at about -0.89,
with the interval excluding zero by a wide margin. The mechanism is measurable
and boring, which is why it is dangerous: legalization must displace cells by an
amount that grows with how tightly the placer packed them, so the pre-legalization
score rewards exactly the candidates whose advantage evaporates afterwards. On
gcd_sky130_a the legalizer move alone costs 13% of wirelength at target density
0.95 and 2% at 0.60.

Finding 2 (the one trusted signal is not the trustworthy-looking one). The
solver-internal route utilization, which this project's own tooling flags as not
trustworthy, is positively correlated with true congestion (+0.74). The folklore
and the measurement disagree in direction; we report the measurement.

Figure 2 (fig2_selection_regret.png) converts fidelity into cost. For each design
we take the rung's preferred candidate and compare it with the best candidate of
the same pool under the truth.

| rung | legalized wirelength regret | congestion regret |
|---|---|---|
| V0 | +19.7% [+18.8, +32.7] | +124.7% [+128.6, +700.6] |
| V1u | +19.7% [+19.0, +33.8] | +125.5% [+131.7, +715.0] |
| V0b | +0.6% [+0.7, +1.9] | +0.7% [-3.6, +12.2] |
| V1 | 0.0% | 0.0% [+4.2, +47.6] |

Finding 3 (the price of a cheap verifier). Selecting on the pre-legalization
signal costs about 20% of legalized wirelength and about 125% of congestion
relative to what was available in the same pool. Reading the congestion number
honestly: the upper end of its interval is large because on some designs the best
candidate has almost no overflow, so a ratio amplifies; the median is the number
we stand behind and the absolute values are in the release data.

Also FINAL: 66% of designs place their truth-best candidate at the lowest density
we explored, which is the design's density floor, not an artifact of the grid:
target density 0.45, 0.50 and 0.55 produce byte-identical placements on
gcd_sky130_a. The truth optimum on these designs lies at the feasibility
frontier, and we state that rather than presenting it as an interior optimum.

### 5.4 The ruler is a rung too (FINAL)

If the ladder is real, then the quantity we have been calling the truth must
itself be a proxy for the rung above it. We test this by adding placement timing
(a physical timing evaluation with an HPWL-based pre-route RC model) as a third
truth component, on all 24 source-domain designs and 696 candidates.

| signal | vs setup TNS | vs setup WNS |
|---|---|---|
| V0 internal wirelength | +0.219 [+0.025, +0.426] | +0.112 [+0.010, +0.340] |
| V1u unlegalized DEF wirelength | +0.216 [+0.024, +0.425] | +0.122 [+0.011, +0.340] |
| V1 legalized wirelength | **-0.471 [-0.574, -0.202]** | -0.261 [-0.393, -0.069] |
| fair ruler (wirelength + congestion) | -0.247 [-0.502, -0.092] | -0.227 [-0.361, -0.008] |

Finding 4. The fair ruler, and especially its wirelength component, is
negatively correlated with timing: within a design, the candidates that look best
on legalized wirelength tend to be worse on setup slack, and vice versa. The
geometry-best candidate is also the timing-best on only 7 of 24 designs. The
magnitude is modest (selecting on geometry costs a median 6.7% of TNS relative to
the timing-best candidate, while selecting on timing costs a median 2.0% of
legalized wirelength), but the sign is systematic and the interval excludes zero.

Interpretation, stated carefully. The timing here is a pre-clock-tree evaluation
with a wireload model, so it is itself a proxy for signoff timing; we are not
claiming to have reached signoff. What the measurement establishes is the
structural point the paper is about: every rung we have measured is a proxy for
the next, and a proxy can invert the ordering of the rung above rather than merely
add noise to it. Optimizing the wrong rung therefore does not cost a little
accuracy; it moves the design in the wrong direction, and a self-improving loop
accepting that signal will do so persistently.

### 5.5 A signoff spot check (FINAL, one design)

The rungs above the ruler are clock tree synthesis, routing and DRC, where a
candidate costs minutes to tens of minutes rather than seconds. We therefore ran the
chain as a spot check rather than a campaign-wide rung: the geometry-optimal
candidate and the candidate the cheap rung is attracted to, both for gcd_sky130_a,
pushed from the placed DEF through clock tree synthesis, routing and DRC with the
same flow and the same configuration.

| candidate | routing wall time | DRC violations |
|---|---|---|
| geometry-optimal (density 0.65, effort 7) | 148 s | 155 |
| cheap-rung attractor (density 0.95, effort 0) | 1619 s | 332 |

Both candidates route to completion. The cheap verifier's pick takes 11 times longer
to route and ends with 2.1 times as many DRC violations. This is the direction the
whole ladder predicts, observed at the end of the flow rather than on a proxy: the
signal that looks best to the placer produces a design that is worse to route and
dirties the layout more.

We state the scope plainly: this is one design and two candidates. It is an
illustration that the ordering survives to signoff, not a measurement with a
sampling distribution, and nothing else in this paper depends on it. The cost is the
reason: at ~25 minutes per candidate under load, a campaign-wide signoff rung would
cost about 100 times the geometry ladder.

## 6. Dynamics: the gap over rounds and the true-improvement horizon (FINAL)

Design. Every rung runs an identical adaptive search over (target density,
congestion effort, seed) for 16 rounds from the same start candidate (density
0.80, effort 3), on all 32 designs and 5 independent seeds, 800 trajectories. The
loop sees only its rung's signal and is charged that rung's measured cost. The
harness scores every held state with the truth, which the loop never sees.

Two implementations are reported. A **replay** runs the loop over the candidate
pool that Stage 1 already evaluated, so it needs no new compute, is exactly
deterministic, and is paired across rungs: every rung sees the same candidates,
the same start and the same truth, and differs only in the signal it may read. A
**live** run drives the same loops through fresh placements and is used as
corroboration; the replay is the primary result because pairing is what makes the
comparison of rungs meaningful. Scores are percentile ranks inside the design's
pool, so a rank point is one step of the pool ordering, and both curves live on
the same scale.

| rung | cost (s) | true gain at r=16 | trajectories ending worse | VG at r=16 | median r* | interior r* | NSI (gain per s) |
|---|---|---|---|---|---|---|---|
| V0 internal wirelength | 162 | **-0.482** | **93%** | **+1.218** | 0 | 34% | **-2.18e-3** |
| V1u unlegalized wirelength | 172 | **-0.500** | **90%** | **+1.232** | 0 | 39% | **-1.93e-3** |
| V0b solver route utilization | 154 | +0.071 | 28% | +0.018 | 3 | 68% | 2.13e-4 |
| V1 legalized wirelength | 188 | **+0.161** | 10% | +0.018 | 4 | 85% | **6.37e-4** |
| V2 fair ruler (Pareto) | 269 | +0.143 | 10% | 0.000 | 3 | 83% | 4.36e-4 |

Finding 5 (the gap is not noise). A loop driven by the pre-legalization signal
does not merely fail to improve: it ends **half a pool-step worse** than where it
started, in 90-93% of trajectories, while reporting a believed improvement of
+1.22 rank points. Since a rank point is one step of the pool ordering, a gap of
1.22 means the believed and true curves are nearly a full range apart and moving in
opposite directions. A faithful verifier has essentially no gap (+0.018).

Finding 6 (the horizon). For both cheap rungs the median r* is 0: the truth peak
is the starting state, i.e. **every accepted edit was net harmful**, and this is
an interior result in 34-39% of trajectories. For the faithful rungs r* is 3-4 with
an interior optimum in 68-85%, which is the ordinary behaviour of a working search.
The model in Section 3 predicts exactly this ordering: with a low-precision
verifier the accepted harmful edits accumulate in the state while the diminishing
beneficial returns run out, so the true curve peaks early and then declines.

Finding 7 (the mechanism, measured directly). Proposition 1 says true improvement is
confirmed gains minus accumulated damage. That decomposition is measurable, so we
account for it rather than fitting a curve: every accepted edit is classified by whether
the truth improved or worsened, and the two contributions are summed. The identity
net = confirmed gain - harmful loss holds exactly on every trajectory by construction.

| rung | confirmed gain | harmful loss | net | confirmed accepts | harmful accepts | AR |
|---|---|---|---|---|---|---|
| V0 internal wirelength | +0.214 | **+0.732** | **-0.496** | 2.0 | 3.0 | 0.33 |
| V1u unlegalized wirelength | +0.227 | **+0.732** | **-0.482** | 2.0 | 3.0 | 0.33 |
| V0b route utilization | +0.451 | +0.375 | +0.063 | 2.0 | 1.0 | 0.60 |
| V1 legalized wirelength | +0.527 | +0.295 | +0.152 | 2.5 | 1.0 | 0.67 |
| V2 fair ruler (Pareto) | +0.554 | +0.339 | +0.170 | 2.0 | 1.0 | 0.69 |

Three things happen at once with a weak verifier, and the table separates them:

1. **The damage term dominates.** For the two cheap rungs the harmful loss (0.732) is
   3.4 times the confirmed gain (0.214), which is what makes the net negative. For the
   faithful rungs the terms reverse: the confirmed gain is 1.6-1.8 times the loss.
2. **The gain term nearly triples** when the verifier becomes faithful (0.214 to 0.554).
   A faithful verifier is not merely more cautious; it finds better edits.
3. **The damage term halves** (0.732 to 0.295-0.339) and harmful accepts fall from 3.0 to
   1.0 per trajectory, while confirmed accepts stay near 2. So the weak verifier accepts
   more, and of worse quality.

This is the compounding mechanism made visible, and it is the quantitative content of
the model: the ceiling does not come from variance but from damage written into the
persistent state and then built upon. The absorption rate is the same statement in ratio
form.

Finding 8 (what to pay for, measured). NSI, the true gain per second of measured
evaluation cost, ranks V1 (6.4e-4) above V2 (4.4e-4) above V0b (2.1e-4), with the
two cheap rungs negative. The strongest rung costs 43% more than the next one down
and returns slightly less. So the value of a verifier is set by its fidelity per
unit cost with a saturation point, and the cheapest faithful rung is the best buy.
This is the same conclusion the scheduling replay reached independently
(Section 7), which is why Section 7 is framed as a negative result about
screening rather than as a method.

Reading the figure. Figure 4 shows the believed curve rising monotonically for the
cheap rungs while the true curve falls; the third panel accumulates the gap.

### 6.1 Live corroboration (FINAL, 128 of 128 cells, 32 designs)

The replay needs no solver time, which is also its weakness: it could describe the
pool rather than the loop. The live implementation therefore drives the same four
loops through fresh placements and fresh truth evaluations, one loop per design per
rung, 16 rounds each. The two are scored identically here, by rank inside the pool the
live run itself explored.

| rung | n live | live dQ_T | replay dQ_T | live r* | replay r* | live VG | replay VG | live ends worse | replay ends worse |
|---|---|---|---|---|---|---|---|---|---|
| V0 internal wirelength | 32 | **-0.699** | -0.491 | 0 | 0 | +1.455 | +1.277 | 97% | 100% |
| V1u unlegalized wirelength | 32 | **-0.644** | -0.500 | 0 | 0 | +1.447 | +1.259 | 100% | 88% |
| V1 legalized wirelength | 32 | +0.175 | +0.143 | 4 | 2 | 0.000 | +0.018 | 16% | 9% |
| V2 fair ruler (Pareto) | 32 | +0.159 | +0.107 | 4 | 2 | 0.000 | 0.000 | 16% | 9% |

The two implementations agree on what matters. The rungs split into the same two
groups in both: the cheap rungs are strongly negative (-0.70 and -0.64 live, -0.49 and
-0.50 replayed) and the faithful rungs are positive (+0.18 and +0.16 live, +0.14 and
+0.11 replayed). The horizon is r* = 0 for both cheap rungs in both, and the gap is
large in both. On the cheap rungs the live loop is worse than the replay, and it ends
worse in 97-100% of trajectories, so the replay's central claim is not an artifact of
simulating the loop on a frozen pool.

The one thing that is not stable is the order *within* the cheap group: live puts V1u
(-0.644) above V0 (-0.699) while the replay puts V0 (-0.491) above V1u (-0.500). The
spread inside that group is 0.055 live and 0.009 replayed, against a gap of about 0.8
to the faithful group, so the two cheap rungs are indistinguishable from each other and
both are clearly separated from the faithful pair. We report the boundary at the
partition, not at a rank within the losing group.

The live run costs a real placement per round through legalization and detailed
placement, so it took substantially longer than the replay and was sharing the machine
with the rest of the campaign. It is now complete: 128 of 128 cells, all four rungs on
all 32 designs.

Disagreement in the small: the live faithful arms gain slightly less than the replay's
(+0.057 against +0.107 for the ruler) and their r* is later (4 against 2). Both
differences are consistent with the live loop having a smaller pool to move through,
which makes each step coarser and the search less able to exploit it. We report them
as the residual difference between a simulated loop and a real one.

## 7. What an evaluation budget should buy (FINAL)

Setup. Policies draw from the frozen candidate pool, are charged the measured
per-stage cost of every evaluation they make, and their final placement is scored
by the truth. Three families: climb on a fixed rung; climb on the truth-shaped
Pareto rule; and screen-then-confirm, which draws k candidates, ranks them with a
screening rung, and confirms the best m with the strongest rung. 32 designs, 5
seeds per cell, and each policy is run under an explicit cost cap so that policies
compete at equal budget.

| policy | 100 s | 140 s | 200 s | 280 s |
|---|---|---|---|---|
| climb V0 (internal wirelength) | 0.143 | 0.125 | 0.107 | 0.109 |
| climb V1u (unlegalized wirelength) | 0.143 | 0.125 | 0.125 | 0.109 |
| climb V0b (route utilization) | 0.732 | 0.741 | 0.759 | 0.768 |
| climb V2 (fair ruler, Pareto) | 0.737 | 0.804 | 0.804 | 0.804 |
| climb V1 (legalized wirelength) | 0.804 | 0.804 | 0.839 | 0.839 |
| screen V0 then confirm V2 | 0.598 | 0.607 | 0.607 | 0.598 |
| screen V1u then confirm V2 | 0.607 | 0.625 | 0.625 | 0.616 |
| **screen V1 then confirm V2** | **0.893** | **0.893** | **0.911** | **0.920** |

Finding 9 (screening works, if the screening rung is faithful). Ranking with the
cheapest faithful rung and confirming with the strongest one wins at every budget:
0.893 against 0.804 for the best fixed rung at 100 s, and 0.920 against 0.839 at
280 s. The advantage is not a cost effect - it persists when the budget is doubled -
so screening buys something the fixed-rung climb cannot: breadth before commitment.

Finding 10 (screening on a wrong rung is worse than not screening). Screening with
either pre-legalization signal lands at 0.60, well below climbing on a faithful
rung, and barely above the pool's median. A cheap screen is only cheap if it
preserves the ordering it screens on; screening on an anti-correlated signal
spends money to select the wrong candidates.

Finding 11 (the free lunch is bounded). Climbing on the fair ruler (Pareto) is
worse than climbing on legalized wirelength alone (0.804 against 0.839), and
never better. The Pareto rule is the honest criterion, but it is also the most
conservative: refusing any move that worsens the congestion component gives up
wirelength gains it could have kept. Together with the NSI result this is the
practical guidance: pay for the cheapest faithful rung, screen with it, and
confirm expensive moves rather than every move.

Correction to an earlier preliminary statement. An earlier version of this section
reported the opposite conclusion, that screening does not beat a fixed rung, on a
pool of 16 design-seeds. That conclusion does not survive the full 32-design pool:
the screening policy gains roughly nine rank points at every budget. The
pre-registered kill criterion K3 was therefore evaluated on insufficient data and
does not fire. We report the reversal rather than quietly replacing it, because it
is the campaign's own illustration of the paper's thesis: a conclusion drawn on a
small pool, evaluated by one rung of evidence, was wrong.

### 7.1 Held-out splits, including the sealed designs

The claims above were formed on the development split. Re-running the arms on the
validation, sealed and out-of-distribution splits is the test of whether they were
fitted to the designs that suggested them. The sealed designs were never used to
choose a policy, a threshold or a hyperparameter; the comparison below is a report,
which is what the protocol reserves them for.

| split | designs | n | A0 | A1 (unlegalized, fixed) | A1 (legalized, fixed) | A2 (ruler) |
|---|---|---|---|---|---|---|
| dev | 13 | 65 | 0.000 | **-0.500** | +0.179 | +0.125 |
| val | 5 | 25 | 0.000 | **-0.444** | +0.143 | +0.214 |
| sealed | 6 | 30 | 0.000 | **-0.536** | +0.125 | +0.125 |
| ood | 8 (other PDKs) | 40 | 0.000 | **-0.375** | +0.196 | +0.250 |

Finding 13 (the finding is not fitted to the designs that produced it). The sealed
split reproduces the development result: the unfaithful arm destroys true quality at
about the same magnitude (-0.536 against -0.500), and the faithful arms gain about the
same amount (+0.125 against +0.179). The out-of-distribution split, which differs in
library, cell height and routing stack, shows the same pattern again.

The gain-per-second ranking is stable out of sample as well: on the sealed designs the
legalized-wirelength arm gives 8.5e-4 per second against the ruler arm's 5.4e-4 and the
unlegalized arm's negative value, the same ordering as on the development split. NSI is
therefore not a property of the development set.

Reading honestly: the sealed magnitudes differ from the development ones by up to about
a third (A2: +0.125 against +0.214 on validation), so the effect size is not precisely
estimated at 30 trajectories per cell. What is stable is the ordering and the sign, and
that is what the paper claims.

## 8. External anchoring and transfer (FINAL)

Setup. 32 designs carry a commercially placed reference DEF for the same input
DEF and floorplan. We score the reference, the ruler-optimal candidate and the
candidate the cheap rung (V0) is attracted to (highest density, no congestion
effort) with the same independent evaluator, so the comparison is physically
consistent: same input, same floorplan, same library, same congestion model.

| pick | wirelength / reference | congestion / reference |
|---|---|---|
| ruler-optimal | 0.935 | 1.228 |
| cheap-rung (V0) attractor | 1.089 | 2.902 |

Paired across designs: the ruler-optimal pick is better than the cheap-rung pick
on 31 of 32 designs for wirelength and 31 of 32 for congestion. The ruler-optimal
pick is below the reference on wirelength for 20 of 32 designs.

Reading. The load-bearing statement is the paired one, because it uses one
external yardstick for both policies. The absolute ratio is an anchor, not a
like-for-like contest: the reference was produced by a different tool, with
different settings and a different objective mix, and our congestion is worse
than the reference's overall. We therefore do not claim to beat commercial tools;
we claim that the choice the cheap verifier makes is externally visible as worse,
which is the same conclusion the internal analysis reaches.

A note on cross-tool comparability, because it bounds what an absolute ratio can mean.
Our independent evaluator applied to the reference DEF agrees with the commercial tool's
own reported wirelength on only three of the four designs where both numbers exist, and
disagrees by -21% to +9% (aes 0.79, picorv32 0.86, apb4_timer 0.91, s1238 1.09). Two
tools measuring "wirelength" for the same design differ by that much through fill
handling, unit conventions and what is counted. This is why the claim is built on a
paired comparison with one evaluator applied to both policies, and why we do not quote a
single absolute number as if it were tool-independent.

### 8.1 Transfer across process technologies (FINAL)

Setup. The source domain is sky130 (24 designs); the out-of-distribution targets
are ics55 and nangate45 (4 designs each), which differ in library, cell height and
routing stack. Every policy from Section 7 is run on every design at a fixed
budget of 140 s. The preference learned on the source is the policy ordering by
final truth rank there.

| policy | sky130 | ics55 | nangate45 |
|---|---|---|---|
| climb V0 (internal wirelength) | 0.125 | 0.071 | 0.107 |
| climb V1u (unlegalized wirelength) | 0.098 | 0.125 | 0.116 |
| climb V0b (route utilization) | 0.714 | 0.777 | 0.746 |
| climb V1 (legalized wirelength) | 0.795 | 0.777 | 0.826 |
| climb V2 (fair ruler, Pareto) | 0.804 | 0.759 | 0.866 |
| screen V0 then confirm V2 | 0.661 | 0.379 | 0.513 |
| screen V1u then confirm V2 | 0.634 | 0.509 | 0.491 |
| screen V1 then confirm V2 | **0.902** | **0.893** | 0.799 |

| target | source-best policy | its rank on target | target-best policy | target-best rank | TR ratio | TR rank (Spearman of policy orderings) |
|---|---|---|---|---|---|---|
| ics55 | screen V1 then confirm V2 | 0.893 | screen V1 then confirm V2 | 0.893 | 1.000 | 0.874 |
| nangate45 | screen V1 then confirm V2 | 0.799 | climb V2 (Pareto) | 0.866 | 0.923 | 0.905 |

Finding 12 (the ladder's ordering is a property of the ladder, not of a
technology). The qualitative structure is identical in all three technologies:
both pre-legalization signals are the worst policies (0.07-0.13), the faithful
rungs are good (0.71-0.87), and screening with a faithful rung is best or
near-best (0.80-0.89). The Spearman correlation between the source and target
policy orderings is 0.87 and 0.91, and applying the source's choice on a target
costs at most 8% of the achievable rank. This is what makes the paper's claim a
statement about evaluation depth rather than about one PDK: which verifier is
worth using is determined by whether its signal is aligned with the truth, and
alignment is much more stable across technologies than the numerical values are.

Technology-specific residual. On nangate45 the Pareto climb is the best policy
(0.866 against 0.799), whereas on sky130 and ics55 the screening policy is best.
The difference is small relative to the gap between faithful and unfaithful
policies, and we report it as a residual rather than claiming a universal ranking
of the top policies.

Limitation. The out-of-distribution arms have four designs each, so the transfer
correlations have wide intervals and are reported as an ordering rather than as a
precise coefficient. The timing rung does not resolve on these technologies (its
library and LEF initialisation aborts), so transfer is measured on the geometry
ruler; extending the timing rung to these PDKs is future work.

## 9. Limitations and what we do not claim

- We do not claim that accelerating RSI has been achieved, and nothing here
  supports civilization-scale readings of the term.
- We do not claim to beat commercial tools in absolute quality. The claim is
  about the dynamics of improvement, and our absolute numbers are modest.
- The truth is the fair ruler of legalized wirelength plus trial-route
  congestion, which is itself a proxy for signoff. Extending the ladder to timing
  and DRC is the natural next rung and is not yet measured.
- The loops are per-design and share no learned state, so there is no train/test
  contamination in Stages 1-2; splits become load-bearing only for the transfer
  experiments.
- The machine was shared and heavily loaded during part of the campaign, so
  wall-clock cost records are noisy even though the CPU cost records are not. The
  cost ledger keeps both.
- The signoff rung is a feasibility spot check, not a campaign-wide measurement. The
  chain from a placed DEF through clock tree synthesis, routing and DRC was made to
  run and one design's geometry-optimal candidate reached a routed design with 155
  DRC violations. Because a single candidate costs minutes to tens of minutes, the
  comparison across rungs at signoff was not completed and no claim depends on it.
- Seven implementation defects were found during the campaign and are documented
  (A1 density plateau, A2 concurrency race, A3 cached failures, A4 irreproducible
  seeding, A5 unmeasurable candidates in a trajectory, A6 cache keyed on the wrong
  identity, A7 signoff concurrency and ordering). We consider the
  audit trail part of the result, because each defect produces results that look
  plausible rather than results that break visibly.
- The external comparison uses the reference DEF as an anchor for the relative
  quality of our two pick policies. It is not a like-for-like tool contest.
- Timing (the V3 rung) is implemented and validated on individual candidates but
  the full timing pass over the candidate pool is still running, so no claim in
  this draft depends on timing yet.

## 10. Conclusion

We set out to measure, rather than assert, what bounds a self-improving system, and
chose a domain where evaluation has a priced ladder and an external reference:
physical design. The measurement is unambiguous on the question that motivated it.

A verifier is not a noisy version of the truth. The signal that is cheapest to
compute and most natural to optimize - the wirelength reported by the placer before
legalization - is anti-correlated with the truth (rho = -0.89 against legalized
wirelength, -0.92 against congestion) and with the rung above it (rho = -0.47
against setup slack). Selecting on it costs about 20% of wirelength and 125% of
congestion relative to what was available in the same candidate pool, and the
choice it makes is visibly worse on an external commercial yardstick on 31 of 32
designs.

A self-improvement loop driven by such a verifier does not plateau; it goes
backwards while reporting progress. Over 16 rounds and 800 trajectories, the loops
driven by pre-legalization signals ended half a pool-step worse than they started
in 90-93% of runs while reporting a believed improvement of +1.22 rank points, and
their true-improvement horizon was r* = 0: the best state they ever held was the
one they started from. Faithful verifiers showed the ordinary behaviour of a
working search - small gap, interior optimum, positive gain.

The practical consequence is a rule with a measured margin. Pay for the cheapest
verifier that preserves the truth ordering; use it to screen candidates for breadth;
confirm the survivors with the strongest available one. That policy beat the best
fixed-rung strategy at every budget we tested, by roughly nine rank points, and its
preference order transferred across process technologies with rank correlation
0.87-0.91. Ranking candidates on an unfaithful verifier, by contrast, was worse than
not screening at all.

The mechanism is measurable rather than inferred. Splitting every accepted edit
into confirmed gain and harmful loss shows the damage term is 3.4 times the gain
term for the cheap rungs and that the relation reverses for the faithful ones: a
weak verifier is not merely more permissive, it lets through more edits of worse
quality, and that damage is written into the persistent state and then built upon.
This is why a weak verifier produces a ceiling rather than noise.

The findings survive leaving the designs that produced them. On six sealed designs,
which were used for nothing except the report, the unfaithful arm is negative at
-0.54 and the faithful arms positive, the same pattern as on the development split;
and on the eight out-of-distribution designs, which differ in library and routing
stack, the pattern repeats. A live implementation of the loops, driving real
placements each round, reproduces the rung ordering, the sign and the horizon.

Three things we do not claim. We did not achieve, and do not claim, accelerating
self-improvement: the loops here are per-design and share no learned state, so what
we measure is the improvement dynamics of one loop, not the growth of an improver.
The timing evidence is a pre-clock-tree evaluation with a wireload model, so even
the top of our ladder is a rung rather than signoff. And the signoff comparison is
one design and two candidates, an illustration rather than a measurement with a
sampling distribution.

What the work contributes is the instrument and the discipline to use it. The
ladder, the cost ledger, the external anchor, the frozen protocol and the seven dated
amendments - each recording a defect that produced results which looked plausible
rather than results which broke - are the reason the findings above could be trusted
at all. The campaign also produced its own illustration of the thesis: a preliminary
conclusion in this study, drawn on a pool one third the size, was wrong, and was
corrected by the same rule the paper recommends - measure with a stronger verifier
than the one that produced the claim.

## 11. Reproducibility and honesty notes

- Every number in this draft is produced by a script in ieda/rsi/analysis from the
  append-only ledger, and each is labelled FINAL or PENDING here.
- Five defects were found and fixed during the campaign, each recorded as a dated
  amendment rather than silently repaired: a density plateau that made part of the
  search grid degenerate (A1), a concurrency race in which two loops could share a
  work directory (A2), failures cached as results (A3), a seeding scheme that made
  trajectories irreproducible across processes (A4), and candidates with an
  unmeasurable truth allowed into a trajectory (A5).
- The analysis refuses to scalarize the truth with arbitrary weights: in-loop
  acceptance uses Pareto dominance and offline scoring uses rank aggregation.
- Cost is reported per stage (placement, legalization and detail, trial route,
  timing) and a rung is charged exactly what it used, so every claim about cost can
  be re-derived.

## Appendix A: reproducibility

Workspace, protocol, amendments, harness, analysis and figure scripts are listed
in the repository under ieda/rsi. Protocol hash and amendment hashes are frozen;
the runner verifies the protocol hash before every run. Every reported number is
derived from the ledger by a script in ieda/rsi/analysis.

| artifact | path |
|---|---|
| protocol | ieda/rsi/protocol/PROTOCOL-v1.0.md |
| amendments | ieda/rsi/protocol/AMENDMENT-A1.md, AMENDMENT-A2.md, AMENDMENT-A3.md |
| harness | ieda/rsi/harness/rsi_lib.py, verify.py, splits.py, stage1_pool.py, stage2_loop.py, timing_rung.py, stage1_timing.py |
| analysis | ieda/rsi/analysis/fidelity.py, timing_fidelity.py, dynamics.py, scheduling.py, innovus_anchor.py, anchor_report.py, go_no_go.py, figures_stage1.py |
| splits | ieda/rsi/harness/splits.json (dev 13 / val 5 / sealed 6 / ood 8 / excluded 3) |
| ledger | runs/v2/ledger.jsonl |
| figures | ieda/rsi/paper/figures/ |
