# Round 60: SR-20 is bounded and decides correctly, but its passes are not the same passes that produced the evidence

## 1. The mandatory check passed, and the decisions are sound

Three SR-20 runs, pass counts and decisions read from the planner's own log before any congestion result:

| design | extra pass declared | decision |
|---|---|---|
| s5378_sky130_b | 1 of 2 | peak 28 -> 28, total 3778 -> 3778 **(undone)** |
| gcd_ics55_a | 1 of 2 | peak 3 -> 4, total 37 -> 23 **(undone)** |
| gcd_ics55_a (seed 1000, earlier) | 1 of 2 | peak 3 -> 6, total 37 -> 27 **(undone)** |

**Bounded at two extra passes and stopping after one, exactly as designed** - the failure mode of SR-17 is
gone. The decisions are also the right ones under the rule: an extra pass whose congestion numbers do not
improve is undone (s5378_sky130_b, where nothing changed at all), and one that improves the total but
worsens the peak is refused (gcd_ics55_a), because the peak is the dimension the objective is losing on.

## 2. But the passes are not the passes the evidence came from

The ungated multi-pass evidence - three passes taking gcd_ics55_a from 2.20x the reference's total overflow
to 0.80x and its peak from 0.67x to 0.33x - was produced by repeating the **Tcl commands**
placer_run_lg and placer_run_dp. SR-20's extra passes call **PLAPI::runLG and PLAPI::runDP directly**.

Those are not the same call:

    PlacerIO::runLegalization()   ->  updatePlacerDB();  runLG();  writeBackSourceDataBase();
    PlacerIO::runDetailPlacement()->  updatePlacerDB();  runDP();  writeBackSourceDataBase();
    SR-20's loop                  ->  runLG();  runDP();   (no re-sync before, one write-back on undo)

**The command path re-synchronises the placer database from the source database before every stage.** SR-20
does not. So the extra passes it runs are not the extra passes the evidence measured, and its refusal of a
gain on gcd_ics55_a is **not yet evidence that the gate is too strict** - it may be that its passes are
weaker than the ones that produced the 0.80.

This is exactly the sort of difference that has produced four earlier withdrawls: a change that looks
equivalent to what was measured and is not. It is checkable, and it is the next thing to check.

## 3. What the round establishes and what it does not

**Established**: the loop executes, is bounded, logs every pass, and applies the rule - four properties that
SR-15, SR-17, SR-18 and SR-19 each lacked one of. SR-20 is a working instrument.

**Not established**: whether the instrument captures the lever. On gcd_ics55_a the ungated command-based
three-pass run improved both congestion numbers and SR-20's API-based single extra pass worsened the peak.
Until the path difference is removed, the two numbers are not comparable and no conclusion about the lever
can be drawn from SR-20's no-ops.

## 4. Cost, unchanged

Each extra pass is one legalisation, one detail placement and two trial-route evaluations, about six minutes.
On both designs tested SR-20 paid for one extra pass and stopped, so it cost roughly one pass.

## 5. State

- **In the tree pending measurement**: SR-20, and the path difference above.
- **Withdrawn with reasons**: SR-2/3/4/5/7/8/9/12/13/14/15/16, SR-17, SR-18, SR-19.
- **The multi-pass evidence stands as measured, but by the command path**: three Tcl-command passes take
  gcd_ics55_a from 2.20x the reference's total overflow to 0.80x and its peak from 0.67x to 0.33x at no
  wirelength cost, s5378_sky130_b is inert, and s1238_sky130_a is damaged by the second pass.
- **Standing**: 4 of 15 designs no worse on every measurable dimension; wirelength fails 2 of 15, total
  overflow 8 of 13 on meaningful counts, peak 9 of 13.
