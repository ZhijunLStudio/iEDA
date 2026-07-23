<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 10 · iDB Agent 原生设计状态实施方案 · ai1.1

> 基线：`docs/ai/10-iDB-database.md` 负责数据库对象、格式和商业数据库对标；本文定义 Agent 原生 EDA 所需的设计状态、对象身份、增量、事务和可重放存储。评测、候选选择和 QoR gate 归 `12`；工作流与进程执行归 `40`；实验分支、预算、选择和提交 policy 归 `43`。
>
> 成熟度纪律：本文用 **CURRENT** 描述在当前工作区源码中可定位的能力，用 **TARGET/DRAFT** 描述尚待实现的 Agent 原生状态服务。`DesignState`/`MoveTxn` 是可复用的 D1 过渡资产，不等于 immutable snapshot、CAS catalog、多租户或跨进程恢复已经完成。
>
> 首个垂直闭环：post-place Timing ECO。iTO/iNO/iPL 在 Runtime branch 上提出 `MoveInst`、`ResizeInst`、`SwapVt`、`InsertBuffer` 或 `ReconnectPin`；iDB 将已批准的 typed delta 变成 candidate snapshot，给 `49` 计算 verification plan、给 `12` 绑定度量，只有 `43` 可选择并推进提交 head。

---

## 0. 目标、非目标与唯一责任

### 0.1 目标

iDB 不是“给 Agent 开放现有 setter”的别名。它是设计状态的可信边界，使每一次分析和写入都能回答：读的是哪个 immutable state，改了哪些对象，为什么这些证书/缓存必须失效，以及失败后能否回到可证明的基线。

ai1.0 首版必须做到：

- 为 design、instance、pin、net、route shape、via、region、layer 和外部工件建立稳定、typed、可审计的引用；
- 从经验证的输入 manifest 创建 immutable `SnapshotRef`，不把进程内 `IdbBuilder*` 当 snapshot；
- 只在 branch 上应用版本化 `TypedDelta`，返回实际 touched、保守 `DirtySet` 和 `InvalidationSet`；
- 以 compare-and-swap、lease fencing、可逆 undo/checkpoint 和 durable publish 支持并发候选；
- 将 snapshot、delta、context、artifact 和 invariant evidence 内容寻址，使另一个干净进程可 replay；
- 提供只读、结构化、可分页的 inspect/diff/export API，禁止 Agent 传递裸指针或依赖 ambient current DB；
- 对 `PARTIAL`、`CANCELLED`、`CONFLICT`、`STALE_OBJECT`、`UNSUPPORTED` 和 rollback failure 给出不同且可机器处理的结果；
- 将 iDB 现有 DEF/LEF/Verilog 读写、对象操作和 D1 `DesignState` 原型包在 compatibility adapter 后，逐步替换而非声称重写完成。

### 0.2 非目标

- iDB 不规划 placement、route 或 ECO，也不从自然语言生成 `TypedDelta`；领域工具负责 `diagnose/propose`，iDB 只验证和应用其结构化动作。
- iDB 不决定候选 QoR、Pareto、regret 或是否满足 timing/DRC/IR 门限；这些属于 `12`、领域工具和 `49`。
- iDB 不持有 Runtime 的预算、实验队列、审批、人类角色或选择策略；它只验证已授权的 branch/lease/capability token 并执行状态原子性。
- ai1.0 不承诺对所有工具私有内存、STA graph、router cache 或第三方 license state 作字节级快照；不可持久化部分必须列在 manifest，replay 时重建或返回 `UNSUPPORTED`。
- 不允许任意 Tcl/C++ setter、文件路径、对象名称或 `IdbObject*` 越过 Agent API 成为写接口；名字可用于 selector，但不是身份或权限证明。

### 0.3 唯一责任

| Owner | 负责 | 不负责 |
|---|---|---|
| iDB / Design State（本文） | ObjectId、snapshot/lineage、typed apply、scope/touched/dirty、invariant、durable artifact/ref、state replay | QoR 选择、证书 policy、工作流调度 |
| 领域工具（20-39） | inspect/diagnose/propose、领域 action 语义、domain checker | 隐式改主设计、给自己候选签发提交权 |
| `43` Experiment Runtime | branch 生命周期、budget、lease acquisition、候选选择、commit 意图 | 定义几何/连通性/时序真值 |
| `40` Platform | worker 隔离、DAG、取消、产物 protocol、进程恢复 | 直接写 iDB global singleton |
| `48` Intent/Scenario | intent/scenario canonicalization、审批、consumer receipt | 设计几何/拓扑 mutation |
| `55` Technology Knowledge | TechContext、单位/层/库语义、qualification | 复制 iDB object identity |
| `49` Verification Hub | required claims、validator DAG、Certificate、失效编排 | 修改 candidate state 或 QoR 排序 |
| `12` Evaluation | metric、可比较性、Pareto、QoR gate、evidence pack | state commit 或 correctness certificate 签发 |

**红线：** `Proposal`、`TypedDelta`、`MetricRecord`、`ValidationCertificate` 和 `DecisionRecord` 是五种不同对象。低精度预测、日志文本或 `saveDef()` 成功都不能替代其中任何一个。

---

## 1. CURRENT 事实审计与迁移边界

### 1.1 当前可复用资产

| 资产 | CURRENT 源码证据 | 可复用定位 | Agent 化缺口 |
|---|---|---|---|
| iDB import/export | `src/database/manager/builder/builder.h:61-99` 声明 LEF/DEF/Verilog build 与 DEF/LEF/Verilog/GDS/JSON save；`builder.cpp:138-349` 实现 | 输入 adapter、checkpoint 的 import/export backend、round-trip oracle | file path 驱动；无 manifest hash、snapshot identity、coverage 或 atomic publish |
| 可变设计拥有者 | `src/database/manager/service/def_service/def_service.h:54-89` 以 `unique_ptr<IdbDesign>` 持有可变 design，并借用 layout pointer | 当前进程内 branch materialization 的内核 | 不是 immutable view，生命周期与 `IdbDefService` 相同 |
| 现有对象 mutation | `src/database/data/design/IdbDesign.h:121-170` 有 create/place/replace/connect/disconnect/remove/rename/connectivity API | delta applier 的 legacy backend | 参数多为 name/raw pointer，无 scope、generation、transaction 或 replay evidence |
| 现有局部 ID | `IdbInstanceList`、`IdbNetList` 分别使用递增 `_mutex_index` 赋 ID；例如 `src/database/data/design/db_design/IdbNet.cpp:559-585` | 初始 registry mapping 的输入之一 | local counter 在重载/不同 object list 中没有跨 snapshot、kind namespace、generation 或 ABA 防护语义 |
| 全局 DataManager 路径 | `src/platform/data_manager/idm.h:49-80` 是 singleton，公开 builder/service/design 指针；`idm_init.cpp:41-62` 由 DEF 导入填充 | 旧工具 adapter 的受控入口 | 当前 global mutable state 不能服务并发 immutable snapshot |
| D1 内存状态原型 | `src/platform/design_state/{DesignState,MoveTxn,DirtySet,ArtifactIndex}.{hh,cpp}` | 单进程事务、canonical hash、dirty/artifact freshness 的迁移种子 | 无 catalog、分支、CAS、持久化、snapshot view、租约或 access control |
| D1 move 接线 | `src/platform/data_manager/idm_design_inst.cpp:299-397` 为 `placeInst` 记录 undo 与 instance/pin/net/region dirty | `MoveInst` 的第一个 integration seam | 只覆盖一条 mutation path；dirty generation 为默认 `0`，没有 typed delta/evidence/actual-scope compare |
| 真实工具直写 | iTO buffer flow 写入 timing/iDB 后直接 `saveDef()`，`src/operation/iTO/source/module/fix_hold/HoldOptimizer_buffers.cpp:80-112`；iRT、iCTS 直接 create/connect/place，见 `iRT/interface/RTInterface.cpp:295-325`、`iCTS/.../WrapperClockWriter.cc:358-469` | 必须纳入 migration inventory 的 consumers | 旁路 state contract，无法安全并行或重放 |

