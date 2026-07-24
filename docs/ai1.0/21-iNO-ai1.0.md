<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 21 · iNO Agent 原生网表优化与扇出修复实施规格 · ai1.1

> 基线：本文件 ai1.0、`10-iDB-ai1.0.md`、`12-evaluation-ai1.0.md` 与 `51-53` 公共契约。
>
> 当前成熟度：`D0/DRAFT`。**CURRENT** iNO 是配置驱动、原地修改共享 iDB 的 max-fanout/fix-IO 工具；**TARGET** 是本文规划的 snapshot-bound、proposal-first、branch-only、可回滚、可验证的 Agent capability。除标为 CURRENT 的事实外，本文内容均不表示仓库已经实现。
>
> 首个产品切片：post-place/post-CTS 的 data-net fanout/capacitance/transition 修复。clock tree、reset 专用树、跨电压域、任意逻辑综合和 signoff ECO 不在首版自动提交范围。
---
## 0. 结论、目标与唯一责任
### 0.1 目标
iNO 必须从“一次命令直接插 buffer”变成 Agent 可组合的 net optimization 服务：

```text
inspect immutable snapshot
  -> diagnose violations and evidence
  -> propose deterministic portfolio without writes
  -> Runtime forks isolated candidate branches
  -> materialize typed reversible delta under scope lease
  -> local legalize + RC/STA/evaluation
  -> Verification Hub issues scoped certificates
  -> Runtime selects/rejects; only Runtime may commit
```

首版交付必须做到：

- 同时区分 fanout、capacitance、transition 违例及约束来源，不把缺约束当 clean；
- 生成 direct split、balanced、physical-clustered 等多类候选，并显式报告不可行负载；
- 以 stable ObjectRef、固定 context 和确定性 tie-break 描述 driver/net/load，不跨边界传裸指针；
- proposal 不写设计；apply 只写 Runtime 提供的 branch，并产生 before/after/inverse/dirty/invalidation；
- buffer tree、driver clone、reconnect、resize 复用共同 NetlistDelta codec，不复制 iTO/iDB mutation kernel；
- 用 F0-F4、anytime checkpoint 和预算驱动筛选，不用低精度结果签 correctness certificate；
- connectivity、frozen scope、legal、DRV、setup/hold 等证书不完整时没有 commit 路径。

### 0.2 非目标
- 不进行 Boolean restructuring、gate decomposition、retiming、逻辑重综合或任意 Verilog 重写；
- 不自动修改 SDC、clock period、exceptions、dont-touch/dont-use、UPF 或 TechContext；
- 不替代 iCTS 构造 clock tree，不把普通 data-buffer 算法用于 clock/reset/power special net；
- 不在 iNO 内平行实现 legalizer、STA、RC extraction、DRC、power 或 congestion kernel；
- 不承诺 F0/F1 代理结果等价于 routed/signoff 结果；
- 不允许 Tcl/Python legacy 命令成为 Agent R2/R3 提交接口；
- 首版不自动 merge 两个 netlist ECO branch，不以“最后写入者获胜”处理冲突。

### 0.3 Owner 边界
| 模块 | 唯一负责 | 明确不负责 |
|---|---|---|
| iNO（本文） | net/fanout 诊断、负载分组、拓扑/master/location-window proposal、iNO 领域 payload、legacy fallback 适配 | branch/commit、稳定 ID 真值、STA/合法性证书 |
| iDB（10） | SnapshotRef/ObjectRef、TypedDelta 公共 envelope、apply/inverse、DirtySet、状态完整性 | 候选算法与 QoR 排名 |
| iEval（12） | metric、F0-F4 比较、Pareto、校准、QoR gate/evidence | 网表写入、correctness certificate |
| iPL（22） | placement 可行性、local legalization、actual moved scope、legal checker | 选择 fanout topology |
| iTO（25） | timing-path/DRV ECO 策略、resize/VT/buffer/clone 的 timing owner | iNO fanout portfolio；绕过共同 delta codec |
| iSTA（27） | timing/DRV 真值、dirty cone、incremental/full qualification | 修改网表、选择候选 |
| Runtime（43） | branch、budget、lease、cancel、selection、commit CAS | EDA 物理判断 |
| Intent（48） | immutable constraints/scenarios/protection truth | 普通优化流修改约束 |
| Verification Hub（49） | required claim planning、certificate、coverage、失效 | QoR 排名或领域计算 |
| Technology（55） | cell family、dont_use、PVT/RC、capability qualification | iNO 私自按名称猜 buffer/clone/resize 合法性 |

**动作 ownership 规则**：iNO 和 iTO 可以提出相同底层 action class，但 action schema、materializer 和 inverse 只有一个公共实现。两者对同一 net/driver 的候选必须竞争相同 lease；不得各自修改后拼接结果。
---
## 1. CURRENT 源码事实审计
### 1.1 iNO 资产表
| 路径 | CURRENT 能力 | 可复用定位 | 关键缺口 |
|---|---|---|---|
| `src/operation/iNO/api/NoApi.{hpp,cpp}` | singleton facade；init、fixFanout/fixIO、saveDef、timing summary | legacy adapter 后端 | 无 request/result schema、snapshot、branch、错误状态；生命周期是裸指针 |
| `src/operation/iNO/source/iNO.{h,cpp}` | 解析配置并调用 `FixFanout` | legacy execution wrapper | 每次执行直接 mutation；无 proposal/transaction |
| `src/operation/iNO/source/module/fix_fanout/FixFanout.{h,cpp}` | 遍历 STA nets；跳过 clock；超固定 max fanout 时插固定 buffer 并搬移 loads；fixIO | baseline 与 differential oracle | 仅 fanout count；容器顺序分组；无 cap/slew、dont_touch/domain、placement、rollback、增量 STA |
| `src/operation/iNO/source/io/DbInterface.{h,cpp}` | 持有 iDB/iSTA/config/reporter；保存优化前 WNS/TNS | legacy session adapter | process singleton；不绑定 immutable context；并发/重复初始化不隔离 |
| `src/operation/iNO/source/config/{NoConfig.h,Config.json}`、`source/io/JsonParser.{h,cpp}` | LEF/DEF/SDC/Lib、`insert_buffer`、`max_fanout` | legacy config compatibility | Agent 不能把任意路径/master 字符串当可信 TechContext；缺值可能 assert/空 master |
| `src/operation/iNO/source/io/Reporter.{h,cpp}` | 文本时间与计数报告 | 人工 debug | 不是 typed evidence；无 coverage/provenance |
| `src/operation/iNO/test/run_no.cpp` | 命令式 smoke runner | legacy regression | 无断言型 contract/delta/fault tests |
| `src/operation/iNO/CMakeLists.txt`、`api/CMakeLists.txt`、`source/{,io/,module/}CMakeLists.txt` 与 `external_libs/` | `ino_api/ino_source/ino_module/ino_io` 构建/链接图 | 新 adapter 并行接线基础 | 当前无 `agent` target |
| `src/operation/iNO/README.md`、`scripts/design/*/script/iNO_script/` | fanout 用法和多工艺 Tcl 示例 | compatibility fixtures | 文档接口仍是单次 config 命令 |
| `src/platform/tool_manager/tool_api/ino_io/ino_io.{h,cpp}`、`src/platform/tool_manager/tool_manager.{h,cpp}` | flow facade；设置 stage、初始化 iNO 并无条件返回 bool | legacy facade/shadow consumer | 无 typed failure、branch 或 verification |
| `src/interface/tcl/tcl_ino/{tcl_ino.cpp,tcl_register_no.h,tcl_noconfig.cpp}` | 注册 fanout、IO 和 config Tcl 命令 | legacy CLI compatibility | 接受路径配置，输出文本成功消息 |
| `src/interface/python/py_ino/{py_ino.cpp,py_register_ino.h}` | 注册 fanout Python binding | legacy Python compatibility | 当前无 fixIO binding、typed result |

