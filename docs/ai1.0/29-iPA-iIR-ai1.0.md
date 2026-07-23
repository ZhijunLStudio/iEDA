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

---

## 8. Scenario、activity 与 result schema

```text
PowerScenario
  scenario/mode/corner/voltage/temperature/frequency refs
  activity_artifacts[] {VCD|SAIF, hierarchy scope, time window}
  propagation/default policy + clock treatment
  liberty/RC/netlist refs

ActivityRecord
  object_id, toggle_rate, duty/static_probability
  source = measured|propagated|default|unknown
  source span/window + confidence

PowerResult
  per instance/net/domain dynamic/internal/leakage
  clock/data/IO breakdown + total
  activity and model coverage, assumptions, provenance

IrResult
  domain/node/branch voltage/current
  peak/P95/drop map/hotspots
  source mapping, KCL/residual, boundary/source coverage
```

所有 power 分量在统一单位下守恒到 total；无法归属部分进入 `unattributed_power`。VCD hierarchy scope 解析失败不能回退 default 后继续标 measured。每个 current source 记录 `power_record_id / V / injection node / mapping rule`。

## 9. Activity audit 与功耗算法

```text
resolve design<->waveform hierarchy mapping
  -> map ports/nets/registers/clocks by stable IDs
  -> compute measured toggle/duty in requested window
  -> propagate only through qualified logic domain
  -> apply versioned default policy to remaining objects
  -> report measured/propagated/default/unknown weighted coverage
  -> calculate dynamic/internal/leakage per scenario
  -> independent sum and range checks
```

Clock gating、generated clock、多 voltage domain 和 X/Z 的处理由 policy 指定。默认 activity 超阈值时可以输出 F0/F1 interval，但 F3 gate 为 `INCOMPLETE`。what-if 只在 overlay 中改变 activity/cell，结果不改 canonical activity store。

## 10. IR network 与求解

1. 从 PG geometry/TechContext 建 conductance graph，检查 source、ground/reference、open component 和 domain isolation。
2. 将 instance power 依据 domain/voltage/PG pin 映射为 current injections；unmapped current 计入 coverage。
3. 组装 `G*V=I`，选择 CG/LU/GS adapter，报告 iteration/residual/conditioning。
4. 检查 KCL、功率和 current conservation；singular network 为 invalid input，不是 IR=0。
5. 输出 node/branch/hotspot 与从 power->source->path 的 attribution。

Region solve 必须说明边界条件和截断误差；无法构造保守边界时升级 full network。PDN 修改后检查 whole-domain peak，避免局部改善迁移 hotspot。

## 11. Fidelity、失败与 LLD

| 档 | Power | IR | 使用 |
|---|---|---|---|
| F0 | default/statistical activity | coarse effective R | ranking |
| F1 | propagated + estimated RC | reduced/local network | Top-K |
| F2 | VCD/SAIF mix + full supported components | full static PG | decision |
| F3 | required modes/corners/windows complete | full static + required domains | gate |
| F4 | PTPX | Voltus/RedHawk | calibration/release |

`ActivityAuditor`、`PowerAttributor`、`CurrentSourceBuilder`、`IrService`、`ResidualGate` 分离。失败状态包括 `ACTIVITY_SCOPE_MISMATCH`、`PARTIAL_ACTIVITY`、`LIBRARY_CONTEXT_MISMATCH`、`UNMAPPED_CURRENT`、`SINGULAR_PG`、`NOT_CONVERGED`、`PARTIAL_DOMAIN`；这些状态均不可变为 full PASS。

## 12. CI 与 PR

`PI-T01` VCD nested scope/time window，`PI-T02` measured/propagated/default 分类，`PI-T03` activity x2 dynamic 单调，`PI-T04` dynamic/internal/leakage 守恒，`PI-T05` clock gating/multi-voltage，`PI-T06` power->current 逐实例追溯，`PI-T07` 小 PG 解析解/KCL，`PI-T08` singular/open/not-converged，`PI-T09` current scaling/IR 线性，`PI-T10` region/full 新 hotspot，`PI-T11` F1/F3/F4 coverage 分桶，`PI-T12` PDN loop rollback。

PR：`PA-0 scenario/activity schema` -> `PA-1 hierarchy audit/provenance` -> `PA-2 typed power/attribution` -> `IR-0 PG graph/current mapping` -> `IR-1 solver/residual/hotspot` -> `PI-2 region/full + iPNP loop` -> `PI-3 dynamic/thermal/F4`。
