<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 27 · iSTA 静态时序分析 · 商业对标方案 · rv2.0

> 文档号：27-rv2.0　　版本：rv2.0（大改）　　里程碑：**双对标 —— PT 签核精度（G7：R²>0.98）× Innovus in-design 调用（又快又准）**
> 体例：`01-ai-doc-conventions-rv1.md`；深度对标：`24-iPL-3d-rv1.0.md`（逐 kernel 走读 + 诚实归因 + 被否方案）
> 商业金标：**PrimeTime（签核收敛准确性）**；**Innovus（物理设计过程中的 in-design 时序调用）**；门禁：**G7 / G17 / G21**（辅 G6/G14/G15）
> 上游：`10-iDB`、`28-iRCX`　下游：`22-iPL`、`25-iTO`、`23-iCTS`、`26-iRT`、`12-evaluation`
> 纲领：`00-ieda-commercial-parity-master-plan-v1.1.md`；Know-how：`03-commercial-knowhow-catalog.md` KH-STA-\*
> 覆盖：`src/operation/iSTA/`（sta/ 21.8k LOC、sdc-cmd/ 3.6k、delay/+cuda 6.5k、api/ ~4.3k，全树 ~45k LOC 含测试）
> 纪律：**文档是假说不是事实**；断言带 `file:line`；未实测写「未验证」；每条理论附能杀死它的对照。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.0–v1.2 | 2026-07-20 | 审计骨架 + LLD 切片 |
| rv1.0 | 2026-07-20 | 体例对齐 01；坐实「无 PBA / 缺省 BFS GBA / 单位注释矛盾 / SI 注释掉 / MCMM 无场景表」；纠偏「增量有实现缺契约」「AOCV 已进传播」 |
| **rv2.0** | **2026-07-21** | **大改（对照 24-iPL-3d-rv1.0.md 的深度与丰富度重写，并把目标显式拆成双对标线）**。核心修订五条：**(1)** rv1.0 把 iSTA 当成「一个引擎缺几个特性」来审——**代码级核实后发现头号结构症结是三套平行时序栈**：真引擎 `ista::TimingEngine`、布局期 `ieval::TimingAPI`（独立 TimingInstanceGraph/TimingWireGraph，`src/evaluation/api/timing_api.hh`）、CTS 私有 fast_sta（`iCTS/source/module/timing/TimingEngine.{hh,cc}`，304 LOC）——iPL 布局期时序**根本不经 iSTA**（§1.3，类比 24 号文档 §1.5 的「复用率≈0%」判定）；**(2)** 新增 **in-design 调用审计**（§1.4，Innovus 对标的核心证据）：iTO 全树 **10 处全量 `updateTiming()` vs 1 处 `incrUpdateTiming()`**，每次优化迭代都是 `resetSdcConstrain+resetGraphData+resetPathData` 全图清光重算（`Sta.cc:2878-2880`），iRT 的 `RTInterface::updateTiming` 函数体大段注释（`RTInterface.cpp:1522+`）——现状调用结构是**批处理**而非 in-design；**(3)** delay 栈逐模型走读（§1.2/§1.5）：坐实「四模型并存但生产硬编一条、`delay_mode` 未外露」「Ceff π-model 迭代存在但从未对拍」「CCS 模板被解析但接收端电容/CCSN 不进生产」「LVF/POCV 零支持」；**(4)** 全文按**双对标线**重组：PT 线 = 签核精度栈（PBA/SI/AOCV·POCV/CCS/CPPR/单位口径 → G7 R²>0.98），Innovus 线 = in-design 调用栈（统一引擎 + dirty-cone 增量 + effort 分级 → 又快又准），§10 拆成两块看板；**(5)** 补齐 24 号文档体例要素：§4.12 模块状态一览（成熟度/复杂度/边界/复用姿势）、§5 双档配置表、§8 调用方契约表、§14 未验证/不要重走/兄弟仓库实测发现。**缺省新特性关闭 → 零回归**的纪律不变。 |

---

## 1. 症结审计（逐 kernel / 逐模块代码走读）

对 `src/operation/iSTA/` 全树（sta/ 21821 LOC + sdc-cmd/ 3639 + delay/·delay-cuda/·propagation-cuda/ 6495 + api/ ~4300）走读后的判定。**前提**：rv2.0 不推翻 rv1.0 的五条坐实结论（无 PBA / 缺省 BFS / 单位矛盾 / SI 死接线 / MCMM 半成品），但把审计深度对齐 24 号文档：逐 kernel 给「现状算法 / 判定 / 缺口」三列，并新增 rv1.0 没有的两个结构级审计（§1.3 三套栈、§1.4 in-design 调用）。

### 1.1 功能形态——完整 GBA 引擎在，PBA/MCMM/SI 未成签核闭环

主流程（`Sta::updateTiming`，`Sta.cc:2873-2943`，实测两个分支均存在）：

```text
ApplySdc(pre) → ConstProp → IdealClock → CombLoopCheck
  → ClockSlewDelay（BFS）/ Slew+Delay（DFS）
  → Levelization → NormalClock → GenClock → ApplySdc(post clock)
  → BuildPropTag → [INTEGRATION_FWD 关时 DataSlewDelay] → DataProp(Fwd BFS|DFS)
  → // StaCrossTalkPropagation()   ← 两处注释掉（Sta.cc:2901、2926）
  → DataProp(IncrFwd) → Analyze → ApplySdc(post) → DataProp(Bwd)
```

| 能力 | 现状 | 证据 | 判定 |
|---|---|---|---|
| GBA 数据传播 | ✓ 缺省 **BFS** | `_propagation_method = PropagationMethod::kBFS`（`Sta.hh:670-671`）；BFS 分派 `StaDataPropagation.cc:686-690` | **成熟 GBA**，非空壳 |
| DFS 备选 | ✓ | `PropagationMethod::kDFS`（`Type.hh:91`）；DFS 管线 `Sta.cc:2887-2908` | 可切换；**两路径数值一致性未验证** |
| CPPR | ✓ 已接线 | `StaAnalyze` 同钟调用 `StaCppr`（`StaAnalyze.cc:261-267`）；公共前缀差分（`StaCppr.cc:84-133`） | 可用；generated/ideal clock 边界未对拍 |
| 路径分析 | ✓ | `StaAnalyze` + `StaSeqPathData`；`getWNS`（`Sta.cc:2176`）/`getTNS`（`Sta.cc:2213`） | 出口经 `FS_TO_NS` 为 ns |
| top-N 路径 | ✓ | `getTopNWorstSeqPaths`（`Sta.cc:2519`，声明 `Sta.hh:552`） | **PBA 候选入口已在**，无路径级重算 |
| **PBA** | ✗ | 全树 `rg PBA\|PathBased\|path_based` **零命中** | **头号精度缺口（G7 主杠杆）** |
| SI / Crosstalk | ⚠️ 写了未进生产 | `StaCrossTalkPropagation`（393 LOC）+ `CrossTalkDelayCalc` 存在；`updateTiming` 两处注释 | **死接线** |
| MCMM | ⚠️ 多库无场景 | `_libs`「different corners」（`Sta.hh:662`）；无 scenario 表 | **半成品** |
| AOCV | ⚠️ | `readAocv`（`Sta.hh:214-215`）；fwd 弧乘 AOCV derate（`StaDataPropagation.cc:428-475`） | 入口+传播在；vs PT 未对拍 |
| derate | ✓ | 8 槽全局 derate 表（`Sta.hh:61` `g_global_derate_num=8`；max/min×clock/data×cell/net）；`setupOcvDerate`（`StaApplySdc.cc:430`，`:711` 接入） | 平面 OCV 齐；**级数 derate（depth-based）无** |
| 增量 | ⚠️ 有实现缺契约 | `StaIncremental`（前/后向锥队列，`StaIncremental.hh:57-66`）；`TimingEngine::incrUpdateTiming`（`TimingEngine.cc:682`，声明 `TimingEngine.hh:254`） | **不是零**；但下游几乎不用（§1.4） |
| SDC | ✓ 约 32 命令 | `sdc-cmd/Cmd*.cc`（create_clock、generated、false_path、MCP、IO delay、derate、units、clock_groups…） | 覆盖表与响亮失败未普查（G14） |
| GPU 传播 | ⚠️ 编译期资产 | `CUDA_PROPAGATION` 开关（`iSTA/CMakeLists.txt:58`）；`StaGPUFwdPropagation` + `propagation-cuda/fwd_propagation.cu`（782 LOC）+ `delay-cuda/calc_rc_timing.cu`（681 LOC） | **缺省 off**；CPU/GPU 一致性未验证（G21 潜在杠杆） |
| AI 延迟校准 | ⚠️ | `AI-inference/AISta.{hh,cc}`：`AICalibratePathDelay`（部署校准路径延迟的 AI 模型） | 存在；**生产路径未接入、精度未验证** |

### 1.2 算法成熟度——逐 kernel 走读（GBA 桶选临界 ≠ PBA；delay 栈「多模型隐式」）

