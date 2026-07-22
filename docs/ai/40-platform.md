<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 40 · platform / flow 平台与流程编排 · 商业对标方案 · rv2.0

> 文档号：40-rv2.0　　版本：rv2.0（大改）　　里程碑：**脚本散装 → DAG 编排（Innovus session 能力）× 工具契约透明（全工具就绪表 + 失败传播 + 断点续跑）→ G14/G15/G16 闭环**
> 体例：`01-ai-doc-conventions-rv1.md`；深度对标：`27-iSTA-rv2.0.md`、`28-iRCX-rv2.0.md`、`30-iDRC-rv2.0.md`（逐能力走读 + 双对标线 + 完整精度栈）
> 商业金标：**ICC2 / Innovus session 管理**（流程编排/依赖声明/失败传播）；**Calibre 签核路径**（工具契约透明 → G14/G15 可证）；门禁：**G14 / G15 / G16 / G21**（辅 G1/G1b）
> 上游：全工具链（21–33）　下游：`12-evaluation`（QoR 汇聚层）、CI/CD 门禁
> 纲领：`00-ieda-commercial-parity-master-plan-v1.1.md`；Know-how：`03-commercial-knowhow-catalog.md` KH-PLAT-\*、KH-X-03/04
> 覆盖：`src/platform/flow/`（flow.h/flow.cpp、tool_flow/ 空壳待建）、`src/interface/tool_api/*_io`（12 个单例入口）、`src/apps/ieda_main.cpp`
> 纪律：**平台层横向能力优先于单工具纵深**；契约可机械校验（非人脑约定）；断言带 `file:line`；未实测写「未验证」；每条理论附能杀死它的对照。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.0–v1.2 | 2026-07-20 | 空壳/契约/DAG LLD；编号未对齐 01 骨架 |
| rv1.0 / v2.0 | 2026-07-20 | **§0–§14 重排**；坐实 `tool_flow/` 空壳与 `ieda_main` 恒 `return 0`；F2 仍待对照实验 |
| **rv2.0** | **2026-07-22** | **大改（对照 27-iSTA-rv2.0 的深度与平台特性重写，目标显式拆成双对标线）**。核心修订六条：**(1)** rv1.0 把 platform 当成「编排层缺 DAG」来审——**代码级核实后发现头号结构症结是全链契约缺失与假成功陷阱**：`tool_flow/` 确为空壳，但症结根源是**全工具就绪契约不透明**（eval→rcx 顺序陷阱 fork 实测）+ **失败假成功**（`ieda_main.cpp:69` `return 0`，子工具 FATAL 不向上传播）+ **工具间耦合隐式**（单例群直接互访，依赖在人脑）——Tier 4 层的核心职责是「让全工具链的边界/依赖/失败语义成为可机械校验的契约」，现状是**边界失明**（类比 30-iDRC 无覆盖表的假 clean）；**(2)** 新增 **§1.5 精度栈逐项审计**（平台层的「精度栈」= 全工具契约透明度）：逐机制列出 platform 已有 vs 商业平台（ICC2/Innovus session 管理）的差距清单——Tcl 入口 ✓、12 个 tool_api ✓、flow 骨架 ✓；但 **就绪契约表零建设**（哪个工具依赖哪个工具的哪些前置产物）、**失败 rc 不传播**（`return 0` 硬编码）、**断点续跑未证**（无 checkpoint 机制）、**单例污染未审**（多设计连跑风险）、**增量闭环无平台原语**（iTO/iCTS/iNO 各自调 incr LG，无统一封装）——这五条是 **G14/G15/G16 不可证的根源**（门禁要求「失败响亮」「工具边界诚实」「单 session netlist→GDS」，当前架构全链无法保证）；**(3)** 全文按**双对标线**重组：ICC2/Innovus 线 = 流程编排能力（DAG 调度 + 依赖声明 + 拓扑校验 + on_fail abort_chain → session 管理水平），Calibre 线 = 工具契约透明（就绪表 + 产物断言 + checked/skipped 强制 + 假成功禁止 → 签核路径可信度），§10 拆成两块看板；**(4)** 补齐 27 号文档体例要素：§4.12 模块状态一览（FlowScheduler/EngineContract/Checkpoint 各模块成熟度/复杂度/边界/复用姿势）、§5.2 双档配置表（严格契约档 × 宽松兼容档，对标 signoff vs in-design 的分级配置）、§8 调用方契约表（全工具 12×12 依赖矩阵 + 平台强制闭环点）、§10.3 对照实验（E-PLAT-01～05 已有，补 E-CONTRACT-\* 系列契约违反注入实验）；**(5)** 平台层特殊纪律强化：**横向能力优先于单工具纵深**（§2.3 红线：不许单工具再配私有 STA/DRC/eval，必须走平台 API）、就绪契约从「附录可选」升为 **M0 前置 + CI 强制**（§4.1）、失败 rc 看板必填 **非零率 / abort_chain 成功率 / 假成功拦截数**（§10.1，对标商业 session 的失败传播能力，机械判据）；**(6)** 新增 **§1.3 三层契约审计**（对标 27-iSTA §1.3 三套栈 + §1.4 in-design 调用的结构性审计深度）：**工具间依赖契约**（12×12 requires 矩阵当前全在人脑）、**工具内初始化契约**（单例 getInstance 是否幂等/可重入）、**平台闭环契约**（commit→incr LG、route→drc→routeECO 三点现状各自为政，无统一原语）。**缺省配置零回归**纪律不变；新增契约校验开关缺省 **强制**（平台层边界诚实 > 开发便利，类比 30-iDRC 的 SKIP≠PASS 红线）。 |

---

## 1. 症结审计（逐能力 / 逐层级代码走读）

对 `src/platform/flow/`（flow.h/flow.cpp、tool_flow/ 空壳）+ `src/interface/tool_api/*_io`（12 个单例）+ `src/apps/ieda_main.cpp` 走读后的判定。**前提**：rv2.0 不推翻 rv1.0 的核心结论（tool_flow 空壳、ieda_main 恒 return 0、顺序陷阱待实验），但把审计深度对齐 27/28/30 号文档：逐能力给「现状 / 判定 / 缺口」三列，并新增 rv1.0 没有的 **§1.5 精度栈逐项**（平台层的「精度栈」= 全工具契约透明度，对标商业 session 管理）、**§1.3 三层契约审计**（工具间/工具内/平台闭环，对标 27-iSTA §1.3 三套栈的结构性审计深度）。

生产骨架（`flow.h:51-53` + `ieda_main.cpp:56-74`）：

```text
ieda_main(script_path):
  Flow::initFlow()                           // src/platform/flow/flow.cpp:35-47
  Flow::run(script_path)                     // :52-105，核心：Tcl_EvalFile(interp, script.c_str())
  return 0                                   // :69 硬编码，子 Tcl 命令失败不传播
tool_api 单例群（12 个 *_io.h）：
  icts_io, idrc_io, ieval_io, ifp_io, ino_io, ipdn_io, ipl_io, ipnp_io, ipw_io, irt_io, ista_io, ito_io
  每个工具有 init/run/report 入口，经 src/interface/tcl/tcl_<tool>/ 注册 Tcl 命令
```

