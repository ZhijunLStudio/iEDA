# iEDA 商业对等计划 Agent 团队架构

生成时间：2026-07-29
版本：v1.0

## 1. 团队架构总览

```
主 Agent (Master Coordinator)
├── 负责文档：00-ieda-commercial-parity-master-plan-v1.1.md
├── 职责：总体协调、门禁验收、结果汇总
└── 协调 4 个子 Agent 团队

子 Agent 团队：
├── Team A: 签核真值源 (Signoff Truth Source)
│   ├── Agent A1: iSTA-PT 对齐专家
│   ├── Agent A2: iRCX-StarRC 对齐专家
│   └── Agent A3: iDRC-Calibre 对齐专家
│
├── Team B: 实现链优化 (Implementation Chain)
│   ├── Agent B1: iPL 布局优化专家
│   ├── Agent B2: iRT 布线收敛专家
│   ├── Agent B3: iTO 时序修复专家
│   └── Agent B4: iCTS 时钟树专家
│
├── Team C: 基础设施与验证 (Infrastructure & Validation)
│   ├── Agent C1: QoR 评测框架专家
│   ├── Agent C2: 接口与失败语义专家
│   └── Agent C3: 性能剖面与对比专家
│
└── Team D: 测试执行与报告 (Testing & Reporting)
    ├── Agent D1: AES13 测试执行专家
    └── Agent D2: 报告生成与更新专家
```

## 2. 主 Agent 职责

### 2.1 核心职责
- 维护 master plan 文档状态
- 协调各子 agent 的工作顺序和依赖
- 验收各门禁（G1-G21）
- 汇总测试结果和报告
- 决策优先级调整

### 2.2 工作流程
1. Phase 0: 建立基线和协议
2. Phase A: 可信度地基
3. Phase B0-B4: 签核真值源 + 实现链优化
4. 持续验证和报告更新

## 3. 子 Agent 团队详细职责

### Team A: 签核真值源团队

#### Agent A1: iSTA-PT 对齐专家
- **文档**：`27-iSTA.md` rv2.1
- **目标**：G7 门禁（与 PrimeTime 相关性）
- **交付**：
  - top-N PBA 实现
  - MCMM 多场景支持
  - vs PT 对齐报告（R²>0.98, |ΔWNS|≤10ps）
  - 增量 STA 契约
- **依赖**：iRCX SPEF 输入
- **优先级**：P0（第一优先）

#### Agent A2: iRCX-StarRC 对齐专家
- **文档**：`28-iRCX.md` rv2.1
- **目标**：G8 门禁（与 StarRC 精度对齐）
- **交付**：
  - 逐网电容/电阻对比
  - 耦合电容精度提升
  - SPEF 量纲修正
  - 误差报告 JSON
- **依赖**：DEF 输入
- **优先级**：P0（与 A1 并行）

#### Agent A3: iDRC-Calibre 对齐专家
- **文档**：`30-iDRC.md` rv2.2
- **目标**：G11 门禁（rule deck 覆盖）
- **交付**：
  - foundry coverage manifest
  - vs Calibre 可比子集验证
  - checked/skipped/partial/unsupported 分类
  - SHA-256 deck 校验
- **依赖**：GDS 输入
- **优先级**：P1

### Team B: 实现链优化团队

#### Agent B1: iPL 布局优化专家
- **文档**：`22-iPL.md` rv2.1
- **目标**：G2/G3 门禁（布局收敛、宏布局）
- **交付**：
  - 宏力导向 + SA 布局
  - QP 初值优化
  - Nesterov 收敛断言
  - 拥塞驱动布局
  - 时序驱动布局（依赖 A1）
- **依赖**：iFP 输入、iSTA 增量接口
- **优先级**：P0

#### Agent B2: iRT 布线收敛专家
- **文档**：`26-iRT.md` rv2.1
- **目标**：G5 门禁（route-clean 或诚实拒绝）
- **交付**：
  - 收敛反馈控制
  - plateau 检测和策略调整
  - 违例 JSON 输出
  - 时序驱动布线（依赖 A1）
  - ECO 布线支持
