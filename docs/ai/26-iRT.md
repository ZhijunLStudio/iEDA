<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 26 · iRT 布线 · 商业对标优化方案 · rv2.1

> 文档号：26-rv2.1　　版本：rv2.1（实现评审优化）　　里程碑：**双对标 —— NanoRoute 精度（G5: DRC=0）× Innovus 性能/调用（冲突分量反馈 + 时序预算 + ECO）**
> 体例：`01-ai-doc-conventions-rv1.md`；深度对标：`27-iSTA-rv2.0.md`（逐 kernel 走读 + 双对标线 + 模块状态一览 + 双看板）
> 商业金标：**Innovus NanoRoute / ICC2 route**（精度：DRC=0 收敛性；性能：反馈控制 + 墙钟）；门禁：**G5 / G17 / G21**（辅 G14）
> 上游：`22-iPL`、`23-iCTS`、`25-iTO`、`24-iPDN`　下游：`28-iRCX`、`27-iSTA`、`30-iDRC`
> 纲领：`00-ieda-commercial-parity-master-plan-v1.1.md`；Know-how：`03-commercial-knowhow-catalog.md` KH-RT-\*
> 联合架构：`04-ppa-technical-review-and-optimization-rv1.md` 的 `DesignState + DirtySet + MoveTxn`；闭环工作台：`51-agent-native-eda-detailed-plan-v1.0.md`
> 覆盖：`src/operation/iRT/`（interface/ 1800 LOC、early_router/ 3651、pin_accessor/ 5521、detailed_router/ 4331、其余八模块 ~16k，全树 ~38k LOC）
> 纪律：**文档是假说不是事实**；断言带 `file:line`；未实测写「未验证」；每条理论附能杀死它的对照。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.0–v1.2 | 2026-07-20 | 功能矩阵 + 简版 LLD；篇幅薄于 24 号深度 |
| rv1.0 / v2.0 | 2026-07-20 | 体例对齐 24-iPL-3d：坐实管线漏 TG/SR、DR 调度硬编码九组、timing 死实现、无 ECO；纠偏管线真相（ER 在 runERT） |
| **rv2.0** | **2026-07-21** | **大改（对照 27-iSTA-rv2.0.md 深度重写，并把目标显式拆成双对标线）**。核心修订五条：**(1)** rv1.0 把 iRT 当「一个管线缺几个控制」审——**代码级核实后发现头号算法症结是内核成熟、外环原始**：DR 内核是 **PathFinder-like 历史代价传播**（`routeDRBoxMap` 网络依赖 `routed_rect` 与 `violation` 加权，`DetailedRouter.cpp:1425-1574`）+ A* 类详布（`routeDRBox` 弧展开+优先队列，`:2659-2780`），**工业级内核**；但外环是**固定九幕剧本**（字面量调度表，`:126-134`），无 plateau 检测（`stopIteration` 仅 clean 早停，`:2426-2432`），无策略升级机制——对标 NanoRoute「plateau→换 box/代价/撕布」的反馈控制，**外环收敛控制是核心差距**（§1.2，类比 27 号 §1.4「in-design 调用 10:1」的结构症结）；**(2)** 新增 **逐 kernel 走读**（§1.2 表：ER/PA/SA/TG/LA/SR/TA/DR/VR/DE 十模块的现状算法 / 判定 / 缺口三列）：PA 5521 LOC 重型成熟、TG 依赖 Flute、DR 内核 4331 LOC 含 A*/patch/min-area、VR 有层×类型汇总——**架构不弱，缺口在控制器与时序接线**；**(3)** 全文按**双对标线**重组：NanoRoute 线 = 精度栈（DRC=0 收敛性 + 可诊断违例归因 → G5），Innovus 线 = 性能/调用栈（plateau 反馈 + 时序驱动排序/代价 + 墙钟 → G17/G21），§10 拆成两块看板；**(4)** 补齐 27 号体例要素：§4.12 模块状态一览（十模块成熟度/复杂度/边界/复用姿势）、§5 双档配置表（effort 包 low/medium/high + plateau 关）、§8 跨工具契约表（iRT→iDRC 接通 vs iRT→iSTA 死）、§10.3 对照实验（E-RT-01~08，每个假说附能杀死它的实验）、§14 未验证/负面结论明确区分；**(5)** 新增 **算法复杂度与边界分析**（§4.A-G 各模块算法伪代码、O() 标注、edge case 边界、复用姿势禁止平行重写）。**缺省新杠杆关闭 → 零回归**纪律不变。 |
| **rv2.1** | **2026-07-23** | 实现评审：plateau 从“违例数相等”升级为完备率/加权严重度/热点集合/线长 via 状态向量；只升级连通冲突分量；修复时序 criticality 归一化和验收；补 box 冲突图并行提交、ECO 冻结哈希与数据布局/分配剖面。 |

---

## 1. 症结审计（逐 kernel / 逐模块代码走读）

对 `src/operation/iRT/` 全树（interface/ 1800 LOC + early_router/ 3651 + pin_accessor/ 5521 + detailed_router/ 4331 + topology_generator/ 1587 + layer_assigner/ 1966 + space_router/ 2597 + track_assigner/ 2257 + supply_analyzer/ 703 + violation_reporter/ 848 + drc_engine/ 427，全树 ~38k LOC）走读后的判定。**前提**：rv2.0 不推翻 rv1.0 的核心发现（管线含 TG/SR、DR 调度硬编码、timing 死实现、无 ECO），但把审计深度对齐 27-iSTA-rv2.0.md：逐 kernel 给「现状算法 / 判定 / 缺口」三列，并新增 rv1.0 没有的结构级审计（§1.3 内核-外环解耦症结、§1.4 时序接线审计）。

### 1.1 功能形态——完整多阶段管线在，收敛控制器原始

**完整管线存在**（`runRT()`，`RTInterface.cpp:108-147`）：

```text
initRT → [runERT: ER独立] → runRT: PA → SA → TG → LA → SR → TA → DR → VR → destroyRT
```

- `runERT()`（`:90-106`）单独跑 EarlyRouter（access/supply/2D–3D EGR 阶段），**不在** `runRT` 内。
- `runRT()`（`:108-147`）串联八段：PinAccessor → SupplyAnalyzer → **TopologyGenerator** → LayerAssigner → **SpaceRouter** → TrackAssigner → DetailedRouter → ViolationReporter。
- rv1.0 纠正：漏写 TG/SR；ER 位置错标。

**DR 外环是固定九幕剧本，不是反馈控制器**（头号症结 S1）：

1. `routeDRModel`（`DetailedRouter.cpp:107-167`）本地构造 `dr_iter_param_list`，**九次** `emplace_back`（`:126-134`），每组 `size` 恒 **`12`**、`offset` 轮转 `{0,4,8}`、代价倍率梯度 `1×→2×→4×`、`max_routed_times` `{3,5,15}`。
2. **零处**从外部读调度表；`Config.hpp:60-61` 仅 `dr_temp_directory_path`。
3. `stopIteration`（`:2426-2432`）条件：`(iter != list.size()) && getRouteViolationNum==0` → 仅 clean 早停。**违例连平 / 上升 / 热点均不触发任何策略切换**——全仓 `grep plateau` 生产代码**零命中**。
4. 有 keep-best（`updateBestResult` `:2388-2424` 按 `getViolationScore`、`selectBestResult` 九轮后回灌）——这是「历史最好」，**不是** plateau 后换策略。

**多线程骨架在，自适应调度无**：`routeDRBoxMap` 等处 `#pragma omp parallel for`（`:319,:410,:2223`）；`thread_number` 可配（`RTInterface.cpp:361`，默认 128）。

