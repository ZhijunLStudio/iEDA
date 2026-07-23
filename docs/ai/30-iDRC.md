<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 30 · iDRC 设计规则检查 · 商业对标优化方案 · rv2.1

> 文档号：30-rv2.1　　版本：rv2.1（实现评审优化）　　里程碑：**规则引擎实 → 覆盖表透明（G11）→ vs Calibre 子集精确匹配 → 增量违例回灌 iRT**
> 体例：`01-ai-doc-conventions-rv1.md`；深度对标：`24-iPL-3d-rv1.0.md`、`27-iSTA-rv2.0.md`（逐 kernel 走读 + 诚实归因 + 被否方案）
> 商业金标：**Calibre**（签核精度）；**Innovus verify**（in-design 速度）；门禁：**G7 / G11 / G12 / G14 / G15**（辅 G21）
> 上游：`26-iRT`　下游：`26-iRT`（ECO 回灌）、`12-evaluation`
> 纲领：`00-ieda-commercial-parity-master-plan-v1.1.md`；Know-how：`03-commercial-knowhow-catalog.md` KH-DRC-\*
> 联合架构：`04-ppa-technical-review-and-optimization-rv1.md` 的 `DirtySet + full oracle`；闭环工作台：`51-agent-native-eda-detailed-plan-v1.0.md`
> 覆盖：`src/operation/iDRC/`（RuleValidator.{hpp,cpp}、rv_design_rule/×26、DRCInterface.cpp、design_rule/\*.hpp）
> 纪律：**签核可信度 > 性能**；断言带 `file:line`；未实测写「未验证」；SKIP≠PASS；每条理论附能杀死它的对照。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.0 | 2026-07-20 | 有规则无覆盖表；未 vs Calibre |
| v1.1 | 2026-07-20 | 引擎摘要 |
| rv1.0 / v2.0 | 2026-07-20 | **大改**：坐实 `verifyRVModel` OpenMP（`RuleValidator.cpp:356`）；`verifyRVCluster`（`:608+`）调度 **26** 类 `ViolationType`；`DRCInterface.cpp:153` 消费 `DRCRV.verify`。核心修订：引擎**非空壳**，缺口是 **覆盖表/假 clean/Calibre 对齐/回灌**，不是「没有 DRC」。 |
| **rv2.0** | **2026-07-22** | **大改（对照 27-iSTA-rv2.0 的深度与体例重写，强化签核工具特性）**。核心修订五条：**(1)** rv1.0 把 iDRC 当成「引擎全、缺外围」来审——**代码级核实后发现头号结构症结是精度机制链条断裂**：26 规则引擎在、几何谓词成熟，但 **vs Calibre 的精度验证栈零建设**（无 harness / 无分桶归因 / 无 R² / 覆盖表只在附录未进 CI）——in-design DRC 的价值前提是「我知道我覆盖了哪些规则、跳过了哪些、与签核金标的偏差在哪个桶」，当前状态是**边界失明**（§1.5，类比 27 号文档对 PBA/SI/MCMM 缺失的判定）；**(2)** 新增 **精度栈逐项审计**（§1.5，Calibre 对标核心证据）：逐机制列出 iDRC 已有 vs Calibre 签核必需的差距清单——几何检查引擎 ✓、R-tree 索引 ✓、26 规则族 ✓；但 **rule deck 覆盖率不透明**（哪些 Calibre 规则映射到 iDRC 的哪个 `ViolationType`）、**skipped 规则不报告**（假 clean 的根源，G15 核心）、**无 vs Calibre 子集对齐 harness**（G7/G11 不可证）、**违例聚合策略未文档化**（同一 spacing 违例报 N 个点 or 1 个区域影响 diff 对齐）；**(3)** 全文按**双对标线**重组：Calibre 线 = 签核精度栈（覆盖表透明 + R² / MAE 分桶归因 + 子集一致 + 响亮失败 → G7 R²>0.98），Innovus verify 线 = in-design 速度栈（OpenMP 并行已有 + cluster 剖分 + 墙钟 ≪ Calibre → 迭代内可用），§10 拆成两块看板；**(4)** 补齐 27 号文档体例要素：§1.2 kernel 算法表（三规则伪码已有，新增复杂度/边界/复用姿势分析）、§4.13 模块状态一览、§5.2 双档配置表（签核档 vs 迭代档）、§8 调用方契约表（iRT→iDRC + iDRC→iRT ECO 回灌）、§10.3 对照实验（E-DRC-01～04 已有，补 E-CAL-\* 系列 Calibre 对齐实验）；**(5)** 签核工具特殊纪律强化：**SKIP≠PASS 红线前置**（§1.3 边界、§2.3 约束、§7 状态机、§10.1 看板、§14.2 负面）、覆盖表从「附录可选」升为 **M0 前置 + CI 强制**（§4.1）、精度看板必填 R² / MAE / 分桶归因（§10.1，对标 Calibre 子集的机械判据，非目视）。**缺省配置零回归**纪律不变；新增 harness/覆盖表 CI 开关缺省 **强制**（签核工具边界诚实 > 开发便利）。 |
| **rv2.1** | **2026-07-23** | 实现评审：Calibre 对齐从总数/R²改为规则语义归一化后的 violation precision/recall/F1 与 unmatched 集；移除未由代码证实的具体几何库断言；补 rule-aware dirty window、线程局部结果/确定性归并和 periodic full DRC oracle。 |