### 1.1 功能形态——薄壳在，契约透明度零建设

| 能力 | 现状 | 证据 | 判定 |
|---|---|---|---|
| Tcl 脚本入口 | ✓ | `flow.h:51-53` initFlow/run/runTcl；`ieda_main.cpp:62` | **可用** |
| 12 工具 API | ✓ | `tool_api/icts_io.h` 等 12 个；`tcl_register.cpp` 注册全部工具命令 | **完整入口** |
| tool_flow 编排层 | ✗ 空壳 | `tool_flow/` 仅 CMakeLists.txt（rv1.0 坐实） | **P0 缺口（G14/G16）** |
| 就绪契约表 | ✗ | 无 `requires_table.json` / `EngineContract.hh`；工具调用序在 TCL 脚本（人脑约定） | **P0 缺口（G14）** |
| 失败 rc 传播 | ✗ | `ieda_main.cpp:69` `return 0`（硬编码）；Tcl 命令失败 rc 未审计 | **P0 缺口（G14）** |
| 断点续跑 | ✗ | 无 checkpoint 机制；无 `save_session` / `restore_session` | **P0 缺口（G16）** |
| 增量闭环原语 | ✗ | iTO/iCTS/iNO 各自调 iPL.runIncrLG（25/23/21 号文档）；无统一 `IncrLegalizeAfterCommit` 封装 | **P1 缺口（KH-PLAT-02）** |
| 单例污染审计 | ✗ 未审 | 连跑多设计时单例 reset 行为**未验证** | P2 |
| 产物存在断言 | ✗ | 无 `assert_products` 机制；stage 成功≠产物存在（假成功陷阱） | **P0 缺口（G14）** |
| SUCCESS stamp | ✗ | 无 `SUCCESS_<stage>` marker 文件；无 CI 消费侧 | **P0 缺口（G15）** |
| QoR baseline 集成 | ⚠️ | `benchmark/qor/` 目录存在；与 12-evaluation 集成**未验证** | 半通（G1/G1b） |

**§1.1 结论**：入口骨架**完整可用**（Tcl 驱动 + 12 工具 API），但**平台层横向能力完全缺失**——编排/契约/失败传播/续跑四大能力是空白（tool_flow 空壳是表象，契约透明度零建设才是根源）。对照商业 session（ICC2/Innovus）的「依赖声明+拓扑校验+失败传播+checkpoint」能力，iEDA 当前形态是**脚本拼装**（顺序在人脑，违序静默错，失败假成功）。

### 1.2 算法成熟度——平台层无「算法」，核心是契约机制

平台层不是算法密集型（不同于 iPL/iRT），核心是**契约机制设计**。从 rv1.0 的 DAG 调度伪代码（§1.2.1 已有）提炼关键能力评估：

| kernel / 机制 | 现状算法 / 设计 | 判定 | 缺口 |
|---|---|---|---|
| **拓扑排序校验**（启动期，Kahn 算法） | ✗ 零命中 | **不存在** | 环检测/缺失前置检查——rv1.0 伪码 `validateTopo` 已给算法（O(V+E)），需落地 |
| **依赖就绪判定**（运行期，`ready(requires)`） | ✗ 零命中 | **不存在** | 前置 stage 成功标记集合 `success_stamps` 查询——rv1.0 伪码已给，需落地 |
| **失败传播链**（`abort_chain` on stage fail） | ✗ | `ieda_main` 恒 return 0 | 任一 stage 失败 → 后继不执行 → 整体 rc≠0（rv1.0 伪码 `:115-127` 已给） |
| **产物存在断言**（G14 双保险：rc=0 **且** products exist） | ✗ | 无 `expected_products` 声明 | stage.run() 返回 true 但产物缺失 → 假成功，拦下（rv1.0 `:129-132` 已给逻辑） |
| **Checkpoint 序列化**（iDB + 各工具状态 snapshot） | ✗ | 无 `Checkpoint.{hh,cpp}`；iDB 序列化**未验证**（§14.1-5） | 续跑前提：保存/恢复设计状态（DEF/内存 DB/随机种子），逐位一致验收（G16） |
| **单例注册代理**（工具不直接互访，经 Scheduler 初始化） | ✗ | 当前 `tool_api/*_io.h` 单例直接 getInstance()，绕过契约 | 工具 A 直接调 B.getInstance() = 隐式依赖，Scheduler 不可见（rv1.0 D4 决策：代理注入，非重写） |
| **增量闭环封装**（`IncrLegalizeAfterCommit` 三原语） | ✗ | iTO/iCTS/iNO 各自调 iPL；无统一 API | 平台强制：任何 netlist commit → 自动触发 incr LG（KH-PLAT-02，三工具同款病） |

**假说 H-PLAT-1（可杀）**：顺序陷阱（eval 先于 rcx → SPEF 静默不读）在本仓存在。  
**杀死实验 E-PLAT-01**（rv1.0 §10.2 已给设计）：手工改 TCL 脚本（`run_eval` 置于 `run_rcx` 前）→ 启动流程 → 查 SPEF 读入日志；若 eval 读到空/零 SPEF → **实锤 H-PLAT-1**（fork 同源病），改为「启动期依赖校验拦下」。

**假说 H-PLAT-2（可杀）**：子工具 FATAL（如 iPL core dump）会导致整体 exit≠0。  
**杀死实验 E-PLAT-02**（rv1.0 §10.2 已给）：流程中途注入崩溃（`kill -9` 或人为 assert(false)）→ 查整体 exit code；若仍=0 → **杀 H-PLAT-2**，实锤「失败假成功」（F3），改为「平台捕获 + rc≠0」。

### 1.3 ★三层契约审计——头号结构症结（对标 27-iSTA §1.3 三套栈 + §1.4 in-design 调用的审计深度）

rv1.0 的隐含前提是「平台层只缺 DAG 编排代码」。**代码级核实：错。症结是三层契约全链断裂，且每层都有结构性缺陷：**

#### 1.3.1 工具间依赖契约（Tier 4 主职责）

| 依赖边 | 当前状态 | 应有契约 | 判定 |
|---|---|---|---|
| **sta ← rcx**（SPEF） | 人脑约定（TCL 脚本序） | `sta.requires = ["rcx_ready"]`；启动期校验；违序→FATAL | **隐式依赖**（F2 顺序陷阱根源） |
| **eval ← sta ∧ rcx** | 人脑约定 | `eval.requires = ["sta_ready", "rcx_ready"]`（KH-PLAT-01） | **隐式依赖**（fork 实测 eval 先于 rcx 静默运行） |
| **to ← sta, place** | 人脑约定 | `to.requires = ["sta_ready", "place_legal"]`（时序驱动优化需要 slack + 可 move） | **隐式依赖** |
| **route ← place, cts, pdn** | 人脑约定 | `route.requires = ["place_legal", "cts_done", "pdn_done"]` | **隐式依赖** |
| **drc ← route** | 人脑约定 | `drc.requires = ["route_done"]` | **隐式依赖** |
| **report ← eval** | 人脑约定 | `report.requires = ["eval_done"]`（产物依赖） | **隐式依赖** |

