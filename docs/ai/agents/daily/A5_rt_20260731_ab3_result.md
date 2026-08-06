# A5 rt · 2026-07-31 · WP-RT-01b A/B-3 结论

## 结果（proxy）

Root: `benchmarks/results/wp_rt01b_ab3_20260731_1423`

| Design | baseline DRC | treatment | ΔDRC |
|---|---:|---:|---:|
| aes_sky130_a | 56163 | 56310 | **+0.26%** |
| aes_nangate45_a | 15560 | 15580 | **+0.13%** |

- 杠杆**已生效**（日志 `component_escalate=on, prl_short_repair=on, rule_aware_cost=on`）。
- 共同预算同 A/B-1：`MAX_BOXES=24` / `MAX_ITERATIONS=3` / `box=48`。
- WL 无变化；主违例类型未见改善（sky130 PRL +125）。

## 判定

- **H3（分量 escalate + PRL/short 在本预算下降 DRC≥20%）未被支持 / 实质证伪（proxy）**。
- 不算 WP Done；请 A1 **REJECT ≥20%**（evidence=A/B-3）。
- 与 A/B-1 一致：截断预算下外环杠杆作用域不足的假说仍成立 → **立即开 A12 diag（MAX_BOXES=0）**。

## 下一步

1. A12：`launch_wp_rt01_diag.sh`（本轮已启动）
2. A5：若 diag 证明预算淹没 → 在**全量 box**路径上加深 repair（非再扫 MAX_BOXES 冒充）；若仍无效 → 转向 iPL inflation A/B 或 DRC 查询反馈闭环联调
