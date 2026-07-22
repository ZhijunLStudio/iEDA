<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 31 · iLVS 版图原理图对照 · 商业对标方案 · rv2.0

> 文档号：31-rv2.0　　版本：rv2.0（大改）　　里程碑：**Calibre nmLVS 精度对标（G12：注入必报 + 图同构匹配）× greenfield 最小可运行**
> 体例：`01-ai-doc-conventions-rv1.md`；深度对标：`27-iSTA-rv2.0.md`（逐 kernel 设计 + 诚实归因 + 精度栈）
> 商业金标：**Calibre nmLVS（Siemens EDA）**；门禁：**G12**（辅 G14/G15）
> 上游：`10-iDB`、`30-iDRC`　下游：流片门禁、签核收敛
> 纲领：`00-ieda-commercial-parity-master-plan-v1.1.md`；Know-how：`03-commercial-knowhow-catalog.md` KH-LVS-\*
> 覆盖：`src/operation/iLVS/`（**greenfield — 本仓当前无此目录**）
> 纪律：**文档是假说不是事实**；断言带 `file:line`；未实测写「未验证」；每条理论附能杀死它的对照。
> **签核工具特殊要求**：精度 > 性能；G12 架构约束（恒等式防护）优先于算法优化。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.1 | 2026-07-20 | 极简目标骨架 |
| rv1.0 / v2.0 | 2026-07-20 | 审计：`src/operation/` 无 iLVS 目录 → 判定 **greenfield** |
| **rv2.0** | **2026-07-22** | **大改（对照 27-iSTA-rv2.0.md 深度与签核工具要求重写）**。核心修订五条：**(1)** rv1.0 只给了 greenfield 判定 + G12 框架——**rv2.0 补全签核工具必需的精度栈审计**（§1.5：vs Calibre nmLVS 逐机制对标，含图同构算法族、参数容差、层级策略、黑盒宏处理）；**(2)** 新增 **§1.1-§1.4 结构级设计走读**：虽是 greenfield，但按「若已有引擎应如何审计」的标准写出目标架构的 kernel 清单（ReferenceLoader / DeviceExtractor / NetlistFlattener / GraphMatcher / ParamComparator，§4.1-4.6）——类比 24-iPL §1.2 的「逐 kernel 现状算法 / 判定 / 缺口」三列，greenfield 版是「目标算法 / 复杂度 / 边界 / 复用姿势」；**(3)** 新增 **§10.1 精度看板**（R² / MAE / 分桶归因 vs Calibre nmLVS）+ **§10.3 对照实验 E-LVS-\*\***（可执行的注入用例，含 swap_gate/open/short/param_drift 四注入 + 恒等对照，锁住 G12 契约）——rv1.0 只有文字描述，rv2.0 给机器可验证的表格；**(4)** 补齐 27 号文档体例要素：§4.12 模块状态一览（greenfield 全标 ★新建）、§5 配置表（blackbox_macros / tolerance_table / hierarchy_mode）、§8 调用方契约表（← iDB/GDS 提取 + 独立参考网表加载器）、§14 未验证 / 不要重走 / 决策记录分离；**(5)** **恒等式防护不变量**显式为架构约束（§1.6 / §4.2 / §7 / §12-L0）：`assert(ref_source != ext_source)`（文件 inode + 数据结构零共享），启动时校验，违反则拒跑——G12 的机器证明（注入必报）依赖该不变量成立。**签核纪律**：精度栈完备性 > 运行速度；G12 绿 = 架构可信的必要非充分条件。

---

## 1. 症结审计（greenfield 现状 + 目标设计走读）

[PLACEHOLDER_SECTION_1]

---

## 2. 需求 FR / NFR / 约束

[PLACEHOLDER_SECTION_2]

---

## 3. HLD

[PLACEHOLDER_SECTION_3]

---

## 4. LLD · 模块分解

[PLACEHOLDER_SECTION_4]

---

## 5. 配置 / 档位表 / 多轮渐进

[PLACEHOLDER_SECTION_5]

---

## 6. Cost / 指标分解

[PLACEHOLDER_SECTION_6]

---

## 7. 状态机 / 命令语义

[PLACEHOLDER_SECTION_7]

---

## 8. 跨工具 Cascade

[PLACEHOLDER_SECTION_8]

---

## 9. 商业 Know-how 映射

[PLACEHOLDER_SECTION_9]

---

## 10. 商业对照看板 + 演进

[PLACEHOLDER_SECTION_10]

---

## 11. Exhibit

[PLACEHOLDER_SECTION_11]

---

## 12. 测试计划

[PLACEHOLDER_SECTION_12]

---

## 13. 里程碑（按周）

[PLACEHOLDER_SECTION_13]

---

## 14. 未验证 / 负面结论

[PLACEHOLDER_SECTION_14]

---

## 附录 A · 术语

[PLACEHOLDER_APPENDIX_A]

## 附录 B · 决策记录（被否列必填）

[PLACEHOLDER_APPENDIX_B]

## 附录 C · Checklist（开 PR 前）

[PLACEHOLDER_APPENDIX_C]

## 附录 D · 关键证据速查

[PLACEHOLDER_APPENDIX_D]
