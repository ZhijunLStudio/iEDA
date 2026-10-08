# Round 42: SR-13 and SR-14 are not no-ops - the earlier verdicts were an artifact of the broken harness

## 1. What was being re-judged, and why

Round 36 found that gp_agent resolved IEDA_BIN at import time, so every script that set it afterwards ran
the **same binary in both arms**. Two changes had been rejected on those measurements:

- **SR-13** (discard detail placement whenever the peak strictly worsens, instead of only when it worsens
  and the total fails to improve): rejected as "fires on 1 of 6 seed-pairs, effect inside the noise".
- **SR-14** (keep the Nesterov solve alive past step-length stagnation when overflow is still above 1.1x
  target, using the quadratic density penalty): rejected as "identical to the control".

In an A/B that cannot switch binaries, **both verdicts were guaranteed before any run started**. They were
unmeasured, not rejected, and this round measures them.

## 2. First result: the harness switches binaries now, and the changes are real

Comparing the placement files produced by the two arms for the same design and seed:

| test | arm pairs complete | identical | **different** |
|---|---|---|---|
| SR-13 vs control | 2 | 0 | **2** |
| SR-14 vs control | 1 | 0 | **1** |

**Every completed pair differs.** For comparison, in the invalid A/Bs the pairs were byte-identical by
construction. So:

- the arm switching is fixed and demonstrably working;
- **SR-13 changes the placement**;
- **SR-14 changes the placement**.

**Both earlier "no-op" verdicts are retracted.** They described the harness, not the change.

## 3. What this does to the record

- **SR-13** and **SR-14** move from "rejected" to **"in flight"**. They are in the tree as reverted
  binaries (iEDA-sr13 = 1d1a8fd6, iEDA-sr14 = 0c50cc35) and are being measured now: six designs times
  three seeds for SR-13, two designs times three seeds for SR-14, each paired against the current source
  (f9581627) with the reference from the standing rebuild.
- The lesson is the one this campaign keeps relearning in a new guise: **a measurement is only as good as
  the apparatus**, and apparatus defects are invisible in the numbers they produce - they produce
  plausible numbers, in this case two pairs of identical arms which read as "the change does nothing".

## 4. What is not yet claimed

No effect size for either change. The runs cover 60 configurations and eleven placements are done, with
four jobs working through them. When they finish, each pair is scored against the legalised reference from
the same batch, and the verdict will be recorded with the same standard applied to every other change:
multi-seed, paired, same binary pair aside from the change under test.

## 5. The standing is unaffected

The 15-design standing was rebuilt with the fixed harness and reproduces round 28 within 0.02 on every
ratio, so nothing in the baseline depends on the defect. What the defect invalidated was the judgement of
these two source changes, and only those.

## 6. Tree state

Source unchanged: SR-10 and SR-11 in; SR-2/3/4/5/7/8/9/12 withdrawn with recorded reasons; **SR-13 and
SR-14 under re-measurement**. Binary f9581627. Wrappers iEDA-nosshim, iEDA-sr13-nosshim and
iEDA-sr14-nosshim hide the host preload shim so the flow runs at all.
