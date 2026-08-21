# GPA 目标循环 Round 1 证据记录

日期：2026-08-21 晚
分支：feat/parity-gp-session（已推送 personal）
提交：8c7538d → 6782bd3 → ec5b5bf → 212b7ff → 002f59f → 0bcc713 → 2811f97 → 9f45508

## 1. 本轮做的工具改动（全部已验证端到端）

1. run record 统一带 def_hpwl（DEF 级 HPWL，与 verify metrics 同口径），
   local_run delta 增加 rutil。
2. verify metrics 按 (design, DEF 集合+mtime, model, timing) 缓存：
   实测同组 DEF 第二次调用 5s → 0s。
3. propose 全种类补 executable_action + 档位选项；
   新增 propose kind=timing（读缓存 iSTA 报告 → 路径实例集合）；
   propose regions priority=congestion（读缓存 RUDY map → region rect）。
4. observe kind=experiments：trace 聚合 + Pareto 表 + archive metrics。
5. 缓存预算按 source 拆分（run 128 / observe+verify 4000）。
6. start/full 暴露 timing=1（is_timing_effort + opt_overflow_list
   [0.15,0.20,0.25,0.30]），record 带 timing_weight_updates。
7. start 暴露 bin_cnt（写 is_adaptive_bin=0 + N×N 固定网格）。
8. propose_config 网格：congestion_effort 升级、timing_effort_on、
   phi、seed_anchor、congestion_grid_64。
9. verify lg 的 sky130 LEF 硬编码修复；status 带 def_hpwl；
   checkpoint 符号标签（latest/start）+ 递归列表；scope 前置校验。

## 2. 开放目标会话（4 个 PDK/规模，headless，只允许 ieda_gp_*）

| 会话 | 设计 | 状态 | 工具调用 | 插件级错误 |
|---|---|---|---|---|
| s1238 | sky130 小 | 已结束 | 56 | 0 |
| nangate | nangate45 小 | 运行中 | 40+ | 0 |
| asap7 | asap7 大 | 运行中 | 54+ | 0 |
| ihp130 | ihp130 中 | 运行中（b 次会话） | 27+ | 0 |

模型编排失败全部被结构化错误接住（freeze 缺 region、空 workdir、
checkpoint=start 等），无 traceback。

## 3. s1238 会话最终结果（同 evaluator，含 timing）

| 指标 | raw | candidate | innovus |
|---|---|---|---|
| HPWL | 5,957,257 | 5,934,445 | 8,053,041 |
| RUDY max | 2.768 | 2.207 | 2.035 |
| bins | 654 | 573 | 622 |
| rsum | 208.65 | 171.85 | 133.02 |
| WNS ns | -0.0503 | -0.0439 | -0.1341 |
| freq MHz | 645.0 | 647.7 | 612.0 |

- 五项全部超过 raw baseline；HPWL/bins/WNS 三项超过 Innovus；
  RUDY max 与 rsum 从 gap 大幅收窄但仍未超过。
- 候选 DEF：/tmp/my_goal_s1238/placement.def
  （effort=1 seed=3000 400it + 两次 region 疏散，共 480it）。
- 会话自述的结构性瓶颈：GP 拥塞感知网格（32×32 adaptive）
  与 verify RUDY（64×64）不一致，细粒度尖峰 GP 看不见。

## 4. 对网格对齐假说的独立 A/B（bin_cnt=64 旋钮）

| 配置（均 seed=3000, 400it, raw DEF 起点） | defHPWL | verify RUDYmax | bins | rsum |
|---|---|---|---|---|
| 会话 best（adaptive, effort=1 + 局部修复） | 5,934,445 | 2.207 | 573 | 171.85 |
| effort=1, bin 64 | 6,424,339 | 2.417 | 718 | 175.79 |
| effort=2, bin 64 | 6,289,620 | 2.635 | 682 | 206.34 |
| effort=3, bin 64（plain RUDY） | 6,312,418 | 2.833 | 631 | 208.27 |

结论：
- bin_cnt=64 对齐网格没有直接改善 verify RUDY；
- GP 内部 route_util（effort2 报 1.98）与 verify RUDYmax（2.635）
  存在模型校准差（route cap / demand spread / 惩罚形状），
  不只是分辨率问题；
- 目前最有效的仍是 agent 循环：effort=1 + 便宜的 congestion_hotspots
  复查 + region 疏散局部动作（把 verify RUDYmax 从 2.768 压到 2.207）。

## 4.5 nangate 会话最终结果（同 evaluator，含 timing）

| 指标 | raw | candidate | innovus |
|---|---|---|---|
| HPWL | 5,850,034 | 3,910,596 | 3,264,413 |
| RUDY max | 5.149 | 2.720 | 1.991 |
| bins | 289 | 362 | 328 |
| rsum | 330.65 | 176.10 | 100.39 |
| WNS ns | -1.186 | -1.178 | -1.207 |
| freq MHz | 598.3 | 601.2 | 590.8 |

