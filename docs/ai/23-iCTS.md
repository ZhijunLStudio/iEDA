<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 23 · iCTS 时钟树综合 · 商业对标方案 · rv2.1

> 文档号：23-rv2.1　　版本：rv2.1（实现评审优化）　　里程碑：**双对标 —— ccopt 签核精度（G19：skew/latency/power）× Innovus in-design 调用（增量分支更新不成瓶颈）**
> 体例：`01-ai-doc-conventions-rv1.md`；深度对标：`27-iSTA-rv2.0.md`（逐 kernel 算法伪码 + 双对标线 + 双看板）
> 商业金标：**ccopt（时钟质量签核准确性）**；**Innovus（物理设计流程中的 CTS 调用模式）**；门禁：**G4 / G19 / G17**（辅 G16/G21；useful skew 依赖 G7）
> 上游：`22-iPL`、`10-iDB`、SDC；下游：`26-iRT`、`27-iSTA`、`30-iPA`、`12-evaluation`
> 纲领：`00-ieda-commercial-parity-master-plan-v1.1.md`；Know-how：`03-commercial-knowhow-catalog.md` KH-CTS-\*
> 联合架构：`04-ppa-technical-review-and-optimization-rv1.md`；闭环工作台：`51-agent-native-eda-detailed-plan-v1.0.md`
> 覆盖：`src/operation/iCTS/`（**source 62.5k + test 21.2k = 83.7k LOC**）：`flow/{Flow,Synthesis,Optimization,instantiation,evaluation,report}`、`module/{routing,topology,characterization,timing}`、`database/`、`api/CTSAPI.*`
> 纪律：**文档是假说不是事实**；断言带 `file:line`；未实测写「未验证」；每条理论附能杀死它的对照。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.0–v1.1 | 2026-07-20 | 摘要：无 incr LG；skew 只报告；无 useful skew |
| rv1.0 | 2026-07-20 | 体例对齐；坐实 C1（无 post-buffer LG）/C2（skew 不 fail）；推翻「HiGHS 即默认」「BST 是主 spine」 |
| rv1.1 | 2026-07-21 | 重读 `Flow.cc`、`Optimization.cc`、`Config.hh`；坐实 C2 机理（void 强转+成败公式排除 optimization）；测试资产盘点（21.2k） |
| **rv2.0** | **2026-07-21** | **大改（对照 27-iSTA-rv2.0.md 深度重写，目标显式拆成双对标线）**。核心修订五条：**(1)** 明确 **双对标线**：ccopt 线 = 时钟质量签核精度（skew/latency/power 三指标 ≤5%，G19），Innovus 线 = in-design 调用模式（CTS 在优化循环中墙钟占比 ≤20%，post-CTS 能立即进 iTO/iRT 而非卡死，G21 分项）——rv1.0/rv1.1 只隐含"打平 ccopt"单线，未审 CTS 作为工具被调用的性能与接口;**(2)** §1 **逐 kernel 算法审计**：H-tree 离散主路径 = characterization 表驱动 + fanout/cap 约束搜索 + embedding 插 buffer（非通用拓扑优化算法如 DME/ZST），HiGHS analytical 路径 = MILP 求解器后端（真求解器但生产关闭），BST = 教科书 bottom-up joining + top-down embedding 但**主 spine 是 H-tree 不是 BST**（`Solution.cc:38-41` 只在 enable_analytical_solver 分叉，无 BST 主路径）;**(3)** §4 **每模块给算法伪码、复杂度、边界、复用姿势**，新增 §4.12 **模块状态一览表**（成熟度 / 主复杂度 / 关键边界 / 复用姿势，类比 27 号文档 §4.12）;**(4)** §10 拆成 **§10.1 ccopt 精度看板（skew/latency/power）+ §10.2 Innovus 调用模式看板（墙钟占比 / 接口响应）**；§10.3 对照实验每条给「杀死条件」（E-CTS-XX 编号，类比 27 号的 E-PT-XX / E-INCR-XX）;**(5)** §14 按 27 号体例重组：§14.1 未验证、§14.2 负面结论/不要重走、§14.3 兄弟仓库实测发现（预留，现空）、§14.4 相对 rv1.1 的纠偏。**rv1.1 的 C1/C2 结论、FR/NFR 框架、M0–M4 演进全部保留**，本版按双对标线重组并补齐算法细节。 |
| **rv2.1** | **2026-07-23** | 实现评审：useful skew 改为同时受 setup/hold 差分约束的 LP；buffer 选择补 Pareto DP；增量 CTS 明确 dirty branch RC/STA 优先、拓扑重构后置；G19 加绝对 ps/mW 下限，生产模式严格失败。 |

---

## 1. 症结审计（逐 kernel / 逐模块代码走读）

对 `src/operation/iCTS/` 全树（source 62.5k + test 21.2k）走读后的判定。**前提**：rv2.0 不推翻 rv1.1 的核心结论（C1/C2 机理），但把审计深度对齐 27 号文档：逐 kernel 给「现状算法 / 判定 / 缺口」三列，并明确 CTS 作为"被优化器反复调用的工具"的性能与接口症结（§1.4）。

生产骨架（`Flow.cc:94-152` 实测）：

```text
CTSAPI::runCTS → Flow::runCTS
  Setup 检查(失败→kSetupNotReady) → readClockData(失败→kReadDataFailed)
  → (void)runSynthesis → (void)runOptimization → (void)instantiateClockTree → (void)evaluateClockTree
  → buildCompletedRunStatus(synthesis, instantiation)   // 只含两段，见 §1.3
```

