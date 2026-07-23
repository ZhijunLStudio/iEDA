<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 41 · Interface Agent Gateway 实施方案 · ai1.0

> 基线：`41-interface.md`。当前 Tcl 与 pybind11 接口覆盖多工具；`src/interface/mcp-iEDA` 已有 stdio/SSE server，但目前主要暴露任意脚本运行和示例运行两个工具。

## 1. 现状判断

现有 MCP 是可复用的 transport 原型，不是安全的 Agent EDA API：

- `server.py` 只注册 `iEDA_RUN`、`iEDA_RUN_EXAMPLE`；
- `run_ieda` 使用 `subprocess.run(..., shell=True)`；
- 返回文本“success”，没有 snapshot、artifact、coverage 和结构化状态；
- 用户可提供脚本路径，权限/工作区/超时未形成契约；
- Python `ieda_py` 已注册 iDB/iPL/iSTA/iRT/iTO 等模块，可作为 typed adapter 起点。

## 2. 目标分层

```text
MCP/REST/gRPC transport
  → Auth/tenant/quota/schema
  → Agent Tool Service (typed domain APIs)
  → Platform ToolRegistry/Workflow
  → pybind/C++ adapters or isolated legacy worker
```

transport 不定义 EDA 语义；同一 tool schema 可通过 MCP、Python SDK 或内部 RPC 调用。

## 3. 首批接口

| MCP tool | 权限 | 后端 |
|---|---:|---|
| `ieda.design.summarize` | R0 | observer/iDB |
| `ieda.state.diff` | R0 | design state |
| `ieda.timing.top_paths` | R1 | iSTA adapter |
| `ieda.timing.path_explain` | R1 | iSTA/iRCX |
| `ieda.experiment.run_candidate` | R2 | Agent Runtime branch |
| `ieda.experiment.status/cancel/resume` | R2 | Platform |
| `ieda.evidence.get` | R0 | artifact store |

任意 Tcl 执行保留为 `legacy.admin.run_script`，默认不向普通 Agent 暴露。

## 4. LLD

```text
src/interface/agent/
  schemas/
  ToolService.{hh,cc}
  PythonBindings.cc

src/interface/mcp-iEDA/src/mcp_ieda/
  server.py
  registry.py
  auth.py
  schemas.py
  clients/runtime.py
  tools/{state,timing,experiment,evidence}.py
```

MCP 层只做 schema 校验、认证和调用转发；不解析 EDA 文本报告，不直接拼 shell。

## 5. 安全要求

- 禁止 `shell=True` 执行用户参数；使用 argv、路径 allowlist 和固定工作区；
- PDK/netlist/report 不出租户域；
- 每个工具声明读写 scope；
- 默认无网络、限 CPU/RSS/wall、临时目录隔离；
- SSE 连接中断不取消后端任务，返回可恢复 request ID；
- 日志去除设计敏感内容，artifact 通过受控引用获取。

## 6. 里程碑

| 阶段 | 交付 | 门禁 |
|---|---|---|
| IF-A0（2 周） | 统一 Pydantic/JSON schema + typed errors | schema fuzz 无未捕获异常 |
| IF-A1（2 周） | 4 个 read-only MCP tools | 不再依赖文本 success |
| IF-A2（3 周） | experiment async/status/cancel | 断连后可恢复 |
| IF-A3（3 周） | auth/quota/sandbox | 路径穿越与命令注入测试全拦截 |
| IF-A4（4 周） | Python SDK + transport parity | MCP/SDK 相同调用结果 schema 一致 |

## 7. 测试

- 命令注入、路径穿越、超大 JSON、重复 request ID、过期 snapshot；
- stdio/SSE 断开、重连、取消；
- MCP schema 与 C++ manifest 自动一致性；
- Python adapter 与 Tcl legacy 对拍；
- 无权限 Agent 尝试写主 snapshot 必须拒绝。

**H-IF-A1**：Python binding 足以承载首批 read-only 高频查询。若序列化/跨语言拷贝占比 >10%，只对热点引入 Arrow/zero-copy，不重写全部接口。

---

## 8. 统一请求/响应 envelope