---

## 1. 症结审计

### 1.1 功能形态

| 项 | 证据 | 判定 |
|---|---|---|
| 入口 | `DRCInterface.cpp:79` init；`:153` `verify(...)` | 生产接线 |
| 并行 | `RuleValidator.cpp:356` `#pragma omp parallel for` | 真并行 |
| 规则调度 | `verifyRVCluster` `:608-680` 逐 `ViolationType` + `needVerifying` | 可跳过单类 |
| 实现文件 | `rv_design_rule/*.cpp` **26** 个 | **规则覆盖有代码** |
| 规则数据 | `data_manager/design_rule/*.hpp` 多类 | 参数化 |
| 覆盖表 | repo 无 PDK↔ieda 映射表 | **G11 缺口** |
| vs Calibre | 无 harness | **G11 缺口** |
| → iRT | 统一 JSON schema | **未验证** |

### 1.2 算法表

| kernel | 现状 | 判定 | 缺口 |
|---|---|---|---|
| Cluster 构建 | `buildRVClusterList` `:268+` | 工程化 | 大设计剖分 G13 |
| 几何谓词族 | spacing/enclosure/short/area/… | **in-design 成熟度中高** | 天线/密度等 missing 台账 |
| needVerifying | 按类型过滤 | 正确 | **skipped 必须进报告** |
| OpenMP 写违例 | parallel for | 待审线程安全 | §14 |

### 1.3 边界

- `needVerifying` 跳过 ≠ 规则不存在于 PDK——**若不打印 skipped → 假 clean（G15）**。  
- 检查对象是否最终 DEF/GDS 几何——**未验证**（D4）。  
- 0 违例 + skipped 非空 → **禁止**标 signoff clean（KH-DRC-01）。

### 1.4 跨工具

| 方向 | 现状 | 判定 |
|---|---|---|
| iRT → iDRC | 布线后形状 | 半通 |
| iDRC → iRT | 热点回灌 | 缺统一 schema |
| vs Calibre | 无 | G11 |
| platform C6 | 违例数一致 | 待测 |

### 1.5 ★精度栈逐项——对 Calibre 签核的差距清单（Calibre 对标核心，签核工具头号纪律）

Calibre 签核 DRC 的可信度来自一整套互相咬合的机制。逐项核实 iDRC 差距（✓=有且生产在用，⚠️=有但半残，✗=无）：

