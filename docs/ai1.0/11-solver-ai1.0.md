<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 11 · Solver Agent 可组合求解服务实施方案 · ai1.1

> 基线：`docs/ai/11-solver.md`、本文 ai1.0 和 `12-evaluation-ai1.0.md`。本版以可直接开发为目标，明确区分仓库事实（CURRENT）与规划能力（TARGET）。
>
> 当前成熟度：`D0/D1 混合`。当前公共 `src/solver` 有可运行的 legalization/geometry 代码；HiGHS MILP、METIS/hMETIS、SA/Nesterov 等求解资产仍位于领域工具内部。统一 `ProblemSpec/Candidate/Proof`、Capability API、预算/cancel/resume、独立可行性检查和 Solver Registry 均尚未实现。
>
> 首个垂直闭环：post-place Timing ECO 的局部合法化候选。Solver 读取 immutable snapshot 派生的问题，输出 proposal-only 候选；Runtime 在隔离 branch apply，Verification Hub 验证 legality/timing/frozen scope，iEval 比较 QoR，只有 Runtime 可以 commit。

---

## 0. 产品目标、边界与原则

### 0.1 产品目标

Solver 不是“把算法目录包一层 RPC”，而是 Agent 可发现、可预算、可中断、可复核的求解平面：

```text
Planner declares goal/problem family
  -> Runtime fixes snapshot/context/scope/budget
  -> Solver validates typed ProblemSpec and selects qualified backend
  -> backend streams candidate assignments/proposals and bounds
  -> independent checker rejects invalid incumbents
  -> Solver returns CandidateSet + ProofBundle + exact termination
  -> Runtime may apply one proposal on a branch
  -> Evaluation/Verification judge the resulting design state
  -> Runtime selects or commits; Solver never writes the main snapshot
```

首版必须做到：

- 一个问题、候选和证明均有稳定 schema、单位、context 与内容 hash；
- 能区分“已证明不可行”“预算内没找到解”“有可行 incumbent 但未证明最优”；
- wall/CPU/RSS/迭代/候选/license 等预算由 Runtime 权威账本约束；
- timeout/cancel 不丢最后一个已独立复核的 incumbent；
- 算法、seed、线程数、容差、二进制和依赖版本进入 run identity；
- CP-SAT、MIP、启发式和学习 ranker 按适用域路由，而不是按算法名字宣称精度；
- 所有设计修改保持 proposal/apply 分离，并能进入 12/43/49 的 gate/commit 链；
- Honey 生成的局部 solver 与手工 solver 使用相同 checker、测试和晋级协议。

### 0.2 非目标

- 不把 `src/solver` 建成新的 iPL/iCTS/iRT，不复制领域模型、数据库和 signoff 算法；
- 不承诺通用数学建模语言，不接受 Agent 提供任意代码、callback、shell 或动态库；
- 不把 heuristic 的“未找到冲突”称为 `INFEASIBLE`，不把低 gap 自动称为物理正确；
- 不让 Solver 直接 apply `TypedDelta`、持有 branch、签发设计级 certificate 或 commit；
- 不在首版统一搬迁所有工具私有 solver；只有真实 consumer 和独立 checker 的 adapter 进入 Registry；
- 不将 CP-SAT/MIP 自动视为 F3，也不将 learned ranker 的分数视为 bound/proof；
- 不宣称替代商业 optimizer、foundry signoff 或人工批准。

### 0.3 唯一责任

| 模块 | 负责 | 不负责 |
|---|---|---|
| Solver（本文） | 问题规范、backend qualification、搜索、candidate/bound/proof、预算安全点 | 设计 branch、apply、QoR gate、设计级正确性 |
| 领域工具 | 从 snapshot 构造领域问题、把 assignment 编译为 proposal、领域语义 | 伪造 solver proof、绕过公共状态语义 |
| Planner（54） | 选择 problem/capability、建议预算/恢复/停止 | 直接调用内部类、改硬约束、声明最优/可行 |
| Runtime（43） | branch、权威预算、worker、cancel、apply、select、commit | 解释数学约束或相信未经 checker 的 incumbent |
| iEval（12） | metric、F0-F4 比较、Pareto、QoR gate | 数学可行性证明、apply 或 commit |
| Verification Hub（49） | 设计级 claim、coverage、失效和 bundle | 优化目标排序、求解器内部 bound |
| TechContext（55） | PDK canonical ID、单位、映射、qualification | 为 solver 猜缺失工艺默认值 |
| Data/Oracle（47） | frozen corpus、oracle protocol、数据切分和 lineage | 在线选择或把单一工具当无条件真值 |

核心分界是：**ProblemSpec 内数学可行，不等于 apply 后的设计可提交；Solver proof 不能替代 ValidationCertificate。**

---

## 1. CURRENT 事实审计与 TARGET 差距

### 1.1 公共 `src/solver` 的真实状态

| 路径/资产 | CURRENT 事实 | 可复用点 | 不能据此宣称 |
|---|---|---|---|
| `src/solver/CMakeLists.txt` | 只 `add_subdirectory(legalization)` 和 `geometry` | 公共库接入起点 | 已有统一 runtime/registry |
| `legalization/LGMethodInterface.hh` | 接受 iPL 指针，返回 `bool`；支持 incremental/rollback 方法 | Abacus adapter 和回滚对拍 | immutable input、结构化失败、proof |
| `legalization/method/abacus` | 真实全量/增量合法化与内部 rollback stack | 首个 heuristic backend | 多高单元、并发、cancel/resume 已 qualified |
| `geometry/geometry_boost` | 维护可变 polygon set，提供 intersect/overlap/rect/area | checker 的确定性几何原语 | 完整 Solver capability 或线程安全 |
| `partition/TBD` 等五个目录 | 文件为 0 字节占位 | 未来目录名参考 | partition/QP/Steiner/two-pin 已实现 |

因此旧版“首批 kernel 注册”必须校正：公共目录中当前只有 Abacus 和 Geometry 可作为迁移起点；Geometry 更适合作为 checker/operator 依赖，不应为凑数量冒充优化 solver。

### 1.2 工具私有求解资产

