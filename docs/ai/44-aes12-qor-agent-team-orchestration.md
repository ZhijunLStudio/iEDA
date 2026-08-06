<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 44 · AES12@65% QoR 推进 · 多 Agent 编排与质量把控方案 · rv1.2

> 文档号：44-rv1.2　　版本：rv1.2　　日期：2026-07-31
> 绑定路线图：[`43-aes12-65pct-qor-optimization-roadmap.md`](43-aes12-65pct-qor-optimization-roadmap.md) **（算法/C++ 落点手册见 43 §13）**
> 纲领：`00` / `04`；评测：`12-evaluation`；性能纪律：`42`
> 目的：按 Wave-0→4 与工具×指标优先级，用**多 Agent**完成整体调度、分工具算法改造、质量与指标把控。
> 纪律：每个 WP 单一假说；缺省关闭新杠杆→零回归；无 SPEF 的 WNS / 无活动率的 Power / 无 PDN 的 IR **不得进 QoR 绿灯**；假 clean 一票否决。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| **rv1.0** | **2026-07-30** | 首版：冻结 1 主控 + 1 质量官 + 3 真值 + 4 实现链 + 2 电源 + 1 平台 + 1 基准执行 = **13 Agent**；定义依赖图、交接契约、日报协议、门禁矩阵与启动提示词路径。 |
| **rv1.1** | **2026-07-31** | 对齐用户重心：实现链 Agent 的主交付必须是 `src/operation/<tool>/` **C++ 算法改造**；目标 AES@65% 指标 **≥20%**。Flow/BEST_EFFORT 不得记为 QoR Done。Wave-1（DRC/WL）可与 Wave-0 后半**有限并行**（DRC 门禁不依赖 SPEF）。 |
| **rv1.2** | **2026-07-31** | 新增 **§1.2 Agent↔算法/C++ 落点索引**（指向 43 §13）；工单强制写「主改函数清单」。 |

---

## 1. 团队总览

```text
                    ┌─────────────────────────────────────┐
                    │  A0  Orchestrator（总编排）          │
                    │  Wave 开闸 / WP 分发 / 冲突仲裁 / 合入 │
                    └───────────────┬─────────────────────┘
                                    │
              ┌─────────────────────┼─────────────────────┐
              ▼                     ▼                     ▼
    ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
    │ A1 Quality Guard │  │ A12 Bench Runner │  │ A11 Platform     │
    │ 指标真伪/门禁/A/B │  │ AES12 复跑与产物 │  │ DirtySet/MoveTxn │
    └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘
             │ 否决权               │ 基线/回归            │ 契约
    ┌────────┴─────────────────────┴─────────────────────┴────────┐
    │                                                              │
    │  Team-T 签核真值          Team-I 实现链           Team-P 电源  │
    │  A2 iRCX   A3 iSTA       A5 iRT   A6 iDRC        A9 iPNP     │
    │  A4 iPA                  A7 iPL   A8 iTO/iCTS    A10 iIR     │
    └──────────────────────────────────────────────────────────────┘
```

| ID | 代号 | 角色 | 绑定 WP | 主指标责任 |
|---|---|---|---|---|
| **A0** | `orch` | 总编排 / 调度 | 全部 Wave 开闸与合入 | 进度、依赖、冲突 |
| **A1** | `qguard` | 质量与指标把控 | §6 全部门禁 | 真伪、≥20%、红线 |
| **A2** | `rcx` | iRCX 真值 | WP-RCX-01 | SPEF / net delay |
| **A3** | `sta` | iSTA 真值+增量 | WP-STA-01, WP-STA-02 | WNS/Fmax 可信、PBA |
| **A4** | `pa` | iPA 功耗真值 | WP-PA-01 | Power / 电流源 |
| **A5** | `rt` | iRT 外环/协商拥塞 | WP-RT-01, WP-IRT-MAP-01 | DRC / EGR WL |
| **A6** | `drc` | iDRC 反馈契约 | WP-DRC-01 | DRC 签核闭环 |
| **A7** | `pl` | iPL 可布线布局 | WP-PL-01 | EGR WL / 下游 DRC |
| **A8** | `tocts` | iTO + iCTS | WP-TO-01, WP-CTS-01 | WNS / Fmax / Power |
| **A9** | `pnp` | iPNP/iPDN | WP-PNP-00, WP-PNP-01 | IR 前置与条带优化 |
| **A10** | `ir` | iIR 求解 | WP-IR-01 | IR-drop |
| **A11** | `plat` | platform 契约 | WP-PLT-01 | 事务/增量一致性 |
| **A12** | `bench` | AES12 执行与回归 | 全 Wave 复跑 | 可复现产物 |

