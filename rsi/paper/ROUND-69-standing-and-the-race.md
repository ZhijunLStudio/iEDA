# Round 69: the standing under the adopted protocol, and the race that explains the residue

## 1. The 15-design standing, measured one flow at a time

First standing measured with the router's thread pin in force (round 67 fix), one flow at a time,
OMP_NUM_THREADS=1, shipped placer config, scored by the ruler against the fixed reference:

| design | hpwl | union | max | fails |
|---|---|---|---|---|
| apb4_timer | 0.8717 | 0.9310 | 1.0000 | - |
| gcd_nangate45_a | 0.8881 | 1.0000 | 1.0000 | - |
| s1238_ics55_a | 0.8289 | 0.5226 | 0.4286 | - |
| s1238_nangate45_a | 0.7489 | 1.0000 | 1.0000 | - |
| aes | 0.7324 | 1.3611 | 1.7778 | union,max |
| gcd_ics55_a | 0.9442 | 1.8500 | 0.5000 | union |
| gcd_sky130_a | 1.1251 | 2.1956 | 1.1818 | hpwl,union,max |
| picorv32 | 0.8081 | 1.4525 | 1.6111 | union,max |
| s1238 | 0.6935 | 1.2521 | 1.4286 | union,max |
| s1238_sky130_a | 1.0766 | 2.0988 | 1.7857 | hpwl,union,max |
| s38584_ics55_a | 0.9695 | 1.1897 | 1.6000 | union,max |
| s38584_nangate45_a | 0.9590 | 1.5000 | 1.0000 | union |
| s5378_sky130_b | 0.8962 | 1.5605 | 1.2727 | union,max |
| salsa20_ics55_a | 0.9449 | 0.7947 | 1.3143 | max |
| salsa20_nangate45_a | 0.9414 | 1.8862 | 1.7143 | union,max |

**ALL-DIM PASS 4/15.** The determinism fix changed how the numbers are obtained, not the count.
Nine designs still fail on congestion alone while winning wirelength by 3% to 25%; two fail wirelength
and both are the designs whose global placement hit the 2000-iteration cap (round 66).

## 2. But "one at a time" is not sufficient either

Comparing across sessions, the same design, binary, seed and config gives different answers:

| design | session A | session B |
|---|---|---|
| gcd_ics55_a | union 17 (4 runs, byte-identical) | union 37 (serial sweep, and again in a single-design probe) |
| gcd_sky130_a | union 1994 / max 36 | union 1976 / max 26 |

And the file check is negative: a complete flow leaves **no file outside its own workdir** (scanned
/tmp, /var/tmp, the repository and the case tree for anything modified during the run). So this is not
a leftover artifact on disk.

## 3. The cause: iPL's wirelength gradient races across nets that share a pin

    src/operation/iPL/source/module/evaluator/wirelength/WAWirelengthGradient.cc

      line 241  #pragma omp parallel for num_threads(thread_num) schedule(dynamic, net_chunk_size)
      line 241  for (auto* network : _topology_manager->get_network_list()) {
      line 417      _pin_grad_x_list[node->get_node_id()] = a * (pin_grad_min_x - pin_grad_max_x);
      line 436      _pin_grad_x_list[node->get_node_id()] += rep_x * dx / dist;      // ce7 only
      line 531  float pin_gradient_x = _pin_grad_x_list[node->get_node_id()] * net_weight;

The loop is parallel over **nets**, the storage is indexed by **pin**, and a pin belongs to several nets.
So several iterations write the same slot concurrently. Line 417 is an assignment, so whichever thread
writes last wins; line 436 accumulates, which is a plain data race. The value therefore depends on how
the work was distributed and interleaved - and with schedule(dynamic) that follows machine load.

**This explains the thread-count-dependent variation of round 67 and why the unmodified tree escapes it.**
The unmodified tree never routes during placement, so nothing raises the process-wide thread count;
every one of these regions stays at the caller's setting and the race has a single writer. Raising the
count (round 67's 128) or leaving it at the machine default exposes a race that was always there.

**It does NOT explain everything, and the residue is stated here rather than smoothed over.**
gcd_sky130_a already ships PL.num_threads=1 and was run with OMP_NUM_THREADS=1, so every one of these
regions had a single thread and the race cannot fire - yet it produced union 1994 / max 36 in one
session and union 1976 / max 26 in another. So there is at least one further source of run-to-run
variation that one thread does not remove, most plausibly iteration over a pointer-keyed container
whose order varies per process, or uninitialised memory. That source is **not identified**, and it is
why this round does not claim a deterministic placer.

**It is a defect in its own right, independent of this campaign**: iEDA's placement result depends on
how many cores the host has and on what else is running, which makes regression testing and any
A/B comparison of placer changes unsound.

## 4. Next round, in order

1. **Fix the race so the placer is deterministic.** Accumulate per-pin contributions without a race -
   per-thread partials reduced in a fixed order, or a per-pin atomic/scoped accumulation - then verify
   with repeated runs at several thread counts, several concurrency patterns, and on a loaded machine.
2. Re-run the 15-design standing with a placer whose output is a function of its inputs.
3. Then, and only then, re-adjudicate SR-11 and SR-21 - the only two changes in the tree - and resume
   work on the objective. Until step 1 lands, any pass-count change cannot be attributed.

## 5. State

- **In the tree**: SR-10, SR-11, SR-21, plus the round-67 determinism fix. Binaries: iEDA-base c9761dc9,
  iEDA-ctl16 f9581627, iEDA-sr21 62f55d58, **iEDA-det2 74899997**.
- **Standing**: 4/15 (above), measured one flow at a time.
- **Ruler**: sound - reproducible across two full passes and insensitive to thread count.
- New artifact: runs/sweep_det2ser.json.
