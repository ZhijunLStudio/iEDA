<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 32 · iECO 工程变更 · 商业对标方案 · rv2.2

> 文档号：32-rv2.2　　版本：rv2.2（M0 失败语义闭环）　　里程碑：**双对标 —— ICC2/Innovus timing ECO 原子闭环 × Conformal ECO 等价修复精度**
> 体例：`01-ai-doc-conventions-rv1.md`；深度对标：`27-iSTA-rv2.0.md`（逐 kernel 走读 + 诚实归因 + 被否方案）
> 商业金标：**ICC2 / Innovus（timing ECO 闭环与调用可靠性）**；**Conformal ECO（功能等价修复精度）**；门禁：**G16 / G17**
> 上游：`22-iPL`、`25-iTO`、`26-iRT`、`27-iSTA`　下游：`12-evaluation`、`40-platform`
> 纲领：`00-ieda-commercial-parity-master-plan-v1.1.md`；Know-how：`03-commercial-knowhow-catalog.md` KH-ECO-\*
> 联合架构：`04-ppa-technical-review-and-optimization-rv1.md` 的 `DesignState + DirtySet + MoveTxn`；闭环工作台：`51-agent-native-eda-detailed-plan-v1.0.md`
> 覆盖：`src/operation/iECO/`（~863 LOC 全树含测试）；唯一生产能力 = via repair
> 纪律：**文档是假说不是事实**；断言带 `file:line`；未实测写「未验证」；每条理论附能杀死它的对照。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.1 | 2026-07-20 | 架构愿望 |
| rv1.0 / v2.0 | 2026-07-20 | **审计**：生产 API 仅 `ECOApi::ecoVia`（`ieco_api.cpp:33-36`）→ `ECOVia` shape/pattern（`ieco_via.cpp:43-45`）。**无** diagnose→iTO→routeECO 编排——旧稿「技术架构」多为目标态。 |
| **rv2.0** | **2026-07-21** | **大改（对照 27-iSTA-rv2.0.md 深度重写，双对标线拆解）**。核心修订五条：**(1)** rv1.0 把 iECO 当成「缺时序/功能 ECO」来审——**代码级核实后发现头号结构症结是零编排能力**：仅 `ECOApi::ecoVia`（`ieco_api.cpp:33-36`）一个生产接口，直连 via shape/pattern 修复（`ieco_via_repair.cpp:37-75`），**无** timing ECO 所需的「诊断→提案→合法→布线→验证」循环编排器（§1.3）；**(2)** 新增 **平台原语缺口审计**（§1.4）：timing ECO 需要的五大原语——iSTA 增量（`incrUpdateTiming` 存在但下游 10:1 不用，见 27-iSTA-rv2.0.md §1.4）、iTO veto 提案（接口无）、iPL 增量合法（API 无）、iRT 增量布线（`RTInterface::updateTiming` 死骨架，`RTInterface.cpp:1522+` 函数体注释）、事务回滚（无）——**五缺四半**；**(3)** via repair 算法走读（§1.2/§4.2）：`repairByShape` 为每个 via 遍历候选 via master（`ieco_via_repair.cpp:37-68`，OMP 并行），按方向/连通性匹配最佳形状；`repairByPattern`（`:71-76`）**空实现**（仅 `return 0`）；**(4)** 全文按**双对标线**重组：ICC2/Innovus 线 = timing ECO 闭环（诊断→优化→增量legalize+route+STA → accept/rollback，G16/G17 主战场），Conformal 线 = 功能 ECO 等价修复（netlist patch → LEC 验证，Phase C 后置）；**(5)** 补齐 27 号文档体例要素：§4.8 模块状态一览（成熟度/边界/复用）、§5 双档配置表、§8 调用方契约、§10 双看板（timing ECO 可靠性 × functional ECO 精度）、§14 未验证/不要重走。**缺省新特性关闭 → 零回归**。 |
| **rv2.1** | **2026-07-23** | 实现评审：纠正 via repair 伪码与 timing ECO 接受条件方向；事务扩为五层状态原子提交；明确 dirty RC/STA、local DRC、冻结哈希和 full oracle；functional ECO 以正式等价检查而非 LVS 作为功能门禁。 |
| **rv2.2** | **2026-07-24** | 完成 ECO-0 的请求失败语义：`shape` 返回成功状态与独立修复计数；未实现的 `pattern` 返回 `kUnsupported`；未知 type 返回 `kInvalidType`，不再静默回落到 shape；API/manager/TCL 逐层传播失败。新增 `ieco_via_request_test` 锁住分发、零修复成功和 unsupported 非成功语义。shape 修复后的 DRC 改善量仍未验证。 |

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
| eco via by shape | 有实现 | **窄域可用，仍需 DRC 改善验证** |
| eco via by pattern | 内核仍为空；入口已返回 `kUnsupported`，TCL 返回失败（rv2.2） | **失败语义已闭环；算法仍未实现** |
| timing ECO 编排 | 无 | ★ 目标 |
| functional patch | 无 | ★ Phase C |