| 资产 | CURRENT 可见能力 | 首次接入建议 | 主要缺口 |
|---|---|---|---|
| iCTS `HighsMathHtreeSolver` | in-process HiGHS MILP；已有 status、incumbent、primal/dual bound、gap、time limit | 第二个真实 adapter，保留原模型与测试 | 公共 context/proof/checkpoint/cancel、独立通用 checker |
| iCTS `AnalyticalValidation` | 对离散 H-tree candidate 做领域 legality 检查 | 作为领域 post-check，不塞进通用 solver core | 不是所有 Solver constraint 的 proof |
| iPL `Metis` | 固定 seed option 的图分区调用，返回 partition vector | 隔离 adapter + balance/cut 重算 | 输入/错误/资源语义薄；对象持有裸指针 |
| iPL `Hmetis` | 写固定目录、拼 command 并 `system()`，再读结果文件 | 只能经 External Tool Bridge 重写后 shadow | command/path 注入、并发污染、陈旧产物假成功 |
| iPL `SimulateAnneal` | `rand()`、固定循环、单一 solution update/rollback | 先重构 RNG/event/checker 后再接 | 无显式 seed、best incumbent、cancel/checkpoint |
| iPL `Nesterov` | 迭代和 OpenMP thread 参数 | 领域内部优化原语 | 不是独立 ProblemSpec capability |
| `src/third_party/highs` | vendored HiGHS | MIP backend 与 differential oracle | 第三方存在不等于资格完成 |
| CP-SAT backend | 仓库审计未见公共实现/依赖 | TARGET；依赖评审后引入或外接 | 当前不能发布 capability |
| learned ranker | 仓库有 ONNX runtime 等模型资产但无公共 Solver ranker | TARGET；先 shadow | 当前不能宣称能选 solver/候选 |

### 1.3 CURRENT/TARGET 对照

| 能力面 | CURRENT | TARGET ai1.1 | 首个证据 |
|---|---|---|---|
| 输入 | 工具私有对象、裸指针/文件 | immutable refs + typed `ProblemSpec` | schema/golden fixtures |
| 输出 | bool、vector、工具私有 solution/log | `CandidateSet + ProofBundle + Termination` | contract tests |
| 可行性 | 多由 kernel 自报或领域后验 | 独立 checker 按 constraint ID/coverage 复核 | exhaustive/fuzz |
| anytime | 少量 time/iteration 参数 | monotonic verified incumbents + progress stream | timeout/cancel tests |
| resume | Abacus 有内部 rollback，非通用 resume | 绑定 run identity 的版本化 checkpoint | continuous/resume differential |
| 确定性 | seed/thread/global state 不统一 | deterministic profile + process isolation | replay hashes |
| portfolio | 无公共 runner | 共用预算、异构 family、Pareto/lexicographic | held-out regret |
| 修改 | 私有 kernel 可能直接改内部 DB | proposal-only；Runtime branch apply | main snapshot zero-write |
| 资格 | 能编译/能运行 | domain/fidelity/checker/tests/security/consumer 全闭合 | Readiness Ledger |

### 1.4 首版问题范围

| ProblemKind | 首版 consumer | 首版 backend | 明确边界 |
|---|---|---|---|
| `placement.local_legalization@1` | iPL/iTO Timing ECO | Abacus heuristic adapter | 标准单元、单 height/region；具体 domain 由 qualification 冻结 |
| `clock.htree_slot_choice@1` | iCTS analytical H-tree | 当前 HiGHS MIP adapter | 只接现有 affine/discrete model，不泛化为 CTS signoff |
| `partition.graph@1` | iPL exploratory partition | METIS isolated/in-process adapter | 先 graph，不谎称 hypergraph；balance/cut 独立重算 |
| `local.discrete_assignment@1` | Honey T2 local solver | TARGET CP-SAT template | 仅有限离散域；未引入依赖前保持 `NOT_STARTED` |

`geometry.query` 作为 `SolverSupportCapability` 服务独立 checker 和领域 adapter；它没有 objective/candidate/proof，不纳入优化结果统计。

---

## 2. 面向 Agent 的需求与架构不变量

### 2.1 功能需求

| ID | 需求 | 优先级 | 验收要点 |
|---|---|---:|---|
| FR-SOL-01 | capability discovery 返回 domain、证据、成本、cancel/resume 条件 | P0 | 域外请求在运行前 `UNSUPPORTED` |
| FR-SOL-02 | `ProblemSpec` 表达 typed variable/constraint/objective/context | P0 | 禁止任意 executable expression |
| FR-SOL-03 | candidate 保留 assignment/proposal、lineage、可行性结果 | P0 | 无 checker PASS 不发布为 feasible |
| FR-SOL-04 | bounds/gap/certificate 明确语义与来源 | P0 | heuristic unknown bound 为 null，不填 0 |
| FR-SOL-05 | F0-F4 自动路由和显式降档/升级 | P0 | 算法名不决定 fidelity |
| FR-SOL-06 | anytime progress、cancel、partial、selected resume | P0 | timeout 不丢 verified incumbent |
| FR-SOL-07 | 总预算及 child run 原子 reservation | P0 | portfolio 不超 global/runtime ledger |
| FR-SOL-08 | deterministic profile 与并发隔离 | P0 | 固定 identity 可重放，例外可量化 |
| FR-SOL-09 | proposal 与 apply/verify/commit 分离 | 红线 | Solver 对主 snapshot 零写入 |
| FR-SOL-10 | backend/adapter/checker 独立 qualification | P0 | build pass 不能进入 ACTIVE |
| FR-SOL-11 | Honey T2 solver 复用同一合同与门禁 | P1 | 生成代码不能替换固定 checker/runtime glue |
| FR-SOL-12 | decision sample 保存成功和所有失败 | P1 | timeout/unsupported/infeasible 不丢失 |

### 2.2 非功能要求

| ID | 要求 |
|---|---|
| NFR-SOL-01 | 所有请求绑定 `SnapshotRef/IntentRef/ScenarioSetRef/TechContextRef/PolicyRef`；不读 ambient current design |
| NFR-SOL-02 | 长度/时间/功耗/容量使用 canonical unit；保留 exact source scale，禁止猜单位 |
| NFR-SOL-03 | progress queue 有界；慢 consumer 不能阻塞 kernel，丢事件要有计数且不丢 terminal/incumbent |
| NFR-SOL-04 | cancel p95 目标由 capability qualification 声明；不能合作取消的 legacy backend 用独立 worker kill |
| NFR-SOL-05 | serialized checkpoint、model、插件、外部结果均视为不可信输入，验证 hash/schema/size 后再读取 |
| NFR-SOL-06 | cache 和 resume 不跨 tenant、tech、intent、solver build、thread profile 或 tolerance 复用 |
| NFR-SOL-07 | 10 ms 以上任务 adapter overhead 目标不超过 2%；未达标先优化 view/event，不绕过 contract |
| NFR-SOL-08 | API/schema 向后兼容；constraint/objective 语义变化必须升 major version 并重新 qualification |

### 2.3 不可绕过的不变量

