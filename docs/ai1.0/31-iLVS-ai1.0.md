<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 31 · iLVS Agent 原生连通性与版图对照实施规格 · ai1.1

> 日期：2026-07-24。
>
> 当前成熟度：`D0 / greenfield`。仓库中没有 `src/operation/iLVS/`、iLVS API、可执行程序或 CMake target；本文的 TARGET 类型、目录和 API 均为实施规格，不代表已经编码。
>
> 首个可交付：独立导入 reference gate-level netlist 与 layout-side connectivity，完成标准单元数字设计的结构化 compare、mismatch witness、coverage 和外部 LVS adapter；纯 GDS 器件识别、模拟参数 reduction 和 foundry signoff 后置。
>
> 安全底线：缺 parser、device、rule、mapping 或 coverage 时结果只能是 `UNKNOWN`、`PARTIAL` 或 `UNSUPPORTED`，绝不能推断等价或签发 `PASS`。

---

## 0. 产品目标、非目标与唯一责任
### 0.1 产品目标
iLVS 是面向 Agent 的只读验证服务，不是一个返回 `clean=true` 的脚本包装器。
它必须把“比较了什么、依据什么、没比较什么、为何失败”编码为可重放对象。
首版目标如下：

- 独立导入 reference source 与 layout-side connectivity，阻止同源恒等式假通过；
- 将名字、层次、单位、器件和端口语义规范化为版本化 `CanonicalGraph`；
- 在声明的标准单元数字子集内检测 open、short、missing、extra 和 pin mismatch；
- 对 hierarchy preserve、selective flatten 和 blackbox port compare 给出显式决策；
- 对对称结构保留 ambiguity class，不任意固定一个对象映射；
- 为每个 mismatch 生成最小或有界的相关子图、源位置和归因路径；
- 支持 Agent 查询 capability、启动 compare、解释结果、取消和重放；
- 为 iECO 候选提供 connectivity 门禁输入，但不替 Runtime 提交设计；
- 接入 Netgen、Calibre nmLVS、PVS 等外部结果，保留工具差异和 coverage；
- 用增量结果加速候选筛选，并以保守 dirty closure 和 full fallback 保证安全；
- 以故障注入、property、metamorphic、fuzz 和差分 oracle 量化资格。

目标工作流：

```text
immutable base/candidate snapshots + independent source artifacts
  -> capability and provenance validation
  -> source/layout import with explicit coverage
  -> canonicalization under exact policy and TechContext
  -> graph partition/refinement/matching
  -> independent mapping replay
  -> MatchResult + MismatchWitness[] + EvidencePack
  -> Verification Hub evaluates claim coverage
  -> Runtime may select/commit; iLVS never commits
```

### 0.2 非目标
- 首版不宣称替代 Calibre nmLVS、PVS 或 foundry-qualified signoff flow；
- 首版不从纯 GDS/OASIS 自动识别任意 MOS、BJT、diode、resistor、capacitor；
- 首版不自行发明 foundry layer map、device recognition rule 或 reduction rule；
- 首版不把 DEF 中已有 net labels 当作独立物理抽取真值；
- 首版不实现逻辑功能等价；该 claim 属于 iFormal，而 connectivity 等价属于 iLVS；
- 首版不把名称相同、对象数量相同或 process return code 0 当作 LVS PASS；
- 首版不允许 Agent 自由文本生成 rule deck、shell、Tcl 或 vendor 命令；
- 首版不允许外部工具直接修改主 snapshot 或覆盖 reference artifact；
- 首版不保证 analog parameter tolerance、series/parallel reduction 和 permutable terminals；
- 首版不将 blackbox 内部未检查内容计入完整 coverage；
- 首版不将局部 compare 的结论扩张为 full-chip PASS；
- 首版不在 iLVS 内维护另一套 iDB snapshot、Technology 或 certificate 真值。

### 0.3 唯一责任与模块所有权
| 模块 | 唯一负责 | 明确不负责 |
|---|---|---|
| iLVS（本文） | connectivity import contract、canonical graph、compare、witness、coverage、增量/full 一致性 | 修改设计、提交 branch、逻辑功能证明、foundry rule 真值 |
| iDB（10） | immutable snapshot、ObjectRef、TypedDelta、DirtySet、结构完整性、artifact lineage | 宣称 layout 与 reference 等价 |
| iFormal（34，TARGET） | reference/revised 逻辑功能等价、proof/counterexample | 版图几何抽取与物理连通性 |
| Technology（55） | layer-purpose、via/device/cell/rule mapping 与 qualification | 根据名字猜等价关系 |
| iECO（32） | 领域 workflow 模板、proposal、compensation 编排 | 绕过 connectivity/formal/DRC gate |
| Verification Hub（49） | validator DAG、claim coverage、certificate、invalidation | 实现 matcher 或修改 iLVS 结论 |
| Agent Runtime（43） | branch、预算、取消、候选选择、commit CAS | 伪造或放宽 iLVS coverage |
| External Bridge（57） | 固定 adapter、隔离执行、artifact、parser、protocol | 自动授予商业工具 F4 资格 |
| Data/Oracle（47） | oracle protocol、qualification、差分数据治理 | 隐藏 oracle disagreement |

核心分界是：iDB 的 `state.connectivity@1` 只证明数据库内部双向关系完整，
iLVS 的 `layout_vs_source.connectivity@1` 才比较两个独立来源，
iFormal 的 `functional.equivalent@1` 再证明逻辑行为。
三者不能互相替代。

---

## 1. CURRENT 有界事实审计
### 1.1 审计范围与结论
本次审计只查看仓库内源代码、CMake 和相邻 ai1.0 文档，不把规划文字当实现。
结论是：iLVS kernel/API 不存在；可复用的是 iDB 逻辑对象、路由几何、部分 parser、局部 continuity checker 和初始 artifact/state 基础。

| 证据 | CURRENT 事实 | 可复用定位 | 不能据此声称 |
|---|---|---|---|
| `src/operation/CMakeLists.txt` | 列出 iDRC/iECO/iSTA/iRCX 等，无 iLVS/iFormal subdirectory | 新 target 的接线位置 | 已有 iLVS 或 formal engine |
| `src/operation/` | 不存在 `iLVS/` 与 `iFormal/` 目录 | greenfield 边界证据 | 文档 API 已可调用 |
| `src/database/data/design/IdbDesign.h` | 持有 instance/net/io pin/special net/wire 等容器 | layout-side logical view adapter | 独立 physical extraction |
| `IdbNet.h` / `IdbPins.h` / `IdbInstance.h` | 有 net、pin、instance 关系和原始名称 | F0/F1 connectivity inventory | stable cross-snapshot ObjectId |
| `IdbCellMaster.h` | 有 master name、term、geometry/type | std-cell/blackbox seed metadata | function、equivalent pin 或 device model 完整 |
| `IdbBuilder::buildDef` | DEF 导入后构造 net/bus | legacy layout adapter | DEF labels 是独立 LVS extraction |
| `IdbBuilder::rustBuildVerilog` | Rust parser 读取 Verilog 并创建 iDB；默认/指定 top | reference adapter 候选 | parser 支持所有 Verilog/netlist 语法 |
| `rust_flatten_module` | parser API 有 flatten 操作 | flat digital reference 首切片 | preserve hierarchy/source span 完整 |
| `IdbBuilder::saveGDSII` | 从 DEF/iDB 写 GDS text/data | debug/export artifact | 仓库能读取 binary GDS 并识别器件 |
| `manager/parser/gdsii` | CMake 构建 data classes 与 `GdsiiTextWriter` | GDS model/writer 的代码复用 | production GDS/OASIS reader |
| `CheckNet` | 对一个已声明 net 的 pin/route segment 做相交图和连通检查 | F0 continuity diagnostic | 跨 net short 检测或 source/layout LVS |
| `src/platform/design_state` | 有 `DesignState`、`DirtySet`、`MoveTxn`、`ArtifactIndex` 小型实现 | TARGET snapshot/adaptor 的 seed | 完整 immutable branch/CAS/runtime |
| `ArtifactIndex` | ready artifact 要 path、SHA-256、state version | provenance/freshness adapter | content-addressed evidence store 已完备 |
| external process 搜索 | 除局部 solver `system()` 外无统一 runner/bridge | 证明 External Bridge 尚待实现 | 安全 external LVS adapter 已存在 |

