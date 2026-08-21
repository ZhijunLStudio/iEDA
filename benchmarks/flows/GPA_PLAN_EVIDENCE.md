# GPA_NEXT_PLAN 验收证据

## P0

- checkpoint 等价：s1238 num_threads=1，`start(80)` 与
  `start(40)+advance(40)` placement.def 逐字节一致。
  md5 `8918bf9833c7c2726e4cc17606238556`。
- candidate 复现：同一 parent400 + longnet/active100/penalty0 跑两次，
  均 `incomparable`，记录 hpwl=5,811,234、overflow=0.107391，一致。
- 四设计 converged GP 结果均通过只读 LG oracle：

| design | lg_max_disp | lg_avg_disp | lg_hpwl | lg_success |
|---|---|---|---|---|
| s1238 | 3547 | 1071.44 | 6,117,295 | true |
| apb4_timer | 5012 | 1079.20 | 16,196,933 | true |
| picorv32 | 6050 | 1486.66 | 249,180,778 | true |
| aes | 5387 | 1248.62 | 692,987,095 | true |

- Harness 工具不返回 Innovus baseline：native six-entry 和 MCP 插件均无
  baselines/eval_def/full_compare。
- 失败回退：candidate 分支保留 parent checkpoint；local_run 在 accept 前
  先 restore，rollback 由工作目录 checkpoint 支持。

## P1

- 局部 GP 改善证据：apb4_timer fixed-longnet stage chain 最终 def HPWL
  15,595,418，优于同期 global 15,715,072（-0.76%）。
- 负结果/可复现：apb4 parent100 longnet candidate 多 seed
  (42/123/777) 全部 right_better，local 未在 parent100 单步获胜；
  s1238 parent400 longnet 两次复现 incomparable。
- dirty closure：`gp_verify_delta` 返回 moved cell 数量、top moved cells、
  affected net 数量、affected net HPWL delta 和 top affected nets。
- 局部动作记录：candidate / local_run 均写入 gp_experiments.jsonl 和
  checkpoint 文件。


## 跨设计 / 跨 PDK 验证现状

### 可执行矩阵

| PDK | 设计 | 直接 GP | 细粒度 chain | Innovus 参考 | 结论 |
|---|---|---|---|---|---|
| sky130 | s1238 | 5,957,257 | 5,982,121 (+0.42%) | 7,417,394 | direct 更好 |
| sky130 | apb4_timer | 15,715,072 | 15,595,418 (-0.76%) | 20,389,663 | chain 更好 |
| sky130 | picorv32 | 234,280,119 | 234,280,119 (0.00%) | 358,263,695 | 持平 |
| sky130 | aes | 665,002,127 | 689,140,722 (+3.63%) | 1,154,174,869 | direct 更好 |
| ihp130 | gcd | 620,662,411 | 631,022,147 (+1.67%) | 无 Innovus DEF | direct 更好 |

结论：细粒度 longnet chain 不是普遍优于直接 GP；只有 apb4_timer 改善。
四个 sky130 设计的直接 GP DEF HPWL 全部优于 Innovus 参考。

### 未能完成的验证与原因

- ics55：本机缺少 `N551P6M_ieda.lef` / `signalStorm55_lef.lef`；
- nangate45：本机无对应 foundry 物理库；
- asap7：本机无对应 foundry 物理库；
- ihp130 及以上 PDK：无 Innovus placement DEF，只有部分 timing 快照。

因此“所有 PDK 全验证”在当前机器上无法完成，需要补充 PDK 物理库和
Innovus/第三方参考结果。


## 本地 PDK 可用性补充

无需外网下载：本机 `/mnt/usb20t` 已挂载多个用户的 PDK 数据。

- nangate45：
  - `/mnt/usb20t/PCL-167/data3/taosimin/OpenROAD/test/Nangate45/`
  - 有 tech/cell LEF、lib、OpenROAD gcd DEF；
  - 已搭最小 iEDA case `/tmp/nangate45_gcd`；
  - 直接 GP 随机初始化跑通，392 迭代 overflow=0.0989，internal HPWL=5,070,217，
    def HPWL=5,850,034；输入 OpenROAD floorplan def HPWL=4,472,593（本配置下 iEDA 差于 OpenROAD 初始布局）。
- asap7：
  - `/mnt/usb20t/PCL-155/home/dengqinyi/iFlow/foundry/asap7/`
  - 有 tech/cell LEF 和 lib；
  - 尚无可直接用于 iEDA GP 的 DEF/case，需要 iFP floorplan 后再验证。
- ics55：仍未找到物理 LEF/lib，无法验证。


## 其他 PDK 实验补充

### nangate45_gcd

- 输入 OpenROAD `gcd_nangate45.def` HPWL 4,472,593；
- iEDA 直接 GP（random_init=1, seed=42, 600 iter）392 次迭代收敛，
  internal HPWL 5,070,217，def HPWL 5,850,034，当前配置下未超过输入布局；
- target_density 0.80/0.85/0.90 显式请求均被 adaptTargetDensity 钳制到
  物理利用率边界，三组结果相同。

### asap7_aes

- 用 OpenROAD 0.9 从 `aes_asap7.v` + asap7 LEF/lib 生成初始 DEF；
- iEDA 直接 GP 431 次迭代收敛：
  - overflow=0.09872
  - route_util=2.08596
  - def HPWL=58,392,975
- longnet stage chain 在第 167 次迭代 `overflow_target_miss`，chain 未收敛。
  细粒度链在该 asap7 设计上不稳定。

### ics55

- 仍缺少 `N551P6M_ieda.lef` 和 signalStorm lib，无法执行。


## Agent 调用 GP vs 原始 GP：跨 PDK 细粒度动作结果

从各 PDK 的 parent checkpoint 出发，按 agent 流程执行
propose_regions -> candidate(region/longnet, 20 iterations)：

| PDK | 设计 | parent | 区域候选 | 长网候选 | 是否优于 parent/global |
|---|---|---|---|---|---|
| sky130 | s1238 | iter400 | — | incomparable | 否 |
| sky130 | apb4_timer | iter100 | — | right_better（3 seed） | 否 |
| ihp130 | gcd | chain | chain +1.67% | — | 否 |
| nangate45 | gcd | iter300 | incomparable | incomparable | 否 |
| asap7 | aes | iter400 | incomparable | incomparable | 否 |

结论：细粒度 agent 动作在当前 iEDA GP kernel 上还不能稳定超过
原始 GP 的 global 分支；唯一正向案例是 sky130/apb4_timer 的
longnet stage chain（-0.76%）。

### Innovus 对比可用性

- sky130 四设计：有 Innovus DEF，iEDA 原始 GP HPWL 全部优于 Innovus；
- nangate45 / asap7 / ihp130：本机 Innovus 二进制存在，但当前 shell
  license 失败（LMC-01902），无法生成这些 PDK 的 Innovus 参考；
  因此不能宣称在这些 PDK 上超过 Innovus。


## 局部 GP 改进（local perturb + relinearize）

新增 C++ 能力：
- `scope_anneal_ratio`：局部 mask 只跑前 N 步，其余步骤自动清除 mask，
  做全局修复；
- `scope_density_target` 现在也作用于 longnet / instances / random 等非
  region/hotspot scope（对 active 实例覆盖网格加密度筛）。

新增策略：candidate 局部解 -> accept -> 以该布局为初始值重新 random_init=0
global GP。sky130 四设计结果：

| design | raw GP def HPWL | local-restart HPWL | 变化 |
|---|---|---|---|
| s1238 | 5,957,257 | 5,948,770 | -0.14% |
| apb4_timer | 15,715,072 | 15,646,612 | -0.44% |
| picorv32 | 234,280,119 | 234,878,612 (hotspot+anneal) | +0.26% |
| aes | 665,002,127 | 645,379,700 | -2.95% |

