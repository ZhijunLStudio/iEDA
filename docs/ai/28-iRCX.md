<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 28 · iRCX 寄生提取 · 商业对标方案 · rv1.0

> 文档号：28-rv1.0　　版本：rv1.0　　里程碑：**2.5D pattern SPEF（含真实耦合）→ vs StarRC 逐网标定（G8）→ 耦合可被 iSTA 消费 → 增量提取（喂 G17）**
> 体例：`01-ai-doc-conventions-rv1.md`；深度对标：`24-iPL-3d-rv1.0.md`（逐 kernel 走读）
> 商业金标：**StarRC**（辅 Quantus）；门禁：**G8 / G17**（辅 G7/G15/G21；无 G8 不准宣称 G17 时序/功耗打平）
> 上游：`26-iRT`、`10-iDB`、ITF/captab；下游：`27-iSTA`、`25-iTO`、`12-evaluation`
> 纲领：`00-ieda-commercial-parity-master-plan-v1.1.md`；Know-how：`03-commercial-knowhow-catalog.md` **KH-RCX-01…03**
> 覆盖：`src/operation/iRCX/`（`flow/`、`module/calculate/`、`module/report/`、`parser/itf*`、`tool/compare_spef/`、`api/RCXAPI.*`）
> 纪律：**文档是假说不是事实**；断言带 `file:line`；未实测写「未验证」；每条理论附能杀死它的对照。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.0 | 2026-07-20 | 审计摘要：耦合进 SPEF；ITF 全；CompareSpef 在；未 vs StarRC 标定 |
| v1.1 | 2026-07-20 | 短篇展开，**未对齐 01 规范**；架构图写 `*CC` 易误导 |
| **rv1.0** | **2026-07-20** | **体例对齐 01**：对 `Extraction` / `EdgeCapAccumulator` / `SpefDumperDNet` / `ThicknessModel` / `CompareSpefTool` / ITF parser **逐文件走读后重写**。保留正确结论（**有提取无 StarRC 标定**、**全量无增量**）；推翻/细化：① 「SPEF `*CC`」→ 实现写的是 IEEE **`*CAP` 三节点耦合行**（真实 aggressor 名），全树无字面 `*CC` 关键字；② 「ITF 全」→ 主结构（conductor/dielectric/via/corner）在，**PBTV 厚度应用被注释掉**、部分 PROCESS_* 回调无 setter；③ 「CompareSpef=标定」→ 仅为 **SPEF-vs-SPEF** 工具，**无** `run_starrc_align` harness。**缺省新特性关闭 → 零回归**。 |

---

## 1. 症结审计（逐 kernel / 逐模块代码走读）

对 `src/operation/iRCX/` 主路径走读后的判定。生产骨架：

```text
RCXAPI::init(config) → Setup(ITF/captab/mapping + adaptDB)
RCXAPI::run → Extraction: topology → environment → process variation → R/C
RCXAPI::report → SpefDumper (*D_NET / *CAP / *RES)
工具: compare_spef / plot_spef / dump_net_shape
```

### 1.1 功能形态——可运行 2.5D 提取器在，签核标定环缺

