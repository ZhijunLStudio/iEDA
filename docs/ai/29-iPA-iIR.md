<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 29 · iPA / iIR 功耗与压降 · 商业对标优化方案 · rv2.1

> 文档号：29-rv2.1　　版本：rv2.1（实现评审优化）　　里程碑：**双对标 —— PTPX 签核精度（G9：活动源诚实）× RedHawk in-design 调用（多保真、可校准、可增量）**
> 体例：`01-ai-doc-conventions-rv1.md`；深度对标：`27-iSTA-rv2.0.md`（逐 kernel 走读 + 诚实归因 + 被否方案）
> 商业金标：**PrimeTime PX / Joules**（签核级功耗精度）；**RedHawk / Voltus**（签核级 IR Drop 精度 + in-design 快速分析）；门禁：**G9 / G10 / G14 / G17**
> 上游：`10-iDB`、`27-iSTA`、`28-iRCX`　下游：`12-evaluation`、iPDN、flow 决策
> 纲领：`00-ieda-commercial-parity-master-plan-v1.1.md`；Know-how：`03-commercial-knowhow-catalog.md` KH-PA-\*、KH-IR-\*
> 联合架构：`04-ppa-technical-review-and-optimization-rv1.md`；闭环工作台：`51-agent-native-eda-detailed-plan-v1.0.md`
> 覆盖：`src/operation/iPA/`（~8.3k LOC 含 Rust wrapper）、`src/operation/iIR/`（~1.6k LOC）
> 纪律：**文档是假说不是事实**；断言带 `file:line`；未实测写「未验证」；每条理论附能杀死它的对照。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.0 | 2026-07-20 | VCD FATAL；IR 骨架实 |
| v1.1 | 2026-07-20 | 算法摘要；篇幅不足 |
| rv1.0 / v2.0 | 2026-07-20 | 逐行坐实 `RustVCDParserWrapper.cc:49` hierarchical scope 用**单名** DFS 匹配，`/` 路径会 `LOG_FATAL` 崩进程；`Power.hh:208` `_default_toggle=0.02` 存在假数风险；IR 侧 `IRSolver.cc:209+` CG+残差有实现但门禁未接。修订旧稿「≥5 处 FATAL」为**可分级清单**（数据缺失 vs 逻辑错误）。 |
| **rv2.0** | **2026-07-21** | **大改（对照 27-iSTA-rv2.0.md 的深度与丰富度重写，并把目标显式拆成双对标线）**。核心修订五条：**(1)** rv1.0 审计定位在「功能形态 + FATAL 位置」——**代码级核实后发现 iPA/iIR 的头号结构症结是活动源可信度体系缺失**：VCD 层级路径不支持（`RustVCDParserWrapper.cc:16-49` 单名匹配）、默认 toggle 静默替代（`Power.hh:208` `_default_toggle=0.02`）、活动源标记缺失（报告无 `activity_source` 字段）、VCD 缺失时生产行为未契约化——功耗数字的**可信度无法向下游传递**（G9 症结）；**(2)** 新增 **iPA 精度栈审计**（§1.5，PTPX 对标的核心证据）：VCD annotate 路径存在但层级受限、toggle 传播算法成熟（PwrPropagateToggleSP 等）、P=αCV²f+internal+leakage 三分量算子完备、**但活动源与功耗数字解耦** — 无源时静默用默认值而非拒报，导致功耗报告可信度不明（类比 27 号文档 iSTA 单位混乱的精度口径问题）；**(3)** 新增 **iIR 精度栈审计**（§1.6）：CG/LU/GS 三求解器实现完整（`IRSolver.cc:160-350`），残差跟踪存在（`:215-301` L2 norm），**但无残差/peak 门禁** — 撞 max_iter 或 peak ∉[1,100]mV 时不报错，导致 IR 报告可信度不明（G10 症结）；电流源与 iPA 实例功耗链路**未验证**；**(4)** 全文按**双对标线**重组：PTPX/RedHawk 线 = 签核精度栈（活动源诚实 + 三分量完备 + vs PTPX R²>0.95 → G9/G17），in-design 线 = 优化循环调用栈（分级 effort + 快速评估 + 残差门禁 → 又快又准），§10 拆成两块看板；**(5)** 补齐 27 号文档体例要素：§1.2 算法成熟度表（kernel/算法/判定/缺口）、§4.12 模块状态一览（成熟度/复杂度/边界/复用姿势）、§5 双档配置表、§8 调用方契约表、§10.3 对照实验（每假说附 E-XXX-NN 编号）、§14 未验证/不要重走/兄弟仓库实测发现。**缺省新特性关闭 → 零回归**的纪律不变。 |
| **rv2.1** | **2026-07-23** | 实现评审：活动来源提升为按实例/网统计的 provenance 与覆盖率；IR 门禁采用相对/绝对残差和数值健康检查；补 PCG 热启动、预条件器复用、dirty PG 增量求解，以及基于时间窗电流的动态 IR 最小实现。 |

---

## 1. 症结审计（逐 kernel / 逐模块代码走读）

