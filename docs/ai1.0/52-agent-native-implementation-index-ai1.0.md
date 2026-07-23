<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 52 · iEDA.ai Agent 原生工具实施总索引 · ai1.3

> 日期：2026-07-23
> 上位方案：`51-agent-native-eda-detailed-plan-v1.0.md`；新增架构与工具边界见 `53-agent-native-eda-architecture-v2.0.md`。
> 使用方式：本文件负责跨工具顺序、共同契约和里程碑；各 `*-ai1.0.md` 负责模块 API、LLD、源码落点和测试；同编号原 `.md` 负责现有 kernel 审计与商业对标。

## 0. 详细设计完成基线（2026-07-23）

本轮已按 `12-evaluation-ai1.0.md` 的工程深度展开 `10/11`、`20-49`、`54-57` 全部工具/模块文档，并补齐此前缺失的 `34-iFormal-ai1.0.md`、`39-i3D-iPKG-ai1.0.md`。总纲 `50/51/53` 不复制模块 LLD，继续只承担战略、产品与总架构职责。

后续评审不以行数判断“详细”，而机械检查每篇是否给出：

1. 当前代码事实、目标能力、明确非目标和 owner 边界；
2. typed request/result/proposal/delta/certificate 中适用的具体 schema；
3. snapshot/intent/scenario/tech/policy refs、scope、coverage 和 provenance；
4. stage/fidelity/backend 的前置、降级、升级和 forbidden claim；
5. apply/rollback/actual touched/DirtySet/InvalidationSet 或只读缓存失效；
6. 文件级 LLD、现有 API adapter、禁止复制的内核和依赖方向；
7. `PARTIAL/UNSUPPORTED/INFEASIBLE/TIMEOUT/FAILED` 的领域语义；
8. 正例、边界、metamorphic、故障注入、incremental/full、held-out/oracle 测试；
9. 可杀假说、退出门禁、PR 切片及至少一个真实 consumer/e2e；
10. 与 iDB、Platform、Runtime、Evaluation、Verification、Intent、Technology 的契约对账。

任何新模块或新 capability 若缺上述适用项，状态不得高于 D1；若某项不适用，文档必须写出原因，不能直接省略。

## 1. 文档全集

### 1.1 现有基础设施

| 文档 | 核心交付 | 90 天角色 |
|---|---|---|
| `10-iDB-ai1.0.md` | snapshot、stable ID、typed delta、DirtySet | P0 基座 |
| `11-solver-ai1.0.md` | SolverResult、budget、incumbent、portfolio | P1 局部求解 |
| `12-evaluation-ai1.0.md` | metric schema、Pareto、gate、regret | P0 门禁 |
| `40-platform-ai1.0.md` | DAG、rc、artifact、checkpoint、worker | P0 执行平面 |
| `41-interface-ai1.0.md` | typed MCP/Python gateway、安全隔离 | P0 对外入口 |
| `42-perf-ai1.0.md` | Agent 调用/增量/闭环性能 trace | P0 可度量 |

### 1.2 现有与 greenfield EDA 工具

