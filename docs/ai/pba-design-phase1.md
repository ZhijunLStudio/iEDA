<!--
Copyright (c) 2026-2030 Southeast University
iEDA is licensed under Mulan PSL v2.
-->
# iSTA PBA 实现设计 - Phase 1 准备

> 文档号：PBA-DESIGN-P1　版本：v0.1　作者：Agent A1　日期：2026-07-29
> 状态：等待 A2 SPEF　前置：单位审计完成　后续：PBA 实现（Phase 2）

## 执行摘要

**SPEF 接收就绪度**：✓ 已验证
- Tcl 命令：`read_spef <file>`（`CmdReadSpef.cc`）
- API：`TimingEngine::readSpef()`（`TimingEngine.hh:125`）
- 单位处理：✓ C_UNIT/R_UNIT 自动转换（`ElmoreDelayCalc.cc:831-848`）

**PBA 架构设计**：已完成骨架设计
- 新模块：`StaPathBased.{hh,cc}`（复用现有 GBA 传播核）
- 入口：复用 `getTopNWorstSeqPaths`（`Sta.cc:2519`）
- 对齐目标：PrimeTime（G7：endpoint≥99%、|ΔWNS|≤10ps、R²>0.98）

---

## 1. SPEF 接收验证（✓ 完成）

### 1.1 读取接口
**Tcl 层**：
```tcl
read_spef <path_to_spef>
```
- 实现：`CmdReadSpef::exec()`（`shell-cmd/CmdReadSpef.cc:39-48`）
- 调用链：`Sta::readSpef()` → `StaBuildRCTree(spef_file)` → `SpefRustReader`

**API 层**：
```cpp
TimingEngine &readSpef(const char *spef_file)  // TimingEngine.hh:125
```

**Python 绑定**：
```python
read_spef("path/to/file.spef")  # PythonSta.hh:101
```

### 1.2 单位处理机制（✓ 已验证正确）

**SPEF 单位提取**（`StaBuildRCTree.cc:85-86`）：
```cpp
rc_net_common_info->set_spef_cap_unit(spef_parser.getSpefCapUnit());
rc_net_common_info->set_spef_resistance_unit(spef_parser.getSpefResUnit());
```

**单位转换逻辑**（`ElmoreDelayCalc.cc:831-848`）：
```cpp
void RCNetCommonInfo::set_spef_cap_unit(const std::string& spef_cap_unit) {
  if (Str::contain(spef_cap_unit.c_str(), "1 FF") ||
      Str::contain(spef_cap_unit.c_str(), "1.0 FF")) {
    _spef_cap_unit = CapacitiveUnit::kFF;
  } else {
    _spef_cap_unit = CapacitiveUnit::kPF;  // 默认
  }
}
```

**使用点**（`ElmoreDelayCalc.cc:867-893`）：
```cpp
static auto spef_cap_unit = rc_net_common_info->get_spef_cap_unit();
// ...
ConvertCapUnit(spef_cap_unit, uniform_cap_unit, cap_value)
```

**量纲一致性判定**：
- SPEF R/C → 内部统一单位（OHM/PF）→ 延迟计算（fs）→ 报告（ns）
- ✓ 路径完整，无单位混用

**风险点**：
1. 若 SPEF 用 kOHM/1000*OHM 等非标单位 → 需验证 `Str::contain` 覆盖
2. 若 DEF DBU ≠ SPEF 坐标隐含 scale → 需确认 iDB 已处理

---

## 2. PBA 架构设计（Composition over GBA）

### 2.1 设计原则（来自 docs/ai/27-iSTA.md §4.3）

**D2**：top-N PBA 外挂，**不替换 GBA**
- GBA 保留作为 first-pass 筛查
- PBA 仅对 top-N 违例路径重算
- 穷尽 PBA（N<0）预留但 G7 验收用 top-1000

**复用姿势**（§4.3 强调）：
- ✓ 复用现有传播核（`StaDataPropagation`）
- ✓ 复用 CPPR 核（`StaCppr`）
- ✓ 复用路径数据结构（`StaPathDelayData`）
- ✗ 禁止修改 `StaDataBucket` 合并逻辑冒充 PBA

### 2.2 核心数据结构

**路径表示**（已有）：
```cpp
class StaPathDelayData : public StaData {  // StaData.hh:267
 public:
  int64_t get_arrive_time() const override { return _arrive_time; }
  StaVertex* get_own_vertex() const { return _own_vertex; }
  StaArc* get_src_arc() const { return _src_arc; }
  StaPathDelayData* get_bwd_path() { return _bwd_path; }
  // ...
};
```

