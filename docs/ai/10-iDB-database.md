<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 10 · iDB 数据库 · 商业对标方案 · rv2.0

> 文档号：10-rv2.0　　版本：rv2.0（大改）　　里程碑：**双对标 —— 数据完整性对标（Innovus/ICC2 OA，往返无损 G1）× 性能/容量对标（G13 大设计）**
> 体例：`01-ai-doc-conventions-rv1.md`；深度对标：`24-iPL-3d-rv1.0.md`、`27-iSTA-rv2.0.md`、`28-iRCX-rv2.0.md`（逐 kernel 走读 + 双对标线 + 诚实归因）
> 商业金标：**Innovus/ICC2 Design Database**（数据完整性）；**OpenAccess (OA)**（往返无损、API 稳定性）；门禁：**G1 / G13 / G14 / G16**
> 上游：LEF/DEF/Verilog/SDC/Liberty/SPEF/GDS 等输入文件　下游：**全部工具**（iDB 是全流程唯一共享数据模型）
> 纲领：`00-ieda-commercial-parity-master-plan-v1.1.md`；Know-how：`03-commercial-knowhow-catalog.md` KH-DB-\*
> 覆盖：`src/database/manager/builder/`（12.6k LOC）、`src/database/manager/parser/`（11 格式目录）、`src/database/manager/{memory,service}`、`builder/gds_builder/`、`parser/gdsii/`
> 纪律：**文档是假说不是事实**；每条断言带 `file:line`；未实测写「未验证」；每条理论附能杀死它的对照。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.0–v1.1 | 2026-07-20 | GDS 文本风险摘要 |
| rv1.0 / v2.0 | 2026-07-20 | 坐实 `Def2GdsWrite` 持 `GdsiiTextWriter`（`gds_write.h:107`）、`GTWriter.cpp:126` 写 ASCII `"HEADER "` |
| rv1.1 / v3.0 | 2026-07-21 | **大改**：对 `builder/`（12572 LOC）+ `parser/gdsii/`（2201 LOC）+ `gds_write.{h,cpp}`（138+858 LOC）逐文件读完重写。核心修订五条，**其中三条推翻/深化 v2.0 的判定**：**(1)** GDS 问题比 v2.0 认定的更严重——不是"文本格式不对"一个缺陷，而是**四重叠加**：文本 writer + **坐标单位换算函数是死代码**（`gds_write.h:122-126` `transDB2Unit` 第一句 `return value;` 使第二句永不可达，21 处调用全部原样透传 DBU，而 UNITS 声明却是 `1.0/_unit_microns`——**声明与坐标自相矛盾**）+ 无 GDS reader（全仓 grep `GdsReader/GTReader/readGds/loadGDS` **零命中**，"往返"根本无从谈起）+ TCL 层丢弃失败返回值（`tcl_db_file.cpp:385-398` `CmdSaveGDS::exec` 无视 `saveGDSII` 的 bool，恒 `return 1`，G14 假成功）;**(2)** v2.0 称"SDC ✓ 读"——**错**，`parser/` 下无 sdc 目录，SDC 由 iSTA `TimingEngine::readSdc` 消费，**不在 iDB 数据模型内**（对 G16 session 序列化是缺口）;**(3)** `manager/memory/` 是**空壳目录**（仅一个 0 字节 `CMakeLists.txt`），v2.0 §DB3"大设计内存未爬坡"连基础设施都不存在;**(4)** `Def2GdsWrite` 的类结构是 **DEF writer 的换皮移植**：`write_version/write_design` 产出名为 `"VERSION"`/`"Design Name"`/`"DIEAREA"` 的 GdsStruct 并把版本号当 `GdsText` 写进版图（`gds_write.cpp:124-176`）——这是**可视化调试产物**，不是 tapeout 语义;**(5)** parser 层已 Rust 化（liberty/spef/verilog/vcd 四个 Rust parser + C 桥），往返矩阵必须把 Rust 桥纳入断言面。 |
| **rv2.0** | **2026-07-22** | **大改（对照 27-iSTA-rv2.0.md / 28-iRCX-rv2.0.md 的深度与双对标线重写，强化基础设施工具特性）**。核心修订五条：**(1)** rv1.1 把 iDB 当成"GDS 问题为主、其余格式成熟"来审——**代码级核实后发现头号结构症结是数据完整性机制缺失**：往返无损能力未证（无 CI 矩阵）、属性保留策略不透明（STATUS/PROPERTY/VERSION 映射未文档化）、格式覆盖表空白（哪些 DEF 5.8 / LEF 5.7 特性支持/跳过/假成功不可知）——基础设施的价值前提是"我知道我保留了什么、丢了什么、与金标 OA 的差距在哪"，当前状态是**边界失明**（§1.5，类比 30 号文档对 DRC 覆盖表缺失的判定）；**(2)** 新增 **数据完整性栈逐项**（§1.5，Innovus/ICC2 OA 对标核心证据）：逐机制列出 iDB 已有 vs 商业 DB 必需的差距清单——LEF/DEF/Verilog 读写引擎 ✓、Rust parser 桥 ✓；但 **往返无损不可证**（无 CI 矩阵）、**格式覆盖表零建设**（哪些子特性映射到 iDB 的哪个字段/接口）、**属性映射策略未文档化**（REGION/GROUP/SLOT 等 DEF 扩展语义的保留/丢弃规则不透明）、**性能/容量基线缺失**（memory/ 空壳目录，G13 容量爬坡无起点）；**(3)** 全文按**双对标线**重组：Innovus/ICC2 OA 线 = 数据完整性栈（往返无损 + 格式覆盖表透明 + 属性映射文档化 → G1 零丢失），性能/容量线 = 内存/I/O 速度栈（内存池/驻留策略 + 增量更新 API + 大设计剖面 → G13 百万实例），§10 拆成两块看板；**(4)** 补齐 27 号文档体例要素：§1.5 精度栈（数据完整性机制 15 项对比）、§4.12 模块状态一览已有但补充复用姿势/复杂度分析、§5 双档配置表（全量档 vs 增量档）、§8 调用方契约表（全工具 → iDB 消费契约 + iDB → evaluation/platform 提供契约）、§10.2 对照实验（E-DB-\* 系列可杀假说）；**(5)** 基础设施工具特殊纪律强化：**边界诚实红线前置**（§1.3 边界、§2.3 约束、§7 状态机、§10.1 看板、§14.2 负面）、格式覆盖表从"附录可选"升为 **M0 前置 + CI 强制**（§4.3，对标 30 号 DRC 覆盖表的地位）、数据完整性看板必填往返丢失计数/覆盖率（§10.1，对标 OA 的机械判据，非目视）。**缺省配置零回归**纪律不变；新增 GDS 二进制 + 往返矩阵 CI 开关缺省 **强制**（基础设施边界诚实 > 开发便利）。 |

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
- **空壳目录**：`manager/memory/`（0 字节 CMakeLists）。rv1.1 的"内存爬坡"P1 项连挂载点都没有。
- JSON 有写无读（§1.1）——G16 session 若选 JSON 做 checkpoint 格式，需补 reader 或换格式（未决，见 §14）。