### 1.2 真实外部入口
```text
Tcl run_no_fixfanout -config <json>
  src/interface/tcl/tcl_ino/tcl_ino.cpp
    -> ToolManager::RunNOFixFanout
       src/platform/tool_manager/tool_manager.cpp
    -> NoIO::runNOFixFanout
       src/platform/tool_manager/tool_api/ino_io/ino_io.cpp
    -> NoApi::initNO / iNODataInit / fixFanout
    -> iNO::fixFanout
    -> FixFanout::fixFanout              # writes shared IdbDesign directly

Python run_no_fixfanout(config)
  src/interface/python/py_ino/py_ino.cpp
    -> the same ToolManager path
```

Tcl 同时注册 `run_no_fixIO`，但 Python 当前只注册 fanout。`NoIO::runNOFixFanout/runNOFixIO` 在完成调用后直接返回 `true`，没有把 partial、unsupported 或内部 mutation failure 结构化上报。现有设计脚本位于 `scripts/design/*/script/iNO_script/run_iNO_fix_fanout.tcl`。

### 1.3 CURRENT 算法与副作用
`FixFanout::fixFanout()` 从 iSTA netlist 读取 fanout 数、用 `TimingIDBAdapter::staToDb` 找到 iDB net；clock net 被标记为 iDB clock 并跳过。若 `fanout > _max_fanout`，循环创建一个 net 和一个未放置 buffer，每轮按 `IdbNet::get_load_pins()` 当前顺序搬最多 `_max_fanout` 个 loads。结果接近 root 下多个一级 buffer 的直接分裂，不是经过优化的 balanced/clustered tree。

当前实现还具有以下必须被回归测试锁定、而不能被文档美化的事实：

- `_max_fanout` 与唯一 `insert_buffer` 来自 JSON，不读取 iSTA 每个 driver/liberty 的实际优先级限制；
- 只检查 fanout；没有调用 iSTA `validateCapacitance/validateSlew`；
- 除 clock 外没有结构化过滤 reset、dont_touch、dont_use、multi-driver、tri-state、power domain crossing；
- 新 instance 以 `kNone` placement status、坐标 `(0,0)` 创建，不调用 iPL legalizer；
- 直接调用 `IdbDesign::createOrFindNet/createInstance/connectPinToNet/disconnectPinFromNet/renameNet`；操作序列不是原子 delta；
- 失败时可能已创建前序 net/buffer/reconnect；没有完整 inverse、checkpoint 或 semantic digest rollback；
- 普通 NoIO 路径不在修复后执行 common incremental RC/STA；`outputSummary()` 的 full timing rebuild 也不在正常 fixFanout 调用链中；
- IO net 为保留端口语义存在 net-name swap；目标实现必须用 stable ID/alias policy 显式表达，不能靠名字推断对象身份；
- load 输入顺序变化可能改变 partition，当前结果不保证线程/容器顺序确定性。

### 1.4 可复用跨模块入口及限制
| 资产 | CURRENT 事实 | TARGET 用法 |
|---|---|---|
| `src/database/data/design/IdbDesign.{h,cpp}` | 已有 safer create/place/replace/remove/connect/disconnect/rename/validateConnectivity 方法 | 由 iDB TypedDelta codec 包装；iNO 不直接散调 setter |
| `src/platform/design_state/{DesignState,MoveTxn,DirtySet}.*` | 当前工作树已有单设计 transaction、undo action、version/dirty/canonical hash 基础 | 过渡期底座；尚不是多 branch SnapshotRef/TypedDelta catalog，不得宣称目标事务已完成 |
| `src/operation/iSTA/api/TimingEngine.{hh,cc}` | fanout、slew、capacitance 查询/validate 与 updateTiming 接口存在 | common TimingService adapter 的 legacy sensor；消费 receipt 绑定 context |
| `src/operation/iSTA/source/module/sta/StaIncremental.*` | 已有增量传播队列基础 | 经 27 qualification 后用于 F2/F3；未对拍前不可签完整 timing claim |
| `src/operation/iPL/api/PLAPI.{hh,cc}` | `runLG/runIncrLG(inst list)` 存在 | `place.legalize_local` adapter；实际 touched 超 scope 则拒绝 |
| `src/operation/iTO/source/module/fix_{drv,setup,hold}` | 已有 insert buffer、repower、fanout split 与 RC/timing 更新路径 | 抽取公共 ECO primitive 或 differential baseline；不能由 iNO 私有复制 |

结论：CURRENT 提供了可运行 kernel 和若干 safer setters，但没有目标 Agent contract。迁移必须 adapter-first、shadow dual-run，不能把 legacy `bool` 包一层 JSON 就标成 R2。
---
## 2. 首版范围与需求
### 2.1 支持矩阵
| 对象/动作 | 首版 | 条件 |
|---|---:|---|
| 单 driver、普通 data net | 支持 | stable refs、完整 intent/tech/scenario、post-place/post-CTS |
| fanout/cap/slew diagnosis | 支持 | iSTA 对应 check 有 coverage；缺限制为 UNKNOWN |
| insert buffer / tree / reconnect | 支持 | buffer family qualified、local legal 可用 |
| resize driver | 条件支持 | exact/conditional-equivalent family、pin map、iTO/common codec qualified |
| clone combinational driver | 条件支持 | pure combinational、单目标 output、formal/function mapping、输入域合法 |
| IO buffer | proposal-only 起步 | 明确 input/output direction、IO constraint 与 domain |
| clock/reset/power/special net | unsupported | 交给 iCTS/专用 reset/power flow |
| multi-driver/tri-state/inout bus | unsupported | 在有独立语义与验证资格前拒绝 |
| routed net 保线 topology edit | 默认 unsupported | 需 iRT rip-up/reroute scope 与 DRC/RC policy |

### 2.2 功能需求
| ID | 需求 | P | 验收 |
|---|---|---:|---|
| FR-NO-01 | `inspect` 返回 net/driver/load/topology/constraint/geometry 摘要 | P0 | 全部绑定 snapshot/context/scope/coverage |
| FR-NO-02 | `diagnose` 分离 fanout/cap/slew 与 UNKNOWN_LIMIT | P0 | 与 iSTA typed result 逐项对账 |
| FR-NO-03 | 输出 evidence-backed root cause 和受限对象原因 | P0 | skipped/unsupported 不计 clean |
| FR-NO-04 | deterministic proposal portfolio | P0 | load 顺序置换不改变 canonical proposal hash |
| FR-NO-05 | master、clone、resize 只来自 qualified TechContext mapping | P0 | 私有/default master 被拒绝 |
| FR-NO-06 | proposal 无设计副作用 | 红线 | 前后 semantic digest 相同 |
| FR-NO-07 | apply 仅在 branch + valid lease materialize TypedDelta | 红线 | committed head 零污染 |
| FR-NO-08 | 每个 action 有 scope/precondition/inverse/dirty/invalidation | P0 | apply->inverse semantic digest 恢复 |
| FR-NO-09 | 接入 iPL local legal 与 common iSTA dirty update | P0 | incremental/full 对拍在 qualification 容差内 |
| FR-NO-10 | verify 返回分项结果/coverage/artifact refs | P0 | 无裸 bool/文本 PASS |
| FR-NO-11 | F0-F4、AUTO、anytime incumbent/checkpoint | P1 | timeout/cancel 保留可审计 incumbent，绝不自动 apply |
| FR-NO-12 | partial/unsupported/infeasible/stale/conflict 可恢复 | P0 | 状态和 retry hint 可机器判定 |
| FR-NO-13 | iNO/iTO 相同 object lease 冲突 | P0 | 构造并发中恰有一个 materializer 获 lease |
| FR-NO-14 | iEval hard gate + Pareto，无隐藏总分 | P0 | 违例候选不能靠 area/WNS 加权抵消 |
| FR-NO-15 | legacy shadow/fallback 带完整限制与 provenance | P1 | fallback 不升级 correctness fidelity |
| FR-NO-16 | IO fix 进入独立 capability 和 schema | P1 | direction/name/domain 用例覆盖 |

