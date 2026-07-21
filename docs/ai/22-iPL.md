<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 22 · iPL 布局 · 商业对标优化方案 · rv2.0

> 文档号：22-rv2.0　　版本：rv2.0（大改）　　里程碑：**双对标 —— place_opt QoR 精度线（G2/G3/G17：HPWL/overlap/timing）× 性能线（G21：墙钟/内存/调用模式）**
> 体例：`01-ai-doc-conventions-rv1.md`；深度对标：`27-iSTA-rv2.0.md`（逐 kernel 走读 + 双看板 + 诚实归因 + 被否方案）
> 商业金标：**Innovus place_opt / ICC2 place_opt**（QoR 与调用模式）；门禁：**G2 / G3 / G14 / G17 / G21**
> 上游：`20-iFP`（die/rows/宏约束）、`21-iNO`（netlist）、`27-iSTA`（timing）　下游：`23-iCTS`、`26-iRT`、`25-iTO`
> 纲领：`00-ieda-commercial-parity-master-plan-v1.1.md`；Know-how：`03-commercial-knowhow-catalog.md` KH-PL-\*
> 覆盖：`src/operation/iPL/`（31.3k LOC）：`api/PLAPI.{hh,cc}`、`source/module/{global_placer/electrostatic_placer,legalizer,detail_placer,initial_placer,macro_placer,buffer,evaluator,grid_manager,topology_manager,checker,filler,post_global_placer,wrapper}`、`platform/.../ipl_io.cpp`、`tcl_ipl`
> 纪律：**文档是假说不是事实**；断言带 `file:line`；未实测写「未验证」；每条理论附能杀死它的对照。

---

## 0. 变更记录

| 版本 | 日期 | 修订人 | 说明 |
|---|---|---|---|
| v1.0–v1.2 | 2026-07-20 | parity | 骨架：宏空壳、RandomPlace、isSTAStarted=false、LG 不上抛 |
| rv1.0 / v2.0 | 2026-07-20 | parity | 体例对齐；坐实宏假成功、Random 默认、发散只打日志 |
| rv1.1 / v3.0 | 2026-07-21 | parity | 大改：对 `PLAPI.cc`（1087）全文、`NesterovPlace.cc`（2055）关键段、`runFlow` 全链、`ipl_io.cpp`、`tcl_ipl` 重读后重写。核心修订五条，两条推翻 v2.0 判定：(1) `runFlow` 全链为 `runGP → (buffer/spread 可选) → runLG → if(isSTAStarted()) runPostGP() else { /*runDP 注释*/ } → writeBack`，而 `isSTAStarted()` 在 `PLAPI.cc:842-846` 硬编码 `return false`——**runPostGP 永不可达、else 分支 runDP 被注释，详细布局在默认 flow 中整体死亡**；(2) `NesterovPlace.cc:1360-1390` 存在 `_nes_config.isOptCongestion()` 门控的 **LUT-RUDY 拥塞驱动**（内置 RUDY 环，opt-in）；(3) `isSTAStarted` 死在 `PLAPI` 包装层；(4) `runFlow` 内 `runLG()` 的 bool 返回值被丢弃；(5) `runFlow` 还挂了两段隐蔽流程（buffer/spread）。 |
| **rv2.0 / v4.0** | **2026-07-21** | parity | **大改（对照 27-iSTA-rv2.0.md 的深度与体例重写，目标显式拆成双对标线）**。核心修订六条：**(1)** rv1.1 把 iPL 当成「一组功能缺口」来审——**代码级核实后发现头号结构症结是调用层面的三处死链（宏假成功 D1、DP 在 runFlow 死亡 D2、守卫恒 false D4）+ 发散静默（D-fail）**，这些不是特性缺失而是**工程死结**——Nesterov 内核（2055 LOC）本身成熟，但被错误的流程包装杀死了；**(2)** 新增**主算法对比审计**（§1.2 核心算法判定表）：commercial place_opt 核心能力 = (a) mixed-size macro+std 协同（力导向+SA+通道）+ (b) 解析初值（QP/B2B）+ (c) timing-driven 净权重注入 + (d) congestion-driven density inflation + (e) 多轮 DP refinement **默认跑**——iPL 差距主要在 (a) 空壳 + (b) 资产不存在 + (c)(d) 守卫死 + (e) 默认不跑，**不是 Nesterov 算法本身弱**（§1.2/§1.5）；**(3)** 全文按**双对标线**重组：place_opt QoR 线 = 宏成功/HPWL/timing/congestion（G2/G3/G17），性能线 = 墙钟/内存/调用模式适合优化循环（G21），§10 拆成两块看板；**(4)** 补齐 27 号文档体例要素：§1.5 与 place_opt 差距逐项（算法/实现/调用三层归因）、§4.13 模块状态一览（成熟度/复杂度/边界/复用姿势）、§5 双档配置表（effort 分级）、§10.3 对照实验框架（E-PL-NN 编号，能杀死假说）、§14 未验证/不要重走/平行实现嫌疑；**(5)** 新增**性能剖面审计**（§1.6）：现状无墙钟/内存打点、无 per-stage breakdown、无增量调用接口——对比 Innovus place_opt 可被 iTO 循环内高频调用（ECO 后局部 re-place），iPL 只有全量批处理模式；**(6)** 明确**算法 vs 工程归因**（§1.7 症结优先级表）：P0 是假成功修复（D1/D2/D4，纯工程，零算法工作量）+ DP 回流（D2，~3.2k LOC 成熟算子从死代码变生产），P1 是宏算法（MP force+SA）+ QP 初值（依赖 11-solver），时序/拥塞驱动（守卫修复后验证收益）——**最高性价比修复在 P0**。**缺省新特性关闭 → 零回归**的纪律不变。 |

