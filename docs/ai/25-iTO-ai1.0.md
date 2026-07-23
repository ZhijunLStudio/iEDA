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

