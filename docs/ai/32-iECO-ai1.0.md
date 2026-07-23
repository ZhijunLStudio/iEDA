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

