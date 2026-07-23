<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->

# 51 · 面向 Agent 的 iEDA.ai 具体研发方案 · v1.0

> 日期：2026-07-23
> 定位：本方案是 `50-agent-era-eda-master-plan-v1.0.md` 的工程化展开，不替代 `00-ieda-commercial-parity-master-plan-v1.1.md`。
> 目标：把 iEDA 从“由工程师编写 Tcl 驱动的一组 EDA 程序”改造成“Agent 可观察、可试探、可修改、可验证、可回滚、可组合和可生成的 EDA 能力底座”。
> 事实纪律：本文将“已有代码资产”“需改造成 Agent 工具的能力”“未来新工具”分开标识；代码存在不等于精度、稳定性或商业对标已经达标。
> 后续扩展：新增工具 owner、现状/目标双视图、统一 Context/Certificate 和 formal/SI/多物理/3D 方案见 `53-agent-native-eda-architecture-v2.0.md`，实施顺序见 `52-agent-native-implementation-index-ai1.0.md`。

---

## 0. 版本与结论

### 0.1 本版相对 50 号总纲新增什么

`50` 号总纲给出了正确的战略方向：过程评估优先、多精度引擎、全流程归因、STA 先行和工具生成底座。本方案进一步补齐七个工程问题：

1. Agent 究竟调用“整工具”还是“原子能力”；
2. 设计状态、工具副作用、分支、回滚和并发如何管理；
3. 工具未完全完成任务时，如何返回对 Agent 有用的部分结果；
4. 低精度结果如何定义置信度，何时必须升级到高精度验证；
5. 当前 iEDA 每个模块如何进入 Agent 工具体系；
6. 除传统 P&R 工具外，还应出现哪些 Agent 专用工具；
7. 第一个 90 天做什么，如何证明方向有效。

### 0.2 核心结论

**结论 A：产品单位应从“工具”改成“可验证的设计操作”。**

Agent 不需要另一个带命令行的 `place_opt`。它更需要：

- 查询某条路径为何关键；
- 获得候选修复动作及影响范围；
- 在分支快照上插入一个 buffer；
- 只合法化受影响区域；
- 只重提受影响网络；
- 只重算受影响时序锥；
- 比较修改前后 PPA 与新增风险；
- 不合格时原子回滚。

**结论 B：近期首个产品切片应是“Agent-native Timing Closure Lab”。**

从 post-placement/post-CTS 快照开始，围绕 iSTA、iTO、iNO、iPL 增量合法化、iRCX/evaluation 快估构建事务化 ECO 闭环。它比直接承诺全流程自动流片更窄，但能同时验证 Agent 原生架构的核心价值。

**结论 C：工具可不完美，但边界不能不诚实。**

低精度、部分完成和超时都可以成为有效结果；静默跳过规则、伪造高置信度、修改一半却返回成功、无法复现和无法回滚不能接受。

**结论 D：商业工具对标仍然重要，但角色改变。**

商业工具主要承担四个角色：训练/校准 oracle、不可逆门禁的独立验证器、反例发现器和 PPA 上界参考，而不是 Agent 每一步都必须依赖的执行后端。

**结论 E：长期壁垒不是 LLM 包装层，而是“状态 + 原子操作 + 验证 + 数据飞轮”。**

单纯把 Tcl 命令包装成 MCP/REST 不会产生 Agent 原生 EDA。真正的壁垒是可追溯设计状态、事务式局部修改、统一增量分析、误差校准、反事实数据和失败经验库。

---

## 1. 先校正三项关键假设

### 1.1 “5 个 70% 模型得到 99% 可信度”不成立

`50` 号总纲使用了 `1-(1-p)^N`。该式计算“至少有一个模型正确”的概率，不是多数投票正确率，也没有解决如何识别哪个模型正确。

若 5 个模型独立、每个正确率都是 70%，简单多数投票正确率为：

```text
P(majority correct)
  = C(5,3) * 0.7^3 * 0.3^2
  + C(5,4) * 0.7^4 * 0.3
  + 0.7^5
  = 83.692%
```

EDA 代理模型通常共享训练数据、特征与物理简化，错误高度相关，真实提升可能更小。因此：

- 多模型一致只能作为“不确定性信号”，不能自动成为真值；
- 必须在 held-out 设计族和 held-out PDK 上校准；
- 必须报告错误相关性和 calibration curve；
- 硬门禁必须由独立物理模型、形式验证或 signoff oracle 验证；
- 模型一致但违反守恒、拓扑、合法性或单位不变量时，直接判失败。

### 1.2 “order 准确率”需要拆成可测指标

单一“排序一致率 90%”没有定义比较集合、相等处理和业务损失。建议按任务分别使用：

| 任务               | 主指标                            | 为什么                                 |
| ------------------ | --------------------------------- | -------------------------------------- |
| 找关键路径         | `Recall@K`、关键路径漏报率      | Agent 最怕漏掉真正最差路径             |
| 对候选 ECO 排序    | Kendall`tau`、pairwise accuracy | 衡量相对排序                           |
| 从候选中选一个执行 | selection regret                  | 衡量选错后损失多少，而非全排序是否完美 |
| 预测修改方向       | sign accuracy                     | 判断改善/恶化方向                      |
| 预测是否越过门禁   | false-negative rate               | 不能把不合法或有违例设计判为可行       |
| 返回数值           | MAE/P95、分桶偏差                 | 支撑阈值决策与归因                     |
| 返回置信度         | ECE/Brier、coverage-risk          | 证明 90% 置信度确实约有 90% 命中       |

过程工具的优先目标不是绝对数值完全相等，而是**低 selection regret、低关键项漏报、置信度可校准**。

### 1.3 Agent 能补救“求解不完整”，不能补救“验证不真实”

Agent 可以：

- 根据中间拥塞图改变搜索方向；
- 为局部问题生成脚本或小型求解器；
- 将一个大问题分解成多个局部问题；
- 发现工具不适用后切换引擎；
- 利用部分可行解继续优化。

Agent 不能可靠补救：

- DRC 跳过规则却报告 clean；
- STA 单位/场景错配却不声明；
- 数据库写出丢属性却返回成功；
- 设计被部分修改但没有变更日志；
- 训练数据泄漏导致的虚假泛化；
- 形式不等价或电源完整性不满足却没有独立门禁。

因此战略应是：**求解器允许近似，验证器必须诚实；动作可以投机，提交必须保守。**

---

## 2. Agent 与人类工程师对工具需求的差异

| 维度     | 面向人类的传统 EDA   | 面向 Agent 的 EDA                            |
| -------- | -------------------- | -------------------------------------------- |
| 主要入口 | GUI、Tcl、长流程脚本 | 强类型 API、状态 ID、结构化事件流            |
| 操作粒度 | 一次运行一个 stage   | 查询、候选生成、局部修改、局部验证           |
| 状态认知 | 工程师记忆当前流程   | 机器可读状态图与完整 lineage                 |
| 失败处理 | 日志后人工定位       | 结构化错误、失败域、建议替代方案、可恢复点   |
| 长任务   | 等待结束或人工看 log | anytime、progress、cancel、resume、incumbent |
| 结果形态 | 文本报告、GUI 热图   | JSON/Arrow/图切片 + 可选文本证据             |
| 精度选择 | 用户选择命令/effort  | 风险、预算、阶段和不确定性驱动自动升级       |
| 修改方式 | 工程师直接改数据库   | 分支快照中的事务，验证后 commit              |
| 可复现性 | 脚本大致复现         | 输入/版本/种子/环境/动作逐项可重放           |
| 多任务   | 多个工程师人为协调   | 多 Agent 锁、冲突检测、分支合并              |
| 工具扩展 | 厂商发布新命令       | 动态生成 adapter、分析器、局部求解器并过门禁 |
| 商业价值 | seat/license         | 成功闭环、计算资源、验证等级、服务 SLA       |

