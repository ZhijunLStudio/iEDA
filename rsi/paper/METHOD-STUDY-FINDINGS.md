# Findings before a method-level (source-modifying) RSI study

Measured in this workspace on 2026-09-17, to answer: can we iterate on iEDA's placement
algorithms themselves (placer_run_gp / _lg / _dp) rather than on configuration knobs?

## 1. Incremental rebuild is not the bottleneck

    one .cc in iPL   (src/operation/iPL/api/PLAPI.cc)   -> 14 s, 16 ninja targets
    one header       (src/operation/iPL/api/GPContract.hh) -> 18 s, 36 ninja targets

Both include recompiling, re-archiving and relinking bin/iEDA (240 MB). Twenty rounds
of source iteration therefore cost about 5 minutes of compile time in total.

## 2. Per-candidate cost: the downstream stages are the CHEAP ones

Median wall seconds per candidate over 32 designs, from the campaign ledger
(cost_components on every stage1-pool record):

    global placement (gp)          7.4 s
    legalization + detail (lg+dp)  2.9 s
    trial route (egr)              6.2 s

lg+dp is the cheapest stage on 32/32 designs (about 20% of candidate time). On the
largest design (aes): gp 88.2 s, lg+dp 37.9 s, egr 48.5 s.

## 3. What each downstream stage does to wirelength (same GP start, six designs)

Isolated with a purpose-written stage script (tcl/pl_stage.tcl, init order taken from the
working timing rung). GP-only output is NOT legalized; the other two are.

| design | GP (illegal) | +LG | +LG+DP | LG move | DP move | cost of skipping DP |
|---|---|---|---|---|---|---|
| gcd_sky130_a | 6849500 | 7025178 | 6906347 | +2.6% | -1.7% | +1.7% |
| s1238_sky130_a | 6430955 | 6572625 | 6288275 | +2.2% | -4.3% | +4.5% |
| aes_sky130_a | 276997520 | 545096496 | 431150280 | **+96.8%** | **-20.9%** | **+26.4%** |
| s38584_sky130_a | 193929381 | 309769522 | 274888151 | **+59.7%** | -11.3% | +12.7% |
| gcd_nangate45_a | 6786803 | 7090060 | 7072540 | +4.5% | -0.2% | +0.2% |
| gcd_ics55_a | 3918981 | (crash) | (crash) | rc=-11 | | |

So: **legalization inflicts damage (+2% to +97%) and detailed placement repairs most of
it (-0.2% to -21%).** Skipping DP costs +0.2% to +26% of the final wirelength, and DP
costs a fraction of GP. The premise "DP is too slow to touch" does not hold.

Two tooling defects found on the way:
- gp_agent.py lg run standalone fails (rc=1) and silently leaves placement.def untouched;
  only the dp path (init_pl + placer_run_lg + placer_run_dp) works.
- the legalization path segfaults on ics55 (rc=-11) with the resolved cell LEF.
- the case-root script/DB_script/db_path_setting.tcl expects env(TECH_LEF_PATH) etc.,
  which only the flow driver sets; a hand-written stage script must use absolute paths.

## 4. The GP-stage number cannot be used as a score

- GP output is not legalized (cells overlap, which fabricates short wires).
- rho between pre-LG HPWL and post-LG+DP HPWL over the candidate pool: **-0.891**.
- the pre-LG-best candidate is the post-LG+DP-best on **0 of 32** designs.

## 5. The proposed three verifier dimensions disagree with each other

| pair | median Spearman over designs |
|---|---|
| legalized HPWL vs congestion union | +0.970 |
| legalized HPWL vs peak congestion | +0.715 |
| legalized HPWL vs timing (setup TNS) | **-0.471** |
| solver-internal HPWL vs legalized HPWL | **-0.892** |

- the HPWL-best candidate is also the congestion-best on only **16/32** designs, while
  pairwise discordance between the two is only 5.6%: they agree on almost every pair
  but disagree on the winner half the time.
- consequence: "measure three dimensions and take the best" is not well defined without
  a combining rule. This study used Pareto dominance in the loop and rank aggregation
  offline, precisely to avoid an arbitrary weight.

## 6. Noise floor at a fixed configuration (three seeds, 32 designs)

| quantity | median spread (max-min)/mean | p90 |
|---|---|---|
| legalized HPWL | 0.86% | 4.33% |
| congestion union | 5.92% | 26.05% |

Congestion is about seven times noisier than wirelength. For reference, moving target
density from 0.80 to 0.95 changes wirelength by about -1.5% and congestion by about
+79%. Any wirelength effect below ~1% needs repetition to be visible.

## 7. What is actually available

- Usable PDKs: **three** (sky130 24 designs, ics55 4, nangate45 4). asap7 and ihp130 are
  registry entries whose references point at dead paths and are excluded.
- Floorplan: the iEDA input DEF and the Innovus output DEF share the same DIEAREA on
  **32 of 32** designs, so "same input" is already satisfied in this data.
- Matched cross-PDK set: four circuits exist in all three usable PDKs, covering S/M/L:
  gcd (S), s1238 (S), salsa20 (M), s38584 (L) x {sky130, ics55, nangate45} = 12 designs.
  This removes the circuit as a confound when testing whether a method change transfers.