`IdbBuilder::buildDef()` 会删除此前的 `_def_service` 后重建（`builder.cpp:138-164`）；`buildLef(..., b_techfile=true)` 也会重建 LEF service（`:196-225`）。因此不能把上述指针、`IdbObject*` 或内存 list 的地址缓存为跨调用身份。

### 1.2 CURRENT `DesignState` 的准确定位

当前原型已经有值得保留的行为：一个互斥的 active transaction、顺序 undo、dirty 合并、state version、artifact SHA-256 格式校验和由 provider 贡献的 canonical SHA-256（`DesignState.hh:50-97`、`MoveTxn.cpp:16-147`）。它的测试覆盖 commit dirty 去重、destructor rollback、nested transaction reject、artifact stale 和 canonical ordering（`src/platform/design_state/tests/DesignStateTest.cpp`）。

但下列能力**尚未由该实现提供**，所以不得在 capability registry 标成已支持：

| 缺口 | 代码层原因 | TARGET 处置 |
|---|---|---|
| Immutable snapshot | `canonicalHash()` 调用 callback 读取 live state；没有 materialized object image | SnapshotCatalog 只接受 durable manifest/checkpoint/delta chain |
| Branch / multiwriter | 一个 `_active_transaction_token` 显式拒绝 nested/concurrent transaction | Runtime branch 对应独立 state store；同 branch 以 CAS + lease fencing 串行 |
| Durable recovery | artifact index 仅内存 map，`reset()` 会清空 metadata/artifacts/coverage | temp -> hash verify -> durable CAS -> catalog publish 的两阶段协议 |
| Stable ObjectId | `DirtySet::ObjectKey` 只有 instance/pin/net 与 caller supplied generation | ObjectRegistry 管 kind/namespace/local/generation、source mapping 和 tombstone |
| Full correctness | MoveTxn 只执行调用方提供 lambda undo，没有 invariant profile | DeltaValidator + DbInvariantChecker + reload/replay proof |
| Tenant / authorization | 当前原型无 tenant/project/ACL 字段 | refs、CAS namespace、lease 和 audit record 均携带 tenant/project |

### 1.3 迁移原则

1. **先做 facade，再迁 consumer。** 不改变 `IdbDesign` 现有 setter 语义；新 Agent capability 只能调用 `DesignStateService`。
2. **D1 与 TARGET 双跑。** `MoveTxn` 暂时承接 `MoveInst` undo/dirty，TARGET delta 与 legacy mutation 的 before/after digest 必须对拍。
3. **无证据即不升级。** 未接入 registry 的 legacy 直接写调用在 manifest 中标 `legacy_unsafe`，不能在 branch 并行调度。
4. **checkpoint 首先使用格式事实。** DEF/Verilog/sidecar manifest 可作为首版边界；每个无法 round-trip 的字段显式列 `non_persisted_state`，而不是假装完整。

---

## 2. Agent 能力与需求

### 2.1 inspect / propose / apply / verify 的边界

| 分面 | iDB capability | 输入 | 输出 | 状态副作用 |
|---|---|---|---|---|
| inspect | `state.inspect@1`、`state.diff@1`、`state.capabilities@1` | immutable snapshot + typed selector/scope | typed slices、ObjectRef、coverage、page token | 无 |
| propose | `state.preflight_delta@1` | **领域工具已产生**的 `TypedDeltaDraft` | 可应用性、required lease、估算 dirty/invalidation、拒绝原因 | 无；不产生设计动作 |
| apply | `state.apply_delta@1` | branch head + expected head + validated delta + lease | detached/candidate snapshot、actual touched、dirty、invariant result | 仅 branch/candidate catalog |
| verify | `state.verify_integrity@1`、`state.replay@1`、`state.export@1` | snapshot + invariant/export/replay profile | structural evidence、round-trip/replay report、artifact manifest | 只写 CAS evidence/index |
| compensate | `state.rollback@1` | transaction/candidate reference | restored base/detached candidate disposition | 仅 branch metadata；不可回滚已提交 global head |

`state.preflight_delta` 可以做结构性 proposal 验证，**不能**用它替领域工具生成 buffer、cell 或 route。`state.verify_integrity` 只证明 iDB 声明的结构不变量；它不是 `49` 的 certificate bundle，也不是 DRC/STA signoff。

### 2.2 功能需求

| ID | 要求 | 优先级 | 可验收结果 |
|---|---|---:|---|
| FR-DB-01 | import 创建 canonical `InputManifest` 和 `SnapshotRef` | P0 | 相同冻结输入在 clean process 中得到相同 ref；缺 source/hash/units 失败 |
| FR-DB-02 | 所有 Agent 读接口只接收 immutable snapshot | P0 | API 无 `current_db`/裸 pointer 参数；view 不随 head 漂移 |
| FR-DB-03 | ObjectId 稳定、typed、generation-aware | P0 | rename 后同 ID；delete/recreate 同名对象使旧 ref `STALE_OBJECT` |
| FR-DB-04 | typed delta 有 schema、前置/后置、before image、inverse/checkpoint | P0 | 每类 delta apply/replay/rollback 有正反例 |
| FR-DB-05 | apply 报告 declared 与 actual touched、保守 dirty/invalidation | P0 | 越 scope 或漏报 touched 不能 `SUCCESS` |
| FR-DB-06 | branch head CAS、lease fence、idempotency | P0 | 两 writer 同 expected head 只有一个可 publish |
| FR-DB-07 | state integrity/replay/export 产生可引用 evidence | P0 | fresh-process replay + declared round-trip 对账 |
| FR-DB-08 | partial/cancel/timeout/failure 不污染 base | P0 | 每个终态保留 disposition 与 hash evidence |
| FR-DB-09 | iDB artifact manifest 与 CAS 可校验、可失效 | P1 | path/mtime 变动不能误命中；hash mismatch 不 publish |
| FR-DB-10 | tenant/project/PDK license 边界贯穿 ref、CAS 和审计 | P1 | 跨 tenant ref/selector/manifest 均拒绝且不泄露存在性 |
| FR-DB-11 | legacy mutation 接入 inventory 与 facade | P1 | Timing Lab action classes 无 direct-write bypass |
| FR-DB-12 | schema migration 不就地改旧 snapshot | P1 | 迁移产生新 ref、report 和 equivalence finding |

### 2.3 非功能需求与纪律

| ID | 要求 |
|---|---|
| NFR-DB-01 | snapshot hash 只含 canonical semantic input；时间戳、绝对路径、地址、日志、随机顺序不得参与。 |
| NFR-DB-02 | `SUCCESS` 表示 candidate snapshot、delta、invariant evidence 已 durable publish；仅内存 mutation 不可返回 success。 |
| NFR-DB-03 | 无法证明局部依赖时 dirty/invalidation 必须扩大到 design，而不是猜测小范围。 |
| NFR-DB-04 | 同 request/ref/schema/tool adapter/seed 必须可 replay；非确定性 backend 须记录版本、seed、重复协议和差异。 |
| NFR-DB-05 | object/snapshot selector、delta payload、artifact URI 均 schema-validated；不允许 shell/file glob 隐式扩展。 |
| NFR-DB-06 | read view 可并发；同 branch write 必须串行且有 fencing token；旧 singleton 未证明隔离前只允许 process worker。 |
| NFR-DB-07 | CAS key、tenant、project、license label、retention policy 必须在 publish 前验证；默认禁止跨租户 dedup。 |
| NFR-DB-08 | 承诺的性能须按冻结 benchmark 的 median/MAD、p95、RSS、CAS bytes 与设计规模报告，首版不虚构绝对阈值。 |

---

## 3. 总体架构、调用与数据流

### 3.1 TARGET 组件图

```text
 Planner / domain tool
   inspect -> diagnose -> Proposal + TypedDeltaDraft
                               |
 Gateway: schema/auth/quota ---+---- Runtime: branch/budget/decision
                               |            | expected_head + fenced lease
                               v            v
                     +----------------------------------+
                     |  DesignStateService (iDB facade) |
                     | RequestValidator / ACL           |
                     | ObjectRegistry / DesignView      |
                     | DeltaValidator / DeltaApplier    |
                     | Dirty+Invalidation builder       |
                     | Invariant checker / replay       |
                     | SnapshotCatalog / CAS bridge     |
                     +----------------+-----------------+
                                      |    |
                         snapshot/delta |    | evidence/artifacts
                                      v    v
                    49 Verification    12 Evaluation
                    required claims     metrics/gate
                                      \    /
                                  Runtime select/commit
```

