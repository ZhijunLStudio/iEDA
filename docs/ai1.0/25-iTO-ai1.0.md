<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 25 · iTO Agent-Native 时序优化可实施规格 · ai1.1

> 文档状态：`IMPLEMENTATION_SPEC / TARGET ai1.1`。源码基线审计日期：2026-07-24。
>
> **CURRENT** 表示仓库中已经存在且能由下列源码定位的行为；**TARGET** 表示待实现契约。本文不会把 proposal、branch、MCMM、证书或回滚描述成现有能力。
>
> 首个垂直闭环：post-place/post-CTS 标准单元 timing ECO。iTO 负责诊断和动作提案；Runtime 负责 branch、预算和提交；iDB/iECO 负责 TypedDelta 事务；common iSTA 负责时序真值；Verification Hub 负责证书；iEval 负责 QoR 比较。

---

## 0. 目标、非目标与唯一责任

### 0.1 ai1.1 目标

iTO 从“执行整段原地优化 pass”演进为 Agent 可组合、可筛选、可回滚的 timing action provider：

```text
immutable snapshot + intent + MCMM scenarios
  -> inspect / diagnose
  -> propose immutable EcoProposal portfolio
  -> screen without changing the design
  -> Runtime forks candidate branch
  -> apply exact actions as TypedDelta
  -> legal / RC / STA / DRC / power verification
  -> iEval compares QoR and uncertainty
  -> Runtime commits exact verified branch head or abandons it
```

首版必须做到：

- 对 setup、hold、slew、capacitance、fanout 问题输出机器可读诊断，而非只写报告；
- 支持 `resize`、`vt_swap`、`insert_buffer`、`rebuffer`、受限 `move` 和 `reconnect` 的精确 action contract；
- proposal 与 apply 分离，`propose`、`screen` 绝不修改设计；
- 每个动作都有 stable object refs、前置条件、预测、实际 TypedDelta、DirtySet、逆操作和证据；
- 在 required MCMM scenario/check 上同时保护 setup/hold/DRV，不能用单 corner WNS 代替 closure；
- 把 legacy iTO 算法作为 candidate generator/adapter 复用，而不是允许其绕过 Runtime 原地提交；
- timeout、unsupported、partial validation、stale context 和 rollback failure 均有不可混淆的终态；
- 以商业工具 F4 oracle 做相关性校准，结论按设计族、PDK、阶段和场景分桶。

### 0.2 非目标

- iTO 不拥有主设计 head、branch、commit CAS、全局预算或 Agent 调度；这些归 Runtime（43）。
- iTO 不修改 SDC、时钟周期、generated clock、false/multicycle path、case analysis、dont_touch、power intent 或库文件。发现约束问题只诊断并请求高权限 IntentPatch 工作流。
- iTO 不平行实现 iSTA、iRCX、iPL、iRT、iDRC、iPA/iIR、iEval 或 Verification Hub 的内核。
- 首版不承诺 transistor ECO、clock tree topology ECO、macro move、global placement、全芯片 reroute、PG ECO 或 signoff 等价。
- `move` 是有界 placement hint；`reconnect` 只用于已证明逻辑等价的 timing ECO 拓扑变换，不是任意逻辑重写。
- 首版不自动合并两个候选分支；没有商业 oracle 时不声称达到 commercial signoff。

### 0.3 Owner 边界

| Owner | 唯一负责 | iTO 只能消费/请求 |
|---|---|---|
| iTO | timing diagnosis、候选生成、动作语义、预测、pass policy | 不提交、不签发外域证书 |
| iDB（10） | immutable snapshot、stable object identity、TypedDelta、DirtySet、state diff | iTO 不直接维护第二份设计真值 |
| iECO（32） | timing ECO workflow 模板、补偿链 | iTO 提供 action，不复制 workflow engine |
| common iSTA（27） | scenario/check/path/slack/DRV 真值、增量与 full STA | iTO 内部估计只能标低 fidelity |
| iRCX/iRT（28/26） | extracted/estimated RC、route feasibility、coupling 邻域 | iTO 不把 Steiner RC 称为 routed RC |
| iPL（22） | move/insert 后 legalize、合法性和 placement delta | iTO placer 仅作为 legacy generator 资产 |
| iDRC（30） | rule-specific DRC result | iTO 不由“能放下”推导 DRC clean |
| iPA/iIR（29） | power/IR 分析 | iTO 只预测面积、动态/漏电风险 |
| iEval（12） | metric normalization、Pareto、QoR gate、商业相关性 | iTO 不以隐藏加权分决定提交 |
| Verification Hub（49） | validator DAG、coverage、certificate/bundle | iTO 的 `verify` 返回证据引用，不伪造 PASS |
| Runtime（43） | branch/lease/budget/state/CAS/commit/recovery | iTO 不提供绕过 Runtime 的 Agent commit API |

---

## 1. CURRENT：真实源码、API、算法、配置与测试审计

### 1.1 已存在入口

| 资产 | CURRENT 行为 | ai1.1 定位 |
|---|---|---|
| `src/operation/iTO/api/ToApi.{hpp,cpp}` | singleton `ToApi`；`init/initEngine/runTO/optimizeDrv/optimizeSetup/optimizeHold/optimizeDrvSpecialNet/performBuffering/saveDef/reportTiming/outputSummary` | Legacy Facade；保留 Tcl/Python 兼容，不直接暴露给 Agent |
| `src/operation/iTO/source/iTO.{h,cpp}` | 按 config 顺序原地执行 DRV -> hold -> setup | Legacy Pass Adapter 后端 |
| `src/platform/tool_manager/tool_api/ito_io/ito_io.cpp` | Tool Manager 初始化 config、重置 lib/SDC、初始化 STA，再调用 pass | 兼容入口；没有 snapshot/branch 参数 |
| `src/interface/tcl/tcl_ito` | 注册 `run_to*`、special-net、buffering 命令 | 人工 flow 入口；不能作为 Agent 原子协议 |
| `src/interface/python/py_ito` | 注册 `run_to/run_to_drv/run_to_hold/run_to_setup` | Python 兼容入口 |

`ToApi::outputSummary()` 当前按 clock 输出 initial/optimized/delta TNS、WNS 和建议频率；它没有 snapshot、scenario set、coverage、unit schema、hold/DRV 或 certificate，因此只能进入 Legacy Sensor Adapter。

### 1.2 已存在优化资产

| 源码 | CURRENT 算法事实 | 明确限制 |
|---|---|---|
| `source/module/fix_drv/ViolationOptimizer*` | 用 iSTA `validateCapacitance/validateSlew` 检测 max 模式 cap/slew；按 HV/FLUTE/shallow-light tree 自底向上拆负载并插 buffer；迭代次数由 config 控制 | 跳过 clock、const 和连接 port 的 net；没有 proposal、MCMM、dont_touch/power-domain/frozen-scope contract 或 rollback |
| `source/module/fix_setup/SetupOptimizer*` | 枚举 setup 违例 endpoint，按 path net delay 排序；用 `classifyCells` 做等价 cell repower；支持 VG buffering 和 high-fanout split；RC invalid 后增量 STA，无法证明完整时回退 full STA | 当前主循环实际调用 gate sizing，并让 split buffering 参与；没有显式 VT action、候选 portfolio、逐动作硬门禁或 branch 隔离 |
| `source/module/fix_hold/HoldOptimizer*` | 读取 min-mode hold slack，插 hold/load buffer，并在局部决策中读取 max/min slack | 原地变更；不是 required MCMM scenario 全覆盖；setup 保护不是证书 |
| `source/module/solver/buffer/vg` | 由 routing tree 产生 buffered option，并以 required arrival time 选 best option | 单一内部选择；没有暴露备选、预测误差或实际 validation |
| `source/timing_engine/timing_engine_util.cpp` | `classifyCells` 候选、`substituteCell`、iSTA `repowerInstance`，同时调整 iDB master/坐标 | 可作为 resize adapter 内核；当前没有 typed before/after、CAS precondition 或 inverse |
| `source/module/evaluator/EstimateParasitics*` | 维护 invalid-net set；以 routing tree 和 layer-1 RC API重建 RC tree；支持 invalid net 或全网估算 | 它是 early RC estimator，不是 iRCX/post-route 真值；dirty set 只含裸指针集合 |
| `source/module/placer/Placer*` | 基于 row spacing 在最多约 40 rows 内找最近 site-aligned 空位并更新内部 row 使用状态 | 不是 iPL legality/region/orientation/DRC certificate；找不到时可能返回原位置 |
| `source/data_manager` | 统计新增 net/buffer/resize 和设计面积，检查面积/利用率上限 | 进程内计数，不绑定 branch/snapshot，也不是通用 BudgetLedger |

