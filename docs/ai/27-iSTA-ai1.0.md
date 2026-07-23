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

