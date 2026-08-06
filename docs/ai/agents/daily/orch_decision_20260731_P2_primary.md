# A0 决策 · 2026-07-31 · WP-RT-01 后路

> 回应：[`orch_inbox_A5_WP-RT-01_20260731.md`](orch_inbox_A5_WP-RT-01_20260731.md)

## 裁决

**采用 P2 为主路径，P1 为有限诊断（单设计），禁止把去 MAX_BOXES 当作 QoR 交付。**

理由：

1. A0 纪律禁止用 `MAX_BOXES`/BEST_EFFORT 扫参冒充算法 WP。
2. A/B-1 已证明「加权+min-area 候选」在截断预算下无效；路线图 WP-RT-01 原目标本是 **plateau→冲突分量 escalate + 规则 repair**——P2 才对齐。
3. P1（`MAX_BOXES=0`）只用于杀死/支持「预算淹没」假说，由 A12 跑 **仅 aes_sky130_a**，结果标签 `proxy` / `diagnostic`，**不得**写进 ≥20% 成功叙事。

## 工单

### WP-RT-01b（A5 · 主）

- `src_paths=src/operation/iRT/`
- 内容：
  1. 冲突连通分量 escalate（仅 hotspot 分量扩 halo / 提高 history；禁止全局盲目 box×2 为唯一手段）
  2. PRL + metal_short 专项 repair（缺省 OFF）
  3. 与 A6 推进 **C-VIO** 草案字段
- 假说 H3：分量局部 escalate 可降稳定热点 DRC ≥20%（proxy）
- 杀死实验：开杠杆后热点集合 Jaccard 不降且 DRC 不降 → 杀 H3
- Done：diff + 缺省零回归 + A/B（可与 diag 结果对照）+ 请 A1 审

### WP-RT-01-diag（A12 · 诊断）

- 仅 `aes_sky130_a`；种子同 A/B-1；treatment 同杠杆；**`MAX_BOXES=0`**（或极大）
- 超时建议 ≥4h/stage；记录墙钟与是否 OOM
- 产出：`benchmarks/results/wp_rt01_ab2_diag_<stamp>/` + 一页结论：预算淹没？Y/N/unclear
- **不算** WP-RT-01 Done

### WP-DRC-01 / WP-PL-01

- A6 / A7 按 prompts 立即开工（Wave-1 `open_limited`）

## A1

- A/B-1：**REJECT ≥20%**（evidence=Δ≈0%）
- 可审 WP-RT-01 缺省关代码质量；不签发 QoR 成功