依赖方向固定为：`src/platform/design_state` 的 service/schema 不 include 领域工具；`src/database/manager/design_state` 的 adapter 可以读取既有 iDB；领域工具只 include public facade/header。任何 tool 直接拿 `DataManager::getInstance()->get_idb_design()` 写候选，都在迁移后视为 protocol violation。

### 3.2 只读 inspect 数据流

```text
state.inspect request
  -> validate tenant/context/snapshot existence/schema
  -> acquire snapshot read lease (fencing generation recorded)
  -> materialize or open immutable DesignView
  -> resolve typed selector (name -> ObjectId only inside this snapshot)
  -> enforce scope/pagination/redaction
  -> serialize ObjectSlice + resolved scope + coverage + provenance
  -> release lease; return stable page token bound to snapshot and selector hash
```

读 API 不得借用 global `IdbDesign` 后在返回对象中暴露 pointer。`ObjectSlice` 大 map/list 用 CAS artifact ref，small scalar 可 inline；任何 selector ambiguity 返回 `AMBIGUOUS_SELECTOR`，不会挑一个“最像”的名称。

### 3.3 proposal 到 candidate snapshot 的写入数据流

```text
domain tool proposes TypedDeltaDraft (no mutation)
  -> Runtime fixes base/context/policy/budget and acquires branch lease
  -> state.preflight_delta validates schema/rights/object generations/scope
  -> state.apply_delta(expected_head, idempotency_key, lease)
      -> fork isolated write view from base checkpoint + delta chain
      -> apply operations in canonical order; record before images
      -> collect actual touched and compare declared scope
      -> build conservative DirtySet + InvalidationSet
      -> run required structural invariants
      -> write delta/inverse/evidence to temporary CAS
      -> hash verify, atomically publish artifacts and candidate snapshot
      -> CAS branch head or retain detached candidate on conflict
  -> return StateResponse; Runtime asks 49/12 to verify/evaluate
```

`apply` 不做 QoR selection。若 `actual_touched` 超出声明，候选必须 rollback/abandon；不能仅扩大 scope 后继续，因为原 lease、frozen-object certificate 和 proposal risk model 已失效。

### 3.4 提交、回滚与 replay 数据流

```text
Runtime selects a verified candidate
  -> recheck branch head, tenant, policy/context refs, certificate freshness
  -> state.publish_head(expected_committed_head, candidate_snapshot, commit fence)
  -> atomic catalog CAS + append DecisionRecord ref
  -> emit invalidation event (certificates/cache/consumers)

worker failure or rejected candidate
  -> state.rollback(transaction/candidate)
  -> inverse in isolated write view OR discard unpublished view
  -> verify base canonical digest + durable head unchanged
  -> retain non-sensitive failure evidence; mark ABANDONED or CORRUPTED_BRANCH
```

已发布 committed head 不是可被旧 transaction 任意 rollback 的栈顶；恢复应创建一个新的、经审批的 reverse delta/branch。`state.replay` 从 referenced checkpoint、ordered delta、context 与 source artifacts 在 clean process 重建，输出 semantic diff 和 unsupported/non-persisted state。

---

## 4. 统一状态模型与 schema

### 4.1 引用与身份

```text
SnapshotRef  = sha256:canonical-snapshot-manifest
DeltaRef     = sha256:canonical-typed-delta
ArtifactRef  = cas://tenant/project/sha256/<digest>
ScopeRef     = sha256:canonical-object-region-layer-set
ObjectId     = {kind:u16, namespace:u16, local_id:u64, generation:u32}
ObjectRef    = {snapshot_ref, object_id}
BranchRef    = {tenant, project, branch_id, head_snapshot_ref, epoch}
LeaseRef     = {lease_id, branch_ref, fencing_generation, expiry, scope_ref}
```

`kind` 至少包括 design, instance, pin, net, io_pin, route_shape, via, special_net, region, blockage, row, layer, cell_master。`namespace` 与 design lineage/tenant/project 绑定；`local_id` 在同一 lineage 内不因 rename 改变；delete 创建 tombstone 并推进 `generation`。外部 name/source span 只是 index artifact，不能被 client 当作 ID 重用。

TARGET `ObjectRegistry` 的导入算法：以 input manifest 中的 parser version、object kind、hierarchical source path、canonical creation order 和必要的 geometry/connectivity discriminator 产生 first mapping；同一 manifest 重放必须一致。若 parser 无法可靠提供 discriminator，registry 返回 `UNSTABLE_IMPORT_ID`，该 object kind 不可参与 cross-snapshot delta，先补 adapter。

### 4.2 `InputManifest` 与 `DesignSnapshot`

```yaml
schema: input-manifest@1
tenant: tenant-a
project: aes13
sources:
  - {kind: tech_lef, ref: cas://.../sha256/..., parser: lef@3, license_label: pdk-a}
  - {kind: cell_lef, ref: cas://.../sha256/..., parser: lef@3, license_label: pdk-a}
  - {kind: def, ref: cas://.../sha256/..., parser: def@5}
  - {kind: verilog, ref: cas://.../sha256/..., parser: verilog-rust@2}
unit_system_ref: sha256:exact-dbu-and-physical-units
intent_ref: sha256:...
scenario_set_ref: sha256:...
tech_context_ref: sha256:...
import_profile_ref: sha256:...
non_persisted_state: [legacy_ista_graph]
```

```text
DesignSnapshot
  schema_version / snapshot_ref / parent_snapshot_ref / lineage_ref
  input_manifest_ref / checkpoint_ref / ordered_delta_refs[]
  object_registry_ref / unit_system_ref / artifact_manifest_ref
  intent_ref / scenario_set_ref / tech_context_ref / invariant_profile_ref
  semantic_digest / persisted_capabilities / non_persisted_state[]
  created_by {capability_revision, request_id, tenant, project}
  status = PREPARING | DURABLE | PUBLISHED | QUARANTINED
```

```text
snapshot_ref = hash(
  snapshot_schema, parent_snapshot_ref, canonical_input_manifest_ref,
  canonical_checkpoint_ref, ordered_delta_refs, object_registry_ref,
  unit/intent/scenario/tech/invariant refs, persisted_capabilities
)
```

时间、host、absolute path、worker PID、progress log、license token 和 CAS physical location 不进入 hash。`status` 是 catalog metadata；它不改变 `snapshot_ref` 的 semantic content。`PUBLISHED` 要求所有 referenced CAS object 已 hash-verified；`QUARANTINED` 只能用于诊断/replay，不能被 Runtime 作为 candidate。

### 4.3 Scope、DirtySet 与 InvalidationSet

```yaml
scope:
  kind: object_region_layer
  objects: ["instance:0:102:3", "net:0:87:1"]
  regions_dbu: [[-1, 1000, 2000, 5200, 6800]]
  layers: [M2, M3]
  scenarios: []
  halo_dbu: 0
  closure: exact                 # exact | conservative | design
```

```text
DirtySet
  changed: ObjectRef[]                 # actual post-apply object IDs
  relations: {pins, nets, masters, route_shapes, vias}
  regions: Region[]                    # DBU and layer, canonical non-overlapping form
  layers: LayerId[]
  scenarios: ScenarioId[]
  dependency_domains: {placement, connectivity, route, rc, timing, power, ...}
  reason: DeltaKind[]
  completeness = EXACT | CONSERVATIVE | DESIGN_WIDE

InvalidationSet
  source_snapshot / candidate_snapshot / delta_ref
  affected_claim_kinds[] / cache_dependency_domains[]
  exact_scope_ref / conservative_scope_ref
  required_revalidation_hints[]
  reason[] / producer_revision
```

iDB 是 structural dirty 的 owner，生成保守上界；iSTA/iRT/iRCX/iDRC 等可把自己的 dependency cone **扩大**，不得缩小 iDB 的闭包。无 topology/geometry proof 时 `closure=design`。`InvalidationSet` 是对 `49` certificate registry 与 `12` cache 的事件输入，不是“证书已失效”的最终判断。

