<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 29 · iPA/iIR Agent 原生功耗与压降实施规格 · ai1.1

> 基线：`docs/ai/29-iPA-iIR.md`、本文件 ai1.0，以及当前工作区 `src/operation/iPA`、`src/operation/iIR`。
>
> 成熟度纪律：本文只用 **CURRENT** 描述当前源码中可定位、可调用或有测试的事实；只用 **TARGET** 描述尚待实现的 Agent 原生契约。目录、类型、能力、证书、增量行为或精度档被写入 TARGET，不表示仓库已经具备它们。
>
> 当前结论：iPA 已有 VCD、显式 vectorless、toggle/SP 传播、Liberty 三分量功耗和报告；iIR 已有 PG SPEF/估算拓扑、功耗到电流、稀疏矩阵、LU/CG 和残差门控种子。它们仍是 singleton/文件/裸 map 风格，缺 immutable context、逐对象 provenance、多场景、typed result、稳定 ID、完整网络审计、Agent lifecycle、增量证明和 qualification。

---

## 0. 目标、非目标与成功定义

### 0.1 目标

TARGET iPA/iIR 是 Agent 可安全调用的只读分析服务，不是把 `report_power` 和 `report_ir_drop` 换一个 RPC 名称。

首版目标：对 immutable snapshot 和显式 scenario 审计 measured/propagated/defaulted/unknown activity；输出 instance/net/domain/rail 的 switching/internal/leakage/static power；使每个 current source 可追到 power/activity/model/PG node。

它从 iDB/TechContext 或 PG SPEF 得到可审计 DC PG network，按 domain/rail/corner 求解并发布 residual/KCL/hotspot/explanation/compare/validation；F0-F2 只筛选，满足 policy 的 F3/F4 才可入高风险 gate。

缺 activity、rail、library、RC、boundary 或 convergence 必须 fail closed；Runtime deadline/cancel/partial/publish/replay 与 iPDN、iThermal、iEM、iEval、Hub 的版本化契约也是首版目标。

目标闭环：

```text
Runtime pins snapshot + intent + scenario + tech + policy
  -> power.audit_activity
  -> power.estimate
  -> ir.build_network
  -> ir.build_sources
  -> ir.solve
  -> ir.hotspots / ir.explain
  -> Evaluation compares candidate with base
  -> Verification Hub checks required claims
  -> Runtime rejects, escalates, or selects candidate
```

### 0.2 非目标

- iPA/iIR 不修改 iDB/branch/PdnDelta/cell；iPA 不拥有 STA/PVT 真值，iIR 不设计 PDN、不复制 thermal/EM ownership。
- 首版不声称 dynamic IR、package RLC、Ldi/dt、transient、EM 或 electro-thermal signoff；F0/F1/default/低残差不等于 commercial correlation。
- 无活动/rail/映射、空结果、timeout 不解释为 0 或 PASS；CURRENT Tcl/Python/CSV 仍只是 legacy surface。

### 0.3 成功定义

一个结果 production-eligible 至少满足：

1. 五类 ref、capability/schema/tool revision、单位、scenario/domain/rail/scope/provenance 完整；
2. coverage 分母、缺失集合、fallback、cache key 和 replay manifest 可重放；
3. power/current/KCL/residual 门均通过，且无 policy 禁止的 partial/unsupported/defaulted；
4. Hub 收到 typed evidence，定量测试和 held-out qualification 达第 18 节 DoD。

production-eligible 不等于 signoff-qualified。F4 qualification 仍需指定版本的 external oracle、PDK、设计族、场景和误差预算。

---

## 1. 唯一责任与模块边界

| 模块 | 负责 | 不负责 |
|---|---|---|
| iPA（本文） | activity audit、toggle/SP provenance、三分量功耗、功耗覆盖、power evidence | 修改 activity artifact、生成 PG geometry、签发 IR/thermal/EM 证书 |
| iIR（本文） | PG electrical graph、power-to-current、DC solve、residual/KCL、IR hotspot 与解释 | 生成/提交 PDN action、定义 power intent、发明缺失 boundary |
| iDB（10） | snapshot、stable ObjectId、geometry/connectivity、TypedDelta、conservative dirty | 功耗公式、IR 求解、结果优劣 |
| Intent/Scenario（48） | mode/corner/domain/rail/voltage/temp/frequency/activity binding | 计算 power 或 IR |
| TechContext（55） | Liberty/LEF/RC/via/material/PVT/单位/qualification refs | 选择隐藏默认 PDK 或场景 |
| common iSTA（27） | timing graph、clock、slew、load、RC view、incremental timing evidence | activity source ownership、PG solve |
| iPDN/iPNP（24） | PG connectivity、strap/via/width proposal 与 apply | 复制 iIR solver、把 IR map 当 proposal |
| iThermal（37） | temperature field、thermal boundary 和 coupled-loop residual | 自行估算 activity |
| iEM（36） | branch current 的 EM/reliability 语义、limits、lifetime | 重解 PG 电路或伪造 branch current |
| Evaluation（12） | metric normalization、candidate compare、fidelity routing、QoR policy | 将 partial IR 变成 PASS |
| Verification Hub（49） | required-claim DAG、certificate coverage、staleness | 重新计算 power/IR 数值 |
| Runtime（43） | request lifecycle、worker、budget、cancel、branch、selection、replay | 隐式补齐 scenario 或覆盖分析失败 |
| Observer（44） | 跨证据 root-cause graph 和对象定位 | 替代领域 evidence producer |

红线：`PowerResult`、`IrResult`、`ValidationCertificate` 和 `DecisionRecord` 是不同对象。功耗较低不证明 IR 合格；IR residual 合格不证明 activity 或 rail coverage 合格；certificate 齐全不替代 Runtime 的选择决策。

---

## 2. CURRENT 源码审计

### 2.1 审计范围

有界审计覆盖 iPA `Power/PowerEngine/ActivityProvenance`、core/VCD/annotate/propagate/calc/report、Tcl/Python/PowerIO/tests/CMake；iIR `iIR/IRMatrix/IRSolver`、Rust/PG builder/tests/CMake；iPNP `IREval` consumer；以及 iDB、Intent、TechContext、iSTA、iPDN、iThermal、iEM、iEval、Hub、Runtime 文档契约。

未审计商业工具内部算法、未运行全设计 commercial benchmark，因而本文不声称 CURRENT correlation 或规模性能。

### 2.2 CURRENT 可复用资产

| CURRENT 资产 | 源码证据 | 可复用定位 | 不能据此声称 |
|---|---|---|---|
| Power singleton/graph | `Power.hh` 持有 `PwrGraph`、`PwrSeqGraph` 和三类 power data | legacy kernel adapter | snapshot-safe、多租户或可并发 |
| VCD 路径 | `readRustVCD` 调 Rust parser，要求 top scope，失败返回 0 | measured activity importer 种子 | SAIF、time-window API、逐 signal provenance |
| 活动来源门控 | `ActivityProvenance.hh` 记录 VCD/vectorless 和 aggregate coverage | fail-closed 起点 | propagated/default/unknown 的逐对象账本 |
| 显式 vectorless | `set_default_toggle` 拒绝负数/NaN；Tcl 需 `-toggle` 或 `-allow_default_toggle` | fallback policy seed | 该默认值已经校准或可签核 |
| coverage | `updateActivityCoverage` 按非 const power vertex 统计 annotated 数 | coverage denominator seed | pin/net/clock/domain weighted coverage |
| toggle/SP 传播 | `propagateClock/Const/ToggleSP` 和 sequential graph ops | F1 activity estimator seed | 多 clock/domain 精确处理和误差界 |
| 三分量功耗 | leakage/internal/switch calculators 和 group aggregation | legacy power kernel | 完整 multi-corner、multi-voltage、thermal loop |
| switching 公式 | `PwrCalcSwitchPower.cc` 使用 toggle、cap、`VDD^2` | equation adapter seed | 每项的 C/V/activity provenance 已结构化 |
| Liberty power | internal table lookup、conditional leakage、nominal voltage | cell model backend | PVT qualification、missing arc coverage 已门控 |
| refused reports | JSON refused 时 numeric power 为 null；text 为 N/A | fail-closed report seed | typed Agent status/evidence pack |
| instance export | `IRInstancePower` 含 name、nominal V、internal/switch/leakage/total | current-source bridge seed | stable ObjectId、domain/rail/provenance |
| PG SPEF | iIR Rust bridge 可读 SPEF 并构造 conductance data | F2 network importer seed | rail/domain completeness、boundary audit |
| geometry PG build | `PowerEngine::buildPGNetWireTopo` 从 iDB special net 和 resistance query 构网 | estimated network seed | DRC-clean/electrically complete network |
| matrix assembly | `IRMatrix` 构造 Eigen sparse G 和 current vector | DC solver front-end seed | bounds/component audit 或 arbitrary rail names |
| LU/CG | `IRSolver` 有 direct/iterative path | solver backend seed | distributed production solver 或 F3 qualification |
| residual report | `IRSolveReport` 有 status、iteration、absolute/relative residual | numerical gate seed | result-level persisted residual evidence |
| CG guards | 检查 dimensions、finite、positive diagonal、symmetry、iteration gates | negative-test foundation | 浮岛、boundary、KCL、condition 完整审计 |
| IR output | iIR 保存 `net -> instance name -> drop` map | legacy visualization/report | node/branch voltage/current、hotspot schema |
| legacy consumers | Tcl/Python、platform PowerIO、iPNP IREval | compatibility inventory | caller 正确传播所有失败 |

### 2.3 CURRENT 已存在的失败纪律

- 未选择 VCD/显式 vectorless、VCD scope mismatch 或 0 annotation 时，CURRENT power path拒绝；JSON用null、text用N/A，instance export为空，activity-refused IR返回0。
- CURRENT iIR拒绝空power、缺RC/power、空net或非正voltage；LU/CG invalid/failure/max-iteration不发布vector。
- CURRENT solver gate test覆盖SPD小系统和zero-diagonal invalid system。