### 1.2 iDB 与 netlist 能力的准确边界
`IdbBuilder` 当前可以先装载 LEF，再装载 DEF 或 gate-level Verilog。
这使 iLVS 可以写只读 adapter，将 legacy 对象复制到独立 canonical store。
但该 store 必须记录下列未知项：

- parser 接受的语法子集和所有 diagnostics；
- flatten 造成的层次、array 和 generate 信息损失；
- constant、assign、escaped name、bus slice/concat 的实际展开覆盖；
- cell master 未在 LEF 找到时的处理；
- port direction 与 PG pin 语义是否来自一致的库；
- DEF SPECIALNETS、regular nets 和 logical net 的关系；
- wire/via shape 是否完整、是否含 pin access 或仅布线结果；
- unit scale、manufacturing grid、layer purpose 与 source map；
- fill、filler、tap、decap、antenna diode 是否应进入 compare；
- route status、unrouted segment、virtual connection 是否可比较。

任何一项不能由 adapter 证明时，必须进入 `Coverage.unknown` 或 `unsupported`。
adapter 不得用空列表表示“输入里没有该对象”。

### 1.3 GDS、DEF 与 physical extraction 边界
当前仓库的 GDS 相关公开入口是写出路径。
目录名 `gdsii-parser` 不能代替 reader 能力证据；审计到的 target 由 `aux_source_directory` 组装 data class 和 text writer，
没有可供 iLVS 调用的 binary GDS read + polygon connectivity + device recognition API。

因此 TARGET 输入分三种：

| layout 输入 | 首版语义 | 最高可声明状态 |
|---|---|---|
| iDB/DEF declared nets | 对已有 net membership 与 route continuity 做结构 compare | `F1 DECLARED_CONNECTIVITY` |
| 外部 extractor normalized result | 独立 layout-side connectivity/device graph | 取决于 adapter qualification，最高 F4 |
| pure GDS/OASIS | 当前无 reader/device/rule pipeline | `UNSUPPORTED` |

`F1 DECLARED_CONNECTIVITY` 可用于发现 ECO reconnect、missing/extra instance 和 declared-net open，
但不能证明两个不同 net 的几何没有意外短接，也不能证明 diffusion/poly 形成的器件。
对这种输入返回 `MATCH` 必须把 claim 限定为 `declared_connectivity`，不能序列化成 signoff LVS PASS。

### 1.4 CURRENT checker 的可复用与限制
`src/platform/data_manager/checker/check_connection.cpp` 将 pin 和 regular wire segment 包装为 Boost undirected graph，
通过 shape intersection 判断同一 IdbNet 内的 pin 是否落在同一 component。
它可以作为 migration shadow sensor，但有以下限制：

- 构图对象已经按 IdbNet 分组，无法天然发现不同 net 之间的 bridge short；
- pin-to-pin 不直接连接，依赖 route segment；
- 只看 regular wire 路径，special net、device layer 和 extraction rule 未形成统一语义；
- 当前代码没有 coverage、provenance、stable ID 或 structured evidence contract；
- 递归/两两扫描和几何精度未经过 LVS 规模资格；
- `connected` 只说明该 net 内部图连通，不说明与 reference net 对应。

TARGET `IdbDeclaredConnectivityAdapter` 可以调用或双跑该 checker，
但必须重新生成独立 graph，并用自己的 exact coverage/result schema 包装。

### 1.5 缺失资产台账
以下资产在本次 bounded audit 中未找到，因此全部标为 greenfield：

- iLVS service、CLI、matcher、canonical schema 和 tests；
- SPICE/CDL/Spectre reference parser；
- binary GDS/OASIS reader；
- polygon connectivity extractor；
- MOS/BJT/diode/resistor/capacitor recognition；
- device series/parallel/finger reduction；
- LVS deck compiler、rule coverage 与 foundry qualification；
- equivalent pin/function metadata 的统一读取；
- Netgen/Calibre/PVS adapter、report parser 和 golden corpus；
- External Bridge 运行时实现；
- Verification Hub 的统一 certificate 实现；
- production immutable snapshot/CAS/branch service；
- iFormal kernel/API。

### 1.6 CURRENT、adapter-first 与 greenfield 的迁移边界
| 层 | 实施策略 | 允许复用 | 强制隔离 |
|---|---|---|---|
| CURRENT legacy | 只读审计和 shadow | iDB object traversal、Verilog parser、CheckNet | 不直接暴露 raw pointer 给 Agent |
| Adapter-first | 先做 manifest/import/normalize/external report | 已有 parser 和外部成熟 LVS | parser coverage、source spans、tool hash |
| Greenfield kernel | canonical graph、matcher、witness、incremental planner | Boost/成熟图算法可评估 | 不从 layout graph clone reference |
| Future extraction | GDS reader、geometry connectivity、device/rule engine | 经过选型的成熟库/adapter | 独立 qualification，不继承 digital claim |

迁移期间 legacy 与 TARGET 结果并行记录。
只有 contract tests 证明对象、diagnostic 和 coverage 对齐后，Agent capability 才从 `EXPERIMENTAL` 晋级。

---

## 2. 产品切片、成熟度与 fidelity
### 2.1 首版支持域
首版产品域是 post-place 到 post-route 的标准单元数字设计：

- reference：受限 structural Verilog，明确 top、library、parser 和 flatten policy；
- layout side：iDB/DEF declared connectivity，或 qualified external extractor 的 graph；
- cell：标准单元按 master + ordered pin role；
- macro：只允许显式 blackbox，比较端口集合与连通性；
- hierarchy：flat、preserve 或 selective flatten，policy 必须写入结果；
- PG：VDD/VSS/global net 仅按显式 namespace/policy 处理；
- mismatch：open、short、missing/extra instance/net/port、pin mismatch；
- incremental：只对 typed delta 生成保守 scope，并定期/触发 full compare；
- external：Netgen 作为开源差分 oracle，Calibre/PVS 作为候选商业 oracle。

### 2.2 Fidelity 定义
| Fidelity | 计算内容 | 允许用途 | 禁止 claim |
|---|---|---|---|
| F0 | manifest/schema/provenance/count/hash sanity | 早期拒绝坏输入 | connectivity equivalent |
| F1 | iDB/DEF declared-net compare + per-net continuity | ECO 快筛、结构诊断 | geometry/device LVS clean |
| F2 | 独立 source graph 与 layout connectivity graph 的 deterministic matcher | supported digital subset gate | 未覆盖 device/rule 的 full LVS |
| F3 | full-scope in-tree supported subset，含独立 replay、资格和 coverage threshold | Hub 的限定 claim | foundry signoff |
| F4 | qualified Netgen/Calibre/PVS protocol，固定 deck/report point/tool build | high-risk oracle/signoff comparator | 超出 protocol 的隐式 truth |