### 4.4 `TypedDelta` schema

```yaml
schema: typed-delta@1
delta_id: uuid
base_snapshot_ref: sha256:...
intent_ref: sha256:...
scenario_set_ref: sha256:...
tech_context_ref: sha256:...
proposal_ref: sha256:...
author: {capability: timing.insert_buffer@1, tool_revision: sha256:...}
declared_scope_ref: sha256:...
operations:
  - op_id: move-u42
    kind: MoveInst
    target: {object_id: "instance:0:102:3"}
    preconditions: {master: BUF_X2, movable: true, old_pose: [1000, 2000, N]}
    after: {pose: [1040, 2000, N], status: PLACED}
    expected_dirty_domains: [placement, wirelength, congestion, rc, timing]
inverse: {kind: MoveInst, after: {pose: [1000, 2000, N], status: PLACED}}
canonical_order: [move-u42]
```

必填字段：schema/version、base/context refs、proposal ref、declared scope、每个 op 的 typed target/precondition/postcondition、权限 action class、estimated dirty、inverse 或 checkpoint strategy、canonical order、payload hash。禁止内嵌 Tcl、自由 C++ callback、路径或“运行某个 command”字符串。

首版注册动作如下；其它现有 iDB setter 先保持 legacy-only：

| Delta | 前置条件 | 成功后必须证明 | 保守 dirty/invalidation |
|---|---|---|---|
| `MoveInst` | instance generation/live、movable、target site/region、lease 覆盖 old/new halo | coordinate/orient/status、placement index 与 pin locations 一致 | placement, WL, congestion, RC, timing, power |
| `ResizeInst` / `SwapVt` | cell family mapping 来自 `55`、dont_touch/dont_use 未命中、equivalence class 合格 | master/pin/function mapping、合法尺寸/站点 | netlist attrs, placement, timing, power, RC |
| `InsertBuffer` | master/library/PG mapping qualified、target net/edit rights、命名 policy | one input/one output connectivity、无孤儿 inst/pin/net、actual new IDs | connectivity, placement, route, RC, timing, power, formal |
| `ReconnectPin` | pin/net live、driver/load/frozen policy、intent restriction | old/new net membership 双向一致、无断开残留 | connectivity, route, RC, timing, formal/LVS |
| `Add/DeleteRouteShape` / `ReplaceVia` | net/layer/via 来自 `55`、region/layer lease、route stage | ownership、geometry/layer/via topology | route, DRC, RC, timing, SI/EM/IR |
| `ConstraintPatch` | **不属于 DesignDelta**；仅 `48` 的 R4 approval flow | new IntentRef/baseline | all timing/power compare/cache/certificate domains |

### 4.5 事务与 response schema

```yaml
request_id: uuid
capability: state.apply_delta@1
tenant: tenant-a
branch_ref: {id: eco-17, expected_head: sha256:..., epoch: 6}
lease_ref: {id: lease-..., fencing_generation: 42}
idempotency_key: uuid
delta_ref: sha256:...
scope_ref: sha256:...
budget: {wall_ms: 2000, memory_mb: 4096}
cancel: {deadline_ms: 2000, mode: cooperative_then_kill}
```

```text
StateResponse
  status = SUCCESS | PARTIAL | CONFLICT | STALE_OBJECT | INVALID_DELTA |
           INVARIANT_FAILED | TIMEOUT | CANCELLED | STORAGE_ERROR |
           CORRUPTED_BRANCH | UNAUTHORIZED | UNSUPPORTED | FAILED
  request/idempotency/transaction/branch/lease refs
  snapshot_before / snapshot_after? / detached_candidate?
  delta_ref / inverse_or_checkpoint_ref
  declared_scope / actual_touched / dirty / invalidation refs
  invariant {checked, skipped, unsupported, failed, evidence_ref}
  completed_scope / remaining_scope / artifacts / resume_token? / diagnostics[]
```

`SUCCESS`：candidate snapshot、delta、invariant result 和 required index records durable，且 branch CAS 成功或 response 明确为 durable `detached_candidate`。`PARTIAL`：无可提交 head；必须同时给 `completed_scope`/`remaining_scope` 与稳定 resume preconditions。`TIMEOUT`/`CANCELLED`：若 worker 已产生未发布临时 state，必须 discard 或 rollback 后才能返回；不可把 partial in-memory modification 当 incumbent。

---

## 5. 状态机、并发、租约与恢复

### 5.1 Candidate / branch 状态机

```text
NEW -> LEASED -> PREFLIGHTED -> APPLYING -> VALIDATING -> PERSISTING -> READY
 |        |           |             |             |             |
 |        +--------> CONFLICTED     |             |             +-> CAS fail -> DETACHED
 |                    (no write)    |             +-> failed -> ROLLING_BACK
 |                                  cancel/timeout              |
 +-> ABANDONED <---------------------------+--------------------+

READY -> SELECTED (Runtime only) -> COMMITTING -> COMMITTED
 READY -> REJECTED/ABANDONED
ROLLING_BACK -> ROLLED_BACK | CORRUPTED_BRANCH
```

`PREFLIGHTED` 不是锁定全芯片；它只说明在当时 head/lease/context 下 schema 与 structural precondition 可通过。`DETACHED` 可保留用于 comparison/replay，但不得自动 rebase 或成为 branch head。`CORRUPTED_BRANCH` 立即隔离：禁止新 tool、verification 或 evaluation 读取，保留最小 failure evidence 后由 Runtime 销毁。

### 5.2 apply 的原子算法

```text
apply(request):
  validate request/context/tenant/ACL/idempotency/lease fence/expected head
  if prior completed idempotency record: return exact prior response
  load immutable base snapshot and delta; validate every ObjectRef generation
  create isolated write view; checkpoint or stage all inverse images
  apply ops in canonical order, collecting actual touched after each op
  require actual_touched subset_of declared_scope and lease scope
  build conservative DirtySet + InvalidationSet; run invariant profile
  if any check fails/cancel/deadline: rollback isolated view; verify base digest
  write data to temp CAS, hash verify, write transaction/evidence manifest
  atomically publish CAS objects, then CAS branch head(expected_head, lease fence)
  on head conflict: leave detached candidate only if complete and policy allows
  append immutable transaction disposition; return structured status
```

多个 op 的发布是 all-or-nothing。DB mutation 成功但 artifact/catalog 发布失败仍是失败，必须进入 rollback/recovery 路径。不同 delta 的 canonical op order 由 schema 定义，不依据 proposal JSON 字段顺序。

### 5.3 Lease、冲突与 merge

| 资源 | owner / acquisition | 冲突规则 |
|---|---|---|
| snapshot read lease | Platform/Runtime 为 inspect/validator 获取 | 不阻塞 writer；view 固定 ref |
| branch write lease | Runtime 原子申请，iDB 校验 fence | 同 branch 只能一个有效 writer |
| object-set lease | Runtime 根据 proposed scope 申请 | object ID 或 generation 重叠即冲突 |
| spatial/layer lease | Runtime 根据 region/layer+halo 申请 | bbox/layer overlap 冲突；不因 ID 不同放行 |
| high-risk lease | Runtime 管 clock/reset/PG/intent domain | 必须与普通 object/region lease 合并判断 |

lease 按 `(tenant, project, branch, high-risk-domain, layer, region, object)` canonical order 原子取得，防止部分持有死锁。每次 lease renewal 递增或保持可验证的 fencing generation；iDB 在 publish 前再检查 fence，过期 worker 不得覆盖新 owner。iDB 只做 mechanical conflict detection 与 revalidation；两 delta 是否值得 merge 由 Runtime/Policy 决定。

### 5.4 rollback、crash 与 recovery