### 1.2 算法成熟度——逐 kernel 走读（内核成熟，外环原始）

| kernel | LOC | 现状算法 | 判定 | 缺口 |
|---|---|---|---|---|
| **DetailedRouter 内核** | 4331 | **PathFinder-like 历史代价传播**（网络依赖 `routed_rect` 与 `violation` 权重，`DetailedRouter.cpp:1425-1574`）+ **A* 类详布**（`routeDRBox` 弧展开+优先队列，`:2659-2780`）+ patch（`:2946-3069`）+ min-area 修复（`:3099-3169`） | **工业级内核**，有代价梯度、障碍避让、patch 机制 | **外环收敛控制**（调度硬编码、无 plateau、无策略升级）是核心差距，**不是**内核算法弱 |
| DetailedRouter 外环 | — | 固定九幕（`:126-134`）+ 仅 clean 早停（`:2426-2432`）+ keep-best（`:2388-2424`） | **原始控制器**——无反馈、无自适应 | **头号症结 S1**：vs NanoRoute「plateau→换 box/代价/撕布」的反馈控制 |
| EarlyRouter | 3651 | access 冲突消解 + supply 分析 + 分阶段 EGR（`ERStage`）拓扑/层赋 | **成熟粗布线资产**；与 runRT 内 SA/TG/LA 能力重叠 | 职责边界未文档化（默认 TCL flow 走哪条未验证） |
| PinAccessor | 5521 | pin access 点搜索 / patch / 冲突消解 | **重型成熟**；是 PA 主战场 | — |
| SupplyAnalyzer | 703 | GCell supply/demand 统计 | 教科书+工程化；供 LA/SR | — |
| TopologyGenerator | 1587 | **Flute** 平面 Steiner 树拓扑生成 | 成熟；依赖 `initFlute` | 复用 Flute Composition |
| LayerAssigner | 1966 | 层分配 / GR→DR 桥接 | 成熟 | — |
| SpaceRouter | 2597 | 层上空间路由 / demand 修正 | **rv1.0 漏写**；生产必经 | — |
| TrackAssigner | 2257 | track 分配 / 轨道化 | 成熟；DR 前置 | — |
| ViolationReporter | 848 | 终态 DRC 汇总 + **层×类型表**（within/among × type × layer，`:181-257`）+（可选）JSON | 成熟报告器；默认 JSON 关 | 门控与 harness 解耦 |
| DRCEngine | 427 | 对接 iDRC / IDS | Composition；规则源应走 tech（KH-RT-06） | 规则硬编码红线待扫（未验证） |
| `RTInterface::updateTiming` | ~200（注释掉部分） | **整函数体注释**（`:1522+`，含数据结构到 `getWNS/getTNS`） | **死实现**（症结 S3） | 时序闭环断开（iRT→iSTA 单向死） |

**四项缺失的工业杠杆**（对标 NanoRoute / ICC2，逐项核实为「当前无」）：

| # | 杠杆 | 代码事实 | 落点 |
|---|---|---|---|
| ① | **stagnation→局部换策略**（冲突分量扩 halo / 历史代价 / 选择性撕布） | `stopIteration` 仅 clean 早停；无反馈 API | §4.A |
| ② | **自适应 / 可配 box** | `size=12` 九组字面量 | §4.A / §5 |
| ③ | **时序驱动排序或代价** | `enable_timing` 不进 wire/via/violation cost；`updateTiming` 空 | §4.B |
| ④ | **ECO 局部拆线重布** | `ecos` = notification only | §4.D |

**假说 H1（可杀）**：G5 失败主因是外环策略耗尽（固定九轮无升级），而非内核 A*/PathFinder 算法弱。
**杀死实验 E-RT-01**：同一违例残留设计，手动调大 box（24/48）或加倍迭代数；若违例显著下降 → 外环是瓶颈（支持 H1）；若不降 → 内核也有问题，杀 H1。

**假说 H2（rv2.0 新增，可杀）**：DR 墙钟大头在 box 内 A* 路由（`routeDRBox`），而非外层调度。
**杀死实验 E-RT-02**：剖面单轮 DR：box 调度开销 vs `routeDRBox` 累计墙钟；若调度 < 5% → 支持 H2；若调度 ≥ 20% → 杀 H2，改查并行效率/box 切分。

### 1.3 ★内核-外环解耦症结——头号结构判定（类比 27 号 §1.3「三套栈」）

rv1.0 的隐含前提是「DR 整体能力弱」。**代码级核实：错。内核算法成熟，症结在外环控制器与内核解耦：**

**内核层（DetailedRouter.cpp 内部，`:2659-3169`）**：

| 组件 | 能力 | 证据 `file:line` | 判定 |
|---|---|---|---|
| `routeDRBox` A* 搜索 | 弧展开 + 优先队列 + bend/via/wire 代价 | `DetailedRouter.cpp:2659-2780` | **工业级 A\***，有方向偏好、障碍避让 |
| 历史代价传播 | `routed_rect_unit` / `violation_unit` 权重叠加 | `:1425-1574`（cost 计算）；DRIterParam 携带权重倍率 | **PathFinder-like**：网络依赖历史违例加权逼疏散 |
| Patch 机制 | 候选 patch 生成 + 最小代价选择 | `:2946-3069` `patchDRBox` | 有工业深度（非简单 ripup） |
| Min-area 修复 | 检测并修复 min-area 违例 | `:3099-3169` `repairDRBox` | signoff 必需，已有 |

**外环层（`routeDRModel`，`:107-167`）**：

| 组件 | 能力 | 证据 | 判定 |
|---|---|---|---|
| 调度生成 | 九次 `emplace_back` 字面量 | `:126-134` | **硬编码**；无外部配置 |
| 收敛判定 | 仅 `vio==0` 早停 | `:2426-2432` `stopIteration` | **无 plateau 检测**；连平不触发 |
| 策略升级 | 无 | `grep "plateau\|escalate\|strategy"` 零命中 | **无反馈控制** |
| 调度参数 | 固定 `size=12`、`offset={0,4,8}` 轮转、代价倍率 1/2/4× | `:126-134` | 不可配，不自适应 |

**与 NanoRoute 的差距逐项**（对标 Innovus 行为，类比 27 号 §1.4 in-design 调用审计）：

| NanoRoute/ICC2 行为 | iRT 现状 | 缺口落点 |
|---|---|---|
| plateau 检测（违例连平窗口） | 无检测 API | §4.A plateau 算法 |
| 策略升级（稳定热点冲突分量扩 halo、历史代价、选择性撕布） | 固定九幕，无分支 | §4.A 策略表 |
| 可配调度表（box/offset/cost/effort） | 字面量嵌死 `.cpp` | §5.1 配置外置 |
| 违例残留诚实拒绝 | 可能静默完成+残留 DRC | §4.A.2 fail_on_residual |
| 时序驱动（关键网排序/slack 代价） | `updateTiming` 空+不进代价 | §4.B |
| ECO 局部拆线 | 仅 notification | §4.D |

**量化**：内核有 PathFinder 代价梯度（1×→2×→4×）+ A* 搜索 + patch/min-area，**算法深度不弱于教科书 PathFinder**；外环是**固定循环**而非**反馈控制器**——这正是 NanoRoute「plateau-driven routing」架构要实现的东西（§3.2-D1、§4.A）。

**诚实归因**：内核成熟有工程理由——iRT 已走过 A*/代价梯度/patch 的算法积累期；但外环原始也有历史——早期目标是「能跑通」，收敛控制未成为设计焦点。代价是真实的：**中密度设计可能九轮耗尽仍有残留违例，且无自适应升级路径**（G5 主要障碍，未验证但 E-RT-01 可测）。

