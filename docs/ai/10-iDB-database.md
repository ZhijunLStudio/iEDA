<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 10 · iDB 数据库 · 商业对标优化方案 · rv1.1

> 文档号：10-rv1.1　　版本：v3.0（大改，逐文件代码走读后重写）　　里程碑：**二进制 GDS 可流片 + 无损往返矩阵 + 容量爬坡（G13）**
> 体例：`01-ai-doc-conventions-rv1.md`（对齐 `HS-3D_Problem/thirdparty/iEDA-3D/docs/3d/design/24-iPL-3d-rv1.0.md` 的逐 kernel 走读深度）
> 主纲：`00-ieda-commercial-parity-master-plan-v1.1.md`（G1/G13/G16）　Know-how：`03-commercial-knowhow-catalog.md`（KH-DB-01/02/03）
> 上游：LEF/DEF/Verilog/SDC/Liberty 等输入文件　下游：**全部工具**（iDB 是全流程唯一共享数据模型）
> 覆盖：`src/database/manager/builder/`（12.6k LOC）、`src/database/manager/parser/`（11 格式目录）、`src/database/manager/{memory,service}`、`builder/gds_builder/`、`parser/gdsii/`
> 纪律：**文档是假说不是事实**；每条断言带 `file:line`；未实测写「未验证」。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.0–v1.1 | 2026-07-20 | GDS 文本风险摘要 |
| rv1.0 / v2.0 | 2026-07-20 | 坐实 `Def2GdsWrite` 持 `GdsiiTextWriter`（`gds_write.h:107`）、`GTWriter.cpp:126` 写 ASCII `"HEADER "` |
| **rv1.1 / v3.0** | **2026-07-21** | **大改**：对 `builder/`（12572 LOC）+ `parser/gdsii/`（2201 LOC）+ `gds_write.{h,cpp}`（138+858 LOC）逐文件读完重写。核心修订五条，**其中三条推翻/深化 v2.0 的判定**：**(1)** GDS 问题比 v2.0 认定的更严重——不是"文本格式不对"一个缺陷，而是**四重叠加**：文本 writer + **坐标单位换算函数是死代码**（`gds_write.h:122-126` `transDB2Unit` 第一句 `return value;` 使第二句永不可达，21 处调用全部原样透传 DBU，而 UNITS 声明却是 `1.0/_unit_microns`——**声明与坐标自相矛盾**）+ 无 GDS reader（全仓 grep `GdsReader/GTReader/readGds/loadGDS` **零命中**，"往返"根本无从谈起）+ TCL 层丢弃失败返回值（`tcl_db_file.cpp:385-398` `CmdSaveGDS::exec` 无视 `saveGDSII` 的 bool，恒 `return 1`，G14 假成功）;**(2)** v2.0 称"SDC ✓ 读"——**错**，`parser/` 下无 sdc 目录，SDC 由 iSTA `TimingEngine::readSdc` 消费，**不在 iDB 数据模型内**（对 G16 session 序列化是缺口）;**(3)** `manager/memory/` 是**空壳目录**（仅一个 0 字节 `CMakeLists.txt`），v2.0 §DB3"大设计内存未爬坡"连基础设施都不存在;**(4)** `Def2GdsWrite` 的类结构是 **DEF writer 的换皮移植**：`write_version/write_design` 产出名为 `"VERSION"`/`"Design Name"`/`"DIEAREA"` 的 GdsStruct 并把版本号当 `GdsText` 写进版图（`gds_write.cpp:124-176`）——这是**可视化调试产物**，不是 tapeout 语义;**(5)** parser 层已 Rust 化（liberty/spef/verilog/vcd 四个 Rust parser + C 桥），往返矩阵必须把 Rust 桥纳入断言面。 |

---

## 1. 症结审计（逐文件代码走读）

对 `src/database/manager/builder/` 全部 7 个子目录（def_builder `def_read.cpp` 2330 / `def_write.cpp` 1455、verilog_builder `verilog_read.cpp` 1107 / `verilog_write.cpp` 541、json_builder `json_write.cpp` 952、gds_builder `gds_write.{h,cpp}` 138+858、lef_builder、buildLefData/buildBus/buildNet/builder 本体）、`parser/gdsii/` 全部 21 个文件（2201 LOC）、`parser/` 其余 10 个格式目录、`manager/{service,memory}`、以及 TCL 入口 `tcl_db_file.cpp` 逐一读完后的判定。

### 1.1 功能形态——读写能力矩阵（实测，非推测）