| 故障点 | 必须行为 | 不允许行为 |
|---|---|---|
| 第 k 个 op 抛异常 | LIFO inverse/isolated view discard，重算 base digest | 保留已创建 orphan pin/net/shape |
| cancel/deadline | cooperative cancel 后等待 safe point；超时隔离 worker | 将未验证 after state 标 success |
| temp CAS 写失败/磁盘满 | 不 publish catalog；清理 temp 或标 orphan GC candidate | 记录 ref 却缺 object |
| CAS hash mismatch | `STORAGE_ERROR`，candidate quarantine | 接受 path/mtime 等价 |
| catalog publish 前 crash | startup 扫描 `PREPARING`，删除/隔离 temp；head 不变 | 猜测是否已 commit |
| catalog publish 后 crash | 以 durable transaction record/candidate manifest 恢复 idempotent response | 依赖 worker 内存恢复 |
| rollback 后 semantic digest 不等 | `CORRUPTED_BRANCH`，保留 evidence，禁止继续 | 自动用名称寻找对象修补 |

checkpoint 状态固定为 `PREPARING -> DURABLE -> PUBLISHED`。compaction 只可在等价 checkpoint、object registry、artifact manifest、context refs、invariant summary 全部逐项对账后替换读路径；原 delta chain 保留至 retention policy 允许回收。

---

## 6. 结构化 API、错误、partial 与 cancel

### 6.1 公共 capability 表

| API | 权限等级 | 成功输出 | 特殊失败 |
|---|---:|---|---|
| `state.capabilities@1` | R0 | context 下可读/可写 delta kinds、profiles、limits | `UNSUPPORTED_CONTEXT` |
| `state.inspect@1` | R0 | `ObjectSlice`/page/artifact refs | `NOT_FOUND`、`AMBIGUOUS_SELECTOR`、`STALE_PAGE_TOKEN` |
| `state.create_snapshot@1` | R3 | initial SnapshotRef、import report | `IMPORT_PARTIAL`、`UNQUALIFIED_TECH` |
| `state.preflight_delta@1` | R1 | validation/lease/invalidation estimate | `STALE_OBJECT`、`SCOPE_DENIED` |
| `state.apply_delta@1` | R1/R2 by action class | candidate snapshot/delta/dirty/evidence | `CONFLICT`、`INVARIANT_FAILED`、`CORRUPTED_BRANCH` |
| `state.diff@1` | R0 | typed structural diff + comparability | `CONTEXT_MISMATCH`、`UNSUPPORTED_OBJECT_KIND` |
| `state.verify_integrity@1` | R1 | invariant evidence/coverage | `PARTIAL`、`UNSUPPORTED_PROFILE` |
| `state.rollback@1` | R1 | disposition/base digest evidence | `NOT_ROLLBACKABLE` |
| `state.replay@1` | R2 | replay snapshot/diff/report | `NON_PERSISTED_CAPABILITY` |
| `state.export@1` | R1 | artifact manifest/round-trip profile | `PARTIAL_EXPORT`、`LICENSE_DENIED` |
| `state.compact@1` | R3 maintenance | equivalent checkpoint/report | `RETENTION_HOLD` |

权限是 `41` Gateway/Runtime 的 authority 输入；iDB 不自行解释“谁是管理员”。不过 iDB 必须校验 signed principal、tenant/project/action class、lease scope、intent/tech restrictions 和 audit correlation ID，不能把调用方声称的 role 当事实。

### 6.2 错误语义

| 情形 | 状态 | `snapshot_after` | 恢复者 |
|---|---|---|---|
| expected head 已前移 | `CONFLICT` | null 或明确 detached candidate | Runtime 重 inspect/re-propose；高风险 action 不自动 rebase |
| ObjectId generation/lineage 不匹配 | `STALE_OBJECT` | null | domain tool 重新 inspect |
| schema/precondition/ACL/scope 失败 | `INVALID_DELTA` / `UNAUTHORIZED` | 与 before 相同 | caller 修正；不按名称降级 |
| structural check fail | `INVARIANT_FAILED` | null；base 不变 | domain tool 新 proposal |
| profile 有 skipped/unsupported | `PARTIAL` 或 `UNSUPPORTED` | 不可提交 | Runtime 补 validator/profile |
| worker deadline/cancel | `TIMEOUT` / `CANCELLED` | null；或 declared non-publish partial artifact | Runtime 决定 resume/abandon |
| persistent store error | `STORAGE_ERROR` | null | Platform repair/retry idempotent request |
| undo/replay digest 异常 | `CORRUPTED_BRANCH` | forbidden | Runtime quarantine/destroy |

所有 diagnostics 使用稳定 machine code、affected `ObjectRef`/scope、evidence ref、retryability、redacted human message；不得靠解析 stdout。`FAILED` 仅用于未分类内部错误，必须附 trace/evidence ref，不能掩盖上表可分类状态。

### 6.3 partial、page 和 cancellation 规则

- `state.inspect` 的 `PARTIAL` 只表示有明确 `completed_scope`、`remaining_scope` 和 `continuation_token`；page token 绑定 snapshot、tenant、selector hash、schema 和 expiry。
- `state.verify_integrity` 的 skipped、unsupported、refused 分量必须原样返回。`checked > 0` 绝不等同 full pass。
- apply 不支持 “部分 op 已提交”；多-op delta 只允许 all-or-none。需要部分执行时，Planner/Runtime 拆为多个显式 delta/branch。
- cancellation 在 preflight/read/export 可以有 safe partial result；在 mutation 中只在 rollback 已完成或从未触及 view 后返回终态。
- resume token 是 capability/profile/snapshot/lease-independent artifact ref；过期 context、head 或 schema 时拒绝 resume，而不是从当前 DB 接续。

---

## 7. 持久化、CAS、cache 与 artifact

### 7.1 CAS publish contract

```text
CAS object key = tenant namespace + project namespace + sha256(canonical bytes)
publish:
  write temp object under transaction namespace
  -> fsync/close + compute canonical content hash
  -> validate schema, tenant/license labels and referenced object hashes
  -> atomic object promote (or immutable conditional put)
  -> write manifest referring only to durable objects
  -> catalog compare-and-swap publish
```

CAS 可以 deduplicate 同 tenant/project 的相同内容；跨 tenant dedup 默认关闭，即使 hash 相同也不得以 timing、错误码或 ref 形式泄露 existence。PDK/proprietary artifact 的 manifest 可被授权 consumer 读取 hash/coverage，不复制 rule text。GC 仅回收没有 catalog/retention/legal hold 引用的 object；candidate evidence 默认保留到 experiment retention 到期。

### 7.2 ArtifactManifest

```text
ArtifactManifest
  artifact_ref / type / schema / sha256 / byte_size / status
  producer capability/build/parser revision / snapshot_ref / context refs
  scope/coverage/created_from_delta_ref
  tenant/project/license labels / redaction class / retention class
  dependencies[] / non_persisted_state[] / diagnostics_ref
```

`path` 是 worker-local staging detail，不能进入 downstream cache key。CURRENT `ArtifactIndex` 的 `state_version` freshness 可迁移为 adapter signal，但 TARGET freshness 一律以 snapshot/context/dependency ref 计算；有 hash 但 context 不同仍是 stale。

### 7.3 cache 与失效

```text
StateCacheKey = hash(
  snapshot_ref, object/scope selector ref, intent_ref, scenario_set_ref,
  tech_context_ref, adapter/build/schema/profile params, artifact hashes
)
```

最保守规则是不同 `SnapshotRef` 不复用 object-derived result。后续增量复用须同时满足：consumer 声明 dependency domain；`DirtySet` 不相交或有可验证局部闭包；context/artifact/schema/tool revision 相同；周期性 full replay 对拍未失格。`Invalidate` 事件至少带 old/new snapshot、dirty/invalidation refs、semantic context diff 和 producer revision；consumer 可以扩大失效，不能静默缩小。

---

## 8. 权限、多租户与数据治理

### 8.1 授权决策

```text
allow(request) = authenticated principal
  && request.tenant/project == ref namespace
  && capability/action class allowed by Gateway policy
  && branch/lease fence current for mutations
  && scope subset_of approved lease and intent restrictions
  && TechContext/PDK license permits requested use/export
  && audit correlation/idempotency fields present
```

R0 只能 inspect approved redacted state；R1 可创建 branch candidate；R2 可执行 routed/netlist action；R3 维护 catalog/compact；R4 仅属于 `48` intent approval，不能借 iDB mutation 获得。Runtime 的 service identity 不能越过 tenant/project/PDK labels。错误回应对无权 ref 使用统一 `NOT_FOUND_OR_DENIED` 外部码，详细原因只写受限 audit log。

