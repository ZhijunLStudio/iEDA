<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 12 · evaluation 评测地基 · 商业对标优化方案 · rv1.1

> 文档号：12-rv1.1　　版本：v3.0（大改，逐文件代码走读后重写）　　里程碑：**工具内 L1 评估器 → L2 QoR 度量地基（schema + parity harness + G1/G15/G17–G21）**
> 体例：`01-ai-doc-conventions-rv1.md`（对齐 `24-iPL-3d-rv1.0.md` 走读深度）
> 主纲：`00-ieda-commercial-parity-master-plan-v1.1.md`（§1bis、G1/G1b/G15/G17–G21）
> Know-how：`03-commercial-knowhow-catalog.md`（KH-EV-01/02、KH-X-01/08、KH-PLAT-02）
> 覆盖：`src/evaluation/` 全树（8463 LOC）：`src/module/{congestion,density,wirelength,timing,eval_io}`、`src/util/{init_sta,init_egr,init_idb,init_flute,...}`、`api/`、`apps/`、`database/`
> 纪律：**文档是假说不是事实**；断言带 `file:line`；budget 外生。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.0–v1.2 | 2026-07-20 | harness/schema/L1-L2 设想；章节未对齐体例 |
| rv1.0 / v2.0 | 2026-07-20 | 体例重排；重申 L1 行数证据 |
| **rv1.1 / v3.0** | **2026-07-21** | **大改**：对 `src/evaluation/` 全树 30 个源文件逐一读完重写。核心修订四条：**(1)** v2.0 §S1 说 L1 "被 iTO EvalAPI 消费"——**不准**：全仓消费方实测为 **iPL**（`ExternalAPI.cc` + `NesterovPlace.cc:1359-1387`，GP 主循环内嵌 LUT-RUDY 拥塞驱动优化）与 **iPNP**（`CongestionEval.cpp` 50 LOC 薄封装，**非平行重写**，v2.0 担心的重复实现不成立）、`iPL/test/CongEvalAPITest.cc`；iTO 侧未见 include（**未验证是否经其他通道**）；**(2)** L1 内核实测比 v2.0 印象**更全**：congestion 有 EGR/RUDY/LUT-RUDY 三族九入口（`congestion_eval.cpp:58-100`），其中 **EGR 依赖 iRT 落盘目录 `rt_dir_path`**（`:58-70`）——跨工具顺序陷阱不只 init_sta 一处；**(3)** `init_sta.cc`（1946 LOC）的重不止于"启 STA"：include 面含 `RTInterface.hpp`、`api/PowerEngine.hh`、`api/TimingEngine.hh`、`salt/base/flute.h`（`:29-35`）——一个 "init" util 直连 iRT/iPW/iSTA/flute 四个外部栈，是**全树耦合度最高的文件**；**(4)** `database/summary_db.cpp` 是 **19 行空壳**（仅空 ctor/dtor）——L2 的"数据库"占位早已存在但无任何字段，v2.0 把 L2 当纯 greenfield 不准确：greenfield 是对的，但**有一个会误导后来者的空壳需要先处置**。 |

---

## 1. 症结审计（逐文件代码走读）

### 1.1 功能形态——L1/L2 分界实测

| 层 | 内容 | 判定 |
|---|---|---|
| L1（优化回路评估器） | `module/` 四内核 + `api/` 五门面 + `apps/` 五个独立二进制 | **真实存在且已接线**（消费者 §1.4） |
| L2（QoR 度量地基） | `database/summary_db.cpp` **19 行空壳**；无 schema/harness/对比器 | **等同 greenfield**（空壳先处置，§4.0） |

### 1.2 算法成熟度（L1 逐内核）

