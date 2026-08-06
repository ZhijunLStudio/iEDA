54 · Agent Planner、Critic 与停止策略实施方案 · ai1.1

> 当前成熟度：`D0/DRAFT`。`43` 明确 Runtime 不内置 LLM SDK；当前仓库未见独立 Planner。
>
> 职责：把用户目标编译为可验证、受预算约束的计划并生成 proposal；不直接写设计、不执行未注册工具、不决定验证真值。

## 1. Planner 与 Runtime 的边界

Planner 是可替换的决策层，Runtime 是确定性执行/事务层：

| Planner                                   | Runtime                           |
| ----------------------------------------- | --------------------------------- |
| 解释 GoalSpec、选能力、形成 plan/proposal | 验 schema/权限/状态，运行 DAG     |
| 根据证据修改搜索策略                      | fork/lease/budget/cancel/recovery |
| 建议升级 fidelity 或停止                  | 执行 router/policy，拒绝越权      |
| 对候选给决策理由                          | 根据证书和 policy commit          |

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

| 风险                      | 确定性防线                                |
| ------------------------- | ----------------------------------------- |
| 幻觉工具/参数             | capability/schema validation              |
| 通过改 SDC 改善 WNS       | GoalSpec 固定 IntentRef；R4 独立流        |
| 无限反思/重试             | node/call/retry/budget hard limit         |
| 越 scope 动作             | Runtime lease + frozen certificate        |
| prompt/report injection   | 结构化 adapter；外部文本标 untrusted data |
| 选择 partial/unknown 候选 | Verification bundle policy                |
| 泄漏客户案例              | Experience tenant/family ACL              |

Planner 异常只使 plan 失败，不能使 branch 自动 commit。输出无法校验时返回 `INVALID_PLAN` 并保存 trace。

## 9. 里程碑

| 阶段            | 交付                         | 退出门禁                                |
| --------------- | ---------------------------- | --------------------------------------- |
| PLAN-A0（2 周） | GoalSpec/PlanGraph/validator | 未知能力、无界循环、缺 validator 全拒绝 |
| PLAN-A1（3 周） | Timing ECO rule baseline     | 10 cases 可重放，零 LLM 依赖            |
| PLAN-A2（3 周） | critic/recovery/stop         | 故障注入无无限重试/越权                 |
| PLAN-A3（4 周） | model-backed proposal/rank   | held-out regret 优于或不差 baseline     |
| PLAN-A4（4 周） | experience-guided planning   | 同预算 accepted-action rate 有统计改善  |
| PLAN-A5（后续） | planner/critic 多角色        | 仅在成本收益证据后启用                  |

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

## 12. PlanValidator、DecisionRecord 与执行反馈

PlanValidator 分四轮：schema/引用 -> capability/domain/permission -> DAG 数据依赖与 budget upper bound -> mandatory validator/stop/recovery 闭合。Apply node 后必须存在针对其 invalidation set 的 Verify node；Select/Stop 不能消费 partial/unknown 为已通过。动态 revise 只替换未执行子图，已执行 node 和 evidence 不可改写。

```text
PlannerDecision
  decision_id / plan_revision / input evidence refs
  considered actions/capabilities + rejected reasons
  selected proposal/fidelity/stop/recovery action
  expected information gain/cost/risk
  model/rule/experience hashes
  deterministic validation result
```

Runtime 将真实 status/metrics/certificates/budget 回传，Planner 只能基于 refs 生成下一 revision。自然语言 rationale 单独存储，不参与可执行 hash；私有 chain-of-thought 不要求保存，也不能成为证据。

## 13. CI 编号与 PR 依赖

`PLAN-T01` random PlanGraph property，`PLAN-T02` unknown/retired capability，`PLAN-T03` missing validator after delta，`PLAN-T04` budget upper bound/loop，`PLAN-T05` intent/scope/permission attack，`PLAN-T06` partial candidate select，`PLAN-T07` retry/recovery limit，`PLAN-T08` revise executed node，`PLAN-T09` prompt/report injection，`PLAN-T10` deterministic baseline replay，`PLAN-T11` held-out regret/cost A/B，`PLAN-T12` model outage rule fallback。

PR：`PLAN-0 schema/validator` -> `PLAN-1 deterministic Timing ECO baseline` -> `PLAN-2 critic/stop/recovery` -> `PLAN-3 Model Router adapter` -> `PLAN-4 Experience adapter` -> `PLAN-5 model-backed A/B`。前四项完成前不启用自主 LLM plan 执行。

## 14. Goal Compiler 与 Action DSL

