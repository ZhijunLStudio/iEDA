<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 32 · iECO 工程变更 · 商业对标方案 · rv1.0

> 文档号：32-rv1.0　　版本：v2.0　　里程碑：**via ECO 真路径审计 → 时序 ECO E2E（iTO+iRT incr）→ 功能 ECO 最小**
> 体例：`01-ai-doc-conventions-rv1.md`　门禁：G16/G17　Know-how：KH-ECO-01/02、KH-X-03
> 对标：**ICC2 eco / Conformal（功能）**
> 覆盖：`ieco_api.cpp:33-36` `ecoVia`；`eco_via/*`（shape/pattern repair）；**非**完整 timing/functional ECO 编排器

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.1 | 2026-07-20 | 架构愿望 |
| **rv1.0 / v2.0** | **2026-07-20** | **审计**：生产 API 仅 `ECOApi::ecoVia`（`ieco_api.cpp:33-36`）→ `ECOVia` shape/pattern（`ieco_via.cpp:43-45`）。**无** diagnose→iTO→routeECO 编排——旧稿「技术架构」多为目标态。 |

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

| # | 决策 | 被否 |
|---|---|---|
| D1 | iECO=编排门面+via | 重写 iTO/iRT |
| D2 | 平台三原语强制 | 脚本自觉 |
| D3 | 功能 ECO 后置 | Phase A 上 Conformal 级 |

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

对照：冻结层被改必失败；关 veto 看回退；其余网坐标不变。

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
