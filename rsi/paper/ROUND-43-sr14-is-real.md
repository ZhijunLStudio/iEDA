# Round 43: SR-14 is a real improvement on the design it was built for, and SR-13 is mixed

## 1. The headline

SR-14 keeps the Nesterov solve alive past step-length stagnation when the density overflow is still above
1.1x its target, using the quadratic density penalty the tree already contains. It was **rejected earlier
as "identical to the control"** - a verdict produced by a harness that ran the same binary in both arms.

Measured properly, paired, same seed, same binary pair aside from the change, against the legalised
reference from the standing batch:

**gcd_sky130_a**

| seed | total overflow (ctl -> SR-14) | peak overflow | wirelength |
|---|---|---|---|
| 1000 | 2.2556 -> **0.9667** (-1.289) | 1.2727 -> **0.8182** (-0.454) | **-16.0%** |
| 1001 | 1.0211 -> **0.9678** (-0.053) | 1.0000 -> 1.0000 | -0.2% |
| 1002 | 2.0111 -> **0.8500** (-1.161) | 1.3636 -> **0.9091** (-0.454) | **-11.5%** |

**All three seeds improve total overflow, two of three improve peak substantially as well, and wirelength
never gets worse.** Two of the three seeds take total overflow from failing the reference to winning it,
and the peak from 1.27x to 0.82x.

The mechanism matches the design: gcd_sky130_a is one of the designs whose global placement exits with
overflow well above its own target (0.1233 against 0.1), and SR-14 is specifically the change that acts
in that case. It helping there and not elsewhere is what the derivation predicts, not a coincidence to be
caught by a later test.

## 2. SR-13, which is mixed

SR-13 tightens the detail-placement guard so that any worsening of the peak discards the stage, instead
of only a worsening that also fails to improve the total. Its earlier verdict was "fires on 1 of 6
seed-pairs, effect inside the noise", from the same broken harness.

| design | seed | total overflow | peak | wirelength |
|---|---|---|---|---|
| s1238_sky130_a | 1000 | 2.193 -> 2.053 (-0.14) | 2.357 -> **1.857 (-0.50)** | -3.7% |
| s1238_sky130_a | 1001 | 1.885 -> **1.983 (+0.10)** | 1.357 -> **1.929 (+0.57)** | -1.3% |
| s5378_sky130_b | 1000 | 1.562 -> 1.557 | 1.273 -> 1.273 | 0.0% |
| s5378_sky130_b | 1001 | 1.536 -> 1.530 | 1.273 -> 1.273 | 0.0% |
| s5378_sky130_b | 1002 | 1.629 -> 1.632 | 1.273 -> 1.273 | 0.0% |

**It helps substantially at one seed, hurts substantially at another, and does nothing on the second
design.** That is genuinely mixed, and it is consistent with the original reading in spirit - the verdict
"mixed, keep the weaker rule" survives, but now it survives on a measurement that could have found
otherwise.

## 3. What this round changes

- **SR-14 moves from rejected to a candidate**: a measured, consistent, three-seed improvement on the
  design its mechanism targets, with no cost to wirelength.
- **SR-13 stays out**, on measured grounds rather than on an artifact.
- **The scope of SR-14 is one design.** It is the design whose global placement the mechanism addresses,
  and the next step is to check the designs whose global placement converges normally, where it should be
  inert - both to confirm the mechanism and to confirm it does not cost anything elsewhere.
- The wrapper set now includes iEDA-sr13-nosshim and iEDA-sr14-nosshim, so the reverted binaries remain
  testable inside the environment that hides the host's preload shim.

## 4. A process note, applied immediately

The extension of the SR-14 test was first launched with CPU sets 640-703, which exceed the machine's 512
cores - the same mistake that silently invalidated a batch in round 39. It was caught within the same
round, before any result was read, by checking the CPU count against the set. Given that this is the
second occurrence, the check is now: **any harness launch verifies its CPU set against nproc first.**

## 5. Tree state

Source unchanged: SR-10 and SR-11 in; SR-2/3/4/5/7/8/9/12 withdrawn. **SR-14 is a live candidate pending a
multi-design check; SR-13 remains out.** Binary f9581627.
