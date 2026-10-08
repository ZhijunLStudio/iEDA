# 知识沉淀改造方案 —— 离线知识挖掘流水线

> 分支：`feat/knowledge-mining`
> 目录：`benchmarks/flows/knowledge_mining/`
> 状态：待审阅（P0 设计稿）
> 生成：2026-09-10

---

## 0. 一句话

把现有「LLM 在环、散文知识」的知识沉淀，改造成「纯 Python 离线驱动 iEDA CLI 做海量对照搜索 → 产出结构化 (x, a, y) → 小模型拟合阈值与剂量 → held-out 检验泛化 → 参数回灌插件」的定量知识流水线。全程 LLM 只退出数据生成，只在「假设声明」处保留语义。

---

## 1. 现状诊断（为什么现在这套不行）

现有 `knowledge_distiller` 插件的三层都在用散文（中文句子），无法拟合：

| 层 | 现状 | 问题 |
|---|---|---|
| 观测 | `delta: {raw: "HPWL→1.136e9(-55%), EGR total→577k"}` | 自由文本，无数值字段 |
| 知识 | `condition.observable: "铺满率很低(≲10-15%)且溢出bin无密簇…"` | LLM 拍的字面量阈值，非学出 |
| 置信度 | `confidence = 0.6 + min(0.3, (n-2)*0.1)` | 写死公式，非学出 |

根因：**LLM 被放在了数据生成的每个环节**。慢、贵、产出不可执行。

改造本质：**把数据底料从散文换成数值，把知识产出从句子换成可执行的 `条件(阈值)→动作+剂量`**。

---

## 2. 核心原则（不可违反）

1. **标签只认 EGR**。效果真值 y 只用 `irt_egr`（trial-route）+ def HPWL + timing。RUDY 一律不作为效果。
2. **RUDY 降级为诊断特征**，不扔掉。「RUDY↔EGR 不一致度」本身是待挖的知识（见 §5.3）。
3. **不硬编码**。阈值、权重、剂量全部从训练集拟合，`prior_spec.json` 里数值字段一律 `null`，由 `fit.py` 填。一行 magic number 都不写死。
4. **数据要细，让模型聚合**。不预先聚成「压缩/疏散」粗桶；动作连续化、特征空间化、指标分解。
5. **效果只信实测**。y 必须来自 `irt_egr`/`def_hpwl_eval`/STA 实测回写，模型不「想象」效果。
6. **运动员 ≠ 裁判员**。训练/测试按逻辑设计切，held-out 在拟合中完全不可见。
7. **只验证、不硬凑**。「拟合不出来」是合法结论，见 §12 exit condition。

---

## 3. 先验假设：十几条压成 3 条决策轴

对 `knowledge.json` 的 20 条按物理动作归类，真实主题是 **3 条决策轴**（其余是重复/变体/反例边界）：

| 轴 | 假设（可证伪） | 覆盖条目 |
|---|---|---|
| **H1 压缩 vs 疏散** | 溢出源是「长网跨空白」→压缩收拢；溢出源是「高扇出汇聚」→疏散摊开。分岔判据可由可测特征拟合。 | 19/20 |
| **H2 线长驱动 vs 时序加权** | 拥塞/密度洁净的 setup-limited 设计，纯线长驱动已恢复大部分 WNS；时序加权只补残余项（扇出/拓扑）。 | 子集 |
| **H3 全局 vs 局部** | 局部热点 + 全局有白空间 → 只动热点格；峰值真超容量 → 全局重解。作用范围是可拟合的。 | 1 |

三条轴的公式形状在 `prior_spec.json` 里声明（§5 特征定义对应字段），数值全 `null`。

---

## 4. 数据采集：海量对照搜索

### 4.1 入口（已验证，无需 dsh、无需 LLM）

- 布局：`benchmarks/flows/gp_agent.py plain`（从 `input_def` + `pl_config` 跑 GP→LG→DP，产出 `placement.def`）。
- 权威指标：`irt_egr.py`（EGR）、`def_hpwl_eval.py`（HPWL）、`gp_timing_paths.py`（timing）。
- 特征源：`gp_congestion_observe.py`（RUDY，诊断用）+ DEF/网表解析（精确特征）。
- 设计注册表：`deepseek_harness/designs.json`（35 key，见 §7 切分）。