Fidelity 是语义和资格，不是单纯运行时间。
工具品牌、effort 选项或 report 中的 `CORRECT` 字样都不能自动赋予 F4。

### 2.3 Capability maturity
| 等级 | 交付条件 | Registry 可见状态 |
|---|---|---|
| D0 | 只有本文规格和 CURRENT audit | `UNAVAILABLE` |
| D1 | schema、manifest、handwritten graph tests | `EXPERIMENTAL` |
| D2 | independent import + F1/F2 matcher + fault tests | `SHADOW` |
| D3 | 三个真实设计族、增量/full 对拍、Netgen differential | `QUALIFIED_SUBSET` |
| D4 | 固定 PDK/tool/protocol 与商业 oracle 达量化 DoD | `PRODUCT_SUBSET` |
| D5 | foundry/组织 signoff qualification | 独立治理，不由本文自动授予 |

### 2.4 Claim 命名
禁止公共 API 返回无作用域的 `lvs.clean`。
首批 claim 使用以下名称：

```text
layout_vs_source.manifest_valid@1
layout_vs_source.declared_connectivity@1
layout_vs_source.digital_connectivity@1
layout_vs_source.blackbox_ports@1
layout_vs_source.device_subset@1
layout_vs_source.full_protocol@1
```

每个 claim 绑定 exact input refs、scope、fidelity、device/rule coverage 和 policy。

---

## 3. 功能需求、非功能需求与不变量
### 3.1 功能需求
| ID | 需求 | P | 验收要点 |
|---|---|---:|---|
| FR-LVS-01 | capability discovery 返回 input/device/rule/hierarchy/fidelity 域 | P0 | 未实现能力不出现在 supported |
| FR-LVS-02 | reference 与 layout input manifest 独立校验 | P0 | 同 artifact/hash/store identity 拒绝 |
| FR-LVS-03 | structural Verilog 导入并记录 parser coverage | P0 | unknown syntax 非空即非 full |
| FR-LVS-04 | iDB/DEF declared connectivity adapter | P0 | claim 限定为 F1 |
| FR-LVS-05 | external extracted connectivity 导入 | P0 | schema/protocol/source span 完整 |
| FR-LVS-06 | canonicalize names、units、hierarchy、devices、nets、ports | P0 | semantic policy ref 参与 graph hash |
| FR-LVS-07 | flat digital graph compare | P0 | rename/permutation 保持结论 |
| FR-LVS-08 | open/short/missing/extra/pin mismatch 分类 | P0 | fault injection 逐类命中 |
| FR-LVS-09 | hierarchy preserve/selective flatten | P1 | boundary mapping 可审计 |
| FR-LVS-10 | blackbox 端口 compare | P0 | 内部 coverage 明确 excluded |
| FR-LVS-11 | PG/global net 显式策略 | P0 | 不按名字隐式短接 |
| FR-LVS-12 | array/bus/escaped name 规范化 | P0 | source spelling 可回指 |
| FR-LVS-13 | device 参数与 tolerance rule schema | P1 | 未支持时 UNSUPPORTED，不近似 |
| FR-LVS-14 | 对称结构输出 ambiguity classes | P0 | mapping 非唯一仍可证明结构等价 |
| FR-LVS-15 | bounded matching budget | P0 | 耗尽为 UNKNOWN，不是 PASS |
| FR-LVS-16 | independent connectivity replay 验证 mapping | P0 | matcher 自身错误可被第二路径发现 |
| FR-LVS-17 | mismatch witness 与 explain API | P0 | 每项可定位双方对象/source spans |
| FR-LVS-18 | coverage/evidence pack | P0 | checked/skipped/unknown/unsupported 守恒 |
| FR-LVS-19 | incremental dirty-scope compare | P1 | scope 保守过近似，跨界扩张 |
| FR-LVS-20 | incremental/full consistency audit | P0 | disagreement 立即降级 capability |
| FR-LVS-21 | full fallback policy | P0 | scope 不可证明时自动请求 full |
| FR-LVS-22 | External Bridge adapter protocol | P0 | raw artifact 到字段 source span |
| FR-LVS-23 | Netgen differential oracle | P1 | 支持子集逐 mismatch 对拍 |
| FR-LVS-24 | Calibre/PVS commercial oracle | P1 | 固定 deck/tool/report point |
| FR-LVS-25 | asynchronous status/cancel/replay | P0 | cancel 不产生 terminal PASS |
| FR-LVS-26 | Verification Hub validator result | P0 | Hub 无法从 partial 签 full claim |
| FR-LVS-27 | iECO delta validation | P0 | exact candidate head 和 base 绑定 |
| FR-LVS-28 | deterministic serialization/hash | P0 | 重排输入/线程不改 semantic result |
| FR-LVS-29 | cache/invalidation | P1 | context/parser/tool/rule 变化失效 |
| FR-LVS-30 | report schema migration | P1 | major 未知拒绝，旧 evidence 可重放 |

### 3.2 非功能需求
| ID | 要求 |
|---|---|
| NFR-LVS-01 | 所有 read/compare 接受 immutable refs，不读取隐式 current design。 |
| NFR-LVS-02 | 相同 graph、policy、tool/parser hash 和 budget 产生相同 canonical result。 |
| NFR-LVS-03 | 匹配算法对输入遍历顺序、地址、线程调度和 hash-map seed 不敏感。 |
| NFR-LVS-04 | stable ID 不使用裸 pointer、vector index、临时路径或 wall clock。 |
| NFR-LVS-05 | 单位转换使用 exact rational/integer；溢出和非整除显式失败。 |
| NFR-LVS-06 | `PARTIAL/UNKNOWN/UNSUPPORTED/TIMEOUT/CANCELLED` 永不映射为 PASS。 |
| NFR-LVS-07 | cache key 包含两侧 graph hash、policy、TechContext、scope、implementation hash。 |
| NFR-LVS-08 | 外部执行固定 argv/template，禁 `shell=True` 和 Agent 文本插入。 |
| NFR-LVS-09 | 原始专有 deck/report 受 tenant/license/retention ACL 管理。 |
| NFR-LVS-10 | timeout/cancel 必须终止 descendant，并保留已封存的 partial evidence。 |
| NFR-LVS-11 | 性能按冻结 benchmark protocol 发布 median/MAD/p95/RSS，不杜撰绝对速度。 |
| NFR-LVS-12 | parser 或 schema drift 必须 quarantine qualification，不能填默认字段。 |
| NFR-LVS-13 | 所有 mismatch 分类都能从 normalized 结果回指原始 artifact。 |
| NFR-LVS-14 | Agent-facing API 不暴露 legacy iDB raw pointer 或 mutable singleton。 |
| NFR-LVS-15 | 一个 tenant 的 graph、deck、report、cache 和名字不能被另一个 tenant 推断。 |

