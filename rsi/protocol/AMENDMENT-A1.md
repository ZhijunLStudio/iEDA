# Amendment A1 to Protocol v1.0

Date: 2026-09-16. Status: applied before the reported measurements of Stage 1
(batch v2, improver_id 8992e76f8b4349de) and Stage 2 (improver_id
44c6478905abf3f4). Protocol v1.0 itself is unmodified; its hash stays frozen.
This file is the audit trail.

## A1.1 Measured facts that forced the amendment

1. **Density plateau.** target_density is clamped from below by the design: on
   gcd_sky130_a, td = 0.45, 0.50 and 0.55 produce the identical placement
   (def_hpwl 6715582, legalized). The low end of the grid is therefore a plateau,
   not an extending axis. Consequence: a truth optimum sitting at td = 0.55 is
   sitting on the physical density floor, and the pool contains duplicate points
   below it. Reported, not hidden.
2. **Zero-congestion references.** Some designs (PPU_sky130_b, aes_sky130_a)
   reach EGR union = 0 at the reference point. Any ratio-based scalarization of
   congestion divides by zero or explodes. The original composite truth
   (0.5 * HPWL_norm + 0.5 * EGR_norm) is therefore ill-defined exactly on the
   easiest designs.

## A1.2 Truth definition (supersedes section 2.3 for Stages 1-2)

- **In-loop acceptance for the strongest rung (V2)** uses the project's own
  practitioner rule: a candidate is accepted iff it is non-worse on every
  measured dimension (legalized HPWL, EGR union) with at least one strict
  improvement (Pareto dominance). No weights.
- **Offline scoring** for believed-vs-true curves uses rank aggregation: each
  truth component is converted to a percentile rank inside the candidate pool of
  that design and seed (1.0 = best), and the truth score is the mean of the two
  ranks. The believed score is the percentile rank on the rung's own signal,
  computed on the same pool. Both live in [0,1], so
  dQ(r) = score(held_r) - score(start) and VG_r = dQ_believed - dQ_true are
  comparable without an arbitrary weight.

Rationale: the claim must not depend on a chosen scalarization. Rank aggregation
is invariant to monotone rescaling of each component; the Pareto rule is the
criterion the project already uses for its eight-dimension reconciliation.

## A1.3 Verifier rung to signal mapping (as implemented)

| rung | signal read by the loop | ledger field | charged cost |
|---|---|---|---|
| V0 | GP-internal HPWL, placement not legalized | V0_gp_internal_hpwl | gp |
| V0b | solver-internal route utilization | V0b_route_util | gp |
| V1u | DEF HPWL of the legalizer input | V1u_def_hpwl_unlegal | gp |
| V1 | HPWL of the legalized + detailed placement | V1_hpwl_indep | gp + lgdp |
| V2 | legalized HPWL and EGR union (Pareto rule) | V1_hpwl_indep + egr_total_overflow_union | gp + lgdp + egr |

Costs are recorded as components (gp / lgdp / egr) per candidate, so any rung's
cost is recomputable, and the truth-evaluation cost is never charged to the loop.

## A1.4 Excluded cases

- nangate45_gcd, asap7_aes, ihp130_gcd: registry entries whose references point
  at dead /tmp or foreign-tree paths. Excluded from all aggregates and listed
  here rather than dropped silently. 32 of 35 cases are usable.
- One salsa20_sky130_a candidate failed the EGR legalization gate and is kept in
  the ledger with its failure reason.

## A1.5 Naming

The rung previously called V1 comes in two flavours and they are not
interchangeable: the DEF HPWL written at the end of global placement (before the
legalizer runs) is V1u, and the HPWL of the legalized placement is V1. Stage 1
measures both, plus the stale state field, to make the distinction visible
instead of implicit.
