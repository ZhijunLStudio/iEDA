<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 43 · AES12@65% 后 · iEDA.ai QoR 算法与工具改造路线图 · rv1.2

> 文档号：43-rv1.2　　版本：rv1.2　　日期：2026-07-31

> 触发证据：[`benchmarks/reports/aes12_65pct_detailed_comparison.md`](../benchmarks/reports/aes12_65pct_detailed_comparison.md)
> 数据根：`benchmarks/results/aes13_65pct_trueutil_20260730_1931`
> 纲领：`00-ieda-commercial-parity-master-plan-v1.1.md`；算法细则：`04-ppa-technical-review-and-optimization-rv1.md`
> 关联工具文档：`22-iPL` / `23-iCTS` / `24-iPDN-iPNP` / `25-iTO` / `26-iRT` / `27-iSTA` / `28-iRCX` / `29-iPA-iIR` / `30-iDRC` / `40-platform`
> **执行手册**：本文 **§13** = 各工具**算法级 + C++ 代码级**改造清单（Agent 实施时以此为准）
> 纪律：**文档是假说不是事实**；未实测写「未验证」；禁止用参数/利用率扫参冒充算法改造；假 clean / 无 SPEF 的 WNS 不得进门禁。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| **rv1.0** | **2026-07-30** | 基于 AES 12 项 @ 65% 真实利用率全量跑通结果，给出工具/算法/代码级改造方案、指标优先级矩阵、Wave-0～Wave-4 工作包与 ≥20% 验收口径。明确：a/b/t 利用率扫参对 DRC/WL **零改善**，后续禁止以 util/padding DOE 替代内核改造。 |
| **rv1.0+** | **2026-07-30** | 执行面绑定多 Agent 编排：[`44-aes12-qor-agent-team-orchestration.md`](44-aes12-qor-agent-team-orchestration.md) + [`agents/COORDINATION_BOARD.md`](agents/COORDINATION_BOARD.md)。 |
| **rv1.1** | **2026-07-31** | **工作重心钉死**：主交付 = `src/operation/<tool>/` 与相关 `src/` 的 **C++ 算法/内核改造**，目标 AES@65% 六项指标相对可信基线 **≥20%**。Flow/BEST_EFFORT/截断仅作贯通手段，**不算 QoR 交付**。新增 §1.5 代码落点总表与 Agent↔目录绑定。 |
| **rv1.2** | **2026-07-31** | 新增 **§13 分工具算法级 + C++ 代码级优化手册**：每个工具给出症结、算法步骤、精确文件/类/函数、缺省开关、假说/杀死实验、当前进度与 Done 包。Wave WP 表同步挂上主改路径。 |

---

## 1. 执行结论与问题边界

### 1.1 已证明（流程工程）

- **12/12** 完成 post-route DEF / GDS 与阶段报告；Floorplan 实测 CORE Usage **65.0%–65.3%**（Die/Core 由 `cell_area/target` 定边，已去掉旧版 `MIN_CORE_SIDE` 膨胀）。
- 空间证据齐全：placement density、EGR overflow、early-router 逐层 map、DRC 违例中心密度均可审计。

### 1.2 未证明（物理签核 / QoR）

| 维度 | 状态 | 证据摘要 |
|---|---|---|
| DRC | **0/12 clean** | 违例 15,637–56,737；主项 short / PRL spacing / min-area |
| Setup WNS / Fmax | **低置信** | 抽查路径 `path net delay = 0`；无 SPEF 回标；存在未约束 I/O / 缺失 slew |
| Power | **低置信** | vectorless；`switch_power ≈ 0`；无 VCD/SAIF |
| Congestion 汇总 | **接口失效** | `Average Congestion = -1`；map CSV 有效 |
| IR-drop | **0/12 未运行** | 无 iPNP/iIR 产物；报告记 `N/A`（不得填 0） |
| a/b/t 策略 | **无效杠杆** | 同 PDK 下 EGR WL / DRC 变化 **+0.0%**；主导因素不是密度而是路由/规则/代价 |

> **结论分裂**：流程完成度 ≠ 签核完成度。本路线图只服务后者：在可信测量之上，通过**工具算法与代码改造**使 Setup WNS、Fmax、Power、EGR WL、DRC、IR-drop 相对可信基线提升 **≥20%**。

### 1.3 横向基线快照（摘自对比报告）

| Design 族 | Setup WNS (ns) | Fmax (MHz) | Power (mW) | EGR WL (um) | DRC | IR-drop |
|---|---:|---:|---:|---:|---:|---|
| aes_sky130_* | −2.299 | 208.4 | 62.730 | 350,639 | 56,737 | 未运行 |
| aes_nangate45_* | +1.380* | 892.9* | 22.690* | 153,034 | 15,637 | 未运行 |
| aes_asap7_* | −1491* | 0.7* | 39.290* | 50,440 | 49,591 | 未运行 |
| aes_ics55_* | +0.845* | 604.3* | 190.800* | 191,812 | 28,133 | 未运行 |

\*标星值在 SPEF/活动率修复前**不得**作为优化 A/B 的金基线；仅作流程观测。

### 1.4 DRC 主项分布（算法靶标）

| PDK | Top violations | 算法暗示 |
|---|---|---|
| sky130 | PRL spacing ≫ min-area ≫ metal_short | 详布间距代价与 patch；协商拥塞 history |
| nangate45 | metal_short ≫ PRL ≫ nonsufficient_overlap | short 冲突分量撕布；via/overlap repair |
| asap7 | min-area ≫ short ≫ PRL | min-area repair 强化；layer/via 映射校准 |
| ics55 | min-area ≫ short ≫ PRL | 同 asap7 侧重 min-area + short |

### 1.5 工作重心（rv1.1 强制）— `src/operation` C++ 算法

用户目标表述（执行约束）：

1. **主战场**：`/home/lxq/AiEDA/iEDA.ai/src/operation/<iRT|iDRC|iPL|iTO|iCTS|iRCX|iSTA|iPA|iPNP|iPDN|iIR|…>/` 内的算法与 C++ 实现；必要时连带 `src/platform/`、`src/evaluation/`、`src/database/` 契约层。
2. **主目标**：在 **AES 12 项 @ 实测 65% core util** 下，六项指标相对 Wave-0 可信基线各自改善 **≥20%**（口径见 §6；DRC 对齐更激进 clean 路径）。
3. **非主战场（可辅助、不可冒充交付）**：`benchmarks/flows` 超参、`IEDA_RT_BEST_EFFORT` / `MAX_BOXES` / 软跳过 iTO、利用率/padding DOE、只改 Tcl/JSON 配置。

#### Agent ↔ 主改目录（唯一认领边界）