| 格式 | 读 | 写 | 证据 | 判定 |
|---|---|---|---|---|
| LEF | ✓（lef_builder + third_party lefdef） | ✓（`builder.h:82 saveLef`） | `buildLefData.cpp`、`lef_builder/property_parser/` | 主路径成熟；**写出版本/属性保真未验证** |
| DEF | ✓ `def_read.cpp`（2330 LOC） | ✓ `def_write.cpp`（1455 LOC，`DefWriteType` 分档 `def_write.h:51`） | builder.cpp:78 | **全仓最成熟的读写对**；属性往返无 CI |
| Verilog | ✓ Rust（`verilog-rust` + `VerilogParserRustC.cc`）+ 旧 C++ `verilog_read.cpp`（1107） | ✓ `verilog_write.cpp`（541） | parser/verilog/ | **两套读路径并存**（Rust 新 / C++ 旧），切换逻辑未审计 |
| Liberty | ✓ Rust（`lib-rust` + `LibParserRustC.cc`） | — | parser/liberty/ | 读-only，合理 |
| SPEF | ✓ Rust（`spef-parser` + `SpefParserRustC.cc`） | 经 iRCX（**未验证**） | parser/spef/ | |
| SDF | ✓（`sdf/sdf_parse`） | — | parser/sdf/ | |
| AOCV | ✓ `AocvParser.cc` | — | parser/aocv/ | |
| VCD | ✓ Rust（`vcd_parser`） | — | parser/vcd/ | |
| JSON | ✗（`parser/json/` 全是 Json* 数据结构 + `GJWriter.cpp`） | ✓ `json_write.cpp`（952） | | **方向反的**：有写无读 |
| SDC | **不在 iDB** | — | `parser/` 无 sdc 目录；iSTA `readSdc` 消费 | **v2.0 判"✓读"错误**；G16 session 缺口 |
| **GDS** | **✗✗ 无 reader**（全仓 grep `GdsReader/GTReader/readGds/loadGDS` 零命中） | **文本**（§1.2 四重缺陷） | `parser/gdsii/` 无 Reader 类 | **流片阻断 + 往返不可能** |

**结论**：iDB 是"LEF/DEF/Verilog 三强 + 其余读-only + GDS 读写双缺"的格局。v2.0 的表把 GDS 读标成"parser 目录在"——**目录在 ≠ 能读**：`parser/gdsii/` 21 个文件里 19 个是 `Gds*` POD 数据结构头，1 个 `GdsData/GdsStruct` 容器，1 个 `GTWriter` 文本写出器，**没有任何读取入口**。

### 1.2 GDS 写出：四重缺陷叠加（P0，逐条坐实）

1. **文本 writer 冒充 GDS**。`Def2GdsWrite` 持有 `GdsiiTextWriter _writer`（`gds_write.h:107`）；`GTWriter.hpp:36-37` 类注释自承 *"GDS-TXT is a human-readable version of the GDSII file format"*；`GTWriter.cpp:126` 写 `(*_stream) << "HEADER "` ASCII 文本流。**二进制 GDSII record 流（[len BE][rec-type][data-type][payload]）在全仓不存在**（grep `GdsiiBinaryWriter|BinaryGds|writeBinary` 零命中）。
2. **坐标单位换算是死代码（比文本更严重，是真 bug）**。`gds_write.h:122-126`：
   ```cpp
   int32_t transDB2Unit(int32_t value)
   {
     return value;                       // ← 直接返回，第二句永不可达
     return value / _unit_microns;       // ← 死代码
   }
   ```
   该函数在 `gds_write.cpp` 被调用 **21 次**（die/pin/component/net/fill 全部坐标），全部原样透传 DBU；而 `set_units()`（`gds_write.cpp:104-119`）却向文件声明 `_gds.set_unit(1.0/_unit_microns, 1e-6/_unit_microns)`。**UNITS 声明与坐标数值差 `micron_dbu` 倍**（nangate45 = 2000×）——即便有人写了二进制化补丁而不修这里，产出的"二进制 GDS"几何仍会错 2000 倍。**先修死换算，再谈二进制**。