| 能力 | 现状 | 证据 | 判定 |
|---|---|---|---|
| 全芯片提取 | ✓ | `Extraction.cc:31–37`：`buildTopology && buildEnvironment && buildProcessVariation && calculateParasitics` | **可用** |
| ITF 主结构 | ✓ | `ItfRead::createDb` 注册 conductor/dielectric/via（`ItfRead.cpp:37–46`） | **成熟解析** |
| Cap tab 插值 | ✓ | 外部 `captab_file` + `CapTable` | **与 ITF 分离** |
| 接地 C / 耦合 C | ✓ | `EdgeCapAccumulator` + `foldCoupling`（`EdgeCapAccumulator.cc:115–135`） | **pattern 累加** |
| SPEF dump | ✓ | `SpefDumperDNet.cc`：`*CAP`/`*RES`（`183–213`） | **可用** |
| 跨网耦合 aggressor | ✓ | `*CAP` 三 token：本网 node + **对端 SPEF 名** + C（`SpefDumperDNet.cc:185–191`） | **真实挂点**（非假 CC） |
| Wire/Via R | ✓ | `WireResistanceModel` / `ViaResistanceModel` | **可用** |
| CompareSpef | ✓ SPEF↔SPEF | `compare_spef/README.md:1–7`；TCL `compare_spef` | **工具在** |
| vs **StarRC** 标定 harness | ✗ | 仓内无 `run_starrc_align.sh`（仅旧文档规划）；无 G8 CI | **P0 缺口（G8）** |
| 增量提取 | ✗ | `topo_pool.clear()` 后全量；无 dirty-net API | **P1（KH-RCX-03）** |
| Shield 专用模型 | ✗ | special-net 耦合折进接地（`EdgeCapAccumulator.cc:121–123`） | 缺口 |
| Density/PBTV 生效 | ✗ 半死 | `model_thickness_` 注释掉多项式，厚度=nominal（`ThicknessModel.hh:111–117`） | **死接线** |

### 1.2 算法成熟度——StarRC 快速模式同类，缺场解校准环

| kernel | 现状算法 | 判定 | 缺口 |
|---|---|---|---|
| `EdgeCapAccumulator` | 双侧/单侧/无邻：`nearCap`/`farthestCap`；coupling 对半分或全加；special→ground；same-net 丢弃（`EdgeCapAccumulator.cc:65–135`） | **教科书+工程 2.5D** | 无 multi-neighbor 族、宽金属 fringe、via C |
| `CapacitanceCalc` | 边级查表累加；via 边不算 C（审计：`calcEdge` 185–187） | 可用 | via 电容 |
| `ResistanceCalc` | wire ρ(W,T)/Rpsq+CRT；via + half_node_scale | 成熟向 | via thickness 变分 TODO |
| `SpefDumper` / `buildCouplingRefs` | `merged_ccap` 双向挂网（`SpefDumper.cc:98–139`） | **正确耦合导出** | 无字面 `*CC`（若下游只认 `*CC`——**未验证** iSTA） |
| `CompareSpefTool` | total/ground/coupling C、p2p R、mismatch（README） | 成熟对比器 | **不是** StarRC 驱动器；`-delay` 未实现（`CompareSpefConfig.cc:109`） |
| `MetalDensity` + PBTV | 可算 `effective_density`，厚度应用注释掉 | **半成品** | design/process layer id 混用风险（`ThicknessModel.hh:126–141` vs `MetalDensity` build） |
| ITF PROCESS_* | grammar CALLBACK 存在 | 解析面宽 | **无 `itfrSetProcess*` setter** → 空回调（审计） |

**假说 H-RCX-1（可杀）**：G8 失败主因是 **全局系统偏差（可 α 标定）**，而非拓扑枚举缺失。  
**杀死实验 E-RCX-01**：同 DEF+同 ITF，逐网 `(C_i−C_s)/C_s`；若高相关+过原点偏移 → 允许全局/分层 α；若低相关+按层/长度离群 → **杀 H-RCX-1**，改补边类型/via/shield，**禁止盲调 α**。

**假说 H-RCX-2（可杀）**：耦合已写入 SPEF ⇒ iSTA SI 可消费。  
**杀死实验 E-RCX-02**：iSTA 读回 SPEF 统计 discard/未挂上的 CC；扰动单耦合看 slack（对接 27 T-E1）。若 discard>0 或 slack 不变 → 杀「耦合已闭环」，查命名/单位/`*CAP` vs `*CC` 语义。

### 1.3 边界 / 回退 / 单位——操作化可用，单位硬编码

- **SPEF 单位硬编码**：`*C_UNIT 1.0 FF` / `*R_UNIT 1.0 OHM`（`SpefDumperHeader.cc:47–48`）；内部 `cap_ff` 与头对齐。  
- **Compare/Plot** 读入 scale 到 FF（`SpefReader.cc:166–168` 一带）。  
- **缺口**：不可配置单位；无从 ITF 推导单位校验（G15 相关）。  
- **全量重算**：每次 `run_rcx` = adaptDB + 全网（`RCXAPI.cc:51–65` 一带）。  
- **假成功风险**：CompareSpef 绿（自比对）≠ G8 绿（vs StarRC）。