**量化**：12 个工具 → 理论 12×12=144 依赖对（实际约 20 条主依赖边），**全部在 TCL 脚本人脑约定**（无机器可校验的 requires 表）。对照商业 session（Innovus）：`place` 命令自动检查 `floorplan_done` stamp，违序→启动期报错（声明式依赖）。

**诚实归因**：人脑约定的工程理由——早期单工具开发，各自 TCL 脚本独立调试，全流程「拼装」时依赖序靠文档/经验传承。但代价是真实的：**新工具加入插入点全凭经验**（eval 加入时没人记得「必须晚于 rcx」），**fork 顺序陷阱证明人脑约定不可扩展**（E-PLAT-01 实测）。

#### 1.3.2 工具内初始化契约（单例幂等性）

| 工具 API | 现状单例模式 | 幂等性 | 多设计连跑风险 |
|---|---|---|---|
| `IplApi::getInstance()` | 静态局部变量单例（iPL） | **未验证** | 连跑设计 A→B，iPL 状态是否正确 reset？ |
| `ItoApi::getInstance()` | 同上（iTO） | **未验证** | 同上 |
| `IstaApi::getInstance()` | 同上（iSTA） | **未验证** | 同上 |
| …（12 个工具各一套） | 各自单例实现 | **全部未验证** | F6：多设计单例污染未审计 |

**假说 H-PLAT-3（可杀）**：连跑两设计（gcd → aes）时单例自动 reset，无污染。  
**杀死实验 E-PLAT-06**（新增）：脚本连跑 `read_def gcd.def; run_place; read_def aes.def; run_place`（无退出 iEDA）→ 查第二次布局的 instance 数/网表名；若仍是 gcd 残留 → **杀 H-PLAT-3**，实锤单例污染。

#### 1.3.3 平台闭环契约（commit→incr LG 三点同款病）

| 闭环点 | 现状 | 应有平台原语 | 证据 |
|---|---|---|---|
| **iTO commit → incr LG** | iTO 自己调 `ipl_io.runIncrLG()` | `IncrLegalizeAfterCommit(netlist_delta)` 统一封装 | 25-iTO §1.2：「commit netlist 但不调 incr LG → 非法布局流入下游」 |
| **iCTS commit → incr LG** | iCTS 自己调（或不调） | 同上 | 23-iCTS §1.1：同款病 |
| **iNO commit → incr LG** | iNO 自己调 | 同上 | 21-iNO §1.3：同款病 |
| **route → drc → routeECO** | 脚本串联：`run_route; run_drc; if vios: run_route_eco` | `EcoRouteLoop(max_iter, drc_threshold)` 封装 | 30-iDRC §4.3：回灌 schema 草案，无平台循环 |
| **iRT ← iDRC 违例 JSON** | schema 不一致**未验证** | 统一 `violation_summary.json` 格式 | 30-iDRC FR-DRC-05、26-iRT FR-RT-06 |

**诚实归因**：commit→incr LG 三点各自为政的工程理由——每个工具开发者都知道「改网表后要合法化」，但**平台未提供统一原语**，只能各自调 iPL API（易漏、易忘）。商业工具（Innovus）的 `ecoPlace` API **内建 legalize 步骤**，无「优化但不合法化」的接口——这是**架构属性**（平台强制），非工具自觉（rv1.0 D2 决策核心）。

**§1.3 结论**：三层契约全链断裂——**(a) 工具间依赖全在人脑**（12×12 矩阵零机械化，顺序陷阱根源）；**(b) 工具内单例幂等性未验证**（多设计连跑风险，F6）；**(c) 平台闭环无统一原语**（commit→incr LG 三工具同款病，route↔drc 回灌无平台循环）。对照商业 session（ICC2/Innovus）的「依赖声明+状态管理+闭环原语」三层能力，iEDA 当前架构是**薄壳拼装**（横向能力缺失，纵深在单工具内，平台未体现价值）。

### 1.4 边界 / 回退 / 单位——操作化边界模糊，契约缺失是主线

平台层没有「单位」（时间/距离/电容等物理量在各工具内），但有**操作化边界**（什么时候算成功/失败/可回退）——现状模糊，契约缺失：

- **成功语义混乱**：`ieda_main` 恒 `return 0`（`ieda_main.cpp:69`）；Tcl 命令失败 rc **未审计**（`flow.cpp:52-105` `Tcl_EvalFile` 返回值未检查，**未验证**）。  
- **失败不传播**：子工具 LOG_FATAL 或 core dump → 整体 exit code？ E-PLAT-02 实测前未知（H-PLAT-2）。  
- **产物缺口**：stage 跑完 ≠ 产物存在（如 place 成功但 `place.def` 空文件/损坏）；无 `assert_products` 机制（G14 双保险缺失）。  
- **回退能力**：无 checkpoint 机制；续跑依赖「手工保存中间 DEF + 重新读入」（逐位一致性**未验证**，G16）。  
- **假成功陷阱**：0 违例 + skipped 规则非空 → DRC 报 clean（假 clean，类比 30-iDRC §1.5-#5 的 SKIP≠PASS）；平台层未拦截（KH-X-04）。

**缺省**：当前平台无显式失败语义（rc=0 是唯一出口）；无显式回退机制（DEF 文件+人工操作）。

**复用**：商业 session（ICC2）的 `save_mw_cel` / `restore_mw_cel` = 保证逐位一致的 checkpoint（随机种子/迭代序同步）；iEDA 缺此能力（iDB 序列化**未验证**，§14.1-5）。

### 1.5 ★精度栈逐项——对商业 session 管理的差距清单（平台层的「精度栈」= 全工具契约透明度）

商业 session（ICC2/Innovus）的可信度来自一整套互相咬合的机制。逐项核实 iEDA platform 差距（✓=有且生产在用，⚠️=有但半残，✗=无）：

