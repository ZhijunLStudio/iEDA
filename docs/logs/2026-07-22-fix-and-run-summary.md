# AES 设计流程运行总结报告

**日期**: 2026-07-22
**任务**: 修复iEDA工具并运行13个AES设计

## 1. 已完成的工作

### 1.1 修复iPL除零错误 ✓

**问题**: `NesterovPlace::initFillerNesInstance()` 函数存在除零错误（SIGFPE）

**修复位置**: 
- 文件: `src/operation/iPL/source/module/global_placer/electrostatic_placer/NesterovPlace.cc`
- 行号: 589-590, 606

**修复内容**:
1. 在计算平均边长时添加除零检查（max_idx - min_idx）
2. 在计算filler数量时添加除零检查（avg_edge_x * avg_edge_y）
3. 添加详细的警告日志，帮助诊断问题

**验证结果**: ✓ 除零错误已修复，不再崩溃

### 1.2 重新编译iEDA ✓

**编译时间**: 2026-07-22 22:31
**二进制文件**: `/home/lxq/AiEDA/iEDA.ai/bin/iEDA` (50MB)
**状态**: 成功

### 1.3 批量运行脚本创建 ✓

创建了以下工具脚本：
- `run_13_aes_batch.sh` - 批量运行13个AES设计
- `monitor_progress.sh` - 监控运行进度
- `generate_comparison_report.py` - 生成对比分析报告

## 2. 发现的新问题

### 2.1 设计配置问题

**问题描述**: 所有单元被标记为固定（Fixed Instances），没有可移动的单元

**表现**:
```
Placed Instances Num : 0
Fixed Instances Num : 7513
```

**根本原因**: 
- Floorplan阶段可能将所有单元标记为固定
- 或者netlist中已经包含布局信息

**影响**: 
- iPL (Placement) 阶段发散（divergence）
- 流程无法继续进行

### 2.2 "No driver pin exist" 警告

**问题**: 大量网络没有驱动引脚
```
Error : No driver pin exist... (重复42次)
```

**可能原因**:
- Netlist质量问题
- DEF解析问题
- 网络连接性问题

## 3. 当前状态

### 3.1 第一次批量运行结果

- **总设计数**: 13
- **成功**: 0
- **失败**: 13
- **失败原因**: 所有设计都在iPL阶段失败（使用旧版本iEDA，有SIGFPE错误）

### 3.2 修复后测试结果

**测试设计**: aes_sky130_a
**结果**: 部分成功
- ✓ 不再崩溃（SIGFPE已修复）
- ✓ iFP阶段完成
- ✓ iTO_fix_fanout阶段完成
- ✗ iPL阶段发散

**生成的文件**:
- `iFP_result.def` (2.5MB)
- `iTO_fix_fanout_result.def` (2.5MB)

## 4. 需要解决的问题

### 4.1 高优先级

1. **修复Fixed Instance问题**
   - 检查为什么所有单元被标记为固定
   - 可能需要修改Floorplan配置或脚本
   - 或者需要使用不同的netlist格式

2. **解决"No driver pin"警告**
   - 验证netlist质量
   - 检查DEF/LEF解析逻辑

### 4.2 中优先级

3. **完善benchmark配置**
   - 验证所有13个设计的配置正确性
   - 确保PDK路径、netlist、SDC文件都存在且正确

4. **调整placement参数**
   - 如果单元确实需要固定，调整placement策略
   - 或者使用增量placement

## 5. 下一步行动计划

### 短期（立即执行）

1. **检查netlist** - 查看aes.v是否包含布局信息
2. **检查Floorplan脚本** - 确认为什么单元被固定
3. **尝试其他设计** - 测试nangate45/asap7的设计是否有相同问题

### 中期（1-2天）

4. **修复配置/脚本** - 解决Fixed Instance问题
5. **重新运行批量测试** - 使用修复后的配置
6. **生成完整报告** - 对比13个设计的PPA指标

### 长期（本周内）

7. **优化flow** - 根据运行结果优化flow参数
8. **完善文档** - 更新使用说明和常见问题
9. **提交修复** - 将iPL修复提交到上游

## 6. 工具和脚本清单

### 6.1 批量运行工具
- `/home/lxq/AiEDA/iEDA.ai/benchmarks/flows/run_13_aes_batch.sh`
- `/home/lxq/AiEDA/iEDA.ai/benchmarks/flows/run_aes_simple.sh`

### 6.2 监控和报告工具
- `/home/lxq/AiEDA/iEDA.ai/benchmarks/flows/monitor_progress.sh`
- `/home/lxq/AiEDA/iEDA.ai/benchmarks/flows/generate_comparison_report.py`

### 6.3 构建工具
- `/home/lxq/AiEDA/iEDA.ai/build_ieda_local.sh`

## 7. 技术细节

### 7.1 修复的代码差异

```cpp
// 修复前：
int avg_edge_x = static_cast<int>(edge_x_sum / (max_idx - min_idx));
int avg_edge_y = static_cast<int>(edge_y_sum / (max_idx - min_idx));
int32_t filler_cnt = std::ceil(static_cast<int32_t>(static_cast<float>(total_filler_area / (avg_edge_x * avg_edge_y))));

// 修复后：
int idx_range = max_idx - min_idx;
if (idx_range <= 0) {
  LOG_WARNING << "Invalid index range for filler calculation";
  idx_range = 1;
  if (!edge_x_assemble.empty()) {
    edge_x_sum = edge_x_assemble[0];
    edge_y_sum = edge_y_assemble[0];
  }
}
int avg_edge_x = static_cast<int>(edge_x_sum / idx_range);
int avg_edge_y = static_cast<int>(edge_y_sum / idx_range);

int32_t filler_cnt = 0;
if (avg_edge_x > 0 && avg_edge_y > 0 && total_filler_area > 0) {
  int64_t filler_area_per_cell = static_cast<int64_t>(avg_edge_x) * static_cast<int64_t>(avg_edge_y);
  filler_cnt = std::ceil(static_cast<float>(total_filler_area) / static_cast<float>(filler_area_per_cell));
} else {
  LOG_WARNING << "Invalid filler parameters - skipping filler insertion";
}
```

### 7.2 编译信息

- **源码目录**: `/home/lxq/AiEDA/iEDA/src/operation/iPL/`
- **构建目录**: `/home/lxq/AiEDA/iEDA/build/`
- **编译器**: gcc 10.4.0 (conda-forge)
- **构建系统**: CMake + Ninja
- **编译时间**: ~2分钟（增量编译）

## 8. 已知限制

1. **环境依赖**: 需要micromamba环境 `ieda-build` (实际指向 `ecc` 环境)
2. **PDK要求**: 需要完整的PDK文件（LEF、LIB等）
3. **内存要求**: 单个设计运行需要~2GB内存
4. **时间估算**: 单个成功流程预计15-30分钟

## 9. 参考文档

- 原始日志: `/home/lxq/AiEDA/iEDA.ai/docs/logs/2026-07-22-aes-flow-setup.md`
- 批量运行日志: `/home/lxq/AiEDA/iEDA.ai/benchmarks/reports/batch_run_20260722_222430.log`
- 测试日志: `/tmp/test_aes_sky130_a.log`

---

**报告生成时间**: 2026-07-22 22:35
**状态**: iPL除零错误已修复，但存在设计配置问题需要进一步调查
**下一步**: 调查Fixed Instance问题，修复后重新运行批量测试
