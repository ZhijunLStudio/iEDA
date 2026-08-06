# Agent 团队执行状态监控

**更新时间**: 2026-07-30
**执行模式**: 选项 B - 全面改进方案

---

## 🎯 总体目标

通过高利用率压力测试发现 iEDA 工具链的算法和实现缺陷，并在代码层面进行改进，而不是停留在配置调优层面。

**核心问题**: iRT 在 65% 利用率下布线失败（违例爆炸、内存失控、算法缺陷）

---

## 📊 Agent 执行矩阵

| Agent ID | 任务 | 工作包 | 状态 | 预计完成 | 绑定门禁 |
|----------|------|--------|------|---------|---------|
| **ae3b820c** | Plateau Detection | WP-iRT-01 | 🔄 运行中 | 2-3 天 | G14 |
| **aaba9d58** | Memory Budget | WP-iRT-02 | 🔄 运行中 | 3-4 天 | G14, G20 |
| **af7f81a7** | Adaptive Box Sizing + 对比框架 | WP-iRT-03 | 🔄 运行中 | 5-7 天 | G2 |

---

## ✅ 已完成工作（Phase 0）

### 1. 诊断与分析
- ✅ **深度根因分析**（`65pct_failure_root_cause_analysis.md`）
  - 发现违例爆炸机理：57k → 230k
  - 发现内存失控：8MB → 197MB
  - 识别算法缺陷：无 box-level 收敛控制

### 2. 基础设施
- ✅ **QoR Baseline**（`baseline_35pct.json`）- 13 个配置完整数据
- ✅ **Parity Protocol**（`parity_protocol.json` v1.1）- G1b 门禁
- ✅ **商业对照流程**（`commercial_comparison_procedure.md`）

### 3. 问题修复
- ✅ **iFP IO_SITE 修复** - 解决 floorplan 失败问题
- ✅ **配置标签纠正** - 发现 baseline 标签错误

---

## 🚀 当前执行中（Phase B0-B2）

### WP-iRT-01: Box-Level Plateau Detection

**目标**: 检测违例爆炸并响亮失败

**实现内容**:
```cpp
// DetailedRouter.cpp 中添加
- 每 36 个 box 检查违例趋势
- 增长率 >150% 触发 plateau
- 输出 plateau_diagnostic.json
- 返回失败退出码
```

**对照实验**:
- Baseline: box 144 处 OOM（无诊断）
- Test A: box 72-108 处检测到爆炸（响亮失败）
- Test B: threshold=2.0（更宽松）

**成功标准**:
- ✅ 检测到违例爆炸
- ✅ 生成诊断 JSON
- ✅ 明确的错误消息
- ✅ G14 门禁通过

---

### WP-iRT-02: Memory Budget Control

**目标**: 防止 OOM，保存 partial 结果

**实现内容**:
```cpp
// 新增 MemoryBudgetGuard 类
- 监控内存使用（读取 /proc/self/status）
- 超限时设置 abort flag
- OpenMP 线程检查并优雅退出
- 保存 partial DEF
```

**环境变量**:
```bash
IEDA_RT_MAX_MEMORY_MB=8192  # 默认 8GB
```

**对照实验**:
- Test A: 100 MB（低预算，触发保护）
- Test B: 8192 MB（正常预算）

**成功标准**:
- ✅ 内存超限不 OOM
- ✅ 保存 partial DEF
- ✅ 生成 memory_diagnostic.json
- ✅ G14 + G20 门禁通过

---

### WP-iRT-03: Adaptive Box Sizing

**目标**: 根据利用率动态调整 box size

**实现内容**:
```cpp
// DetailedRouter.cpp 自适应策略
- <40%: box_size=12 (快速)
- 40-60%: box_size=24 (平衡)
- ≥60%: box_size=48 (全局视野)
- 支持 escalation: 12→24→48
```

**环境变量**:
```bash
IEDA_RT_INITIAL_BOX_SIZE=24  # 手动覆盖
IEDA_RT_ENABLE_ESCALATION=1  # 启用渐进增大
```

**Grid Search 实验**:
| Box Size | 预期 Boxes | 预期违例 | 预期时间 |
|----------|-----------|---------|---------|
| 12 (baseline) | 144/324 | 230k | OOM |
| 24 | 200+/324 | <150k | 90-120 min |
| 48 | 324/324 | <100k | 120+ min |
| Escalation | 324/324 | <100k | 优化的 |

**成功标准**:
- ✅ 65% 违例增长率 <50%/iteration
- ✅ 至少完成 2 个 DR iteration
- ✅ 墙钟时间 ≤2 小时
- ✅ G2 门禁扩展通过

---

### 对比框架建设

**交付物**:
1. **Schema**: `improvement_comparison_schema.json`
   - 收敛性、质量、性能、稳定性指标定义

2. **脚本**: `compare_improvements.py`
   - 自动提取 routing metrics
   - Before/After 对比
   - 生成 Markdown 报告

3. **实验计划**: `improvement_experiment_plan.md`
   - 实验矩阵（Baseline, E-01~E-05）
   - 执行命令和预期效果

4. **自动化**: `run_improvement_experiments.sh`
   - 批量运行实验
   - 自动生成对比报告

---