### 2.4 CURRENT 缺口与已知风险

| ID | CURRENT 缺口 | 直接风险 | TARGET 处置 |
|---|---|---|---|
| GAP-PI-01 | API 依赖 singleton/current STA graph | 请求间状态串扰，无法绑定 snapshot | `PowerContext` + worker session |
| GAP-PI-02 | aggregate activity provenance 仅 VCD/vectorless | propagated/default/unknown 被合并 | `ActivityProvenance` per object/window |
| GAP-PI-03 | 无 SAIF importer | average activity 工件不可统一消费 | versioned VCD/SAIF adapters |
| GAP-PI-04 | VCD begin/end Tcl 选项被注释 | window 不可审计 | `ActivityWindow` 必填且 hash 化 |
| GAP-PI-05 | 无 stable ObjectId | rename/replay/compare 易错配 | 使用 iDB `ObjectId/ObjectRef` |
| GAP-PI-06 | nominal voltage 取首个 instance | 多 voltage/domain 会被错误折叠 | per-domain/per-rail voltage binding |
| GAP-PI-07 | `IRInstancePower` 用 `const char*` | lifetime/identity 脆弱 | owned typed record + stable ID |
| GAP-PI-08 | 0 power instance 被 instance export 跳过 | 真零与缺失无法区分 | explicit status/coverage，不按值删除 |
| GAP-PI-09 | current mapping 位于 opaque Rust map | 无逐 source trace/coverage | `CurrentInjection` records |
| GAP-PI-10 | rail polarity靠 `VDD`/`VSS` substring | 非标准 rail 和多域错误 | Intent `RailRole` 明确绑定 |
| GAP-PI-11 | unknown rail 在 matrix build 中 fatal | Agent worker 被进程级终止 | typed `UNSUPPORTED_RAIL_ROLE` |
| GAP-PI-12 | `Power::runIRAnalysis` 忽略 `setInstancePowerData/solveIRDrop` 返回值并返回 1 | false success | end-to-end status propagation |
| GAP-PI-13 | Tcl/Python `report_ir_drop` 也忽略每 rail 失败并返回 1 | false PASS/report | compatibility adapter 汇总失败 |
| GAP-PI-14 | iPNP `IREval` 未检查 build/solve；空 map 的 min/max/avg 返回 0 | missing 被解释为 0 drop | typed result；空 map 为 UNKNOWN |
| GAP-PI-15 | top iIR 不持久化 `IRSolveReport` | consumer 看不到 residual | `ResidualReport` 进入 `IrResult` |
| GAP-PI-16 | IR drop 由 solved vector 最大值减 node voltage | reference/source 语义不显式 | boundary-aware voltage/drop definition |
| GAP-PI-17 | 无 connected-component/floating-node report | singular/open 原因不清 | network audit before solve |
| GAP-PI-18 | 无 branch current/KCL record | hotspot/EM 无可靠输入 | branch result + conservation gates |
| GAP-PI-19 | geometry builder 含固定 via/row resistance fallback | PDK 相关误差不可见 | TechContext source/qualification receipt |
| GAP-PI-20 | tests 多处硬编码开发机路径且非断言型 | CI 覆盖虚高 | hermetic analytic fixtures |
| GAP-PI-21 | solver gate target `EXCLUDE_FROM_ALL` 且未 `add_test` | 默认 CI 可能不运行 | CTest registered target |
| GAP-PI-22 | 无 timeout/cancel/partial/replay | 长任务无法受 Runtime 管控 | cooperative cancellation + manifest |
| GAP-PI-23 | 无 incremental dependency proof | local result 可能漏远端热点 | conservative dirty over-approximation |
| GAP-PI-24 | 无 commercial correlation protocol | fidelity 标签不可校准 | F4 oracle qualification corpus |

### 2.5 迁移原则

1. 冻结 legacy numeric behavior，以 adapter 暴露真实输入/输出/失败；singleton 不穿越 Agent 边界，新旧双跑后再迁移 caller。
2. false-success propagation 是 P0；`const char*`、pointer、路径、map key 不作跨请求 identity。
3. 无法证明的 coverage/domain/rail/scope 扩为 UNKNOWN/full；SAIF、dynamic IR、thermal coupling 独立落地。

---

## 3. 功能与非功能需求

### 3.1 功能需求

| ID | TARGET 需求 | 优先级 | 验收要点 |
|---|---|---:|---|
| FR-PI-01 | 构建并验证 `PowerContext` | P0 | 五 ref、units、stage、policy 缺一不可执行 |
| FR-PI-02 | audit VCD/SAIF/vectorless/propagated activity | P0 | 每类 count/weight/coverage/unknown set 可复放 |
| FR-PI-03 | hierarchy/window/X/Z/clock/domain 映射审计 | P0 | mismatch 不静默 default |
| FR-PI-04 | 估算 switching/internal/leakage/static/total | P0 | 分量和总量守恒，缺模型显式 |
| FR-PI-05 | query design/domain/instance/net/clock group | P0 | stable selector，分页绑定 snapshot |
| FR-PI-06 | power hotspot 和解释 | P1 | 贡献分量、activity/model/region evidence |
| FR-PI-07 | build/import `IrNetwork` | P0 | topology、units、component、boundary、rail audit |
| FR-PI-08 | power-to-current source mapping | P0 | 每个 source 引用 power record 和 PG node |
| FR-PI-09 | static DC IR solve | P0 | voltage/drop/current/residual/KCL/status |
| FR-PI-10 | IR hotspot、path/bottleneck explain | P0 | source/path/edge sensitivity 和 coverage |
| FR-PI-11 | base/candidate compare | P0 | context compatibility、aligned IDs、new hotspot |
| FR-PI-12 | validate for requested policy | P0 | typed findings/evidence；不自行签 commit |
| FR-PI-13 | incremental analyze | P1 | conservative dirty、local/full oracle、fallback |
| FR-PI-14 | fidelity selection与qualification | P0 | actual fidelity、downgrade/fallback 原因可见 |
| FR-PI-15 | partial/unsupported/timeout/cancel/replay | P0 | terminal status 不丢失，artifact 可恢复 |
| FR-PI-16 | external commercial oracle adapter | P1 | isolated parser、version/command manifest、no hidden merge |

### 3.2 非功能需求

| ID | TARGET 要求 |
|---|---|
| NFR-PI-01 | 读请求只接受 immutable refs；禁止读取未声明的 current global design。 |
| NFR-PI-02 | 跨 Agent 边界禁止裸 `double`；数值必须携带 unit、validity、scenario 和 provenance。 |
| NFR-PI-03 | 同 request semantic hash、输入 refs、tool/model revision、seed 得到 canonical-equivalent 结果。 |
| NFR-PI-04 | 所有 cache key 包含 snapshot、intent、scenario、tech、activity、policy、fidelity、scope 和 producer revision。 |
| NFR-PI-05 | partial、fallback、unsupported、timeout、cancel 不能序列化成 SUCCESS/PASS。 |
| NFR-PI-06 | 旧 singleton 只能在隔离 worker/session 内串行使用；不得跨租户共享可变状态。 |
| NFR-PI-07 | cancel/deadline 在 parse、propagate、power loop、network build、assembly、iterative solve、publish 阶段设检查点。 |
| NFR-PI-08 | 中间 artifact 先写 staging，hash/manifest 验证后原子 publish；取消任务不可留下 current result。 |
| NFR-PI-09 | 日志、host、PID、absolute path、wall clock 不进入 semantic hash。 |
| NFR-PI-10 | 性能目标以冻结 benchmark protocol 的 median/MAD/p95/RSS 发布，不用单次开发机数据。 |
| NFR-PI-11 | 任何 fatal/abort 路径在 Agent adapter 中变为 typed failure；worker crash 由 Runtime 隔离。 |
| NFR-PI-12 | schema 版本只做向后兼容 additive change；breaking change 升 capability major。 |

---

## 4. 全局不变量与 fail-closed 红线

### 4.1 Context 不变量

- 五类 ref 非空且 hash-verified；Scenario绑定唯一mode/corner/activity view及至少一个domain/rail pair，V/T/f/window不得从global或文件名推断。
- Liberty/RC corner须qualified或显式UNQUALIFIED；selector在请求snapshot展开stable IDs，unmatched/ambiguous是finding；compare不兼容时只给structural/coverage diff。

### 4.2 Activity 不变量

- measured/propagated/defaulted/unknown互斥且覆盖eligible set；constant单列，`effective=1`不伪装`measured=1`。
- scope/window无匹配不可回退后仍标measured；vectorless须显式、版本化、有单位语义；X/Z策略未知则不执行。

### 4.3 Power 不变量

- 每record `total=switching+internal+leakage+other`；design total含unattributed，不丢小值/零值凑守恒。
- 0 W只在覆盖且模型成功时有效；missing/unsupported为null+status；activity/C/V/f及Liberty cell/arc/table/PVT/condition可追溯。
- 不同domain/rail无转换规则时不相加，也不映射到一个nominal voltage。

### 4.4 IR 不变量

- 每个load current绑定domain/rail role/V/PG pin-node/power record；source、unmapped power、boundary分别记账，gap不从RHS消失。
- R/G finite有单位；有load component须有合格boundary；success同时过solver、absolute/relative residual、KCL、finite/range gate。
- drop相对显式reference；region记录boundary operator/error，无证明升full；不收敛/singular/floating/unmapped/missing rail不产生0或PASS。

### 4.5 Evidence 不变量

- 结论沿`hotspot -> node/branch -> source -> power -> activity/model -> artifact`追溯，evidence仅引用CAS artifact。
- cancel后kernel晚返回也不publish SUCCESS；fallback降低qualification；incremental须full-oracle qualification才称comparable。

---

## 5. TARGET 公共能力面

### 5.1 Capability 列表