### 3.3 红线不变量
1. `reference.provenance.artifact_ref != layout.provenance.artifact_ref`。
2. 两侧 importer instance、arena、object address space 和 build lineage 不共享。
3. canonicalization 只能消除声明的表示差异，不能删除未理解语义。
4. 未解析 source statement 必须计入 coverage，不能无声跳过。
5. 未识别 layout layer、purpose、via、device 或 label 必须计入 coverage。
6. 名称只可作 qualified seed/hint，不能单独证明映射。
7. global/PG net 只按显式 rule 合并，不能按 `VDD*`/`GND*` 模糊匹配。
8. blackbox PASS 只证明 boundary ports，不证明内部。
9. tolerance 只作用于指定 device/property/unit/domain，不设全局百分比。
10. ambiguity 可以与等价并存，但 search exhaustion 不能与 PASS 并存。
11. mapping 产生后必须由独立 replay 检查每条声明 connectivity。
12. witness 缺失不能把已知 mismatch 降为 UNKNOWN；必须保留最小原始证据。
13. incremental scope 必须是实际影响的保守超集，不能为性能缩小。
14. local PASS 只能覆盖 declared scope，不外推 full design。
15. incremental 与 full disagreement 时 full 优先，incremental qualification 失效。
16. external rc=0、`CORRECT` 文本或 0 个 parsed mismatch 都不是充分 PASS 条件。
17. missing expected report、parser field 或 coverage manifest 使结果非 PASS。
18. Verification Hub 只能为 exact snapshot/context/scope 签 certificate。
19. iECO/Runtime 不得通过改 policy ref 重用旧 iLVS result。
20. 任何证据 artifact 发布后 immutable；重跑创建新 attempt，不覆盖。

---

## 4. TARGET 总体架构与数据流
### 4.1 组件图
```text
Reference artifacts                       Layout-side artifacts
Verilog / future CDL             iDB snapshot / DEF / external extraction
        |                                      |
ReferenceImporter                         LayoutImporter
        | SourceNetlist                        | LayoutConnectivity
        +------------------+-------------------+
                           v
                    Canonicalizer
             policy + TechContext + coverage
                           |
              independent CanonicalGraph pair
                           |
          Partitioner -> Refiner -> Matcher -> MappingReplay
                           |
              MatchResult + MismatchWitness[]
                           |
          EvidenceBuilder -> CAS / ArtifactIndex adapter
                           |
         Verification Hub -> Runtime / iECO / Observer

External Bridge: Netgen / Calibre / PVS
  -> raw reports -> qualified parser -> normalized MatchResult
  -> OracleComparator compares class/object/coverage, not one bool
```

### 4.2 请求数据流
```text
validate request schema/auth/budget
  -> resolve immutable source/layout/tech/policy refs
  -> capability intersection and fidelity eligibility
  -> validate provenance independence
  -> import each side in separate worker/store
  -> seal raw normalized models and coverage
  -> canonicalize each side independently
  -> compare graph metadata and early invariants
  -> partition/refine/match under budget
  -> replay proposed mapping by independent verifier
  -> classify mismatches/ambiguity/unknown
  -> seal evidence and publish result
  -> Hub evaluates requested claim coverage
```

每一箭头都产生 phase status、diagnostics、input/output ref 和 resource usage。
后阶段不得覆盖前阶段的 `PARTIAL` 或 `UNSUPPORTED`。

### 4.3 失败短路顺序
1. schema、ACL、artifact integrity；
2. reference/layout independence；
3. parser/device/rule capability；
4. units、namespace、top、hierarchy compatibility；
5. import coverage；
6. graph structural sanity；
7. matching；
8. replay；
9. evidence completeness；
10. claim policy。

早期失败仍返回结构化 `LvsOperationResult`，但不构造伪空 graph。

### 4.4 核心设计决策
| 决策 | 选择 | 原因 |
|---|---|---|
| source store | 两侧独立 worker/arena + sealed artifact | 防同源/共享对象假通过 |
| internal model | typed bipartite/hypergraph，非字符串 pair 列表 | 表达 instance-pin-net-hierarchy/device |
| canonical order | kind/type/semantic key/stable ID 排序 | 可重放、可 diff |
| matching | seeds + partition refinement + component search | 避免全图暴力同构 |
| ambiguity | 保留 equivalence class | 对称电路不存在唯一正确名字映射 |
| verdict | status 与 coverage 正交 | 0 mismatch 不等于完整比较 |
| local mode | conservative closure + full fallback | 防跨 scope short/open 漏报 |
| external | raw + normalized + protocol validation | 防 report parser 假成功 |

---

## 5. Agent API 与 capability contract
### 5.1 公共 API
```text
lvs.capabilities(context_ref, requested_claim)
lvs.import_reference(ReferenceImportRequest)
lvs.import_layout(LayoutImportRequest)
lvs.canonicalize(CanonicalizeRequest)
lvs.compare(CompareRequest)
lvs.explain(ExplainRequest)
lvs.validate_delta(DeltaValidationRequest)
lvs.status(operation_id)
lvs.cancel(operation_id, reason)
lvs.replay(EvidencePackRef)
lvs.compare_oracle(OracleComparisonRequest)
```

API 名称是 TARGET contract；CURRENT 没有这些入口。

### 5.2 `CapabilityDescriptor`
```yaml
capability: layout_vs_source.digital_connectivity@1
implementation: ilvs.matcher@sha256
maturity: SHADOW
fidelities: [F0, F1, F2]
reference_formats: [structural_verilog_subset]
layout_formats: [idb_declared_connectivity, normalized_external_graph]
devices: [stdcell]
hierarchy_modes: [flat, preserve, selective_flatten]
blackbox: boundary_ports_only
incremental: conservative_scope_with_full_fallback
limits:
  vertices: 10000000
  backtrack_states: 100000
unsupported:
  - pure_gds_device_extraction
  - spice_cdl
  - mos_parameter_reduction
qualification_ref: null
```

Registry 发布的是 environment + implementation + TechContext 的交集。
字段缺失时调用方不得假定默认支持。

### 5.3 `CompareRequest`
```yaml
schema: ilvs.compare.request@1
request_id: uuid
reference_ref: sha256:source-netlist
layout_ref: sha256:layout-connectivity
tech_context_ref: sha256:tech
equivalence_policy_ref: sha256:policy
scope:
  kind: full_design
  roots: []
fidelity: F2
hierarchy_mode: selective_flatten
budget:
  wall_ms: 600000
  cpu_ms: 2400000
  rss_bytes: 8589934592
  backtrack_states: 100000
  witness_vertices: 500
require:
  complete_import: true
  complete_device_coverage: true
  independent_replay: true
idempotency_key: uuid
```

`scope.kind=dirty` 时还必须提供 base/candidate snapshot、TypedDelta、DirtySet 和 full-fallback policy。

### 5.4 `LvsOperationResult`
```text
LvsOperationResult
  operation/request/attempt IDs
  phase + terminal status
  exact input/context/policy/implementation refs
  requested/actual fidelity
  phase results and diagnostics
  source/layout/canonical graph refs
  match result/evidence pack refs
  resource usage and budget disposition
  retryability/cancellation/replay metadata
```

`terminal status` 使用：

```text
PASS | PASS_WITH_AMBIGUITY | MISMATCH | PARTIAL | UNKNOWN |
UNSUPPORTED | INVALID_INPUT | INVALID_INDEPENDENCE | TIMEOUT |
CANCELLED | FAILED | INTERNAL_INCONSISTENCY
```

只有前两个状态可表达等价，且仍须满足 requested claim 的 coverage policy。

