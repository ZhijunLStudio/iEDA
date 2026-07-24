<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 21 · iNO 网表优化（修复）· 商业对标方案 · rv2.1

> 文档号：21-rv2.1　　版本：rv2.1（实现评审优化）　　里程碑：**双对标 —— Genus/DC 网表修复质量线（关键度排序 + 平衡树拓扑 + 路径否决）× 性能线（秒级完成 + 增量 STA）**
> **范围裁定（保留）**：iNO ≈ **网表修复**（fix_fanout/fixIO），**不是** DC/Genus 综合（G18→`33-iLO-iTM`）
> 体例：`01-ai-doc-conventions-rv1.md`（对齐 `24-iPL-3d-rv1.0.md` 走读深度）
> 主纲：`00-ieda-commercial-parity-master-plan-v1.1.md`（G6/G14，与 iTO 协同）　Know-how：KH-TO-01、KH-SYN-01、KH-X-04
> 联合架构：`04-ppa-technical-review-and-optimization-rv1.md` 的 `MoveTxn + DirtySet`；闭环工作台：`51-agent-native-eda-detailed-plan-v1.0.md`
> 覆盖：`src/operation/iNO/` 全树（1129 LOC）：`FixFanout.{h,cpp}`、`NoApi.cpp`、`iNO.{h,cpp}`、`io/{JsonParser,DbInterface,Reporter}`、`config/NoConfig.h`、`test/run_no.cpp`
> 纪律：**文档是假说不是事实**；断言带 `file:line`；未实测写「未验证」。

---

## 0. 变更记录

| 版本 | 日期 | 修订人 | 说明 |
|---|---|---|---|
| v1.0–v1.1 | 2026-07-20 | parity | 范围裁定+摘要 |
| rv1.0 / v2.0 | 2026-07-20 | parity | 体例升格；坐实 FixFanout 真插 buffer、无 commit 后否决 |
| rv1.1 / v3.0 | 2026-07-21 | parity | **大改**：对 iNO 全树 13 个源文件（1129 LOC）逐行读完重写（`FixFanout.cpp` 271 行全读）。核心修订五条 |
| **rv2.0 / v4.0** | **2026-07-22** | **parity** | **大改（对照 27-iSTA.md 深度重写，双对标线显式化）**。核心修订五条：**(1)** 新增 **§1.5 ★功能完整性栈**（辅助工具的精度栈 = 功能覆盖 + 跨工具契约）——逐项清点与 Genus/DC 网表修复的差距：链式拓扑 vs 平衡树、容器序 vs 关键度排序、无 veto vs 路径否决、void API vs 响亮失败、全量 summary STA vs 增量模式、无物理感知 vs 位置聚簇，14 项差距中 **P0 级 5 项全是"能力缺失"（非算法精度）**；**(2)** 新增 **in-place 调用审计**（§1.4，类比 27 号 §1.4）：iTO/iNO **双修同网无冲突检测**（`NoApi::fixFanout` 与 `ViolationOptimizer::fixDrv` 各自插 buffer，**无共享 eco_txn、无修改锁、无变更日志对账**）——现状是"不撞车靠运气"；outputSummary 的全量 STA 重建（`NoApi.cpp:147-149`）在 iTO 循环内调用的墙钟占比**未量化**（E-NO-06 前提）；**(3)** 坐实 **fixFanout 链式拓扑的延迟特征**：深度 = ⌈(fanout−max)/(max−1)⌉ ≈ fanout/max（树是 log），**最远负载经过所有 buffer**（树只经 log 层），在 fanout=100、max=30 时链深度 ≈3 vs 树 ≈2，**但最关键的是容器序分配 → 关键负载不一定近根**——worst slack 路径延迟可比树多 1-2 级 buffer 延迟（未实测，E-NO-04 量化）；**(4)** rv1.1 提的"kClock 副作用"（`:134-136`）实测是**正确行为**——时钟网标记为 kClock 是为了在后续修复轮跳过，**不改则死循环**（时钟网高扇出但不应插 buffer）——归入"未文档化的正确实现"（FR-NO-07 降为 P2 文档化）；**(5)** **引入双对标线框架**（Genus/DC 线 = 修复质量，性能线 = 秒级 + 增量）：质量线差距 = 拓扑/关键度/veto（§1.5 上半），性能线差距 = summary STA/与 iTO 串行调用（§1.5 下半）；§10 拆成两块看板（10.1 质量看板、10.2 性能看板），与 27 号双对标结构对齐。rv1.1 的五条修订全部保留，本版在其上叠加结构性分析。 |
| **rv2.1** | **2026-07-23** | **Codex** | 实现评审：tree 模式拆为布局前有界扇出树与布局后容量约束几何聚簇；接受条件改为 DRV/合法性/时序/面积功耗的字典序门禁；共享 `MoveTxn/DirtySet` 与冲突图；禁止借改 `kClock` 充当遍历状态。 |
| **rv2.2** | **2026-07-24** | **Codex** | FR-NO-04 配置层落地：`NoConfig::validate` 拒绝空/纯空白 `insert_buffer`，`JsonParser` 改为异常响亮失败并修复空单例；新增 Release 有效的 L0 配置校验测试。API/TCL typed rc 仍属 FR-NO-03，M1 尚未整体关闭。 |
| **rv2.3** | **2026-07-24** | **Codex** | FR-NO-03/06 失败语义闭环：内核返回 `FixResult`，NoApi/ToolManager/TCL 逐层透传失败；无 load 网安全跳过，有 load 无 driver、缺 buffer master/pin、连接失败均停止并报错；删除 `connect()` 重复死分支。新增边界测试。FR-NO-02 事务回滚仍未实现，故失败可观测不代表整网原子回滚。 |

