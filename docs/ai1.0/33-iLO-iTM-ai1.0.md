<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 33 · iLO/iTM Agent 逻辑优化与工艺映射实施方案 · ai1.1

> 文档状态：`TARGET/DRAFT`，日期：2026-07-24。
>
> CURRENT 事实：`src/operation/iLO/CMakeLists.txt` 与 `src/operation/iTM/CMakeLists.txt` 均为空文件。仓库没有 iLO/iTM API、IR、优化器、映射器、测试目标或可执行内核，也没有 `iFormal` 源码目录。本文的 iLO/iTM、LogicIR、iFormal 接口和 Agent capability 均是 TARGET，不得解释为已实现。
>
> 可复用基线：仓库已有 gate-level Verilog/Liberty parser、iDB Verilog import/export、iSTA netlist/SDC/STA、iNO fanout repair、iTO timing repair、映射后网表与 SDC benchmark。`benchmarks/flows/synthesize_aes_multi_pdk.py` 和 `benchmarks/synthesis/*.ys` 证明 Yosys/ABC 能在特定主机上完成过 AES spike，但它们使用绝对路径、宿主环境和直接脚本执行，缺少 hermetic manifest、稳定身份、结构化结果与 formal evidence，不能算集成后端或产品能力。
>
> 首要安全结论：**QoR 改善、仿真通过、结构哈希相似或 iSTA/iPL 指标改善都不能证明功能等价。每个可交付优化/映射候选必须经 Verification Hub 调用 qualified iFormal/external formal adapter 得到 `functional.equivalent = PASS`；`UNKNOWN`、`PARTIAL`、timeout 或缺 validator 一律不可提交。**

---

## 0. 目标、非目标、所有权与成功定义

### 0.1 目标

iLO/iTM 向 Agent 提供可审计的逻辑优化与工艺映射决策服务，而不是开放一个可拼任意 Tcl 的综合 shell：

```text
immutable RTL/netlist + IntentRef + ScenarioSetRef + TechContextRef
  -> import/canonicalize LogicIR
  -> inspect/diagnose
  -> propose typed, bounded strategies
  -> optimize technology-independent logic
  -> map to a qualified library set
  -> prove functional equivalence independently
  -> compare candidates at declared QoR fidelity
  -> materialize selected LogicDelta on an isolated iDB branch
  -> validate certificates and evidence
  -> Runtime alone decides commit or returns a Pareto frontier
```

首版必须做到：

- 输入、约束、技术、工具、策略、seed、预算和产物全部内容寻址、版本化、可重放；
- 能导入结构化门级 Verilog，并通过 qualified external frontend 扩展到 synthesizable RTL；
- 保留 hierarchy、clock/reset、blackbox、`dont_touch`、power-domain 和 source/name lineage；
- 让 Agent 分清观察、诊断、提案、候选 artifact、数据库 delta、formal proof、certificate 与提交决定；
- 以 Yosys/ABC 等 proven library/tool 为首个优化/映射后端，native kernel 只在可测缺口成立后分切片建设；
- 对 Boolean rewrite、cut mapping、portfolio、物理反馈和停止条件给出确定性、有限预算的实现规则；
- 对任何 unsupported、partial、timeout、parser drift、proof unknown 和 unmapped state fail closed；
- 在相同 base/context/protocol 下报告独立 QoR 分量、Pareto、uncertainty 和选择 regret；
- 支持 branch-first apply、rollback、cancel、crash recovery 与 clean-process replay；
- 形成可供 Yosys、commercial synthesis/formal oracle 对拍的 hermetic protocol。

### 0.2 非目标

- 首版不自研完整 RTL elaborator、SystemVerilog frontend、SDC/UPF 解释器、SAT solver 或 signoff STA；
- 不宣称 iNO fanout repair 或 iTO buffer/resize 是完整逻辑综合/technology mapping；
- 不支持未明确建模的 latch inference、retiming、clock gating insertion、state re-encoding、scan/DFT、memory compiler、analog/mixed-signal、bidirectional bus synthesis 或多驱动 tri-state 优化；
- 不把任意 LLM 文本转换为 Yosys/ABC/commercial tool 命令；只执行注册的 typed strategy 与固定 argv/template；
- 不让 iLO/iTM 修改当前 committed iDB、IntentRef、ScenarioSetRef、TechContextRef 或 validation policy；
- 不用一个隐藏加权总分抵消 formal、clock/reset、protection、unmapped、timing/DRV 等硬失败；
- 不因外部工具返回码为 0、日志包含 `success` 或生成了非空网表就签发成功；
- 不承诺替代 DC/Genus/Formality/Conformal 等商业工具，也不把商业工具品牌自动视作 oracle；
- 不把 F0-F3 proxy 校准结果、学习模型排名或 PPA 改善当作 correctness certificate；
- 不在缺少持久化状态、inverse/checkpoint 或 crash test 时发布 R2/R3 mutation capability。

### 0.3 唯一责任

| 模块 | 唯一负责 | 明确不负责 |
|---|---|---|
| iLO（本文） | LogicIR、结构/Boolean 审计、technology-independent rewrite、strategy proposal、rewrite lineage | technology cell 选择、DB commit、formal certificate 自签 |
| iTM（本文） | qualified cell-function view、cut/supergate mapping、mapping candidate、映射 coverage | Liberty/PDK 真值所有权、placement、signoff timing |
| iDB（10） | Snapshot/ObjectId/TypedDelta/transaction/rollback/replay、mapped netlist materialization | 候选 QoR 排名、综合算法 |
| Intent/Scenario（48） | clock/exception/protection/power intent 的不可变真值与 coverage | 优化约束或为 QoR 放松 intent |
| Technology（55） | Liberty/LEF/PVT/cell family/function/dont-use/qualification 真值 | 执行 mapping 或暗示同名 cell 等价 |
| iFormal/external bridge（57） | 独立 CEC/SEC 执行与 normalized proof result；CURRENT 为 greenfield/external adapter | PPA 排名、自动放宽 proof policy |
| iSTA（27） | timing/slew/load/required-time/criticality 分析 | 功能等价证明、mapping winner 选择 |
| iPL（22） | placement/geometry/congestion/early physical observation | Boolean correctness |
| iTO/iNO（25/21） | mapped branch 上的 timing/fanout ECO proposal 与独立 delta | generic synthesis、未证明的等价 cell 资格 |
| iEval（12） | metric 归一化、可比性、Pareto、fidelity/uncertainty、QoR gate | 生成 rewrite 或 correctness certificate |
| Verification Hub（49） | 规划 validator DAG、检查 coverage、签发 current certificate bundle | 重写 formal/STA 算法或决定 QoR winner |
| Runtime（43） | experiment/branch/budget/cancel/select/commit/abandon | 改写领域结果或绕过 certificate |