picorv32 尚未超过 raw GP，需继续调整 scope/anneal 或做多轮扰动。


## local_restart 跨 PDK 结果（最新）

`ieda_gp_run kind=local_restart` = 局部 candidate + accept + 以局部解为
初始值重新 random_init=0 global GP，并与同一预算 raw-GP restart 比较。

| PDK | 设计 | raw GP HPWL | local_restart HPWL | 相对变化 |
|---|---|---|---|---|
| sky130 | s1238 | 5,957,257 | 5,948,770 | -0.14% |
| sky130 | apb4_timer | 15,715,072 | 15,646,612 | -0.44% |
| sky130 | picorv32 | 234,280,119 | 234,878,612（agent 应保留 raw） | +0.26% |
| sky130 | aes | 665,002,127 | 645,379,700 | -2.95% |
| nangate45 | gcd | 5,850,034 | 5,790,441 | -1.02% |
| asap7 | aes | 58,392,975 | 57,785,023 | -1.04% |
| ihp130 | gcd | 620,662,411 | baseline_restart 617,524,718 | -0.51% |
| ihp130 | gcd | 620,662,411 | local_restart 617,906,850 | -0.44% |

Harness 真实模型调用验证：
```
ieda_gp_run kind=local_restart s1238
candidate_verdict=left_better
local_restart_hpwl=5948770 < baseline_restart_hpwl=5963695
```


最终 agent 选择策略（`local_restart` 工具返回 recommended_side）：
- s1238/apb4/aes/nangate45/asap7：local_restart；
- picorv32：raw GP；
- ihp130：baseline_restart。

在此策略下，本机可运行的 6 个 PDK/设计组合中 agent 调用 GP 的
最终 HPWL 均不劣于 raw GP，其中 5 组严格更优。


## 真实 Agent 调用 GP 的最终结果（无规则策略）

同一套提示和工具，Agent 自己观察、提议、选择、执行，没有按设计硬编码。

| design | raw GP | agent-selected | 改善 | Agent 选择 |
|---|---|---|---|---|
| s1238 | 5,957,257 | 5,949,564 | -0.13% | longnet-top-8, 77 instances |
| apb4_timer | 15,715,072 | 15,591,351 | -0.79% | longnet-top-3, 63 instances |
| aes | 665,002,127 | 644,812,888 | -3.04% | longnet-top-1, 112 instances |
| picorv32 | 234,280,119 | 234,280,119 | 0.00% | Agent 判断 raw 更优，保留 raw |

对比 Innovus（同一设计）：

| design | agent GP | Innovus | 胜方 |
|---|---|---|---|
| s1238 | 5,949,564 | 7,417,394 | agent GP |
| apb4_timer | 15,591,351 | 20,389,663 | agent GP |
| picorv32 | 234,280,119 | 358,263,695 | agent GP |
| aes | 644,812,888 | 1,154,174,869 | agent GP |

picorv32 是明确 negative result：Agent 试了两个 proposal，局部结果均比
raw GP 差，最终正确选择 raw，而不是强行接受局部解。

nangate45 / asap7 / ihp130 因没有 Innovus placement DEF，未做 Innovus 对比；
三者的 local_restart 均优于各自 raw GP（见上表）。


## 同维度指标复评（HPWL + 密度 + HPWL-based timing）

用 `gp_metrics_compare.py` 对 raw / agent / Innovus 的 DEF 跑同一 evaluator：

| design | metric | raw GP | agent | Innovus |
|---|---|---|---|---|
| s1238 | HPWL | 5,957,257 | 5,949,564 | 8,053,041 |
| s1238 | setup WNS | -0.0492 | **-0.0282** | -0.1329 |
| s1238 | peak cell density | 1.43373 | 1.43373 | 1.42950 |
| apb4_timer | HPWL | 15,715,072 | 15,591,351 | 18,566,747 |
| apb4_timer | setup WNS | **-0.5616** | -0.5647 | -0.6764 |
| apb4_timer | peak cell density | 36.8102 | 36.8102 | 36.7646 |
| picorv32 | HPWL | 234,280,119 | 234,280,119(raw) | 308,691,343 |
| picorv32 | setup WNS | -15.923 | -15.923(raw) | -21.366 |
| aes | HPWL | 665,002,127 | 644,812,888* | 914,210,691 |
| aes | setup WNS | -75.812 | -76.083* | -94.454 |

\* aes 的 agent 布局 `overflow=0.287, route_util=5.33`，未收敛，不能作为
合法改善；feasibility-aware 版本会把推荐改回 raw。

已知 evaluator 问题：
- picorv32 density evaluator 返回负值（-99.18），不可信；
- aes density csv 缺失；
- Innovus 的 eGR congestion 与 iEDA GP RUDY 不是同一 estimator，
  目前不能同维对比。

GP 内部 density/congestion（raw vs agent）：
- s1238：overflow 0.09947 -> 0.09974，route_util 1.692 -> 1.680；
- apb4：overflow 0.09924 -> 0.09965，route_util 1.373 -> 1.189；
- aes：overflow 0.10000 -> 0.28664，route_util 2.586 -> 5.329（agent 不可行）。


## 同 evaluator 四列矩阵（修复后）

`gp_evaluator_regression.py --repeat 2` 四设计全通过。
所有数字来自同一 evaluator：HPWL=def_hpwl_eval，density=run_density_eval，
RUDY=run_congestion_eval，timing=eval_timing_metrics.tcl。

| design | placement | HPWL | peak density | RUDY max | RUDY total | setup WNS |
|---|---|---|---|---|---|---|
| s1238 | raw | 5,957,257 | 0.458522 | 0.004824 | 3.778444 | -0.0492 |
| s1238 | agent | 5,949,564 | 0.458522 | 0.005120 | 3.781833 | -0.0282 |
| s1238 | innovus | 8,053,041 | 0.457168 | 0.003627 | 5.257225 | -0.1329 |
| apb4 | raw | 15,715,072 | 0.366530 | 0.003046 | 2.337015 | -0.5616 |
| apb4 | agent | 15,591,351 | 0.366530 | 0.003190 | 2.328226 | -0.5647 |
| apb4 | innovus | 18,566,747 | 0.366077 | 0.002559 | 2.918314 | -0.6764 |
| picorv32 | raw/agent | 234,280,119 | 0.340668 | 0.003854 | 3.399836 | -15.9233 |
| picorv32 | innovus | 308,691,343 | 0.340663 | 0.003650 | 4.552387 | -21.3663 |
| aes | raw | 665,002,127 | 0.491452 | 0.004218 | 3.733800 | -75.8116 |
| aes | agent* | 644,812,888 | 0.496452 | 0.005146 | 3.637586 | -76.0834 |
| aes | innovus | 914,210,691 | 0.410401 | 0.003348 | 5.379015 | -94.4539 |

\* aes agent 布局 overflow=0.287，不满足收敛条件；feasibility-aware
local_restart 会推荐 raw。

结论：
- HPWL：iEDA raw/agent 全面优于 Innovus；
- timing：iEDA 全面优于或接近 Innovus；
- density peak：Innovus 在 aes 上更均衡，其余相近；
- RUDY max：Innovus 更优；iEDA agent 在 s1238/apb4/aes 上比 raw 略差。


## 长程 Agent 验证（Harness + ieda_gp 工具，GP-only profile）

真实 deepseek-v4-pro，仅 GP 工具，parent -> local_restart -> 新 parent ->
local_restart，最多 2-3 轮：

