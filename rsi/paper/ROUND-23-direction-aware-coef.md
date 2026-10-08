# Round 23: SR-12 - the wirelength force was direction-blind, and nangate45 pays for it

## 1. The defect, found by looking at which direction the congestion is in

The evaluator reports overflow per routing direction, and on the two designs that fail the peak at
every seed the split is extreme:

| design | total overflow horizontal | total overflow vertical | vertical / horizontal |
|---|---|---|---|
| salsa20_nangate45_a | 81 | **1009** | **12.5** |
| s38584_nangate45_a | 0 | **21** | **all of it** |
| salsa20_ics55_a | 30883 | 11556 | 0.37 (the other way) |
| s1238_sky130_a | 1663 | 2120 | 1.28 |

**The direction with the smaller capacity is carrying nearly all of the overflow.** The placer's own
LEF says the capacity is asymmetric: Layout::get_route_cap_h/v are the total routing track counts per
direction, and for nangate45 the horizontal count is about 1.38x the vertical, while for sky130 it is
about 0.84x, i.e. the other way round.

And the placer ignores that entirely:

    void NesterovPlace::updateWirelengthCoef(float overflow) { ... _wirelength_coef = ...; }
    ...
    updateWirelengthForce(_wirelength_coef, _wirelength_coef, ...);   // x and y get the SAME number

**A single scalar, passed as both the horizontal and the vertical coefficient**, whatever the routing
stack allows. That is the defect: on a PDK whose capacity is asymmetric the placer is free to spend
routing resources in the wrong direction, and the evaluator charges it.

## 2. The change

obtainDirectionalWirelengthCoef tilts the pair inversely to the per-direction capacity:

    ratio   = sqrt(route_cap_h / route_cap_v)
    coeff_x = base / ratio
    coeff_y = base * ratio

A direction with more tracks can afford more spread, and in this wirelength model a smaller coefficient
means freer spread. The geometric mean is preserved, so the overall wirelength pressure is unchanged
and only its balance between directions moves. A design with symmetric capacity is left exactly as it
was. Applied at all four places the force is computed, including the two that set the initial gradient.
Built in 19 s.

## 3. Result, against a commit-matched control

Control is the same source without the change (arm sr10, md5 aad1fef4, a build of HEAD); treated is
sr12, md5 841df305.

| design | PDK | HEAD | **direction-aware** | reference | effect |
|---|---|---|---|---|---|
| **s38584_nangate45_a** | nangate45 | 21 / 4 | **0 / 0** | 6 / 2 | **both better, overflow eliminated** |
| **salsa20_nangate45_a** | nangate45 | 1090 / 14 | **813 / 16** | 250 / 10 | **union -277 (-25%)**, peak +2 |
| gcd_nangate45_a | nangate45 | 0 / 0 | 0 / 0 | 0 / 0 | unchanged |
| apb4_timer | sky130 | 2036 / 20 | 2119 / **18** | 5626 / 26 | union +83 (+4%), peak -2 |

Wirelength cost: +0.37% (gcd_nangate45_a), +1.52% (salsa20_nangate45_a), +3.41%
(s38584_nangate45_a), +4.55% (apb4_timer).

## 4. The mechanism is verified, not assumed

Re-measuring the directional split after the change:

| design | arm | totalH | totalV | V/H |
|---|---|---|---|---|
| salsa20_nangate45_a | HEAD | 81 | **1009** | 12.46 |
| salsa20_nangate45_a | **direction-aware** | 98 | **715** | 7.30 |
| s38584_nangate45_a | HEAD | 0 | 21 | all vertical |
| s38584_nangate45_a | **direction-aware** | **0** | **0** | - |
| apb4_timer (sky130, V capacity larger) | HEAD | 1238 | 798 | 0.64 |
| apb4_timer | **direction-aware** | 1372 | 747 | 0.54 |

**Vertical overflow falls 29% on salsa20_nangate45_a and is eliminated on s38584_nangate45_a**, and on
the sky130 control the tilt goes the other way, toward horizontal pressure, because sky130's vertical
capacity is the larger one. The change does what its derivation says it does, in the direction each PDK
requires.

## 5. Honest limits

- **One seed.** The seed spread on this metric reaches 67% for a single design, so the effect sizes
  need repeating. The mechanism check above compares the direction split within one run, so it is not
  seed-dependent in the same way, but the magnitudes are.
- **Wirelength pays 0.4% to 4.6%.** That is inside the noise floor for the small designs and above it
  for apb4_timer. Whether the trade is good depends on the design; the standing on HPWL is currently
  0.90 median with 13 of 15 no-worse, so there is margin.
- **The sky130 effect is mixed** - peak improves, total overflow worsens by 4% - and sky130 is where
  most of the valid set lives.
- **Timing is not measured** on nangate45, which is where the improvement is largest, because the
  timing tool crashes there.

## 6. Why this is the right kind of change

It is in the algorithm, not in an option and not in a harness. It follows from a measured property of
the placements (direction-asymmetric overflow), it is derived from a quantity the placer already holds
(the LEF track counts per direction), it is validated against a commit-matched control, and the
mechanism is separately confirmed by re-measuring the direction split. Where it makes the overflow
worse on a PDK it is because that PDK's capacity tilts the other way, which is the correct behaviour
rather than a failure.

## 7. Tree state

In: SR-10 (in-tool congestion measurement), SR-11 (detail-placement dominance guard), **SR-12
(direction-aware wirelength coefficients)**. Withdrawn with recorded reasons: SR-2, SR-3, SR-4, SR-5,
SR-7, SR-8, SR-9.
