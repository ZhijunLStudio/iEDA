# iEDA 商业对标 Agent 团队执行计划

生成时间：2026-07-30
版本：v1.0

## 1. Agent 团队架构

根据 `00-ieda-commercial-parity-master-plan-v1.1.md` 的要求，设计如下 agent 团队：

### 1.1 主 Agent（Master）
- **职责**：
  - 负责主纲领文档（00-ieda-commercial-parity-master-plan-v1.1.md）的执行
  - 协调所有子 agent 的工作
  - 集成构建与测试
  - AES13 最终执行与结果回写
  - 跨工具审核与证据分级

- **关键任务**：
  - G1/G1b: QoR baseline 与 parity protocol
  - 最终门禁验证（G17-G21）
  - 证据收集与分级（D0-D4）

### 1.2 Sub-Agent A: iFP 实现链（implementation-chain）
- **职责**：
  - 非方形 IO pitch 处理
  - Tap blockage 相交检测
  - Die/core 合法性验证
  - Tcl/Python 失败传播

- **绑定门禁**：
  - G2: placement-converges
  - G3: macro-placement-live
  - G14: no-silent-failure（iFP 部分）

- **当前关键问题**：
  - 65% 利用率下 IO_SITE 环境变量缺失导致所有 floorplan 失败
  - 需要修复并验证 40%-65% 利用率渐进式测试

### 1.3 Sub-Agent B: iDRC 签核真值（signoff-truth）
- **职责**：
  - Foundry coverage manifest
  - Checked/skipped/partial/unsupported 分类
  - G11/G14 状态维护
  - vs Calibre 对照

- **绑定门禁**：
  - G11: drc-coverage
  - G5: route-clean（DRC 部分）

### 1.4 Sub-Agent C: iRT 布线优化（routing-optimizer）
- **职责**：
  - 收敛反馈控制
  - 违例归因与 JSON 输出
  - Timing-driven routing
  - DR 调度策略

- **绑定门禁**：
  - G5: route-clean
  - G13: scale-mid
  - G21: perf-parity（iRT 部分）

### 1.5 Sub-Agent D: iSTA 时序真值（timing-truth）
- **职责**：
  - vs PrimeTime 对齐
  - PBA 实现
  - MCMM 场景调度
  - 增量契约

- **绑定门禁**：
  - G7: sta-correlates（最高优先级）
  - G6: setup-hold-diagnosed

### 1.6 Sub-Agent E: Benchmark/Performance（platform-aes13）
- **职责**：
  - AES13 全配置执行
  - wait4 CPU/RSS 监控
  - 进程组 timeout 管理
  - Resume/stop-after 可比性防伪
  - 渐进式利用率测试（40%-65%）

- **绑定门禁**：
  - G21: perf-parity
  - G1: qo-baseline-fresh

### 1.7 Sub-Agent F: Evaluation/QoR（qor-validator）
- **职责**：
  - QoR schema 维护
  - 指标真实性验证
  - vs 商业对照数据收集
  - 报告生成

- **绑定门禁**：
  - G15: metric-not-fake
  - G17: qor-parity-impl

## 2. 当前优先级（Phase 0）

### 2.1 P0 任务（立即执行）

#### Task P0-1: 修复 floorplan IO_SITE 问题
- **负责 Agent**: Sub-Agent A (iFP)
- **问题**：所有 65% 利用率测试在 floorplan 阶段失败，缺少 `IO_SITE` 环境变量
- **修复方案**：
  1. 检查 `run_iFP.tcl` 的环境变量依赖
  2. 在 design.json 或流程脚本中补充必要的环境变量
  3. 验证修复后重新运行

#### Task P0-2: 渐进式利用率测试
- **负责 Agent**: Sub-Agent E (Benchmark)
- **策略**：按照报告 §1.2 的计划，渐进式测试
  - 40% → 50% → 55% → 60% → 65%
  - 每档先运行 3 个代表性配置
  - 每个档位通过后再扩展到全配置

#### Task P0-3: 建立 QoR baseline
- **负责 Agent**: Sub-Agent F (QoR)
- **任务**：
  1. 收集现有 35% 利用率的完整 QoR 数据作为 baseline
  2. 建立 `parity_protocol.json` 冻结文件
  3. 设计 vs 商业对照的数据采集方案

### 2.2 P1 任务（并行执行）

#### Task P1-1: iSTA vs PT 对齐起步
- **负责 Agent**: Sub-Agent D (iSTA)
- **任务**：Phase B0 准备工作
  - 单位/增量契约审计
  - PT harness 脚本设计
  - 首轮对比测试

#### Task P1-2: iRT 收敛机制审计
- **负责 Agent**: Sub-Agent C (iRT)
- **任务**：Phase B2 准备工作
  - Plateau 反馈控制代码审计
  - 违例 JSON schema 设计
  - 收敛失败语义定义

