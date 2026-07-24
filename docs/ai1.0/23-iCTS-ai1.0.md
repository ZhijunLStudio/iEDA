<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 23 · iCTS Agent 原生时钟树实施规格 · ai1.1

> 基线：`docs/ai/23-iCTS.md` 负责 iCTS kernel、商业相关性和传统 flow 演进；本文定义 Agent 原生 iCTS 的 capability、状态、数据、事务和验证契约。
>
> 成熟度纪律：本文以 **CURRENT** 表示 2026-07-24 在当前工作区可由源码、CMake 或测试定位的事实，以 **TARGET** 表示尚待实现的 ai1.1 能力。`ClockDAG`、FastSTA incremental sizing、iDB writeback restore 等 CURRENT 资产不等于 immutable snapshot、跨工具原子事务或 signoff timing 已经存在。
>
> 首个垂直闭环：在冻结的 post-place snapshot 上，针对一个 primary/generated clock 产生 no-op、H-tree 参数、buffer sizing 三类候选；每个候选在独立 branch 上依次完成 iDB apply、iPL 单元合法化、iRT clock-net route、RC、common iSTA setup/hold/DRV、Verification Hub certificate 和 iEval gate。useful skew 在这一闭环稳定后才进入受控 profile。

---

## 0. 目标、非目标与唯一责任

### 0.1 目标

iCTS Agent 不是把 `CTSAPI::runCTS()` 包成一个工具调用，而是把时钟树决策拆成可观察、可比较、可回滚和可验证的阶段：

```text
inspect immutable clock state
  -> diagnose clock-domain problems
  -> propose a bounded candidate portfolio without mutation
  -> Runtime forks one branch per selected proposal
  -> apply typed ClockDelta on the branch
  -> legalize / route / extract / analyze setup+hold
  -> Verification Hub qualifies required claims
  -> iEval compares QoR and applies policy gates
  -> Runtime commits one fresh candidate or rejects all
```

ai1.1 的目标是：

- 每次调用绑定 `snapshot / intent / scenario / tech / policy / toolchain / seed / budget`；
- 以 stable typed ID 表达 clock、source、sink、buffer、net、sink group 和 proposal-only node，名字仅用于显示；
- 将 inspect、diagnose、propose、apply、verify 分离，证明 propose 无设计副作用；
- 复用 CURRENT H-tree、characterization、FastSTA、buffer sizing、routing 原语和 ClockDAG，不平行重写内核；
- 将低成本 clock estimator 与 common iSTA setup/hold 真值分层，禁止 FastSTA 自证 F3；
- 对 topology、buffer/sizing、useful skew、incremental repair 给出可执行 action、前置条件、inverse、dirty 和验证顺序；
- 让任一成功、拒绝、partial、unsupported、timeout、cancel 和 rollback failure 都有机器可读结果与 evidence；
- 让另一个干净 worker 能从 refs、schema、binary/config 和 seed 重放候选及决定。

### 0.2 非目标

- iCTS 不拥有 immutable snapshot、branch head、lease 或 commit；这些属于 iDB/Design State 与 Runtime。
- iCTS 不修改 SDC clock period、waveform、clock group、exception、uncertainty 或 dont-touch；需要变更时只生成高权限 `IntentPatch` 建议，不能混入 `ClockDelta`。
- iCTS 不实现 standard-cell legalizer、detailed router、RC signoff、MCMM STA、QoR gate 或证书调度；它调用 iPL、iRT/iRCX、iSTA、iEval 和 Verification Hub 的公共契约。
- FastSTA、Steiner estimate、HPWL 或 internal timing 只能作为 F0/F1/F2 估计；不能签发 setup/hold closure、route complete 或 DRC clean。
- ai1.1 不承诺所有 generated-clock、clock-gating、multi-source、mesh、resonant clock、post-route ECO 和 external signoff profile 都可写。未 qualification 的语义返回 `UNSUPPORTED`。
- 不允许通过 Agent payload 执行 Tcl、传任意 config/file path、暴露 `Idb*`/`Pin*`/`Clock*`，或直接写 global singleton。

### 0.3 唯一责任与边界

| Owner | 负责 | 不负责 |
|---|---|---|
| iCTS（本文） | clock read model、诊断、topology/buffer/skew proposal、ClockDelta 领域语义、clock-specific structural claims、dirty seed | snapshot/commit、placement/route/STA 真值、QoR 选择 |
| iDB / Design State（10） | stable ObjectRef、snapshot/branch、typed apply、actual touched、dirty/invalidation、rollback/replay | 决定时钟拓扑好坏 |
| Intent/Scenario（48） | clock/generated relation、propagation、mode/corner、clock group/exception canonical truth | 物理时钟树 mutation |
| Technology Knowledge（55） | qualified cell family、pin function、PVT、RC/routing rule refs、units | 候选选择或设计写入 |
| iPL（22） | clock buffer 的 site/row/fence/overlap 合法化及 actual moved | 时钟延迟/偏斜真值 |
| iRT/iRCX（26/28） | clock net route、NDR、via、DRC proxy、RC/coupling artifacts | clock intent 或 useful-skew policy |
| iSTA（27） | common propagated-clock MCMM setup/hold/DRV/CPPR 结果 | 选择/应用 CTS action |
| iTO（25） | data-path ECO、timing root cause 和受控修复 proposal | 擅自 resize/reconnect leased clock tree |
| iEval（12） | metric 口径、可比较性、Pareto、QoR gate、evidence pack | correctness certificate 或 commit |
| Verification Hub（49） | required claims、validator DAG、coverage、certificate freshness | 修改候选或给 QoR 排名 |
| Runtime（43） | branch、lease、budget、调度、选择、CAS commit/abandon | 定义 clock 物理真值 |

红线：`ClockObservation`、`ClockProposal`、`ClockDelta`、`MetricBundle`、`ValidationCertificate`、`DecisionRecord` 是不同对象。一个对象的 `SUCCESS` 不能替代另一个对象。

---

## 1. CURRENT 源码事实审计与 TARGET 差距

### 1.1 公共入口和生命周期（CURRENT）

| 资产 | 已核实能力 | 限制 / TARGET 缺口 |
|---|---|---|
| `src/operation/iCTS/api/CTSAPI.{hh,cc}` | singleton facade；`init/runCTS/report/resetAPI/lastStatus/outputSummary` | config/work-dir + ambient iDB；无 request context、snapshot、branch、budget、seed、cancel |
| `api/CTSStatus.hh` | `kOk/kNoOp/kNotInitialized/kConfigError/kFlowError/kReportError` typed 状态 | `ok()` 将 `kNoOp` 视为 ok；无 partial/unsupported/timeout/stale/conflict/rollback 语义 |
| `source/flow/Flow.{hh,cc}` | `read -> synthesis -> optimization -> instantiation -> evaluation`；setup/read/synthesis/instantiation 有结构化阶段状态 | 单个可变 `CTSRuntime`；不是 per-request session；evaluation readiness 不进入最终成功公式 |
| `Flow::runOptimization()` | optimization summary `success=false` 会把 `_run_summary` 置 failed；优化后重建 ClockDAG | 每 clock FastSTA solver failure 可被记录成 no-op reason 后继续其他 clock；reason 仍以字符串表达 |
| `source/utils/logger/Schema.*` | stage、diagnostic、runtime、表格报告 | 报告 schema 不是 Agent result/evidence schema，也不绑定 snapshot/context |

准确措辞：CURRENT 已不再是“optimization 完全不影响 flow 成败”；`accepted_edit_apply_failed` 会传播失败。真正缺口是 per-clock no-op/skip 语义、evaluation/外部 verification 不参与提交资格，以及整体仍是批处理 mutable session。

### 1.2 时钟语义与读模型（CURRENT）

| 资产 | 已核实能力 | 限制 / TARGET 缺口 |
|---|---|---|
| `database/adapter/sdc/SdcClockReader.*` | side-effect-free SDC subset reader；primary/generated clock、period、divide/multiply/invert、virtual、case analysis | 默认构造从 `dmInst` 取 SDC path；不是 canonical IntentRef/ScenarioSetRef consumer |
| `database/adapter/sdc/clock_trace/` | 对 SDC target 做时钟网追踪；报告 ambiguity、unowned clock-like net、mux/cycle 等；测试覆盖 generated/master ownership | 使用进程内 iDB/name；无 stable ObjectRef、consumer receipt、mode/scenario identity |
| `database/design/Clock.hh` | clock name/net name/period/source/loads/insts/nets、precluster metadata | 指针和名字是身份；无 generated relation、scenario、intent provenance |
| `database/design/ClockNetwork.hh` | domain/inst/net role、topology kind、`Empty/Planned/Instantiated/ProjectedToExternalDb` 生命周期 | “stable semantic model”仍绑定 design-owned raw pointers；不是跨 snapshot stable ID |
| `database/design/ClockDAG.*` | 按 clock 构建有向图、cycle 检查、reachable pins/nets、topological order、source-to-FF buffer-depth 统计 | read-only 进程内 projection；不带 snapshot、edge stable ID、RC/timing/scenario |
| `database/design/ClockLayout.*` | clock/net/inst/segment layout projection，带 role/domain/phase/depth 和 DBU | 主要以 name + clock index 定位；不证明 placement/route 合法或 artifact coverage |

### 1.3 综合、路由与优化资产（CURRENT）

| 资产 | CURRENT 行为 | Agent 化定位 |
|---|---|---|
| `flow/synthesis/topology`、`module/topology` | sink clustering、balanced H-tree shape、median/fixed root、depth/tolerance | deterministic topology proposal backend；先保留 legacy-equivalent candidate |
| `flow/synthesis/htree` | characterization table 驱动的 discrete 主路径；`enable_analytical_htree=false` 默认；可选 HiGHS analytical solver | topology/buffering candidate family，必须显式记录 family/config/solver status |
| `module/routing` | FLUTE/SALT/CBS/BST、Steiner/RCTree、terminal-coordinate legalization | F0/F1 topology/route estimate；不是 iRT detailed route |
| `module/routing/local_legalization` | 对 movable point/fixed point/region 做有界 assignment；Router 和 cluster constraints 消费 | 只可描述为端点坐标合法化原语；不是 post-buffer standard-cell iPL legalize |
| `database/adapter/fast_sta` | per-clock context、RC tree、timing/power、skew/cap/slew 查询；buffer master incremental update 和 dirty region | F1/F2 estimator 与 sizing backend；必须标 `cts.fast_sta`，不能冒充 common iSTA |
| `flow/optimization` | 基于 FastSTA 的 clock buffer sizing；exact/scalable solver；接受 edits 后写回 CTS design/layout | CURRENT 只覆盖 master sizing，不是 insert/delete/reconnect/useful skew portfolio |
| `flow/evaluation/qor` | ClockDAG coverage、buffer count/area、path depth、Steiner wirelength/HPWL 和报告 | E0 sensor；final summary 不包含 MCMM setup/hold、CPPR、route/DRC certificate |

CURRENT 不存在可定位的 Agent `inspect/propose/apply/verify` facade、`ClockContext/ClockIntent/ClockDelta` 公共 schema、useful-skew planner、snapshot/branch/lease、anytime checkpoint 或 Verification Hub 注册。本文后续对此均标 TARGET。

### 1.4 iDB 写回与恢复边界（CURRENT）

`source/database/io/WrapperClockWriter.cc` 在写前重建并验证 ClockDAG，收集 reachable clock nets/touched names，创建或更新 iDB clock buffer/net并重连 pins。失败时会：

- 删除本次创建的 clock nets 和 instances；
- 恢复捕获到的 pre-existing net pin attachment；
- 清空 CTS/iDB cross-reference map；
- 通过 `idb_clock_tree_restored` 报告恢复是否成功。

这是一项可复用的 **CURRENT 局部恢复资产**，但不是 TARGET 原子事务，原因是：

- 捕获集按 name 和当前 materialization scope 构建，没有 immutable base snapshot 或 branch head CAS；
- 恢复目标主要是 net attachment 和新对象，不能证明所有 instance master/location、route、RC、STA cache 和跨工具副作用均恢复；
- 成功写入直接作用于 current iDB，未产生通用 TypedDelta、actual touched、dirty/invalidation 或 durable candidate snapshot；
- worker crash、进程退出、跨服务失败和 stale proposal 没有统一恢复协议。

