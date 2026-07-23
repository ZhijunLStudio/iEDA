<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 12 · Evaluation Agent 物理设计度量、比较与门禁实施方案 · ai1.0

> 基线：`docs/ai/12-evaluation.md`、`12-evaluation-ai1.1.md`。本版以 **2D 物理设计** 为首要范围，定义 Agent 可安全使用的 iEval；3D per-tier 指标和热/层间语义沿用 ai1.1 的梯度评估思想，待 2D 契约稳定后再扩展。
>
> 当前成熟度：现有 `src/evaluation` 的 wirelength、density、congestion、timing/power API 是可复用的 L1 传感器；snapshot 绑定、统一 QoR、候选比较、校准、门禁和 evidence pack 尚待建设。本文中的“目标”均为规划，不表示已实现。
>
> 首个垂直闭环：在 post-place/post-CTS snapshot 上，为 iTO/iNO/iPL 的局部 ECO 候选提供 F0-F3 测量、Pareto 筛选、升级验证和提交前 QoR 门禁。Runtime、iDB、Verification Hub 分别见 `43`、`10`、`49`。

---

## 0. 目标、边界与设计原则

### 0.1 目标

iEval 不是另一个 `report_*` 命令集合。它是 Agent 在物理设计优化循环中使用的、可复现的只读决策服务：

```text
observe snapshot
  -> domain tool proposes TypedDelta
  -> Runtime creates candidate branch
  -> iDB applies TypedDelta on the branch
  -> iEval measures and compares candidates at an allowed fidelity
  -> uncertain / near-gate candidates are escalated
  -> Verification Hub supplies required certificates
  -> iEval applies QoR gate and emits evidence
  -> Runtime selects or rejects; only Runtime commits
```

首版必须具备：

- 为每个值绑定 `snapshot / intent / scenario / tech / tool / unit / coverage`；
- 让 Agent 查询“此状态能测什么、用了什么近似、结果是否可比较”；
- 将低成本估计用于筛选，将 F3/F4 分析用于候选确认；
- 用硬门禁、Pareto 关系和不确定性做决策，不用隐藏的加权总分；
- 输出可重放的证据包，能解释为何升级、拒绝或无法判断；
- 用 held-out 设计族和 PDK 校准代理模型/快估，而非把训练集排名当真实能力。

### 0.2 非目标

- iEval 不修改 iDB，不生成 placement/route/ECO 动作，也不拥有 branch；
- iEval 不平行实现 iSTA、iRT、iDRC、iPA、iIR 的物理算法；它通过受控 adapter 调用这些领域能力；
- RUDY、HPWL、early STA、学习模型均不能签发 DRC clean、timing closure 等证书；
- 首版不承诺替代 foundry/commercial signoff，也不把 3D、SI、EM、thermal 纳入 post-place 闭环；
- “测不到”不是 0，“跳过”不是 clean，“模型一致”不是 oracle。

### 0.3 唯一责任

| 模块 | 负责 | 不负责 |
|---|---|---|
| iEval（本文） | metric 口径、fidelity 路由、候选比较、校准、QoR gate、evidence pack | 修改设计、签发领域 correctness certificate、提交分支 |
| iDB（10） | snapshot、TypedDelta、dirty set、状态完整性 | 候选好坏判断 |
| 领域工具（iPL/iCTS/iRT/iSTA/...） | 观测、候选、局部动作和领域计算 | 隐式接受自己的候选 |
| Verification Hub（49） | validator DAG、coverage、certificate 及失效 | PPA 排序或 reward 定义 |
| Experiment Runtime（43） | branch、预算、生命周期、选择和原子 commit | 定义 WNS、DRC 或拥塞的物理语义 |
| Observer（44） | root-cause 证据图与对象定位 | 伪造 metric 或 gate 结论 |

这条分界必须保持：**metric 改善不等于可提交；certificate 通过也不等于候选的 QoR 最优。**

---

## 1. 现状审计与首版范围

### 1.1 可复用资产

| 资产 | 当前可见能力 | Agent 化时的定位 | 首版限制 |
|---|---|---|---|
| `WirelengthAPI` | design/net/path 的 HPWL、FLUTE、HTree、VTree、GRWL | F0/F1 线长传感器 | 结果缺 snapshot、单位、输入覆盖和 stage 语义 |
| `DensityAPI` | cell/pin/net/macro-margin map 与 patch 查询 | placement/floorplan 风险传感器 | 不是 placement legality certificate |
| `CongestionAPI` | RUDY、LUT-RUDY、EGR map/overflow/utilization | F0/F1 拥塞筛选器 | EGR 依赖 iRT 产物目录；缺目录绝不能返回“拥塞为零” |
| `TimingAPI` | STA/update、WNS/TNS、pin slack、timing/power map | 过渡期 timing adapter | 最终 timing 语义归 common iSTA（27），不能另立真值 |
| `src/evaluation/apps` | 独立指标应用 | 离线对拍/调试入口 | 不作为 Agent 在线协议 |
| iPL/iPNP 消费点 | iPL 已调用 timing/WL/congestion；iPNP 有 congestion 薄封装 | L1 数值零回归保护对象 | 新层不能改变其调用时序或数值 |

现有返回结构主要是裸数值、内存对象或文件路径。例如 `TotalWLSummary`、`OverflowSummary`、`TimingSummary` 已能提供有价值的测量，但没有说明它们属于哪个 immutable state，也无法表达不支持、部分覆盖、场景差异和可比较性。因此它们只能作为 **Legacy Sensor Adapter** 的后端，不能直接暴露给 Agent。

### 1.2 首版物理设计对象与阶段

| 阶段 | 首版 iEval 问题 | 主要消费者 |
|---|---|---|
| post-floorplan | die/core/row/IO/macro 约束候选是否有明显几何和密度风险 | iFP、iPL |
| post-place | 局部 move/resize/buffer 候选是否改善 setup/hold proxy、HPWL、density/congestion，且未破坏合法性 | iPL、iTO、iNO |
| post-CTS | 候选是否改善 clock-aware timing，是否引入 latency/skew/hold 风险 | iCTS、iTO |
| post-GR | 全局布线候选的 overflow、估算 RC 和 timing trade-off | iRT、iTO |
| post-route | 局部 reroute/ECO 是否在 DRC/RC/STA 证据完整时改善 QoR | iRT、iTO、Runtime |

