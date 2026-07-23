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

