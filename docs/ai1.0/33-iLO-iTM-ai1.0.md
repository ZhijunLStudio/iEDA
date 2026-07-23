<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 33 · iLO/iTM Agent 逻辑优化与工艺映射实施方案 · ai1.0

> 基线：`33-iLO-iTM.md` 当前为 greenfield/D0，`src/operation/iLO`、`iTM` 仅空 CMakeLists。实施顺序是成熟外部内核 adapter → 统一 IR/证据 → 物理反馈闭环 → 有选择地自研差异化内核。

## 1. 首批产品切片

- 输入：可综合 Verilog、Liberty NLDM、SDC、可选 early physical feedback；
- 输出：mapped netlist、area/timing/power estimate、变换 trace；
- 后端优先接 Yosys/ABC 等成熟可验证内核；
- iNO 只处理 fanout/IO，不冒充 synthesis；
- 每次 netlist change 必须 formal/equivalence 门禁。

## 2. API

```text
logic.inspect(snapshot_or_rtl)
logic.propose_rewrite(ir, objectives, budget)
logic.run_portfolio(ir, strategies, libraries)
mapping.map(ir, library, scenarios, physical_view)
mapping.compare(candidates)
logic.apply(branch, NetlistDelta)
logic.verify_equivalence(reference, revised)
```

## 3. 中间表示与证据

```text
LogicIR
  stable node/net/port IDs
  boolean function/AIG view
  clock/reset/power intent refs
  source mapping

TransformTrace
  rule/pass/parameters
  before/after cones
  equivalence proof/result
  estimated vs realized PPA
```

Agent 必须能知道哪次 rewrite 导致后续 PPA 变化，而不是只保留最终网表。

## 4. LLD

```text
src/operation/iLO/
  api/LogicService.{hh,cc}
  ir/LogicIR.{hh,cc}
  adapter/YosysAdapter.{hh,cc}
  adapter/AbcAdapter.{hh,cc}
  agent/RewritePortfolio.{hh,cc}
  evidence/TransformTrace.{hh,cc}

src/operation/iTM/
  api/MappingService.{hh,cc}
  library/CellFamilyIndex.{hh,cc}
  mapping/MappingPortfolio.{hh,cc}
  physical/PhysicalFeedbackView.{hh,cc}
```

## 5. Physical Feedback

feedback 只读且版本化：estimated wire RC、congestion bins、macro/region、criticality。综合候选在相同 physical snapshot 上比较；不能用不同 placement 结果冒充 mapping 本身收益。

## 6. Fidelity

| 档 | 内容 |
|---|---|
| F0 | logic depth/gate count/library scalar |
| F1 | learned delay/area/routability ranker |
| F2 | mapped STA + estimated physical |
| F3 | map→place→STA/area/power |
| F4 | DC/Genus + formal/signoff oracle |

## 7. 开发路径

| 阶段 | 内容 | 门禁 |
|---|---|---|
| SYN-A0（3 周） | external adapter + manifest/artifacts | 固定小例可重放 |
| SYN-A1（4 周） | LogicIR/stable IDs/trace | read-write/equivalence |
| SYN-A2（4 周） | strategy portfolio + mapping compare | 不同 pass/seed 证据完整 |
| SYN-A3（5 周） | physical feedback loop | F2 与 post-place regret 报告 |
| SYN-A4（后续） | multi-Vt/自研差异化 rewrite | DC/Genus/formal 联合门禁 |

## 8. 测试

- combinational/sequential、reset、blackbox、multi-clock、dont_touch；
- transform 后 equivalence failure 必须回滚；
- library 缺 cell/VT family、unsupported construct；
- RTL/design family split 防模型泄漏；
- 全 LVT/HVT 与混合 VT 的单调/Pareto；
- 相同 netlist 不同物理反馈版本不可混比。

**H-SYN-A1**：先建立 portfolio+物理反馈能比从头写综合内核更快产生 PPA 差异化。若外部 adapter 成为不可控瓶颈，再根据 trace 热点收编具体 pass，而不是整体重写。

---

## 9. Logic/Mapping request 与 candidate contract

```text
LogicRequest
  rtl/netlist artifact + reference design ref
  intent/scenario/tech/library refs
  hierarchy/blackbox/clock/reset policy
  allowed transforms + dont_touch scope
  objectives {area, delay, power, routability, disruption}
  fidelity/budget/seed/backend allowlist

LogicCandidate
  candidate_id/backend/pass pipeline/seed
  LogicIR before/after refs + mapped netlist artifact
  TransformTrace[] + affected cones
  equivalence status/counterexample ref
  estimated and realized metric bundles
  unsupported constructs/coverage/provenance
```

Backend 只接收 typed generated script/argv template；不得将 Agent 自由文本拼接到 Yosys/ABC 命令。每个 candidate 在 formal/equivalence 未 `PROVED` 前不能进入主物理设计 branch。

## 10. LogicIR、mapping 与物理反馈

`LogicIR` 至少表达 module/port/net/node、combinational function、register/clock/reset、blackbox 和 source mapping。canonical serialization 对 source order/临时名称稳定；unknown、tri-state、memory、analog construct 标 unsupported，不能降成普通 AND/FF。

Mapping 流程为：验证 Liberty/Scenario -> 构建 cell family/function/timing/power view -> 运行多个 strategy -> 独立重算 area/gate count -> F2 mapped STA -> 可选 early physical feedback -> Pareto。不同 library set、PVT 或 physical snapshot 的结果不可归因给 mapping algorithm。

TransformTrace 为每个 pass 保存 before/after cone hash、规则/参数、对象映射和 proof ref。批量 pass proof 失败时二分定位最小 failing prefix；失败 candidate 隔离，不丢 counterexample。

```text
map candidates on identical LogicIR/library/scenarios
  -> F0/F1 logic metrics -> formal proof
  -> F2 estimated physical placement/STA/routability
  -> Top-K full map->place->STA/power
  -> iEval compare selection regret
```

PhysicalFeedbackView 只含版本化摘要/网格/criticality，不暴露 iPL/iSTA 私有指针。反馈过期或与 netlist mapping 不兼容时返回 `STALE_PHYSICAL_VIEW`。

## 11. 失败、CI 与 PR

状态包括 `UNSUPPORTED_RTL`、`MISSING_LIBRARY_MAPPING`、`BACKEND_FAILED`、`EQUIVALENCE_DISPROVED`、`EQUIVALENCE_UNKNOWN`、`PARTIAL_MAPPING`、`STALE_PHYSICAL_VIEW`。任何 unknown/partial proof 均不能作为功能等价网表提交。

CI：`SYN-T01` combinational/sequential/reset，`SYN-T02` hierarchy/blackbox，`SYN-T03` unsupported construct，`SYN-T04` LogicIR canonical round-trip，`SYN-T05` transform mutation/counterexample，`SYN-T06` Liberty family mapping，`SYN-T07` multi-VT Pareto，`SYN-T08` backend crash/timeout/parser drift，`SYN-T09` physical view version，`SYN-T10` F2/post-place regret，`SYN-T11` train/holdout family split，`SYN-T12` artifact replay。

PR：`SYN-0 external bridge adapter` -> `SYN-1 LogicIR/source map` -> `SYN-2 transform trace/formal bridge` -> `SYN-3 mapping/library family` -> `SYN-4 portfolio/Pareto` -> `SYN-5 physical feedback e2e` -> `SYN-6 selected native pass`。