首个可交付不跨越 post-route signoff：它以 post-place Timing Closure Lab 为样板，动作限定为 resize、VT swap、buffer、reconnect 和局部 move；每个动作的 state/verification 契约由其他文档定义，iEval 只消费其结果。

### 1.3 分层模型

为避免“L1/L2”在不同文档中含义漂移，本文固定四层：

| 层 | 名称 | 输入/输出 | 允许用途 |
|---|---|---|---|
| E0 | Legacy Sensor | 现有 API 的裸结果 | 既有工具优化回路；数值锁回归 |
| E1 | Normalized Metric | `MetricRecord`/map，完整 provenance | Agent observe、候选快筛、趋势 |
| E2 | Decision Evaluation | compare、rank quality、calibration、regret | 决定候选是否升级或保留 |
| E3 | QoR Gate + Evidence | gate verdict、certificate refs、evidence pack | Runtime 的 selection/commit policy 输入 |

E0 不被“精确化”或改语义；E1-E3 是新增薄层。高精度领域计算仍由 iSTA/iRT/iDRC 等工具完成。

---

## 2. 面向 Agent 的需求

### 2.1 功能需求

| ID | 需求 | 优先级 | 验收要点 |
|---|---|---:|---|
| FR-EV-01 | `measure` 返回结构化、带上下文的 metric bundle | P0 | 缺 snapshot/unit/source/scenario 的记录不能入库 |
| FR-EV-02 | 按 stage、capability、预算、风险选择 fidelity | P0 | 实际档位和降档原因可见 |
| FR-EV-03 | 比较 base 与 candidate，拒绝不可比状态 | P0 | intent/tech/scenario/scope 不同不产生伪 delta |
| FR-EV-04 | 候选 Pareto、hard gate、风险和成本分离 | P0 | 禁止未声明的总分决定提交 |
| FR-EV-05 | 记录 proxy 对 F3/F4 的 rank、方向、数值和置信度误差 | P0 | 产生 held-out calibration report |
| FR-EV-06 | 根据不确定性、near-gate、OOD 和策略升级评估 | P0 | 不能以 F0/F1 跨越 hard gate |
| FR-EV-07 | 输出可重放 evidence pack 与 trend | P0 | 任一结论能定位 request、artifact、policy、tool hash |
| FR-EV-08 | 支持局部 scope 与 dirty set，安全复用缓存 | P1 | 局部结果声明 scope；不能冒充全芯片结果 |
| FR-EV-09 | 接入 iPA/iIR、post-route iDRC/RCX 与外部 oracle | P1 | `unsupported/partial` 保持原语义 |
| FR-EV-10 | 维护 E0 兼容及 L1-L2 对拍 | 红线 | iPL 既有 L1 数值回归为零 |

### 2.2 非功能需求与纪律

| ID | 要求 |
|---|---|
| NFR-EV-01 | 读 API 只接受 immutable `snapshot_ref`，不读取“当前全局设计”。 |
| NFR-EV-02 | 每个 metric 都有值域、单位、source、coverage 和 fidelity；禁止裸 `double` 穿越 Agent 边界。 |
| NFR-EV-03 | 相同 request、snapshot、工具/模型版本和 seed 应产生可重放结果；非确定性须记录重复统计。 |
| NFR-EV-04 | 任何 `PARTIAL`、`UNSUPPORTED`、`TIMEOUT` 或 coverage 缺口不能被序列化成 PASS。 |
| NFR-EV-05 | Cache key 必含 state/context/adapter 参数；不跨 intent、tech、scenario 复用。 |
| NFR-EV-06 | budget 由 Runtime/Policy 传入且记录，评估器不得用自己的实际结果反填门限。 |
| NFR-EV-07 | 新建适配层不引入对 E0 singleton 的并发裸访问；必要时由 worker/session 串行化旧 API。 |
| NFR-EV-08 | 性能承诺须在冻结 benchmark protocol 后以多次重复的 median/MAD 发布；首版先测量，不杜撰绝对目标。 |

### 2.3 三个必须回答的问题

每次调用返回的数据都必须能回答：

1. **测的是什么？** 指标定义、scope、单位、场景、覆盖率和输入工件。
2. **为何可信到这个程度？** 具体 estimator/tool、fidelity、版本、校准证据、OOD/不确定性。
3. **能据此做什么？** 仅排序、需要升级、可进入下一阶段，或因 certificate/gate 不完整而不可提交。

---

## 3. 总体架构与数据流

### 3.1 组件图

```text
             iFP / iPL / iCTS / iRT / iTO / iNO
                inspect/propose/apply on branch
                                 |
                    EvaluationRequest (read-only)
                                 v
  +--------------------------------------------------------------+
  |                    iEval Agent Evaluation                    |
  |  RequestValidator -> Capability/FidelityRouter -> MetricCache|
  |          |                     |                              |
  |          +---- MetricCollector / Legacy Sensor Adapters -----+
  |                                |                              |
  |   Comparator <- MetricBundle <- iSTA/iRT/iDRC/iPA/...         |
  |       |                                                        |
  |  RankQuality + Calibration + GateEngine -> EvidencePack       |
  +-------------------------------+------------------------------+
                                  | metric/gate evidence
                                  v
  Verification Hub: certificates ----> Runtime: select / commit
```

`FidelityRouter` 只选择已注册、适用于当前 stage/scope 的估算器；它不得将“调用成功”解释成物理有效。`GateEngine` 只判定 QoR policy，所需 correctness certificate 是否齐全由 Verification Hub 的 bundle 表达。

### 3.2 单次测量数据流

