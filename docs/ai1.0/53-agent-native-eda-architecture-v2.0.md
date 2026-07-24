<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 53 · iEDA.ai 面向 Agent 的 EDA 工具架构与新增工具总方案 · v2.3

> 日期：2026-07-24
> 上位方案：`50-agent-era-eda-master-plan-v1.0.md`、`51-agent-native-eda-detailed-plan-v1.0.md`。  
> 实施索引：`52-agent-native-implementation-index-ai1.0.md`。  
> 定位：本文件给出“当前仓库事实”和“目标产品架构”两张图，补齐现有 `*-ai1.0.md` 未明确承接的工具；它是规划，不表示新增模块已经实现。  
> 成熟度纪律：除明确引用现有源码的能力外，本文新增模块均从 `D0/DRAFT` 起步；外部工具能被调用只表示 adapter 达到 D1，不表示自研 kernel 达到 D2-D4。

---

## 0. 本版解决的问题

`51` 已经提出完整的 Agent 原生理念，`10`-`47` 的 `ai1.0` 文档也覆盖了现有后端工具、状态、执行、接口、观察、模型、生成和数据。但是逐项对照后仍有四个结构性缺口：

1. **设计意图没有独立真值 owner**：SDC、UPF、MMMC、dont-touch、审批过的例外分散在 iSTA、iPA、各工具配置和脚本中；Agent 很容易把“修改目标”与“修改约束”混在一起。
2. **验证没有统一证书层**：`12` 管指标与 gate，`43` 触发 policy，各 EDA 工具各自验证；但谁编排 connectivity、legality、formal、DRC、STA、frozen-object 和 artifact round-trip，并对“检查了什么”签发机器证书，尚无独立 owner。
3. **技术/PDK 语义没有公共服务**：LEF、Liberty、RC tech、rule deck、layer purpose、via、库族和单位映射分别被各工具读取，缺少可审计的 `TechContext` 和 capability/coverage 查询。
4. **未来能力只有名字，没有产品契约**：formal、SI、EM/reliability、thermal、DFM、3D/package 等出现在路线图中，但没有和 snapshot/delta/oracle/validator 接轨的详细方案。

本版不推翻 `51` 的 Timing Closure Lab 优先级，而是补上这些 owner，并将未来工具放进有退出门禁的依赖图。

## 1. 事实审计与边界

### 1.1 当前仓库可确认的事实

| 事实 | 证据 | 结论 |
|---|---|---|
| operation 构建入口注册 iDRC、iECO、iFP、iIR、iLO、iTM、iPDN、iPNP、iPL、iRT、iSTA、iPA、iTO、iCTS、iNO、iRCX | `src/operation/CMakeLists.txt:1` | 只能证明构建入口存在，不能证明所有模块有有效 kernel |
| iLO、iTM 的 `CMakeLists.txt` 为空 | `src/operation/iLO/CMakeLists.txt`、`src/operation/iTM/CMakeLists.txt` | logic optimization/technology mapping 按 D0 处理 |
| AI 构建当前只进入 predictor，predictor 只注册 iPL wirelength | `src/ai/CMakeLists.txt:1`、`src/ai/predictor/CMakeLists.txt:1` | model registry/router 是规划，不是已有公共服务 |
| platform flow 当前是薄 `flow.cpp` library，没有文档规划中的 DAG/runtime 实现 | `src/platform/flow/CMakeLists.txt:1` | `40/43` 是新增执行架构 |
| MCP 当前只暴露脚本和 example，使用 `shell=True`，返回文本 success | `src/interface/mcp-iEDA/src/mcp_ieda/server.py:31`、`:52`、`:74` | MCP 只能作为 transport 原型，不是 Agent 安全工具面 |
| `ieda_main` 调 Tcl 后固定返回 0 | `src/apps/ieda_main.cpp:67` | 在修复 rc 传播前，外部 Agent 不能可靠判断失败 |
| iSTA 可见串扰传播/延迟代码 | `src/operation/iSTA/source/module/delay/CrossTalkDelayCalc.cc`、`source/module/sta/StaCrossTalkPropagation.cc` | 可作为 SI 审计起点，但不足以宣称完整 SI closure |
| 未发现独立 formal、UPF、thermal、reliability、DFM、package/3D operation 目录 | 2026-07-23 仓库文件检索，未验证外部私有分支 | 对应新工具全部标 D0；先 adapter/oracle 后自研 |

### 1.2 三种状态必须并列呈现

| 状态 | 含义 | 对外表述 |
|---|---|---|
| `CURRENT` | 当前主仓库存在真实调用路径 | 可试用，但仍需报告 coverage 和成熟度 |
| `ADAPTER-FIRST` | 当前无自研完整 kernel，先接外部/开源工具 | 可作为 oracle/执行后端，不宣称 iEDA 自研能力 |
| `GREENFIELD` | 只有 schema、算法方案和测试计划 | 不注册生产 capability，不进入自动 commit |

任何 capability registry 必须从构建产物和 conformance test 生成，禁止从文档标题自动推导。

### 1.3 `51` 中缺少独立 owner 的能力

| `51` 能力 | 现有承接 | 缺口 | 新 owner |
|---|---|---|---|
| Intent Extractor、Constraint Completeness Prover、scenario reduce | iSTA/Observer 部分涉及 | 意图版本、审批、UPF/MMMC、约束 patch 隔离 | `48-intent-scenario-ai1.0.md` |
| connectivity/formal/legality/frozen/round-trip/signoff bundle | 各工具、Evaluation、Runtime 分散 | validator 编排、coverage、证书与失效规则 | `49-verification-hub-ai1.0.md` |
| Agent 目标分解、反思、工具选择 | Runtime 明确不内置 planner | 规划策略、计划验证、停止/升级准则 | `54-agent-planner-ai1.0.md` |
| PDK Adapter Generator、Rule-deck Compiler | Honey 有模板，iDRC/各 parser 消费 | TechContext 真值、语义映射和资格认证 | `55-technology-knowledge-ai1.0.md` |
| Failure Memory、Design Trajectory Search | Observer/Data 有局部入口 | 可检索经验对象、适用条件、负经验和遗忘策略 | `56-experience-memory-ai1.0.md` |
| Report/Log Semantic Parser、商业/开源工具接入 | Oracle/Interface 有部分职责 | 进程适配、协议化解析、版本探测、license/隔离 | `57-external-tool-bridge-ai1.0.md` |
| functional equivalence/formal ECO | iLO/iTM 与 Oracle 提到外部 formal | 领域 API、miter/proof/counterexample 语义 | `34-iFormal-ai1.0.md` |
| SI-aware route/timing closure | iSTA/iRCX/iRT 分散 | aggressor window、noise/crosstalk delta、SI gate | `35-iSI-ai1.0.md` |
| EM、aging、reliability | iIR/PDN 路线图提及 | 可靠性场景、limit source、lifetime 证据 | `36-iEM-iReliability-ai1.0.md` |
| thermal/self-heating coupling | 无独立模块 | 热网格、功耗迭代、温度依赖 derate | `37-iThermal-ai1.0.md` |
| DFM/yield、antenna/density/redundant via | iDRC/iRT 部分基础 | manufacturability risk 与 hard DRC 分离 | `38-iDFM-ai1.0.md` |
| chiplet/2.5D/3D/package-board-die | 无独立模块 | 多 die 坐标/接口/热/供电/时序契约 | `39-i3D-iPKG-ai1.0.md` |