### 1.3 CURRENT 配置

`source/config/Config.json` 与 `ToConfig` 当前解析：

```text
routing_tree = flute | hvtree | shallow-light
setup_target_slack / hold_target_slack
max_insert_instance_percent / max_core_utilization
fix_fanout / optimize_drv / optimize_hold / optimize_setup
DRV_insert_buffers / setup_insert_buffers / hold_insert_buffers
number_of_decreasing_slack_iter
max_allowed_buffering_fanout / min_divide_fanout
optimize_endpoints_percent / drv_optimize_iter_number
specific_prefix.{drv,hold,setup}.{make_buffer,make_net}
```

这些键继续用于 legacy pass。TARGET 的 `OptimizationIntent` 必须显式带单位、场景、预算和 policy ref；不能直接把进程全局 `ToConfig` 当 Agent contract。`ToApi::resetConfigSdc`/`resetConfigLibs` 是 legacy 初始化能力，不授权 iTO 在实验中修改 intent/tech context。

### 1.4 CURRENT 构建与测试

- `src/operation/iTO/CMakeLists.txt` 使用 C++20，构建 `api` 和 `source`。
- source 被拆为 `ito_config`、`ito_data_manager`、`ito_timing_engine`、`ito_eval`、`ito_fix_drv`、`ito_fix_hold`、`ito_fix_setup`、`ito_placer`、tree builders 和 `ito_vg_buffer`。
- 依赖包含 `ista-engine`、`idb/idm`、FLUTE/SALT、feature DB 等；模块间存在 singleton 和环状风格依赖，尚不能证明多 branch 并行隔离。
- `src/operation/iTO/test/run_to.cpp` 只用空白 config 构造并运行；`test/CMakeLists.txt` 只生成 `test_run_to`，没有有效 gtest assertion、delta inverse、增量/full、MCMM 或故障注入覆盖。
- benchmark 脚本覆盖多个 PDK/design 的 setup/hold/DRV flow，可升级为回归语料，但生成的 DEF/Verilog/log 不是 Agent contract 测试。

### 1.5 CURRENT/TARGET 差距结论

| 能力 | CURRENT | TARGET ai1.1 |
|---|---|---|
| 状态 | singleton/current design | immutable context + isolated candidate branch |
| 输出 | bool/void/log/summary | typed result + status + evidence refs |
| 动作 | 内核直接修改 | immutable action -> TypedDelta -> verified result |
| 场景 | 主要 max/min 查询 | explicit required MCMM coverage |
| RC | tree-based estimate | fidelity-routed iRCX/iRT + estimator provenance |
| placement | 内部空位搜索 | iPL action/legalization + certificate |
| 回滚 | 无公共契约 | inverse delta + branch abandon + replay audit |
| 提交 | legacy flow 后保存 DEF | Runtime exact-head CAS only |
| 测试 | smoke | schema/unit/property/integration/e2e/oracle pyramid |

---

## 2. 需求与不可绕过不变量

### 2.1 功能需求

| ID | 需求 | P | 验收 |
|---|---|---:|---|
| FR-TO-01 | `inspect` 返回 capability、context、coverage 和可编辑 scope | P0 | 不读取未声明的 current design |
| FR-TO-02 | `diagnose` 输出 setup/hold/DRV root-cause 和路径分量 | P0 | attribution 与 common iSTA 在容差内守恒 |
| FR-TO-03 | `propose` 产生不可变、可重放的多样化 proposal | P0 | 调用前后 snapshot hash 相同 |
| FR-TO-04 | `screen` 输出 F0/F1 预测、uncertainty、prune reason | P0 | 低 fidelity 不越过 hard gate |
| FR-TO-05 | 六类首版 action 有精确前后置和 touched/dirty 上界 | P0 | stale/frozen/越 scope 在 apply 前拒绝 |
| FR-TO-06 | `apply` 仅在 Runtime branch transaction 中生成 TypedDelta | P0 | 无 branch/lease/expected head 不可调用 |
| FR-TO-07 | `verify` 编排 legal/RC/STA/DRV/DRC/power policy | P0 | 返回 bundle ref，不返回自签裸 bool |
| FR-TO-08 | required MCMM setup/hold/DRV 风险联合评估 | P0 | 漏 scenario 结果为 PARTIAL/INCOMPLETE |
| FR-TO-09 | 支持 portfolio 生成、剪枝、组合、预算与停止策略 | P0 | 每个候选均有 terminal disposition |
| FR-TO-10 | 支持 timeout/cancel/partial/unsupported/stale/rollback failure | P0 | 不序列化成 SUCCESS |
| FR-TO-11 | legacy pass 可作为受限 generator/基线运行 | P1 | 旧 Tcl/Python 数值基线不被 Agent 层无意改变 |
| FR-TO-12 | evidence 可重放到 exact context/tool/seed/policy | P0 | replay hash 和关键 action/result 一致 |

### 2.2 非功能需求

| ID | 要求 |
|---|---|
| NFR-TO-01 | 所有 Agent 读 API 只接收 immutable refs；写 API 只接收 branch transaction 和 expected head/revision。 |
| NFR-TO-02 | schema 使用版本号；未知 major 拒绝，未知 optional minor 字段可保留透传。 |
| NFR-TO-03 | 同一 context、request、tool/model hash、seed 和 deterministic policy 的 proposal 顺序及 ID 可重放。 |
| NFR-TO-04 | 单位必须显式：time=`ns`、cap=`pF`、res=`ohm`、power=`mW`、area=`um^2`、distance=`dbu|um`。 |
| NFR-TO-05 | Legacy singleton session 默认串行；完成 session isolation qualification 前不得并行写两个 branch。 |
| NFR-TO-06 | DirtySet 必须是对真实受影响集合的保守上界（over-approximation/超集）；iDB/下游工具可继续扩大，iTO 和任一 adapter 不可缩小。 |
| NFR-TO-07 | 所有 mutation 有 idempotency key；重复 apply 返回原 result 或明确 conflict，不重复插 cell/net。 |
| NFR-TO-08 | 性能/QoR 目标只在冻结 benchmark protocol 后发布 median/MAD、P95 和 worst case，不杜撰绝对收益。 |

### 2.3 红线不变量

1. `inspect/diagnose/propose/screen` 对设计只读，输入/输出 snapshot hash 必须一致。
2. iTO 没有可绕过 Runtime 的 Agent commit 路径；legacy `saveDef` 不注册为 Agent capability。
3. `apply` 必须校验 exact base head、object revision、lease fencing token、scope 和 action preconditions。
4. 任何 required setup/hold/DRV/legality/connection claim 为 `FAIL/UNKNOWN/PARTIAL/STALE` 时不得 `READY_TO_COMMIT`。
5. F0/F1 只能剪枝或升级，不能签发 closure、DRC clean、legal 或 power-safe 证书。
6. 修改 SDC/clock/exception/dont_touch/PG/frozen/clock/reset 对象必须拒绝，而不是记录 warning 后继续。
7. actual touched 超出 declared upper bound 或 lease 时 branch 隔离，结果为 `SCOPE_VIOLATION`。
8. rollback/inverse 校验失败时 branch 为 `CORRUPTED`，不得继续复用。
9. 所有 accepted action 必须同时保留 proposal、TypedDelta、before/after metrics、certificate bundle 和 DecisionRecord 引用。
10. setup 改善但新增 required hold/DRV/DRC hard violation 是失败，不是 partial success。

---

## 3. Agent capability 面与状态机

### 3.1 Capability API

| Capability | Mutability | 输入 | 输出 | 典型状态 |
|---|---|---|---|---|
| `timingopt.inspect@1` | read-only | `TimingContext`、scope | `TimingInspectResult` | SUCCESS/PARTIAL/UNSUPPORTED |
| `timingopt.diagnose@1` | read-only | context、problem selector、budget | `TimingDiagnosisSet` | SUCCESS/NO_VIOLATION/PARTIAL |
| `timingopt.propose@1` | read-only | context、diagnosis、intent、seed | `EcoProposalSet` | SUCCESS/NO_APPLICABLE_ACTION |
| `timingopt.screen@1` | read-only | context、proposal set、fidelity/budget | `ScreeningResult` | SUCCESS/PARTIAL/TIMEOUT |
| `timingopt.apply@1` | branch-write | branch txn、exact proposal/action、lease | `ApplyResult` | APPLIED/STALE_CONTEXT/PRECONDITION_FAIL |
| `timingopt.verify@1` | branch-read; validators may use isolated workspace | branch head、delta、policy | `OptimizationResult` | VERIFIED/VALIDATION_FAIL/INCOMPLETE |
| `timingopt.run_pass@1` | orchestration convenience | experiment ref、pass policy | trace + incumbent/frontier | COMPLETED/TIMEOUT_WITH_INCUMBENT |