### 1.4 跨工具协调——SPEF 出口在，真值源与增量断

| 方向 | 现状 | 判定 |
|---|---|---|
| iDB/iRT → iRCX | `adaptDB` + topology | **通**（布线几何质量依赖上游） |
| ITF/captab → iRCX | Setup 多 corner（`Setup.cc:227–238`） | **通** |
| iRCX → SPEF 文件 | `report_rcx` | **通** |
| iRCX → iSTA | 文件 SPEF；SI 依赖耦合消费 | **半通**；E-RCX-02 未做 |
| iRCX ↔ StarRC | PlotSpef 有 `kStarRc` 几何解析（`PlotSpefCapResolver.cc:57–74`）；**无自动对齐流水线** | **G8 前置缺** |
| ECO/iTO → 增量 | 无 | **断** |

### 1.5 死配置 / 死接线 / 假成功点名

1. **PBTV 厚度应用注释掉**（`ThicknessModel.hh:111–117`）→ density 路径空转。  
2. **`DROP_FACTOR_LATERAL_SPACING`** 入库、environment/C **零引用**（审计）。  
3. **`query*IsolatedCap`** 无调用方；运行用 `farthestCap`。  
4. **ITF PROCESS_*** 无 setter。  
5. **compare `-delay`** 显式未实现。  
6. **旧文档 `*CC` 措辞**易让人以为缺耦合——**实际有 `*CAP` 耦合行**。

### 1.6 症结优先级表

| ID | 症结 | 证据 | P |
|---|---|---|---|
| **R1** | 从未 vs StarRC 门禁化标定 → **G8 不可证** | 无 harness；CompareSpef≠StarRC | **P0** |
| **R2** | Density/PBTV 死接线 + layer-id 风险 | `ThicknessModel.hh:111–117,126–141` | P1 |
| **R3** | 无增量提取 | `Extraction.cc` 全量 | P1 |
| **R4** | 耦合→iSTA 消费未实测 | H-RCX-2；KH-RCX-02 | P1 |
| **R5** | Shield / via C / multi-pattern 缺口 | foldCoupling special→gnd | P1 |
| R6 | 单位硬编码、无校验 | Header FF | P2（G15） |
| R7 | 旧文档 `*CC` 误导 | 实现为 `*CAP` 三节点 | P2（文档） |

**§1 最关键 2 条（回报）**：**R1（无 vs StarRC/G8 harness）**、**R2（PBTV/density 写了不生效）**——若只报「精度」类：R1 + **耦合消费未证（R4）** 并列第二；本版以代码死接线 R2 与标定 R1 为双首症结。

---

## 2. 需求 FR / NFR / 约束

### 2.1 FR（★ = 相对现状新增）

| ID | 功能 | 现状 | rv1.0 |
|---|---|---|---|
| FR-RCX-01 | 全量 2.5D 提取 + SPEF | ✓ | 保留主路径 |
| FR-RCX-02 | ITF + captab + multi-corner | ✓ | 保留；修死回调按需 |
| FR-RCX-03 | 跨网耦合进 SPEF（`*CAP` 三节点） | ✓ | 保留；★ 文档/测试明确语义 |
| FR-RCX-04 | Wire/Via R | ✓ | 保留 |
| FR-RCX-05 | CompareSpef SPEF↔SPEF | ✓ | ★ 门禁化 JSON 输出 |
| FR-RCX-06 | ★ **vs StarRC align harness** | ✗ | ★ G8 前置 |
| FR-RCX-07 | ★ **标定系数表**（全局/分层 α） | ✗ | ★ 仅当 E-RCX-01 支持系统偏差；缺省 α=1 |
| FR-RCX-08 | ★ **PBTV/density 生效**（修注释+layer id） | 死接线 | ★ 开关缺省 **off**（零回归）；on 后对拍 |
| FR-RCX-09 | ★ **增量 extract(dirty_nets)** | ✗ | ★ 缺省走全量 |
| FR-RCX-10 | ★ 耦合消费校验（对接 iSTA） | 未测 | ★ E-RCX-02 |
| FR-RCX-11 | ★ Shield / special-net 策略显式 | 折接地 | ★ 可配；缺省=现状 |
| FR-RCX-12 | PlotSpef / DumpNetShape | ✓ | 保留可视化 |