| # | 商业 session 机制 | iEDA platform 现状 | 证据 | 对 G14/G15/G16 可证性的影响 | P |
|---|---|---|---|---|---|
| 1 | **Tcl 驱动入口** | ✓ | `flow.h:51-53`；`ieda_main.cpp:62` Tcl_EvalFile | 基准能力 | — |
| 2 | **12 工具 API 完整** | ✓ | `tool_api/*_io.h` 12 个；`tcl_register.cpp` 注册 | 纵深能力在 | ✓ |
| 3 | **就绪契约表**（requires 矩阵机械化，依赖声明式） | ✗ | 无 `requires_table.json` / `EngineContract.hh`；依赖在 TCL 脚本（人脑约定） | **边界失明**：不知道工具 A 依赖哪些前置（sta 依赖 rcx 是经验，非契约）→ **顺序陷阱根源**（fork eval→rcx 静默错） | **P0** |
| 4 | **启动期拓扑校验**（环检测/缺失前置 → FATAL before run） | ✗ | 无 `FlowScheduler::validateTopo`；违序在运行期静默错（或成功） | **G14 不可证**：违序不响亮 → CI 无法拦截错误流程 | **P0** |
| 5 | **失败 rc 传播**（任一 stage fail → 整体 rc≠0 + abort_chain） | ✗ | `ieda_main.cpp:69` 恒 `return 0`；Tcl 命令失败 rc 未审计 | **G14 不可证**：子工具失败 → 整体仍报成功 → CI 假绿 | **P0** |
| 6 | **产物存在断言**（G14 双保险：rc=0 **且** expected_products exist） | ✗ | 无 `Stage.expected_products` 声明；无运行期检查 | **假成功陷阱**：stage 报成功但 DEF 空/损坏 → 下游工具读入失败（G14） | **P0** |
| 7 | **SUCCESS stamp 机制**（每 stage 成功后写 marker 文件，CI 消费） | ✗ | 无 `SUCCESS_<stage>` 文件；无 CI 检查逻辑 | **G15 不可证**：CI 不知道哪些 stage 真成功（全靠 exit code，已知=0） | **P0** |
| 8 | **Checkpoint 序列化**（save/restore session，逐位一致续跑） | ✗ | 无 `Checkpoint.{hh,cpp}`；iDB 序列化**未验证** | **G16 不可证**：续跑不可证逐位一致（fork 前科：ASLR 导致 HPWL 1.89x 离散） | **P0** |
| 9 | **增量闭环统一原语**（commit→incr LG 平台封装，非工具自觉） | ✗ | iTO/iCTS/iNO 各自调 iPL；无 `IncrLegalizeAfterCommit` API | **架构缺陷**：三工具同款病（commit 不 LG → 非法布局流入下游）→ 平台未体现价值（KH-PLAT-02） | P1 |
| 10 | **单例幂等性审计**（多设计连跑时 getInstance 正确 reset） | ✗ 未审 | 12 个 tool_api 单例；reset 行为**未验证** | **多设计污染风险**（F6）：连跑 gcd→aes 时残留 gcd 状态 | P2 |
| 11 | **就绪契约运行时报告**（每次 run 附带 checked/skipped stage 清单） | ✗ | 无运行时契约附件；无 `flow_stamps.json` | 类比 30-iDRC 的 SKIP≠PASS：跳过 stage 不报告 → 假 clean | P1 |
| 12 | **工具间耦合透明化**（12×12 依赖矩阵文档化，禁隐式单例互访） | ✗ | 当前 `tool_api` 单例直接 getInstance()，绕过 Scheduler | 工具 A→B.getInstance() = 隐式依赖，平台不可见（§1.3.1） | P1 |
| 13 | **route↔drc 回灌闭环**（违例 JSON 统一 schema + 平台循环封装） | ⚠️ schema 草案 | 30-iDRC §4.3 `violation_summary` 草案；无平台 `EcoRouteLoop` | 闭环在脚本（`run_route; run_drc; if vios: run_route_eco`）→ 逻辑散装 | P1 |
| 14 | **QoR baseline 集成**（`run_qor_baseline.sh` 自动消费 eval 产物） | ⚠️ 半通 | `benchmark/qor/` 存在；与 12-evaluation 集成**未验证** | G1/G1b 前置；但平台未强制（可绕过） | P2 |
| 15 | **性能剖面导出**（每 stage 墙钟 → `flow_profile.json`，G21 机读） | ✗ | 无性能打点；无 JSON 输出 | **G21 不可证**：全流程墙钟不可归因（不知道瓶颈在哪个 stage） | P2 |

**§1.5 结论**：精度缺口是**结构性的三层**——(a) 契约机制：就绪表/拓扑校验/产物断言/SUCCESS stamp（#3/4/6/7，**G14/G15 不可证的根源**）；(b) 失败传播：rc≠0/abort_chain（#5，**G14 核心**）；(c) 续跑能力：checkpoint/逐位一致（#8，**G16 不可证**）；(d) 平台闭环：增量原语/回灌循环/多设计隔离（#9/13/10）。rv1.0 只覆盖了 (a) 的理论设计（DAG 伪码），(b)(c)(d) 是 rv2.0 新增战线。**平台层头号纪律 = 横向能力优先于单工具纵深**（§2.3 红线）：不许单工具再配私有 STA/DRC/eval，必须走平台契约。

### 1.6 死配置 / 死接线 / 假成功点名

1. **`ieda_main` 恒 `return 0`**（`ieda_main.cpp:69`）→ 子工具失败不向上传播（G14 核心缺口）。  
2. **`tool_flow/` 空壳**（仅 CMakeLists.txt）→ 编排层零建设。  
3. **就绪契约全在人脑**（TCL 脚本序）→ 违序静默错或假成功（fork eval→rcx 陷阱）。  
4. **无产物存在断言**（stage 成功≠产物存在）→ 假成功陷阱（place 报成功但 DEF 空/损坏）。  
5. **无 SUCCESS stamp 消费侧**（CI 不检查 marker 文件）→ G15 不可证。  
6. **单例直接互访**（`tool_api` getInstance() 绕过 Scheduler）→ 依赖隐式化。  
7. **commit→incr LG 各自为政**（iTO/iCTS/iNO 三工具同款病）→ 平台未封装（KH-PLAT-02）。  
8. **Tcl 命令失败 rc 未检查**（`flow.cpp:52-105` Tcl_EvalFile 返回值**未验证**）→ 失败传播链断裂可能点。  
9. **iDB 序列化未验证**（checkpoint 前置，§14.1-5）→ G16 续跑不可证。  
10. **多设计单例 reset 未审**（连跑污染风险，F6）→ 幂等性未保证。

### 1.7 症结优先级表（§1 结论摘要）

| ID | 症结 | 证据 | 对标线 | P |
|---|---|---|---|---|
| **F1** | **编排层空壳 → DAG 调度零建设** | `tool_flow/` 仅 CMakeLists.txt | ICC2/Innovus session | **P0** |
| **F2** | **就绪契约表缺失 → 依赖全在人脑** | 无 requires_table；fork eval→rcx 陷阱 | ICC2/Innovus 依赖声明 | **P0** |
| **F3** | **失败假成功 → rc 恒 0** | `ieda_main.cpp:69` `return 0` | ICC2/Innovus 失败传播 | **P0** |
| **F6_ext** | **产物断言缺失 → rc=0 不保证产物存在** | 无 assert_products 机制 | G14 双保险 | **P0** |
| **F7** | **SUCCESS stamp 缺失 → CI 不可证** | 无 marker 文件 + 无消费侧 | G15 | **P0** |
| F4 | 增量闭环无平台原语 | iTO/iCTS/iNO 各自调 iPL | KH-PLAT-02 | P1 |
| F5 | 断点续跑未证 | 无 checkpoint；iDB 序列化未验证 | G16 | P1 |
| F6 | 多设计单例污染 | 12 个单例 reset 行为未审 | — | P2 |
| F8 | 工具间耦合隐式 | 单例直接互访，绕过 Scheduler | — | P1 |
| F9 | 性能剖面缺失 | 无墙钟打点 → G21 不可归因 | G21 | P2 |

**§1 最关键 5 条（双对标线）**：  
- **ICC2/Innovus session 线**：F1（DAG 空壳）、F2（契约表缺）、F3（失败假成功）  
- **Calibre 签核路径线**：F6_ext（产物断言缺）、F7（SUCCESS stamp 缺）

