# Round 79: my own orchestration error invalidated the round-78 SR-25 cells

## 1. What I got wrong

Running `ps` before touching anything this round:

    parent (ppid = bash)  workers=3   elapsed 20:16   --arms sr25 ... --outdir seedcells_sr25
    parent (ppid = bash)  workers=4   elapsed 08:10   --arms sr25 ... --outdir seedcells_sr25
    parent (ppid = bash)  workers=4   elapsed 02:16   --arms sr25 ... --outdir seedcells_sr25

**Three sweep invocations were running concurrently**, all writing the same
`runs/seedcells_sr25/*.json` records and the same `runs/seedwork/sr25_<design>_s<seed>` working
directories. Up to 11 iEDA processes were alive at once.

I had launched them across rounds and believed two of them were dead because my launching shell had been
reaped. In rounds 78 I attributed the resulting "no placement.def" records to the launcher being reaped.
**That attribution was wrong: the records were produced by concurrent sweeps deleting and recreating each
other's working directories.** The campaign's own environment rule says process cleanup must be verified by
listing rather than assumed; I skipped it, and then diagnosed a symptom without looking at what was
running. Same class of error as the ones this campaign has a rule against.

## 2. What it invalidates

**All round-78 SR-25 cells are discarded.** Their co-run pattern is undefined - somewhere between 3 and 11
processes - so they cannot be compared with anything, and two of the three values I quoted for one cell
(907 and 800 for gcd_sky130_a seed 1000) are as likely to be an artifact of sweep overlap as of the
4-in-flight pattern I attributed them to.

Deleted: `runs/seedcells_sr25/` and `runs/seedwork/sr25_*`. The round-78 note stands as a record of what
was observed; its numbers are marked invalid here.

**Not invalidated:** SR-25's execution evidence (the segment log, which is per-process and unaffected),
and the round-77 screen (one launcher, three workers, no overlap at the time it ran - that is the one whose
numbers I now trust least among the three, so it should be re-taken too).

## 3. Fix

`run_sr25_validation.sh` now takes an exclusive `flock` and refuses to start if one is held, so a
second launch cannot race the first. Verified after relaunch: one parent whose parent is the wrapper shell,
four workers, four iEDA processes, and no other sweep anywhere.

    pid 879052 ppid 879044   <- the single sweep parent
    pid 879053..879056 ppid 879052   <- its four workers

## 4. State

- **Tree**: unchanged, SR-25 in place, `build/bin/iEDA` = `c385b257` (committed 5f737d8).
- **Running**: one locked sweep, `--arms sr25 --seeds 1000,1001,1002,1003 --workers 4`, output to
  `runs/seedcells_sr25`, with a wrapper that restarts on interruption so it can finish.
- **Discarded this round**: round 78's SR-25 cells.
- **Still true from round 77** (to be re-measured): SR-25 executes, is bounded, both segments improve the
  entry state, and its entry measurement equals the current tree's result for the same cell.

## 5. Lesson recorded

A long-running measurement must be **provably single-instance** before its output is read, and "I think I
killed that" is not evidence. Two of the three overlapping sweeps existed because I re-launched after a
shell was reaped without listing the survivors. This is the third time in this campaign that a conclusion
was confounded by a process I did not know was running (rounds 31, 76, and now 79), and the first time it
was mine rather than the environment's.
