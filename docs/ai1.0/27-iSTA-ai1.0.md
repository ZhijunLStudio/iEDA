<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 27 · iSTA Agent 时序服务实施方案 · ai1.0

> 基线：`27-iSTA.md` 与 `27-iSTA-benchmark-plan.md`。复用完整 GBA、CPPR、SDC、RC tree 和已有增量资产；目标是唯一 common timing service，而非继续增加平行时序栈。

## 1. Agent 产品面

| 分面 | 能力 |
|---|---|
| observe | clocks/scenarios/coverage/WNS/TNS/top paths |
| explain | cell/net/clock/constraint/CPPR/RC 分量归因 |
| estimate | 同一引擎的 F1/F2 effort，而非第二套语义 |
| incremental | DirtySet 驱动的 forward/backward cone 更新 |
| validate | full update、增量对拍、near-gate false negative |
| what-if | 不 commit 的 cell/net/RC 参数反事实 |

## 2. API

```text
timing.inspect(snapshot, scenarios)
timing.top_paths(snapshot, selector, K, fidelity)
timing.explain_path(snapshot, path_id)
timing.audit_constraints(snapshot)
timing.update_cone(branch, dirty_set, scenarios)
timing.full_update(snapshot, scenarios)
timing.what_if(snapshot, parameter_delta)
timing.compare(result_a, result_b)
```

Path ID 包含 scenario/check type/start/end/launch-capture clocks/edges；仅用字符串报告行不能稳定引用路径。

## 3. 统一结果

```text
TimingResult
  snapshot/scenario/analysis_type
  wns/tns/violating_endpoints
  path_set + path_match_keys
  coverage {constraints, arcs, endpoints, skipped, unsupported}
  effort/fidelity
  incremental_scope/full_audit_age
  units/provenance
```

setup/hold、rise/fall、max/min 分开；不存在用 0 代替 N/A 的路径。

## 4. Common Timing 架构

```text
                 immutable TimingTopology
                /          |             \
       ScenarioView   RcModelView    ConstraintView
                \          |             /
                 TimingService API
                  /       |       \
             iPL/iCTS   iTO/iNO   iRT/evaluation
```

- iPL evaluation timing 与 CTS fast STA 降级为明确 F0/F1 adapter；
- stable object/path ID、单位和 SDC 语义由 iSTA 定义；
- caller 只能选 effort，不复制图；
- 过渡期双跑并记录差异，不能一次性删除旧栈。

## 5. Dirty Cone LLD

```text
src/operation/iSTA/agent/
  TimingService.{hh,cc}
  TimingResultBuilder.{hh,cc}
  PathIdRegistry.{hh,cc}
  PathAttributor.{hh,cc}
  ConstraintAuditor.{hh,cc}
  DirtyConePlanner.{hh,cc}
  IncrementalAudit.{hh,cc}
  EffortPolicy.{hh,cc}
```

```text
changed cell/net/constraint/RC
  → mark delay/slew invalid
  → forward cone arrivals
  → backward cone required times
  → affected endpoints/path groups
  → stop only on exact version/value stability
```

最坏退化全图是正确行为。锥外变化或漏失效是 correctness bug，不用放松 epsilon 掩盖。

## 6. Fidelity

| 档 | 配置 |
|---|---|
| F0 | graph/logic depth/estimated RC，仅候选粗筛 |
| F1 | common topology + estimated RC + limited scenarios/GBA |
| F2 | dirty cone + active scenarios + CPPR |
| F3 | full RC/full scenarios/GBA + selected PBA |
| F4 | PT/Spice oracle adapter |

PBA 先对 top endpoints 做 path-local 搜索，输出 search exhausted/budget/gap；超预算返回 partial。

## 7. 开发路径

| 阶段 | 内容 | 门禁 |
|---|---|---|
| STA-A0（3 周） | typed inspect/top paths/units/coverage | 与现有报告逐项对账 |
| STA-A1（4 周） | path ID/explain/constraint audit | 分量求和、unconstrained 注入 |
| STA-A2（5 周） | DirtySet contract/full-incr audit | 相关端点 ≤1 ps、锥外 0 变化 |
| STA-A3（5 周） | iTO/iNO common service | 全量调用比例和墙钟下降 |
| STA-A4（6 周） | iPL/iCTS/iRT 旧栈双跑收敛 | 口径差有分桶和迁移门禁 |
| STA-A5（后续） | top-N PBA/MCMM/SI | PT 联合门禁，不只 R² |

## 8. 测试

- setup/hold、rise/fall、generated clock、false/multicycle、clock groups；
- 单位缩放、重收敛、combinational loop、unconstrained；
- resize/buffer/reconnect/RC-only/constraint dirty cases；
- full/incremental 交叉 fuzz；
- path matching 与 PT coverage/false-negative；
- worker cancel 后 state 不损坏。

**H-STA-A1**：统一 dirty-cone service 可使 Timing Lab 单动作 STA 墙钟下降 ≥5 倍且终局不变。若 dirty cone 经常接近全图，按 action/net class 归因，不伪造增量收益。

---

## 9. TimingContext 与稳定对象

```text
TimingContext
  snapshot_ref / intent_ref / scenario_set_ref / tech_context_ref
  netlist/topology_version
  constraints/liberty/RC/activity/derate refs
  analysis {setup|hold, rise|fall, GBA|PBA, CPPR}
  path groups/clocks/exceptions + coverage

TimingPathId
  scenario/check/startpoint/endpoint
  launch_clock/capture_clock/edges
  path_group + topology_generation
```

同名 endpoint 在不同 scenario/check/edge 下是不同 path。path 重收敛后内部 arc 序列可变，但匹配 key 保持 endpoint/clock/check 语义；无法一一匹配时 compare 返回 added/removed/ambiguous，不能按报告行号对齐。

