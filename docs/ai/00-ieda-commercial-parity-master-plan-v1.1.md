<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 00 · iEDA 商业能力对标 · 优化主纲领 · v1.1

> 日期：2026-07-20（v1.0）/ 2026-07-20（v1.1 修订）
> 目标：**给定相同 netlist（及同 PDK / 同约束包），iEDA 全流程与商业流程（Innovus 或 ICC2 + PrimeTime + Calibre）的 PPA 接近打平；端到端与关键步骤运行时间接近，力争更短。**
> 能力定义 = **功能覆盖 + QoR 质量 + 规模/性能 + 可签核可信度** 四者齐备，缺一条都不算"达到"。
> 体例：沿用 `HS-3D_Problem/thirdparty/iEDA-3D/docs/3d/design/`——**每条验收机器可判定；没有实测写"未验证"，不补白；文档是假说不是事实。**
> 执行面：本纲领面向 **Claude / Cursor agent 分工具落地**——每个工作包必须可独立认领、有对照实验、有门禁绑定；禁止"先写一大坨再测"。

### 修订记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.0 | 2026-07-20 | 首版：对标表、G1–G20、分阶段、决策③④ |
| v1.1 | 2026-07-20 | 对齐用户目标（PPA+运行时）；补苹果对苹果协议；拆 QoR/Perf 门禁；对齐已有子文档（22/26）；加 agent 工作包协议；修正七维表述与工具存在性 |
| v1.1.1 | 2026-07-20 | §5 细化为「重点工具 / 实施路径 / 交付 / 验证」；对齐 22/25/26/27 升版（功能算法矩阵 + 分阶段） |
| v1.2 | 2026-07-20 | 子文档 22/25/26/27 升至 v1.2：LLD 可开发级 + 商业对比评测与提升路线 |
| v1.3 | 2026-07-20 | 新增 `03-commercial-knowhow-catalog.md`；全工具方案补 Know-how 专节；补齐 11/12/31–33/40–42 |
| v1.4 | 2026-07-20 | 全工具方案升 v1.1+：技术/算法/实现 LLD + 商业对照看板 + M0–M4 演进策略 |
| **v1.5** | **2026-07-20** | **体例对齐 `24-iPL-3d-rv1.0`**：新增 `01-ai-doc-conventions-rv1.md`；主战场 22/23/25/26/27/28 升 **rv1.0**（逐 kernel 走读 + ALG + IterParam + Exhibit + L0–L5）；其余工具同骨架升 rv1.0（篇幅按 01 指引） |

---

## 0. 一句话

iEDA 已有 **1 个基础设施 + 若干工具 + 4 次流片**（README 公开事实），能跑通 netlist→GDS；
**v1.1 = 同输入商业对标下，实现链 PPA 打平（或更优）+ 签核可信项全绿 + 运行时接近/更短 + 每设计可自动寻优。**

四条主线（不可颠倒优先级）：

1. **对标 harness**：把差距变成数字（含商业金参考并排产物）。
2. **签核真值源**：iSTA/iRCX/iDRC/iPA 先可信，再谈下游优化。
3. **实现链 QoR**：iFP→iPL→iCTS→iRT→iTO 逐工具打平。
4. **性能/规模**：同质量下墙钟时间与内存接近商业；大设计不崩。

---

## 1. 对标总纲：iEDA 工具 ↔ 商业工具 ↔ 能力标杆

> "达到商业能力"必须先定义**对标谁、用什么基准、看什么指标**。下表是全部后续工作的锚点。
> 商业工具栏给**双对标**（Synopsys / Cadence）；**每个基准设计在 Phase 0 冻结"主对标方"**（Innovus **或** ICC2 二选一），验收全程不换，避免挑强项。

| # | iEDA | 商业对标（Synopsys / Cadence） | 能力标杆（区别于开源的核心能力） | 公开评测基准 |
|---|---|---|---|---|
| 1 | **iFP** | ICC2 floorplanning / Innovus floorplan | 宏布局看连线；auto-die；UPF/多电压；拥塞/时序驱动 macro place | ISPD05/06；OFS `gcd/aes/jpeg` |
| 2 | **iNO** | DC topographical / Genus iSpatial | 物理感知综合优化；restructuring；`fix_fanout` 不破坏时序 | EPFL；OFS 综合 QoR |
| 3 | **iPL** | ICC2 place_opt / Innovus place_opt_design | GP 收敛；LG 零丢失；时序/拥塞/功耗多目标；incremental | ISPD05/06/15；OFS PPA |
| 4 | **iCTS** | ICC2 clock_opt / Innovus ccopt_design | skew/latency/功耗三目标；useful skew；多域；mesh+tree | ISPD09/10 CTS |
| 5 | **iPDN / iPNP** | ICC2 create_pg / Innovus PG planning | 功耗预算→网格；EM/IR 感知条宽；via pillar | 自建（§4.6） |
| 6 | **iTO** | ICC2 route_opt / Innovus postroute opt | resize/buffer/VT-swap **真 apply**；hold+setup；DRV；SI-aware | OFS post-route WNS/TNS |
| 7 | **iRT** | ICC2 route / Innovus NanoRoute | GR→TA→DR→0 DRC；时序/SI/NDR；ECO route；>1M cell | ISPD18/19 |
| 8 | **iSTA** | PrimeTime / Tempus | graph + **PBA**；MCMM；OCV/AOCV/SOCV；SI；SDC 覆盖 | TAU/ICCAD；vs PT 路径相关 |
| 9 | **iRCX** | StarRC / Quantus | pattern 精度；耦合 C；field-solver 校准；增量 | vs StarRC 逐网 |
| 10 | **iPA** | PrimeTime PX / Joules | VCD/SAIF；clock/leakage/dynamic；多角 | vs PTPX |
| 11 | **iIR** | RedHawk / Voltus | 静/动态 IR；收敛 residual；EM | 自建（§4.11） |
| 12 | **iDRC** | Calibre / ICV / Innovus verify | rule deck 覆盖；分层并行；不静默 SKIP | vs Calibre rv |
| 13 | **iLVS** | Calibre nmLVS / Assura | 独立参考网表；器件+参数；可调试报告 | 注入差异必非 clean |
| 14 | **iECO** | ICC2 eco / Conformal ECO | 功能 ECO + 时序 ECO；金属可修 | 注入 ECO |
| 15 | **iLO / iTM** | DC / Genus | 库映射面积/延迟；与物理回灌 | EPFL/ISCAS |
| 16 | **platform / flow** | ICC2/Innovus session | 单 session 增量闭环；断点续跑；无顺序陷阱 | 一键复现 |
| 17 | **interface** | 商业 TCL/Python | 产物存在断言；静默空操作响亮失败；API 覆盖 | 命令矩阵 |

