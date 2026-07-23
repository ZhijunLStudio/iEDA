<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 48 · Design Intent 与 Scenario 服务实施方案 · ai1.1

> 当前成熟度：`D0/DRAFT`。仓库已有 iSTA SDC 等解析资产，但未发现统一 Intent/Scenario 服务和 UPF 独立能力；本方案不能被解读为现有功能。
>
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

## 12. Canonicalization、消费对账与 scenario 算法

Intent canonicalization 只消除语义无关的 source 顺序/空白/临时名称，保留 precedence、collection 展开和 source span。Wildcard/collection 必须在指定 snapshot 上展开为 stable ObjectId set，并记录 unmatched/ambiguous；设计 snapshot 变化后重新审计，不复用旧展开。

每个 tool result 返回 `consumed_intent_ids / skipped / unsupported / defaulted`。IntentService 聚合 consumer ledger，发现 iSTA/iTO/iCTS 等对同一 IntentRef 的展开不一致时阻断相关 gate。Tool 私有默认 scenario 不能进入 ledger 后被视作 Intent 的一部分。

Scenario dominance 仅在 metric/决策 protocol 下计算：若场景 A 在校准域内对某检查保守支配 B，可减少 F0/F1 探索；F3 validation 仍使用 policy 的 signoff_required set。每次缩减保存被省略场景、支配证据和周期性全量 diff。

## 13. CI 与 PR

`INT-T01` source reorder canonical hash，`INT-T02` wildcard 0/ambiguous/overwide，`INT-T03` generated clock cycle，`INT-T04` false/multicycle pair，`INT-T05` clock groups/case conflict，`INT-T06` unit/PVT/RC mismatch，`INT-T07` consumer ledger disagreement，`INT-T08` patch R0-R4 approval，`INT-T09` new baseline not comparable，`INT-T10` scenario reduction/full audit，`INT-T11` parser version invalidation，`INT-T12` unsupported UPF/SDC partial。

PR：`INT-0 Intent/Scenario/source-map schema` -> `INT-1 SDC adapter/canonical IR` -> `INT-2 audit rules` -> `INT-3 consumer ledger` -> `INT-4 patch/approval/diff` -> `INT-5 scenario dominance/full audit` -> `INT-6 UPF after qualification`。

## 14. Normalized IR 与 precedence 语义

SDC adapter 的输出不是 Tcl AST，而是已解析对象集合和时序语义。首版 IR 至少包含：

```text
ClockDef / GeneratedClockDef / ClockRelation
PortDelay / ClockLatency / ClockUncertainty / TransitionLimit
PathException(false|min|max|multicycle) + setup/hold pairing
CaseAnalysis / DisableTiming / DataCheck
ObjectProtection(dont_touch|dont_use|region)
ScenarioBinding(mode, libraries, rc, PVT, activity)
```

每个节点保存 normalized value、exact source value/unit、expanded ObjectId set、source span、命令顺序、precedence group 和 parser diagnostic。`-add`、覆盖、reset/remove、collection 空集等操作不能在 canonicalization 时被抹平。

Canonical hash 分两层：`source_semantic_hash` 反映当前 snapshot 上的展开与 precedence；`portable_intent_hash` 只用于识别可迁移模板，不能参与证书/cache 命中。对象重命名若 stable ID 不变可保持前者，新增匹配 wildcard 的对象必须改变前者并触发 audit。

## 15. Audit engine 与影响分析

Audit rule 统一返回：

```text
AuditFinding
  rule_id/version/severity/status
  intent nodes + source spans + object/scenario scope
  deterministic evidence/query result
  uncertainty/unsupported reason
  suggested review action, never auto-applied patch
```

规则运行分四层：单节点 schema/单位；跨节点 precedence/冲突；设计对象覆盖；跨消费者实际消费对账。昂贵的 STA/formal 反证作为外部 validator，不嵌入规则本体。finding 去重按 rule + semantic scope，source 文本变动但语义不变时保留关联。

`intent.diff` 输出 `added/removed/changed/retargeted/precedence_changed/coverage_changed`，并计算影响集合：affected endpoints、timing cones、modes/scenarios、power domains、protected objects 和需失效 claim。影响集合是保守上界；无法证明局部时返回 full invalidation，不能猜小范围。

## 16. IntentPatch、审批与并发

IntentPatch 只允许版本化 typed operation，例如 `AddClock`、`ReplaceObjectSet`、`TightenException`、`BindScenarioLibrary`；禁止内嵌任意 Tcl。提交时验证 `base_intent_ref`，若基线已 supersede 则返回 `CONFLICT`，不自动 rebase。

审批记录包含 proposer、reviewer role、patch hash、semantic diff、影响分析、audit/verification evidence、批准用途和有效期。涉及 clock/exception/power domain 的 patch 至少需要独立 domain owner；批准角色不得由 Planner token 或工具 manifest 自行提升。

激活新 IntentRef 时：

1. 在固定 Design Snapshot 上重放 import/canonicalize；
2. 全量执行必需 audit；
3. 生成与旧 ref 的 semantic diff 和 invalidation event；
4. 创建新 baseline，旧运行继续绑定旧 ref；
5. Gateway 禁止新 experiment 选择 superseded ref，除非显式 replay。

## 17. 首个 Timing Lab 切片

首切片只支持 SDC 中 Timing ECO 真正消费的子集：primary/generated clocks、IO delay、clock groups、false/multicycle path、case analysis、dont-touch/dont-use，以及 setup/hold scenario binding。对其他命令保留 source span 并返回 coverage partial。

端到端验收序列：导入 SDC -> 生成 IntentRef/ScenarioSetRef -> iSTA 返回 consumption receipt -> audit 对账 -> Planner 固定 refs -> Resize/Buffer branch -> Verification Hub 按相同 signoff scenario set 签证。注入一条过宽 false path、一个空 wildcard、一个 library PVT 错配和一次 parser 升级，四者都必须阻断旧完整性结论或使其失效。

服务级指标包括 unresolved object 数、unsupported 命令覆盖、consumer disagreement、intent 变更导致的 invalidation 数、audit p95 和错误复用次数。成功标准不是“解析了多少 SDC 命令”，而是首批闭环不存在未解释默认值和场景漂移。

## 18. Schema migration 与兼容

Intent/Scenario schema 使用 major/minor 版本。reader 可以忽略明确声明为 non-semantic 的未知 minor metadata；未知 semantic field、major version 或 parser diagnostic class 一律拒绝激活。迁移工具读取旧 ref 并产生新 ref、migration report 和 equivalence findings，不就地改 artifact。

版本升级若声称语义等价，必须在 canonical corpus 上证明 semantic hash、expanded object set、consumer receipt 和 audit findings 等价；否则按 semantic-breaking 处理并失效所有依赖 certificate/cache。

## 19. 版本历史

- ai1.1（2026-07-23）：补充 SDC normalized IR、双层 canonical hash、四层 audit、IntentPatch 并发审批、Timing Lab 端到端切片和 schema migration。
- ai1.0（2026-07-23）：定义 Intent/Scenario 边界、核心 API、审计规则、权限与消费契约。
