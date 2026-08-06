# iEDA 完整物理设计流程运行指南

本指南说明如何运行完整的物理设计流程（floorplan → routing → GDS）并生成详细的对比报告。

## 快速开始

### 单个设计

```bash
cd /home/lxq/AiEDA/iEDA.ai/benchmarks
./flows/quick_run_and_report.sh gcd_sky130_a
```

### 多个设计对比

```bash
cd /home/lxq/AiEDA/iEDA.ai/benchmarks

# 运行同一设计的不同PDK版本（跨工艺对比）
./flows/quick_run_and_report.sh aes_sky130_a aes_nangate45_a aes_asap7_a aes_ics55_a

# 运行同一PDK的不同策略版本（策略对比）
./flows/quick_run_and_report.sh aes_sky130_a aes_sky130_b aes_sky130_t

# 运行完整的13个AES设计
./flows/quick_run_and_report.sh \
    aes_sky130_a aes_sky130_b aes_sky130_t \
    aes_nangate45_a aes_nangate45_b aes_nangate45_t \
    aes_asap7_a aes_asap7_b aes_asap7_t \
    aes_ics55_a aes_ics55_b aes_ics55_t \
    aes
```

## 可用设计

### 小型设计（快速测试，<5分钟）
- `gcd_sky130_a` - 最基础的GCD设计，约百门级别

### 中型设计（10-30分钟）
- `aes_sky130_a` - AES加密模块 @ sky130 (面积优化)
- `aes_sky130_b` - AES加密模块 @ sky130 (平衡优化)
- `aes_sky130_t` - AES加密模块 @ sky130 (时序优化)
- `aes_nangate45_a/b/t` - AES @ nangate45 PDK
- `aes_asap7_a/b/t` - AES @ asap7 PDK
- `aes_ics55_a/b/t` - AES @ ics55 PDK
- `aes` - AES基线版本

### 设计命名规则
格式：`<design>_<pdk>_<strategy>`
- **design**: 设计名称 (aes, gcd, picorv32等)
- **pdk**: 工艺库 (sky130, nangate45, asap7, ics55)
- **strategy**: 综合策略
  - `a` = area (面积优化，利用率35%)
  - `b` = balance (平衡优化，利用率30%)
  - `t` = timing (时序优化，利用率25%)

## 输出结果

### 目录结构

运行完成后，会生成以下目录和文件：

```
benchmarks/
├── results/
│   └── flow_YYYYMMDD_HHMMSS/          # 时间戳标记的运行结果
│       ├── aes_sky130_a/               # 每个设计的目录
│       │   └── workspace/
│       │       ├── result/             # 所有输出文件
│       │       │   ├── iFP_result.def      # Floorplan DEF
│       │       │   ├── iPL_result.def      # Placement DEF
│       │       │   ├── iCTS_result.def     # CTS DEF
│       │       │   ├── iRT_result.def      # Routing DEF
│       │       │   ├── final.gds           # 最终GDS
│       │       │   ├── sta/                # 时序报告
│       │       │   ├── power/              # 功耗报告
│       │       │   ├── drc/                # DRC报告
│       │       │   ├── density_map/        # 密度图
│       │       │   └── visualizations/     # 版图可视化
│       │       └── script/             # TCL脚本
│       └── aes_nangate45_a/
│           └── ...
└── reports/
    └── comparison_YYYYMMDD_HHMMSS.md  # 详细对比报告
```

### 报告内容

生成的详细报告（类似 `aes11_detailed_comparison-0.md`）包含：

1. **执行结论**
   - 流程完成度（X/Y 生成 DEF、GDS、STA等）
   - 物理签核质量（DRC clean数量、违例范围）

2. **数据口径与覆盖**
   - 各阶段指标的数据来源和可信度
   - DEF/结构/利用率、时序、功耗、拥塞、DRC、IR-drop

3. **横向总表**
   - 所有设计的关键指标对比
   - Die面积、单元数、Setup WNS、Fmax、功耗、线长、DRC、运行时间

4. **关键横向图**
   - 面积对比柱状图
   - 频率对比图
   - 功耗对比图
   - DRC违例对比图
   - 布线运行时间对比图

5. **空间Map横向对比**
   - 标准单元密度
   - Pin密度
   - EGR overflow
   - 早期布线需求
   - DRC违例密度

6. **同工艺纵向结论**
   - 每个PDK内不同策略的对比分析
   - 利用率对质量的影响

7. **各设计阶段纵向对比**
   - 每个设计的完整阶段表格
   - 运行时间、内存、实例数、核心利用率、HPWL、时序、功耗、DRC
   - 各阶段的版图截图（Floorplan/Placement/CTS/Routing/GDS）
   - 空间Map证据（16张代表图 + 完整原始文件索引）