> 旧文档 `agent_team_plan.md` / `agent-team-plan.md` 仍保留历史；**自 2026-07-30 起，AES12@65% QoR 推进以本文为唯一编排源**。

### 1.1 交付定义（rv1.1）

| 算 Done | 不算 Done |
|---|---|
| 在 `src/operation/<你的工具>/`（或 A11 的 `src/platform/`）合入可开关的 C++ 算法改动 | 只改 `benchmarks/flows`、Tcl、JSON、env 截断 |
| A/B 显示目标指标 ≥20%（或本 WP 规定阈值），且缺省关闭零回归 | BEST_EFFORT / MAX_BOXES 把流程「跑通」 |
| 对照实验 + AES@65% artifact + A1 签发 | 无假说、无杀死实验的大 diff |

**实现链优先级（冲 ≥20% 数字）**：`A5 iRT` → `A6 iDRC` → `A7 iPL`（Wave-1 DRC/WL）→ `A8 iTO/iCTS`（Wave-2，需 SPEF）→ `A9/A10`（Wave-3 IR）。

### 1.2 Agent ↔ 算法 / C++ 落点索引（rv1.2）

> 权威细则在路线图 **[43 §13](43-aes12-65pct-qor-optimization-roadmap.md)**。下表是编排侧速查；工单必须抄「主改函数」列。

| Agent | 工具 | 算法级动作（一句话） | 主改 C++（开工必读） | 43 小节 |
|---|---|---|---|---|
| A2 | iRCX | SPEF 强制 + pattern RC；禁静默跳过 | `Extraction.*` / `CapacitanceCalc.*` / `ResistanceCalc.*` | §13.2 |
| A3 | iSTA | 约束完备 + dirty cone 增量 + top-N PBA | `Sta.*` / `ElmoreDelayCalc.*` / `TimingEngine.*` | §13.3 |
| A4 | iPA | 活动率传播 + 分项 Power + `activity_source` | `Power.*` / `PwrPropagateToggleSP` / `PwrCalc*` | §13.4 |
| A5 | iRT | plateau→冲突分量 escalate + 规则代价 + PRL/short repair | `DetailedRouter.cpp` / `DRConflictEscalate.hpp` / `DRRuleAwareCost.hpp` | §13.1 |
| A6 | iDRC | C-VIO JSON + in-design short/spacing/min-area | `DRCInterface::outputCVioJson` / `RuleValidator` | §13.5 |
| A7 | iPL | RUDY→`density_scale` inflation + 回退；缺省 OFF | `NesterovPlace::inflateInstancesByRouteUtil` | §13.6 |
| A8 | iTO | 候选批 + MoveTxn 精确 STA 否决 | `SetupOptimizer` / `HoldOptimizer` / `VGBuffer` / `MoveTxn` | §13.7 |
| A8 | iCTS | BST + buffer DP + useful skew | `BSTRouter` / `TopologyGen` / `Optimization` | §13.8 |
| A9 | iPNP/iPDN | 真实 PDN + SA 敏感度 | `PdnPlan` / `PdnOptimizer` / `SimulatedAnnealing` | §13.9 |
| A10 | iIR | `Gv=i` + 热图 + residual | `IRSolver` / `PGNetlist` | §13.10 |
| A11 | platform | MoveTxn / DirtySet / ArtifactIndex | `MoveTxn.cpp` / `DirtySet.cpp` | §13.11 |
| A12 | bench | 只跑数；禁止改算法冒充 | `benchmarks/` | — |

