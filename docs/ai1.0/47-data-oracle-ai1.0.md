<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 47 · 数据飞轮与 Oracle 服务实施方案 · ai1.1

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

---

## 9. Record、ingest 与 lineage 状态

```text
DecisionSample
  sample/design_family/tenant/license IDs
  base context/problem/request refs
  candidate proposal/delta/branch refs
  low-fidelity predictions + model qualifications
  high-fidelity/oracle observations + protocols
  certificates/decision/disposition/failure class
  input/build/tool/model/artifact hashes

DatasetVersion
  immutable sample refs/query/snapshot time
  schema/normalization/dedup rules
  split/family/PDK/tenant policy
  quality/leakage/known-issue reports
```

Ingest 状态为 `RECEIVED -> SCHEMA_VALID -> LINEAGE_VALID -> DEDUPED -> POLICY_VALID -> AVAILABLE`。原始记录不可就地修值；修正生成 superseding record/dataset version，保留旧 lineage。样本引用的 artifact/retention 失效会传递到派生 dataset/model qualification。

## 10. Oracle qualification 与主动学习

Oracle adapter 的资格绑定 exact tool/version/report point/scenario/parser/protocol 和 sanity suite。商业工具结果若 constraint/activity/coverage 错配同样 `PROTOCOL_INVALID`。多个 oracle 冲突时保留分量和争议状态，不投票生成假真值。

主动学习 query 仅从非 holdout pool 选取高 uncertainty、高 disagreement、near-gate、OOD 和代表性样本，并按 design family/PDK/失败类保持覆盖；oracle budget 使用 ledger。最终门禁集 ACL 隔离，在线 router/experience 不可查询其标签。

## 11. CI 测试与 PR

`DATA-T01` schema/lineage missing，`DATA-T02` duplicate/superseding，`DATA-T03` family/PDK leakage，`DATA-T04` tenant/license/retention，`DATA-T05` oracle unit/scenario/report mismatch，`DATA-T06` conflicting oracles，`DATA-T07` parser/artifact drift，`DATA-T08` active selection excludes holdout，`DATA-T09` failure/timeout/unsupported retention，`DATA-T10` dataset replay/hash，`DATA-T11` derived model invalidation，`DATA-T12` winner-only bias audit。

PR：`DATA-0 sample/dataset schema` -> `DATA-1 collector/lineage` -> `DATA-2 quality/dedup/split` -> `DATA-3 oracle registry/protocol` -> `DATA-4 active learning/budget` -> `DATA-5 retention/tenant/invalidation`。

## 12. 存储分区与不可变数据流

数据按可信处理阶段分区，禁止在同一目录中边解析边覆盖：

```text
RAW       原始输入、日志、报告、退出状态；append-only
NORMALIZED 通过固定 parser/schema 得到的 typed records
CURATED   完成 lineage、dedup、policy、质量检查的可采样记录
FROZEN    绑定 split/protocol/hash 的训练、校准或门禁版本
TOMBSTONE 依法不可再读取的引用与传播记录，不伪装物理删除已完成
```

Artifact 放 CAS，metadata/lineage 放事务索引；DatasetVersion 只保存不可变 sample refs 和 query materialization manifest。collector 失败也要写 `RunEnvelope`，其中包含 preflight、tool rc/signal、timeout/license/resource、缺失 artifact 和 retry lineage，不能只在产生 metric 时建样本。

幂等键至少包含 `source run + protocol + parser/schema`。重复 ingest 返回已有 record；修复 parser 生成 superseding normalized record，不修改 RAW，也不让旧冻结 dataset 静默漂移。

## 13. 配对、归一化与标签语义

Oracle 配对不是按名字 join。每个 `ObservationPair` 必须证明以下上下文相同或明确可转换：

```text
design_family + logical/physical snapshot
intent + scenario + tech context
analysis/report point + propagated/ideal state
PBA/GBA, CPPR, SI, RC extraction, activity semantics
unit system + object mapping protocol
```