```text
request validation
  -> resolve immutable context and capability manifest
  -> resolve metric definitions and eligible adapters
  -> cache lookup by complete context key
  -> run adapter(s) in declared worker/session
  -> normalize value, unit, coverage, provenance and uncertainty
  -> schema/range/semantic validation
  -> persist MetricBundle and artifacts by content hash
  -> return SUCCESS | PARTIAL | UNSUPPORTED | TIMEOUT | FAILED
```

执行失败、缺工件、stage 太早、规则不支持均是可预期状态，必须给出结构化 diagnostics；不可静默退回默认 scenario、默认路径或空 map。

### 3.3 核心设计决策

| 决策 | 选择 | 原因 |
|---|---|---|
| 状态绑定 | 每次请求显式 `snapshot_ref` | 消除 singleton/current design 漂移 |
| 结果粒度 | vector/map + scalar，保留分量 | 使拥塞热点、clock/skew、setup/hold 可归因 |
| 选择逻辑 | 先 hard gate，后 Pareto，再按显式 policy 打破平局 | 不用一个总分掩盖 DRC/hold 风险 |
| F0-F4 | 估计可筛选，F3/F4 才可支持高风险决策 | 成本和真实性分层 |
| 低精度质量 | 用 held-out regret/recall/calibration 管理 | 数值 MAE 小不保证选对候选 |
| 旧 API | adapter 隔离、数值锁回归 | 不冲击 iPL 等已接线消费者 |
| evidence | CAS ref + manifest，而非文本日志 | 让 decision 可复放、可审计 |

---

## 4. 统一契约与 schema

### 4.1 `EvaluationRequest`

所有对外 API 共享以下最小上下文；调用方不能以全局变量、省略的 scenario 或文件路径代替 ref。

```yaml
request_id: uuid
capability: eval.measure@1
snapshot_ref: sha256:branch-snapshot
intent_ref: sha256:constraints-and-objectives
scenario_set_ref: sha256:mcmm-scenarios
tech_context_ref: sha256:pdk-lib-rc
policy_ref: sha256:eval-policy
stage: post_place
scope:
  kind: design                 # design | region | object_set | path_set | net_set
  ref: cas:scope-definition
metrics: [timing.setup.wns, timing.setup.tns, wirelength.hpwl, congestion.rudy_peak]
fidelity:
  requested: F1                # F0 | F1 | F2 | F3 | F4 | AUTO
  allow_downgrade: false
budget: {wall_ms: 1000, cpu_ms: 2000, memory_mb: 1024}
seed: 17
```

约束：

- timing、power、IR 类请求必须带 `scenario_set_ref`；无场景只能返回 `UNSUPPORTED`，不能选择“当前 clock”；
- route/RC 相关请求必须提供对应 artifact manifest；不能从工作目录猜测 `guide`、SPEF 或 EGR CSV；
- `AUTO` 仅可在 policy 显式允许时选取最高可用档；显式 F3 不允许被悄悄降为 F1；
- 每次请求的 scope 必须可解析为 stable object ID/region/layer 集合，名称只是索引。

### 4.2 `MetricRecord`

```json
{
  "metric_id": "timing.setup.wns",
  "definition_version": "1.0.0",
  "value": -83.0,
  "unit": "ps",
  "direction": "higher_is_better",
  "status": "MEASURED",
  "snapshot_ref": "sha256:...",
  "intent_ref": "sha256:...",
  "scenario_set_ref": "sha256:...",
  "tech_context_ref": "sha256:...",
  "scope": {"kind": "design", "ref": "cas:scope/..."},
  "fidelity": {"requested": "F3", "used": "F3", "estimator": "ista.full_update"},
  "coverage": {"checked": 12034, "skipped": 0, "unsupported": 0, "details_ref": "cas:..."},
  "uncertainty": {"kind": "none", "value": null, "calibration_ref": null},
  "provenance": {"tool_binary": "sha256:...", "model": null, "input_artifacts": ["sha256:..."]},
  "runtime": {"wall_ms": 438, "seed": 17},
  "artifact_refs": ["cas:report/..."]
}
```

字段规则：

- `value` 只在 `MEASURED` 或可定义的 `PARTIAL` 分量中存在；`UNSUPPORTED`、`FAILED`、`NOT_APPLICABLE` 不可用 0 代替；
- 单位在 metric definition 中固定，边界层完成 DBU/ns/mW 等转换并记录原始单位；
- `coverage.checked + skipped + unsupported` 的含义由每个 definition 定义，禁止跨指标相加；
- `uncertainty.kind=calibrated` 必须有 held-out `calibration_ref`；未校准代理使用 `not_calibrated`；
- map、top-K paths、热点列表等大对象只放 artifact ref，主记录保持可索引。

### 4.3 `MetricBundle`、比较与门禁结果

```text
MetricBundle
  bundle_id, request/context refs, status
  metric_records[], completed_scope, remaining_scope
  cache_state, diagnostics[], artifact_refs[]

ComparisonResult
  base_bundle_ref, candidate_bundle_ref, comparability
  deltas[] {metric_id, absolute, relative, direction, significance}
  dominance = BASE | CANDIDATE | NON_DOMINATED | EQUIVALENT | UNKNOWN
  required_escalations[], diagnostics[]

GateResult
  policy_ref, candidate_snapshot_ref
  verdict = PASS | FAIL | INCOMPLETE | NOT_COMPARABLE
  checks[] {id, severity, result, evidence_refs, reason}
  certificate_bundle_ref, metric_bundle_refs[]
  publishable, required_actions[], evidence_pack_ref
```

`PASS` 仅表示“满足该 QoR policy”，不自动表示 Runtime 可提交；Runtime 仍必须检查对应 certificate bundle、branch head 和权限。`INCOMPLETE` 与 `NOT_COMPARABLE` 默认均不可提交。

### 4.4 可比较性规则

只有以下条件全部满足，`eval.compare` 才能产生数值 delta：

1. metric definition、单位、scope 和聚合方法相同；
2. intent、tech、scenario、activity/context ref 相同，或 policy 明确声明等价映射；
3. fidelity 与 estimator 相同，或已批准的 cross-fidelity calibration 覆盖该 domain；
4. base/candidate 均有足够 coverage，且 `PARTIAL` 的完成范围完全相同；
5. 对随机算法，seed 或重复统计协议相同；
6. route/RC、规则 deck、输入 artifact 的版本没有隐式漂移。

