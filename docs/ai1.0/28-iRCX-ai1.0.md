<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 28 · iRCX Agent-Native 寄生提取服务可实施规格 · ai1.1

> 基线：`docs/ai/28-iRCX.md` 与当前 `src/operation/iRCX/`。本文是可直接拆分代码任务、接口评审、测试和验收的 ai1.1 TARGET 规格。
> 上游：iDB、iRT、Technology Knowledge、Scenario；下游：iSTA、iSI、iTO、iECO、Evaluation、Verification Hub。
> 商业参照：StarRC/StarRC xTRA；F4 只表示经协议接入的外部签核结果，不表示 iRCX 自身达到签核等价。
> 核心纪律：`CURRENT` 是已审计源码事实，`TARGET` 是待实现设计；两者不可混写。F0/F1 估算不得冒充 extracted/signoff RC；缺 route、tech 或 corner 时不得返回零寄生。

---

## 0. 目标、非目标与唯一责任

### 0.1 ai1.1 目标

iRCX ai1.1 的目标不是给既有全量命令套一层自然语言，而是把“路由几何到可消费寄生网络”的全过程变成可发现、可预算、可取消、可回放、可增量验证的 Agent capability：

1. 提供 `inspect / estimate / extract / update / compare / validate` 六类 typed capability；
2. 用 `ExtractionContext` 固定 snapshot、route generation、technology、corner、单位、模型和确定性环境；
3. 用 `TopologyArtifact` 与 `ParasiticGraph` 暴露可解释的 wire/via/ground/coupling 分量，而非只给 SPEF 路径；
4. 用 tile/net/halo dirty planning 和 coupling pair 唯一 ownership 实现保守正确的增量提取；
5. 用 `RcDelta` 原子发布增量结果和 inverse，供 iSTA/iSI 按 dirty seed 更新；
6. 用适用域、pattern coverage、uncertainty 和 calibration version 约束 F0-F4 fidelity；
7. 用 SPEF round-trip、full-vs-incremental、analytic golden、商业对拍和下游 timing/SI 联合门禁证明结果；
8. 让 timeout、cancel、partial、unsupported、worker crash 都有不可误解的状态和 evidence。

首个端到端目标是 post-route ECO：iRT 发布一个已提交 `RouteDelta`，iRCX 在 branch 上计算保守 dirty scope，重提 affected nets 与 coupling halo，原子发布 `RcDelta`，iSTA/iSI 消费同一寄生版本并返回更新后的 timing/SI 证据，全量重提作为抽检 oracle。

### 0.2 非目标

- 不把 placement HPWL、Steiner 估算或 layer-average RC 宣称为已提取寄生；
- 不在 iRCX 内复制 iRT 的 DRC/连通性修复职责；iRCX 可拒绝坏拓扑，但不擅自修改 route；
- 不由 iRCX 解释 setup/hold、噪声窗口或优化收益；这些属于 iSTA/iSI/iTO；
- 不以 SPEF 文件大小、单一 total C、单一 WNS 或全局相关系数替代分量/拓扑/覆盖率门禁；
- 不在 ai1.1 首版追求任意线段原地 patch；允许以 dirty tile 为最小重建单元；
- 不把 StarRC 输出直接写入 iRCX 主状态；外部结果是不可变 F4 artifact，经 importer 和 provenance 校验后比较；
- 不承诺未校准工艺、未支持 pattern 或超出 halo 证明范围的 signoff 精度；
- 不允许 legacy singleton worker 并发处理不同 session。

### 0.3 唯一责任与 owner 边界

| 对象/决策 | 唯一 owner | iRCX 的责任 |
|---|---|---|
| committed route geometry、route generation | iDB/iRT | 只读消费，校验 generation 与完整性 |
| technology/process stack、layer/via mapping | Technology Knowledge + iDB | 解析并冻结为 `TechRef`，报告缺失/不支持 |
| parasitic topology、R、ground C、coupling C | **iRCX** | 构建、验证、版本化、解释与发布 |
| coupling pair canonical ownership/index | **iRCX** | 保证唯一、不残留、不双计 |
| SPEF serialization/round-trip qualification | **iRCX** | 事务输出、解析回读、单位与名称对账 |
| timing graph/slack/dirty endpoint | iSTA | 消费 `ParasiticGraph/RcDelta`，不篡改提取值 |
| aggressor window/noise/delta-delay | iSI | 消费显式 coupling，不让 iRCX臆测活动窗口 |
| ECO action 与 route mutation | iTO/iECO/iRT | iRCX仅估算/提取候选 branch |
| 商业 reference 与接受阈值 | Verification Hub/flow owner | iRCX 生成可比较证据，不自行放宽阈值 |

### 0.4 术语和真值层级

| 术语 | 严格含义 |
|---|---|
| estimate | F0/F1 代理值；必须带模型、适用域和不确定度 |
| extract | F2/F3 基于已提交 route 与指定 tech/corner 的寄生提取 |
| signoff/reference | F4 外部工具或 field solver 按冻结协议产生的参考值 |
| full | 对请求中的完整 design scope 计算；不是“商业签核”同义词 |
| incremental | 对保守 dirty closure 重建并证明与 full 一致；不是降低 fidelity |
| partial | 预算/超时/unsupported 导致 scope 未完成；不得发布为 current RC |
| stale | 结果所依赖 generation 已不是当前 generation；数值即使可读也不可提交 |

---

## 1. CURRENT：真实源码、配置、SPEF、测试与消费审计

### 1.1 公共入口与生命周期（CURRENT）

当前公共 C++ 面只有 `RCXAPI::init(config_file)`、`run()`、`report()`、`compare_spef()`、`dump_net_shape()` 和 `plot_spef()`（`src/operation/iRCX/api/RCXAPI.hh`）。Tcl 注册 `init_rcx / run_rcx / report_rcx / compare_spef / dump_net_shape / plot_spef`。

真实全量流程为：

```text
init_rcx(config)
  -> RCXData.reset
  -> Setup::initialize

run_rcx
  -> Setup::adaptDB
  -> omp_set_num_threads
  -> buildTopology
  -> buildEnvironment
  -> buildProcessVariation
  -> calculateParasitics(R then C)

report_rcx
  -> Report::dumpSpef
  -> one SPEF per configured corner/temperature
```

`Extraction::buildTopology()` 在 `Extraction.cc:50` 调用 `topo_pool.clear()`，`calculateParasitics()` 在 `Extraction.cc:132` 重建整张 `RCTable`。因此 CURRENT 是进程内 singleton 驱动的全量流程，不存在 session、scope extraction、dirty planner、transactional publish、cancel 或 checkpoint。

### 1.2 配置与工艺输入（CURRENT）

`RCXConfig` 当前解析：

| 字段 | 当前语义 | 审计结论 |
|---|---|---|
| `thread_num` | 必填整数，非正数钳到 1 | 进程全局 OpenMP 设置，不是每 session budget |
| `mapping_file` | 必填，按 config 目录解析绝对路径 | design layer 到 process layer 映射 |
| `corners[]` | `name`、可选 `temperature[]`、必填 `itf_file/captab_file` | 多 corner/temperature 输入存在 |
| `output` | SPEF 输出目录，缺省 `.` | 无事务 staging/manifest |
| `report_geometry` | 可选布尔值 | 仅影响扩展注释/几何报告 |

