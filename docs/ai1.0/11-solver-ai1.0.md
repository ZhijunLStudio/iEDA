<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 11 · Solver Agent 可组合数值内核实施方案 · ai1.0

> 基线：`11-solver.md`。现有 legalization、geometry、partition、quadratic programming、routing 等资产分散；本文定义供 Agent 和生成工具复用的统一求解契约。

## 1. 目标

将 solver 从“被各工具静态链接的算法目录”升级为可发现、可预算、可中断、可比较的局部求解服务。Agent 不直接选择内部类，而是声明问题、硬约束、目标向量、预算和证据要求。

## 2. Solver Contract

```cpp
struct SolverRequest {
  ProblemKind kind;
  SnapshotId snapshot;
  Scope scope;
  HardConstraints hard;
  ObjectiveVector objectives;
  ResourceBudget budget;
  uint64_t seed;
};

struct SolverResult {
  Status status;              // optimal/feasible/partial/infeasible/timeout/error
  CandidateSet incumbents;
  std::optional<double> lower_bound;
  std::optional<double> upper_bound;
  double gap;
  Coverage coverage;
  ResumeToken resume;
  SolverEvidence evidence;
};
```

`infeasible` 必须带冲突约束或最小不可行子集的近似证据；`partial` 必须有可行 incumbent 或明确“尚无可行解”。

## 3. 首批 kernel 注册

| 注册名 | 复用目录 | Agent 场景 | 首版边界 |
|---|---|---|---|
| `legalize.abacus` | `src/solver/legalization` | ECO 局部合法化 | 标准单元、单 region |
| `geometry.query` | `src/solver/geometry` | DRC/route/observer | 只读确定性谓词 |
| `partition.hypergraph` | `src/solver/partition` | floorplan/并行分区 | 输出多候选 |
| `place.quadratic` | `src/solver/qudratic_programming` | 局部/全局布局 seed | 不负责最终合法 |
| `route.two_pin` | `src/solver/two_pin_routing` | 局部绕障候选 | 有限 layer/region |
| `tree.steiner` | `src/solver/steiner_forest` | clock/net topology | 声明近似比未知 |

## 4. LLD

```text
src/solver/runtime/
  SolverRegistry.{hh,cc}
  SolverContract.hh
  BudgetController.{hh,cc}
  ProgressSink.hh
  ResumeStore.{hh,cc}
  DeterminismGuard.{hh,cc}
  PortfolioRunner.{hh,cc}
```

adapter 不改变现有 kernel 数值，先统一入口与证据。第二阶段才允许实现 checkpoint/cancel；无法安全中断的 kernel 在 manifest 中声明 `cancel=process_only`。

## 5. Portfolio 规则

- 同一问题可并行运行多个 solver/seed，但共用总预算；
- 硬约束不满足的候选先淘汰，再比较 Pareto；
- 不允许把不同语义的 cost 直接横向排序；
- portfolio 必须保留算法多样性，不能只是同模型五个 seed；
- 每个候选输出产生者、参数、seed 和终止原因。

## 6. 里程碑

| 阶段 | 交付 | 门禁 |
|---|---|---|
| SOL-A0（2 周） | contract + registry + geometry/Abacus adapter | 现有回归数值不变 |
| SOL-A1（3 周） | budget/progress + feasible incumbent | 超时不丢已得可行解 |
| SOL-A2（3 周） | portfolio runner + Pareto | 3 kernel/seed 可统一比较 |
| SOL-A3（4 周） | resume/cancel for selected kernels | 恢复后与连续运行容差一致 |
| SOL-A4（持续） | local exact solver templates | 生成工具过 mutation/golden 门禁 |

## 7. 测试

- 小问题穷举真值验证 optimal/feasible/infeasible；
- 相同 seed 确定性 hash；不同线程数结果差异白名单；
- timeout、cancel、OOM、数值发散；
- 约束冲突不返回空 success；
- incumbent 单调不变差；
- solver adapter 与原入口逐位或容差对拍。

**H-SOL-A1**：统一 contract 不显著增加内核墙钟。若 adapter overhead 在 10 ms 以上任务中超过 2%，改用零复制 view/批量事件，不能绕过 contract。

---

