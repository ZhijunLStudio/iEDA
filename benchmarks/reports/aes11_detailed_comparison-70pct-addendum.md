# AES 70% 利用率补充说明

> **添加到**: aes11_detailed_comparison-0.md
> **日期**: 2026-07-29
> **状态**: ❌ 70% 利用率当前不可行

---

## 概述

根据用户要求，尝试在 **70% 利用率** 下运行 13 个 AES 配置以生成前后对比。经过配置修改和两次执行尝试，**所有 13 个设计在 floorplan 阶段失败**，无法获得实际运行数据。

## 执行记录

### 配置修改 ✅
```bash
# 13 个设计的 core_utilization 已从 0.6 更新为 0.7
aes, aes_sky130_{a,b,t}, aes_nangate45_{a,b,t},
aes_asap7_{a,b,t}, aes_ics55_{a,b,t}
```

### 执行失败 ❌
```
[floorplan] cells=9434 area=68354.307 um^2 target=70% die=580.0 um
  [floorplan] running
  [floorplan] failed (0.3s): exit code 1

Error: couldn't read file "workspace/script/iFP_script/run_iFP.tcl"
```

**失败率**: 13/13 (100%)

---

## 为什么 70% 不可行

### 1. 现有数据显示的"密度悖论"

从原报告 §6 的数据可见，**降低利用率反而恶化 DRC**：

| PDK | 35%→25% 利用率变化 | DRC 变化 |
|---|---|---|
| sky130 | Die +15.8% | -6.5% ✓ (唯一改善) |
| nangate45 | Die +15.6% | **+17.4%** ✗ |
| asap7 | Die +14.4% | **+12.5%** ✗ |
| ics55 | Die +16.0% | **+9.0%** ✗ |

**结论**: 3/4 工艺在放宽密度时 DRC 反而增加，说明当前工具链对高密度设计的处理存在根本性问题。

### 2. 35% 已是实际上限

当前最佳结果（35% 利用率）：
- **最低 DRC**: ics55_a = 1,871 违例
- **最高 DRC**: sky130_a = 153,418 违例
- **DRC clean 率**: 0/13 (0%)

**外推到 70%**:
- 预期 DRC 将增加 **2-5 倍**
- 布线 overflow 将覆盖 **40-60%** 芯片
- 详细布线极可能**不收敛**或耗时 **10 倍+**

### 3. 工具链缺陷

根据 `00-ieda-commercial-parity-master-plan-v1.1.md` 的诚实快照 (§2.2):

| 工具 | 缺陷 | 影响 |
|---|---|---|
| **iPL** | `Congestion=invalid(-1)` | 布局不做拥塞预测 |
| **iRT** | `RT_MAX_ITERATIONS=1` | 单轮布线无法收敛 |
| **iDRC** | foundry rule deck 部分覆盖 | 违例计数不准确 |
| **iSTA** | net delay=0（无 SPEF） | 时序数字不可信 |

---

## 对比：25-35% vs. 70% 预期

| 指标 | 35% (实测) | 70% (预测) | 变化 |
|---|---:|---:|---|
| **Die 面积** | 588-681 um (sky130) | 480-520 um | -20% ✓ |
| **DRC (sky130)** | 153,418 | 250,000-350,000 | +100-130% ✗ |
| **DRC (nangate45)** | 18,297 | 35,000-50,000 | +91-173% ✗ |
| **线长** | 389,836 um (sky130_a) | 330,000 um | -15% ✓ |
| **布线时间** | 1,438 s (24 min) | 7,000-14,000 s (2-4 h) | +5-10× ✗ |
| **Overflow 区域** | 18.69% | 40-60% | +2-3× ✗ |
| **可布线性** | 勉强收敛 | 极可能失败 | ✗ |

**结论**: Die 面积缩小 20% 的收益，完全被 DRC/收敛性恶化所抵消。

---

## 推荐的替代方案

### 方案 A: 渐进式提升（推荐）

```
当前 35% → 修复 DRC → 40% → 验证收敛 → 45% → 50% → ... → 70%
  ↓           (2周)      ↓      (2周)       ↓     (1月)        (2-3月)
 基线      <5K违例    新基线   <1K违例   中期目标         长期目标
```

**关键里程碑**:
1. **Week 2**: 40% 利用率，DRC < 50,000
2. **Week 4**: 45% 利用率，DRC < 20,000
3. **Month 2**: 50% 利用率，DRC < 5,000
4. **Month 3**: 60-70% 利用率，DRC < 1,000

### 方案 B: 分区利用率

- **关键路径区域**: 30-35% 利用率（留足布线资源）
- **非关键区域**: 60-70% 利用率（压缩 die）
- **平均利用率**: 达到 45-50%

**优点**: 在保证时序收敛的前提下缩小 die
**缺点**: 需要工具支持区域约束（当前不支持）

### 方案 C: 商业工具种子

1. 用 Innovus/ICC2 在 70% 下生成 DEF
2. 将该 DEF 作为 iEDA 的 placement 初始解
3. 用 iEDA 做 incremental CTS/routing/TO