3. **类结构是 DEF writer 换皮**。`write_version()`/`write_design()`（`gds_write.cpp:124-176`）创建名为 `"VERSION"`、`"Design Name"` 的 GdsStruct 并把 `"5.8"`（DEF 版本号概念）当 `GdsText` 元素写入版图；顶层 struct 叫 `"DIEAREA"`（`gds_write.cpp:187`）；`write_row/write_track_grid/write_gcell_grid/write_via/write_region/write_slot/write_group` 七个 DEF 语义段以 "no need to print" 注释掉（`gds_write.cpp:76-83`）。产物的正确心智模型是**"给 GUI/人看的版图示意图"**，不是 tapeout 数据。
4. **TCL 层假成功**。`CmdSaveGDS::exec`（`tcl_db_file.cpp:385-398`）调用 `dmInst->saveGDSII(str_path)` 后**丢弃其 bool 返回值，两条路径都 `return 1`**——`saveGDSII` 内部 `DefFileWriteInit` 失败（`builder.cpp:331-334`）时用户拿到的仍是 rc=0。G14 红线违例。

### 1.3 算法/数据结构成熟度

| 模块 | 内容 | 判定 |
|---|---|---|
| `parser/gdsii/Gds*.hpp`（19 个） | GDS 元素 POD（Boundary/Path/Sref/Aref/Text/Node/Box/XY/Strans/Unit/Timestamp…） | **结构齐全、方向正确**——二进制 writer 的数据模型底座已存在，缺的只是 record 编码器（§4.1 可复用） |
| `GdsData/GdsStruct` | struct 容器 + `is_full()` 批量 flush（`GdsData.hpp:73`） | 与文本 writer 耦合的 flush 策略，二进制化时需重审阈值 |
| `Def2GdsWrite::writeDb` | init → set_units → begin → writeChip → finish（`gds_write.cpp:55-68`） | 骨架可用；writeChip 段落顺序需按 GDS 语义重排 |
| DEF/Verilog/JSON writer | 见 §1.1 | 成熟，无阻塞 |
| `manager/service/` | data_service / def_service / lef_service | 成熟 |
| `manager/memory/` | **仅 0 字节 `CMakeLists.txt`** | **空壳目录**——无内存池/驻留策略任何代码（KH-DB-03 无落点） |

### 1.4 边界 / 回退 / 假成功

- **写失败不传播**：`Def2GdsWrite::writeDb` 返回 `_writer.finish()` 的 bool，但 `writeChip()` 内部各段（write_die 等）失败只 `std::cout` 打印继续跑（`gds_write.cpp:180-184`）；TCL 层再丢一次（§1.2-4）。**三层过滤后，用户不可能看到写失败**。
- `set_units` 失败路径：`def_units==nullptr && lef_units==nullptr` → cout + `kDbFail`（`gds_write.cpp:108-112`），但 `writeDb` 不检查 `set_units` 的返回值继续写（`gds_write.cpp:59-63`）——单位缺失时产出无 UNITS 的文件。
- **空壳目录**：`manager/memory/`（0 字节 CMakeLists）。v2.0 的"内存爬坡"P1 项连挂载点都没有。
- JSON 有写无读（§1.1）——G16 session 若选 JSON 做 checkpoint 格式，需补 reader 或换格式（未决，见 §14）。

### 1.5 跨工具协调

| 方向 | 现状 | 判定 |
|---|---|---|
| iDB → 全工具 | 唯一共享数据模型，各工具经 `dmInst` 读写 | 成熟（这是 iEDA 的正确骨架） |
| iDB → iRCX/iSTA | SPEF/Liberty 读入供给 signoff | 通（读路径） |
| iDB → 12 evaluation | 最终产物 DEF/GDS 是 L2 QoR 的真源 | **GDS 断**：L2 若按 GDS 抽样几何，拿到的是文本示意图 |
| iDB → 40 platform | G16 session 断点续跑依赖 iDB 可序列化 | **缺**：无二进制 session dump；DEF 往返未证无损 |
| iDB → flow 脚本 | `regress_gcd.sh` 以最终 GDS 做验收 | **验收对象本身是文本 GDS**——"过 regression"≠"可流片" |

---

## 2. 需求 FR / NFR / 约束

### 2.1 FR（★=新增/大改）

| ID | 功能 | 现状 | rv1.1 |
|---|---|---|---|
| FR-DB-01 | ★ 先修 `transDB2Unit` 死换算 + `CmdSaveGDS` 返回值透传 | ✗（死代码/假成功） | P0（**先于二进制**，§1.2-2/4） |
| FR-DB-02 | ★ `GdsiiBinaryWriter`（复用 `GdsData/Gds*` POD + record 编码器） | ✗ | P0（§4.1） |
| FR-DB-03 | ★ GDS reader（二进制 → `GdsData`） | ✗✗ | P1（§4.2，往返矩阵前提） |
| FR-DB-04 | ★ 往返矩阵 CI（读→写→再读，逐格式字段清单断言） | ✗ | P0（§4.3） |
| FR-DB-05 | DEF STATUS/PROPERTY 不丢 | ❓ 待矩阵裁决 | P1 |
| FR-DB-06 | 容量剖面 10万/50万/100万实例（RSS+wall） | ✗（memory/ 空壳） | P1（§4.4） |
| FR-DB-07 | ★ 空壳目录处置（`manager/memory/` 填实或删除） | 空壳 | P2 |
| FR-DB-08 | ★ Verilog 双读路径（Rust/旧 C++）收敛或写明分工 | 并存未审计 | P2 |