`run_pass` 只是严格组合前六个 capability 的 Runtime workflow；它不能调用未记录的内部 mutation，也不能自己 commit。

### 3.2 Capability discovery

```yaml
capability: timingopt.apply@1.1
provider: ito-agent
build_ref: sha256:binary-and-flags
actions: [resize, vt_swap, insert_buffer, rebuffer, move, reconnect]
stages: [post_place, post_cts, post_gr, post_route]
scenario_support:
  inspect: mcmm
  screen_f0: selected_scenarios
  verify_f2: required_dirty_scenarios
  verify_f3: required_full_scenarios
fidelities: [F0, F1, F2, F3]
mutation: branch_only
isolation: serialized_legacy_session
limits:
  post_route_move: unsupported
  coupling_aware: requires_irt_irx
required_adapters: [idb, ista]
optional_adapters: [ircx, ipl, irt, idrc, ipa, ieval, ieco, verification_hub]
```

manifest 必须由构建/注册生成；缺 adapter 时按 action/stage 返回 `UNSUPPORTED`，不可静默降成另一物理语义。

### 3.3 Proposal 生命周期

```text
CREATED
  -> INSPECTED
  -> DIAGNOSED | NO_VIOLATION | DIAGNOSIS_PARTIAL
  -> PROPOSED | NO_APPLICABLE_ACTION
  -> SCREENED_KEEP | SCREENED_REJECT | SCREENED_ESCALATE
  -> BRANCH_RESERVED
  -> APPLYING
  -> APPLIED | PRECONDITION_FAIL | STALE_CONTEXT | APPLY_FAILED
  -> VERIFYING
  -> VERIFIED | VALIDATION_FAIL | VALIDATION_INCOMPLETE | TIMEOUT_WITH_PARTIAL
  -> READY_TO_SELECT | REJECTED | ABANDONED
  -> Runtime: COMMITTED | NOT_SELECTED | STALE_BASE
```

状态转换由 `expected_revision` CAS；terminal 状态不可再 apply。取消在只读阶段返回 partial evidence；取消发生于写事务时先完成 atomic abort/branch quarantine，再返回。

### 3.4 Pass 状态

```text
IDLE -> CONTEXT_BOUND -> ROUND_DIAGNOSE -> ROUND_PROPOSE -> ROUND_SCREEN
     -> ROUND_BRANCH_VERIFY -> SELECT_INCUMBENT
     -> NEXT_ROUND | STOPPED | FAILED

STOPPED.reason = CLEAN | BUDGET | NO_IMPROVEMENT | OSCILLATION |
                 NO_FEASIBLE_PROPOSAL | TIMEOUT | CANCELLED | POLICY_LIMIT
```

---

## 4. 上下文、意图与诊断 schema

### 4.1 `TimingContext`

```yaml
schema: timingopt.context@1.1
context_id: sha256:canonical-context
snapshot_ref: sha256:immutable-idb-snapshot
intent_ref: sha256:sdc-and-protected-intent
scenario_set_ref: sha256:mcmm-set
tech_context_ref: sha256:pdk-lib-rc-voltage
stage: post_cts
units: {time: ns, cap: pF, resistance: ohm, power: mW, area: um2, distance: dbu}
required_scenarios:
  - scenario_id: func_ss_0p72v_125c_rcworst
    checks: [setup, slew, capacitance, fanout]
    weight_class: hard
  - scenario_id: func_ff_0p88v_m40c_rcbest
    checks: [hold, slew, capacitance]
    weight_class: hard
active_modes: [functional]
scope:
  object_refs: [idb:inst:0187, idb:net:09af]
  region_dbu: [1000, 2000, 3000, 4200]
  expansion_policy_ref: sha256:scope-policy
protected:
  frozen_sets_ref: sha256:frozen-objects
  clock_refs: [idb:net:clk]
  reset_refs: [idb:net:rst_n]
  pg_domain_ref: sha256:upf-view
toolchain_ref: sha256:adapter-manifests
```

context resolver 必须确认所有 refs 相互兼容；scenario/lib/RC/voltage 与 snapshot stage 不匹配时返回 `INVALID_CONTEXT`。

### 4.2 `OptimizationIntent`

```yaml
schema: timingopt.intent@1.1
intent_id: sha256:canonical-intent
objective:
  primary: reduce_total_violation
  tie_break: [min_change_count, min_area_delta, min_power_delta, deterministic_id]
hard_limits:
  setup_slack_ns_by_scenario: {func_ss: 0.000}
  hold_slack_ns_by_scenario: {func_ff: 0.000}
  max_new_drv_violations: 0
  max_new_drc_violations: 0
  max_utilization: 0.80
  max_area_delta_um2: 240.0
  max_leakage_delta_mw: 0.50
  max_dynamic_delta_mw: 1.20
change_budget:
  max_actions: 50
  max_resizes: 30
  max_vt_swaps: 30
  max_inserted_instances: 16
  max_created_nets: 16
  max_moved_instances: 8
  max_total_displacement_dbu: 20000
  max_touched_nets: 80
compute_budget:
  wall_ms: 300000
  screen_candidates: 200
  branch_candidates: 20
  f3_candidates: 5
allowed_actions: [resize, vt_swap, insert_buffer, rebuffer, move, reconnect]
forbidden_actions: [edit_constraint, edit_clock, edit_power_intent]
fidelity_policy_ref: sha256:fidelity-policy
verification_policy_ref: sha256:timing-eco-gate
stop_policy_ref: sha256:stop-policy
```

所有 limit 是输入，不可根据候选结果动态放宽。旧 config 可由显式 converter 生成 intent；converter 输出及默认值进入 evidence。

### 4.3 `TimingProblem` 与 `TimingDiagnosis`

```yaml
schema: timingopt.diagnosis@1.1
diagnosis_id: sha256:context-selector-tool-result
context_ref: sha256:canonical-context
status: COMPLETE
problem:
  problem_id: sha256:scenario-check-object-signature
  check: setup                    # setup|hold|slew|capacitance|fanout
  scenario_id: func_ss
  endpoint_ref: ista:endpoint:02c1
  path_ref: ista:path:7a20
  driver_ref: idb:pin:11b8
  net_ref: idb:net:09af
  observed: {slack_ns: -0.083, limit: 0.0, violation: 0.083}
  coverage: {rise: true, fall: true, path_count: 20, scenarios: [func_ss]}
signature:
  semantic_key: setup|func_ss|launch_clk|capture_clk|endpoint|rise
  topology_hash: sha256:path-arcs-and-nets
attribution:
  - cause: cell_delay
    object_ref: idb:inst:0187
    value_ns: 0.116
    confidence: 0.98
    evidence_ref: cas:path-arc-table
  - cause: net_rc
    object_ref: idb:net:09af
    value_ns: 0.074
    confidence: 0.85
    evidence_ref: cas:rc-components
  - cause: clock_or_constraint
    value_ns: 0.012
    confidence: 1.0
  - cause: unattributed
    value_ns: 0.003
    confidence: 0.0
conservation:
  path_total_ns: 0.205
  attributed_total_ns: 0.205
  tolerance_ns: 0.001
root_causes:
  - kind: weak_driver_high_load
    object_refs: [idb:inst:0187, idb:net:09af]
    score: 0.91
    applicable_action_families: [resize, vt_swap, insert_buffer, rebuffer]
invalid_assumptions: []
```

attribution 必须以 common iSTA path explain 为准。路径重收敛后，`path_ref` 可失效，但 semantic key 用于 added/removed/ambiguous 对齐；不能按 report 行号或 endpoint 名单独匹配。

### 4.4 诊断算法