---

## 1. 症结审计（逐 kernel / 逐模块代码走读）

对 `src/operation/iPL/` 全树（api/ 含 `PLAPI.{hh,cc}` 1087+372 LOC、source/module/ 各子模块、platform/data_manager/ipl_io.cpp、tcl_ipl 层）走读后的判定。**前提**：rv2.0 不推翻 rv1.1 的核心发现（假成功、DP 死路径、守卫恒 false），但把审计深度对齐 27-iSTA-rv2.0.md：逐 kernel 给「现状算法 / 判定 / 缺口」三列，并新增 rv1.1 没有的**主算法对比**（§1.2 与 place_opt 核心能力逐项）与**调用模式审计**（§1.6 批处理 vs in-design）。

### 1.1 功能「假成功 / 死路径」——三处死链 + 一条死守卫（工程症结）

| # | 死链 | 证据 | 后果 |
|---|---|---|---|
| D1 | **宏布局空壳+假成功** | `macro_placer/` 仅一行 readme；`PLAPI.cc:517-522` runMP 全注释；`ipl_io.cpp:170-181` 全注释 `return true`；`runFlow` 首行 `// runMP();`（`:389`） | 有宏设计的 GP 在无宏约束下铺 std cell（G3/G14） |
| D2 | **DP 在默认 flow 死亡** | `PLAPI.cc:421-425`：`if(isSTAStarted()) runPostGP(); else { // runDP(); }` + `:842-846` 守卫恒 false | 五算子（NFSpread 1117 / InstanceSwap 853 / BinOpt 460 / RowOpt 341 / LocalReorder ≈3.2k LOC）**在 `run_placer` 里整体不执行**；sky130_gcd 回归（`run_iPL.tcl:40`）即此链 |
| D3 | **runFlow 丢 LG 返回值** | `PLAPI.cc:411` `runLG();` 不接 bool | LG 失败在默认 flow 静默（v2.0 只记了 TCL 层 `:279` 一带） |
| D4 | **时序守卫硬编码 false** | `PLAPI.cc:842-846`（真实查询被注释）；`ExternalAPI.cc:40-43` 是活的 | timing-driven placement 整条死；`runPostGP`/`destroyTimingEval`/TDP 报告全殉葬 |

**runFlow 实测形状**（`PLAPI.cc:387-458`）：
```
// runMP();
runGP();                        // RandomPlace + Nesterov（PLAPI.cc:523-530）
if (cfg.buffer.isMaxLengthOpt())      runBufferInsertion();     // 隐蔽段 1
if (cfg.dp.isEnableNetworkflow())     runNetworkFlowSpread();   // 隐蔽段 2
runLG();                        // ← bool 丢弃（D3）
if (isSTAStarted()) runPostGP(); else { /* runDP(); // remove DP */ }   // D2/D4
reportPLInfo(); writeBackSourceDataBase();
```

### 1.2 ★主算法对比——commercial place_opt 核心能力 vs iPL 现状（对标线核心）

**place_opt 的核心算法能力**（Innovus/ICC2，文献 + 行业标准流程）：

| # | 能力 | 算法形态 | 意图 | 是否必需 |
|---|---|---|---|---|
| A | **Mixed-size macro+std 协同** | force-directed initial + overlap resolve + SA/MIP polish + channel-aware | 宏与 std cell 同时优化，通道约束 | 有宏设计必需（G3） |
| B | **解析初值** | Quadratic Placement（QP）/ B2B partition | 比 random 低 15-30% 初始 HPWL（文献量级） | 中大设计强需（G2） |
| C | **Electrostatic GP** | Nesterov / ePlace 类（预条件梯度 + eDensity + WA + overflow ramp） | 全局展开的工业标准内核 | 必需 |
| D | **Timing-driven 净权重** | crit path → 增大净权重 → WA 拉近 | post-CTS 时序闭环的主杠杆 | timing 关键路径必需（G17） |
| E | **Congestion-driven density** | GR/RUDY → bin density inflation | 避免局部拥塞 hotspot | 密集设计强需（G17） |
| F | **Legalization** | Abacus/Tetris 类（位移最小 DP） | GP→LG 质量守恒 | 必需 |
| G | **Detail placement 多算子** | cell swap / local reorder / bin optimization / spread | LG→DP 再降 5-15% HPWL（文献），**默认跑** | 商业布局器标配 |
| H | **多轮渐进 effort 档** | 低 effort 快速铺开 → 高 effort 精化 | 速度/质量平衡 | 生产必需（G21） |

**iPL 现状对照**（逐能力判定）：