不应简单删除所有面向人的能力。维护者仍需要日志、可视化和调试台，但它们是**运维/证据界面**，不是产品主交互面。

---

## 3. iEDA 当前资产盘点

### 3.1 状态标记

| 标记  | 含义                                                           |
| ----- | -------------------------------------------------------------- |
| `A` | 有真实代码和调用路径，可直接作为改造起点；不表示已达到商业精度 |
| `B` | 有部分实现或窄能力，需补契约、精度或闭环后才能成为 Agent 工具  |
| `C` | 只有空壳/文档规划，或仓库中尚不存在，属于 greenfield           |

### 3.2 基础设施与接口

| 资产                  | 当前事实                                                                             | 状态 | 对 Agent 的价值                | 第一改造点                                           |
| --------------------- | ------------------------------------------------------------------------------------ | ---: | ------------------------------ | ---------------------------------------------------- |
| iDB / data manager    | LEF/DEF/Verilog 等读写和共享设计对象已在；完整性、增量更新、session 序列化仍是规划项 |  A/B | 统一设计状态的自然底座         | immutable snapshot + delta + validate + content hash |
| solver                | 合法化、几何与各工具私有数值内核存在，统一 solver contract 不完整                    |    B | 局部精确求解与生成工具复用     | 统一`SolverResult`、预算、界、不可行证据           |
| evaluation L1         | 拥塞、密度、线长、时序快估已有，iPL/iPNP 有消费路径                                  |    A | 高频低成本 sensor              | 声明适用域、误差带和输入状态                         |
| evaluation L2         | 统一 QoR schema/harness 在现有文档中仍属待建                                         |    C | Agent 的 reward 与提交门禁     | 先冻结 schema，不先做总分                            |
| feature/vectorization | 特征解析、图/patch/layout 向量化目录存在                                             |  A/B | 代理模型、检索、局部图查询     | 与 snapshot/delta ID 对齐，防特征陈旧                |
| `src/ai/predictor`  | 当前可见主资产是 iPL wirelength ONNX predictor                                       |    B | 证明模型嵌入路径存在           | 扩展为 model registry，不把单模型写死在工具内        |
| ToolManager/tool_api  | iPL/iCTS/iRT/iSTA/iTO 等门面存在                                                     |  A/B | adapter 的复用入口             | 从 bool/单例升级为版本化结构化响应                   |
| Tcl/shell             | DB、FP、PDN、PL、CTS、NO、TO、RT、DRC、STA、power、RCX、eval、ECO 等命令已注册       |    A | 兼容旧 flow、早期 adapter 后端 | 不作为 Agent 最终协议；补 rc 和结构化输出            |
| platform flow         | Tcl 启动骨架在，`tool_flow/` 基本空；当前 `ieda_main` 最终固定 `return 0`      |    B | 未来工作流运行时落点           | DAG、失败传播、产物断言、checkpoint、事件流          |
| benchmarks            | 已有 registry、flow manager、报告/脚本及多设计/多 PDK 资产                           |  A/B | 数据和回归起点                 | 冻结 protocol，核验可重复性与 gold 来源              |

代码证据入口：

- operation 注册：`src/operation/CMakeLists.txt`；
- Tool API：`src/platform/tool_manager/tool_api/`；
- Tcl 注册：`src/interface/tcl/tcl_register.h`；
- AI predictor：`src/ai/predictor/ipl_wirelength/`；
- flow 空壳与退出码：`src/platform/flow/tool_flow/`、`src/apps/ieda_main.cpp`；
- benchmarks：`benchmarks/`。

### 3.3 当前 EDA 工具如何进入 Agent 体系

| 工具      | 现有能力摘要                                                     | 状态 | 首批 Agent 化能力                                                                 | 中期增强                                                 |
| --------- | ---------------------------------------------------------------- | ---: | --------------------------------------------------------------------------------- | -------------------------------------------------------- |
| iFP       | die/core/row/track、IO、tap/endcap；宏规划能力未闭环             |  A/B | `floorplan.validate`、`io.propose`、`tap.check`                             | 约束驱动 auto-die、宏约束敏感性、候选 floorplan 生成     |
| iNO       | fix fanout/fix IO，真实插 buffer，但能力窄                       |  A/B | `fanout.diagnose`、`fanout.propose_tree`、事务式 apply                        | 关键度/物理位置驱动的树拓扑、与 iTO 冲突协调             |
| iPL       | 宏/全局/合法化/详细布局相关实现；增量与统一时序语义需增强        |  A/B | `place.query_region`、`place.move_delta`、`legalize.local`、`place.score` | timing/congestion/power 多目标候选、局部 exact placement |
| iCTS      | 时钟树构建和优化资产在；与统一 iSTA 的语义仍需对齐               |  A/B | `clock.query_tree`、`clock.propose_skew`、`clock.validate_delta`            | useful skew、跨场景鲁棒 CTS、clock ECO                   |
| iPDN/iPNP | PDN 构建与规划/评估资产存在                                      |  A/B | `pdn.query_coverage`、`pdn.propose_strap`、`pdn.check_connectivity`         | IR/EM/面积联合优化、局部加固、功耗域感知                 |
| iTO       | setup/hold/DRV/buffering 等优化能力在；事务与 veto 不完整        |  A/B | `timing.diagnose`、`eco.propose_resize/buffer`、`eco.apply_txn`             | multi-Vt、路径级组合动作、风险约束搜索                   |
| iRT       | 全局/详细布线能力较丰富；timing 接线和增量 ECO 是主要缺口        |  A/B | `route.query_congestion`、`route.local`、`route.check_delta`                | timing/SI/EM driven、局部 rip-up、DRC repair portfolio   |
| iRCX      | 2.5D R/C 与 SPEF 基础在；pattern 完备度、标定和增量缺失          |  A/B | `rc.estimate_net`、`rc.extract_scope`、`rc.compare`                         | dirty-net 增量、multi-neighbor/via/shield、误差校准      |
| iSTA      | 完整 GBA 与增量资产在；PBA/SI/MCMM 和三套时序语义问题仍需解决    |  A/B | `timing.top_paths`、`path.explain`、`timing.update_cone`                    | common timing engine、PBA、scenario manager、SI-aware    |
| iPA       | VCD/传播和 dynamic/internal/leakage 功耗基础在；活动源可信度需补 |  A/B | `power.query_instance/net`、`activity.coverage`                               | 多模式功耗、向量缺失不确定性、功耗敏感性                 |
| iIR       | PG 网络与 CG/LU/GS 求解资产在；电流源链和残差门禁需补            |  A/B | `ir.solve_region`、`ir.hotspots`、`ir.residual`                             | 增量 IR、dynamic IR、EM/reliability 联合                 |
| iDRC      | 几何检查和多类规则资产在；coverage 与 Calibre 对拍缺             |  A/B | `drc.check_scope`、`drc.explain_violation`、`drc.coverage`                  | 增量 DRC、修复候选、rule-deck compiler                   |
| iECO      | 当前主要是 via repair；完整 ECO 编排尚无                         |    B | `via.propose_repair`、`eco.transaction` 门面                                  | timing/route/functional ECO 编排                         |
| iLO/iTM   | 当前两个目录均为空 CMakeLists，不能视为已有综合                  |    C | 先以外部综合 adapter 供数据与闭环                                                 | 逻辑重写、工艺映射、物理感知综合                         |
| iLVS      | 当前仓库无`src/operation/iLVS/`                                |    C | 先接外部 LVS 结果与结构化 diff                                                    | 自研 device extraction/graph match/增量 LVS              |

### 3.4 当前资产的现实判断

iEDA 已经具备相当多的算法和数据结构，不应重写一套“AI 版 P&R”。主要结构问题是：

1. 大部分接口以整阶段、配置文件、单例和 bool 返回为中心；
2. 同一个 QoR 语义在不同工具中可能由不同评估栈计算；
3. 局部修改、增量更新、事务和回滚没有统一契约；
4. 结果主要面向日志/报告，不足以让 Agent 稳定推理；
5. 工具支持边界、跳过项、误差和数据来源没有统一声明；
6. benchmark 已有资产，但 gold、协议、版本和数据 lineage 仍需冻结。

