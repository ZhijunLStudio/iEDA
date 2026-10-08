# Round 12: a reference-value error in my own analysis scripts, and the corrected standing

## 1. The error

Several analysis scripts hard-coded the reference EGR values for the valid designs in a small
dictionary instead of reading them from the anchor file. In that dictionary the total overflow for
salsa20_ics55_a was written as 3407, which is **s38584_ics55_a's value**. The true reference for
salsa20_ics55_a is **54296**.

Consequence: Rounds 9, 10 and 11 reported that design as having a total-overflow ratio of
**12.46x**, when the real ratio is **0.78x - we win on it**. Every table in those rounds that
attributed a "salsa20_ics55_a union blowup" was wrong about the reference comparison. The relative
changes within the round (for example, that iterating the pipeline raises union from 40191 to
41434) are unaffected, because both arms of those comparisons came from the same measurement; what
is wrong is the position of any of it against the reference.

This is the third data-integrity error found in this campaign, after the netlist mismatch and the
seed-spread overstatement, and it is the same class: a conclusion resting on a value that was
transcribed rather than read. The fix is the same as the others - read from the authoritative file
in every analysis, which `standing_corrected.py` now does.

## 2. The corrected standing, valid (netlist-matched) designs

| design | pdk | dnets | HPWL | union | peak | WNS | TNS |
|---|---|---|---|---|---|---|---|
| gcd_ics55_a | ics55 | 0 | 0.94 | 0.93 | **0.50** | - | - |
| s1238_ics55_a | ics55 | 0 | 0.80 | **0.73** | **0.86** | - | - |
| s38584_ics55_a | ics55 | 0 | 0.95 | 1.06 | 1.33 | - | - |
| salsa20_ics55_a | ics55 | 0 | 0.95 | **0.78** | 1.35 | - | - |
| s38584_nangate45_a | nangate45 | 0 | 0.94 | 3.50 | 2.00 | - | - |
| salsa20_nangate45_a | nangate45 | 0 | 0.92 | 4.36 | 1.40 | - | - |
| aes | sky130 | 0 | 0.73 | 0.73 | 1.45 | 0.95 | 1.00 |
| apb4_timer | sky130 | 0 | 0.84 | 0.36 | 0.77 | 0.87 | 0.88 |
| gcd_sky130_a | sky130 | -4 | 1.14 | 1.07 | 1.17 | 0.35 | 0.55 |
| picorv32 | sky130 | 0 | 0.80 | 0.75 | 1.85 | 0.99 | 0.95 |
| s1238 | sky130 | 0 | 0.69 | 0.53 | 1.47 | -0.02 | -0.00 |
| s1238_sky130_a | sky130 | -1 | 1.09 | 1.51 | 2.19 | 0.85 | 0.62 |
| s5378_sky130_b | sky130 | -4 | 0.88 | 0.73 | 1.32 | 0.42 | 0.43 |

| dimension | n | median ratio | no worse |
|---|---|---|---|
| HPWL | 13 | 0.923 | 11 / 13 (85%) |
| EGR union | 13 | 0.782 | 8 / 13 (62%) |
| **EGR max** | 13 | **1.353** | **3 / 13 (23%)** |
| setup WNS | 7 | 0.848 | 7 / 7 (100%) |
| setup TNS | 7 | 0.618 | 6 / 7 (86%) |

**Two designs beat the reference on both congestion dimensions at once** (gcd_ics55_a peak 0.50 and
union 0.93; s1238_ics55_a peak 0.86 and union 0.73), and a third wins total overflow while losing the
peak (salsa20_ics55_a). Of the ten designs that lose the peak, **five win total overflow** - aes,
picorv32, s1238, salsa20_ics55_a and s5378.

**The two nangate45 blowups are the sharpest remaining problem**, and they are on netlist-matched
comparisons: salsa20_nangate45_a at 4.36x total overflow and s38584_nangate45_a at 3.50x, both about
four to twenty times worse than anything else in the set and both far outside the seed spread.

## 3. What does not change

The peak deficit is real and unaffected: median 1.353 with 3 of 13 no-worse. The campaign's
localisation of it stands - it is created by detail placement, in its first swap iteration, by
operators that accept moves on wirelength alone; and on the valid set it is concentrated in the two
nangate45 designs and s1238_sky130_a.

## 4. The one lead this round produced

A structural census of what predicts the peak on the valid set found nothing usable: occupancy
overflow sum rho +0.118, net bounding-box sum +0.274, bounding-box p99 +0.015, max-bin ratio +0.259,
gini delta +0.216. **No property computable from a DEF tracks peak congestion**, which is consistent
with the peak being a routing-specific quantity and closes off the cheapest route to a signal.

What the same run did produce is the LG-versus-LG+DP comparison. Across nine seed-pairs on three
netlist-matched designs, **LG alone is better than LG+DP on both congestion dimensions for six of
them, ties on one, and loses only on two seeds of one design.** On s1238_ics55_a the LG placement
beats the reference on both dimensions at all three seeds (peak 10/6/9 against 14, union 93/65/74
against 177), where the shipped flow - which always runs detail placement - loses.

The shipped flow always runs DP because it has no measurement to decide with. The EGR evaluator is
available and costs seconds. **A flow that chose between the two placements on a Pareto rule over
the two congestion metrics would, on this data, take the better one in every case** - and the rule
contains no tuned constant. That is what the next measurement in this round tests.
