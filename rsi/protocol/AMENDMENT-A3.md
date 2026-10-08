# Amendment A3 to Protocol v1.0

Date: 2026-09-16. Status: applied during Stage 2 (after 204 candidates and 5
completed trajectories).

## A3.1 Defect found

The Stage 2 candidate cache wrote its result file unconditionally, including when
the candidate run had failed (solver killed, non-zero exit, or the congestion gate
refusing the DEF). A failed record is indistinguishable from a valid one at read
time: the reader saw status != ok but still returned the cached payload, whose
signals are empty.

Consequence: a transient fault (in this instance, an external process cleanup
that killed in-flight iEDA children) became a permanent hole. The affected
designs reported status "no_reference" for every rung, which reads like a design
that cannot be measured rather than a fault that should be retried. 35 poisoned
cache entries were found and removed.

## A3.2 Fix

1. A cache entry is only trusted when it is usable: status ok, a legalized HPWL,
   and a congestion number. Anything else is deleted and recomputed.
2. A failure is never written to the cache, so a retry always gets a fresh
   attempt.
3. Locking (A2) is unchanged, and the re-check happens inside the lock so the
   deletion is safe against concurrent readers.

## A3.3 Data handling

Poisoned entries were purged. Candidates that had already been marked bad in this
run (aes, aes_core_sky130_b) will be re-run for those designs after the current
sweep finishes; the loop is per design, so the affected designs can be replayed
without touching the rest.

## A3.4 Why this is recorded rather than quietly fixed

The general hazard is that a data pipeline which caches failures looks identical
to one that caches successes until the analysis shows a design missing. Both
defects found in this campaign (A2 concurrency, A3 failure caching) produce
results that look plausible rather than results that break visibly. That is why
the protocol requires a cost record for every run and a failure list separate
from the results.