| kernel | LOC | 现状算法 | 判定 | 缺口 |
|---|---|---|---|---|
| `congestion_eval` | 1900 | **三族九入口**：EGR（`evalHori/Verti/UnionEGR`，`:58-70`，**读 iRT `rt_dir_path` 落盘的 overflow CSV**）/ RUDY（`:73-85`，net 密度摊派）/ LUT-RUDY（`:88-100`，查表修正） | 成熟（优化级） | EGR 输入依赖 iRT 目录约定——**跨工具顺序耦合**；禁当 L2 签核 |
| `density_eval` | 1030 | bin 密度/溢出统计 | 成熟 | 同上 |
| `wirelength_eval` | 475 | HPWL/STEINER 等（`wirelength_lut` 83 LOC 查表） | 成熟 | 同上 |
| `timing_eval` | 169 | `runSTA/runVecSTA/evalTiming(routing_type, rt_done)`（`:24-34`）+ 单例 `getInst/destroyInst`（`:14-22,55`） | 薄门面 | 单例全局态，复跑 destroy 纪律未验证 |
| `init_sta` | **1946** | 建 STA：`readSdc→buildGraph→initRcTree→updateTiming` + **直连 iRT/iPW/flute**（include `RTInterface.hpp`/`PowerEngine.hh`/`salt/base/flute.h`，`:29-35`） | **重耦合 init**，不是纯评估 | 与 40 F2 顺序陷阱同源；职责应拆（§4.6） |
| `init_egr` | 317 | EGR 数据初始化（iRT 目录读取） | 支撑 | 与 congestion_eval 的目录契约未文档化 |
| `init_idb` / `init_flute` | 250 / 62 | iDB/flute 引导 | 支撑 | — |
| `eval_io/{timing,density,wirelength}_io` | 120/112/86 | 结果落盘 | 支撑 | — |
| `api/{congestion,density,wirelength,timing,union}_api` | 347/282/189/146/79 | 单例 C 接口门面 | 成熟 | 单例复跑语义未验证 |
| `apps/{congestion,density,wirelength,timing,union}_app` | 244/182/155/75/101 | 独立评估二进制 | 有 | 与 flow 内调用结果一致性未验证 |
| `database/summary_db` | **19** | 空 ctor/dtor | **空壳** | §4.0 处置 |

### 1.3 边界 / 回退 / 假成功

- L1 快近似、**只许进优化回路**（铁律保留）：EGR/RUDY 是估计器，禁当 signoff 证据。
- `evalEGR` 的输入是**另一个工具（iRT）的落盘目录**——目录不存在/路径约定漂移时的失败语义未验证（联动 iEDA-3D fork 的 EGR 目录前科：`get_config().get_output_path()` 未设时拼出 `/rt/...`，本仓同类风险**未排除**）。
- 单例族（`TimingEval::_timing_eval`、各 api）复跑时必须 `destroyInst`，flow 内多处调用是否成对**未验证**。
- `summary_db` 空壳：名字暗示"汇总数据库"，新人易以为 L2 已存在——G14 级卫生问题。

### 1.4 跨工具协调（消费方实测）

| 方向 | 现状 | 证据 | 判定 |
|---|---|---|---|
| iPL → evaluation | GP 主循环内嵌拥塞驱动：`NesterovPlace.cc:1359-1387` 注释明写 "LUT-RUDY based congestion-driven optimization"，另有 GR 版 TODO（`:1383-1387`）；`ExternalAPI.cc` | **已接线，最深消费者** | L1 定位实证 |
| iPNP → evaluation | `iPNP/.../CongestionEval.cpp`（50 LOC）`#include "congestion_api.h"`（`:28`）薄封装；同目录 DRCEval 38 / FastPlacer 55 / IREval 127 | 薄封装 | **非平行重写**（v2.0 担心解除） |
| iRT → evaluation | EGR 的输入生产者（`rt_dir_path` overflow CSV） | `congestion_eval.cpp:58-70` | **反向顺序依赖**：评估要等 iRT 落盘 |
| iTO → evaluation | v2.0 声称的"EvalAPI 消费"在 `src/operation/iTO` 未见 include | grep 零命中 | **未验证**；要么走 init_sta 间接，要么 v2.0 判错（§14） |
| evaluation → 主纲门禁 | 无统一 QoR schema，各工具报告各自为政 | — | L2 缺口（本方案主体） |

---

## 2. 需求 FR / NFR / 约束

### 2.1 FR（★=新增）

