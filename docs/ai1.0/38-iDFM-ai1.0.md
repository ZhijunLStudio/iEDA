<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 38 · iDFM Agent 可制造性与良率风险实施方案 · ai1.0

> 当前成熟度：`D0/DRAFT`。iDRC/iRT 可能包含 antenna、density、via 等局部资产，但当前未见独立 DFM/yield 产品面和 foundry-qualified model。
>
> 边界：iDRC 判断声明规则是否违反；iDFM 评估 hard DRC 之外的制造风险并给 proposal。DFM score 不能替代 foundry signoff。

## 1. 首批能力

- rule/coverage audit：antenna、density、via redundancy、line-end/spacing pattern；
- redundant via opportunity 与成功落点；
- antenna risk inspect/proposal；
- window density inspect/fill impact proposal（fill apply 后置）；
- hotspot pattern 检索和 external lithography/CMP adapter；
- DFM proposal 对 timing/RC/congestion/DRC 的副作用评估；
- risk map 与 manufacturing certificate 的证据输入。

首版不承诺真实 yield 百分比、OPC/RET、自研 lithography signoff 或 foundry deck 替代。

## 2. API

```text
dfm.coverage(snapshot, tech_context, rule_family)
dfm.inspect_region(region, layers, fidelity)
dfm.antenna_risk(net_or_scope)
dfm.via_redundancy(scope)
dfm.density_windows(scope, window_policy)
dfm.pattern_hotspots(scope, model_ref)
dfm.propose_mitigation(observations, allowed_actions)
dfm.compare(before, after, scope)
```

所有 mitigation 默认为 proposal-only，由 iRT/iDRC/iECO 或受控 fill 工具应用。

## 3. Schema

```text
DfmObservation
  id, family, rule/model namespace
  geometry/object/region/layer refs
  severity/risk interval
  threshold/limit source
  features/model/domain/OOD
  coverage + evidence

DfmProposal
  action = redundant_via|diode|jumper|route_change|fill_adjust|geometry_adjust
  typed target/parameters/scope
  predicted risk reduction
  timing/RC/congestion/DRC cost interval
  required validators
```

`risk` 与 `violation` 分开：只有 TechContext 声明的 hard rule checker 才能产生 violation；learned hotspot 产生 calibrated risk/OOD。

## 4. 分层方法

| Fidelity | 方法 |
|---|---|
| F0 | 几何/拓扑 heuristic、机会点计数 |
| F1 | deterministic antenna/density/via rule subset |
| F2 | pattern library + calibrated hotspot model/CMP proxy |
| F3 | foundry-qualified rule subset、detailed fill/RC feedback |
| F4 | external foundry litho/CMP/yield/signoff protocol |

learned model 由 `45` 注册和 OOD 路由；pattern/training 数据由 `47` 管理。模型高置信也不能生成 hard clean certificate。

## 5. 关键算法

### 5.1 Redundant via

从 route/via graph 找单 cut、高电流或关键网络，枚举可放置 cut array，先做几何/局部 DRC，再评估 resistance、EM、拥塞和邻近影响。不可放置不是工具失败，应返回机会覆盖和 infeasible reason。

### 5.2 Density

以可配置 window/step/layer 计算局部 density，报告边界处理和被排除 purpose。fill proposal 要保留 timing critical/analog/keepout/PDN 区域，且 fill 后必须重提 RC/SI/DRC。

### 5.3 Antenna

按 fabrication sequence、gate/diffusion area 和 layer/via cut 累积风险。缺工艺序列/ratio 规则时只能给结构 proxy，不能判 pass/fail。

## 6. LLD 与源码落点

```text
src/operation/iDFM/
  api/DfmService.{hh,cc}
  data/{DfmObservation,DfmProposal,DfmCoverage}.hh
  adapters/{IdrcRule,IrtGeometry,TechRule,ExternalHotspot}.cc
  analysis/{Antenna,WindowDensity,ViaRedundancy,PatternHotspot}.cc
  proposal/{Via,Antenna,Density,Route}Mitigator.cc
  agent/DfmCapabilityAdapter.cc
```

