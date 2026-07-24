<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 30 · iDRC Agent 原生增量检查与修复建议实施方案 · ai1.1

> 基线：`docs/ai/30-iDRC.md`、本文件 ai1.0、`10-iDB-ai1.0.md`、`12-evaluation-ai1.0.md`、`43-agent-runtime-ai1.0.md`、`49-verification-hub-ai1.0.md`。
>
> 成熟度纪律：本文用 **CURRENT** 表示 2026-07-24 当前工作区中可定位、可编译或已有测试的事实；用 **CURRENT-WT** 表示尚未提交的工作树实现；用 **TARGET** 表示 ai1.1 要交付的契约。任何 TARGET schema、API、证书或性能目标都不表示已经实现。
>
> 首个垂直闭环：post-route 局部 route/via ECO。iDRC 对 immutable base/candidate snapshot 做 rule-aware 增量检查，输出可解释 violation、精确 coverage 和 proposal-only 修复建议；iRT/iECO 物化建议，iDB 应用 TypedDelta，Verification Hub 签发 scoped certificate，Runtime 决定候选生命周期和提交。
>
> 最高优先级红线：**零条已报告 violation 在 coverage 不完整时绝不等于 clean。** `SKIPPED != PASS`，`UNSUPPORTED != PASS`，`TIMEOUT != PASS`，局部 clean 也不蕴含全芯片 clean。

---

## 0. 目标、非目标与唯一责任

### 0.1 TARGET 目标

iDRC ai1.1 不是给 `getViolationList()` 加一个 JSON 外壳。它要成为 Agent 可安全调用、可增量执行、可审计重放的只读验证与建议服务：

```text
inspect immutable snapshot and exact rule context
  -> discover qualified rule/checker capabilities
  -> resolve requested claim and conservative CheckScope
  -> run deterministic checker work units
  -> normalize stable violations and exact coverage
  -> explain or compare base/candidate results
  -> optionally propose repair drafts without mutation
  -> validate materialized candidate at required fidelity
  -> publish DRCResult + Evidence for Hub and Runtime
```

首版必须做到：

- 每个结果绑定 `snapshot_ref / tech_context_ref / rule_context_ref / checker_build_ref`；
- 以 deck 中的规范化 rule instance 为 coverage 分母，而不是以 26 个 family 名称代替 foundry rule deck；
- 支持 `rule_discovery`、`check_scope`、`explain`、`compare`、`propose_repair`、`validate` 六个能力；
- 从 iDB `DirtySet` 的旧几何和新几何生成保守 scope，并按 rule locality 决定 local、component 或 full；
- 对相同输入、相同 binary、相同 seed 给出稳定的 violation ID、排序、coverage 和 evidence hash；
- 将 repair 严格限制为 proposal，由 iRT/iECO 生成 TypedDeltaDraft，由 iDB 在 branch 上应用；
- 把 timeout、cancel、partial、checkpoint、resume、replay 和 cache 当协议的一部分；
- 允许 Verification Hub 基于 coverage 和 qualification 签发 scoped DRC claim；
- 用增量/full 差分和 Calibre oracle 持续管理 checker 资格，不以单个样例宣称商业 signoff 等价。

### 0.2 非目标

- iDRC 不拥有 branch，不修改 committed 或 candidate snapshot，不直接调用 iDB setter；
- iDRC 不自动选择或提交修复，不把 proposal 序号当授权；
- iDRC 不替代 iRT 的可布线性搜索、iECO 的动作物化、iSTA 的 timing 分析或 iEval 的 QoR 比较；
- iDRC 不把 LEF/DEF 中已加载的 rule family 集合冒充完整 foundry deck；
- iDRC 不把当前固定 `5*pitch` cluster expansion 宣称为任意规则的安全 halo；
- iDRC 不对 antenna、density、lithography、DFM、ERC 等未注册规则生成 clean 或 repaired 结论；
- ai1.1 不承诺替代 Calibre 等 signoff oracle；F4 只用于相关性、资格和发布门禁；
- explain 只解释 checker 实际使用的参数和 witness，不生成无法由证据验证的自然语言原因；
- compare 不跨不兼容 tech/deck/unit/geometry 语义强行对齐；
- cluster 只用于 UI 和 repair work package，不改变 raw violation 集合或 gate 分母。

### 0.3 唯一责任与 owner

| 模块 | 唯一负责 | 明确不负责 |
|---|---|---|
| iDRC owner | rule manifest、scope planning、checker execution、violation identity/explain、DRC evidence、repair proposal | snapshot mutation、候选选择、certificate policy |
| iDB / Design State（10） | immutable snapshot、ObjectId、ShapeRef、TypedDelta、旧/新 touched geometry、DirtySet | DRC 规则语义和候选好坏 |
| Tech Context owner | PDK/LEF/deck 解析、单位/layer/purpose 映射、RuleContext 内容寻址 | 隐式选择默认 deck |
| iRT | route/track/via/reroute proposal 的可布线性物化和 route risk | DRC clean certificate |
| iECO | via/shape ECO 动作物化、前置条件和可回滚 TypedDeltaDraft | 从成功返回值推断 DRC clean |
| iEval（12） | route/timing/PPA metric、候选比较、QoR gate | DRC correctness claim |
| Verification Hub（49） | required claim、validator DAG、qualification、certificate、失效 | 执行几何 predicate 或修改状态 |
| Experiment Runtime（43） | branch、预算、lease、cancel、候选状态、选择和 commit | 重新解释 rule/violation 语义 |

代码 owner 建议为 `iDRC + Design State + Verification` 三方评审：iDRC owner 批准规则语义，Design State owner 批准 ID/dirty/snapshot 契约，Verification owner 批准 claim/coverage/qualification。跨边界 PR 缺任一 owner review 不合入共享集成分支。

---

## 1. CURRENT 事实审计与迁移边界

### 1.1 审计范围与方法

本次为 bounded audit，不是对所有 26 个几何算法逐行形式验证。审计覆盖当前脏工作树中的以下真实路径：

- `src/operation/iDRC/interface/DRCInterface.{hpp,cpp}`；
- `src/operation/iDRC/source/data_manager/{DataManager,advance/*,design_rule/*}`；
- `src/operation/iDRC/source/module/rule_validator/{RuleValidator,rv_data_manager/*,rv_design_rule/*}`；
- `src/operation/iDRC/source/module/rule_validator/coverage/*` 和 `tests/RuleCoverageTest.cpp`；
- `src/operation/iDRC/source/toolkit/logger/*` 和 logger working-tree test；
- iDRC/interface/data-manager/rule-validator/Tcl 的 `CMakeLists.txt`；
- `src/database/interaction/RT_DRC/ids.hpp`；
- `src/interface/tcl/tcl_idrc/*`、default config、tool manager DRC IO 和 report DRC；
- `src/operation/iRT/interface/RTInterface.cpp` 与 iRT `DRCEngine` 消费点；
- `src/operation/iECO/source/eco_via/*`；
- 现有脚本产出的 `violation_map.json`/GDS layer artifacts 和仓库内可见测试。

审计结论只证明接口和数据流可定位；它不证明每个 LEF58 分支正确，也不证明对任何 foundry deck 的完整覆盖。

### 1.2 CURRENT 可复用资产

| 资产 | 当前事实 | TARGET 定位 | 当前限制 |
|---|---|---|---|
| `DRCInterface` | singleton，提供 `initDRC/checkDef/getViolationList/cmpViolation/destroyDRC` | Legacy checker adapter | 读取全局 iDB；没有 snapshot/context/request/result envelope |
| `ids::Shape` | `net_idx + bbox + layer_idx + is_routing` | 临时 rectangle adapter | 无 ObjectId、ShapeId、purpose、owner、unit、generation |
| `ids::Violation` | family、bbox、layer、net index set、`required_size` | legacy raw result adapter | 无 RuleId、ViolationId、witness、severity、coverage、provenance |
| `DataManager` | 包装 die、DBU、manufacturing grid、routing/cut layer、规则结构 | Tech/legacy database adapter | singleton；构造时会删除 temp directory；无 immutable RuleContext |
| `Database::_exist_rule_set` | 表示从 iDB/LEF 包装后存在的 family | family-level inventory seed | 不是 exact deck rule instance，也无 source span/qualification |
| rule structs | routing/cut layer 上保存 spacing、width、area、enclosure 等整数参数 | RuleManifest compiler 输入 | 参数有效性、默认值和 parser coverage 没有统一状态 |
| `RuleValidator` | 26 个 family dispatcher，OpenMP cluster 并行 | exact kernel backend | 无 cancellation、checkpoint、per-rule execution status |
| geometry core | Boost polygon/polyset、max rectangle、boundary/cut pool、R-tree query | 几何 canonicalization 和 witness 后端 | 当前 pool 索引是调用内局部 ID，不能跨 rerun 作 stable ID |
| cluster | `cluster_size=100*pitch`，`expand_size=5*pitch` | 可作为执行 tiling 优化 | 固定 expansion 不是 rule-derived halo；非局部规则无证明 |
| check region | region bbox 扩 `expand_size`，选择 routing 相邻层和 cut 层 | CheckScope adapter | region 自身是 `ids::Shape`；无 scope proof、old/new geometry |
| dedup | `CmpViolation` 按 family/bbox/layer/type/net/required size 排序去重 | canonical result normalization seed | witness 相同/不同的语义不完整，跨 snapshot identity 未定义 |
| report | stdout summary、`violation_map.json`、detail file、GDS、feature output | legacy artifact attachment | JSON 只含 type/shape/net；无 schema version 和 atomic evidence bundle |
| Tcl/tool manager | batch init/check/destroy 和 compare/report IO | compatibility facade | bool/console/path 驱动；失败、partial、coverage 无统一返回 |
| iRT adapter | 把 env/result/check region 转为 `ids::*` 调 iDRC | 首个增量 consumer | net/layer index 是进程局部；异常通过 catch 后继续转换为空风险 |
| iECO via | shape repair 可返回 typed status/count | repair action owner seed | 当前会直接操作 legacy data；未绑定 DRC proposal/snapshot |

### 1.3 CURRENT rule family inventory

当前 `ViolationType` 和 validator CMake 同时可见以下 26 个 family；这里的“实现存在”不等于具体 PDK rule instance 已加载或已通过 oracle 资格：