| kernel | 现状算法 | 判定 | 缺口 |
|---|---|---|---|
| `StaFwdPropagationBFS`（`StaDataPropagationBFS.cc:164-223`，275 LOC） | 按 level 队列 BFS；弧上集成 slew+delay（`INTEGRATION_FWD`）；线程池逐 level 并行 | **工业向 GBA 传播** | 无路径 tag、无 path-based 重算 |
| `StaFwdPropagation`（弧，`StaDataPropagation.cc:407-554`） | `arrive += arc_delay`（含 derate/AOCV）；非单态翻沿双数据 | 正确的图传播 | 汇合点由 bucket 保 n-worst，非单路径一致沿 |
| `StaDataBucket::addData`（`StaData.cc:439-445`） | 同 signature 按 `getCompareValue` 排序：max 取大、min 取小 | **经典 GBA 悲观合并** | 重收敛扇出相对 PT-PBA 系统性偏悲观 → G7 主杠杆 |
| `StaVertex::getArriveTime`（`StaVertex.cc:626-630`） | max→`back()`，min→`front()` | 与 bucket 一致的 GBA 读出口 | — |
| `StaCppr`（`StaCppr.cc:84-133`，136 LOC） | launch/capture 路径顶点最长公共前缀 → \|ΔAT\| | 教科书 CRPR，可用 | vs PT 边界（ideal/propagated、generated clock）未验证 |
| `StaAnalyze`（`StaAnalyze.cc:42-71、287-297`，608 LOC） | 时钟边关系 LCM/近似比 + setup/hold 配对 → `StaSeqPathData` | 成熟 | 无 PBA 钩子 |
| **生产 net delay 路径**（`StaDataSlewDelayPropagation.cc:279-302`） | `rc_net->delay(obj, in_slew, output_current, mode, trans)` → Elmore/波形近似；Arnoldi 网附加逐节点 waveform | **波形级 RC 延迟已在生产**（比 rv1.0 印象好） | 模型选择**硬编**，用户不可见不可配 |
| `ElmoreDelayCalc`（1519+748 LOC） | π-model + **Ceff 迭代**（`ElmoreDelayCalc.hh:154-161`：`Ceff = C_near + C_far·(1−exp(−d/(R·C_far)))`）+ Elmore/D2M/ECM/D2MC 四矩法（`ElmoreDelayCalc.hh:658`） | **Ceff 在**，四模型在 | **四模型只在 `StaDump.cc:297-303` 被枚举对拍**；生产无 `delay_mode` 对外契约；Ceff 从未与 PT 对拍 |
| `ReduceDelayCal` / `ArnoldiNet`（896 LOC） | Arnoldi 降阶 + 矩匹配 | 能力在 | 与 Elmore 路径的分工未成文 |
| `WaveformApproximation`（338 LOC） | 波形拟合（输出电流驱动 RC 响应） | 能力在 | 输入是 NLDM 派生波形还是 CCS 电流源——**未核实**，待 §4.5 坐实 |
| Liberty 表 | NLDM 4 表（cell rise/fall + rise/fall transition，`Lib.hh:413`）；**双线性插值**（`solver/Interpolation.hh:36`）；CCS `output_current_template` 被解析（`Lib.hh:1310`） | NLDM 完整、插值正确 | **CCS 接收端电容 / CCSN 噪声不进生产**——signoff 精度栈缺口 |
| `CrossTalkDelayCalc` | two-π 降阶 + 噪声波形叠加（`StaCrossTalkPropagation.cc:72+`） | 有算法 | **生产注释掉**（`Sta.cc:2901/2926`） |
| `AISta::AICalibratePathDelay` | AI 模型校准路径延迟 | 资产 | 未接生产、无 vs PT 增益报告 |

**假说 H1（可杀）**：G7 失败主因是 GBA 重收敛悲观，而非 cell 表插值。
**杀死实验 E-PT-04**：重收敛合成网；GBA vs PT 大误差 → 开 top-N PBA 后 worst_50 MAE 应显著下降；若不降 → 杀 H1，改查 delay/lib/SPEF。

**假说 H2（rv2.0 新增，可杀）**：in-design 慢的主因是「全量重算 × 优化迭代数」，而非单轮传播慢。
**杀死实验 E-INCR-02**：iTO fix_drv 一轮 ECO（≤100 cell 变更）后分别计时全量 `updateTiming()` vs 锥增量；若增量 ≥ 全量 50% 墙钟 → 杀 H2，改查图重置/RC 重建路径（§4.4）。

### 1.3 ★三套平行时序栈——头号结构症结（类比 24 号文档 §1.5「复用率≈0%」）

rv1.0 的隐含前提是「全项目只有一个时序引擎，补特性即可」。**代码级核实：错。至少三套栈并存，且物理设计主路径上 iSTA 本体不是被调得最多的那个：**

| 栈 | 位置 | 规模/形态 | 谁在用 | 判定 |
|---|---|---|---|---|
| ① 真引擎 `ista::TimingEngine` | `iSTA/api/TimingEngine.{hh,cc}`（1972+437 LOC）+ sta/ 内核 21.8k | 完整 GBA 引擎（§1.1 全部能力） | iTO（10 处全量调用）、iNO（`NoApi.cpp:106`）、iPL ExternalAPI（`ExternalAPI.cc:58`）、iRT（名义） | **唯一够格做 signoff 的栈** |
| ② 布局期 `ieval::TimingAPI` | `src/evaluation/api/timing_api.{hh,cc}` + `database/timing_db.hh` + `src/util/init_sta.cc` | **独立图**：`TimingInstanceGraph`/`TimingWireGraph`（`timing_api.hh:27-28`），自有 `updateTiming(net_list, dbu)` / `buildRCTree(routing_type)` / `buildSpefRCTree`（`timing_api.hh:59-70`） | **iPL**（`ExternalAPI.cc:138-144`：布局期时序全部走这里） | **与 ① 数值是否一致无人知道**——布局优化的时序判断和签核读数来自两套图 |
| ③ CTS 私有 fast_sta | `iCTS/source/module/timing/TimingEngine.{hh,cc}`（304 LOC） | 只算 skew/latency 的迷你引擎 | iCTS（`OptimizationPreparation.cc:321` `fast_sta.updateTiming(clock_id)`） | 专用小核，语义窄；但与 ① 的时钟延迟读数**无对拍** |
| ④ iRT 名义接口 | `RTInterface::updateTiming`（`RTInterface.cpp:1522+`） | **函数体大段注释**（含一段被注释的 TimingEngine 初始化 lambda） | 无人（死骨架） | 路由期实际**不做** STA 驱动 |

**量化**：布局期时序决策 100% 走栈 ②；时序优化期 100% 走栈 ①（全量模式）；CTS 期走栈 ③；路由期无时序。**一条 netlist→GDS 流程里，时序语义被四套口径各说各话**——这正是 Innovus「common timing engine」架构要消灭的东西（§3.2-D8、§4.10）。
**诚实归因**：栈 ② 的存在有工程理由——iPL 需要「无 SDC 全图、只按 instance 图增量算 WNS/TNS 代理」的轻量评估，直接驱动 21.8k LOC 的 ista 全量流程太重。但代价是真实的：**布局看到的时序 ≠ 签核看到的时序**，timing-driven placement 的权重可能在对一个错的目标优化（未验证，E-EVAL-01 可杀）。

### 1.4 ★in-design 调用审计——现状是批处理，不是 in-design（Innovus 对标核心证据）

Innovus 的 in-design 时序 = **同一引擎常驻 + effort 分级 + ECO 后只重算受影响锥**。对 iTO/iPL/iCTS/iRT 全树 grep 调用点后的现状统计（代码走读计数，可复现）：

| 调用方 | 全量 `updateTiming()` | 增量 `incrUpdateTiming()` | 形态 |
|---|---|---|---|
| iNO | 1（`NoApi.cpp:106`） | 0 | 每次网表变更后全图重来 |
| iTO fix_setup | 2（init `:43`、process `:78`） | **1**（`SetupOptimizer_process.cpp:94`） | 初始化全量 + 每轮优化全量；**唯一一处增量** |
| iTO fix_drv | 3（init `:43`、check `:69`、process `:72`） | 0 | 每个 DRV 修复轮全量 |
| iTO fix_hold | 3（init `:44`、process `:44`/`:136`） | 0 | 每个 hold 轮全量 |
| iTO builder | 1（`timing_engine_builder.cpp:91`） | 0 | 建引擎时全量 |
| iPL | 不经 iSTA（走栈 ②，§1.3）+ `ExternalAPI.cc:58` 1 处 | 0 | 布局期时序与 iSTA 脱钩 |
| iCTS | 不经 iSTA（走栈 ③） | — | — |
| iRT | 0（`RTInterface::updateTiming` 函数体注释，§1.3-④） | 0 | 死骨架 |
| **合计** | **10** | **1** | **10:1** |

且每次全量调用的语义是「**全图清光重算**」：`updateTiming()` 开头 `resetSdcConstrain(); resetGraphData(); resetPathData();`（`Sta.cc:2878-2880`）——SDC 重施、图数据重置、路径数据清空，然后 17 个 func 整管线重跑。**一次 buffer 插入的代价 = 一次全图签核级传播**。

**与 Innovus 的差距逐项**：

| Innovus in-design 行为 | iEDA 现状 | 缺口落点 |
|---|---|---|
| 引擎常驻内存，ECO 只标 dirty cone | 每次调用全图 reset 重算 | §4.4 dirty-cone 契约 |
| effort 分级：布局期 estimate RC + ideal clock；post-CTS propagated；post-route 真实 SPEF | 无分级概念：iPL 用栈 ② 自造估算，iTO 一律全量全精度 | §5.2 in-design effort 档 |
| 增量延迟计算：变更 net 的 RC 局部重建 | RC 树重建粒度未契约化（`initRcTree/resetRcTree/updateRCTreeInfo` 在，`TimingEngine.hh:225-246`，但谁调用、何时全量未见文） | §4.4 |
| 优化循环内 STA 占墙钟小头 | iTO 每轮全量 → STA 大概率是优化循环墙钟大头（**未验证**，E-INCR-02 量） | §10.2 看板 |
| 同一引擎贯穿，读数自洽 | 三套栈四种口径（§1.3） | §4.10 收敛路线 |

**假说 H3（可杀）**：把 iTO 的 10 处全量调用收敛为「全量×1 + 锥增量×N」后，fix_drv/fix_hold 端到端墙钟应降 ≥3× 且终局 WNS/TNS 不变（ε=1ps）。
**杀死实验 E-INCR-03**：替换后跑 iTO 全流程，若 WNS/TNS 漂移 > 1ps → 增量锥实现有洞（`StaResetPropagation` 清锥范围错），杀「增量可直接替换」的假设，回 §4.4 修锥。

### 1.5 ★精度栈逐项——对 PT signoff 的差距清单（PT 对标核心）

PT 签核收敛时的准确性来自一整套互相咬合的机制。逐项核实 iSTA 差距（✓=有且生产在用，⚠️=有但半残，✗=无）：

