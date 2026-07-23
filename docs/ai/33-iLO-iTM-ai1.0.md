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