### 2.2 NFR

| ID | 指标 | 门槛 |
|---|---|---|
| NFR-DB-01 | 二进制 GDS 可被 gdstk/klayout stream 打开 | 必过（KH-DB-01） |
| NFR-DB-02 | GDS 几何与 DEF 抽样一致（同一坐标系） | 逐点多边形对比，0 偏差 |
| NFR-DB-03 | 文本 GDS 路径仅 debug 旗标可达，带 WARN | 不进流片脚本 |
| NFR-DB-04 | 往返矩阵清单内字段丢失数 | 0（G1） |
| NFR-DB-05 | 50万实例 load→save 峰值 RSS | 记录→预算（G13） |
| NFR-DB-06 | 写失败 rc | TCL 层非 0（G14） |

### 2.3 红线

- **禁止**用 ASCII 流冒充 GDS 流片产物（KH-DB-01）。
- **禁止**在未修 `transDB2Unit` 前交付任何"二进制 GDS"（错误坐标编码成二进制是更大的假成功）。
- **禁止**宣称"parser 目录存在 = 支持该格式"——读写两列分开举证（§1.1 教训）。
- 新能力缺省不改变现有 flow 行为 → 零回归。

---

## 3. HLD 总体架构

### 3.1 数据流

```
输入文件                    iDB（唯一共享数据模型）                     输出
─────────────   ┌────────────────────────────────────┐   ─────────────────
LEF ──────────► │  builder/ (lef/def/verilog/json)    │ ──► DEF   (成熟)
DEF ──────────► │  parser/  (11 格式; 4 个 Rust 桥)    │ ──► Verilog(成熟)
Verilog(Rust)─► │  data: design/tech/circuit          │ ──► JSON  (写-only)
Liberty(Rust)─► │  service: def/lef/data              │ ──► GDS:
SPEF(Rust)────► │  memory: 【空壳】                     │     文本(现, debug only)
SDF/AOCV/VCD─►  │                                     │     ★二进制(§4.1, 流片)
SDC ✗(在 iSTA)  └──────────────┬─────────────────────┘
                               │ ★ GdsBinaryReader(§4.2)
                               ▼
                    ★ 往返矩阵 CI（读→写→再读 → 字段断言，§4.3）
```

### 3.2 关键设计决策（含被否）

| # | 决策 | 被否 |
|---|---|---|
| D1 | **先修死换算与假成功，再做二进制 writer** | 直接上新 writer（会把 2000× 错误坐标编码进二进制） |
| D2 | 二进制 writer **复用 `GdsData/Gds* POD`**，只新增 record 编码层 | 另起一套 GDS 数据模型（平行重写） |
| D3 | GDS reader 走 `GdsData` 中间表示再进 iDB（读改写共用一套 POD） | reader 直插 iDB（两套语义映射） |
| D4 | 文本 GDS 保留为显式 debug 旗标 + WARN | 立刻物理删除（现网脚本可能依赖，§14 未验证） |
| D5 | 往返矩阵"测试即规格"进 CI | 口头字段清单 |
| D6 | `manager/memory/` 空壳：容量剖面先落在 benchmark 脚本，不新建目录 | 把空壳填实再测（无需求驱动，先量后建） |
| D7 | SDC 留在 iSTA，不进 iDB（本里程碑） | 为 G16 提前把 SDC 搬进 iDB（超范围，§14 记录） |

---

## 4. LLD · 模块分解

### 4.1 ★ `GdsiiBinaryWriter`（FR-DB-02，P0）

**现状签名（真实）**：`GdsiiTextWriter`（`GTWriter.hpp:38-93`）——`init(txt, GdsData*) / begin() / finish() / writeStruct() / writeTopStruct()`，私有 `write_header/bgnlib/libname/units/bgnstr/strname/element/boundary/path/sref/aref/text/xy/endel/endstr/endlib` 一族**全是对 `std::ofstream` 的 `<<` 文本操作**。

**设计**：与 `GdsiiTextWriter` 平级新增 `GdsiiBinaryWriter`，**消费同一个 `GdsData`**（D2），把 `write_*` 一族换成 record 编码：