### 1.1 功能形态——商业级骨架在，提交闭环缺两道闸（rv1.1 结论保留）

| 能力 | 现状 | 证据 | 判定 |
|---|---|---|---|
| SDC clock 追踪 | ✓ 多钟/歧义/mux/virtual | `ClockTraceResolve.cc`（527 LOC）；`FlowSdcTraceTest.cc` 858 LOC 测试 | **成熟** |
| Sink 聚类 | ✓ FastClustering | `SinkLoadClustering.cc:221`；`enable_sink_clustering` 缺省 true（`Config.hh:76,183`） | **成熟** |
| H-tree 合成 | ✓ 离散为主 | `Solution.cc:38-41` 分派 | **主路径=离散** |
| HiGHS MILP | ✓ 可选 | `HighsMathHtreeSolver.cc` 1022 LOC；`Config.hh:75,182` 缺省 **false** | **成熟备选** |
| Bound-skew tree | ✓ BottomUp+TopDown | BST 算法 ~4.7k LOC；routing/bound_skew_tree 目录 | **算法成熟，辅助原语** |
| Buffer 插入+写回 | ✓ | Embedding(569) → Instantiation → WrapperClockWriter(631) | **可用** |
| Optimization 报告 | ✓ skew/area/target_met | `OptimizationReport.cc:102`（target_met 打印为字符串） | **只报告** |
| Post-buffer **placement legalize** | ✗ | `runIncrLG\|runLegalize\|Legalizer` 在 `source/` **零命中** | **P0 缺口（KH-CTS-05）** |
| Useful skew | ✗ | 零命中 | **P2，依赖 G7** |
| 对 iSTA/iPA/iRT 运行时调用 | ✗ | 仅 `cts_lib_bridge.hh`；内部 FastSTA adapter（`source/module/timing/` 304 LOC） | **闭环断** |

### 1.2 算法成熟度——逐 kernel 走读（H-tree = 表驱动搜索 ≠ 通用拓扑优化）

**ccopt 核心算法能力**（商业对标基准）：
- **拓扑合成**：DME (Deferred-Merge Embedding) / ZST (Zero-Skew Tree) / MMM (Method of Means and Medians) 等通用最优拓扑算法
- **多目标优化**：skew + latency + power 三目标帕累托前沿搜索，非单一 min-skew
- **Useful skew**：基于 iSTA slack 的时序预算搬运（KH-CTS-02）
- **后处理闭环**：buffer 插入后强制 legalize + 实时 DRC/timing 验证

**iCTS 现状算法逐 kernel**：

| kernel | LOC | 现状算法 | 判定 | 与 ccopt 差距 |
|---|---|---|---|---|
| 离散 H-tree | `flow/synthesis/htree/discrete_solution/` | **Characterization 表驱动 + fanout/cap 约束搜索 + embedding**；非 DME/ZST 等通用拓扑优化 | **工业化搜索** | 算法层：无 DME/ZST；目标函数：单一 skew，缺 latency/power 联合优化 |
| `HighsMathHtreeSolver` | 1022 | HiGHS in-process MILP 求解后端 | **真求解器** | 缺省关；无"离散失败→analytical"产品化回退；与 ccopt analytical 模式数值未对拍 |
| BST | `routing/bound_skew_tree/` ~4.7k | bottom-up (joining/balance) + top-down (embedding)；**教科书算法** | **辅助原语** | **主 spine = H-tree 不是 BST**（`Solution.cc:38-41` 无 BST 主路径分支）；BST 仅作 FLUTE/SALT 等的候选 |
| Optimization sizing | `flow/optimization/Optimization.cc` | 逐 clock 迭代 trial sizing；FastSTA 驱动；accepted_edits 计数 | 可用 | **状态不进 runCTS 成败**（§1.3）；reason 字符串惯例脆弱；sizing 策略单一（无 multi-corner VT-aware） |
| FastClustering | `module/topology/fast_clustering/` ~2.3k | partition/boundary/polish/finalize 四阶段 | 成熟 | 商业 multi-level 策略开关少；无 useful-skew-aware 聚类 |
| FastSTA adapter | `module/timing/` 304 LOC | 内部轻量 timing/slew/delay 估计，驱动 Optimization | 估计轨 | **禁当 G19 金标**（必须外生 iSTA 或 ccopt 读数，G15） |

**算法层归因（ccopt 线核心差距）**：
1. **拓扑算法**：iCTS 离散 H-tree = 表驱动启发式搜索 ≠ ccopt 的 DME/ZST 理论最优算法——但"表驱动"本身是工业化路径，差距在**目标函数**（单 skew vs 三目标）而非算法类别。
2. **多目标优化**：iCTS Optimization 只优化 skew/cap，无 latency/power 作为显式目标——ccopt 的 `-target_skew`/`-max_transition`/`-power_priority` 三维帕累托。
3. **Useful skew**：iCTS 零支持；ccopt 依赖 in-design STA 的 setup/hold slack 实时反馈（KH-CTS-02）。

**假说 H-CTS-1（可杀）**：G19 差距主因是 post-CTS 重叠/位移（无 incr LG）而非 H-tree 拓扑。杀死实验 E-CTS-01：CTS 后 iPL LayoutChecker 报 overlap=0 且 skew 仍远劣 → 杀 H-CTS-1，改查目标函数/sizing 策略。
**假说 H-CTS-2（可杀）**：HiGHS analytical 系统性优于离散。杀死实验 E-CTS-02：同设计 A/B off/on，p50/p90 skew/latency 无显著改善或墙钟爆炸 → 杀，维持离散默认。
**假说 H-CTS-3（rv2.0 新增，可杀）**：iCTS 的 FastSTA 与外生 iSTA 读数系统性偏差 >10%。杀死实验 E-CTS-03：同 CTS 产物用 FastSTA vs 外生 iSTA 算 skew/latency，若一致（Δ<5%）→ 杀 H-CTS-3，sizing 策略本身不是瓶颈。

