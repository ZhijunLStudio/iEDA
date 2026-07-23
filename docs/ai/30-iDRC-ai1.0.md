<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 30 · iDRC Agent 增量检查与修复建议实施方案 · ai1.0

> 基线：`30-iDRC.md`。复用几何谓词、R-tree/cluster 和已有规则族；Agent 化核心是 scope 检查、rule coverage、可解释 violation 和 repair proposal。`SKIP != PASS`。

## 1. API

| API | 输出 |
|---|---|
| `drc.coverage` | PDK rule→checker 映射、checked/skipped/unsupported |
| `drc.check_scope` | region/layer/net 的 violations + halo |
| `drc.explain` | rule parameters、几何证据、相关对象 |
| `drc.cluster` | 可独立修复的 violation clusters |
| `drc.propose_repair` | move/shape/via/reroute proposals，不 apply |
| `drc.validate_delta` | before/after/new/resolved/residual |

## 2. Violation ID

稳定 ID 由 rule ID、canonical object IDs、归一化几何和 scenario/deck hash 组成。聚合显示不改变底层 violation 数；与 Calibre 对齐时同时提供 raw 和 cluster 两口径。

## 3. 增量范围

route/placement delta 的 bbox 按 rule 最大 interaction distance、相关 layer/via 和邻接对象扩张。若 rule 无有限 halo 或 coverage 未知，自动升级 full check/unsupported，不猜测局部安全。

## 4. LLD

```text
src/operation/iDRC/agent/
  DrcService.{h,cpp}
  RuleCoverageRegistry.{h,cpp}
  IncrementalScopePlanner.{h,cpp}
  ViolationId.{h,cpp}
  ViolationExplainer.{h,cpp}
  RepairCandidateGenerator.{h,cpp}
  DrcDeltaComparator.{h,cpp}
```

RuleCoverageRegistry 由 PDK adapter 生成并进 CI；规则实现仍在现有 validator 内。

## 5. Repair 策略

- spacing/short：move/shift/reroute/change layer；
- enclosure/via：replace/add metal/replace via；
- min area：patch metal，必须检查新 spacing；
- antenna/density 等未支持规则不得生成“已修复”结论；
- 每 proposal 标注可能新增的规则族和影响 scope。

## 6. 开发路径

| 阶段 | 内容 | 门禁 |
|---|---|---|
| DRC-A0（3 周） | coverage/violation schema/ID | skipped 注入不能 clean |
| DRC-A1（4 周） | incremental scope/full audit | full/local violation set 一致 |
| DRC-A2（3 周） | explain/cluster | 3 规则构造例几何证据正确 |
| DRC-A3（5 周） | repair proposal + iRT/iECO | new violation 为 0 才 accept |
| DRC-A4（持续） | rule deck compiler/Calibre align | coverage 与分桶 diff 门禁 |

## 7. 测试

- rule boundary ±1 DBU、touch/overlap、跨层/via、并行线程确定性；
- delta bbox 边缘外的 interaction；
- violation raw/cluster ID 稳定；
- repair 一个 rule 新增另一个 rule；
- empty deck、解析失败、unsupported rule；
- Calibre raw mapping 和聚合差异。

**H-DRC-A1**：有限 halo 的局部检查足以支持大多数 route ECO。若 full audit 发现远端新增，定位 rule/全局约束并把该规则标为 nonlocal，不能无界扩大默认 halo。