1. 按 `(scenario, check)` 查询 coverage；required coverage 缺失则诊断最多为 `PARTIAL`。
2. 对每组获取 top-K unique endpoints/path groups，K 来自 budget，不用同一 endpoint 的重复 path 淹没集合。
3. 从 iSTA explain 获取 cell arc、net RC、clock、constraint 分量；分量回加误差超 tolerance 则 `ATTRIBUTION_MISMATCH`。
4. 对 DRV 记录 limit source、rise/fall、driver/load、fanout、cap、slew；缺 Liberty limit 是 `NO_LIMIT`，不是 clean。
5. 生成 root-cause graph：problem -> path/DRV -> cell/net/arc -> physical/constraint evidence。
6. constraint/clock root cause 只能进入 `NON_ACTIONABLE_CONSTRAINT`；不得伪装成 resize/buffer proposal。
7. 用 stable semantic signature 去重；保留各 scenario 的独立 severity，禁止先加权成一个裸分数。

---

## 5. Action、Proposal、TypedDelta 与 DirtySet

### 5.1 Stable object 引用

```yaml
object_ref:
  object_kind: instance
  stable_id: idb:inst:0187
  expected_revision: 42
  snapshot_ref: sha256:base
  name_hint: U_DATA_187
```

- authoritative identity 是 iDB stable ID + expected revision，`name_hint` 仅调试；重命名不能改变已有对象身份。
- proposal 中的新对象使用 `new_id = hash(proposal_id, action_index, role, ordinal)`；apply 时由 iDB materialize，重放保持同 ID。
- net split 后原 net ID 保留给 driver-side net；新 load-side net 用 deterministic new ID；具体语义写入 action，不能由 adapter 临时决定。
- pin ref 由 instance stable ID + logical port identity 绑定；master swap 后若 port mapping 不唯一，precondition fail。

### 5.2 `EcoAction`

```yaml
schema: timingopt.eco_action@1.1
action_id: sha256:proposal-index-canonical-action
kind: insert_buffer
target_refs: [idb:net:09af]
parameters:
  master_ref: tech:libcell:BUF_X4_RVT
  split_load_refs: [idb:pin:aa10, idb:pin:aa11]
  requested_location_dbu: [182000, 95100]
  new_instance_id: new:inst:4e10
  new_net_id: new:net:711b
preconditions:
  - {kind: object_revision, ref: idb:net:09af, equals: 42}
  - {kind: driver_count, ref: idb:net:09af, equals: 1}
  - {kind: net_type, ref: idb:net:09af, equals: signal}
  - {kind: objects_not_frozen, refs: [idb:net:09af, idb:pin:aa10, idb:pin:aa11]}
  - {kind: libcell_is_buffer, ref: tech:libcell:BUF_X4_RVT}
declared_touched_upper_bound:
  instances: [new:inst:4e10]
  nets: [idb:net:09af, new:net:711b]
  pins: [idb:pin:aa10, idb:pin:aa11]
  region_dbu: [179000, 92000, 185000, 98200]
predicted_dirty_domains: [connectivity, placement, routing, rc, timing, power, drc]
inverse_strategy: typed_inverse
required_validators: [state_integrity, connectivity, legal, rc, setup, hold, drv]
```

### 5.3 动作前置/后置矩阵

| Action | 不可缺前置 | apply 后置 | 主要拒绝码 |
|---|---|---|---|
| `resize` | combinational/sequential function 等价；完整 pin map；footprint/site/height/voltage domain 合法；非 frozen/dont_touch/clock cell；目标 master 存在 | 同一 instance stable ID、连接不变、master 改变、位置按 legal policy 保留或局部重合法 | NO_EQUIVALENT_MASTER, PIN_MAP_AMBIGUOUS, LEGAL_FIT_REQUIRED |
| `vt_swap` | function/pin/footprint/size 等价；目标 VT 可用且 voltage domain 合法；policy 允许 leakage trade-off | 只改变 master/VT 属性；连接和几何 footprint 不变 | VT_UNAVAILABLE, DOMAIN_MISMATCH, POWER_LIMIT_RISK |
| `insert_buffer` | 单 driver signal net；buffer master/ports 已验证；split loads 非空且属于原 net；位置 window 可请求；非 clock/reset/PG/frozen | 新 instance/new net、原 net driver-side 保留、loads 精确迁移、buffer in/out 连接、placement request 记录 | MULTI_DRIVER, PROTECTED_NET, LOAD_SET_STALE, NO_LEGAL_SITE |
| `rebuffer` | 明确旧 buffer chain 子图、边界 pins 和等价 transfer function；子图非共享/受保护 | 以 delete+insert+reconnect 原子组合替换；边界 connectivity 等价；所有删除对象进入 tombstone | SUBGRAPH_CHANGED, NON_EQUIVALENT_CHAIN, SHARED_BUFFER |
| `move` | movable、非 fixed；目标 stage 允许；region/row/orientation/halo 合法；displacement budget 足够 | instance ID/master/connectivity 不变；iPL 返回实际位置和 legal delta | FIXED_OBJECT, OUT_OF_REGION, POST_ROUTE_UNSUPPORTED |
| `reconnect` | 只允许 proposal 内声明的 buffer/clone load partition；driver/pin direction/type/logic equivalence 已证明 | load 从 old net 精确迁到 new net；不得增减 port；连接图 hash 符合预期 | ARBITRARY_REWIRE_FORBIDDEN, DIRECTION_MISMATCH, EQUIVALENCE_UNPROVEN |

`driver_clone` 可作为后续 P1 composite action：必须有组合等价证明、load partition 和 power/domain/placement/route validation。没有 formal/LVS adapter 时 manifest 返回 `UNSUPPORTED`，不能借 `reconnect` 偷渡。

### 5.4 `EcoProposal`

```yaml
schema: timingopt.eco_proposal@1.1
proposal_id: sha256:context-diagnosis-actions-policy-seed
context_ref: sha256:canonical-context
diagnosis_refs: [sha256:diagnosis-a]
base_snapshot_ref: sha256:base
generator:
  name: setup-portfolio-generator
  version: 1.1.0
  build_ref: sha256:binary
  seed: 4812
actions: [sha256:action-0, sha256:action-1]
composition:
  order: [0, 1]
  dependency_edges: [[0, 1]]
  atomic_apply: true
predicted_metrics:
  - {metric: setup_wns, scenario: func_ss, delta: 0.041, unit: ns, p10: 0.020, p90: 0.060}
  - {metric: hold_wns, scenario: func_ff, delta: -0.008, unit: ns, p10: -0.016, p90: 0.000}
  - {metric: area, delta: 4.20, unit: um2}
confidence: 0.71
fidelity: F1
assumptions: [estimated_rc, gba, no_coupling_update]
risk_flags: [HOLD_NEAR_GATE, LOCAL_CONGESTION]
change_cost: {actions: 2, inserted_instances: 1, area_um2: 4.20}
declared_touched_upper_bound_ref: sha256:scope
fallback_proposal_refs: [sha256:conservative-alternative]
```

proposal canonicalization 排序 map keys、scenario IDs 和 set-like refs，但保留 action order。任何 action、context、policy 或 seed 改变都产生新 proposal ID。

### 5.5 `TypedDelta`

```yaml
schema: state.typed_delta@1
delta_id: sha256:canonical-operations
base_snapshot_ref: sha256:base
branch_ref: branch:candidate-17
proposal_ref: sha256:proposal
operations:
  - op: substitute_master
    object_ref: idb:inst:0187@42
    before: {master_ref: tech:libcell:NAND2_X1_RVT}
    after:  {master_ref: tech:libcell:NAND2_X2_LVT}
  - op: create_instance
    stable_id: new:inst:4e10
    master_ref: tech:libcell:BUF_X4_RVT
    location_dbu: [182000, 95100]
  - op: create_net
    stable_id: new:net:711b
    connect_type: signal
  - op: reconnect_pin
    pin_ref: idb:pin:aa10
    before_net_ref: idb:net:09af
    after_net_ref: new:net:711b
inverse_operations_ref: cas:inverse-delta
actual_touched_ref: cas:actual-object-set
dirty_set_ref: cas:dirty-set
adapter_build_ref: sha256:adapter
apply_sequence: 1082
```

TypedDelta 由 iDB/iECO schema owner 定义；上例规定 iTO 所需字段，不授权 iTO 自建不兼容 delta 类型。before 值来自 branch head，不能从 proposal 预测复制。

### 5.6 `DirtySet`