否则返回 `NOT_COMPARABLE` 并列出冲突 ref；例如修改 SDC 后的 WNS 只能建立新 baseline，不能宣称 ECO 改善。

---

## 5. Agent Capability API

| API | 类型 | 输入 | 输出 | 副作用 |
|---|---|---|---|---|
| `eval.capabilities` | read | context/stage | 可用 metric、fidelity、前置工件和 domain | 无 |
| `eval.measure` | read | `EvaluationRequest` | `MetricBundle` | 仅写 cache/artifact/trace |
| `eval.compare` | read | 两个 bundle + policy | `ComparisonResult` | 无 |
| `eval.screen_candidates` | read | base + candidate refs + budget | 保留集、淘汰原因、升级队列 | 无 |
| `eval.rank_quality` | offline/read | proxy prediction + oracle labels | Recall@K、regret、sign accuracy | 写 calibration artifact |
| `eval.calibrate` | offline | frozen train/validation protocol | calibration model/domain/card | 版本化 model artifact |
| `eval.gate` | read | candidate metrics + certificate bundle + policy | `GateResult` | evidence pack |
| `eval.emit_evidence` | read | request/result refs | content-addressed evidence pack | 写 artifact |
| `eval.invalidate` | metadata | invalidation event | stale cache/certificate dependency notice | 不改设计 |

### 5.1 `eval.capabilities`

Agent 在调用前先问 capability，而不是猜测“某工具也许能跑”。示例输出：

```yaml
stage: post_place
available:
  - metric: wirelength.hpwl
    fidelity: [F0, F1]
    requires: [placement]
  - metric: congestion.rudy_peak
    fidelity: [F0, F1]
    requires: [placement, routing_resources]
  - metric: timing.setup.wns
    fidelity: [F1, F2, F3]
    requires: [sdc, liberty, placement, scenario_set]
  - metric: route.drc.count
    fidelity: []
    status: NOT_APPLICABLE
    reason: detail_route_artifact_missing
```

这里的“不适用”是有价值的决策信息，Runtime 应据此改变 stage、补足工件或升级工作流。

### 5.2 `eval.screen_candidates`

该 API 的默认过程固定如下：

```text
1. 验证每个 candidate 与 base 的 context、scope、branch head。
2. 运行 cheap structural/QoR checks；任一 hard risk 明确失败即淘汰。
3. 用 F0/F1 计算可比较的 metric vector，保留非支配候选。
4. 对 near-gate、高不确定性、OOD 或 top-K 候选按策略升级 F2/F3。
5. 合并同 fidelity 的比较；记录被淘汰、保留、升级的每个理由。
6. 预算耗尽时返回当前 Pareto set 和 `INCOMPLETE`，不擅自选择或提交。
```

`screen_candidates` 不可接受一个黑盒 `score` 参数。若产品确实需要偏好（例如 WNS 优先于面积），偏好必须位于版本化 policy 中，并在 evidence pack 写出阈值、tie-break 顺序和适用 stage。

---

## 6. 物理设计指标、fidelity 与路由

### 6.1 Fidelity 语义

| 档 | 定义 | 可用于 | 不可用于 |
|---|---|---|---|
| F0 | 几何/拓扑/解析近似，如 HPWL、density、RUDY、fanout/logic-depth proxy | 大量候选粗筛、热点发现 | hard gate、signoff claim |
| F1 | 已校准的快估或受限模型，如 LUT-RUDY、估算 RC/STA、learned ranker | 候选排序和升级决策 | 证书、未校准 domain 的阈值判断 |
| F2 | 有界的真实内核，如局部 legalize、early GR、dirty-cone timing | Top-K 验证、局部风险判断 | 全局/全场景完整性声明 |
| F3 | 当前 iEDA 流程的完整领域分析，如 full iSTA、GR/DR、iDRC、iPA/iIR | stage gate 的度量证据 | 外部 signoff 等价声明 |
| F4 | 独立 oracle/外部 signoff 或经批准的高保真对拍 | 校准、发布前抽样/强制 policy | 高频搜索回路 |

“最高 fidelity”不等于“总是更好”：若输入 coverage 不足、上下文不一致或工具 domain 外，F3/F4 仍应返回 `PARTIAL/UNSUPPORTED`。

### 6.2 指标目录

| 指标族 | metric id 示例 | 首选后端 | 关键语义 |
|---|---|---|---|
| 几何/合法性 | `placement.overlap_area`、`placement.row_violation_count` | iPL/iDB/Verification Hub | 为 correctness claim 提供输入，不把近似 density 当合法性 |
| 线长 | `wirelength.hpwl`、`wirelength.flute`、`wirelength.gr`、`wirelength.routed` | `WirelengthAPI`、iRT | DBU/um 固定；明确估计线长或实际线段长 |
| 密度/拥塞 | `density.cell_peak`、`congestion.rudy_peak`、`congestion.egr_tof`、`congestion.gr_overflow` | density/congestion、iRT | `demand/capacity` 与 map grid/layer 版本必须入 provenance |
| 时序 | `timing.setup.wns`、`timing.hold.wns`、`timing.setup.tns`、`timing.drv.count` | common iSTA | setup/hold、corner、mode、path group 分开，ps 统一 |
| 时钟 | `clock.skew.max`、`clock.latency.max`、`clock.transition_violation_count` | iCTS + iSTA | 不能被 data-path WNS 抵消 |
| 布线/DRC | `route.wirelength`、`route.via_count`、`route.drc.<rule>.count` | iRT/iDRC | rule deck、checked/skipped rule 清单必填 |
| 功耗/IR | `power.total`、`power.dynamic`、`ir.drop.peak` | iPA/iIR | activity source、scenario、PDN/temperature context 必填 |
| 成本 | `runtime.wall`、`memory.rss_peak`、`action.disruption` | Runtime/tool trace | 不是 PPA，不能覆盖物理 hard gate |