## 2. 目标产品架构

### 2.1 当前视图与目标视图必须分开

当前可运行主链仍接近：

```text
human/Agent → Tcl or MCP script → iEDA process/singletons → logs/files
                                            └──────────────→ fixed/weak rc
```

目标 Agent 原生主链是：

```text
Goal + approved Intent + Policy + Budget
                  │
        ┌─────────▼──────────┐
        │ 54 Planner         │  plan/propose/critic; never writes DB
        └─────────┬──────────┘
                  │ typed plan
        ┌─────────▼──────────┐
        │ 41 Gateway         │  auth/schema/quota/capability discovery
        └─────────┬──────────┘
                  │
        ┌─────────▼──────────────────────────────────────┐
        │ 43 Experiment Runtime + 40 Execution Platform │
        │ branch/budget/DAG/worker/cancel/recovery       │
        └──────┬──────────────┬───────────────┬──────────┘
               │              │               │
      ┌────────▼───────┐ ┌────▼──────────┐ ┌──▼────────────────┐
      │ 48 Intent/     │ │ 55 Technology │ │ 44 Observer +     │
      │ Scenario       │ │ Knowledge     │ │ 56 Experience     │
      └────────┬───────┘ └────┬──────────┘ └──┬────────────────┘
               └──────────────┼───────────────┘
                              │ normalized context
      ┌───────────────────────▼───────────────────────────────┐
      │ Agent-native EDA capabilities                        │
      │ observe → diagnose → propose → apply(branch) → check │
      │ existing 20-33 + new 34-39                           │
      └───────────────────────┬───────────────────────────────┘
                              │ candidate snapshot/evidence
      ┌───────────────────────▼───────────────────────────────┐
      │ 49 Verification Hub → 12 Metrics/Gates               │
      │ invariants + formal + physical + signoff certificate │
      └───────────────────────┬───────────────────────────────┘
                              │ accept/reject/unknown
      ┌───────────────────────▼───────────────────────────────┐
      │ 10 Design State + Artifact CAS + Event/Decision Log  │
      └───────────────────────┬───────────────────────────────┘
                              │ paired observations
      ┌───────────────────────▼───────────────────────────────┐
      │ 45 Model Router + 47 Data/Oracle + 57 External Bridge│
      │ 46 Tool Factory (quarantine only)                    │
      └───────────────────────────────────────────────────────┘
```

### 2.2 九个平面及唯一责任

| 平面 | 唯一责任 | 不负责 |
|---|---|---|
| Agent planning | 目标分解、候选策略、何时升级/停止 | 直接改数据库、伪造验证结果 |
| Gateway/control | 身份、权限、配额、schema、capability discovery | EDA 物理算法、报告文本解析 |
| Experiment/execution | 分支、DAG、预算、worker、恢复、提交状态机 | 领域指标含义、LLM 推理 |
| State/artifact | 稳定对象、snapshot、typed delta、CAS、lineage | 决定候选好坏 |
| Intent/technology | “允许做什么”和“技术语义是什么” | 用放宽 intent 换取 PPA |
| EDA capability | 确定性观察、proposal、branch action、领域检查 | 隐式 commit、无 scope 写入 |
| Verification/evaluation | 证书、coverage、hard gate、Pareto 比较 | 生成设计动作 |
| Knowledge/model/data | 检索经验、校准、OOD、oracle、数据集 | 绕过 validator 自动上线 |
| Factory/external bridge | 受控扩展和外部工具接入 | 把 compile/report success 当物理正确 |

### 2.3 产品单位：Capability，不是进程和 Tcl 命令

每个 EDA 领域统一拆为五个分面：

```text
inspect  : 读取结构化状态和 coverage
diagnose : 给出证据化问题分解
propose  : 产生候选，不修改设计
apply    : 仅在 branch 应用 TypedDelta
verify   : 对指定 snapshot/scope 签发领域结果
```

整阶段 `run_*` 仍可作为 workflow capability，但必须由这些分面构成，并返回每一分面的真实状态。Agent 不直接持有内部 C++ 对象或跨调用裸指针。

## 3. 统一上下文与契约

### 3.1 一次调用的最小上下文

```yaml
request_id: uuid
capability: timing.top_paths@1
snapshot_ref: sha256:...
intent_ref: sha256:...
scenario_set_ref: sha256:...
tech_context_ref: sha256:...
policy_ref: sha256:...
scope: {objects: [], regions: [], layers: []}
budget: {wall_ms: 5000, cpu_ms: 20000, memory_mb: 4096}
fidelity: {requested: F2, allow_escalation: true}
seed: 17
```

五个 ref 缺一时只能执行 manifest 明确允许的降级能力。比如纯几何 query 可不需要 scenario，但 timing/IR 不能静默使用“当前默认场景”。

### 3.2 Capability Manifest

```yaml
name: route.reroute_nets
version: 1.0.0
maturity: D1
facets: [propose, apply]
reads: [placement, routing, tech, constraints]
mutates: [routing]
permissions: [R1, R2]
scope_kinds: [net, region, layer]
fidelity: [F1, F2]
supports: {partial: true, cancel: true, resume: true, deterministic: seed}
validators_required: [frozen_objects, drc.incremental, rc.scope, sta.incremental]
domain: {stages: [post_route], pdk_qualifications: []}
```

manifest 的 `maturity` 来自测试和 evidence，不由开发者手填后直接生效。`domain` 外输入返回 `UNSUPPORTED` 或请求 router 升级，不能猜测。

### 3.3 统一响应

```yaml
status: SUCCESS | PARTIAL | INFEASIBLE | UNSUPPORTED | TIMEOUT | CANCELLED | FAILED
snapshot_before: sha256:...
snapshot_after: sha256:...       # read-only 时相同；失败且无改动也相同
result_ref: cas:...
proposal_refs: []
delta_ref: null
touched: {objects: [], regions: [], layers: []}
dirty: {domains: [], objects: [], scenarios: []}
coverage: {checked: 0, skipped: 0, unsupported: 0, details_ref: cas:...}
uncertainty: {kind: none, value: null, calibration_ref: null}
artifacts: []
diagnostics: []
resume_token: null
provenance: {tool: sha256:..., model: null, tech: sha256:..., intent: sha256:...}
```

`PARTIAL` 必须同时给 `completed_scope` 和 `remaining_scope`；`TIMEOUT` 若有 incumbent 也不能改写为 success；`FAILED` 后若 snapshot hash 改变，Runtime 必须进入 `CORRUPTED_BRANCH` 并销毁该分支。

### 3.4 Proposal、Delta 与 Certificate 分离