| 文档 | 首个 Agent 切片 | Wave |
|---|---|---:|
| `20-iFP-ai1.0.md` | floorplan inspect/validate/candidates | 3 |
| `21-iNO-ai1.0.md` | fanout diagnose/tree proposal/txn | 1 |
| `22-iPL-ai1.0.md` | local move/legalize/frozen scope | 1 |
| `23-iCTS-ai1.0.md` | tree inspect/common timing/clock txn | 3 |
| `24-iPDN-iPNP-ai1.0.md` | PDN inspect/reinforcement portfolio | 3 |
| `25-iTO-ai1.0.md` | timing diagnose/ECO proposal/apply | 1 |
| `26-iRT-ai1.0.md` | local reroute/frozen nets/anytime | 2 |
| `27-iSTA-ai1.0.md` | typed timing/common engine/dirty cone | 1 |
| `28-iRCX-ai1.0.md` | net inspect/dirty tile extraction | 1 |
| `29-iPA-iIR-ai1.0.md` | activity provenance/power→IR trace | 3 |
| `30-iDRC-ai1.0.md` | coverage/incremental check/repair proposal | 2 |
| `31-iLVS-ai1.0.md` | external adapter/flat digital compare | 4 |
| `32-iECO-ai1.0.md` | timing 与 route-DRC 领域 workflow | 2 |
| `33-iLO-iTM-ai1.0.md` | external synthesis adapter/LogicIR | 4 |
| `34-iFormal-ai1.0.md` | external CEC/局部证明/counterexample | 1 shadow/4 product |
| `35-iSI-ai1.0.md` | coupling coverage/SI inspect/route mitigation | 2 |
| `36-iEM-iReliability-ai1.0.md` | EM stress/lifetime context/mitigation | 3 |
| `37-iThermal-ai1.0.md` | steady thermal/coupled solve/hotspot proposal | 3 |
| `38-iDFM-ai1.0.md` | antenna/density/via/pattern risk | 2 analyzer/4 write |
| `39-i3D-iPKG-ai1.0.md` | multi-die state/bump/package early analysis | 4 incubation |

### 1.3 新建 Agent 专用工具

| 文档 | 核心交付 | Wave |
|---|---|---:|
| `43-agent-runtime-ai1.0.md` | experiment/branch/budget/policy | 0 |
| `44-design-observer-ai1.0.md` | summarize/diff/explain/root cause | 1 |
| `45-model-router-ai1.0.md` | registry/calibration/OOD/F0-F4 router | 1 |
| `46-honey-tool-factory-ai1.0.md` | 受控工具生成和晋级门禁 | 4 |
| `47-data-oracle-ai1.0.md` | paired data/oracle/lineage/active learning | 0 |

feature/vectorization 归 `44/45` 复用，现有 MCP/Python 归 `41`，benchmark 数据归 `47`，不再另建平行系统。

### 1.4 新增横向服务

| 文档 | 核心交付 | Wave |
|---|---|---:|
| `48-intent-scenario-ai1.0.md` | immutable intent/scenario/audit/approval | 0 |
| `49-verification-hub-ai1.0.md` | validator registry/certificate/invalidation | 0 |
| `54-agent-planner-ai1.0.md` | typed plan/critic/recovery/stop | 1 |
| `55-technology-knowledge-ai1.0.md` | TechContext/PDK semantics/qualification | 0 |
| `56-experience-memory-ai1.0.md` | trajectory/failure case/applicability | 1 |
| `57-external-tool-bridge-ai1.0.md` | isolated external worker/report protocol | 0 |

`48/49/55/57` 是底座，不应被单个 EDA 工具私有复制；`54` 可由确定性规则 baseline 起步，不要求 LLM 才能运行；`56` 的经验只能产生先验/proposal，不是 oracle。

## 2. 总体依赖图

```text
                    47 Data/Oracle ←→ 57 External Bridge
                       ▲       ▲
                       │       │
10 iDB → 40 Platform → 43 Runtime → 41 Interface
  │          │              ▲  │
  │          ├→ 42 Perf     │  ├→ 54 Planner
  │          └→ 11 Solver   │  ├→ 44 Observer ←→ 56 Experience
  │                         │  └→ 45 Model Router
  │                         │
  ├→ 48 Intent/Scenario ────┤
  ├→ 55 Technology/PDK ─────┤
  └→ 49 Verification Hub → 12 Evaluation/Gates

20-33 existing/greenfield EDA tools consume the common context/contracts
  ├→ 34 iFormal                               [Wave 1 shadow/Wave 4]
  ├→ 35 iSI + 38 iDFM ←→ 26 iRT/28 iRCX/30 iDRC [Wave 2]
  ├→ 36 Reliability + 37 Thermal ←→ 24/29      [Wave 3]
  └→ 39 i3D/iPKG ←→ per-die 20-38              [Wave 4 incubation]

46 Honey consumes stable contracts after Wave 1; it does not define them.
```

## 3. 统一完成定义

