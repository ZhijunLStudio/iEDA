<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 11 · solver 数值内核 · 商业对标方案 · rv2.0

> 文档号：11-rv2.0　　版本：rv2.0（大改）　　里程碑：**双对标 —— Cadence 分区/合法化精度（Abacus 位移 < 1.2× 金标）× 多工具复用（≥2 消费方）**
> 体例：`01-ai-doc-conventions-rv1.md`；深度对标：`24-iPL-3d-rv1.0.md`、`27-iSTA-rv2.0.md`（逐 kernel 走读 + 双对标线 + 诚实归因）
> 商业金标：**Cadence QPlace**（合法化精度）；**hMETIS**（分区质量）；**CGAL**（几何精度）；门禁：**G2 / G3 / G14**（辅 G21）
> 上游：无（基础设施）　下游：`22-iPL`、`20-iECO`、`26-iRT`、`23-iCTS`（潜在消费方）
> 纲领：`00-ieda-commercial-parity-master-plan-v1.1.md`（支撑 G2/G3/G14）；Know-how：`03-commercial-knowhow-catalog.md` KH-X-04、KH-PL-01
> 覆盖：`src/solver/` 全 7 子目录（总计 2469 LOC，其中 **2036 LOC 集中在 legalization+geometry 两个目录**）；消费方 iPL/iECO
> 纪律：**文档是假说不是事实**；断言带 `file:line`；未实测写「未验证」；每条理论附能杀死它的对照。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.1 | 2026-07-20 | 极简要求 |
| rv1.0 / v2.0 | 2026-07-20 | 审计：legalization 含 Abacus；QP "目录在但接线未证" |
| rv1.1 / v3.0 | 2026-07-21 | 大改：对 `src/solver/` 全 7 子目录逐文件读完后重写；坐实 5/7 目录是 0 字节 TBD 占位符；真实内核散落在工具内部；存量只有 Abacus（1137 LOC，iPL 真在用）与 geometry（boost 后端，全仓仅 iECO 一个消费方）；third_party 数值库（highs/lemon/hmetis/metis/flute3）由各工具 `external_libs/*.cmake` 各自直接引用，**src/solver 一个都没链接**。 |
| **rv2.0** | **2026-07-22** | **大改（对照 27-iSTA-rv2.0.md / 28-iRCX-rv2.0.md 深度与体例重写，强化 Tier 3 基础设施特性与商业对标）**。核心修订五条：**(1)** rv1.1 把 solver 当成"处置空壳目录"来审——**代码级核实后发现头号定位症结是 Tier 3 基础设施的精度栈与复用姿势缺失**：Abacus 合法化（1137 LOC）虽成熟但**无 vs Cadence QPlace 精度对拍**（合法化位移、重叠数、确定性未验证）；geometry 单消费者（iECO）但**无几何精度门禁**（boost.polygon 距离/包含计算与 CGAL 金标的一致性未验证）；**复用姿势不透明**（哪些内核该进 solver、哪些留工具内，无文档化收编纪律 → TBD 空壳再生风险）；**(2)** 新增 **§1.5 精度栈逐项**（对商业 solver 能力的差距清单，Tier 3 基础设施核心证据）：逐机制列出 Abacus vs QPlace（合法化精度）、geometry vs CGAL（几何谓词精度）、partition vs hMETIS（分区质量）——几何检查引擎 ✓、Abacus 算法 ✓，但 **vs 商业精度验证栈零建设**（无 harness / 无分桶归因 / 无确定性验证 / 无复用姿势门禁）；**(3)** 全文按**双对标线**重组：商业精度线 = Abacus vs QPlace 位移/重叠/确定性 + geometry vs CGAL 谓词精度（G2/G3 主杠杆），复用姿势线 = 多工具消费（≥2 消费方准入 + 收编纪律文档化 + 工具内平行重写禁止），§10 拆成两块看板；**(4)** 补齐 27 号文档体例要素：§1.2 算法表重写（Abacus 伪码 + 复杂度/边界/复用姿势）、§4.5 模块状态一览对齐格式（成熟度/主复杂度/关键边界/复用姿势四列）、§5.2 双档配置表（Abacus 卫士档 × 快速档）、§10.2 对照实验详细（E-SOL-01～05 已有，补 E-QPLACE-\* / E-CGAL-\* 商业对拍实验）、§10.3 演进 M0-M4 带退出门禁；**(5)** Tier 3 基础设施特殊纪律强化：**复用姿势 = 核心价值**（§1.3 边界、§2.3 约束、§3.2 D1 决策、§4.1 收编纪律、§10.1 看板），≥2 消费方准入门槛从「建议」升为 **强制**（NFR-SOL-03，防空壳再生），精度看板必填 vs 商业金标的对拍数据（§10.1，Abacus 位移 / geometry 距离误差）。**缺省配置零回归**纪律不变；新增收编纪律 README 强制（Tier 3 边界诚实 > 代码数量）。 |

---

## 1. 症结审计（逐目录 / 逐 kernel 代码走读）

### 1.1 目录真相表（`find src/solver -type f` 全量）