### 1.5 ★数据完整性栈逐项——对 Innovus/ICC2 OA 的差距清单（数据库对标核心，基础设施头号纪律）

Innovus/ICC2 设计数据库的可信度来自一整套互相咬合的数据完整性机制。逐项核实 iDB 差距（✓=有且生产在用，⚠️=有但半残，✗=无）：

| # | Innovus/ICC2 OA 机制 | iDB 现状 | 证据 | 对数据完整性的影响 | P |
|---|---|---|---|---|---|
| 1 | **LEF/DEF 读写引擎** | ✓ | `def_read.cpp` 2330 LOC + `def_write.cpp` 1455 LOC；`lef_builder/` + third_party lefdef | 主路径成熟 | — |
| 2 | **Verilog 网表读写** | ✓（双路径） | Rust（`verilog-rust` + `VerilogParserRustC.cc`）+ 旧 C++ `verilog_read.cpp` 1107 LOC | 两套读路径并存，切换逻辑未审计 | P2 |
| 3 | **Liberty/SPEF/SDF 读取** | ✓（Rust桥） | `lib-rust` / `spef-parser` / `sdf/sdf_parse` + Rust-C 桥 | 读-only，合理 | ✓ |
| 4 | **往返无损能力**（read→write→read，字段保真） | ✗（无 CI 矩阵） | repo 无往返断言 CI；DEF/Verilog/GDS 属性保留**未验证** | **边界失明**：不知道 iDB 保留了输入的哪些字段、丢了哪些 → **假无损的根源**（工具报"写成功"但关键属性已丢，流程后段拿到残缺数据） | **P0** |
| 5 | **格式覆盖表**（DEF 5.8 / LEF 5.7 特性 ↔ iDB 字段映射） | ✗ | repo 无强制覆盖表；哪些 DEF STATUS/REGION/GROUP/SLOT 支持/跳过不可知 | **边界失明**：不知道 iDB 支持了输入格式的哪个子集 → **假支持的根源**（builder "不报错"≠ 数据正确进 iDB） | **P0** |
| 6 | **属性映射策略文档化**（扩展属性/PROPERTY/VERSION 的保留规则） | ✗ | DEF PROPERTY 读取路径存在（`def_read.cpp`），写出是否保真**未验证**；LEF VERSION 映射策略**未文档化** | 属性丢失不透明 → 下游工具（如 iDRC 需要 layer property、iTO 需要 cell timing class）拿到不完整数据 | P1 |
| 7 | **GDS 二进制读写**（tapeout 唯一真源） | ✗✗（§1.2 四重缺陷） | 文本 writer + 死换算 + 无 reader + 假成功 | **流片阻断**：当前产出是 ASCII 示意图（坐标错 2000×），无法交 foundry | **P0** |
| 8 | **API 稳定性**（builder/service 接口版本兼容） | ⚠️ 未承诺 | `data_service` / `def_service` / `lef_service` 在；接口变更策略**无文档** | iDB 接口变更破坏下游工具（24 个 operation 模块全依赖 iDB）；无版本号/deprecation 策略 | P1 |
| 9 | **数据校验**（几何/拓扑/命名合法性） | ⚠️ 零散 | DEF 坐标/单位读取有校验；**无统一 validate() 入口** | 非法数据进 iDB → 后段工具 crash（如 iPL 拿到重叠 placement blockage） | P1 |
| 10 | **内存管理**（池化/驻留/增量释放） | ✗（空壳目录） | `manager/memory/` 仅 0 字节 `CMakeLists.txt`（§1.3） | **G13 容量爬坡无基础**：大设计内存爆炸（100 万实例 RSS 未知） | **P0** |
| 11 | **增量更新 API**（局部修改无需全量重建） | ✗ | 全树无 `updateNet` / `modifyInstance` / `incrementalLoad` 类 API | 每次 ECO 后全量 save→reload → 墙钟主瓶颈（iTO 每轮优化都要序列化整个 DB） | P1 |
| 12 | **session 序列化/断点续跑**（G16 前置） | ✗（格式未定） | JSON 有写无读（§1.1）；DEF 往返无损未证；SDC 不在 iDB（§1.1） | G16 无法实现（session dump 需要全状态：design + timing constraints + opt state） | P1 |
| 13 | **并发读保护**（多工具同时查询 iDB） | ⚠️ 未验证 | `dmInst` 全局单例；是否线程安全**未验证** | 潜在 race（如 evaluation 后台统计 + iTO 前台修改） | P2 |
| 14 | **错误恢复**（写失败回滚/部分写保护） | ✗ | §1.4：写失败继续写 + TCL 层假成功 | 损坏输出文件被下游当成合法输入 → 全链失真 | **P0** |
| 15 | **性能剖面/基线**（load/save 墙钟/内存分项） | ✗ | 无 `benchmark/db/` 剖面脚本；memory/ 空壳 | 性能退化不可察觉（如某次提交让 50 万实例 load 慢 3×） | P1 |

