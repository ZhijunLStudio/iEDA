<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 22 · iPL Agent 原生布局实施规格 · ai1.0

> 事实基线：`src/operation/iPL`、`src/interface/tcl/tcl_ipl`、`src/platform/tool_manager/tool_api/ipl_io`，以及 `10-iDB-ai1.0.md`、`12-evaluation-ai1.0.md`、`20-iFP-ai1.0.md`、`51-agent-native-eda-detailed-plan-v1.0.md`、`53-agent-native-eda-architecture-v2.0.md`。
>
> 当前成熟度：iPL 已有标准单元全局布局、合法化、增量合法化、详细布局、network-flow spreading、布局检查器、PlacerDB/iDB wrapper 和 evaluation/iSTA 调用路径。当前入口仍以 singleton、可变 PlacerDB、整阶段调用、`bool`/裸数值和主动 write-back 为主；snapshot/branch、typed delta、scope/frozen proof、结构化 partial、并发 worker、checkpoint/cancel 和 Verification certificate 均是 **TARGET**，不是已实现能力。
>
> 首个垂直闭环：在一个已合法的 post-place/post-CTS immutable snapshot 上，定位少量 critical cells，产生 move/swap/reorder 候选，在隔离 branch 中 apply，执行有界局部合法化，比较 iEval F0-F3 指标，取得 placement/frozen/timing/congestion 证书，由 Runtime 原子提交一个候选。

---

## 0. 目标、非目标与唯一责任

### 0.1 目标

iPL Agent 面不是 `run_placer` 的自然语言包装。首版必须做到：

- `inspect -> diagnose -> propose -> apply(branch) -> verify` 每一步都有版本化结构化输入输出；
- proposal 不修改设计，apply 只修改 Runtime 分配的 candidate branch；
- 每个动作声明 requested scope、frozen complement、预期 touched、实际 `actual_touched`、dirty、inverse 和 certificate invalidation；
- move、swap、reorder、spread、legalize、incremental legalize 的语义可区分、可拒绝、可回放；
- 低 fidelity 只筛选，合法性、timing、congestion 等提交门禁由相应权威 validator 签发；
- legacy kernel 可通过隔离 adapter 渐进复用，旧 Tcl/API 数值和流程在迁移期间保持回归可控；
- 失败、超时、取消、局部不可行和不支持均不污染 base snapshot，也不伪装成成功。

### 0.2 非目标

- iPL 不拥有 branch 生命周期、最终 candidate selection 或 commit；这些属于 Runtime 和 iDB。
- iPL 不定义 WNS/TNS、拥塞、功耗的权威口径；度量归 iEval，timing 真值归 iSTA。
- placement legality certificate 不等价于 QoR 改善，也不包含 DRC、STA、route 或 signoff clean。
- 首版不承诺任意宏自动布局。当前 `PLAPI::runMP` 实现体被注释，macro placer 未接入 `source/module/CMakeLists.txt`。
- 首版不自动 resize、插 buffer、改 netlist、改 floorplan、改 SDC/UPF 或解冻 `fixed/dont_touch` 对象。
- 不把 ONNX wirelength predictor 的一个成功推理当作通用模型注册、适用域证明或 verification oracle。
- 不承诺替代商业/signoff placement，也不预先写死未经 benchmark 冻结的绝对性能数字。

### 0.3 Owner 与责任边界

| Owner | 负责 | 明确不负责 |
|---|---|---|
| iPL（本文） | placement observation、诊断、候选生成、placement delta 编译、legacy kernel adapter、自有结构合法性 validator | branch commit、跨工具 QoR 决策、STA/route/DRC 真值 |
| iDB（10） | immutable snapshot、branch、TypedDelta journal、CAS、stable ID、dirty/invalidation 持久化 | 选择移动位置或判断 QoR 优劣 |
| iEval（12） | metric 定义、F0-F4 路由、可比性、Pareto、QoR gate/evidence | 签发 placement correctness certificate |
| iFP（20） | die/core/row、macro/IO/blockage/region、placement handoff | 标准单元局部布局决策 |
| Runtime（43） | capability 调度、预算、lease、worker、cancel、candidate selection、commit | 修改 placement 算法语义 |
| Intent/Scenario（48） | hard/soft intent、scenario set、policy ref | 从 placement 结果反推并静默修改约束 |
| Verification Hub（49） | validator DAG、certificate bundle、freshness/revocation | 生成候选或定义 reward |
| Tech Knowledge（55） | LEF/Liberty/RC/单位/映射/qualification 的 `TechContextRef` | 以缺失 tech 默认值放行 |
| Agent Tool Hub | schema 校验、鉴权、capability manifest、限流、审计 | 将自由文本直接映射成内存写操作 |

硬分界是：**iPL 可以报告“布局结构合法”，iEval 可以报告“指标改善”，只有 Runtime 在 Verification Hub 证书完整且 head CAS 成功时才能提交。**

---

## 1. CURRENT 事实审计与 TARGET 边界

### 1.1 已核实的源码资产（CURRENT）

| 证据位置 | 已存在能力 | 可复用定位 | 不能据此声称 |
|---|---|---|---|
| `src/operation/iPL/api/PLAPI.hh` | `runGP/runLG/runIncrLG/runDP/runNetworkFlowSpread`、white space、legality、report、timing 查询 | legacy facade 后端 | 已有 branch/delta/cancel/structured error |
| `src/operation/iPL/source/module/global_placer/electrostatic_placer/NesterovPlace.*` | electrostatic/Nesterov GP、HPWL/overflow 迭代日志、best 记录、固定 seed 的局部噪声路径 | F2/F3 global runner kernel | 已有对外 progress stream、可恢复 checkpoint 或 cooperative cancel |
| `src/operation/iPL/source/module/legalizer/Legalizer.*` | full/incremental legalize、指定 target list、solver rollback | local legalize adapter 的起点 | 已证明 requested halo、actual touched、frozen complement 不变 |
| `Legalizer::updateInstanceList` | changed count 小于总实例 10% 时选择 incremental，否则 complete | 回退行为的现状证据 | 当前回退符合 Agent scope；TARGET 必须显式授权 full fallback |
| `src/operation/iPL/source/module/detail_placer` | RowOpt、InstanceSwap、LocalReorder、NFSpread、HPWL 计算 | 候选/动作 kernel 拆分来源 | 现有 `runDP` 是有界局部、只触碰声明对象的 delta |
| `DetailPlacer::checkIsLegal` | 当前实现直接返回 `true` | 迁移时的负面基线 | DP 自检已覆盖合法性；提交必须调用独立 checker |
| `src/operation/iPL/source/module/checker/layout_checker` | inside-core、row/site、row orientation/power alignment、overlap 检查 | placement structural validator 的一部分 | 已覆盖 dont_touch、fence、halo/channel、multi-height、scope/frozen |
| `src/operation/iPL/source/module/wrapper/IDBWrapper.*` | iDB 到 PlacerDB wrap 和 placement write-back | legacy worker materialize/export adapter | write-back 是事务性 TypedDelta apply |
| `src/operation/iPL/api/external_api/ExternalAPI.*` | iSTA/evaluation timing、WL、congestion、report 桥接 | legacy sensor adapter | 返回值具备 snapshot/provenance/coverage |
| `src/platform/tool_manager/tool_api/ipl_io` | init/destroy/full flow/incremental legalization 门面 | legacy compatibility entry | worker 隔离或并发安全 |
| `src/interface/tcl/tcl_ipl` | `run_placer`、分阶段 GP/LG/DP、incremental LG、check/report | 人工回归和兼容面 | Agent capability protocol |
| `src/operation/iPL/source/module/macro_placer` 与 CMake | readme/目录存在，CMake 接入和 `runMP` body 被注释 | 未来实现参考 | CURRENT 支持 macro placement |
| `src/operation/iPL/test/CMakeLists.txt` | 多个历史测试源被列出但 test executable 段被注释 | fixture/场景线索 | 当前 iPL 已有持续执行的完整测试矩阵 |

### 1.2 CURRENT 调用与状态风险

```text
Tcl / ToolManager / another operation
  -> PlacerIO singleton
  -> PLAPI singleton
  -> PlacerDB singleton (mutable mirror of iDB)
  -> GP/LG/DP mutates PlacerDB
  -> optional evaluation/iSTA calls
  -> writeBackSourceDataBase mutates source iDB
  -> destroy singleton
```