| # | Calibre 签核机制 | iDRC 现状 | 证据 | 对签核可信度的影响 | P |
|---|---|---|---|---|---|
| 1 | **26 规则族几何检查引擎** | ✓ | `verifyRVCluster` `:608-680` 逐 `ViolationType` 调度；`rv_design_rule/*.cpp` **26** 个实现文件 | 基准能力 | — |
| 2 | **R-tree 空间索引** | ✓ | spacing/enclosure 类规则查询候选（§1.5.1 伪码） | 避免 O(n²) 暴力 | ✓ |
| 3 | **整数 DBU 几何谓词与退化处理** | ⚠️ 需逐规则证实 | 当前文档不能仅凭伪码断言使用 boost.geometry/CGAL 或 medial-axis；M0 建实际 primitive 清单 | rounding、touch/overlap、notch/EOL 语义直接决定漏报/误报 | P0 |
| 4 | **rule deck 覆盖表**（foundry rule ID ↔ tool rule 映射） | ✗（附录有草案，未进 CI） | repo 无强制覆盖表；`coverage.json` 仅附录草案（§4.1） | **边界失明**：不知道 iDRC 覆盖了 PDK deck 的哪个子集 → **假 clean 的根源**（检查了 26 类、跳过了未知数量，报 0 违例不可信） | **P0** |
| 5 | **runtime checked/skipped 报告**（每次跑完显式列出哪些规则检查了、哪些跳过了） | ✗ | 当前 `verify` 返回 `Violation list`；无 `checked[]` / `skipped[]` 字段（FR-DRC-03） | **SKIP≠PASS 红线**：Innovus verify 明确标注「覆盖 85% PDK deck」；iDRC 0 违例 + skipped 非空 = PARTIAL_CLEAN（**禁止**标 signoff clean） | **P0** |
| 6 | **vs Calibre 子集对齐 harness**（语义归一化 → rule/layer 内 violation-set matching → precision/recall/F1/unmatched） | ✗ | 无 `benchmark/qor/drc/` harness；无集合匹配与归因工具（FR-DRC-04） | **G7 不可证**：无对齐 = 不知道与金标差距在哪（是几何 bug？测量定义不同？映射表错？Calibre 多报了 iDRC 未实现的规则？） | **P0** |
| 7 | **违例聚合策略文档化**（多个相邻违例点 merge 成一个区域 or 逐点报告） | ✗ | §1.5.1 三规则伪码提到「实现策略影响违例数」；生产行为**未文档化** | diff 对齐时违例数不一致的归因前提（同一 spacing 错误，Calibre 报 1 个区域、iDRC 报 5 个点 → 需明确聚合策略才能判定是「一致」还是「多报/漏报」） | P1 |
| 8 | **响亮失败**（未支持规则 → ERROR + 拒绝运行，而非静默 SKIP 当 PASS） | ⚠️ | `needVerifying` 按类型过滤（`verifyRVCluster` `:608+`）；但 skipped 不进报告 → 用户看到 0 违例以为全通过 | G14/G15 核心：静默 SKIP = 假 clean（用户以为流片 ready，实际大量规则未检查） | **P0** |
| 9 | **rule 参数正确性**（LEF/tech 文件的 spacing/width/enclosure 值正确映射到检查器） | ⚠️ 未验证 | `design_rule/*.hpp` 数据结构；`SameLayerCutSpacing` 等与 LEF 参数绑定（§14.1-4） | 参数错 → 全链失真（如 min_spacing 读成 0.14 实际 PDK 是 0.18 → 漏报真违例） | P1 |
| 10 | **OpenMP 并行写违例容器线程安全** | ⚠️ 未验证 | `RuleValidator.cpp:356` `#pragma omp parallel for`；`Violation` 容器写入（§14.1-1） | race → 违例数不稳定 or 漏报 | P1 |
| 11 | **天线/密度规则**（antenna ratio, metal density, CMP dummy fill） | ✗ | 26 规则族无 antenna/density 类；缺失完整清单（§14.1-3） | in-design 定位可缓（Calibre 签核前补）；但覆盖表必须标明 missing | P2 |
| 12 | **DRC deck 复杂规则**（conditional rules: spacing by voltage/width/parallel-run-length 多维表） | ⚠️ 部分 | `ParallelRunLengthSpacing` / `EnclosureParallel` 在；多维条件表支持**未验证** | 先进工艺 deck 复杂度；nangate45 量级可缓 | P2 |
| 13 | **vs Calibre 精度归因分桶** | ✗ | 无 harness → 无分桶（`geometry_bug` / `measure_def` / `mapping_error` / `calibre_only`，§4.2） | 对齐差异无法归因 → 不知道是代码 bug 还是边界差异 | P0 |
| 14 | **iRT ECO 回灌闭环**（DRC 违例 JSON → iRT 消费 → ECO route → 再 DRC） | ⚠️ schema 草案 | `violation_summary` JSON 草案（§4.3）；iRT `RTInterface` 消费侧**未验证** | G5 闭环前置；schema 不一致 = 需转换层 | P1 |

**§1.5 结论**：精度缺口是**结构性的三层**——(a) 机制层：覆盖表/checked/skipped 报告/响亮失败（#4/5/8，**SKIP≠PASS 红线**）；(b) 对齐层：vs Calibre violation-set matching / unmatched 分桶归因（#6/13，**G7 不可证**）；(c) 实现层：参数绑定/线程安全/天线密度缺（#9/10/11）。**签核工具头号纪律 = 边界诚实**（KH-DRC-02）：无覆盖表的 DRC clean = 假 clean。

### 1.5.1 已实现 ViolationType（代码枚举走读）

依据 `verifyRVCluster` 调用链（非完整 PDK deck）：  
AdjacentCutSpacing、CornerFillSpacing、CornerSpacing、CutEOLSpacing、CutShort、DifferentLayerCutSpacing、Enclosure、EnclosureEdge、EnclosureParallel、EndOfLineSpacing、FloatingPatch、JogToJogSpacing、MaximumWidth、MaxViaStack、MetalShort、MinHole、MinimumArea、MinimumCut、MinimumWidth、MinStep、NonsufficientMetalOverlap、NotchSpacing、OffGridOrWrongWay、OutOfDie、ParallelRunLengthSpacing、SameLayerCutSpacing（及头文件族）。  
**→ 这是 iEDA 实现集，不是 Calibre 全 deck。**

