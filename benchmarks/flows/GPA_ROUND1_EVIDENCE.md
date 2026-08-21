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

### Round 2 新增工具修复

- **context clobbering bug（重要）**：插件对所有 run 命令都传
  record.input_def/pl_config，导致从 Innovus DEF 起步的会话在下一次
  restore/local_run 时被 registry 默认 DEF 覆盖 → "config fingerprint or
  design topology mismatch"。已修：只有 start 建立 context，其余命令继承
  workdir 保存的 input_def/config。修复后 ihp130 timing 会话的
  local_run（32 active + 1321 halo）成功执行。
- local timing-path repair 实测：WNS -1.148 → -1.156（微劣），
  hold +0.302 不变；印证 Round-25 结论：scope=instances 局部动作对
  ihp130 关键路径作用有限，timing 主要靠 GP 内 timing_effort 权重。
- timing 权重更新计数修正（stdout+stderr）。
- opt_overflow_list 扩展到 [0.10..0.30] 六档；实测 6 次更新后
  WNS -1.196（比 4 档的 -1.148 差）→ 更新次数不是越多越好，
  说明权重更新的"最后几档"在当前 hold guard 下反向。

### ihp130 timing 配置扫描（timing=1，Innovus DEF 起点，seed=42）

| 配置 | defHPWL | RUDYmax | bins | rsum | WNS | freq |
|---|---|---|---|---|---|---|
| cong3, 4 档阈值, to=0.1, 440it | 444,180,470 | 1.551 | 782 | 132.08 | **-1.148** | **162.6** |
| cong3, 6 档阈值, to=0.08, 457it | 446,410,740 | 1.584 | 776 | 129.0 | -1.196 | 161.4 |
| cong1, 6 档, 388it | 443,195,931 | 1.711 | 847 | 157.14 | -1.154 | 162.5 |
| cong2, 6 档, 468it | 446,866,310 | 1.714 | 772 | 132.18 | -1.223 | 160.7 |
| Innovus | 502,815,015 | 2.171 | 1099 | 245.28 | -1.024 | 166.0 |

- cong3 + 4 档阈值（[0.15..0.30]）仍是 best：HPWL + 3 项 congestion 全超
  Innovus，WNS 距 Innovus 0.124ns、freq 差 3.4MHz。
- 6 档阈值/更多更新反而劣化 WNS（hold guard 反向效应）；
  cong1/cong2 的拥塞差、timing 也差。
- 正在跑 seed=1000/2000 验证 trajectory 变化。

### timing 权重"更新但不生效"之谜（下轮 C++ 方向）

- 证据：cong3 Innovus-init 的 placement 在 timing on/off、
  4 档/6 档/窗口化阈值下 **bit-identical**（hpwl 433,658,002 完全一致），
  尽管 updateTimingNetWeight 被计数到 2-6 次、in-GP STA 成功运行
  （144s/次）。
- 疑点：printNesterovDatabase 显示 "Set NetWeight Num : 0"——
  更新后的权重没有落到任何 net，或权重梯度对该设计轨迹无影响。
- 下轮：在 updateTimingNetWeight 里记录 nonzero delta/centrality 分布，
  对照 in-GP iSTA 与外部 run_timing_eval 的 slack 是否一致；
  若 in-GP centrality 退化（全 0），定位 in-GP STA 的 RC/clock 初始化差异。

## 4.7 ihp130 timing 权重 no-op 的完整诊断链（Round 3，已插桩实证）

1. 插桩（b671de5，logging-only）：每次 timing 更新打印
   max_centrality / nets_with_weight_change / max_weight_delta /
   late_wns。实测：max_centrality=0、weight_change=0、late_wns=+1.34。
2. 代码根因一（行为层）：get_node_criticality 里
   if (wns > 0) return 0.0f; —— in-GP STA 报 WNS 为正，
   所有 net criticality/centrality = 0 → 权重恒不更新。
3. 代码根因二（模型层）：同一 placement（Innovus DEF），
   in-GP STA（InitSTA::updateTiming，pin-pair HPWL RC）报 +1.34ns，
   外部 run_timing_eval（HPWL）报 -1.024ns —— in-GP RC 模型比
   外部乐观约 2.4ns（wire_length/dbu 换算或 pin-pair 分段差异待查）。
4. 反证：s1238 上 timing mode 有效（外部 WNS 0.063→0.133，
   HPWL 代价 0.09%~1.35% 说明权重非零）——in-GP STA 在 sky130 上
   尚能给出负 WNS，ihp130 上则整体偏正。