### 2.2 NFR（可测数字）

| ID | 项 | 指标 |
|---|---|---|
| NFR-RCX-01 | **G8** | vs StarRC：逐网 total C **p90 相对差 < 5%**；耦合 C **p90 < 10%**（纲领） |
| NFR-RCX-02 | G8 相关 | R²(total C) ≥ 0.98；mismatch net → 0 趋势 |
| NFR-RCX-03 | 零回归 | α=1、PBTV off、无增量 → 与当前 SPEF 字节/数值 ε 一致 |
| NFR-RCX-04 | 增量正确性 | 同 dirty 集：增量 vs 全量同网 \|ΔC\| < ε（协议，建议相对 1% 或绝对 0.1fF） |
| NFR-RCX-05 | 耦合消费 | iSTA discard CC = 0（或报告响亮非零） |
| NFR-RCX-06 | 墙钟 | 日常设计 ≤ 1.5× StarRC 起步观测（G21 分项） |
| NFR-RCX-07 | 单位 | SPEF 头与内部一致；JSON `unit:fF`/`Ohm` |

### 2.3 红线约束

- **金标 = StarRC**；同 DEF + **同 ITF/captab**（KH：禁混工艺文件）。  
- **无 G8 背书，不准宣称 G17 时序/功耗打平**（纲领硬约束）。  
- **禁止无分桶数据盲调 α**（E-RCX-01）。  
- **缺省新特性关闭 → 零回归**（PBTV on、增量、α≠1 均显式）。  
- 禁止用「CompareSpef 自比对 PASS」代替 G8。

---

## 3. HLD

### 3.1 数据流

```text
ITF / captab / mapping / corners
        │
        ▼
   Setup + adaptDB (iDB geometry)
        │
        ▼
   TopologyBuilder ──► TopoPool (edges/nodes/vias)
        │
        ▼
   Environment (side/overlap neighbors)
        │
        ▼
   ProcessVariation (etch width; ★PBTV thickness opt-in)
        │
        ├──────────────────┐
        ▼                  ▼
 CapacitanceCalc      ResistanceCalc
 EdgeCapAccumulator    Wire/Via R
        │                  │
        └────────┬─────────┘
                 ▼
          RCTable / SpefDumper
          *D_NET *CAP(gnd+coupling) *RES
                 │
       ┌─────────┼─────────┐
       ▼         ▼         ▼
   iSTA read   PlotSpef   ★ CompareSpef vs StarRC gold
                           → align_report.json → G8
```

### 3.2 关键设计决策（含被否）

| ID | 决策 | 被否方案 | 理由 |
|---|---|---|---|
| D1 | **先 harness 再调 α / 改模型** | 先盲调系数 | 无分桶则无法杀 H-RCX-1 |
| D2 | **保持 2.5D pattern 主路线** | 立刻上全芯片场解 | StarRC 快速模式同类；缺的是校准环（KH-RCX-01） |
| D3 | **耦合保持 `*CAP` 三节点**；若 iSTA 需 `*CC` 再双写 | 无证据改格式 | E-RCX-02 先行 |
| D4 | **PBTV 修复后缺省 off** | 直接打开改厚度 | 零回归；打开需 vs StarRC |
| D5 | **增量外挂 dirty API，缺省全量** | 默认可增量 | 正确性风险 |
| D6 | **标定 α 可审计 changelog** | 静默硬编码 | G15 |
| D7 | **G8 先于 G17** | 边提边宣称打平 | 纲领 |

---

## 4. LLD · 模块分解

