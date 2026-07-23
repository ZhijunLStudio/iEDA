<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 46 · Honey 工具生成工厂实施方案 · ai1.1

> 新建横向能力。目标不是让模型任意生成 EDA 内核，而是从受控模板生成 adapter、只读 analyzer、局部 solver 和 workflow，并以机器证据晋级。

## 1. 生成等级

| 等级 | 产物 | 默认权限 |
|---|---|---:|
| T0 | report/parser/adapter | R0-R1 |
| T1 | read-only analyzer/feature | R1 |
| T2 | local solver，输出 proposal 不 apply | R1 |
| T3 | workflow，组合注册工具 | R2 |
| T4 | typed delta generator | R2，强门禁 |
| T5 | 新物理内核/高权限工具 | 人工立项，不自动发布 |

首年只产品化 T0-T3。

### 1.1 Factory API

```text
factory.create(requirement, template, permissions)
factory.build(package_id)
factory.test(package_id, gate_profile)
factory.publish_quarantine(package_id)
factory.run_shadow(package_id, dataset)
factory.promote(package_id, approval)
factory.revoke(package_id, reason)
```

create/build 可以由 Agent 发起，promote 必须经过确定性门禁和显式批准。

## 2. Tool Package

```text
manifest.yaml
schemas/request.json
schemas/response.json
src/
tests/unit/
tests/golden/
tests/metamorphic/
tests/adversarial/
calibration/domain.json
security/permissions.yaml
provenance/generation.json
```

## 3. 生成流程

```text
requirement → select template/capabilities
  → generate package in sandbox
  → static/compile/schema
  → golden + mutation + metamorphic
  → differential/oracle test
  → resource/failure/security test
  → publish to quarantine registry
  → shadow traffic
  → explicit promotion
```

### 3.1 LLD 与源码落点

```text
tools/factory/
  api/FactoryService.py
  registry/PackageRegistry.py
  sandbox/SandboxRunner.py
  gates/{Static,Golden,Mutation,Metamorphic,Differential,Security}.py
  promotion/PromotionPolicy.py
  templates/
```

工厂运行时与 iEDA 主进程隔离，通过 Tool Registry 安装 quarantine package。

## 4. 模板库

```text
tools/factory/templates/
  legacy_report_adapter/
  object_query_analyzer/
  metric_attributor/
  cp_sat_local_solver/
  workflow_composer/
  pdk_mapping_adapter/
```

模板提供 Tool Contract、错误语义、trace、预算和测试骨架；生成内容聚焦 domain 逻辑。

## 5. 真工具门禁

- mutation score：删除/替换核心计算后测试必须失败；
- golden：独立小例真值；
- metamorphic：平移/重命名/单位缩放等；
- differential：与现有/商业工具同协议对拍；
- permission：越权文件/网络/主 snapshot 写入失败；
- resource：CPU/RSS/wall 上限；
- unsupported：域外输入拒答而非猜测。

## 6. 里程碑

| 阶段 | 交付 | 门禁 |
|---|---|---|
| HF-A0（3 周） | package spec + two templates | 手工工具也可按 spec 打包 |
| HF-A1（4 周） | adapter/analyzer generator | 5 个报告 adapter 过门禁 |
| HF-A2（4 周） | local solver template | 3 个小问题穷举对拍 |
| HF-A3（4 周） | workflow composer/quarantine | shadow traffic 无越权 |
| HF-A4（持续） | failure memory/template evolution | escaped defect 进入反例集 |

## 7. 不做

- 不以 compile pass 作为成功；
- 不让生成工具修改约束；
- 不把生成 prompt 当唯一 provenance；
- 不自动晋级生产；
- 不平行重写 iSTA/iRT 等成熟内核。

**H-HF-A1**：受控模板能把新 adapter/analyzer 交付从周降到天，同时 defect 不增加。以人工基线对比 lead time、mutation score 和 escaped defect。

---

## 8. Requirement 与生成 provenance