```
ALG-4.1-1  record 编码（GDSII stream format）
  每条 record = [2B 总长 BE][1B rec-type][1B data-type][payload]
  HEADER    rec=0x00 i16  version(600)
  BGNLIB    rec=0x01 i16×12  时间戳
  LIBNAME   rec=0x02 str
  UNITS     rec=0x03 f64×2  excess-64 编码（user unit / dbu per user unit）
  BGNSTR/STRNAME ... BOUNDARY(rec=0x08)+LAYER(0x0D)+DATATYPE(0x0E)+XY(0x10,i32 BE 对)+ENDEL(0x11)
  SREF(rec=0x0A)+SNAME(0x06)+STRANS(0x1A)+MAG(0x1B)+ANGLE(0x1C)+XY+ENDEL
  ENDSTR(0x07) / ENDLIB(0x04)
  字符串奇数长补 NUL；f64 excess-64: sign·16^(exp-64)·mantissa
```

- **复用姿势 = Composition**：`GdsData/GdsStruct/Gds*` POD 原样复用；仅新增编码器文件对（`GBWriter.{hpp,cpp}`），与 `GTWriter` 同目录同风格。
- **复杂度**：O(元素数)；单条 record 写 O(1)。内存与文本版同级（`GdsData::is_full` 分批 flush 策略保留）。
- **边界**：坐标 int32 溢出检查（DBU→unit 换算后）；空 struct 不写；`transDB2Unit` **修复后**统一走 `value / _unit_microns`（FR-DB-01 先行）。
- **验收（机器可判）**：`file` 报 data 而非 ASCII；`xxd | head` 首 2 字节为记录长非 `HE`；gdstk/klayout stream 模式打开；与 DEF 抽样多边形逐点一致（NFR-DB-02）。

### 4.2 ★ `GdsBinaryReader`（FR-DB-03，P1）

**现状**：无（全仓零命中）。

**设计**：record 解码器 → `GdsData`（D3）→ `GdsData→iDB` 映射层。第一阶段只需覆盖往返矩阵断言所需子集：HEADER/UNITS/BGNSTR/STRNAME/BOUNDARY/PATH/SREF/AREF/XY/LAYER/DATATYPE/ENDEL/ENDSTR/ENDLIB。**复杂度** O(文件字节)；流式，不全量驻留。**边界**：截断 record（len 越界）→ 响亮失败；未知 rec-type → 跳过并计数 WARN。

### 4.3 ★ 往返矩阵 CI（FR-DB-04，P0）

**现状**：各 parser 散落单测，无"读→写→再读"闭环。

**设计**（测试即规格，D5）：

```
ALG-4.3-1  每格式一行矩阵
  for fmt in [DEF, Verilog, GDS★, JSON★]:
    db0 = read(gold.fmt); f1 = write(db0); db1 = read(f1)
    for field in FIELD_MANIFEST[fmt]:      # 清单即规格
      assert db0.field == db1.field
  FIELD_MANIFEST[DEF]  = {坐标, STATUS, PROPERTY, NET 连接, VIA, ROW/TRACK}
  FIELD_MANIFEST[Verilog] = {层次名, 端口方向, 实例连接, 转义名}
  FIELD_MANIFEST[GDS]  = {struct 名, layer/datatype, XY 坐标, SREF/MAG/ANGLE}
  FIELD_MANIFEST[JSON] = {待定——json 无 reader，先标记 BLOCKED}
```

**边界**：字段容差表（浮点坐标按 DBU 整数比）；已知丢失字段先列入 `KNOWN_LOSS.md` 而非静默。**铁律**：清单外字段丢失不阻断，清单内丢失 = G1 红。

### 4.4 ★ 容量剖面（FR-DB-06，P1）

不新建目录（D6），落 `benchmark/db/`：netlist→iDB→saveDEF 全链，10万/50万/100万实例三档，记录 load_wall / save_wall / peak RSS。50万档为 G13 候选；100万失败则写清瓶颈（几何全展开？unordered_map 膨胀？——**先量后猜**）。

### 4.5 `Def2GdsWrite` 段落重排（随 FR-DB-02 落地）

`writeChip()`（`gds_write.cpp:64-85`）按 GDS 语义重排：去掉 `"VERSION"`/`"Design Name"` 两个 DEF 换皮 struct；顶层 struct 用真实 design name；die 边界是否落 layer 0 需按 PDK layer map 决策（**deferred**：layer map 表先行，见 §14）；`write_pin/component/net/special_net/fill` 保留但坐标一律过修复后的 `transDB2Unit`。