**§1.5 结论**：数据完整性缺口是**结构性的三层**——(a) 验证层：往返无损不可证、格式覆盖表零建设、属性映射不透明（#4/5/6，**边界失明**）；(b) 实现层：GDS 四重缺陷、内存管理空壳、增量 API 缺（#7/10/11）；(c) 健壮性层：错误恢复缺、数据校验零散、并发保护未验证（#14/9/13）。rv1.1 只覆盖了 (b) 的一部分，(a) 是 rv2.0 新增战线。**基础设施工具头号纪律 = 边界诚实**（KH-DB-02）：无往返矩阵的"格式支持" = 假支持。

### 1.6 跨工具协调——消费契约与提供契约（基础设施调用方/被调用方双向审计）

| 方向 | 现状 | 契约要求 | 判定 |
|---|---|---|---|
| 全工具 → iDB（消费契约） | 唯一共享数据模型，各工具经 `dmInst` 读写 | iDB API 稳定性承诺（版本兼容/deprecation 策略） | **半通**：骨架正确，但无版本策略（§1.5-#8） |
| iRCX/iSTA → iDB | SPEF/Liberty 读入 | 格式覆盖表透明（哪些 SPEF 字段进 iDB） | **半通**：读路径在，覆盖表缺（§1.5-#5） |
| iDB → evaluation | 最终产物 DEF/GDS 是 L2 QoR 的真源 | GDS 二进制可信 + 几何与 DEF 一致 | **GDS 断**：L2 若按 GDS 抽样几何，拿到的是文本示意图（坐标错 2000×） |
| iDB → platform | G16 session 断点续跑依赖 iDB 可序列化 | session dump 包含全状态（design + constraints + opt state） | **缺**：无二进制 session dump；DEF 往返未证无损；SDC 不在 iDB |
| iDB → flow 脚本 | `regress_gcd.sh` 以最终 GDS 做验收 | 二进制 GDS 可被 foundry 接收（gdstk/klayout stream 模式打开） | **验收对象本身是文本 GDS**——"过 regression"≠"可流片" |
| iTO/iPL → iDB | ECO 后修改 instance/net | 增量更新 API（局部修改无需全量重建） | **断**：无增量 API，每次 ECO 全量 save→reload（§1.5-#11） |

**§1.6 结论**：跨工具契约断点三处——**(a) 数据完整性契约不透明**（格式覆盖表/往返无损/属性映射策略缺）；**(b) GDS 产物不可信**（文本示意图冒充流片数据）；**(c) 性能契约缺失**（无增量 API，ECO 墙钟主瓶颈）。

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