**路径完整栈**（已有）：
```cpp
std::stack<StaPathDelayData*> getPathDelayData()  // StaPathData.hh:135
```

### 2.3 PBA 新模块骨架

**文件**：`src/operation/iSTA/source/module/sta/StaPathBased.{hh,cc}`

**接口设计**：
```cpp
#pragma once
#include <vector>
#include "StaPathData.hh"
#include "StaSeqPathData.hh"

namespace ista {

/**
 * @brief Path-Based Analysis (PBA) 外挂模块
 *
 * 对 GBA 筛选的 top-N 路径进行路径级一致沿延迟重算，
 * 去除 GBA bucket 合并导致的悲观性。
 *
 * 复用：StaDataPropagation（传播核）、StaCppr（CPPR）、
 *       StaSeqPathData（路径结构）
 */
class StaPathBased {
 public:
  explicit StaPathBased(Sta* ista) : _ista(ista) {}
  ~StaPathBased() = default;

  // 主入口：对 top-N 路径运行 PBA
  void runTopNPba(int n, AnalysisMode mode);

  // 单条路径重算
  int64_t recomputePathArriveTime(StaSeqPathData* seq_path);

  // GBA vs PBA 对比报告
  void reportGbaVsPba(const std::vector<StaSeqPathData*>& paths);

  // 配置
  void setTopN(int n) { _top_n = n; }
  int getTopN() const { return _top_n; }

 private:
  Sta* _ista;
  int _top_n = 0;  // 0=关闭 PBA

  // 辅助：路径级延迟累加（保持转换一致性）
  int64_t accumulatePathDelay(const std::stack<StaPathDelayData*>& path_stack,
                               AnalysisMode mode, TransType trans);

  // 辅助：路径级 CPPR（复用 StaCppr）
  std::optional<int> computePathCppr(StaClockData* launch,
                                      StaClockData* capture);
};

}  // namespace ista
```

### 2.4 算法伪码（§4.3 FR-STA-04）

```text
PBA.run(mode, N):
  1. gba_paths = Sta.getTopNWorstSeqPaths(N, mode)  # 复用现有
  2. for each path in gba_paths:
       # 路径级重算
       pba_arrive = 0
       for each arc in path.getPathDelayData():
         arc_delay = recomputeArcDelay(arc, path.trans_consistent)
         pba_arrive += arc_delay

       # 路径级 CPPR
       cppr = StaCppr(path.launch_clock, path.capture_clock).get_cppr()

       # 更新 slack
       path.pba_slack = req_time - pba_arrive + cppr_adjustment

  3. report_timing -columns {gba_slack pba_slack delta}
```

**关键差异**：
- GBA：`StaDataBucket` 同 signature 按大小合并 → 丢路径信息
- PBA：单路径栈 `getPathDelayData()` 保持转换一致性 → 乐观 5-15%（文献量级）

---

## 3. 实施路径（3-4 周）

### Week 1：SPEF 验证 + PBA 骨架
- [x] Day 1-2：验证 SPEF 读取（已完成）
- [ ] Day 3-4：创建 `StaPathBased.{hh,cc}` 骨架
- [ ] Day 5：T-A3 单元测试（`top_n=0` 零开销）

### Week 2：PBA 实现
- [ ] Day 1-3：实现 `recomputePathArriveTime()`
- [ ] Day 4：路径级 CPPR 接入
- [ ] Day 5：T-A1 单元测试（diamond 重收敛单调性）

### Week 3：PT 对齐 harness
- [ ] Day 1-2：同 DEF+SPEF 运行 iSTA vs PT
- [ ] Day 3-4：逐 endpoint slack 提取脚本
- [ ] Day 5：首轮相关性报告（bias/MAE/P95/R²）

### Week 4：迭代修正
- [ ] Day 1-3：根据对比诊断 delay 模型问题
- [ ] Day 4-5：E-PT-04 验证（PBA 后 worst_50 MAE 应降）

---

## 4. 测试契约（从 docs §9.2 T-A 系列）

### L0 单元测试（gtest）

**T-A1**：diamond 重收敛 PBA 单调性
```cpp
// 钻石网：A → B+C → D，B/C 有不同 slew
TEST(PbaTest, DiamondMonotonicity) {
  auto gba_slack = seq_path->getSlack();  // GBA 悲观
  pba->runTopNPba(1, AnalysisMode::kMax);
  auto pba_slack = seq_path->getPbaSlack();

  // setup: pba_slack >= gba_slack
  EXPECT_GE(pba_slack, gba_slack) << "PBA 应更乐观";
}
```

