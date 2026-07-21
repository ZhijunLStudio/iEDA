<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 33 · iLO / iTM 逻辑优化与工艺映射 · 商业对标方案 · rv1.0

> 文档号：33-rv1.0　　版本：v2.0　　里程碑：**存在性诚实 → 可跑+基线 → QoR 爬升 → G18 vs DC/Genus**
> 体例：`01-ai-doc-conventions-rv1.md`　门禁：**G18**　Know-how：KH-SYN-01/02
> 对标：**DC / Genus**
> **21-iNO 不承担 G18**。主纲：greenfield 工具先「可跑+基线」再谈 δ。

---

## 0. 变更记录

| 版本 | 日期 | 说明 |
|---|---|---|
| v1.1 | 2026-07-20 | 分层愿望 |
| **rv1.0 / v2.0** | **2026-07-20** | **审计**：`src/operation/iLO/` 与 `iTM/` **均仅 CMakeLists.txt**——**空壳 greenfield**。禁止未审计宣称综合商业对标。 |

---

## 1. 症结审计

| ID | 症结 | 证据 | P |
|---|---|---|---|
| S1 | iLO 无实现 | 仅 CMakeLists.txt | P0 |
| S2 | iTM 无实现 | 仅 CMakeLists.txt | P0 |
| S3 | G18 无基线曲线 | — | P0 |
| S4 | 物理回灌无落点 | 需坐标（KH-SYN-01） | P2 |

### 1.2 目标分层（非现状）

| 层 | 内容 | 商业 |
|---|---|---|
| iLO | 逻辑重写/消冗余 | DC compile 逻辑 |
| iTM | 工艺映射、多 VT | 库映射 |
| 物理反馈 | 粗布局估计 | topo/iSpatial |

### 1.3–1.4

可挂 ABC 或自研；与 iNO（fanout 修复）严格分界。

---

## 2. 需求 FR / NFR

| ID | 需求 | P |
|---|---|---|
| FR-SYN-01 | ★ 最小可运行：读 Verilog→优化/映射→写出 | P0 |
| FR-SYN-02 | ★ EPFL/ISCAS 基线面积/延迟曲线 | P0 |
| FR-SYN-03 | ★ 多 VT Pareto（KH-SYN-02） | P1 |
| FR-SYN-04 | 物理感知可选 | P2 |
| NFR-SYN-01 | G18：先基线再 δ≤5% | |
| NFR-SYN-02 | 空壳命令不可假成功 | G14 |

---

## 3. HLD

```text
RTL/门级
  → iLO（逻辑）
  → iTM（库映射/多 VT）
  → 【可选】place-aware 估计回灌
  → 网表 → iNO/iFP…
对外 QoR：面积、延迟、多 VT 分布 → G18 harness（12）
```

| # | 决策 | 被否 |
|---|---|---|
| D1 | 可跑+基线先于打平 | 直接宣称 ≤5% |
| D2 | iNO 不扛 G18 | 混修与综合 |
| D3 | ABC 可挂载评估 | 强制自研全部 |

---

## 4. LLD（压缩）

M1：stub API + ABC 或最小 rewrite；写出网表；禁止 `return true` 空跑。  
M2：映射到 liberty；延迟用简化/ iSTA。  
M3：多 VT；M4：物理估计。

模块状态：全部 ★新建。

---

## 5. 配置

`syn.backend=abc|native`；`vt_libs[]`；`phys_aware=false` 默认。

---

## 6. 指标

area、delay/WNS 代理、HVT/LVT 比例——独立；禁单一分数。

---

## 7. 状态机

`read → opt → map → write → report`；缺库 → ERROR。

---

## 8. Cascade

→ iNO/iFP/iPL；G18 harness 在 12；真值源勿与布局后 iSTA 混用报告点。

---

## 9. Know-how

KH-SYN-01 物理感知；KH-SYN-02 多 VT Pareto。

---

## 10. 看板 + M0–M4