### 2.3 非功能需求
| ID | 要求 |
|---|---|
| NFR-NO-01 | 所有读写接受 resolved immutable refs；禁止读取隐式 current design/current SDC/current library。 |
| NFR-NO-02 | 同一 request/snapshot/tool/schema/seed/thread profile 产生 canonical-equivalent 结果；并行 reduction 固定顺序。 |
| NFR-NO-03 | ObjectRef 包含 kind/id/generation；名字只作 display alias，不用于 stale 后重新定位。 |
| NFR-NO-04 | 单位使用公共 typed units；DBU、fF/pF、ns/ps 不以裸 double 跨边界。 |
| NFR-NO-05 | actual touched/dirty 只能比声明保守扩大；越 declared scope 必须原子失败。 |
| NFR-NO-06 | CANCELLED/FAILED 后无孤儿 cell/net、未释放 lease、临时 artifact 或已修改 committed head。 |
| NFR-NO-07 | cache key 包含所有 context、scope、fidelity、tool/qualification/seed/tenant；缺项禁用缓存。 |
| NFR-NO-08 | PARTIAL/UNSUPPORTED/UNKNOWN 不能被 UI、Tcl 或 serializer 转为 SUCCESS/PASS/0 violations。 |
| NFR-NO-09 | schema major/minor 有 fixture、compatibility 与 migration report；未知 semantic field fail closed。 |
| NFR-NO-10 | benchmark 数字在 protocol 冻结后发布 median/MAD/CI；本文不杜撰绝对性能目标。 |
| NFR-NO-11 | tenant/license/retention 沿 input、proposal、delta、metric、certificate、log lineage 传播。 |
| NFR-NO-12 | legacy singleton 由单 worker/session 隔离；不允许多个 branch 并发共享 NoApi/DbInterface。 |
---
## 3. 目标架构与数据流
### 3.1 组件
```text
Agent / Planner
     |
     v
NetOptService (transport-neutral)
  RequestValidator / CapabilityPolicy
     |
     +--> NetInspector ----------> iDB Snapshot View
     +--> FanoutDiagnoser -------> Intent + iSTA + TechContext
     +--> CandidateGenerator
            LoadPartitioner / TopologyBuilder / MasterSelector / LocationHint
     |
     v
NetOptimizationProposal (immutable, no write)
     |
Runtime fork + budget + object/net/region lease
     v
NoDeltaMaterializer --> common NetlistDelta codec --> candidate branch
     |                         |
     |                         +--> iPL local legalize
     |                         +--> iSTA dirty RC/timing
     v
NoValidatorAdapter -> Verification Hub certificates
     |
iEval compare/gate -> Runtime select/reject/commit CAS
```

### 3.2 六个 capability
| Capability | 权限 | 副作用 | 结果 |
|---|---:|---|---|
| `netopt.inspect@1` | R0/R1 | 只读 cache/artifact | `NetObservation` |
| `netopt.diagnose_fanout@1` | R1 | 只读 | `FanoutDiagnosis` |
| `netopt.propose@1` | R1 | 只读，允许 proposal artifact | `NetOptimizationProposal[]` |
| `netopt.apply@1` | R2 | 仅 candidate branch | `TypedDelta` + candidate SnapshotRef |
| `netopt.verify@1` | R1/R2 | validator artifact | `NetOptVerificationResult`；证书由 49 签发 |
| `netopt.run_legacy_fallback@1` | R2/shadow | 隔离 branch worker | legacy delta capture；永不直接 commit |

`inspect -> diagnose -> propose -> apply -> verify` 是可组合阶段，不强制一个进程。组合 convenience workflow 只能由 Runtime DAG 定义，不能在 iNO 内隐藏 fork、commit 或 recovery。

### 3.3 数据流不变量
1. 请求进入时固定 snapshot/intent/scenario/tech/policy/capability qualification；阶段中不得换 latest。
2. diagnosis 引用 observation 和 iSTA evidence，不复制成无法失效的裸数字。
3. proposal 只引用 logical node IDs 和 master/location choices；永久 object ID/name 在 apply 时由 iDB 分配。
4. preflight 必须在任何 setter 前完成；不可预检项使用 branch checkpoint，不允许部分发布。
5. local legalize 若需移动 scope 外对象，返回 scope expansion proposal，不自动扩大权限。
6. validator subject 是冻结的 candidate snapshot；verify 过程中 head 变化即 STALE。
7. iNO 不调用 commit。Tcl legacy facade 也不能绕过 Runtime commit policy。
---
## 4. 公共调用与响应契约
### 4.1 `NetOptRequest`
公共字段引用 51/53 owner schema；本文只定义 namespaced payload。

```yaml
invocation_id: 0190...
capability: {name: netopt.propose, version: 1.0.0, qualification_ref: sha256:...}
actor: {tenant: acme, subject: agent-17, role: optimizer}
context: {snapshot_ref: sha256:base, intent_ref: sha256:intent,
          scenario_set_ref: sha256:mcmm, tech_context_ref: sha256:tech,
          policy_ref: sha256:policy}
scope_ref: cas:scope/net-objects
fidelity: {requested: AUTO, minimum: F0, maximum: F3}
control: {budget_ref: cas:budget/reservation, deadline: 2026-07-23T18:00:00+08:00, seed: 17}
payload:
  net_selector: {object_refs: [{kind: net, id: 42, generation: 3}]}
  violation_kinds: [fanout, capacitance, transition]
  topology_allowlist: [direct_split, balanced, physical_clustered]
  actions_and_budget: {allow: [insert_buffer, reconnect_loads, resize_driver], max_new_cells: 16, max_new_nets: 16}
```

Gateway 先验证 schema/auth；Runtime 验证 permission、budget、scope、branch/head 和 qualification；worker 只接收 resolved mounts/refs，payload 不允许任意文件路径、Tcl、shell 或未映射 master 名。

### 4.2 `StageResult<T>` 使用规则
```text
status = SUCCESS | PARTIAL | UNSUPPORTED | INFEASIBLE |
         TIMEOUT | CANCELLED | FAILED | STALE | CONFLICT
context_echo + completed_scope + remaining_scope + coverage
value_ref<T> / diagnostics[] / artifacts[] / provenance / resources
checkpoint_ref? / invalidation_events[]
```

| status | iNO 语义 | value 可否消费 |
|---|---|---|
| SUCCESS | 请求 scope 全部完成且 schema/coverage 合格 | 可按 capability/fidelity 用途消费 |
| PARTIAL | 部分 nets/loads/scenarios 完成 | 仅 completed_scope；不得声称全部 clean |
| UNSUPPORTED | net class、stage、tech 或 checker 无实现/资格 | 不重试同参数；可换专用工具 |
| INFEASIBLE | 支持该问题，但预算/scope/master/legal space 下无解 | 可扩 scope/budget 或换 action |
| TIMEOUT | 超 deadline；可能有 incumbent/checkpoint | incumbent 仅 proposal，除非其独立完整 apply/verify |
| CANCELLED | 在 cancel point 停止并清理 | 不产生可提交 branch head |
| FAILED | 内部/输入/adapter 错误 | 若 branch digest 变为未知则标 CORRUPTED_BRANCH |
| STALE | refs/generation/head/qualification 已变化 | 重新 inspect/diagnose，禁止按名字续跑 |
| CONFLICT | lease/head/CAS 冲突 | 保留 evidence；首版不自动 rebase/merge |