5. 下轮修复顺序：先查 InitSTA::updateTiming 的 dbu_unit 取值与
   单段 RC（log wire_length/cap/res），对齐外部 HPWL evaluator；
   再把 wns>0 的硬截断改为基于 slack 裕量的连续 criticality
   （避免 STA 一旦偏乐观整个 feature 完全失效）。
### ihp130 target_overflow 扫描（cong3, Innovus DEF 起点, seed 42）

| target_overflow | iters | defHPWL | RUDYmax | bins | rsum | WNS | freq |
|---|---|---|---|---|---|---|---|
| 0.10 | 440 | 444.2M | 1.551 | 782 | 132.08 | -1.148 | 162.6 |
| 0.12 | 424 | 441.9M | 1.566 | 799 | 134.45 | -1.141 | 162.8 |
| 0.15 | 405 | 438.9M | 1.652 | 765 | 136.52 | -1.132 | 163.1 |
| 0.20 | 378 | 431.3M | 1.620 | 802 | 152.95 | -1.073 | 164.7 |
| 0.25 | 358 | 421.7M | 1.869 | 829 | 177.70 | -1.036 | 165.7 |
| Innovus | - | 502.8M | 2.171 | 1099 | 245.28 | -1.024 | 166.0 |

- 单调趋势：target_overflow 越大（越少扩散）WNS/freq 越接近 Innovus，
  HPWL 越低，RUDYmax/rsum 升高但仍全面低于 Innovus。
- to=0.25 时 WNS -1.036 距 -1.024 仅 0.012ns、freq 165.7 vs 166.0；
  正在跑 to=0.30/0.35 找 crossover 点——若 WNS/freq 越过而
  rutil 仍 < 2.171、HPWL 仍 < 502.8M，ihp130 即达成全方位超过。
### ★ ihp130 全方位超过 Innovus（to=0.3，crossover 达成）

| 指标 | raw | candidate（cong3, to=0.3, 342it） | Innovus | vs Innovus |
|---|---|---|---|---|
| HPWL | 620,662,411 | 410,214,665 | 502,815,015 | -18.4% ✅ |
| RUDY max | 2.655 | 1.866 | 2.171 | ✅ |
| bins | 1728 | 844 | 1099 | ✅ |
| rsum | 784.41 | 213.15 | 245.28 | ✅ |
| WNS ns | +0.459 | -0.988 | -1.024 | +36ps ✅ |
| freq MHz | 220.2 | 167.0 | 166.0 | ✅ |

- 候选 DEF：/tmp/my_ihp130_to_0.3/placement.def
- 六项指标全部超过 Innovus（含 timing 两项）——第一个达成
  “全方位超过 Innovus”的设计。
- 机制：cong3 从 Innovus DEF 起步，target_overflow=0.3 让 GP 在
  不过度扩散的前提下优化 HPWL/拥塞，WNS 只牺牲 36ps 仍优于 Innovus。
- to=0.35 的 rsum（249.8）略超 Innovus（245.3），不是全域赢家；
  to=0.3 是 crossover 最优档。
### s1238/nangate 更深拥塞推进（to 降低 + 继续扩散）结果：反向

| 实验 | defHPWL | verify RUDYmax | bins | rsum | 内部 rutil |
|---|---|---|---|---|---|
| s1238 best（effort1, to=0.1 + 疏散） | 5,934,445 | 2.207 | 573 | 171.85 | - |
| s1238 push（effort2, to=0.05, 482it） | 6,203,894 | 2.544 | 650 | 195.93 | 1.58 |
| nangate same-die best | 3,180,729 | 2.947 | 323 | 152.29 | - |
| nangate push（effort2, to=0.08, 341it） | 3,446,662 | 3.316 | 260 | 140.40 | 2.01 |

- 内部 rutil 改善（1.58/2.01）没有转化为 verify RUDY 改善——
  再次实证 GP 内部拥塞模型与 verify RUDY 校准不一致；
  单纯加强拥塞项不能闭合 s1238/nangate/asap7 的 RUDY gap。
- 下轮必须做 C++ 拥塞校准，或新增基于 verify RUDY map 的
  局部疏散原语（Python 侧读缓存 rudy_util.csv → 选 top overflow bin
  → scope=region 疏散循环），把 s1238 会话证明有效的手工循环
  变成工具内建的 local_congestion 动作。
## 4.8 Round 4：local_congestion 原语 + 状态指纹缓存 + s1238 Pareto 推进

### 新工具能力（已推送 e01eb85）