**基础设施**：iDB / solver 对标 OpenAccess 级互操作 + 容量；验收见 §4.1。  
**存在性诚实声明**（附录 B）：`iLVS`、`iLO/iTM` 在本仓可能为 **greenfield/空壳**——parity 目标仍成立，但排期与门禁必须单独标注，禁止假装"已有工具再优化"。

---

## 1bis. 苹果对苹果协议（Parity Protocol）——**所有 G17–G21 的前置约束**

> 没有本协议，"差距 ≤5%"没有物理意义。Phase 0 必须产出冻结的 `benchmark/parity_protocol.json`。

### 输入等价（必须逐项锁定）

| 项 | 规则 |
|---|---|
| Netlist | 同一 Verilog（或同一 DC/Genus 综合产物）；禁止一方重综合另一方不重综合 |
| 库/PDK | 同一 `.lib` / LEF / tech / RC 模型版本；角点集合一致 |
| 约束 | 同一 SDC（时钟、IO、false path、MCP）；单位与 `set_units` 对齐 |
| 电源意图 | 有 UPF 则双方都加载；无则双方都不加载 |
| 设计边界 | 同一 die/core（或同一 util 目标由 iFP/商业 floorplan 各自产出后**记录面积差**，面积进 G17 独立指标） |
| 随机性 | iEDA 固定 seed；商业侧关闭随机扰动或记录 seed；两次复跑 QoR 波动计入不确定度带 |

### 流程等价（允许实现差异，不允许目标偷换）

| 项 | 规则 |
|---|---|
| 主对标方 | 每个设计冻结 Innovus **或** ICC2 一条商业实现链；签核侧固定 PT + StarRC + Calibre |
| 努力档位 | 商业侧使用**文档化默认努力档**（如 `place_opt`/`route_opt` 标准 effort），禁止为赢比赛开秘密超参；超参变更必须进协议版本号 |
| 报告点 | 统一报告点：`post-place` / `post-cts` / `post-route` / `signoff-STA`；禁止拿商业 post-opt 对 iEDA post-place |
| 指标定义 | WNS/TNS 来自 **同一 STA 引擎读同一 SPEF**（推荐：双方 DEF/网表导出后都用 PT 读，避免"iSTA 对自己友好"）；HPWL/面积/功耗定义写进 JSON schema |
| 失败语义 | 商业侧失败或超时 → 该设计记 `commercial_fail`，不计入打平分母；iEDA 假 clean（rc=0+错产物）→ 直接 G14 FAIL |

### 判定公式

对指标 \(m\)：令 \(e\)=iEDA，\(c\)=商业，不确定度带 \(\epsilon_m\) 来自复跑标准差。

- **更优或打平**：\(e_m \le c_m \cdot (1+\delta_m) + \epsilon_m\)（越小越好类）；或对越大越好类对称。
- **默认 \(\delta\)**：见 §3 G17 分层表；**不允许用强项掩盖弱项**——每个 \(m\) 独立转绿。
- **运行时**：墙钟时间在**独占机器**采集（附录 A.7）；共享机只采正确性。

---

## 2. 当前基线诚实快照

### 2.1 已确凿（公开/可验证，不倒退）

- 工具目录齐全（`src/operation/i*`），netlist→GDS 可跑通；**4 次流片**（README）。
- `src/evaluation/` 已存在——PPA 闭环落点在。
- 本仓已有三套流程痕迹（`ics55` / `sky130` / `nangate45`）——Phase 0 复用。
- **子文档已实读审计并升版（功能/算法 + 分阶段交付）**：
  - `22-iPL.md` **rv1.0**：逐 kernel 走读 + LLD/ALG（宏/QP/收敛/时序/拥塞）+ vs place_opt；体例对齐 24-iPL-3d。
  - `27-iSTA.md` **v1.2**：LLD（PBA/harness/MCMM/增量）+ vs PT 评测路线（模板文档）。
  - `26-iRT.md` **v1.2**：LLD（plateau/违例 JSON/时序排序）+ vs NanoRoute 评测路线。
  - `25-iTO.md` **v1.2**：LLD（否决环/incr LG/报告）+ vs route_opt 评测路线。