### 4.3 结构化错误码
`NO_UNKNOWN_LIMIT`、`NO_UNSUPPORTED_NET_CLASS`、`NO_PROTECTED_OBJECT`、`NO_TECH_MAPPING_MISSING`、`NO_LEGAL_MASTER_MISSING`、`NO_LEGAL_LOCATION_MISSING`、`NO_CHANGE_BUDGET_EXCEEDED`、`NO_SCOPE_EXPANSION_REQUIRED`、`NO_STALE_DIAGNOSIS`、`NO_LEASE_CONFLICT`、`NO_DELTA_PREFLIGHT_FAILED`、`NO_ROLLBACK_FAILED`、`NO_INCREMENTAL_MISMATCH`、`NO_VALIDATION_INCOMPLETE`。

diagnostic 至少含 category、retryable、affected ObjectRefs、evidence refs 和建议的有限恢复动作；人类 message 不参与控制流。
---
## 5. iNO 领域 schema
### 5.1 `NetObservation`
```yaml
observation_id: sha256:...
subject: {net_ref: ..., driver_pin_ref: ..., driver_inst_ref: ...}
net_class: data
topology: {driver_count: 1, load_count: 73, current_depth: 0, routed_state: unrouted}
loads:
  - {pin_ref: ..., inst_ref: ..., location: {x: 1200, y: 450, unit: dbu},
     pin_cap: {value: 1.7, unit: fF}, criticality_ref: metric:..., region_ref: ..., power_domain_ref: ...}
constraints:
  fanout: {state: RESOLVED, limit: 30, source_intent_ids: [...]}
  capacitance: {state: RESOLVED, limit: {value: 80, unit: fF}, source_tech_ids: [...]}
  transition: {state: PARTIAL, per_scenario: [...]}
protection: {dont_touch: false, frozen: false, domain_crossing: false}
coverage: {loads: 73/73, scenarios: 4/6, geometry: full, timing: partial}
```

criticality 是来自 iSTA/iEval 的有 provenance 特征，不是 iNO 自定义 slack 真值。location 缺失时 physical-clustered 可以 unsupported，但 balanced 候选仍可生成。

### 5.2 `FanoutDiagnosis`
```yaml
diagnosis_id: sha256:...
observation_ref: cas:...
subject: {net_ref: ..., driver_pin_ref: ...}
checks:
  - {kind: fanout, result: VIOLATED, measured: 73, limit: 30, margin: -43,
     unit: count, scenario_scope: all-applicable, constraint_sources: [...]}
  - {kind: capacitance, result: VIOLATED, rise_fall: [...]}
  - {kind: transition, result: UNKNOWN_LIMIT, missing_scenarios: [...]}
root_causes: [{kind: load_count_dominant, confidence: bounded, evidence_refs: [...]}]
risks: [critical_load_depth, hold_regression, placement_pressure]
editable_scope: {nets: [...], pins: [...], region_hints: [...]}
unsupported_loads: []
consumption_receipt: {intent_ids: [...], tech_ids: [...], scenarios_consumed: [...], defaults: []}
```

`PASS/VIOLATED/UNKNOWN_LIMIT/NOT_EVALUATED/UNSUPPORTED` 必须分离。一个 net 可同时违反三类 check；任何 UNKNOWN 不能被 fanout-only 修复掩盖。

### 5.3 `NetOptimizationProposal`
```yaml
proposal_id: sha256:canonical-payload
subject: {diagnosis_ref: cas:..., base_snapshot_ref: sha256:...}
strategy: physical_clustered
logical_nodes:
  - {node_id: n1, role: buffer, master_choices: [{tech_cell_ref: ..., rank_reason: drive_cap_area}],
     location_window: {region_ref: ..., bbox: [...], halo: ...}}
logical_edges:
  - {from: driver, to: n1}
  - {from: n1, assigned_load_refs: [...]}
actions:
  - {kind: insert_buffer, logical_node: n1, source_net_ref: ...}
  - {kind: reconnect_loads, load_refs: [...], destination_logical_net: e1}
predictions:
  {max_fanout: {value: 24, fidelity: F1, uncertainty: ...},
   max_cap: {value: 61, unit: fF, fidelity: F1, uncertainty: ...}, critical_depth: 1}
guards: {declared_scope_ref: cas:..., preconditions_ref: cas:..., change_budget: {...}}
required_validators: [state.integrity, connectivity, frozen, legal, drv, sta.setup, sta.hold]
unsupported_or_residual: []
```

proposal 内 logical names 只在 payload 中有效。它不能预先承诺实际 instance/net 名、最终合法坐标、实际 RC/STA 或 certificate PASS。

### 5.4 `NetOptVerificationResult`
```yaml
subject_snapshot_ref: sha256:candidate
delta_ref: cas:typed-delta
checks:
  - {claim: connectivity.incremental, result: PASS, scope_ref: ..., coverage: ..., artifact_ref: ...}
  - {claim: placement.legal.incremental, result: PASS, scope_ref: ..., coverage: ..., artifact_ref: ...}
  - {claim: drv.fanout, result: PASS, scenarios: [...], coverage: ...}
  - {claim: drv.capacitance, result: PARTIAL, missing: [...]}
consumption_receipts: {intent: ..., tech: ..., timing: ...}
incremental_full_audit: {selected: true, comparison_ref: ...}
```

iNO validator adapter 产出领域结果；只有 49 的 qualified issuer 可以把它规范化并签成 `ValidationCertificate`。
---
## 6. Typed Delta 与动作语义
### 6.1 Delta envelope
```yaml
delta_id: sha256:canonical-ops
schema: netlist_delta.no/1.0
subject: {proposal_ref: cas:..., base_snapshot_ref: sha256:..., branch_ref: branch:..., lease_ref: lease:...}
declared_scope_ref: cas:...
preconditions: {object_generations: [...], topology_digest: sha256:...,
                protected_digest: sha256:..., branch_head: sha256:...}
ops: [...]
recovery: {before_image_ref: cas:..., inverse_ops: [...]}
actual_touched: {objects: [...], regions: [...]}
dirty_set: {nets: [...], pins: [...], instances: [...], regions: [...], scenarios: [...]}
invalidation_set: {metrics: [...], claims: [...], features: [...]}
result: {postconditions: [...], materializer_receipt: {build: ..., tech_ids: [...], generated_ids: [...]}}
```

op 顺序 canonical 且有依赖 DAG；inverse 按已成功 op 的逆拓扑顺序执行。apply 返回的 actual fields 由 materializer 测得，不能沿用 proposal 预测。