所以第一阶段研发投入应优先放在横向底座和纵向切片，而不是同时扩充每个工具的商业功能列表。

---

## 4. 目标架构

### 4.1 总体分层

```text
┌──────────────────────────────────────────────────────────────┐
│ Agent / Planner / Multi-agent coordinator                   │
│ 目标分解 · 风险预算 · 实验选择 · 结果解释 · 终止决策          │
└───────────────────────────┬──────────────────────────────────┘
                            │ typed tool calls
┌───────────────────────────▼──────────────────────────────────┐
│ Agent Gateway                                                │
│ Tool Registry · Policy · Auth · Quota · Schema · Capability │
└───────────────────────────┬──────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────┐
│ Experiment Runtime                                          │
│ fork · txn · lock · budget · cancel · resume · portfolio    │
│ trace · cache · scheduler · conflict detection · provenance │
└──────────────┬───────────────────┬────────────────────────────┘
               │                   │
┌──────────────▼───────────┐ ┌────▼────────────────────────────┐
│ Agent-native EDA tools   │ │ Validation / Oracle            │
│ observe · propose · act  │ │ invariants · formal · signoff  │
│ estimate · analyze       │ │ commercial comparator          │
└──────────────┬───────────┘ └────┬────────────────────────────┘
               │                   │
┌──────────────▼───────────────────▼────────────────────────────┐
│ Design State Service                                        │
│ immutable snapshots · typed delta · artifact CAS · event log│
│ iDB view · scenario · PDK/tool/model/version hashes          │
└──────────────┬────────────────────────────────────────────────┘
               │ adapters
┌──────────────▼────────────────────────────────────────────────┐
│ Existing engines                                             │
│ iFP/iPL/iCTS/iTO/iRT/iSTA/iRCX/iPA/iIR/iDRC/...              │
│ evaluation · feature · vectorization · external gold tools   │
└───────────────────────────────────────────────────────────────┘
```

### 4.2 六个不可绕过的架构约束

1. **状态不可隐式变化**：所有写操作必须声明 base snapshot，并产生 delta 和新 snapshot。
2. **分析结果绑定状态**：每个指标、热图、路径和模型输出必须带 snapshot/scenario/tool/model hash。
3. **修改默认在分支**：Agent 不能直接修改主状态；只有 validation policy 通过后才 commit。
4. **约束变更与实现变更分权**：改 SDC、屏蔽违例或放宽规则不能伪装成 PPA 优化动作。
5. **硬不变量先于 reward**：连接性、功能等价、合法性、单位、必检规则和电源连通不允许用加权总分抵消。
6. **失败是正式输出**：unsupported、partial、infeasible、timeout、numerical failure、validation failure 必须可区分。

---

## 5. 设计状态、事务与多 Agent 协作

### 5.1 Design Snapshot

每个快照使用内容寻址 ID，最少包含：

```json
{
  "snapshot_id": "sha256:...",
  "parent_id": "sha256:...",
  "design": {
    "netlist": "sha256:...",
    "physical_db": "sha256:...",
    "constraints": "sha256:...",
    "activity": "sha256:..."
  },
  "context": {
    "pdk": "sky130@hash",
    "libraries": ["tt@hash"],
    "scenarios": ["func_ss_100c"],
    "units": {"time": "ps", "cap": "fF", "distance": "nm"}
  },
  "runtime": {
    "ieda_binary": "sha256:...",
    "tool_versions": {},
    "model_versions": {},
    "seed": 17
  },
  "artifacts": [],
  "invariants": []
}
```

快照不是每次都复制完整数据库。实现可采用 base snapshot + append-only typed delta + 周期性 compact checkpoint。

### 5.2 Typed Delta

优先支持以下可逆原语：

| 类别 | 原语                                                                  | 必须记录的前置/后置                |
| ---- | --------------------------------------------------------------------- | ---------------------------------- |
| 实例 | `MoveInst`、`ResizeInst`、`SwapVt`、`SetOrient`               | 原坐标/master/orient；新值；合法域 |
| 网表 | `InsertBuffer`、`DeleteBuffer`、`ReconnectPin`、`CloneDriver` | 连接图、命名、等价性影响           |
| 布线 | `AddSegment`、`DeleteSegment`、`AddVia`、`ReplaceVia`         | layer/shape/net、DRC 影响域        |
| 时钟 | `ChangeSkewTarget`、`InsertClockBuffer`                           | clock domain、setup/hold 场景      |
| PDN  | `AddStrap`、`ResizeStrap`、`AddViaArray`                        | 电源域、阻塞、面积、EM 约束        |
| 约束 | `UpdateConstraint`                                                  | 单独权限域；旧/新语义与理由        |

每个 delta 必须提供：影响对象集合、dirty region、dirty timing cone、逆操作或 checkpoint、预期不变量和验证计划。

### 5.3 事务状态机

```text
CREATED
  → APPLIED_IN_BRANCH
  → LOCAL_INVARIANTS_OK
  → INCREMENTAL_ANALYSIS_OK
  → CROSS_TOOL_VALIDATION_OK
  → COMMITTED

任一步失败：ROLLING_BACK → ROLLED_BACK
预算耗尽：PARTIAL（保留 branch + resume_token，不进入主状态）
```

### 5.4 多 Agent 冲突管理

并发不应依赖“大家改不同文件”的乐观假设。锁与冲突域至少包括：

- object lock：instance/net/pin/route segment；
- spatial lock：bin/region/layer；
- semantic lock：clock domain/power domain/scenario/constraint；
- resource lock：同一外部 license、内存上限、GPU；
- merge conflict：两个 delta 的 dirty cone 相交或对同一 metric 有非线性交互。

第一版只支持 branch-and-select，不做自动合并：多个 Agent 各自产生候选分支，由统一 validator 比较。自动 merge 放在证明局部独立之后。

---

## 6. 统一 Agent Tool Contract

### 6.1 工具注册清单

```yaml
name: timing.update_cone
version: 1.0.0
kind: analysis
mutates_design: false
inputs:
  snapshot: DesignSnapshotRef
  scope: TimingConeSelector
  scenarios: ScenarioSelector
fidelity:
  supported: [F1, F2, F3]
capabilities:
  streaming: true
  cancel: true
  resume: true
  deterministic: true
requires:
  - netlist_valid
  - constraints_loaded
produces:
  - TimingSummary
  - PathSet
  - ConfidenceReport
invalidates: []
```

### 6.2 请求结构

```json
{
  "request_id": "req-...",
  "tool": "timing.update_cone@1.0.0",
  "snapshot_id": "sha256:...",
  "expected_head": "sha256:...",
  "scope": {"dirty_nets": ["n1", "n2"], "depth": 12},
  "objective": {"metrics": ["wns", "tns", "top_paths"]},
  "constraints": {"max_new_drc": 0},
  "fidelity": "auto",
  "budget": {"wall_ms": 2000, "cpu_s": 8, "memory_mb": 4096},
  "seed": 17,
  "return": {"top_k": 50, "include_evidence": true}
}
```

### 6.3 响应结构

```json
{
  "request_id": "req-...",
  "status": "success|partial|infeasible|invalid_input|unsupported|timeout|cancelled|numerical_failure|validation_failure",
  "base_snapshot_id": "sha256:...",
  "new_snapshot_id": null,
  "result": {},
  "delta": null,
  "metrics": {"before": {}, "after": {}, "units": {}},
  "confidence": {
    "level": 0.82,
    "calibration_set": "sta-order-v3",
    "ood_score": 0.11,
    "coverage": 0.97,
    "known_bias": ["high_fanout_underestimated"]
  },
  "validation": {
    "checked": ["units", "graph_consistency"],
    "skipped": ["si"],
    "failed": []
  },
  "progress": {"fraction": 1.0, "best_bound": null},
  "resume_token": null,
  "artifacts": [],
  "diagnostics": [],
  "provenance": {}
}
```