```yaml
schema: state.dirty_set@1
source_delta_ref: sha256:delta
connectivity:
  instances: [idb:inst:0187, new:inst:4e10]
  nets: [idb:net:09af, new:net:711b]
  pins: [idb:pin:aa10]
placement:
  instances: [idb:inst:0187, new:inst:4e10]
  rows: [idb:row:109]
  bins: [idb:bin:3004, idb:bin:3005]
routing:
  nets: [idb:net:09af, new:net:711b]
  regions_dbu: [[179000, 92000, 185000, 98200]]
  coupling_neighbor_nets: [idb:net:0a20]
rc: {nets: [idb:net:09af, new:net:711b, idb:net:0a20]}
timing:
  seeds: [idb:pin:aa10, new:inst:4e10/Y]
  directions: [forward, backward]
  scenarios: [func_ss, func_ff]
power: {instances: [idb:inst:0187, new:inst:4e10], activity_cone: affected}
drc: {regions_dbu: [[178000, 91000, 186000, 99200]], rules: policy_required}
expansion_log: []
```

传播顺序固定为 connectivity -> placement -> route/coupling -> RC -> timing -> power/IR/DRC。每个工具记录 requested/consumed/expanded scope；扩大超过 policy 上限返回 `SCOPE_EXPANSION_REQUIRED`，由 Runtime 追加预算或拒绝。

---

## 6. Screening、结果与证据契约

### 6.1 Fidelity

| 档 | 允许计算 | 用途 | 禁止结论 |
|---|---|---|---|
| F0 | Liberty arc/load sensitivity、HPWL/Steiner delta、面积/VT table、规则启发式 | 大规模 infeasible/prune | timing/DRC/legal PASS |
| F1 | common topology + estimated RC + selected approved scenarios；可复用 legacy iTO evaluator | portfolio ranking、风险区间 | MCMM closure、post-route clean |
| F2 | branch actual delta + iPL local legal + dirty iRT/iRCX + dirty-cone common iSTA +局部 DRC | Top-K 候选确认 | 超出 scope 的 full-chip claim |
| F3 | required full scenarios、full relevant RC/route/DRC/STA policy；必要时 selected PBA | commit 前 open-source gate | commercial signoff 等价 |
| F4 | 冻结 commercial/signoff oracle | 校准、相关性、最终外部 qualification | 在线默认能力 |

升级条件：near hard gate、prediction interval 跨 0/limit、OOD、coupling sensitive、high fanout、大拓扑变更、F1 排名接近、required policy、增量/full age 超限。

### 6.2 `ScreeningResult`

```yaml
schema: timingopt.screening_result@1.1
request_id: uuid
context_ref: sha256:context
status: PARTIAL
records:
  - proposal_ref: sha256:p1
    disposition: ESCALATE
    fidelity_used: F1
    predicted_metrics_ref: cas:metric-vector
    uncertainty_ref: cas:intervals
    risk_flags: [HOLD_NEAR_GATE]
    prune_reasons: []
  - proposal_ref: sha256:p2
    disposition: REJECT
    prune_reasons: [AREA_BUDGET_EXCEEDED]
coverage:
  requested_scenarios: [func_ss, func_ff]
  evaluated_scenarios: [func_ss]
partial_reasons: [F1_HOLD_MODEL_UNAVAILABLE]
cost: {wall_ms: 821, candidates: 20}
```

screening 先做结构/预算/不变量 hard prune，再做 dominance 与模型筛选。模型失败不能把 candidate 自动判劣；若 hard feasibility 未知且 budget 允许则升级，否则 `UNDECIDED_BUDGET_EXHAUSTED`。

### 6.3 `OptimizationResult`

```yaml
schema: timingopt.optimization_result@1.1
result_id: sha256:branch-head-policy-bundle
proposal_ref: sha256:p1
delta_ref: sha256:delta
base_snapshot_ref: sha256:base
candidate_snapshot_ref: sha256:candidate-head
status: VERIFIED
metric_deltas_ref: cas:base-vs-candidate-metrics
hard_gate:
  verdict: PASS
  certificate_bundle_ref: cas:verification-bundle
  policy_ref: sha256:timing-eco-gate
scenario_results:
  - {scenario_id: func_ss, setup_wns_ns: 0.004, setup_tns_ns: 0.0, drv_count: 0}
  - {scenario_id: func_ff, hold_wns_ns: 0.006, hold_tns_ns: 0.0, drv_count: 0}
actual_change_cost:
  actions: 2
  inserted_instances: 1
  area_delta_um2: 4.08
  total_displacement_dbu: 600
prediction_error_ref: cas:predicted-vs-actual
dirty_set_ref: cas:consumed-dirty-set
evidence_pack_ref: cas:ito-evidence
```

### 6.4 Evidence pack

```text
manifest.json
context.json / intent.json / capability-manifest.json
diagnoses.json / proposals.json / screening.json
apply-request.json / typed-delta.json / inverse-delta.json
dirty-set-requested.json / dirty-set-consumed.json
metrics-before.json / metrics-after.json / prediction-error.json
verification-plan.json / certificate-bundle.ref
decision-record.ref / event-log.jsonl
tool-model-build-hashes.json / seeds.json / budget-ledger.ref
artifacts/*.ref
```

manifest 中每个文件有 content hash、schema、producer 和 retention。日志不是事实源；缺少 raw/normalized validator artifact 时证书不可验证。

---

## 7. 候选生成、剪枝、组合与停止算法

### 7.1 Generator portfolio

每个 root cause 至少尝试下列可用 family；不适用须给 reason：

| 问题 | 保守候选 | 中等候选 | 激进候选 |
|---|---|---|---|
| setup cell delay | 相邻 drive resize | footprint-compatible LVT/resize | 多 cell resize + buffer/rebuffer |
| setup net RC/load | driver resize | 单 buffer/load split | VG/rebuffer +受限 move |
| hold | HVT/downsize（setup 有裕量） | 单 delay buffer | 分段 buffer/reconnect |
| slew/cap | resize driver | buffer split | tree-aware multi-buffer/rebuffer |
| fanout | load partition | 单级 buffer tree | bounded two-level tree |

no-op baseline 必须作为 compare anchor，但不计作“多样化 action”。同一 cell 的相邻三个 size 只算一个 family；portfolio diversity 至少按 `(action family, target root cause, parameter band)` 统计。

### 7.2 生成步骤

```text
for root cause in deterministic severity order:
  enumerate applicable action families from manifest
  resolve legal library/master/VT alternatives
  enumerate bounded topology/location/load partitions
  build single-action proposals
  estimate touched upper bound and hard feasibility
  retain conservative / median / aggressive representatives

build combinations only from retained singles:
  add dependency edges
  reject conflict or duplicate semantic effect
  cap action depth and beam width by intent
  canonicalize and assign deterministic IDs
```

location 枚举由 iPL feasibility query 给 window/sites；legacy `Placer::findNearestSpace` 只可在 F0/F1 generator 中提出 hint，不能证明可放置。

### 7.3 Hard prune 顺序

1. schema/context/object revision/frozen/lease feasibility；
2. action-specific equivalence、pin map、domain/stage；
3. declared scope 与 change budget；
4. obvious area/utilization/master availability；
5. predicted required scenario hard-limit risk；
6. duplicate semantic proposal；
7. dominance/low expected value only after uncertainty considered。

所有 rejected proposal 保留首个 decisive reason 和其他 observed reasons。禁止只保留 Top-K 而丢失其余候选去向。

### 7.4 组合与冲突

两个 action 可组合必须同时满足：

- 写对象集合不冲突，或存在显式 dependency（如 insert 后 move 新 cell）；
- 一个 action 的 precondition 在前序 action 后仍可解析；
- touched/dirty、change/compute budget 合并后不过限；
- setup/hold 风险不是明显相反且无 scenario margin；
- reconnect/rebuffer 的 net split stable ID 与后续 action 引用一致。

首版 `max_action_depth` 默认由 intent 指定，建议 3；beam search 每层先 hard prune、再按 Pareto + diversity 保留。该建议不是固定产品默认值，实际值进入 policy/version。

### 7.5 预算

Runtime BudgetLedger 执行 reserve/debit/refund：

```text
reserve diagnose + F0/F1
  -> debit actual
reserve K candidate branches + expected F2
  -> apply/verify each; debit actual
reserve F3 for frontier/near-gate
  -> return unused credit
```

iTO 不能透支或把 wall timeout 改为 success。超过单 proposal change budget 是 hard reject；达到全 experiment compute budget则返回 verified incumbent/frontier 和未评估原因。

### 7.6 选择与停止

候选选择顺序：

1. 删除 required hard claim fail/incomplete/stale 的候选；
2. 对 near-gate/uncertain/frontier 请求更高 fidelity；
3. 对 `(violation magnitude, WNS/TNS, DRV, power, area, congestion, change cost)` 保留 Pareto；
4. 用 intent 显式 tie-break，不用隐藏总分；
5. Runtime 决定 select/commit，iTO 只返回建议和证据。