因此 TARGET 首版必须在隔离 branch/worker 中调用 legacy writer；失败的正确恢复基线是“丢弃 candidate materialization 并校验 base hash”，而不是只信任 in-process inverse。

### 1.5 构建与测试（CURRENT）

- `src/operation/iCTS/CMakeLists.txt` 无条件加入 `external_libs/source/api/test`，根级 target 为 `icts_source` 与 `icts_api`；当前没有 `agent/` target。
- `src/operation/iCTS/test/CMakeLists.txt` 用 `icts_add_test_executable` 注册 CTest；real-tech 和 slow real-tech 分别由 `ICTS_BUILD_REALTECH_TESTS`、`ICTS_BUILD_SLOW_REALTECH_TESTS` 控制，默认关闭。
- 当前测试源码含 161 个 `TEST/TEST_F/TEST_P` 宏，覆盖 config、ClockDAG、SDC trace、flow/no-op、writeback restore、FastSTA/OpenSTA micro-case、incremental master change、H-tree、analytical solver、characterization、clustering、routing 和 local legalization。
- CURRENT 测试没有 Agent schema conformance、stable ID across snapshot、branch apply/replay、跨 iPL/iRT/iSTA/Hub 事务、useful skew、cancel/resume、commercial ccopt harness。

### 1.6 成熟度矩阵

| 能力 | CURRENT | ai1.1 TARGET | 生产资格前置 |
|---|---|---|---|
| SDC clock subset/trace | 可用 | Intent/Scenario receipt + stable ID | parser/consumer coverage 对账 |
| Clock topology observation | ClockDAG/Layout 内存对象 | immutable paged `ClockTreeObservation` | snapshot/name-order/replay tests |
| H-tree synthesis | batch write flow | side-effect-free candidate backend | proposal digest 零写入 |
| Buffer sizing | FastSTA incremental CURRENT | typed resize proposals + branch delta | common iSTA differential |
| Buffer insert/delete/reconnect | synthesis 内部隐式发生 | explicit action + before/inverse/dirty | connectivity/property/fault tests |
| Useful skew | 未实现 | setup/hold constrained window proposal | common MCMM iSTA + hold guard |
| iDB mutation | direct current design + limited restore | branch-only typed apply | base pollution=0、replay |
| Cell legalization | 未接 iPL | scoped iPL legalization | exact actual touched/frozen proof |
| Clock routing/RC | internal estimate | iRT route + iRCX artifact | route/RC coverage certificate |
| Timing truth | FastSTA estimator | common iSTA propagated MCMM | incremental/full qualification |
| QoR/commit gate | report only | iEval + Hub + Runtime CAS | complete fresh bundle |
| Anytime/cancel/resume | 未实现 | safe checkpoints + incumbent | crash/cancel replay |

---

## 2. 功能需求、非功能需求与不变量

### 2.1 功能需求

| ID | 需求 | 优先级 | 可验收结果 |
|---|---|---:|---|
| FR-CTS-A01 | 注册 versioned capability manifest 和 qualification profile | P0 | capability/clock kind/stage/fidelity/PDK 未注册时 `UNSUPPORTED` |
| FR-CTS-A02 | inspect 只读取 immutable snapshot 并返回 stable clock tree view | P0 | 重命名/顺序变化不改变对象身份或语义 hash |
| FR-CTS-A03 | diagnose 分解 skew/latency/slew/cap/fanout/coverage/constraint 风险 | P0 | finding 指向具体 evidence、scope、scenario 和 estimator |
| FR-CTS-A04 | propose 至少产生 no-op、legacy-equivalent 和一个多样化候选且零写入 | P0 | propose 前后 snapshot digest 完全一致 |
| FR-CTS-A05 | topology proposal 显式给 sink partition、tree family、branch points、route assumptions | P0 | source-to-every-required-sink coverage=100% |
| FR-CTS-A06 | buffer proposal 支持 resize，后续资格化 insert/delete/reconnect | P0 | 每个 action 有 precondition、before、inverse、dirty seed |
| FR-CTS-A07 | ClockDelta 在 branch 上原子 materialize 并返回 requested/actual touched | P0 | 越 scope、stale generation、lease conflict 均 fail closed |
| FR-CTS-A08 | apply 后调用 iPL clock-cell legalize 并捕获所有 side-effect move | P0 | overlap/site/fence/frozen claims 完整 |
| FR-CTS-A09 | 调用 iRT/iRCX 形成 routed clock net 和 RC coverage | P0 | unrouted/partial RC 不可进入 ready-for-selection |
| FR-CTS-A10 | common iSTA 同时验证所有 required scenario 的 setup、hold、DRV、latency、skew | P0 | 缺任一 required scenario 不得 PASS |
| FR-CTS-A11 | Verification Hub 从 ClockDelta/dirty 规划并签发 fresh certificate bundle | P0 | certificate identity/coverage/expiry 可重算 |
| FR-CTS-A12 | iEval 对 base/candidate 做可比性、hard gate、Pareto 与 evidence pack | P0 | 不用隐藏总分越过 hold/DRV/route gate |
| FR-CTS-A13 | useful skew 以 sink arrival window 和物理实现 proposal 表达 | P1 | setup 获益、hold 损失、CPPR/uncertainty 全可见 |
| FR-CTS-A14 | 支持 dirty branch incremental repair/update | P1 | 未触及 clock domain hash 不变；范围扩大显式返回 |
| FR-CTS-A15 | 支持 progress/cancel/checkpoint/resume 和 best incumbent | P1 | partial incumbent 不可提交；恢复结果在容差内一致 |
| FR-CTS-A16 | 所有终态含 typed status/error、coverage、artifacts、disposition | P0 | partial/unsupported/timeout 不序列化成 success |
| FR-CTS-A17 | legacy Tcl/API 保持兼容并与 Agent facade 双跑 | 红线 | CURRENT golden 数值和退出语义无意外回归 |
| FR-CTS-A18 | 提供 replay、fault、performance、held-out 和 commercial differential harness | P0 | 失败/OOM/timeout 进入分母，报告可复算 |

### 2.2 非功能需求

| ID | 要求 |
|---|---|
| NFR-CTS-A01 | 所有 read/propose 请求必须显式携带 immutable `snapshot_ref`；禁止读取 ambient current design。
| NFR-CTS-A02 | 同 snapshot/context/schema/toolchain/config/seed/thread policy 的 deterministic profile 输出 canonical result digest 相同。
| NFR-CTS-A03 | metric 必有 unit、scenario、coverage、fidelity、estimator、tool/model hash；禁止裸 `double` 越过 Agent 边界。
| NFR-CTS-A04 | FastSTA 与 common iSTA 使用不同 metric namespace；低 fidelity 不能通过字段改名冒充高 fidelity。
| NFR-CTS-A05 | apply 只允许 branch + valid fenced lease；service 和 legacy worker 不持有 committed-head 写权限。
| NFR-CTS-A06 | actual touched 超 declared writable scope 时必须 rollback/abandon；不能扩大后沿用旧 proposal 风险结论。
| NFR-CTS-A07 | dirty/invalidation 是保守上界；依赖无法证明局部时升级到 clock-domain/design scope。
| NFR-CTS-A08 | 每个跨工具阶段都消费同一 snapshot lineage、IntentRef、ScenarioSetRef、TechContextRef；receipt 不一致立即 `CONTEXT_MISMATCH`。
| NFR-CTS-A09 | cancel/timeout/worker loss 后 committed head 不变；rollback 不可证明时 branch 标 `CORRUPTED` 并禁止复用。
| NFR-CTS-A10 | legacy singleton 在隔离性资格完成前只运行于 process worker；不同 candidate 不共享 cwd、reporter、CTSRuntime 或 FastSTA context。
| NFR-CTS-A11 | benchmark 固定 binary/compiler/machine/thread/cache/seed/budget，报告 median/MAD/p95/RSS，不只报告最好一次。
| NFR-CTS-A12 | name、path、Tcl、config 和 cell selector 均不作为权限或 identity；payload 只含 schema-validated ref/enum/value。

### 2.3 强制不变量

1. 每个 required sink 在物理 tree 中恰有一条被支持的 source-to-sink clock path；multi-source/mesh profile 除非单独 qualification，否则 `UNSUPPORTED`。
2. ClockDAG 无 cycle；每个 clock net 驱动语义满足 profile，禁止 dangling required sink、null driver 和跨 clock 非授权重连。
3. `ClockId` 绑定 source ObjectRef、intent node、mode/domain，不由 display name 单独决定。
4. proposal-only node 与 committed ObjectId 命名空间分离；apply 返回确定的 `provisional_id -> ObjectRef` 映射。
5. `ClockDelta` 只包含物理动作；period、exception、uncertainty、clock group 和 scenario 修改不属于 delta。
6. 所有 clock buffer master 必须来自当前 TechContext 中 qualified、not-dont-use、pin/function/PVT 匹配的集合。
7. required clock buffer 必须 placement legal；内部 terminal legalization 不能替代该 claim。
8. required clock net 必须 route/RC coverage 完整；flyline/Steiner estimate 不能标为 routed。
9. accepted candidate 在同一 required scenario set 上同时通过 setup、hold 和 DRV；setup 改善不能以新增 hold/DRV failure 换取。
10. partial/unsupported/timeout/cancel 的结果不能签发 complete bundle，也不能成为 committed head。
11. 未触及且冻结的 clock domain、data objects 和 intent hashes必须保持；任何差异都进入 actual touched 和新验证计划。
12. apply + inverse 或 candidate discard 后，base canonical state hash、head ref 和 fresh certificates 与调用前一致。

---

## 3. Capability 面、生命周期与状态机

### 3.1 TARGET capability

| Capability | 类型 | 主要输入 | 主要输出 | 设计副作用 |
|---|---|---|---|---|
| `clock.capabilities@1` | discover | context/profile selector | manifest、qualification、limits | 无 |
| `clock.inspect@1` | read | context + clock/scope selector | `ClockTreeObservation` | 无 |
| `clock.diagnose@1` | read | observation ref + profile | `ClockDiagnosis` | 无 |
| `clock.propose_topology@1` | propose | diagnosis + intent + budget | `ClockProposal[]` | 无 |
| `clock.propose_buffering@1` | propose | tree view + master set + budget | `ClockProposal[]` | 无 |
| `clock.propose_useful_skew@1` | propose | common iSTA path/slack refs | window + implementation proposals | 无 |
| `clock.apply@1` | branch write | fresh proposal + branch/lease | candidate snapshot + `ClockDeltaResult` | 仅 candidate branch |
| `clock.verify@1` | read/orchestrate | candidate + verification profile | claims、metrics、bundle refs | 仅 artifacts |
| `clock.progress@1` | read | operation ref | progress/incumbent/checkpoint | 无 |
| `clock.cancel@1` | control | operation ref + fence | terminal/cancel-pending result | 无主设计写入 |
| `clock.resume@1` | control | checkpoint + same context | new operation ref | 仅 candidate branch |

`clock.verify` 只编排/聚合 iCTS 自有 structural evidence 和外部 certificate refs；它不能替 Verification Hub 签署其他 owner 的 claim。`clock.apply` 返回 candidate，而不是 commit。

### 3.2 五段式边界

```text
INSPECTED
  observation bound to immutable refs; coverage may be partial
      |
DIAGNOSED
  findings + evidence; no action implied
      |
PROPOSED
  immutable proposal + predicted effects; snapshot unchanged
      |
APPLIED_ON_BRANCH
  actual ClockDelta + candidate snapshot + dirty/invalidation
      |
VERIFIED / REJECTED / INCOMPLETE
  external certificates + iEval decision inputs; Runtime owns selection
```

禁止的捷径：`diagnose -> direct setter`、`propose -> mutate current CTSRuntime`、`apply -> saveDef main`、`FastSTA target_met -> commit`、`iCTS verify -> self-issued STA PASS`。

### 3.3 Operation 状态机

```text
ACCEPTED -> VALIDATING_CONTEXT -> MATERIALIZING_READ_VIEW
         -> INSPECTING/DIAGNOSING/GENERATING
         -> PROPOSAL_READY                         # read/propose terminal

PROPOSAL_READY -> ACQUIRING_LEASE -> PREFLIGHT
               -> APPLYING_IDB -> LEGALIZING -> ROUTING -> EXTRACTING
               -> ANALYZING -> VERIFYING -> READY_FOR_SELECTION
               -> SELECTED | REJECTED | ABANDONED  # Runtime transitions
```

