# Round 66: the four-arm standing, re-measured in one batch with one ruler

## 1. Outcome in one line

The authoritative single-batch standing is **unmodified 2/15, current tree 4/15, with SR-21 4/15** -
SR-21 adds no design, and two defects in the previous scoring are why the record said 3/15 and 5/15.

## 2. What the ruler actually is, and what it is not

The campaign scores congestion with iEDA's own EGR congestion evaluator, invoked as:

    gp_metrics_compare.density(def, case_root, 200, foundry, "egr", 64)

It copies the DEF into a private temp directory, runs db_init + def_init + run_density_eval
(grid_size 200) + run_congestion_eval (model egr, bin_cnt 64x64), and reads the numbers from
congestion_result.json in that temp directory. So it **never reads or writes the arm's own
egr_congestion_map/ CSVs**, and it enforces the legalization gate (an unlegalized DEF is refused).

That distinction matters, because those CSVs are the obvious thing to read and they are wrong.
Measured on runs/standingB/picorv32/ours, where the DEF is **byte-identical** to
runs/cur21sweep/picorv32/placement.def (md5 ec8f9669 both):

| source | union | max |
|---|---|---|
| the flow's own CSV in standingB/picorv32/ours | 125165 | 74 |
| the flow's own CSV in cur21sweep/picorv32 | 121153 | 58 |
| the ruler (this round, and standingB/agg.json) | **121153** | **58** |

Two different numbers for the same DEF. The CSVs are each run's own flow output on whatever grid
that run's config used (the union maps on disk are 28x28 to 303x303 across the set, not 64x64); they
are not the scored quantity. Scoring from them would have been wrong by up to 8% on union.

**The ruler is deterministic.** Four designs have byte-identical DEFs in the cur and sr21 arms, and
each pair returns identical union **and** max from two separate evaluator invocations: picorv32
121153/58, s1238_ics55_a 81/6, s38584_nangate45_a 3/1, salsa20_nangate45_a 464/12. The full 60-cell
batch was then run twice end to end and returned the same numbers in every cell.

## 3. Defect 1: a zero reference turned into a free pass

The old scoring computed the ratio as "arm/ref if ref else None", then counted None as a pass. The
reference genuinely has **zero** overflow on two nangate45 designs, so those ratios were None
whatever our arm did. On s1238_nangate45_a unmodified iEDA asks the router for 4 bins and 2 bins
against a reference of 0 and 0 - it loses - but it was scored as a pass.

Direct comparison (arm <= reference) instead of a ratio fixes it. Results are unchanged for 14
designs and flip one: **the unmodified baseline is 2/15, not 3/15.**

## 4. Defect 2: SR-21's headline win does not reproduce

The record credits SR-21 with taking gcd_ics55_a from union 1.85x to 0.80x, "a failing design to a
passing one", which is where "5 of 15" comes from. Re-measured inside one batch:

| arm | hpwl | union | max | vs reference (20) |
|---|---|---|---|---|
| orig | 4094310 | 37 | 3 | 1.85x |
| cur | 4094310 | 37 | 3 | 1.85x |
| **sr21** | 4094306 | **37** | 3 | **1.85x** |
| ref | 4336162 | 20 | 6 | - |

**SR-21 did not move this design at all.** The 0.80 does not reappear, and neither does the promised
16. This is the round-31 failure mode again - the pipeline is reproducible within a batch and not
across batches - and it is why every conclusion in this campaign has to be re-derived in a single
batch before it is believed. SR-21 is inherited from that earlier measurement; whether it can win on
gcd_ics55_a is now an **open question**, not a result.

## 5. The corrected standing

15 designs, one ruler, one batch. PASS = no worse than the legalized Innovus reference on all three
measurable dimensions.

| design | orig | cur | sr21 | fails (cur) | hpwl | union | max |
|---|---|---|---|---|---|---|---|
| aes | fail | fail | fail | union,max | 0.732 | 1.361 | 1.611 |
| apb4_timer | fail | **PASS** | **PASS** | - | 0.872 | 0.929 | 1.000 |
| gcd_ics55_a | fail | fail | fail | union | 0.944 | 1.850 | 0.500 |
| gcd_nangate45_a | **PASS** | **PASS** | **PASS** | - | 0.892 | 1.000 | 1.000 |
| gcd_sky130_a | fail | fail | fail | hpwl,union,max | 1.136 | 2.389 | 1.273 |
| picorv32 | fail | fail | fail | union,max | 0.808 | 1.453 | 1.611 |
| s1238 | fail | fail | fail | union,max | 0.761 | 1.142 | 1.429 |
| s1238_ics55_a | **PASS** | **PASS** | **PASS** | - | 0.829 | 0.523 | 0.429 |
| s1238_nangate45_a | fail | **PASS** | **PASS** | - | 0.749 | 1.000 | 1.000 |
| s1238_sky130_a | fail | fail | fail | hpwl,union,max | 1.078 | 2.053 | 1.857 |
| s38584_ics55_a | fail | fail | fail | union,max | 0.969 | 1.166 | 1.600 |
| s38584_nangate45_a | fail | fail | fail | union | 0.959 | 1.500 | 1.000 |
| s5378_sky130_b | fail | fail | fail | union,max | 0.896 | 1.560 | 1.273 |
| salsa20_ics55_a | fail | fail | fail | max | 0.945 | 0.786 | 1.143 |
| salsa20_nangate45_a | fail | fail | fail | union,max | 0.941 | 1.886 | 1.714 |