1. hard constraint 永远不能被 penalty、ranker score 或 objective 改写为 soft；
2. `INFEASIBLE` 只来自 qualified proof path，搜索耗尽但无 proof 是 `UNKNOWN/NO_FEASIBLE_FOUND`；
3. 发布的 feasible candidate 必须通过与 producer 分离的 checker；
4. candidate 的数学 feasibility 仅覆盖 `ProblemSpec`，不能扩大成 design-level legality/timing/DRC claim；
5. 任一 bound 都绑定 objective、sense、relaxation、tolerance 和 backend；不可跨不同目标比较 gap；
6. resume token 只能恢复同一 problem/run identity；不兼容必须响亮失败；
7. Solver 不拥有 branch，不返回 `new_snapshot_id`，不调用 commit；
8. ranker 可以改变搜索顺序，不能删除 hard constraint、伪造 candidate 或改变最终 checker；
9. portfolio child 共用总预算，取消父 run 必须终止或隔离全部 child；
10. required context、coverage、artifact 或 qualification 缺失时不能降级成成功。

---

## 3. 总体架构与控制流

### 3.1 组件图

```text
Planner / domain tool
        |
        v
SolverService API -------- CapabilityRegistry / QualificationStore
        |
        +--> RequestValidator --> ProblemCanonicalizer --> DomainRouter
        |                                                |
        |                            +-------------------+-------------------+
        |                            |                   |                   |
        |                       CP-SAT adapter       MIP adapter      Heuristic adapter
        |                            |                   |                   |
        |                            +---------- PortfolioRunner ------------+
        |                                                |
        +--> BudgetController / Cancellation / WorkerPool / CheckpointStore
                                                         |
                                IndependentFeasibilityChecker
                                                         |
                         ResultNormalizer / ProofBuilder / EvidenceWriter
                                                         |
                 CandidateSet + ProofBundle + Progress/Termination
```

学习 ranker 位于 `DomainRouter/PortfolioRunner` 的建议侧，输入只允许 approved features/domain signature，输出 backend/candidate ordering 和 uncertainty；确定性 router 在模型 unavailable/OOD 时完整接管。

### 3.2 单次求解数据流

```text
1. resolve exact capability version and qualification
2. validate refs, unit system, scope, schema and unsupported predicates
3. canonicalize stable IDs/order; compute problem_id
4. Runtime reserves parent budget; Solver allocates bounded child slices
5. start qualified worker and emit RUN_STARTED
6. backend emits raw incumbent/bound/progress
7. checker validates assignment against canonical constraints
8. only checked candidate enters CandidateStore/Pareto frontier
9. at safe point honor cancel/checkpoint/budget
10. normalize outcome + termination; seal evidence and resource actuals
11. Runtime receives proposal-only candidates and decides whether to branch/apply
```

### 3.3 关键设计决策

- **双状态而非一个 status**：`outcome` 描述已证明的数学结论，`termination` 描述为什么停止，避免 `timeout_with_incumbent` 混成成功；
- **checker 是 capability 的一部分**：没有 checker 的 backend 可 shadow，但不能发布 feasible candidate；
- **adapter 先保数值再重构 kernel**：第一阶段不顺手修改 legacy 算法；correctness 修复单独 PR，有 before/after golden；
- **局部 typed ProblemSpec，不做万能表达式解释器**：首版按 `ProblemKind` 注册 model builder/checker schema；
- **worker isolation 默认保守**：裸指针、全局 RNG、固定文件路径或未知线程安全的 backend 默认进程隔离；
- **proof 与 evidence 分层**：backend 原始状态是 evidence，只有 ProofBuilder 验证完语义才能形成 Solver claim。

---

## 4. 统一契约与 schema

### 4.1 `ProblemSpec`

```text
ProblemSpec
  schema_version / problem_id / problem_kind
  base_snapshot_ref
  intent_ref / scenario_set_ref / tech_context_ref / policy_ref
  scope {object_ids, regions, layers, excluded/protected objects}
  unit_system_ref
  variables[]
    {id, value_type, domain, lower/upper, allowed_values,
     initial_value?, source_object?, unit?, symmetry_group?}
  constraints[]
    {id, type, HARD|SOFT, operands, relation, rhs, tolerance,
     applicability, source_ref, checker_id}
  objectives[]
    {id, expression, MINIMIZE|MAXIMIZE|TARGET_RANGE,
     lexicographic_level, tolerance, aggregation, unit}
  decomposition {blocks, coupling_edges, merge_rule}
  warm_start_ref? / expected_invariants[]
  requested_evidence / allowed_backend_families[]
```

约束表达式只允许该 `ProblemKind` schema 注册的 typed operator，例如 `NoOverlap1D`、`AllowedAssignment`、`LinearLe`、`PartitionBalance`。`expression` 是结构化 AST/ref，不是 C++ function pointer、Python、Tcl 或字符串公式。

Canonicalizer 必须：

- 按 stable ID 排序对象、变量、约束和无序集合；
- 将等价单位转成 canonical exact representation，并保留 source unit；
- 保留 hard/soft、strict/non-strict 和 tolerance 差异；
- 检测 dangling object、空 domain、上下界反转、NaN/Inf 和重复 constraint ID；
- 将 context、schema、normalized payload 共同计算为 `problem_id`。

### 4.2 `SolverRequest` 与执行策略

```text
SolverRequest
  request_id / idempotency_key
  capability {name, version_constraint, qualification_ref?}
  problem_spec_ref | inline_problem_spec
  fidelity = AUTO | F0 | F1 | F2 | F3 | F4
  solve_mode = FIRST_FEASIBLE | IMPROVE | PROVE | ENUMERATE | PARETO
  candidate_limit / diversity_policy
  budget {wall_ms, cpu_ms, rss_bytes, iterations, nodes,
          candidate_events, artifact_bytes, license_credits}
  stop {objective_target?, relative_gap?, absolute_gap?, no_improve_epochs?}
  reproducibility {seed, threads, deterministic_profile}
  checkpoint_policy / progress_policy / return_policy
```

请求中的预算只是上限意图；Runtime `BudgetLedger` 是权威。Solver 启动前拿 reservation，child run 只能消费父 reservation 的子配额，完成后按 actual 结算。

### 4.3 `Candidate` 与 proposal-only 输出

```text
SolverCandidate
  candidate_id / problem_id / producer_run_id / sequence
  assignment_ref
  proposal_ref?                 # 领域 model builder 可选生成
  objective_values[] {objective_id, value, unit, evaluation_kind}
  feasibility
    {PASS|FAIL|UNKNOWN, checker_qualification, constraint_coverage,
     max_residual, violated_constraint_ids, tolerance_profile}
  source {backend, family, parameters, seed, threads, warm_start_ref?}
  discovered_at {wall_ms, cpu_ms, iteration, node}
  lineage {parent_candidate?, transform?, model/ranker refs?}
  diversity_signature / artifact_refs
```