- **依赖**：iPL 输出、iSTA 时序预算
- **优先级**：P0

#### Agent B3: iTO 时序修复专家
- **文档**：`25-iTO.md` rv2.1
- **目标**：G6 门禁（setup/hold 修复）
- **交付**：
  - re-time 否决环
  - 增量 legalization
  - VT-swap/buffer 插入真 apply
  - SI-aware 优化
- **依赖**：iSTA 增量、iPL incr LG、iRT ECO
- **优先级**：P1（在 B1/B2 后）

#### Agent B4: iCTS 时钟树专家
- **文档**：`23-iCTS.md` rv2.1
- **目标**：G4/G19 门禁（skew/latency/功耗）
- **交付**：
  - skew/latency/功耗三目标
  - 多域支持
  - buffer 后增量 LG
  - useful skew
- **依赖**：iPL 输出
- **优先级**：P1

### Team C: 基础设施与验证团队

#### Agent C1: QoR 评测框架专家
- **文档**：`12-evaluation.md` rv1.2、`04-ppa-technical-review-and-optimization-rv1.md`
- **目标**：G1/G1b 门禁（基线和协议）
- **交付**：
  - `parity_protocol.json` 冻结
  - QoR 指标 schema 和校验
  - 自动化对比脚本
  - 商业侧并排运行框架
- **依赖**：无
- **优先级**：P0（最先启动）

#### Agent C2: 接口与失败语义专家
- **文档**：`41-interface.md` rv1.0
- **目标**：G14 门禁（无静默失败）
- **交付**：
  - 产物存在断言
  - 响亮失败传播
  - Tcl/Python 错误处理
  - 命令矩阵覆盖
- **依赖**：各工具接口
- **优先级**：P0

#### Agent C3: 性能剖面与对比专家
- **文档**：`42-perf-parity.md` rv2.3
- **目标**：G21 门禁（性能打平）
- **交付**：
  - 墙钟/内存剖面工具
  - 独占机测试框架
  - median/MAD 统计
  - 热点归因报告
- **依赖**：完整流程可运行
- **优先级**：P1

### Team D: 测试执行与报告团队

#### Agent D1: AES13 测试执行专家
- **目标**：运行 13 个 AES 配置（65% 利用率）
- **交付**：
  - 修改 design.json 配置
  - 执行完整流程
  - 收集 QoR 数据（timing/power/DRC/congestion）
  - 收集性能数据（runtime/memory）
  - SHA-256 manifest
- **依赖**：优化后的 iEDA 工具链
- **优先级**：P1（在主要优化后）

#### Agent D2: 报告生成与更新专家
- **目标**：更新 `aes11_detailed_comparison-0.md`
- **交付**：
  - 添加 65% 利用率测试结果
  - 更新所有表格和图表
  - 生成对比分析
  - 更新结论和建议
- **依赖**：D1 测试数据
- **优先级**：P1（最后执行）

## 4. 执行顺序与依赖关系

### 4.1 Phase 0: 基础建立（Week 1-2）
```
C1 (QoR 框架) ───┬──> 所有其他 agents
C2 (接口)        ─┘
```

### 4.2 Phase A+B0: 签核真值源（Week 3-6）
```
A1 (iSTA) ───┬──> B1 时序驱动、B2 时序驱动、B3
A2 (iRCX) ───┘
A3 (iDRC) ──────> 独立并行
```

### 4.3 Phase B1-B4: 实现链优化（Week 5-12）
```
B1 (iPL) ──> B4 (iCTS) ──┬──> B2 (iRT) ──> B3 (iTO)
                          │
                          └──> (并行) A3 (iDRC)
```

### 4.4 Phase 验证与报告（Week 10-14）
```
C3 (性能剖面) ──> D1 (AES13 测试) ──> D2 (报告更新)
```