---

## 1. 症结审计（逐文件代码走读）

### 1.1 功能形态——两命令一配置的窄工具

| 模块 | 文件 | LOC | 判定 |
|---|---|---|---|
| 内核 | `FixFanout.{h,cpp}` | 69+271 | 全树唯一算法模块（fixIO + fixFanout 两入口） |
| API | `NoApi.cpp` | 192 | 薄转发 + initISTA + saveDef + outputSummary（全 void） |
| 驱动 | `iNO.{h,cpp}` | 49+70 | initialization/fixIO/fixFanout；**ASCII art banner 走 cout**（`:34-45,:54-63`） |
| 配置 | `NoConfig.h` + `JsonParser.{h,cpp}` | 75+42+84 | json 配置；`insert_buffer` 空仅 cout（`JsonParser.cpp:69-71`） |
| DB 桥 | `DbInterface.{h,cpp}` | 79+70 | idb/timing_engine 句柄 + eval_data |
| 报告 | `Reporter.{h,cpp}` | 52+49 | ofstream + 计时 |
| 测试 | `test/run_no.cpp` | 27 | **象征性**（一个 main） |
| TCL | `tcl_ino.cpp`/`tcl_noconfig.cpp` | — | `CmdNORunFixFanout`/`CmdNORunFixIO`/`CmdNOConfig` 三命令 |

### 1.2 算法成熟度（逐 kernel，`FixFanout.cpp` 全读）