### 6.3 阶段 x 指标 x 默认路由

| stage | F0/F1 搜索 | F2 确认 | F3 gate 的可用目标 |
|---|---|---|---|
| post-floorplan | macro/IO HPWL、density、macro margin、util proxy | iPL GP + early congestion | floorplan geometry/row/IO 相关检查；无 route/DRC clean 声明 |
| post-place | HPWL/FLUTE、density、RUDY/LUT-RUDY、timing proxy | local legalize + early GR + dirty timing | placement legality、full relevant-scenario iSTA、可用时 early routing 风险 |
| post-CTS | data/clock proxy、clock load/HPWL | clock local route + incremental common STA | setup/hold、skew/latency/transition/load 的完整 declared scope |
| post-GR | GR WL、EGR/GR overflow、估算 RC | affected-net GR + dirty RC/STA | GR resource/overflow、F3 timing；DRC 仍按 policy 标记未完成 |
| post-route | routed WL、DRC hotspot、RC timing proxy | local detailed reroute + incremental DRC/RC | iDRC declared rule scope、extracted RC、full iSTA、power/IR（若 policy 要求） |

路由表是 `FidelityRouter` 的唯一事实来源。每个单元不是硬编码“必须有值”，而是 `available / requires / fallback / forbidden_claim` 的注册条目。比如 placement 阶段可以用 RUDY 进行排序，但 `route.drc.count` 必须为 `NOT_APPLICABLE`。

### 6.4 路由算法

```text
route(request):
  candidates = registry.find(metric, stage, scope, tech, scenario)
  eligible = candidates.filter(input_artifacts_complete && capability_qualified)
  if requested fidelity is explicit:
      choose exact eligible fidelity
      if none and !allow_downgrade: return UNSUPPORTED
      else choose nearest lower fidelity and mark PARTIAL
  if AUTO:
      choose highest eligible fidelity within budget and policy ceiling
  if uncertainty/OOD/near_gate requires more than selected:
      return escalation requirement, not a fake precise value
  return adapter + actual fidelity + precondition evidence
```

Fidelity 改变、adapter 替换、模型版本变化均会改变 result key；不可只因“同叫 WNS”而复用旧结果。

---

## 7. 比较、校准与 QoR 门禁

### 7.1 比较与 Pareto

每个候选先经过同等 context 下的可比较性检查，再形成 metric vector。候选 A 支配 B 的条件是：在 policy 指定的所有软目标上不差、至少一个严格更好，且两者均已通过相同 hard gate。任何一方的 `UNKNOWN/PARTIAL` 会阻断相应维度的支配结论。

最终候选进入提交前 gate 时，顺序固定如下：

```text
context/schema validity
  -> certificate bundle complete/current
  -> connectivity / frozen-scope / legality hard gates
  -> setup / hold / DRV / DRC / IR hard gates required by stage policy
  -> coverage and uncertainty gates
  -> Pareto frontier on timing, congestion, WL, power, cost
  -> explicit policy tie-break: smaller disruption, stronger evidence, lower cost
```

面积、功耗、WNS 改善都不能抵消 hold 失败、范围外改动、缺失 DRC rule 或 context 不可比。Policy 可以按阶段配置门限，但不得允许 proposal 自行删除必需检查。

F0/F1 预筛阶段只执行 context/schema 和 policy 声明的低成本检查，不要求每个粗筛候选先生成完整 certificate bundle；其输出状态只能是“淘汰、保留或待升级”，不能是“可提交”。完整 certificate 和 hard gate 只对进入最终选择集合的候选执行。

### 7.2 Gate profile 示例

```yaml
profile: timing_eco.post_place@1
hard:
  - state.integrity: {source: certificate, required: PASS}
  - objects.frozen: {source: certificate, required: PASS, scope: complement_of_delta}
  - placement.legal: {source: certificate, required: PASS, scope: dirty_region_plus_halo}
  - timing.setup.wns: {source: metric, fidelity_min: F3, relation: non_regress, tolerance_ps: 0}
  - timing.hold.wns:  {source: metric, fidelity_min: F3, relation: non_regress, tolerance_ps: 0}
  - timing.drv.count: {source: metric, fidelity_min: F3, relation: non_increase}
soft:
  - timing.setup.wns: {fidelity_min: F3, direction: higher}
  - wirelength.hpwl: {fidelity_min: F1, direction: lower}
  - congestion.rudy_peak: {fidelity_min: F1, direction: lower}
  - action.disruption: {direction: lower}
unknown_policy: reject
escalate_if:
  - abs(delta.timing.setup.wns) < 5ps
  - uncertainty.crosses_gate: true
  - model.ood: true
```

数值只是示例，不是全局阈值。实际 `tolerance_ps`、场景集和 activity 要由 design/PDK/policy owner 冻结，任何调整都会产生新的 `policy_ref`。

### 7.3 代理质量与校准

F0/F1 的价值取决于它能否减少 F3 调用且不漏掉好候选或坏候选。`eval.rank_quality` 至少输出：

| 任务 | 指标 | 失败含义 |
|---|---|---|
| Top-K 候选筛选 | `Recall@K`、关键坏候选 false-negative | 好候选被 F0/F1 错杀，或风险候选被放行 |
| 候选选择 | `selection_regret = oracle(best) - oracle(selected)` | 排序看似正确但最终选错 |
| 改善方向 | sign accuracy、按 action/stage 分桶 | 把恶化预测为改善 |
| 数值代理 | MAE、P95、bias、worst bucket | 近门限时不可安全使用 |
| 置信度 | ECE、Brier、coverage-risk | “90% 置信度”没有实际含义 |
| OOD | in-domain/OOD 覆盖与失败率 | 新 PDK/新设计族被错误外推 |

训练、调参和最终报告必须以设计族、PDK、动作类别分组切分；同一设计的邻近 snapshot、派生候选或同一 netlist 的不同 seed 不能同时出现在 train 与 holdout。任何校准卡须记录 oracle、样本分布、适用范围、失效日期和 model hash。

### 7.4 升级策略

