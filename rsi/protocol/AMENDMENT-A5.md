# Amendment A5 to Protocol v1.0

Date: 2026-09-16. Status: applied before the reported Stage 2 dynamics results.

## A5.1 Rule added

A candidate whose truth could not be measured (missing congestion, missing
legalized wirelength, or a failed evaluation) must not enter a trajectory. The
loops skip such a candidate, record it in the trajectory as skipped with the
reason and the cost already paid, and continue.

## A5.2 Why

The three-arm validation showed a held state whose congestion component was
missing. The loop had accepted it because its own rung's signal was present, which
is correct behaviour for the loop - the loop is not supposed to look at the truth -
but it left a hole in exactly the half of the truth the analysis needs. Since the
analysis recomputes the trajectory score from both truth components, a hole
silently degrades that trajectory's data rather than announcing itself.

This is the same family as A3 (a failure must not be stored as a result): the
harness must not let a missing measurement travel as if it were a measurement.

## A5.3 Scope

Applies to Stage 2 loops and to the three-arm runner. The candidate cache rule from
A3 is unchanged: an unusable evaluation is not cached, so a later attempt can
succeed. Skipping is recorded rather than silent, so the number of unscored
candidates is auditable.
