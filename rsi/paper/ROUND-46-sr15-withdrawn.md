# Round 46: SR-15 broke a design it should not have touched, and was withdrawn

## 1. The measurement caught it in the first pair

SR-15 kept the density mechanism alive past step-length stagnation and restored the placement if the
overflow did not fall. Its safety claim was that it can gain where SR-14 gained and cannot lose where SR-14
lost, and the first pair tested refutes it:

| design | seed | control (f9581627) | SR-15 |
|---|---|---|---|
| **apb4_timer** | 1000 | GP terminal overflow **0.0983** (converged) | GP terminal overflow **0.9479** |

**apb4_timer's global placement reaches its target and SR-15 destroyed it** - the terminal overflow went
from 0.098 to 0.948. The design the mechanism is supposed to be inert on is the one it broke.

## 2. The cause is structural, and visible in the source

The engagement branches end in continue, which skips the rest of the loop body - the wirelength and density
gradient updates, the penalty refresh, and the iteration bookkeeping. SR-14 did the same and happened not to
trip on the designs tested. SR-15 added a second continue, in the branch that waits for the grace period,
so the solve could spend up to sixty iterations skipping its own updates. The solver's state and the
placement diverge, and the result bears no relation to the objective.

This is a defect of the implementation, not of the idea. The idea - measure inside the solve and keep the
mechanism only when it lowers the overflow - might still work if the continuation let the loop body run
rather than skipping it. That is a different change and it is not made here.

## 3. What was done

- **SR-15 is withdrawn.** The two files are restored from the commit before it and the rebuild reproduces
  **f9581627**, so the withdrawal is exact.
- The in-flight SR-15 runs were killed rather than allowed to finish, since they produce placements that
  are not comparable to anything.

## 4. What this round is worth

**The protocol did its job.** SR-15 passed review on the page - it is a strict guard around a mechanism
that had been measured to work - and it was caught by the first paired measurement, on a design chosen
specifically as the safety control rather than as the target. A test that had used only gcd_sky130_a, where
the mechanism engages, would have reported a plausible result and shipped a change that wrecks designs whose
global placement is fine.

Two things this campaign keeps rediscovering are both in evidence: a change is judged by what it does on the
designs it is not aimed at, and an implementation defect produces plausible numbers rather than obvious
errors.

## 5. Where the objective stands

- **Standing** (15 valid designs, both arms in one batch, corrected reference): **4 designs no worse on
  every measurable dimension**; wirelength fails 2 of 15, total overflow 10 of 13, peak 9 of 13.
- **In the tree**: SR-10 (in-process congestion measurement) and SR-11 (detail-placement dominance guard).
- **Withdrawn with recorded reasons**: SR-2, SR-3, SR-4, SR-5, SR-7, SR-8, SR-9, SR-12, SR-13 (mixed),
  **SR-15 (destroys a converging design)**.
- **SR-14 remains a verified mechanism without a reliable sign** - it lowers terminal overflow and improves
  congestion where the solve stagnates above target, is inert where the solve converges, and is
  unpredictable on a third group. It is not in the tree.
- **ce4 (congestion-aware global placement) re-confirmed as a knob, not a default**, now on the corrected
  metric.

## 6. A transient worth recording

One rebuild failed with collect2: fatal error: cannot find ld and succeeded unchanged on retry, with 187 GB
free. It looked like resource exhaustion from concurrent builds rather than a toolchain fault; if it recurs
it should be read as the machine being loaded, not as a reason to doubt an edit.
