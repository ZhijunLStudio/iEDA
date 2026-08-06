# A0 Orchestrator rollup · 2026-07-31

## (1) 看板变更

- 采纳 A5 inbox：A/B-1 **不足 ≥20%**，WP-RT-01 保持 doing。
- **决策 P2 主 + P1 诊断**：新开 WP-RT-01b（A5）、WP-RT-01-diag（A12）；开闸 WP-DRC-01 / WP-PL-01。
- B-AB-RT01：从「等 A0」→「已决策，A5/A12 执行」。

## (2) 阻塞

| ID | 状态 |
|---|---|
| B-RCX-ITF | 仍堵 SPEF trusted |
| B-BASELINE | 未冻结 |
| B-AB-RT01 | **已决策** |

## (3) 给各 Agent 的下一指令

| Agent | 指令 | `src_paths=` |
|---|---|---|
| **A5** | 执行 **WP-RT-01b**：冲突分量 escalate + PRL/short repair；缺省 OFF；假说 H3 | `src/operation/iRT/` |
| **A12** | 执行 **WP-RT-01-diag**：仅 sky130_a，同杠杆，`MAX_BOXES=0`；出诊断结论页 | `benchmarks/`（禁止改算法冒充） |
| **A6** | 启动 **WP-DRC-01** + 与 A5 冻 C-VIO 草案 | `src/operation/iDRC/` |
| **A7** | 启动 **WP-PL-01**（inflation/routability，缺省关） | `src/operation/iPL/` |
| **A1** | 对 A/B-1 记录 **REJECT ≥20%**；可审缺省关代码质量 | — |
| **A3/A4/A9/A11** | 继续 Wave-0；PA/PNP/PLT 交 A1 审 | 各工具目录 |
| **A2** | SPEF 真值仍 BLOCKED；跟进 foundry ITF | `src/operation/iRCX/` |
| **A8/A10** | 仍 locked | — |

## (4) 是否请求 A1 审查

- **是（否定性）**：请 A1 对 WP-RT-01 A/B-1 出具 `REJECT ≥20%: reason=delta≈0; evidence=wp_rt01_ab_20260731_0952`。
- **否（肯定性 QoR）**：本轮无 ACCEPT ≥20% 请求。
- **是（质量）**：WP-RT-01b 缺省关 C++ 已合入（`DRConflictEscalate` + DetailedRouter 接线）；可审零回归/热路径，**不算** ≥20% ACCEPT。

## (5) 后续更新 · WP-RT-01b 代码合入（同日 14:20）

- A5 已落地：冲突分量 escalate + PRL/short 优先修；缺省 OFF；单测 `irt_dr_conflict_escalate_test` 通过；`bin/iEDA` 重链。
- C-VIO：A5 ACK RFC。
- **下一步**：A12/A5 跑 A/B-3（proxy）验证 H3；仍 **禁止** MAX_BOXES 冒充交付。