| # | CURRENT family | 主要层类 | 初始 TARGET locality 假设 |
|---:|---|---|---|
| 1 | `adjacent_cut_spacing` | cut | finite halo，待参数推导和 full qualification |
| 2 | `corner_fill_spacing` | routing | finite halo，待资格 |
| 3 | `corner_spacing` | routing | finite halo，待资格 |
| 4 | `cut_eol_spacing` | cut+routing 邻接 | finite halo，跨层闭包 |
| 5 | `cut_short` | cut | finite halo |
| 6 | `different_layer_cut_spacing` | 相邻 cut | finite halo，跨层闭包 |
| 7 | `enclosure` | cut+routing | finite halo，via component witness |
| 8 | `enclosure_edge` | cut+routing boundary | finite halo，待最大 `within` 推导 |
| 9 | `enclosure_parallel` | cut+routing | finite halo，待资格 |
| 10 | `end_of_line_spacing` | routing+可选 cut | finite halo，组合条件取最大范围 |
| 11 | `floating_patch` | routing/net | component 或 unknown，不能先验 local |
| 12 | `jog_to_jog_spacing` | routing | finite halo，待表项最大值推导 |
| 13 | `maximum_width` | routing polygon | component，局部 bbox 不足以证明 |
| 14 | `max_via_stack` | 多层 via stack | component，跨层 |
| 15 | `metal_short` | routing/net relation | finite halo；连通后果另由 connectivity claim |
| 16 | `min_hole` | routing polygon hole | component |
| 17 | `minimum_area` | routing polygon | component |
| 18 | `minimum_cut` | routing+cut | finite halo 或 component，按 rule variant |
| 19 | `minimum_width` | routing polygon | finite halo/component，按实现 witness |
| 20 | `min_step` | routing boundary | component |
| 21 | `nonsufficient_metal_overlap` | routing overlap | finite halo，跨 net relation |
| 22 | `notch_spacing` | routing polygon | finite halo/component，按 notch 定义 |
| 23 | `off_grid_or_wrong_way` | routing/manufacturing grid | object-local |
| 24 | `out_of_die` | all shapes/die | object-local |
| 25 | `parallel_run_length_spacing` | routing | finite halo，取所有 table 最大 spacing |
| 26 | `same_layer_cut_spacing` | cut | finite halo，取所有条件最大范围 |

所有 locality 在 RuleManifest 有逐 rule instance 的证明前均为 `unknown`。上表只是 planner 实现优先级，不可直接签发 incremental qualification。

### 1.4 CURRENT-WT 未提交能力

当前工作树新增 `RuleCoverageReport`、`drc_summary.json` 和 fail-closed logger exit code：

- engine family 集合由 26 个 `ViolationType` 手写枚举；
- loaded 集合取 `Database::get_exist_rule_set()`；
- 显式请求 unknown 或未加载 family 时拒绝执行；
- 空 selector 当前解释为 `all_loaded_rules`；
- 输出 `checked/skipped/unsupported/refused`，并强制 `signoff_clean=false`；
- 零 violation 的状态为 `partial_clean`，G11 因无 foundry table/Calibre evidence 保持 incomplete；
- `DRCLOG.error` 的进程退出码由成功改为 `EXIT_FAILURE`；
- 新测试是 `EXCLUDE_FROM_ALL` executable，尚未用 `add_test()` 接入 CTest。

这些是正确方向的 compatibility guard，但仍是 family-level coverage。它没有 exact rule universe、per-layer variant、failed/not-applicable、snapshot/deck hash、check scope 或 certificate，因此 ai1.1 不得把它包装成 `drc.full_clean`。

### 1.5 关键缺口与风险登记

| ID | CURRENT 缺口 | 失败风险 | TARGET 控制 |
|---|---|---|---|
| GAP-DRC-01 | global singleton 读取 live iDB | 运行中状态漂移 | immutable `snapshot_ref` + read lease |
| GAP-DRC-02 | family 级 loaded/checked | 少规则却报 clean | exact RuleManifest 分母 |
| GAP-DRC-03 | 固定 `5*pitch` expansion | halo 边界漏报 | rule-derived halo + unknown->full |
| GAP-DRC-04 | 只有 bbox/net index | rerun identity 漂移 | ObjectId/ShapeId/ViolationId |
| GAP-DRC-05 | 无旧几何输入 | move/delete 周边漏检 | old/new union dirty closure |
| GAP-DRC-06 | OpenMP 无执行清单 | crash/timeout 混成空结果 | per-work-unit ledger + terminal status |
| GAP-DRC-07 | temp 目录 init 时删除 | evidence/cache 被覆盖 | isolated workspace + CAS atomic publish |
| GAP-DRC-08 | logger fatal exit | 服务进程整体退出 | worker isolation + structured error |
| GAP-DRC-09 | `required_size` 单值 | explain 丢 rule 条件 | typed witness operands/thresholds |
| GAP-DRC-10 | report path/bool 接口 | Agent 解析日志或误判 | versioned result/evidence schema |
| GAP-DRC-11 | repair 可直接改 legacy DB | 绕过 branch/验证 | proposal-only + iRT/iECO TypedDeltaDraft |
| GAP-DRC-12 | 无 oracle qualification | 局部/full 与 Calibre 漂移 | differential corpus + revocable qualification |
| GAP-DRC-13 | layer/net indexes 非稳定 | reload 后错误关联 | TechLayerId/ObjectId，不以 vector index 作协议 ID |
| GAP-DRC-14 | empty shapes 可形成非法 bbox/grid | crash或伪空结果 | request/schema/preflight fail-closed |
| GAP-DRC-15 | CMake 子目录改全局 build type | 构建配置串扰 | target-local options，CTest 注册 |

---

## 2. 设计原则、术语与 claim lattice

### 2.1 强制原则

1. **状态先绑定。** 所有读请求先固定 immutable snapshot，禁止“当前设计”。
2. **规则先枚举。** checker 执行前先得到 exact requested/applicable rule universe。
3. **scope 保守扩大。** iDB dirty 是下界输入，iDRC 只能扩大，不能无证明缩小。
4. **旧/新都检查。** delete/move/reshape 必须覆盖 before 和 after 的交互邻域。
5. **不完整即不确定。** skipped、unsupported、failed、timeout、cancel、stale 任一存在都阻断 clean。
6. **局部只证明局部。** incremental result 的 claim 带 scope 和 assumptions，不向 full 自动提升。
7. **原始集合守恒。** cluster、UI 聚合和 repair grouping 不改变 raw violation count。
8. **建议与动作分离。** RepairProposal 没有设计副作用，也不是 TypedDelta。
9. **证据内容寻址。** 日志可辅助诊断，但不能替代 schema 化 Evidence。
10. **资格可撤销。** incremental/full 或 Calibre 反例立即冻结相关 rule/checker qualification。

### 2.2 术语

| 术语 | 定义 |
|---|---|
| rule family | 算法类别，例如 `parallel_run_length_spacing` |
| rule instance | deck 中具有 source span、layer tuple、参数、例外和单位的规范化规则 |
| `RuleContext` | tech、deck、parser、unit、layer/purpose mapping 的 immutable 内容寻址上下文 |
| `RuleManifest` | RuleContext 下所有 rule instance 与 checker/locality/qualification 的完整清单 |
| requested universe | selector 展开后调用方要求证明的 rule instances |
| applicable universe | 对给定 scope 经可靠证明适用的 requested rule instances |
| checked | checker 成功执行且 evidence 完整的 rule instance |
| clean | 在声明 claim/scope/context 下 coverage 完整且 raw violations 为零 |
| dirty | 至少有一条有效 raw violation；coverage 可同时不完整 |
| inconclusive | 没有 violation 或有部分结果，但 coverage/执行不支持 pass/fail 完整结论 |
| halo | rule instance 对空间邻域的保守最大依赖距离，单位为 DBU |
| component scope | 需要完整 polygon/net/via stack/connected component 的依赖范围 |
| full scope | snapshot 中 policy 定义的全设计、全相关层和全部 required rules |
| witness | checker 可复算的几何对象、测量、阈值、关系和 source rule 引用 |
| continuity match | base/candidate 间判断 new/resolved/residual 的显式匹配记录，不篡改 ViolationId |

### 2.3 TARGET claim lattice

```text
drc.full_clean(rule_set=R, design=D)
  implies drc.scoped_clean(rule_set=S, scope=X)
  only when S subset R, X subset D, context identical, and qualification allows projection

drc.scoped_clean(...)
  does not imply drc.full_clean(...)

drc.incremental_clean(...)
  implies only its exact dirty closure and assumptions

drc.estimated_low_risk(...)
  implies no correctness claim

drc.partial / drc.inconclusive / drc.unsupported
  imply no clean claim
```

F4 commercial clean 也不自动替换 iDRC claim；二者可由 Hub policy 组合。反向同样不成立。

---

## 3. 面向 Agent 的需求与不变量

### 3.1 功能需求