每个 Agent tool 只有同时满足以下条件才从 D1 晋级 D2/D3：

1. manifest：名称、版本、输入、输出、权限、fidelity、cancel 能力；
2. typed request/response：无裸文本 success、裸 double 和隐式单位；
3. context：所有结果绑定 snapshot/intent/scenario/technology/policy refs；
4. state：写操作只在 branch；Proposal、TypedDelta、Certificate 分离；
5. errors：invalid/unsupported/infeasible/partial/timeout/validation failure 可区分；
6. scope：touched/frozen/dirty/invalidated 明确；
7. rollback：失败后主状态和冻结域不变；
8. validation：required claim 有 current certificate，coverage/失效规则完整；
9. evidence：tool/model/data/oracle/intent/tech hash、coverage、artifacts；
10. tests：unit、integration、failure injection、metamorphic；
11. benchmark：至少 smoke+daily；AI/校准能力必须 held-out family；
12. consumer：至少一个真实 Agent 闭环消费，不以 demo 调通代替产品价值。

## 4. 共同协议冻结顺序

| 顺序 | 协议 | Owner 文档 | 依赖者 |
|---:|---|---|---|
| 1 | Unit/ObjectId/SnapshotRef | 10 | 全部 |
| 2 | IntentRef/ScenarioSetRef | 48 | timing/power/clock/Planner/validator |
| 3 | TechContextRef/Qualification | 55 | 全部 EDA tool/router |
| 4 | Status/Error/Coverage/Artifact | 40/12 | 全部 |
| 5 | CapabilityManifest/Request/Response | 40/41 | Planner/全部 adapter |
| 6 | TypedDelta/DirtySet/InvalidationSet | 10 | EDA action/49 |
| 7 | ValidationCertificate/PolicyProfile | 49 | Runtime/Evaluation |
| 8 | MetricRecord/Gate | 12 | Runtime/所有 validator |
| 9 | Experiment/Branch/Budget | 43 | Planner/MCP/ECO |
| 10 | GoalSpec/PlanGraph | 54 | Gateway/Runtime |
| 11 | Model/Dataset/Oracle/Experience manifest | 45/47/56 | learned/fidelity 工具 |
| 12 | External Adapter/Tool Package | 57/46 | 外部/生成工具 |

后一个协议不得私自复制前一个协议的字段定义。

## 5. Wave 0：基础契约（W1-W4）

### 5.1 目标

建立一个只读、可复现、失败诚实的 Agent 调用闭环，不追求 PPA 改善。

### 5.2 关键路径

```text
10 ObjectId/Snapshot
  → 40 StageResult/rc/artifact
  → 48 Intent/Scenario + 55 TechContext
  → 49 ValidationCertificate + 12 MetricRecord/Gate
  → 43 Experiment read-only
  → 41 MCP summarize/top_paths/status
  → 42 trace
  → 47 frozen benchmark protocol + 57 isolated adapter
```

### 5.3 退出门禁

- 10 个设计 snapshot hash 可复现；
- 20 类失败注入全部非 success；
- MCP 不再以任意 shell script 作为普通 Agent 主能力；
- `design.summarize`、`timing.top_paths`、`state.diff` 可用；
- 所有结果有 snapshot/intent/scenario/tech/tool/unit/source/coverage；
- missing/stale context 和 certificate 不得 full success/commit；
- baseline 不要求改动设计。

## 6. Wave 1：Timing Closure Lab（W5-W13）

### 6.1 工具链

```text
48 freeze intent/scenarios + 55 qualify tech
  → 44 path explain + 54 bounded plan
  → 25 iTO proposals + 21 iNO proposals
  → 45 F0/F1 rank
  → 43 fork Top-N
  → 10 apply typed delta
  → 22 local legalize
  → 28 dirty RC
  → 27 dirty-cone setup/hold
  → 49 certificate bundle + 12 hard gates/Pareto
  → commit or rollback
  → 56 record success/failure applicability
```

### 6.2 90 天统一门禁