任一非终态都可在 safe point 转 `CANCEL_PENDING`。终态集合固定为：

```text
SUCCESS | NO_CHANGE | PARTIAL | UNSUPPORTED | TIMEOUT | CANCELLED
REJECTED | CONFLICT | STALE | FAILED | FAILED_ROLLBACK
```

- `SUCCESS` 仅表示当前 capability 的完整契约完成，不自动表示可 commit；
- `NO_CHANGE` 是完整执行后的合法结果，必须说明 no-op 原因；
- `PARTIAL` 必须列出 produced/missing/skipped scope，不满足下游完整输入；
- `TIMEOUT` 可附 incumbent/checkpoint，但默认 disposition 为 `NON_COMMITTABLE`；
- `FAILED_ROLLBACK` 使 branch `CORRUPTED`，需要 Runtime 回收 worker/materialization。

### 3.4 Proposal 新鲜度

`ClockProposal` 只有在以下 fingerprint 全相等时可 apply：

```text
base_snapshot_ref
clock_tree_semantic_hash
clock_intent_ref + scenario_set_ref + tech_context_ref
writable_scope_ref + frozen_scope_hash
generator/config/model/schema versions
```

任一 ObjectRef generation、sink membership、master qualification、route artifact 或 required scenario 变化都使 proposal `STALE`。Runtime 不自动 rebase 高风险 clock proposal；必须重新 inspect/diagnose/propose。

---

## 4. 公共上下文、身份与请求 schema

### 4.1 `ClockContext`（TARGET）

```yaml
schema: ieda.clock.context@1.0
request_id: 018f...
tenant_ref: tenant:project-a
snapshot_ref: sha256:immutable-design-state
branch_ref: null                    # apply/verify 时必填
expected_head_ref: null             # apply 时必填
intent_ref: sha256:canonical-clock-intent
scenario_set_ref: sha256:required-mcmm-set
tech_context_ref: sha256:pdk-lib-rc-routing-context
policy_ref: sha256:clock-policy
toolchain_ref: sha256:binary-build-adapter-manifest
stage: post_place                   # post_place | post_cts | post_gr | post_route
scope_ref: sha256:clock-domain-object-region-scope
fidelity:
  requested: F1                    # F0 | F1 | F2 | F3 | F4 | AUTO
  allow_downgrade: false
  required_for_selection: F3
budget:
  wall_ms: 30000
  cpu_ms: 120000
  memory_mb: 8192
  max_candidates: 16
  max_actions: 256
  max_new_buffers: 64
  max_moved_cells: 128
  max_scope_expansions: 1
determinism:
  seed: 17
  thread_count: 1
  deterministic: true
  tie_break: stable_object_id
```

规则：

- inspect/propose 必须有 `snapshot_ref`；apply 还必须有 `branch_ref/expected_head_ref/lease_ref`；
- timing、useful skew 和 production eligibility 必须有非空 required `scenario_set_ref`；
- `AUTO` 只允许根据 policy 向更高可信度升级，不能将显式 F3 静默降为 F1；
- budget 是 hard upper bound；超过返回 timeout/scope expansion，不修改 policy；
- 即使算法不使用随机数也记录 seed；非 deterministic backend 记录重复协议和分布结果。

### 4.2 Stable ID 规则（TARGET）

```text
ClockId       = "clk:sha256:" + sha256(lineage + source_pin_object_id + intent_node_id + mode_id + generation)
ClockNodeRef  = {snapshot_ref, object_ref(pin|instance|io_pin)}
ClockNetRef   = {snapshot_ref, object_ref(net)}
SinkGroupId   = sha256(canonical sorted sink ObjectIds + intent/scenario semantics)
TreeEdgeId    = sha256(clock_id + from_node_id + to_node_id + edge_role)
ProposalNodeId= {proposal_id, local_ordinal, role}       # not an ObjectId
ActionId      = {proposal_id, canonical_action_ordinal}
```

- rename 保持 ObjectId/ClockId，display name 可以变化；delete/recreate 同名对象推进 generation，旧 ref 为 `STALE_OBJECT`；
- 从 iDB 导入时使用 iDB ObjectRegistry 的唯一映射，不在 iCTS 另造持久 ID；
- new buffer/net 在 proposal 中使用 `ProposalNodeId`，apply 由 iDB reserve/materialize 后返回 ObjectRef mapping；
- action、sink、master、edge 和 scenario 列表按 typed ID canonical sort；指针地址、unordered iteration、绝对路径和时间戳不得进入 hash；
- CURRENT `Clock*`、`Pin*`、clock index、FastSTA node id、Tree node id 和 name 都只能存在于 worker adapter 内。

### 4.3 `ClockIntent` consumer view（TARGET）

```yaml
schema: ieda.clock.intent_view@1.0
intent_ref: sha256:...
clock_id: clk:sha256:generated-clock-semantic-id
clock_identity: {source_pin: obj:pin:42:3, intent_node: intent:clock:7, mode: func, generation: 1}
kind: generated                     # primary | generated
source_pin: obj:pin:42:3
master_clock_id: clk:sha256:master-clock-semantic-id
generated_relation:
  source: obj:pin:20:1
  divide_by: 2
  multiply_by: 1
  invert: false
waveform_ns: [0.0, 0.5]
period_ns: 1.0
propagation: propagated             # ideal | propagated
required_sink_groups:
  - sink_group_id: sha256:...
    sinks_ref: cas://.../sorted-sink-set
    latency_window_ns: [0.10, 0.35]
    skew_bound_ns: 0.04
clock_groups_ref: sha256:...
uncertainty_ref: sha256:...
exceptions_ref: sha256:...
protected_objects_ref: sha256:...
buffer_policy:
  eligible_master_set_ref: sha256:...
  dont_use_ref: sha256:...
  max_fanout: 32
  max_cap_pf: 1.5
  max_slew_ns: 1.5
route_policy_ref: sha256:clock-ndr-shield-layer-policy
coverage:
  parser: complete
  consumer_receipt_ref: cas://.../intent-receipt
```

`ClockIntent` 是 48 的 canonical view，iCTS 只消费，不自行修正。ideal/propagated 混用、generated master/source unresolved、required sink set 空或 consumer receipt 不一致时，写 capability 返回 `CONTEXT_INCOMPLETE` 或 `UNSUPPORTED_CLOCK_SEMANTICS`。

### 4.4 公共请求与返回 envelope（TARGET）

```yaml
schema: ieda.clock.request@1.0
capability: clock.propose_topology@1
context: { ...ClockContext... }
selector:
  clock_ids: [clk:sha256:clock-semantic-id]
  sink_group_ids: [sha256:...]
options_ref: sha256:canonical-generator-options
idempotency_key: sha256:caller-operation-identity
lease_ref: null
```

```yaml
schema: ieda.clock.result@1.0
operation_ref: op:clock:...
capability: clock.propose_topology@1
status: SUCCESS
phase: PROPOSAL_READY
context_receipt:
  snapshot_ref: sha256:...
  intent_ref: sha256:...
  scenario_set_ref: sha256:...
  tech_context_ref: sha256:...
  policy_ref: sha256:...
  toolchain_ref: sha256:...
payload_ref: cas://.../clock-proposals
coverage: {requested_clocks: 1, completed_clocks: 1, missing: []}
diagnostics: []
artifacts: [cas://.../manifest]
resource_usage: {wall_ms: 812, cpu_ms: 790, peak_rss_mb: 220}
determinism_receipt: {seed: 17, threads: 1, result_digest: sha256:...}
disposition: READ_ONLY
```

未知 major schema 或未知 semantic field 必须拒绝；明确 non-semantic minor metadata 可被兼容 reader 忽略。idempotency key 只在完整 context/fingerprint 相同的情况下命中。

---

## 5. iCTS 领域 schema

### 5.1 `ClockTreeObservation`（TARGET）

```yaml
schema: ieda.clock.tree_observation@1.0
observation_id: sha256:canonical-observation
context_receipt: {snapshot_ref: sha256:..., intent_ref: sha256:..., scenario_set_ref: sha256:..., tech_context_ref: sha256:...}
clock:
  clock_id: clk:sha256:clock-semantic-id
  kind: primary
  source: obj:pin:42:3
  master_clock_id: null
  propagation: propagated
  period_ns: 1.0
tree:
  topology_kind: htree
  roots: [obj:pin:42:3]
  node_table_ref: cas://.../clock-nodes
  edge_table_ref: cas://.../clock-edges
  sink_group_table_ref: cas://.../sink-groups
  topology_hash: sha256:...
  source_reachable_sink_count: 2048
  required_sink_count: 2048
metrics:
  - {name: cts.fast_sta.skew, value: 0.032, unit: ns, fidelity: F1, scenario: cts_internal, coverage: 1.0}
  - {name: clock.wirelength.steiner, value: 12450.0, unit: um, fidelity: F0, scenario: none, coverage: 1.0}
physical:
  placement_coverage: partial
  route_coverage: estimate
  rc_coverage: estimate
  legal_claim_ref: null
  route_claim_ref: null
coverage:
  status: PARTIAL
  missing: [common_mcmm_timing, placement_certificate, detailed_route]
provenance:
  reader: icts.clock_dag_adapter@1
  artifacts: [cas://...]
```

node table 至少包含 node ID、ObjectRef/proposal ID、role、master、location+unit、domain、level、fanout、cap/slew/arrival 的 per-estimator records；edge table 至少包含 edge ID、from/to、net ObjectRef、role、route state、length、RC artifact ref。缺指标是 `null + reason`，不是 0。

### 5.2 `ClockDiagnosis`（TARGET）

```yaml
schema: ieda.clock.diagnosis@1.0
diagnosis_id: sha256:...
observation_id: sha256:...
findings:
  - finding_id: finding:clock:...
    kind: skew_violation              # skew|latency|slew|cap|fanout|coverage|connectivity|physical
    severity: error
    clock_id: clk:sha256:clock-semantic-id
    scenario_ids: [func_ss_0p72v_125c]
    object_scope_ref: sha256:...
    measured: {value: 0.082, limit: 0.040, unit: ns, fidelity: F3}
    attribution:
      topology: 0.25
      buffer_delay: 0.20
      route_rc: 0.45
      uncertainty_or_unattributed: 0.10
    evidence_refs: [cas://.../path-pairs, cas://.../rc-breakdown]
    allowed_action_families: [resize, topology_rebuild, local_repair]
    unsupported_reasons: []
coverage: {required_scenarios: 4, analyzed_scenarios: 4, status: COMPLETE}
```

attribution 不是必须伪装成精确因果。无法由 evidence 守恒解释的部分进入 `uncertainty_or_unattributed`；低 fidelity finding 不能给高 fidelity action 签发风险豁免。

### 5.3 `ClockProposal`（TARGET）

```yaml
schema: ieda.clock.proposal@1.0
proposal_id: sha256:canonical-proposal
kind: topology                     # no_op | topology | buffering | local_repair | useful_skew
base_fingerprint:
  snapshot_ref: sha256:...
  topology_hash: sha256:...
  intent_ref: sha256:...
  scenario_set_ref: sha256:...
  tech_context_ref: sha256:...
clock_ids: [clk:sha256:clock-semantic-id]
family: balanced_htree
sink_partitions_ref: cas://.../partition
target_arrival_windows_ref: null
planned_nodes_ref: cas://.../proposal-nodes
planned_edges_ref: cas://.../proposal-edges
master_set_ref: sha256:qualified-masters
placement_windows_ref: cas://.../windows
route_assumptions_ref: sha256:...
requested_actions_ref: cas://.../draft-actions
declared_writable_scope_ref: sha256:...
frozen_complement_hash: sha256:...
predicted_metrics:
  - {name: cts.fast_sta.skew, delta: -0.018, unit: ns, fidelity: F1, uncertainty: 0.008}
risks:
  setup: unknown
  hold: high
  placement: medium
  route: medium
required_validators:
  - clock.connectivity.complete@1
  - placement.legal@1
  - route.clock.complete@1
  - timing.setup_hold_drv@1
fallback: {kind: no_op, proposal_id: sha256:...}
generator: {id: icts.balanced_htree@1, config_ref: sha256:..., seed: 17}
```

proposal 是 immutable decision object，不是 delta，也不是修改后的设计。必须保留 no-op baseline；“同 family 只改一个相邻 size”不算 topology diversity。