### 6.2 动作矩阵
| Action | scope 与前置条件 | materialize | inverse | 最小 dirty / invalidation |
|---|---|---|---|---|
| `InsertBuffer` | source net、driver、选定 loads、location window；single-driver data net；qualified buffer/pins/domain；head/topology generation 匹配 | create instance + child net；connect buffer input/output；不在此步宣称 legal | reconnect loads/source；disconnect/remove instance；remove empty child net；恢复 alias | netlist/connectivity；原/新 net RC；上下游 timing cone；placement region；area/power/congestion；DRV/legal/frozen cert |
| `BuildBufferTree` | composite declared tree、所有 loads、cell/area/depth budget | 展开为有 DAG 的 InsertBuffer/CreateNet/Reconnect；逐层 parent-before-child | reverse full op DAG；任何 child 失败回滚 whole composite | union of all nodes/edges；不能只 dirty root net |
| `ReconnectLoads` | 精确 load pin refs、from/to nets、expected driver/domain；pins 未 frozen | disconnect from old + connect to new atomically | reconnect each pin to recorded old net | 两侧 net/pins/drivers、RC、timing downstream、connectivity/frozen |
| `CloneDriver` | combinational exact function、单目标 output、input mapping、same domain/site；禁 sequential/macro/tri-state/multi-output 默认路径 | create clone；连接其 inputs 到相同 source nets；创建 output net；reconnect load partition | loads 回原 net；remove clone output net/instance；输入关系恢复 | clone/input/output nets、logic equivalence、timing cones、placement、area/power/congestion/DRV |
| `ResizeDriver` | exact/qualified family equivalence、pin/function/PG mapping、site/height/domain compatible、original master generation | common ReplaceMaster codec；保持连接；location window 交 iPL | replace original master + pin mapping/before geometry | instance/all pins/connected nets、RC/timing、legal、area/power、equivalence/frozen |
| `InsertIoBuffer` | IO pin direction、port constraint、original alias、domain 和 source/load side 明确 | 独立 input/output schema 创建 buffer/net 并连接 | 恢复 IO pin 原 net/alias，删除创建对象 | IO timing、connectivity、net alias、legal/domain、RC/STA；首版 proposal-only |

### 6.3 Preflight 和 postcondition
Preflight 必须机械验证：

1. base/branch head 与 proposal diagnosis 未 stale；
2. ObjectRef generation、driver/load membership 和 topology digest 一致；
3. declared object/region scope 被 actor、manifest、lease 同时允许；
4. protected/dont_touch/dont_use、clock/reset/domain/routed state 没有变化；
5. cell mapping、buffer ports、function、site、PVT/scenario qualification 完整；
6. name/ObjectId reservation 可用且 change budget 不超限；
7. inverse 所需 before image 已持久化并通过 hash 校验。

Postcondition 至少检查：单 driver 规则、load 不丢不重、buffer 输入输出方向、无 floating/orphan 新对象、expected object counts、actual touched 在 scope 内、semantic state 可序列化。任何失败先 rollback；rollback 自身失败则 branch `RECOVERY_REQUIRED/CORRUPTED_BRANCH`，永久禁止 commit。

### 6.4 Dirty 与失效闭包
```text
topology edit
  -> connectivity + stable object relations
  -> RC of old/new/adjacent nets
  -> slew/cap/fanout at changed drivers
  -> downstream setup/hold cones and path groups
  -> placement bins/rows around new/resized cells
  -> area/power/congestion maps
  -> frozen/intent/tech consumption receipts
  -> all dependent metric/cache/certificate/model features
```

无法精确证明 dirty cone 时保守 full invalidation；不得因 incremental 较快而猜小范围。route 已存在时 topology edit 默认失效相关 route/DRC/RC，并要求 iRT policy；不能保留旧 wire 后声称 routed clean。
---
## 7. 候选算法与确定性
### 7.1 约束优先级
每个 partition 节点必须满足所有已知 hard limit：

```text
fanout(children) <= resolved fanout limit
sum(pin_cap + estimated_wire_cap) <= resolved cap limit
predicted rise/fall slew <= resolved transition limit
tree cells/nets/area/depth/displacement <= request budget
protected/domain/site/routed constraints are never relaxed
```

若某 limit UNKNOWN，候选可用于 diagnosis/探索，但不能宣称对应 violation repaired；policy 可要求先升级 iSTA/Intent/Tech coverage。

### 7.2 Portfolio
| 策略 | 生成 | 适用与风险 |
|---|---|---|
| `direct_split` | root 下多个 buffer，按 capacity 分组 | legacy 可比、深度低；长线/聚类可能差 |
| `balanced` | 按 hard branching factor 构造最小/有界深度树 | 无几何时可用；物理线长可能差 |
| `physical_clustered` | stable location + cap/criticality 约束聚类，cluster 内再平衡 | post-place 首选候选之一；依赖 geometry/RC proxy |
| `criticality_aware` | 为关键 loads 保留浅路径，非关键 loads 聚类 | 可能增加面积/非关键深度；必须保护 hold |
| `clone_assisted` | 合格 driver clone + load partition，必要时子树 | 仅 qualified 逻辑；equivalence/输入布线成本高 |
| `resize_then_split` | 先枚举 driver resize，再减少/替换 buffer 层 | 与 iTO action 重叠；统一 lease/codec，不能双写 |

每类输出 seed 和 residual，不设一个隐式默认胜者。至少保留 no-op、legacy-equivalent 和两类结构不同候选用于比较。

### 7.3 Load partition 与 tie-break
1. 将 pin cap、location、domain、region、setup/hold criticality 规范化为 typed feature；missing 有独立 mask。
2. 先按不可跨越 domain/region/protection 分桶；桶自身不可满足时 INFEASIBLE/UNSUPPORTED。
3. capacity assignment 以 cap/fanout hard bound 为先，geometry/criticality 为次级 Pareto 特征。
4. cluster/assignment 平局依次使用 `(power_domain_id, region_id, x, y, stable_pin_id)`；禁止 pointer/address/container order。
5. master tie-break 用 `(family_rank, drive, area, leakage, tech_cell_id)`，实际 policy 权重显式记录。
6. canonical proposal hash 排除时间、worker ID、临时名称和物理 staging path。

关键 load 的“更靠近根”是 proposal 目标而非绝对规则；若 hold 风险、cap 或 legal 约束冲突，保留冲突证据，不能静默重排。
---
## 8. F0-F4、anytime 与回落
### 8.1 Fidelity
| F | 实际工作 | 用途 | 禁止声称 |
|---|---|---|---|
| F0 | 纯拓扑 fanout/cap 下界、buffer count/depth/area bound；不 apply | 大规模 prune、不可行早停 | legal、slew clean、timing improvement |
| F1 | placement geometry/HPWL/estimated wire cap、Liberty what-if、校准 uncertainty | topology/master/location rank | branch correctness 或 commit gate |
| F2 | branch apply、iPL local legal、estimated/incremental RC、early/common incremental STA | Top-K 验证与再排序 | full MCMM/signoff clean |
| F3 | qualified extraction/timing profile、required scenarios、incremental+抽样/full audit、完整 Timing ECO bundle | 首版 controlled commit 候选 | external signoff/tapeout |
| F4 | qualified external/full-route/signoff-style RC/STA/DRC 流 | 高风险发布辅助 | 自动 release；仍受 R5/人工策略 |

requested fidelity 是上限/目标，不是保证。实际 fidelity、降档原因、adapter/tool/qualification hash 和 uncertainty 必须返回。AUTO 依据风险、near-gate、OOD、预算和 calibration 逐级升级。

### 8.2 Anytime checkpoint
长候选生成每完成一种 topology 或稳定一批候选后发布 checkpoint：已处理 nets、剩余 nets、deterministic generator state、incumbent proposal refs、bound、已耗资源。checkpoint 只能在相同 refs/build/schema/seed 下 resume。

Cancel points 位于 net 之间、topology seed 之间、materialize 前、每个 composite action 原子边界、validator 之间。materialize 中 cancel 先 rollback 当前 delta，再返回 CANCELLED；不能把半棵树当 incumbent。

