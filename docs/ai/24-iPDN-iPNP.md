<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 24 · iPDN / iPNP 电源网络 · 商业对标方案 · rv2.0

> 文档号：24-rv2.0　　版本：rv2.0（实现评审优化）　　里程碑：**模板网格可信 → 有误差界的快速评估 → 功耗/IR/EM 驱动优化 → vs create_pg / Voltus**
> 体例：`01-ai-doc-conventions-rv1.md`（对齐 `24-iPL-3d-rv1.0.md` 走读深度）
> 主纲：`00-ieda-commercial-parity-master-plan-v1.1.md`（G10 前置/G17/G21）　Know-how：KH-IR-01、KH-X-04
> 联合架构：`04-ppa-technical-review-and-optimization-rv1.md` 的 `MoveTxn + DirtySet`；闭环工作台：`51-agent-native-eda-detailed-plan-v1.0.md`
> 对标：**ICC2 create_pg / Innovus PG + Voltus**
> 上游：`20-iFP`（core/IO）、`29-iPA`（功耗预算）　下游：`29-iIR`（签核）、`26-iRT`（避障）
> 覆盖：`src/operation/iPDN/`（api + pdn_plan/pdn_via ≈3.0k LOC）与 `src/operation/iPNP/`（≈4.7k LOC，含独立 main.cpp）
> 纪律：**文档是假说不是事实**；断言带 `file:line`；未实测写「未验证」。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.0–v1.1 | 2026-07-20 | 双工具边界摘要 |
| rv1.0 / v2.0 | 2026-07-20 | 体例升格；坐实 iPDN 模板 API 与 iPNP SA 存在；「功耗驱动是否真进 cost 未验证」 |
| **rv1.1 / v3.0** | **2026-07-21** | **大改**：对 iPDN/iPNP 两树逐文件走读后重写。核心修订五条，**三条推翻/深化 v2.0**：**(1)** v2.0 的悬案「SA cost 项 live？」——**实锤 live，且代价惊人**：`SimulatedAnnealing::evaluateCost`（`:358-380`）对**每个候选解**执行 `saveToIdb → EGR 拥塞评估 → IREval → 还原`，而 `IREval::runIREval`（`IREval.cpp:33-45`）驱动的是**真实 `PowerEngine`**（`buildPGNetWireTopo + runIRAnalysis + reportIRAnalysis`）——**SA 每步 move 付一次全量 IR 求解**，cost 是活的，性能模型是崩的（大设计上 SA 不可行，§1.3-B1，待 E-PDN-02 量化）;**(2)** v2.0 判「IREval 估计 ≠ iIR 签核」——**需修正**：IREval 不是独立估计器，是**包在真 PowerEngine 外的薄壳**（127 LOC），与 iIR 签核是否同源同参须 29-iIR 裁决（§14）；真正的风险不是精度口径而是「每 move 一次签核级求解」的成本;**(3)** iPDN 也有空壳：`pdn_router/`、`pdn_sim/`、`solver/`、`utility/` 四个目录**只有 0 字节 CMakeLists**，`test/` 零用例——iPDN 真实资产 = `pdn_plan`（788+791+344）+ `pdn_via`（197）+ api（147）;**(4)** 生产 flow 的双段结构坐实：iPDN 在 **iFP 阶段**经 `pdn.tcl` 建模板（`create_grid` met1 + `create_stripe` met4，`run_iFP.tcl:85` → `module/pdn.tcl:11-13`），iPNP 在**后段** `run_pnp`（`run_iEDA.sh:41`）→ `iPNP_result.def/v`——**PG 真源确实有两棒**，交接语义（覆盖 or 增量）未文档化;**(5)** iPNP 有**独立 `main.cpp`**（169 LOC，自带 TCL console 注册 `run_pnp`）——与 iEDA 主二进制并存的第二入口，架构归属需裁定。 |
| **rv2.0** | **2026-07-23** | 实现评审：候选由 typed delta 表达、禁止 iDB 充当临时画布；用固定尺度、局部电导敏感度、周期 full IR 与不确定性触发构成有误差界的 SA 内环；补 PCG 热启动/预条件器复用、EM/IR/容量驱动条带推导和 false-feasible/rank-regret 验收。 |

---