该路径适合顺序 legacy flow，但 Agent 并行候选会暴露四类风险：

1. 调用隐含“当前设计”，request 无法绑定 immutable `snapshot_ref`。
2. solver 可能移动目标之外对象，现有返回只给 `bool`，无法审计 `actual_touched`。
3. write-back 不是 delta journal；中途崩溃、部分写入和 rollback 证据不可表达。
4. singleton/全局输出目录/evaluation session 不允许同进程无约束并发。

### 1.3 CURRENT/TARGET 成熟度表

| 能力 | CURRENT | TARGET 首版 |
|---|---|---|
| inspect | report、white-space 和内部 DB 查询 | snapshot-bound、分页、带单位/coverage 的 observation |
| diagnose | 算法内部日志/报告 | 结构化 root causes、conflict objects、recommended action classes |
| propose | GP/DP 直接求解并写内部状态 | 至少 move/swap/reorder 三类不写设计的 proposal set |
| apply | PlacerDB mutation + write-back | branch-only typed delta，precondition + CAS + inverse |
| local legalize | changed list 入口 | 显式 halo、禁止静默全量、返回 actual touched/冲突证据 |
| verify | `LayoutChecker` bool/report | claim/coverage/witness/certificate，独立 frozen validator |
| anytime | 迭代日志、内部 best 值 | progress event、legal incumbent、deadline/cancel/checkpoint/resume |
| parallel candidates | 未建立 | 每 branch 独占 legacy worker/session/output dir |
| errors | bool/log/fatal 路径混合 | `OK/PARTIAL/UNSUPPORTED/INFEASIBLE/...` 且 success 不吞缺口 |

迁移原则：先在 legacy 外加 contract 和隔离层，锁住原数值与写回行为；不得先搬迁整个 iPL 目录或让旧入口同时写主状态和 branch。

---

## 2. Agent capability 面与生命周期

### 2.1 Capability 清单

| Capability | 风险 | 是否写状态 | 输出 | 首版 |
|---|---:|---:|---|---:|
| `place.capabilities` | R0 | 否 | manifest/limits/versions | P0 |
| `place.inspect` | R0 | 否 | `PlacementObservation` | P0 |
| `place.diagnose` | R0 | 否 | `PlacementDiagnosis` | P0 |
| `place.propose_moves` | R1 | 否 | `MoveProposal[]` | P0 |
| `place.propose_spread` | R1 | 否 | `MoveProposal[]` | P1 |
| `place.propose_global` | R1 | 否 | candidate artifact/progress | P1 |
| `place.apply_delta` | R2 | branch | `PlacementDeltaResult` | P0 |
| `place.legalize_local` | R2 | branch | actual delta/result | P0 |
| `place.refine_detail` | R2 | branch | bounded actual delta/result | P1 |
| `place.verify_structure` | R0 | 否 | verification result | P0 |
| `place.checkpoint/resume/cancel` | R1 | worker/artifact | token/terminal result | P1 |
| `place.run_legacy_flow` | R3 | isolated import/export | legacy artifact | compatibility only |

`place.capabilities` 必须公布支持的 stage、action、object kind、maximum page/action/scope、fidelity、cancel 粒度、determinism、fallback、worker isolation、schema/tool/kernel hash。manifest 未声明的组合返回 `UNSUPPORTED`，不能猜测执行。

### 2.2 五段式边界

```text
inspect(snapshot)                 read-only, no proposal
  -> diagnose(observation)        evidence -> cause, no mutation
  -> propose(snapshot, diagnosis) candidates, no mutation
  -> apply(branch, proposal)      compile + atomic branch mutation
  -> verify(candidate snapshot)   independent claims/certificates
```

- `inspect` 读取 snapshot，不接收裸 `IdbBuilder*` 或 `PlacerDB*`。
- `diagnose` 区分 overlap、off-site、density hotspot、timing-critical placement pressure 和 `UNKNOWN`，不得由 metric 相关性伪造因果。
- `propose` 输出 precondition、估计、风险和适用域；其 `estimated` 不是验收结论。
- `apply` 只接受 `branch_ref + expected_head + proposal/delta`，不得隐式创建或提交 branch。
- `verify` 必须从 candidate snapshot 重读，不信任 proposal 的 expected/estimated 字段。

### 2.3 状态机

```text
REQUESTED -> VALIDATED -> MATERIALIZING -> RUNNING
    -> PROPOSED                         (read/propose terminal)
    -> APPLIED -> DIRTY -> VERIFIED     (branch action)
    -> CHECKPOINTED -> RUNNING          (resume)
    -> PARTIAL | UNSUPPORTED | INFEASIBLE | CANCELLED | FAILED
```

只有 `VERIFIED` 表示 iPL 请求所要求的 placement claims 已完成；仍不表示可 commit。`PARTIAL` 必须包含产出范围和未完成项，不能携带 `commit_eligible=true`。`CANCELLED` 的未合法 incumbent 仅能作为 proposal artifact，不能作为 applied candidate head。

---

## 3. 功能与非功能需求

### 3.1 功能需求

| ID | 需求 | 优先级 | 验收要点 |
|---|---|---:|---|
| FR-PL-01 | inspect 返回 object/row/site/bin/net/constraint 的稳定引用和 coverage | P0 | 不暴露裸指针；可分页和 artifact 化 |
| FR-PL-02 | diagnose 返回证据、置信度、冲突集和可行动作类别 | P0 | `UNKNOWN` 与无问题可区分 |
| FR-PL-03 | move/swap/reorder proposal 不修改任何 snapshot | P0 | propose 前后 state hash 相同 |
| FR-PL-04 | proposal 声明 stage、scope、precondition、objective vector 和 estimated fidelity | P0 | 缺字段拒绝进入 apply |
| FR-PL-05 | apply 使用 expected head 和 before value 做双重冲突检查 | P0 | stale proposal 零写入 |
| FR-PL-06 | local legalize 返回实际移动对象和 displacement | P0 | actual touched 可完整重建 |
| FR-PL-07 | scope 外对象由 frozen proof 校验 | P0 | 任一越域变化使请求失败 |
| FR-PL-08 | dirty nets/bins/timing cones 和 invalidated certificates 可计算 | P0 | 与 iDB journal 一同发布 |
| FR-PL-09 | inverse delta 覆盖全部 actual touched | P0 | apply/rollback hash 恢复 |
| FR-PL-10 | full fallback 只能由请求 policy 显式授权 | P0 | local solver 不静默扩散为全芯片 |
| FR-PL-11 | structural legality 输出分项 claim、coverage 和 witness | P0 | skipped 不得转成 PASS |
| FR-PL-12 | legality 与 iEval metric/STA/route certificate 分离 | P0 | 类型和 issuer 不可混用 |
| FR-PL-13 | F0-F4 路由记录 requested/actual fidelity 和降档原因 | P0 | F0/F1 不能跨 hard gate |
| FR-PL-14 | GP/large spread 支持 progress、deadline、cancel 和 legal incumbent | P1 | cancel 后无半写 branch |
| FR-PL-15 | checkpoint token 完整绑定输入、配置和实现 | P1 | 任一绑定变化后 token stale |
| FR-PL-16 | legacy E0 调用和 Agent adapter 可双跑对拍 | P0 | 旧 Tcl 回归门禁不被绕开 |
| FR-PL-17 | partial/unsupported/infeasible 返回结构化 diagnostics | P0 | 不使用空数组或零值代替 |
| FR-PL-18 | 支持 iTO/iNO 提供的 physical feasibility request | P1 | iPL 不直接应用 netlist delta |

### 3.2 非功能需求

| ID | 要求 |
|---|---|
| NFR-PL-01 | 所有 Agent 读写请求绑定 `snapshot_ref/intent_ref/scenario_ref/tech_ref/policy_ref`。 |
| NFR-PL-02 | 坐标以整数 DBU 传输并携带 unit context；禁止无单位浮点坐标跨边界。 |
| NFR-PL-03 | 同 snapshot/config/seed/thread/kernel hash 应可重放；非确定性必须公布统计策略。 |
| NFR-PL-04 | legacy singleton 一次只属于一个 worker lease；同进程不得并发复用。 |
| NFR-PL-05 | branch action 原子发布；OOM、signal、worker loss、artifact failure 后 base/head 不变。 |
| NFR-PL-06 | 输出规模受 page、artifact、action count、region area 和 runtime budget 限制。 |
| NFR-PL-07 | 所有 cache key 覆盖 state/context/action/kernel/model/fidelity；dirty 后精确失效。 |
| NFR-PL-08 | 安全日志不含完整网表、绝对受限路径、secret 或不受限实例列表。 |
| NFR-PL-09 | 未测量的性能目标不写成承诺；benchmark 报 median/MAD、硬件、线程和冷暖缓存。 |
| NFR-PL-10 | contract 层不依赖 PLAPI/PlacerDB singleton；legacy 类型不得穿越 Agent Tool Hub。 |

