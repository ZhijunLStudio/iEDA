# WP-iRT-01 + WP-iRT-02 实验计划

**日期**: 2026-07-30
**目标**: 验证两个改进的实际效果，决定是否需要 WP-iRT-03

---

## 🎯 实验目标

### 主要目标
1. **验证响亮失败** - Plateau detection 能否检测到违例爆炸
2. **验证资源保护** - Memory budget 能否防止 OOM
3. **验证诊断质量** - 生成的诊断信息是否有用
4. **验证用户体验** - 相比之前的静默失败是否改善

### 次要目标
5. 确定最优的配置参数（check interval, threshold）
6. 收集数据为 WP-iRT-03 提供依据

---

## 🧪 实验设计

### 测试设计
- **Design**: aes_sky130_a
- **Utilization**: 65%（已知会触发违例爆炸）
- **Binary**: 包含 WP-iRT-01 + WP-iRT-02 的新版本

### 实验矩阵

| 实验 | Check Interval | Threshold | Memory Budget | 预期 |
|------|---------------|-----------|---------------|------|
| **Exp 1** | 36 boxes | 1.5 (150%) | 8192 MB | 在 box 72-108 检测 |
| **Exp 2** | 24 boxes | 1.2 (120%) | 4096 MB | 更早检测（box 48-72） |
| **Exp 3** | 48 boxes | 2.0 (200%) | 8192 MB | 更晚检测（box 108-144） |

### 对比维度

#### 1. 收敛性
- Box 完成数量（预期：72-144/324）
- 违例数量和增长趋势
- 是否完成布线

#### 2. 稳定性
- 是否触发 plateau detection
- 是否触发 memory budget
- 是否 OOM（应该不会）
- 退出码（应该非零）

#### 3. 诊断质量
- `plateau_diagnostic.json` 内容
- `memory_diagnostic.json` 内容
- 日志中的错误消息
- 改进建议是否可执行

#### 4. 运行时间
- 墙钟时间（预期：30-90 分钟）
- 相比之前 OOM 前的时间
- 节省的时间（避免等待 OOM）

---

## 📊 预期结果

### Exp 1（默认配置）
```
Box 进度: 72-108/324
触发 plateau: ✅ 是
触发 memory: ❌ 否（内存未超限）
运行时间: ~45-60 分钟
诊断 JSON: plateau_diagnostic.json ✅
退出码: 非零 ✅
用户体验: 清晰的错误消息和建议 ✅
```

### Exp 2（严格配置）
```
Box 进度: 48-72/324（更早检测）
触发 plateau: ✅ 是
触发 memory: ⚠️ 可能（预算较低）
运行时间: ~30-45 分钟（更早退出）
诊断 JSON: 两个都可能有 ✅
建议: 可能会建议增加内存或降低利用率
```

### Exp 3（宽松配置）
```
Box 进度: 108-144/324（更晚检测）
触发 plateau: ✅ 是（但更晚）
触发 memory: ❌ 否
运行时间: ~60-90 分钟
诊断 JSON: plateau_diagnostic.json ✅
风险: 可能接近 OOM（但应该被保护）
```

---

## 🎯 成功标准

### 必须达到（P0）
1. ✅ 所有实验都不会 OOM
2. ✅ 至少一个实验触发 plateau detection
3. ✅ 生成有效的诊断 JSON
4. ✅ 日志中有清晰的错误消息
5. ✅ 返回非零退出码

### 期望达到（P1）
6. ✅ Plateau 在预期的 box 范围内触发
7. ✅ 诊断信息包含可执行的建议
8. ✅ 运行时间显著短于之前（< 90 分钟）
9. ✅ 不同配置的行为符合预期

### 加分项（P2）
10. ✅ Memory budget 在 Exp 2 中触发
11. ✅ 能生成 partial DEF（如果 memory 触发）
12. ✅ 诊断数据足以指导 WP-iRT-03 的实现

---

## 📋 执行步骤

### 1. 准备环境
```bash
cd /home/lxq/AiEDA/iEDA.ai

# 确认新二进制存在
ls -lh /home/lxq/AiEDA/iEDA/bin/iEDA

# 确认测试脚本存在
ls -lh run_experiments_WP-iRT-01-02.sh
```

### 2. 运行实验
```bash
# 执行三个实验（预计总时间 2-4 小时）
./run_experiments_WP-iRT-01-02.sh
```

### 3. 收集结果
实验完成后，检查：
- `benchmarks/results/experiment_WP-iRT-01-02/exp*.log` - 运行日志
- `benchmarks/results/experiment_WP-iRT-01-02/exp*/*/workspace/result/*.json` - 诊断文件

### 4. 分析结果
使用对比工具：
```bash
python3 benchmarks/qor/compare_improvements.py \
  --experiments benchmarks/results/experiment_WP-iRT-01-02 \
  --output benchmarks/results/experiment_WP-iRT-01-02/comparison_report.md
```

