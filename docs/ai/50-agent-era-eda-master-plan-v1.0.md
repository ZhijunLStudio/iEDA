<!--
Copyright (c) 2026-2030 Southeast University
Copyright (c) 2026-2030 National Center of Technology Innovation for EDA
iEDA is licensed under Mulan PSL v2.
-->
# 50 · Agent 时代 EDA 研发总纲 · v1.1

> 日期：2026-07-23
>
> 目标：**构建 AI 原生 EDA 工具生态，支撑大模型按需调用、自演化优化、多精度协同的芯片设计流程。**
>
> 定位：**垂直工具供给方 + API/任务级服务 + 工具配置与验证底座**（收费单位仍需客户和成本数据验证）
>
> 核心逻辑：**确定性物理内核与联合门禁为底座 + AI 候选排序/调参/归因 + 同内核多 effort 档 + 全流程状态和不确定度管理**
> 约束：本文是研究与产品假说，不得放宽 `00`/`04`/`27` 的正确性、覆盖率和签核相关性门禁。
> 工程化展开：[`51-agent-native-eda-detailed-plan-v1.0.md`](51-agent-native-eda-detailed-plan-v1.0.md) 定义 Agent-native Timing Closure Lab、snapshot/delta/transaction、typed tool contract 和 90 天 backlog；与本文冲突时，以 2026-07-23 的纠偏和 `51` 的具体契约为准。

---

## 0. 战略定位与行业判断

### 0.1 核心价值主张

**传统 EDA 痛点**：
- 商用工具无法被大模型随时调用（封闭 API、授权墙）
- 无法灵活修改计算内核以适配 AI 需求
- 现有接口以人工 session 为中心，稳定的 headless API、状态/产物契约和可归因反馈不足；GUI/交互调试对问题定位仍有价值

**我方解决方案**：
- **工具形态重构**：headless API 为一等入口，GUI/TCL/Python/MCP 都作为同一事务与状态 API 的客户端
- **多 effort 引擎**：同一确定性内核提供 estimate/in-design/correlated 档；NN surrogate 是可选预筛插件
- **可编程性**：开放计算内核，支持针对特定数据集训练专用代理模型

### 0.2 行业格局预判

**三类有价值主体**：
1. **全栈自建巨无霸**（如 NVIDIA / Apple）：内部闭环，不采购外部工具
2. **工具生成平台**：提供 EDA 工具的生成、编排、评审基础设施
3. **垂直工具供给方**（我方定位）：通过 API/任务级服务提供 STA / Placement / Routing 等专用能力；按调用、资源时或订阅收费均待验证

**我方优势**：
- 已有多厂商商用 EDA license（Innovus / ICC2 / PrimeTime / StarRC / Calibre，存储于 159 服务器）
- 多工艺库（sky130 / ics55 / nangate45 / ihp130）+ 流片项目全流程数据
- iEDA 开源基座（C++20，netlist→GDS 全流程，4 次流片验证）

---

## 1. 技术架构：四大支柱

### 1.1 精度指标重构

**传统签核目标**：约束语义完整 + 数值误差受控 + 临界违例不漏报。SPICE、Liberty、PrimeTime 处于不同抽象层，不能用一个“绝对精度百分比”概括。

**AI 原生过程目标**：在保持硬约束保护的前提下，更快地找出值得精确评估的候选。排序很重要，但不是唯一精度：

- top-K precision/recall 或 NDCG@K：是否把真正关键路径排在前面。
- critical false-negative：金标 slack 低于 guardband 的路径不得漏报。
- signed bias、MAE/P95/max：防整体平移在高 `R²` 下被掩盖。
- constraint/endpoint coverage：未支持语义必须拒绝，不能靠模型补数。
- calibration/coverage/OOD abstention：模型不知道时必须回落确定性引擎。

不再使用“50%/70%/90% 精度”这类未定义数字。每个 effort 档在冻结数据集上发布 accuracy-latency curve，并由调用方按风险预算选择。

**验收指标**：M0 只记录现状，不把未经 artifact 证明的 0.6 当作事实；M1/M2 按 `04 §2.3/§6.3` 在 design-family + PDK holdout 上同时验收排序、绝对误差、临界漏报和拒答率。

### 1.2 多模型评审与置信度机制

