# iEDA.ai AES12 65% 模块质量分析与下一阶段优化方案

生成日期：2026-08-04
依据报告：

- `benchmarks/reports/aes12_65pct_detailed_comparison.md`
- `benchmarks/reports/aes12_65pct_qor_wp_rt01b_comparison.md`

## 1. 执行摘要

当前 iEDA.ai 已具备多 PDK 物理实现流程贯通能力：AES 12 项在 sky130、nangate45、asap7、ics55 上均可生成 post-route DEF/GDS，并能输出阶段图、CTS 图、密度/EGR/early-router map、DRC violation map 与机器可读 JSON。这说明 iFP、iTO fanout、iPL、iCTS、iRT、iDRC、report/evaluation 基础链路已经可运行。

但当前质量还没有进入签核闭环。WP-RT-01b 后 12/12 设计 DRC 均下降，平均 DRC 改善为 -2.89%，但没有任何设计达到 clean，也没有达到 -20% DRC 改善目标。与此同时，routing runtime 平均增至 trueutil 基线的 3.33 倍，说明现有路由加轮和修复策略有效但性价比不足，继续单纯增加搜索预算不是合理主线。

下一阶段优先级应从“跑通更多流程”切换到“可信测量 + DRC 主因闭环 + 可回归门禁”。P0 先修 STA/SPEF、Power activity、Congestion summary、PDN/IR 四类测量缺口；P1 集中处理 iRT/iDRC 中占主导的 PRL spacing、minimum area、metal short；P2 再做 placement/CTS/routing 联合 QoR 调参；P3 才适合把 agent 优化接入默认实验闭环。

## 2. 数据口径

### 2.1 已验证的事实

| 项目 | 当前状态 |
|---|---|
| 流程完成度 | 12/12 设计生成 post-route DEF/GDS |
| Floorplan 目标利用率 | 实测 CORE Usage 约 65.0% - 65.3%，旧版 MIN_CORE_SIDE 膨胀已移除 |
| DRC clean | 0/12 |
| WP-RT-01b DRC 改善 | 12/12 全降，范围 -4.39% 到 -1.83%，均值 -2.89% |
| WP-RT-01b runtime 代价 | routing runtime 平均为基线 3.33 倍 |
| STA 可信度 | 12/12 抽查路径 `net delay = 0`，且存在未约束 I/O 或缺失 input slew |
| Power 可信度 | 无 VCD/SAIF，switching power 为 0 或 vectorless proxy |
| Congestion | placement/EGR/early-router map 可用；汇总接口曾出现 `Average Congestion=-1` 口径问题 |
| IR-drop | 12/12 未运行 |

### 2.2 WP-RT-01b 改造效果

| PDK | DRC 平均改善 | routing runtime 平均倍率 | 结论 |
|---|---:|---:|---|
| sky130 | -2.24% | 3.78x | PRL spacing 仍是绝对主因，运行时间代价偏高 |
| nangate45 | -1.92% | 1.95x | short 与 PRL 双主因，预算增加收益最低 |
| asap7 | -3.02% | 4.71x | min-area 与 short 主导，耗时膨胀最大 |
| ics55 | -4.39% | 2.89x | min-area 改善相对最好，但仍远未 clean |
| 全部 | -2.89% | 3.33x | 算法杠杆已生效，但未形成签核级闭环 |

口径风险：trueutil 基线使用 `MAX_BOXES=4`，且部分设计 `MAX_ITERATIONS=1`；WP-RT-01b 使用 `MAX_BOXES=48`、`MAX_ITERATIONS=5`。因此 DRC 改善同时包含算法变化与预算变化，不能全部归因为算法本身。

## 3. 模块与工具功能质量矩阵