| Agent | 主改目录（C++） | 主 WP | ≥20% 挂钩指标 |
|---|---|---|---|
| A2 rcx | `src/operation/iRCX/` | WP-RCX-01 | （真值）net delay / SPEF |
| A3 sta | `src/operation/iSTA/` | WP-STA-01/02 | WNS / Fmax 可信 |
| A4 pa | `src/operation/iPA/` | WP-PA-01 | Power 真值 |
| A5 rt | `src/operation/iRT/` | WP-RT-01（+ MAP） | **DRC / EGR WL** |
| A6 drc | `src/operation/iDRC/` | WP-DRC-01 | DRC 闭环反馈 |
| A7 pl | `src/operation/iPL/` | WP-PL-01 | **EGR WL / 下游 DRC** |
| A8 tocts | `src/operation/iTO/` + `iCTS/` | WP-TO-01 / WP-CTS-01 | **WNS / Fmax / Power** |
| A9 pnp | `src/operation/iPNP/` + `iPDN/` | WP-PNP-00/01 | IR 前置 |
| A10 ir | `src/operation/iIR/` | WP-IR-01 | **IR-drop** |
| A11 plat | `src/platform/`（MoveTxn/DirtySet/…） | WP-PLT-01 | 增量契约 |
| A12 bench | `benchmarks/`（跑数，不改算法冒充） | 全 Wave 复跑 | 可复现证据 |

**合入检查（每个算法 PR）**：diff 主体必须在上表目录；若 >30% 行落在 flow/配置，A1 **REJECT** 并要求拆成「算法 PR」+「可选 harness PR」。

---

## 2. 目标与非目标

### 2.1 目标

1. 建立 **SPEF-backed STA / activity-backed Power / PDN-backed IR / 有效 congestion 汇总** 的可信测量面。
2. 相对 Wave-0 可信基线，六项指标各自改善 **≥20%**（DRC 实际应对齐更激进的 clean 路径，见 §6）。
3. **改造对象强制为 iEDA.ai `src/operation`（及必要 platform）内的 C++ 算法与内核**——见 §1.5；flow 超参扫参 / BEST_EFFORT 截断 **不算** 本目标交付。
4. 给出 **工具 × 指标优先级矩阵**，作为后续 Agent / 人力排期唯一顺序源。
5. 每个算法 WP 交付三联证据：`code diff（src/operation）` + `对照实验` + `AES@65% artifact delta`。

### 2.2 非目标（本阶段明确不做）

- 以 utilization / padding / `IEDA_RT_MAX_ITERATIONS` / `MAX_BOXES` / BEST_EFFORT 单点调参作为主交付（可作 A/B 对照，不可替代算法 WP）。
- 宣称与 Innovus/ICC2 商业 parity（需独立金标 harness；见 `00` G17）。
- 从零重写完整逻辑综合器、全规则 signoff DRC、动态 IR（后置）。
- 用 AI 直接改 DEF 而无 `MoveTxn` + 精确 oracle 否决。
- 只改 `benchmarks/flows` / Tcl / JSON 配置来「刷」报告数字。

### 2.3 红线

| 红线 | 说明 |
|---|---|
| 假 success | DRC residual > 0 仍 rc=0 / GDS「成功」→ 门禁 FAIL |
| 假时序 | 无 SPEF 的 WNS/Fmax 进 QoR 门禁 → FAIL |
| 假功耗 | `switch_power=0` 且无活动率来源标签 → 不得用于 Power/IR 决策 |
| 假 IR | 无 PDN/求解结果填 0 → 禁止；必须 `N/A` 或响亮失败 |
| 质量优先 | 加速/并行 PR 若使 DRC/WNS 回归 → 不合入（对齐 `42` KH-X-05） |

---

## 3. 工具 × 指标优先级矩阵

评分：`5`=主杠杆，`4`=强相关，`3`=中等，`2`=间接，`1`=弱，`0`=无关。
**推进顺序 = 列内高分优先 + 行间依赖（真值工具先于优化工具）。**

| 工具 | Setup WNS | Fmax | Power | EGR WL | DRC | IR-drop | **推进优先级** |
|---|:-:|:-:|:-:|:-:|:-:|:-:|---|
| **iRCX** | 5 | 5 | 3 | 1 | 1 | 2 | **P0-真值** |
| **iSTA** | 5 | 5 | 2 | 1 | 0 | 1 | **P0-真值** |
| **iRT** | 4 | 4 | 3 | 5 | 5 | 2 | **P0-QoR** |
| **iDRC** | 1 | 1 | 0 | 1 | 5 | 0 | **P0-签核闭环** |
| **iPL** | 4 | 4 | 3 | 5 | 4 | 2 | **P1** |
| **iTO** | 5 | 5 | 5 | 2 | 2 | 1 | **P1** |
| **iCTS** | 4 | 4 | 4 | 2 | 1 | 1 | **P1** |
| **iPNP / iPDN** | 2 | 2 | 2 | 1 | 2 | 5 | **P1-IR** |
| **iIR** | 2 | 2 | 1 | 0 | 0 | 5 | **P1-IR** |
| **iPA** | 1 | 1 | 5 | 0 | 0 | 4 | **P1-功耗真值** |
| **iFP** | 2 | 2 | 1 | 3 | 2 | 3 | **P2** |
| **iNO** | 3 | 3 | 2 | 2 | 1 | 0 | **P2** |
| **iECO / platform** | 3 | 3 | 2 | 2 | 3 | 2 | **贯穿** |

### 3.1 按指标的主导工具链

| 指标 | 主导顺序 | 说明 |
|---|---|---|
| **DRC** | iRT → iDRC → iPL | 外环收敛 + 规则反馈 + 上游可布线性 |
| **EGR WL** | iPL → iRT (ER/GR) | 拥塞驱动布局 + 协商拥塞粗布 |
| **Setup WNS / Fmax** | iRCX+iSTA → iTO → iCTS → iPL → iRT | 先真值，再 opt / CTS / timing weight / timing cost |
| **Power** | iPA → iTO → iCTS → iPL | 活动率 → VT/resize → clock buffer → power weight |
| **IR-drop** | iPNP → iIR → iPA → (可选 iTO) | PDN → 求解 → 电流源 → IR-aware sizing |

---

## 4. 根因 → 算法改造映射

| 观测根因 | 错误应对（禁止） | 正确改造（本路线图） |
|---|---|---|
| `net delay = 0` | 调时钟周期 / 关路径 | iRCX SPEF 强制闭环 + iSTA 读 SPEF |
| DRC 数万且 a/b/t 不变 | 再扫 util/padding | iRT plateau 外环 + 规则代价 + repair；iDRC 结构化反馈 |
| `IEDA_RT_MAX_ITERATIONS=1` | 只把迭代调到 5 | 外环自适应策略（box/history/rip-up）；迭代只是预算 |
| Congestion = −1 | 忽略 map | 修复汇总 API；用 EGR/early-router CSV 作真源 |
| Power 不可用 | 用 leakage 冒充 total | iPA 活动率传播 + 分量报告 |
| IR 未运行 | 填 0 | iPNP 进 flow + iIR `Gv=i` |
| iRT `updateTiming` 死实现 | 事后 iTO 硬扛 | 复活 timing cost / critical net 调度 |
| DR 九幕硬编码 | 手工改字面量 | `DRIterParam` 外置 + plateau→escalate |

---

## 5. 分波次工作包（算法 / 代码）

### 5.0 总览

```text
Wave-0  测量真值     iRCX / iSTA / iPA / congestion API / iPNP-in-flow
Wave-1  DRC + WL     iRT 外环 / iDRC 反馈 / iPL 拥塞驱动
Wave-2  WNS + Power  iTO MoveTxn / iCTS buffer DP / iSTA 增量·PBA
Wave-3  IR-drop      iPNP sensitivity / iIR 求解闭环
Wave-4  贯穿契约     DesignState / DirtySet / MoveTxn / ArtifactIndex
```