---

## 4. Context、请求与核心 schema

### 4.1 公共上下文

每个 request/response 都复用 `10/51/53` 的引用语义：

```yaml
context:
  tenant_id: tenant-A
  request_id: req-uuid
  trace_id: trace-uuid
  snapshot_ref: sha256:base-state
  branch_ref: branch-uuid            # read-only 请求可省略
  expected_head: sha256:branch-head  # mutation 必填
  intent_ref: sha256:intent-ir
  scenario_ref: sha256:scenario-set
  tech_ref: sha256:qualified-tech-context
  policy_ref: sha256:placement-policy
  schema_version: place.v1
  deadline: 2026-07-23T12:00:00Z
```

缺 context 不是自动取当前全局状态的理由。`tech_ref` 未通过当前 action 所需 qualification 时返回 `TECH_UNQUALIFIED`；`scenario_ref` 不适用于纯结构 inspect 时也应保留引用，以保证后续候选可比。

### 4.2 `PlacementRequest`

```yaml
placement_request:
  context: {...}
  stage: post_floorplan | global | legal | detail | post_place | post_cts | eco
  operation: inspect | diagnose | propose | apply | legalize | refine | verify
  scope:
    region: {die_id: die0, lx_dbu: 0, ly_dbu: 0, ux_dbu: 0, uy_dbu: 0}
    object_selectors: [{kind: instance, ids: [inst:17, inst:21]}]
    allowed_instances: [inst:17, inst:21]
    halo: {x_dbu: 4000, y_dbu: 8000, max_instances: 200}
    frozen_complement: true
  allowed_actions: [move, swap, reorder, spread, legalize_incremental]
  hard_constraints:
    preserve_fixed: true
    preserve_dont_touch: true
    preserve_regions: true
    max_displacement_dbu: 20000
    max_actual_touched: 200
    require_legal_output: true
  objectives:
    metrics: [hpwl, density_overflow, congestion_proxy, setup_slack, disruption]
    pareto_only: true
    hard_gates_ref: sha256:gate-profile
  fidelity: {requested: F1, allow: [F0, F1, F2], allow_downgrade: false}
  budget: {wall_ms: 30000, cpu_ms: 120000, memory_bytes: 4294967296, candidates: 32}
  reproducibility: {seed: 17, threads: 1, deterministic_required: true}
  fallback: {allow_expand_halo: false, allow_full_legalize: false, max_escalations: 1}
  output: {page_size: 200, include_maps: false, artifact_threshold_bytes: 1048576}
```

`allowed_instances` 是可写集合，不是“优先考虑”集合。halo 是 local legalizer 可搜索/连带移动的最大许可边界；两者的交集和 policy 决定最终 writable set。`frozen_complement=true` 时，未列入 writable set 的 placement 字段必须保持 hash 不变。

### 4.3 `PlacementObservation`

```yaml
placement_observation:
  context_echo: {...}
  status: OK | PARTIAL | UNSUPPORTED | FAILED
  stage: post_place
  object_page:
    items:
      - inst_ref: inst:17
        master_ref: master:NAND2_X1
        bbox_dbu: [1000, 2000, 1400, 2800]
        orient: N
        placement_status: PLACED
        mobility: MOVABLE | FIXED | DONT_TOUCH | UNSUPPORTED
        region_refs: [region:cpu]
        row_refs: [row:31]
        connected_net_refs: [net:9]
    next_page_token: opaque-or-null
  legal_space:
    intervals_artifact_ref: sha256:intervals
    row_site_grid_ref: grid:rows-v3
    blockers_by_kind: {fixed: 12, blockage: 3, frozen: 44}
  maps:
    - metric: density
      grid: {origin_dbu: [0, 0], step_dbu: [20000, 20000], dims: [64, 64]}
      artifact_ref: sha256:density-map
      source: ipl_grid | ieval_density
      fidelity: F0
      coverage: {region_fraction: 1.0, skipped: []}
  criticality:
    timing_scenario_ref: sha256:scenario-set
    cells_artifact_ref: sha256:critical-cells
    source: ista | legacy_timing_adapter
  summary: {movable: 100, frozen: 40, unsupported: 2, overlap_cliques: 0}
  provenance: {tool: ipl-agent, kernel_hash: sha256:kernel, config_hash: sha256:config}
  diagnostics: []
```

Observation 中每个 map 必须绑定 grid origin、step、dimensions、DBU 和 snapshot。两个 grid 未经显式 resample 不可逐 bin diff。分页 token 绑定 request/context/filter/order；snapshot 变化后 token 失效。

### 4.4 `MoveProposal`

```yaml
move_proposal:
  proposal_id: proposal:uuid
  base_snapshot_ref: sha256:base-state
  stage: eco
  action: move | swap | reorder | spread | legalize | legalize_incremental
  requested_scope: {...}
  preconditions:
    expected_placements:
      - {inst_ref: inst:17, x_dbu: 1000, y_dbu: 2000, orient: N, version: 8}
    required_capabilities: [legalize_incremental.v1]
    required_tech_qualification: [row_site_mapping]
  requested_edits:
    - {inst_ref: inst:17, to: {x_dbu: 2400, y_dbu: 2000, orient: N}}
  expected_touched: [inst:17]
  estimated:
    metrics: [{name: hpwl_delta, value: -3200, unit: dbu, fidelity: F0}]
    legal_state: NEEDS_LEGALIZE
    uncertainty: {kind: interval, low: -5000, high: 600}
  risk_flags: [NEAR_FENCE]
  generator: {name: critical_cell_move, version: 1.0, seed: 17, config_hash: sha256:cfg}
  expires_on_head_change: true
```

Proposal 是建议，不是 delta journal。swap 必须列出双方 before/to；reorder 必须列出窗口内完整原序和目标序；spread 必须给出每个实例的显式目标或确定性生成 artifact，禁止在 apply 时二次自由决策。

### 4.5 `PlacementDelta` 与 result

```yaml
placement_delta:
  delta_id: delta:uuid
  base_snapshot_ref: sha256:base-state
  branch_ref: branch:uuid
  expected_head: sha256:branch-head
  requested_scope: {...}
  operations:
    - op: set_placement
      inst_ref: inst:17
      before: {x_dbu: 1000, y_dbu: 2000, orient: N, status: PLACED}
      after:  {x_dbu: 2200, y_dbu: 2000, orient: N, status: PLACED}
      reason: requested_move | swap | reorder | legalizer_side_effect | spread
  actual_touched:
    instances: [inst:17, inst:18]
    fields: [placement]
  dirty:
    instances: [inst:17, inst:18]
    nets: [net:9, net:12]
    bins: [{grid_ref: grid:density-v1, indices: [10, 11]}]
    timing_cones: [{scenario_ref: sha256:scenarios, seed_pins: [pin:44]}]
    congestion_regions: [{lx_dbu: 0, ly_dbu: 0, ux_dbu: 5000, uy_dbu: 5000}]
  inverse:
    operations:
      - op: set_placement
        inst_ref: inst:17
        before: {x_dbu: 2200, y_dbu: 2000, orient: N, status: PLACED}
        after:  {x_dbu: 1000, y_dbu: 2000, orient: N, status: PLACED}
  invalidation:
    certificates: [placement.legal.v1, placement.frozen.v1, timing.incremental.v1]
    metric_cache_namespaces: [hpwl, density, congestion, timing, power]
    artifacts: [sha256:old-placement-map]
  proof_inputs:
    frozen_before_hash: sha256:frozen-before
    writable_set_hash: sha256:writable-set
```

Result 额外携带 `new_snapshot_ref/new_head/result_hash/actual_fidelity/fallback_used/diagnostics/artifact_refs`。`actual_touched` 从 before/after snapshot diff 计算，不能只相信 solver target list。inverse 必须覆盖所有 actual operations；不能构造 inverse 时 action 不允许 publish。