### 4.0 落点

```text
src/operation/iRCX/
  source/flow/extraction/Extraction.*     ← ★ 增量入口
  source/module/process/ThicknessModel.*  ← ★ PBTV 生效开关
  source/module/calculate/capacitance/    ← ★ 可选 α 乘子
  source/module/report/SpefDumper*.*      ← 保持；★ 单测耦合行
  source/tool/compare_spef/               ← ★ JSON stats 门禁化
  calibration/CoeffTable.*                ← ★新增（缺省 α=1）
benchmark/qor/rcx/
  run_starrc_align.sh                     ← ★新增
  align_report.schema.json
```

### 4.1 ALG · 全量提取（已有）

**真实现状**（`Extraction.cc:31–37`）：

```text
[已有] Extraction::run():
  buildTopology()          // clear + build_all
  buildEnvironment()
  buildProcessVariation()  // etch; PBTV 厚度当前=nominal
  calculateParasitics()    // R then C
```

- **复杂度**：O(edges · neighbors + vias)；可 `thread_num`（`RCXAPI`）。  
- **边界**：空设计早退；via 边 C 跳过。  
- **复用**：禁止平行第二套提取器。

### 4.2 ALG · 耦合累加与 SPEF（已有，语义澄清）

```text
[已有] foldCoupling(side, cc_ff):
  if specialNet: ground += cc; return
  if sameNet: return
  append_net_ccap_entry(net, edge, adj_edge, corner, cc_ff)

[已有] SpefDumper writeDNet *CAP:
  for coupling:  id  node_self  aggressor_node_name  C
  for ground:    id  node_self  C
```

- **证据**：`EdgeCapAccumulator.cc:115–135`；`SpefDumperDNet.cc:183–198`。  
- **Know-how**：KH-RCX-02。  
- ★ 单测：合成两平行线 → SPEF 必现三 token 行且双方网名可反查。

### 4.3 ALG · ★ StarRC harness + 标定（FR-RCX-06/07）

```text
★ ALG-RCX-1  run_starrc_align.sh
  spef_i = iRCX(same DEF, ITF, captab)
  spef_s = StarRC(same inputs)
  CompareSpefTool -test spef_i -ref spef_s → stats.json
  buckets: layer / length / fanout / coupling_ratio
  assert p90_total_c < 0.05 && p90_cc < 0.10   # G8

★ ALG-RCX-2  CoeffTable (default identity)
  if E-RCX-01 显示系统偏移:
    C' = α_layer[layer] * C   # 或 global_alpha
  else:
    禁止调 α；转补模型
  变更写入 changelog + exhibit
```

- **缺省**：α=1，行为=现状。  
- **复用**：CompareSpef **Composition**，不重写对比器。

### 4.4 ALG · ★ PBTV / density 收口（FR-RCX-08）

**现状**：多项式结果注释，强制 `etch.thickness = t_nom`（`ThicknessModel.hh:111–117`）。

```text
★ ALG-RCX-3  model_thickness_(..., enable_pbtv):
  [已有] 若无 PBTV 表 → t_nom
  ★ if !enable_pbtv: thickness = t_nom          // 零回归
  ★ else:
       启用 rt_deff 多项式（解开注释）
       统一 density 查询用 process_layer_id
       单测：密度变 → 厚度变 → C 单调方向符合预期
```

- **杀死实验 E-RCX-03**：`enable_pbtv=true` 后 vs StarRC p90 **变差** → 杀「直接开 PBTV」，保持 off 并修公式/权重。

### 4.5 ALG · ★ 增量提取（FR-RCX-09）

```text
★ ALG-RCX-4  extractIncremental(dirty_nets):
  expand = dirty ∪ 1-hop neighbors (coupling)
  rebuild topo/env 仅 expand（或标记失效边）
  重算 R/C → 按 net 名替换 SPEF 字典
  assert vs full extract on expand nets
```

- **缺省**：API 可存在但 TCL 默认仍全量 `run_rcx`。  
- **边界**：空 dirty → no-op；跨 corner 逐角。

