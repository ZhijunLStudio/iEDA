# Round 88: retraction - round 87's "protocol-correct confirmation" re-scored concurrent placements

## 1. What is wrong

Round 87 reported that the acceptance result was confirmed under the one-flow-at-a-time protocol:
primary 2/15 -> 4/15, secondary 17/44 -> 26/44, 9 gains, 0 regressions, "identical to the concurrent
validation in every headline number".

It was identical because **it was the same placements**. `multi_seed_sweep.py` keys its work directory by
`(arm, design, seed)` only, and skips the flow when `placement.def` already exists:

    wd = runs/seedwork/<arm>_<design>_s<seed>
    if not (wd/"placement.def").exists():  <run the flow>

The concurrent validation had already written those DEFs. The "sequential" run therefore **reused them and
only re-ran the evaluator**. Proof from the filesystem:

    seedwork/sr26_gcd_sky130_a_s1003/placement.def   2026-09-20 03:36:58
    seedwork/sr26_gcd_nangate45_a_s1000/placement.def 2026-09-20 03:35:27
    seedwork/sr26_apb4_timer_s1002/placement.def     2026-09-20 03:34:29

The concurrent validation ran roughly 03:16-04:35; the "sequential" one ran 05:45-06:30. Every DEF carries
the earlier timestamp. The sequential table was a **re-measurement of concurrent placements**, so it said
nothing about the sequential protocol - and the perfect agreement between the two tables was an artifact of
that, not evidence of robustness.

**Round 87's confirmation is withdrawn.** The records (`runs/seedcells_seq_sr26`, `runs/seedcells_seq_cur`)
are deleted and the copies that reached `rsi/analysis/out/` and git are superseded here.

## 2. What survives

Round 86's finding is untouched, because that measurement used a different script (`/tmp/stab.py`) which
creates a fresh work directory per repetition and always runs the flow:

    gcd_sky130_a seed 1003, SR-26, one flow at a time, four consecutive repeats:
        747/14  747/14  747/14  747/14        (all pass, reference 900/22)

against the concurrent validation's 1004/19 for the same cell. So the claim that **the co-run pattern can
flip a cell's verdict** stands, and the sequential value for that cell really is 747/14. What is unknown is
the sequential *table*, which round 87 claimed to have and did not.

## 3. The fix

The work directory is now keyed by the output directory as well:

    runs/seedwork/<outdir>/<arm>_<design>_s<seed>

so two runs in different co-run patterns can never reuse each other's placements, and a resumed run cannot
silently inherit another condition's state. No per-design or per-seed choice is involved; it is a naming
change.

Verified after relaunch: fresh directories appearing under `seedwork/seedcells_seq_sr26/`, exactly **one**
iEDA process alive, one sweep, one wrapper.

## 4. Why this keeps happening to me, and what I am changing

This is the third orchestration error of mine in this campaign, and the third with the same shape -
**reusing or overlooking state from a differently-conditioned run**:

| round | error |
|---|---|
| 79 | three sweep invocations left running from earlier launches, racing over one work directory |
| 86 | a leftover repeatability script still running while I launched the "sequential" validation |
| 88 | the sweep's resume check silently reusing the other co-run pattern's placements |

The common factor is that each run's *inputs* are not fully captured by the identifiers used to cache its
outputs. The corrective is the same each time: **a run's cache key must include every condition that can
change its result**, and here that is the co-run pattern (round 76) in addition to binary, design and seed.
The work-directory key now does that.

I am also recording the general rule this campaign now needs, because it is sharper than the one it had:

    A measurement is identified by (binary, design, seed, co-run pattern, thread settings).
    Any cache, checkpoint or resume path must key on that whole tuple, not a prefix of it.

## 5. State

- **Tree**: SR-26, `build/bin/iEDA` = `f6f81193`, unchanged this round.
- **Running**: sequential validation re-launched with fresh work directories, 44 cells per arm, both arms,
  the eleven candidate designs, one flow at a time, flock-protected.
- **Validated so far (concurrent pattern only)**: primary 2/15 -> 4/15, secondary 17/60 -> 26/60, 9 gains,
  0 regressions. This is one measurement in one pattern and is the only acceptance evidence that exists.
- **Withdrawn**: round 87's sequential confirmation, and the round-84 single-cell evidence (round 85).
- **Objective**: 4/15 measured, with the protocol-correct re-measurement in flight.