### 2.2 诚实的未决（除标注外均为"待 Phase 0 实测"）

| 项 | 状态 | 归属 |
|---|---|---|
| **逐工具 QoR 数字**（vs 商业，统一基准） | ❌ 不存在——**第一个要产出的东西**（Phase 0） | platform/evaluation |
| 苹果对苹果协议冻结文件 | ❌ 不存在 | platform |
| iPL 宏/收敛/时序驱动 | ⚠️ 代码审计已有（22）；**数值待测** | iPL |
| iRT 收敛/时序驱动 | ⚠️ 代码审计已有（26）；**数值待测** | iRT |
| iTO 贪心否决/incr LG | ⚠️ 代码审计已有（25）；**数值待测** | iTO |
| iSTA PBA / SI / MCMM / vs PT | ⚠️ 代码审计已有（27）；**数值与 harness 待建** | iSTA |
| iRCX vs StarRC | ❓ 无对比 | iRCX |
| iDRC vs Calibre deck | ❓ 未逐条对照 | iDRC |
| iLVS 是否恒等式 / 是否存在 | ❓ 待审计（附录 B 标 greenfield） | iLVS |
| 规模上限（现有设计多 <50 万实例） | ❓ 未爬坡 | all |
| 静默失败面 | ❓ 历史病；本仓未普查 | interface/platform |
| **运行时 vs 商业分项剖面** | ❌ 不存在 | all |

---

## 3. v1.1 验收表（机器可判定门禁）

**v1.1 完成 = 下表全绿。** 判据落到"脚本读产物、断言数字"，不许人工目测。

### 3.1 地基与可信度

| # | 门禁 | 判据（机器可判定） | 归属 |
|---|---|---|---|
| G1 | **`qo-baseline-fresh`** | `benchmark/qor/` 存在当前二进制逐工具 QoR JSON（≥5 设计 × 全指标含墙钟/内存），由 `run_qor_baseline.sh` 生成并进 CI；二进制 hash 变即 FAIL | platform/evaluation |
| G1b | **`parity-protocol-frozen`** | `benchmark/parity_protocol.json` 存在且版本锁定；含主对标方、努力档、报告点、指标 schema | platform |
| G14 | **`no-silent-failure`** | 每 TCL/Python 命令有产物存在断言；已知静默空操作清单清零；缺前置选项响亮失败 | interface |
| G15 | **`metric-not-fake`** | 禁 `budget==value` 自报达标；QoR budget 外生；超标 FAIL | platform/evaluation |
| G16 | **`flow-one-session`** | netlist→GDS 单 session；引擎重启不丢状态；断点续跑产物一致 | platform |

### 3.2 实现链正确性（非商业对比，先保证"自己不骗自己"）

| # | 门禁 | 判据 | 归属 |
|---|---|---|---|
| G2 | **`placement-converges`** | iPL：GP overflow < 0.1 且 HPWL > 0；LG 零丢失；基准设计 legal | iPL |
| G3 | **`macro-placement-live`** | 有宏设计：shelf-pack 兜底率 < 10%；cost-term-live（代价项置零解必变） | iFP/iPL |
| G4 | **`cts-meets-skew`** | iCTS：skew/latency 达约束；时钟网进功耗报告；多域全绿 | iCTS |
| G5 | **`route-clean`** | iRT：≥3 中密度设计 DRC=0；密设计违例<阈值 **或** 诚实拒绝并定位层/类型 | iRT/iPL |
| G6 | **`setup-hold-diagnosed`** | post-route WNS ≥ −50 ps **或** 成因定位报告（约束/未优化/缺寄生三选一+对照）；hold=0 或可解释 | iTO/iSTA |
| G9 | **`power-has-activity`** | iPA：有真实活动源，或无源时**拒绝报数**（禁静默 toggle 回落） | iPA |
| G10 | **`ir-sane-converges`** | peak drop ∈ [1,100] mV 且 residual 达标；作用域缺失→告警回落，禁 LOG_FATAL | iIR/iPDN |
| G12 | **`lvs-not-tautology`** | 参考网表独立；注入差异必非 clean（工具若 greenfield：本门禁=最小可运行实现+注入测） | iLVS |
| G13 | **`scale-mid`** | ≥1 个 50 万–100 万实例端到端跑通，或明确上限与瓶颈分项 | all |

### 3.3 签核相关度（金参考 = 商业工具）

| # | 门禁 | 判据 | 归属 |
|---|---|---|---|
| G7 | **`sta-correlates`** | iSTA vs **PrimeTime**：同网表+SPEF，逐路径 slack R² > 0.98，endpoint 差 < 1%；MCMM 逐角 | iSTA/iRCX |
| G8 | **`rcx-accuracy`** | iRCX vs **StarRC**：逐网 total C 差 < 5%、耦合 C 差 < 10%（90 分位） | iRCX |
| G11 | **`drc-coverage`** | 目标 PDK rule deck 覆盖表进 repo；Calibre 可比子集违例一致或逐条解释 | iDRC |