### 5.5 错误码
| Code | 语义 | 可重试 |
|---|---|---|
| `LVS_INPUT_HASH_MISMATCH` | artifact 内容与 manifest 不符 | 否 |
| `LVS_SOURCE_LAYOUT_ALIAS` | 两侧 artifact/store/build lineage 同源 | 否 |
| `LVS_PARSER_UNSUPPORTED` | 格式/语法不在 parser domain | 需换 adapter |
| `LVS_TOP_AMBIGUOUS` | top module/cell 非唯一 | 修请求 |
| `LVS_UNIT_UNRESOLVED` | 单位缺失/冲突/溢出 | 修 TechContext |
| `LVS_LAYER_UNMAPPED` | layout layer-purpose 无 mapping | 修 Technology |
| `LVS_DEVICE_UNSUPPORTED` | device recognition/normalization 不支持 | 换 fidelity/tool |
| `LVS_RULE_UNSUPPORTED` | equivalence/reduction rule 不支持 | 换 policy/tool |
| `LVS_HIERARCHY_UNRESOLVED` | flatten/preserve boundary 不可对齐 | 修 policy |
| `LVS_MATCH_BUDGET_EXHAUSTED` | 搜索未完成 | 扩预算/换算法 |
| `LVS_MAPPING_REPLAY_FAILED` | matcher mapping 与独立 replay 矛盾 | 否，quarantine |
| `LVS_EVIDENCE_INCOMPLETE` | witness/coverage/provenance 不完整 | 否，修实现 |
| `LVS_EXTERNAL_PROTOCOL_INVALID` | 外部 report point/schema/coverage 不符 | 修 adapter |
| `LVS_INCREMENTAL_UNSAFE` | dirty closure 无法证明保守 | 自动 full |

---

## 6. 生命周期、状态机与取消
### 6.1 Operation 状态机
```text
CREATED -> VALIDATING -> IMPORTING -> CANONICALIZING -> MATCHING
MATCHING -> REPLAYING -> EXPLAINING -> SEALING -> TERMINAL

VALIDATING -> INVALID_INPUT | INVALID_INDEPENDENCE | UNSUPPORTED
IMPORTING/CANONICALIZING -> PARTIAL | UNKNOWN | UNSUPPORTED | FAILED
MATCHING -> MISMATCH | UNKNOWN | TIMEOUT | FAILED
REPLAYING -> INTERNAL_INCONSISTENCY
any nonterminal -> CANCELLING -> CANCELLED
```

`MISMATCH` 可以在 matching 早期确定，但仍要经过 evidence sealing。
如果 evidence sealing 失败，terminal 为 `FAILED`，不能只返回内存里的 mismatch 列表。

### 6.2 Graph artifact 状态
```text
ABSENT -> BUILDING -> NORMALIZED -> VALIDATED -> SEALED
BUILDING/NORMALIZED -> PARTIAL | UNSUPPORTED | CORRUPT
SEALED -> immutable; any semantic change creates a new ref
```

reference 和 layout graph 分别推进；一侧失败不能借用另一侧字段补齐。

### 6.3 Cancel、timeout 与 retry
- cancel token 在 parser batch、partition iteration、search node 和 witness expansion 边界检查；
- cancel 后停止产生新 mapping，封存已完成 phase 的 evidence；
- timeout 与 user cancel 分开编码，二者都不能产生 PASS；
- retry 复用 sealed inputs，不复用未封存临时 graph；
- 相同 idempotency key 返回同一 active/terminal operation；
- 增加预算创建新 attempt，并引用旧 attempt，不覆盖旧 evidence；
- external job 取消由 Bridge 杀 process group，iLVS 只消费已封存结果；
- worker crash 后恢复只能从 sealed phase artifact 开始。

### 6.4 Compare verdict lattice
```text
INVALID/UNSUPPORTED/FAILED
          |
        UNKNOWN
          |
        PARTIAL
       /       \
MISMATCH      PASS_WITH_AMBIGUITY
                  |
                 PASS
```

该图只表达信息完整度，不定义错误严重程度。
`MISMATCH` 是确定的反例，不因 coverage 还有未知而消失；结果可同时记录 `known_mismatch=true` 和 incomplete coverage。

---

## 7. 统一数据契约与 schema
### 7.1 公共 identity 与 provenance
```text
ArtifactProvenance
  artifact_ref + sha256 + byte_size
  media_type + schema/version
  tenant/license/retention labels
  producer adapter/tool/parser/build hashes
  source URI alias (redacted in Agent view)
  imported_at + attempt_id
  parent refs + transformation trace
  diagnostics ref + signature/attestation ref
```

`imported_at` 不参与 semantic hash。
路径仅用于审计，不是 identity。

```text
StableId
  namespace_ref
  kind
  local_key
  generation
```

`namespace_ref` 至少包含 design lineage、source side、schema major 和 TechContext。
`local_key` 由 canonical semantic path + disambiguator 生成；冲突显式失败，不能靠遍历序号消歧。

### 7.2 `SourceNetlist`
```yaml
schema: ilvs.source_netlist@1
id: sha256:...
provenance_ref: sha256:...
format: structural_verilog_subset
top: {module_id: ref:module:top, original_name: top}
hierarchy_policy: {mode: preserve, policy_ref: sha256:...}
units: {parameter_scale: exact, source: language_default}
modules: [ref:module:top]
instances: [ref:instance:top/u1]
nets: [ref:net:top/n1]
ports: [ref:port:top/A]
assigns: [ref:alias:top/a0]
globals: []
coverage_ref: sha256:...
diagnostics_ref: sha256:...
semantic_hash: sha256:...
```

Source importer 保留 statement source span、escaped spelling、bus range direction、constant width 和 assign lineage。
unsupported primitive、UDP、behavioral always/initial、force、tran gate 或 unresolved parameter 都进入 diagnostics。

### 7.3 `LayoutConnectivity`
```yaml
schema: ilvs.layout_connectivity@1
id: sha256:...
provenance_ref: sha256:...
source_kind: idb_declared_connectivity
snapshot_ref: sha256:...
extraction_mode: declared_net_membership_plus_route_continuity
coordinate_unit: {num: 1, den: 1000, symbol: um}
top_cell: {hierarchy_id: lay:hier:top}
conductors: []
components: [lay:component:c0]
instances: [lay:instance:u1]
devices: []
nets: [lay:net:n1]
ports: [lay:port:A]
labels: []
source_object_map_ref: sha256:...
coverage_ref: sha256:...
semantic_hash: sha256:...
```

`source_kind` 决定能声明的 claim。
external extraction 必须增加 deck/protocol/tool refs、recognized device records 和 rule coverage。

### 7.4 `CanonicalGraph`
```text
CanonicalGraph
  graph_id + side = REFERENCE | LAYOUT
  source model/provenance/coverage refs
  canonicalization/equivalence/tech policy refs
  namespace + exact unit system
  hierarchy nodes + boundary edges
  instance/device/net/port/pin vertices
  connects/contains/aliases/binds edges
  semantic attributes + original alias refs
  partition seeds + graph invariants
  ordered object and edge digests
  semantic_hash + serializer/build hash
```

graph 使用 typed incidence 表达多端 net，不能把 hyperedge 随意转成有方向 pair 而丢 pin role。
序列化按 kind、semantic key、StableId 排序。

### 7.5 `Device`
```text
Device
  stable_id + side + hierarchy_id
  class = STDCELL | MOS | BJT | DIODE | RES | CAP | BLACKBOX | UNKNOWN
  model_id + model_namespace + original_model
  terminals {role -> pin/net refs}
  parameters {name -> ExactQuantity | Interval | Symbolic}
  multiplicity/fingers/array_origin
  normalization_trace + reduction_group_ref
  source spans/shapes
  recognition/reduction coverage status
```