`assignment_ref` 是 Solver 真正求出的数学赋值。`proposal_ref` 是领域 adapter 把赋值转换成 `ResizeInst/MoveInst/...` 等 typed proposal 的结果，但没有 apply 语义。若映射不完整或对象已 stale，candidate 状态为 `UNMAPPABLE`，不能传给 Runtime branch。

### 4.4 `SolverResult`、outcome 与 termination

```text
SolverResult
  request/problem/run/qualification refs
  outcome = OPTIMAL | FEASIBLE | INFEASIBLE | UNBOUNDED | UNKNOWN
  termination = COMPLETED | TARGET_REACHED | TIMEOUT | CANCELLED |
                ITERATION_LIMIT | NODE_LIMIT | MEMORY_LIMIT |
                WORKER_LOST | NUMERICAL_FAILURE | DEPENDENCY_FAILURE
  api_status = SUCCESS | PARTIAL | INVALID_INPUT | UNSUPPORTED |
               STALE_CONTEXT | RESOURCE_UNAVAILABLE | INTERNAL_ERROR
  candidates[] / rejected_candidate_summary
  bound_records[] / proof_bundle_ref
  coverage / progress_summary / resource_actual
  checkpoint_ref? / resume_token? / diagnostics[] / provenance
```

典型组合：

| 情况 | outcome | termination | api_status |
|---|---|---|---|
| 证明最优 | `OPTIMAL` | `COMPLETED` | `SUCCESS` |
| timeout 有 checked incumbent | `FEASIBLE` | `TIMEOUT` | `PARTIAL` |
| timeout 无可行解也无 proof | `UNKNOWN` | `TIMEOUT` | `PARTIAL` |
| qualified unsat/IIS/exhaustive proof | `INFEASIBLE` | `COMPLETED` | `SUCCESS` |
| 超出 domain | `UNKNOWN` | 不启动 | `UNSUPPORTED` |
| checker 推翻全部 raw incumbents | `UNKNOWN` | 依实际停止原因 | `PARTIAL` 或 `INTERNAL_ERROR` |

### 4.5 `ProofBundle`

```text
ProofBundle
  proof_id / problem_id / run_id
  feasibility_proofs[]
    {candidate_id, checker, checked_constraints, residuals, exactness, artifacts}
  bound_proofs[]
    {objective_id, sense, primal_bound?, dual_bound?, relaxation,
     absolute_gap?, relative_gap?, backend_status, tolerance}
  infeasibility_proof?
    {kind = UNSAT_CORE|IIS|FARKAS|EXHAUSTIVE|DOMAIN_SPECIFIC,
     constraint_ids, verifier, minimality_claim, coverage, artifact}
  unboundedness_proof?
  termination_evidence
  assumptions / skipped / unsupported
  verifier/tool/build/input hashes
```

`IIS` 不自动等于最小不可行子集，必须声明 `minimality_claim`。CP-SAT 只有在 assumption literals/对应 verifier 完整时才返回 unsat core；MIP backend 的 infeasible/unbounded 状态必须经 backend qualification 与必要的独立复核。无法导出可验证 artifact 时，proof 只能标 `BACKEND_ATTESTED`，不能伪装成 independently verified。

### 4.6 Bound 与 gap 规则

对于最小化目标，`primal_bound` 来自最佳 checked feasible candidate，`dual_bound` 来自有效 relaxation/proof；最大化目标方向相反。统一相对 gap：

```text
abs_gap = abs(primal_bound - dual_bound)
rel_gap = abs_gap / max(abs(primal_bound), abs(dual_bound), gap_scale)
```

每个 ProblemKind 冻结 `gap_scale` 与 absolute/relative tolerance。多目标不返回含糊的单一 gap：lexicographic 按 level 分别证明；Pareto 模式为每个 candidate/objective 保存 bound coverage。无合法 dual bound 时字段为 null，不能用 heuristic best-so-far 冒充。

### 4.7 身份、缓存与幂等

```text
problem_id = hash(canonical ProblemSpec + exact context/schema refs)
run_id = hash(problem_id + solver qualification + backend parameters
              + seed + threads + tolerance + budget/stop profile)
candidate_id = hash(problem_id + canonical assignment + proposal mapping version)
checkpoint_id = hash(run_id + checkpoint sequence + sealed artifact hash)
```

相同 idempotency key 与请求 payload 返回同一 active/terminal operation；payload 不同则冲突。Solver result cache 只复用 exact run identity 的 terminal evidence；更大预算的旧 run 不能假装是新 run，较小预算也不能仅截日志伪造对应 termination。

---

## 5. Agent Capability API

### 5.1 API 面

| API | 语义 |
|---|---|
| `solver.capabilities` | 按 ProblemKind/context/domain 查询已 qualified backend/fidelity |
| `solver.validate_problem` | 只 canonicalize/validate，返回 unsupported predicates 和规模估计 |
| `solver.solve` | 异步提交，返回 operation/run ID |
| `solver.watch` | 从 sequence cursor 读取 progress/incumbent/bound/terminal event |
| `solver.status` | 当前状态、预算、最后 checked incumbent 和 checkpoint |
| `solver.cancel` | 幂等请求 cooperative cancel 或 worker termination |
| `solver.checkpoint` | 在 capability 支持的安全点创建 sealed checkpoint |
| `solver.resume` | 校验 token 与新 budget 后继续同一 run lineage |
| `solver.explain_result` | 返回结构化 rejected/proof/termination 解释，不从日志猜测 |

Planner 只消费 Registry 发布的 capability snapshot；执行前 Runtime 再解析精确 qualification，防版本漂移。普通 Agent 无 `register_backend` 权限。

### 5.2 `SolverManifest`

```yaml
capability: solver.clock.htree_slot_choice@1
problem_kinds: [clock.htree_slot_choice@1]
backend: {id: highs_htree@1, family: mip, build: "sha256:..."}
domain:
  variable_types: [binary, continuous]
  constraint_families: [linear, affine_choice]
  max_variables: 200000
  tech_qualification_required: true
supports:
  modes: [first_feasible, improve, prove]
  fidelity: [F2, F3]
  streaming: bounds_only
  cancel: process
  checkpoint: false
  resume: false
determinism:
  profiles: [reproducible]
  seed_controlled: true
  thread_sensitive: true
proof:
  feasibility_checker: htree_assignment_checker@1
  bounds: [primal, mip_dual, gap]
  infeasibility: backend_attested
permissions: R1
```

