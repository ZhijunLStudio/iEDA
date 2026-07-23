<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 20 · iFP Agent 原生 Floorplan 实施规格 · ai1.1

> 基线：`docs/ai/20-iFP.md`、`12-evaluation-ai1.0.md`、`10-iDB-ai1.0.md`、`43-agent-runtime-ai1.0.md`、`48-intent-scenario-ai1.0.md`、`49-verification-hub-ai1.0.md`、`55-technology-knowledge-ai1.0.md`、`51-53`。本文把 iFP 从 Tcl 风格的过程式命令提升为可检查、可提案、可隔离试验、可验证和可回滚的 floorplan capability；本文的“TARGET”均为待实现规格，不表示仓库已有该能力。
>
> 首个垂直闭环：固定一个已导入的设计 snapshot 和 `FloorplanIntent`，产生 die/core/row/track/IO/macro-constraint 候选，在 Runtime branch 中应用一个冻结的 `FloorplanDelta`，经 iPL/iEval/Verification Hub 评估后仅由 Runtime 选择和提交。iFP 不直接提交主设计，也不把 proxy 当作 signoff。

---

## 0. 目标、边界和原则

### 0.1 目标

iFP 是 Agent 使用的 floorplan 领域服务，而不是 `init_floorplan` 等传统命令的重命名。首版必须让一次 floorplan 决策能回答：

1. **看到了什么？** 哪个 immutable snapshot、哪些 die/core/row/track/IO/macro/blockage/region/PDN 约束，缺了哪些输入；
2. **为什么建议这个候选？** 目标、硬约束、求解/启发式、评分分量、假设、Fidelity、适用域和未覆盖范围；
3. **实际改了什么？** 版本化 `FloorplanProposal` 和可逆 `TypedDelta`，其 declared/actual touched、scope、dirty domain 与 before image；
4. **为什么可继续或不可提交？** 几何/coverage/消费回执、iEval metric、Verification certificate 和明确的 `PASS/FAIL/PARTIAL/UNKNOWN`。

首批范围为二维、单 die、矩形 core、单一 core-site row pattern 的 floorplan 试验。其对象包括：die、core、rows、track grids、signal IO pins、tap/endcap 插入、placement blockages、regions、macro 的**约束**。宏的最终 `(x,y,orient)` 搜索归 iPL；iFP 只能提出/应用版本化 region、halo、channel、orientation 和 edge-affinity 约束，不能伪称已完成 macro placement。

### 0.2 非目标

- 不重写 iDB/iPL/iPDN/iRT/iSTA/iDRC/iEval 的内核；iFP 通过受控 contract 消费它们；
- 不把 `area/utilization`、HPWL、RUDY、early route 或 early PDN risk 解释为 DRC/IR/timing closure certificate；
- 不在 Agent adapter 中直接写 `dmInst`/iDB 主状态，不绕过 `state.apply_delta`、branch lease 或 Runtime commit；
- 不在未资格认证的 multi-height/multi-pattern site、polygonal core、multi-die、3D、power-domain/UPF 复杂 floorplan 上投影成矩形后返回成功；
- 不因可调用 legacy API 就宣称线程安全、可回滚或可并发；
- 不由 Planner token、LLM 文本或 proposal 自行修改 PDK/Intent/PDN policy。IntentPatch 和 TechContext 另有 R4 流程。

### 0.3 责任边界

| 组件 | 拥有 | 明确不拥有 |
|---|---|---|
| iFP（本文） | floorplan inspect/diagnose/propose、floorplan delta 编译、legacy mutation adapter、局部 floorplan 结构检查 | 主分支 commit、宏坐标求解、路由/STA/IR/DRC 真值 |
| iDB（10） | immutable snapshot、stable ID、TypedDelta、transaction、dirty set、rollback | floorplan 候选质量与 Pareto 选择 |
| Runtime（43） | experiment、branch、lease、预算、cancel、select/commit | 几何算法和物理 checker 语义 |
| iPL | macro/global/detail placement、legalization、macro-constraint 消费回执 | 修改 iFP proposal 或把未消费约束视作满足 |
| iPDN | PDN topology/stripe/via/port 的生成和分析入口 | 为 iFP 的几何 proposal 签发 IR/EM clean |
| iEval（12） | metric、Fidelity 路由、比较、Pareto、QoR gate、evidence pack | 设计 mutation、correctness certificate、commit |
| Verification Hub（49） | validator DAG、coverage、certificate 和失效 | QoR 排名、候选生成 |
| Intent/Technology（48/55） | immutable IntentRef/ScenarioSetRef/TechContextRef、qualification | 用隐式默认值替代缺失约束/PDK 语义 |
| Planner（54） | capability-aware PlanGraph 和策略建议 | 数据库写、shell、certificate 或权限提升 |

`metric` 改善、legacy 命令返回 `true`、或某个 checker 未报错，均不等于“floorplan 可提交”。

---

## 1. CURRENT 审计和 TARGET 基线

### 1.1 已核实的源码事实（CURRENT）

| 位置 | 已有能力 | 对 Agent 化的含义和限制 |
|---|---|---|
| `src/operation/iFP/api/ifp_api.h` | singleton `ifp::FpApi`，暴露 `initDie/initCore/makeTracks/autoPlacePins/placePort/autoPlacePad/placeIOFiller/tapCells`，返回 `bool` 或 `void` | 没有 snapshot、request ID、scope、structured diagnostic、transaction、dirty set、inverse 或 cancel；不可直接跨 Agent 边界暴露 |
| `source/module/init_design/init_design.cpp` | die reset/写坐标；按 core site 取整、重置 rows、交替 `FS_MX/N_R0` 建 row；为指定 routing layer 新增 track grids | `initDie` 和 `initCore` 是 destructive global mutation；site/layer 检查不完整，坐标顺序、die/core containment、重复 track 和失败后的状态没有 Agent 契约 |
| `source/module/io_placer/io_placer.cpp` | 基于 core/die 做等间距 pin 及 pad/filler 放置；支持显式 port 几何 | 不是 net-driven assignment，未输出 slot capacity、fixed/group/order conflict、未放置 pin 或 cost；结果写入当前 iDB |
| `source/module/tap_cell/tapcell.cpp` | 根据 placement blockage 分割 row region，插入固定 tap/endcap | 实现可作 legacy 后端，但没有 idempotence、命名冲突、coverage 证据、partial/rollback 语义；该类保存 mutable region/index 状态 |
| `source/module/macro_placer/`、`io_router/` | 目录/CMake target 存在，未见可供 Agent 调用的实现源文件 | 宏坐标搜索和 IO routing 不能列为 CURRENT capability |
| `src/operation/iFP/test/` | 仅 CMake 入口，未见 Agent contract 测试资产 | 需要从 schema、golden、mutation、workflow 基准重新建立 |
| `src/operation/iPDN/api/ipdn_api.h` | legacy PDN API 可创建 IO pin/port、grid/stripe、layer connection、macro connection 和 segment/via | 多为全局过程式 mutation，iFP 只能提交 reservation/anchor hint 给 iPDN；不能自行宣称 PDN feasible 或 IR-safe |

`FpApi` 与 `PdnApi` 都是进程全局 singleton，底层代码使用 `dmInst`。在尚未完成隔离审计和 qualification 前，默认它们**非线程安全、非 reentrant、不可与其他 branch 共享**。CURRENT 的成功/失败信息主要是裸 `bool` 或日志；这不足以表达部分成功、实际触及对象和失效范围。

### 1.2 CURRENT 与 TARGET 的明确分界

| 主题 | CURRENT | TARGET（本文要求） |
|---|---|---|
| 输入 | Tcl/参数和 ambient global DB | `snapshot_ref + IntentRef + ScenarioSetRef + TechContextRef + policy + scope` |
| 读取 | 无统一 inspect/diagnose API | immutable `FloorplanView` 和 structured findings/capability/coverage |
| 提案 | 直接写当前设计 | `FloorplanProposal`，无设计副作用，可多候选、可复放 |
| 写入 | `FpApi` 过程式 global mutation | Runtime branch 上的 versioned `FloorplanDelta` + iDB transaction/inverse/checkpoint |
| 宏 | 无现成 macro placer 接口 | 只输出 iPL 可消费的 macro constraint；坐标决策仍由 iPL |
| 评价 | 无比较/证据接口 | iEval F0-F4 metric bundle、Pareto、升级与 evidence pack |
| 验证 | 命令返回值/日志 | 结构 validator + qualified certificate bundle；skip/unknown 不为 pass |
| 并发 | 未声明 | 读 snapshot 可并发；legacy 写由 worker process/lease 隔离，主分支 commit 串行 |