| # | PT 机制 | iSTA 现状 | 证据 | 对 slack 的影响方向 | P |
|---|---|---|---|---|---|
| 1 | GBA | ✓ | `Sta.hh:670-671` 缺省 BFS | 基准 | — |
| 2 | **PBA（穷尽/top-N）** | ✗ | 全树零命中 | 重收敛网 GBA 偏悲观 5-15%（文献量级，**未实测**） | P0 |
| 3 | CPPR | ✓ | `StaCppr.cc:84-133` | 去公共路径悲观 | ✓ |
| 4 | **SI（串扰 delta delay/noise）** | ⚠️ 死接线 | `Sta.cc:2901/2926` 注释 | 先进工艺 Agv 对齐可移 slack 数十 ps | P1 |
| 5 | 平面 OCV derate | ✓ | `Sta.hh:61` 8 槽；`StaApplySdc.cc:430/711` | — | ✓ |
| 6 | **AOCV（depth-based derate）** | ⚠️ | 读入+传播在（`StaDataPropagation.cc:428-475`）；无 vs PT 报告 | 深逻辑级数路径 derate 过悲观 | P1 |
| 7 | **POCV/LVF（statistical moments）** | ✗ | `rg lvf\|pocv\|ocv_moments` 于 source/ 零命中（仅 `StaApplySdc` 命中 statistical 字样的注释） | 7nm 以下 signoff 必需；nangate45 量级可缓 | P2 |
| 8 | **CCS 接收端电容 / CCSN** | ✗（解析有、生产无） | `Lib.hh:1310` 解析 output_current 模板；receiver_capacitance/CCSN 不进 delay/slew 计算 | 波形非线性负载下 slew/delay 偏差 | P1 |
| 9 | Ceff 有效电容迭代 | ⚠️ 有未对拍 | `ElmoreDelayCalc.hh:154-161` | 相对总电容法是正确方向；精度未验证 | P1 |
| 10 | delay 模型选择 | ⚠️ 四模型隐式 | `ElmoreDelayCalc.hh:658`；生产硬编、dump 才枚举（`StaDump.cc:297-303`） | 不同模型在长 RC 网上差可达 10%+（未实测） | P1 |
| 11 | NLDM 双线性插值 | ✓ | `solver/Interpolation.hh:36` | 与 PT 同法 | ✓ |
| 12 | 单位/报告口径 | ✗ 混乱 | `StaPathData.hh:66` 注释「ps」vs 全链路 `FS_TO_NS` | 报告/接口错位风险（G15） | P0 |
| 13 | SDC 完备性 | ⚠️ 未普查 | 32 条 Cmd；`set_driving_cell`/`set_load` 在兄弟仓库实测 core dump（§14.3） | 约束误读 → 全链失真 | P0 |
| 14 | MCMM | ⚠️ 无场景表 | `_libs` 多库（`Sta.hh:662`），无 scenario 调度 | 多角 signoff 缺 | P1 |
| 15 | vs PT 对拍 harness | ✗ | 无 `benchmark/qor/sta/` | **G7 不可证** | P0 |

**§1.5 结论**：精度缺口是**结构性的三层**——(a) 算法层：PBA/SI/POCV 缺或死（#2/4/7）；(b) 模型层：CCS 接收端、delay_mode、Ceff 对拍（#8/9/10）；(c) 口径层：单位、SDC、harness（#12/13/15）。rv1.0 只覆盖了 (a)(c) 的一部分，(b) 是 rv2.0 新增战线。

### 1.6 边界 / 回退 / 单位——操作化尚可，单位语义混乱

- **内部时间单位 = fs**：`StaData.hh` 多处 `unit is fs`；宏 `NS_TO_FS`/`FS_TO_NS`（`Type.hh:77-78`，`g_ns2fs=1e6`，`Type.hh:49`）。
- **注释矛盾（坐实）**：`StaClockPair` 成员注释写 `unit is ps`（`StaPathData.hh:66-69`），但 `getArriveTimeNs`/`getSlackNs` 一律 `FS_TO_NS`（`StaPathData.hh:120-134`）；`getWNS` 亦 `FS_TO_NS`（`Sta.cc:2176+`）。**实现按 fs，注释说谎** → G15/报告风险。
- **Elmore 侧混用 PS_TO_NS**：`ElmoreDelayCalc`/`StaVertex` 部分 RC 节点延迟走 ps→ns（如 `StaVertex.cc:898`）——**跨子系统单位链未文档化**。
- **SDC 时间入口**：`convertTimeUnit` + `_time_unit` 缺省 `kNS`；`CmdSetUnits` 可切。
- **回退**：`resetGraphData`/`resetPathData` 全量前必调（`Sta.cc:2878-2880`）；增量靠 `StaResetPropagation` 清锥（`StaIncremental.hh:81+`）。
- **假成功风险**：`updateTiming` 恒 `return 1`（`Sta.cc:2943`）——无结构化 rc 分类（G14）。

### 1.7 死配置 / 死接线 / 假成功点名

1. **`StaCrossTalkPropagation` 注释掉**（`Sta.cc:2901`、`2926`）——SI 算法仓库级存在、签核级不存在。
2. **无 `StaPathBased` / 无 PBA 开关**——`getTopNWorstSeqPaths` 仅服务报告排序。
3. **`_libs` 多角无 scenario 调度**——多 `readLiberty` ≠ MCMM。
4. **单位 API 注释掉**：`getUnit`/`setUnit`/`convertToStaUnit` 注释块（`Sta.hh:601-603`）。
5. **`updateTiming` 成功码恒 1**（`Sta.cc:2943`）。
6. **`RTInterface::updateTiming` 函数体大段注释**（`RTInterface.cpp:1522+`）——iRT 时序接口是死骨架。
7. **`ieval::TimingAPI` 与 iSTA 零对拍**——布局期时序口径与签核口径分家（§1.3-②）。
8. **GPU 传播编译即资产、运行即缺席**——`CUDA_PROPAGATION` 缺省 off，CPU/GPU 一致性无测试。
9. **`AICalibratePathDelay` 未接生产**——AI 校准模型无入口、无增益报告。
10. **`delay_mode` 四模型只活在 `StaDump`**——生产不可配（§1.5-#10）。

### 1.8 症结优先级表（§1 结论摘要）

| ID | 症结 | 证据 | 对标线 | P |
|---|---|---|---|---|
| **S1** | **无 PBA**（GBA 桶合并悲观） | PBA 零命中；`StaData.cc:439-445` | PT | P0 |
| **S2** | **单位注释/实现矛盾 + 报告口径** | `StaPathData.hh:66` vs `FS_TO_NS` | PT | P0 |
| **S3** | **无 vs PT harness → G7 不可证** | 无对齐脚本/schema | PT | P0 |
| **S9** | **三套平行时序栈，口径分家** | §1.3 表；`timing_api.hh:27-28`；iCTS 304 LOC | Innovus | P0 |
| **S10** | **in-design 调用 = 10:1 全量批处理** | §1.4 表；`Sta.cc:2878-2880` | Innovus | P0 |
| S4 | SI 死接线 | `Sta.cc:2901/2926` | PT | P1 |
| S5 | MCMM 无场景表 | `Sta.hh:662` | PT | P1 |
| S6 | 增量契约未文档化 | `TimingEngine.hh:254`；下游 10:1 不用 | Innovus | P1 |
| S7 | SDC 覆盖/响亮未普查 | 32 Cmd；兄弟仓库 core dump 实测（§14.3） | PT | P1 |
| S8 | delay_mode 未外露 + CCS 接收端缺 + Ceff 未对拍 | `StaDump.cc:297-303`；`Lib.hh:1310`；`ElmoreDelayCalc.hh:154-161` | PT | P1 |
| S11 | GPU/AI 两资产闲置 | `iSTA/CMakeLists.txt:58`；`AISta.hh` | 速度 | P2 |
| S12 | POCV/LVF 零支持 | rg 零命中 | PT（远期） | P2 |

**§1 最关键 5 条**：S1、S2、S3（PT 线）+ S9、S10（Innovus 线）。

---

## 2. 需求 FR / NFR / 约束

### 2.1 FR（★ = 相对现状新增）

| ID | 功能 | 现状 | rv2.0 |
|---|---|---|---|
| FR-STA-01 | GBA 全图传播 + setup/hold 分析 | ✓ BFS/DFS | 保留；校准可归因 |
| FR-STA-02 | CPPR | ✓ | 保留；纳入 vs PT 分桶 |
| FR-STA-03 | WNS/TNS/top-N 路径报告 | ✓ | 报告单位统一 ns |
| FR-STA-04 | ★ **top-N PBA**（`StaPathBased`） | ✗ | ★ 缺省关；`path_based_top_n=0` 零回归；穷尽档预留 |
| FR-STA-05 | ★ **vs PT path harness**（JSON+R²+分桶） | ✗ | ★ G7 前置 |
| FR-STA-06 | ★ **MCMM 外挂 ScenarioManager** | ✗ | ★ 缺省单场景=现状 |
| FR-STA-07 | ★ **单位出口纪律** | 混乱 | ★ 内部仍 fs，出口/JSON 一律 ns |
| FR-STA-08 | ★ **SDC 覆盖表 + 未支持响亮失败** | 未普查 | ★ G14；先修 §14.3 的 core dump |
| FR-STA-09 | ★ **增量契约**（dirty net/cone + gtest） | 半有 | ★ 文档化 + API 收口 + 下游切换 |
| FR-STA-10 | ★ **delay_mode 显式**（Elmore/Reduce/Auto） | 隐式 | ★ 缺省=现状行为 |
| FR-STA-11 | ★ **SI live 开关** | 注释掉 | ★ 缺省 off |
| FR-STA-12 | AOCV 表生效报告 | 部分 | 报告 derate 命中率 |
| FR-STA-13 | ★ path group / 分析模式与 PT 对齐导出 | 部分 | ★ harness schema |
| **FR-STA-14** | ★ **InDesignTiming 统一契约**：全量/锥增量/lazy-estimate 三态 API，供 iTO/iPL/iCTS 调用 | ✗（10:1 全量+三套栈） | ★ §4.4，Innovus 线核心 |
| **FR-STA-15** | ★ **in-design effort 档**：estimate-RC+ideal-clock 快档 ⇄ 全精度档可切换 | ✗ | ★ §5.2 |
| **FR-STA-16** | ★ **三套栈收敛**：ieval/iCTS 引擎数值对齐 iSTA 或收敛为同一引擎的轻量模式 | ✗ | ★ §4.10 |
| FR-STA-17 | ★ **CCS 接收端电容进 slew/delay** | 解析有生产无 | ★ 缺省关，对拍后开 |
| FR-STA-18 | ★ POCV/LVF（远期） | ✗ | ★ 仅接口预留（P2） |
| FR-STA-19 | ★ GPU/AI 资产盘点与一致性测试 | 闲置 | ★ 一致性先行，加速后置 |

### 2.2 NFR（可测数字）

