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

---

## 8. 诊断与候选数据契约

```text
FanoutDiagnosis
  snapshot/scenario/net/driver refs
  loads[] {pin_id, cap, slew_limit, criticality, location, domain}
  current topology/depth/fanout/cap/slew
  violated checks + constraint source
  dont_touch/clock/reset/power-domain risks
  coverage + evidence

FanoutProposal
  diagnosis_ref / topology_kind
  nodes[] {role, master_candidates, location_window}
  edges[] {parent, child, assigned_loads}
  predicted depth/cap/slew/setup/hold/area
  change/scope budget + required validators
```

Diagnosis 必须区分 fanout、capacitance、transition 三类 violation；一个 net 可能同时命中。约束缺失时返回 `UNKNOWN_LIMIT`，不能用硬编码 max fanout 自动修复。

## 9. Topology 生成与 master/location 选择

1. 过滤 dont_touch、clock/reset、跨电源域等受限 net；需要专用流程的返回 `UNSUPPORTED_DOMAIN`。
2. 按 load location、cap 和 criticality 生成 chain、balanced、physical-clustered 至少三类 seed。
3. 聚类树先满足每个子树 cap/fanout hard limit，再优化线长和 depth；关键 load 的路径深度作为独立目标。
4. 从 TechContext 的 buffer family 选择合法 master，校验 voltage/domain、input cap、drive 和 dont_use。
5. location 只是合法窗口/hint；最终坐标由 iPL local legalizer 决定，候选不能声称已合法。
6. 用 iEval F0/F1 预估，Top-K 才在 branch apply + RC/STA。

聚类 tie-break 使用 stable pin ID；输入容器顺序置换不得改变树。无法满足 hard limit 时输出剩余超限 loads 和冲突原因，不无限插 buffer。

## 10. Apply 与跨工具闭环

```text
acquire net/object lease
  -> verify diagnosis and proposal not stale
  -> allocate stable object IDs/names
  -> insert buffers/nets and reconnect loads atomically
  -> connectivity + power-domain sanity
  -> local legalize location windows
  -> dirty RC + common iSTA setup/hold/DRV
  -> iEval gate area/power/congestion
  -> accept candidate or rollback
```

`NoDeltaAdapter` 记录每个新 cell/net/pin、旧/新连接、实际位置、dirty timing cone 和 inverse。iNO 与 iTO 对同一 driver/net 的 lease 冲突必须返回 `STATE_CONFLICT`；不能分别修改后再尝试拼接网表。

## 11. LLD 与状态

| 模块 | 关键职责 |
|---|---|
| `FanoutDiagnoser` | 从 common constraint/timing service 构建原因和 coverage |
| `LoadPartitioner` | hard capacity 下的多策略负载分组 |
| `FanoutCandidateGenerator` | topology/master/location window portfolio |
| `NoDeltaAdapter` | 调现有 FixFanout commit 路径并生成 typed diff |
| `NoValidator` | connectivity/legal/DRV/setup/hold/area 分项结果 |

状态为 `DIAGNOSED -> PROPOSED -> APPLIED_BRANCH -> VALIDATING -> READY|REJECTED`；任一状态都绑定 snapshot head。诊断后 base 改变，proposal 为 `STALE`，禁止按名字重新定位后继续。

## 12. 测试矩阵与 PR 切片

| ID | 场景 | 断言 |
|---|---|---|
| NO-T01 | fanout 0/1/limit/limit+1/1000 | diagnosis 与限制边界正确 |
| NO-T02 | chain/balanced/clustered 手算 | depth、load assignment、cap 不丢失 |
| NO-T03 | loads 输入随机置换 | topology hash 稳定 |
| NO-T04 | dont_touch/clock/reset/domain crossing | 无越权 proposal |
| NO-T05 | master 缺失/dont_use | unsupported 而非空 success |
| NO-T06 | apply 第 k 个 reconnect 失败 | 无孤儿 cell/net，hash 恢复 |
| NO-T07 | legalize 无位置 | proposal rejected，网表回滚 |
| NO-T08 | incremental/full RC/STA | 相关 endpoint 在阈内、锥外不变 |
| NO-T09 | iNO/iTO 同 net 并发 | 恰有一方获 lease |
| NO-T10 | held-out portfolio | DRV clean 后 setup/hold/area Pareto 与 regret 可见 |

PR：`NO-0 diagnose/schema` -> `NO-1 deterministic load partition` -> `NO-2 topology/master portfolio` -> `NO-3 delta/rollback/local legalize` -> `NO-4 common RC/STA gate` -> `NO-5 iTO lease 与 benchmark`。