ITF、captab 与 mapping parser 已分模块构建；corner 数据进入 `RCXData::CornerData`。但 CURRENT config 没有 snapshot、route stage、scope、fidelity、coupling policy、timeout、memory、seed、cache、calibration 或 external worker 配置。

### 1.3 2.5D extraction kernel（CURRENT）

| kernel | 已实现事实 | ai1.1 不得误述的缺口 |
|---|---|---|
| `IdbAdapter` | 从 iDB 适配 design、routing layers、regular/special nets、wire/via/pin | 不是 immutable route artifact；没有 generation/hash |
| `TopologyBuilder` | regular/special net 几何构建 `TopoPool` node/edge/via | 只支持全量 builder；stable node ID 未跨重建保证 |
| `Environment` | track/pixel 空间索引，侧邻与上下层 overlap，special net 参与环境 | 搜索 track 数当前为固定值 10；没有可证明 halo manifest |
| `ProcessVariation` | 构建每 corner/net etch profile | PBTV 多项式实际应用仍被注释，厚度回到 nominal |
| `ResistanceCalc` | wire 与 via R，按 corner/net/edge 写 `RCTable` | 缺 typed provenance 与局部重算接口 |
| `CapacitanceCalc` | 基础侧邻/跨层 pattern 查询，ground/coupling 累积 | `CapacitanceCalc.cc:185-187` 直接跳过 via C |
| `EdgeCapAccumulator` | 双侧、单侧、无侧邻；special coupling 折 ground；跨网 coupling 写 entry | 没有 multi-neighbor/via C/shield 专用模型和唯一 owner registry |

CURRENT 可称为“有可运行的 2.5D 全量提取骨架”，不能称为“已达到 StarRC signoff”或“已有增量提取”。

### 1.4 数据、单位与 SPEF（CURRENT）

`RCXData` 持有 layout、layer table、topology、net environment、corner etch profile、RC table 和 SPEF context。`SpefDumper` 由这些裸引用组装输出；不存在不可变 `ParasiticGraph` 或版本化 result store。

SPEF CURRENT 事实：

- header 固定 `*C_UNIT 1.0 FF`、`*R_UNIT 1.0 OHM`、`*T_UNIT 1.0 NS`；
- `*NAME_MAP` 分别为 port、instance、net 生成编号；
- coupling 以 SPEF `*CAP` 三节点行写出，不存在必须使用字面 `*CC` 的要求；
- wire ground C 均分到边两端，via edge 不产生 ground C；
- coupling edge pair 选择 Manhattan 最近端点作为 node pair 后聚合；
- `*D_NET` total C 是 ground C 与当前 net view 中 coupling C 的和；
- `*RES` 写 topology edge，包括 wire/via R；
- `report_geometry` 通过注释携带 layer/geometry 扩展，不属于 portable 核心语义。

独立 `compare_spef` reader 会展开 name map，把电容归一到 fF、电阻归一到 ohm，构建 net/node/pair 索引。它不等于主提取结果 importer，也不构成 iRCX SPEF round-trip transaction。

### 1.5 compare/report/test（CURRENT）

`compare_spef` 已支持 test/reference、net/pin 过滤、total/ground/coupling C、p2p resistance、timeout、并行核数、CSV/JSON 等参数。机器可读 `compare.json` schema 已报告双侧 coverage、统计量和 joint gate，且显式把未分解 wire/via R、critical slack 未比较、无冻结阈值列为 blocking reason。

当前仓内可见的专用自动测试主要是 `source/tool/compare_spef/tests/CompareJsonTest.cc`，覆盖 compare JSON 的 coverage、空样本非零伪装和联合门禁。提取 kernel、SPEF round-trip、增量、parser fuzz、故障注入和商业对拍尚未形成系统 CI。

### 1.6 iRT、iSTA 与 iSI 消费（CURRENT）

| 链路 | CURRENT | TARGET 差距 |
|---|---|---|
| iRT/iDB -> iRCX | `run()` 时 `Setup::adaptDB()` 读取当前进程数据库 | 无 route artifact/generation/scope contract |
| iRCX -> iSTA | 通过文件 `report_rcx` 后 `read_spef`；iSTA Rust SPEF reader 构建 RC tree | 无内存 `RcDelta`、无 CAS publish、无 dirty seed ACK |
| iRCX -> iSI | 没有独立 iSI 实现目录/typed coupling handoff | 需共享 coupling graph，不能通过 half-split 猜测 |
| iRCX -> iTO/iECO | 文件链或重新跑全量 | 无 candidate branch/session 和增量 update |
| iRCX -> commercial | compare/plot 可读外部 SPEF | 无冻结 StarRC run manifest/自动 qualification |

iSTA 能解析 SPEF coupling 不等于 iSI 闭环已验证。ai1.1 必须用单 coupling 扰动、node attach、dirty timing 与 noise/delta-delay 联合测试证明消费语义。

### 1.7 构建事实与成熟度矩阵（CURRENT -> TARGET）

`src/operation/iRCX/CMakeLists.txt` 构建 parser、database、topology、environment、process、calculate、report、tools、flow、SPEF parser 和 API 多个静态库。`ircx_compare_json_test` 为 `EXCLUDE_FROM_ALL`；当前没有 `ircx_agent`、schema、service、transaction、incremental 或 worker targets。

| 能力 | CURRENT | ai1.1 TARGET |
|---|---|---|
| 全量 2.5D extraction | 可运行 | 封装为 F3 backend，行为回归 |
| 局部 inspect | 无 typed API | net/segment/pair 可追溯分量 |
| early estimate | 无正式 contract | F0/F1 严格标记、可校准、可拒绝 |
| incremental | 无 | tile/net/halo closure + full 抽检 |
| coupling ownership | RC table entry/导出聚合 | canonical pair 唯一 owner + reverse index |
| session/state | singleton | 多 session 控制面，legacy worker 隔离 |
| structured result | bool + 文件/log | status/result/evidence typed envelope |
| cancellation/replay | 无 | cooperative cancel、manifest replay |
| commercial qualification | 手工 compare 基础 | 冻结 protocol + 分桶门禁 + timing/SI 联合 |

---

## 2. 功能需求、非功能需求与红线不变量

### 2.1 功能需求

| ID | 要求 | 可验收输出 |
|---|---|---|
| FR-01 | capability discovery | capability/version/fidelity/limits/backend manifest |
| FR-02 | inspect route/topology/environment/RC | component lineage、coverage、unsupported list |
| FR-03 | F0/F1 estimate | estimate label、domain、calibration、uncertainty |
| FR-04 | F2/F3 extract | immutable `ParasiticGraph` + result/evidence |
| FR-05 | route delta incremental update | conservative `ExtractionScope` + atomic `RcDelta` |
| FR-06 | compare arbitrary compatible results | per component/topology/layer/pattern/net/sink buckets |
| FR-07 | validate structural/numeric/round-trip/downstream | claims、violations、gate verdict |
| FR-08 | multi-corner/multi-temperature | one explicit result per scenario; no silent merge |
| FR-09 | cancellation/timeout/partial | completed/remaining scope + non-publishable status |
| FR-10 | deterministic replay | canonical request + input hashes + seed + backend build |
| FR-11 | worker isolation | crash/OOM/timeout 不污染 service state |
| FR-12 | SPEF import/export | transaction manifest、name/unit policy、round-trip evidence |

### 2.2 非功能需求

