# iRT 改进效果对比实验计划

## 实验目标

验证 WP-iRT-01 (Plateau Detection)、WP-iRT-02 (Memory Guard) 和 WP-iRT-03 (Adaptive Box Sizing) 对高密度设计（65% utilization）收敛性的改进效果。

## 实验矩阵

| 实验 ID | 改进内容 | 环境变量配置 | 预期效果 |
|---------|---------|-------------|---------|
| **Baseline** | 无改进 | - | box 144/324, OOM @ 12GB |
| **E-01** | Plateau Detection | `IEDA_RT_PLATEAU_CHECK_INTERVAL=36`<br>`IEDA_RT_PLATEAU_EXPLOSION_THRESHOLD=1.5` | box 72-108, 响亮失败 |
| **E-02** | Memory Guard | `IEDA_RT_MAX_MEMORY_MB=8192` | box 100-150, 优雅退出 |
| **E-03** | Box Size=24 (固定) | `IEDA_RT_INITIAL_BOX_SIZE=24`<br>`IEDA_RT_ENABLE_ESCALATION=0` | box 200+, 更好收敛 |
| **E-04** | Box Size=48 (固定) | `IEDA_RT_INITIAL_BOX_SIZE=48`<br>`IEDA_RT_ENABLE_ESCALATION=0` | 可能完成全部 324 |
| **E-05** | Adaptive Size (自动) | `IEDA_RT_DESIGN_UTILIZATION=0.65` | 自动选择 size=48 |
| **E-06** | Escalation 12→24→48 | `IEDA_RT_INITIAL_BOX_SIZE=12`<br>`IEDA_RT_ENABLE_ESCALATION=1` | 平衡速度和收敛 |
| **E-07** | 组合 (01+02+05) | Plateau + Memory + Adaptive | 预期最佳效果 |

## 测试配置

- **设计**: `aes_sky130_a` @ 65% utilization
- **重复次数**: 每个实验 1 次（改进稳定后增加到 3 次）
- **超时**: 2 小时
- **内存限制**: 12 GB（E-02 测试 8GB）
- **输出目录**: `benchmarks/results/improvement_experiments/`

## 对比指标

### 主要指标（优先级递减）

1. **收敛性**: boxes 完成数量（目标: ≥200/324）
2. **稳定性**: 无 OOM，响亮失败（exit code != 0）
3. **质量**: DRC 数量（次要，先关注收敛）

### 次要指标

4. **性能**: 墙钟时间、内存使用峰值
5. **可预测性**: 日志清晰度、诊断信息完整性

## 执行命令

### 前置条件

确保已构建最新的 iEDA 二进制：

```bash
cd /home/lxq/AiEDA/iEDA.ai
scripts/integration/ieda_build.sh clean
```

### 手动执行单个实验

```bash
# Baseline (无改进)
export DESIGN=aes_sky130_a
export UTILIZATION=0.65
export OUTPUT_DIR=benchmarks/results/improvement_experiments/baseline

# 清理旧结果
rm -rf $OUTPUT_DIR

# 运行设计（假设有 run_single_design.py 脚本）
# 如果没有，需要手动进入设计目录执行 run_iEDA.sh
cd benchmarks/designs/${DESIGN}/workspace
bash ../../../scripts/design/sky130_gcd/run_iEDA.sh
# 复制结果到输出目录
cp -r result $OUTPUT_DIR/
```

### E-01: Plateau Detection

```bash
export IEDA_RT_PLATEAU_CHECK_INTERVAL=36
export IEDA_RT_PLATEAU_EXPLOSION_THRESHOLD=1.5
export OUTPUT_DIR=benchmarks/results/improvement_experiments/E-01

# 运行设计
# ... (同上)

unset IEDA_RT_PLATEAU_CHECK_INTERVAL IEDA_RT_PLATEAU_EXPLOSION_THRESHOLD
```

### E-02: Memory Guard

```bash
export IEDA_RT_MAX_MEMORY_MB=8192
export OUTPUT_DIR=benchmarks/results/improvement_experiments/E-02

# 运行设计
# ...

unset IEDA_RT_MAX_MEMORY_MB
```

### E-03: Box Size 24 (Fixed)

```bash
export IEDA_RT_INITIAL_BOX_SIZE=24
export IEDA_RT_ENABLE_ESCALATION=0
export OUTPUT_DIR=benchmarks/results/improvement_experiments/E-03

# 运行设计
# ...

unset IEDA_RT_INITIAL_BOX_SIZE IEDA_RT_ENABLE_ESCALATION
```

### E-04: Box Size 48 (Fixed)

```bash
export IEDA_RT_INITIAL_BOX_SIZE=48
export IEDA_RT_ENABLE_ESCALATION=0
export OUTPUT_DIR=benchmarks/results/improvement_experiments/E-04

# 运行设计
# ...

unset IEDA_RT_INITIAL_BOX_SIZE IEDA_RT_ENABLE_ESCALATION
```

