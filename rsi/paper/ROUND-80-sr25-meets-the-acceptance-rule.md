# Round 80: SR-25 meets the objective's acceptance rule - primary 2/15 to 4/15 with no regression

## 1. The result

Full four-seed validation, 60 of 60 cells, one locked single-instance sweep:

| design | current tree | SR-25 | change |
|---|---|---|---|
| gcd_nangate45_a | PPPP 4/4 | PPPP 4/4 | - |
| s1238_ics55_a | PPPP 4/4 | PPPP 4/4 | - |
| **s1238_nangate45_a** | PPP. 3/4 | **PPPP 4/4** | gains seed 1003 |
| **salsa20_ics55_a** | .PPP 3/4 | **PPPP 4/4** | gains seed 1000 |
| **gcd_sky130_a** | .P.. 1/4 | **PPP. 3/4** | gains seeds 1000 and 1002 |
| apb4_timer | P... 1/4 | P.P. 2/4 | gains seed 1002 |
| s38584_ics55_a | .... 0/4 | .P.. 1/4 | gains seed 1001 |
| s38584_nangate45_a | .... 0/4 | P... 1/4 | gains seed 1000 |
| gcd_ics55_a | P... 1/4 | P... 1/4 | - |
| aes, picorv32, s1238, s1238_sky130_a, s5378_sky130_b, salsa20_nangate45_a | 0/4 | 0/4 | still never pass |

    primary   (designs passing on EVERY seed)     current tree 2/15   ->  SR-25 4/15
    secondary (passing design-seed cells of 60)   current tree 17/60  ->  SR-25 24/60
    per-seed pass counts of 15   current 5 5 4 3      SR-25 8 6 6 4
    gains 7    regressions 0

**This satisfies the objective's acceptance rule as written**: the pass count rises, and no currently
passing design is turned into a failing one. It is the first change in this campaign that does.

Two things make it more than a knife-edge result:

- **SR-25 is better at every individual seed**: 8, 6, 6, 4 against 5, 5, 4, 3. Not an artifact of
  where the seed set happens to fall.
- **Two designs become all-seed passes** (s1238_nangate45_a, salsa20_ics55_a) and a third
  (gcd_sky130_a) goes from passing 1 seed in 4 to 3 in 4, on a design that previously failed all three
  dimensions with union 2.2x.

## 2. What SR-25 is

`PLAPI::runGatedGPRefine(2, 300, 4)`, called from the finishing hook after the existing
detail-placement passes. Each segment re-linearises **global placement** from the current coordinates at
`congestion_effort = 4`, then runs one legalisation and one detail placement, measures peak and total
overflow with the project's own evaluator, and keeps the segment only if it improves the peak or holds the
peak and improves the total. Nothing is undone during the loop, so a segment that looks worse alone can
still lead to the one that wins; the best segment is restored at the end.

Effort 4 is the level the tree's own comment describes as using the verification evaluator's own demand
model - the same union RUDY quantity the ruler scores. The campaign's round-2 measurement found our peak
bin asks the router for 1.85x the reference's demand on 30 of 30 designs, so this aims the placer's own
objective at the measured defect.

The levels it uses were **excluded as unconditional defaults** because their sign varies by design. That
exclusion is about applying a level to every design for the whole run; it does not apply to using a level
as a refinement that is rejected unless the scored numbers improve. This distinction is the whole idea,
and it is why the same mechanism that was rejected 60 rounds ago works here.

## 3. Execution was verified before the effect, as required

    [SR-25] entry:                 peak 26 total 1976
    [SR-25] segment 1/2 effort 4:  peak 18 total 826   <- new best
    [SR-25] segment 2/2 effort 4:  peak 16 total 907   <- new best

and on aes, where it does not help, the gate rejects both segments and the placement is unchanged:
`peak 58 -> 102, total 346124 -> 450455 | best is segment 0`. So the mechanism is not a blanket
"more effort is better"; it is a refinement bounded by the scored numbers.

## 4. Caveats, stated

1. **The two columns were measured under different co-run patterns** - the current-tree cells at four to
   six flows in flight (round 74), the SR-25 cells at four (this round). Round 76 showed the pattern moves
   a cell by 1-2 overflow bins. The observed gains are far larger than that (e.g. gcd_sky130_a union
   `1976 -> 800`, salsa20_ics55_a peak `43 -> 31`), and there are **zero** regressions, so the
   acceptance claim has margin. A matched-pattern re-measurement of both arms is still the rigorous
   confirmation and is the next measurement.
2. **Cost**: two extra global-placement segments make the flow roughly three times more expensive.
3. **Six designs still never pass** (aes, picorv32, s1238, s1238_sky130_a, s5378_sky130_b,
   salsa20_nangate45_a) plus seven that pass some seeds but not all. The objective wants all 15.
4. `gcd_ics55_a` is unchanged by SR-25 (1/4) - the one design where the original tree's guards were
   doing something SR-25 does not reproduce.

## 5. State

- **Tree**: SR-25 in place, `build/bin/iEDA` = `c385b257`, committed (5f737d8).
- **Evidence**: `runs/seedcells_sr25` (60 cells) copied to `rsi/analysis/out/sr25_*.json`;
  verdict script `rsi/harness/sr25_verdict.py`.
- **Baselines**: unmodified 2/15 primary and 12/60 secondary; current tree before SR-25 2/15 and 17/60.
- **Objective**: not met (it asks for all 15 designs on every measurable dimension). The goal stays
  active; what changed is that the measured count moved for the first time, from 2/15 to 4/15 on the
  criterion that survives multi-seed testing.
