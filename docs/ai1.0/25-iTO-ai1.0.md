<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 25 · iTO Agent 时序优化实施方案 · ai1.0

> 基线：`25-iTO.md`。iTO 是 Timing Closure Lab 的首个动作提供者；复用 setup/hold/DRV/buffering，实现 diagnose→propose→apply→validate 的事务化分离。

## 1. 目标切片

首版只支持 post-place/post-CTS 标准单元 ECO：resize、VT swap、buffer、driver clone、有限 local move。禁止自动改 SDC、clock period、false path 或 dont_touch。

## 2. API

| API | 说明 |
|---|---|
| `timingopt.diagnose` | path/DRV 的 cell/net/RC/constraint attribution |
| `timingopt.propose` | 多个 `EcoProposal`，不修改设计 |
| `timingopt.screen` | F0/F1 方向、幅度、风险粗筛 |
| `timingopt.apply` | branch 中生成 typed delta |
| `timingopt.validate` | legal→RC→STA→power/congestion |
| `timingopt.run_pass` | 受控组合上述原子 API，返回全 trace |

## 3. EcoProposal

```text
proposal_id / diagnosis_id
actions[] {resize,vt_swap,insert_buffer,clone,move_hint}
preconditions / touched_objects / dirty_cone
predicted_metrics + confidence + fidelity
hard_risks {hold,drv,drc,legal,power}
change_budget / fallback
```

proposal 和 apply 解耦，使 Agent 可组合/排序/拒绝；现有 optimizer 内直接修改路径逐步收编到 DeltaAdapter。

## 4. 事务闭环

```text
begin branch txn
  → apply netlist/placement delta
  → connectivity check
  → local legalize
  → dirty RC
  → dirty-cone setup+hold STA
  → DRV/congestion/power checks
  → full F3 periodic audit
  → accept or rollback
```

任一步失败不得保留半修改。accept 条件是新指标满足 hard gates 且在外部 objective 下优于 baseline；不能仅判断 WNS。

## 5. LLD

```text
src/operation/iTO/agent/
  TimingDiagnoser.{hh,cc}
  EcoCandidateGenerator.{hh,cc}
  ResizeGenerator.{hh,cc}
  VtSwapGenerator.{hh,cc}
  BufferGenerator.{hh,cc}
  EcoDeltaAdapter.{hh,cc}
  EcoValidator.{hh,cc}
  PassController.{hh,cc}
```

`PassController` 调平台原语，不直接持有 iPL/iRT/iSTA 单例。

## 6. 候选策略

- setup：size/VT/buffer/move 多样化，不只贪心最大 cell；
- hold：delay cell/buffer/route detour，严格保护 setup；
- DRV：先 hard clean，再恢复面积功耗；
- 对同一 cell/net 建 lease，避免 iNO/iCTS/iTO 冲突；
- 每轮设 change budget 和 no-improvement window；
- 记录 rejected candidate，进入 failure memory。

## 7. 里程碑

| 阶段 | 内容 | 门禁 |
|---|---|---|
| TO-A0（3 周） | diagnose/proposal schema | path 分量与 iSTA 总量一致 |
| TO-A1（4 周） | resize/VT delta + rollback | 500 actions 零残留 |
| TO-A2（4 周） | buffer + local legal/RC/STA | full/incr ≤1 ps 相关端点 |
| TO-A3（4 周） | candidate portfolio/ranker | held-out regret 和 F3 节省 |
| TO-A4（5 周） | setup/hold/DRV pass controller | 10 case ≥8 减少违例且硬门禁不退化 |
| TO-A5（后续） | route-aware/multi-scenario/power recovery | route/MCMM oracle 对拍 |

## 8. 测试

- dont_touch、clock/reset、multi-output、high fanout、无等价 VT/master；
- hold/setup 交叉退化；
- buffer 命名/连接/合法位置/route failure；
- 连续动作组合与逐动作验证差异；
- Agent 提议改 SDC 必须权限拒绝；
- full audit 推翻增量结果时 branch 自动回收。

**H-TO-A1**：proposal portfolio + F1/F2 筛选比现有单一路径贪心在相同计算预算下有更低 violation magnitude。若未改善，先检查候选多样性和 common STA，不直接上强化学习。

---

## 9. Diagnosis 与 action contract

```text
TimingProblem
  snapshot/intent/scenario/tech refs
  check = setup|hold|slew|cap|fanout
  endpoint/path/net/cell IDs
  slack/limit/violation magnitude + coverage
  attribution {cell, net_rc, clock, constraint, coupling}
  allowed actions/frozen scope/change budget

EcoAction
  kind = resize|vt_swap|insert_buffer|clone_driver|move_hint
  target/preconditions/parameters
  expected touched + dirty domains
  predicted metric vector/uncertainty/model ref
  inverse strategy + validators required
```