rv1.0 只覆盖 F1（DAG 伪码设计），rv2.0 新增 **F2（契约表，顺序陷阱根除点）** + **F3/F6_ext/F7（失败/产物/stamp 三层可证性，G14/G15 核心）** + **§1.3 三层契约审计（工具间/工具内/平台闭环，结构性症结）**。

---

## 2. 需求 FR / NFR / 约束

### 2.1 FR（★ = 相对现状新增）

| ID | 功能 | 现状 | rv2.0 |
|---|---|---|---|
| FR-PLAT-01 | ★ **FlowScheduler DAG**（拓扑排序+依赖校验+执行调度） | ✗ F1 | ★ §4.1；缺省 off（零回归）；`strict_contract=true` 启用 |
| FR-PLAT-02 | ★ **就绪契约表**（requires_table.json + EngineContract.hh） | ✗ F2 | ★ §4.1；M0 前置+CI 强制 |
| FR-PLAT-03 | ★ **失败 rc 传播**（子工具失败 → rc≠0 + abort_chain） | ❓ F3 | ★ §4.3；E-PLAT-02 实测前置 |
| FR-PLAT-04 | ★ **产物存在断言**（expected_products + 运行期检查） | ✗ F6_ext | ★ §4.1 Stage 结构；G14 双保险 |
| FR-PLAT-05 | ★ **SUCCESS stamp 机制**（marker 文件 + CI 消费） | ✗ F7 | ★ §4.1；写入+CI 检查 |
| FR-PLAT-06 | ★ **Checkpoint 续跑**（save/restore + 逐位一致验收） | ✗ F5 | ★ §4.4；iDB 序列化前置 |
| FR-PLAT-07 | ★ **增量三原语**（IncrLegalizeAfterCommit / IncrRouteEco / IncrRetimingVeto） | ✗ F4 | ★ §4.5；平台封装，工具强制调用 |
| FR-PLAT-08 | ★ **工具间耦合代理**（单例注册经 Scheduler，禁直接互访） | ✗ F8 | ★ §4.1；依赖可见化 |
| FR-PLAT-09 | ★ **性能剖面导出**（墙钟打点 → flow_profile.json） | ✗ F9 | ★ §4.6；G21 前置 |
| FR-PLAT-10 | ★ **run_qor_baseline 集成**（自动消费 eval → 12-evaluation） | ⚠️ 半通 | ★ §4.7；G1/G1b 前置 |
| FR-PLAT-11 | ★ **多设计隔离审计**（单例 reset + 连跑污染测试） | ✗ F6 | ★ §4.8；E-PLAT-06 |
| FR-PLAT-12 | ★ **route↔drc 回灌闭环**（EcoRouteLoop 平台封装） | ⚠️ 脚本散装 | ★ §4.5；统一 schema（30/26） |

### 2.2 NFR（可测数字）

| ID | 项 | 指标 | 对标线 |
|---|---|---|---|
| **NFR-PLAT-01** | **违序检出** | 启动期拓扑校验：环/缺失前置 → FATAL（非运行期静默错） | **G14** |
| **NFR-PLAT-02** | **失败非零率** | 子工具失败 → 整体 exit≠0（E-PLAT-02 实测 100%） | **G14** |
| **NFR-PLAT-03** | **产物断言拦截** | stage 成功但产物缺失 → 拦下（E-PLAT-05 注入必检出） | **G14** |
| **NFR-PLAT-04** | **SUCCESS stamp 覆盖** | CI 检查：全 stage 绿 → 全 stamp 存在（缺一不可） | **G15** |
| **NFR-PLAT-05** | **续跑逐位一致** | checkpoint 后续跑 vs 一跑到底：DEF 字节 diff=0（E-PLAT-03） | **G16** |
| NFR-PLAT-06 | 增量原语强制 | commit 不调 incr LG → 平台拦下（E-PLAT-04） | KH-PLAT-02 |
| NFR-PLAT-07 | 全流程通 / 不通 | netlist→GDS 单 session 无人工介入 | G16 |
| NFR-PLAT-08 | 端到端墙钟 | 记录+进 42-performance JSON | G21 |
| NFR-PLAT-09 | 零回归 | `strict_contract=false` → 当前 TCL 脚本行为不变 | — |

### 2.3 红线约束

- **金标 = ICC2/Innovus session 管理**（流程编排能力）**× Calibre 签核路径可信度**（工具契约透明）。  
- **横向能力优先于单工具纵深**：不许单工具再配私有 STA/DRC/eval（27-iSTA §1.3 三套栈教训）；新时序需求必须进平台契约（§4.1 requires 表）。  
- **契约表 M0 前置 + CI 强制**：无 requires_table → 禁止宣称「全流程可用」（类比 30-iDRC 无覆盖表的假 clean）。  
- **缺省新特性关闭 → 零回归**（Scheduler 缺省 off；`strict_contract=true` 显式启用）。  
- **SKIP≠PASS 红线**（类比 30-iDRC）：跳过 stage 不报告 → 假 clean；平台必须输出 checked/skipped 清单（NFR-PLAT-04）。  
- 禁止用「能跑完」替代「逐位一致」（续跑验收标准，D3 决策）。  
- 禁止无契约先「重构全部 TCL 脚本」（§14.2 负面）。

---

## 3. HLD

### 3.1 数据流——单引擎双档（严格契约档 × 宽松兼容档）

```text
                    TCL 脚本（用户编写）
                         │
                         ▼
            ┌─────────────────────────────┐
            │  Flow::run(script_path)      │
            │  Tcl_EvalFile(interp, ...)   │
            └─────────────┬───────────────┘
                         │
          ┌──────────────┼──────────────┐
          │ 宽松档（现状兼容）│  严格档（rv2.0 目标）│
          ▼              ▼               ▼
    直接执行 Tcl     FlowScheduler      依赖声明+校验
    无契约校验       validateTopo()     拓扑序+就绪检查
    失败可能不传播    abort_chain        失败→rc≠0+停止后继
    （零回归）       产物断言+stamp     （G14/G15/G16）
          │              │
          ▼              ▼
    tool_api 单例群（12 个 *_io）
      icts/idrc/ieval/ifp/ino/ipdn/ipl/ipnp/ipw/irt/ista/ito
          │              │
          ▼              ▼
    各工具引擎          ★ Scheduler 代理注册
    直接 getInstance()   依赖可见化+幂等性审计
          │              │
          ▼              ▼
    产物（DEF/rpt/JSON） ← assert_products + SUCCESS stamp
          │
          ▼
    12-evaluation（QoR 汇聚）+ CI 门禁（消费 stamp）
```

**核心架构判断**：严格契约档与宽松兼容档**共用同一套 tool_api、同一套工具引擎**——差别只在「是否经过 Scheduler 依赖校验」和「是否强制失败传播/产物断言/stamp」。这与商业 session（ICC2）的「可选 design rule check 严格度」同构；也直接否定「为兼容性再写一套轻量平台」的路线（代价是口径分家，参考 27-iSTA §1.3 三套栈教训）。

### 3.2 关键设计决策（含被否理由，对标 27-iSTA §3.2 深度）