边界结论固定为：**iLO/iTM 产生候选，不接受自己的候选；iFormal 证明功能，不证明 QoR；iEval 比较 QoR，不证明功能；Runtime 提交，但不生成设计动作。**

### 0.4 成功定义

`ai1.1` 实施成功不是“能跑一次 Yosys”。至少满足：

1. `logic.import/inspect/diagnose/propose/optimize` 与 `mapping.map/compare/validate` 有冻结 schema、状态和错误语义；
2. supported profile 的每个 delivered candidate 都有完整 mapping、全设计 final equivalence PASS、约束/技术消费 receipt 和 replay evidence；
3. 任意失败、取消、超时、worker crash、parser drift 或 proof unknown 不改变 committed head；
4. 同一 manifest/tool/strategy/seed 的 deterministic profile 在 clean process 重放得到相同 semantic hashes；
5. benchmark 以独立 design family 和 PDK 分桶，公开每设计结果、失败和 worst case，不以派生网表当独立样本；
6. QoR 假说由 frozen protocol 的 Yosys/commercial paired oracle 检验；无收益时可停止 native kernel，而安全与可审计能力仍成立。

---

## 1. CURRENT 有界源码审计

### 1.1 审计范围与结论

本次审计限定于仓库内可见的 iLO/iTM、operation CMake、iDB/Verilog/Liberty/iSTA/iNO/iTO 源码与测试、benchmark synthesis/netlist/SDC 资产，以及 `10/12/43/48/49/55/57` Agent 基座文档。未通过源码、测试或可重放 artifact 证实的能力均按不存在处理。

| 资产 | CURRENT 证据 | 可复用定位 | 不可推导的能力 |
|---|---|---|---|
| iLO/iTM build | `src/operation/CMakeLists.txt` 已 `add_subdirectory(iLO/iTM)`，但两个子目录仅有空 `CMakeLists.txt` | 可直接落 TARGET 目录，不需改 operation 总入口 | 没有 library、API、kernel、test 或 install target |
| Verilog parser | `src/database/manager/parser/verilog` 的 Rust/C++ API 表达 module、declaration、instance、assign、ID/index/slice/concat/constant，并支持 flatten | gate-level structural import adapter seed | 不是完整 RTL/SystemVerilog elaborator；不能据此声称 always/generate/parameter/behavioral 支持 |
| iDB Verilog builder | `src/database/manager/builder/verilog_builder` 将结构网表导入 iDB，并有 writer | mapped netlist materialization/round-trip 的 legacy adapter | 当前接口没有 LogicIR、stable lineage、partial coverage、transaction 或 formal 语义 |
| Liberty parser/model | `src/database/manager/parser/liberty` 有 Rust parser、function expression、cell/port、NLDM timing/internal power/leakage 等模型 | Technology adapter 和 mapping cell-view 输入 | 当前没有统一 TechContext、cell-family qualification 或 mapper；parser success 不等于 mapping coverage |
| iSTA | `src/operation/iSTA/source/module/netlist` 有 Instance/Net/Pin/Port/LibCell 图；已有 Verilog/Liberty/SDC 读取与 STA | mapped timing、load/slew/criticality、formal input normalization辅助 | iSTA netlist 不是 Boolean optimization IR，也不是 equivalence engine |
| iNO | `src/operation/iNO` 有 fanout repair、buffer 配置、`FixResult` 和少量 failure/config tests | mapped branch 高扇出 repair 后端候选 | 只覆盖局部 fanout；没有 proposal/delta/formal/transaction 完整闭环 |
| iTO | `src/operation/iTO` 暴露 DRV/setup/hold、buffering、resize 和 timing/placement helper | post-map physical/timing ECO 消费方 | mutable singleton/legacy API 不是 Agent-safe mapper，也没有独立 candidate acceptance |
| parser tests | iSTA Verilog/Liberty tests 存在 | 可提取 corpus 和 adapter behavior | 多个测试使用开发者绝对路径，非 hermetic CI；不足以证明语义覆盖 |
| benchmark | 受 Git 跟踪的 `benchmarks/designs` 约有 292 个 `.v`、183 个 `.sdc`、279 个 `design.json` | mapped-netlist import、STA、physical flow 和 design-family protocol | 仓库内无对应 tracked Liberty/LEF 集；大量 PDK 变体是同一 RTL family 派生，不能当独立泛化样本 |
| Yosys spike | `benchmarks/flows/synthesize_aes_multi_pdk.py`、`benchmarks/synthesis/*.ys`、两份 AES mapped netlist、2026-07-23 报告 | external adapter 选型和 golden artifact seed | hard-coded host/PDK/RTL path、直接脚本、`setundef -zero`、无 formal/name map/manifest；ASAP7 还曾失败 |
| formal | 源码树未发现 iFormal 模块；`49` 仅规划 `functional.equivalent` claim，`57` 仅规划 formal adapter | TARGET 由 Hub + External Bridge 接入 proven formal tool | 当前没有可签发 functional equivalence certificate 的实现 |

### 1.2 CURRENT parser 真实边界

首版不能把 parser 资产混为一谈：

- Verilog Rust parser 当前公开的数据模型是结构连接模型，适合 mapped gate netlist；behavioral RTL 必须交给 qualified Yosys/commercial frontend，在隔离 workspace 内 elaboration 后再导入 LogicIR；
- iDB builder 会 flatten 指定 top；hierarchy preservation、module-boundary identity 和一对多 lineage 需要新增 adapter/sidecar，不能从 flatten 后名称猜回；
- Verilog constants、bus slice/concat 和 assign 可见，但 4-state/X/Z、multi-driver、supply/tri/wand/wor 的逻辑语义必须显式 audit；不能降为普通二值 net；
- Liberty parser能提供大量 timing/power/function结构，但 mapper只消费 Technology Service 已 qualification 的组合；unsupported sequential group、conditional arc、multi-output、three-state、clock-gating 或 power-aware属性必须保留 coverage；
- iSTA SDC 是 Intent Service 的复用后端，不允许 iLO 再实现一套私有 SDC precedence 或自行解释空 collection；
- source parser warning、丢失 span、unresolved cell/pin、单位和 top 推断都必须进入 import report，不能只返回 `bool`。