### 4.6 模块状态一览

| 模块 | 现状成熟度 | 主复杂度 | 关键边界 | 复用姿势（现状→目标） |
|---|---|---|---|---|
| def_read/def_write | 成熟（2330+1455 LOC） | O(对象数) | 属性保真无 CI | 保留 + 矩阵 |
| verilog (Rust+旧C++) | 双读路径并存 | — | 切换逻辑未审计 | 收敛或写明分工（FR-DB-08） |
| json_write / GJWriter | 写-only（952 LOC） | — | 无 reader | 标记 BLOCKED（§4.3） |
| `Gds*/GdsData` POD | 结构齐全（2201 LOC） | — | is_full flush 阈值 | **Composition 复用**（§4.1/4.2） |
| `GdsiiTextWriter` | 调试级（566 LOC） | O(元素) | 非流片格式 | 降级 debug-only + WARN |
| `Def2GdsWrite` | DEF 换皮（858 LOC） | O(元素) | §1.2 四重缺陷 | 重排 + 接二进制后端 |
| `GdsiiBinaryWriter` ★ | 无 | O(元素) | int32 溢出；excess-64 | 新增（Composition POD） |
| `GdsBinaryReader` ★ | 无 | O(字节) | 截断/未知 record | 新增 |
| `manager/memory/` | **空壳** | — | — | 不填实，剖面落 benchmark（D6） |
| `CmdSaveGDS` | 假成功 | — | 丢 bool | 修返回值（FR-DB-01） |

---

## 5. 配置

| 键 | 默认 | 说明 |
|---|---|---|
| `gds.mode` | `binary`（落地后） | `binary` / `text_debug`；落地前唯一可用值是 text 且必须 WARN |
| `gds.layer_map` | PDK 侧车文件 | die/pin/net → (layer,datatype) 映射；**缺失即失败**，禁止硬编 |
| `roundtrip.manifest` | repo 内清单 | §4.3 FIELD_MANIFEST 路径 |

缺省行为不变（text 路径保留至 binary 验收通过）→ 零回归。

---

## 6. 指标分解

| 维 | 含义 | 记录 |
|---|---|---|
| roundtrip_lost_fields | 清单内丢失字段数（逐格式分列） | 禁合并总分 |
| gds_readable | gdstk/klayout 打开结果 | bool |
| gds_geom_deviation | 与 DEF 抽样多边形偏差 | max/mean |
| load_wall / save_wall / peak_rss | 三档实例数 | CSV |
| write_failure_rc | 注入失败时 TCL rc | 必须 ≠0 |

---

## 7. 状态机 / 命令语义

```
load → mutate → save_{def|verilog|json|gds}
save_gds: check(layer_map) → write → verify(rc 透传)
失败 rc≠0；binary 失败 ≠ 改写 text 假成功；text_debug 模式首行 WARN 日志
```

---

## 8. 跨工具 Cascade

| 上/下游 | 信号 | 契约 |
|---|---|---|
| 全工具 ↔ iDB | dmInst 读写 | 不变（正确骨架） |
| iDB → 12 evaluation | 最终 DEF/★GDS 为 L2 QoR 真源 | 二进制落地前 L2 禁抽 GDS |
| iDB → 40 platform | G16 session 序列化 | DEF 往返无损证明，或专用 dump（§14 未决） |
| iDB → flow 脚本 | regress 验收对象 | binary 落地后脚本切 binary |

---

## 9. 商业 Know-how 映射

| KH-ID | 本工具落点 |
|---|---|
| KH-DB-01（二进制唯一流片真源） | §1.2 / §4.1 / NFR-DB-01/03 |
| KH-DB-02（属性往返） | §4.3 矩阵 + KNOWN_LOSS |
| KH-DB-03（分层驻留/容量） | §4.4 剖面（memory/ 空壳记录在案） |
| KH-X-04（失败响亮） | §1.4 / FR-DB-01 / §7 |

---

## 10. 商业对照看板 + 演进 M0–M4

### 10.1 看板

| 指标 | iEDA iDB | 商业（INVS/ICC2 DB） | 门槛 | 门禁 |
|---|---|---|---|---|
| 流片 GDS | 文本示意图 | 二进制 stream | gdstk/klayout 可读 | — |
| GDS 几何一致 | 坐标差 2000×（死换算） | — | 抽样 0 偏差 | — |
| 往返丢失 | 无矩阵 | OA 无损 | 清单内 0 | G1 |
| 写失败可见 | rc 恒 0 | 响亮 | rc≠0 | G14 |
| 峰值内存 | 未剖面 | — | 记录→预算 | G13 |