### 3.4 商业 QoR / 性能打平（决策③，用户目标）

> **分层 \(\delta\)**：默认 5% 对一切指标一刀切会 simultaneous 过严/过松。按下表；Phase 0 实测后**只允许收紧，不许放宽**。

| 指标类 | 默认 \(\delta\) | 说明 |
|---|---|---|
| WNS / TNS（post-route，**双方用 PT 读**） | 5% 或 ≤10 ps 取松者 | 绝对值很小时用 ps 带 |
| 标准单元面积 / 利用率 | 5% | die 若不同则同时报 die 面积差 |
| 路由后线长 / via 数 | 8% | 对拓扑敏感，略宽 |
| 总功耗（同活动源） | 5% | 无活动源则本指标 N/A→G9 |
| DRC 违例数 | 必须同为 0，或密设计按 G5 诚实拒绝 | 不许"商业 0 / iEDA 很多还宣称打平" |
| 时钟 skew / latency / 时钟功耗 | 5% | = 原 G19，并入实现链 CTS 行 |

| # | 门禁 | 判据 | 归属 |
|---|---|---|---|
| G17 | **`qor-parity-impl`** | 按 §1bis + 上表：五套日常基准，post-route 逐指标独立转绿；**报告点对齐**；强项不可掩弱项 | iFP/iPL/iCTS/iRT/iTO |
| G18 | **`qor-parity-synth`** | iNO/iLO/iTM vs DC/Genus：EPFL/ISCAS+基准，面积/延迟 ≤5% 或更优；greenfield 工具先达"可跑+基线"再谈 δ | iNO/iLO/iTM |
| G19 | **`qor-parity-cts`** | 并入 G17 的 CTS 三指标；本行保留为 CTS 专项 CI 标签（避免只跑全流程才发现 CTS 回退） | iCTS |
| G20 | **`qor-parity-scale`** | G13 大设计上 G17 成立 | all |
| G21 | **`perf-parity`**（v1.1 新增） | 五套日常基准：端到端墙钟 **≤ 1.5×** 商业主对标方，且至少 2/5 设计 **≤ 1.0×**（持平或更快）；关键步骤（place/cts/route/sta）分项剖面进 JSON；大设计（G20）放宽至 **≤ 3×** 且附瓶颈定位 | all |

**红线（每次改动后复验）**：`ctest` 全绿 · 三 PDK 回归全绿 · G1/G1b 新鲜。

> **门槛校准纪律**：G6/G8/G10/G17/G21 的数值门槛在 Phase 0 后**只收紧不放宽**；离门槛太远 → 记入 §7 并降**阶段目标**，**不改门槛**。

---

## 4. 逐工具优化方案（七维纵深）

> 图例：🔴 阻塞 / 🟡 部分 / 🟢 已达成残项 / ❓ 未审计 / ⚠️ 已有子文档结论、待测数值。
> **七维**：`data → func → algo → impl → interaction → api → test`（v1.0 误写"六维"，此处更正）。
> 每个工具：① 商业缺口 ② 七维缺口 ③ PPA/性能杠杆 ④ 绑定门禁 ⑤ 里程碑。
> **"现状"除公开事实与已合并子文档结论外，一律待审计/待测。** 详细 LLD 进子文档（`20-*.md`…），本文保持纲领不膨胀。

### 4.0 依赖与关键路径（agent 排期用）

```text
G1/G1b harness ──┬── G14/G15 静默失败与假指标
                 ├── G7 iSTA↔PT ──┐
                 ├── G8 iRCX↔StarRC ┼── 真值源就绪后才允许大力优化 QoR
                 ├── G11 iDRC↔Calibre ┘
                 │
                 ├── G2/G3 iPL/iFP ── G4 iCTS ── G5 iRT ── G6 iTO ── G17
                 │                                      └── G19(CTS CI)
                 ├── G9/G10 iPA/iIR
                 ├── G12 iLVS
                 ├── G16 session
                 └── G13 ── G20/G21（规模与性能，与 G17 滚动并行但不得牺牲质量门禁）
```

**硬约束**：无 G7/G8，不准宣称 G17 时序/功耗打平（否则是在错误数字上做功）。

### 4.1 database / iDB ❓
- **对标**：OpenAccess 互操作 + 容量。
- **缺口**：GDS 真二进制往返；LEF/DEF/SDC/SPEF/Verilog 不丢属性；100 万实例内存预算。
- **门禁**：G1、G13、G16。**里程碑**：P0 IO 往返矩阵 → P1 容量爬坡。

### 4.2 iFP ❓
- **缺口**：力导向/SA 宏布局；auto-die；拥塞/时序驱动 macro place。
- **杠杆**：宏 HPWL、通道、行占用率。
- **目标**：`macro_packed_frac < 10%`；util 默认待 Phase 0 复核（fork 提示 0.70 易崩）。
- **门禁**：G3、G17。

### 4.3 iNO ❓
- **缺口**：commit 后重计时否决；物理坐标感知。
- **门禁**：G6、G14、G18。

### 4.4 iPL ⚠️（详见 `22-iPL.md` v1.1）
- **已证实缺口（代码）**：宏布局空模块+假成功；GP=RandomPlace；发散/LG 失败不上抛；`isSTAStarted()`=false；拥塞驱动缺独立环。
- **算法主攻**：宏力导向+SA；QP 初值；Nesterov 收敛断言；timing/congestion effort 证真。
- **门禁**：G2/G3/G5/G14/G17/G21。**优先**：见 §5 Phase B1/B2。