**工单模板增量字段（A0 强制）：**

```text
src_paths=src/operation/<tool>/...
primary_functions=<Class::method>, ...
algorithm_ref=43 §13.x
default_off=yes
kill_experiment=E-...
```

---

## 2. 角色职责（详细）

### 2.1 A0 · Orchestrator（总编排）

**唯一可做的事：**

1. 维护 Wave 状态机：`locked → open → in_progress → gate_review → closed`。
2. 按 §3 依赖图发 WP 工单（不得跳过 T0 真值就开 T2 WNS 门禁）。
3. 仲裁跨工具接口冲突（例：iRT 要的 violation JSON schema vs iDRC 输出）。
4. 批准合入：**必须先过 A1 Quality Guard**。
5. 更新协调板 [`agents/COORDINATION_BOARD.md`](agents/COORDINATION_BOARD.md) 与日报。
6. 杀掉无效假说：对照实验失败的 WP → `closed_wont_fix`，禁止扩参掩盖。

**禁止：**

- 直接改工具内核替代工具 Agent（可做小范围集成胶水除外）。
- 在 A1 红灯时强行标 Wave 完成。
- 用 util/padding DOE 或 BEST_EFFORT 截断替换算法 WP。
- 把「flow 贯通」记为 QoR 里程碑完成。

**退出物：** 每周 `docs/ai/agents/weekly_orch_YYYYMMDD.md`（进度、阻塞、下一闸口）。

**A0 对实现链的硬要求：** 每个 WP 工单必须写明 `src_paths=`（至少一个 `src/operation/...` 或 `src/platform/...` 路径）+ `primary_functions=`（43 §13 中的类/函数）+ `algorithm_ref=43 §13.x`；缺省则工单无效。

---

### 2.2 A1 · Quality Guard（质量与指标把控）— **一票否决**

**核心职责：**

| 职责 | 细则 |
|---|---|
| 真伪门禁 | 无 SPEF → WNS/Fmax 拒收；`switch_power=0` 无标签 → Power 拒收；无 PDN → IR 拒收；DRC residual 仍 success → FAIL |
| ≥20% 判定 | 相对 **Wave-0 冻结基线**（非 7/30 虚标报告）计算；负 slack 用绝对改善 |
| A/B 协议 | 强制同输入 manifest、同 `binary_sha256`、同 threads；记录 delta JSON |
| 回归守护 | 任何合入不得使 DRC 显著变差（阈值由协调板冻结） |
| 证据分级 | D0–D4（对齐 `00`/`04`）；无三联证据（code+test+artifact）不得升 D2+ |
| 报告签发 | 只有 A1 可把指标标为 `trusted` / `proxy` / `invalid` |

**门禁检查清单（每个 WP Done 前必跑）：**

```text
[ ] 假说与杀死实验已记录
[ ] 主 diff 落在 src/operation/<tool>/ 或 src/platform/（flow-only → REJECT）
[ ] 缺省配置零回归（新杠杆关闭）
[ ] A/B delta 进入 benchmarks/qor 或约定 JSON
[ ] 指标标签：trusted | proxy | invalid
[ ] ≥20% 相对 Wave-0 冻结基线可复核（或本 WP 规定阈值）
[ ] 红线未触碰（假 success / 假时序 / 假功耗 / 假 IR）
[ ] A12 复跑产物 hash 可追溯
```

**否决话术模板：**
`REJECT <WP-ID>: reason=<红线名>; evidence=<path>; required_fix=<...>`