| 对象 | 可否修改状态 | 内容 | Owner |
|---|---:|---|---|
| `Proposal` | 否 | 动作意图、前置条件、预计影响、风险和所需 validator | 各 EDA tool |
| `TypedDelta` | 仅 branch | before/after、touched、dirty、inverse/checkpoint | iDB + domain adapter |
| `MetricRecord` | 否 | value/unit/scenario/source/coverage | Evaluation |
| `ValidationCertificate` | 否 | claim、scope、checks、coverage、证据、有效期/失效域 | Verification Hub |
| `DecisionRecord` | commit 元数据 | 候选、拒绝原因、policy、批准者、证书集合 | Runtime |

低精度预测只能产生 Proposal/MetricRecord，不能伪造 Certificate。

### 3.5 证书失效是显式数据

每类 delta 发布 `InvalidationSet`。例如 `InsertBuffer` 至少失效 connectivity、placement legality、RC、setup/hold、DRV，若已布线还失效 local DRC；`ConstraintPatch` 失效所有 timing 比较基线并要求新 intent 审批。未列出的证书不得默认继续有效，必须由 certificate registry 的依赖图计算。

## 4. 工具版图

### 4.1 已有 `ai1.0` 继续承担的核心

| 类别 | 文档 | 角色 |
|---|---|---|
| 状态/数值/评价 | `10`、`11`、`12` | snapshot/delta、solver、metric/gate |
| 物理实现 | `20`-`30`、`32` | FP/NO/PL/CTS/PDN/TO/RT/STA/RCX/power/IR/DRC/ECO |
| greenfield 基础 | `31`、`33` | LVS、logic optimization/mapping |
| 执行与接口 | `40`-`43` | workflow、gateway、perf、experiment runtime |
| 智能与数据 | `44`-`47` | observer、model router、factory、data/oracle |

这些文档不因本版新增模块而废弃；新模块通过 ref、manifest、certificate 接入，禁止复制其 schema。

### 4.2 新增横向模块

| 模块 | 首个可交付切片 | 依赖 | 禁止事项 |
|---|---|---|---|
| 48 Intent/Scenario | SDC normalized IR + constraint audit + immutable approval | iSTA parser、iDB context | Agent 自动放宽约束 |
| 49 Verification Hub | validator registry + certificate + Timing ECO policy | 10/12/27/40/43 | 自建另一套 STA/DRC |
| 54 Agent Planner | schema-constrained plan + critic + stop/escalate | 41/43/44/45 | 直接调用 singleton/写主状态 |
| 55 Technology Knowledge | TechContext manifest + unit/layer/lib/via query | existing parsers | 把解析成功等价为 PDK 合格 |
| 56 Experience Memory | failure/trajectory case + applicability retrieval | 44/47 | 跨租户、同族 benchmark 泄漏 |
| 57 External Tool Bridge | fixed argv worker + report normalizer + protocol probe | 40/41/47 | `shell=True`、文本 success |

### 4.3 新增 EDA/signoff/多物理模块

| 模块 | 状态 | 起步方式 | 首个硬门禁 |
|---|---:|---|---|
| 34 iFormal | D0 | 外部 formal adapter + 小规模 combinational equivalence | 不等价必须给 counterexample/unknown，不能 success |
| 35 iSI | D0/D1 审计 | 收编 iSTA crosstalk 资产 + iRCX coupling coverage | SI on/off delta 与独立 oracle 对拍 |
| 36 iEM/iReliability | D0 | static PG/signal current rule checker + external oracle | limit source、温度、寿命和 coverage 必填 |
| 37 iThermal | D0 | steady-state grid solver + external/analytic oracle | 能量守恒、网格收敛、温度依赖迭代残差 |
| 38 iDFM | D0 | redundant-via/antenna/density analyzer，proposal-only | 不把 yield risk 当 foundry signoff |
| 39 i3D/iPKG | D0 | multi-die manifest + bump/connectivity/thermal toy solver | 跨 die 坐标、单位、接口连通性可证明 |

### 4.4 暂不独立建模块的能力

| 能力 | 暂归属 | 独立立项触发条件 |
|---|---|---|
| Local Exact Solver Builder | 11 + 46 | 至少 3 个领域共享同一建模 IR，并有性能证据 |
| Metamorphic Test Generator | 46 | 测试生成成为独立服务且有跨语言 consumer |
| Evidence Pack Builder | 12 + 49 | evidence 存储/签名吞吐成为独立扩展瓶颈 |
| Report/Log Semantic Parser | 57 | parser 数量和生命周期需要独立团队/registry |
| Rule-deck Compiler/PDK Adapter Generator | 55 + 46 | 只能由 foundry/PDK owner 资格认证，不能纯自动晋级 |
| Decision Regret Estimator/OOD Router | 12 + 45 | 避免出现第二套指标/模型注册系统 |
| Causal QoR Attributor | 44 | 与 Observer 的 EvidenceGraph 共用真值 |
| Pareto Portfolio Manager | 43 | 与 experiment/branch 生命周期不可分割 |

### 4.5 孵化工具，只冻结接入契约

下列方向不进入前 18 个月关键路径，只要求未来能以 `CapabilityManifest + TechContext + SnapshotRef + Certificate` 接入：

- library/memory/IP characterization 与库质量审计；
- standard-cell generation；
- analog/mixed-signal constraint extraction 与局部 layout validation；
- package-board electromagnetic/PI full-wave adapter；
- DTCO 和新器件规则/模型；
- spec/RTL 到物理实现的跨层逆向优化。

## 5. 新架构下的典型闭环

### 5.1 Timing ECO：首个产品闭环

```text
48 freeze intent/scenarios
  → 44 explain violations
  → 54 create auditable plan
  → 25/21/22 propose candidates
  → 45 rank + OOD/fidelity route
  → 43 fork branches
  → 10 apply typed deltas
  → 22 local legalize → 28 dirty RC → 27 dirty STA
  → 49 issue {connectivity, legality, frozen, setup, hold, DRV} certificates
  → 12 gate/Pareto
  → 43 commit one or return Pareto set
  → 56 store success/failure applicability
```

相对 `51` 的关键增强是：intent、technology 和 validation certificate 都成为显式版本对象；任何 constraint/tech 变化会阻断 before/after 比较。

### 5.2 约束调试：独立高权限流

```text
48 audit → proposed IntentPatch (never design delta)
  → evidence + affected endpoint/scenario set
  → 34 formal/structural sanity when applicable
  → R4 human/domain approval
  → create new IntentRef and new baseline
  → full timing coverage audit
```

该流不得与普通 PPA experiment 共用 commit。WNS 改善不构成 constraint patch 通过证据。

### 5.3 SI-aware route ECO

```text
35 identify victim/aggressor/window
  → 26 propose spacing/layer/shield/reroute alternatives
  → branch apply
  → 30 DRC + 28 coupling RC + 35 noise/crosstalk + 27 setup/hold
  → 49 frozen/coverage certificates
  → hard gates + Pareto {timing, noise, congestion, via, cost}
```

### 5.4 Power/thermal/reliability 闭环

```text
29 activity provenance/power
  → 37 thermal solve
  → temperature-dependent power/resistance iteration
  → 29 IR + 36 EM/lifetime
  → 24 PDN proposals
  → DRC/congestion/thermal/IR/EM certificates
  → Pareto selection
```

任何 activity、ambient、package boundary、lifetime target 缺失都必须降低 coverage 或返回 unknown，不得输出无条件“可靠”。

