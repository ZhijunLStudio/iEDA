<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 24 · iPDN/iPNP Agent 电源网络实施方案 · ai1.0

> 基线：`24-iPDN-iPNP.md`。职责：iPDN 执行电源几何/连接，iPNP 生成和评价规划候选；功耗与 IR 真值来自 iPA/iIR 契约。

## 1. Agent 场景

- 审计 PG connectivity、coverage、via、stripe 和电源域；
- 根据 power/IR hotspot 生成局部 strap/via/width 候选；
- 比较 IR/EM 改善与 signal congestion/DRC/area 成本；
- 只加固指定 region/domain，冻结其他 PG 与信号网；
- 失败时扩大 scope 或报告物理不可行。

## 2. API

```text
pdn.inspect(snapshot, domain, region)
pdn.validate_connectivity(snapshot)
pdn.propose_reinforcement(snapshot, hotspots, budget)
pdn.apply(branch, PdnDelta)
pdn.validate(branch, scenarios)
pnp.run_portfolio(snapshot, objectives, budget)
```

## 3. PdnDelta

包含 `Add/Resize/DeleteStrap`、`Add/ReplaceViaArray`、`ReconnectPgPin`、decap proposal；每项声明 domain/layer/bbox、预计电阻/面积、signal blockage 和 inverse。删除/缩窄现有 PG 默认高风险并后置。

## 4. LLD

```text
src/operation/iPDN/agent/
  PdnInspector.{h,cpp}
  PdnDeltaAdapter.{h,cpp}
  PdnConnectivityValidator.{h,cpp}

src/operation/iPNP/agent/
  ReinforcementGenerator.{hh,cc}
  PdnPortfolioRunner.{hh,cc}
  PdnCostAttributor.{hh,cc}
```

iPNP 不复制 iIR solver、evaluation congestion 或 iDRC；通过 Tool Contract 组合。

## 5. 闭环

```text
activity coverage gate
  → iPA power map
  → iIR solve + residual gate
  → hotspot attribution
  → iPNP candidates
  → iPDN branch apply
  → connectivity/DRC/congestion
  → iIR/EM rescore
  → Pareto select
```

活动度覆盖不足时只输出带风险的 scenario 分析，不宣称签核改善。

## 6. 里程碑

| 阶段 | 内容 | 门禁 |
|---|---|---|
| PDN-A0（3 周） | inspect/connectivity/coverage | open/short/missing via 注入必报 |
| PDN-A1（4 周） | strap/via proposal + delta | branch/rollback/frozen domain |
| PDN-A2（4 周） | power-IR provenance 闭环 | 电流源逐实例可追溯 |
| PDN-A3（5 周） | IR/DRC/congestion portfolio | 硬门禁 + Pareto |
| PDN-A4（后续） | EM/dynamic IR/decap | 独立 oracle 对拍 |

## 7. 测试

- 多电源域、missing source、跨层 via、macro blockage、窄通道；
- CG 不收敛不能返回有效 IR candidate；
- PG 修改不得触碰冻结 signal nets；
- strap 改善 IR 但导致 DRC/拥塞时不得 commit；
- 整体平移/电流缩放的 metamorphic 关系。

**H-PDN-A1**：局部 reinforcement 能用较小 signal cost 修复主要 IR hotspot。若电流重分布导致新热点频繁出现，升级为全局 portfolio，不迭代堆叠局部补丁。

