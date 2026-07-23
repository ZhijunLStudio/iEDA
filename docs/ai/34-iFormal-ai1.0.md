<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 34 · iFormal Agent 形式等价与证明服务实施方案 · ai1.0

> 当前成熟度：`D0/DRAFT`。当前仓库没有独立 iFormal operation；`47` 仅规划 formal/LEC oracle。首版采用 external adapter，不能宣称已有自研 formal kernel。  
> 首要 consumer：buffer/netlist ECO、未来 iLO/iTM rewrite 和 functional ECO 的提交门禁。

## 1. 产品切片与边界

首批只做 gate-level combinational equivalence checking（CEC）：reference/revised netlist + library function mapping + compare-point policy。clock-gating、scan、memory/blackbox、X/Z、sequential equivalence 和 RTL property checking 分阶段支持。

iFormal 负责问题构造、映射、证明状态、counterexample 和 coverage；外部执行经 `57`；oracle/数据归 `47`；certificate 由 `49` 签发。随机仿真或结构 hash 只能筛选，不能签发数学等价 PASS。

## 2. API

| API | 输出 |
|---|---|
| `formal.prepare` | FormalProblem + compare-point/mapping coverage |
| `formal.check_equivalence` | PROVED/DISPROVED/UNKNOWN/PARTIAL |
| `formal.check_scope` | ECO cone 的局部 proof + boundary assumptions |
| `formal.explain_counterexample` | first divergence、input/clock trace、mapped objects |
| `formal.compare_engines` | 多 backend 结果/假设差异 |
| `formal.propose_partition` | cone/partition proposal，不修改 netlist |
| `formal.resume` | checkpoint/budget 续证 |

## 3. Schema

```text
FormalProblem
  reference_artifact + revised_artifact
  intent_ref + tech_context_ref
  top/module/compare_points
  clock_reset_scan policy
  blackbox/memory/X semantics
  correspondence map
  assumptions + proof scope

FormalResult
  status = PROVED | DISPROVED | UNKNOWN | PARTIAL
  proved/failed/unmapped/unsupported points
  engine/version/seed/budget
  proof/counterexample/log artifacts
  assumptions + coverage + diagnostics
```

`PROVED` 的 claim 仅覆盖列出的 compare points、assumptions 和 semantics；有 unmapped/unsupported point 时不能升级为 full equivalence。

## 4. Fidelity 与算法路径

| Fidelity | 方法 | 可签发证明 |
|---|---|---:|
| F0 | 结构/功能 hash、cone diff、常量传播 sanity | 否 |
| F1 | directed/random simulation、small truth table | 否；只能发现反例 |
| F2 | SAT sweeping + miter，小/中等组合 cone | 是，限已证明 scope |
| F3 | partitioned/hierarchical CEC、memory/clock-gate handling | 是，按 coverage |
| F4 | 合格 external commercial/open-source formal protocol | 是，受 protocol 限定 |

自研路径优先 composition 已验证 SAT/AIG 库，不从零手写 SAT solver。首版价值在可靠 adapter/mapping/证据，不在求解器品牌。

## 5. LLD

```text
src/operation/iFormal/
  api/FormalService.{hh,cc}
  ir/{FormalProblem,FormalResult,Counterexample}.hh
  frontend/{NetlistNormalizer,LibraryFunctionMapper}.cc
  mapping/{ComparePointMapper,ConePartitioner}.cc
  engines/{Structural,Simulation,ExternalCec}Engine.cc
  engines/SatCecEngine.cc                  # F2 后续
  explain/DivergenceTracer.cc
  agent/FormalCapabilityAdapter.cc
```

canonical netlist IR 可与 `33 LogicIR` composition，但 ownership 要冻结：iFormal 不成为第二个 synthesis IR writer。

## 6. 局部 ECO 证明

```text
TypedDelta → changed logical cone
  → identify cut inputs/outputs and state elements
  → prove outside cone structurally unchanged
  → build local miter under explicit boundary assumptions
  → prove all affected compare points
  → periodically run full equivalence oracle
```

局部 proof 若依赖未证明 boundary assumption，只能返回 conditional/partial certificate。insert buffer 的物理位置不影响逻辑，但 reconnect/clone/logic rewrite 必须重新证明。

## 7. 失败语义

| 情况 | 结果 |
|---|---|
| 找到可重放反例 | DISPROVED |
| timeout/OOM、无反例 | UNKNOWN，不得写 PROVED |
| compare point 未映射 | PARTIAL/UNKNOWN |
| unsupported memory/X/blackbox | PARTIAL，列出对象 |
| reference 或 revised parse 失败 | FAILED_INPUT |
| backend 间一方 PROVED 一方 DISPROVED | PROTOCOL_CONFLICT，停止提交 |

## 8. 验证与集成门禁

- 每个 counterexample 在独立 simulator/engine 重放；
- known-equivalent/known-non-equivalent small circuits + mutation suite；
- netlist rename/reorder/commutative rewrite metamorphic；
- formal result 绑定 reference/revised/intent/tech/tool hash；
- iECO/iLO 提交 policy 只接受 `49` 发布的 current certificate；
- blackbox、unmatched point 和 assumption 数量进入看板。

## 9. 里程碑

| 阶段 | 交付 | 退出门禁 |
|---|---|---|
| FORM-A0（2 周） | problem/result/mapping schema | unknown/partial 不会伪装 pass |
| FORM-A1（3 周） | external CEC adapter | 100 个等价/不等价小例正确分类 |
| FORM-A2（4 周） | ECO cone/mapping/counterexample | buffer/resize/clone mutation 可定位 |
| FORM-A3（5 周） | SAT CEC 或第二 backend | differential 冲突可诊断 |
| FORM-A4（5 周） | hierarchical/partition/resume | timeout 保留 proved partitions |
| FORM-A5（后续） | sequential/property/formal ECO | 独立立项，不阻塞 CEC 产品化 |

## 10. 可杀假说与不做

**H-FORM-A1**：adapter-first 足以覆盖 Timing Lab 首批 netlist ECO 的功能门禁。若 mapping/unsupported 使 coverage 低于 95%，先缩小允许 action/domain，不以仿真替代证明。

- 不把仿真未发现差异写成等价；
- 不把 timeout 写成 pass；
- 不自动添加 assumptions 使 proof 变容易；
- 不忽略 blackbox/memory/X 语义；
- 不在首版承诺 RTL-to-gate sequential equivalence 或完整 property verification。