| ID | 项 | 指标 | 对标线 |
|---|---|---|---|
| NFR-STA-01 | G7 相关 | 同网表+SPEF+SDC+lib：top-1000 slack **R² > 0.98**；endpoint 集合差 **< 1%** | PT |
| NFR-STA-02 | G7 误差带 | 只收紧；目标 P95\|Δslack\| ≤ 协议 δ（初值 15-30 ps，实测替换） | PT |
| NFR-STA-03 | PBA 单调 | setup：`slack_pba ≥ slack_gba`；hold 对称；违规计入报告 | PT |
| NFR-STA-04 | PBA 成本 | top_n=1000、深度≤50：PBA 墙钟 ≤ 10% 全图 GBA | PT |
| NFR-STA-05 | 增量正确性 | T-F1：脏锥外 endpoint slack 变化 ≤ 1 ps | Innovus |
| **NFR-STA-09** | ★ **增量速度** | ECO ≤100 cell：锥增量墙钟 ≤ 全量 10%；≤1000 cell：≤ 30% | Innovus |
| **NFR-STA-10** | ★ **in-design 端到端** | iTO fix_drv+fix_hold 全流程 STA 墙钟占比 ≤ 30%（现状未测，先量后定） | Innovus |
| **NFR-STA-11** | ★ **引擎一致性** | 同一网表+同一 RC：ieval 快档 vs iSTA GBA 的 endpoint slack **R² ≥ 0.99**（布局期口径对齐） | Innovus |
| NFR-STA-06 | 零回归 | 所有 ★ 开关缺省 off/0 → 与当前二进制路径报告一致（浮点 ε） | 双 |
| NFR-STA-07 | G21 sta 分项 | `updateTiming` 墙钟剖面进 parity JSON；日常设计 ≤ 1.5× PT | PT/速度 |
| NFR-STA-08 | 内存 | 峰值记录；bucket `_n_worst` 可配并报告 | 双 |
| **NFR-STA-12** | ★ GPU 一致性 | 开 `CUDA_PROPAGATION` 后全图 arrive/slack 与 CPU 差 ≤ ε（先一致、再谈加速） | 速度 |

### 2.3 红线约束

- **金标 = PrimeTime（精度）/ Innovus（in-design 行为）**；G17 时序行最终以双方 DEF 经 PT 读数为准——iSTA G7 绿 ≠ 自动 G17 绿。
- **无 G7 背书，不准关闭 G17 时序打平**。
- **缺省新特性关闭 → 零回归**（PBA/SI/MCMM/delay_mode/effort 档切换均显式）。
- 禁止静默吞掉未支持 SDC（G14）。
- 禁止用 WNS 自报「打平」而无外生 PT 对照（G15）。
- **禁止给任何优化器再配一套私有 STA**（§1.3 的反面教材已有两套）；新时序需求一律进 §4.4 契约。
- **禁止用 eval 快档读数做 signoff 判定**；快档只服务优化迭代内部排序（NFR-STA-11 约束其 R²）。

---

## 3. HLD

### 3.1 数据流——单引擎双档（signoff 档 × in-design 档）

```text
                    Liberty / AOCV[/LVF 远期]
                         │
Verilog/iDB ──► Netlist ──► BuildGraph ──► StaGraph（常驻）
SPEF/iRCX ──► RcNet ──────────────────────────┘        │
SDC ──► SdcConstrain ──► ApplySdc (多阶段)              │
                         │                             │
         ClockProp / Levelize / PropTag                │
                         │                             │
              ┌──────────┴──────────┐                  │
              │  DataProp BFS/DFS   │  ← GBA（缺省）    │
              │  (bucket max/min)   │                  │
              └──────────┬──────────┘                  │
                         │  [opt] CrossTalk  ← 缺省 off │
                         ▼                             │
                    StaAnalyze + CPPR                  │
                         │                             │
   ┌─────────────────────┼─────────────────────────────┤
   │ signoff 档（PT 线）  │        in-design 档（Innovus 线）│
   ▼                     ▼                              ▼
getWNS/TNS          reportPath                 ★InDesignTiming 契约（§4.4）
[runPathBased]      [run_scenarios]              ├ updateTiming()        全量（建图后 1 次）
[PBA 穷尽档]        [SI on]                       ├ updateTimingIncremental(dirty)  锥重算
[CCS/Ceff 对拍]                                  └ estimateSlack(effort)  快档评估
   │                                                   ▲            ▲
   ▼                                                   │            │
PathExport JSON ──► classify_diff.py ↔ PT JSON    iTO(10→1+N)  iPL(eval 对齐)  iCTS(fast_sta 收敛)
   │
   ▼
G7 看板（§10.1）                            in-design 看板（§10.2）
```

**核心架构判断**：PT 线与 Innovus 线**共用同一个 StaGraph、同一份 RC、同一条传播管线**——差别只在「调用的粒度（全图 vs 锥）」和「生效的精度配置（§5 双档表）」。这与 Innovus「common timing engine, 多 effort」完全同构；也直接否定「为快而再写一套轻量 STA」的路线（§1.3 已有两套教训）。

### 3.2 关键设计决策（含被否）

| ID | 决策 | 被否方案 | 理由 |
|---|---|---|---|
| D1 | **先 harness 再大改算法** | 先重写传播核 | 无 R² 则无法归因（杀 H1 需要数据） |
| D2 | **top-N PBA 外挂，不替换 GBA** | 全图 path-tag PBA | 成本与增量复杂度；复用 `getTopNWorstSeqPaths`；穷尽档仅作 signoff 终验预留 |
| D3 | **MCMM 外挂 ScenarioManager** | 内核一次传播多角混用 | `_libs` 已多库；混角危险 |
| D4 | **内部保持 fs，对外一律 ns** | 全局改 ps | 改动面爆炸；只修注释+出口 |
| D5 | **SI 开关缺省 off** | 强制进 `updateTiming` | 零回归；待 SPEF 耦合与 T-E1 |
| D6 | **增量与 PBA 并行演进** | 等 PBA 完成再做增量 | 下游 iTO 已依赖 `incrUpdateTiming`（虽只 1 处） |
| D7 | **delay_mode 显式可配，缺省=现状** | 静默改默认模型 | 防 CI 漂移 |
| **D8** | **三套栈收敛方向 = 同一引擎的轻量模式，不是删掉 eval** | (a) iPL 切到全量 iSTA；(b) 维持现状双轨 | (a) 太重（21.8k LOC 全管线跑布局内循环不现实）；(b) 口径分家是 §1.3 症结。折中：eval 快档必须过 NFR-STA-11 一致性门禁（R²≥0.99），长期把 eval 的图换成 iSTA 的子图视图 |
| **D9** | **in-design 加速先做增量契约，后做 GPU/AI** | 先上 GPU 传播 | 10:1 的调用结构不改，单轮再快也被调用次数吃掉；且 GPU 一致性未验证（NFR-STA-12 前置） |
| **D10** | **CCS 接收端/POCV 排 P1/P2，不挡 G7 主线** | 先补全精度栈再对拍 | nangate45 量级 NLDM+Ceff 已可能够到 R²=0.98（假说，E-PT-02/03 可杀）；CCS 是为先进工艺预留 |

---

## 4. LLD · 模块分解

### 4.0 落点

```text
src/operation/iSTA/source/module/
  sta/
    StaPathBased.hh/.cc        ← ★新建 PBA（FR-STA-04）
    StaScenario.hh/.cc         ← ★新建 MCMM（FR-STA-06）
    StaPathExport.hh/.cc       ← ★新建 JSON 对齐（FR-STA-05）
    StaInDesign.hh/.cc         ← ★新建 in-design 契约（FR-STA-14，包 StaIncremental）
    Sta.cc / StaAnalyze.cc / StaReport.cc / StaPathData.hh  ← 接线/单位
    StaCrossTalkPropagation.cc ← ★开关接入 updateTiming（FR-STA-11）
  delay/
    DelayMode.hh               ← ★枚举+工厂（FR-STA-10）
api/
  TimingEngine.{hh,cc}         ← ★incrUpdateTiming 契约化 + effort 档入口
benchmark/qor/sta/             ← ★ harness
docs/ai/attachments/ista-sdc-coverage.md  ← ★
```

### 4.1 ALG · GBA 传播（已有，保留）

**真实现状签名**

- `StaFwdPropagationBFS::operator()(StaGraph*)`（`StaDataPropagationBFS.cc:164`）
- `StaDataPropagation::operator()(StaGraph*)` 按 `PropagationMethod` 分派（`StaDataPropagation.cc:686-690`）

```text
[已有] updateTiming():
  resetSdcConstrain(); resetGraphData(); resetPathData()   // Sta.cc:2878-2880
  pipeline = (method==BFS) ? bfs_funcs : dfs_funcs          // Sta.cc:2889-2930，17 func
  for f in pipeline: graph.exec(f)   // Crosstalk 槽位缺省跳过
  return 1                          // ★ 改结构化 rc（§7）

[已有] FwdBFS(graph):
  seed level==1 && (slew_prop || port)
  while queue:
    parallel for v in queue: v.exec(FwdBFS)   // 逐 level 线程池
    // arc: slew+delay; arrive += derated_arc_delay (含 AOCV, :428-475)
    // sink bucket: keep n-worst critical by max/min (StaData.cc:439-445)
```

- **复杂度**：O((V+E)·W·T⁻¹)，W=bucket n-worst，T=线程数；单次全量 = signoff 档成本基准。
- **边界**：const/loop_disable/mpw/非 prop_tag 跳过；终点算 check arc。
- **复用**：禁止平行重写传播核；PBA **Composition** 在路径层；GPU 路径（`StaGPUFwdPropagation`）只在 NFR-STA-12 一致性达标后启用。

### 4.2 ALG · CPPR（已有）

**现状**：`StaCppr::operator()(StaClock*)`（`StaCppr.cc:84`）；`StaAnalyze` 同钟启用（`StaAnalyze.cc:261-267`）。

```text
[已有] CPPR(launch, capture):
  common = longest_common_prefix(launch_path_vertexes, capture_path_vertexes)
  if !common: return 0
  cppr_fs = abs(AT_launch(common) - AT_capture(common))
```

- **边界**：异钟依赖 async group 过滤；ideal vs propagated 边界**未验证**。
- **复用**：PBA 重算 arrive 时**复用** `path->get_cppr()`，不改 CPPR 核。

### 4.3 ALG · ★PBA（`StaPathBased`）（FR-STA-04，PT 线主杠杆）

```cpp
// StaPathBased.hh（★新增）
struct PathBasedResult {
  StaSeqPathData* gba_path = nullptr;
  int64_t slack_gba_fs = 0, slack_pba_fs = 0;
  int64_t arrive_pba_fs = 0, require_pba_fs = 0;
  bool monotonic_ok = true;
  std::vector<std::string> arc_trace;
};

class StaPathBased {
 public:
  explicit StaPathBased(Sta* sta);
  // top_n==0 → 空，行为=现状；top_n<0 → 穷尽档（全部违例路径，仅 signoff 终验）
  std::vector<PathBasedResult> run(AnalysisMode mode, int top_n);
  PathBasedResult recompute(StaSeqPathData* path);
};
```

