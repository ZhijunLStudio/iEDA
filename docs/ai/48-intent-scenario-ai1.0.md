<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 48 · Design Intent 与 Scenario 服务实施方案 · ai1.0

> 当前成熟度：`D0/DRAFT`。仓库已有 iSTA SDC 等解析资产，但未发现统一 Intent/Scenario 服务和 UPF 独立能力；本方案不能被解读为现有功能。  
> 职责：为所有 Agent 工具提供不可变、可审计、可审批的设计意图与场景真值；不负责 STA/power 求解，不允许普通优化流修改约束。

## 1. 产品边界

服务统一表示：clock/generated clock、IO delay、path exception、case analysis、operating condition、RC corner、mode、power domain、dont-touch/dont-use、目标预算和签核场景集合。

它回答三个问题：当前 intent 是否完整；某个工具调用适用哪些 scenario；拟议的 IntentPatch 会改变哪些分析语义。它不回答 WNS/功耗数值，这些分别归 iSTA/iPA/IR。

首版只保证 SDC normalized IR 和 MMMC 场景 manifest。UPF/CPF、复杂 hierarchical intent 和自动 constraint repair 必须在 parser/oracle 对拍后逐项晋级。

## 2. API

| API | 权限 | 结果 |
|---|---:|---|
| `intent.import` | R4 | normalized IntentRef + parser coverage |
| `intent.inspect` | R0 | clocks/exceptions/domains/protection/来源 |
| `intent.audit` | R1 | unconstrained、冲突、过宽 exception、缺失项 |
| `intent.diff` | R0 | 语义 diff，不是文本 diff |
| `intent.propose_patch` | R1 | proposal-only IntentPatch + affected scope |
| `intent.approve_patch` | R4 | 新 IntentRef + approval record |
| `scenario.list/query` | R0 | ScenarioSetRef 和条件切片 |
| `scenario.coverage` | R1 | 各分析器支持/跳过/未知场景 |
| `scenario.dominance` | R1 | 决策用支配关系 + 被省略风险 |

`scenario.dominance` 只能减少探索计算，不能从最终 validation policy 删除签核场景。

## 3. 核心 Schema

```text
IntentSnapshot
  intent_ref = hash(normalized_ir + source_artifacts + parser + approvals)
  clocks, io_constraints, exceptions, case_analysis
  physical_constraints, protected_objects
  power_intent, optimization_budgets
  source_map, diagnostics, coverage

Scenario
  id, mode, process, voltage, temperature
  rc_corner, library_sets, constraint_view, activity_ref
  analysis_types, signoff_required

IntentPatch
  base_intent_ref, typed_operations
  justification, affected_objects/scenarios/metrics
  proposer, required_approvals, evidence_refs
```

normalized IR 中每个对象都必须保留 source file/line 和解析器版本；不能用扁平化后无法回指来源的字符串集合。

## 4. 审计规则

首批确定性规则：

1. sequential endpoints 是否有有效 launch/capture clock；
2. input/output port 是否有 delay 或显式豁免；
3. generated clock master/source/ratio 是否闭合；
4. false/multicycle/min-max exception 是否命中 0、过多或冲突对象；
5. clock group、case analysis 与 mode 是否矛盾；
6. scenario 的 library/RC/voltage/temperature 单位与 Technology Context 是否匹配；
7. dont-touch/dont-use/power-domain 边界是否能映射稳定 ObjectId；
8. 同一对象不同源约束的 precedence 是否显式。

输出是 `ERROR/WARNING/UNKNOWN` + evidence。启发式“疑似过宽 false path”不能直接判错，只能要求审批或 formal/STA 反证。

## 5. LLD 与源码落点

```text
src/intent/
  api/IntentService.{hh,cc}
  ir/{IntentSnapshot,Clock,Exception,PowerDomain,Scenario}.hh
  parser/SdcAdapter.{hh,cc}
  parser/UpfAdapter.{hh,cc}              # D0，占位前不注册 capability
  audit/{Coverage,Conflict,Exception,Domain}Auditor.{hh,cc}
  scenario/{ScenarioCatalog,DominanceAnalyzer}.cc
  approval/{IntentPatch,ApprovalLedger}.cc
```

