<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 23 · iCTS Agent 时钟树实施方案 · ai1.0

> 基线：`23-iCTS.md`。复用现有时钟拓扑/优化资产；优先解决 tree 可观察、提交闭环、common timing 和跨场景 setup/hold 风险。

## 1. Agent 能力

- 查询 clock tree 的 sink、buffer、latency、skew、load 和异常；
- 生成 topology/buffer/局部 skew target proposal；
- 在 branch 应用 clock delta；
- 强制合法化、局部布线、RC 和多场景 STA；
- 对 useful skew 动作给 setup/hold 双向证据。

## 2. API

| API | 说明 |
|---|---|
| `clock.inspect_tree` | 稳定 ID 的树、metrics、coverage |
| `clock.diagnose` | skew/latency/transition/load 根因 |
| `clock.propose_topology` | 多树候选，不 apply |
| `clock.propose_skew` | sink group target + 风险场景 |
| `clock.apply` | `ClockDelta`，branch only |
| `clock.validate` | legal/route/RC/setup/hold/DRV |

## 3. ClockDelta

包含插删/resize clock buffer、reconnect clock net、sink group/target、位置 hint、影响场景和逆操作。clock/reset 对象属于高风险，默认 F3 验证且 change budget 更小。

## 4. LLD

```text
src/operation/iCTS/agent/
  ClockTreeInspector.{hh,cc}
  ClockDiagnoser.{hh,cc}
  ClockCandidateGenerator.{hh,cc}
  UsefulSkewPlanner.{hh,cc}
  ClockDeltaAdapter.{hh,cc}
  ClockValidator.{hh,cc}
```

CTS 私有 fast timing 只可作为 F0/F1，并必须与 iSTA 对拍；终局一律 common iSTA scenario manager。

## 5. 开发路径

| 阶段 | 内容 | 门禁 |
|---|---|---|
| CTS-A0（2 周） | tree inspect/typed no-op/error | 空 sink、缺 master 响亮失败 |
| CTS-A1（3 周） | proposal/apply/rollback | tree connectivity 100% |
| CTS-A2（4 周） | legalize-route-RC-STA cascade | 任一步失败全回滚 |
| CTS-A3（4 周） | common timing + scenario | private/iSTA 分桶差异可见 |
| CTS-A4（5 周） | useful skew portfolio | setup 改善不以 hold 失败换取 |

## 6. 测试

- generated/ideal/propagated clock、多个 sink group、clock gating、dont_touch；
- buffer master 不存在、无合法位置、route 不可行；
- CPPR/latency/skew 单位与口径；
- 修改一个 branch 后其他 clock domain hash 不变；
- rollback 恢复 tree/placement/netlist/STA。

**H-CTS-A1**：common timing 重排 CTS 候选可降低“CTS 内部好、post-CTS STA 坏”的比例。若差异不降，先查 RC/clock propagation 语义，不盲调 topology cost。

---

## 7. Clock 数据契约

```text
ClockTreeView
  snapshot/scenario/clock IDs
  root/sinks/buffers/nets/levels + stable topology edges
  propagated/ideal/generated state
  per-node latency/slew/cap/fanout
  skew groups + setup/hold path groups
  placement/route/RC coverage

ClockProposal
  kind = topology|buffering|local_repair|useful_skew
  base_tree_ref / sink partition / target latency windows
  buffer family + location windows + route assumptions
  predicted skew/latency/power/setup/hold/DRV
  touched/frozen/change budget + required validators
```

sink 缺失、generated clock 关系不完整、ideal/propagated 混用或 clock master 不合格时，proposal 为 `UNSUPPORTED/PARTIAL`。时钟名字不能作为唯一 ID；ClockId 绑定 source pin、mode 和 intent ref。

## 8. Topology 与 useful-skew 算法

Topology generator 至少包含几何聚类树、平衡树和 timing-weighted tree 三个 family。流程为：规范化 sinks -> 按 region/domain/latency constraint 分组 -> 生成 branching points -> 选择 buffer family/级数 -> 给 placement windows -> F0 RC/skew -> Top-K branch apply。criticality 只影响候选排序，不能违反 max cap/slew/fanout。

Useful skew 以 sink group 的 arrival window proposal 表达，不直接“调一个 skew 值”。每个 proposal 同时计算：受益 setup endpoints、受损 hold endpoints、跨组/跨模式影响、CPPR/uncertainty 和允许 latency range。任一 required scenario 缺失时不得进入 apply；clock period/exception 不属于允许 action。

## 9. Apply 与验证 DAG

```text
acquire clock-domain lease
  -> verify proposal/base tree/intent current
  -> branch insert/delete/resize buffers + reconnect clock nets
  -> local legalize with clock-specific frozen scope
  -> local route/RC extraction
  -> common iSTA propagated-clock setup+hold+DRV
  -> skew/latency/power + route congestion/DRC
  -> full tree connectivity and sink coverage
  -> iEval gate -> ready or atomic rollback
```

`ClockDelta` 记录 sink-to-root connectivity before/after；apply 中途失败不能遗留半棵树。router 扩大 scope 或 legalizer 移动 data cells 时，实际 touched 超预算即拒绝。F3 full common timing 未完成前，候选只能用于实验，不能提交。

## 10. LLD 细化

| 类 | 职责 |
|---|---|
| `ClockTreeInspector` | 从 CTSAPI/common STA 构建 stable tree 与 coverage |
| `ClockDiagnoser` | 将 skew/latency/slew/load 分解到拓扑、位置、RC、master |
| `ClockCandidateGenerator` | 多 family topology/buffer/location proposals |
| `UsefulSkewPlanner` | scenario-aware sink window 与 setup/hold impact |
| `ClockDeltaAdapter` | 调现有 CTS mutation path，生成 typed delta/inverse |
| `ClockValidator` | sink coverage/connectivity/legal/route/RC/STA/DRV 分项 |

CTS 私有 timing 数据保留为 `cts.fast_timing` F0/F1 metric；结果 schema 必须标 estimator，不能复用 `timing.setup.wns` 的 F3 名称。

## 11. 失败语义与测试

| 状态 | 示例 |
|---|---|
| `INVALID_CLOCK_CONTEXT` | generated/propagated/clock group 不完整 |
| `INFEASIBLE_TOPOLOGY` | latency/load/placement window 同时无解 |
| `PARTIAL_ROUTE` | clock net 未全布通，不可形成完整 timing gate |
| `VALIDATION_FAIL` | hold/DRV/coverage/frozen 任一失败 |
| `STALE_PROPOSAL` | tree、intent、scenario 或 tech ref 变化 |

CI：`CTS-T01` empty/single/multi sink，`CTS-T02` generated/ideal/propagated，`CTS-T03` topology sink coverage，`CTS-T04` master/location infeasible，`CTS-T05` apply 故障回滚，`CTS-T06` setup/hold 双向，`CTS-T07` CPPR/单位，`CTS-T08` private/common timing diff，`CTS-T09` route/RC failure，`CTS-T10` clock domain frozen，`CTS-T11` cancel/resume，`CTS-T12` held-out topology regret。

PR：`CTS-0 tree inspect/schema` -> `CTS-1 topology proposal/delta` -> `CTS-2 legal-route-RC cascade` -> `CTS-3 common timing migration` -> `CTS-4 useful-skew portfolio` -> `CTS-5 anytime/benchmark`。