| 目录 | 文件实况 | LOC | 判定 |
|---|---|---|---|
| `legalization/` | `Abacus.cc` 1137 + `Abacus.hh` 109 + `AbacusCluster.{cc,hh}` 144+135 + `LGCustomization.{cc,hh}` 61+52 + `LGMethodInterface.hh` 50 + `LGMethodCreator.{cc,hh}` 43+44 | 1775 | **唯一生产级模块**（§1.2） |
| `geometry/` | `engine_geometry.h`（抽象基类，`:31`）+ `engine_geometry_creator` 43+41 + `geometry_boost` 241+78 + point/rect/polygon/polygon_set 四个 POD | 694 | 有实现，**消费方=1**（§1.3） |
| `qudratic_programming/` | **仅 `TBD`，0 字节** | 0 | **空目录** |
| `partition/` | **仅 `TBD`，0 字节** | 0 | **空目录** |
| `clustering/` | **仅 `TBD`，0 字节** | 0 | **空目录** |
| `steiner_forest/` | **仅 `TBD`，0 字节** | 0 | **空目录** |
| `two_pin_routing/` | **仅 `TBD`，0 字节** | 0 | **空目录** |

**5/7 目录是占位符。** 这不是"接线缺口"，是**从 2026-07-06 起就从未存在过实现**（TBD 文件时间戳）。v2.0 围绕 QP/SA 写的 FR-SOL-01/03 全部悬空。

**§1.1 结论**：solver 现状 = **2 个活模块（Abacus 1775 LOC + geometry 694 LOC）+ 5 个空壳目录**。真实数值内核散落在各工具内部（iPL NesterovPlace/initial_placer/SteinerWirelength、iTO flute3、iSTA 时序图、iIR Eigen），src/solver 在链接层面只被 iPL（Abacus）和 iECO（geometry）两处消费——**基础设施库的复用价值未实现**（§1.5-#4）。

### 1.2 算法成熟度——逐 kernel 走读（Abacus 合法化在、几何谓词在，精度未验证）

| kernel | 现状算法 | 判定 | 缺口 |
|---|---|---|---|
| `Abacus`（`Abacus.cc:1137` LOC，教科书 Abacus） | 标准 Abacus 单行合法化（placeRow/cluster/collapse 一族）；按 x 坐标排序 → 逐 cluster 塌缩到合法位置；支持 site 对齐 | **工业向合法化引擎**；iPL 唯一消费方（`Legalizer.cc:32`） | 无 vs Cadence QPlace 精度对拍（位移/重叠数）；确定性未验证（排序依赖指针序与否）；NaN/Inf 卫士无 |
| `LGMethodCreator`（工厂，43 LOC） | `createMethod(kAbacus/kCustomized)` 分派；default 分支**静默返回 nullptr**（`:37-39`） | 工厂模式正确 | 静默 nullptr → 调用方不查空即崩（G14） |
| `geometry_boost`（241 LOC，Boost.Polygon 封装） | `addRect`/`addPolygon`/`booleanOp`（AND/OR/XOR）/`getEdge`；boost::polygon 后端 | **几何谓词成熟**；iECO 唯一消费方 | 无 vs CGAL 精度对拍（距离/包含计算）；单消费者 = 未充分证明复用价值 |
| **Partition**（空，0 字节 TBD） | 不存在 | **缺** | iPL `NesterovPlace` 的 net cut 最小化是工具内自写；hMETIS/metis 在 third_party 但不经 solver |
| **QP**（空，0 字节 TBD） | 不存在 | **缺** | iPL `NesterovPlace` 的二次规划初值是工具内自写；highs 在 third_party 但不经 solver |
| **Steiner**（空，0 字节 TBD） | 不存在 | **缺** | iPL `SteinerWirelength` 直接引 flute3（`ipl_source_external_libs.cmake`），不经 solver |
| **Clustering**（空，0 字节 TBD） | 不存在 | **缺** | iPL/iCTS 各自实现 clustering，无公共出口 |
| **Two-pin routing**（空，0 字节 TBD） | 不存在 | **缺** | iRT 布线不经 solver |

**Abacus 算法伪码**（对标 30-iDRC §1.5.1 三规则伪码深度）：

```text
def Abacus.legalize(cells, rows):
  # 1. 按 x 坐标排序 cell（O(n log n)）
  sorted_cells = sortByX(cells)                   # ← 确定性风险：若用 std::sort + 指针比较 → 地址序依赖
  
  # 2. 构建 cluster（O(n)）
  clusters = []
  for cell in sorted_cells:
    # 找到该 cell 应放置的行
    target_row = findBestRow(cell, rows)         # 最小化 y 方向位移
    
    # 查找该行现有 cluster（按 x 区间重叠）
    overlapping_cluster = findOverlappingCluster(cell.x, target_row, clusters)
    
    if overlapping_cluster:
      overlapping_cluster.addCell(cell)          # 合并入现有 cluster
    else:
      clusters.append(Cluster(cell, target_row))  # 新建 cluster
  
  # 3. 逐 cluster 塌缩到合法位置（O(k·m)，k=cluster 数，m=cluster 平均 cell 数）
  for cluster in clusters:
    # 计算 cluster 质心（期望位置）
    centroid_x = sum(cell.x for cell in cluster.cells) / len(cluster.cells)
    
    # 从质心开始，向左右扫描可用空位（site-aligned）
    legal_x = findLegalSite(centroid_x, cluster.row, cluster.totalWidth)
    
    # 按 x 序逐 cell 放置（最小化总位移²）
    current_x = legal_x
    for cell in cluster.cells:
      cell.legalX = current_x
      cell.legalY = cluster.row.y
      current_x += cell.width
    
    # 检查边界（cluster 超出行宽 → 失败）
    if current_x > cluster.row.right:
      return SolverResult{ok=false, msg="cluster exceeds row width"}
  
  # 4. 全局重叠检查（O(n log n)）
  if hasOverlap(all_cells):
    return SolverResult{ok=false, msg="overlap after legalization"}
  
  return SolverResult{ok=true, iters=1, residual=computeTotalDisplacement²}
```