### 8.2 数据最小化与审计

- 普通 Agent/Model/Experience 查询只得到必要 ObjectId、typed property 与脱敏 artifact；DEF/LEF/Liberty/route 文件不是默认 prompt payload。
- audit record 至少包含 principal, tenant/project, request/branch/lease, refs, action class, status, touched/dirty digest, policy decision, build hash 和时间；审计时间不进入 snapshot hash。
- export 需要 destination classification；PDB/PDK licensed artifact 的跨项目 export、自由文本日志和 CAS signed URL 都须显式 policy。
- tenant deletion/retention 通过 catalog tombstone 与 CAS reachability 执行，不能因共享 hash 意外删除另一个 tenant 数据。

---

## 9. 跨模块契约

### 9.1 40 / 43 / 48 / 49 / 55 / 12 对账

| 模块 | iDB 输入 | iDB 输出 | 禁止耦合 |
|---|---|---|---|
| `40` Platform | worker request、lease/context refs、cancel/deadline、artifact staging token | typed response、actual touched/dirty、CAS artifact refs | Platform 不持有 `IdbObject*` 或把 rc=0 当 state success |
| `43` Runtime | branch policy、expected head、idempotency、selected candidate intent | candidate/detached snapshot、conflict/fence result、transaction disposition | iDB 不选 winner、不扣 budget、不自动 rebase |
| `48` Intent | immutable `IntentRef`/`ScenarioSetRef`、ObjectId expansion | snapshot context binding、design delta invalidation | iDB 不解析或批准 `ConstraintPatch`；新 IntentRef 建新 baseline |
| `49` Verification Hub | base/candidate snapshot、TypedDelta、Dirty/InvalidationSet、integrity evidence | state claim input、exact scope/replay evidence | iDB 不把 `DbInvariantChecker` 结果伪装成完整 certificate bundle |
| `55` Technology | `TechContextRef`、unit/layer/via/cell-family mapping、qualification receipt | consumed tech IDs、rejected/unmapped diagnostics | iDB 不用 cell/layer 名字猜 mapping，不把 parser success 当 qualified |
| `12` Evaluation | immutable base/candidate refs、dirty/cache event、artifact manifests | metric provenance/evidence input | iDB 不计算 QoR，不允许 metric cache 跨 context/snapshot 默认复用 |

### 9.2 与 `51` / `52` / `53` 的不可变约束

本文落实 `53` 的五 ref 最小调用上下文和 `Proposal -> TypedDelta -> Certificate -> DecisionRecord` 分离，落实 `52` 将 `Unit/ObjectId/SnapshotRef` 和 `TypedDelta/DirtySet/InvalidationSet` 作为 P0 基座，落实 `51` 的 branch-first Timing Lab。实现时不得另建第二套命名相近的 `Snapshot`, `DirtySet`, `Scope` 或 `ObjectId` schema。

`SnapshotRef` 绑定 `IntentRef`、`ScenarioSetRef`、`TechContextRef`。纯几何 state 可以有明确声明的 context optional profile；timing/power/route/DRC 不能回退“当前场景/当前 PDK”。任一 semantic context ref 变化生成新 baseline 并使相关 compare/certificate/cache 不可 current 命中。

### 9.3 Verification 的最小 claim 输入

| Delta class | iDB 必须供给 `49` | 至少要求的后续 claim（policy 决定严格程度） |
|---|---|---|
| geometry / `MoveInst` | old/new pose、actual region、placement dirty | `state.integrity`, `objects.frozen`, placement legality, timing/route scope |
| master change | before/after master、family mapping receipt、pin mapping | integrity, connectivity, frozen, timing/power |
| buffer/reconnect | created/deleted IDs、pin-net edge diff、affected nets | integrity, connectivity/formal, placement, RC/STA, route if applicable |
| route/via | shape/via/layer/net ownership diff、geometry/layer dirty | integrity, frozen, DRC, RC, STA, SI/EM/IR as policy requires |
| import/export | manifest/parser/exporter profile, persisted capability list | state integrity, artifact round-trip, context/tech coverage |

Hub 根据 delta invalidation graph 决定 exact required claims；iDB 给的是保守事实，不能通过少报 dirty 来减少检查。

---

## 10. LLD：源码落点、类职责与迁移

### 10.1 目标目录与现有边界

```text
src/platform/design_state/                     # CURRENT D1 seed; TARGET service home
  api/DesignStateService.{hh,cc}               # public facade only
  schema/{SnapshotRef,ObjectId,Scope,TypedDelta,StateResponse}.hh
  catalog/{SnapshotCatalog,BranchCatalog,TransactionLog}.cc
  transaction/{DeltaValidator,DeltaApplier,RollbackEngine,LeaseFence}.cc
  persistence/{CasStore,CheckpointCodec,ArtifactManifest,ReplayEngine}.cc
  query/{DesignView,SelectorCompiler,DiffEngine}.cc
  invalidation/{DirtySetBuilder,InvalidationBuilder}.cc
  verify/{DbInvariantChecker,RoundTripChecker}.cc
  migration/{LegacyIdbAdapter,DesignStateD1Adapter}.cc
  tests/{unit,contract,property,fault,workflow}/

src/database/manager/design_state/             # TARGET iDB-facing adaptation only
  ObjectRegistry.{hh,cc}
  IdbSnapshotMaterializer.{hh,cc}
  IdbObjectCodec.{hh,cc}
  IdbMutationAdapter.{hh,cc}

src/database/manager/{builder,service,data}/   # CURRENT legacy kernel; do not expose as Agent API
src/platform/data_manager/                     # CURRENT singleton bridge; migration inventory only
```

先将 CURRENT `DesignState`, `MoveTxn`, `DirtySet`, `ArtifactIndex` 收入同一 namespace/target，但不要在 DB-0 迁移期间重命名或破坏既有 consumer。`IdbMutationAdapter` 是唯一允许调用 `IdbDesign::{createInstance,placeInstance,replaceInstanceMaster,connect*,disconnect*,remove*}` 的 TARGET 层；它在每个 mutation 前后记录 object codec image。

### 10.2 类职责

| 类/模块 | 输入 | 输出 | 不可做的事 |
|---|---|---|---|
| `DesignStateService` | typed request + auth context | typed response | 暴露 raw iDB pointer 或 implicit current state |
| `ObjectRegistry` | import/materialized objects | ObjectId/name/source mapping/tombstone | 用 pointer/address 作为 stable ID |
| `DesignView` | SnapshotRef + selector | immutable typed slices | setter 或读 branch head 后漂移 |
| `SnapshotCatalog` | durable manifest/parent/branch CAS | lineage/head/disposition | 选择 candidate QoR |
| `DeltaValidator` | draft + view + scope/intent/tech policy | normalized/validated delta | 运行 STA/DRC 或改设计 |
| `DeltaApplier` | validated delta + isolated view | actual touched/before image | 静默越 scope/auto-rebase |
| `DirtySetBuilder` | before/after/object relations | conservative dirty/invalidation | 缩小领域 consumer 的 closure |
| `RollbackEngine` | inverse/checkpoint + transaction | base-digest evidence | 吞掉 undo failure |
| `CheckpointCodec` | materialized view | durable checkpoint / import report | 声称保存 non-persisted tool state |
| `ReplayEngine` | manifest/checkpoint/delta chain | replay diff/evidence | 使用 ambient cwd/current DB |
| `DbInvariantChecker` | view + profile | checked/skipped/failed evidence | 把 skipped 写成 pass |
| `LegacyIdbAdapter` | target request | legacy iDB operation + capture | 给 legacy global singleton 并发直调 |

### 10.3 现有代码迁移表

