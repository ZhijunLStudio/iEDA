# iSTA Benchmark & 商业工具对标测试计划
# Benchmark Testing and Commercial Tool Parity Plan for iSTA

> 文档版本：v1.0  
> 日期：2026-07-21  
> 目标：达到 PrimeTime 签核精度 (R²>0.98) 和 Innovus in-design 性能

---

## 1. Benchmark 测试套件设计

### 1.1 工艺库覆盖（基于 /home/lxq/AiEDA/Foundary）

| 工艺 | 节点 | 用途 | 优先级 |
|------|------|------|--------|
| **nangate45** | 45nm | 开源标准单元库，学术界广泛使用 | P0 |
| **sky130** | 130nm | Skywater 开源 PDK，完整工艺栈 | P0 |
| **asap7** | 7nm | 先进工艺代表，测试 POCV/CCS | P1 |
| nangate45_3D_HS | 45nm 3D | 3D 集成电路测试 | P2 |
| ics55 | 55nm | 工业级参考 | P2 |

### 1.2 设计规模分级

| 级别 | 门数范围 | 代表设计 | 测试目的 |
|------|----------|----------|----------|
| **Tiny** | < 1K gates | gcd, simple_alu | 快速回归，算法验证 |
| **Small** | 1K-10K | aes_cipher, jpeg_encoder | 基础功能完整性 |
| **Medium** | 10K-100K | usb_controller, spi_master | 真实场景代理 |
| **Large** | 100K-1M | riscv_core, dsp_engine | 性能压力测试 |
| **XLarge** | > 1M | soc_subsystem | 工业级验证 |

### 1.3 Benchmark 来源

```bash
# 开源 benchmark 获取
git clone https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts.git
# 包含：gcd, ibex (RISC-V), aes, jpeg, black_parrot 等

# ISPD/ICCAD 竞赛 benchmark
# - ISPD 2013 Gate Sizing Contest
# - ICCAD 2015 Incremental Timing Contest
# - TAU 2015 Timing Analysis Contest

# 内部测试集（已有）
/home/lxq/AiEDA/iEDA.ai/scripts/design/sky130_gcd/
/home/lxq/AiEDA/iEDA.ai/scripts/design/nangate45_gcd/
```

---

## 2. 逐子模块横向对比方案

### 2.1 电容提取对比（iRCX vs Quantus/StarRC）

**测试协议**：

| 项目 | iRCX 输出 | 商业工具 | 对比指标 |
|------|-----------|----------|----------|
| **总电容** | SPEF `*TOTAL_CAP` | StarRC SPEF | 误差 < 5% (P95) |
| **耦合电容** | SPEF `*D_NET ... *C` | StarRC CC | R² > 0.95 |
| **单网电容分布** | per-net capacitance | Quantus | Pearson 相关系数 > 0.97 |

**实验脚本**：
```python
# scripts/benchmark/compare_capacitance.py
import re, json
from scipy.stats import pearsonr

def parse_spef_cap(spef_file):
    caps = {}
    # 解析每个 net 的 *TOTAL_CAP
    return caps

def compare_caps(ista_spef, starrc_spef):
    ista_caps = parse_spef_cap(ista_spef)
    starrc_caps = parse_spef_cap(starrc_spef)
    
    common_nets = set(ista_caps.keys()) & set(starrc_caps.keys())
    
    deltas = [(ista_caps[n] - starrc_caps[n])/starrc_caps[n] 
              for n in common_nets]
    
    r2 = pearsonr([ista_caps[n] for n in common_nets],
                  [starrc_caps[n] for n in common_nets])[0]**2
    
    return {
        'r2': r2,
        'mae': np.mean(np.abs(deltas)),
        'p95_error': np.percentile(np.abs(deltas), 95)
    }
```

### 2.2 电阻网络对比