| ID | 纪律 |
|---|---|
| NFR-01 | 相同 canonical inputs、seed、backend build 和 thread policy 必须产生相同 stable IDs 与 canonical digest |
| NFR-02 | 每个数值携带明确 SI dimension；序列化边界不依赖隐式 fF/ohm/dbu |
| NFR-03 | read-only capability 不得改变 iDB、current RC、cache alias 或工作目录 |
| NFR-04 | publish 使用 CAS：`base_route_generation` 与 `base_rc_generation` 均匹配才可提交 |
| NFR-05 | cache hit 必须重新校验 snapshot/generation/tech/corner/model/route stage，不只按 net 名命中 |
| NFR-06 | unsupported、missing、empty、zero 四种语义分开；没有样本不是 0% error |
| NFR-07 | service 内存、CPU、wall time、worker 数、artifact bytes 均可预算和观测 |
| NFR-08 | partial/cancelled/timed_out 结果不得自动成为 iSTA/iSI current parasitic view |
| NFR-09 | 生产日志不得代替 schema；所有 hard gate 必须读取结构化字段 |
| NFR-10 | schema 向前兼容：新增 optional 字段可读，删除/改义必须升级 major |

### 2.3 红线不变量

1. `route_artifact_ref`、`tech_ref`、`corner_ref` 任一缺失，`extract/update` 必须失败；不得返回全零 `ParasiticGraph`。
2. F0/F1 的 `quality_class` 必须是 `ESTIMATED`，SPEF exporter 默认拒绝；只有显式 debug policy 可输出且 header/manifest 必须标 estimated。
3. 每个物理 coupling contribution 只有一个 canonical owner record；两个 net view 只能引用，不得各存一份可独立累加的真值。
4. `C_total_definition = C_ground + coupling_factor * sum(C_coupling)` 的 factor 必须显式；compare 前定义不一致必须拒绝或正规化。
5. 所有 R、C 必须 finite 且非负；数值钳零只能按显式 threshold，并累计 clipped bound。
6. topology 中 pin 必须可达 driver/root 或被分类为合法 multi-driver/unsupported；open、cycle policy 不能静默修复。
7. dirty scope 是正确性的保守上界；允许多算，不允许漏算可能改变的 coupling/environment/process influence。
8. 删除或移动 segment/via 必须清除 owner record 与所有 reverse index；不存在“只覆盖新值、不删旧值”。
9. full 与 incremental 使用同一 topology/calculate kernels；禁止为增量另写数值口径不同的近似 kernel。
10. `RcDelta` publish 要么全成功，要么 current view 不变；SPEF 文件写一半不构成发布。
11. route generation 或 tech/corner/model/calibration 变化后，旧结果只能读作历史 evidence，不能伪装 fresh。
12. F4 reference 未对齐 design、route hash、corner、temperature、coupling policy、单位和 report point 时不可参与 acceptance gate。

---

## 3. Agent capability 面、session 与状态机

### 3.1 Capability API（TARGET）

| Capability | Mutability | 输入 | 主要输出 |
|---|---|---|---|
| `rc.capabilities` | read-only | protocol client info | backend/fidelity/schema/limit manifest |
| `rc.open_session` | control | context refs、budget、isolation | `session_id`、frozen context digest |
| `rc.inspect` | read-only | session、object refs、detail level | topology/environment/component observation |
| `rc.estimate` | read-only | session、scope、F0/F1 policy | estimated graph/summary/domain/uncertainty |
| `rc.extract` | artifact write | session、scope、F2/F3 policy | candidate full/partial result，不自动 publish |
| `rc.update` | candidate mutation | session、`RouteDelta`、incremental policy | `ExtractionScope`、candidate `RcDelta` |
| `rc.compare` | read-only/artifact | lhs/rhs refs、definition、buckets | correlation/difference/gate evidence |
| `rc.validate` | read-only/artifact | result/delta、validation profile | structural/numeric/round-trip/downstream claims |
| `rc.publish` | state mutation | validated result/delta、expected generations | new rc generation、consumer notification |
| `rc.cancel` | control | session/operation、reason | cancellation acknowledgement |
| `rc.close_session` | control | session、retention policy | release report/artifact refs |

`extract` 和 `update` 只产生 candidate。只有 `validate` 达到 profile 要求且 `publish` CAS 成功后，结果才成为 branch current RC。这样 Agent 可以并行比较候选而不污染共享时序状态。

### 3.2 Capability discovery response

```yaml
schema: ieda.rcx.capabilities.v1
service_version: 1.1.0
backends:
  - id: ircx_2p5d
    build_digest: sha256:...
    fidelities: [F2, F3]
  - id: calibrated_early_rc
    model_digest: sha256:...
    fidelities: [F0, F1]
features:
  inspect: [net, segment, via, layer, coupling_pair, pattern]
  incremental_granularity: [net, tile]
  spef: [import, export, roundtrip]
  coupling_policies: [full, half_for_total_only]
limits:
  max_sessions: 8
  max_corners_per_operation: 16
  cooperative_cancel: true
unsupported:
  - via_capacitance: ircx_2p5d_current_backend
```

discovery 是路由决策输入，不是宣传页。尚未 qualification 的能力必须位于 `experimental` 或 `unsupported`，不能仅因为代码路径存在就标 supported。

### 3.3 Session 状态机

```text
NEW
  -> CONTEXT_BOUND
  -> READY
  -> RUNNING_INSPECT | RUNNING_ESTIMATE | RUNNING_EXTRACT | RUNNING_UPDATE
  -> CANDIDATE_READY
  -> VALIDATING
  -> VALIDATED
  -> PUBLISHING
  -> PUBLISHED
  -> CLOSED

任意运行态 -> CANCELLING -> CANCELLED
任意运行态 -> TIMED_OUT | FAILED | WORKER_LOST
CONTEXT_BOUND/READY/CANDIDATE_READY/VALIDATED -> STALE
```

状态转换规则：

- `open_session` 冻结 context refs；载入成功才进入 `READY`；
- 一个 session 同时最多有一个 mutating operation；read-only inspect 可读 immutable artifact；
- route/tech/corner generation 变化不会篡改 session，而是将其标 `STALE`；
- `CANDIDATE_READY` 不代表可发布；validation profile 决定 `VALIDATED`；
- `close_session` 不删除已发布 artifact，只释放 lease、worker 和临时 cache；
- 同一 `idempotency_key + request_digest` 重试返回已有 operation；key 相同而 digest 不同则 `IDEMPOTENCY_CONFLICT`。

### 3.4 Operation 状态与进度

```yaml
operation:
  operation_id: op:rcx:01J...
  state: RUNNING
  phase: calculate_capacitance
  progress:
    completed_nets: 128
    total_planned_nets: 420
    completed_tiles: 17
    total_planned_tiles: 52
    current_corner: rcworst_125c
  checkpoint_ref: artifact://...
  cancel_safe_point: edge_interval_boundary
  heartbeat_at: 2026-07-24T10:00:00Z
```

进度分母来自已冻结 scope，不允许运行中缩小分母制造 100%。scope 因保守 closure 扩大时记录 `scope_revision`、原因和新分母。

### 3.5 五段式调用边界

每次有代价的 capability 都执行：

1. **preflight**：schema、权限、ref、新鲜度、单位、route/tech/corner 完整性；
2. **plan**：选择 fidelity/backend、构建 scope、估算资源、冻结 cache key；
3. **execute**：在 session/worker 中计算 candidate，响应 cancel；
4. **validate**：结构、数值、coverage、round-trip、full/incremental 或 consumer 检查；
5. **publish**：CAS 提交 artifact/current alias，发 consumer event，持久化 evidence。

