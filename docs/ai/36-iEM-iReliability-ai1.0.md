<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 36 · iEM/iReliability Agent 电迁移与可靠性实施方案 · ai1.0

> 当前成熟度：`D0/DRAFT`。当前 iIR/PDN/route 可提供部分网络与几何起点，但仓库未发现独立 EM/reliability operation 和经 PDK 认证的限值服务。  
> 首版以 static PG/via EM 和 signal average/RMS/peak screening 为主；可靠性寿命只能在明确模型、温度、占空比和 PDK limit 下输出。

## 1. 产品职责

- 对 PG wire/via 和 signal wire/via 计算电流应力与 margin；
- 区分 average、RMS、peak、bidirectional stress 和 duty cycle；
- 将 hotspot 归因到几何、电流源、温度、供电路径和模型覆盖；
- 生成 widen、via array、layer promotion、current spreading、load relocation 等 proposal；
- 为 PDN/route ECO 提供 EM/reliability certificate 输入；
- 记录 aging/BTI/HCI 等未来模型接口，但不在无 characterization 时给寿命结论。

## 2. API

```text
reliability.coverage(snapshot, scenario, scope)
em.check_pg(scope, scenario, fidelity)
em.check_signal(scope, scenario, fidelity)
em.inspect_segment(segment_or_via_id)
em.hotspots(scope, threshold)
reliability.estimate_lifetime(scope, mission_profile, model_ref)
reliability.propose_mitigation(hotspot_set, allowed_actions)
reliability.compare(before, after, scope)
```

mitigation 只产生 proposal；route/PDN/place action 分别由 iRT/iPDN/iPL 应用。

## 3. Schema

```text
MissionProfile
  scenario weights, voltage/temp timeline
  activity/duty source, target_lifetime, confidence

StressObservation
  object_id, kind = wire|via|pin|cell
  current = average|rms|peak + unit
  area/width/thickness/cut_count
  current_density, limit, margin
  temperature, directionality, duty
  model/limit source + applicability
  solver residual + coverage + uncertainty

ReliabilityResult
  hotspots, percentiles, unsupported_objects
  lifetime_distribution_or_bound
  assumptions, evidence, status
```

limit 必须来自 `55 TechContext` 的已认证 rule/model；无 limit 只能返回 stress observation，不能 PASS。

## 4. 分层计算

| Fidelity | 方法 | 用途 |
|---|---|---|
| F0 | geometry/current proxy、via count heuristic | hotspot 粗筛 |
| F1 | static IR branch current + DC current density | PG average EM |
| F2 | activity-driven average/RMS/peak + temperature derate | signal/PG decision |
| F3 | time-window/dynamic current、self-heating/mission aggregation | 高风险验证 |
| F4 | foundry-qualified signoff/reliability oracle | release evidence |

寿命模型（例如 Black-type relation）只作为 `model_ref` 插件，参数、适用层、温度范围和统计置信度必须显式。不得把一个经验公式硬编码成所有 PDK 真值。

## 5. 数据流与算法

```text
iPA activity/current source provenance
  + iIR/PDN solved branch currents/residual
  + iRT/iDB wire/via geometry
  + iThermal temperature map
  + TechContext limits/models
  → conservative stress aggregation
  → hotspot cluster + sensitivity
  → proposal portfolio
  → branch rerun + certificates
```

Kirchhoff residual、unmapped current、default activity、missing geometry 和 temperature interpolation error 都进入 coverage。多段 wire/via 的 current continuity 在容差内守恒，否则结果失败。

## 6. LLD 与源码落点

```text
src/operation/iReliability/
  api/ReliabilityService.{hh,cc}
  data/{MissionProfile,StressObservation,ReliabilityResult}.hh
  adapters/{PowerActivity,IrCurrent,RouteGeometry,Thermal,TechLimit}.cc
  em/{PgEmAnalyzer,SignalEmAnalyzer,ViaStressAggregator}.cc
  aging/{LifetimeModelRegistry,MissionAggregator}.cc
  proposal/MitigationGenerator.cc
  agent/ReliabilityCapabilityAdapter.cc
```

iIR 保留电路求解 ownership，iPA 保留活动/功耗 ownership，iThermal 保留温度场 ownership。本模块不复制求解器，只做可靠性语义与聚合。

## 7. 闭环约束

| proposal | 必需验证 |
|---|---|
| widen/layer promotion | DRC、RC、STA、拥塞、EM |
| via array/redundant via | DRC、connectivity、resistance、EM |
| PDN strap/current spreading | PG connectivity、IR residual、DRC、signal congestion、thermal、EM |
| load relocation | legal、timing、power、IR、thermal、frozen scope |
| cell/driver change | formal/connectivity、timing、power、signal EM |

## 8. 失败语义

- missing/unsupported PDK limit：`UNKNOWN_LIMIT`，无 PASS；
- activity/current provenance 不足：`PARTIAL` + worst-case/interval（仅 policy 允许）；
- IR solver residual 超阈值：`INVALID_UPSTREAM`；
- temperature map 缺失：仅在明确 nominal/conservative assumption 下估算并降 fidelity；
- mission profile 缺失：不输出 lifetime；
- mitigation 降低 peak 但增加未检查对象应力：scope/coverage fail。

## 9. 里程碑

| 阶段 | 交付 | 退出门禁 |
|---|---|---|
| REL-A0（3 周） | stress/limit/mission schema | 无 limit/source 不会 pass |
| REL-A1（4 周） | static PG wire/via EM | 解析网络电流与小例守恒 |
| REL-A2（5 周） | signal average/RMS/peak screening | activity provenance/coverage 完整 |
| REL-A3（4 周） | hotspot/proposal portfolio | held-out hotspot 降低且无硬回归 |
| REL-A4（5 周） | thermal/mission/lifetime plugin | 参数域外拒答、残差可审计 |
| REL-A5（后续） | dynamic/aging/signoff qualification | foundry/oracle 协议后晋级 |

## 10. 测试与可杀假说

- 单 wire/via/parallel path/mesh 的解析电流 gold；
- 宽度、cut count、current、temperature 单调 metamorphic；
- activity missing/default、current direction reversal、pulse duty、via current crowding；
- static/dynamic、incremental/full、iEDA/external oracle differential；
- proposal 对 frozen objects、邻近 signal congestion 的副作用。

**H-REL-A1**：F1/F2 screening 能以低 false-negative 找到 F4 高风险对象并减少昂贵检查。若 Recall@K 不足，screening 只能用于排序，不能用于 clean 证书。

## 11. 不做

- 不在无 PDK limit 时自创阈值；
- 不把 nominal temperature/默认 activity 隐藏；
- 不以平均电流替代 RMS/peak 适用条件；
- 不让 reliability 模块直接改 route/PDN；
- 不在首版承诺 aging、self-heating 和 lifetime signoff。

