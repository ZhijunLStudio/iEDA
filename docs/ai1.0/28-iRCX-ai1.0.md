<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 28 · iRCX Agent 寄生提取实施方案 · ai1.0

> 基线：`28-iRCX.md`。复用 2.5D topology/environment/R/C/SPEF/compare 资产；Agent 首要能力是 net/region 局部提取、分量解释、适用域和增量耦合一致性。

## 1. API

| API | 输出 |
|---|---|
| `rc.inspect_net` | wire/via/ground/coupling/topology 分量 |
| `rc.estimate_scope` | F0/F1 RC + uncertainty/domain |
| `rc.extract_scope` | dirty nets + coupling halo 的 F2/F3 RC |
| `rc.compare` | 两结果按 layer/pattern/net/sink 分桶 |
| `rc.update` | branch RC view + dirty timing seeds |
| `rc.audit` | coverage、pattern miss、units、full/incr consistency |

## 2. 增量所有权

```text
route delta
  → primary dirty nets
  → spatial halo neighbors
  → coupling pairs affected
  → remove old owned parasitics
  → rebuild topology/environment/R/C
  → atomically publish RcDelta
```

每个 coupling pair 使用 canonical `(min_net_id,max_net_id,segment_key)` 所有权，防止局部重提时双计或残留。

## 3. RcDelta

包含旧/新 R、ground C、coupling C、topology node/edge、units、corner、pattern coverage、dirty sinks 和 inverse/checkpoint。SPEF 只是 artifact，不是唯一内存接口。

## 4. LLD

```text
src/operation/iRCX/agent/
  RcService.{hh,cc}
  RcInspector.{hh,cc}
  DirtyNetPlanner.{hh,cc}
  CouplingOwnership.{hh,cc}
  IncrementalExtractor.{hh,cc}
  PatternCoverage.{hh,cc}
  RcResultBuilder.{hh,cc}
```

现有 full Extraction 作为 F3/fallback；第一版 incremental 可重建 dirty tile，而不是过早追求线段级 patch。

## 5. Fidelity 与适用域

| 档 | 内容 |
|---|---|
| F0 | HPWL/Steiner/layer-average RC |
| F1 | calibrated pattern/surrogate，必须 OOD 检测 |
| F2 | tile-local 2.5D extraction |
| F3 | full iRCX +完整 pattern coverage |
| F4 | StarRC/field solver |

pattern miss、via C/shield/multi-neighbor 未支持必须显式反映 coverage/uncertainty，不可全局 alpha 掩盖。

## 6. 开发路径

| 阶段 | 内容 | 门禁 |
|---|---|---|
| RC-A0（3 周） | net inspect/result schema | 分量与 SPEF 总量对账 |
| RC-A1（4 周） | dirty tile/coupling owner | 增量无残留/双计 |
| RC-A2（5 周） | incremental publish + iSTA | full/incr R/C/slack 分桶一致 |
| RC-A3（4 周） | pattern coverage/OOD | 域外不静默外推 |
| RC-A4（6 周） | via/multi-neighbor/shield priorities | 由 StarRC/field residual 驱动 |

## 7. 测试

- add/delete/move segment、replace via、same-net/cross-net coupling；
- dirty net 邻居未改但 coupling 改变；
- SPEF 单位、名称和 read-back；
- small C/R 同时报绝对/相对误差；
- full/incremental 随机 route delta fuzz；
- partial extraction 不得标 full coverage。

**H-RC-A1**：tile-level incremental 已能把 ECO 提取降至 full 的 10% 以内。若 halo 扩散主导，按 layer/spacing/coupling cutoff 做正确性受控优化，不先做线程微调。

---

## 8. Extraction request/result contract

```text
RcRequest
  snapshot/tech/scenario refs
  route_artifact_ref + route_generation
  scope {nets, segments, region, layers}
  corner/model/coupling policy
  fidelity/budget/seed

RcResult
  status / snapshot/scope/corner/model refs
  net parasitics[] {topology, wire_r, via_r, ground_c, coupling_c}
  coupling owners + dirty sinks/timing seeds
  pattern/model hits/misses
  completed/remaining scope + coverage/uncertainty/residual
  SPEF/result/evidence artifact refs
```

