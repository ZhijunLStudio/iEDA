# iSTA 商业对标与AI创新 - 文档导航

## 📚 文档结构

### 1. 核心技术文档
- **[27-iSTA.md](./27-iSTA.md)** (66KB)
  - 完整的 rv2.0 审计文档
  - 逐模块代码走读 + 症结分析
  - 双对标线：PT 签核精度 × Innovus in-design 性能
  - 包含 HLD/LLD、算法、配置、演进路线图

### 2. Benchmark 测试计划
- **[27-iSTA-benchmark-plan.md](./27-iSTA-benchmark-plan.md)** (20KB)
  - **工艺库覆盖**：nangate45, sky130, asap7, ics55, nangate45_3D_HS
  - **设计规模分级**：Tiny → XLarge (< 1K gates → > 1M gates)
  - **逐子模块横向对比**：
    - 电容提取 (vs StarRC/Quantus)
    - 电阻网络 (RC 树拓扑)
    - Slew 转换时间 (3层验证)
    - Cell Delay (NLDM/CCS 对比)
    - Net Delay (4档精度)
    - 时序传播 (BFS/DFS/增量)
    - Setup/Hold 分析 (4层门禁)
  - **AI/ML 技术创新**：
    - 神经网络加速 Cell Delay (40× 加速)
    - GNN Net Delay 估算 (20× 加速)
    - LLM SDC 生成 (12× 加速)
    - 强化学习 buffer 插入
    - Transformer 趋势预测
    - 知识蒸馏 (PT → iSTA)

### 3. 可视化看板
- **[27-iSTA-visualization.html](./27-iSTA-visualization.html)** (25KB)
  - 交互式 HTML 页面
  - 双对标看板 (PT + Innovus)
  - 子模块对比表格
  - AI/ML 创新卡片
  - 模块状态一览
  - 里程碑路线图 (M0-M5)
  - 关键验证实验

## 🎯 核心目标

### PT 精度对标 (G7)
| 指标 | 目标 |
|------|------|
| R²(slack) | **> 0.98** |
| Endpoint 覆盖 | **> 99%** |
| WNS 误差 | **< 10ps** |
| MAE(slack) | **< 15ps** |

### Innovus in-design 对标
| 指标 | 目标 |
|------|------|
| 全量 vs 增量调用 | **1:N** (从 10:1) |
| 增量墙钟 / 全量 | **< 10%** |
| STA 占优化墙钟 | **< 30%** |
| 引擎统一性 | **1套** (从 3套) |

### AI 加速目标
| 项目 | 加速比 |
|------|--------|
| Cell delay 查询 | **40×** |
| Net delay 估算 | **20×** |
| SDC 生成 | **12×** |

## 🗺️ 演进路线图

```
M0 先量 (1周)
  └─ harness + 首个 align_report
  
M1 可信 (2-3周)
  └─ GBA R² ≥ 0.90
  
M2 主算法 (3-5周)
  └─ top-N PBA + R² ≥ 0.95
  
M3 打平 (5-7周) 🎯
  └─ G7 达标 (R²>0.98)
  
M4 in-design (6-8周)
  └─ 增量契约 + 10→1+N
  
M5 纵深 (8-10周)
  └─ MCMM + SI + GPU + AI
```

## 🔬 测试覆盖

### 工艺库 (PDK)
- ✅ **nangate45** (45nm, P0) - 开源标准库
- ✅ **sky130** (130nm, P0) - Skywater 开源 PDK
- ⏳ **asap7** (7nm, P1) - 先进工艺
- ⏳ **nangate45_3D_HS** (P2) - 3D 集成
- ⏳ **ics55** (55nm, P2) - 工业参考

### Benchmark 来源
```bash
# OpenROAD 开源套件
git clone https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts.git

# ISPD/ICCAD 竞赛
- ISPD 2013 Gate Sizing Contest
- ICCAD 2015 Incremental Timing Contest
- TAU 2015 Timing Analysis Contest

# 内部测试集
/home/lxq/AiEDA/iEDA.ai/scripts/design/{sky130,nangate45}_gcd/
```

## 🤖 AI/ML 技术栈