**复杂度**：O(n log n + k·m)，n=cell 数，k=cluster 数（≈行数），m=平均 cluster cell 数（密集布局可达 50-100）。

**边界 case**：
1. **超宽 cell**：cell.width > row.width → 放不下，必须失败上抛（现状：卫士无，§4.2）；
2. **空输入**：cells=[] → 应返回 ok=true（trivial success），现状未验证；
3. **NaN 坐标**：cell.x=NaN → 排序 UB，现状无卫士（§4.2 FR-SOL-02）；
4. **确定性**：排序若依赖指针/容器序（如 `std::sort` 默认 `<` 比较指针）→ 同输入不同内存布局产生不同输出（ASLR 场景，G2 风险）。

**几何谓词伪码**（`geometry_boost` 核心操作）：

```text
def EngineGeometryBoost.booleanOp(poly_A, poly_B, op):
  # boost::polygon 后端（O(m+n)，m/n=顶点数）
  result = boost::polygon::operators::{AND, OR, XOR}(poly_A, poly_B)
  return result

def distance(poly_A, poly_B):
  # 多边形间距离（O((m+n) log(m+n))）
  return boost::polygon::euclidean_distance(poly_A, poly_B)

def contains(poly_outer, poly_inner):
  # 包含判定（O(m)）
  return boost::polygon::contains(poly_outer, poly_inner)
```

**复杂度**：距离计算 O((m+n) log(m+n))；布尔运算 O(m+n)；包含判定 O(m)。

**边界 case**：
1. **退化多边形**：面积为 0（线段/点）→ boost::polygon 行为**未验证**（可能返回 NaN/Inf）；
2. **非简单多边形**：自相交 → boost 可能产生非预期结果（CGAL 会拒绝）；
3. **精度**：boost::polygon 用整数坐标（固定点）vs CGAL 用有理数（精确计算）→ 距离计算误差**未量化**（E-CGAL-01）。

**假说 H-SOL-1（可杀）**：Abacus 确定性失败主因是排序依赖指针地址序。  
**杀死实验 E-SOL-02**：同输入 Abacus 双跑（ASLR on）；若输出不同 → 坐实不确定性；若相同 → 杀 H-SOL-1，改查容器迭代序或并行 reduction。

**假说 H-SOL-2（可杀）**：geometry_boost 距离计算与 CGAL 金标误差 < 1%（整数精度足够）。  
**杀死实验 E-CGAL-01**：合成 100 对随机多边形 → boost vs CGAL 距离 → 若 p95|Δ|/真值 > 1% → 杀 H-SOL-2，整数后端精度不足。

### 1.3 geometry——有实现、单消费者的"半死代码"

- `EngineGeometry`（`engine_geometry.h:31-`）是抽象基类（`addRect` 纯虚），唯一后端 `geometry_boost`（241 LOC，Boost.Polygon 封装），creator 工厂。
- **全仓消费方 grep**：`src/operation` 内仅 `iECO/source/data/ieco_data_via.h` 一处 include。
- **判定**：实现存在且合理，但单消费者意味着它实际是 **iECO 的私有工具类被放进了公共目录**——要么提升为真公共几何库（iRT/iDRC 候选消费方），要么降级回 iECO（§3 D2 决策）。
- **精度缺口**：boost::polygon（整数坐标）vs CGAL（有理数精确计算）的距离/包含谓词误差**未量化**（§1.5-#2）。

### 1.4 数值内核的真实分布（审计外圈：内核不在 solver 里）

rv1.1 未审的一层：**生产数值内核全部住在工具内部**，`src/solver` 只是一个未能长成的"愿望目录"：

| 真实内核 | 位置 | 本应归属 |
|---|---|---|
| ePlace Nesterov GP（含 QP 初值概念） | `iPL/.../electrostatic_placer/NesterovPlace.cc`（提 Quadratic） | solver/qudratic_programming（空） |
| 初值布局 | `iPL/source/module/initial_placer/` | solver（空） |
| Steiner 线长 | `iPL/.../evaluator/wirelength/SteinerWirelength.{hh,cc}`（flute3） | solver/steiner_forest（空） |
| flute3 链接 | `iPL/external_libs/ipl_source_external_libs.cmake`、iTO 同款 | 无统一出口 |
| 详细布局 5 算子 | `iPL/source/module/detail_placer/` | solver（空） |
| hmetis/metis/highs/lemon | `src/third_party/` | src/solver **零链接** |

**§1.4 结论**：solver 定位混乱——既不是"数值内核统一出口"（真实内核在工具内各自为政），也不是"第三方封装层"（third_party 库由各工具直接引用）。**复用价值未实现**（§1.5-#4），当前 = 两个孤岛模块的存放地。

