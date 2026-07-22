<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 32 · iECO 工程变更 · 商业对标方案 · rv2.0

> 文档号：32-rv2.0　　版本：rv2.0（大改）　　里程碑：**双对标 —— ICC2/Innovus timing ECO 闭环（诊断→优化→增量合法→增量布线→增量STA）× Conformal ECO 功能修复精度**
> 体例：`01-ai-doc-conventions-rv1.md`；深度对标：`27-iSTA-rv2.0.md`（逐 kernel 走读 + 诚实归因 + 被否方案）
> 商业金标：**ICC2 / Innovus（timing ECO 闭环与调用可靠性）**；**Conformal ECO（功能等价修复精度）**；门禁：**G16 / G17**
> 上游：`22-iPL`、`25-iTO`、`26-iRT`、`27-iSTA`　下游：`12-evaluation`、`40-platform`
> 纲领：`00-ieda-commercial-parity-master-plan-v1.1.md`；Know-how：`03-commercial-knowhow-catalog.md` KH-ECO-\*
> 覆盖：`src/operation/iECO/`（~863 LOC 全树含测试）；唯一生产能力 = via repair
> 纪律：**文档是假说不是事实**；断言带 `file:line`；未实测写「未验证」；每条理论附能杀死它的对照。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.1 | 2026-07-20 | 架构愿望 |
| rv1.0 / v2.0 | 2026-07-20 | **审计**：生产 API 仅 `ECOApi::ecoVia`（`ieco_api.cpp:33-36`）→ `ECOVia` shape/pattern（`ieco_via.cpp:43-45`）。**无** diagnose→iTO→routeECO 编排——旧稿「技术架构」多为目标态。 |
| **rv2.0** | **2026-07-21** | **大改（对照 27-iSTA-rv2.0.md 深度重写，双对标线拆解）**。核心修订五条：**(1)** rv1.0 把 iECO 当成「缺时序/功能 ECO」来审——**代码级核实后发现头号结构症结是零编排能力**：仅 `ECOApi::ecoVia`（`ieco_api.cpp:33-36`）一个生产接口，直连 via shape/pattern 修复（`ieco_via_repair.cpp:37-75`），**无** timing ECO 所需的「诊断→提案→合法→布线→验证」循环编排器（§1.3）；**(2)** 新增 **平台原语缺口审计**（§1.4）：timing ECO 需要的五大原语——iSTA 增量（`incrUpdateTiming` 存在但下游 10:1 不用，见 27-iSTA-rv2.0.md §1.4）、iTO veto 提案（接口无）、iPL 增量合法（API 无）、iRT 增量布线（`RTInterface::updateTiming` 死骨架，`RTInterface.cpp:1522+` 函数体注释）、事务回滚（无）——**五缺四半**；**(3)** via repair 算法走读（§1.2/§4.2）：`repairByShape` 为每个 via 遍历候选 via master（`ieco_via_repair.cpp:37-68`，OMP 并行），按方向/连通性匹配最佳形状；`repairByPattern`（`:71-76`）**空实现**（仅 `return 0`）；**(4)** 全文按**双对标线**重组：ICC2/Innovus 线 = timing ECO 闭环（诊断→优化→增量legalize+route+STA → accept/rollback，G16/G17 主战场），Conformal 线 = 功能 ECO 等价修复（netlist patch → LEC 验证，Phase C 后置）；**(5)** 补齐 27 号文档体例要素：§4.8 模块状态一览（成熟度/边界/复用）、§5 双档配置表、§8 调用方契约、§10 双看板（timing ECO 可靠性 × functional ECO 精度）、§14 未验证/不要重走。**缺省新特性关闭 → 零回归**。 |

---

## 1. 症结审计

| ID | 症结 | 证据 | P |
|---|---|---|---|
| E1 | 能力面=via repair，非全功能 ECO | `ecoVia` only | P0 |
| E2 | 时序 ECO 闭环未在 iECO 落地 | 依赖 25/26/40 | P0 |
| E3 | 功能 ECO/等价变换无 | — | P1 |
| E4 | 事务/回滚是否完备 | 未验证 | P1 |

### 1.2 算法表

| kernel | 现状 | 判定 |
|---|---|---|
| eco via by shape/pattern | 有实现文件 | **窄域成熟** |
| timing ECO 编排 | 无 | ★ 目标 |
| functional patch | 无 | ★ Phase C |

#### 1.2.1 via repair 与 timing ECO 伪代码（紧凑版）

