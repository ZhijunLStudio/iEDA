# Round 45: SR-15, a self-guarded version of SR-14, and a correction to round 44

## 1. A correction first

Round 44 recorded that "congestion moves with the mechanism", and used s1238_sky130_a as the case where
SR-14 raised global placement's terminal overflow at all three seeds and congestion got worse. The full
scoring does not support that for that design:

| s1238_sky130_a seed | total overflow (ctl -> SR-14) | peak overflow | wirelength |
|---|---|---|---|
| 1000 | 2.0525 -> **1.9515 (better)** | 1.8571 -> **1.6429 (better)** | +0.4% |
| 1001 | 1.8852 -> 2.3484 (worse) | 1.3571 -> 1.6429 (worse) | +6.4% |

**One seed improves both congestion dimensions, the other worsens both** - while the terminal overflow
rose at both. So the chain "terminal overflow up therefore congestion worse" is **not** reliable on this
design, and round 44 stated it more strongly than the data supports.

What does hold, and is the part worth keeping: **the mechanism is inert on designs whose global placement
reaches its target** (apb4_timer, gcd_ics55_a, s1238_ics55_a all terminate at 0.098-0.100 and their
numbers do not move), and on gcd_sky130_a the terminal overflow and the congestion outcome agree at four
of five seeds.

## 2. Why that motivates the change rather than undermining it

If the sign cannot be predicted from outside the solve, then the way to make SR-14 usable is not to
predict it but to **measure it inside the solve** - the same pattern that worked for the detail-placement
guard.

**SR-15** does exactly that:

1. at step-length stagnation, if the overflow is still above 1.1x target, record the overflow, the
   position and the density scales, engage the quadratic density penalty and continue;
2. let the solve run for a bounded number of further iterations;
3. **if the overflow fell, keep the result; if it did not, restore the recorded position and scales and
   stop where the solve would have stopped anyway.**

The guard is on the quantity the mechanism exists to reduce, measured by the solve itself, so the outcome
is bounded regardless of the design: **it can gain where SR-14 gained and it cannot lose where SR-14 lost.**

Built as iEDA-sr15 (md5 4594497102149833f58272aa7b285f68), with the control pinned to iEDA-clean89
(f9581627, the current tree) so the pair differs by exactly this change.

## 3. What is being measured

Four designs times three seeds, paired against the pinned control, scoring both arms against the legalised
reference from the standing batch:

- **gcd_sky130_a**, where SR-14 gave large gains at four of five seeds - SR-15 should keep them;
- **s1238_sky130_a**, where SR-14 helped at one seed and hurt at another - SR-15 should keep the first and
  refuse the second;
- **apb4_timer** and **gcd_ics55_a**, whose global placement converges - SR-15 should be inert, which is
  the safety property.

The first runs are in progress; eight of twenty-four configurations are placed.

## 4. Notes on the harness

The control for this test had to be pinned explicitly: building SR-15 overwrote build/bin/iEDA, so the
"current tree" arm would otherwise have been SR-15 itself in both arms - the exact defect that invalidated
the SR-13 and SR-14 tests. The arm table now names the control by its saved binary rather than by the
build output, and the wrapper for it was created and verified before launching.

## 5. Tree state

**SR-15 is a source change in the tree pending its measurement.** SR-10 and SR-11 remain; SR-2/3/4/5/7/8/9/12
withdrawn; SR-13 out as mixed; SR-14 superseded by SR-15 if the guard works as designed.