| kernel | 现状算法（file:line） | 判定 | 缺口 |
|---|---|---|---|
| `fixFanout()` 主循环 | 遍历 STA netlist（`FOREACH_NET`，`:129`），`fanout>_max_fanout` → 修；时钟网改写 `kClock` 跳过（`:134-136`） | 可用 | **副作用未文档化**（kClock 改写）；违例网按容器序，无关键度排序 |
| `fixFanout(IdbNet*)` 修复体 | **贪心链式**（`:155-233`）：`while fanout>max`：新建 1 net + 1 buffer，buffer 入 pin 接原网、出 pin 接新网，**前 `max_fanout` 个负载挪新网**；原网负载数每轮降 `max_fanout-1` | **教科书以下**：链式非平衡树；负载按 `get_load_pins()` 容器序（`:159`），**无 slack/关键度优先** | 商业做法（拓扑平衡 + 关键负载近根 + 物理位置聚簇）整体缺失；无 legalize；无 veto |
| `fixIO()` | 每 IO pin：解开全部 instance pin → 新 net → IO 与原网之间插 buffer（`:35-119`）；方向匹配靠 pin direction 比较（`:73-83`） | **自承"临时"**（`:32-34`） | 方向匹配启发式未验证；buffer 放 `kNone` 无坐标 |
| `makeInstance` | `createInstance(..., kTiming, kNone, kNone, 0,0, kErrorIfExists)`（`:240-244`） | 可用 | `kNone` 放置态 → 下游必须容忍无坐标实例 |
| 网名交换（port 网） | STA adapter `swapNetNames` 或三次 rename（`:208-225`） | 可用 | 双路径语义等价性未验证 |
| `connect()` | pin 名匹配后 `connectPinToNet`（`:252-269`） | 有缺陷 | **if/else 两分支逐字相同**（`:258-262` 死分支）；`dinst` 空时直接用 `dpin` |
| 配置读取 | `insert_buffer` 空 → `cout << "[Config Info] insert_buffer is Null"`（`JsonParser.cpp:69-71`）继续跑 | **假成功温床** | 空 buffer 下 `makeInstance` 必失败（`LOG_ERROR_IF :182`），但**流程不中断、rc 不变** |
| `NoApi::outputSummary` | 销毁重建整个 TimingEngine 产"after"数据（`NoApi.cpp:147-149`） | **性能地雷** | summary 应付 incr STA；全量重建未量化 |
| `NoApi::initISTA` | readSdc→buildGraph→initRcTree→updateTiming（`:100-107`） | 可用 | 与 12-init_sta / 25-iTO 的 STA 引导是否重复，未审计 |

### 1.3 边界 / 回退 / 假成功

- **回滚：无**。修复直接改 iDB，无 txn/undo；veto 环缺失（v2.0 判定保留，且是本工具 P0）。
- **失败语义三层漏**：(a) 配置空 buffer 仅 cout；(b) `LOG_ERROR_IF`（`:182,:202-203`）记日志后继续，`:183-185` 虽 return 但 `:202-203` 之后**无检查**——`buf_input_pin` 为 null 时 `connect(insert_buf, nullptr, in_net)` 内 `dpin->get_pin_name()` 崩险；(c) API 全 void → TCL 恒 rc=0。
- **日志纪律**：ASCII art banner + 结果数字走 `cout`/`LOG_INFO` 混用（`iNO.cpp:34-63`、`FixFanout.cpp:144-150`）；`Reporter` 与 cout 双通道。
- 计数口径：`_insert_instance_index - 1`（`:145,:149`）依赖索引初值 1（`FixFanout.h`），初值改动即报表错一——**脆弱但未证错**。

### 1.4 跨工具协调

| 方向 | 现状 | 判定 |
|---|---|---|
| iNO → iDB | 直接 createInstance/createNet/disconnect/connect | 通（真改网表，v2.0 判定正确） |
| iNO → iSTA | 经 `TimingIDBAdapter` 取 fanout；`swapNetNames` | 通；但 fix 后**无 incr STA 刷新**——时序图与网表脱节直到下次全量 update |
| iNO ↔ iTO | 都可插 buffer，**无分工协议** | 同网双修无冲突检测（v2.0 判定保留） |
| iNO → iPL | 新 buffer `kNone` 无坐标 | 布局前 OK；布局后无 legalize 闭环（→40 incr LG） |
| iNO → iLO/iTM | 综合/映射不在此 | 边界清晰（范围裁定保留） |

---