| ID | 功能 | 现状 | P |
|---|---|---|---|
| FR-EV-01 | ★ QoR schema + 校验器（`src/evaluation/qor/`） | ✗（`summary_db` 空壳先处置） | P0 |
| FR-EV-02 | ★ parity harness（`benchmark/qor/`：run/compare/board） | ✗ | P0 |
| FR-EV-03 | ★ budget 外生校验进 CI | ✗ | P0 |
| FR-EV-04 | 各工具推送适配（iRT/iCTS/iSTA/iPA/iIR/iDRC/iPL） | ✗ | P0 |
| FR-EV-05 | power/IR 字段接入（iPA/iIR 在 evaluation 外） | ✗ | P1 |
| FR-EV-06 | L1 保持 + 回归锁死（含 NesterovPlace 内嵌调用数值不动） | ✓ | 红线 |
| FR-EV-07 | L1↔L2 口径差标定 | ✗ | Phase B |
| FR-EV-08 | ★ EGR↔iRT 目录契约文档化 + 缺目录响亮失败 | 未文档化 | P1 |
| FR-EV-09 | ★ 单例复跑语义（destroyInst 成对）审计 + gtest | 未验证 | P1 |
| FR-EV-10 | ★ `summary_db` 空壳处置（填实为 L2 schema 载体或删除） | 空壳 | P0 |
| NFR-EV-01 | L2 只读最终产物 | — | G15 |
| NFR-EV-02 | 逐指标独立转绿，禁加权总分 | — | G17/KH-EV-02 |

约束：无 protocol 冻结禁止宣称 δ≤5%；L1 任何改动必须过 iPL GP 数值零回归（FR-EV-06）。

---

## 3. HLD 总体架构

### 3.1 数据流

```
L1（现状，不动）: congestion(EGR/RUDY/LUT-RUDY)/density/WL/timing
   ↑ 消费: iPL NesterovPlace(GP 内嵌) · iPNP(薄封装) · apps 独立二进制
   ↑ 输入: iDB + 【iRT rt_dir_path(EGR 反向依赖)】
L2（新建 src/evaluation/qor/）:
   tools → final artifacts(DEF/rpt) → QoR JSON(schema 校验)
        → compare_qor.py ↔ commercial gold → align_report → G1/G17/G21 assert
   parity_protocol.json 冻结 effort/report_point/δ/ε
```

### 3.2 关键设计决策（含被否）

| # | 决策 | 被否 |
|---|---|---|
| D1 | L1/L2 分层；L1 数值一字不动（iPL GP 内嵌调用是红线） | 把 L1 精确化当 signoff |
| D2 | schema 先于 harness | 先写对比脚本 |
| D3 | L2 只读最终产物（DEF/rpt），不读引擎内存 | 读中间态 |
| D4 | budget 外生 + 机械校验（G15） | 工具自报 |
| D5 | L2 落在 `src/evaluation/qor/` 新目录；`summary_db` 空壳删除（避免两个"L2"） | 在 19 行空壳上长（名字已误导） |
| D6 | EGR↔iRT 目录契约显式文档化，缺目录响亮失败 | 静默读空目录产"拥塞=0"假成功 |

---

## 4. LLD · 模块分解

### 4.0 目录与空壳处置（FR-EV-10）

```text
benchmark/qor/
  run_qor_baseline.sh / run_qor_scale.sh / run_perf_compare.sh
  schemas/qor_metrics.json
  parity_protocol.json
  compare_qor.py
  <design>/<stage>/{ieda,commercial}/
src/evaluation/qor/        # ★ 新建 L2
  QoRSchema.hh / QoRValidator.cpp / QoREmitter.hh
src/evaluation/database/summary_db.cpp   # 删除（19 行空壳，D5）
```

### 4.1 ★ protocol + summary schema（FR-EV-01）

```json
{
  "version": "1",
  "primary_pnr": "innovus|icc2",
  "effort": "standard",
  "report_points": ["post_place","post_cts","post_route","signoff_sta"],
  "delta": {"wns":0.05,"hpwl":0.05,"wl":0.08,"power":0.05},
  "epsilon_runs": 2,
  "designs_daily": ["gcd","aes","jpeg","sky130_gcd","ics55_gcd"],
  "signoff": {"sta":"pt","rcx":"starrc","drc":"calibre","power":"ptpx"}
}
```

summary 字段纪律：`unit`/`source` 必填；`budget` 仅 protocol 白名单；`activity_source`；`skipped_drc_rules`；`binary_hash`（变 → G1 基线陈旧）。

