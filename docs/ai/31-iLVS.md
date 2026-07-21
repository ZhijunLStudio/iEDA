<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 31 · iLVS 版图原理图对照 · 商业对标方案 · rv1.0

> 文档号：31-rv1.0　　版本：v2.0　　里程碑：**非恒等式最小可跑 + G12 注入必报 → 真实比对 → Calibre 子集**
> 体例：`01-ai-doc-conventions-rv1.md`　门禁：**G12**　Know-how：KH-LVS-01/02、KH-X-04
> 对标：**Calibre nmLVS**
> 主纲诚实声明：本仓可能 **greenfield/空壳**——parity 目标成立，但禁止假装已有完整工具。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.1 | 2026-07-20 | 极简目标 |
| **rv1.0 / v2.0** | **2026-07-20** | **审计**：`src/operation/` **无 iLVS 目录**（对比 iECO/iDRC 等）；`find *lvs*` 无生产引擎——判定为 **greenfield**。方案以「最小可运行+G12」为 M1，不以虚构代码当现状。 |

---

## 1. 症结审计

| ID | 症结 | 证据 | P |
|---|---|---|---|
| L1 | 无 `src/operation/iLVS` 引擎 | 目录缺失 | P0 |
| L2 | 恒等式风险（若用同一网表双侧） | 主纲 G12 / KH-LVS-01 | P0 |
| L3 | 无注入差异测试 | — | P0 |
| L4 | 无 mismatch 机读报告 | — | P1 |

### 1.2 形态判定

| 项 | 判定 |
|---|---|
| 功能 | **空/未落地** |
| 算法 | 纸面：提取图 ↔ 参考图同构/匹配 |
| 边界 | 必须以独立 ReferenceLoader 为红线 |

### 1.3–1.4

跨工具：依赖 iDB/GDS 提取与独立 Verilog/CDL；平台 session 末段调用。

---

## 2. 需求 FR / NFR

| ID | 需求 | P |
|---|---|---|
| FR-LVS-01 | ★ 目录+API 骨架 `run_lvs` | P0 |
| FR-LVS-02 | ★ 独立 ReferenceLoader（≠版图源） | P0 |
| FR-LVS-03 | ★ G12 三注入：swap_gate/open/short → 非 clean | P0 |
| FR-LVS-04 | mismatch JSON | P1 |
| FR-LVS-05 | vs Calibre 子集 | P2 |
| NFR-LVS-01 | 恒等路径启动失败 | G12 |
| NFR-LVS-02 | greenfield 阶段不宣称签核 | |

---

## 3. HLD

```text
RefNetlist (Verilog/CDL 独立加载)
  ≠ ExtractedNetlist (版图/DEF 器件识别)
compare → devices/nets/params mismatches → JSON
注入测试钩子（CI）
```

| # | 决策 | 被否 |
|---|---|---|
| D1 | 先 stub+G12 | 先写完备引擎再测 |
| D2 | 参考路径强制独立 | 同文件双侧 |
| D3 | 标准单元可黑盒策略可配 | 强制晶体管级 |

---

## 4. LLD（压缩）

```text
M1 stub:
  load_ref(path_ref); load_ext(path_ext);
  assert path_ref != path_ext (inode/hash)
  run_compare_or_stub_fail
  inject_tests in CI
M2: 器件识别 + 名称/图匹配 + 容差表
```

模块状态：全部 ★新建。

---

## 5. 配置

`lvs.ref_netlist`/`lvs.extracted` 必填且校验不同源；`blackbox_macros=true`。

---

## 6. 指标

mismatch 计数分桶；注入检出率=100%；墙钟次要。

---

## 7. 状态机

`init → load_ref → load_ext → compare → report`；恒等配置 → rc≠0。

---

## 8. Cascade

← iDB/GDS；← 综合/网表金参考；→ 流片门禁；与 30 签核分层。

---

## 9. Know-how

KH-LVS-01 参考独立；KH-LVS-02 注入必报。

---

## 10. 看板 + M0–M4

| 指标 | 门槛 | G |
|---|---|---|
| 注入非 clean | 100% | G12 |
| 恒等拒跑 | 是 | G12 |
| vs Calibre | 子集解释 | 后 |

对照：同文件双侧必拒；swap 一门必报；空实现假 clean 必杀。

```text
M0 存在性审计（本版完成）
M1 stub+独立加载+G12 三注入
M2 真实比对报告
M3 签核子集
M4 Calibre 对齐
```

---

## 11. Exhibit

`lvs_report.json`、注入用例日志。

---

## 12. 测试

L0 恒等拒跑；L0 三注入；L1 小设计；L5 无引擎不得 G12 PASS（除非 stub 测绿）。

---

## 13. 里程碑

Phase A：M1；引擎填空随资源。

---

## 14. 未验证

是否有外部仓库 iLVS；提取策略（CDL vs 单元级）。

**不要重走**：用「DEF 对比 DEF」冒充 LVS。

---

## 附录 B

| # | 决策 | 被否 |
|---|---|---|
| E-1 | greenfield 诚实 | 假装有工具 |
| E-2 | G12 先于完备引擎 | 引擎完再测 |
| E-3 | 参考独立硬校验 | 约定靠自觉 |


---

## 附 · greenfield 证明与 G12 最小实现

```text
ls src/operation/ → 无 iLVS/
主纲附录 B：iLVS 可能 greenfield —— 本审计确认
```

### G12 三注入规格

| 注入 | 操作 | 期望 |
|---|---|---|
| swap_gate | 参考网表交换两门输出 | mismatch ≥1 |
| open | 断开一网 | mismatch |
| short | 合并两网 | mismatch |

参考与提取 **文件哈希必须不同**；相同 → 启动失败。

### PR

| PR | 内容 |
|---|---|
| LVS-0 | 目录/API 骨架 |
| LVS-1 | 独立加载+哈希校验 |
| LVS-2 | 三注入 CI |
| LVS-3 | mismatch JSON |


### 最小目录落点（M1）

```text
src/operation/iLVS/
  api/ilvs_api.*
  source/ReferenceLoader.*
  source/Extractor.*   # 可先 stub 读 DEF 单元级
  source/Comparer.*
  test/inject_g12.*
```

### 黑盒策略

大宏 / SRAM：参考与提取均作黑盒端口匹配，避免未建模晶体管导致恒假 fail；策略必须写入报告。

### 与 30/10 关系

几何真源来自 iDB/GDS（10 二进制后）；DRC clean ≠ LVS clean。

### 门禁 G12 原文对齐

参考网表独立；注入差异必非 clean；greenfield 时本门禁=最小可运行+注入测。  
本文件 M1 即该「最小」定义。

## 附 B · 决策

| # | 决策 | 被否 |
|---|---|---|
| E-1 | greenfield 诚实 | 假装有 LVS |
| E-2 | G12 先于完备引擎 | 引擎完再测 |
| E-3 | 参考独立硬校验 | 靠自觉 |

checklist：骨架 API；哈希校验；三注入；mismatch JSON。


### 体例合规声明

本文档已按 `01-ai-doc-conventions-rv1.md` 强制骨架组织（§0–§14），引用主纲门禁与 `03-commercial-knowhow-catalog.md` 的 KH-ID；未实测项见 §14。

主纲版本锚定：`00-ieda-commercial-parity-master-plan-v1.1.md`；Know-how 目录：`03-commercial-knowhow-catalog.md`。

完成定义：代码变更 + 机器门禁 + 当前二进制重跑一致（体例 §1 铁律 8）。


---

**文档状态**：rv1.0 已发布；后续仅允许「有新 file:line 证据」的修订进入变更记录。
