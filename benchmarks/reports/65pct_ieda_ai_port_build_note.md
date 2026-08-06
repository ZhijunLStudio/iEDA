# iEDA.ai 补丁移植与自编译验证（2026-07-30）

## 结论

65pct AES 用的 iCTS / iRT BEST_EFFORT 补丁已落在 **iEDA.ai 源码**，并用 **iEDA.ai 自编译** 的 `bin/iEDA` 完成 ASAP7@65% 冒烟（CTS→RT→filler→GDS）。

## 二进制

| 项 | 值 |
|----|----|
| 路径 | `/home/lxq/AiEDA/iEDA.ai/bin/iEDA` |
| md5 | `8d2eff5720a098928dbf599c52c55bb3` |
| 构建时间 | 2026-07-30 19:11 |
| 对比 sibling iEDA | md5 `0ba5fbd5...`（不同，非拷贝） |

## 移植内容（iEDA.ai 树内）

- **iCTS**: FastClusteringFinalize / SinkBranch / SourceTrunk* / TopologyPruning / DiscreteSolution
- **iRT**: DetailedRouter（手术式：MAX_BOXES / MAX_DR_SECONDS / task·path 上限 / skip uploadNetResult·patchFinalMinArea）、Utility soft-warn、MemoryBudgetGuard
- **独立构建修复**: macro_placer include/link、StaPathBased `<stack>`、BufferInserterConfig 传播

## 冒烟

- 结果根: `benchmarks/results/aes13_65pct_selfbuild_smoke_20260730_1911`
- design: `aes_asap7_a` @65% BEST_EFFORT
- CTS 7.1s / routing 555.6s / filler 8.7s / gds 281.2s → `final.gds` 存在
- RT 日志可见: `65pct guards`、`MAX_BOXES=2`、`skip uploadNetResult`、`skip patchFinalMinArea`