---

### 2.3 Team-T · 签核真值（Wave-0 主责）

#### A2 `rcx` — iRCX

- **WP：** WP-RCX-01
- **交付：** post-route SPEF 强制；pattern + dirty halo；缺 SPEF 非零退出
- **验收信号给 A1：** 关键路径 `net delay > 0`
- **上游：** A12 提供 DEF；**下游：** A3 必须读 SPEF
- **文档：** `28-iRCX.md`；阻塞参考 `IRCX_SPEF_UNBLOCK_PLAN.md`

#### A3 `sta` — iSTA

- **WP：** WP-STA-01（Wave-0）、WP-STA-02（Wave-2）
- **交付：** unconstrained=0；增量 DirtySet；top-N PBA（Wave-2）
- **验收：** 约束覆盖绿；增量 vs full 一致
- **依赖：** A2 SPEF；A11 DirtySet 接口
- **文档：** `27-iSTA.md`

#### A4 `pa` — iPA

- **WP：** WP-PA-01
- **交付：** 活动率来源标签；分量拆分；供 A10 电流源
- **验收：** `switch_power>0` 或诚实 `vectorless` 标签且 A1 标 `proxy`
- **文档：** `29-iPA-iIR.md`

---

### 2.4 Team-I · 实现链（Wave-1/2 主责）

#### A5 `rt` — iRT

- **WP：** WP-IRT-MAP-01（可先于外环）、WP-RT-01
- **交付：** congestion 汇总无 `-1`；plateau 外环；规则代价；timing cost 接线；residual → 失败
- **主指标：** DRC ↓≥50% 路径；EGR/routed WL
- **依赖：** A6 violation schema；A7 可布线放置；A3 timing（Wave-1 可先关 timing 杠杆做 DRC）
- **文档：** `26-iRT.md`

#### A6 `drc` — iDRC

- **WP：** WP-DRC-01
- **交付：** in-design 子集；`(type,layer,bbox,net_ids,severity)` JSON；checked/skipped/unsupported
- **依赖：** 与 A5 共同冻结 schema（A0 仲裁）
- **文档：** `30-iDRC.md`

#### A7 `pl` — iPL

- **WP：** WP-PL-01
- **交付：** 稳定初值；RUDY→GR→inflation；增量 LG
- **主指标：** EGR WL / overflow ↓≥20%
- **依赖：** A5 early GR 校准接口；A11 增量 LG
- **文档：** `22-iPL.md`

#### A8 `tocts` — iTO + iCTS（同一 Agent，分阶段 WP）

- **WP：** WP-TO-01、WP-CTS-01（**仅 Wave-0 真值绿后启动**）
- **交付：** MoveTxn 候选+否决；buffer DP；useful skew
- **主指标：** WNS/Fmax/Power ≥20%
- **依赖：** A3/A2/A4 trusted；A11 MoveTxn；A7 incr LG
- **文档：** `25-iTO.md`、`23-iCTS.md`
- **内部顺序：** 先 TO DRV/setup 骨架，再 CTS useful skew（避免双端同时改时钟）

---

### 2.5 Team-P · 电源（Wave-0 前置 + Wave-3）

#### A9 `pnp` — iPNP/iPDN

- **WP：** WP-PNP-00（进 flow）、WP-PNP-01（sensitivity）
- **交付：** 真实 PDN；条带/via 优化；supply 占位给 A5
- **文档：** `24-iPDN-iPNP.md`

#### A10 `ir` — iIR

- **WP：** WP-IR-01
- **交付：** `Gv=i`；worst/avg/map/residual；浮空节点失败
- **依赖：** A9 PDN；A4 电流（否则 `proxy`）
- **文档：** `29-iPA-iIR.md`

---

### 2.6 A11 `plat` · Platform（贯穿）