**核心逻辑**：多模型用于估计不确定度、发现分歧和触发回落，不用于用投票“证明”物理正确。

**数学纠偏**：`1-(1-p)^N` 是“至少一个模型正确”的概率，不是多数投票正确率。5 个相互独立且准确率均为 0.7 的模型，多数投票正确率为：

```text
Σ(k=3..5) C(5,k)·0.7^k·0.3^(5-k) = 0.83692
```

现实模型共享训练数据和特征，错误相关性通常使收益更低。因此不得宣称“5 个 70% 模型得到 99% 可信度”。

**实施方案**：
1. **专家模型训练**：按 design family + PDK 切分 holdout，记录模型适用域。
2. **校准融合**：学习各模型的 calibrated probability 和误差相关矩阵，不做简单票数相加。
3. **分歧回落**：ensemble variance 高、OOD 或临界 guardband 内，一律调用确定性 STA/RC。
4. **交叉校验**：setup/hold 分开建模；模型输出不能修改 SDC exception 或跳过检查。

**技术债务清零**：
- 当前 AI 自演化瓶颈：已穷尽现有知识，无法向电容 / 电阻等物理层探索
- 解决方案：补充物理设计知识库（RC 提取 / 互连延迟模型 / 工艺参数），引导 AI 深层探索

### 1.3 按需匹配的计算引擎体系

首选“同一确定性内核的多 effort 档”，避免多套图、单位和约束语义漂移：

| 档位 | 适用阶段 | 计算 | 保护边界 |
|---|---|---|---|
| estimate | FP/GP/候选预筛 | 预估 RC、GBA、活跃场景子集、有限搜索预算 | 误差区间 + periodic exact rescore |
| in-design | DP/CTS/route/iTO | 增量 RC/STA、关键场景、CPPR | dirty cone 与 full oracle 对拍 |
| correlated | 阶段终局/parity | SPEF、完整场景、PBA/CPPR、覆盖清单 | `04 §2.3` 联合门禁 |

Liberty LUT 是标准确定性 cell-delay 基础，不应被预设为低精度慢路径；PrimeTime 类 STA 也不是“SPICE-like”仿真。轻量 NN/GNN 只有在端到端 profile 证明比 LUT/Elmore 更快、holdout 精度受控且能 OOD 拒答时，才作为 estimate 插件。

统一 API 应接收 `DesignState + ScenarioSet + AccuracyBudget + LatencyBudget`，返回 `value + uncertainty + coverage + provenance`。插件可以独立部署，但对象 ID、单位、约束解析和最终 oracle 必须共享。

### 1.4 全流程状态与归因管理

**核心能力**：
1. **帕累托点自动筛选**：
   - 对候选设计点做 PPA Pareto 筛选，减少昂贵终局评估。
   - 工艺角是约束场景，不是可以任意丢弃的 Pareto 点。过程阶段可用 active-scenario screening，但必须保守、周期性全场景复验；signoff 不得因此跳角。

2. **偏差归因系统**：
   - 保存所有工具版本 + 中间数据（路径长度 / 电容 / 电阻 / cell delay / net delay）
   - 当 iSTA 与 PrimeTime 偏差 > 阈值时，自动定位到具体计算环节

3. **核心门禁点检查**：
   - 高频迭代可优先检查关键 endpoint/dirty cone，降低反馈延迟。
   - 每 N 批、约束变化和阶段终局必须 full update；只看 Top-100 不能作为完整性证明。

---

## 2. 第一阶段目标：STA 工具为牵引（6-12 个月）

### 2.1 阶段定位

**不做**：流片签核用的最终时序分析（对标 PrimeTime）

**优先做**：逻辑综合、布局布线过程中的**实时时序评估**（对标 Innovus 内嵌 STA）

**理由**：
- 过程 STA 调用频次高（布局迭代数千次），速度比精度更关键
- 降低首个产品门槛，快速验证 AI 原生架构可行性
- 积累工具生成底座经验，为后续工具（Placement / Routing）铺路

### 2.2 技术路线图

#### Phase 0：基线建立与偏差定位（1-2 周）

**数据集**：
- SKY130 起步，但按 design family 划 train/validation/holdout；随后至少增加一个未参与调参的 PDK
- 采集维度：网表 / SDC / 布局布线结果 / 时序报告（PT 作为数值金标，Innovus 作为 in-design 调用和性能参考，iSTA 为被测）

