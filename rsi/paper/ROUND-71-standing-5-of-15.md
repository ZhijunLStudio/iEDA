# Round 71: the standing is 5/15, and the design the campaign claimed is now reproducible

## 1. Headline

Two complete 15-design passes with the fixed binary, one flow at a time, OMP_NUM_THREADS=1, shipped
placer config, scored by the ruler against the fixed reference:

    pass 1: 5/15        pass 2: 5/15        14 of 15 designs byte-identical between the passes

**The objective's baseline moves from 4/15 to 5/15.** The design that moved is `gcd_ics55_a`:

| dimension | our | reference | ratio |
|---|---|---|---|
| hpwl | 4089282 | 4336162 | **0.9431** |
| total overflow (union) | 16 | 20 | **0.8000** |
| peak overflow (max) | 2 | 6 | **0.3333** |

0.80 is precisely the value the campaign recorded for SR-21 on this design ("union 1.85 to 0.80, a
failing design to a passing one"), which rounds 66-70 could not reproduce and which round 66 recorded
as an open question. **It reproduces now, deterministically, and it is the same number.**

## 2. Why it moved, and why that is the honest attribution

The change that moved it is not an algorithmic one. It is round 70's fix: the in-process trial route
writes one `overflow_map_<layer>.csv` per routing layer into a directory that is reused for every
measurement and was never cleared, and the evaluator reads those files back to build the congestion
numbers. A layer file left by an earlier measurement was therefore read as though it described the
current placement.

The consequence was not merely noisy measurement - it was **wrong decisions**. The guard that decides
whether detail placement is kept compares the measured peak and total; fed a stale map it saw the wrong
totals (the same input placement reported as total 35 -> 27 in one run and 35 -> 22 in another) and
sometimes kept a placement it should have rejected. With the directory cleared, the measurement is a
function of the placement and the guard decides correctly:

| binary | gcd_ics55_a | union | verdict |
|---|---|---|---|
| iEDA-base (unmodified) | b7603486 | 37 | fail (37 > 20) |
| iEDA-det2 (thread fix, stale maps) | 7ce5837d, and 80882c81 in another setting | 37, and 17 | fail, or pass by luck |
| **iEDA-det3 (maps cleared)** | **5a996196** | **16** | **pass** |

So the improvement is attributable to **the modified tree with a correct measurement**: the guard is the
thing that produces the better placement, and it could only do so once it was measuring what it thought
it was measuring. The unmodified tree has no guard and no in-flight measurement, which is why its
2/15 is unaffected by this fix.

## 3. Reproducibility, measured properly

| check | result |
|---|---|
| two complete passes | pass counts equal; **14 of 15 designs byte-identical** (value and DEF) |
| the one design that differs | `s38584_ics55_a`: union 3296 vs 3244 (both fail; verdict unchanged) |
| gcd_ics55_a, 4 repeats, shipped config (num_threads=16) | 5a996196 x4 - identical |
| gcd_ics55_a, 4 repeats, config pinned to num_threads=1 | 5a996196 x4 - identical |

`s38584_ics55_a` is one of the four ics55 designs whose shipped config is `num_threads=16`, and those
regions use `schedule(dynamic)`, so the reduction order follows machine load. **The residual
irreproducibility is confined to the parallel-thread-count setting, and the verdicts are stable anyway.**

## 4. The standing

| design | hpwl | union | max | fails |
|---|---|---|---|---|
| **gcd_ics55_a** | **0.9431** | **0.8000** | **0.3333** | - |
| apb4_timer | 0.8717 | 0.9310 | 1.0000 | - |
| gcd_nangate45_a | 0.8879 | 1.0000 | 1.0000 | - |
| s1238_ics55_a | 0.8289 | 0.5226 | 0.4286 | - |
| s1238_nangate45_a | 0.7489 | 1.0000 | 1.0000 | - |
| aes | 0.7324 | 1.3611 | 1.7778 | union,max |
| gcd_sky130_a | 1.1325 | 2.2256 | 1.2727 | hpwl,union,max |
| picorv32 | 0.8081 | 1.4525 | 1.6111 | union,max |
| s1238 | 0.7613 | 1.1505 | 1.4286 | union,max |
| s1238_sky130_a | 1.0776 | 2.0525 | 1.8571 | hpwl,union,max |
| s38584_ics55_a | 0.9695 | 1.1843 | 1.6000 | union,max |
| s38584_nangate45_a | 0.9590 | 1.5000 | 1.0000 | union |
| s5378_sky130_b | 0.8962 | 1.5461 | 1.2727 | union,max |
| salsa20_ics55_a | 0.9448 | 0.7851 | 1.2286 | max |
| salsa20_nangate45_a | 0.9414 | 1.8862 | 1.7143 | union,max |

Five designs pass; the failing pattern is unchanged (ten fail congestion, and only two fail wirelength -
the two whose global placement hit the 2000-iteration cap).

## 5. What this does and does not establish

**Establishes:** the modified tree, with the measurement defect fixed, passes 5 of 15 designs against
the legalised commercial reference on all three measurable dimensions, up from 4; the pass is
reproducible within a batch and across two consecutive batches; and the campaign's most-cited single
result was real rather than an artifact - it was unreproducible because the measurement it depended on
was reading another measurement's files.

**Does not establish:** multi-seed confirmation. Both passes used seed 1000. The objective requires
paired multi-seed measurement before a change is accepted, and a single design turning over on one seed
is exactly the kind of evidence the campaign's own rules say not to accept. The next round must repeat
this at seeds 1001-1003 and confirm the pass survives.

## 6. State

- **In the tree**: SR-10, SR-11, SR-21, the round-67 thread-pin fix, the round-70 measurement-directory
  fix. **iEDA-det3 = 83ee2f75** is the current build.
- **Standing**: 5/15 (this round, two passes).
- **Artifacts**: runs/sweep_p1.json, runs/sweep_p2.json, copied to rsi/analysis/out/ for durability.
- **Next**: (1) multi-seed confirmation of the 5/15 and of gcd_ics55_a specifically; (2) attack the
  remaining congestion-only failures, where the cheapest are s38584_nangate45_a (1 bin) and
  salsa20_ics55_a / salsa20_nangate45_a (5 bins each on the peak); (3) resolve the num_threads=16
  residual so the ics55 designs are reproducible at their shipped configuration.