自然语言 goal 先生成 `GoalDraft`，再由 deterministic compiler 对照 Intent/Policy/Metric Registry 解析。任何未映射目标、单位、方向、容差或 hard/soft 属性都进入 clarification finding；不得默认为“WNS 越大越好”后直接执行。

```text
Objective
  metric_id + semantic version
  direction = minimize|maximize|target_range
  baseline protocol + aggregation/scenarios
  hard threshold or Pareto objective
  measurement fidelity + acceptance tolerance

ActionSpec
  action_class + typed parameter domain
  preconditions + required context
  declared scope function
  expected invalidation classes
  proposal/apply capability refs
```

Action DSL 只引用 manifest 注册的 typed operation，不能表达任意代码、字符串命令或直接字段写入。Planner 可以收紧参数域和 scope，不能扩大 GoalSpec 的 allowed action、protected scope 或预算。多个目标默认 hard gates + Pareto；只有 GoalSpec 明确提供经审批的 utility function 时才允许标量化，且仍不覆盖 hard gate。

## 15. 确定性 baseline 算法

Timing ECO baseline 使用可重放的 bounded beam：

```text
observe verified incumbent
while budget remains and stop policy is false:
  select top unresolved problem signatures
  enumerate typed actions from allowed domains
  reject precondition/scope/duplicate/tabu violations
  estimate cheap metrics + uncertainty for all proposals
  choose diverse Top-N under branch and fidelity budgets
  branch/apply/evaluate/verify through Runtime
  update verified Pareto portfolio and failure counters
  widen scope or escalate fidelity only by policy
return verified portfolio + stop reason + residual risks
```

候选去重基于 normalized delta + base snapshot，不基于自然语言描述。diversity 至少覆盖 action class、physical/timing region 和 predicted trade-off；防止 Top-N 全是同一 cell 的近似 resize。Tabu 只抑制在相同 context 下有同类 confirmed failure 的动作，不能把历史经验变成永久禁令。

排序采用分层键：hard feasibility risk、expected information gain/decision value、Pareto potential、cost；tie-break 使用稳定 proposal ID。模型分数只能影响层内排序，不能把缺 required context 或超权限候选推入执行。

## 16. Budget Ledger、恢复与停止证明

Budget 在 Runtime 持有权威账本，Planner 使用只读 reservation view：

```text
BudgetAccount
  limits: wall/cpu/rss/gpu/license/tool_calls/model_calls/branches
  reserved + consumed + released by node/candidate/fidelity
  deadline + cancellation state
```

PlanValidator 计算最坏上界；Runtime 在 node 启动前原子 reserve，完成后结算 actual。Planner revision 只能使用 remaining budget，不能通过创建新 plan ID 重置配额。

停止判定保存结构化证据：

- `GOAL_MET`：current complete bundle 下所有 hard completion criteria 通过；
- `PARETO_STABLE`：预注册窗口内无超容差的新 verified non-dominated point；
- `INFEASIBLE`：仅当确定性 checker/oracle 证明，不由模型猜测；
- `UNSUPPORTED`：required capability/validator/domain 不存在或 qualification 不足；
- `RISK_TOO_HIGH`：剩余候选 OOD/uncertainty/near-gate 超 policy 且无法升级；
- `BUDGET_EXHAUSTED`：下一条合法 plan path 无法 reserve。

No-progress、连续失败和 experience hint 只能触发 `PARETO_STABLE` 候选或恢复动作；最终 stop 仍由 StopPolicy 对 current evidence 判定。

## 17. Planner qualification 与首个切片

Planner 版本的 qualification 绑定 strategy/rule/model/prompt、capability snapshot schema、Goal/Plan schema、benchmark split、budget profile 和 validation policy。模型或 prompt 更新不继承旧 qualification。

首个切片固定 `post_place timing ECO`，仅允许 ResizeInst/SwapVt/InsertBuffer；输入是 44 的结构化 path/problem evidence，输出是 51 定义的 reference PlanGraph。验收同时运行三组：rule baseline、model-backed、model outage fallback。

必须报告：valid-plan rate、accepted-action rate、selection regret、hard-gate false negative、F3/F4 cost、重复动作、恢复次数和停止正确率。model-backed 只有在 held-out family 上达到预注册收益且不增加 correctness 风险时晋级；否则保留 proposal/rationale 辅助，执行策略仍用 baseline。

## 18. 版本历史

- ai1.1（2026-07-23）：补充 Goal Compiler、typed Action DSL、bounded beam baseline、权威预算账本、停止证明和 Planner qualification。
- ai1.0（2026-07-23）：定义 Planner/Runtime 边界、PlanGraph、Critic、恢复停止策略和初始 CI。