## 检查结果

### 快速检查

```bash
# 查看报告
cat benchmarks/reports/comparison_<timestamp>.md | less

# 检查某个设计的关键文件
ls -lh benchmarks/results/flow_<timestamp>/aes_sky130_a/workspace/result/

# 查看最终GDS
ls -lh benchmarks/results/flow_<timestamp>/*/workspace/result/final.gds

# 统计DRC违例
grep -r "Total violations" benchmarks/results/flow_<timestamp>/*/workspace/result/drc/
```

### 详细分析

```bash
# 查看某个设计的时序报告
cat benchmarks/results/flow_<timestamp>/aes_sky130_a/workspace/result/sta/timing.rpt

# 查看功耗报告
cat benchmarks/results/flow_<timestamp>/aes_sky130_a/workspace/result/power/power.rpt

# 查看DRC详细报告
cat benchmarks/results/flow_<timestamp>/aes_sky130_a/workspace/result/drc/detail.drc

# 查看版图可视化
ls benchmarks/results/flow_<timestamp>/aes_sky130_a/workspace/result/visualizations/
```

## 高级用法

### 使用底层Python脚本

```bash
cd /home/lxq/AiEDA/iEDA.ai/benchmarks

# 步骤1: 运行物理设计流程
python3 flows/aes13_flow.py \
    --designs gcd_sky130_a \
    --output-root results/my_run \
    --workers 1

# 步骤2: 生成报告
python3 flows/generate_aes11_detailed_report.py \
    --run-root results/my_run \
    --output reports/my_report.md
```

### 并行运行多个设计

```bash
# 使用4个worker并行运行
python3 flows/aes13_flow.py \
    --designs aes_sky130_a aes_nangate45_a aes_asap7_a aes_ics55_a \
    --output-root results/parallel_run \
    --workers 4
```

### 仅生成报告（使用已有结果）

```bash
# 如果已经运行过流程，可以只重新生成报告
python3 flows/generate_aes11_detailed_report.py \
    --run-root results/aes13 \
    --output reports/new_report.md
```

## 常见问题

### Q: 流程运行失败怎么办？

A: 检查日志文件：
```bash
cat benchmarks/results/flow_<timestamp>/<design>/workspace/*.log
```

### Q: 如何修改设计配置（如利用率）？

A: 编辑设计配置文件：
```bash
vim benchmarks/designs/<design>/design.json
# 修改 floorplan.core_utilization 字段
```

### Q: 生成的报告在哪里？

A: 在 `benchmarks/reports/comparison_<timestamp>.md`，也可以用浏览器查看（如果转换为HTML）

### Q: 如何查看版图？

A: 使用KLayout查看GDS：
```bash
klayout benchmarks/results/flow_<timestamp>/<design>/workspace/result/final.gds
```

或查看PNG截图：
```bash
ls benchmarks/results/flow_<timestamp>/<design>/workspace/result/visualizations/
```

## 流程说明

完整的物理设计流程包含以下阶段：

1. **Floorplan (iFP)** - 芯片规划，定义die和core区域
2. **Fanout Fixing (iNO)** - 修复扇出违例
3. **Placement (iPL)** - 标准单元放置
4. **CTS (iCTS)** - 时钟树综合
5. **Timing Optimization (iTO)** - 时序优化（DRV、Hold）
6. **Legalization (iPL_lg)** - 合法化
7. **Routing (iRT)** - 全局和详细布线
8. **Filler (iPL_filler)** - 填充单元插入
9. **GDS Export** - 生成最终GDS

每个阶段都会生成对应的DEF文件和报告。

## 性能参考

| 设计规模 | 单元数 | 预计时间 | 内存占用 |
|---------|--------|---------|---------|
| 小型 (gcd) | ~100 | 1-5分钟 | <2GB |
| 中型 (aes) | ~9K | 10-30分钟 | 2-4GB |
| 大型 | >50K | 1-3小时 | 4-8GB |

*实际时间取决于机器性能和配置*

## 相关文件

- `flows/aes13_flow.py` - 主流程脚本
- `flows/generate_aes11_detailed_report.py` - 报告生成器
- `flows/tcl_generator.py` - TCL脚本生成器
- `flows/flow_manager.py` - 流程管理器
- `designs/REGISTRY.json` - 设计注册表
- `designs/<design>/design.json` - 各设计的配置文件

## 技术支持

如有问题，请检查：
1. iEDA编译是否成功：`ls -lh /home/lxq/AiEDA/iEDA.ai/bin/iEDA`
2. PDK是否正确安装：`ls /home/lxq/AiEDA/Foundary/`
3. 设计配置是否正确：`cat benchmarks/designs/<design>/design.json`
4. 网表文件是否存在：`ls benchmarks/designs/<design>/netlist/`
