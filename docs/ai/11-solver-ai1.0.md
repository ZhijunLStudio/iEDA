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

