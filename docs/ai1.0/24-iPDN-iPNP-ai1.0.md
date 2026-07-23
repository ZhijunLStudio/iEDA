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

---

## 8. 数据契约与对象模型

```text
PdnView
  snapshot/tech/domain/scenario refs
  sources/rails/rings/straps/vias/pins as stable IDs
  layer/width/pitch/resistance/connectivity graph
  macro/blockage/signal-resource intersections
  power/current/IR result refs + coverage

PdnProposal
  diagnosis/hotspot refs
  operations[] {add|resize|delete strap, add|replace via array, reconnect pin}
  domain/layer/region and electrical intent
  predicted IR/EM + metal/via/area/congestion/DRC cost
  assumptions/fidelity/change budget/required validators
```

Decap 首版只作为 proposal placeholder，未有合法 cell、placement、power model 时 manifest 标 `UNSUPPORTED`。删除/缩窄 PG 需要高权限 policy 和 full-domain F3 验证；普通优化 policy 默认只允许 add/strengthen。

## 9. 检查与候选生成算法

`PdnConnectivityValidator` 将每个 domain 构造成 source-to-pg-pin 的分层图，分别检查 open、short、dangling shape、missing via、unpowered instance 和跨域连接。几何相交不自动等于电气连接；via/layer/purpose 必须由 TechContext 判定。

Reinforcement generator：

1. 从 iIR hotspot 的 node/branch sensitivity 和 source provenance 定位瓶颈边；
2. 枚举 width/pitch/parallel strap/via-array/current-spreading proposals；
3. 用 F0/F1 电阻变化与 signal resource 相交做粗筛；
4. 对 Top-K 在 branch 应用，重建 PG graph 和电流源；
5. iIR F2/F3 求解并检查 residual、远端新 hotspot、EM、DRC 和 congestion；
6. 在 hard gate 后形成 IR/metal/via/signal-cost Pareto。

不能只比较原 hotspot；whole-domain peak 和 P95 也必须检查，防止电流重分布把问题搬走。

## 10. Apply、失效与 fidelity

| 档 | 后端 | 决策范围 |
|---|---|---|
| F0 | Manhattan/effective-R sensitivity、几何资源 | 大量 proposal 排序 |
| F1 | reduced/local PG network | region 候选确认，输出边界误差 |
| F2 | full static network + declared activity | Top-K IR/EM 检查 |
| F3 | full domains/scenarios + DRC/congestion/thermal context | stage gate |
| F4 | Voltus/RedHawk 等合格 oracle | 校准/发布 |

PdnDelta 至少失效 PG connectivity、IR/EM、route resource、DRC、RC/SI 和受影响 power-domain certificate。apply 实际碰到 frozen signal route 时直接失败；需要 signal reroute 时返回独立 proposal，由 Runtime 创建新的联合 experiment。

## 11. LLD、失败与测试

| 类 | 交付 |
|---|---|
| `PdnInspector` | PG graph、coverage、resource intersection |
| `PdnConnectivityValidator` | per-domain checked/open/short/unpowered 结果 |
| `ReinforcementGenerator` | sensitivity 驱动多动作 portfolio |
| `PdnDeltaAdapter` | iPDN API branch apply/inverse/actual touched |
| `PdnCostAttributor` | IR/metal/via/signal congestion/DRC 分量 |
| `PdnPortfolioRunner` | 预算、升级、Pareto、evidence |

状态：缺 activity/current 为 `PARTIAL_INPUT`；PG singular/open source 为 `INVALID_NETWORK`；solver 不收敛为 `NUMERICAL_FAILURE`；局部解边界不充分为 `PARTIAL_SCOPE`；DRC/EM/新 hotspot 失败为 `REJECTED`。

CI：`PDN-T01` source-to-pin 图解析，`PDN-T02` open/short/missing via，`PDN-T03` 多域隔离，`PDN-T04` strap/via delta rollback，`PDN-T05` frozen signal，`PDN-T06` 解析小网络 IR，`PDN-T07` current scaling，`PDN-T08` local/full IR，`PDN-T09` 新 hotspot 检测，`PDN-T10` DRC/congestion trade-off，`PDN-T11` activity coverage，`PDN-T12` F1/F3 selection regret。

PR：`PDN-0 inspect/connectivity` -> `PDN-1 typed strap/via delta` -> `PDN-2 power-current provenance` -> `PDN-3 sensitivity portfolio` -> `PDN-4 DRC/congestion/IR gate` -> `PDN-5 EM/thermal/F4 qualification`。