#### 1.5.2 选 3 规则几何检查伪代码（对标 24-iPL-3d §1.2 深度）

从 26 规则族中选 3 个代表性规则展开算法剖析（Spacing、Width、Enclosure），对应商业 DRC 的核心检查类别。

以下是**目标算法骨架**，不是对当前每个 `.cpp` 所用 primitive 的事实断言；M0 必须把伪码中的 `polygon_distance/widthMeasurementPrimitive/contains` 映射到真实函数、整数 DBU rounding 和聚合行为。

**Spacing 规则伪代码**（`rv_design_rule/rv_spacing.cpp` 类）：

```text
def checkSpacing(layer, min_spacing):
  shapes = getShapes(layer)                      # 获取该层全部形状
  violations = []
  
  # 1. 构建 R-tree 空间索引（O(n log n)）
  rtree = RTree()
  for shape in shapes:
    rtree.insert(shape.bbox, shape.id)
  
  # 2. 逐形状查询邻居（O(n·k)，k=平均邻居数）
  for shape_A in shapes:
    query_box = shape_A.bbox.expand(min_spacing)  # 扩展查询框
    candidates = rtree.query(query_box)
    
    for shape_B_id in candidates:
      if shape_A.id == shape_B_id:
        continue                                   # 跳过自己
      
      shape_B = getShape(shape_B_id)
      
      # 3. 精确距离计算（必须使用仓内已验证的整数 DBU primitive）
      dist = polygon_distance(shape_A.geom, shape_B.geom)
      
      if dist < min_spacing:
        violations.append({
          "type": "SPACING",
          "layer": layer,
          "value": dist,
          "bbox": union(shape_A.bbox, shape_B.bbox),
          "shapes": [shape_A.id, shape_B.id]
        })
  
  return violations
```

**复杂度**：O(n log n + k·n)，n=形状数，k=平均邻居数（稠密层 k 大，如 M1 可达 10-20；稀疏层 M5+ k 小）。

**边界 case**：
1. **Self-spacing**：单 polygon 凹角处距离<min_spacing（具体 primitive 由实际代码/规则语义冻结）；
2. **同/异 net 条件**：只能按对应 rule deck 条件表取值，禁止假设固定 0.5 倍关系；
3. **形状重叠**：polygon_distance=0（特殊违例，需区分"短路"vs"同 net 合并"）。

**Width 规则伪代码**（`rv_design_rule/rv_width.cpp` 类）：

```text
def checkWidth(layer, min_width):
  shapes = getShapes(layer)
  violations = []
  
  for shape in shapes:
    # 1. 按实际规则实现选择 edge-pair/最大内接窗口/骨架类算法；M0 代码审计后冻结
    measurements = widthMeasurementPrimitive(shape.geom)
    
    # 2. 遍历 primitive 返回的局部最小宽度见证
    for witness in measurements:
      local_width = witness.width
      
      if local_width < min_width:
        violations.append({
          "type": "WIDTH",
          "layer": layer,
          "value": local_width,
          "bbox": witness.bbox,
          "location": witness.location
        })
  
  return violations
```

**复杂度**：O(Σ T_width(shape))；在真实 primitive 审计前不虚报 `m log m`。

**边界 case**：
1. **非凸 polygon**：所有局部窄颈必须产生见证，不能只看 bbox 或单一主轴；
2. **薄长条形状**：整条都<min_width，报多个违例 or 合并成一个区域违例（实现策略影响违例数统计）；
3. **退化形状**：面积极小的"针刺"形状（可能是布线器bug），宽度→0。

**Enclosure 规则伪代码**（`rv_design_rule/rv_enclosure.cpp` 类）：

```text
def checkEnclosure(layer_pair, min_enclosure):
  # layer_pair = (M1, VIA12)：via 的下层金属必须包住 via cut
  lower_shapes = getShapes(layer_pair.lower)     # 如 M1 金属
  vias = getVias(layer_pair)                     # VIA12 的 cut 形状
  violations = []
  
  # 1. 构建下层金属 R-tree
  rtree_lower = RTree()
  for metal in lower_shapes:
    rtree_lower.insert(metal.bbox, metal.id)
  
  # 2. 逐 via 检查包围（O(v·k)，v=via 数，k=候选金属数）
  for via in vias:
    # 查询可能包住 via 的金属（扩展查询框避免漏检）
    query_box = via.cut_bbox.expand(min_enclosure)
    candidates = rtree_lower.query(query_box)
    
    enclosing_metal = None
    for metal_id in candidates:
      metal = getShape(metal_id)
      if polygon_contains(metal.geom, via.cut_geom):  # 完全包住
        enclosing_metal = metal
        break
    
    if enclosing_metal is None:
      # via 未被任何金属包住
      violations.append({
        "type": "ENCLOSURE",
        "layer": layer_pair,
        "bbox": via.cut_bbox,
        "reason": "via not enclosed"
      })
    else:
      # 检查包围距离（边到边最小距离）
      enc_dist = min_distance_boundary_to_boundary(
        via.cut_geom.boundary, enclosing_metal.geom.boundary
      )
      
      if enc_dist < min_enclosure:
        violations.append({
          "type": "ENCLOSURE",
          "layer": layer_pair,
          "value": enc_dist,
          "bbox": via.cut_bbox,
          "metal_id": enclosing_metal.id
        })
  
  return violations
```