preflight 失败不启动 worker；execute 成功但 validate 失败保留 debug artifact，不更新 current alias。

---

## 4. 公共身份、上下文与 scope schema

### 4.1 Stable ID 规则（TARGET）

| ID | 构造 | 稳定边界 |
|---|---|---|
| `snapshot_id` | design snapshot content digest | design 内容不变 |
| `route_artifact_id` | canonical routed shapes/vias digest | route 内容不变 |
| `net_id` | snapshot namespace + escaped hierarchical net identity | rename/delete 会变 |
| `shape_id` | net_id + layer + normalized geometry + occurrence discriminator | 几何不变 |
| `via_id` | net_id + via master + origin/orientation + occurrence | via 不变 |
| `topology_node_id` | net_id + node kind + canonical coordinate/layer/pin ref | topology 等价重建 |
| `topology_edge_id` | ordered endpoint IDs + edge kind + source shape IDs | 同一物理 edge |
| `coupling_id` | corner + ordered net IDs + ordered segment-fragment IDs + interval | 同一物理贡献 |
| `rc_generation` | branch-local monotonic generation | publish 成功后递增 |

canonicalization 必须规定：dbu 整数坐标、矩形端点顺序、线段方向、hierarchy escape、bus delimiter、via orientation、重复 shape ordinal。禁止用内存地址、遍历线程编号或 SPEF name-map 序号生成 stable ID。

### 4.2 `ExtractionContext`（TARGET）

```yaml
schema: ieda.rcx.extraction_context.v1
context_id: ctx:rcx:...
snapshot_ref: {id: snap:..., digest: sha256:...}
branch_ref: branch:eco/42
route:
  artifact_ref: artifact://route/...
  generation: 184
  digest: sha256:...
  stage: detailed_route
  completion: committed
technology:
  tech_ref: tech:sky130:...
  mapping_digest: sha256:...
  layer_stack_digest: sha256:...
  via_model_digest: sha256:...
scenarios:
  - corner_ref: corner:rcworst
    process_digest: sha256:...
    temperature_c: 125.0
    captab_digest: sha256:...
units:
  distance_internal: dbu
  dbu_per_micron: 1000
  resistance_canonical: ohm
  capacitance_canonical: farad
model:
  backend: ircx_2p5d
  fidelity: F3
  model_digest: sha256:...
  calibration_ref: calib:rcx:...
  coupling_definition: full_pair_cap
environment:
  service_build: git:...
  compiler: ...
  architecture: x86_64
  thread_policy: deterministic_static
  seed: 240724
```

`route.stage` 枚举至少为 `global_route / track_assigned / detailed_route / post_eco_committed`。F2/F3 只接受有真实 layer、width、via 和连通关系的 route；`global_route` 只能进入 F0/F1，除非 backend capability 明确声明其为 F2 输入且结果仍标 partial/approximate。

### 4.3 `ExtractionScope`（TARGET）

```yaml
schema: ieda.rcx.scope.v1
scope_id: scope:...
selection:
  nets: [net:...]
  regions_dbu: [[0, 0, 100000, 100000]]
  layers: [M2, M3]
  tiles: [tile:M2:10:11]
closure:
  include_complete_selected_nets: true
  include_topology_junctions: true
  include_coupling_neighbors: true
  include_special_net_environment: true
  halo_by_layer_dbu: {M2: 6000, M3: 8000}
reason:
  primary_dirty_shapes: [shape:...]
  primary_dirty_vias: [via:...]
  invalidation_rules: [GEOMETRY_CHANGED, COUPLING_HALO, OLD_OWNER]
bounds:
  requested_net_count: 3
  planned_net_count: 17
  requested_area_dbu2: 10000000000
  planned_area_dbu2: 32400000000
```

scope 是可审计计划，不只是 net list。`requested` 与 `planned` 分开，Agent 才能理解为何局部 ECO 触发邻网重提。若 backend 无法证明有限 halo，planner 必须升级全量并写 `FULL_FALLBACK_UNBOUNDED_INFLUENCE`。

### 4.4 `TopologyArtifact`（TARGET）

```yaml
schema: ieda.rcx.topology_artifact.v1
artifact_id: artifact://rcx/topology/...
context_digest: sha256:...
scope_id: scope:...
nets:
  - net_id: net:...
    roots: [node:driver]
    nodes:
      - {id: node:..., kind: pin, point_dbu: [100, 200], layer: M2, pin_ref: pin:...}
    edges:
      - id: edge:...
        kind: wire
        u: node:...
        v: node:...
        source_shapes: [shape:...]
        layer: M2
        width_dbu: 140
        length_dbu: 1200
connectivity:
  opens: []
  unexpected_cycles: []
  ambiguous_drivers: []
canonical_digest: sha256:...
```

TopologyArtifact 必须先于 RC 数值生成，可独立 inspect/validate/cache。route shape 到 edge 的 lineage 不完整时不得声称可做精确增量删除。

---

## 5. 寄生、ownership、delta、result 与 evidence schema

### 5.1 `ParasiticGraph`（TARGET）

```yaml
schema: ieda.rcx.parasitic_graph.v1
graph_id: rcgraph:...
quality_class: EXTRACTED            # ESTIMATED | EXTRACTED | REFERENCE
fidelity: F3
context_digest: sha256:...
topology_artifact_ref: artifact://...
scenario: {corner_ref: corner:rcworst, temperature_c: 125.0}
units: {resistance: ohm, capacitance: farad}
nets:
  - net_id: net:...
    resistors:
      - {edge_id: edge:..., u: node:..., v: node:..., value: 8.2, source: wire_model}
    ground_caps:
      - {node_id: node:..., value: 1.7e-15, source_edges: [edge:...]}
    coupling_refs:
      - {coupling_id: cpl:..., peer_net_id: net:..., self_node_id: node:..., peer_node_id: node:...}
    totals:
      wire_r_sum_ohm: 28.1
      via_r_sum_ohm: 4.5
      ground_c_f: 8.1e-15
      coupling_c_full_f: 3.2e-15
coupling_store_ref: artifact://rcx/couplings/...
coverage_ref: artifact://rcx/coverage/...
canonical_digest: sha256:...
```

电阻保存 edge 值，不用“全网总 R”代替拓扑；ground C 保存实际 node attach；coupling 真值只在 coupling store 中保存，net 仅持引用。内部 canonical unit 使用 farad/ohm，API 展示可附便利单位，但 digest 只对 canonical 值计算。

### 5.2 `CouplingOwnership`（TARGET）

```yaml
schema: ieda.rcx.coupling_store.v1
records:
  - coupling_id: cpl:...
    owner_key:
      corner_ref: corner:rcworst
      net_lo: net:a
      net_hi: net:b
      fragment_lo: frag:...
      fragment_hi: frag:...
      interaction_interval_dbu: [1200, 4800]
      relation: same_layer_parallel
    endpoint_lo: node:...
    endpoint_hi: node:...
    capacitance_f: 2.4e-15
    model_source: {pattern_id: p:..., table_digest: sha256:...}
    source_environment: [shape:..., shape:...]
reverse_index:
  by_net: {net:a: [cpl:...], net:b: [cpl:...]}
  by_fragment: {frag:...: [cpl:...]}
  by_tile: {tile:M2:10:11: [cpl:...]}
```