### 1.4 ★时序接线审计——现状单向断开（iRT→iSTA 死，iSTA→iRT 无）

对 iRT/iSTA 双向接口的现状统计（代码走读，可复现）：

| 方向 | 接口 | 现状 | 证据 `file:line` |
|---|---|---|---|
| iRT → iSTA | `RTInterface::updateTiming` | **函数体大段注释**（含 TimingEngine 初始化 lambda、`getWNS/getTNS` 调用、`clock_timing_map` 填充全部注释） | `RTInterface.cpp:1522-1730` |
| iRT 代价计算 | slack 进 wire/via cost | **无 slack 乘数**；只用 `prefer/non_prefer/via/bend/fixed/routed/violation_unit` | `:1425-1574` cost 路径 |
| iRT summary | timing 槽位 | `printSummary` 有 timing 表（`DetailedRouter.cpp:3335-3342`），但 `enable_timing!=0` 时 `clock_timing_map` 仍空（`updateTiming` 不填） | `:3248-3263` `updateSummary` 调用空壳 |
| iSTA → iRT | slack→net 排序/代价 | **全无**（iRT 无从 iSTA 读 slack 的路径） | 无 `#include "TimingEngine.hh"` 于生产代码 |

**与 NanoRoute timing-driven 的差距**：

| Innovus/ICC2 timing-driven 行为 | iRT 现状 | 缺口 |
|---|---|---|---|
| 关键网优先布（slack 更负更先） | 无排序 | §4.B Phase1 |
| Slack-aware 代价（crit 网加权 ripup cost） | 代价路径无 slack 项 | §4.B Phase2 |
| 每轮 DR 后时序重算（验证改善） | `updateTiming` 空 | §4.B 报告复活 |

**判定**：`enable_timing` 开关**存在**（`Config.hpp:36`，默认 0），但实现**已死**——开关打开后：(1) `updateTiming` 空操作 → `clock_timing_map` 保持空；(2) summary timing 表空；(3) cost 计算无 slack 项 → **布线 DEF 不变**（假说，E-RT-03 可杀）。相对 rv1.0「疑似只报告」判定，rv2.0 升级为：**非报告向，而是开关+槽位存在但实现已死**（类比 27 号 §1.7-1 SI 注释掉）。

### 1.5 ★精度栈逐项——对 NanoRoute signoff 的差距清单（NanoRoute 对标核心）

NanoRoute signoff 级布线的 DRC=0 收敛性来自一整套互相咬合的机制。逐项核实 iRT 差距（✓=有且生产在用，⚠️=有但半残，✗=无）：

| # | NanoRoute 机制 | iRT 现状 | 证据 | 对 DRC 收敛的影响 | P |
|---|---|---|---|---|---|
| 1 | PathFinder 历史代价传播 | ✓ | `DetailedRouter.cpp:1425-1574` 代价叠加；DRIterParam 权重倍率 | 基准 | — |
| 2 | A* 详布 + 障碍避让 | ✓ | `:2659-2780` `routeDRBox` | 基准 | — |
| 3 | Patch / min-area 修复 | ✓ | `:2946-3069` patch；`:3099-3169` min-area | signoff 必需 | — |
| 4 | **plateau 检测** | ✗ | `stopIteration` 仅 clean（`:2426-2432`）；`grep plateau` 零命中 | 违例连平时无升级路径 → 可能早卡死 | P0 |
| 5 | **策略升级（box/代价/撕布）** | ✗ | 固定九幕（`:126-134`）；无策略分支 | plateau 后无反应 → 残留违例 | P0 |
| 6 | 可配调度表 | ✗ | 字面量硬编码 | 无法针对设计调优 effort | P1 |
| 7 | 时序驱动排序 | ✗ | 无 slack 读取路径 | 关键网可能后布导致拥塞 | P1 |
| 8 | 时序驱动代价 | ✗ | cost 路径无 slack（`:1425-1574`） | crit 网 detour 代价不足 | P1 |
| 9 | **DRC 残留诚实拒绝** | ✗ | 九轮后 `runRT` 仍正常返回；无 `route_incomplete` 标记 | **假 clean**（G5/G14） | P0 |
| 10 | 违例层×类型归因 | ✓ | VR 有 within/among × type × layer 表（`ViolationReporter.cpp:181-257`） | 可诊断 | — |
| 11 | 违例 JSON harness 可读 | ⚠️ 默认关 | `outputJson` 需 `enable_notification`（`:503-507`） | harness 假阴性风险 | P1 |
| 12 | NDR / SI spacing 膨胀 | ✗（未见独立膨胀环） | — | 先进工艺 SI 约束 | P2 |
| 13 | vs NanoRoute 对拍 harness | ✗ | 无 `benchmark/qor/irt/` | **G5/G17 不可证** | P0 |

**§1.5 结论**：精度缺口是**结构性的两层**——(a) 控制层：plateau/策略/诚实拒绝（#4/5/9，P0）；(b) 时序层：排序/代价（#7/8，P1）；(c) 对拍层：harness（#13，P0）。内核算法（#1-3）**不是**缺口。

### 1.6 边界 / 回退 / 假成功——操作化尚可，缺诚实拒绝

- **边界较全**：DR box 初始化、`max_routed_times`、`max_candidate_patch_num`、min-area patch、违例上传多轮（`routeDRModel` 内 `uploadViolation` 两次 + final）。优于「取数→循环→写回」三行式脚本。
- **checkpoint**：box 级与 model 级 `updateBestResult`；终态 `selectBestResult`。**但**九轮结束仍有违例时：`runRT`/`route()` 仍走完 → **无失败 rc**（对照 G5「诚实拒绝」、G14）。**未验证** TCL 层是否检查 VR 总数——标「未验证」，P0 实测。
- **配置缺省策略偏软**：`getConfigValue`（`Utility.hpp:2251-2260`）缺键 → `RTLOG.warn` + 默认值，**不 error**。相对主纲 G14 / KH-X-04，未知关键键应响亮失败（§4.F、§7）。
- **结构化日志半通**：每 DR iter 有 fort 表 +（`output_inter_result`）CSV；JSON 多受 `enable_notification` 门控（VR `outputJson` `:503-507`）。**缺**机器可读 `iter_dr_series.json`（违例序列专档）与 `route_incomplete` 失败码。

### 1.7 死配置 / 死接线 / 假成功点名

1. **`RTInterface::updateTiming` 函数体大段注释**（`RTInterface.cpp:1522+`）——时序接口是死骨架。
2. **无 plateau API / 无策略升级机制**——`stopIteration` 仅 clean 早停，无策略分支。
3. **调度表嵌死 `.cpp`**——`Config` 无 `dr_schedule` / `plateau_window` / `enable_eco` 字段。
4. **`ecos` 名不副实**：`#if 1 // ecos` 仅 notification（`RTInterface.hpp:154-156`）。
5. **VR JSON 默认关**：依赖 `enable_notification`；G5 harness 若只读 JSON 会假阴性。
6. **九轮后残留违例可能静默完成**——无 `route_incomplete` 标记、无非零 rc。
7. **ER vs runRT 双入口**：能力重叠边界、默认 TCL flow 走哪条——**未验证**（§14.1）。

### 1.8 症结优先级表（§1 结论摘要）