依赖约束：**Wave-2 的 WNS/Power 门禁依赖 Wave-0**；**Wave-3 依赖 Wave-0 的 PDN+活动率**；Wave-1 可与 Wave-0 后半并行，但 DRC clean 门禁不依赖 SPEF。

---

### Wave-0（约 1–2 周）：测量真值

> 不做完 Wave-0，不得宣称任何「WNS/Power/IR 提升 20%」。

#### WP-RCX-01 · SPEF 强制闭环

| 项 | 内容 |
|---|---|
| 落点 | `src/operation/iRCX/`；flow post-route 强制 extract→SPEF→iSTA |
| **C++ 主文件** | `flow/extraction/Extraction.*`；`module/calculate/capacitance/CapacitanceCalc.*`；`module/calculate/resistance/ResistanceCalc.*`；`database/config/RCXConfig.hh` |
| 算法 | 线段 tile + R-tree 邻居；pattern key `(layer,width,space,thickness,density,neighbor_count,via_stack)`；dirty net 更新含耦合 halo；界外返回 `out_of_domain`，禁止无界外推 |
| 改造要点 | 禁止静默跳过 RCX；SPEF 缺失 → stage 非零退出；ITF+captab 缺失时响亮 `BLOCKED`（勿假 SPEF） |
| 验收 | 关键路径 `net delay > 0`；与金标（若有）可报 MAE/bias；AES12 子集 100% SPEF-backed |
| 对照实验 | E-RCX-01：关/开 SPEF，同一 DEF，路径 net delay 分布必须分离 |
| 状态 | 部分阻塞历史见 `IRCX_SPEF_UNBLOCK_PLAN.md` / `CRITICAL_BLOCKER_IRCX_ITF.md`；以当前二进制实测为准 |
| **细则** | §13.2 |

#### WP-STA-01 · 约束完备 + 增量失效

| 项 | 内容 |
|---|---|
| 落点 | `src/operation/iSTA/`；SDC 覆盖检查 |
| **C++ 主文件** | `module/sta/Sta.*`；`StaSlewPropagation.*`；`module/delay/ElmoreDelayCalc.*`；`api/TimingEngine.*` |
| 算法 | SCC/loop 检查 + levelization；按 level 并行；`on commit` 失效 dirty cone（前向 arrival + 后向 required）；锥外不变为测试不变量 |
| 改造要点 | 清零 unconstrained endpoint；补齐 input delay / output delay / uncertainty / driving cell；缺失 slew 响亮报告；`read_spef` 失败非静默 |
| 验收 | unconstrained=0；增量 vs full 在随机 ECO 注入集一致 |
| 对照 | E-STA-01：故意漏约束 → 必须非零退出或 coverage FAIL |
| **细则** | §13.3 |

#### WP-PA-01 · 活动率传播

| 项 | 内容 |
|---|---|
| 落点 | `src/operation/iPA/` |
| **C++ 主文件** | `api/Power.*` / `PowerEngine.*`；`ops/calc_power/PwrCalc*.*`；`ops/propagate_toggle_sp/*`；`core/PwrGraph.*` |
| 算法 | 活动源优先级：VCD/FSDB → SAIF → **标注来源的** vectorless；传播信号概率与 toggle correlation；报告 clock / internal / switching / leakage 与覆盖率 |
| 验收 | `switch_power > 0` + `activity_source` 标签；无活动源不得冒充实测 |
| 对照 | E-PA-01：无 VCD 时报告必须标 `vectorless` 且禁止进 IR 决策门禁（除非显式 override） |
| **细则** | §13.4 |

#### WP-IRT-MAP-01 · 拥塞汇总修复

| 项 | 内容 |
|---|---|
| 落点 | iRT early_router / EGR report API；evaluation JSON |
| **C++ 主文件** | `iRT/.../early_router/EarlyRouter.*`；evaluation congestion summary API；禁止写死 `-1` |
| 算法 | 由已有 CSV map 聚合 avg / top-1% / top-5% overflow 与热点 bbox；消灭 `-1` sentinel |
| 验收 | JSON 与 `place_egr_*` / `overflow_map_planar` 数值一致；门禁可读 |
| 对照 | E-MAP-01：全零 map 不得被拉伸成伪热点；`-1` 样本必须被校验器拒绝 |

#### WP-PNP-00 · PDN 进入主 flow

| 项 | 内容 |
|---|---|
| 落点 | `iPNP` / `iPDN`；aes13 flow stage |
| **C++ 主文件** | `iPDN/.../pdn_plan/pdn_plan.*`；`pdn_via/pdn_via.*`；`iPNP/.../synthesis/NetworkSynthesis.*` |
| 算法 | 生成真实 rings/straps/via；定义电源 bump/pad/source；金属占位写入 supply map |
| 验收 | 每设计有 PDN DEF；可被 iIR 读取；无 PDN → IR stage `unsupported` 非静默跳过 |
| 状态 | 当前 AES12：**0/12 IR**；本 WP 为 Wave-3 前置 |
| **细则** | §13.9–§13.10 |

---

### Wave-1（约 2–6 周）：DRC ↓≥50%（目标路径 clean）+ EGR WL ↓≥20%

#### WP-RT-01 · DR 外环反馈控制器（头号算法改造）

**症结（已有代码审计，见 `26-iRT.md`）**：DetailedRouter 内核为 PathFinder-like 历史代价 + A* + patch + min-area（成熟）；外环为固定九幕字面量调度，`stopIteration` 仅 clean 早停，**无 plateau / 无策略升级**；`updateTiming` 整段死实现。

**目标算法**：

```text
state = {vio_count, weighted_severity, hotspot_set, completeness, wl, via}
while not clean and within_budget:
  route_with(current_strategy)
  if plateau(state, window):                 # 不只看 count 相等
    escalate(conflict_connected_components): # 只升级连通分量
      enlarge_box / increase_history_cost /
      selective_ripup / raise_via_or_spacing_penalty
  keep_best_feasible_snapshot()
if residual_drc > 0:
  fail_loudly(rc != 0)                       # 禁止假 success
```

| 子项 | 建议落点 | 内容 |
|---|---|---|
| plateau 状态向量 | `DetailedRouter.cpp` `buildConvergenceState` / `stopIteration` | 完备率、加权严重度、热点集合 Jaccard、WL/via 联合判停滞（`DRConvergence.hpp`） |
| 策略表外置 | `DRIterParam` / `Config.hpp` / `RTInterface::wrapConfig` | 去掉九组 `emplace_back` 字面量；box size/offset、history 倍率、max_routed_times 可配且可 escalate |
| 冲突分量撕布 | `DRConflictEscalate.hpp` + `applyComponentEscalateOnPlateau` | violation 连通分量；扩 halo / 权重 boost **仅对该分量**（禁止只靠全局 box×2） |
| 规则感知代价 | `DRRuleAwareCost.hpp` + `DRNode::getViolationCost` | `drc_risk` 纳入 PRL / min-area / short；A* 热路径缓存 config，禁止 `getenv` |
| repair 强化 | `updateTaskSchedule` / `patchDRTask` / min-area 候选 | sky130→PRL+minarea；nangate→short；`prlShortRepairPriority` |
| 时序接线 | `RTInterface::updateTiming`（当前死实现） | `cost += timing_weight(net)*delay`；critical net 优先调度 |