### 5.5 2.5D/3D 探索闭环

```text
39 multi-die assembly + interface intent
  → partition/bump/TSV proposals
  → per-die FP/place/route/PDN proxy
  → cross-die timing + thermal + power delivery
  → package feasibility/cost
  → portfolio; no tapeout commit without external signoff bundle
```

## 6. 状态、作用域与并发

### 6.1 Scope 是权限边界，不只是性能提示

统一 scope 支持 object、logical cone、clock/power domain、region、layer、scenario 和 die/package component。每个 apply 工具必须返回 `declared_scope` 与 `actual_touched_scope`，后者超出前者即失败。

### 6.2 分支合并策略

前两阶段只支持 branch-and-select。只有满足以下全部条件才允许试验性 merge：

1. touched object 不相交；
2. dirty logical/physical cone 不相交或已联合重算；
3. intent/tech/scenario ref 完全相同；
4. 组合 delta 重新通过全部证书，不能复用两个分支各自证书；
5. merge 冲突与非线性交互进入 experience memory。

### 6.3 Cache 规则

cache key 至少包含 capability/tool hash、所有 context refs、scope canonical hash、request、seed、fidelity 和 tenant。近似结果另含 model/calibration hash；validator 结果另含 rule/coverage manifest。缺字段时禁用缓存，而不是猜测可复用。

## 7. Validation Certificate 架构

### 7.1 Claim 而非 bool

```yaml
certificate_id: sha256:...
claim: timing.setup_within_budget
subject_snapshot: sha256:...
context: {intent: sha256:..., scenarios: sha256:..., tech: sha256:...}
scope: {endpoints: all}
result: PASS | FAIL | UNKNOWN | PARTIAL
coverage: {checked: 10000, skipped: 0, unsupported: 0}
evidence_refs: [cas:...]
validator: ista.setup@hash
valid_until: {invalidated_by: [NetlistDelta, RcDelta, ConstraintPatch]}
```

`UNKNOWN` 与 `FAIL` 不同，但两者默认都不能 commit。只有 policy 明确允许的软指标可以 partial/unknown 进入 Pareto；connectivity、functional equivalence（若动作需要）、legal、setup/hold、声明的 DRC rule 等硬门禁不能被其他收益抵消。

### 7.2 Policy profile

| profile | 适用 | 最低证书 |
|---|---|---|
| `explore.readonly` | 观察/诊断 | state/input integrity |
| `timing_eco.post_place` | resize/VT/move/buffer | connectivity、legal、frozen、setup+hold、DRV |
| `route_eco.post_route` | reroute/via/shield | frozen、DRC coverage、RC、setup+hold |
| `netlist_rewrite` | logic/formal ECO | formal equivalence、mapping integrity、STA |
| `pdn_reinforcement` | strap/via/decap | PG connectivity、DRC、IR residual、EM、signal congestion |
| `release.signoff` | 发布/tapeout | 外部 F4 bundle + 双审批；首版不自动提交 |

## 8. 源码落点与依赖规则

```text
src/contracts/                          # 仅公共 schema/value types
  context/ status/coverage/capability/validation/
src/database/manager/design_state/      # existing-object stable ID adapter
src/platform/design_state/              # snapshot/delta/CAS catalog
src/platform/flow/tool_flow/            # deterministic stage DAG
src/platform/agent_runtime/             # experiment/branch/budget/policy
src/interface/agent/                    # transport-neutral typed service
src/intent/                             # 48 intent/scenario
src/verification/                       # 49 registry/certificate/policy
src/planner/                            # 54 plan schema/critic; no DB writer
src/technology/                         # 55 TechContext/qualification
src/knowledge/experience/               # 56 cases/index/applicability
src/platform/external_bridge/           # 57 external process/protocol adapter
src/operation/<tool>/agent/             # tool-specific capability adapters
src/operation/iFormal|iSI|iReliability|iThermal|iDFM|iPKG/
benchmarks/{evaluation,perf-agent,data_flywheel,conformance}/
```

依赖规则：

1. `src/contracts` 不依赖任何 tool singleton；
2. EDA tool 不依赖 Planner；Planner 只看 manifest/schema；
3. Verification Hub 组合 domain validator，不重新实现 domain kernel；
4. Intent/Technology 是只读版本对象，普通 R0-R3 流不能修改；
5. Observer/Experience 不写设计；Model 不直接 apply delta；
6. external bridge 只负责进程和协议，归一化语义由 adapter + Oracle protocol 共同审核；
7. 新目录只有通过架构 review 后才加入顶层 CMake，避免空目录被误认为 capability。

## 9. 安全、治理与可运营性

### 9.1 权限拆分

| 权限 | 示例 | 审批 |
|---|---|---|
| R0 metadata | summarize/capability/manifest | tenant policy |
| R1 analysis | STA/DRC/IR/observer | resource quota |
| R2 branch mutation | local ECO/reroute | branch only + validators |
| R3 design commit | approved delta | Runtime policy + evidence |
| R4 intent/technology | SDC/UPF/rule/PDK mapping | domain owner explicit approval |
| R5 release/signoff | GDS/signoff bundle | dual approval + external certificate |

Planner 的 token/角色不授予权限；权限由 Gateway/Runtime 根据主体、tool manifest、scope 和 policy 判定。

### 9.2 多租户和供应链

- snapshot、feature、prompt、日志、商业 report、model cache 全部带 tenant；
- 外部 binary、container、PDK、model、generated package 全部保存 digest/SBOM；
- 生成/外部工具默认无网络、只读 base snapshot、固定 argv、资源上限；
- tool/model/tech/intent 变更触发对应证书失效和 qualification；
- 生产 capability registry 与 quarantine registry 物理/逻辑隔离。

## 10. 实施 Wave 与退出条件

### Wave 0A：事实化底座（W1-W4）

在现有 `52` Wave 0 上增加：

- 冻结 `ContextRefs`、`CapabilityManifest`、`ValidationCertificate`；
- 48 提供只读 SDC intent/scenario manifest；
- 55 提供只读 TechContext manifest；
- 49 注册 state/input/constraint coverage 三类 validator；
- 57 替换普通 Agent 的任意 shell 调用路径。

退出：任一 timing 查询都能回答“哪个 snapshot、intent、scenario、tech、tool、coverage”；缺失时非 success。

### Wave 1A：可提交 Timing Lab（W5-W13）

- 54 只做 schema-constrained planner baseline，允许规则/搜索基线替代 LLM；
- 49 发布 `timing_eco.post_place` certificate bundle；
- 56 记录所有候选的失败域和适用条件；
- 34 仅在 buffer/netlist topology action 上接 external formal shadow check。

退出沿用 `51 §11.3`，并新增：500 次提交证书依赖无漏失效；constraint/tech ref 变化 100% 阻断旧 baseline 复用。

### Wave 2A：Route/DRC/SI（M4-M8）

- 35 先做 coupling/noise inspect 和 proposal scoring，不先做自动 action；
- route delta → DRC/RC/STA/SI 证书链；
- 38 只做 DFM analyzer/proposal，不作为硬 signoff。