唯一 ownership 不等于把全电容“分配给 victim”。`net_lo/net_hi` 只确定存储 owner；iSI 的 victim/aggressor 角色由分析窗口决定。导出某个 net 的 SPEF view 时可引用同一 record，但 full-chip 序列化 policy 必须避免重复导致 parser 二次累加。

强制检查：owner key 唯一；两端 net/fragment/node 存在；reverse index 双向完备；删除集合闭包完整；同一几何贡献不因线程顺序生成不同 ID；`sum(owner C)` 与按 net 展开视图按明确 coupling definition 对账。

### 5.3 `RcDelta`（TARGET）

```yaml
schema: ieda.rcx.rc_delta.v1
delta_id: rcdelta:...
base: {route_generation: 184, rc_generation: 77, rc_graph_digest: sha256:...}
target: {route_generation: 185, candidate_rc_generation: 78}
scope_ref: scope:...
topology:
  removed_nodes: [node:...]
  added_nodes: [{id: node:..., kind: junction, ...}]
  removed_edges: [edge:...]
  added_edges: [{id: edge:..., ...}]
parasitics:
  removed_resistors: [edge:...]
  upsert_resistors: [{edge_id: edge:..., value_ohm: 3.1}]
  removed_ground_caps: [{net_id: net:..., node_id: node:...}]
  upsert_ground_caps: [{net_id: net:..., node_id: node:..., value_f: 1.2e-15}]
  removed_couplings: [cpl:...]
  upsert_couplings: [{coupling_id: cpl:..., ...}]
dirty:
  nets: [net:...]
  timing_seed_nodes: [node:...]
  si_victim_candidates: [net:...]
inverse_ref: artifact://rcx/inverse/...
validation_ref: artifact://rcx/validation/...
canonical_digest: sha256:...
```

`removed_*` 必须显式，不能把“新 scope 没出现”隐式解释为删除。inverse 由 apply 前状态生成并持久化；rollback 只接受精确 base/target generation，不能把旧 inverse 应用到后续 generation。

### 5.4 `RcResult` envelope（TARGET）

```yaml
schema: ieda.rcx.result.v1
request_id: req:...
operation_id: op:...
session_id: session:...
status: SUCCEEDED
publishability: VALIDATION_REQUIRED
quality: {class: EXTRACTED, fidelity: F2, backend: ircx_2p5d}
context_ref: ctx:...
requested_scope_ref: scope:request
completed_scope_ref: scope:completed
remaining_scope_ref: null
artifacts:
  topology_ref: artifact://...
  parasitic_graph_ref: artifact://...
  rc_delta_ref: artifact://...
  spef_refs: []
coverage:
  route_geometry: 1.0
  topology: 1.0
  model_pattern: 0.973
  coupling_bound_accounted: true
uncertainty:
  method: calibrated_bucket_interval
  resistance_abs_bound_ohm: 0.9
  capacitance_abs_bound_f: 1.1e-15
warnings: [PATTERN_FALLBACK_USED]
unsupported: []
evidence_ref: artifact://rcx/evidence/...
```

`SUCCEEDED` 表示请求按 contract 完成，不代表 acceptance gate 通过；`publishability` 至少有 `NOT_PUBLISHABLE / VALIDATION_REQUIRED / VALIDATED / PUBLISHED`。partial 必须给 requested/completed/remaining 三个 scope，不能只给百分比。

### 5.5 `EvidencePack`（TARGET）

EvidencePack 至少包含：canonical request/context；所有输入 content digest；backend/service/compiler/build；seed/thread/scheduler；scope closure trace；stable-ID manifest；单位与 coupling definition；pattern hit/miss/OOD；clipped/cutoff bound；每 phase wall/CPU/RSS/I/O；validation claims；compare buckets；SPEF transaction/round-trip；iSTA/iSI ACK；worker stdout/stderr digest；错误链；artifact inventory 与 retention。

Evidence 本身 content-addressed，敏感 absolute path 和许可证信息经 redaction；原始商业报告留受控 artifact store，只把必要统计与 digest 放入可公开 evidence。

---

## 6. 增量提取：tile/net/halo、dirty 与保守失效

### 6.1 RouteDelta 到 ExtractionScope

```text
validate RouteDelta(base=184,target=185)
  -> collect added/deleted/moved/resized shapes and replaced vias
  -> primary dirty fragments/nets/tiles
  -> include old topology lineage and old coupling owners
  -> expand per-layer geometry influence halo
  -> query both old and new spatial indexes
  -> include neighboring regular/special nets and pair endpoints
  -> close complete selected-net topology and boundary crossings
  -> freeze ExtractionScope + reason graph
  -> remove old owned parasitics in scope
  -> rebuild topology/environment/process/R/C with shared kernels
  -> validate ownership/index/conservation
  -> create RcDelta and inverse
```

同时查询 old/new 空间索引是硬要求。只查新几何会漏掉被删除 aggressor 的旧 coupling；只查新 net list 会留下 orphan owner。

### 6.2 Tile 与 halo 规则

- tile 坐标由 `tech_ref + layer + tile_size_dbu + origin` 决定，并进入 cache key；
- shape 跨 tile 时所有相交 tile 都 dirty；边界 interaction 由 canonical fragment 负责；
- same-layer halo 至少覆盖模型支持的最大有效 lateral spacing、width influence、etch/density influence；
- cross-layer halo 覆盖 backend 声明的上下层数和投影扩展；
- via change 同时 dirty via 所连上下 routing layers、相邻 via/metal interaction 与整网 topology；
- special net move/resize 影响 shield/ground environment，不能因 special net 不输出普通 SPEF 而忽略；
- halo cutoff 只在物理模型有有限支持或有经验证的残差上界时使用；被截断 C 上界累计到 uncertainty；
- net topology 改变时默认重建整网，首版不做未经证明的 subtree splice。

### 6.3 Invalidation 矩阵

| 变化 | 最小保守失效 |
|---|---|
| wire add/delete/move | old/new tiles、所在 net、halo neighbors、旧 owner pair |
| width/shape resize | topology fragment、同层/跨层 environment、R/C、density influence |
| via add/delete/replace | 所在 net topology、相邻 layers、via R/C model、timing seeds |
| net rename/reconnect | stable identity/topology/SPEF name map/consumer mapping；通常 full-net |
| route stage 改变 | 所有依赖 stage 的 estimate/extract cache；未提交 route 不允许 F3 |
| mapping/ITF/captab | 所有相关 layer/corner 结果；默认 full design |
| temperature only | 对应 scenario R 与依赖温度的 C；topology 可复用 |
| calibration/model build | 对应 fidelity/model cache；旧 evidence 保留但 stale |
| coupling policy | coupling view/total definition/consumer cache；物理 owner store可复用需重证 |
| tile size/halo policy | scope/cache/index 全失效，不复用旧 incremental certificate |

### 6.4 Full fallback 条件

以下任一情况升级 full extraction，结果写明原因而非静默变慢：old lineage/owner reverse index 缺失；base generation 不匹配；跨层/密度影响没有已证明上界；route delta 含全局 layer remap；dirty closure 超过 `full_fallback_ratio`；topology ambiguity；stable-ID collision；incremental validation 抽检失败；backend 版本不支持该 delta kind。