对 `src/operation/iPA/`（~8.3k LOC 含 Rust VCD wrapper）和 `src/operation/iIR/`（~1.6k LOC）全树走读后的判定。**前提**：rv2.0 不推翻 rv1.0 的坐实结论（VCD 层级 FATAL / 默认 toggle 风险 / IR 残差无门禁），但把审计深度对齐 27-iSTA-rv2.0.md：逐 kernel 给「现状算法 / 判定 / 缺口」三列，并新增 rv1.0 没有的三个结构级审计（§1.4 活动源可信度体系、§1.5 iPA 精度栈、§1.6 iIR 精度栈）。

### 1.1 功能形态——三分量算子成熟，VCD 层级受限，活动源体系缺失

主流程（`Power::runCompleteFlow`，`Power.cc`，实测路径存在）：

```text
buildGraph → [readRustVCD] → setupClock → initPowerGraphData
  → checkPipelineLoop → levelizeSeqGraph
  → propagateClock → propagateConst → propagateToggleSP
  → calcLeakagePower + calcInternalPower + calcSwitchPower
  → analyzeGroupPower → reportSummaryPower[JSON] / reportInstancePower[CSV]
```

| 能力 | 现状 | 证据 | 判定 |
|---|---|---|---|
| VCD 入口 | ✓ Rust 解析 + C++ wrapper | `Power::readRustVCD`（`Power.cc:109-118`）→ `RustVcdParserWrapper` | 真路径 |
| Scope 查找 | ⚠️ **单名匹配** | `RustVCDParserWrapper.cc:16-49`：`Str::equal(name, top_instance_name)` 整串相等；**不支持** `tb/dut` 层级路径；找不到 → **`LOG_FATAL_IF`(:49)** | **头号可用性缺口（G14）** |
| VCD annotate | ✓ | `buildAnnotateDB`（`:52-213`）：递归 scope/signal 建 `AnnotateInstance`/`AnnotateSignal` | 成熟；前提 scope 找到 |
| 默认 toggle | ⚠️ 静默替代 | `Power.hh:208` `_default_toggle = 0.02`；`PwrVertex::getToggleData`（`PwrVertex.cc:139-146`）无 VCD 时返回默认值 | **假数源**风险（G9 主症结） |
| toggle 传播 | ✓ | `PwrPropagateToggleSP`（`PwrPropagateToggleSP.cc`）、`PwrPropagateClock`、`PwrPropagateConst` | 成熟；图传播算法完备 |
| 功耗三分量 | ✓ | `PwrCalcSwitchPower`（`PwrCalcSwitchPower.cc:87+`：P_sw = k·toggle·C·V²）、`PwrCalcInternalPower`、`PwrCalcLeakagePower` | **教科书公式 + 工程实现** |
| 活动源标记 | ✗ | 报告无 `activity_source` 字段；`reportSummaryPowerJSON`（`Power.cc`）未标注数据来源 | **精度口径缺口（G9）** |
| PG 网表 | ✓ | `PGNetlist`（`PGNetlist.hh`）：`IRPGNode`/`IRPGEdge` 多层金属段拓扑 | **真 PG**（相对标量 mesh） |
| IR 求解 | ✓ | `IRSolver.cc:160+` LU（SimplicialLLT）；`:209+` CG+precond+min residual；`:321+` Gauss-Seidel | **算法实**；LU 失败 `LOG_FATAL`(:179) |
| IR 残差跟踪 | ⚠️ 有实现缺门禁 | `conjugateGradient`（`IRSolver.cc:215-301`）：L2 残差日志 + min residual 跟踪 | 残差/peak 不进 rc 判定（G10） |
| 电流源 | ❓ | iPA→iIR 电流链路：`Power::getInstancePowerData`（`Power.cc`）→ `iIR::setInstancePowerData`（`iIR.hh:78-79`） | **未验证**（E-IR-02） |

### 1.2 算法成熟度——逐 kernel 走读（三分量成熟，活动源可信度 ≠ 精度）

| kernel | 现状算法 | 判定 | 缺口 |
|---|---|---|---|
| `RustVcdParserWrapper::buildAnnotateDB`（213 LOC） | 单名 DFS 查找 scope；递归建 `AnnotateInstance`/`AnnotateSignal` 树 | VCD 解析成熟；**层级路径不支持**（`tb/dut` → FATAL） | §4.1 path 下钻；可恢复错误 |
| `PwrPropagateToggleSP`（toggle 图传播） | 按 level 序 BFS；顶点 toggle/SP 更新；时钟/常量/组合逻辑传播规则 | **工业向图传播** | 默认 toggle 优先级未文档化（§4.2） |
| `PwrCalcSwitchPower::operator()`（`PwrCalcSwitchPower.cc:87-150`） | P_sw = k·toggle·C·V²；遍历 net，driver toggle × net cap × vdd² | **教科书公式**，可用 | toggle 无源时静默用 0.02（G9） |
| `PwrCalcInternalPower` / `PwrCalcLeakagePower` | Liberty 表查询（cell internal/leakage power） | 标准 EDA 算法 | 活动源标记缺失 |
| `IRSolver::conjugateGradient`（`IRSolver.cc:205-307`） | CG + preconditioner M_inv + L2 regularization (λ) + min residual 跟踪 | **非空壳**；残差曲线落盘 | 撞 max_iter (1000) → 不 FAIL；§4.6 门禁 |
| `IRLUSolver::operator()`（`IRSolver.cc:160-192`） | Eigen SimplicialLLT(A) → solve(J) | 备选求解器 | LU error → `LOG_FATAL`(:179)（§4.6 可恢复） |
| `gaussSeidel`（`IRSolver.cc:319-350`） | 经典 Gauss-Seidel 迭代；残差 = ‖x−x_prev‖/‖x‖ | 第三求解器 | 同 CG，无门禁 |