## 2. 需求 FR / NFR / 约束

| ID | 需求 | 现状 | P |
|---|---|---|---|
| FR-NO-01 | FixFanout/FixIO 保持 | ✓ | — |
| FR-NO-02 | ★ commit 后 incr STA；Δslack≤0 回滚（txn 语义与 25-iTO 同库） | ✗ | P0 |
| FR-NO-03 | ★ API 返 bool/SolverResult 式状态；TCL rc 透传 | ✓ `FixResult`→bool→TCL rc 已接通；端到端 Tcl 运行待全量链接验证 | P0 |
| FR-NO-04 | ★ 空 insert_buffer 响亮失败（配置校验前置） | ✓ 空/空白与非法 max fanout 前置拒绝，异常由 NoApi 转 bool | P0 |
| FR-NO-05 | ★ 平衡树 fanout 修复（关键负载近根 + slack 排序） | ✗（链式） | P1（§4.2） |
| FR-NO-06 | ★ `connect()` 死分支清理 + `LOG_ERROR_IF` 后崩险修复 | ✓ 重复分支删除；空端点改 typed failure | P0（卫生） |
| FR-NO-07 | ★ 时钟识别只读化：使用 STA clock 查询或局部 visited，移除持久 `kClock` 改写 | 隐蔽副作用 | P1 |
| FR-NO-08 | ★ `outputSummary` 改 incr STA（禁全量重建）或标注成本 | 全量重建 | P1 |
| FR-NO-09 | 有坐标才启用物理感知放置（经 40 incr LG） | ✗ | P1 |
| NFR-NO-01 | 假成功 0（配置/修复/汇报三层） | G14 | |
| NFR-NO-02 | 缺省关 veto → 数值零回归 | 红线 | |
| NFR-NO-03 | 不承担 G18 | 范围 | |

---

## 3. HLD 总体架构

### 3.1 数据流

```text
高扇出/IO 违例
  → 配置校验（★空 buffer 响亮失败）
  → FixFanout/FixIO（TimingIDBAdapter 改 iDB）
  → ★ dirty RC + setup/hold incr STA + veto（与 25-iTO 共享 MoveTxn/DirtySet）
  → ★ IncrLegalizeAfterCommit（40，若已有坐标）
  → 报告（inserts/rollbacks/ΔWNS 独立列）
```

### 3.2 关键设计决策（含被否）

| # | 决策 | 被否 |
|---|---|---|
| D1 | iNO=修复非综合（保留 v2.0） | 用 iNO 扛 G18 |
| D2 | 否决环与 iTO 同库同配置键 | 两套回滚/两套"可接受恶化" |
| D3 | **先补失败语义（FR-NO-03/04/06）再谈算法升级（FR-NO-05）** | 在假成功地基上换平衡树 |
| D4 | 平衡树修复做成**可选模式**（`fanout.mode=chain|tree`，默认 chain 零回归） | 直接替换默认行为 |
| D5 | `outputSummary` 保留但标注全量重建成本；incr 化排 P1 | 立即重写（影响面未审计） |
| D6 | 布局前可不 LG；布局后必经 40 incr LG | 从不合法化 |
| D7 | 时钟网跳过使用只读查询或局部 `visited` 集 | 把持久 `net_type=kClock` 当临时遍历标记；语义污染会泄漏给 CTS/STA |

---

## 4. LLD · 模块分解

### 4.1 ★ 失败语义地基（FR-NO-03/04/06，P0）

**实现状态（2026-07-24）**：FR-NO-03/04/06 代码已完成。`ino_config_validation_test` 锁定空配置/非法 fanout，`ino_failure_semantics_test` 锁定无 load 跳过和有 load 无 driver 失败；`JsonParser::get_json_parser()` 同时从未初始化静态指针修为函数内静态对象。五个生产对象已编译，端到端 Tcl 运行仍待全量链接验证。FR-NO-02 的 `MoveTxn` 未落地，已有多个 insertion 后的罕见后续写失败仍可能留下部分修改，调用链会停止并报失败但不会整网回滚。