| 模块/工具 | 当前功能 | 质量评级 | 证据 | 主要缺口 |
|---|---|---|---|---|
| iFP | 基于 cell area/target util 生成 die/core，支持多 PDK floorplan | B | 12/12 CORE Usage 约 65%，stage DEF 齐全 | 缺少 floorplan 阶段拥塞/IO/PDN 预估门禁 |
| iTO fanout | 插入 fanout buffer，输出 fanout DEF | B- | 各设计 fanout stage 均有实例增量 | fanout 后利用率从约 65% 升到约 67%，未见与后续拥塞/DRC 的自动联动 |
| iPL | 全局放置、合法化、filler，输出 density/pin/net maps | B- | placement/legalization/filler stage 完整，9 类密度 map 可用 | 当前 a/b/t 面积策略没有带来 DRC 单调改善，缺少 routability-driven placement 闭环 |
| iCTS | 生成时钟树、buffer、CTS 可视化 | B- | CTS DEF、clock tree/flyline SVG 可用 | CTS 质量未与真实 SPEF STA、post-CTS hold/setup、routing DRC 联动 |
| iRT early/global/detail | layer assign、track assign、early router、detailed router、violation reporter | D+ | WP-RT-01b 12/12 DRC 降低；但 0/12 clean | PRL spacing、min-area、metal short 仍占主导；runtime 代价高；BEST_EFFORT cap 限制单 box 修复深度 |
| iDRC | post-route DRC 检查与 violation map | C | 12/12 输出按类型 DRC 和空间 violation map | 需要规则覆盖回归、规则映射校验、waiver/签核口径，不应只提供总数 |
| iSTA | 输出 WNS/TNS/Fmax | D+ | post-route timing report 存在 | 无 SPEF 回标，net delay 为 0；未约束端口和缺失 input slew 未清零 |
| iRCX | 用于寄生抽取/SPEF 的基础模块存在 | D | 源码与接口存在，但本轮报告无 SPEF-backed STA | 未接入默认 post-route 质量闭环；缺少 SPEF 成功门禁 |
| Power/iPW/iPA | 输出总功耗 proxy | D | 报告有 power 数字 | 无 VCD/SAIF，switching power 不可信；不能服务 IR 或 PPA 决策 |
| iPDN/iPNP/iIR | PDN/IR 模块存在 | F | 报告 IR-drop 12/12 `not_run` | 无 PDN/IR 结果、热图、worst/avg drop、超阈面积 |
| Evaluation/report | 汇总 JSON/CSV/HTML、阶段图、map 渲染 | B- | 报告含机器可读数据与空间图 | congestion summary 曾有 sentinel 口径问题；缺少逐阶段 delta 门禁 |
| Flow/tool_manager/Tcl/Python | 串接多工具与配置 | B- | 多 PDK 12/12 跑通 | 缺少统一质量 gate：DRC 非 clean 仍可被描述为流程 success |
| Agent/AI/feature/vectorization | 具备特征、AI、MCP/agent 接口基础 | C | 源码目录存在，报告 JSON 可作为观测面 | 还没有与 PPA/DRC/IR 回归门禁绑定，暂不应控制默认策略 |

## 4. 主导问题拆解

### 4.1 路由与 DRC 是第一瓶颈

WP-RT-01b 启用 rule-aware cost、enhanced min-area repair、component escalate、PRL/short repair 后，DRC 全部下降，说明方向正确。但下降幅度只有 1.83% - 4.39%，同时 runtime 最高达到基线 4.76 倍。当前 iRT 的瓶颈不是“有没有修复动作”，而是修复动作没有精准打到主导违例并快速收敛。

按 WP-RT-01b 全设计汇总，主导 DRC 类型为：

| DRC 类型 | 全部设计总数 | 优先级 |
|---|---:|---|
| parallel_run_length_spacing | 162,712 | P1 |
| minimum_area | 157,110 | P1 |
| metal_short | 94,112 | P1 |
| end_of_line_spacing | 7,844 | P2 |
| corner_spacing | 7,361 | P2 |
| off_grid_or_wrong_way | 4,770 | P2 |

PDK 差异明显：

- sky130：PRL spacing 是绝对主因，其次 min-area 与 short。
- nangate45：metal_short 与 PRL spacing 接近，是双主因。
- asap7：minimum_area、metal_short、PRL spacing 均高，且 runtime 膨胀最大。
- ics55：minimum_area 绝对主导，适合先做 min-area repair 专项。

### 4.2 STA/Power 当前不能支持 PPA 决策

报告显示 12/12 设计 `all_reported_net_delays_zero = true`。因此当前 WNS/Fmax 只能视为库内单元延迟代理，不可用于 post-route PPA 排名或 CTS/routing 策略选择。未约束端口平均约 4.6 个，缺失 input slew pin 平均约 303.5 个，最大 426 个，说明约束闭环未完成。

Power 同样没有活动率来源。无 VCD/SAIF 时 switching power 缺失或为 0，vectorless 结果只能用于流程贯通，不可用于动态功耗、IR-drop 或 PPA 权衡。

### 4.3 Congestion 有空间证据，但汇总指标未形成 gate

placement density、EGR overflow、early-router map 均能输出并可审计，这是良好基础。但历史报告指出 aggregate `Average Congestion=-1`，说明 summary 层口径存在 sentinel 或未初始化问题。下一阶段需要把 map 原始数据归约成可比较的 top-1%、top-5%、nonzero bin、max overflow、total overflow，并纳入质量门禁。

### 4.4 PDN/IR 尚未进入闭环