示例仅定义 TARGET manifest 字段，不表示当前 H-tree adapter 已注册或达到 F3。实际 limits、thread/seed 支持和 proof 等级由 qualification 数据生成，不能手填后即 ACTIVE。

### 5.3 能力成熟度

| Readiness | 含义 | 可见范围 |
|---|---|---|
| `CONTRACT` | schema/manifest/validator fixture 已冻结 | 开发测试 |
| `SHADOW` | adapter 可运行，结果不参与选择/apply | shadow corpus |
| `QUALIFIED` | domain 内 checker、failure、resource、security、held-out 门禁通过 | 限定 Runtime policy |
| `ACTIVE` | 至少一个真实闭环 consumer，SLO/rollback/revocation 完整 | Gateway 发布 |
| `SUSPENDED/RETIRED` | 漂移、CVE、escaped defect 或替代 | 新请求不可解析 |

目录存在、测试数量、编译成功或一次 demo 都不能推进 readiness。

---

## 6. F0-F4、backend 选择与回落

### 6.1 Fidelity 是证据等级，不是算法排行榜

| 档位 | Solver 典型实现 | 允许用途 | 必须输出 | 禁止 claim |
|---|---|---|---|---|
| F0 | presolve、规则、解析 bound、几何过滤 | 域检查、候选剪枝、规模估计 | 适用域、过滤原因、bound exactness | feasible/optimal |
| F1 | learned ranker、已校准 cost/feasibility predictor | backend/变量/候选排序 | model qualification、OOD、校准误差 | proof/infeasible |
| F2 | Abacus/METIS/SA 等 heuristic、短时 MIP/CP-SAT | 找 incumbent、局部探索 | checker coverage、资源、unknown bounds | 设计可提交、无 proof 的 infeasible |
| F3 | qualified open-source exact/complete-enough 模式 | 提交前数学确认、gap/proof | full declared domain、independent checker、proof/bounds | 超出 coverage 的结论 |
| F4 | 独立商业 solver/第二实现/exhaustive oracle | 高风险、分歧和 qualification | 独立 input/protocol/artifact | 自动等同设计 signoff |

同一 HiGHS run 在短预算、无 proof 时可只是 F2；同一 CP-SAT backend 只有在 domain、proof、checker 和停止条件满足 qualification 时才可作为 F3。F4 通过 57 External Tool Bridge 和 47 Oracle protocol 接入，不直接执行 shell。

### 6.2 适用域矩阵

| 家族 | 适合 | 不适合/风险 | 默认回落 |
|---|---|---|---|
| CP-SAT（TARGET） | 有限整数/布尔、逻辑、NoOverlap、局部离散选择 | 连续非线性、浮点物理模型；unsat core 有假设前提 | domain 不可编码则 MIP/领域 heuristic；依赖未 qualified 则 unsupported |
| MIP/HiGHS | 线性连续+整数、可给 primal/dual/gap | big-M 数值、非线性近似、容差导致假可行 | 数值异常换 scaling/profile；无 incumbent 转 heuristic warm start |
| 领域 heuristic | 快速找 local incumbent、复杂黑盒目标 | 通常没有 dual/proof，可能只覆盖窄 domain | checker 失败即丢弃；no result 换核/扩域 proposal |
| learned ranker | 排 backend、变量、seed、候选验证顺序 | OOD、数据泄漏、自我强化、分数不可解释 | OOD/model outage 退确定性规则；永不绕过 checker |

Router 固定流程：hard domain filter -> required proof/fidelity filter -> resource/license availability -> deterministic baseline ranking -> optional qualified ranker reorder -> diversity allocation。没有满足证据要求的 backend 时返回 `UNSUPPORTED`，不能静默降 proof。

### 6.3 Ranker 纪律

Ranker 输入只含批准的 problem/context domain signature 和历史结构化统计；默认不读取原始 PDK、网表名字或自由文本。训练按 design family/PDK/problem family 分组切分，报告 solver-selection regret、first-feasible time、unsafe preference 和 OOD false-negative。模型只在确定性候选集内排序；模型 hash/prompt/feature schema 变化重新 qualification。

---

## 7. Anytime 状态机、预算、cancel 与 resume

### 7.1 运行状态机

```text
CREATED -> VALIDATING -> READY -> QUEUED -> RUNNING
RUNNING -> INCUMBENT_AVAILABLE -> RUNNING
RUNNING -> CHECKPOINTING -> RUNNING
RUNNING -> COMPLETED | LIMIT_REACHED | CANCELLING | FAILED
CANCELLING -> CANCELLED | ISOLATION_FAILURE
LIMIT_REACHED/CANCELLED/FAILED -> RESUMABLE | TERMINAL
```

状态和事件 append-only；`INCUMBENT_AVAILABLE` 只在 checker PASS 后发布。progress event 至少含 monotonic sequence、run/child、wall/CPU、iteration/node、raw/checked incumbent、bound、queue-drop count 和 checkpoint ref。事件 fraction 不可计算时为 null，不伪造 90%。

### 7.2 Budget 与 portfolio

Runtime 原子 reserve 总预算，Solver 再给 child `initial_slice + bounded_extension`。`BudgetController` 在模型构建、epoch/node batch、incumbent、checkpoint 前后检查 deadline/cancel。RSS/file/output 等硬限制由 worker/cgroup 执行；in-process 只能用于已证明可控的 backend。

Portfolio 只比较同 ProblemSpec/目标语义的 checked candidate；先淘汰 infeasible，再维护 lexicographic/Pareto frontier。reallocation policy 版本化，以进展、bound、diversity和预计信息价值分配，不能让最快 backend 吞掉全部预算。父 cancel 必须传播到所有 child，terminal 前确认无孤儿 worker。

### 7.3 Cancel、checkpoint 与 resume

- cooperative backend 在声明的 safe point 检查 cancel，qualification 报 p50/p95/max latency；
- 无 safe point 的 legacy backend 标 `cancel=process`，隔离 worker 被 TERM/KILL 后不能声称可 resume；
- checkpoint 包含 backend-native state、canonical candidate frontier、RNG state、iteration/node 和 proof progress；
- token 绑定 `problem_id/run_id/backend build/ABI/dependency/seed/threads/tolerance/checkpoint hash/tenant`；
- checkpoint 先写临时 CAS artifact、校验后 seal，再发布 token；截断 artifact 不可见；
- native blob 只能由同一受信 build 在隔离 worker 反序列化，size/decompression/object-count 均限额；
- resume 增加的是新预算 reservation，不重置已消费账本；连续运行与 resume 的等价性按 manifest 容差测试。

首版只为明确支持稳定 state serialization 的 backend开放 resume；Abacus rollback 不是 checkpoint，HiGHS 当前 time limit 也不等于公共 resume。