**现状签名（已实现）**：`FixResult FixFanout::fixIO/fixFanout()` → `bool iNO/NoApi::fixIO/fixFanout()` → ToolManager bool → TCL `0/1`。

```text
ALG-4.1-1  失败语义三层修复
  [配置层] JsonParser 读完即校验：insert_buffer 空 / master 不存在 → ERROR rc≠0（FR-NO-04）
  [内核层] FixFanout 两入口返 FixResult{ok, inserted, rolled_back, msg}；
           LOG_ERROR_IF(:182,:202-203) 改为"检查+失败上抛"（消 :202-203 崩险）
  [API/TCL 层] NoApi 返 bool；Cmd*::exec 透传（G14）
  [卫生] connect() 删死分支（:258-262）
```

### 4.2 ★ 平衡树 fanout 修复（FR-NO-05，P1，`fanout.mode=tree`）

**现状**：链式（§1.2）。**设计**：

```text
ALG-4.2-1  treeFixFanout(net)   # ★ 新增，与 chain 并存（D4）
  if pre_place:
    以 (cap,slew,max_fanout) 为容量约束，自底向上构造近似平衡树；
    关键负载只决定靠近根的层级，不用 slack 排序代替拓扑/容量约束
  else:
    loads 按坐标做 capacitated clustering（递归二分或有容量 k-median）
    每簇满足 ΣCload≤Cmax、fanout≤Fmax、估算 slew≤Smax；
    cluster root 取合法 site 候选，关键负载在同等容量下靠近上游
  对每个候选 buffer master 做离散 DP，状态=(cap,delay,slew,area,power)，支配剪枝
  复杂度：聚簇 O(fanout log fanout)，master DP 与库候选数成正比
  边界：fanout≤max 不动；真实 clock net 只读跳过；无合法位置则报告不可修而非污染 net type
  验收：DRV 清、setup/hold guardband 满足、总 buffer/area/power 独立报告
```

**复用姿势**：自建（修复拓扑是 iNO 本体职责）；veto 复用 25-iTO eco_txn（D2）。

### 4.3 ★ veto 环（FR-NO-02，P0，与 25 对齐）

```text
txn = MoveTxn.begin(design_state_version)
apply fix（chain 或 tree）；产出 DirtySet{insts,nets,rc_arcs,timing_cones,rows}
if placed and !IncrLegalizeAfterCommit(dirty.rows): rollback(kIllegal)
update_rc(dirty.nets); incr_sta_setup_hold(dirty.timing_cones)
按字典序验收：
  1. connectivity/legal 必须 PASS；目标 fanout/cap/slew DRV 必须减少且不得新增更高优先级 DRV
  2. setup/hold 均不得越过 guardband；“为修 DRV 允许局部 slack 小幅下降”必须显式预算
  3. 在 1/2 均通过后，才比较 area/power/buffer_count 的 Pareto 改善
通过则 commit 并递增 state/RC/STA version；否则恢复 iDB、放置、RC cache、STA version
配置键与 iTO 同一：eco.max_slack_degrade（缺省关 → 零回归 NFR-NO-02）
```

多个 net 可先生成候选，再按共享 net/row/timing cone 建冲突图；同一颜色批量提交、批末一次增量 RC/STA。这样减少逐 move 固定开销，同时保持确定性提交顺序。

### 4.4 `outputSummary` 成本标注（FR-NO-08，P1）

现状全量重建（`NoApi.cpp:147-149`）。P1 改 incr STA 差分；过渡期内**在文档与日志显式标注**"summary 成本 = 一次全量 STA"，大设计默认关闭。

### 4.5 模块状态一览