| 假说 | 可杀实验 | 状态（2026-07-31） |
|---|---|---|
| H1：仅规则加权即可降 DRC | E-RT-01 A/B-1 | **未支持**（Δ≈0%，`wp_rt01_ab_20260731_0952`） |
| H3：冲突分量 escalate + PRL/short | E-RT-03 A/B-3 | **跑中**（`wp_rt01b_ab3_*`） |
| H2：墙钟大头在 `routeDRBox` | E-RT-02 剖面 | 未做 |

**预期**：DRC ↓50–90%（向 per-PDK 至少 1 个 clean 迈进）；连带 routed/EGR WL ↓15–25%。
**细则**：**§13.1**（含已合入开关表）。

#### WP-DRC-01 · in-design 快速规则 + 结构化反馈

| 项 | 内容 |
|---|---|
| 落点 | `src/operation/iDRC/` |
| **C++ 主文件** | `interface/DRCInterface.*`（`getViolationList` / `outputCVioJson`）；`rule_validator/RuleValidator.*`；`rv_design_rule/{MetalShort,ParallelRunLengthSpacing,MinimumArea}.*` |
| 算法 | 规则编译为按层查询计划；width/spacing：sweep-line + R-tree；enclosure/cut：邻域查询；层次 `(cell_hash, orient, deck_hash)` 缓存 |
| 契约 | **C-VIO** `(type, layer, bbox, net_ids, severity)` + `checked/skipped/unsupported`；缺省 OFF 写出 `c_vio.json` |
| 验收 | in-design 子集（short/spacing/min-area/enclosure）全覆盖；假 clean 不可能 |
| 对照 | E-DRC-01：注入已知 short → 必检出且反馈 JSON 非空 |
| **细则** | §13.5 |

#### WP-PL-01 · 可布线布局（EGR WL + 下游 DRC）

| 项 | 内容 |
|---|---|
| 落点 | `src/operation/iPL/` |
| **C++ 主文件** | `.../electrostatic_placer/NesterovPlace.{hh,cc}`（`inflateInstancesByRouteUtil`）；`BinGrid` / `GridManager`；`legalizer/Legalizer.*`；`config/pl_default_config.json` |
| 算法 | （1）B2B/QP 或多层 coarsening 稳定初值，禁止随机初值为生产默认；（2）保留 WA/LSE + electrostatic density + Nesterov；（3）RUDY/pin-density → 快速 GR 校准 → **局部 cell inflation**（`density_scale` 上限+回退）；（4）timing/power weight：slack/criticality 平滑，单网封顶；（5）合法化：Abacus + 局部 swap/reorder；iTO/iCTS 后只 LG dirty halo |
| 验收 | 同 netlist 下 EGR WL ↓≥20% **或** overflow 面积 ↓≥20%；合法化零重叠 |
| 对照 | E-PL-01：inflation off/on；EGR overflow map 热点必须收缩，否则杀「拥塞反馈有效」假说 |
| **细则** | §13.6 |

---

### Wave-2（约 6–10 周）：WNS/Fmax ↑≥20%，Power ↓≥20%

> 依赖 Wave-0 SPEF + 活动率。基线必须重新跑出「可信 post-route」后再 A/B。

#### WP-TO-01 · 候选生成 + MoveTxn 精确否决

| 项 | 内容 |
|---|---|
| 落点 | `src/operation/iTO/` + platform `MoveTxn` |
| **C++ 主文件** | `fix_setup/SetupOptimizer.*`；`fix_hold/HoldOptimizer.*`；`fix_drv/ViolationOptimizer.*`；`solver/buffer/vg/VGBuffer.*`；`config/ToConfig.h`；`src/platform/design_state/MoveTxn.*` |
| 算法 | 见下伪代码 |
| 验收 | 相对 SPEF-backed 基线：WNS 绝对改善 ≥20% 或 TNS 同量级；Power（同 activity）↓≥20%；每次拒绝可 rollback 且 hash 一致 |
| 对照 | E-TO-01：关闭精确 STA 否决只保留局部估计 → 应出现 hold/DRV 回归（证明否决必要） |
| **细则** | §13.7 |

```text
score(move) = estimated_ΔTNS
            - λa·Δarea - λp·Δpower - λc·congestion_risk
            - λh·hold_risk - λd·DRV_risk

repeat until budget / no-improve:
  candidates = resize + VT-swap + buffer(van Ginneken DP) + pin-swap
  rank by score; build move conflict graph; take independent batch
  apply batch in MoveTxn
  incr legalize → incr RC → incr STA(setup+hold) → local DRC
  accept iff hard constraints hold AND lexicographic objective improves
  else rollback; update tabu
固定顺序: DRV → setup → hold → setup recovery
每 N 批: full RC/STA oracle；漂移则禁用增量路径
```

#### WP-CTS-01 · 拓扑 / buffer DP / useful skew

| 阶段 | 算法 | 约束 | C++ 落点 |
|---|---|---|---|
| sink clustering | bounded-diameter / k-means 变体 | max fanout/cap、blockage、clock gate | `flow/synthesis/Synthesis.*` |
| topology | DME/BST 或 FLUTE 引导 buffered tree | slew/cap、buffer sites、NDR | `module/topology/TopologyGen.*`；`routing/bound_skew_tree/BSTRouter.*` |
| buffer DP | `(cap,delay,power,area)` Pareto + 支配剪枝 | 库/角点合法 | `flow/optimization/Optimization.*` |
| useful skew | LP / 差分约束预算 | 同时管 setup/hold 与 skew range | `Optimization.*` + Config `skew_bound` |
| commit | MoveTxn + incr LG + incr RC/STA | 任一步失败整批回滚 | platform `MoveTxn` |

| 验收 | insertion delay / skew / clock WL / buffer area 联合不劣；Fmax 相对可信基线 ↑≥20%（可与 iTO 叠加统计） |
|---|---|
| 对照 | E-CTS-01：关掉 useful skew 仅平衡 skew → setup 应变差或不变（验证 skew 杠杆） |
| **细则** | §13.8 |

#### WP-STA-02 · 增量 STA + top-N PBA（支撑高频调用）

| 项 | 内容 |
|---|---|
| **C++ 主文件** | `module/sta/Sta.*`（dirty cone）；PBA beam 路径枚举（若缺则新建 `StaPathBased` 旁路） |
| 算法 | dirty cone 增量，目标 `O(S_dirty·(V_d+E_d))`；GBA 筛 endpoint → PBA beam/k-shortest；超预算标 `pba_exhausted`，禁止假装精确 |
| 验收 | iTO 全流程中 STA 墙钟占比可控；增量 vs full 一致；PBA 关键 FN 可审计 |
| 说明 | 本 WP 不直接「涨 Fmax」，但没有它 Wave-2 墙钟不可接受 |
| **细则** | §13.3 |

---

### Wave-3（约 8–12 周）：IR-drop 从无到可测并可降 ≥20%

#### WP-PNP-01 · PDN 条带 / via 敏感度优化