退出：SI on/off 独立对拍、frozen nets 零变化、DRC skipped 非 clean、DFM 改善不引入 hard violation。

### Wave 3A：Power/Thermal/Reliability（M7-M14）

- 36 static EM + lifetime context；
- 37 steady thermal + power-temperature 固定点；
- PDN action 联合 IR/EM/thermal/congestion/DRC。

退出：解析小例守恒/残差通过；外部 oracle protocol 固定；unknown input 不输出 unconditional pass。

### Wave 4A：Cross-layer/3D（M12-M24）

- 34 formal 内核/adapter 产品化；
- 39 multi-die state 与 package adapter；
- iLO/iTM/LVS 接入 formal/technology/verification；
- Honey 生成的 adapter/analyzer 进入 shadow/quarantine。

退出：至少一个跨层闭环有真实 consumer 和独立 oracle；没有闭环消费的新 tool 不晋级 D2。

## 11. 验证矩阵

| 层 | 必测 | 失败判定 |
|---|---|---|
| Schema | version、unknown field、unit、ID generation | 解析宽松吞字段即失败 |
| State | apply/rollback/replay/hash、crash | 主 snapshot 污染即停止扩工具 |
| Scope | declared vs touched/frozen/dirty | 越域对象数非 0 |
| Tool | golden、metamorphic、differential、unsupported | 假 success/静默 skip |
| Incremental | dirty vs full periodic oracle | 超容差时禁增量 commit |
| Planner | invalid plan、tool hallucination、loop、budget | manifest 外调用或无界重试 |
| Model | family/PDK holdout、regret、calibration/OOD | 高置信 false-negative 超预算 |
| Certificate | dependency invalidation、coverage、expiry | 复用已失效证书 |
| External | rc、timeout、license、parser version drift | 文本 success 覆盖失败 rc |
| Security | tenant、path、command、network、artifact | 任一越权读取/写入 |

## 12. 统一指标

不引入“Agent EDA 总分”。至少独立报告：

- correctness：invalid commit、rollback mismatch、certificate invalidation miss；
- decision：Recall@K、selection regret、accepted action rate、hard-gate false negative；
- closure：time-to-first-feasible、WNS/TNS/endpoint、DRC by rule、IR/EM/thermal residual；
- scope：touched object/area、frozen violation、incremental/full delta；
- evidence：coverage、unknown/unsupported、replay success；
- cost：wall/CPU/RSS/GPU/license minutes/Agent calls；
- generalization：design-family、PDK、stage、topology coverage；
- operations：cancel latency、recovery rate、cache correctness、tenant isolation。

## 13. 优先级和资源闸门

### 13.1 必做顺序

```text
P0: state/rc/schema → intent/tech refs → validation certificate
P1: Timing Lab adapters → planner baseline → experience capture
P2: route/DRC → SI inspect → DFM proposal
P3: power/PDN → thermal/EM/reliability
P4: formal self-hosting → logic/LVS → 3D/package incubation
```

P0 未过时，不增加 P2/P3 的自动写工具。团队可以并行做 D0 研究和 external adapter，但不能注册 R2/R3 capability。

### 13.2 新模块立项模板

每个新工具开始编码前必须回答：

1. 真实 consumer 是哪个闭环；
2. 输入 context refs 是否齐全；
3. inspect/propose/apply/verify 哪些分面首发；
4. 失败、partial、unsupported 如何区分；
5. 最小独立 oracle 和可杀假说是什么；
6. 写操作的 typed delta、scope、inverse 和必需证书；
7. D0→D1→D2→D3 的机器证据；
8. 为什么不应由现有模块 Composition 承担。

## 14. 前 16 个新增 issue

1. 冻结五个 `ContextRef` schema 和 canonical hash；
2. 为现有 timing query 生成 IntentRef/ScenarioSetRef/TechContextRef；
3. 冻结 `ValidationCertificate` 与 invalidation rules；
4. 建 validator registry，接 state.validate/constraint coverage；
5. 为 Timing ECO 定义 policy profile；
6. 修 MCP 任意脚本主入口和 iEDA rc 传播；
7. 建 external worker 固定 argv、timeout、artifact protocol；
8. 实现 SDC normalized IR 与 unconstrained/exception audit；
9. 实现 library/layer/via/unit 的 TechContext query；
10. 让 Planner 只消费 capability registry，拒绝未知工具名；
11. 建 FailureCase/TrajectoryCase schema 和 tenant/family split；
12. 接一个 external formal adapter 做 buffer ECO shadow validation；
13. 审计 iSTA crosstalk 代码并冻结 SI coverage baseline；
14. 用解析小网格建立 thermal/EM gold cases；
15. 建 certificate invalidation property test；
16. 将新增模块 maturity/capability 自动汇总到 `52` 机器索引。

## 15. 明确不做

1. 不把新增 12 份文档写成 12 个同时开工的项目；
2. 不因 iSTA 有 crosstalk 文件就宣称 SI signoff 已有；
3. 不因 external formal/thermal/EM 工具能启动就宣称自研 kernel 完成；
4. 不让 Planner 通过 Tcl、shell 或 Python 反射绕过 manifest；
5. 不把 intent/PDK/rule 修改当普通 design delta；
6. 不让 Verification Hub 平行重写 STA/DRC/LVS/formal 内核；
7. 不把 DFM/yield score 当 foundry hard DRC；
8. 不在 activity/ambient/lifetime/package 边界未知时输出精确可靠性结论；
9. 不在 2D 状态/事务不稳定时建设生产级 3D 自动优化；
10. 不把历史相似案例当 oracle；经验只能形成 proposal 或先验。

## 16. 决策记录

| 决策 | 采用 | 被否方案 | 理由 |
|---|---|---|---|
| 设计意图 | 独立 immutable context | 塞进 iDB 或 iSTA 当前配置 | intent 权限/审批/失效语义不同 |
| 验证 | certificate hub 组合领域 validator | Runtime 中堆 bool gate | coverage、证据和失效需统一 |
| PDK | TechContext service + qualification | 每工具各读各解释 | 防单位/层/库族语义漂移 |
| Planner | 与确定性 Runtime 分离 | LLM 直接驱动 singleton | 便于权限、重放和替换策略 |
| 未来工具 | adapter-first + D0 明示 | 先造空目录/命令 | 避免存在性与成熟度混淆 |
| 经验 | 案例+适用域+负结果 | prompt/RAG 任意文本库 | 需要可审计、隔离和防泄漏 |
| 多 Agent | branch-and-select 优先 | 自动合并优先 | 物理/时序交互非线性强 |

## 17. 可机器检查的架构不变量

| ID | 不变量 | CI/运行时检查 |
|---|---|---|
| INV-01 | 写设计只能通过 TypedDelta + transaction | 链接/调用边界扫描；主 snapshot hash guard |
| INV-02 | Planner 不拥有 DB、shell、validator 权限 | manifest permission test；adversarial plan |
| INV-03 | Intent/Technology 不属于普通 DesignDelta | schema namespace 与 R4 approval test |
| INV-04 | success 必须带 result/coverage/provenance | response conformance suite |
| INV-05 | commit 必须有 current complete bundle | Runtime state-machine property test |
| INV-06 | certificate 不超出 validator qualification | Issuer claim/scope/rule/scenario check |
| INV-07 | context/schema/tool 变化显式失效 | dependency graph mutation test |
| INV-08 | 外部/生成代码不直接写主状态 | sandbox mount/ACL/side-effect test |
| INV-09 | tenant/license/retention 沿 lineage 传播 | cross-tenant and tombstone tests |
| INV-10 | nondeterministic 决策仍可证据重放 | seed/request/response/candidate hash check |