### 4.2 动作矩阵（连续化，不是 3 个桶）

| 物理动作 | iEDA 旋钮（连续/有序） |
|---|---|
| 基线 | `plain`（config 默认 td） |
| 压缩 | `plain --target-density {0.60,0.70,0.80,0.85,0.90,0.95}` |
| 加拥塞惩罚 | `start --congestion-effort {0,2,3,4,5,6}` |
| 疏散 | `plain` → `local_congestion`（作用于 EGR 热点 bin，疏散强度 + halo 半径参数化） |
| 时序加权（仅 H2） | `start --timing 1` |

> 注意：疏散/`local_congestion` 会把 cell 移出格点（unlegalized），**所有标签必须在 `accept`(LG+DP) 之后的 `placement.def` 上测**。

### 4.3 两阶段特征（决定 pipeline 形状）

- **阶段 0（pre-PL）**：从 `input_def` + 网表 + config 算——`fill_rate`、`hfanout_ratio`、`die_area`、`cell_count`。
- **阶段 1（post-baseline）**：先跑一次 baseline `plain`，从 placement + EGR 算——`overflow_ratio`、`ws_margin`、`vh_ratio`、`longnet_ratio`、溢出簇局部性、RUDY↔EGR 偏差。

→ 决策函数天然两阶段：廉价跑 baseline → 观察特征 → 决定动作。与现有 `observe → propose → run` 同构，但无 LLM。

### 4.4 规模与并行

- 35 设计 × (1 baseline + ~8 动作) × 3 seed ≈ **800~1000 次 GP 跑**（单次 30s~5min，并行 8~16 → 小时到一天级）。
- 复用 `gp_agent.py` 单发 subprocess（R22 已验证稳定）+ `cachedRun` 缓存。
- **多 seed 是估信噪比，不是多采点**：同一 action 至少 3 seed，算「提升均值 vs 方差」；提升 < 噪声的，不是知识。

---

## 5. 特征词典（x）

### 5.1 精确特征（网表/DEF，不依赖 RUDY/EGR）

| 特征 | 定义 | 类型 |
|---|---|---|
| `fill_rate` | core 已用面积 / core 总面积（= core util） | 0~1 |
| `hfanout_ratio` | fanout > 8 的网数 / 总网数 | 0~1 |
| `hfanout_pin_share` | fanout > 8 网的 pin 总数 / 总 pin | 0~1 |
| `net_bbox_span_p90` | 网 bbox 跨距分布 p90 / die 对角线 | 0~1 |
| `cell_count` | 标准单元数 | 正数（对数归一） |
| `die_aspect` | die 宽 / 高 | 正数 |

### 5.2 EGR 空间特征（真值来源，post-baseline 算）

| 特征 | 定义 | 类型 |
|---|---|---|
| `egr_union` / `egr_max` | 权威 iRT 溢出（标签用，不直接当 x） | 正数 |
| `overflow_ratio` | 溢出 bin 数 / 热点区 bin 数 | 0~1 |
| `overflow_cluster` | 溢出 bin 空间聚类度（最近邻距离均值 / die 尺度） | 0~1 |
| `hotspot_hfanout` | 溢出 bin 内网的平均 fanout | 正数 |
| `ws_margin` | 热点区白空间 / 热点区需求峰值 | 正数 |
| `vh_ratio` | 热点区 V 需求 / H 需求 | 正数 |

### 5.3 RUDY 诊断特征（不丢弃，降级）

| 特征 | 定义 | 意义 |
|---|---|---|
| `rudy_peak` | verify 64×64 plain RUDY peak | 与 egr_max 对照 |
| `rudy_egr_mismatch` | (rudy_peak 归一 − egr_max 归一) 的符号/幅度 | **「RUDY↔EGR 背离度」，待挖的核心知识**：solver 优化 RUDY、我们关心 EGR，背离越大越危险 |

> 设计要点：`rudy_egr_mismatch` 本身可能是「congestion_effort 何时白调」的分岔特征——这是从「RUDY 不准」里挖出的真知识，不是要绕开的问题。

### 5.4 防泄漏约束（hard rule）