### 4.2 ★ 判定算法（FR-EV-02/03）

```text
ALG-4.2-1  for m in required:
  commercial missing → SKIP（记账，非 PASS）
  |ieda-comm| > δ·scale + ε → FAIL m      # ε=复跑波动（KH-X-08）
  逐指标独立；禁加权总分
ALG-4.2-2  budget 校验:
  abs(budget-value)<tol 且 budget 来自自身输出 → FAIL
  budget 非白名单 → FAIL
```

### 4.3 ★ 推送适配（FR-EV-04）

iRT→drc/wl；iCTS→skew/latency；iSTA→wns/tns；iPA→power+activity；iIR→peak_ir；iDRC→drc+skipped；iPL→hpwl/overflow。**每指标必须有门禁消费者**（fork Metric3D 写-only 教训）。

### 4.4 L1 内核维护纪律（FR-EV-06 红线）

- `congestion/density/wirelength/timing` 四内核 + api 五门面：**数值一字不动**；只允许补 gtest、文档、失败语义。
- iPL `NesterovPlace` 内嵌调用点（`:1359-1387`）是 L1 最深的耦合点——任何 api 签名变动必须先过 iPL GP 数值零回归。

### 4.5 ★ EGR↔iRT 契约（FR-EV-08）

`evalEGR(rt_dir_path, ...)`（`congestion_eval.cpp:58-70`）：契约写明（a）目录由 iRT 何命令在何阶段产出；(b) 缺目录/缺文件 → 响亮失败而非"拥塞 0"；(c) 文件名 `*_egr_{horizontal,vertical,union}_overflow.csv` 冻结进协议。**deferred**：契约文本需先读 iRT 侧产出代码（§14）。

### 4.6 `init_sta` 职责拆分（审计建议，P2 冻结）

1946 LOC 的 init util 直连 iRT/iPW/flute（§0-3）。**本里程碑不动**（动它影响 timing_eval 全链），但记录：长期应拆为"STA 引导"（留）与"iRT/iPW 桥接"（各归其工具）。列为技术债，禁止在本文件之外悄悄扩散此耦合模式。

### 4.7 模块状态一览

| 模块 | 现状成熟度 | 主复杂度 | 关键边界 | 复用姿势（现状→目标） |
|---|---|---|---|---|
| congestion_eval（三族） | 成熟 | O(nets×bins) | EGR 依赖 iRT 目录（§4.5） | 锁回归 + 契约化 |
| density_eval | 成熟 | O(cells) | — | 锁回归 |
| wirelength_eval + lut | 成熟 | O(nets) | — | 锁回归 |
| timing_eval | 薄门面（单例） | 委托 iSTA | 单例复跑（§4 FR-EV-09） | 锁回归 + 审计 |
| init_sta | **重耦合**（1946） | — | 直连 iRT/iPW/flute | 冻结，技术债（§4.6） |
| api 五门面 | 成熟 | — | 单例语义 | 锁回归 |
| apps 五二进制 | 有 | — | 与 flow 一致性未验证 | 补一致性用例 |
| `summary_db` | **空壳**（19 LOC） | — | 误导命名 | 删除（D5） |
| `qor/` ★ | 无 | O(指标×设计) | budget 外生 | 新建 |

---

## 5. 配置

protocol 版本锁定；改 δ/effort 必须升 version；二进制 hash 变 → G1 基线失效。L1 无可配新项（红线）。

---

## 6. 指标分解

看板列：WNS/TNS/HPWL/WL/DRC/Power/IR/skew/latency/wall_s/RSS——**禁止加权总分掩弱项**；每列带 `unit/source/budget(外生)`。

---

## 7. 状态机

```text
freeze_protocol → run_flow → emit_summary → validate_schema
  → (optional) compare_gold → align_report → gate_assert
校验失败：产物不进库；EGR 缺目录：响亮失败（非"拥塞 0"）
```

---

## 8. 跨工具 Cascade