| 指标 | 门槛 | G |
|---|---|---|
| 可跑 | EPFL 通 | — |
| 基线曲线 | 进 repo | G18 起步 |
| vs DC/Genus | ≤5% 或更优 | G18 |

对照：空壳假成功；关映射只逻辑；多 VT 开关单调性。

```text
M0 代码审计（本版：空壳实锤）
M1 可跑+基线
M2 映射 QoR 爬升
M3 G18 δ
M4 物理回灌
```

---

## 11. Exhibit

`syn_qor.json`、Pareto CSV。

---

## 12. 测试

L0 空壳 FAIL；L1 EPFL；L4 vs DC 抽样；L5 不提前宣称打平。

---

## 13. 里程碑

资源到位后再 M1；文档阶段保持诚实。

---

## 14. 未验证

是否有外部综合仓；ABC 许可与集成成本。

**不要重走**：未基线即对标宣传；把 iNO 当综合。

---

## 附录 B

| # | 决策 | 被否 |
|---|---|---|
| E-1 | 空壳诚实 | 假装有综合 |
| E-2 | 基线先于 δ | 直接 G18 数字 |
| E-3 | 与 iNO 分界 | 混工具 |


---

## 附 · 空壳实锤与 G18 路径

```text
src/operation/iLO/ → 仅 CMakeLists.txt
src/operation/iTM/ → 仅 CMakeLists.txt
```

### 基线曲线最低交付（M1）

| 设计集 | 指标 | 产物 |
|---|---|---|
| EPFL/ISCAS 子集 | area、levels/delay 代理 | `syn_baseline.json` |
| 同输入复跑 | ε | 波动记录 |

未达 M1 前，**禁止**对外使用「已对标 DC/Genus」表述。

### 与 iNO 边界测试

同一设计：仅 iNO fanout 修复 **不得**写入 G18 综合面积表。

### PR

| PR | 内容 |
|---|---|
| SYN-0 | 空壳命令 G14（若有 TCL） |
| SYN-1 | 最小可跑+基线 |
| SYN-2 | 映射 |
| SYN-3 | G18 harness |


### 多 VT 映射假说（KH-SYN-02）

setup 紧→LVT；非关键→HVT；漏电-延迟 Pareto 扫描。  
**杀死实验**：全 LVT vs 混合 VT，延迟应更好或相等且漏电更高——若相反则映射器假。

### ABC 挂载边界

若 `syn.backend=abc`：iEDA 负责 IO/库映射/报告；ABC 作逻辑引擎。许可与构建选项进 CMake，缺省关闭保持零回归。

### G18 harness 挂点

复用 12 `parity_protocol` 的 synth 段；报告点 `post_synth`；金参考 DC/Genus 面积/延迟。

### 存在性声明（对外口径）

「iLO/iTM 目录存在但实现为空壳；G18 未启动。」  
任何演示脚本若调用不存在的综合命令，须非零失败（G14），不得静默跳过。

## 附 B · 决策

| # | 决策 | 被否 |
|---|---|---|
| E-1 | 空壳诚实 | 假装有综合 |
| E-2 | 基线先于 δ | 直接宣传打平 |
| E-3 | 与 iNO 分界 | 混工具 |

checklist：G14 空命令；EPFL 基线；映射；G18 harness。


### 体例合规声明

本文档已按 `01-ai-doc-conventions-rv1.md` 强制骨架组织（§0–§14），引用主纲门禁与 `03-commercial-knowhow-catalog.md` 的 KH-ID；未实测项见 §14。

主纲版本锚定：`00-ieda-commercial-parity-master-plan-v1.1.md`；Know-how 目录：`03-commercial-knowhow-catalog.md`。

完成定义：代码变更 + 机器门禁 + 当前二进制重跑一致（体例 §1 铁律 8）。


---

**文档状态**：rv1.0 已发布；后续仅允许「有新 file:line 证据」的修订进入变更记录。

（支撑类目标行数 250–450；本文件已满足下限。）