对象对齐优先 stable ObjectId；外部工具只有名字时，通过版本化 mapping artifact 转换，并报告 `matched/ambiguous/unmatched/filtered` coverage。只要目标 hard-gate 对象无法对齐，整体相关性不能掩盖问题。

数值标签区分：`MEASURED`、`DERIVED`、`CENSORED`、`BOUND`、`MISSING`、`CONFLICTED`。timeout 不能当最差数值，未报告路径不能当 clean，低于报告阈值的结果应记录 censoring rule。聚合标签必须能回指中间分量和原始 source span。

## 14. Data Quality Report 与 split 算法

每个 frozen dataset 附带机器可读 `DataQualityReport`：

```text
schema/lineage/artifact completeness
family/PDK/stage/scenario/action/failure coverage
duplicate and near-duplicate rates
unit/range/outlier/conflict/censoring statistics
object-mapping and oracle-protocol coverage
tenant/license/retention eligibility
split leakage probes and known issues
```

split 先构造 family graph：RTL 衍生、综合网表近似、宏拓扑指纹、历史项目关系均形成不可跨边。随后按 design family 分组，再约束 PDK/topology/failure 分层覆盖。找不到满足约束的切分时明确失败，不能退回 sample-level random split。

最终门禁集使用独立 ACL、不可被 active-learning query、Planner/Experience 检索或特征统计读取。预处理统计量只在 train 内拟合，再应用到 calibration/test。任何 family 归属修订都创建新 split version 并使受影响模型 qualification stale。

## 15. 主动学习调度与预算账本

候选采样分数不直接等同模型 uncertainty：

```text
value = expected_decision_change
      * domain_coverage_weight
      * failure_information_weight
      / expected_oracle_cost
```

调度器先做 eligibility/holdout/tenant/license hard filter，再在 uncertainty、模型分歧、near-gate、OOD、代表性和失败稀缺桶之间分配配额。相同设计的高度相关候选设 batch 上限，防止预算被一个 hotspot 吞掉。

`OracleBudgetLedger` 记录 reservation、actual CPU/license/wall、cancel/refund 和超支原因。多 worker 通过原子 reservation 避免重复提交昂贵 oracle；失败/timeout 是否重试由 protocol policy 决定，不能由 collector 无限重试直到得到成功样本。

## 16. 治理、服务与漂移

- query 默认最小权限，tenant、license、retention、用途和导出目的同时鉴权；
- PDK/vendor 报告的敏感文本不进入普通 prompt、日志和共享 embedding；
- 删除请求生成 tombstone，并沿 lineage 标记 dataset/model/qualification 的可继续使用条件；
- dataset serving 返回精确 version，不提供会随时间变化的“latest”给训练或签发流程；
- 监控输入分布、failure mix、oracle disagreement、parser coverage 和 decision regret；
- drift 只触发重新评测/降级，不自动用在线数据更新 production model。

数据恢复测试必须证明索引重建后所有 frozen dataset 的 sample set/hash 一致；原始 artifact 不可用时相应记录变为 `UNVERIFIABLE`，不能靠 normalized 数值冒充可重放。

## 17. 首个垂直切片与完成定义

首个切片选择 Timing ECO 的 `candidate -> iSTA low fidelity -> external timing oracle -> accept/reject`。至少包含成功、hold regression、unsupported、timeout、parser partial 和高置信误排六类记录。

完成定义：同一 run 重复 ingest 幂等；对象/场景/单位 coverage 可对账；同 family 泄漏构造例全部被 split validator 拦截；冻结数据集可从 manifest 重建；删除或 parser/oracle qualification 变化能使派生资格失效；在固定 oracle 预算下，主动策略对 held-out pool 的 decision coverage 不差于预注册随机基线。若最后一项不成立，仍可发布数据底座，但主动学习保持实验状态。

## 18. 版本历史

- ai1.1（2026-07-23）：补充 RAW-NORMALIZED-CURATED-FROZEN 分区、上下文配对、标签语义、family graph split、预算账本、治理和 Timing ECO 数据切片。
- ai1.0（2026-07-23）：定义 DecisionSample、Oracle Adapter、Dataset Manifest、数据切分和主动学习方向。