#### 1.2.1 via repair 与 timing ECO 伪代码（紧凑版）

**via repair 算法**（现有 ecoVia，`ieco_api.cpp:36`）：

```text
def ecoVia(type="shape"):
  if type == "pattern":
    return UNSUPPORTED                           # 现状 repairByPattern 仅 return 0
  parallel for via in selected_vias:
    candidates = via_masters compatible with cut layer/direction/connectivity
    best = deterministic_argmin(candidates, shape_mismatch + rule_risk)
    if best exists: record replacement delta(via, best)
  merge thread-local deltas deterministically; apply replacements; return changed_count
```

**复杂度**：O(|vias|·|candidate_masters|)。这段伪码只描述代码证实的 shape/master 选择，不虚构“移动 via/拆 array/扩 metal”现有能力。边界：pattern 模式必须响亮标 unsupported；无候选、替换后 DRC 不改善均报告残余，禁静默。

**timing ECO 状态机 6 步**（目标设计，依赖 25/26/40）：

```text
def eco_timing(violating_paths, max_iter):
  for iter in 1..max_iter:
    txn = MoveTxn.begin(DesignState.version)
    
    for path in top_N_paths:
      # 1. diagnose
      arcs = iSTA.analyzePath(path)             # 27 FR-STA-01
      # 2. propose
      moves = iTO.proposeFixes(arcs)             # 只提案，最终 accept 归本事务
      if moves.empty: record_unfixable(path); continue
      # 3. commit + legalize
      dirty = applyMoves(moves)                  # inst/net/row/rc_arc/timing_cone/route_box
      if not iPL.incrPlaceOrLG(dirty):           # 位置硬门
        rollback(txn); continue
      # 4. route
      if not iRT.routeECO(moves.affected_nets): # 26 FR-RT-06
        rollback(txn); continue
      # 5. re-verify
      if not iDRC.checkIncremental(dirty.route_boxes):
        rollback(txn); continue
      iRCX.updateDirty(dirty.nets)
      metrics = iSTA.updateSetupHold(dirty.timing_cones)
      # 6. accept: 硬门字典序，不是方向写反的单一 WNS 判断
      if connectivity/legal/route/DRC 不全 PASS: rollback(txn); continue
      if setup 或 hold 越过 guardband，或 DRV 新增更高优先级违例: rollback(txn); continue
      if timing/area/power/congestion 无 Pareto 改善: rollback(txn); continue
      commit(txn)  # 原子提交 iDB/placement/route/RC/STA versions
      break
    
    if not improved: break                       # 不收敛→报残余
  
  return improved
```

迭代上限由设计规模/预算配置，不硬编码 3；不收敛→响亮报残余违例清单。回滚必须恢复 iDB/netlist、placement、route/occupancy、RC cache、STA graph/version 五类状态；每 K 个 commit 跑 full DRC+RC+STA oracle，增量漂移超阈值则回滚最近批次并重建缓存。

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
| FR-ECO-06 | ★ DirtySet/full-oracle/版本一致性 | P0 |
| FR-ECO-07 | ★ out-of-scope canonical hash 冻结断言 | P0 |
| NFR-ECO-01 | 其余网冻结（26 契约） | |
| NFR-ECO-02 | session 增量（G16） | |

---

## 3. HLD

