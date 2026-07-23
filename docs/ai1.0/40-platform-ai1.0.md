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

---

## 8. Workflow/Stage 详细契约

```text
WorkflowSpec
  workflow_id / schema_version
  base_snapshot/intent/scenario/tech/policy refs
  nodes[] {stage_id, capability@version, inputs, expected outputs,
           reads, mutates, scope, budget, retry, compensation}
  edges[] {from, to, artifact/data/control condition}
  global budget/resource/tenant/priority

StageResult
  status = SUCCESS|PARTIAL|FAILED|TIMEOUT|CANCELLED|UNSUPPORTED
  snapshot_before/after + actual touched/dirty
  output artifacts + schema/hash/assertions
  coverage/metrics/certificate refs
  resource/termination/resume/diagnostics
```

DAG validator 在启动前检查环、缺 producer、artifact type/version、snapshot/context 不一致、写 scope 冲突、budget 汇总和 capability qualification。动态展开 node 只能引用 registry capability，并重新运行同样验证。

## 9. 调度、worker 与 artifact publish

```text
READY -> LEASE_WAIT -> DISPATCHED -> RUNNING
RUNNING -> VALIDATING_OUTPUT -> SUCCEEDED|PARTIAL|FAILED
RUNNING -> CANCELLING -> CANCELLED|ISOLATION_FAILURE
worker loss -> RECOVERING -> READY|FAILED
```

首版每个 legacy tool 在独立 process/workspace 中运行，输入只读、输出临时目录。StageRunner 收集 rc/signal/resource、验证 expected artifacts 和 response schema，再以 CAS 原子发布。rc=0 但产物空/旧/缺字段为 `FAILED_OUTPUT`。常驻 worker 只有在证明 reset/reload 跨设计无状态污染后晋级。

资源 scheduler 同时管理 CPU、RSS、wall、scratch、worker slot 和 license token；分配/释放进入 BudgetLedger。重试只适用于 manifest 声明幂等的 node，apply node 重试前确认 transaction 未发布。

## 10. Checkpoint、事件与恢复

Checkpoint 包含 workflow spec hash、completed stage results、current branch heads、durable artifacts、budget ledger、pending/running nodes 和 compatible resume tokens。恢复时重新验证 tool/version/context；不兼容 node 回到 READY 或 FAILED，不能套用旧进程内指针。

Event 使用单 workflow 单调 sequence，至少一次持久化；consumer 以 event_id 去重。progress 可丢弃/压缩，但 state transition、budget、artifact publish、failure、cancel 和 decision 事件不可丢。事件 payload 只存 refs，不复制敏感大报告。

## 11. CI 与 PR

`PLAT-T01` DAG cycle/type/producer，`PLAT-T02` rc/signal/empty/stale artifact，`PLAT-T03` stage partial/skip，`PLAT-T04` process isolation 双设计，`PLAT-T05` CPU/RSS/license budget，`PLAT-T06` cancel process group，`PLAT-T07` kill at publish/checkpoint，`PLAT-T08` event replay/duplicate，`PLAT-T09` retry idempotency，`PLAT-T10` compensation rollback，`PLAT-T11` concurrent write scope conflict，`PLAT-T12` resume version drift。

PR：`PLAT-0 StageResult/rc fix` -> `PLAT-1 ToolRegistry/DAG validator` -> `PLAT-2 isolated runner/artifact assertions` -> `PLAT-3 events/budget/resource` -> `PLAT-4 checkpoint/recovery` -> `PLAT-5 lease/concurrency` -> `PLAT-6 qualified worker pool`。

## 12. ToolManifest 与 WorkflowSpec 完整 schema

```yaml
name: timing.full_update
version: 1.0.0
maturity: D2
facets: [inspect, verify]
request_schema: timing_full_update_request@1
response_schema: timing_result@1
reads: [netlist, placement, constraints, liberty, rc]
mutates: []
scope_kinds: [design, scenario_set]
requires:
  artifacts: [netlist, liberty, sdc, rc_view]
  context: [snapshot, intent, scenario, tech]
produces:
  artifacts: [timing_result, timing_report]
  claims: [timing.setup, timing.hold, timing.drv]
fidelity: [F2, F3]
execution:
  isolation: process
  deterministic: seeded
  cancel: process_group
  resume: false
resources: {cpu: 8, rss_mb: 16384, license: []}
domain: {stages: [post_place, post_cts, post_route]}
```

Manifest 注册时完成 JSON Schema 校验、capability name/version 冲突、artifact type、context、permission、validator 和 resource unit 检查。`maturity/domain/qualification` 由 Registry 从证据计算，不信任 manifest 自报。Tool binary 或 adapter hash 是 registry revision 的一部分。

```yaml
workflow: timing_eco_candidate@1
base_snapshot_ref: sha256:...
context: {intent: sha256:..., scenarios: sha256:..., tech: sha256:..., policy: sha256:...}
nodes:
  - id: apply
    capability: state.apply_delta@1
    inputs: {delta_ref: $request.delta_ref}
    outputs: {candidate_snapshot: snapshot_ref}
    budget: {wall_ms: 2000}
    compensation: state.rollback@1
  - id: legal
    capability: placement.legalize_local@1
    inputs: {snapshot_ref: $apply.candidate_snapshot}
  - id: timing
    capability: timing.full_update@1
    inputs: {snapshot_ref: $legal.snapshot_after}
edges: [[apply, legal], [legal, timing]]
failure_policy: fail_fast_and_compensate
```

