<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 55 · Technology/PDK Knowledge 服务实施方案 · ai1.1

> 当前成熟度：`D0/DRAFT`。仓库已有 LEF/Liberty/RC/DEF 与各工具配置解析路径，但没有统一 `TechContext`、rule coverage 和资格认证服务。
>
> 职责：统一技术语义、来源、单位、层/过孔/库族映射和 capability qualification；不复制各 EDA 工具的物理计算 kernel。

## 1. 产品职责

Agent 不能靠文件名推断工艺。Technology Knowledge 将以下输入编译成不可变 `TechContextRef`：technology/cell LEF、Liberty library set、RC tech/ITF、DRC/LVS deck manifest、layer purpose、via stack、voltage/temp limits、library equivalence family，以及必要的 package/thermal/reliability 参数引用。

服务区分三层：`parsed` 表示能读取；`semantically_valid` 表示跨源一致；`qualified_for(capability, fidelity)` 表示经过该工具的 gold/oracle/coverage 测试。三者不能混用。

## 2. API

```text
tech.import(source_manifest)
tech.validate(tech_context_ref, check_profile)
tech.query_layers/vias/cells/corners/rules(selector)
tech.map_layer(source_namespace, target_namespace)
tech.map_cell_family(master, target_constraint)
tech.rule_coverage(tool_id, rule_set)
tech.qualify(tool_id, fidelity, benchmark_evidence)
tech.diff(context_a, context_b)
tech.deprecate(context_or_qualification, reason)
```

修改 source 或 mapping 创建新 ref；普通 Agent 只有 read/query 权限，qualification 需要 PDK/domain owner。

## 3. TechContext Schema

```text
TechContext
  tech_context_ref
  source_artifacts[]: kind/hash/version/license
  unit_system
  layer_graph: routing/cut/purpose/direction/pitch/width/spacing
  via_catalog: lower/cut/upper/geometry/resistance/current_limit
  library_sets: scenario/voltage/temp/cell families/dont_use
  rc_models: corner/model/domain/coverage
  rule_manifests: namespace/version/supported/skipped
  power_thermal_reliability_refs
  qualifications[]
  known_issues[]
```

所有归一化对象保留 source span。foundry deck 内容可保持加密/外部，只在 manifest 中记录 hash、capability 和 coverage，不要求复制敏感规则文本。

## 4. 语义校验

- DBU、长度、电阻、电容、时间、功率、电压、温度单位闭合；
- routing/cut layer 拓扑连续，preferred direction/pitch 合理；
- via 上下层、cut 数、几何与命名一致；
- LEF macro 与 Liberty cell/pin/direction/function 映射；
- library PVT 与 Scenario operating condition 一致；
- RC layer/corner 映射无孤儿和歧义；
- DRC/LVS rule namespace 与 iDRC/iLVS 支持集可追溯；
- power domain voltage、EM limit、thermal material 的适用范围明确。

启发式 sanity pass 不是 foundry qualification。

## 5. Rule-deck/PDK Adapter 工厂边界

`46 Honey` 可生成 parser/mapping/smoke test 候选；本服务保存语义 IR、qualification 和版本。自动生成结果先进入 quarantine：

```text
source → generated adapter → parse/sanity
  → canonical pattern suite
  → differential oracle
  → domain owner review
  → capability-specific qualification
```

Rule compiler 不能根据公开描述猜测缺失 foundry 规则；unsupported rule 必须留在 coverage 中。

## 6. LLD 与源码落点

```text
src/technology/
  api/TechnologyService.{hh,cc}
  manifest/{SourceManifest,TechContext,Qualification}.hh
  adapters/{Lef,Liberty,RcTech,DrcDeck,LvsDeck}.cc
  graph/{LayerGraph,ViaCatalog,CellFamilyGraph}.cc
  validation/{Unit,CrossSource,Scenario,RuleCoverage}Validator.cc
  query/TechnologyQuery.cc
  qualification/QualificationRegistry.cc
```

初期 Composition 现有 parser；只有当现有 parser 无稳定结构化 API 时增加薄 adapter，禁止为服务重写 LEF/Liberty parser。

## 7. 消费契约

