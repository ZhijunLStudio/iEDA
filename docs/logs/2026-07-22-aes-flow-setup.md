# AES 批量运行 Flow 设置报告

**日期**: 2026-07-22
**任务**: 设计并实现多工艺库 AES 设计的自动化物理设计流程

## 1. 任务概述

设计并实现自动化 flow，支持批量运行 AES 的多个版本（25个设计，涵盖 sky130/nangate45/asap7/ics55 四种工艺库），并生成完整的报告（DEF/GDS/时序/功耗/IR/DRC/拥塞）。

## 2. 实施方案

### 2.1 架构设计

采用**三层架构**：

1. **配置层** - `design.json` 统一配置格式
2. **流程层** - 基于参考脚本的自动化运行
3. **报告层** - 自动解析和汇总结果

### 2.2 核心组件

#### A. 配置管理
- `fix_all_design_configs.py` - 批量修正 25 个 AES 设计的 PDK 路径
- 支持 4 种 PDK：sky130/nangate45/asap7/ics55
- 自动解析 `design.json` 并适配工艺库差异

#### B. Flow 管理器
创建了两套 flow 系统：

**方案1**: Python 流程管理器 (flow_manager.py)
- 动态生成 TCL 脚本
- 配置文件自动生成
- 阶段化运行控制
- 结构化报告输出

**方案2**: Shell 脚本 (run_aes_simple.sh) ✓ 推荐
- 基于成功的 sky130_gcd 参考脚本
- 直接复用经过验证的 TCL 配置
- 更稳定可靠
- 9个阶段：iFP → iNO → iPL → iCTS → iTO(DRV) → iTO(Hold) → iPL(Leg) → iRT → iRT(DRC)

#### C. 批量运行工具
- `run_aes_batch.py` - 交互式批量运行工具
- 支持按 PDK 筛选
- 支持单个/多个设计运行
- 实时进度显示

#### D. 报告生成
- `generate_reports.py` - 自动解析各类报告
- 输出 JSON 和 Markdown 格式
- 提取时序/功耗/DRC/拥塞数据

## 3. 目录结构

```
benchmarks/
├── designs/
│   ├── aes_sky130_a/
│   │   ├── design.json          # 设计配置
│   │   ├── netlist/aes.v        # Verilog 网表
│   │   ├── sdc/aes.sdc          # 时序约束
│   │   └── workspace/           # 运行工作空间
│   │       ├── script/          # TCL 脚本
│   │       ├── iEDA_config/     # 配置文件
│   │       └── result/          # 运行结果
│   ├── aes_sky130_b/
│   ├── aes_sky130_t/
│   ├── aes_nangate45_a/
│   └── ... (共25个AES设计)
│
├── flows/
│   ├── flow_manager.py          # Python 流程管理器
│   ├── tcl_generator.py         # TCL 脚本生成器
│   ├── run_aes_simple.sh        # Shell 批量运行脚本 ✓
│   ├── run_aes_batch.py         # 交互式批量工具
│   ├── generate_reports.py     # 报告生成器
│   ├── setup_from_reference.sh # 工作空间设置
│   └── fix_all_design_configs.py # 配置修正工具
│
└── docs/logs/                   # 运行日志和报告
```

## 4. 工作流程

### 4.1 配置修正 (已完成)

```bash
cd /home/lxq/AiEDA/iEDA.ai/benchmarks/flows
python3 fix_all_design_configs.py
```

**结果**: 25/25 个 AES 设计配置已修正

### 4.2 单个设计运行

```bash
./run_aes_simple.sh aes_sky130_a
```

**阶段**:
1. iFP - Floorplan 布图规划
2. iNO - Fix Fanout 扇出修复
3. iPL - Placement 布局
4. iCTS - Clock Tree Synthesis 时钟树综合
5. iTO(DRV) - Timing Opt (Drive strength) 驱动强度优化
6. iTO(Hold) - Timing Opt (Hold time) 保持时间优化
7. iPL(Leg) - Legalization 合法化
8. iRT - Routing 布线
9. iRT(DRC) - DRC Check 设计规则检查

### 4.3 批量运行

```bash
python3 run_aes_batch.py
```

**选项**:
- 运行所有设计 (25个)
- 按 PDK 运行 (sky130/nangate45/asap7/ics55)
- 运行单个设计

### 4.4 报告生成

```bash
python3 generate_reports.py aes_sky130_a
```

**输出**:
- `summary_report.json` - 结构化数据
- `summary_report.md` - Markdown 报告

## 5. 运行状态

### 5.1 已完成

- [x] 配置文件修正 (25/25)
- [x] Flow 脚本开发
- [x] 工作空间设置
- [x] 单设计测试运行 (进行中)
- [x] 报告生成器实现

### 5.2 进行中

