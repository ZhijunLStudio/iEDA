# AES @ 65% × 12 分析报告

更新时间：2026-07-30 18:30（UTC+8）

对照文档：`docs/ai/65pct_failure_root_cause_analysis.md`

## 1. 目标与判定标准

用户要求：4 工艺 × a/b/t = **12 版 AES**，在 **65% utilization** 下跑通，产出各阶段 DEF / GDS / 报告；卡住就改 iEDA 代码/算法；**先跑通，指标好坏不挡路，但结果必须客观真实**。

本次判定“跑通”= 全阶段关键产物存在且非空，**不**要求：

- DRC clean
- 全网连通无残差
- 时序/功耗达标

## 2. 根因对照（实践验证）

根因文档指出主历史卡点是 **DetailedRouter violation 爆炸/hang**，而非 cell 爆炸或 FP 硬拒。

本轮实践补充：

| PDK | 65% 实际卡点 | 处理 |
|-----|--------------|------|
| sky130 / nangate45 / ics55 | 主要在 iRT DR；用 MAX_BOXES + BEST_EFFORT 打通 | 已全链路 |
| asap7 | **CTS** 先于 RT：clustering → HTree sink-load 过滤清空 → source trunk 边界 | 多层 BEST_EFFORT |
| asap7 | CTS 后 **iTO drv 历史性 hang** | flow 软复制 CTS DEF |
| asap7 | DR **单 box 可达 20+ 分钟无进度** | task/path/时间截断 |

## 3. 代码/算法改动清单（先跑通）

补丁落地在 `/home/lxq/AiEDA/iEDA`（同步二进制到 `iEDA.ai/bin/iEDA`）：

1. **iCTS FastClusteringFinalize**：BEST_EFFORT 接受 illegal singleton
2. **SinkBranch / SourceTrunk**：`allow_boundary_relaxation` 跟随 BEST_EFFORT env
3. **TopologyPruning / DiscreteSolution**：sink-load 过滤为空时回退 raw / uncovered pool；缺合法性时继续
4. **SourceTrunkSegment / SourceTrunk**：cap index 钳位；segment 失败可保留 direct reconnect
5. **DetailedRouter**：
   - MAX_BOXES 在并行循环内原子截断
   - BEST_EFFORT 单 pass、cap tasks/paths
   - `IEDA_RT_MAX_DR_SECONDS` / `MAX_BOX_SECONDS`
6. **aes13_flow.py**：BEST_EFFORT 下 to_drv/hold 复制前级 DEF；resume 不误删已有 LG/CTS 进度

## 4. 客观结果

- **12/12** 全链路产物齐全（见 `65pct_aes12_final_report.md`）
- 结果根：`benchmarks/results/aes13_65pct_pass_20260730_1551/`
- ASAP7 GDS ≈ 146 MB；sky130 ≈ 113 MB

## 5. 质量风险（必须写明）

1. **DR 截断**：仅处理少量 box / 少量 task，大量 net 可能仍为 track-assign / 全局线网，**高残差 DRC 预期内**
2. **ASAP7 CTS 软拓扑**：非法 cluster + 无 sink-load 覆盖的 HTree，时钟树质量差
3. **ASAP7 to_drv/hold 未真实优化**：产物是 CTS DEF 拷贝，后续 legalization 从该 DEF 出发
4. **指标不可用于商业对比**：只能证明“工具链在 65% 下能吐出阶段文件”

## 6. 后续若要“真跑通质量”

优先级建议（与本次目标正交）：

1. 修 ASAP7 CTS sink-load / monotone prune 真因，而不是 raw frontier 回退
2. 修 iTO drv 在 ASAP7 上的 hang（非跳过）
3. 逐步提高 `MAX_BOXES` / 关闭 BEST_EFFORT，用 plateau 软停替代硬截断
4. 将 `/home/lxq/AiEDA/iEDA` 补丁回灌 `iEDA.ai` 源树并修复其独立编译

## 7. 相关报告

- 进展：`benchmarks/reports/65pct_aes12_progress.md`
- 本分析：`benchmarks/reports/65pct_aes12_analysis.md`
- 最终：`benchmarks/reports/65pct_aes12_final_report.md`
- 结果指针：`benchmarks/reports/65pct_current_result_root.txt`
