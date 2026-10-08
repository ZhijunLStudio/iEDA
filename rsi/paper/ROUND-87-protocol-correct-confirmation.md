# Round 87: the protocol-correct measurement confirms the result

## 1. The measurement

Rounds 80-83 validations ran four flows at a time while claiming the one-flow-at-a-time protocol adopted in
round 76, and round 86 showed that deviation flips individual cells. The measurement has now been re-taken
properly: **one flow at a time**, nothing else on the machine, both arms, four seeds, the eleven designs
that pass at least one seed in some arm (the five that never pass cannot move the count). 44 cells per arm,
flock-protected single instance, verified as exactly one iEDA process throughout.

## 2. The result - and it is the same result

| design | current tree (seq) | SR-26 (seq) |
|---|---|---|
| gcd_nangate45_a | PPPP 4/4 | PPPP 4/4 |
| s1238_ics55_a | PPPP 4/4 | PPPP 4/4 |
| **s1238_nangate45_a** | PPP. 3/4 | **PPPP 4/4** |
| **salsa20_ics55_a** | .PPP 3/4 | **PPPP 4/4** |
| gcd_sky130_a | .P.. 1/4 | PPP. 3/4 |
| apb4_timer | P... 1/4 | P.P. 2/4 |
| s38584_ics55_a | .... 0/4 | .PP. 2/4 |
| s38584_nangate45_a | .... 0/4 | P... 1/4 |
| s1238_sky130_a | .... 0/4 | P... 1/4 |
| gcd_ics55_a | P... 1/4 | P... 1/4 |
| s1238 | .... 0/4 | .... 0/4 |

    primary (every seed)       current 2/15  ->  SR-26 4/15
    passing cells (of 44)      current 17/44 ->  SR-26 26/44
    gains 9    regressions 0

**Identical to the concurrent-pattern validation in every headline number**: same primary count (2 -> 4),
same number of gains (9), same zero regressions, same four all-seed designs. The gains are the same nine
cells, and the one cell that differed between patterns (gcd_sky130_a seed 1003) fails sequentially and
passes concurrently - so gcd_sky130_a is 3/4 under both, with a different missing seed.

## 3. What that means

**The conclusion is robust to the protocol deviation even though individual cells are not.** Round 86's
worry - that the primary count carried about one design of uncertainty - is not borne out: both patterns
return 4/15. The reason is that the pattern moves *which* seed fails on a near-miss design, not whether a
design is an all-seed pass. The per-seed verdicts are pattern-dependent; the count is not.

This is the right shape for the objective, which is a per-design conjunction: a count that survives a
protocol change is meaningful, whereas a count that moved with it would not have been.

Round 83's acceptance decision therefore stands on two independent measurements in different co-run
patterns, and the objective's requirement - same batch, one ruler, multi-seed paired, pass count up and
nothing regressing - is satisfied under the stricter of the two.

## 4. State

- **Tree**: SR-26, `build/bin/iEDA` = `f6f81193`.
- **Acceptance result, twice measured**: primary **2/15 -> 4/15**, secondary **17/44 -> 26/44** on the
  candidate designs (or 17/60 -> 26/60 over all fifteen, with the five never-passing designs unchanged),
  9 gains, 0 regressions.
- **Evidence**: `runs/seedcells_seq_cur`, `runs/seedcells_seq_sr26` (44 each, one flow at a time);
  `runs/seedcells_cur4`, `seedcells_sr25`, `seedcells_sr26`, `seedcells_sr27` (concurrent, kept for
  comparison). Comparison script `/tmp/seq_cmp.py` logic is in the round record.
- **Objective**: 4/15 confirmed against a target of 15/15.

## 5. What is left, in order of expected value

1. **The five designs that never pass** (aes, picorv32, s1238, s5378_sky130_b, salsa20_nangate45_a) fail by
   1.15x-2.0x, not by bins. More of the same refinement will not close that; they need a different
   mechanism aimed at the demand model itself.
2. **Cost.** SR-26 allows up to six global-placement re-linearisations per placement. This is now the
   largest practical objection to the change, and it is what makes the protocol-correct measurement slow
   enough to matter operationally.
3. **gcd_sky130_a is one seed short under either pattern but a different seed in each**, and
   s38584_ics55_a is two short. Neither is a cell-level target any more; both need a change that makes the
   near-miss cells stable.
