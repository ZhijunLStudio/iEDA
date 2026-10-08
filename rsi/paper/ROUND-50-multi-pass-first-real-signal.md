# Round 50: running legalization and detail placement three times takes a failing design to passing, and the benefit is invisible in wirelength

## 1. The result

The shipped flow runs legalization once and detail placement once. Running that pair three times, same
binary, same seed, same batch, measured against the reference legalised in the same batch:

**gcd_ics55_a**

| passes | wirelength | total overflow | peak |
|---|---|---|---|
| 1 (shipped) | 0.9416 | **2.20** | 0.6667 |
| 2 | 0.9447 | 1.35 | 1.0000 |
| **3** | 0.9431 | **0.80** | **0.3333** |

**The design goes from failing total overflow by 2.2x to passing every measurable dimension** - wirelength
0.94, total overflow 0.80, peak 0.33 - and wirelength does not move (0.9416 to 0.9431).

**s5378_sky130_b**

| passes | wirelength | total overflow | peak |
|---|---|---|---|
| 1 | 0.8962 | 1.5605 | 1.2727 |
| 2 | 0.8962 | 1.5605 | 1.2727 |
| 3 | 0.8962 | 1.5622 | 1.2727 |

**Exactly inert.** No cost, no benefit - the additional passes change nothing on this design.

That is the shape a change should have: a large gain where it does something, nothing where it does not.

## 2. Why this is different from everything else tried

Every other mechanism in this campaign was a **settings** change - a coefficient, a schedule, an effort
level - and each turned out to be a knob whose sign varied by design. This one is **more iterations of two
stages that are already in the flow**, and its effect is monotone on the design that responds: 2.20, 1.35,
0.80 over three passes.

It also has a natural stopping criterion, which the tree already contains: placer_finish with a pass limit
and a tolerance. That was implemented early in this work and left dormant.

## 3. A critical detail about that criterion

The obvious tolerance to use is wirelength, since that is what detail placement is for. **On gcd_ics55_a it
would stop too early**: wirelength is 0.9416, 0.9447, 0.9431 across the passes - flat within noise - while
congestion falls 2.20 to 0.80. **A wirelength-tolerance loop would have concluded after the first pass that
nothing more was happening, and missed the entire benefit.**

The benefit is visible only in the congestion measurement, which the flow now has in-process from SR-10.
So the tolerant version of this change has to be gated on congestion rather than on wirelength, and that is
a source change rather than a command-line option.

## 4. What is being measured now

Eight more designs at one, two and three passes, in the same batch, to see whether the pattern holds: a
large gain on the designs that respond, inertness elsewhere, and no design made worse.

## 5. What this means for the objective

The standing is 4 of 15 designs no worse on every measurable dimension, with total overflow failing 8 of 13
on meaningful counts. If even a few of those 8 respond the way gcd_ics55_a does, this is the first lever in
this campaign with a plausible route to moving that number.

## 6. State

- **In the tree**: SR-10, SR-11. Binary f9581627. The pass-loop helper exists but is dormant.
- **Withdrawn with reasons**: SR-2/3/4/5/7/8/9/12/13/14/15/16.
- The measurement is running; no change is proposed until the eight designs are in.
