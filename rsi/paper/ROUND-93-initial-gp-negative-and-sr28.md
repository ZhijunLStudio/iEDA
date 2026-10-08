# Round 93: the initial-GP congestion variant is a clean negative, and SR-28 tests the cheap refinement

## 1. The measurement that closes a direction

The five never-passing designs fail on both congestion dimensions (union 1.21x-3.01x, peak 1.09x-1.86x)
while already winning wirelength by 6-28%. SR-26 applies congestion effort 4 on the **finishing** passes.
The untried variant was effort 4 on the **initial** global placement. Measured, one flow at a time, same
seed, via a flock-protected wrapper:

| design | initial GP effort 0 | initial GP effort 4 | reference | verdict |
|---|---|---|---|---|
| s5378_sky130_b | union 3675 (1.518x), peak 26 (1.182x) | union 3935 (**1.625x**), peak 28 (**1.273x**) | 2421 / 22 | **worse on both** |
| s1238 | union 1726 (1.124x), peak 30 (1.071x) | union 1815 (**1.182x**), peak 30 (1.071x) | 1535 / 28 | **worse on union, peak tied** |

**Steering the whole global placement with the congestion term makes both designs worse.** Cost was 36 s
and 41 s for both arms, so on these designs the variant is *not* expensive - it is simply ineffective. That
also corrects round 41's expectation that effort 4 necessarily costs tens of minutes: it does not, on
designs of this size, because the congestion term only engages once density overflow drops below its gate.

**Direction closed.** No further work on initial-GP congestion effort, and no identified mechanism left that
targets the never-passing designs' magnitude. They fail by 21-201% on union; nothing measured in this
campaign moves them.

## 2. The mechanism picture is now sharp, and it is a measured statement rather than a guess

    congestion-steered GP as a whole-run objective      -> worse (this round, and round 41's exclusion)
    congestion-steered GP as a bounded gated refinement -> better (SR-26, +1 all-seed design)
    a cheap non-steered refinement                      -> under test (SR-28)

The first two are both measured in this campaign under the protocol-correct setting for the second. The
shape that works is bounded and gated; the shape that fails is unbounded and steering. That is a more
precise finding than either experiment alone.

## 3. SR-28: the cheap half of the refinement, under the same gate

Every SR-26 segment re-linearises under the congestion term, so every candidate the gate can choose is
congestion-steered. SR-28 keeps the same structure but re-linearises the **last third of the budget at the
default effort (0)** - a plain re-linearise followed by legalisation and detail placement, which is the
"run the pair again" shape the campaign's earliest multi-pass evidence favoured, at the cheap end because
effort 0 does not call the evaluator inside the Nesterov loop.

    segments 1-4 of 6 : effort 4   (as SR-26)
    segments 5-6 of 6 : effort 0   (new)

**The gate's guarantee is unchanged**: a segment is chosen only if it is no worse than the entry on either
scored number and better on at least one. Adding candidates therefore cannot make the result worse than the
entry state on the scored numbers; it can only fail to help.

Execution verified from its own log before any effect is read:

    [SR-28] segment 1/6 effort 4: peak 18 total 826 | best is segment 1
    [SR-28] segment 2/6 effort 4: peak 16 total 907 | best is segment 2
    [SR-28] segment 3/6 effort 4: peak 20 total 873 | best is segment 2
    [SR-28] segment 4/6 effort 4: peak 20 total 906 | best is segment 2
    [SR-28] segment 5/6 effort 0: peak 20 total 745 | best is segment 2

and on another cell the steered segments reached peak 14 (reference 22) before an effort-0 segment at
peak 20 was correctly not chosen. So the schedule runs, and the gate still decides on the numbers.

Built as **iEDA-sr28 = 48cd5be3**. The 44-cell sequential validation is running under an flock wrapper,
reusing the round-91 current-tree arm so the comparison is paired in one protocol.

## 4. State

- **Tree**: SR-26, `build/bin/iEDA` = `f6f81193` (SR-28 is a saved candidate, not in the tree until it
  earns acceptance).
- **Accepted result (unchanged, paired and sequential)**: primary **2/15 -> 3/15**, secondary
  **15/44 -> 25/44**, 0 design-level regressions.
- **Running**: SR-28 sequential validation, 44 cells, `runs/seedcells_seq_sr28`, wrapper
  `rsi/harness/run_sr28_validation.sh`.
- **Closed**: initial-GP congestion effort (this round).
- **Objective**: 3/15 against 15/15, with three rounds left.

## 5. Next

1. Read the SR-28 validation and decide it on the same rule used for SR-26: primary count up, no design
   regression. If it ties, it is withdrawn on the same rule that withdrew SR-23/24/27.
2. If it helps, the cost question is already answered for these designs - an effort-0 segment is a plain
   GP re-linearise, an order of magnitude cheaper than the effort-4 segments.
3. If it does not help, the remaining rounds are best spent recording the state of the objective honestly
   rather than starting a new mechanism with two rounds of measurement left.