因此，A0/A1 不得把 `FpApi` 的返回值包装成 `SUCCESS` 后称作 Agent floorplan 完成。任何尚未实现或未资格认证的 TARGET 能力都必须在 capability manifest 中以 `UNAVAILABLE` 或 `UNQUALIFIED` 发布。

### 1.3 首版能力成熟度

| Capability | CURRENT | 首个 TARGET maturity | 允许的 claim |
|---|---|---|---|
| legacy die/core/row/track mutation | E0 过程式写 | E1 branch adapter + structural evidence | `executed_on_branch`，非 legal certificate |
| geometry/row/track/IO inspect | 无统一接口 | E1 typed read model | inventory/coverage，不代表 correctness |
| die/core 候选 | 无 | E2 F0 proposal | “screening candidate”，非可提交 |
| IO assignment | equal spacing legacy | E2 constraint-aware candidate | “assignment proposal”或明确 infeasible |
| macro constraints | 无 Agent schema | E2 iPL handoff schema/receipt | “emitted/consumed”，非 macro placement success |
| tap/endcap | legacy insertion | E2 branch delta + coverage validator | local coverage claim，qualification 前不作 full foundry claim |
| PDN feasibility | legacy generation commands | E1 reservation conflict/risk only | `PARTIAL/UNKNOWN`，非 IR/EM pass |
| F2-F4 portfolio | 无 | E2/E3 依赖 iPL/iEval/Hub | 仅在 consumer/validator qualified 时可用 |

---

## 2. Agent capability 面和调用状态机

### 2.1 对外 capability

所有 API 是 versioned typed service，输入没有裸文件路径、裸指针、ambient current design 或隐式 technology default。`diagnose/propose/verify` 为只读；`apply` 只能由 Runtime 在 branch lease 下触发。

| API | 权限 | 输入 | 结果 | 副作用 |
|---|---:|---|---|---|
| `floorplan.capabilities@1` | R0 | `tech_context_ref`、stage | supported domain、qualified fidelities、limits、fallback | 无 |
| `floorplan.inspect@1` | R0 | `FloorplanReadRequest` | inventory、geometry、coverage、source/ID ledger | 无 |
| `floorplan.diagnose@1` | R1 | read request + diagnostic profile | `FloorplanFinding[]`、conflict set、required evidence | 无 |
| `floorplan.propose@1` | R1 | `FloorplanProposalRequest` | zero or more immutable proposals + Pareto/rationale | 无 |
| `floorplan.compile_delta@1` | R1 | frozen proposal + base/head/scope | `FloorplanDelta` 或 precondition failure | 无 |
| `floorplan.apply@1` | R2 branch only | branch, expected head, compiled delta | new branch snapshot、actual touched、dirty/inverse/evidence | branch write |
| `floorplan.verify@1` | R1 | snapshot/delta + verification profile | structural result、metric/certificate refs、coverage | no design write |
| `floorplan.compare@1` | R1 | same-context base/candidate proposal or snapshot set | comparability/Pareto/escalation result | 无 |

`floorplan.apply@1` 不在 public Planner capability set 中：Planner 只产生 plan node，Runtime 验证 permission、budget、branch、lease 和 expected head 后调用。`FloorplanProposal` 本身永远不能携带 commit permission。

### 2.2 正常工作流

```text
capabilities + context qualification
  -> inspect immutable base snapshot
  -> diagnose missing/contradictory geometry, IO, macro, PDN reservations
  -> propose N frozen FloorplanProposal objects at allowed F0/F1
  -> reject infeasible/unsupported candidates; Pareto-prune only comparable ones
  -> Runtime forks branch and acquires die/core/row/IO/PG-domain leases
  -> compile proposal to FloorplanDelta; validate expected head and preconditions
  -> apply atomically on branch, collect actual touched/dirty/inverse
  -> structural verify (F0) and iPL/iEval/iPDN allowed evaluation (F1-F4)
  -> Verification Hub creates current certificate bundle
  -> Runtime selects exact candidate head or abandons branch
  -> Runtime alone CAS-commits, then invalidates dependent artifacts/certificates
```

任何 context、qualification、policy、base snapshot 或 proposal schema 变化，都中断比较和 apply；必须重新 inspect/propose，而非自动 rebase 高 blast-radius floorplan。

### 2.3 状态和结果语义

```text
PROPOSED -> COMPILED -> APPLYING -> APPLIED -> STRUCTURALLY_VERIFIED
                                      |              |
                                      v              v
                                  ROLLED_BACK   EVALUATED -> READY_FOR_SELECTION
                                                       -> REJECTED | STALE | ABANDONED
```

`STRUCTURALLY_VERIFIED` 只表明请求的几何/结构检查完成，不等于 `READY_TO_COMMIT`。后者由 Runtime 确认 exact branch head 的 current complete certificate bundle 和 policy gate 后才可出现。

| 状态 | 含义 | 调用者必须做什么 |
|---|---|---|
| `SUCCESS` | 请求定义的全部工作完成，coverage 与 provenance 完整 | 不自动等同 commit/pass |
| `INFEASIBLE` | 对声明 domain 已证明硬约束无解 | 返回最小冲突/资源证据；不得输出伪完整候选 |
| `UNSUPPORTED` | feature 超出 qualified domain | 保留 unsupported feature/scope；不得降维假装完成 |
| `UNQUALIFIED` | 后端可调用但 tech/tool/fidelity 无 qualification | 只允许 policy 明示的诊断或 fallback |
| `PARTIAL` | 明确完成的 scope 与未完成部分都已列出 | 不能用于 full validation/gate pass |
| `UNKNOWN` | 输入或分析证据不足，未证明失败/通过 | 升级、补输入或拒绝；不能转零风险 |
| `CONFLICT/STALE` | expected head、proposal base、lease 或 context 失配 | 重新 inspect；高风险 delta 不自动 rebase |
| `CANCELLED` | cancel 在安全点生效，未发布 candidate snapshot | 返回已持久化证据和资源账本 |
| `FAILED_ROLLED_BACK` | apply 失败、base hash 已恢复 | branch 可回到 base，记录失败证据 |
| `CORRUPTED_BRANCH` | rollback/hash/invariant 无法恢复 | Runtime 隔离销毁 branch，禁止 select/reuse |

---

## 3. Context、请求与核心 schema

### 3.1 强制上下文

每个 Agent request 均绑定以下不可变 refs；没有任一 ref 时除纯 inventory 以外返回 `INVALID_REQUEST/PARTIAL`，不能猜默认值。

```text
FloorplanContext
  snapshot_ref             # iDB immutable DesignSnapshot
  intent_ref               # physical constraints, protected objects, power domains
  scenario_set_ref         # IO/timing/power scenarios used by downstream evaluation
  tech_context_ref         # sites, layers, vias, units, rules, library/PDN metadata
  capability_manifest_ref  # actual qualified iFP/iPL/iEval/iPDN/validator combinations
  policy_ref               # proposal, verification, budget and gate profile
  artifact_manifest_ref    # imported floorplan/LEF/DEF etc. hashes, not paths
```

`IntentRef` 变化（例如 protected region、power domain、IO constraint）或 `TechContextRef` 的 site/layer/via/rule/PDN semantic diff，均使旧 proposal、metric、certificate 和 cache 至少 `STALE`；不能把不同 context 的 core area/WL 作 before/after QoR 比较。

### 3.2 FloorplanIntent

```text
FloorplanIntent
  schema_version / intent_id / base_snapshot_ref / context_refs
  scope:
    die_ids, core_ids, row_sets, track_layers, io_pin_ids, macro_ids,
    blockage_ids, region_ids, power_domain_ids
  hard:
    die/core boundary or allowed envelope
    allowed core site/row pattern and manufacturing/site grid policy
    fixed IO/macro/region/blockage objects and frozen object complement
    IO side/segment/layer/direction/capacity/group/order/differential constraints
    macro halo/channel/orientation/region/edge-affinity constraints
    PDN reserved corridors/keepouts/IO anchors/domain separation
    maximum utilization, required placeable capacity, required stages/certificates
  soft:
    utilization/aspect/margin ranges, IO wirelength, macro affinity,
    early congestion/timing/PDN risk, disruption and runtime cost
  budget:
    candidate_count, F0/F1/F2/F3/F4 credits, wall/CPU/RSS/license limits
  policy_refs / provenance / approval_refs
```