### 1.3 CURRENT 可用但未 Agent 化的动作

| 动作 | CURRENT 后端 | TARGET 用法 | 接入前阻断项 |
|---|---|---|---|
| gate-level read/write | Verilog parser + iDB builder/writer + iSTA reader/writer | LogicIR import/export、round-trip oracle | stable IDs、hierarchy/name map、coverage、transaction |
| timing/load/slew | iSTA | F2/F3 annotation 与诊断 | immutable snapshot adapter、ScenarioSet receipt、units/provenance |
| buffer high fanout | iNO | post-map独立 `LogicDelta` 候选 | branch-only、actual touched、inverse、formal |
| resize/buffer setup/hold | iTO | post-map physical refinement | proposal mode、same family qualification、rollback、formal/legal/timing gates |
| Yosys/ABC synthesis | benchmark host script | External Bridge registered adapter | no absolute path/shell、manifest、resource/cancel、parser、formal、qualification |

### 1.4 CURRENT 缺口

- 无 LogicContext、LogicIR、Function、Constraint、RewriteProof、MappingCandidate、LogicProposal、LogicDelta、Result、Evidence schema；
- 无 capability manifest、permissions、immutable input refs、budget 或 idempotency；
- 无 stable logic identity、hierarchical lineage、rename/delete generation 或 source/name mapping；
- 无 clock/reset/blackbox/dont-touch/power-domain transformation policy；
- 无 Boolean optimizer、cut mapper、bounded portfolio、Pareto candidate store 或 stop policy；
- 无 physical feedback schema、compatibility key、uncertainty/calibration 或 anti-circularity规则；
- 无 formal validator、compare-point coverage、counterexample artifact 或 certificate；
- 无 branch-only materialization、inverse/checkpoint、rollback/replay 或 crash recovery；
- 无 hermetic iLO/iTM CMake targets、unit/property/fuzz/integration/performance tests；
- 无可证明的商业相关性、QoR 增益或生产 SLA。

### 1.5 迁移原则

1. adapter-first：先把 proven external frontend/optimizer/mapper/formal 变为 typed、hermetic、可审计 capability；
2. IR-first 但不 kernel-first：LogicIR 用于协议、身份和差分，不借“建 IR”名义重写完整综合器；
3. pure candidate first：import/inspect/diagnose/propose/optimize/map 默认生成 immutable artifact，不触碰 iDB；
4. branch materialization second：只有 Runtime 分配 branch 后，iDB 才应用平台 `TypedDelta<LogicDelta>`；
5. proof before QoR delivery：proof unknown 的候选可保留诊断，不能成为 `READY`；
6. shadow qualification：新 adapter/native pass 与冻结后端/商业 oracle 对拍后再进入自动候选集；
7. no semantic defaults：缺 top、clock、reset polarity、PVT、library、blackbox model、power domain 或 X policy 时返回 partial/unsupported，而不是猜。

---

## 2. 功能、非功能需求与不变量

### 2.1 功能需求

| ID | 需求 | 优先级 | 验收要点 |
|---|---|---:|---|
| FR-LO-01 | `logic.import` 从结构网表或 qualified RTL frontend 生成 canonical LogicIR | P0 | source/tool/parser/coverage/unsupported 完整；无 ambient path |
| FR-LO-02 | `logic.inspect` 查询 hierarchy、cone、function、clock/reset、domain、protection 和 mapping lineage | P0 | 只读固定 LogicIR/SnapshotRef；返回 stable refs |
| FR-LO-03 | `logic.diagnose` 结构化报告冗余、深度、fanout、unmapped、loop、multi-driver、constraint/protection 风险 | P0 | finding 有 scope、severity、evidence 和 certainty |
| FR-LO-04 | `logic.propose` 产生 typed strategy、precondition、预算、风险和 validation plan | P0 | Proposal 不含可执行自由文本，不修改状态 |
| FR-LO-05 | `logic.optimize` 执行白名单 pipeline 或 qualified backend，输出候选 IR/trace | P0 | 每 pass checkpoint/lineage/stop reason 可重放 |
| FR-TM-01 | `mapping.map` 从 LogicIR 与 qualified TechContext 生成 fully mapped candidate | P0 | supported profile `unmapped=0`，cell/function/pin coverage 完整 |
| FR-TM-02 | `mapping.compare` 拒绝不可比 context，输出 hard gate、Pareto、uncertainty、cost 和 regret | P0 | 不以隐藏总分作提交决定 |
| FR-SYN-07 | `logic.validate` 执行结构/round-trip/formal/constraint/receipt 检查并交 Hub 签证 | P0 | formal 非 PASS 不可 delivered |
| FR-SYN-08 | hierarchy/name/source/one-to-many/many-to-one/tombstone lineage 可查询 | P0 | rename 不改 identity；删除/重建不复用旧 ref |
| FR-SYN-09 | clock/reset/blackbox/dont-touch/power-domain policy 在每个 rewrite/map 前检查 | P0 | 越界 100% 阻断构造例 |
| FR-SYN-10 | Runtime budget、cancel、timeout、partial incumbent 与 stop reason 贯穿 portfolio | P0 | 无超预算静默继续；verified incumbent 不丢 |
| FR-SYN-11 | iDB branch 上 materialize LogicDelta，支持 rollback/replay | P0 | failure/cancel/crash 后 base digest 不变 |
| FR-SYN-12 | iSTA/iPL physical feedback 只读、版本化、兼容性校验 | P1 | stale/mismatched feedback 拒绝，不混比 |
| FR-SYN-13 | iTO/iNO post-map action 作为独立 delta/证据阶段接入 | P1 | 不把 downstream ECO 收入 mapper 虚假归因 |
| FR-SYN-14 | native AIG rewrite/cut mapping 可按 feature flag shadow | P2 | external parity、formal、perf/QoR 假说过门后才默认 |
| FR-SYN-15 | Yosys/ABC 与 commercial synthesis/formal oracle harness | P1 | frozen paired input/protocol、逐设计结果、raw artifact |

### 2.2 非功能需求