## 8. Problem IR 与能力清单

### 8.1 规范问题描述

```text
ProblemSpec
  problem_id / kind / schema_version
  snapshot_ref / intent_ref / tech_context_ref
  scope {objects, regions, layers}
  variables[] {stable_id, domain, bounds, initial_value, unit}
  constraints[] {id, type, hard|soft, expression_ref, tolerance, source}
  objectives[] {id, direction, expression_ref, lexicographic_level}
  decomposition {independent_blocks, coupling_edges}
  warm_start_ref / expected_invariants
```

表达式只允许 registry 中的 typed operator；不能将 Agent 生成的任意代码指针塞入 solver。所有长度、时间、容量和 cost 先归一化，原始单位进入 provenance。hard constraint 不能通过 penalty 权重偷偷变成 soft。

### 8.2 `SolverManifest`

```yaml
solver_id: legalize.abacus@1
problem_kinds: [placement.local_legalization]
domain: {cell_kinds: [stdcell], stages: [post_place, post_cts]}
supports: {warm_start: true, partial: true, cancel: iteration, resume: false}
guarantees: {feasibility_check: exact, optimality: heuristic}
determinism: {seeded: true, thread_sensitive: false}
limits: {max_variables: 100000, max_regions: 1}
evidence: [constraint_residuals, displacement, termination_reason]
```

`manifest` 的 qualification 由测试证据产生。超出 domain 必须 `UNSUPPORTED`，不能靠“也许能跑”进入 portfolio。

## 9. 运行状态机与预算

```text
CREATED -> VALIDATING -> READY -> RUNNING
RUNNING -> FEASIBLE_PARTIAL -> RUNNING
RUNNING -> OPTIMAL | FEASIBLE | INFEASIBLE | TIMEOUT | CANCELLED | NUMERICAL_FAILURE
TIMEOUT/CANCELLED -> RESUMABLE | TERMINAL
```

预算分为 wall、CPU、内存、迭代、候选数和外部 license。`BudgetController` 每个安全点检查取消和限额；无法插入安全点的 legacy kernel 必须进独立 worker，以进程终止实现 cancel，并声明没有 resume。超时若有可行 incumbent，状态为 `TIMEOUT_WITH_INCUMBENT`；没有可行解不能返回空 `FEASIBLE`。

### 9.1 Incumbent 纪律

- 发布前用独立 feasibility checker 复核，而非相信 kernel 内部 flag；
- incumbent 序列在相同 hard constraint 下不得变差；多目标时保存 Pareto set；
- heuristic lower/upper bound 必须标来源，未知 bound 使用 null，不能填 0；
- warm start 若不合法，先报告并修复/拒绝，不把初始点算作可行 incumbent；
- resume token 绑定 problem/solver/binary/seed/thread config hash，不兼容时 `STALE_RESUME_TOKEN`。

## 10. Adapter 与执行架构

```text
SolverService
  -> ProblemValidator
  -> SolverRegistry/QualificationFilter
  -> BudgetController
  -> PortfolioRunner
       -> InProcessAdapter (已证线程/状态安全)
       -> IsolatedWorkerAdapter (legacy/global state)
  -> IndependentFeasibilityChecker
  -> ResultNormalizer/EvidenceBuilder
```

| 组件 | 关键实现 |
|---|---|
| `ProblemValidator` | 变量引用、单位、bounds、hard/soft、scope 和 capability domain |
| `PortfolioRunner` | 共用总预算、并行配额、incumbent event merge、early stop |
| `ProgressSink` | 有界 event 队列；慢 consumer 不阻塞 kernel |
| `DeterminismGuard` | 固定 seed/order/thread config，记录浮点/库版本 |
| `FeasibilityChecker` | 与优化 kernel 分离，对 hard constraints 逐项出 residual |
| `EvidenceBuilder` | 参数、终止原因、bounds、residual、资源、候选 lineage |

现有 kernel adapter 只转换数据和生命周期，不改数值；需要修 kernel correctness 时单独 PR，并以 adapter 前后 golden 区分行为变化。

## 11. 首批 kernel 的输入与验证