停止条件逐项记录：required violations clean、change budget exhausted、compute budget exhausted、连续 N 轮 improvement 小于 epsilon、proposal signature oscillation、no applicable/feasible proposal、scope expansion denied、timeout、cancel、policy max rounds。N/epsilon/max rounds 必须来自 versioned stop policy。

---

## 8. 风险模型与 MCMM

### 8.1 风险向量

每个 proposal 的预测和实测都保留向量，不能压成一个 reward：

| 域 | 必测/预测项 | 典型 action 风险 |
|---|---|---|
| setup | WNS/TNS、violating endpoints、path groups、rise/fall | HVT/downsize/move away/buffer delay |
| hold | WNS/TNS、violating endpoints、rise/fall | LVT/upsize/shorter route/driver clone |
| DRV | slew/cap/fanout count、magnitude、limit source | resize 增 input cap；buffer partition 不当 |
| placement | legal、overlap、row/orientation/region、utilization | resize width、insert、move |
| route/DRC | routability、overflow、new rule violations、antenna policy | insert/reconnect/rebuffer/move |
| RC/crosstalk | R/C、coupling neighbors、delta delay/noise | 拓扑/route/local move 改邻线 |
| power/area | leakage/dynamic/area、activity coverage | LVT/upsize/buffer tree |
| IR/reliability | current density/IR risk policy | 大量 LVT/upsize/集中插 buffer |
| functional/state | connectivity、pin map、frozen scope、equivalence | master swap/reconnect/rebuffer |

### 8.2 MCMM 规则

- context 固定 required scenario set；每个 scenario 至少包含 mode、PVT、RC corner、derate/OCV、check coverage 和 constraint ref。
- setup 与 hold scenario 不互相代替；每个 hard scenario 分别过门，不能以加权平均抵消。
- F0/F1 可由 FidelityPolicy 选代表 scenario，但必须标出 omitted scenarios 和升级条件。
- F2 dirty cone 必须覆盖 delta 影响的所有 required scenarios；scenario-specific graph/RC/derate 不可跨 context cache。
- F3 commit gate 运行 policy 指定 required full scenarios；任何一个 required scenario UNKNOWN/PARTIAL 即 bundle incomplete。
- `worst scenario` 可用于排序，不可用于证明其他场景 coverage。
- scenario 新增、lib/RC/SDC/derate 变化使 diagnosis、proposal prediction、metric、certificate 全部 stale。

### 8.3 Setup/Hold 交叉保护

对于 proposal `p`：

```text
setup_gain_s = base_setup_violation_s - candidate_setup_violation_s
hold_loss_h  = candidate_hold_violation_h - base_hold_violation_h
```

任一 hard hold scenario 新增 violation，proposal 在该 fidelity 为 hard fail；不能用 setup gain 抵消。反向同理。若低 fidelity 的 prediction interval 触及 gate，则必须升级，不允许按均值接受。

### 8.4 Crosstalk 与 stage

| Stage | RC/route 语义 | crosstalk policy |
|---|---|---|
| post-place/post-CTS | placement/Steiner estimated RC | 标记 `no_coupling`；敏感网升级或保守 margin |
| post-GR | global-route RC/拥塞 | 读取 route neighbor/coupling proxy，变更邻域进 DirtySet |
| post-route | extracted RC + local route ECO | coupling-aware iRCX/iSI required；move 默认 unsupported |

没有 coupling adapter 时结果是 assumption/unsupported，不是零噪声。

---

## 9. 跨工具调用顺序与事务

### 9.1 Read-only 阶段

```text
Runtime resolves immutable TimingContext
  -> iDB inspect object/scope/protection/revisions
  -> common iSTA inspect coverage/top paths/DRV
  -> iRCX/iRT inspect available RC/route fidelity
  -> iEval inspect metric capability/calibration
  -> iTO diagnose -> propose -> screen
```

任一 read adapter 若只能访问 singleton current design，Gateway 必须把 snapshot 装入隔离/串行 session，并校验前后 state hash。

### 9.2 Candidate 写/验证顺序

```text
1. Runtime reserve budget, fork branch, acquire write/object/region leases
2. iDB begin transaction(expected branch head, fencing generation)
3. iTO EcoDeltaAdapter checks preconditions
4. iDB/iECO apply netlist/master/connectivity operations atomically
5. iDB state-integrity + actual-touched reconciliation
6. iPL apply move/placement requests and local legalize
7. iRT check/perform required local route feasibility or ECO
8. iRCX update dirty nets plus coupling neighbors
9. common iSTA update dirty cones for all affected required scenarios
10. iDRC validate required region/rules
11. iPA/iIR update if policy/action risk requires
12. Verification Hub normalize results and issue exact-head certificates
13. iEval compare base/candidate, hard gate, Pareto/evidence
14. Runtime mark READY_TO_SELECT or reject/abandon
15. Runtime exact candidate-head CAS commit, never iTO
```

connectivity/state-integrity 失败时不继续 expensive validators。工具可并行仅当输入 immutable、依赖已满足、session isolation 已 qualification；legacy singleton 路径串行。

### 9.3 事务边界

- `apply` 的原子单位是一个 proposal；多 action 按 dependency order 执行，任何 action 失败则整个未发布 transaction abort。
- iDB 事务成功只表示 TypedDelta 已落 candidate branch，不表示物理/时序可接受。
- local legal/route/RC/STA 是 transaction 后 candidate verification；失败时 Runtime abandon branch，不能把部分动作 cherry-pick 到主 head。
- optimization pass 的多轮 candidate 各有独立 verified head；只有 Runtime 可从 incumbent fork 下一轮。
- 批量 apply 可减少开销，但每个 action 仍有 operation records；失败时二分定位仅用于诊断，最终未验证 batch 整体回收。

### 9.4 CAS 与幂等

```yaml
apply_request:
  idempotency_key: exp-8/cand-17/apply-1
  branch_ref: branch:candidate-17
  expected_head_ref: sha256:head-6
  expected_candidate_revision: 9
  lease_fencing_generation: 31
  proposal_ref: sha256:p1
```

重复相同 request 返回原 `ApplyResult`；相同 key 不同 payload 返回 `IDEMPOTENCY_CONFLICT`。head/revision/fence 任一不匹配为 `STALE_CONTEXT`/`LEASE_LOST`，不得自动 rebase 高风险 timing delta。

### 9.5 Rollback 与补偿

```text
before apply: persist proposal + precondition evidence
during apply: append typed operation journal
on operation failure: inverse journal in reverse order inside transaction
after abort: compare branch state hash to pre-transaction hash
if equal: ROLLED_BACK
if unequal: FAILED_ROLLBACK -> branch CORRUPTED -> destroy/quarantine
```

对已 materialize 的新对象，inverse 删除时保留 tombstone/lineage。外部工具临时 artifact 由 workflow compensation 清理，但证据引用按 retention 保留。主 head 从不依赖“反向再改回来”；候选失败优先 abandon isolated branch。

### 9.6 Replay

replay 固定 base snapshot、context、proposal、TypedDelta、tool/model/build hashes、seed 和 policy。分两级：

- structural replay：delta operation、stable IDs、actual touched、final snapshot hash 一致；
- analytical replay：相同 deterministic qualification 下 metric/certificate hash 一致；非确定工具保存重复统计和允许 tolerance。

工具/模型版本不可获得时返回 `UNREPLAYABLE_DEPENDENCY`，不能用新版本结果冒充原决策。

---

## 10. 错误、partial、unsupported 与 timeout

### 10.1 统一 envelope

```yaml
status: PARTIAL
code: REQUIRED_SCENARIO_MISSING
message: hold analysis unavailable for func_ff
retryable: false
phase: verify
completed_items: [connectivity, legal, setup_func_ss]
missing_items: [hold_func_ff]
incumbent_ref: sha256:last-verified-candidate
diagnostics_ref: cas:error-details
evidence_pack_ref: cas:partial-evidence
```

### 10.2 状态语义

