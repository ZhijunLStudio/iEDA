<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 56 · Design Trajectory 与 Failure Memory 实施方案 · ai1.1

> 当前成熟度：`D0/DRAFT`。`44` 规划 `trajectory.search`，`47` 规划数据/失败样本；本服务承接规范案例、检索、适用性和生命周期，Observer 保留面向 Agent 的解释入口，Data/Oracle 保留数据集与训练职责。
>
> 经验是 proposal 的先验，不是 validator 或 oracle。

## 1. 为什么需要结构化经验

纯文本 RAG 难以区分“某动作失败于 hold”与“该动作在另一个 PDK 成功”，也难以防同 RTL 家族泄漏。经验对象必须绑定 snapshot 特征、intent/tech/scenario、动作、结果、证书和失败域，并显式描述适用/不适用条件。

首版优先保存负经验：高置信误判、越门禁候选、timeout、unsupported、rollback、增量/full 不一致。最终 clean design 不是唯一有价值数据。

## 2. API

```text
experience.record_case(experiment_record)
experience.get(case_id)
experience.query(problem_context, filters, top_k)
experience.query_failures(action_or_signature, filters)
experience.mark_counterexample(case_id, evidence)
experience.link_superseding(case_id, new_case_id)
experience.redact/expire(case_id, policy)
experience.export_dataset(query, split_policy)
```

`query` 返回案例、相似依据、适用性评分、冲突证据和 provenance；不直接返回“执行此动作”命令。

## 3. Case Schema

```text
ExperienceCase
  case_id, tenant, retention/license
  design_family, topology_signature, stage, scale_bucket
  intent/scenario/tech refs or redacted domain signature
  problem_signature + evidence_refs
  proposed_action + typed parameters + scope
  predicted_outcome/model/confidence
  observed_outcome/metrics/certificates
  disposition = accepted|rejected|failed|rolled_back|unsupported
  failure_class/root_cause_status
  applicability + exclusions
  tool/model/data/oracle hashes
```

`root_cause_status` 区分 confirmed/hypothesis/unknown；事后文本解释不能自动升级为 confirmed。

## 4. 失败分类

一级分类固定：`INPUT`、`UNSUPPORTED_DOMAIN`、`INFEASIBLE`、`TOOL_DEFECT`、`TIMEOUT_RESOURCE`、`STATE_CORRUPTION`、`SCOPE_VIOLATION`、`VALIDATION_FAIL`、`MODEL_HIGH_CONFIDENCE_ERROR`、`POLICY_REJECT`、`UNKNOWN`。

二级分类由领域扩展，例如 timing hold regression、legal no-site、DRC spacing、RC coverage、formal counterexample。分类变更版本化，原记录不就地重写。

## 5. 检索与适用性

检索采用两段式：

```text
hard filter: tenant/license + stage + action class + required context compatibility
  → candidate retrieval: topology/physical/problem embeddings + structured keys
  → applicability model/rules
  → diversity and negative-case mixing
  → return with distance, exclusions, evidence strength
```

不能只返回最相似成功案例；至少同时返回相似失败/反例，帮助 Planner 估计风险。跨 PDK 检索只有在 TechContext 声明映射兼容时允许。

## 6. LLD 与源码落点

```text
src/knowledge/experience/
  api/ExperienceService.{hh,cc}
  schema/{ExperienceCase,FailureTaxonomy,Applicability}.hh
  ingest/ExperimentRecordNormalizer.cc
  index/{StructuredIndex,VectorIndex,TopologySignature}.cc
  retrieval/{Filter,Ranker,Diversifier}.cc
  policy/{Tenant,Retention,Redaction,FamilySplit}.cc
  audit/CounterexampleTracker.cc
```

`44 TrajectoryIndex` 改为本服务的查询 adapter/可视化 consumer，不再另存 canonical case；`47` 通过 export 获取冻结 dataset，不从在线索引随意切 train/test。

## 7. 防泄漏与生命周期

- tenant 默认硬隔离，匿名化不自动授权跨客户；
- design family 是强字段，同族变体不得跨 benchmark train/test；
- tool/model/tech 版本过期后案例保留但 applicability 降级；
- 被新证据推翻的案例标 counterexample/superseded，不物理删除审计链；
- retention/license 到期执行 redaction/删除并使派生 dataset 可追踪失效；
- 在线检索语料与最终 held-out 门禁集物理/ACL 隔离。

