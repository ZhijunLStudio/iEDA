# Round 63: SR-21 across three designs - one large win, two no-regressions

## 1. The three results

Scored against the reference legalised in the same batch, seed 1000:

| design | shipped / standing | **SR-21** | outcome |
|---|---|---|---|
| **gcd_ics55_a** | union **1.85**, peak 0.50 | union **0.80**, peak **0.3333** | **failing to passing** |
| s5378_sky130_b | union 1.5597 (3776), peak 1.2727 (28) | union **1.5399 (3728)**, peak 1.2727 (28) | marginally better, no regression |
| s1238_sky130_a | union 2.0525 (3594), peak 1.8571 (52) | **identical (3594 / 52)** | refused the damaging pass |

**Three designs, three correct behaviours.** On the design where the lever works it takes a failure to a
pass; on the design whose extra passes change nothing it leaves the result essentially where it was and
improves the total overflow slightly; on the design whose second pass damages both numbers it ends exactly
where the shipped flow ends, because the best pass was the first one.

The s1238_sky130_a result is the strongest single piece of evidence for the gate working: **3694 -> 3594 is
the pass it refused**, and the placement it produced is byte-identical to the shipped flow's.

## 2. Why this is the first result of its kind here

Eleven changes were withdrawn before this one. The four immediately preceding it - SR-15, SR-17, SR-18,
SR-19 - each failed on a different property: an ill-placed continue, an unbounded loop, and twice a placement
inside a function the flow never calls. **SR-21 executes on the command path, is bounded by its argument,
logs every pass, and now has a measured effect.**

The other eleven were settings knobs whose sign varied by design. This is more iterations of two stages the
flow already runs, gated by a measurement the flow already makes, and it has now been shown to help where
help is available and to do nothing where it is not.

## 3. What is still not established

- **One seed.** Three seeds, paired, is the campaign's own rule and the next step.
- **Three designs of fifteen.** The designs failing on peak while passing on total - aes at 1.61, picorv32 at
  1.61, s38584_ics55_a at 1.60, salsa20_ics55_a at 1.14 - are the natural targets, since SR-21 moved a peak
  from 0.50 to 0.33 on gcd_ics55_a. Whether the same lever reaches them is a measurement, not an assumption.
- **The cost.** Two extra passes is two legalisations, two detail placements and three trial-route
  evaluations, about twelve minutes on these designs. On s1238_sky130_a and s5378_sky130_b the loop stopped
  after one extra pass, so the cost there is roughly one pass.

## 4. Coverage, provisionally

gcd_ics55_a becomes a fifth design no worse on every measurable dimension if this holds, taking the count
from 4 of 15 to 5. That is a change in the objective's headline number produced by a source change for the
first time in this campaign.

## 5. State

- **In the tree pending multi-seed confirmation**: SR-21, with SR-10 and SR-11.
- **Withdrawn with reasons**: SR-2/3/4/5/7/8/9/12/13/14/15/16, SR-17, SR-18, SR-19, SR-20's per-step gate
  (replaced by SR-21).
- **Standing**: 4 of 15 designs no worse on every measurable dimension; wirelength fails 2 of 15, total
  overflow 8 of 13 on meaningful counts, peak 9 of 13.