### 5.4 `ClockDelta`（TARGET）

```yaml
schema: ieda.clock.delta@1.0
delta_id: sha256:canonical-requested-delta
proposal_id: sha256:...
base_snapshot_ref: sha256:...
expected_head_ref: sha256:...
lease_ref: lease:...
declared_writable_scope_ref: sha256:...
preconditions_ref: cas://.../typed-preconditions
operations:
  - action_id: action:0
    kind: InsertClockBuffer
    target: {net: obj:net:300:2, split_loads_ref: sha256:...}
    new_inst: {proposal_node_id: pnode:3, master: tech:cell:CLKBUF_X4, location_window_ref: sha256:...}
    new_net: {proposal_node_id: pnet:4, role: sink_tree}
    expected_before_ref: sha256:net-connectivity-before
  - action_id: action:1
    kind: ResizeClockBuffer
    target: obj:instance:900:1
    from_master: tech:cell:CLKBUF_X2
    to_master: tech:cell:CLKBUF_X4
    expected_pin_function_hash: sha256:...
  - action_id: action:2
    kind: ReconnectClockPin
    target: obj:pin:901:1
    from_net: obj:net:300:2
    to_net: pnet:4
  - action_id: action:3
    kind: SetClockRoutePolicyRef
    target: pnet:4
    route_policy_ref: sha256:qualified-clock-route-policy
inverse_strategy: before_image
expected_dirty_seed_ref: sha256:...
required_postconditions_ref: sha256:...
```

允许的首批物理 action：`InsertClockBuffer`、`RemoveClockBuffer`、`ResizeClockBuffer`、`ReconnectClockPin`、`CreateClockNet`、`RemoveClockNet`、`MoveClockBufferHint`、`SetClockRoutePolicyRef`。每种 action 必须声明 ownership、object generation、before image、预期 touched、inverse 和 validators。

`SetSinkArrivalWindow` 只存在于 useful-skew proposal 的目标层，不是修改 SDC 的 delta action；最终 delta 必须由合法的 buffer/topology/location/route 动作实现窗口。

### 5.5 `ClockDeltaResult` 与 evidence（TARGET）

```yaml
schema: ieda.clock.delta_result@1.0
delta_id: sha256:...
status: SUCCESS
base_snapshot_ref: sha256:...
candidate_snapshot_ref: sha256:...
actual_delta_ref: cas://.../normalized-actual-delta
provisional_object_map_ref: cas://.../proposal-to-object-map
actual_touched_ref: sha256:...
dirty_set_ref: sha256:...
invalidation_set_ref: sha256:...
inverse_delta_ref: sha256:...
before_state_hash: sha256:...
after_state_hash: sha256:...
frozen_complement_before_hash: sha256:...
frozen_complement_after_hash: sha256:...
stage_receipts:
  idb_apply: cas://...
  placement: cas://...
  route: cas://...
  rc: cas://...
  timing: cas://...
  verification_bundle: cas://...
  evaluation: cas://...
coverage: {status: COMPLETE, missing: []}
disposition: READY_FOR_SELECTION
```

Evidence manifest 至少记录 source/build/schema/config/model hash、全部 context refs、request/result/delta/certificate/metric refs、实际 fidelity、resource usage、seed/thread、worker sandbox、warnings/errors 和 artifact checksums。普通日志可作为附件，但不能是唯一证据。

---

## 6. 候选算法与物理风险控制

### 6.1 统一 proposal pipeline（TARGET）

```text
resolve ClockContext and qualified capability profile
  -> inspect source/sinks/current tree/physical and timing coverage
  -> partition problems by clock/domain/sink group/root cause
  -> emit no-op baseline
  -> run bounded topology/buffering/skew generator portfolio
  -> reject structural/intent/tech/scope infeasible candidates
  -> canonicalize and deduplicate by physical semantic hash
  -> F0 feasibility and cost vector
  -> F1 calibrated FastSTA/geometry screening
  -> preserve non-dominated + uncertainty/novel candidates
  -> return Top-K immutable proposals; no design mutation
```

排序规则固定为：hard-feasible 优先，然后 Pareto dominance，再按 policy 显式的 lexicographic key，最后按 `proposal_id`。禁止在 result 中只保留一个隐藏加权总分；若搜索内部使用权重，必须同时输出原始 skew/latency/power/wire/buffer/risk 分量和 policy ref。

### 6.2 Topology 构建

候选 family 及成熟度：

| Family | 成熟度 | 后端 / 用途 | 资格限制 |
|---|---|---|---|
| `no_op` | TARGET facade，CURRENT state 可读 | 当前 tree 的零动作基线 | 所有请求必有 |
| `legacy_discrete_htree` | CURRENT kernel | characterization table + depth/segment/frontier + embedding | ai1.1 首个 legacy-equivalent proposal |
| `analytical_htree` | CURRENT 可选 kernel | HiGHS analytical H-tree，默认关闭 | 只在 solver/build profile qualification 后启用 |
| `geometric_clustered_htree` | CURRENT 原语 + TARGET proposal 化 | sink clustering + balanced H-tree | partition/centroid/constraint evidence 完整 |
| `bst_local_branch` | CURRENT routing 原语 + TARGET proposal 化 | bound-skew local branch/route candidate | 不宣称替换整棵 H-tree spine |
| `timing_weighted_tree` | TARGET | common iSTA criticality/sensitivity 驱动 partition 和 branch window | F3 scenario coverage 完整后才能 apply |

不把 CURRENT H-tree 描述成 DME/ZST，也不在没有实现和测试时宣称这些 family 已支持。未来增加新 topology family 必须注册独立 capability qualification，不得复用旧 family 名称改变算法。

每个 topology generator 必须执行：

1. 按 stable ObjectId 排序并校验 required sink membership、source、generated relation、clock boundary 和 protected objects；
2. 按 sink group、region/fence、macro/regular、latency window 和 clock gating boundary 建立不可跨越的 partition constraints；
3. 在预算内枚举 depth、partition、branch point、root policy 和 family；
4. 只生成 `ProposalNodeId`/placement window，不分配 committed name/ObjectId；
5. 为每条 edge 给 route layer/NDR/shield assumptions 和 geometric lower bound；
6. 选择 qualified buffer family/级数，检查 fanout/cap/slew 的 F0 上界；
7. 计算 source reachability、sink uniqueness、path-depth、wire/buffer/power estimate 和 placement capacity；
8. 对等价 topology canonicalize；保留各 Pareto bucket 的 bounded frontier；
9. 产出 required validators、known unsupported、uncertainty 和 fallback。

复杂度必须在 manifest 中声明。balanced H-tree 与 deterministic partition 目标为 `O(n log n)`；candidate enumeration 由 `max_candidates/max_depth/options` 硬限制。任何指数/solver 路径达到 budget 时返回 `TIMEOUT` + 已完整生成的 incumbent，不得返回半棵 tree 为 SUCCESS。

### 6.3 Buffer 插入与 sizing

CURRENT sizing 的准确起点是 `flow/optimization`：从 configured buffer types 取得合法 master，构建 clock route geometry/FastSTA context，按 cap/slew baseline 运行 exact 或 scalable solver，并将 accepted master changes 写回 CTS design/layout。TARGET 先将这条路径拆成 `propose resize -> branch apply -> common verify`，再扩展 insert/delete/reconnect。

TARGET buffering generator 的状态至少包含：

```text
State(level, subtree/sink_group, driver_master, load_cap_bin,
      input_slew_bin, arrival_window_bin, route_length_bin,
      buffer_count, area, power_estimate, provenance)
```

转移为 `keep / resize / insert / remove / split / reconnect`，但只有 capability profile 允许的转移进入 frontier。每次转移先检查 hard constraints：

- TechContext 中 pin function、footprint、PVT、dont-use、voltage domain；
- max fanout/cap/slew 和 root/sink boundary semantics；
- placement window 是否至少能容纳目标 cell，是否触及 fixed/dont-touch/fence；
- tree connectivity 和 generated/gating boundary；
- route length/resource 上界与 change budget。

在相同离散签名内保留 `(skew, latency, power, area, wire, action_count, risk)` 非支配项；binning 误差、pruning 数和被支配 witness 写入 evidence。F1 FastSTA 只排序，不允许删除 uncertainty 覆盖范围内可能成为 F3 最优的全部候选。held-out Top-K recall/regret 不合格时，缩小 pruning 或停用该 estimator。

### 6.4 Useful skew：setup/hold 双约束（TARGET）

useful skew 不是“把 skew 调大/调小”，而是对 sink group 的 arrival shift/window 提议。定义正的 `x_g` 为该 sink group clock arrival 变晚。对 launch group `l`、capture group `c` 的线性化路径：

```text
setup_slack' ~= setup_slack + x_c - x_l
hold_slack'  ~= hold_slack  + x_l - x_c
```

TARGET planner 使用 common iSTA 提供的 per-scenario path set、sensitivity、CPPR/uncertainty receipt，解有界 LP/portfolio：

```text
for every required setup path p:
  setup_slack_p + x_capture(p) - x_launch(p) - error_guard_p >= setup_floor_p
for every required hold path q:
  hold_slack_q + x_launch(q) - x_capture(q) - error_guard_q >= hold_floor_q
for every sink group g:
  latency_min_g <= base_latency_g + x_g <= latency_max_g
  |x_g| <= policy_shift_budget_g
for generated/master relations and clock groups:
  preserve declared phase/frequency/boundary constraints
objective vector:
  setup_violation, hold_violation, max_skew, latency, power, disruption
```

上述公式只用于 proposal 的线性化模型，不能替代 apply 后 propagated-clock STA。以下情况直接禁止 useful-skew apply：required scenario/path coverage 不完整、ideal/propagated 混用、CPPR/uncertainty receipt 缺失、generated relation unresolved、所需 shift 只能靠修改 SDC 实现、hold floor 无可行解。

solver 输出 sink windows 后，还必须由 topology/buffering/location/route generator 产生一个或多个 **物理实现 proposal**。`window feasible` 不等于物理 candidate feasible；实际 arrival 超 window 或 F3 setup/hold gate 失败时拒绝。

### 6.5 Setup/hold/DRV 风险规则

| 动作 | 主要 setup 风险 | 主要 hold 风险 | 其他必查 |
|---|---|---|---|
| stronger/closer buffer | launch clock/data 相对关系、capture 提前 | capture 提前可改善或恶化，须逐 path | cap、slew、power、legal |
| weaker/farther buffer | capture 变晚可能改善 setup | capture 变晚通常侵蚀 hold | slew、latency |
| topology repartition | common path/CPPR、跨组 latency | launch/capture group 非对称 | sink ownership、route |
| insert stage | latency 增加、jitter/uncertainty | 局部 phase shift | area、fanout、route |
| remove stage | latency 降低 | short-path 风险 | slew/cap、connectivity |
| route detour/NDR | RC/latency/variation | intentional delay 可能侵蚀对侧 | DRC、SI、congestion |

验证以 common iSTA 返回的实际结果为准，不依赖上表中的方向直觉。任一 required scenario 新增 setup/hold violation、DRV 超 policy、coverage 降低或 uncertainty 增大到门限外时是 `VALIDATION_FAILED`，不是“部分改善”。

### 6.6 Incremental dirty scope

`ClockDelta` 只声明 dirty seed；各 owner 按依赖扩大，iCTS 不自行缩小下游结果：

```text
clock action/object refs
  -> iDB connectivity + instance/master/location + net membership
  -> iPL rows/sites/bins/fences + actual moved neighbors
  -> iRT target nets + conflict/resource halo + coupling neighbors
  -> iRCX primary nets + coupling RC neighborhood
  -> iSTA clock propagation + launch/capture forward/backward cones + scenarios
  -> iTO conflict/repair eligibility + data paths sharing affected endpoints
  -> iPA/power and congestion metrics as policy requires
  -> Verification certificate invalidation
```

动作到最小 dirty seed：

| Action | iCTS seed | 必须失效 |
|---|---|---|
| resize buffer | inst + input/output pins + incident nets + downstream branch | cap/slew/RC load/timing/power/legal fit |
| insert/delete buffer | new/removed inst/net + split loads + ancestors/descendants | connectivity、placement、route、RC、STA、power |
| reconnect sink/group | old/new nets + moved sinks + both branches | sink coverage、topology、route/RC、setup/hold |
| move hint/legalize side effect | all actually moved insts + incident nets + spatial halo | placement、route、RC、timing、congestion |
| route policy/geometry | nets + layer/region + coupling halo | route/DRC、RC、STA、SI/EM as applicable |