| ID | 症结 | 证据 | 对标线 | P |
|---|---|---|---|---|
| **S1** | **无 plateau 检测 + 无策略升级**（外环固定九幕） | `DetailedRouter.cpp:126-134` 字面量；`:2426-2432` 仅 clean 早停；`grep plateau` 零命中 | NanoRoute | P0 |
| **S2** | **调度表硬编码**（box=12 不可配） | `:126-134`；`Config.hpp:60-61` 无调度字段 | NanoRoute | P0 |
| **S3** | **timing 死实现**（`updateTiming` 空+不进代价） | `RTInterface.cpp:1522+` 函数体注释；`DetailedRouter.cpp:1425-1574` 无 slack | NanoRoute | P0 |
| **S4** | **DRC 残留无诚实拒绝**（假 clean） | 九轮后 `runRT` 正常返回；无 `route_incomplete` | NanoRoute | P0 |
| **S5** | **无 vs NanoRoute harness → G5 不可证** | 无对齐脚本/schema | NanoRoute | P0 |
| S6 | VR JSON 默认关（门控风险） | `ViolationReporter.cpp:503-507` `enable_notification` | NanoRoute | P1 |
| S7 | 无 ECO route | `RTInterface.hpp:154-156` 仅 notification | NanoRoute | P1 |
| S8 | ER/runRT 双入口边界未验证 | 能力重叠；默认 flow 未文档化 | — | P1 |

**§1 最关键 5 条**：S1（plateau/策略）、S2（调度外置）、S3（timing）、S4（诚实拒绝）、S5（harness）。

---

## 2. 需求 FR / NFR / 约束

### 2.1 FR（★ = 相对现状新增）

| ID | 功能 | 现状 | rv2.0 |
|---|---|---|---|
| FR-RT-01 | GR/TA/DR 八段管线（PA→SA→TG→LA→SR→TA→DR→VR） | ✓ | 保留；文档纠偏 TG/SR |
| FR-RT-02 | ★ **stagnation 检测**（完备率/加权严重度/热点集合/WL-via 状态向量） | 无；仅 clean 早停 | ★ 缺省关；`enable_plateau=0` 零回归 |
| FR-RT-03 | ★ **冲突分量策略升级**（局部窗口/历史代价/选择性撕布） | 固定九幕 | ★ 只处理稳定热点的连通分量，禁止全局盲目 box×2 |
| FR-RT-04 | ★ **可配 DR 调度表**（box/offset/代价倍率/effort） | 字面量 size=12 | ★ 外置 JSON/内嵌表；默认表≡今日九组 |
| FR-RT-05 | ★ **DRC 残留诚实拒绝**（`route_incomplete` + 非假 clean） | 静默跑完 | ★ G5；`fail_on_residual_drc` 建议默认 true |
| FR-RT-06 | ★ **时序驱动 Phase1**（关键网排序） | 死 `updateTiming` + 无 slack 读取 | ★ 缺省关；依赖 G7（iSTA 可信） |
| FR-RT-07 | ★ **时序驱动 Phase2**（slack-aware 代价） | cost 路径无 slack | ★ 缺省关；单独 PR |
| FR-RT-08 | ★ **违例终态 JSON**（层×类型×bbox），禁中间态 | VR 有能力；默认 notification 关 | ★ 独立开关；建议 harness 默认开 |
| FR-RT-09 | ★ **`routeECO(net_names)` 局部拆线重布** | 无 | ★ Phase C |
| FR-RT-10 | ★ **未知关键 config 键响亮失败**（G14） | WARN+默认 | ★ 严格键表+响亮 |
| FR-RT-11 | ★ **vs NanoRoute 苹果对苹果 harness** | 无 | ★ G5/G17；`benchmark/qor/irt/` |
| FR-RT-12 | ★ **Exhibit 机读**：`iter_dr_series` + `violation_summary` + 失败码 | 半通（fort/CSV） | ★ JSON schema |
| FR-RT-13 | NDR / SI spacing 膨胀 | 未见 | Phase C（P2） |
| FR-RT-14 | ★ **effort 包**（low/medium/high）多轮渐进 | 固定九幕 | ★ §5.2 |

### 2.2 NFR（可测数字）

| ID | 项 | 指标 | 对标线 |
|---|---|---|---|
| NFR-RT-01 | **G5 中密度设计 DRC** | **=0**；或诚实拒绝+定位 | NanoRoute |
| NFR-RT-02 | 密设计 | 违例 < 阈值 **或** `route_incomplete` | NanoRoute |
| NFR-RT-03 | WL / via vs 商业 | δ≤8%（主纲分层；独立转绿） | NanoRoute |
| NFR-RT-04 | post-route WNS（双方 PT） | 进 G17；timing 杠杆真化后 A/B | NanoRoute |
| NFR-RT-05 | **route 墙钟** | 日常 ≤1.5× 商业；大设计 ≤3×（G21/G20） | **NanoRoute** |
| NFR-RT-06 | **零回归** | 关 ★杠杆时与当前二进制行为一致 | 双 |
| NFR-RT-07 | plateau 日志 | 可机读（轮次/违例/动作） | — |
| NFR-RT-08 | 峰值内存 | 记录；plateau 策略不恶化超 20% | NanoRoute |

### 2.3 红线约束

- **金标 = Innovus NanoRoute / ICC2 route**（精度：DRC=0 收敛性；性能：plateau 反馈 + 墙钟）；G17 route 行最终以双方 DEF 经 PT + signoff DRC 读数为准。
- **无 G5 背书，不准关闭 G17 route 打平**。
- **缺省新杠杆关闭 → 零回归**（plateau/timing/ECO 均显式开关）。
- 禁止静默吞掉未知关键配置键（G14）。
- 禁止用 DRC 自报「打平」而无外生 NanoRoute 对照（G15）。
- **禁止重写整个 DetailedRouter 内核换收敛**（附录 B E-1）——内核成熟，缺口在外环（§1.3）。
- **禁止把空 `updateTiming` 宣传为 timing-driven**（G14）——开关真化前文档必须诚实标「未实现」。

---

## 3. HLD 总体架构

### 3.1 数据流（据真实 `RTInterface` 重画，双对标线标注）

```
  iPL/iCTS/iPDN: DEF + nets + fixed shapes     tech LEF/rules
  ★iSTA: slack (Phase1/2) 注入排序/代价        iDRC: DRCEngine
          │                                          │
          └──────────────────┬───────────────────────┘
                             ▼
        ┌────────────────────────────────────────────────────────────┐
        │  RTInterface                                                │
        │  initRT(config_map) → DataManager + DRCEngine + GDSPlotter │
        │                                                              │
        │  runERT(config):  EarlyRouter (access/supply/EGR stages)     │
        │                   （独立粗布线；与 runRT 能力重叠待边界）      │
        │                                                              │
        │  runRT():  八段管线                                          │
        │    PinAccessor.access     ← 重型成熟（5521 LOC）             │
        │    SupplyAnalyzer.analyze ← GCell supply/demand             │
        │    TopologyGenerator.generate ← Flute Steiner 树            │
        │    LayerAssigner.assign   ← GR→DR 桥                         │
        │    SpaceRouter.route      ← 层空间路由                        │
        │    TrackAssigner.assign   ← 轨道化                           │
        │    DetailedRouter.route   ← ★内核成熟（PathFinder+A*）        │
        │      ├ 内核：routeDRBox (A* + patch + min-area)             │
        │      └ 外环：routeDRModel ← ★plateau/调度外置/时序排序        │
        │    ViolationReporter.report ← ★终态 JSON / G5 检查           │
        │                                                              │
        │  ★ routeECO (Phase C)                                        │
        │  destroyRT → output DEF                                      │
        │  Exhibit: ★iter_dr_series / violation_summary JSON          │
        └────────────────────────────────────────────────────────────┘
                             │
           ┌─────────────────┴─────────────────┐
           │ NanoRoute 精度线                  │ Innovus 性能线
           ▼                                   ▼
    iDRC signoff DRC=0              iRCX / iSTA / iTO / eval (G17)
    vs NanoRoute harness (G5)       墙钟剖面 (G21)
```