### 4.6 Scope、身份与不变量

Scope 至少由 `die + region + explicit objects + writable fields + halo + frozen complement` 组成。bbox 内的实例不自动可写，连接到 dirty net 的实例也不自动可写。stable ID 不复用，name 只用于展示；请求解析 name 时必须固化为 ID 列表和解析 snapshot。

最小硬不变量：

- fixed/dont_touch/unsupported 实例 placement 不变；
- 标准单元在合法 row/site 上、orientation 与允许集合一致、无 overlap；
- fence/region/domain、blockage、row fragment 和 multi-height compatibility 满足；
- macro 的 halo/channel/orientation 仅在相应已实现 validator 覆盖时可宣称通过；
- requested scope 外 placement hash 不变，netlist/master/connectivity/clock/route/constraint 一律不因 placement delta 改变；
- `from/before` 与 branch head 不一致时返回 conflict，零写入。

---

## 5. 动作语义、dirty 与失效

### 5.1 动作定义

| Action | 请求语义 | 允许 actual touched | 最小检查 | 不可静默行为 |
|---|---|---|---|---|
| move | 一个实例到目标点/orient | 目标 + 授权 legalize halo | mobility、before、region、displacement、legal | 改 master、连线、解冻 |
| swap | 两个兼容实例交换 site/orient | 两个目标 + 授权 halo | width/height/site/domain/region、完整 before | 以“swap”名义移动第三方不报告 |
| reorder | 同一 row window 内改变实例顺序 | 窗口显式成员 + 授权 halo | 成员集合、row compatibility、窗口边界 | 将窗口外对象拉入 |
| spread | 在区域内降低密度/拥塞压力 | 显式 writable set | density target、blocker、max displacement、budget | 将 GP 变成全芯片写回 |
| legalize | 对请求 placement 求合法解 | 请求明确的 full writable set | structural invariants | 隐式扩大 scope |
| legalize_incremental | 对 dirty instances + halo 求局部合法解 | writable halo 内实际连带对象 | local feasibility、actual touched、frozen proof | target 过多时自动全量执行 |

resize hint 或 buffer insertion proposal 来自 iTO/iNO；iPL 可回答 physical feasibility 或在 netlist delta 已由其 owner 应用后合法化，不能自行改变 master/connectivity。

### 5.2 Local legalize 算法契约（TARGET）

```text
validate context/head/before/mobility
  -> resolve allowed instances and frozen complement
  -> expand search window within requested halo and object cap
  -> build row/site intervals after fixed/blockage/frozen occupancy
  -> solve ordering/displacement with region/height/orient constraints
  -> materialize proposed placements in worker-local state
  -> diff all placement fields against branch input
  -> reject if actual_touched exceeds writable set/cap
  -> run independent structural checker
  -> derive dirty/invalidation/inverse
  -> atomic publish delta or publish nothing
```

无局部解返回 `INFEASIBLE_LOCAL`，并给出冲突 rows、intervals、blockers、对象和最小已知 expansion hint。Runtime 可以新建请求扩大 halo；solver 自身不得改写原请求。若 `allow_full_legalize=true`，full fallback 仍要作为新 attempt 记录，scope、成本、actual touched 和所有证书覆盖随之升级。

### 5.3 Dirty propagation

| 变化 | dirty | invalidation |
|---|---|---|
| instance coordinate/orient | old/new overlap bins、connected nets、pin locations | HPWL/density/congestion/timing/power map；placement legal/frozen |
| 多实例 swap/reorder | 两端/窗口 bins、成员 connected nets | 同上；window ordering artifact |
| region-wide spread | 覆盖区域及 map kernel halo、所有 touched nets | region metric cache；相关 timing/congestion certificate |
| legalizer side effect | 每个实际 before/after 对应对象 | 按实际 diff，不按 requested list 估计 |

dirty set 是“必须重新计算的最小已知集合”，不是 correctness certificate。增量 validator 必须声明 closure 规则和 coverage；无法证明 closure 时升级 full validation 或返回 partial。

### 5.4 Inverse 与失效纪律

- inverse 顺序与 forward operation 逆序一致，并保留 status/orient/coordinate 的精确 before 值；
- rollback 在新 branch/head 上作为另一条 journal delta 执行，不擦除历史；
- snapshot、intent、scenario、tech、policy、kernel/model 任一语义输入变化都使 proposal/cache stale；
- placement delta 至少撤销 base 的 placement legality/frozen、受影响 iEval metric、incremental STA/congestion certificate；
- full legalize/refine 导致 touched 集扩大时，失效按实际集合重算，不能沿用 request 预估。

---

## 6. TARGET 架构与数据流

### 6.1 组件图

```text
Planner / Observer
       |
       v
Agent Tool Hub -- auth/schema/capability --> PlacementAgentService
       |                                      | inspect/diagnose/propose
       |                                      v
       |                              PlacementReadModel
       |
Runtime -- branch/lease/budget/cancel --> PlacementWorkerBroker
                                               |
                     +-------------------------+----------------------+
                     | isolated legacy worker                         |
                     | SnapshotMaterializer -> PLAPI/PlacerDB kernels |
                     | -> DeltaCapture -> StructuralValidator         |
                     +-------------------------+----------------------+
                                               |
                             PlacementDelta + evidence artifacts
                                               v
                   iDB journal/branch ----> iEval / Verification Hub
                                               |
                                      Runtime select + head CAS commit
```

Contract/read-model 层不链接 `ipl-api`。只有 worker adapter 链接 legacy `ipl-api/ipl-source`，以便在迁移期硬隔离 singleton 和输出目录。

### 6.2 Inspect/propose 数据流

```text
validate request + authorize snapshot
  -> resolve qualified TechContext and Intent/Scenario
  -> query immutable iDB read model
  -> optionally materialize read-only PlacerDB worker
  -> collect rows/sites/objects/maps with provenance
  -> diagnose with deterministic rules
  -> generate bounded proposal set
  -> schema/invariant/precondition validation
  -> persist artifact by content hash
  -> return proposals; snapshot hash remains unchanged
```

### 6.3 Apply/verify/commit 数据流

```text
Runtime creates branch and acquires lease
  -> apply checks branch expected_head + proposal base
  -> worker materializes exact branch snapshot
  -> adapter executes requested bounded action
  -> DeltaCapture compares before/after and rejects overreach
  -> iDB atomically appends PlacementDelta, advances branch head
  -> Verification Hub runs placement/frozen + dependent validators
  -> iEval measures comparable base/candidate metrics
  -> Runtime selects one candidate
  -> final freshness check + head CAS commit
```

任何 worker 内 write-back 只能落到 worker-local materialization。它不得持有 base snapshot writer；真正状态发布仅通过 iDB TypedDelta journal。

---

## 7. Fidelity、anytime、cancel、checkpoint 与回落

### 7.1 F0-F4 定义

| 档位 | Placement 计算 | 可用于 | 不可用于 |
|---|---|---|---|
| F0 | bbox/HPWL delta、row/site interval、局部 density arithmetic | 候选枚举、明显不合法预筛 | 提交门禁、拥塞/timing clean |
| F1 | RUDY/density map、早期 timing proxy、可选已校准 learned ranker | 排序、淘汰、OOD 检测 | 证明 placement/timing/route 正确 |
| F2 | 有界 local legalize/detail refine、incremental HPWL/density/iSTA | 局部候选升级 | 未覆盖范围的 full-chip claim |
| F3 | full iPL structural check + full iEval/iSTA/必要 early route | 内部 commit 候选验证 | foundry/commercial signoff 等价 |
| F4 | 经 Bridge qualification 的外部 placer/legalizer/signoff 组合 | policy 要求的外部相关性/最终证据 | qualification domain 外泛化 |

`requested_fidelity` 与 `actual_fidelity` 必须分开。依赖缺失时只有 request 明确允许才能降档，结果必须带 `DEGRADED` 和原因；任何 hard gate 不得由 F0/F1 PASS。

### 7.2 Anytime 进度