`full_fallback_ratio` 只影响性能选择，不得用来缩小正确 scope。full fallback 保持请求的 fidelity/corner；不能为赶 timeout 偷降 F3 到 F1，除非调用方另发允许降级的新请求。

### 6.5 Incremental certificate

每个成功 update 生成 certificate：base/target digest；delta kind counts；old/new tile query digest；closure reason graph；removed/upsert owner counts；boundary checksum；full 抽检样本与误差；dirty/full runtime ratio；保守额外 scope 比率。certificate 是 publish profile 的输入，缺失时只能作为 debug candidate。

---

## 7. Fidelity、适用域、校准与 anytime

### 7.1 F0-F4 严格定义

| 档 | 前置 | 算法/输出 | 可声明 | 禁止声明 |
|---|---|---|---|---|
| F0 | placement/global route intent、tech layer averages | HPWL/Steiner/route guide RC | early estimate | extracted、coupling-complete |
| F1 | 可用拓扑代理、校准模型、domain detector | pattern/surrogate + interval | calibrated estimate in-domain | domain 外精度、signoff |
| F2 | committed detailed route、tech/corner，局部 closed scope | tile/net/halo 2.5D extraction | scope-extracted、partial/full scope coverage | full-chip coverage（若 scope 局部） |
| F3 | 完整 committed route、全量 supported model | full iRCX 2.5D | full-design iRCX extracted | StarRC 等价 |
| F4 | 冻结外部 protocol 与完整 provenance | StarRC/field solver imported result | reference under named protocol | 跨 corner/route 的真值 |

Fidelity 是证据等级，不是数字越大就允许省略 provenance。F2 的数值 kernel 应与 F3 一致，区别主要是 scope 与增量证明。

### 7.2 适用域与 calibration

`DomainDescriptor` 至少覆盖 technology/process family、layer、width/spacing、length、via master/stack、parallel overlap、cross-layer distance、neighbor count、shield/special-net context、density、temperature、route stage。每个 observation 分类为 `IN_DOMAIN / NEAR_BOUNDARY / OUT_OF_DOMAIN / UNKNOWN`。

校准 artifact 包含训练/验证 design split、reference tool/version/options、feature ranges、bucket count、误差分布、absolute floor、时间戳和模型 digest。禁止在同一 net 样本上训练又报告 acceptance；禁止用全局 alpha 掩盖 layer/pattern/via 结构缺失。

### 7.3 Unsupported、partial 与 fallback

- 当前 backend 的 via C、multi-neighbor、专用 shield pattern 等缺口必须逐 pattern 报告；
- supported fallback 可用保守 proxy，但输出 `PARTIAL_COVERAGE`、source 与 uncertainty，不得假装 native hit；
- unknown pattern 若无安全 fallback，相关 scope 为 unsupported；不得填零；
- estimate 请求可按 policy 从 F1 降 F0，但必须记录 downgrade；extract 请求默认不允许降到 estimate；
- partial artifact 可供 inspect/debug/继续运行，不可自动发布；
- timeout 时保存最后完整 net/tile checkpoint，不把半个 net 的 owner store 暴露为有效 graph。

### 7.4 Anytime 与停止

执行顺序优先完成 whole-net atomic units，并可按 criticality 排序，但排序依据和版本进入 evidence。停止条件为预算耗尽、cancel、安全故障或 scope 完成。任何 early stop 返回 completed/remaining scope；只有调用方明确请求 `allow_partial=true` 才返回 partial artifact，否则只返回失败与 checkpoint ref。

---

## 8. Route -> RC -> iSTA/iSI 时序、cache key 与发布

### 8.1 版本链

```text
iRT commits RouteDelta at route_generation=185
  -> Observer emits route.committed(snapshot, branch, base/target, digest)
  -> iRCX opens/binds context and plans dirty closure
  -> iRCX extracts candidate RcDelta(base_rc=77,target_route=185)
  -> iRCX structural/numeric/incremental validation
  -> RcStore CAS(base_route=184,current_route=185,base_rc=77)
  -> publish rc_generation=78 + immutable ParasiticGraph
  -> iSTA ACK consumes dirty timing seeds against rc_generation=78
  -> iSI ACK consumes canonical coupling records against rc_generation=78
  -> Evaluation/Hub assembles joint evidence
```

route 已变而 RC 尚未 publish 时，branch 状态必须是 `STALE_RC`。iSTA 可以显式读取旧历史结果做比较，但 commit/acceptance gate 不得把它当 current。

### 8.2 Cache key

```text
RCKey = H(
  schema_major, snapshot_digest, route_artifact_digest, route_generation,
  tech/layer/via/mapping digests, corner/process/captab, temperature,
  route_stage, topology_builder_version, environment_policy,
  backend/model/calibration digests, fidelity, coupling_definition,
  canonical_scope_digest, tile/halo policy, unit_policy,
  deterministic_thread_policy, relevant feature flags)
```

不进入数值语义的字段如 request ID、输出目录、日志级别不得破坏 cache；会改变数值或 topology 的字段不得遗漏。scope cache 可复用 immutable tile/topology fragment，但组合后必须重跑 boundary/owner validation。

### 8.3 Consumer contract

iSTA importer 接收 topology nodes/edges、ground cap 与 coupling policy，并回传 `consumed_rc_generation`、mapped/unmapped node counts、dirty endpoints、incremental/full timing check。iSI 必须直接读取 canonical full coupling C 和两端 stable IDs；Miller factor、victim/aggressor、window overlap由 iSI 计算，不能固化进 iRCX graph。

若 consumer 只支持 SPEF，bridge 先事务导出再 read-back 校验，consumer ACK 仍绑定 SPEF digest 与 rc generation。任何 name mapping discard、单位不匹配、topology attach 失败都阻断 joint gate。

### 8.4 Publish、rollback 与 replay

publish 流程：获取 branch RC lease；校验 candidate/evidence digest；CAS route/RC generations；写 immutable graph/delta；更新 current alias；发送 outbox event；等待 required consumer ACK。alias 或 event 失败时用事务日志恢复；消费者失败不篡改已发布数值，但 branch gate 为 `RC_CONSUMER_INCOMPLETE`。

rollback 优先发布 inverse 为新 generation，而不是把计数器倒退。replay 从 canonical request、input artifact、backend image/build、seed 和 deterministic policy 重跑，比较 canonical digest；外部 F4 若许可证环境不可重放，至少重放 importer/compare 并验证原始 artifact digest。

---

## 9. SPEF 事务、round-trip 与 legacy worker 隔离

### 9.1 SPEF export transaction

```text
validate graph is publishable for requested export policy
  -> create request-scoped staging directory
  -> serialize deterministic header/name-map/net order
  -> fsync file and write manifest(digest, units, corner, graph, counts)
  -> parse staged SPEF with independent reader
  -> compare topology/R/gcap/ccap/name/unit against source graph
  -> atomic rename artifact directory
  -> publish artifact ref; cleanup staging on failure
```

可重复导出模式固定 `*DATE` 或将其排除 semantic digest；net/node/cap/res 排序按 stable ID，不能依赖 unordered container。文件名包含合法化 corner/temperature 和 collision-resistant digest。已有路径默认拒绝覆盖；显式 replace 也只能通过新 artifact version。

### 9.2 Round-trip acceptance

round-trip 必查：design/name-map escape、hierarchy/bus delimiter、ports/instance/internal node attach、corner/temperature manifest、C/R unit scale、resistor endpoints/value、ground C node/value、coupling unordered pair/value、`*D_NET` 定义、empty/zero section 语义、几何扩展忽略后的核心等价。