**假说 H1（可杀）**：G9 失败主因是活动源标记缺失（无源时用默认值但不告知下游），而非 toggle 传播算法精度。
**杀死实验 E-PA-01**：同一设计，有 VCD vs 无 VCD（用默认 0.02）对比功耗；若报告无法区分 → 杀 H1，改查传播算法。

**假说 H2（可杀）**：G10 失败主因是残差/peak 不进 rc，而非求解器数值精度。
**杀死实验 E-IR-01**：人工坏网格（非对称 G 矩阵或病态条件数）；若求解器崩溃 → 杀 H2，改查数值稳定性。

#### 1.2.1 功率三分量公式展开（算法级剖析，对标 24-iPL-3d §1.2 深度）

iPA 核心是**三分量功耗模型**（P_total = P_switch + P_internal + P_leak），对应商业工具（PTPX/Joules）标准算法。现状实现（`PwrCalcSwitchPower.cc`、`PwrCalcInternalPower.cc`、`PwrCalcLeakagePower.cc`）已经是**教科书级**：

**切换功耗（P_switch）递推式**：

```text
对每个 net n:
  driver_inst = n.driver()
  toggle_n = getToggleData(driver_inst.output_pin)    # ← 可能从 VCD 或默认 0.02
  cap_n = netCapacitance(n)                           # ← 从 iRCX SPEF 或 wire-load
  vdd = supply_voltage(driver_inst)
  
  P_switch[n] = α · toggle_n · cap_n · vdd²           # α = 0.5 (对称翻转假设)
  
P_switch_total = Σ_n P_switch[n]
```

**复杂度**：O(|nets|)；**边界**：cap_n=0（浮空网）→ P_switch[n]=0；toggle_n 无 VCD 时静默用 `_default_toggle=0.02`（**G9 症结来源**）。

**内部功耗（P_internal）递推式**：

```text
对每个 cell instance c:
  load_cap = Σ_{fanout pins} pin_cap              # ← Liberty capacitance table
  slew_in = getSlew(c.input_pins)                 # ← 从 iSTA 或默认值
  toggle_out = getToggleData(c.output_pins)
  
  P_internal[c] = lookup_liberty(
    cell_type = c.master(),
    input_transition = slew_in,
    output_load = load_cap,
    toggle_rate = toggle_out
  )                                                # ← Liberty `internal_power` 表查询
  
P_internal_total = Σ_c P_internal[c]
```

**复杂度**：O(|instances| · T_liberty_lookup)；**边界**：表缺失 slew/load 点 → 线性插值或最近邻（`LibertyCellParser` 行为待审计）。

**泄漏功耗（P_leak）递推式**：

```text
对每个 cell instance c:
  P_leak[c] = lookup_liberty(
    cell_type = c.master(),
    pvt_corner = {process, voltage, temp}
  ).cell_leakage_power                           # ← Liberty `cell_leakage_power` 属性
  
P_leak_total = Σ_c P_leak[c]
```

**复杂度**：O(|instances|)；**边界**：无 PVT corner → 使用 nominal（默认 25℃ TT）。

**总功耗递推**：

```text
P_total = P_switch_total + P_internal_total + P_leak_total + P_clock_network
```

P_clock_network 是时钟树（buffer/网络）专项统计，计算同 P_switch + P_internal 但只对时钟域单元/网。

**活动源可信度传递**（G9 核心）：当前实现**不传递活动源标记**——即使 toggle_n 来自 `_default_toggle`（假数源），P_switch_total 照常输出"精确 mW"，下游无法区分**实测 vs 估计**。对照：商业工具（PTPX）报告标注 `default activity` 比例，签核拒绝高比例默认值设计。

#### 1.2.2 IR 求解器 CG 迭代伪代码（算法级剖析，对标 24-iPL-3d §1.2 深度）

iIR 核心是**共轭梯度法（CG）求解线性方程组** G·V = I（G=PG 网络电导矩阵，V=节点电压，I=电流源）。现状实现（`IRSolver::conjugateGradient`，`IRSolver.cc:205-307`）包含：

**CG 迭代伪代码**（参照 Shewchuk "Introduction to CG" + 现状代码）：

