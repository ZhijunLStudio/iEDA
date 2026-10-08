# Results and where they come from

Every headline number in the draft, the script that produces it, and its status.
Status FINAL means the measurement is complete for the stated scope; PENDING means
it is not yet measured and must not be quoted.

## Verifier fidelity (32 designs, 928 candidate evaluations)

| number | value | script | status |
|---|---|---|---|
| rho, unlegalized wirelength vs legalized wirelength | -0.891 | ieda/rsi/analysis/fidelity.py | FINAL |
| rho, unlegalized wirelength vs congestion union | -0.922 | fidelity.py | FINAL |
| rho, legalized wirelength vs congestion union | +0.970 | fidelity.py | FINAL |
| rho, solver route utilization vs congestion union | +0.737 | fidelity.py | FINAL |
| selection regret in legalized wirelength, unlegalized pick | +19.7% | fidelity.py | FINAL |
| selection regret in congestion, unlegalized pick | +124.7% | fidelity.py | FINAL |
| designs whose truth-best candidate sits on the density floor | 66% | fidelity.py, amendment A1 | FINAL |

## The ruler is a rung too (24 designs, 696 candidates)

| number | value | script | status |
|---|---|---|---|
| rho, legalized wirelength vs setup TNS | -0.471 [-0.574, -0.202] | timing_fidelity.py | FINAL |
| rho, unlegalized wirelength vs setup TNS | +0.216 | timing_fidelity.py | FINAL |
| rho, solver route utilization vs setup TNS | -0.213 | timing_fidelity.py | FINAL |
| designs where the geometry-best is also the timing-best | 7 of 24 | timing_fidelity.py | FINAL |

## External anchoring (32 designs with a commercial reference)

| number | value | script | status |
|---|---|---|---|
| ruler pick / reference, wirelength | 0.935 | innovus_anchor.py, anchor_report.py | FINAL |
| cheap-rung pick / reference, wirelength | 1.089 | anchor_report.py | FINAL |
| ruler pick / reference, congestion | 1.228 | anchor_report.py | FINAL |
| cheap-rung pick / reference, congestion | 2.902 | anchor_report.py | FINAL |
| designs where the ruler pick beats the cheap-rung pick | 31 of 32 (both metrics) | anchor_report.py | FINAL |

## Dynamics (800 trajectories, 16 rounds, 5 seeds)

| number | value | script | status |
|---|---|---|---|
| true gain at r=16, V0 internal wirelength | -0.482 | dynamics_replay.py | FINAL |
| true gain at r=16, V1u unlegalized wirelength | -0.500 | dynamics_replay.py | FINAL |
| true gain at r=16, V1 legalized wirelength | +0.161 | dynamics_replay.py | FINAL |
| trajectories ending worse, V0 / V1u | 93% / 90% | dynamics_replay.py | FINAL |
| trajectories ending worse, V1 / V2 | 10% / 10% | dynamics_replay.py | FINAL |
| gap at r=16, V0 / V1u | +1.218 / +1.232 | dynamics_replay.py | FINAL |
| gap at r=16, faithful rungs | +0.018 / 0.000 | dynamics_replay.py | FINAL |
| horizon r*, V0 / V1u | 0 (interior in 34% / 39%) | dynamics_replay.py | FINAL |
| horizon r*, V1 / V2 | 4 / 3 (interior in 85% / 83%) | dynamics_replay.py | FINAL |
| gain per second, V1 / V2 / V0b | 6.4e-4 / 4.4e-4 / 2.1e-4 | dynamics_replay.py | FINAL |
| live-loop corroboration | see below | stage2_loop.py, live_vs_replay.py | FINAL (128/128 cells) |

## Mechanism (per-trajectory decomposition, 800 trajectories)

The identity net = confirmed gain - harmful loss holds exactly per trajectory by
construction; medians are reported, so the two net columns need not match exactly.