## 1. 症结审计（逐文件代码走读）

### 1.1 功能形态——双工具真实资产盘点

| 工具 | 模块 | LOC | 判定 |
|---|---|---|---|
| **iPDN** | `api/ipdn_api.cpp` | 147 | 9 个模板命令薄门面 |
| | `module/pdn_plan/pdn_plan.cpp` | 788 | 网格/条带生成主逻辑 |
| | `module/pdn_plan/pdn_cut_stripe.cpp` | 791 | 切割避障 |
| | `module/pdn_plan/pdn_plan_macro.cpp` | 344 | 宏连接 |
| | `module/pdn_via/pdn_via.cpp` | 197 | via 阵列 |
| | **`module/{pdn_router,pdn_sim}`、`solver/`、`utility/`** | **0** | **空壳×4（仅 0 字节 CMakeLists）** |
| | `test/` | 0 | **零用例** |
| **iPNP** | `main.cpp` | 169 | **独立二进制入口**（自带 TCL console） |
| | `PNP.cpp` / `config/PNPConfig.cpp` | 221/309 | 驱动+配置 |
| | `module/synthesis/{PowerVia,PowerRouter,NetworkSynthesis}` | 658/573/142 | PG 综合 |
| | `module/optimizer/{SimulatedAnnealing,PdnOptimizer}` | 445/110 | SA 优化（global/region 两模式 `PdnOptimizer.cpp:55,91`） |
| | `module/evaluator/{IREval,CongestionEval,DRCEval,FastPlacer}` | 127/50/38/55 | 薄封装族（IREval→**真 PowerEngine**） |
| | `data_manager/{PNPGridManager,PNPIdbWrapper,SingleTemplate}` | 178/87/86 | 网格+写回 |
| | `module/pnp-cmd/CmdRunPnp.cc` | 100 | TCL 命令 |

### 1.2 算法成熟度——逐 kernel

| kernel | 现状算法（file:line） | 判定 | 缺口 |
|---|---|---|---|
| iPDN `createGrid/createStripe` | 层方向交替 strap（`ipdn_api.cpp:50-72` → pdn_plan） | 成熟工程 | **宽度/间距与用户输入硬绑**——功耗预算推导无（KH-IR-01 一半） |
| `pdn_cut_stripe` | 切割避障（791 LOC，全工具最大文件） | 实 | 与 macro/blockage 交互边界未验证 |
| `connectLayerList` | 层数<2 打 Error（`ipdn_api.cpp:79`） | 边界诚实 | — |
| iPNP SA | Metropolis（`SimulatedAnnealing.cpp:195-209` `acceptSolution`：劣解按 exp(−ΔE/T) 接受） | **真 SA** | 初始解依赖、温度表外生性 |
| **SA cost** | `evaluateCost`（`:358-380`）= w_ir·norm(IR) + w_of·norm(overflow)，IR 来自 `IREval.runIREval()` → **PowerEngine 全量求解**，overflow 来自 EGR | **cost 全 live**（v2.0 悬案实锤） | **每 move 一次全量 IR+EGR**（§1.3-B1）；归一化用 max/min/avg（`normalizeIRDrop`），min 恒变时归一化漂移 |
| `IREval` | 薄壳驱动 PowerEngine（`IREval.cpp:33-45`）+ `displayIRDropMap` | **非估计器，是签核引擎薄壳** | 与 iIR 同源性待 29 裁决 |
| `PdnOptimizer` | `optimizeGlobal`（`:55`）/ `optimizeByRegion`（`:91`）两模式 | 有 | region 模式分区策略未读 |
| `PNPIdbWrapper` | `saveToIdb`（`:42`）/ `writeIdbToDef`（`:69`） | 写回路径在 | 与 iPDN special net 的**覆盖语义未文档化** |

### 1.3 边界 / 回退 / 疑似问题