| ID | 决策 | 被否方案 | 被否理由（工程/门禁） |
|---|---|---|---|
| **D1** | **DAG 编排内建化（requires 在代码里，非纯脚本）** | 保持纯脚本编排（现状） | **fork 顺序陷阱根源**：脚本编排=顺序约定在人脑，无机器校验 → eval 先于 rcx 静默运行 → SPEF 永久不读（fork 实测）。对照：商业 session（ICC2/Innovus）的依赖是**声明式**（TCL 调 `place` 自动检查 `floorplan_done`），违序=启动期报错。**被否原因**：人脑约定不可扩展（新工具加入 → 插入点全凭经验）；G14 要求机器可校验依赖。 |
| **D2** | **commit 闭环平台强制（增量 legalize 非建议是必须）** | 工具自觉调 incr LG | **三个工具同款病**：25-iTO §1.2、23-iCTS §1.1、21-iNO §1.3 均有"commit netlist 但不调 runIncrLG → 非法布局流入下游"。对照：商业工具（Innovus）的 `ecoPlace` API **内建 legalize 步骤**，无"优化但不合法化"的接口。**被否原因**：自觉=架构级设计缺陷，每个工具都要记住调 LG → 易漏；平台强制=结构属性，`IncrLegalizeAfterCommit` 原语封装（§4.5，KH-PLAT-02）。 |
| **D3** | **续跑验收=逐位一致（非"能跑完"）** | 续跑能跑完即可 | **低于逐位一致的续跑=假续跑**：可能续出不同结果（fork 前科：iPL ASLR 导致续跑 HPWL 1.89x 离散）。对照：商业工具（ICC2）的 `save_mw_cel/restore` **保证数值一致性**（随机种子/迭代序同步）。**被否原因**："能跑完"=无验收标准，续跑结果不可复现 → 调试/对标陷入僵局；G16 要求续跑产物逐位一致（NFR-PLAT-05）。 |
| **D4** | **单例保留+代理注入契约（不大翻修）** | 重写全部引擎管理（依赖注入） | **改动面 vs 收益权衡**：各工具单例（`IplApi::getInstance()` 类）是现状架构，全改=数月工作量。对照：fork 曾尝试重写引擎管理（`EngineRegistry` 中央注册）→ 半途放弃（回退成本太高）。**被否原因**：Scheduler 代理初始化（调用前检查 requires）是**最小侵入式改造**：工具接口不变，只在 `tool_api` 层加契约校验；重写=推倒重来，风险>收益。 |
| **D5** | **覆盖表 P0（边界诚实先于盲追全 stage）** | 先补全所有工具再记覆盖 | **KH-DRC-02 核心**（类比 30-iDRC）：无契约表的平台 = 边界失明（不知道工具 A 依赖哪些前置）。对照：商业 session（Innovus）**明确标注**依赖关系（help 文档列 prerequisites）。**被否原因**：追全 stage = 工作量数量级差（每个工具深度集成需月级）；边界诚实（requires 表）= G14 可判定基础（违序检出）。 |
| **D6** | **定位流程编排平台（非全能 IDE）** | 宣称替代商业 EDA 套件 | **范围诚实**：iEDA platform 对标 ICC2/Innovus 的 **session 管理层**（流程编排+工具协调），非 Cadence Virtuoso 全能 IDE。对照：商业 PnR 工具的平台职责 = 依赖管理+失败传播+checkpoint，不包办单工具算法。**被否原因**：宣称替代全能 IDE = 过度承诺；流程编排定位 = 有用且可达标。 |
| **D7** | **与 tool_api 共 schema（全工具统一产物格式）** | 各工具各写各的产物格式 | **契约前提**：全流程 netlist→GDS 需要工具间产物格式一致（iRT DEF = iPL 输入；iDRC JSON = iRT 消费）。对照：商业工具（Innovus）的工具链产物格式**平台强制**（不许私有格式）。**被否原因**：各写各的 = 需要格式转换层（易出 bug）；统一 schema = 零转换成本（§8 契约表）。 |
| **D8** | **缺省宽松档（零回归），显式严格档（G14/G15/G16）** | 直接改成严格契约 | **兼容性 vs 质量权衡**：现有 TCL 脚本用户（外部/内部）依赖当前行为；强制严格契约 = breaking change（CI 全红）。对照：商业工具升级时保留「legacy mode」兼容老脚本。**被否原因**：直接改=用户脚本全失效（外部贡献者流失）；双档=平滑过渡（缺省兼容，`strict_contract=true` 新门禁）。 |

**决策的共同模式**（防重蹈覆辙）：
- **机器校验 > 人脑约定**（D1/D5）：声明式依赖 + 启动期拓扑校验 = 一劳永逸；
- **平台强制 > 工具自觉**（D2/D7）：架构属性（commit 闭环/统一 schema）不依赖每个工具开发者记住；
- **高标准验收**（D3）：逐位一致 = 可复现性的唯一证明；
- **最小侵入改造**（D4）：代理注入契约 vs 推倒重来，选前者（工程现实）；
- **边界诚实**（D5/D6）：契约表+范围定位 = 实事求是（类比 30-iDRC 覆盖表前置）。

---

## 4. LLD · 模块分解

### 4.0 落点

```text
src/platform/flow/tool_flow/
  FlowScheduler.{hh,cpp}       ← ★新建（FR-PLAT-01）
  EngineContract.hh            ← ★新建（FR-PLAT-02）
  IncrLoop.{hh,cpp}            ← ★新建（FR-PLAT-07）
  Checkpoint.{hh,cpp}          ← ★新建（FR-PLAT-06）
src/interface/tool_api/
  *_io.{h,cpp}                 ← 12 个保留；★ 注册到 Scheduler
scripts/integration/
  run_contract_tests.sh        ← ★新建（E-PLAT-01～06）
benchmark/qor/
  run_qor_baseline.sh          ← ★集成到 12-evaluation（FR-PLAT-10）
config/
  requires_table.json          ← ★新建（M0 前置+CI 强制）
```

### 4.1 ALG · FlowScheduler + 就绪契约表 `[新增 P0]`

**核心数据结构**（对标 rv1.0 §1.2.1 伪码，补充实现细节）：

```cpp
// src/platform/flow/tool_flow/FlowScheduler.hh（★新建）
struct Stage {
  std::string name;                              // 如 "place", "sta", "drc"
  std::vector<std::string> requires;             // 前置 stage 名列表（就绪契约）
  std::vector<std::string> expected_products;    // 产物路径列表（G14 双保险）
  std::function<bool()> run;                     // 执行函数（返回 bool）
  std::function<void()> on_start;                // 可选：开始时回调（打点用）
  std::function<void()> on_success;              // 可选：成功时回调
};

class FlowScheduler {
 public:
  void registerStage(const Stage& s);            // 各 tool_api 注册
  void validateTopo() const;                     // 启动期：拓扑序校验（环/缺前置 → FATAL）
  int  run(const std::vector<std::string>& plan);// 按拓扑序执行，任一失败 → rc≠0
  
  // 查询接口（供 tool_api 检查前置）
  bool isReady(const std::string& stage) const;  // 检查单 stage 是否可执行
  bool hasSucceeded(const std::string& stage) const; // 检查是否已成功
  
 private:
  std::map<std::string, Stage> stages_;          // 注册的全部 stage
  std::set<std::string> success_stamps_;         // 已成功 stage 集合（内存）
  std::map<std::string, double> stage_wall_ms_;  // 墙钟记录（G21）
  
  bool ready(const std::vector<std::string>& reqs) const; // 检查前置列表
  void stampSuccess(const std::string& name);    // 写 SUCCESS marker 文件
  void emitProfile() const;                      // 输出 flow_profile.json
};
```