---

## 8. 可行性、目标、bounds 与失败语义

### 8.1 独立 checker

每个 ProblemKind 注册 checker，而不是让每个 backend 自定义正确性。checker 读取 canonical ProblemSpec + assignment，逐 constraint ID 返回 checked/skipped/unsupported、residual 和 tolerance；整数/布尔先验证 domain，浮点线性约束使用 scale-aware tolerance。checker 与 backend 不共享可变模型对象，避免同一建模 bug 自证。

| ProblemKind | 首版独立检查 |
|---|---|
| local legalization | object completeness、row/site、overlap、fixed/protected、region、最大位移；apply 后仍需 iPL certificate |
| H-tree slot choice | choice 完整性、domain、affine constraint residual、fanout/buffer rule；随后运行 AnalyticalValidation |
| graph partition | 每 vertex 恰一 part、part range、balance、cut 从原图重算 |
| local discrete assignment | domain/allowed tuple/all-different/capacity 等 schema operator 全量重算 |

### 8.2 目标与 candidate 纪律

hard feasibility 先于 objective。多目标默认 lexicographic 或 Pareto，不允许 adapter 私自构造隐藏加权总分；若领域批准 utility，权重/归一化进入 PolicyRef。incumbent 单调性按已声明 order 判断：单目标 best 不变差；Pareto frontier 可增删被支配点，但每次变化可重放。重复 assignment 用 canonical hash 去重。

### 8.3 错误与 Agent 恢复

| 条件 | 结果 | 允许恢复 |
|---|---|---|
| schema/unit/ref 错 | `INVALID_INPUT` | 修输入，不换 seed |
| domain/规模/proof 不支持 | `UNSUPPORTED` | 换 qualified capability 或分解 |
| 已验证 infeasible proof | `INFEASIBLE` | Planner 可提出扩大 scope；不得改硬约束 |
| 无 proof 且没找到解 | `UNKNOWN + NO_FEASIBLE_FOUND` | 延长、换核、warm start、分解 |
| timeout/cancel 有 incumbent | `FEASIBLE + PARTIAL` | 消费 candidate 或合法 resume；不可自动 commit |
| NaN、奇异、MIP 数值问题 | `NUMERICAL_FAILURE` | scaling/profile/alternate backend |
| dependency/license 不可用 | `RESOURCE_UNAVAILABLE` | bounded retry/alternate environment |
| checker 推翻 raw incumbent | candidate rejected + diagnostic | backend quarantine 阈值；不得发布 |
| checkpoint 不兼容/损坏 | `STALE_RESUME_TOKEN`/`ARTIFACT_INVALID` | 从 ProblemSpec 重启 |

---

## 9. 确定性、并发与隔离

| Profile | 承诺 | 典型用途 |
|---|---|---|
| `STRICT` | 同 build/machine/profile 的 candidate/proof hash 一致 | schema/checker、小型 exact |
| `REPRODUCIBLE` | 同 identity 在声明数值容差内结果/结论一致 | MIP/并行数值 backend |
| `STATISTICAL` | 固定 seed 可追踪；多 seed 分布经 qualification | stochastic heuristic/ranker |

所有 backend 禁止公共 `rand()`；使用 run-local RNG 并保存 state。canonical ordering 后再建模；线程数、OpenMP/BLAS/solver 参数进入 identity。并发策略默认：immutable ProblemSpec 可共享；backend instance、temporary directory、RNG、progress sink 和 checkpoint 独占。Abacus 的可变 cluster/rollback state、GeometryBoost 的 lazy mutable cache、METIS wrapper 的裸状态均在证明可重入前隔离实例；hMETIS 固定文件路径/`system()` 路径不得进入 in-process adapter。

并发测试不能只跑 TSAN：同一请求 N 路并发、不同 tenant 同名对象、cancel 与 incumbent/checkpoint 竞态、worker crash 后重启都要验证 artifact/candidate 不串线。

---

## 10. Proposal、apply 与设计级验证

```text
ProblemBuilder(snapshot/context/scope) -> ProblemSpec
Solver -> checked assignment -> ProposalCompiler -> SolverProposal
Runtime validates proposal/base/head/scope -> forks branch
iDB applies TypedDelta on branch -> actual touched + invalidation set
Verification Hub builds required certificate DAG
iEval compares base/candidate metrics and applies QoR gate
Runtime commits exact branch head or records rejection
```

SolverProposal 必须包含 base snapshot、stable object IDs、typed action、declared scope、preconditions、expected invalidations、inverse/checkpoint requirement 和 assignment lineage。它不包含写指针或“已验证”布尔。ProposalCompiler 是领域 owner 代码；Solver core 不理解 `MoveInst` 的物理副作用。

若实际 touched 超 scope、base head stale、proposal 无法映射、apply 失败或 certificate incomplete，candidate 仍可保留数学 evidence，但 disposition 为 rejected/unapplied。优化目标改善不能覆盖 frozen/connectivity/legal/timing/DRC hard fail。

---

## 11. 现有 kernel 迁移切片

| 顺序 | Adapter | CURRENT 保持 | TARGET 增量与退出门禁 |
|---:|---|---|---|
| 1 | `AbacusLocalLegalizeAdapter` | 不改 Abacus 数值和 iPL 旧入口 | copy/view 输入、proposal-only、独立 checker、rollback/timeout 对拍；限定单高 domain |
| 2 | `HtreeHighsMipAdapter` | 复用现有 model/status/bound/gap | 映射双状态、resource evidence、独立 residual checker；current tests + exhaustive toy |
| 3 | `MetisGraphPartitionAdapter` | 复用 METIS objective/options | RAII、完整 input/status/seed、cut/balance 重算、worker isolation |
| 4 | `CpSatLocalSolverAdapter` | 无 CURRENT 实现 | 依赖/SBOM/license 决策、typed operator subset、unsat/exhaustive、Honey T2 template |
| 5 | `SolverRanker` | 无公共 CURRENT ranker | deterministic baseline、shadow model、OOD/family holdout/regret |

Geometry 先作为 `GeometryCheckerSupport`：补 const snapshot/view、degenerate/overflow/metamorphic tests 后供 feasibility checker 使用，不包装成虚假 optimizer。SA 只有在移除 global `rand()`、保存 best checked incumbent、加入 safe point 和 rollback invariant 后才能进入 SHADOW。hMETIS 必须走 57 的 fixed argv/workspace/artifact protocol；现有 `system()` 入口不可注册。

---

## 12. 跨模块契约