- ieda_gp_run kind=local_congestion：读 verify-RUDY 缓存的 map，
  取 top overflow bins 合并成 region（自动扩到 GP bin 尺度），
  循环 scope=region 疏散；divergence 自动 gentle retry；失败自动
  rollback 到调用前 checkpoint；调用前自动刷新 congestion map
  （按 DEF mtime 缓存，便宜）。
- 修复 run 缓存 soundness bug：缓存 key 只含参数不含状态，
  同一参数列表在不同起始 placement 上会命中陈旧结果。现在
  state-dependent 命令（advance/local_run/candidate/local_congestion/
  accept）的 key 含 checkpoint 路径+mtime 与 placement.def mtime；
  start/full 含 input_def+mtime。

### s1238 实测（工具循环：global spread → local_congestion）

| 点 | defHPWL | verify RUDYmax | bins | rsum | 说明 |
|---|---|---|---|---|---|
| 会话 final | 5,934,445 | 2.207 | 573 | 171.85 | effort1 to0.1 + 2 次手工疏散 |
| B（+lc 3轮） | 6,049,835 | **2.027** | 578 | 165.06 | RUDYmax 首破 2.035 |
| C（td0.5 全局） | 6,549,526 | 2.153 | 567 | **156.16** | rsum/bins 最优 |
| td0.45/to0.08 | 6,947,156 | 2.149 | 582 | 163.49 | 更散反而更差（非单调） |
| Innovus | 8,053,041 | 2.035 | 622 | 133.02 | - |

- 疏散对 RUDYmax 有效（2.207→2.027）、全局扩散对 rsum 有效
  （171.85→156.16），但二者不可兼得且 rsum 对 td 非单调——
  verify RUDY 与 GP 内部模型的结构性校准差仍未闭合；
  s1238 现为 4/6（HPWL/bins/WNS/freq），RUDYmax 差 0.12、
  rsum 差 23。C++ 拥塞校准是唯一剩余路径。
## 4.9 Round 5：congestion_effort=4 —— evaluator-aligned RUDY（C++ 校准基础）

- 新 effort 级别 4：GP 拥塞目标与 verify run_congestion_eval 完全同模型——
  demand = overlap_area×(1/h+1/w)（无 LUT、无 route-cap 归一、无 dm 因子、
  无 Gaussian blur），utilization = demand/bin_area，报告 union max。
- 同时把 -congestion_effort 校验放开到 4，propose_config 新增
  congestion_effort_4_evaluator 候选（带 bin_cnt=64）。
- 实测（s1238）：
  | 起点 | defHPWL | 内部 rutil | verify RUDYmax | bins | rsum |
  |---|---|---|---|---|---|
  | 会话 best（effort4, 400it） | 6,300,458 | 2.106 | 2.376 | 686 | 199 |
  | raw DEF（effort4, 600it） | 6,337,888 | 1.994 | 2.495 | 684 | 211 |
- 校准效果：内部 rutil 与 verify RUDYmax 同一量级且同向（1.99 vs 2.49），
  但 effort4 的固定点尚未超过 effort1+疏散 recipe（2.207/171.85）。
  剩余差距在 force shaping：penalty 已加到 0.5×over_util 仍收敛到同一点，
  说明需要对 >1.0 的 bin 施加更强的局部推力（或直接加拥塞梯度项）。
## 4.10 Round 6：effort-4 force 扫描 + 疏散深挖 + 第二代会话

- effort4 + super-linear penalty（0.5×over_util + 1.0×over_util²）扫描：
  td 0.6/0.7 从会话 best、td 0.5 从 raw——verify 结果全部劣于
  effort1+疏散 recipe（2.207/573/171.85），固定点对 penalty 不敏感。
- 疏散深挖（td0.5 点上 4 轮×3 bin）：rudy_max 2.153→2.116 但
  rsum 156→165、bins 567→590——溢出质量守恒式转移，疏散无法同时
  降 max 和 sum；**s1238 的 rsum<133 需要求解器级的全局扩散质量**，
  点工具层已到能力边界。
- 结论修正：s1238/nangate/asap7 的剩余拥塞缺口属于 C++ 求解器
  能力（密度扩散质量 + 直接 over-util 惩罚项），不是工具编排问题。
- 已启动第二代开放会话（s1238/nangate，携带已知配方：effort1+疏散、
  Innovus-die 起点、target_overflow 扫描、effort4/bin_cnt64）。
## 4.11 Round 7：aligned RUDY 单位校准 + 膨胀原型结论