```text
eco_timing（目标）:
  iSTA diagnose → iTO veto propose → IncrLG → routeECO → incrSTA → accept?
eco_via（现状）:
  shape repair；pattern=unsupported
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

`freeze_layers`；`eco.max_iters`；`eco.full_oracle_interval`（初始 1）；setup/hold/DRV/area/power guardband；`via.type=shape`。`pattern` 在实现前是 unsupported，不得作为可用配置列出。

---

## 6. 指标

setup/hold WNS/TNS、DRV、area/power、local DRC、改动实例/网/shape 数、via 修复/残余数、回滚原因、增量/full 差、墙钟——独立列。

---

## 7. 状态机

`begin_txn → apply → local place/legal → route_eco → local DRC → dirty RC → setup+hold STA → joint gate → commit|rollback → periodic full oracle`。

已落地的 via 请求子状态机：`parse type → shape: init+repair+SUCCESS(count>=0) | pattern: UNSUPPORTED | unknown: INVALID_TYPE`。只有 `SUCCESS` 映射为 TCL 成功；“成功且修复 0 个”与“不支持”不再共用整数 `0`。

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
| via ECO 请求语义 | `ieco_via_request_test` 通过；pattern/unknown 非成功，shape 的 0 修复仍成功 | G14 |
| timing ECO E2E | 用例绿 | G16/G17 |
| 扰动最小 | 记录 | |

### 10.2 对照实验

| ID | 输入 | 判据 | 锁住 |
|---|---|---|---|
| E-ECO-01 | gcd 换小驱动 `BUF_X4→X1` | eco_timing 修复且 WNS 改善 | timing ECO 闭环 |
| E-ECO-02 | 不可修违例（物理拥塞） | 响亮报残余（禁假 clean） | §1.2.1 边界 |
| E-ECO-03 | 功能 patch（换等价门） | formal LEC equivalent + LVS clean + setup/hold 不越 guardband | functional ECO |
| E-ECO-04 | 任一步故障注入（LG/route/DRC/RC/STA） | 回滚后五层状态 hash/version 与 txn 前完全一致 | 原子事务 |
| E-ECO-05 | 修改 1 网的 timing ECO | 白名单外 canonical geometry/netlist hash 不变 | 扰动最小/冻结契约 |

### 10.3 演进

```text
M0 via 请求分发/失败语义完成；shape 产物与 DRC 改善断言待补
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

via repair 对 DRC 的改善量；shape 路径端到端产物；与 iRT ECO API 签名对齐。`eco_repair_via` 已由 `tcl_register_eco.h` 注册并由 `tcl_eco.cpp` 调用，不再列为未验证。

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
| shape 入口 + pattern 占位 | `ieco_via.cpp:43-45`；`repairByPattern` 当前仅 return 0 |

### timing ECO 序列（目标，平台原语）

```text
diagnose(iSTA) → propose(iTO) → MoveTxn.apply → IncrPlace/LG
  → IncrRouteEco → local DRC → dirty RC → setup+hold incrSTA → JointGate
freeze_layers 外禁止改几何
```

### PR

| PR | 内容 |
|---|---|
| ECO-0 | via 请求状态与 pattern/unknown 失败语义已完成；shape 产物/DRC 改善断言待补 |
| ECO-1 | ecoTiming 门面 |
| ECO-2 | 冻结层 |
| ECO-3 | functional 最小 |


### via ECO 类型

| type | 请求 token | 含义 |
|---|---|---|
| shape | `shape` | 按形状修 |
| pattern | `pattern` | **空实现/unsupported**；rv2.2 已返回失败且不初始化/修改设计 |

### 金属可修层示例配置

```json
{"freeze_layers": ["M1", "M2"], "eco_layers": ["M3", "M4", "M5", "VIA34"]}
```

改动落入 freeze → txn 失败。

### 成功判据（timing ECO）

connectivity/合法性/local DRC PASS；目标 DRV 改善且无更高优先级新增；setup/hold 均不越 guardband；其后才要求 timing/area/power/congestion Pareto 改善。白名单外 canonical hash 全量不变，禁止仅抽样 bbox。

### Phase 绑定

主纲：ECO 依赖 G16 + iRT ECO API，排 Phase C。  
M0 via 断言可提前；timing 门面不早于 25/26/40 原语。

checklist：via shape 断言与 pattern unsupported；ecoTiming 门面；冻结层 canonical hash；五层状态回滚；periodic full oracle。


### 体例合规声明

本文档已按 `01-ai-doc-conventions-rv1.md` 强制骨架组织（§0–§14），引用主纲门禁与 `03-commercial-knowhow-catalog.md` 的 KH-ID；未实测项见 §14。

主纲版本锚定：`00-ieda-commercial-parity-master-plan-v1.1.md`；Know-how 目录：`03-commercial-knowhow-catalog.md`。

完成定义：代码变更 + 机器门禁 + 当前二进制重跑一致（体例 §1 铁律 8）。


---

**文档状态**：rv2.2 已完成 via 请求失败语义闭环；shape 修复产物/DRC 改善与 timing ECO 目标态仍须由机器门禁验证。