| CURRENT 路径 | 迁移动作 | DB slice 后状态 |
|---|---|---|
| `src/database/manager/builder/builder.{h,cpp}` | 封装成 import/export/checkpoint backend，记录 parser/exporter profile、input/output hash | 保留，Agent 不直接调用 |
| `src/database/data/design/IdbDesign.{h,cpp}` | 通过 `IdbMutationAdapter` 支撑首批 delta；补 before/after codec | 保留，只有 adapter 可写 |
| `src/platform/data_manager/idm.{h,cpp}` | 仅作 single-process legacy materializer；禁止 facade 返回 singleton pointers | 逐 consumer 收口 |
| `src/platform/design_state/*` | 保留 transaction/dirty/hash tests；扩 schema/API/durability | D1 seed，非完成状态服务 |
| iTO/iNO/iRT/iCTS direct writes | 每个 call site 先产生 proposal/delta，再由 facade apply；双跑 legacy result | 未迁移前 capability 标 unsafe/non-parallel |

---

## 11. 不变量、可比较性与 replay

### 11.1 iDB structural invariant profile

| Profile | 最小检查 | 适用 delta | 不能证明 |
|---|---|---|---|
| `state.core@1` | ObjectId uniqueness/generation、parent/context refs、manifest hash、no orphan registry entry | 全部 | placement/route/timing correctness |
| `state.connectivity@1` | pin<->net 双向、created/deleted edge、driver/load shape constraints | reconnect/buffer/netlist | logical equivalence/signoff LVS |
| `state.geometry@1` | bbox canonical、layer ownership、coordinate/unit range、index consistency | move/route/via | DRC clean/legality certificate |
| `state.export@1` | declared DEF/Verilog/sidecar semantic round-trip、unsupported list | checkpoint/export | all tool private cache equivalence |
| `state.replay@1` | clean process materialize + semantic object diff | release/compaction | external tool analysis equivalence |

每个 result 记录 profile/version、checked/skipped/unsupported/failed objects/rules、coverage、tool/parser/codec hash。`state.core PASS` 是 `49` 的 `state.integrity` 输入，不能直接成为 Runtime commit permission。

### 11.2 diff 与可比较性

`state.diff(a,b)` 先检查 lineage、ObjectRegistry schema、unit, intent, scenario, tech context 和 comparison profile。相同 design lineage 的 structural diff 可以在不同 context 下输出，但 response 必须 `comparison=STRUCTURAL_ONLY`；在不同 intent/tech/scenario 下不得声称 QoR comparable。diff 分为 `added/removed/modified/renamed/retargeted/coverage_changed/context_changed`，每项给 stable IDs 和 before/after artifact ref，避免将 object name 文本 diff 当语义 diff。

### 11.3 replay 规则

```text
replay(snapshot):
  resolve all manifest refs under original tenant/license policy
  materialize checkpoint using declared parser/codec versions
  apply ordered delta refs with original canonical order
  rebuild ObjectRegistry and canonical semantic digest
  run replay profile and compare expected vs actual object/context/artifact coverage
  return EQUIVALENT | PARTIAL | NOT_EQUIVALENT | UNSUPPORTED with evidence
```

parser/codec schema major change 或 unavailable PDK artifact 不能悄悄使用 latest/default；返回 `UNSUPPORTED`，或者显式 migration 产生新 SnapshotRef。`PARTIAL` 明确列入 non-persisted state，不能作为 `state.replay@1` 完整通过。

---

## 12. 首批工作流

### 12.1 post-place Timing ECO

```text
1. iSTA/Observer inspect fixed SnapshotRef，输出 violation/object ScopeRef。
2. iTO/iNO/iPL 只创建 Proposal + TypedDeltaDraft；不写 current iDB。
3. Runtime 创建 N 个 branch，固定 Intent/Scenario/Tech/Policy refs 与 budget。
4. iDB preflight/apply 每个 candidate，产生 actual touched/Dirty/Invalidation。
5. 12 在 candidate snapshot 上筛选/升级；49 根据 invalidation 运行 connectivity/legality/STA 等。
6. Runtime 只从 current certificate + gate complete 的 branch 选择；iDB CAS 推进 selected head。
7. state export/replay artifact 进入 evidence pack；失败 candidate 保留 disposition，不污染 baseline。
```

端到端验收：同一 base 的 20 个 buffer/resize/move candidate 可并发 read/isolated write；一个故意越 frozen scope、一个 generation stale、一个第 k op fault、一个 head conflict、一个 worker cancel 都不得改变 committed head。最终 selected candidate 必须能在 clean process replay，并在 `12` evidence pack 中定位 snapshot/delta/context/invariant refs。

### 12.2 post-route local reroute

Route delta 必须声明 affected net、region、layer、frozen net digest、coupling halo 与 TechContext via/layer refs。若 iRT 发现必须扩大 route window，只能返回新的 scope expansion proposal；旧 lease/delta/certificate 变 stale，不能在原 request 上直接加 shape。`DirtySet` 至少扩到 DRC/RC/timing/SI/EM 所需 domain；是否跑对应 validator 由 `49` policy 决定。

### 12.3 import/export recovery drill

从 LEF/DEF/Verilog/sidecar `InputManifest` 导入 -> create snapshot -> export declared formats -> 新进程 import -> `state.diff`/`state.replay` 对拍。所有 parser warning、unsupported section、unit conversion、name collision、non-persisted capability 进入 import/report；“writer 返回 true”不是 round-trip success。

---

## 13. 测试、故障注入与基准

### 13.1 测试分层

| 层级 | 用例 | 关键断言 |
|---|---|---|
| L0 unit | ObjectId/Scope canonicalization、hash、schema、status mapping、lease fence | name/path/order/clock 不改变语义 hash；generation mismatch 拒绝 |
| L1 contract | request/context/ACL/selector/page/artifact schemas | 缺 context、跨 tenant、ambiguous name、bare path 全部响亮失败 |
| L2 delta | 每个 op pre/post/inverse/actual touched/dirty | apply -> inverse 恢复 semantic digest；越 scope 零 publish |
| L3 persistence | temp CAS、catalog CAS、checkpoint/compaction/replay | kill 任一点只见 last durable head；无 dangling catalog ref |
| L4 integration | LegacyIdbAdapter 与 iTO/iNO/iPL/iCTS/iRT 首批 action | legacy/target before-after diff 对拍；无 global-state bypass |
| L5 workflow | Timing ECO、route repair、cancel/conflict/verification/evaluation | incomplete/failed certificate 或 gate 无 commit path |
| L6 scale/soak | multi-branch、long delta chain、GC/retention/recovery | 无 race/ABA/incorrect cache reuse；性能统计可复现 |

### 13.2 必进 CI 的案例

| ID | 注入 | 断言 |
|---|---|---|
| DB-T01 | 相同 input manifest 两次 clean import | snapshot/object mapping digest 一致 |
| DB-T02 | rename instance/net | ObjectId 不变、name index 更新、Intent expansion 可审计 |
| DB-T03 | delete 后同名 recreate | new generation，旧 ObjectRef `STALE_OBJECT` |
| DB-T04 | 每种首批 delta apply -> inverse | base digest、object counts、relationships 和 registry 恢复 |
| DB-T05 | multi-op 第 k 步 throw | 无 half publish、无 orphan object、base head unchanged |
| DB-T06 | mutation 实际触及 scope 外 net/region/layer | reject/quarantine，报告 actual touched |
| DB-T07 | 双 writer 同 expected head/fence | 仅一个 branch CAS success；另一个 conflict/detached |
| DB-T08 | kill at PREPARING/DURABLE/PUBLISHED | restart 只恢复 last durable catalog state |
| DB-T09 | corrupt CAS bytes/hash/manifest ref | never publish; `STORAGE_ERROR` evidence complete |
| DB-T10 | DEF/Verilog/sidecar round-trip | declared profile semantic equivalent；未知/缺失项 visible |
| DB-T11 | 1000 randomized delta + periodic fresh replay | incremental state 与 replay diff 为空，或 explicit partial |
| DB-T12 | intent/tech/scenario ref drift | old cache/certificate/result not current/comparable |
| DB-T13 | tenant B guesses tenant A ref | no data leak; audit records deny |
| DB-T14 | legacy singleton two-design worker sequence | no state carryover; otherwise capability remains process-isolated |

### 13.3 Property 与 metamorphic 测试

