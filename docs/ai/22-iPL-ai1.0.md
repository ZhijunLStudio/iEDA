<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 22 · iPL Agent 布局实施方案 · ai1.0

> 基线：`22-iPL.md`。复用宏/全局/合法化/详细布局资产与 evaluation 拥塞反馈；Agent 化重点是多候选、局部动作、统一时序和可验证增量。

## 1. 工具分面

| 分面 | Agent 用途 |
|---|---|
| observe | bin density、overflow、critical cell、movability、legal space |
| propose | macro seed、GP 参数、局部 move/swap/reorder 候选 |
| act | branch 中应用 instance move |
| repair | 增量 legalize/detail refine |
| validate | legal、frozen scope、timing/congestion/power |

## 2. API

```text
place.inspect(snapshot, region)
place.propose_macro(snapshot, constraints, budget)
place.propose_global(snapshot, seeds, objectives)
place.propose_local(snapshot, instances, move_budget)
place.apply_delta(branch, PlacementDelta)
place.legalize_local(branch, dirty_instances, halo)
place.score(snapshot, fidelity)
```

整阶段 `run_place` 保留为 legacy workflow，不是 Agent 唯一入口。

## 3. PlacementDelta

```text
moves: {inst_id, from, to, orient}
scope: region + movable set
frozen_object_hash
estimated: hpwl/density/timing
dirty: nets + bins + timing cone
inverse: before coordinates
```

硬不变量：固定实例不动、site/row/orient 合法、macro halo/channel、scope 外 hash 不变。

## 4. LLD

```text
src/operation/iPL/agent/
  PlacementInspector.{hh,cc}
  MacroCandidateGenerator.{hh,cc}
  GlobalCandidateRunner.{hh,cc}
  LocalMoveGenerator.{hh,cc}
  IncrementalLegalizerAdapter.{hh,cc}
  PlacementDeltaAdapter.{hh,cc}
  PlacementValidator.{hh,cc}
```

时序统一走 iSTA Tool Contract。`evaluation::TimingAPI` 仅在经过口径对拍后作为 F0/F1 view，不能独立定义 slack 真值。

## 5. Fidelity 与 anytime

| 档 | 实现 |
|---|---|
| F0 | HPWL/RUDY/density/analytic gradients |
| F1 | ONNX wirelength/congestion/timing ranker |
| F2 | 限迭代 Nesterov + local legalize + early STA |
| F3 | full GP/LG/DP + iSTA/iRT/evaluation |

Nesterov/宏搜索每 epoch 输出 incumbent、overflow、HPWL、timing proxy、gradient norm；cancel 返回当前合法或标记未合法候选。

## 6. 开发路径

| 阶段 | 内容 | 门禁 |
|---|---|---|
| PL-A0（3 周） | inspect/delta/frozen validator | 500 local moves 可回滚 |
| PL-A1（4 周） | local legalize + dirty bins/nets | 与 full legalize 一致，scope 外不变 |
| PL-A2（4 周） | common timing adapter | proxy/F3 误差和适用域可见 |
| PL-A3（5 周） | local/macro/global portfolio | Pareto 候选与 selection regret |
| PL-A4（4 周） | anytime/cancel/resume | incumbent 与连续运行容差一致 |

## 7. 测试

- fixed/dont_touch、macro、multi-height、blockage、窄空位、无可行位置；
- local legalize 失败原子回滚；
- 不同线程/seed 确定性策略；
- F0/F1 只在声明 domain 使用；
- post-place full STA/GR 重排候选时记录 regret。

**H-PL-A1**：Agent 局部 move + 增量验证比重跑 full GP 更高效地修复少量关键路径。若 dirty region 经常扩散为全芯片，应限制在 late placement/ECO，早期仍使用全局 portfolio。