| 项 | 内容 |
|---|---|
| **C++ 主文件** | `iPNP/.../optimizer/PdnOptimizer.*`；`SimulatedAnnealing.*`；`iPDN/.../pdn_plan/*` |
| 算法 | 多目标：worst IR、EM current density、routing blockage；**禁止**全芯片平均功耗反推统一线宽；PDN 金属占位反馈 iRT supply |
| 验收 | 相对首版静态 PDN，worst IR ↓≥20% 或超阈面积 ↓≥20%（需 WP-IR-01） |
| **细则** | §13.9 |

#### WP-IR-01 · 静态 IR 求解器闭环

```text
从网表/版图提取 conductance G
解 Gv = i（PCG + Jacobi / IC / AMG 预条件，按 profile 选）
报告: worst/avg IR、超阈值面积、relative/absolute residual、热图
拓扑不变 → 复用预条件器 + 热启动；定期 full oracle
浮空节点：连通性检查失败 → 响亮失败
```

| 电流源 | 来自 iPA（实例电流）；无活动率则 IR 仅标 `proxy` |
|---|---|
| **C++ 主文件** | `iIR/.../ir-solver/IRSolver.*`（`IRCGSolver`/`IRLUSolver`）；`module/power-netlist/PGNetlist.*`；`api/iIR.*` |
| 动态 IR | **后置**：静态 PG + 活动覆盖 + DC 相关性未绿前不立项 |
| 对照 | E-IR-01：故意断 strap → worst IR 必须上升且热图定位正确 |
| **细则** | §13.10 |

---

### Wave-4（贯穿全周期）：platform 增量契约

| 组件 | 作用 | 没有它的后果 |
|---|---|---|
| `DesignState` + `DirtySet` | 统一标记 cell/net/constraint 变更 | 各工具全量重建，结果不一致 |
| `MoveTxn` | iTO/iCTS/iECO 原子提交/回滚 | 假 apply、不可复现 |
| `ArtifactIndex` | DEF/SPEF/report sha256 | 假 success、不可追溯 |
| FlowScheduler 失败语义 | DRC residual / 缺 SPEF → 非零退出 | 对比报告继续「success 但签核红」 |

本波次与 `04` / `40-platform` 对齐；每个优化 WP 合入时必须声明是否遵守 DirtySet/MoveTxn。

---

## 6. 「≥20%」量化验收口径

在 **Wave-0 可信基线**（建议 daily：`aes_sky130_*` + `aes_nangate45_*`）上定义：

| 指标 | 基线定义 | ≥20% 含义 | 主导 WP | 硬约束 |
|---|---|---|---|---|
| DRC | 同 DEF、同 rule deck 的违例数 | count ↓≥20%；Wave-1 对齐目标 **↓≥50%**，并冲 per-PDK ≥1 clean | WP-RT-01 / WP-DRC-01 | 不得用 waiver 充 clean |
| EGR WL | placement 后 EGR 报告总线长 | WL ↓≥20% **或** overflow 面积 ↓≥20% | WP-PL-01 / WP-RT-01 | DRC 不得显著恶化 |
| Setup WNS | SPEF-backed；负 slack 用绝对量 | \|WNS\| 改善 ≥20%，或转正且 TNS 改善 ≥20% | WP-TO-01 / WP-CTS-01 | 无 SPEF → 不计 |
| Fmax | 同约束语义下由 period/WNS 推导 | Fmax ↑≥20% | WP-TO-01 / WP-CTS-01 / WP-STA-02 | 约束覆盖必须完整 |
| Power | 同 `activity_source` 的 total | total ↓≥20%（分项可审计） | WP-TO-01 / WP-PA-01 / WP-CTS-01 | switch=0 → 不计 |
| IR-drop | 首版静态 worst IR | worst ↓≥20% | WP-PNP-01 / WP-IR-01 | 无 PDN → 不计 |

**联合门禁**：单一指标达标但 DRC 上升或假 clean → 整体 FAIL（对齐 `00` G7/G17 精神）。

---

## 7. 推荐推进顺序与人力切分

### 7.1 时间线（逻辑序，可部分并行）

```text
T0  WP-RCX-01 + WP-STA-01 + WP-PA-01 + WP-IRT-MAP-01 + WP-PNP-00
T1  WP-RT-01 + WP-DRC-01 + WP-PL-01          ← DRC / WL 最大收益
T2  WP-TO-01 + WP-CTS-01 + WP-STA-02         ← WNS / Fmax / Power
T3  WP-PNP-01 + WP-IR-01                    ← IR
T*  Wave-4 契约贯穿于每一合入
```

### 7.2 建议团队切分

| 组 | 负责 WP | 产出 |
|---|---|---|
| 签核真值组 | RCX / STA / PA / DRC / MAP | 可信报告面 + 门禁变绿前置 |
| 实现链组 | RT / PL / TO / CTS | DRC/WL/WNS/Power 数字改善 |
| 电源组 | PNP / IR | IR 从 N/A → 可测可降 |
| 平台组 | MoveTxn / DirtySet / ArtifactIndex / FlowScheduler | 跨工具一致性与失败语义 |

### 7.3 Agent 认领协议（对齐 `00`）

每个 WP 认领必须包含：

1. **单一主假说**（可被对照实验杀死）
2. **改动文件清单**（禁止无关大扫除）
3. **A/B 设计**（同输入 manifest、同 binary identity）
4. **门禁绑定**（上表 §6 对应行）
5. **缺省关闭新杠杆 → 零回归**

算法收益不成立时关闭或删除 WP，**禁止**扩大参数搜索掩盖失败。

---

## 8. 与现有文档 / 报告的关系

| 文档 | 关系 |
|---|---|
| `aes12_65pct_detailed_comparison.md` §9 | 报告内 P0–P3 偏测量与流程；**本文将其升级为算法/代码 WP，并冻结优先级矩阵** |
| `04-ppa-technical-review-and-optimization-rv1.md` | 跨工具算法与 DirtySet/MoveTxn 的权威细则；本文是 AES12@65% 驱动的**排期实例化** |
| `26-iRT.md` | WP-RT-01 的逐 kernel 依据；外环症结 S1 / 时序死线 S3；与 **§13.1** 互链 |
| `22/23/25/27/28/29/30` | 各工具 LLD；**算法/C++ 执行清单以本文 §13 为准** |
| `IRCX_SPEF_UNBLOCK_PLAN.md` | WP-RCX-01 的历史阻塞与解锁路径 |
| `improvement_experiment_plan.md` / `experiment_plan_WP-iRT-01-02.md` | 已有 iRT 实验应并入 WP-RT-01，避免平行重复 |

---

## 9. 里程碑退出条件

| 里程碑 | 退出条件（机器可判定） |
|---|---|
| **M-T0** | AES12 子集：SPEF-backed STA=100%；unconstrained=0；activity 有来源标签；congestion 无 −1；PDN 产物存在 |
| **M-T1** | 相对 T0 后 DRC 基线 ↓≥50%；至少 1 个 PDK 出现 DRC clean **或** 文档化 waiver；EGR WL 或 overflow ↓≥20% |
| **M-T2** | SPEF-backed WNS/Fmax 相对 T0 后基线改善 ≥20%；Power ↓≥20%；无 DRC 回归 |
| **M-T3** | 12/12 有 worst/avg IR + 热图；worst IR 相对首版静态基线 ↓≥20% |
| **M-契约** | 随机 ECO 注入：MoveTxn rollback hash 一致；缺 SPEF/有 residual DRC → 非零退出 |