iDRC 保留 hard rule kernel 和 violation ownership。相同几何查询应 composition iDRC/iRT spatial index，不重建第三份 layout database。

## 7. 闭环

```text
DFM inspect → proposals → branch apply by owner
  → full affected hard DRC
  → route connectivity + RC/SI/STA
  → EM/density/antenna/hotspot recheck
  → frozen scope + coverage certificate
  → Pareto {risk, timing, power, area, route cost}
```

fill/route/via proposal 不能只验证目标风险；新增 hard DRC、timing/hold、coupling 或 EM 违例直接拒绝。

## 8. 失败语义

- missing foundry rule/model：UNSUPPORTED/PROXY_ONLY；
- rule subset 未覆盖：PARTIAL，不能 `dfm.clean`；
- learned model OOD：UNKNOWN/升级 F4；
- no legal mitigation：INFEASIBLE + explored space；
- external hotspot 与 internal risk 冲突：CALIBRATION_CONFLICT；
- density/antenna source sequence 不完整：INVALID_CONTEXT。

## 9. 里程碑

| 阶段 | 交付 | 退出门禁 |
|---|---|---|
| DFM-A0（3 周） | observation/proposal/coverage schema | risk/violation 不混用 |
| DFM-A1（4 周） | via opportunity + antenna/density audit | 构造 pattern 与 rule coverage 正确 |
| DFM-A2（5 周） | deterministic mitigation proposals | hard DRC/RC/STA 副作用闭环 |
| DFM-A3（5 周） | pattern/model router | held-out family/PDK/OOD 报告 |
| DFM-A4（5 周） | external litho/CMP adapter | protocol/版本/coverage 可重放 |
| DFM-A5（后续） | fill/DFM optimization | foundry owner qualification 后写能力 |

## 10. 测试与可杀假说

- via 单/多 cut、密度窗口边界、antenna fabrication sequence 的手工 gold；
- layout 平移/镜像、网格起点变化、单位缩放 metamorphic；
- rule/model version drift、missing layer purpose、encrypted coverage；
- mitigation mutation：删掉 DRC/RC feedback 时测试必须失败；
- held-out hotspot false-negative 和 selection regret。

**H-DFM-A1**：proposal-only DFM 能在不增加 hard violation 下减少 external hotspot/单 cut 风险。若不能，保留 analyzer 和数据采集，不开放自动 apply。

## 11. 不做

- 不把 risk score 等价为 yield；
- 不把 iDRC 未支持规则等价为 clean；
- 不让 learned model签发 hard rule PASS；
- 不自动修改 foundry deck；
- 不在 fill 后跳过 RC/SI/timing；
- 不在首版承诺 OPC/RET 或 foundry DFM signoff。

## 12. Pattern/机会 ID、失效与 CI

DFM observation 使用 `deck/model hash + canonical shapes + window/pattern coordinates` 形成 stable ID；聚合 hotspot 不改变 raw opportunity/violation 数。Route/fill/via/metal shape、density window 或 foundry model 变化失效相交观察；global density/CMP model 变化默认全局失效。

首版 metric 分开 redundant-via opportunity/insertable/success、antenna ratio/margin、window density min/max、pattern risk class 和 coverage。未知 yield model 不输出 yield 百分比；risk level 只能引用合格 model。

CI：`DFM-T01` redundant via 几何/不可插原因，`DFM-T02` antenna ratio 边界，`DFM-T03` density sliding windows，`DFM-T04` stable ID/order，`DFM-T05` proposal secondary DRC/RC，`DFM-T06` global/local invalidation，`DFM-T07` missing foundry model，`DFM-T08` external parser drift，`DFM-T09` incremental/full，`DFM-T10` held-out opportunity precision/recall。

PR：`DFM-0 coverage/schema` -> `DFM-1 via opportunity` -> `DFM-2 antenna/density audit` -> `DFM-3 proposal+secondary checks` -> `DFM-4 external pattern adapter` -> `DFM-5 qualification`。
