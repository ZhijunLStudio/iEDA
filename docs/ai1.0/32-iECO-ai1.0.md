<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 32 · iECO Agent 领域闭环实施方案 · ai1.0

> 基线：`32-iECO.md`。当前生产能力主要是 via repair；iECO 在 Agent 架构中是 ECO 领域门面，通用分支/预算/调度归 Agent Runtime，优化内核归 iTO/iRT/iDRC/iPL/iSTA。

## 1. 领域工作流

| workflow | 组合工具 |
|---|---|
| `eco.timing` | iSTA diagnose → iTO proposal → iPL legal → iRCX → iSTA |
| `eco.route_drc` | iDRC cluster → iRT/iECO via proposal → iDRC/RC/STA |
| `eco.functional` | netlist patch → equivalence → legal/route/STA/LVS |
| `eco.power_ir` | iPA/iIR → iPNP/iPDN → DRC/route/IR |

首版实现 timing 与 route/via，functional 后置到 iLVS/formal adapter 可用。

## 2. API

```text
eco.diagnose(problem_ref)
eco.propose(problem_ref, strategies, budget)
eco.execute(branch, proposal_id, policy)
eco.status/cancel/resume(execution_id)
eco.validate(execution_id)
eco.explain_rejection(proposal_id)
```

iECO 不提供绕过 Runtime 的直接主状态 commit。

## 3. Eco Workflow Spec

```yaml
problem: timing.setup
base_snapshot: sha256:...
allowed_actions: [resize, vt_swap, insert_buffer, local_move]
change_budget: {instances: 20, nets: 10, region_um: 100}
validation:
  - connectivity
  - local_legalize
  - dirty_rc
  - setup_hold_sta
  - frozen_objects
fallback: [expand_region, alternative_action, full_validation]
```

## 4. LLD

```text
src/operation/iECO/agent/
  EcoService.{h,cpp}
  EcoProblem.{h,cpp}
  EcoWorkflowBuilder.{h,cpp}
  ViaRepairAdapter.{h,cpp}
  EcoEvidenceBuilder.{h,cpp}
```

现有 via repair 纳入 proposal/apply/validate；pattern repair 若仍空实现则 manifest 标 unsupported。

## 5. 开发路径

| 阶段 | 内容 | 门禁 |
|---|---|---|
| ECO-A0（2 周） | via repair typed adapter | shape/pattern coverage 诚实 |
| ECO-A1（3 周） | timing workflow builder | 失败补偿链/回滚 |
| ECO-A2（4 周） | route-DRC workflow | frozen nets/new violations |
| ECO-A3（4 周） | rejection/failure memory | 每拒绝有结构化原因 |
| ECO-A4（后续） | functional/power workflows | formal/LVS/IR gates |

## 6. 测试

- 每个 workflow stage 注入失败；
- local legalize/route/STA 任一步失败恢复；
- via 无替换 master、pattern unsupported；
- 不可修问题返回 residual/unfixable；
- change budget 和 frozen layer/net；
- iECO 不复制工具内核的依赖审计。

**H-ECO-A1**：领域模板可显著减少 Planner 自由组合造成的漏门禁。对比自由调用与模板在 failure injection 中的 escaped invalid commit，模板必须为 0。

---

## 7. Workflow contract 与状态机

```text
EcoExecution
  execution/workflow/policy IDs
  base/current/incumbent snapshot refs
  problem/proposal/delta refs
  allowed capability versions + budgets
  plan nodes/edges + compensation actions
  validation requirements + evidence refs
  status/history/resume token
```

```text
CREATED -> DIAGNOSING -> PROPOSING -> READY
READY -> APPLYING -> VALIDATING -> EVALUATED
EVALUATED -> READY_TO_SELECT | REJECTED | NEEDS_RECOVERY
READY_TO_SELECT -> Runtime selection (iECO itself cannot commit)
RUNNING -> CANCELLING -> CANCELLED
worker failure -> RECOVERING -> READY|FAILED|CORRUPTED_BRANCH
```

Workflow spec 必须引用 capability manifest 的具体 major version；运行中工具升级不改变已有 execution。每个 node 声明 reads/mutates/scope、preconditions、success predicate、timeout、retry 和 compensation，不能以“命令返回 0”作为成功条件。

## 8. 首批模板 DAG

### 8.1 Timing ECO

```text
iSTA diagnose -> iTO/iNO proposals -> iEval F0/F1 screen
  -> iDB branch apply -> iPL local legal -> iRCX dirty extract
  -> iSTA F2/F3 setup/hold/DRV -> Verification bundle
  -> iEval gate -> READY_TO_SELECT|REJECTED
```

### 8.2 Route/DRC ECO

```text
iDRC explain/cluster -> iRT/iECO via proposals -> branch route delta
  -> connectivity/frozen -> iDRC affected+secondary rules
  -> iRCX coupling -> iSTA -> iEval gate
```

每个模板带最小 validation profile；Planner 只能增加检查或缩小 allowed action，不能删除 mandatory nodes。节点返回 partial 时由 policy 决定升级/恢复，不能自动跳过。

## 9. Compensation 与恢复

- 设计修改依靠 iDB delta inverse/checkpoint 回滚；
- 外部 worker/artifact 创建由 Platform 清理，但 evidence 不删除；
- retry 只适用于声明 idempotent 的 read/analysis node；apply node 重试前必须确认 transaction 未发布；
- local scope 无解可生成 `expand_region` 新 proposal，不在原 execution 静默扩 scope；
- full audit 推翻 incremental certificate 时吊销 candidate 和相关 qualification，回退最近 validated snapshot；
- 任何 rollback hash 不一致使 branch `CORRUPTED`，停止所有后续 node。

## 10. LLD 与数据所有权

| 组件 | 职责 |
|---|---|
| `EcoProblem` | 规范 problem signature/context/scope |
| `EcoWorkflowBuilder` | policy + problem -> versioned DAG |
| `EcoService` | lifecycle facade，委托 Runtime 执行 |
| `ViaRepairAdapter` | 现有 via repair 的 proposal/delta/coverage |
| `EcoEvidenceBuilder` | 聚合 node/metric/certificate/decision refs |

iECO 不实现 branch scheduler、Tool Registry、iSTA/iDRC kernel 或 Pareto engine；分别复用 Runtime、Gateway、领域工具和 Evaluation。pattern repair 若现有函数无真实行为，capability discovery 返回 `UNSUPPORTED`。

## 11. CI、故障注入与 PR

`ECO-T01` workflow schema/mandatory node，`ECO-T02` 每节点失败补偿，`ECO-T03` apply 前后 kill，`ECO-T04` local legal/route/RC/STA partial，`ECO-T05` change budget/frozen scope，`ECO-T06` retry idempotency，`ECO-T07` cancel/resume，`ECO-T08` full audit overturn，`ECO-T09` via unsupported pattern，`ECO-T10` free-form Planner 删除 gate 拒绝，`ECO-T11` evidence replay，`ECO-T12` 与自由调用 escaped-invalid 对照。

PR：`ECO-0 workflow/execution schema` -> `ECO-1 via typed adapter` -> `ECO-2 timing DAG` -> `ECO-3 route/DRC DAG` -> `ECO-4 compensation/cancel/resume` -> `ECO-5 evidence/failure memory` -> `ECO-6 functional/power 模板`。

完成定义：每个模板至少有一个真实 branch e2e、所有 node 的 typed failure injection、完整 rollback 和不可绕过的 gate；仅提供一段固定 Tcl flow 不算 Agent 原生 ECO。