| 工具 | 消费 | 必须返回 |
|---|---|---|
| iFP/iPL/iRT/iDRC | layer/via/site/rule | 实际使用 tech objects/rules |
| iSTA/iTO/iCTS | library set/cell family/PVT | consumed cells/arcs/corners |
| iRCX/iSI | RC/coupling model/layer mapping | model hit/miss/coverage |
| iPA/iIR/PDN | voltage/cell power/via/grid | source/coverage/limits |
| iFormal/iLVS | cell function/device/rule mapping | blackbox/unsupported list |
| Planner/Router | qualification/domain/cost | 不得把 unqualified 当 F3/F4 |

## 8. 失败与版本语义

- source hash、mapping 或 parser version 变化创建新 TechContextRef；
- qualification 绑定 tool binary + fidelity + benchmark protocol，任一变化可失效；
- unresolved mapping 返回 PARTIAL，依赖对象的 capability 不可 full PASS；
- encrypted deck 无法枚举规则时，adapter 必须提供 vendor/tool 声明的 coverage artifact；
- tech diff 分为 semantic-breaking 与 metadata-only，前者失效相关证书/cache。

## 9. 里程碑

| 阶段 | 交付 | 退出门禁 |
|---|---|---|
| TECH-A0（2 周） | source/TechContext/qualification manifest | 内容寻址、license/tenant 完整 |
| TECH-A1（4 周） | layer/via/unit graph | 4 PDK 样例跨源一致性报告 |
| TECH-A2（4 周） | library family/PVT mapping | iSTA/iTO 消费同一映射 |
| TECH-A3（4 周） | RC/rule coverage | iRCX/iDRC unsupported 不再静默 |
| TECH-A4（4 周） | qualification registry | capability discovery 只发布合格组合 |
| TECH-A5（后续） | PDK adapter/rule compiler | pattern+oracle+owner 三重门禁 |

## 10. 测试与可杀假说

- 单位缩放、layer 重命名、source 顺序变化的 metamorphic；
- LEF/Liberty pin 缺失、PVT mismatch、via 断层、RC orphan、rule version drift；
- 同 PDK 不同版本不能误命中 cache/certificate；
- qualification 撤销后 registry 立即停止新调用，历史 evidence 仍可重放。

**H-TECH-A1**：统一 TechContext 能减少跨工具层/库/单位错配。先审计 10 个 flow 的实际 mapping；若服务不能定位差异，说明 adapter 没捕获真实消费路径，不能晋级。

## 11. 不做

- 不宣称拥有 foundry 未提供的规则真值；
- 不因 parser 不报错就标 qualified；
- 不让 Agent 自动修改 rule/PDK mapping 并用于签核；
- 不把 proprietary deck 内容放入普通 prompt/log；
- 不建立与各工具重复的私有 cell/layer ID 体系。

## 12. Canonical ID、消费回执与失效传播

Tech object ID 采用 `tech_context_ref + kind + canonical local id`，不能跨 PDK/version 猜同一对象。Layer/cell/via 的 source aliases 由 mapping table 管理；多对一或一对多映射必须声明用途和歧义。单位归一化保留 exact scale/source，禁止浮点舍入后丢原值。

每个 capability 返回 `consumed_tech_ids / model hits / misses / defaults`。TechnologyService 对照 manifest 检查实际消费；工具绕过 TechContext 私读另一个 LEF/Liberty/RC 文件时，qualification fail。TechContext semantic diff 生成影响集合：library/function 变化失效 formal/timing/mapping，RC 变化失效 RC/timing/SI，rule 变化失效 DRC/DFM certificate，via limit 变化失效 route/EM。

## 13. CI 与 PR

`TECH-T01` source order/canonical hash，`TECH-T02` DBU/unit extremes，`TECH-T03` layer/via graph orphan/cycle，`TECH-T04` LEF/Liberty pin/function mismatch，`TECH-T05` PVT/scenario mismatch，`TECH-T06` RC/rule mapping missing/ambiguous，`TECH-T07` encrypted deck coverage，`TECH-T08` consumer bypass/default，`TECH-T09` semantic diff invalidation，`TECH-T10` qualification tool/parser drift，`TECH-T11` tenant/license ACL，`TECH-T12` deprecate/replay history。

PR：`TECH-0 source/TechContext schema` -> `TECH-1 unit/layer/via graph` -> `TECH-2 library family/PVT` -> `TECH-3 RC/rule coverage` -> `TECH-4 consumer receipts` -> `TECH-5 qualification/invalidation` -> `TECH-6 factory-generated adapters`。

## 14. Import pipeline 与 canonical graph

Import 分阶段执行，后阶段不得掩盖前阶段的 coverage：