| PDK | design | raw GP DEF HPWL | 长程结果 | 说明 |
|---|---|---|---|---|
| sky130 | s1238 | 5,957,257 | parent 保留 | 本轮 local_restart 5,957,606 未改善 |
| sky130 | apb4_timer | 15,715,072 | parent400 保留 | R1 15,591,351 改善 raw，但新 parent 内部指标退化 |
| sky130 | picorv32 | 234,280,119 | parent400 保留 | local_restart 235.2M 未改善 |
| sky130 | aes | 665,002,127 | parent400 保留 | local_restart 不可行，正确停止 |
| nangate45 | gcd | 5,850,034 | local_restart 5,805,987 | feasible，-0.75% |
| asap7 | aes | 58,392,975 | R2 local_restart 58,044,765 | feasible，-0.60% |
| ihp130 | gcd | 620,662,411 | R1 parent1 608,715,951 | feasible，-1.93% |

长程实验暴露并修复的工具 bug：
1. `ieda_gp_run` 的 start/advance/candidate/local_run 把参数数组传给
   design lookup，导致 `unknown design undefined`；
2. `gp_agent.py` 调用参数顺序错误，子命令前有全局参数；
3. `ieda_gp_session restore` 参数顺序错误；
4. cross-PDK `local_restart` 未传 case/config/foundry/lef；
5. cross-PDK raw baseline 未传，raw_gp_hpwl 为 null。

以上均已在 profile_plugin 和 designs.json 修复。


## 工具信息一致性契约测试（排除工具问题）

`gp_tool_contract_test.py` 对 7 设计 / 4 PDK 逐一调用 local_restart，
并独立用 def_hpwl_eval 复核工具返回的每一个 HPWL 字段：

- raw_gp_hpwl == def_hpwl_eval(raw DEF)
- local_restart_hpwl == def_hpwl_eval(restart placement)
- parent_def_hpwl == def_hpwl_eval(parent accepted placement)
- 三个字段 unit 都为 "def"
- overflow/route_util 有限

结果：7/7 通过，problems=[]。

因此：现在 agent 看到的 raw / parent / local HPWL 是同一 evaluator、
同一单位，可以安全比较。之前“parent internal HPWL 和 raw DEF HPWL
混比”的工具信息问题已排除。

各设计关键 DEF HPWL：

| design | raw | parent accepted | local_restart | feasible |
|---|---|---|---|---|
| s1238 | 5,957,257 | 5,884,828 | 5,948,770 | true |
| apb4 | 15,715,072 | 14,913,559 | 15,646,612 | true |
| picorv32 | 234,280,119 | 231,535,715 | 235,316,171 | true |
| aes | 665,002,127 | 644,528,490 | 647,205,078 | false |
| nangate45 | 5,850,034 | 5,576,884* | 5,809,151 | true |
| asap7 | 58,392,975 | 56,885,355* | 58,043,717 | true |
| ihp130 | 620,662,411 | — | 契约通过 | — |

* parent 为不可行 checkpoint（overflow 高），不能直接和可行解比较。


## 修复同单位信息后的长程结果（v5）

同一套规则：parent 只做 seed，winner 必须 feasible；比较只用 DEF HPWL。

| PDK | design | raw DEF HPWL | 最终 feasible HPWL | 结果 |
|---|---|---|---|---|
| sky130 | s1238 | 5,957,257 | 5,957,606（模型误选 local，应保留 raw） | 工具信息已一致，决策仍不稳定 |
| sky130 | apb4 | 15,715,072 | 15,591,351 | -0.79% |
| sky130 | picorv32 | 234,280,119 | 234,280,119（raw） | local 未改善 |
| sky130 | aes | 665,002,127 | 665,002,127（raw） | local 不可行 |
| nangate45 | gcd | 5,850,034 | 5,819,606 | -0.52% |
| asap7 | aes | 58,392,975 | 58,056,930 | -0.575% |
| ihp130 | gcd | 620,662,411 | 617,865,587 | -0.45% |

本轮额外修复：`scope_instances` 列表改为 Tcl 花括号包裹，避免
`text_out[N]_reg_p` 这类带方括号的实例名破坏命令解析。


## s1238 补充两候选实验（v6）

真实 Agent 选择 longnet-top-2（23 instances）和 longnet-top-5（51 instances），
都用同单位 DEF HPWL 比较：

- top-2 local_restart: 5,939,909, feasible=true
- top-5 local_restart: 5,954,941, feasible=true
- raw baseline: 5,957,257
- parent accepted: 5,884,828, feasible=false（只做 seed）

最终 winner：top-2 local_restart，相对 raw -0.29%。


## 工具全链路修复后的长程 v8 结果

新能力：
- start/advance/candidate/local_run 的中间 metrics 暴露；
- 动作去重缓存 + workdir 调用预算（128）；
- terminal `target_reached` 也会保存 checkpoint；
- local_restart 返回 parent/local/global 三个 child checkpoint；
- 允许 Agent 从“当前更差”的 feasible 局部解继续探索一轮。

| PDK | design | raw feasible HPWL | 最终 feasible HPWL | 变化 |
|---|---|---|---|---|
| sky130 | s1238 | 5,957,257 | 5,957,257 | raw（另一次两候选实验 -0.29%） |
| sky130 | apb4 | 15,715,072 | 15,612,372 | -0.65% |
| sky130 | picorv32 | 234,280,119 | 234,280,119 | raw |
| sky130 | aes | 665,002,127 | 665,002,127 | local 不可行，raw |
| nangate45 | gcd | 5,850,034 | 5,813,974 | -0.62% |
| asap7 | aes | 58,392,975 | 57,887,305 | -0.87% |
| ihp130 | gcd | 620,662,411 | 617,702,474 | -0.47% |

仍存在的问题：
- s1238 对 proposal 覆盖规模敏感，模型两次选择不同结果；
- ihp130 `start(target_reached)` 在新二进制下应保存 checkpoint，但 v8
  被旧动作缓存命中；已给动作缓存加版本号；
- aes / picorv32 的密度约束仍无法通过现有局部动作改善。


## 5 工具 + 假设验证长程 v10 结果

Agent 自主决定评测时机和假设验证；最终候选必须跑
`ieda_gp_verify kind=metrics` 并报告 HPWL/density/RUDY/timing。

| PDK | design | 最终 winner | HPWL | 密度/RUDY/timing 结论 |
|---|---|---|---|---|
| sky130 | s1238 | raw | 5,957,257 | 可行续跑 +2.69% HPWL，指标全差，raw 保留 |
| sky130 | apb4 | raw 保留 | 15,715,072 | candidate 可行但 accept 导出 DEF bug，未确认 |
| sky130 | picorv32 | raw | 234,280,119 | 可行边界≈raw，验证了 density relaxation |
| sky130 | aes | /tmp/gp_long_aes_v10_7/placement.def | **573,846,319 (-13.7%)** | WNS -51.45 vs -75.81；freq 18.54MHz vs 12.77MHz；RUDY max 差 20%，total 好 14% |
| nangate45 | gcd | raw | 5,850,034 | parent LG 后 7.62M，raw 全维最优 |
| asap7 | aes | baseline_restart | **57,987,714 (-0.69%)** | RUDY max/total 改善 |
| ihp130 | gcd | raw | 620,662,411 | config fingerprint mismatch 导致 local_restart 失败 |

本轮暴露的真实工具问题：
1. `ieda_gp_session accept` 在 candidate/local_restart 工作目录上会写出输入 DEF；
2. local_restart 的 target_density 语义与 start 不一致；
3. `overflow_penalty` 在 schema 暴露但 start 不转发；
4. ihp130 的 seed start config 和 local_restart config fingerprint 不一致。


## v10 winner 全维度表（同一 evaluator，已补齐）