首版只有 `STDCELL` 和显式 `BLACKBOX` 是 supported。
出现其他 class 而 adapter 未 qualified 时，device 为 `UNKNOWN/UNSUPPORTED`，不能丢弃。

### 7.6 `Net`
```text
Net
  stable_id + side + hierarchy_id
  namespace + canonical_name_hint + original aliases
  kind = SIGNAL | POWER | GROUND | GLOBAL | CONSTANT | UNKNOWN
  terminal incidence multiset
  boundary port refs
  source members/components/shapes
  global rule ref + alias decisions
  degree/signature/component digest
```

net name 仅是 hint。
constant net 必须保留 width/value/source expression；不能把未连接与逻辑 0 合并。

### 7.7 `Port` 与 pin
```text
Port
  stable_id + owner hierarchy/device
  canonical/original name + namespace
  direction = INPUT | OUTPUT | INOUT | POWER | GROUND | UNKNOWN
  role + bit index/range/endian
  attached net + boundary peer
  equivalent_terminal_group_ref
  source span/shape + coverage status
```

direction `UNKNOWN` 不能靠连接度猜出后继续 full compare。
PG port 也不能从名称前缀自动推断。

### 7.8 `Hierarchy`
```text
Hierarchy
  node_id + parent_id + module/cell/model id
  canonical path + original path aliases
  mode = PRESERVED | FLATTENED | BLACKBOX
  instance/port/net child refs
  boundary binding map
  array/generate expansion trace
  flatten policy/rule refs
  source span + coverage
```

selective flatten 必须在两侧分别执行并生成 boundary equivalence proof。
仅一侧丢失层次时不能用名字删除层级分隔符后假定等价。

### 7.9 `EquivalenceRule`
```yaml
schema: ilvs.equivalence_policy@1
rule_id: eq:stdcell-pin-swap
domain: {tech_context_ref: sha256:..., device_class: STDCELL}
predicate: {model_ids: [cell:NAND2_X1]}
transform: {permutable_terminal_groups: [[A1, A2]]}
parameters: []
tolerance: null
authority: qualified_library_mapping
source_ref: sha256:...
qualification_ref: sha256:...
priority: 100
conflict: reject
```

rule 是 allowlist，不是 matcher heuristic。
冲突、歧义、未知 authority 均使适用对象 `UNSUPPORTED`。

### 7.10 `MatchResult`
```text
MatchResult
  result_id + compare/request refs
  status + claim_type + requested/actual fidelity
  reference/layout/canonical graph refs
  exact scope + hierarchy/equivalence policies
  object mappings by kind
  ambiguity classes
  mismatch witness refs by class
  graph counts/invariants/search statistics
  coverage/evidence refs
  assumptions + unsupported/unknown lists
  independent replay status
  canonical result hash
```

0 个 witness 只有在 coverage 完整、search 完成、replay PASS 时才能得到 PASS。

### 7.11 `MismatchWitness`

```text
MismatchWitness
  witness_id + class + severity
  reference/layout object refs
  anchor ports/devices/nets
  bounded subgraphs and frontier
  expected vs observed incidence
  candidate mapping/ambiguity context
  source spans/shapes/report spans
  derivation steps + classifier version
  minimality = PROVED | LOCALLY_MINIMAL | BOUNDED
  truncation/unknown notes
```

class 至少包括 `OPEN`、`SHORT`、`MISSING_INSTANCE`、`EXTRA_INSTANCE`、
`MISSING_NET`、`EXTRA_NET`、`PORT_MISMATCH`、`PIN_SWAP`、`MODEL_MISMATCH`、
`PARAMETER_MISMATCH`、`HIERARCHY_MISMATCH` 和 `GLOBAL_NET_MISMATCH`。

### 7.12 `Coverage`

```text
Coverage
  universe definition + expected counts
  checked/skipped/unknown/unsupported/failed counts
  objects by kind/model/hierarchy
  parsers: statements/tokens/features/diagnostics
  layout: layers/purposes/vias/labels/shapes/devices/rules
  matching: partitions/components/vertices/edges
  scope: requested/effective/frontier/outside
  blackbox: boundary checked/internal excluded
  parameters/tolerances/reductions
  external protocol report points
  completeness predicates + gaps
```

对每个维度要求 `expected = checked + skipped + unknown + unsupported + failed`。
无法定义 universe 时 completeness 为 `UNKNOWN`，不是 100%。

### 7.13 `EvidencePack`

```text
EvidencePack
  manifest + schema version
  request/input/context/policy refs
  raw and normalized source refs
  phase event journal
  canonical graph/result/coverage/witness refs
  mapping replay transcript
  tool/parser/serializer/build hashes
  budget/resource/cancel records
  external raw report and source-span maps
  checksums/signature/ACL/retention
  replay recipe + expected semantic hashes
```

EvidencePack 不复制受限 deck 内容到普通 JSON；只保存受 ACL 保护的 ref、hash 和必要 manifest。

---

## 8. Canonicalization 与语义规则

### 8.1 名称、namespace 与 stable ID

- 每侧建立独立 namespace；相同文本名不产生相同 StableId；
- escaped Verilog name 去转义只生成 alias，不覆盖原 spelling；
- hierarchy separator、bus delimiter 和 array spelling 由 parser adapter 解析，不用字符串替换猜测；
- rename policy 只影响 seed，不影响 graph incidence；
- duplicate canonical alias 是 ambiguity/error，不能 last-writer-wins；
- source span 和 iDB ObjectRef 保存在 alias map，供 witness 回指；
- stable ID generation 变化使旧 ref stale，防 delete/recreate 同名复用；
- canonical hash 排除路径、时间和内存地址，包含所有 semantic policy refs。

### 8.2 单位与参数

- 坐标统一为 `int64 DBU + exact rational to meter`；
- device 参数使用 `ExactQuantity(num, den, dimension)`，不先转 double；
- suffix `u/n/p/k/meg` 的语言语义由 parser 声明；未知 suffix 拒绝；
- tolerance 比较先转共同 dimension，再按 rule 的 abs/rel/ULP/interval 执行；
- NaN、overflow、underflow、symbolic unresolved 均为 UNKNOWN；
- multiplicity `m`、finger `nf`、width/length 的组合只按 qualified reduction rule 处理；
- 参数未在 claim 中要求仍要记录 `NOT_REQUESTED`，不能伪装 checked。

### 8.3 Device normalization

标准单元 canonical model 来自 Technology 的 exact cell mapping，至少包含 master、pin role、PG pin 和 function-family qualification。
名称相似、面积相同或 pin count 相同不足以映射 master。

未来 primitive device pipeline 固定顺序：

```text
recognize raw device
  -> bind model namespace
  -> canonicalize terminal roles
  -> normalize exact parameters
  -> apply allowlisted local reductions
  -> preserve reduction trace
  -> compare under property-specific tolerance
```

任何阶段缺规则则停止该 device 的等价判断，并进入 coverage gap。

### 8.4 Blackbox、PG 与 global net

- blackbox 必须由 exact model/hierarchy selector 指定；通配符默认禁用；
- blackbox compare 检查 model identity、端口、方向、bit 和外部 incidence；
- blackbox 内部对象计入 `excluded_by_policy`，claim 名包含 `blackbox_ports`；
- POWER/GROUND 分类来自 qualified LEF/Liberty/Tech mapping 或显式 source declaration；
- global net alias rule 按 namespace、domain、hierarchy 和 voltage class 限定；
- 不允许把所有同名 VDD 在多电压域自动合并；
- substrate/well/implicit bulk 未建模时 full device claim 为 UNSUPPORTED；
- tie-high/tie-low 与 supply constant 分开建模，除非 rule 明确等价。