### 4.5 iCTS ❓
- **缺口**：三目标报告；多域；buffer 后增量 legalize；时钟功耗进 iPA。
- **门禁**：G4/G6/G19/G17。

### 4.6 iPDN / iPNP ❓
- **缺口**：真功耗驱动网格；EM/IR 感知条宽。
- **门禁**：G10 前置。

### 4.7 iTO ⚠️（详见 `25-iTO.md` v1.1）
- **已证实**：真 apply（非只 plan）；贪心 `0.5*delay`；无路径级 re-time 否决；未见 incr LG。
- **算法主攻**：否决环 → incr LG → VT-swap/编排 → SI-aware。
- **门禁**：G6/G7/G16/G17。**排期**：在 iSTA 增量契约与 iPL incr LG 之后（§5 Phase B3）。

### 4.8 iRT ⚠️（详见 `26-iRT.md` v1.1）
- **已证实缺口**：DR 硬编码、无 plateau；timing 疑似只报告；无 ECO。
- **算法主攻**：反馈控制收敛；关键网排序；违例机读归因。
- **门禁**：G5/G13/G16/G17/G21。

### 4.9 iSTA ⚠️（详见 `27-iSTA.md` v1.1）
- **已证实缺口**：无 PBA；MCMM 场景调度未见；单位 FS/ps 注释矛盾；SI/增量契约待验。
- **算法主攻**：PT harness 归因 → top-N PBA → MCMM 外挂 → delay_mode 分层。
- **地位**：**全线时序真值源**；G7 先于 G17。
- **门禁**：G7/G6/G14/G15。

### 4.10 iRCX ❓
- **缺口**：精度校准；耦合 C；增量；SPEF 量纲。
- **门禁**：G8。

### 4.11 iPA / iIR ❓
- **iPA**：活动源覆盖；禁静默 toggle；层级 VCD 作用域。
- **iIR**：真 PG 提取；residual；合理 drop。
- **门禁**：G9/G10。

### 4.12 iDRC ❓
- **缺口**：覆盖表；SKIP 显式；vs Calibre；并行。
- **门禁**：G11/G5。

### 4.13 iLVS ❓ / 可能 greenfield
- **最低成本保险**：G12 注入差异测试——有工具就测，无工具则最小实现+测。
- **门禁**：G12。

### 4.14 iECO ❓
- **依赖**：G16 + iRT ECO API；排 Phase C。

### 4.15 iLO / iTM ❓ / 可能 greenfield
- **门禁**：G18；先"可跑+基线"再 δ。

### 4.16 platform / flow ❓
- **缺口**：单 session；顺序陷阱（eval 先于 rcx 等）；崩溃不得 exit 0。
- **门禁**：G1/G1b/G14/G15/G16。

### 4.17 interface ❓
- **缺口**：产物断言；选项依赖；未映射键响亮忽略声明；API 矩阵。
- **门禁**：G14。

---

## 5. 分阶段计划（重点工具 · 实施路径 · 交付 · 验证）

> 排期按经验 ×3，**不设死线**；以门禁转绿为准。下列「周」为单轨粗估；多轨并行见 §6.3。  
> **双焦点**：实现链以 **iPL** 为第一刀；签核链以 **iSTA** 为第一刀——二者 Phase 0 后可并行，但 G17 时序行必须等 G7 背书。

### 5.0 阶段总览

| 阶段 | 时长粗估 | 重点工具（主） | 伴生工具 | 退出条件（门禁） |
|---|---|---|---|---|
| **Phase 0** | 1–2 周 | platform/evaluation、**iSTA**、**iPL**、iRT | iTO 基线、G12 | G1/G1b；`01-baseline-report`；22/26/27 P0 清零 |
| **Phase A** | 1–2 周 | interface、iDRC、iLVS、fork 审计 | iSTA 单位/SDC | G14 主清单；G11 覆盖表起步；G12 |
| **Phase B0** | 3–4 周 | **iSTA（PBA）**、iRCX | — | G7 爬坡；G8 起步 |
| **Phase B1** | 2–3 周 | **iPL（宏+QP）** | iFP | G2/G3；G14-iPL |
| **Phase B2** | 2 周 | **iRT（收敛）**、iCTS | iPL 拥塞环 | G5 中密度；G4 |
| **Phase B3** | 2–3 周 | **iTO（否决环）**、iSTA MCMM/SI | iPL incr LG | G6 路径；G7 MCMM |
| **Phase B4** | 滚动 | 全实现链 | evaluation | **G17** 逐设计转绿；G21 日常剖面 |
| **Phase C** | 滚动 | 规模、综合、ECO、寻优 | iLO/iTM、iECO | G13/G18/G20；G21 大设计档 |

```text
时间 →
Phase0 ──┬── T0 harness
         ├── T1 iSTA 基线+PT harness ── B0 PBA ── B3 MCMM/SI
         ├── T2 iPL 基线 ── A 假成功清零 ── B1 宏+QP ── B2 时序/拥塞
         ├── T3 iRT 基线 ────────────── B2 收敛 ── B4 timing-route
         └── T4 iTO 基线 ────────────────────── B3 否决环（依赖 T1/T2）
```