| # | iPL 现状 | 算法判定 | 差距归因层 | 证据 |
|---|---|---|---|---|
| A | **空壳+假成功** | 无 macro 算法；有宏时 GP 在无宏约束下铺 std | **P0 算法缺** | `macro_placer/` 一行 readme；`PLAPI.cc:517-522` / `ipl_io.cpp:170-181` 全注释恒 true |
| B | **RandomPlace 生产默认** | 教科书最低档；QP 资产不存在（`src/solver/qudratic_programming` 空目录 TBD） | **P1 资产缺** | `PLAPI.cc:526` `:525` CenterPlace 注释；11-solver §1.1 |
| C | **Nesterov 成熟（2055 LOC）** | 预条件 Nesterov + eDensity（DCT 862）+ WA（536）+ overflow ramp —— **工业级内核，不弱** | **算法 OK** | `NesterovPlace.cc` 主循环；`evaluator/` DCT/WA 成熟 |
| D | **守卫殉葬** | `TimingAnnotation` 基建在（395 LOC）；`isSTAStarted()` 恒 false 杀死整条 TDP 路径 | **P0 工程死结** | `PLAPI.cc:842-846` 硬编码；`ExternalAPI.cc:40-43` 真查询被屏蔽 |
| E | **内置 RUDY opt-in** | `NesterovPlace.cc:1360-1390` **LUT-RUDY 存在**（evalRouteDem → fastGaussianBlur → evalRouteUtil → updateWirelengthForceDirect），`isOptCongestion` 门控 | **实现在，默认化待评估** | `:1360-1390`；GR 版注释 TODO `:1383-1387` |
| F | **Abacus 成熟（597）** | `ieda_solver::LGMethodCreator` 位移最小 DP | **算法 OK** | `Legalizer.cc:32`；bool 返回被丢（工程） |
| G | **五算子就绪但默认 flow 死** | NFSpread 1117 / InstanceSwap 853 / BinOpt 460 / RowOpt 341 / LocalReorder ≈3.2k —— **全仓最完整 DP，但 runFlow 不跑** | **P0 工程死结** | `detail_placer/` 各目录；`PLAPI.cc:421-425` 守卫+注释杀死；独立命令 `run_detail_placer` 可达（`ipl_io.cpp:226`） |
| H | **单趟 / 无 effort 分级** | 配置项散落；无 IterParam 包；无快/精档切换 | **P1 工程** | 无 `PlacerIterParam` 类；§5 待建 |

**§1.2 结论（诚实归因）**：
- **算法层不是主要差距**：Nesterov GP（C）与 Legalizer（F）是成熟的工业内核，**不弱于 place_opt 同类算法**；DP 五算子（G）已就绪且体量完整（~3.2k LOC）。
- **P0 差距在工程死结**：宏假成功（A 接线缺）、DP 默认不跑（G 被"守卫+注释"杀死）、timing 守卫恒 false（D）——**三处死链不是算法问题，是流程包装错误**。
- **P1 差距在算法资产缺**：QP 初值（B 资产不存在，需先建）、宏算法（A 空壳，需力导向+SA）。
- **主杠杆不同于主纲 G2 印象**：G2「对齐 Innovus GP 质量」的瓶颈**不是 Nesterov 不够好**，而是 (1) 宏处理为零（A）、(2) 初值用 random（B）、(3) DP 不跑（G）三者联合导致 HPWL 偏高——**修 P0 工程死结（零算法工作量）可能比重写 GP 更快见效**（假说 H1，E-PL-01 可杀）。

### 1.3 算法「内核不弱，杠杆缺」——逐 kernel 判定（细化 §1.2）

| kernel | LOC | 现状算法 | 判定 |
|---|---|---|---|
| `initial_placer/RandomPlace` | — | 随机撒点 | **生产默认**（`PLAPI.cc:526`），教科书最低档 |
| `initial_placer/CenterPlace` | — | 中心聚拢 | 存在，`:525` 注释禁用 |
| `src/solver/qudratic_programming` | **0（TBD 空目录，见 11-solver）** | 无 | **v2.0 设想的 QP 资产不存在**——FR-PL-03 须重新立项（先建 QP 再接线） |
| `NesterovPlace` 主循环 | 2055 | 预条件 Nesterov + eDensity + WA + overflow ramp | **成熟工业内核**；`_is_diverged` 多处置位，发散处 LOG_ERROR 后 return（约 `:1260`），**失败不离开 iPL** |
| `evaluator/density/dct_process/DCT` | 862 | 真 DCT/FFT Poisson | 成熟（2D 家底，3D fork 重写过它——见 24-iPL-3d §1.5） |
| `evaluator/wirelength/WAWirelengthGradient` | 536 | WA 值+梯度 | 成熟 |
| `NesterovPlace` 拥塞段 | `:1360-1390` | **LUT-RUDY 拥塞驱动**（isOptCongestion 门控，iter≥200 起每 10 轮） | **真实存在但 opt-in**；GR 版注释 TODO；不经 iRT map、不经 eval 模块 |
| `evaluator/timing/TimingAnnotation` | 395 | 时序标注基建 | **守卫殉葬品**（D4） |
| `Legalizer`（Abacus） | 597 | `ieda_solver::LGMethodCreator`（`Legalizer.cc:32`）位移最小 DP | 成熟；bool 到 runFlow/TCL 两层被丢 |
| `detail_placer` 五算子 | ≈3.2k | NFSpread/BinOpt/RowOpt/LocalReorder/InstanceSwap | **全仓最完整 DP**；默认 flow 不跑（D2）；`run_detail_placer` 单独命令可达（`ipl_io.cpp:226`） |
| `buffer/BufferInserter` | 617 | 布局内插 buffer（isMaxLengthOpt 门控） | 隐蔽流程段；与 iNO/iTO 的 buffer 职责重叠未裁定 |
| `macro_placer` | 一行 readme | 无 | **空壳+假成功**（D1） |

**四项缺失的工业杠杆**（对标 place_opt）：① 宏 force+SA/mixed-size（空壳）；② 解析初值（QP 资产不存在，须先建）；③ timing-driven 净权重（守卫死，基建 TimingAnnotation 在）；④ DP 回默认 flow（五算子就绪，纯粹接线问题——**性价比最高的修复**）。

### 1.3 代码「操作化」——边界有，失败语义三层漏

- **发散**：`_is_diverged` → LOG_ERROR + return（`NesterovPlace.cc:~1260`）；`runGP` 为 void（`PLAPI.cc:523`），runFlow 无从知晓 → 静默成功（KH-X-04 违反）。
- **LG**：`runLG` 返 bool + LOG_ERROR_IF（`PLAPI.cc:532-537`）；runFlow 丢弃（`:411`）；TCL 不查（v2.0 已记）。
- **MP**：IO 恒 true（D1）。
- **日志**：`printNesterovDatabase`/`reportPLInfo` 有；per-iter CSV（HPWL/overflow/λ）无；失败码无。
- **隐蔽 config 门控**：`isMaxLengthOpt`/`isEnableNetworkflow`/`isOptCongestion` 三个开关决定 flow 真实形状，不在任何文档（§14 的 config 默认值审计是 M0 前置）。