### 6.4 部分完成是一等公民

长任务被取消或超时时，工具应尽量返回：

- 当前最好可行解 incumbent；
- 尚未处理的 scope；
- 下界/上界或已知 gap；
- 已检查与跳过的规则/场景；
- 中断时内部 checkpoint；
- 继续执行所需 `resume_token`；
- 替代工具建议，例如“全芯片详细布线超时，可对 17 个冲突区做局部布线”。

`partial` 绝不能自动 commit。Agent 可以基于它继续规划、缩小问题或升级引擎。

### 6.5 结构化错误

错误至少分为：

| 错误类     | 示例                       | Agent 可采取的动作             |
| ---------- | -------------------------- | ------------------------------ |
| 输入不完整 | 缺 SDC/活动度/RC tech      | 补输入或降级到明确的估算模式   |
| 不支持     | 当前模型不支持 multi-clock | 切换工具/分解场景              |
| 不可行     | 局部合法化无空位           | 扩大区域、换动作、回滚         |
| 数值失败   | IR solver 不收敛           | 调预条件、换求解器、缩小 scope |
| 资源耗尽   | 超时/内存不足              | resume、分片、降 fidelity      |
| 验证失败   | 新增 DRC/功能不等价        | 回滚并记录反例                 |
| 状态冲突   | base snapshot 已过期       | rebase 或放弃候选              |

---

## 7. 多精度、anytime 与风险驱动调度

### 7.1 精度档不是简单的“50%/70%/90%”

建议将档位定义为执行与证据等级：

| 档位 | 典型实现                                    | 使用场景             | 必须输出                          |
| ---- | ------------------------------------------- | -------------------- | --------------------------------- |
| F0   | 缓存、规则、几何/图特征、解析近似           | 大规模候选粗筛       | 适用域、保守界或明确无界          |
| F1   | 已校准 surrogate/learned ranker             | 候选排序、敏感性扫描 | model hash、OOD、校准误差、训练域 |
| F2   | 快速物理模型/局部求解                       | 过程优化、分支淘汰   | 覆盖率、跳过机制、P95 误差        |
| F3   | iEDA 完整物理引擎                           | 提交前开源工具验证   | 全场景结果、不变量、可复现证据    |
| F4   | 商业 signoff/独立 field solver/SPICE/formal | 高风险和最终门禁     | 独立输入来源、版本、完整报告      |

同一 API 的不同档位必须保持语义一致。例如 `timing.top_paths` 各档都返回同一 schema，不能 F1 排 net、F3 排 path 却共用一个“accuracy”。

算法类型不能预先绑定精度顺序。查找表可能在已表征区间内比神经网络更准，局部物理近似也可能在 OOD 设计上优于训练模型。每个实现进入某个 fidelity 档位，必须依据同协议实测的误差、覆盖、计算成本和证据强度，而不是依据“函数拟合 < NN < 物理仿真”的名称排序。

### 7.2 自动升级策略

```text
候选数量大、风险低
  → F0/F1 批量筛选
  → 对 Pareto 前沿与模型分歧点调用 F2
  → 对拟提交动作调用 F3
  → 对不可逆里程碑、OOD 或 F3/F2 冲突调用 F4
```

触发升级的条件：

- OOD score 超阈值；
- 置信区间跨越门禁；
- 多模型分歧大；
- 动作影响 clock/reset/power/高扇出或大区域；
- 接近 setup/hold/IR/DRC 极限；
- 修改约束或宏观拓扑；
- 低档结果与守恒/单调性不一致；
- 进入 tapeout/signoff gate。

### 7.3 Anytime 工具的具体要求

布局、布线、宏规划、PDN 和组合优化工具应逐步支持：

- `time_limit`、`iteration_limit`、`quality_target` 三种停止条件；
- 随时给出 best feasible incumbent；
- 每个 epoch 输出独立可解析的 progress event；
- cancel latency 有上限，目标 p95 < 2 s；
- checkpoint 后 resume 的结果与不中断运行在容差内一致；
- 返回“为什么没有继续改善”，而不仅是“达到最大迭代数”；
- 保留多样化候选，而不是只返回一个局部最优点。

### 7.4 失败后的标准恢复阶梯

Agent 不应在每次失败后自由发挥一套不可审计的补救流程。运行时提供统一恢复阶梯，并记录实际走过的分支：

```text
1. 继续：已有 incumbent/checkpoint 时，用 resume_token 延长有限预算
2. 缩域：把全芯片问题缩成 region/net/path/scenario 子问题
3. 调档：低精度不确定则升档；高精度太慢则先用低档筛选
4. 换核：在同一工具契约下切换算法/solver/preconditioner
5. 改写问题：放宽搜索范围，但不得放宽设计硬约束
6. 生成辅助工具：只读 analyzer、adapter、局部 solver 或 workflow
7. 调独立 oracle：商业工具、formal、SPICE、field solver 或人工审批
8. 宣告残余：返回 unfixable/unsupported 证据，保留最佳可行分支
```

每一级有独立预算。只有失败类型与工具 manifest 允许时才能进入下一级。例如“DRC rule 不支持”不能靠增加同一求解器迭代解决，“合法化不可行”也不能通过自动放宽 floorplan 边界掩盖。

---

## 8. 面向 Agent 的原子工具目录

### 8.1 观察与理解工具（优先级最高）

| 工具                        | 输入              | 输出                                            | 可复用资产           | 优先级 |
| --------------------------- | ----------------- | ----------------------------------------------- | -------------------- | -----: |
| `design.summarize`        | snapshot/scenario | 规模、阶段、完整性、异常、可用工具              | iDB/report           |     P0 |
| `state.diff`              | 两个 snapshot     | typed delta、指标变化、影响域                   | iDB/file manager     |     P0 |
| `design.validate`         | snapshot          | 拓扑/几何/命名/单位/约束完整性                  | iDB/checker          |     P0 |
| `timing.top_paths`        | scenario/K        | 路径、slack、cell/net 分量、coverage            | iSTA                 |     P0 |
| `timing.path_explain`     | path              | delay attribution、dominant arcs、RC/logic 比例 | iSTA/iRCX            |     P0 |
| `timing.constraint_audit` | SDC/design        | unconstrained、矛盾、异常例外、覆盖率           | iSTA SDC             |     P0 |
| `congestion.hotspots`     | region/layer      | hotspot cluster、阻塞来源、相关 nets            | evaluation/iRT       |     P0 |
| `drc.explain`             | violation         | rule、几何证据、相关 objects、修复空间          | iDRC                 |     P0 |
| `power.activity_coverage` | activity/design   | 实测/传播/默认活动比例与层级缺口                | iPA                  |     P0 |
| `ir.hotspots`             | scenario          | drop、residual、供电路径、敏感负载              | iIR                  |     P1 |
| `rc.net_breakdown`        | net               | wire/via/ground/coupling 分量和模型命中         | iRCX                 |     P1 |
| `clock.tree_explain`      | clock/sink        | latency/skew/load/buffer attribution            | iCTS/iSTA            |     P1 |
| `metric.root_cause`       | metric regression | 跨 stage 因果候选与证据                         | 新建 + 全流程 ledger |     P1 |

### 8.2 试探与敏感性工具

这些工具只回答“如果改一点，会发生什么”，不直接提交设计：

| 工具                            | 作用                                                           |
| ------------------------------- | -------------------------------------------------------------- |
| `sensitivity.cell_size`       | 扫描关键 cell 的 size/VT 候选，预测 setup/hold/power/area 变化 |
| `sensitivity.buffer_location` | 沿 net 候选点扫描 buffer 类型和位置                            |
| `sensitivity.cell_move`       | 对关键实例做有限差分，估计 wire/timing/congestion 梯度         |
| `sensitivity.route_layer`     | 改层/加宽/屏蔽的 RC、SI、DRC 影响                              |
| `sensitivity.pdn_strap`       | strap 宽度/间距/位置对 IR/EM/拥塞影响                          |
| `scenario.reduce`             | 找真正支配当前决策的场景，不删除最终签核场景                   |
| `counterfactual.evaluate`     | 在不 commit 的分支上评估一个或一组 delta                       |
| `candidate.diversify`         | 从同一问题生成拓扑不同的候选，减少模型同源错误                 |