```text
AgentRequest
  request_id / idempotency_key
  capability@version
  tenant/user/roles
  snapshot/intent/scenario/tech/policy refs
  typed payload / scope / budget / deadline
  trace_context / client_schema_version

AgentResponse
  request_id / operation_id
  status + typed result or result_ref
  snapshot_before/after / touched/dirty
  coverage/uncertainty/provenance/artifacts
  diagnostics[] {code, field, retryable, details_ref}
  pagination/resume/trace refs
```

同步 read-only 小调用可直接返回；长任务固定返回 operation_id 并通过 status/events 获取。网络超时后客户端用 idempotency_key 查询原操作，Gateway 不重复提交 apply/experiment。分页 token 绑定 snapshot/query/schema，snapshot 变化后 token stale。

## 9. Schema、权限和 transport parity

Capability manifest 是 schema 单一来源，生成 JSON Schema/Pydantic/Python SDK/MCP metadata；手工 schema drift 进入 CI fail。Gateway 先认证/授权/配额，再校验 refs/payload/scope，最后调用内部 ToolService。

| 权限 | 能力 |
|---|---|
| R0 | metadata/evidence/已授权摘要 |
| R1 | 只读领域分析 |
| R2 | 创建 branch/experiment 和 branch apply |
| R3 | 提交已验证 design delta |
| R4 | intent/tech/policy/constraint 高权限变更 |

MCP、SDK、internal RPC 在同请求 manifest 下应得到语义相同的 status/result hash；transport-specific 时间和 trace 字段除外。

## 10. 安全执行与错误语义

所有外部进程转交 57 Bridge，Gateway 本身不执行 shell。PathRef 只能指向租户 artifact store；服务器 canonicalize/ACL 后解析，客户端绝对路径不进入执行。外部文本/report 标 untrusted data，不进入 system/tool schema。

错误枚举至少包括 `INVALID_ARGUMENT`、`UNAUTHENTICATED`、`PERMISSION_DENIED`、`NOT_FOUND`、`CONFLICT`、`UNSUPPORTED`、`RESOURCE_EXHAUSTED`、`DEADLINE_EXCEEDED`、`INTERNAL`；EDA 领域 status 保留在 typed result，不能全部压成 HTTP 500。

## 11. CI 与 PR

`IF-T01` schema/property fuzz，`IF-T02` unknown field/version，`IF-T03` idempotent retry，`IF-T04` pagination snapshot drift，`IF-T05` stdio/SSE disconnect/reconnect，`IF-T06` R0-R4 matrix，`IF-T07` tenant/path/symlink，`IF-T08` oversized/decompression payload，`IF-T09` log/artifact redaction，`IF-T10` MCP/SDK/internal parity，`IF-T11` rate/quota/deadline，`IF-T12` Agent 试图主状态/constraint 写入。

PR：`IF-0 envelope/error/schema generation` -> `IF-1 read-only tools` -> `IF-2 async operation/events` -> `IF-3 auth/tenant/quota` -> `IF-4 SDK/transport parity` -> `IF-5 Arrow/zero-copy only after profile`。

## 12. Capability 发布与 schema 编译

Gateway 只发布 Registry 中 `visible=true` 且调用者有权限的 capability snapshot。编译过程：

```text
CapabilityManifest + request/response schema
  -> resolve referenced common definitions
  -> generate canonical JSON Schema bundle
  -> generate Pydantic/internal RPC/Python SDK types
  -> generate MCP tool metadata and examples
  -> compare semantic schema hashes across transports
  -> publish immutable CapabilitySnapshotRef
```

Schema 只允许向后兼容的 optional field 增加进入 minor version；删除字段、改变单位/枚举/required 是 major version。Gateway 支持固定过渡窗口的多 major 版本，但每次请求解析到 exact schema hash，不能“尽力兼容”未知字段。

### 12.1 Capability 描述示例

```yaml
name: ieda.timing.top_paths
version: 1.0.0
transport_modes: [sync, async]
permission: R1
request_schema: timing_top_paths_request@1
response_schema: timing_path_page@1
max_inline_bytes: 1048576
pagination: stable_cursor
idempotency: read_only
rate_class: timing_read
```