- **B1（疑似，性能）SA 成本模型不可扩展**：每候选解 = 一次 iDB 写回 + 全量 EGR + 全量 PowerEngine IR + 还原（`SimulatedAnnealing.cpp:358-380`）。SA 通常需 10³–10⁵ 次 move 评估——**gcd 或许能跑，中设计即不可行**。**杀死实验 E-PDN-02**：gcd 上统计 `run_pnp` 的 SA 迭代数 × 单次 evaluateCost 墙钟，外推 50k inst；若外推超 G21 预算一个量级 → 实锤，须换增量 IR 或代理模型。
- **B2 iDB 写回抖动**：`evaluateCost` 每次「写入候选 → 评估 → 写回旧解」（`temp_wrapper.saveToIdb` 两次，`:360,:378`）——iDB 成为 SA 的临时画布，若中途崩溃留下**候选污染态**（无事务）。失败语义未验证。
- **B3 归一化漂移**：`normalizeIRDrop(max,min,avg)` 依赖当次统计量，候选间基线漂移——cost 跨 move 可比性存疑（未验证）。
- 边界好的一面：`connectLayerList` 层数检查（v2.0 已记）；SA 报告逐迭代落盘（`:178-184` IR/overflow 分列）。

### 1.4 跨工具协调——PG 两棒交接是最大结构问题

| 方向 | 现状 | 判定 |
|---|---|---|
| iFP → iPDN | iFP 阶段 `pdn.tcl` 建 met1 grid + met4 stripe（`run_iFP.tcl:85`、`module/pdn.tcl:11-13`） | **第一棒**：模板在 floorplan 期定型 |
| iPDN → iDB | special net 写出 | 通 |
| iPNP → iDB | `saveToIdb/writeIdbToDef` → `iPNP_result.def/v`（`run_iPNP.tcl` 尾部） | **第二棒**：覆盖 or 增量未文档化（FR-PDN-02） |
| iPNP → PowerEngine | `IREval` 薄壳 | 通（但用作 SA 内环成本，B1） |
| iPA → iPDN | **功耗预算→条带宽度推导：无** | 宽度靠用户 tcl 硬编（`pdn.tcl:11-13` 的 0.48/1.60） |
| iPDN/iPNP → iIR | 签核在 29 | 分工正确 |
| iPNP 独立 main | `main.cpp` 自带 console | **第二入口**，与 iEDA 主二进制关系未文档化 |

---

## 2. 需求 FR / NFR / 约束

| ID | 需求 | 现状 | P |
|---|---|---|---|
| FR-PDN-01 | 保持模板生成（iFP 段） | ✓ | — |
| FR-PDN-02 | ★ 黄金 PG 单一真源：iPDN→iPNP 交接语义文档化 + stamp | 两棒未文档化 | P0 |
| FR-PDN-03 | ★ 条带宽度/间距 ← iPA 功耗预算可追溯（替 `pdn.tcl` 硬编） | 硬编 | P1 |
| FR-PNP-01 | ~~SA cost-term-live 测试~~ → **改为**：cost live 已实锤，转 **SA 成本模型预算化**（E-PDN-02 量化 + 增量 IR/代理评估） | live 但贵 | P0 |
| FR-PNP-02 | ★ IREval↔iIR 同源裁定（联动 29：同引擎同参数则文档化，异则标定差） | 未裁定 | P1 |
| FR-PNP-03 | ★ SA 事务化评估（崩溃不留污染态） | 无事务 | P1 |
| FR-PDN-04 | ★ iPDN 空壳×4 处置 + test/ 从零建 | 空壳/零测 | P0（G14 卫生） |
| FR-PDN-05 | ★ iPNP 独立 main.cpp 归属裁定（并入主二进制 or 文档化双入口） | 双入口 | P2 |
| FR-PDN-06 | vs create_pg 几何可比 | 未对拍 | P2 |
| NFR-PDN-01 | 空操作/空命令非成功 | — | G14 |
| NFR-PDN-02 | IR 结论只认 iIR 签核 | — | G10 |
| NFR-PDN-03 | SA 单次 evaluateCost 墙钟 | 记录→预算（E-PDN-02 后定） | G21 |

约束：新特性缺省关→零回归；禁止在 iPDN 内再写一套 IR 求解器；禁止双真源互不理睬。

---

## 3. HLD 总体架构

### 3.1 数据流（据生产 flow 实测）