| Capability | 最低权限 | 主要输入 | 主要输出 |
|---|---:|---|---|
| `power.capabilities@1` | R0 | context refs/stage | manifest、supported fidelity/models |
| `power.audit_activity@1` | R0 | `PowerContext`、activity policy | `ActivityAudit` |
| `power.estimate@1` | R0 | context、audit ref、scope、fidelity | `PowerResult` |
| `power.query@1` | R0 | result ref、typed selector/page | records/summary |
| `power.hotspots@1` | R0 | result ref、threshold/profile | `PowerHotspotSet` |
| `power.explain@1` | R0 | result ref、record/hotspot ref | `PowerExplanation` |
| `power.compare@1` | R0 | base/candidate result refs | `PowerComparison` |
| `power.validate@1` | R1 | result ref、validation profile | `ValidationEvidence` |
| `ir.capabilities@1` | R0 | context refs/stage | network/solver manifest |
| `ir.build_network@1` | R0 | context、domain/rail、source policy | `IrNetwork` |
| `ir.build_sources@1` | R0 | network ref、power result ref | `CurrentSourceSet` |
| `ir.solve@1` | R0 | network/source refs、solver policy | `IrResult` |
| `ir.hotspots@1` | R0 | result ref、limit profile | `HotspotSet` |
| `ir.explain@1` | R0 | result/hotspot/object ref | `IrExplanation` |
| `ir.compare@1` | R0 | base/candidate result refs | `IrComparison` |
| `ir.validate@1` | R1 | result ref、validation profile | `ValidationEvidence` |
| `power_ir.replay@1` | R1 | evidence manifest、budget | new execution/result equivalence |

R0 是只读分析，R1 允许消耗受控计算预算并发布 evidence。任何能力都没有 branch mutation 权限。

### 5.2 统一请求

```text
AnalysisRequest
  request_id/capability
  snapshot_ref/intent_ref/scenario_set_ref/tech_context_ref/policy_ref
  stage/scenario_ids/scope {kind, stable object IDs or region ref}
  fidelity {requested, allow_downgrade}
  budget {wall_ms, cpu_ms, memory_mb}/deadline/cancel_token_ref/seed
```

请求校验规则：

- `scenario_ids` 必须属于 `scenario_set_ref`；空集合不选“当前场景”。
- `scope` 必须是 stable object/region/domain selector；name 仅用于解析，结果保存 ID。
- 显式 F3 且 `allow_downgrade=false` 时，缺输入返回 `UNSUPPORTED/PARTIAL_INPUT`，不降为 F1。
- budget 小于 capability 最小可运行预算时，在启动 kernel 前返回 `BUDGET_INSUFFICIENT`。
- deadline 已过或 cancel 已置位时，不读取大型 artifact。

### 5.3 统一响应 envelope

```text
AnalysisResponse
  request_id/execution_id/capability/status/qualification/actual_fidelity
  result_ref/evidence_ref/coverage_ref/diagnostics/fallbacks
  producer {tool, build_hash, schema_version, kernel_revision}
  resource_usage {wall_ms, cpu_ms, peak_rss_mb}
```

`status` 与 `qualification` 正交。一次计算可以 `SUCCESS + EXPLORATORY`，但不能因 status success 自动获得 gate 资格。

---

## 6. TARGET 架构与生命周期

### 6.1 组件图

```text
Runtime/Gateway -> RequestValidator -> ContextResolver -> FidelityRouter
  -> isolated PowerWorkerSession -> ActivityAudit -> PowerEstimator/ResultBuilder
  -> IrNetworkBuilder/Audit -> CurrentSourceBuilder/Coverage -> Solver/Residual/KCL
  -> Hotspot/Explain/Compare -> EvidencePack -> CAS -> Hub/iEval
QualificationRegistry constrains every router/result transition.
```

legacy `Power`、`PowerEngine`、`iIR` 只在 `PowerWorkerSession` 内出现。TARGET schema 层不包含这些类的 pointer。

### 6.2 Power lifecycle

```text
CREATED -> CONTEXT_VALIDATING -> ACTIVITY_AUDITING -> GRAPH_BUILDING
 -> ANNOTATING/PROPAGATING -> POWER_COMPUTING -> RESULT_VALIDATING
 -> PUBLISHING -> SUCCEEDED
```

任一 active 状态可进入 `CANCEL_REQUESTED -> CANCELLED`、`TIMED_OUT` 或 `FAILED`。

partial仅允许可信matched subset、policy允许的逐scenario结果或一致page；kernel不支持partial snapshot时不得伪造partial numeric result。

### 6.3 IR lifecycle

```text
CREATED -> CONTEXT_VALIDATING -> NETWORK_BUILDING/IMPORTING -> NETWORK_AUDITING
 -> SOURCE_MAPPING -> MATRIX_ASSEMBLING -> SOLVING -> RESIDUAL/KCL
 -> HOTSPOT/RESULT_VALIDATING -> PUBLISHING -> SUCCEEDED
```

`NETWORK_AUDITING` 必须先于 matrix solve。已知 floating component 不能交给 CG 再期待 numerical failure 代替 topology diagnosis。

### 6.4 Worker/session 规则

- legacy worker一次只绑定一个context hash；初始化清空graph/power/IR maps/report/workspace，path只入staging；scrub不可证明则销毁进程。
- crash为`WORKER_CRASHED`且artifact quarantine；retry保持semantic hash，retry count不入result hash。

### 6.5 Cancel、timeout 与 publish

cancel检查点位于artifact fetch、activity parse chunk、graph/propagation level、power batch、PG/matrix batch、CG batch/direct factorization前后、hotspot batch和publish前。

若 legacy direct solve 无 cooperative cancel，Runtime 以隔离进程执行并可终止 worker；结果状态是 `CANCELLED` 或 `TIMEOUT`，不是 numerical failure。

### 6.6 Replay lifecycle

```text
load manifest -> verify hashes/schema/producer -> reconstruct canonical request
 -> rerun deterministic settings -> compare digest
 -> EXACT | NUMERIC_EQUIVALENT | DRIFT | UNREPLAYABLE
```

`NUMERIC_EQUIVALENT` 只允许在 manifest 声明浮点比较 profile 时使用；对象集合、status、coverage、fallback 和 qualification 必须 exact match。

---

## 7. TARGET 核心 schema

### 7.1 Identity、单位与枚举

所有 schema 复用 iDB/Platform 公共类型，不在 iPA/iIR 创建第二套 `SnapshotRef`、`ObjectId`、`Scope`、`DirtySet` 或 `UnitValue`。

```text
ObjectId  = {kind, namespace, local_id, generation}
ObjectRef = {snapshot_ref, object_id}
ResultId  = hash(schema, semantic_request, producer, canonical_payload)
RecordId  = hash(result_id, record_kind, scenario_id, object/domain/rail key)
```

最小单位表：

| Quantity | Canonical storage | API display 可选 | 禁止 |
|---|---|---|---|
| power | W | mW/uW | 无 unit 的 numeric |
| voltage/drop | V | mV/uV | `%` 代替原值 |
| current | A | mA/uA | 正负号无 rail convention |
| resistance | ohm | mOhm | sheet R 与 segment R 混用 |
| conductance | S | mS | 以 resistance 字段承载 |
| capacitance | F | pF/fF | 未记录 effective/load 定义 |
| frequency | Hz | MHz/GHz | toggle/event 与 Hz 混用 |
| temperature | K | degC | 不记录 scale |
| time | s | ns/us | VCD tick 无 timescale |
| coordinate | database unit + transform ref | um | 裸整数跨 snapshot |
| residual | dimensioned absolute + dimensionless relative | 同 storage | 只给“converged=true” |

核心枚举：

```text
ActivityKind = VCD | SAIF | PROPAGATED | VECTORLESS_DEFAULT | CONSTANT | UNKNOWN
RailRole = POWER | GROUND | WELL | PACKAGE_SOURCE | OTHER
PowerComponent = SWITCHING | INTERNAL | LEAKAGE | OTHER_SUPPORTED | UNATTRIBUTED
RunStatus = SUCCESS | PARTIAL | UNSUPPORTED | INVALID_INPUT | NUMERICAL_FAILURE |
            TIMEOUT | CANCELLED | RESOURCE_EXHAUSTED | WORKER_CRASHED | INTERNAL_ERROR
Qualification = UNQUALIFIED | EXPLORATORY | QUALIFIED_INTERNAL | QUALIFIED_EXTERNAL
Validity = VALID | MISSING | UNSUPPORTED_MODEL | OUT_OF_DOMAIN | STALE | INVALID
```

### 7.2 `PowerContext`

```text
PowerContext
  schema/context_id
  snapshot_ref/intent_ref/scenario_set_ref/tech_context_ref/policy_ref
  stage/design_lineage_ref/object_registry_ref/unit_system_ref
  netlist/liberty/signal-RC/PG-geometry/PG-RC/activity artifact refs
  iSTA/Tech consumer receipt refs
```

`context_id` 对 semantic fields canonical hash；worker path、mtime 和 log 不参与。

Context validation 输出：

- resolved refs 及 schema/tool revision；
- stage 与 artifact freshness；
- stable-ID mapping coverage；
- scenario-to-library/RC/domain/rail mapping；
- unsupported features；
- blocking diagnostics。

### 7.3 `PowerScenario`

```text
PowerScenario
  scenario_id/mode_id/process_corner_id
  library_view_ref/signal_rc_corner_ref/pg_rc_corner_ref
  temperature {value, unit, source or field_ref}
  frequencies[] {clock ObjectIds, value Hz, source}
  domains[] {domain_id, power_rail_id, ground_rail_id, nominal_voltage V}
  activity_view_ref
```

规则：frequency per clock而非全局fastest；voltage per domain/rail；temperature为scalar或field且标来源；activity view须mode-compatible；PG RC与signal RC corner分开。

### 7.4 `ActivityProvenance`

```text
ActivityProvenance
  activity_record_id/scenario_id/object_ref/kind
  source_artifact_ref/source_scope/source_signal/mapping
  window {begin, end, duration, unit}
  toggle_rate Hz/transition_count/static_probability/X/Z fractions
  confidence/policy_ref/diagnostics
```