### 1.4 跨工具协调

| 方向 | 现状 | 判定 |
|---|---|---|
| iFP → iPL | die/core/rows 经 iDB；宏约束无（20-iFP §4.2 待建） | 宏债务推给 GP |
| iSTA → iPL | `PLAPI::isSTAStarted` 恒 false；`ExternalAPI` 层是活的 | **死在包装层**——修复成本一行（取消注释），风险是 TDP 路径多年未跑，需回归基线 |
| iRT/eval → iPL | LUT-RUDY 内置环（opt-in）；eval::EvalAPI 版注释 | 内置 RUDY 与 12-evaluation 的 congestion_eval **是两套**（平行实现嫌疑，§14） |
| iPL → iCTS/iRT | `writeBackSourceDataBase` 写回 | 通 |
| iPL → iTO | `runIncrLG`（`PLAPI.cc:539+`） | API 在，Phase C 用 |
| iPL 内部 buffer vs iNO/iTO | BufferInserter 617 LOC 在布局内插 buffer | **三处 buffer 职责未裁定**（21-iNO/25-iTO 联动） |

### 1.5 与商业 place_opt 差距（假说，待 G17）

| 能力 | Innovus/ICC2 | iPL 现状 | 差距归因 |
|---|---|---|---|
| Macro place | SA/MIP+通道 | 假成功 | P0 接线+算法 |
| Init | QP/B2B | RandomPlace | P0（QP 资产先建） |
| GP | Nesterov/ePlace 类 | ✓ 成熟 | 发散断言/effort 档 |
| Detail | 多算子默认跑 | 五算子**默认不跑** | **P0 接线（D2）** |
| Timing-driven | 净权重 | 守卫死（基建在） | P1 一行修复+回归 |
| Congestion | GR inflat | 内置 RUDY opt-in | P1 默认化评估 |
| Legalize | 失败即停 | bool 两丢 | P0 G14 |

---

## 2. 需求

### 2.1 FR（★ = 本 rv 新增或大改）

| ID | 功能 | 现状 | rv1.1 |
|---|---|---|---|
| FR-PL-01 | ★ MacroPlacer：力导向初值 + 重叠消解 + SA polish | 空壳假成功 | ★ 真实现 + G14 |
| FR-PL-02 | ★ macro-first：宏锚定 fixed 后 GP std | 无 | ★ |
| FR-PL-03 | ★ 解析初值（先在 11-solver 建 QP 资产，再接线）；Random 仅回退 | Random 默认；QP 不存在 | ★（依赖 11 FR-SOL-08 解冻） |
| FR-PL-04 | GP：Nesterov + eDensity + WA | ✓ | 保留 + ★发散致命 |
| FR-PL-05 | ★ 收敛断言：diverged/overflow 未达标 → runGP 返 false → runFlow/TCL rc≠0 | void/只 LOG | ★ |
| FR-PL-06 | ★ 修复 `PLAPI::isSTAStarted()`（取消注释）+ TDP 路径回归基线 + timing 权重 A/B | 恒 false | ★ |
| FR-PL-07 | ★ 拥塞驱动默认化评估：isOptCongestion 现状默认审计 + A/B；统一内置 RUDY 与 12-eval 的归属 | opt-in/两套 | ★ |
| FR-PL-08 | LG bool 全链上抛（runFlow/TCL）；暴露 unplaced 机器可读 | 两丢 | ★ |
| FR-PL-09 | ★ **DP 回默认 flow**：`enable_dp` 配置开关（默认 on）替换"守卫+注释"死结构 | 默认不跑 | ★ **最高性价比** |
| FR-PL-10 | incr LG API 供 iTO/CTS | ✓ API | Phase C |
| FR-PL-11 | ★ IterParam 多轮渐进（effort 包） | 单趟 | ★ |
| FR-PL-12 | ★ Exhibit：per-iter CSV + JSON 终态 + 失败码 | 弱 | ★ |
| FR-PL-13 | ★ vs place_opt 苹果对苹果 | 无 | ★ G17 |
| FR-PL-14 | ★ iPL BufferInserter 与 iNO/iTO 的 buffer 职责裁定 | 三处并存 | ★ 文档+用例 |

### 2.2 NFR

| ID | 项 | 指标 |
|---|---|---|
| NFR-PL-01 | 中小设计（50k–200k inst）GP 收敛 | overflow ≤ target；wall 进 G21 预算 |
| NFR-PL-02 | LG 后 HPWL 膨胀 | ≤ 5%（先建基线再断言） |
| NFR-PL-03 | 宏：零 overlap；通道满足约束模型 | G3；违规→失败 |
| NFR-PL-04 | QP 失败 | 显式回退 Random + WARN，禁假成功 |
| NFR-PL-05 | 关 ★杠杆时 | 与当前二进制行为一致（零回归；假成功修复除外——**默认开**） |
| NFR-PL-06 | G17 place 段 | HPWL 或 post-route WNS δ≤5% |
| NFR-PL-07 | G21 | place 墙钟 ≤1.5× |
| NFR-PL-08 | ★ DP 默认 on 后 | gcd 回归 HPWL 不劣化、overlap=0 |

### 2.3 红线