```text
iFP 段:  pdn.tcl ──► iPDN createGrid/Stripe/via/macro connect ──► iDB special nets（第一棒）
            ▲ 硬编宽度（0.48/1.60）←—— ★ 改由 iPA 预算推导（FR-PDN-03）
布局/CTS 段 …
iPNP 段: run_pnp ──► PdnOptimizer(global|region)
            └─► SA: candidate → saveToIdb → EGR + PowerEngine IR → restore   [每 move 全量！]
            ──► PNPIdbWrapper.writeIdbToDef → iPNP_result.def/v（第二棒）
            ★ stamp pdn_generator=ipdn|ipnp（FR-PDN-02）
下游:    iIR 签核（29）只读 stamp 指向的几何
```

### 3.2 关键设计决策（含被否）

| # | 决策 | 被否 |
|---|---|---|
| D1 | iPDN=模板（iFP 段）；iPNP=优化（后段）；iIR=签核 | 两套都当签核生成器 |
| D2 | 真源 stamp + 交接语义文档化 | 双写不合并、互不理睬 |
| D3 | **先量化，再采用可校准的物理敏感度模型；ML 不是首选** | 无误差界地按固定间隔跳过 IR，或直接上黑盒 ML |
| D4 | IREval 维持薄壳；同源裁定后再谈统一 | 在 iPNP 内另写估计器 |
| D5 | iPDN 空壳×4 删除；test 从零建 | 保留占位 |
| D6 | iPNP 独立 main 暂保留并文档化 | 立刻合并二进制（影响面未审） |

---

## 4. LLD · 模块分解

### 4.1 ★ 真源交接（FR-PDN-02，P0）

```text
ALG-4.1-1  PG 真源协议
  iPDN 写出 special nets 后 stamp pdn_generator=ipdn
  iPNP saveToIdb 最终解后 stamp pdn_generator=ipnp + 记录 delta（增/改的 net 数）
  iIR/报告只读 stamp 指向的几何
  断言：两棒之间无第三方改写 special net（flow 契约，40 联动）
```

### 4.2 ★ SA typed delta + 多保真评估（FR-PNP-01/03，P0）

**现状签名（真实）**：`CostResult SimulatedAnnealing::evaluateCost(const PNPGridManager&, const PNPGridManager&)`（`SimulatedAnnealing.cpp:358`）。

```text
ALG-4.2-1  evaluate(candidate_delta)
  baseline = immutable PGGraph + current accepted solution
  delta = {add/remove/resize_strap, add/remove/via_array, affected_tiles}
  先查 hard constraints: connectivity, min width/spacing, via enclosure,
                        EM current density, routing-capacity reserve；失败候选不进 SA cost
  congestion_delta = local EGR(affected_tiles + halo)
  ir_delta, uncertainty = sensitivity(G, V, delta)
    # 首选局部 conductance-matrix update / Schur complement；
    # 多候选同一电流目标时可用 adjoint voltage sensitivity 排序
  normalized_cost 使用 protocol 冻结的 baseline scale，禁止按每个候选 min/max/avg 重标
  if uncertainty > guardband or accepted_since_exact >= K or candidate 接近预算边界:
    exact = full_ir(candidate, warm_start=last_voltage)
    更新敏感度误差模型；若预测与 exact 符号相反则回滚并收紧 guardband
  MoveTxn 只在 accept 后把 typed delta 原子提交到 iDB；reject/崩溃不改变生产 DB

ALG-4.2-2  full_ir 加速
  PG 稀疏结构不变（仅宽度/电阻变）时复用符号分解/预条件器，PCG 从上次 V 热启动
  稀疏结构变化时仅局部重建，超过 dirty_ratio 阈值才全量重建 preconditioner

验收不只看 Spearman：同时报告 top-k rank regret、false-feasible rate、peak-IR 误差 p95；
任何候选被代理判可行而 full IR 判超预算均计 false-feasible，生产目标必须为 0（guardband 后）。
边界：缺省 `sa.eval_mode=exact` 保持现状；fast 模式只有校准集和 holdout 门禁都通过才可生产开启。
```

### 4.3 ★ 条带宽度预算推导（FR-PDN-03，P1）

