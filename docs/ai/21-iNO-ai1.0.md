<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 21 · iNO Agent 网表修复实施方案 · ai1.0

> 基线：`21-iNO.md`。iNO 是 fanout/IO 修复工具，不是逻辑综合；复用现有插 buffer 路径，补诊断、树候选、事务和 iTO 冲突协调。

## 1. 首批任务

- 找出 max fanout/cap/slew 违例及根因；
- 生成链、平衡树、物理聚类树多个 proposal；
- 按关键度保证关键 loads 靠近根；
- 在 branch 中 apply、合法化、增量 RC/STA；
- 与 iTO 对同一 net 的修改使用统一 ECO lease。

## 2. API

| API | 输出/副作用 |
|---|---|
| `netopt.diagnose_fanout` | driver/load/criticality/location/violations |
| `netopt.propose_tree` | topology candidates + predicted depth/load |
| `netopt.propose_io_fix` | IO buffer proposal |
| `netopt.apply` | `NetlistDelta`，仅 branch |
| `netopt.validate` | connectivity/legal/DRV/setup/hold/area |

## 3. Proposal Schema

```text
FanoutProposal
  source_net/driver
  topology {chain,balanced,clustered}
  buffer_master/location_hints
  load_partition
  expected_depth/max_load
  touched_objects/change_budget
  unsupported_reasons
```

proposal 不生成永久名字；apply 时由 iDB 名称服务分配稳定 ID。

## 4. LLD

```text
src/operation/iNO/agent/
  FanoutDiagnoser.{h,cpp}
  FanoutCandidateGenerator.{h,cpp}
  LoadPartitioner.{h,cpp}
  NoDeltaAdapter.{h,cpp}
  NoValidator.{h,cpp}
```

现有 `FixFanout` 保留为 fallback candidate；新增 generator 不复制 buffer commit 代码。

## 5. 决策与门禁

1. 先处理硬 DRV；
2. 在满足 DRV 的候选中比较 setup/hold/area；
3. 关键 load 不能被容器顺序随机分配；
4. apply 后必须 local legalize；
5. dirty RC/STA 与 full 对拍；
6. iNO/iTO lease 冲突返回 `state_conflict`。

## 6. 里程碑

| 阶段 | 内容 | 门禁 |
|---|---|---|
| NO-A0（2 周） | diagnose/结构化 summary | 无默认静默修复 |
| NO-A1（3 周） | balanced/clustered proposal | 100-load 构造例深度/负载正确 |
| NO-A2（3 周） | transaction + legalize + STA | rollback 和 frozen scope |
| NO-A3（3 周） | iTO conflict lease | 双工具不重复修改同 net |
| NO-A4（4 周） | candidate portfolio/benchmark | DRV clean 且关键路径不退化预算 |

## 7. 测试

- fanout=0/1/阈值/1000、dont_touch、clock/reset、跨电源域；
- 无合法 buffer master 返回 unsupported；
- 链/树 depth 和 load partition 单元真值；
- apply 中途失败不留孤立 net/cell；
- summary STA 不重复全量重建的性能 trace。

**H-NO-A1**：物理聚类平衡树能在 DRV 同样 clean 时降低 worst load delay。若 held-out 设计收益不稳定，按 net class 路由模型分桶，不把单一 topology 设为默认。