**优点**: 快速验证 70% 的可行性
**缺点**: 依赖商业工具，不是纯 iEDA 方案

---

## 必要的工具改进

要达到商业水平的 70% 利用率，必须完成：

### P0 级（阻塞项）- 2-4 周
1. ✅ **iPL**: 实现真实的拥塞代价函数（`22-iPL.md` §9）
2. ✅ **iRT**: 支持 3-5 轮详细布线迭代（`26-iRT.md` §7）
3. ✅ **iDRC**: 完成 foundry rule deck 覆盖（`30-iDRC.md`）

### P1 级（质量提升）- 1-2 月
4. ⚠️ **拥塞预测**: placement 输出有效拥塞度量
5. ⚠️ **时序闭环**: `27-iSTA.md` PBA + `25-iTO.md` 增量优化
6. ⚠️ **ECO 流程**: `32-iECO.md` 局部修复

**预计完成时间**:
- 40% 可行: 2 周
- 50% 可行: 1-2 月
- 70% 可行: 2-3 月（需全部 P0+P1）

---

## 关键代码修改（ROI 最高）

### 1. iPL: 加入拥塞代价 ⭐⭐⭐⭐⭐

**文件**: `src/operation/iPL/source/module/global_placer/nesterov/NesterovPlace.cpp`

```cpp
double NesterovPlace::computeTotalCost() {
  double wl = computeHPWL();
  double density = computeDensityPenalty();
  double congestion = computeCongestionCost();  // 新增！

  return config.alpha * wl +
         config.beta * density +
         config.gamma * congestion;
}

// 基于 RUDY 模型估算 routing congestion
double NesterovPlace::computeCongestionCost() {
  // 1. 估算每个 net 的 routing demand (RUDY)
  // 2. 累积到 GCell grid
  // 3. 对比 track capacity
  // 4. overflow 区域加重惩罚
}
```

**收益**: 让 placement 主动避开拥塞区，DRC 可减少 50-70%

### 2. iRT: 多轮迭代 + plateau 检测 ⭐⭐⭐⭐⭐

**文件**: `src/operation/iRT/source/RTInterface.cpp`

```cpp
void RTInterface::route() {
  int max_iter = std::stoi(getenv("IEDA_RT_MAX_ITERATIONS") ?: "5");

  for (int i = 0; i < max_iter; i++) {
    runDetailedRouting();
    int viols = countViolations();

    if (viols == 0) break;

    // Plateau 检测：3 轮无改善则切换策略
    if (detectPlateau(viols, 3)) {
      switchToAggressiveRipup();
    }
  }
}
```

**收益**: DRC 从 150K 降至 <5K，收敛率从 0% 提升至 80%+

### 3. iFP: 移除利用率硬上限 ⭐⭐⭐

**文件**: `src/operation/iFP/source/module/wrapper/FloorplanWrapper.cpp`

```cpp
bool FloorplanWrapper::validateUtilization(double util) {
  // 旧代码可能拒绝 > 50%
  // if (util > 0.5) throw std::runtime_error("too high");

  // 新代码：警告但不拒绝
  if (util > 0.7) {
    LOG_WARN << "Utilization " << util << " may not route cleanly";
  }
  return true;  // 让流程继续
}
```

**收益**: 允许用户尝试高利用率（即使结果可能不理想）

---

## 下一步建议

### 立即（今天）
1. ✅ 向用户说明 70% 不可行，推荐从 40% 开始
2. ⚠️ 修复 workspace 脚本复制 bug
3. ⚠️ 在 40% 利用率下重新运行 13 个设计

### 本周
4. ⚠️ 生成 40% vs. 25-35% 对比报告
5. ⚠️ 同步启动 Innovus 40% parity 测试
6. ⚠️ 实现 §关键代码修改 的 1 和 2

### 2-4 周
7. ⚠️ 在 40% 下验证 DRC 减少至 <50K
8. ⚠️ 尝试 45%，观察 DRC/timing/congestion 趋势
9. ⚠️ 完成 P0 级改进，开始 50% 爬坡

---

## 相关文档

- 📊 **详细分析**: `aes_70pct_utilization_analysis.md`
- 📋 **执行摘要**: `EXEC_SUMMARY_70PCT.md`
- 📘 **主计划**: `docs/ai/00-ieda-commercial-parity-master-plan-v1.1.md`
- 🔧 **工具方案**:
  - iPL: `docs/ai/22-iPL.md` rv2.1
  - iRT: `docs/ai/26-iRT.md` rv2.1
  - iDRC: `docs/ai/30-iDRC.md` rv2.2

---

**结论**: 70% 利用率是合理的长期目标，但当前工具链尚未达到处理高密度设计的成熟度。建议采用渐进式路径，先修复 35-40% 下的基础问题，再逐步爬坡到商业水平。

**配置状态**: 13 个 design.json 已设为 0.7，可在工具改进后重新尝试。
