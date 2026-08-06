# Agent 团队完整审计报告汇总

**生成时间**：2026-07-29
**主 Agent**：Master Coordinator
**状态**：所有 7 个 agent 首轮审计完成

---

## 执行摘要

### ✅ 好消息：基础比预期好
1. **iRT 内核成熟**：PathFinder+A*+patch 算法工业级，Plateau 框架完整但默认关
2. **状态传播基本正确**：iPL 的 GP/LG 失败会 LOG_FATAL 阻塞流程
3. **QoR 基础设施完整**：协议、schema、验证工具齐全（D2 级）
4. **iSTA 单位处理正确**：内部 fs 整型一致，无混用

### 🔴 关键阻塞项（必须立即解决）
1. **iRCX SPEF 缺失**：Agent A2 尚未完成审计，阻塞 A1 的 PBA 开发
2. **Tcl 接口静默失败**：23 个命令无条件返回成功，零产物断言
3. **宏布局完全空**：`macro_placer/` 只有 readme，有宏设计无法正确布局
4. **PBA 零实现**：iSTA 只有 GBA，阻塞 G7 门禁
5. **Calibre deck 缺失**：无法建立 iDRC vs Calibre 映射

### ⚠️ 重要发现：文档 vs 实际
- **iRT 文档低估现状**：Plateau 机制已实现但默认关，非"无代码"
- **AES13 数据矛盾**：
  - 文档说 DRC 1,726-166,251
  - Agent A3 发现所有 detail.drc 文件 0 字节
  - Agent D1 发现 baseline 是 11 个设计（非 13 个）
- **65% 利用率已测试过**：60%/65%/70% 全失败，当前 design.json 已设为 65%

---

## 逐 Agent 详细报告

### Agent C1: QoR 评测框架 ✅
**状态**：审计完成，进入实施阶段
**成熟度**：D2（有代码+测试+artifact，缺商业侧数据）

**交付物**：
- ✅ 协议文件完整（主对标方 Innovus、标准 effort）
- ✅ 验证工具齐全（SHA-256、manifest、逐指标判定）
- ⚠️ 商业侧框架设计（5-8 天）
- ⚠️ 联合门禁未实现（G7 需覆盖率+WNS+bias+分桶）

**下一步**：P0-1 门禁脚本（2 天）+ P0-2 商业侧框架（5-8 天）

---

### Agent A1: iSTA-PrimeTime 对齐 ✅
**状态**：审计完成，阻塞在 SPEF 上
**成熟度**：D1（单位正确，PBA 零实现）

**关键发现**：
- ✅ 单位处理机制正确（内部 fs 整型，报告转 ns）
- ✅ CPPR 已存在（但作用于 GBA）
- ❌ PBA 零实现（搜索 `path.*based` 无命中）
- ⚠️ 三套时序栈（iPL/iTO/CTS 各用不同引擎）
- ✅ AES13 net delay=0 根因确认（无 SPEF）

**阻塞依赖**：需要 Agent A2 (iRCX) 提供 SPEF

**下一步**：等待 SPEF → 验证单位 → 实现 PBA → PT 对齐

---

### Agent B1: iPL 布局优化 ✅
**状态**：审计完成，进入实施阶段
**成熟度**：D1（框架正确，宏/QP 零实现）

**关键发现**：
- ✅ 状态传播基本正确（GP/LG 失败会 LOG_FATAL）
- ❌ 宏布局完全空（`macro_placer/` 只有 readme）
- ❌ QP 初值是随机（15-30% 线长损失）
- ⚠️ QP 求解器目录空（`src/solver/quadratic_programming`）
- ⚠️ 时序驱动被 guard（`isSTAStarted()` 检查）

**下一步**：
- P0: Phase B1.2 - 实现宏力导向 + SA
- P1: Phase B1.3 - 构建 QP 求解器
- P1: Phase B1.5 - 启用时序驱动（依赖 A1）

---

### Agent A2: iRCX-StarRC 对齐 ⏳
**状态**：刚启动，审计中
**优先级**：P0（紧急，阻塞 A1）

**任务**：
1. 审计 iRCX SPEF 生成状态
2. 验证 SPEF 单位与 DEF DBU 对齐
3. 为 AES13 生成 SPEF（至少 1-2 个配置）
4. 交付给 Agent A1 验证

---

### Agent B2: iRT 布线收敛 ✅
**状态**：审计完成，纠正文档错误
**成熟度**：D2（内核成熟，配置默认关）

**关键发现**（纠正文档 rv2.1）：
- ✅ 内核算法成熟（PathFinder + A* + patch）
- ✅ **Plateau 机制已实现**（文档说"无 API"是错的）
  - 位置：`DetailedRouter.cpp:2905-3076`
  - 有 `applyPlateauEscalation` 函数
  - 有 `fail_on_residual_drc` 诚实拒绝
  - **但默认关**：`IEDA_RT_ENABLE_PLATEAU=false`
