# Amendment A7 to Protocol v1.0

Date: 2026-09-17. Status: applied to the signoff rung.

## A7.1 Defect found

The signoff driver (which pushes a placement DEF through clock tree synthesis,
routing and DRC) had no mutual exclusion on its work directory. Two invocations for
the same design therefore ran CTS and the router in the same directory at the same
time. This is the same hazard as A2 in a second script: each run writes the stage
DEFs and the routing temp tree, so the surviving files are a mixture of two runs and
the DRC result would describe neither candidate.

## A7.2 Fix

An exclusive lock for the whole chain, keyed on the work directory, taken before the
first stage and released on every exit path.

## A7.3 Ordering defects found in the same investigation

The project's per-stage scripts could not be used as-is for a placement-to-signoff
chain, for two reasons that are recorded because they affect anyone reusing them:

1. The stage scripts read the SDC before the DEF, so a clock port that only the DEF
   introduces cannot be resolved and CTS aborts with sdc_clock_resolution_failed.
   The signoff script orders the reads as config, tech LEF, cell LEF, DEF, library,
   SDC, then the stage.
2. Routing requires init_rt before run_rt; without it the GDS plotter singleton is
   never initialised and the router aborts.

## A7.4 Scope of the signoff evidence

The signoff chain is used as a spot check, not as a campaign-wide rung: one design
(gcd_sky130_a) and, at the time of writing, the geometry-optimal candidate, which
produced a routed design with 155 DRC violations. Absolute violation counts from a
single design are not a claim about the ladder, and the rung's comparative result is
reported only if both candidates complete. This is stated in the paper's limitations
rather than presented as a finished measurement.