### 4.6 ALG · Resistance（已有）

```text
[已有] WireResistanceModel: ρ(W,T) 或 Rpsq + CRT
[已有] ViaResistanceModel: via R * half_node_scale_factor
[已有] SPEF *RES 两节点（SpefDumperDNet.cc:200–213）
```

- ★ 纳入 G8 分桶（R 与 C 分开报，禁单一标量）。

### 4.7 ALG · CompareSpef / PlotSpef（已有）

| 工具 | 角色 | RV1.0 |
|---|---|---|
| CompareSpef | SPEF↔SPEF；C/R/CC mismatch | ★ JSON schema + G8 脚本调用 |
| PlotSpef | SPEF→GDS/LYP；识别 iRCX/StarRC 几何 | 可视化归因，不替代 G8 |
| DumpNetShape | 形状 dump | 保留 |

### 4.8 模块状态一览

| 模块 | 成熟度 | 主复杂度 | 关键边界 | 复用姿势 |
|---|---|---|---|---|
| Setup / ITF | 成熟解析 | O(文件) | PROCESS_* 空回调 | 保留+按需修 |
| Topology | 成熟 | O(几何) | clear 全量 | 保留 |
| Environment | 成熟 | O(边·邻) | special 作邻边 | 保留 |
| EdgeCapAccumulator | 成熟 2.5D | O(边) | same-net 丢；special→gnd | 保留 |
| Resistance | 成熟向 | O(边+via) | via thick TODO | 保留 |
| SpefDumper | 成熟 | O(节点+CC) | 单位硬编码 | 保留 |
| Thickness/PBTV | 半死 | O(边) | 注释掉 | ★ 开关修复 |
| CompareSpef | 成熟工具 | O(nets) | 非 StarRC 驱动 | Composition→G8 |
| CoeffTable ★ | 新增 | O(1)/层 | 缺省 1 | 新增 |
| Incremental ★ | 新增 | O(dirty) | 缺省全量 | 新增 |
| Align harness ★ | 新增 | 评测 | 同 ITF | 新增 |

---

## 5. 配置 / IterParam / 多轮渐进

| 键 | 缺省 | 含义 | 回归 |
|---|---|---|---|
| `thread_num` | 现状 | OpenMP | 不变 |
| `mapping_file` / `corners[]` / `output` | 现状 | Setup | 不变 |
| `report_geometry` | 现状 | SPEF 几何注释 | 不变 |
| ★ `enable_pbtv_thickness` | **false** | 解开 PBTV | 关=现状 |
| ★ `calib_coeff_file` | 空（α=1） | 标定表 | 空=现状 |
| ★ `incremental_nets` | 空 | 非空走增量 | 空=全量 |
| ★ `shield_coupling_mode` | `fold_to_ground` | 显式现状语义 | 不变默认 |
| ★ `emit_compare_json` | false | Compare 机读 | — |

多轮（评测向，非求解器 iter）：

| 轮 | PBTV | α | 增量 | 目的 |
|---|---|---|---|---|
| 0 | off | 1 | 全量 | 基线 / 零回归 |
| 1 | off | 1 | 全量 | G8 先量 |
| 2 | off | 标定后 | 全量 | G8 爬坡 |
| 3 | on | 再标定 | 全量 | 模型加深 |
| 4 | cfg | cfg | dirty | ECO |

---

## 6. Cost / 指标分解

| 维 | 符号 | 来源 | 门禁 |
|---|---|---|---|
| Total C rel err p50/p90 | C | vs StarRC | **G8** |
| Coupling C rel err p90 | CC | vs StarRC | **G8** |
| R p2p rel err | R | CompareSpef | 报告/G8 分项 |
| R²(total C) | ρ | align | G8 |
| Mismatch nets / CC | M | CompareSpef | →0 |
| iSTA CC discard | D | iSTA 读回 | NFR-RCX-05 |
| Extract wall time | T | StageLog | G21 |
| Peak mem | Mem | 报告 | 记录 |

禁止用单一「提取 PASS」掩盖 C/CC/R 分项。

