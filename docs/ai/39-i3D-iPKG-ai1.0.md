<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 39 · i3D/iPKG Agent Chiplet、3D 与封装协同实施方案 · ai1.0

> 当前成熟度：`D0/DRAFT/独立孵化`。当前主仓库未发现独立 package/3D operation；必须在 2D Snapshot/Delta/Validation 稳定后进入生产路径。  
> 首版目标不是完整 3D signoff，而是多 die/封装状态契约、接口连通性和 early timing/power/thermal portfolio。

## 1. 产品切片

1. Assembly manifest：die/chiplet/interposer/package/board component 与版本；
2. 坐标/单位/层/方向变换；
3. logical interface ↔ bump/TSV/RDL/ball pin 映射；
4. cross-component connectivity/short/open audit；
5. bump/TSV/partition/placement proposal；
6. early cross-die wire/timing/power delivery/thermal/cost proxy；
7. per-die 2D EDA workflow composition；
8. external package/field/thermal/signoff adapter 和证据 bundle。

首版不承诺全波 EM、mechanical stress、advanced package DRC、analog IO/channel signoff 或自动 tapeout assembly。

## 2. API

```text
assembly.import(manifest)
assembly.validate(assembly_ref, check_profile)
assembly.query_components/interfaces/nets(selector)
assembly.diff(a, b)
assembly.propose_partition(logical_design, constraints)
assembly.propose_bumps(interface_set, constraints)
assembly.propose_placement(component_set, constraints)
assembly.apply_delta(base_ref, assembly_delta)       # branch only
assembly.estimate_timing_power_thermal(scope, fidelity)
assembly.verify_connectivity(scope)
assembly.export(adapter, protocol)
```

## 3. Multi-die Schema

```text
AssemblySnapshot
  assembly_ref
  components[]: die|interposer|package|board + artifact/snapshot refs
  coordinate_frames[] + transforms
  stack/material/technology context refs
  interfaces[] + protocol/voltage/clock/power intent
  assembly_nets[] + endpoint mappings
  bump/TSV/RDL/ball objects
  package boundary/cost/model refs

AssemblyDelta
  move/rotate component
  add/remove/remap bump|TSV|RDL
  repartition logical block/interface
  before/after/touched/dirty/inverse
```

每个 component 可引用独立 2D DesignSnapshot/TechContext；assembly 不复制其内部对象。跨 die 对象使用 `(component_id, local_object_id)`，禁止名称拼接充当身份。

## 4. 坐标与单位不变量

- 每个 frame 声明 origin、axes、handedness、rotation/mirror、length unit；
- transform compose/inverse 必须数值闭合；
- bump/TSV/RDL endpoint 在映射 tolerance 内且层/side 合法；
- interface voltage/protocol/direction 与 Intent/TechContext 一致；
- assembly net 的逻辑/物理端点数和 connectivity policy 一致；
- 任何 transform/stack/technology 变化失效几何、热、RC、PI 和相关 timing certificate。

## 5. Agent 工具分面

### 5.1 Inspect/diagnose

`assembly.summarize`、`interface.audit`、`bump.congestion`、`cross_die_path.explain`、`power_delivery.explain`、`thermal_stack.hotspots`。

### 5.2 Propose

partition、die placement、interface clustering、bump assignment、TSV/RDL topology、power/ground bump allocation。proposal 必须返回不同拓扑候选而不是只给一个局部最优。

### 5.3 Apply/verify

只在 assembly branch 应用 typed AssemblyDelta；按 dirty component 触发 per-die FP/PL/RT/PDN/STA 以及 cross-die RC/timing/thermal/PI。首版多 Agent 仍 branch-and-select，不自动合并 component changes。

## 6. Fidelity

| Fidelity | 方法 |
|---|---|
| F0 | graph partition/cut、Manhattan/IO/power-density proxy |
| F1 | bump-aware geometry、early RC/timing、resistance/thermal grid |
| F2 | per-die global place/route + RDL/package compact model |
| F3 | detailed per-die + package extraction/thermal/PI adapters |
| F4 | qualified package/field/thermal/mechanical/signoff bundle |

不同 die/封装技术的 fidelity 分开记录；一个 component F3 不能把整个 assembly 宣称 F3。

## 7. 关键算法路线

### 7.1 Partition/assignment

超图 partition 目标独立记录 cut bandwidth、critical paths、power domain、die area/technology affinity、bump count、thermal/power delivery 和 cost。硬约束先过滤，Pareto portfolio 保留 diverse partition。

