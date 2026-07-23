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
