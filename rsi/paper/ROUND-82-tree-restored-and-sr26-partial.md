# Round 82: tree restored to the validated configuration, and SR-26's partial result

## 1. State hygiene: the tree now holds the validated change, not an unvalidated candidate

Round 81 left the source at SR-26's budget (cap 6, stagnation stop) while the **validated** result was
SR-25's (cap 2). That is the wrong state: a reader of the tree would find an unmeasured configuration
where a measured one was claimed.

The source is restored to the SR-25 state and rebuilt, and the rebuild reproduces the validated binary
**byte for byte**:

    build/bin/iEDA       c385b257f4b07322b55f26df3a152684
    build/bin/iEDA-sr25  c385b257f4b07322b55f26df3a152684

SR-26 remains available as a saved candidate binary (`iEDA-sr26 = f6f81193`) with its own validation
running, so the candidate is not lost and the tree is not carrying it.

## 2. SR-26's partial result (22 of 60 cells)

**No verdict flips in either direction so far.** The cell values differ from SR-25 by more than expected:

| design | seed | SR-25 | SR-26 | note |
|---|---|---|---|---|
| gcd_sky130_a | 1000 | (800, 16) | (814, 16) | both pass |
| gcd_sky130_a | 1001 | (815, 16) | (794, 16) | both pass |
| gcd_sky130_a | 1003 | (945, 16) | (1004, 19) | both fail; SR-26 worse on both |
| apb4_timer | 1003 | (2137, 16) | (1993, 24) | both fail; SR-26 better union, worse peak |
| gcd_ics55_a | 1003 | (34, 4) | (31, 4) | both fail; SR-26 better |
| aes, gcd_nangate45_a, apb4_timer 1000-1002, gcd_ics55_a 1000-1002 | | identical | | |

**This defeats the structural argument I expected to hold.** SR-26's segment set is a superset of
SR-25's - segments 1 and 2 start from the same states - so under the gate's ordering its chosen best
should be at least as good. It is not, because at this resolution cell values move by ~2% **between runs
of the same binary**, so SR-26's first two segments do not reproduce SR-25's first two. The residual
run-to-run variation is therefore not only a limit on what can be *claimed*; it is also why "more search
cannot be worse" is false here.

**Interim reading: SR-26 costs more and has bought nothing.** The validation continues; the decision to
keep or revert it waits for the full 60 cells, and the acceptance rule is unchanged (primary count up,
nothing regressing).

## 3. Confirmed state carried forward

- **Tree**: SR-25, binary `c385b257` = the configuration validated in round 80.
- **Acceptance result (matched pattern, both arms at 4 flows)**: primary **2/15 -> 4/15**, secondary
  **17/60 -> 24/60**, 7 gains, 0 regressions. The 52-of-52-identical check showed 4 versus 6 flows does
  not move these cells, so round 80's comparison is matched.
- **Running**: SR-26 validation to `runs/seedcells_sr26` under an flock wrapper.
- **Candidates not in the tree**: `iEDA-sr23`, `iEDA-sr24` (both withdrawn), `iEDA-sr26` (running).

## 4. Next

1. Finish SR-26 and decide it by the acceptance rule.
2. Cost: three to six global-placement re-linearisations per placement is the largest practical
   objection to SR-25, and SR-26 makes it worse. Reducing it is worth a round on its own.
3. The six designs that never pass are 1.15x-2.0x away, not bins away; they need a different mechanism
   rather than more of this one.