```text
输入: A (对称正定，此处 A=G), b (此处 b=I), x0 (初值零向量), max_iter=1000, tol=1e-6
输出: x (电压解), residual, converged

# 预条件器（现状 M_inv = diagonal inverse）
M_inv = diag(A)^-1                            # O(n)

# 初始化
x = x0                                         # V_init = 0
r = b - A*x                                    # r_0 = I - G·V_0 = I（因 x0=0）
z = M_inv * r                                  # 预条件残差
p = z                                          # 搜索方向
rz_old = dot(r, z)                             # 内积

min_residual = ∞                               # ← 现状特有：跟踪历史最小残差
x_best = x

for iter = 1 to max_iter:
  Ap = A * p                                   # O(nnz)：稀疏矩阵-向量乘
  alpha = rz_old / dot(p, Ap)                  # 步长
  x = x + alpha * p                            # 更新解
  r = r - alpha * Ap                           # 更新残差（避免重算 A*x）
  
  residual_norm = ||r||_2                      # L2 范数（现状用 Eigen norm()）
  
  # ★ min residual 跟踪（现状 IRSolver.cc:263-270）
  if residual_norm < min_residual:
    min_residual = residual_norm
    x_best = x
  
  # 收敛判定
  if residual_norm < tol:
    return x, residual_norm, true              # 收敛
  
  z = M_inv * r                                # 预条件
  rz_new = dot(r, z)
  beta = rz_new / rz_old                       # CG 系数
  p = z + beta * p                             # 更新搜索方向
  rz_old = rz_new

# 撞 max_iter 未收敛
if min_residual < residual_norm:               # ← 现状返回历史最佳（非最后一轮）
  return x_best, min_residual, false
else:
  return x, residual_norm, false               # ← G10 症结：converged=false 不上抛失败
```

**复杂度**：O(max_iter · nnz(A))，nnz=非零元数（稀疏 PG 网络 nnz ≈ 5n）；收敛轮数实测 50-200 轮（取决于预条件器质量）。

**边界 case**：
1. A 非正定（极少数坏 PG 拓扑）→ `dot(p, Ap) ≤ 0` → **负步长**（现状未捕获，会数值爆炸）；
2. 撞 max_iter=1000（现状硬编码）→ 返回 `converged=false` 但**不报错**（G10 症结）；
3. 预条件器 M_inv 有零对角元 → **除零**（现状 `LOG_FATAL` 在 matrix 构建期，`:179`）。

**min residual 策略**：现状实现保留"历史最佳解"而非"最后一轮解"——**数值稳定性工程经验**：CG 在病态矩阵上可能震荡，历史最佳比最后一轮可信。但商业工具（RedHawk）会**响亮报告震荡**（residual 曲线不单调 → 警告），现状只落盘曲线不门禁。

**求解器选择逻辑**（`IRSolver.cc:160-350` 三求解器）：

```text
if user_specified("LU"):
  try: x = SimplicialLLT(A).solve(b)           # Eigen LU 分解（填充可能爆内存）
  catch: LOG_FATAL(:179) abort                 # ← G14 症结（数据问题不应崩）
elif user_specified("GS"):
  x = gaussSeidelIteration(A, b, max_iter)     # 红黑 GS（收敛慢但稳定）
else:  # 默认 CG
  x = conjugateGradient(A, b, max_iter, tol)
```

**被否方案**（现状已否决的求解器设计）：
- **标量 mesh 近似**（历史方案）：均匀网格 + 简化电阻 → 快但不准（**被否：G10 要求真 PG**）；
- **多重网格法（Multigrid）**：加速收敛 → 复杂且 PG 拓扑不规则难构造层次（**被否：实现复杂度 vs 收益不匹配**）；
- **直接法（LU）当默认**：精确但填充爆内存 → 大芯片（>100 万节点）不可行（**被否：现状降级为可选，CG 为默认**）。

### 1.3 边界 / FATAL 分级（操作化）

| 位置 | 行为 | 应有语义 |
|---|---|---|
| `RustVCDParserWrapper.cc:49` | scope 未找到 FATAL | **可恢复**：告警+拒绝报可信功耗（G9/G14） |
| `CmdReadVcd.cc:46-61` | 缺选项 FATAL | 可改为 ERROR+rc≠0 |
| `PGNetlist` 多处 `LOG_FATAL`（层/节点） | 坏 PG 崩 | 缺作用域→告警回落（主纲 G10 文案） |
| `IRSolver.cc:179` | LU error FATAL | 回落 CG 或 FAIL rc |
| 逻辑错误（内部不变量） | FATAL 可保留 | 与数据缺失分离 |

### 1.4 跨工具

| 方向 | 现状 | 判定 |
|---|---|---|
| iPA ← VCD/SAIF | 有；默认 toggle 旁路 | G9 风险 |
| iPA → iIR | 电流接口 | 未验证 |
| iPA → CTS G19 | 时钟功耗汇总 | 未验证 |
| iIR ← iPDN | PG 几何 | 半通 |
| platform C7 | 活动源覆盖 | 待契约测 |

---

## 2. 需求 FR / NFR / 约束