- 发现并修复单位错位：aligned demand 少了 ×dbu 因子，内部 util 只有
  0.003 量级（verify 是 2.15），导致 effort4 的 penalty/inflation 阈值
  （>1.0）从未触发——此前 effort4 的"固定点不敏感"即由此而来。
  修复后内部 h/v max = 2.35/2.92，与 verify 同量级。
- 激活后的行为：super-linear penalty（×5.5）与 density-scale 膨胀
  （cap 1.4）都导致密度发散（overflow 0.1→1.2，40 iters 内崩溃式退化）。
- 隔离实验：只留 gentle penalty（1+0.05×over_util, cap 1.5）、移除膨胀——
  密度稳定（ov 0.162）但 verify 2.417/638/191.9 不优于起点。
- 最终交付（de281be）：dbu 校准 + gentle penalty 保留；膨胀原型删除
  并注释指向本记录。结论：in-loop 拥塞目标会破坏密度收敛平衡，
  s1238/nangate/asap7 的 rsum 缺口需要的是密度-拥塞联合目标的重构
  （超出点工具迭代范围），工具层保持 effort1+疏散 recipe 为当前最优。
## 4.12 Round 7 收尾：★ nangate 第二代会话达成 5/5 全胜 Innovus（独立复验）

| 指标 | raw | candidate（/tmp/my_goal2_nangate/placement.def） | Innovus | vs Innovus |
|---|---|---|---|---|
| HPWL | 5,850,034 | 2,768,159 | 3,264,413 | -15% ✅ |
| RUDY max | 5.149 | 1.896 | 1.991 | -4.8% ✅ |
| bins | 289 | 232 | 328 | ✅ |
| rsum | 330.66 | 75.66 | 100.39 | -25% ✅ |
| WNS ns | -1.186 | -1.197 | -1.207 | +10.4ps ✅ |
| freq MHz | 598.3 | 594.5 | 590.8 | ✅ |

- 配方（会话自发现 + 我独立复验）：start input_def=innovus_placed.def,
  random_init=0, seed_anchor_strength=0.5, congestion_effort=4, bin_cnt=64,
  iterations=150 → 局部关键路径锥修复。第二个全面超过 Innovus 的设计。
- s1238 同配方逼近：anchor+effort4 后 7,533,348 / 2.056 / 616 / 142.06 /
  -0.120 / 617.1 —— 5/6（RUDYmax 差 1%、rsum 差 6.8%），为 s1238 迄今
  最优点；后续疏散在该状态上反复发散或劣化，rollback 已修（私有副本）。
## 4.13 Round 8：asap7 anchor 家族 + s1238 固定点测绘

### asap7（Innovus-DEF anchor 家族，effort4+bin64）

| anchor | defHPWL | verify RUDYmax | bins | rsum |
|---|---|---|---|---|
| 0.1 | 45,051,840 | 0.773 | 0 | 0 |
| 0.3 | 43,297,776 | 0.791 | 0 | 0 |
| 0.5 | 41,694,997 | 0.803 | 0 | 0 |
| 0.7 | 36,932,804 | 0.912 | 0 | 0 |
| Innovus | 45,224,840 | 0.706 | 0 | 0 |

- anchor 越低越接近 Innovus（rudy_max→0.77 底线，HPWL→45.2M），
  rudy_max 收敛不到 0.706（GP 的 WL 目标仍会轻微聚集）。
- anchor0.5 全维度：HPWL 41.7M ✓ / rudy_max 0.803 ✗ / bins=rsum=0 ✓ /
  WNS -7.532 ✗（Innovus -7.392）/ freq 119.9 ✗；anchor+timing=1 的 6 次
  权重更新没有改善 WNS（与 ihp130 同类的 in-GP STA 乐观问题）。
- 结论：asap7 的 Innovus rudy_max 0.706/WNS -7.392 组合在当前 GP 能力
  下不可同时超越；gen-1 会话点（37.7M/2.492/51/21.85/-5.236/165.4）
  保持 asap7 的 HPWL/WNS/freq 最优，anchor 家族提供 bins/rsum=0 的
  另一 Pareto 端。

### s1238 固定点测绘（anchor+effort4 族，确定性收敛）

| 点 | defHPWL | verify RUDYmax | bins | rsum |
|---|---|---|---|---|
| anchor1（150it） | 7,533,348 | 2.056 | 616 | 142.06 |
| anchor2（+二遍 anchor 400it） | 7,407,426 | 2.393 | 570 | **124.29** |
| anchor2 + 疏散（任何参数） | 7,533,348 | 2.056 | 616 | 142.06 |
| Innovus | 8,053,041 | 2.035 | 622 | 133.02 |

