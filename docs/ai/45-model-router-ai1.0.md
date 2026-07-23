<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 45 · Model Registry、校准与 Fidelity Router 实施方案 · ai1.0

> 新建横向能力。复用 `src/ai/predictor` 的 ONNX 路径，但不把模型逻辑继续分散嵌入各 EDA 工具。

## 1. 职责

- 注册 heuristic、learned model、快速物理引擎和外部 oracle；
- 声明输入特征、适用域、模型/数据版本；
- 计算 OOD 和 calibrated uncertainty；
- 按风险、预算和门禁选择 F0-F4；
- 记录模型分歧和升级理由；
- 禁止 learned result 绕过硬 validator。

### 1.1 Router API

```text
model.register(manifest, artifact)
model.validate_input(model_id, feature_ref)
model.infer(model_id, feature_ref, budget)
model.route(task, context, risk_policy)
model.calibrate(model_id, calibration_dataset)
model.report_drift(model_id, observation_batch)
model.retire(model_id, reason)
```

`model.route` 返回所选 engine 和升级策略，不直接执行设计修改。

## 2. Model Manifest

```yaml
model_id: timing-ranker-v3
task: eco_candidate_ranking
input_schema: candidate_features@2
output_schema: rank_score@1
domain:
  pdks: [sky130]
  stages: [post_place]
  max_instances: 200000
calibration:
  dataset: calib-2026-08@hash
  metrics: [recall_at_20, selection_regret, ece]
runtime:
  backend: onnx-cpu
  deterministic: true
```

## 3. Router 决策

```text
validate input/domain
  → estimate risk = OOD + gate distance + action blast radius
  → choose cheapest engine satisfying risk policy
  → run and inspect uncertainty/coverage
  → escalate on disagreement, OOD, gate overlap or high-risk object
```

模型类型不决定 fidelity，实测证据决定。多个相关模型一致不等于真值。

## 4. LLD

```text
src/ai/runtime/
  ModelRegistry.{hh,cc}
  FeatureContract.{hh,cc}
  CalibrationStore.{hh,cc}
  OodDetector.{hh,cc}
  FidelityRouter.{hh,cc}
  InferenceTrace.{hh,cc}
```

首批任务：wirelength/拥塞估计 adapter、timing path/candidate ranker、RC residual calibrator。模型不得直接写 iDB。

## 5. 指标

- Recall@K、Kendall tau、selection regret；
- false-negative near gate；
- ECE/Brier/coverage-risk；
- OOD AUROC 与未知域拒答率；
- F3/F4 调用节省率；
- 高置信错误数量和错误相关性。

## 6. 里程碑

| 阶段 | 内容 | 门禁 |
|---|---|---|
| MR-A0（2 周） | manifest/registry/version | 模型与数据 hash 必填 |
| MR-A1（3 周） | feature contract + ONNX adapter | 特征陈旧检测 |
| MR-A2（4 周） | calibration/OOD | held-out family/PDK 报告 |
| MR-A3（3 周） | fidelity router | 升级决策可重放 |
| MR-A4（持续） | drift monitor/recalibration | 高置信错误触发回收 |

## 7. 红线

- 不以随机 train/test split 宣称跨设计泛化；
- 不把同 RTL 的 PDK 变体跨 split；
- 不仅报告总体 accuracy；
- 不允许缺 model/data hash 的输出进入 evidence pack；
- 不自动在线训练并直接替换生产模型。

**H-MR-A1**：ranker 可在 regret 预算内减少 ≥80% F3 候选。若做不到，缩小 domain 或只让模型做 active learning，不抬高虚假置信度。