```yaml
placement_progress:
  attempt_id: attempt:uuid
  sequence: 42
  phase: materialize | initialize | optimize | legalize | validate | publish
  iteration: 120
  metrics:
    hpwl: {value: 1234000, unit: dbu, fidelity: F0}
    density_overflow: {value: 0.14, unit: ratio, fidelity: F0}
  incumbent_ref: sha256:candidate-artifact
  incumbent_state: UNLEGALIZED | LEGAL_LOCAL | LEGAL_FULL
  elapsed_ms: 8300
  budget_remaining: {wall_ms: 21700}
  termination_hint: CONTINUE | CONVERGED | PLATEAU | BUDGET_NEAR | CANCEL_PENDING
```

Progress sequence 单调递增且是 evidence，不直接推进 branch head。GP 内部现有日志和 best HPWL/overflow 可作为改造起点，但在没有显式导出坐标、状态和 context 前不算 incumbent contract。

### 7.3 Cancel 与 terminal result

- cancel 是 cooperative token，kernel 在声明的最大响应粒度内轮询；超时后 Runtime 可终止 worker。
- cancel 前尚未 publish TypedDelta 时，branch head 不变；worker 临时状态被丢弃。
- 最近 `LEGAL_LOCAL/LEGAL_FULL` incumbent 可作为 proposal artifact 返回，仍需新的 apply/verify。
- 只有 `UNLEGALIZED` incumbent 时返回 `CANCELLED_WITH_PARTIAL`，`commit_eligible=false`。
- worker 被强杀后由 Runtime/CAS 检查 terminal event；不存在 atomic publish 记录即视为未应用。

### 7.4 Checkpoint/resume

Checkpoint manifest 至少绑定：base snapshot、intent/scenario/tech/policy、stage、solver/config/kernel hash、seed、thread count、floating mode、iteration、coordinate/object ordering、optimizer state、artifact hashes 和 worker ABI。resume 前逐项校验；head、tech 或 config 改变均返回 `CHECKPOINT_STALE`。

首版允许只对 global runner 实现 checkpoint。local move/legalize 应足够短，优先依靠原子重试。现有 `saveNesterovPlaceData` 是调试数据输出，未经 round-trip/determinism 测试不能宣称为 resume checkpoint。

### 7.5 回落规则

| 原因 | 允许回落 | 禁止行为 |
|---|---|---|
| local infeasible | 返回 conflict；由 Runtime 显式扩大 halo/改 proposal | solver 自动 full legalize |
| F1 model OOD | 回 F0 heuristic 或升 F2，按 policy | 用高置信默认值掩盖 OOD |
| incremental metric unsupported | 升 full metric 或 partial | 把缺值记 0/PASS |
| worker OOM/timeout | 终止、保留已发布 artifact、重试较小 budget | 复用未知完整性的内存状态 |
| F4 external unavailable | 按 policy 保留 F3/UNKNOWN | 伪造 F4 certificate |

---

## 8. 合法性、度量与 Verification certificate

### 8.1 三类结果必须分离

| 类型 | Owner/issuer | 回答的问题 | 示例 |
|---|---|---|---|
| Structural validation | iPL validator | placement 结构是否满足已声明规则 | inside core、row/site、orient、overlap、region |
| Metric evidence | iEval + domain adapter | 候选的 QoR 数值与 base 如何比较 | HPWL、density、congestion、WNS/TNS、power |
| Verification certificate | Verification Hub 注册 issuer | 某 claim 在某 coverage/fidelity/context 下是否成立且新鲜 | placement legal、frozen unchanged、timing checked |

`LayoutChecker::checkLegality()` 的 bool 只能作为 CURRENT sensor。TARGET validator 必须逐项返回 PASS/FAIL/UNKNOWN/SKIPPED、coverage、witness objects、algorithm/version；宏 halo、dont_touch、multi-height 等未实现检查不能被总 bool 吞掉。

### 8.2 iPL structural claims

首版 claim profile：

| Claim | 必需输入 | 最小 witness/coverage |
|---|---|---|
| `placement.inside_core.v1` | snapshot、die/core | 全部 actual touched + 受影响 blocker |
| `placement.row_site.v1` | row/site tech mapping | 全部 touched 标准单元 |
| `placement.orientation.v1` | allowed orient/row/domain | touched 对象及例外列表 |
| `placement.no_overlap.v1` | placement + obstruction geometry | dirty region closure 或 full design |
| `placement.region.v1` | fence/guide/domain intent | touched + region members |
| `placement.frozen.v1` | before/after + frozen set hash | frozen complement 全字段 diff |
| `placement.delta_integrity.v1` | journal/inverse/actual diff | 全部 actual operations |

只有证书 coverage 与 policy 要求一致时才能进入 bundle。局部 no-overlap 必须证明检查区域包含所有跨边界相交对象；否则返回 `PARTIAL` 或升级 full check。

### 8.3 Certificate schema

```yaml
verification_certificate:
  certificate_id: cert:uuid
  claim: placement.no_overlap.v1
  verdict: PASS | FAIL | UNKNOWN
  subject_snapshot_ref: sha256:candidate
  base_snapshot_ref: sha256:base
  intent_ref: sha256:intent
  tech_ref: sha256:tech
  scope: {...}
  coverage: {objects_checked: 182, objects_total_in_claim: 182, skipped: []}
  evidence_refs: [sha256:witness, sha256:validator-log]
  issuer: {name: ipl-structural-validator, version: 1.0, binary_hash: sha256:bin}
  issued_at: 2026-07-23T12:00:00Z
  invalidation_keys: [placement, row_geometry, region_constraints, tech_mapping]
```

证书 issuer 由 Verification Hub 注册和鉴权；iPL response 只能引用已签发证书，不能在自然语言字段自称 certified。

### 8.4 iEval 契约

- iPL 只请求 metric name/scope/fidelity，不读取裸全局 `TimingAPI` 作为 Agent 真值。
- CURRENT `ExternalAPI` 的 WL/congestion/timing 调用进入 `LegacyPlacementMetricAdapter`，必须补 snapshot、unit、source、coverage、stage 和 error mapping。
- iPL 内部 HPWL/density 可用于 kernel objective 和 F0 evidence；与 iEval 同名指标先完成数值/单位/stage 对拍。
- candidate 排序由 iEval Pareto/comparability 完成；iPL 不隐藏加权总分决定 commit。
- post-CTS timing 候选必须使用 common iSTA scenario semantics；legacy timing adapter 仅在 qualification domain 内作为 F1/F2。

---

## 9. 事务、并发、worker、缓存与恢复

### 9.1 原子 apply

```text
1 authorize(branch, capability, tenant, scope)
2 acquire branch lease; compare expected_head
3 validate schema, before values, tech and policy
4 materialize exact head into worker-local PlacerDB
5 run action; capture complete before/after diff
6 enforce writable set, touched cap and hard invariants
7 build forward/inverse/dirty/invalidation artifacts
8 append artifacts to CAS; verify hashes
9 atomically append journal + advance branch head
10 emit terminal event and release lease
```

步骤 1-8 任一失败都不推进 head。步骤 9 CAS conflict 时丢弃该 publish attempt，返回 `HEAD_CONFLICT`；不得把同一 solver state 套到新 head 上重放。

### 9.2 并发模型

- 同一 branch mutation 串行化；不同 branch 可并行。
- inspect 可并发读取 immutable snapshot，但 legacy sensor 若依赖 singleton 仍经 worker/session 串行化。
- proposal 不取得 writer lease；apply 时必须重新验证 proposal preconditions。
- 两个 disjoint delta 也不由 iPL 自动 merge；Runtime/iDB 根据 actual touched、dirty/invalidation 和 policy 决定重放或拒绝。
- output directory 使用 `tenant/request/attempt` 隔离，禁止由 config 指向共享路径。

### 9.3 Legacy worker 隔离

每个 legacy worker 固定一个 tenant、snapshot、branch attempt、PLAPI/PlacerDB 生命周期和临时目录。输入 mount 只读，输出目录配额受控，默认无网络；worker 只能调用 capability manifest 固定的二进制和 argv/config schema。worker 返回 artifact/hash 后退出或完全 reset，不能跨 snapshot 复用未知 singleton 状态。

建议进程隔离优先于线程锁，因为 PLAPI、PlacerDB、Legalizer、evaluation 和 ToolManager 均存在 singleton/global state。线程内并行只有在对应 kernel 完成无全局状态审计和 TSAN 后才能开放。

### 9.4 Cache key 与恢复

Cache key 至少为：

