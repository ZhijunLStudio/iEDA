# Round 83: SR-26 supersedes SR-25 - same primary, two more cells, strict head-to-head win

## 1. The decision

SR-26 (segment cap raised from 2 to 6, plus a stop after two consecutive non-improving segments) is
accepted as the tree's configuration. It is measured against SR-25 head-to-head on the cells both
measured, with every arm at the same co-run pattern:

| arm | primary (every seed) | secondary (of 60) | gains vs the matched current tree | regressions |
|---|---|---|---|---|
| current tree | 2/15 | 17/60 | - | - |
| SR-25 (cap 2) | 4/15 | 24/60 | 7 | 0 |
| **SR-26 (cap 6 + stagnation stop)** | **4/15** | **26/60** | **9** | **0** |

Head-to-head on the **58 cells measured in both**:

    SR-25 24 passes   SR-26 26 passes
    SR-26 wins 2, loses 0, ties 56

    s1238_sky130_a@1000   sr25 (1759, 28) -> sr26 (1488, 20)
    s38584_ics55_a@1002   sr25 (2513, 16) -> sr26 (2577, 14)

Both wins are cases the two-segment budget left failing, including **the cell round 82 identified as
failing by a single overflow bin**: SR-26 takes s38584_ics55_a's peak from 16 to 14 against a reference
of 15. So the extra segments do buy something; they buy cells, not a new all-seed design.

**Acceptance rule satisfied**: relative to the matched current tree, the pass count rises (2/15 -> 4/15,
17/60 -> 26/60) and no currently passing design is turned into a failing one (0 regressions). Relative to
SR-25 it is a strict improvement on the measured cells.

The tree is set to SR-26 and the rebuild reproduces the measured binary exactly:

    build/bin/iEDA       f6f811931b470ee68e05767bb1528446
    build/bin/iEDA-sr26  f6f811931b470ee68e05767bb1528446

## 2. What was established along the way, including a wrong expectation

Round 81 predicted that SR-26's superset segment set should be at least as good as SR-25's under the
gate's ordering. Round 82 reported cell values differing by more than expected and called the argument
defeated. **The full table shows the prediction was right in outcome but for a different reason than the
argument claimed**: SR-26 does dominate, by two cells, but its early segments do **not** reproduce SR-25's
early segments (same binary, same design, same seed, ~2% cell movement between runs). So the dominance is
a fact about the measurement, not a consequence of set inclusion, and the run-to-run residual is large
enough to matter at one-bin margins even though it does not change this decision.

## 3. Full table (per design, per seed set)

| design | current tree | SR-25 | **SR-26** |
|---|---|---|---|
| gcd_nangate45_a | PPPP 4/4 | PPPP 4/4 | PPPP 4/4 |
| s1238_ics55_a | PPPP 4/4 | PPPP 4/4 | PPPP 4/4 |
| s1238_nangate45_a | PPP. 3/4 | PPPP 4/4 | PPPP 4/4 |
| salsa20_ics55_a | .PPP 3/4 | PPPP 4/4 | PPPP 4/4 |
| gcd_sky130_a | .P.. 1/4 | PPP. 3/4 | PPP. 3/4 |
| apb4_timer | P... 1/4 | P.P. 2/4 | P.P. 2/4 |
| s38584_ics55_a | .... 0/4 | .P.. 1/4 | **.PP. 2/4** |
| s38584_nangate45_a | .... 0/4 | P... 1/4 | P... 1/4 |
| s1238_sky130_a | .... 0/4 | .... 0/4 | **P... 1/4** |
| gcd_ics55_a | P... 1/4 | P... 1/4 | P... 1/4 |
| aes, picorv32, s1238, s5378_sky130_b, salsa20_nangate45_a | 0/4 | 0/4 | 0/4 |

## 4. What remains

- **Primary is 4/15; the objective wants 15/15** and every design no worse on every measurable dimension.
- **Eleven designs are not all-seed passes.** Five never pass on any seed (aes, picorv32, s1238,
  s5378_sky130_b, salsa20_nangate45_a) and fail by 1.15x-2.0x, not by bins - they need a different
  mechanism rather than more of this one.
- **gcd_sky130_a is one seed short** (PPP.) and **s38584_ics55_a is two seeds short** (.PP.). These are
  the closest to moving the primary count.
- **Cost**: SR-26 allows up to six segments and each is a global-placement re-linearisation plus
  legalisation plus detail placement. It stops early on designs it cannot help (aes rejects and stops),
  but on the designs it does help this is the most expensive configuration measured, and cost is now the
  largest practical objection.

## 5. State

- **Tree**: SR-26, binary `f6f81193`.
- **Evidence**: `runs/seedcells_cur4` (matched current tree), `runs/seedcells_sr25`, `runs/seedcells_sr26`
  (60/60); all copied to `rsi/analysis/out/`. Comparison scripts: `rsi/harness/sr25_verdict.py`,
  plus the three-arm and head-to-head comparisons.
- **Candidates not in the tree**: `iEDA-sr23`, `iEDA-sr24` (withdrawn with measured reasons).
