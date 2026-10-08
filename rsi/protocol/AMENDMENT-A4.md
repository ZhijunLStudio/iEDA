# Amendment A4 to Protocol v1.0

Date: 2026-09-16. Status: applied before the reported Stage 2 dynamics results.

## A4.1 Defect found

Every stochastic choice in the harness (which candidate an adaptive loop proposes
next, which random policy replay a simulation runs) was seeded with Python's
hash() of a tuple. Python salts tuple hashing per process (PYTHONHASHSEED), so the
same command produced different proposals on different runs. The trajectories on
disk were therefore not reproducible, which contradicts the protocol's
determinism requirement, and the pre-registered comparison of arms would not have
been repeatable by a reader.

## A4.2 Fix

Seeding goes through a single helper (stable_seed), which derives an integer from
a SHA-256 of the identifying strings and is independent of the interpreter's hash
salt. Stage 2 loops, the three-arm runner and the scheduling replay all use it.

## A4.3 Data handling

The Stage 2 trajectories produced before the fix were moved aside (the candidate
cache, which is keyed on the candidate itself and not on the random walk, was
kept). Stage 2 was restarted under stable seeding. Stage 1 is unaffected: its
candidate set is an exhaustive grid, not a random walk.

## A4.4 Related finding during the same audit

Three designs (PPU_sky130_b, aes, aes_core_sky130_b) had failed with a
"no_reference" status. The cause was not the solver: an external process cleanup
during the campaign killed in-flight runs, and the version of Stage 2 that was
already resident in memory still cached failures. With A3 in force, a restart
repairs these designs by recomputation rather than by special handling.