| design | 版本 | HPWL | peak density | mean density | RUDY max | RUDY total | setup WNS(ns) | freq(MHz) |
|---|---|---|---|---|---|---|---|---|
| s1238 | raw=winner | 5,957,257 | 0.458522 | 0.458522 | 0.004824 | 3.778444 | -0.04922 | 645.49 |
| apb4 | raw=winner* | 15,715,072 | 0.366530 | 0.366530 | 0.003046 | 2.337015 | -0.56163 | 485.05 |
| picorv32 | raw=winner | 234,280,119 | 0.340668 | 0.340668 | 0.003854 | 3.399836 | -15.9233 | 54.28 |
| aes | agent winner | **573,846,319** | 0.589755 | 0.314884 | 0.005085 | 3.210842 | **-51.449** | **18.54** |
| aes | raw | 665,002,127 | 0.491452 | 0.350931 | 0.004218 | 3.733800 | -75.812 | 12.77 |
| nangate45 | raw=winner | 5,850,034 | 0.839014 | 0.839014 | 0.015860 | 4.843156 | n/a | n/a |
| asap7 | baseline_restart winner | **57,987,714** | 0.471760 | 0.036759 | **0.079383** | **6.886486** | n/a | n/a |
| asap7 | raw | 58,392,975 | 0.468640 | 0.036759 | 0.081418 | 6.929867 | n/a | n/a |
| ihp130 | raw=winner | 620,662,411 | 0.560176 | 0.560176 | 0.005540 | 8.388075 | n/a | n/a |

* apb4 候选 feasible，但 accept 导出 DEF bug 未解决，故可验证 winner 仍为 raw。


## 所有实验中已找到的最优 feasible 结果（跨会话汇总）

| design | raw HPWL | 最优 agent HPWL | 变化 | peak density | RUDY max | RUDY total | setup WNS | freq |
|---|---|---|---|---|---|---|---|---|
| s1238 | 5,957,257 | 5,939,909 | -0.29% | 0.458522 | 0.00464 | 3.778684 | -0.0306 | 653.33MHz |
| apb4 | 15,715,072 | 15,591,351 | -0.79% | 0.366530 | 0.003190 | 2.328226 | -0.5647 | 484.32MHz |
| picorv32 | 234,280,119 | 234,280,119 | 0% | 0.340668 | 0.003854 | 3.399836 | -15.9233 | 54.28MHz |
| aes | 665,002,127 | 573,846,319 | -13.7% | 0.589755 | 0.005085 | 3.210842 | -51.449 | 18.54MHz |
| nangate45 | 5,850,034 | 5,813,974 | -0.62% | 0.839014 | 0.016195 | 4.834003 | n/a | n/a |
| asap7 | 58,392,975 | 57,887,305 | -0.87% | 0.462444 | 0.080320 | 6.906416 | n/a | n/a |
| ihp130 | 620,662,411 | 617,771,700 | -0.47% | 0.560176 | 0.005412 | 8.348585 | n/a | n/a |


## raw / 最优 agent / Innovus 同维度精确对比表（sky130）

| design | 指标 | raw | 最优 agent | agent vs raw | Innovus | agent vs Innovus |
|---|---|---|---|---|---|---|
| s1238 | HPWL | 5,957,257 | 5,939,909 | -0.291% | 8,053,041 | -26.24% |
| s1238 | peak density | 0.458522 | 0.458522 | 0 | 0.457168 | +0.30% |
| s1238 | RUDY max | 0.004824 | 0.004640 | -3.81% | 0.003627 | +27.93% |
| s1238 | RUDY total | 3.778444 | 3.778684 | +0.006% | 5.257225 | -28.12% |
| s1238 | setup WNS | -0.04922 | -0.03062 | +0.0186ns | -0.13295 | +0.1023ns |
| s1238 | freq | 645.49 | 653.33 | +1.22% | 612.39 | +6.69% |
| apb4 | HPWL | 15,715,072 | 15,591,351 | -0.787% | 18,566,747 | -16.02% |
| apb4 | peak density | 0.366530 | 0.366530 | 0 | 0.366077 | +0.124% |
| apb4 | RUDY max | 0.003046 | 0.003190 | +4.73% | 0.002559 | +24.66% |
| apb4 | RUDY total | 2.337015 | 2.328226 | -0.376% | 2.918314 | -20.22% |
| apb4 | setup WNS | -0.56163 | -0.56474 | -0.0031ns | -0.67645 | +0.1117ns |
| apb4 | freq | 485.05 | 484.32 | -0.151% | 459.46 | +5.41% |
| picorv32 | HPWL | 234,280,119 | 234,280,119 | 0 | 308,691,343 | -24.10% |
| picorv32 | peak density | 0.340668 | 0.340668 | 0 | 0.340663 | +0.0015% |
| picorv32 | RUDY max | 0.003854 | 0.003854 | 0 | 0.003650 | +5.59% |
| picorv32 | RUDY total | 3.399836 | 3.399836 | 0 | 4.552387 | -25.32% |
| picorv32 | setup WNS | -15.9233 | -15.9233 | 0 | -21.3663 | +5.443ns |
| picorv32 | freq | 54.28 | 54.28 | 0 | 41.90 | +29.55% |
| aes | HPWL | 665,002,127 | 573,846,319 | -13.71% | 914,210,691 | -37.23% |
| aes | peak density | 0.491452 | 0.589755 | +20.00% | 0.410401 | +43.70% |
| aes | RUDY max | 0.004218 | 0.005085 | +20.56% | 0.003348 | +51.88% |
| aes | RUDY total | 3.733800 | 3.210842 | -14.01% | 5.379015 | -40.31% |
| aes | setup WNS | -75.812 | -51.449 | +24.36ns | -94.454 | +43.00ns |
| aes | freq | 12.77 | 18.54 | +45.16% | 10.31 | +79.74% |

## cross-PDK 精确表（无 Innovus DEF，timing n/a）

| design | 指标 | raw | 最优 agent | delta |
|---|---|---|---|---|
| nangate45 | HPWL | 5,850,034 | 5,813,974 | -0.616% |
| nangate45 | peak density | 0.839014 | 0.839014 | 0 |
| nangate45 | RUDY max | 0.015860 | 0.016195 | +2.11% |
| nangate45 | RUDY total | 4.843156 | 4.834003 | -0.189% |
| asap7 | HPWL | 58,392,975 | 57,887,305 | -0.866% |
| asap7 | peak density | 0.468640 | 0.462444 | -1.322% |
| asap7 | RUDY max | 0.081418 | 0.080320 | -1.349% |
| asap7 | RUDY total | 6.929867 | 6.906416 | -0.338% |
| ihp130 | HPWL | 620,662,411 | 617,771,700 | -0.466% |
| ihp130 | peak density | 0.560176 | 0.560176 | 0 |
| ihp130 | RUDY max | 0.005540 | 0.005412 | -2.31% |
| ihp130 | RUDY total | 8.388075 | 8.348585 | -0.471% |


## Round 2：iSTA ps 单位 bug 修复

- 现象：asap7 timing WNS -2146 ns，路径每个 cell delay 出现 -2147.484 ns。
- 根因：asap7 liberty 时间单位是 1ps；slew/load 越界后 LUT 线性外推
  产生巨大负 delay，随后污染所有传播值。
- 修复：LibTable::findValue 对两轴都 clamp 到表边界，不再外推。
- 验证：
  - asap7 raw WNS -2146.16 ns -> -5.3735 ns；
  - agent WNS -5.2884 ns，freq 163.98 MHz；
  - Innovus WNS -7.3920 ns，freq 121.92 MHz；
  - s1238 WNS 基本不变（-0.0503 vs -0.0492）；
  - nangate WNS 不变（-1.186381）。

## Round 3：RUDY utilization + congestion_hotspots + accept 契约

- C++ 层：
  - run_congestion_eval 现在输出 rudy_utilization_max/avg/h/v、
    rudy_overflow_bin_count、rudy_overflow_util_sum；
  - 同时写 rudy_demand.csv 和 rudy_util.csv；
  - 利用率 supply 与 GP route_util 同源（LEF track count）。
- Python / Harness 层：
  - 新增 gp_congestion_observe.py；
  - ieda_gp_observe kind=congestion_hotspots 返回
    top overflow bins、merged executable regions、region 字符串；
  - 可用 scope_region 字符串直接喂给 ieda_gp_run local_run。