| ID | TARGET 需求 | 优先级 | 验收要点 |
|---|---|---:|---|
| FR-DRC-01 | `rule_discovery` 返回 exact RuleManifest | P0 | deck 每个规范化 rule instance 恰有一个终态 |
| FR-DRC-02 | `check_scope` 解析 region/layer/net/object/rule selector | P0 | selector 不明确时拒绝，不猜默认对象 |
| FR-DRC-03 | 支持 full、explicit scoped、dirty incremental 三种请求 | P0 | result 明确记录 scope kind 和 proof |
| FR-DRC-04 | 从 old/new touched geometry 计算 rule-aware closure | P0 | move/delete 在两端周边均不漏报 |
| FR-DRC-05 | 对 finite/component/global/unknown locality 正确升级 | P0 | unknown 无 local 执行路径 |
| FR-DRC-06 | 输出 stable `ViolationId` 和完整 `ViolationRecord` | P0 | 顺序、线程、tile 不改变 ID |
| FR-DRC-07 | `explain` 返回 source rule、operands、witness、阈值 | P0 | 可用独立 predicate 重算 |
| FR-DRC-08 | `compare` 输出 new/resolved/residual/changed/ambiguous | P0 | 集合守恒且不按 bbox 近似静默合并 |
| FR-DRC-09 | coverage 区分 checked/skipped/unsupported/failed/refused/not-applicable | P0 | 每个 requested rule instance 唯一分桶 |
| FR-DRC-10 | `propose_repair` 生成 proposal-only candidates | P0 | API 无 apply/commit side effect |
| FR-DRC-11 | proposal 声明 DRC/route/timing/frozen 风险与 secondary rules | P0 | 风险缺失即 proposal invalid |
| FR-DRC-12 | `validate` 比较 base/candidate 并绑定实际 TypedDelta | P0 | proposal 与实际 delta 不一致时 fail |
| FR-DRC-13 | 支持 F0-F4 路由和禁止非法降档 | P0 | used fidelity 与 downgrade reason 可见 |
| FR-DRC-14 | 结构化 timeout/cancel/partial/checkpoint/resume | P0 | partial 从不产生 clean |
| FR-DRC-15 | CAS evidence 和 fresh-process replay | P0 | 重放 result digest 一致 |
| FR-DRC-16 | cache key 覆盖所有语义依赖 | P0 | tech/deck/tool/scope 漂移必 miss |
| FR-DRC-17 | Hub 可校验 coverage 和 qualification 后签 certificate | P0 | iDRC 不直接签发 policy bundle |
| FR-DRC-18 | 保持 legacy iRT/iDRC 数值兼容 adapter | P1 | 迁移期间 legacy regression 明确分桶 |
| FR-DRC-19 | Calibre raw result 映射到 RuleId/geometry/object relation | P1 | unmapped 不从分母删除 |
| FR-DRC-20 | 分页查询 violation/manifest 且 page token 稳定 | P1 | page 不重不漏，token 绑定 result hash |

### 3.2 非功能需求

| ID | TARGET 要求 |
|---|---|
| NFR-DRC-01 | 对外接口不接受 live singleton、裸 pointer 或隐式 current design。 |
| NFR-DRC-02 | 几何坐标协议层使用带符号 64-bit DBU；32-bit legacy conversion 必须做 overflow check。 |
| NFR-DRC-03 | 同一 request/context/build/seed 的 canonical result digest 必须确定。 |
| NFR-DRC-04 | 并行调度只改变性能，不改变 raw result、ID、排序、coverage 或 evidence。 |
| NFR-DRC-05 | 任一未捕获 checker 异常隔离到 worker/work unit，主服务返回结构化失败。 |
| NFR-DRC-06 | 任何临时文件只在隔离 workspace；CAS 发布采用 hash 校验和原子 rename。 |
| NFR-DRC-07 | 请求预算由 Runtime 传入；iDRC 不根据已看到的结果放宽 deadline 或 coverage。 |
| NFR-DRC-08 | cancellation 到 safe point 的延迟可测，且取消后不发布伪完整结果。 |
| NFR-DRC-09 | schema、rule 参数、bbox、polygon、selector、artifact ref 均有上限和严格校验。 |
| NFR-DRC-10 | 日志不包含未脱敏绝对路径、license token 或未授权设计名称。 |
| NFR-DRC-11 | benchmark 报告发布 median、p95、MAD、峰值 RSS、输入规模和硬件配置。 |
| NFR-DRC-12 | 无冻结 benchmark 前不承诺绝对吞吐；性能优化不得弱化 correctness gate。 |
| NFR-DRC-13 | schema 向后兼容只允许 additive optional 字段；语义变化升级 major capability version。 |
| NFR-DRC-14 | evidence retention 到期后 result 变 `UNVERIFIABLE`，不得继续作为 current certificate 依据。 |
| NFR-DRC-15 | 外部 F4 工具/license 不可用时显式 `UNAVAILABLE`，不得降为 F3 后保留 F4 标签。 |

### 3.3 必须保持的不变量

`INV-DRC-01`：一个 `DRCResult` 只绑定一个 immutable `snapshot_ref`。

`INV-DRC-02`：`rule_context_ref` 唯一确定 deck、parser、unit、layer 和 purpose 语义。

`INV-DRC-03`：`requested = checked ∪ skipped ∪ unsupported ∪ failed ∪ refused ∪ proven_not_applicable`，各集合两两不交。

`INV-DRC-04`：`PASS -> coverage.complete=true && raw_violation_count=0`。

`INV-DRC-05`：`raw_violation_count=0` 不推出 `PASS`。

`INV-DRC-06`：incremental `PASS` 的 claim scope 不大于被验证的 conservative closure。

`INV-DRC-07`：locality 为 `unknown/global` 的 rule 不能由 local work unit 标记 checked。

`INV-DRC-08`：dirty closure 包含所有 touched shape 的 old bbox 和 new bbox；缺一侧则 fail closed。

`INV-DRC-09`：同一 stable shape/rule/witness 在调度重排后产生相同 ViolationId。

`INV-DRC-10`：cluster 数量可以变化，raw ViolationId multiset 不得变化。

`INV-DRC-11`：compare 的 `new + residual_base_matches + resolved = base/candidate` 关系可对账，ambiguous 单列。

`INV-DRC-12`：RepairProposal 不包含可执行函数指针、shell、脚本路径或隐式 mutation。

`INV-DRC-13`：proposal 被物化后，实际 TypedDelta 的 touched set 超出声明即原 proposal 失效。

`INV-DRC-14`：cache hit 必须重新校验 artifact hash、qualification freshness 和完整 key。

`INV-DRC-15`：TIMEOUT/CANCELLED/PARTIAL 的 completed work 可以审计，但不可签 clean certificate。

`INV-DRC-16`：checkpoint 恢复必须固定相同 snapshot/context/build/partition plan。

`INV-DRC-17`：任何 F0/F1 估计不得签发 full clean；F1 incremental 只在已资格 scope 内签 scoped claim。

`INV-DRC-18`：Hub/Runtime 不能通过忽略 coverage 字段把 iDRC result 升格。

---

## 4. TARGET 总体架构与调用顺序

### 4.1 组件图

```text
Agent / domain planner
        |
        v
Experiment Runtime ---- budget / branch / lease / cancel / selection
        |
        +---- iDB Design State ---- immutable snapshot / ObjectId / DirtySet
        |
        +---- Tech Context -------- RuleContext / layer-purpose / exact deck
        |
        +---- Verification Hub ---- required claims / plan / qualification
                                      |
                                      v
  +------------------------------------------------------------------+
  |                       iDRC Agent Service                         |
  | RequestValidator -> RuleManifestRegistry -> IncrementalPlanner   |
  |          |                 |                    |                 |
  |          +-> CheckerRouter -> WorkLedger -> LegacyKernelAdapter  |
  |                                  |               geometry/R-tree |
  | ViolationNormalizer <- raw result+---------------+               |
  | Explain / Compare / RepairProposal / EvidencePublisher           |
  +------------------------------------------------------------------+
                | result/evidence                 | proposals
                v                                 v
      Verification Hub issuer              iRT / iECO materializer
                |                                 |
                +----------> iEval <--------------+
                               |
                               v
                    Runtime select / commit
```

### 4.2 依赖与执行顺序

验证一个 materialized candidate 的固定顺序是：

1. Runtime 固定 base/candidate branch、budget、policy、lease 和 cancellation token。
2. iDB 返回 immutable `snapshot_ref`、actual TypedDelta、old/new touched geometry、DirtySet 和 invalidations。
3. Tech Context 解析并内容寻址 RuleContext；不得从工作目录猜 deck。
4. Verification Hub 依据 delta/policy 计算 required DRC claim 和 fidelity，不执行 checker。
5. iDRC 校验 request，发现 RuleManifest，生成 conservative CheckScope 和 work plan。
6. iDRC 执行、规范化并发布 DRCResult/Evidence；过程只读 snapshot。
7. Hub 校验 schema、coverage、qualification、freshness 后签 scoped/full certificate 或返回 incomplete。
8. iEval 读取 metric 与 certificate bundle 做候选 QoR gate，不改变 DRC verdict。
9. Runtime 根据完整 bundle 和 decision policy 选择、abandon 或提交 exact candidate head。

生成修复建议的顺序是：

```text
iDRC ViolationRecord
  -> iDRC RepairProposal (no mutation)
  -> Runtime opens candidate exploration
  -> iRT/iECO validates applicability and creates TypedDeltaDraft
  -> iDB preflight/apply on branch -> actual TypedDelta + candidate snapshot
  -> Hub plans -> iDRC validates -> iEval compares
  -> Runtime decides; only Runtime can request commit
```

禁止的反向依赖：iDRC kernel 不 include Runtime/Hub/iEval；iDB 不 include iDRC；iRT/iECO 不把 iDRC private structs 持久化；Hub 不调用 `DRCI` singleton；Runtime 不解析 iDRC stdout。

### 4.3 单次 `check_scope` 数据流

```text
validate capability envelope and authorization context
  -> resolve immutable SnapshotView and Tech/RuleContext
  -> expand rule selector against exact RuleManifest
  -> validate CheckScope selector and requested claim
  -> consume iDB old/new DirtySet when mode=incremental
  -> derive per-rule locality closure and escalation set
  -> freeze deterministic partition/work ledger
  -> execute qualified checker adapters
  -> record each rule/work-unit terminal status
  -> canonicalize witness, IDs, ordering and dedup
  -> compute exact Coverage and verdict
  -> atomically publish DRCResult/Evidence to CAS
  -> return refs, never infer clean from empty list
```

---

## 5. TARGET 公共 capability 与生命周期

### 5.1 Capability 表

| Capability | 副作用 | 主要输入 | 主要输出 | 最低权限 |
|---|---|---|---|---|
| `drc.rule_discovery@1` | 只读/CAS evidence | snapshot、tech/rule context | RuleManifest、capability limits | R0 |
| `drc.check_scope@1` | 只读/CAS evidence | context、scope、rules、fidelity | DRCResult、ViolationRecords、Coverage | R1 |
| `drc.explain@1` | 只读/CAS evidence | result + ViolationId | explanation + witness refs | R0 on result |
| `drc.compare@1` | 只读/CAS evidence | base/candidate results | ViolationDelta、comparability | R0 on both |
| `drc.propose_repair@1` | 只读/CAS proposal | violation/result/policy | RepairProposal set | R1 |
| `drc.validate@1` | 只读/CAS evidence | base/candidate/delta/proposal? | validation DRCResult + delta compare | R1 |

权限级别由 Gateway/Runtime 定义；iDRC 只校验 signed principal、tenant/project、snapshot read rights、rule/deck policy 和 evidence ACL。repair proposal 权限不授予 iDB write 权限。