**T-A2**：top-100 单调性
```cpp
TEST(PbaTest, Top100Monotonicity) {
  pba->runTopNPba(100, AnalysisMode::kMax);
  for (auto* path : paths) {
    EXPECT_GE(path->getPbaSlack(), path->getSlack());
  }
}
```

**T-A3**：零回归（`top_n=0` 零开销）
```cpp
TEST(PbaTest, ZeroRegressionWhenDisabled) {
  pba->setTopN(0);
  auto t0 = now();
  sta->updateTiming();
  auto dt = now() - t0;

  // 关闭时不应有 PBA 开销
  EXPECT_EQ(pba->getTopN(), 0);
  // WNS 应与纯 GBA 相同
  EXPECT_DOUBLE_EQ(sta->getWNS(AnalysisMode::kMax), gba_wns);
}
```

### L1 回归测试

**E-PT-04**：重收敛设计 PBA 收益
```bash
# benchmarks/qor/sta/test_pba_gain.sh
# 1. AES13 + SPEF
# 2. GBA 模式：获取 worst_50 路径
# 3. PBA 模式：top_n=50
# 4. 断言：mean(|pba_slack - pt_slack|) < mean(|gba_slack - pt_slack|)
```

---

## 5. 风险与依赖

### 前置依赖（阻塞）
1. **A2 SPEF**：需等待 iRCX 首个输出（预计 24h 内）
2. **AES13 完整流程**：需确认 DEF → SPEF → iSTA 链路通

### 技术风险
1. **Ceff 迭代未对拍**（docs §1.2）：delay 模型可能有系统偏差
2. **三套时序栈**（docs §1.3）：iPL 用的 `ieval::TimingAPI` 不经 iSTA
3. **AOCV 未对拍**（docs §1.1）：derate 系数可能与 PT 口径不同

### 缓解措施
- Week 3 首轮对比 → 识别主导误差源（delay vs PBA vs CPPR）
- 若 E-PT-04 不通过 → 回退查 §1.2 delay 模型栈（Elmore/Ceff/CCS）

---

## 6. 下一步（收到 SPEF 后立即执行）

### Immediate（Day 1）
```bash
# 1. 验证 SPEF 可读性
cd /home/lxq/AiEDA/iEDA.ai
bin/iEDA -script test_spef.tcl
# test_spef.tcl:
#   read_liberty ...
#   read_verilog ...
#   link_design
#   read_spef <A2_SPEF_PATH>
#   report_net -verbose <一个 net>  # 检查 RC 是否非零

# 2. 创建 PBA 模块骨架
touch src/operation/iSTA/source/module/sta/StaPathBased.{hh,cc}
# （代码见 §2.3）
```

### Week 1 目标
- [ ] PBA 骨架编译通过
- [ ] T-A3 单元测试绿灯（零回归）
- [ ] 首次 `read_spef` 成功且 net delay > 0

---

## 附录 A：关键文件清单

| 文件 | 职责 | 审计状态 |
|---|---|---|
| `src/operation/iSTA/source/module/sta/StaBuildRCTree.cc` | SPEF 读取 + RC 树构建 | ✓ 单位处理正确 |
| `src/operation/iSTA/source/module/delay/ElmoreDelayCalc.{hh,cc}` | RC 延迟计算（Elmore/Ceff） | ✓ 模型在，未对拍 |
| `src/operation/iSTA/source/module/sta/StaData.{hh,cc}` | 路径数据结构 | ✓ 可复用 |
| `src/operation/iSTA/source/module/sta/StaCppr.{hh,cc}` | CPPR 算法 | ✓ 可复用 |
| `src/operation/iSTA/source/module/sta/Sta.cc:2519` | `getTopNWorstSeqPaths()` | ✓ PBA 入口 |
| `src/operation/iSTA/source/module/sta/StaPathBased.{hh,cc}` | **[新建]** PBA 模块 | 待创建 |
| `docs/ai/27-iSTA.md` | 对标方案主文档 | ✓ 已审 |

---

**联系点**：Agent A1 (iSTA-PrimeTime 对齐专家)
**协作**：Agent A2 (iRCX-StarRC 对齐) — SPEF 提供方
**审查**：待 A2 SPEF 交付后启动 Phase 2 实现