| ID | 要求 |
|---|---|
| NFR-SYN-01 | 所有调用固定 `SnapshotRef/LogicIrRef + IntentRef + ScenarioSetRef + TechContextRef + PolicyRef`；禁止读取“当前设计/当前库/当前 SDC”。 |
| NFR-SYN-02 | 跨边界只传 typed ref/schema；不得暴露 iDB/iSTA/Liberty raw pointer、singleton 或本地绝对路径。 |
| NFR-SYN-03 | deterministic profile 下相同输入、adapter、strategy、seed、线程配置产生相同 semantic artifact；不可控非确定性必须记录重复分布。 |
| NFR-SYN-04 | 外部执行使用 `57` 的固定 argv/template、隔离 workspace、resource journal、process-group cancel；禁止 `shell=True`。 |
| NFR-SYN-05 | parser/report/protocol schema drift 使 qualification 失效；不得沿用旧字段默认值。 |
| NFR-SYN-06 | `PARTIAL/UNSUPPORTED/TIMEOUT/CANCELLED/UNKNOWN` 永不序列化为 PASS、零值或空问题集。 |
| NFR-SYN-07 | cache key 含全部 semantic context、tool/parser/model/strategy/seed/threads/fidelity；跨 context 不复用。 |
| NFR-SYN-08 | budget 是输入；工具不得根据已看到的候选结果回写 deadline、hard limit 或比较 baseline。 |
| NFR-SYN-09 | Runtime/Hub/iEval 与领域执行面分权；iLO/iTM 不能 commit、自签证书或删除失败 evidence。 |
| NFR-SYN-10 | 外部后端 license/security/tenant artifact 按 `57` 管理；日志不泄露 secret、license token 或未授权 PDK 内容。 |
| NFR-SYN-11 | 性能以 frozen corpus 至少 5 次重复发布 median/MAD/p95/RSS/CPU/artifact bytes；不以单次 pass 时间代替端到端。 |
| NFR-SYN-12 | QoR 按 design family/PDK/scenario 独立报告；派生 corner/variant 不计作独立泛化样本。 |

### 2.3 全局不变量

| ID | 不变量 | 违反时行为 |
|---|---|---|
| INV-SYN-01 | 任何设计修改只能由 Runtime 授权、iDB 在 isolated branch 应用平台 TypedDelta | `PERMISSION_DENIED`；无临时直写路径 |
| INV-SYN-02 | `base_snapshot/context refs/policy` 在一个 experiment 内不可变 | 创建新 experiment/baseline，不直接比较 improvement |
| INV-SYN-03 | 每个 net bit 在 supported combinational region 有且仅有一个 driver；例外必须显式 resolved model | import/map `UNSUPPORTED_MULTI_DRIVER` |
| INV-SYN-04 | rewrite 不越 hierarchy/protection/blackbox/power/clock/reset boundary | candidate rejected，记录最小越界 scope |
| INV-SYN-05 | sequential v1 保持 state element 数量、clock/reset/enable signature 和 state correspondence | 必须走后续 SEC profile；首版 unsupported |
| INV-SYN-06 | fully mapped delivered candidate 的 cell/pin/function/library/scenario coverage 完整且 `unmapped=0` | `PARTIAL_MAPPING`，不可 materialize/commit |
| INV-SYN-07 | 每个 delivered candidate 有全设计 final equivalence PASS，且 proof context 与 candidate hash 精确一致 | Hub bundle incomplete，禁止 commit |
| INV-SYN-08 | PPA/QoR 结果永不转换为功能等价结论 | protocol violation，quarantine adapter/result |
| INV-SYN-09 | renamed object 保持 ID；deleted object tombstone；recreated object generation 不同 | identity audit fail |
| INV-SYN-10 | actual touched 是 declared scope 的子集，dirty/invalidation 是实际影响的保守上界 | rollback/abandon；不得事后扩大 scope 继续 |
| INV-SYN-11 | rollback/replay 后 semantic digest 与预期完全一致 | `CORRUPTED_BRANCH`，隔离分支 |
| INV-SYN-12 | timeout/cancel 只返回 durable artifact/verified incumbent；未封存临时状态不可见 | discard/rollback 后终态 |
| INV-SYN-13 | compare 只在相同 source design intent、scenario、tech、proof/QoR protocol 下计算 delta | `INCOMPARABLE_CONTEXT` |
| INV-SYN-14 | 所有 fallback、default、unsupported、coverage miss 和 uncertainty 均在 Result/Evidence 可见 | semantic validation fail |

### 2.4 每个回答必须包含的五件事

Agent 收到的结果必须回答：

1. 处理了哪个 immutable design/context，实际消费了哪些 intent/tech/scenario；
2. 哪些对象、函数、约束和 library cell 被覆盖，哪些 unsupported/partial；
3. 使用哪个 backend/pass/参数/seed/budget，停止原因和实际资源是什么；
4. correctness 由什么独立 proof/coverage 支持，是否足以签发 current certificate；
5. QoR 值属于哪个 fidelity、估计模型和物理 snapshot，不确定性与可比较性是什么。

---

## 3. TARGET 架构、Capability 与状态

### 3.1 组件图

```text
Planner / Agent
  | typed goal, no shell text
  v
Runtime: experiment + immutable context + budget + branch authority
  |
  +--> Intent Service -------- clocks/reset/protection/domain/scenarios
  +--> Technology Service ---- libraries/functions/families/PVT/qualification
  +--> iDB ------------------- snapshot/export/ObjectId/transaction/replay
  |
  v
+------------------------- iLO/iTM domain --------------------------+
| RequestValidator -> Importer -> LogicIR/Identity/Constraint Binder |
|        |              |                     |                     |
|    Inspector      Diagnoser          Proposal Builder              |
|        |              |                     |                     |
|        +------ Optimizer Portfolio -> Mapping Portfolio -----------+
|                           |                  |                     |
|          Native shadow kernels       External Backend SDK          |
|                           |                  |                     |
|                    Candidate/Evidence/Lineage                      |
+---------------------------+------------------+---------------------+
                            | fixed job manifest
                            v
                 External Bridge: Yosys/ABC/vendor/formal
                            |
       +--------------------+-------------------------+
       |                    |                         |
     iSTA F2          iPL + iSTA F3              iFormal result
       |                    |                         |
       +-------------> iEval compare <---------------+
                            |
                   Verification Hub bundle
                            |
                  Runtime select/commit/abandon
```

