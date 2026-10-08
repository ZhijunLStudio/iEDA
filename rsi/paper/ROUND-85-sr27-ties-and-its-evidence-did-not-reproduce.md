# Round 85: SR-27 measured - a principled gate that ties, so the tree goes back to SR-26

## 1. What SR-27 was

The segment chooser ranked peak above total and accepted any segment that improved the peak, so it could
return a placement worse on the total than the one it started from. SR-27 restricted eligibility: a
segment may be the final answer only if it is no worse than the **entry** state on either scored number
and better on at least one. Ineligible segments are still executed and still become the state the next
segment starts from, so the non-monotone traversal is preserved.

Built as `iEDA-sr27 = 0543fdbb`, validated over the same 60 cells.

## 2. The result: a tie

| arm | primary (every seed) | secondary | gains vs matched cur | regressions |
|---|---|---|---|---|
| matched current tree | 2/15 | 17/60 | - | - |
| SR-25 | 4/15 | 24/60 | 7 | 0 |
| SR-26 | 4/15 | **26/60** | 9 | 0 |
| **SR-27** | 4/15 | 26/58 (59 cells) | 9 | 0 |

SR-27 has the same primary count, the same number of gains, and zero regressions. It differs only in
*which* seed of s1238_sky130_a passes (s1003 instead of s1000). **It does not raise the objective's
count, so under the acceptance rule it is not an improvement.**

**The tree is restored to SR-26**, the configuration with the complete 60/60 validation, and the rebuild
reproduces it byte for byte:

    build/bin/iEDA       f6f811931b470ee68e05767bb1528446
    build/bin/iEDA-sr26  f6f811931b470ee68e05767bb1528446

SR-27 is kept as a saved candidate (`0543fdbb`) and its 59 records are in `rsi/analysis/out/`.

## 3. The round-84 single-cell evidence did not reproduce - and that is the round's real finding

Round 84 reported that SR-27 turned gcd_sky130_a seed 1003 from 1004/19 into **747/14, a pass**, and
called that evidence the gate was doing what it was designed to do. **In the validation the same binary,
design and seed returned 952/19, a failure.**

The cell across every arm measured:

| arm | union | peak | verdict |
|---|---|---|---|
| current tree | 911 | 18 | fail (union, by 1.2%) |
| SR-25 | 945 | 16 | fail |
| SR-26 | 1004 | 19 | fail |
| SR-27 (single-cell check) | **747** | **14** | pass |
| SR-27 (validation) | 952 | 19 | fail |

**A cell whose value ranges over 747-1004 and 14-19 between runs cannot discriminate anything**, and I
used one sample of it as evidence in the previous round. That was the same mistake the campaign has rules
against: reading a single observation as a property. The correct use of that cell is as a *symptom* that
motivated a change, which it was; it should never have been presented as confirmation.

## 4. A second correction to the round-84 claim

Round 84 said the gate makes the refinement "unable to worsen a placement on either scored number". That
guarantee holds for the **tool's own in-process measurement** (`egr_mof`/`egr_tof`), which is what the
gate reads. It does **not** transfer to the ruler's numbers, which come from a different instrument
(`run_congestion_eval`, fixed 64x64, reading the EGR maps). The validation shows exactly that: SR-27's
final DEF scored 952/19 against the ruler while its entry scored 911/18, because "no worse than entry"
was true of the tool's measurement and false of the scored one. The claim is narrowed accordingly.

## 5. Recorded for the next attempt

- The gate change is principled and safe, and it is **not** an improvement at this resolution. It is
  available as a candidate if a later change makes the near-miss cells stable enough to matter.
- **gcd_sky130_a seed 1003 is unstable across arms and runs and should not be used to justify anything**,
  in either direction.
- The per-segment log line is missing the eligibility annotation (one edit did not apply to the build);
  the entry line plus "best is segment 0" is still sufficient to audit each decision. Not worth a rebuild
  that would invalidate a running validation.
- **The interval between runs of the same binary at a single cell is now large enough to flip verdicts**
  (747 vs 952 on one cell). Every acceptance decision in this campaign has been made on cells with that
  property, which is why every one has used multi-seed aggregates and matched patterns rather than single
  cells. That remains the right protocol; the new information is the size of the interval.

## 6. State

- **Tree**: SR-26, binary `f6f81193`, the configuration validated at primary **4/15** and secondary
  **26/60** with 9 gains and 0 regressions against the matched current tree (2/15, 17/60).
- **Candidates not in the tree**: `iEDA-sr23`, `iEDA-sr24` (withdrawn), `iEDA-sr27` (tie, this round).
- **Validation**: SR-27 at 59/60 cells under its flock wrapper; no other sweep running.
- **Objective**: 4/15 against a target of 15/15. Five designs never pass and fail by 1.15x-2.0x, which
  needs a different mechanism rather than more refinement; gcd_sky130_a is one seed short and
  s38584_ics55_a two.
