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

---

## 8. Agent 请求与观测模型

```text
PlacementRequest
  snapshot/intent/scenario/tech/policy refs
  stage = macro|global|legal|detail|eco
  scope {instances, region, frozen complement}
  allowed_actions {move,swap,reorder,resize_hint,macro_seed}
  hard {rows,sites,regions,blockages,halo,orientation,dont_touch}
  objectives {timing,wirelength,density,congestion,power,disruption}
  fidelity/budget/seed

PlacementObservation
  instance/row/bin stable IDs
  legal space intervals + blockers
  density/pin/net/congestion maps with grid refs
  critical cells/nets and timing scenario refs
  movable/frozen/unsupported counts
  source/fidelity/coverage
```

`place.inspect` 必须支持 selector 和 pagination/artifact ref，不能把全设计裸指针或巨型文本交给 Agent。所有 map 绑定 grid origin/step/dimensions 和 snapshot；不同 grid 的值不能直接 diff。

## 9. 候选生成和动作语义

| Candidate | 生成 | Apply 后最小验证 |
|---|---|---|
| macro seed | connectivity clustering、edge/region/halo、多 seed | macro overlap/halo/channel + F2 GP |
| global place | Nesterov 参数/initial seed portfolio | density/HPWL、legalizability、early timing/congestion |
| local move | critical cell + legal intervals + net bbox sensitivity | local legal、frozen、dirty timing/WL |
| swap/reorder | row window 内 pin/net cost 枚举 | site/orient、overlap、netlist 不变 |
| resize hint | 由 iTO proposal 给 master，iPL 只处理物理可行性 | cell fit/legal、dirty bins/nets |

F0 gradient 或 learned ranker 只产生排序证据。`PlacementDelta` 的 `from` 必须与 branch head 一致；实际合法化若改变额外 cell，应把它们加入 `actual_touched`，超出允许 halo 则拒绝，不能静默扩散。

## 10. 局部合法化与 dirty propagation

```text
dirty instances + requested target
  -> expand by row/window/height/site compatibility
  -> construct free intervals after fixed/blockage/frozen occupancy
  -> solve displacement/ordering with hard legality
  -> independent overlap/site/orient/region checker
  -> actual touched instances
  -> dirty nets -> RC/timing cone; dirty bins -> density/congestion
```

找不到局部可行解时返回 `INFEASIBLE_LOCAL` 和冲突 rows/objects；由 Runtime 选择扩大 halo 或换 proposal。局部 solver 不得自动解冻对象。full legalizer 只作为显式 fallback，执行后 scope 变为 full 并重新签发 frozen certificate。

## 11. Anytime 与进度契约

```text
PlacementProgress
  iteration/epoch, status, incumbent_ref
  hpwl/density_overflow/congestion_proxy/timing_proxy
  gradient_norm/step/legal_state
  elapsed/budget/termination_reason
```

GP 的 incumbent 可未合法，但必须标 `UNLEGALIZED`；取消时优先返回最近合法 incumbent，否则返回 partial candidate 且不可提交。resume token 绑定 netlist/floorplan/constraints、solver params、seed 和 thread config。相同 token 在 head 改变后 stale。

## 12. 文件级实施拆分

| 类 | 现有后端 | 新职责 |
|---|---|---|
| `PlacementInspector` | PLAPI/iDB/evaluation | stable IDs、scope、map provenance |
| `MacroCandidateGenerator` | macro placer assets | multi-seed proposal，不 commit |
| `GlobalCandidateRunner` | Nesterov | budget/progress/incumbent adapter |
| `LocalMoveGenerator` | timing/net/bin views | move/swap/reorder proposal set |
| `IncrementalLegalizerAdapter` | solver/legalization + iPL legalizer | halo、actual touched、infeasible evidence |
| `PlacementDeltaAdapter` | PLAPI mutation path | typed before/after/inverse/dirty |
| `PlacementValidator` | iPL checker + Verification Hub | legal/frozen/coverage 分项结果 |

旧 evaluation timing 只通过 `legacy_timing_adapter` 暂存为 F0/F1；F2/F3 统一调用 iSTA service。任何替换先双跑并按 action/scenario/path 分桶。

## 13. 测试与 PR

`PL-T01` fixed/dont_touch/region，`PL-T02` multi-height/row fragment，`PL-T03` macro halo/channel，`PL-T04` local infeasible 与 scope expansion，`PL-T05` 500 delta apply/rollback，`PL-T06` actual touched/frozen，`PL-T07` incremental/full legal/density/WL，`PL-T08` dirty STA/full STA，`PL-T09` cancel/resume/incumbent，`PL-T10` seed/thread determinism，`PL-T11` F0/F1 held-out regret，`PL-T12` full GP 与 branch portfolio 的成本/QoR。

```text
PL-0 inspect/grid/object schema
 -> PL-1 PlacementDelta + frozen/rollback
 -> PL-2 local move + independent legal checker
 -> PL-3 dirty metrics/common STA
 -> PL-4 macro/global portfolio + progress/cancel
 -> PL-5 Timing ECO 与 floorplan e2e
```

完成定义：Agent 能在固定 post-place snapshot 上提出至少三类局部候选，隔离 apply、局部合法化、F2/F3 评估、拒绝越域动作并回滚；仅包装 `run_place` 不算完成。