```text
★ PBA.run(mode, N):
  [已有] updateTiming() 若尚未
  paths = (N>0) ? getTopNWorstSeqPaths(mode, N) : all_violating(mode)   // Sta.cc:2519
  for p in paths:
    arrive = 0
    for arc_data in p.getPathDelayData() 按 launch→capture 序:
      // 取该 path 实际 rise/fall 弧延迟，禁止再读 vertex max/min bucket
      arrive += arc_delay_fs(arc_data)
    require = p.getRequireTime()                 // 含 constraint/uncertainty/derate
    slack_pba = f_setup_hold(require, arrive, p.get_cppr())   // CPPR 复用 §4.2
    slack_gba = p.getSlack()
    mono = (mode==kMax) ? slack_pba>=slack_gba : slack_pba<=slack_min_gba
    emit PathBasedResult                          // arc_trace 供归因
```

| 条件 | 行为 |
|---|---|
| `path_based_top_n==0` / 开关 off | 不跑，零开销 |
| 缺弧延迟 | LOG_ERROR，`monotonic_ok=false`，跳过该条 |
| 性能 | O(N·L)；N=1000、L=50 ≪ 全图 GBA（NFR-STA-04） |

**接入**：`Sta::runPathBased`；`report_timing -path_based`；配置 `path_based_top_n` 默认 **0**。
**复用姿势**：新建模块 + Composition 现有 path/CPPR；**禁止**改 bucket 语义冒充 PBA（§14.2）。
**与 PT 穷尽 PBA 的关系**：PT signoff 对违例路径做穷尽 PBA；本设计 N<0 档预留同语义，但 G7 验收用 top-1000（成本/精度平衡点，E-PT-04 定）。

### 4.4 ALG · ★InDesignTiming 契约（FR-STA-14/15，Innovus 线核心）

**现状**：`TimingEngine::incrUpdateTiming`（`TimingEngine.cc:682`）+ `StaIncremental` 前/后向锥队列（`StaIncremental.hh:57-66`）+ `StaResetPropagation` 清锥（`StaIncremental.hh:81-99`）。**实现在、契约无、下游 10:1 绕开它**（§1.4）。

```cpp
// StaInDesign.hh（★新增；薄封套，不动 StaIncremental 内核）
enum class TimingEffort { kEstimate, kIncremental, kFull };
//  kEstimate   : 不触发传播；用既有 AT/RT + 局部 RC 重估（布局期口径, §5.2 档 A）
//  kIncremental: dirty cone 前/后向重传（ECO 循环内, 档 B）
//  kFull       : 现状 updateTiming()（建图后/阶段性, 档 C）

class StaInDesign {
 public:
  void markDirtyNets(std::vector<Net*>);          // ECO 方声明变更
  void markDirtyInstances(std::vector<Instance*>);//  sizing/move/buffer
  unsigned apply(TimingEffort);                    // 返回受影响 vertex 数（观测用）
  // 契约: kEstimate 后读 slack = 上偏差代理(禁 signoff); kIncremental 后锥外 slack ≤1ps(NFR-STA-05)
};
```

**增量锥语义（据 `StaIncremental` 现状收紧）**：

```text
★ apply(kIncremental):
  for v in dirty:  insertFwdQueue(v); insertBwdQueue(v)     // 已有 API
  applyFwdQueue(): level 序锥内重传 slew→delay→AT（复用 §4.1 弧算子）
  applyBwdQueue(): 锥内重传 RT
  Analyze 只重跑受影响 clock pair 的 path（★需新增：现状 StaAnalyze 全图）
  记录: n_dirty, n_cone_vertex, wall_ms → in-design 看板（§10.2）
```

**下游切换表**（§1.4 的 10 处全量调用逐一归置）：

| 调用点 | 现状 | 目标 |
|---|---|---|
| `timing_engine_builder.cpp:91` / 各 `*_init.cpp:43` | 全量 | 保留 kFull（建图后必须 1 次） |
| `SetupOptimizer_process.cpp:78` | 全量 | ★ kIncremental（`:94` 已有先例，扩到全循环） |
| `ViolationOptimizer.cpp:72` / `_check.cpp:69` | 全量 | ★ kIncremental；check 阶段可 kEstimate |
| `HoldOptimizer_process.cpp:44/:136` | 全量 | ★ kIncremental |
| `NoApi.cpp:106` | 全量 | ★ kIncremental（fanout 修复是局部变更） |

**RC 局部重建**：`initRcTree(net)`/`resetRcTree(net)`/`updateRCTreeInfo(net)`（`TimingEngine.hh:225-246`）已有 per-net 粒度——契约补「dirty net 的 RC 树先局部重建再入锥」，禁全量 `initRcTree()`。
**复用姿势**：封套 + 契约；内核 `StaIncremental` 不改算法，只补 `StaAnalyze` 的锥级重跑。

### 4.5 ALG · ★Delay 栈收口（FR-STA-10/17，PT 线模型层）

**现状四模型**（`ElmoreDelayCalc.hh:658` `DelayMethod::{kElmore,kD2M,kECM,kD2MC}`）只在 `StaDump.cc:297-303` 被枚举对拍，生产硬编 `StaDataSlewDelayPropagation.cc:279` 一条路径。

1. **`delay_mode` 显式**（FR-STA-10）：`enum class DelayMode { kLegacy, kElmore, kD2M, kECM, kD2MC, kAuto }`，缺省 `kLegacy`=当前硬编行为（零回归）；每次 `updateTiming` 打日志。`kAuto` = 按 RC 网规模/扇出选模型（规则待 E-PT-02/03 数据定，**禁止**拍脑袋定规则）。
2. **Ceff 对拍**（§1.5-#9）：`ElmoreDelayCalc.hh:154-161` 的 π-model Ceff 迭代 vs PT 同网 slack 分桶（harness `net_delay` 桶）；若 Ceff 反而更差 → 查 π 参数提取。
3. **CCS 接收端电容**（FR-STA-17，P1）：`Lib.hh:1310` 已解析 output_current 模板——核实 `WaveformApproximation` 的输入是 NLDM 派生还是 CCS 电流源（**未核实**）；把 receiver_capacitance（C1/C2 分段）接入 Ceff 迭代替代单一 pin cap。缺省关。
4. **AI 校准定位**（`AICalibratePathDelay`）：定位为「系统残差学习」——harness 分桶后，对稳定残差桶（如 net_delay 桶）用 AI 模型学习 GBA→PT 的 Δ，作为报告修正层而非传播层改动。**禁区**：AI 修正不得进入 signoff 判定，只作预测（§14.2）。

### 4.6 ALG · ★SI 接线（FR-STA-11）

```text
★ if cfg.enable_crosstalk:
     pipeline.insert(after FwdProp, StaCrossTalkPropagation)   // Sta.cc:2901/2926 两个槽位
   else:
     // 保持现状注释行为
```

T-E1：只扰动一条耦合 C，目标路径 slack 必变。缺省 **off**。前置：iRCX SPEF 的耦合电容（CC）真实存在且 `RcNet` 承载——**SPEF CC 解析是否落地未验证**，先测 T-E1 再谈精度。

### 4.7 ALG · ★MCMM ScenarioManager（FR-STA-06）

```cpp
struct StaScenario { std::string name, mode, corner; std::vector<std::string> libs;
                     std::string sdc; AnalysisMode analysis_mode; };
// runAll: 串行 reset→readLiberty子集→readSdc→updateTiming→收集 WNS/TNS/endpoint
// mergeWorst: 同 endpoint 取 worst；报告 worst_scenario
```

- **缺省**：无 scenario 文件 → 单次现状流程。
- **禁止**：一次传播混用未声明多角弧。

### 4.8 ALG · ★POCV/LVF（FR-STA-18，远期 P2）

仅接口预留：delay/slew 数据通路现在传标量（fs）；POCV 需要每个弧带 (μ, σ) 或 LVF moments。**不在 G7 主线**；nangate45 对拍用平面 OCV + AOCV 足够（D10）。落点记录：`StaArc` delay 数据 + `StaData` 的 arrive/slew 容器是未来扩 moments 的两个接缝。

### 4.9 ALG · ★PathExport + PT harness（FR-STA-05）

```text
★ export_paths(tool=ista|pt) → JSON
  unit: "ns" 必填
  key: endpoint+startpoint+clock+edge；冲突用 pins Jaccard≥0.8
★ classify_diff.py → align_report.json
  r2_slack, endpoint_coverage_diff_pct, MAE/P95, buckets[...]
```

分桶：`reconvergence_suspect` / `clock_path_cppr` / `cell_delay` / `net_delay` / `sdc_mismatch` / `unmatched`。
**复用**：优先 `reportTimingData` / `getTopNWorstSeqPaths` 写 JSON，避免解析文本 rpt。

### 4.10 ALG · ★三套栈收敛路线（FR-STA-16，Innovus 线结构修复）

| 栈 | 短期（G7 期） | 中期 | 长期 |
|---|---|---|---|
| ② ieval::TimingAPI | **保留但上锁**：加 NFR-STA-11 一致性门禁——同一网表+RC 下与 iSTA GBA 对拍 R²≥0.99，进 CI | eval 的图改为 iSTA StaGraph 的**只读子图视图**（同一份 AT/RT，estimate 档只换 RC 来源） | 栈 ② 消亡，只剩「iSTA 引擎 + kEstimate 档」 |
| ③ iCTS fast_sta | 保留（专用 skew 小核，语义窄） | 时钟 latency/skew 与 iSTA propagated clock 读数对拍进 CI | 收敛为 iSTA 的 clock-only 查询接口 |
| ④ iRT 死骨架 | 删除或实装二选一（**禁止**留着注释尸体冒充能力） | post-route 用 iSTA 全量+SPEF（已有 readSpef 路径） | — |

**纪律**：收敛期内，任何新时序需求（新优化器、新评估项）**必须**进 §4.4 契约或 iSTA API，禁止第五套栈（§2.3 红线）。

### 4.11 ALG · 单位与报告（最小改，FR-STA-07）

| 文件 | 动作 |
|---|---|
| `StaPathData.hh:66-69` | 注释改为 `internal unit: fs` |
| `StaReport.cc` 等 | 打印强制 ns 语义（已有 `FS_TO_NS`，补后缀/字段） |
| `StaVertex.cc:898` 等 Elmore ps→ns 链 | 文档化跨子系统单位链（哪段 ps、哪段 fs、何处转换） |
| JSON | `"unit":"ns"` |
| gtest | 1000 ps = 1e6 fs → `getSlackNs()≈1.0`（E-UNIT-01） |

### 4.12 模块状态一览（成熟度 / 复杂度 / 边界 / 复用姿势）