```text
对每个 region/layer:
  I_peak = activity_window_peak(P_inst / Vdd)，并保留 simultaneity/decap 假设来源
  w_em ≥ I_peak / (J_limit(layer,temp) · metal_thickness)
  R_strap = R_sheet(layer) · length / width；via_array 由单 via R 与 I_limit 决定
  用网络灵敏度求满足 max_drop≤budget 的最小 Δconductance，并转成候选 width/pitch/via count
  w_strap = snap_up(max(w_em, w_ir, min_width), manufacturing_grid)
  再检查：可用 routing tracks、spacing、macro blockage、总 PG metal budget
产出 pdn 参数建议 → pdn.tcl 模板变量化（不再硬编 0.48/1.60）
```

平均功耗只用于 early estimate；生产条带/EM 门禁必须使用带来源的峰值或时间窗电流。无法获得动态活动时，报告保守假设和不确定性，不得把平均电流当峰值真值。

### 4.4 iPDN 空壳与测试（FR-PDN-04，P0）

删除 `pdn_router/pdn_sim/solver/utility` 四空目录；`test/` 建 gtest：createGrid 几何断言、cut_stripe 避障用例、connectLayerList 层数失败用例。

### 4.5 模块状态一览

| 模块 | 现状成熟度 | 主复杂度 | 关键边界 | 复用姿势 |
|---|---|---|---|---|
| iPDN pdn_plan/cut/macro/via | 成熟（2.1k） | O(条带×障碍) | 层数检查在；macro 交互未验证 | 保留 |
| iPDN api | 薄门面（147） | — | — | 保留 |
| iPDN 空壳×4 | **空** | — | 误导 | 删除 |
| iPNP SA | 真 SA（445） | O(iters×(EGR+IR)) | **每 move 全量 IR（B1）** | 保留+预算化 |
| IREval | PowerEngine 薄壳（127） | 签核级求解 | 非估计器（v2.0 修正） | 保留；同源裁定 |
| CongestionEval/DRCEval/FastPlacer | 薄封装（50/38/55） | — | — | 保留 |
| PdnOptimizer | 两模式（110） | — | region 策略未读 | 保留 |
| PNPIdbWrapper | 写回（87） | — | 无事务（B2/B3） | ★事务化 |
| iPNP main.cpp | 独立入口（169） | — | 双二进制 | 文档化（D6） |

---

## 5. 配置

| 键 | 默认 | 说明 |
|---|---|---|
| `pdn.source_of_truth` | `ipdn` → SA 后 `ipnp` | stamp（FR-PDN-02） |
| `pnp.enable` | 现状（flow 已调） | — |
| `sa.eval_mode` | `exact` | `exact|sensitivity_guarded`；fast 模式需 holdout 门禁 |
| `sa.exact_interval` | 1（=现状） | fast 模式中至多 K 个 accepted move 一次 full IR |
| `sa.uncertainty_guardband` | 协议给定 | 超阈值或近预算边界立即 full IR |
| `sa.ir_drop_weight` / `sa.overflow_weight` | 现状 | 报告已分列 |
| `sa.cost_scale.{ir,overflow,metal,power}` | baseline 固定值 | 一次 run 内冻结，禁止候选自归一化 |
| `pdn.width_from_budget` | false | ★ FR-PDN-03，缺省关零回归 |

---

## 6. 指标分解

| 维 | 含义 | 记录 |
|---|---|---|
| PG 金属量 / via 数 | | 独立列 |
| SA iters / accept_rate / wall | SA 效率 | 独立列 |
| evaluateCost 四段计时 | saveToIdb/EGR/IR/restore | ★ E-PDN-02 |
| IREval peak / **iIR peak** | 两列分列（同源裁定后注明口径） | 禁混 |
| pdn_generator stamp | 真源追踪 | ★ |

禁用非 iIR 数报 G10。

---

## 7. 状态机 / 命令语义

```text
iFP: create nets → grid/stripe → connect layers/macro/IO → stamp(ipdn)
iPNP: load → optimize(global|region) → final saveToIdb → stamp(ipnp) → def/v 导出
失败 rc≠0；SA 中断 → iDB 恢复到最后一次完整态（★ FR-PNP-03）
```

---

## 8. 跨工具 Cascade