### 5.2 通用请求 envelope

```yaml
schema_version: ieda.drc.request.v1
request_id: uuid
correlation_id: uuid
capability: drc.check_scope@1
subject: {snapshot_ref: sha256:..., expected_snapshot_digest: sha256:...}
context: {tech_context_ref: sha256:..., rule_context_ref: sha256:..., intent_ref: sha256:...}
policy_ref: sha256:...
scope_ref: cas:check-scope/...
rule_selector_ref: cas:rule-selector/...
fidelity: {requested: F1, allow_upgrade: true, allow_downgrade: false}
budget: {wall_ms: 30000, cpu_ms: 120000, memory_mb: 4096, max_violations: 100000}
execution: {seed: 17, deterministic: true, checkpoint_policy: periodic}
control: {cancel_token_ref: runtime:cancel/..., idempotency_key: sha256:semantic-request}
```

`max_violations` 触发时结果为 `PARTIAL_LIMIT`，coverage 中已执行 rule 仍保留，但 verdict 不得为 clean。截断后不得继续声称 violation count 是总数。

### 5.3 通用响应 envelope

```yaml
schema_version: ieda.drc.response.v1
request_id: uuid
capability: drc.check_scope@1
status: SUCCESS                 # SUCCESS|PARTIAL|UNSUPPORTED|TIMEOUT|CANCELLED|FAILED|REFUSED
verdict: DIRTY                  # CLEAN|DIRTY|INCONCLUSIVE|NOT_COMPARABLE
refs: {result_ref: cas:drc-result/..., evidence_ref: cas:drc-evidence/..., checkpoint_ref: null}
coverage_summary: {requested: 842, checked: 842, incomplete: 0}
diagnostics: []
runtime: {wall_ms: 481, cpu_ms: 1730, peak_rss_mb: 722}
```

`status=SUCCESS` 只表示请求协议完整执行并持久发布；物理 verdict 可以是 `DIRTY`。`status=PARTIAL` 与 `verdict=CLEAN` 的组合在 schema 层非法。

### 5.4 请求状态机

```text
RECEIVED
  -> VALIDATING
  -> CONTEXT_RESOLVED
  -> PLANNED
  -> RUNNING <-> CHECKPOINTING
  -> NORMALIZING
  -> PUBLISHING
  -> SUCCEEDED

Any nonterminal state -> CANCELLING -> CANCELLED
RUNNING/CHECKPOINTING -> TIMED_OUT
VALIDATING/CONTEXT_RESOLVED/PLANNED -> REFUSED
Any state -> FAILED, with classified diagnostic and no complete claim
```

只有 `SUCCEEDED` 可有 `CLEAN` 或 `DIRTY` verdict。`TIMED_OUT/CANCELLED/FAILED/REFUSED` 只能是 `INCONCLUSIVE` 或 `NOT_COMPARABLE`。

---

## 6. TARGET `RuleContext` 与 `RuleManifest`

### 6.1 `RuleContext` schema

```yaml
schema_version: ieda.drc.rule-context.v1
rule_context_ref: sha256:canonical-content
tech_context_ref: sha256:...
process_id: pdk-qualified-id
deck: {deck_ref: sha256:source-bundle, deck_kind: foundry_derived, deck_version: 1.2.0}
parser: {parser_id: ieda.tech.rule_parser, parser_build_ref: sha256:..., parse_report_ref: cas:...}
units: {coordinate: DBU, dbu_per_micron: 2000, area: DBU2, manufacturing_grid_dbu: 5}
layers: {mapping_ref: cas:tech-layer-map/...}
purposes: [drawing, pin, blockage, cut, fill, special_net]
net_classes: [signal, clock, reset, power, ground, analog, unknown]
rule_manifest_ref: cas:drc-rule-manifest/...
qualification_set_ref: cas:drc-qualification/...
source_artifacts: [{ref: sha256:..., kind: tech_lef, required: true}, {ref: sha256:..., kind: rule_deck, required: true}]
```

规范：

- `rule_context_ref` 哈希 canonical schema、所有 source artifact hash、parser build、单位和 mapping；
- 绝对路径、mtime、host、PID、license token 不进入 hash；
- `dbu_per_micron <= 0`、unit overflow、layer mapping 冲突或 parse diagnostics 有 fatal 时 context 为 invalid；
- LEF-only context 必须标 `deck_kind=lef_only`，不能满足要求 foundry deck 的 policy；
- project overlay 以有序 patch manifest 表示，顺序和冲突解决进入 hash；
- external Calibre deck 若不可解析为 exact instances，unmapped source rules 仍作为 manifest 条目，状态为 unsupported，不能从分母消失。

### 6.2 稳定 layer、purpose 与 net 语义

`TechLayerId` 不使用 `routing_layer_list` 或 `cut_layer_list` 的 vector index。推荐 canonical form：

```text
TechLayerId = hash(tech_context_ref, canonical_layer_name, layer_kind, mask?)
LayerRef    = {tech_layer_id, canonical_name, kind=routing|cut|implant|other}
Purpose     = drawing|pin|blockage|cut|fill|special_net|unknown
NetRef      = {object_id, net_class, is_special, connectivity_generation}
```

规则：

- layer display name 可保留，但协议关联使用 `TechLayerId`；
- routing/cut 同名也因 kind 不同而 ID 不同；
- unknown purpose/net class 不得自动映射到 signal/drawing；
- power/ground special wire 与普通 signal wire必须保留 purpose/net class，避免错误跳过或修复；
- unit conversion 必须 exact；不能表示的浮点 rule 参数在 manifest 编译时拒绝，而非四舍五入；
- bbox 和 polygon 坐标用 64-bit DBU，面积乘法用检查过的 128-bit intermediate 或等价安全实现。

### 6.3 `RuleManifest` schema

```yaml
schema_version: ieda.drc.rule-manifest.v1
manifest_ref: sha256:...
rule_context_ref: sha256:...
completeness: {source_rules_total: 842, normalized: 811, unsupported: 27, parse_failed: 4}
rules:
  - rule_id: sha256:...
    family: parallel_run_length_spacing
    source: {artifact_ref: sha256:..., span: L410:C1-L426:C2, source_rule_name: M3.SPACE.PRL.04}
    applies_to: {layers: [tech-layer-id:M3], purposes: [drawing, pin, special_net], net_relation: different_net, direction: any}
    parameters: {width_breaks_dbu: [0, 280, 600], prl_breaks_dbu: [0, 1000, 5000]}
    spacing_table_dbu: [[140, 180, 220], [180, 240, 300], [220, 300, 400]]
    locality: {kind: finite_halo, halo_dbu: 400, layer_closure: [tech-layer-id:M3], proof_kind: parameter_upper_bound}
    checker: {adapter_id: idrc.prl_spacing, checker_build_ref: sha256:..., supported: true, fidelity_min: F1}
    qualification_ref: cas:...
    severity: ERROR
```

`RuleId` 计算：

```text
RuleId = hash(
  rule_context schema major,
  normalized source artifact hash + source span,
  canonical family + layer tuple + purpose/net relation,
  canonical typed parameters + units + exceptions,
  normalization/parser semantic version
)
```

不得把 checker build 放进 RuleId；checker 升级不改变物理规则身份，但会改变 result/cache/qualification。source span 因无语义格式化变化时可由 parser 提供 stable AST anchor；若做不到，升级 context 并明确 compare 不兼容。

### 6.4 locality 与 qualification

| locality | planner 行为 | 可签 claim |
|---|---|---|
| `object_local` | 检查 touched object old/new 完整几何 | 资格范围内 incremental |
| `finite_halo(d)` | old/new bbox 按该 rule 的 `d` 扩张并取依赖层/对象 | 通过 differential qualification 后 incremental |
| `component` | 拉取完整 polygon/net/via stack/component | scoped component claim |
| `global` | 升级 full design | full only |
| `unknown` | full checker 或 unsupported | 不能 local |

qualification 至少绑定 `rule_id pattern / checker_build_ref / geometry adapter / scope mode / corpus / oracle / thresholds / expiry`。一次反例只撤销命中的最小资格范围；若无法定位，冻结整个 adapter build。

---

## 7. TARGET `CheckScope` 与 scope proof

### 7.1 Schema

```yaml
schema_version: ieda.drc.check-scope.v1
scope_id: sha256:canonical-scope
snapshot_ref: sha256:...
mode: dirty_incremental          # full|explicit|dirty_incremental|component
requested:
  regions: [{ll_x: 1000, ll_y: 2000, ur_x: 9000, ur_y: 12000, unit: DBU}]
  layers: [tech-layer-id:M3, tech-layer-id:V3]
  nets: [object-id:net/123]
  objects: [object-id:wire/456]
  purposes: [drawing, cut]
dirty_input: {delta_ref: sha256:..., dirty_set_ref: cas:..., old_geometry_ref: cas:..., new_geometry_ref: cas:...}
resolved: {rule_scopes_ref: cas:..., checked_region_union_ref: cas:..., component_refs: [], full_escalated_rules: []}
proof: {planner_build_ref: sha256:..., derivation_ref: cas:drc-scope-proof/..., conservative: true}
```

空 selector 语义必须显式：

- `mode=full` 可省略 region/object selector，但必须有非空 required rule selector 或 policy 展开的 rule set；
- `mode=explicit` 空 region/layer/net/object 全部拒绝为 `EMPTY_SCOPE`；
- `mode=dirty_incremental` 必须有可验证 delta、old geometry 和 new geometry；
- 空 rule selector 只有 policy 明确定义为 exact manifest 全集时才允许；不能沿用 legacy “all loaded families” 的隐式语义。

### 7.2 Scope resolution 规则

1. 校验 bbox 非反向、坐标未溢出、polygon 正交性/闭合性和 layer existence。
2. 将 net/name selector 在固定 snapshot 内解析为 ObjectId；零匹配或多匹配均拒绝。
3. 将 rule selector 展开为 exact RuleId 集合，并记录 selector expression 和 manifest hash。
4. 读取 iDB actual touched set，不能只信 proposal declared scope。
5. 对每个 touched shape 收集 before 和 after 的完整 canonical geometry。
6. 对每个 RuleId 按 locality 生成独立 scope；不能先取一个全局固定 halo 再冒充逐 rule 证明。
7. 合并可安全共享的 work tiles，但 evidence 保留 rule-specific original scope。
8. component/global/unknown 按 manifest 升级；预算不足返回 `PARTIAL/INCONCLUSIVE`。
9. 记录所有 over-approximation；性能优化只能缩减经形式或 differential 证明的冗余。

