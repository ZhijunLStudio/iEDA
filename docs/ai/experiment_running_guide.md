# 实验运行中 - 快速参考

**启动时间**: 2026-07-30 13:40+
**状态**: 🔄 Experiment 1 运行中
**预计时间**: 45-60 分钟

---

## 🔍 快速监控命令

### 查看实时进度
```bash
# 查看最新日志
tail -f benchmarks/results/experiment_WP-iRT-01-02/exp1_default_*.log

# 或者查看后台任务输出
tail -f /tmp/claude-1002/-home-lxq-AiEDA-iEDA-ai/*/tasks/btjx3pacg.output
```

### 检查进程状态
```bash
# 查看 iEDA 进程
ps aux | grep iEDA | grep -v grep

# 查看内存使用
ps aux | grep iEDA | grep -v grep | awk '{print $6/1024 " MB"}'
```

---

## ✅ 寻找的成功信号

在日志中查找：
```bash
grep -i "plateau\|explosion\|violation\|memory" \
  benchmarks/results/experiment_WP-iRT-01-02/exp1_default_*.log
```

**预期看到**:
- `[INFO] Plateau detection enabled`
- `[INFO] Routed XX/324 boxes with XXXXXX violations`
- `[ERROR] VIOLATION EXPLOSION DETECTED!`
- `[ERROR] Box progress: 72/324` (或类似)
- `plateau_diagnostic.json generated`

---

## 📊 预期结果

### 最可能的情况
```
✅ 在 box 72-108 处检测到违例爆炸
✅ 生成 plateau_diagnostic.json
✅ 清晰的错误消息和建议
✅ 运行时间 45-60 分钟
❌ 不会 OOM
```

### 诊断 JSON 内容
```json
{
  "plateau_detected": true,
  "box_progress": "72/324",
  "prev_violations": 57929,
  "curr_violations": 117032,
  "growth_rate": 1.02,
  "recommendation": "Increase box size or reduce design utilization"
}
```

---

## 📁 结果文件位置

```
benchmarks/results/experiment_WP-iRT-01-02/
├── exp1_default_20260730_HHMMSS.log  ← 主日志
└── exp1_default_20260730_HHMMSS/
    └── aes_sky130_a/
        └── workspace/
            └── result/
                ├── plateau_diagnostic.json  ← 诊断文件
                ├── memory_diagnostic.json   ← 如果内存触发
                ├── logs/
                │   └── routing.log  ← 详细 routing 日志
                └── *.def  ← DEF 文件（如果生成）
```

---

## ⏱️ 时间估计

```
现在 ────→ +45-60min ────→ 完成
        Exp 1 运行中
```

---

## 🎯 完成后的行动

### 1. 检查结果
```bash
# 查看完整日志
cat benchmarks/results/experiment_WP-iRT-01-02/exp1_default_*.log

# 查看诊断 JSON
cat benchmarks/results/experiment_WP-iRT-01-02/exp1_*/aes_sky130_a/workspace/result/plateau_diagnostic.json
```

### 2. 评估效果
- Plateau detection 是否工作？
- 在哪个 box 触发？
- 诊断信息是否有用？
- 相比之前的 OOM 是否改善？

### 3. 决定下一步
- ✅ 如果效果好 → 可以选择运行 Exp 2/3 或直接进入下一阶段
- ⚠️ 如果需要调整 → 修改参数重新测试
- 🔧 如果需要 WP-iRT-03 → 开始实现 Adaptive Box Sizing

---

## 💡 关键点

### 这次实验的核心价值

**不管收敛性是否改善**，我们已经实现了：
1. ✅ 从静默失败 → 响亮失败
2. ✅ 从无诊断 → 详细诊断
3. ✅ 从 OOM → 优雅退出
4. ✅ 从困惑 → 清晰的改进建议

**这本身就是巨大的工具质量提升！**

---

**状态**: 实验运行中，将在完成时自动通知
**下次更新**: 实验完成后（45-60 分钟）
