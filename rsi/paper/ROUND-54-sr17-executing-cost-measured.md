# Round 54: SR-17 is executing, and its cost is now measured rather than estimated

## 1. What the logs show

SR-17's arms have been running about fifty minutes. Reading global placement's own log for one of them,
the sequence is exactly the designed one:

    [SR-11] detail placement kept: peak 50 -> 56, total overflow 3835 -> 3676
    -----------------Start Legalization-----------------
    -----------------Finish Legalization-----------------   (Total Movement: 0)
    -----------------Start Detail Placement-----------------

and on the other arm, at 08:16 and again at 08:22:

    [SR-11] detail placement reverted: peak 4 -> 8, total 40 -> 58

**So the extra passes are running.** Two things came out of reading the log that are worth recording.

## 2. The cost, measured

**One extra pass takes about six minutes** on these designs - the two timestamps of the same decision
message are 6 minutes apart - and that time is dominated by the two trial-route evaluations the gate takes
around each pass, which come to roughly 2.5 minutes each here.

With up to three extra passes that is **up to eight trial-route evaluations per design**, so on a design
that improves all the way the gate adds roughly twenty minutes, against a control arm that finishes in
about ten. **Roughly three times the post-placement time, not the two orders of magnitude I claimed in
round 52.** Round 53 corrected that claim; this round puts a number on it.

## 3. A mechanism detail that came out of the log

**Calling runDP() inside SR-17 re-runs the SR-11 guard**, because the guard lives in runDP(). So each
extra pass is itself guarded: a pass whose detail placement worsens the peak is reverted inside runDP and
again by SR-17's own measurement. That is benign - the two guards agree, and the second only sees a
placement the first already accepted - but it means the extra passes are not bare LG+DP. It is recorded
because it was not obvious from the source and it affects how the cost and the effect should be read.

## 4. The determination is still pending

No SR-17 decision line has been written yet and no SR-17 placement file exists, so the four-design
prediction from round 52 is untested. The runs are in the extra-pass phase and spending CPU.

**I am not going to keep polling this inside one round.** It is a long measurement, the state is
understood, and the next round's first action is to read the four decisions and score them.

## 5. What this says about the change

The mechanism remains the best lever this campaign has found - the multi-pass evidence is unambiguous and
its three behaviours are distinguishable by the gate. But it now has a measured price of roughly 3x the
post-placement time on a design that uses all three passes, and the price is paid in trial-route
evaluations, which is the same resource every expensive mechanism here has cost.

Two consequences stand:

1. **A cheaper gate is the thing to look for**, and the log suggests where: if an extra pass changes
   nothing, the legalisation reports "Total Movement: 0" - so a do-nothing pass is detectable without any
   evaluation at all. That catches the inert case (s5378_sky130_b, and the s1238_sky130_a arm above, whose
   extra legalisation moved nothing) at zero cost. It does not catch the third case, where a pass does
   something and makes congestion worse, which is what the evaluation is still needed for.
2. Any claim about SR-17 must carry the measured cost, and its adoption would be a deliberate trade rather
   than a free improvement.

## 6. State

- **In the tree pending measurement**: SR-17. SR-10 and SR-11 remain.
- **Withdrawn with reasons**: SR-2/3/4/5/7/8/9/12/13/14/15/16.
- **Standing**: 4 of 15 no worse on every measurable dimension; wirelength fails 2 of 15, total overflow
  8 of 13 on meaningful counts, peak 9 of 13.