---

### Phase 0 · harness + 协议 + 基线（1–2 周，**先量再写**）

| 维度 | 内容 |
|---|---|
| **重点工具** | **evaluation/platform（G1/G1b）**；**iSTA**（PT 对齐）；**iPL / iRT**（对照实验）；iTO 轻量基线；G12 |
| **实施路径** | ① 冻结 `parity_protocol.json`（主对标方/努力档/报告点）② `run_qor_baseline.sh` daily 五套 ③ `run_pt_align.sh` 首轮 ④ 执行 22/26/27/25 各自 §P0 测法 ⑤ 目录级 greenfield 确认（iLVS/iLO） |
| **交付内容** | `benchmark/qor/**` JSON；`parity_protocol.json`；`01-baseline-report.md`；分项墙钟表；各子文档未验证清单前 N 条清零纪要 |
| **测试验证** | CI：二进制 hash 变 → G1 FAIL；PT 对齐脚本有 R² 产出（不要求已 ≥0.98）；宏布局空操作/timing A/B/plateau 结果落盘 |

---

### Phase A · 可信度地基（1–2 周，与 B0 早期并行）

| 维度 | 内容 |
|---|---|
| **重点工具** | **interface（G14）**；**iDRC（G11 覆盖表）**；**iLVS（G12）**；fork 分叉审计；iSTA 单位/SDC 响亮 |
| **实施路径** | 静默失败普查 → 命令产物断言 → Calibre 子集映射起步 → LVS 注入差异 → `02-fork-divergence-audit.md` → 可搬项小步 cherry-pick+红线 |
| **交付内容** | 静默清单清零表；SDC/DRC 覆盖表；G12 测试；fork 可搬/需适配/不可搬三栏 |
| **测试验证** | 已知假成功用例（如 `run_macro_placement`）不得再 rc 成功装死；注入 LVS 差异必非 clean；ctest+三 PDK |

---

### Phase B0 · 签核真值源 · iSTA 主攻（3–4 周）★

| 维度 | 内容 |
|---|---|
| **重点工具** | **iSTA**（第一优先）；伴生 **iRCX**（G8 起步） |
| **实施路径** | 见 `27-iSTA.md` §9：单位/增量契约 → **top-N PBA** → R² 爬坡 → MCMM 外挂（可与 B3 重叠）→ delay_mode 文档化；并行 StarRC 逐网对比试点 |
| **交付内容** | `StaPathBased.*`；GBA/PBA 双值报告；`benchmark/qor/sta/` 多轮对比；增量 gtest |
| **测试验证** | T-A1/A2/B1（27 文档）；**G7** 向 0.98 爬坡；无 G7 背书不得关闭 G17 时序行 |

---

### Phase B1 · 实现链第一刀 · iPL 主攻（2–3 周）★

| 维度 | 内容 |
|---|---|
| **重点工具** | **iPL**；伴生 iFP（宏/die 交界） |
| **实施路径** | 见 `22-iPL.md` §9：A 假成功/发散/LG 上抛 → **宏力导向+SA** → **QP 初值** → G2/G3；fork 审计通过项整段搬 |
| **交付内容** | `macro_placer/`；QP 初值路径；`macro_packed_frac`；收敛断言 |
| **测试验证** | NFR-PL-01/03；T-A1/B2/C1；5 基准 G2；有宏设计 G3 |

---

### Phase B2 · 可布线与时钟（~2 周）

| 维度 | 内容 |
|---|---|
| **重点工具** | **iRT（收敛反馈）**；**iCTS**；iPL 拥塞最小环 |
| **实施路径** | iRT plateau+策略+违例 JSON（26 §7）；iCTS skew/多域/buffer 后 incr LG；iPL congestion effort 与密设计联调 |
| **交付内容** | DR 调度外置；`violation_summary.json`；CTS 三目标报告字段 |
| **测试验证** | **G5** 中密度 0 DRC；**G4**；plateau 日志可机读 |

---

### Phase B3 · 时序修复闭环（2–3 周）

| 维度 | 内容 |
|---|---|
| **重点工具** | **iTO**；iSTA MCMM/SI；iPL incr LG 接线 |
| **实施路径** | iTO re-time 否决 + incr LG（25 §7）；pass 固定序；iSTA 场景/SI live；PostGP/默认流程审计关闭 |
| **交付内容** | `ito_pass_report.json`（接受/回滚）；MCMM 汇总报告 |
| **测试验证** | **G6**；NFR-TO-02/03；T-E1（SI）；下游 iPL T-D1 绿 |

---

### Phase B4 · QoR / Perf 打平主循环（滚动）

| 维度 | 内容 |
|---|---|
| **重点工具** | iFP/iPL/iCTS/iRT/iTO + evaluation（**G17/G21**） |
| **实施路径** | 同输入并排商业流程 → 逐指标归因 → 回开工具级 WP（§6 工作包）→ 单设计转绿再扩五套；墙钟剖面与 QoR 同发 |
| **交付内容** | 每设计 parity JSON；差距 issue 板；G21 daily 曲线 |
| **测试验证** | G17 逐指标独立；G19 CTS CI；G21 ≤1.5× 日常档起步观测→门禁 |

---

### Phase C · 规模 + 综合 + ECO + 寻优（滚动）