---

## 7. 状态机 / 命令语义

| 命令 | API | 失败语义（目标） |
|---|---|---|
| `init_rcx -config` | `RCXAPI::init` | ITF/captab/mapping 失败响亮 |
| `run_rcx` | `run` → Extraction | topo/env/RC 失败非零 |
| `report_rcx` | `report` → SPEF | IO 失败 |
| `compare_spef` | CompareSpefTool | 缺文件；★ JSON |
| `plot_spef` / `dump_net_shape` | 工具 | IO |

★ 增量：`run_rcx -incremental netlist.txt`（或等价）仅当显式；缺省全量。

---

## 8. 跨工具 Cascade

| 信号 | 方向 | 契约 |
|---|---|---|
| 布线几何 | iRT/iDB→iRCX | DBU/层映射一致 |
| SPEF | iRCX→iSTA/iTO | FF/OHM；耦合可解析 |
| gold SPEF | StarRC→harness | 同 ITF |
| align_report | harness→`12-evaluation` | G8/G17 |
| dirty nets | iTO/ECO→iRCX | 增量 API |
| 快估轨 | iEval↔iRCX | p95 相对差有界（协议） |

---

## 9. 商业 Know-how 映射

| KH-ID | 摘要 | 本工具落点 |
|---|---|---|
| KH-RCX-01 | pattern + field-solver 标定 | §4.3；G8；先 pattern 校准，场解作抽检 |
| KH-RCX-02 | 耦合可被 STA 消费 | §4.2 + E-RCX-02 |
| KH-RCX-03 | 增量提取 | §4.5 |
| KH-X-01 | 同一真值源 | 无 G8 不关 G17 时序/功耗 |
| KH-EV-01/02 | 并排金参考 | §10 |

---

## 10. 商业对照看板 + 演进 M0–M4

### 10.1 看板（vs StarRC）

| 指标 | iRCX | StarRC | 门槛 | 门禁 |
|---|---|---|---|---|
| total C p90 相对差 | | 0 | **<5%** | **G8** |
| 耦合 C p90 | | 0 | **<10%** | **G8** |
| R²(total C) | | 1 | ≥0.98 | G8 |
| mismatch net | | 0 | →0 | G8 |
| iSTA CC discard | | — | =0 或响亮 | KH-RCX-02 |
| 提取墙钟 | | | ≤1.5× 起步 | G21 |
| G17 时序/功耗 | — | — | **禁止无 G8 宣称** | G17 |

### 10.2 对照实验

| ID | 实验 | 若失败则结论 |
|---|---|---|
| E-RCX-01 | 相关+偏移 vs 离群 | 杀/保 α 策略（H-RCX-1） |
| E-RCX-02 | iSTA 读耦合扰动 | 杀「耦合已闭环」（H-RCX-2） |
| E-RCX-03 | PBTV on vs StarRC | 杀盲目开 PBTV |
| E-RCX-04 | 增量 vs 全量 | 杀错误 dirty 扩展 |
| E-RCX-05 | 单位头 vs 数值 | G15 |

### 10.3 演进

| 里程碑 | 内容 | 退出 |
|---|---|---|
| **M0 先量** | harness 跑通；分桶 JSON | 看见 p50/p90 |
| **M1 可信** | 单位/挂点/E-RCX-02；Compare JSON | SI 链可测 |
| **M2 主算法** | 标定 α 或补模型 → **单设计 G8** | G8 起步 |
| **M3 打平** | 五套 daily **G8**；服务 G7/G17 | G8 稳 |
| **M4 纵深** | 增量；PBTV on；G21；iEval 口径 | KH-RCX-03 |

---

## 11. Exhibit

| 档 | 产物 |
|---|---|
| text | StageLog；Compare 文本 rpt |
| JSON | `align_report.json` / `compare_stats.json`（★） |
| CSV | per-net ΔC/ΔCC/ΔR；分桶汇总（★） |
| plot | PlotSpef GDS；ΔC scatter（★） |

字段：`unit`/`source`/`budget` 外生（G15）。