| 门禁 | 目标 |
|---|---|
| 状态正确性 | 500 动作零未授权主状态变化 |
| rollback | hash/拓扑/指标在字段容差内恢复 |
| incremental STA | 相关端点与 full ≤1 ps，锥外无变化 |
| frozen scope | scope 外 object hash 变化数 0 |
| 失败诚实 | 所有注入失败带 status/dirty/evidence |
| 闭环效果 | ≥10 held-out 违例 case 中 ≥8 减少 setup violation magnitude |
| 硬门禁 | connectivity/legal/setup+hold/DRV 不以别项改善抵消 |
| 计算 | 相对每候选 F3 全跑，候选评价总 CPU wall 降 ≥5× |
| 泛化 | ≥2 PDK、≥3 design family，family split |
| 上下文 | intent/tech/scenario ref 变化 100% 阻断旧 baseline/certificate |
| 证书 | required claim 无漏失效；UNKNOWN/PARTIAL 默认不 commit |

任何数值目标若 M0 测量证明不合理，必须形成 protocol 变更记录，不能静默改门槛。

## 7. Wave 2：Route/DRC ECO（M4-M8）

交付顺序：

1. iRT inspect/hotspot/RouteDelta；
2. frozen-net local reroute；
3. iDRC coverage + incremental scope；
4. iDRC/iRT repair proposal portfolio；
5. route delta → iRCX → iSTA；
6. iSI coupling coverage/inspect → mitigation shadow loop；
7. iDFM via/antenna/density analyzer，首版 proposal-only；
8. iECO 领域 workflow；
9. anytime/cancel/resume。

退出门禁：构造与 held-out DRC case 上 residual 减少；不新增 timing/DRV；冻结网不动；skipped rules 不记 clean；local/full DRC 定期一致。

## 8. Wave 3：Floorplan/Clock/Power/Thermal/Reliability（M7-M14）

三个闭环可并行，但共用 Wave 0/1 契约：

- floorplan：iFP candidates → iPL/early route/PDN → Pareto；
- clock：iCTS proposal → legal/route/RC/common iSTA；
- power：activity audit → iPA → iIR → iPNP/iPDN → DRC/congestion/IR。
- thermal/reliability：power provenance → thermal fixed-point → IR/EM/lifetime context → PDN proposal。

每条闭环先做来源/coverage/rollback，再做 learned ranker。

## 9. Wave 4：综合、Formal、LVS、3D 与工具生成（M12-M24）

- iFormal 从 Timing ECO shadow adapter 晋级为 netlist rewrite 门禁；
- iLO/iTM 先接成熟综合内核、LogicIR、transform trace 和 iFormal；
- iLVS 先外部 extraction/oracle + flat digital graph compare；
- i3D/iPKG 只做 AssemblyRef、接口/坐标/连通性和 early proxy 孵化；
- Honey 只生成 T0-T3 adapter/analyzer/local solver/workflow；
- PDK adapter/rule deck compiler 进入 quarantine；
- 多 Agent 仍优先 branch-and-select，自动 merge 需独立证明。

## 10. 集成门禁矩阵

| 动作 | 必需验证 | 可选/后置 |
|---|---|---|
| resize/VT | connectivity、legal、setup+hold、DRV | power/congestion（按 policy） |
| insert buffer | connectivity、legal、RC、setup+hold、DRV | local route/DRC |
| local move | legal、frozen、congestion、STA | power |
| clock change | connectivity、legal、route、RC、所有 setup+hold 场景 | SI |
| reroute | frozen nets、DRC coverage、RC、STA | SI/EM |
| PDN change | PG connectivity、DRC、IR residual、signal congestion | EM/dynamic IR |
| netlist rewrite | formal equivalence、map、STA、legal/route | LVS/full power |
| constraint change | 独立 intent approval + before/after audit | 禁与普通 PPA action 混合 |

## 11. 仓库落点总览