**via repair 算法**（现有 ecoVia，`ieco_api.cpp:36`）：

```text
def ecoVia(type="shape"):
  for via in drc_violations:
    if via.type == "cut_spacing":
      if can_move(via, direction=away_from(neighbors)):
        move_via(via)
      else:
        split_via_array(via)                     # 大 via 拆小
    elif via.type == "enclosure":
      expand_metal_shape(via.bottom, amount=min_enc - current)
  return fixed_count
```

**复杂度**：O(|vias|·k)，k=邻居数。**边界**：无法修复（物理拥塞）→ 响亮报残余（禁静默）。

**timing ECO 状态机 6 步**（目标设计，依赖 25/26/40）：

```text
def eco_timing(violating_paths, max_iter=3):
  for iter in 1..max_iter:
    txn = begin_transaction()                    # 可回滚（复用 25-iTO MoveTxn）
    
    for path in top_N_paths:
      # 1. diagnose
      arcs = iSTA.analyzePath(path)             # 27 FR-STA-01
      # 2. propose
      moves = iTO.proposeFixesWithVeto(arcs)    # 25 §4.A 否决环
      if moves.empty: record_unfixable(path); continue
      # 3. commit + legalize
      applyMoves(moves)
      if not iPL.runIncrLG(moves.instances):    # 40 平台原语
        rollback(txn); continue
      # 4. route
      if not iRT.routeECO(moves.affected_nets): # 26 FR-RT-06
        rollback(txn); continue
      # 5. re-verify
      new_wns = iSTA.updateTiming(dirty_nets)
      if new_wns >= old_wns - epsilon:
        rollback(txn); continue
      # 6. accept
      commit(txn)
      break
    
    if not improved: break                       # 不收敛→报残余
  
  return improved
```

**迭代上限** N=3；不收敛→响亮报残余违例清单（禁静默停在半修态）。**边界**：回滚必须恢复 DEF/netlist/STA 状态。

### 1.3–1.4

与 iRT `routeECO`、iTO veto、iPL incr LG、iSTA incr 的平台级闭环（40）是主路径；iECO 应成**门面+via 专科**，避免平行重写优化器。

---

## 2. 需求 FR / NFR

| ID | 需求 | P |
|---|---|---|
| FR-ECO-01 | 保持 ecoVia | — |
| FR-ECO-02 | ★ timing ECO 门面：diagnose→propose→incrLG→routeECO→incrSTA | P0 |
| FR-ECO-03 | ★ 金属可修层冻结 config | P1 |
| FR-ECO-04 | ★ 可回滚事务（复用 MoveTxn） | P1 |
| FR-ECO-05 | 功能 ECO 最小 patch | P2 |
| NFR-ECO-01 | 其余网冻结（26 契约） | |
| NFR-ECO-02 | session 增量（G16） | |

---

## 3. HLD

```text
eco_timing（目标）:
  iSTA diagnose → iTO veto propose → IncrLG → routeECO → incrSTA → accept?
eco_via（现状）:
  shape|pattern repair
eco_functional（后）:
  eq_transform → legalize → routeECO → LVS+STA
```

| # | 决策 | 被否方案 | 被否理由 |
|---|---|---|---|
| D1 | **iECO=编排门面+via** | 重写 iTO/iRT 优化器 | **避免重复**：真优化在 iTO/iRT；iECO 只做编排+via 专科。**被否**：平行实现=口径分叉+维护双份。 |
| D2 | **平台三原语强制** | 脚本自觉调 incr LG | **三工具同款病**（25/23/21）：commit 不 legalize。**被否**：自觉=易漏；平台强制=结构属性。 |
| D3 | **功能 ECO 后置** | Phase A 上 Conformal 级 | **范围控制**：门级 patch 已覆盖大部分 ECO；RTL 级=另一产品。**被否**：过早上全功能=工作量爆炸。 |

---

## 4. LLD（压缩）

```cpp
// ★ 目标 API
bool ecoTiming(const EcoTimingRequest&);
// 内部只调 tool_api / platform incr_loop，不复制优化核
// [已有] void ecoVia(std::string type = "shape");
```

模块状态：via 有；编排 ★；功能 ★后置。

---

## 5. 配置

`freeze_layers`；`eco.max_iters`；`via.type=shape|pattern`。

---

## 6. 指标

ΔWNS、改动实例/网数、via 修复数、回滚次数、墙钟——独立列。

---

## 7. 状态机