**复杂度**：O(v·k)，v=via 数（可达数万），k=候选金属数（平均 2-5）。

**边界 case**：
1. **多金属重叠**：via 被多个金属 polygon 同时包住 → 选最近的一个计算 enc_dist（或报告全部候选）；
2. **部分包围**：via cut 一半在金属内、一半悬空 → polygon_contains=false，直接报"未包围"；
3. **方向性 enclosure**：PDK 可能要求水平/垂直方向不同 enc 值（如 enc_x=0.05, enc_y=0.08）→ 需分方向计算。

**三规则的共同特征**（商业 DRC 核心模式）：
- **R-tree 空间索引**：避免 O(n²) 暴力配对；
- **几何 primitive 版本化**：距离/包含/宽度测量必须指向仓内真实实现和 rounding 语义；未经代码证实不得写成 boost.geometry/CGAL；
- **违例聚合策略**：多个相邻违例 or 合并成一个区域（实现影响违例数，需文档化）。

---

## 2. 需求 FR / NFR

| ID | 需求 | 现状 | P |
|---|---|---|---|
| FR-DRC-01 | 保持 26 规则引擎 | ✓ | — |
| FR-DRC-02 | ★ PDK 覆盖表进 repo | ✗ | P0 |
| FR-DRC-03 | ★ 运行时 `checked[]/skipped[]` | ✗ | P0 |
| FR-DRC-04 | ★ vs Calibre 子集 harness | ✗ | P0 |
| FR-DRC-05 | ★ 违例 JSON ≡ iRT schema | ❓ | P1 |
| FR-DRC-06 | ★ route→drc→routeECO 闭环 | ✗ | P1 |
| FR-DRC-07 | 台账驱动补规则 | — | P2 |
| FR-DRC-08 | ★ rule-aware incremental DRC + periodic full oracle | 无正式契约 | P1 |
| NFR-DRC-01 | SKIP≠PASS | G11/G15 | |
| NFR-DRC-02 | in-design 墙钟 ≪ Calibre | 记录 | G21 |
| NFR-DRC-03 | 可比子集匹配 | per-rule precision/recall/F1、unmatched bbox、测量值误差；关键 short/spacing 类 false-negative=0 | G11 |

红线：不追求 100% deck；追求**边界诚实**（KH-DRC-02）。

---

## 3. HLD

```text
iDB/DEF/GDS 形状
  → DRCInterface
  → RuleValidator.verify
       build clusters → OpenMP verifyRVCluster
       → Violation list
  → ★ coverage attach (checked/skipped)
  → ★ JSON(layer, type, bbox) → report / iRT ECO
签核真值：Calibre（可比子集对齐）
```

决策（含被否理由详细列，对标 24-iPL-3d §3 深度）：

| # | 决策 | 被否方案 | 被否理由（工程/门禁） |
|---|---|---|---|
| D1 | **覆盖表 P0（边界诚实先于盲追 Calibre）** | 先追 Calibre 全绿再记覆盖 | **KH-DRC-02 核心**：无覆盖表的 DRC clean = 假 clean（不知道跳过了哪些规则）。对照：商业 in-design DRC（Innovus verify）**明确标注**检查/跳过规则比例（如"覆盖 85% PDK deck"）。**被否原因**：追 Calibre 100% deck = 工作量数量级差（Calibre 规则数千条，iEDA 26条）；边界诚实（checked/skipped 列表）= G11/G15 可判定基础（SKIP≠PASS）。 |
| D2 | **定位 in-design DRC（非 signoff）** | 宣称替代 Calibre 签核 | **范围诚实**：iEDA DRC 对标 Innovus verify（优化循环内快速检查），非 Calibre（流片前签核）。对照：商业 PnR 内置 DRC 覆盖"大头规则"（spacing/width/enclosure），复杂规则（density/antenna/stress）留给 Calibre。**被否原因**：宣称替代 Calibre = 过度承诺（26 规则 vs 数千条），违反主纲领"诚实定界"；in-design 定位 = 有用且可达标。 |
| D3 | **与 iRT 共 schema（违例 JSON 统一）** | 各工具各写各的违例格式 | **闭环前提**：route→drc→routeECO 需要违例 JSON 格式一致（iDRC 产出 = iRT 输入）。对照：商业工具（Innovus）的 DRC 违例可**直接喂给 ECO route**（`ecoRoute -fix_drc`）。**被否原因**：各写各的 = 需要格式转换层（易出 bug）；统一 schema = 零转换成本（FR-DRC-05 与 26-iRT FR-RT-06 同步设计）。 |

