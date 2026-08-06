# AES 65% 利用率测试 - 最终执行报告

**日期**: 2026-07-29
**任务**: 修复所有代码问题，让 65% 利用率的完整流程跑通
**状态**: ✅ Floorplan 100% 成功，完整流程正在运行中

---

## 关键成果

### ✅ Floorplan 阶段：12/12 (100%)

所有 PDK 的 floorplan 全部成功：
- sky130: 3/3 ✓
- nangate45: 3/3 ✓
- asap7: 3/3 ✓
- ics55: 3/3 ✓

### 🔧 修复的关键问题

1. **Top Module 名称错误**
   - 问题：硬编码使用 `aes_cipher_top` 但实际是 `aes`
   - 修复：`aes13_flow.py` line 862，直接使用 `config["top"]`

2. **Netlist 文件选择错误**
   - 问题：RTL 文件 `aes.v` 与综合后的 `aes_cipher_top.v` 混淆
   - 修复：优先使用 `aes_cipher_top.v`，并自动匹配 top module

3. **LEF 文件路径错误**
   - asap7: 使用了 tech lef 而非 cell lef → 修复为 `asap7sc7p5t_27_R_1x_201211.lef`
   - ics55: tlef 不存在 → 修复为 `N551P6M_ieda.lef` (tech) + `ics55_LLSC_H7CR_ieda.lef` (cell)

4. **环境变量配置不完整**
   - 创建了完整的测试脚本 `test_single_65pct.py`，包含所有必需的环境变量

---

## 📊 运行历史

### 修复过程

| 尝试 | 修复内容 | Floorplan 成功率 |
|---|---|---|
| 1 | 初始运行 | 0/12 (0%) |
| 2 | 修复 top module | 6/12 (50%) - sky130 + nangate45 |
| 3 | 修复 netlist 选择 + asap7 LEF | 9/12 (75%) - 加上 asap7 |
| 4 | 修复 ics55 LEF | **12/12 (100%)** ✅ |

### 运行配置

```bash
python3 benchmarks/flows/run_full_flow_65pct.py
```

**参数**:
- 利用率: 65%
- Routing 迭代: 5 轮（在脚本中可配置）
- 超时: placement 30min, routing 2h
- 顺序: 逐个设计完整运行

---

## 🔧 代码修改总结

### 1. benchmarks/flows/aes13_flow.py

**修改 A**: Top module 修复（line 862）
```python
# 修改前
top = "aes_cipher_top" if netlist.name == "aes_cipher_top.v" else config["top"]

# 修改后
top = config["top"]
```

**修改 B**: Netlist 选择修复（line 1105-1113）
```python
else:
    generated_netlist = DESIGNS_ROOT / name / "netlist/aes_cipher_top.v"
    configured_netlist = DESIGNS_ROOT / name / config["inputs"]["netlist"]
    if generated_netlist.is_file():
        netlist = generated_netlist
        config = {**config, "top": "aes_cipher_top"}
    else:
        netlist = configured_netlist
```

**修改 C**: Workspace 初始化增强（line 792-817）
- 多级模板 fallback
- 详细的诊断信息

### 2. benchmarks/flows/test_single_65pct.py (新建)

完整的单设计测试框架：
- 自动检测正确的 netlist 和 top module
- 所有 4 个 PDK 的完整配置
- 所有必需的环境变量
- 详细的成功/失败诊断

**关键逻辑**:
```python
# 自动 netlist 检测
netlist_dir = REPO_ROOT / f"benchmarks/designs/{design_name}/netlist"
if (netlist_dir / "aes_cipher_top.v").exists():
    netlist_file = netlist_dir / "aes_cipher_top.v"
    top_module = "aes_cipher_top"
else:
    netlist_file = netlist_dir / "aes.v"
    top_module = "aes"
```

### 3. benchmarks/flows/run_full_flow_65pct.py (新建)

完整流程脚本，基于成功的测试脚本扩展：
- 运行 floorplan → placement → CTS → routing
- 逐个设计顺序执行
- 详细的阶段状态报告

---

## 📁 交付文件

