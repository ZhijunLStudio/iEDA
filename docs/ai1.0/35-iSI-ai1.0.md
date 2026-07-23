<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 35 · iSI Agent 信号完整性分析与闭环实施方案 · ai1.0

> 当前成熟度：`D0/D1 待审计`。仓库可见 iSTA `CrossTalkDelayCalc`/`StaCrossTalkPropagation` 代码，但完整耦合提取、噪声模型、时窗迭代、coverage 和 route closure 未验证。
>
> 复用 iRCX coupling、iSTA timing windows、iRT route action；iSI 不直接改线。

## 1. 首批产品面

1. coupling coverage：哪些 net/layer/pattern 有耦合数据；
2. victim/aggressor inspect：耦合强度、时窗、方向、dominance；
3. crosstalk delay update：setup/hold 的 delta 与不确定性；
4. noise screening：receiver noise margin 的 conservative check；
5. mitigation proposal：spacing、layer change、shield、slew/driver、reroute scope；
6. SI validation：候选 route delta 的 timing/noise/coverage 证书输入。

首版不宣称 signoff glitch propagation、full waveform transistor noise 或 package full-wave SI。

## 2. API

```text
si.coverage(snapshot, scenario, scope)
si.inspect_net(net_id, scenario)
si.find_victims(region_or_path, thresholds)
si.find_aggressors(victim_id, timing_window_policy)
si.update_timing(scope, scenarios, fidelity)
si.check_noise(scope, scenarios, fidelity)
si.propose_mitigation(victim_set, allowed_actions)
si.compare(before, after, scope)
```

`propose_mitigation` 返回 Route/Eco Proposal；apply 由 iRT/iTO 在 branch 完成。

## 3. Schema

```text
CouplingEdge
  victim/aggressor segment IDs
  layer/geometry/overlap/spacing
  coupling_cap + model/source/coverage

SiObservation
  victim, aggressor_set, scenario
  alignment/window probability or bound
  delay_delta_rise/fall
  peak_noise/width/margin
  baseline_slew/load
  uncertainty + evidence

SiProposal
  action class + candidate geometry/electrical change
  touched/frozen scope
  expected timing/noise/congestion/DRC impact
  required validators
```

## 4. 分层算法

```text
F0: geometric coupling potential + criticality screen
F1: coupling cap ratio + static timing-window overlap
F2: effective capacitance/crosstalk delay + iterative windows
F3: distributed RC waveform/noise propagation + MCMM
F4: qualified signoff SI oracle
```

核心迭代：iRCX 提供 coupling graph → iSTA 提供 victim/aggressor arrival windows/slew → iSI 计算 delta/noise → 更新 timing windows，直到 endpoint/slack/coupling delta 在容差内或达到迭代上限。未收敛返回 PARTIAL/UNKNOWN，不能使用最后一次结果冒充稳定解。

## 5. 筛选与保守性

- aggressor pruning 必须报告被剪枝 coupling 总量上界；
- timing-window 无 overlap 可筛掉，但 OCV/jitter/unknown phase 要扩大窗口；
- unknown switching correlation 使用 policy 指定 worst-case/bounded 模型；
- coupling extraction 缺邻线/层/过孔模型时 coverage 降级；
- clock/reset/high-fanout nets 使用独立阈值，不沿用普通 data net。

## 6. LLD 与源码落点

```text
src/operation/iSI/
  api/SiService.{hh,cc}
  data/{CouplingGraph,TimingWindow,SiObservation}.hh
  adapter/{IrcxCouplingAdapter,IstaWindowAdapter}.cc
  analysis/{AggressorFilter,CrosstalkDelay,NoiseAnalyzer}.cc
  iteration/SiTimingFixedPoint.cc
  proposal/MitigationGenerator.cc
  agent/SiCapabilityAdapter.cc
```

第一阶段先审计/收编 iSTA 现有 crosstalk 类，以 adapter 暴露结构化结果；禁止复制后形成第四套时序语义。最终 setup/hold 基准仍由 common iSTA engine 提供。

## 7. 闭环和证书