### 7.3 空间 halo 计算

finite rule 的 halo 必须由所有可能交互参数的保守上界推导：

```text
halo(rule) = max(
  spacing,
  within,
  parallel_within,
  EOL extension,
  cut-to-metal distance,
  PRL table maximum,
  exception lookaround,
  geometry decomposition guard
)
```

若任一条件依赖未解析 table、无限 connectivity、density window 或外部脚本，locality 为 `unknown/global`。不得用 routing pitch、平均 spacing 或当前设计中观测到的最大距离替代 deck 上界。

### 7.4 old/new geometry 与保守 invalidation

对每个 delta op：

```text
Removed shape: dirty = halo(old_bbox)
Added shape:   dirty = halo(new_bbox)
Moved shape:   dirty = halo(old_bbox) union halo(new_bbox)
Reshaped:      dirty = halo(old_geometry) union halo(new_geometry)
Layer change:  old layer closure union new layer closure
Via replace:   all old/new cut and enclosure layers + stack component
Reconnect:     geometry closure + affected net/component relations
```

检查最终状态不需要覆盖抽象移动路径上的中间几何，因为中间状态未 materialize；若 iDB 实际执行分步 mutation 并暴露中间 committed state，则每一步是独立 delta，必须分别验证。

iDRC 的 `InvalidationSet` 是证书/cache 的保守上界：

- geometry digest 变化使重叠 rule-scope result stale；
- RuleContext/checker/qualification 变化使所有相关 cache/certificate stale；
- net connectivity generation 变化使依赖 net relation/component 的结果 stale；
- die/layer/manufacturing grid 变化默认 full invalidation；
- 无法证明不相交时 invalidate，不以 cache 命中率为由缩小。

### 7.5 incremental/full 资格

每个 `(rule family/variant, checker build, scope planner build, geometry adapter, tech family)` 独立资格：

```text
for each qualified random or real delta:
  incremental = check(candidate, conservative dirty closure)
  full = check(candidate, full design, same RuleContext/build)
  project full violations onto closure and dependency relation
  require exact canonical set equality
  require no full-only violation causally attributable to delta outside closure
```

不能只比较 count。任何 ID/witness 差异、边界外新 violation、coverage 差异或 non-determinism 都是 qualification failure。抽检频率由风险和近期反例调整；高风险 via stack、global/component 和新 parser build 默认 100% full，资格后才能降采样。

---

## 8. TARGET 稳定对象、shape 与 violation 身份

### 8.1 ObjectId 与 ShapeId

iDRC 消费 iDB ObjectId，不自行以 net name/vector index 造 ID。shape identity 定义为：

```text
ShapeId = hash(
  owner ObjectId + object generation,
  TechLayerId + Purpose,
  canonical geometry kind and coordinates,
  shape role (wire/via-cut/enclosure/pin/blockage/fill),
  canonical child ordinal supplied by iDB registry
)
```

canonical rectangle 固定 `(ll_x,ll_y,ur_x,ur_y)`；polygon 去重复点、固定 winding、选择字典序最小起点，并规范 hole 顺序。不能用内存地址、R-tree insertion index、cluster index、线程号或遍历顺序。

rename 若 iDB ObjectId 和 geometry 不变，ShapeId 稳定；delete+recreate 即使名称相同也因 generation 不同而不同。shape geometry 改变时 ShapeId 改变，这是精确 occurrence identity 的必要条件。

### 8.2 `ViolationId` schema 与计算

```yaml
schema_version: ieda.drc.violation-id.v1
algorithm: sha256-canonical-v1
rule_id: sha256:...
subject_shape_ids: [sha256:..., sha256:...]
witness_key:
  relation: edge_to_edge
  anchors_dbu: [[1200, 4000], [1340, 4000]]
  measured: 140
  required: 180
  orientation: horizontal
violation_id: sha256:...
```

```text
ViolationId = hash(
  RuleId,
  sorted subject ShapeIds with typed roles,
  canonical witness relation and anchors,
  canonical layer/net relation
)
```

snapshot_ref 不进入 ViolationId，因此未变 shape 上的同一 occurrence 可跨相邻 snapshot 稳定；snapshot_ref 仍在 ViolationRecord 中防止脱离上下文使用。severity 不进入 ID，policy 改 severity 不应伪造 new/resolved。

### 8.3 跨 rerun 与跨 delta 连续性

同 snapshot/context/build 的 rerun 必须 byte-identical。跨 snapshot 时：

- exact ViolationId 相同 -> `residual_unchanged`；
- RuleId 和 stable ObjectIds 相同、geometry witness 变化 -> 使用 `ContinuityMatch`，状态 `residual_changed`；
- base 无匹配、candidate 有 -> `new`；
- base 有、candidate 无匹配 -> `resolved`；
- 多对多候选无法唯一匹配 -> `ambiguous`，不得靠最近 bbox 静默决定。

`ContinuityMatch` 独立于 ViolationId：

```yaml
base_violation_id: sha256:...
candidate_violation_id: sha256:...
match_kind: same_objects_changed_witness
score_components: {object_identity: exact, rule: exact, anchor_distance_dbu: 40}
deterministic_tie_break: canonical-id
confidence: 1.0
```

RuleContext 不同默认 `NOT_COMPARABLE`。只有显式 RuleEquivalenceMap 能跨 deck compare，结果注明 mapped/unmapped，不签 clean。

---

## 9. TARGET `ViolationRecord`、severity 与 explain witness

### 9.1 Schema

```yaml
schema_version: ieda.drc.violation-record.v1
violation_id: sha256:...
snapshot_ref: sha256:...
rule_context_ref: sha256:...
rule_id: sha256:...
family: enclosure
severity: ERROR                 # INFO|WARNING|ERROR|FATAL
subjects:
  - {object_id: object-id:via/1, shape_id: sha256:..., role: cut, net_class: signal}
  - {object_id: object-id:wire/2, shape_id: sha256:..., role: lower_enclosure, net_class: signal}
geometry:
  bbox: {ll_x: 10, ll_y: 20, ur_x: 40, ur_y: 50, unit: DBU}
  witness_ref: cas:drc-witness/...
layers:
  - {tech_layer_id: tech-layer-id:V2, purpose: cut}
  - {tech_layer_id: tech-layer-id:M2, purpose: drawing}
net_relation: same_net
measurement:
  kind: enclosure_pair
  actual: {east: 20, west: 10, north: 30, south: 30, unit: DBU}
  required: {end: 20, side: 20, unit: DBU}
source_rule_ref: cas:rule-source-span/...
scope_id: sha256:...
checker:
  adapter_id: idrc.enclosure
  checker_build_ref: sha256:...
  fidelity: F1
qualification_ref: cas:...
```

severity 来源优先级固定为 `policy override > deck severity > family default`，并记录最终来源。severity 只影响 gate/排序，不允许从 coverage 分母删除 WARNING/INFO；policy 若只要求 ERROR/FATAL clean，selector 必须显式记录。

### 9.2 Witness 要求

每条 violation 至少包含：

- exact RuleId 和可定位 source span；
- 所有决定 predicate 的 stable subjects 和 typed roles；
- canonical bbox，但 bbox 不是完整 witness；
- actual measurement、required threshold、单位、比较运算符和 exception evaluation；
- layer/purpose/net relation；
- checker build、fidelity、scope 和 qualification；
- 若几何太大则用 CAS witness ref，并在 record 中保存 hash/summary。

`drc.explain` 只能由这些字段生成结构化 explanation。例如 spacing explain 返回两条 edge、平行长度、实际间距、table row/column、same/different-net 判断和未触发例外。缺 operand 时状态为 `EXPLANATION_INCOMPLETE`，不能生成看似完整的文本。

### 9.3 Dedup 与 cluster

raw dedup key 是 ViolationId。两个 RuleId、两个不同 subject role 组合或两个不同 witness occurrence 即使 bbox 相同也不能合并。

cluster 是派生视图：

```text
cluster_id = hash(result_ref, clustering_policy_ref, sorted member ViolationIds)
```

cluster 必须满足：成员只出现一次、所有 raw violation 被保留、member count 总和等于 raw count。不同 clustering policy 的 cluster ID 可不同，不影响 certificate。

---

## 10. TARGET `Coverage`、`DRCResult` 与 `Evidence`

### 10.1 Exact Coverage schema

```yaml
schema_version: ieda.drc.coverage.v2
rule_context_ref: sha256:...
scope_id: sha256:...
requested_rule_ids_ref: cas:...
counts:
  requested: 842
  applicable: 811
  checked: 811
  skipped: 0
  unsupported: 27
  failed: 4
  refused: 0
  proven_not_applicable: 0
complete: false
entries_ref: cas:drc-coverage-entries/...
blocking_reasons:
  - {code: UNSUPPORTED_RULES, rule_ids_ref: cas:...}
  - {code: RULE_EXECUTION_FAILED, rule_ids_ref: cas:...}
```

每个 requested RuleId 必须恰有一个 terminal entry：

| 状态 | 精确定义 | clean 影响 |
|---|---|---|
| `CHECKED` | qualified checker 成功，全部所需 work units 完成且 evidence 完整 | 可参与 clean |
| `SKIPPED_POLICY` | policy/预算明确跳过本可执行规则 | 阻断 required claim |
| `SKIPPED_LIMIT` | violation/时间/资源上限后未执行 | 阻断 |
| `UNSUPPORTED` | 无 parser/checker/geometry 能力 | 阻断 |
| `FAILED` | checker/work unit 异常、非确定或 evidence 写失败 | 阻断 |
| `REFUSED` | selector/context/rule 参数无效，未开始 | 阻断 |
| `NOT_APPLICABLE` | 有可审计 proof 表明 scope 无对应 layer/purpose/object | 只在 policy 接受该 proof 时不阻断 |

`unsupported` 指 source rule 存在但能力缺失；“technology 未加载”不能既从分母删除又叫 unsupported。parse failed source rule 也必须以 stable placeholder RuleId 或 source-entry ID 保留。

### 10.2 Clean 判定算法