### 3.2 关键设计决策（含被否）

| ID | 决策 | 被否方案 | 理由 |
|---|---|---|---|
| **D1** | **plateau 最小切口**挂在 `stopIteration` 旁，不重写 A* | 重写整个 DR 内核 | **内核成熟**；缺口在外环（§1.3 核心判定，KH-RT-02） |
| D2 | **调度表外置**，默认 JSON/内嵌表 ≡ 今日九组 size=12 | 立刻改默认 box | 零回归（NFR-RT-06） |
| D3 | 时序 **先关键网排序**，再 slack 代价 | 一步改代价数值 | 数值稳定性；代价依赖 G7 |
| D4 | 违例产物 **只认 DR/VR 最终态** | 读 TA 中间态 | fork 教训；G5/iDRC 共读 |
| D5 | ECO / NDR / SI → **Phase C** | 与收敛同 PR | 降低耦合 |
| D6 | **新杠杆缺省关**；G14 响亮失败可默认开 | 混在同一开关 | 正确性≠QoR 实验 |
| D7 | **商业对照外生度量**（双方 PT + 同 DEF 输入） | 只用 iSTA 自评打 G17 | 主纲 §1bis / KH-X-01 |
| **D8** | **双对标线显式**（NanoRoute 精度 × Innovus 性能） | 单一「打平」目标 | 精度（DRC=0）与性能（墙钟）解耦；§10 双看板 |

---

## 4. LLD · 模块分解

### 4.0 落点

```text
src/operation/iRT/
  interface/RTInterface.cpp|.hpp     ← ECO API、config、updateTiming 真化
  source/data_manager/advance/Config.hpp
  source/module/detailed_router/
    DetailedRouter.cpp               ← plateau/调度/box
    dr_data_manager/DRIterParam.hpp
  source/module/violation_reporter/ViolationReporter.cpp
  source/toolkit/utility/Utility.hpp ← getConfigValue G14
benchmark/qor/irt/
  run_route_parity.sh
  violation_summary.schema.json
  iter_dr_series.schema.json
```

### 4.A DetailedRouter · 反馈控制收敛（FR-RT-02/03/04，NanoRoute 精度线主杠杆）

**真实现状**：`routeDRModel` 硬编码九组（`DetailedRouter.cpp:107-167`）；`stopIteration` 仅 clean 早停（`:2426-2432`）；有 keep-best（`:2388-2424`）。**内核成熟**（§1.3）：`routeDRBox` A* + PathFinder 代价（`:2659-2780` + `:1425-1574`）。

#### 4.A.1 配置数据结构（★新增，缺省=现状零回归）

```cpp
struct DRIterParamRow {  // 与现 DRIterParam 字段对齐
  double prefer_wire_unit, non_prefer_wire_unit, bend_unit, via_unit;
  int32_t size;      // 今日恒 12
  int32_t offset;    // 0/4/8
  int32_t schedule_interval;
  double fixed_rect_unit, routed_rect_unit, violation_unit;
  int32_t max_routed_times, max_candidate_patch_num;
};

struct DRScheduleConfig {
  std::vector<DRIterParamRow> iters;  // 默认 = DetailedRouter.cpp:126-134
  bool enable_plateau = false;        // ★缺省关
  int plateau_window = 3;
  double min_relative_improvement = 0.02;
  double hotspot_jaccard_threshold = 0.85;
  std::vector<int> local_halo_escalate = {1, 2, 4};
  bool enable_ripup_hotspot = false;  // ★缺省关
  bool fail_on_residual_drc = false;  // G14/G5；建议生产默认 true（正确性）
};
// Config.hpp 增：DRScheduleConfig dr_schedule;
```

#### 4.A.2 算法伪代码 + 复杂度 + 边界

```text
ALG-4.A-1  routeDRModel（标注新增部分）
输入：nets, obstacles, tech_rules, cfg
输出：routed_result, vio_num (or route_incomplete)

  list ← loadSchedule(cfg)          // [已有] 无 cfg 时用内置九组
  vio_series ← []
  best_result ← ∅
  
  for iter in 1..list.size:
    setDRIterParam(list[iter]);      // [已有] 设代价权重
    initDRBoxMap();                  // [已有] 切分 GCell box
    buildBoxSchedule();              // [已有] box 优先级排序
    routeDRBoxMap();                 // [已有] 并行 box 内 A* 路由
    uploadViolation();               // [已有] DRC 检查
    updateBestResult(vio_score);     // [已有] keep-best (:2388-2424)
    updateSummary();                 // [已有] 日志/CSV
    
    state = {route_completeness,
             weighted_vio_severity(type,layer),
             hotspot_component_set,
             wirelength, via_count}
    state_series.push(state)
    
    if stopIteration_clean: break    // [已有] :2426 vio==0 早停
    
    ★ if cfg.enable_plateau and detectStagnation(state_series, window):
      level++
      component ← highest_severity_stable_hotspot()
      act ← nextAction(component, level)  // kExpandLocalHalo | kReweightHistory | kRipupComponent | kGiveUp
      RTLOG.info("plateau detected", iter, vio, act)
      applyOnly(component, act)  // 不扩大无关区域，不饿死普通网
      if act==kGiveUp: break
      
  selectBestResult()                 // [已有] 回灌历史最好
  
  ★ if residual_drc > 0 and cfg.fail_on_residual_drc:  // ★新增 G5
      return route_incomplete

复杂度：O(I · B · RouteBox)
  I = 迭代数（9 或 plateau 延长）
  B = box 数（设计相关，~数百到数千）
  RouteBox = 单 box A* 成本 O((pins·gcells)·log(queue_size))
  plateau 检测：O(window)，可忽略

边界：
  - window=0 或 enable_plateau=false → 行为≡现状九幕
  - 无稳定热点分量 → 继续原调度，不做全局升级
  - 所有策略耗尽 + 仍有违例 → give_up 或 fail_on_residual
  - list 为空 → LOG_ERROR，返回失败

复用姿势：
  - 自建调度器（封套层）+ 复用现有 routeDRBoxMap 内核
  - **禁止**平行第二套 DR 或重写 A* 内核（D1）
```

```text
ALG-4.A-2  detectStagnation（★新增）
输入：state_series[], window
输出：bool + stable_hotspot_components

  if state_series.size < window+1: return false
  improvement = (severity_old-severity_new)/max(severity_old, eps)
  stable = Jaccard(hotspots_old, hotspots_new) ≥ hotspot_jaccard_threshold
  complete_not_better = route_completeness_new ≤ route_completeness_old + eps
  cost_not_better = normalized(WL,via)_new ≥ normalized(WL,via)_old - eps
  return improvement < min_relative_improvement && stable && complete_not_better && cost_not_better

违例按 rule severity、层和影响长度加权；单纯“总数相等”不能区分一个 short 与多个轻微 spacing。
复杂度：热点集合已排序时 O(window·V)；window=0 → 禁用。
```

并行提交：为 DR boxes 建共享边界/网/违例分量冲突图，图着色后每色并行计算 thread-local route delta；barrier 处按 `(color, box_id, net_id)` 确定性提交并统一更新 history cost。禁止多个线程直接竞争写全局 occupancy/violation 容器。

| 步 | 动作 | 钩子位置 | 复杂度影响 |
|---|---|---|---|
| 1 | 每轮记录 `vio_num` → `iter_dr_series` | `updateSummary` 旁 | O(1) |
| 2 | `stopIteration` 旁调 plateau | `:2426` 附近 | O(window) |
| 3 | box 从调度表取，禁写死 12 | `:126-134` | — |
| 4 | 策略耗尽 → 非假 clean | G5 return 前 | O(1) |