```text
hash(snapshot + intent + scenario + tech + policy + stage + scope
     + capability + action/config + fidelity + seed/threads
     + schema/tool/kernel/model versions)
```

Observation/proposal cache 不跨 head。局部 metric cache 只有在 dirty closure 与 adapter invalidation contract 已测试时复用。crash recovery 从 iDB journal/CAS 和 terminal events 重建；worker 临时文件不是事实源。损坏或缺失 artifact 返回 `ARTIFACT_CORRUPT`，不能从日志猜测成功。

---

## 10. 失败、partial 与 unsupported

### 10.1 统一状态和错误码

| Code | 语义 | state change | 可否重试 |
|---|---|---:|---|
| `INVALID_ARGUMENT` | schema/单位/范围错误 | 无 | 修请求后 |
| `UNAUTHORIZED_SCOPE` | tenant/object/capability 越权 | 无 | 需新授权 |
| `SNAPSHOT_NOT_FOUND` | 引用不存在/不可见 | 无 | 修引用后 |
| `HEAD_CONFLICT` | branch head 与 expected 不同 | 无 | 重新 propose/apply |
| `STALE_PROPOSAL` | base/before/precondition 变化 | 无 | 重新 propose |
| `TECH_UNQUALIFIED` | tech mapping/单位/规则未认证 | 无 | 补 qualification |
| `UNSUPPORTED` | manifest 不支持 stage/action/object | 无 | 换能力/工具 |
| `INFEASIBLE_LOCAL` | 当前 scope/halo 无局部合法解 | 无 | 显式扩大/换候选 |
| `SCOPE_VIOLATION` | actual touched 超出 writable set | 无 publish | 缩 action/扩授权 |
| `VALIDATION_FAILED` | placement hard invariant 失败 | 无 publish 或 branch rejected | 修 proposal |
| `PARTIAL` | 有结果但 coverage/依赖不完整 | 最多 artifact | 升档/补依赖 |
| `CANCELLED` | cooperative cancel | 未发布 head 不变 | 可 resume/retry |
| `TIMEOUT/OOM/WORKER_LOST` | 执行资源失败 | head 不变 | 按 policy |
| `ARTIFACT_CORRUPT` | hash/manifest/持久化失败 | head 不变 | 重算 |
| `INTERNAL` | 未分类实现错误 | head 不变 | 人工排查 |

### 10.2 Partial 纪律

Partial response 必须列出 `completed_items/skipped_items/coverage/missing_dependencies/resume_or_retry_hint`。典型例子：inspect 分页成功但 congestion map 缺失；F2 local legalize 成功但 STA timeout；incremental overlap 只覆盖局部且 closure 未证明。任何 partial 都不映射为 `success=true` 或 PASS certificate。

空结果语义必须明确：`items: [] + status: OK` 表示已完整检查且为空；`UNSUPPORTED` 表示能力不存在；`PARTIAL` 表示未完整观察；`FAILED` 表示执行失败。

---

## 11. 跨模块契约

| 模块 | iPL 消费 | iPL 产出 | 关键约束 |
|---|---|---|---|
| iFP（20） | die/core/row/site、macro/IO、blockage、region/halo/channel handoff | placement feasibility/pressure、标准单元候选 | floorplan_ref 改变使 placement proposal/certificate stale |
| iNO（21） | buffer/clone candidate 和 affected nets | whitespace/placement feasibility、post-netlist legalize delta | iPL 不拥有 connectivity change |
| iTO（25） | resize/VT/buffer candidate、critical objects | fit/space/move/legalize evidence | timing verdict 归 iSTA；master delta 先由 iTO owner apply |
| iCTS（23） | clock cells/nets、dont_touch、post-CTS scenario | clock-aware local placement candidate | 不移动未授权 clock object；setup/hold 同验 |
| iRT（26） | congestion/pin-access/route blockage、F3 route result | dirty nets/regions、placement candidate | RUDY 不是 route certificate；route change 使相关 placement metrics stale |
| iSTA（27） | scenario-bound critical paths/slack/sensitivity | moved pins/nets/timing dirty cone | common timing API 是 F2/F3 真值，禁止另立 WNS 口径 |
| iDB（10） | snapshot/read model/stable ID/branch/lease | PlacementDelta/inverse/dirty/invalidation | 不传裸 pointer；head CAS 是发布边界 |
| Runtime（43） | budget/seed/worker/cancel/fallback/selection | progress/terminal/evidence | iPL 不 commit，不跨 branch 写 |
| Intent/Scenario（48） | hard constraints、dont_touch、domains、objective/gate refs | conflict diagnostics | 约束缺失不由 iPL自行补默认 |
| Tech Knowledge（55） | DBU、row/site、master geometry/orient、LEF/Liberty mapping | qualification usage evidence | mapping 不完整返回 TECH_UNQUALIFIED |
| Verification Hub（49） | validator profile、required claims | structural evidence/certificate refs | freshness/coverage/revocation 由 Hub 管理 |
| Agent Tool Hub | auth、schema negotiation、capability routing | typed response/artifact refs | 不接受 shell/Tcl/free-form path 作为 Agent mutation API |

跨模块 ordering 规则：floorplan/tech/intent 先固定，placement proposal 才可比较；netlist/master delta 先应用再 legalize；placement apply 后先结构验证，再做 incremental/full metric，最后组装 certificate bundle。任何上游引用改变都触发显式 stale，而非“尽量复用”。

---

## 12. 安全、权限与审计

- Tool Hub 对 capability、tenant、snapshot、branch、object scope 和 risk level 做服务端鉴权，模型提示不是权限边界。
- selector 解析有最大对象数；regex/glob、page size、region area、candidate count 和 artifact bytes 均受 policy 限制。
- config 只允许 schema 白名单字段；路径使用 artifact/secret handle，拒绝 `..`、任意绝对输出路径和 shell expansion。
- legacy Tcl 不能从 Agent 请求拼接；外部 binary 使用固定 argv，无 shell，默认无网络和最小只读 mount。
- proposal/apply/verify 记录 caller、context hashes、capability/schema/tool/kernel、seed/thread、budget、fallback、actual touched、结果和 artifact hash。
- 日志按 tenant 隔离并执行 retention/tombstone；训练/经验数据只有在策略允许且完成脱敏/lineage 后进入 Data Oracle/Experience Memory。
- 模型或插件产出的坐标始终经过 deterministic schema、precondition、scope 和 independent validator，不能绕过。

必须注入的安全反例包括：跨 tenant snapshot、stale page token、超大 selector、恶意 artifact path、伪造 stable ID、越权 fixed move、config 命令注入、worker 网络访问、符号链接逃逸和 stale certificate replay。

---

## 13. LLD、构建目标与迁移

### 13.1 TARGET 源码落点

```text
src/operation/iPL/agent/
  CMakeLists.txt
  contract/
    PlacementTypes.hh
    PlacementSchemaValidator.{hh,cc}
    PlacementStatus.hh
  service/
    PlacementAgentService.{hh,cc}
    PlacementCapabilityProvider.{hh,cc}
  inspect/
    PlacementReadModel.{hh,cc}
    PlacementInspector.{hh,cc}
    PlacementDiagnoser.{hh,cc}
  proposal/
    LocalMoveGenerator.{hh,cc}
    SwapReorderGenerator.{hh,cc}
    SpreadCandidateGenerator.{hh,cc}
    GlobalCandidateRunner.{hh,cc}
  apply/
    PlacementDeltaCompiler.{hh,cc}
    PlacementDeltaCapture.{hh,cc}
    IncrementalLegalizerAdapter.{hh,cc}
    DetailRefineAdapter.{hh,cc}
  verify/
    PlacementStructuralValidator.{hh,cc}
    FrozenPlacementValidator.{hh,cc}
    PlacementCertificateEvidence.{hh,cc}
  worker/
    LegacyPlacementWorker.{hh,cc}
    PlacementSnapshotMaterializer.{hh,cc}
    PlacementProgressAdapter.{hh,cc}
  adapter/
    LegacyPLAPIAdapter.{hh,cc}
    LegacyPlacementMetricAdapter.{hh,cc}
```

公共 `SnapshotRef/BranchRef/Scope/DirtySet/InvalidationSet/TypedDelta/ArtifactRef/Status` 必须引用 platform contracts 的唯一 schema，不在 iPL 复制定义。

### 13.2 建议构建目标和依赖方向