### 8.3 修改工具

第一批动作必须小、可逆、易验证：

| 动作工具                 | 硬前置                           | 提交前验证                          |
| ------------------------ | -------------------------------- | ----------------------------------- |
| `eco.resize_cell`      | legal master、dont_touch、domain | 等价、legal、setup/hold、power、DRV |
| `eco.swap_vt`          | 库族映射、功耗域                 | setup/hold、leakage、合法性         |
| `eco.insert_buffer`    | net 可切分、合法 cell            | connectivity、legal、route、STA     |
| `eco.clone_driver`     | fanout/功能允许                  | connectivity、负载、STA、area       |
| `place.move_local`     | movable、region/halo             | legal、congestion、STA              |
| `route.reroute_nets`   | 冻结非 scope 网络                | DRC、RC、STA、未触碰集合            |
| `route.add_shield`     | shield/PG 资源可用               | DRC、RC/SI、拥塞、PG connectivity   |
| `clock.adjust_local`   | clock domain 和 skew budget      | setup+hold、多场景、clock DRC       |
| `pdn.reinforce_region` | 电源域/层资源                    | IR、EM、signal congestion、DRC      |
| `floorplan.move_macro` | halo/channel/fixed constraints   | macro legal、pin access、拥塞、PPA  |

### 8.4 验证与证明工具

| 工具                              | 目标                                      |
| --------------------------------- | ----------------------------------------- |
| `verify.connectivity`           | 断路、短路、悬空、PG 连接                 |
| `verify.functional_equivalence` | 网表修改前后 LEC/形式等价                 |
| `verify.legality`               | placement/row/orientation/site/halo       |
| `verify.incremental_drc`        | delta 影响区的完整规则子集与 skipped 列表 |
| `verify.incremental_sta`        | dirty cone + 所有相关场景                 |
| `verify.power_ir`               | 功耗来源覆盖与 IR residual/peak           |
| `verify.frozen_objects`         | 保证 scope 外对象逐项未变                 |
| `verify.artifact_roundtrip`     | DEF/GDS/SPEF/网表读写保真                 |
| `verify.signoff_bundle`         | F4 工具运行及证据包完整性                 |

---

## 9. 未来潜在工具版图

### 9.1 不是传统商业命令翻版的 Agent 专用工具

| 潜在工具                       | 价值                                                           | 依赖                          |
| ------------------------------ | -------------------------------------------------------------- | ----------------------------- |
| Design State Linter            | 在运行昂贵工具前发现输入、单位、场景和状态错误                 | iDB/SDC/PDK schema            |
| Intent Extractor               | 从 RTL/SDC/UPF/历史 flow 提取 clock、power、性能与不可触碰意图 | RTL/constraint parser         |
| Constraint Completeness Prover | 找 unconstrained path、过宽 exception、冲突时钟和伪优化空间    | iSTA + formal                 |
| Decision Regret Estimator      | 估计使用低精度模型选错候选的真实损失                           | 多 fidelity 配对数据          |
| OOD/Risk Router                | 决定调用哪一级引擎或是否拒答                                   | model registry/calibration    |
| Causal QoR Attributor          | 将 WNS/功耗/拥塞退化归因到 stage、动作和物理分量               | event ledger + counterfactual |
| Design Trajectory Search       | 在历史设计轨迹中检索相似状态和成功动作                         | snapshot/delta 数据湖         |
| Failure Memory                 | 结构化记录失败动作、适用条件和替代策略                         | diagnostics schema            |
| Pareto Portfolio Manager       | 维护多分支 PPA 前沿，按价值/计算成本分配预算                   | experiment runtime            |
| Local Exact Solver Builder     | 为一个小 region/cone 自动建 CP-SAT/MIP/graph problem           | solver templates              |
| Metamorphic Test Generator     | 自动生成平移、重命名、镜像、单位缩放等不变量测试               | tool contract                 |
| Rule-deck Compiler             | PDK rule → iDRC 可执行检查 + coverage map + test pattern      | iDRC/PDK grammar              |
| PDK Adapter Generator          | 从 LEF/Lib/ITF/tech rule 生成映射、单位校验和 smoke tests      | parser/tool generator         |
| Report/Log Semantic Parser     | 将商用工具报告变成统一 schema 和训练样本                       | external adapters             |
| Evidence Pack Builder          | 自动汇总每次提交的输入、delta、门禁与反例                      | CAS/event ledger              |

### 9.2 求解与分析工具的扩展

**近期（6-12 个月）**：

- 局部 detailed placement exact solver；
- dirty-net 增量 RCX；
- path-local PBA；
- timing-aware local router；
- incremental DRC + repair proposals；
- 活动度缺失估计与不确定性；
- static IR 局部加固；
- macro/floorplan candidate generator；
- multi-Vt 与 gate sizing portfolio；
- scenario dominance/reduction 分析。

**中期（12-24 个月）**：

- physical-aware logic rewrite/mapping；
- formal ECO 与功能等价修复；
- dynamic IR、EM、self-heating、aging 联合分析；
- SI-aware route/timing closure；
- useful-skew 与多场景 CTS；
- hierarchical block/top co-optimization；
- congestion/timing/power joint floorplanning；
- memory/compiler/IP characterization adapter；
- DFM/yield hotspot prediction 和冗余 via optimization；
- thermal-aware placement/PDN/routing。

**远期（24 个月以后，需独立立项）**：

- chiplet/2.5D/3D IC 分区、bump/TSV、热-应力-时序联合；
- package-board-die 协同；
- analog/mixed-signal 布局约束生成与局部验证；
- 标准单元自动生成、表征与库质量审计；
- 工艺-设计协同优化 DTCO；
- 从 spec/RTL 到物理实现的跨层反向优化；
- 面向新器件/新互连的自动工具构造。

这些远期方向不能与近期基础设施同时铺开。它们需要在 snapshot/delta/validator 已稳定后，作为新 tool package 接入。

---

## 10. 五个典型 Agent 闭环

### 10.1 闭环 A：post-placement 时序 ECO（首个产品切片）

```text
snapshot(post_place)
  → constraint/activity/design audit
  → F2 timing.top_paths
  → path.explain + root-cause cluster
  → generate {resize, VT-swap, buffer, local-move} candidates
  → F0/F1 rank 100 candidates
  → fork Top-20
  → local legalize + fast RC + incr STA
  → F2 保留 Pareto Top-5
  → F3 full STA + congestion + power + legality
  → commit best or retain multiple Pareto branches
```

硬约束：不改 SDC；不动 dont_touch；不新增 DRC/DRV；所有场景 hold 不退化超过预算；作用域外对象不变。

### 10.2 闭环 B：route/DRC 局部收敛

```text
iDRC violation clusters
  → explain geometry/rule
  → classify {spacing, enclosure, via, short, antenna, density}
  → generate multiple local repair topologies
  → freeze unaffected nets
  → local route + incremental DRC
  → RC delta + STA risk check
  → commit/rollback
```

Agent 的优势不是凭语言猜线路，而是能够针对每个冲突区选择不同算法，并在失败后扩大 region、换层或放弃局部最优。

### 10.3 闭环 C：PDN/IR 与信号拥塞协同

```text
activity coverage audit
  → power map + IR solve + residual gate
  → hotspot attribution
  → candidate {strap, width, via array, local decap, load spread}
  → evaluate IR/EM improvement
  → evaluate signal congestion/DRC/area cost
  → Pareto selection
```

