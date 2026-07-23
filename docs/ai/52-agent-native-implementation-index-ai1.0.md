<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 52 · iEDA.ai Agent 原生工具实施总索引 · ai1.1

> 日期：2026-07-23
> 上位方案：`51-agent-native-eda-detailed-plan-v1.0.md`；新增架构与工具边界见 `53-agent-native-eda-architecture-v2.0.md`。
> 使用方式：本文件负责跨工具顺序、共同契约和里程碑；各 `*-ai1.0.md` 负责模块 API、LLD、源码落点和测试；同编号原 `.md` 负责现有 kernel 审计与商业对标。

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

## 16. 版本历史

- ai1.1（2026-07-23）：接入 53 号新架构，新增 12 份模块方案；冻结 intent/technology context、validation certificate、Planner、experience 与 external bridge 的 ownership，并把 formal/SI/reliability/thermal/DFM/3D 纳入 Wave。
- ai1.0（2026-07-23）：将 51 号总方案拆解为 25 份模块实施方案，冻结依赖顺序、90 天 Timing Closure Lab 和后续四个 Wave。
