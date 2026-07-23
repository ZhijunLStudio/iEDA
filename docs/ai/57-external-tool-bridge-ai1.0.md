<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 57 · External Tool Bridge 与语义报告适配实施方案 · ai1.0

> 当前成熟度：`D0/D1 混合`。当前 MCP `run_ieda` 使用 `shell=True` 并返回文本 success，可作为问题证据，不能作为目标实现。  
> 职责：安全执行 iEDA legacy、开源、商业和 signoff 外部工具，采集原始产物并按版本化协议归一化；`47` 决定其是否可作为 oracle，`41` 只提供 Agent transport。

## 1. 工具类别

| 类别 | 示例 | 默认角色 |
|---|---|---|
| iEDA legacy worker | Tcl/Python/current binary | 迁移 adapter |
| open-source backend | synthesis/formal/SPICE/solver | 执行或 differential oracle |
| commercial backend | timing/RC/DRC/LVS/power/IR | F4 oracle/signoff comparator |
| lab/field data importer | silicon/characterization report | calibration/validation evidence |

“可启动”不等于“语义协议通过”；“商业工具”也不自动等于真值。

## 2. API

```text
bridge.register_adapter(adapter_manifest)
bridge.probe(adapter_id, environment_ref)
bridge.prepare(request, protocol_ref)
bridge.run(prepared_job, budget)
bridge.status/cancel/resume(job_id)
bridge.collect(job_id)
bridge.normalize(raw_artifacts, parser_version, target_schema)
bridge.validate_protocol(normalized_result, protocol_ref)
bridge.quarantine(adapter_id, reason)
```

所有执行使用固定 binary/container digest、argv template 和 allowlisted workspace。普通请求不能提供任意 command/script path。

## 3. Adapter Manifest

```yaml
adapter_id: external.timing.pt@2
binary: {digest: sha256:..., probe: ["-version"]}
argv_template: ["pt_shell", "-f", "${generated_script}"]
inputs: [netlist, liberty, sdc, spef]
outputs: [raw_report, normalized_timing]
environment: {licenses: [pt], network: false}
limits: {wall_s: 3600, rss_mb: 32768}
parser: timing_pt_v2@hash
protocols: [pt-path-v2]
permissions: R1
```

generated script 只能由受审模板填 typed 参数，不能拼接 Agent 文本。adapter 声明 deterministic 条件、locale/timezone、退出码语义和 license failure 模式。

## 4. 执行状态机

```text
REGISTERED → PROBED → PREPARED → QUEUED → RUNNING
RUNNING → SUCCEEDED_RAW | PARTIAL_RAW | TIMEOUT | FAILED | CANCELLED
SUCCEEDED_RAW/PARTIAL_RAW → NORMALIZING → PROTOCOL_VALID|INVALID|UNSUPPORTED
```

process rc=0 只是 `SUCCEEDED_RAW` 的必要条件之一；expected artifacts、非空/完整性、parser/schema 和 protocol 通过后才形成可消费结果。

## 5. 语义归一化

normalizer 必须保留：

- 原始 report/log/artifact hash；
- tool/version/build、完整 argv template ID、环境/locale；
- scenario/report point/units/analysis mode；
- checked/skipped/unsupported coverage；
- parser version 和每字段 source span；
- warning/error/license/early termination 诊断。

解析器以 grammar/structured API 为先；不得只靠出现 `success`、`0 violations` 等字符串。report format drift 触发 quarantine 或 PARTIAL，不沿用旧字段默认值。

## 6. LLD 与源码落点

```text
src/platform/external_bridge/
  api/ExternalBridgeService.{hh,cc}
  registry/AdapterRegistry.cc
  execution/{JobPreparer,IsolatedRunner,ResourceMonitor}.cc
  artifact/ArtifactCollector.cc
  normalize/{ParserRegistry,NormalizedResult}.cc
  protocol/ProtocolValidator.cc
  security/{ArgvTemplate,PathPolicy,SecretBroker}.cc

adapters/external/<tool>/
  manifest.yaml templates/ parsers/ protocols/ tests/
```