Know-how：KH-RT-01/02/03（PathFinder 历史代价、plateau→策略、自适应 box）。

### 4.B 时序驱动（FR-RT-06/07，NanoRoute 性能线）

**真实现状**：调用槽在（`DetailedRouter.cpp:3248-3263`）；`updateTiming` 空（`RTInterface.cpp:1522+`）；代价无 slack（`:1425-1574`）。

```text
ALG-4.B-1  复活报告路径（P0，前置）
  恢复 RTInterface::updateTiming 真实现（或 Composition 调 iSTA API）
  enable_timing=1 → clock_timing_map 非空（可测）
  仍不改布线 → 仅报告（诚实命名：timing-aware reporting，不是 timing-driven routing）
```

```text
ALG-4.B-2  Phase1 关键网排序（★缺省 enable_timing_sort=0）
输入：nets[], slack_map (from iSTA)
输出：sorted_nets[]

  if !enable_timing_sort: return nets  // 缺省关 → 零回归
  
  slack_map ← STA::getSlackMap()  // 须 G7 可信
  stable_sort(nets, [&](a, b) {
    return slack_map[a] < slack_map[b];  // 更负更先（setup）
  });
  RTLOG.info("timing-driven sort enabled", crit_net_count)
  return nets

复杂度：O(N log N)，N=net 数；stable_sort 保证同 slack 的原序
边界：
  - enable_timing_sort=0 → 现状顺序，零回归
  - slack_map 空或 iSTA 未 ready → LOG_ERROR，回退原序
  - 每轮 DR 前调用（增量成本相对 DR 可忽略）
```

```text
ALG-4.B-3  Phase2 slack-aware 代价（★单独 PR，缺省 weight=0）
输入：net, slack, base_cost
输出：adjusted_cost

  if slack_cost_weight == 0: return base_cost  // 缺省关
  
  setup_crit = clamp((-setup_slack + setup_guardband) / max(clock_period, eps), 0, 1)
  hold_crit  = clamp((-hold_slack  + hold_guardband)  / max(hold_norm, eps), 0, 1)
  crit = max(setup_crit, clamp(hold_weight * hold_crit, 0, 1))
  base_cost = history_congestion + preferred_wire + nonpreferred_wire + via + bend
  adjusted = history_congestion
           + preferred_wire
           + (1 + w_np·crit)·nonpreferred_wire
           + (1 + w_via·crit)·via
           + (1 + w_bend·crit)·bend
  同时给 net 设置 delay budget/层偏好；history_congestion 保持正、有界且不被 criticality 抵消
  return adjusted  # 加大绕行/via/非优选层相对代价，推动关键网选择低延迟路径

复杂度：O(1) per arc；总增量 O(E·crit_net_ratio)
边界：
  - weight=0 → 现状代价
  - clock_period/hold_norm≤0 → 配置错误，响亮失败；crit 始终截断到 [0,1]
  - 依赖 G7（iSTA slack 可信）
```

| 条件 | 行为 | 验收 |
|---|---|---|
| `enable_timing=0` | 现状；文档禁止称 timing-driven | — |
| `enable_timing=1` 且实现仍空 | **G14 响亮失败**（禁止假报告） | T-B0 |
| T-B1 | sort 开后 critical nets 的 route order 可观测；DEF 是否变化不是 QoR 门禁 | critical order trace + WNS/TNS/DRV/DRC |
| T-B2 | Phase2 开后关键路径 delay/WNS 改善且 DRC、非关键网完成率不退化 | 双方 PT + 分桶 route 指标 |

Know-how：KH-RT-04（关键网优先）。依赖：`27-iSTA` G7 可信 slack。

### 4.C ViolationReporter · 终态归因（FR-RT-08，G5 harness 前置）

**真实现状**：`report()` → `uploadViolation`（经 DRCEngine 重算，`ViolationReporter.cpp:181-257`）→ summary 含 within/among × type × layer；`outputJson` 需 `enable_notification`（`:503-507`）。

```text
ALG-4.C-1  violation_summary.json（★新增独立开关）
输入：final_violation_list (from DRCEngine)
输出：JSON

{
  "source": "DR_final" | "VR",
  "total_count": int,
  "by_layer_type": [
    {"layer": "M1", "type": "short", "count": int, "bboxes": [...]},
    ...
  ],
  "route_incomplete": bool  // ★G5
}

契约：
  - 总数与日志 `total_violation_num` 一致（T-C1）
  - 禁读 TA/中间 iter 当签核态（除非标明 debug）
  - 独立开关 enable_violation_json（默认建议 harness 开）

复杂度：O(V)，V=违例数；JSON 序列化可忽略
边界：
  - V=0 → 空数组，route_incomplete=false
  - DRCEngine 返回空但 DR 认为有违例 → LOG_ERROR，数据不一致
```

Know-how：KH-X-04（响亮失败 + 结构化产物）、G5（DRC=0 或诚实拒绝）。

### 4.D ECO route（FR-RT-06，Phase C）

```cpp
// RTInterface.hpp ★
struct EcoRouteResult { bool ok; int touched_nets; int residual_drc; };
EcoRouteResult routeECO(const std::vector<std::string>& net_names);
// 拆局部 → 受限冲突分量 TA/DR → 其余网 canonical geometry hash 不变（E-RT-06）
```

**真实现状**：仅 `sendNotification`。目标实现先冻结 out-of-scope shapes、fixed PG/clock NDR 与不可修层，事务内只允许白名单 net/region 产生 typed delta；提交前对非白名单几何做排序归一后的 canonical hash 校验。失败恢复 route graph、occupancy、history cost、violation cache。复用：调用现有 box DR，禁平行 ECO 引擎。Know-how：KH-RT-07。

### 4.E 前置模块（ER/PA/SA/TG/LA/SR/TA）· 保持与边界

| 模块 | 真实现状 | rv1.0 动作 | 复用姿势 |
|---|---|---|---|
| EarlyRouter | `runERT` 独立；分 stage | 文档纠偏；默认 flow 冻结 | 自建 |
| PinAccessor | `access()` | 保持 | 自建 |
| SupplyAnalyzer | `analyze()` | 保持；供拥塞提示 | 自建 |
| TopologyGenerator | Flute | 保持 | flute3 Composition |
| LayerAssigner | `assign()` | 保持；KH-RT-08 | 自建 |
| SpaceRouter | `route()` | **文档补入管线**；保持 | 自建 |
| TrackAssigner | `assign()` | 保持 | 自建 |
| DRCEngine | IDS/iDRC | 规则从 tech | Composition |
| updateTiming | 空壳 | ★真化或删开关 | Composition iSTA |

### 4.F Config / Utility · G14（FR-RT-08）

```
ALG-4.F-1  getConfigValue 关键
  if !exist(key):
    if key in required_or_strict_set: RTLOG.error; throw/abort  // ★ G14
    else: WARN + default                                       // [已有] 可选键
```

未知 `-dr_schedule_path` 等关键键：响亮失败。Know-how：KH-X-04。

### 4.G 模块状态一览

| 模块 | 现状 | rv1.0 动作 | 复用姿势 |
|---|---|---|---|
| DetailedRouter 外环 | 固定九幕 | ★plateau+调度外置 | 自建深化 |
| DetailedRouter 内核 | 成熟 A*/代价 | 保持 | 已有 |
| updateTiming | 死 | ★复活或禁伪开关 | Composition |
| VR JSON | 门控关 | ★harness 可读 | 已有加深 |
| routeECO | 无 | ★ Phase C | 自建+复用 DR |
| getConfigValue | WARN 默认 | ★严格键失败 | 已有 |
| ER…TA 管线 | 完整 | 文档+边界冻结 | 已有 |