| 对端 | Solver 消费 | Solver 产出 | 失败传播 |
|---|---|---|---|
| Planner 54 | Goal/Action、capability snapshot、建议 fidelity | candidate/proof/cost/stop evidence | Planner 不能改 Solver outcome；unsupported 进入有界恢复 |
| Runtime 43 | immutable refs、budget reservation、cancel、worker | operation/events/resource actual/resume | partial 不能 commit；父预算/branch 状态权威 |
| Evaluation 12 | objective definitions、calibration/route advice | candidates、solver cost/evidence | iEval 不把 ranker score当 metric/proof |
| Verification 49 | required claims、checker qualification/revocation | math proof + proposal lineage | design certificate 单独签发；Solver proof 不升级 claim |
| Honey 46 | CompiledRequirement/template/package qualification | T2 proposal-only solver result | fixed runtime/checker 不可由生成 slot 替换 |
| Data/Oracle 47 | frozen corpus、F4 protocol、split/ACL | 每个 run/candidate/failure lineage | winner-only 禁止；holdout 标签不回流在线 ranker |
| TechContext 55 | canonical IDs/units/domain qualification | consumed tech IDs/hits/misses/defaults receipt | ambiguous/unmapped/changed context -> unsupported/stale |
| Experience 56 | applicable success/failure/counterexample | disposition + evidence refs | 历史只影响排序/恢复，不影响 proof |
| External Bridge 57 | qualified external solver job/result | normalized candidate/bound/raw artifact refs | rc=0 不是 success；parser/protocol drift quarantine |

---

## 13. LLD 与源码落点

### 13.1 TARGET 目录

```text
src/solver/
  api/{SolverService,SolverCapabilityApi}.{hh,cc}
  contract/{ProblemSpec,SolverRequest,SolverResult,SolverManifest,ProofBundle}.hh
  schema/{SchemaRegistry,ProblemCanonicalizer,RequestValidator}.{hh,cc}
  registry/{BackendRegistry,QualificationStore,DomainMatcher}.{hh,cc}
  runtime/{SolverOperation,BudgetController,Cancellation,ProgressBus}.cc
  runtime/{WorkerPool,IsolatedWorker,PortfolioRunner,CheckpointStore}.cc
  checker/{CheckerRegistry,FeasibilityChecker,ResidualReport}.cc
  result/{CandidateStore,BoundNormalizer,ProofBuilder,EvidenceWriter}.cc
  routing/{FidelityRouter,DeterministicRouter,RankerAdapter}.cc
  adapters/{abacus,htree_highs,metis,cp_sat}/
  support/geometry/
  test/agent_solver/

contracts/solver/{problem_spec,solver_manifest,solver_result,proof_bundle}/*.json
benchmarks/solver/{manifests,protocols,toy,heldout,reports}/
```

现有 `legalization`、`geometry` 和领域私有内核先不移动；adapter 通过窄接口链接。跨工具迁移需单独 owner/consumer PR，不能先复制代码形成双真值。

### 13.2 关键接口

```cpp
class ISolverBackend {
 public:
  virtual BackendManifest manifest() const = 0;
  virtual Availability check(const ProblemSpec&, const SolvePolicy&) const = 0;
  virtual BackendResult solve(const ProblemSpec&, SolveContext&) = 0;
};

class IFeasibilityChecker {
 public:
  virtual CheckerManifest manifest() const = 0;
  virtual FeasibilityReport check(const ProblemSpec&, const Assignment&) const = 0;
};

struct SolveContext {
  BudgetView budget;
  CancellationToken cancel;
  ProgressSink progress;
  CheckpointWriter checkpoint;
  RunLocalRng rng;
};
```

`ISolverBackend` 不接 iDB mutable pointer，不签发 design certificate。Adapter 可以调用 legacy kernel，但必须把所有 ambient state 物化为输入 artifact/session，并在 evidence 中记录实际消费。

---

## 14. 安全、供应链与运维

- ProblemSpec/manifest 只允许 schema operator 与 allowlisted backend；拒绝动态 callback、路径、脚本和环境变量注入；
- backend/build/package 绑定 SBOM、compiler flags、依赖 lock、license、CVE 和签名；变更使 qualification/cache/checkpoint stale；
- worker 默认无网络、只读输入、专用空输出目录、最小 UID/namespace/cgroup；secret/license 通过 broker 注入且不写 evidence；
- checkpoint/model/外部 artifact 做 hash、schema、长度、递归深度、解压比和 tenant ACL 检查；
- learned model 与 Honey generated source 视为不可信供应链输入；active 版本运行时不重新生成/下载；
- escaped infeasible candidate、错误 proof、越权写、孤儿进程、跨 tenant cache 命中立即 suspend qualification，追溯证书、数据集和 Experience；
- 运营指标分开报告服务可用性与物理解质量：queue/run/cancel p95、RSS overshoot、orphan、checker rejection、proof invalid、resume failure、determinism drift、first feasible、final gap。

---

## 15. 测试、benchmark 与可杀假说

### 15.1 测试分层

| 层 | 方法 | 必须锁住 |
|---|---|---|
| L0 schema/unit | golden + invalid fixtures | null/unknown 不变 0，hard/soft/units 不漂移 |
| L1 checker | exhaustive toy + property/fuzz | 所有 assignment 与枚举 oracle 一致 |
| L2 adapter | legacy/direct differential | adapter 不改变原数值/termination，差异有批准 |
| L3 metamorphic | rename/order/translation/unit scale/symmetry | 结果按预期不变或等变 |
| L4 runtime | timeout/cancel/OOM/worker loss/resume/event stall | 无丢 incumbent、孤儿、负预算和损坏 checkpoint |
| L5 portfolio | duplicate/diversity/bound/near-gate | frontier、reallocation、停止可重放 |
| L6 mutation | 删除 constraint/checker、翻 sense/status、伪 bound | 核心 mutation 必须被测试杀死 |
| L7 workflow | propose -> branch -> verify -> gate | 主 snapshot 零写，incomplete 无 commit |
| L8 benchmark | smoke/daily/weekly/scale/heldout | quality/cost/regret/稳定性按 family 分桶 |

### 15.2 CI 编号与反例

`SOL-T01` schema/context/unit；`SOL-T02` exhaustive feasible/optimal/infeasible；`SOL-T03` infeasible vs no-feasible-found；`SOL-T04` primal/dual/gap direction；`SOL-T05` checker rejects corrupted incumbent；`SOL-T06` timeout/cancel event race；`SOL-T07` resume vs continuous；`SOL-T08` strict/reproducible/statistical profiles；`SOL-T09` concurrent tenant/artifact isolation；`SOL-T10` adapter legacy parity；`SOL-T11` metamorphic rename/order/translation/scale；`SOL-T12` portfolio total budget/diversity；`SOL-T13` ranker OOD/model outage fallback；`SOL-T14` unsupported domain loud failure；`SOL-T15` checkpoint fuzz/deserialization limits；`SOL-T16` mutation score；`SOL-T17` dependency/CVE/revocation propagation；`SOL-T18` proposal cannot write/apply/commit。