### 1.3 边界 / 回退 / 假成功——**本版核心：成败公式的三重排除**（rv1.1 保留）

`Flow::runCTS` 的成败判定（`Flow.cc:130`）：

```cpp
const bool run_success = _run_summary.outcome == SynthesisOutcome::kFinished
                         && _run_summary.success && _instantiation_summary.success;
```

1. **Optimization 被排除**：`runOptimization()` 的结果（含 `solver_failed`/`no_op`）不在公式里——`runCTS` 可以在"零 buffer 被优化"的情况下 `kFinished`。
2. **skew/target_met 被排除**：`OptimizationReport.cc:102` 仅打印 `target_met` 字符串。
3. **reason 可观测性靠字符串惯例**：`Optimization.cc:294` 在 `no_op_reason ∈ {no_optimizable_clock, target_met}` 时用 `summary.stop_reason` 覆写——"target_met"既是 no_op 理由又会被更具体的 stop_reason 替换，**语义靠约定不靠类型**；`:225` 连 `fast_sta_context_failed`（STA 环境坏了）也只落 no_op。
4. **四阶段 `(void)` 强转**（`Flow.cc:125-128`）：阶段的 `EvaluationBuild`/summary 返回值显式丢弃，状态靠成员变量隐式传递——这是上述三排除的代码形态根源。
5. 仅有的失败通道：setup（`Flow.cc:100-111` → kSetupNotReady）与 readClockData（`:113-124` → kReadDataFailed）——**数据进得来、树搭得出，后面全是软语义**。

### 1.4 ★in-design 调用审计——现状 = 单次批处理，不是高频增量（Innovus 线核心证据）

**Innovus ccopt in-design 模式**：
- **常驻内存**：CTS 后时钟树结构保持，后续 ECO（iTO buffer 插入、iPL 微调）只需**局部更新** skew/latency
- **增量接口**：`update_clock_tree -eco` 仅重算受影响分支，非全树重 synthesis
- **高频调用**：post-CTS 的 iTO fix_drv / fix_hold 每轮迭代都调 STA，若 CTS 数据被破坏则立即修复时钟网，而非重跑完整 CTS

**iCTS 现状调用形态**（据下游代码审计）：

| 下游工具 | 调用点 | 形态 | 判定 |
|---|---|---|---|
| 日常流程 | `run_iCTS.tcl` → `run_cts` 命令 | **单次全量**：setup → synthesis → optimization → instantiation → 写 DEF 退出 | **批处理** |
| iTO post-CTS | **无运行时调用**（iTO 在 CTS 后从 iDB 读时钟网） | ECO 后无"update_clock_tree"语义 | **静态产物** |
| iRT post-CTS | **无运行时调用**（iRT 从 DEF 读） | 同上 | **静态产物** |
| iPL post-CTS | **无运行时调用**（布局从 iDB 读坐标） | cell 微移后无时钟树更新 | **静态产物** |

**与 Innovus 的差距**（Innovus 线，影响 G21 墙钟占比）：
- iCTS 是"run once, write DEF, exit"批处理——post-CTS 工具把时钟网当普通网处理，CTS 本身不再参与闭环。
- ccopt in-design 模式下，时钟结构在内存常驻，ECO 可触发局部更新（如单 buffer resize 只重算该分支 RC）。
- **影响**：若 post-CTS 的 iPL/iTO 破坏了时钟 buffer 位置/连接，现状**无闭环修复**——要么忍受劣化，要么手动重跑完整 `run_cts`（成本高，实际不做）。

**假说 H-CTS-4（rv2.0 新增，可杀）**：post-CTS 的 iPL/iTO 不会显著破坏时钟质量（skew/latency 变化 <5%）。
**杀死实验 E-CTS-04**：CTS 后 → iTO fix_drv → 重测 skew/latency（外生 STA），若劣化 >5% → 杀 H-CTS-4，需要增量 update 接口（FR-CTS-14）。

### 1.5 跨工具协调（保留 rv1.1）

| 方向 | 现状 | 判定 |
|---|---|---|
| SDC → iCTS | `SdcClockReader` + `ClockTraceResolve` | **通** |
| iCTS → iDB | IdbConversion/WrapperClockWriter | **通**；无 post-LG |
| iCTS → iPL | **无** `runIncrLG`（grep 零命中） | **断（P0）** |
| iCTS → iSTA | 内部 FastSTA adapter（304 LOC） | 估计轨；G19 须外生 |
| iCTS → iPA | FastSTA power 在；→iPA 链**未验证** | G4「时钟进功耗报告」待实锤 |
| iCTS → iRT | 不调 iRT；Steiner/RC 内估 | NDR 属 KH-CTS-04 Phase C |
| iCTS ↔ ccopt | 无 `benchmark/qor/cts/` | **G19 前置缺** |
| **post-CTS → iCTS** | **无增量更新接口** | **Innovus 线缺口** |

### 1.6 「legalize」名存实亡（rv1.1 结论保留，证据维持）

`LocalLegalization` 服务 FLUTE 端子/聚类 root（`Router.cc:152-184`、`ClusterConstraintEvaluator.cc:80-93`）；`Router::legalizePins`（`Router.cc:305-321`）生产零调用仅测试引用；**Instantiation 后无 cell 级 LG/DRC/site 校验**。措辞纪律：缺的是 **iPL incr LG**，不是"没有 legalize"。