---

## 🔍 关键观察点

### 在实验过程中观察

#### 日志输出
```bash
# 实时监控日志（在另一个终端）
tail -f benchmarks/results/experiment_WP-iRT-01-02/exp1_*.log
```

**寻找关键信息**:
- `[INFO] Plateau detection enabled`
- `[INFO] Routed XX/324 boxes with XXXXXX violations`
- `[ERROR] VIOLATION EXPLOSION DETECTED!`
- `[ERROR] Box progress: XX/324`
- `[ERROR] Recommendation: ...`

#### 进程状态
```bash
# 监控内存使用
top -p $(pgrep iEDA)

# 或者
watch -n 5 'ps aux | grep iEDA | grep -v grep'
```

---

## 📈 结果评估标准

### 改进有效性矩阵

| 指标 | Before（无改进） | After（WP-iRT-01+02） | 改进程度 |
|------|----------------|---------------------|---------|
| **失败模式** | 静默 OOM | 响亮失败+诊断 | ⭐⭐⭐⭐⭐ |
| **诊断信息** | 无 | JSON + 日志 | ⭐⭐⭐⭐⭐ |
| **用户体验** | 困惑 | 清晰的改进路径 | ⭐⭐⭐⭐⭐ |
| **资源保护** | 会 OOM | 不会 OOM | ⭐⭐⭐⭐⭐ |
| **收敛性** | box 144/324 | box 72-144/324 | ⭐ (无改善) |

**预期**: 前 4 项显著改进，收敛性未改善（需要 WP-iRT-03）

---

## 🚦 决策点

### 实验后决策树

```
实验结果？
├─ Plateau detection 工作正常 ✅
│  ├─ Box 进度 < 144/324（比 baseline 更早检测）
│  │  └─ ✅ 符合预期，改进有效
│  └─ Box 进度 >= 144/324
│     └─ ⚠️ 检测较晚，考虑调整参数
│
├─ Memory budget 触发（在 Exp 2）✅
│  └─ ✅ 保护机制有效
│
├─ 诊断信息有用 ✅
│  └─ ✅ 用户能理解失败原因
│
└─ 收敛性是否改善？
   ├─ 否（预期）
   │  └─ 决策：实现 WP-iRT-03 (Adaptive Box Sizing)
   └─ 是（意外）
      └─ 决策：可能不需要 WP-iRT-03，继续测试其他利用率
```

---

## 📝 实验日志模板

### 记录格式（手动填写或脚本自动生成）

```markdown
## Experiment 1: 默认配置

**开始时间**: YYYY-MM-DD HH:MM:SS
**结束时间**: YYYY-MM-DD HH:MM:SS
**运行时间**: XX 分钟

**配置**:
- Check Interval: 36
- Threshold: 1.5
- Memory Budget: 8192 MB

**结果**:
- Box 进度: XX/324
- Plateau 触发: ✅/❌
- Memory 触发: ✅/❌
- 退出码: X
- 诊断文件: ✅/❌

**诊断 JSON 内容**:
```json
{...}
```

**关键日志片段**:
```
[ERROR] VIOLATION EXPLOSION DETECTED!
...
```

**观察**:
- [填写观察到的现象]

**结论**:
- [是否符合预期]
```

---

## 🎯 实验后行动

### 如果 Plateau Detection 有效
✅ 更新文档，标记 G14 门禁通过
✅ 确定推荐的默认配置
✅ 准备合并到主分支

### 如果 Memory Budget 有效
✅ 更新文档，标记 G14+G20 门禁通过
✅ 验证 partial DEF 的有效性
✅ 文档化内存预算设置指南

### 如果收敛性未改善（预期）
📋 开始 WP-iRT-03 实现
📋 或者先测试其他利用率（55%, 60%）
📋 或者调整 box size 参数手动测试

### 如果发现问题
🐛 调试并修复
🔄 重新编译测试
📝 更新问题跟踪

---

## ⏱️ 时间估计

| 阶段 | 预计时间 |
|------|---------|
| 准备 | 5 分钟 |
| Exp 1 | 45-60 分钟 |
| Exp 2 | 30-45 分钟 |
| Exp 3 | 60-90 分钟 |
| 结果分析 | 30 分钟 |
| **总计** | **3-4 小时** |

**建议**: 启动实验后可以做其他工作，定期检查进度即可。

---

## 📞 支持信息

**实验脚本**: `/home/lxq/AiEDA/iEDA.ai/run_experiments_WP-iRT-01-02.sh`
**输出目录**: `benchmarks/results/experiment_WP-iRT-01-02/`
**对比工具**: `benchmarks/qor/compare_improvements.py`
**文档**: `docs/ai/M1_milestone_status.md`

---

**准备就绪！执行命令**:
```bash
cd /home/lxq/AiEDA/iEDA.ai
./run_experiments_WP-iRT-01-02.sh
```