`External Backend SDK` 只准备 typed `PreparedJob`、解析 normalized result 和校验 protocol；进程、workspace、资源、license、cancel 归 `57`。Native kernel 与 external adapter 产生同一 Candidate/Proof/Evidence schema，不能拥有较宽松门禁。

### 3.2 Capability 列表

| Capability | 权限 | 输入 | 输出 | 是否修改设计 |
|---|---:|---|---|---:|
| `logic.import@1` | R1 | LogicContext + RTL/netlist refs + import profile | LogicIR + ImportReport | 否 |
| `logic.inspect@1` | R0 | LogicIrRef/SnapshotRef + typed selector | LogicSlice/summary/lineage | 否 |
| `logic.diagnose@1` | R1 | LogicIrRef + checks + budget | DiagnosticSet + Evidence | 否 |
| `logic.propose@1` | R1 | diagnostics + objectives + policy + budget | LogicProposal[] | 否 |
| `logic.optimize@1` | R1 | LogicIrRef + typed strategy | optimized LogicIR candidates | 否，生成 artifact |
| `mapping.map@1` | R1 | LogicIrRef + Tech/Scenario + map strategy | MappingCandidate[] | 否，生成 artifact |
| `mapping.compare@1` | R1 | base/candidate refs + evaluation profile | Comparison/Pareto/escalations | 否 |
| `logic.validate@1` | R1 | reference/candidate/proof policy | ValidatorResult refs/Evidence | 否 |
| `logic.materialize_delta@1` | R2 | selected candidate + branch lease | platform TypedDelta payload + candidate snapshot | 是，仅 branch；iDB owner |

R0/R1 可在没有 state mutation 基座时先发布；R2 必须等 iDB transaction/rollback/replay 与 Hub mandatory claim 闭环。iLO/iTM 不提供 R3 commit capability。

### 3.3 请求生命周期

```text
RECEIVED
  -> CONTEXT_RESOLVED
  -> IMPORTED
  -> AUDITED
  -> DIAGNOSED
  -> PROPOSED
  -> OPTIMIZING
  -> MAPPING
  -> STRUCTURAL_VALIDATED
  -> EQUIVALENCE_PENDING
  -> EQUIVALENCE_PROVED
  -> QOR_EVALUATED
  -> READY
```

任一阶段可进入：

```text
UNSUPPORTED | PARTIAL | TIMEOUT | CANCELLED | FAILED | QUARANTINED
```

`PARTIAL` 是 capability 终态，不是可隐式推进的中间成功。只有满足当前 capability output contract 才可 `SUCCESS`；只有 Candidate 到 `READY` 且 Hub bundle complete/current，Runtime 才能考虑 commit。

### 3.4 Candidate 状态

```text
CREATED -> RUNNING -> ARTIFACT_READY -> PROOF_PENDING
  -> PROVED -> EVALUATED -> VALIDATED -> READY
  -> REJECTED | PARTIAL | TIMEOUT | CANCELLED | FAILED
```

- `ARTIFACT_READY` 只代表 artifact schema/integrity 通过，不代表功能正确；
- `PROVED` 必须引用 exact reference/candidate/assumption/tool qualification；
- `EVALUATED` 只代表 QoR 可用，不代表 proof PASS；
- `READY` 需要结构、formal、mapping coverage 和 policy required receipts；
- 后续 iTO/iNO delta 会创建新 candidate revision，使旧 proof/QoR/certificate stale。

### 3.5 Capability discovery

Manifest 至少声明：

```yaml
capability: mapping.map@1
implementation: yosys_abc_adapter@1
permission: R1
input_profiles: [gate_verilog@1, rtl_verilog2005_subset@1]
output_profiles: [mapped_verilog@1, logic_ir@1]
semantic_support:
  hierarchy: preserve_or_explicit_flatten
  sequential: preserve_ff_signature
  blackbox: uninterpreted_same_model
  x_policy: reject_or_explicit_two_state
fidelity: [F0, F1, F2]
determinism: seeded_single_thread_qualified
required_context: [intent, scenario_set, tech, policy]
validators: [logic.structural, functional.equivalent, artifact.roundtrip]
qualification_ref: sha256:...
```

Registry 展示的是 implementation × input profile × TechContext × proof/QoR protocol 的 qualified 交集，不能显示笼统的“支持 Yosys”或“支持某 PDK”。

---

## 4. TARGET 公共 schema

### 4.1 引用、枚举与版本

复用平台 `SnapshotRef/ObjectId/ObjectRef/ArtifactRef/ScopeRef/TypedDelta`，不建立第二套同名 schema。LogicIR 内尚未 materialize 到 iDB 的临时对象使用 `IrObjectId`；它不能冒充 ObjectId。

```text
LogicIrRef       = sha256:canonical-logic-ir
LogicProposalRef = sha256:canonical-logic-proposal
LogicDeltaRef    = sha256:canonical-logic-delta-payload
CandidateRef     = sha256:canonical-mapping-candidate
ProofRef         = sha256:canonical-rewrite-proof
EvidenceRef      = cas://tenant/project/sha256/<digest>

IrObjectId = {
  logic_lineage_ref,
  kind = module|port|node|net|function|constraint|domain,
  local_id:u64,
  generation:u32
}
```

公共状态：

```text
StageStatus = SUCCESS | PARTIAL | UNSUPPORTED | TIMEOUT |
              CANCELLED | FAILED | QUARANTINED
ProofStatus = PROVED | DISPROVED | UNKNOWN | NOT_RUN
CoverageStatus = FULL | PARTIAL | NONE | NOT_APPLICABLE
Fidelity = F0 | F1 | F2 | F3 | F4
Certainty = EXACT | BOUNDED | ESTIMATED | UNKNOWN
```

unknown major schema、unknown semantic enum 或丢失 required field 一律拒绝；reader 只能忽略明确标记为 non-semantic 的新 minor metadata。

### 4.2 `LogicContext`