`FloorplanIntent` 是 proposal 输入，不是普通 `IntentPatch`。它可以引用已经批准的 physical constraints，但不得在同一 request 中创建或激活新的 SDC/UPF/PDK 语义。无法映射到 stable ObjectId 的任何 fixed/protected object 必须使相应 scope `PARTIAL`。

### 3.3 读模型与诊断结果

```text
FloorplanView
  snapshot_ref / context_refs / view_schema / source_artifact hashes
  die/core: exact DBU rectangles, polygon support status, containment
  sites/rows: site ID, origin, step, orient, count, coverage and gaps
  tracks: layer IDs, direction, start, pitch, count, duplicates/coverage
  IO: stable pin IDs, shapes/layers, fixedness, assigned slots, unplaced list
  macros: master/bbox/status, existing constraints, region/halo/channel refs
  blockages/regions: type, bbox/polygon, owner, power-domain association
  tap/endcap: instance IDs, master, generated provenance, row segment coverage
  pdn_reservations: imported corridor/keepout/anchor refs and coverage only
  capability/coverage/diagnostics

FloorplanFinding
  finding_id / rule_id/version / severity / status
  snapshot/context/scope refs and affected stable IDs/bbox
  observed values + exact units + source evidence
  assumptions/unsupported/uncertainty
  suggested next capability or review action; never an implicit mutation
```

`inspect` 必须保留 exact DBU 整数及 unit source；显示层可附带 micron，但不得只存浮点近似。未加载的 IO、blockage、PDN 或 macro 数据以 `UNKNOWN/PARTIAL` 表达，不能序列化为空集合后作 clean。

### 3.4 Proposal 和候选 schema

```text
FloorplanProposal
  proposal_id = hash(canonical request + generator + seed + base/context refs)
  proposal_schema / producer / generator_version / random_seed
  base_snapshot_ref / expected_head / context_refs / policy_ref
  declared_scope / frozen_scope / preconditions
  actions[]:
    DieCorePlan
    RowPlan
    TrackPlan
    IoAssignmentPlan
    TapEndcapPlan
    MacroConstraintPlan
    PdnReservationPlan
  predicted:
    exact structural values and F0-F4 MetricEstimate[]
    objective vector, hard-constraint outcome, uncertainty, coverage
  rationale:
    inputs, constraint relaxation (must be empty for hard constraints),
    solver trace/artifacts, alternatives considered, assumptions
  required_next_stages / intended_dirty_domains / expiry conditions

MetricEstimate
  metric_definition/unit/value or interval
  fidelity/adapter/model/tool hash/qualification ref
  scope/scenario/coverage/uncertainty/OOD state
  allowed_use = SCREEN | RANK | ESCALATE_ONLY
```

proposal canonicalization 按 stable ID、layer/site ID、几何和 action order 排序。输入容器顺序、无语义 source whitespace 或并行枚举顺序不能改变 proposal hash；真正的 random generator 必须记录 seed、版本和候选 budget。所有 hard constraint 必须为 `PASS/FAIL/UNKNOWN`，不能“用一个很大的 penalty”悄悄违反。

### 3.5 FloorplanDelta：proposal 与实际写入分离

`FloorplanDelta` 是 domain schema，编译后必须落为 iDB `TypedDelta` extension；它不是把 `FloorplanProposal` 原样序列化，更不是 Tcl 字符串。iDB 当前首批 delta 列表未含 floorplan operation，因此以下 operation 是 **TARGET schema 扩展**，必须先经 DB-A 兼容性/transaction 审核实现后才注册 capability。

```text
FloorplanDelta
  operation_id / schema_version / proposal_id / base_snapshot_ref
  expected_head / context_refs / policy_ref / branch_id
  declared_scope / frozen_scope / permissions / preconditions
  operations[] in canonical dependency order:
    ReplaceDieBoundary
    ReplaceCoreAndRows
    UpsertTrackGrid
    UpsertIoPinShapeOrAssignment
    InsertTapEndcapInstances
    UpsertMacroFloorplanConstraint
    UpsertPdnReservation                 # reservation only; no iPDN signoff claim
  before_images / inverse_operations or checkpoint_ref
  declared_touched / actual_touched (after apply)
  spatial_scope / dirty_domains / invalidation_plan
  postconditions / verification_profile_ref / evidence_refs
```

`ReplaceDieBoundary`/`ReplaceCoreAndRows` 是 whole-design/high blast-radius operation：默认只能在 empty/pre-place floorplan stage，且 scope 至少包括 die/core/rows/tracks/IO/macros/blockages/regions/PDN reservation 的依赖闭包。对已有 placement、route、CTS、RC、timing、PDN 的 design，除非 policy 明确允许并有 full invalidation/validation 预算，compile 必须返回 `UNSUPPORTED` 或 `SCOPE_TOO_LARGE`，不能局部改 core 后重用 downstream 结果。

---

## 4. 对象 scope、结构不变量与诊断

### 4.1 Scope 不是一个 bbox

floorplan 的几何与语义依赖跨越 bbox。每个 request/delta 同时声明 object、spatial、layer 和 domain scope：

```text
FloorplanScope
  objects: stable IDs and expected generations
  geometry: die/core/row segment/IO edge/region bbox or polygon
  layers: routing/cut layers and IO layers
  domains: placement, IO, macro, blockage, PDN reservation, timing/route consumers
  scenarios: relevant IO/power/timing scenario IDs
  frozen: explicit protected objects plus complement-of-declared-scope policy
```

一条 core change 的 dirty set 不能只写 `placement`。保守默认是：placement/legalization、IO assignment、tap/endcap、macro constraints、routing/RC/timing、PDN/IR/EM 及它们的 metric/cache/certificate 全部 stale。iDB 提供的 dirty set 是下界，iPL/iRT/iSTA/iPDN/iEval/Hub 可以扩大但不得缩小。

### 4.2 必需结构不变量

| ID | 不变量 | 检查结果/失败处理 |
|---|---|---|
| FP-INV-01 | die/core 坐标有严格正面积、相同单位，core 被 die 包含 | `FAIL`；不取 abs/交换坐标后继续 |
| FP-INV-02 | die/core/IO/region/macro geometry 对齐 declared manufacturing/site/track grid 或有显式允许偏差 | `FAIL/PARTIAL`；记录 exact remainder |
| FP-INV-03 | row site 存在、step/count/orientation 合法，row segment 在 core 内且不与不可放置对象重叠 | `FAIL`；gap/overlap 为 finding |
| FP-INV-04 | track layer 是 routing layer，direction/start/pitch/count 正，重复/冲突 grid 可定位 | `FAIL/PARTIAL`；不通过日志判断 |
| FP-INV-05 | fixed IO、不动 macro、blockage、region、protected object 未被 proposal 覆盖或移动 | `FAIL`；frozen violation 不能由 QoR 补偿 |
| FP-INV-06 | 每个 IO assignment 满足 layer/edge/slot/capacity/shape/non-overlap/group-order hard constraint | `INFEASIBLE/FAIL`；未分配 pin 明列 |
| FP-INV-07 | macro constraint 引用的 macro/master/region/site/PDN reservation 均可解析；冲突可解释 | `CONFLICT/PARTIAL`；不 last-writer-wins |
| FP-INV-08 | tap/endcap master、row segment、spacing、name policy 和 insertion coverage 完整 | local `PASS/PARTIAL/FAIL`；不扩张为 foundry DRC claim |
| FP-INV-09 | proposal 的 declared scope 包含 actual touched；before/after/inverse 完整 | 越域为 `INVARIANT_FAILED` 并 rollback |
| FP-INV-10 | exact branch snapshot 与 context/tech/policy/capability refs 可重放 | 缺任一 artifact 为 `UNVERIFIABLE` |

### 4.3 Diagnose profiles

`floorplan.diagnose` 只产生 finding 和下一步建议，不偷偷执行 `initCore`、打 tap 或移动 IO。首批 profile：

