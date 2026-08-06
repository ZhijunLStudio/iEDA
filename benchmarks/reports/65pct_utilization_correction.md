# 65% 利用率校正说明

时间：2026-07-30 19:31 +0800

## 问题（用户质疑成立）

上一轮 `aes13_65pct_pass_20260730_1551` **口头目标 65%，实测 core util 远未达到**：

| PDK | 旧 die (µm) | 旧实测 util | 原因 |
|-----|------------|-------------|------|
| sky130 | 580 | **~27%** | `MIN_CORE_SIDE=500` 硬下限 |
| asap7 | 90 | **~29%** | `MIN_CORE_SIDE=70` 硬下限 |
| nangate45 | 206.6 | **~49%** | 边长额外 ×1.15 膨胀 |
| ics55 | 239.5 | **~49%** | 同上 |

报告 `aes12_65pct_detailed_comparison.md` 中 Core util. 列（27–29%/约 49%）已客观暴露该问题。

## 修复（`aes13_flow.py`）

1. 去掉边长 ×1.15 膨胀，使 `cell_area/core_area ≈ target`
2. 将 `MIN_CORE_SIDE` 降为工具安全下限（50/40/30/40），不再当“舒适 die”
3. `FLOW_ARTIFACT_VERSION=2`，签名纳入 die/util，避免 resume 沿用旧大 die

## 新 die（target=65%，effective=65%）

| PDK | 新 die (µm) | 新 core (µm) |
|-----|------------|--------------|
| sky130 | 404.3 | 324.3 |
| nangate45 | 184.9 | 144.9 |
| asap7 | 66.6 | 46.6 |
| ics55 | 213.5 | 173.5 |

## 重跑结果根

`/home/lxq/AiEDA/iEDA.ai/benchmarks/results/aes13_65pct_trueutil_20260730_1931`

## 实测确认（2026-07-30 21:20）

Floorplan `CORE Usage`：**65.0% – 65.3%**（12/12）。
全链路 DEF/GDS/power 已重写对比报告：[`aes12_65pct_detailed_comparison.md`](aes12_65pct_detailed_comparison.md)。
