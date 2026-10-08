# PL RSI research snapshot

This branch contains a research harness and changes to the placement solver. **It is not a DSH plugin or a demonstrated general-purpose recursive self-improver.** It uses the Agent PL foundation in the parent branch.

## Current entry points

| Phase | Source | Scope |
| --- | --- | --- |
| Verifiability study | `fb5c3cc8` | Effects of verifier depth on configuration-search decisions |
| Source-refinement campaign | `04e26de9` | Source edits and paired placement/congestion measurements |

The retained solver is **SR-28**. `paper/ROUND-96-sr28-accepted.md` is its latest acceptance record. `paper/FINAL-STATE.md` predates final SR-28 acceptance and includes the earlier SR-26 standing.

- `harness/`: full experiment source, including historical and withdrawn experiments.
- `analysis/*.py`: analysis programs; `analysis/out/` retains compact frozen verifier-study results.
- `evidence/sr28/`: 132 frozen cell records, 44 for each of cur, SR-26 and SR-28.
- `protocol/`: unchanged original protocol and amendment hashes.
- `paper/`: draft sources, figures, correction records and round history.
- The source refinement changes 11 C++/header files under `src/`, plus the `gp_agent.py` wrapper; see the snapshot manifest.

## Checks without a solver, PDK or API account

From the repository root with Python 3.10 or newer:

```bash
python3 rsi/analysis/number_audit.py
python3 rsi/harness/paired_sequential_verdict.py \
  --runs-root rsi/evidence/sr28/runs --arms cur,sr26,sr28 --subject sr28
```

The audit checks **45 frozen numeric expectations**, not comparison fairness or the paper's interpretation. Replay reproduces **15/44 -> 26/44** passing cells and **2/11 -> 3/11** all-seed designs in the exported subset.

These 11 candidate designs were selected from a 15-design campaign. Historical reports use a 15-design primary denominator; this export covers only 11. It is not a new run or a complete 15-design evaluation. Pass/fail covers HPWL, total overflow and peak overflow, not timing or full PPA. Binary identities are recorded in `evidence/sr28/manifest.json`.

## Running new experiments

Historical runners expect `<RSI_ROOT>/ieda/` for the checkout, `<RSI_ROOT>/assets/` for external inputs, and `<RSI_ROOT>/runs/` for live outputs. Set `RSI_ROOT`, supply `harness/designs.local.json`, and build the solver arms required by each runner. Saved names such as `iEDA-det3`, `iEDA-base`, `iEDA-sr26` and `iEDA-sr28` are **not automatically supplied by a fresh build**; consult each arm's round record.

Physical comparisons need the existing flock wrapper, sequential execution and controlled threads. Older launchers and comments describe historical protocols. Shared paths now default to this checkout's location, rather than the original home directory.

Live runs, solver binaries, commercial references, the large analysis-output history and the compiled draft PDF are excluded. The original workspace retains them. No congestion acceptance or rollback policy is changed during packaging.

## Limitations carried forward

- SR-28 ranks peak overflow first, total overflow second. Total overflow can increase when peak decreases; older promises of no degradation on both metrics do not match the code.
- Refinement snapshots save shapes but not orientations; complete rollback still needs validation.
- A detail-placement call also runs gated finishing and GP refinement; its stage/cost boundary is broader than its name.
- Repeated source selection used the target designs. Equal-budget controls and independent held-out algorithm validation remain necessary.
- `paper/CORRECTION-anchoring.md`, `ROUND-7-netlist-integrity.md` and `ROUND-28-protocol-correction.md` supersede some commercial-reference claims.
- The draft's `r*` definition differs from the finite-window argmax in `analysis/dynamics_replay.py`.

The old draft is research history, not a submission-ready paper. The original study README below is preserved for context; the current scope and caveats above take precedence.

---

# Original verifier-study README (historical)

This directory contains the instrument, the experiments and the analyses behind the
paper *The Verifiability Gap: Evaluation Depth Bounds Self-Improvement in Physical
Design*. It is self-contained except for the iEDA checkout it lives in and the input
data, which is not in git (see Data below).

Everything here was produced under a pre-registered protocol with a frozen hash and a
dated amendment trail, because the study's own subject is the failure mode of trusting
a signal you have not checked.

## Layout