### 1.5 ★精度栈逐项——对商业 solver 能力的差距清单（Tier 3 基础设施核心证据）

商业 EDA 的数值内核（Cadence QPlace 合法化、hMETIS 分区、CGAL 几何）准确性来自一整套互相咬合的机制。逐项核实 iEDA solver 差距（✓=有且生产在用，⚠️=有但半残，✗=无）：

| # | 商业 solver 机制 | iEDA solver 现状 | 证据 | 对基础设施可信度的影响 | P |
|---|---|---|---|---|---|
| 1 | **Abacus 合法化引擎** | ✓ | `Abacus.cc:1137` 标准 Abacus；iPL `Legalizer.cc:32` 消费 | 基准能力 | — |
| 2 | **几何谓词引擎**（距离/包含/布尔运算） | ✓ | `geometry_boost` 241 LOC；boost::polygon 后端 | 基准能力 | — |
| 3 | **vs Cadence QPlace 精度对拍**（合法化位移/重叠数） | ✗ | 无 harness；无 `benchmark/qor/solver/abacus_vs_qplace/` | **边界失明**：不知道 Abacus 与金标的位移差距（是 1.1× 还是 2×？）→ iPL 合法化质量不可信 | **P0** |
| 4 | **复用姿势门禁**（≥2 消费方准入 + 收编纪律文档化） | ✗ | Abacus/geometry 各 1 消费方；无 `src/solver/README.md` 收编纪律；TBD 空壳 5/7 | **复用价值缺失**：solver 未成"被多工具证明需要的内核收编地"；空壳目录误导 → G14 级卫生问题 | **P0** |
| 5 | **确定性验证**（同输入双跑字节一致） | ✗ | Abacus 排序依赖指针序**未审计**；无 gtest E-SOL-02 | ASLR 场景布局不可复现 → G2 红线 | **P0** |
| 6 | **NaN/Inf 卫士** | ✗ | Abacus 入口无校验（cell 宽/行高/坐标有限性）；工厂 default 静默 nullptr | 退化输入 UB（崩溃或静默错误）→ G14 响亮失败纪律 | **P0** |
| 7 | **vs CGAL 几何精度对拍**（距离/包含谓词误差） | ✗ | boost::polygon（整数）vs CGAL（有理数）误差**未量化**；无 E-CGAL-01 | 几何计算误差不可归因 → iECO/iDRC 调用 geometry 的可信度不明 | P1 |
| 8 | **Partition 质量**（vs hMETIS net cut） | ✗ | partition 目录空；iPL `NesterovPlace` 自写 net cut 最小化，质量**未验证** | iPL 全局布局质量天花板受限（分区差 → 线长/拥塞差）；但工具内实现 ≠ solver 缺口 | P1 |
| 9 | **QP 初值精度**（vs Cadence QPlace quadratic） | ✗ | QP 目录空；iPL `NesterovPlace` 自写二次规划，收敛性**未验证** | GP 初值质量受限；但工具内实现 ≠ solver 缺口 | P2 |
| 10 | **Steiner 线长精度**（vs FLUTE/GeoSteiner） | ✗ | steiner_forest 目录空；iPL 直接引 flute3（third_party），精度 OK 但**不经 solver** | Steiner 计算正确但复用姿势错（各工具各自引 flute3 → 版本/封装不统一） | P2 |
| 11 | **工厂响亮失败** | ⚠️ | `LGMethodCreator` default 静默 nullptr（`LGMethodCreator.cc:37-39`） | 未知 method 类型 → 调用方不查空即崩 | P1 |
| 12 | **SolverResult 统一返回约定** | ✗ | `LGMethodInterface` 返回值约定**未文档化**；iPL 侧失败检查**未验证** | 失败语义不透明 → 工具层无法正确上抛 rc（G14） | P1 |

**§1.5 结论**：精度缺口是**结构性的三层**——**(a) 精度验证栈**：vs 商业金标对拍（Abacus vs QPlace、geometry vs CGAL）缺失（#3/7，**边界失明**）；**(b) 复用姿势**：≥2 消费方门禁/收编纪律不存在，空壳目录误导（#4，**复用价值缺失**）；**(c) 可靠性基础**：确定性/NaN 卫士/响亮失败缺（#5/6/11，**G2/G14 红线**）。rv1.1 只覆盖了 (c) 的诊断，(a)(b) 是 rv2.0 新增战线。**Tier 3 基础设施头号纪律 = 复用姿势透明**（KH-SOL-01）：单消费者模块 = 未充分证明收编价值。

### 1.6 边界 / 回退 / 假成功

- 工厂 default 静默 nullptr（§1.2）——唯一存量边界缺陷。
- TBD 目录若被构建系统 glob 到不会报错（0 文件），**CI 无任何机制发现"solver 一半是空壳"**——rv1.1 文档作者正是被目录名误导。
- Abacus 失败语义：`LGMethodInterface` 返回值约定**未文档化**，iPL 侧消费处未验证失败检查（§14）。
- **SKIP≠PASS 红线**（借鉴 30-iDRC §1.5-#5）：geometry 单消费者 ≠ "几何库成熟"；Abacus 单消费者 ≠ "合法化可复用"；**必须 ≥2 消费方才能宣称收编成功**（NFR-SOL-03）。

### 1.7 跨工具协调