```text
inspect victim → generate diverse proposals
  → iRT apply route delta in branch
  → iDRC + iRCX coupling update
  → iSI fixed-point + iSTA all affected scenarios
  → frozen/congestion/noise/setup/hold certificates
  → Pareto select
```

shield proposal 还必须验证 PG connectivity/resource；driver/slew proposal 必须经过 iTO/netlist/formal policy。

## 8. 失败语义

| 条件 | 结果 |
|---|---|
| 无 coupling 数据 | UNSUPPORTED/UNKNOWN，不得报告 zero noise |
| 迭代不收敛 | PARTIAL + residual/history |
| aggressor 数超预算 | PARTIAL + pruned bound/resume |
| scenario 缺时钟关系 | UNKNOWN + conservative assumption |
| mitigation 无合法 route | INFEASIBLE proposal |
| signoff/iSI 方向冲突 | calibration failure，禁自动提交 |

## 9. 里程碑

| 阶段 | 交付 | 退出门禁 |
|---|---|---|
| SI-A0（3 周） | 现有 crosstalk kernel/coverage 审计 | 代码路径、输入、fallback、单位可复现 |
| SI-A1（4 周） | coupling graph/net inspect | 解析 pattern 与 iRCX/小例守恒 |
| SI-A2（5 周） | timing-window delay F1/F2 | victim ranking Recall@K/oracle 通过 |
| SI-A3（5 周） | noise analyzer/fixed-point | 收敛/不收敛语义正确 |
| SI-A4（5 周） | iRT mitigation portfolio | held-out cases 降 SI 且无 DRC/timing 新违例 |
| SI-A5（后续） | F3/F4 qualification | 2 PDK、多层/过孔/clock cases |

## 10. 测试与可杀假说

- 解析双线/三线 RC、小电路 SPICE/field/signoff gold；
- victim/aggressor 交换、整体平移、单位缩放、无 overlap window；
- 同向/反向 switching、rise/fall、clock/data、多 aggressor cancellation/worst-case；
- incremental/full coupling 和 timing 定期对拍；
- mitigation 后 frozen route shapes 必须不变。

**H-SI-A1**：F1/F2 screening 可在低漏报下把 F4 victim 数减少至少 5 倍。若 critical victim Recall@K 不达门槛，缩小适用域并使用 conservative full escalation，不调松 gate。

## 11. 不做

- 不把 coupling capacitance 存在等价为 timing/noise violation；
- 不把缺 coupling 模型等价为 0；
- 不让 iSI 自行修改 route；
- 不为 SI 建另一套独立 STA graph；
- 不在首版承诺 package/channel full-wave 或模拟 IO signoff。

## 12. 实施依赖、失效与 metric 定义

`SiResultKey` 必含 route generation、RC coupling model、timing window/scenario、switching correlation policy、tool/model hash。RouteShape/Via、driver/master、clock/constraint、RC model 任一变化都会失效相关 victim/aggressor observation；只改非耦合远端 net 只有在 spatial dependency proof 下才可复用。

首批 metric 固定为 `si.coupling_cap_ratio`、`si.delay_delta.setup/hold`、`si.noise.peak/width/margin`、`si.victim_count` 和 coverage，不合成一个 SI score。Noise receiver threshold 缺 library/source 时返回 `UNKNOWN_LIMIT`。

## 13. CI 编号与 PR 切片

`SI-T01` coupling pair 守恒，`SI-T02` window overlap/OCV 扩张，`SI-T03` rise/fall 同向反向，`SI-T04` 多 aggressor pruning bound，`SI-T05` iteration convergence/non-convergence，`SI-T06` route delta invalidation，`SI-T07` incremental/full，`SI-T08` no coupling data，`SI-T09` mitigation frozen/DRC，`SI-T10` F1/F4 victim Recall@K。

PR：`SI-0 kernel/coverage audit` -> `SI-1 coupling graph/inspect` -> `SI-2 window/delay adapter` -> `SI-3 noise/fixed-point` -> `SI-4 iRT proposals/validation` -> `SI-5 F4 qualification`。