`PROPAGATED` 还需input refs、operator/model revision、logic/clock rule、reconvergence/independence assumptions和error/UNQUANTIFIED。

`VECTORLESS_DEFAULT` 还需policy/version、value source/object class、explicit authorization和calibration bucket/UNQUALIFIED。

`kind=UNKNOWN` 的 numeric activity 字段为 null，reason 必填。

### 7.5 `CoverageReport`

```text
CoverageReport
  eligible/measured/propagated/defaulted/constant/unknown {count, weighted}
  by_class/by_domain/by_hierarchy
  unmatched_source_signals_ref/uncovered_design_objects_ref
  denominator_policy_ref
```

coverage 至少同时提供 count-weighted 和 policy-weighted 值。weighted denominator 的权重定义必须可审计，例如 capacitance、instance count 或 prior power；不能用本次结果反向构造权重来提高 coverage。

### 7.6 `PowerRecord` 与 `PowerResult`

```text
PowerRecord
  power_record_id/scenario_id/scope_kind/object_ref/domain_id/rail_id
  switching/internal/leakage/other_supported/total {value W, validity}
  activity_record_refs/model_refs/voltage/temperature/frequency_refs/assumptions
PowerResult
  power_result_id/context_id/scenario_id/scope_ref/status/qualification/fidelity
  summary_by_domain/component including unattributed/total
  records/activity_coverage/model_coverage/conservation refs
  fallbacks/diagnostics
```

`unattributed` 必须参与 total。若某 component validity 不是 VALID，total 不得是无条件 VALID；可按 policy 输出 interval，但必须 `PARTIAL`。

### 7.7 `IrNetwork`

```text
IrNetwork
  network/context/scenario/domain/rail IDs, rail_role, source_kind
  topology_digest; nodes/branches/boundaries/components/mapping/audit refs
  resistance/voltage/current/coordinate units; qualification
```

```text
IrNode {node_id, physical ObjectRefs, domain/rail/role, coordinate/layer/purpose/
        transform, SOURCE|LOAD_PIN|JUNCTION|VIA|PACKAGE|REFERENCE, component_id}
IrBranch {branch_id, endpoints, physical refs, WIRE|VIA|BUMP|PACKAGE|CONTACT|
          REDUCED, resistance value/unit/source/temp/qualification, geometry}
IrBoundary {boundary/node/component IDs, DIRICHLET|NORTON|THEVENIN|REGION,
            V/I/Z units, PACKAGE|IO|INTENT|EXTERNAL source, refs/qualification}
```

### 7.8 `CurrentInjection`

```text
CurrentInjection
  source/network/scenario IDs; instance_ref/pg_pin_ref/node_id
  domain_id/rail_id/rail_role/power_record_refs
  allocated_power W/conversion_voltage V/current A
  mapping_rule/allocation_fraction/validity
```

多 rail cell 必须按 library/intent power-pin relation 或显式 allocation model 分配；没有规则时为 `UNMAPPED_POWER`，不得平均分配。

### 7.9 `ResidualReport`

```text
ResidualReport
  solver/revision/preconditioner; matrix shape/nnz; iterations/termination
  absolute residual A/relative residual; max/sum node KCL residual A
  source-load balance A; voltage min/max V; tolerances_ref
  conditioning estimate or null; floating component count
```

未计算 condition estimate 时为 null，不写 0。direct solver 的 iterations 可为 0，但 factorization status 和 residual 必须存在。

### 7.10 `IrResult`

```text
IrResult
  result/context/scenario/network/source-set IDs; status/qualification/fidelity
  node/branch/residual/coverage refs
  min_voltage/max_drop/P95_drop/analyzed_load_current with units
  hotspot_set_ref/fallbacks/diagnostics
```

Node result 包含 absolute voltage、reference voltage、drop、KCL residual 和 validity。Branch result 包含 signed current、magnitude、I2R loss 和 direction convention。

### 7.11 `Hotspot` 与 `Evidence`

```text
Hotspot
  hotspot/result/scenario/domain/rail IDs; kind/severity
  peak_object_ref/region_ref; peak/limit/margin with units
  member-node/dominant-source/dominant-branch/path-evidence/coverage refs
```

```text
EvidenceManifest {semantic request/five refs; input/parser receipts;
 activity/coverage/model/conservation; network/source/audit; matrix/solver/KCL;
 hotspot/explain/compare; policy/qualification/fallback; producer revisions;
 deterministic settings/resource usage}
```

Evidence 不内嵌大型 wave、matrix 或 maps；以 CAS refs + schema/digest 指向。

---

## 8. Activity audit 算法与语义

### 8.1 Eligible set

`ActivityAuditor` 先从 snapshot、power graph 和 scenario 构造 eligible object set：

1. 枚举comb/seq/clock/port/net/macro，标记constant、disabled、case-pruned和absent，按mode/domain/class切 denominator。
2. 保存stable ObjectId而非VCD name；无法映射power graph的对象生成`GRAPH_MAPPING_GAP`。

eligible policy 必须版本化。修改 denominator policy 会改变 audit/result hash，不能沿用旧 qualification。

### 8.2 VCD 导入

```text
verify hash/timescale -> parse hierarchy/variables -> normalize while retaining source spelling
 -> map requested scope/window/signals to stable ObjectIds -> count transitions/X/Z by policy
 -> per-object records + unmatched/ambiguous inventories
```

VCD 规则：

- window须`begin<end`并位于/显式截断artifact span；zero duration和0 scope match分别报window/scope error。
- 多signal到一object默认ambiguous；clock alias/generated mapping走Intent/iSTA receipt；glitch/min-pulse/timescale均入provenance。
- X/Z不无条件当0；policy不支持时对象UNKNOWN。

### 8.3 SAIF 导入

SAIF 是 TARGET，CURRENT 未实现。首版 adapter 要求：

- 解析duration、T0/T1/TX/TZ、TC、hierarchy，校验时间和并保留source counters，明确TC/duration的event-rate语义。
- 复用VCD scope/mapping/unknown规则；SAIF average activity不称为cycle-accurate waveform。

### 8.4 Propagation

传播优先级：

```text
CONSTANT > measured VCD/SAIF > qualified clock propagation
         > qualified logic propagation > explicit vectorless default > UNKNOWN
```

同优先级冲突不按输入顺序覆盖；生成 `ACTIVITY_CONFLICT` 并按 policy 拒绝或选择带 evidence 的 source。

逻辑传播至少记录：

- gate function、input SP/toggle、independence/reconvergence和seq state/clock relation；
- clock-gating enable、iteration/levelization/loop handling，以及unsupported black-box/memory。

clock propagation 不得把 fastest clock 复制给所有 clock domains。generated/gated clock 的 frequency 和 enable 必须来自 iSTA/Intent 或 UNKNOWN。

### 8.5 Vectorless policy

允许形式：

```text
VectorlessPolicy {enabled, policy_id, allowed/excluded classes,
                  toggle_rate Hz, static_probability, max_defaulted_weighted_fraction}
```

禁止以无量纲 `0.02` 在不记录“每周期 toggle”还是 Hz 的情况下跨 scenario 使用。若 legacy kernel 仍需要 `0.02`，adapter 必须记录转换所用 clock frequency和 legacy semantics。

### 8.6 Audit verdict

| 条件 | audit status | 最高 qualification |
|---|---|---|
| 无 activity source 且未允许 vectorless | `PARTIAL_INPUT` | UNQUALIFIED |
| scope 0 match | `INVALID_INPUT` | UNQUALIFIED |
| measured+propagated 达 policy 且 unknown=0 | `SUCCESS` | policy 决定 |
| defaulted 比例在探索阈值内 | `SUCCESS` 或 `PARTIAL` | EXPLORATORY |
| defaulted 超 gate 阈值 | `PARTIAL` | EXPLORATORY |
| unknown 非零但 policy 允许 interval | `PARTIAL` | EXPLORATORY |
| required clock/macro/domain unknown | `PARTIAL_INPUT` | UNQUALIFIED |

---

## 9. Power estimate 算法、方程与 provenance

### 9.1 Switching power

对 net/pin transition 的平均 switching power：

```text
P_switch = k_event * r_toggle * C_eff * V_swing^2
```

其中：

- `r_toggle`是有明确edge/event语义的Hz，`k_event`记录0.5/edge-count convention，`C_eff`引用iSTA/RC/Liberty view。
- `V_swing`来自domain/rail；level shifter/cross-domain需模型，否则unsupported；Liberty internal已含short-circuit时不重复。

CURRENT `PwrCalcSwitchPower` 可作为 legacy backend，但 adapter 必须补录其实际 `k`、toggle、cap、V 和对象映射；无法补录时 fidelity 最高 F1。

### 9.2 Internal power

概念式：

```text
P_internal = sum_over_events(rate_event * E_internal(slew_in, load_out,
                                                     transition, when, PVT))
```

要求：

- lookup记录library/cell/pin/related-pin/table/indices/interpolation；slew/load来自同scenario iSTA receipt，rise/fall和power/ground relation不混用。
- `when`用SP/state coverage；seq clock/data可分组；unsupported expression和out-of-table距离/policy显式，静默clamp不可qualified。

### 9.3 Leakage/static power

概念式：

```text
P_leakage = sum_state Pr(state | scenario, activity) * P_lib(state, V, T, process)
```

若 library 只有 cell-level leakage：

- 标coarse model且不伪造state provenance；缺V/T interpolation降档；power-gated/off由Intent定义，不从低activity猜测。

`static_power` 在本规格中是 leakage及明确注册的 always-on/static component 聚合，不与“static IR”混淆。

### 9.4 Total、范围与守恒

```text
P_record_total = P_switching + P_internal + P_leakage + P_other_supported
P_design_total = sum(P_attributed_records) + P_unattributed
```

门禁：

- 每项finite非负，回馈模型独立component；component sum同时过absolute/relative tolerance。
- hierarchy/domain/group由同一leaf聚合，net/driver switching ownership固定；format不参与计算，interval上下界分别守恒。