- **WP：** WP-PLT-01
- **交付：** DesignState / DirtySet / MoveTxn / ArtifactIndex；FlowScheduler 失败语义
- **服务对象：** A3/A5/A7/A8 优先
- **文档：** `40-platform.md`、`04` §3–4
- **规则：** 工具 Agent 新增「全量重建 STA/RC」路径必须经 A11 评审，默认禁止。

---

### 2.7 A12 `bench` · Benchmark Runner

- **职责：** 按 A0 工单跑 AES12（或 daily 子集 sky130+nangate45）；固定 seed/manifest；产出 stage artifact + QoR JSON
- **禁止：** 解释「业务上是否达标」（那是 A1）；禁止改算法代码
- **交付：** `benchmarks/results/<run_id>/` + 对比报告增量
- **工具：** `benchmarks/flows/aes13_flow.py` 及现有 runner

---

## 3. Wave 状态机与依赖图

### 3.1 Wave 开闸条件

| Wave | 开闸条件（全部满足） | 主责 Agent | 并行许可 |
|---|---|---|---|
| **0** | 立即 | A2/A3/A4/A5(map)/A9(00)/A11/A12 | T 组全并行；A5 仅 MAP；A9 仅 PNP-00 |
| **1** | A1 签发：congestion 无 -1；A6↔A5 schema 冻结；建议 SPEF 已通但 **不阻塞 DRC WP** | A5/A6/A7 | 三角并行 |
| **2** | A1：SPEF-backed STA=`trusted`；activity 有标签；A11 MoveTxn 可用 | A8 + A3(STA-02) | TO 先于 CTS 一周缓冲 |
| **3** | A1：PDN 产物 12/12 或 daily 子集全有；A4 可供电流或显式 proxy | A9(01)+A10 | 串行：PNP-01 → IR |
| **4** | 贯穿，与 Wave-0 同时开始 | A11 | 持续 |

### 3.2 WP 依赖（边表示「必须先完成」）

```text
WP-RCX-01 ──► WP-STA-01 ──► WP-STA-02
                    │              ▲
                    ▼              │
              WP-TO-01 ────────────┤
                    │              │
              WP-CTS-01 ───────────┘

WP-PA-01 ──► (Power 门禁) ──► WP-TO-01
WP-PA-01 ──► WP-IR-01

WP-IRT-MAP-01 ──► (Congestion 门禁)
WP-DRC-01 ◄──schema──► WP-RT-01
WP-PL-01 ──► WP-RT-01（软依赖：可先 RT，但 WL 目标需 PL）

WP-PNP-00 ──► WP-PNP-01 ──► WP-IR-01

WP-PLT-01 ──► WP-TO-01 / WP-CTS-01 / 增量 STA（硬依赖）
```

### 3.3 合入流水线（强制）

```text
工具 Agent 完成代码
    → 本地单测/对照实验
    → A12 跑约定设计子集
    → 提交 A/B delta 包
    → A1 Quality Review（trusted/proxy/invalid）
    → A0 批准合入 / 驳回
    → 更新 COORDINATION_BOARD
```

---

## 4. 交接契约（跨 Agent 接口）

| 契约 ID | 生产者 | 消费者 | 载荷 | 冻结责任 |
|---|---|---|---|---|
| **C-SPEF** | A2 | A3, A8, A1 | SPEF + `rcx_coverage.json` | A0 |
| **C-STA** | A3 | A5, A8, A1 | WNS/TNS/path + `net_delay_ok` flag | A1 验真 |
| **C-ACT** | A4 | A8, A10, A1 | power 分量 + `activity_source` | A1 |
| **C-VIO** | A6 | A5 | violation JSON schema | A0 仲裁冻结 |
| **C-CONG** | A5 | A7, A1 | overflow avg/top1%/top5% + map 路径 | A1 |
| **C-PDN** | A9 | A5, A10 | PDN DEF + supply blockage | A0 |
| **C-IR** | A10 | A1, A9 | worst/avg/map/residual | A1 |
| **C-TXN** | A11 | A3, A7, A8 | MoveTxn/DirtySet API | A11 |
| **C-ART** | A12 | A1, A0 | run_id, manifests, sha256 | A12 |