**ALL-DIM PASS  orig 2/15   cur 4/15   sr21 4/15**

Note s38584_nangate45_a: cur union is 3 against a reference of 2. Under the old convention that was
a null ratio and a pass; it is a loss by one bin.

## 6. What the corrected table says about where the work is

**21 failing (design, dimension) cells: 10 union, 9 max, 2 hpwl.**

**Nine of the fifteen designs fail on congestion alone**, and on every one of them wirelength is
already won, by 3% to 25%:

| design | hpwl | worst failing dimension |
|---|---|---|
| aes | 0.732 | max 58 vs 36 |
| gcd_ics55_a | 0.944 | union 37 vs 20 |
| picorv32 | 0.808 | max 58 vs 36 |
| s1238 | 0.761 | max 40 vs 28 |
| s38584_ics55_a | 0.969 | max 24 vs 15 |
| s38584_nangate45_a | 0.959 | union **3 vs 2** |
| s5378_sky130_b | 0.896 | union 3776 vs 2421 |
| salsa20_ics55_a | 0.945 | max 40 vs 35 |
| salsa20_nangate45_a | 0.941 | union 464 vs 246 |

Only **two** designs fail wirelength (gcd_sky130_a 1.136, s1238_sky130_a 1.078) - and those are
exactly the two whose global placement hit the 2000-iteration cap with internal overflow still at
0.123/0.128 instead of the 0.10 stopping band the other twelve reached.

**The gap distribution is very uneven, which is the actionable part:**

| design | dimension | our | ref | abs gap |
|---|---|---|---|---|
| s38584_nangate45_a | union | 3 | 2 | **1** |
| salsa20_ics55_a | max | 40 | 35 | 5 |
| salsa20_nangate45_a | max | 12 | 7 | 5 |
| s5378_sky130_b | max | 28 | 22 | 6 |
| gcd_sky130_a | max | 28 | 22 | 6 |
| s38584_ics55_a | max | 24 | 15 | 9 |
| s1238 | max | 40 | 28 | 12 |
| gcd_ics55_a | union | 37 | 20 | 17 |
| picorv32 / aes | max | 58 | 36 | 22 each |

One design loses by a single overflow bin. Three more lose by 5-6 bins on a single dimension. That is
the cheapest end of the objective, and it is where the first source change should be aimed.

## 7. Consequence for how the loop is judged

The campaign has been reporting **means** ("8 of 13 improved, average narrowing 16%") while the
objective is a **per-design conjunction**. On this table that mismatch is not academic: SR-11 +
SR-21 bought large mean improvements on nangate45 (s38584_nangate45_a union 21 to 3) and still moved
the pass count by exactly zero on that design, because the reference sat at 2.

The judging rule is therefore changed with this round:

    accept a source change iff  (pass count increases)
                                and (no currently-passing design regresses)

with the per-design deficits above as the priority order. A mean over designs is no longer evidence
of progress on this objective.

## 8. State and artefacts

- **In the tree**: SR-10, SR-11, SR-21 (build 62f55d58). **Not in the tree**: the sixteen withdrawn
  changes, unchanged by this round.
- **New, reproducible**: rsi/harness/egr_ruler_batch.py regenerates the whole table in about
  7 minutes; rsi/analysis/out/four_arm_standing.json is the frozen output (in git);
  runs/four_arm.json and runs/four_arm_raw.json are the working copies.
- **Superseded**: the "3/15 -> 4/15 -> 5/15" progression, and every per-arm ratio read out of an
  arm's own egr_congestion_map/ CSVs.

## 9. Next

1. Target the cheapest end first: s38584_nangate45_a (one bin), then the three designs failing a
   single dimension by 5-6 bins.
2. The GP congestion machinery already in the tree (WAWirelengthGradient congestion_effort 2/4/7,
   level 4 being explicitly evaluator-aligned) is the obvious lever, but it failed as an
   unconditional default. The untried shape is a **bounded GP refinement gated on the ruler, keeping
   the best segment** - the same shape as SR-21, which is already demonstrated to be bounded,
   self-guarding and executing on the command path, now aimed at the stage where Round 29 localised
   the debt.
3. Do not re-derive any earlier claim from the old scoring path; re-measure it here.
