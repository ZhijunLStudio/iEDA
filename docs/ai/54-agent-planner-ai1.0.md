<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 54 · Agent Planner、Critic 与停止策略实施方案 · ai1.0

> 当前成熟度：`D0/DRAFT`。`43` 明确 Runtime 不内置 LLM SDK；当前仓库未见独立 Planner。  
> 职责：把用户目标编译为可验证、受预算约束的计划并生成 proposal；不直接写设计、不执行未注册工具、不决定验证真值。

## 1. Planner 与 Runtime 的边界

Planner 是可替换的决策层，Runtime 是确定性执行/事务层：

| Planner | Runtime |
|---|---|
| 解释 GoalSpec、选能力、形成 plan/proposal | 验 schema/权限/状态，运行 DAG |
| 根据证据修改搜索策略 | fork/lease/budget/cancel/recovery |
| 建议升级 fidelity 或停止 | 执行 router/policy，拒绝越权 |
| 对候选给决策理由 | 根据证书和 policy commit |

没有 Planner 也必须能用固定规则/搜索 baseline 完成 Timing Lab；LLM 不是架构前置依赖。

## 2. API

```text
planner.compile_goal(goal, intent_ref, policy_ref)
planner.create_plan(goal_spec, capability_snapshot, budget)
planner.propose(plan_id, observation_refs)
planner.critique(plan_id, execution_evidence)
planner.revise(plan_id, critique, remaining_budget)
planner.decide_fidelity(candidate_set, router_advice)
planner.should_stop(plan_id, portfolio, remaining_budget)
planner.explain_decision(decision_id)
```

每次输出先经过 deterministic `PlanValidator`，再交 Runtime；自然语言解释不是可执行计划。

## 3. Schema

```text
GoalSpec
  base_snapshot, intent/scenario/tech/policy refs
  objectives[]                 # metric + direction，不是单总分
  hard_constraints[]
  allowed_action_classes[]
  protected_scope
  budget, deadline, risk_tolerance
  completion_criteria

PlanGraph
  nodes: Observe | Diagnose | Propose | Branch | Apply | Verify | Select | Stop
  edges: data/control dependencies
  capability name/version/query
  inputs from typed refs
  expected outputs and failure branches
  per-node budget/retry/fidelity
```

PlanGraph 不允许嵌入 shell、Tcl、Python 源码或未知工具名。动态生成工具只能引用 quarantine package ID，并由 Runtime 单独鉴权。

## 4. 首批策略

### 4.1 确定性 baseline

Timing ECO 使用显式状态机：audit → top path → root cause → enumerate allowed actions → rank → branch Top-N → verify → Pareto select/stop。先以规则、beam search、bandit/BO 等可重放策略建立基线，再测 LLM planner 是否降低 regret 或工具调用数。

### 4.2 Critic

Critic 只基于结构化 evidence 检查：

- plan 是否缺 required validator；
- proposal 是否违反 protected scope/intent；
- 连续失败是否来自同一 unsupported domain；
- 模型是否 OOD 或在 gate 附近高不确定；
- action 是否重复、互相抵消或预算价值低；
- 终止条件是否满足，剩余风险是否被明确报告。

Planner 与 Critic 可用不同模型或规则，但二者一致不构成物理真值。

## 5. 有界恢复与停止

```text
per candidate: retry_same_tool <= 1
per failure class: recovery_ladder steps <= policy limit
per plan: max nodes/branches/tool calls/wall/license credits
no measurable progress for N verified actions → stop or widen scope once
required claim UNKNOWN with no available validator → stop UNSUPPORTED
budget exhausted → return verified Pareto/incumbent + residual, never auto-commit partial
```

停止原因必须是枚举值：`GOAL_MET`、`PARETO_STABLE`、`BUDGET_EXHAUSTED`、`INFEASIBLE`、`UNSUPPORTED`、`RISK_TOO_HIGH`、`USER_CANCELLED`。

## 6. Capability Discovery

Planner 只看到 Gateway 发布的 capability snapshot：版本、maturity、domain、fidelity、cost model、permissions、required validators。计划执行前 Runtime 再校验一次，处理 tool retired/version drift。文档中的 API 名不能直接视为 capability。

## 7. LLD 与源码落点

```text
src/planner/
  api/PlannerService.{hh,cc}
  schema/{GoalSpec,PlanGraph,Decision}.hh
  validation/PlanValidator.cc
  strategy/{RuleBased,BeamSearch,Portfolio,ModelBacked}.cc
  critic/{Safety,Progress,Evidence,Coverage}Critic.cc
  policy/{Retry,Recovery,Stop}Policy.cc
  trace/PlannerTrace.cc
```

模型调用通过 `45 Model Router`，经验检索通过 `56`，设计观察通过 `44`；Planner 不直接读取任意文件/report，也不链接 operation singleton。

## 8. 安全与失败语义

| 风险 | 确定性防线 |
|---|---|
| 幻觉工具/参数 | capability/schema validation |
| 通过改 SDC 改善 WNS | GoalSpec 固定 IntentRef；R4 独立流 |
| 无限反思/重试 | node/call/retry/budget hard limit |
| 越 scope 动作 | Runtime lease + frozen certificate |
| prompt/report injection | 结构化 adapter；外部文本标 untrusted data |
| 选择 partial/unknown 候选 | Verification bundle policy |
| 泄漏客户案例 | Experience tenant/family ACL |

Planner 异常只使 plan 失败，不能使 branch 自动 commit。输出无法校验时返回 `INVALID_PLAN` 并保存 trace。

## 9. 里程碑

| 阶段 | 交付 | 退出门禁 |
|---|---|---|
| PLAN-A0（2 周） | GoalSpec/PlanGraph/validator | 未知能力、无界循环、缺 validator 全拒绝 |
| PLAN-A1（3 周） | Timing ECO rule baseline | 10 cases 可重放，零 LLM 依赖 |
| PLAN-A2（3 周） | critic/recovery/stop | 故障注入无无限重试/越权 |
| PLAN-A3（4 周） | model-backed proposal/rank | held-out regret 优于或不差 baseline |
| PLAN-A4（4 周） | experience-guided planning | 同预算 accepted-action rate 有统计改善 |
| PLAN-A5（后续） | planner/critic 多角色 | 仅在成本收益证据后启用 |

## 10. 测试与可杀假说

- property：随机 capability registry 下生成 plan 必须 schema/依赖闭合；
- adversarial：提示要求改 SDC、跳 DRC、执行 shell、复用旧证书；
- failure：timeout/OOM/unsupported/partial/worker loss/empty candidates；
- benchmark：规则、单模型、planner+critic 同预算比较成功率、regret、调用成本；
- replay：固定 model/tool/data/seed 时决策 trace 可重放，非确定模型保存完整 response hash。

**H-PLAN-A1**：Planner 相对确定性 baseline 在相同 F3/F4 预算下提升 accepted-action rate 或降低 selection regret。若不成立，保留规则/搜索 planner，LLM 只用于解释和 proposal 草拟。

## 11. 不做

- 不让 LLM 直接 commit；
- 不将 chain-of-thought 作为验证证据；
- 不允许自由代码/命令成为普通 PlanNode；
- 不以多 Agent 讨论一致代替 validator；
- 不在首版自动 merge 分支；
- 不把 Planner 与 Runtime/Tool Registry 合成不可替换单体。