iPDN/iPNP/iIR 目录存在，但 AES12 65% 报告 12/12 IR-drop 未运行。没有 PDN/IR 时，power、routing resource、floorplan margin、signoff readiness 都缺关键约束。下一阶段至少要形成“能跑、能报、能 gate”的最小 IR 闭环。

## 5. 下一阶段优化方案

### P0：可信测量闭环，1-2 周

目标：先让 PPA/DRC/IR 指标可信，避免在错误指标上调参。

| 工作包 | 牵头模块 | 交付物 | 验收标准 |
|---|---|---|---|
| SPEF-backed STA | iRCX, iSTA, flow | routing 后自动抽 SPEF，STA 读取 SPEF | 12/12 `net delay > 0`，SPEF 文件存在且被 timing report 标记 |
| SDC 完整化 | flow, iSTA, Tcl | 每 PDK/design 统一 SDC 模板 | unconstrained ports/endpoints = 0；missing input slew = 0 或有显式 waiver |
| Activity-backed Power | iPW/iPA, flow | VCD/SAIF 接入或校准 vectorless activity schema | 12/12 有 activity source 标签，switching power 非零或明确豁免 |
| Congestion summary 修复 | evaluation, report, iRT | 从 map 生成统一 congestion JSON | 无 -1/NaN；输出 max/top1/top5/nonzero/total overflow |
| IR 最小闭环 | iPDN/iPNP/iIR, power | PDN 生成、电流模型、IR report/map | 12/12 有 worst/avg drop、超阈面积、热图 |
| Gate 统一 | platform flow/report | `quality_gate.json` | DRC 非 clean、STA 未回标、IR 未跑时不标记 signoff success |

### P1：DRC 主因闭环，2-4 周

目标：从“全设计小幅下降”提升到“每 PDK 至少 1 个 clean 或接近 clean 的可解释样本”。

| 工作包 | 牵头模块 | 交付物 | 验收标准 |
|---|---|---|---|
| DRC top-rule 回归库 | iDRC, iRT test | PRL/min-area/short/EOL/corner/off-grid 最小 testcase | 每类规则有单测、修复前后 DRC delta 可复现 |
| PRL spacing 专项 | iRT detailed_router, drc_engine | PRL-aware rip-up/reroute 与局部 spacing cost | sky130 PRL violation 降低 >= 20%，runtime 增量 < 2x |
| min-area 专项 | iRT detailed_router, iDRC | patch/extend/fill-style min-area repair | asap7/ics55 min-area 降低 >= 20%，不显著增加 short |
| metal short 专项 | iRT detailed_router | short hotspot component 分裂、via/segment reroute | nangate45/asap7 short 降低 >= 20% |
| 预算扫参实验 | benchmarks/qor, iRT | 1/3/5 iteration、4/16/48 box 可比报告 | 区分算法收益与预算收益，建立默认预算策略 |
| BEST_EFFORT cap 审计 | iRT config/flow | 单 box 任务 cap 可配置并上报 | 高冲突 box 不再固定 cap=4，报告记录实际任务数 |

### P2：布局、CTS、路由联合 QoR，4-8 周

目标：用上游策略降低路由压力，而不是只在详细布线阶段修补。

| 工作包 | 牵头模块 | 交付物 | 验收标准 |
|---|---|---|---|
| Routability-driven placement | iPL, evaluation, iRT early_router | placement 读 EGR/early congestion proxy，支持 congestion weight 扫参 | 同 PDK DRC 与 overflow 对 placement 参数呈可解释变化 |
| utilization/padding DOE | iFP, iPL, benchmarks | utilization x padding x congestion-weight 小型 DOE | 每 PDK 找到至少一组 Pareto 改善配置 |
| CTS 策略扫参 | iCTS, iSTA | buffer set、cluster、fanout/cap sweep | post-CTS/post-route WNS、skew、clock WL、DRC 联合评分 |
| 阶段 delta 观测 | report, design_state | 每阶段 STA/power/congestion/HPWL delta | 超阈值自动判退，定位 QoR 劣化阶段 |
| PDK tech 校准 | iDB, iRT, iDRC | layer direction、track、via、min-area、cut spacing 校验报告 | DRC 主因可回溯到规则、track 或算法，而非黑盒总数 |

### P3：Agent 优化闭环，8 周以后

目标：在 P0-P2 指标可信后，让 agent 只做可审计、可回退的参数优化。

| 工作包 | 牵头模块 | 交付物 | 验收标准 |
|---|---|---|---|
| 观测面标准化 | agent runtime, report | `design_state.json`、`quality_gate.json`、`experiment_manifest.json` | 每次实验可复现输入 hash、工具 hash、配置 diff |
| 安全动作集合 | agent runtime, flow | 有边界参数动作，如 util、padding、routing budget、CTS config | agent 不能修改 PDK/RTL/签核 waiver |
| Pareto archive | benchmarks/qor, agent | 按 PPA/DRC/IR/runtime 维护 archive | 硬约束失败不进入默认策略 |
| holdout 验证 | benchmarks/qor | 非 AES 或新增 PDK/design 验证 | 策略需通过 holdout 才能晋升默认 |

