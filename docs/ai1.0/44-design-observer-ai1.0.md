<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 44 · Design Observer 与归因工具实施方案 · ai1.0

> 新建 Agent 专用只读工具包。复用 iDB/report/evaluation/feature/vectorization/iSTA/iRCX 等资产，为 Planner 提供结构化、可定位的设计理解。

## 1. 为什么独立建设

Agent 若只能调用“run STA”和读取长报告，会把大量推理预算浪费在文本解析，也无法证明分析绑定哪个状态。Observer 将跨工具只读信息汇成稳定对象 ID 和 evidence graph，不复制底层计算内核。

## 2. 工具集合

| 工具 | 输出 |
|---|---|
| `design.summarize` | 阶段、规模、场景、输入完整性、可用 capability |
| `design.query_objects` | 按类型/region/path/domain 的对象切片 |
| `state.diff` | typed change、dirty domain、metric delta |
| `path.explain` | cell/net/clock/constraint/RC delay attribution |
| `hotspot.cluster` | congestion/DRC/IR/power 空间簇和关联对象 |
| `metric.root_cause` | 观测证据、候选原因、反事实验证建议 |
| `trajectory.search` | 历史相似 snapshot 与成功/失败动作 |
| `design.risk_map` | OOD、coverage 缺口、硬门禁接近程度 |

## 3. Evidence Graph

```text
Snapshot ─contains→ Object
Metric ─measured_on→ Snapshot/Scenario
MetricDelta ─caused_after→ TypedDelta
Path ─contains→ Arc/Net/Cell
Violation ─touches→ Object/Region/Rule
Hypothesis ─supported_by/refuted_by→ Evidence
```

root cause 输出是带证据的假说，不得包装成确定事实。每个假说给 `confidence`、`missing_evidence` 和可执行杀死实验。

## 4. LLD

```text
src/observer/
  api/
  DesignSummary.{hh,cc}
  ObjectQuery.{hh,cc}
  EvidenceGraph.{hh,cc}
  PathAttributor.{hh,cc}
  HotspotClusterer.{hh,cc}
  RootCauseEngine.{hh,cc}
  TrajectoryIndex.{hh,cc}
```

feature/vectorization 只提供表示；Observer 负责 schema/provenance。所有缓存 key 包含 snapshot/scenario/tool/model hash。

## 5. 里程碑

| 阶段 | 内容 | 验收 |
|---|---|---|
| OBS-A0（2 周） | summary/object query | 对 10 设计无文本解析 |
| OBS-A1（3 周） | state.diff/path attribution | 分量和总量守恒在容差内 |
| OBS-A2（3 周） | hotspot cluster | 构造热点定位 Recall@K |
| OBS-A3（4 周） | root-cause hypotheses | 每结论带证据和杀死实验 |
| OBS-A4（4 周） | trajectory search | held-out 检索不泄漏同族样本 |

## 6. 测试

- 缓存陈旧、snapshot 切换、对象删除、同名不同 ID；
- path delay 分量求和；
- hotspot 平移/镜像 metamorphic；
- root cause 无证据时必须输出 unknown；
- trajectory 数据按客户/设计族隔离。

**H-OBS-A1**：结构化 path attribution 能显著减少 Agent 无效 ECO。以相同候选预算比较有/无 Observer 的 accepted-action rate；若无提升，检查 attribution 是否真正包含 constraint/RC/clock 分量。

---

## 7. Query/Evidence contract

```text
ObservationRequest
  snapshot/context refs
  selector {object IDs, region, path, domain, metric, violation}
  fields/relations/depth/limit/order
  evidence/fidelity/budget

ObservationResult
  status + typed objects/relations or artifact ref
  stable IDs/source snapshots
  coverage/completed/remaining selector
  hypotheses[] {claim, confidence, support, refute, missing, kill_experiment}
  provenance/cache/diagnostics
```

Query 默认分页并限制 graph depth/对象数；超预算返回 partial + resume token，不截断后声称完整。Observer 只消费已注册工具的 structured result，不从任意日志用 LLM 猜事实。

## 8. Evidence Graph 构建与 root cause

Evidence node/edge 均含 subject snapshot、context、source result hash 和 validity domain。TypedDelta 到 metric delta 只表达时间/实验关联，不自动标 causal。RootCauseEngine 流程：定位异常 metric/violation -> 汇集结构/path/hotspot/delta evidence -> 运行确定性规则与历史检索 -> 产生竞争假说 -> 列支持/反证/缺失 -> 生成最小反事实实验。没有可区分证据时 status 为 `UNKNOWN`。

Hotspot clustering 使用明确 grid/layer/distance 和 stable raw member IDs；cluster 可变不影响底层 violation/metric。Path attribution 的 cell/net/clock/constraint/RC 分量必须守恒到 path total。

## 9. Cache、失效与 CI

Cache key 包含 snapshot/context/query/schema/source tool/model hash。任何 source result/certificate 失效会沿 evidence dependency graph 标 stale；旧 hypothesis 保留审计但不返回为 current。

`OBS-T01` selector/pagination，`OBS-T02` same name/different ID，`OBS-T03` deleted/stale object，`OBS-T04` path attribution sum，`OBS-T05` hotspot translate/mirror，`OBS-T06` cluster/raw membership，`OBS-T07` competing hypotheses/no evidence，`OBS-T08` kill experiment refute，`OBS-T09` cache/source invalidation，`OBS-T10` tenant/family trajectory isolation，`OBS-T11` partial/resume，`OBS-T12` accepted-action A/B。

