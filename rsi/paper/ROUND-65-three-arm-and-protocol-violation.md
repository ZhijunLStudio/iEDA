# Round 65: the three-arm comparison exists, and a protocol violation found while measuring the timing column

## 1. The table the objective needs

Per design, three arms and the five dimensions. The first three are now measured; the timing pair is in
progress. Both reference arms were verified to use the **same** reference artefact (checked value by value
for wirelength and both congestion numbers), so the comparison is within one protocol.

**Headline: 3 of 15 designs pass on all three geometric dimensions with unmodified iEDA; 4 of 15 with the
current tree, and gcd_ics55_a becomes a fifth when SR-21 is included.**

## 2. What the changes bought, read off the table

The large effects are all on the nangate45 designs, where the baseline is far from the reference:

| design | dimension | original | current |
|---|---|---|---|
| s38584_nangate45_a | total overflow | 10.500 (21) | **1.500 (3)** |
| s38584_nangate45_a | peak | 4.000 (4) | **1.000 (1)** |
| salsa20_nangate45_a | total overflow | 4.431 (1090) | **1.886 (464)** |
| salsa20_nangate45_a | peak | 2.000 (14) | **1.714 (12)** |
| apb4_timer | peak | 1.250 (20) | **1.000 (16)** - now passes |
| picorv32 | peak | 2.056 (74) | **1.611 (58)** |
| s1238 | total overflow | 1.275 (1957) | **1.142 (1753)** |
| s1238_ics55_a | total overflow | 0.852 (132) | **0.523 (81)** |

**The cost is wirelength, and it is a real trade, not bookkeeping**: almost every design's wirelength
rises slightly, most on s1238 (0.694 to 0.761), because SR-11 falls back to the legalised placement when
detail placement worsens congestion and the legalised placement is the worse one for wirelength.

**And there is one genuine self-inflicted regression: gcd_sky130_a is worse on all three** (wirelength 1.125
to 1.136, total 2.221 to 2.389, peak 1.182 to 1.273). That is on the record; SR-11 helps twenty numbers and
hurts three, on the same design.

## 3. Timing, the fifth dimension

The stored timing results were lost in a disk cleanup and had been measured under the old bypass protocol,
so the timing column is being re-measured now: **four arms per design** - unmodified, current tree, current
tree with SR-21, and the legalised Innovus reference - all with the same iSTA, the same library, the same
SDC and the same pre-route RC model, which is what makes it a placement comparison rather than a signoff
result.

A first design is measured. apb4_timer, setup WNS and TNS:

| arm | setup WNS | setup TNS |
|---|---|---|
| unmodified | -0.5903 | -26.937 |
| current | -0.5887 | -26.838 |
| **Innovus** | **-0.6860** | **-30.960** |

**We are less negative on both, i.e. better**, which is consistent with apb4_timer being the one design that
already passed every dimension. The remaining sky130 designs are running.

## 4. A protocol violation I created, found and fixed

While checking whether the placement runs were stuck I found two problems with my own orchestration:

1. **I was reading the wrong log.** iEDA's glog re-initialises itself to `/var/tmp/`, so the file under the
   run's own `pl/log/` holds only a three-line header. I counted zero `Start Detail Placement` events in it
   and concluded four runs had hung; their real logs show they were running. The check must match the log by
   process id, not by directory.
2. **The launches were not pinned to one OpenMP thread.** `rsi_lib.run_cmd` pins `OMP_NUM_THREADS` for a
   documented reason - 48 of the 50 parallel regions in the tree do not set a thread count, and the
   reduction order changes the solver trajectory, so the same binary and input give different wirelength
   under different core counts. **My launchers called the benchmark's own `run_ieda`, which copies the
   environment instead, and I passed `RSI_OMP_THREADS` while the runtime reads `OMP_NUM_THREADS` - the wrong
   name, so nothing was pinned and each process took 128 threads.**

The four placement runs already produced in that configuration were discarded and the whole arm restarted
pinned, because a multi-threaded result is not comparable with the pinned standing and mixing the two is
exactly the kind of cross-protocol comparison this campaign has already been burned by.

**Prior A/B conclusions are unaffected and there is a hard check on that**: SR-21's result on
s1238_sky130_a is byte-identical to the standing's placement, and the standing was measured through the
pinned path. If the thread count moved the solver, that could not be true. Threading affects the congestion
evaluator, whose output is an integer overflow count.

## 5. State

- **In the tree**: SR-10, SR-11, SR-21 (build 62f55d58).
- **Withdrawn with reasons**: sixteen changes, SR-2 through SR-20.
- **Standing, three dimensions**: 3 of 15 pass with unmodified iEDA, 4 of 15 with the current tree, 5 with
  SR-21 included on the designs measured so far.