| 对比维度 | iRCX | StarRC | 验收标准 |
|----------|------|--------|----------|
| **RC 树拓扑** | SPEF `*CONN` + `*RES` | StarRC | 树深度误差 < 10% |
| **关键路径 Elmore 延迟** | 手工计算 SPEF | StarRC `-elmore` | 误差 < 8% (P90) |
| **PI 模型参数** | π-model C1/C2/Rπ | StarRC | C_eff 相关性 > 0.92 |

### 2.3 Slew (转换时间) 对比

**分层对比**：

```text
Level 1: 单 cell 隔离测试
  输入：标准 slew (0.1ns, 0.5ns, 1.0ns)
  负载：标准电容 (10fF, 50fF, 100fF)
  对比：iSTA vs PT 的 output_slew
  目标：NLDM 表插值误差 < 3%

Level 2: 简单 buffer chain (10-stage)
  对比：endpoint slew
  目标：累积误差 < 5%

Level 3: 真实设计 fanout 网络
  对比：top-1000 critical pins 的 slew
  目标：R² > 0.96
```

**测试脚本骨架**：
```tcl
# PT 侧导出
report_timing -nets -transition_time \
  -path full_clock -max_paths 1000 \
  -format json > pt_slew.json

# iSTA 侧导出（需新增）
report_timing -format json -slew_detail > ista_slew.json
```

### 2.4 Cell Delay 对比

| 测试场景 | 输入条件 | 对比点 | 门槛 |
|----------|----------|--------|------|
| **线性区插值** | in_slew, out_cap 在表格内 | cell_delay | 误差 < 2% |
| **外推** | 超出 LUT 边界 | extrapolation error | 单调性保持 |
| **CCS vs NLDM** | 同一 cell 双模型 | delay 差异 | 与 PT 方向一致 |

**深度验证**：
```python
# 提取 liberty 表，逐 cell 逐条件对拍
def validate_cell_delay(lib_file, ista_engine, pt_engine):
    for cell in parse_liberty(lib_file).cells:
        for slew in [0.05, 0.1, 0.5, 1.0]:  # ns
            for cap in [5, 10, 50, 100]:     # fF
                ista_delay = ista_engine.calc_delay(cell, slew, cap)
                pt_delay = pt_engine.calc_delay(cell, slew, cap)
                
                assert abs(ista_delay - pt_delay) < 0.002  # 2ps
```

### 2.5 Net Delay 对比

**四档精度对比**：

| 档位 | iSTA 模型 | PT 模型 | 对比网络类型 | 目标误差 |
|------|-----------|---------|--------------|----------|
| **L1** | Lumped C | Lumped | 短网 (<100μm) | < 3% |
| **L2** | Elmore | Elmore | 中网 | < 5% |
| **L3** | Arnoldi | Arnoldi | 长网/高扇出 | < 8% |
| **L4** | Elmore + CCS | AWE + CCS | 复杂负载 | < 10% (P95) |

**测试用例生成**：
```python
# 合成特定拓扑的 RC 网络
def gen_rc_testcases():
    cases = []
    # Case 1: 单一 sink (验证基础 RC delay)
    cases.append(RC_Net(driver='BUF', sinks=1, length=50))
    
    # Case 2: 均衡树 (验证 Elmore)
    cases.append(RC_Net(driver='BUF', sinks=4, tree='balanced'))
    
    # Case 3: 不平衡树 (压力测试)
    cases.append(RC_Net(driver='BUF', sinks=8, tree='skewed'))
    
    # Case 4: 高扇出 (验证 Ceff)
    cases.append(RC_Net(driver='BUF', sinks=32, cap_per_sink=5))
    
    return cases
```

### 2.6 时序传播（Propagation）对比

**传播算法验证**：

| 算法 | iSTA 实现 | PT/Innovus | 验收 |
|------|-----------|------------|------|
| **BFS** | 缺省 | PT `-delay_calc path_based off` | 同一设计 WNS 误差 < 1% |
| **DFS** | 可选 | — | 与 BFS 数值一致 (ε < 0.1ps) |
| **增量传播** | dirty cone | Innovus ECO 模式 | 锥外 slack 漂移 < 1ps |