| Profile | 规则和输出 | 不可作出的结论 |
|---|---|---|
| `geometry@1` | die/core containment、grid remainder、row/track inventory、area accounting | 不证明可布线/DRC clean |
| `capacity@1` | movable/macro/halo/blockage/reservation area ledger、utilization interval、row capacity | 不把估算 capacity 当 legal placement |
| `io@1` | fixed/unplaced pin、slot inventory、side/group/order/diff conflict、net centroid coverage | 没有 net/constraint coverage时不报“最优 IO” |
| `macro_handoff@1` | macro constraints 的引用、互斥、region/halo/channel/PDN reservation conflict | 不计算最终 macro coordinate |
| `pdn_reservation@1` | corridor/keepout/anchor 与 core/IO/macro channel 几何冲突 | 不签发 IR/EM/stripe connectivity |
| `readiness@1` | downstream artifacts、qualified capability、required inputs/unknowns | 不以文件存在替代 qualification |

诊断应给最小可解释 conflict set，例如“这 14 个固定 IO 仅允许 top side，而合格 slot 为 12”，而不是只给 `false`。

---

## 5. 候选生成和 Pareto 策略

### 5.1 总体规则

候选生成分为**硬约束可行性**、**多样化生成**、**Fidelity 评估**和**Pareto 筛选**四步。不得以一个未公开加权总分跨越 hard constraint；各 metric 的方向、单位、scope、coverage、Fidelity、uncertainty 和 calibration 必须来自 iEval 的 normalized record。

```text
resolve request/context/capability/qualification
  -> enumerate legal structural seeds
  -> prove/reject hard constraints and deduplicate canonical plans
  -> evaluate allowed F0/F1 features independently
  -> retain non-dominated candidates plus diversity representatives
  -> emit proposal/evidence and required escalation plan
```

候选 A 支配 B 的前提是同一 base/context/policy、同一 required hard-gate state、每个比较 metric 的 scope/scenario/fidelity/coverage 可比较，且所有软目标不差、至少一个严格更好。任意维度 `UNKNOWN/PARTIAL/OOD` 阻断该维支配结论。F0/F1 的结果只能 `SCREEN/RANK/ESCALATE_ONLY`，不得产生 commit winner。

### 5.2 Die/core/row 候选

F0 面积式仅是 seed，不是完成的 floorplan 求解器：

```text
movable_required = movable_cell_area + explicit reserve
fixed_excluded   = macro_area + halo_area + placement_blockage_area
                  + PDN corridor/keepout area + row unusable area
placeable_target = movable_required / target_utilization
core_area_min    = placeable_target + fixed_excluded

enumerate (aspect_ratio, utilization, margins, site) tuples
  -> solve exact width/height interval
  -> snap according to declared site/manufacturing policy
  -> construct rows and subtract fixed/blockage/reservation segments
  -> compute actual usable row capacity and account rounding loss
  -> reject infeasible geometry; canonicalize/deduplicate survivors
```

四类 area 必须独立报告：physical core、raw rows、placeable rows、movable demand。禁止把 macro/halo/blockage/PDN corridor 双重扣除或忽略。若 `TechContext` 没有 qualified site/unit mapping，或 row pattern 不在 capability domain，返回 `UNQUALIFIED/UNSUPPORTED`，不得靠旧的 `initCore` 自动交替 row 当作“兼容”。

### 5.3 IO assignment 候选

先由 `IoSlotEnumerator` 将每条允许 edge 离散为 typed legal slot：`{edge, segment, layer, direction, coordinate, shape limit, capacity, keepout, fixed owner}`。固定 IO 先占 slot；所有可移动 IO 必须保留 stable ID 和 net/group/differential/order/side constraint。

```text
validate fixed pins and reserve their slots
  -> build bipartite assignment or min-cost-flow graph
  -> hard-filter unavailable edge/layer/order/group/differential constraints
  -> cost = declared net-centroid distance + bus/order penalty + congestion/PDN risk proxy
  -> solve, enumerate k diverse feasible assignments, canonicalize
  -> return assignment, per-pin cost, unassigned pins and conflict evidence
```

`autoPlacePins` 的等间距算法可在 A2 中成为一个 deterministic baseline generator，但其输出必须先转为 slot assignment proposal，再经同一 structural validation；不得把“legacy 写成功”当成合格候选。无完备匹配时可返回 `INFEASIBLE` 和最大可行 partial assignment 用于诊断，但 `PARTIAL` 绝不能伪装为完整 `IoAssignmentPlan`。

### 5.4 Macro、blockage、region 和 PDN reservation

iFP 产出以下**约束**，不产出 macro location：

```text
MacroConstraintPlan
  macro_ref / allowed_region_refs / forbidden_regions
  allowed_orientations / fixedness
  halo per side / channel requirements
  edge or IO affinity / relative-order or separation constraints
  power_domain_ref / PDN corridor and connection-anchor reservations
  provenance, priority, hard-or-soft, conflict policy
```

冲突以 schema rule 处理：同一 macro 同时有相交为空的 hard region、相互排斥 orient，或 channel 与 immutable blockage/PDN corridor 冲突时返回 `CONFLICT/INFEASIBLE`，禁止“最后一条覆盖前一条”。iPL 消费后必须返回 `consumed_constraint_ids / ignored / unsupported / actual touched / expansion`。任何 hard constraint 未消费、默认化或被 iPL 扩大 scope，都会使候选停在 `PARTIAL` 并要求重新 verification；不能因 placement metric 看似好而忽略。

`PdnReservationPlan` 仅保留 floorplan 层面的 corridor、keepout、macro-connection anchor、IO pad/port reserve 和 domain separation。它必须由 TechContext 的 layer/via/power-domain metadata 支持；否则为 `UNKNOWN/PARTIAL`。iPDN 可把 reservation 转成自己的 proposal，但 iFP 不调用 legacy `createGrid/createStripe` 在主状态产生隐式 PDN。

### 5.5 Tap/endcap 和 row blockage

`TapEndcapPlan` 先对 row segment 做纯计算：受 placement blockage、fixed macro、reserved corridor 切分后的 segment，所需 endcap/tap 数、spacing、orientation、master 和 deterministic name allocation。编译时生成 `InsertTapEndcapInstances` operations，而非让 legacy adapter 自由创建不可预测名称。

初期可在 isolated legacy worker 中调用 `TapCellPlacer`，但 adapter 必须对 before/after 做 typed diff，并拒绝下列情况：actual touched 超 scope、生成对象无法稳定映射、重复调用不具幂等/明确 replacement policy、覆盖 checker 不可运行。旧实现对 site width 对齐 spacing 的截断必须在报告中显式记录 requested/effective spacing；若有效 spacing 不满足 hard policy，返回 `FAIL` 而非静默向下取整。

---

## 6. Fidelity、回退和升级

### 6.1 F0-F4 定义

Fidelity 是成本/证据等级，不是成功等级。某个实现可运行而无 qualification 时，应返回 `UNQUALIFIED`，不可将其升格为 F2/F3。

| Fidelity | iFP 输入/后端 | 允许用途 | 明确禁止 |
|---|---|---|---|
| F0 | exact geometry/site/row/slot/area checks；deterministic die/core/IO seeds；约束冲突 | 可行性筛除、结构诊断、候选多样化 | timing/congestion/PDN/DRC clean 或 commit |
| F1 | 经过 held-out 校准的 HPWL/IO distance、density/RUDY、macro/IO/PDN reservation risk proxy | candidate ranking 和 Top-K 筛选 | 跨 hard gate、无校准 extrapolation |
| F2 | qualified iPL global placement/local legalization、iRT early GR 或等价受控 adapter、iPDN topology feasibility、iEval compare | 缩小 portfolio、识别拥塞/时序/PDN 风险和 scope expansion | signoff certificate 或 full-chip closure |
| F3 | policy 要求的 full placement/route/STA/PDN/DRC 分析及 Verification Hub claim bundle | final selection 的 QoR/required correctness evidence | 代替 F4 foundry/commercial signoff |
| F4 | qualified external/foundry/commercial oracle，走 57 External Tool Bridge | 发布/signoff policy 所要求的外部证据 | 未安装/未资格认证时伪造结果 |