### 8.3 有界恢复阶梯
```text
F1 unavailable -> F0 + explicit uncertainty, proposal-only
physical geometry missing -> balanced/direct_split only
local legal infeasible -> request one scope expansion or reject
incremental STA mismatch -> one qualified full rerun; revoke suspect path on repeat
portfolio timeout -> return completed proposals + remaining scope
legacy fallback -> isolated branch + captured diff + full verification
dependency unavailable -> no lowering of correctness/commit policy
```

同一参数无限重试、静默使用 default buffer、跳过 scenario 或退回 current global DB 均被禁止。
---
## 9. 状态、事务、并发与 commit 边界
### 9.1 状态机
```text
NEW -> INSPECTED -> DIAGNOSED -> PROPOSED
                         |            |
                         |            -> STALE / UNSUPPORTED / INFEASIBLE
                         v
              BRANCH_RESERVED -> APPLYING -> APPLIED
                                      |          |
                               ROLLED_BACK   VALIDATING
                                                   |
                                  REJECTED <- READY_TO_SELECT
                                                   |
                                      Runtime: COMMITTED | CONFLICT | ABANDONED
```

任何状态绑定 exact snapshot/context/capability qualification。`READY_TO_SELECT` 不是 commit permission；candidate head 或 certificate bundle 变化立即 stale。

### 9.2 事务协议
```text
Runtime fork branch from immutable base
  -> reserve budget + acquire fenced net/driver/load/region lease
  -> iNO preflight + persist before image/inverse plan
  -> materialize ordered ops
  -> postcondition + semantic digest
  -> publish candidate SnapshotRef + TypedDelta atomically
  -> legalize/analyze/verify on frozen subject
```

首版 branch 内 writer 串行；不同 branch 可并行，但 legacy singleton worker 必须 process/session 隔离。lease key 至少覆盖 driver instance、source net、all moved load pins、location region；clone 还覆盖 input nets 的 read/write mode。fencing token 过期后旧 worker 的 publish 必须失败。

### 9.3 Commit 与证书
最小 Timing ECO policy bundle 建议包含：

- `state.integrity`、`connectivity.incremental/full-as-policy`；
- `frozen_objects.unchanged`、`intent.consumption_consistent`、`tech.consumption_consistent`；
- `placement.legal.incremental`，必要时 full legal；
- `drv.fanout`、`drv.capacitance`、`drv.transition` 对 required scenario/check coverage；
- `sta.setup` 与 `sta.hold`；post-CTS 还需 clock-aware policy；
- routed-stage 追加 route/DRC/RC affected-scope claims；
- iEval QoR gate/evidence：area/power/congestion/HPWL/WNS/TNS 等不越 policy。

F0/F1 metric、iNO 的 `success=true`、legacy report、单 scenario STA 都不能签上述 claim。Verification Hub 判断 completeness/currentness，iEval 判断 hard gate/Pareto，Runtime 最后复核 R3 权限、budget、base head、revocation 并 CAS commit；iNO 没有 commit API。
---
## 10. Metric、决策与可解释性
| 类别 | 指标 | 判定方式 |
|---|---|---|
| correctness hard | lost/duplicate loads、multi-driver、floating/orphan、scope violation | 任一非零拒绝 |
| DRV hard | fanout/cap/slew margin，unknown/unsupported coverage | required checks/scenarios 必须 certificate-complete |
| timing hard | setup/hold WNS/TNS/path regression budgets | policy gate，不可互相加权抵消 |
| physical hard | legal overlap/site/region/domain、route/DRC（适用时） | certificate gate |
| cost | new cells/nets、area、leakage/dynamic proxy、displacement、runtime/memory | 与 budget 比较 |
| QoR | tree depth、critical-load depth、wirelength/RC、congestion、WNS/TNS | hard gate 后做 Pareto |
| decision quality | Top-K recall、regret、false-prune、upgrade rate、calibration | held-out F3/F4 oracle 评估 |

不发布隐藏的 `score = a*WNS-b*area-c*power` 作为提交依据。若 policy 需要 tie-break，必须持久化 metric definition、normalization、priority 和 sensitivity；原始分量始终保留。

每次选择记录 considered/rejected proposals、拒绝阶段、hard-gate 原因、Pareto dominance、uncertainty、实际/预测偏差和最终证据 refs。Agent 可以解释“为何选”，不能用自然语言覆盖结构化 gate。
---
## 11. LLD 与迁移落点
### 11.1 新增路径和类
```text
src/operation/iNO/agent/
  CMakeLists.txt
  api/{NetOptService,NetOptCapabilities}.{hh,cc}
  schema/{NetObservation,FanoutDiagnosis,NetOptimizationProposal,NetOptVerificationResult}.hh
  inspect/{NetInspector,NetClassClassifier}.{hh,cc}
  diagnose/{FanoutDiagnoser,ConstraintResolverAdapter}.{hh,cc}
  propose/{CandidateGenerator,LoadPartitioner,TopologyBuilder,MasterSelector,LocationHintGenerator}.{hh,cc}
  apply/{NoDeltaMaterializer,NoLegacyDiffCapture}.{hh,cc}
  verify/NoValidatorAdapter.{hh,cc}
  legacy/LegacyFixFanoutAdapter.{hh,cc}
```

公共类型不落在 iNO：`InvocationContext/StageResult/Scope/TypedDelta/DirtySet` 位于 `src/contracts`（51/53 规划），branch/lease/commit 位于 `src/platform/agent_runtime`，stable state 位于 iDB/design-state，certificate 位于 verification。iNO schema 只拥有 namespaced domain payload。

### 11.2 类职责
| 类 | 输入 | 输出/纪律 |
|---|---|---|
| `NetOptService` | PreparedInvocation | 编排领域阶段，不持有全局 DB，不 commit |
| `NetInspector` | SnapshotView + Scope | stable typed slices、pagination/artifact；不返回裸 iDB/iSTA 指针 |
| `NetClassClassifier` | topology/intent/tech | data/clock/reset/special/multi-driver；fail closed |
| `ConstraintResolverAdapter` | 48/27/55 services | 限制值、precedence、source、UNKNOWN、receipt |
| `FanoutDiagnoser` | observation + timing evidence | 分 check diagnosis、root cause、coverage |
| `LoadPartitioner` | loads/hard capacity/seed | deterministic partitions + infeasible proof |
| `TopologyBuilder` | partitions/action budget | logical action DAG，不分配永久 ID |
| `MasterSelector` | TechContext + scenario set | qualified cell choices；无私有 default |
| `LocationHintGenerator` | placement view | windows/hints，不声称 legal |
| `NoDeltaMaterializer` | proposal + branch + lease | 调公共 codec，actual touched/dirty/inverse |
| `NoValidatorAdapter` | frozen candidate + delta | 领域 validator raw result，供 49 签发 |
| `LegacyFixFanoutAdapter` | isolated legacy session | shadow/fallback；capture actual diff 和 limitation |

### 11.3 依赖方向
```text
ino_agent_schema -> common contracts only
ino_agent_service -> schema + service interfaces
ino_agent_adapter -> iNO legacy kernel/iDB view/iSTA adapter
ino_agent_apply -> common NetlistDelta materializer interface
interface/agent -> NetOptService
Tcl/Python legacy -> compatibility facade, never reverse-linked into Agent service
```

Planner/Evaluation/Runtime 不链接 `NoApi` singleton；iNO 不链接 Verification issuer 或 Runtime concrete commit implementation。

