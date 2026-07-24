<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 20 · iFP 布图规划 · 商业对标优化方案 · rv2.2

> 文档号：20-rv2.2　　版本：rv2.2（基础几何正确性落地）　　里程碑：**双对标 —— Innovus/ICC2 floorplan 精度线（auto-die + IO 质量 + 宏约束）× 性能线（秒级完成 die/core/IO/tap）**
> 体例：`01-ai-doc-conventions-rv1.md`；深度对标：`24-iPL-3d-rv1.0.md`、`27-iSTA-rv2.0.md`（逐 kernel 走读 + 诚实归因 + 双对标线）
> 商业金标：**Innovus floorplan**（die/core/IO/constraint 精度）；**ICC2 floorplan**（宏规划辅助）；门禁：**G3 / G14 / G17**（辅 G2）
> 上游：网表/LEF　下游：`22-iPL`、`24-iPDN`、`26-iRT`
> 纲领：`00-ieda-commercial-parity-master-plan-v1.1.md`；Know-how：`03-commercial-knowhow-catalog.md` KH-FP-\*
> 联合架构：`04-ppa-technical-review-and-optimization-rv1.md`；闭环工作台：`51-agent-native-eda-detailed-plan-v1.0.md`
> 覆盖：`src/operation/iFP/` 全树（1636 LOC）+ iPL 侧宏残迹（`PLAPI.cc`、`platform/.../ipl_io.cpp`、`tcl_ipl.cpp`）
> 纪律：**文档是假说不是事实**；断言带 `file:line`；未实测写「未验证」；每条理论附能杀死它的对照。

---

## 0. 变更记录

| 版本 | 日期 | 修订人 | 说明 |
|---|---|---|---|
| v1.0–v1.1 | 2026-07-20 | parity | 宏空壳；无 auto-die；职责裁定摘要 |
| rv1.0 / v2.0 | 2026-07-20 | parity | 体例对齐；坐实 iFP macro 空壳 + iPL `return true` 假成功 |
| rv1.1 / v3.0 | 2026-07-21 | parity | 对 iFP 全树 14 个源文件（1636 LOC）+ iPL 宏残迹逐行读完重写；坐实三空壳目录、IO 等间距无 cost、B1/B2 疑似 bug |
| **rv2.0** | **2026-07-22** | parity | **大改（对照 27-iSTA-rv2.0.md 的深度与双对标线体例重写）**。核心修订五条：**(1)** rv1.1 把 iFP 当成"三空壳+两疑似 bug"来审——**结构层核实后发现头号症结是精度机制完整度缺失**：有 die/core/IO/tap 四项基础能力，但**缺 vs Innovus/ICC2 floorplan 的精度验证栈**（无 auto-die 面积目标验证、无 IO net-driven cost、无宏约束与 iPL 闭环测试、无 die/core 合法性门槛 → G3/G17 主责交接不清）——in-design floorplan 的价值前提是"我知道 die 面积与 util 的关系、IO 摆放质量可量化、宏约束能被 iPL 消费"，当前状态是**边界模糊**（§1.5，类比 27 号文档对 PBA/SI 缺失的判定）；**(2)** 新增 **§1.5 精度栈逐项**（对 Innovus/ICC2 floorplan 的差距清单，辅助工具核心证据）：逐机制列出 iFP 已有 vs 商业 floorplan 必需的差距——die/core/track 初始化 ✓、tap/endcap 插入 ✓；但 **auto-die 面积模型未验证**（util→die 公式与实际拥塞/DRC 的关系未校准）、**IO placement 无 net-driven cost**（等间距排布 vs 商业工具的飞行线优化）、**宏约束模型单向**（iFP→iDB 写入但 iPL 消费侧未闭环测试）、**track 生成按 die vs core 未裁决**（§1.2-kernel 表指出，待 E-FP-07）、**三空壳目录占位误导**（G14 卫生）；**(3)** 全文按**双对标线**重组：Innovus 线 = floorplan 精度栈（auto-die 面积模型 + IO net-cost + 宏约束闭环 → G3/G17 面积/宏可解释），ICC2 线 = floorplan 辅助栈（die/core 合法性 + 快速完成 → 秒级），§10 拆成两块看板；**(4)** 补齐 27 号文档体例要素：§1.2 kernel 算法表（补 auto-die/IO/tap 伪码+复杂度+边界+复用姿势）、§4.6 模块状态一览、§5 配置表、§8 调用方契约表（iFP→iPL/iPDN/iRT 交接）、§10.1/10.2 双看板（vs Innovus/ICC2 + 对照实验 E-FP-01～07）、§14 未验证/不要重走/兄弟仓库三分；**(5)** 辅助工具特殊定位强化：**iFP 是 Tier 2 辅助工具**（主责在 iPL 宏真化，iFP 只做约束交接）——宏算法归 22、iFP 不实现 SA/力导向的红线前置（§2.3 约束、§3.2-D1 决策、§14.2 负面），精度栈聚焦 die/IO/tap 三项特有能力对商业工具的差距（§1.5），篇幅适当精简但保持核心章节完整（§4 LLD 保留伪码但不展开 MacroPlacer）。**缺省新特性关闭 → 零回归**纪律不变。 |
| **rv2.1** | **2026-07-23** | Codex | 实现评审：auto-die 从单一 `A_cell/util` 改为 std/macro/halo/blockage/IO/PDN/whitespace 分项预算与下游拥塞可行性循环；IO 从“按重心排序”改为约束槽位分配；面积/IO 实验改用独立指标、效应量和置信区间。 |
| **rv2.2** | **2026-07-24** | agent team | 裁决并修复 B1/B2：非方形 core 的垂直 IO pitch 改用高度，tap blockage 使用闭区间标准相交；新增纯几何单测。die/core 坐标、DB/layout/site/layer 和自动尺寸输入开始响亮失败，Tcl/Python 传播返回值。负坐标合法，但负坐标 site snapping 仍使用 C++ 截断，设计级回归前保持未验证。 |

---

## 1. 症结审计（逐文件代码走读）

### 1.1 功能形态——真实模块清单（`find` 全量，1636 LOC）