### 8.5 Hierarchy、array 与 bus

- preserve 模式比较 module/cell boundary 与 port binding；
- flatten 模式保存每个 flattened object 的 origin chain；
- selective flatten policy 两侧使用同一 semantic selector，不依赖 source 路径文本；
- instance arrays 展开为 element IDs，并保存 range、方向和 origin；
- bus bit mapping 保留 `[msb:lsb]` 方向，不能只按排序后 bit 集比较；
- generate block 无稳定标签时用 source semantic discriminator；无法稳定则 UNKNOWN；
- recursive hierarchy、unresolved parameterized module 和 duplicate top 都拒绝；
- hierarchy rewrite 必须保持 port-to-net incidence digest，否则报告 mismatch。

---
## 9. Compare、反例与 no-false-PASS 算法

| 阶段 | TARGET 算法 | 输出/失败语义 |
|---|---|---|
| preflight | 比较 top、scope、hierarchy mode、model/rule namespace、exact units 和 coverage universe；对象计数只作 sanity | 冲突为 INVALID/UNSUPPORTED，计数相同不表示等价 |
| partition | 先按 hierarchy/blackbox boundary、device class/model、port role、PG/global domain 和 connected component 切分；跨分区 edge 记 frontier | 任何 edge 丢失为 INTERNAL_INCONSISTENCY |
| seed | exact boundary port、qualified unique model/degree/signature、显式 mapping 形成 seed；名字只用于无冲突 hint | 冲突 seed 撤销并出 diagnostic，不强配 |
| refine | `color0=H(kind,model,role,param-class,degree)`；迭代 `color'=H(color,multiset(edge-kind,neighbor-color))` 到稳定；hash collision 以完整 tuple 二次校验 | 稳定 partition、unique mapping、ambiguous cells |
| decompose | 将未决 incidence graph 按已匹配 frontier 拆成独立子问题，按候选数/边界约束从小到大求解 | 子问题和预算独立记账 |
| search | 候选必须满足 kind/model/role/parameter/hierarchy/degree；采用 fail-first backtracking、增量 incidence consistency、memoized failed frontier；达到 budget 立即 UNKNOWN | 禁止 budget exhaustion 返回 PASS |
| ambiguity | 找到一个 mapping 后继续在预算内寻找 automorphism；等价 mappings 压成 orbit/equivalence class | `PASS_WITH_AMBIGUITY`，不伪造唯一对象对应 |
| classify | 对 unmatched incidence 做 union/find relation：一 ref net 对多 layout component 为 OPEN，多 ref net 对一 layout component 为 SHORT；对象/端口/model/param 分别分类 | 同一根因可关联多个 symptom，但保留 primary/derived |
| witness | 从冲突 edge/vertex 双向 BFS，遇已证明 mapping frontier 停止；用 deletion test 局部最小化；超预算标 BOUNDED | 证据包含两侧 subgraph、frontier、source spans 和 derivation |
| replay | 独立 verifier 不读取 matcher cache：逐 mapped device/port 重建 incidence multiset，并检查 coverage/partition 守恒 | 任一矛盾为 INTERNAL_INCONSISTENCY 并 quarantine build |

PASS predicate 固定为：`import complete && requested coverage complete && search complete && mismatch_count==0 && replay==PASS && evidence sealed`；任一 conjunct 为 false/unknown 都不得 PASS。

## 10. 增量 dirty scope 与 full fallback

`IncrementalScopePlanner` 从 TypedDelta 的 actual-touched objects 开始，加入 created/deleted/reconnected pin、old/new net、instance/master、route component、hierarchy ancestors/boundaries、alias/global/PG peers、blackbox ports和当前 ambiguity partition；随后沿 incidence 与已匹配 relation 扩张到闭包。scope 只能扩大，调用方给的 dirty set 只是下界。

| 情况 | 强制动作 |
|---|---|
| reconnect/short 可能跨 scope、global/PG 改动、hierarchy/blackbox policy 改动 | 扩到相关 component/domain；不能界定则 full |
| parser/TechContext/equivalence rule/tool build 变化 | 所有旧 graph/cache/result stale，full re-import |
| delete 导致旧 mapping 断裂、ambiguity class 跨界、unknown actual-touched | full fallback |
| effective dirty vertices 超 full graph 的 policy threshold（首版 20%） | 直接 full，阈值写 evidence |
| local compare 得到 mismatch | 保留局部反例；commit gate 默认再跑 full，不能用局部结果推断其余区域 |
| local compare PASS | 只签 exact scope；每 100 个 candidate、每 20 个 local PASS 或 commit 前至少一次 full，取最早触发者 |

增量/full oracle 对同一 supported universe 要求 verdict、mismatch class/object incidence 集一致；witness 展示边界可不同。任何漏报使该 action/PDK/policy 组合的 incremental qualification 立即撤销，后续全量执行。

## 11. External Netgen、Calibre 与 PVS 协议

外部 adapter 必须经 57 的 `manifest -> probe -> prepare -> isolated run -> collect -> normalize -> protocol validate`，固定 binary/container digest、deck ref、typed argv/template、top、hierarchy/report point、units、expected artifacts 和 parser corpus；Agent 不能提交命令行或 deck 文本。

| 状态/档位 | iLVS 处理 |
|---|---|
| F0 prepare/probe | 仅证明环境/manifest；binary/version/deck 缺失为 `UNSUPPORTED/ENVIRONMENT_INVALID` |
| F1 raw completed | rc、signal、log、报告完整性已知；尚不能声明物理结果 |
| F2 normalized | mismatch/device/rule/object 已结构化且字段有 source span；coverage gap 为 PARTIAL |
| F3 protocol-valid | 固定公开/内部 protocol 与 golden corpus 合格，可作 supported-subset validator |
| F4 qualified oracle | tool build + PDK/deck + parser + protocol + organization qualification 的精确交集；不跨版本继承 |
| timeout/cancel | 保留 sealed partial raw artifact，terminal 为 TIMEOUT/CANCELLED；禁止从已解析前缀得 PASS |
| parser/report drift | `NORMALIZATION_UNSUPPORTED` 并 quarantine；不得把缺字段填 0 |
| replay | 以 raw hash/parser/schema/protocol 重做 normalize，逐字段 hash/source span 一致；外部工具 nondeterministic attempts 分开保存 |

Netgen 首先覆盖可公开复现的 digital/primitive microcases；Calibre/PVS 对同一 frozen deck/report point 做商业差分。OracleComparator 比较 verdict、mismatch class、对象 mapping、device/rule coverage 和 unknown，不只比较 `CORRECT/INCORRECT` 文本；oracle 彼此分歧输出 `ORACLE_DISAGREEMENT`，交由 qualification owner 处理。

## 12. 跨模块顺序、安全与治理