PR：`OBS-0 query/object schema` -> `OBS-1 evidence graph/state diff` -> `OBS-2 path attribution` -> `OBS-3 hotspot cluster` -> `OBS-4 root-cause hypotheses` -> `OBS-5 trajectory/experience adapter` -> `OBS-6 Planner A/B`。

## 10. Evidence Graph 存储 schema

```text
EvidenceNode
  node_id / kind / schema_version
  subject_ref {snapshot, object, metric, path, violation, delta, hypothesis}
  context refs / payload_ref
  source tool/model/result hashes
  coverage/validity/invalidation dependencies

EvidenceEdge
  edge_id / type
  source_node / target_node
  semantics = contains|measured_on|changed_by|touches|supports|refutes|derived_from
  source result/ref + confidence/assumptions
```

Graph 是 append-only evidence index，canonical facts 仍在 iDB/Metric/Certificate artifacts。相同 source result 可幂等 ingest；tool/parser/context 变化创建新 node，不原地改旧事实。`supports/refutes` 只能引用显式规则/实验/模型结果，语言模型叙述本身不生成 evidence edge。

查询存储分两层：按 snapshot/object/type/source 的结构化索引；大 path/map/trace 在 CAS。Graph traversal 设置 edge type allowlist、depth、node/byte budget，返回 completed frontier 和 resume token。

## 11. 各 capability 的执行算法

| Capability | 算法步骤 | 完整性条件 |
|---|---|---|
| `design.summarize` | state/intent/tech/tool capability/coverage 聚合 | required source refs resolved |
| `design.query_objects` | selector -> stable IDs -> typed projection/pagination | selector coverage 可说明 |
| `state.diff` | ObjectId/generation + typed field/relationship diff | before/after context 可比较 |
| `path.explain` | iSTA path -> arc/cell/net/clock/constraint/RC attribution | 分量和 total 守恒 |
| `hotspot.cluster` | raw map/violations -> normalized spatial graph -> clusters | raw membership 全保留 |
| `metric.root_cause` | anomaly -> evidence collection -> competing hypotheses | support/refute/missing 全列出 |
| `trajectory.search` | hard context filter -> Experience query -> applicability | tenant/family/PDK policy通过 |
| `design.risk_map` | gate distance + coverage/OOD/stale evidence | 不把 unknown 变 low risk |

`design.summarize` 不做所有昂贵分析，只说明当前可用/缺失 capability 和已有 current evidence。用户要求 fresh metric 时显式调用 iEval/tool。

## 12. RootCauseEngine 细化

```text
normalize symptom(metric/violation/path)
  -> identify changed state and affected stable objects
  -> gather current observations and before/after evidence
  -> run deterministic domain attribution rules
  -> retrieve similar success/failure cases after hard filters
  -> create mutually distinguishable hypotheses
  -> score evidence strength/applicability, not prose fluency
  -> propose minimal kill experiments and required fidelity
```

Hypothesis schema：claim type、subject scope、support/refute/missing refs、confidence kind（rule/calibrated/model/unknown）、applicability、kill experiment、status（open/refuted/confirmed）。只有注册 validator/反事实实验满足 confirmation policy 才可 confirmed。

示例 timing root cause 分桶：constraint/clock、cell arc、net RC/coupling、slew/load、physical detour、scenario/coverage。若 path delay 分量无法守恒，先产生 `attribution_incomplete`，不继续给确定性 resize 建议。

## 13. Hotspot 与 risk map 数据口径

所有空间输入先转换到 `GridRef{origin, step, nx, ny, layers, transform}`。不同 grid 通过保守重采样 operator 对齐并记录误差。Cluster ID 由 source result、raw member IDs、algorithm/version/params 生成；参数变化产生新 cluster，不破坏 raw violation ID。

Risk map 是多通道 artifact：hard gate distance、coverage gap、OOD、certificate freshness、activity/constraint/rule缺口和 action blast radius，禁止压成无解释单值。Planner 可按通道查询，iEval/Verification 仍决定 gate。

## 14. 增量构建、cache 与一致性审计

State/Metric/Certificate event 到达后，Ingestor 解析 dependencies，标旧 nodes stale 并构建新 nodes/edges。处理采用 event_id 幂等、snapshot sequence 有序；乱序事件进入 pending queue，缺 predecessor 超时后标 graph partial。

Cache key 包含 query canonical form、snapshot/context、graph revision、source tool/model 和 permission view。不同 tenant/ACL 的结果不共用 serialized cache。定期从 canonical artifacts 重建抽样 subgraph，与在线增量图比较 node/edge/validity，差异触发 quarantine。

## 15. Timing Lab 观察闭环

```text
summarize post-place snapshot
  -> top_paths + path.explain
  -> root-cause hypotheses and kill experiments
  -> Planner requests iTO proposals
  -> state.diff + metric delta after branch runs
  -> hypotheses supported/refuted
  -> risk_map before selection
  -> store evidence graph refs in DecisionRecord/ExperienceCase
```

衡量 Observer 价值用相同 candidate/F3 预算下的 accepted-action rate、selection regret、无效 action 类别和 diagnosis-to-verified 时间；不以生成解释字数评估。

## 16. 完成定义

- 所有观察绑定 immutable snapshot/context/source/coverage；
- path attribution、cluster membership 和 state diff 有守恒/独立 oracle；
- root cause 无证据时输出 unknown，且每个开放假说有 kill experiment；
- source 失效可传播到 graph/query/cache；
- 大图查询支持分页、预算和 resume；
- Experience/Model/Planner 不可绕过 tenant/family/PDK hard filter；
- Timing Lab A/B 证明观察信息是否减少无效候选。
