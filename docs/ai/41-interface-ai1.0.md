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

