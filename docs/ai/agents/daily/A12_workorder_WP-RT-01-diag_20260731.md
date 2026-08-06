# A12 工单 · WP-RT-01-diag · A0 下发 2026-07-31

你是 **A12 bench**。本工单是**诊断**，不是 QoR 交付。

## 目的

检验 A/B-1「ΔDRC≈0%」是否主要因 `MAX_BOXES=24` **预算淹没**。

## 跑法

- 设计：仅 **`aes_sky130_a`**
- 种子：与 A/B-1 相同（trueutil LG）
- baseline：杠杆关；treatment：`RULE_AWARE_COST=1` + `ENHANCED_MINAREA_REPAIR=1`
- **`IEDA_RT_MAX_BOXES=0`**（不截断）；`MAX_ITERATIONS=3`；`INITIAL_BOX_SIZE=48`；记录墙钟/内存
- 产出根：`benchmarks/results/wp_rt01_ab2_diag_<stamp>/`
- 一页结论：预算淹没？`yes` / `no` / `unclear` + DRC delta

## 禁止

- 改 `src/operation/` 冒充诊断
- 把本结果写成「≥20% 达标」

## 交回

写 `docs/ai/agents/daily/A12_bench_YYYYMMDD.md` 并 @A0；A0 再决定是否调整 P2 优先级。
