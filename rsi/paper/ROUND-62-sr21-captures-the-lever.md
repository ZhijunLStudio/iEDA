# Round 62: SR-21 captures the lever - a failing design becomes a passing one, with the loop bounded and self-guarding

## 1. The change

SR-21 replaces the per-step gate with a best-result tracker. It runs up to two extra legalise-plus-detail-
placement passes, records the whole placement state and both congestion numbers after each, and at the end
returns to whichever pass was best. **Best is peak first and total second** - the same dominance order the
standing uses - because the peak is the dimension the objective is losing on. Nothing is undone during the
loop; a pass that makes things worse simply does not become the best.

This follows directly from round 61's finding that the trajectory is non-monotone: the shipped pass leaves
peak 3 / total 37, the second leaves peak 6 / total 27, the third leaves peak 2 / total 16. The peak drops
and then rises. A rule that demands monotone improvement refuses the second pass and never reaches the
third; a rule that remembers the best traverses it.

## 2. It works, and the log shows it working

    [SR-21] pass 1/2: peak 6 total 27 | best is pass 0 at peak 3 total 37
    [SR-21] pass 2/2: peak 2 total 16 | best is pass 2 at peak 2 total 16 (this pass is the new best)
    [SR-21] last pass was the best: peak 2 total 16
    Start Detail Placement calls: 3      (shipped once plus exactly two extra - bounded as designed)
    rc 0, placement written

**It kept the worsening pass as a candidate without adopting it, continued, and ended on the best.** That is
the behaviour three earlier attempts could not produce.

## 3. The measured effect on a failing design

gcd_ics55_a, scored against the reference legalised in the same batch:

| | wirelength | total overflow | peak |
|---|---|---|---|
| shipped / standing | 0.9442 | **1.85 (failing)** | 0.50 |
| **SR-21** | 0.9431 | **0.80 (passing)** | **0.3333** |

**The design goes from failing total overflow by 1.85x to passing at 0.80x, with the peak also improving
from 0.50 to 0.33 and wirelength unchanged.** Under the objective's definition - every measurable dimension
at or below 1.00 - gcd_ics55_a moves from a failure to a clean pass.

This is the first source change in this campaign that is bounded, self-guarding, executes where the flow
runs it, and produces a real improvement on a design that was failing. Ten previous attempts were withdrawn,
and the four immediately preceding this one failed on placement rather than on idea.

## 4. What the round has not yet established

- **One seed, one design.** The measurement is a single run at seed 1000. The campaign's own rule is three
  seeds, paired, and that is the next step.
- **The two control designs are running**: s5378_sky130_b, where the extra passes change nothing and SR-21
  should end where the shipped flow ends - its first extra pass should fail the 'changed neither number'
  test and stop the loop; and s1238_sky130_a, where the second pass made both numbers worse and SR-21
  should keep the shipped pass and end there.
- **Cost is unchanged and real**: two extra passes is two legalisations, two detail placements and three
  trial-route evaluations, about twelve minutes on these designs. On a design whose first extra pass changes
  nothing, SR-21 pays for one pass and stops.

## 5. Coverage, provisionally

Four valid designs were no worse on every measurable dimension before this. If gcd_ics55_a holds at other
seeds it becomes the fifth, and the two designs still ahead of it - the ones failing on peak while passing
on total - are the natural next targets, since the same lever moved a peak from 0.50 to 0.33 here.

## 6. State

- **In the tree pending its multi-seed measurement**: SR-21, with SR-10 and SR-11.
- **Withdrawn with reasons**: SR-2/3/4/5/7/8/9/12/13/14/15/16, SR-17, SR-18, SR-19, and SR-20's per-step gate
  (kept as SR-21's predecessor and replaced by it).
- **Standing**: 4 of 15 designs no worse on every measurable dimension; wirelength fails 2 of 15, total
  overflow 8 of 13 on meaningful counts, peak 9 of 13.