| 方向 | 现状 | 判定 |
|---|---|---|
| solver → iPL | Abacus 唯一接线（`Legalizer.cc:32`） | 通但单线 |
| solver → iECO | geometry 唯一接线 | 通但单线 |
| iPL/iTO → third_party 数值库 | 各 tool `external_libs/*.cmake` 自引 | **绕开 solver**，无版本/封装统一 |
| solver → iIR | iIR 内嵌 Eigen 求解 | 明确不并入（rv1.1 裁定保留） |
| iPL/iCTS → solver | 潜在消费方（clustering/Steiner）**未接入** | **断**（复用价值缺失） |
| solver → 22-iPL | iPL 宏真化/QP 初值的**真实需求**驱动 QP 目录立项 | **被动等待**（rv1.1 D4） |

**§1.7 结论**：solver 当前只被 2 个工具单点消费（iPL Abacus、iECO geometry），其他工具（iTO/iCTS/iRT）的数值需求各自解决——**"共享算法库"的定位未实现**，真实角色是"两个孤岛模块的存放地"（§1.5-#4）。

### 1.8 症结优先级表（§1 结论摘要）

| ID | 症结 | 证据 | 对标线 | P |
|---|---|---|---|---|
| **S1** | **无 vs QPlace 精度对拍 → Abacus 位移/重叠边界失明** | 无 harness；无 `benchmark/qor/solver/` | Cadence QPlace | **P0** |
| **S2** | **复用姿势门禁缺失 → 单消费者模块占公共目录** | Abacus/geometry 各 1 消费方；无 README 收编纪律 | 多工具复用 | **P0** |
| **S3** | **确定性未验证 → ASLR 场景不可复现** | Abacus 排序依赖指针序**未审计**；无 E-SOL-02 | G2 确定性 | **P0** |
| **S4** | **NaN/Inf 卫士缺失 → 退化输入 UB** | 入口无校验；工厂 default 静默 nullptr | G14 响亮失败 | **P0** |
| S5 | TBD 空壳目录（5/7）误导 | `ls -la src/solver/*/TBD` 全 0 字节 | 代码卫生 | P0（G14 级） |
| S6 | vs CGAL 几何精度未量化 | boost::polygon（整数）vs CGAL（有理数）误差**未测** | CGAL 金标 | P1 |
| S7 | SolverResult 返回约定未文档化 | `LGMethodInterface` 失败语义不透明 | G14 | P1 |
| S8 | 工具内数值内核散落（partition/QP/Steiner） | iPL 各自实现，不经 solver | 统一封装 | P2（被动等需求） |

**§1 最关键 5 条（双对标线）**：  
- **商业精度线**：S1（vs QPlace 对拍）、S6（vs CGAL 对拍）  
- **复用姿势线**：S2（≥2 消费方门禁）、S3（确定性）、S4（卫士）

rv1.1 只覆盖 S5（TBD 空壳诊断）与 S7（返回约定），rv2.0 新增 **S1/S6（vs 商业金标精度验证栈，Tier 3 基础设施核心）** + **S2（复用姿势门禁，防空壳再生）** 三条结构性症结。

---

## 2. 需求 FR / NFR / 约束

### 2.1 FR（★=新增；与 v2.0 对照，悬空项已重锚）

| ID | 功能 | 现状 | rv1.1 |
|---|---|---|---|
| FR-SOL-01 | ★ 五个 TBD 空目录处置：填入真实需求驱动的实现**或**删除 | 0 字节占位 ×5 | P0（§4.1，G14 级卫生） |
| FR-SOL-02 | ★ Abacus gtest（合法化最小位移 + 边界用例） + NaN/Inf 卫士 | 无 test | P0（§4.2） |
| FR-SOL-03 | ★ `LGMethodCreator` default 响亮失败（ERROR，非静默 nullptr） | 静默 nullptr | P0 |
| FR-SOL-04 | ★ Abacus 确定性验证（同输入双跑字节一致） | 未验证 | P1 |
| FR-SOL-05 | ★ `src/solver/README.md`：写明"什么该进 solver、什么留工具内"的收编纪律 | 无 | P0（§3 D1） |
| FR-SOL-06 | SolverResult{ok,iters,residual} 统一返回约定 | 无 | P1（**先用于 Abacus 改造，验证模式后再推广**——v2.0 给不存在的 QP 设计 API 的教训） |
| FR-SOL-07 | geometry 归属裁定执行（公共化或降级 iECO） | 单消费者 | P2 |
| FR-SOL-08 | SA seed/温度表规格 | 无消费者 | **冻结**（§3 D4：直到 iPL 宏真化产生真实需求，22 主导） |

### 2.2 NFR

| ID | 指标 | 门槛 |
|---|---|---|
| NFR-SOL-01 | 同输入 Abacus 双跑 | 输出字节一致 |
| NFR-SOL-02 | 退化输入（空 cell/零宽行/NaN 坐标） | 失败上抛，非 UB |
| NFR-SOL-03 | 新增 solver 内核 | 必须≥2 个真实消费方才准入公共目录（防空壳再生） |
| NFR-SOL-04 | solver 全库 gtest | ≥存量两模块核心路径 |

### 2.3 红线

