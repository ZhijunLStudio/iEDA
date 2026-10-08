# Round 52: three designs, three behaviours, and a gate that separates them - SR-17

## 1. The multi-pass result, complete on three designs

Same batch, same binary, same seed, reference legalised in the same batch:

| design | passes | wirelength | total overflow | peak | direction |
|---|---|---|---|---|---|
| **gcd_ics55_a** | 1 | 0.942 | 2.200 (44) | 0.667 (4) | - |
| | 2 | 0.945 | 1.350 (27) | 1.000 (6) | improving |
| | **3** | 0.943 | **0.800 (16)** | **0.333 (2)** | **passes everything** (ref 20 / 6) |
| **s5378_sky130_b** | 1 | 0.896 | 1.561 (3778) | 1.273 (28) | - |
| | 2 | 0.896 | 1.561 (3778) | 1.273 (28) | **exactly inert** |
| | 3 | 0.896 | 1.562 (3782) | 1.273 (28) | inert |
| **s1238_sky130_a** | 1 | 1.078 | 2.053 (3594) | 1.857 (52) | - |
| | 2 | 1.076 | **2.091 (3662)** | **2.143 (60)** | **worse** |

**Three designs, three behaviours**: one improves monotonically until it passes, one is untouched, one is
damaged by the second pass.

## 2. Why that makes the gate the right change rather than a reason to stop

Every earlier mechanism in this campaign showed the same spread and was abandoned because nothing could
tell the cases apart. **Here something can**: the cases are distinguished by the measurement the gate would
take. A loop that keeps a pass only when a congestion number improved and neither got worse would

- run three passes on gcd_ics55_a and take it from 2.20x to 0.80x,
- run one extra pass on s5378_sky130_b, see no change, and stop where the shipped flow stops,
- run one extra pass on s1238_sky130_a, see both numbers worse, revert it and stop.

**One win, two no-ops, no losses.** That is the shape the SR-11 guard has, applied to a lever that is
worth more.

## 3. SR-17, implemented

In PLAPI, after the shipped LG and DP and after the SR-11 guard: up to three further LG+DP passes, each
one preceded and followed by the in-process congestion measurement SR-10 added; a pass is kept only if
either congestion number improved **and neither worsened**, otherwise the pre-pass instance positions are
restored, the derived managers are refreshed, and the loop stops.

Built as iEDA-sr17, md5 e9d20157a2ca48678a401c416db940d8, against a control rebuilt clean at f9581627 so
the pair differs by exactly this change. The arm table names the control by its saved binary, because
building SR-17 overwrote build/bin/iEDA - the defect that invalidated the SR-13 and SR-14 tests.

## 4. Cost

A pass is legalisation plus detail placement, about 2.9 s each against a 7.4 s global placement, plus the
two congestion measurements SR-11 already pays for. Bounded at three passes, so the worst case roughly
doubles the post-placement time of the flow. That is two orders of magnitude below the congestion-effort
knob and it buys congestion improvement rather than trading between directions.

## 5. What is being measured

SR-17 against the pinned control, one seed, four designs chosen to cover all three behaviours plus one
that was expected to be inert:

- **gcd_ics55_a** - should keep passes and reproduce the 0.80 total overflow;
- **s5378_sky130_b** - should discard its first extra pass and end where the control ends;
- **s1238_sky130_a** - should discard its extra pass and end where the control ends;
- **salsa20_ics55_a** - a design whose peak fails while its total passes; the gate is symmetric so it
  should be unaffected unless the extra passes help it.

The prediction is specific enough to be wrong: if SR-17 improves a design it should not, or fails to keep
the gain on gcd_ics55_a, that will be reported as a refutation.

## 6. State

- **In the tree pending measurement**: SR-17. SR-10 and SR-11 remain.
- **Withdrawn with reasons**: SR-2/3/4/5/7/8/9/12/13/14/15/16.
- **Standing**: 4 of 15 no worse on every measurable dimension; wirelength fails 2 of 15, total overflow
  8 of 13 on meaningful counts, peak 9 of 13.