**对比分析**：
- 提取 iSTA 中间数据：路径长度 / 电容 / 电阻 / cell delay / net delay
- 逐 endpoint/path/arc 对比 PT，按 constraint/cell/net/clock/CPPR/unmatched 定位偏差；Innovus 另测增量调用延迟
- 输出：`偏差清单.md`（按环节 / 类型 / 影响程度分类）

**验收**：
- `benchmark/qor/sta/` 存在 20 组设计的全量对比 JSON
- endpoint/constraint coverage、signed bias、MAE/P95、critical false-negative、top-K P/R 均有基线；未匹配项逐条分类

#### Phase 1：核心偏差校准（2-3 周）

**优先修复项**（按影响排序）：
1. **单位问题**：iSTA 代码中 fs/ps 注释矛盾（27-iSTA.md 已识别）
2. **RC 提取偏差**：OpenRoad 伪造的 3D RC 参数 → 替换为真实工艺文件
3. **路径长度计算**：Elmore 延迟与 Innovus 对齐

**技术方案**：
- 先修单位、SDC 语义、Liberty 插值、RC 拓扑/单位和 CPPR/PBA 等根因。
- 只有剩余误差在 design-family + PDK holdout 上稳定时，才允许有界、单调、可关闭的 residual calibrator；禁止用 `k*x+b` 掩盖 unsupported 或拓扑错误。

**验收**：
- `04 §2.3` 联合门禁逐项改善，critical false-negative 不得恶化
- 同时记录 estimate/in-design/correlated 三档 accuracy-latency curve；单一 order 数字不构成通过

#### Phase 2：多专家模型框架（1 个月）

**目标**：解决泛化性问题（当前模型在新数据集性能下滑）

**方案**：
1. 按数据集特征聚类（拥塞密度 / 时钟频率 / 面积 / 工艺节点）
2. 每类训练代理模型（输入：拓扑/布局/场景特征；输出：候选 ranking + uncertainty，不直接改 slack 真值）
3. 上层调度依据适用域选择模型；OOD/分歧/guardband 内回落确定性引擎

**验收**：
- holdout 上 top-K P/R、critical false-negative、calibration/coverage/OOD 拒答率联合通过
- 报告包含模型选择和数据搬运的端到端延迟，不能只量 NN kernel

#### Phase 3：工具生成底座初版（2 个月）

**核心能力**：
- 从需求描述生成经过 schema 校验的工具配置/流水线变体（如 clock-only 查询）；优先组合已验证模块，不默认生成新计算内核
- 确需代码生成时，静态检查、微基准、metamorphic test、差分 oracle、sanitizer 和性能/QoR 回归全部通过后才能发布

**技术实现**：
- 工具模板库：基于 iSTA 拆解出可组合的计算模块（graph build / delay calc / slack propagation）
- Code generation + verification：生成代码后自动注入已知 case，验证输出与模板一致

**验收**：
- 输入需求 → 生成 versioned config/manifest → 通过能力覆盖和回归测试；“5 分钟”先记录，不作正确性门槛
- 对固定 mutation corpus 的缺逻辑、恒返回、单位错误、漏失效均拒绝；不使用无样本定义的“虚假工具拒绝率 100%”

### 2.3 与 00-ieda-commercial-parity 的关系

**继承部分**：
- **G7（sta-correlates）**：iSTA vs PrimeTime 的联合相关性门禁（`04 §2.3`）→ 作为 Agent 时代工具的 correlated 回落档
- **27-iSTA.md 的 LLD**：PBA / MCMM / 增量契约 → 保留为高精度引擎选项
- **基础设施**：iDB / solver / platform → 复用

**差异部分**：
- 商业对齐目标是"替代 PrimeTime"（绝对精度）
- Agent 时代目标是"支撑 AI 决策"（order 精度 + 速度）
- **双轨并行**：
  - G7 继续推进（用于签核回落、金标准校准）
  - 本计划独立迭代（用于过程 STA、工具生成）

---

## 3. 工具生成底座（Honey 体系）建设

### 3.1 定义