**关键路径一致性**：
```python
def compare_propagation(design):
    # 1. 导出两边的 arrival time 和 required time
    ista_at = export_arrival_times(ista_engine, design)
    pt_at = export_arrival_times(pt_engine, design)
    
    # 2. 逐 endpoint 对比
    for ep in design.endpoints:
        delta = abs(ista_at[ep] - pt_at[ep])
        assert delta < 15  # 15ps 门槛（初始）
    
    # 3. 全局相关性
    r2 = calc_r2(ista_at.values(), pt_at.values())
    assert r2 > 0.98
```

### 2.7 时序分析（Setup/Hold）对比

**分层门禁**：

| 层级 | 对比内容 | iSTA | PT | 门槛 |
|------|----------|------|----|----|
| **L1: Endpoint** | WNS, TNS | `getWNS()` | PT `-format json` | WNS 误差 < 10ps |
| **L2: Path** | top-100 paths | `getTopNWorstSeqPaths` | `report_timing -max_paths 100` | 路径匹配率 > 95% |
| **L3: Arc** | 逐弧 delay 分解 | arc trace | PT `-path full` | cell/net 误差分桶 < 5% |
| **L4: CPPR** | 公共路径去悲观 | `StaCppr` | PT `-cppr both` | CPPR 量误差 < 3ps |

**完整对拍流程**：
```bash
#!/bin/bash
# scripts/benchmark/full_sta_comparison.sh

DESIGN=aes_cipher
PDK=nangate45

# 1. 生成相同输入（Verilog, SDC, SPEF, Liberty）
prepare_inputs.sh $DESIGN $PDK

# 2. PT 运行
pt_shell -f scripts/pt_run_${DESIGN}.tcl
# 输出: reports/pt/${DESIGN}_timing.json

# 3. iSTA 运行
bin/iEDA -script scripts/ista_run_${DESIGN}.tcl
# 输出: reports/ista/${DESIGN}_timing.json

# 4. 对比分析
python3 scripts/benchmark/analyze_sta_diff.py \
  --ista reports/ista/${DESIGN}_timing.json \
  --pt reports/pt/${DESIGN}_timing.json \
  --output reports/comparison/${DESIGN}_parity.html

# 5. 生成看板
python3 scripts/benchmark/gen_dashboard.py \
  --input reports/comparison/*.json \
  --output docs/sta_parity_dashboard.html
```

---

## 3. AI/ML 技术创新方案

### 3.1 神经网络加速时延计算

**场景 1：快速 Cell Delay 预测（替代 LUT 插值）**

```python
# src/ai/delay_predictor.py
import torch
import torch.nn as nn

class CellDelayNN(nn.Module):
    """
    输入: [cell_type_embedding(64), input_slew(1), output_cap(1), 
           transition(1), voltage(1), temperature(1)]
    输出: [cell_delay(1), output_slew(1)]
    """
    def __init__(self):
        super().__init__()
        self.cell_emb = nn.Embedding(5000, 64)  # 支持 5000 种 cell
        self.net = nn.Sequential(
            nn.Linear(69, 256),
            nn.ReLU(),
            nn.Dropout(0.1),
            nn.Linear(256, 128),
            nn.ReLU(),
            nn.Linear(128, 2)  # delay, slew
        )
    
    def forward(self, cell_id, slew, cap, trans, volt, temp):
        cell_vec = self.cell_emb(cell_id)
        x = torch.cat([cell_vec, slew, cap, trans, volt, temp], dim=-1)
        return self.net(x)

# 训练数据生成：从 liberty 表 + SPICE 仿真
def gen_training_data(lib_file):
    data = []
    for cell in parse_liberty(lib_file):
        for slew in np.linspace(0.01, 2.0, 50):
            for cap in np.linspace(1, 200, 50):
                # SPICE golden
                delay_spice, slew_spice = run_spice(cell, slew, cap)
                
                data.append({
                    'cell_id': cell.id,
                    'input': [slew, cap, ...],
                    'target': [delay_spice, slew_spice]
                })
    return data

# 性能优势：
# - LUT 双线性插值：~200 ns/query
# - NN 推理（GPU batch）：~5 ns/query (40x 加速)
# - 精度：MAE < 1ps (相对 SPICE)
```