---

## 10. 未验证 / 负面结论 / 不要重走

| 项 | 判定 |
|---|---|
| a/b/t 利用率扫参改善 DRC/WL | **已证伪**（本轮 +0.0%）；不要再作为主优化手段 |
| 正 slack（nangate/ics55）表示时序达标 | **未验证**（net delay=0）；禁止当金标 |
| 仅增加 `IEDA_RT_MAX_ITERATIONS` 即可 DRC clean | **未验证**；可作为 E-RT-01 对照，不能替代外环改造 |
| ASAP7 EGR overflow 全零 ⇒ 可布线良好 | **未验证**；与高 DRC 并存，说明 map/规则/代价可能失配 |
| 动态 IR / 全规则 Calibre 对拍 / 商业 parity | **未验证**；不在本 rv1.0 退出条件内 |
| AI 直接预测 rip-up 集合无 oracle | **不要重走**；必须 MoveTxn + 精确评估（见 `04` §6） |

---

## 11. 一句话结论

AES12@65% 证明 **flow 可贯通**；QoR 仍受 **DRC 外环原始、RC/STA/Power/IR 测量断裂** 限制。
后续 iEDA.ai 推进顺序冻结为：

1. **真值**：iRCX → iSTA → iPA → iPNP
2. **可布线**：iRT 外环 + iDRC 反馈 + iPL 拥塞驱动
3. **PPA**：iTO + iCTS（+ 增量 iSTA）
4. **电源完整性**：iIR + PDN sensitivity

全部以**算法与代码改造**交付，以 §3 矩阵、§6 门禁与 **§13 分工具手册**验收；参数扫参只作杀假说的对照，不作主交付。

---

## 12. 产物与索引

| 产物 | 路径 |
|---|---|
| 本路线图 | `docs/ai/43-aes12-65pct-qor-optimization-roadmap.md` |
| **多 Agent 编排（执行面）** | [`44-aes12-qor-agent-team-orchestration.md`](44-aes12-qor-agent-team-orchestration.md) |
| **协调板** | [`agents/COORDINATION_BOARD.md`](agents/COORDINATION_BOARD.md) |
| **Agent 启动提示词** | [`agents/prompts/`](agents/prompts/) |
| 触发对比报告 | `benchmarks/reports/aes12_65pct_detailed_comparison.md` |
| 机器可读对比 | `benchmarks/reports/aes12_65pct_detailed_comparison.json` |
| 技术评审总纲 | `docs/ai/04-ppa-technical-review-and-optimization-rv1.md` |
| 商业对标主纲领 | `docs/ai/00-ieda-commercial-parity-master-plan-v1.1.md` |

---

## 13. 分工具算法级 + C++ 代码级优化手册（rv1.2）

> **用法**：每个 Agent 开工前读本工具小节；PR 必须点名「改了哪几个函数」；缺省关闭新杠杆。
> 路径均相对仓库根 `iEDA.ai/`。
> 状态标签：2026-07-31。

### 13.0 总表（一眼定位）

| 工具 | Agent | 主指标 | 头号算法动作 | 主 C++ 入口 | 当前状态 |
|---|---|---|---|---|---|
| **iRT** | A5 | DRC / WL | plateau→冲突分量 escalate + 规则代价 + repair | `DetailedRouter.cpp` | 01a/01b 杠杆已合入；A/B-3 跑中 |
| **iDRC** | A6 | DRC 闭环 | C-VIO JSON + in-design 规则查询 | `DRCInterface.cpp` | C-VIO 写出缺省 OFF 已合入 |
| **iPL** | A7 | EGR WL / DRC | RUDY inflation + density_scale 回退 | `NesterovPlace.cc` | congestion 缺省 OFF + 回退已合入 |
| **iTO** | A8 | WNS / Power | 候选批 + MoveTxn 精确否决 | `SetupOptimizer` / `VGBuffer` | Wave-2；依赖 SPEF |
| **iCTS** | A8 | Fmax / Power | BST + buffer DP + useful skew | `BSTRouter` / `Optimization` | Wave-2 |
| **iRCX** | A2 | 真值 | SPEF 强制 + pattern RC | `Extraction` / `CapacitanceCalc` | **BLOCKED**（缺 ITF+captab） |
| **iSTA** | A3 | 真值 / 增量 | 约束完备 + dirty cone + PBA | `Sta` / `TimingEngine` | Wave-0/2 |
| **iPA** | A4 | Power 真值 | 活动率传播 + 分项报告 | `Power` / `PwrPropagateToggleSP` | Wave-0 |
| **iPNP/iPDN** | A9 | IR 前置 | 真实 PDN + SA 敏感度 | `PdnPlan` / `PdnOptimizer` | Wave-0/3 |
| **iIR** | A10 | IR-drop | `Gv=i` + 热图 + residual | `IRSolver` | Wave-3 |
| **platform** | A11 | 一致性 | MoveTxn / DirtySet | `MoveTxn.cpp` / `DirtySet.cpp` | 贯穿 |

---

### 13.1 iRT（A5）— DRC / EGR WL 主杠杆

#### 症结
1. **内核成熟、外环原始**：A* + PathFinder-like 历史代价在；固定九幕 `DRIterParam` + 仅 clean 早停（详见 `26-iRT.md` S1）。
2. AES@65%：**数万 DRC**（sky130≈56k；nangate≈15k），主项 PRL / short / min-area。
3. `RTInterface::updateTiming` **死实现** → 无 timing-driven 排序/代价。

#### 算法方案（按实施序）

```text
# Phase A — 外环反馈（进行中）
1. plateau(state): 完备率 + 加权 severity + hotspot Jaccard
2. escalate(component): 只对最高 severity 连通分量
   - mild history/violation scale（禁止「只全局 box×2」）
   - 分量 net 的 violation weight boost
3. repair priority: metal_short > PRL > min-area > other
4. rule-aware A* history cost（封顶 max_history_scale）

# Phase B — 时序接线（Wave-1 后半 / Wave-2）
5. 复活 updateTiming：criticality 归一化 → wire/via/violation cost
6. critical net 优先进 updateTaskSchedule

# Phase C — 数据/并行（性能）
7. box 冲突图并行提交；热路径零 getenv；剖面 routeDRBox
```

#### C++ 落点（必须改这些）

| 优先级 | 文件 | 类/函数 | 改什么 |
|---|---|---|---|
| P0 | `src/operation/iRT/source/module/detailed_router/DetailedRouter.cpp` | `routeDRModel` / `updateTaskSchedule` / `addRouteViolationToGraph` / `applyComponentEscalateOnPlateau` | 外环 escalate + 调度 |
| P0 | `.../DRConflictEscalate.hpp` | `buildConflictComponents` / `prlShortRepairPriority` / `componentWeightBoost` | 分量算法（头文件可测） |
| P0 | `.../DRRuleAwareCost.hpp` | `ruleAwareWeight` / `ruleAwareViolationCost` | 规则权重 |
| P0 | `.../DRConvergence.hpp` | `DRConvergenceTracker` | plateau 状态向量 |
| P0 | `.../data_manager/advance/Config.hpp` + `interface/RTInterface.cpp` | wrapConfig | 缺省 OFF 开关 |
| P1 | `.../DRNode.hpp` | `getViolationCost` / `addViolationNumber` | A* 历史代价缩放 |
| P2 | `interface/RTInterface.cpp` | `updateTiming` | 复活时序 |
| P2 | `layer_assigner/LayerAssigner.*` / `space_router/SpaceRouter.*` | LA/SR | 拥塞协商（EGR WL） |

