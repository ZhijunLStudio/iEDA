# Round 26: what is actually in iEDA's source, and one claim that did not match the tree

## 1. The question this answers

Asked directly: has the source been changed. The answer is yes, and this is the exact inventory as it
stands, taken from the diff against the campaign's starting commit rather than from narrative.

    src/interface/tcl/tcl_ipl/tcl_ipl.cpp                     +50
    src/interface/tcl/tcl_ipl/tcl_ipl.h                        +2
    src/interface/tcl/tcl_ipl/tcl_register_pl.h                +2
    src/operation/iPL/api/PLAPI.cc                           +105  -3
    src/operation/iPL/api/PLAPI.hh                             +6
    src/operation/iPL/source/module/detail_placer/DetailPlacer.cc  +153
    src/operation/iPL/source/module/detail_placer/DetailPlacer.hh   +17
    src/operation/iPL/source/module/global_placer/electrostatic_placer/NesterovPlace.cc +6
    src/platform/tool_manager/tool_api/ipl_io/ipl_io.cpp       +44
    src/platform/tool_manager/tool_api/ipl_io/ipl_io.h          +2
    10 files, 387 insertions, 3 deletions

## 2. What each one is, and whether it changes the placement

| change | where | changes placement? |
|---|---|---|
| **SR-11** - detail placement is kept only when it is not dominated on the evaluator's congestion numbers | PLAPI.cc | **yes - this is the method change** |
| SR-10 - measure congestion in process with the project's own evaluator | PLAPI.cc | no, measures only |
| two Tcl commands (placer_finish, placer_run_nfs) | tcl_ipl.* | no, not called by any flow script |
| two API wrappers (runConvergedFinish, runNetworkFlowSpread) | ipl_io.*, PLAPI.hh | no, not called by any flow script |
| SR-1 retirement note | NesterovPlace.cc | no, comment only |
| NFS result log line | DetailPlacer.cc | no, log only |

**Exactly one of the six alters what the tool places: SR-11.**

## 3. The claim that was wrong

In Round 20 the commit message said "SR-9's demand proxy is reverted". **It was not.** The demand
estimator - SR-8's per-net bounding box charge plus SR-9's capacity term and blur, 153 lines in
DetailPlacer.cc and 17 in the header - was still in the tree and still running on every detail
placement, called twice per placement and logging both.

That contradicts two things already recorded: that the estimator was measured **not to track** the
evaluator, and that it was withdrawn. It is an instrument, so it never changed a placement - which is
exactly why nothing caught it: a change with no effect produces no anomaly. **A no-op is invisible to
every check except reading the diff.**

Removed now. Verified behaviour-neutral by A/B against the build that contained it:

| design | with the instrument | removed |
|---|---|---|
| s1238_ics55_a | 81 / 6, HPWL 3,371,592 | **identical** |
| salsa20_nangate45_a | 464 / 12, HPWL 503,948,119 | **identical** |

## 4. What the source state now is

    src/operation/iPL/api/PLAPI.cc                                +31  -3   (SR-10 + SR-11)
    src/operation/iPL/source/module/global_placer/.../NesterovPlace.cc  +6      (comment only)
    src/interface/tcl/tcl_ipl/*                                    +54
    src/platform/tool_manager/tool_api/ipl_io/*                    +46

Total source diff: **one behavioural change (SR-11), one measurement (SR-10), four dormant
exposures or comments.**

## 5. The routine that would have caught it

The check that found it was reading the diff itself, which is the only thing that sees a no-op. It
belongs with the other two cheap checks this work has needed: list what each binary contains before
comparing binaries, and list what the tree contains before trusting a narrative. Both cost one
command.