| 模块 | 现状成熟度 | 主复杂度 | 关键边界 | 复用姿势（现状→目标） |
|---|---|---|---|---|
| `StaFwdPropagationBFS` | 成熟（线程池 GBA） | O((V+E)·W/T) | 非 prop_tag 跳过；终点 check arc | 保留；GPU 路径待 NFR-STA-12 |
| `StaDataBucket` GBA 合并 | 成熟 | O(W log W)/vertex | n-worst 截断丢路径 → PBA 候选池下限 | 保留；**禁止调乐观冒充 PBA** |
| `StaCppr`/`StaAnalyze` | 成熟 | O(paths·depth) | 异钟 async 过滤；ideal/propagated 边界未验证 | 保留+对拍 |
| 生产 net delay（`StaDataSlewDelayPropagation`） | 成熟但隐式 | O(pins·RC nodes) | rc_net 空→0 延迟（理想网）；Arnoldi 波形仅附加 | ★ delay_mode 显式（§4.5） |
| `ElmoreDelayCalc`（Ceff/四模型） | 能力在、对拍无 | O(RC nodes) | `_is_update_ceff` 缓存位；`n<=1` 退化 | ★ Ceff/CCS 对拍后定默认（§4.5） |
| `ReduceDelayCal`/`ArnoldiNet` | 能力在 | O(RC nodes·q)（q=降阶数） | 与 Elmore 分工未成文 | ★ kAuto 规则数据源 |
| `StaCrossTalk*` | 死接线 | O(nets·aggressors) | SPEF CC 落地未验证 | ★开关接入（§4.6） |
| `StaIncremental` | 有实现、契约无 | O(cone) | 清锥范围=正确性命门（E-INCR-03） | ★ §4.4 封套契约化 |
| `StaPathBased` | 不存在 | O(N·L) | top_n=0 零回归；缺弧 LOG_ERROR | ★新建（§4.3） |
| `StaInDesign` | 不存在 | 封套 O(dirty) | kEstimate 禁 signoff | ★新建（§4.4） |
| `StaScenario` | 不存在 | O(scenarios·全量) | 禁混角 | ★新建（§4.7） |
| ieval::TimingAPI | 成熟但口径分家 | 自有图 O(V+E) | 无 SDC 全图；与 iSTA 零对拍 | ★上锁→子图视图（§4.10） |
| iCTS fast_sta | 专用小核（304 LOC） | O(clock tree) | 只 skew/latency | 保留+对拍（§4.10） |
| iRT `RTInterface::updateTiming` | 死骨架 | — | 函数体注释 | ★删除或实装（§4.10） |
| GPU 传播（`StaGPUFwdPropagation`+2 cu 模块） | 编译期资产 | O((V+E)/GPU) | CPU/GPU 一致性无测试 | ★一致性先行（NFR-STA-12） |
| `AICalibratePathDelay` | 闲置 | O(paths) 推理 | 禁进 signoff 判定 | ★残差修正层定位（§4.5-4） |
| PT harness | 不存在 | O(paths) | schema 先行 | ★新建（§4.9） |
| SDC Cmd×32 | 有 | — | 未支持命令禁假成功；core dump 待修（§14.3） | ★覆盖表+响亮（FR-STA-08） |

---

## 5. 配置 / 双档表 / 多轮渐进

### 5.1 可配表（缺省 = 现状零回归）

| 参数 | 缺省 | 含义 |
|---|---|---|
| `propagation_method` | `kBFS` | 与 `Sta.hh:670-671` 一致 |
| `path_based_analysis` | **false** | 关 PBA |
| `path_based_top_n` | **0** | 0=不跑；<0=穷尽档（仅 signoff 终验） |
| `enable_crosstalk` | **false** | SI off |
| `delay_mode` | **`kLegacy`** | 显式后仍映射现状硬编行为 |
| `scenario_file` | 空 | 空=单场景 |
| `report_unit` | `ns` | 出口单位 |
| `n_worst_path_per_clock` | 现有 | 报告/PBA 候选池 |
| `aocv_enable` | 随是否 `readAocv` | — |
| ★ `in_design_effort` | `kFull` | §4.4 三态；缺省 kFull = 现状逐字行为 |
| ★ `enable_ccs_receiver` | **false** | CCS 接收端电容（FR-STA-17） |

### 5.2 ★双档表（rv2.0 核心新增：同一引擎的两套精度配置）

**档 A/B/C = in-design effort（Innovus 线）**：

| 档 | name | RC 来源 | clock | 传播粒度 | 用途 | 禁 |
|---|---|---|---|---|---|---|
| A | estimate | 布局估算（eval/steiner） | ideal | 不传播（读既有 AT/RT + 局部重估） | 布局/优化循环内部排序 | signoff |
| B | incremental | 局部重建（dirty nets） | 现状 | 锥重传 | ECO 循环（iTO 各 optimizer） | — |
| C | full | 全量 SPEF/估算 | 现状 | 全图 | 建图后、阶段验收、报告 | — |

**轮 0-5 = signoff 努力档（PT 线，在档 C 上叠加）**：

| 轮 | name | PBA N | SI | MCMM | 目的 |
|---|---|---|---|---|---|
| 0 | gba-baseline | 0 | off | 单 | M0 基线 / 零回归 |
| 1 | gba-calibrate | 0 | off | 单 | delay/SDC/单位校准 |
| 2 | pba-top100 | 100 | off | 单 | 验证单调与 MAE↓ |
| 3 | pba-top1000 | 1000 | off | 单 | G7 爬坡 |
| 4 | si-on | 1000 | on | 单 | KH-STA-04 |
| 5 | mcmm | 1000 | cfg | 多场景 | G7 逐角 |

**触发规则**：优化循环内一律档 B；循环间（进入下一阶段前）档 C 一次；档 A 只出现在 iPL/eval 内循环。单轮模式（仅 `updateTiming`）= 档 C 轮 0，**零回归**。

---

## 6. Cost / 指标分解

禁止单一标量掩盖。每次 harness / `updateTiming` / `apply(effort)` 独立记录：

| 维 | 指标 | 来源 | 对标线 |
|---|---|---|---|
| QoR-GBA | WNS/TNS（ns）、#neg endpoints | `getWNS`/`getTNS`（`Sta.cc:2176/2213`） | PT |
| QoR-PBA | slack_pba、Δ(pba−gba)、mono 违规数 | ★ PathBased | PT |
| 相关 | R²、MAE、P95\|Δ\|、endpoint 覆盖差 | ★ align_report | PT |
| 分桶 | reconvergence/cppr/cell/net/sdc/unmatched 计数 | ★ classify_diff | PT |
| 延迟栈 | cell_delay_sum / net_delay_sum | `getCellAndNetDelayOfArriveTime`（`StaPathData.cc:128`） | PT |
| SI | si_delta_ns（可关） | Crosstalk | PT |
| ★ 增量 | n_dirty、n_cone_vertex、cone/全图 vertex 比、增量墙钟 | ★ StaInDesign（§4.4） | Innovus |
| ★ 调用剖面 | 每调用点 effort 档 × 次数 × 墙钟（§1.4 表的实时版） | ★ 契约打点 | Innovus |
| 性能 | `updateTiming` 全量墙钟/内存；PBA 附加墙钟 | Stats 日志（`Sta.cc:2939-2942`） | 双 |
| 场景 | per-scenario WNS + worst_scenario | ★ MCMM | PT |

---

## 7. 状态机 / 命令语义

```text
              readLiberty/readDesign/readSdc/readSpef[/readAocv]
                                    │
                                    ▼
                     link / BuildGraph / ApplySdc
                                    │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
              updateTiming   ★apply(kIncremental)  updateClockTiming
               (档C 全量重置)   (档B 锥队列)          (仅钟)
                    │               │
                    ▼               ▼
              Analyze/CPPR    锥内 AT/RT + ★锥级 Analyze
                    │
        report_timing / getWNS|TNS / [runPathBased] / [run_scenarios]

   档A（estimate）: 不进此图——读既有 AT/RT + 局部 RC 重估，禁写回 StaGraph
```

| 命令/API | 成功 | 失败 rc（目标） |
|---|---|---|
| `updateTiming` | 图完成；现恒 1（`Sta.cc:2943`） | ★ 分期：前置缺失 → 非 0 + LOG_ERROR（G14） |
| `incrUpdateTiming`/`apply(kIncremental)` | 锥应用完，返回受影响 vertex 数 | 未 build graph → 响亮失败 |
| `apply(kEstimate)` | 返回代理 slack | **禁**在 signoff 路径调用（断言） |
| `runPathBased` | 返回结果向量 | top_n=0 → 空成功 |
| `run_scenarios` | 每场景报告 | scenario 文件非法 → 非 0 |
| 未支持 SDC | — | **禁止**当成功（★；含 §14.3 core dump 修复） |

`resetGraphData` / `resetPathData`（`Sta.hh:577-578`）：全量前清理；增量用 `StaResetPropagation`（清锥范围 = 正确性命门，E-INCR-03 验证）。

---

## 8. 跨工具 Cascade——★调用方契约表（rv2.0 重写）

| 调用方 | 现状（§1.3/§1.4） | 目标契约 | 单位/口径 |
|---|---|---|---|
| iPL | 走 ieval 栈 ②（`ExternalAPI.cc:138-144`），不经 iSTA | eval 快档 = 档 A，过 NFR-STA-11（R²≥0.99）门禁；中期改 iSTA 子图视图 | slack ns；档 A 读数禁出优化循环 |
| iTO | 10 处全量 + 1 处增量 | §4.4 切换表：init 档 C ×1 + 循环档 B ×N；check 可档 A | slack ns；dirty 集合由 ECO 方声明 |
| iCTS | fast_sta 栈 ③（`OptimizationPreparation.cc:321`） | 保留小核 + 与 iSTA propagated clock 读数对拍进 CI；长期收敛 clock-only 查询 | latency/skew ns |
| iRT | `RTInterface::updateTiming` 死骨架 | 删除或实装；post-route 走档 C + readSpef | — |
| iRCX → iSTA | SPEF（含 CC）→ `RcNet` | SPEF CC 落地验证是 SI 前置（§4.6） | — |
| iSTA → evaluation/G17 | 无 harness | PathExport JSON → align_report；**PT 读双方 DEF 为最终真值** | ns |
| iSTA → G21 | 无剖面 | `updateTiming`/增量/每档墙钟进 parity JSON | s |

**闭环触发**：iTO 优化后 dirty nets → 档 B 锥重算 → slack 刷新 → 否决/接受 ECO；布局 eval 口径漂移超 NFR-STA-11 → 禁用档 A，回退档 B；harness 分桶 `net_delay` 占比超阈 → iRCX/SPEF 侧归因。

---

## 9. 商业 Know-how 映射（引用 `03`）