| 维度 | 内容 |
|---|---|
| **重点工具** | 大设计（G13/G20）；iNO/iLO/iTM（G18）；iECO+iRT ECO；自动 PPA 寻优 |
| **实施路径** | ariane/bp 爬坡+瓶颈定位；综合链基线→δ；`route_eco`；参数扫描复用 Phase 0 harness |
| **交付内容** | 规模上限报告；综合 QoR 曲线；ECO 用例集；寻优配置 |
| **测试验证** | G13/G18/G20；G21 大设计 ≤3×；ECO 契约测试 |

---

### 5.1 已有子文档 ↔ 阶段映射（防跑偏）

| 子文档 | Phase 0 | 主攻阶段 | 关键算法交付 |
|---|---|---|---|
| **27-iSTA** | PT harness | **B0** | top-N PBA |
| **22-iPL** | overflow/宏/timing A/B | **B1**（后 B2 拥塞/时序） | 宏+QP+收敛断言 |
| **26-iRT** | 违例序列/timing A/B | **B2** | plateau 反馈控制 |
| **25-iTO** | post-route 基线 | **B3** | re-time 否决 + incr LG |
| 其余工具 | 审计/基线 | 按 §4 / 附录 B | 见各待写文档 |

---



## 6. Agent 工作包协议（Claude / Cursor 执行面）

> 目标不是"让模型读完纲领写代码"，而是**可并行认领的原子包**。违反本协议的 PR/改动视为未完成。

### 6.1 工作包模板（每个 PR / agent 会话只做一个）

```text
WP-<tool>-<nn> · <一句话目标>
绑定门禁: G#
对照实验: <能杀死假说的命令/设计>
禁止范围: <不改哪些模块>
完成定义: 代码 + 门禁脚本断言 + 当前二进制重跑一致
证据: file:line 或 JSON 字段路径
```

### 6.2 强制纪律

1. **先量再写**：无 Phase 0 数字，不准开 QoR 算法大改（G14 静默失败除外，可先修）。
2. **一次一假说**：每个会话只验证/修复一个对照实验。
3. **子文档优先**：有 `22-iPL.md` / `26-iRT.md` 时，agent 以子文档 LLD 为准，纲领只作门禁与优先级。
4. **fork 搬运**：必须先有 `02-fork-divergence-audit.md` 条目；搬完立刻 ctest+三 PDK。
5. **性能不盲优化**：无 G1 墙钟基线，不准为"加速"改算法默认行为。
6. **输出回写**：测完更新子文档 §未验证清单；纲领 §2.2/§7 由 `01-baseline-report.md` 取代，不在纲领里堆原始日志。

### 6.3 推荐并行轨道（互不踩脚）

| 轨道 | 内容 | 依赖 |
|---|---|---|
| T0 | harness / protocol / G14 普查 | 无 |
| T1 | iSTA↔PT、iRCX↔StarRC | T0 |
| T2 | iPL（22 文档） | T0；时序驱动真化依赖 T1 部分 |
| T3 | iRT（26 文档） | T0；timing-driven route 依赖 T1 |
| T4 | iCTS / iTO / iFP | T2 部分转绿后 |
| T5 | iDRC/iLVS/iPA | T0 |
| T6 | perf 剖面与 G21 | G17 单设计开始转绿后 |

---

## 7. 决策记录

### 7.1 已拍板（2026-07-20）

1. **对标参考系 = 商业一线。** PT / ICC2|Innovus / StarRC / Calibre / PTPX 可用。  
   → OpenSTA/OpenROAD 不进判据；Phase 0 必须产出并排对比。
2. **基准集 = 五套日常 + 大设计进 G13/G20。**  
   → `run_qor_baseline.sh` 分 `daily` / `scale` 两层。
3. **目标语义 = QoR 打平商业（或更优）。**  
   → G17–G20；逐指标独立转绿；排期 ×3 预期，以门禁为准。
4. **3D fork 修法 = 整段搬代码（先审计再搬）。**  
   → `02-fork-divergence-audit.md`；每轮红线；清理 default-off/静默兜底。

### 7.2 v1.1 增补拍板建议（写入本纲领即生效，除非用户否决）

5. **运行时是一等目标。** 新增 **G21**：日常 ≤1.5× 且 ≥2/5 设计 ≤1.0×；大设计 ≤3×+瓶颈定位。质量门禁优先于性能，但性能回归与 QoR 循环绑定，禁止"先打平再一辈子还技术债"。
6. **苹果对苹果协议冻结为 G1b。** 无协议文件，G17–G21 不许宣称通过。
7. **签核相关度与实现链 QoR 解耦报告。** G7/G8 绿不等于 G17 绿；G17 时序指标推荐**双方都用 PT 读**，避免自卖自夸。

---

## 8. 未验证 / 风险清单（Phase 0 必须清零或降级记入 baseline-report）

