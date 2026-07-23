<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 43 · Agent Experiment Runtime 实施方案 · ai1.0

> 新建横向能力。iDB 管对象和快照，Platform 管 stage 执行；Runtime 管 Agent 的候选实验、分支、预算、策略和提交。

## 1. 核心职责

- 将一个目标拆成可审计 experiment；
- fork 多个候选分支并分配 fidelity/预算；
- 调用 Tool Registry，不直接调用内部单例；
- 维护 branch lifecycle、lease 和 conflict；
- 触发 validation policy；
- 选择 Pareto 候选并提交；
- 记录失败恢复阶梯和 decision trace。

## 2. API

| API | 语义 |
|---|---|
| `experiment.create` | 固定 base snapshot、目标、硬约束和预算 |
| `experiment.propose` | 注册候选 delta/生成策略 |
| `experiment.run` | 在隔离分支执行分析/动作/验证 DAG |
| `experiment.status` | progress、incumbent、resource、events |
| `experiment.cancel/resume` | 可恢复控制 |
| `experiment.select` | Pareto/风险/预算下的显式决策 |
| `experiment.commit` | policy 通过后原子提交 |
| `experiment.abandon` | 保留证据，释放 branch |

## 3. 状态机

```text
CREATED → PROPOSING → RUNNING → PARTIAL|EVALUATED
EVALUATED → VALIDATING → REJECTED|READY_TO_COMMIT
READY_TO_COMMIT → COMMITTED
任何运行态 → CANCELLING → CANCELLED
worker failure → RECOVERING → RUNNING|FAILED
```

## 4. LLD

```text
src/platform/agent_runtime/
  ExperimentService.{hh,cc}
  BranchManager.{hh,cc}
  BudgetLedger.{hh,cc}
  CandidatePortfolio.{hh,cc}
  ValidationPolicy.{hh,cc}
  RecoveryPlanner.{hh,cc}
  DecisionTrace.{hh,cc}
```

Runtime 不内置 LLM SDK。Planner 通过接口提交 proposal，确定性 Runtime 校验权限和状态。

## 5. 候选选择

1. 先删硬约束失败候选；
2. 置信区间跨 gate 的候选升 fidelity；
3. 保留非支配候选；
4. 同等 QoR 下选扰动小、证据强、成本低者；
5. 不确定且预算耗尽时返回 Pareto set，不擅自 commit。

## 6. 首个垂直切片

Timing Closure Lab：一个 experiment 以 1 个 post-place snapshot、最多 100 个候选、20 个 F2 分支、5 个 F3 分支为默认预算模板。动作只允许 resize/VT/buffer/local move。

## 7. 里程碑

| 阶段 | 内容 | 门禁 |
|---|---|---|
| AGRT-A0（2 周） | experiment/branch/budget schema | 审计日志可重放 |
| AGRT-A1（3 周） | branch-and-select | 20 分支互不污染 |
| AGRT-A2（3 周） | validation policy/commit | 未过 gate 无提交路径 |
| AGRT-A3（3 周） | cancel/resume/recovery ladder | 故障后不丢 incumbent |
| AGRT-A4（4 周） | region/object leases | 冲突检测 100% 命中构造例 |

## 8. 测试

- 过期 head、重复 commit、预算透支、worker 丢失、事件重放；
- 两候选独立好但冲突时不得自动 merge；
- Agent 试图修改 constraint/rule deck 权限拒绝；
- 分支 artifact 泄漏和租户隔离；
- validation policy 版本变化可重放旧决策。

**H-AGRT-A1**：branch-and-select 已足够释放多 Agent 价值。只有在大量候选确实 spatial/semantic 独立后才实现自动 merge。

---

## 9. Experiment/Candidate 详细 schema

```text
Experiment
  experiment/base/context/policy refs
  goal/objective vector/hard constraints
  allowed capability/action classes
  branch/candidate/global budgets
  state/head/incumbent/portfolio refs

Candidate
  proposal/base/branch/current snapshot refs
  delta/action lineage
  status/fidelity/metric/certificate refs
  resource ledger/actual touched/conflicts
  rejection/escalation/selection reason
```

