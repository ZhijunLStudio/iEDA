# Agent 首轮审计报告汇总

生成时间：2026-07-29
主 Agent：Master Coordinator

---

## 已完成审计的 Agents

### ✅ Agent C1: QoR 评测框架专家
**状态**：审计完成
**结论**：基础设施良好（D2级），但缺商业侧数据和联合门禁

**关键发现**：
1. ✅ **协议文件完整**：`parity_protocol.json` 已冻结（Innovus、标准 effort、4 报告点）
2. ✅ **验证工具齐全**：SHA-256 校验、manifest 完整性、逐指标判定
3. ⚠️ **商业侧运行框架缺失**：无 Innovus/PT/StarRC/Calibre 调用脚本
4. ⚠️ **联合门禁未实现**：G7 需要覆盖率+WNS+bias+分桶，当前只有简单 delta

**交付计划**：
- P0-1: 门禁检查脚本（2天）
- P0-2: 商业侧框架设计（5-8天）
- P0-3: 增强现有脚本（3天）
- **总周期**：10-12天

**阻塞项**：商业侧数据采集依赖 license

---

### ✅ Agent A1: iSTA-PrimeTime 对齐专家
**状态**：审计完成
**结论**：单位处理正确，但 PBA 零实现，阻塞 G7

**关键发现**：
1. ✅ **单位处理机制正确**：内部全程 fs 整型，报告时转 ns，未见混用
2. ⚠️ **SPEF 单位风险**：若 SPEF 单位未对齐 DEF DBU，会系统性偏差
3. ❌ **PBA 零实现**：搜索 `path.*based` 无命中，只有 GBA 悲观合并
4. ✅ **CPPR 已存在**：但作用于 GBA 路径，非 PBA
5. ⚠️ **三套时序栈**：iPL/iTO/CTS 各用不同时序引擎，不一致
6. ✅ **AES13 问题根因确认**：net delay=0 因为无 SPEF（符合预期）

**阻塞依赖**：需要 iRCX (Agent A2) 提供正确 SPEF

**优先行动**：
1. 等待 iRCX SPEF
2. 验证单位口径（DEF DBU vs SPEF resistance_unit）
3. 实现 top-N PBA（新建 `StaPathBased.{hh,cc}`）
4. 建立 PT 对齐 harness

---

### ✅ Agent B1: iPL 布局优化专家
**状态**：审计完成
**结论**：状态传播基本正确，但宏布局完全空、QP 初值是随机

**关键发现**：
1. ✅ **状态传播基本正确**：GP/LG 失败都会 LOG_FATAL，阻塞后续流程
2. ⚠️ **runFlow 未捕获 LG 返回值**：但因为内部 LOG_FATAL，实际仍会中止
3. ❌ **宏布局完全空**：`macro_placer/` 只有 readme，`runMP()` 被注释
4. ❌ **QP 初值是随机**：`RandomPlace` 是生产默认，15-30% 线长损失
5. ⚠️ **QP 求解器目录空**：`src/solver/quadratic_programming` 不存在
6. ⚠️ **时序驱动被 guard**：`isSTAStarted()` 检查导致时序驱动未启用

**优先行动**：
- P0: Phase B1.1 - 加强 LG 返回值检查
- P0: Phase B1.2 - 实现宏力导向 + SA
- P1: Phase B1.3 - 构建 QP 求解器
- P1: Phase B1.4 - 收敛曲线日志
- P1: Phase B1.5 - 启用时序驱动（依赖 A1）

---

## 等待中的 Agents

### ⏳ Agent B2: iRT 布线收敛专家
**状态**：运行中
**任务**：审计 DetailedRouter 迭代逻辑、分析 AES13 违例增长、定位热点

### ⏳ Agent A3: iDRC-Calibre 对齐专家
**状态**：运行中
**任务**：审计 RuleCoverage、生成 4 PDK manifest、建立 Calibre 映射

### ⏳ Agent C2: 接口与失败语义专家
**状态**：运行中
**任务**：普查静默失败、产物断言、失败传播、API 矩阵

### ⏳ Agent D1: AES13 测试执行专家
**状态**：准备中（等待依赖）
**依赖**：Agent B1, B2, C1

---

## 关键路径分析

### 🔴 P0 阻塞项（必须立即解决）

1. **iRCX SPEF 缺失**
   - 影响：阻塞 Agent A1 的 PBA 开发和 PT 对齐
   - 状态：Agent A2 (iRCX-StarRC) 尚未启动
   - 决策：**需要立即启动 Agent A2**，或使用临时 SPEF 先验证流程