- **G14**：MP/发散 GP/LG 失败 禁止 TCL 成功返回；runFlow 内禁止丢 bool。
- **金标** Innovus/ICC2；OpenROAD 不作门禁金标。
- **3D fork** 算法意图可参考，禁止未审计整替 2D。
- **QP 资产不存在**（11-solver §1.1）——禁止再在文档里写"接线 qudratic_programming"当既有事实。
- 新杠杆缺省关（timing/congestion/SA）；假成功修复与 DP 回流**默认开**（NFR-PL-08 门禁看护）。

---

## 3. HLD 总体架构

### 3.1 数据流

```
  iFP: die/core/rows/★MacroConstraint   iNO: netlist
  iSTA: slack/crit (守卫修复后)          iRT/内置RUDY: congestion
          │                                     │
          └─────────────────┬───────────────────┘
                            ▼
  ┌────────────────────────────────────────────────────────────┐
  │  PlacerIO / PLAPI                                            │
  │  ★ runMP: MacroPlacer(force→resolve→SA) → fix macros         │
  │  ★ runGP: QuadraticPlace?(→11-solver) else RandomPlace       │
  │         → NesterovPlace (★fail if diverged/overflow)         │
  │           ├ WA (+★net_crit)  ├ eDensity/DCT                  │
  │           ├ LUT-RUDY cong (★默认化评估)  └ keep-best [已有]    │
  │  runLG: Abacus → ★bool 全链上抛                              │
  │  ★ runDP: 五算子（enable_dp 默认 on，替代守卫+注释死结构）      │
  │  reportPLInfo + ★Exhibit CSV/JSON → writeBack                │
  └────────────────────────────────────────────────────────────┘
                            ▼
                  iCTS / iRT / iTO(incr LG)
```

### 3.2 关键设计决策（含被否）

| # | 决策 | 被否 |
|---|---|---|
| D1 | 假成功修复 + DP 回流默认开；QoR 杠杆默认关 | 全部默认关（DP 不回流 = 放行现状残疾 flow） |
| D2 | 宏归 iPL，iFP 只给约束（与 20-iFP 裁定一致） | 宏归 iFP |
| D3 | QP 先在 11-solver 立项建资产，再 Composition 接线 | 文档空喊"接线 qudratic_programming"（目录是 0 字节 TBD） |
| D4 | timing/congestion 权重注入，不改 Nesterov 骨架 | 改写求解器 |
| D5 | DP 回流走 `enable_dp` 配置（默认 on），删"守卫+注释"结构 | 恢复注释版 runDP / 继续靠 isSTAStarted 门控 |
| D6 | `isSTAStarted` 修复 = 取消注释 + 回归基线，不重构 STA 生命周期 | 顺手重设计 STA 启动顺序（超范围） |
| D7 | 内置 RUDY 与 12-eval congestion_eval 归属：先审计重复度再统一 | 立刻删一个（未审计） |

---

## 4. LLD · 模块分解

### 4.0 目录落点

```text
src/operation/iPL/
  api/PLAPI.cc|.hh                     ← runFlow 失败语义/DP 回流/守卫修复
  source/module/
    macro_placer/                      ← ★新建 MacroPlacer.{hh,cc}（删假成功链）
    initial_placer/quadratic_placer/   ← ★新建（依赖 11-solver QP 资产）
    global_placer/electrostatic_placer/NesterovPlace.*
    legalizer/Legalizer.*              ← bool 上抛
    detail_placer/                     ← 五算子已有；★回 runFlow
  source/config/PlacerIterParam.*      ← ★新增
benchmark/qor/ipl/                     ← ★ parity harness（12 联动）
```

### 4.1 `MacroPlacer` ★（FR-PL-01/02）

**真实现状**：无类；`PLAPI.cc:517-522` 全注释；`ipl_io.cpp:170-181` 恒 true。

```cpp
struct MacroPlaceResult { bool ok=false; int placed=0, failed=0;
  double hpwl=0, overlap_area=0, channel_viol=0; std::string fail_reason; };
class MacroPlacer { public: MacroPlaceResult run(); };  // force→resolve→SA
```

```
ALG-4.1-1  run
  macros ← blocks|is_macro  (M=0 → ok=true no-op)
  [★] forceInit: 阻尼力导向（net 质心+边界斥力），O(P·M)
  [★] resolveOverlaps: 最小重叠轴推开，clamp in-die
  [★] if sa_enable: translate|rotate(LEF orient)|swap；
      cost = α·HPWL + β·overlap(∞) + γ·channel + δ·cross_proxy；Metropolis
  [★] fix macros（fixed=true，macro-first FR-PL-02）
  overlap>0 or channel_viol>0 → ok=false   // 禁假成功
```

边界：无合法 orient → fail。复用：SA 框架待 11-solver FR-SOL-08 解冻后共用；此前 iPL 内最小实现并标注收编候选。

### 4.2 `QuadraticPlace` ★（FR-PL-03）

```
ALG-4.2-1  runGP 初值
  if cfg.use_qp_init && solver QP 可用:
    ok = QuadraticPlace(db).run();  if !ok: LOG_WARN → RandomPlace
  else: RandomPlace
  NesterovPlace(...).runNesterovPlace()
  if diverged or (strict && overflow>target): return false   // §4.3
```

**前置**：11-solver 的 QP 目录现为空 TBD——本 FR 与 11 FR-SOL-08 联动，由本工具的真实需求驱动那边立项。边界：固定宏锚点；孤立网跳过。

### 4.3 `NesterovPlace` 深化（FR-PL-04/05/06/07）

**真实现状**：`runNesterovPlace/NesterovSolve`；`_is_diverged` 多处置位（约 1099/1171/1227/1261/1400/1418/1493/1557）；发散 LOG_ERROR return（~`:1260`）；`runGP` void（`PLAPI.cc:523`）。