Experiment 创建后 base/context/policy 不变；变更任一 ref 创建新 experiment。Candidate 的 `READY_TO_COMMIT` 绑定 exact branch head 和 current certificate bundle，head 变化立即 stale。

## 10. Branch、预算和 commit 协议

```text
reserve experiment budget
  -> fork branch from immutable base
  -> acquire object/region/domain leases for apply
  -> execute validated workflow DAG
  -> debit actual resources, release unused reservation
  -> collect metrics/certificates
  -> select exact candidate head
  -> recheck base head/policy/certificate freshness
  -> atomic compare-and-swap commit
  -> publish DecisionRecord and release branches
```

BudgetLedger 采用 reserve/debit/refund，按 candidate 和 capability 记录 wall/CPU/RSS/license/F3/F4 credits。预算透支先 cancel/return partial，不通过负数账本继续。Commit CAS conflict 返回 `STALE_BASE`；Runtime 不自动 rebase 高风险 delta。

## 11. Recovery ladder 与选择

恢复阶梯由 policy 版本化：retry transient read -> restart worker -> downgrade/alternate qualified tool -> expand scope proposal -> full validation -> stop。相同 failure class/输入不重复无限尝试；每步消耗预算并进入 DecisionTrace。

选择过程调用 iEval：删除 hard fail/incomplete commit candidates -> 对 near-gate/uncertain 升级 -> 保留 Pareto -> 按明确 tie-break 选择。若无唯一 winner 或预算尽，返回 frontier；Planner 建议不能覆盖 Runtime 的 certificate/policy 检查。

## 12. CI 与 PR

`AGRT-T01` state transition property，`AGRT-T02` 20 branch 隔离，`AGRT-T03` stale head/CAS，`AGRT-T04` lease overlap/conflict，`AGRT-T05` budget reserve/debit/refund，`AGRT-T06` worker loss/recovery limit，`AGRT-T07` cancel/resume/incumbent，`AGRT-T08` certificate invalidation，`AGRT-T09` Pareto/tie-break，`AGRT-T10` duplicate commit/idempotency，`AGRT-T11` DecisionTrace replay，`AGRT-T12` conflict candidates 不自动 merge。

PR：`AGRT-0 schema/state machine` -> `AGRT-1 branch/budget` -> `AGRT-2 execution/portfolio` -> `AGRT-3 validation/commit CAS` -> `AGRT-4 cancel/recovery` -> `AGRT-5 leases/conflict` -> `AGRT-6 Timing Lab e2e`。

## 13. 持久化模型与服务 API 语义

| Entity | 主键/版本 | 核心字段 |
|---|---|---|
| experiment | experiment_id/revision | base/context/goal/policy/state/budget |
| candidate | candidate_id/revision | proposal/branch/head/status/evidence |
| branch | branch_id/generation | base/head/lease/owner/health |
| budget ledger | experiment_id, sequence | reserve/debit/refund/resource/reason |
| decision trace | decision_id | considered/rejected/selected/policy/evidence |
| recovery action | recovery_id | failure/step/input/output/budget |

API mutating call 接受 `expected_revision` 和 idempotency key。状态转换通过数据库 CAS + append event 原子提交；重复请求返回原 transition。Runtime 重启后从实体状态和 event log 恢复，不依赖 Planner 内存或 worker session。

```text
experiment.create -> CREATED
experiment.propose -> candidate PROPOSED records
experiment.run -> operation_id (asynchronous)
experiment.select -> DecisionRecord, no commit yet
experiment.commit -> exact candidate head CAS
experiment.abandon -> terminal + branch cleanup intent
```

## 14. 生命周期不变量

1. Experiment base/context/policy 创建后 immutable；
2. Candidate branch head 单调演进，所有 delta 有 lineage；
3. `EVALUATED` 只表示有 metric，不表示 certificates/gate；
4. `READY_TO_COMMIT` 要求 exact head 的 current complete bundle 和 PASS gate；
5. Commit 只能发生一次，且主 head expected value 等于 experiment base 或批准 parent；
6. terminal experiment 不创建新 candidate/消耗新 budget；
7. `CORRUPTED_BRANCH` 永远不可 select/reuse；
8. Budget ledger 不能负数，reservation 总量不超 experiment/global quota；
9. rejected/failed/abandoned candidate 的证据保留；
10. Planner/model 建议不能直接修改 state。

