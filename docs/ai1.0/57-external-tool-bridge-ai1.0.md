<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 57 · External Tool Bridge 与语义报告适配实施方案 · ai1.1

> 当前成熟度：`D0/D1 混合`。当前 MCP `run_ieda` 使用 `shell=True` 并返回文本 success，可作为问题证据，不能作为目标实现。
>
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

## 13. PreparedJob 与隔离细节

```text
PreparedJob
  adapter/protocol/environment refs
  immutable input artifact mounts
  generated script hash + typed substitution map
  exact argv/env allowlist/workdir
  expected artifact assertions
  resource/license/timeout/cancel policy

ExternalJobResult
  execution/raw status + rc/signal/termination
  stdout/stderr/raw artifact hashes
  resource/license events
  normalization/protocol status and typed result ref
  parser field source spans + coverage
```

JobPreparer 在运行前 canonicalize 所有路径、拒绝 symlink escape、渲染受审模板并对生成脚本内容寻址。Runner 使用新 process group/container/cgroup；cancel 先 TERM grace 再 KILL，并确认所有 descendant 消失。输出目录不可预置 expected artifact，防旧文件造成假成功。

## 14. Parser qualification 与 cache

Parser 以 raw report corpus、format version、locale、tool build 和 protocol 资格绑定。每个字段保存 source span/token 和转换单位；必填字段缺失使 normalized result partial/invalid。Parser cache key 包含 raw hash/parser/schema/protocol，不同 tool version 即使报告相似也不复用。

Shadow probe 在 vendor/tool 升级时运行 old/new parser 和 sanity/differential；format drift 自动 quarantine adapter。License unavailable 与物理失败分开，重试由 Platform policy 限制。

## 15. CI 编号与 PR

`EXT-T01` argv metachar/newline，`EXT-T02` path traversal/symlink，`EXT-T03` env/secret redaction，`EXT-T04` fork child/cancel，`EXT-T05` CPU/RSS/output/disk limits，`EXT-T06` rc=0 empty/stale/truncated artifact，`EXT-T07` locale/decimal/format drift，`EXT-T08` parser source spans/units，`EXT-T09` license failure/retry，`EXT-T10` tenant/workspace isolation，`EXT-T11` cache/version invalidation，`EXT-T12` normalized-to-raw replay。

PR：`EXT-0 manifest/PreparedJob/fixed argv` -> `EXT-1 isolated runner/artifacts` -> `EXT-2 parser registry/protocol` -> `EXT-3 iEDA legacy/formal/timing adapters` -> `EXT-4 DRC/LVS/RC/power adapters` -> `EXT-5 license/cancel/quota` -> `EXT-6 drift/shadow qualification`。

## 16. Adapter SDK 与模板边界

Adapter 只实现四个插件面，Runner 核心不可由插件替换：

```text
InputMaterializer  typed refs -> immutable input tree
ScriptRenderer     typed parameters -> reviewed template output
ArtifactSpec       expected paths/types/completeness assertions
ResultParser       raw artifacts -> normalized typed result + coverage
```

插件不能启动子进程、访问 secret broker、修改 cgroup/namespace、决定重试或签发 certificate；这些由 Bridge/Platform 固定实现。模板 substitution 按类型编码：path 由 Materializer 分配，enum 来自 manifest，数值经过范围/单位校验，object list 写独立 data file；禁止把用户文本直接插入 Tcl/shell/Python 语句。

Adapter package 内容寻址并带 SBOM、license、supported tool builds、parser corpus 和 protocol tests。注册只使其 `REGISTERED`；probe/golden/security/shadow 通过后才能得到 environment-specific qualification。

## 17. Job identity、调度与 exactly-once artifact

```text
job_key = hash(adapter qualification + PreparedJob + immutable inputs + protocol)
attempt_id = job_key + monotonic attempt number
```