架构 review 只能增加或显式版本化这些不变量，不能由某个 consumer 暂时豁免。临时兼容路径也必须在 Gateway/Runtime 前被同一检查包围，并有删除日期和 owner。

## 18. 三条控制序列

### 18.1 Read/Inspect

```text
Client -> Gateway(auth/schema/rate)
  -> Runtime(resolve immutable context + capability qualification)
  -> Platform worker -> domain adapter/kernel
  -> StageResult(coverage/provenance/artifacts)
  -> Observer/Client
```

只读不代表无约束：仍需固定 snapshot/context、预算、取消和 tenant artifact ACL。缓存必须命中完整 context 和 tool/schema qualification。

### 18.2 Propose/Explore

```text
Goal -> Planner(typed PlanGraph) -> PlanValidator
  -> Runtime fork branches -> proposal/apply in isolated txn
  -> low/high fidelity evaluation -> Verification plan
  -> verified Pareto portfolio + DecisionRecord
```

模型、Experience 和 Honey package 都只能影响 proposal/rank；Runtime 对能力、权限、预算和 DAG 做最终解释。

### 18.3 Commit

```text
candidate snapshot + typed delta + policy
  -> Verification Hub required claim closure
  -> qualified validators -> current complete Bundle
  -> Runtime recheck base head/context/capability
  -> compare-and-swap commit -> new SnapshotRef
  -> invalidate dependent cache/certificates -> append trajectory
```

commit 失败不改变主 head，候选仍作为历史 branch/evidence。不存在“工具返回 success 后顺便 commit”的旁路。

## 19. 降级模式与可用性语义

| 不可用组件 | 允许降级 | 不允许伪装 |
|---|---|---|
| Model Router/LLM | rule/beam baseline、人工 proposal | 取消 schema/permission/verification |
| Experience Memory | 无先验搜索 | 把当前设计数据当历史经验 |
| external oracle/license | 保留 F0-F3 探索或等待 | 把低精度结果升级为 F4 |
| incremental validator | full validator | 跳过 required claim |
| Verification Hub issuer | inspect/propose/shadow | commit |
| Intent/Tech service | replay 已固定且 current 的 refs | 使用工具私有默认配置 |
| artifact/CAS 部分故障 | 已缓存可校验只读结果 | 签发无原始证据的新证书 |
| Planner | 固定 workflow | Runtime 自己猜 action |

服务状态统一为 `AVAILABLE/DEGRADED/READ_ONLY/UNAVAILABLE`，并附受影响 capability/domain。Gateway 在调用前返回可解释拒绝；不能执行一半后用自然语言 warning 表示降级。

## 20. 部署拓扑与演化规则

逻辑边界不强制首版拆微服务。支持三种部署：

1. 单进程开发：typed interface 仍生效，外部/生成工具保持子进程隔离；
2. 本地 worker pool：Platform 管资源和 legacy singleton 隔离，CAS/Registry 共享；
3. 多服务/多租户：Gateway、Runtime、worker、model、data 分离，增加 mTLS/签名/配额。

无论拓扑，ObjectId、context refs、StageResult、error、certificate 和 audit event 的语义相同。进程内指针、singleton 或本地路径不能出现在跨边界 schema 中。拓扑变化只影响 transport/deployment qualification，不应改变领域结果；必须用同一 golden trace 对拍。

首批必须单独记录的 ADR：snapshot 存储格式、event journal/CAS 一致性、schema 编码、worker 隔离级别、issuer 信任模型、tenant encryption key、external license 调度、模型服务部署。每项 ADR 给出负载/故障实验和回滚路径，不能仅凭框架偏好决定。

## 21. 公共类型系统与 schema ownership

### 21.1 类型分层

| 类型层 | 示例 | Owner | 依赖限制 |
|---|---|---|---|
| Identity | ObjectId、SnapshotRef、ArtifactRef、TenantRef | 10/40 | 不依赖领域 tool |
| Context | IntentRef、ScenarioSetRef、TechContextRef、PolicyRef | 48/55/49 | immutable、内容寻址 |
| Invocation | CapabilityManifest、InvocationContext、Budget、StageResult | 40/41/43 | 不包含进程内指针/路径 |
| State change | Proposal、TypedDelta、Scope、DirtySet、InvalidationSet | 10 + domain owner | IntentPatch 独立命名空间 |
| Evidence | MetricRecord、ValidatorResult、Certificate、Bundle | 12/49 | metric 与 claim 不互转 |
| Decision | GoalSpec、PlanGraph、DecisionRecord、ExperienceCase | 54/43/56 | 不授予执行权限 |
| Supply/Data | Model/Dataset/Oracle/ToolPackage/Adapter manifest | 45/47/46/57 | qualification 与 tenant lineage |

公共 schema 只允许 owner 发布版本。domain 文档可以组合、约束或扩展 namespaced payload，但不能重定义 `status`、`coverage`、`scope`、`fidelity` 等公共字段。跨边界 schema 使用稳定编码和 canonical serialization；hash 不依赖 map iteration、locale、时间戳或临时路径。

### 21.2 兼容与演化

- major 变化要求显式 adapter/migration 和所有 consumer requalification；
- minor 只新增被声明为 non-semantic/optional 的字段；
- unknown semantic field、enum、unit 或 claim 默认 fail closed；
- writer 保存 exact schema ref，reader 不按“最新版本”猜解释；
- replay 优先原版本；migration 生成新 artifact 和 semantic diff；
- schema owner 维护 golden fixtures、invalid fixtures 和 producer/consumer matrix。

## 22. 状态、一致性与事件模型

### 22.1 聚合与存储

| Aggregate | 权威状态 | 一致性要求 |
|---|---|---|
| Design head/branch | snapshot catalog + transaction journal | head 强一致 CAS；snapshot immutable |
| Experiment/Plan/Job | append-only event journal | aggregate 内有序；跨 aggregate 通过 refs |
| Registry/Qualification | registry DB + revocation log | 新调用强制 freshness；历史可重放 |
| Artifact/Evidence | CAS + metadata catalog | hash integrity；删除产生 tombstone |
| Cache/Index | 派生存储 | 可丢、可重建、读时校验 refs |
| Dataset/Model/Experience | immutable versions + lineage graph | tenant/license/retention 传播 |

系统不要求跨所有服务全局事务。设计 commit 使用本地强一致 catalog/journal；对 cache、trajectory、metrics 和 invalidation 的发布使用 transactional outbox + idempotent consumer。任何 consumer 延迟都不能让 Runtime 绕过 commit 前 freshness check。

### 22.2 Event envelope