### 1.7 症结优先级表（§1 结论摘要）

| ID | 症结 | 证据 | 对标线 | P |
|---|---|---|---|---|
| **C1** | buffer 写回后无 iPL incr LG | `source/` 内 `runIncrLG` 零命中；KH-CTS-05 | ccopt | **P0** |
| **C2** | optimization/skew 不进 `runCTS` 成败 | `Flow.cc:125-130`（void 强转+成败公式）；`Optimization.cc:225,241,273,319-321` | ccopt | **P0（G4）** |
| **C3** | 无 vs ccopt harness | 无 `benchmark/qor/cts/` | ccopt | **P0** |
| **C4** | ★ 无增量 update 接口（post-CTS ECO 静态产物） | §1.4 下游调用审计 | Innovus | **P0（G21）** |
| **C5** | ★ 单目标优化（skew only，无 latency/power 联合） | Optimization 只看 skew；无 `-power_priority` 等 | ccopt | **P1（G19）** |
| C6 | HiGHS 缺省关；易误读为默认 | `Config.hh:75,182`；`Solution.cc:38-41` | ccopt | P1 |
| C7 | 时钟功耗→iPA 链未验证 | fast_sta/power 在；外链未验 | ccopt | P1（G4）** |
| C8 | 无 useful skew | 零命中；KH-CTS-02 | ccopt | P2（G7 后）** |
| C9 | BST 无专项 gtest | test/（21.2k）无 BoundSkew 专用 | — | P2 |
| C10 | no_op reason 字符串惯例 | `Optimization.cc:294` 覆写逻辑 | — | P1（可观测性）** |

---

## 2. 需求 FR / NFR / 约束

### 2.1 FR（★ = 相对 rv1.1 新增）

| ID | 功能 | 现状 | rv2.0 |
|---|---|---|---|
| FR-CTS-01 | SDC multi-clock trace + 歧义报告 | ✓ | 保留；ambiguous 响亮策略进 G14 |
| FR-CTS-02 | H-tree 离散合成 + embedding/writeback | ✓ | 保留主路径 |
| FR-CTS-03 | 可选 HiGHS analytical H-tree | ✓ 缺省 off | 保留；★ 失败响亮回退离散 |
| FR-CTS-04 | BST/FLUTE/SALT/CBS 路由原语 | ✓ | 保留；★ 补 BST gtest |
| FR-CTS-05 | Optimization + EmitClockSummary | ✓ | ★ **optimization 状态进 runCTS 成败**（§4.2） |
| FR-CTS-06 | ★ post-instantiation iPL `runIncrLG` | ✗ | ★ 生产推荐 on；开关可关→零回归 |
| FR-CTS-07 | ★ skew 硬门禁（逐 clock target_met） | 只报告 | ★ production/CI 缺省严格失败；仅显式 compatibility profile 可放宽 |
| FR-CTS-08 | ★ vs ccopt harness | ✗ | ★ G19 前置 |
| FR-CTS-09 | ★ 时钟功耗进 iPA / 报告 delta | 半有 | ★ 实锤 G4 |
| FR-CTS-10 | ★ useful skew | ✗ | ★ 缺省 off；依赖 G7 |
| FR-CTS-11 | ★ 多域门禁汇总 + JSON exhibit | 部分 | ★ 对齐 12-eval |
| FR-CTS-12 | ★ NDR/shield 契约（与 iRT） | ✗ | ★ Phase C |
| FR-CTS-13 | ★ no_op reason 类型化（enum 替字符串惯例） | 字符串覆写 | ★ P1 可观测性 |
| **FR-CTS-14** | ★ **增量 update 接口**（post-CTS ECO 可触发局部修复） | ✗ | ★ `update_clock_tree` 命令；缺省 off（Innovus 线） |
| **FR-CTS-15** | ★ **多目标优化**（skew + latency + power 三目标） | 单 skew | ★ 权重可配；缺省单目标=现状（ccopt 线） |

### 2.2 NFR（可测数字）

| ID | 项 | 指标 | 对标线 |
|---|---|---|---|
| NFR-CTS-01 | G4 skew | 每 SDC clock：optimized_skew ≤ skew_bound + ε（1–5 ps 协议化） | ccopt |
| NFR-CTS-02 | G4 legality | CTS 后 overlap=0；site 对齐；runIncrLG rc=0 | ccopt |
| NFR-CTS-03 | **G19 精度** | vs ccopt 的 skew/latency/时钟功耗分别用 `max(相对阈值, 绝对阈值)`：例如 skew/latency 至少容许协议化 2–5 ps floor，功耗设测量噪声 floor；三项独立同时验收 | ccopt |
| NFR-CTS-04 | 零回归 | 两开关 false → 与当前二进制行为一致（浮点 ε 内） | — |
| NFR-CTS-05 | HiGHS 可选档 | 开启不劣于离散，或响亮回退 | ccopt |
| **NFR-CTS-06** | ★ **墙钟（Innovus 线）** | 日常设计 CTS ≤1.5× ccopt；**post-CTS 工具（iTO/iRT）墙钟中 CTS 更新占比 ≤20%** | Innovus / G21 |
| NFR-CTS-07 | optimization 失败 | `solver_failed`/`fast_sta_context_failed` → runCTS 非成功 rc（开关 on 时） | — |
| **NFR-CTS-08** | ★ 增量更新响应 | `update_clock_tree` 单 buffer ECO ≤ 全量 10% 墙钟 | Innovus |

### 2.3 红线

