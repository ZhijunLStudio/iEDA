# Round 77: SR-25, the first change that attacks global placement itself, and its screen

## 1. What was built

`PLAPI::runGatedGPRefine(max_segments, iterations, congestion_effort)`, called from the finishing hook
after the existing detail-placement passes, with a budget of 2 segments, 300 iterations each and
`congestion_effort = 4`.

Each segment re-linearises **global placement** from the current coordinates at effort 4, then runs one
legalisation and one detail placement, measures peak and total overflow with the project's own evaluator,
and keeps the segment only if it improves the peak or holds the peak and improves the total. Nothing is
undone during the loop, so a segment that looks worse alone can still lead to the one that wins, and the
best segment is restored at the end.

Why global placement rather than more detail placement: round 29 localised the deficit at global
placement plus legalisation (1.87x-2.07x the reference on wirelength on the designs the flow still fails)
while detail placement improves the peak on three of five designs tested. The finishing passes already act
on the repair stage; the demand that costs the peak is created upstream of it.

Why effort 4 in particular: it is the level the tree's own comment describes as using the verification
evaluator's own demand model. Levels 2-7 are excluded as **unconditional defaults** because their sign
varies by design. That exclusion says a level cannot be trusted applied to everything; it does not say a
level cannot be used as an accepted-or-rejected refinement - which is the shape that made the finishing
passes bounded and self-guarding.

This is the same structure as round 1's SR-22, which was reverted on one design at 35 s of flow time on the
**pre-fix instrument**, where the guard's own measurement was reading back stale per-layer overflow maps
from a reused directory (round 70). It had never been validly tested. Built as **iEDA-sr25 = c385b257**.

## 2. Execution verified first, as the campaign requires

    [SR-25] entry:                 peak 26 total 1976
    [SR-25] segment 1/2 effort 4:  peak 18 total 826   <- new best
    [SR-25] segment 2/2 effort 4:  peak 16 total 907   <- new best
    [SR-25] last segment was the best: peak 16 total 907

Both segments executed, both improved, bounded, and the entry state (peak 26, total 1976) is exactly the
current tree's result for that design and seed. So the change runs, and the improvement is not an artifact
of the gate failing to fire.

## 3. The screen, nine designs plus one, seed 1000

Both columns are the same co-run pattern (three flows in flight), so they are comparable to each other;
see section 5 for what that does and does not license.

| design | current union | SR-25 union | current max | SR-25 max | verdict |
|---|---|---|---|---|---|
| **salsa20_ics55_a** | 0.786 | **0.728** | 1.229 | **0.943** | **fail -> PASS** |
| **s1238_sky130_a** | 2.053 | **0.809** | 1.857 | **1.000** | fail only on hpwl by **0.17%** |
| **gcd_sky130_a** | 2.196 | **1.008** | 1.182 | **0.727** | fail on union by 7 bins |
| s38584_ics55_a | 1.166 | 1.049 | 1.600 | 1.067 | still fails, much closer |
| s5378_sky130_b | 1.561 | 1.518 | 1.273 | 1.182 | still fails, slightly closer |
| apb4_timer | 0.931 | 0.883 | 1.000 | 1.000 | PASS -> PASS (union improved) |
| gcd_nangate45_a | 0 | 0 | 0 | 0 | PASS -> PASS |
| s1238_ics55_a | 0.523 | 0.523 | 0.429 | 0.429 | PASS -> PASS |
| picorv32 | 1.453 | 1.581 | 1.611 | 1.556 | worse union, still fails |
| s1238 | 1.150 | 1.206 | 1.429 | 1.214 | worse union, still fails |

**Reading it:**

- **One design moves from failing to passing on all three dimensions** (salsa20_ics55_a), and its failing
  dimension was the peak - the dimension that gates nine designs in this campaign.
- **Two designs move from catastrophic to marginal**: s1238_sky130_a from 2.05x union and 1.86x peak to
  0.809x and 1.000x, missing only wirelength by 0.17%; gcd_sky130_a from 2.20x union to 1.008x, missing by
  7 overflow bins.
- **No currently-passing design regresses.** The three passing designs in the screen are unchanged or better.
- **Two designs get worse on union** (picorv32 1.453 -> 1.581, s1238 1.150 -> 1.206) while their peaks
  improve. Both were failing before and after, so neither flips a verdict, but the trade is real and is
  recorded rather than hidden.

If the seed-1000 screen held exactly, the seed-1000 pass count would go from 5/15 to 6/15 with a seventh
one 0.17% away - but a screen is not the instrument.

## 4. Why a mechanism-level explanation is plausible

Effort 4 makes global placement minimise the **evaluation evaluator's own demand model** - the same union
RUDY map the ruler scores - instead of a wirelength objective that has no notion of capacity. The
campaign's round-2 measurement found our peak bin asks the router for 1.85x the reference's demand on
**30 of 30** designs. A refinement that pushes the placement's own objective onto that quantity is
targeting exactly the measured defect, and the segment logs show it working in the direction expected:
peak 26 -> 18 -> 16 on gcd_sky130_a.

Contrast with the excluded attempts: level 5, level 7 and effort 4 as a *default* were measured as
unreliable or destructive. Those tests applied the level to the whole run on every design. Here it is
applied for 300 iterations from an already-converged placement and **rejected unless the scored numbers
improve**.

## 5. What is not yet established

1. **Single seed.** The screen is seed 1000. Rounds 72-74 showed pass/fail is seed dependent and that for
   the near-miss designs the failing seed moves. A design that passes at seed 1000 has not been fixed.
2. **Co-run pattern.** The screen ran three flows in flight. Round 76 showed the co-run pattern changes
   cell values by 1-2 bins, which does not affect effects of this size (0.8x-1.4x) but does mean these are
   not the adopted one-flow-at-a-time numbers.
3. **Cost.** Each segment is a full global-placement re-linearisation plus legalisation plus detail
   placement, so the flow is roughly tripled. `aes` at one thread is about 600 s per flow before this.
4. **The two union regressions** are unexplained and may matter on other seeds.

The full four-seed validation is running now; nothing here should be treated as an accepted improvement
until it reports under the metric form of round 74 (designs passing on every seed, and design-seed cells).

## 6. State

- **Tree**: SR-25 is built and in the tree as `iEDA-sr25 = c385b257`; `build/bin/iEDA` is that build.
  Round 75's SR-23/SR-24 remain withdrawn.
- **Running**: `multi_seed_sweep.py --arms sr25 --seeds 1000,1001,1002,1003 --workers 3`, results to
  `runs/seedcells_sr25`.
- **Baselines for comparison**: current tree primary 2/15, secondary 17/60; unmodified 2/15 and 12/60
  (round 74, concurrent pattern - to be re-taken serially).