```yaml
schema: logic-context@1
request_id: uuid
idempotency_key: sha256:...
actor_ref: tenant/project/principal
base_snapshot_ref: sha256:...       # artifact-only import 可为空
source_design_ref: sha256:...
logic_ir_ref: sha256:...            # import 请求可为空
intent_ref: sha256:...
scenario_set_ref: sha256:...
tech_context_ref: sha256:...
policy_ref: sha256:...
top:
  module: aes
  resolution: explicit              # 禁止 ambiguous auto-top
input_profile: gate_verilog@1
hierarchy_policy: preserve           # preserve | explicit_flatten
semantic_policy:
  value_domain: four_state_exact     # four_state_exact | explicit_two_state
  blackbox: uninterpreted_same_model
  sequential: preserve_signature
  power_domain: forbid_crossing_change
allowed_scope_ref: sha256:...
allowed_transforms: [const_prop, aig_rewrite, refactor, map]
objectives:
  hard: [functional_equivalence, no_unmapped, protect_objects]
  soft: [delay, area, leakage, dynamic_power, routability, disruption]
fidelity_requested: F2
backend_allowlist: [yosys_abc_adapter@1]
strategy_refs: [sha256:...]
seed: 17
threads: 1
budget:
  wall_ms: 600000
  cpu_ms: 1200000
  peak_rss_bytes: 8589934592
  candidates: 16
  proof_ms_per_candidate: 120000
  artifact_bytes: 2147483648
deadline: rfc3339
```

`LogicContext` 只引用 approved Intent/Technology/Policy；任何 semantic ref 改变生成新 context hash。工具实际消费结果必须返回 receipt，不能假设 request 中写了就已消费。

### 4.3 `LogicIR`

```text
LogicIR
  schema_version / logic_ir_ref / logic_lineage_ref / parent_logic_ir_ref
  source_design_ref / source_artifact_refs[] / import_profile_ref
  intent_ref / scenario_set_ref / tech_context_ref
  parser_frontend_qualification_ref / value_domain / hierarchy_policy
  top_module_id / modules[] / nodes[] / nets[] / functions[]
  constraints[] / clock_domains[] / reset_domains[] / power_domains[]
  blackbox_models[] / protection_sets[]
  source_map_ref / object_lineage_ref / canonical_order_ref
  diagnostics[] / unsupported_features[] / coverage
  semantic_digest / created_by / evidence_refs[]
```

`semantic_digest` 覆盖所有影响逻辑语义、保护、domain、function 和 hierarchy 的字段；时间、host、workspace、日志路径和 CAS 物理位置不入 hash。

### 4.4 `Node`

```text
Node
  id: IrObjectId
  kind = INPUT | OUTPUT | CONST | PRIMITIVE | CELL | FF | LATCH |
         MEMORY | BLACKBOX | MODULE_INSTANCE | RESOLVE
  module_id / hierarchical_scope / external_object_ref?
  input_pins[] / output_pins[] / function_refs[]
  cell_ref? / sequential_signature? / source_spans[]
  clock_domain_id? / reset_domain_id? / power_domain_id?
  attributes {dont_touch, keep, preserve, blackbox, generated}
  origin_ids[] / creation {pass_id, rule_id, ordinal}
  supported_semantics / diagnostics[]
```

`sequential_signature` 至少含 edge、data/clock/enable/reset/set pins、sync/async、polarity、priority、initial-state policy 和 state correspondence ID。首版只允许保持 signature 的映射，不允许隐式改变。

### 4.5 `Net`

```text
Net
  id: IrObjectId
  module_id / bit_index / width_group_id?
  driver_endpoints[] / load_endpoints[]
  resolution = SINGLE | TRI | WAND | WOR | SUPPLY | UNKNOWN
  value_domain / constant_value?
  clock_role = NONE | ROOT | GENERATED | GATED | PROPAGATED
  reset_role = NONE | SYNC | ASYNC
  power_domain_ids[] / crossing_kind?
  external_object_ref? / source_spans[] / aliases[]
  protected / origin_ids[] / structural_fingerprint
```

`structural_fingerprint` 用于匹配/诊断，不是 identity。`driver_endpoints.size != 1` 的 net 只有在 resolution model 被 frontend 和 formal profile共同支持时才可优化；否则 import partial/unsupported。

### 4.6 `Function`

```text
Function
  id: IrObjectId
  ordered_inputs[] / ordered_outputs[]
  representation = CONST | EXPR | TRUTH_TABLE | AIG | CELL_EXPR |
                   SEQUENTIAL_RELATION | UNINTERPRETED
  expr/aig/truth_table/artifact_ref
  value_domain / x_z_semantics / output_polarity
  support_set / canonical_npn_class?
  assumptions[] / source = rtl|primitive|liberty|blackbox_policy
  source_tech_object_ids[] / parser_qualification_ref
  semantic_hash / coverage / diagnostics[]
```

不允许从 cell 名称猜 Function；必须来自 qualified frontend/primitive semantics/Liberty function。超过 truth-table 可承受输入数时保留 AIG/表达式，不强制指数展开。

### 4.7 `Constraint`

```text
Constraint
  id: IrObjectId
  intent_object_id / kind
  target_object_refs[] / target_ir_ids[] / scenario_ids[]
  normalized_value + exact_source_value + unit
  precedence_group / command_order / source_span
  hard_or_soft / transform_effect
  expansion = EXACT | CONSERVATIVE | AMBIGUOUS | EMPTY
  consumed_by[] / skipped_by[] / unsupported_by[]
```

首版 transform-relevant `kind` 至少覆盖 clock/generated-clock、clock group、IO delay、case analysis、false/multicycle path、max transition/cap/fanout、`dont_touch`、`dont_use`、power domain、allowed cell/library、hard PPA budget。Constraint 是 Intent 的只读投影；iLO/iTM 不创建或修改 IntentPatch。

### 4.8 `RewriteProof`

```text
RewriteProof
  schema_version / proof_ref
  reference_logic_ir_ref / revised_logic_ir_ref
  reference_artifact_ref / revised_artifact_ref
  scope_ref / proof_kind = LOCAL_CEC | WHOLE_CEC | WHOLE_SEC
  boundary_correspondence_ref / state_correspondence_ref?
  assumptions {value_domain, reset, blackbox_models, case_constraints}
  compare_points {eligible, matched, unmatched, ignored_with_reason}
  method / validator_qualification_ref / tool_binary_ref
  request_ref / raw_result_refs[] / normalized_result_ref
  status = PROVED | DISPROVED | UNKNOWN
  counterexample_ref? / runtime / resources / coverage
  invalidated_by[] / evidence_refs[]
```

Optimizer 自己生成的 local proof/trace 只是 `RewriteProof` evidence；只有 Hub 校验 registered iFormal validator、coverage 和 current context 后才能签发 `functional.equivalent` certificate。