容差只用于十进制格式化误差，默认 `max(1e-21 F, 1e-9 relative)` 与 `max(1e-9 ohm, 1e-9 relative)`；超限阻断 artifact。SPEF importer 不允许把 parse error、未知单位或 dangling name 映射为零。

### 9.3 Worker 隔离

CURRENT singleton `RCX_DATA_INST/RCX_CONFIG_INST` 和进程级 OpenMP 线程数不适合多租户并发。ai1.1 首版由 service control plane 为每个 mutating session 启独立 worker 进程：只读 input artifact；私有临时目录和输出；cgroup/rlimit CPU/RSS/file-size；无网络默认；heartbeat/cancel pipe；结构化 result channel；崩溃时丢弃 staging。

一个 worker 同时只处理一个 context。control plane 不把指针/裸 singleton 状态跨 worker 暴露；后续只有在消除全局状态并通过 TSAN/多 session 确定性测试后，才评审 in-process backend。

---

## 10. 失败、timeout、cancel、partial 与 validate/compare

### 10.1 状态与错误码

| code | 语义 | 可重试/动作 |
|---|---|---|
| `MISSING_ROUTE/TECH/CORNER` | 必要输入缺失 | 补输入；绝不返回零 RC |
| `ROUTE_NOT_COMMITTED` | stage/generation 非已提交 | 等待 iRT commit |
| `STALE_ROUTE_GENERATION` | session/request 已旧 | 新 context 重跑 |
| `UNSUPPORTED_PATTERN/VIA_MODEL` | backend 无可信模型 | partial、升级 backend/F4 |
| `TOPOLOGY_OPEN/AMBIGUOUS_DRIVER` | route topology 非法或不明确 | 上游修复/显式 policy |
| `UNIT_UNKNOWN/NAME_MAP_ERROR` | 解析/序列化不可解释 | 阻断 publish |
| `OWNER_INVARIANT_FAILED` | coupling 重复、残留或索引缺失 | full fallback；隔离 candidate |
| `INCREMENTAL_MISMATCH` | 与 full oracle 超差 | 禁用该 delta kind 增量 |
| `BUDGET_EXCEEDED/TIMED_OUT/CANCELLED` | 未完成 | checkpoint/remaining scope |
| `WORKER_OOM/WORKER_LOST` | 隔离 worker 失败 | current state 不变，可限资源重试 |
| `CAS_CONFLICT` | route/RC generation 被抢先更新 | 重绑 base，不盲重放 |
| `CONSUMER_REJECTED` | iSTA/iSI attach/ACK 失败 | publish gate 不完整 |

错误 envelope 含 `phase`、`retryable`、`completed_scope_ref`、`remaining_scope_ref`、`last_checkpoint_ref`、cause chain、worker exit/resource peak 和 evidence ref。cancel 是 cooperative；超过 grace period kill worker，状态为 `CANCELLED_FORCED`，staging 不可发布。

### 10.2 `rc.compare` 与 `rc.validate`

compare 先验证 design/route/corner/temperature/unit/coupling definition/report point 可比较性，再输出 topology match、wire R、via R、ground C、coupling C、total C、Elmore 与可选 slack/noise buckets。每项同时报 sample/coverage、absolute MAE/P50/P95/max、relative MAE/P50/P95（排除 absolute floor 并计数）、bias、R²/rank correlation、missing-only 两侧集合。

validate profiles：`STRUCTURAL`（ID/topology/owner/finite/nonnegative）；`ROUNDTRIP`；`INCREMENTAL`（boundary/full oracle）；`TIMING_CONSUMER`；`SI_CONSUMER`；`COMMERCIAL_G8`。claim 结果为 `PASS/FAIL/INCOMPLETE/UNSUPPORTED`，只有 PASS 可满足 hard gate；没有样本、缺阈值或 unsupported 不能变绿。

---

## 11. TARGET LLD、真实落点与 CMake

### 11.1 目录与 target

```text
src/operation/iRCX/agent/
  schema/        ExtractionContext.hh RcScope.hh ParasiticGraph.hh RcDelta.hh RcResult.hh
  service/       RcService.hh RcSession.hh OperationRegistry.hh
  inspect/       RcInspector.hh ComponentLineage.hh
  estimate/      EarlyRcEstimator.hh DomainGuard.hh CalibrationStore.hh
  incremental/   DirtyScopePlanner.hh TileIndex.hh CouplingOwnership.hh IncrementalExtractor.hh
  transaction/   RcTransaction.hh RcStore.hh SpefTransaction.hh ConsumerPublisher.hh
  validation/    RcValidator.hh IncrementalChecker.hh SpefRoundTrip.hh EvidenceBuilder.hh
  worker/        WorkerClient.hh WorkerMain.cc WorkerProtocol.hh
  adapter/       LegacyExtractionBackend.hh IdbRouteArtifactAdapter.hh IstaRcAdapter.hh
```

| 类 | 责任 | 不负责 |
|---|---|---|
| `RcService` | capability/preflight/session/operation 调度 | 数值 kernel |
| `DirtyScopePlanner` | old/new index、halo、closure、fallback | 修改 route |
| `CouplingOwnership` | canonical record/reverse index/invariants | victim window |
| `IncrementalExtractor` | remove-rebuild-delta/checkpoint | 发布 current alias |
| `LegacyExtractionBackend` | 复用 CURRENT topology/environment/R/C | Agent 状态机 |
| `RcTransaction/RcStore` | CAS、immutable artifact、inverse/outbox | timing 计算 |
| `RcValidator` | 结构/数值/coverage claim | 自行放宽门禁 |
| `EvidenceBuilder` | provenance/resource/claim inventory | 解析自由文本当真值 |

### 11.2 CMake 与兼容策略

新增 `ircx_agent_schema`（无 singleton）、`ircx_agent_incremental`、`ircx_agent_validation`、`ircx_agent_service`、`ircx_worker` 和对应 tests；链接方向为 schema <- incremental/validation <- service，legacy backend 作为 adapter 私有依赖。禁止让 calculate/topology 反向依赖 agent runtime。

根 `src/operation/iRCX/CMakeLists.txt` 最后 `add_subdirectory(agent)`；tests 注册 CTest，不再 `EXCLUDE_FROM_ALL`。保留现有 `RCXAPI`/Tcl 行为；兼容入口可调用 legacy backend，但不会虚构 session/delta。feature flag 缺省关闭，直到 full regression 与 round-trip 门禁通过。

### 11.3 分 PR 计划

| PR | 内容 | 合入门禁 |
|---|---|---|
| RC-A0 | schema、units、stable ID、capabilities | schema golden/compat/property |
| RC-A1 | immutable route/topology adapter、inspect | CURRENT full topology digest 回归 |
| RC-A2 | ParasiticGraph/ownership、legacy F3 adapter | component/SPEF totals 对账 |
| RC-A3 | SPEF transaction/import/round-trip | malformed/units/name-map fuzz |
| RC-A4 | tile index、dirty planner、invalidation trace | closure analytic/property tests |
| RC-A5 | incremental remove-rebuild、RcDelta/inverse | add/delete/move/via/full equivalence |
| RC-A6 | RcStore CAS、worker isolation、cancel/replay | crash/OOM/conflict tests |
| RC-A7 | iSTA/iSI adapters与 dirty ACK | slack/noise full-vs-incremental |
| RC-A8 | F0/F1 domain/calibration | OOD/coverage/holdout qualification |
| RC-A9 | StarRC harness、G8 evidence/perf dashboard | 冻结阈值联合门禁 |

