# Round 56: SR-17's loop ran 62 times where the shipped flow runs once, and the cause is still not pinned

## 1. The decisive count

Counting `Start Detail Placement` per iEDA process across every log this campaign has produced: **the shipped
flow calls detail placement exactly once.** The two SR-17 arms called it **62 and 56 times**, and neither
wrote a single SR-17 decision line. So the extra passes were not the bounded loop the source shows.

The loop body is `for (int32_t pass = 0; pass < 3; pass++)` with breaks in both branches, which cannot
exceed three iterations on its own. The call sites for the stages are:

    PLAPI.cc:347, 616, 633, 731, 751   (runLG/runDP from other entry points)
    PLAPI.cc:2192, 2196                (inside runConvergedFinish)

so the repetition is not a nested call inside runLG as I first suspected - those two lines are inside
`runConvergedFinish`, the dormant SR-6 loop, which SR-17 does not call.

**The cause needs the loop instrumented to find, and the change has to come out of the tree first.** It is
out: the source is exactly reverted and the rebuild reproduces `f9581627`.

## 2. What the count does establish, and it matters for the objective

**The shipped flow runs legalisation and detail placement once each.** That is why the multi-pass lever is
real: there is no converging loop in the shipped path at all, so three passes are genuinely three times the
work rather than a re-run of something already done. It also explains why the effect is large where it
appears: the flow's only legalisation-plus-detail-placement step is being asked to do everything.

## 3. The structure for the right implementation already exists and is dormant

`PLAPI::runConvergedFinish(max_passes, hpwl_rel_tol)` runs LG+DP up to `max_passes` times and stops on a
**wirelength** tolerance. It is the exact shape needed, and the one thing wrong with it is the tolerance:
on gcd_ics55_a the wirelength is flat across the passes (0.9416, 0.9447, 0.9431) while total overflow falls
2.20 to 0.80, so a wirelength-gated loop stops after the first pass and captures none of the benefit.

**The minimal change is to give that existing loop a congestion-based stop** rather than writing a new one -
and unlike SR-17 it is already wired into the API and already bounded by its argument, so it does not
reproduce SR-17's failure mode. That is the next thing to try, with the loop instrumented so a repeat of
this round's surprise would be caught by counting rather than by an hour of wall clock.

## 4. Cost of the round

Both SR-17 arms were killed after about an hour each. The round produced no placement result. What it
produced is the count that rules out the shipped flow having a converging loop, the exact structure to build
on, and the confirmation that the multi-pass effect is not an artefact of the flow already doing it.

## 5. State

- **In the tree**: SR-10 and SR-11. Binary **f9581627**, source clean.
- **Withdrawn with reasons**: SR-2/3/4/5/7/8/9/12/13/14/15/16, **SR-17**.
- **The multi-pass evidence stands**: three passes take gcd_ics55_a from 2.20x the reference's total overflow
  to 0.80x and its peak from 0.67x to 0.33x at no wirelength cost; s5378_sky130_b is inert; s1238_sky130_a
  is damaged by the second pass.
- **Standing**: 4 of 15 designs no worse on every measurable dimension; wirelength fails 2 of 15, total
  overflow 8 of 13 on meaningful counts, peak 9 of 13.