```
ALG-4.3-1  发散/收敛断言
  bool PLAPI::runGP();                    // void → bool
  if _is_diverged: status=Diverged, return false
  if strict_overflow && final_overflow>target: return false
ALG-4.3-2  守卫修复（FR-PL-06）
  PLAPI::isSTAStarted() := _external_api->isSTAStarted()   // 取消 PLAPI.cc:844 注释
  前置：跑通 TDP 路径回归基线（多年未执行，可能藏次级 bug——先量）
ALG-4.3-3  拥塞默认化评估（FR-PL-07）
  审计 isOptCongestion 默认值与 config 暴露面（NesterovPlaceConfig.hh:66,91,128）
  A/B：on/off × {HPWL, overflow, 后道 DR viol}；再决定默认
```

缺省 timing_w=0 → 零回归；`strict_fail_on_diverge=true` 默认开。

### 4.4 `Legalizer`（FR-PL-08）

**真实现状**：`bool runLegalize()`；`PLAPI::runLG` 返 flag（`:532-537`）；runFlow 丢（`:411`）、TCL 丢。

```
ALG-4.4-1  runFlow: if (!runLG()) { status=LG_FAIL; return false; }
struct LgResult { bool ok; int unplaced; double hpwl_delta; std::vector<std::string> unplaced_names; };
```

### 4.5 ★ DP 回流（FR-PL-09，最高性价比）

**真实现状**：五算子就绪；`runFlow` 里被"守卫+注释"杀死（`:421-425`）；独立命令 `run_detail_placer` 可达（`ipl_io.cpp:226`）。

```
ALG-4.5-1  runFlow 段替换
  if (cfg.enable_dp) { runDP(); }        // 默认 on
  // 删除 if(isSTAStarted())runPostGP()/else{注释} 结构；
  // runPostGP 归位到时序驱动路径（守卫修复后的 TDP flow），不再霸占默认链
  DP 后 checker.isNoOverlapAmongInsts() 失败 → rc≠0
```

门禁 NFR-PL-08：gcd 回归 DP on/off 对比（HPWL 不劣化、overlap=0、wall 增幅记录）。**这是本 rv 单点收益最大的改动**：~3.2k LOC 成熟算子从死代码变默认路径。

### 4.6 `PlacerIO` / TCL（G14）

```
ALG-4.6-1  runMacroPlacement: 真调 runMP，返 r.ok（禁恒 true）
ALG-4.6-2  CmdPlacerRunLG/MP/GP/DP: if(!io.run...()) return 0
```

### 4.7 模块状态一览

| 模块 | 现状 | rv1.1 动作 | 复用姿势 |
|---|---|---|---|
| MacroPlacer | 空+假成功 | ★新建+真 IO | 自建（SA 后收编 11） |
| QuadraticPlace | 资产不存在 | ★立项（联动 11） | Composition（待建） |
| RandomPlace | 默认初值 | 降级回退 | 已有 |
| NesterovPlace | 成熟（2055） | ★发散断言+守卫修复 | 自建深化 |
| DCT/WA evaluator | 成熟（862/536） | 不动 | 已有 |
| LUT-RUDY 拥塞 | opt-in 内置 | ★默认化 A/B | 已有→归属审计（D7） |
| Legalizer | 成熟（597） | ★bool 全链 | 已有 |
| DetailPlacer 五算子 | **默认 flow 死** | ★回流（FR-PL-09） | 已有 |
| BufferInserter | 隐蔽段（617） | ★职责裁定（FR-PL-14） | 已有 |
| TimingAnnotation | 守卫殉葬（395） | 随 FR-PL-06 复活 | 已有 |
| IterParam / Exhibit | 无 / 弱 | ★新增 | 新增 |

---

## 5. IterParam / 多轮渐进（FR-PL-11）

| 轮 | max_iter | target_ovf | timing_w | cong_w | sa_macros | 意图 |
|---|---|---|---|---|---|---|
| R0 | 低 | 松 | 0 | 0 | off | 快速铺开（≈现状） |
| R1 | 中 | 中 | 0 | 小 | on | 拥塞/宏 polish |
| R2 | 高 | 紧 | 小 | 中 | on | 时序介入 |
| R3 | 精化 | 紧 | 中 | 中 | off | 收尾（effort high） |

缺省 effort=medium → R0+R1；timing_w/cong_w 默认 0 零回归。配置集中 `PlacerIterParam`，禁散落魔数。

---

## 6. Cost / 指标分解

| 维 | 符号 | 记录点 | 用途 |
|---|---|---|---|
| HPWL / WA | W | 每 GP iter + 终态 | G17 |
| Overflow | O | 每 iter | 收敛 |
| Timing penalty | T | Σ crit·WA | A/B |
| Congestion penalty | C | LUT-RUDY util 超供 | A/B |
| Macro overlap / channel viol | M | MP 终态 | G3 |
| LG unplaced / DP overlap | U | LG/DP 终态 | G14 |
| Wall time | t | phase 分段 | G21 |

**禁止**单一标量掩盖 U>0 或发散。

---

## 7. 状态机 / 命令语义

```
initPlacer → (runMP?) → runGP → (buffer/spread?) → runLG → (runDP?) → report → writeBack → destroy
```

| 命令 | 成功 | 失败 rc |
|---|---|---|
| run_macro_placer | MacroPlaceResult.ok | 空操作/残留 overlap |
| run_global_placer | !diverged && overflow 门 | Diverged/Overflow |
| run_legalizer | flag==true | unplaced>0 |
| run_detail_placer | 无重叠 | overlap |
| run_placer（runFlow） | 全阶段成功 | 任一阶段失败中止（bool 不丢） |

---

## 8. 跨工具 Cascade

