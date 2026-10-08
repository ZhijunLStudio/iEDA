# Final state of the iEDA RSI congestion campaign

> Supersedes the status and TODO sections of HANDOVER.md and WORK-SUMMARY.md, which describe a state that
> later measurement did not support. Every number here is reproducible from the artifacts named beside it.

## 1. The objective, and whether it is met

**Not met.** The objective is: on 15 netlist-matched designs, every design and every measurable dimension no
worse than Innovus (HPWL, EGR union, EGR max, setup WNS, setup TNS).

Measured under the protocol the campaign adopted in round 76 and only actually used from round 91:

| arm | primary: designs passing on EVERY seed | secondary: passing design-seed cells |
|---|---|---|
| unmodified iEDA | 2/15 (concurrent pattern, round 74; not yet re-taken sequentially) | 12/60 |
| current tree before the GP refinement | **2/15** | 15/44 |
| **current tree (SR-26)** | **3/15** | **25/44** |

Eleven of fifteen designs pass at least one seed under the current tree; the other four - nine of fifteen if
counting the designs that pass at least one seed under some arm - do not pass every seed. Five designs pass
no seed at all.

**The honest summary: this campaign moved the count by one design, from 2 to 3 of 15, and established why
the remaining twelve are hard.**

## 2. How the number was obtained

The measurement recipe, all of it load-bearing:

    one flow at a time, nothing else on the measurement host
    OMP_NUM_THREADS=1 in every iEDA process
    the shipped placer config (the ics55 designs ship num_threads=16)
    the binary built from this tree
    scored by gp_metrics_compare.density(def, case_root, 200, foundry, "egr", 64)
    against runs/standingB/<design>/ref, the Innovus DEF legalised by the same run
    seeds 1000, 1001, 1002, 1003; 11 candidate designs, 44 cells per arm

Artifacts: `runs/seedcells_seq_cur/` and `runs/seedcells_seq_sr26/` (44 cells each), summarised by
`ieda/rsi/harness/paired_sequential_verdict.py`. The unmodified arm in the table above is from
`runs/seedcells/base_*` (concurrent pattern) and is **not** protocol-comparable; re-taking it is the first
open task.

**Why every earlier number in the campaign is different.** Rounds 1-74 measured with several flows in flight
and without a thread pin that survived the router inside placement. Rounds 80-88 believed they were measuring
sequentially and were not. Individual cells move by 1-30% between co-run patterns, enough to flip verdicts;
the counts move by one to two designs.

## 3. What is in the tree

| change | what it does |
|---|---|
| SR-10 | calls the project's own congestion evaluator around detail placement, so the stage can see routability at all |
| SR-11 | keeps detail placement only when it does not worsen the peak while failing to improve the total |
| SR-21 | runs up to two extra legalise+detail-placement passes on the command path and keeps the best |
| round-67 fix | iRT no longer resets the process-wide OpenMP thread count (was 128); the in-flight congestion measurement restores the caller's setting |
| round-70 fix | clears `<output>/rt/rt_temp_directory/early_router` before each in-process measurement, because the evaluator reads those per-layer files back and was reading other measurements' |
| **GP gated refinement** | up to 6 segments, each a GP re-linearisation at congestion effort 4 plus one legalise and one detail placement, measured with the project's evaluator and kept only if no worse than the entry on either scored number and better on at least one; restored from the best segment at the end |

Binaries: `iEDA-base` c9761dc9 (unmodified), `iEDA-sr25` c385b257, **`iEDA-sr26` f6f81193 = `build/bin/iEDA`
(current)**, `iEDA-sr27` 0543fdbb, `iEDA-sr28` 48cd5be3. The tree is 11 files, +534/-13 against the
campaign baseline fb5c3cc.

## 4. What was withdrawn, and the measured reason

Beyond the sixteen the campaign had already withdrawn (SR-2..SR-9, SR-12..SR-20), this work withdrew:

| change | measured reason |
|---|---|
| SR-23 (revert any non-improving DP result) | net loss: secondary 17/60 -> 16/60, and it turned salsa20_ics55_a@1003 from pass to fail by removing the non-monotone step the finishing search needs |
| SR-24 (revert only the dominated case) | net loss: same 17 -> 16; makes gcd_ics55_a@1000 fail worse |
| SR-27 (segment chooser restricted to Pareto-over-entry) | tie at primary 4/15 concurrent and 3/15 sequential, no gain; its motivating single cell measured 747/14 in one run and 952/19 in the next |
| concurrent-pattern measurements as acceptance evidence | they gave 4/15 where the protocol-correct measurement gives 3/15 |

A defect found and **not** fixed, because the minimal fix was measured to be harmful: the SR-11 guard accepts
a strictly dominated move (same peak, 25% worse total). Observed at apb4_timer seed 1002.

## 5. What is established about the mechanism

All four statements are measured, most under the protocol-correct setting:

1. **Congestion-steered global placement is worse as a whole-run objective.** Initial GP at effort 4:
   s5378_sky130_b union 1.518x -> 1.625x and peak 1.182x -> 1.273x; s1238 union 1.124x -> 1.182x. Cost was
   36 s and 41 s, so it is not expensive on these designs - it is ineffective.
2. **The same term applied as a bounded, gated refinement is better.** It is the only change that has raised
   the objective's count: +1 design passing on every seed, +10 passing cells, 0 design-level regressions.
3. **Detail placement is the repair stage, not the source of the deficit.** Round 29's stage localisation put
   the wirelength debt in GP+LG (1.87x-2.07x the reference on the designs the flow fails) and found detail
   placement improving the peak on three of five designs tested.
4. **The five designs that never pass fail on both congestion dimensions while already winning wirelength:**
   union 1.21x-3.01x, peak 1.09x-1.86x, HPWL 0.72x-0.94x. That is a demand-model deficit of a magnitude no
   mechanism measured in this campaign moves.

## 6. Instrument requirements - the campaign's own hardest lesson

A measurement is identified by the whole tuple:

    (binary, design, seed, co-run pattern, thread settings)

Every conclusion requires both arms measured in one tuple, **and** every cache, checkpoint or resume path must
key on that tuple rather than a prefix of it. The three orchestration errors that corrupted measurements in
this work - two sweeps racing over one work directory; a leftover repeat script running alongside a launch; a
resume check inheriting another pattern's placements - were each a violation of that rule.

Two instrument facts are worth carrying forward:
- the ruler (`gp_metrics_compare.density`) is deterministic and thread-insensitive, and reads a private DEF
  snapshot in a temp directory, so it never reads an arm's own artifacts;
- the in-process evaluator the guard uses agrees with the ruler to within 1-5 overflow bins, so the guard is
  not optimising a bad proxy.

## 7. What remains

1. **Twelve designs do not pass every seed**: five never pass (aes, picorv32, s1238, s5378_sky130_b,
   salsa20_nangate45_a) and seven miss one or two seeds.
2. **Timing covers 7 of 15 designs.** nangate45 aborts inside the timing evaluation and ics55 stops while
   reading the library LEF. The five-dimension claim cannot be made on half the set until that is fixed.
3. **Cost.** The GP refinement allows up to six global-placement re-linearisations per placement. On the
   designs it helps it is the most expensive configuration measured, and it is why the protocol-correct
   validation takes hours rather than minutes.
4. **The unmodified arm has not been re-taken sequentially**, so the "2 -> 3" figure compares a
   protocol-correct arm against a concurrent one. The direction is safe (the current tree's own sequential
   arm is 2/15 and SR-26's is 3/15, measured in one protocol), but the base-vs-SR-26 statement needs the same
   treatment.