| KH-ID | 含义 | 本工具落点 |
|---|---|---|
| KH-STA-01 | GBA 筛查 + PBA 终审 | §4.3 FR-STA-04；§10 M2 |
| KH-STA-02 | CPPR/CRPR | §4.2；E-PT-05 |
| KH-STA-03 | AOCV 深度 derate | `StaDataPropagation.cc:428+`；FR-STA-12 |
| KH-STA-04 | SI delta 进 slack | §4.6；T-E1 |
| KH-STA-05 | 增量锥失效 | §4.4；T-F1 |
| KH-STA-06 | path group 分治 | 报告/`CmdGroupPath`；harness 分组 |
| ★ KH-STA-07 | **in-design effort 分级**（estimate/incremental/full 三态） | §4.4/§5.2；Innovus 线核心 |
| ★ KH-STA-08 | **common timing engine**（签核与优化同一引擎） | §1.3/§4.10；三套栈收敛 |
| ★ KH-STA-09 | **ECO 后 lazy 增量**（dirty cone，非全图） | §4.4；NFR-STA-09 |
| KH-X-01 | 同一真值源闭环 | G7 先于 G17；§8 |
| KH-X-04 | 响亮失败 | FR-STA-08；§7 |
| KH-X-08 | 不确定度带 | parity ε；§10 |
| KH-EV-01/02 | 并排金参考、逐指标转绿 | §10 看板；G17 独立于 G7 |

---

## 10. 商业对照看板 + 演进

### 10.1 PT 精度看板（每次 harness 必填）

| 指标 | iSTA | PrimeTime | Δ | 门槛 | 门禁 |
|---|---|---|---|---|---|
| WNS (ns) | | | | ≤10 ps 或协议 % | G6/G7 |
| TNS (ns) | | | | ≤5% | G7 |
| #endpoints | | | % | <1% | **G7** |
| R²(slack) top-1000 | | 1.0 | — | **>0.98** | **G7** |
| MAE / P95\|Δslack\| | | — | ns | 只收紧 | G7 |
| 分桶占比 | | — | — | reconvergence↓ after PBA | — |
| `updateTiming` 墙钟 | | | × | ≤1.5×（日常） | **G21** |
| 峰值内存 | | | × | 记录 | G21 |

### 10.2 ★Innovus in-design 看板（每次 iTO 全流程必填）

| 指标 | 现状（未测先空） | 目标 | 门禁 |
|---|---|---|---|
| 全量 vs 增量调用比 | 10:1（静态代码统计） | init 1 次全量 + 循环全增量 | NFR-STA-09 |
| ECO ≤100 cell 增量墙钟 / 全量 | — | ≤ 10% | NFR-STA-09 |
| iTO 全流程 STA 墙钟占比 | —（先量） | ≤ 30% | NFR-STA-10 |
| 增量后锥外 slack 漂移 | — | ≤ 1 ps | NFR-STA-05（T-F1） |
| eval 档 A vs iSTA GBA 的 R² | 未验证 | ≥ 0.99 | **NFR-STA-11** |
| iTO 终局 WNS/TNS（增量版 vs 全量版） | — | Δ ≤ 1 ps | E-INCR-03 |

### 10.3 对照实验（能杀死假说）

| ID | 假说 | 方法 | 杀死条件 |
|---|---|---|---|
| E-PT-01 | 端到端可相关 | 五套 daily align | 无稳定 R² 产物 → harness 失败 |
| E-PT-02 | 差距在 net | 理想网/零网延迟 | R² 不升 → 杀「网延迟主因」 |
| E-PT-03 | 差距在 cell | 理想单元延迟 | R² 不升 → 杀「cell 主因」 |
| E-PT-04 | **需要 PBA** | 重收敛：GBA→PBA | PBA 后 worst_50 MAE **不降** → 杀 H1 |
| E-PT-05 | CPPR 对齐 | 开关 CPPR vs PT | 误差变化无预期 → 查 CPPR 边界 |
| E-PT-06 | SDC 响亮 | 注入未支持命令 | 仍 rc 成功 → G14 FAIL |
| E-PT-07 | SI 响应 | 耦合扰动 | slack 不变 → SI 未 live |
| E-PT-08 | MCMM 口径 | 2×2 场景 | worst 汇总与 PT 不一致 → 查合并规则 |
| E-UNIT-01 | 内部为 fs | 构造 1e6 fs | `getSlackNs`≠1 → 单位链坏 |
| E-INCR-01 | 锥外不变 | T-F1 | 远端 slack 变 → 增量坏 |
| ★ E-INCR-02 | 慢在 10:1 全量 | 单 ECO 计时全量 vs 锥 | 增量 ≥ 全量 50% → 杀 H2，改查图重置/RC 重建 |
| ★ E-INCR-03 | 增量可替换全量 | iTO 全流程增量版 vs 全量版 | 终局 WNS/TNS 漂移 >1ps → 锥实现有洞，杀 H3 |
| ★ E-EVAL-01 | eval 栈口径可用 | 同网表同 RC 对拍 eval vs iSTA | R²<0.99 → 档 A 禁用于时序驱动布局权重 |
| ★ E-GPU-01 | GPU 传播一致 | CUDA on/off 全图对拍 | 超 ε → GPU 路径禁用直至修复 |

### 10.4 演进 M0–M5

| 里程碑 | 目标 | 退出门禁 |
|---|---|---|
| **M0 先量** | harness+schema+至少 1 设计 align_report；单位注释修正；§1.4 调用剖面实测化（打点） | 有 R² 数字；E-UNIT-01；in-design 看板基线行 |
| **M1 可信** | delay/SDC/单位校准；GBA R²≥0.90（无 PBA）；SDC core dump 修复（§14.3） | 分桶稳定；G14 SDC 清单起步 |
| **M2 主算法** | top-N PBA；双值报告；E-PT-04 通过 | 重收敛设计 R²≥0.95；NFR-STA-03 |
| **M3 打平** | 五套 daily **G7**（R²>0.98，endpoint<1%） | **G7**；允许启动 G17 时序行评审 |
| **M4 in-design** | §4.4 契约落地 + iTO 10→1+N 切换；增量 NFR-STA-05/09；eval 对拍 E-EVAL-01 | **NFR-STA-09/10/11**；E-INCR-03 |
| **M5 纵深** | MCMM 逐角、SI live、CCS 接收端、G21 sta 分项、GPU 一致性 | G7 MCMM；NFR-STA-07/12；**G21** 剖面 |

---

## 11. Exhibit

| 档 | 产物 | 内容 |
|---|---|---|
| text | `report_timing` / summary | GBA 表；可选 PBA 列 |
| CSV | `sta_endpoints.csv` | endpoint, clock, slack_gba_ns, slack_pba_ns, delta, scenario |
| ★ CSV | `sta_incr_trace.csv` | call_site, effort, n_dirty, n_cone_vertex, wall_ms（§4.4 打点，in-design 看板数据源） |
| JSON | `ista_paths.json` / `pt_paths.json` / `align_report.json` | schema 见 §4.9；G7 机读 |
| ★ JSON | `indesign_profile.json` | §1.4 调用剖面实测版（每调用点 effort×次数×墙钟） |
| plot（可选） | Δslack 直方图、分桶饼图 | 管理者一眼归因 |

调试：`ISTA_DEBUG=1` 时可 dump arc_trace（PBA）与 Crosstalk noise 摘要、锥传播边界顶点清单（查 E-INCR-01/03 用）。

---

## 12. 测试计划

| 层 | 内容 | 验收 |
|---|---|---|
| **L0 gtest** | 现有 `StaTest`/`TimingEngineTest`/`DelayTest`；★ T-A1 diamond 重收敛 PBA 单调；T-A2 top-100 mono；T-A3 top_n=0 零回归；E-UNIT-01；T-F1 增量锥外不变；★ T-I1 `apply(kEstimate)` 禁 signoff 断言；★ T-D1 delay_mode 各模型同网 slack 排序稳定 | CI |
| **L1 集成** | 小设计 full `updateTiming` + report JSON round-trip；★ ECO 单 buffer 插入 → 档 B 锥重算 → 与档 C 全量对拍（Δ≤1ps） | 文件存在且 schema 过；增量对拍绿 |
| **L4 基准** | `benchmark/qor/sta/` 五套 daily vs PT；★ iTO 全流程增量版 vs 全量版（E-INCR-03） | 产出两块看板行 |
| **L5 红线** | 缺省开关 off 与基线二进制对比；未支持 SDC 不得假绿；无 G7 不得宣称 G17 时序打平；★ 档 A 读数不得出现在任何 signoff 报告 | G14/G15/G7 纪律 |

---

## 13. 里程碑（按周）

| 阶段 | 周 | 交付物 | 验收 |
|---|---|---|---|
| **P0** | 1 | 本文档 rv2.0；单位注释 PR；harness 骨架 + 1 设计首轮 R²；调用剖面打点（§4.4 只打点不切换） | M0 |
| **P1** | 2–3 | SDC 覆盖表 + core dump 修复；delay_mode 日志；GBA 校准实验 E-PT-02/03 | M1 轨迹 |
| **P2** | 3–5 | `StaPathBased` + 双值报告 + T-A\*；E-PT-04 | M2 |
| **P3** | 5–7 | 五套 G7 爬坡；PathExport 稳定 | M3 / **G7** |
| **P4** | 6–8 | `StaInDesign` 契约 + iTO 切换（10→1+N）+ T-F1/E-INCR-03；eval 对拍 E-EVAL-01 | M4 / NFR-STA-09/10/11 |
| **P5** | 8–10 | ScenarioManager；SI 开关+T-E1；G21 sta 剖面；GPU 一致性 | M5 |
| **P6** | 滚动 | CCS 接收端；与 iPL/iTO 契约联调；服务 G17 时序行（PT 真值）；POCV 预研 | G17 依赖满足 |

PR 切片建议：PR-STA-0 harness → PR-STA-1 单位 → PR-STA-2 PBA → PR-STA-3 增量契约 → PR-STA-4 iTO 切换 → PR-STA-5 SDC → PR-STA-6 MCMM → PR-STA-7 SI/delay_mode → PR-STA-8 eval 对拍。

---

## 14. 未验证 / 负面结论

### 14.1 未验证（禁止写成事实）