任一契约变更：**先提 RFC 短文到 `docs/ai/agents/rfc/`，A0+相关方 ACK 后才能合入。**

---

## 5. 质量与指标把控细则（A1 操作手册）

### 5.1 指标标签

| 标签 | 含义 | 可否用于 ≥20% 门禁 |
|---|---|---|
| `trusted` | SPEF/活动率/PDN 等前置满足 | 是 |
| `proxy` | 有明确降级说明（如 vectorless） | 仅观测，默认否 |
| `invalid` | net delay=0、−1 congestion、假 clean 等 | 否；触发 FAIL |

### 5.2 基线冻结仪式（Wave-0 结束时由 A0+A1+A12 执行）

1. A12 全量或 daily 子集复跑，产物目录 `.../wave0_baseline_<date>/`
2. A1 逐项贴标签，写出 `benchmarks/qor/wave0_baseline_manifest.json`
3. 之后所有 ≥20% **只相对该 manifest** 计算
4. 禁止用 2026-07-30 虚标 WNS/Power 作优化基线

### 5.3 每指标 Owner（对 A1 汇报）

| 指标 | 主 Owner Agent | 协作 |
|---|---|---|
| DRC | A5 | A6, A7 |
| EGR WL | A7 | A5 |
| Setup WNS | A8 | A3, A2 |
| Fmax | A8 | A3, A2 |
| Power | A8 | A4 |
| IR-drop | A10 | A9, A4 |

Owner 对「本指标未达标」负责提出下一假说；A1 负责判定数字是否可信。

---

## 6. 通信与节奏

### 6.1 协调板（唯一真相源）

路径：[`docs/ai/agents/COORDINATION_BOARD.md`](agents/COORDINATION_BOARD.md)

字段：`WP | Owner | Wave | Status | BlockedBy | LastEvidence | A1Verdict`

Status 枚举：`todo | doing | review | done | blocked | closed_wont_fix`

### 6.2 日报（每个活跃 Agent）

写到 `docs/ai/agents/daily/<agent_id>_YYYYMMDD.md`，强制四段：

1. **Done**：代码/实验/产物路径
2. **Delta**：相对基线的指标变化（可 `N/A`）
3. **Blocked**：依赖谁、卡什么契约
4. **Next**：下 24h 唯一主任务

A0 每日汇总一页：`docs/ai/agents/daily/orch_rollup_YYYYMMDD.md`

### 6.3 同步会触发条件（异步优先）

- 契约冲突（C-VIO / C-TXN）
- A1 REJECT 同一 WP 连续 2 次
- Wave 开闸/闭闸
- 假说被杀死需改路线图 43

---

## 7. Agent 启动提示词

完整可复制提示词见目录：

[`docs/ai/agents/prompts/`](agents/prompts/)

| 文件 | Agent |
|---|---|
| `A0_orchestrator.md` | 总编排 |
| `A1_quality_guard.md` | 质量官 |
| `A2_rcx.md` … `A12_bench.md` | 各工具/基准 |

**启动约定（Cursor / 多会话）：**

1. 每个 Agent 独立会话或独立 Task，**只加载本角色 prompt + 路线图 43 §对应 WP**。
2. 工作区同一 git worktree 时：工具 Agent **禁止**改他人目录除非 RFC；优先按 `src/operation/<tool>/` 边界。
3. 若用并行 Task：A0 先开；Wave-0 并行拉起 A2/A3/A4/A9/A11/A12 与 A5(MAP)；A1 常驻。
4. 合入前必须 `@A1` 审查（或由用户粘贴 A1 checklist 结果）。

### 7.1 推荐并行度（第一周 → rv1.1 起）