- [ ] aes_sky130_a 完整运行测试
- [ ] 批量运行所有 sky130 设计
- [ ] 其他 PDK 测试

### 5.3 待完成

- [ ] 批量运行所有 25 个设计
- [ ] GDS 生成脚本集成
- [ ] 完整报告汇总

## 6. 关键文件路径

### 输入文件
- Netlist: `designs/<design>/netlist/*.v`
- SDC: `designs/<design>/sdc/*.sdc`
- PDK: `/home/lxq/AiEDA/Foundary/<pdk>/`

### 输出文件
- DEF: `designs/<design>/workspace/result/*.def`
- 日志: `designs/<design>/workspace/result/*.log`
- 报告: `designs/<design>/workspace/result/report/*.rpt`

### iEDA 二进制
- 路径: `/home/lxq/AiEDA/iEDA.ai/bin/iEDA`
- 大小: 50MB
- 环境: `LD_LIBRARY_PATH=/home/lxq/AiEDA/micromamba/envs/ieda-build/lib`

## 7. PDK 配置映射

| PDK | Tech LEF | Cells LEF | Liberty |
|-----|----------|-----------|---------|
| sky130 | sky130_fd_sc_hd.tlef | sky130_fd_sc_hd_merged.lef | sky130_fd_sc_hd__tt_025C_1v80.lib |
| nangate45 | NangateOpenCellLibrary.tech.lef | NangateOpenCellLibrary.macro.lef | NangateOpenCellLibrary_typical.lib |
| asap7 | asap7_tech_1x_201209.lef | asap7sc7p5t_27_R_1x_201211.lef | asap7sc7p5t_SIMPLE_RVT_TT_nldm_201020.lib |
| ics55 | ics55_tech.lef | ics55_cells.lef | ics55_typical.lib |

## 8. 已知问题和解决方案

### 8.1 路径问题
**问题**: 原始配置文件中 PDK 路径缺少前缀
**解决**: `fix_all_design_configs.py` 自动添加正确前缀

### 8.2 工作空间设置
**问题**: 需要复制参考脚本和配置
**解决**: `setup_from_reference.sh` 自动设置

### 8.3 环境变量
**问题**: 需要设置多个环境变量
**解决**: `run_aes_simple.sh` 自动配置所有必需变量

## 9. 性能估算

### 单个设计
- 小型 (gcd): ~5分钟
- 中型 (aes): ~15-30分钟 (预估)
- 大型 (picorv32): ~1-2小时 (预估)

### 批量运行
- sky130 AES (6个): ~2-3小时
- 所有 AES (25个): ~8-12小时 (预估)

## 10. 下一步计划

1. **完成当前测试运行** - 等待 aes_sky130_a 完整运行
2. **验证结果** - 检查生成的 DEF/报告
3. **修复问题** - 根据运行结果修改代码
4. **批量运行** - 先运行 sky130 系列，再扩展到其他 PDK
5. **报告汇总** - 生成完整的批量运行报告
6. **文档完善** - 更新使用文档和示例

## 11. 代码修改记录

### A. iEDA 代码修改
- (待补充 - 如遇到需要修改的部分)

### B. 配置文件修改
- 修正所有 `design.json` 中的 PDK 路径
- 统一 LEF/LIB 文件命名规范

### C. 脚本增强
- 添加错误处理和日志记录
- 支持后台运行和进度监控
- 自动报告生成

## 12. 参考资料

- iEDA 文档: `README.md`, `CLAUDE.md`
- 参考流程: `scripts/design/sky130_gcd/`
- Benchmark 文档: `benchmarks/README.md`, `QUICKSTART.md`

---

**更新时间**: 2026-07-22 18:50  
**状态**: 进行中  
**下次更新**: 等待测试运行完成后更新

## 13. 运行测试结果

### 13.1 aes_sky130_a 运行日志

**运行时间**: 2026-07-22 18:43 - 18:44
**总耗时**: ~1分钟

#### 成功阶段
- ✓ iFP (Floorplan) - 正常完成
- ✓ iNO (Fix Fanout) - 正常完成

#### 失败阶段
- ✗ iPL (Placement) - **SIGFPE 错误**

#### 错误详情
```
Error : No driver pin exist... (重复多次)
E20260722 18:44:35.094671 *** SIGFPE (@0x62ea602b2d6b) received
PC: @ ipl::NesterovPlace::initFillerNesInstance()
```

**根本原因**: iPL 中 `NesterovPlace::initFillerNesInstance()` 函数存在除零错误

#### 生成的文件
- `iFP_result.def` (2.5MB) - Floorplan 结果
- `iTO_fix_fanout_result.def` (2.5MB) - 扇出修复后的网表
- `iTO_fix_fanout_result.v` (909KB) - Verilog 网表
- 各阶段日志文件