不能在活动源未知时输出无条件“精确 IR”。结果必须区分 VCD 驱动、传播、默认和未知比例。

### 10.4 闭环 D：多候选 floorplan 搜索

```text
RTL/netlist + macro/pin/power intent
  → generate diverse macro topologies
  → F0 routability/timing/power proxy
  → F2 global place/global route/early IR
  → preserve Pareto candidates
  → F3 detailed evaluation on Top-N
```

这里 Agent 负责规划试验和利用失败信息；iFP/iPL/iRT/iPNP 提供确定性物理能力。

### 10.5 闭环 E：约束调试而非“约束优化”

```text
constraint audit
  → detect unconstrained/over-constrained/conflicting paths
  → produce evidence and proposed constraint patch
  → independent review/formal check
  → explicit intent-change approval
  → rerun baseline
```

约束修改必须进入独立审计流，禁止 Agent 为改善 WNS 自动增加 false path 或放宽 clock。

---

## 11. Agent-native Timing Closure Lab 详细定义

### 11.1 MVP 输入与边界

输入：

- 已合法 post-placement 或 post-CTS DEF；
- gate-level netlist；
- LEF/Liberty/SDC；
- 可选 SPEF/RC tech；
- 可选活动度；
- 明确的 setup/hold/area/congestion/功耗预算。

MVP 暂不负责：

- RTL 功能修复；
- 自动改 SDC；
- 全芯片 detailed route；
- signoff 替代；
- 大规模 macro movement；
- 多 Agent 自动合并。

### 11.2 MVP 工具集合

```text
Read-only:
  design.summarize
  design.validate
  timing.top_paths
  timing.path_explain
  congestion.hotspots
  state.diff

Propose:
  eco.propose_resize
  eco.propose_vt_swap
  eco.propose_buffer
  place.propose_local_move

Act in branch:
  eco.resize_cell
  eco.swap_vt
  eco.insert_buffer
  place.move_local

Verify:
  verify.connectivity
  verify.legality
  rc.extract_scope
  timing.update_cone
  verify.congestion
  verify.frozen_objects
```

### 11.3 MVP 成功定义

先建立 M0 baseline，再冻结数值目标。建议首轮退出门槛：

| 维度       | 90 天门槛                                                                              |
| ---------- | -------------------------------------------------------------------------------------- |
| 事务正确性 | 500 次动作中主快照无一次未授权改变；rollback 后 hash/指标在容差内恢复                  |
| 重放       | 相同 snapshot/tool/version/seed 的结果 100% 可重放，浮点项按字段容差                   |
| 失败诚实   | 所有注入失败均返回非 success，且带失败域和未修改证明                                   |
| 增量一致性 | dirty-cone STA 与全量 STA 对相关端点差异 ≤1 ps，未达则禁用增量提交                    |
| 冻结域     | scope 外实例/网络/布线变化数为 0                                                       |
| 闭环收益   | 至少 10 个 held-out 违例 case 中，≥8 个在硬约束不退化下减少 setup violation magnitude |
| 计算收益   | 相对“每个候选全量跑 F3”，候选选择总 CPU wall 降低 ≥5×                              |
| 泛化       | 至少覆盖 2 个 PDK、3 个设计族；按设计族隔离训练/测试                                   |

“setup violation magnitude 减少”必须同时报告 WNS、TNS、违例端点数，禁止只挑一个改善指标。

---

## 12. 数据与知识飞轮

### 12.1 每次调用都应生成训练记录

```text
(snapshot_before, problem_context, tool_request)
  → candidates
  → low_fidelity_predictions
  → selected_actions
  → snapshot_after_branch
  → high_fidelity_observations
  → accepted/rejected/rolled_back
  → failure_reason + applicability
```

最有价值的数据往往不是最终 clean design，而是：

- 哪个候选被低精度模型排第一但实际失败；
- 失败发生在 legal、route、hold 还是 DRC；
- 哪些设计特征导致模型 OOD；
- 哪个局部动作在相似状态中重复有效；
- 多个动作组合时出现了什么非线性交互；
- Agent 为什么停止或升级 fidelity。

### 12.2 数据切分纪律

- 按 design family 切分，禁止同一 RTL 的不同参数/PDK 变体跨训练与测试泄漏；
- 另设 held-out PDK；
- 另设异常/对抗 case：高扇出、重收敛、窄通道、宏密集、clock/reset、低活动覆盖；
- 训练数据、校准数据、门禁数据三分；
- 商业工具输出必须记录版本、设置、report point、license 环境和失败 case；
- 不把商业工具“跑出来一个数字”当真值，先冻结同输入/同单位/同场景协议。

### 12.3 Oracle 层级

| 问题               | 首选 oracle                       | 备选             |
| ------------------ | --------------------------------- | ---------------- |
| 功能等价           | formal/LEC                        | 仿真回归         |
| cell delay         | SPICE/Liberty characterization    | PT 分解报告      |
| RC pattern         | field solver                      | StarRC 分桶      |
| 过程 STA           | F3 iSTA + Innovus 对拍            | PT 签核          |
| DRC                | Calibre rule subset               | 人工构造几何真值 |
| IR                 | RedHawk/Voltus + circuit residual | 解析小网格解     |
| PPA action outcome | F3/F4 branch rerun                | 历史相似动作     |

### 12.4 主动学习

优先把昂贵 F4 预算花在：

- F1/F2 分歧最大的候选；
- OOD 最高但业务价值大的状态；
- Pareto 边界附近；
- 模型置信度高但被 F3 推翻的反例；
- 新 PDK、新 library family、新拓扑；
- 会改变 Agent 决策的样本，而不是对决策无影响的重复样本。

---

## 13. 评价体系

### 13.1 四层指标

**L0 工具正确性**：schema、单位、失败语义、确定性、边界、round-trip、不变量。

**L1 模型/分析质量**：MAE/P95、Recall@K、Kendall tau、selection regret、calibration、OOD。

**L2 动作质量**：动作成功率、回滚率、硬约束违例率、局部/全量一致性、扰动规模。

**L3 闭环质量**：time-to-first-feasible、PPA Pareto 超体积、计算成本、跨 PDK/设计泛化、最终 F4 通过率。

### 13.2 PPA 不是一个加权分数

统一报告向量：

```text
Timing: WNS, TNS, violating endpoints, setup/hold separated
Power : dynamic, internal, leakage, activity coverage
Area  : core/die/cell/buffer area
Route : WL, vias, overflow, layer usage
DRC   : count by rule, skipped rules, severity
PI    : peak/percentile IR, EM violations, solver residual
Cost  : wall, CPU, memory, GPU, external-license minutes
Risk  : confidence, OOD, unverified mechanisms
```

选择由外部 design objective/constraint 决定，evaluation 不自行把它们加成一个分数。默认保留 Pareto 前沿。

### 13.3 新增“决策效用”指标

| 指标                    | 定义                                     |
| ----------------------- | ---------------------------------------- |
| Selection regret        | oracle 最优候选收益 - Agent 所选候选收益 |
| Improvement per compute | 有效 PPA 改善 / CPU/GPU/license 成本     |
| Validation efficiency   | 通过 F3/F4 的候选数 / 被升级候选数       |
| Recovery efficiency     | 从一次失败到下一个可行候选的调用数/时间  |
| Tool substitution rate  | 外部商业调用可被 F0-F3 安全避免的比例    |
| Evidence completeness   | 提交所需证据字段完整率                   |

---

## 14. 工具生成底座（Honey）的具体形态

### 14.1 工具生成不等于生成任意 C++

优先生成四类低风险产物：

1. adapter：把现有命令/报告映射到统一 schema；
2. analyzer：只读设计状态，生成诊断或特征；
3. local solver：在显式 scope 与约束内求解；
4. workflow：组合已注册工具，不创建新的物理真值。

直接生成可写全芯片数据库的高权限工具应后置。

### 14.2 Tool Package

