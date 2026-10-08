# Round 51: the multi-pass signal holds on the design it helps, and the full sweep is still running

## 1. What is measured so far

Same batch, same binary, same seed, reference legalised in the same batch:

| design | passes | wirelength | total overflow | peak |
|---|---|---|---|---|
| **gcd_ics55_a** | 1 | 0.9416 | **2.20** | 0.6667 |
| | 2 | 0.9447 | 1.35 | 1.0000 |
| | **3** | 0.9431 | **0.80** | **0.3333** |
| **s5378_sky130_b** | 1 | 0.8962 | 1.5605 | 1.2727 |
| | 2 | 0.8962 | 1.5605 | 1.2727 |
| | 3 | 0.8962 | 1.5622 | 1.2727 |
| **picorv32** | 1 | 0.808 | 1.453 | 1.611 |

**gcd_ics55_a is monotone across the passes on congestion and flat on wirelength**; s5378_sky130_b is
inert; picorv32's first pass reproduces the standing exactly, which is the internal consistency check.

Nine of the fifteen designs are running at one, two and three passes and five more have started; only the
two complete ones and picorv32's first pass are scored, because a trial-route evaluation takes minutes on
the large designs and the scoring cannot keep up with eight concurrent runs inside one round.

## 2. Why this is worth pursuing rather than discarding

Every other mechanism tried in this campaign was a setting and every one turned out to be a knob with a
varying sign. This is **more iterations of two stages already in the flow**, and on the one design it
affects it is monotone. It also has a natural safety shape: on s5378_sky130_b it does nothing at all, so
there is no cost to carrying it where it does not help.

## 3. The implementation is identified, and it is small

PLAPI already exposes the pieces:

- runLG and runDP, individually callable;
- runConvergedFinish with a pass limit and a wirelength tolerance, declared and referenced once - a
  dormant loop over exactly these stages;
- SR-10's notifyPLCongestionInfo, which measures total and peak overflow in process.

**The change is to make that loop's continuation test the congestion measurement rather than the
wirelength tolerance.** On the design where the lever works, wirelength is flat across the passes
(0.9416, 0.9447, 0.9431) while congestion falls 2.20 to 0.80, so a wirelength-gated loop stops after the
first pass and captures none of it. The gate has to be: continue while either congestion number improves,
stop when neither does.

**That is a source change and it is not made this round**, because the evidence for it rests on one design
plus one inert control, and this campaign's own rule is that a change is proposed on a multi-design,
multi-seed measurement. The sweep is running to supply exactly that.

## 4. Cost, which is on the right side for once

A pass is legalisation plus detail placement, measured earlier at about 2.9 s each against a 7.4 s global
placement. Three passes therefore roughly double the post-placement time of the flow. That is far below the
congestion-effort knob's tens of minutes per design, and it is the price of a change that improves
congestion rather than only trading between directions.

## 5. State

- **In the tree**: SR-10, SR-11. Binary f9581627.
- **Withdrawn with reasons**: SR-2/3/4/5/7/8/9/12/13/14/15/16.
- **Standing**: 4 of 15 no worse on every measurable dimension; wirelength fails 2 of 15, total overflow
  8 of 13 on meaningful counts, peak 9 of 13.
- **Next**: finish the sweep, then implement the congestion-gated pass loop and measure it the same way.