```text
ipl-agent-contracts       # pure types/schema; no iDB/PLAPI singleton
ipl-agent-readmodel       # immutable iDB reader + Tech/Intent views
ipl-agent-proposal        # deterministic proposal generators
ipl-agent-delta           # compiler/capture/dirty/inverse
ipl-agent-validators      # placement/frozen validators
ipl-agent-worker          # the only target linking legacy ipl-api/source
ipl-agent-service         # Tool Hub facade; depends on contracts/interfaces
ipl-agent-contract-tests
ipl-agent-integration-tests
```

禁止 `ipl-agent-contracts` 链接 ToolManager、PLAPI、PlacerDB、Tcl 或 evaluation singleton。worker 通过窄接口消费 contracts；service 不直接拿 `IdbBuilder*`。现有 `ipl-api/ipl-source/ipl-module-*` target 保留，直到 legacy compatibility 和新 adapter 双跑门禁完成。

### 13.3 类职责

| 类 | 单一职责 | 禁止职责 |
|---|---|---|
| `PlacementInspector` | selector/page/grid/provenance 归一化 | 修改 PlacerDB/iDB |
| `PlacementDiagnoser` | evidence 到结构化 cause/conflict | 生成无法追溯证据的自然语言结论 |
| `LocalMoveGenerator` | criticality/legal-space 驱动 move proposals | apply 或 commit |
| `SwapReorderGenerator` | compatible window 的 swap/reorder proposals | 隐式扩大对象集 |
| `GlobalCandidateRunner` | budget/progress/incumbent/checkpoint facade | 将 debug dump 冒充 checkpoint |
| `PlacementDeltaCompiler` | proposal/precondition 到 requested TypedDelta | 调 solver 后覆盖 before |
| `PlacementDeltaCapture` | worker before/after 到 actual/inverse/dirty | 信任 target list 代替 diff |
| `IncrementalLegalizerAdapter` | 显式 halo 和 fallback policy 包装 legacy LG | 自动 full fallback |
| `PlacementStructuralValidator` | 分项 placement claims/witness | 输出 QoR 排名 |
| `FrozenPlacementValidator` | before/after frozen complement diff | 只检查 bbox 外对象 |
| `LegacyPlacementWorker` | 隔离 singleton 生命周期/目录/资源 | 持有 base writer 或跨租户复用 |

### 13.4 现有资产迁移表

| CURRENT | 迁移动作 | 删除/收口门禁 |
|---|---|---|
| `PLAPI::runGP/runLG/runIncrLG/runDP` | 先由 worker adapter 调用，再逐步抽 kernel options/progress | legacy Tcl 和 Agent 双跑通过 |
| `Legalizer::updateInstanceList/runIncrLegalize/runRollback` | 包装显式 scope，before/after capture，禁止未授权 full mode | incremental/full differential + frozen tests |
| `LayoutChecker` | 保留 E0 bool；新增分项 result/witness adapter，补缺失 claims | certificate conformance + adversarial fixtures |
| `DetailPlacer`/RowOpt/Swap/Reorder/NFSpread | 从整阶段入口拆出 bounded proposal/action adapters | action-level rollback/metamorphic tests |
| `ExternalAPI` metrics | 经 iEval legacy adapter 补 context/coverage/status | common iEval/iSTA 对拍达标 |
| `IDBWrapper::writeBackSourceDatabase` | 仅在 worker local materialization 使用；正式发布改 TypedDelta | 500 次 branch apply/rollback 零 base 污染 |
| Tcl/PlacerIO | 保留兼容；内部可逐步转 facade | legacy golden/CLI exit semantics 稳定 |
| 注释的 macro placer | 保持 `UNSUPPORTED`，单独 ADR/项目恢复 | 构建、contract、验证、benchmark 全部完成 |
| 注释的 test executable | 建立新的 contract/integration targets，择取可用 fixtures | CI 中真实注册并执行 |

---

## 14. 首批工作流

### 14.1 post-place critical-cell local move

```text
Observer -> timing.top_paths + place.inspect(region)
Planner  -> place.diagnose
iPL      -> propose move/swap/reorder Pareto candidates
Runtime  -> one branch per candidate
iPL      -> apply_delta + legalize_local
Hub      -> placement structural + frozen certificates
iEval    -> F0/F1 screen, survivors F2/F3 timing/congestion
Runtime  -> select; freshness check; CAS commit one or reject all
```

该工作流必须保留 rejected candidate、infeasible evidence、fidelity 升级原因和 selection regret。未找到更优候选是合法 terminal outcome，不允许为了“有结果”放松 hard gate。

### 14.2 iTO resize 后增量合法化

iTO 先在 branch 应用 master delta并产生 dirty instances；iPL 读取新尺寸和 TechContext，检查 row/site/region fit，执行有界 incremental legalize，返回全部 side-effect movement。随后 iTO/iSTA 验证 timing，iEval 比较 QoR。iPL inverse 只覆盖 placement 字段，master inverse 仍归 iTO delta owner。

### 14.3 post-CTS clock-adjacent refine

只在 Intent 明确授权的 clock cells 和邻近普通单元集合上生成候选；iCTS 提供 clock domain/skew context，iSTA 同时验证 setup/hold。iPL structural PASS 不能替代 clock certificate；任一未授权 clock/dont_touch movement 由 frozen validator 拒绝。

---

## 15. 测试、golden、benchmark 与可杀假说

### 15.1 测试分层

| 层 | 内容 | 关键失败判定 |
|---|---|---|
| schema/contract | version、unknown field、enum、unit、page、error mapping | 宽松吞语义字段或裸坐标 |
| unit | selector、interval、proposal、delta compile、dirty/inverse | actual diff 漏对象/字段 |
| property | random legal rows/moves/apply/rollback | hash 不恢复、越域写 |
| golden | 固定微型 DEF/LEF/intent 的 observation/proposal/certificate | stable ID/单位/claim 漂移 |
| metamorphic | 平移、合法镜像、重命名、对象顺序、线程/seed | 不变量或排序无理由变化 |
| differential | local vs full legal/check；incremental vs full metric | 误差/coverage 超资格域 |
| integration | iDB branch + worker + iEval + Hub + Runtime | base 污染、stale evidence commit |
| fault/security | cancel/OOM/crash/corrupt artifact/head conflict/path/tenant | partial 成功、越权、半写 |
| benchmark | QoR、runtime、memory、candidate regret、scope amplification | 只报最好一次或训练集 |

### 15.2 Golden fixtures

| Fixture | 必覆盖 |
|---|---|
| `single_row_gap` | move、site align、inverse、空/非空 interval |
| `fragmented_rows` | blockage、row fragment、局部 infeasible |
| `mixed_width_height` | width/site compatibility、multi-height unsupported/covered 诚实性 |
| `fence_boundary` | region、跨边界 overlap closure、halo cap |
| `fixed_dont_touch` | frozen complement、越权 proposal/apply |
| `swap_reorder_window` | 双方 before、窗口成员集合、actual touched |
| `dense_hotspot` | spread、scope amplification、F0/F2 metric |
| `post_cts_clock` | clock domain、setup/hold scenario、dont_touch |
| `no_local_solution` | blocker witness、INFEASIBLE_LOCAL、显式扩大 |
| `legacy_numeric_lock` | GP/LG/DP/report 的 E0 数值和行为基线 |

Golden 记录 input hashes、tool/kernel/config、seed/thread 和字段容差；不把日志全文或不稳定 wall time 当 golden。

### 15.3 Metamorphic 与 differential

- 整体按 site/row 整数倍平移且 core/constraints 同移，合法性和相对 HPWL 应保持；
- stable ID 保持而 name 重命名，proposal 物理集合不变；
- input object 顺序打乱，确定性模式 result hash 不变；
- 合法水平镜像并正确变换 orientation 后，结构 claim 等价；
- proposal + inverse 后 placement/frozen hash 与 base 相同；
- 将 halo 缩小不能产生比大 halo 更多的授权 touched 对象；
- local no-overlap 与 full checker 对 dirty closure 一致；incremental HPWL/density/iSTA 与 full 结果按预注册 tolerance 对拍；
- legacy adapter 与原 Tcl/API 在同输入上的 E0 输出零语义回归。

### 15.4 故障注入