### 9.5 Power coverage

至少拆分：

| Coverage | 分母 | gap 示例 |
|---|---|---|
| activity object | eligible activity objects/weight | unknown toggle |
| library cell | powered instances/weight | missing cell |
| internal arc | eligible events/weight | missing/unsupported table |
| leakage state | powered instances/weight | unsupported condition |
| voltage domain | powered instances/power prior | unbound domain/rail |
| timing/load | switching/internal records | stale slew/load/RC |
| attribution | computed total power | unattributed component |

这些 coverage 不压成一个不透明 score。gate profile 对每项给阈值和 required classes。

### 9.6 Power hotspot 与 explanation

Power hotspot可按instance/bin/region/hierarchy/domain/clock聚合，包含total/density、components、top stable IDs、activity来源贡献、V/T/f敏感项、model/extrapolation coverage及base delta/new/resolved分类。

`power.explain` 返回 evidence graph，不生成“因为 activity 高”这种无数值依据的文本。解释排序按显式 contribution/sensitivity profile。

---

## 10. PG network 与 current-source construction

### 10.1 Network source priority

| Source | TARGET fidelity | 要求 |
|---|---|---|
| coarse effective-R proxy | F0 | 明确 topology缺失和 calibration bucket |
| iDB special-net geometry + Tech resistance | F1/F2 | layer/via/source/connectivity audit |
| qualified PG SPEF | F2/F3 | name/node mapping、units、corner、source boundary |
| extracted full-chip/package model | F3 | package/source/rail/domain完整 |
| commercial/foundry model | F4 | external qualification manifest |

若同时存在 geometry 和 PG SPEF，不能静默择一。policy 指定 authoritative source，另一项用于 topology/name/correlation audit。

### 10.2 Geometry construction

```text
select Intent domain/rail -> collect shapes/vias/pins/bumps/package terminals
 -> canonical electrical segments/nodes/branches using Tech rules and R(T,corner,geometry)
 -> attach boundaries -> components -> source/load/connectivity/mapping audit
```

几何相交不自动表示电连接。不同 layer需合法 via/contact；same-layer crossing需同 net/purpose且拓扑规则允许。

固定 `0.01 ohm` via/row resistance 只能保留为 CURRENT legacy F0/F1 assumption，必须在 result fallback中暴露，不能用于 F3。

### 10.3 PG SPEF import

Importer 必须验证：

- 校验hash、divider/delimiter/units、net/rail/domain和corner；检查node count/duplicate/dangling、R finite positive。
- 校验PG pin/instance/bump stable-ID mapping、package/source boundary及source-load connectivity。

只读到一个文件并成功 parse 不等于 `IrNetwork` valid。

### 10.4 Boundary conditions

首版支持qualified source node的Dirichlet、Thevenin、Norton，以及有full-network reduction evidence的region boundary。

禁止把component max voltage当source、为floating自动加conductance仍称exact、默认IO ideal source、按VDD/VSS substring判sign，或省略ground仍输出domain drop。

### 10.5 Network audit

`NetworkAudit` 至少包含：

- counts和source-connected load coverage；floating/source-only/load-only/dangling/open/short/cross-domain findings。
- R distribution/invalid records、boundary qualification、physical mapping、matrix structural symmetry/diagonal候选检查。

有 load 的 floating component默认 `INVALID_NETWORK`。policy允许探索时可单独隔离，不得将其 load 从 denominator删除。

### 10.6 Power-to-current conversion

静态平均 current 的基础关系：

```text
I_load = P_allocated / V_conversion
```

约束：

- `V_conversion`来自scenario rail或coupled iteration；missing/zero/nonfinite则失败，不令current=0；mapped components和direction由profile固定。
- 多PG pin按library/characterized rule分配；decap/analog/memory需adapter；unmapped/unsupported保留W/interval。

### 10.7 Source mapping coverage

```text
coverage = mapped power / eligible power; mapped instances / eligible instances;
           valid current / eligible current estimate
```

分母为 0 时 coverage 是 `NOT_APPLICABLE` 或 `UNKNOWN`，不自动为 1。IR gate通常同时要求 domain/rail、power fraction和critical-class coverage。

---

## 11. Matrix、solver、残差与 convergence

### 11.1 DC 方程

对非固定节点采用 nodal analysis：

```text
G_ff * V_f = I_f - G_fb * V_b
```

其中 `V_b` 是显式 boundary voltage；sign convention 在 source set中固定。Thevenin/Norton按标准 companion model并入。

报告不可只写 `G*V=I`，必须保留：

- free/boundary node partition；
- row/column到 node ID映射；
- branch conductance来源；
- RHS中 load/source/boundary贡献；
- elimination/reduction operator；
- matrix digest和solver settings。

### 11.2 Assembly guards

- matrix非空方阵、indices合法、系数/RHS finite、diagonal positive、off-diagonal sign正确且symmetry在容差内。
- 每free component接boundary，RHS balance符合audit；duplicate branch canonical aggregation，不按输入顺序覆盖。

失败返回 `MATRIX_ASSEMBLY_INVALID`，不进入 solver。

### 11.3 Solver selection

| Solver | 适用 | 前置 | 失败 |
|---|---|---|---|
| sparse direct LDLT/LU adapter | 小/中型、oracle/debug | factorization可承受；matrix适配 | factorization/numerical failure |
| preconditioned CG | SPD大网络 | symmetry、positive-definite evidence、preconditioner | breakdown/max iteration |
| legacy GS | 仅 debug/对拍 | 显式启用 | 不进入 production qualification |
| external distributed/commercial | F4 | registered adapter/license | external status完整映射 |

CURRENT 类名 `IRLUSolver` 实际使用 Eigen `SimplicialLLT`；TARGET manifest必须记录真实 algorithm/backend，不能只沿用误导性 display name。

### 11.4 Convergence gates

同时要求：

```text
||G V - b||_2 <= absolute_tolerance
||G V - b||_2 / max(||b||_2, epsilon) <= relative_tolerance
max_node |KCL(node)| <= kcl_max_tolerance
sum_component KCL <= kcl_sum_tolerance
all voltages/currents finite and within declared physical sanity range
```

absolute 和 relative gate 使用 AND，而不是任选其一。`epsilon`、norm和scaled/preconditioned residual semantics写入 tolerance profile。

### 11.5 Floating、singular 与 regularization

- floating load component直接`INVALID_NETWORK`；singular保留evidence并按根因分类。
- `G+lambda I`仅显式exploratory，报告lambda/error/sensitivity，最高EXPLORATORY；删除floating后为PARTIAL_SCOPE且保留原分母。

### 11.6 Voltage/drop/current derivation

```text
V_node = solved absolute potential under declared reference
Drop_power = V_boundary_effective - V_node
Rise_ground = V_node - V_ground_boundary_effective
I_branch(u->v) = (V_u - V_v) / R_uv
P_loss_branch = I_branch^2 * R_uv
```

多 source component 的 `V_boundary_effective` 不能简单取 max；node drop必须相对 policy定义的 nominal rail或通过 source-path explanation给出。若单值 drop语义不成立，返回 absolute voltage和source-specific margins。

### 11.7 Post-solve checks

- 用原矩阵重算residual；逐node/component KCL和source/load/I2R balance；检查current continuity/sign、voltage range。
- 小/抽样网络direct/CG双跑；仅required checks全过后构造hotspot。

能量平衡需考虑 `P=V*I` conversion与 constant-power load线性化误差；首版 nominal-voltage current source必须将该近似写入 qualification。

---

## 12. Hotspot、explain、compare 与 validate

### 12.1 Hotspot detection

阈值来自 Intent/policy，不硬编码：

- absolute voltage lower bound；
- drop voltage upper bound；
- drop ratio upper bound；
- branch current或I2R screening limit；
- percentile/top-K exploratory profile；
- spatial clustering distance/layer/domain boundary。

`HotspotBuilder` 先产生 violating nodes/branches，再按 connectivity和physical region聚类。不同 domain/rail/scenario不合并为一个 hotspot。

### 12.2 Hotspot severity

```text
margin = limit - observed       # upper-bound metric
normalized_margin = margin / scale_from_policy
```

severity由明确 threshold bands决定。coverage/residual不合格时 hotspot可供诊断，但 validity 为 `CONDITIONAL`，不能标 clean。

### 12.3 IR explain

`ir.explain` 至少给peak voltage/drop/limit、dominant load及power/activity来源、source-to-hotspot resistance path/cut、branch R/I/I2R和geometry。

还要给alternative path/connectivity、residual/mapping/default/model fallback，以及sensitivity method/valid range。

首版 sensitivity可用线性 adjoint/selected perturbation。若只用路径电阻 heuristic，必须标 F0/F1 proxy。

### 12.4 Compare compatibility

比较前检查：

- lineage/registry、intent profile、scenario/domain/rail/units和activity/window/policy compatible；
- fidelity相同或可校准，Tech/PG-RC/library变化已分类，coverage/limit和region/full scope可比较。

不兼容时返回 `INCOMPARABLE_CONTEXT`，可以分别展示结果但不计算伪 delta。

### 12.5 Power comparison

```text
PowerComparison {aligned records; object/domain/hierarchy component deltas;
  coverage/model/context diffs; top changes; new/disappeared; qualification relation}
```

candidate coverage下降时，即使已覆盖部分功耗更低，也不能结论“power improved”。

### 12.6 IR comparison

```text
IrComparison {aligned domain/rail/scenario; peak/P95/area-over-limit and
  node/branch/object deltas; new/moved/resolved hotspots; source/topology,
  residual/coverage/qualification diffs; whole-domain verdict}
```

必须检查 new hotspot 和 whole-domain peak，不只比较原 hotspot region。PDN reinforcement导致 current redistribution时，这是硬门禁。

### 12.7 Validate capability

`power.validate` 可检查：

- context/activity/model/attribution coverage；
- power component and hierarchy conservation；
- numeric range、NaN/Inf、unit一致性；
- qualification/profile阈值；
- replay manifest完整性。