- **禁止**给不存在的代码设计 API（v2.0 教训：FR 表驱动前先 `find -type f`）。
- **禁止**在工具内平行重写 Abacus（现存唯一公共内核）；发现第二处 Abacus 实现即 bug。
- **禁止**为"完备性"向 TBD 目录填投机实现——准入条件是**真实消费方**（NFR-SOL-03）。
- iIR 的 Eigen 求解**不**强行并入（v2.0 裁定正确，保留）。

---

## 3. HLD 总体架构

### 3.1 数据流（据实）

```
                     src/solver/（现实：2 个活模块 + 5 个空壳）
  ┌──────────────────────────────────────────────────────────┐
  │  legalization/Abacus ──────────► iPL Legalizer.cc:32      │
  │  geometry/boost ───────────────► iECO ieco_data_via.h     │
  │  【TBD×5: partition/clustering/QP/steiner/two_pin】        │
  └──────────────────────────────────────────────────────────┘
  真实数值内核（工具内，不经 solver）:
    iPL: NesterovPlace / initial_placer / detail_placer / SteinerWirelength→flute3
    iTO: 自引 flute3     iIR: 内嵌 Eigen     iSTA: 自有时序图
  third_party: highs/lemon/hmetis/metis/flute3/BST-DME/salt/spectra/fft
        ▲ 各工具 external_libs/*.cmake 各自链接，无统一封装
```

### 3.2 关键设计决策（含被否）

| # | 决策 | 被否 |
|---|---|---|
| D1 | **solver 定位 = "被 ≥2 工具证明需要的数值内核的收编地"**，不是"完备数值库"（README 写明准入纪律 NFR-SOL-03） | 把 TBD 目录填满以"对齐目录结构" |
| D2 | geometry：先审计 iRT/iDRC 是否有重复几何轮子，有则公共化，无则降级回 iECO | 维持"伪公共"现状 |
| D3 | SolverResult 模式先在 Abacus 上改造验证，再谈推广 | 一次性全库 API 运动（v2.0 式） |
| D4 | SA/QP API **冻结**，等 22-iPL 宏真化/QP 初值产生真实需求后由消费方驱动设计 | 现在就写 SA/QP 规格（v2.0 FR-SOL-01/03，悬空） |
| D5 | TBD 空目录：M0 盘点后删除；将来有实现时按 git 历史重建目录 | 保留占位（误导文档与新人，本案即受害者） |

---

## 4. LLD · 模块分解

### 4.1 ★ TBD 目录处置（FR-SOL-01，P0）

```
ALG-4.1-1  每个 TBD 目录三问
  Q1 有真实消费方在等它吗？（grep 消费方 TODO/文档）  → 有：立项，由消费方 doc 驱动（如 22-iPL 的 QP 初值）
  Q2 third_party 已有等价物吗？（partition→hmetis/metis, QP→highs）  → 有：不实现，写"经由 third_party X 消费"进 README
  Q3 都无？  → 删除目录（git 可恢复）
```

**产出**：`solver-inventory.md`（每目录：实况/消费方/处置）；删除 PR 与 README（FR-SOL-05）同批落地。**复杂度**：纯审计，O(目录)。**边界**：partition 目录的"愿望"与 3D fork 的 iPAR 经验不可照搬（fork 是把 partition 填成了 iPAR，那是另一套需求）。

### 4.2 Abacus 可信化（FR-SOL-02/03/04，P0）

**现状签名（真实）**：`class Abacus : public LGMethodInterface`（`Abacus.hh`），1137 LOC；经 `LGMethodCreator::createMethod(kAbacus)` 构造；iPL `Legalizer.cc:32` 消费。

- **gtest（新增 `src/solver/legalization/test/`）**：(a) 单行三 cell 最小位移；(b) 超宽 cell 放不下→失败语义；(c) 空输入；(d) NaN 坐标注入→卫士失败（FR-SOL-02）；(e) 同输入双跑字节一致（FR-SOL-04）。
- **卫士**：入口校验 cell 宽/行高/坐标有限性；失败经 `LGMethodInterface` 约定返回码上抛（FR-SOL-06 的首个落地处）。
- **工厂修复**：default 分支 `LOG_ERROR` + 返回 nullptr，并给 creator 加 gtest（FR-SOL-03）。
- **复杂度**：Abacus 本体 O(N log N + Σ行)；卫士 O(N)。**边界**：site_w≤0、行数 0、cell 宽 > 行宽。
- **复用姿势**：保留自建（已成熟）；**禁止第二实现**。

### 4.3 SolverResult 约定（FR-SOL-06，P1）

```cpp
// ★ 新增（先在 legalization 内落地，不进公共头直到第二消费方出现）
struct SolverResult { bool ok; int iters; double residual; std::string msg; };
// Abacus: ok=全部落位, iters=pass 数, residual=总位移², msg=失败行/cell 名
// 调用方契约: ok=false → 工具层 rc≠0（联动 41/G14）
```

**边界**：残差 NaN → ok=false。**教训刻录**：本约定 v2.0 是为不存在的 QP 设计的；rv1.1 先让 Abacus 用它跑通一个真实闭环，模式才许推广。

### 4.4 geometry 归属（FR-SOL-07，P2）

```
ALG-4.4-1  grep iRT/iDRC/iFP 的几何轮子（Boost.Polygon/自写 rect 运算）
  发现 ≥1 处重复 → 提升 EngineGeometry 为公共出口，重复处收编
  无重复        → 目录移入 iECO（git mv），solver/geometry 删除
```