重复 submit 返回已有 terminal result 或附着到同一 active attempt；只有 manifest/protocol 声明可重试且预算允许时创建新 attempt。外部工具是否真正 deterministic 不影响 artifact 身份：每个 attempt 独立保存，不能用相同 job key 覆盖不同结果。

调度先原子 reserve CPU/RSS/disk/license token，再创建空 workspace。license checkout 事件与进程生命周期写 journal；worker loss 后 reconciler 查进程/容器和 license lease，不能盲目再启动。结束顺序是 stop descendants -> fsync/seal output -> collect hashes -> release license/resources -> terminal event，避免结果与配额竞态。

## 18. Protocol validation pipeline

```text
raw execution validity
  -> artifact completeness/integrity
  -> parser schema + field source spans
  -> units/report-point/scenario normalization
  -> object/rule/path mapping coverage
  -> protocol sanity/invariant checks
  -> optional differential/cross-tool checks
  -> qualified normalized result
```

每层保存独立 status，后层不能把前层 failure 覆盖成 success。ProtocolValidator 只检查声明的语义条件，例如 clocks propagated、PBA/CPPR/SI 模式、DRC rule set、power activity coverage；它不因为工具品牌或 rc=0 自动赋予 oracle 身份。

外部对象名通过版本化 mapping artifact 转成 stable ObjectId；ambiguous/unmatched 数进入 coverage。最终标量即使接近 iEDA，只要关键 path/rule/object 无法对齐，也不能用于分量对拍或 full claim。

## 19. 当前 iEDA 入口迁移切片

针对当前 `run_ieda shell=True + 文本 success`，迁移分四步：

1. Gateway 停止接收任意脚本文本，只接收 flow ID、typed config refs 和预算；
2. manifest 将 flow ID 映射到固定 binary/argv/template，Bridge 在独立 workspace 执行；
3. 收集 process status、日志、预期 DB/report artifact，并用首版 parser 返回 StageResult；
4. 新路径 shadow 对比旧路径，覆盖正常、rc 非 0、rc=0 空输出、timeout、cancel、路径注入和孤儿进程。

旧入口在兼容期只能由受信 operator 调用，标记 deprecated，不能注册为 Agent R1+ capability。新路径满足 20 类失败非 success、主工作区零写入、取消无 descendant、raw-to-normalized 可回指后，Gateway 才切换默认路由。

## 20. 外部 timing/formal 首批适配

Timing adapter 固定 netlist/liberty/SDC/SPEF、analysis mode 和 report schema，输出 path/arc/slack 分量及 scenario coverage；Formal adapter 固定 reference/revised netlist、blackbox/mapping policy，输出 equivalent/counterexample/unknown 和 compare-point coverage。二者先用于 Timing ECO shadow，不直接放宽 commit policy。

Qualification 绑定 tool build、environment、license feature、template、parser、protocol、TechContext 和 golden corpus。vendor 升级时 parallel probe old/new；任何字段漂移、默认模式改变或 failure classification 变化均 quarantine 新组合，旧组合是否继续可用由 license/security policy 决定。

## 21. 运维 SLO、事故与版本历史

指标至少包括 queue/license wait、startup/run/normalize p95、timeout/cancel latency、orphan count、resource overshoot、artifact incomplete、parser/protocol invalid、cache correctness 和 tenant isolation。物理收敛率按 tool/protocol 报告，不与平台可用率混为一项。

出现 sandbox escape、secret 泄漏、orphan process、stale artifact 假成功或 parser 错字段时立即 quarantine adapter qualification，停止新 job，保全 workspace/journal，回溯相同 qualification 的 oracle/certificate/dataset，并将最小反例加入 CI。恢复需 security/domain owner 重新批准。

- ai1.1（2026-07-23）：补充 Adapter SDK 插件边界、job 幂等与资源 journal、分层 protocol pipeline、现有 iEDA 入口迁移、timing/formal 切片和事故处置。
- ai1.0（2026-07-23）：定义 external adapter manifest、隔离执行状态机、语义归一化、parser qualification 与 CI。