| # | 项 | 出处 | 测法 |
|---|---|---|---|
| 1 | iPL 宏布局空操作 / 兜底率 | 22 §1.1 | 含宏设计前后 DEF 宏坐标 |
| 2 | iPL GP overflow/HPWL | 22 §1.2 | gcd/aes 读 GP 结束值 |
| 3 | iTO apply vs plan | §4.7 | commit 前后 slack |
| 4 | iSTA PBA/MCMM/SI | §4.9 | 审计 + vs PT |
| 5 | iLVS 恒等式 / 是否存在 | §4.13 | G12；目录审计 |
| 6 | iPA 活动源覆盖 | §4.11 | 报告活动源标注 |
| 7 | GDS 二进制真伪 | §4.1 | gdstk round-trip |
| 8 | 静默失败面 | §2.2 | grep 空 catch / 假成功 |
| 9 | 引擎顺序陷阱 | §4.16 | eval↔rcx 对照 |
| 10 | 规模上限 | §2.2 | G13 |
| 11 | 数值门槛适用性 | §3 | Phase 0 校准（只收紧） |
| 12 | iRT plateau / timing 驱动真假 | 26 §1.1/1.3 | 违例序列 + enable_timing A/B |
| 13 | **商业并排墙钟剖面** | G21 | 独占机 daily 五套 |

---

## 附录 A · 方法论（全文有效）

1. **文档是假说不是事实**；fork 结论不外推，只提示查哪。
2. **每个理论附能杀死它的对照**；先量再写。
3. **读最终产物，不读中间态**。
4. **完成 = 代码 + 机器门禁 + 当前二进制重跑一致**。
5. **响亮失败不静默**；禁止 rc=0 配错产物。
6. **门槛是需求不是变量**；不达则降阶段目标，不改门槛。
7. **不争抢计时**：性能只在独占机采；共享机只采正确性。
8. **Agent 一次一工作包**（§6）；禁止无门禁的"大重构"。

## 附录 B · 文档族规划

> 体例强制：[`01-ai-doc-conventions-rv1.md`](01-ai-doc-conventions-rv1.md)（对齐 `24-iPL-3d-rv1.0`：§0–§14 + 附录；逐 kernel 走读；ALG 伪代码；缺省关→零回归）。  
> 每份方案 = 症结审计 → FR/NFR → HLD/LLD → **商业 Know-how（引用 `03`）** → 门禁 → Exhibit → 测试 → 里程碑 → 未验证。  
> 横切 Know-how 目录：[`03-commercial-knowhow-catalog.md`](03-commercial-knowhow-catalog.md)。

| 文档 | 对象 | 商业对标 | 绑定门禁 | 状态（v1.5） |
|---|---|---|---|---|
| `01-ai-doc-conventions-rv1.md` | 文档体例 | — | 全文档 | **rv1.0** |
| `01-baseline-report.md` | 逐工具真实基线 | — | G1/G1b | Phase 0 产出 |
| `02-fork-divergence-audit.md` | fork↔本仓 | — | 决策④ | Phase A |
| `03-commercial-knowhow-catalog.md` | 商业手法推演目录 | 全工具 | 全文引用 | **v1.0** |
| `10-iDB-database.md` | iDB | OpenAccess | G1/G13/G16 | **rv1.0** |
| `11-solver.md` | solver | 数值内核 | G2/G3/G5/G15 | **rv1.0** |
| `12-evaluation.md` | evaluation | QoR/Perf 地基 | G1/G15/G17–G21 | **rv1.0** |
| `20-iFP.md` | 布图 | floorplan | G3/G17 | **rv1.0** |
| `21-iNO.md` | 网表修复 | DC topo 局部 | G6/G18 边界 | **rv1.0** |
| `22-iPL.md` | 布局 | place_opt | G2/G3/G5/G17/G21 | **rv1.0（旗舰）** |
| `23-iCTS.md` | 时钟树 | ccopt | G4/G19 | **rv1.0** |
| `24-iPDN-iPNP.md` | 电源 | PG/Voltus | G10/G17 | **rv1.0** |
| `25-iTO.md` | 时序优化 | route_opt | G6/G17 | **rv1.0** |
| `26-iRT.md` | 布线 | NanoRoute | G5/G13/G17/G21 | **rv1.0** |
| `27-iSTA.md` | STA | **PrimeTime** | G7/G6 | **rv1.0** |
| `28-iRCX.md` | 提取 | **StarRC** | G8/G7 | **rv1.0** |
| `29-iPA-iIR.md` | 功耗/IR | **PTPX**/Voltus | G9/G10 | **rv1.0** |
| `30-iDRC.md` | DRC | **Calibre** | G11/G5 | **rv1.0** |
| `31-iLVS.md` | LVS | nmLVS | G12 | **rv1.0（greenfield）** |
| `32-iECO.md` | ECO | eco/Conformal | G16/G17 | **rv1.0** |
| `33-iLO-iTM.md` | 逻辑/映射 | DC/Genus | G18 | **rv1.0（空壳）** |
| `40-platform.md` | 平台 | session | G1/G14/G15/G16 | **rv1.0** |
| `41-interface.md` | 接口 | TCL/Python | G14 | **rv1.0** |
| `42-perf-parity.md` | 性能 | 墙钟/内存 | G21/G20 | **rv1.0** |

### 附录 B.1 · Know-how → 阶段速查

见 `03-commercial-knowhow-catalog.md` §8。关键记忆：

- **签核链**：KH-STA-* / KH-RCX-* 先于实现链 QoR。  
- **实现链**：KH-PL-* → KH-CTS-* → KH-RT-* → KH-TO-*。  
- **横切**：KH-X-01 真值源、KH-X-04 响亮失败、KH-EV-* 看板。

---