每个 kernel 增加专属反例：Abacus 无空位、fragmented row、fixed/region/multi-height；H-tree invalid affine domain、infeasible choice、tiny time limit、big-M/numeric scaling；METIS empty/asymmetric/disconnected graph、invalid vertex、极端 balance；CP-SAT empty domain、assumption core、integer overflow；ranker 高置信选错与跨 PDK OOD。

### 15.3 Benchmark protocol

结果绑定 input/build/context/qualification/protocol/machine/seed/threads hashes；性能至少五次重复报告 median/MAD。按 ProblemKind、变量/约束规模、稀疏度、可行性、PDK/family 分桶，记录 validation/build overhead、time-to-first-checked-feasible、time-to-best、final objective/gap、checker rejection、cancel latency、peak RSS、artifact bytes。portfolio 额外报告 selection regret、算法多样性和每单位 F3/F4 预算的决策收益。

训练/calibration/最终 gate 按 design family/PDK 隔离；同一 snapshot 派生候选不得跨 split。Golden 首选人工可核 toy/exhaustive；differential oracle 也保存冲突，不能多数投票生成真值。

### 15.4 可杀假说

| 假说 | 实验 | 失败动作 |
|---|---|---|
| H-SOL-A1：统一 contract 对 10 ms+ 内核 overhead <= 2% | adapter/direct 分规模对拍 | 零复制 view/批量事件；不绕 contract |
| H-SOL-A2：checker 能阻止 backend 假可行 | mutation/fuzz 注入缺 constraint、容差错误 | 修 checker/schema，暂停 backend |
| H-SOL-A3：异构 portfolio 固定预算优于单 backend | held-out first-feasible/final regret A/B | 简化 router，保留单 backend baseline |
| H-SOL-A4：checkpoint/resume 产生净收益且结果一致 | 故障/抢占 workload 连续对拍 | 对该 backend 禁用 resume，只保 partial |
| H-SOL-A5：ranker 降低求解成本且不增 unsafe preference | family holdout + model outage | ranker 保持 shadow，使用确定性路由 |
| H-SOL-A6：T2 模板 solver 缩短交付且 defect 不增 | 人工 vs Honey lead-time/mutation/escaped defect | 停止自动 T2 晋级，保留模板辅助 |

---

## 16. 里程碑、PR 切片与完成定义

| 阶段 | 周期 | 交付 | 退出门禁 |
|---|---:|---|---|
| SOL-A0 事实冻结 | 2 周 | consumer/asset 台账、schema、toy protocol | CURRENT/TARGET、TBD、私有入口均可机检 |
| SOL-A1 契约地基 | 3 周 | Problem/Result/Proof/Manifest、validator、registry | invalid/unsupported/status 反例全过 |
| SOL-A2 首个闭环 | 4 周 | Abacus adapter/checker、proposal-only、Runtime branch | legacy parity；Timing ECO 无主状态写 |
| SOL-A3 MIP 与 runtime | 4 周 | H-tree HiGHS、budget/progress/cancel worker、bounds | exhaustive toy、timeout incumbent/gap 正确 |
| SOL-A4 portfolio | 4 周 | METIS、Pareto/diversity/router、benchmark | total budget 不超；held-out 对 baseline 报告 |
| SOL-A5 resume/CP-SAT | 4-6 周 | selected checkpoint；依赖批准后的 CP-SAT T2 | resume parity、安全反序列化、exhaustive |
| SOL-A6 学习与生成 | 持续 | ranker shadow、Honey T2、F4 differential | family holdout 收益；mutation/security 全过 |

建议 PR：`SOL-0 facts+schemas` -> `SOL-1 canonicalizer+checker SDK` -> `SOL-2 Abacus proposal-only` -> `SOL-3 worker+budget+cancel` -> `SOL-4 H-tree HiGHS proof mapping` -> `SOL-5 METIS+portfolio` -> `SOL-6 checkpoint selected backend` -> `SOL-7 CP-SAT dependency/template` -> `SOL-8 ranker shadow`。每个 PR 必须附 ProblemKind/domain、状态映射、checker、正反 golden、resource/security、真实 consumer 和 readiness ledger 变更。

一个 capability 只有在 manifest/domain、独立 checker、failure/partial、determinism/isolation、budget/cancel、supply-chain、held-out benchmark、revoke 和至少一个闭环 consumer 全部具备后才 ACTIVE。“注册成功并返回一个数”不算 Agent-ready。

---

## 17. 开放问题与决策点

| ID | 问题 | 决策原则 |
|---|---|---|
| OI-SOL-02 | CP-SAT 依赖选择与许可证/体积 | 依赖、安全、SBOM、构建矩阵批准前保持 NOT_STARTED |
| OI-SOL-03 | HiGHS infeasible/unbounded proof 等级 | 未有独立 verifier 前明确 backend-attested，不扩大 claim |
| OI-SOL-04 | Abacus 的精确 supported domain | 以真实 corpus + adversarial qualification 冻结，不根据类名猜 |
| OI-SOL-07 | checkpoint 跨版本迁移 | 首版不迁移；同 build/ABI only，需求成立后另立格式 |
| OI-SOL-08 | Geometry support 的 ownership | checker 稳定前留 `src/solver/support`；若多模块消费再独立服务 |

---

## 附录 A：术语

- **ProblemSpec**：绑定 snapshot/context、变量、硬软约束和目标的 canonical 数学问题。
- **SolverProposal**：由领域 adapter 从 assignment 编译出的 typed、未 apply 动作。
- **Incumbent**：当前最佳且已经独立 checker 复核的可行 candidate。
- **ProofBundle**：数学可行性、bounds、不可行/无界和停止证据；不等于设计 certificate。
- **Qualification**：backend+build+domain+fidelity+checker+protocol 的限定资格。
- **Fidelity**：成本、覆盖和证据强度档位；不由算法名称决定。

## 附录 B：版本历史

- ai1.1（2026-07-24）：按 Evaluation 深度重构；完成 CURRENT/TARGET 审计、Problem/Candidate/Proof schema、Capability API、F0-F4/backend 回落、anytime/cancel/checkpoint、确定性隔离、proposal/apply 边界、跨模块契约、LLD、安全供应链、完整测试/假说/里程碑。
- ai1.0（2026-07-23）：定义初版 SolverRequest/Result、Problem IR、portfolio、失败语义和 adapter 方向。