引用表达式只能访问已声明 request/node output，解析为 typed edge；不允许模板执行任意脚本或环境变量展开。

## 13. DAG 校验与调度算法

```text
validateWorkflow(spec):
  validate schema/context/base snapshot
  resolve exact capability revisions
  type-check all node inputs and artifact edges
  topological-sort; reject cycles/unreachable mandatory nodes
  compute each node read/write/scope/resource upper bound
  reject unordered write conflicts and missing compensation
  ensure every mutating node is followed by required validators
  reserve global resources/licenses
  emit immutable ResolvedWorkflow

schedule(resolved):
  ready = nodes whose dependencies have terminal acceptable status
  order by priority/deadline/critical-path then stable node id
  acquire resource tokens and snapshot/scope leases atomically
  dispatch worker; persist state before external side effect
  on completion validate output, debit budget, release resources
  activate successors or failure/compensation branch
```

调度公平性采用 tenant/experiment weighted fair queue，deadline 只能在配额内提高优先级。Resource reservation 与 branch lease 使用固定全局顺序避免死锁；等待超时返回 `RESOURCE_UNAVAILABLE`，不无限占用部分资源。

## 14. Worker wire protocol 与 StageRunner

```text
WorkerRequest
  stage_run_id / capability_revision
  immutable context and input artifact mount refs
  typed request payload
  output workspace token
  resource/cancel/deadline/trace configuration

WorkerResponse
  protocol_version / stage_run_id
  raw termination {rc,signal,reason}
  typed tool status/result
  actual touched/dirty/coverage
  output artifact candidates + hashes
  resource/progress/resume/diagnostics
```

StageRunner 的职责顺序固定：创建隔离 workspace -> materialize 只读输入 -> 启动 worker -> 采集 progress/resource -> cancel/timeout -> 等待所有 descendant -> 收集输出 -> schema/range/artifact assertion -> CAS publish -> 持久化 StageResult。工具不得自行把任意绝对路径登记为 artifact。

旧 Tcl 工具通过 `LegacyToolAdapter` 生成固定 Tcl script 和 argv，stdout 仅作为附件；成功由 rc、typed adapter result 和 artifact assertions共同决定。常驻 worker 增加 `reset(session)` protocol，并用跨设计污染 suite 资格认证。

## 15. 持久化、artifact 和 event 数据模型

| Store | Key | 持久内容 | 一致性 |
|---|---|---|---|
| workflow catalog | workflow_id | resolved spec/context/state | compare-and-swap revision |
| stage run store | stage_run_id | attempts/result/resource/error | append attempt + terminal CAS |
| checkpoint store | checkpoint_id | completed nodes/heads/ledger/tokens | content hash + durable marker |
| artifact CAS | sha256 | bytes/metadata/tenant/retention | temp-write/hash/atomic publish |
| event log | workflow_id, sequence | state/resource/artifact/failure events | append-only, at-least-once |
| lease store | resource/scope | owner/expiry/generation | fencing token |

所有状态转换先写 intent/event，再执行或发布外部副作用。Lease fencing token 随 WorkerRequest 传递，过期 worker 的迟到结果即使 rc=0 也不可 publish。Artifact metadata 记录 producer stage、schema、mime、size、retention 和 sensitivity；CAS 相同 hash 不自动授权跨 tenant 读取。

## 16. 配置与 FailurePolicy

```yaml
failure_policy: timing_eco@1
on:
  RESOURCE_UNAVAILABLE: {retry: 2, backoff: exponential, same_input: true}
  WORKER_LOST: {retry: 1, restart_from: last_checkpoint}
  PARTIAL: {action: return_to_runtime}
  INVALID_OUTPUT: {action: quarantine_capability}
  MUTATION_FAILED: {action: compensate_and_verify_base}
compensation:
  required_hash_check: true
  corrupted_branch_action: destroy
```

Retry 必须同时满足 status retryable、node idempotent 或未发布 transaction、剩余预算和相同 capability revision。Policy 不能把领域 `INFEASIBLE/VALIDATION_FAIL` 变成 transient retry。

## 17. Timing Lab 端到端时序

```text
Runtime submits 20 candidate workflows
  -> Platform validates exact manifests and reserves shared budget
  -> parallel apply/legal/dirty RC/STA within branch leases
  -> failed mutation runs compensation and base-hash check
  -> successful stages publish result/evidence refs
  -> Runtime/iEval select Top-K for F3 validation workflow
  -> Platform runs Verification plan
  -> Runtime commits exact candidate head via iDB CAS
  -> Platform closes workflows, releases leases, retains evidence
```

验收时注入 worker crash、license unavailable、event consumer断连、checkpoint 中断和主 head 冲突，验证结果仍为单一可解释 terminal state。

## 18. 模块完成定义

- `WorkflowSpec` 可从 YAML/JSON round-trip，resolved revision 完整可重放；
- DAG/type/resource/write-conflict 在执行前检出；
- 20 类失败状态不依赖日志文本；
- mutating stage 失败后 base hash 可证明恢复，否则 branch 销毁；
- kill/restart 后 workflow 不重复发布 side effect；
- event/StageResult/artifact 可离线重建执行时间线；
- 至少 Timing ECO 和只读 evaluation 两条 workflow 使用同一平台协议。