若 iPL/iRT 扩大 actual scope 超过 lease/budget，返回 `SCOPE_EXPANSION_REQUIRED` 和建议 scope；Runtime 重新授权并从 fresh proposal 开始。验证“其他 clock domain 不变”使用 canonical topology/placement/connectivity/route hashes，不比较日志或遍历顺序。

---

## 7. Fidelity、anytime 与确定性

### 7.1 F0-F4 定义

| Fidelity | 内容 | CURRENT 可复用后端 | 允许用途 | 禁止结论 |
|---|---|---|---|---|
| F0 | topology/connectivity、几何、fanout/cap 上界、HPWL/Steiner、placement capacity | ClockDAG、TopologyGen、Router、Qor | feasibility、去重、粗筛 | timing/route/legal PASS |
| F1 | characterized segment + CTS FastSTA skew/slew/cap/power | characterization、FastSTA | candidate ranking、sizing search | common setup/hold closure |
| F2 | branch materialize + scoped iPL + early/local route/RC + relevant incremental iSTA | TARGET adapters | Top-K 验证、风险定位 | full required-scenario commit gate，除非 profile 明确资格化 |
| F3 | required scope/full clock route+RC、common propagated MCMM iSTA、DRV、placement/frozen checks | TARGET cross-tool chain | controlled commit eligibility | external signoff equivalence |
| F4 | qualified commercial/signoff external bridge | TARGET/可选 | release correlation/oracle | 缺 license 时伪装 skip/PASS |

每个 metric record 使用实际执行的 fidelity；requested F3 若只完成 F1，结果为 `PARTIAL` 或 `TIMEOUT`，不是 `SUCCESS(F3)`。F4 不可用时返回 `UNSUPPORTED_EXTERNAL_ORACLE`，本地 F3 仍可按自己的 qualification 独立判定。

### 7.2 Fidelity router

升级条件：near hard gate、F0/F1 disagreement、OOD、uncertainty 交叠 Pareto frontier、useful skew、clock/reset 高风险、route/placement capacity 临界、incremental/full audit 抽样、policy 强制。降档仅在 request 明确 `allow_downgrade=true` 且用途仍是 screening 时允许，并写 `downgrade_reason`。

同一候选的跨 fidelity 比较必须保留 estimator namespace：

```text
cts.fast_sta.skew             # F1
route.estimated_clock_delay   # F0/F2, adapter qualified
timing.clock.skew             # common iSTA F3
external.ccopt.clock_skew     # F4 reference
```

### 7.3 Anytime 与 checkpoint

安全 checkpoint 仅在一个候选完全构造、验证状态可序列化且没有半写 transaction 时产生：

```yaml
schema: ieda.clock.checkpoint@1.0
base_fingerprint: {...}
generator_state_ref: cas://...       # canonical queue/frontiers/dedup set
completed_proposals_ref: cas://...
best_incumbent_ref: cas://...
remaining_budget: {...}
seed: 17
thread_policy: deterministic
binary_config_model_refs: [...]
candidate_branch_refs: []            # only durable, closed transactions
```

progress event 至少包含 completed/queued/pruned/failed 数、current fidelity、wall/cpu/RSS、best incumbent metrics、safe-point sequence 和 cancellation state。cancel 不打断 iDB 原子 publish；在下一个 safe point 生效。resume 要求 base/context/toolchain/schema 相同，否则 `STALE_CHECKPOINT`。

### 7.4 确定性规则

- clock/sink/master/action/scenario 按 stable typed ID 排序；浮点比较使用版本化 tolerance 和 total-order tie-break；
- RNG 只能从 context seed 派生为 `hash(seed, clock_id, generator_id, ordinal)`，禁止共享全局 RNG；
- deterministic profile 固定 thread count/parallel reduction order；非 deterministic solver 记录版本、threads、seed 和重复统计；
- canonical serialization 统一 units、NaN/Inf rejection、map order 和 insignificant metadata；
- cache key 包含完整 context、scope、fidelity、generator/config/model/toolchain、seed/thread 和 capability qualification；
- timeout 不能改变已完成 proposal 的内容或排序，只改变返回集合和 checkpoint；相同 budget/safe-point policy 应可 replay。

---

## 8. Branch apply、跨工具事务与 rollback

### 8.1 Preflight（TARGET）

在任何 mutation 前按顺序检查：

1. schema/capability/profile/permission/budget；
2. snapshot/branch expected head/lease fencing generation；
3. proposal fingerprint、ObjectRef generation、clock intent/scenario/tech receipts；
4. source/sink/connectivity、protected/dont-touch、master/pin function；
5. declared writable scope、frozen complement、change budget；
6. required downstream capabilities和 artifacts 是否可用；
7. candidate worker/branch materialization hash 是否等于 base；
8. idempotency key 是否为相同 request 或冲突复用。

任何失败都发生在 mutation 前，并返回 typed error。不得先运行 legacy `runCTS()` 再从日志判断 proposal 是否 stale。

### 8.2 原子 apply 算法（TARGET）

```text
Runtime acquires fenced lease for clock domain + physical halo
  -> materialize immutable base into isolated candidate worker
  -> verify base hash and context receipts
  -> iDB preflight + reserve provisional object IDs
  -> begin branch transaction
       apply ClockDelta ops in canonical dependency order
       capture before image and normalized actual diff after every op group
       run immediate connectivity/name/master invariants
       publish candidate snapshot + actual delta + dirty/invalidation atomically
  -> close iDB transaction
  -> run downstream validation DAG as read/derived branch operations
  -> READY_FOR_SELECTION or abandon candidate
```

操作依赖序：创建 inst/net -> bind pins/master/location hint -> reconnect -> remove obsolete connectivity -> remove unreferenced old objects -> attach route policy。删除动作只有在所有 references 已转移且 postcondition 可证明时执行。

`clock.apply` 成功后也不修改 committed head。若 legacy writer 仍被使用，它只能在 candidate materialization 中执行；写前 checkpoint，写后以 before/after diff 构造 actual delta，不能把 `WrapperWriteSummary.success` 直接升级成 Agent success。

### 8.3 跨 iDB/iPL/iRT/iSTA/iTO/iEval/Hub 顺序

```text
0. Runtime / Hub plan
   resolve required claims; acquire clock-domain lease and iTO conflict exclusion

1. iDB
   apply physical ClockDelta -> candidate snapshot -> actual touched/dirty/invalidation

2. iPL
   materialize candidate -> legalize only authorized clock cells/halo
   -> return all moved cells and placement structural evidence

3. iRT then iRCX
   route affected clock nets under route policy; report scope expansion/unrouted
   -> extract primary/coupling RC artifacts with coverage

4. iSTA
   consume same Intent/Scenario/Tech refs; propagated-clock update
   -> setup + hold + DRV + latency/skew + CPPR/coverage per required scenario

5. iTO coordination
   inspect affected data paths and report repair need/conflict; no clock-tree write
   if Runtime approves an iTO repair proposal, create a new composite candidate and
   repeat iDB -> iPL -> iRT/iRCX -> iSTA; never append an unverified hidden ECO

6. Verification Hub
   aggregate iCTS structural claim plus iPL/iRT/iRCX/iSTA validators,
   check coverage/freshness/qualification and issue bundle verdict

7. iEval
   compare base/candidate metrics, enforce hard gates/Pareto/escalation,
   emit decision evidence; it does not commit

8. Runtime
   recheck branch head/context/certificate freshness and CAS commit one candidate,
   or abandon all candidates and release leases
```

iTO 的位置不是“替 CTS 自动修 hold”。它是独立 proposal owner；其 action 会改变 netlist/placement/route/STA dirty closure，必须形成新 candidate 和完整验证链。iCTS/iTO 同一 clock cell/net 的 lease 冲突返回 `CONFLICT`，不得 last-writer-wins。

### 8.4 Rollback 与恢复

| 失败点 | 默认动作 | 必须证明 |
|---|---|---|
| iDB publish 前 | abort transaction/inverse | base/head/hash 未变，无 visible artifact |
| iDB candidate publish 后、验证前 | abandon detached candidate | committed head 未变，candidate disposition 可审计 |
| iPL/iRT/iRCX/iSTA/Hub/iEval 失败 | 丢弃 candidate materialization；保留 failure evidence | base hash、worker isolation、无跨 candidate cache 污染 |
| Runtime CAS conflict | candidate 保持 detached 或按 policy abandon | 不自动 rebase，不覆盖新 head |
| worker crash/OOM | kill/reap worker，验证 branch catalog/head | 无半发布；临时 artifact 不可见或可 GC |
| inverse/restore mismatch | `FAILED_ROLLBACK` + branch CORRUPTED | 禁止复用，触发 incident evidence |

跨工具“回滚”优先通过丢弃 isolated candidate 实现，而不是要求每个 legacy singleton 完美 undo。需要 resume 的 durable checkpoint 只引用 closed candidate snapshot，不引用半修改内存。

### 8.5 Dirty 与 certificate 失效

候选产生后至少失效：旧 `clock.connectivity/sink_coverage/topology`、affected placement legality、clock route/DRC、RC、timing setup/hold/DRV、clock power/congestion；若实际触及 data cell/net，还失效对应 functional/connectivity/timing/power claims。Hub 根据 normalized actual delta 规划，不只看 requested action。

certificate identity 必含 candidate snapshot、intent/scenario/tech/policy、validator/tool/config、scope/coverage 和 evidence hash。任何 ref 或 covered object generation 变化后旧证书不可复用。

---

## 9. 验证、metric 与提交资格

### 9.1 iCTS 自有 structural claims（TARGET）

| Claim | iCTS 可证明内容 | 明确不证明 |
|---|---|---|
| `clock.context.resolved@1` | source/generated/master/sink groups/intent receipts 完整 | SDC 全语义 signoff |
| `clock.dag.valid@1` | 无 cycle、driver/load arc 可构建 | 物理 route 或 timing |
| `clock.sink_coverage.complete@1` | required sinks 全部且唯一 source-reachable | sink timing meet |
| `clock.master.qualified@1` | used masters 在 Tech qualified set，pin/function/PVT 匹配 | placement fit、library signoff completeness |
| `clock.scope.frozen@1` | iCTS read model 中 frozen clock topology hash 未变 | iPL/iRT 全对象冻结；由各 owner 补充 |
| `clock.delta.reversible@1` | normalized delta 有 before/inverse，branch round-trip hash 通过 | committed head 可随意回滚 |

每个 claim 返回 `PASS | FAIL | UNKNOWN | UNSUPPORTED`，其中 `UNKNOWN/UNSUPPORTED` 都不能被 bundle 当 PASS。

### 9.2 Required validation DAG

```text
context resolved
  -> iDB structural integrity + clock DAG + sink coverage + master qualification
  -> iPL site/row/fence/overlap + frozen placement
  -> iRT connectivity/resource/NDR/layer + clock route complete
  -> iDRC rule-profile coverage (as required by stage/policy)
  -> iRCX RC/coupling coverage
  -> iSTA propagated setup/hold/DRV/skew/latency for every required scenario
  -> power/congestion/SI/EM optional or mandatory per policy
  -> iEval comparable metrics + hard QoR gate
  -> Verification Hub complete/fresh bundle
```

可并行的 validator 由 Hub 规划，但依赖语义不变：没有 final actual placement 不能签 route，route/RC 不完整不能签 final propagated timing。scope-limited certificate 必须标 scope，不能冒充 full-design clean。

### 9.3 Clock metric 口径

| Metric | 必需维度 | 说明 |
|---|---|---|
| insertion latency | clock/sink group/scenario/transition/source-to-sink/unit | min/max/p50/p95 与 coverage，不只一个平均 |
| skew | clock/skew group/scenario/transition/CPPR policy | 明确 local/global、pair endpoints、uncertainty |
| setup/hold | scenario/path group/endpoint | WNS/TNS/violation count 分开；缺场景不是 0 |
| DRV | slew/cap/fanout + rise/fall + object | limit/source/violation magnitude |
| physical | buffer count/area/wire/via/route length/level | estimator、route state、unit、scope |
| power | switching/internal/leakage + activity provenance | FastSTA 与 iPA namespace 分开 |
| disruption | inserted/deleted/resized/moved/reconnected + scope amplification | requested vs actual |
| runtime | stage wall/cpu/RSS/cache/solver iterations | timeout/failure 同样记录 |