## 10. 服务生命周期与图所有权

```text
UNBOUND -> BUILDING_TOPOLOGY -> READY
READY -> UPDATING_INCREMENTAL | UPDATING_FULL | WHAT_IF
UPDATING_* -> READY | PARTIAL | FAILED_DIRTY
context/topology change -> STALE -> REBUILDING
```

一个 immutable `TimingTopology` 可被多个只读 ScenarioView 使用；ConstraintView、RcModelView 和 derate 均绑定 ref。调用者不能持有 graph node 裸指针跨请求。what-if 在 overlay 中修改 cell/net/RC 参数，结束后丢弃，不污染 canonical timing state。

### 10.1 Build 顺序

```text
validate context and units
  -> build netlist/timing arcs
  -> bind liberty/scenarios/constraints
  -> initialize clocks/exceptions
  -> bind estimated or extracted RC
  -> propagate slew/delay/arrival/required
  -> coverage audit and snapshot result
```

任一步 unsupported/skip 都进入 coverage。没有 RC 时可建立 F0/F1 estimated view，但不得标 F3；无约束 endpoint 不以 slack=0 代替。

## 11. Dirty cone 算法与审计

| Change | Forward dirty | Backward dirty | 额外失效 |
|---|---|---|---|
| cell/master/VT | output arrivals/slew downstream | affected endpoints required cone | cap/DRV/power |
| reconnect/buffer | topology downstream | endpoints/path groups | full graph index/connectivity |
| placement/route/RC | net delay/slew downstream | affected endpoints | coupling neighbors |
| clock tree/latency | capture/launch clock cones | all related data endpoints | CPPR/path IDs |
| constraint/scenario | as defined by changed constraint | potentially global | comparison baseline |

增量流程从 iDB DirtySet 出发，领域逻辑只扩大。传播停止条件是版本和数值均稳定；只比较浮点 epsilon 可能漏 topology change。每 N 次增量或风险触发 full audit，比较 WNS/TNS、endpoint slack、DRV、top-K path matching 和 coverage；超阈值后撤销对应 dirty rule qualification。

## 12. Path explain 与 what-if

`path.explain` 输出 cell arc、net R/C、clock launch/capture、uncertainty/derate、constraint 和 CPPR 分量，所有分量带单位/source。分量求和必须与 path total 在容差内；不支持项进入 `unattributed`。

`timing.what_if` 只允许 registry 中的参数 overlay，例如 candidate cell delay/cap、net RC delta、clock latency bound。它返回估计 fidelity/uncertainty 和 invalid assumptions，不生成 TypedDelta 或 certificate；真正候选必须由 iTO/iNO/iCTS/iPL apply 后重新 STA。

## 13. Effort/Fidelity 具体配置

| 档 | topology/RC/scenario | 结果用途 |
|---|---|---|
| F0 | logic depth/fanout + estimated wire | 粗筛，不能 gate |
| F1 | common topology + estimated RC + limited approved scenarios | ranking/what-if |
| F2 | extracted/dirty RC + dirty cone + active scenarios + CPPR | Top-K candidate 验证 |
| F3 | full RC、required scenarios、full GBA + selected PBA audit | stage gate |
| F4 | PT/Spice 协议对拍 | calibration/release |

请求显式 F3 时不允许因预算静默退成 F1；可返回 `TIMEOUT/PARTIAL` + F2 incumbent 和所缺场景。PBA 需要输出 searched endpoints、budget、exhaustion 和 GBA/PBA delta。

## 14. LLD 细化

| 类 | 职责 |
|---|---|
| `TimingService` | context/session 生命周期、请求路由、只读 facade |
| `TimingResultBuilder` | typed metric/path/coverage/provenance |
| `PathIdRegistry` | stable match key、generation、ambiguity |
| `PathAttributor` | delay/clock/constraint/RC 分解与守恒 |
| `ConstraintAuditor` | unconstrained、exception/clock coverage |
| `DirtyConePlanner` | change->cone/scenario/path group 保守扩张 |
| `IncrementalAudit` | sampled/periodic full diff 与 qualification |
| `EffortPolicy` | F0-F4 config、budget、escalation，不复制图 |

迁移顺序是 iTO/iNO -> iPL -> iCTS -> iRT/evaluation；每个 consumer 先双跑 legacy/common 结果并记录分桶差异，再切换 gate truth source。

## 15. 失败语义、测试与 PR

状态包括 `INVALID_CONTEXT`、`UNCONSTRAINED/PARTIAL_COVERAGE`、`UNSUPPORTED_ANALYSIS`、`STALE_RC`、`TIMEOUT_WITH_PARTIAL`、`INCREMENTAL_MISMATCH`、`NUMERICAL_FAILURE`。WNS/TNS 查询不存在 clock/path 时返回 N/A + coverage，不返回 0。

CI：`STA-T01` setup/hold rise/fall，`STA-T02` generated clock/clock groups，`STA-T03` false/multicycle，`STA-T04` unit/RC corner，`STA-T05` path ID/matching ambiguity，`STA-T06` attribution 守恒，`STA-T07` 每类 dirty action，`STA-T08` random full/incremental fuzz，`STA-T09` what-if 无污染，`STA-T10` cancel/rebuild，`STA-T11` legacy/common diff，`STA-T12` PT coverage/bias/P95/worst/Recall@K。

PR：`STA-0 context/result/path schema` -> `STA-1 inspect/top paths/coverage` -> `STA-2 explain/constraint audit` -> `STA-3 dirty cone + full audit` -> `STA-4 iTO/iNO consumers` -> `STA-5 iPL/iCTS/iRT/evaluation migration` -> `STA-6 PBA/MCMM/F4 qualification`。