```text
src/database/manager/design_state/     # iDB 对象层
src/platform/design_state/             # snapshot/delta 持久化
src/platform/flow/tool_flow/           # deterministic workflow
src/platform/agent_runtime/            # experiment/branch/policy
src/interface/agent/                    # transport-neutral typed service
src/interface/mcp-iEDA/                # MCP transport
src/evaluation/qor/                    # metric/gate
src/observer/                          # Agent read-only understanding
src/ai/runtime/                        # model registry/router
src/intent/                            # intent/scenario truth
src/verification/                      # validator/certificate/policy
src/planner/                           # typed planner/critic
src/technology/                        # TechContext/qualification
src/knowledge/experience/              # trajectory/failure memory
src/platform/external_bridge/          # isolated external adapters
src/operation/<tool>/agent/            # 每工具 adapter/proposal/validator
src/operation/{iFormal,iSI,iReliability,iThermal,iDFM,iPKG}/
src/platform/oracle/                   # external oracle registry
tools/factory/                         # Honey templates
benchmarks/{evaluation,perf-agent,data_flywheel}/
```

目录可在实现前通过架构 review 微调，但职责边界不可无记录改变。

## 12. 团队工作流与责任

| Workstream | 负责文档 | 首要交付 |
|---|---|---|
| State/Runtime | 10/40/43 | snapshot、txn、DAG、commit policy |
| Intent/Technology | 48/55 | intent/scenario/PDK context 与 qualification |
| Interface/Security/External | 41/57 | typed gateway、sandbox、external adapter |
| Verification/Metrics/Perf/Data | 12/42/47/49 | certificate、gate、trace、oracle protocol |
| Timing Lab | 21/22/25/27/28 | 首个闭环 |
| Planner/Observer/Model/Memory | 44/45/54/56 | plan、explain、rank、OOD、failure memory |
| Route/SI/DFM Closure | 26/30/32/35/38 | 第二闭环 |
| Clock/Power/FP/Multi-physics | 20/23/24/29/36/37 | 第三批闭环 |
| Front/Back Signoff | 31/33/34 | synthesis/formal/LVS greenfield |
| 3D/Package Incubation | 39 | AssemblyRef/early analysis |
| Tool Factory | 11/46 | solver contract/生成门禁 |

每个 workstream 必须有 domain owner 和 contract owner。跨工具 schema 由 contract owner 合并，禁止“先各做一份以后再统一”。

## 13. 每周集成节奏

- 每 PR：schema/unit/failure/smoke；
- 每日：Timing Lab daily cases、full/incremental audit 抽样；
- 每周：held-out family、2 PDK、PPA/regret/perf；
- 每双周：failure injection day，主动 kill/超时/OOM/输入破坏；
- 每月：商业 oracle/field/formal 对拍和 protocol review；
- 每里程碑：冻结 binary/model/data hashes 与完整 evidence pack。

## 14. 立即执行的前 16 个 issue

1. 冻结 `SnapshotRef/ObjectId/UnitSystem` schema；
2. 修复 iEDA/Tcl 失败退出码传播；
3. 冻结 `IntentRef/ScenarioSetRef/TechContextRef`；
4. 冻结 `CapabilityManifest/StageResult/Coverage`；
5. 冻结 `ValidationCertificate/InvalidationSet`；
6. 实现 read-only `design.summarize`；
7. 实现 typed `timing.top_paths`；
8. MCP 新增 summarize/top_paths/status，限制任意脚本工具；
9. 建 external bridge 固定 argv/timeout/artifact worker；
10. 建立 MetricRecord、certificate bundle 和 evidence pack 最小版；
11. 建立 benchmark protocol 与 10 case baseline；
12. 实现 SDC normalized intent + constraint coverage audit；
13. 实现 library/layer/via/unit TechContext query；
14. 实现 `ResizeInst` delta + apply/rollback/invalidation 测试；
15. 接通 local legalize → dirty RC → dirty STA → certificate 的手工闭环；
16. 建 rule-based Planner 与 FailureCase 记录基线。

## 15. 总体停止条件

出现以下任一情况时停止扩工具面，优先修底座：