### 10.2 对照实验（杀假说）

| 实验 | 方法 | 杀死条件 |
|---|---|---|
| E-DB-01 | `file`/`xxd` 验当前产物 | 若已是二进制 → 本文档 §1.2-1 被杀（预期：ASCII `HEADER`） |
| E-DB-02 | 修死换算前后坐标对比 | 若无变化 → §1.2-2 被杀（预期：差 micron_dbu 倍） |
| E-DB-03 | 故意丢 STATUS 跑矩阵 | 矩阵不报 → 矩阵假（G1 防线） |
| E-DB-04 | 注入写盘失败 | TCL rc==0 → §1.2-4 实锤（修复后必≠0） |
| E-DB-05 | 文本模式进 release 流片脚本 | CI 拒（NFR-DB-03） |

### 10.3 演进

```text
M0 先量：E-DB-01/02 实锤报告（hex 头 + 坐标比）+ 空壳/假成功台账
M1 可信：FR-DB-01（死换算+rc 透传）+ gtest；BinaryGdsWriter + E-DB-02/04 绿
M2 主算法：GdsBinaryReader + 往返矩阵 CI（DEF/Verilog/GDS）
M3 打平：layer_map 真实 PDK 全量 GDS 与金参考并排（12 联动）
M4 纵深：OASIS、容量 100万、session 序列化选型
```

退出门禁：M0→实锤报告入库；M1→NFR-DB-01/02；M2→NFR-DB-04；M3→G1 面积/几何行可解释；M4→非本阶段阻断。

---

## 11. Exhibit

| 档 | 产物 |
|---|---|
| JSON | `db_roundtrip_report.json`（逐格式 × 逐字段 PASS/FAIL/SKIP） |
| CSV | `db_capacity.csv`（insts, load_wall, save_wall, peak_rss） |
| text | `db_gds_probe.txt`（M0 hex 头 + file 输出 + 坐标比实锤） |
| plot | 可选：容量- RSS 曲线 |

---

## 12. 测试计划

| 层 | 用例 | 锁住 |
|---|---|---|
| L0 | `transDB2Unit` 换算正确（修后） | FR-DB-01 |
| L0 | 二进制头 magic/record 结构 | FR-DB-02 |
| L0 | DEF STATUS/PROPERTY round-trip | FR-DB-05 |
| L0 | 截断 record → reader 响亮失败 | §4.2 |
| L1 | 三 PDK（sky130/ics55/nangate45）DEF/Verilog 矩阵 | §4.3 |
| L1 | gdstk 打开 binary GDS + 几何抽样 | NFR-DB-01/02 |
| L4 | 50万实例 RSS/wall 剖面 | G13 |
| L5 | 写失败注入 → TCL rc≠0 | G14 |

---

## 13. 里程碑（按周粗估）

| 周 | 交付 | 验收 |
|---|---|---|
| W0 | M0 实锤报告（E-DB-01/02）+ KNOWN_LOSS 初稿 | 报告入库 |
| W1 | FR-DB-01 + `GdsiiBinaryWriter` + gtest | NFR-DB-01/02 |
| W2 | `GdsBinaryReader`（子集）+ 往返矩阵 CI 三格式 | NFR-DB-04 |
| W3 | 容量剖面 + layer_map 全量 GDS | G13 候选 |
| W4+ | 与 12 联动金参考并排；OASIS 评估 | M3/M4 |

PR 切片：DB-0 实锤报告 → DB-1 死换算+rc 修复 → DB-2 BinaryWriter → DB-3 Reader+矩阵 → DB-4 容量剖面。

---

## 14. 未验证 / 负面结论

| # | 项 | 说明 |
|---|---|---|
| 1 | 现网脚本是否已依赖文本 GDS | 删/降级前须 grep `scripts/` + 用户 flow；**未验证** |
| 2 | OASIS 是否需要 | 商业已普及；本里程碑不做 |
| 3 | DEF 5.8 全属性集往返 | 矩阵裁决前不写"不丢" |
| 4 | layer map 来源 | die/pin/net → (layer,datatype) 无 PDK 侧车；**deferred，缺即失败** |
| 5 | G16 session 格式 | JSON 无 reader / DEF 往返未证 / 专用二进制 dump 三选一，**未决** |
| 6 | SDC 是否进 iDB | 现由 iSTA 消费；G16 若要序列化约束需单独立项（D7） |
| 7 | Verilog 双读路径 | Rust 新 vs `verilog_read.cpp` 1107 旧，切换与差异**未审计** |