### 11.4 迁移顺序
1. `NO-0` 冻结 CURRENT golden、actual call graph、config/summary/failure baseline。
2. 新增 schema/inspect/diagnose，只读 shadow，与 iSTA fanout/cap/slew report 对账。
3. 新增 deterministic partition/topology/master proposal；保证 semantic digest 零变化。
4. 先实现 Reconnect/InsertBuffer 公共 delta codec，再接 iNO materializer；不用 legacy setter sequence 作为正式 codec。
5. 接 iPL local legal 与 common iSTA dirty update；incremental/full shadow qualification。
6. 接 Verification/iEval/Runtime branch-and-select，写 capability 停在 R2。
7. legacy FixFanout 进入隔离 fallback/captured-diff；旧 Tcl 数值与脚本继续回归。
8. 只有 conformance/benchmark/evidence 通过后 Registry 将限定 profile 晋级 R3；不删除旧 API，先发布 deprecation receipt。
---
## 12. 跨文档契约矩阵
| 文档 | iNO 消费 | iNO 提供/必须遵守 | 集成门禁 |
|---|---|---|---|
| 10 iDB | Snapshot/ObjectRef、branch apply、TypedDelta、Dirty/Invalidation、semantic digest | actual touched、before/inverse、stable refs | apply/inverse/replay、scope escape、stale generation |
| 12 Evaluation | MetricRecord、compare、FidelityRouter、Gate/Evidence | prediction/actual refs 与 uncertainty | F1/F3 rank/regret、不可比 context 拒绝 |
| 22 iPL | movable/legal-space inspect、local legalize | new/resized cells、location windows、declared halo | incremental/full legal、actual moved/frozen |
| 25 iTO | shared ECO action/lease、timing strategy ownership | fanout diagnosis/proposal；不复制 action codec | 同 net conflict、cross-tool differential |
| 27 iSTA | typed fanout/cap/slew、criticality、dirty timing、full audit | exact topology delta/dirty cone/consumption receipt | per-scenario coverage、incremental/full disagreement |
| 43 Runtime | PreparedInvocation、branch/budget/lease/cancel/commit | checkpoints、bounded recovery、无 commit | head/lease/cancel/crash state machine |
| 48 Intent | constraints、scenario、protected objects/domain | consumed/skipped/defaulted intent IDs | intent drift/unknown/ordinary flow R4 deny |
| 49 Verification | claim policy、validator registry、issuer/invalidation | raw scoped validator results + delta refs | incomplete/stale certificate no commit |
| 55 Technology | buffer/equivalence/VT/site/PVT/RC mapping、qualification | consumed tech IDs/miss/default receipt | mapping/PVT/parser/tool drift invalidation |

若任一 owner schema 尚未实现，iNO 可完成 D0 schema/adapter shadow，但对应 R2/R3 capability 不得注册为 active。
---
## 13. 安全、权限与治理
| 操作 | 最低权限 | 约束 |
|---|---:|---|
| capability/metadata、已有 proposal 摘要 | R0 | tenant ACL/redaction |
| inspect/diagnose/propose/F0-F3 analyze | R1 | immutable refs、quota、无 design write |
| apply/local legal/fallback branch | R2 | branch-only、scope lease、sandbox、validators |
| selected candidate commit | R3 | 只由 Runtime；current bundle + CAS + audit |
| 修改 max fanout intent/dont_use/library mapping | R4 | 独立 Intent/Tech patch 与 domain-owner 审批 |
| F4 release/signoff | R5 | 外部证据、双审批；首版不自动发布 |

安全不变量：

- Agent payload 不能携带任意 config path、DEF output path、Tcl、shell、network endpoint 或动态 library；
- worker 只挂载 resolved read-only base/context 与自己的 writable branch/artifact staging；
- buffer/master selector 只接受 TechObjectRef，不执行名称模糊匹配；
- proposal 文本、log、pin/net display names 按 tenant policy 脱敏；CAS/cache 同样检查 ACL；
- legacy adapter 固定 binary/config template/argv，在无网络、限 CPU/memory/time 的 worker 中运行；
- 每次调用记录 actor、tenant、capability/qualification、refs、scope、budget、seed、resource、status、artifact hashes；
- invalid commit、scope escape、cross-tenant leak、rollback failure 会立即 suspend 对应 capability qualification并保留最小反例。
---
## 14. 测试、Benchmark 与可杀假说
### 14.1 分层测试
| 层 | 测试 | 必须断言 |
|---|---|---|
| Unit | limit precedence、load capacity、tree depth、master mapping、canonical hash | 边界/单位/UNKNOWN/确定性 |
| Schema | request/result/diagnosis/proposal/delta fixtures | major/minor、缺字段、unknown semantic、canonical serialization |
| Golden | 手算 0/1/limit/limit+1/100/1000 loads、IO direction、cluster geometry | diagnosis、partition、tree、residual、stable hash |
| Metamorphic | load/container/map 顺序置换、整体平移、单位等价换算、stable rename、线程数变化 | 语义等价输出；物理变化按预期 |
| Differential | legacy direct split、iTO buffer/DRV、common iSTA report、incremental/full | 差异分桶和原因；不以 majority 当 oracle |
| Property | 随机 legal delta apply/inverse、scope/dirty/invalidation closure | base digest 恢复；actual scope 不越界；失效不漏 |
| Fault | 每个 op 前后、artifact/CAS、legalizer/STA crash、cancel、lease expiry、worker kill | committed head 不变、无 orphan、branch disposition 明确 |
| Integration | inspect->diagnose->propose->branch apply->legal->STA->verify->gate | context/refs/coverage 一致；incomplete 无 commit |
| Security | path/Tcl/master injection、R1 apply、R2 main write、cross-tenant cache、expired qualification | 全部 fail closed 并有 audit |

### 14.2 核心用例
`NO-T01` fanout 0/1/limit/limit+1/1000；`NO-T02` cap/slew rise/fall/scenario/UNKNOWN；`NO-T03` direct/balanced/clustered 手算；`NO-T04` input permutation/thread determinism；`NO-T05` clock/reset/dont_touch/multi-driver/domain；`NO-T06` master missing/dont_use/PVT mismatch；`NO-T07` each action apply/inverse；`NO-T08` 第 k 个 reconnect/create/capture fault；`NO-T09` local legal infeasible/scope expansion；`NO-T10` incremental/full RC/STA；`NO-T11` iNO/iTO lease race；`NO-T12` timeout/cancel/checkpoint/resume；`NO-T13` legacy diff capture；`NO-T14` certificate incomplete/stale；`NO-T15` intent/tech/tool drift；`NO-T16` two-tenant/path/command isolation。

### 14.3 Benchmark protocol
数据集分三层：合成可证明网络；公开/可分发 small designs；内部设计族的 tenant/PDK/family held-out。按 fanout、physical span、criticality、stage、library/PDK、congestion、domain 分桶。训练/调参设计族不得进入最终 held-out；每个 case 固定 source/context/tool/schema/seed/protocol hashes。

基线至少包括 no-op、CURRENT legacy FixFanout、balanced deterministic、physical-clustered、iTO 相关 buffer/DRV flow。oracle 是预算内枚举候选的 qualified F3，F4 仅在可用且许可允许时作为外部参考。

报告：DRV clean/unknown/unsupported、connectivity/legal invalid rate、setup/hold regression、buffer/net/area/wire/power/congestion delta、Top-K recall/regret/false-prune、incremental/full disagreement、runtime/memory/cancel saving/cache hit，以及按桶的 median/MAD/bootstrap CI。只报总平均值不构成发布证据。