### 4.5 模块状态一览

| 模块 | 现状成熟度 | 主复杂度 | 关键边界 | 复用姿势（现状→目标） |
|---|---|---|---|---|
| Abacus | 生产级（1137 LOC，单消费方 iPL） | O(N log N + Σ行) | 超宽 cell/空输入未卫士化 | 自建保留 + gtest + 卫士 |
| LGCustomization | 薄（61 LOC） | — | 语义未审 | 随 Abacus 一并补 test |
| LGMethodCreator | 工厂（43 LOC） | O(1) | default 静默 nullptr | 修响亮失败 |
| geometry/boost | 实现合理（694 LOC），单消费方 | O(元素 log) | — | 公共化或降级（ALG-4.4-1） |
| TBD ×5 | **空壳** | — | 误导性占位 | 删除/需求驱动重建（§4.1） |
| 工具内数值内核（iPL/iTO/iSTA/iIR） | 生产级但散落 | — | 无统一封装 | **不动**；≥2 消费方才收编（D1） |

---

## 5. 配置

| 键 | 默认 | 说明 |
|---|---|---|
| `solver.abacus.guard` | true（新增后） | NaN/Inf 卫士；关闭仅供调试对照 |
| —（SA/QP 配置族） | **冻结** | v2.0 的 `sa.seed/t0/cool`、`qp.max_iter/tol` 随 FR-SOL-08 冻结，待真实消费方 |

缺省行为不变 → 零回归。

---

## 6. 指标分解

| 维 | 含义 | 记录 |
|---|---|---|
| legalize_displacement | Abacus 总位移² | 独立列（进 12 QoR schema 候选） |
| legalize_fail_reason | 失败归类（超宽/NaN/空） | 独立列 |
| determinism_diff | 双跑差异字节数 | 必须 0 |
| solver_alive_ratio | 活模块/总目录 | 现状 2/7 → 目标 100%（删空后） |

---

## 7. 状态机 / 命令语义

```
createMethod(type)  → 失败响亮（ERROR + nullptr）
legalize(cells,rows) → guard → solve → SolverResult{ok,...}
ok=false → 调用方（iPL）rc≠0，禁止"位移一半当成功"
```

---

## 8. 跨工具 Cascade

| 上/下游 | 信号 | 契约 |
|---|---|---|
| solver → 22 iPL | Abacus 合法化 + SolverResult | iPL LG 失败必须上抛（G14） |
| solver → iECO | geometry | 归属裁定后重签 |
| 22 → solver（反向） | iPL 宏真化/QP 初值的**真实需求** | 驱动 FR-SOL-08 解冻与 QP 立项 |
| solver → 12 | legalize_displacement 等指标 | QoR schema 候选字段 |

---

## 9. 商业 Know-how 映射

| KH-ID | 本工具落点 |
|---|---|
| KH-X-04（发散/失败响亮） | §4.2 卫士、§4.3 SolverResult、FR-SOL-03 |
| KH-PL-01（解析初值） | **冻结项**：QP 初值归 22-iPL 主导，solver 只提供收编位（§3 D4） |
| （新增）确定性复现 | FR-SOL-04 / NFR-SOL-01 |

---

## 10. 商业对照看板 + 演进 M0–M4

### 10.1 看板

| 指标 | iEDA solver | 商业（内置 numerics） | 门槛 | 绑定 |
|---|---|---|---|---|
| 公共内核数 | 2（Abacus+geometry） | 全集成 | 需求驱动，不比数量 | — |
| 空壳目录 | 5 | 0 | 0 | G14 卫生 |
| 合法化确定性 | 未验证 | 确定 | 双跑字节一致 | G2 |
| 退化输入 | UB 风险 | 响亮失败 | gtest 全绿 | G14 |

### 10.2 对照实验（杀假说）

| 实验 | 方法 | 杀死条件 |
|---|---|---|
| E-SOL-01 | `find src/solver -type f` + `wc -c */TBD` | 若任何 TBD 非 0 字节 → §1.1 被杀（预期全 0） |
| E-SOL-02 | Abacus 同输入双跑 | 输出不同 → 不确定性实锤，先修再谈别的 |
| E-SOL-03 | NaN 坐标注入 | 不失败 → 卫士必要性实锤 |
| E-SOL-04 | grep 工具内第二处 Abacus | 发现即平行重写 bug |
| E-SOL-05 | grep iRT/iDRC 几何轮子 | 决定 ALG-4.4-1 走向 |

### 10.3 演进

```text
M0 先量：solver-inventory.md（E-SOL-01/04/05）+ TBD 处置 PR + README 准入纪律
M1 可信：Abacus gtest×5 + 卫士 + 工厂响亮失败 + 确定性验证
M2 主算法：SolverResult 在 Abacus 闭环（iPL 消费失败上抛）
M3 打平：（被动）22 宏真化/QP 初值需求到达 → 解冻 FR-SOL-08，消费方驱动设计
M4 纵深：确定性并行 reduction 序文档化；第二批收编评估（Steiner/初值布局）
```

退出门禁：M0→inventory+空壳清零；M1→NFR-SOL-01/02；M2→iPL LG 失败注入 rc≠0；M3→有真实消费方才启动。

---

## 11. Exhibit