iEval 比较前必须确认 base/candidate 的 intent/scenario/tech、metric definition、unit、scope 和 fidelity 可比。若 candidate 使用更完整 coverage，不能直接将 base 缺失值当 0；应升级 base measurement 或返回 `INCOMPARABLE`。

### 9.4 Commit hard gates

首版 controlled R3 candidate 必须同时满足：

1. candidate snapshot/delta/actual touched/inverse/dirty/invalidation durable；
2. clock context、DAG、sink coverage、master qualification完整；
3. iPL legal/frozen、iRT route、iRCX RC coverage 为 PASS；
4. required scenario 的 common iSTA setup、hold、DRV 全部有结果并满足 policy；
5. no forbidden object/intent/clock boundary/scope mutation；
6. Verification Hub bundle `COMPLETE_AND_FRESH`；
7. iEval hard gate PASS 且候选不被 base Pareto dominance（policy 允许的等价 no-op 除外）；
8. Runtime branch head、lease fence、context refs 与验证时一致；
9. evidence pack 可读取、hash 校验通过；
10. selection/approval 权限满足 clock-risk profile。

`target skew met`、`runCTS kFinished`、`save DEF success`、`FastSTA valid`、`iCTS structural PASS` 均不足以单独满足上述门禁。

---

## 10. 失败、partial、unsupported 与 timeout

### 10.1 统一错误码（TARGET）

| Error code | 典型原因 | 可重试性 / disposition |
|---|---|---|
| `INVALID_ARGUMENT` | enum/range/unit/scope 非法 | 修请求；无 mutation |
| `SCHEMA_MISMATCH` | unknown major/semantic field | 升级 adapter；无 mutation |
| `CONTEXT_INCOMPLETE` | intent/scenario/tech/receipt 缺失 | 补 context；无 mutation |
| `CONTEXT_MISMATCH` | 下游消费 refs 不一致 | 重新 materialize；candidate abandon |
| `STALE_SNAPSHOT` / `STALE_OBJECT` | base/head/object generation 变化 | 重新 inspect/propose |
| `STALE_PROPOSAL` / `STALE_CHECKPOINT` | fingerprint/toolchain/schema 漂移 | 不自动 rebase |
| `CONFLICT` / `LEASE_EXPIRED` | iTO/iCTS scope race、fence 过期 | Runtime 重新调度 |
| `CLOCK_NOT_FOUND` / `AMBIGUOUS_CLOCK` | selector 0/多匹配 | 使用 stable ClockId |
| `UNSUPPORTED_CLOCK_SEMANTICS` | mesh/multi-source/未知 gating/generated relation | 不 apply；等待 qualification |
| `UNSUPPORTED_SCENARIO` | required MCMM/PVT/analysis 未覆盖 | 不降级 PASS |
| `EMPTY_REQUIRED_SINK_SET` | intent 声明但无 required sink | context error/no-op 按 policy区分 |
| `MASTER_UNAVAILABLE` | qualified master 集为空/不匹配 | proposal NO_CHANGE 或 UNSUPPORTED |
| `INFEASIBLE_TOPOLOGY` | coverage/fanout/cap/latency constraints 无解 | 返回 witness/frontier |
| `INFEASIBLE_PLACEMENT` | 无合法 cell sites/windows | scope expansion proposal，不自动扩大 |
| `SCOPE_EXPANSION_REQUIRED` | iPL/iRT/RC dirty 超 lease/budget | 新请求/新 proposal |
| `IDB_APPLY_FAILED` | create/connect/master/precondition 失败 | abort/abandon |
| `LEGALIZATION_FAILED` | overlap/site/fence 无解 | reject candidate |
| `PARTIAL_ROUTE` / `PARTIAL_RC` | unrouted net/缺 layer/耦合覆盖 | non-committable |
| `PARTIAL_STA` | scenario/path/CPPR/DRV 覆盖缺失 | non-committable |
| `SETUP_REGRESSION` / `HOLD_REGRESSION` / `DRV_REGRESSION` | hard timing gate 失败 | reject candidate |
| `CERTIFICATE_INCOMPLETE` / `CERTIFICATE_STALE` | claim missing/expired/ref drift | rerun verification |
| `INCOMPARABLE_METRICS` | base/candidate definition/context不同 | 重测，不做伪 delta |
| `TIMEOUT_WITH_INCUMBENT` | budget 到期但有完整 candidate | screening only，需继续升级 |
| `CANCELLED_AT_SAFE_POINT` | Runtime/用户取消 | abandon/checkpoint |
| `WORKER_FAILED` / `RESOURCE_EXHAUSTED` | crash/OOM/disk quota | committed head 不变 |
| `FAILED_ROLLBACK` | base/hash/restore 校验失败 | branch CORRUPTED，人工/平台回收 |
| `INTERNAL_ERROR` | 不变量外异常 | fail closed + minimal evidence |

### 10.2 Partial 纪律

partial result 必须包含：已完成 clock/sink/scenario/object/validator 集、缺失集、最后安全阶段、incumbent 是否完整、candidate 是否发布、base/head hash、可否 resume 和 required next action。以下映射禁止：

```text
no sinks measured       != skew 0
no route artifact       != route clean
skipped hold scenario   != hold pass
unsupported clock gate  != boundary load accepted
FastSTA solver no-op    != target met
restoration attempted   != rollback proved
timeout with candidate  != success
```

### 10.3 NO_CHANGE 分类

`NO_CHANGE` 的 reason 必须来自 enum：`TARGET_ALREADY_MET`、`NO_APPLICABLE_MASTER`、`NO_FEASIBLE_CANDIDATE`、`BUDGET_TOO_SMALL`、`EMPTY_OPTIONAL_SCOPE`、`ALL_CANDIDATES_DOMINATED`。required sink 空、context 缺失、solver failure 和 unsupported semantics 不得降为 NO_CHANGE。

---

## 11. 并发、隔离、安全与治理

### 11.1 Lease 与冲突

read/propose 可共享 immutable snapshot。apply lease 至少覆盖 clock/source/sinks/current tree objects、new-object namespace 和 placement/route halo；同一 clock domain 的 topology write 独占。iTO 对 leased clock cell/net 只能 read/diagnose，若需写则由 Runtime 形成 composite plan 或排队。

两个 proposal 即使 declared scopes 不相交，只要 generated/master relation、shared gating cell、route resource halo 或 timing scenario invalidation 相交，也必须冲突或由 Runtime 建立串行顺序。lease expiry 后 worker 不得 publish；fencing generation 由 iDB catalog 在 publish 时复核。

### 11.2 Legacy worker 隔离

CURRENT `CTSAPI` singleton、`CTSRuntime`、Wrapper、reporter、FastSTA、`dmInst` 和工作目录只能由 `LegacyCTSWorker` 持有。首版采用 process-per-candidate 或已证明 reset 完整的串行 session pool；同进程并发实例在通过 isolation/property/fault tests 前不允许。

worker 输入是 resolved read-only artifacts + fixed adapter config，输出是 candidate checkpoint/actual diff/report artifacts。worker 无 committed-head token、无任意网络、无 caller supplied Tcl/shell/path，写目录限制在 branch staging。

### 11.3 权限等级

| 等级 | 操作 | 最低控制 |
|---|---|---|
| R0 | capability/summary inspect | tenant ACL、redaction、quota |
| R1 | detailed inspect/diagnose/propose/F0-F2 | immutable refs、scope、budget、no write |
| R2 | branch apply/legal/route/F3 verify | fenced lease、isolated worker、validators |
| R3 | selected candidate commit | 仅 Runtime；fresh bundle + CAS + audit |
| R4 | clock intent/exception/uncertainty/period patch | 独立 IntentPatch + clock owner approval |
| R5 | F4 release/signoff | qualified external evidence + release approval |

安全测试必须覆盖 stable ID 伪造、cross-tenant ref/cache、expired lease、arbitrary path/config/Tcl、master name injection、scope escape、artifact symlink/corruption、stale certificate replay 和 worker output spoofing。

---

## 12. LLD、真实源码落点与迁移

### 12.1 TARGET 目录与构建目标

保留 CURRENT kernel 目录和 target，不移动 60k+ 行实现。新增薄 Agent 层：

```text
src/operation/iCTS/
  api/
    CTSAPI.{hh,cc}                         # CURRENT legacy facade，保持兼容
    CTSStatus.hh                           # CURRENT legacy status
  agent/                                   # TARGET
    CMakeLists.txt
    contract/
      ClockTypes.hh
      ClockContext.hh
      ClockIntentView.hh
      ClockObservation.hh
      ClockDiagnosis.hh
      ClockProposal.hh
      ClockDelta.hh
      ClockResult.hh
      ClockSchemaValidator.{hh,cc}
    service/
      ClockAgentService.{hh,cc}
      ClockCapabilityProvider.{hh,cc}
      ClockOperationController.{hh,cc}
    inspect/
      ClockSnapshotReader.{hh,cc}
      ClockTreeInspector.{hh,cc}
      ClockDiagnoser.{hh,cc}
      ClockStableIdAdapter.{hh,cc}
    proposal/
      ClockProposalCanonicalizer.{hh,cc}
      ClockCandidatePortfolio.{hh,cc}
      LegacyHTreeProposalAdapter.{hh,cc}
      TopologyCandidateGenerator.{hh,cc}
      BufferingCandidateGenerator.{hh,cc}
      UsefulSkewPlanner.{hh,cc}
      ClockParetoFrontier.{hh,cc}
    apply/
      ClockDeltaCompiler.{hh,cc}
      ClockDeltaCapture.{hh,cc}
      ClockDirtyMapper.{hh,cc}
      ClockBranchApplier.{hh,cc}
    verify/
      ClockStructuralValidator.{hh,cc}
      ClockFrozenValidator.{hh,cc}
      ClockEvidenceBuilder.{hh,cc}
      ClockVerificationAdapter.{hh,cc}
    worker/
      LegacyCTSWorker.{hh,cc}
      ClockSnapshotMaterializer.{hh,cc}
      ClockProgressAdapter.{hh,cc}
      ClockCheckpointCodec.{hh,cc}
    adapter/
      LegacyCTSAPIAdapter.{hh,cc}
      FastStaMetricAdapter.{hh,cc}
      IdbClockDeltaAdapter.{hh,cc}
      IplClockLegalizeAdapter.{hh,cc}
      IrtClockRouteAdapter.{hh,cc}
      IrcxClockRcAdapter.{hh,cc}
      IstaClockTimingAdapter.{hh,cc}
      ItoCoordinationAdapter.{hh,cc}
      IEvalClockAdapter.{hh,cc}
  test/agent/
    contract/ unit/ property/ integration/ replay/ fault/

benchmarks/qor/cts/                      # TARGET，目录当前不存在
  schemas/ fixtures/ protocols/ manifests/ commercial/ reports/
```

公共 `SnapshotRef/ObjectRef/BranchRef/LeaseRef/Scope/TypedDelta/DirtySet/InvalidationSet/ArtifactRef/Status/CertificateRef` 引用 platform contracts 的唯一实现；iCTS 只定义 clock domain payload，不复制公共 envelope。

建议 CMake target：

```text
icts_agent_contracts          # pure types/schema；不链接 iDB/CTS singleton
icts_agent_readmodel          # immutable DesignView + Intent/Tech views
icts_agent_proposal           # deterministic generators；可链接窄 kernel interface
icts_agent_delta              # compiler/capture/dirty/inverse
icts_agent_validators         # iCTS-owned structural/frozen evidence
icts_agent_worker             # 唯一允许链接 icts_api/icts_source 和 legacy globals
icts_agent_service            # Tool Hub facade；依赖 contracts/public interfaces
icts_agent_contract_tests
icts_agent_integration_tests
```

`icts_agent_contracts` 不得 include `CTSAPI.hh`、`Flow.hh`、`idm.h`、iSTA implementation 或 ToolManager。service 通过接口调 worker/Hub/Runtime；worker 不反向依赖 service。

### 12.2 核心类职责