- 主 snapshot 被未声明修改；
- full/incremental 对拍持续不一致；
- Agent 可通过改约束/跳规则改善 PPA；
- 同一指标出现多个互不对拍的语义源；
- failure 返回 success 或 partial 被 commit；
- intent/tech/scenario 不同的 baseline、cache 或 certificate 被复用；
- required certificate 已失效、UNKNOWN 或 coverage 不足却仍可 commit；
- benchmark 泄漏/不可重放；
- MCP/生成工具可越权执行任意命令；
- 新增工具没有真实闭环 consumer。

## 16. Readiness Ledger

总索引同时维护机器可读 readiness ledger；文档表格只作为渲染视图。每个 capability/facet 至少记录：

```text
capability + facet + owner
source module/document/issue/PR
current maturity and requested maturity
request/response/error schema versions
permissions + context refs + supported domain
provider qualification + required validators
benchmark/protocol/test/evidence-pack refs
consumer closed loops
blocking dependencies + revocations + last reviewed
```

状态只允许 `NOT_STARTED -> CONTRACT -> SHADOW -> QUALIFIED -> ACTIVE -> SUSPENDED/RETIRED`。目录、命令或文档存在不能自动推进状态。ledger 更新由 CI 校验：不存在的 schema/test/evidence、过期 qualification、无 consumer 的 R2/R3 capability 均拒绝合并。

## 17. 跨模块契约验收矩阵

| 契约 | Owner | 首个 producer | 首个 consumer | 必需契约测试 |
|---|---|---|---|---|
| SnapshotRef/ObjectId/UnitSystem | 10/40 | iDB/DesignState | 全部工具 | hash/replay/rename/unit |
| IntentRef/ScenarioSetRef | 48 | SDC adapter | iSTA/Planner/49 | canonical/coverage/consumer receipt |
| TechContextRef | 55 | LEF/Liberty/RC adapter | iSTA/iPL/iRT | mapping/unit/PVT/qualification |
| CapabilityManifest/StageResult | 40/41 | Registry/Gateway | 43/54 | version/permission/partial/cancel |
| TypedDelta/Scope/InvalidationSet | 10/43 | ECO adapter | iDB/49 | apply/rollback/touched/closure |
| MetricRecord/ParetoDecision | 12 | evaluation | Planner/Runtime | semantics/context/regret/tie-break |
| ValidationCertificate/Bundle | 49 | domain validators | Runtime commit | coverage/stale/conflict/replay |
| Experiment/Decision/FailureCase | 43/54/56 | Runtime/Planner | Data/Experience | lineage/tenant/disposition |

Owner 负责 canonical schema 和 conformance suite；producer 负责生成正确对象；consumer 负责拒绝缺字段、旧版本和不兼容 context。不能只测试 producer happy path。

## 18. Release train 与 issue 模板

每个 Wave 采用四类 release train：

1. `Contract`: schema、golden fixtures、compatibility/invalidation tests；
2. `Adapter`: legacy kernel 到 contract 的薄适配和真实失败语义；
3. `Closure`: Runtime DAG、policy bundle、benchmark consumer；
4. `Qualification`: held-out、failure/security/perf、evidence pack 和 Registry 晋级。

后三类不得反向私改已发布 Contract。发现契约不足时由 owner 发 schema change，提供 migration、consumer impact 和重新 qualification 计划。

Issue 必填：问题与真实 consumer、输入/输出/context、状态与错误、权限/scope、oracle/可杀假说、测试 ID、完成门禁、依赖和明确不做。只有代码任务而没有闭环 consumer 的 issue 默认 D0，不进入关键路径统计。

集成看板至少显示：P0 contract blockers、capability maturity、invalid/partial、held-out 回归、certificate qualification、external protocol 状态和资源预算。周报不以完成 issue 数替代 gate 状态。

## 19. 文档深化 Agent 团队与批次

本轮采用“一模块一子 Agent、主 Agent 只负责 51-53 和集成”的所有权模型。受并发槽位限制，子 Agent 按批次滚动执行；同一文件在一个批次中只有一个 writer。