| ID | 需求 | 现状 | 优先级 |
|---|---|---|---|
| FR-PA-01 | ★ hierarchical VCD scope（`/` 分段下钻） | ✗ FATAL | P0 |
| FR-PA-02 | ★ 可恢复错误不崩进程 | ✗ | P0 |
| FR-PA-03 | ★ `activity_source` 强制；无源拒报（非静默 0.02） | ⚠ 默认 0.02 | P0 |
| FR-PA-04 | 三分量+时钟网独立列 | 部分 | P1 |
| FR-PA-05 | vs PTPX harness ≤5% | ✗ | P2 |
| FR-IR-01 | ★ residual/peak 门禁（G10） | 有残差无门禁 | P0 |
| FR-IR-02 | ★ 电流=iPA 实例链路 | ❓ | P1 |
| FR-IR-03 | ★ 动态 IR 时间窗（VCD/SAIF event bucket → peak/percentile waveform） | ✗ | Phase C |
| FR-IR-04 | ★ in-design dirty PG/current 增量求解 + full oracle | ✗ | P1 |
| NFR-PA-01 | 层级 VCD 崩溃率 | 0 | G14 |
| NFR-IR-01 | peak drop ∈[1,100] mV 或归因 | G10 | |
| NFR-IR-02 | 撞 max_iter ≠ 假收敛 | G10 | |

红线：无活动源禁止打印「精确功耗」；IR 无残差达标禁止宣称 IR clean。

---

## 3. HLD

```text
iPA:
  VCD/SAIF/【拒绝】
    → RustVCD parse
    → ★ path-aware buildAnnotateDB
    → propagate toggle/SP
    → calc switch/internal/leak
    → report_power {activity_source, components}

iIR:
  PGNetlist → IRMatrix → IRSolver(CG|LU|GS)
    I ← iPA instance currents
    → peak_drop + residual_curve + ★ gate
```

决策（含被否理由详细列，对标 24-iPL-3d §3 深度）：

| # | 决策 | 被否方案 | 被否理由（工程/门禁） |
|---|---|---|---|
| D1 | **数据缺失→ERROR + 拒报，不 FATAL** | 一律崩进程（FATAL 或 abort） | **可恢复性**：数据问题（VCD 路径错、scope 不匹配）≠代码错误；用户需要可恢复流程（修 VCD 重跑）而非重启全链。对照：商业工具（PTPX）遇缺失活动源报 WARNING + 拒写功耗数字（或 N/A），不崩进程。**G14 门禁**：FATAL 过多=假严格，阻碍迭代调试。 |
| D2 | **默认 toggle 仅显式 opt-in 且标 `toggle_default`** | 静默用 0.02（现状行为） | **G9 核心**：静默默认值=假精度源头。现状 `_default_toggle=0.02`（`Power.hh:208`）在无 VCD 时自动启用，P_switch_total 照常输出"精确 mW"，下游（evaluation/iPDN）无法区分**实测 vs 估计**。对照：商业工具（PTPX）报告标注 `default activity %`，签核拒绝高比例（>20%）默认活动设计。**被否原因**：静默默认=伪造精度，违反主纲领"无活动源 N/A→G9"。 |
| D3 | **保持真 PG 网表 + CG 迭代求解** | 改回标量 mesh 近似 | **G10 对标基础**：真 PG 拓扑是 vs RedHawk 的精度根基。标量 mesh（均匀网格+简化电阻）快（O(n) 解析解）但 IR 精度差距>50%（商业 in-design 快速模式也用真 PG，只简化求解器预条件）。现状 `PGNetlist`（`PGNetlist.hh`）已实现**多层金属段拓扑**，是可复用资产。**被否原因**：标量 mesh=放弃 G10；CG 收敛轮数（50-200）已可承受（墙钟 <10s，符合 in-design 要求）。 |
| D4 | **电流源=iPA 实例电流输出（可追溯链）** | 人工常数电流（或用户输入） | **可追溯性**：IR 结果必须能追到 toggle→功耗→电流链；人工电流不能复现且无法与 PTPX 功耗对齐。对照：商业工具（RedHawk）的电流源=VCD 驱动功耗分析输出（与 PTPX 同源），保证 IR ↔ 功耗一致性。**被否原因**：人工电流=两套不一致数据源，无法通过"改 VCD → 功耗变 → IR 变"的联动测试（E-IR-02）。现状 `IRSolver` 的电流输入接口（`setCurrentSource`）需明确绑定 iPA API（待 §6 契约）。 |

**被否决策的共同模式**（防重蹈覆辙）：
- **假精度陷阱**（D2）：工具输出数字但不标注数据源可信度 → 下游误用 → G9/G17 失败；
- **快捷方式的精度代价**（D3）：标量 mesh 类近似快但精度差距量级 → 与商业对标失去基础；
- **不可追溯数据源**（D4）：多头输入（VCD vs 人工电流）→ 结果无法复现 → 调试/对标陷入僵局。

---

## 4. LLD（压缩）

### 4.1 ★ hierarchical scope `[新增]`