| path | what it is |
|---|---|
| protocol/PROTOCOL-v1.0.md | the pre-registration: claim, definitions, hypotheses, metrics, splits, kill criteria |
| protocol/PROTOCOL-v1.0.sha256 | the hash the runner verifies before every run |
| protocol/AMENDMENT-A*.md | seven dated amendments, each recording a defect found and fixed |
| harness/rsi_lib.py | cost ledger, stable seeding, solver fingerprint, provenance |
| harness/verify.py | the leveled verifier verify(V0..V4) and the shared truth ruler |
| harness/timing_rung.py + tcl/timing_eval.tcl | placement timing (HPWL-RC model) for one DEF |
| harness/signoff_rung.py + tcl/signoff_stage.tcl | placed DEF through CTS, routing, DRC |
| harness/splits.py + splits.json | dev / val / sealed / ood splits and the sealed-context gate |
| harness/stage1_pool.py | the candidate pool: a knob grid per design, scored by every rung |
| harness/stage2_loop.py | the live adaptive loops, one per rung, with a race-free cache |
| harness/stage1_timing.py | adds the timing rung to every pooled candidate |
| harness/stage3_arms.py | the A0 / A1 / A2 arm runner |
| harness/prune_runs.py | removes heavy intermediates from finished candidates only |
| analysis/*.py | one script per result; each prints the numbers in the paper |
| analysis/out/ | the analysis outputs, including the frozen JSON behind each figure |
| paper/RESULTS.md | every headline number, the script that produces it, its status |
| paper/DRAFT-v0.1.md | the paper in markdown, with FINAL and PENDING labels |
| paper/main.tex, main.pdf | the submission draft (14 pages, 11 figures) |
| paper/figures/ | the figures, regenerable from the analyses |

## Data (not in git)

The experiments read from and write to two trees outside the repository, because they
are large working data rather than source:

| tree | contents |
|---|---|
| assets/ | read-only inputs: the case roots (input DEFs and configs), commercial reference DEFs, the migrated knowledge and mining artifacts |
| runs/ | the ledger and the candidate work directories |

The ledger runs/v2/ledger.jsonl is append-only; every record carries the protocol hash,
the improver identity that requested it and the per-stage cost that rung used. A record
whose cost components are missing never replaces one that has them.

## Reproducing the reported numbers

    cd <this checkout>
    A=ieda/rsi/analysis          # if you are at the repository root, this is rsi/analysis
    /usr/bin/python3 $A/fidelity.py          --root runs/v2   # rung fidelity (Section 5)
    /usr/bin/python3 $A/timing_fidelity.py   --root runs/v2   # the ruler is a rung too (5.4)
    /usr/bin/python3 $A/dynamics_replay.py   --root runs/v2   # the gap and the horizon (6)
    /usr/bin/python3 $A/mechanism.py         --root runs/v2   # the two model terms measured
    /usr/bin/python3 $A/live_vs_replay.py    --root runs/v2   # live corroboration (6.1)
    /usr/bin/python3 $A/scheduling_pool.py   --root runs/v2 --budgets 100,140,200,280
    /usr/bin/python3 $A/sealed_arms.py       --root runs/v2   # arms by split (7.1)
    /usr/bin/python3 $A/transfer.py          --root runs/v2   # cross-technology (8)
    /usr/bin/python3 $A/anchor_report.py                      # external anchor (8)
    /usr/bin/python3 $A/go_no_go.py          --root runs/v2   # the kill criteria
    /usr/bin/python3 $A/number_audit.py      --root runs/v2   # re-derives every quoted number

Running the experiments themselves needs IEDA_BIN (default build/bin/iEDA) and
RSI_CPUSET, a core set to pin each run to. Pinning matters: without it the solver's
thread pool spins and reports thousands of CPU seconds for seconds of wall time.

## Reproducing from scratch

1. Build iEDA (cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release, then
   cmake --build build --target iEDA).
2. Put the case inputs under assets/ and generate the local design registry
   (harness/designs.local.json maps each design to its case root, input DEF, placement
   config, foundry directory and commercial reference DEF).
3. Draw the candidate pool: harness/stage1_pool.py --designs "<list>" --workers 32.
4. Add the timing rung: harness/stage1_timing.py --root runs/v2.
5. Run the loops: harness/stage2_loop.py --designs "<list>" --rounds 16 --seeds 1000.
6. Run the analyses above.

A measurement is keyed on the candidate and the solver binary, so re-running step 3 or
5 reuses everything valid and recomputes only what is missing; a failure is never
cached.

## The seven amendments, in one line each

- **A1** the low end of the density grid is a plateau (0.45, 0.50, 0.55 give identical
  placements), and the truth had to stop being a weighted sum.
- **A2** two loops could share one candidate work directory and silently corrupt each
  other; fixed with a per-candidate lock.
- **A3** failures were cached as results, turning a transient fault into a permanent hole.
- **A4** tuple-hash seeding made trajectories irreproducible across processes; replaced
  with salt-independent seeding.
- **A5** a candidate whose truth could not be measured could still enter a trajectory.
- **A6** the cache was keyed on the loop's code version, so a code change discarded valid
  measurements; now keyed on the solver binary.
- **A7** the signoff driver had the same concurrency hazard as A2, plus two ordering
  requirements (SDC before DEF cannot resolve a clock port; routing needs init_rt).

Together they are the paper's methodology made concrete: every one of these defects
produced results that looked plausible rather than results that broke.

## Licence

Same licence as the surrounding iEDA tree (Mulan PSL v2).
