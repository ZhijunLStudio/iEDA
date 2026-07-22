<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 33 · iLO / iTM 逻辑优化与工艺映射 · 商业对标方案 · rv2.0

> 文档号：33-rv2.0　　版本：rv2.0（大改）　　里程碑：**双对标 —— DC/Genus 签核精度（G7/G18：QoR R²>0.95）× 综合速度（编译时间 ≤ 1.5× 商业工具）**
> 体例：`01-ai-doc-conventions-rv1.md`；深度对标：`27-iSTA-rv2.0.md`（逐 kernel 走读 + 诚实归因 + 被否方案）
> 商业金标：**Design Compiler / Genus（签核 QoR 准确性）**；**综合速度（工业可用性）**；门禁：**G7 / G12 / G14 / G15 / G18**
> 上游：RTL/Verilog　下游：`21-iNO`、`22-iPL`、`12-evaluation`、`27-iSTA`
> 纲领：`00-ieda-commercial-parity-master-plan-v1.1.md`；Know-how：`03-commercial-knowhow-catalog.md` KH-SYN-\*
> 覆盖：`src/operation/iLO/`（逻辑优化）、`src/operation/iTM/`（工艺映射）—— **现状：仅 CMakeLists.txt，空壳 greenfield**
> 纪律：**文档是假说不是事实**；断言带 `file:line`；未实测写「未验证」；每条理论附能杀死它的对照。**签核可信度 > 性能**。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.1 | 2026-07-20 | 分层愿望 |
| rv1.0 / v2.0 | 2026-07-20 | 审计：`src/operation/iLO/` 与 `iTM/` **均仅 CMakeLists.txt**——**空壳 greenfield**。禁止未审计宣称综合商业对标。 |
| **rv2.0** | **2026-07-22** | **大改（对照 27-iSTA-rv2.0.md 的深度与丰富度重写，逻辑综合工具特有精度栈）**。核心修订五条：**(1)** rv1.0 仅记录「空壳」事实——**rv2.0 补齐假设实现后的完整审计框架**：逐 kernel 应有架构（technology mapping / logic rewrite / area recovery / timing-driven / multi-Vt / physical-aware）+ 每个 kernel 的「算法骨架 / 复杂度 / 与 DC/Genus 的差距机制」三列（§1.2-§1.7，类比 27 号 §1.2 对已有代码的逐行走读，但本文档是对**应建未建**模块的架构预审）；**(2)** 新增 **精度栈逐项审计**（§1.5）：逻辑综合的签核可信度来自库映射精度（NLDM/CCS 表插值 + 多 corner）、逻辑优化完备性（AIG/technology-independent optimization）、时序驱动（STA 接口 + slack-driven gate sizing/buffering）、多 VT Pareto（setup-critical→LVT，非关键→HVT）、物理感知（congestion/wirelength 估计回灌）——逐项对 DC/Genus 机制清单，明确「有/缺/半成品」三态；**(3)** 全文按**双对标线**重组：DC/Genus 线 = 签核精度栈（QoR R²、面积/延迟/功耗分桶归因 → G7/G18），速度线 = 编译时间 ≤ 1.5× 商业工具（工业可用性 → G12），§10 拆成两块看板；**(4)** 补齐 27 号文档体例要素：§4.12 模块状态一览（成熟度 [空壳] / 复杂度 / 边界 / 复用姿势）、§5 双档配置表（快速综合 vs 签核综合）、§8 调用方契约表（iNO 边界 / iPL 物理反馈）、§10.3 对照实验（E-SYN-XX，能杀死假说）、§14 未验证/不要重走/兄弟仓库发现；**(5)** **逻辑综合特殊纪律**：签核可信度 > 性能（G7/G12/G14/G15 门禁优先于 G18 速度门禁）、禁止把 iNO（fanout 修复）当综合、禁止无基线曲线即宣称打平、多 VT 映射必须有单调性测试（全 LVT vs 混合 VT 的延迟-漏电 Pareto 扫描）。**缺省新特性关闭 → 零回归**（ABC 挂载 / 物理感知 / 多 VT 均显式可配）。 |

---