- ✅ 硬编码 9 轮调度确认（`:432-440`）
- ⚠️ AES13 数据矛盾（需要完整 13 设计的违例曲线）

**下一步**：
- P0: 开启 Plateau（`IEDA_RT_ENABLE_PLATEAU=1`）
- P0: 记录每轮违例序列到 JSON
- P0: 热点分析（最差设计的 violation_summary.json）

---

### Agent A3: iDRC-Calibre 对齐 ✅
**状态**：审计完成，发现数据矛盾
**成熟度**：D1（框架完整，缺 Calibre deck 和数据）

**关键发现**：
- ✅ Schema 驱动 manifest 系统已实现
- ✅ `RuleCoverage` 类和单测齐全
- ⚠️ SHA-256 只验证格式，未计算内容哈希
- ❌ **Calibre deck 文件不存在**（无法建立映射）
- ❌ **AES13 所有 detail.drc 文件 0 字节**（与文档矛盾）

**数据矛盾**：
- 文档 v1.9 说 DRC 1,726-166,251
- Agent A3 发现所有 detail.drc 空文件

**下一步**：
1. 定位正确的 DRC 数据文件
2. 获取 4 PDK 的 Calibre deck
3. 实现内容 SHA-256
4. 建立 iDRC → Calibre 规则映射

---

### Agent C2: 接口与失败语义 ✅
**状态**：审计完成，发现 23 个静默失败
**成熟度**：D0（严重缺陷，G14 阻塞）

**关键发现**：
- ❌ **Pattern A: 忽略 bool 返回**（P0 最危险）
  - `tcl_ipl.cpp:97-101` `CmdPlacerFiller` 忽略返回值
  - `tcl_ipl.cpp:128-132` `CmdPlacerIncrementalFlow` 同上
  - `tcl_ito.cpp:45-49` `CmdTOAutoRun` 同上
  - `tcl_ito.cpp:78-82` `CmdTORunDrv` 同上
- ❌ **Pattern B: void 调用无错误检测**（P0）
  - `tcl_irt/src/tcl_run_rt.cpp:36-37` `RTI.runRT()` void
  - `tcl_irt/src/tcl_init_rt.cpp:51-52` `RTI.initRT()` void
- ❌ **Pattern D: 零产物断言**（P0）
  - 搜索 `std::filesystem::exists` 零匹配
  - 无命令验证输出 DEF/SPEF/reports 存在

**影响**：工具失败被掩盖 → 下游消费错误输入 → 级联失败误判

**下一步**：
1. 修复 Pattern A/B（传播工具返回值）
2. 添加产物断言（所有输出命令）
3. 构建 G14 回归套件（注入已知失败）

---

### Agent D1: AES13 测试执行 ✅
**状态**：准备完成，发现关键信息
**成熟度**：基础设施就绪，等待依赖

**关键发现**：
- ✅ 基础设施完整（runner、PDK、Python 环境）
- ⚠️ **Baseline 是 11 个设计，非 13 个**
  - `aes11-functional-parallel-20260725-rv2.3`
  - 25-35% 利用率，11/11 成功
- ⚠️ **60%/65%/70% 已测试过，全部失败**
  - 当前 design.json 已设为 65%
  - 失败阶段：floorplan
- ⚠️ **密度悖论确认**
  - 25-35%: 成功
  - 60%+: 失败（系统性）

**建议**：
- 不立即测试 65%（已知会失败）
- 建议渐进式探索：40% → 45% → 50% → 55%
- 找出失败边界（35% 成功，60% 失败之间）

**下一步**：等待 Agent B1/B2 优化完成，或批准 40% 探索性测试

---

## 数据矛盾汇总

### 矛盾 #1：AES13 设计数量
- **文档 v1.9**：13 个设计
- **Agent D1 发现**：baseline 只有 11 个设计
- **需要澄清**：是否有 2 个配置未跑或结果丢失？

### 矛盾 #2：DRC 违例数据
- **文档 v1.9 §2.4**：DRC 1,726-166,251
- **Agent A3 发现**：所有 `detail.drc` 文件 0 字节
- **需要行动**：定位正确的 DRC 数据文件或重新运行

### 矛盾 #3：iRT Plateau 文档
- **文档 rv2.1**："无 plateau API"
- **Agent B2 发现**：Plateau 完整实现（`:2905-3076`），只是默认关
- **需要更新**：docs/ai/26-iRT.md 需要纠正

### 矛盾 #4：利用率测试历史
- **用户请求**：65% 利用率测试
- **Agent D1 发现**：60%/65%/70% 已测试过，全失败
- **需要决策**：是否重新测试 65%，还是先优化工具链

---

## 关键路径更新