- 对 raw：4/5 超过（bins 除外）；对 Innovus：WNS 超过，其余仍短。
- 关键发现（会话报告）：nangate45 的 registry 输入 DEF die 利用率
  0.839，而 Innovus DEF 为 0.772——Innovus 用了更大的 die，不是同口径
  起点。handover 的 2,775,743 最优候选正是从 Innovus DEF（同 die）
  起步所得。下轮应把 Innovus-die 输入 DEF 注册为 preset。
- 会话自创的有效手段：seed_anchor_strength=0.01 + 单步 advance 扫谷底
  （4.53M→4.06M→3.91M），tool 的 anchor 旋钮被正确组合使用。

## 4.6 Round 2 关键进展（2026-08-21 深夜）

### 修复两个"timing 无效"根因（此前困扰多轮的谜题）

1. **derived config 写入 bug**：workdir 未 mkdir 导致 pl_derived_config.json
   写入静默失败，GP 实际用 base config 跑（timing 从未开启），
   而 record 还谎报 timing_effort=true。已修（mkdir + 诚实 record）。
2. **计数 bug**：timing 更新日志走 stderr，旧代码只数 stdout → 恒 0。
   已修（stdout+stderr）。
   修复后 ihp130 timing=1 实测 **timing_weight_updates=2/60 iters**，
   机制确认工作——"config timing_effort 无效"正式结案。

### 修复后的 ihp130 timing+cong 结果（同 evaluator）

| 指标 | raw | candidate（timing1+cong3, 440it） | innovus |
|---|---|---|---|
| HPWL | 620,662,411 | 444,180,470 | 502,815,015 |
| RUDY max | 2.655 | **1.551** | 2.171 |
| bins | 1728 | 782 | 1099 |
| rsum | 784.41 | 132.08 | 245.28 |
| WNS ns | +0.459 | -1.148 | -1.024 |
| freq MHz | 220.2 | 162.6 | 166.0 |

- HPWL + 全部 3 项 congestion 超过 Innovus；
- WNS 从 handover 候选 -1.394 / Round-24 -1.154 改善到 **-1.148**，
  距 Innovus 只差 0.124ns、freq 差 3.4MHz。
- 正在跑 refinement：6 档 opt_overflow_list [0.10..0.30] +
  target_overflow 0.08 + 800it。

### nangate 同 die（公平口径）结果

| 指标 | raw | candidate（Innovus-DEF init, cong3, 342it） | innovus |
|---|---|---|---|
| HPWL | 5,850,034 | **3,180,729** | 3,264,413 |
| RUDY max | 5.149 | 2.947 | 1.991 |
| bins | 289 | **323** | 328 |
| rsum | 330.65 | 152.29 | 100.39 |
| WNS ns | -1.186 | **-1.192** | -1.207 |
| freq MHz | 598.3 | **596.3** | 590.8 |

- 同 die 起点下 HPWL/bins/WNS/freq 四项超过 Innovus，
  证明"nangate HPWL 落后"主要是 die 口径问题，不是 GP 能力问题。
- 剩余缺口集中在 RUDY max / rsum（C++ 校准方向不变）。

### asap7 会话最终结果

| 指标 | raw | candidate | innovus |
|---|---|---|---|
| HPWL | 58,392,975 | **37,735,561** | 45,224,840 |
| RUDY max | 1.697 | 2.492 | 0.706 |
| bins | 16 | 51 | 0 |
| rsum | 4.47 | 21.85 | 0 |
| WNS ns | -5.374 | **-5.236** | -7.392 |
| hold WNS | -2.061 | **-1.166** | -5.115 |
| freq MHz | 161.7 | **165.4** | 121.9 |

- HPWL/WNS/hold/freq 超过两个 baseline；congestion 受结构性
  fixed-macro 角落聚集限制，会话记录 Pareto 备选点（HPWL 17.4M/20 bins/max 5.76）。

## 5. 下一轮方向

1. C++：把 GP 拥塞目标对齐 run_congestion_eval 的 RUDY 模型
   （同几何、同 route cap、同 demand 估计），或直接在 GP 循环里
   以 verify RUDY 为 score 做后处理疏散（GR/congestion-aware）。
2. 等 nangate / asap7 / ihp130 会话收尾，收集最终对比表。
3. nangate 会话当前 best（3,910,596 / 2.72 / 362 / 176.1 / -1.178 /
   601.2）仍被 handover 的 Innovus-init 候选（2,775,743 / 3.084 /
   259 / 144.6 / -1.184 / 599.0）Pareto 纠缠：需要 Innovus-init 路径
   的系统引导（propose_config 的 seed_anchor / input_def=innovus DEF）。
4. 工具层：experiments 的跨 workdir 查询（传 design + 多 workdir），
   让新会话直接看到历史 Pareto。