| 上/下游 | 信号 | 契约 |
|---|---|---|
| iPL/iPNP → L1 | 优化回路估计 | 数值零回归（FR-EV-06） |
| iRT → L1(EGR) | `rt_dir_path` overflow CSV | §4.5 契约（FR-EV-08） |
| 全工具 → L2 | 最终产物 summary.json | §4.1 schema |
| L2 → 主纲 | G1/G15/G17/G21 门禁 | 与 40 `run_qor_baseline`、42 `run_perf_compare` 共管 |

---

## 9. 商业 Know-how 映射

| KH | 落点 |
|---|---|
| KH-EV-01（金参考并排） | §4.2/§10 |
| KH-EV-02（逐指标独立） | §4.2 ALG-4.2-1 |
| KH-X-01（真值源对齐） | L2 只读最终产物（D3） |
| KH-X-08（ε 波动带） | ALG-4.2-1 ε |
| KH-PLAT-02（budget 外生） | ALG-4.2-2 |

---

## 10. 商业对照看板 + 演进 M0–M4

### 10.1 看板

| 指标 | iEDA | 商业 | δ | G |
|---|---|---|---|---|
| WNS/TNS/HPWL/DRC/Power | | | ≤5% 等 | G17 |
| peak IR | | | [1,100] mV | G10 |
| 墙钟 | | | ≤1.5× | G21 |
| L1 回归 | 现值冻结 | — | 0 漂移 | FR-EV-06 |

### 10.2 对照实验（杀假说）

| 实验 | 方法 | 杀死条件 |
|---|---|---|
| E-EV-01 | 假达标注入（budget=value） | 校验器不放行 |
| E-EV-02 | 改中间态不动最终产物 | L2 数值变 → D3 被杀 |
| E-EV-03 | 协议漂移（私改 δ） | 拒跑 |
| E-EV-04 | 复跑波动 >ε | 不进判定 |
| E-EV-05 | 删 `rt_dir_path` 跑 EGR | "拥塞 0"静默成功 → §4.5 实锤 |
| E-EV-06 | iPL GP 跑前后 L1 api 数值 | 任何漂移 → FR-EV-06 红 |

### 10.3 演进

```text
M0 先量：消费方台账（§1.4 实测表）+ summary_db 空壳处置 + schema/protocol 冻结空跑
M1 可信：QoRValidator + 五工具推送 + iEDA-only daily 基线
M2 主算法：EGR 契约 + 单例审计 + PT/StarRC 金参考并排抽样
M3 打平：G17/G21 门禁启用（逐指标）
M4 纵深：PPA 外环复用 harness；init_sta 拆分（技术债）
```

退出门禁：M0→假指标被拒+空壳清零；M1→五套 summary；M2→align_report；M3→G17 assert；M4→非本阶段阻断。

---

## 11. Exhibit

| 档 | 产物 |
|---|---|
| JSON | `summary.json`（schema 校验过）、`align_report.json` |
| text | 看板 `board.md` |
| CSV | L1 现有 `*_rudy_*.csv` / `*_egr_*_overflow.csv`（不动） |
| plot | 可选差分直方图 |

---

## 12. 测试计划

| # | 测试 | 锁住 |
|---|---|---|
| T-EV-1 | 缺 unit/source 拒收 | §4.1 |
| T-EV-2 | budget==value FAIL | G15 |
| T-EV-3 | 改中间态 L2 不变 | D3 |
| T-EV-4 | 五工具 schema 过 | FR-EV-04 |
| T-EV-5 | 协议漂移拒跑 | §5 |
| T-EV-6 | EGR 缺目录响亮失败 | FR-EV-08 |
| T-EV-7 | L1 api 数值双跑一致 | FR-EV-06 |

---

## 13. 里程碑（按周粗估）

| 周 | 交付 | 验收 |
|---|---|---|
| W0 | 消费方台账 + 空壳处置 + protocol/schema 空跑 | M0 |
| W1 | QoRValidator + 五工具推送 | M1 |
| W2 | EGR 契约 + 单例审计 + daily 基线 | M1/M2 |
| W3 | 金参考并排抽样 | M2 |
| W4+ | G17/G21 门禁 | M3 |

PR 切片：EV-0 台账+空壳+protocol → EV-1 schema+校验器 → EV-2 五工具推送+daily → EV-3 EGR 契约 → EV-4 金参考并排 → EV-5 G17 assert。

---

## 14. 未验证 / 负面结论