### 4.H PR 切片

| PR | 内容 | 验收 |
|---|---|---|
| PR-RT-0 | P0：违例序列、timing A/B、VR 源、层号 grep | JSON/日志 |
| PR-RT-1 | `violation_summary.json` 终态 | T-C1 |
| PR-RT-2 | 调度外置（默认兼容） | 行为不变 |
| PR-RT-3 | plateau+策略（缺省关） | T-A1；开后 G5 |
| PR-RT-4 | 自适应 box 表 | T-A2 |
| PR-RT-5 | `updateTiming` 真化或 G14 禁伪 | 空表不再谎报 |
| PR-RT-6 | 关键网排序（缺省关） | T-B1 |
| PR-RT-7 | slack 代价 | G7 后 |
| PR-RT-8 | `fail_on_residual_drc` | G5/G14 |
| PR-RT-9 | ECO API | T-D1 |
| PR-RT-10 | route parity harness | §10 |

---

## 5. 配置 / IterParam / 多轮渐进

### 5.1 可配表（缺省=现状零回归）

| 键 | 默认 | 含义 |
|---|---|---|
| `-temp_directory_path` | `./rt_temp_directory` | 已有 |
| `-thread_number` | 128 | 已有 |
| `-enable_timing` | 0 | 已有；真化前开→应 G14 |
| `-enable_notification` | 0 | 已有 |
| `-output_inter_result` | 0 | 已有 |
| ★ `-enable_plateau` | 0 | FR-RT-01 |
| ★ `-plateau_window` | 3 | |
| ★ `-plateau_min_relative_improvement` | 0.02 | 加权严重度最小改善 |
| ★ `-hotspot_jaccard_threshold` | 0.85 | 稳定热点集合判据 |
| ★ `-dr_schedule_path` | ""（内置九组） | FR-RT-02 |
| ★ `-enable_timing_sort` | 0 | FR-RT-04 |
| ★ `-slack_cost_weight` | 0 | Phase2 |
| ★ `-fail_on_residual_drc` | 0→建议产线 1 | G5 |
| ★ `-enable_violation_json` | 0→建议 harness 1 | FR-RT-05 |

### 5.2 内置默认调度（≡ `DetailedRouter.cpp:126-134`）

| iter | size | offset | cost 倍率 | max_routed_times |
|---|---|---|---|---|
| 1–3 | 12 | 0/4/8 | 1× | 3 |
| 4–6 | 12 | 0/4/8 | 2× | 5 |
| 7–9 | 12 | 0/4/8 | 4× | 15 |

effort 包（★）：`low`=前 3；`medium`=9（现状）；`high`=9+plateau escalate。缺省 `medium` + plateau 关。

---

## 6. Cost / 指标分解

| 维 | 符号 | 记录点 | 用途 |
|---|---|---|---|
| Wire length | WL | 每 DR iter + VR | G17 |
| Via count | V | 每 iter | G17 |
| Patch count | P | 每 iter | 诊断 |
| Violation count | DRC | 每 iter + VR 终态 | **G5** |
| Violation by layer×type | DRC* | VR | 定位 |
| Prefer/non-prefer wire cost | C_w | box 内 | PathFinder（KH-RT-01） |
| Fixed/routed/violation unit | C_f/r/v | DRIterParam | 调度 A/B |
| Clock TNS/WNS/Freq | T | summary（真化后） | 报告；非 G17 金标 |
| Plateau events | Pl | ★新日志 | E-RT-01 |
| Wall time | t | Monitor per stage | **G21** |

**禁止**单一「route score」掩盖 DRC>0。

性能优化顺序固定为：先用 per-stage/per-box profile 确认 priority queue、邻接访问、DRC 查询与内存分配占比；再做连续 id/SoA 热数组、arena/pool 复用、减少重复 R-tree 查询，最后才增加线程。每项必须报告 CPU time、cache miss（可用时）、分配次数、峰值内存和 QoR hash，避免线程数上升但 barrier/allocator 争用更重。

---

## 7. 状态机 / 命令语义

```
initRT → [runERT] → runRT → [routeECO] → destroyRT
              │         │
              │         ├ PA→SA→TG→LA→SR→TA→DR→VR
              │         └ DR 内：iter 1..N / plateau* / selectBest
              └ access/supply/EGR
```

| 命令 | 成功 | 失败 rc（★目标） |
|---|---|---|
| init_rt | DM 就绪 | 缺 required 配置（G14） |
| run_ert | ER 完成 | 未验证现有 rc |
| run_rt / auto route | VR DRC=0 或允许的诚实拒绝 | residual DRC 且 fail_on；plateau give-up |
| route_eco | 触达网 DRC 清 + 他网不变 | 契约破坏 |
| destroy_rt | DEF 写出 | IO 失败 |

脏状态：失败后保留 last-best；exhibit 标 `dirty=1` / `route_incomplete=1`。

---

## 8. 跨工具 Cascade

| 信号 | 方向 | 契约 |
|---|---|---|
| 合法化 DEF / rows | iPL→iRT | 布线前就绪 |
| clock nets | iCTS→iRT | connect_type |
| PDN shapes | iPDN→iRT | fixed/-1 net |
| violation list | iRT↔iDRC | DRCEngine |
| slack / crit | iSTA→iRT | 单位一致；G7 后 |
| RC / SPEF | iRT→iRCX→iSTA | post-route |
| incr nets | iTO→iRT ECO | Phase C |
| cong hint | iRT→iPL | 未来；非本 rv 阻塞 |
| exhibit JSON | iRT→`12-evaluation` | G5/G17 |

---

## 9. 商业 Know-how 映射

| KH-ID | 推演要点 | 本工具落点 | 对照实验 | 优先级 |
|---|---|---|---|---|
| KH-RT-01 | 历史代价抬价逼疏散 | DR 代价阶梯 / ★可配 | 调度 A/B | P1 |
| KH-RT-02 | plateau→换策略 | ALG-4.A-1/2 | E-RT-01 | **P0** |
| KH-RT-03 | 自适应 box | `box_escalate` | E-RT-02 | **P0** |
| KH-RT-04 | 关键网优先 | ALG-4.B-2 | E-RT-03 | P1 |
| KH-RT-05 | SI 间距膨胀 | Phase C | 耦合扰动 | P2 |
| KH-RT-06 | 规则从 tech，禁写死层 | grep 红线 + DRCEngine | P0 扫描 | P0 |
| KH-RT-07 | ECO 局部拆线 | §4.D | E-RT-06 | P2 |
| KH-RT-08 | GR 指导 DR | ER/LA/SR 保持 | 拥塞相关 | P1 |
| KH-X-04 | 响亮失败 | §4.F / fail_on_residual | G14 | **P0** |
| KH-X-05 | 多目标分层 | 先 G5 再 G17 再 G21 | 禁颠倒 | P0 |

---

## 10. 商业对照看板 + 演进 M0–M4

### 10.1 看板（vs Innovus NanoRoute / ICC2 route）

| 指标 | iRT | 商业 | Δ | 门槛 |
|---|---|---|---|---|
| DRC 违例 | （待测） | 0 | — | **G5** |
| 线长 | | | % | ≤8%（分层） |
| via 数 | | | % | ≤8% |
| post-route WNS（PT） | | | ps/% | **G17** |
| route 墙钟 | | | × | **G21**；大设计 G20≤3× |
| plateau 触发次数 | ★ | — | — | 可机读 |
| timing enable DEF 差分 | 现应≈0 | — | — | E-RT-03 |

### 10.2 对照实验（能杀死假说）

