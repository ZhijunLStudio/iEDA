<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 10 · iDB Agent 原生设计状态实施方案 · ai1.0

> 基线：`10-iDB-database.md` 负责格式、数据完整性和商业数据库对标；本文只定义 Agent 所需的状态、增量和事务存储能力。
> 当前成熟度：D1-D2 混合。LEF/DEF/Verilog 等数据路径存在；稳定对象 ID、不可变快照、完整 typed delta 和 session 恢复尚未实现或未验证。

## 1. 产品职责

iDB 在 Agent 架构中不是“所有流程逻辑的容器”，而是唯一可信的设计对象层。它负责：

- 提供稳定对象身份和一致单位；
- 生成可内容寻址的设计快照；
- 在 base snapshot 上应用可逆 delta；
- 计算受影响对象和 dirty domain；
- 校验数据库局部/全局不变量；
- 以只读 view 服务并发分析；
- 以 artifact manifest 连接 DEF、网表、SPEF、SDC 等外部文件。

调度、预算、Agent 权限和多分支选择归 `43-agent-runtime-ai1.0.md`，不塞进 iDB。

## 2. 首批 Agent API

| API | 类型 | 输入 | 输出/副作用 |
|---|---|---|---|
| `state.inspect` | read | snapshot + object selector | typed object slice + versions |
| `state.validate` | read | snapshot + check set | checked/skipped/failed invariants |
| `state.create_snapshot` | write metadata | input manifest | immutable snapshot ID |
| `state.apply_delta` | branch write | base ID + typed delta | branch snapshot + dirty set |
| `state.diff` | read | two snapshot IDs | object-level typed diff |
| `state.rollback` | branch write | txn ID | restored snapshot/hash evidence |
| `state.compact` | maintenance | delta-chain head | compact checkpoint |
| `state.export` | artifact | snapshot + format | artifact hash + coverage report |

所有写 API 必须带 `expected_head`，过期时返回 `state_conflict`，不能覆盖新版本。

## 3. 数据模型

```text
DesignSnapshot
  id = hash(InputManifest + BaseCheckpoint + DeltaChain + Context)
  parent_id
  object_generation
  unit_system
  scenario_refs
  artifact_manifest
  invariant_summary

TypedDelta
  operation_id
  preconditions
  before_image
  after_image
  touched_objects
  spatial_bbox/layers
  dirty_domains
  inverse|checkpoint_ref
```

首批 delta：`MoveInst`、`ResizeInst`、`SwapVt`、`InsertBuffer`、`ReconnectPin`、`Add/DeleteRouteShape`、`ReplaceVia`。约束 delta 单独命名空间并默认禁用。

## 4. LLD 与源码落点

```text
src/database/manager/design_state/       # iDB 对象适配、稳定 ID、单位
  ObjectId.hh
  ObjectRegistry.{hh,cc}
  DesignView.{hh,cc}
  DbInvariantChecker.{hh,cc}

src/platform/design_state/               # 持久化与 delta 链
  SnapshotCatalog.{hh,cc}
  TypedDelta.{hh,cc}
  DeltaApplier.{hh,cc}
  DirtySet.{hh,cc}
  CheckpointCodec.{hh,cc}
  ArtifactManifest.{hh,cc}
```

关键决策：

1. 采用 64-bit stable ID + generation，禁止用裸指针跨调用；
2. 第一版 checkpoint 使用已验证的 DEF/Verilog/sidecar manifest 组合，不声称保存全部工具私有状态；
3. delta 链达到长度/读取成本阈值后 compact；
4. 只读 view 可并发，commit 串行；
5. 名字是索引而非身份，rename 后 ID 不变；
6. SDC/活动度/场景属于 snapshot context，不伪装成 iDB 几何对象。

## 5. DirtySet 契约

```cpp
struct DirtySet {
  IdSet instances;
  IdSet pins;
  IdSet nets;
  RegionSet regions;
  LayerSet layers;
  ScenarioSet scenarios;
  DirtyReason reason;
};
```

- iDB 只给出结构影响的保守超集；
- iSTA/iRCX/iRT 可扩展各自 dirty cone，但不得缩小到漏项；
- 每个 consumer 返回实际消费范围，供调试漏失效；
- 周期性 full recompute 对拍是增量能力的永久门禁。

## 6. 开发路径

| 阶段 | 周期 | 实现 | 退出门禁 |
|---|---:|---|---|
| DB-A0 | 2 周 | ObjectId、unit schema、input manifest | read-only hash 在 10 个设计稳定 |
| DB-A1 | 3 周 | snapshot catalog、state.diff | 同输入重建 hash 一致；diff 无漏项 |
| DB-A2 | 4 周 | 四类 instance/netlist delta + inverse | 500 次 apply/rollback 零主状态污染 |
| DB-A3 | 4 周 | route delta、spatial dirty set | 局部布线对象 round-trip 一致 |
| DB-A4 | 4 周 | compact checkpoint、crash recovery | kill 注入后可恢复到最后 commit |

## 7. 测试与证据

- L0：每种 delta 的前置条件、逆操作、非法 ID、generation mismatch；
- L1：随机 delta 序列 apply→rollback，snapshot hash 恢复；
- L2：iTO buffer ECO 后 fresh load 与 in-session state 等价；
- L3：两个并发只读分析 + 一个串行 commit，无 race；
- metamorphic：对象重命名不改变拓扑指标，整体平移不改变连接性；
- failure injection：写满磁盘、checkpoint 中断、错误单位、artifact 缺失必须非 success。

证据文件：`snapshot_manifest.json`、`delta.json`、`dirty_set.json`、`invariants.json`、`replay_report.json`。

## 8. 不做与可杀假说

- ai1.0 不承诺进程内存逐字节快照；
- 不把所有工具私有 cache 纳入第一版 checkpoint；
- 不允许 Agent 直接执行任意 iDB setter；
- 不在稳定 ID 和 round-trip 门禁前做跨 Agent 自动 merge。

**H-DB-A1**：base+delta 比每候选完整 DEF reload 至少快 5 倍。若在 10k 次局部 ECO 基准上不足 2 倍，优先 profile 对象复制/索引重建，而不是继续增加 delta 类型。