| number | cheap rungs (V0, V1u) | faithful rungs (V1, V2) | script |
|---|---|---|---|
| confirmed gain term | +0.214 to +0.227 | +0.527 to +0.554 | mechanism.py |
| harmful loss term | +0.732 | +0.295 to +0.339 | mechanism.py |
| damage / gain ratio | 3.4x | 0.5x to 0.6x (gain/loss 1.6x-1.8x) | mechanism.py |
| confirmed accepts per trajectory | 2.0 | 2.0 to 2.5 | mechanism.py |
| harmful accepts per trajectory | 3.0 | 1.0 | mechanism.py |
| absorption rate (AR) | 0.33 | 0.60 to 0.69 | dynamics_replay.py |

## Evaluation-budget method (32 designs, 5 seeds, equal cost caps)

| number | value | script | status |
|---|---|---|---|
| final rank, screen V1 then confirm V2, 100 s | 0.893 | scheduling_pool.py | FINAL |
| final rank, best fixed rung, 100 s | 0.804 | scheduling_pool.py | FINAL |
| margin at 100 s | +0.089 | scheduling_pool.py | FINAL |
| margin at 280 s | +0.080 | scheduling_pool.py | FINAL |
| final rank, screen on an unlegalized rung | 0.598 - 0.625 | scheduling_pool.py | FINAL |

## Transfer (24 source designs, 4 + 4 out-of-distribution designs)

| number | value | script | status |
|---|---|---|---|
| rank correlation of policy orderings, sky130 to ics55 | 0.874 | transfer.py | FINAL |
| rank correlation of policy orderings, sky130 to nangate45 | 0.905 | transfer.py | FINAL |
| source-best policy rank on ics55 / nangate45 | 0.893 / 0.799 | transfer.py | FINAL |
| TR ratio, ics55 / nangate45 | 1.000 / 0.923 | transfer.py | FINAL |

## Live loop versus replay (seed 1000, 16 rounds, 128 of 128 cells, 32 designs)

| rung | live dQ_T | replay dQ_T | live r* | replay r* | live ends worse | replay ends worse | script |
|---|---|---|---|---|---|---|---|
| V0 internal wirelength | -0.699 | -0.491 | 0 | 0 | 97% | 100% | live_vs_replay.py |
| V1u unlegalized wirelength | -0.644 | -0.500 | 0 | 0 | 100% | 88% | live_vs_replay.py |
| V1 legalized wirelength | +0.175 | +0.143 | 4 | 2 | 16% | 9% | live_vs_replay.py |
| V2 fair ruler | +0.159 | +0.107 | 4 | 2 | 16% | 9% | live_vs_replay.py |

The two implementations split the rungs into the same two groups (cheap negative,
faithful positive), agree on the sign and the horizon, and agree on magnitudes to about
0.06. The order *within* the cheap group is not stable (live puts V1u above V0, the
replay the reverse) because the spread inside that group is 0.055 and 0.009 against a gap
of about 0.8 to the faithful group, so the two cheap rungs are indistinguishable from
each other. The live run does not include the route-utilization arm, so the common-rung
set is these four.

## Arms by split, including the sealed designs (5 seeds, 16 rounds per cell)

True gain over 16 rounds, median; A0 is the start state so its gain is zero by definition.

| split | designs | n | A1 unlegalized | A1 legalized | A2 ruler | script |
|---|---|---|---|---|---|---|
| dev | 13 | 65 | -0.500 | +0.179 | +0.125 | sealed_arms.py |
| val | 5 | 25 | -0.444 | +0.143 | +0.214 | sealed_arms.py |
| sealed | 6 | 30 | -0.536 | +0.125 | +0.125 | sealed_arms.py |
| ood | 8 | 40 | -0.375 | +0.196 | +0.250 | sealed_arms.py |

Gain per second on the sealed split: legalized 8.5e-4 > ruler 5.4e-4 > unlegalized
(negative), the same ordering as the development split. The sealed designs were used
for nothing except this report.

## Signoff spot check (one design, two candidates)