| 模块 | 现状成熟度 | 主复杂度 | 关键边界 | 复用姿势（现状→目标） |
|---|---|---|---|---|
| `fixFanout` 主循环 | 可用 | O(nets) | kClock 持久语义副作用（FR-NO-07） | 保留遍历，改为只读 clock 查询/局部 visited |
| `fixFanout(net)` 链式修复 | 教科书以下 | O(fanout²/max)（while 重取 load_pins） | fanout≤max 不动；port 网改名 | 保留为 chain 模式；★tree 并存 |
| `fixIO` | 自承"临时" | O(io_pins) | 方向匹配启发式 | 保留 + 失败语义 |
| `connect` | 有死分支 | O(buf_pins) | null pin 崩险 | 修（§4.1） |
| JsonParser | 可用 | — | 空 buffer 仅 cout | 前置校验 |
| NoApi | 全 void | — | 失败不可观测 | 返 bool |
| `outputSummary` | 性能地雷 | 全量 STA | 大设计默认关 | incr 化（P1） |
| Reporter | cout/ofstream 双通道 | — | 口径混用 | 统一到 Reporter |

---

## 5. 配置

| 键 | 默认 | 说明 |
|---|---|---|
| `insert_buffer` | **必填**（空→ERROR） | FR-NO-04 |
| `max_fanout` | 现状 | |
| `fanout.mode` | `chain` | ★ `tree` 可选（FR-NO-05，D4 零回归） |
| `enable_timing_veto` | false | ★ FR-NO-02；与 iTO 同 `eco.*` 键族 |
| `eco.setup_guardband` / `eco.hold_guardband` | 协议给定 | DRV 修复允许的显式时序预算，禁止隐式 `Δslack>0` |
| `eco.batch_size` | 1 | >1 时按冲突图着色批量验证 |

---

## 6. 指标分解

| 维 | 含义 | 记录 |
|---|---|---|
| inserted_buffers / inserted_nets | | 独立列 |
| rolled_back | veto 回滚次数 | 独立列 |
| ΔWNS / ΔTNS / DRV 前后 | | 独立列（进 12 schema 候选） |
| chain vs tree 对比 | critical 到达时间、buffer 数 | E-NO-04 |
| summary_cost_s | outputSummary 墙钟 | 标注全量重建 |

---

## 7. 状态机 / 命令语义

```text
init_config → check_config(★空 buffer ERROR) → fix → ★veto? → commit/rollback
  → ★(placed → incr LG) → report
任一层失败 rc≠0；API 返 bool；TCL 透传
```

---

## 8. 跨工具 Cascade

| 上/下游 | 信号 | 契约 |
|---|---|---|
| ← iSTA | fanout/slack（incr） | veto 与 tree 排序的输入 |
| → iDB | 网表真改 | txn 可回滚（FR-NO-02） |
| ↔ 25-iTO | eco_txn 同库同键；同网双修冲突检测 | 分工矩阵（下） |
| → 40 platform | IncrLegalizeAfterCommit | 布局后必经 |
| → iPL | kNone 新实例 | 布局前插入时由后续 GP 处理 |

分工矩阵（保留 v2.0）：综合后扇出/IO → iNO（G6/G14）；布局后时序 → iTO（G6/G17）；逻辑映射 → iLO/iTM（G18）。

---

## 9. 商业 Know-how 映射

| KH-ID | 本工具落点 |
|---|---|
| KH-TO-01（修复后否决） | §4.3 veto 环 |
| KH-SYN-01（物理感知可选） | FR-NO-09 |
| KH-X-04（空配置/失败响亮） | §4.1 三层修复 |

---

## 10. 商业对照看板 + 演进 M0–M4

### 10.1 看板

| 指标 | iNO | 商业 fanout fix | 门槛 | G |
|---|---|---|---|---|
| DRV/fanout 清 | 链式可清 | 平衡树+关键度 | 清或可解释 | G6 协同 |
| 修复拓扑 | 链（深度 O(n/max)） | 树（O(log)） | tree 模式达标 | — |
| 否决回滚 | 无 | 有 | 注入必滚 | G14 |
| 失败可观测 | 全 void | 响亮 | rc≠0 | G14 |
| 综合 QoR | N/A | DC | →33 | G18 |