`ir.validate` 可检查：

- network/source/boundary coverage；
- floating/open/short/domain isolation；
- solver residual、KCL、energy balance；
- voltage/drop limits和hotspot completeness；
- incremental/full或external qualification evidence。

返回的是 `ValidationEvidence`，由 Hub结合其他领域 claim签发 certificate。iPA/iIR不自行宣称 candidate可提交。

### 12.8 Clean semantics

`NO_HOTSPOT_FOUND`要求scope及required scenarios/domains/rails全覆盖，activity/model/source/network/boundary达profile，solver/post-check成功、limit有效且qualification允许。

否则使用 `UNKNOWN/PARTIAL/UNSUPPORTED`，绝不以空 hotspot list表示 clean。

---

## 13. Incremental、dirty scope 与 cache

### 13.1 原则

TARGET incremental 是 full analysis 的优化，不是另一套物理语义。iDB 提供 structural `DirtySet/InvalidationSet`；iPA/iIR 只能扩大其 dependency closure，不能缩小。

```text
candidate snapshot + base result + iDB DirtySet
  -> classify semantic context changes
  -> expand power/PG dependency closure conservatively
  -> decide REUSE | INCREMENTAL | FULL_REBUILD | UNSUPPORTED
  -> run and record actual recomputed scope
  -> periodic/risk-triggered full oracle
```

### 13.2 Power dirty expansion

| Change | 最小候选 dirty | 必须扩大的依赖 | 默认 fallback |
|---|---|---|---|
| activity artifact/window/policy | mapped objects | downstream propagation cone、clock/domain groups | mapping不稳定则 full power |
| instance move only | instance/nets | load RC、slew、switching和region maps | RC receipt不支持增量则 full scenario |
| resize/VT/master | instance pins | activity function、internal/leakage、load/slew downstream | missing arc diff则 full cone/design |
| buffer/reconnect | touched nets/pins | logic activity、clock、RC、timing、power attribution | topology proof缺失则 full graph |
| voltage/temp/corner/frequency | affected domain | all domain records和current sources | full affected domain |
| Liberty/RC/model revision | mapped models | every consuming record | full scenario |

### 13.3 IR dirty expansion

| Change | 最小候选 dirty | closure | 默认 fallback |
|---|---|---|---|
| load power only | injection nodes | same connected component | full component solve |
| local PG R/geometry | touched branches/nodes | same component、boundary reduction、all redistributed currents | full component solve |
| source/bump/boundary | source component | entire component | full component rebuild/solve |
| via/layer/rail connectivity | touched topology | connectivity component may merge/split | full domain network rebuild |
| domain/rail intent | affected domains | mapping、network、sources、limits | full scenarios |
| temperature-dependent R | affected field cells | mapped branches and connected components | full affected components |

静态线性网络的 RHS 局部变化通常仍影响整个 connected component；“region incremental”不能仅因 geometry bbox 小就只解 bbox。

### 13.4 Region solve

Region solve仅在有full-network Schur/reduced operator、validated domain decomposition/interface residual，或conservative V/I boundary interval时启用。

结果记录 retained/eliminated node sets、boundary operator、base network ref、truncation error和validity radius。candidate topology越过cut boundary或新 source/load落在被消元区时，region cache立即失效。

### 13.5 Cache key 与复用

```text
CacheKey = hash(capability major, semantic request, five context refs,
                activity/window/model/network/source refs, scope,
                fidelity + solver/tolerances, producer revision)
```

跨 snapshot reuse 只有在 stable ObjectId、context等价、DirtySet不相交且dependency proof已 qualification 时允许。cache hit仍执行 freshness、schema和policy gate；stale artifact不得以“已有结果”返回。

### 13.6 Incremental qualification

- 每action/design bucket周期性full双跑；power比较leaf/totals/coverage/hotspot，IR比较V/I/peak/P95/new-hotspot/residual。
- mismatch扩大dirty，重复则该bucket失格；full失败时不以incremental替代真值。

---

## 14. Fidelity、qualification、fallback 与错误

### 14.1 Fidelity 定义

| 档 | Activity/Power | PG/IR | 允许用途 |
|---|---|---|---|
| F0 | calibrated/unqualified defaults、cell count/effective C proxy | effective-R/coarse mesh proxy | idea/ranking，不做硬门 |
| F1 | qualified propagation + estimated RC/Liberty subset | geometry-estimated reduced/full component | candidate筛选、Top-K |
| F2 | VCD/SAIF mix、完整支持的Liberty components | qualified PG SPEF或Tech R full static network | engineering decision，按coverage升级 |
| F3 | required modes/corners/windows/domains complete | full required domains、boundary、residual/KCL、limits complete | internal stage gate |
| F4 | designated commercial power oracle | Voltus/RedHawk或指定external oracle | calibration/release evidence |

`actual_fidelity` 取最弱的 required upstream component；例如 F3 network + F1 activity 的组合最多 F1/F2 policy等级，绝不标 F3。

### 14.2 Qualification key

```text
QualificationKey = design_family + PDK/TechContext + stage + scenario class
                 + activity source/window class + power model set
                 + PG network/boundary source + solver/tolerance
                 + tool/parser/build revisions + metric profile
```

qualification 不是工具全局属性。parser、PDK、model、solver tolerance或commercial version变化使相关 qualification stale，需按 policy重跑。

### 14.3 Fallback rules

| 缺失/失败 | 可选 fallback | 结果约束 |
|---|---|---|
| measured activity gap | explicit vectorless/propagation | PARTIAL或EXPLORATORY；来源比例保留 |
| SAIF unsupported | VCD若同语义artifact存在 | 记录 adapter替换；否则 UNSUPPORTED |
| PG SPEF缺失 | geometry+Tech R | fidelity下降；无Tech R则停止 |
| iterative不收敛 | direct solve在预算/规模允许时 | 保留首次failure evidence |
| region proof失效 | full component/domain | 不是 downgrade；记录scope escalation |
| external oracle unavailable | internal F3若policy允许 | 不能签F4-required gate |
| thermal field缺失 | scalar scenario T | 只在profile允许；记录 assumption |

禁止 fallback：missing rail -> `VDD`、missing ground -> 0 V、missing library power -> 0、missing activity -> 0 toggle、missing source -> ideal boundary、timeout -> last iterate success。

### 14.4 Terminal status

| Status | numeric payload | gate语义 |
|---|---|---|
| `SUCCESS` | 完整且通过required checks | 仍受qualification/policy约束 |
| `PARTIAL` | 仅可信subset/interval，带coverage | 不得full PASS |
| `UNSUPPORTED` | null或已完成无关子结果 | 不得PASS |
| `INVALID_INPUT` | null | caller修context/artifact |
| `INVALID_NETWORK` | 可带audit，不带valid voltages | 不得PASS |
| `NUMERICAL_FAILURE` | diagnostics/last iterate可隔离 | last iterate不作valid result |
| `TIMEOUT` | policy允许的checkpoint partial | 不得PASS |
| `CANCELLED` | 无published current result | 不得PASS |
| `RESOURCE_EXHAUSTED` | null/diagnostics | 可由Runtime升级预算 |
| `WORKER_CRASHED` | quarantined artifact refs | retry或bug处理 |

### 14.5 Error codes

P0 codes：`CONTEXT_REF_MISMATCH`、`SCENARIO_NOT_FOUND`、`ACTIVITY_SOURCE_MISSING`、`ACTIVITY_SCOPE_MISMATCH`、`ACTIVITY_WINDOW_INVALID`、`ACTIVITY_CONFLICT`、`PARTIAL_ACTIVITY`、`LIBRARY_CONTEXT_MISMATCH`、`POWER_MODEL_MISSING`、`POWER_CONSERVATION_FAILED`、`DOMAIN_UNBOUND`、`RAIL_UNBOUND`、`UNSUPPORTED_RAIL_ROLE`、`PG_ARTIFACT_MISSING`、`PG_UNIT_MISMATCH`、`FLOATING_COMPONENT`、`BOUNDARY_MISSING`、`UNMAPPED_POWER`、`MATRIX_ASSEMBLY_INVALID`、`FACTORIZATION_FAILED`、`NOT_CONVERGED`、`KCL_FAILED`、`PARTIAL_SCOPE`、`INCOMPARABLE_CONTEXT`、`INCREMENTAL_MISMATCH`。

每个 diagnostic 含 code、severity、scenario/domain/rail、stable object refs、source spans/artifact refs、message、retryability和suggested action；自由文本不用于状态判断。

---

## 15. 跨模块契约与端到端顺序

### 15.1 输入/输出对账

| Provider/consumer | 向 iPA/iIR 提供 | 从 iPA/iIR 接收 | 关键约束 |
|---|---|---|---|
| iDB | snapshot view、ObjectId、geometry、dirty | read receipt、actual analyzed scope | 不持久化tool pointer |
| Intent | scenario/domain/rail/limit/activity binding | coverage/gap findings | 不猜默认domain/rail |
| TechContext | Liberty/RC/layer/via/R(T)/units qualification | consumer receipt/model coverage | 未qualified模型降档 |
| iSTA | clock/slew/load/signal RC view和freshness | power dependency/invalidations | 同scenario/context |
| iPDN/iPNP | PG geometry/candidate snapshot | hotspot/sensitivity/compare | iIR不生成delta |
| iThermal | scalar/field temperature ref | power map和coupling residual input | coupled loop由Runtime编排 |
| iEM | limit/model需求 | branch current/residual/coverage | upstream不合格则EM partial |
| iEval | fidelity/metric/compare profile | normalized power/IR metrics | 不吞status/coverage |
| Hub | required claims/profile | validation evidence | Hub签certificate |
| Runtime | refs/budget/cancel/worker/CAS | typed response/evidence | Runtime唯一选择/commit owner |

### 15.2 单次 full static IR 顺序