```text
FactoryRequirement
  requested capability/facets/domain
  input/output schemas + source capability refs
  allowed dependencies/permissions/resources
  correctness properties/gold/oracle protocol
  unsupported behavior/security profile

GenerationRecord
  requirement/template/generator/model/prompt hashes
  source dependency/license hashes
  produced diff/build environment
  test/gate/shadow/promotion history
```

Requirement 缺独立 correctness oracle 或至少可杀的 metamorphic property 时，最高只能生成 T0 parser skeleton/quarantine，不得升可执行 analyzer/solver。

## 9. Sandbox、gate 与晋级

Build/test 在无主仓写权限、默认断网、限 CPU/RSS/wall/output 的隔离环境。依赖只来自 allowlisted lockfile/CAS；生成代码不能读取用户 home、secret、PDK 明文或其他租户 artifact。

Gate 顺序固定：schema/static/license -> compile -> unit/golden -> mutation -> metamorphic -> differential -> failure/resource/security -> shadow。任何 skipped required gate 是 `INCOMPLETE`。PromotionPolicy 绑定 package hash、tests、domain 和权限；修改一行代码即新 package，旧批准不继承。

Shadow 只读或在 disposable branch 运行，输出不进入选择/commit。Promote 后仍由 Tool Registry 限制 maturity/domain；escaped defect 触发 revoke、使缓存/certificate/qualification stale，并将最小反例加入模板测试。

## 10. CI 与 PR

`HF-T01` requirement/schema，`HF-T02` malicious generated file/network/process，`HF-T03` dependency/license，`HF-T04` compile-pass fake logic mutation，`HF-T05` golden/metamorphic，`HF-T06` differential parser drift，`HF-T07` resource/OOM/timeout，`HF-T08` shadow no side effect，`HF-T09` promotion approval/hash change，`HF-T10` revoke propagation，`HF-T11` tenant data prompt leakage，`HF-T12` generated solver infeasible checker。

PR：`HF-0 package/requirement/provenance` -> `HF-1 sandbox/static/build` -> `HF-2 adapter/analyzer templates` -> `HF-3 full gate pipeline` -> `HF-4 quarantine/shadow/promotion` -> `HF-5 local solver/workflow templates` -> `HF-6 failure-memory evolution`。

## 11. Package identity 与生命周期

三个 ID 必须分离，避免“重新构建后沿用旧批准”：

```text
package_id       = hash(requirement + template + generated source + schemas)
build_id         = hash(package_id + toolchain + locked dependencies + build flags)
qualification_id = hash(build_id + gate profile + test corpus + domain + permissions)
```

生命周期由 Registry 原子推进：

```text
DRAFT -> GENERATED -> BUILDING -> BUILT -> GATE_RUNNING
  -> QUARANTINED -> SHADOWING -> QUALIFIED -> ACTIVE
                              \-> REJECTED
ACTIVE -> SUSPENDED -> REVOKED
```

- `GENERATED` 只表示文件齐全，不表示代码可信；
- `BUILT` 只表示可重现编译成功，不表示业务逻辑正确；
- `QUALIFIED` 必须限定 capability facet、domain、fidelity、权限和有效期；
- 同一个 package 可以有多个 build，但生产 capability 只能引用一个明确 qualification；
- gate corpus、依赖、模板、权限或生成源码变化时重新生成 qualification；
- revoke 事件要通知 Tool Registry、Verification Hub、cache 和 Experience Memory。

Registry 的状态变更采用 compare-and-swap，并保存 actor、old/new state、reason 和 evidence refs。任何 worker 都不能直接把状态写为 `ACTIVE`。

## 12. Requirement compiler 与模板契约

Factory 不直接把自然语言 prompt 交给生成器。`RequirementCompiler` 先把需求编译为确定性中间表示：

```text
CompiledRequirement
  capability_name/facets/domain/maturity_ceiling
  typed input/output/error schemas
  required context refs and object-id namespaces
  permission/resource/network/artifact policy
  invariants + metamorphic properties + oracle protocol
  unsupported-domain predicates
  dependency allowlist + license policy
  acceptance thresholds + promotion owner
```