### 3.1 数据流——单引擎双档（数据完整性档 × 性能/容量档）

```text
                    LEF/DEF/Verilog/Liberty/SPEF/GDS (输入格式)
                         │
输入文件 ──────────────► builder/ (lef/def/verilog/json/gds)  ← parser/ (11 格式; 4 Rust 桥)
LEF ──────────────────► │  data: design/tech/circuit          │
DEF ──────────────────► │  service: def/lef/data              │ ──► DEF   (成熟)
Verilog(Rust+旧C++)──► │  memory: 【空壳 → ★需建设】          │ ──► Verilog(成熟)
Liberty(Rust)─────────► │                                     │ ──► JSON  (写-only)
SPEF(Rust)────────────► │  ★ 往返矩阵 CI (§4.3, G1 前置)      │ ──► GDS:
SDF/AOCV/VCD──────────► │  ★ 格式覆盖表 (§4.7, 边界诚实)      │     文本(现, debug only)
SDC ✗(在 iSTA, G16缺口) └──────────────┬─────────────────────┘     ★二进制(§4.1, 流片)
                                        │
           ┌────────────────────────────┼────────────────────────────┐
           │ 数据完整性档（OA 线）       │        性能/容量档（G13 线）│
           ▼                            ▼                            ▼
     往返无损 CI              全工具 → iDB 消费        ★ 内存池/驻留策略
     格式覆盖表透明          (24 operation 模块)        ★ 增量更新 API
     属性映射文档化          dmInst 读写              ★ 容量剖面 (10万/50万/100万)
     GDS 二进制可信                                    load/save 墙钟分项
           │                            │                            │
           ▼                            ▼                            ▼
     G1 看板（§10.1）              调用方契约表（§8）         性能/容量看板（§10.2）
```

**核心架构判断**：数据完整性线与性能/容量线**共用同一个 iDB 数据模型、同一套 builder/parser**——差别只在「验证的深度（往返矩阵 vs 基础读写）」和「生效的优化策略（§5 双档表：全量档 vs 增量档）」。这与 Innovus「common database, 多 effort」同构；也直接否定「为快而再写一套轻量 DB」的路线（代价是口径分家，参考 27 号文档 §1.3 三套栈教训）。

### 3.2 关键设计决策（含被否）

| ID | 决策 | 被否方案 | 理由 |
|---|---|---|---|
| **D1** | **先修死换算与假成功，再做二进制 writer** | 直接上新 writer（会把 2000× 错误坐标编码进二进制） | 死换算修复是前置（FR-DB-01）；否则二进制产物仍错 |
| D2 | 二进制 writer **复用 `GdsData/Gds* POD`**，只新增 record 编码层 | 另起一套 GDS 数据模型（平行重写） | Composition 复用现有 19 个 POD 结构（§4.1） |
| D3 | GDS reader 走 `GdsData` 中间表示再进 iDB | reader 直插 iDB（两套语义映射） | 读改写共用一套 POD，代码复用率高 |
| **D4** | **往返矩阵"测试即规格"进 CI，字段清单即边界承诺** | 口头字段清单 / 等全通过再建 CI | 基础设施边界诚实纪律（KH-DB-02）；清单外丢失不阻断，清单内丢失 = G1 红 |
| D5 | 文本 GDS 保留为显式 debug 旗标 + WARN | 立刻物理删除（现网脚本可能依赖） | 零回归；二进制验收通过后降级 debug-only |
| **D6** | `manager/memory/` 空壳：容量剖面先落 benchmark 脚本，不新建目录 | 把空壳填实再测（新建内存池基础设施） | 无需求驱动，先量后建；剖面数据定义内存策略（不是反过来） |
| D7 | SDC 留在 iSTA，不进 iDB（本里程碑） | 为 G16 提前把 SDC 搬进 iDB | 超范围；G16 序列化选型未定（§14 记录） |
| **D8** | **格式覆盖表 P0（边界诚实先于盲追 OA 全特性）** | 先追 OA 全格式支持再记覆盖 | **KH-DB-02 核心**：无覆盖表的"格式支持" = 假支持（不知道跳过了哪些字段）。对照：OA 明确标注每个 API 版本支持的 DEF/LEF 子集。**被否原因**：追 OA 100% 特性 = 工作量数量级差；边界诚实（支持/跳过字段列表）= G1 可判定基础。 |
| **D9** | **增量 API 外挂（显式 `updateNet`/`modifyInstance`），缺省全量** | 内部自动识别脏数据增量 save | 显式契约可审计（§8）；自动识别 = 隐式魔法（易出 bug） |

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

### 4.6 ★ 增量更新 API（FR-DB-11，P1，性能线核心）

**设计**：参见上文 IncrementalDB 类设计 + 增量语义 + 下游切换表。

### 4.7 ★ 格式覆盖表（FR-DB-05，P0，边界诚实核心）