```text
tool-package/
  manifest.yaml
  schemas/{request,response}.json
  src/
  tests/
    unit/
    golden/
    metamorphic/
    adversarial/
  calibration/
    domain.json
    error_buckets.json
  security/
    permissions.yaml
  README.md
```

### 14.3 生成工具门禁

| 门禁               | 要求                                         |
| ------------------ | -------------------------------------------- |
| 编译/静态检查      | 只是入场，不代表工具有效                     |
| Golden tests       | 已知小例与独立真值一致                       |
| Mutation tests     | 修改关键计算逻辑后测试必须失败，防“空测试” |
| Metamorphic tests  | 平移、重命名、镜像、单位缩放等不变量成立     |
| Differential tests | 与已有工具/商业工具在冻结协议下比较          |
| Failure injection  | 缺文件、超时、空设计、非法单位必须响亮失败   |
| Permission         | 只允许声明的读写 scope                       |
| Resource           | 时间/内存/线程上限可执行                     |
| Provenance         | prompt、模板、依赖、模型、代码 hash 可追溯   |

“虚假工具拒绝率 100%”只能在明确的负样本集合上表达。更合理的持续指标是 mutation score、反例发现率和 escaped defect 数。

---

## 15. 商业工具与自研工具的组合策略

### 15.1 三种部署模式

| 模式    | 自研工具                                       | 商业工具          | 适合客户                 |
| ------- | ---------------------------------------------- | ----------------- | ------------------------ |
| Open    | F0-F3 全自研，客户自己做 signoff               | 可选              | 学术、开源、成本敏感客户 |
| Hybrid  | 高频过程调用自研，关键门禁调用客户已有 license | oracle/signoff    | 已有 EDA 基础的 Fabless  |
| Managed | iEDA.ai 调度自研与受控商业后端                 | gold/signoff 服务 | 缺少完整工具链的团队     |

### 15.2 商业模式建议

单纯按“token”计价不适合 EDA：一条路径的 F1 排序和一次全芯片 F4 signoff 成本相差巨大。建议计价单位透明映射为：

- tool invocation + fidelity；
- 设计规模桶；
- CPU/GPU wall；
- 外部 license minute；
- 状态存储/数据保留；
- SLA 与验证等级；
- 成功闭环套餐可作为上层产品，但不承诺不可控 PPA 结果。

对 Agent 可继续暴露统一“compute credit”，内部再映射真实资源成本。

---

## 16. 路线图

### 16.1 Phase 0：契约与基线（第 0-4 周）

交付：

- DesignSnapshot/TypedDelta/ToolManifest/ToolResponse schema v0.1；
- tool registry 和本地 gateway；
- 统一 status/error/units/provenance；
- `design.summarize`、`design.validate`、`state.diff`；
- iSTA/evaluation 只读 adapter；
- 10 个小设计的冻结 baseline；
- 失败注入与重放测试。

退出门禁：

- 同一快照读取结果可复现；
- 输入缺失/单位错/unsupported 不再返回 success；
- 所有结果绑定 snapshot/tool/version；
- 不要求此阶段提升 PPA。

### 16.2 Phase 1：事务化 Timing Closure Lab（第 5-12 周）

交付：

- branch/commit/rollback；
- resize/VT-swap/insert-buffer/local-move 四类 typed delta；
- local legalize、dirty RC、dirty-cone STA adapter；
- frozen-object verifier；
- candidate portfolio 与 F1/F2/F3 升级；
- 端到端 Agent loop 与 evidence pack。

退出门禁采用 §11.3。

### 16.3 Phase 2：扩展到 route/DRC（第 4-8 个月）

交付：

- spatial scope 与 region lock；
- local reroute/rip-up；
- incremental DRC + rule coverage；
- DRC repair proposals；
- route delta → RC → STA 闭环；
- anytime/cancel/resume 在 iRT 的首个实现。

退出门禁：在 held-out DRC case 上提高 clean 收敛率，同时冻结网变化为 0，不能以新增 timing 违例换 clean。

### 16.4 Phase 3：功耗/PDN 与多场景（第 7-12 个月）

交付：

- activity provenance/coverage；
- power/IR 结构化工具；
- PDN local action；
- multi-scenario timing/power policy；
- scenario reduction 只用于决策，不删除最终门禁；
- timing/power/IR/congestion Pareto portfolio。

### 16.5 Phase 4：跨层与工具生成（第 12-18 个月）

交付：

- physical-aware synthesis adapter；
- logic/technology mapping 的可控引擎方案；
- functional ECO + equivalence；
- analyzer/local solver/workflow generator；
- PDK adapter/rule-deck compiler 原型；
- 多 Agent branch-and-select。

### 16.6 Phase 5：规模化与新领域（第 18-24 个月）

交付：

- 百万实例的状态/增量/并发能力；
- hierarchical block/top；
- SI/EM/thermal/reliability 扩展；
- 2.5D/3D 原型；
- 服务化计量、隔离、审计、客户 PDK 私有部署。

---

## 17. 第一个 90 天 backlog

### 17.1 工作流 A：状态与运行时

| 周      | 任务                                             | 验收                               |
| ------- | ------------------------------------------------ | ---------------------------------- |
| W1-W2   | 冻结四个 schema；content hash；artifact manifest | schema test + 版本兼容策略         |
| W2-W3   | snapshot create/load/diff                        | 同状态 hash 一致；差异逐对象       |
| W3-W5   | branch/txn/rollback                              | failure injection 后主状态不变     |
| W5-W7   | event/progress/cancel/resume 协议                | mock long tool 可中断续跑          |
| W7-W10  | experiment portfolio/cache                       | 相同调用命中缓存；不同版本不误命中 |
| W10-W13 | evidence pack/replay                             | 一条闭环可离线完整重放             |

### 17.2 工作流 B：时序与 ECO adapter

| 周      | 任务                                    | 验收                                |
| ------- | --------------------------------------- | ----------------------------------- |
| W1-W3   | iSTA top-path/path-breakdown 结构化输出 | unit/scenario/path ID 完整          |
| W3-W5   | resize/VT-swap/insert-buffer delta      | inverse/dirty cone 正确             |
| W4-W7   | iPL local legalization wrapper          | 不可行时不留半修改                  |
| W5-W8   | dirty RC + incr STA                     | 与全量相关端点 ≤1 ps，否则禁提交   |
| W7-W10  | 候选生成与 ranking baseline             | 报 Recall@K/regret，不只报 accuracy |
| W10-W13 | end-to-end timing loop                  | 满足 §11.3                         |

### 17.3 工作流 C：数据与评测

| 周     | 任务                      | 验收                            |
| ------ | ------------------------- | ------------------------------- |
| W1-W2  | 冻结 benchmark protocol   | 输入/版本/场景/单位完整         |
| W2-W5  | 构建正常+异常 timing case | 至少覆盖高扇出/重收敛/拥塞/hold |
| W4-W8  | 商业/自研中间分量采集     | cell/net/RC/path 可对齐         |
| W6-W10 | 校准与 OOD baseline       | design-family split，无泄漏     |
| W8-W13 | 闭环看板                  | L0-L3 独立指标与失败样本        |

### 17.4 研发资源建议

最小并行工作流：

- 状态/运行时 2-3 人；
- iSTA/iTO/iPL/iRCX adapter 与增量闭环 3-4 人；
- benchmark/oracle/数据 2 人；
- Agent planner/model/评测 2 人；
- 每个关键工具需要原作者或领域 owner 参与 review。

若资源不足，优先顺序是：状态事务 > 结构化观察 > 增量验证 > 动作候选 > learned model > tool generation。

---

## 18. 工程治理与安全

### 18.1 权限级别

| 级别 | 能力                                        |
| ---- | ------------------------------------------- |
| R0   | 只读元数据/报告                             |
| R1   | 运行分析器，不修改设计                      |
| R2   | 在临时 branch 做局部修改                    |
| R3   | 通过 policy 后 commit 到开发主线            |
| R4   | 修改约束/PDK/rule deck，需要显式审批        |
| R5   | signoff/tapeout artifact 发布，需要双重门禁 |

