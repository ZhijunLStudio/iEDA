# Round 90: the paired sequential verdict is one arm away

## 1. Where the measurement stands

The protocol-correct (one flow at a time) validation is at **42 of 44 SR-26 cells**; the current-tree arm has
not started. The two pending SR-26 cells are `salsa20_ics55_a` seeds 1002 and 1003, and its first two
sequential cells pass:

    salsa20_ics55_a   reference union 53369  max 35
      s1000  (34849, 34)  PASS
      s1001  (35616, 28)  PASS
      s1002  pending
      s1003  pending

so SR-26's sequential primary count resolves to **3 of 15** if those two also pass (the two designs that are
4/4 in both patterns, plus salsa20_ics55_a), against **4 of 15** concurrently. The difference is
`s1238_nangate45_a`, which passes every seed concurrently and fails seed 1003 sequentially.

## 2. What is still missing, and why it decides everything

The objective's acceptance rule is a comparison **between SR-26 and the current tree in one protocol**. The
current-tree sequential arm is 44 cells and has not been run. Until it exists:

- SR-26's sequential count (2 or 3 of 15) has no counterpart to compare against;
- the concurrently-measured "2/15 -> 4/15" is the only paired evidence that exists, and round 89 showed it
  does not transfer to the sequential protocol.

If the current tree is also 3/15 sequentially, then SR-26's improvement is confined to the concurrent
pattern and its accepted status must be withdrawn on the same rule that withdrew SR-23, SR-24 and SR-27. If
the current tree is 2/15 sequentially, SR-26 still improves the count under the correct protocol and the
acceptance stands. **I do not know which, and I will not guess.**

## 3. A useful by-product: the current tree's sequential cost profile

The current tree has no refinement segments, so its arm is much cheaper per cell than SR-26's, which is
itself the cost argument against SR-26 in its present form: SR-26 allows up to six global-placement
re-linearisations per placement, and the sequential protocol pays that in wall time on every cell.

## 4. State

- **Tree**: SR-26, `build/bin/iEDA` = `f6f81193`, unchanged.
- **Running**: sequential validation, SR-26 at 42/44, current tree at 0/44, one flow at a time, exactly one
  iEDA process, wrapper `rsi/harness/run_seq_validation.sh` (restarts if interrupted).
- **New tool**: `rsi/harness/paired_sequential_verdict.py` - reads both sequential arms and prints the
  per-design table, the primary and secondary counts, the gains and regressions, and an accept/reject line
  against the objective's rule. It is the one command that will settle the question.
- **Superseded evidence**: the concurrent-pattern acceptance result (primary 2/15 -> 4/15, secondary
  17/60 -> 26/60, 9 gains, 0 regressions) stands as a measurement of that pattern and is not the protocol's
  number.
- **Objective**: unestablished under the adopted protocol; SR-26 at 3/15 (pending 2 cells) versus a target
  of 15/15, with the comparison arm unmeasured.

## 5. Next

1. Run `paired_sequential_verdict.py` once both arms are complete - that is the acceptance decision.
2. Act on it: keep SR-26 if it improves the sequential count with no regression, withdraw it otherwise,
   with the measured reason recorded either way.
3. Then the five never-passing designs, which fail on both dimensions by 1.21x-3.01x on union and
   1.09x-1.86x on the peak while already winning wirelength by 0.72x-0.94x. Those are a demand-model
   deficit, not a bin-level miss, and more refinement segments will not close them.