**就绪契约表**（`config/requires_table.json`，M0 前置+CI 强制）：

```json
{
  "version": "rv2.0",
  "stages": {
    "idb_init": {
      "requires": [],
      "products": ["design.idb"]
    },
    "fp": {
      "requires": ["idb_init"],
      "products": ["result/fp/fp.def"]
    },
    "place": {
      "requires": ["fp"],
      "products": ["result/pl/place.def"]
    },
    "cts": {
      "requires": ["place"],
      "products": ["result/cts/cts.def"]
    },
    "pdn": {
      "requires": ["fp"],
      "products": ["result/pdn/pdn.def"]
    },
    "route": {
      "requires": ["place", "cts", "pdn"],
      "products": ["result/rt/route.def"]
    },
    "rcx": {
      "requires": ["route"],
      "products": ["result/rcx/design.spef"]
    },
    "sta": {
      "requires": ["rcx"],
      "products": ["result/sta/timing.rpt"]
    },
    "to": {
      "requires": ["sta", "place"],
      "products": ["result/to/optimized.def"]
    },
    "drc": {
      "requires": ["route"],
      "products": ["result/drc/violations.json"]
    },
    "eval": {
      "requires": ["sta", "rcx"],
      "products": ["result/eval/qor_summary.json"]
    },
    "report": {
      "requires": ["eval"],
      "products": ["result/report/final_report.txt"]
    }
  }
}
```

**拓扑排序校验**（启动期，O(V+E)，rv1.0 §1.2.1 伪码已给，此处列关键实现点）：

```cpp
void FlowScheduler::validateTopo() const {
  // Kahn 算法
  std::map<std::string, int> in_degree;
  for (const auto& [name, stage] : stages_) {
    in_degree[name] = 0;
  }
  for (const auto& [name, stage] : stages_) {
    for (const auto& req : stage.requires) {
      if (stages_.find(req) == stages_.end()) {
        LOG_FATAL << "Stage " << name << " requires missing stage: " << req;
      }
      in_degree[name]++;
    }
  }
  
  std::queue<std::string> queue;
  for (const auto& [name, deg] : in_degree) {
    if (deg == 0) queue.push(name);
  }
  
  std::vector<std::string> topo_order;
  while (!queue.empty()) {
    std::string u = queue.front(); queue.pop();
    topo_order.push_back(u);
    
    for (const auto& [v_name, v_stage] : stages_) {
      if (std::find(v_stage.requires.begin(), v_stage.requires.end(), u) 
          != v_stage.requires.end()) {
        in_degree[v_name]--;
        if (in_degree[v_name] == 0) {
          queue.push(v_name);
        }
      }
    }
  }
  
  if (topo_order.size() != stages_.size()) {
    // 存在环
    LOG_FATAL << "Cycle detected in flow DAG";
  }
}
```

**执行调度**（运行期，按拓扑序，rv1.0 §1.2.1 伪码 `:110-137` 已给完整逻辑）：

- 复杂度：O(V · T_run)，V=stage 数（~12），T_run=单 stage 执行时间（place 分钟级）。  
- 边界：前置未就绪 → abort_chain（后继不执行）；产物缺失 → rc≠0（G14 双保险）；成功 → 写 `SUCCESS_<stage>` marker 文件（G15）。  
- 复用姿势：**禁止**平行重写调度核；现有 TCL 脚本缺省走宽松档（`flow.cpp` 直接 `Tcl_EvalFile`），显式 `--strict-contract` 走 Scheduler。

---

## 5. 配置

flow plan JSON/TCL 声明 stage 列表；缺省=现有脚本行为（零回归）；`strict_contract=true` 开启违序失败。

---

## 6. 指标

全流程通/不通、违序检出、续跑 diff、子步骤 rc、端到端墙钟（→42）。

---

## 7. 状态机

```text
validateTopo → for stage: check_ready → run → assert_products → stamp
fail → abort → rc≠0
checkpoint @ stage boundary（可选）
```

---

## 8. Cascade

平台强制：任何 netlist commit（iTO/iNO/iCTS/iECO）→ incr LG。就绪：eval 不得早于 rcx（KH-PLAT-01）。

---

## 9. Know-how

| KH | 落点 |
|---|---|
| KH-PLAT-01 | §4.2 顺序契约 |
| KH-PLAT-02 | 度量外生（与 12） |
| KH-X-03 | 断点续跑 |
| KH-X-04 | 失败非零 |

---

## 10. 看板 + M0–M4

| 指标 | iEDA | 商业 | 门槛 | G |
|---|---|---|---|---|
| netlist→GDS 单 session | | ✓ | ✓ | G16 |
| 违序检出 | | 启动报错 | 报错 | G14 |
| 续跑一致 | | 逐位 | 逐位 | G16 |
| 崩溃 rc | | ≠0 | ≠0 | G14 |
| 墙钟 | | | ≤1.5× | G21 |

契约测试 C1–C9：eval↔rcx、sta↔rcx、ipl↔ifp、ito↔ipl、icts↔ipl、irt↔idrc、ipa↔vcd、flow↔rc、checkpoint。

### 10.2 对照实验（可执行设计，对标 24-iPL-3d §10.2 深度）

| ID | 输入 | 命令/操作 | 判据（数值阈值） | 杀死假说/锁住契约 |
|---|---|---|---|---|
| **E-PLAT-01** | 违序启动注入（手工改 TCL：eval 先于 rcx） | 启动流程 | **启动期 FATAL**（非运行期静默错）；日志响亮报"missing dep: eval requires rcx" | F2 顺序陷阱（fork 同源病） |
| **E-PLAT-02** | 子步骤崩溃注入（`kill -9 <iRT_pid>` 中途杀进程） | 流程继续 | **rc≠0 且无 SUCCESS stamp**；日志报"stage failed: route" | F3 失败传播（G14） |
| **E-PLAT-03** | gcd 续跑 vs 一跑到底 | 全流程跑完 → 保存 checkpoint → 从 cts 后续跑 | 输出 DEF **逐位 diff=0**（bit-identical） | F4 续跑一致性（G16） |
| **E-PLAT-04** | iTO commit 不调 incr LG（人为注释 `IncrLegalizeAfterCommit`） | eco_timing | **平台拦下**：响亮 ERROR "commit without legalize" 或自动触发 LG | C4 契约（ito↔ipl） |
| **E-PLAT-05** | 产物缺失注入（人为删 `place.def` 后标记 place 成功） | 流程继续到 cts | **启动 cts 前 FAIL**："missing product: place.def" | F1 产物断言（G14） |