```text
Runtime -> iDB snapshot; Intent/Tech scenario/domain/rail/model/limit; iSTA receipt
 -> iPA audit -> ActivityAudit/Coverage -> iPA estimate -> PowerResult/conservation
 -> iIR network/audit -> sources/mapping -> solve/Residual/KCL/hotspots
 -> iEval/Hub compare/validate -> Runtime certificates or incomplete reasons
```

任一步失败，下游默认不执行；policy允许诊断 continuation时，下游结果显式 `DEPENDENCY_PARTIAL`。

### 15.3 PDN candidate sequence

```text
base IrResult -> iPNP proposes PdnDelta -> iDB applies on candidate branch
  -> iDB emits actual touched + conservative dirty/invalidation
  -> iPA recomputes only when power dependencies changed
  -> iIR rebuilds affected network/components and solves
  -> compare whole domain, new hotspots, residual, EM/DRC/congestion
  -> Hub certificate bundle -> Runtime select/reject
```

局部改善且全域 peak/P95/new-hotspot退化时默认 REJECTED。iPNP CURRENT 空 map返回0的行为不得穿越TARGET adapter。

### 15.4 Electro-thermal sequence

```text
P(T0) -> Thermal.solve -> T1 -> Tech R(T1)/Liberty(T1)
      -> P(T1) + IR(T1) -> damp -> convergence checks
```

Runtime拥有循环、预算、damping和termination。iPA/iIR每次只处理固定context iteration；未收敛时整体 `NUMERICAL_FAILURE/PARTIAL`，不发布最后一次为耦合成功。

---

## 16. LLD、真实源码落点与 CMake

### 16.1 TARGET 目录

```text
src/operation/iPA/agent/
  schema/{PowerContext,PowerScenario,ActivityRecord,Coverage,PowerResult}.hh
  service/{PowerService,ActivityAuditService,PowerQueryService}.cc
  adapter/{LegacyPowerAdapter,VcdActivityAdapter,SaifActivityAdapter}.cc
  model/{ActivityLedger,PowerAttributor,PowerConservationGate}.cc
  evidence/{PowerEvidenceBuilder,PowerReplayManifest}.cc
src/operation/iIR/agent/
  schema/{IrNetwork,CurrentSource,Residual,IrResult,Hotspot}.hh
  service/{IrNetworkService,IrSolveService,IrExplainService}.cc
  adapter/{LegacyIrAdapter,PgSpefAdapter,GeometryPgAdapter}.cc
  network/{NetworkAudit,BoundaryResolver,ComponentBuilder}.cc
  solve/{MatrixAssembler,SolverRouter,ResidualGate,KclGate}.cc
  evidence/{IrEvidenceBuilder,IrReplayManifest}.cc
```

公共 `UnitValue/ObjectId/Scope/Status/EvidenceRef` 从 Platform contract target引用，不在上述目录复制。

### 16.2 类职责

| 类 | 输入 | 输出 | 明确不做 |
|---|---|---|---|
| `ContextValidator` | request/five refs | resolved context/findings | 加默认scenario |
| `ActivityLedger` | eligible set + adapters | per-object provenance | 计算power |
| `LegacyPowerAdapter` | resolved session | leaf legacy values/receipts | 对外返回singleton pointers |
| `PowerResultBuilder` | leaf/model/activity | typed result | 隐藏unattributed |
| `PowerConservationGate` | records/summaries | evidence/verdict | 修改数值凑平 |
| `IrNetworkBuilder` | PG sources/Tech/Intent | network | 设计PDN |
| `NetworkAudit` | network/mapping | component/findings | 用solver代替audit |
| `CurrentSourceBuilder` | power/network | injections/coverage | 猜多rail分配 |
| `MatrixAssembler` | audited network/sources | matrix maps/digest | 自动regularize |
| `SolverRouter` | matrix/policy/budget | vector/raw report | 掩盖fallback |
| `ResidualGate/KclGate` | raw solve | validated residual | 将max_iter当success |
| `HotspotAttributor` | validated result/limits | hotspots/evidence | 生成PdnDelta |

### 16.3 CURRENT 修改点

| CURRENT 文件/target | 首批改动 | 兼容约束 |
|---|---|---|
| `iPA/api/Power.*` | 暴露只读 kernel receipt；传播所有 stage return | legacy Tcl numeric值锁定 |
| `iPA/api/ActivityProvenance.hh` | 保留aggregate API；adapter构建新ledger | CURRENT tests继续通过 |
| `iPA/.../read_vcd/*` | window/scope/mapping diagnostics adapter | parser不直接依赖Agent schema |
| `iPA/.../calc_power/*` | component/model lookup receipts | 公式变化独立 parity PR |
| `iPA/.../plot_power/*` | legacy report消费typed status bridge | refused仍为null/N/A |
| `iIR/api/iIR.*` | 保存/返回 solve report；不丢失败 | legacy map API暂保留 |
| `iIR/.../IRMatrix.*` | bounds/sign/rail role validation | 不再fatal unknown rail |
| `iIR/.../IRSolver.*` | 统一real solver name、cancel hook、report | analytic gate零回归 |
| `iIR/.../PGNetlist.*` | stable physical mapping/audit receipts | builder算法变化另切片 |
| `iPNP/.../IREval.*` | 消费typed status；empty不返回0 | 由iPNP owner独立PR |

### 16.4 CMake 落点

- iPA/iIR agent CMake分别建schema/service/tests；schema只依赖公共contract，service私有链接legacy kernels。
- `ir_solver_gate_test`迁到`BUILD_TESTING/add_test`；hermetic tests无absolute path/GPU/license依赖，commercial suite独立label/guard。
- CUDA/CPU共用`ResidualReport`和qualification gate。

### 16.5 PR 切片

| PR | 内容 | 独立门禁 |
|---|---|---|
| PI-0 | CURRENT behavior inventory、false-success tests、status bridge | missing activity/solve fail不可success |
| PA-1 | common context/scenario/unit/schema + capability manifest | schema/hash/golden compatibility |
| PA-2 | activity ledger、VCD window/scope、coverage | nested hierarchy/unknown/default tests |
| PA-3 | SAIF adapter和propagation provenance | VCD/SAIF equivalent activity corpus |
| PA-4 | typed power records/model receipts/conservation | analytic formula/component sums |
| IR-1 | network schema、PG SPEF/geometry adapters、audit | open/floating/multi-domain fixtures |
| IR-2 | typed current mapping和coverage | every current traces to power |
| IR-3 | matrix/solver/residual/KCL/result | direct/CG analytic oracle |
| PI-4 | hotspot/explain/compare/validate/evidence | new hotspot/full-scope tests |
| PI-5 | incremental/cache/replay/runtime cancel | incremental-full and crash recovery |
| PI-6 | iPDN/iThermal/iEM/iEval/Hub integration | end-to-end candidate gate |
| PI-7 | F4 adapters/correlation/qualification | held-out commercial protocol |

每个 PR 记录 CURRENT/TARGET变化、schema compatibility、consumer list、negative tests、performance delta和rollback strategy；不可把大规模公式改动与Agent包装混入同一PR。

---

## 17. 测试、oracle、qualification 与性能

### 17.1 测试分层

| 层 | 目的 | 必须包含 |
|---|---|---|
| L0 schema/unit | canonical/hash/enum/unit/status | round-trip、unknown fields、unit mismatch |
| L1 analytic kernel | 方程和solver真值 | RC chain/star/mesh、single cell power |
| L2 adapter | real legacy/import mapping | VCD/SAIF/Liberty/PG SPEF fixtures |
| L3 invariant/property | 守恒、单调、permutation | generated networks/activity |
| L4 incremental/metamorphic | local vs full、关系真值 | dirty expansion/new hotspot |
| L5 fault/runtime | timeout/cancel/crash/CAS | no false publish/replay |
| L6 integration | cross-module claim/evidence | iDB/Intent/Tech/iSTA/Hub sequence |
| L7 commercial | correlation/selection quality | held-out designs/PDKs/scenarios |

### 17.2 P0 hermetic cases

| ID | Case | Expected |
|---|---|---|
| PI-T01 | no activity source | null numeric power、`PARTIAL_INPUT` |
| PI-T02 | VCD missing/nested/ambiguous scope | exact diagnostics，不default |
| PI-T03 | VCD window/X/Z/timescale | count/probability和policy一致 |
| PI-T04 | SAIF duration/counter mismatch | invalid，不normalize掩盖 |
| PI-T05 | measured/propagated/default/unknown mix | disjoint sets、coverage守恒 |
| PI-T06 | vectorless explicit/implicit | only explicit enabled |
| PI-T07 | multi-clock/gated/generated clock | per-clock frequency，不用fastest全局化 |
| PI-T08 | multi-voltage/domain/level shifter | rail binding正确或unsupported |
| PI-T09 | switching analytic C/V/activity | formula/unit tolerance通过 |
| PI-T10 | internal table rise/fall/when | lookup provenance和expected energy |
| PI-T11 | leakage state/PVT/missing model | expected或partial，不为0 |
| PI-T12 | leaf/group/domain/design sums | component/attribution守恒 |
| PI-T13 | zero physical power vs missing | VALID 0与null MISSING可区分 |
| PI-T14 | PG chain/star/parallel mesh analytic | node voltage/branch current匹配 |
| PI-T15 | Dirichlet/Thevenin/Norton boundaries | equation和sign正确 |
| PI-T16 | floating/open/short/cross-domain | network audit拒绝 |
| PI-T17 | arbitrary rail names/roles | 不依赖VDD/VSS substring |
| PI-T18 | unmapped/multi-PG-pin power | coverage/alloc rule正确 |
| PI-T19 | LU/CG residual gates/max_iter | only converged publishes |
| PI-T20 | KCL/energy balance injected fault | `KCL_FAILED`/failure |
| PI-T21 | hotspot threshold/cluster/path | stable IDs/limits/provenance完整 |
| PI-T22 | base/candidate new hotspot | whole-domain regression检出 |
| PI-T23 | incomparable context | no numeric delta verdict |
| PI-T24 | empty IR map/current source | UNKNOWN/failure，不为0/PASS |
| PI-T25 | runIR false-success regression | nested return code传播到Tcl/Python |
| PI-T26 | timeout/cancel at each checkpoint | no current SUCCESS artifact |
| PI-T27 | worker crash/CAS partial write | quarantine + deterministic retry |
| PI-T28 | replay same manifest | exact或declared numeric equivalent |

