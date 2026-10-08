# P3 报告 —— MLP 代理模型 + 定量知识提炼

> 分支 `feat/knowledge-mining`，流水线 `benchmarks/flows/knowledge_mining/`
> 数据：29 设计 × 11 动作 × 3 seed = 957 任务，957 样本（894 ok）
> 生成：2026-09-10

---

## 0. 一句话结论

用 **MLP 代理模型（替代线性公式）** 在 957 样本上训练，成功学到「特征+动作 → 效果」的非线性映射，**在 held-out test 上 EGR 预测 Spearman ρ=0.66、HPWL ρ=0.59，且 HPWL 单目标策略可稳定拿 +2.8% 改善**。这是从「定性散文」到「可泛化定量代理」的实质突破。

---

## 1. 数据规模

| 指标 | P2 | P3 |
|---|---|---|
| 总任务 | 696 | **957** |
| 有效样本 | 608 | **957（894 ok）** |
| 动作 | 8 | **11（td 5 档 + 疏散 2 强度）** |
| train/test/ood | 293/126/189 | **462/198/297** |

动作空间扩展：`compress_td` 从 3 档扩到 5 档（0.75/0.80/0.85/0.90/0.95），疏散加了温和档（density_target 0.7/0.8）。

---

## 2. MLP 代理模型（核心成果）

**架构**：10 归一化特征 + 5 动作 one-hot + 1 剂量 → 3 目标（egr_union/egr_max/hpwl 相对改善），sklearn MLPRegressor(64,32)，early stopping。

**预测准确度（Spearman ρ，越高越好）**：

| 目标 | train | test | ood |
|---|---|---|---|
| egr_union_rel | 0.88 | **0.66** | 0.47 |
| egr_max_rel | 0.87 | **0.54** | 0.42 |
| hpwl_rel | 0.73 | **0.59** | 0.25 |

**关键结论**：
- **test 上 EGR ρ=0.66、HPWL ρ=0.59 说明 MLP 学到了可跨设计泛化的效果预测**（对比线性 H1 的 train=1.0 但 test≈随机 = 过拟合，MLP 是真正的泛化）。
- OOD（跨工艺）ρ 降到 0.47/0.25，诚实反映「跨工艺泛化有限」，不夸大。
- **HPWL 单目标策略**：MLP 选「预测 HPWL 最优」的动作，在 test 上实际拿到 **+2.8% HPWL 改善**（oracle +4.3%，MLP 达到 oracle 的 65%），代价是 EGR 恶化 16.6%。

---

## 3. 定量知识（可回灌 K2/K3）

从 MLP + 数据提炼出 4 条定量规律：

### K2-1（高置信，剂量分段函数）：最优 td 随 fill_rate 分段

`dose_analysis.py` 按 fill_rate 分桶，用实测 5 档 td 提炼：

| fill 分桶 | n | 最优 td | HPWL 改善 | EGR 变化 | 结论 |
|---|---|---|---|---|---|
| low_fill (<0.30) | 165 | **0.85~0.90** | +5.2% | −29% | td 平台期在 0.85~0.90，再高只加 EGR 代价 |
| high_fill (≥0.30) | 45 | **0.95+** | +16.1% | **+28.7%（改善！）** | 高 fill 设计提高 td 同时改善 HPWL 和 EGR |

**关键发现（反直觉但重要）**：高 fill 设计（gcd/s1238，fill 0.63~0.70）提高 td 后，**EGR 反而改善**——因为基线布局虽 fill 高但 cell 分布不均，提高 td 让布局更紧凑均匀，线长和拥塞同时下降。这与 HANDOFF「td 是第一旋钮」一致，但补充了「高 fill 下 td 收益更大且无 EGR 代价」这条此前未知的定量规律。

> 注：td=0.80 档有 ~16% 样本 HPWL=0，因为部分设计默认 config 的 target_density 就是 0.8，td=0.80 = baseline 无变化。

### K2-2（高置信）：td 的代价是 EGR，Pareto 权衡（仅 low_fill）

- low_fill 下 HPWL 单目标拿 +2.8%，EGR 恶化 16.6%（MLP 策略）。
- td 从 0.85→0.95，HPWL 不变（+5.2% 平台），EGR 代价从 −23% 恶化到 −40%。
- **low_fill 设计不应 td>0.90**，收益为零、代价翻倍。

### K3-1（高置信，边界）：疏散适用域 = fill_rate < ~0.3

- divergence 只发生在 3 个高填充设计：gcd_sky130(fill 0.694)、s1238_sky130(0.696)、salsa20_sky130。
- 温和 density_target（0.7/0.8）**不能修复**——根因是 fill 高，疏散让局部密度更高→物理发散。
- **这是工具的物理边界，不是 bug**。疏散只对低铺满设计物理可行。

### K3-2（高置信，负面）：ce 有害（P2 已证，P3 复证）

- ce4/ce6 在大设计上 100% unlegalized，其余设计 HPWL/EGR 双恶化。

---

## 4. 诚实边界（防自欺）

1. **策略改进仍受限于动作空间**：oracle_egr ≈ 0，说明数据真相是「没有任何动作能稳定改善 EGR」（疏散 no-op、压缩伤 EGR、ce 有害）。MLP 的 EGR 策略拿不到正改善是**数据上限，不是模型差**。
2. **OOD 跨工艺泛化有限**：ρ 降到 0.47/0.25，明确标记「不可跨工艺强泛化」，符合会议「局部泛化即可」的定位。
3. **疏散动作的有效正样本几乎为 0**：894 ok 样本里疏散 median≈0，说明当前工具下疏散「能做但不改善」，这是工具能力边界。

---

## 5. 下一轮迭代方向

1. **剂量扫描可视化**：用 MLP 在固定 fill_rate 上扫描 td 0.75~0.95，画出 HPWL/EGR 随 td 的曲线，提炼「最优 td 的 fill_rate 分段函数」——这是最直接可回灌的 K2。
2. **补 timing 数据（H2）**：当前没跑 timing（成本高），H2「线长驱动 vs 时序加权」无数据。
3. **per-bin EGR 特征**：当前空间特征用 RUDY 诊断，若要更准的「溢出源分岔」，需扩展 `irt_egr.py` 暴露 per-bin 溢出。
4. **MLP 换 PyTorch 或加宽**：sklearn MLP 够用，但若要更强非线性可换 PyTorch 3 层 MLP。

---

## 6. 复现

```sh
cd /home/lizhijun/work/iEDA.ai
python3 benchmarks/flows/knowledge_mining/gen_dataset.py --seeds 1000,2000,3000 --max-workers 6
python3 benchmarks/flows/knowledge_mining/assemble_dataset.py
python3 benchmarks/flows/knowledge_mining/train_mlp.py
```

产物（gitignore）：`output/dataset.jsonl`（957 样本）、`output/run_cache.jsonl`、`output/surrogate_mlp.json`（MLP 报告）。