**设计**：参见上文 `docs/ai/attachments/idb-format-coverage.json` + CI 接入。

### 4.8 模块状态一览（成熟度 / 复杂度 / 边界 / 复用姿势）

| 模块 | 现状成熟度 | 主复杂度 | 关键边界 | 复用姿势（现状→目标） |
|---|---|---|---|---|
| def_read/def_write | 成熟（2330+1455 LOC） | O(对象数) | 属性保真无 CI | 保留 + 矩阵（§4.3） |
| verilog (Rust+旧C++) | 双读路径并存 | O(tokens) | 切换逻辑未审计 | 收敛或写明分工（FR-DB-08） |
| json_write / GJWriter | 写-only（952 LOC） | O(对象数) | 无 reader | 标记 BLOCKED 直至补 reader |
| `Gds*/GdsData` POD | 结构齐全（2201 LOC） | — | is_full flush 阈值需重审 | **Composition 复用**（§4.1/4.2） |
| `GdsiiTextWriter` | 调试级（566 LOC） | O(元素) | 非流片格式 | 降级 debug-only + WARN（D5） |
| `Def2GdsWrite` | DEF 换皮（858 LOC） | O(元素) | §1.2 四重缺陷 | 重排 + 接二进制后端（§4.5） |
| `GdsiiBinaryWriter` ★ | 无 | O(元素) | int32 溢出；excess-64 编码 | 新增（Composition POD，§4.1） |
| `GdsBinaryReader` ★ | 无 | O(字节) | 截断/未知 record | 新增（§4.2） |
| `IncrementalDB` ★ | 无 | O(dirty) | base checksum 校验 | 新增封套（§4.6） |
| `FormatCoverage` ★ | 无 | O(特性数) | 覆盖表与实现同步 | 新增活文档（§4.7） |
| `manager/memory/` | **空壳** | — | — | 不填实，剖面落 benchmark（D6，§4.4） |
| `CmdSaveGDS` | 假成功 | — | 丢 bool | 修返回值透传（FR-DB-01） |

---

## 5. 配置 / 双档表 / 迭代策略

### 5.1 可配表（缺省 = 现状零回归）

| 键 | 默认 | 说明 | 回归 |
|---|---|---|---|
| `gds.mode` | `binary`（落地后） | `binary` / `text_debug`；落地前唯一可用值是 text 且必须 WARN | 零回归 |
| `gds.layer_map` | PDK 侧车文件 | die/pin/net → (layer,datatype) 映射；**缺失即失败**，禁止硬编 | 新增必填 |
| `roundtrip.manifest` | repo 内清单 | §4.3 FIELD_MANIFEST 路径；CI 强制 | 新增 |
| `db.incremental` | `false` | 开启增量 API（§4.6）；缺省全量 | 零回归 |
| `db.validate_on_load` | `false` | 加载后数据校验（几何/拓扑合法性） | 零回归（新增开关） |
| `db.memory_profile` | `false` | 运行时内存剖面（RSS 采样） | 零回归 |

### 5.2 ★双档表（rv2.0 核心新增：同一数据库的两套配置）

**档 A/B = 数据完整性 effort（OA 线）**：

| 档 | name | 往返验证 | 格式覆盖 | 属性保留 | 用途 | 禁 |
|---|---|---|---|---|---|---|
| A | baseline | 基础读写 | 隐式 | 部分未知 | 现状行为（零回归基线） | — |
| B | certified | CI 矩阵强制 | 覆盖表透明 | 清单内 100% | G1 数据完整性保证 | 无矩阵宣称"无损" |

**轮 C/D = 性能/容量档（G13 线）**：

| 档 | name | 实例数 | 内存优化 | 增量 API | 用途 |
|---|---|---|---|---|---|
| C | daily | ≤10万 | 无 | 全量 | 日常小设计 |
| D | large | ≤100万 | 池化/驻留（§4.4 数据定义策略） | 增量（§4.6） | G13 大设计 |

**触发规则**：
- CI 回归一律档 B（数据完整性优先）
- 性能剖面走档 C/D（分档基线）
- 生产 flow 缺省档 A（零回归）；G1 验收通过后切档 B

### 5.3 迭代策略（评测向，非求解器 iter）

| 轮 | 数据完整性档 | 容量档 | GDS | 目的 |
|---|---|---|---|---|
| 0 | A（baseline） | C（daily） | text | 基线 / 零回归 |
| 1 | A | C | text | 修死换算 + 假成功（FR-DB-01） |
| 2 | B（certified） | C | binary | 往返矩阵 CI + 二进制 GDS（G1 起步） |
| 3 | B | D（large） | binary | 容量剖面（G13 爬坡） |
| 4 | B | D + incremental | binary | 增量 API（ECO 性能） |

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

## 8. 跨工具 Cascade——★调用方契约表（基础设施消费/提供双向契约）