### 10.2 对照实验（杀假说）

| 实验 | 方法 | 杀死条件 |
|---|---|---|
| E-NO-01 | 空 insert_buffer 跑 fix | rc==0 → §1.3 实锤（修复后必≠0） |
| E-NO-02 | 关 veto 看 WNS 变化 | 变差 → veto 必要性 |
| E-NO-03 | 注入恶化修复（mock incr STA） | 不回滚 → veto 假 |
| **E-NO-04** | 同设计 chain vs tree：critical load 到达时间/buffer 数 | tree 不优 → FR-NO-05 价值被杀（降级 P2） |
| E-NO-05 | 与 iTO 同网双修 | 无冲突检测 → 分工协议必要性实锤 |

### 10.3 演进

```text
M0 先量：失败语义台账（E-NO-01）+ 链式结构实测量化（链深度/关键负载位置）
M1 可信：§4.1 三层失败语义 + 死分支/崩险修复 + gtest
M2 主算法：veto 环（与 25 同库）+ 40 incr LG 接线
M3 打平：tree 模式（E-NO-04 裁决后）+ 与 iTO 分工用例集
M4 纵深：物理感知放置 + outputSummary incr 化
```

退出门禁：M0→台账；M1→E-NO-01 绿；M2→E-NO-03 绿；M3→E-NO-04 裁决记录。

---

## 11. Exhibit

| 档 | 产物 |
|---|---|
| JSON | `no_report.json`（inserts/rollbacks/Δslack/mode） |
| text | `report.txt`（现状保留，口径统一到 Reporter） |

---

## 12. 测试计划

| 层 | 用例 | 锁住 |
|---|---|---|
| L0 | 空 buffer → ERROR rc≠0 | FR-NO-04 |
| L0 | 无 load 网跳过；有 load 无 driver → typed failure | FR-NO-06 |
| L0 | 否决注入必回滚 | FR-NO-02 |
| L0 | 小网（fanout≤max）不动；时钟网跳过 | 现状语义 |
| L0 | chain vs tree 拓扑深度 | FR-NO-05 |
| L1 | gcd fanout 修复后 DRV 清 + incr STA 一致 | G6 |
| L1 | 布局后修复经 incr LG 合法 | FR-NO-09 |
| L5 | 不宣称 G18；缺省 veto 关零回归 | NFR-NO-02/03 |

---

## 13. 里程碑（按周粗估）

| 周 | 交付 | 验收 |
|---|---|---|
| W0 | M0 台账 + 范围锁定重申 | M0 |
| W1 | §4.1 失败语义三层 + 卫生修复 | M1 |
| W2 | veto 环 + 40 incr LG | M2 |
| W3+ | tree 模式（E-NO-04 裁决）+ iTO 分工用例 | M3 |

PR 切片：NO-0 台账 → NO-1 失败语义+卫生 → NO-2 veto 环 → NO-3 incr LG → NO-4 tree 模式（裁决后）。

---

## 14. 未验证 / 负面结论

| # | 项 | 说明 |
|---|---|---|
| 1 | 链式修复的实际 QoR 损失 | 结构分析为链式，但未在真实设计上量化 vs 树——E-NO-04 前提 |
| 2 | fixIO 方向匹配启发式正确率 | 自承"临时"（`:32-34`），无用例 |
| 3 | `swapNetNames` vs 三次 rename 语义等价 | `:208-225` 双路径未对拍 |
| 4 | `_insert_instance_index` 初值依赖 | `:145` 的 `-1` 口径脆弱，未证错 |
| 5 | `outputSummary` 全量重建的墙钟占比 | 未量化 |
| 6 | 与 iTO buffer 命名/实例冲突 | 分工协议前未验证 |
| 7 | initISTA 与 12-init_sta/25-iTO 的重复度 | 三处 STA 引导未审计 |
| 8 | 失败后的整网原子性 | FR-NO-03/06 已能停止并上抛；FR-NO-02 前，多轮 insertion 后的罕见写失败仍无整网 rollback |