### 17.3 Property 与 metamorphic tests

- activity/C乘k使linear dynamic按k，V乘k使switching按k²，leakage不变；linear current或全部R乘k使drop按k。
- 并联/降R不恶化fixed-current drop；输入重排不改canonical；series split且R和不变时端点解不变。
- disconnected无load component只改audit；defaulted转同值measured只改coverage/qualification；dirty扩full不与full oracle矛盾。

### 17.4 Incremental-full tests

对move/resize/VT/buffer/reconnect/activity-window/domain-V/PG-width-via-source，比较recomputed superset、leaf power error/totals、node-V/branch-I error、peak/P95/Recall@K、coverage/status/fallback和cache freshness。

任何漏掉new hotspot或hard-limit crossing的case使该action incremental qualification立即失败。

### 17.5 Fault injection

注入：truncated VCD/SAIF/SPEF、bad unit、hash mismatch、stale snapshot、missing library table、NaN activity、zero voltage、negative R、out-of-range node ID、duplicate source、singular matrix、CG breakdown、OOM、worker kill、cancel race、CAS publish failure、parser/tool revision drift。断言 status、diagnostic、artifact quarantine、retryability和no false PASS。

### 17.6 Commercial power/IR oracle protocol

F4冻结train/calibration/held-out family、防数据泄漏、PDK/library/RC/V/T/mode/window、mapping coverage/resolver、tool/version/options/parser和power/IR source/boundary/package/decap语义；failed/unsupported留在分母。

Power metrics：total/component MAPE与signed bias、P50/P95 absolute error、top-power Recall@K、domain rank correlation、coverage bucket。IR metrics：peak/P95 drop error、node voltage MAE/P95、hotspot Recall/Precision、worst hotspot distance、branch current error和false-clean rate。

signoff导向最重要的红线是 false-clean，而不是平均误差最低。任何商业oracle违规而internal报告clean的case必须进入blocking triage。

### 17.7 性能 protocol

数据桶：node/branch/instance/net/activity event数、domains/scenarios、matrix nnz、fidelity、cold/warm cache、full/incremental。每组至少5次，报告 median、MAD、p95 wall、CPU、peak RSS、CAS read/write、parse/graph/propagate/power/assembly/solve/post-check分段、CG iterations和cache hit。

禁止：用生成build tree作为输入证据、只报告最快一次、混合不同hardware结果、排除timeout/OOM、用legacy singleton warm state冒充cold start、以solver时间替代end-to-end latency。

### 17.8 可杀假说

| Hypothesis | 测量 | 杀死条件与行动 |
|---|---|---|
| H-PI-A1：provenance/coverage能显著降低错误决策 | coverage bucket下的power/IR误差和false-clean | 高coverage仍无改善：优先修模型/RC/clock而非扩大activity功能 |
| H-PI-A2：F1能保留F3候选排序 | held-out NDCG/Recall@K/selection regret | 低于DoD：该bucket禁用F1筛选 |
| H-PI-A3：incremental与full决策等价 | action分桶hard crossing/new hotspot | 任一漏报：扩大dirty或禁用incremental |
| H-PI-A4：internal F3可稳定关联F4 | held-out power/IR误差、bias、false-clean | 超阈：F3不得作对应gate |
| H-PI-A5：hotspot explanation可定位有效PDN action | top attribution edge与实际sensitivity/action收益 | Recall/收益不足：降为diagnostic，不驱动proposal |

---

## 18. 里程碑、量化 DoD、风险与版本历史

### 18.1 里程碑

| Milestone | 内容 | Exit |
|---|---|---|
| PI-A0（2周） | CURRENT freeze、status/units/context schema | false-success P0 cases全绿 |
| PA-A1（3周） | VCD audit/ledger/window/coverage | PI-T01..08 hermetic通过 |
| PA-A2（4周） | typed power/model provenance/conservation | PI-T09..13和legacy数值锁 |
| IR-A1（4周） | network/source schema和audit | PI-T14..18通过 |
| IR-A2（4周） | solver/residual/KCL/result | PI-T19..20通过且CTest默认注册 |
| PI-A3（4周） | hotspot/explain/compare/Hub evidence | PI-T21..25通过 |
| PI-A4（5周） | incremental/cache/cancel/replay | PI-T26..28和action corpus通过 |
| PI-A5（持续） | F4 qualification/PDN/thermal/EM闭环 | held-out DoD达标 |

### 18.2 量化 DoD

P0 contract DoD：100% numeric records有unit/scenario/domain-rail/validity/provenance，100% mapped current追到Power/Activity或static model；missing/empty/timeout/cancel为0或PASS的次数为0。

解析fixture relative `<=1e-9`且absolute `<=1e-12`；required solve全过residual/KCL且0个未收敛publish valid；schema/replay 100% round-trip/equivalent；covered legacy numeric regression为0（status修复除外）。

Incremental DoD：hard-limit agreement和new-hotspot Recall 100%，Top-K Recall `>=0.99`；power/IR误差达profile，cache false hit和cancel/timeout/crash current-artifact leak均为0。

F1 screening建议初始门槛：held-out Recall@10 `>=0.90`、NDCG@10 `>=0.90`、selection regret P95不超过policy budget；不达标的design/PDK bucket禁用F1自动筛选。

F3/F4 qualification门槛不在实现前伪造统一数字。PI-7必须由产品/PDK profile冻结 power component误差、IR hotspot false-clean、node/peak误差和coverage阈值；任何发布报告同时给CI和bootstrap confidence interval、sample size和失败分母。最低红线为 held-out F4 false-clean `=0`，否则不得签发对应internal gate qualification。

### 18.3 Gate matrix

| Claim | 最低输入/qualification | 阻断条件 |
|---|---|---|
| power ranking | F1 + bucket qualification | unknown critical class、OOD |
| power budget met | F3或policy指定F4 | coverage/model/conservation不达标 |
| IR candidate improved | comparable F2/F3 full-domain | new hotspot、residual/coverage regression |
| IR limit met | F3或required F4 | missing domain/rail/boundary、false-clean risk |
| EM input usable | qualified branch currents + KCL | partial mapping/residual failure |
| thermal input usable | power map coverage + spatial mapping | unknown power/coordinate/domain |
| commit eligible | Hub complete bundle + Runtime policy | 任一required claim incomplete/stale |

### 18.4 Residual risks

| Risk | 现状 | Mitigation |
|---|---|---|
| CURRENT uncommitted parity changes may evolve | audit绑定当前工作区 | PI-0冻结commit/hash和behavior tests |
| Legacy singleton/global STA state | CURRENT | worker isolation，逐consumer迁移 |
| Rust bridge数据opaque/lifetime | CURRENT | typed owned boundary和mapping ledger |
| 多rail/UPF服务尚DRAFT | TARGET dependency | unsupported先行，不猜domain |
| Liberty power semantics覆盖不全 | CURRENT/unknown | model coverage + F4 correlation |
| geometry PG fixed resistance assumptions | CURRENT | Tech receipt；F3禁用fallback |
| solver只覆盖static DC | CURRENT | scope明确；dynamic IR独立版本 |
| region/incremental可能漏远端效应 | TARGET risk | component/full fallback和full oracle |
| iPNP current empty-map=0 | CURRENT consumer risk | typed adapter migration + regression test |
| commercial licenses/corpus可用性 | external | separate guarded suite，失败留分母 |
| thermal/electrical fixed-point runaway | future | Runtime-owned damping/residual/timeout |

### 18.5 开放问题

- common Unit/Status/Evidence target；SAIF parser/license；Liberty multi-rail allocation和PG-SPEF/iDB authoritative mapping。
- F3 package要求；constant-power nonlinear时机；CUDA/direct/CG deterministic profile；F4 tool/corpus/threshold。

开放问题未关闭前采用更保守的 unsupported/qualification，不采用隐式默认。

### 18.6 源码证据摘要

- iPA证据：`ActivityProvenance.hh`、`Power.*`、`PowerEngine.*`、core/read_vcd/calc_power/plot_power、Tcl/Python/`ipw_io.cpp`、activity/VCD tests。
- iIR/consumer证据：`iIR.*`、`IRMatrix.*`、`IRSolver.*`、`PGNetlist.*`、Rust bridge、iPNP `IREval.cpp`、tests及module CMake。

### 18.7 文档自检

交付前机械检查：

```bash
git diff --check -- docs/ai1.0/29-iPA-iIR-ai1.0.md
awk 'NF {n++} END {print n}' docs/ai1.0/29-iPA-iIR-ai1.0.md
awk '/^```/{n++} END{print n, (n % 2 ? "UNBALANCED" : "BALANCED")}' \
  docs/ai1.0/29-iPA-iIR-ai1.0.md
grep -nE 'CURRENT|TARGET|ActivityProvenance|PowerResult|IrNetwork|Residual|Hotspot|UNSUPPORTED|TIMEOUT|CANCELLED|incremental|commercial|CMake|版本历史' \
  docs/ai1.0/29-iPA-iIR-ai1.0.md
git status --short -- docs/ai1.0/29-iPA-iIR-ai1.0.md
```

人工自检：新增能力均为TARGET且CURRENT有源码锚点；missing不成0/PASS；全链路可追溯；incremental为保守over-approximation；local/partial/fallback降qualification；PR/CMake/tests/DoD可独立验收。

### 18.8 版本历史

- ai1.1（2026-07-24）：按 implementation-ready 深度重写，补齐CURRENT审计、边界/需求/生命周期/schema/算法/增量/失败/跨模块/LLD/CMake/PR/oracle/DoD；ai1.0（2026-07-23）仅提出activity provenance、三分量功耗、PG网络和residual gate。