每个 PR 只扩一条可回滚边界；不得把 schema、增量 kernel、consumer 改造和商业门禁塞进一个大提交。

---

## 12. 测试、故障、性能与商业对拍

### 12.1 测试金字塔

| 层 | 必测 |
|---|---|
| analytic golden | 单 wire、L/T/branch、parallel pair、cross-layer overlap、wire+single/stack via；手算 R/C/topology |
| unit/schema | canonical IDs、unit conversion、corner key、scope closure、owner/reverse index、delta inverse |
| property | R/C finite nonnegative；长度/电阻率单调；pair order 不变；owner 唯一；serialize digest 稳定 |
| metamorphic | 平移/镜像、输入/线程顺序、net rename 后数值不变、拆分共线段守恒、单位缩放等价 |
| incremental/full | add/delete/move/resize wire、replace via、special shield、neighbor-only dirty、边界 tile、随机 delta 序列 |
| parser fuzz | SPEF name-map、delimiter、bus、科学计数、单位、duplicate/missing section、dangling node、超大值/NaN |
| integration | route commit -> RcDelta -> iSTA/iSI ACK；SPEF bridge 与 memory graph 数值一致 |
| replay | 同环境 digest 一致；worker crash 后 checkpoint 重跑；artifact 缺失明确失败 |

Golden 不使用提取器自身生成 expected；analytic fixture 由独立公式或手工 SPEF 审核。incremental property 对每条随机 route delta 同时跑 full oracle，比 topology/pair set、per-edge R、node gcap、coupling owner 和下游结果。

### 12.2 故障注入

注入缺 ITF/captab/mapping、unknown layer/via、route generation 竞态、tile index 损坏、owner reverse index 丢失、磁盘满、staging rename 失败、parser truncation、worker SIGKILL/OOM、timeout 在各 phase、cancel 在 owner rebuild、consumer拒绝、outbox 重发。断言 current alias 不变、无半文件、重试幂等、错误码和 remaining scope 正确。

### 12.3 Performance protocol

固定机器/CPU affinity/build/线程/冷暖 cache，分别测 full F3 与 ECO F2。报告 wall/CPU/RSS、geometry/edge/net/pair 数、index/plan/topology/environment/R/C/validate/export phase、cache hit、dirty/full scope ratio、增量/full wall ratio、p50/p95/p99、cancel latency。性能提升不得通过减少 pattern/coverage 或跳过验证取得。

ai1.1 目标：典型局部 ECO planned nets <= full 的 10%、p95 增量 wall <= full 的 15%；若物理 halo 合法导致超过，报告“范围扩散”而非错误归咎线程。full extraction 相对 CURRENT 回归：wall <= 1.10x、peak RSS <= 1.15x。

### 12.4 StarRC/field-solver 对拍

冻结同一 GDS/DEF、netlist、tech translation、corner/temperature、metal fill、coupling threshold、reduction、SPEF definition 与 report point；保存 StarRC command/version/log/output digest。design split 至少覆盖公开小设计、工业宏/总线、长线高扇出、密集耦合、宽金属、via-rich、shield/special context；校准集与验收集隔离。

必报 layer × width/spacing × length × via × neighbor/pattern × coupling-ratio buckets。联合门禁同时检查 topology coverage、ground C、coupling C、wire R、via R、Elmore、同一 iSTA slack 与 iSI delta-delay/noise；任何必需维度 unsupported/incomplete 则 G8 不通过。

目标阈值在 qualification 前由 flow owner 冻结；建议起点：matched net/topology >= 99.5%，ground C/coupling C/wire R absolute-floor 后 p95 relative <= 10%，via R p95 <= 15%，component R² >= 0.98，Elmore p95 <= 10%，critical slack p95 absolute delta <= 10 ps。小值同时使用 absolute floor，禁止相对误差爆炸或被排除样本隐身。

---

## 13. 里程碑、量化 DoD 与可杀假说

### 13.1 里程碑

`M0 contract/inspect` -> `M1 immutable full graph + round-trip` -> `M2 ownership/dirty scope` -> `M3 incremental transaction` -> `M4 iSTA/iSI closed loop` -> `M5 estimate calibration` -> `M6 commercial/performance qualification`。前一阶段 evidence 不绿，不开放后一阶段默认路由。

### 13.2 ai1.1 完成定义

- 六类 capability、session/state/error schema 有 golden 与兼容测试；
- 缺 route/tech/corner、OOD/unsupported、empty/zero 的反例全部不能假成功；
- F0/F1 在所有 result/export/evidence 中不可被识别为 extracted/signoff；
- stable ID 在 1/8/32 threads、输入乱序和 replay 下 canonical digest 一致；
- analytic golden 的 topology、R、gcap、ccap 在冻结容差内全通过；
- SPEF export/import 100% fixture round-trip，无 dangling name、未知单位或 coupling 双计；
- 10k 随机 route delta 序列无 owner 残留/重复，incremental 与 full graph digest 或数值容差一致；
- crash/OOM/timeout/cancel/CAS conflict 后 current RC 不变且 staging 可回收；
- iSTA dirty update 与 full rebuild 的 endpoint/slack 在阈值内，iSI coupling/noise 语义通过单对扰动；
- full 回归、增量性能与 StarRC 联合门禁达到 §12 冻结阈值；
- CMake targets/CTest、operator metrics、evidence retention 和 rollback runbook 可在干净 out-of-tree build 重放。

### 13.3 可杀假说

| 假说 | 杀死实验 | 被杀后的动作 |
|---|---|---|
| 全局 alpha 足以达到商业相关性 | layer/pattern/via holdout residual | 补模型/coverage，不继续盲调 alpha |
| 有限 halo 不漏 coupling | 扩大 halo/full pair-set differential | 扩 scope 或 full fallback |
| dirty tile 一定更快 | 多种 ECO size 的 phase profile | 调整 fallback ratio/index，不降 fidelity |
| SPEF 能完整承载内存图 | independent round-trip + consumer attach | 修 exporter/importer或优先 memory contract |
| iSTA 读 coupling 即代表 SI 闭环 | 单 coupling 扰动看 noise/delta-delay | 完成 iSI contract，不以 read success 代替 |

---

## 14. 开放 ADR、主要风险与版本历史

必须形成 ADR：canonical coupling total 定义；tile/halo proof；stable topology node rule；multi-driver policy；SPEF duplicate coupling policy；F2 publish validation profile；F4 raw artifact retention；worker sandbox；current alias 与 consumer ACK 的一致性。

主要风险是 CURRENT global state 隔离成本、iDB route lineage 不足、via C/multi-neighbor/shield 模型空缺、不同 SPEF consumer 对 coupling/名称口径不一，以及商业许可证导致 CI 不稳定。对应策略分别是 worker、immutable adapter、显式 unsupported/模型 PR、round-trip consumer suite、离线 artifact + 定期受控 qualification。

| 版本 | 日期 | 说明 |
|---|---|---|
| ai1.0 | 2026-07 | 初版能力与增量概述 |
| ai1.1 | 2026-07-24 | 基于真实 API/kernel/SPEF/compare/test/consumer/CMake 审计，补齐可实施 Agent service、schema、事务、验证与 DoD |