特征必须是**决策时点可算**的量。阶段 1 特征只来自 baseline placement + 网表，**绝不用 action 之后才有的量**当输入（否则离线好看、线上用不了）。

---

## 6. 标签（y）：EGR 真值 + Pareto

- **单维**：`egr_union`、`egr_max`、`def_hpwl`、`setup_wns`、`hold_wns`。
- **相对基线归一**：所有 y 转成「相对 plain 基线的提升比例」`(baseline − after)/baseline`，消掉设计规模/工艺的量级差异。
- **多目标 Pareto**：EGR 与 HPWL 反向，单看「EGR 降了」会误判。拟合 **Pareto 面（EGR vs HPWL vs timing）**，知识输出「某动作在 Pareto 上往哪个方向移动多少」，不是标量「降没降」。
- **run status 必录**：`ok / sigsegv / not_converged / cross_design_contamination`，不静默丢弃（防选择偏差）。

---

## 7. 训练/测试切分（运动员 vs 裁判员）

**按逻辑设计切，不是按 design key 切**。`designs.json` 里同一逻辑设计有多个变体 key（`s1238` 与 `s1238_sky130_a` 等），变体必须在同一边，否则是变体泄漏。

| 集合 | 组成 | 用途 |
|---|---|---|
| train | ~15 个 sky130 逻辑设计 | 拟合阈值/剂量 |
| test（held-out） | ~5 个 sky130 逻辑设计 | 泛化检验，拟合中完全不可见 |
| OOD（跨工艺） | nangate45(5) / ics55(4) / ihp130(1) / asap7(1) | 测真泛化（跨工艺分布漂移） |

- `fit.py` 绝不读 test/ood 的任何一行 y。
- `validate.py` 最后只跑一次，报告 train vs test vs OOD 落差。落差大 = 过拟合（对应会议点名的风险）。

---

## 8. 拟合与验证

每条决策轴一个**线性/逻辑回归**（800~1000 样本，线性核抗过拟合，够用不上 NN）：

```
H1 示例：
  score_压缩 = w1·longnet_ratio + w2·(1−fill_rate) + w3·(1−overflow_ratio) + b1
  score_疏散 = w4·overflow_ratio + w5·hfanout_ratio + w6·(1−ws_margin) + b2
  动作 = argmax(压缩, 疏散)
  剂量 td = intercept − k·(1 − fill_rate)
```

- `w1..w6, b1, b2, k, intercept` 全部从 train 学，无 magic number。
- 「多少算低铺满」= 学出的分类边界，不是 LLM 拍的字面量「≲10-15%」。
- **验证 = 同一过程**：`fit.py` 出参数 → `validate.py` 在 test/ood 比对。
  - test 上仍优于基线 → 假设 confirmed。
  - test 上失效 → 进 `falsify_if`，成边界反例，也是知识。

---

## 9. 已知坑的规避清单（实现时逐条核对）

| # | 坑 | 规避 |
|---|---|---|
| 1 | 随机性/方差 | 每 action ≥3 seed，估均值 vs 方差；提升 < 噪声不当作知识 |
| 2 | 未 legalize 就测 | 疏散/`local_congestion` 后必须 `accept`(LG+DP) 再测 |
| 3 | 单目标误判 | Pareto 面（EGR×HPWL×timing） |
| 4 | 规模/工艺量级差异 | 相对基线归一 + 设计身份随机效应 |
| 5 | lookahead 泄漏 | 特征只用决策时点可算量 |
| 6 | 失败运行偏差 | run status 全录，不静默丢弃 |
| 7 | 适用域外推 | test/ood 特征凸包判定，外推必须标注 |
| 8 | 版本漂移 | dataset 记录 iEDA commit / tool version |
| 9 | RUDY 不准 | RUDY 只做诊断特征，y 只认 EGR |

---

## 10. 预期产出的知识（分层，长什么样）