| # | 项 | 说明 |
|---|---|---|
| 1 | iTO 是否消费 evaluation（v2.0 §S1 声称） | grep `src/operation/iTO` 未见 include；可能经 init_sta 间接或判错——**待证** |
| 2 | iRT 侧 EGR 产出代码与目录约定 | §4.5 契约化前必读 |
| 3 | 单例族复跑语义（destroyInst 成对） | flow 多点调用未审计 |
| 4 | apps 五二进制与 flow 内调用结果一致性 | 未验证 |
| 5 | 各工具报告可机读性清单 | M1 前提 |
| 6 | L1–L2 偏差量级 | FR-EV-07，Phase B |
| 7 | 商业批跑 license/队列 | 外生约束 |

**不要重走**：
- 不要在 `summary_db` 空壳上长 L2（名字已误导一次，D5）。
- 不要把 L1 估计器（RUDY/EGR）当 signoff 证据引用。
- 不要无 protocol 用「感觉差距」驱动优化。
- 不要复制 `init_sta` 的"一个 init 连四栈"模式到新模块。

---

## 附录 A · 迁移 checklist

- [ ] 消费方台账（§1.4 表落 `attachments/eval-consumers.md`）
- [ ] `summary_db` 空壳删除 PR
- [ ] `parity_protocol.json` + `qor_metrics.json` 冻结空跑
- [ ] `src/evaluation/qor/` schema + QoRValidator
- [ ] 五工具推送 + daily 基线
- [ ] EGR↔iRT 契约文档 + 缺目录响亮失败 + T-EV-6
- [ ] 单例复跑审计 + T-EV-7
- [ ] 金参考并排 + align_report
- [ ] G17/G21 assert 开关

## 附录 B · 关键决策记录

| # | 决策 | 被否 |
|---|---|---|
| E-1 | L1/L2 分层，L1 数值冻结 | 精确化 L1 拖死 iPL GP |
| E-2 | schema 先于 harness | 先写对比脚本 |
| E-3 | L2 只读最终产物 | 读引擎内存 |
| E-4 | budget 外生 + 机械校验 | 工具自报 |
| E-5 | 每指标挂门禁消费者 | 写-only 数据湖 |
| E-6 | L2 落新目录 qor/，删 summary_db 空壳 | 在空壳上长 |
| E-7 | EGR 契约显式化 + 响亮失败 | 静默"拥塞 0" |
| E-8 | init_sta 拆分冻结为技术债 | 本里程碑强拆 |

## 附录 C · 术语

- **L1**：优化回路评估器（RUDY/EGR/density/WL/timing 估计），快、近似、禁 signoff
- **L2**：QoR 度量地基（schema+harness+金参考对比），只读最终产物
- **EGR**：Early Global Route 拥塞估计（本仓实现读 iRT 落盘 overflow CSV）
- **RUDY / LUT-RUDY**：net 密度摊派拥塞估计 / 查表修正版
- **ε 带**：复跑不确定度（KH-X-08）

## 附录 D · 证据摘录（file:line 最小集）

| 断言 | 证据 |
|---|---|
| L1 行数 | `congestion_eval.cpp` 1900、`density_eval.cpp` 1030、`wirelength_eval.cpp` 475、`timing_eval.cc` 169、`init_sta.cc` 1946 |
| congestion 三族九入口 | `congestion_eval.cpp:58-100` |
| EGR 依赖 iRT 目录 | `congestion_eval.cpp:58-70`（`rt_dir_path` 入参） |
| iPL GP 内嵌调用 | `NesterovPlace.cc:1359-1387`（"LUT-RUDY based congestion-driven optimization"） |
| iPNP 薄封装 | `iPNP/.../CongestionEval.cpp:28`（`#include "congestion_api.h"`，50 LOC） |
| init_sta 重耦合 | `init_sta.cc:29-35`（RTInterface/PowerEngine/TimingEngine/flute include） |
| TimingEval 单例 | `timing_eval.cc:14-22,55` |
| summary_db 空壳 | `database/summary_db.cpp` 19 LOC（空 ctor/dtor） |
| 全树体量 | `find src/evaluation -name '*.cpp' -o -name '*.cc' | xargs wc -l` = 8463 |