2. **商业侧运行框架**
   - 影响：阻塞 G17 商业对等验收
   - 状态：Agent C1 已完成设计，需要实施
   - 决策：优先级提升，与 PBA 开发并行

3. **宏布局零实现**
   - 影响：有宏设计无法正确布局，G3 门禁失败
   - 状态：Agent B1 已定位，需要实施
   - 决策：Phase B1.2 立即开始

### 🟡 P1 依赖项（需要协调）

1. **三套时序栈不一致**
   - 影响：iPL/iTO/CTS 各用不同时序引擎，结果不一致
   - 解决：需要架构级重构，超出单个 agent 范围
   - 决策：记录为技术债，Phase B 后期统一

2. **QP 求解器缺失**
   - 影响：QP 初值优化无法实施
   - 解决：需要新建 solver 模块
   - 决策：Phase B1.3，可与宏布局并行

---

## 主 Agent 决策

### 决策 #1：立即启动 Agent A2 (iRCX)
**理由**：Agent A1 阻塞在 SPEF 上，时序真值源是关键路径
**行动**：启动 iRCX-StarRC 对齐专家

### 决策 #2：Agent C1 进入实施阶段
**理由**：审计完成，基础设施清晰，可以开始编码
**行动**：指导 Agent C1 开始 P0-1 和 P0-2 工作包

### 决策 #3：Agent B1 进入实施阶段
**理由**：审计完成，宏布局缺口明确
**行动**：指导 Agent B1 开始 Phase B1.2（宏力导向 + SA）

### 决策 #4：暂缓 65% 利用率测试
**理由**：实现链优化尚未完成，过早测试无意义
**行动**：Agent D1 继续等待，专注于基线验证和脚本准备

---

## 下一步行动计划

### 立即（今天）
1. ✅ 启动 Agent A2 (iRCX-StarRC)
2. ✅ 指导 Agent C1 进入实施阶段
3. ✅ 指导 Agent B1 进入实施阶段
4. ⏳ 等待 Agent B2/A3/C2 完成审计

### 短期（1-2 天）
1. Agent A2 完成 iRCX 审计，开始 SPEF 生成
2. Agent C1 完成门禁检查脚本（P0-1）
3. Agent B1 完成宏布局力导向实现（Phase B1.2）
4. Agent B2/A3/C2 完成审计并进入实施

### 中期（1-2 周）
1. Agent A1 实现 PBA，开始 PT 对齐
2. Agent C1 完成商业侧框架设计（P0-2）
3. Agent B1 完成 QP 初值优化（Phase B1.3）
4. Agent B2 实现收敛反馈控制

### 长期（2-4 周）
1. G7/G11 门禁转绿
2. G2/G3/G5 门禁转绿
3. 启动 Agent D1 渐进式利用率测试

---

## 风险更新

### 新增风险

**风险 5：iRCX SPEF 质量不确定**
- **概率**：中（未审计）
- **影响**：即使有 SPEF，单位/精度问题会导致 timing 偏差
- **缓解**：Agent A2 必须验证 SPEF 单位与 DEF DBU 对齐
- **Plan B**：使用 StarRC 作为金标准，先对齐再优化 iRCX

**风险 6：宏布局算法从零开发**
- **概率**：高（完全空白）
- **影响**：开发周期可能超出预期
- **缓解**：参考 docs/ai/03-commercial-knowhow-catalog.md 的商业手法
- **Plan B**：先实现简单 shelf-pack 兜底，再实现 force-directed

### 更新的风险

**风险 1：65% 利用率**
- **状态更新**：暂缓测试，等待实现链优化
- **新策略**：在 G2/G3/G5 转绿后，再进行渐进式测试

---

## 成功标准进度

### 必达（M0）
- ✅ 7 个 agent 成功启动并运行
- ✅ 3 个 agent 完成首轮审计（C1/A1/B1）
- ⏳ G1/G1b/G14 门禁转绿 → Agent C1 实施中
- ⏳ G7 (iSTA vs PT) 对齐起步 → 等待 Agent A2 SPEF

### 期望（M1）
- ⏳ G2/G3/G5 门禁转绿 → Agent B1/B2 实施中
- ⏳ AES13 在某个利用率下稳定运行 → 暂缓
- ⏳ 报告更新 → 等待测试数据

### 理想（M2）
- ⏳ G17 部分指标转绿 → 依赖商业侧数据
- ⏳ 65% 利用率测试成功 → 暂缓
- ⏳ 所有 13 个配置 DRC clean → 依赖 B2/A3

---

**主 Agent 状态**：协调中，准备启动第二轮指令
**最后更新**：2026-07-29（审计汇总完成）