```text
coverage_complete =
  every required requested rule has terminal CHECKED
  or policy-approved proven NOT_APPLICABLE

verdict = DIRTY
  if any valid raw violation exists
else CLEAN
  if status=SUCCESS
     and coverage_complete
     and scope/claim relation is valid
     and all qualifications are current
     and evidence publish/replay checks pass
else INCONCLUSIVE
```

因此可能同时有 violations 和 incomplete coverage；外部响应 verdict 为 `DIRTY`，coverage 仍明确 incomplete。不能因为已经发现错误就省略未执行项，除非调用方设置 fail-fast；fail-fast 结果是 partial dirty，不是完整 violation census。

### 10.3 `DRCResult` schema

```yaml
schema_version: ieda.drc.result.v1
result_ref: sha256:canonical-result
request_semantic_hash: sha256:...
snapshot_ref: sha256:...
tech_context_ref: sha256:...
rule_context_ref: sha256:...
policy_ref: sha256:...
scope_id: sha256:...
claim:
  kind: scoped_incremental
  rule_set_ref: cas:...
  assumptions_ref: cas:...
status: SUCCESS
verdict: CLEAN
fidelity: {requested: F1, used: F1, external_oracle: false}
coverage_ref: cas:drc-coverage/...
violation_set_ref: cas:drc-violations/...
raw_violation_count: 0
truncated: false
work_ledger_ref: cas:drc-work-ledger/...
evidence_ref: cas:drc-evidence/...
qualification_refs: [cas:...]
```

`result_ref` 哈希不含 wall time、worker host、日志顺序；这些在 Evidence runtime metadata。它包含 canonical violation set、coverage、scope、contexts、checker builds、fidelity 和 work plan semantic digest。

### 10.4 Evidence schema

```yaml
schema_version: ieda.drc.evidence.v1
evidence_ref: sha256:manifest
producer: {capability: drc.check_scope@1, service_build_ref: sha256:...}
subject: {snapshot_ref: sha256:..., semantic_digest: sha256:...}
contexts: {tech: sha256:..., rule: sha256:..., policy: sha256:...}
inputs:
  scope_ref: cas:...
  geometry_manifest_ref: cas:...
  delta_ref: sha256:...
outputs:
  result_ref: cas:...
  coverage_ref: cas:...
  violation_set_ref: cas:...
  work_ledger_ref: cas:...
execution:
  partition_plan_ref: cas:...
  seed: 17
  thread_count: 8
  runtime_stats_ref: cas:...
artifacts:
  - {kind: normalized_json, ref: sha256:..., required: true}
  - {kind: legacy_violation_map, ref: sha256:..., required: false}
replay: {recipe_ref: cas:..., expected_result_digest: sha256:...}
```

Evidence manifest 原子发布前检查所有 required refs 可读且 hash 一致。legacy JSON/GDS/console 可以作为 optional artifact，不能成为唯一 coverage 或 witness 证据。

---

## 11. 六个 capability 的规范行为

### 11.1 `drc.rule_discovery@1`

输入 snapshot + RuleContext，输出 exact RuleManifest、checker limits、fidelity 和 qualification。发现流程必须执行 parser diagnostics、unit/layer mapping、source rule conservation 和 adapter lookup。

状态：`DISCOVERED`、`PARTIAL_MANIFEST`、`INVALID_CONTEXT`、`UNSUPPORTED_DECK`。`PARTIAL_MANIFEST` 可供 inspect，但任何要求全 deck 的 check 都 inconclusive。

### 11.2 `drc.check_scope@1`

支持 full、explicit、component 和 dirty incremental。planner 必须先生成 per-rule scope proof，再执行。返回 raw violations、Coverage、work ledger 和 Evidence。分页只影响传输，不影响 result hash。

### 11.3 `drc.explain@1`

只接受当前可读 result 中的 ViolationId。验证 result/record/witness hash 后返回 typed predicate trace、source rule span、对象关系和图形 artifact refs。stale/missing witness 返回结构化 incomplete，不重新读取 live DB 猜测。

### 11.4 `drc.compare@1`

比较前检查 snapshot lineage、RuleContext、RuleId universe、unit、scope projection、fidelity 和 checker comparability。输出：

```yaml
comparability: COMPARABLE
base_result_ref: cas:...
candidate_result_ref: cas:...
new: [violation-id...]
resolved: [violation-id...]
residual_unchanged: [violation-id...]
residual_changed: [continuity-match...]
ambiguous: []
coverage_delta_ref: cas:...
```

若 candidate coverage 比 base 少，仍可报告已知 new violation，但总体 `NOT_COMPARABLE/INCONCLUSIVE`，不能宣称 resolved 总数或 improvement。

### 11.5 `drc.propose_repair@1`

先校验 violation current、rule family template qualified、subjects 未 stale、policy 允许建议。生成有限 proposal set，按 deterministic cost vector 排序。输出不是 mutation，不含 `applied=true`。

### 11.6 `drc.validate@1`

输入 base/candidate snapshot、actual delta、可选 originating proposal。执行以下门禁：

1. candidate 是 base 的可接受 lineage descendant；
2. actual touched 与 delta manifest 一致；
3. proposal precondition 若存在仍成立；
4. scope 包含 actual old/new dirty closure、原 violation rule 和 secondary rules；
5. 运行 required fidelity；
6. compare new/resolved/residual，单列 coverage 差异；
7. 输出 proposal outcome，但不决定候选 accept/commit。

原 violation 消失但出现等价 changed witness 时不算 resolved；原 violation 消失但新增更高 severity 或 frozen/timing/route 风险时，iDRC 只报告 DRC 部分，最终拒绝由 Hub/iEval/Runtime policy 决定。

---

## 12. Rule coverage、skip 与 unsupported 的红线

### 12.1 分母来源

coverage 分母按以下顺序确定：

```text
policy required claim
  -> exact RuleContext manifest
  -> explicit RuleId/family/layer/purpose/severity selector
  -> requested universe
  -> auditable applicability proof
  -> terminal execution bucket per RuleId
```

禁止从 checker 实际执行列表反推 requested universe。禁止把未被 parser 识别的 source rule 从 source count 删除。禁止仅以 current `_exist_rule_set` 作为 full-deck denominator。

### 12.2 典型情形

| 情形 | status/verdict | 原因 |
|---|---|---|
| requested 842，checked 842，0 violations，full qualified | SUCCESS/CLEAN | 完整 claim |
| requested 842，checked 811，unsupported 27，failed 4，0 violations | PARTIAL/INCONCLUSIVE | 零报告不等于 clean |
| requested subset 3，checked 3，0 violations | SUCCESS/CLEAN scoped subset | 只证明 subset |
| empty deck | REFUSED/INCONCLUSIVE | 没有可证明 rule universe |
| empty explicit selector | REFUSED/INCONCLUSIVE | 不能静默 all-loaded |
| unknown rule name | REFUSED/INCONCLUSIVE | 不转为 `kNone` 后继续 |
| checker crash after 5 violations | PARTIAL/DIRTY | 已知 dirty，但 census/coverage 不完整 |
| F4 license unavailable | UNSUPPORTED/INCONCLUSIVE | 不冒充 F3/F4 clean |
| local scope checked, global rule required | PARTIAL/INCONCLUSIVE | 必须 full escalation |
| all rules NOT_APPLICABLE with valid full-scope proof | SUCCESS/CLEAN only if policy permits | proof 进入 evidence |

### 12.3 CURRENT-WT 迁移要求

现有 `RuleCoverageReport` 保留为 legacy guard，下一步必须：

- 将 26-family 手写表改为由 validator registry 生成并做 CMake/test conservation；
- 将 `loaded_rules` 拆为 source rule instance、normalized、adapter-supported 和 qualified；
- 将 `partial_clean` 映射为 `INCONCLUSIVE`，避免“clean”字符串被上层误用；
- 把 `drc_summary.json` 纳入 versioned Evidence，而不是 temp directory 的独立旁路真值；
- 对 `outputRuleCoverageJson()` 写失败返回结构化 failed，service worker 不直接结束宿主进程；
- 测试用 `add_test()` 注册，默认 CI 执行，不保持 `EXCLUDE_FROM_ALL` 孤岛。

---

## 13. TARGET RepairProposal 与 proposal-only 策略

### 13.1 Schema

```yaml
schema_version: ieda.drc.repair-proposal.v1
proposal_id: sha256:canonical-proposal
source: {result_ref: cas:..., violation_ids: [sha256:...]}
base_snapshot_ref: sha256:...
rule_context_ref: sha256:...
strategy: shift_segment
subjects: [{object_id: object-id:wire/7, expected_generation: 4}]
parameters: {axis: x, min_delta_dbu: 40, max_delta_dbu: 120, grid_dbu: 5}
declared_scope: {region_ref: cas:..., layers: [tech-layer-id:M3], nets: [object-id:net/2]}
preconditions: [not_frozen, route_owner_available, same_snapshot_head]
expected_effects: {target_rules: [rule-id:...], target_violations: [sha256:...]}
secondary_rule_ids: [rule-id:spacing, rule-id:min_area, rule-id:eol]
risks:
  drc: {level: medium, reasons: [secondary_spacing]}
  route: {level: high, reasons: [track_occupancy, connectivity]}
  timing: {level: unknown, affected_nets: [object-id:net/2]}
  frozen: {level: blocked, affected_objects: []}
materializer: {owner: iRT, typed_delta_kind: RoutePatch}
cost_vector: {edit_count: 1, moved_dbu: 40, new_vias: 0, estimated_wirelength_dbu: 0}
qualification_ref: cas:repair-template-qualification/...
```

ProposalId 绑定 base snapshot、source violations、strategy、subjects、parameter domain、preconditions、risks 和 template build。它不包含 candidate snapshot，因为尚未 apply；materialized 后由 `validate` 记录 `proposal_id -> actual delta_ref -> candidate_snapshot_ref`。

### 13.2 family 到策略映射