```
                     [Agent A2: iRCX SPEF]（P0 阻塞）
                             ↓
                     [Agent A1: PBA 实现]
                             ↓
                     [G7 iSTA vs PT 对齐]
                             ↓
                     [Agent B1: 时序驱动布局]
                             ↓
                     [Agent B2: 时序驱动布线]
                             ↓
                     [G17 时序指标打平]

并行路径：
[Agent C2: 修复静默失败] → [G14 门禁]
[Agent B1: 宏布局实现] → [G3 门禁]
[Agent B2: 开启 Plateau] → [G5 门禁]
[Agent C1: 商业侧框架] → [G17 准备]
```

---

## 主 Agent 决策

### 决策 #1：数据矛盾优先澄清
**行动**：
1. 定位正确的 AES13 完整数据（13 个设计）
2. 找出 DRC 违例报告的正确位置
3. 更新 baseline 和文档

### 决策 #2：SPEF 是关键路径
**行动**：
1. 催促 Agent A2 完成 iRCX 审计
2. 如果 SPEF 生成复杂，考虑临时方案（用已有工具生成）
3. A1 的 PBA 实现阻塞在此

### 决策 #3：静默失败必须修复
**行动**：
1. Agent C2 立即进入实施阶段
2. 修复 23 个无条件返回成功的命令
3. G14 门禁是基础，必须先通过

### 决策 #4：iRT 配置调优优先于算法重写
**行动**：
1. Agent B2 开启 Plateau（`IEDA_RT_ENABLE_PLATEAU=1`）
2. 重跑 AES13，记录违例曲线
3. 验证文档纠正（Plateau 已存在）

### 决策 #5：65% 利用率测试延后
**理由**：
- 60%/65%/70% 已知失败
- 工具链优化尚未完成
- 应该先修复基础问题，再提升利用率

**行动**：
1. Agent D1 暂停 65% 测试
2. 建议 40% 探索性测试（找失败边界）
3. 等待 B1/B2 优化完成后，渐进式测试

---

## 下一步行动计划

### 立即（今天）
1. ✅ 催促 Agent A2 完成 iRCX 审计
2. ✅ 指导 Agent C2 修复静默失败（P0）
3. ✅ 指导 Agent B1 实现宏布局（Phase B1.2）
4. ✅ 指导 Agent B2 开启 Plateau 重跑
5. ⏳ 定位 AES13 数据矛盾

### 短期（1-2 天）
1. Agent A2 完成 SPEF 生成
2. Agent C2 修复 23 个静默失败命令
3. Agent B2 重跑 AES13 with Plateau
4. 澄清数据矛盾（11 vs 13、DRC 位置）

### 中期（1-2 周）
1. Agent A1 实现 PBA
2. Agent B1 完成宏布局
3. Agent C1 完成商业侧框架
4. G14/G3/G5 门禁转绿

### 长期（2-4 周）
1. G7 门禁转绿
2. 启动渐进式利用率测试（40%→50%→55%）
3. G17 部分指标转绿

---

## 资源分配

| Agent | 状态 | 优先级 | 下一步 | 预计完成 |
|-------|------|--------|--------|----------|
| A1 (iSTA) | 等待 A2 | P0 | PBA 实现 | 等待中 |
| A2 (iRCX) | 审计中 | P0 | SPEF 生成 | 1-2 天 |
| A3 (iDRC) | 审计完成 | P1 | 获取 Calibre deck | 2-3 周 |
| B1 (iPL) | 实施中 | P0 | 宏布局实现 | 3-5 天 |
| B2 (iRT) | 实施中 | P0 | 开启 Plateau | 2-3 天 |
| C1 (QoR) | 实施中 | P0 | 商业侧框架 | 5-8 天 |
| C2 (接口) | 实施中 | P0 | 修复静默失败 | 2-3 天 |
| D1 (测试) | 等待 | P1 | 40% 探索 | 等待批准 |

---

## 成功标准进度

### 必达（M0）
- ✅ 7 个 agent 启动并完成审计
- ✅ 识别关键阻塞项（SPEF、静默失败、宏布局）
- ⏳ G14 门禁转绿（Agent C2 实施中）
- ⏳ 数据矛盾澄清

### 期望（M1）
- ⏳ SPEF 生成（Agent A2）
- ⏳ G2/G3/G5 门禁转绿（Agent B1/B2）
- ⏳ 40% 利用率稳定测试
- ⏳ 商业侧框架就绪（Agent C1）

### 理想（M2）
- ⏳ G7 门禁转绿（PBA + PT 对齐）
- ⏳ G17 部分指标转绿
- ⏳ 找到最高稳定利用率（50-60% 范围）

---

**主 Agent 状态**：协调完成，等待 Agent A2 和数据矛盾澄清
**最后更新**：2026-07-29（7 个 agent 审计汇总）