---

## 12. 测试计划

| 层 | 内容 | 验收 |
|---|---|---|
| L0 | Cap 累加/耦合三 token/SPEF 头单位；★ PBTV off 等价 | 绿 |
| L1 | 小设计 extract→iSTA read；Compare 自洽 | T-C1/C2 |
| L4 | vs StarRC 日常设计趋势 | 看板 |
| L5 | 无 G8 不宣称 G17；α 变更有 changelog；缺省 α=1/PBTV off | G14/G15 |

用例：T-A1 gcd vs StarRC；T-C1 名称 round-trip；T-C2/C3 耦合；T-D1 增量；T-G8 assert。

---

## 13. 里程碑（按周）

| 阶段 | 周 | 交付 | 验收 |
|---|---|---|---|
| P0 | 0–2 | `run_starrc_align.sh` + schema | M0 |
| P1 | 2–4 | 挂点/单位/E-RCX-02 | M1 |
| P2 | 4–7 | 标定或模型补丁 → 单设计 G8 | **G8** |
| P3 | 7–10 | 五套 daily G8 | M3 |
| P4 | 滚动 | 增量 API；PBTV 开关评估 | M4 |
| P5 | 与 STA | 喂 G7/G17 | 纲领 |

---

## 14. 未验证 / 负面结论

### 14.1 未验证

- 首轮 vs StarRC **真实 p90**（无 harness 前禁止填写「已接近」）。  
- iSTA 对 `*CAP` 三节点耦合的丢弃率（H-RCX-2）。  
- `MetalDensity` design/process id 混用在打开 PBTV 后的实测命中率。  
- via R 覆盖率 vs StarRC。  
- 主流程默认是否始终 `report_rcx` 接通签核路径（与 `40-platform` 联动）。  
- Quantus 是否作第二金标（本方案主金标 StarRC）。

### 14.2 不要重走

- **不要**无分桶盲调全局 α。  
- **不要**把 CompareSpef 自比对当作 G8。  
- **不要**无 G8 宣称 G17 时序/功耗打平。  
- **不要**为「文档写过 `*CC`」而强行改 SPEF 格式；先做 E-RCX-02。  
- **不要**默认打开未校准的 PBTV 厚度。  
- **不要**用场解全量替换 2.5D 作为第一优先（先校准环）。

---

## 附录 A · 术语

| 词 | 含义 |
|---|---|
| StarRC | 商业寄生提取金标 |
| ITF | 工艺互连技术文件 |
| captab | 电容查找表 |
| 2.5D pattern | 边邻接查表累加，非 3D 场解 |
| `*CAP` 三节点 | SPEF 耦合电容行（victim node, aggressor, C） |
| G8 | iRCX vs StarRC 精度门禁 |
| α 标定 | 对系统偏差的乘性校准 |

## 附录 B · 决策记录

| ID | 决策 | 被否 | 备注 |
|---|---|---|---|
| E-1 | 先 harness 再标定 | 先调 α | H-RCX-1 |
| E-2 | 同 DEF+同 ITF | 混工艺文件 | 金标纪律 |
| E-3 | 双轨（iEval 快 / iRCX 准）有界 | 混用无门禁 | 协议 |
| E-4 | 增量排 G8 后 | 先做增量 | 正确性 |
| E-5 | PBTV 缺省 off | 直接开 | 零回归 |
| E-6 | 保持 `*CAP` 耦合直至 E-RCX-02 | 盲目改 `*CC` | 兼容 |

## 附录 C · Checklist

- [ ] G8 harness 产物进 CI  
- [ ] α 变更有 changelog  
- [ ] PBTV/增量缺省关  
- [ ] 耦合消费实验有记录  
- [ ] 不宣称 G17 时序/功耗打平除非 G8 协议满足  

---

**回报摘要**：本文件目标篇幅 550–800 行；关键症结 **(1) 无 vs StarRC 门禁化标定 → G8 不可证（R1）**；**(2) PBTV/density 厚度应用注释掉、写了不生效（R2）**。