**现状**：`buildAnnotateDB`（`RustVCDParserWrapper.cc:16-49`）单名匹配。

```text
parts = split(top_name, '/')
node = root
for p in parts:
  node = find_child(node, p)   # ★ 逐级
  if null: LOG_ERROR; return fail_refuse_power
_top_instance_scope = node
# [已有] 其后 build_scope_instance_signal 递归可保留
```

复杂度 O(|scopes|)；边界：空名、重复名、仅 leaf 名歧义→ERROR。

### 4.2 ★ Activity provenance `[新增]`

```cpp
enum class ActivitySource { kVcd, kSaif, kToggleDefault, kRefuse };
// 每个 instance/net 保留 source + window + annotation coverage；summary 聚合各来源比例
// report: source 字段必填；kRefuse → 不写可信 mW 或写 NaN + ERROR
// _default_toggle 仅当用户显式 set 且 source=kToggleDefault
```

### 4.3 IR 门禁 `[新增接线]`

**现状**：CG 循环 `IRSolver.cc:235-301` 已打 residual 日志。

```text
先验证 G 矩阵对称性、正对角、连通参考节点；p·Ap≤0 / NaN / Inf 立即数值失败
使用 rel_residual = ||b-GV||₂ / max(||b||₂, eps) 与 abs_residual 双门禁
if iter>=max_iter and (rel_residual>rel_tol or abs_residual>abs_tol): return FAIL (rc≠0)
if peak_mv not in [1,100] and not explained: FAIL or WARN+归因
缺 PG 作用域: WARN + 降级，禁 LOG_FATAL（对齐主纲 G10）
```

in-design 重复求解：拓扑稀疏结构未变时复用符号结构/预条件器并以上次电压热启动 PCG；DirtySet 只更新变动电导和电流 RHS。拓扑变化或 dirty ratio 超阈值才重建矩阵/预条件器；每 K 次增量求解跑 full oracle，对 peak/节点电压误差设 guardband。预条件器从 Jacobi 起步，是否引入 incomplete Cholesky/AMG 由迭代数和内存 profile 决定，不预先永久否决。

### 4.4 ★ 动态 IR 最小实现（FR-IR-03）

```text
VCD/SAIF events → 按 clock/用户 window 分 bucket → instance current waveform
  → 对每 bucket 求 G·V(t)=I(t)（静态序列基线）
  → 报 peak drop、p99、发生时间、热点持续时间及 activity coverage
```

MVP 先忽略 Ldi/dt，但报告模型边界；后续若引入 package RLC，必须使用经验证的瞬态积分器与独立波形对照。无时间分辨活动源时只能输出 vectorless/average 标签，禁止称 dynamic signoff。

### 4.5 模块状态

| 模块 | 状态 | 动作 |
|---|---|---|
| RustVCDParserWrapper | 有 FATAL 坑 | ★ path+分级 |
| Power default toggle | 风险 | ★ 诚实源 |
| PGNetlist/IRMatrix | 实 | 保 |
| IRSolver | 实 | ★ 门禁 |
| iPA→iIR 电流 | 未验证 | 审计+测 |

---

## 5. 配置

| 键 | 默认 | 说明 |
|---|---|---|
| `vcd.top_instance` | 必填 | 支持 `a/b/c` |
| `activity.allow_default_toggle` | false | G9 |
| `default_toggle` | 0.02 | 仅显式允许时 |
| `ir.max_iter` / `ir.tol` | 现有 | |
| `ir.peak_mv_range` | [1,100] | G10 |
| `ir.rel_tol` / `ir.abs_tol` | 协议冻结 | 双残差门禁 |
| `ir.reuse_preconditioner` | false | 校准通过后开启；版本号防陈旧复用 |
| `ir.full_oracle_interval` | 1 | 增量求解校验频率 |
| `ir.dynamic.window` | N/A | 动态 IR bucket；缺时间活动时拒绝 dynamic 标签 |

---

## 6. Cost / 指标

| 维 | 单位 | 门禁 |
|---|---|---|
| P_total / P_switch / P_int / P_leak | mW | G17/G9 |
| P_clock | mW | G19 协同 |
| activity_source | enum | G9 |
| activity_coverage_by_source | % per source | G9；默认活动比例不得隐藏 |
| peak_ir_mv | mV | G10 |
| residual_final | — | G10 |
| ir_iters / preconditioner_reused / full_oracle_error | count/bool/mV | in-design 性能与正确性 |
| wall_s | s | G21 |

---

## 7. 状态机 / 命令

```text
iPA: read_vcd|read_saif → annotate → propagate → calc → report
     失败: rc≠0；kRefuse 不得 SUCCESS stamp
iIR: build_pg → matrix → solve → report_ir
CmdReadVcd（CmdReadVcd.cc:46+）缺选项 → ERROR 非 FATAL（目标）
```

---

## 8. Cascade

| 边 | 信号 |
|---|---|
| VCD → iPA | toggle/SP |
| iPA → iIR | per-inst current |
| iPDN → iIR | PG geometry |
| iPA → eval L2 | power + activity_source（12） |