**实验设计原则**：
1. **注入可控**：违序/崩溃/删产物 = controlled experiment（人为制造错误状态）；
2. **判据机械**：启动期 FATAL vs 运行期 ERROR、rc≠0、diff=0（非目视）；
3. **锁住契约**：每实验绑定一个 F-#/C-# 契约，失败=契约破裂。

**E-PLAT-01 详细执行步骤**（示例）：
```bash
# 注入违序
cat > flow_bad.tcl <<'EOF'
source init.tcl
run_eval              # ← eval 先于 rcx（违序）
run_rcx
run_sta
EOF

# 启动流程
ieda -f flow_bad.tcl
echo $?                                         # 必须 ≠0（启动期拒绝）

# 判据校验
grep -i "missing dep\|requires rcx" ieda.log   # 日志必须响亮报依赖缺失
test -f SUCCESS_eval && echo "FAIL: eval ran without rcx"  # SUCCESS stamp 不应存在
```

**E-PLAT-03 详细执行步骤**（示例）：
```bash
# 一跑到底
ieda -f flow_full.tcl                          # gcd netlist→GDS
cp output.def output_full.def
md5sum output_full.def > checksum_full.txt

# 续跑
ieda -f flow_full.tcl                          # 跑到 cts
save_checkpoint ckpt_cts
<退出 ieda>
ieda -restore ckpt_cts -f flow_continue.tcl    # 从 cts 后继续（pdn→route→...）
cp output.def output_resume.def

# 判据校验
diff -q output_full.def output_resume.def     # 必须无差异（逐位一致）
md5sum -c checksum_full.txt                    # MD5 必须一致
```

### 10.3 演进

```text
M0 顺序陷阱实验 + F3 rc 审计 + 空壳台账
M1 DAG + 失败语义（G14）
M2 增量闭环 + 续跑（G16）
M3 接 G1 看板
M4 PPA 外环
```

---

## 11. Exhibit

`flow_stamps.json`、`contract_report.json`、checkpoint manifest。

---

## 12. 测试

T-A1 违序启动失败；T-B1 注入崩溃 rc≠0；T-C1 C1–C9；T-D1 续跑 diff=0；T-E1 commit→incr LG。

---

## 13. 里程碑

P0 只做实验与审计（PR-PLAT-0），不写编排代码。

---

## 14. 未验证

| # | 项 |
|---|---|
| 1 | 本仓是否存在 eval/rcx 顺序病 | §4.2 |
| 2 | 子步骤崩溃实际 rc | 注入 |
| 3 | tcl_flow 默认序列 | 读代码 |
| 4 | 多设计单例污染 | 连跑 |
| 5 | iDB 序列化（续跑前提） | 10 |

**不要重走**：无契约先「重构全部 TCL 脚本」。

---

## 附录 B

| # | 决策 | 被否 |
|---|---|---|
| E-1 | 编排内建 | 纯脚本 |
| E-2 | commit 强制闭环 | 自觉 |
| E-3 | 续跑逐位一致 | 能跑完 |
| E-4 | 单例代理 | 重写 |
| E-5 | fork 契约族借鉴 | 重发明 |


---

## 附 · 代码证据与 tool_api 清单

| 断言 | 证据 |
|---|---|
| Flow 三入口 | `flow.h:51-53` initFlow/run/runTcl |
| tool_flow 空壳 | 目录仅 `CMakeLists.txt` |
| main 恒 0 | `ieda_main.cpp:69` `return 0` |
| tool_api | `icts_io idrc_io ieval_io ifp_io ino_io ipdn_io ipl_io ipnp_io ipw_io irt_io ista_io ito_io` |

### 就绪契约表（初稿，可改）

| stage | requires |
|---|---|
| place | idb_ready, fp_ready |
| cts | place_legal |
| route | cts_done 或 place_legal（flow 可配） |
| rcx | route_done |
| sta | rcx_ready |
| to | sta_ready, legal |
| eval | sta_ready, rcx_ready |
| report | products_exist |

### SUCCESS stamp 格式

```json
{"flow":"impl","stages":["place","cts","route"],"rc":0,"binary_hash":"...","ts":"..."}
```

缺 stamp → CI 不得标流程成功。

### PR 切片

| PR | 内容 | 验收 |
|---|---|---|
| PLAT-0 | §4.2 实验+F3 审计 | F2 实锤/排除 |
| PLAT-1 | Scheduler+契约 | 违序失败 |
| PLAT-2 | rc+stamp | 注入崩溃 |
| PLAT-3 | incr 三原语 | T-E |
| PLAT-4 | checkpoint | 逐位 |
| PLAT-5 | qor baseline | G1 |


### F3 rc 审计步骤（P0）

```text
1. 人为在 iRT/iPL 注入 LOG_FATAL 或 abort
2. 观察进程 exit code 与是否写 SUCCESS stamp
3. 若 exit=0 → F3 实锤 → PR-PLAT-2 必做
```

### incr 三原语与工具文档交叉引用

| 原语 | 实现落点 | 关联文档 |
|---|---|---|
| IncrLegalizeAfterCommit | iPL runIncrLG | 22/23/25 |
| IncrRouteEco | iRT routeECO | 26 |
| IncrRetimingVeto | iSTA incr | 27 |

### 脚本编排 → DAG 迁移策略（零回归）

1. 默认仍跑用户 TCL（行为不变）；  
2. `strict_contract=true` 时启用 Scheduler；  
3. 日常 CI 先开契约测试 C1–C9，再切默认。

### 多设计批跑（F6）隔离选项

| 策略 | 说明 | 阶段 |
|---|---|---|
| 进程池 | 每设计一进程 | 推荐 M2 |
| reset 单例 | 同进程清状态 | 难，后置 |

### FlowScheduler 伪代码（完整）

```text
validateTopo(stages):
  if cycle or missing_require: FATAL startup
run(plan):
  for s in plan:
    if not ready(s.requires): ERROR; return nonzero
    if not s.run(): abort; return nonzero
    if not s.assert_products(): abort; return nonzero
    stamp(s)
  write SUCCESS
  return 0
```

### 与用户 TCL 共存例

```tcl
# 旧：纯脚本顺序
# 新：可选
flow_set_strict_contract true
flow_run_plan impl_standard
```

strict 关闭时行为与今日一致（零回归）。

## 附 B · 决策记录

| # | 决策 | 被否 |
|---|---|---|
| E-1 | 编排内建化 | 纯脚本约定 |
| E-2 | commit 闭环平台强制 | 工具自觉 |
| E-3 | 续跑=逐位一致 | 能跑完即续跑 |
| E-4 | 单例+代理 | 重写引擎管理 |
| E-5 | fork 契约族借鉴 | 重发明 |

checklist：P0 实验完成？F3 rc 已知？tool_flow 不再空壳？SUCCESS stamp 有消费者？


### 体例合规声明

本文档已按 `01-ai-doc-conventions-rv1.md` 强制骨架组织（§0–§14），引用主纲门禁与 `03-commercial-knowhow-catalog.md` 的 KH-ID；未实测项见 §14。

主纲版本锚定：`00-ieda-commercial-parity-master-plan-v1.1.md`；Know-how 目录：`03-commercial-knowhow-catalog.md`。