满足任一条件必须升级或返回 `INCOMPLETE`：

- metric delta 接近 policy 门限，置信区间跨越 gate；
- candidate 位于 F0/F1 Pareto frontier，且将参与 selection；
- learned/proxy model 判断 OOD 或没有适用 calibration；
- 动作触及 clock/reset、约束、PG、跨区域冻结边界等高风险对象；
- F0/F1 与上一次 F3 的方向冲突，或 cache/coverage 有缺口；
- policy 对该阶段明确要求 F3/F4。

若预算不足，服务返回保留的候选集和所需 F3 检查清单；不返回一个貌似完整的 winner。

---

## 8. 缓存、失效与证据

### 8.1 Cache key 与 immutable snapshot

```text
MetricCacheKey = hash(
  snapshot_ref, intent_ref, scenario_set_ref, tech_context_ref,
  metric_definition, scope_ref, stage, fidelity/adapter/params,
  tool_binary_hash, model_hash, input_artifact_hashes, seed
)
```

最保守的策略是不同 `snapshot_ref` 不复用数值。后续可通过 iDB 的 `DirtySet` 实现局部增量，但只能在 adapter 声明的 dependency domain 内复用，并且必须在结果中标记：

| delta 影响 | 可能失效的 E1 metric | 允许保留的例子 |
|---|---|---|
| move/resize/swap cell | local density、HPWL/FLUTE、congestion、timing、power | 不相关 region 的只读 floorplan geometry（有证明时） |
| insert buffer/reconnect | connectivity、timing、power、placement、route/RC | 未触及的 tech metadata |
| add/delete route shape/via | route WL、DRC、RC、timing、IR/EM | placement density |
| PDN/activity/context change | power、IR、thermal、相关 timing derate | 纯几何 WL |
| SDC/liberty/corner/rule deck change | timing/DRV、DRC、所有比较基线 | 无；新 context 重新测量 |

Dirty set 是保守下界，领域工具可扩大但不可缩小。E0 singleton 的 cache 不能被当作跨 snapshot 事实；adapter 必须用 session lock、worker 隔离或完整重建来防止全局状态污染。

### 8.2 Evidence pack

每个 `GateResult` 生成以下内容寻址清单：

```text
evidence_pack.json
  request + resolved context + policy refs
  base/candidate snapshot refs and TypedDelta ref
  MetricBundle/ComparisonResult refs
  certificate bundle ref and freshness check
  fidelity routing and escalation decisions
  tool/model/binary/input artifact hashes
  gate checks, thresholds, verdict and diagnostics
  Runtime budget/seed/repetition statistics
  replay command manifest (no ambient working-directory inputs)
```

文本报告、热图、top-path、EGR/DRC map 是 evidence pack 的附件，而不是唯一事实源。任何 artifact 丢失或 hash 不一致都会使 pack `UNVERIFIABLE`。

### 8.3 趋势与基线

Flow 每个阶段可调用 `eval.measure` 形成 `metrics_snapshot.json`；聚合器只在上下文可比较时生成 `metrics_trend.json/csv`。趋势必须保留阶段、fidelity 和 coverage，不能将 post-place F1 WNS 与 post-route F3 WNS 连成假装连续的单一曲线。

---

## 9. LLD：模块、接口与适配边界

### 9.1 源码落点

首版在现有 `src/evaluation` 内新增层，不移动 E0 内核：

```text
src/evaluation/
  api/
    agent_evaluation_api.{hh,cc}          # 唯一 C++ facade；不暴露 singleton
  database/
    metric_record.{hh,cc}
    evaluation_bundle.{hh,cc}
    evaluation_policy.{hh,cc}
  src/agent/
    request_validator.{hh,cc}
    metric_registry.{hh,cc}
    fidelity_router.{hh,cc}
    metric_collector.{hh,cc}
    metric_cache.{hh,cc}
    comparator.{hh,cc}
    pareto_selector.{hh,cc}
    gate_engine.{hh,cc}
    calibration/{rank_quality,calibration_store,ood_guard}.{hh,cc}
    evidence/{evidence_pack,trend_writer}.{hh,cc}
    adapters/
      legacy_wirelength_adapter.{hh,cc}
      legacy_density_adapter.{hh,cc}
      legacy_congestion_adapter.{hh,cc}
      legacy_timing_adapter.{hh,cc}
      sta_adapter.{hh,cc}
      route_adapter.{hh,cc}
      drc_adapter.{hh,cc}
      power_ir_adapter.{hh,cc}
  test/agent_evaluation/
  CMakeLists.txt                            # target: eval_agent

benchmarks/qor/
  schemas/{metric_record,evaluation_policy,evidence_pack}.json
  protocols/{screening,calibration,parity}.yaml
  datasets/                                 # manifest only; large artifacts in CAS
  reports/
```

`summary_db` 目前是空壳，不作为新接口的事实来源。EV-A0 必须决定删除、弃用标注或迁移为上述 schema 载体；在决定前禁止另起第二套同名 summary 结构。

### 9.2 关键类职责

| 类/模块 | 职责 | 不可做的事 |
|---|---|---|
| `RequestValidator` | 校验 refs、scope、budget、policy、必需工件 | 猜默认 scenario/路径 |
| `MetricRegistry` | metric definition、单位、方向、可用 stage、adapter registration | 让 tool 私有字段成为公共语义 |
| `FidelityRouter` | 选择合格 adapter，输出降档/升级理由 | 改写 policy 或抹掉风险 |
| `MetricCollector` | 调 adapter，组装 normalized record | 直接访问未隔离的全局设计 |
| `Comparator` | 可比较性、delta、统计显著性 | 跨 context 做相对改善 |
| `ParetoSelector` | 非支配筛选、稳定 tie-break 输入 | 隐式加权总分 |
| `GateEngine` | 根据 policy 评价 metric/certificate evidence | 签发 certificate 或 commit |
| `CalibrationStore` | 保存 domain/model/card/held-out 统计 | 使用未冻结数据泄漏报告 |
| `EvidencePackBuilder` | 完整血缘与可重放 manifest | 只引用人读日志 |