- **金标 = ccopt/clock_opt**（同设计冻结一条）；G19 外生读数，禁内部 FastSTA 自报打平（G15）。
- **双对标线独立验收**：ccopt 精度线（G19 三指标）≠ Innovus 性能线（G21 墙钟占比）——前者可先达标。
- **无 G4 背书不宣称 G19/G17 CTS 行转绿**。
- **useful skew 无 G7 不开生产默认**（KH-CTS-02）。
- **禁止平行重写 62.5k 行骨架**；只补闭环与目标函数。
- buffer 后**禁止**未 legalize 进 route（对接 40-platform 硬约束）。
- ★ **post-CTS 工具破坏时钟质量 >5% 必报告**（E-CTS-04 量化门槛）。

---

## 3. HLD

### 3.1 数据流（据真实 `Flow::runCTS` + ★闭环）

```text
SDC clocks ──► ClockTraceResolve ──► ClockData
Liberty ──► Characterization ──► CharLibrary
              │
     SinkClustering (FastClustering)
              │
     ┌────────┴────────┐
     │ HTree::build    │
     │ discrete [默认] │  analytical/HiGHS ← enable_analytical_htree(false)
     └────────┬────────┘
              ▼
     Embedding → Optimization(sizing) + EmitClockSummary
              │
     Instantiation → iDB
              │
     ★ iPL::runIncrLG(cts_insts)          ← FR-CTS-06
     ★ assert optimization_status         ← FR-CTS-05（solver_failed→rc）
     ★ assert skew gate per clock         ← FR-CTS-07
              ▼
     Evaluation + JSON exhibit ──► G4 / G19 harness ↔ ccopt
```

### 3.2 关键设计决策（含被否）

| ID | 决策 | 被否 | 理由 |
|---|---|---|---|
| D1 | **先闭环（LG+成败公式+harness）再改目标函数** | 先重写 H-tree | 无 G4/G19 数据无法归因 |
| D2 | **LG 复用 iPL `runIncrLG`** | CTS 内自建 LG | KH-CTS-05；与 iTO 同债 |
| D3 | **离散 H-tree 保持默认** | 强制 HiGHS | E-CTS-02 未过不翻默认 |
| D4 | **BST 保持辅助原语** | BST 替 H-tree spine | 主拓扑已是 H-tree |
| D5 | **production/CI `fail_on_skew_miss=true`；compatibility profile 显式 false** | 生产默认放过 skew miss | 兼容性不能冒充生产成功；旧脚本迁移由 profile 承担 |
| D6 | **optimization 状态进成败做成开关**（NFR-CTS-07） | 无条件改成败公式 | 现状可能依赖"no_op 也绿"的脚本存在 |
| D7 | **no_op reason 先类型化再扩展** | 继续加字符串 | `:294` 覆写已是腐化点 |
| D8 | **useful skew 排 G7 后** | 现用 FastSTA slack | FastSTA≠签核 |

---

## 4. LLD · 模块分解

### 4.0 落点

```text
src/operation/iCTS/
  source/flow/Flow.cc                    ← ★ (void) 强转改状态检查；成败公式扩展
  source/flow/optimization/Optimization.{cc,hh}  ← ★ no_op reason 类型化
  source/database/config/Config.*        ← ★ 新开关（缺省保零回归）
  api/CTSAPI.*                           ← rc 语义导出
benchmark/qor/cts/                       ← ★ vs ccopt harness
```

### 4.1 ★ Flow 成败公式修复（FR-CTS-05/06/07，核心）

**真实现状**（`Flow.cc:125-152`）：四阶段 `(void)` 强转；成败只看 synthesis+instantiation。

```text
★ ALG-CTS-1  runCTS() 扩展（全开关控制，缺省=现状）:
  [已有] (void) runSynthesis(); (void) runOptimization(); (void) instantiateClockTree();
  ★ if cfg.post_cts_legalize:
       insts = collectInsertedClockBuffers()
       rc = PLAPI::runIncrLG(insts);  if rc!=0: return kLegalizeFailed
  ★ if cfg.fail_on_optimization_failure:
       if optimization_summary.status == "no_op"
          && reason ∈ {solver_failed, fast_sta_context_failed, no_resizable_buffers}:
            return kOptimizationFailed
  ★ if cfg.fail_on_skew_miss:
       for clock summary: if !target_met: return kSkewMiss
  [已有] (void) evaluateClockTree()
```

