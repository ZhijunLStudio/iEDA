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