| 调用方 | 消费契约（工具 → iDB） | 提供契约（iDB → 工具） | 单位/口径 | 现状判定 |
|---|---|---|---|---|
| 全工具（24 个 operation） | 经 `dmInst` 读写设计数据；API 稳定性承诺 | 数据模型一致性；版本兼容/deprecation 策略 | — | **半通**：骨架正确，但无版本策略（§1.5-#8） |
| iPL/iNO/iCTS/iTO/iRT | 读 instance/net/pin 拓扑 | 拓扑正确性；几何合法性 | DBU 整数 | 通；数据校验零散（§1.5-#9） |
| iSTA | 读 Liberty/SPEF（时序分析） | Liberty/SPEF 格式覆盖透明 | ns/fF/Ohm | **半通**：读路径在，覆盖表缺（§1.5-#5） |
| iRCX | 读 routing 几何 → 写 SPEF | SPEF 写出保真（耦合 C/电阻） | fF/Ohm | 通；SPEF 往返未验证 |
| iPW | 读 power net + activity（功耗分析） | VCD 解析 + power net 拓扑 | mW | 通 |
| evaluation | 读最终 DEF/GDS（L2 QoR 真源） | GDS 二进制可信 + 几何与 DEF 一致（抽样 0 偏差） | — | **GDS 断**：L2 若按 GDS 抽样，拿到文本示意图（坐标错 2000×） |
| platform | G16 session dump/restore | session 序列化包含全状态（design + constraints） | — | **缺**：无二进制 session；DEF 往返未证无损；SDC 不在 iDB |
| flow 脚本 | `regress_gcd.sh` 验收 GDS | 二进制 GDS 可被 foundry 接收（gdstk/klayout stream 打开） | — | **验收对象是文本 GDS**："过 regression"≠"可流片" |
| iTO/iPL ECO | 修改 instance/net 后继续优化 | 增量更新 API（局部修改无需全量重建） | — | **断**：无增量 API，每次 ECO 全量 save→reload（§1.5-#11） |

**闭环触发**：
- iTO ECO 后脏数据 → 增量 save（档 D） → 墙钟 <10% 全量 → 接受优化；否则拒绝增量（回退全量）
- evaluation L2 几何抽样 → GDS vs DEF 偏差 >DBU → iDB 写出失败，escalate 到 builder 层
- platform session restore → 往返矩阵 fail >0 → 拒绝 restore，要求 clean checkpoint

**契约分层**（对标 OA API 稳定性承诺）：
- **Tier 1（稳定 API）**：`dmInst`、`design/tech/circuit` 核心数据结构 → 承诺向后兼容（版本号 + deprecation 周期）
- **Tier 2（演进 API）**：builder/parser 扩展接口 → 可变更，但需 changelog + migration guide
- **Tier 3（实验 API）**：增量 API、session dump → 明确标注 experimental，可随时变更

---

## 9. 商业 Know-how 映射

| KH-ID | 含义 | 本工具落点 |
|---|---|---|
| KH-DB-01 | 二进制唯一流片真源（GDS stream format） | §1.2 / §4.1 / NFR-DB-01/03 |
| **KH-DB-02** | **边界诚实**（格式覆盖表透明 + 往返无损可证 + 属性映射文档化） | §1.5 / §4.3 矩阵 + §4.7 覆盖表 + KNOWN_LOSS |
| KH-DB-03 | 分层驻留/容量（内存池/大设计） | §4.4 剖面（memory/ 空壳记录在案，先量后建） |
| KH-DB-04 | 增量更新（ECO 后局部修改） | §4.6 IncrementalDB API |
| KH-X-04 | 响亮失败（写失败非零 rc） | §1.4 / FR-DB-01 / §7 |
| KH-X-01 | 同一真值源闭环 | G1 先于 L2 evaluation；§8 契约 |

---

## 10. 商业对照看板 + 演进 M0–M4

### 10.1 数据完整性看板（vs Innovus/ICC2 OA）

| 指标 | iEDA iDB | Innovus/ICC2 OA | Δ | 门槛 | 门禁 |
|---|---|---|---|---|---|
| 流片 GDS | 文本示意图 | 二进制 stream | 格式错 | gdstk/klayout 可读 | — |
| GDS 几何一致 | 坐标差 2000×（死换算） | 0 偏差 | 2000× | 抽样 0 偏差 | NFR-DB-02 |
| 往返丢失（DEF） | 无矩阵 | 0（OA 无损） | 不可知 | 清单内 **0** | **G1** |
| 往返丢失（Verilog） | 无矩阵 | 0 | 不可知 | 清单内 **0** | **G1** |
| 往返丢失（GDS） | 无矩阵 + 无 reader | 0 | 不可知 | 清单内 **0** | **G1** |
| 格式覆盖率（DEF 5.8） | 隐式（边界失明） | 明确子集标注 | 不透明 | 覆盖表进 CI | **G1** |
| 属性保留（PROPERTY） | 未验证 | 100% | 未知 | 往返矩阵验证 | G1 |
| 写失败可见 | rc 恒 0（假成功） | 响亮非零 | 3 层过滤 | rc≠0 | **G14** |
| API 稳定性 | 无承诺 | 版本号 + deprecation | 无策略 | 分层契约（§8） | — |