| Code | 含义 | 可否提交 | 恢复 |
|---|---|---:|---|
| `NO_VIOLATION` | requested coverage 内无目标违例 | 否，无候选 | 正常终止 |
| `NO_APPLICABLE_ACTION` | 有问题但 manifest/policy 下无动作 | 否 | 扩 capability 或人工处理 |
| `UNSUPPORTED` | action/stage/scenario/adapter 不支持 | 否 | 换 provider/policy，不降格 success |
| `PARTIAL` | 有部分有效结果且明确缺口 | 否，若缺 required claim | 补预算/adapter/coverage |
| `STALE_CONTEXT` | snapshot/head/object revision 变化 | 否 | 重新 inspect/diagnose/propose |
| `PRECONDITION_FAIL` | action 假设不成立 | 否 | 拒绝 proposal |
| `INFEASIBLE_PHYSICAL` | 无合法位置/route/domain 可行性 | 否 | 生成其他 family |
| `SCOPE_EXPANSION_REQUIRED` | 下游保守扩大超过授权 | 否 | Runtime 批准新 scope 后重跑 |
| `VALIDATION_FAIL` | required hard gate 明确失败 | 否 | reject/记录 failure memory |
| `VALIDATION_INCOMPLETE` | required validator unknown/partial/timeout | 否 | 补验证 |
| `TIMEOUT_WITH_PARTIAL` | 无 verified incumbent，只有 partial | 否 | 返回 partial evidence |
| `TIMEOUT_WITH_INCUMBENT` | 有上一次 exact-head verified incumbent | 仅该 incumbent 可进入选择 | Runtime 决定 |
| `CANCELLED` | 已安全停止且无写事务悬挂 | 否 | 可从持久状态新建请求 |
| `FAILED_ROLLBACK` | state hash 无法恢复 | 否 | branch CORRUPTED/incident |
| `STALE_BASE` | commit CAS 与主 head 冲突 | 否 | Runtime 新实验；不自动 rebase |

### 10.3 Partial 纪律

有效 partial 必须列 completed/missing scope、scenarios、checks、actions 和 artifacts。`PARTIAL` 不允许携带 `hard_gate.verdict=PASS`。timeout 后只能返回已经完成证书且绑定未变 head 的 incumbent；“分析跑了一半但 WNS 看起来更好”不是 incumbent。

---

## 11. TARGET 源码落点与兼容策略

### 11.1 新目录

```text
src/operation/iTO/agent/
  CMakeLists.txt
  api/
    TimingOptCapability.{hh,cc}
    TimingOptService.{hh,cc}
    ResultEnvelope.hh
  contract/
    TimingContext.hh
    OptimizationIntent.hh
    TimingDiagnosis.hh
    EcoAction.hh
    EcoProposal.hh
    OptimizationResult.hh
  diagnose/
    TimingDiagnoser.{hh,cc}
    AttributionConservation.{hh,cc}
  propose/
    CandidatePortfolio.{hh,cc}
    ResizeGenerator.{hh,cc}
    VtSwapGenerator.{hh,cc}
    BufferGenerator.{hh,cc}
    RebufferGenerator.{hh,cc}
    MoveGenerator.{hh,cc}
    ReconnectGenerator.{hh,cc}
    CombinationPlanner.{hh,cc}
  screen/
    AnalyticScreen.{hh,cc}
    FidelityRouter.{hh,cc}
    RiskVector.{hh,cc}
  apply/
    EcoDeltaAdapter.{hh,cc}
    ActionPreconditionChecker.{hh,cc}
    DirtySetBuilder.{hh,cc}
  control/
    PassController.{hh,cc}
    StopPolicy.{hh,cc}
  adapter/
    LegacyToAdapter.{hh,cc}
    IdbAdapter.{hh,cc}
    IstaAdapter.{hh,cc}
    IplAdapter.{hh,cc}
    IrcxAdapter.{hh,cc}
    VerificationAdapter.{hh,cc}
  evidence/
    EvidencePackWriter.{hh,cc}
```

schema 若平台已有共享定义，应引用共享包而非在 iTO 复制。`PassController` 只依赖 capability interfaces/Runtime client，不直接获取 `toConfig`、`timingEngine`、`toDmInst`、`toPlacer` singleton。

### 11.2 现有代码收编

| CURRENT 资产 | 首次收编 | 改造原则 |
|---|---|---|
| `ViolationOptimizer` | DRV candidate generator | 先拆 check/enumerate 与 mutate；tree repair 输出 proposed split/buffer locations |
| `SetupOptimizer` gate sizing | ResizeGenerator | 暴露所有合法 alternatives/预测，不在 generator 内 `repowerInstance` |
| VG buffering/split buffering | Buffer/RebufferGenerator | 输出完整 topology action；保留 deterministic option ordering |
| `HoldOptimizer` | Hold BufferGenerator | 先输出 affected setup scenarios/risk，不直接 insert |
| `TOLibRepowerInstance` | EcoDeltaAdapter legacy backend | apply 前 pin/function/domain 检查；记录 exact before/after/inverse |
| `EstimateParasitics` | F1 IrcxAdapter fallback | 返回 fidelity/assumptions/coverage；invalid pointer set 转 stable DirtySet |
| `Placer` | F0 location hint fallback | 不签 legal；真实 apply/verify 调 iPL |
| `ToDataManager` counters | Legacy metrics | budget authoritative source 改 Runtime ledger |

### 11.3 CMake

新增 `ito_agent_contract`、`ito_agent_core`、`ito_agent_adapters`、`ito_agent_api` targets；contract target 不链接 mutable tool singletons。legacy `ito_api/ito_source` 继续构建。测试按 unit/component/integration 单独 target，不继续把全仓 `CMAKE_BUILD_TYPE` 在子目录强制改为 Release/Debug；该清理可在不改变行为的独立 PR 完成。

### 11.4 兼容入口

- Tcl/Python `run_to*` 保持 legacy 语义并明确 `legacy_mutating=true`，不注册给 Agent Tool Registry。
- 可新增人工调试命令导出 diagnosis/proposals，但默认只读。
- 原 config 由 `LegacyIntentConverter` 显式转换；空 buffer string、无效 master、缺 file 等错误在 converter 中结构化报告。
- legacy output summary 通过 adapter 补 provenance，但不得反向改变现有 summary 数值。

---

## 12. 分阶段 PR 与依赖门禁

| PR | 内容 | 真实落点 | 合入门禁 |
|---|---|---|---|
| TO-0 | CURRENT 数值锁、schema、capability manifest、只读 state-hash guard | `agent/contract`, `agent/api`, legacy tests | diagnose/propose 前后 hash 100% 不变；legacy benchmark 数值锁 |
| TO-1 | inspect/diagnose、path/DRV evidence、attribution conservation | `agent/diagnose`, iSTA adapter | setup/hold rise/fall/DRV coverage；attribution tolerance property |
| TO-2 | resize/VT proposal + typed apply/inverse | generators + `EcoDeltaAdapter` | 500 随机 action/inverse 零残留；pin/function/domain checks |
| TO-3 | insert buffer/reconnect/rebuffer + stable new IDs | buffer/reconnect generators | split connectivity/equivalence；replay ID/hash 一致 |
| TO-4 | iPL move/local legal + DirtySet + iRCX/common iSTA F2 | adapters + DirtySetBuilder | dirty/full RC/STA 对拍；scope expansion 诚实 |
| TO-5 | portfolio/screen/combination/budget/stop | screen/control | deterministic portfolio、terminal disposition 守恒、cancel/timeout |
| TO-6 | Verification Hub/iEval/iECO timing workflow | verification/evidence adapters | incomplete bundle 无 commit 路径；Timing Lab branch e2e |
| TO-7 | MCMM/coupling/power/area/route-aware F3 | scenario/risk adapters | required scenario/rule coverage；full/incremental qualification |
| TO-8 | F4 commercial calibration与 qualification | oracle harness/report | held-out 相关性/Recall/regret/bias 报告，失败不隐瞒 |

依赖顺序：共享 context/TypedDelta/DirtySet/Runtime/Hub schema 尚未落地时，TO-0 只可用 versioned local prototype + adapter，合入公共分支前必须消除重复定义。每个 PR 可独立关闭 capability；不能用 stub 返回 `SUCCESS`。

---

## 13. 测试金字塔与故障注入

### 13.1 Unit / schema

| ID | 测试 |
|---|---|
| TO-T01 | context/intent/action/proposal/result schema：缺字段、单位错、未知 major、canonical hash |
| TO-T02 | stable object/new object ID；重命名、replay、net split、tombstone |
| TO-T03 | master function/pin/footprint/VT/domain 分类，ambiguous pin map 拒绝 |
| TO-T04 | attribution conservation、path semantic matching added/removed/ambiguous |
| TO-T05 | DirtySet 各 action 传播与“只能扩大”property |
| TO-T06 | budget merge、combination conflicts、deterministic order、stop/oscillation |

### 13.2 Component