## 📋 后续任务（Phase B3-C）

### Task #8: 建立真正的 35% baseline
**状态**: ⏸️ 待启动
**前置**: 等待当前三个改进完成
**内容**: 重新配置并运行真正的 35% 利用率 AES 设计

### P1 改进（收敛性优化）
- **WP-iRT-04**: Incremental Violation Checking（10-15 天）
- **WP-iRT-05**: Critical Net Prioritization（timing-driven, 15-20 天）
- **WP-iRT-06**: Congestion-Driven Detour（15-20 天）

### P2 改进（性能优化）
- **WP-iRT-07**: OpenMP Load Balancing
- **WP-iRT-08**: Violation JSON Export

---

## 🎯 里程碑与门禁

### M1: 响亮失败（Week 1-2）
- ✅ WP-iRT-01 完成
- ✅ WP-iRT-02 完成
- ✅ G14 门禁通过
- **效果**: 65% 失败时有明确诊断，不再 OOM

### M2: 基本收敛（Week 3-5）
- ✅ WP-iRT-03 完成
- ✅ 对比框架建立
- ✅ G2 门禁扩展通过
- **效果**: 65% 能完成 200+ boxes，违例可控

### M3: 中密度 DRC=0（Week 6-10）
- ⏸️ WP-iRT-04/05/06 完成
- ✅ G5 门禁通过（中密度 DRC=0）
- **效果**: 55-60% 利用率完全收敛

### M4: 商业 QoR 打平（Week 11+）
- ⏸️ 实现链全工具优化
- ✅ G17 门禁通过（逐指标打平）
- ✅ G21 门禁通过（性能 parity）
- **效果**: 与 Innovus/ICC2 PPA 持平

---

## 📈 预期改进效果

### 当前状态（Baseline）
```
65% 利用率:
- Boxes: 144/324 (44%)
- Violations: 57k → 230k (爆炸)
- Memory: 8MB → 197MB → OOM
- Status: 进程被杀，无诊断
```

### M1 完成后（响亮失败）
```
65% 利用率:
- Boxes: 72-144/324
- Violations: 检测到爆炸并停止
- Memory: 控制在预算内
- Status: 响亮失败 + 诊断 JSON
- 改进: 用户体验提升，有明确的失败原因
```

### M2 完成后（基本收敛）
```
65% 利用率:
- Boxes: 200-324/324
- Violations: <150k（可控）
- Memory: <500MB
- Status: 可能完成 1-2 个 DR iteration
- 改进: 显著提高收敛概率
```

### M3 完成后（中密度完美）
```
55-60% 利用率:
- Boxes: 324/324 (100%)
- Violations: 0（clean）
- DRC: 0
- Status: 完全收敛
- 改进: 稳定支持中高密度设计
```

---

## 🔍 监控指标

### 每日检查
- [ ] Agent 是否仍在运行（检查 /tmp/claude-1002/tasks/*.output）
- [ ] 是否有 API 错误或中断
- [ ] 磁盘空间是否充足（编译产物）

### 完成后验证
- [ ] 代码编译通过
- [ ] 单元测试通过（如果有）
- [ ] 对照实验完成
- [ ] 文档更新
- [ ] 门禁通过

---

## 📝 决策记录

### 决策 1: 选项 B（全面改进）vs 选项 A（快速报告）
**选择**: 选项 B
**原因**: 用户明确要求"去改算法、去改代码"，而不是停留在配置层面
**日期**: 2026-07-30

### 决策 2: P0 改进优先级
**顺序**: WP-iRT-01 → WP-iRT-02 → WP-iRT-03
**原因**:
- WP-01 最快见效（响亮失败）
- WP-02 保证稳定性
- WP-03 是收敛性关键
**日期**: 2026-07-30

### 决策 3: 并行执行三个工作包
**选择**: 同时启动三个 agent
**原因**: 三个改进相对独立，可以并行开发
**风险**: 可能需要协调代码合并
**日期**: 2026-07-30

---

## 🚧 风险与缓解

### 风险 1: Agent API 错误中断
**概率**: 中
**影响**: 高
**缓解**:
- 使用 SendMessage 恢复中断的 agent
- 保存中间结果
- 准备手动接管方案

### 风险 2: 代码合并冲突
**概率**: 低
**影响**: 中
**缓解**:
- 三个改进在不同代码区域
- WP-01/02 主要在 routeDRBoxMap
- WP-03 在初始化阶段

### 风险 3: 改进效果不如预期
**概率**: 中
**影响**: 中
**缓解**:
- 设计了完整的对照实验
- Grid search 找最优参数
- 有 fallback 方案（降低利用率目标）

---

## 📞 支持信息

**主 Agent**: 负责协调和最终集成
**诊断报告**: `/home/lxq/AiEDA/iEDA.ai/docs/ai/65pct_failure_root_cause_analysis.md`
**主计划**: `/home/lxq/AiEDA/iEDA.ai/docs/ai/00-ieda-commercial-parity-master-plan-v1.1.md`
**iRT 子文档**: `/home/lxq/AiEDA/iEDA.ai/docs/ai/26-iRT.md` rv2.1

---

**状态更新频率**: 每日或当 agent 完成时
**下次审查**: 三个 agent 全部完成后