必须在 materialize、solver 中途、diff、artifact write、CAS 前后、certificate issuance 阶段注入异常。覆盖 cancel race、worker SIGKILL、OOM、磁盘满、CAS conflict、stale checkpoint、缺 tech、evaluation timeout、corrupt manifest、solver 返回 success 但越域移动、`DetailPlacer::checkIsLegal` 假阳性等。断言 base/head、terminal event、artifact 可见性和 status 均符合原子协议。

### 15.5 Benchmark protocol

冻结设计族/PDK/stage/intent/scenario、baseline commit、机器/编译器、线程/seed、cold/warm cache、预算和重复次数；按设计族隔离调参集与 held-out。报告 median/MAD/P95、峰值内存、候选数、actual/requested touched amplification、legalize 成功率、F0/F1 对 F3 rank correlation/regret、增量/full 误差和最终 PPA 向量。失败/超时/OOM 进入分母。

### 15.6 可杀假说

| ID | 假说 | 证伪条件/决策 |
|---|---|---|
| H-PL-01 | local move + bounded legalize 比 full GP 更适合 late timing repair | held-out 中多数 dirty scope 扩散或总成本不低；限制到更晚 ECO 或停止 |
| H-PL-02 | F0/F1 能可靠筛去明显差候选 | 对 F3 top-k recall/regret 未过冻结门槛；禁用该 proxy 路由 |
| H-PL-03 | legacy incremental LG 可封装为严格 scope action | actual touched 频繁越 halo/不可完整捕获；改 kernel 或仅保留 full worker |
| H-PL-04 | dirty metric 与 full metric 足够一致 | 误差超过 per-metric qualification；强制 full 验证 |
| H-PL-05 | worker 隔离使 legacy singleton 可并行候选 | 出现跨 worker 状态/文件污染或吞吐无收益；收紧进程/并发 |
| H-PL-06 | move/swap/reorder 三类动作覆盖 MVP 修复空间 | held-out 成功率低且失败集中于缺失动作；以证据增加 resize/buffer 协作或 exact solver |

门槛数值由 baseline PR 冻结，不能在看到 held-out 结果后反向调整。

---

## 16. 里程碑、PR 切片与完成定义

### 16.1 依赖里程碑

| 阶段 | 交付 | 退出门禁 |
|---|---|---|
| PL-M0 事实/基线 | CURRENT manifest、legacy golden、benchmark protocol | 所有能力标 CURRENT/TARGET，测试真实执行 |
| PL-M1 Contracts | request/observation/proposal/delta/status schema | schema conformance、unknown/partial/error tests |
| PL-M2 Read/Propose | inspector、diagnoser、move/swap/reorder proposal | propose 零状态变化，stable/page/unit tests |
| PL-M3 Branch Apply | delta compiler/capture、inverse、dirty/invalidation | 500 次 apply/rollback 零 base 污染 |
| PL-M4 Local LG | scoped incremental adapter、frozen/structural validators | 越域拒绝、local/full differential、fault tests |
| PL-M5 Evaluation | iEval/iSTA adapters、F0-F3 escalation、certificate DAG | partial 不提交、proxy held-out qualification |
| PL-M6 Anytime | global runner progress/cancel/checkpoint/resume | crash/cancel/replay/determinism 门禁 |
| PL-M7 E2E | iTO/iNO/iCTS/iRT 协同和 Runtime selection | 三个工作流可重放、evidence bundle 完整 |

### 16.2 建议 PR 顺序

1. `PL-PR01`：capability manifest、schema、status/error contract 和 contract tests。
2. `PL-PR02`：immutable read model、stable ID、selector/page/grid provenance。
3. `PL-PR03`：move/swap/reorder proposal generators，证明 propose 零写入。
4. `PL-PR04`：worker isolation、snapshot materializer、legacy output sandbox。
5. `PL-PR05`：PlacementDelta compiler/capture、actual touched、inverse、dirty/invalidation。
6. `PL-PR06`：incremental legalizer adapter、显式 fallback、scope/frozen validator。
7. `PL-PR07`：structural claims/certificate evidence 和 Verification Hub 注册。
8. `PL-PR08`：iEval/common iSTA adapter、incremental-full differential 与 fidelity router。
9. `PL-PR09`：progress/cancel/checkpoint/resume；Nesterov adapter。
10. `PL-PR10`：三个 E2E workflow、fault/security/benchmark suite 和 legacy migration gate。

每个 PR 必须同时包含 contract/test/evidence；不得把“大目录重构”和行为迁移混入同一 PR。按仓库分支规则，该工作属于 `integration/agent-native` 或 `*/agent-*` lane，提交使用 `./dev/branch_commit.sh`。

### 16.3 完成定义

iPL Agent 原生 MVP 只有同时满足以下条件才算完成：

- Agent 可从 immutable snapshot inspect/diagnose，并生成 move/swap/reorder 至少三类 typed proposal；
- proposal 零写入，apply 只发生在 branch，base 在成功/失败/cancel/crash 下均未被改变；
- local legalize 显式遵守 writable scope/halo，返回完整 actual touched、inverse、dirty 和 invalidation；
- structural legality、frozen proof、iEval metric、iSTA/route certificate 类型和 owner 分离；
- F0-F4 实际档位、proxy qualification、partial/unsupported/fallback 全部可见，低 fidelity 不越权提交；
- 500 次 delta apply/rollback、stale/head conflict、worker loss、artifact corruption 和 frozen adversarial 测试通过；
- local/incremental 与 full differential 在冻结 qualification domain/tolerance 内通过，超域自动升级或拒绝；
- 至少一个 post-place timing repair workflow 在 held-out design 上端到端重放，Runtime 能选择或诚实拒绝所有候选；
- legacy `run_placer`/GP/LG/DP/report 兼容面有 golden 数值保护，且新层不依赖自然语言或裸 singleton 指针；
- capability、schema、binary/config/model、context、artifact、certificate 和 journal 足以离线解释每次决定。

仅新增一组 `place.*` 名字并在内部直接调用 `runFlow()`，或只返回“success + 新坐标”，均不算完成。

---

## 17. 开放问题、ADR 与风险

| ID | 问题 | 默认保守决策 | 需要证据 |
|---|---|---|---|
| OQ-PL-01 | legacy incremental LG 是否能稳定限制 actual touched | 默认 worker diff + 越域拒绝 | scope amplification benchmark |
| OQ-PL-02 | multi-height/复杂 fence 的 checker coverage 到何程度 | 未覆盖即 UNKNOWN/UNSUPPORTED | rule-by-rule fixtures |
| OQ-PL-03 | DP kernel 拆成 proposal 与 apply 的最小边界 | 先 move/swap/reorder adapter，不重写算法 | action differential/维护成本 |
| OQ-PL-04 | GP checkpoint 是否跨机器/编译器重放 | 默认只同 ABI/硬件资格域 | round-trip/determinism matrix |
| OQ-PL-05 | learned wirelength ranker 的适用域 | 默认 F1 且 OOD 升级 | family/PDK held-out calibration |
| OQ-PL-06 | macro placement 由 iFP 还是 iPL owner | CURRENT 为 unsupported；另立 ADR | 构建资产、契约和 workflow 边界 |
| OQ-PL-07 | local overlap closure 的最小 halo | 无证明则 full check | adversarial cross-boundary property tests |
| OQ-PL-08 | dont_touch 的唯一语义来源 | Intent/iDB canonical flag，iPL 只消费 | 跨 iTO/iCTS/iPL schema 对账 |

主要风险不是“优化不够聪明”，而是 legacy mutable state 被误当事务、局部 solver 静默扩大范围、metric 被误当 certificate，以及 CURRENT/TARGET 混写造成实现者依赖不存在的能力。本规格用 worker 隔离、actual diff、显式 fallback、类型化验证和可杀 benchmark 将这些风险变成发布门禁。

## 18. 版本历史

- v1.0（2026-07-23）：基于当前 iPL/ToolManager/Tcl/ExternalAPI/CMake/测试源码审计，完整区分 CURRENT 与 TARGET；新增 capability 生命周期、PlacementRequest/Observation/MoveProposal/PlacementDelta、动作/scope/frozen/actual touched/dirty/inverse/invalidation、F0-F4/anytime/cancel/checkpoint/fallback、合法性与 iEval/Verification 分工、事务/worker/失败/安全、跨模块契约、LLD 构建目标、测试/可杀假说、里程碑/PR/完成定义。