| 类 | 单一职责 | 禁止职责 |
|---|---|---|
| `ClockAgentService` | version/auth/schema facade 与 operation refs | 持有 mutable CTSRuntime 或 commit |
| `ClockSnapshotReader` | immutable DesignView/Intent/Tech 到 read model | 读取 ambient `dmInst` |
| `ClockTreeInspector` | paged nodes/edges/sinks/coverage/provenance | 修改 tree 或补默认 scenario |
| `ClockDiagnoser` | metric/evidence 到 typed findings | 把相关性写成确定因果 |
| `ClockCandidatePortfolio` | 调度 bounded family、no-op、dedup/Pareto | apply/verify |
| `LegacyHTreeProposalAdapter` | 将 CURRENT H-tree 作为 side-effect-free candidate backend | 直接 writeClock 到 base |
| `BufferingCandidateGenerator` | master/action frontier 与风险 | 将 FastSTA 结果标 common timing |
| `UsefulSkewPlanner` | setup/hold LP、window 和实现需求 | 修改 SDC/intent |
| `ClockDeltaCompiler` | proposal 到 requested typed operations/preconditions | 信任名字/指针身份 |
| `ClockDeltaCapture` | before/after 到 normalized actual/inverse/mapping | 只回显 requested touched |
| `ClockDirtyMapper` | clock-specific dirty seed/invalidation | 缩小其他 owner dirty |
| `ClockStructuralValidator` | DAG/sink/master/delta structural claims | route/legal/timing 自签 |
| `LegacyCTSWorker` | 隔离 CURRENT singleton/kernel/file output | committed-head 权限或跨 tenant pool |
| adapters | context/receipt/status/coverage 转换 | 自动 fallback、吞 partial、解析日志作为唯一状态 |

### 12.3 CURRENT 资产迁移表

| CURRENT 资产 | TARGET 迁移动作 | 收口门禁 |
|---|---|---|
| `CTSAPI::init/runCTS/report` | 固定 config 的 isolated legacy worker，先做 numeric/exit golden | Agent E2E 不再直接调用 singleton |
| `CTSStatus/FlowRunStatus` | adapter 映射到公共 terminal/error；保留 legacy ABI | no-op/failure/partial conformance |
| `SdcClockReader/clock_trace` | 改消费 Intent view/DesignView；与 CURRENT trace differential | generated/mux/case coverage receipt |
| `Clock/ClockNetwork/ClockDAG/Layout` | 构建 immutable observation；pointer/name 映射 ObjectRef | stable/reload/rename/order property tests |
| `TopologyGen/Synthesis/HTree` | 拆 candidate-only backend，diff capture 检查零写入 | proposal 前后 state digest 相同 |
| analytical H-tree/HiGHS | 独立 qualified family，不改变默认 | timeout/determinism/QoR benchmark |
| FastSTA | namespace 为 F1 estimator，保留 incremental sizing | common iSTA differential + OOD policy |
| `Optimization` accepted edits | 先输出 resize proposals，再由 common delta apply | direct edit path 不用于 Agent commit |
| `WrapperClockWriter` restore | candidate worker legacy fallback + actual diff | fault matrix/base hash/branch discard |
| `Evaluation/Qor` | legacy E0 metric adapter，补 context/unit/coverage | iEval common metric 对账 |
| Router/local legalization | F0 route/terminal primitive | 不再表述为 cell legal/detailed route |

### 12.4 分阶段 PR 计划

1. `CTS-PR00 CURRENT manifest`：冻结 legacy API/status/CMake/test/metric golden，增加 capability inventory，不改行为。
2. `CTS-PR01 contracts`：ClockContext/IntentView/Observation/Diagnosis/Proposal/Delta/Result schema、canonical codec 和错误码测试。
3. `CTS-PR02 inspect`：SnapshotReader、stable ID adapter、ClockDAG/Layout observation、paging/coverage；legacy differential。
4. `CTS-PR03 propose`：no-op + legacy discrete H-tree + buffer resize candidate-only adapter；证明零写入、确定性、Pareto。
5. `CTS-PR04 delta`：ClockDelta compiler/capture、provisional ID、actual touched、dirty/invalidation、inverse/property tests。
6. `CTS-PR05 branch worker`：isolated materialization、legacy writer fallback、lease/idempotency、crash/rollback/replay。
7. `CTS-PR06 physical chain`：iPL legalize -> iRT route -> iRCX -> common iSTA adapters 和 Hub claim registration。
8. `CTS-PR07 evaluation`：F0-F3 router、FastSTA/common differential、iEval gate、first E2E workflow。
9. `CTS-PR08 useful skew`：setup/hold LP、window-to-physical portfolio、MCMM/CPPR adversarial tests，默认 off。
10. `CTS-PR09 anytime`：progress/cancel/checkpoint/resume、deterministic parallel policy、resource limits。
11. `CTS-PR10 qualification`：held-out/performance/commercial harness、安全/故障 suite、legacy migration/deprecation gate。

每个 PR 同时包含 contract、positive/negative/fault tests、evidence artifact 和 rollback/deprecation plan。按仓库规则，该 Agent contract/adapter 工作进入 `integration/agent-native` 或 `*/agent-*`；若需修改共享 deterministic kernel，应在 parity/compat lane 单独提交，禁止混入大规模目录重构。

---

## 13. 测试、回放、性能与商业对拍

### 13.1 测试分层

| 层 | 内容 | 必须断言 |
|---|---|---|
| schema/contract | version、required/unknown field、enum、unit、ref、status mapping | semantic 字段不被宽松吞掉；partial 不变 success |
| unit | stable ID、selector、DAG、partition、frontier、LP、delta compile、dirty | 边界、UNKNOWN、canonical order、单位 |
| property | 随机 legal tree/action/apply/inverse/scope | source reachability、sink uniqueness、base hash 恢复、越域=0 |
| golden | 手算 clock micro-design、SDC/generated/gating、legacy H-tree/FastSTA | observation/proposal/delta/evidence 稳定 |
| metamorphic | rename、input permutation、平移/镜像、unit conversion、thread/seed | 语义等价输出不变或差异有明确原因 |
| differential | CURRENT vs adapter、FastSTA vs common iSTA、incremental vs full、local vs full | 分桶误差/coverage；禁止以 majority 代 oracle |
| integration | iDB -> iPL -> iRT/iRCX -> iSTA -> Hub -> iEval -> Runtime | refs 一致、缺一步不 commit、other domain hash 不变 |
| replay | clean worker 重建 inspect/proposal/candidate/decision | result/state/evidence digest 与 tolerance receipt |
| fault injection | 每 op/阶段/CAS/artifact/cancel/OOM/kill/lease race | committed head 不变、branch disposition 明确 |
| security | tenant/path/Tcl/master/ID/lease/certificate 攻击 | fail closed、无存在性泄露、audit 完整 |
| performance | runtime/RSS/cache/scope amplification/F3 saving | 固定协议、多次重复、失败进入分母 |
| commercial | ccopt/clock_opt 同冻结输入与外生 measurement | 可比性、三指标独立、license/unsupported 诚实 |

### 13.2 Golden fixtures

| Fixture | 重点 |
|---|---|
| `clock_zero_sink` | required/optional sink 区分，禁止 skew=0 假成功 |
| `clock_single_sink` | direct/no-op、zero skew definition、buffer path depth |
| `clock_balanced_four` | 手算 H-tree、canonical partition、permutation invariance |
| `clock_unbalanced_cluster` | depth/cluster/latency trade-off、placement windows |
| `primary_generated_pair` | master/generated ownership、divide/multiply/invert、mode |
| `clock_gate_mux_case` | gating/mux/case analysis boundary 与 unsupported |
| `multi_clock_shared_logic` | ambiguity、lease conflict、domain isolation |
| `macro_regular_mixed` | sink domain partition、source-to-root + downstream |
| `missing_master` | tech qualification、NO_CHANGE vs UNSUPPORTED |
| `no_legal_site` | iPL infeasible、scope expansion、zero base pollution |
| `partial_clock_route` | unrouted/RC partial 不可 commit |
| `setup_hold_cross` | useful-skew setup 改善/hold 退化反例 |
| `dirty_one_branch` | other branch/domain hash、incremental/full STA |
| `writeback_fault_k` | create/place/connect 第 k 点失败和 restore/discard |
| `legacy_numeric_lock` | CURRENT Tcl/API/status/QoR/HTree/FastSTA 基线 |

golden manifest 固定 input/source hashes、PDK/lib/RC、intent/scenarios、binary/config/schema、seed/thread、expected coverage 和 per-field tolerance。日志全文、绝对路径、wall time、unordered traversal 不进 golden。

### 13.3 Property、metamorphic 与 differential

- 对随机树执行任一合法 delta + inverse，100% 恢复 topology/connectivity/placement semantic hash；
- required sink 集合置换、display rename 不改变 ClockId/SinkGroupId/proposal semantic hash；
- 坐标与 core/constraints 同步平移，topology connectivity、相对长度/latency 结论保持；
- 正确镜像且同步变换 orientation/routing assumptions 后，structural claims 等价；
- 增大 budget 不能丢失此前已完成的 deterministic non-dominated proposal，除非 schema/policy 明确 frontier cap；
- 缩小 writable scope 不能产生更多 authorized actual touched；需要扩大时返回 proposal；
- FastSTA incremental master change 与 full FastSTA 已有 CURRENT test 继续保留，并新增 common iSTA 分桶；
- iSTA incremental 与 full 对 affected endpoints/scenarios 对拍；超 qualification tolerance 时撤销 incremental profile；
- CURRENT `runCTS` 和 legacy worker 在相同输入/config 上的退出状态、clock connectivity 和 E0 QoR 受 golden 保护。

### 13.4 故障注入与回放矩阵

必须在下列边界逐一注入 fail/cancel/timeout：context resolve、snapshot materialize、proposal serialization、每类 iDB action 前后、before-image capture、actual diff、candidate artifact write/hash/publish、iPL legalize、iRT round、iRCX extraction、iSTA scenario update、Hub certificate issue、iEval gate、Runtime CAS 前后。

每个 case 断言：committed head ref/hash、base snapshot、lease/fence、candidate disposition、visible CAS artifacts、terminal event、error code、rollback proof。最低要求是所有已实现 mutation boundary 全覆盖，而不是随机挑几个。worker SIGKILL/OOM/disk-full/corrupt checkpoint/cross-tenant cache/stale resume 进入 CI 或 nightly fault profile。

Replay 分三档：

1. contract replay：request/result canonical bytes 和 digest 完全相等；
2. state replay：candidate semantic hash、actual delta、dirty/invalidation 完全相等；
3. numeric replay：metric 在预注册 tolerance 内，非 deterministic backend 同时满足重复分布协议。

### 13.5 Performance protocol

按 sink count、clock count、tree depth、buffer count、physical span、scenario count、PDK、route stage、dirty ratio 分桶。固定 CPU/NUMA、compiler/build、线程、cold/warm cache、预算和重复次数；报告 median/MAD/p95、peak RSS、CAS bytes、candidate count、prune rate、F0/F1 Top-K recall/regret、F3 calls saved、requested/actual scope amplification、incremental/full speedup和失败/timeout/OOM 率。

基线至少包括：CURRENT batch `runCTS`、no-op、legacy discrete H-tree、analytical H-tree（可用时）、resize-only CURRENT equivalent、full re-run、incremental dirty branch。性能结论不以训练/调参设计作为 held-out；任何失败都进入分母。

### 13.6 Commercial correlation

当 commercial license/bridge 可用时，在完全冻结且合法可比的输入上运行：同 DEF/netlist/SDC、同 libraries/PVT/RC、同 propagated/ideal policy、同 route stage、同 units/clock groups/uncertainty。commercial 产物通过 External Tool Bridge 导入，不能解析自由文本猜 scenario。

独立报告而非总分：

- insertion latency per clock/sink group/scenario；
- local/global skew 与 endpoint pair；
- setup WNS/TNS、hold WNS/TNS、DRV counts；
- clock buffer count/area/power；
- clock route length/vias/congestion；
- wall time/RSS/license wait 分离；
- topology/edit distance 和失败分类。

对拍分三类：measurement correlation（同一 tree 两工具测量）、optimization correlation（各自优化后 QoR）、decision correlation（F0/F1 是否保留 F3/F4 优候选）。F4 不可用必须输出 `UNSUPPORTED_EXTERNAL_ORACLE`，不能从测试分母中静默删除；本地 correctness 仍由 F3 自身门禁负责。

