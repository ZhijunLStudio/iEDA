<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 46 · Honey 工具生成工厂实施方案 · ai1.0

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