#### 已合入开关（缺省全 OFF → 零回归）

| 开关 | Config / Env | 作用 |
|---|---|---|
| 规则感知代价 | `enable_rule_aware_cost` / `IEDA_RT_RULE_AWARE_COST` | short/PRL/min-area 权重 |
| 强化 min-area | `enable_enhanced_minarea_repair` / `IEDA_RT_ENHANCED_MINAREA_REPAIR` | patch 候选预算 |
| 分量 escalate | `enable_component_escalate` / `IEDA_RT_COMPONENT_ESCALATE` | plateau 后分量权重 |
| PRL/short 优先 | `enable_prl_short_repair` / `IEDA_RT_PRL_SHORT_REPAIR` | rip-up 排序 |
| 全局 box escalate | `enable_plateau_escalate` / `IEDA_RT_ENABLE_ESCALATION` | **可选**；非 01b 主路径 |

Flow CLI：`--rt-rule-aware-cost` / `--rt-enhanced-minarea-repair` / `--rt-component-escalate` / `--rt-prl-short-repair`。

#### 质量门禁
- A* 热路径：**禁止** `getenv`；config 在 `routeDRModel` 缓存一次。
- history scale 封顶（默认 8）。
- 单测：`irt_dr_rule_aware_cost_test`、`irt_dr_conflict_escalate_test`、`irt_dr_convergence_test`。

#### Done 包
`src/operation/iRT/` diff + 缺省关零回归 + AES@65% proxy A/B ΔDRC≥20%（或 WP 阈值）+ 请 A1 审。
**禁止**用 `MAX_BOXES` / BEST_EFFORT 冒充 Done。

---

### 13.2 iRCX（A2）— SPEF 真值

#### 症结
无 SPEF → STA `net delay=0` → 一切 WNS/Fmax「优化」无效。当前主阻塞：**缺 ITF + captab**（foundry）。

#### 算法方案
1. 线段 tile + R-tree 邻居查询。
2. Pattern key：`(layer, width, space, thickness, density, neighbor_count, via_stack)`。
3. Dirty net 更新：含耦合 halo；查询界外 → `out_of_domain`（禁止外推）。
4. 写出 SPEF；缺失则 **非零退出**（禁止静默跳过）。

#### C++ 落点

| 文件 | 改什么 |
|---|---|
| `src/operation/iRCX/flow/extraction/Extraction.*` | 提取管线；失败语义 |
| `.../capacitance/CapacitanceCalc.*` | 耦合/图案电容 |
| `.../resistance/ResistanceCalc.*` / Via model | 电阻 |
| `.../database/config/RCXConfig.hh` | ITF/captab/corners 路径；`thread_num` |

#### Done 包
关键路径 `net delay > 0`；AES 子集 100% SPEF-backed；E-RCX-01 关/开 SPEF 分布分离。
**未解锁 ITF 前**：只允许准备性 C++（失败语义、接口），不得宣称 QoR。

---

### 13.3 iSTA（A3）— 约束 / 增量 / PBA

#### 症结
约束不全 + 无 SPEF → 报告不可信；iTO 高频调用需要增量，否则墙钟炸。

#### 算法方案
1. **WP-STA-01**：SDC 覆盖检查；unconstrained=0；缺 slew 响亮。
2. Levelization + SCC；dirty cone：前向 arrival + 后向 required。
3. **WP-STA-02**：GBA 筛 endpoint → top-N PBA；超预算标 `pba_exhausted`。

#### C++ 落点

| 文件 | 改什么 |
|---|---|
| `src/operation/iSTA/module/sta/Sta.*` | 主图 / 传播 / 增量失效 |
| `StaSlewPropagation.*` 等 | slew/data prop |
| `module/delay/ElmoreDelayCalc.*` | 延迟模型接 SPEF |
| `api/TimingEngine.*` | 对外 API；`read_spef` 失败语义 |
| （PBA）`StaPathBased.*` 或等价 | beam / k-shortest |

#### Done 包
E-STA-01 漏约束必 FAIL；增量 vs full 一致；SPEF-backed 后方可进 WNS 门禁。

---

### 13.4 iPA（A4）— 活动率 / Power 真值

#### 症结
`switch_power≈0`、vectorless 未标注 → Power/IR 决策不可用。

#### 算法方案
活动源：`VCD/FSDB → SAIF → vectorless(labeled)`；传播 toggle/SP；报告四分项 + coverage。

#### C++ 落点

| 文件 | 改什么 |
|---|---|
| `src/operation/iPA/api/Power.*` / `PowerEngine.*` | 入口与报告 |
| `ops/propagate_toggle_sp/*` | 活动率传播 |
| `ops/calc_power/PwrCalc{Switch,Internal,Leakage}Power.*` | 分项计算 |
| `core/PwrGraph.*` | 图结构 |

#### Done 包
`activity_source` 标签强制；无活动源不得进 IR 决策门禁。

---

### 13.5 iDRC（A6）— 规则反馈闭环

#### 症结
iRT 只能数违例，缺结构化 `(type,layer,bbox,net_ids,severity)` → escalate 策略盲目。

#### 算法方案
1. in-design 子集：short / PRL spacing / min-area / enclosure（sweep-line + R-tree）。
2. 输出 **C-VIO v0** JSON；coverage 三分：`checked/skipped/unsupported`。
3. 禁止假 clean：有 unsupported 不得宣称 signoff_clean。

#### C++ 落点

| 文件 | 改什么 |
|---|---|
| `src/operation/iDRC/interface/DRCInterface.cpp` | `getViolationList`；**`outputCVioJson`**（checkDef） |
| `.../Config.hpp` | `enable_c_vio_json` / `c_vio_json_path` |
| `rule_validator/RuleValidator.*` | verify 管线 |
| `rv_design_rule/MetalShort.cpp` 等 | 单规则实现/性能 |

#### 已合入
- `IEDA_DRC_ENABLE_C_VIO=1` → 写 `c_vio.json`（缺省 OFF）。
- RFC：`docs/ai/agents/rfc/RFC-20260730-C-VIO.md`（A5+A6 ACK）。

#### 下一步 C++
注入 short 必检出 UT；可选：`getViolationList` 热路径旁路 dump（仍缺省 OFF）。

---

### 13.6 iPL（A7）— 可布线布局

#### 症结
65% 下下游 DRC/WL 受布局拥塞影响大；随机初值与无 inflation 回退会伤 QoR。

#### 算法方案
1. 稳定初值（B2B/QP/coarsening）；禁止随机为生产默认。
2. 保留 WA/LSE + electrostatic + Nesterov。
3. RUDY util → `inflateInstancesByRouteUtil`（`density_scale`，硬顶 3.0）。
4. **发散 keep-best 时同步回滚 density_scale**（已做）。
5. Timing/power net weight 平滑封顶；LG dirty halo。

#### C++ 落点