**Honey ≠ 现成工具集合**，而是：
- 积累各类需求的实现经验（code patterns / 算法库 / 验证用例）
- 可快速基于已有版本迭代出符合新需求的工具
- 示例：已有"标准 STA" → 1 天内生成"支持 3D IC 的 TSV-aware STA"

### 3.2 核心组件

| 组件 | 功能 | 实现状态 |
|------|------|---------|
| **工具模板库** | 可组合的计算模块（iSTA / iPL / iRT 拆解） | Phase 0-1（基于 iEDA 现有代码） |
| **算法知识库** | 物理设计算法（Steiner tree / QP / A*）+ 论文实现 | 持续积累 |
| **验证用例集** | 每类工具的回归测试（含边界 case） | Phase 1 起步 |
| **代理模型训练管线** | 自动数据集聚类 + 模型训练 + 部署 | Phase 2 |
| **第三方评审门禁** | 检测生成工具是否包含真实计算逻辑 | Phase 3 |

### 3.3 扩展路径（STA 之后）

**短期（6-12 个月）**：
- iPL（布局）：多目标优化（timing / congestion / power）
- iRT（布线）：详细布线收敛 + timing-driven

**中期（1-2 年）**：
- iCTS（时钟树）：useful skew
- iTO（时序优化）：resize / buffer / VT-swap

**长期（2+ 年）**：
- 综合链（iLO / iTM）：AI 辅助逻辑优化
- 全流程仿真：EDA 领域的世界模型

---

## 4. 数据与基础设施

### 4.1 数据资产盘点

**已有**（存储于 159 服务器）：
- 商用 EDA license：Innovus / ICC2 / PrimeTime / StarRC / Calibre
- 工艺库：sky130 / ics55 / nangate45 / ihp130（git submodule）
- 流片项目数据：4 次流片的全流程数据（netlist / DEF / timing reports）

**待建**：
- **微观数据采集管线**：
  - 对接 Innovus / AI 团队，提取 net delay / cell delay / 电容 / 电阻等非宏观数据
  - 自动化采集：`run_data_collection.sh <design>` → 输出标准化 JSON
- **数据集构建原则**：
  - 不仅包含"优质设计"（低拥塞、时序干净），也要包含异常场景（高拥塞、大量违例）
  - 确保数据集覆盖真实设计的全分布

### 4.2 计算资源规划

**训练侧**：
- GPU 需求：轻量 GNN 模型训练（Phase 2）
- 资源按 Phase 0 的样本量、模型参数、吞吐和训练 profile 估算；先做单卡/小模型基线。没有 scaling curve 前不预购“8×A100×1周/每模型”

**推理侧**：
- 函数拟合：CPU 足够
- 轻量 NN：单 GPU（T4 级别）
- 确定性 STA：多核 CPU；场景级和 levelized propagation 的扩展性以 `42` 的线程曲线为准

---

## 5. 里程碑与验收

### 5.1 M0：基线建立（2 周内，截止 2026-08-05）

**交付物**：
- [ ] `benchmark/qor/sta/` 存在 20 组 SKY130 设计的 PT vs iSTA 数值对比 JSON，以及 Innovus in-design latency 报告
- [ ] `偏差清单.md`：按环节分类的偏差来源（≥20 条）
- [ ] 当前 endpoint/constraint coverage、bias、MAE/P95、critical FN、top-K P/R 和 latency：记录于 `50-agent-era-baseline.json`

**责任人**：@李兴权 + AI 自演化团队

### 5.2 M1：单数据集收敛（截止 2026-08-26）

**交付物**：
- [ ] iSTA 在 validation/holdout 上的联合门禁相对 M0 改善，critical false-negative 不回归
- [ ] 核心偏差修复清单：单位/约束/Liberty/RC/CPPR-PBA 分桶证据；residual calibrator 若使用须单独 A/B
- [ ] CI 集成：新增 STA alignment 与随机 ECO 的 incr-vs-full 测试

**门禁**：
- 修复后不得引入新回归（三 PDK 流程全绿）
- 绝对误差、覆盖率和临界漏报均卡门禁；排序不能替代这些项

### 5.3 M2：多专家模型框架（截止 2026-09-30）

**交付物**：
- [ ] 数据集聚类报告：≥3 类数据集 + 特征描述
- [ ] 每类专用代理模型：训练 + 部署脚本
- [ ] holdout 联合指标 + calibration/coverage/OOD 拒答率 + 端到端延迟