### E-05: Adaptive Size (Auto)

```bash
export IEDA_RT_DESIGN_UTILIZATION=0.65
# IEDA_RT_ENABLE_ESCALATION 默认为 1（启用）
export OUTPUT_DIR=benchmarks/results/improvement_experiments/E-05

# 运行设计
# 预期：根据 65% 利用率自动选择 size=48，并启用 escalation (48→96→192)
# ...

unset IEDA_RT_DESIGN_UTILIZATION
```

### E-06: Escalation 12→24→48

```bash
export IEDA_RT_INITIAL_BOX_SIZE=12
export IEDA_RT_ENABLE_ESCALATION=1
export OUTPUT_DIR=benchmarks/results/improvement_experiments/E-06

# 运行设计
# 预期：12→24→48 escalation
# ...

unset IEDA_RT_INITIAL_BOX_SIZE IEDA_RT_ENABLE_ESCALATION
```

### E-07: Combined (01+02+05)

```bash
export IEDA_RT_PLATEAU_CHECK_INTERVAL=36
export IEDA_RT_PLATEAU_EXPLOSION_THRESHOLD=1.5
export IEDA_RT_MAX_MEMORY_MB=8192
export IEDA_RT_DESIGN_UTILIZATION=0.65
export OUTPUT_DIR=benchmarks/results/improvement_experiments/E-07

# 运行设计
# ...

unset IEDA_RT_PLATEAU_CHECK_INTERVAL IEDA_RT_PLATEAU_EXPLOSION_THRESHOLD
unset IEDA_RT_MAX_MEMORY_MB IEDA_RT_DESIGN_UTILIZATION
```

## 批量执行

使用自动化脚本（见 `run_improvement_experiments.sh`）：

```bash
cd /home/lxq/AiEDA/iEDA.ai
bash benchmarks/qor/run_improvement_experiments.sh
```

## 结果对比

### 手动对比单个实验

```bash
python3 benchmarks/qor/compare_improvements.py \
  --baseline benchmarks/results/improvement_experiments/baseline \
  --improved benchmarks/results/improvement_experiments/E-03 \
  --improvement-id "E-03: Box Size 24" \
  --output benchmarks/results/improvement_experiments/E-03_comparison.md
```

### 批量对比所有实验

```bash
python3 benchmarks/qor/compare_improvements.py \
  --experiments benchmarks/results/improvement_experiments \
  --output benchmarks/results/improvement_experiments/full_comparison_report.md
```

## 成功标准

### 最低要求

- **E-03 或 E-04**: 至少一个完成 ≥200 boxes（62% 进度）
- **E-07**: 组合方案完成 ≥250 boxes（77% 进度）

### 理想目标

- **E-04 或 E-05**: 完成全部 324 boxes（100% 收敛）
- **E-07**: 完成全部 324 boxes + DRC < 1000

### 失败判定

- 所有实验都停留在 <150 boxes（<46% 进度）
- 出现新的 segfault 或未预期的崩溃

## 风险与缓解

### 风险 1: 大 box size 运行时间过长

- **缓解**: 设置 `IEDA_RT_MAX_ITERATIONS=6`（仅运行前 6 轮迭代）

### 风险 2: 内存使用显著增加

- **缓解**: 监控 E-04 和 E-05 的内存使用，必要时降低 box size 到 36

### 风险 3: 结果不稳定（多次运行差异大）

- **缓解**: 每个实验重复 3 次，取中位数

## 后续工作

根据实验结果决定：

1. **如果 E-03/E-04 显著改善**: 将 adaptive sizing 作为默认策略
2. **如果 E-06 (escalation) 最优**: 调整 escalation 参数（例如每 2 轮翻倍而非 3 轮）
3. **如果 E-07 (组合) 效果最佳**: 文档化推荐配置，考虑作为高密度设计的默认设置

## 附录：环境变量快速参考

```bash
# Box Sizing (WP-iRT-03)
export IEDA_RT_INITIAL_BOX_SIZE=24              # 手动指定初始 box size (12, 24, 48)
export IEDA_RT_ENABLE_ESCALATION=1              # 启用 escalation (0=禁用, 1=启用)
export IEDA_RT_DESIGN_UTILIZATION=0.65          # 设计利用率（用于自动选择 box size）

# Plateau Detection (WP-iRT-01)
export IEDA_RT_PLATEAU_CHECK_INTERVAL=36        # 每 N 个 box 检查一次 plateau
export IEDA_RT_PLATEAU_EXPLOSION_THRESHOLD=1.5  # 违例增长 >X 倍触发 plateau

# Memory Guard (WP-iRT-02)
export IEDA_RT_MAX_MEMORY_MB=8192               # 内存预算上限（MB）

# 其他控制
export IEDA_RT_MAX_ITERATIONS=6                 # 最大迭代次数（调试用）
```