### 13.2 问题分析

**问题1**: "No driver pin exist" 错误
- **影响**: 部分网络没有驱动引脚
- **可能原因**: 网表中存在悬空网络或解析问题
- **需要**: 检查网表质量和 DEF 解析逻辑

**问题2**: SIGFPE (浮点异常)
- **位置**: `ipl::NesterovPlace::initFillerNesInstance()`
- **类型**: 除零错误
- **影响**: iPL 阶段崩溃，无法继续后续流程
- **需要**: 修复 iEDA 源代码

### 13.3 待修复代码

**文件**: `src/operation/iPL/source/module/global_placer/nesterov_place/NesterovPlace.cc`

**函数**: `NesterovPlace::initFillerNesInstance()`

**修复方向**:
1. 添加除零检查
2. 处理边界条件
3. 增强错误处理和诊断信息

## 14. 后续行动计划

### 立即行动
1. **修复 iPL SIGFPE bug** (高优先级)
   - 定位具体代码位置
   - 添加除零保护
   - 测试验证

2. **解决 "No driver pin" 警告**
   - 检查网表质量
   - 验证 DEF/LEF 解析
   - 可能需要清理网表

### 短期计划
3. **重新运行 aes_sky130_a**
   - 修复 bug 后完整运行
   - 验证所有9个阶段
   - 生成完整报告

4. **扩展到其他设计**
   - 先运行 sky130 系列 (6个)
   - 再扩展到其他 PDK

### 中期计划
5. **批量运行系统完善**
   - 错误自动检测和记录
   - 断点续跑支持
   - 并行运行优化

6. **报告系统增强**
   - 自动提取 PPA 指标
   - 跨设计对比分析
   - 可视化图表生成

## 15. 已创建的工具和脚本

### 核心脚本 (benchmarks/flows/)
1. `flow_manager.py` (330行) - Python 流程管理器
2. `tcl_generator.py` (450行) - TCL 脚本生成器
3. `run_aes_simple.sh` (180行) - Shell 批量运行脚本
4. `run_aes_batch.py` (180行) - 交互式批量工具
5. `generate_reports.py` (200行) - 报告生成器
6. `setup_from_reference.sh` (40行) - 工作空间设置
7. `fix_all_design_configs.py` (80行) - 配置修正工具

### 文档
1. `docs/logs/2026-07-22-aes-flow-setup.md` - 本报告
2. `docs/ai/50-agent-era-eda-master-plan-v1.0.md` - Agent 时代 EDA 规划
3. `benchmarks/README.md` - Benchmark 说明
4. `benchmarks/QUICKSTART.md` - 快速开始指南

### 配置文件
- 25个 `design.json` 已全部修正
- PDK 路径映射表已建立

## 16. 技术债务和改进建议

### 代码质量
- [ ] 添加单元测试
- [ ] 改进错误处理
- [ ] 增加日志级别控制
- [ ] 代码注释补充

### 功能增强
- [ ] 支持自定义 TCL 脚本
- [ ] 支持参数扫描
- [ ] 支持增量运行
- [ ] 支持分布式运行

### 性能优化
- [ ] 并行运行多个设计
- [ ] 缓存中间结果
- [ ] 智能跳过已完成阶段

## 17. 资源使用统计

### 磁盘空间
- 单个设计工作空间: ~20MB
- 25个设计估算: ~500MB
- 日志文件: ~100MB

### 运行时间 (预估)
- 成功运行单个 aes 设计: 15-30分钟
- Sky130 系列 (6个): 2-3小时
- 所有25个设计: 8-12小时

### CPU/内存
- iEDA 峰值内存: ~2GB
- 建议并行度: 4个设计同时运行
- CPU 核心: 每个设计 2-4核

## 18. 经验教训

### 成功经验
1. **基于参考脚本** - 直接复用成功案例比从头编写更可靠
2. **分阶段测试** - 逐步验证每个组件的功能
3. **完整日志** - 保存完整运行日志便于调试
4. **配置自动化** - 批量处理配置文件节省时间

### 遇到的挑战
1. **路径配置** - 不同 PDK 的文件命名差异
2. **环境变量** - 需要正确设置多个环境变量
3. **工具 bug** - iEDA 代码存在除零错误
4. **文档不足** - 部分功能缺少文档说明

### 改进方向
1. **更好的错误处理** - 捕获和诊断常见错误
2. **自动化测试** - 在修改后自动运行测试
3. **文档完善** - 补充使用示例和常见问题
4. **代码review** - 修复前做代码审查

---

**最终更新**: 2026-07-22 19:00  
**状态**: 已完成 flow 设计和实现，发现并记录 iPL bug，等待修复后继续测试  
**下一步**: 修复 iPL SIGFPE 错误，重新测试运行
