# Round 89: the protocol-correct measurement lowers the count, and the comparison arm is still missing

## 1. What has been measured

The sequential validation (one flow at a time, flock-protected, fresh work directories keyed by output
directory after round 88's fix) has completed **40 of 44 SR-26 cells**; the current-tree arm has not started.
SR-26's per-design result under the sequential protocol, against the same cells measured concurrently:

| design | SEQUENTIAL SR-26 | CONCURRENT SR-26 |
|---|---|---|
| gcd_nangate45_a | PPPP 4/4 | PPPP 4/4 |
| s1238_ics55_a | PPPP 4/4 | PPPP 4/4 |
| **s1238_nangate45_a** | **PPP. 3/4** | **PPPP 4/4** |
| gcd_sky130_a | P.PP 3/4 | PPP. 3/4 |
| s1238_sky130_a | P.P. 2/4 | P... 1/4 |
| gcd_ics55_a | P..P 2/4 | P... 1/4 |
| apb4_timer | ..P. 1/4 | P.P. 2/4 |
| s38584_ics55_a | ...P 1/4 | .PP. 2/4 |
| s38584_nangate45_a | P... 1/4 | P... 1/4 |
| s1238 | .... 0/4 | .... 0/4 |
| salsa20_ics55_a | (4 cells pending) | PPPP 4/4 |

    all-seed designs among the 10 fully measured:   sequential 2   concurrent 4
    passing cells:                                  sequential 21/40  concurrent 26/44

## 2. What this means

**The sequential protocol gives a lower count than the concurrent one, not a higher.** Four cells flip
verdict, in both directions, but the net is four fewer passing cells and **two fewer all-seed designs**:

- **s1238_nangate45_a is 3/4 sequentially** (fails seed 1003) and 4/4 concurrently, so it loses its
  all-seed status - the design round 83 credited SR-26 with taking from 3/4 to 4/4.
- apb4_timer 2/4 -> 1/4 and s38584_ics55_a 2/4 -> 1/4.
- Against that, gcd_ics55_a 1/4 -> 2/4 and s1238_sky130_a 1/4 -> 2/4.

So **the "primary 2/15 -> 4/15" result measured concurrently does not carry over to the sequential
protocol as stated**. The sequential primary count for SR-26 is 2 or 3 of 15, not 4, and the last design
pending (salsa20_ics55_a, 4/4 concurrently) decides which.

**The comparison that matters is not yet available.** The objective is about SR-26 versus the current tree,
and both must be measured in the same protocol. The current-tree sequential arm has 44 cells to go, and its
count is what decides whether SR-26 improves anything under the correct protocol. Concurrently the current
tree is 2/15; if its sequential count is also 2, SR-26's gain may be entirely a property of the concurrent
pattern, which would be a substantial correction to rounds 80-83.

I am not going to state a conclusion before that arm exists. What can be said now:

- **SR-26's cell-level improvement is large and one-sided in the concurrent pattern** (9 gains, 0
  regressions) and **smaller but still one-sided sequentially** (s1238_sky130_a and gcd_ics55_a gain a seed
  each; s1238_nangate45_a, apb4_timer and s38584_ics55_a lose one each). Both patterns show real movement;
  neither shows the current tree winning.
- **The all-seed count is pattern-dependent by one to two designs**, which is the quantity the objective
  asks for. Any acceptance claim needs the paired measurement, exactly as round 72 concluded from the other
  direction.

## 3. Why the earlier rounds did not see this

Rounds 80-83 ran their validations at four flows in flight. Round 76 adopted one-flow-at-a-time and round
86 showed a cell can flip between them; round 88 showed my "sequential confirmation" had silently reused
the concurrent placements. So until now every acceptance number in this campaign came from the concurrent
pattern, and the protocol-correct numbers were never actually taken. They are now, and they are lower.

## 4. State

- **Tree**: SR-26, `build/bin/iEDA` = `f6f81193`, unchanged.
- **Running**: sequential validation, SR-26 at 40/44, current tree at 0/44, one flow at a time, wrapper
  `rsi/harness/run_seq_validation.sh`, records in `runs/seedcells_seq_sr26` and `runs/seedcells_seq_cur`.
- **Acceptance evidence**: concurrent pattern only (primary 2/15 -> 4/15, secondary 17/60 -> 26/60, 9
  gains, 0 regressions). Under the sequential protocol SR-26 is 2/10 all-seed against 4/10 concurrent, so
  that evidence does not transfer and the paired sequential comparison is required.
- **Objective**: not established under the adopted protocol; the strict sequential count for SR-26 is 2 or
  3 of 15 with one design pending, and the current-tree arm is unmeasured.

## 5. Next

1. Finish the sequential arms for both binaries and compute the paired sequential counts. That is the
   measurement every acceptance decision needs, and it is the only thing that can settle whether SR-26
   improves the objective at all.
2. If the paired sequential counts tie, SR-26's accepted status must be withdrawn on the same rule that
   withdrew SR-23/24/27 - and the round-86 cell-level flips would then be a property of the pattern rather
   than of the change, which would be worth understanding before attacking the five never-passing designs.