- 任意合法 delta sequence `apply; rollback` 恢复 base semantic digest；对 op grouping 的合并/拆分只在 schema 指定可交换时保持等价。
- canonical order、JSON map insertion order、artifact physical staging path、source file whitespace/ordering（语义无关时）不改变 SnapshotRef；semantic field/mapping/units 变化必须改变。
- rename 保持 topology/object identity；整体平移保持 connectivity；镜像/rotation 只在 tech/site symmetry profile 允许时保留相关 property。
- 对保守 dirty 采用 metamorphic oracle：将 dirty 扩大到 design 后，consumer 不可得到与原范围矛盾的“fresh”判断；若有差异则局部依赖失格。
- delta generator fuzz ObjectId kind/generation、bbox overflow、layer/via mismatch、重复 pin、cycle reconnect、name collision、nested transaction、idempotency replay。

### 13.4 故障注入与 benchmark protocol

故障注入覆盖 CAS disk full/permission/partial write、hash mismatch、catalog CAS race、worker SIGKILL、lease expiry/fence reuse、undo lambda throw、parser crash、serializer version drift、malformed artifact、cancel at each state transition。任何注入后都检查 committed head、base digest、temp cleanup/quarantine 和 audit disposition。

性能报告包含完整 reload、base+1 delta、base+100 delta、compaction 后 read、fresh-process replay 和 N branch contention 六组；按 design/PDK/stage/action object count/route size 分桶。每组至少五次，发布 median/MAD、p95 wall、RSS、CPU、CAS read/write bytes、checkpoint bytes、dirty size、rollback time 与 full reload 对拍误差。不得以仅内存 `MoveTxn` 时间代替 Agent state service 成本。

### 13.5 可杀假说

| 假说 | 实验 | 失败后的行动 |
|---|---|---|
| H-DB-A1：base+delta 可显著优于每候选 full DEF reload | held-out 10k local ECO portfolio 对比 reload/delta/replay | profile copy/index/codec；若不足 2x，缩小 delta 范围或维持 process checkpoint，不盲增类型 |
| H-DB-A2：保守 dirty 足以安全支持局部验证/cache | incremental consumer 与 full-domain oracle 按 action/PDK 分桶对拍 | 扩大 closure；该 action 类禁用 incremental reuse |
| H-DB-A3：stable ObjectId 能跨 import/replay 保持正确引用 | rename/delete/recreate/parser upgrade corpus | 修 import mapping；未解决 kind 禁止 cross-snapshot action |
| H-DB-A4：legacy iDB 能在 process materialization 下承载首个 branch 闭环 | N candidate worker isolation/soak | 若污染或成本超界，先补 reset/checkpoint/worker pool，不开放 shared singleton |
| H-DB-A5：DEF/Verilog/sidecar checkpoint 足以复现 Timing Lab 语义 | fresh replay 后 iDB diff + required validators 对拍 | 将缺失 state 纳入 sidecar 或限制该 capability 为 unsupported |

---

## 14. 里程碑、PR 切片与完成定义

### 14.1 里程碑

| 阶段 | 周期 | 交付 | 退出门禁 |
|---|---:|---|---|
| DB-A0 事实冻结 | 2 周 | direct-write inventory、CURRENT D1 audit、InputManifest/ObjectId/Unit schema、benchmark protocol | 10 个设计 import source/units/legacy mutations 台账完成 |
| DB-A1 只读身份 | 3 周 | ObjectRegistry、SnapshotCatalog read-only、DesignView/inspect/diff、D1 adapter | clean import hash/object mapping 稳定；no raw pointer Agent API |
| DB-A2 instance delta | 4 周 | Move/Resize/SwapVt schema、preflight/apply/inverse/dirty/invariants | 1000 apply/rollback + replay 零 semantic diff |
| DB-A3 topology delta | 4 周 | InsertBuffer/Reconnect、connectivity dirty/actual touched、iTO/iNO bridge | Timing Lab candidate 不再 direct-write iDB |
| DB-A4 route delta | 4 周 | shape/via codec、spatial/layer lease、route dirty/invalidation | local route round-trip + scope expansion rejection |
| DB-A5 durability/concurrency | 4 周 | CAS/catalog/head CAS/lease fence/fault recovery/tenant ACL | kill/race/ACL matrix 全部无 false success |
| DB-A6 compact/replay | 3 周 | checkpoint/compaction/schema migration/fresh-process replay | declared persisted capabilities round-trip and replay pass |

### 14.2 建议 PR 顺序

```text
DB-0  CURRENT mutation inventory + schemas + DesignState D1 contract tests
DB-1  ObjectRegistry/UnitSystem/InputManifest + read-only DesignView/inspect
DB-2  SnapshotCatalog + deterministic import/hash + state.diff
DB-3  MoveInst/ResizeInst/SwapVt + inverse + dirty/invariant dual-run
DB-4  InsertBuffer/Reconnect + connectivity codec + iTO/iNO facade migration
DB-5  CAS ArtifactManifest + branch CAS/lease/idempotency + failure injection
DB-6  RouteShape/Via + spatial/layer scope + iRT facade migration
DB-7  checkpoint/compaction/replay + export round-trip + multi-tenant hardening
```

每个 PR 附带：schema version/compatibility、CURRENT consumer migration list、scope/permission、pre/post/inverse、actual touched/dirty/invalidation、positive/negative/fault test、benchmark effect 和 `49/12` contract impact。只包装已有 setter、没有 inverse/replay/negative case 的提交不算 delta 支持。

### 14.3 完成定义

一个 `TypedDelta` 类型达到 production-eligible（不等于 signoff-qualified）的定义：

1. schema 和 action class 已版本化，validator 拒绝未知 semantic field；
2. ObjectRef/generation、context、intent/tech mapping、lease/scope 的前置条件可机械验证；
3. after state、actual touched、conservative dirty/invalidation、before image/inverse 或 checkpoint 均可审计；
4. apply、rollback、fresh replay、compaction 后 semantic diff 对拍通过；
5. structural invariant coverage 与 skipped/unsupported 明确，failure injection 无 base/head 污染；
6. 至少一个真实领域 consumer 走 facade，legacy direct-write path 已阻断或标 unsafe；
7. `49` 能由 delta/invalidation 生成 required claims，`12` 的 cache/evidence 能引用完整 refs；
8. benchmark 和 H-DB 分桶证据已发布，未达域被 capability registry 降级或禁用。

---

## 15. 开放问题、风险与版本历史

| ID | 问题 | 当前处理原则 |
|---|---|---|
| OI-DB-01 | iDB 所有对象的 canonical codec/round-trip 覆盖 | 先 Timing Lab object kinds；未知字段列 non-persisted/unsupported，不猜测 |
| OI-DB-02 | `IdbBuilder`/DataManager singleton 的 process reset 成本与污染 | 未通过 double-design soak 前只用 isolated worker，不开放 shared in-process branches |
| OI-DB-03 | ObjectId 初始 mapping 对 parser 版本/DEF 重排的稳定性 | 以 corpus 验证；无 stable discriminator 的 kind 禁止 cross-snapshot mutation |
| OI-DB-04 | route shape/via 与 iRT/iDRC 私有索引同步 | 先 adapter + full rebuild oracle；通过后才启用 local incremental claim |
| OI-DB-05 | CAS 后端和跨 host atomicity | 先抽象 `CasStore`；catalog conditional write 是唯一 publish authority |
| OI-DB-06 | PDK/DEF/Verilog artifact 的授权与 retention | 由 tenant/license label 先行；不因 dedup 共享可见性 |
| OI-DB-07 | legacy `DesignState` API 是否纳入长期公共 ABI | DB-A1 后只以 facade 对外；内部 D1 API 可迁但需 adapter/conformance test |
| OI-DB-08 | merge 的语义与 QoR risk | iDB 只提供 conflict/revalidation；Runtime policy 与领域 tool 决定是否建新的 merge proposal |

### 版本历史

- ai1.1（2026-07-23）：按 `12` 的实施规格深度重写；增加 CURRENT/TARGET 分层、现有 `DesignState` D1 审计、完整 schema/状态机/CAS/ACL/跨模块契约、LLD、测试、基准和 PR 定义。
- ai1.0（2026-07-23）：提出 stable ID、snapshot、TypedDelta、DirtySet 和初步开发路径。
