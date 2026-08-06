# A1 Verdict — WP-IRT-MAP-01（C-CONG）

> 审查对象：[A5 rt](d28d855f-f912-4f52-8f40-69892e858017)
> 日期：2026-07-30

## Verdict: **ACCEPT**（Congestion 测量面 → `trusted` 路径开启）

| 检查 | 结果 |
|---|---|
| 根因可复现 | Pass — feature_path/output_path 不一致导致 -1 |
| 禁止 -1 进报告 | Pass — `isValid()` 失败写 N/A；JSON 无 sentinel |
| C-CONG schema | Pass — RFC + `congestion_summary.*` |
| 与 EGR CSV 一致 | Pass — sky130 样例 total/max 对齐 rpt |
| 缺省零回归 | Pass — 有 JSON 优先，legacy rpt 仍可用 |
| 完整 iEDA link 构建 | **未在本机验证**（依赖缺失）— 标观测：合入后需完整 build 再跑 metrics |

## 标签

- Congestion summary：**可升 `trusted`**（在完整 build + metrics 复跑确认写 JSON 后）
- 当前对已有 CSV 离线聚合：**proxy→trusted 候选**

## 不在本 WP 范围

- WP-RT-01 plateau 外环（仍 locked）

## 协调板动作

WP-IRT-MAP-01 → `done`；C-CONG → `accepted`（待 A7 ACK 可后补）