| violation family | 可建议策略 | apply owner | 必查 secondary/risk |
|---|---|---|---|
| spacing/EOL/notch/corner | shift、trim、局部 reroute、change layer | iRT | width、area、EOL、via、route capacity、timing |
| metal/cut short | separate、reroute、layer change | iRT/iECO | connectivity、frozen net、timing、new spacing |
| enclosure/overlap | extend enclosure、replace via、select via variant | iECO/iRT | adjacent cut、min area、stack、EM/route |
| minimum area/hole/step | metal patch、reshape、reroute | iRT/iECO | spacing、notch、density、timing capacitance |
| minimum width/maximum width | widen、split、reroute | iRT | spacing、area、capacity、RC/timing |
| minimum cut/max via stack | add/replace/reduce via stack | iECO/iRT | enclosure、cut spacing、connectivity、IR/EM |
| off-grid/wrong-way/out-of-die | snap、move、reroute | iRT/iDB domain tool | displacement、frozen、timing、die constraints |
| component/unknown or unsupported | no automatic proposal | none | return `NO_QUALIFIED_TEMPLATE` |

Repair template 只做有限、schema 化参数枚举和 exact predicate 预筛。语言模型可以选择已注册 template 或解释风险，不能生成任意坐标 mutation 绕过 template/materializer。

### 13.3 风险与验证门禁

- `frozen=blocked` 的 proposal 不返回可物化动作，除非 Runtime policy 有更高审批并创建新 proposal；
- timing risk 为 unknown 不能被序列化为 none；受影响 net/cone 交给 iEval/iSTA；
- route risk 由 iRT 做 track/via/connectivity feasibility；iDRC 的几何 clearance 不是 routability；
- proposal 必须包含原 RuleId、全部模板声明 secondary RuleIds 和 conservative declared scope；
- actual touched 超出 declared scope、对象 generation stale 或参数超 domain -> `PROPOSAL_DIVERGED`；
- resolved 只说明 source occurrence 不再存在；最终 accept 还要求 required DRC coverage complete、无 forbidden new violations、route/timing/frozen certificates 完整；
- iDRC 不调用 iECO `repair()` 或 iRT mutation API，兼容层也不得隐藏 apply。

---

## 14. TARGET F0-F4 fidelity 与升级路由

| 档位 | 计算 | 允许用途 | 禁止用途 |
|---|---|---|---|
| F0 | rule bounds、bbox/track occupancy、template predicate 预筛 | proposal 排序、明显不可行淘汰 | 任何 clean/dirty certificate，除非确切解析 predicate 已注册为 checker |
| F1 | qualified rule-aware incremental iDRC | 低/中风险 scoped certificate、候选迭代 | 未资格 family、global/unknown、full claim |
| F2 | 扩大 component/region、同一 exact kernel、更多 secondary rules | near-gate 候选确认 | 冒充 full design |
| F3 | 全设计 exact iDRC、完整 required internal deck | internal full DRC claim | 商业 signoff 等价 |
| F4 | Calibre/批准 external oracle、完整映射与 artifact | correlation、release/signoff policy 输入 | license/coverage 缺失时静默降档 |

路由顺序：先满足 claim 最低 fidelity，再看 rule qualification、locality、delta 风险、near-gate、OOD、预算。可升级不可隐式降级；调用方请求 F1 而 rule 要求 full 时，若 `allow_upgrade=true` 升 F3，否则返回 `NONLOCAL_REQUIRES_FULL`。F4 不可用时返回 `ORACLE_UNAVAILABLE`。

升级触发包括：clock/reset/PG/frozen domain、via stack、component/global rule、qualification 新鲜度不足、incremental/full 抽检、ambiguous compare、repair secondary risk、coverage 缺口和 candidate 接近 commit gate。

---

## 15. TARGET 执行、timeout、cancel、checkpoint、replay 与 cache

### 15.1 Deterministic work ledger

work unit key 为 `(RuleId, canonical scope tile/component, layer closure, geometry shard digest)`。planner 固定 canonical 顺序；worker 可并行领取，normalizer 按 key/ViolationId 排序归并。ledger 对每项记录 `PENDING/RUNNING/CHECKED/SKIPPED/FAILED/CANCELLED`、input digest、adapter build、attempt、artifact refs。

当前 `100*pitch` cluster 可作为 tile size heuristic，但 correctness halo 来自 RuleManifest。tile 重叠结果以 ViolationId 去重；tile 边界 metamorphic test 必须证明 partition 不影响 raw set。

### 15.2 Timeout 与 cancel

- Runtime deadline 和 cancel token 在 request validation 时固定；
- geometry build、每个 rule、每个 tile/component、normalization 和 publish 都有 cooperative safe point；
- deadline 到达停止领取新 work，运行中 kernel 在下一个 safe point 退出；不可杀宿主全局状态；
- 已完成 ledger/violations 可发布 partial evidence，未完成 rule 标 `SKIPPED_LIMIT/CANCELLED`；
- cancel race 在 publish 前再次检查；已完整原子发布可返回 SUCCESS，否则 CANCELLED；
- forced worker kill 后 workspace quarantine，结果 FAILED/CANCELLED，不能假装空 violations。

### 15.3 Checkpoint 与 resume

checkpoint 包含 request semantic hash、snapshot/context/build refs、partition plan、completed ledger、canonical partial accumulator hashes、next work key 和 schema version。状态为 `PREPARING -> DURABLE -> PUBLISHED`。resume 仅在全部 refs 和 qualifications 仍有效时继续；否则 `CHECKPOINT_STALE`。checkpoint 永不携带 clean verdict。

### 15.4 Replay

fresh-process replay 从 immutable snapshot artifact、RuleContext、scope、checker/service builds、seed 和 partition recipe 重建。要求 result/coverage/violation canonical digest 一致；wall time、thread count 可不同。若 legacy singleton 无法隔离或 build 不再可取，返回 `NON_REPLAYABLE_DEPENDENCY`，相关 certificate 不能宣称 fully replayable。

### 15.5 Cache

```text
CacheKey = hash(capability major, snapshot_ref, RuleContext, policy/selector,
  CheckScope proof, checker/planner/geometry builds, fidelity, qualification,
  deterministic flags, schema and output-affecting limits)
```

timeout、cancel、failed 默认不进入 complete-result cache；partial checkpoint 使用独立 namespace。不同 snapshot 不因 bbox 相同直接复用；未来可用 content-addressed geometry shard，但必须包含完整 dependency digest。cache hit 重新检查 CAS、ACL、retention 和 qualification freshness。

---

## 16. Fail-closed 错误语义

| code | status/verdict | 恢复动作 |
|---|---|---|
| `INVALID_RULE_CONTEXT` / `RULE_PARSE_FAILED` | REFUSED/INCONCLUSIVE | 修复 tech/deck/parser |
| `EMPTY_RULE_SET` / `EMPTY_SCOPE` / `AMBIGUOUS_SELECTOR` | REFUSED/INCONCLUSIVE | 调用方显式重发 |
| `STALE_SNAPSHOT` / `STALE_OBJECT` / `TECH_MISMATCH` | REFUSED/INCONCLUSIVE | Runtime re-inspect，不自动 rebase |
| `UNSUPPORTED_RULE` / `NONLOCAL_REQUIRES_FULL` | UNSUPPORTED/INCONCLUSIVE | 升 fidelity 或补 checker |
| `CHECKER_FAILED` / `NONDETERMINISTIC_RESULT` | FAILED/INCONCLUSIVE 或 DIRTY partial | quarantine build，保留反例 |
| `PARTIAL_LIMIT` / `TIMEOUT` / `CANCELLED` | PARTIAL/INCONCLUSIVE 或已知 DIRTY | resume/upgrade/abandon |
| `EVIDENCE_PUBLISH_FAILED` / `CACHE_CONTEXT_MISMATCH` | FAILED/INCONCLUSIVE | 不签 certificate，重跑 |
| `REPLAY_MISMATCH` / `CHECKPOINT_STALE` | FAILED/INCONCLUSIVE | 冻结 qualification/cache |
| `PROPOSAL_STALE` / `PROPOSAL_DIVERGED` / `FROZEN_OBJECT_RISK` | REFUSED/NOT_COMPARABLE | 重新 propose 或审批 |
| `ORACLE_UNAVAILABLE` / `LICENSE_DENIED` | UNSUPPORTED/INCONCLUSIVE | 等待 F4 或改 policy，不改标签 |

diagnostic 必含 stable code、phase、RuleId/work key/scope、retryability、evidence ref 和脱敏 message。禁止 `exit(0)`；服务模式下 fatal legacy call 必须在 worker process 隔离并映射非零退出。未知异常统一 `INTERNAL_ERROR`，但不能吞掉已知 coverage 缺口。

---

## 17. TARGET LLD、源码落点与 CMake

### 17.1 模块落点

```text
src/operation/iDRC/agent/
  schema/{RuleContext,RuleManifest,CheckScope,ViolationRecord,Coverage,RepairProposal,DRCResult,Evidence}.{hpp,cpp}
  service/{DRCService,RequestValidator,CapabilityDispatcher}.{hpp,cpp}
  rule/{RuleManifestCompiler,RuleRegistry,QualificationRegistry}.{hpp,cpp}
  scope/{IncrementalScopePlanner,LocalityResolver,ScopeProof}.{hpp,cpp}
  identity/{GeometryCanonicalizer,ViolationIdentity,ContinuityMatcher}.{hpp,cpp}
  execution/{CheckerRouter,WorkPlanner,WorkLedger,CheckpointStore}.{hpp,cpp}
  adapter/{LegacyIDRCAdapter,IDBGeometryAdapter,CalibreAdapter}.{hpp,cpp}
  explain/{ViolationExplainer,WitnessBuilder}.{hpp,cpp}
  compare/{DRCComparator,CoverageComparator}.{hpp,cpp}
  repair/{RepairTemplateRegistry,RepairProposalGenerator,RiskAnnotator}.{hpp,cpp}
  evidence/{ResultNormalizer,EvidencePublisher,ReplayRunner,DRCCache}.{hpp,cpp}
  tests/{unit,property,metamorphic,differential,fuzz,fault,perf,oracle}/
```

public schema 不 include Boost、iDB internal、Runtime 或 singleton headers。`LegacyIDRCAdapter` 是唯一允许调用 `DRCI/DRCRV` 的迁移层，并在隔离 worker 中把 32-bit `ids::*` 转换为 target records。

### 17.2 CMake target 图

```text
idrc_agent_schema
  <- idrc_rule_manifest, idrc_scope_planner, idrc_violation_identity
  <- idrc_execution, idrc_explain, idrc_compare, idrc_repair, idrc_evidence
  <- idrc_legacy_adapter
  <- idrc_agent_service
  <- idrc_agent_tests
```

