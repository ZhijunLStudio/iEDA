<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 55 · Technology/PDK Knowledge 服务实施方案 · ai1.0

> 当前成熟度：`D0/DRAFT`。仓库已有 LEF/Liberty/RC/DEF 与各工具配置解析路径，但没有统一 `TechContext`、rule coverage 和资格认证服务。  
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