- Headless 验证（deepseek-v4-pro/max/极简）：
  - congestion_hotspots 调用 ok:true；
  - s1238 raw：util_max 1.919、overflow bins 157、首 region
    22348 24832 24832 27315。
- 真实 agent 循环：
  - restore parent_400 -> accept -> congestion_hotspots ->
    local_run(region,20) -> verify；
  - local_run 内部 HPWL -20102，candidate DEF HPWL 5861083；
  - 发现 session accept 带 checkpoint 会意外回滚 parent，
    已改为结构化拒绝 checkpoint。

## Round 4：timing_paths + propose gp_config

- 新增 gp_timing_paths.py：
  - 运行只读 iSTA，读 .rpt.json；
  - 返回 worst paths 的 endpoint/slack/freq/start/end point；
  - 每条 path 附 scope_instances 字符串，可直接用于
    ieda_gp_run local_run scope=instances。
- ieda_gp_observe 新 kind：timing_paths。
  Headless 验证 ok:true，s1238 首个 path：
  endpoint DFF_12/Q_reg:D，slack 0.225，
  11 个 instance 的 scope_instances 字符串。
- ieda_gp_propose 新 kind：gp_config。
  基于 checkpoint config_state + trajectory 给出：
  - density_relief / density_penalty_up
  - congestion_effort_on
  - budget candidates
  每个 candidate 都是 executable start action
  （input_def=workdir/placement.def, random_init=0）。
  Headless 验证 ok:true。
- 快速配置实验（直接调用，非 agent）：
  - congestion_effort=1 from parent：100 iter 后 overflow 0.678，route_util 6.84；
  - target_density=0.55 from parent：100 iter 后 overflow 0.691；
  都未达到可行，说明 config 需要继续迭代观察，而不是一次切换解决。

## Round 5：timing_paths 统一 evaluator + apply_region_density 验证

- 修复：timing_paths 之前用 run_sta（0 RC），报告的 slack 是正的；
  而 verify metrics 用 run_timing_eval HPWL RC，slack 是负的。
  两者不是同一 evaluator，agent 会拿错误路径做 timing local。
- 修复后：
  - run_timing_eval 新增 -path_json / -max_path；
  - gp_timing_paths.py 读同一个 HPWL RC evaluator 的路径；
  - GP_TOOL_VERSION 升到 3 使旧缓存失效。
- Headless 验证：
  - timing_paths evaluator=run_timing_eval HPWL；
  - timing_summary.setup_wns=-0.050255；
  - first path slack=-0.050255，与 verify metrics 完全一致。
- timing path local_run（11 instance，20 iter）：
  - DEF HPWL 5874369 vs raw 5957257；
  - overflow bins 628 vs 654；
  - setup WNS 基本持平。
- apply_region_density headless 循环：
  - restore parent400 -> apply_region_density(scope_density_target=0.5, 20 iter)
    -> metrics verify；
  - ok=true，HPWL 5868709，RUDY util max 2.998856，overflow bins 630。

## Round 6：terminal checkpoint 连续性 + target_overflow + 跨 PDK timing paths

- 修复 terminal checkpoint off-by-one：
  - 现象：target_reached 后 checkpoint 的 solver.current_iter=391，
    NesterovPlace.current_iter=390；restore 后再 advance 被
    "iteration numbers must be strictly increasing" 拒绝。
  - 修复：terminal break 前记录 _finished_iter=iter_num；
    checkpoint 两端现在都是 391。
  - 顺带修 accept：terminal 已提交时 accept 返回 no-op ok，
    不再让 local_run 失败。
- 新增 target_overflow 参数：
  - ieda_gp_run start / placer_run_gp / GPContract / propose gp_config
    现在都能传 target_overflow；
  - headless start target_overflow=0.02 congestion_effort=1 验证
    ok=true, stop_reason=overflow_target_miss, hpwl=6025656,
    route_util=1.65001。
- 跨 PDK 同 evaluator timing paths 全部通过：
  - nangate WNS -1.186381，path slack -1.186381；
  - asap7 WNS -5.373541，path slack -5.373541；
  - ihp130 WNS 0.459085，path slack 0.459085；
  - headless asap7 timing_paths ok=true，与 verify metrics 一致。
- s1238 配置搜索初步数据：
  - congestion_effort=1, target_overflow=0.1（390 iters）：
    HPWL 5974307, rutil 2.6806, bins 596, WNS -0.043843；
  - congestion_effort=1, target_overflow=0.05（466 iters）：
    HPWL 6148253, rutil 2.3574, bins 645, WNS -0.033820；
  - congestion_effort=1, target_overflow=0.02（488 iters）：
    HPWL 5857391, rutil 2.9993, bins 627, WNS -0.049229；
  - Innovus 同一 evaluator：HPWL 8053041, rutil 2.0349, bins 622。
  当前 iEDA 在 HPWL / timing / bins 可超过 Innovus，
  rutil max 仍未超过，下一轮继续用 Pareto 搜索压低 rutil max。

## Round 7：s1238 config Pareto 扫描 + congestion model 选项

- 新增 verify metrics --congestion-model rudy|lutrudy。
- 从 parent_400 已接受 DEF 出发，congestion_effort=1，
  random_init=0，扫描 6 组 target_density x target_overflow：
  td/to   | stop | iter | hpwl     | ov      | route_util(internal)
  0.5/0.1 | target | 409 | 6415832  | 0.0980  | 1.55609
  0.55/0.1| target | 404 | 6089153  | 0.0999  | 1.64338
  0.6/0.1 | target | 391 | 5836600  | 0.0996  | 1.60638
  0.5/0.05| miss   | 447 | 6515113  | 0.0722  | 1.56543
  0.55/0.05| target| 478 | 6252205  | 0.0545  | 1.66118
  0.6/0.05| target | 471 | 6020935  | 0.0487  | 1.59281
- 同 evaluator RUDY(64 bins)：
  td50to10: HPWL 6583394, rutil 2.5042, bins 553, rsum 159.81,
            WNS -0.0767；
  td60to10: HPWL 5983382, rutil 2.6943, bins 561, rsum 173.26,
            WNS -0.0374；
  Innovus : HPWL 8053041, rutil 2.0349, bins 622, rsum 133.02。
- 继续 hotspot 局部：td50to10 + region local20 后
  rutil 2.4784, bins 554, rsum 158.16；
  但 scope_density_target=0.4 第二轮变差。
- 当前结论：iEDA 已在 HPWL / timing / bins 超过 Innovus；
  rutil max 和 overflow sum 还需更好的 congestion 目标或
  更多轮 hotspot 迭代，点工具已验证可支撑该搜索。

## Round 8：headless Pareto 循环 + congestion nets

- Headless（deepseek-v4-pro/max/极简）完整跑通两候选 Pareto 循环：
  - A: td0.6/to0.05/cong1, 466 iters target_reached；
    HPWL 6148253, rutil 2.357, bins 645, rsum 184.04, WNS -0.0338；
  - B: td0.5/to0.1/cong1, 420 iters target_reached；
    HPWL 6595040, rutil 2.344, bins 577, rsum 156.91, WNS -0.0769；
  - 模型裁决：A 是 congestion-HPWL 更好 Pareto 点，
    B 是 congestion-sum 极限点。
- congestion_hotspots 新增 congestion_nets：
  - 找出 HPWL bbox 穿过热点区域的长网；
  - 返回 net/hpwl/overlap_ratio/instances/scope_instances；
  - headless 验证：A_region 热点第一网 n95，
    5 instances：U391,U297,U258,U237,U111。
- 用 congestion nets 做 local GP：
  - B + n95 local20：HPWL 6590363, rutil 2.402, bins 579,
    rsum 155.82, WNS -0.0767；
  - A_region + n37/n38 尝试无明显 win。
- td0.45/to0.1/cong1 补充点：
  HPWL 6875632, rutil 2.427, bins 592, rsum 153.84, WNS -0.0882。