| 信号 | 方向 | 契约 |
|---|---|---|
| die/rows/★MacroConstraint | iFP→iPL | 20-iFP FR-FP-05 |
| net_crit | iSTA→iPL | 守卫修复后；slack 派生 |
| congestion | 内置 RUDY / iRT | FR-PL-07 A/B 后冻结来源 |
| incr inst list | iTO/CTS→iPL | `runIncrLG` |
| HPWL/overflow exhibit | iPL→12-eval | QoR schema 字段 |
| QP 需求 | iPL→11-solver | FR-PL-03 驱动 FR-SOL-08 |

---

## 9. 商业 Know-how 映射

| KH-ID | 落点 |
|---|---|
| KH-X-04 响亮失败 | §4.3/§4.4/§4.6 |
| KH-PL-01 解析初值 | §4.2（依赖 11） |
| KH-PL-02/03 密度/WA | 已有（DCT 862/WA 536） |
| KH-PL-04 时序净权重 | ALG-4.3-2 |
| KH-PL-05 拥塞 inflat | ALG-4.3-3 |
| KH-PL-06 合法化失败即停 | §4.4 |
| KH-PL-07 增量 | FR-PL-10 |
| KH-PL-08 宏混合 | §4.1 |
| KH-FP-01 通道 | Macro cost + 20-iFP 约束 |

---

## 10. 商业对照看板 + 演进 M0–M4

### 10.1 看板（vs Innovus/ICC2 place_opt）

| 指标 | iPL | 商业 | 门槛 |
|---|---|---|---|
| Macro success 语义 | 假成功→★真 | 真 | G14/G3 |
| Init 质量 | Random→★QP | QP/B2B | G2 |
| GP overflow | 有/断言弱 | 严格 | G2 |
| Detail place | **默认不跑→★默认跑** | 默认 | G2（NFR-PL-08） |
| Post-place HPWL | 未对拍 | 金标 | G17 δ≤5% |
| Post-route WNS（PT） | 未对拍 | 金标 | G17 |
| Place runtime | 未对拍 | 金标 | G21 ≤1.5× |

### 10.2 对照实验（能杀死假说）

| 假说 | 实验 | 杀死条件 |
|---|---|---|
| DP 回流改善 QoR | gcd 回归 DP on/off | HPWL/overflow 无差且 wall 增 → 默认改回 off 并记录 |
| QP 优于 Random | 同设计对比 → GP HPWL/overflow | QP 不优且更慢 |
| 修 isSTAStarted 有收益 | timing on/off A/B | WNS 无显著差异（则 TDP 维持关，文档记死） |
| LUT-RUDY 默认化有益 | cong on/off → 后道 DR viol | viol 不降或 HPWL 崩 |
| 宏 SA 必要 | force-only vs +SA | SA 无降 overlap/HPWL |
| 发散致命影响流程 | 故意坏参 | 不上抛则下游脏数据（应捕获） |

### 10.3 演进

| 阶段 | 目标 | 退出门禁 |
|---|---|---|
| **M0 先量** | config 默认值台账（isOptCongestion/isMaxLengthOpt/isEnableNetworkflow）；harness 基线 | 台账+基线可复现 |
| **M1 可信** | 假成功修复（MP/LG/GP bool 全链）+ DP 回流 | G14 + NFR-PL-08 |
| **M2 主算法** | 宏+QP 立项接线 | G2/G3 |
| **M3 打平** | isSTAStarted 修复 + timing/cong A/B；G17 δ | G17 |
| **M4 性能** | IterParam effort；G21 | G21 |

---

## 11. Exhibit

| 档 | 产物 | 内容 |
|---|---|---|
| CSV | `place_iters.csv` | iter,hpwl,wa,overflow,lambda,step,t_ms |
| JSON | `place_summary.json` | status,hpwl,overflow,unplaced,macro_*,dp_overlap,runtime |
| TXT | `place_report.txt` | 人读摘要 |
| Plot | 可选 | HPWL/overflow 曲线 |

失败码：`OK|MACRO_FAIL|QP_FALLBACK|GP_DIVERGED|LG_UNPLACED|DP_OVERLAP`。

---

## 12. 测试计划

| 级 | 内容 |
|---|---|
| L0 | Macro overlap=0；QP 小网（资产到位后）；isSTAStarted mock；diverged→false |
| L1 | runFlow 全链：故意坏参必非零 rc；runLG 失败注入必中止 |
| L1 | DP on/off gcd 回归（NFR-PL-08） |
| L4 | 基准套件 vs 冻结商业 DEF 指标 |
| L5 | 假成功回归（MP 空实现必须 fail）；关杠杆零回归 |

---

## 13. 里程碑（按周，示意）

| 周 | 交付 | 验收 |
|---|---|---|
| W1 | M0 台账（config 默认值+flow 形状）+ 假成功修复 PR | G14 单测绿 |
| W2 | DP 回流 + NFR-PL-08 门禁 | gcd 回归对比报告 |
| W3–W4 | MacroPlacer force+SA | 宏 overlap=0 于中小设计 |
| W5 | LG/GP/TCL bool 全链 | L1 红线 |
| W6 | isSTAStarted 修复 + TDP 基线 + timing A/B | 「有/无收益」报告 |
| W7 | 拥塞默认化 A/B + RUDY 归属审计 | 杀死实验表 |
| W8+ | QP 立项（联动 11）；G17/G21 place 段 | 主纲 Phase B1 退出 |

PR 切片：PL-0 台账 → PL-1 假成功三修 → PL-2 DP 回流 → PL-3 宏 → PL-4 守卫修复+A/B → PL-5 QP 接线 → PL-6 IterParam/Exhibit。

---

## 14. 未验证 / 负面结论 / 不要重走

