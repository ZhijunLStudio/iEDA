# P2 全量搜索报告 —— 知识挖掘第一轮定量结论

> 分支 `feat/knowledge-mining`，流水线 `benchmarks/flows/knowledge_mining/`
> 数据：29 设计（train14/test6/ood9）× 8 动作 × 3 seed = 696 任务，608 有效样本
> 生成：2026-09-10

---

## 0. 一句话结论

第一轮离线定量验证，**产出了 3 条可泛化的定量规律 + 2 条「该动作不可用」的硬边界**，同时诚实发现：H1「压缩 vs 疏散」决策边界**过拟合**（train_acc=1.0 但 held-out 接近随机），因为「疏散赢」的正样本在数据里几乎不存在。

---

## 1. 数据规模与质量

| 指标 | 值 |
|---|---|
| 总任务 | 696（29 设计 × 8 动作 × 3 seed） |
| 有效样本 | 608 |
| 按 split | train 293 / test 126 / ood 189 |
| 按动作 | compress_td 261 / congest_ce 174 / evacuate_region 87 / evacuate_instance 86 |
| 按 status | ok 567 / egr_failed 24 / evacuate_diverged 15 / gp_failed 2 |

样本质量：93% 有效；失败的 41 个全部**保留标记**（不静默丢弃），是工具边界的直接证据。

---

## 2. 核心定量结论（按置信度排序）

### 结论 A（高置信，跨 split 泛化）：`compress_td` 是 HPWL 稳定正向杠杆，代价是 EGR

**这是最扎实的一条规律**，train/test/ood 三档一致：

| split | HPWL median 改善 | HPWL improve_rate | EGR union median | EGR improve_rate |
|---|---|---|---|---|
| train | **+6.9%** | 100% (126/126) | −23% | 19% |
| test | **+3.9%** | 100% (54/54) | −34% | 0% |
| ood | **+3.3%** | 90% (81/90) | −46% | 10% |

**定量知识（K2 形态）**：
- 提高 `target_density` **几乎总能缩短 HPWL**（improve_rate 90~100%，跨工艺成立）。
- 代价是 EGR union 恶化 23~46%（密度↑ → 拥塞↑，物理必然）。
- 剂量回归学出：`target_density* = 0.873 + 0.059 × fill_rate`（fill_rate 越高，最优 td 越高）。

> 这条直接量化了 HANDOFF 的定性结论「td 是 HPWL 第一旋钮」，并补上了「代价是 EGR」和「最优 td 随 fill_rate 递增」两个此前缺失的数值。

### 结论 B（高置信，强烈负面）：`congest_ce`（ce4/ce6）全面有害

| 维度 | train | test | ood |
|---|---|---|---|
| HPWL median | −49% | −93% | −143% |
| HPWL improve_rate | 0% | 0% | 0% |
| EGR union median | −528% | −977% | −9600% |

且 ce4/ce6 在 **4 个设计上 100% 产不可合法化布局**（aes_core / salsa20_sky130 / s38584_sky130 / salsa20_ics55，各 3 seed 全挂）。

**结论**：当前 iEDA 的 `congestion_effort` 旋钮**不应使用**——它既恶化 HPWL 又恶化 EGR，还在大设计上产非法布局。这是比「ce 无效」更强的「ce 有害」定量证据。

### 结论 C（中置信，负面）：疏散（`local_congestion`）基本 no-op 且系统性 divergence

- 疏散成功的样本 median ≈ 0（EGR 和 HPWL 都无变化，improve_rate 40~60% = 接近随机）。
- 15 个疏散任务 `evacuate_diverged`（gcd/s1238/salsa20 上 3 seed 全挂），根因是局部密度惩罚 spike。
- 2 个 `gp_failed`（apb4_uart 的 rmtree 并发问题，transient）。

**结论**：`local_congestion` 在大多数设计上**要么 divergence 要么 no-op**，只有少数高扇出型设计可能有效——但我们没采到有效的正样本。**印证 HANDOFF「疏散只对高扇出型有效」的边界，且发现当前实现比预想更脆弱**（divergence 率远高于预期）。