```text
SourceManifest validate/license/tenant
  -> parser adapters + source diagnostics
  -> exact-unit normalized records
  -> alias/object resolution
  -> layer/via/library/RC/rule cross-source graph
  -> semantic validators
  -> immutable TechContext + validation report
```

同类 source 冲突不采用 last-writer-wins。每个属性保存 candidate values、来源、precedence rule 和 resolution；没有显式 rule 时为 `CONFLICTED`。canonicalization 可以稳定排序和统一 exact rational scale，但不能合并具有不同 purpose、mask、PVT 或条件表达式的对象。

LayerGraph 的 edge 表达 routing-cut-routing 和合法连接；ViaCatalog 引用 edge 与几何/电性/可靠性适用域。CellFamilyGraph 区分 logical equivalence、drive-strength ladder、VT variants、physical compatibility 和 formal blackbox；“名称相似”不是 equivalence。RC/rule 节点保存 namespace 与 coverage，不把 proprietary deck 展开成普通文本。

## 15. Query 与 mapping 语义

所有 query 返回 `items + coverage + diagnostics + context_ref`。selector 只能使用 typed predicate；查询空集区分 `VALID_EMPTY`、`UNMATCHED` 和 `UNSUPPORTED_FIELD`。consumer 不能把三者都当空列表继续执行。

MappingResult 必须表达：

```text
EXACT            唯一语义等价
CONDITIONAL      在指定 scenario/purpose/capability 下等价
ONE_TO_MANY      需要调用者选择或扩展
AMBIGUOUS        存在多个不可判定候选
UNMAPPED         source 已知但无 target
UNSUPPORTED      adapter 无该语义
```

`map_cell_family` 还要返回 function/PG pin/site/height/drive/VT 限制；`map_layer` 返回 purpose/mask/direction/RC/rule domain。Planner 只能消费 EXACT/满足条件的 CONDITIONAL；其余状态必须由 domain tool 明确处理或拒绝。

## 16. Capability-specific qualification

Qualification 不是 TechContext 的全局 PASS：

```text
TechnologyQualification
  tech_context + capability/tool/parser/build hashes
  facet + fidelity + stage + scenario/rule domain
  supported/unsupported object and rule coverage
  canonical-pattern/golden/differential evidence
  consumer receipt audit
  owner/issued/expiry/revocation
```

例如 iSTA F3 可针对指定 library/RC/scenario 集合 qualified，而 iDRC 仍可能只有 spacing subset；Capability Registry 必须发布这个交集，不能展示为“该 PDK 已支持”。

变更影响按 graph edge 传播：source/parser/mapping 变化先产生 semantic diff，再定位受影响 qualification、cache、certificate 和 dataset。metadata/license 变化也可能不改物理语义但改变访问资格；因此 semantic invalidation 与 policy invalidation 分开记录。

## 17. 首个 Timing Lab 切片

首版只导入 Timing ECO 必需的 technology/cell LEF、Liberty set 和 RC corner manifest，建立 site/layer/via、cell pin/function/family、PVT/units 和 scenario mapping。iSTA、iTO、iPL 三个 consumer 必须返回 receipt，并由服务证明它们没有私读不同版本输入。

验收注入：一个 LEF/Liberty pin mismatch、一个错误 capacitance/time scale、一个不存在的 VT variant、一个 RC corner orphan、一次 library 更新。前四项必须产生可定位 finding，最后一项必须创建新 ref 并使旧 timing qualification/certificate/cache 不可 current 命中。

只有上述切片稳定后再接 rule deck、EM/thermal/package；新增 source 类型必须有真实 consumer、source-owner 和独立 qualification protocol。

## 18. 安全、运维与版本历史

PDK artifact 按 tenant/license 加密与审计，服务日志只记 hash/object ID/诊断码，不输出 proprietary rule/table 原文。查询结果也受用途控制；模型/Experience/Honey 默认只能得到批准的 domain signature 或脱敏属性。

运营指标：import/replay 成功率、unresolved/conflicted mapping、consumer bypass/default、qualification coverage、semantic-diff invalidation、旧 ref 误命中和查询 p95。服务不可用时允许 replay 已固定且 current 的本地 context artifact，但禁止工具退回私有默认 PDK 文件。

- ai1.1（2026-07-23）：补充分阶段 import、canonical graph、typed mapping 状态、capability-specific qualification、Timing Lab 切片和 PDK 数据治理。
- ai1.0（2026-07-23）：定义 TechContext、跨源语义校验、消费契约和 qualification registry。