## 8. Planner/Model/Data 集成

| 消费者 | 用法 | 红线 |
|---|---|---|
| Planner | proposal prior、avoid known failures、recovery hint | 不直接 commit |
| Observer | trajectory/failure explanation | 相似不等于因果 |
| Model Router | OOD/domain evidence、drift cases | 不用测试集在线调参 |
| Data/Oracle | 导出 paired/active-learning dataset | split 后不可回灌 holdout 标签 |
| Honey | escaped defect 更新模板测试 | 不把客户代码/数据放生成 prompt |

## 9. 里程碑

| 阶段 | 交付 | 退出门禁 |
|---|---|---|
| MEM-A0（2 周） | Case/failure/applicability schema | success/failed/unknown 均可规范记录 |
| MEM-A1（3 周） | Timing Lab ingest | 100% candidate 含 disposition/provenance |
| MEM-A2（4 周） | structured + topology retrieval | known related cases Recall@K 基线 |
| MEM-A3（3 周） | negative/diverse retrieval | 不只返回成功和同一 topology |
| MEM-A4（4 周） | tenant/family/retention policy | 泄漏构造例全部被拦截 |
| MEM-A5（持续） | counterexample/applicability learning | 错误建议可追踪降权/撤回 |

## 10. 测试与可杀假说

- 同名不同 ObjectId、同 RTL 不同 PDK、同拓扑不同 intent 的检索隔离；
- tenant/retention/license ACL；
- 旧工具案例、新 TechContext、contradictory outcomes 的排序；
- 删除 vector index 后 structured fallback 可用；
- benchmark 对比无经验、仅成功经验、成功+失败经验的 regret/accepted rate。

**H-MEM-A1**：加入失败/反例经验能在同预算下减少重复无效动作。若 held-out family 无改善，经验只保留审计和主动学习用途，不扩大检索权重。

## 11. 不做

- 不把 prompt/chat transcript 直接当 canonical case；
- 不把相似案例当物理证明；
- 不跨租户默认共享；
- 不允许 benchmark holdout 标签进入在线检索；
- 不只保存被接受的动作；
- 不因 root-cause 叙述流畅就标 confirmed。

## 12. Ingest、检索结果与质量评测

Ingest 只接受完整 Experiment/Decision/Evidence refs，先校验 tenant/license/context/tool lineage，再规范 failure taxonomy/problem/action signatures。缺 disposition 或证据的 case 可存 `INCOMPLETE`，但默认不进入 Planner 检索。后续 root-cause confirmation 追加 evidence event，不覆盖原 hypothesis。

```text
ExperienceQueryResult
  query/problem/context refs
  cases[] {case_id, structured/vector distances,
           applicability, exclusions, evidence strength, age/drift}
  success/failure/counterexample diversity
  coverage/filters/index versions
```

检索评测不只看相似 case Recall@K，还比较 downstream accepted-action rate、selection regret、重复失败率和 unsafe suggestion false-positive。Vector index unavailable 时 structured fallback 必须保持 hard filters；不得为了可用性放松 tenant/family/PDK 边界。

## 13. Poisoning、失效与 CI

只有有验证证据的 observed outcome 可影响 applicability/ranking；用户文本、模型 self-report 和未验证成功不能提升权重。Tool/Tech/Intent drift 使 case 降权或 excluded，counterexample 可撤销规则但保留历史。导出 dataset 后记录 exact case refs；在线 case 更新不改变冻结数据集。

`MEM-T01` ingest missing lineage，`MEM-T02` taxonomy/version，`MEM-T03` same name/different ID，`MEM-T04` tenant/license/retention，`MEM-T05` family/PDK/intent hard filter，`MEM-T06` success+failure diversity，`MEM-T07` contradictory/counterexample，`MEM-T08` old tool/tech drift，`MEM-T09` vector outage fallback，`MEM-T10` malicious text/poisoning，`MEM-T11` dataset export freeze，`MEM-T12` downstream A/B。

PR：`MEM-0 schema/taxonomy` -> `MEM-1 Timing Lab ingest` -> `MEM-2 structured index` -> `MEM-3 vector/applicability/diversity` -> `MEM-4 ACL/retention/family split` -> `MEM-5 counterexample/drift` -> `MEM-6 Planner/Data A/B`。

## 14. Case identity 与事件生命周期

