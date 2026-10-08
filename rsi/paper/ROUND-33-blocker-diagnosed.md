# Round 33: the blocker is identified exactly - any path containing "log" cannot be created

## 1. The rule, and the observation that proves it

The host refuses to create a directory when the full path contains the lower-case substring "log".
The decisive case is not a log directory at all:

| path | result |
|---|---|
| runs/rt5/rt/rt_temp_directory | ok |
| **runs/rt5/rt/rt_temp_directory/topology_generator** | **FAIL** |
| runs/rt5/rt/tmpdir/gen | ok |
| runs/rt5/a/b/c/d/e/f | ok |

topology_generator contains no word "log" but does contain the substring - topoLOGy. It fails; the same
depth and the same parent with a different name succeeds. Every earlier observation fits the same rule:

| path | result | why |
|---|---|---|
| .../pl/log | FAIL | contains log |
| .../pl/ilog | FAIL | contains log |
| .../pl/dshlogs | FAIL | contains log |
| .../pl/bbilog | FAIL | contains log |
| .../pl/LOG | ok | upper case |
| .../pl/dsh, .../pl/trace, .../pl/x | ok | no log |
| a file named log | ok | files are not restricted, only directories |

Rename, copy and archive extraction to such a path all fail, so it is enforced below the shell.

## 2. Why this stops the flow, and why it cannot be worked around from here

iEDA creates at least two such paths on the standard path:

1. **iPL**: <output>/pl/log - the placement log directory. **Worked around** in a local build by renaming
   it to pl/trace; the flow then ran through global placement and legalization instead of aborting at
   start-up.
2. **iRT**: <output>/rt/rt_temp_directory/topology_generator - the router's temporary directory. The flow
   now aborts here, with the same Permission denied.

Renaming the second would mean editing iRT's internals, and there is no reason to believe it is the last
one - **any** directory iEDA names with "log" anywhere in its path is affected, and "topology" alone
appears throughout a router. Editing iEDA's internal directory names to dodge a host-side string rule
would make the source diverge from upstream for reasons that have nothing to do with placement quality,
and would have to be undone later.

**Both workaround edits were reverted**, and the tree is byte-for-byte the build it already was:
md5 f95816274f668e58a7456bdf5358cf7b.

## 3. What this means

**The objective is blocked at its first step.** The flow cannot produce a placement, so no standing can
be rebuilt, no A/B can be run, and no source change can be evaluated. Every remaining task in the
objective depends on a placement.

## 4. What I need

One of:

1. **The host restriction lifted** for paths containing "log" - then everything runs unchanged and the
   round-31 standing rebuild proceeds.
2. **Confirmation that the restriction is intended**, in which case the placement flow needs its
   directory names changed, and I would want that done as a separate, labelled configuration - not mixed
   with the algorithmic work, whose every claim depends on measuring placements.

## 5. What was learned that is worth keeping

- The round-31 anomaly (the same design, seed and binary giving 10,717,785 in some batches and
  7,364,089 in others, each batch internally exact) now has a plausible mechanism: **the host was
  refusing directory creation intermittently and then persist**--ently during this session, and early
  runs in this campaign did create pl/log successfully, which is how the restriction was not noticed
  sooner. A run that aborts at start-up produces no placement; a run that aborts later produces a partial
  one; both would look like "a different result for the same configuration". This remains a hypothesis
  rather than a measurement, because it cannot now be tested while the flow cannot run.
- The method rules already written down - same batch, both arms, commit-matched binaries, read the diff -
  are what allowed this to be diagnosed rather than mistaken for an algorithmic effect.

## 6. Tree state

Unchanged and clean. SR-10 and SR-11 in; SR-2, SR-3, SR-4, SR-5, SR-7, SR-8, SR-9, SR-12, SR-13 and
SR-14 withdrawn with recorded reasons. Binary f9581627.