### 10.2 性能/容量看板（vs 商业 DB 大设计能力）

| 指标 | iEDA iDB | 商业基线 | Δ | 门槛 | 门禁 |
|---|---|---|---|---|---|
| 50 万实例 load 墙钟 | 未剖面 | — | 未知 | 记录→预算 | **G13** |
| 50 万实例 save 墙钟 | 未剖面 | — | 未知 | 记录→预算 | **G13** |
| 50 万实例峰值 RSS | 未剖面（memory/ 空壳） | — | 未知 | 记录→预算 | **G13** |
| 100 万实例可行性 | 未测 | 可（内存池） | 未知 | 通过 or 写清瓶颈 | G13 |
| 增量 save 加速比 | 无增量 API | ≥10×（ECO ≤100 net） | ∞（无 API） | ≥10× | — |
| ECO 后全量 reload 墙钟 | 主瓶颈（iTO 循环） | 增量 API 避免 | — | 增量 API 存在 | — |

### 10.3 对照实验（可执行设计，杀假说）

| ID | 实验 | 输入 | 命令/操作 | 判据（数值阈值） | 杀死假说/锁住契约 |
|---|---|---|---|---|---|
| **E-DB-01** | 验证当前 GDS 是文本 | 现有 GDS 产物 | `file gcd.gds; xxd gcd.gds \| head` | 若**不是** ASCII `HEADER` → §1.2-1 被杀（预期：是 ASCII） | 文本 GDS 实锤（M0） |
| **E-DB-02** | 验证死换算 | 修前后 GDS 坐标 | 修 `transDB2Unit` → 比较坐标值 | 若修后坐标变化 = `_unit_microns` 倍 → 坐实死换算 | §1.2-2 实锤（M0） |
| **E-DB-03** | 往返矩阵防假 | 故意丢 DEF STATUS | 跑矩阵 CI；矩阵是否报 fail | 若矩阵**不报** → 矩阵假（需修断言） | G1 防线有效性（M1） |
| **E-DB-04** | 写失败传播 | 注入写盘失败（只读目录） | `save_def /readonly/x.def`；检查 TCL rc | 若 TCL rc==0 → §1.2-4 实锤（预期：修后≠0） | G14 响亮失败（M1） |
| **E-DB-05** | 文本模式防护 | text_debug 进 release 流片脚本 | CI 检测 `gds.mode==text` | 若 CI 不拒 → 防护失效（预期：CI ERROR） | NFR-DB-03（M2） |
| **E-DB-06** | 二进制 GDS 可读 | 二进制 GDS 产物 | `gdstk.read_gds(x.gds)` / klayout stream 模式 | 若打开失败 or 报格式错 → 二进制编码有 bug | NFR-DB-01（M2） |
| **E-DB-07** | GDS 几何一致 | 同一 DEF，输出 DEF + GDS | 抽样 DEF 坐标 vs GDS 坐标；逐点比对 | 若偏差 >1 DBU → 坐标换算仍错 or layer map 错 | NFR-DB-02（M2） |
| **E-DB-08** | 容量瓶颈定位 | 100 万实例合成网表 | load + heap profiler（valgrind massif） | 若 RSS >预算 → 写清瓶颈（哪类对象占比最大） | G13 容量（M3） |
| **E-DB-09** | 增量正确性 | DEF base + ECO 10 net | 增量 save vs 全量 save；load 后比对 | 若 net 连接不一致 → 增量 merge 有 bug | 增量 API（M4） |

**实验设计原则**：
1. **注入可控**：手工制造失败条件（只读目录、故意丢字段）= controlled experiment
2. **判据机械**：文件头 magic/坐标数值/rc 值（非目视）
3. **锁住边界**：E-DB-03 的"矩阵必报 fail"= G1 防线的验证（不许假通过）

### 10.4 演进 M0–M4

| 里程碑 | 目标 | 交付 | 退出门禁 |
|---|---|---|---|
| **M0 先量** | 实锤报告（E-DB-01/02）+ 空壳/假成功台账 | hex 头 + 坐标比 + KNOWN_LOSS 初稿 | 报告入库；边界失明可追溯 |
| **M1 可信** | FR-DB-01（死换算+rc 透传）+ BinaryWriter + gtest | `transDB2Unit` 修复 + `CmdSaveGDS` 修复 + E-DB-02/04 绿 | NFR-DB-01/02；G14 响亮失败 |
| **M2 主算法** | GdsBinaryReader + 往返矩阵 CI（DEF/Verilog/GDS）+ 格式覆盖表 | 三格式矩阵 + `idb-format-coverage.json` | **NFR-DB-04（G1）** |
| **M3 打平** | 容量剖面（50万/100万）+ layer_map 真实 PDK 全量 GDS | `capacity_profile.csv` + 与金参考并排（12 联动） | **G13 容量基线** |
| **M4 纵深** | 增量 API（IncrementalDB）+ session 序列化选型 + OASIS 评估 | 增量 API + E-DB-09 + G16 方案 | 增量正确性；非本阶段阻断 |