| 档 | 产物 |
|---|---|
| text | `docs/ai/attachments/solver-inventory.md`（M0 台账） |
| JSON | `solver_trace.jsonl`（SolverResult 落地后：ok/iters/residual/msg 逐调用） |
| text | `src/solver/README.md`（准入纪律 NFR-SOL-03） |

---

## 12. 测试计划

| 层 | 用例 | 锁住 |
|---|---|---|
| L0 | Abacus 最小位移/超宽/空/NaN/双跑一致 ×5 | FR-SOL-02/04 |
| L0 | 工厂未知 type → 响亮 | FR-SOL-03 |
| L1 | iPL gcd LG 失败注入 → rc≠0 | §7/G14 |
| L5 | `find src/solver -name TBD` 为空（CI 防空壳回潮） | FR-SOL-01 |

---

## 13. 里程碑（按周粗估）

| 周 | 交付 | 验收 |
|---|---|---|
| W0 | inventory + TBD 处置 + README | M0 |
| W1 | Abacus gtest + 卫士 + 工厂修复 | M1 |
| W2 | SolverResult 闭环 + iPL 失败上抛联调 | M2 |
| W3+ | geometry 归属执行；（被动）FR-SOL-08 解冻 | M3 |

PR 切片：SOL-0 inventory+TBD 删除+README → SOL-1 Abacus gtest/卫士/工厂 → SOL-2 SolverResult → SOL-3 geometry 归属。

---

## 14. 未验证 / 负面结论

| # | 项 | 说明 |
|---|---|---|
| 1 | Abacus 内部确定性（排序是否依赖地址序） | E-SOL-02 裁决前不写"确定" |
| 2 | `LGMethodInterface` 返回约定与 iPL 侧失败检查 | 代码未文档化，需读 iPL `Legalizer.cc` 全文件 |
| 3 | LGCustomization 语义与消费者 | 61 LOC，grep 未见消费方（**疑似第二处死代码**，待 inventory 裁决） |
| 4 | third_party highs 是否被任何 target 真实链接 | cmake 引用存在 ≠ 链接；未验证 |
| 5 | iPL `NesterovPlace` 的 QP 初值实际形态 | 注释提 Quadratic；收编评估前需读码 |

**不要重走**：
- 不要给不存在的代码设计 API（v2.0 给 0 字节 QP 目录写 FR-SOL-01/03 是本案原型）。
- 不要为"目录好看"填投机实现——准入门槛是真实消费方（NFR-SOL-03）。
- 不要在 iPL 内再写一套 CG/Abacus——发现第二实现即收编议题。

---

## 附录 A · 迁移 checklist

- [ ] `solver-inventory.md`（7 目录实况/消费方/处置）
- [ ] 五个 TBD 目录删除 PR（或 Q1 立项记录）
- [ ] `src/solver/README.md` 准入纪律
- [ ] Abacus gtest ×5 + NaN 卫士
- [ ] `LGMethodCreator` default 响亮 + gtest
- [ ] SolverResult 在 Abacus 落地 + iPL 失败上抛
- [ ] geometry 归属（ALG-4.4-1）执行
- [ ] CI：`find src/solver -name TBD` 为空断言

## 附录 B · 关键决策记录

| # | 决策 | 被否 |
|---|---|---|
| E-1 | solver=收编地（≥2 消费方准入） | 完备数值库幻想 / 填满 TBD |
| E-2 | 存量两模块先可信化 | 先设计新 API |
| E-3 | SA/QP 规格冻结待真实需求 | 现在就写（v2.0 悬空 FR） |
| E-4 | TBD 删除（git 可恢复） | 保留占位 |
| E-5 | iIR Eigen 不并入 | 强行统一数值栈 |

## 附录 C · 术语

- **TBD 目录**：仅含 0 字节 `TBD` 占位文件的目录；本案 5 个
- **收编**：工具内成熟内核在出现第二消费方后移入 src/solver 的动作
- **SolverResult**：`{ok,iters,residual,msg}` 统一返回约定（先在 Abacus 验证）
- **卫士**：入口数值合法性检查（NaN/Inf/退化），失败响亮上抛

## 附录 D · 证据摘录（file:line 最小集）

| 断言 | 证据 |
|---|---|
| TBD×5 全 0 字节 | `ls -la src/solver/{clustering,partition,qudratic_programming,steiner_forest,two_pin_routing}/TBD` = 0 |
| Abacus 体量 | `Abacus.cc` 1137 / `AbacusCluster.{cc,hh}` 144+135 |
| 工厂分派 | `LGMethodCreator.cc:27-42`（default 静默 nullptr `:37-39`） |
| iPL 消费点 | `iPL/.../legalizer/Legalizer.cc:20-32`（`LGMethodCreator method_creator;`） |
| geometry 单消费方 | grep `engine_geometry` 于 `src/operation` 仅 `iECO/.../ieco_data_via.h` |
| solver 全量 LOC | `find src/solver -name '*.cc' -o ... | xargs wc -l` = 2469 |
| 工具内 Steiner | `iPL/.../evaluator/wirelength/SteinerWirelength.{hh,cc}` |
| flute3 自引 | `iPL/external_libs/ipl_source_external_libs.cmake`、iTO 同款 |
| third_party 数值库 | `src/third_party/{highs,lemon,hmetis,metis,flute3,BST-DME,salt,spectra,fft}` |
