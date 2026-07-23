<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 29 · iPA/iIR Agent 功耗与压降实施方案 · ai1.0

> 基线：`29-iPA-iIR.md`。复用 activity/VCD、toggle propagation、三分量功耗、PG 网络和 CG/LU/GS 求解；优先建立活动源和电流源可追溯性。

## 1. 职责

- iPA：活动度覆盖、实例/net 功耗、来源与不确定性；
- iIR：从 iPA 实例功耗生成电流源，求解 IR 并给残差；
- iPNP：消费 hotspot 生成 PDN 候选；
- Evaluation：决定 coverage/residual 是否足以进入 gate。

## 2. API

```text
power.audit_activity(snapshot, mode)
power.query(snapshot, selector, scenario)
power.what_if(snapshot, activity_or_cell_delta)
ir.build_sources(snapshot, power_result)
ir.solve(snapshot, domain, region, fidelity)
ir.explain_hotspot(snapshot, node_or_region)
ir.compare(before, after)
```

## 3. Provenance

每个 toggle 标记 `vcd|saif|propagated|default|unknown`；每个 instance power 记录 dynamic/internal/leakage、voltage/temp/lib/corner；每个 IR current source 引用 power record ID。默认 toggle 比例超过 policy 时，签核级 power/IR 为不可信而不是精确值。

## 4. LLD

```text
src/operation/iPA/agent/
  ActivityAuditor.{hh,cc}
  PowerService.{hh,cc}
  PowerAttributor.{hh,cc}
  PowerResultBuilder.{hh,cc}

src/operation/iIR/agent/
  CurrentSourceBuilder.{hh,cc}
  IrService.{hh,cc}
  RegionIrSolver.{hh,cc}
  ResidualGate.{hh,cc}
  IrHotspotAttributor.{hh,cc}
```

## 5. Fidelity

| 档 | Power | IR |
|---|---|---|
| F0 | 默认/统计 activity，强风险标记 | 粗 mesh sensitivity |
| F1 | propagated activity + power proxy | reduced PG/local solve |
| F2 | VCD/SAIF + static vectorless mix | full static PG + residual |
| F3 | multi-mode/corner complete | full static, selected dynamic later |
| F4 | PTPX/RedHawk/Voltus | external oracle |

## 6. 开发路径

| 阶段 | 内容 | 门禁 |
|---|---|---|
| PA-A0（3 周） | hierarchy-safe activity audit/provenance | VCD scope/coverage 正确，缺失不静默 |
| PA-A1（4 周） | instance/net power typed result | 三分量和总量守恒 |
| IR-A0（4 周） | power→current source trace | 每电流可追到 power/activity |
| IR-A1（4 周） | residual gate/hotspot explain | 不收敛、peak 异常非 success |
| PI-A2（5 周） | region incremental + PDN loop | full/local 差异与新热点检测 |
| PI-A3（后续） | dynamic IR/EM | external oracle 门禁 |

## 7. 测试

- 嵌套 VCD scope、部分 activity、clock gating、无活动、多个电压；
- activity 加倍的 dynamic power 单调关系；
- voltage/temperature/library mismatch；
- 小 PG 网络解析解、singular/open source、CG max_iter；
- current scaling 与 IR drop 近线性 metamorphic；
- 局部 PDN 改动引发远端热点必须检出。

**H-PI-A1**：活动来源诚实化比先提升 power 公式复杂度更能降低错误决策。以 activity coverage 分桶对比 PTPX/IR 误差；若高覆盖仍偏差大，再查库/RC/clock 模型。