- 现状：rutil max 与 rsum 的最优 iEDA 点仍未同时超过 Innovus，
  但 headless 已能自主完成候选生成、执行、同一 evaluator 验证
  和 Pareto 取舍。

## Round 9：LUT-RUDY utilization 对齐 solver 目标

- 问题：GP congestion_effort 内部用 LUT-RUDY；
  verify 默认用 plain RUDY；两者不是同一模型。
- 修复：
  - calLUTRUDY 现在同样计算 utilization / overflow bins / overflow sum；
  - ieda_gp_verify metrics 支持 congestion_model=rudy|lutrudy；
  - congestion_hotspots 支持 congestion_model=rudy|lutrudy。
- Headless 验证：
  - verify lutrudy：raw rutil 2.957816，B rutil 2.546712，
    B overflow sum 254.863052（接近 Innovus 254.180549）；
  - congestion_hotspots lutrudy：model=lutrudy，rutil 2.546712，
    第一 congestion net n95，scope_instances=U391,U297,U258,U237,U111。
- 更多 feasible 配置点（s1238 plain RUDY）：
  - td0.5/to0.08/cong1：
    HPWL 6666913, rutil 2.333612, bins 556, rsum 164.197581；
  - td0.5/to0.1/cong1（B）：
    HPWL 6595040, rutil 2.344350, bins 577, rsum 156.91；
  - td0.6/to0.05/cong1（A）：
    HPWL 6148253, rutil 2.357432, bins 645, rsum 184.04；
  - Innovus：HPWL 8053041, rutil 2.034871, bins 622, rsum 133.02。
- congestion net local 迭代：
  - B+n95：rsum 155.816；
  - B+n95+n37：rsum 155.899；
  - td050to008+n257：rutil 变差。
  说明单 net local 对 peak 的作用有限，下一步需要
  solver 侧 peak-congestion 目标或更多 nets 联合局部。

## Round 10：congestion-net union headless 循环

- Headless 全链路：
  congestion_hotspots(rudy,64 bins) -> 取前 3 个 congestion nets
  -> union 14 instances -> local_run(60 iters, anneal 0.5)
  -> verify metrics(rudy)。
- 结果：
  - peak rutil 2.333612 -> 2.293105（-1.7%）；
  - overflow bins 556 -> 561（+0.9%）；
  - overflow sum 164.20 -> 168.39（+2.6%）；
  - 模型判定：不值得保留，热点只是转移，不是消散。
- 当前 s1238 plain RUDY 最佳可行点：
  td0.5/to0.08/cong1 + top3 congestion-net local60：
  HPWL 6704993, rutil 2.293105, bins 561, rsum 168.39。
- 结论：工具链已经能自动做 hotspot -> net scope -> verify -> verdict；
  要达到 Innovus 的 rutil 2.035 / rsum 133，还需要
  solver 侧直接优化 peak bin，或显著扩大联合 scope。

## Round 11：solver 侧 congestion_effort level 2

- 新增 congestion_effort=2：
  - 对穿过 LUT-RUDY util >1 bin 的长网，
    额外放大其 wirelength gradient（threshold 1.0，factor 0.25）；
  - 配置进入 config_state / checkpoint fingerprint，
    可正确 restore。
- Headless 验证（deepseek-v4-pro/max/极简）：
  - start td0.5/to0.1/cong2, 600 iters：
    ok=true, target_reached, end_iteration=420,
    hpwl=6405350, overflow=0.0999558, route_util=1.5006。
- 同 evaluator 对比：
  - plain RUDY：
    HPWL 6538020, rutil 2.650141, bins 650, rsum 176.40；
  - LUT-RUDY：
    HPWL 6538020, rutil 2.762708, bins 876, rsum 281.56。
- 初步结论：level2 明显降低 solver 内部 LUT-RUDY peak
  （1.544 -> 1.501），但 plain-RUDY evaluator 峰值反而上升，
  证明 solver 目标与 plain RUDY evaluator 需要进一步统一。
  目前保留 level2 作为可复现的 solver knob，
  level1 仍是 plain RUDY Pareto 上更安全的点。

## Round 12：congestion_effort=3（plain RUDY solver 目标）

- 新增 congestion_effort=3：
  - solver 的 RUDY demand 用 plain RUDY weight（无 LUT 表），
    与 ieda_gp_verify metrics(congestion_model=rudy) 一致；
  - 保留 Gaussian blur 以维持数值稳定；
  - peak-bin gradient penalty factor=0.1。
- Headless 验证：
  - start td0.5/to0.1/cong3, 600 iters：
    ok=true, target_reached, end_iteration=420,
    hpwl=6417520, overflow=0.0998012, route_util=1.61169。
- 同 evaluator（plain RUDY）：
  cong3 td0.5/to0.1：
    HPWL 6569824, rutil 2.388049, bins 587, rsum 160.233107；
  对比 level1 B：
    HPWL 6595040, rutil 2.344350, bins 577, rsum 156.91。
- 结论：
  - level3 显著降低 HPWL 且 bins/rsum 居中；
  - plain peak 仍以 level1 B 为最低；
  - 三种 effort 都已成为可复现、可 restore 的点工具旋钮。

## Round 14：跨 PDK preset 验证发现

- nangate45：
  - target_density 0.7/0.8/0.9 全部被 adaptTargetDensity 夹到
    1.001（设计利用率接近 1）；
  - cong1 点：DEF HPWL 7181173，rutil 4.468，bins 379；
  - cong0/to0.05 点：DEF HPWL 7099534，rutil 4.707，bins 350；
  - parent300 本身：DEF HPWL 4472593，rutil 2.769，bins 457；
  - Innovus：HPWL 3264413，rutil 1.991，bins 328。
  - nangate 需要单独的 HPWL-first 配置，s1238 preset 不适用。
- ihp130：
  - td0.5/to0.1/cong1 可稳定运行（568 iters target_reached）；
  - DEF HPWL 624455491，rutil 2.435，bins 1681，
    均比 raw 好；仍差 Innovus。
- asap7：
  - 发现 start-from-parent bug：
    td0.5/td0.6 + cong0/cong1 全部在 iter=4
    overflow_target_miss，HPWL ~3.8e9；
  - 原始 raw start（从 unplaced DEF）正常；
  - 需要排查 parent DEF 重用路径，下一轮修复。

## Round 15：asap7 start/advance 修复

- 修复 1：旧 checkpoint 没有 congestion_effort_level key，
  fingerprint 被误判 mismatch；现在缺 key 且 current=1 时归一化兼容。
- 修复 2：resume/advance 的 terminal def_save 会导出 input DEF；
  cmd_advance 现在在 advance 结束后用 restore+accept 重新导出
  最新 checkpoint 的 placement.def。
- 修复 3：designs.json 的 asap7 foundry_dir 之前误写 sky130，
  已改为真实 asap7 foundry。
- 验证：
  - 旧 asap7 parent checkpoint 现在可 accept；
  - advance parent400 -> 432 iters target_reached；
  - headless advance + verify：
    candidate HPWL 57668240（raw 58392975），
    rutil 1.697845，bins 16；
  - placement.def 不再等于 raw input（md5 不同）。
- 重要使用方式：
  - 继续一个 mid-state checkpoint 用 ieda_gp_run advance，
    不要用 start(input_def=parent DEF) relinearize；
  - asap7 上 start-from-parent 仍可能 early miss，
    而 advance 稳定收敛。

## Round 16：跨 PDK advance 路径验证

- nangate45 parent300 -> advance 600：
  target_reached，301-393 iters；
  导出 DEF HPWL 5837679（raw 5850034）；
  rutil 5.155，bins 284。
  对比 parent300 DEF HPWL 4472593，rutil 2.769，bins 457。
  parent（不可行 mid-state）在 DEF 指标上仍优于 feasible advance 点。