| ID | 假说 | 方法 | 杀死条件 |
|---|---|---|---|
| E-RT-01 | 「存在隐式 plateau」 | 读 iter 违例序列 | 连平可检出且代码无分支→假说死；有分支则更新文档 |
| E-RT-02 | 局部冲突分量扩 halo 有效 | 1/2/4 halo A/B | 稳定热点严重度不降或无关区域扰动/墙钟显著增加→局部升级策略被杀 |
| E-RT-03 | timing 杠杆改善终局 | 0/1 固定 seed，记录 order + 双方 PT | 仅 DEF 改变但 WNS/TNS 无改善，或 DRC/非关键网完成率退化→策略不晋级 |
| E-RT-04 | VR 读的是最终态 | VR vs 末 DR summary | 不一致→纪律失败 |
| E-RT-05 | QoR 已打平 | vs 商业同输入 | 任一指标超 δ→G17 未过 |
| E-RT-06 | ECO 冻结他网 | 改 1 网 | 他网坐标变→契约死 |
| E-RT-07 | updateTiming 有输出 | enable=1 看 clock_timing | 空表→死实现坐实（已预期） |

### 10.3 演进 M0–M4

| 里程碑 | 技术动作 | 商业对照焦点 | 退出门禁 |
|---|---|---|---|
| **M0** | 违例序列可见；timing A/B；管线文档纠偏 | 诊断力 | 数据落盘 |
| **M1** | violation JSON + plateau（可关）+ 调度外置 | 收敛机理≈反馈控制 | G5 可诊断；零回归 |
| **M2** | 中密度 ≥3 设计 DRC=0；残留诚实拒绝 | 功能 parity | **G5** |
| **M3** | 关键网排序 + WL/via δ；updateTiming 真 | post-route WNS | **G17** 逐指标 |
| **M4** | 墙钟剖面 + ECO/NDR/SI | 性能/纵深 | **G21**；Phase C |

```text
P0 序列可见 → JSON 可诊断 → plateau 反馈（G5）→ 关键网排序 → 商业 Δ + 墙钟 → ECO/NDR/SI
```

---

## 11. Exhibit

| 档 | 产物 | 触发 |
|---|---|---|
| text | fort 表（WL/via/patch/violation/timing） | 每 iter / VR `[已有]` |
| CSV | `net_map_*` / `violation_map_*` | `output_inter_result` `[已有]` |
| JSON | notification 包；★`violation_summary.json`；★`iter_dr_series.json` | notification / 新开关 |
| plot | 可选 congestion/violation heatmap | 后置；非门禁阻塞 |

`iter_dr_series` 最小字段：`iter, vio_num, wl, via, plateau_action, box_size, wall_ms`。

---

## 12. 测试计划

| 级 | ID | 内容 | 门禁 |
|---|---|---|---|
| L0 | gtest schedule load | 默认表≡字面量九组 | 回归 |
| L0 | detectStagnation | 严重度改善/热点迁移/稳定热点/清零用例 | FR-RT-01 |
| L1 | 小设计 runRT | 管线跑通；VR 总数 | 冒烟 |
| L1 | T-A1/A2 | plateau on/off；box 12/24/48 | G5 |
| L1 | T-B1 | timing_sort 0/1 DEF | FR-RT-04 |
| L1 | T-C1 | JSON vs 日志 | FR-RT-05 |
| L1 | T-D1 | ECO 契约 | FR-RT-06 |
| L4 | E-RT-05 | vs NanoRoute/ICC2 | G17 |
| L5 | 红线 | 写死层名 grep；假 clean；未知键 | G14/KH-RT-06 |

---

## 13. 里程碑（按周，示意）

| 周 | 阶段 | 交付物 | 验收 |
|---|---|---|---|
| W0 | P0 先量 | 序列 CSV/JSON、E-RT-03/07 报告 | 数据 |
| W1 | 产物 | violation_summary + 调度外置 | T-C1；零回归 |
| W2–3 | Phase B2 收敛 | plateau + fail_on_residual | **G5** 中密度 |
| W4 | 时序 Phase1 | updateTiming 真 + sort 开关 | T-B1 |
| W5+ | G17/G21 | parity harness + 剖面 | 看板转绿 |
| 后 | Phase C | ECO/NDR/SI | T-D1 |

---

## 14. 未验证 / 负面结论

### 14.1 未验证

- 默认 TCL/Python flow 是否调用 `runERT` 或仅 `runRT`。
- 九轮结束 DRC>0 时 TCL 返回码是否非零（假 clean 风险）。
- VR `getViolationList` 与末轮 DR `uploadViolation` 集合是否逐元素一致。
- ER 与 SA/TG/LA 在生产配置下的职责边界与双算代价。
- 全量「写死层号」红线（初步未见，需 CI grep）。
- 规模上限（>1M cell）与 G20。
- NDR 语义是否已有隐藏路径。

### 14.2 负面结论（不要重走）

- **不要**为收敛重写 DetailedRouter A* 内核（E-1）。
- **不要**把 `enable_timing` 现状称为 timing-driven（实现已死）。
- **不要**读 TA 中间违例当 G5 签核态。
- **不要**用 OpenROAD 作 G17 金标替换 NanoRoute/ICC2。
- **不要**在缺省打开 plateau/撕布导致无基线回归。
- **不要**假设 `ecos` 通知 API = ECO route。

---

## 附录 A · 术语

| 术语 | 含义 |
|---|---|
| ER | EarlyRouter（`runERT`） |
| PA/SA/TG/LA/SR/TA/DR/VR | `runRT` 八段 |
| box/size | DR 窗口 GCell 尺度；现状恒 12 |
| plateau | 违例数连平且未清零 |
| 商业金标 | Innovus NanoRoute / ICC2 route |
| 假 clean | rc 成功但 DRC>0 且无 `route_incomplete` |

## 附录 B · 决策记录

| ID | 决策 | 被否 | 状态 |
|---|---|---|---|
| E-1 | plateau 外环，不重写 DR | 重写 A* | 采纳 |
| E-2 | 时序先排序后代价 | 一步改代价 | 采纳 |
| E-3 | 违例产物先行 | 先 ECO | 采纳 |
| E-4 | ECO/NDR/SI→Phase C | 与 G5 同 PR | 采纳 |
| E-5 | 新杠杆缺省关 | 默认全开冲 QoR | 采纳 |
| E-6 | G14 响亮失败（残留 DRC/死 timing 开关/未知键） | 继续 WARN | 采纳 |
| E-7 | PR 切片 §4.H | 巨型单 PR | 采纳 |

## 附录 C · Checklist（合并前）

- [ ] §1 症结均有 `file:line`
- [ ] 管线含 TG/SR；ER 在 `runERT`
- [ ] 默认调度回归 ≡ `:126-134`
- [ ] `enable_plateau` 等 ★ 默认 0
- [ ] G5/G14/G17/G21 进看板与测试
- [ ] KH-RT-01..08 有落点
- [ ] E-RT-* 能杀死对应假说
- [ ] 无「timing-driven 已具备」措辞

---

## 附录 D · 与 v1.2 对照速查

| v1.2 说法 | rv1.0 纠正 |
|---|---|
| ER→PA→SA→LA→TA→DR→VR | `runERT` 分离；`runRT`=PA→SA→**TG**→LA→**SR**→TA→DR→VR |
| timing 疑似只报告 | **`updateTiming` 空操作**；连报告都假 |
| 九组字面量 box=12 | 坐实 `:126-134`；size 字段即 box |
| 无 plateau | 坐实；`stopIteration` 仅 clean 早停 |
| ecos 仅 notification | 坐实；ECO API 仍缺 |
