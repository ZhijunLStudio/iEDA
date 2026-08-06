# A5 工单 · WP-RT-01b · A0 下发 2026-07-31

你是 **A5 rt**。A0 已决策：**P2 为主**（本工单）；P1 诊断由 A12 跑，你不负责扫 MAX_BOXES。

## src_paths（强制）

`src/operation/iRT/`

## 目标

在 AES@65% proxy 下，通过**冲突连通分量 escalate** + **PRL/metal_short 专项 repair**，相对 A/B-1 baseline 争取 DRC ↓≥20%（标签 `proxy`）。缺省关闭 → 零回归。

## 必做

1. plateau 后只对稳定热点的 **violation 连通分量** escalate（扩局部 halo / 提高该分量 history·violation 权重）；禁止「全局 box×2」作为唯一策略。
2. PRL spacing + metal_short 的 repair/patch 路径加强（可开关）；min-area 已有增强则复用开关纪律。
3. 与 A6 对齐 **C-VIO** 字段草案。
4. 假说 **H3** + 杀死实验写进日报。
5. 合入后通知 A0/A12 做 A/B（可与 diag 对照）。

## 禁止

- 用加大 `IEDA_RT_MAX_BOXES` / BEST_EFFORT / 迭代次数冒充本 WP Done
- 宣称 trusted 时序改善

## Done 包

`src/operation/iRT/` diff + 缺省关零回归说明 + proxy A/B + 请 A1 审

日报：`docs/ai/agents/daily/A5_rt_YYYYMMDD.md`
决策依据：`daily/orch_decision_20260731_P2_primary.md`