| 上/下游 | 信号 | 契约 |
|---|---|---|
| iFP → iPDN | core box/IO | pdn.tcl 模板化（FR-PDN-03） |
| iPA → iPDN | 功耗预算 | ★ 宽度推导 |
| iPDN → iPNP | special nets + stamp | §4.1 |
| iPNP → iIR | PG 几何 + stamp | iIR 只读 stamp |
| iPNP → iRT | PG blockage | 避障 |
| iPDN/iPNP → 40 | flow 阶段契约 | 两棒顺序硬约束 |

---

## 9. 商业 Know-how 映射

| KH-ID | 落点 |
|---|---|
| KH-IR-01（真 PG 驱动 IR） | §4.1 真源 + §4.3 预算推导 |
| KH-X-04（失败响亮） | connectLayerList 已有；SA 事务化 ★ |
| KH-EV-02（指标分列） | IREval/iIR 分列（§6） |

---

## 10. 商业对照看板 + 演进 M0–M4

### 10.1 看板

| 指标 | iPDN/iPNP | 商业 PG | 门槛 | G |
|---|---|---|---|---|
| 可布 PG | 有（两段式） | 有 | 连通 | — |
| SA 可扩展性 | 每 move 全量 IR | 增量/代理 | E-PDN-02 外推 ≤G21 | G21 |
| peak IR | 经 iIR | Voltus | G10 | G10 |
| 金属量/拥塞 | | | 记录 | G17 |
| 真源可追 | 无 stamp | 单源 | stamp 链完整 | G14 |

### 10.2 对照实验（杀假说）

| 实验 | 方法 | 杀死条件 |
|---|---|---|
| E-PDN-01 | 双真源冲突注入（两棒间第三方改写） | 无 stamp 链检测 → FR-PDN-02 必要性实锤 |
| **E-PDN-02** | SA 迭代数 × 单次 evaluateCost 四段计时，外推 50k inst | 外推 ≤ G21 预算 → 「B1 不可扩展」被杀（维持现状） |
| E-PDN-03 | sensitivity_guarded vs 每候选 full IR（校准集+holdout） | false-feasible>0、top-k rank regret 超阈值或 peak-IR p95 误差超 guardband → fast 模式被杀，回 exact |
| E-PDN-04 | 跳过 iIR 直接引用 IREval peak 报 G10 | 协议拒（NFR-PDN-02） |
| E-PDN-05 | 同一拓扑连续 resize 候选：冷启动 vs PCG 热启动+预条件器复用 | 解差超过 tol 或迭代/墙钟无显著下降 → 复用策略不晋级 |

### 10.3 演进

```text
M0 先量：空壳/双入口台账；E-PDN-02 成本分解；真源 stamp 设计
M1 可信：stamp 链 + 空壳清理 + iPDN gtest 从零
M2 主算法：SA sensitivity_guarded 多保真评估（E-PDN-03 裁决）；iPA 预算接线
M3 打平：vs create_pg 几何可比
M4 纵深：网格自适应 / region SA 策略
```

---

## 11. Exhibit

| 档 | 产物 |
|---|---|
| JSON | `pdn_summary.json`（含 stamp、宽度来源） |
| CSV | stripe 清单、SA 逐迭代（已有 `SA_report.txt`，迁 CSV） |
| text | IREval vs iIR 对比表（同源裁定后） |

---

## 12. 测试计划

| 层 | 用例 | 锁住 |
|---|---|---|
| L0 | 层数<2 FAIL；createGrid 几何断言；cut_stripe 避障 | iPDN 从零 |
| L0 | SA 置零 IR 权重 → 解必变（live 回归锁） | §4.2 |
| L1 | 小设计连通；两棒 stamp 链断言 | FR-PDN-02 |
| L4 | gcd SA 墙钟分解 | E-PDN-02 |
| L5 | 无 iIR 不报 G10 PASS；SA 中断不留污染态 | G10/FR-PNP-03 |

---

## 13. 里程碑（按周）

| 周 | 交付 | 验收 |
|---|---|---|
| W0 | 台账 + E-PDN-02 报告 | M0 |
| W1 | stamp 链 + 空壳清理 + gtest 骨架 | M1 |
| W2 | sensitivity_guarded + full-IR guard（E-PDN-03 裁决） | M2 |
| W3 | iPA 预算接线 | M2 |
| W4+ | vs create_pg | M3 |