### 代码文件
- ✅ `benchmarks/flows/aes13_flow.py` (3 处关键修复)
- ✅ `benchmarks/flows/test_single_65pct.py` (测试框架)
- ✅ `benchmarks/flows/run_full_flow_65pct.py` (完整流程)
- ✅ `benchmarks/flows/watch_65pct.sh` (监控脚本)

### 配置文件
- ✅ 13 × `design.json` (core_utilization: 0.65)

### 运行结果
- ✅ 12 × `iFP_result.def` (floorplan 完成，已恢复到 workspace/)
- ⏳ 完整 place→route→gds 流程运行中

### 报告文档
- ✅ `AES_65PCT_EXECUTION_REPORT.md`
- ✅ `AES_FINAL_BREAKTHROUGH_REPORT.md`
- ✅ `AES_执行总结_中文.txt`

---

## 🎯 当前状态与下一步

### 当前状态

**Floorplan**: 12/12 成功 ✅
**完整流程**: 正在运行 ⏳

**已恢复的 workspace**:
- 所有 12 个设计的成功 floorplan 已从 `workspace.stale-*` 恢复
- 包含完整的脚本、配置和 iFP_result.def

### 运行中的流程

```python
for each design in 12 designs:
    run_stage("floorplan")      # ✓ 已完成
    run_stage("placement")      # ⏳ 运行中
    run_stage("cts")            # ⏳ 待运行
    run_stage("routing")        # ⏳ 待运行
```

### 监控命令

```bash
# 实时监控
bash benchmarks/flows/watch_65pct.sh

# 查看日志
tail -f benchmarks/flows/logs/full_flow_final_*.log

# 检查完成数量
find benchmarks/results/aes13_65pct -name "iPL_result.def" | wc -l
find benchmarks/results/aes13_65pct -name "iRT_result.def" | wc -l
find benchmarks/results/aes13_65pct -name "final.gds" | wc -l
```

### 完成后的任务

1. 收集所有 PPA 数据：
   - Area (from DEF)
   - DRC violations (from iDRC reports)
   - Timing (WNS, TNS from iSTA reports)
   - Power (from iPW reports)

2. 生成对比报告：
   - 65% vs 35% 完整对比表
   - 更新 `aes11_detailed_comparison-0.md`

3. 分析结果：
   - 哪些 PDK 在 65% 下表现好
   - DRC 和 timing 是否收敛
   - 与之前 35% 的实际差距

---

## 💡 关键经验教训

### 1. 不要被错误消息误导
- "找不到脚本" → 实际是 top module 错误
- "找不到单元" → 实际是 netlist 文件错误
- "找不到 LEF" → 实际是路径配置错误

### 2. 对比成功案例
- 检查之前成功运行用的配置
- 对比环境变量和文件路径差异
- 查看 design.json 的实际内容

### 3. 创建独立测试框架
- 单设计测试比全流程更快
- 完整环境变量更可靠
- 逐个 PDK 验证和修复

### 4. 直接修复代码，不只是分析
- 找到问题 → 立即修复
- 验证修复 → 继续下一个
- 逐步提升成功率：0% → 50% → 75% → 100%

### 5. 理解工具的行为
- `aes13_flow.py` 会自动归档旧 workspace
- 需要恢复成功的 workspace 才能继续
- 环境变量必须完整且正确

---

## 📊 预期结果

### 成功指标

如果完整流程成功：
- 12 × `iPL_result.def` (placement 完成)
- 12 × `iCTS_result.def` (CTS 完成)
- 12 × `iRT_result.def` (routing 完成)
- 12 × `final.gds` (GDS 生成)

### PPA 数据

将从以下报告收集：
- `workspace/result/report/*.rpt` - DRC, area
- `workspace/result/timing/*.rpt` - Setup/hold timing
- `workspace/result/power/*.rpt` - Power analysis

### 对比报告

将生成：
```
| PDK | Util | Die(um²) | DRC | WNS(ns) | Fmax(MHz) | vs 35% |
|-----|------|----------|-----|---------|-----------|--------|
| sky130 | 65% | XXX | XXX | XXX | XXX | ±X% |
| ... |
```

---

**报告生成**: 2026-07-29 12:57
**Floorplan**: 12/12 成功 ✅
**完整流程**: 运行中 ⏳
**预计完成**: 根据 placement 和 routing 速度，1-3 小时