**不要重走**：
- 不要在未修 `transDB2Unit` 前写二进制编码器——会把 2000× 错误坐标固化进二进制（比文本假成功更难发现）。
- 不要扩展 `GdsiiTextWriter`「更像」二进制（加 record 样子）——文本流语义根本不是 record 流，重写编码层比重写文件名便宜。
- 不要把"parser 目录存在"当"支持该格式"举证——GDS 目录 21 个文件无 reader 是本案原型。

---

## 附录 A · 迁移 checklist

- [ ] E-DB-01/02 实锤报告（hex + 坐标比）
- [ ] `transDB2Unit` 死代码修复 + gtest（FR-DB-01）
- [ ] `CmdSaveGDS::exec` 透传 `saveGDSII` 返回值（FR-DB-01）
- [ ] `GBWriter.{hpp,cpp}` record 编码器（Composition `GdsData`）
- [ ] `writeChip()` 段落重排 + 去 DEF 换皮 struct
- [ ] `GdsBinaryReader` 子集 + 截断失败 gtest
- [ ] FIELD_MANIFEST × {DEF, Verilog, GDS} + CI
- [ ] `KNOWN_LOSS.md` 初稿
- [ ] 容量剖面三档 CSV
- [ ] 文本 GDS 加 `--gds-debug-text` 旗标 + WARN
- [ ] `manager/memory/` 空壳处置（删或留说明）
- [ ] Verilog 双读路径审计记录

## 附录 B · 关键决策记录

| # | 决策 | 被否 |
|---|---|---|
| E-1 | 二进制唯一流片真源 | 文本冒充 / "更像二进制"的文本 |
| E-2 | 先修死换算+假成功再写新 writer | 直接上新 writer |
| E-3 | 复用 `GdsData` POD，只加编码层 | 另起数据模型 |
| E-4 | 测试即规格（FIELD_MANIFEST） | 口头字段清单 |
| E-5 | 文本保留显式 debug | 无迁移硬删 |
| E-6 | 容量剖面落 benchmark 脚本 | 先填实 memory/ 空壳 |
| E-7 | SDC 留 iSTA（本里程碑） | 提前搬进 iDB |

## 附录 C · 术语

- **GDSII stream**：二进制 record 流，`[2B len BE][rec-type][data-type][payload]`；坐标 i32 BE；实数 excess-64
- **GDS-TXT**：`GTWriter` 自承的人读文本版（`GTWriter.hpp:36-37`），仅调试
- **往返矩阵**：读→写→再读 → 字段清单断言，"测试即规格"
- **excess-64**：GDS 实数编码，`sign·16^(exp-64)·mantissa`
- **layer map**：设计对象 → (layer, datatype) 的 PDK 侧车映射

## 附录 D · 证据摘录（file:line 最小集）

| 断言 | 证据 |
|---|---|
| saveGDSII 入口 | `builder.cpp:330-338` → `Def2GdsWrite` |
| TextWriter 成员 | `gds_write.h:107` `GdsiiTextWriter _writer;` |
| 自承人读格式 | `GTWriter.hpp:36-37` |
| ASCII HEADER | `GTWriter.cpp:126` `<< "HEADER "` |
| 死单位换算 | `gds_write.h:122-126`（`return value;` 先行）；21 处调用（`grep -c transDB2Unit gds_write.cpp` = 21） |
| UNITS 声明矛盾 | `gds_write.cpp:119` `set_unit(1.0/_unit_microns, …)` |
| DEF 换皮 struct | `gds_write.cpp:124-176`（`"VERSION"`/`"Design Name"` GdsText）；`:187` `"DIEAREA"`；`:76-83` 七段注释 |
| 无 GDS reader | `grep -rl "GdsReader\|GTReader\|readGds\|loadGDS" src/` = 0 |
| TCL 假成功 | `tcl_db_file.cpp:385-398`（丢 bool 恒 return 1） |
| set_units 失败继续写 | `gds_write.cpp:59-63`（不查返回值） |
| memory/ 空壳 | `manager/memory/` 仅 0 字节 `CMakeLists.txt` |
| parser 目录 | `parser/{aocv,gdsii,json,liberty,rust-common,sdf,spef,vcd,verilog}`；无 sdc |
| Rust 桥 | `LibParserRustC.cc` / `SpefParserRustC.cc` / `VerilogParserRustC.cc` / `VcdParserRustC.cc` |
| builders 体量 | `find builder -name '*.cpp' \| xargs wc -l` = 12572 |