| Kernel | 最小输入 | 独立可行性检查 | 关键退化 |
|---|---|---|---|
| Abacus | rows/sites/cells/obstacles/target x | row/site、overlap、fixed、region | multi-height、fragmented rows 暂 unsupported |
| geometry | typed shapes/layers/tolerance | 对称性、边界和 exact predicate oracle | overflow/degenerate polygon |
| hypergraph | vertices/hyperedges/weights/k/balance | partition completeness/balance/cut recompute | empty/high-degree net |
| quadratic placement | matrix/anchors/bounds | residual、bounds、finite coordinates | singular/ill-conditioned matrix |
| two-pin route | grid/resources/obstacles/endpoints | path connectivity/resource/layer legality | no path、via shortage |
| Steiner | terminals/obstacles/layers | tree connectivity、terminal coverage、length recompute | duplicate/collinear terminals |

## 12. Portfolio 与选择算法

```text
validate one canonical ProblemSpec
  -> select qualified solver variants
  -> allocate initial budget slices
  -> run and stream independently checked incumbents
  -> remove infeasible/duplicate candidates
  -> maintain objective-vector Pareto frontier
  -> reallocate remaining budget by progress + diversity policy
  -> stop on proof, budget, no-improvement, cancellation or enough candidates
  -> return frontier + rejected reasons + per-run evidence
```

进度快不代表最终质量好；budget reallocation policy 必须版本化并在 held-out problem family 上评价 selection regret。多 seed 不是算法多样性；manifest 应标 algorithm family，portfolio policy 可要求至少两个不同 family。

## 13. 失败语义

| 条件 | 状态 | 证据 |
|---|---|---|
| problem schema/unit 错 | `INVALID_INPUT` | field/constraint IDs |
| 超出 manifest domain | `UNSUPPORTED` | violated domain predicate |
| 证明不可行 | `INFEASIBLE` | conflict set/IIS approximation/check trace |
| 仅搜索未找到可行解 | `NO_FEASIBLE_FOUND` | explored budget，不得称 infeasible |
| NaN/发散/奇异 | `NUMERICAL_FAILURE` | residual/history/conditioning |
| timeout/cancel 有 incumbent | `PARTIAL` | incumbent + remaining/gap/resume |
| feasibility checker 推翻候选 | candidate rejected | exact violated constraints |

## 14. 测试与基准协议

| ID | 测试 | 断言 |
|---|---|---|
| SOL-T01 | toy problems 穷举/解析 gold | optimal/bound/gap 正确 |
| SOL-T02 | infeasible 与搜索未找到 | 状态严格区分 |
| SOL-T03 | hard constraint penalty 极小/极大 | 仍不可违反 hard constraint |
| SOL-T04 | timeout/cancel 每个安全点 | 无损坏；合法 incumbent 保留 |
| SOL-T05 | resume vs continuous | 同 seed 在声明容差内一致 |
| SOL-T06 | same seed/order/thread | result/evidence hash 稳定 |
| SOL-T07 | OOM/worker kill/progress consumer stall | 服务可恢复，无孤儿 worker |
| SOL-T08 | adapter vs legacy direct entry | 数值和 termination 等价 |
| SOL-T09 | portfolio duplicate/invalid candidate | 去重且拒绝原因完整 |
| SOL-T10 | random small fuzz + independent checker | 无 escaped infeasible candidate |

性能按问题族、变量/约束规模、稀疏度和可行性分桶，分别报告 adapter overhead、首个可行解时间、best incumbent 时间和最终 gap；只报告总墙钟无法判断 anytime 价值。

## 15. PR 切片与完成定义

```text
SOL-0  ProblemSpec/SolverManifest/Result schema + validator
SOL-1  geometry + Abacus adapters + independent checker
SOL-2  budget/progress/cancel + isolated worker
SOL-3  routing/Steiner/partition adapters
SOL-4  portfolio/Pareto/diversity + benchmark harness
SOL-5  selected kernel resume/checkpoint
SOL-6  local exact template qualification for Honey-generated tools
```

一个 solver capability 只有在 manifest、domain、独立 feasibility checker、失败语义、determinism、budget/cancel 和至少一个真实领域 consumer 全部具备后才可从 D1 晋级；“注册成功并返回一个数”不算 Agent-ready。
