# Round 47: SR-16 fixes SR-15's bug and is still a knob, so it is withdrawn too

## 1. What SR-16 fixed

SR-15 was withdrawn because its engagement branches ended in continue, which skips the loop body - the
gradient updates, the penalty refresh and the bookkeeping - so a design whose global placement converges
(apb4_timer, terminal overflow 0.098) came out at 0.948.

**SR-16 has no continue.** When the solve should keep going it falls out of the if-else and the loop body
runs normally; when it should stop it breaks, as the original code did. Verified in the source before
building: zero continue statements in the patch.

**The safety control passes.** apb4_timer, the design SR-15 destroyed:

| design | seed | control | SR-16 | SR-15 (withdrawn) |
|---|---|---|---|---|
| apb4_timer | 1000 | 0.0983 | **0.0998** | 0.9479 |
| apb4_timer | 1001 | 0.0998 | **0.0991** | - |

The converging design stays converged. The implementation defect is fixed.

## 2. And yet it is still a knob

Eight paired configurations, three seeds on three designs, both arms scored against the legalised
reference:

| design | seed | total overflow | peak | wirelength |
|---|---|---|---|---|
| **gcd_sky130_a** | 1000 | 2.360 -> **1.108 (-1.252)** | 1.182 -> **0.818 (-0.364)** | **-14.2%** |
| gcd_sky130_a | 1001 | 1.021 -> **0.968** | 1.000 -> 1.000 | -0.2% |
| **apb4_timer** | 1001 | 0.996 -> **0.895** | 1.375 -> **1.000 (-0.375)** | -1.2% |
| apb4_timer | 1002 | 0.995 -> **0.943** | 1.125 -> 1.125 | -0.6% |
| apb4_timer | 1000 | 0.931 -> 0.977 (+0.046) | 1.000 -> 1.000 | -2.7% |
| **s1238_sky130_a** | 1000 | 2.053 -> 2.103 (+0.051) | 1.857 -> 1.929 (+0.072) | +1.0% |
| **s1238_sky130_a** | 1001 | 1.885 -> 2.214 (+0.329) | 1.357 -> **2.000 (+0.643)** | +2.7% |
| **s1238_sky130_a** | 1002 | 1.832 -> 2.114 (+0.282) | 1.714 -> 1.857 (+0.143) | +5.8% |

**Four configurations improve and four worsen.** The wins are large where they occur - gcd_sky130_a takes
total overflow from 2.36x the reference to 1.11x and wirelength down 14% - and the losses are consistent:
s1238_sky130_a gets worse at all three seeds.

**Withdrawn.** A change that helps half the configurations and hurts the other half, at no way of telling
them apart beforehand, is not adoptable, and the objective's rule is the same one applied to ce4.

## 3. The concrete gap the guard left

The guard was supposed to prevent exactly the s1238_sky130_a outcome: it restores the recorded state when
the overflow has not fallen. It did not, and the reason is structural:

**the guard only gets to decide at the next stagnation event.** On s1238_sky130_a the global-placement
overflow rose (0.128 -> 0.131), so the guard should have reverted - but the solve reached its iteration
limit instead of stagnating again, so the decision point was never reached and the worsened placement
stood. A guard that only fires at one of the two ways a solve can end guards neither.

Fixing that means evaluating the same condition at the loop's natural exit as well, which is a different
and slightly larger change than SR-16 and is not made here. It is recorded as the next step for this
mechanism.

## 4. What the three rounds on this mechanism have established

- **The mechanism is real**: engaging the density penalty past stagnation lowers global placement's
  terminal overflow on the designs that stagnate above their target, and congestion improves with it
  (gcd_sky130_a, at four of five seeds for the unguarded version).
- **It is inert where it should be**: designs whose global placement converges are untouched.
- **Its sign is not predictable from outside the solve**, and the two attempts to guard it internally
  failed for implementation reasons - one catastrophically, one partially.
- Therefore it is **not in the tree**, and the record says why.

## 5. Tree state

- **In the tree**: SR-10 and SR-11. Binary **f9581627**, source clean.
- **Withdrawn with recorded reasons**: SR-2/3/4/5/7/8/9/12, SR-13 (mixed), SR-14 (unpredictable sign),
  SR-15 (destroys a converging design), **SR-16 (mixed, 4 of 8)**.
- **Standing** unchanged: 4 of 15 designs no worse on every measurable dimension; wirelength fails 2 of
  15, total overflow 10 of 13, peak 9 of 13.

## 6. Another transient

The linker failure collect2: fatal error: cannot find ld occurred three times this round and cleared on
retry each time, with the machine loaded by parallel builds. It is being treated as load, not as a
toolchain or edit problem, and it has not produced a wrong result - the rebuild always reproduces the
expected hash.