### 9.3 Adapter contract

```cpp
class IMetricAdapter {
 public:
  virtual AdapterManifest manifest() const = 0;
  virtual Availability check(const EvaluationRequest&) const = 0;
  virtual AdapterResult measure(const EvaluationRequest&, EvaluationSession&) = 0;
  virtual DependencySet dependencies(const EvaluationRequest&) const = 0;
};
```

`AdapterManifest` 声明 metric definition、fidelity、stage、scope、输入 artifact、是否 deterministic、支持 partial/cancel、校准域和不允许签发的 claim。`AdapterResult` 先保留原始输出与工件，再由 `MetricCollector` 完成单位/coverage/provenance 的统一。适配器无法说明 coverage 时，必须返回 `PARTIAL` 或 `UNSUPPORTED`。

### 9.4 现有后端接入顺序

| Adapter | 第一个能力 | 必须补的契约 | 风险控制 |
|---|---|---|---|
| legacy WL | F0 `wirelength.hpwl/flute` | DBU、placement snapshot、net/path scope | 与旧 API 同输入数值对拍 |
| legacy density | F0 peak/avg/map | grid、region、macro/blockage 语义 | 不用于 legal claim |
| legacy congestion | F0 RUDY/LUT-RUDY，F2 EGR/GR | grid/layer/capacity、iRT artifact manifest | 缺目录响亮失败；不读 ambient output path |
| common STA | F2/F3 WNS/TNS/DRV/path set | scenario、RC、incremental/full scope、coverage | 语义唯一归 iSTA；setup/hold 分开 |
| route/DRC | F2/F3 overflow/DRC/routed WL | net/layer/rule scope、skipped rules | `skipped` 不能 clean |
| power/IR | F2/F3 power/IR | activity、PDN、temperature、scenario | 无 activity/context 返回 partial |

---

## 10. 三个首批工作流

### 10.1 post-place Timing ECO 候选筛选

```text
1. Observer/iSTA 给出 top violating path 与 dirty object set。
2. iTO/iNO/iPL 在最多 N 个 branch 生成 TypedDelta；Runtime 固定 base/context/budget。
3. iEval F0/F1 计算 HPWL、density/RUDY、timing proxy 和 disruption。
4. 淘汰明确 worsening 或 scope/coverage 不完整者，保留 Pareto Top-K。
5. 对 Top-K 做 local legalize + F2 dirty-cone timing；near-gate 或 top candidates 升 F3 full iSTA。
6. Verification Hub 检查 frozen objects、connectivity、placement legality、setup/hold/DRV。
7. iEval gate 输出 candidate 的 QoR verdict/evidence；Runtime 才可 select/commit。
```

验收不是“Agent 找到改善动作”这一句，而是：每一个拒绝/保留/升级动作均可由 evidence pack 重放；F1 选出的 winner 对 F3 oracle 的 regret、关键 path 漏报率和调用成本均有统计报告。

### 10.2 post-CTS useful-skew/clock ECO

Clock 类候选默认高风险：F0/F1 只用于生成/预筛，所有可提交候选必须在 common iSTA 的 setup、hold、clock latency/skew、transition/load 场景集上完成 F3 测量。`clock.*` 不与 data WNS 合并成总分；任一 hold 或 clock DRV 恶化即 hard fail，除非新 policy 经批准。

### 10.3 post-route 局部 reroute

RouteDelta 带 frozen net hash、affected nets/region/layers 和 dirty coupling neighbors。iEval 先读 F2 overflow/估算 RC，随后要求 iRT/iDRC/iRCX/iSTA 提供 F3 结果。若 router 为可行性扩大 scope，应由 iRT 返回 scope expansion proposal；iEval 将原 scope 的 frozen certificate 标为 stale，不能把扩大修改后的“改善”套用在原候选上。

---

## 11. 测试、基准与可杀假说

### 11.1 测试分层

| 层级 | 测试 | 必须锁住的行为 |
|---|---|---|
| L0 unit | schema、单位换算、definition 值域、Pareto、gate 表达式 | `N/A`/unsupported 不变成 0/pass |
| L1 contract | request/context、scope、adapter manifest、artifact 缺失 | 无 scenario/tech/输入工件必须响亮失败 |
| L2 adapter | E0 adapter 与原 API 同输入对拍；iSTA/iRT/iDRC stub | E0 数值零回归，coverage/provenance 完整 |
| L3 state | snapshot/delta/dirty/cache 交叉 | context 变化、陈旧 cache、越 scope 结果均不可复用 |
| L4 workflow | timing ECO、CTS、route repair branch-to-gate | 未过 gate/certificate 无 commit 路径 |
| L5 benchmark | smoke/daily/weekly/scale/holdout、F0-F4 对拍 | 无泄漏校准、性能统计和 regret 报告 |

### 11.2 必须有的反例注入

- 将 WNS 的 `ps` 与 `ns` 混用，schema/definition validator 必须拒收；
- 删除一个 scenario、DRC rule、activity source 或 EGR artifact，gate 必须为 `INCOMPLETE/FAIL`，绝不能 clean；
- base/candidate 使用不同 SDC、RCX、rule deck 或 PDK，compare 必须为 `NOT_COMPARABLE`；
- 构造 F1 排名错误和 over-confident 样本，校准报告必须暴露 regret/ECE，而非只报平均 MAE；
- F0 把一个 near-gate 候选判断为通过时，升级策略必须触发 F3；
- 修改 scope 外 frozen net/instance，Verification Hub 失败且 iEval 不得被 QoR 改善掩盖；
- worker timeout、cancel、单例残留、artifact 损坏后，返回正确 status，base snapshot 不变；
- iPL 既有 congestion/WL/timing 调用前后双跑，E0 数值与调用成功率无回归。

### 11.3 Benchmark protocol

每条结果必须关联 `input/build/artifact` manifest、binary hash、seed、机器配置和 protocol version。性能用至少五次重复的 median/MAD；不同设计族、PDK、规模、stage、动作类别分桶。训练/校准与 holdout 的隔离由 manifest 机械检查，不能依赖目录命名约定。