**M0→M1→M2 是 G1 关键路径**（数据完整性可证）；**M3 是 G13 关键路径**（容量）；M4 为性能/G16 预留。

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

### 14.1 未验证（禁止写成事实）

- 当前任意设计 vs OA 的真实往返丢失字段数（**M0 前未知**）。
- DEF 5.8 全属性集（VERSION/PROPERTY/STATUS/REGION/GROUP/SLOT/MASK 等）的保留策略。
- LEF 5.7 OBS/ANTENNAMODEL/DENSITY 等扩展特性的往返保真性。
- Verilog 2001 generate/parameter/defparam 展开后的连接保真性。
- SPEF 往返保真性（iRCX 写出 → iDB 读入 → 再写出，耦合 C 是否丢失）。
- **SPEF 耦合电容是否真实落地到 `RcNet`**（iSTA SI 前置，类比 27 号文档 §14.1-5）。
- `dmInst` 全局单例是否线程安全（多工具并发读）。
- **50 万/100 万实例 load/save 墙钟/内存真实数值**（G13 基线，M0 打点产出）。
- 现网脚本是否已依赖文本 GDS（删/降级前须 grep `scripts/` + 用户 flow）。
- layer map 来源（die/pin/net → (layer,datatype) 无 PDK 侧车文件）——**deferred，缺即失败**。
- G16 session 格式选型（JSON 补 reader / DEF 往返无损 / 专用二进制 dump 三选一）——**未决**。
- Verilog 双读路径（Rust 新 vs `verilog_read.cpp` 1107 旧）切换逻辑与数值一致性。

### 14.2 负面 / 不要重走

| 项 | 结论 |
|---|---|
| 无 `transDB2Unit` 修复前写二进制编码器 | **禁止**——会把 2000× 错误坐标固化进二进制（比文本假成功更难发现）。D1 先行。 |
| 扩展 `GdsiiTextWriter`「更像」二进制 | **禁止**——文本流语义根本不是 record 流；重写编码层比改文件名便宜。D2。 |
| 把"parser 目录存在"当"支持该格式" | **禁止**——GDS 目录 21 个文件无 reader 是本案原型（§1.1 教训）。读写分开举证。 |
| 无往返矩阵 CI 宣称"格式无损支持" | **禁止**——边界失明 = 假支持（KH-DB-02）；清单内丢失 = G1 红线。D4/D8。 |
| 无格式覆盖表宣称"DEF 5.8 支持" | **禁止**——不知道跳过了哪些字段 = 假支持；对标 30 号 DRC 覆盖表纪律。§1.5-#5。 |
| 先建内存池基础设施再测容量 | **不推荐**——无需求驱动；剖面数据定义内存策略（不是反过来）。D6。 |
| 为 G16 提前把 SDC 搬进 iDB | **超范围**——SDC 现由 iSTA 消费；序列化选型未定。D7。 |
| 用 JSON 作 session 格式但不补 reader | **禁止**——有写无读 = 单向门（§1.1）；G16 需要 restore。 |
| 增量 API 内部自动识别脏数据 | **禁止**——隐式魔法易出 bug；显式契约可审计（§8）。D9。 |
| ★ 无格式覆盖表前盲追 OA 100% 特性 | **禁止**——边界诚实先于能力虚报（D8）；清单可追溯 > 功能全但边界失明。 |

### 14.3 相对 rv1.1 文档的纠偏与深化

- 「iDB 主问题是 GDS」→ 补充：**数据完整性机制缺失才是结构症结**（往返无损不可证、格式覆盖表零建设、属性映射不透明）——§1.5 新增 15 项机制对比，GDS 只是其中 1 项（#7）。
- 「memory/ 空壳是内存爬坡缺口」→ 深化为「容量剖面先落 benchmark 脚本，数据定义内存策略」——D6 + §4.4，不是反过来先建基础设施。
- 「往返矩阵待补」→ 升级为「测试即规格，清单即边界承诺」——D4 + §4.3 FIELD_MANIFEST，清单内丢失 = G1 红线（不是软建议）。
- 「格式支持隐式」→ 强化为「格式覆盖表 P0（边界诚实先于盲追 OA）」——D8 + §4.7，对标 30 号 DRC 覆盖表的 M0 前置地位。
- rv1.1 未提「增量 API」→ rv2.0 新增 §4.6 IncrementalDB（性能线核心），因 iTO ECO 循环墙钟主瓶颈是全量 save→reload（§1.5-#11）。

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