- 当前任意设计 vs PT 的真实 R² / MAE（**M0 前未知**）。
- BFS vs DFS 两管线数值是否一致。
- AOCV 表在典型工艺上与 PT 的逐级 derate 一致性。
- `StaCppr` 在 propagated/ideal/generated clock 全组合下与 PT 差。
- SPEF 耦合电容是否真实落地到 `RcNet`（SI 前置）。
- 打开 Crosstalk 是否数值稳定、是否拖垮运行时。
- `_n_worst` 默认对大设计内存与 QoR 的敏感度。
- GPU 传播路径（`CUDA_PROPAGATION`）与 CPU 一致性。
- **`WaveformApproximation` 的输入波形是 NLDM 派生还是 CCS 电流源**（§4.5-3 前置）。
- **ieval 栈与 iSTA 的数值差**（E-EVAL-01 前，档 A 口径一律视为未背书）。
- **iTO 全流程 STA 墙钟占比现状**（NFR-STA-10 的基线，M0 打点产出）。
- Ceff 迭代（`ElmoreDelayCalc.hh:154-161`）相对总电容法/PT 的精度增益。

### 14.2 负面 / 不要重走

| 项 | 结论 |
|---|---|
| 把 GBA bucket 调得「更乐观」冒充 PBA | **禁止**——破坏 GBA 悲观上界语义；PBA 必须路径级重算（§4.3） |
| 无 harness 先改 Elmore/Arnoldi 默认 | **禁止**——无法归因；先 E-PT-02/03 |
| 一次传播混多角 lib | **禁止**——用 ScenarioManager 串行 |
| 默认打开 SI/PBA | **禁止**——违反零回归；显式开关 |
| 用 iSTA WNS 自证 G17 | **禁止**——纲领要求 PT 真值源 |
| 全局把内部单位从 fs 改成 ps | **不推荐**——出口统一 ns + 修注释即可（D4） |
| 平行重写传播核「为了 PBA」 | **禁止**——Composition 路径层 |
| ★ 为求快再写一套轻量 STA | **禁止**——§1.3 已有 eval/iCTS 两套平行栈的教训；方向是收敛不是再加（D8） |
| ★ 不动 10:1 调用结构、先上 GPU 加速单轮传播 | **禁止**——调用次数才是大头（H2/D9）；且 GPU 一致性未验证 |
| ★ 用 eval 档 A 读数做 signoff 判定或写进对外报告 | **禁止**——档 A 只服务优化循环内部排序（§2.3/§7 断言） |
| ★ AI 校准进 signoff 判定 | **禁止**——`AICalibratePathDelay` 只作残差预测层（§4.5-4） |

### 14.3 兄弟仓库（iEDA-3D fork）实测发现——本树待复核

以下结论在 `HS-3D_Problem/thirdparty/iEDA-3D` 的实测中坐实（见其项目记忆与 24 号文档 §14.7），**本树（iEDA.ai）代码同源但行号/行为需复核，未验证前不当事实用**：

| 发现 | 兄弟仓库证据 | 本树复核动作 |
|---|---|---|
| `set_driving_cell` / `set_load` 让 iSTA core dump | bisect 确证；`bp_fe_top_3d.sdc` 因此未用 | P1：gtest 复现 → 修 → 进 SDC 覆盖表（FR-STA-08 第一项） |
| `remove_from_collection` 未实现 | 同 SDC 流程发现 | 进覆盖表「未支持响亮失败」清单 |
| `set_propagated_clock` 曾是静默 no-op | 已修（CTS 时钟不进时序的根因） | 复核本树 `CmdSetPropagatedClock.cc` 是否含修复 |
| 巨型扇出网（reset 704 pins、icache 1035 pins）主导 WNS 且布局器救不了 | bp_fe 实测 slack −584ns @1.8ns | M0 harness 设计选型时避开「坏 SDC 好引擎」的冤案 |
| 时钟 mesh 有环 vs iSTA 树结构 → CTS+RCX+STA 死循环 | 真因 breakLoop 零进展，已修 | iCTS 联调（P6）时复核 comb loop 检测路径 |

### 14.4 相对 rv1.0 文档的纠偏

- 「iSTA 是一个引擎缺几个特性」→ **三套平行栈 + 10:1 批处理调用**才是结构症结（§1.3/§1.4），精度特性缺口（§1.5）排在其后。
- 「增量缺契约」→ 补充：**契约缺只是 half，下游 10:1 绕开才是全图**；光文档化契约不切换调用点 = 纸面修复，故 P4 专列「iTO 切换」。
- delay 栈「多模型并存」→ 细化为「生产硬编一条 + dump 才枚举 + Ceff 有而未对拍 + CCS 接收端缺」（§1.5-#8/9/10）。
- GPU/AI 两资产 rv1.0 完全未提 → 列入 S11，但纪律是「一致性先行、加速后置」（D9/NFR-STA-12）。

---

## 附录 A · 术语

| 术语 | 含义 |
|---|---|
| GBA | Graph-Based Analysis：顶点桶 max/min 合并 |
| PBA | Path-Based Analysis：单路径一致沿延迟累加 |
| CPPR/CRPR | 公共时钟路径悲观去除 |
| MCMM | Multi-Corner Multi-Mode |
| AOCV | Advanced OCV：按逻辑深度 derate |
| POCV/LVF | 参数化 OCV / Liberty Variation Format（statistical moments） |
| CCS/CCSN | Composite Current Source（驱动电流模型/噪声模型） |
| Ceff | 有效电容：π-model 下迭代求等效负载（`ElmoreDelayCalc.hh:154-161`） |
| ★ in-design STA | 物理实现循环内嵌的时序分析（相对 stand-alone signoff STA） |
| ★ effort 档 A/B/C | estimate / incremental / full 三态（§5.2） |
| ★ dirty cone | ECO 变更网/instance 的前向+后向影响锥（`StaIncremental`） |
| G7/G17/G21 | 纲领门禁：STA 相关 / 实现 QoR 打平 / 性能打平 |

## 附录 B · 决策记录（被否列必填）

| 决策 | 选 | 被否 | 杀死实验 |
|---|---|---|---|
| PBA 范围 | top-N 外挂 | 全图 path-tag | E-PT-04 成本/收益 |
| 单位策略 | 内 fs 外 ns | 全局改 ps | E-UNIT-01 |
| MCMM | 外挂串行 | 内核混角 | E-PT-08 |
| SI | 缺省 off | 强制 on | E-PT-07 + 回归 |
| 真值 | PT 金标 | 仅 iSTA 自评 | 纲领 G17 |
| 传播缺省 | 保持 BFS | 改 DFS 默认 | 零回归对比 |
| ★ 三套栈方向 | 收敛为同一引擎的 effort 档 | 删 eval / 维持双轨 / 再写轻量栈 | E-EVAL-01 |
| ★ in-design 加速次序 | 先增量契约后 GPU/AI | 先 GPU 单轮加速 | E-INCR-02 |
| ★ CCS/POCV 优先级 | P1/P2，不挡 G7 | 先补全再对拍 | E-PT-02/03（若 cell/net 桶非主因则提前） |
| ★ iRT 死骨架 | 删除或实装 | 留注释尸体 | 代码审查 |

## 附录 C · Checklist（开 PR 前）

- [ ] ★ 开关缺省 off/0，附零回归证据
- [ ] 断言含 `file:line` 或实测；否则标未验证
- [ ] 假说附杀死实验 ID
- [ ] 指标多维写入 JSON，非单一 WNS
- [ ] 触及 STA 数值时跑 align_report
- [ ] 不宣称 G17 时序打平除非 G7 已绿且 PT 协议满足
- [ ] ★ 新增时序调用点必须走 §4.4 契约（不得直接 `updateTiming()` 裸调，不得新造时序栈）
- [ ] ★ 档 A（estimate）读数未出现在任何 signoff 产物
- [ ] ★ 增量 PR 必附 E-INCR-01/03 对拍数据

## 附录 D · 关键证据速查

| 结论 | file:line |
|---|---|
| 缺省 BFS | `Sta.hh:670-671` |
| BFS 分派 | `StaDataPropagation.cc:686-690` |
| BFS 主循环 | `StaDataPropagationBFS.cc:164-223` |
| GBA 桶比较 | `StaData.cc:439-445` |
| Crosstalk 注释 | `Sta.cc:2901`、`2926` |
| 全量重置三连 | `Sta.cc:2878-2880` |
| updateTiming 恒 return 1 | `Sta.cc:2943` |
| getWNS/getTNS | `Sta.cc:2176`、`Sta.cc:2213` |
| top-N 候选入口 | `Sta.cc:2519`（`Sta.hh:552`） |
| 单位宏 fs | `Type.hh:49/77-78` |
| 注释写 ps | `StaPathData.hh:66-69` |
| CPPR | `StaCppr.cc:84-133`；`StaAnalyze.cc:261-267` |
| 增量 API | `TimingEngine.hh:254`；`TimingEngine.cc:682`；`StaIncremental.hh:57-66` |
| RC per-net 接口 | `TimingEngine.hh:225-246` |
| 生产 net delay 调用 | `StaDataSlewDelayPropagation.cc:279-302` |
| 四模型只在 dump | `StaDump.cc:297-303`；枚举 `ElmoreDelayCalc.hh:658` |
| Ceff 迭代 | `ElmoreDelayCalc.hh:154-161` |
| NLDM 4 表 / 双线性插值 | `Lib.hh:413`；`solver/Interpolation.hh:36` |
| CCS 模板解析 | `Lib.hh:1310` |
| derate 8 槽 | `Sta.hh:61`；`StaApplySdc.cc:430/711` |
| AOCV 进传播 | `StaDataPropagation.cc:428-475`；`Sta.hh:214-215` |
| PBA 零命中 | `rg` over `src/operation/iSTA` |
| 多角库容器 | `Sta.hh:662` |
| ★ eval 独立图 | `evaluation/api/timing_api.hh:27-28,59-70` |
| ★ iPL 走 eval 不走 iSTA | `iPL/api/external_api/ExternalAPI.cc:138-144` |
| ★ iCTS fast_sta | `iCTS/source/module/timing/TimingEngine.{hh,cc}`（304 LOC）；调用 `OptimizationPreparation.cc:321` |
| ★ iRT 死骨架 | `iRT/interface/RTInterface.cpp:1522+` |
| ★ iTO 10:1 全量：增量 | §1.4 表（`NoApi.cpp:106`；`timing_engine_builder.cpp:91`；`SetupOptimizer_{init:43,process:78}`；`ViolationOptimizer{:72,_init:43,_check:69}`；`HoldOptimizer_{init:44,process:44/136}` vs `SetupOptimizer_process.cpp:94`） |
| ★ GPU 资产 | `iSTA/CMakeLists.txt:58`；`StaGPUFwdPropagation`；`propagation-cuda/fwd_propagation.cu`；`delay-cuda/calc_rc_timing.cu` |
| ★ AI 校准资产 | `AI-inference/AISta.hh`（`AICalibratePathDelay`） |