| 模块 | 文件实况 | 判定 |
|---|---|---|
| API 门面 | `ifp_api.h:47-56`（initDie/initCore/makeTracks/autoPlacePins/autoPlacePad/tapCells）+ `ifp_api.cpp` 124 | 真实转发层 |
| init_design | `init_design.cpp` 145 / `.h` 65 | 成熟但教科书（§1.2） |
| io_placer | `io_placer.cpp` **668**（全树最大）/ `.h` 64 | **有量无质**：等间距排布，无 cost（§1.2） |
| tap_cell | `tapcell.cpp` 301 / `.h` 65 | 全树最成熟模块；含内联 endcap |
| **endcap_cell** | **仅 0 字节 `CMakeLists.txt`** | **空壳**（功能内联在 tap_cell） |
| **io_router** | **仅 0 字节 `CMakeLists.txt`** | **空壳** |
| **macro_placer** | **仅 0 字节 `CMakeLists.txt`** | **空壳** |
| data | `ifp_interval.{h,cpp}` 59+21、`ifp_enum.{h,cpp}` 33+21 | interval 容器（tap 用） |
| **test/** | `CMakeLists.txt` + `FloorplanGeometryTest.cc` | 基础几何合同 D2；尚非完整 iDB/设计级测试 |

### 1.2 算法成熟度（逐 kernel）

| kernel | 现状算法（file:line） | 判定 | 缺口 |
|---|---|---|---|
| `InitDesign::initDie` | 用户四角先做有限数/严格有序校验，再检查 DB/layout/die 与 DBU 转换后矩形 | 基础合法性已加固 | 无商业 auto-die 面积模型与设计级回归 |
| `InitDesign::initCore` | site 对齐取整 + 建行（奇偶行 `kFS_MX`/`kN_R0` 交错，`:88`） | 成熟 | **IO 带检查被注释**（`:73-78` "error report, tbd"）——core 贴着 die 边建 row 无防线 |
| `InitDesign::makeTracks` | pitch/offset 写 track grid（`:114-144`） | 可用 | **track 条数按 die 宽/高算**（`:131`、`:140`）而非 core——core 外也铺 track，与 LEF TRACKS 并存策略未验证 |
| `IoPlacer::autoPlacePins` | **pin_list 顺序绕四边等间距**；横/纵 pitch 分别由 core 宽/高计算并对齐 manufacture grid | B1 已修，但仍**无飞行线、无连通性、无 cost** | 商业 IO 规划的 net-driven 质量机制整体缺失 |
| `IoPlacer::placePort` / `placeIOFiller` / `fillInterval` | 定点 port（`:292`）；pad 区间填 filler（`:353/:431`） | 有实现 | 生产调用路径未验证 |
| `IoPlacer::autoPlacePad` / `set_pad_coords` / `autoIOFiller` | pad 环摆位（`:491/:577/:642`） | 有实现 | 仅 pad flow 用；未验证 |
| `TapCellPlacer::tapCells` | 间距 snap site 倍数 → master 查空 → 按行减 blockage 建区间 → 插 ENDCAP_/PHY_ | **成熟**（全树最佳）；B2 已按闭区间相交修复 | 完整 iDB blockage 场景仍需设计级 E-FP-06 |
| `InitDesign::transUnitDB` | 单位换算（`:24-30`） | 可用 | layout 空时返回 **-1 哨兵**（静默，调用方不查） |

### 1.3 边界 / 回退 / 疑似 bug（★=带杀死实验）

- **B1 已确认并修复**：左/右边纵向位置改用 `height_step`；`makePinPitch` 的非方形与 manufacturing-grid 单测通过。E-FP-05 的完整设计/产物断言仍待跑，故只升 D2。
- **B2 已确认并修复**：`buildRegionInRow` 复用 `intersectsClosed(row_box, blockage_box)`，覆盖相离、边界接触与左悬垂微例。E-FP-06 的真实 iDB blockage/tap 实例检查仍待跑。
- **B3** `checkDistance`（`:40-54`）按引用 snap `inst_space` 到 site 倍数，**返回值的语义是"没 snap"**，`tapCells` 在 `:56` 丢弃该返回值——逻辑无错但接口反直觉，重构候选。
- **B4** `initCore` 的 IO 带检查整段注释（`:73-78`）：core 边界压 die 边界时无报错路径。
- **B5 已部分关闭**：非有限数和 `ll>=ur` 现在拒绝；负坐标本身是合法 DEF 坐标，不应拒绝。残余风险是负坐标除以 site pitch 时 C++ 向零截断，而不是数学 floor。
- **假成功链路（坐实，G14）**：`tcl_ipl.cpp:257-265` `CmdPlacerRunMP::exec` → `ipl_io.cpp:170-181` 函数体全注释 `return true` → `PLAPI.cc:517-522` 全注释 → `macro_placer/readme.md` 一行。**`run_mp` 命令对任何设计都 rc=0 且零效果。**
- **空壳目录×3**仍在；测试已从零推进到纯几何合同，生产 iDB 集成测试仍缺。

### 1.4 跨工具协调

| 方向 | 现状 | 判定 |
|---|---|---|
| iFP → iPL | die/core/row/track 经 iDB 消费；宏位靠手工或假 MP | 宏通道债务推到 GP（KH-FP-03） |
| iFP → iPDN | core 边界供 strap | 半通 |
| iFP → iRT | track/IO pin | 半通（track 按 die 算，§1.2） |
| iFP → 平台契约 C3 | rows/core round-trip（40 §7.2） | 待测 |
| iPL 宏残迹 → iFP | 假成功命令 `run_mp` 挂在 iPL 名下 | **归 22 主责**，iFP 只交约束（v2.0 裁定保留） |

**职责裁定（保留 v2.0 铁律）**：宏算法归 iPL（22）；iFP 只做 halo/通道/orient/hint 约束模型 → iDB。auto-die 新增于 init_design，与 initDie 互斥响亮失败。IO/tap 保持增强，先补产物断言与 B1/B2 裁决。

### 1.5 ★精度栈逐项——对 Innovus/ICC2 floorplan 的差距清单（辅助工具核心，双对标证据）

Innovus/ICC2 floorplan 的实用性来自一整套互相咬合的机制。逐项核实 iFP 差距（✓=有且生产在用，⚠️=有但半残，✗=无）：

| # | Innovus/ICC2 floorplan 机制 | iFP 现状 | 证据 | 对下游布局/布线的影响 | P |
|---|---|---|---|---|---|
| 1 | die/core/row 初始化 | ✓ | `InitDesign::initDie`（`init_design.cpp:32-43`）+ `initCore`（`:45-101`） | 基准能力 | — |
| 2 | **auto-die**（util+aspect → die 尺寸，site 对齐） | ✗ | 全树无 `autoDie` / `autoFloorplan`；仅手工 `initDie(lx,ly,ux,uy)` | **手工 die → 面积不可复现**（不同设计师给不同尺寸）；util 与拥塞/DRC 的关系无校准 → **G17 面积行无基线** | **P0** |
| 3 | **auto-die 面积模型验证**（util=0.55 → 实际拥塞<阈值） | ✗（功能缺） | 无 auto-die → 无验证；§4.1 设计 util 默认 0.55 **未校准** | util 过高 → 布局拥塞/DRC 爆炸；过低 → 芯片面积浪费（KH-FP-02） | **P0** |
| 4 | IO placement（pin 按 net 连通性优化位置） | ⚠️ **等间距无 cost** | `IoPlacer::autoPlacePins`（`io_placer.cpp:84-290`）：按 pin_list 顺序绕四边 `width_step` 等间距；**零 net/wirelength cost** | IO 位置与内部连接无关 → 飞线长、时序差（商业工具：IO 靠近 driver/load 重心） | **P1** |
| 5 | **IO net-driven cost**（minimize Σ飞线长） | ✗ | `autoPlacePins` 无 cost 函数；无 net 查询/重心计算 | 等间距 IO 可能让关键 net（clock/reset）绕芯片一圈 → WNS 恶化数十 ps（**未实测**，E-FP-08） | P1 |
| 6 | tap cell / endcap 插入 | ✓ | `TapCellPlacer::tapCells`（`tapcell.cpp:34-77`）；endcap 内联（`:211-224` ENDCAP_） | **成熟**（全树最佳模块） | ✓ |
| 7 | **tap cell blockage 相交判定** | ✓ D2 | `tapcell.cpp` 使用 `intersectsClosed`；纯几何微例覆盖悬垂/接触 | 代码 bug 已关闭；设计级 E-FP-06 待补 | P1 |
| 8 | **IO pin 步进正确性** | ✓ D2 | 左/右边改用 `height_step`；非方形 pitch 微例通过 | 代码 bug 已关闭；设计级 E-FP-05 待补 | P1 |
| 9 | **宏约束模型**（halo/channel/orient/hint） | ⚠️ 设计有、闭环无 | `MacroConstraintModel` 设计（§4.2）；写 iDB 属性；**iPL 消费侧未验证**（22 宏真化前） | 约束写了但 iPL 不读 → 空转（单向模型） | P1 |
| 10 | 宏摆位算法（SA/力导向/分区） | ✗（**铁律：归 iPL**） | `macro_placer/` 空壳；`run_mp` 假成功链路坐实（§1.3-假成功） | **G3 主责在 22**；iFP 不实现宏算法（KH-FP-03） | — |
| 11 | die/core 合法性检查 | ⚠️ D2 | 有序/有限矩形、DB/layout/site、core-in-die 与 Tcl/Python 返回传播已实现 | IO 带语义与负坐标 site snapping 尚未完成 | P1 |
| 12 | track 生成策略 | ⚠️ **按 die vs core 未裁决** | `makeTracks`（`init_design.cpp:131,140`）按 **die 宽高**计算条数 | core 外铺 track 是否合理？与 LEF TRACKS 并存策略未验证（**待 E-FP-07 裁决**） | P1 |
| 13 | IO 带预留（die-core 间距） | ⚠️ | `initCore` 的 IO 带检查整段注释（`:73-78`："error report, tbd"） | core 贴 die 边时无防线 → row 压 die 边界 | P2 |
| 14 | 产物断言（tap/IO 完成性） | ⚠️ | 有几何合同测试；尚无 gtest 断言 tap 后存在 PHY_/ENDCAP_ 或 IO 全 placed/无重叠 | 完整命令仍存在产物级假成功风险 | P1 |
| 15 | **vs Innovus/ICC2 面积/拥塞对照** | ✗ | 无 harness；G17 面积行无基线（同网表 iFP 手工 vs Innovus auto 面积差未记录） | 不知道 iFP die 尺寸与商业工具的差距 → 面积优劣无依据 | **P0** |

**§1.5 结论**：精度缺口是**结构性的三层**——(a) 面积模型层：auto-die 缺、util 未校准、无 vs 商业面积对照（#2/3/15，**G17 面积行主缺口**）；(b) IO 质量层：等间距无 cost、B1 步进疑似错（#4/5/8，**时序/布线质量影响**）；(c) 约束闭环层：宏约束单向、tap blockage 判定疑似错、产物断言缺（#7/9/14，**G3/G14 交接风险**）。rv1.1 只覆盖了 (b)(c) 的疑似 bug 发现，(a) 是 rv2.0 新增战线。**辅助工具头号纪律 = 职责清晰**（宏算法归 iPL、iFP 做约束/die/IO/tap）+ **边界诚实**（auto-die 面积模型需校准，不可盲目默认 util=0.55）。

**假说 H-FP-1（可杀）**：util=0.55 默认值对 nangate45/sky130 量级设计足够（拥塞<10%、DRC clean）。  
**杀死实验 E-FP-02**：同网表 util=0.55 vs 0.75，量拥塞/DRC；若 0.55 仍拥塞>10% or DRC>阈 → 杀 H-FP-1，改调 util 默认或按设计类型分档。

**假说 H-FP-2（可杀）**：IO 等间距 vs net-driven，WNS 差 ≤20ps（可忽略）。  
**杀死实验 E-FP-08**：同设计 IO 等间距 vs 按 net 重心摆放，跑完 STA 比 WNS；若差 >50ps → 杀 H-FP-2，IO cost 升 P0。

---

## 2. 需求 FR / NFR / 约束

### 2.1 FR（★=新增）

| ID | 功能 | 现状 | rv1.1 |
|---|---|---|---|
| FR-FP-01 | initDie/initCore/makeTracks | ✓ | 保留 + initDie 校验（B5） |
| FR-FP-02 | autoPlacePins/Pad/IOFiller | ✓（无 cost） | ★ B1 裁决修复 + net 驱动 cost（§4.3，P1） |
| FR-FP-03 | tapCells/endcap | ✓ | 保留 + B2 裁决修复 + 产物断言 |
| FR-FP-04 | ★ auto-die（util+aspect→W×H，site 对齐） | ✗ | ★新增（§4.1，P0） |
| FR-FP-05 | ★ MacroConstraintModel → iDB | ✗ | ★新增（§4.2，P0）；**不**实现 SA 摆宏 |
| FR-FP-06 | ★ auto-die 与 initDie 互斥响亮失败 | ✗ | ★ G14 |
| FR-FP-07 | rows/core ↔ iPL round-trip | ❓ | 契约测试 |
| FR-FP-08 | ★ 三个空壳目录处置（删或填）+ test/ 从零建 | 空壳×3、零测试 | P0（G14 卫生） |
| FR-FP-09 | ★ makeTracks 按 core 计算（或论证 die 正确并文档化） | 按 die | P1 |

### 2.2 NFR

| ID | 指标 | 门槛 |
|---|---|---|
| NFR-FP-01 | auto-die 墙钟（≤50k inst） | < 1 s |
| NFR-FP-02 | util 策略 | 初始候选 0.55–0.60；按 PDK/设计族由拥塞、pin access、DRC holdout 校准，不作为跨设计常数 |
| NFR-FP-03 | 假成功 | 0（空壳命令/假 MP 须非成功 rc） |
| NFR-FP-04 | iFP gtest | 从零 ≥ §12 所列用例 |

### 2.3 红线

- **禁止**在 iFP 平行重写宏 SA/力导向（归 22）。
- **禁止**宣称 G3 转绿仅靠 iFP（G3 主责 iPL 宏真化）。
- 新特性缺省关闭 → **零回归**。

---

## 3. HLD 总体架构

### 3.1 数据流——单引擎双档（Innovus 精度线 × ICC2 性能线）

```text
                    LEF / 网表 / PDK site
                         │
Verilog/iDB ──► Netlist ──► cell 面积统计 ──► ★auto-die OR 手工 initDie
                         │                      ↓
                         │              util + aspect → die W×H (site 对齐)
                         │                      ↓
                         └─────────────► initCore (row 奇偶翻转 kFS_MX/kN_R0)
                                              │
                                        makeTracks (★按 die or core 待裁决)
                                              │
                              ┌───────────────┼───────────────┐
                              │  Innovus 精度线  │        ICC2 性能线  │
                              ▼                 ▼                      ▼
                      IO net-driven       IO 等间距          tap blockage 判定
                      (★P1 增强)          (现状教科书)        (★B2 修复)
                              │                 │                      │
                      MacroConstraint     产物断言            合法性检查
                      (halo/channel)      (tap/IO 完成)       (die 坐标/IO 带)
                              │                 │                      │
                              ▼                 ▼                      ▼
                      → iPL 消费约束      → iPDN/iRT        → 响亮失败 (G14)
                         (22 宏真化)         (track/IO)
                              │
                              ▼
                      G3 宏合法 + G17 面积行
```

**核心架构判断**：Innovus 精度线与 ICC2 性能线**共用同一套 die/core/track 初始化管线**——差别只在「调用的功能（auto-die vs 手工、net-driven IO vs 等间距）」和「生效的精度配置（§5 双档表：util 默认值、IO cost 开关、产物断言）」。这与 Innovus「common floorplan engine, 多 effort」同构；也直接否定「为快而跳过合法性检查」的路线（秒级完成但产物错误 = 负优化）。

### 3.2 关键设计决策（含被否）

| ID | 决策 | 被否方案 | 理由 |
|---|---|---|---|
| **D1** | **宏算法归 iPL；iFP 只约束**（铁律） | 在 iFP 实现 SA 宏摆位 | **KH-FP-03 核心**：宏摆位是优化问题（SA/力导向/分区），需迭代求解；iFP 是单趟辅助工具（die/core/IO/tap），职责不重叠。对照：Innovus `floorplan` 命令不做宏摆位（由 `place_opt -place_global` 的宏模块负责）；ICC2 `initialize_floorplan` 同理。**被否原因**：在 iFP 实现 SA = 与 22 职责冲突（两套宏算法）+ 增量债（iFP 无迭代框架）；约束交接模型（§4.2）= 清晰分工。 |
| **D2** | **auto-die 默认 util=0.55–0.60**（保守策略） | 激进 util≥0.75 默认 | **KH-FP-02 核心**：util 过高 → 布局拥塞/DRC 爆炸（先进工艺更明显）；过低 → 面积浪费但可制造。对照：商业工具默认 util=0.50–0.65（可配）。**被否原因**：util=0.75 在密集设计（如 bp_fe）实测拥塞>30%（§14.1-未验证，待量）；保守默认 + 可配 = 安全起步（E-FP-02 校准后可调）。 |
| **D3** | **auto-die 与 initDie 互斥响亮失败** | 静默覆盖坐标 | **G14 核心**：两路径同时调用 = 用户意图不明（可能是脚本 bug）；响亮失败 = 强制显式选择。对照：Innovus `-auto_bbox` 与手工坐标互斥。**被否原因**：静默覆盖 = 调试地狱（不知道最终 die 来自哪条路径）；互斥断言 = 一次失败胜过十次猜测。 |
| D4 | **约束写 iDB 属性，不另起平行 DB** | 仅 JSON 旁路 | iDB 是全项目共享 DB；属性机制已有（PROPERTY）；JSON 旁路 = 需同步维护两份数据。 |
| **D5** | **先裁决 B1/B2 两疑似 bug，再谈 IO 算法增强** | 在疑似错的等间距骨架上叠 cost | **工程纪律**：地基疑似歪（B1 步进用错变量、B2 相交判定错边）→ 先修地基再建楼（加 net-cost）。对照：商业开发流程先过单元测试（步进正确性、相交判定正确性）再优化算法。**被否原因**：在错的骨架上叠 cost = 可能掩盖 bug（cost 补偿了步进错误）→ 技术债永存；E-FP-05/06 裁决 = 明确地基状态，然后 FR-FP-02 net-cost 可安全进行。 |
| D6 | **空壳目录删除**（git 可恢复） | 保留占位 | **G14 卫生**：0 字节 `CMakeLists.txt` × 3 = 误导（新人以为有代码）；git 历史可恢复 = 删除无损；保留占位 = 技术债（需文档解释"为何空"）。 |
| D7 | **endcap 维持内联在 tap_cell** | 新建 endcap_cell 模块 | endcap 功能已工作（`tapcell.cpp:211-224`）；拆出去 = 平行重写风险 + 两模块协调成本；内联 = 简单可靠（tap 与 endcap 同属 well-tap 类操作）。 |
| **D8** | **先 harness（vs Innovus 面积差）再调 util** | 盲目定 util 默认 | **精度栈纪律**：无对照 = 不知道 util=0.55 与商业工具的差距（面积更大？更小？）；harness 数据 → 可归因调参（如 Innovus 面积平均小 8% → util 可适当提高）。对照：27 号文档 §3.2-D1"先 harness 再大改算法"。**被否原因**：盲调 util = 拍脑袋（可能让面积偏离商业基线）；G17 面积行需要可解释差异（harness 前置）。 |

---

## 4. LLD · 模块分解

### 4.1 ★ auto-die（FR-FP-04，P0）

**现状签名（真实）**：无；仅 `InitDesign::initDie(die_lx,…)`（`init_design.cpp:32-43`）。

```text
ALG-4.1-1  autoDie(util, aspect, force)
  [已有] initDie/initCore 手工路径（不动）
  ★ A_std = Σ area(movable_std) / util_std          # 仅 std-cell 用 util 折算
  ★ A_fixed = area(union(macro footprints, halos, hard blockages))  # 几何并集避免重复计数
  ★ A_reserve = A_io_ring + A_pdn + A_channel + A_whitespace
  ★ A_core = A_std + A_fixed + A_reserve
  ★ W,H = f(A_core, aspect)；core 对齐 site/row，die 对齐 manufacturing grid
  ★ feasibility loop（有界 3–5 轮）:
      fast_place_or_rudy(W,H) → {overflow,pin_access,macro_channel}
      若任一超预算：按瓶颈方向扩 W/H；禁止只降低一个全局 util 掩盖原因
  ★ 若 die 已非空且 force=false → ERROR（FR-FP-06/G14）
  ★ 写回 IdbDie + 可选自动 initCore 余量
  边界：零面积 / 无 site / util≤0 / 宏+halo 本身不可容纳 → 响亮失败
  复用姿势：Composition 调现有 initDie/initCore，禁止平行写 die
```

`A_io_ring/A_pdn/A_channel` 必须来自显式配置或上游约束并写入报告；未知项不得悄悄计为 0。快速可行性只用于选择尺寸，最终门禁仍由 iPL/iRT/iDRC 的独立结果给出。

### 4.2 ★ MacroConstraintModel（FR-FP-05，P0）

```cpp
// ★ 伪代码 —— 非现有类
struct MacroConstraint {
  std::string name;
  Box halo;
  double channel_n, channel_s, channel_e, channel_w;  // KH-FP-01
  std::optional<Point> hint_xy;
  IdbOrient orient;
};
// 写入 iDB PROPERTY / 专用表；iPL MacroPlacer（22 真化后）作硬约束+cost 读取
```

**禁止**：在 iFP 内跑 Metropolis/力导向。**复杂度** O(N_macro)。

### 4.3 IO / tap（B1/B2 修复 + 增强）

- **B1 修复**（先 E-FP-05 裁决）：左/右边 `width_step` → `height_step`。单行修复 + gtest（非方形 core 断言间距）。
- **B2 修复**（先 E-FP-06 裁决）：相交判定改为标准形式 `row_start_x > rect->get_high_x() || row_end_x < rect->get_low_x()`。单行修复 + gtest（左悬垂 blockage 用例）。
- **★ 约束槽位 IO 分配（P1，FR-FP-02）**：先按 side/layer/pitch 枚举合法槽位并剔除 blockage；固定 pin、side 限制、总线顺序、差分对相邻/对称、供电 pin 间距均作硬约束。自由 pin 的代价为 `flyline + w_t·criticality·distance + w_c·local_congestion + w_a·pin_access`，普通组用最小费用匹配，必须保序的 bus 用动态规划，最后以 `(pin_name, slot_id)` 确定性破同分。**前提**是 B1 修复落地（D5）。仅“按重心排序”不是可验收算法。
- **产物断言**：tap 后存在 PHY_/ENDCAP_ 实例；autoPlacePins 后 pin 全部 `is_placed` 且无重叠（O(pin²) 或排序扫描 O(n log n)）。

### 4.4 makeTracks 按 core（FR-FP-09，P1）

现状 `track_number` 按 die 宽/高（`init_design.cpp:131,140`）。两个选项：(a) 改按 core；(b) 论证 die 铺满是惯例并文档化。**先量** iRT 对 core 外 track 的消费行为再定（§14）。

### 4.5 空壳与测试（FR-FP-08，P0）

删除 `endcap_cell/io_router/macro_placer` 三空目录（D6/D7）；`test/` 建 gtest 骨架，首批用例 = §12 L0 全部。

### 4.6 模块状态一览

| 模块 | 现状成熟度 | 主复杂度 | 关键边界 | 复用姿势（现状→目标） |
|---|---|---|---|---|
| init_design | 教科书（145 LOC） | O(rows) | initDie 无校验（B5）；IO 带检查注释（B4） | 保留 + auto-die Composition |
| io_placer | **等间距无 cost**（668 LOC） | O(pins) | B1 步进疑似错；无容量/重叠检查 | 修复 B1 → P1 加 net cost |
| tap_cell | 成熟（301 LOC） | O(rows×blockage) | B2 相交疑似错边 | 修复 B2 + 断言 |
| endcap_cell/io_router/macro_placer | **空壳×3** | — | 误导 | 删除（D6/D7） |
| MacroConstraintModel ★ | 无 | O(N_macro) | 写 iDB 非旁路 | 新增 |
| auto-die ★ | 无 | O(N_inst) | 互斥/零面积响亮 | 新增（Composition initDie） |
| test/ | **零** | — | — | 从零建 |
| iPL 宏残迹（ipl_io/PLAPI/readme） | **假成功** | — | rc 恒 0 | **22 主责**，本工具只记录 |

---

## 5. 配置 / IterParam

| 键 | 默认 | 说明 |
|---|---|---|
| `auto_die.enable` | false | 零回归 |
| `auto_die.util` | 0.55 | KH-FP-02 |
| `auto_die.aspect` | 1.0 | |
| `auto_die.force` | false | 覆盖已有 die |
| `auto_die.reserve.{io,pdn,channel,whitespace}` | 必填或显式 0 | 分项面积预算，来源写入 Exhibit |
| `auto_die.max_feasibility_iters` | 5 | 快速拥塞/可达性校准上限 |
| `io.assignment_mode` | `legacy` | `legacy|constrained`；新模式缺省关 |
| `io.cost.{timing,congestion,pin_access}` | 0 | 归一化权重；硬约束不进入加权 cost |
| `macro_constraint.path` | "" | JSON/侧车 |

无多轮渐进（floorplan 单趟）；与 iPL IterParam 无关。

---

## 6. Cost / 指标分解

| 维 | 含义 | 记录 |
|---|---|---|
| util_realized | 实例面积/die | 独立列 |
| die_area_um2 | | 进 G17 面积差记录 |
| io_placed / io_overlap | IO 完成数 / 重叠数（B1 修复后应为 0） | 独立列 |
| tap_count / endcap_count | | 产物断言 |
| macro_constraint_count | | 交接计数 |
| wall_s_fp | | →42 |

禁止用「IO 完成」掩盖「宏未摆」。

---

## 7. 状态机 / 命令语义

```text
init → (initDie|auto_die) → initCore → makeTracks
    → place_io / tap → write_macro_constraints → ready_for_place
失败 rc≠0；缺 master / 互斥冲突 / 非法坐标 → ERROR（非 FATAL 崩进程优先）
```

---

## 8. 跨工具 Cascade

| 上/下游 | 信号 | 契约 |
|---|---|---|
| → iPL | die/core/row + MacroConstraint | round-trip C3（40） |
| → iPDN | core box | |
| → iRT | track（§4.4 裁决后冻结语义） | |
| ← 用户 | util/aspect | protocol 记录面积差（主纲 §1bis） |

---

## 9. 商业 Know-how 映射

| KH-ID | 本工具落点 |
|---|---|
| KH-FP-01（宏通道/halo） | §4.2 |
| KH-FP-02（util 默认） | §5 |
| KH-FP-03（IO–宏–std 分层） | §1.4 职责裁定；宏算法在 22 |
| KH-X-04（响亮失败） | B5/FR-FP-06/§7 |
| KH-PL-08（宏离散+连续） | 引用 22 |

---

## 10. 商业对照看板 + 演进

### 10.1 ★Innovus/ICC2 floorplan 精度看板（每次 FP 完成必填）

| 指标 | iFP | Innovus/ICC2 | Δ | 门槛 | 门禁 |
|---|---|---|---|---|---|
| die 面积 (mm²) | | | | 记录差异 | **G17** 面积行 |
| util 实现值 | | | | 0.50–0.70 可配 | — |
| auto-die 可用性 | 手工 | 自动 | — | util 可配 + 互斥失败 | G14 |
| IO placement 质量 | 等间距无 cost | net-driven | — | B1 修复 + cost-term-live | — |
| 宏约束闭环 | 单向（写 iDB） | 双向（FP↔place） | — | iPL 消费验证 | **G3** |
| tap/endcap 完成 | ✓ | ✓ | — | 产物断言 >0 | **G14** |
| IO/tap 假成功 | 0（断言后） | — | — | 0 | **G14** |
| 宏摆位假成功 | `run_mp` rc 恒 0 | — | — | ★记录债务归 22 | G14 |
| die/core 坐标合法性 | 有序/有限/core-in-die D2；IO 带和负坐标 snapping 待补 | 检查 | — | ★响亮失败 | G14 |
| FP 墙钟 | | | | ≤ 5s（≤50k inst） | — |

**看板纪律**：
- die 面积差记入 protocol **独立列**（不掩盖 WNS/拥塞等其他指标）；
- util 实现值 = A_cell / A_die（实测，非配置值）；
- 宏摆位假成功 = **22 主责**，iFP 只记录债务（不纳入 iFP G14 判定）。

### 10.2 ★对照实验（可杀假说，执行设计对标 24-iPL-3d §10.2 深度）

| ID | 输入 | 命令/操作 | 判据（数值阈值） | 杀死假说/锁住契约 |
|---|---|---|---|---|
| **E-FP-01** | 有宏设计（gcd 含 2 macro） | 只跑 iFP + iPL GP（不跑真 MP） | QoR（HPWL/拥塞/WNS）应仍差（不应"变好"） | 杀"FP 已够"假说（宏摆位必需） |
| **E-FP-02** | 同网表 | util=0.55 vs 0.75 跑完布局 | util=0.55 拥塞 < 0.75 拥塞（单调性）；若 0.55 仍拥塞 >10% → 改默认 | H-FP-1 util 模型校准（KH-FP-02） |
| **E-FP-03** | 有宏设计 | 约束置零 vs 全开（halo/channel） | iPL 宏解必变（位置/HPWL 差 >5%） | 约束 cost-term-live（G3） |
| **E-FP-04** | 已 initDie 的设计 | 再调 `auto_die` force=false | **rc ≠ 0**（必须失败）+ ERROR 日志 | 互斥响亮失败（FR-FP-06/G14） |
| **E-FP-05** | 非方形 core（W:H=2:1） | `autoPlacePins`，量左/右边相邻 pin 纵距 | =core_h/(edge_num+1)，且全部 placed/无重叠 | B1 设计级回归 |
| **E-FP-06** | 构造行左端悬垂 blockage | `tapCells`，检查悬垂区 `[row_start, row_start+50]` | 悬垂区无 PHY_/ENDCAP_ | B2 设计级回归 |
| **E-FP-07** | 标准设计 | `makeTracks`，量 core 外 track 是否被 iRT 使用 | iRT 消费 core 外 track 比例；>0 → die 策略合理；=0 → 改按 core | track 生成策略裁决（FR-FP-09） |
| **E-FP-08** | 同设计、固定 seeds | IO legacy vs constrained，跑完整布局/布线/STA | 逐设计独立报告 flyline、overflow、pin-access DRC、WNS/TNS；以 bootstrap 95% CI 与预注册最小效应判断，CI 跨 0 则“不确定、扩样”，不得用单一 WNS 或留下 20–50 ps 空档 | IO 分配收益与副作用（H-FP-2） |

**实验设计原则**（对标 27-iSTA / 30-iDRC）：
1. **可控输入**：非方形 core（E-FP-05）、悬垂 blockage（E-FP-06）= 制造触发条件；
2. **机械判据**：纵距数值比较、rc≠0、存在性检查（非目视）；
3. **锁住边界**：E-FP-04 的互斥失败 = G14 纪律验证；E-FP-07 的 track 策略 = 澄清 die vs core 歧义。

**E-FP-05 详细执行步骤**（示例）：
```bash
# 构造非方形 core（2:1 比例）
ieda> init_die 0 0 2000 1000    # W=2000um, H=1000um（2:1）
ieda> init_core 100 100 1900 900
ieda> auto_place_pins -io_list pins.txt

# 量左边相邻 pin 纵距（预期 = core_h / (edge_num+1) = 800 / (N+1)）
python3 check_io_spacing.py left_pins.csv
# 若实测纵距 = core_w / (edge_num+1) = 1800 / (N+1) → 实锤 B1 bug
```

### 10.3 演进 M0–M4

| 里程碑 | 目标 | 退出门禁 |
|---|---|---|
| **M0 先量** | 空壳×3 删除 + 假成功台账；E-FP-05/06 裁决 B1/B2；确认全流程宏不动（E-FP-01）；vs Innovus 面积差首次记录（harness 骨架） | 台账 + B1/B2 裁决记录 + E-FP-01 数据 |
| **M1 可信** | B1/B2 修复（若裁决为真 bug）+ gtest 骨架；MacroConstraint→iDB 写入 + iPL 只读验证；rows/core round-trip（契约 C3） | T-A1/A2（§12）+ 约束可读 |
| **M2 主算法** | auto-die TCL/Python API；互斥失败（E-FP-04）；产物断言（tap/IO 完成性）；E-FP-07 track 策略裁决 | T-B1/B2（§12）+ E-FP-04 绿 |
| **M3 打平** | 五套 daily vs Innovus 面积差（记入 protocol）；与 place_opt 并排拥塞/DRC；IO net-cost（若 E-FP-08 支持 P1） | **G17 面积行**可解释差异 |
| **M4 纵深** | 多电压域/UPF 预留（Phase C）；宏约束与 iPL 真化联调（G3 候选） | 非本阶段阻断 |

---

## 11. Exhibit

| 档 | 产物 |
|---|---|
| text | `fp_summary.txt`（die/core/util/io/tap） |
| CSV | `fp_macros_constraints.csv`、`fp_io_pins.csv`（pin,side,x,y,layer——B1 回归用） |
| JSON | `fp_qor.json` → 12 schema |
| plot | 可选 die/IO 简图 |

---

## 12. 测试计划（全树从零）

| 层 | 用例 | 锁住 |
|---|---|---|
| L0 | auto-die 零面积/无 site 失败 | §4.1 |
| L0 | 互斥 initDie+auto_die | FR-FP-06 |
| L0 | 非方形 core 左/右 pin 纵距 | B1（E-FP-05） |
| L0 | 行左悬垂 blockage 无 PHY_ | B2（E-FP-06） |
| L0 | initDie 非法坐标拒 | B5 |
| L1 | gcd：tap 后存在 PHY_/ENDCAP_ | FR-FP-03 |
| L1 | 约束写入后 iPL 可读 | FR-FP-05 |
| L4 | 五套 daily util/面积记账 | G17 |
| L5 | 空壳命令/假 MP 不可假成功 | G14 |

---

## 13. 里程碑（按周粗估）

| 周 | 交付 | 验收 |
|---|---|---|
| W0 | 台账 + E-FP-05/06 裁决 + 空壳删除 | M0 |
| W1 | B1/B2 修复 + gtest 骨架 + MacroConstraint PR | M1 |
| W2 | auto-die + 互斥 + 产物断言 | M2 |
| W3+ | 与 22 宏真化联调；IO net-cost | G3 候选 / M3 |

PR 切片：FP-0 台账+空壳删除 → FP-1 B1/B2 修复+gtest → FP-2 MacroConstraint 读写 → FP-3 auto_die → FP-4 产物断言 → FP-5 iPL round-trip。

---

## 14. 未验证 / 负面结论 / 兄弟仓库

### 14.1 未验证（禁止写成事实）

| # | 项 | 说明 |
|---|---|---|
| 1 | B1/B2 设计级闭环 | 纯几何测试通过；尚未用完整 iDB 设计产物执行 E-FP-05/06 |
| 3 | `placePort`/`autoPlacePad`/`autoIOFiller` 生产调用路径 | 仅 pad flow 相关，未验证 |
| 4 | makeTracks 按 die 是否为惯例 | 需读 iRT track 消费（E-FP-07）；若 iRT 不用 core 外 track → 应改按 core |
| 5 | io_router 空壳：商业有 IO 布线，本仓是否立项 | 随 pad flow 需求，未决 |
| 6 | UPF/多电压 | 后置 Phase C；不要提前承诺 |
| 7 | fork 3D iFP auto-die diff | 禁止未审计照搬（单一 3D 代码库纪律） |
| 8 | **util=0.75 在密集设计实测拥塞** | D2 决策引用但未实测；E-FP-02 校准前不作事实 |
| 9 | **auto-die 面积模型与实际拥塞/DRC 的关系** | util=0.55 默认值**未校准**（§1.5-#3）；需 harness 数据（E-FP-02）才能调参 |
| 10 | **IO net-driven vs 等间距的 WNS 差** | H-FP-2 假说待 E-FP-08 裁决；差 <20ps → P2；>50ps → P0 |
| 11 | **MacroConstraint 与 iPL 消费侧闭环** | 约束写 iDB 了，但 iPL MacroPlacer（22 真化前）是否读取**未验证**（§1.5-#9） |
| 12 | **vs Innovus/ICC2 面积差首轮数据** | harness 骨架未建（§1.5-#15）；G17 面积行基线缺失 |

### 14.2 负面 / 不要重走（被否方案 + 技术债教训）

| 项 | 结论 |
|---|---|
| **不要在 iFP 再写一套 MacroPlacer「补空壳」** | **禁止**——与 22 职责冲突且加倍债（两套宏算法需维护）；D1 铁律：宏算法归 iPL，iFP 只交约束（§3.2-D1） |
| **不要在 B1 未裁决的等间距骨架上叠 net-cost** | **禁止**——地基疑似歪，先量后建（D5）；在错的步进上加 cost = 可能掩盖 bug → 技术债永存 |
| **不要把 endcap 从 tap_cell 拆去填空壳目录** | **不推荐**——内联实现已工作（`tapcell.cpp:211-224`），拆 = 平行重写风险（D7） |
| **不要盲目定 util 默认值（无 harness 数据）** | **禁止**——无对照 = 不知道与 Innovus 差距（D8）；拍脑袋定参 → G17 面积行无依据 |
| **不要静默覆盖已有 die（auto-die 与 initDie 冲突时）** | **禁止**——调试地狱（不知道最终 die 来源）；D3 互斥响亮失败 = 一次失败胜过十次猜测 |
| **不要保留空壳目录「占位」** | **禁止**——0 字节 CMakeLists × 3 = 误导新人（以为有代码）；git 历史可恢复，删除无损（D6） |
| **不要用 iFP 宏相关指标宣称 G3 转绿** | **禁止**——G3 主责在 iPL 宏真化（22）；iFP 只做约束交接（§1.4 职责裁定） |
| **不要跳过 die 坐标合法性检查「为了快」** | **禁止**——基础有序/有限校验已经接入，后续还必须补 IO 带与负坐标 site snapping 语义，不能以秒级为由省略 |

**负面结论共同模式**：
- **职责边界清晰** > 功能全覆盖（宏算法归 22、iFP 不实现 SA）；
- **地基修好再建楼** > 在疑似 bug 上叠优化（B1/B2 裁决先于 net-cost）；
- **有数据再调参** > 拍脑袋定默认（harness 先于 util 调参）。

### 14.3 兄弟仓库（iEDA-3D fork）实测发现——本树待复核

以下结论在 `HS-3D_Problem/thirdparty/iEDA-3D` 的实测中坐实（见其项目记忆与相关文档），**本树（iEDA.ai）代码同源但行号/行为需复核，未验证前不当事实用**：

| 发现 | 兄弟仓库证据 | 本树复核动作 |
|---|---|---|
| auto-die util 模型在 3D 场景需两层分配策略 | 3D 分支有 `auto_die_3d` 差异；单层 util 公式不适用堆叠 | 单一 3D 代码库纪律（`ieda3d-single-3d-codebase.md`）：**禁止未审计照搬**；若需 3D auto-die → 单独设计 + 文档化 |
| iFP → iPL 的 row/core 数据可能在 3D 有 tier 属性遗漏 | 3D 流程 iDB 有 tier_id；iFP 是否写全**未验证** | 复核本树 `initCore` 是否有 tier 相关参数（单一 3D 代码库：2D 退化基态保留，不强制 tier） |
| 空壳目录在 fork 分支也是 0 字节（一致性） | 与本树一致；说明空壳非本地改动 | 确认：空壳删除决策（D6）适用全仓库（含 fork） |

---

## 附录 A · 术语

| 词 | 义 |
|---|---|
| auto-die | 由单元面积与 util 推 die 尺寸 |
| MacroConstraint | 非算法摆位的硬/软约束交接 |
| 空壳目录 | 仅 0 字节 CMakeLists 的模块目录；本工具 3 个 |
| B1/B2 | §1.3 两个已确认并完成代码修复的基础几何 bug；设计级 E-FP-05/06 仍待补 |

## 附录 B · 决策记录

| # | 决策 | 被否 |
|---|---|---|
| E-1 | 宏算法归 iPL | iFP 实现宏 SA |
| E-2 | util 保守默认 | 高 util 默认 |
| E-3 | 先裁决 B1/B2 再增强 IO | 在疑似错的骨架上叠 cost |
| E-4 | 空壳×3 删除；endcap 留 tap_cell 内联 | 填空壳 / 拆 endcap |
| E-5 | 多电压后置 | Phase A 做 UPF |

## 附录 C · auto-die 数值例（假说，待测）

仅作 std-cell 子预算示例：设 `A_std_raw=1.0e6 µm²`、`util_std=0.55`，则 `A_std≈1.82e6 µm²`；还必须加宏/halo/blockage 几何并集以及 IO/PDN/channel/whitespace reserve，之后才由 aspect 求 W/H 并分别对齐 site 与 manufacturing grid。**杀死实验**：若分项模型对 holdout 设计的 overflow/pin-access/DRC 无预测力，则调整 reserve/可行性模型，而不是只改一个全局 util。

## 附录 D · 证据摘录（file:line 最小集）

| 断言 | 证据 |
|---|---|
| initDie API / 实现 | `ifp_api.h` / `init_design.cpp`（有限数、有序矩形、DB/layout/die/DBU 后矩形校验） |
| transUnitDB -1 哨兵 | `init_design.cpp:24-30` |
| initCore / 交错行 / IO 带注释 | `init_design.cpp:45-101` / `:88` / `:73-78` |
| makeTracks 按 die | `init_design.cpp:131,140` |
| autoPlacePins 等间距无 cost | `io_placer.cpp:84-290`（edge_num `:133`、width_step `:137`） |
| B1 修复 | `FloorplanGeometry.hh::makePinPitch` + `io_placer.cpp`（左/右边 `height_step`） |
| tapCells 流程 | `tapcell.cpp:34-77`；master 查空 `:62-65`；ENDCAP_/PHY_ `:211-270` |
| B2 修复 | `FloorplanGeometry.hh::intersectsClosed` + `tapcell.cpp::buildRegionInRow` |
| 空壳×3 | `iFP/.../{endcap_cell,io_router,macro_placer}/CMakeLists.txt` 均 0 字节 |
| 几何合同测试 | `iFP/test/FloorplanGeometryTest.cc`；CMake target `ifp_floorplan_geometry_test` |
| 假成功链路 | `tcl_ipl.cpp:257-265` → `platform/tool_manager/tool_api/ipl_io/ipl_io.cpp:170-181`（全注释 `return true`）→ `PLAPI.cc:517-522`（全注释）→ `iPL/.../macro_placer/readme.md`（一行） |
| iFP 全树体量 | `find src/operation/iFP -name '*.cpp' -o ... | xargs wc -l` = 1636 |