| 批次 | 独立模块 Agent | 主 Agent 同期职责 | 合并门禁 |
|---|---|---|---|
| B0 | 10、11、20 | 51-53 总契约深化 | CURRENT/TARGET 与公共类型对账 |
| B1 | 21、22、23 | 51-53 schema/架构 | Timing/placement/clock context 一致 |
| B2 | 24、25、26 | 实施索引更新 | action delta、scope、验证闭包一致 |
| B3 | 27、28、29 | fidelity/oracle 对账 | timing/RC/power scenario 与 coverage 一致 |
| B4 | 30、31、32 | failure/certificate 对账 | DRC/LVS/workflow 不扩张 claim |
| B5 | 33、34、35 | greenfield/external 边界 | logic/formal/SI adapter-first |
| B6 | 36、37、38 | 多物理语义对账 | activity/temperature/lifetime/rule refs 完整 |
| B7 | 39、40、41 | 3D 与执行/入口 | 2D 状态稳定、Gateway 无任意 shell |
| B8 | 42、43、44 | perf/runtime/observer | trace、budget、evidence graph 一致 |
| B9 | 45、46、47 | model/factory/data | qualification、quarantine、lineage 一致 |
| B10 | 48、49、50 | intent/verification/strategy | R4 intent 与普通 delta 隔离 |
| B11 | 54、55、56 | planner/technology/experience | decision、PDK、memory 不充当 oracle |
| B12 | 57 | 主 Agent 全量验收 | external isolation/protocol 与所有 consumer 对账 |

`12-evaluation-ai1.0.md` 是共同深度/契约基线，不由本轮子 Agent 重写；`12-evaluation-ai1.1.md` 保留 3D/梯度扩展研究视图。缺失的 `34`、`39` 文档由对应模块 Agent 新建，不能继续只在索引中宣称存在。

## 20. Module Readiness Record

每篇文档完成后生成一条 readiness record，主 Agent 合并前逐项验收：

```text
DocumentReadiness
  document/module/owner-agent/revision
  current-source evidence refs
  target capabilities and first consumer
  owned schemas + consumed schemas
  side effects/scope/dirty/invalidation/rollback
  fidelity/backend/qualification matrix
  failure/partial/unsupported/cancel semantics
  LLD files/build targets/dependency direction
  test IDs/benchmark/oracle/falsifiable hypotheses
  milestones/PR slices/open decisions
  markdown/contract-review status
```

状态为 `QUEUED -> EDITING -> SELF_CHECKED -> CONTRACT_REVIEW -> ACCEPTED | REWORK`。子 Agent 的“完成”只到 SELF_CHECKED；公共 schema、职责或依赖冲突由主 Agent退回或在 owner 文档统一修订。

## 21. 90 天 Work Breakdown 与依赖闭包

### 21.1 Epic DAG

```text
E0 contracts/conformance
  -> E1 Snapshot/ObjectId/ContextRefs
  -> E2 StageResult/Capability/Gateway
  -> E3 Experiment/Branch/Budget/Journal
  -> E4 Intent/Tech/Validation foundation
  -> E5 read-only summarize/top-path/evaluation baseline
  -> E6 Resize/SwapVt typed delta + rollback
  -> E7 local legalize -> dirty RC -> dirty STA
  -> E8 certificate bundle -> hard gate/Pareto -> controlled commit
  -> E9 Planner baseline/Experience/Data capture
  -> E10 held-out/perf/security/replay qualification
```

E6 之前不允许 production 写能力；E8 之前不允许 commit；E10 之前不关闭 full validator fallback。Route/DRC、PDN/IR、clock 等后续 epic 从 E4/E5 分叉，但仍依赖 E0-E3。

### 21.2 Epic 完成证据