### 4.9 `MappingCandidate`

```text
MappingCandidate
  candidate_ref / candidate_id / parent_candidate_ref?
  base_logic_ir_ref / optimized_logic_ir_ref / mapped_logic_ir_ref
  mapped_netlist_ref / name_lineage_ref / report_ref
  backend / strategy_ref / pass_pipeline / seed / threads
  tech_context_ref / library_set_ids[] / scenario_ids[]
  mapped_cells[] / unmapped_objects[] / cell_function_coverage
  structural_audit_ref / proof_refs[] / certificate_refs[]
  metric_bundle_refs_by_fidelity / physical_feedback_refs[]
  objective_values[] / uncertainty[] / hard_gate_results[]
  actual_cost / stop_reason / status
  consumed_intent_ids / consumed_tech_ids / defaults / misses
  evidence_refs[]
```

### 4.10 `LogicProposal`

```text
LogicProposal
  proposal_ref / base_logic_ir_ref / context_refs
  diagnosis_refs[] / target_scope_ref / objective_order
  strategy_ref / typed_passes[] / backend_requirement
  preconditions[] / expected_touched_upper_bound
  predicted_effects[] {metric, direction, interval, model_ref}
  risks[] / unsupported_if[] / budget_request
  required_validators[] / fidelity_escalation_plan
  rationale_evidence_refs[] / status
```

Proposal 不携带 shell/script、不承诺 improvement、不包含 `equivalent=true`，也不授予 mutation 权限。

### 4.11 `LogicDelta`

`LogicDelta` 是平台 `TypedDelta` 的 domain payload，不是另一套 transaction：

```text
LogicDelta
  schema_version / base_snapshot_ref / source_candidate_ref
  expected_logic_digest / expected_object_generations[]
  operations[] =
    CreateInstance | DeleteInstance | ReplaceMaster | CreateNet | DeleteNet |
    ReconnectPin | ReplaceLogicCone | ReplaceMappedNetlistArtifact
  before_values[] / after_values[]
  object_lineage {preserved, one_to_many, many_to_one, created, tombstoned}
  declared_scope_ref / expected_touched / dirty_lower_bound
  invalidation_domains {connectivity, formal, timing, placement, rc, power}
  preconditions {library, function, domain, protection, hierarchy, lease}
  inverse_payload_ref? / checkpoint_ref / replay_recipe_ref
  proof_refs[] / evidence_refs[]
```

Whole-netlist replacement首版可用 `ReplaceMappedNetlistArtifact`，但 iDB 必须先在 isolated branch 导入、生成 semantic object diff 与 actual touched，再与 declared scope 对账；不能直接覆盖工作区文件或 current design。

### 4.12 `LogicResult`

```text
LogicResult
  request_id / capability / implementation / qualification_ref
  status / stage / started_at / finished_at
  context_refs / input_refs / output_refs[]
  candidate_refs[] / verified_incumbent_refs[]
  coverage {objects, functions, constraints, libraries, scenarios, compare_points}
  actual_fidelity / fallback_chain[] / uncertainty_refs[]
  diagnostics[] / error_code? / retryability
  completed_scope_ref? / remaining_scope_ref? / resume_preconditions?
  consumed_intent_ids / consumed_tech_ids / skipped / defaults
  actual_budget / stop_reason / evidence_pack_ref
```

### 4.13 `LogicEvidence`

```text
LogicEvidencePack
  evidence_pack_ref / request/context/capability/qualification manifests
  immutable input artifact hashes / normalized LogicIR refs
  generated typed strategy + exact rendered argv/template hashes
  raw stdout/stderr/reports/netlists/workspace manifest
  parser field-source map + protocol validation layers
  pass checkpoints / object lineage / structural diffs
  proof requests/results/counterexamples/compare-point coverage
  metric bundles / physical feedback / uncertainty/calibration refs
  transaction/rollback/replay refs / candidate dispositions
  resource/cancel/timeout journal / software-environment hashes
```

原始日志可以辅助诊断，不能替代 structured fields。Evidence 必须能从任一 normalized conclusion 回指原字段或计算输入。

---

## 5. 身份、层次与特殊语义

### 5.1 Stable identity

1. 从 iDB snapshot 导入的 module/instance/pin/net/port 使用 `ObjectRef`；LogicIR 保存映射，不重新 mint 平台 ObjectId。
2. 从 RTL artifact 首次 elaboration 的对象由 import profile 依据 source manifest、parser/frontend version、hierarchical semantic path、canonical bit order 与必要 discriminator 确定初始 `IrObjectId`。
3. Pass 新建对象 ID 由 `parent lineage + pass revision + rule ID + canonical sorted origin IDs + deterministic ordinal` 生成；线程调度和容器遍历顺序不能进入 ordinal。
4. rename 只更新 aliases/name index，不改变 ID；delete 建 tombstone；同名重建使用新 generation。
5. merge/split 保存 many-to-one/one-to-many edges；优化删除保存 reason 和 replacement lineage；无法匹配写 `UNRESOLVED`，不使用相似名字猜测。
6. source span、name、structural hash 都是索引/证据，不单独作为 identity。parser/frontend revision 变化默认生成新 import mapping，并触发 replay diff/qualification。

### 5.2 Hierarchy

- `preserve` profile 禁止跨 module boundary rewrite；module instance port 是 cut boundary；
- `explicit_flatten` 只有 frontend 输出完整 flatten lineage、blackbox boundary 和 port-bit map 时可用；flatten 后不能靠分隔符恢复 hierarchy；
- repeated module instance 的 definition node 与 instance occurrence identity 分离；context-dependent rewrite 默认 clone definition 后在单 occurrence 修改，不能污染所有 occurrence；
- generated names/escaped identifiers/bus endian 经过 canonical name codec，export/import 后 port-bit 对应必须完整；
- top 必须显式或由 manifest 唯一证明；多个 root 时 `AMBIGUOUS_TOP`，禁止随便选择。

### 5.3 Clock 与 reset

Clock/Reset 由 Intent + sequential cell semantics 双源绑定：