- 疏散从任何近邻状态都收敛回同一吸引子（md5 级一致）；
  (2.056,142.06) 与 (2.393,124.29) 是当前工具可达的 Pareto 两端，
  Innovus (2.035,133.02) 严格优于两者——s1238 剩余 1%/7% 缺口
  为求解器级能力，点工具层已穷尽。
## 4.14 Round 9：local_congestion nets 模式 + s1238 强吸引子终证

- 新工具：local_congestion scope=instances 模式——用缓存 map 里的
  congestion_nets（穿过热 bin 的 net 的实例锥）做 scope=instances 疏散，
  而不是搬热 bin 里那几只 cell；gp_congestion_observe 同步落盘
  congestion_nets.json（提交 d126c9c）。
- s1238 终证：nets 锥疏散、region 疏散、任意参数组合，从 anchor 族
  任意近邻状态出发都确定性收敛到同一吸引子
  （7,533,348 / 2.056 / 616 / 142.06，md5 级一致）；rsum-124 点
  （2.393/570/124.29）只是该盆地的另一端点。Innovus (2.035, 133.02)
  严格占优且不在可达盆内——s1238 的局部动作空间已穷尽。
- asap7 gen-3 会话运行中（13+ 调用，正在用 local_congestion/
  propose congestion 探索 anchor 族之外的组合）。
## 4.15 Round 10：congestion-net 提取修复 + asap7 sub-1.0 攻防

- 修复 congestion-net 提取两个问题：① LEF 选择用 registry lef 而非
  foundry 目录第一个 lef（asap7 目录第一个 lef 无宏 → nets 恒空）；
  ② 无 overflow bin（util<1.0）时回退用 top util bins 做 net 锥种子
  （asap7 anchor 族正是这种 sub-1.0 拥塞）。提交 5a5de5a。
- asap7 net 锥疏散实测：anchor-0.2 点上 6 步 net 锥（n13005 等），
  rudy_max 0.776→0.783（微劣）——asap7 的 0.77 峰来自宏区的需求
  集中，缩短穿线 net 只搬移需求不降低峰值。
- asap7 anchor 族 rudy_max 底线确认为 0.77（Innovus 0.706 不可达）；
  gen-3 会话继续探索。
## 4.16 Round 14：asap7 gen-3 收尾（4/5）+ apply_anchor 落地（会话点名需求）

### asap7 gen-3 最终报告（4/5 vs Innovus，五指标）

| 指标 | candidate | Innovus |
|---|---|---|
| HPWL | 43,219,910 | 45,224,840 ✅ |
| RUDYmax | 0.7696 | 0.7058 ❌ +9% |
| bins | 0 | 0 ✅持平 |
| rsum | 0 | 0 ✅持平 |
| WNS | -5.816 | -7.392 ✅ +1.576ns |
| freq | 150.9 | 121.9 ✅ |

- 会话配方：anchor0.3+effort2+to0.002（100it）+ 最差 5 条时序路径锥修复。
- 会话点名缺失工具：apply_anchor（"把热区细胞拉回 Innovus 位置这一最对症
  手段不可用"）——本轮实现。

### apply_anchor 落地（提交 5fa3f66）

- 新 scope 原语：-scope_anchor_strength X (0,1]——in-scope Active 细胞的
  移动按 (1-X) 围绕会话锚点坐标（session start 时捕获的 input-DEF 位置）
  缩放；X=1 即冻结在锚点。
- 锚点坐标随 checkpoint 持久化（新增字段 + 旧 checkpoint 兼容回退），
  restore 之后锚点仍是原始 Innovus 位置。
- 工具层：ieda_gp_run kind=apply_anchor（strength/region/instances，
  发散自动回滚）；修复 Tcl option 未注册导致的 SEGV。
- asap7 实测：机制正确（锚点持久化验证通过），但热区细胞拉回对 0.77 峰值
  无改善（峰值由穿线 net 需求主导，非本地 cell 主导）——工具已交付，
  留待会话在适用场景（如宏相邻区域、局部密度异常）使用。

### 其他会话进展（运行中）
- apb4（75 calls）：15.66M/1.427/63/9.28/-0.544/489.2——HPWL/WNS/freq 领先，
  rudy_max 差 2%、rsum 差 24%。
- picorv32（42 calls）：232.1M/1.8/424/78.76/-4.172/149.9 六项全超 Innovus 的
  点仍在 session 手中，继续打磨中。
- aes（30 calls）：887.7M/1.741/740/127.9（HPWL 已 -23% 领先）。
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