| Epic | 代码交付 | 必需 evidence | 失败时阻断 |
|---|---|---|---|
| E0 | contracts target + fixtures | old/new schema、unknown semantic field | 全部 |
| E1 | snapshot catalog/state adapter | replay/hash/crash/ID stability | E3-E10 |
| E2 | registry/gateway/stage result | permission、partial、cancel、no shell | Agent 入口 |
| E3 | runtime journal/branch/budget | state-machine property、worker loss | 所有写闭环 |
| E4 | intent/tech/certificate refs | context drift/invalidation tests | 比较与 commit |
| E5 | observer/eval/read adapters | coverage、E0 numeric parity | Planner/候选筛选 |
| E6 | typed ECO delta | apply/inverse/touched/frozen | local closure |
| E7 | tool chain adapters | incremental/full、failure injection | certificate |
| E8 | bundle/gate/commit | 500 branch invalid commit=0 | R3 |
| E9 | rule planner/case/data | fixed-budget A/B、no leakage | learned guidance |
| E10 | benchmark/ops runbook | held-out、p95、replay、security | production |

## 22. 统一 Conformance Suite

公共测试 ID 由模块 CI 引用，不在各文档复制不同语义：

| ID | Fixture/性质 | 适用 owner |
|---|---|---|
| CONF-SCHEMA-01 | major/minor/unknown semantic field/enum | 全部 contract owner |
| CONF-CTX-01 | snapshot/intent/scenario/tech/policy mismatch | 全部 capability |
| CONF-STATUS-01 | partial/unsupported/timeout/cancel/failure 非 success | Platform/Gateway/tool |
| CONF-SCOPE-01 | declared/actual/frozen/dirty/invalidation | iDB/所有 apply tool |
| CONF-TXN-01 | apply/rollback/replay/crash/head conflict | iDB/Runtime |
| CONF-FID-01 | F0-F4 forbidden claim/silent downgrade/OOD | Eval/Model/domain tool |
| CONF-CERT-01 | claim/coverage/stale/revoke/bundle | Verification/validator |
| CONF-EXT-01 | argv/path/secret/orphan/stale artifact | Interface/External/Honey |
| CONF-DATA-01 | tenant/family/PDK/retention/holdout | Data/Memory/Model |
| CONF-REPLAY-01 | request-to-decision-to-commit evidence | Runtime/全部闭环 |

模块专属测试在 owner 前缀下扩展；公共 fixture 变化需要 consumer matrix 全跑。测试通过只证明对应层，不能由 schema PASS 推导 domain algorithm 正确。

## 23. 主 Agent 集成审查清单

1. 标题成熟度与代码事实一致，规划项不写成已实现；
2. owner schema 只有一个定义源，其他文档以 ref 消费；
3. read/propose/apply/verify facet 与权限、fidelity、side effect 一一对应；
4. metric、certificate、proposal、delta、intent patch 不发生语义混用；
5. 所有写工具明确 actual touched、dirty、inverse、invalidation 和 branch only；
6. failure/partial/unsupported/cancel 对 Runtime 下一步是可执行信息；
7. LLD 指向真实现有入口或明确 TARGET 新文件，不虚构 CURRENT；
8. benchmark 有 family/PDK/stage/action 分桶、独立 oracle 和失败样本；
9. 首个 consumer、退出门禁和 PR 顺序能形成闭环，不是孤立 API；
10. 文档 Markdown、代码块、编号、版本历史和相互链接完整。

## 24. 版本历史

- ai1.3（2026-07-23）：增加一模块一 Agent 的分批所有权、readiness 状态机、90 天 Epic DAG、统一 conformance suite 和主 Agent 集成审查。
- ai1.2（2026-07-23）：增加机器 readiness ledger、跨模块 producer/consumer 契约矩阵、四类 release train 和可验收 issue 模板。
- ai1.1（2026-07-23）：接入 53 号新架构，新增 12 份模块方案；冻结 intent/technology context、validation certificate、Planner、experience 与 external bridge 的 ownership，并把 formal/SI/reliability/thermal/DFM/3D 纳入 Wave。
- ai1.0（2026-07-23）：将 51 号总方案拆解为 25 份模块实施方案，冻结依赖顺序、90 天 Timing Closure Lab 和后续四个 Wave。