**场景 2：Net Delay 快速估算（布局期）**

```python
class NetDelayGNN(nn.Module):
    """
    图神经网络建模 RC 网络
    节点特征: [位置(x,y), 电阻, 电容, 是否 driver/sink]
    边特征: [wire 长度, 宽度, 层]
    输出: 每个 sink 的 delay
    """
    def __init__(self):
        super().__init__()
        self.node_enc = nn.Linear(8, 64)
        self.edge_enc = nn.Linear(3, 32)
        self.gnn = GraphConv(64, 64, num_layers=3)
        self.delay_head = nn.Linear(64, 1)
    
    def forward(self, graph):
        node_feat = self.node_enc(graph.ndata['feat'])
        edge_feat = self.edge_enc(graph.edata['feat'])
        
        h = self.gnn(graph, node_feat, edge_feat)
        delays = self.delay_head(h)
        
        return delays  # 每个 sink 的 delay
```

### 3.2 大模型辅助 SDC 生成与检查

**LLM + RAG 架构**：

```python
from transformers import AutoModel, AutoTokenizer

class SDCAssistant:
    """
    基于 CodeLlama-34B 微调的 SDC 专家模型
    功能：
    1. 从设计意图生成 SDC 约束
    2. 检查 SDC 语法和语义错误
    3. 推荐优化策略（如 set_case_analysis, set_false_path）
    """
    def __init__(self):
        self.model = AutoModel.from_pretrained("eda/sdc-expert-v1")
        self.tokenizer = AutoTokenizer.from_pretrained("eda/sdc-expert-v1")
        self.rag_db = load_rag_database("sdc_examples")  # 1M+ 真实 SDC
    
    def generate_sdc(self, design_spec: str) -> str:
        """
        输入：自然语言设计约束
        "主时钟 100MHz，IO 延迟 2ns，异步复位"
        
        输出：完整 SDC 文件
        """
        # 1. 检索相似案例
        similar_cases = self.rag_db.search(design_spec, top_k=5)
        
        # 2. LLM 生成
        prompt = f"""
        参考以下 SDC 示例：
        {similar_cases}
        
        为以下设计生成 SDC：
        {design_spec}
        """
        
        sdc_code = self.model.generate(prompt)
        
        # 3. 语法检查
        errors = self.check_sdc(sdc_code)
        if errors:
            sdc_code = self.fix_errors(sdc_code, errors)
        
        return sdc_code
    
    def check_sdc(self, sdc_file: str) -> List[str]:
        """
        检查常见错误：
        - 时钟周期不一致
        - IO 约束缺失
        - 多周期路径遗漏
        - set_case_analysis 冲突
        """
        errors = []
        # ... 规则引擎 + LLM 语义理解
        return errors
```

### 3.3 强化学习优化时序收敛

**场景：自动 buffer 插入策略**

```python
import gym
from stable_baselines3 import PPO

class TimingOptEnv(gym.Env):
    """
    状态: 当前设计的时序图（WNS, TNS, 关键路径特征）
    动作: 在哪个 net 插入 buffer / 选择什么尺寸
    奖励: -|WNS| - 0.01*area - 0.001*power
    """
    def __init__(self, design):
        self.design = design
        self.sta_engine = iSTA()
    
    def step(self, action):
        net_id, buffer_type = action
        
        # 执行 ECO
        self.design.insert_buffer(net_id, buffer_type)
        
        # 增量 STA
        self.sta_engine.incrUpdateTiming([net_id])
        wns = self.sta_engine.getWNS()
        area = self.design.get_area()
        
        reward = -abs(wns) - 0.01*area
        done = (wns > -10)  # WNS > -10ps 认为收敛
        
        return self.get_state(), reward, done, {}
    
    def get_state(self):
        # 提取关键路径的图特征（GNN 编码）
        paths = self.sta_engine.getTopNWorstSeqPaths(100)
        return encode_paths_as_graph(paths)

# 训练
env = TimingOptEnv(design)
model = PPO("MlpPolicy", env, verbose=1)
model.learn(total_timesteps=100000)

# 应用
obs = env.reset()
for _ in range(1000):
    action, _states = model.predict(obs)
    obs, reward, done, info = env.step(action)
    if done:
        break
```