- clock root、generated relation、gating、edge 和 domain 未解析完整时，相关 sequential cone 不可优化；
- data rewrite 不得穿过 clock/reset pin；clock inverter/buffer/gating cell 不参与普通 Boolean cleanup；
- reset 必须记录 sync/async、polarity、set/reset priority、release assumption；不能把 reset 常量传播掉，除非 approved case analysis 对 reference/revised 同时成立且 formal 使用同一假设；
- 首版不插入/删除/移动 state element，不 retime，不改变 edge/enable/reset signature；
- clock/reset 网络的 buffer/DRV 修复归 iCTS/iTO/iNO 特定 policy，不由 generic iLO pass 偷做。

### 5.4 Blackbox、memory、tri-state 与 unknown

- Blackbox 以 `{model hash, ordered ports, directions, widths, optional uninterpreted function relation}` 表示；reference/revised 必须用相同模型；
- 允许在 blackbox 外部组合 cone 优化，但不得删除、复制、跨越或改动其端口对应；
- memory、macro、analog、encrypted、DPI/PLI 等首版保留 BLACKBOX/MEMORY node；端口/clock/domain 不完整则 whole-design proof unknown；
- X/Z、tri/wand/wor、tran、multi-driver 不能通过二值 AIG 静默折叠；只有 frontend 与 formal policy 对同一 resolved semantics qualified 时才可处理；
- benchmark spike 中的 `setundef -zero` 不进入默认 TARGET pipeline。只有 Intent 明确约束且 reference/revised 同一 normalization 证明成立时，才可采用显式 two-state profile。

### 5.5 `dont_touch`、`dont_use` 与保护继承

- `dont_touch` 从 Intent 展开到 stable ObjectId/IrObjectId，module/instance/cone 保护按 policy 继承；
- protected node/net 不得删除、重连、重映射或跨界吸收；只读 timing annotation 不算修改；
- `dont_use` 属 Technology cell selection policy，不等于删除设计中已有 cell；mapper 不选择该 cell，已有 protected instance 保持；
- ambiguous/empty/wildcard-overwide protection expansion 使相关 capability partial/failed，不解释为“未保护”；
- proposal declared scope 必须排除保护对象；actual touched 命中任一保护对象立即 rollback。

### 5.6 Power domain

- LogicIR 保存 domain membership、supply/voltage refs、crossing 与 isolation/level-shifter semantic refs；
- CURRENT 无统一 UPF 服务，首版只消费 Intent Service 已规范化并 qualification 的 power-domain artifact；缺 UPF/coverage 时禁止跨 domain rewrite/map，不把 domain 留空当 single-domain；
- cell mapping 必须使用该 domain/scenario允许的 library set、电压和 physical compatibility；
- isolation、retention、level shifter、always-on 和 power-switch cell 默认 protected/blackbox；
- 任何 transform 造成 crossing 集变化、domain membership变化或移除 power-aware cell，首版 `UNSUPPORTED_POWER_INTENT_TRANSFORM`。

---

## 6. Import、canonicalization 与 round-trip

### 6.1 输入 profile

| Profile | 路径 | 首版语义 |
|---|---|---|
| `gate_verilog@1` | 仓库 Verilog parser/iSTA/iDB adapter | structural module/port/net/instance/assign/constants；严格 audit unsupported |
| `rtl_verilog2005_subset@1` | qualified Yosys frontend via External Bridge | frontend elaborates，iLO 导入 normalized IL/netlist + source lineage |
| `systemverilog_subset@1` | 后续 qualified external frontend | 未注册前 capability discovery 不展示 |
| `idb_snapshot_logic@1` | iDB immutable DesignView/export | mapped netlist + ObjectRef mapping；不得读 mutable singleton |

### 6.2 Import pipeline

```text
resolve and hash all source artifacts
  -> validate top/defines/includes/frontend qualification
  -> parse/elaborate in isolated worker
  -> collect parser diagnostics and unsupported constructs
  -> build hierarchy, bit-level nets, nodes and functions
  -> bind Liberty cells/primitives/blackboxes
  -> bind Intent clocks/reset/protection/domain/constraints
  -> assign/recover stable identities and lineage
  -> audit driver/load, loops, widths, domains and value semantics
  -> canonical serialize + semantic hash
  -> export normalized structural netlist and re-import
  -> emit ImportReport/round-trip diff/Evidence
```

### 6.3 Canonicalization

- modules按 stable semantic ID 排序；ports 按 declaration semantic order + bit order；nodes/nets 按 canonical identity，不按指针或 hash-map 迭代；
- expressions/AIG 使用固定 operator、input order、constant encoding 和 endian；commutative operands按 semantic hash 排序，但保留 source lineage；
- units 明确，不出现裸时间/电容/面积值；
- aliases/source spans 不影响 Boolean semantic hash，但保护、domain、value-domain、blackbox model 与 sequential signature 必须影响；
- artifact source order、JSON map insertion order、workspace path、thread count 在被 qualification 为语义无关时不改变 hash；
- parser/front-end semantic revision、define、include、top、library function、intent 或 power-domain变化必须改变 context/IR hash。

### 6.4 Import coverage

```text
ImportCoverage
  source_files {parsed, failed, ignored_with_reason}
  modules/ports/bits/instances/nets/assigns {eligible, imported, unresolved}
  cells/pins/functions {bound, blackboxed, unsupported, ambiguous}
  constraints {eligible, bound, empty, ambiguous, unsupported}
  clocks/resets/power_domains/protected_objects {eligible, resolved, unknown}
  value_semantics {two_state, four_state, x_z, resolved_net}
  source_span_coverage / lineage_coverage / roundtrip_coverage
```

任何 denominator 不可从“成功项集合”反推。unsupported item 留在 eligible/total 中。Full claim 要求对应 policy 的 denominator 与 required coverage精确满足。

### 6.5 Structural audits

Import 后 P0 audit：

- unresolved cell/pin、width/endian mismatch、duplicate driver、floating required input、combinational loop；
- invalid sequential signature、clock/reset pin 同时作 data、missing state correspondence；
- blackbox model/port mismatch、unsupported primitive、tri-state/resolved net；
- constraint target empty/ambiguous、clock coverage、protection/domain mapping；
- Liberty function/pin direction、LEF master cross-source mismatch、scenario/library PVT mismatch；
- hierarchy/escaped-name/bus/export round-trip diff；
- source artifact、parser、frontend、tech/intent consumption receipt 完整性。

Audit finding 是 `ERROR/WARNING/UNKNOWN`；`WARNING` 是否阻断由版本化 policy 定义。`UNKNOWN` 不得自动降为 clean。