| 层 | 形态 | 示例（具体） | 壁垒 |
|---|---|---|---|
| **K0 工具契约** | 确定性坑 | `bin_cnt 必须 2 的幂`、`util<0.1 用 plain 不用 start` | 低 |
| **K1 场景分类器** | 大模型归类边界 | 「低铺满长网主导」vs「高扇出汇聚」vs「setup-limited 洁净」 | 中 |
| **K2 定量决策规则** | `条件(阈值)→动作+剂量`，参数拟合 | 见下方 JSON | **高（核心）** |
| **K3 先验分布** | 每场景类最优旋钮分布 P(θ*\|c,x) | 「低铺满类」td 最优值集中 0.85~0.92 | 高 |
| **K4 机理注释** | 六段链（审计用） | 保留现有 `condition/decision/mechanism` 句子 | 低 |

**K2 的具体形态**（这是最终要沉淀的核心知识，可执行、非散文）：

```json
{
  "axis": "compress_vs_evacuate",
  "status": "confirmed",
  "features": ["longnet_ratio", "fill_rate", "overflow_ratio", "hfanout_ratio", "ws_margin"],
  "decision": {
    "model": "logistic",
    "score_compress": {"longnet_ratio": 1.2, "fill_rate": -0.8, "overflow_ratio": -0.5, "bias": 0.3},
    "score_evacuate": {"overflow_ratio": 1.5, "hfanout_ratio": 0.9, "ws_margin": -0.7, "bias": -0.2}
  },
  "dose": {
    "target_density": {"formula": "intercept - k*(1 - fill_rate)", "intercept": 0.92, "k": 0.45}
  },
  "evidence": {"n_train": 480, "n_test": 90, "test_acc": 0.78, "ood_acc": 0.61},
  "falsify_if": "OOD 上 accuracy < 0.5 且特征落在凸包外的设计",
  "tool_mapping": {"ieda": "score_compress>score_evacuate → plain --target-density {dose}; 否则 plain → local_congestion"},
  "mechanism_note": "（LLM 写的六段链，审计用，非执行主体）"
}
```

> 参数值是**示意**，最终由 `fit.py` 学出，`prior_spec.json` 里这些字段为 `null`。

---

## 11. 分阶段实施

| 阶段 | 内容 | 产出 |
|---|---|---|
| **P0** | `prior_spec.json`（3 轴假设声明）+ `features.py` 特征定义定稿 | 假设声明 + 特征词典 |
| **P1** | `gen_dataset.py` 在 3 个代表设计跑通矩阵，验证 pipeline + 指标对齐 | 小样本 + 冒烟报告 |
| **P2** | 全量 35 设计海量搜索（并行 + 缓存） | `dataset.jsonl`（800~1000 样本） |
| **P3** | `fit.py` 拟合 + `validate.py` held-out/OOD 检验 | `knowledge_quant.json` + 泛化报告 |
| **P4** | `knowledge_quant.json` 回灌 DSH 插件 K2/K3 | 闭环，替代散文知识 |

---

## 12. exit condition（防自欺底线）

- **拟合成功** = 参数在 test 上显著优于基线，OOD 可接受。
- **拟合失败**（特征够细、样本够多、held-out 仍不收敛）= 诚实结论「这个动作空间里没有可学习的信号」，**换更细的动作或换动作空间**，而不是硬凑一套过拟合假知识交差。

---

## 13. 待用户拍板的决策点

1. 分支名 `feat/knowledge-mining` 是否认可。
2. 搜索规模：直接全量 800~1000 次，还是先 P1 冒烟（3 设计）看结果再放大。
3. H3（全局 vs 局部疏散范围）是否纳入第一版，还是先聚焦 H1。
4. 数据集格式：JSONL（可审计）还是 Parquet（快），倾向 JSONL。

---

## 附：目录结构

```
benchmarks/flows/knowledge_mining/
├── DESIGN.md            # 本方案
├── prior_spec.json      # 3 条假设声明（数值字段 null，由 fit.py 填）
├── features.py          # 数据感知层：input_def/placement/EGR → 归一化特征 x
├── gen_dataset.py       # 海量搜索驱动：并行调 CLI → dataset.jsonl（含缓存）
├── fit.py               # 训练集拟合：阈值 + 剂量权重
├── validate.py          # held-out/OOD 检验：泛化报告
└── output/
    ├── dataset.jsonl        # 原始 (x, a, y) 样本
    └── knowledge_quant.json # 学出的定量规则（回灌插件）
```