| ID | 测试 |
|---|---|
| TO-T07 | resize/VT apply + inverse：位置/连接/ID/master/面积 before-after |
| TO-T08 | insert buffer load partition、reconnect、rebuffer atomic failure |
| TO-T09 | move fixed/region/site/orientation/no-site、iPL actual location |
| TO-T10 | setup/hold/DRV 交叉风险与 rise/fall coverage |
| TO-T11 | F0/F1 prediction interval、OOD、near-gate escalation、模型 unavailable |
| TO-T12 | legacy singleton serialized session 与 read-only hash guard |

### 13.3 Integration

| ID | 测试 |
|---|---|
| TO-T13 | action -> iDB TypedDelta -> connectivity -> iPL legal -> iRCX -> iSTA dirty cone |
| TO-T14 | dirty/full RC、setup、hold、DRV 对拍；超 tolerance 撤销 incremental qualification |
| TO-T15 | required MCMM 漏一个 scenario、edge 或 check 必须 INCOMPLETE |
| TO-T16 | route/coupling neighbor 扩大 DirtySet；scope limit 触发 request |
| TO-T17 | Hub required claim fail/partial/stale；iEval hard gate/Pareto |
| TO-T18 | Runtime exact-head CAS、lease fencing、idempotency、重复 apply/commit |

### 13.4 E2E / benchmark

- `aes` 现有多 PDK setup/hold/DRV 脚本转为固定输入、固定 seed 的 legacy baseline 与 Agent branch flow 对照；生成文件留在 out-of-tree artifact，不入源码。
- 覆盖 sparse/dense placement、high fanout、multi-output、clock/reset/constant、macro 邻域、无等价 master/VT、post-CTS 和 post-GR。
- 每个 design 至少运行 no-op、legacy pass、agent portfolio 三组；比较 hard correctness、QoR、成本和 action count。
- held-out 集不能参与 generator/ranker/calibration 参数选择；结果按 PDK/design family/stage/scenario 分桶。

### 13.5 故障注入

在 apply 每个 operation 前后、iPL legal、iRT、iRCX、iSTA、iDRC、Hub issue、artifact write、Runtime commit CAS 注入 crash/timeout/cancel/stale/partial。必须验证：无主状态污染、无重复对象、budget 不为负、branch health 正确、最后 verified incumbent 不丢、失败 evidence 可重放。

### 13.6 Fuzz / property

- 随机合法 action sequence 后 `apply(inverse(delta))` 恢复 base structural hash；
- 随机 delta sequence 中，所有读取被改输入的 certificate 必须失效；
- proposal 数等于 terminal dispositions 总数；apply 数等于 delta 或明确 apply failure 数；
- action declared touched 包含 actual touched，否则必为 `SCOPE_VIOLATION`；
- 任意 required gate incomplete 均不存在 READY_TO_COMMIT transition；
- 相同 context/policy/seed 的 candidate IDs/order 一致。

---

## 14. 商业相关性、指标协议与量化 DoD

### 14.1 对拍协议

商业工具只作为 F4 oracle。冻结：输入 DEF/netlist/SDC/liberty/SPEF 或 RC tech、scenario/derate、stage、dont_touch/frozen sets、线程/机器、wall budget、seed 和 action budget。open-source 与 commercial 结果先做 coverage/单位/path/scenario 对齐，再算相关性；coverage 不同的点不能硬配成数值样本。

### 14.2 必报指标

| 类别 | 指标 |
|---|---|
| correctness | invalid commit=0、rollback residue=0、scope escape=0、required incomplete commit=0 |
| timing correlation | per-scenario WNS/TNS bias、MAE、P95 absolute error、worst error、direction accuracy |
| ranking | Recall@K、NDCG@K、pairwise direction accuracy、selected-candidate regret |
| DRV | violation precision/recall、magnitude error、limit/edge coverage |
| physical | legal/route feasibility precision/recall、new DRC escape、area/power delta error |
| incremental | dirty/full disagreement rate、P95/worst slack delta、missed endpoint/DRV count |
| efficiency | proposals/s、F2/F3 calls、median/MAD/P95 wall、peak RSS、oracle cost saved |
| robustness | UNKNOWN/PARTIAL/OOD/timeout rate、replay success、failure recovery success |

Pearson/Spearman 可报告，但不能单独作为资格。WNS 相关高而 Top-K recall 低仍不适合 agent selection。

### 14.3 ai1.1 量化完成定义

| Gate | DoD |
|---|---|
| Contract | 100% Agent 调用带 context/schema/status/evidence；无裸 `void/bool/double` 穿越边界 |
| Read-only | 10,000 次随机 inspect/diagnose/propose/screen 前后 snapshot structural hash 零变化 |
| Transaction | 每类 action 至少 500 个合法/非法 property cases；合法 apply+inverse structural hash 零残留，非法无 partial mutation |
| Stable/replay | 固定 toolchain 下 1,000 次 replay 的 proposal/delta/stable ID/hash 100% 一致 |
| Dirty/full | qualification 集中 required scenario 的 missed endpoint/DRV=0；slack tolerance 采用冻结 iSTA policy，超限自动撤销资格 |
| Hard gate | fault-injection 与 E2E 中 invalid/incomplete/stale certificate commit 路径为 0 |
| Portfolio | 相同 change/F3 budget 下，held-out `Recall@K` 和 selected regret 均优于 legacy single-choice baseline；若不优则不启用 learned ranker |
| Closure | 冻结 Timing Lab 的每个 accepted candidate 在 F3 required setup/hold/DRV/connectivity/legal policy 全 PASS；不要求每个设计必须有改善 |
| Correlation | 发布 per-bucket bias/P95/worst/Recall@K/regret；阈值由 TO-8 qualification policy 冻结后入 CI，不在本文杜撰固定 ps 数 |
| Operations | timeout/cancel/worker loss 保留 exact-head verified incumbent；rollback corruption 100% 隔离并告警 |

“10 case 中 8 个改善”不足以证明能力：未改善可以是无 feasible action；真正硬条件是零非法提交、证据完整和相同预算下选择质量。任何 QoR 数字必须同时带置信区间、样本数和失败样本。

### 14.4 可杀假说

**H-TO-A1**：在固定 change/F3 budget 下，多 family proposal + uncertainty escalation 比 legacy 单一路径贪心降低 held-out selected-candidate regret，且不增加 escaped hard violation。若不成立，依次审计候选多样性、common STA/RC 一致性、screen calibration 和组合冲突；不直接增加强化学习复杂度。

**H-TO-A2**：TypedDelta + isolated branch 能将 failure-injection 后主状态污染降为 0。若仍污染，暂停 action 扩展并修复 transaction/adapter ownership。

---

## 15. 运维、版本与退出条件

### 15.1 运行指标

按 capability/action/stage/scenario/provider 分桶记录：status、latency、budget debit、candidate count、prune reason、scope expansion、prediction error、incremental/full disagreement、rollback failure、certificate incomplete、CAS conflict、replay failure。禁止用总体 success rate 掩盖某 action/scenario 的 correctness 问题。

### 15.2 Qualification 与降级

- action adapter、incremental STA/RC、screen model 和 external oracle 各自有 qualification ref。
- full audit 推翻 incremental hard conclusion时，撤销相关 `(adapter, action, stage, scenario class)` 资格，而非只拒绝一个 candidate。
- 发现 invalid commit 时冻结 Timing ECO commit policy，保存 snapshot/evidence，回溯同 qualification bundle，补最小反例后由 owner 显式恢复。
- provider 不合格时 capability manifest 关闭相应 action/fidelity；不得静默切回 legacy mutating pass。

### 15.3 ai1.1 退出条件

完成 TO-0 至 TO-7、满足 14.3 correctness gates、至少一条真实 post-place/post-CTS Timing Lab branch e2e、全部 required claim 由 Hub 签发且 Runtime exact-head commit。TO-8 F4 相关性是 commercial qualification 条件；缺 F4 时可发布 open-source agent-native beta，但必须明确 `commercial_correlation=UNQUALIFIED`。

### 15.4 版本历史

| 版本 | 日期 | 变化 |
|---|---|---|
| ai1.0 | 2026-07 前 | diagnose/propose/apply/validate 初步提纲与 action 列表 |
| ai1.1 | 2026-07-24 | 加入真实源码审计、CURRENT/TARGET 分层、完整 capability/state/schema、稳定 ID、六类 action、MCMM 风险、候选算法、跨工具事务/CAS/rollback/replay、失败语义、源码 PR、测试金字塔、商业相关性与量化 DoD |
