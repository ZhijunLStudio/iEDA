<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 29 · iPA / iIR 功耗与压降 · 商业对标优化方案 · rv1.0

> 文档号：29-rv1.0　　版本：v2.0（体例对齐）　　里程碑：**修 VCD 崩溃 → 活动源诚实（G9）→ IR 收敛合理（G10）→ vs PTPX/Voltus**
> 体例：`01-ai-doc-conventions-rv1.md`　主纲：G9/G10/G14/G17　Know-how：KH-PA-01/02、KH-IR-01/02、KH-X-04
> 对标：**PTPX / Joules**、**RedHawk / Voltus**
> 覆盖：`iPA/.../read_vcd/RustVCDParserWrapper.*`、`Power.*`、`iIR/.../IRSolver.cc`、`PGNetlist.*`、`IRMatrix.*`
> 纪律：断言带 `file:line`；未实测写「未验证」。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.0 | 2026-07-20 | VCD FATAL；IR 骨架实 |
| v1.1 | 2026-07-20 | 算法摘要；篇幅不足 |
| **rv1.0 / v2.0** | **2026-07-20** | **大改**：逐行坐实 `RustVCDParserWrapper.cc:49` hierarchical scope 用**单名** DFS 匹配，`/` 路径会 `LOG_FATAL` 崩进程；`Power.hh:208` `_default_toggle=0.02` 存在假数风险；IR 侧 `IRSolver.cc:209+` CG+残差有实现但门禁未接。修订旧稿「≥5 处 FATAL」为**可分级清单**（数据缺失 vs 逻辑错误）。 |

---

## 1. 症结审计

### 1.1 功能形态

| 模块 | 证据 | 判定 |
|---|---|---|
| VCD 入口 | `Power::readRustVCD`（`Power.cc:109-118`）→ `readVcdFile`+`buildAnnotateDB`+`calcScopeToggleAndSp` | 真路径 |
| Scope 查找 | `RustVCDParserWrapper.cc:16-49`：对 `children` DFS，**`Str::equal(name, top_instance_name)` 整串相等** | **不支持** `tb/dut` 层级路径；找不到 → **`LOG_FATAL_IF`(:49)** |
| 默认 toggle | `Power.hh:59-62,208` `_default_toggle = 0.02` | **假数源**风险（G9） |
| 功耗三分量 | switch/internal/leakage 算子目录存在 | 成熟度中等；报告是否标 `activity_source` **未验证** |
| PG 网表 | `PGNetlist.*` 多层金属段 | **真 PG**（相对标量 mesh） |
| IR 求解 | `IRSolver.cc:160+` LLT；`:209+` CG+precond+min residual；`:321+` Gauss-Seidel | **算法实**；LU 失败 `LOG_FATAL`(:179) |
| 电流源 | 是否=iPA 实例功耗 | **未验证**（I2） |

### 1.2 算法表

| kernel | 现状 | 判定 | 缺口 |
|---|---|---|---|
| Rust VCD annotate | Rust 解析 + C++ wrapper 建 AnnotateDB | 可用 | hierarchical path；可恢复错误 |
| toggle 传播 | `PwrPropagateToggleSP` 等 | 成熟 | 与默认 toggle 优先级 |
| P=αCV²f+int+leak | 标准分解 | 教科书+工程 | 活动源字段强制（KH-PA-01/02） |
| IR CG | L2 残差跟踪 `:215-301` | **非空壳** | 撞 max_iter→FAIL；peak 门禁 |
| IR LU | Eigen SimplicialLLT | 备选 | FATAL→可恢复 |

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
| FR-IR-03 | 动态 IR 时间窗 | ✗ | Phase C |
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

决策：

| # | 决策 | 被否 |
|---|---|---|
| D1 | 数据缺失→告警+拒报，不 FATAL | 一律崩进程 |
| D2 | 默认 toggle 仅显式 opt-in 且标 `toggle_default` | 静默 0.02 |
| D3 | 保持真 PG+迭代求解 | 改回标量 g_mesh |
| D4 | 电流必须可追溯到 iPA | 人工常数电流当签核 |

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

### 4.2 ★ ActivitySource 枚举 `[新增]`

```cpp
enum class ActivitySource { kVcd, kSaif, kToggleDefault, kRefuse };
// report: source 字段必填；kRefuse → 不写可信 mW 或写 NaN + ERROR
// _default_toggle 仅当用户显式 set 且 source=kToggleDefault
```

### 4.3 IR 门禁 `[新增接线]`

**现状**：CG 循环 `IRSolver.cc:235-301` 已打 residual 日志。

```text
if iter>=max_iter and residual>ε: return FAIL (rc≠0)
if peak_mv not in [1,100] and not explained: FAIL or WARN+归因
缺 PG 作用域: WARN + 降级，禁 LOG_FATAL（对齐主纲 G10）
```

### 4.4 模块状态

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

---

## 6. Cost / 指标

| 维 | 单位 | 门禁 |
|---|---|---|
| P_total / P_switch / P_int / P_leak | mW | G17/G9 |
| P_clock | mW | G19 协同 |
| activity_source | enum | G9 |
| peak_ir_mv | mV | G10 |
| residual_final | — | G10 |
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

### 对照实验

| ID | 方法 | 判据 |
|---|---|---|
| E-PA-01 | `tb_gcd/dut` 风格 top | 不崩；annotate 成功或拒报 |
| E-PA-02 | 无 VCD 且不允许 default | 拒报，无「精确」数字 |
| E-PA-03 | 显式 default toggle | 报告标 `toggle_default` |
| E-IR-01 | 人工坏网格 | residual FAIL |
| E-IR-02 | 断 iPA 电流 | 告警非静默 0 drop |

### 演进

```text
M0 先量：FATAL 清单+层级 VCD 复现
M1 可信：path 下钻+G9 activity_source
M2 主算法：G10 residual/peak 门禁+电流链路
M3 打平：vs PTPX/Voltus
M4 纵深：动态 IR 窗口（KH-IR-02）
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
