# 实验执行状态监控

**启动时间**: 2026-07-30
**状态**: 🔄 运行中

---

## 正在执行的实验

### Experiment 1: 默认配置
- **Check Interval**: 36 boxes
- **Threshold**: 1.5 (150%)
- **Memory Budget**: 8192 MB
- **状态**: 🔄 运行中...
- **预计时间**: 45-60 分钟

### Experiment 2: 严格配置
- **Check Interval**: 24 boxes
- **Threshold**: 1.2 (120%)
- **Memory Budget**: 4096 MB
- **状态**: ⏸️ 等待 Exp 1 完成
- **预计时间**: 30-45 分钟

### Experiment 3: 宽松配置
- **Check Interval**: 48 boxes
- **Threshold**: 2.0 (200%)
- **Memory Budget**: 8192 MB
- **状态**: ⏸️ 等待 Exp 2 完成
- **预计时间**: 60-90 分钟

---

## 监控命令

### 查看实时日志
```bash
# 在另一个终端运行
tail -f benchmarks/results/experiment_WP-iRT-01-02/exp1_*.log
```

### 查看进程状态
```bash
ps aux | grep iEDA | grep -v grep
top -p $(pgrep iEDA)
```

### 查看内存使用
```bash
watch -n 5 'ps aux | grep iEDA | grep -v grep | awk "{print \$6}"'
```

---

## 预期时间线

```
现在  → +45-60min → +30-45min → +60-90min → 完成
      Exp 1        Exp 2        Exp 3

总时间: 2.5-3.5 小时
```

---

## 寻找的关键信号

### 成功信号
- ✅ `[ERROR] VIOLATION EXPLOSION DETECTED!`
- ✅ `plateau_diagnostic.json generated`
- ✅ `Box progress: XX/324`
- ✅ 非零退出码

### 问题信号
- ❌ Process killed (OOM) - 不应该发生
- ❌ Segmentation fault - 需要调试
- ❌ 无任何错误输出 - plateau 未触发

---

## 实验完成后检查

### 1. 查看诊断文件
```bash
find benchmarks/results/experiment_WP-iRT-01-02 -name "*.json" -type f
```

### 2. 生成对比报告
```bash
python3 benchmarks/qor/compare_improvements.py \
  --experiments benchmarks/results/experiment_WP-iRT-01-02 \
  --output benchmarks/results/experiment_WP-iRT-01-02/comparison_report.md
```

### 3. 查看总结
```bash
cat benchmarks/results/experiment_WP-iRT-01-02/exp*.log | grep -E "(实验.*完成|耗时|检测到)"
```

---

**状态**: 后台运行中，将自动通知完成
