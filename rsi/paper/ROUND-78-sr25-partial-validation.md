# Round 78: SR-25 partial four-seed validation - promising, and incomplete

## 1. Status

The full four-seed validation of SR-25 is **not complete**. 14 valid cells exist of 60; three records
produced no placement DEF (a workdir race with the previous, interrupted launch) and have been deleted so
they are re-measured. The launcher was reaped twice mid-sweep, so the sweep must be re-run to completion.

## 2. What the valid cells show (concurrent pattern, four flows in flight)

| design | seed | current tree (u,m) | SR-25 (u,m) | reference | verdict |
|---|---|---|---|---|---|
| **gcd_sky130_a** | 1000 | (1976, 26) | **(800, 16)** | (900, 22) | **PASS** |
| **gcd_sky130_a** | 1001 | (847, 16) | (815, 16) | (900, 22) | **PASS** |
| apb4_timer | 1000 | (1928, 16) | (1877, 16) | (2071, 16) | PASS |
| **apb4_timer** | **1002** | (2029, 17) | **(1964, 16)** | (2071, 16) | **PASS** (the one-bin gate) |
| apb4_timer | 1001 | (2131, 20) | (2121, 22) | (2071, 16) | fail |
| apb4_timer | 1003 | (1814, 19) | (2137, 16) | (2071, 16) | fail on union |
| gcd_ics55_a | 1000 | (16, 2) | (18, 3) | (20, 6) | PASS |
| gcd_ics55_a | 1001-1003 | 46 / 25 / 42 | 58 / 33 / 34 | (20, 6) | fail |
| gcd_nangate45_a | all four | (0, 0) | (0, 0) | (0, 0) | PASS, 4/4 |

Two things stand out beyond the round-77 screen:

1. **`gcd_sky130_a` now passes at seeds 1000 and 1001**, with union **800 and 815 against 900** - a
   0.89x result on a design that failed on all three dimensions with union 2.2x, and one of the two
   designs whose global placement hits the 2000-iteration cap. In the round-77 screen (three flows in
   flight) the same cell read 907, a 7-bin shortfall; at four in flight it reads 800 and passes. That is
   the round-76 co-run coupling again, at exactly the scale it was measured at.
2. **`apb4_timer` seed 1002 now passes** - the cell round 74 identified as the one-bin gate
   (peak 17 -> 16), which SR-23/SR-24 could not deliver and which SR-25 does.

So on the valid cells SR-25 gives 9 passes of 14 and turns two designs' blocking cells into passes.

## 3. What is still not established

- **Seeds 1002 and 1003 for the designs that matter**, and the whole table for aes, picorv32, s1238,
  s1238_ics55_a, s1238_sky130_a, s38584_ics55_a, salsa20_nangate45_a, s5378_sky130_b.
- **The two union regressions** seen in the screen (picorv32 1.453 -> 1.581, s1238 1.150 -> 1.206).
- **The co-run pattern**: these numbers are four-in-flight, not the adopted one-at-a-time.
- **Cost**: the flow is roughly tripled by two extra global-placement segments. `salsa20_ics55_a` at one
  thread is ~230 s per flow before this and the segments add about 460 s.

**No claim of an accepted improvement is made in this round.** The objective's acceptance rule is the
every-seed count with no passing design regressing, and the table that decides it does not exist yet.

## 4. Immediate next step

Re-run the validation to completion, and **launch it in a way that survives my session**: the two failures
this round were the launcher being reaped, not the code. Until then the recorded state is:

- tree: SR-25 in place, `iEDA-sr25 = c385b257`, committed (5f737d8);
- `runs/seedcells_sr25` with 14 valid cells and the invalid records deleted for re-measurement;
- baselines unchanged: current tree primary 2/15 / secondary 17/60, unmodified 2/15 / 12/60.
