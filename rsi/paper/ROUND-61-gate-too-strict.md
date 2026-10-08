# Round 61: the gate is too strict, and the trajectory shows why

## 1. The path difference was not the cause

SR-20b added the command path's database re-synchronisation (`updatePlacerDB` before each stage,
`writeBackSourceDataBase` after) around SR-20's extra passes, so they would be the same passes the multi-pass
evidence measured. It built (md5 46fcc84c) and ran on gcd_ics55_a:

    [SR-20] extra pass 1/2: peak 3 -> 6, total 37 -> 27 (undone)

**Identical to SR-20 without the re-sync.** So the path difference was real but immaterial, and the refusal
is not an artefact of it. The re-sync stays because it makes the passes equivalent to the measured ones.

## 2. The trajectory is non-monotone, and that is the whole finding

Putting the gate's measurement next to the ungated command-path evidence for the same design:

| pass | peak | total overflow |
|---|---|---|
| 1 (shipped) | 3 | 37 |
| **2** | **6** | **27** |
| **3** | **2** | **16** |

**The peak gets worse on the second pass and better on the third.** The ungated run ends at 2 and 16, both
better than where it started, which is why it scored as the campaign's best result on a failing design. The
gate never sees that, because it requires every pass not to worsen anything: it refuses pass 2 for taking
the peak from 3 to 6 and stops.

**So the gate is not measuring the wrong quantity - it is measuring at the wrong boundary.** A rule that
demands monotone improvement at every step cannot traverse a trajectory that first drops and then rises, and
the evidence says this trajectory does exactly that.

## 3. What the change should be instead

Three shapes would traverse it, in increasing order of how much they assume:

1. **track the best result seen** and keep it at the end, allowing intermediate worsening - the loop runs
   its passes, records (peak, total) after each, and returns to whichever was best. Simple, and it turns the
   gate into a search over the pass count rather than a monotone filter.
2. **allow a bounded worsening** - continue while the total improves by more than the peak worsens, which is
   a trade rather than a guard.
3. evaluate the trade only at the natural end of the loop.

The first is the most defensible because it assumes least: it does not need the trajectory to be monotone
and it does not need a trade rule to be justified in advance. It costs the same evaluations as running the
full pass count, which is the price of not knowing which pass is best until they are all measured.

## 4. Why this took until now to see

The ungated evidence was measured as three separate runs at fixed pass counts, and its intermediate values
were read as a curve. The gate was then built from the endpoints - 'three passes are good, one pass is the
status quo' - without asking whether the path between them was monotone. **The endpoints were what mattered
for the standing; the path is what matters for a gate, and it had never been looked at.**

## 5. State

- **In the tree**: SR-10, SR-11, and SR-20 with its path fix, pending the corrected gate.
- **Withdrawn with reasons**: SR-2/3/4/5/7/8/9/12/13/14/15/16, SR-17, SR-18, SR-19.
- **The multi-pass evidence stands**: three passes take gcd_ics55_a from 2.20x the reference's total
  overflow to 0.80x and its peak from 0.67x to 0.33x at no wirelength cost, s5378_sky130_b is inert, and
  s1238_sky130_a is damaged by the second pass - and it is now known that the second design's trajectory is
  non-monotone, which is why a per-step rule cannot capture it.
- **Standing**: 4 of 15 designs no worse on every measurable dimension; wirelength fails 2 of 15, total
  overflow 8 of 13 on meaningful counts, peak 9 of 13.
