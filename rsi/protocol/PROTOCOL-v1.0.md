# Pre-registered Protocol v1.0 — The Verifiability Gap

**Project:** ieda-rsi · workspace /home/lizhijun/work/ieda-rsi
**Frozen:** 2026-09-16 · git branch agent-rsi-verifiability · base commit ef2e2d6 (feat/knowledge-mining)
**Rule:** no change to this document after the first data-collection run except as a dated, appended amendment. The grader rejects runs whose protocol hash does not match.

---

## 1. Claim

In a self-modifying system, the achievable rate of self-improvement is bounded by the **fidelity of its verifier**, not by the strength of its proposer. Concretely: when the verifier is a cheap proxy, *believed* improvement rises monotonically while *true* (signoff) improvement is non-monotone and peaks at a finite round r\*. We (a) measure this in a real physical-design stack, (b) give a model that predicts the peak, and (c) give a scheduling method that raises the ceiling under a fixed total budget.

Working title: **The Verifiability Gap: verification strength bounds recursive self-improvement in physical design**.

## 2. Definitions

### 2.1 Self-improvement loop (SIL)
An SIL is a 4-tuple (S, P, V, U):
- **S** state carrier (what persists across rounds: configuration, knowledge base, prompt bundle, tool schema),
- **P** proposer (produces a candidate edit to S),
- **V** verifier (produces the acceptance signal),
- **U** update rule (writes accepted edits back into S).

RSI is the special case where S includes the description of (P, V, U) itself.
In this project: S = GP placement configuration + agent knowledge base; P = simulated annealing over continuous GP knobs AND an LLM agent; V = one of the levels in 2.2; U = write-back of the accepted configuration / knowledge entry.

### 2.2 Verifier levels (cost ladder)
Operational definitions, all measured on the same design and the same candidate DEF.

| Level | Signal | Legalization | Cost (order) |
|---|---|---|---|
| **V0** | GP-internal reported overflow / unlegalized DEF HPWL | none | seconds |
| **V1** | DEF HPWL of the GP+LG+DP result | LG+DP | tens of seconds |
| **V2** | V1 + iRT EGR union/peak (trial route) | LG+DP | minutes |
| **V3** | V2 + iSTA WNS/TNS/hold/freq after CTS | full to CTS | tens of minutes |
| **V4** | V3 + full-flow to GDS and iDRC violation count | full | hours |

### 2.3 Truth
- **T** = the fair-ruler evaluator: legalized HPWL + iRT EGR union/peak + timing, computed by one shared evaluator for every arm (no arm-specific metric code).
- **T\*** = external truth: Innovus 8-dimension reconciliation (hpwl, egr total/max/avg, wns, tns, hold, freq), available for the 33 fully-referenced cases.

### 2.4 Verifier fidelity
- **p(V)** = precision of the verifier: over accepted edits, the fraction whose true objective is non-worse.
- **rho(V)** = Spearman rank correlation between the verifier signal and the true objective over a common candidate pool.

### 2.5 Headline quantities
- **VG_r(V) = Delta Q_V(r) - Delta Q_T(r)** (believed minus true improvement after r rounds).
- **r\*(V) = the smallest r such that for all r' > r, Delta Q_T(r') <= 0** (the round after which true improvement has died). Reported only when the peak is interior to the observed range.

## 3. Model

Let the state have true quality q_r. Each round the proposer draws a candidate edit; the verifier accepts it or not.

Assume:
1. truly beneficial edits yield diminishing true returns g(r), concave and decreasing, g(r) -> 0;
2. truly harmful edits that the verifier accepts cost -c and are **absorbed into the state**, so their damage persists and compounds additively;
3. the verifier accepts a beneficial edit with probability p and a harmful edit with probability f (false accept); p is the precision of accepted edits.

Then
  E[Delta q_true(r)] = p * g(r) - (1 - p) * c * A(r),
where A(r) is the number of absorbed harmful edits, growing without bound in r while g(r) is bounded.

**Proposition 1.** For any p < 1 and concave decreasing g with g -> 0, there is a finite r\* maximizing E[Delta q_true(r)]; moreover dr\*/dp > 0. Consequently, if the verifier's believed signal Q_V does not saturate, VG_r(V) diverges while true quality declines.

**Consequence for testability.** The model predicts (i) a finite interior peak, (ii) ordering of r\* across verifiers following the ordering of p(V) and rho(V), (iii) larger VG for proxies calibrated on a different process. These are the hypotheses below.

