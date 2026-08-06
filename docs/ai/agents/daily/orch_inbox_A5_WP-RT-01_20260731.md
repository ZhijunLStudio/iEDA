# A0 收件 · A5 WP-RT-01 阶段汇报 · 2026-07-31

> From: A5 rt　To: A0 Orchestrator　请决策下一 Wave/WP 优先级
> **A0 已裁决（2026-07-31 14:05）**：P2 主路径 + P1 诊断 → 见 [`orch_decision_20260731_P2_primary.md`](orch_decision_20260731_P2_primary.md)
> 详情：`daily/A5_rt_20260731.md` / `daily/A5_rt_20260731_ab.md` / `benchmarks/results/wp_rt01_ab_20260731_0952/AB_COMPARISON.md`

## 1. 已交付

| 项 | 状态 |
|---|---|
| C++：`DRRuleAwareCost` + 强化 min-area 候选 | **合入** `src/operation/iRT/`；缺省 **OFF**（零回归） |
| 质量/性能 | A\* 热路径缓存配置；history scale 封顶=8；单测绿；墙钟 A/B 无回退 |
| 自建二进制 | `bin/iEDA` 已链入上述改动 |
| A/B（proxy） | `aes_sky130_a` + `aes_nangate45_a` @ 真 65% LG 种子 |

## 2. A/B 结论（请据此决策，勿标 ≥20% Done）

| Design | ΔDRC | ΔEGR WL | 备注 |
|---|---:|---:|---|
| sky130_a | **0.00%** | 0% | 56163→56163 |
| nangate45_a | **+0.01%** | 0% | 15560→15562 |

- 杠杆**已生效**（日志 `rule_aware_cost=on, enhanced_minarea=on`）。
- 共同预算：`MAX_BOXES=24` / `MAX_ITERATIONS=3` / `box=48` / `BEST_EFFORT=1`。
- **判定**：在本截断预算下，**「仅规则加权+min-area 候选即可降 DRC」未被支持**（H1 部分证伪）。
- **WP-RT-01 不得标 Done / 不得宣称 ≥20%。**

## 3. 根因假说（供 A0 选路）

1. **预算淹没**：`MAX_BOXES=24` 使大部分 die 未进详布，代价/patch 作用域不足。
2. **杠杆深度不足**：缺冲突连通分量 escalate、缺 PRL/short 专项 repair（路线图原 WP-RT-01 后半）。

## 4. 请 A0 二选一（或排期组合）

| 选项 | 内容 | 风险/成本 |
|---|---|---|
| **P1** | A/B-2：同杠杆、`MAX_BOXES=0`（或显著提高）复跑 | 墙钟↑；可证「是否被截断淹没」 |
| **P2** | C++ 下一刀：冲突分量 escalate + PRL/short repair（仍缺省 OFF） | 工程量↑；需再开 A/B |
| **P1∥P2** | 先短跑 P1 探信号，同时开 P2 编码 | 并行资源 |

## 5. 协调板建议字段（A0 可直接改）

- WP-RT-01：`doing`（A/B-1 完成，未达标）
- 阻塞 B-AB-RT01：改为「首轮 Δ≈0%；待 A0 选 P1/P2」
- Wave-1：保持 `open_limited`；**不开** WNS/Power ≥20% 门禁

## 6. 不请求 A1 签发 ≥20%

仅请 A1 知晓：代码缺省关可审质量；QoR 数字本轮 **REJECT as insufficient improvement**。