复用 iSTA 已有 SDC parser/对象语义，通过 adapter 转换；禁止再造第二个 Tcl/SDC 解释器。iDB 只保存 `IntentRef`，不吸收 intent 业务逻辑。

## 6. 状态与权限

```text
IMPORTED → AUDITED → APPROVED → ACTIVE → SUPERSEDED
                         └────→ REJECTED
```

- 普通 experiment 固定 IntentRef，整个分支不可变；
- IntentPatch 与 DesignDelta 使用不同命名空间、权限和 commit 流；
- patch 获批后创建新 baseline，禁止与旧 intent 的 QoR 直接计算改善；
- parser warning、unresolved object、unsupported command 都进入 coverage；
- source artifact hash 或 parser version 变化时，旧 audit certificate 失效。

## 7. 与工具的契约

| 消费者 | 必需输入 | 返回义务 |
|---|---|---|
| iSTA/iTO/iCTS | clocks/exceptions/scenarios/protected objects | consumed/skipped intent IDs |
| iPA/iIR/iPDN | power domain/activity/voltage/temp | domain/coverage/unknown source |
| iPL/iRT/iECO | dont-touch、physical region/domain | actual touched vs protected |
| Planner | goals、hard budgets、allowed action classes | plan 中固定 IntentRef |
| Verification Hub | signoff scenario set、required claims | 每证书绑定 IntentRef |

## 8. 失败与回退

| 情况 | status | 行为 |
|---|---|---|
| unsupported SDC/UPF command | PARTIAL/UNSUPPORTED | 列出命令和受影响场景，不生成完整性 PASS |
| 对象解析为 0 个或歧义命中 | FAILED/PARTIAL | 保留 source span，不猜对象 |
| constraint 冲突 | FAILED audit | 不激活 IntentRef |
| dominance 证据不足 | UNKNOWN | 使用全 scenario set |
| patch 未审批 | PENDING_APPROVAL | 禁止进入普通 experiment |

## 9. 里程碑

| 阶段 | 交付 | 退出门禁 |
|---|---|---|
| INT-A0（2 周） | IntentRef/ScenarioSetRef/source map | 同输入 canonical hash 稳定 |
| INT-A1（4 周） | SDC normalized IR | 与 iSTA 消费对象逐项对齐，unsupported 显式 |
| INT-A2（3 周） | 8 类 audit | 构造缺陷全检出，零静默 skip |
| INT-A3（3 周） | immutable approval/diff | 未审批 patch 无激活路径 |
| INT-A4（4 周） | scenario coverage/dominance | 决策缩减与全量结果定期对拍 |
| INT-A5（后续） | UPF adapter | 多 voltage-domain gold/oracle 通过后注册 |

## 10. 测试与可杀假说

- golden：generated clock、exclusive/asynchronous groups、multicycle paired hold、case analysis；
- metamorphic：对象重命名保持 ID 映射，约束文件重排不改变 normalized hash；
- adversarial：空 collection、wildcard 过宽、单位混用、重复 clock、循环 generated clock；
- integration：同 IntentRef 的 iSTA/Planner/Verification 场景集合一致；
- security：R0-R3 不能 approve 或替换 source artifact。

**H-INT-A1**：显式 IntentRef 能消除跨工具默认场景漂移。对 10 个设计追踪 iSTA/iTO/iCTS 当前实际消费场景；若仍有未解释差异，停止自动提交，先修 adapter/precedence。

## 11. 不做

- 不让 LLM 直接生成并激活 SDC/UPF；
- 不以 WNS 变好证明约束正确；
- 不把 scenario reduction 当 signoff waiver；
- 不在 UPF parser 不完整时推断 isolation/retention 语义；
- 不把 source text diff 代替 semantic diff。

