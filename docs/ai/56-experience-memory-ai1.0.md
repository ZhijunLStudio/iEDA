<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 56 · Design Trajectory 与 Failure Memory 实施方案 · ai1.0

> 当前成熟度：`D0/DRAFT`。`44` 规划 `trajectory.search`，`47` 规划数据/失败样本；本服务承接规范案例、检索、适用性和生命周期，Observer 保留面向 Agent 的解释入口，Data/Oracle 保留数据集与训练职责。  
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