### 11.4 关键假说

| 假说 | 实验 | 失败后的动作 |
|---|---|---|
| H-EV-A1：F0/F1 可将 F3 次数显著降低且 selection regret 可控 | 在 held-out ECO portfolio 上比较全 F3 与 screen-then-escalate | 缩小 proxy domain、提高 Top-K 或升级比例；不放松 gate |
| H-EV-A2：局部 dirty metric 足以支持 late ECO | F2 incremental 与 F3 full 分桶对拍 | 扩大 dirty scope 或在该 action 类禁用增量 |
| H-EV-A3：统一 context 阻止错误 QoR 结论 | 注入 scenario/tech/constraint 漂移 | 补 request validator，禁止隐式 default |
| H-EV-A4：证据包可完全重放决策 | 从 CAS manifest 重放随机样本 | 补 artifact/hash/seed，不以日志替代 |

---

## 12. 里程碑、交付物与 PR 切片

| 阶段 | 周期 | 交付 | 退出门禁 |
|---|---:|---|---|
| EV-A0：事实冻结 | 2 周 | E0 consumer 台账、metric dictionary、`summary_db` 处置决定、benchmark protocol 空跑 | 现有 iPL/iPNP 评估调用和数值基线已锁定 |
| EV-A1：契约地基 | 3 周 | `MetricRecord`、request/bundle/policy schema、validator、capability discovery | 缺 context/unit/coverage/artifact 的结果全部拒收 |
| EV-A2：传感器接入 | 3 周 | WL/density/congestion/timing legacy adapters、worker/session 隔离、cache key | E0 对拍无回归；EGR 缺工件响亮失败 |
| EV-A3：比较与门禁 | 4 周 | comparator、Pareto selector、GateEngine、evidence pack、Timing ECO policy | 不可比/未知/证书缺失无 commit 路径 |
| EV-A4：F2/F3 闭环 | 4 周 | common iSTA、local legalize/early GR、Verification Hub 对接 | post-place branch-to-gate e2e 可重放 |
| EV-A5：校准与扩展 | 持续 | regret/calibration/OOD report、post-CTS/post-route、power/IR | held-out 报告驱动 fidelity/domain 资格 |

建议 PR 顺序：

```text
EV-0  事实台账 + schema/protocol（无行为改动）
EV-1  MetricRecord + RequestValidator + capability query
EV-2  WL/density/congestion adapter + E0 数值回归
EV-3  Timing adapter + comparator/Pareto + cache/session
EV-4  GateEngine + evidence pack + Verification Hub bundle bridge
EV-5  Timing ECO vertical slice + calibration harness
EV-6  CTS/route/DRC/power/IR adapters（按独立 policy 进入）
```

每个 PR 必须附：新增/变更 metric definition、适用 stage/scope、覆盖率语义、失效域、最小正反例、benchmark protocol 影响。没有这些信息的“新增分数”不能合入。

---

## 13. 开放问题与后续扩展

| ID | 问题 | 处理原则 |
|---|---|---|
| OI-EV-01 | legacy singleton 在多 branch/并发分析下的隔离方式 | 先 profile 和审计；未证明线程安全前用 worker/session 串行化 |
| OI-EV-02 | EGR/iRT 产物的稳定 artifact contract | 在 iRT 侧确认 producer 前不冻结文件名猜测；缺失必须 unsupported/failed |
| OI-EV-03 | common iSTA 与 legacy `TimingAPI` 的迁移窗口 | 双跑并按 scenario/path 分桶，不一次性替换 |
| OI-EV-04 | F2 local DRC/RC/timing 的可证明 scope | 先要求 conservative dirty expansion 与周期性 full oracle 对拍 |
| OI-EV-05 | power/IR 与 activity、thermal 的 context 统一 | 在 activity/PDN/temperature refs 完整前，只输出 partial 风险，不进 hard pass |
| OI-EV-06 | 3D 指标中台 | 复用本文件 request/record/gate/evidence 契约；再增加 per-tier/inter-tier scope 与 ai1.1 的梯度后端 |
| OI-EV-07 | 商业/外部 oracle 接入 | 通过 External Tool Bridge 固化 argv、manifest、报告 normalizer；不从自由文本判断 success |

---

## 附录 A：其他 Agent 原生 EDA 模块应复用的范例骨架

后续重写 iFP、iPL、iCTS、iRT、iTO 等具体模块时，每篇详细设计至少应回答以下问题：

1. 哪些能力是 `inspect / diagnose / propose / apply(branch) / verify`，各自读写什么 snapshot？
2. Proposal、TypedDelta、MetricRecord、Certificate 分别由谁创建和消费？
3. 每个动作的 scope、frozen objects、dirty domains、inverse/checkpoint 和失败语义是什么？
4. F0-F4 分别调用真实的哪一段既有内核，适用 domain、误差和升级规则如何定义？
5. 如何与 iEval 比较、如何与 Verification Hub 取证、何时才允许 Runtime commit？
6. 源码落点、类职责、adapter 边界、测试反例、基准协议和 PR 切片是什么？
7. 哪些事实已经由代码验证，哪些仍是明确标为 D0/DRAFT 的假设？

当这些问题没有具体答案时，所谓“Agent 原生工具”仍只是传统 Tcl/单例 API 的薄包装，尚不具备可观察、可试探、可验证、可回滚和可组合的工程能力。

## 附录 B：术语

- **Metric**：绑定 snapshot/context 的测量记录，不是裸分数。
- **Fidelity**：估算器成本与真实性等级；不是“成功/失败”等级。
- **Coverage**：实际检查的对象、场景、规则和未覆盖部分。
- **Calibration**：用独立 holdout 证明预测数值/排序/置信度与 oracle 的关系。
- **Pareto**：任何目标不差且至少一个目标更好时的支配关系。
- **Evidence pack**：可重放一个比较或 gate 结论所需的 refs、hash、工件和 policy。
- **Gate**：在明确 policy 下对 QoR/风险的判定；不同于领域 correctness certificate。