**技术债务**：
- 补充物理设计知识库（RC 提取 / 互连模型）
- 引导 AI 向电容 / 电阻层探索

### 5.4 M3：工具生成底座初版（截止 2026-11-30）

**交付物**：
- [ ] 工具模板库：iSTA 拆解为 ≥10 个可组合模块
- [ ] 配置生成管线：需求文本 → schema 化配置/manifest → 已验证模块组合
- [ ] 代码生成实验（可选）：固定 mutation corpus 的静态/动态/差分门禁

**验收用例**：
- 输入："生成仅评估 clock path 的 STA 工具"
- 输出：可执行二进制 + 回归测试通过

### 5.5 M4：扩展到第二工具（截止 2027-02-28）

**候选工具**：iPL（布局）或 iRT（布线）

**交付物**：
- [ ] 第二工具的 estimate/in-design/correlated 档；优先共享确定性内核，代理模型仅作可选 ranking
- [ ] 跨工具调用：大模型自动编排 STA + Placement 协同优化
- [ ] 商业对比：第二工具 PPA 与 Innovus / ICC2 的差距 < 15%

---

## 6. 风险与对策

### 6.1 技术风险

| 风险 | 影响 | 概率 | 对策 |
|------|------|------|------|
| **AI 自演化无法突破 0.7** | M1 延期 | 中 | 人工补充物理知识 + 偏差归因引导 |
| **多模型误差高度相关** | M2 失败或产生高置信错误 | 高 | 测 error correlation；校准融合；分歧/OOD 回落确定性引擎 |
| **工具生成出现虚假代码** | M3 信任崩塌 | 高 | 第三方评审门禁（强制） |
| **跨数据集泛化性不足** | 商业化受阻 | 高 | 扩大数据集 + 持续训练专家模型 |

### 6.2 资源风险

| 风险 | 影响 | 对策 |
|------|------|------|
| **GPU 资源不足** | 模型训练延期 | 云端租用（Vast.ai / Lambda Labs） |
| **商用 EDA license 到期** | 金标准缺失 | 提前续费 + 备份已有数据 |
| **关键人员流失** | 知识断层 | 文档化所有决策 + 代码注释 |

### 6.3 战略风险

| 风险 | 影响 | 对策 |
|------|------|------|
| **行业不接受低精度工具** | 商业模式失败 | 保留高精度签核档（G7 PrimeTime parity） |
| **巨头自建全栈** | 市场萎缩 | 专注中小厂商 + 平台合作 |
| **开源工具竞争** | 价格战 | 强调 AI 原生能力（OpenROAD 不具备） |

---

## 7. 与 00-ieda-commercial-parity 的协同

### 7.1 双轨制：商业对齐 + AI 原生

**商业对齐轨**（00 计划）：
- 目标：替代 Innovus / ICC2，PPA 打平商业工具
- 用户：传统芯片设计团队（人工操作为主）
- 时间线：G17（QoR parity）12-18 个月

**AI 原生轨**（本计划）：
- 目标：支撑大模型调用，order 精度 + 速度优先
- 用户：AI 原生设计平台 / 芯片生成厂商
- 时间线：M1-M3 6-12 个月

### 7.2 资源复用

| 组件 | 商业对齐 | AI 原生 | 复用方式 |
|------|---------|---------|---------|
| **iDB / solver** | ✅ | ✅ | 完全共享 |
| **iSTA（高精度）** | ✅ G7 | ✅ 签核回落档 | 双方共同推进 G7 |
| **iSTA（低精度）** | ❌ | ✅ 过程 STA | AI 原生独立开发 |
| **iPL / iRT** | ✅ G17 | ✅ 多精度引擎 | 商业对齐先行，AI 原生后接 |
| **evaluation** | ✅ G1 harness | ✅ order 精度 | 扩展指标类型 |

### 7.3 里程碑互锁

- **M1 依赖 G7 部分成果**：iSTA 单位修复 / SDC 解析（27-iSTA.md Phase B0）
- **G17 时序行依赖 M1**：联合门禁受保护的过程 STA 可加速商业对齐迭代；阶段终局仍 full rescore
- **M3 反哺商业对齐**：工具生成底座可快速适配新 PDK / 新工艺