Note the difference from multi-fidelity optimization: there, a noisy objective costs you a per-round loss; here the error is written into the improver's own state and amplified by later rounds. That difference is the reason a finite ceiling exists at all.

## 4. Hypotheses

- **H1 (existence).** For weak verifiers (V0, V1), Delta Q_T(r) is non-monotone with a finite interior r\*; VG_r increases with r.
- **H2 (fidelity ordering).** p(V) and rho(V) are non-decreasing from V0 to V4, and r\*(V) increases correspondingly.
- **H3 (process transfer).** r\* is smaller on a PDK other than the one where the proxy was calibrated; the transfer ratio tracks the tool-independent share of the accumulated knowledge.
- **H4 (method).** A verifier-aware schedule (screen at a cheap level, confirm at an expensive level under racing) attains strictly larger Delta Q_T at equal total cost than any fixed-level schedule.
- **H5 (RSI core).** An improver whose own update rule is also updated (A2) attains larger Delta Q_T at equal cost than a frozen improver (A1) at the same verifier level.

## 5. Kill criteria (pre-committed)

1. If no design shows a finite interior r\* at V0 or V1, H1 is falsified. Then the paper becomes a negative result scoped to GP-knob improvement loops, plus the benchmark and protocol contribution.
2. If p(V0) and p(V4) are statistically indistinguishable, the framing is wrong: stop the study and report the null.
3. If H4 fails, drop the method contribution; the paper becomes measurement plus protocol.
4. If the LLM-arm runs cannot be made reproducible within reported variance, the LLM arm is reported as a case study only and all quantitative claims rest on the deterministic improver.

## 6. Arms

| Arm | What is frozen | What changes |
|---|---|---|
| **A0** | everything | nothing (control: no write-back) |
| **A1** | the improver's own code and acceptance rule | S only (configuration, knowledge) |
| **A2** | the task | S and the improver's own update rule |

## 7. Task suite and splits

- Population: 33 cases with complete references (input DEF, placement config, Innovus placed DEF). Two of the 35 registry entries (nangate45_gcd, asap7_aes) reference dead /tmp paths and are excluded; this is recorded, not silently dropped.
- **DEV**: knowledge accrual. **VAL**: accept/reject decisions. **SEALED**: reported numbers only. **OOD**: cross-PDK transfer.
- Isolation rule: if a sealed design name appears in any prompt, knowledge file, or agent context, the sealed set is void and must be re-drawn. This is auditable in the session logs.

## 8. Metrics

VG_r, r\*(V), p(V), rho(V), **NSI** = Delta Q_T / Delta C (net improvement per unit cost, including the amortized cost of generating the improver), **AR** absorption rate (share of distilled knowledge actually executed in a later round, observed behaviorally), **TR** transfer ratio, **CE** coverage entropy, **HIR** human interventions per unit gain, plus per-round cost.

## 9. Cost accounting (mandatory)

Every run appends exactly one JSONL record with:
run_id, design, pdk, arm, round, verifier_level, improver_id, seed, wall_seconds, cpu_seconds, llm_calls, llm_tokens_in, llm_tokens_out, human_minutes, believed metrics, true metrics, accepted, protocol_hash.

A run with no cost record is **invalid and excluded** from every aggregate.

## 10. Anti-self-deception rules

These are written because this project already experienced the failure they prevent (a placement run in which a partially-cleaned workdir plus an unlegalized result produced a six-out-of-six "win" that did not survive clean end-to-end re-execution).

1. Truth is always the shared evaluator or Innovus; never the improver's own acceptance signal.
2. Unlegalized candidates are refused, matching the evaluator's own gate.
3. Each candidate runs in a freshly rebuilt, whole workdir; lineage is recorded.
4. Verifier levels are compared on identical seeds and identical candidate pools (paired design).
5. Sealed designs never enter any agent context.
6. The protocol hash is checked by the runner.
7. No post-hoc metric changes; amendments are dated and appended.
8. Effect sizes and confidence intervals are reported; no cherry-picked designs.

## 11. What we will not claim

- Not that strong (accelerating) RSI has been achieved.
- Not that we beat commercial tools in absolute QoR. The claim is about improvement dynamics.
- Not that the findings generalize beyond the studied loop family without the transfer experiments.
- Not that a monotone believed score implies capability growth.

## 12. Deliverables

1. This protocol (versioned, hashed).
2. The instrumentation: leveled verifier, cost ledger, improver lineage, sealed-split gate.
3. The release dataset of paired (believed, true) round records.
4. The scheduling method and its evaluation.
5. The paper draft with figures and tables.
