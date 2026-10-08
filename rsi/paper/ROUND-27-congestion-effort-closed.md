# Round 27: the global placer's congestion-effort family is closed, and why

## 1. What was untested, and what it does

The shipped configuration sets PL.is_congestion_effort: 0 in every design, so **global placement never
runs with any congestion term** - it optimises wirelength and cell density only. The option
-congestion_effort N sets both the on/off flag and the level.

The excluded list covered levels 2, 3 and 4, which modify the **wirelength gradient**. It did not cover
levels 5, 6 and 7, whose mechanism is different and, given the symptom, better matched:

- **level 5** lowers the per-bin density screen on bins whose routing utilisation exceeds 1.0, so the
  density penalty itself diffuses cells out of the wiring hotspot. It rides the density force rather
  than adding a competing one, and is damped (at most 15% per refresh, floor 0.6).
- **level 7** feeds real trial-route overflow back into the solver.

The symptom is that our **total** overflow is frequently much better than the reference while our
**peak** is worse - five designs at 1.26x to 1.45x with totals at 0.48x to 0.72x. Overflow that is
better in total and worse at the peak is **concentrated** overflow, and diffusing cells out of hotspots
is exactly the action that shape calls for.

## 2. Results

Paired, same seed, same binary, only the effort level differing:

| design | peak, ce0 to ce5 | total overflow | HPWL |
|---|---|---|---|
| picorv32 | 58 to **52** better | 121153 to 120277 better | +2.7% |
| s1238 | 40 to **32** better | 1766 to 1754 better | +1.5% |
| s5378_sky130_b | 28 to **32** worse | 3776 to 4252 worse | -1.0% |
| salsa20_ics55_a | 43 to **57** worse | 41966 to 73859 worse | +21.6% |
| apb4_timer | 16 to **19** worse | 1928 to 1846 better | -0.2% |
| salsa20_nangate45_a | 12 to **23** worse | 464 to 5088 much worse | +15.9% |

**Two designs better, four worse.** Level 5 is a knob, not a fix, and enabling it as a default would be
the same mistake the excluded levels 2 to 4 already were.

**Level 7 is not a near miss, it is destructive.** On picorv32 it takes the peak from 58 to **122**, the
total from 121153 to **449451** (3.7x) and wirelength from 249M to **475M** (1.9x). Real trial-route
feedback inside the solver destabilises it. The remaining level-7 runs were killed rather than
measured, because the first one settled the question.

## 3. Why it fails: the placer optimises a different quantity from the one that is scored

The evaluator's grid, measured from the maps it writes:

| design | EGR grid the score is computed on | placer's RUDY grid |
|---|---|---|
| s1238 | **28 x 28** (784 cells) | 128 x 128 (16384 cells) |
| gcd_nangate45_a | 60 x 60 | 128 x 128 |
| picorv32 | **190 x 190** (36100 cells) | 128 x 128 |

The score's resolution is set by the design and the router's gcell pitch; the placer's is a fixed
128 x 128. **On s1238 the placer has twenty times more cells than the score; on picorv32 it has less
than half.** The models differ too: the score is a peak over actual trial-route overflow after a
Gaussian blur, while the placer's screen is driven by its own RUDY demand on its own grid.

So level 5 lowers a screen on bins the **placer** believes are hot, computed at a resolution that is
neither finer nor coarser than the score's but simply different, and whether that reduces the scored
peak is then luck. That is the whole explanation of the 2-of-6 split, and it is the same reason levels
2 to 4 failed before it.

## 4. What this closes, and what it opens

**Closed**: enabling global placement's congestion awareness at any level. 2, 3, 4 excluded earlier; 5
measured mixed this round; 7 measured destructive. No level of this mechanism reduces the scored peak
reliably, because the mechanism acts on the placer's congestion quantity and the objective is a
different one. That is a definitive negative result and it retires the family.

**Opened**: the evaluator already writes the scored quantity at the scored resolution, as a per-cell
map - place_egr_union_overflow.csv, produced on every run. Nothing in the placer reads it. An action
anchored on the worst cells of **that** map would be targeting the quantity that is scored, at the
resolution it is scored at, which is precisely what every mechanism tried so far fails to do.

That is the next source change.

## 5. Tree state

No source change this round; the round is reconnaissance plus a closed family. In the tree: **SR-10**
(in-process congestion measurement) and **SR-11** (detail-placement dominance guard). Withdrawn with
recorded reasons: SR-2, SR-3, SR-4, SR-5, SR-7, SR-8, SR-9, SR-12.
