# Amendment A2 to Protocol v1.0

Date: 2026-09-16. Status: applied before the reported Stage 2 measurements
(improver_id stage2-pareto-lock-v4).

## A2.1 Defect found

Stage 2 runs several adaptive loops per design (one per verifier rung, several
seeds). Loops for the same design share a candidate cache keyed on
(design, target_density, congestion_effort, seed), because a candidate must be
scored identically no matter which rung requested it. The first implementation
had no mutual exclusion, so concurrent loops could run iEDA in the SAME work
directory at the same time.

Consequence if not caught: one loop's run overwrites the other's placement.def,
both loops read whichever file survived, and both results look plausible. This is
the silent-wrong-result class the protocol section 10 exists to prevent, and it
would have been invisible in the aggregate.

## A2.2 Fix

An exclusive advisory lock (fcntl.flock) per candidate directory, with the cache
re-checked inside the lock. Exactly one process computes a candidate; the others
wait and then reuse the stored record. Verified by construction and by the
reappearance of cache hits (lock_wait_s recorded on reused records).

## A2.3 Data handling

All Stage 2 results produced before the fix were discarded (the stage2 work tree
was wiped) and the stage is being re-run under the fixed code. Stage 1 is
unaffected: its jobs are unique per (design, candidate), so no two processes ever
shared a work directory.

## A2.4 Cost-based design selection

The intent was to drop designs whose per-candidate cost makes a 30-round loop
impractical. Measured medians over 29 candidates per design put the slowest at
138 s (aes) and every design at or below 150 s, so no design is dropped: Stage 2
covers the same 32 cases as Stage 1. The apparent earlier slowness was
duplicated work from the race, not genuine cost.