## 6. 模块级优化路线

### 6.1 iRT/iDRC

优先处理 PRL spacing、minimum_area、metal_short 三大类。iRT 需要在 detailed router 中把 violation type、hotspot component、候选 repair action、实际 rip-up/reroute 次数全部结构化输出；iDRC 需要提供 rule id、layer、bbox、net/pin 上下文，以便建立针对性回归。当前仅看总 DRC 或全局 map 不够。

建议新增三个短周期里程碑：

1. `RT-DRC-M1`：规则分类回归可运行，所有 top violation 有最小 testcase。
2. `RT-DRC-M2`：单规则专项 repair 在 testcase 上达到 clean。
3. `RT-DRC-M3`：AES 65% 每 PDK 至少 1 个设计 DRC 降低 >= 20%，runtime 不超过基线 2.5x。

### 6.2 iSTA/iRCX/Power

在 STA 未回标 SPEF 前，不建议用 WNS/Fmax 驱动 placement/CTS/routing 默认策略。iRCX 应成为 post-route flow 的强制步骤之一，失败则质量状态降级。Power 必须记录 activity source，避免 vectorless proxy 被误用为真实动态功耗。

### 6.3 iPL/iCTS

iPL 当前能稳定输出放置结果和密度 map，但 a/b/t 利用率变化没有形成 DRC 单调改善，说明缺少 routability-driven 反馈。下一阶段应把 EGR/early-router proxy 回灌到 placement 参数和 padding 策略中。iCTS 当前工程产物齐全，但评分必须改为 SPEF-backed STA、clock skew、clock wirelength、buffer area、post-route DRC 的联合指标。

### 6.4 iPDN/iIR

IR-drop 是当前最明显空洞。建议先做最小闭环，不追求复杂优化：固定 PDN 模板、电源源模型、电流模型，跑通 worst/avg drop 与热图，再逐步接入 power activity 和 floorplan margin 优化。

### 6.5 Platform/report/evaluation

平台层要把“流程 success”和“质量 success”分开。只要 GDS 存在即可标记 flow completion，但 signoff quality 必须依赖 DRC、SPEF-backed STA、activity-backed power、valid congestion、IR-drop。报告应生成统一 `quality_gate.json`，供人工、CI、agent 共用。

## 7. 建议验收门禁

| Gate | 当前 | 下一里程碑 |
|---|---:|---:|
| Flow completion | 12/12 | 保持 12/12 可重复 |
| DRC clean | 0/12 | 每 PDK 至少 1 个 clean 或 DRC 降低 >= 20%；随后扩至 12/12 |
| SPEF-backed STA | 0/12 | 12/12，关键路径 net delay 非零 |
| Fully constrained timing | 0/12 | unconstrained=0，missing input slew=0 或 waiver |
| Activity-backed power | 0/12 | 12/12 有 activity source，switching power 有可信来源 |
| Valid congestion summary | 历史存在 -1 sentinel | 无 -1/NaN，与 EGR/early-router map 归约一致 |
| IR-drop | 0/12 | 12/12 有 worst/avg/map |
| DRC 主因回归 | 不完整 | PRL/min-area/short 三类都有单测和 AES delta |
| Runtime budget | 平均 3.33x | 默认策略下 DRC 改善/runtime 有明确 Pareto 依据 |

## 8. 推荐执行顺序

1. 第一周：接通 SPEF-backed STA 与 quality gate，修复 congestion summary 口径。
2. 第二周：接入 activity-backed power 与最小 IR report，同时建立 DRC top-rule 回归框架。
3. 第三到第四周：集中做 PRL/min-area/short 三个 iRT repair 专项，并用固定预算 A/B 验证。
4. 第五到第八周：做 placement/CTS/routing 联合 DOE，形成每 PDK 默认策略候选。
5. 第八周以后：把 agent 优化限定在已验证参数空间内，建立 Pareto archive 与 holdout 验证。

## 9. 结论

iEDA.ai 当前最有价值的基础是流程贯通和空间可观测性已经成形；最短板的是签核质量闭环。下一阶段不应继续把目标设为“生成更多报告”或“简单增加 routing 轮数”，而应把资源集中到可信 STA/Power/IR、DRC 主因专项修复、质量 gate 三件事上。只有这些指标可信并可回归后，PPA 调参和 agent 自动优化才会产生可迁移的工程价值。