首版实际 availability 由 `floorplan.capabilities` 以 `(tech_context, tool binary, fidelity, stage, feature)` 发布。例如当前 repo 的 iFP 只能作为 E0 legacy mutation backend；F1-F4 是 target integration，不能硬编码为“已支持”。

### 6.2 Fidelity router

```text
request metric/check
  -> verify context, stage, scope and TechContext qualification
  -> select registered adapter with manifest coverage
  -> check budget and required minimum fidelity
  -> run or return explicit degradation/escalation requirement
  -> emit actual fidelity, adapter/model/tool hash, inputs and coverage
```

以下条件必须升级到 F2/F3 或返回 `INCOMPLETE`：候选在 F0/F1 Pareto frontier；metric interval 跨越 policy gate；proxy OOD/没有校准；触及 clock/reset/power-domain/PG anchor/frozen region；iPL 消费约束扩大 scope；F0/F1 与最近高保真方向冲突；policy 声明必须 full verification。预算不足时返回保留候选及所缺检查，不能制造一个“winner”。

### 6.3 回退纪律

| 不可用项 | 允许回退 | 不允许伪装 |
|---|---|---|
| iPL macro consumer 未实现/未 qualified | 只输出 macro constraint proposal 和 `PARTIAL` handoff | “macro placement 已完成” |
| net/IO group data缺失 | fixed-pin inventory 或 equal-spacing baseline with `UNKNOWN` quality | net-driven IO optimum |
| iRT early GR artifact 缺失 | F0 geometry + F1 calibrated proxy（若 qualified） | congestion=0/no overflow |
| iPDN 无 topology/IR capability | reservation conflict diagnosis | IR/EM feasible 或 power clean |
| external F4 不可用 | 停在 F3/`INCOMPLETE`，由 policy 拒绝 release | 将 internal proxy 当 signoff |
| legacy worker 不可隔离 | 禁止 branch mutation，仅 inspect/propose | 在共享 singleton 并行 apply |

---

## 7. Branch apply、dirty/invalidation 与 rollback

### 7.1 编译前检查

`compile_delta` 先在 immutable base view 运行，必须验证：proposal hash/expiry、schema、base snapshot/expected head/context/policy/capability、stable IDs/generations、scope/frozen objects、hard constraints、required TechContext objects、branch permission/lease reservation 和预估 budget。任何失败都不启动 legacy mutation。

```text
validate frozen FloorplanProposal
  -> resolve stable IDs and precondition fingerprints
  -> calculate dependency closure and requested leases
  -> build canonical domain operations + inverse/checkpoint strategy
  -> validate declared scope/dirty superset
  -> persist compiled delta artifact
  -> return delta_ref or structured failure
```

proposal 中的 `expected_head` 是 compile/apply 的强前置；head 前进、context drift、lease fencing generation 改变时返回 `STALE/CONFLICT`。floorplan 不自动 rebase，尤其不在 apply 前重新计算 coordinates 却仍复用旧评分。

### 7.2 原子 apply 算法

```text
Runtime forks branch from exact base snapshot and acquires branch/domain leases
  -> iDB validates expected_head, permission, delta schema and preconditions
  -> capture before images or durable checkpoint before first mutation
  -> create isolated legacy worker/session bound only to branch materialization
  -> apply operations in canonical order:
       die/core -> rows -> tracks -> regions/blockages/reservations
       -> IO -> macro constraints -> tap/endcap
  -> collect actual typed diff and tool receipts
  -> reject actual_touched outside declared scope
  -> rebuild required indexes and run structural invariants
  -> compute conservative dirty set and invalidate dependent results
  -> persist delta/inverse/check/artifact hashes
  -> publish new branch snapshot with CAS(expected_head)
  -> on any failure/cancel: rollback; verify base hash; report evidence
```

多 operation delta 是 all-or-nothing：任何第 k 步失败都不得保留半 die、半 rows、半 IO 或部分 taps 为成功 snapshot。若 legacy backend 无法提供可证明的 inverse，A4 必须使用 full branch checkpoint；未满足时 capability 不发布 `apply`。

### 7.3 Dirty set 和 certificate 失效

| Delta 类 | 最小 dirty/invalidation 闭包 | 可能需要的扩大 |
|---|---|---|
| die/core/rows | geometry、rows/sites、placement/legalization、IO、tap/endcap、macro constraint、route/RC/timing、PDN/IR/EM、所有相关 metric/certificate | full design，除非各 consumer 给出保守局部证明 |
| track grid | routing resource、IO shape/layer、GR/route/DRC/RC/timing、PDN layer reservation | layer/domain 全局 |
| IO assignment/shape | IO geometry、connected nets HPWL/placement/route/RC/timing、IO DRC/PDN anchor | connected timing/clock/power domain |
| macro constraint | macro placement、blockage/capacity、congestion/route/RC/timing/PDN | iPL scope expansion 后重新取 closure |
| tap/endcap | placement legality、row capacity、power connectivity/DRC 相关检查 | full rows/core if generated names/masters conflict |
| PDN reservation | macro/IO feasibility、PDN topology、route congestion、IR/EM certificate | power domain/adjacent domains |

`dirty_scope_unknown` 时采取 full invalidation 或 `INCOMPLETE`，绝不能空 dirty set。certificate 失效由 Verification Hub 的 versioned invalidation DSL 计算；iFP 提供 delta kind、actual touched、spatial/layer/domain scope 和 consumption receipts，不自行标记旧证书为“仍有效”。

### 7.4 Cancel、失败和恢复

cancel 安全点在 operation 之间、legacy worker 结束后、CAS publish 前。Runtime 取消时不得杀死仍在写共享主状态的 worker；因此 A4 前的 worker 架构必须让 mutable database materialization 仅属于 branch workspace。cancel 后：

- publish 前：rollback/hash check，结果 `CANCELLED` 或 `FAILED_ROLLED_BACK`；
- publish 后：snapshot 已是 candidate history，Runtime 只能 abandon，不可伪造“从未发生”；
- rollback hash 不等：`CORRUPTED_BRANCH`，销毁 branch，保留 checkpoint/log/artifact hash；
- worker crash/timeout：不根据遗留日志判断成功，重新 materialize from durable checkpoint 后检查；
- storage/artifact hash failure：不更新 catalog/head，返回 `STORAGE_ERROR/UNVERIFIABLE`。

---

## 8. 验证、评价和跨工具契约

### 8.1 iFP 自有结构验证与 certificate

iFP 的 structural validator 输出 raw structured result；只有 Hub 中注册且 qualified 的 validator 可签发 certificate。首个 floorplan policy 至少要求如下 claim，实际 scope/tech/rule coverage 进入 certificate identity：

| Claim | 生产者 | 最小 scope | 说明 |
|---|---|---|---|
| `state.integrity` | iDB/Hub | candidate snapshot | snapshot、delta、actual touched、hash 完整 |
| `floorplan.geometry.valid` | iFP structural validator | die/core/rows/tracks declared scope | FP-INV-01 至 FP-INV-04；不是 route DRC |
| `floorplan.io.assignment.valid` | iFP + qualified IO rule adapter | requested IO pins/slots/layers | fixed/group/order/capacity/shape coverage 必须可见 |
| `floorplan.tap_endcap.coverage` | iFP validator | declared row segments/master rules | 只能按 tool/rule coverage 声明 local/full |
| `objects.frozen` | Hub state validator | complement of declared scope | 不能由 iFP 自签 |
| `macro.constraints.consumed` | iPL receipt validator | exact constraint IDs and candidate snapshot | emitted 不等于 consumed |
| `placement.legal` | iPL/qualified checker | policy 指定 region/full design | iFP row valid 不蕴含 placement legal |
| `pdn.reservation.consistent` | iPDN/geometry validator | power-domain reservation scope | 不蕴含 IR/EM clean |

每张 certificate 绑定 `subject_snapshot + intent/scenario/tech/policy refs + validator qualification + scope/coverage + raw artifact hash`。`UNKNOWN/PARTIAL/SKIPPED` 不可升级为 `PASS`。full claim 与 incremental claim 不可因名字前缀相互替代。

### 8.2 iEval 契约

iFP 不生成自己的隐式 QoR score。对每个 candidate，向 iEval 传入 exact base/candidate snapshot、proposal/delta、context、stage、scope、requested metric/Fidelity 和 budget。iEval 返回 `MetricBundle`、comparability、calibration/OOD、Pareto/escalation 和 evidence pack。