### 14.4 可杀假说
| ID | 假说 | 实验与否证条件 | 否证后的动作 |
|---|---|---|---|
| H-NO-01 | physical-clustered 在同等 hard-clean 下比 legacy direct split 改善 load delay/wire trade-off | held-out 分桶 paired F3；收益 CI 不优于 0 或 setup/hold 退化抵消则否证 | 不设默认；只在获益桶发布或移除策略 |
| H-NO-02 | F0/F1 portfolio 能保留接近 F3 最优的 Top-K 并节省验证成本 | 测 Top-K recall/regret 与 F3 调用成本；无显著优于 deterministic baseline 则否证 | 简化 router，扩大 F2 或停用模型 |
| H-NO-03 | iSTA dirty update 足以支持大部分 iNO 候选 F2/F3 | 持续 incremental/full audit；超 27 qualification tolerance 的分桶重复出现则否证 | 扩 dirty closure/full fallback，撤销该 qualification |
| H-NO-04 | proposal/apply 分离能消除 silent partial 且成本可接受 | fault corpus 与 legacy 对比；仍有 head 污染或事务开销超过节省并无并行收益则否证 | 先修 state/materializer，不晋级 R3 |
| H-NO-05 | clone/resize 扩展能改善纯 buffer 无解/高成本 cases | 只在 qualified cases 与 buffer-only paired；无 Pareto 增益或 equivalence/legal 风险过高则否证 | 保持 iTO-only 或 proposal-disabled |
---
## 15. 工作流、里程碑与 PR 切片
### 15.1 首个端到端工作流
```text
1. Runtime fixes post-place SnapshotRef + Intent/Scenario/Tech/Policy refs.
2. iSTA/Observer identifies candidate fanout/cap/slew nets.
3. iNO inspect/diagnose returns evidence and unsupported scope.
4. iNO generates no-op + direct + balanced + clustered proposal portfolio.
5. Runtime forks Top-K branches and acquires disjoint/fenced leases.
6. Common delta materializes candidate; iPL legalizes declared halo.
7. iSTA updates dirty RC/timing; iEval runs F2 compare and escalation.
8. Verification Hub plans/executes required claims on frozen F3 candidates.
9. iEval applies hard gates then Pareto; Runtime records decision.
10. Runtime commits one candidate by CAS or retains conflict branch; all others abandoned.
```

### 15.2 里程碑
| 阶段 | 周期 | 交付 | 退出门禁 |
|---|---:|---|---|
| NO-A0 | 2 周 | CURRENT golden、schema、inspect | legacy call/result/failure baseline 可重放；读无副作用 |
| NO-A1 | 3 周 | fanout/cap/slew diagnose + receipts | iSTA report 对账；UNKNOWN/partial 不丢 |
| NO-A2 | 3 周 | deterministic partitions/topology/master portfolio | golden/metamorphic 全过；proposal digest 零变化 |
| NO-A3 | 4 周 | InsertBuffer/Reconnect/Tree delta + inverse | 1000 随机 apply/rollback；fault 后零 main pollution |
| NO-A4 | 3 周 | local legal + dirty RC/STA + verify adapter | incremental/full qualification；scope expansion 可见 |
| NO-A5 | 3 周 | Runtime lease/cancel/iEval/49 bundle | iNO/iTO conflict 命中；incomplete 无 commit |
| NO-A6 | 4 周 | clone/resize/legacy fallback/held-out benchmark | 仅合格 profile active；evidence pack/replay 完成 |

周期是规划估算，依赖 10/27/43/49/55 的共同契约；依赖未就绪时阶段停在 shadow，不用本模块私有替代物绕过。

### 15.3 PR 顺序
```text
NO-0  CURRENT golden + capability/domain schema
NO-1  Snapshot-bound inspect + net classifier
NO-2  fanout/cap/slew diagnosis + Intent/Tech/iSTA receipts
NO-3  deterministic partition + topology/master/location proposals
NO-4  common Reconnect/InsertBuffer/BuildTree codec + inverse
NO-5  branch materializer + dirty/invalidation + fault injection
NO-6  iPL local legal + common iSTA incremental/full shadow
NO-7  validator/iEval/Runtime lease-cancel integration
NO-8  clone/resize qualified actions + iTO conflict differential
NO-9  isolated legacy fallback + benchmark + Registry qualification
```

每个 PR 必须链接需求 ID、schema/version、CURRENT consumer、test/benchmark case、scope/permission、failure injection、evidence artifact 和 rollback/deprecation plan。仅新增 facade、Tcl 参数或 `bool` 返回不算 Agent capability。
---
## 16. 完成定义、开放问题与版本历史
### 16.1 Production-eligible 完成定义
1. 文档和 registry 明确 CURRENT/TARGET、owner、stage/net class/fidelity/PDK qualification；
2. inspect/diagnose/propose 无 DB side effect，结果含 refs、units、coverage、receipts、structured status；
3. proposal deterministic、可 canonical replay，至少有 no-op/legacy-equivalent/两类结构候选；
4. 首批每种 action 均有 preflight、actual touched、inverse、dirty/invalidation、positive/negative/fault test；
5. apply 只能在 branch/fenced lease，任意 fail/cancel 后 committed head 不变；
6. iPL/iSTA/Intent/Tech 使用同一 context，incremental/full 差异满足各自 qualification；
7. 49 能从 delta 规划 required claims；缺一 scenario/check/object/artifact 时 bundle 不 complete；
8. 12 能重放 base/candidate metrics、hard gate、Pareto/升级/选择理由；
9. iNO/iTO 同 net 并发没有 lost update、双写或 silent merge；
10. golden/metamorphic/differential/property/fault/security/held-out benchmark 全部进入 CI/qualification evidence；
11. legacy Tcl/Python 数值/脚本回归已记录，fallback 限制可见，迁移/deprecation 不破坏现有 flow；
12. clean process 可由 refs 重放 selected candidate，源码/build/schema/context/policy/artifact hashes 完整。

达到上述条件只表示指定 profile 可进入 controlled R3，不表示 F4 signoff 或所有 net class 支持。

### 16.2 开放问题 / ADR
| ADR | 需实验决策 | 冻结前默认 |
|---|---|---|
| NO-ADR-01 | buffer tree logical IR 是 iNO namespaced 还是公共 ECO composite | iNO proposal IR，materialized ops 使用公共 codec |
| NO-ADR-02 | cap/slew precedence 与 liberty/default fanout_load 的精确跨源规则 | 完全服从 48/27/55 resolver；冲突为 UNKNOWN/FAILED |
| NO-ADR-03 | clone driver 的 formal/function qualification 最小证据 | 默认禁用，仅 qualified combinational profile |
| NO-ADR-04 | post-route topology edit 的 route ownership和 wire invalidation | 默认 unsupported，等待 iRT scope protocol |
| NO-ADR-05 | incremental STA full-audit 抽样率和 tolerance | 由 27 qualification/policy 配置，iNO 不私设 |
| NO-ADR-06 | local legal scope expansion 最大次数/halo | Runtime budget 控制，默认一次 proposal expansion，不自动执行 |
| NO-ADR-07 | IO net stable identity 与 DEF-visible name preservation | stable ObjectRef 为真值；name/alias 由 iDB policy 决定 |
| NO-ADR-08 | legacy singleton 是 process-per-call 还是 session pool | 首版 process/session 串行隔离，以基准选择 |

### 16.3 版本历史
- ai1.1（2026-07-23）：按 Evaluation 深度基线完成 CURRENT 源码/入口审计，补齐 owner/FR/NFR、Agent 六阶段能力、领域 schema、可逆 typed delta、F0-F4/anytime、事务并发、证书/commit、安全、LLD 迁移、全层测试/benchmark/可杀假说与完成定义。
- ai1.0（2026-07-23）：定义 fanout diagnosis、tree proposal、branch apply、基础 LLD、里程碑与测试方向。
