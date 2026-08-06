# AES @ 65% × 12 — 真利用率结果

更新时间：2026-07-30 21:20（UTC+8）

## 结论

**12/12** 在 **实测 Floorplan CORE Usage ≈ 65%** 下完成全链路（DEF + GDS + STA + vectorless power）。

结果根：

`/home/lxq/AiEDA/iEDA.ai/benchmarks/results/aes13_65pct_trueutil_20260730_1931/`

详细对比报告：

[`aes12_65pct_detailed_comparison.md`](aes12_65pct_detailed_comparison.md)

## 实测利用率（Floorplan CORE Usage）

| PDK | die (µm) | core (µm) | CORE Usage |
|-----|----------|-----------|------------|
| sky130 | 404.3 | 324.3 | **65.1%** |
| nangate45 | 184.9 | 144.9 | **65.3%** |
| asap7 | 66.6 | 46.6 | **65.2%** |
| ics55 | 213.5 | 173.5 | **65.0%** |

Placement/Routing 后略升到 ~67–69%（缓冲/CTS 插入），符合预期。

## 相对旧报告

旧根 `aes13_65pct_pass_20260730_1551` 名义 65%，实测仅 ~27–49%（`MIN_CORE_SIDE` + ×1.15 膨胀）。已废弃作 65% 样本。

## 代码修复

1. `aes13_flow.py`：去掉边长 ×1.15；缩小 `MIN_CORE_SIDE`；effective util 偏离 target>3% 硬失败
2. `run_power`：支持 `-toggle` / `-allow_default_toggle`（vectorless）
3. 报告生成器：识别 ICS55 别名报表；按 DEF+GDS 判定流程完成度