实现要求：使用 target-local C++20/compile definitions，不在 iDRC 子目录改全局 `CMAKE_BUILD_TYPE`；测试 `add_executable + add_test` 并打 `idrc_agent` label；fuzz/perf/oracle 以显式 option 和 fixture 启用；service 不 PUBLIC link private data-manager internals；安装/version export 只暴露 schema/facade。

### 17.3 PR 切片与门禁

| PR | 内容 | 依赖 | merge gate |
|---|---|---|---|
| DRC-0 | CURRENT-WT coverage/logger 整理、CTest、legacy golden | 无 | zero violation 永不 signoff clean；非零 fatal exit |
| DRC-1 | schema、RuleContext/Manifest、source conservation | DRC-0 + Tech | parser mutation/fuzz；每 source rule 唯一终态 |
| DRC-2 | iDB geometry/ObjectId adapter、canonical IDs/witness | DRC-1 + iDB | reload/order/thread ID 稳定 |
| DRC-3 | rule-aware scope、old/new dirty、work ledger | DRC-2 | property + incremental/full equality |
| DRC-4 | service/explain/compare/evidence/cache/replay | DRC-3 + Runtime CAS | fresh-process digest equality |
| DRC-5 | repair templates、iRT/iECO materializer handshake | DRC-4 | proposal 无 mutation；actual delta divergence 拒绝 |
| DRC-6 | Hub certificate/iEval workflow | DRC-4/5 + Hub/iEval | incomplete/stale 无 commit path |
| DRC-7 | Calibre adapter、qualification dashboard | DRC-6 | per-rule mapping/correlation gate |

共享 schema 的最小变化走 `compat/*`；deterministic kernel/QoR/Calibre correlation 留在 parity lane；Agent service/state/Hub 接线留在 agent lane。已发布 integration branch 只 merge，不 rebase。每个 commit 通过 `./dev/branch_commit.sh`，不提交 build tree。

---

## 18. 测试、oracle 与可杀假说

### 18.1 测试矩阵

| 层 | 必测内容 | 主要判据 |
|---|---|---|
| analytic | 26 family 的最小构造；阈值 `-1/0/+1 DBU`、touch/open/closed overlap、hole/corner/EOL/via | predicate/witness/RuleId 精确 |
| property | 随机正交 polygon、layer/net relation、rule table；coverage partition conservation | 不 crash、不漏 bucket、几何不变量 |
| metamorphic | 平移、镜像、合法旋转、shape/order/thread/tile 重排、等价 polygon decomposition | violation 集合按变换同构，ID 规则符合规范 |
| incremental-full | add/delete/move/reshape/layer/via/reconnect 的 old/new closure | projected exact set equality，零 delta-caused 漏报 |
| fuzz | request/schema/deck/parser/RuleManifest/polygon/page/checkpoint/Calibre report | bounded resource，无 UB/宿主退出 |
| fault | checker crash、OOM、timeout、cancel race、CAS 写失败、stale cache、corrupt checkpoint、license loss | fail closed、无伪 clean、可恢复 |
| performance | full 与 0.01/0.1/1% dirty；1/2/4/8/16 thread；dense/large polygon/via | speedup、RSS、cancel latency、determinism |
| Calibre oracle | raw marker + rule source mapping、边界 corpus、真实 PDK/design、waiver 分离 | per-RuleId precision/recall、unmapped conservation |
| end-to-end | iDRC proposal -> iRT/iECO -> iDB branch -> Hub -> iEval -> Runtime | 无直接 mutation；不完整 bundle 无 commit |

### 18.2 强制反例注入

- empty deck、empty selector、unknown family、parser 丢一个 rule、checker 跳一个 tile；
- violation list 为空但 unsupported/failed 非空；
- move 的 old bbox 周边保留 shape、新 bbox 周边新增 shape；
- halo 外 `+1 DBU` 不交互、halo 边界和 `-1 DBU` 正好触发；
- minimum-area patch 引入 spacing，via replace 引入 enclosure/cut spacing；
- rename 保持 ObjectId、delete/recreate 重用名称、线程和 insertion order 改变；
- bbox 相同但 witness/RuleId 不同，多对多 continuity ambiguous；
- F4 license 中断后错误降为 F3 标签；
- cancel 恰逢 normalization/publish，checkpoint 在 checker build 升级后 resume；
- cache artifact hash 正确但 RuleContext/policy/qualification 已变；
- Calibre unmapped marker 和 iDRC-only marker，不能从 precision/recall 分母隐藏。

### 18.3 可杀假说

`H-DRC-1`：对已标 finite-halo 的 rule，manifest 上界足以覆盖所有 delta-caused interaction。任一 full-only 反例撤销对应 locality qualification。

`H-DRC-2`：canonical subject+witness ID 在调度、tile 和无关 edit 下稳定。任一非语义漂移阻断 DRC-2。

`H-DRC-3`：首批 route/via ECO 中 F1 在完整证据下显著低于 F3 成本且无漏报。若 p50 成本比不达门限，保留 correctness、重做 partition/cache，不缩 halo。

`H-DRC-4`：repair templates 提高候选有效率而不增加 forbidden secondary violation。若无改善或风险升高，禁用该 template，不调低验证门禁。

---

## 19. 量化完成定义与发布门禁

ai1.1 release 必须同时满足：

- schema golden/negative tests 100% 通过；所有 required 字段缺失均 fail closed；
- 100,000 个 coverage mutation 中伪 `CLEAN` 为 0；source rule conservation 差异为 0；
- 每个已支持 family 至少 20 个 analytic 边界例，`-1/0/+1 DBU` witness 期望 100% 一致；
- 10,000 个随机 delta 的 incremental/full projection 差异为 0；发现一个漏报即撤销对应 qualification；
- 同请求在 thread `{1,2,4,8}`、3 种 tile size、10 次重复下 canonical digest 100% 相同；
- 无关 edit 后 unchanged violations 的 ID 保持率 100%；ambiguous 不得被强制匹配；
- schema/deck/geometry fuzz 累计至少 10^7 executions，无 sanitizer finding、宿主退出或无界内存；
- fault suite 中 timeout/cancel/crash/CAS/cache/checkpoint/license 注入的伪 clean 和非法 certificate 均为 0；
- cooperative cancel p95 safe-point latency <= 250 ms，无法中断的 legacy kernel 必须在可杀 worker 隔离；
- 首个 benchmark 上 `dirty <= 0.1%` 的 F1 p50 wall time <= 同 build F3 的 25%，峰值 RSS <= F3 的 60%；未达性能目标不牺牲 scope；
- full F3 相比冻结 legacy baseline 的 raw family result 零未解释回归，性能回归 p50 <= 10%、peak RSS <= 15%；
- 已资格 Calibre family 在 held-out corpus 上 raw marker precision/recall 各 >= 99.5%，FATAL/short 漏报为 0，unmapped source/marker 数完整报告；
- 500 个 proposal e2e candidate 中，直接 mutation 为 0、actual touched 越界未拒绝为 0、不完整 Hub bundle commit 为 0；
- fresh-process replay 成功率 100%（声明 non-replayable legacy profile 除外），成功项 result digest 必须完全一致；
- 文档、schema、capability version、CMake target、CTest label、dashboard 和 owner runbook 同 PR 可定位。

性能数字是首版工程门禁，不是物理正确性假设；若硬件/benchmark protocol 变化，版本化 protocol 后重新基线，不事后修改已发布数据。Calibre 阈值只授予列出的 rule/PDK/corpus 资格，不产生“全 deck 等价”结论。

---

## 20. 开放风险、版本历史与自检

### 20.1 开放风险

| 风险 | 当前判断 | 关闭条件 |
|---|---|---|
| LEF parser 未覆盖 foundry deck | 高 | source conservation + exact unsupported entries + F4 mapping |
| legacy 32-bit geometry/全局 singleton | 高 | 64-bit adapter、worker isolation、snapshot digest proof |
| fixed cluster halo 造成漏报 | 高 | rule-derived scope + 10k differential zero mismatch |
| component/global rule 性能 | 中高 | 专用 component index；无证明前保持 full |
| violation continuity 多对多 | 中 | deterministic ambiguous output；不强求单匹配 |
| repair timing/route 副作用 | 高 | iRT/iECO/iSTA/iEval/Hub required bundle |
| Calibre rule-name/marker 聚合差异 | 高 | versioned mapping、raw/cluster 双口径、held-out gate |
| evidence retention/license 可用性 | 中 | UNVERIFIABLE 状态、重跑策略、禁止缓存伪命中 |

### 20.2 版本历史

| 版本 | 日期 | 变化 |
|---|---|---|
| ai1.0 | 2026-07 前 | 增量 scope、coverage、stable ID 和 repair proposal 概念草案 |
| ai1.1 | 2026-07-24 | 基于真实 iDRC/iRT/iECO/CMake/working-tree 审计，补齐 owner、FR/NFR/invariant、六能力、八类 schema、F0-F4、恢复/缓存、LLD、测试和量化 DoD |

### 20.3 文档自检

- [x] CURRENT、CURRENT-WT 与 TARGET 分离；没有把 working-tree coverage 当 exact deck coverage。
- [x] 明确“零 reported violations + incomplete coverage != clean”。
- [x] 覆盖 rule discovery/check_scope/explain/compare/propose_repair/validate 状态和 schema。
- [x] 覆盖 RuleContext、RuleManifest、CheckScope、ViolationId/Record、Coverage、RepairProposal、DRCResult、Evidence。
- [x] 覆盖 stable geometry/object/rule ID、unit/layer/net/purpose/severity 和 rerun continuity。
- [x] 覆盖 old/new dirty、rule halo、component/global/unknown、incremental/full qualification。
- [x] 覆盖 proposal-only、DRC/route/timing/frozen risk 及 iRT/iECO apply owner。
- [x] 覆盖 F0-F4、timeout/cancel/checkpoint/replay/cache 和 fail-closed errors。
- [x] 固定 iDB/Tech/Hub/iDRC/iRT/iECO/iEval/Runtime 的责任与调用顺序。
- [x] 给出真实 LLD/CMake/PR slices、九类测试、Calibre oracle 和量化 DoD。
- [x] Markdown fence 成对；topic 关键词齐全；最终 diff 只允许本文件。