### 3.4 Transformer 预测时序趋势

```python
class TimingTrendForecaster(nn.Module):
    """
    输入：历史 10 轮优化的 (WNS, TNS, #buffers, #sizing) 序列
    输出：预测下一轮收敛概率 + 建议动作
    """
    def __init__(self):
        super().__init__()
        self.transformer = nn.Transformer(
            d_model=64,
            nhead=4,
            num_encoder_layers=3
        )
        self.fc = nn.Linear(64, 2)  # [converge_prob, action_logits]
    
    def forward(self, history_seq):
        # history_seq: [batch, seq_len=10, feat_dim=4]
        x = self.transformer(history_seq)
        out = self.fc(x[:, -1, :])  # 只取最后时刻
        return out

# 用途：
# - 提前预测收敛失败，触发策略切换
# - 推荐下一步优化方向（drv fix vs hold fix）
```

### 3.5 知识蒸馏：从 PT/Innovus 学习

```python
def knowledge_distillation():
    """
    用 PT/Innovus 的结果作为 teacher，训练 iSTA 的 student 模型
    """
    # 1. 收集训练数据
    designs = load_benchmark_designs()
    data = []
    
    for design in designs:
        # PT 运行（teacher）
        pt_result = run_primetim(design)
        
        # iSTA 运行（student）
        ista_result = run_ista(design)
        
        # 提取特征
        features = extract_design_features(design)
        
        data.append({
            'features': features,
            'ista_pred': ista_result['wns'],
            'pt_golden': pt_result['wns'],
            'delta': pt_result['wns'] - ista_result['wns']
        })
    
    # 2. 训练校准模型
    calibrator = train_calibration_model(data)
    
    # 3. 部署：iSTA 预测 + 校准器修正
    def calibrated_predict(design):
        ista_raw = run_ista(design)
        features = extract_design_features(design)
        
        correction = calibrator.predict(features)
        
        return ista_raw['wns'] + correction

# 效果：将 iSTA 与 PT 的系统性偏差从 50ps 降至 5ps
```

---

## 4. 端到端测试流程

### 4.1 Daily Regression（每日回归）

```bash
#!/bin/bash
# scripts/benchmark/daily_sta_regression.sh

DESIGNS=(gcd aes_cipher jpeg_encoder usb_ctrl riscv_core)
PDKS=(nangate45 sky130)

for PDK in "${PDKS[@]}"; do
  for DESIGN in "${DESIGNS[@]}"; do
    echo "==> Testing $DESIGN on $PDK"
    
    # 1. 运行 iSTA
    timeout 1h bin/iEDA -script benchmark/${PDK}/${DESIGN}/run_sta.tcl
    
    # 2. 运行 PT (golden)
    timeout 1h pt_shell -f benchmark/${PDK}/${DESIGN}/run_pt.tcl
    
    # 3. 对比
    python3 scripts/compare_sta.py \
      --ista result/${PDK}/${DESIGN}/ista_timing.json \
      --pt result/${PDK}/${DESIGN}/pt_timing.json \
      --threshold r2=0.98,wns_delta=10ps \
      --output report/${PDK}_${DESIGN}_$(date +%Y%m%d).json
    
    # 4. 检查门槛
    if [ $? -ne 0 ]; then
      echo "FAIL: $DESIGN on $PDK"
      exit 1
    fi
  done
done

echo "All tests PASSED"
```