## 5. 门禁验收顺序

### 第一批（必须先通过）
- G1: QoR 基线新鲜度
- G1b: 苹果对苹果协议冻结
- G14: 无静默失败

### 第二批（签核真值）
- G7: iSTA vs PrimeTime
- G8: iRCX vs StarRC
- G11: iDRC vs Calibre

### 第三批（实现链质量）
- G2: iPL 收敛
- G3: 宏布局
- G4: CTS skew
- G5: route-clean
- G6: setup/hold

### 第四批（商业对等）
- G17: QoR 打平
- G19: CTS 专项
- G21: 性能打平

## 6. 当前状态与 65% 利用率测试

### 6.1 v1.9 基线状态
- AES13 执行：13/13 成功
- 质量门禁：13/13 失败（DRC 非零）
- 利用率：25-35%
- 关键问题：
  - DRC 违例 1,726-166,251
  - SPEF 缺失（net delay=0）
  - 无 VCD/SAIF（switch power=0）
  - ASAP7 setup WNS 异常

### 6.2 65% 利用率测试计划
- **风险**：根据 §1.1 的 70% 失败经验，65% 可能仍超出工具能力
- **策略**：
  1. 先在一个配置上测试 65%
  2. 如果失败，降至 50%/55%/60% 寻找上限
  3. 记录失败模式和瓶颈
  4. 更新 master plan 的能力边界

### 6.3 执行优先级调整
- **立即执行**：Agent C1（建立对比框架）
- **高优先级**：Agent A1/A2（签核真值源）
- **中优先级**：Agent B1/B2（布局布线）
- **利用率测试**：在主要优化完成后，渐进式测试（40%→50%→60%→65%）

## 7. Agent 工作包示例

### WP-STA-01 · PrimeTime 对齐基础框架
- **绑定门禁**：G7
- **对照实验**：同一 SPEF，iSTA vs PT 逐路径 slack
- **完成定义**：endpoint 覆盖 ≥99%, |ΔWNS|≤10ps
- **证据**：`benchmarks/qor/sta/pt_correlation.json`

### WP-PL-01 · 宏布局力导向实现
- **绑定门禁**：G3
- **对照实验**：有宏设计，force-directed vs shelf-pack
- **完成定义**：`macro_packed_frac < 10%`
- **证据**：`src/operation/iPL/macro_placer/`, DEF macro 坐标

### WP-RT-01 · 布线收敛反馈控制
- **绑定门禁**：G5
- **对照实验**：plateau 检测后策略切换
- **完成定义**：≥3 中密度设计 DRC=0
- **证据**：`violation_summary.json`, DR 调度日志

## 8. 协作协议

### 8.1 通信机制
- 主 agent 通过任务系统分配工作
- 子 agent 完成后更新任务状态
- 关键决策需主 agent 审批
- 每日汇总进度和阻塞项

### 8.2 代码与文档同步
- 每个工作包完成后立即：
  - 更新相应子文档的§未验证清单
  - 提交代码 + 测试
  - 运行红线检查（ctest + 三 PDK）
  - 更新 master plan §2.2/§7

### 8.3 冲突解决
- 优先级冲突：遵循关键路径（签核真值 > 实现链）
- 资源冲突：独占机测试排队，共享机只测正确性
- 技术冲突：回退到 master plan 决策记录

## 9. 下一步行动

1. **立即启动**：Agent C1（QoR 框架）
2. **并行启动**：Agent C2（接口失败语义）
3. **准备启动**：Agent A1/A2（签核真值源）
4. **暂缓**：65% 利用率测试，等待主要优化完成

## 10. 成功标准

- ✅ 13 个 AES 配置全部执行成功
- ✅ 至少 10/13 配置 DRC clean（G5）
- ✅ iSTA vs PT 对齐（G7）
- ✅ 65% 利用率稳定运行，或明确上限并解释
- ✅ 报告完整更新，包含对比分析
- ✅ master plan v2.0 发布，记录真实能力边界