| 文件 | 改什么 |
|---|---|
| `.../electrostatic_placer/NesterovPlace.cc` | `inflateInstancesByRouteUtil`；主循环 congestion 段；**density_scale 快照/回退** |
| `.../NesterovPlaceConfig.hh` / `Configurator.cc` | `is_opt_congestion` ← `is_congestion_effort` |
| `.../config/pl_default_config.json` | **缺省 `is_congestion_effort=0`** |
| `BinGrid.*` / `GridManager.*` | `evalRouteDem/Cap/Util`、blur |
| `legalizer/Legalizer.*` | 增量 LG |

#### 实验
E-PL-01：同 trueutil 种子，`is_congestion_effort` off/on；看 EGR WL / overflow 面积。

---

### 13.7 iTO（A8）— Setup / Hold / DRV / Power

#### 症结
无精确 STA 否决的局部估计会引入 hold/DRV 回归；必须 MoveTxn。

#### 算法方案
见 §5 Wave-2 伪代码：`score(move)` → 冲突图批处理 → MoveTxn → incr LG/RC/STA/DRC → accept/rollback。
固定序：DRV → setup → hold → setup recovery。

#### C++ 落点

| 文件 | 改什么 |
|---|---|
| `src/operation/iTO/.../SetupOptimizer.*` | setup 候选与接受 |
| `.../HoldOptimizer.*` | hold |
| `.../ViolationOptimizer.*` | DRV |
| `.../solver/buffer/vg/VGBuffer.*` | van Ginneken buffer DP |
| `config/ToConfig.h` | target_slack / buffer 列表 / util 上限 |
| `src/platform/design_state/MoveTxn.*` | 原子提交（与 A11 共改） |

#### 前置
**必须** Wave-0 SPEF + 活动率；否则 A1 拒收 WNS/Power。

---

### 13.8 iCTS（A8）— 时钟树

#### 算法方案
clustering → BST/DME 拓扑 → buffer DP Pareto → useful skew → MoveTxn commit。

#### C++ 落点

| 文件 | 改什么 |
|---|---|
| `.../bound_skew_tree/BSTRouter.*` | 有界 skew 路由 |
| `.../topology/TopologyGen.*` | 拓扑 |
| `.../flow/optimization/Optimization.*` | buffer / skew |
| `.../flow/synthesis/Synthesis.*` | 综合入口 |
| `database/config/Config.hh` | `skew_bound` / `max_fanout` / `buffer_types` |

---

### 13.9 iPNP / iPDN（A9）— PDN

#### 算法方案
1. **WP-PNP-00**：真实 rings/straps/via + source；无 PDN → IR=`unsupported`。
2. **WP-PNP-01**：SA/多目标优化 worst IR vs blockage；金属占位回写 iRT supply。

#### C++ 落点

| 文件 | 改什么 |
|---|---|
| `iPDN/.../pdn_plan/pdn_plan.*` | createGrid/Stripe |
| `iPDN/.../pdn_via/pdn_via.*` | via |
| `iPNP/.../optimizer/PdnOptimizer.*` / `SimulatedAnnealing.*` | 敏感度优化 |
| `iPNP/.../synthesis/NetworkSynthesis.*` | 网络生成 |

---

### 13.10 iIR（A10）— 静态 IR

#### 算法方案
抽 G → 解 `Gv=i`（CG/LU）→ worst/avg/超阈面积/热图/residual；浮空节点响亮失败。

#### C++ 落点

| 文件 | 改什么 |
|---|---|
| `src/operation/iIR/.../ir-solver/IRSolver.*` | `IRCGSolver` / `IRLUSolver`；tolerance / max_iter |
| `.../power-netlist/PGNetlist.*` | PG 图 |
| `api/iIR.*` | 对外 API |

电流源接 iPA；无活动率则报告标 `proxy`。

---

### 13.11 platform（A11）— MoveTxn / DirtySet

#### 算法/契约方案
统一 `DesignState` + `DirtySet` + `MoveTxn::{apply,commit,rollback}`；ArtifactIndex sha256。

#### C++ 落点

| 文件 | 改什么 |
|---|---|
| `src/platform/design_state/MoveTxn.{hh,cpp}` | 事务 |
| `DirtySet.{hh,cpp}` | 脏区 |
| `DesignState.{hh,cpp}` | 提交入口 |

无 QoR 旋钮；每个 iTO/iCTS/iECO PR 必须声明是否遵守。

---

### 13.12 实施检查清单（每个算法 PR）

```text
[ ] src_paths 落在 §1.5 / §13.0 目录
[ ] 单一主假说 + 杀死实验已写日报
[ ] 新杠杆缺省 OFF；打开后有 A/B
[ ] 热路径无 getenv / 无日志风暴
[ ] 单测或最小回归绿
[ ] AES@65% artifact（或声明为何只 UT）
[ ] 未用 MAX_BOXES/BEST_EFFORT/util DOE 冒充指标
[ ] 请 A1 标 trusted/proxy/invalid
```

---

## 附录 A · 工作包速查表

| ID | Wave | 工具 | 主指标 | 优先级 | §13 |
|---|---|---|---|---|---|
| WP-RCX-01 | 0 | iRCX | WNS/Fmax 真值 | P0 | 13.2 |
| WP-STA-01 | 0 | iSTA | WNS/Fmax 真值 | P0 | 13.3 |
| WP-PA-01 | 0 | iPA | Power/IR 真值 | P0 | 13.4 |
| WP-IRT-MAP-01 | 0 | iRT report | Congestion 门禁 | P0 | 13.1 |
| WP-PNP-00 | 0 | iPNP | IR 前置 | P0 | 13.9 |
| WP-RT-01 | 1 | iRT | DRC / WL / WNS | P0 | 13.1 |
| WP-DRC-01 | 1 | iDRC | DRC | P0 | 13.5 |
| WP-PL-01 | 1 | iPL | EGR WL / DRC | P1 | 13.6 |
| WP-TO-01 | 2 | iTO | WNS / Power | P1 | 13.7 |
| WP-CTS-01 | 2 | iCTS | Fmax / Power | P1 | 13.8 |
| WP-STA-02 | 2 | iSTA | 支撑 TO/CTS | P1 | 13.3 |
| WP-PNP-01 | 3 | iPNP | IR | P1 | 13.9 |
| WP-IR-01 | 3 | iIR | IR | P1 | 13.10 |
| WP-PLT-01 | 4 | platform | 全指标一致性 | 贯穿 | 13.11 |

## 附录 B · 决策记录

| 决策 | 选择 | 被否方案 | 理由 |
|---|---|---|---|
| 优化主杠杆 | 算法/内核/契约改造 | util/padding DOE | AES12 a/b/t 已证伪密度主因 |
| 指标 20% 基线 | Wave-0 可信后重测 | 直接用当前报告 WNS/Power | net delay=0 / switch=0 |
| DRC 目标 | Wave-1 对齐 ↓50%+clean 路径 | 仅满足字面 20% | 数万违例下 20% 无签核意义 |
| IR 范围 | 先静态 | 同步上动态 IR | 缺 PDN/活动覆盖 |
| AI 角色 | ranking / policy，精确否决 | 端到端生成布线 | `04` §6 纪律 |
| 文档粒度（rv1.2） | §13 钉到文件/函数/开关 | 只写 Wave 口号 | Agent 需要可执行落点 |