- **复杂度**：LG 成本由 iPL 决定；门禁 O(#clocks)。
- **边界**：无新 buffer → LG no-op；三开关全 false → 字节等价现状（NFR-CTS-04）。
- **复用姿势**：Composition iPL；禁止平行 LG。

### 4.2 ★ no_op reason 类型化（FR-CTS-13）

**现状**：`Optimization.cc:225/241/273` 字符串赋值 + `:294` 条件覆写 + `:310,319-321` status 字符串。

```cpp
// ★ 新增（替换字符串惯例）
enum class OptStatus { kOptimized, kTargetMet, kNoOptimizableClock,
                       kSolverFailed, kFastStaContextFailed, kNoResizableBuffers };
// report 层做 enum→字符串映射；成败判定（ALG-CTS-1）只读 enum
```

边界：`target_met`（正常停止）与 `solver_failed`（失败）**必须分枚举值**——现状都混在 no_op 桶里是 C2 的语义根源。

### 4.3 H-tree 离散 / HiGHS（已有，不动）

`Solution.cc:35-41` 分派；`Config.hh:75,182` 缺省 false。rv1.1 不改默认；★可选增强：HiGHS 求解失败**响亮回退离散**（现状失败语义未验证，§14）。E-CTS-02 结果进看板。

buffer/线型选择不能只取单一 skew 最小值。对每个 subtree 保留非支配状态 `(downstream_cap, insertion_delay, slew, power, area, buffer_count)`；合并子树时查 characterization 表、过滤 cap/slew/fanout 硬违规，再按 delay/power/area 支配关系剪枝。最终由协议按“skew/DRV 硬门 → latency → power/area”字典序选状态，避免一个加权和掩盖不可接受的 slew 或功耗。

### 4.4 BST（已有，补测）

`BstPipeline::run`（`BstPipeline.cc:65-69`）bottomUp+topDown。★ `BoundSkewTreeTest`（L0）：合并平衡、不可行输入、skew 钳位断言。不可行时日志+钳位 → ★可选 rc 化。

### 4.5 ★ Useful skew（FR-CTS-10，缺省关，G7 后）

```text
ALG-CTS-2  UsefulSkewBudget:
  变量: 每个 sequential sink 的 clock latency l_i，以及绝对偏移辅助变量 u_i
  对每条 launch i → capture j 的 setup check:
    l_i - l_j ≤ setup_slack_ij - setup_guardband
  对对应 hold check:
    l_i - l_j ≥ -hold_slack_ij + hold_guardband
  每个 sink: -B_i ≤ l_i-l_ref ≤ B_i；跨域/假路径按 SDC 语义过滤
  第一目标：所有 setup/hold/DRV 约束可行；第二目标：min max_violation；
  第三目标：min Σu_i + λ_power·ΔP + λ_area·ΔA（只在前两层相同后比较）
  LP 不可行时输出最小冲突约束集，不得裁剪一个 `f(slack)` 后继续写树
杀死实验 E-CTS-03: hold 违例升且 setup 无改善 → 杀，回退盲 min-skew
```

### 4.6 ★ 增量 clock update（FR-CTS-14）

```text
ALG-CTS-3 updateClockTree(DirtySet d)
  定位受影响 clock branch、祖先到最近稳定分叉点及其兄弟边界
  先只更新 dirty branch 的 RC、arrival/slew/skew，并尝试 resize/rebuffer/local legalize
  若 fanout/cap/slew/skew 仍超约束，才重建该局部 topology；禁止默认重跑全 CTS
  用 MoveTxn 记录连接、master、位置、RC/STA version；失败完整 rollback
  dirty_ratio 超阈值或每 K 次调用运行 full CTS analysis oracle，校验增量/全量差
```

缓存 characterization lookup、branch-to-sink 索引和稳定分支 RC；用设计版本号拒绝陈旧缓存。性能门禁同时记录 dirty sinks 数、重算 branch 数、增量/全量墙钟比，而不是只报“接口存在”。

### 4.7 LocalLegalization（语义收口）

文档/API 注释明确「端子防重叠 ≠ placement legalize」；placement LG 唯一入口 = ALG-CTS-1 → iPL。

### 4.8 ★ vs ccopt harness（FR-CTS-08）

```text
run_ccopt_align.sh: 同 netlist/DEF/SDC/lib
  iCTS → icts.def + cts_metrics.json ; ccopt → gold.def + gold_metrics.json
  外生读 skew/latency/clk_power（PT+PTPX 或协议指定）
  → align_report.json {p50,p90,rel_err,per_clock} ; assert G19
禁：内部 FastSTA skew 判 G19 绿
```

### 4.9 模块状态一览

| 模块 | LOC | 成熟度 | 关键边界 | 复用姿势 |
|---|---|---|---|---|
| `Flow::runCTS` | 152（Flow.cc） | 成熟骨架 | setup/read 早退；四阶段 void 强转 | ★扩展成败公式 |
| `ClockTraceResolve` | 527 | 成熟（858 LOC 测试） | ambiguous/unowned | 保留 |
| FastClustering | — | 成熟 | enable_sink_clustering | 保留 |
| 离散 H-tree | ~2.8k（htree/） | 成熟 | fanout/cap/slew | 保留主路径 |
| HiGHS H-tree | 1022 | 成熟可选 | 缺省 off；失败语义未验证 | 保留可选+响亮回退 |
| BST | ~2.9k | 成熟辅助 | 缺专项测；钳位非 rc | 保留+补测 |
| Optimization | — | 可用 | **不进成败**；reason 字符串 | ★门禁化+类型化 |
| FastSTA adapter | 9 子目录 | 估计轨 | 禁 G19 金标 | 保留 |
| Instantiation | — | 成熟 | 无 post-LG | ★Composition iPL |
| test/ | **21.2k** | 全仓最厚 | BST 缺口 | 补 BST |

---

## 5. 配置 / IterParam

| 键 | 缺省 | 含义 | 回归 |
|---|---|---|---|
| `skew_bound` | 现状 JSON | 目标 skew | 不变 |
| `enable_analytical_htree` | **false** | HiGHS | 不变 |
| `enable_sink_clustering` | **true** | 聚类 | 不变 |
| `max_length` | placeholder | **非活跃约束** | 勿当有效 |
| ★ `post_cts_legalize` | **false**（零回归）/生产推荐 true | iPL incr LG | 关=现状 |
| ★ `fail_on_optimization_failure` | **false** | optimization 进成败 | CI 强制 true |
| ★ `fail_on_skew_miss` | **true（production/CI）** | skew 硬门 | compatibility profile 可显式 false |
| ★ `enable_useful_skew` | **false** | useful skew | G7 前禁 true |

多轮渐进（缺省单轮=现状）：R0 全关（基线）→ R1 LG+门禁 on（G4 目标态）→ R2 useful skew（G7 后）。

---

## 6. Cost / 指标分解

| 维 | 符号 | 来源 | 门禁 |
|---|---|---|---|
| Global/local skew | S | Optimization+外生 | G4/G19 |
| Latency | L | 外生/报告 | G19 |
| Clock power | P | iPA/PTPX | G4/G19 |
| Buffer count/area | A | EmitClockSummary | 报告 |
| Legality | G | iPL checker | G4 |
| Optimization status | O | ★enum（FR-CTS-13） | NFR-CTS-07 |
| Wall time | T | SchemaWriter runtime | G21 |

**禁止**单一「CTS PASS」掩盖 O=solver_failed 或 S 超标。

---

## 7. 状态机 / 命令语义

| 命令 | 行为 | 失败 rc（目标） |
|---|---|---|
| `cts_config`/init | 读 JSON → Config | setup 失败 |
| `run_cts` | `Flow::runCTS` | setup/read/synth/inst/★LG/★opt/★skew |
| `cts_report` | 报告 | — |
| `cts_save_tree` | 导出树 | IO 失败 |

现状码：`kFinished/kNoOp/kInstantiationFailed/kSynthesisFailed/kSetupNotReady/kReadDataFailed`（`Flow.cc:80-89`）。
★ 新增：`kLegalizeFailed`、`kOptimizationFailed`、`kSkewMiss`（开关 on 时才可达）。

---

## 8. 跨工具 Cascade

| 信号 | 方向 | 契约 |
|---|---|---|
| clock sinks/SDC | 平台→iCTS | ClockTraceResolve 一致 |
| inserted buffers | iCTS→iDB | writeback 后坐标/连接 |
| incr LG request | iCTS→iPL | inst 名列表；失败禁 route（G16） |
| clk power | iCTS→iPA | 时钟网可识别（FR-CTS-09 实锤） |
| slack map | iSTA→iCTS | useful skew；G7 后 |
| clock NDR | iCTS→iRT | Phase C |
| exhibit JSON | iCTS→12-eval | G4/G19/G17 |

---

## 9. 商业 Know-how 映射

| KH-ID | 落点 |
|---|---|
| KH-CTS-01 局部 skew | BST+报告分组；§4.4 |
| KH-CTS-02 useful skew | §4.5；G7 后 |
| KH-CTS-03 延迟/功耗/skew 三目标 | §6；G19 |
| KH-CTS-04 NDR+屏蔽 | FR-CTS-12 |
| KH-CTS-05 buffer 后必 legalize | ALG-CTS-1 |
| KH-CTS-06 mesh/tree/hybrid | 现 tree；大设计再评 mesh |
| KH-CTS-07 时钟门控感知 | ClockTrace；覆盖未普查→§14 |
| KH-X-01 同一真值源 | G19 外生 |
| KH-EV-01/02 并排金参考 | §10 harness |

---

## 10. 商业对照看板 + 演进 M0–M4

### 10.1 看板（vs ccopt/clock_opt）

| 指标 | iCTS | 商业 | 门槛 | 门禁 |
|---|---|---|---|---|
| skew | | | ≤bound；误差门槛=max(5%, protocol ps floor) | G4/**G19** |
| latency | | | 误差门槛=max(5%, protocol ps floor) | **G19**/G17 |
| 时钟功耗 | | | 误差门槛=max(5%, measurement floor) | G4/**G19** |
| legality | 无 post-LG | PASS | PASS | G4 |
| optimization 失败可见 | 隐 no_op | 响亮 | rc≠0 | NFR-CTS-07 |
| CTS 墙钟 | | | ≤1.5× 起步 | G21 |

### 10.2 对照实验（杀假说）

| ID | 实验 | 若失败则结论 |
|---|---|---|
| E-CTS-01 | overlap 审计 | 杀 H-CTS-1 |
| E-CTS-02 | HiGHS on/off | 杀「必开 HiGHS」 |
| E-CTS-03 | useful skew A/B | 杀错误 budget 函数 |
| E-CTS-04 | 紧 skew_bound+fail_on_skew_miss | 不 FAIL → 门禁假接 |
| E-CTS-05 | 注入 solver_failed | runCTS 仍 kFinished → C2 实锤（修复后必非零） |
| E-CTS-06 | vs ccopt 五套 | G19 真值分桶归因 |

### 10.3 演进

| 里程碑 | 内容 | 退出 |
|---|---|---|
| **M0 先量** | legality 实锤；optimization 状态分布台账；skew JSON 化 | 看见 overlap/状态分布 |
| **M1 可信** | incr LG + `fail_on_skew_miss` + optimization 进成败 → **G4** | G4 绿 |
| **M2 主算法** | reason 类型化；iPA 链；多域；BST 补测 | G4 稳健 |
| **M3 打平** | vs ccopt 五套 **G19**；G17 CTS 行 | G19 |
| **M4 纵深** | useful skew（G7 后）；NDR；G21 剖面 | KH-CTS-02/04 |

---

## 11. Exhibit

| 档 | 产物 |
|---|---|
| text | CTS Optimization Clock Summary；Runtime Overview |
| JSON | `cts_metrics.json`（含 ★optimization status enum）/ `align_report.json` |
| CSV | per-clock skew/latency/power |
| plot | 可选 skew 直方 / vs ccopt scatter |

字段纪律：`unit/source/budget` 外生（G15；见 12-eval）。

---

## 12. 测试计划

| 层 | 内容 | 验收 |
|---|---|---|
| L0 | 既有 21.2k 测试全绿；★ BST 专项；★ SkewGate 单元 | 绿 |
| L1 | `post_cts_legalize` on → overlap=0；紧 bound+fail → 非零 rc；注入 solver_failed → 非零 rc | T-A1/T-B1/E-CTS-05 |
| L4 | 日常设计 skew/latency/power 趋势 | 看板 |
| L5 | 缺省开关 off 与基线一致；无 G4 不宣称 G19；buffer 后未 LG 禁进 route | G14/G15/G16 |

---

## 13. 里程碑（按周）

| 阶段 | 周 | 交付 | 验收 |
|---|---|---|---|
| P0 | 0–1 | overlap/optimization 状态实锤脚本；JSON 字段 | M0 |
| P1 | 1–3 | incr LG + skew gate + optimization 进成败 CI | **G4** |
| P2 | 3–5 | reason 类型化；iPA 链；多域；BST 测 | M2 |
| P3 | 5–8 | ccopt harness 五套爬坡 | **G19** |
| P4 | G7 后 | useful skew | M4 |
| P5 | 滚动 | NDR/G21；服务 G17 | 纲领 |

PR 切片：CTS-0 台账 → CTS-1 incr LG → CTS-2 成败公式+门禁 → CTS-3 reason 类型化 → CTS-4 BST 测 → CTS-5 ccopt harness。

---

## 14. 未验证 / 负面结论

### 14.1 未验证

| # | 项 |
|---|---|
| 1 | 首轮日常设计 CTS 后真实 overlap 率（H-CTS-1 待杀） |
| 2 | HiGHS 求解失败时的现状行为（回退 or 静默）——`Solution.cc` 分派后无失败路径审计 |
| 3 | `no_op_reason == "target_met"` 在 `:294` 被 stop_reason 覆写的全部分支语义 |
| 4 | Evaluation 阶段（`evaluateClockTree`）的 TimingEngine 更新是否被消费 |
| 5 | 时钟门控（KH-CTS-07）覆盖矩阵 |
| 6 | HiGHS 在真实工艺库的稳定求解率 |
| 7 | vs ccopt 首轮 p90 差距（无 harness 前禁止估数） |

### 14.2 不要重走

- **不要**在 iCTS 内再写一套 Abacus/行扫描 LG（与 iTO 平行债同罪）。
- **不要**把 FastSTA skew 当 G19 金标。
- **不要**默认翻 `enable_analytical_htree=true` 而无 E-CTS-02。
- **不要**宣称「已有 legalize」仅因存在 `LocalLegalization`。
- **不要**无 G7 开 useful skew 生产默认。
- **不要**继续用字符串当 optimization 状态（`:294` 覆写已是腐化点，加新 reason 前先类型化）。

---

## 附录 A · 迁移 checklist

- [ ] M0 台账：CTS 后 overlap 率 + optimization status 分布（全设计）
- [ ] `post_cts_legalize` 开关 + iPL runIncrLG 接线
- [ ] `fail_on_optimization_failure` + `fail_on_skew_miss` 开关 + CI 强制
- [ ] OptStatus enum 类型化（替字符串）
- [ ] HiGHS 失败响亮回退离散
- [ ] BST 专项 gtest
- [ ] 时钟功耗→iPA 链实锤
- [ ] `benchmark/qor/cts/` harness + align_report
- [ ] useful skew（G7 后）

## 附录 B · 决策记录

| ID | 决策 | 被否 |
|---|---|---|
| E-1 | LG 复用 iPL | CTS 自建 LG |
| E-2 | 门禁三开关缺省 false、CI 强制 true | 立刻默认 fail |
| E-3 | optimization 状态进成败（开关式） | 无条件改公式 |
| E-4 | reason 类型化优先于加新 reason | 继续字符串 |
| E-5 | useful skew 排 G7 后 | 现开 |
| E-6 | 保持 62.5k 骨架 | 推倒重写 |
| E-7 | 离散默认，HiGHS 可选 | 强制 HiGHS |
| E-8 | G19 外生真值 | 内建自评 |

## 附录 C · 术语

| 词 | 含义 |
|---|---|
| ccopt / clock_opt | Innovus / ICC2 时钟综合主命令族 |
| H-tree / BST | 对称时钟主干拓扑 / Bound-Skew Tree |
| incr LG | iPL 增量合法化 |
| useful skew | 故意非零 skew 搬运 setup/hold 裕量 |
| no_op（本工具） | Optimization 未做有效编辑的软状态桶——**混合了「target_met 正常停」与「solver_failed 失败」**（FR-CTS-13 拆分对象） |

## 附录 D · 证据摘录（file:line 最小集）

| 断言 | 证据 |
|---|---|
| runCTS 四阶段 void 强转 | `Flow.cc:125-128` |
| 成败公式排除 optimization | `Flow.cc:130`（只 synthesis+instantiation）；`buildCompletedRunStatus` `:80-81` |
| setup/read 失败早退 | `Flow.cc:100-124` |
| Optimization 软失败 | `Optimization.cc:225,241,273`（reason 枚举）；`:294`（覆写）；`:310,319-321`（status no_op） |
| target_met 只打印 | `OptimizationReport.cc:102` |
| HiGHS 缺省关 | `Config.hh:75,182`；`Solution.cc:35-41` 分派 |
| 无 cell LG | `runIncrLG\|runLegalize\|Legalizer` 于 `source/` 零命中；`Router.cc:305-321` legalizePins 仅测试引用 |
| 聚类默认开 | `Config.hh:76,183` |
| 测试体量 | source 62512 / test 21154（`find ... wc -l`） |
| BST 主入口 | `BstPipeline.cc:65-69` |
