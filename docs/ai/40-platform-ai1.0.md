<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 40 · Platform Agent 工作流与执行平面实施方案 · ai1.0

> 基线：`40-platform.md`。现有 Tcl flow、ToolManager、file/report manager 可复用；`tool_flow/`、依赖契约、失败传播和 checkpoint 是主缺口。

## 1. 平台职责

Platform 是确定性执行平面，不承担 LLM 规划。它负责：

- tool manifest 注册和依赖校验；
- stage DAG、预算、资源和取消；
- structured event、status、artifact；
- checkpoint/resume 和 crash recovery；
- commit 前统一 validator；
- 旧 Tcl/Python 工具 adapter 的进程隔离。

### 1.1 Platform API

```text
platform.register_tool(manifest)
platform.validate_workflow(spec)
platform.run_workflow(spec)
platform.status(workflow_id)
platform.events(workflow_id, from_sequence)
platform.cancel(workflow_id)
platform.resume(workflow_id, checkpoint_id)
platform.get_artifacts(workflow_id, stage_id)
```

这些 API 只执行已注册工具；任意命令执行属于受限 legacy/admin 能力。

## 2. 运行模型

```text
WorkflowSpec → validate DAG/capabilities/resources
  → acquire snapshot lease
  → run stage in worker
  → validate rc + products + schema
  → emit SUCCESS/FAIL/PARTIAL event
  → update checkpoint
  → continue/abort/compensate
```

`ieda_main` 固定返回 0 的现状必须先修；否则 Agent 无法区分成功和失败。

## 3. 核心对象

| 对象 | 字段 |
|---|---|
| `ToolManifest` | name/version/inputs/outputs/requires/mutates/fidelity/cancel |
| `WorkflowSpec` | DAG、budgets、policy、base snapshot |
| `StageResult` | status、artifacts、metrics、coverage、resume |
| `Lease` | snapshot/objects/regions/expiry |
| `Event` | sequence/time/type/progress/evidence |
| `Checkpoint` | completed stages、worker state、snapshot head |

## 4. 源码落点

```text
src/platform/flow/tool_flow/
  WorkflowSpec.{hh,cc}
  FlowScheduler.{hh,cc}
  DependencyValidator.{hh,cc}
  StageRunner.{hh,cc}
  FailurePolicy.{hh,cc}
  CheckpointManager.{hh,cc}
  EventBus.{hh,cc}

src/platform/tool_manager/
  ToolRegistry.{hh,cc}
  LegacyToolAdapter.{hh,cc}
```

## 5. Stage 成功公式

```text
success = process_rc == 0
       && response_schema_valid
       && expected_products_exist_and_hash
       && declared_invariants_pass
       && no_unreported_skips
```

单纯日志出现 “success” 不计。worker crash、超时、产物空文件、schema 缺失分别编码。

## 6. 里程碑

| 阶段 | 内容 | 门禁 |
|---|---|---|
| PLAT-A0（2 周） | rc 传播 + StageResult | 20 个失败注入全部非 success |
| PLAT-A1（3 周） | ToolRegistry + DAG validator | 违序/环/缺 capability 启动前失败 |
| PLAT-A2（3 周） | artifact assertion + event bus | 每 stage 证据可消费 |
| PLAT-A3（4 周） | checkpoint/resume | kill worker 后续跑一次且结果一致 |
| PLAT-A4（4 周） | lease/resource scheduler | 并发无状态污染，license 不超额 |

## 7. 测试

- DAG cycle、缺前置、stage timeout、core dump、空产物、错误 hash；
- 同进程连续跑两设计的单例污染审计；
- checkpoint 前后随机种子/版本/状态一致；
- `commit→incr legalize→RC→STA` 补偿链失败回滚；
- event sequence 不丢、不乱序、可重放。

**H-PLAT-A1**：旧工具先以进程 worker 隔离可快速得到可靠失败语义。若启动开销占短任务 >30%，再建设常驻 worker 池，不能先恢复共享单例直调。
