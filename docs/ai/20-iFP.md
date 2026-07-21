<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 20 · iFP 布图规划 · 商业对标优化方案 · rv1.1

> 文档号：20-rv1.1　　版本：v3.0（大改，逐文件代码走读后重写）　　里程碑：**手工 die/三个空壳目录 → auto-die + 宏约束交接 iPL + IO/tap/track 自动化对标 floorplan**
> 体例：`01-ai-doc-conventions-rv1.md`（对齐 `24-iPL-3d-rv1.0.md` 走读深度）
> 主纲：`00-ieda-commercial-parity-master-plan-v1.1.md`（G3/G14/G2 交接、G17 面积行）
> Know-how：`03-commercial-knowhow-catalog.md`（KH-FP-01/02/03、KH-X-04）
> 上游：网表/LEF　下游：`22-iPL`、`24-iPDN`　对标：**Innovus / ICC2 floorplan**
> 覆盖：`src/operation/iFP/` 全树（1636 LOC）+ iPL 侧宏残迹（`PLAPI.cc`、`platform/.../ipl_io.cpp`、`tcl_ipl.cpp`）
> 纪律：**文档是假说不是事实**；断言带 `file:line`；未实测写「未验证」。

---

## 0. 变更记录

| 版本 | 日期 | 修订人 | 说明 |
|---|---|---|---|
| v1.0–v1.1 | 2026-07-20 | parity | 宏空壳；无 auto-die；职责裁定摘要 |
| rv1.0 / v2.0 | 2026-07-20 | parity | 体例对齐；坐实 iFP macro 空壳 + iPL `return true` 假成功 |
| **rv1.1 / v3.0** | **2026-07-21** | parity | **大改**：对 iFP 全树 14 个源文件（1636 LOC）+ iPL 宏残迹逐行读完重写。核心修订五条，**三条推翻/深化 v2.0**：**(1)** 空壳目录**不止 `macro_placer/` 一个**——`endcap_cell/`、`io_router/`、`macro_placer/` **三个模块目录都只有 0 字节 `CMakeLists.txt`**（v2.0 把 endcap 判为"与 tap 协同"、io_router 判为"能力边界未验证"，实测两者**没有任何代码**；endcap 功能实际是内联在 `tapcell.cpp:211-224` 的 ENDCAP_ 插入里）;**(2)** v2.0 判 io_placer "有实现，飞行线 cost 未验证"——**过誉**：`autoPlacePins`（`io_placer.cpp:84-290`）**没有任何 cost 函数**，是按 pin_list 顺序绕 die 四边**等间距排布**的教科书摆法；且左/右两边的纵向步进用的是 **`width_step`（由 core 宽推出）而非 `height_step`**（`:146`、`:183`，疑似复制粘贴 bug，§1.3-B1，待 E-FP-05 裁决）;**(3)** `makeTracks` 的 track 条数按 **die 宽高**而非 core 计算（`init_design.cpp:131,140`），v2.0 未审到;**(4)** iPL 宏假成功的精确链路坐实：TCL `CmdPlacerRunMP`（`tcl_ipl.cpp:257-265`）→ `PlacerIO::runMacroPlacement`（`platform/tool_manager/tool_api/ipl_io/ipl_io.cpp:170-181`，**函数体全注释，无条件 `return true`**）→ `PLAPI::runMP`（`PLAPI.cc:517-522`，**整体注释**）→ `macro_placer/readme.md`（**一行 `# Macro Placer`**）;**(5)** `tapcell.cpp` 的 blockage 相交判定用错矩形边（`:120-123`，疑似漏判行左端悬垂 blockage，§1.3-B2，待 E-FP-06 裁决）。本版保留 v2.0 的 auto-die + MacroConstraintModel 设计（§4.1/§4.2），全部缺省关闭 → 零回归。 |

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
| **test/** | **仅 `CMakeLists.txt`，零用例** | **全树无测试** |

### 1.2 算法成熟度（逐 kernel）

| kernel | 现状算法（file:line） | 判定 | 缺口 |
|---|---|---|---|
| `InitDesign::initDie` | 用户四角 → `IdbDie` 两点（`init_design.cpp:32-43`）；**恒 return true，无任何校验** | 教科书操作 | 无 auto-die；无非法坐标检查 |
| `InitDesign::initCore` | site 对齐取整 + 建行（奇偶行 `kFS_MX`/`kN_R0` 交错，`:88`） | 成熟 | **IO 带检查被注释**（`:73-78` "error report, tbd"）——core 贴着 die 边建 row 无防线 |
| `InitDesign::makeTracks` | pitch/offset 写 track grid（`:114-144`） | 可用 | **track 条数按 die 宽/高算**（`:131`、`:140`）而非 core——core 外也铺 track，与 LEF TRACKS 并存策略未验证 |
| `IoPlacer::autoPlacePins` | **pin_list 顺序绕四边等间距**（`:84-290`）：`edge_num=⌈pin/side⌉`，`width_step=core_w/(edge_num+1)` 对齐 manufacture_grid；左→右→下→上依次填 | **教科书以下**——**无飞行线、无连通性、无 cost**，pin 顺序即网表顺序 | 商业 IO 规划的最基本项（net 驱动）整体缺失；左/右边疑似用错步进（§1.3-B1） |
| `IoPlacer::placePort` / `placeIOFiller` / `fillInterval` | 定点 port（`:292`）；pad 区间填 filler（`:353/:431`） | 有实现 | 生产调用路径未验证 |
| `IoPlacer::autoPlacePad` / `set_pad_coords` / `autoIOFiller` | pad 环摆位（`:491/:577/:642`） | 有实现 | 仅 pad flow 用；未验证 |
| `TapCellPlacer::tapCells` | 间距 snap site 倍数（`checkDistance :40-54`）→ master 查空（`:62-65`）→ 按行减 blockage 建区间（`buildTapcellRegion :84`）→ 插 ENDCAP_/PHY_（`insertCell :194-270`） | **成熟**（全树最佳） | master 缺 → `return false`（正确响亮）；但 blockage 相交判定疑似错边（§1.3-B2） |
| `InitDesign::transUnitDB` | 单位换算（`:24-30`） | 可用 | layout 空时返回 **-1 哨兵**（静默，调用方不查） |

### 1.3 边界 / 回退 / 疑似 bug（★=带杀死实验）

- **B1 ★（疑似）`autoPlacePins` 左/右边纵向步进用 `width_step`**：`:146`（left）`y = core_low_y + i * width_step`、`:183`（right）同式；而 `width_step = core_width/(edge_num+1)`（`:137`）。bottom/top 边横向用 `width_step` 是对的（`:211/:247`），左/右边纵向应为 `height_step`。非方形 core 上左/右 pin 纵向分布错误（过密重叠或越出 core 高）。**杀死实验 E-FP-05**：W≠H 的 core（如 2:1）跑 autoPlacePins，量左/右边相邻 pin 纵向间距是否等于 `core_h/(edge_num+1)`；不等即实锤。
- **B2 ★（疑似）`buildRegionInRow` blockage 相交判定用错矩形边**（`tapcell.cpp:120-123`）：
  ```cpp
  if (idb_row_end_y < rect->get_low_y() || idb_row_start_y > rect->get_high_y()
      || idb_row_start_x > rect->get_low_x()        // ← 应为 rect->get_high_x()
      || idb_row_end_x < rect->get_high_x()) {      // ← 应为 rect->get_low_x()
    continue;   // 判"不相交"
  }
  ```
  x 向两条比较用错了 rect 的边：行起点在 blockage 左缘之右（含 blockage 左悬垂进行的情形）会被判"不相交"而跳过 → tapcell 可能插进 blockage 左悬垂区。**杀死实验 E-FP-06**：构造 blockage 覆盖行左端 `[row_start-100, row_start+50]`，跑 tapCells，检查 `[row_start, row_start+50]` 内是否出现 PHY_/ENDCAP_。
- **B3** `checkDistance`（`:40-54`）按引用 snap `inst_space` 到 site 倍数，**返回值的语义是"没 snap"**，`tapCells` 在 `:56` 丢弃该返回值——逻辑无错但接口反直觉，重构候选。
- **B4** `initCore` 的 IO 带检查整段注释（`:73-78`）：core 边界压 die 边界时无报错路径。
- **B5** `initDie` 恒 true（`:42`）：非法坐标（ll>ur、负值）不拒。
- **假成功链路（坐实，G14）**：`tcl_ipl.cpp:257-265` `CmdPlacerRunMP::exec` → `ipl_io.cpp:170-181` 函数体全注释 `return true` → `PLAPI.cc:517-522` 全注释 → `macro_placer/readme.md` 一行。**`run_mp` 命令对任何设计都 rc=0 且零效果。**
- **空壳目录×3**（§1.1）+ **全树零测试**（test/ 仅 CMakeLists）。

### 1.4 跨工具协调

| 方向 | 现状 | 判定 |
|---|---|---|
| iFP → iPL | die/core/row/track 经 iDB 消费；宏位靠手工或假 MP | 宏通道债务推到 GP（KH-FP-03） |
| iFP → iPDN | core 边界供 strap | 半通 |
| iFP → iRT | track/IO pin | 半通（track 按 die 算，§1.2） |
| iFP → 平台契约 C3 | rows/core round-trip（40 §7.2） | 待测 |
| iPL 宏残迹 → iFP | 假成功命令 `run_mp` 挂在 iPL 名下 | **归 22 主责**，iFP 只交约束（v2.0 裁定保留） |

**职责裁定（保留 v2.0 铁律）**：宏算法归 iPL（22）；iFP 只做 halo/通道/orient/hint 约束模型 → iDB。auto-die 新增于 init_design，与 initDie 互斥响亮失败。IO/tap 保持增强，先补产物断言与 B1/B2 裁决。

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
| NFR-FP-02 | util 默认 | 0.55–0.60 可配（KH-FP-02） |
| NFR-FP-03 | 假成功 | 0（空壳命令/假 MP 须非成功 rc） |
| NFR-FP-04 | iFP gtest | 从零 ≥ §12 所列用例 |

### 2.3 红线

- **禁止**在 iFP 平行重写宏 SA/力导向（归 22）。
- **禁止**宣称 G3 转绿仅靠 iFP（G3 主责 iPL 宏真化）。
- 新特性缺省关闭 → **零回归**。

---

## 3. HLD 总体架构

### 3.1 数据流

```text
LEF/网表
  → init_design: initDie | ★auto_die → initCore → makeTracks(★按 core?)
  → io_placer(★B1 修复 / ★net-cost P1) / tap_cell(★B2 修复)
  → ★ MacroConstraintModel (halo/channel/orient/hint) → iDB 属性
  → 【iPL】MacroPlacer 消费约束产合法宏解（22，现假成功）
  → iPDN / iRT
```

### 3.2 关键设计决策（含被否）

| # | 决策 | 被否 |
|---|---|---|
| D1 | 宏算法归 iPL；iFP 只约束 | 在 iFP 实现 SA 宏摆位 |
| D2 | auto-die 默认 util=0.55–0.60 | 激进 util≥0.75 默认 |
| D3 | auto-die 与 initDie 互斥响亮失败 | 静默覆盖坐标 |
| D4 | 约束写 iDB 属性，不另起平行 DB | 仅 JSON 旁路 |
| D5 | **先裁决 B1/B2 两个疑似 bug，再谈 IO 算法增强** | 在疑似错的等间距骨架上叠 cost |
| D6 | 空壳目录删除（git 可恢复），test/ 从零建 | 保留占位 |
| D7 | endcap 维持内联在 tap_cell，不为空壳目录取而代之建平行模块 | 新建 endcap_cell 模块 |

---

## 4. LLD · 模块分解

### 4.1 ★ auto-die（FR-FP-04，P0）

**现状签名（真实）**：无；仅 `InitDesign::initDie(die_lx,…)`（`init_design.cpp:32-43`）。

```text
ALG-4.1-1  autoDie(util, aspect, force)
  [已有] initDie/initCore 手工路径（不动）
  ★ A_cell = Σ area(std) + Σ area(macro)          # O(N_inst)
  ★ A_die  = A_cell / util                         # util∈[0.40,0.85]，默认 0.55
  ★ W,H = f(A_die, aspect) → 对齐 manufacture_grid / site
  ★ 若 die 已非空且 force=false → ERROR（FR-FP-06/G14）
  ★ 写回 IdbDie + 可选自动 initCore 余量
  边界：零面积 / 无 site / util≤0 → 响亮失败
  复用姿势：Composition 调现有 initDie/initCore，禁止平行写 die
```

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
- **★ net 驱动 IO cost（P1，FR-FP-02）**：在等间距骨架上加 net 重心吸引项——pin 的候选位按 incident net 的内部连接重心排序（cost-term-live 单测：置零该项解必变）。**前提**是 B1 修复落地（D5）。
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

## 10. 商业对照看板 + 演进 M0–M4

### 10.1 看板

| 指标 | iEDA iFP | Innovus/ICC2 FP | 门槛 | 门禁 |
|---|---|---|---|---|
| util 可达/可配 | 手工 | 自动+可配 | 可配；不过密 | — |
| IO 摆位质量 | 等间距无 cost | net 驱动 | B1 修复 + cost-term-live | — |
| 宏通道合法 | 约束缺口 | 内建 | iPL G3 | G3 |
| IO/tap 完成 | 有 | 有 | 产物断言 | G14 |
| die 面积差 | 记入 protocol | — | 独立列不掩 WNS | G17 |
| 假成功命令 | `run_mp` rc 恒 0 | — | 0 | G14 |

### 10.2 对照实验（杀假说）

| 实验 | 方法 | 杀死条件 |
|---|---|---|
| E-FP-01 | 有宏设计只跑 iFP 不跑真 MP | 若 QoR「变好」→假说「FP 已够」被杀；应仍差 |
| E-FP-02 | auto-die util=0.55 vs 0.75 | 拥塞/DRC 单调性 |
| E-FP-03 | 约束置零 vs 全开 | iPL 宏解必变（cost-term-live） |
| E-FP-04 | initDie 后再 auto_die force=false | 必须非零失败 |
| **E-FP-05** | 非方形 core 跑 autoPlacePins 量左/右 pin 纵距 | =core_h/(edge+1) → B1 被杀；≠ → 实锤修复 |
| **E-FP-06** | 行左端悬垂 blockage 跑 tapCells | 悬垂区无 PHY_ → B2 被杀；有 → 实锤修复 |

### 10.3 演进

```text
M0 先量：空壳×3/假成功/零测试台账；E-FP-05/06 裁决 B1/B2；确认全流程宏不动
M1 可信：B1/B2 修复+gtest；MacroConstraint→iDB + iPL 只读；rows/core round-trip
M2 主算法：auto-die TCL/Python；互斥失败；产物断言
M3 打平：与 place_opt 并排面积/拥塞（面积差记账）；IO net-cost（P1）
M4 纵深：多电压域/UPF 预留（Phase C）
```

退出门禁：M0→台账+B1/B2 裁决记录；M1→T-A；M2→T-B；M3→G17 面积行可解释；M4→非本阶段阻断。

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

## 14. 未验证 / 负面结论

| # | 项 | 说明 |
|---|---|---|
| 1 | B1（左/右边 width_step） | 代码走读高度疑似，E-FP-05 裁决前标「疑似」 |
| 2 | B2（blockage 相交错边） | 同上，E-FP-06 裁决 |
| 3 | `placePort`/`autoPlacePad`/`autoIOFiller` 生产调用路径 | 仅 pad flow 相关，未验证 |
| 4 | makeTracks 按 die 是否为惯例 | 需读 iRT track 消费（§4.4） |
| 5 | io_router 空壳：商业有 IO 布线，本仓是否立项 | 随 pad flow 需求，未决 |
| 6 | UPF/多电压 | 后置；不要提前承诺 |
| 7 | fork 3D iFP auto-die diff | 禁止未审计照搬 |

**不要重走**：
- 不要在 iFP 再写一套 MacroPlacer「补空壳」——与 22 冲突且加倍债。
- 不要在 B1 未裁决的等间距骨架上叠 net-cost——地基疑似歪，先量后建。
- 不要把 endcap 从 tap_cell 拆去填空壳目录——内联实现已工作，拆=平行重写风险。

---

## 附录 A · 术语

| 词 | 义 |
|---|---|
| auto-die | 由单元面积与 util 推 die 尺寸 |
| MacroConstraint | 非算法摆位的硬/软约束交接 |
| 空壳目录 | 仅 0 字节 CMakeLists 的模块目录；本工具 3 个 |
| B1/B2 | §1.3 两个疑似 bug 编号（待 E-FP-05/06 裁决） |

## 附录 B · 决策记录

| # | 决策 | 被否 |
|---|---|---|
| E-1 | 宏算法归 iPL | iFP 实现宏 SA |
| E-2 | util 保守默认 | 高 util 默认 |
| E-3 | 先裁决 B1/B2 再增强 IO | 在疑似错的骨架上叠 cost |
| E-4 | 空壳×3 删除；endcap 留 tap_cell 内联 | 填空壳 / 拆 endcap |
| E-5 | 多电压后置 | Phase A 做 UPF |

## 附录 C · auto-die 数值例（假说，待测）

设 Σarea=1.0e6 µm²，util=0.55 → A_die≈1.82e6；aspect=1 → W=H≈1348 µm；再对齐 site（如 0.46 µm）取整。
**杀死实验**：同一网表 util=0.55 vs 手工偏小 die → 后者 overflow/拥塞应显著更差，否则 util 模型假。

## 附录 D · 证据摘录（file:line 最小集）

| 断言 | 证据 |
|---|---|
| initDie API / 实现 | `ifp_api.h:47` / `init_design.cpp:32-43`（恒 true `:42`） |
| transUnitDB -1 哨兵 | `init_design.cpp:24-30` |
| initCore / 交错行 / IO 带注释 | `init_design.cpp:45-101` / `:88` / `:73-78` |
| makeTracks 按 die | `init_design.cpp:131,140` |
| autoPlacePins 等间距无 cost | `io_placer.cpp:84-290`（edge_num `:133`、width_step `:137`） |
| B1 疑似 | `io_placer.cpp:146,183`（左/右边 `i * width_step`） |
| tapCells 流程 | `tapcell.cpp:34-77`；master 查空 `:62-65`；ENDCAP_/PHY_ `:211-270` |
| B2 疑似 | `tapcell.cpp:120-123`（相交判定错边） |
| 空壳×3 | `iFP/.../{endcap_cell,io_router,macro_placer}/CMakeLists.txt` 均 0 字节 |
| 零测试 | `iFP/test/` 仅 `CMakeLists.txt` |
| 假成功链路 | `tcl_ipl.cpp:257-265` → `platform/tool_manager/tool_api/ipl_io/ipl_io.cpp:170-181`（全注释 `return true`）→ `PLAPI.cc:517-522`（全注释）→ `iPL/.../macro_placer/readme.md`（一行） |
| iFP 全树体量 | `find src/operation/iFP -name '*.cpp' -o ... | xargs wc -l` = 1636 |