```text
DomainEvent
  event_id / aggregate_type / aggregate_id / sequence
  event_type + schema_ref + occurred_at
  actor/tenant/correlation/causation IDs
  subject/context refs
  payload_ref + provenance
```

consumer 以 `(aggregate_id, sequence)` 去重和检测缺口；乱序时暂停该 aggregate 投影，不用 arrival time 重排事实。revoke/tombstone 属高优先事件，但读路径仍通过当前 Registry/CAS 状态兜底。

### 22.3 Saga 边界

长流程不是数据库分布式事务：Runtime saga 显式执行 fork、reserve、apply、analyze、verify、select、commit/rollback。每步有幂等键和补偿动作；无法补偿的外部副作用在 R2/R3 能力中禁止。补偿失败进入 `RECOVERY_REQUIRED`，冻结 branch，不能继续 commit。

## 23. 控制平面与数据平面的接口

```text
Control plane
  Registry / Policy / Planner / Runtime / Budget / Scheduler
       | resolved immutable manifests and refs
       v
Execution plane
  isolated workers / domain adapters / legacy kernels / external tools
       | typed results, artifacts, events
       v
Evidence plane
  CAS / Metrics / Certificates / Trace / Data / Experience
```

控制平面决定“谁、何时、以何预算运行哪项已注册能力”，不修改领域结果；执行平面计算但不决定 commit；证据平面持久化但不授予权限。Model Router 和 Planner 属控制建议源，Verification Issuer 属证据信任边界，二者不在同一授权角色。

Worker 接口只接收 PreparedInvocation：resolved input mounts、fixed capability build、context、scope、budget、secret handle 和 expected artifacts。worker 无权查询任意 tenant Registry、改变 policy 或选择另一个 binary。StageResult 先写 artifact/hash，再提交 terminal event。

## 24. 威胁模型与确定性防线

| 威胁 | 攻击面 | 架构防线 | 验证 |
|---|---|---|---|
| Prompt/report injection | Planner/Observer/parser 文本 | untrusted data 标记、typed plan、无自由命令 | adversarial corpus |
| Capability confused deputy | Planner 借高权限 tool 越 scope | actor+manifest+scope 三重鉴权 | permission property |
| Constraint/PDK cheating | 以改 intent/tech 改善 PPA | R4 独立 patch/approval/new baseline | context drift test |
| Stale evidence replay | cache/certificate/artifact | complete key、freshness、revocation、tombstone | mutation sequence |
| Generated/external code | package/adapter/worker | quarantine、SBOM、fixed argv、sandbox | escape/secret/network tests |
| Cross-tenant leakage | cache/model/data/log | tenant-bound refs、ACL、lineage、redaction | two-tenant fixtures |
| Resource denial | branch/tool/model/license | reservation ledger、quota、cancel/process group | stress/failure injection |
| Supply-chain substitution | binary/model/PDK/parser | digest/signature/qualification pinning | artifact swap test |
| Audit deletion/equivocation | journal/evidence | append-only sequence、CAS hash、issuer identity | recovery/rebuild test |

LLM 的系统提示、角色名和自然语言承诺都不是安全边界。所有防线落在 deterministic schema、Gateway、Runtime、worker isolation、Issuer 和 Registry。

## 25. 架构符合性测试与 fitness functions

| Fitness ID | 持续检查 | 失败动作 |
|---|---|---|
| ARCH-F01 | `contracts` 无 tool/singleton 依赖 | 阻断 PR |
| ARCH-F02 | Planner/Observer/Model 无 iDB writer/shell 依赖 | 阻断 PR |
| ARCH-F03 | 所有 R2/R3 capability 声明 delta/scope/validator | Registry 不发布 |
| ARCH-F04 | response success 均有 context/coverage/provenance | conformance fail |
| ARCH-F05 | certificate claim 不超过 qualification domain | issuer 拒签 |
| ARCH-F06 | cache key 覆盖 semantic inputs | 禁用该 cache |
| ARCH-F07 | external/generated worker base snapshot 只读 | quarantine |
| ARCH-F08 | schema owner/consumer 无重复定义 | contract review fail |
| ARCH-F09 | event projection 可从 journal/CAS 重建 | release fail |
| ARCH-F10 | dependency outage 只进入允许 degraded mode | release fail |

静态检查覆盖 include/link/schema ownership；动态检查覆盖 state machine、scope、failure、security；benchmark fitness 覆盖 correctness、decision、cost 和 generalization。架构图中的箭头若没有至少一个 fitness function，不能视作已受治理的边界。

## 26. 仍需实验决策的 ADR

| ADR | 需验证选项 | 决策数据 | 截止 gate |
|---|---|---|---|
| ADR-01 Snapshot encoding | base+delta、自研 binary、现有 file manager 混合 | replay/size/load/crash | Wave 0 |
| ADR-02 Journal/CAS consistency | embedded DB、service DB、filesystem catalog | atomicity/recovery/ops | Wave 0 |
| ADR-03 Schema encoding | JSON/Protobuf/FlatBuffers 组合 | compatibility/perf/debug | Wave 0 |
| ADR-04 Worker isolation | process、container、microVM | singleton/security/startup | Wave 0-1 |
| ADR-05 Legacy session model | rebuild、session pin、copy-on-write | correctness/RSS/latency | Wave 1 |
| ADR-06 Issuer trust | local ACL、service signing、offline signing | deployment/threat/audit | Wave 1 |
| ADR-07 Multi-agent merge | branch-select、disjoint merge | nonlinear interaction rate | Wave 2+ |
| ADR-08 Multi-region/HA | single-site、replicated CAS/registry | RPO/RTO/cost | Product gate |

ADR 在决策前保持接口抽象，但禁止同时实现多套生产后端。每项记录 hypothesis、benchmark、chosen/rejected、migration 和 rollback；结果同步回 51/52 owner 条目。

## 27. 组件端口与实现边界

架构图中的每条边必须落成一个 transport-neutral port。端口只传 immutable ref、typed value 和 `StageResult<T>`；本地对象指针、singleton、工作目录、环境变量和日志文本不能成为跨组件依赖。

| 组件端口 | 最小操作 | 输入 | 输出 | 不允许承担 |
|---|---|---|---|---|
| `CapabilityRegistryPort` | `discover/resolve/check_freshness` | actor、query、capability ref | frozen manifest/qualification | 执行工具或放宽权限 |
| `ContextResolverPort` | `resolve_intent/resolve_scenarios/resolve_tech/resolve_policy` | tenant + immutable refs | validated context bundle | 使用工具私有默认值 |
| `DesignStatePort` | `resolve/fork/apply/rollback/commit` | snapshot/branch/delta/lease | snapshot ref、touched/dirty/invalidation、commit record | 判断候选 QoR 优劣 |
| `ExecutionPort` | `prepare/execute/cancel/resume` | resolved invocation + mounts + budget | stage result、artifact refs、resource record | 改 policy 或选择其他 binary |
| `DomainCapabilityPort` | `inspect/diagnose/propose/materialize/validate` | invocation context + domain payload | observation/proposal/delta/validator result | 隐式 commit 主状态 |
| `EvaluationPort` | `measure/compare/gate` | frozen subject/context/metric policy | metric bundle、comparison、gate evidence | 签发领域 correctness claim |
| `VerificationPort` | `plan/run/issue_bundle/check_current` | subject、delta/invalidation、policy | claim results、certificates、bundle | 自建平行 STA/DRC 内核 |
| `ExperimentPort` | `begin/fork/run/select/commit/cancel` | goal/plan/context/budget | experiment/decision/terminal record | 解释自然语言或修改领域算法 |
| `ArtifactPort` | `put/get/pin/tombstone` | bytes/manifest/ACL/retention | content ref + integrity metadata | 决定业务 success |
| `EventJournalPort` | `append/read/subscribe` | aggregate sequence + typed event | durable offset/ordered events | 以投影代替权威 head |

