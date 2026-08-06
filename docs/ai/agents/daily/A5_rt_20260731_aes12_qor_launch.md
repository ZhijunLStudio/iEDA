# A5 · 2026-07-31 · AES12@65% QoR 全量跑启动

## 代码修复（本轮）

末轮 plateau 时 **追加最多 2 轮** mild-escalated DR iter（`IEDA_RT_COMPONENT_EXTRA_ITERS`），再跑分量 escalate。修复 A/B-3「plateau@iter3 未触发 Component escalate」空洞。

单测：`irt_dr_conflict_escalate_test` / `irt_dr_rule_aware_cost_test` 通过；`bin/iEDA` 已重链。

## 全量跑

- Root：见 `benchmarks/reports/aes12_65pct_qor_current_result_root.txt`
- 12 设计 @ 65%；种子 trueutil LG
- 杠杆全开；`MAX_BOXES=48`，`MAX_ITERATIONS=5`
- 完成后自动生成：`benchmarks/reports/aes12_65pct_qor_wp_rt01b_comparison.md`（体例对齐原 detailed_comparison，并附 vs trueutil ΔDRC）

## 运行确认（15:36+）

- env 注入：`IEDA_RT_RULE_AWARE_COST=1` 等均已进 iEDA 进程
- `printConfig` 里开关仍为 0（tcl 无 key，属预期）；DR 启动时 env 覆盖生效
- 日志：`rule_aware_cost=on, enhanced_minarea=on, component_escalate=on, prl_short_repair=on`（sky130×3 + nangate45_a）
- nangate45_a：iter3 plateau 后进入 escalate/加轮路径（修复生效）