- ihp130 parent400 -> advance 600：
  target_reached，401-473 iters；
  DEF HPWL 619921396，rutil 2.651，bins 1728。
  旧 parent DEF 原为 unplaced，重新 accept 后 HPWL 580534124，
  rutil 3.168，bins 1551。
- 结论：
  - advance DEF 导出修复在 nangate/ihp130 同样有效；
  - feasible 点不一定 Pareto 优于不可行 parent，
    工具必须同时返回 feasibility 和同一 evaluator DEF 指标，
    agent 才能正确取舍（当前 status 已返回两者）。

## Round 17：不可行 parent 的局部修复前沿 + 回归

- nangate45 parent300 局部 region 全部 diverge（target_density
  被夹到 1.001，physical utilization 接近 1），
  说明该设计没有密度余量，需要 HPWL-first 且不能靠 local GP。
- ihp130 parent400 局部动作：
  - region plain：HPWL 580780561，rutil 3.0548，bins 1552；
  - region td0.8：HPWL 580892926，rutil 3.0232，bins 1553；
  - hotspot 0.2：HPWL 593333042，rutil 3.1018，bins 1623。
  都只是 Pareto 移动，未形成 dominant 点。
- 回归：
  - ipl_gp_session_test --scenario validate：rc=0；
  - gp_tool_contract_test 超时被打断，待下一轮重跑。

## Round 18：contract 回归部分通过

- gp_tool_contract_test 已修 nangate/asap7 foundry_dir。
- 单 case 运行结果：
  - s1238：ok=true，problems=[]；
  - nangate45_gcd：ok=true，problems=[]；
  - ihp130_gcd：ok=true，problems=[]；
  - asap7_aes：跑到 local_restart 后进程超时未打印 summary，
    待下一轮用更长 timeout 重跑。
- 说明 local_restart 的信息契约（HPWL 同单位）在
  sky130/nangate45/ihp130 成立。

## Round 20：contract 全部通过 + headless registry foundry

- gp_tool_contract_test 单 case 全绿：
  - s1238：ok=true；
  - nangate45_gcd：ok=true；
  - ihp130_gcd：ok=true；
  - asap7_aes：ok=true（r19 后台 3600s timeout 完成）。
- headless 验证 asap7 foundry registry：
  - ieda_gp_observe congestion_hotspots design=asap7_aes
    不显式传 foundry_dir；
  - ok=true，model=rudy，rutil=1.696979；
  - 确认从 registry 解析到真实 asap7 foundry。

## Round 22：multi-design headless 总表 + anneal 搜索

- headless 一次 4 design verify（extra_defs 新能力）：
  s1238 是唯一在部分指标上超过 Innovus 的设计
  （HPWL -16.7%，bins -9.8%），
  nangate/asap7/ihp130 当前候选四项均落后。
- s1238 局部迭代继续：
  - td050to008 + top3 congestion nets, 60 iter, halo2, anneal0.8：
    HPWL 6678221, rutil 2.319219, bins 558, rsum 165.048；
  - 再跑同 scope 40 iter（terminal 1 iter）：
    HPWL 6686393, rutil 2.314763, bins 557, rsum 165.932；
  - 相比 round10 点：HPWL/bins/rsum 全面变好，
    rutil 从 2.293 略升到 2.315。

## Round 23：asap7 / ihp130 timing-local 尝试

- asap7 advance 候选 timing path local60：
  HPWL 57898698（raw 58392975），rutil 1.697852，
  WNS -5.38601；仅小幅改善 HPWL。
- asap7 从 raw placed 重新 start 到 target：
  HPWL 57987714，rutil 1.844663，bins 14。
- ihp130 region td0.8 候选 timing path local60：
  HPWL 618169446，rutil 2.839，bins 1739，rsum 832.31，
  明显更差。
- ihp130 contract local_restart 点：
  HPWL 617866974，feasible overflow0.0989，
  parent HPWL 580534124（不可行 overflow0.238）。
- 结论：asap7 / ihp130 目前没有单一动作能同时
  逼近 Innovus 的 HPWL 和 congestion；
  需要更根本的 GP 目标调整或不同初始解。

## Round 24：Innovus DEF 作为 iEDA GP 初始解（重大发现）

- 用 Innovus placed DEF 做 input_def，random_init=0，
  congestion_effort=3：
  - nangate45：HPWL 3190599，**超过 Innovus 3264413（-2.3%）**；
    rutil 2.929（Innovus 1.991），bins 336，rsum 150.56。
  - asap7：HPWL 46669169（Innovus 45224840，差距3.2%）；
    WNS -4.709 / freq 181.2，**timing 明显超过 Innovus**；
    rutil 2.105，bins 8。
  - ihp130：HPWL 444738206，**超过 Innovus 502815015（-11.6%）**；
    rutil 1.549 **超过 2.171**；bins 780 **超过 1099**；
    rsum 132.70 **超过 245.28**；
    WNS -1.154（Innovus -1.024），freq 162.5（Innovus 166.0）。
- ihp130 后续 timing path local：
  - local1：HPWL 445444709，rutil 1.548133，bins 776，
    rsum 131.264，WNS -1.1566；
  - union+anneal0.8：HPWL 444607523，rutil 1.55045，
    bins 782，rsum 131.733，WNS -1.1522。
- headless 验证 ihp130 Innovus-init 全链路：
  candidate 在 HPWL / rutil / bins / rsum 四项全部超过 Innovus，
  仅 setup WNS / freq 略差。
- timing_effort 动态 override 试验：
  TimingAnnotation 未初始化时 abort，已回滚该旋钮，
  保留 config-file 级 timing_effort 不做运行时开关。

## Round 25：ihp130 timing 追赶尝试

- 基础 candidate（Innovus-init + cong3）vs Innovus：
  HPWL 444738206 vs 502815015 ✅
  rutil 1.549 vs 2.171 ✅
  bins 780 vs 1099 ✅
  rsum 132.70 vs 245.28 ✅
  WNS -1.1536 vs -1.0237 ❌
  freq 162.51 vs 166.01 ❌
- timing path local 多轮：
  - local1 WNS -1.1566；
  - union+anneal WNS -1.1522；
  - local3 WNS -1.1528；
  未能超过 Innovus WNS。
- config-file timing_effort 尝试：
  - 修 gp_agent.py：flow 现在 source db_init_lib/db_init_sdc；
  - timing_effort=1 可初始化，不再 abort；
  - 但 opt_overflow_list 空时 timing net-weight 不触发；
  - 显式 opt_overflow_list=[0.05,0.08,0.1] 后结果仍相同，
    timing 目标在当前库/SDC 下未改变路径。

## 新目标 Round 1：以“用户开放目标形式”跑会话，反推插件问题

- 用用户的形式跑 headless 开放目标会话：
  “对 ihp130_gcd / nangate45_gcd 做 GP 优化，
   只允许 ieda_gp_*，不限轮数，自己判断停止。”
- 第一轮暴露并已修复的插件 bug：
  1. archive 函数使用 existsSync/copyFileSync 未 import，
     导致所有 ieda_gp_run 报 `Error: existsSync is not defined`。
     已补 import。
  2. `ieda_gp_session accept` 不带 design 时硬编码 s1238，
     nangate accept 用了 s1238 case/input/config。
     已改为从 workdir trace 推断 design。
  3. `ieda_gp_verify metrics` 不带 design 时把 undefined 传给
     Python，metrics 产出空 JSON。
     已改为 trace 推断 design。
  4. `ieda_gp_observe` 非 designs 不带 workdir 时直接
     Node paths[0] undefined。
     已改为结构化错误。
  5. metrics 不带 raw/candidate/extra 时无意义；
     已前置校验。
  6. propose freeze/region_density 不带 region 时 Python traceback；
     已前置校验。
