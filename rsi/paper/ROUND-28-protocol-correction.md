# Round 28: the standing was measured under two different protocols, and the corrected one is much worse

## 1. How it was found

Comparing the location of the worst congestion cells, ours against the reference, the reference DEF had
to be legalised before it could be scored at all - the evaluator refused it with "placement not
site-aligned (cell overlap)". Legalising it with the same procedure we use gave a total overflow 2.0x
to 2.7x LOWER than the value recorded in the anchor file for the same DEF:

| design | reference, gate bypassed (the anchor) | reference, legalised | ratio |
|---|---|---|---|
| s1238 | 3693 / 30 | **1535 / 28** | union 2.41, max 1.07 |
| picorv32 | 167614 / 40 | **83408 / 36** | union 2.01, max 1.11 |
| apb4_timer | 5626 / 26 | **2071 / 16** | union 2.72, max 1.62 |

## 2. Which protocol is right, and the controlled test that decides it

Two explanations: either the commercial DEF is genuinely illegal by iEDA's rules and illegality really
costs that much, or the bypass path scores differently. HPWL is unchanged between the two, so the
difference is not simply that legalisation moved cells a long way.

**The test**: score OUR OWN already-legal placement both ways. Ours is legal by construction, so if the
bypass were the cause, the two paths would differ there too.

| design | our placement, bypass | our placement, normal path | ratio |
|---|---|---|---|
| s1238 | 1766 / 40 | 1766 / 40 | 1.00 |
| picorv32 | 121153 / 58 | 121153 / 58 | 1.00 |
| apb4_timer | 1928 / 16 | 1928 / 16 | 1.00 |
| s1238_ics55_a | 81 / 6 | 81 / 6 | 1.00 |

**Identical on every design.** The bypass path is not the cause. The cause is that the commercial DEF,
as iEDA reads it, is not a legal placement - its cells are not on iEDA's site grid - and the evaluator
charges that illegality as congestion. The anchor's raw_metrics docstring says as much: "no legalization
gate".

**So the old standing compared our legal placement against an illegal one.** That is not a like-for-like
comparison, and the error is in our favour: it makes the reference look worse than it is.

## 3. The corrected standing

Both sides legalised by the same procedure, same seed, current source:

| design | PDK | old hpwl | old union | old max | **new hpwl** | **new union** | **new max** | verdict |
|---|---|---|---|---|---|---|---|---|
| apb4_timer | sky130 | 0.87 | 0.34 | 0.62 | 0.87 | **0.93** | **1.00** | ALL |
| s1238_ics55_a | ics55 | 0.83 | 0.46 | 0.43 | 0.83 | **0.52** | **0.43** | ALL |
| gcd_nangate45_a | nangate45 | 0.90 | - | - | 0.89 | - | - | ALL |
| s1238_nangate45_a | nangate45 | 0.75 | - | - | 0.75 | - | - | ALL |
| salsa20_ics55_a | ics55 | 0.95 | 0.77 | 1.26 | 0.94 | 0.79 | 1.23 | fail: max |
| s1238 | sky130 | 0.76 | 0.48 | 1.33 | 0.76 | **1.15** | 1.43 | fail: union, max |
| s38584_nangate45_a | nangate45 | 0.96 | 0.50 | 0.50 | 0.96 | **1.50** | 1.00 | fail: union |
| picorv32 | sky130 | 0.81 | 0.72 | 1.45 | 0.81 | **1.45** | 1.61 | fail: union, max |
| aes | sky130 | 0.73 | 0.73 | 1.45 | 0.73 | **1.36** | 1.78 | fail: union, max |
| s5378_sky130_b | sky130 | 0.90 | 0.68 | 1.27 | 0.90 | **1.56** | 1.27 | fail: union, max |
| salsa20_nangate45_a | nangate45 | 0.94 | 1.86 | 1.20 | 0.94 | 1.89 | **1.71** | fail: union, max |
| s38584_ics55_a | ics55 | 0.97 | 0.97 | 1.33 | 0.97 | **1.18** | 1.60 | fail: union, max |
| gcd_ics55_a | ics55 | 0.94 | 0.93 | 0.50 | 0.94 | **1.85** | 0.50 | fail: union |
| gcd_sky130_a | sky130 | 1.14 | 1.07 | 1.17 | 1.14 | **2.39** | 1.27 | fail: hpwl, union, max |
| s1238_sky130_a | sky130 | 1.08 | 1.44 | 1.62 | 1.08 | **2.05** | 1.86 | fail: hpwl, union, max |

**Wirelength is unaffected**, because the bypass does not change positions. **Congestion was inflated
against us on every design.**

## 4. What this changes

- **Designs no worse on every measurable dimension: 6 to 4** (apb4_timer, s1238_ics55_a,
  gcd_nangate45_a, s1238_nangate45_a). Previously reported as 6.
- **The three-metric core all better: 4 to 2** (apb4_timer, s1238_ics55_a).
- **Union is not a strength.** It fails on 11 of 13 measurable designs, from 1.15x to 2.39x. Previously
  reported as a median of 0.78 with 8 of 13 no-worse. **That was an artefact.**
- **Peak is worse still**: 12 of 13 fail, from 1.00x to 1.86x.
- The claim that "five designs are blocked by peak congestion alone" is wrong: under the corrected
  protocol most of them fail union as well.

**The only dimension that survives the correction is wirelength**, which loses on 3 of 15 (gcd_sky130_a
1.14, s1238_sky130_a 1.08).

## 5. Why this is the most useful thing this round produced

The earlier rounds were optimising against a target that was inflated in our favour, which is why
several changes looked like wins and then failed under a commit-matched control: the metric itself was
wrong. Every future comparison uses the legalised reference, and the standing table in
rsi/analysis/standing_corrected2.py recomputes it from scratch so the two protocols cannot be confused
again.

The two protocols differ by up to 2.7x, so every congestion number quoted before this round should be
read as belonging to the bypass protocol and not mixed with these.

No source change this round. Tree state unchanged: SR-10 and SR-11 in, SR-2/3/4/5/7/8/9/12 withdrawn.