#### Task P1-3: 静默失败普查
- **负责 Agent**: Sub-Agent A (iFP)
- **任务**：G14 清单
  - 已知静默失败用例列表
  - 产物存在断言机制
  - 失败传播路径审计

## 3. Agent 协作协议

### 3.1 通信边界
- 所有 agent 写入**同一工作树**
- 主 agent 负责共享接口、真实性声明、编译与回归结果
- Agent 完成不等于门禁变绿，需要三联证据（code/test/artifact）

### 3.2 工作包协议
每个 agent 的工作包必须包含：
```text
WP-<tool>-<nn> · <一句话目标>
绑定门禁: G#
对照实验: <能杀死假说的命令/设计>
禁止范围: <不改哪些模块>
完成定义: 代码 + 门禁脚本断言 + 当前二进制重跑一致
证据: file:line 或 JSON 字段路径
```

### 3.3 证据等级（04 §1.1）
- **D0**: 目录/文件存在
- **D1**: 伪代码/设计文档
- **D2**: 代码 + 单测 + artifact
- **D3**: 集成测试通过
- **D4**: 商业金标并排证据

### 3.4 强制纪律
1. **先量再写**：无 Phase 0 数字，不准开 QoR 算法大改
2. **一次一假说**：每个会话只验证/修复一个对照实验
3. **子文档优先**：以子文档 LLD 为准，纲领只作门禁与优先级
4. **性能不盲优化**：无 G1 墙钟基线，不准为"加速"改算法
5. **输出回写**：测完更新子文档未验证清单

## 4. AES13 测试计划（65% 利用率目标）

### 4.1 当前状态
- ❌ 65% 利用率：13/13 失败（floorplan 阶段，IO_SITE 缺失）
- ✅ 35% 利用率：13/13 成功（但 DRC 全部非零）

### 4.2 执行路径

#### Step 1: 修复环境变量问题
```bash
# Agent A 执行
# 1. 检查并修复 run_iFP.tcl 中的环境变量依赖
# 2. 在 benchmarks/qor/aes13_flow.py 中补充环境变量设置
# 3. 验证修复
```

#### Step 2: 渐进式利用率测试
```bash
# Agent E 执行
# 代表性配置：aes_nangate45_a, aes_sky130_a, aes_ics55_a

# 40% 档（突破历史最高 35%）
python3 benchmarks/qor/run_utilization_test.py --util 0.40 --designs aes_nangate45_a,aes_sky130_a,aes_ics55_a

# 50% 档（前提：40% 通过）
python3 benchmarks/qor/run_utilization_test.py --util 0.50 --designs aes_nangate45_a,aes_sky130_a,aes_ics55_a

# 55% 档
python3 benchmarks/qor/run_utilization_test.py --util 0.55 --designs aes_nangate45_a,aes_sky130_a,aes_ics55_a

# 60% 档
python3 benchmarks/qor/run_utilization_test.py --util 0.60 --designs aes_nangate45_a,aes_sky130_a,aes_ics55_a

# 65% 档（用户目标）
python3 benchmarks/qor/run_utilization_test.py --util 0.65 --designs aes_nangate45_a,aes_sky130_a,aes_ics55_a

# 每档通过后扩展到全 13 配置
python3 benchmarks/qor/run_utilization_test.py --util 0.XX --all
```

#### Step 3: 结果回填报告
```bash
# Agent E + Agent F 执行
# 更新 benchmarks/reports/aes11_detailed_comparison-0.md
# 填充 §1.2.1 - §1.2.5 的表格和趋势分析
```

### 4.3 成功标准
- 每个档位 3/3 代表性配置执行成功（post-route DEF + GDS 生成）
- DRC 违例相比 baseline 的变化趋势记录
- Setup/Hold timing 变化趋势记录
- Routing time 与 baseline 的倍数记录
- 最终确定 iEDA 的最高稳定利用率

### 4.4 失败处理
- 如果某档全部失败（如 70% 的情况）：
  - 诊断失败原因（工具瓶颈 vs 配置问题）
  - 记录失败模式到报告
  - 停止向上探索，确定前一档为最高稳定点

- 如果部分失败：
  - 分 PDK 分析失败原因
  - 记录哪些工艺/配置可以支持更高利用率
  - 给出针对性改进建议

## 5. 报告更新计划

### 5.1 目标报告
`/home/lxq/AiEDA/iEDA.ai/benchmarks/reports/aes11_detailed_comparison-0.md`

### 5.2 更新内容
每个利用率档位（40%, 50%, 55%, 60%, 65%）都需要填充：

#### 表 1: 设计对比表
| Design | Die (µm²) | Core Util | Setup WNS (ns) | Hold WNS (ns) | DRC | Total WL (µm) | Route Time (s) | 状态 |

#### 表 2: vs Baseline 对比
| 指标 | Baseline (35%) | XX% | Delta | % Change |

#### 表 3: 关键发现
- DRC 趋势（是否随利用率上升而增加）
- Timing 趋势（Setup/Hold WNS 变化）
- 布线收敛性（是否能完成布线）
- 工具瓶颈识别