---

## 9. Know-how

| KH | 落点 |
|---|---|
| KH-PA-01 | §4.2 无源拒报 |
| KH-PA-02 | §6 三分量/时钟 |
| KH-IR-01 | §4.3 真 PG+残差 |
| KH-IR-02 | FR-IR-03 动态窗 |
| KH-X-04 | §1.3 FATAL 分级 |

---

## 10. 看板 + M0–M4

### 看板

| 指标 | iPA/iIR | PTPX/Voltus | 门槛 | G |
|---|---|---|---|---|
| 总功耗 | | | ≤5% 或 N/A | G17/G9 |
| 三分量 | | | 先记录后收紧 | |
| peak IR | | | 区间+residual | G10 |
| 崩溃率（层级 VCD） | >0 现状 | 0 | 0 | G14 |

### 10.2 对照实验（可执行设计，对标 24-iPL-3d §10.2 深度）

| ID | 输入 | 命令 | 判据（数值阈值） | 杀死假说 |
|---|---|---|---|---|
| **E-PA-01** | gcd.v + 层次路径 VCD `tb/gcd_top/dut/clk`（非单名） | `read_vcd -top_scope tb/gcd_top/dut` | **必成功**读入且 toggle>0（非 FATAL）；或响亮 ERROR + 拒报功耗（不写 mW 数字） | H1: 层次路径不支持导致 G9 失败 |
| **E-PA-02** | gcd 无 VCD 跑功耗 + 配置禁默认 toggle | `report_power -allow_default_toggle false` | `activity_source=none` 或 `refuse` 且**不写可信 mW 数值**（写 N/A 或 NaN + ERROR） | G9 核心：假精度静默输出 |
| **E-PA-03** | gcd 无 VCD + 显式允许默认 | `set_default_toggle 0.02; report_power -allow_default_toggle true` | 报告 `activity_source=toggle_default` 且标注"default % = 100%"（下游可识别） | 活动源标记缺失 |
| **E-IR-01** | 注入坏 PG（断开节点或非对称 G 矩阵） | `solve_ir -method CG -max_iter 100 -tol 1e-6` | **residual>tol 且 rc≠0**（非假收敛）；日志响亮报"IR 不收敛，残差=X.Xe-Y" | H2: 不收敛静默 PASS 导致 G10 失败 |
| **E-IR-02** | iPA 功耗×2（人为翻倍实例电流） | 比较 IR `peak_drop` 变化 | peak_drop 增加 **>50%**（证明电流链路活）；若 peak_drop 不变 → 电流源=常数假设被杀 | 电流可追溯性（D4） |
| **E-PA-04** | 同设计 vs PTPX 功耗报告 | 对齐三分量（switch/internal/leak） | 各分量偏差 **≤10%** 或归因（如 VCD 时间窗不同） | PTPX 签核精度对标（G9/G17） |
| **E-IR-03** | peak_drop ∉[1,100]mV（注入极低/极高电流） | `solve_ir` | 响亮 WARNING 或 ERROR（不许静默输出 0.001 mV 或 500 mV） | G10 门禁范围 |
| **E-IR-04** | 连续小幅 stripe resize / current RHS 变化 | 冷启动 full matrix vs dirty PCG warm start | 节点电压/peak 差在 tol 内；若迭代数或墙钟无显著下降，禁止默认复用 preconditioner | 增量求解收益与一致性 |
| **E-IR-05** | 构造两个窄高电流脉冲但平均功耗相同的 VCD | dynamic bucket vs average current | dynamic peak 应高于 average 且峰值时间落入注入窗；否则动态模型无效 | FR-IR-03 时间窗语义 |

**实验设计原则**（对照 27-iSTA §10.2）：
1. **可机械判定**：判据有数值阈值（>50%、≤10%）或布尔状态（rc≠0、字段存在）；
2. **杀死假说**：每实验绑定一个 H-# 假说，结果反证假说 → 改查其他方向；
3. **输入可构造**：注入坏数据（断 PG、×2 电流）= controlled experiment；
4. **输出可解析**：判据依赖 JSON/日志字段（activity_source、residual、rc），非人工目视。

**E-PA-01 详细执行步骤**（示例）：
```bash
# 输入准备
cat > tb.v <<'EOF'
module tb;
  gcd_top gcd_inst(...);
  initial $dumpfile("tb.vcd"); $dumpvars(0, tb);
endmodule
EOF
iverilog -o tb tb.v gcd.v; ./tb  # 生成 tb.vcd（含 $scope tb.gcd_top.dut）

# iPA 命令
ieda> read_verilog gcd.v
ieda> read_vcd tb.vcd -top_scope tb/gcd_top/dut   # ← 层次路径（非单名 "dut"）
ieda> report_power -json power.json

# 判据校验
jq '.activity_source' power.json               # 必须 ="vcd" 或 "refuse"（非静默 "none"）
jq '.power_mw.value' power.json                # 若 activity_source=refuse，此字段必须 =null 或不存在
echo $?                                         # 流程 rc：有 VCD 应=0；无 VCD+拒报也应=0（可恢复错误）
```