这些不变量用 property/state-machine test 在随机事件序列上验证。

## 15. Candidate pipeline 与 Portfolio 实现

```text
register proposals
  -> precondition/context/scope dedup
  -> allocate F0/F1 screening budget
  -> fork/apply selected candidates
  -> collect actual touched and invalidations
  -> run F2 workflows and update Pareto frontier
  -> escalate frontier/near-gate/OOD/high-risk to F3
  -> request Verification bundles
  -> iEval final gate
  -> emit DecisionRecord or verified Pareto set
```

Candidate 去重 key 包含 canonical action parameters、base snapshot 和 target stable IDs；不同生成器产生等价 proposal 时保留 producer list，避免重复分支。Portfolio 始终保存原 metric vector/status/coverage，只有 policy tie-break 产生 deterministic ordering。

选择策略接口：

```cpp
struct ISelectionPolicy {
  SelectionResult select(const CandidatePortfolio&, const PolicyRef&, const BudgetView&);
};
```

首版实现 `HardGateParetoPolicy`，不把 Planner/模型 score 写进 Runtime 核心。返回结果列 considered、hard rejected、incomplete、frontier、tie-break 和 required escalations。

## 16. Lease、冲突与并发

Lease kind 包括 branch write、object set、region/layer 和 high-risk domain（clock/reset/PG/intent）。Acquire 按 canonical resource order，一次原子申请；lease 带 fencing generation。Worker 返回 actual touched 后 Runtime 对照 lease，越域则 validation fail 并隔离 branch。

并行只读允许共享 immutable snapshot/tool session（若工具 qualification 允许）；写 branch 隔离。两个候选即使 scope 无几何重叠，若修改同 net/timing cone/clock domain 仍有 semantic conflict。首版不自动 merge；`state.diff` 仅生成 conflict report。

## 17. RecoveryPlanner 详细阶梯

| Failure class | 可用恢复 | 禁止 |
|---|---|---|
| transient resource/license | bounded retry/backoff/alternate worker | 无限 retry |
| worker crash | restart from durable checkpoint | 复用未知进程状态 |
| timeout with incumbent | return/escalate budget if policy permits | 改成 success |
| unsupported domain | alternate qualified capability/stop | domain 外硬跑 |
| local infeasible | propose scope expansion/action family | 静默解冻 |
| incremental mismatch | full validation/revoke qualification | 放松 tolerance 掩盖 |
| validation fail | reject/store failure | 用软指标抵消 |
| rollback corruption | destroy branch/escalate incident | 继续 experiment |

RecoveryPlanner 不生成领域动作，只选择 manifest/policy 中的恢复 transition。每 failure class/step 有次数和总预算，重复 signature 触发 stop。

## 18. Timing Closure Lab 端到端对象流

```text
Experiment(base post-place snapshot, Timing ECO policy)
  -> 100 Proposal records from iTO/iNO/iPL
  -> 100 F0/F1 records, 20 branches, 5 F3 candidates
  -> each branch: TypedDelta -> legal -> RC -> STA -> certificates
  -> portfolio/gate/DecisionRecord
  -> exact head commit or return frontier
  -> ExperienceCase + Data DecisionSamples for every candidate
```

端到端验收检查对象数量守恒：proposal 数 = terminal candidate dispositions；每 apply candidate 有 delta/branch；每 selection 有完整 considered set；未选择 candidate 仍有拒绝原因；commit 与主 snapshot lineage 一致。

## 19. 完成定义

- 崩溃重启可恢复 experiment/candidate/budget/decision 状态；
- 随机状态机测试无非法 transition、重复 commit、负预算；
- 20+ branch 隔离且越 scope 100% 捕获；
- timeout/cancel/worker loss 不丢最后 verified incumbent；
- incomplete/stale certificate 无任何 commit API 路径；
- selection 可离线重放并得到相同 frontier/decision；
- Timing Lab 所有候选成功和失败都进入 evidence/data lineage。