| # | 项 | 说明 |
|---|---|---|
| 1 | `isOptCongestion` 等三开关的**默认值**与 config 文件暴露面 | `NesterovPlaceConfig.hh:66,91,128` 声明在，json 默认未审计——M0 第一刀 |
| 2 | GP keep-best 完整性 | 未逐行核（v2.0 同） |
| 3 | runPostGP/TDP 路径可否跑通 | 多年守卫隔离，修复守卫后可能有次级 bug——先基线 |
| 4 | 内置 RUDY（BinGrid::evalRouteDem）与 12-eval congestion_eval 的重复度 | D7，未审计 |
| 5 | BufferInserter 与 iNO/iTO buffer 的实例冲突 | FR-PL-14，未验证 |
| 6 | runNetworkFlowSpread 算法与收益 | 隐蔽段 2，未读 |
| 7 | AI DP predictor（runAiFlow）对 G17 的影响 | 实验枝，禁进主对照 unless 冻结 |

**不要重走**：
- 不要恢复 `CenterPlace` 为默认（已注释，易局部堆叠）。
- 不要再写"接线 qudratic_programming"当既有资产——目录是 0 字节 TBD（11-solver §1.1）。
- 不要用"注释/守卫"当功能开关——DP 之死即此模式产物（`PLAPI.cc:421-425`）。
- 不要未审计把 3D `MacroPlacer3D` 整文件替换进 2D（无 PlacerDB 耦合，平行栈教训见 24-iPL-3d §1.5）。

---

## 附录 A · 迁移 checklist

- [ ] config 默认值台账（isOptCongestion/isMaxLengthOpt/isEnableNetworkflow/use_qp_init）
- [ ] MP 假成功三修（IO 恒 true / TCL rc / readme 占位）
- [ ] `runFlow` 丢 bool 修复（runLG/runGP）
- [ ] `enable_dp` 配置 + DP 回流 + NFR-PL-08 门禁
- [ ] runPostGP 归位 TDP 路径
- [ ] `PLAPI::isSTAStarted` 取消注释 + TDP 回归基线
- [ ] 发散断言（runGP void→bool）
- [ ] 拥塞默认化 A/B + RUDY 归属审计
- [ ] MacroPlacer force+SA（联动 11 SA 收编）
- [ ] QP 立项（联动 11 FR-SOL-08）
- [ ] IterParam + Exhibit CSV/JSON
- [ ] BufferInserter 职责裁定（FR-PL-14）

## 附录 B · 决策记录

| ID | 决策 | 被否方案 | 理由 |
|---|---|---|---|
| D1 | 假成功修复+DP 回流默认开 | 全默认关 | 现状 flow 残疾，G14 是正确性非实验 |
| D2 | 宏归 iPL | 宏归 iFP | 主纲算法归属 |
| D3 | QP 先建资产再接线 | 空喊接线 TBD 目录 | 11-solver §1.1 实证 |
| D4 | 权重注入 | 改写 Nesterov 方程 | 风险低可 A/B |
| D5 | DP 走配置回流 | 恢复注释/守卫门控 | 死亡结构不要再造 |
| D6 | 守卫修复=取消注释+基线 | 顺手重构 STA 生命周期 | 超范围 |
| D7 | RUDY 归属先审计 | 立刻删一套 | 未审计不动刀 |
| D8 | 3D 只参考不整替 | 直接覆盖 2D | 耦合/复用教训 |

## 附录 C · 术语

| 术语 | 含义 |
|---|---|
| place_opt | 商业布局+合法化+细节统称 |
| WA / eDensity / DCT | log-sum-exp 平滑线长 / 静电密度 / 余弦变换 Poisson 求解 |
| LUT-RUDY | 查表修正的 RUDY 拥塞估计（iPL 内置，opt-in） |
| TDP | timing-driven placement（守卫殉葬的那条路径） |
| G14 | 禁止假成功门禁 |

## 附录 D · 证据摘录（file:line 最小集）

| 断言 | 证据 |
|---|---|
| runFlow 全链 | `PLAPI.cc:387-458`（`// runMP();` `:389`、buffer `:399-403`、spread `:405-408`、runLG `:411`、DP 死结构 `:421-425`、二次 LG 注释 `:436-440`、writeBack `:457`） |
| isSTAStarted 硬编码 | `PLAPI.cc:842-846`（真查询 `:844` 注释，`return false;` `:845`） |
| ExternalAPI 层是活的 | `ExternalAPI.cc:40-43`（`staInst->isInitSTA()`） |
| runGP = Random+Nesterov | `PLAPI.cc:523-530`（CenterPlace 注释 `:525`，RandomPlace `:526`） |
| runLG bool 与丢弃 | `PLAPI.cc:532-537`；`runFlow` `:411` |
| 宏假成功链 | `ipl_io.cpp:170-181`；`PLAPI.cc:517-522`；`macro_placer/readme.md`（一行） |
| 生产入口 | `ipl_io.cpp:65`（run_placer→runFlow）；`scripts/design/sky130_gcd/script/iPL_script/run_iPL.tcl:40` |
| DP 独立命令 | `ipl_io.cpp:226`（runDP） |
| 拥塞驱动内置 | `NesterovPlace.cc:1360-1390`（isOptCongestion 门控；evalRouteDem/fastGaussianBlur/evalRouteUtil；GR 版注释 `:1383-1387`） |
| 拥塞 config | `NesterovPlaceConfig.hh:66,91,128` |
| 发散静默 | `NesterovPlace.cc:~1260`（LOG_ERROR+return）；`runGP` void `PLAPI.cc:523` |
| 五算子体量 | NFSpread 1117 / InstanceSwap 853 / BinOpt 460 / RowOpt 341 / LocalReorder（detail_placer/operation/） |
| Legalizer→solver Abacus | `Legalizer.cc:32` |
| iPL 全树 | `find src/operation/iPL ... wc -l` = 31260 |