MCP description 只描述字段语义，不嵌入使用 PDK/报告内容，不用 prompt 代替 schema validation。

## 13. 同步、异步、事件与分页协议

| 调用 | 入口 | 返回 | 规则 |
|---|---|---|---|
| sync read | `tools/call` | typed response | 仅预计在 sync deadline 内完成 |
| async | `operations.create` | operation_id | mutation/长分析默认 async |
| status | `operations.get` | state/progress/result ref | 可重试、无副作用 |
| event | SSE/stream | sequence events | 支持 from_sequence 重连 |
| cancel | `operations.cancel` | accepted/current state | 幂等，不假装已终止 |
| page | `*.list/query` | items + cursor | cursor 绑定 snapshot/query/schema |

`idempotency_key` 的索引包含 tenant、capability major、canonical request hash；相同 key 不同 payload 返回 conflict。创建操作成功但响应丢失时，客户端重试得到同 operation_id。Cancel 仅表示请求已接受，最终状态从 Platform 事件确认。

大结果超过 inline 限额返回 artifact/page refs；Gateway 不把 Arrow/JSONL 文件路径暴露给客户端，而发放短期、scope-limited artifact token。

## 14. Auth、quota 与威胁模型

```text
authenticate identity
  -> resolve tenant/project/roles
  -> capability permission and maturity filter
  -> artifact/context ownership check
  -> scope/action/policy authorization
  -> request/rate/concurrency/resource quota reserve
  -> forward signed internal principal/context
```

| 威胁 | 防线 |
|---|---|
| command/script injection | 无 shell capability；typed fields + fixed adapters |
| path traversal/symlink | artifact ref + server-side CAS，拒绝客户端路径 |
| cross-tenant ID guessing | tenant-bound opaque refs + ACL each lookup |
| prompt/report injection | 外部文本标 untrusted，不进入 tool/system instructions |
| oversized JSON/zip bomb | body/depth/items/decompressed bytes limits |
| replay/stale write | idempotency + expected_head + expiry/nonces |
| quota bypass by reconnect | quota 绑定 principal/operation，不绑定 socket |
| secret leakage | structured redaction + secret broker，不回传 env/argv secret |

R4 intent/technology/policy 变更使用独立 endpoint、审批和审计，不复用普通 experiment write API。

## 15. SDK 与 legacy 迁移

Python SDK 提供 immutable request builders、typed enums/errors、async operation handle、pagination iterator 和 artifact client。SDK 不隐藏 `PARTIAL/UNSUPPORTED`，不把 non-success 抛成无法读取结果的通用 exception；异常对象保留 status/result refs。

Legacy Tcl/Python 迁移顺序：

1. 为命令登记 fixed adapter、输入/输出和失败语义；
2. 在 isolated worker 中运行并保留 raw log；
3. normalizer 生成 typed response，与现有人工报告对拍；
4. MCP/SDK 发布 typed capability；
5. 普通 Agent 权限中移除任意脚本入口；
6. 保留 admin legacy endpoint 并独立审计。

## 16. 部署与可观测性

Gateway 可无状态扩展；operation/idempotency/quota 状态在共享持久层，artifact 不经 Gateway 内存转发大文件。每次请求记录 auth decision、schema/capability revision、quota、downstream operation 和 status，不记录完整设计 payload。

关键指标：认证/校验/下游/序列化分项 p50/p95、schema reject、permission deny、idempotency hit/conflict、active operations、SSE backlog、artifact bytes 和 redaction errors。健康检查分 transport liveness、registry readiness 和 downstream Platform readiness。

## 17. 完成定义

- `design.summarize`、`state.diff`、`timing.top_paths`、`experiment.run/status/cancel` 具备 MCP/Python parity；
- request/response schema 从同一 manifest 生成且 hash 一致；
- 断连/重试不会重复 mutation；
- R0-R4、tenant、artifact、scope 权限矩阵全覆盖；
- 普通 Agent 无 shell/script/path 执行能力；
- 大结果分页/artifact 化且不会撑爆 Gateway；
- 所有拒绝和下游领域失败可结构化区分。
