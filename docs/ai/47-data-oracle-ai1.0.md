<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 47 · 数据飞轮与 Oracle 服务实施方案 · ai1.0

> 新建横向能力。复用 `benchmarks/`、商用工具与流片数据；目标是产生可追溯的配对观测，而不是堆积无法复现的报告。

## 1. 数据记录单位

```text
snapshot_before + problem_context + request
  + candidates + low_fidelity_predictions
  + selected_delta + branch_snapshot
  + high_fidelity_observations
  + accept/reject/rollback + reason
```

失败候选、超时、unsupported 和高置信错误与成功样本同等重要。

### 1.1 Data/Oracle API

```text
oracle.register(manifest)
oracle.run(request, protocol, budget)
oracle.normalize(raw_artifacts, target_schema)
dataset.create(manifest)
dataset.append(records, lineage)
dataset.validate(dataset_id, policy)
dataset.split(dataset_id, split_policy)
dataset.sample_active(dataset_id, model_state, oracle_budget)
```

`oracle.run` 不直接把外部报告当真值，必须经过 normalize 和 protocol validator。

## 2. Oracle Adapter

| adapter | 用途 | 必填上下文 |
|---|---|---|
| PT/Innovus timing | path/slack/cell/net 对齐 | scenario/PBA/CPPR/SI/units |
| StarRC/field solver | R/C pattern 与 net | tech/corner/geometry bucket |
| Calibre DRC/LVS | rule/violation/connectivity | deck/version/checked rules |
| PTPX/RedHawk | power/IR | activity/voltage/temp/grid |
| formal/LEC | 功能等价 | reference/revised 独立来源 |

Oracle 输出也可能配置错误，必须经过 protocol 和 sanity checks。

## 3. Dataset Manifest

```yaml
dataset_id: timing-eco-2026q3
samples: 120000
design_families: 18
pdks: [sky130, nangate45]
split_key: design_family
inputs_hash: ...
oracle_protocol: pt-path-v2@hash
license_and_retention: internal-only
known_issues: []
```

## 4. LLD

```text
benchmarks/data_flywheel/
  manifests/
  collectors/
  normalizers/
  validators/
  splits/
  active_learning/
  lineage/

src/platform/oracle/
  OracleRegistry.{hh,cc}
  OracleRequest.hh
  OracleResult.hh
```

## 5. 数据切分与质量

- design family、PDK、异常 topology 三层 holdout；
- 同 RTL 变体不跨 train/test；
- 训练、校准、最终门禁三套集合；
- 每条记录带 snapshot/tool/model/oracle hash；
- schema/单位/覆盖/重复/泄漏检查自动化；
- 客户数据默认不进入共享训练集。

## 6. 主动学习

F4 配额优先投向 OOD、模型分歧、Pareto 边界、接近硬 gate、高置信错误和新 PDK pattern。以“是否会改变决策”作为采样价值，不以样本数量为目标。

## 7. 里程碑

| 阶段 | 内容 | 门禁 |
|---|---|---|
| DATA-A0（2 周） | dataset/oracle manifest | 旧报告可判可用/不可用 |
| DATA-A1（4 周） | timing/RC paired collectors | 中间分量可按稳定 ID 对齐 |
| DATA-A2（3 周） | family/PDK split validator | 泄漏构造例全部检出 |
| DATA-A3（4 周） | active learning scheduler | 相同 F4 预算提升决策覆盖 |
| DATA-A4（持续） | drift/failure memory | 新 escaped error 自动入反例集 |

## 8. 红线

- 不把目录存在当数据集完成；
- 不丢失败 run；
- 不在 report point/units 不同情况下算相关性；
- 不用商业结果单向训练而不保留原始证据；
- 不跨客户复用敏感数据。

**H-DATA-A1**：主动学习相对随机采样可在相同 F4 次数下更快降低 selection regret。按冻结 holdout 做 sequential A/B，失败则回到覆盖驱动采样。
