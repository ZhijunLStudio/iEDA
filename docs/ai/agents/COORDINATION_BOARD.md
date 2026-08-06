# AES12 QoR Agent 协调板

> 真相源：本文件。编排：[`../44-aes12-qor-agent-team-orchestration.md`](../44-aes12-qor-agent-team-orchestration.md)
> 路线图：[`../43-aes12-65pct-qor-optimization-roadmap.md`](../43-aes12-65pct-qor-optimization-roadmap.md) **rv1.2**（**§13 = 算法/C++ 手册**）
> 最后更新：2026-07-31 14:52（**A/B-3 不足 ≥20%；已开 A12 diag**）

## 执行纪律（rv1.1）

| 算交付 | 不算交付 |
|---|---|
| `src/operation/<tool>/` 或 `src/platform/` 的 C++ 算法改动 + A/B ≥20%（或 WP 阈值） | flow / BEST_EFFORT / MAX_BOXES / util DOE / 软跳过冒充 QoR |
| 工单含 `src_paths=` | flow-only diff（A1 REJECT） |

**结果根（真 65% util）**：`benchmarks/results/aes13_65pct_trueutil_20260730_1931/`
**WP-RT-01 A/B-1**：`benchmarks/results/wp_rt01_ab_20260731_0952/`（ΔDRC≈0%）
**WP-RT-01b A/B-3**：`benchmarks/results/wp_rt01b_ab3_20260731_1423/`（ΔDRC≈+0.1～0.3%，**不足**）
**AES12@65% QoR 全量（完成）**：`benchmarks/results/aes13_65pct_qor_wp_rt01b_20260731_1520/`；报告 [`aes12_65pct_qor_wp_rt01b_comparison.md`](../../benchmarks/reports/aes12_65pct_qor_wp_rt01b_comparison.md)（ΔDRC 均值约 −2.9%，**未达 ≥20%**；杠杆/escalate 已生效）
**A0 决策全文**：[`daily/orch_decision_20260731_P2_primary.md`](daily/orch_decision_20260731_P2_primary.md)

## Wave 状态

| Wave | Status | 说明 |
|---|---|---|
| 0 真值 | **in_progress** | SPEF 仍堵 ITF；PA/PNP/PLT 待 A1 审 |
| 1 DRC/WL | **open_limited** | A/B-3 验证 H3；C-VIO accepted-draft；PL 待开工 |
| 2–3 | locked | 待 SPEF / PDN |
| 4 契约 | **in_progress** | C-VIO **双方 ACK** + 缺省 OFF 写出 |

## WP 看板

| WP | Owner | Status | `src_paths`（主） | LastEvidence | A1Verdict |
|---|---|---|---|---|---|
| WP-IRT-MAP-01 | A5 | **done** | `src/operation/iRT/` | C-CONG | **ACCEPT** |
| WP-RCX-01 | A2 | **done（flow）** | `src/operation/iRCX/` | prepare-only | **ACCEPT（flow）**；SPEF BLOCKED |
| WP-STA-01 | A3 | doing | `src/operation/iSTA/` | read_spef | — |
| WP-PA-01 | A4 | review | `src/operation/iPA/` | activity_source.json | pending A1 |
| WP-PNP-00 | A9 | review | `src/operation/iPNP/` `iPDN/` | pdn_status.json | pending A1 |
| WP-PLT-01 | A11 | review | `src/platform/` | MoveTxn | pending A1 |
| **WP-RT-01** | **A5** | **doing · P2** | **`src/operation/iRT/`** | A/B-3 **不足**；末轮 plateau 未触发分量 escalate | A/B-3：**REJECT ≥20%** |
| **WP-RT-01-diag** | **A12** | **doing** | `benchmarks/` | `wp_rt01_ab2_diag_20260731_1450` 跑中 | 诊断 `proxy` |
| **WP-DRC-01** | **A6** | **doing** | **`src/operation/iDRC/`** | C-VIO JSON 写出缺省 OFF | — |
| **WP-PL-01** | **A7** | **doing** | **`src/operation/iPL/`** | congestion 缺省 OFF + density_scale 回退 | — |
| WP-TO/CTS/IR | A8/A10 | locked | — | Wave-2/3 | — |

## 契约

| 契约 | Status |
|---|---|
| C-CONG | **accepted** |
| C-SPEF | **accepted-draft** |
| C-ACT | draft |
| C-PDN | draft |
| C-TXN | accepted-minimal |
| C-VIO | **accepted-draft**（A5+A6 ACK；缺省 OFF 写出） |

## 活跃阻塞

| ID | 描述 | Owner |
|---|---|---|
| B-RCX-ITF | 无 ITF+captab → SPEF 不可 trusted | foundry |
| B-BASELINE | Wave-0 金基线未冻结 | A1 |
| B-AB-RT01 | A/B-1/A/B-3 均 Δ≈0%；**末轮 plateau 使分量 escalate 未落地** → 修 C++ + diag | A5 / A12 |

## 基线

Wave-0：**未冻结**。DRC/WL 继续用 **proxy**。

## A0 下一指令（立即）

1. **A5**：修「plateau 在末轮时仍 append escalate 轮次 / 立即对当前分量 boost」（否则 H3 测不到）。
2. **A12**：diag 已启动（`wp_rt01_ab2_diag_20260731_1450`）；出预算淹没结论页。
3. **A1**：对 A/B-3 签发 `REJECT ≥20%`（evidence=`wp_rt01b_ab3_20260731_1423`）。
4. **A7**：可并行准备 E-PL-01（congestion off/on）。