### 13.7 可杀假说

| ID | 假说 | 否证条件 | 否证后的动作 |
|---|---|---|---|
| H-CTS-A01 | CURRENT discrete H-tree 经 proposal/branch/common verification 后仍是有竞争力 baseline | held-out 中被简单 clustered/balanced family 系统性支配 | 降为 compatibility baseline，不默认 |
| H-CTS-A02 | FastSTA F1 能安全筛掉明显差 sizing/topology 候选 | Top-K recall/regret 或 false-prune 未过冻结门槛 | 扩 F2/F3、缩 pruning、撤 qualification |
| H-CTS-A03 | branch-level incremental update 比 full CTS 更适合 post-CTS ECO | dirty scope 经常扩到全域或成本不低 | 仅保留小范围 profile，其他 full rerun |
| H-CTS-A04 | useful-skew LP + physical realization 在 hard hold guard 下改善 setup | 多数 case 物理不可实现或 hold/setup 净收益不优于 no-op | 默认关闭，限制适用桶或移除 |
| H-CTS-A05 | legacy writer 可由 isolated worker + diff 安全封装 | 故障后出现 base/head 污染、actual diff 漏字段 | 禁止 Agent apply，先改 common state adapter |
| H-CTS-A06 | local iPL/iRT/RC/STA chain 能保持严格 frozen scope | scope amplification/增量-full disagreement 频繁超门槛 | 扩验证或仅允许 full profile |
| H-CTS-A07 | analytical H-tree 在合格桶提供 QoR/成本 Pareto 增益 | paired held-out 无增益或 timeout 显著 | 保持实验 profile，不进入默认 |

门槛在 benchmark baseline PR 中预注册，看到 held-out 结果后不得反向调整。

---

## 14. 里程碑与依赖

### 14.1 依赖顺序

| 里程碑 | 周期估算 | 交付 | 退出门禁 |
|---|---:|---|---|
| CTS-M0 事实基线 | 1-2 周 | CURRENT manifest、legacy golden、benchmark protocol | CURRENT/TARGET 无混写，CTest 真执行 |
| CTS-M1 Contracts | 2 周 | context/ID/observation/proposal/delta/result/error schema | schema/canonical/status conformance |
| CTS-M2 Read/Diagnose | 3 周 | immutable inspector、stable IDs、diagnosis | rename/reload/order/coverage tests |
| CTS-M3 Propose | 4 周 | no-op + discrete H-tree + resize portfolio | proposal 零写入、determinism、Top-K evidence |
| CTS-M4 Branch Apply | 4 周 | delta compile/capture/inverse/dirty + worker | 1000 round trips、fault/base pollution=0 |
| CTS-M5 Physical Verify | 5 周 | iPL/iRT/iRCX/iSTA/Hub adapters | complete/partial/frozen/incremental-full gates |
| CTS-M6 Evaluation E2E | 3 周 | F0-F3 escalation、iEval、Runtime selection | 首个 workflow clean-process replay |
| CTS-M7 Useful Skew | 4 周 | LP/window/physical realization，默认 off | MCMM setup+hold adversarial/held-out qualification |
| CTS-M8 Anytime/Scale | 3 周 | progress/cancel/checkpoint/resume/perf | crash/replay/thread/seed/resource gates |
| CTS-M9 Commercial | 持续 | F4 bridge/correlation dashboards | protocol comparable，unsupported 诚实 |

周期是规划值；M4 依赖 10 的 branch/TypedDelta，M5 依赖 22/26/27/49 的公共 contracts，M6 依赖 12/43。依赖未就绪时 capability 保持 `SHADOW/UNSUPPORTED`，禁止在 iCTS 私有实现 snapshot、common STA 或 commit 绕过。

### 14.2 首个端到端用例

```text
1. Runtime freezes post-place SnapshotRef + ClockIntent + ScenarioSet + TechContext.
2. clock.inspect returns primary/generated tree, sinks, topology and coverage.
3. clock.diagnose identifies skew/DRV/physical risks with evidence.
4. propose returns no-op, legacy discrete H-tree parameter variant and resize candidate.
5. iEval F0/F1 retains Top-K; Runtime creates independent branches/leases.
6. Each branch applies ClockDelta through iDB and captures actual touched/inverse/dirty.
7. iPL legalizes; iRT routes; iRCX extracts; iSTA checks all setup/hold/DRV scenarios.
8. Verification Hub issues complete or incomplete bundles; iEval compares/gates.
9. Runtime commits one fresh candidate by CAS or rejects all; candidates are abandoned.
10. A clean worker replays selected and one rejected candidate from evidence refs.
```

成功标准包括“诚实拒绝所有候选”。为了产生 commit 而放宽 hold/route/coverage gate 是协议失败。

---

## 15. 可量化完成定义（DoD）

ai1.1 controlled R3 profile 只有同时满足以下条件才完成：

1. `clock.capabilities/inspect/diagnose/propose/apply/verify` 均有 versioned schema、manifest、positive/negative/unknown-field tests；
2. inspect/propose 对 100% 测试请求保持 base canonical hash 不变，API payload 中无 raw pointer、ambient path 或 current-design selector；
3. stable ID 在同一 lineage 的 reload、rename、input permutation 各 100 次运行中保持；delete/recreate 旧 ref 100% 返回 stale；
4. 所有成功 topology 的 required sink source reachability 和 uniqueness 都为 100%，cycle/dangling/ambiguous case 0 次假 PASS；
5. deterministic profile 在 20 次重复及 thread policy `1/2/4` 的已资格化组合上 result digest 一致；不支持跨 thread deterministic 的 profile 必须显式分开注册；
6. 至少 no-op、legacy discrete H-tree、buffer resize 三类 proposal 可执行；每个非 no-op 有 preconditions、actual diff、inverse、dirty/invalidation 和 validators；
7. 至少 1000 个 generated legal ClockDelta 完成 apply/inverse 或 candidate discard，base/head semantic hash 恢复率 100%，committed-base 污染 0；
8. 每一个已实现 mutation/publish boundary 都有故障注入，worker kill/OOM/cancel/lease conflict 后 committed head 改变次数为 0；rollback mismatch 100% 标 `FAILED_ROLLBACK/CORRUPTED`；
9. iPL 返回的 actual moved、iRT actual nets、iRCX coupling neighbors、iSTA affected scenarios 全部进入 dirty/receipt；授权 scope 外未解释修改为 0；
10. accepted candidate 的 required scenarios setup/hold/DRV result coverage=100%，placement/route/RC/clock claims coverage=100%，Hub bundle fresh/complete=100%；
11. FastSTA 与 common iSTA、incremental 与 full 的 qualification 按设计/PDK/stage 分桶；初始 timing gate采用 `|WNS_delta| <= max(1 ps, 0.1% period)` 且 affected endpoint slack p95 `<= max(2 ps, 0.2% period)`，超出即撤销该桶资格而非放宽记录；
12. route connectivity/unrouted count、DRC violation count和sink coverage的 incremental/full 离散结果要求完全一致；不一致候选不得 commit；
13. F0/F1 screening 在 held-out protocol 上达到预注册的 Top-K recall/regret 门槛并报告 bootstrap CI；未达到时仍可运行但不得作为 false-prune gate；
14. scope `<=1%` design objects 的 qualified incremental profile，目标 p95 wall time `<=25%` 对应 full chain，且 peak RSS 不高于 full；未达标只否证性能资格，不得牺牲 correctness；
15. selected candidates、所有 failure types 和至少 10% rejected candidates可在 clean worker replay；state/contract digest 100% 一致，numeric 结果在 qualification tolerance 内；
16. commercial oracle 可用时至少覆盖 3 个设计族、2 个 PDK/stage bucket、每桶 5 次 paired runs；skew/latency/power/setup/hold/DRV 独立报告。oracle 不可用 case 100% 显式记 `UNSUPPORTED`；
17. CURRENT `icts_test_*` 默认测试和新增 Agent contract/integration tests 全绿；opt-in real-tech/slow/commercial profile 的执行状态和缺失原因可见；
18. evidence pack 对 100% Runtime selection 可解析到 request/context/proposal/delta/metrics/certificates/decision/toolchain/artifact hashes，缺任一关键 ref 不允许 R3；
19. useful skew profile 默认 off，只有 setup+hold LP、物理实现、F3 MCMM、故障与 held-out 门禁全部通过后按设计/PDK/scenario bucket 开启；
20. legacy Tcl/API/status/QoR golden 无未批准语义回归，新 Agent service 不依赖普通日志判断 success。

第 11/14 项是 ai1.1 初始 qualification target，需要在 baseline PR 冻结机器、设计桶与测量方法；它们不是对 CURRENT 实现的虚构承诺。任何 target 未达成应保持 capability 降级/关闭，而不是把 CURRENT 标为已实现。

---

## 16. 开放问题、ADR 与主要风险

| ADR | 需决定的问题 | 默认保守选择 | 所需证据 |
|---|---|---|---|
| CTS-ADR-01 | stable ClockId 与 48 Intent node 的跨 schema 生命周期 | source ObjectRef + intent node + mode；name 非身份 | import/reload/intent migration tests |
| CTS-ADR-02 | generated/gating/mux 支持边界 | inspect 可 partial，write 默认 unsupported | parser/consumer/iSTA differential |
| CTS-ADR-03 | legacy H-tree candidate-only 最小改造 | isolated worker before/after capture | proposal zero-write/perf/maintenance |
| CTS-ADR-04 | FastSTA F1 qualification bucket | 默认只 sizing screening | held-out rank/error/OOD |
| CTS-ADR-05 | iPL clock legalize 的最小 halo | 无证明则扩大并重新授权 | overlap/fence/scope property tests |
| CTS-ADR-06 | clock NDR/shield 的 owner 和 codec | Intent/Tech 给 policy，iRT materialize | route/DRC/RC replay |
| CTS-ADR-07 | iCTS/iTO composite repair 编排 | Runtime 串行新 candidate | lease race/setup-hold E2E |
| CTS-ADR-08 | useful skew LP path reduction | 默认保留 violation + near-critical guard set | full-path adversarial/held-out regret |
| CTS-ADR-09 | checkpoint 是否跨 binary/compiler 恢复 | 默认同 toolchain only | migration/equivalence report |
| CTS-ADR-10 | commercial metric canonicalization | 外生 adapter、每项独立，不做总分 | units/scenario/CPPR/route-stage 对账 |

主要风险：

- 把 CURRENT 进程内 ClockDAG/名字误当 stable snapshot identity；
- 把 Wrapper 写回恢复误当跨 iDB/iPL/iRT/iSTA 的原子 rollback；
- 把 terminal-coordinate legalization误当标准单元 placement legal；
- 把 FastSTA 或 final wirelength report误当 common MCMM timing/certificate；
- topology proposal 内部继续隐式写 global design，使多个 candidate 污染；
- useful skew 只看 setup，或通过修改 SDC 而非物理实现获得“改善”；
- actual scope 扩散后仍使用旧 lease、frozen proof 和风险预测；
- F4 不可用时从对拍分母删除失败，造成虚假商业相关性。

这些风险的处理顺序固定为：先 contracts/stable state/branch isolation，再物理验证链，再扩候选算法。没有 M4/M5 证据前不应优先开发 learned ranker 或自动 useful skew。

---

## 17. 版本历史

- **ai1.1（2026-07-24）**：基于当前 `src/operation/iCTS` API、Flow、SDC trace、Clock/ClockNetwork/ClockDAG/Layout、H-tree/analytical、FastSTA、optimization、Wrapper writeback、Evaluation、CMake 与测试的源码审计，严格区分 CURRENT/TARGET；补齐 owner、FR/NFR/不变量、inspect/diagnose/propose/apply/verify 生命周期、ClockContext/ClockIntent/Observation/Diagnosis/Proposal/ClockDelta/Result/evidence schema、stable ID、topology/buffering/useful-skew、dirty、F0-F4/anytime/determinism、跨 iDB/iPL/iRT/iRCX/iSTA/iTO/iEval/Hub/Runtime 事务、错误/partial/timeout、安全、真实 LLD/PR、全层测试、commercial 对拍、量化 DoD 与 ADR。
- **ai1.0（2026-07-23）**：定义基础 clock inspect/propose/apply/validate、ClockDelta、useful-skew 方向、验证 DAG 和初步 PR/测试列表。