存在歧义的 schema、单位、对象身份或正确性性质时返回 `NEEDS_SPEC`，不得让模型自行补全。模板也必须有版本化 `TemplateDescriptor`：允许修改的 slot、固定 runtime glue、必需测试、允许依赖和最高权限。生成器只能改 slot；schema validation、trace、budget、cancel、artifact 和 error mapping 由模板固定实现。

首批模板的边界如下：

| 模板 | 生成 slot | 工厂固定部分 | 最高等级 |
|---|---|---|---:|
| report adapter | field mapping、单位转换 | 原始 artifact、source span、partial 语义 | T0 |
| object analyzer | feature/归因规则 | snapshot/context、只读 scope、coverage | T1 |
| local solver | objective/constraints/model builder | proposal-only、可行性 checker、预算 | T2 |
| workflow composer | capability 选择和数据依赖 | DAG validator、权限、回退、停止 | T3 |

生成代码不得定义新的权限级别、绕过 capability gateway，也不得把 stringly typed object name 当稳定 ObjectId。

## 13. Gate result 与量化晋级

```text
GateResult
  gate/test-suite/profile versions
  package/build IDs
  domain slice + corpus manifest
  passed/failed/skipped/unsupported counts
  mutation operators killed/survived
  differential error distribution
  resource/security observations
  artifacts + replay command descriptor
```

晋级采用“必需项全过 + 风险阈值”而不是平均分。T0/T1 至少要求 schema/golden/metamorphic/security/resource 全过；T2 额外要求独立 feasibility checker、穷举或参考 solver 对拍；T3 额外要求 DAG、budget、failure branch 和 shadow side-effect 证明。required gate 出现 skipped、测试 corpus 与声明 domain 不匹配，均为 `INCOMPLETE`。

Shadow 评价至少覆盖：结构化失败率、与当前 active 工具的分量差异、unsupported 率、p95 wall/RSS、越权事件和 silent-empty-output。候选只能在预先冻结的窗口和阈值内比较，不能看到结果后放宽标准。小样本无法给出置信区间时维持 quarantine。

## 14. 供应链、运营与回滚

- 每个 build 生成 SBOM，记录 generator、compiler、base image、依赖 hash 和许可证；
- 依赖解析只读 lockfile/CAS，禁止构建脚本联网下载或执行未声明 hook；
- generated source 与模型输出视为不可信输入，必须过 secret、prompt injection、危险 API 和 Unicode/path 检查；
- active package 按 qualification 固定执行镜像，不在运行时重新生成；
- 指标漂移、parser format drift、escaped defect 或依赖 CVE 可触发自动 `SUSPENDED`；
- 回滚切换 Registry 指针，不覆盖旧 package；进行中的 run 记录原 qualification 并完成或由 policy 取消。

Factory 运营 SLO 首版只承诺：状态迁移可审计、build/gate 可重放、revoke 在 registry/cache 新调用路径及时生效。生成速度不是高于 correctness 的 SLO。

## 15. 首个垂直切片与完成定义

首个切片只交付两个真实 consumer：`timing report adapter` 和 `read-only path attribution analyzer`。实施顺序：

1. 手工编写同一 `CompiledRequirement` 下的 reference package；
2. 固化模板、golden raw report、单位/缺字段/格式漂移反例；
3. 生成候选并完成 build/gate/quarantine；
4. 在 Timing Lab shadow traffic 上与 reference 分量对拍；
5. 人工批准一个限定 tool version/report protocol 的 qualification；
6. 注入 parser 漂移和 escaped defect，验证 suspend/revoke/回滚传播。

完成定义：从 requirement 到 qualification 全链可由内容 hash 重放；mutation 核心逻辑可杀；空报告、域外输入和单位错配不会返回成功；shadow 无主状态写入；active 版本被撤销后新调用不可再解析到它。未满足这些条件前，不开始 T2 solver 自动生成。

## 16. 版本历史

- ai1.1（2026-07-23）：补充 package/build/qualification 身份、状态机、Requirement IR、模板 slot 边界、量化晋级、供应链和首个 Timing Lab 垂直切片。
- ai1.0（2026-07-23）：定义 T0-T5 工具生成等级、基础 package、门禁与 quarantine 流程。