PR 切片：PDN-0 台账 → PDN-1 stamp → PDN-2 空壳+gtest → PDN-3 SA 预算化 → PDN-4 预算接线 → PDN-5 对标。

---

## 14. 未验证 / 负面结论

| # | 项 | 说明 |
|---|---|---|
| 1 | B1：SA 每 move 全量 IR 的实际墙钟占比 | E-PDN-02 裁决前标「疑似」 |
| 2 | IREval 与 iIR 是否同引擎同参数 | 薄壳调 PowerEngine 已证；iIR 侧待 29 裁决 |
| 3 | 两棒之间 special net 是否被第三方改写 | stamp 落地前未验证 |
| 4 | 归一化漂移（B3）对 cost 可比性的影响 | 未验证 |
| 5 | `optimizeByRegion` 分区策略与收益 | 未读 |
| 6 | cut_stripe 与 macro 重叠边界 | 未验证 |
| 7 | iPNP 独立 main 的用户面 | 文档化前未审 |

**不要重走**：
- 不要在 iPDN 内再写一套完整 IR 求解器（KH-IR 分工）。
- 不要未量化就上 ML 代理/增量 IR——E-PDN-02 先给四段计时。
- 不要让 SA 直接读写 iDB 当画布而无事务（B2 崩溃污染）。

---

## 附录 A · 迁移 checklist

- [ ] E-PDN-02 成本分解报告（四段计时 × 迭代数 × 外推）
- [ ] 真源 stamp（iPDN/iPNP/契约断言）
- [ ] iPDN 空壳×4 删除 + gtest 从零
- [ ] typed delta + sensitivity_guarded + full-IR guard（E-PDN-03）
- [ ] SA 事务化（FR-PNP-03）
- [ ] iPA 预算→宽度推导（FR-PDN-03）
- [ ] IREval↔iIR 同源裁定（联动 29）
- [ ] iPNP 独立 main 文档化（D6）
- [ ] vs create_pg 对拍

## 附录 B · 决策记录

| # | 决策 | 被否 |
|---|---|---|
| E-1 | 模板/优化/签核三段分治 | 两套都当签核生成器 |
| E-2 | 真源 stamp + 契约 | 双写不合并 |
| E-3 | 先量化再改 SA 成本 | 直接上代理模型 |
| E-4 | IREval 维持薄壳 | iPNP 内另写估计器 |
| E-5 | 空壳删除 | 保留占位 |
| E-6 | 独立 main 文档化暂留 | 立刻合并二进制 |

## 附录 C · 术语

- **两棒 PG**：iFP 段 iPDN 模板 → 后段 iPNP 优化的生产结构（本案命名）
- **stamp**：`pdn_generator=ipdn|ipnp` 真源标记
- **sensitivity_guarded**：局部物理敏感度评估；由不确定性、预算边界和 accepted-move 上限触发 full IR
- **EGR**：early global route 拥塞估计（iPNP 经 CongestionEval 调用）

## 附录 D · 证据摘录（file:line 最小集）

| 断言 | 证据 |
|---|---|
| SA cost 全 live | `SimulatedAnnealing.cpp:358-380`（saveToIdb→EGR→IR→restore）；`:175-184` 逐迭代 IR/overflow 落盘 |
| IREval=PowerEngine 薄壳 | `IREval.cpp:33-45`（`buildPGNetWireTopo/runIRAnalysis/reportIRAnalysis`） |
| Metropolis | `SimulatedAnnealing.cpp:195-209`（exp(−ΔE/T)） |
| 两模式优化 | `PdnOptimizer.cpp:55,91` |
| iPDN 模板 API | `ipdn_api.cpp:50-113`；层数检查 `:79` |
| iPDN 空壳×4 | `module/{pdn_router,pdn_sim}/`、`solver/`、`utility/` 仅 0 字节 CMakeLists |
| 生产两棒 | `run_iFP.tcl:85`→`module/pdn.tcl:11-13`；`run_iEDA.sh:41`；`run_iPNP.tcl` 尾部 `run_pnp`→`iPNP_result.def/v` |
| 写回路径 | `PNPIdbWrapper.cpp:42,69` |
| 独立 main | `iPNP/main.cpp:51`（`int main`，注册 run_pnp） |
| 体量 | iPDN+iPNP `find ... wc -l` = 7724 |