**决策的共同模式**：
- **边界诚实 > 能力虚报**（D1/D2）：覆盖表+in-design 定位 = 实事求是；
- **闭环设计**（D3）：DRC 产出格式必须考虑 iRT 消费侧（跨工具契约）。

---

## 4. LLD（压缩）

### 4.1 覆盖表 `[新增]`

```json
{
  "pdk": "sky130",
  "rules": [
    {"foundry_id": "METAL1.SPACING", "ieda": "ParallelRunLengthSpacing",
     "state": "implemented|partial|missing", "note": ""}
  ]
}
```

每次 `run_drc` 附带 runtime 集合；CI 检查表存在（G11 起步）。

### 4.2 Calibre 对齐算法 `[新增]`

```text
S = implemented ∩ mapped_calibre_rules，冻结 rule deck/version/DBU/层映射
双方输出先归一化：foundry rule id、layer pair、整数 DBU、measurement semantic、polygon/bbox
同一 (rule_id, layer/layer_pair) 内构建候选边：bbox overlap/距离在该规则容差内
做最大权重二分匹配，权重按 overlap、位置距离、测量值误差；禁止只比较总数或精确 bbox hash
matched → 统计 measurement error；unmatched_iEDA=FP，unmatched_Calibre=FN
按 rule/layer 报 precision/recall/F1 和 unmatched 几何；关键规则 FN 必须为 0
桶: geometry_bug | rounding | aggregation | measure_def | mapping_error | calibre_only
```

`R²` 只适合连续测量值的辅助相关性，不适合作为离散违例集合的主门禁；两个工具即使总数相同也可能位置完全不同。

### 4.3 回灌 `[新增]`

`iDRC JSON == 26-iRT violation_summary`；platform：`route → drc → if vios: routeECO(hot) → drc`。

增量检查接收 `DirtySet{layers,bboxes,shapes,nets}`：每条 rule 根据最大作用距离、EOL/PRL 邻域、layer-pair enclosure 扩不同 halo；只失效相交 cluster 与缓存结果。多个 cluster 由线程局部 violation vector 计算，结束后按 `(rule_id,layer,bbox,shape_ids)` 排序、去重、确定性归并，禁止 OpenMP 线程直接写共享容器。每 K 次增量检查或 dirty area 比例超阈值运行 full DRC oracle；对增量/full violation set 做同一匹配，任何 FN 立即清缓存并降级 full。

### 4.4 模块状态

| 模块 | 状态 | 动作 |
|---|---|---|
| RuleValidator | 成熟 | 保；审线程安全 |
| rv_design_rule×26 | 成熟 | 台账补缺 |
| coverage | 无 | ★ |
| Calibre harness | 无 | ★ |
| iRT JSON | 未验证 | ★ |

---

## 5. 配置

| 键 | 默认 | 说明 |
|---|---|---|
| `drc.check_types` | all implemented | |
| `drc.coverage_table` | path | 必填进 CI |
| `drc.fail_on_skipped_as_clean` | true | G15 |
| `drc.omp_threads` | env | |
| `drc.incremental` | false | 校准通过后开启；缺省 full 保正确性 |
| `drc.full_oracle_interval` | 1 | K 次增量一次 full；1 为最保守 |
| `drc.deterministic_merge` | true | 线程局部结果排序归并 |

---

## 6. 指标分解

| 维 | 含义 |
|---|---|
| vio_total | 总违例 |
| vio_by_type/layer | 分桶 |
| skipped_rules | **独立列** |
| wall_s | in-design |
| vs_calibre_precision/recall/F1 | 可比子集集合匹配；逐 rule/layer |
| vs_calibre_unmatched | FP/FN 的 bbox、测量值和归因桶 |

---

## 7. 状态机

```text
init → load_shapes → verify → attach_coverage → emit_json → (optional) feed_irt
0 vio + skipped≠∅ → 状态 = PARTIAL_CLEAN（非 SIGN_OFF_CLEAN）
```

---

## 8. Cascade

