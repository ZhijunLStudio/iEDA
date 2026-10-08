# Round 74: the complete paired multi-seed baseline, and the cheapest path to a primary improvement

## 1. What was measured

All 15 designs, **both arms**, seeds 1000-1003, 120 cells: `PL.num_threads=1` and `OMP_NUM_THREADS=1`,
one cell per process, the same ruler against the same legalised reference. This is the first time the
campaign has a paired multi-seed table in the metric form that rounds 72-73 showed is required.

## 2. The result

| design | unmodified | modified | |
|---|---|---|---|
| gcd_nangate45_a | 4/4 | 4/4 | |
| s1238_ics55_a | 4/4 | 4/4 | |
| **salsa20_ics55_a** | 2/4 | **3/4** | improved |
| **s1238_nangate45_a** | 1/4 | **3/4** | improved |
| gcd_sky130_a | 1/4 | 1/4 | |
| **apb4_timer** | 0/4 | **1/4** | improved |
| **gcd_ics55_a** | 0/4 | **1/4** | improved |
| aes, picorv32, s1238, s1238_sky130_a, s38584_ics55_a, s38584_nangate45_a, s5378_sky130_b, salsa20_nangate45_a | 0/4 | 0/4 | never pass in either arm |

    primary   (designs passing on EVERY seed)      unmodified 2/15    modified 2/15
    secondary (passing design-seed cells of 60)    unmodified 12/60   modified 17/60

    per-seed pass count of 15:   base 2, 4, 3, 3      cur 5, 5, 4, 3

**No design regresses, four improve, and the primary count does not move.** The in-tree changes (SR-10,
SR-11, SR-21) have raised the pass *rate* by 5 cells of 60 and left the every-seed count at 2 of 15.

That is the honest answer to the objective in its own terms, and it also corrects the number the
campaign reported: "4/15 then 5/15" are seed-1000 figures, and their seed-1000 counterparts here are
**base 2/15 and modified 5/15** - a difference that collapses to zero on the every-seed criterion.

## 3. The eight designs that never pass are the whole problem

Three quarters of the design set fails on all four seeds in both arms. Their failures are not marginal
either:

| design | worst dimension | the gap |
|---|---|---|
| gcd_sky130_a | union | 1810-1976 against 900 (2.0-2.2x), and 911 against 900 on the best seed |
| s1238_sky130_a | union, max | 2.05x / 1.86x |
| aes | union, max | 1.36x / 1.78x |
| picorv32 | union, max | 1.45x / 1.61x |
| s1238 | union, max | 1.15x / 1.43x |
| s5378_sky130_b | union, max | 1.55x / 1.27x |
| s38584_ics55_a | union, max | 1.17x / 1.60x |
| salsa20_nangate45_a | union, max | 1.89x / 1.71x |

## 4. The cheapest path to a primary improvement, quantified

From the per-cell detail, the seeds that block a design from 4/4:

| design | current | the only blocking seed | what it needs |
|---|---|---|---|
| **apb4_timer** | 3/4 would be close: passes 1000, fails 1001 (max 20 vs 16), 1002 (**max 17 vs 16**), 1003 (max 19 vs 16) | 1002 needs **one bin**; 1001 and 1003 need 4 and 3 bins | peak overflow down |
| **salsa20_ics55_a** | passes 1001-1003, fails **only** 1000 | max 43 vs 35 - **8 bins** | peak overflow down |
| gcd_ics55_a | passes only 1000; fails 1001 (union 46), 1002 (25), 1003 (42) | needs union to 20 | total overflow down |
| s1238_nangate45_a | passes 1000-1002, fails 1003 | **reference is 0 and we get 4** - a zero-overflow reference | not realistically reachable by optimisation |
| gcd_sky130_a | passes only 1001; fails 1003 by 911 against 900 | **11 bins, 1.2%** | total overflow down 1.2% |

**Two designs are one small step from adding to the primary count: `apb4_timer` needs one overflow bin
at seed 1002, and `salsa20_ics55_a` needs eight bins of peak at seed 1000.** Either one moves the
primary count from 2/15 to 3/15, which is a 50% relative increase on the criterion that matters.

Both are **peak**-congestion deficits, which is consistent with every previous localisation in this
campaign (the peak is the binding dimension).

## 5. Two observations that constrain the next change

1. **On several seeds the two arms are numerically identical** (gcd_sky130_a seed 1003 union 911 in both;
   s1238_nangate45_a seed 1003 union 4 in both; gcd_ics55_a seed 1001 union 46 in both, hpwl to the last
   digit 4078133). The in-tree guards simply do not fire on those inputs, so a change that only sharpens
   the existing guards cannot help them.
2. **s1238_nangate45_a's reference has literally zero overflow**, so any nonzero result loses. Two
   designs in this set (it and gcd_nangate45_a) have a zero reference, and gcd_nangate45_a passes 4/4
   only because we also reach zero on every seed. That is a knife-edge criterion and it should be stated
   as such rather than treated as a continuous gap.

## 6. State

- **In the tree**: SR-10, SR-11, SR-21, the round-67 thread-pin fix, the round-70 measurement-directory
  fix. **iEDA-det3 = 83ee2f75**.
- **Baseline (durable)**: `runs/multi_seed_summary.json` copied to
  `rsi/analysis/out/multi_seed_summary.json`; per-cell records in `runs/seedcells/`.
- **New harness**: `rsi/harness/multi_seed_sweep.py` - resumable, per-cell JSON, reports both metric forms.
- **Diagnosed but not fixed**: `GridManager::evalRouteUtil` sums two **float** totals inside an
  `omp critical` (`_h_util_sum`, `_v_util_sum`) whose order follows thread interleaving, and
  `BinGrid::evalRouteDem/evalRouteCap` accumulate **float** per-bin demand and capacity with
  `#pragma omp atomic` over a `schedule(dynamic)` loop. Float addition is not associative, so those
  quantities are order dependent. The two sums are **dead code** (their only non-assignment use is
  commented out), but `h_cong`/`h_cap` feed `h_util`, which the directional reweighting reads at every
  congestion-effort level. This is a real latent defect; it is **not** demonstrated to be the cause of the
  residual `num_threads=16` variation, because the unmodified tree is byte-reproducible at 16 threads. It
  is recorded as the next instrument item, not as a fix.

## 7. Next

1. **Target `apb4_timer` at seed 1002 (one bin) and `salsa20_ics55_a` at seed 1000 (eight bins of peak).**
   Both are peak-congestion deficits on designs that already pass on the other seeds, so a small,
   mechanistically-motivated reduction in the worst-bin demand is the natural candidate - and the target
   is unambiguous: primary 2/15 -> 3/15.
2. Fix the float-accumulation order dependence in `GridManager`/`BinGrid` (section 6), then re-check the
   16-thread reproducibility.
3. Keep the `multi_seed_sweep.py` table as the acceptance instrument: a change is accepted only if it
   raises the primary count or, failing that, the secondary count with no design regressing.