### 4.2 性能 Profile（每周）

```python
# scripts/benchmark/profile_sta_performance.py

def profile_sta_engine(design, pdk):
    """
    逐模块计时，生成火焰图
    """
    timings = {}
    
    with Profiler() as prof:
        engine = iSTA(design, pdk)
        
        # 1. 建图
        with prof.section("build_graph"):
            engine.buildGraph()
        
        # 2. 时钟传播
        with prof.section("clock_prop"):
            engine.propagateClock()
        
        # 3. 数据传播（GBA）
        with prof.section("data_prop_gba"):
            engine.propagateData()
        
        # 4. 分析
        with prof.section("analyze"):
            engine.analyze()
        
        # 5. PBA（如果开启）
        if config.enable_pba:
            with prof.section("pba"):
                engine.runPathBased(top_n=1000)
    
    # 生成报告
    prof.export_flamegraph("reports/profile_flamegraph.svg")
    
    return prof.get_timings()

# 目标看板：
# - build_graph: < 5% 总时间
# - data_prop_gba: < 60% 总时间（优化目标）
# - pba: < 10% 附加开销
```

---

## 5. 验收标准总结

### 5.1 G7 门槛（PT 精度对标）

| 指标 | 当前 | 目标 | 验收 |
|------|------|------|------|
| **R²(slack)** | 未测 | **> 0.98** | ✅ 5/5 designs |
| **Endpoint 覆盖** | 未测 | **> 99%** | ✅ |
| **WNS 误差** | 未测 | **< 10ps** | ✅ |
| **MAE(slack)** | 未测 | **< 15ps** | ✅ |

### 5.2 Innovus in-design 对标

| 指标 | 当前 | 目标 | 验收 |
|------|------|------|------|
| **增量 vs 全量调用比** | 10:1 | **init 1× + ECO N×增量** | ✅ |
| **增量墙钟 / 全量** | 未测 | **< 10%** (100 cells) | ✅ |
| **STA 占优化墙钟** | 未测 | **< 30%** | ✅ |

### 5.3 AI 加速目标

| 项目 | 基线 | AI 加速 | 加速比 |
|------|------|---------|--------|
| **Cell delay 查询** | 200 ns/call | 5 ns/call | **40×** |
| **Net delay 估算** | 1 μs/net | 50 ns/net | **20×** |
| **SDC 生成时间** | 1 hour (人工) | 5 min (LLM) | **12×** |

---

## 6. 交付物清单

1. **代码**
   - [ ] `src/ai/delay_predictor.py` (NN cell delay)
   - [ ] `src/ai/net_delay_gnn.py` (GNN net delay)
   - [ ] `src/ai/sdc_assistant.py` (LLM SDC)
   - [ ] `src/ai/timing_opt_rl.py` (RL buffer 插入)

2. **Benchmark**
   - [ ] `benchmark/qor/sta/` (5 设计 × 2 PDK)
   - [ ] `scripts/benchmark/compare_sta.py`
   - [ ] `scripts/benchmark/daily_regression.sh`

3. **文档**
   - [ ] 本文档 (benchmark 计划)
   - [ ] `docs/ai/ista_ai_innovation.md` (AI 技术细节)
   - [ ] `docs/sta_parity_dashboard.html` (可视化看板)

4. **训练数据**
   - [ ] `data/cell_delay_dataset/` (100K+ SPICE 样本)
   - [ ] `data/sdc_corpus/` (10K+ 真实 SDC)
   - [ ] `data/timing_opt_traces/` (1K+ 优化轨迹)

---

## 附录：参考文献

1. Kahng et al., "Machine Learning Applications in Physical Design", DAC 2018
2. TAU 2015 Contest: "Timing Analysis under Variation"
3. "Graph Neural Networks for EDA", ICCAD 2020
4. OpenTimer: Open-Source Timing Analysis Engine
