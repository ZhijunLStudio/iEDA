<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 37 · iThermal Agent 热分析与热耦合优化实施方案 · ai1.0

> 当前成熟度：`D0/DRAFT`。当前仓库未发现独立 thermal operation。首版从 steady-state 网格热传导、小例解析 oracle 和 external adapter 起步。  
> 输入功耗来自 iPA，几何来自 iDB/未来 i3D，材料/边界来自 TechContext；本模块不自行估算活动度或修改布局。

## 1. 产品面

- thermal input/coverage audit：power map、材料、die/package boundary、ambient；
- steady-state temperature map 与 hotspot；
- transient thermal（后置）；
- temperature-dependent leakage/delay/resistance 固定点耦合；
- hotspot attribution：power density、spreading path、boundary、neighbor die；
- mitigation proposal：cell spreading、macro move、power gating schedule、PDN/package/thermal via 建议；
- thermal constraint certificate 输入。

## 2. API

```text
thermal.coverage(snapshot, scenario, boundary_ref)
thermal.solve_steady(scope, scenario, fidelity)
thermal.solve_transient(scope, mission_profile, fidelity)
thermal.hotspots(result_ref, thresholds)
thermal.inspect_cell(cell_or_region)
thermal.coupled_solve(coupling_policy, budget)
thermal.propose_mitigation(hotspots, allowed_actions)
thermal.compare(before, after, scope)
```

`coupled_solve` 通过 Platform 组合 iPA/iThermal/iSTA/iIR，不在一个隐藏 loop 中直接调用单例。

## 3. 核心 Schema

```text
ThermalBoundary
  ambient, convection/contact conditions
  package/heat_sink/interface refs
  material stack + conductivity/capacity applicability

PowerMap
  spatial cells/regions, value/unit
  dynamic/internal/leakage components
  activity/source/coverage + time windows

ThermalResult
  grid/mesh ref, temperature field
  max/percentiles/gradients/hotspots
  energy_balance, solver residual, iterations
  boundary/material/model/tool refs
  interpolation/coverage/uncertainty
```

只有 power 和 ambient 而没有 package/boundary 时，结果最多是明确假设下的探索级估计。

## 4. 算法路线

### 4.1 Steady state

以有限体积/热阻网络离散 `div(k grad T) + q = 0`，处理多层材料和边界。首版支持规则 2D/2.5D grid，保守映射 cell power；求解复用 `11 Solver` 的稀疏线性 contract，输出残差和能量平衡。

### 4.2 Coupled fixed point

```text
T0 = nominal temperature
repeat:
  iPA update leakage/internal(Tn)
  iThermal solve T(n+1)
  optional iSTA/iIR update derate/resistance
  damp and evaluate max |T(n+1)-Tn| + power/resistance residual
until converged or budget
```

不收敛返回 PARTIAL + history/incumbent，不采用最后一次温度冒充收敛结果。耦合 policy 明确哪些模块参与、damping 和容差。

## 5. Fidelity

| Fidelity | 模型 | 用途 |
|---|---|---|
| F0 | power-density/neighbor smoothing proxy | candidate ranking |
| F1 | 2D steady resistance grid | early floorplan/place |
| F2 | multilayer 2.5D steady + calibrated boundary | ECO/PDN decision |
| F3 | transient/coupled/package-aware | 高风险验证 |
| F4 | qualified FEM/CFD/package/silicon oracle | release/calibration |

模型等级由 held-out 误差/decision regret 和 domain qualification 决定，不由网格更细自动决定。

## 6. LLD 与源码落点

```text
src/operation/iThermal/
  api/ThermalService.{hh,cc}
  data/{ThermalBoundary,PowerMap,ThermalResult}.hh
  mesh/{GridBuilder,PowerMapper,MaterialMapper}.cc
  solver/{SteadyThermal,TransientThermal}.cc
  coupling/CoupledFixedPoint.cc
  analysis/{HotspotClusterer,ThermalAttributor}.cc
  proposal/MitigationGenerator.cc
  agent/ThermalCapabilityAdapter.cc
```

未来 3D/package mesh 通过 `39` 的 AssemblyRef adapter 接入；不能让 iThermal 私有维护另一份 die/package 坐标真值。

## 7. Proposal 与验证

| proposal | apply owner | 必需验证 |
|---|---|---|
| local cell spread | iPL | legal、timing、congestion、thermal |
| macro move | iFP/iPL | floorplan constraints、route/PDN、timing、thermal |
| PDN/package change | iPDN/iPKG | connectivity、IR/EM、DRC、thermal |
| thermal via/bump suggestion | i3D/iPKG | geometry/manufacturing/package rule、thermal |
| power mode suggestion | Intent/R4 workflow | functional/intent approval + full scenarios |

## 8. 失败语义

- power/activity coverage 不足：PARTIAL/UNKNOWN，列 default/propagated/unknown 比例；
- boundary/material 缺失：UNSUPPORTED 或 assumption-bound F0/F1；
- solver residual/energy imbalance 超限：FAILED_NUMERICS；
- coupled loop 不收敛：PARTIAL，不能 certificate PASS；
- grid 超预算：返回 coarse incumbent + error estimator/resume；
- 插值落在 mesh 外或多 die 坐标歧义：FAILED_INPUT。

## 9. 里程碑

| 阶段 | 交付 | 退出门禁 |
|---|---|---|
| TH-A0（3 周） | boundary/power/result schema | 缺输入不输出无条件温度 |
| TH-A1（5 周） | 2D steady grid solver | 解析解、能量守恒、网格收敛 |
| TH-A2（5 周） | multilayer/power mapping/hotspot | external oracle 的分桶误差可校准 |
| TH-A3（5 周） | power-temperature fixed point | 收敛/不收敛与 replay 正确 |
| TH-A4（5 周） | placement/PDN proposals | held-out hotspot 改善且无硬回归 |
| TH-A5（后续） | transient/3D/package/F4 | 有真实边界/材料/consumer 后立项 |

## 10. 测试与可杀假说

- 1D slab、均匀热源、点热源、双材料层解析/高精度数值 gold；
- 功率倍增、导热率增大、ambient 平移的单调/平移 metamorphic；
- mesh refine convergence、energy balance、boundary extreme；
- power map ObjectId/坐标/单位错误、空白区域、macro 高功率；
- coupled leakage runaway 和 damping sensitivity。

**H-TH-A1**：F1/F2 temperature proxy 能改善 floorplan/PDN 候选选择，而不是只提供漂亮热图。以 held-out 候选 selection regret 验证；失败则只保留 audit/F4 调度用途。

## 11. 不做

- 不用无来源材料/封装参数给出“精确温度”；
- 不把 cell power density heatmap 称为 thermal solve；
- 不忽略 leakage-temperature 正反馈却声称耦合收敛；
- 不让 thermal 模块直接改布局/PDN/intent；
- 不在首版承诺 chip/package CFD 或 silicon-correlated signoff。

