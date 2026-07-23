# iEDA.ai Benchmark Flows

自动化物理设计流程工具集，支持批量运行多工艺库设计。

## 快速开始

### 1. 运行单个设计

```bash
cd /home/lxq/AiEDA/iEDA.ai/benchmarks/flows
./run_aes_simple.sh aes_sky130_a
```

### 2. 批量运行

```bash
python3 run_aes_batch.py
```

### 3. 生成报告

```bash
python3 generate_reports.py aes_sky130_a
```

## 工具说明

### 核心脚本

- **run_aes_simple.sh** - 单个设计运行脚本
  - 自动设置环境变量
  - 运行完整9阶段流程
  - 生成日志和结果

- **run_aes_batch.py** - 批量运行工具
  - 交互式界面
  - 支持按 PDK 筛选
  - 自动汇总结果

- **generate_reports.py** - 报告生成器
  - 解析时序/功耗/DRC/拥塞数据
  - 输出 JSON 和 Markdown 格式

## 已知问题

### iPL SIGFPE 错误
- **症状**: iPL 阶段崩溃，显示 "SIGFPE" 和 "No driver pin exist"
- **原因**: `NesterovPlace::initFillerNesInstance()` 除零错误
- **状态**: 已记录，待修复

## 文档

- **主报告**: `/home/lxq/AiEDA/iEDA.ai/docs/logs/2026-07-22-aes-flow-setup.md`
- **Agent 规划**: `/home/lxq/AiEDA/iEDA.ai/docs/ai/50-agent-era-eda-master-plan-v1.0.md`

---

**更新**: 2026-07-22