| 顺序 | Contract |
|---:|---|
| 1 | iDB 固化 base/candidate snapshot、TypedDelta、actual touched、DirtySet 和 independent artifact refs；iLVS 只读。 |
| 2 | Technology 解析 exact layer/device/cell/global/equivalence/deck qualification；任何 miss 先于 compare 暴露。 |
| 3 | iLVS 做 connectivity compare；若 action 改逻辑结构，iFormal 另行证明功能等价，两个结果不互相提升。 |
| 4 | iECO 将 iLVS/iFormal/legality/DRC/STA 节点放入不可删除 workflow；partial 触发恢复/升级。 |
| 5 | Verification Hub 检查 exact snapshot/scope/coverage/freshness，签限定 claim bundle。 |
| 6 | Runtime 先拒绝 hard fail/incomplete bundle，再选择候选并对 exact head 做 commit CAS；iLVS 无提交权限。 |

安全要求：输入挂载只读、输出空目录且 canonical path/symlink allowlist；parser/extractor 在限 CPU/RSS/wall/output 的隔离 worker；deck/license secret 经 broker 注入且日志脱敏；tenant/PDK/report/cache 分区；恶意 name/深层 hierarchy/巨型 bus/graph bomb 有配额；artifact 解压防 path traversal/zip bomb；ACL 与 retention 跟随派生 evidence；sandbox escape、secret 泄漏、stale artifact 假成功或 replay 矛盾立即 quarantine 并吊销关联 certificate。

## 13. TARGET LLD、CMake 与 PR 切片

```text
src/operation/iLVS/
  CMakeLists.txt  api/{LvsService,Capability}.hh
  model/{SourceNetlist,LayoutConnectivity,CanonicalGraph,Result}.hh
  import/{ReferenceImporter,IdbDeclaredAdapter,ExternalGraphAdapter}.cc
  canonical/{Name,Unit,Hierarchy,Device,Policy}Canonicalizer.cc
  match/{Partitioner,ColorRefiner,ComponentMatcher,MappingReplay}.cc
  explain/{Classifier,WitnessBuilder,EvidenceBuilder}.cc
  incremental/{ScopePlanner,FullFallback,Qualification}.cc
  external/{NormalizedLvsParser,OracleComparator}.cc
  tests/{unit,contract,property,fuzz,integration,oracle}/
```

CMake TARGET：在 `src/operation/CMakeLists.txt` 增加 `add_subdirectory(iLVS)`；`ilvs_model` 不依赖 iDB，`ilvs_core` 只依赖 model/选定图算法，`ilvs_idb_adapter` 单向依赖 `idb`，`ilvs_external_adapter` 依赖 contracts 而不启动进程，`ilvs_tests` 用生成 graph 和 fixtures。禁止 core 链接 Platform singleton、vendor library 或把 adapter 反向塞进 iDB。该接线全部是 TARGET，当前不存在。

PR 顺序：`LVS-0 audit+schemas+status validator` -> `LVS-1 independent import stores+provenance traps` -> `LVS-2 flat stdcell matcher+replay` -> `LVS-3 witness+ambiguity+hierarchy/blackbox` -> `LVS-4 iDB F1 adapter+Hub contract` -> `LVS-5 incremental/full qualification` -> `LVS-6 Netgen adapter` -> `LVS-7 Calibre/PVS shadow` -> `LVS-8 pure-layout extraction feasibility`。每 PR 附 negative/fault tests、coverage diff、benchmark、schema compatibility 和 CURRENT/TARGET 声明；不得在 LVS-8 前创建空 device extractor 冒充支持。

## 14. 测试矩阵、性能协议与量化 DoD

| 层 | 必测内容与断言 |
|---|---|
| analytic | 手算 1–20 device graph：identity、rename、permutation、open、short、pin swap、missing/extra、symmetry、blackbox、PG；exact witness/class |
| property | 随机合法 mapping 的双射/incidence 守恒；apply inverse mutation 恢复 semantic hash；coverage 分桶守恒 |
| metamorphic | rename、声明可交换 pin、输入顺序/线程/hash seed、等价 hierarchy flatten、exact unit scaling 不改 verdict；真实语义 mutation 必改 |
| fuzz | Verilog/normalized graph/schema/name/bus/range/parameter/parser report、深层 hierarchy、重复 ID、hash collision、malformed spans；无 crash/OOM/false PASS |
| fault | parser crash、OOM、disk full、CAS hash mismatch、worker kill、timeout/cancel、rc=0 空/截断/旧 report、license failure、parser drift；全部非 PASS |
| incremental | 每类 TypedDelta 的 dirty/full paired run，跨 scope short/global/hierarchy/ambiguity 注入；零漏报，unsafe 自动 full |
| oracle | Netgen golden + mutation；Calibre/PVS frozen microdeck shadow；逐 class/object/device/rule coverage 对齐并保留 disagreement |
| performance | 1k/10k/100k/1M device、flat/hierarchical/symmetric/adversarial、dirty 0.01/0.1/1/10/20%；各 7 次，报 median/MAD/p95、CPU/RSS、graph bytes、states、witness cost |

进入 `PRODUCT_SUBSET` 的量化 DoD：至少 20 个可授权设计、3 个规模档、2 个独立 flow family；supported mutation corpus 每类不少于 1000 个且 detection=100%、false PASS=0；10,000 次 malformed/fault/cancel 注入 false PASS=0；100 次重复和 8 种输入排列 canonical result hash 一致率=100%；10,000 个 incremental/full paired deltas verdict/class/incidence 一致率=100%；coverage conservation=100%，unknown/unsupported 到 PASS 映射=0；Netgen supported corpus 一致率=100%；Calibre/PVS 各至少 200 个 frozen cases 且所有 disagreement 已归因/waive，无未解释 disagreement；dirty<=1% 时 qualified design 的增量 median wall 小于 full 的 50%，若未达到只取消性能资格、不放宽正确性；cancel 后 orphan process=0、跨租户 artifact leak=0。

## 15. 风险、开放问题、版本历史与自检

| 风险/UNKNOWN | 处置 |
|---|---|
| CURRENT Verilog parser 的完整 structural 子集、层次/source span 保真度未资格 | LVS-1 corpus 审计；缺项显式 parser coverage，不声称支持 |
| iDB route shape 对独立 physical short/open 的充分性未知 | F1 claim 限定 declared connectivity；F2/F3 需外部 extraction 或新 extractor |
| GDS/OASIS reader、device/rule/reduction 资产缺失 | pure GDS/device LVS 保持 UNSUPPORTED，LVS-8 单独选型 |
| equivalent pin、PG/global、multi-domain mapping 完整性未知 | 只接受 Technology exact qualified rule；无 rule 不等价 |
| 对称大图可能导致搜索爆炸 | refinement/decompose/budget；耗尽 UNKNOWN，评估成熟图同构库 |
| commercial deck/report 可用性、license 与 redistribution 未知 | 仅保存受控 refs；用 Netgen 建公开基线，商业资格按环境绑定 |

版本历史：`ai1.1 (2026-07-24)` 按 implementation-ready 深度重写，加入真实 CURRENT audit、adaptor-first/greenfield 边界、完整 schema/算法/incremental/external/security/LLD/test/DoD；`ai1.0 (2026-07-23)` 为 144 行 greenfield 提纲。

自检：仅修改 `docs/ai1.0/31-iLVS-ai1.0.md`；无机械行数门禁，按契约闭包验收；Markdown fence 成对；已覆盖 goals/non-goals/ownership、CURRENT、FR/NFR/invariants、import/canonicalize/compare/explain/validate/incremental、全部指定 schemas、ID/name/unit/device/blackbox/PG/global/hierarchy/array/parameter/tolerance、matching/witness/no-false-PASS、external F0–F4/partial/unsupported/timeout/cancel/replay、跨模块顺序、安全、TARGET CMake/PR、全测试类型与量化 DoD。
