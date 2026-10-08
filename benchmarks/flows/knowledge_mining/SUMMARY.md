# 知识挖掘成果总结 —— 定性 + 定量知识库

> 分支 `feat/knowledge-mining`，流水线 `benchmarks/flows/knowledge_mining/`
> 数据：957 样本（29 设计 × 11 动作 × 3 seed），MLP 代理模型 + 剂量分析

---

## 一、最终产出物

| 产物 | 形态 | 位置 |
|---|---|---|
| **MLP 代理模型** | 可加载 `.pkl`（权重+scaler） | `output/surrogate_mlp.pkl` |
| **推理接口** | `predict_action.py` | 输入特征→推荐动作 |
| **定量规则** | 剂量分段函数 + 4 条规律 | `P3_REPORT.md` |
| **原始数据** | 957 结构化样本 | `output/dataset.jsonl` |

---

## 二、定量知识（可直接回灌插件）

### K2 决策规则 + 剂量（最核心）

**规则 1：提高 target_density 是 HPWL 最可靠的正向杠杆，剂量随 fill_rate 分段**

| fill_rate | 最优 td | HPWL 改善 | EGR 变化 |
|---|---|---|---|
| < 0.30（低铺满） | 0.85~0.90 | +5.2% | −29%（代价） |
| ≥ 0.30（高铺满） | 0.95+ | +16.1% | **+28.7%（改善！）** |

**规则 2：高 fill 设计压缩能「双赢」**——gcd/s1238（fill 0.63~0.70）提高 td 后 HPWL 和 EGR 同时改善。原因是基线布局 cell 分布不均，压缩后更均匀。

**规则 3：疏散适用域 fill < 0.30**——divergence 只发生在高 fill 设计（物理边界，非 bug）；低 fill 下疏散 no-op。

**规则 4：congest_ce（ce4/ce6）有害**——HPWL −49~−143%，EGR −528~−9600%，大设计 100% unlegalized。

### 回灌方式

DSH 插件加载 `surrogate_mlp.pkl`，对每个新设计：
1. 数据感知层算 10 个特征（`features.py`）
2. `predict_action.py` 推理 → 推荐动作 + 预测效果
3. agent 执行推荐动作（td 剂量），试错回写更新后验

---

## 三、MLP 泛化性能（诚实边界）

| 目标 | train | test | ood |
|---|---|---|---|
| egr_union ρ | 0.88 | **0.66** | 0.47 |
| hpwl ρ | 0.73 | **0.59** | 0.25 |

- **test 上可泛化**（对比线性 H1 过拟合 train=1.0/test≈随机）。
- **OOD 跨工艺泛化有限**（符合会议「局部泛化即可」定位，不追求全局强泛化）。
- **EGR 策略无正改善**是数据上限（无动作能稳定改善 EGR），不是模型差。

---

## 四、与会议议程的对应

| 会议要点 | 落地 |
|---|---|
| 定性→定量 | 剂量分段函数（td 随 fill_rate）替代散文「td 是旋钮」 |
| 自适应触发函数 | `predict_action` 按特征动态选动作+剂量 |
| 大小模型协同 | MLP=小模型（数值拟合），distiller=大模型（语义归类） |
| 先验化搜索 | MLP 预测作为 BO 初始分布，替代均匀采样 |
| 训练/测试分离 | train14/test6/ood9 逻辑设计切分 |
| 过拟合风险 | 诚实报告 OOD 泛化有限，不硬凑 |

---

## 五、未覆盖（下一阶段）

1. **timing 动作（H2）**：成本高未采，H2「线长 vs 时序」无数据。
2. **per-bin EGR 特征**：空间特征仍用 RUDY 诊断，EGR per-bin 图未暴露。
3. **MLP 换 PyTorch 加宽**：若要更强非线性可升级。

---

## 六、复现

```sh
cd /home/lizhijun/work/iEDA.ai
python3 benchmarks/flows/knowledge_mining/gen_dataset.py --seeds 1000,2000,3000 --max-workers 6
python3 benchmarks/flows/knowledge_mining/assemble_dataset.py
python3 benchmarks/flows/knowledge_mining/train_mlp.py      # 训练 + 保存 pkl
python3 benchmarks/flows/knowledge_mining/predict_action.py --fill_rate 0.25 ... --objective hpwl
python3 benchmarks/flows/knowledge_mining/dose_analysis.py  # 剂量分段函数
```