建议的 floorplan metric vector（具体可用性以 registry/qualification 为准）：

```text
hard/structural: geometry, row/track, IO, frozen, macro-consumption, reservation coverage
soft/F0-F1: core area, usable utilization, IO HPWL proxy, macro/IO distance,
            density/RUDY risk, PDN reservation conflict/risk, disruption/cost
F2+:       iPL density/legalization feasibility, GR overflow/resource, timing proxy,
            PDN topology result, actual route/RC/STA/IR/DRC when policy permits
```

F0 area 或 F1 RUDY 优势均不能抵消 `objects.frozen`、IO hard failure、缺 required scenario/rule、hold/DRC/IR failure 或 incomplete certificate。iEval 的 `GateEngine` 是 QoR policy 判断者；Hub 是 correctness claim issuer；Runtime 是唯一 commit authority。

### 8.3 iPL handoff

| iFP -> iPL | 必须字段 | iPL -> iFP/Hub receipt |
|---|---|---|
| `MacroConstraintPlan` | stable macro/master IDs、region/halo/channel/orient/affinity、hard/soft、context/version | consumed/ignored/unsupported IDs、actual macro/placement scope、constraint conflict、tool/config hash |
| floorplan geometry | candidate snapshot ref，不传 mutable pointer | read snapshot ref、observed rows/blockages/regions、scope expansion |
| candidate policy | allowed stage/fidelity/budget/frozen set | actual parameters、seed、artifact/metric refs |

iPL 不得从 ambient main DB 偷读与 candidate snapshot 不一致的 rows/IO。若 iPL 因合法化扩展 region、移动 frozen object，或忽略 hard macro constraint，必须返回 structured evidence；Runtime 使原 candidate `PARTIAL/FAIL` 并重新规划，而非采纳扩大改动。

### 8.4 iPDN handoff

iFP 向 iPDN 交付 reservation/anchor plan、power-domain IDs、IO/macro stable IDs、die/core/row geometry snapshot、layer/via references和 coverage。iPDN 返回实际消费的 reservation、冲突/unsupported、拓扑 proposal 或分析 artifact；在 legacy `PdnApi` 只提供 global mutation 的期间，调用必须经 branch worker adapter。

PDN 语义至少区分：`reservation geometrically consistent`、`topology generated`、`connectivity checked`、`IR analyzed`、`EM analyzed`。前一级不蕴含后一级。activity、voltage、temperature、via current limit 或 required rule coverage 缺失时，只能 `PARTIAL/UNKNOWN`。

### 8.5 Intent、Technology、Planner、Runtime 和 External Tool Bridge

- **Intent（48）**：iFP 消费 physical regions, protected objects, IO constraints, power domains 和 signoff scenarios；返回 `consumed_intent_ids/skipped/unsupported/defaulted`。不能因 tool 私有 default 绕过 ledger。
- **Technology（55）**：iFP 消费 DBU、manufacturing grid、site/row、routing/cut layer、via、IO master、tap/endcap master、power/PDN metadata；返回 `consumed_tech_ids/hits/misses/defaults`。未 qualified 的 PDK 解析能力不得声称 F2/F3。
- **Planner（54）**：只从 capability registry 选择 `inspect/diagnose/propose` node 和合法 action schema；它不生成坐标字符串、shell 命令、commit/certificate，也不靠 LLM 选择未注册 tool。
- **Runtime（43）**：固定 experiment base/context/policy，分配 candidate/branch budget 和 lease，执行 apply/verify DAG，记录 decision trace；iFP 不能 fork/commit 自己的 branch。
- **External Tool Bridge（57）**：F4 或外部 macro/PDN oracle 仅经固定 argv、input/output manifest、timeout/cancel、normalizer 和 sandbox 运行；iFP 不解析自由文本日志作为 pass，也不向外部 process 暴露主工作目录。

---

## 9. 并发、隔离和安全

### 9.1 并发模型

```text
immutable FloorplanView/inspect/diagnose/propose: parallel, snapshot-bound
legacy iFP/iPDN mutation: one isolated worker session per branch; no shared singleton
same branch write: serialized by branch lease and expected_head CAS
different branches: parallel only after workspace/process/resource qualification
main snapshot commit: Runtime serial CAS
```

由于 CURRENT iFP/iPDN 使用 global singleton 和 `dmInst`，首版不得在同一进程为两个 branch 并发调用 `FpApi/PdnApi`。最保守实现是 branch materialization + child worker process；worker 只获得最小 read-only input manifest 和 branch-private writable workspace，输出 typed diff/artifact manifest，不能直连主 SnapshotCatalog。若 process isolation 暂不可用，A4 前只开放 read/propose，不开放 Agent `apply`。

### 9.2 Lease 和冲突

lease 至少包含 `branch-write`、die/core、row-set、IO edge/slot、macro/region、track layer、PDN domain 和 high-risk semantic domains。region 不相交也可能通过同一 net、macro halo、row capacity、clock/power domain 产生语义冲突；Runtime 的 conflict detector 必须取 object/spatial/domain 并集。首版不自动 merge floorplan candidates。

worker 返回 `actual_touched` 后，Runtime/iDB 与 lease/declared scope 对账。越域写、main snapshot 触及、额外 artifact path、未声明网络访问或 license 用量异常，均使 candidate fail/isolated。branch 用完销毁临时 materialization，但 evidence/CAS manifest 按 retention policy 保留。

### 9.3 可重放与供应链

proposal、delta、worker input/output、legacy binary/config、TechContext、generator seed、external tool image、policy、certificate、metric和artifact都内容寻址。绝对路径、mtime、进程地址和随机临时名不得进入 semantic hash。legacy tool 的输出若依赖未捕获环境变量/当前目录，capability 必须降为 `UNQUALIFIED`，直到 manifest 补齐。

---

## 10. LLD、源码落点和类边界（TARGET）

### 10.1 目录和构建目标

不移动或复制现有 iFP kernel；在其上新增薄 Agent 层。文件名沿现有 iFP 的 `.h/.cpp` 习惯，transport-neutral schema 可与 platform 的统一编码适配。

```text
src/operation/iFP/
  api/
    ifp_api.{h,cpp}                         # CURRENT legacy facade; behavior kept compatible
    floorplan_agent_api.{h,cpp}             # TARGET typed public facade, no dmInst exposure
  agent/
    floorplan_request_validator.{h,cpp}
    floorplan_capability_registry.{h,cpp}
    floorplan_snapshot_reader.{h,cpp}
    floorplan_inspector.{h,cpp}
    floorplan_diagnoser.{h,cpp}
    geometry/{area_ledger,row_builder,track_planner}.{h,cpp}
    io/{io_slot_enumerator,io_assignment_generator}.{h,cpp}
    macro/{macro_constraint_builder,macro_handoff_receipt}.{h,cpp}
    pdn/{pdn_reservation_planner,pdn_handoff_receipt}.{h,cpp}
    tap/{tap_endcap_planner,tap_coverage_checker}.{h,cpp}
    proposal/{proposal_canonicalizer,pareto_frontier}.{h,cpp}
    delta/{floorplan_delta_compiler,floorplan_dirty_mapper}.{h,cpp}
    verify/{floorplan_structural_validator,consumption_ledger}.{h,cpp}
    adapters/{legacy_fp_worker_adapter,ipl_adapter,ipdn_adapter,ieval_adapter,verification_adapter}.{h,cpp}
  schema/
    floorplan_context.h
    floorplan_intent.h
    floorplan_view.h
    floorplan_proposal.h
    floorplan_delta.h
    floorplan_result.h
  test/agent_floorplan/
  CMakeLists.txt                             # target ifp_agent; explicit dependencies only

benchmarks/floorplan/
  schemas/{intent,proposal,delta,view,result}.json
  fixtures/ protocols/ manifests/ reports/
```

`ifp_agent` 依赖 platform 的 DesignView/TypedDelta/Runtime/Technology/Intent/Verification public facade 和 iEval/iPL/iPDN adapter interface，不得 include iDB `DeltaApplier` 私有头或把 legacy singleton 暴露给 Planner。现有 `ifp_api` 继续为历史 flow 服务；任何修复先有 its legacy regression，Agent 代码不复制其几何实现。

### 10.2 核心类职责