| number | value | script | status |
|---|---|---|---|
| DRC violations, geometry-optimal candidate | 155 | ieda/rsi/harness/signoff_rung.py | FINAL (n=1) |
| DRC violations, cheap-rung attractor | 332 | signoff_rung.py | FINAL (n=1) |
| routing wall time, geometry-optimal | 148 s | signoff_rung.py | FINAL (n=1) |
| routing wall time, cheap-rung attractor | 1619 s | signoff_rung.py | FINAL (n=1) |

Scope: one design, two candidates, run to illustrate that the ordering survives to the
end of the flow. Not a sampling measurement; no other claim depends on it. DRC summaries
are kept at ieda/rsi/analysis/out/signoff_*_drc.json.

## Kill criteria

| criterion | verdict | evidence |
|---|---|---|
| K1 finite true-improvement horizon exists for weak rungs | PASS | ieda/rsi/analysis/go_no_go.py |
| K2 cheap and strong rungs are distinguishable | PASS | go_no_go.py |
| K3 the method beats the best fixed rung at equal cost | PASS (margin +0.071 to +0.089) | go_no_go.py |
| K4 the stochastic arm is reproducible | PASS (amendment A4) | go_no_go.py |

A verdict of PASS on K3 corrects an earlier FAIL recorded on a pool one third the
size; see the draft, Section 7, and the correction paragraph there.

## Figures

| figure | content | script |
|---|---|---|
| fig1_fidelity_heatmap.png | rung vs truth-component correlations | figures_stage1.py |
| fig2_selection_regret.png | cost of a cheap verifier | figures_stage1.py |
| fig3_mechanism.png | how legalization moves wirelength, density vs congestion | figures_stage1.py |
| fig4_dynamics.png | believed and true improvement by rung; the gap | dynamics_replay.py |
| fig5_scheduling.png | equal-budget policy comparison | scheduling_pool.py |
| fig6_timing_vs_ruler.png | geometry ruler vs timing misranking | timing_fidelity.py |
| fig7_external_anchor.png | our picks against the commercial reference | anchor_report.py |
| fig8_transfer.png | policy preference across technologies | transfer.py |
| fig9_arms_by_split.png | arms by split including the sealed designs | sealed_arms.py |
| fig10_live_vs_replay.png | live loop versus replay | live_vs_replay.py |
| fig11_mechanism.png | the two terms of the model, measured | mechanism.py |

## Reproducing

    cd /home/lizhijun/work/ieda-rsi
    /usr/bin/python3 ieda/rsi/analysis/fidelity.py          --root runs/v2
    /usr/bin/python3 ieda/rsi/analysis/timing_fidelity.py   --root runs/v2
    /usr/bin/python3 ieda/rsi/analysis/dynamics_replay.py   --root runs/v2
    /usr/bin/python3 ieda/rsi/analysis/scheduling_pool.py   --root runs/v2 --budgets 100,140,200,280
    /usr/bin/python3 ieda/rsi/analysis/transfer.py          --root runs/v2
    /usr/bin/python3 ieda/rsi/analysis/anchor_report.py
    /usr/bin/python3 ieda/rsi/analysis/sealed_arms.py       --root runs/v2
    /usr/bin/python3 ieda/rsi/analysis/live_vs_replay.py    --root runs/v2
    /usr/bin/python3 ieda/rsi/analysis/mechanism.py         --root runs/v2
    /usr/bin/python3 ieda/rsi/analysis/go_no_go.py          --root runs/v2

The ledger (runs/v2/ledger.jsonl) is append-only and carries a protocol hash on
every record. Measurements are keyed on the candidate and the solver binary
(amendment A6), so re-running the analyses is exact and re-running the experiments
reuses every valid measurement.

## Pre-submission audit

    /usr/bin/python3 ieda/rsi/analysis/number_audit.py --root runs/v2

Re-derives every headline number from the frozen analysis output and compares it with
the value quoted in the paper or the results index. 45 checks, all passing.
