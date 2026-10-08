# Amendment A6 to Protocol v1.0

Date: 2026-09-16. Status: applied to Stage 2 before the reported live trajectories.

## A6.1 Defect found

The candidate cache was validated against the identity of the loop code that
requested the measurement. Every change to the loop - including changes with no
effect on measurement, such as the seeding fix in A4 - therefore invalidated the
entire cache and recomputed all previously measured candidates. On a contended
machine that is several hours of redundant work per code change, and it makes the
experiment look stalled when it is merely redoing work.

## A6.2 Fix

A cached evaluation is a property of the candidate, not of the experiment that
asked for it. The cache is now validated on what actually determines the
measurement:

1. the evaluation is usable (A3, A5), and
2. it was produced by the same solver binary, identified by size and modification
   time, recorded on every entry.

The loop identity is still recorded on each entry for provenance, but no longer
gates reuse.

## A6.3 Scope and safety

- A failure is still never reused (A3).
- A measurement whose recorded solver identity differs from the current binary is
  deleted and recomputed, so the ledger cannot mix placements from two builds.
- The same reasoning applies to the analysis side, where records written by
  different improver generations are merged and the latest reading of a candidate
  is kept.

## A6.4 Note

This is the third defect in the family "an identity that is too coarse silently
discards valid data, and an identity that is too fine silently duplicates it".
Twenty candidate evaluations were previously double counted in the analyses for
the same reason and were corrected in the analysis code.