- 已加的点工具能力：
  1. ieda_gp_run 在 start/full/local_run 等动作前自动把
     上一个 placement.def / checkpoint / metrics 归档到
     <workdir>/archive/<timestamp>，防止 agent 覆盖历史。
  2. status 返回 effective_config：
     target_density / target_overflow / congestion level /
     timing / bin size，agent 可看到被 solver 钳制后的真实值。
  3. congestion_hotspots / timing_paths / metrics / accept
     缺失 design 时从 gp_agent_trace.jsonl 推断。
  4. headless profile patch 增加 tool-goal disabled，
     避免 agent 调用 create_goal 破坏“只 GP 工具”。
- 第二轮开放目标会话进行中：
  ihp130_gcd：31 次工具调用，主要
  start/full/verify/metrics/hotspots 循环；
  nangate45_gcd：42 次调用，已出现
  verify metrics / congestion_hotspots / full / advance 循环。
  等会话结束后继续分析。

## 新目标 Round 2：第二轮会话继续暴露的插件问题

- `ieda_gp_verify kind=lg` 不带 design 时同样硬编码 s1238，
  nangate 会话的 LG 用了 s1238 数据。
  已改为 trace 推断 design。
- agent 传入 target_density=1.0，C++ 端拒绝并返回
  "target_density must be in (0,1)"，但插件没有前置校验，
  agent 在错误发生后才学习。
  已加 start/full 前置校验：
  target_density / target_overflow 必须 (0,1) 或 -1。
- 会话状态：
  - ihp130 开放目标会话仍在运行，31+ 次调用；
  - nangate45 开放目标会话仍在运行，44+ 次调用；
  - asap7 开放目标会话刚启动。
- 模型编排问题（不属于插件问题，仅记录）：
  - 空 workdir 先调 status/checkpoints；
  - 不传 design / raw_def / candidate_def；
  - target_density 传 1；
  - 反复 accept 已经 terminal 的会话；
  这些由模型自身修复，插件需要给结构化错误而不是 traceback。

## 新目标 Round 3：最新插件重启三轮开放目标会话

- 又发现并修复：
  1. full 分支中 `design` 变量未定义，
     导致 asap7/nangate 会话 ieda_gp_run full
     报 `Error: design is not defined`。
     已定义 design 并前置校验。
  2. archive 保存 `pl/gp_session_checkpoint.json` 时
     目标 pl/ 目录不存在，导致 checkpoint 归档失败。
     已自动创建 dirname。
  3. gp_toolbox.py 未捕获异常时输出 Python traceback；
     已统一为 `{"ok":false,"reason":...}` 结构化错误。
- 直接工具 smoke（不经模型）：
  ieda_gp_run full design=s1238 iterations=20 timing=0
  返回 ok=true，raw/candidate/innovus 三路 metrics 正常。
  第二次 start 触发 archive，确认 placement.def、
  pl/gp_session_checkpoint.json 等已归档。
- 三个开放目标会话（最新插件）运行中：
  - ihp130：28 次调用，失败4，主要是
    metrics 缺 design（无 trace）与 status 空 workdir；
  - nangate：27 次调用，失败3；
  - asap7：28 次调用，失败11，其中多为模型错误
    （checkpoint=cp1、无 region 调 region_density、
    空 workdir 调 propose/advance），插件均返回了结构化错误。
- 结论：点工具层面 crash/undefined/traceback 问题已清零，
  剩余失败基本是 agent 编排（模型能力）问题。

## 新目标 Round 4：点工具错误出口最终收敛

- runCli 在 Python 命令 rc!=0 时不再返回
  `Command failed ...` 大段文本，
  而是优先解析 stdout 里的结构化 JSON 返回。
- 直接 smoke：
  ieda_gp_propose regions 对空 workdir 现在返回：
  {ok:false, error:"no checkpoint ... run gp_start first"}
  不再出现 traceback / Command failed。
- 三轮最新会话进行中，点工具层面剩余失败：
  - 空 workdir 调用（模型编排）；
  - checkpoint=cp1 无效标签（模型编排）；
  - region_density 不传 region（模型编排）；
  - region 与任何 GP bin 不 overlap（模型给了错误坐标）。
  这些错误现在全部是简短结构化原因。
- 会话中模型已产生有意义的中间结果：
  nangate45 candidate HPWL 2,879,411（raw 4,472,593，Innovus 3,264,413）；
  asap7 candidate HPWL 51,956,062（raw 58,392,975）；
  ihp130 candidate HPWL 413,884,099（raw 620,662,411）。

## 新目标 Round 5：从会话中再发现两个点工具问题

- 问题 1：candidate 局部分支提前 target_reached 时，
  C++ 不打印 candidate_verdict/local/global，
  Python 得到 candidate={}，
  导致 local_restart 在 stage=candidate 失败。
  已修复：terminal candidate 回退到
  pl/gp_session_checkpoint.json + parent checkpoint，
  verdict=left_better，并标记 terminal_local。
- 问题 2：apply_region_density / apply_freeze 等
  依赖已有 workdir 的动作必须显式 design，
  模型漏传时被 schema 拒绝。
  已修复：ieda_gp_run 任何 kind 在缺 design 时
  从 gp_agent_trace.jsonl 推断；
  推不出来才返回结构化错误。
- 三轮会话仍在跑，最新失败已经全部是模型编排问题。

## 新目标 Round 6：直接回归验证 + region 参数别名

- 又发现 apply_region_density 只认 `region`，
  schema 同时暴露 `region` 和 `scope_region`，
  模型/调用者传 scope_region 时 Tcl 收到 undefined。
  已修复：参数统一归一化，
  region 或 scope_region 都可。
- 直接工具回归：
  1. ieda_gp_run candidate 在 ihp130 terminal 场景：
     candidate 不再是 {}，
     返回 candidate_verdict=left_better、
     terminal_local=true、local/global metrics。
  2. ieda_gp_run apply_region_density 不带 design：
     design 从 trace 推断成功；
     scope_region 传 "0 0 41180 41350" 不再出现 undefined，
     成功执行 1 步 local region density。
- 三个开放目标会话仍运行：
  ihp130 83 calls，nangate 73 calls，asap7 63 calls。
  自最新插件版本后没有新的插件级错误。

## 新目标 Round 7：scope_effect 可见性

- nangate 会话的模型说 "local scope machinery isn't engaging"，
  但工具结果里没有 scope_effect 数据，模型无法判断
  active / halo / context 实际写入了多少。
- 已修复：gp_agent.py 解析 C++ stdout 的
  `scope_effect active=... halo=... context=... context_moved=... max_displacement=...`，
  local_run / candidate 的 record 现在返回该结构。
- 这是点工具信息完备性问题，不是模型能力问题。
- 三个开放目标会话仍在运行。

## 新目标 Round 8：会话统计与最新版清洁验证

- 三个会话当前统计：
  ihp130：92 calls / 91 results，ok 82，fail 9；
  asap7：68 calls / 67 results，ok 51，fail 16；
  nangate：81 calls / 80 results，ok 67，fail 13。
- 所有 fail 都可归因于：
  模型在空 workdir 上先调 observe/propose、
  无效 checkpoint 标签、region 不 overlap、缺参数。
  这些已由插件返回结构化原因。
- 为确保“最新 JS 代码”也被开放目标会话验证，
  又启动一个全新的 s1238 会话
  （goal_s1238，3600s timeout，最新插件代码）。

## 新目标 Round 9：candidate 终止原因扩展

- asap7 会话暴露：
  candidate 局部分支 stop_reason=overflow_target_miss 时，
  同样没有 candidate_verdict/local/global 输出，
  candidate={}，local_restart stage=candidate 失败。
- 已修复：
  fallback 覆盖 target_reached 和 overflow_target_miss；
  overflow_target_miss 时 verdict=right_better（保留 parent/global）。
- 最新 s1238 会话仍在跑，当前 24 calls，
  失败均为模型编排（空 workdir、region 不 overlap、缺 region）。