`TimingDiagnoser` 的 attribution 分量必须能回加到 common iSTA path delay（在定义容差内），无法归因部分单列 `unattributed`。constraint/clock 定义问题只生成诊断和高权限 IntentPatch 建议，不能伪装成 cell ECO。

## 10. 各 action 的可执行语义

| Action | 前置 | Apply | 主要风险 |
|---|---|---|---|
| resize | equivalent cell family、pins/function 一致 | 替换 master，保持连接 | legal fit、input cap、hold、power |
| VT swap | 同 footprint/function/voltage domain | 替换 VT master | leakage/setup/hold/library coverage |
| insert buffer | net 可编辑、master 合格、候选断点 | split net + reconnect + place window | connectivity、legal、route、hold |
| clone driver | functional/power intent 允许 | clone + load partition | equivalence、fanout、area、route |
| move hint | movable/region/site 允许 | 委托 iPL local move | wire trade-off、congestion、legal |

每个 generator 至少输出 no-op baseline、保守和激进三个候选档；候选 diversity 以 action family/target/parameter 衡量，不能用同一 resize 的多个相邻 size 冒充完整 portfolio。

## 11. Screening 与闭环控制

```text
diagnose top-N unique root causes
  -> generate bounded diverse proposals
  -> reject stale/precondition/scope violations
  -> F0 analytic sensitivity + F1 calibrated ranking
  -> branch apply Top-K
  -> connectivity/local legal/dirty RC/F2 STA
  -> escalate frontier and near-gate to F3 full relevant scenarios
  -> Verification bundle + iEval QoR gate
  -> accept one, continue next round, or rollback/stop
```

`PassController` 的停止条件版本化：hard violations clean、change budget、no-improvement window、oscillation、wall budget、cancel 或没有可行 proposal。连续多 action 必须逐步记录 DecisionRecord；批量验证只能作为性能优化，失败时要二分定位并回滚整个未验证 batch。

## 12. DirtySet 与跨工具顺序

```text
netlist delta
  -> connectivity/formal dirty
  -> placement instances/rows/bins
  -> route nets + coupling neighbors
  -> RC nets/sinks
  -> STA forward/backward cones + scenarios
  -> power/activity/IR as policy requires
```

iTO 不自行缩小 iDB dirty set。iPL/iRT/iRCX/iSTA 各自可扩大；实际 consumed scope 回写 trace。任何一步扩大到 policy 上限外，返回 `SCOPE_EXPANSION_REQUIRED`，由 Runtime 决定重跑，不静默转 full-chip。

## 13. LLD 与失败状态

| 组件 | 关键输出 |
|---|---|
| `TimingDiagnoser` | typed causes/path evidence/problem signature |
| action generators | immutable proposals + applicability |
| `EcoDeltaAdapter` | stable IDs、before/after/inverse/actual touched |
| `EcoValidator` | connectivity/legal/RC/setup/hold/DRV/power/congestion refs |
| `PassController` | round state、budget、incumbent、stop/recovery trace |

状态严格区分 `NO_APPLICABLE_ACTION`、`INFEASIBLE_PHYSICAL`、`PARTIAL_VALIDATION`、`VALIDATION_FAIL`、`STALE_CONTEXT`、`TIMEOUT_WITH_INCUMBENT` 和 `FAILED_ROLLBACK`。一次 ECO 降低 setup violation 但新增 hold/DRV 时是 `VALIDATION_FAIL`，不是 partial success。

## 14. CI 与 PR

`TO-T01` attribution 守恒，`TO-T02` master family/pin mapping，`TO-T03` 每类 delta/inverse，`TO-T04` buffer split connectivity，`TO-T05` local legal infeasible，`TO-T06` dirty/full RC/STA，`TO-T07` setup/hold 交叉，`TO-T08` scope expansion，`TO-T09` multi-action rollback，`TO-T10` stop/oscillation/cancel，`TO-T11` held-out regret/F3 节省，`TO-T12` 约束修改权限拒绝。

PR：`TO-0 diagnosis/problem schema` -> `TO-1 resize/VT proposal+delta` -> `TO-2 buffer/clone+connectivity` -> `TO-3 local legal/RC/common STA` -> `TO-4 portfolio/iEval gate` -> `TO-5 pass controller/cancel/recovery` -> `TO-6 route-aware/power/MCMM`。

完成定义：在固定 Timing Lab benchmark 上，所有候选均可追踪为 proposal->delta->metrics->certificate->decision；accepted action 的 F3 setup/hold/DRV gate 全通过，rejected action 有机器可读原因。