---

## 8. 商业模式

### 8.1 定价模型

**待验证假说**：
- 计费单位候选：API 调用、分析场景数、CPU/GPU 资源时、设计规模阶梯或订阅。
- 定价前先测单位任务成本、峰值资源、缓存复用、支持成本和客户愿付价格。
- 不在技术方案中写未经合同/公开报价验证的商业工具价格，也不预设 token 是客户可理解的 EDA 计费单位。

### 8.2 目标客户

**短期（1 年内）**：
- AI 芯片设计平台（如 Cadence AI 平台、Synopsis.ai）
- 学术界 / 初创公司（低成本试错）

**中期（2-3 年）**：
- 中型 Fabless（100-500 人规模）
- IDM 的探索性项目

**长期（5 年）**：
- 成为工具生成平台的标准后端引擎

---

## 9. 决策记录

### 9.1 已拍板（2026-07-22）

1. **第一阶段聚焦 STA**：过程时序评估，对标 Innovus 内嵌 STA（非 PrimeTime）
2. **过程工具重视 ranking，但不能放宽 coverage/临界漏报/绝对误差保护**：统一采用 `04 §2.3` 联合指标
3. **多模型用于不确定度和回落触发**：删除“5 个 70% → 99%”错误结论；实际收益以 holdout 为准
4. **工具生成底座为长期目标**：Honey 体系通过 STA 迭代积累经验
5. **双轨制**：商业对齐（00 计划）与 AI 原生（本计划）并行，资源复用

### 9.1bis 技术纠偏（2026-07-23）

1. PrimeTime 作为数值相关性金标，Innovus 作为 in-design 调用/性能参考，二者不混用。
2. 多 effort 档优先共享 DesignState、单位、SDC 和确定性内核；不默认维护函数/LUT/NN/“SPICE-like STA”四套平行引擎。
3. AI 只给候选/策略/归因；物理修改走 MoveTxn、增量 oracle 和阶段终局 full rescore。
4. 工艺角不可按 Pareto 点随意跳过；过程筛角须周期性全角复验，signoff 全覆盖。
5. Honey 第一阶段优先生成配置和模块组合；代码生成属于受 mutation/differential tests 约束的研究项。

### 9.2 待决策

- [ ] GPU 资源采购：自建 vs 云端租用
- [ ] 数据集开源策略：部分开源 vs 完全闭源
- [ ] 第二工具选择：iPL vs iRT（M4 阶段）

---

## 10. 附录

### 10.1 参考文档

- `00-ieda-commercial-parity-master-plan-v1.1.md`：商业对齐总纲
- `04-ppa-technical-review-and-optimization-rv1.md`：跨工具联合门禁和底层算法优化路线
- `27-iSTA.md`：iSTA 技术方案（PBA / MCMM / vs PrimeTime）
- `51-agent-native-eda-detailed-plan-v1.0.md`：Agent-native 工程架构与 Timing Closure Lab 实施计划
- `智能纪要：EDA工具研发方向研讨会 2026年7月22日.md`：战略决策来源

### 10.2 术语表

| 术语 | 定义 |
|------|------|
| **order 精度** | 时序路径排序准确率（如 Top-100 worst paths 中有 90 条与金标准一致） |
| **多模型评审** | 以校准概率、误差相关性和模型分歧估计不确定度；不是简单投票证明正确 |
| **按需引擎** | 根据 accuracy/latency budget 选择同一内核的 estimate/in-design/correlated effort；可选 surrogate 必须能回落 |
| **Honey 体系** | 工具生成底座，通过积累实现经验支撑快速适配新需求 |
| **帕累托点** | 多目标优化中的非支配解（如 PPA 边界上的设计点） |

### 10.3 联系人

- 战略决策：@李兴权
- STA 技术：iSTA 团队 + AI 自演化团队
- 数据采集：对接 Innovus / 159 服务器
- 文档维护：本文档由 Claude Code 生成，人工审校后生效

---

**版本历史**：
- v1.0（2026-07-22）：初版，基于研讨会纪要与商业对齐计划
- v1.1（2026-07-23）：按 `04` 修正 ensemble 数学、order-only 门禁、工艺角筛选、引擎分层、校准与工具生成边界