### 5.3 趋势分析图
- DRC 违例 vs 利用率曲线
- Setup Timing vs 利用率曲线
- Die 面积 vs 利用率曲线
- Runtime vs 利用率曲线

### 5.4 最高稳定利用率结论（§1.2.7）
- iEDA 最高稳定利用率确定
- vs 用户目标（65%）的达成情况
- 关键瓶颈分析
- 改进建议

## 6. 执行时间表

### Week 1（当前周）
- Day 1-2: P0-1（修复 IO_SITE）+ P0-2（40%-50% 测试）
- Day 3-4: P0-2（55%-65% 测试）+ P0-3（QoR baseline）
- Day 5: 报告更新 + 主 agent 集成

### Week 2-3（Phase 0）
- Sub-Agent D: iSTA vs PT 对齐
- Sub-Agent A: iFP 静默失败清理
- Sub-Agent B: iDRC coverage manifest
- Sub-Agent C: iRT 收敛机制

### Week 4-6（Phase B0-B1）
- iSTA PBA 实现（Phase B0）
- iPL 宏布局 + QP 初值（Phase B1）
- iRT 收敛反馈控制（Phase B2）

### Week 7+（Phase B4-C）
- QoR 打平主循环（G17 逐设计转绿）
- 规模测试（G13/G20）
- 性能优化（G21）

## 7. 门禁优先级

### P0（阻塞性）
- G1/G1b: 基线与协议冻结
- G14: 静默失败清零
- G7: iSTA vs PT（时序真值源）

### P1（主攻）
- G2/G3: iPL 收敛与宏布局
- G5: iRT route-clean
- G4: iCTS skew

### P2（打平）
- G17: QoR parity（逐指标）
- G21: Perf parity（运行时）

### P3（规模）
- G13/G20: 大设计
- G18: 综合链（iNO/iLO/iTM）

## 8. 风险与依赖

### 8.1 已知风险
1. **iFP 高利用率支持不足**
   - 现状：35% 可用，70% 失败，65% 未知
   - 影响：限制 QoR 对标的起点
   - 缓解：渐进式测试 + 算法审计

2. **iRT DRC 收敛问题**
   - 现状：35% 利用率下 13/13 DRC 非零（1,871-153,418）
   - 影响：G5/G11 阻塞
   - 缓解：收敛机制改进 + 规则覆盖审计

3. **iSTA vs PT 差距未知**
   - 现状：无 PT harness，当前 STA 结果低置信
   - 影响：G7 阻塞，时序相关门禁不可信
   - 缓解：Phase B0 第一优先级

### 8.2 关键依赖
- **商业工具访问权限**：PT, StarRC, Calibre, Innovus/ICC2
- **独占测试机**：G21 性能对比需要排除干扰
- **PDK 完整性**：4 个 PDK 的规则与模型

### 8.3 退出标准
- 每个 Phase 的退出条件以门禁转绿为准
- 不设死线，以质量为第一优先级
- 发现阻塞性问题时，优先级动态调整

## 9. Agent 启动命令（示例）

### 主 Agent
```bash
# 监控整体进度，协调子 agent
claude --agent master \
  --task "商业对标主计划执行" \
  --doc "/home/lxq/AiEDA/iEDA.ai/docs/ai/00-ieda-commercial-parity-master-plan-v1.1.md" \
  --gate "G1,G1b,G17,G21"
```

### Sub-Agent A (iFP)
```bash
claude --agent ifp-chain \
  --task "修复 floorplan IO_SITE + 渐进式利用率测试" \
  --gate "G2,G3,G14" \
  --priority P0
```

### Sub-Agent E (Benchmark)
```bash
claude --agent platform-aes13 \
  --task "AES13 渐进式利用率测试（40%-65%）" \
  --gate "G1,G21" \
  --config "benchmarks/qor/utilization_test_config.json"
```

### Sub-Agent F (QoR)
```bash
claude --agent qor-validator \
  --task "QoR baseline 建立 + 报告更新" \
  --gate "G15,G17" \
  --output "benchmarks/reports/aes11_detailed_comparison-0.md"
```

## 10. 下一步行动

### 立即执行（现在）
1. 诊断并修复 IO_SITE 环境变量问题
2. 设计渐进式利用率测试脚本
3. 启动 40% 利用率首轮测试（3 个代表性配置）

### 今日完成
1. 40%-50% 利用率测试完成
2. 初步 DRC/Timing 趋势分析
3. 报告 §1.2.1-1.2.2 填充

### 本周完成
1. 65% 利用率测试完成（或确定最高稳定利用率）
2. 报告 §1.2 全部章节填充
3. QoR baseline（35%）数据冻结
4. Parity protocol 文件生成

---

**文档状态**：执行计划 v1.0
**负责人**：Master Agent
**更新日期**：2026-07-30
**下次审查**：完成 Phase 0 后
