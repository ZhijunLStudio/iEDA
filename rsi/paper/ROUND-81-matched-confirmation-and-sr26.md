# Round 81: the matched-pattern confirmation, and SR-26 (let the refinement converge)

## 1. Round 80's main caveat is resolved

Round 80's acceptance comparison had the two columns measured under different co-run patterns (4-6 flows
in flight for the current tree, 4 for SR-25). Round 76 showed the pattern moves a cell by 1-2 overflow
bins, so that caveat mattered. It is now closed two ways:

1. **The current tree re-measured at exactly 4 flows** (`runs/seedcells_cur4`, 60 cells): **52 of 52
   comparable cells are identical** to the round-74 values, so 4 versus 6 flows does not move these cells.
2. **The fully matched comparison** (both arms at 4 flows):

| design | current tree | SR-25 | change |
|---|---|---|---|
| gcd_nangate45_a | PPPP 4/4 | PPPP 4/4 | - |
| s1238_ics55_a | PPPP 4/4 | PPPP 4/4 | - |
| s1238_nangate45_a | PPP. 3/4 | PPPP 4/4 | 3->4 |
| salsa20_ics55_a | .PPP 3/4 | PPPP 4/4 | 3->4 |
| gcd_sky130_a | .P.. 1/4 | PPP. 3/4 | 1->3 |
| apb4_timer | P... 1/4 | P.P. 2/4 | 1->2 |
| s38584_ics55_a | .... 0/4 | .P.. 1/4 | 0->1 |
| s38584_nangate45_a | .... 0/4 | P... 1/4 | 0->1 |
| gcd_ics55_a, aes, picorv32, s1238, s1238_sky130_a, s5378_sky130_b, salsa20_nangate45_a | unchanged | | |

        primary (every seed)   current 2/15  ->  SR-25 4/15
        secondary (of 60)      current 17/60 ->  SR-25 24/60
        gains 7    regressions 0

**The acceptance claim stands on matched measurements.** SR-25 is the first change in this campaign that
raises the pass count without turning any passing design into a failing one, on an instrument that repeats
and with both arms measured in one pattern.

## 2. What the per-cell detail says about where SR-25 still loses

The gate accepts a segment that improves the peak, and several near-misses show that ordering costing the
other dimension when the *union* is the binding one at that cell:

| design | seed | entry (current) | SR-25 | outcome |
|---|---|---|---|---|
| gcd_sky130_a | 1003 | 911 / 18 (union is the only failure) | **945 / 16** | peak 18 -> 16 but union 911 -> 945, still fails, now worse on union |
| apb4_timer | 1001 | 2131 / 20 | 2121 / 22 | still fails both |
| apb4_timer | 1003 | 1814 / 19 (union would pass, peak fails) | 2137 / 16 | peak 19 -> 16 but union 1814 -> 2137 |
| s38584_ics55_a | 1000 | 3244 / 24 | 2600 / 18 | both much better, still 3 bins of peak short |
| s38584_ics55_a | 1002 | 2858 / 22 | 2513 / 16 | **one bin of peak short** (16 vs 15) |

Two observations that bound what is left:
- **`s38584_ics55_a` seed 1002 fails by a single overflow bin** on the peak.
- **The peak-first acceptance order trades union for peak**, and at least two cells would pass if the trade
  went the other way (apb4_timer 1003, gcd_sky130_a 1003). The tool cannot know which dimension is binding
  because it does not have the reference, so this is a structural limitation of the gate, not a bug.

## 3. SR-26: let the refinement converge instead of stopping after a fixed two segments

The two-segment budget left several designs one seed short. **SR-26** raises the cap to 6 and adds a
stagnation stop: the loop ends after **two consecutive segments that do not improve the best**. A
non-improving segment is still *not discarded* - the next segment starts from it, which is what allows the
non-monotone path - but a design the mechanism cannot help now stops early rather than paying for the whole
budget. This is an algorithmic stopping rule applied uniformly to every design, not a per-design choice.

Built as **iEDA-sr26 = f6f81193**. Validation over the same 60 cells is running under an flock wrapper
(`rsi/harness/run_sr26_validation.sh`).

## 4. State

- **Tree**: SR-26 in place (cap 6, stagnation stop); SR-25 remains in the tree as the change validated in
  round 80 and is what `iEDA-sr25` is.
- **Evidence**: `runs/seedcells_cur4` (the matched current-tree column), `runs/seedcells_sr25`,
  `runs/seedcells_sr26` (running); all copied to `rsi/analysis/out/` as they complete.
- **Acceptance to beat**: primary 4/15, secondary 24/60, with the current tree at 2/15 and 17/60.

## 5. Next

1. Read the SR-26 validation; if it raises the primary count with no regression, keep it, otherwise revert
   with the measured reason.
2. Reduce the cost, which is now the largest remaining practical objection: each segment is a
   global-placement re-linearisation plus legalisation plus detail placement, and up to six of them.
3. Attack the remaining never-passing designs, which are 1.15x-2.0x away rather than bins away.