### 7.2 Bump/TSV placement

候选生成 → capacity/keepout/domain/escape feasibility → matching/min-cost flow/局部 exact solver → early RDL congestion/RC → per-die pin access。无法分配要给 Hall-like capacity/region 证据或最小冲突集合。

### 7.3 Cross-die analysis

interface path 分解为 die timing arc、IO/bump/TSV/RDL/package RC、clock relation；power/thermal 通过 assembly graph/mesh composition。每一分量保留模型和 coverage，不输出一个不可解释总 delay/temperature。

## 8. LLD 与源码落点

```text
src/operation/iPKG/
  api/AssemblyService.{hh,cc}
  data/{AssemblySnapshot,AssemblyDelta,Component,Interface}.hh
  geometry/{CoordinateFrame,Transform,Stack}.cc
  connectivity/AssemblyNetGraph.cc
  partition/PartitionPortfolio.cc
  bump/{BumpAssigner,CapacityChecker}.cc
  analysis/{CrossDieTiming,PowerDelivery,ThermalAssembly,Cost}.cc
  adapters/{PerDieWorkflow,ExternalPackageTool}.cc
  agent/AssemblyCapabilityAdapter.cc
```

若已有 3D 分支/子模块，正式实现前先做 ownership/code audit，再决定收编或 adapter；本文不假设其已进入当前仓库。

## 9. Validation Bundle

| 动作 | 必需验证 |
|---|---|
| component move/rotate | boundary/overlap/keepout、interfaces、thermal/PI、cost |
| bump/TSV remap | logical/physical connectivity、capacity、package rules、timing |
| repartition | formal/interface equivalence、per-die feasibility、timing/power |
| RDL topology | DRC/connectivity、RC/SI、current/EM、escape congestion |
| power bump change | PG connectivity、IR/EM、signal return path、thermal |

R5 release 必须由 external qualified adapter 和双审批，首版无自动发布路径。

## 10. 失败语义

- frame/unit/side 歧义：FAILED_INPUT；
- component artifact/TechContext 不可重放：UNVERIFIABLE；
- interface 未映射或 voltage/protocol 不兼容：INFEASIBLE/INVALID_INTENT；
- bump capacity 不足：INFEASIBLE + conflict region/capacity evidence；
- compact model 域外：UNKNOWN/OOD，升级 external oracle；
- per-die workflow partial：assembly PARTIAL，不能 full pass；
- 不同 fidelity/coverage component：结果保留分量，不用最低/最高单标签掩盖。

## 11. 里程碑

| 阶段 | 交付 | 退出门禁 |
|---|---|---|
| PKG-A0（4 周） | AssemblyRef/frame/interface schema | transform/connectivity gold 全过 |
| PKG-A1（5 周） | import/query/diff/connectivity | 两 die toy assembly 可重放 |
| PKG-A2（6 周） | bump assignment/placement proposal | capacity/keepout/infeasible 证据正确 |
| PKG-A3（8 周） | cross-die timing/thermal/PI proxies | analytic/external small cases 校准 |
| PKG-A4（8 周） | per-die workflow portfolio | 至少一条真实 2.5D consumer 闭环 |
| PKG-A5（后续） | RDL/package/F4 adapters | PDK/package owner qualification |

## 12. 测试与可杀假说

- frame translate/rotate/mirror/inverse、um/mm/DBU 单位 metamorphic；
- open/short/swapped differential pair/power-ground/duplicate bump；
- capacity-limited matching、keepout、edge escape、clock/power domain；
- per-die snapshot 改动触发 assembly dirty/certificate invalidation；
- two-die analytic RC/thermal network 与 external oracle；
- partition portfolio 的 Pareto/diversity 与 held-out decision regret。

**H-PKG-A1**：统一 AssemblySnapshot 能让现有 2D 工具以 Composition 支持 early chiplet exploration。若大量工具必须复制/扁平化多 die 数据，先修 state/context adapter，不建设自动 optimizer。

## 13. 不做

- 不把多个 DEF 拼接称为 3D state；
- 不混用坐标/单位/镜像而无 transform；
- 不以 compact model 代替 package/signoff；
- 不在单 die 事务/证书不稳定时开放 assembly 写能力；
- 不让 Agent 自动更改 interface/power intent；
- 不在首版承诺 full-wave、mechanical stress 或模拟 channel signoff。