| 类/模块 | 输入/输出 | 必须做 | 禁止做 |
|---|---|---|---|
| `FloorplanAgentApi` | typed request/response | version/permission/facade 边界 | 返回裸 bool/pointer 或直接 commit |
| `FloorplanRequestValidator` | refs/scope/policy | context、ID generation、capability、budget、schema校验 | 猜 site/layer/scenario/default path |
| `FloorplanSnapshotReader` | immutable DesignView | stable typed inventory、unit/source ledger | 读取 ambient `dmInst` 当 snapshot |
| `FloorplanInspector/Diagnoser` | view/profile | findings、coverage、conflict evidence | mutation 或 QoR pass |
| `AreaLedger/RowBuilder/TrackPlanner` | intent + tech | exact accounting、legal seed、rounding evidence | 以浮点/abs 隐藏非法输入 |
| `IoSlotEnumerator/AssignmentGenerator` | IO/constraints | typed slots、feasibility、deterministic k candidates | 调 legacy auto place 写 DB |
| `MacroConstraintBuilder` | macro/region/PDN hints | versioned hard/soft constraints | macro coordinate solver/最后写入覆盖 |
| `PdnReservationPlanner` | technology/domain/geometry | reservation scope/conflict | IR/EM claim 或 direct main PdnApi mutation |
| `FloorplanDeltaCompiler` | frozen proposal | canonical operations/preconditions/inverse/dirty declaration | 直接修改 DesignView |
| `LegacyFpWorkerAdapter` | branch materialization + operation | one worker/session, typed diff, controlled legacy call | shared singleton, undeclared file/DB access |
| `FloorplanStructuralValidator` | candidate view | per-invariant raw result/coverage | 签 certificate/掩盖 skipped |
| `ConsumptionLedger` | iPL/iPDN/tech/intent receipts | actual consumer reconciliation | 假设 adapter 已使用所有 input |
| iEval/Hub adapters | exact refs/artifacts | invoke public contracts, surface status | 自定义 QoR/certificate semantics |

### 10.3 Legacy adapter 渐进策略

1. **FP-A0/A1**：只读 adapter 从 `DesignView` 建 view；不得以 CURRENT global DB 作为独立事实源。
2. **FP-A2**：把 F0 die/core/IO/tap plan 转为 proposal；legacy `autoPlacePins/tapCells` 仅为 branch-only baseline generator，先/后 diff 必须可解释。
3. **FP-A3**：`FloorplanDeltaCompiler` 与 iDB floorplan TypedDelta extension 一起实现；无 checkpoint/inverse 的 legacy operation 不能登记可 apply。
4. **FP-A4**：process-isolated `LegacyFpWorkerAdapter`、cancel/crash/rollback/actual-touched 证据；在压力与 failure-injection 通过前不提高并发。
5. **FP-A5+**：逐项把成熟 legacy 数据构造替换为 snapshot-bound implementation；只有完整对拍后才能改变默认 backend。

对 `InitDesign::initDie/initCore/makeTracks` 的输入顺序、null/return 处理、row/track reset/duplicate 行为应先以 legacy contract 测试锁定，再修复并版本化 capability。不可在 Agent 层“补一个 if”后声称 legacy 行为已安全。

---

## 11. 测试、基准和可杀假说

### 11.1 测试分层

| 层级 | 用例 | 必须锁住的行为 |
|---|---|---|
| L0 schema/unit | canonical hash、DBU、enum、proposal/delta precondition、Pareto | `UNKNOWN/PARTIAL` 不变成 zero/pass；单位/ID mismatch 拒绝 |
| L1 geometry | die/core/row/track/area/slot/tap pure functions | 负面积、rounding、gap、overlap、blockage切分有精确 evidence |
| L2 contract | request/context/capability/receipt/status | 缺 intent/tech/scenario、unqualified adapter、未消费 hard constraint 响亮失败 |
| L3 state | branch apply/inverse/checkpoint/dirty/cache | 失败/取消后 base hash 恢复；actual touched 不越 scope |
| L4 adapter | legacy iFP/iPL/iPDN/iEval/Hub public facade | CURRENT 数值/副作用对拍；无 ambient artifact/单例泄漏 |
| L5 workflow | inspect -> propose -> branch -> verify -> select | 未过 complete bundle 永无 commit path；20 branch 互不污染 |
| L6 benchmark | smoke/daily/weekly/scale/holdout/F0-F4 | regret、false-negative、coverage、成本和可重放结果按分桶报告 |

### 11.2 Golden fixtures

`benchmarks/floorplan/fixtures` 至少包含：

- 最小矩形 die/core 和精确 DBU/site/grid 手算例；
- non-square core、奇偶 row、site rounding、row origin/orientation 例；
- macro halo/channel、placement blockage 与 PDN corridor 交叠/相邻/完全覆盖例；
- fixed/unfixed IO、corner/side/layer、bus order/differential/group、slot容量不足例；
- 多个 tap/endcap master、blockage 切分 row、间距不可整除和名字冲突例；
- 具有 known overflow/timing/PDN-risk 特征的 holdout designs，分别按 PDK/design family/stage 切分；
- unqualified multi-height/multi-pattern/polygonal/multi-die fixture，断言 `UNSUPPORTED`，不是错误矩形化。

golden 必须保存 input manifest、expected typed view/proposal/delta/finding、tool/config/binary hash 和允许的 numeric tolerance；大工件进入 CAS，只在仓库保存 manifest。

### 11.3 Metamorphic、differential 和 adversarial

| 类别 | 注入 | 断言 |
|---|---|---|
| metamorphic | source/constraint 无语义重排、stable object rename、候选枚举并发顺序变换 | canonical proposal/view hash 与 Pareto 结果不变 |
| metamorphic | 全设计平移且相应固定 geometry 一同平移 | topology/relative area/IO assignment结构不变，绝对坐标按规则变化 |
| differential | legacy `initCore/makeTracks/autoPlacePins/tapCells` 在同一 branch materialization 与 controlled baseline 对拍 | typed diff 与 legacy实际副作用相同；差异必须有批准的 migration record |
| differential | F0/F1 rank 与 F2/F3 oracle 按 design/PDK/action 分桶 | 输出 Recall@K、selection regret、sign accuracy、MAE/P95/ECE/OOD，不只报平均值 |
| adversarial | 坐标交换/overflow、DBU 与 micron 混用、缺 site/layer/master、重复/冲突 tracks | 返回明确 failure，不破坏 branch |
| adversarial | 空/歧义 stable ID、stale head、context/policy/qualification drift | compile/apply/compare 不复用旧 proposal/certificate |
| adversarial | scope 外 mutable object、iPL 忽略 hard constraint、worker 写 ambient output | lease/receipt/ACL 检查 fail，candidate 无 commit |
| adversarial | worker timeout/crash/cancel/磁盘满/checkpoint hash 损坏 | 无半提交；正确 `CANCELLED/FAILED_ROLLED_BACK/CORRUPTED_BRANCH` |

### 11.4 Benchmark protocol

每个结果记录 protocol/version、input/build/artifact manifest、PDK/design family/stage、generator/tool/model hash、seed、机器配置、budget、Fidelity、coverage和重复统计。性能至少五次重复报告 median/MAD；不得将 F0 与 F3 wall time 或不同 PDK/scene 的 metric 混成单一平均数。

F1/ML/proxy 校准采用 design family、PDK、stage、macro/IO/PDN topology 分组的 holdout。相同 netlist 的相邻 snapshot、派生候选或不同 seed 不能同时在 training 和 holdout。基准成败指标至少有：

```text
correctness: rollback mismatch, scope escape, certificate invalidation miss
decision: Recall@K, selection regret, hard-gate false negative, direction accuracy
quality: usable capacity, IO WL, congestion/timing/PDN delta at oracle fidelity
coverage: unsupported/partial/OOD rate, consumer receipt completeness
cost: wall/CPU/RSS/license/F2-F4 credits, cancellation saving
replay: proposal/delta/certificate/decision trace replay success
```

### 11.5 可杀假说