同一 net 的 total C 必须区分 ground 与 coupling；不同工具对 coupling 的 half/full split policy 进入 definition。SPEF read/write 的 unit、name-map 和 topology node identity 均必须显式，禁止仅比较文件大小或最终 WNS。

## 9. Topology、environment 与增量算法

```text
canonicalize routed shapes/vias by net/layer/coordinates
  -> split at pins/junctions/vias/coupling interaction points
  -> build connected RC topology
  -> query per-segment geometry/environment pattern
  -> compute wire/via R, ground C and pairwise coupling C
  -> assign canonical coupling owner
  -> reduce/publish RcDelta atomically
```

Dirty tile 首版流程：从 changed shapes/vias 得 primary nets -> 按最大合格 coupling distance 扩展 spatial halo -> 加入邻网和旧 coupling owners -> 移除该 scope 的旧寄生 -> 重建 -> 检查无残留/双计 -> 发布。若模型没有有限 halo、route generation 漂移或旧 owner 缺失，升级 full extraction。

### 9.1 Coupling ownership invariants

- pair key 为 `(min(netA,netB), max(netA,netB), canonical_segment_pair)`；
- 一个物理耦合只由一个 owner record 存储，victim view 通过引用展开；
- delete/move 任一 segment 必须删除所有反向索引；
- full/incremental 的 pair set、sum C 和 per-net view 在容差内一致；
- coupling cutoff 被剪枝的总量上界进入 uncertainty/coverage。

## 10. Fidelity 与路由/时序集成

| 档 | 前置/输出 | 禁止声明 |
|---|---|---|
| F0 | HPWL/Steiner + layer-average RC | extracted RC |
| F1 | pattern/surrogate + OOD/uncertainty | domain 外精度 |
| F2 | dirty tile 2.5D、coupling halo | full-chip coverage |
| F3 | full iRCX、完整 supported patterns | F4 signoff 等价 |
| F4 | field/StarRC protocol | 未对齐 corner/report point 的真值 |

`rc.update` 发布只读 RcView/RcDelta，由 iSTA 消费 dirty sinks；iRCX 不直接触发 STA 全局 singleton。route 变化但 RC 未更新时，TimingContext 标 `STALE_RC`，gate 不可通过。

## 11. LLD、失败与 CI

| 类 | 交付 |
|---|---|
| `RcInspector` | net/segment/via/environment 分量和 source |
| `DirtyNetPlanner` | primary/halo/neighbor/owner scope |
| `CouplingOwnership` | canonical pair/index/invariant checker |
| `IncrementalExtractor` | remove-rebuild-publish transaction |
| `PatternCoverage` | model hit/miss/OOD/cutoff bound |
| `RcResultBuilder` | typed RcResult/SPEF/evidence/dirty seeds |

状态：`MISSING_ROUTE`、`UNSUPPORTED_PATTERN`、`PARTIAL_COVERAGE`、`STALE_ROUTE_GENERATION`、`TOPOLOGY_ERROR`、`NUMERICAL_FAILURE`、`INCREMENTAL_MISMATCH`。任一 topology open 或 negative R/C 非 policy 支持都使结果失败。

CI：`RC-T01` single wire/via/branch 解析，`RC-T02` ground/coupling 守恒，`RC-T03` SPEF unit/name round-trip，`RC-T04` add/delete/move/replace via，`RC-T05` neighbor-only coupling dirty，`RC-T06` owner 无双计残留，`RC-T07` pattern miss/OOD，`RC-T08` incremental/full random fuzz，`RC-T09` RcDelta->iSTA slack，`RC-T10` F1/F3/F4 分桶误差与 rank。

PR：`RC-0 typed inspect/result` -> `RC-1 topology/pattern coverage` -> `RC-2 coupling owner/index` -> `RC-3 dirty tile transaction` -> `RC-4 RcDelta/iSTA` -> `RC-5 SPEF/full audit` -> `RC-6 F4 qualification`。
