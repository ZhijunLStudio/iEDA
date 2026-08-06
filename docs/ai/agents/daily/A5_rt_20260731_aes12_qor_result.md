# A5 · 2026-07-31 · AES12@65% QoR 全量结果

## 结果

- Root：`benchmarks/results/aes13_65pct_qor_wp_rt01b_20260731_1520/`
- 报告：`benchmarks/reports/aes12_65pct_qor_wp_rt01b_comparison.md`（+ html/json/csv/assets）
- 12/12 success；CORE Usage ≈ 65%

## DRC vs trueutil

| PDK 族 | ΔDRC 大约 |
|---|---|
| sky130 | −2.2% |
| nangate45 | −1.8% ~ −2.0% |
| asap7 | −3.0% |
| ics55 | −4.4% |

均值约 **−2.9%**；**0/12** 达到 ≤−20%。

## 机制验证

- 杠杆 ON（DR adaptive schedule 日志）
- Component escalate：9/12
- 末轮 append extra DR：9/12（修复有效）

## 判定

- **REJECT / 未达标**（相对 ≥20% QoR 目标）
- 不可把 Δ 全记算法：预算 `MAX_BOXES=48` vs 基线 `4`；且 BEST_EFFORT 仍 cap 单 box tasks→4

生成：2026-07-31T17:54:30+08:00
