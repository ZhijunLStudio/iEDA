# Round 64: what has actually been changed in iEDA, and the standing it produces

## 1. The source changes, as they stand

Ten files, +338 / -12 against the campaign's starting commit:

| file | lines | what it is |
|---|---|---|
| src/operation/iPL/api/PLAPI.cc | +222 -12 | **SR-10** (call the project's own congestion evaluator around detail placement), **SR-11** (keep detail placement only when it does not worsen both congestion numbers), **SR-21** (runGatedFinish: up to two extra LG+DP passes, keep the best) |
| src/operation/iPL/api/PLAPI.hh | +7 | declarations for those |
| src/platform/tool_manager/tool_api/ipl_io/ipl_io.cpp | +48 | calls runGatedFinish from runDetailPlacement - **the function the placer_run_dp command actually lands in** |
| src/interface/tcl/tcl_ipl/tcl_ipl.cpp | +50 | two Tcl command classes (placer_finish, placer_run_nfs) |
| src/interface/tcl/tcl_ipl/tcl_ipl.h | +2 | their declarations |
| src/interface/tcl/tcl_ipl/tcl_register_pl.h | +2 | their registration |
| src/operation/iPL/source/module/detail_placer/DetailPlacer.cc | +10 | an NFS result log line |
| src/operation/iPL/source/module/detail_placer/DetailPlacer.hh | +1 | - |
| src/operation/iPL/source/module/global_placer/electrostatic_placer/NesterovPlace.cc | +6 | a comment recording why an earlier change was retired |
| src/platform/tool_manager/tool_api/ipl_io/ipl_io.h | +2 | - |

**The current build is md5 62f55d58, which is SR-10 + SR-11 + SR-21.** The campaign's baseline build is
f9581627 (SR-10 + SR-11); the original unmodified iEDA is c9761dc9.

## 2. The standing: current source against Innovus

Both sides legalised in the same batch, seed 1000. Ratios are ours over the reference; below 1.00 is better.

| design | PDK | HPWL | union | max | verdict |
|---|---|---|---|---|---|
| aes | sky130 | 0.7323 | 1.3609 | 1.6111 | fail: union, max |
| apb4_timer | sky130 | 0.8717 | 0.9285 | 1 | **ALL** |
| gcd_ics55_a | ics55 | 0.9442 | 1.85 | 0.5 | fail: union |
| gcd_nangate45_a | nangate45 | 0.8919 | - | - | **ALL** |
| gcd_sky130_a | sky130 | 1.1357 | 2.3889 | 1.2727 | fail: hpwl, union, max |
| picorv32 | sky130 | 0.8081 | 1.4525 | 1.6111 | fail: union, max |
| s1238 | sky130 | 0.7613 | 1.142 | 1.4286 | fail: union, max |
| s1238_ics55_a | ics55 | 0.8289 | 0.5226 | 0.4286 | **ALL** |
| s1238_nangate45_a | nangate45 | 0.7489 | - | - | **ALL** |
| s1238_sky130_a | sky130 | 1.0776 | 2.0525 | 1.8571 | fail: hpwl, union, max |
| s38584_ics55_a | ics55 | 0.9695 | 1.1656 | 1.6 | fail: union, max |
| s38584_nangate45_a | nangate45 | 0.959 | 1.5 | 1 | fail: union |
| s5378_sky130_b | sky130 | 0.8962 | 1.5597 | 1.2727 | fail: union, max |
| salsa20_ics55_a | ics55 | 0.9448 | 0.7862 | 1.1429 | fail: max |
| salsa20_nangate45_a | nangate45 | 0.9414 | 1.8862 | 1.7143 | fail: union, max |

**4 of 15 designs are no worse on every measurable dimension** (apb4_timer, gcd_nangate45_a, s1238_ics55_a,
s1238_nangate45_a; the two nangate45 designs have no congestion reference so only wirelength is claimed).
**Wirelength fails 2 of 15, total overflow 10 of 13, peak 9 of 13.**

## 3. What SR-21 adds on the designs it has been measured on

| design | without SR-21 (union / peak) | **with SR-21** | outcome |
|---|---|---|---|
| **gcd_ics55_a** | 1.85 / 0.50 | **0.80 / 0.3333** | failing to passing |
| s5378_sky130_b | 1.5597 / 1.2727 | **1.5399 / 1.2727** | essentially unchanged |
| s1238_sky130_a | 2.0525 / 1.8571 | **2.0525 / 1.8571** | byte-identical to the shipped flow |

## 4. What is still missing from this table

**The original unmodified iEDA's own numbers under this protocol.** The old file recording them was deleted
during a disk cleanup and it was measured under the bypass protocol anyway (whose reference congestion was
2.0x to 2.7x too large), so it is being re-measured now with the original binary c9761dc9 on all fifteen
designs, scored against the same legalised references. Five of fifteen are done. When it finishes this
table gets a third arm and the question 'what did the changes buy against stock iEDA' has a real answer
rather than a comparison across two protocols.

## 5. What has been withdrawn

SR-2/3/4/5/7/8/9/12/13/14/15/16/17/18/19/20 - sixteen changes, each with a recorded measured reason. They
are not in the tree. What is in the tree is three changes, of which SR-21 is the only one with a measured
effect on a failing design.