**不要重走**：
- 不要把 ABC/综合塞进 iNO（范围裁定）。
- 不要在全 void API 上继续加功能——先补失败语义地基（D3）。
- 不要把 chain 直接替换成 tree 改默认——并存可选，E-NO-04 裁决后再谈切换。

---

## 附录 A · 迁移 checklist

- [ ] M0 台账（失败语义三层 + 链式结构量化）
- [x] JsonParser 前置校验（空/纯空白 buffer ERROR；L0 配置测试已落地）
- [x] FixFanout 两入口返 FixResult；`:202-203` 崩险修复
- [x] `connect()` 死分支清理
- [x] NoApi 返 bool；TCL rc 透传（对象编译通过；端到端运行待全量链接）
- [ ] veto 环（eco_txn 与 25 同库同键）
- [ ] 40 IncrLegalizeAfterCommit 接线
- [ ] clock net 只读跳过；遍历使用局部 visited，禁止修改持久语义类型
- [ ] tree 模式（E-NO-04 裁决后）
- [ ] outputSummary 成本标注 / incr 化

## 附录 B · 关键决策记录

| # | 决策 | 被否 |
|---|---|---|
| E-1 | 修复≠综合 | iNO 扛 G18 |
| E-2 | 先失败语义后算法 | 在假成功地基上换算法 |
| E-3 | 否决与 iTO 同库同键 | 平行回滚 |
| E-4 | tree 与 chain 并存可选 | 直接替换默认 |
| E-5 | 缺省关 veto 零回归 | 强改默认行为 |
| E-6 | summary 标注成本缓重写 | 立即重写（影响面未审） |

## 附录 C · 术语

- **链式修复**：每 buffer 取 max 个负载挂原网，深度 O(fanout/max) 的一串（现状）
- **平衡树修复**：深度 O(log_max fanout)、关键负载近根的拓扑（FR-NO-05 目标）
- **eco_txn**：begin/apply/incr_sta/commit-or-rollback 事务语义（与 25-iTO 共享）
- **kNone 放置态**：新实例无坐标状态，需下游 GP/LG 消化

## 附录 D · 证据摘录（file:line 最小集）

| 断言 | 证据 |
|---|---|
| 链式修复 | `FixFanout.cpp:155-233`（while 循环 + `:206` 前 max 个负载） |
| 负载无关键度排序 | `FixFanout.cpp:159`（`get_load_pins()` 容器序） |
| kClock 副作用 | `FixFanout.cpp:134-136`（`setNetConnectType`） |
| fixIO 自承临时 | `FixFanout.cpp:32-34`（"临时修复io问题…联系zzs"） |
| 死分支 | `FixFanout.cpp:258-262`（if/else 逐字相同） |
| LOG_ERROR_IF 不中断 | `FixFanout.cpp:182,:202-203` |
| 空 buffer 仅 cout | `JsonParser.cpp:69-71` |
| API 全 void | `NoApi.cpp:110-112` |
| outputSummary 全量重建 | `NoApi.cpp:147-149`（`destroyTimingEngine(); initISTA`） |
| initISTA 全链 | `NoApi.cpp:100-107` |
| ASCII banner cout | `iNO.cpp:34-45,:54-63` |
| buffer kNone | `FixFanout.cpp:66-68,:96-98,:240-244` |
| TCL 三命令 | `tcl_ino.cpp:36,65`、`tcl_noconfig.cpp:37` |
| 全树体量 | `find src/operation/iNO -name '*.cpp' -o ... | xargs wc -l` = 1129 |