### 1. 神经网络加速
```python
# Cell Delay Predictor (PyTorch)
class CellDelayNN(nn.Module):
    """40× 加速，MAE < 1ps"""
    
# Net Delay GNN (DGL)
class NetDelayGNN(nn.Module):
    """20× 加速，图结构建模"""
```

### 2. LLM SDC 助手
```python
# CodeLlama-34B + RAG
class SDCAssistant:
    """1M+ SDC 案例库，12× 加速"""
```

### 3. 强化学习优化
```python
# PPO Agent (stable-baselines3)
class TimingOptEnv(gym.Env):
    """自动 buffer 插入策略"""
```

### 4. 知识蒸馏
```python
# Teacher (PT) → Student (iSTA)
"""系统偏差 50ps → 5ps"""
```

## 🚀 快速开始

### 查看可视化看板
```bash
# 在浏览器中打开
firefox /home/lxq/AiEDA/iEDA.ai/docs/ai/27-iSTA-visualization.html
# 或
google-chrome /home/lxq/AiEDA/iEDA.ai/docs/ai/27-iSTA-visualization.html
```

### 运行 Daily Regression
```bash
cd /home/lxq/AiEDA/iEDA.ai
# 待开发
# bash scripts/benchmark/daily_sta_regression.sh
```

### 逐模块对比测试
```bash
# 电容提取对比
# python3 scripts/benchmark/compare_capacitance.py \
#   --ista result/nangate45/gcd/rcx.spef \
#   --starrc golden/nangate45/gcd/starrc.spef

# Cell Delay 验证
# python3 scripts/benchmark/validate_cell_delay.py \
#   --lib /home/lxq/AiEDA/Foundary/nangate45/lib/NangateOpenCellLibrary_typical.lib
```

## 📊 关键数据结构

### PT 对拍 JSON Schema
```json
{
  "tool": "ista|pt",
  "design": "aes_cipher",
  "pdk": "nangate45",
  "unit": "ns",
  "paths": [
    {
      "endpoint": "reg_name/D",
      "startpoint": "reg_name/Q",
      "slack": -0.025,
      "arrival": 1.234,
      "required": 1.209,
      "cppr": 0.003
    }
  ]
}
```

### 增量传播 Trace
```json
{
  "call_site": "iTO::SetupOptimizer",
  "effort": "incremental",
  "n_dirty": 50,
  "n_cone_vertex": 1234,
  "wall_ms": 25
}
```

## 📦 交付物清单

### 代码模块
- [ ] `src/ai/delay_predictor.py` (NN cell delay)
- [ ] `src/ai/net_delay_gnn.py` (GNN net delay)
- [ ] `src/ai/sdc_assistant.py` (LLM SDC)
- [ ] `src/ai/timing_opt_rl.py` (RL buffer)

### Benchmark 脚本
- [ ] `benchmark/qor/sta/` (5 设计 × 2 PDK)
- [ ] `scripts/benchmark/compare_sta.py`
- [ ] `scripts/benchmark/daily_regression.sh`
- [ ] `scripts/benchmark/compare_capacitance.py`
- [ ] `scripts/benchmark/validate_cell_delay.py`

### 训练数据
- [ ] `data/cell_delay_dataset/` (100K+ SPICE)
- [ ] `data/sdc_corpus/` (10K+ 真实 SDC)
- [ ] `data/timing_opt_traces/` (1K+ 优化轨迹)

## 🔗 相关文档

- [00-ieda-commercial-parity-master-plan-v1.1.md](./00-ieda-commercial-parity-master-plan-v1.1.md) - 总纲
- [03-commercial-knowhow-catalog.md](./03-commercial-knowhow-catalog.md) - Know-how 目录
- [24-iPL-3d-rv1.0.md](./24-iPL-3d-rv1.0.md) - 布局器深度审计范例

## 📞 联系方式

- **作者**：iEDA.ai Team
- **机构**：Southeast University EDA Lab
- **日期**：2026-07-21
- **版本**：rv2.0 + Benchmark Plan v1.0

---

**核心理念**：
1. **双对标线**：PT 签核精度 × Innovus in-design 性能
2. **逐模块对比**：每个子模块独立验证，量化门槛
3. **AI/ML 创新**：神经网络加速 + LLM 辅助 + 强化学习优化
4. **可量化验证**：R²、MAE、加速比等硬指标
5. **工业级 Benchmark**：多工艺、多规模、daily 回归