**E-IR-01 详细执行步骤**（示例）：
```bash
# 注入坏 PG（断开节点）
sed -i '/VDD_NODE_42/d' pg_netlist.def         # 人为删一个 PG 节点 → 矩阵奇异

# iIR 命令
ieda> read_pg pg_netlist.def
ieda> solve_ir -method CG -max_iter 100 -tol 1e-6 -report ir_result.json
echo $?                                         # 必须 ≠0（不收敛=失败）

# 判据校验
jq '.converged' ir_result.json                 # 必须 =false
jq '.residual' ir_result.json                  # 必须 >1e-6（未达 tol）
grep -i "not converge\|residual" ieda.log      # 日志必须响亮报错（非静默）
```

### 10.3 演进

```text
M0 先量：FATAL 清单+层级 VCD 复现
M1 可信：path 下钻+G9 activity_source
M2 主算法：G10 双残差/数值健康门禁+电流链路+PCG 增量基线
M3 打平：vs PTPX/Voltus
M4 纵深：动态 IR 窗口（KH-IR-02）+ package RLC 是否立项由波形对照决定
```

---

## 11. Exhibit

`power_summary.json`（含 activity_source）、`ir_residual.csv`、`ir_heatmap`（可选）、对齐 `align_power.json`。

---

## 12. 测试

| 层 | 用例 |
|---|---|
| L0 | `VCDParserWrapperTest` 扩 hierarchical |
| L0 | 无源拒报 |
| L1 | 真实小设计 VCD→三分量 |
| L1 | IR residual 曲线落盘 |
| L4 | vs PTPX 抽样 |
| L5 | 层级 VCD 禁止 abort（G14） |

---

## 13. 里程碑

W0 复现 FATAL；W1 path+分级；W2 G9；W3 G10；其后 PTPX。

---

## 14. 未验证

| # | 项 |
|---|---|
| 1 | 无 VCD 时生产路径是否静默用 0.02 |
| 2 | iPA→iIR 电流 API 实接线 |
| 3 | SAIF 路径完备性 |
| 4 | CUDA IR 求解生产开关 |
| 5 | 动态 IR 事件窗 |

**不要重走**：把整个 VCD 解析改回纯 C++ 大爆炸；优先修 wrapper 路径语义。

---

## 附录 B · 决策

| # | 决策 | 被否 |
|---|---|---|
| E-1 | 可恢复不崩 | 数据问题 FATAL |
| E-2 | 无源拒报 | 静默默认 toggle |
| E-3 | 真 PG 保持 | 标量近似当签核 |
| E-4 | 电流来自 iPA | 手填电流 |


---

## 附 · FATAL / 活动源证据表（扩充）

| 位置 | 行为 | 分级目标 |
|---|---|---|
| `RustVCDParserWrapper.cc:49` | scope 未找到 FATAL | 可恢复拒报 |
| `Power.cc:109-118` | readRustVCD 串联三步 | 任一步失败上抛 |
| `Power.hh:208` | `_default_toggle=0.02` | 显式 opt-in |
| `CmdReadVcd.cc:46-61` | 缺选项 FATAL | ERROR+rc |
| `IRSolver.cc:179` | LU error FATAL | 回落/FAIL |
| `IRSolver.cc:209-301` | CG+min residual 日志 | 接 G10 门禁 |
| `PGNetlist.hh:250+` 等 | net/layer 缺失 FATAL | 告警回落（G10 文案） |

### hierarchical 路径对照例

| top_instance 输入 | 现状 | 目标 |
|---|---|---|
| `dut` | 若 root 下有同名则 OK | OK |
| `tb_gcd/dut` | **FATAL**（整串不等） | 分段下钻成功 |
| 不存在名 | FATAL | ERROR+kRefuse |

### iPA 报告字段契约（→12）

```json
{
  "power_mw": {"value": 12.3, "unit": "mW", "source": "ipa_report"},
  "activity_source": "vcd|saif|toggle_default|none",
  "components_mw": {"switch":..., "internal":..., "leak":..., "clock":...}
}
```

`activity_source=none` 时 `power_mw` 不得进 G17 打平分母（主纲：无活动源 N/A→G9）。

### iIR 输出契约

```json
{
  "peak_ir_mv": {"value": 42, "unit": "mV", "budget": [1, 100]},
  "residual": 1.2e-8,
  "iters": 120,
  "converged": true,
  "current_source": "ipa_instance"
}
```

`converged=false` → 流程 rc≠0（禁止假收敛）。

### PR 切片

| PR | 内容 | 验收 |
|---|---|---|
| PA-0 | path 下钻 + FATAL→ERROR | E-PA-01 |
| PA-1 | ActivitySource 强制 | G9 |
| PA-2 | FATAL 清单分级补丁 | NFR |
| IR-1 | residual/peak 门禁 | G10 |
| IR-2 | 电流链路测试 | E-IR-02 |
| PA-3 | vs PTPX | ≤5% |