| 边 | 信号 |
|---|---|
| iRT → iDRC | wires/vias |
| iDRC → iRT | hot bbox |
| iDRC → eval | drc_total + skipped |
| Calibre ↔ iDRC | 子集对齐 |

---

## 9. Know-how

| KH | 落点 |
|---|---|
| KH-DRC-01 | §4.1/§7 覆盖透明 |
| KH-DRC-02 | §3 in-design vs signoff |
| KH-X-04 | 假 clean 禁止 |

---

## 10. 看板 + M0–M4

| 指标 | iDRC | Calibre | 门槛 | G |
|---|---|---|---|---|
| 可比子集违例 | | | 一致或逐条解释 | G11 |
| skipped 数 | | — | 显式 | G15 |
| 假 clean | 禁 | — | 0 | G15 |
| 墙钟 | | | ≪ signoff | G21 |

对照：注入短路必报；覆盖表 CI；Calibre diff 台账；skipped 非空不得 PASS signoff。

### 10.2 对照实验（可执行设计，对标 24-iPL-3d §10.2 深度）

| ID | 输入 | 命令/操作 | 判据（数值阈值） | 杀死假说/锁住契约 |
|---|---|---|---|---|
| **E-DRC-01** | 注入 spacing 违例（手工缩小间距到 0.9×min） | `sed 's/RECT 100 200 150 300/RECT 100 200 151 300/' gcd.def; run_drc` | 必检出且 **type=SPACING**；违例数 ≥1 | 假 clean（G15） |
| **E-DRC-02** | 干净设计（golden DEF） | `run_drc -report drc.json` | **0 违例且 skipped[] 非空**（证明有检查有跳过）；报告标注"PARTIAL_CLEAN" | SKIP≠PASS（G11/G15） |
| **E-DRC-03** | 同 DEF vs Calibre 可比子集（仅已映射规则） | 双方 DRC → normalize → bipartite match | 逐 rule/layer precision/recall/F1；关键 short/spacing FN=0，所有 unmatched 逐条归因；禁止用总数相等替代集合一致 | Calibre 子集对齐（G11） |
| **E-DRC-04** | 覆盖表 CI 注入（人为删 coverage.json） | `run_drc` | **启动拒绝或 ERROR**："missing coverage.json" | 覆盖表强制（FR-DRC-02） |
| **E-DRC-05** | 随机局部移动/加线/via，固定 seed | incremental DRC vs 每步 full DRC | 匹配后 FN=0、FP 在归并容差内；任一漏报则缓存/halo 策略失败并降级 full | FR-DRC-08 |

**实验设计原则**：
1. **注入可控**：手工修改 DEF 坐标 = 制造违例（controlled experiment）；
2. **判据机械**：违例数≥1、skipped 非空、集合匹配 precision/recall/F1 与 unmatched 逐条归因（非目视）；
3. **锁住边界**：E-DRC-02 的"skipped 非空"= in-design 定位的验证（不许宣称 100% PDK）。

**E-DRC-01 详细执行步骤**（示例）：
```bash
# 注入 spacing 违例（手工缩小 M1 两形状间距）
cp gcd.def gcd_inject.def
sed -i 's/RECT 1000 2000 1500 3000/RECT 1000 2000 1580 3000/' gcd_inject.def  
# ← 两矩形原间距 20um，改成 18um（假设 min_spacing=20um）

# iDRC 命令
ieda> read_def gcd_inject.def
ieda> run_drc -pdk sky130 -report drc_result.json

# 判据校验
jq '.violations | length' drc_result.json        # 必须 >0
jq '.violations[0].type' drc_result.json         # 必须 ="SPACING"
jq '.violations[0].layer' drc_result.json        # 必须 ="M1"
jq '.violations[0].value' drc_result.json        # 必须 <20（实测间距）
```

**E-DRC-03 详细执行步骤**（Calibre 对齐）：
```bash
# iDRC 跑
ieda> run_drc -pdk sky130 -report idrc.json

# Calibre 跑（仅子集：spacing/width/enclosure）
calibre -drc -turbo -hier gcd.calibre_deck    # deck 仅开 3 规则族

# 归一化并做 rule/layer 内集合匹配；总数相同也必须执行
normalize_calibre_drc calibre.rpt -o calibre.json
align_drc_sets idrc.json calibre.json --coverage coverage.json -o align.json
jq '.by_rule[] | {rule,precision,recall,f1,fp,fn}' align.json
# 关键 short/spacing 的 fn 必须为 0；其余 unmatched 必须带归因桶
```

### 10.3 演进

```text
M0 覆盖表生成+进 repo
M1 运行时 checked/skipped
M2 Calibre 子集对齐
M3 回灌 iRT（G5 闭环）
M4 按台账补规则 + 大规模并行
```

---

## 11. Exhibit