短期可用独立 Python worker，但公共 request/result/schema 由 contracts 定义。执行与 iEDA 主进程隔离，避免 singleton、环境变量和 license 状态污染。

## 7. 与 40/41/47/49 的边界

| 模块 | 责任 |
|---|---|
| 40 Platform | DAG、worker 调度、资源/事件/checkpoint |
| 41 Gateway | auth、quota、transport、Agent schema |
| 47 Data/Oracle | oracle protocol、配对数据、truth/quality policy |
| 49 Verification Hub | 将合格 external result 组成 certificate/bundle |
| 57 Bridge | 外部进程、artifact、parser、protocol mechanics |

Bridge 不自行把 normalized result 标为 F4；qualification 由 Oracle/Technology/Verification 的证据共同决定。

## 8. 安全与运维

- 禁止 `shell=True`，使用 argv/execve/container API；
- workspace 路径 canonicalize + allowlist，输入只读、输出专用目录；
- secret/license 通过 broker 注入，不进入日志/artifact；
- 默认断网，若 vendor license 需网络则仅允许明确 endpoint；
- CPU/RSS/wall/file count/output bytes 限额；
- kill process group，验证取消后无孤儿进程；
- tenant/PDK/report cache 隔离；
- 原始 artifact 不经 parser 也要保留或按 retention 安全销毁。

## 9. 失败语义

| 情况 | status |
|---|---|
| binary/version 不符 | ENVIRONMENT_INVALID |
| license 不可用 | RESOURCE_UNAVAILABLE，可按 policy 重试 |
| process rc 非 0/core | FAILED |
| rc=0 但产物缺失/空 | FAILED_OUTPUT |
| timeout 有部分报告 | PARTIAL/TIMEOUT，保留 incumbent 但非 full success |
| parser format drift | NORMALIZATION_UNSUPPORTED |
| protocol point/unit 不匹配 | PROTOCOL_INVALID |
| cancel 后仍有子进程 | ISOLATION_FAILURE，adapter quarantine |

## 10. 里程碑

| 阶段 | 交付 | 退出门禁 |
|---|---|---|
| EXT-A0（2 周） | manifest/fixed argv/isolated runner | command/path injection 全拦截 |
| EXT-A1（2 周） | iEDA legacy adapter + rc/artifact | 20 类失败均非 success |
| EXT-A2（4 周） | timing/formal 两个 adapters | raw→normalized 可逐字段回指 |
| EXT-A3（4 周） | RC/DRC/LVS adapters | rule/scenario coverage 不丢失 |
| EXT-A4（3 周） | license/quota/cancel/recovery | 无超配额和孤儿进程 |
| EXT-A5（持续） | parser drift/shadow qualification | vendor 升级前后 differential gate |

## 11. 测试与可杀假说

- argv 注入、路径穿越、symlink、超大输出、fork child、locale/decimal 变化；
- rc=0 空报告、报告截断、warning-only failure、license checkout 后 crash；
- golden raw reports + parser mutation tests；
- 同 input/protocol 的 external/iEDA 分量对齐，不只比较最终一个数；
- adapter/version/parser 更新触发 cache/certificate 失效。

**H-EXT-A1**：固定协议 adapter 能在不改 legacy kernel 的前提下提供可靠 Agent 失败语义。若 parser/状态仍不稳定，则该 adapter 仅作人工诊断，不进入自动闭环。

## 12. 不做

- 不暴露任意 shell/script 工具给普通 Agent；
- 不把 process rc=0 或文本 success 当完整成功；
- 不丢原始报告只保存解析字段；
- 不把不同 report point/units/scenario 强行对齐；
- 不绕过 vendor license/数据保留政策；
- 不让外部工具直接写主 snapshot。

