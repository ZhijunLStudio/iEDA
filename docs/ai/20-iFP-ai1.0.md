<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 20 · iFP Agent 布图规划实施方案 · ai1.0

> 基线：`20-iFP.md`。复用 die/core/row/track、IO、tap/endcap 能力；宏摆放算法仍归 iPL，iFP 负责意图、边界和约束交接。

## 1. Agent 场景与边界

iFP 为 Agent 提供“生成和审计 floorplan 候选”的能力，不直接承诺一键产生最优 floorplan。首批场景：

- 从 netlist/宏/IO/利用率意图构造合法 die/core；
- 检查现有 floorplan 的行、track、IO、tap、halo/channel；
- 生成 IO/利用率/aspect 的多候选；
- 将宏约束交给 iPL 候选搜索；
- 在 F2 global place/global route 后比较候选。

## 2. API

| API | 类型 | 主要输出 |
|---|---|---|
| `floorplan.inspect` | read | die/core/row/track/IO/tap 完整性 |
| `floorplan.validate` | read | 几何、site、util、边界、coverage |
| `floorplan.propose_die` | proposal | aspect/util 多候选，不 apply |
| `floorplan.propose_io` | proposal | net-driven IO 候选和 cost 分解 |
| `floorplan.emit_macro_constraints` | proposal | halo/channel/orient/region |
| `floorplan.apply` | branch write | `FloorplanDelta` |
| `floorplan.compare` | read | 面积/早期 timing/congestion/PDN Pareto |

## 3. Delta 与不变量

```text
FloorplanDelta
  die/core/rows/tracks changes
  io_pin placements
  tap/endcap insertions
  macro constraints (not macro locations)
  invalidates = placement + route + RC + timing + PDN
```

硬不变量：die/core 坐标有序、site/grid 对齐、row 不越 core、IO 不重叠、tap/endcap coverage、所有 fixed macro 约束可表达。修改 die/core 是高 blast-radius 动作，只在独立 branch 运行。

## 4. LLD

```text
src/operation/iFP/agent/
  FloorplanInspector.{h,cpp}
  FloorplanValidator.{h,cpp}
  DieCandidateGenerator.{h,cpp}
  IoCandidateGenerator.{h,cpp}
  MacroConstraintEmitter.{h,cpp}
  FloorplanDeltaAdapter.{h,cpp}
```

复用 `api/ifp_api.*`，先修现有非法输入/失败返回；不得从 Agent adapter 绕过 iFP API 直接写 iDB。

## 5. Fidelity

| 档 | 实现 | 用途 |
|---|---|---|
| F0 | 面积公式、飞线、pin/macro 密度 | 生成 100+ 候选 |
| F1 | calibrated congestion/timing ranker | 排序 |
| F2 | iPL GP + iRT early GR + early PDN | Top-10 |
| F3 | 完整 place/CTS/GR/分析 | Top-2/提交 |

## 6. 开发路径

| 阶段 | 内容 | 门禁 |
|---|---|---|
| FP-A0（2 周） | inspect/validate + B1/B2 类边界用例 | 非方形 core、blockage、非法坐标全覆盖 |
| FP-A1（3 周） | die/IO proposal，proposal/apply 分离 | 100 候选不污染 base |
| FP-A2（3 周） | macro constraint schema + iPL 消费测试 | 写入与消费字段 100% 对账 |
| FP-A3（4 周） | F0-F2 portfolio | held-out 候选 selection regret 报告 |
| FP-A4（4 周） | 与商用 floorplan 同协议对拍 | 面积/拥塞/IO WL 分桶 |

## 7. 测试与假说

- 非方形 core、奇偶 row、manufacturing grid、无 IO、宏越界、tap blockage；
- IO pin 全排列不应因输入容器随机序导致质量漂移；
- floorplan apply→rollback 恢复 hash；
- constraint 写入但 iPL 不读必须 gate fail。

**H-FP-A1**：net-driven IO 相对等间距可降低 post-place IO-net WL 且不增 overlap。若 WNS/WL 无稳定改善，保留等间距为确定性 fallback，先查宏/内部逻辑主导程度。