`drc_summary.json`、`drc_violations.csv`、`coverage_runtime.json`、可选 bbox plot。

---

## 12. 测试

| 层 | 用例 |
|---|---|
| L0 | MetalShort 注入必报 |
| L0 | skipped 字段存在 |
| L1 | 小设计全规则跑通 |
| L4 | Calibre 子集 diff |
| L5 | PARTIAL_CLEAN 不得当 G11 PASS |

---

## 13. 里程碑

W0 表；W1 runtime 诚实；W2 harness；W3 回灌；持续补规则。

---

## 14. 未验证

| # | 项 |
|---|---|
| 1 | OpenMP 写 Violation 容器线程安全 |
| 2 | 最终态数据源（DEF vs 内部 shape） |
| 3 | 天线/密度规则缺失完整清单 |
| 4 | SameLayerCutSpacing 等与 LEF 参数绑定正确性 |

**不要重走**：无覆盖表前宣称「DRC clean=可流片」。

---

## 附录 B

| # | 决策 | 被否 |
|---|---|---|
| E-1 | 覆盖表先于对照 | 盲对齐 |
| E-2 | in-design 定位 | 替代 Calibre |
| E-3 | 统一违例 JSON | 双 schema |


---

## 附 · 规则文件清单（rv_design_rule/）

AdjacentCutSpacing、CornerFillSpacing、CornerSpacing、CutEOLSpacing、CutShort、DifferentLayerCutSpacing、Enclosure、EnclosureEdge、EnclosureParallel、EndOfLineSpacing、FloatingPatch、JogToJogSpacing、MaximumWidth、MaxViaStack、MetalShort、MinHole、MinimumArea、MinimumCut、MinimumWidth、MinStep、NonsufficientMetalOverlap、NotchSpacing、OffGridOrWrongWay、OutOfDie、ParallelRunLengthSpacing、SameLayerCutSpacing（计 26）。

调度入口：`RuleValidator.cpp:608+` `verifyRVCluster`；并行：`:356` OpenMP；接口：`DRCInterface.cpp:153`。

### 覆盖表生成流程（M0）

```text
1. 枚举 ViolationType / rv_design_rule 文件名 → ieda_rules[]
2. 读 PDK rule deck（人工/脚本）→ foundry_rules[]
3. 映射表 YAML/JSON 进 repo；未映射 = missing
4. CI: 表存在 ∧ run_drc 输出 skipped ⊆ 表
```

### 与 Calibre 差异归因模板

| 桶 | 含义 | 动作 |
|---|---|---|
| geometry_bug | iEDA 几何谓词错 | 修规则代码 |
| measure_def | 测量定义不同（EOL 等） | 文档+可选对齐 |
| mapping_error | 覆盖表映错 | 改表 |
| calibre_only | 未实现 | missing 台账 |

### 违例 JSON schema（与 26 对齐草案）

```json
{
  "violations": [
    {"type": "MetalShort", "layer": "M1", "bbox": [x0,y0,x1,y1], "net": "..."}
  ],
  "checked": ["MetalShort", "..."],
  "skipped": ["Antenna", "..."],
  "status": "clean|partial_clean|dirty"
}
```

`status=partial_clean` **不得**映射为门禁 PASS。

### PR 切片

| PR | 内容 | 验收 |
|---|---|---|
| DRC-0 | 覆盖表+生成脚本 | G11 起步 |
| DRC-1 | runtime checked/skipped | G15 |
| DRC-2 | Calibre harness | 台账 |
| DRC-3 | JSON= iRT schema | 共读 |
| DRC-4 | 回灌编排 | G5 |


### in-design vs signoff 使用策略（KH-DRC-02）

| 场景 | 工具 | 期望 |
|---|---|---|
| 迭代中快速查 short/spacing | iDRC | 秒～分钟级；允许 skipped |
| 流片前签核 | Calibre | 全 deck；iDRC 子集须可解释 |
| CI 日常 | iDRC + 覆盖表 | partial_clean 显式 |

迭代期可用 iDRC 指导 routeECO；**不得**用 iDRC clean 替代 Calibre signoff 声明。

### 线程安全审阅清单（未验证→M1 任务）

1. `Violation` 容器在 OpenMP 循环中是否有临界区；  
2. `needVerifying` 只读共享规则参数是否 const；  
3. cluster 缓存销毁时机（`RuleValidator.cpp:427` 注释）是否 race。

### 假 clean 防御测试用例

| 用例 | 期望 status |
|---|---|
| 全规则跑、0 vio、skipped 空 | clean |
| 0 vio、skipped 非空 | partial_clean |
| 有 MetalShort | dirty |
| 覆盖表缺失 | 启动 FAIL（CI） |