接口实现可以首版同进程，但依赖方向必须与端口一致。`Runtime` 可依赖 `DesignStatePort`，不能链接 iDB writer；`Planner` 可依赖 Registry/Observer 的只读接口，不能依赖 `ExecutionPort` 的任意命令入口；domain adapter 可链接自己的 legacy kernel，不能反向依赖 Planner、Gateway 或 Evaluation。

### 27.1 `PreparedInvocation` 交接点

Gateway 和 Runtime 完成鉴权、manifest/context 解析与预算预留后，才允许产生执行平面唯一接受的对象：

```yaml
invocation_id: uuid
idempotency_key: sha256:...
actor_ref: tenant:subject
capability_ref: timing.top_paths@sha256:qualification
context_bundle_ref: cas:context-bundle
subject_snapshot_ref: sha256:...
branch_ref: null
scope_ref: cas:scope
request_ref: cas:typed-request
input_mounts:
  - {artifact_ref: cas:..., mount_name: design, mode: read_only}
budget_reservation_ref: cas:budget
worker_profile_ref: cas:worker-profile
expected_outputs: [timing-path-set@1, execution-log@1]
deadline: 2026-07-24T18:00:00+08:00
seed: 17
```

worker 返回结果前先发布所有声明 artifact，随后原子记录 terminal `StageResult`。如果 worker 丢失，Runtime 以 idempotency key、journal 和 artifact manifest 区分“未开始、执行中、产物已写但未确认、已终态”，不能盲目重跑写操作。

### 27.2 依赖防火墙

| 源 target | 允许依赖 | CI 必须拒绝 |
|---|---|---|
| `ieda_agent_contracts` | STL、选定 schema runtime | iDB/tool/platform/shell |
| `ieda_design_state` | contracts、iDB stable-ID/file adapter | Planner/model/domain optimizer |
| `ieda_agent_runtime` | contracts、port interfaces、journal/CAS client | tool singleton、Tcl command |
| `ieda_agent_gateway` | contracts、registry/runtime client、auth | domain kernel、DB writer |
| `<domain>_agent_adapter` | contracts、domain kernel、worker SDK | Planner、Gateway、commit catalog |
| `ieda_verification` | contracts、validator ports、policy | 复制 domain kernel |
| `ieda_planner` | contracts、registry/observer client | state writer、shell、issuer key |

该表用 include/link allowlist 和最小链接测试落实。为绕开循环依赖而把公共类型移回某个 domain target 视为架构回归。

## 28. 首个可执行参考装配

首个开发环境只需要单进程控制面加隔离 worker，不需要先拆微服务。必须提供一个不依赖 LLM、不依赖商业 license 的确定性 reference assembly，用小设计贯通真实端口：

```text
AgentGateway
  -> LocalCapabilityRegistry
  -> AgentRuntime + EmbeddedJournal + LocalCAS
  -> DesignStateService + iDB adapter
  -> ProcessWorkerPool
       -> iSTA read adapter
       -> iTO proposal/materialization adapter
       -> iPL local-legalize adapter
       -> iRCX dirty-RC adapter
  -> EvaluationService
  -> VerificationHub
```

### 28.1 启动与健康顺序

1. 校验 schema bundle、Registry snapshot、policy 和 issuer trust roots；
2. 打开 CAS/journal，恢复未完成 aggregate，验证 design head 与 outbox；
3. 注册 worker profile，只加载 digest 与 qualification 均匹配的 adapter；
4. 解析只读 Intent/Scenario/Tech context 并跑 input-integrity validator；
5. 发布 R0/R1 capabilities；R2 仅在 branch/crash/rollback suite 通过后发布；
6. R3 默认关闭，直到 current certificate bundle 和 atomic commit suite 通过；
7. 对外 health 同时报告 `AVAILABLE/DEGRADED/READ_ONLY/UNAVAILABLE` 及被禁用 facet。

启动失败不得通过空 Registry、默认 PDK、跳过 recovery 或禁用 validator 来获得绿色 health。

### 28.2 两条 release trace

只读 trace 必须先通过：

```text
discover -> resolve contexts -> resolve snapshot -> execute top_paths
  -> normalize MetricRecord -> persist evidence -> replay same result
```

写 trace 随后在相同 assembly 中通过：

```text
begin experiment -> propose Resize/SwapVt -> fork -> apply journaled delta
  -> local legalize -> dirty RC -> dirty STA -> evaluation compare
  -> issue required bundle -> deterministic select -> head CAS commit
  -> publish invalidation/trajectory -> replay decision and commit
```

每个箭头至少有一个 contract fixture、一个成功集成例和一个失败注入例。写 trace 任一步失败时，主 head、scope 外对象和冻结 intent/tech refs 必须不变；已完成的 stage/artifact 仍需可审计。

### 28.3 架构验收记录

reference assembly 的 release artifact 至少包含：build digest、schema bundle、Registry snapshot、context bundle、golden input snapshot、完整 event trace、所有 StageResult、certificate bundle、DecisionRecord、CommitRecord、资源 trace 和 replay report。缺少任一项时只能称为 demo，不能作为 Agent-native MVP 发布。

## 29. 文档与版本历史

本文件是架构主图；模块 API/LLD 以 `34`-`39`、`48`-`49`、`54`-`57` 的对应实施文档为准；已有模块以 `10`-`47` 对应文档为准。字段冲突时先修改 owner 文档并记录 schema migration，禁止在 consumer 文档复制后私自演化。尚未创建或仍在深化的文档不得被索引为“已完成”。

- v2.3（2026-07-24）：增加 transport-neutral 组件端口、`PreparedInvocation` 交接、构建依赖防火墙，以及可直接落地的单进程控制面/隔离 worker reference assembly 和 release trace。
- v2.2（2026-07-23）：按模块深化计划补充公共类型所有权、聚合/事件/Saga 一致性、控制与执行平面、威胁模型、architecture fitness functions 和 ADR 实验表。
- v2.1（2026-07-23）：增加十条机器架构不变量、read/propose/commit 控制序列、显式降级模式、部署拓扑与首批 ADR。
- v2.0（2026-07-23）：基于 `51`、全部现有 `*-ai1.0.md` 与当前源码入口审计，新增 Intent/Scenario、Verification Hub、Planner、Technology Knowledge、Experience Memory、External Bridge，以及 formal/SI/reliability/thermal/DFM/3D-package 工具规划；明确 CURRENT/ADAPTER-FIRST/GREENFIELD 双视图与分阶段门禁。