| 槽位 | Agent | 唯一目标 | 主代码目录 |
|---|---|---|---|
| 1 | A0 | 开协调板；工单必须带 `src_paths=` | — |
| 2 | A1 | 红线 +「flow-only diff REJECT」 | — |
| 3 | A2 | SPEF 闭环 C++ | `src/operation/iRCX/` |
| 4 | A3 | 约束覆盖 + 读 SPEF | `src/operation/iSTA/` |
| 5 | A4 | 活动率标签 | `src/operation/iPA/` |
| 6 | A5 | **启动 WP-RT-01 外环/代价/repair（C++）**；MAP 已 done 则不再占主槽 | `src/operation/iRT/` |
| 7 | A6 | C-VIO + in-design 规则反馈 | `src/operation/iDRC/` |
| 8 | A7 | 可布线布局 / inflation | `src/operation/iPL/` |
| 9 | A9 | WP-PNP-00 PDN 进 flow | `src/operation/iPNP/` `iPDN/` |
| 10 | A11 | MoveTxn/DirtySet | `src/platform/` |
| 11 | A12 | AES@65% daily 复跑（真 util 结果根） | `benchmarks/` |

说明：Wave-1 的 **DRC/WL C++**（A5/A6/A7）与 Wave-0 真值可并行；**WNS/Power 的 ≥20% 门禁**仍须等 SPEF/活动率（A2/A3/A4）变绿后由 A1 签发。

Wave-2 再全力拉起 A8（`iTO`/`iCTS`）；Wave-3 再启 A10。

---

## 8. 与路线图门禁的映射

| 路线图里程碑 | A1 签发条件 | 参与 Agent |
|---|---|---|
| M-T0 | SPEF-backed、unconstrained=0、activity 标签、cong 无 -1、PDN 存在 | T + A9 + A5map + A12 |
| M-T1 | DRC ↓≥50% 路径；WL/overflow ↓≥20%；无假 clean | A5/A6/A7 |
| M-T2 | WNS/Fmax/Power trusted 且 ≥20% | A8/A3/A4 |
| M-T3 | IR trusted 且 worst ↓≥20% | A9/A10/A4 |
| M-契约 | rollback hash 一致；缺 SPEF/有 residual → 非零 | A11 + 全员 |

---

## 9. 风险与升级

| 风险 | 检测 | 升级动作 |
|---|---|---|
| 工具 Agent 用扫参冒充算法 | A1 审 diff / 实验设计 | A0 关闭 WP，回 43 纪律 |
| SPEF 长期阻塞 | A2 日报连续 blocked | A0 升级 `IRCX` 专项，A3 不得发 trusted WNS |
| RT/DRC schema 扯皮 | RFC >48h 无 ACK | A0 强制冻结 v0 schema |
| 多 Agent 改同一文件冲突 | git / 目录边界 | A0 指定唯一 Owner |
| 质量官成瓶颈 | review 队列 >3 | 增加 A1-deputy 只做清单机械检查，否决权仍在 A1 |

---

## 10. 一句话作战指令

**A0 按 Wave 开闸；Team-T 先把数变真；Team-I 打 DRC/WL 再打 PPA；Team-P 补 IR；A1 掌管绿灯；A12 只负责跑出可追溯产物。**

无 A1 `trusted`，任何「提升 20%」宣传无效。

---

## 附录 A · 文件索引

| 路径 | 说明 |
|---|---|
| `docs/ai/44-aes12-qor-agent-team-orchestration.md` | 本文 |
| `docs/ai/43-aes12-65pct-qor-optimization-roadmap.md` | 算法路线图 |
| `docs/ai/agents/COORDINATION_BOARD.md` | 协调板 |
| `docs/ai/agents/prompts/*.md` | 各 Agent 启动提示词 |
| `docs/ai/agents/daily/` | 日报目录 |
| `docs/ai/agents/rfc/` | 跨工具契约 RFC |
