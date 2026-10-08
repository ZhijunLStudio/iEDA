# Round 30: SR-14 is withdrawn, and the "legalization costs 40%" finding is retracted

## 1. SR-14, and why it is withdrawn

SR-14 kept the Nesterov solve alive past step-length stagnation when the density overflow was still
above 1.1x target, using the quadratic density penalty the tree already contains. It built and it was
plausible, and it is withdrawn because the measurement does not support it.

**Measured against the correct control**, same batch, same seed, one thread:

| binary | md5 | global placement wirelength | legalization/global placement |
|---|---|---|---|
| control | f9581627 | 10,717,785 | 1.403 |
| **SR-14** | **0c50cc35** | **10,717,785** | **1.403** |

**Identical.** Two runs each, same value. The source is restored and the rebuild reproduces f9581627
exactly, so the withdrawal is byte-for-byte clean.

## 2. The finding it was built on is retracted

SR-14 existed because a stage table showed legalization inflating wirelength by 40% on gcd_sky130_a and
s1238_sky130_a - the only two designs above 7% - and the reading was that global placement exits with an
unmet density constraint and legalization pays for it.

That reading does not survive re-measurement. **The same design, configuration, seed, command and binary
produced global-placement wirelength 10,717,785 in some batches and 7,364,089 in others**, with
legalization/global-placement of 1.403 and 1.012 respectively:

| batch | runs | global placement | legalization / global placement |
|---|---|---|---|
| current-tree sweep | 1 | 10,717,785 | 1.403 |
| bin_check, binary f9581627 | 2 | 10,717,785 (both) | 1.403 |
| bin_check, binary 0c50cc35 | 2 | 10,717,785 (both) | 1.403 |
| repro, one thread | 5 | 7,364,089 (all 5) | 1.012 |
| repro, eight threads | 5 | 7,364,089 (all 5) | 1.012 |

**Within a batch the result is exactly reproducible; between batches it moves by 31%.** The batches used
the same binary, the same case configuration (unmodified, timestamps from 09-16), no derived config,
Tcls identical apart from output paths, and the same thread settings, so the difference is not in
anything the harness declares.

**So the 40% legalization cost is not a property of the flow.** It is a first-stage outcome that one batch
produced and another did not. The retraction is total: the stage-level claim, the "GP debt" framing, and
the SR-14 motivation all go with it.

## 3. What this is, in the list of protocol defects

This is the fourth defect of the same kind, and the most serious:

1. the reference was scored illegal, inflating its congestion 2.0x to 2.7x (Round 28);
2. a control binary contained two changes (Round 24);
3. the pipeline is only deterministic at one OpenMP thread (Round 29);
4. **an input the harness neither controls nor records changes a first-stage result by 31%.**

All four have the same shape: **a comparison between two things that were not actually comparable.** The
first three were fixed by changing what is measured or which binaries are compared. The fourth is not
fixed yet, and the practical consequence is a rule:

**Every conclusion must come from a single batch that contains both arms.** Comparisons across batches -
"the sweep said X, a fresh run says Y" - are not evidence, however reproducible each batch is internally.
The A/B scripts used in this work already run both arms in the same process, which is why their
"identical" and "different" verdicts remain trustworthy; it is the cross-batch stage tables that are not.

## 4. What stands

- **SR-10** (in-process congestion measurement) and **SR-11** (detail-placement dominance guard) are in
  the tree. SR-11 is not inert - it changes the placement on s5378_sky130_b - but its measured effect is
  of order 0.1%.
- Withdrawn with recorded reasons: SR-2, SR-3, SR-4, SR-5, SR-7, SR-8, SR-9, SR-12, SR-13, **SR-14**.
- The corrected standing (both sides legalised) is unchanged: 4 of 15 designs no worse on every
  measurable dimension; wirelength loses on 3 of 15; union loses on 11 of 13; peak on 12 of 13.

## 5. What the next round must do first

Find the uncontrolled input. It is not the binary, the config file, the Tcl, the seed or the thread
count. The remaining candidates are the launch environment and anything the flow derives at runtime from
the machine - and until it is identified, no stage-level claim can be made. That is the immediate task,
ahead of any further source change.