| 假说 | 受控实验 | 被否时的动作 |
|---|---|---|
| H-FP-A1：F0 structural generator 可快速排除不可行 die/core/IO 候选且不漏 hard violation | 与独立 geometry/slot oracle、人工手算 fixture 对拍 | 收紧 domain/修正 schema；不把 F0 继续用于自动筛除 |
| H-FP-A2：constraint-aware IO 相对 equal-spacing baseline 可降低 held-out post-place IO WL，且不增加 hard conflict | 同预算、同 base/context 下 paired portfolio，F2/F3 比较 | 保留 deterministic baseline；分析 net/constraint coverage，不宣称净改善 |
| H-FP-A3：F1 proxy 能减少 F2/F3 次数且 selection regret 可控 | 全 F3 与 screen-then-escalate 按 PDK/design family 比较 | 缩小校准域、提高 Top-K/升级率，绝不放松 hard gate |
| H-FP-A4：macro/PDN reservation handoff 可降低 downstream conflict | iPL/iPDN consume receipt 与无 reservation baseline 对比 | 修 schema/consumer 或停止把 reservation 用作 ranking feature |
| H-FP-A5：branch worker 可隔离 legacy singleton mutation | 并发 branch、crash、cancel、hash/FD/path leak 注入 | 退回串行 process 或禁用 apply；不可依靠 mutex 口头证明隔离 |
| H-FP-A6：局部 dirty/incremental validation 足够安全 | incremental 与 full F3/fresh reload 随机抽检 | 扩大 scope 或禁用该 delta 类的增量复用 |

---

## 12. 里程碑、PR 切片和完成定义

### 12.1 依赖顺序

iFP 的可写闭环依赖 `10` snapshot/transaction/TypedDelta、`43` branch/lease/budget、`48/55` context/qualification、`49` certificate、`12` evaluation。依赖未达到相应门禁时，可交付只读/提案能力，但不得伪装为可提交 floorplan。

| 阶段 | 周期 | 交付 | 退出门禁 |
|---|---:|---|---|
| FP-A0：事实冻结 | 2 周 | legacy API/caller/side-effect 台账、CURRENT behavior fixtures、capability manifest skeleton | 每个 legacy mutation 的 global side effect、输入单位、失败模式、并发未知项可追溯 |
| FP-A1：读模型与契约 | 3 周 | context/request/view/finding/proposal schema、snapshot reader、inspect/geometry diagnose | 缺 ref/unit/coverage 必拒绝；10 个 fixture view/hash 稳定 |
| FP-A2：F0 proposals | 4 周 | area/row/track/IO slot generator、macro/PDN reservation schema、Pareto/canonicalization | 100 候选无状态污染；hard infeasible 有 conflict evidence；legacy baseline 对拍 |
| FP-A3：消费与评价 | 4 周 | iPL/iPDN/iEval adapters、consumption ledger、F1 qualification harness | 未消费 hard constraint/不同 context/缺 calibration 无 selection path |
| FP-A4：branch mutation | 5 周 | DB floorplan delta extension、compiler、isolated legacy worker、checkpoint/inverse/cancel/dirty map | 500 apply/rollback/cancel/crash 注入零主状态污染，越 scope 100% 检出 |
| FP-A5：验证闭环 | 4 周 | structural validators、Hub profile、iPL F2 handoff、evidence pack、Runtime e2e | 一个矩形-core intent 可 branch-and-select，complete bundle 前零 commit |
| FP-A6：资格与扩展 | 持续 | F1 calibration、F2/F3 full comparisons、PDN/IO/macro domain扩展 | held-out regret/coverage/qualification report 驱动 capability 升降级 |

时间只是排期估算；完成取决于退出门禁而非周数。

### 12.2 建议 PR 顺序

```text
FP-0  legacy fact ledger + golden fixture/manifests (no behavior change)
FP-1  FloorplanContext/View/Intent/Proposal schema + inspect/capability
FP-2  geometry/row/track/IO slot F0 generators + canonicalization/contract tests
FP-3  macro/PDN reservation schema + iPL/iPDN consumption receipts
FP-4  iEval adapter + Pareto/escalation + F1 calibration protocol
FP-5  iDB FloorplanDelta extension + compiler/invalidation map (joint DB review)
FP-6  isolated legacy worker + branch apply/rollback/cancel/failure injection
FP-7  structural validators + Hub certificate profile + Runtime floorplan experiment
FP-8  qualified F2/F3 portfolio, held-out benchmarks and capability promotion
```

每个 PR 必须附：schema/version migration、CURRENT/TARGET 变化、capability manifest、actual dependency/dirty domain、positive/negative fixture、coverage/unsupported 语义、benchmark protocol impact、rollback path。没有这些证据的“Agent API wrapper”不允许合入。

### 12.3 端到端完成定义

首个 iFP Agent 原生闭环完成的最低标准是：

1. 受支持的 rectangular-core design 可用固定 context 做 `inspect/diagnose`，并得到 complete/partial coverage；
2. 一个 `FloorplanIntent` 能确定性地产生多个 die/core/IO/macro-constraint 候选，硬无解有 evidence；
3. 任一候选在独立 branch 通过 versioned `FloorplanDelta` 应用，实际 touched/dirty/inverse/checkpoint 可查询；
4. apply/cancel/crash 后可证明 base hash/主 head 未污染，失败 branch 不可复用；
5. iPL 对 macro constraints 给 consumption receipt，iEval 比较 exact same-context candidates，Hub 对 required structural/frozen claims 生成 current bundle；
6. Runtime 能输出 Pareto selection/abandon DecisionRecord，且 incomplete/failed/stale candidate 没有 commit path；
7. golden、metamorphic、differential、adversarial、holdout benchmark 和可杀假说报告全部在 CI/发布门禁中可重放。

“新增 `auto_floorplan` Tcl 命令”“能跑一次 `FpApi::initCore`”或“F0 分数更好”均不算完成。

---

## 13. 开放问题和 ADR

| ID | 问题 | 决策/验证前的保守处理 |
|---|---|---|
| OI-FP-01 | iDB `TypedDelta` 如何表达 die/core/row/track 的高 blast-radius before/inverse | A4 前只 proposal；联合 DB ADR 决定 full checkpoint、schema migration 和 compaction 语义 |
| OI-FP-02 | CURRENT `dmInst`/singleton 的 branch materialization 和 process isolation 成本 | 未证明前禁并发 mutation；以 worker crash/FD/path/DB hash 实验决定 |
| OI-FP-03 | iFP legacy row/track reset、coordinate rounding、duplicate track 的既有用户兼容性 | FP-A0 锁 behavior；修复需要独立 legacy migration/feature flag 和差异报告 |
| OI-FP-04 | iPL 可消费的 macro constraint format、scope expansion 和 receipt 机制 | 先冻结 schema/consumer test；没有 receipt 不将 macro handoff 列为 E2 |
| OI-FP-05 | IO legal slot 的 LEF/tech/rule coverage及 package/pad ring语义 | 未资格认证时仅支持 core-bound signal IO subset，pad/package 另列 unsupported |
| OI-FP-06 | PDN reservation 与 iPDN topology/IR/EM 的正式边界 | reservation 保持独立 claim；无 activity/voltage/temp/via limit时只 partial |
| OI-FP-07 | polygonal/multi-height/multi-die/3D floorplan 的数据模型 | 不在矩形 schema 打补丁；待 stable view/delta/invariant/benchmark 后单独 versioned extension |
| OI-FP-08 | F1 代理的训练数据、license/tenant 隔离和 OOD policy | 先规则/解析 baseline + holdout；不将用户 design artifact 混入无审批训练集 |
| OI-FP-09 | 外部 floorplanner/signoff oracle 的 input/export fidelity | 通过 57 manifest/differential protocol；未验证 DEF/LEF/constraint round-trip 不采纳结果 |
| OI-FP-10 | floorplan policy 是否允许 late-stage die/core 变更 | 默认不允许；需要 domain owner 审批、full invalidation和预算 profile |

---

## 14. 版本历史

- ai1.1（2026-07-23）：以 `12-evaluation-ai1.0.md` 的可实现深度重写。新增 CURRENT 源码审计与 TARGET 分界、Agent 五分面 API、context/proposal/delta schema、scope/invariant/dirty/rollback、F0-F4、iPL/iPDN/iEval/Hub/Planner 契约、legacy worker 隔离、测试/benchmark/可杀假说、里程碑/PR/ADR。未把计划能力表述为现有实现。
- ai1.0（2026-07-23）：初始 iFP Agent floorplan 概要，覆盖 API、简单 delta、Fidelity 和开发路径。