```text
case_id = hash(
  normalized problem/context signature,
  base snapshot family signature,
  proposal/delta,
  observed evidence/disposition
)
```

同一 proposal 的多次尝试不是覆盖关系：每次执行保留 attempt，聚合 case 通过 refs 关联。`CaseEvent` 追加记录 `INGESTED/QUALIFIED/ROOT_CAUSE_UPDATED/COUNTEREXAMPLE/SUPERSEDED/REDACTED/EXPIRED`，包含 actor、reason、evidence 和 policy version。索引是事件投影，可以重建；canonical case 和证据不以 vector DB 为真值。

Ingest qualification 分层：lineage/schema 完整可用于审计；有 current verified observation 可用于检索；有独立 root-cause 证据才可影响 failure rule；满足 tenant/license/split policy 才可导出数据。一个 `INCOMPLETE` case 后续补证升级时产生事件和新 projection，不改写当时事实。

## 15. 检索评分、矛盾与适用域

hard filter 后的 ranking 采用可解释分量，不输出不透明单分数：

```text
context compatibility: tech/intent/scenario/stage/action
problem similarity: structured signature + topology + physical features
evidence strength: certificate/oracle/root-cause status
freshness/drift: tool/model/context qualification
diversity: action/region/outcome/failure class
conflict penalty: comparable cases with contradictory outcomes
```

返回结果列出每一分量和排除原因。成功与失败检索使用同一候选池，按 query policy 保证最少 negative/counterexample 配额；若没有满足 hard filter 的案例，返回 `NO_APPLICABLE_CASE`，不能用跨 PDK 最近邻填空。

可比较案例结果冲突时创建 `ConflictSet`，区分测量协议差异、隐藏 context、随机性和真正反例。在冲突解决前降低 evidence strength，并要求 Planner 扩大探索或升级验证；不能多数投票生成“经验真值”。

## 16. 防 poisoning 与反馈闭环

影响排序的信号只来自 Runtime disposition、Verification certificate、Oracle protocol 和 owner-confirmed taxonomy。文本描述、用户点赞、模型自评和被选择本身不能提升权重，避免 selection bias 与自我强化。

Planner 使用案例后回传 `RetrievalUseRecord`：哪些 case 被展示/采用/忽略、产生哪些 proposal、最终证据和成本。评估同时保留 propensity/展示集合，避免只观察被采用建议。错误建议生成 counterexample event；受影响规则/embedding/model 重新 qualification，而不是删除难例。

在线 ranking 更新先 shadow，在冻结 family holdout 上比较重复失败率、unsafe suggestion 和 regret。没有统计收益时保留 structured retrieval 和审计，不把更多历史塞进 prompt。

## 17. 隐私、导出与删除传播

- domain signature 采用批准字段白名单，不能靠“匿名化 embedding”绕过 tenant policy；
- 原始网表、路径名、宏名、报告文本默认不进入共享索引；
- 跨项目共享需要显式 license、source owner 和可逆性评估；
- export 生成不可变 case refs、投影/index 版本、redaction policy 和 family split；
- expire/delete 生成 tombstone，并通知派生 dataset/model/qualification owner；
- 无法从不可逆模型中删除影响时，记录风险并按治理策略重新训练或停用。

检索审计日志本身可能泄漏查询问题，按与 case 相同或更严格的 tenant/retention policy 管理。

## 18. 首个 Timing Lab 切片与完成定义

首版只记录 `ResizeInst/SwapVt/InsertBuffer` 的 problem、proposal、branch outcome 和 verification disposition。至少建立六个检索桶：accepted improvement、setup no-gain、hold regression、legal failure、unsupported domain、model high-confidence error。

完成定义：Timing Lab 所有候选 100% 有 disposition；同名异对象、同 family holdout、跨 tenant/PDK 构造例无法泄漏；矛盾案例同时返回；vector outage 不放松 hard filter；Planner A/B 在固定预算下报告 accepted-action rate、重复失败、unsafe suggestion 和 regret。经验无收益不阻塞基础闭环，但 Planner 不得声称 experience-guided 晋级。

## 19. 版本历史

- ai1.1（2026-07-23）：补充事件化 case identity、检索评分与 ConflictSet、poisoning 防线、反馈偏差、删除传播和 Timing Lab 六类经验切片。
- ai1.0（2026-07-23）：定义 ExperienceCase、失败分类、两段式检索、生命周期和 Planner/Data 集成。