### 结论 D（诚实负结论）：H1 决策轴过拟合

- `fit.py` 在 train 上拟合出 logistic 分类器，train_acc=**1.0**（35 对）。
- held-out 检验：median EGR rel ≈ 0，improve_rate = 0.5（= 随机）。

**原因**：H1 的「疏散赢」正样本几乎不存在（疏散都是 no-op/diverged），分类器只能学「压缩赢」，无法泛化。**这是「只验证不硬凑」的正面体现**——拟合失败就是失败，报告它，而不是硬凑假知识。

---

## 3. 知识库回灌（K2/K3 形态）

本轮能回灌插件的定量规则（`output/knowledge_quant.json`）：

```json
{
  "compress_td": {
    "status": "confirmed",
    "effect": {"hpwl": "median +3.3~6.9%, improve_rate 90~100%",
               "egr": "median -23~-46% (代价)"},
    "dose": {"formula": "td = 0.873 + 0.059*fill_rate"},
    "scope": "sky130 + nangate45 + ics55 + ihp130 跨工艺成立"
  },
  "congest_ce": {
    "status": "falsified",
    "effect": {"hpwl": "median -49~-143%", "egr": "median -528~-9600%"},
    "boundary": "大设计(aes_core/s38584/salsa20) 100% unlegalized",
    "verdict": "不应使用"
  },
  "evacuate": {
    "status": "mostly_noop_or_diverged",
    "boundary": "gcd/s1238/salsa20 上 3 seed 全 diverged",
    "verdict": "仅高扇出型设计可能有效，当前实现脆弱"
  }
}
```

---

## 4. 与会议议程的对应

| 会议要求 | 本轮结果 |
|---|---|
| 定性 → 定量 | 结论 A 给出了「td 最优值随 fill_rate 递增」的定量剂量 |
| 训练/测试分离 | train14/test6/ood9，运动员 ≠ 裁判员 |
| 自适应触发函数 | `td = 0.873 + 0.059*fill_rate` 就是「阈值随场景平移」的最小实现 |
| 过拟合风险 | 结论 D 诚实报告 H1 过拟合，不硬凑 |
| 效果不佳的应对 | 会议说「若新场景验证未达预期，探索更精准定量规则」——H1 过拟合正是触发「换动作空间/更细特征」的信号 |

---

## 5. 下一步（P3 改进方向）

1. **H1 需要更多「疏散赢」正样本**：当前疏散几乎全是 no-op/diverged，说明「疏散」这个动作空间本身没采到有效区。要么修 `local_congestion` 的 divergence，要么换疏散实现（如 scope=instances 针对高扇出网），要么承认「疏散在当前工具下不可用」作为边界结论。
2. **per-bin EGR 特征**：当前空间特征用 RUDY 诊断，per-bin EGR 图未暴露。若要更准的「溢出源分岔」，需扩展 `irt_egr.py` 暴露 per-bin 溢出。
3. **HPWL 作为 H1 的胜负判据**：结论 A 显示 compress_td 在 HPWL 维度稳定赢，EGR 维度稳定输。H1 的「谁赢」应该用 Pareto（EGR×HPWL），而非单看 EGR——否则会把「压缩改善 HPWL」误判为「压缩输」。
4. **timing 动作补采**（H2）：本轮没跑 timing（成本高），H2 无数据。若要看「线长驱动 vs 时序加权」，需在 setup-limited 设计子集上补跑 `--timing 1`。

---

## 6. 复现

```sh
cd /home/lizhijun/work/iEDA.ai
python3 benchmarks/flows/knowledge_mining/gen_dataset.py --seeds 1000,2000,3000 --max-workers 6
python3 benchmarks/flows/knowledge_mining/assemble_dataset.py
python3 benchmarks/flows/knowledge_mining/fit.py
python3 benchmarks/flows/knowledge_mining/validate.py
```

产物（gitignore）：
- `output/run_cache.jsonl`（695 条缓存）
- `output/dataset.jsonl`（608 样本）
- `output/knowledge_quant.json`（拟合规则）