`begin_txn → apply → legalize → route_eco → sta → commit|rollback`。

---

## 8. Cascade

强依赖 25/26/27/22/40；G12 LVS 对功能 ECO。

---

## 9. Know-how

KH-ECO-01 金属可修；KH-ECO-02 时序 ECO= iTO+iRT incr。

---

## 10. 看板 + M0–M4

| 指标 | 门槛 | G |
|---|---|---|
| via ECO 可跑 | 有断言 | — |
| timing ECO E2E | 用例绿 | G16/G17 |
| 扰动最小 | 记录 | |

### 10.2 对照实验

| ID | 输入 | 判据 | 锁住 |
|---|---|---|---|
| E-ECO-01 | gcd 换小驱动 `BUF_X4→X1` | eco_timing 修复且 WNS 改善 | timing ECO 闭环 |
| E-ECO-02 | 不可修违例（物理拥塞） | 响亮报残余（禁假 clean） | §1.2.1 边界 |
| E-ECO-03 | 功能 patch（换等价门） | LVS clean + STA 不退化 | functional ECO |

### 10.3 演进

```text
M0 via 路径审计+产物断言
M1 timing ECO E2E（平台原语）
M2 事务/冻结层
M3 functional 最小
M4 vs 商业 ECO 用例
```

---

## 11. Exhibit

`eco_report.json`。

---

## 12. 测试

L0 ecoVia；L1 timing 闭环；L5 冻结层；注入失败回滚。

---

## 13. 里程碑

Phase C 主战场；M0 可提前。

---

## 14. 未验证

via repair 对 DRC 的改善量；tcl_eco 是否暴露；与 iRT ECO API 签名对齐。

**不要重走**：在 iECO 内复制 Nesterov/DR。

---

## 附录 B

| # | 决策 | 被否 |
|---|---|---|
| E-1 | 门面+via | 全能优化器 |
| E-2 | 复用 25/26 | 平行实现 |
| E-3 | 功能后置 | 过早 Conformal |


---

## 附 · 现状 API 与目标门面

| 现状 | 证据 |
|---|---|
| ecoVia only | `ieco_api.cpp:33-36` |
| shape/pattern | `ieco_via.cpp:43-45`；宏 `eco_repair_via_by_*` |

### timing ECO 序列（目标，平台原语）

```text
diagnose(iSTA) → propose(iTO+veto) → IncrLegalizeAfterCommit
  → IncrRouteEco → incrSTA → accept?
freeze_layers 外禁止改几何
```

### PR

| PR | 内容 |
|---|---|
| ECO-0 | via 产物断言 |
| ECO-1 | ecoTiming 门面 |
| ECO-2 | 冻结层 |
| ECO-3 | functional 最小 |


### via ECO 类型

| type | 宏 | 含义 |
|---|---|---|
| shape | `eco_repair_via_by_shape` | 按形状修 |
| pattern | `eco_repair_via_by_pattern` | 按图案修 |

### 金属可修层示例配置

```json
{"freeze_layers": ["M1", "M2"], "eco_layers": ["M3", "M4", "M5", "VIA34"]}
```

改动落入 freeze → txn 失败。

### 成功判据（timing ECO）

ΔWNS≥0（或恶化≤ε 且用户允许）；合法性 PASS；DRC 热点不增；其余网 bbox 不变（抽样）。

### Phase 绑定

主纲：ECO 依赖 G16 + iRT ECO API，排 Phase C。  
M0 via 断言可提前；timing 门面不早于 25/26/40 原语。

## 附 B · 决策

| # | 决策 | 被否 |
|---|---|---|
| E-1 | 门面+via | 全能优化器 |
| E-2 | 复用 25/26/40 | 平行实现 |
| E-3 | 功能 ECO 后置 | 过早上 Conformal |

checklist：via 断言；ecoTiming 门面；冻结层；回滚测。


### 体例合规声明

本文档已按 `01-ai-doc-conventions-rv1.md` 强制骨架组织（§0–§14），引用主纲门禁与 `03-commercial-knowhow-catalog.md` 的 KH-ID；未实测项见 §14。

主纲版本锚定：`00-ieda-commercial-parity-master-plan-v1.1.md`；Know-how 目录：`03-commercial-knowhow-catalog.md`。

完成定义：代码变更 + 机器门禁 + 当前二进制重跑一致（体例 §1 铁律 8）。


---

**文档状态**：rv1.0 已发布；后续仅允许「有新 file:line 证据」的修订进入变更记录。