### 18.2 安全与隔离

- 客户 PDK、网表、活动度和商用报告分租户存储；
- 生成代码在无网络、限资源、只读 base snapshot 的 sandbox 中运行；
- 禁止工具自行访问未声明文件；
- 所有外部命令、license 调用和产物 hash 进入 audit log；
- 训练数据默认不跨客户；
- prompt/log 中的设计对象名也视为敏感数据；
- cache key 必须包含客户域，禁止跨租户命中。

### 18.3 变更治理

- schema 使用语义版本；
- tool manifest 声明 deprecation；
- model 变更必须重新校准，不只跑 unit test；
- PDK adapter 变更触发对应 PDK 全量门禁；
- Agent policy 与物理引擎版本解耦，可单独回滚；
- 每次 commit 保存 decision record：候选、拒绝原因、证据与批准策略。

---

## 19. 风险与对策

| 风险                  | 早期信号                            | 对策                                                 |
| --------------------- | ----------------------------------- | ---------------------------------------------------- |
| 只做了 Tcl 包装       | Agent 仍需解析日志、无法局部修改    | 以 Tool Contract/Typed Delta 验收，不以 API 数量验收 |
| 状态系统过重          | 所有时间花在序列化，无闭环          | base+delta；先支持 timing ECO 的最小对象集           |
| 增量结果不可信        | 与全量偏差不稳定                    | 双跑门禁；不达标时保留全量提交验证                   |
| 模型在新设计失效      | OOD 高、ranking 高信低错            | held-out family/PDK；coverage-risk；自动升级 F2/F3   |
| Agent 通过改约束作弊  | WNS 突然改善但 intent 变化          | constraint 独立权限和 diff gate                      |
| 多目标被单分数掩盖    | timing 好但 DRC/IR 恶化             | 硬门禁 + Pareto，不用隐含加权总分                    |
| 生成工具只有框架      | compile pass 但 mutation 不敏感     | mutation/metamorphic/differential tests              |
| 商业数据不可复现      | 版本/设置不全                       | oracle protocol + artifact hash + report point       |
| 并发修改相互污染      | 两 Agent 各自好，合并后坏           | 先 branch-and-select，后证明独立再 merge             |
| 过早追求全流程        | 每个模块都有 demo，没有一个闭环可靠 | 90 天只做 Timing Closure Lab                         |
| 低精度被滥用到签核    | F1 输出直接进入 tapeout             | fidelity policy；不可逆 gate 强制 F4                 |
| 业务按 token 难以核算 | 同 token 成本差异巨大               | compute credit 映射真实资源与验证等级                |

---

## 20. 明确不做

近期不做以下事情：

1. 不为 Agent 重做一套 GUI；
2. 不把所有 Tcl 命令机械包装后宣称 Agent-native；
3. 不同时重写 placement/router/STA/综合；
4. 不用一个 PPA 总分替代各项硬门禁；
5. 不把代理模型输出直接当 signoff；
6. 不让 Agent 默认修改 SDC、UPF 或 rule deck；
7. 不在没有事务/回滚前开放写数据库工具；
8. 不用同一 RTL 的 PDK/参数变体同时进入训练和测试；
9. 不以“代码生成成功/编译成功”作为工具生成成功；
10. 不承诺短期替代 PrimeTime/StarRC/Calibre 的最终签核；
11. 不在首版实现多 Agent 自动 merge；
12. 不因 Agent 可以写脚本而放弃正式 API、schema 和验证。

---

## 21. 决策与待决事项

### 21.1 建议立即拍板

| 决策         | 建议                                                          |
| ------------ | ------------------------------------------------------------- |
| 首个垂直切片 | Timing Closure Lab                                            |
| 状态模型     | immutable snapshot + typed delta + transaction                |
| 主入口       | versioned structured API；Tcl 仅作兼容 adapter                |
| 低精度目标   | decision regret/Recall@K/calibration，不用单一 order accuracy |
| 多模型定位   | 不确定性估计，不作签核真值                                    |
| PPA 选择     | 硬门禁 + Pareto                                               |
| 商业工具角色 | oracle/signoff/反例，不进入每一步强依赖                       |
| 工具生成顺序 | adapter → analyzer → local solver → workflow → 高权限工具 |

### 21.2 需要通过 M0 数据再决策

- 第一批支持的两个 PDK；
- snapshot 底层使用自研二进制、现有 file manager 还是混合格式；
- dirty-cone STA 是否已足够可信，或需要先重构三套时序栈；
- iRCX 局部提取先做真实增量还是先做 calibrated estimate；
- Agent planner 使用单 Agent portfolio 还是 planner/critic 两角色；
- 外部 commercial oracle 的调用配额与数据可留存边界；
- 首批客户部署采用进程内、worker pool 还是容器隔离。

---

## 22. 与现有文档的关系

| 文档                                              | 本方案如何使用                                                        |
| ------------------------------------------------- | --------------------------------------------------------------------- |
| `00-ieda-commercial-parity-master-plan-v1.1.md` | 提供商业 PPA/功能对标的长期上界与工具级缺口                           |
| `01-ai-doc-conventions-rv1.md`                  | 继承“断言带证据、未验证不写事实、假说可被实验推翻”的纪律            |
| `10`-`42` 各工具方案                          | 作为现有工具成熟度和具体 kernel 改造依据                              |
| `50-agent-era-eda-master-plan-v1.0.md`          | 提供 Agent 时代战略定位；本方案负责工程化和校正指标                   |
| 2026-07-22 研讨会纪要                             | 提供“Agent 掌握全流程、工具可部分完成、过程 STA 先行”的原始决策背景 |

本方案不要求暂停商业对标轨。两条轨道共享 iDB、增量引擎、评测、benchmark 和高精度验证；差异在产品形态：商业对标轨建设 F3/F4 可信上界，Agent 原生轨建设 F0-F3 的状态化调用与闭环效率。

---

## 附录 A：首批 API 命名建议

```text
state.create_snapshot       state.diff                 state.replay
state.fork                  state.commit               state.rollback
design.summarize            design.validate            design.query_objects
timing.top_paths            timing.path_explain        timing.update_cone
timing.constraint_audit     timing.compare             timing.sensitivity
place.query_region          place.move_local           place.legalize_local
route.query_congestion      route.reroute_nets         route.check_scope
rc.estimate_net             rc.extract_scope           rc.compare
drc.check_scope             drc.explain                drc.propose_repair
power.activity_coverage     power.query                power.compare
ir.solve_region             ir.hotspots                pdn.propose_reinforcement
eco.propose                 eco.apply_delta            eco.validate
verify.connectivity         verify.legality            verify.frozen_objects
experiment.create           experiment.run_portfolio   experiment.select_pareto
```

## 附录 B：术语

| 术语              | 定义                                                          |
| ----------------- | ------------------------------------------------------------- |
| Snapshot          | 由内容 hash 标识、可重放的完整设计状态视图                    |
| Typed Delta       | 具有明确语义、作用域、逆操作和验证要求的设计变化              |
| Incumbent         | 求解过程中当前最好的可行解                                    |
| Selection regret  | Agent 选择相对 oracle 最优候选损失的收益                      |
| Coverage-risk     | 模型只在部分样本上给结论时，覆盖率与错误风险的关系            |
| Fidelity          | 执行成本与证据强度等级 F0-F4                                  |
| Evidence pack     | 支撑一次提交的输入、版本、delta、指标、门禁和产物集合         |
| Branch-and-select | 多个 Agent/算法在隔离分支产生候选，验证后选一个，不直接合并   |
| Honey             | 可生成、组合、验证和积累 EDA 工具经验的底座，而非静态工具列表 |

## 附录 C：版本历史

- v1.0（2026-07-23）：基于 `50` 号总纲、2026-07-22 研讨会纪要、现有工具方案和仓库代码资产形成首版具体方案。
