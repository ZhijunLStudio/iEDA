# knowledge_mining —— 离线知识挖掘流水线

把 `deepseek_harness/knowledge.json` 的 20 条散文先验压成 3 条可证伪决策轴，
用纯 Python 离线驱动 iEDA CLI 做海量对照搜索，产出结构化 `(特征, 动作, 效果)`，
小模型拟合「阈值 + 剂量」，held-out 检验泛化。**无 LLM、无 DSH、无硬编码数值。**

## 目录

| 文件 | 作用 |
|---|---|
| `DESIGN.md` | 完整方案（目标/架构/动作矩阵/特征词典/切分/坑清单） |
| `prior_spec.json` | 3 条决策轴假设声明（数值字段 `null`，由 `fit.py` 填） |
| `split.json` | train(14)/test(6)/ood(9) 逻辑设计切分 |
| `features.py` | 特征计算（pre_pl + post_baseline，复用现有 DEF/LEF/RUDY parser） |
| `gen_dataset.py` | 离线驱动：动作矩阵 → 缓存 → 并行，产出 run_cache |
| `assemble_dataset.py` | 特征 + metrics 组装 → `output/dataset.jsonl` |
| `fit.py` | 拟合决策边界（阈值）+ 剂量（numpy 手写 logistic/ridge） |
| `validate.py` | held-out/OOD 策略改进率 + 过拟合落差 |

## 用法

```sh
cd /home/lizhijun/work/iEDA.ai

# P1 冒烟：3 个 train 设计跑通全动作矩阵（单 seed）
python3 benchmarks/flows/knowledge_mining/gen_dataset.py \
    --designs gcd_sky130_a,s1238_sky130_a,s1488_sky130_b \
    --seeds 1000 --max-workers 4

# 组装样本
python3 benchmarks/flows/knowledge_mining/assemble_dataset.py

# 拟合（只看 train）
python3 benchmarks/flows/knowledge_mining/fit.py

# 检验（test + ood）
python3 benchmarks/flows/knowledge_mining/validate.py

# P2 全量：20 sky130 + 9 OOD，3 seed
python3 benchmarks/flows/knowledge_mining/gen_dataset.py \
    --seeds 1000,2000,3000 --max-workers 8
```

## 关键约定

- **标签只认 EGR**（`irt_egr`）+ HPWL（`def_hpwl_eval`）+ timing；RUDY 只做诊断特征。
- **疏散/start 必须先 legalize**：`start`/`local_congestion` 产出未合法 GP，`gen_dataset.py` 自动补 `accept`(LG+DP) 再评分。
- **缓存键含 iEDA 二进制 hash**（`build/bin/iEDA`），工具重建才失效，脚本提交不失效。
- **切分单位 = 逻辑设计**（变体 key 必须同边），运动员 ≠ 裁判员。
- **所有数值来自拟合**，`prior_spec.json` 里 null 字段由 `fit.py` 填，无硬编码。

## 产物

- `output/run_cache.jsonl`：每 run 的权威 metrics（幂等缓存，gitignore）
- `output/dataset.jsonl`：结构化样本（gitignore）
- `output/knowledge_quant.json`：学出的定量规则（回灌插件 K2/K3）
