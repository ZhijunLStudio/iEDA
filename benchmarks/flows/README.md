# iEDA.ai Benchmark Flows

自动化物理设计流程工具集，支持批量运行多工艺库设计。

## 快速开始

### Commercial-parity AES13 流程

`aes13_flow.py` 是 13 个 AES 配置的可复现入口。运行前会机械校验冻结协议，
每个阶段成功后在 `workspace/result/manifests/` 写入脚本、输入、前置产物和
输出产物的 SHA-256。`--resume` 只有在这些 hash 全部匹配时才会跳过阶段；
仅有旧 DEF/GDS 文件不能构成成功证据。

```bash
# 先验证 G1b 协议没有漂移
python3 -m benchmarks.qor.validate_protocol

# 运行全部 13 个配置；结果写入 benchmarks/results/aes13
python3 benchmarks/flows/aes13_flow.py --jobs 1 --quality-gate report

# 输入、二进制、协议或上游产物未变时安全续跑
python3 benchmarks/flows/aes13_flow.py --resume --jobs 1 --quality-gate report
```

完整批跑中，任一阶段 `error`、`failed` 或 `partial` 都返回非零。只有用户显式
使用 `--prepare-only` 或 `--stop-after` 时，对应的 `prepared`/`partial` 才是预期
终态。`report` 模式允许在签核证据不全时完成采集，但批次总体状态会写为
`observational`，不代表 commercial parity 通过；`strict` 模式要求所有质量门禁
通过，否则返回非零。

每个设计会把本次真实执行的阶段写入 `performance_profile.jsonl`，批次根目录另有
一份合并文件。记录符合 `benchmarks/qor/schemas/performance_profile.schema.json`，
并附二进制、build manifest、hardware manifest 和输入签名的 SHA-256。阶段名称只按
runner 实际计时边界映射；例如当前 routing TCL 只能记为 `iRT`，不会伪造
`iRT-GR/iRT-TR/iRT-DR` 三个分项。

当前入口只运行一次，也不验证独占机或真实 cold/warm 缓存状态，因此所有记录固定为
`repeat=1`、`comparable=false`、`exclusive_host=false`。每个实际执行的 iEDA stage
独占一个进程组，由 `wait4` 采集真实 user/system CPU 与进程 peak RSS；timeout 会终止
整个进程组，禁止孤儿进程在超时后继续写出“新鲜”产物。`--profile-cache-mode` 只是观测
样本标签，不能让该结果进入 G21。`--resume` 跳过的阶段不会产生伪造的耗时记录；只要
存在跳过阶段，或用户用 `--stop-after` 提前停止，本次也不会发射伪 `e2e` 记录。完整
执行时 `e2e` 的 CPU 是本次实际执行 stage 的 CPU 之和、peak RSS 是各 stage 最大值，
而 wall 边界覆盖整个 `run_design`；启用 synthesis 时 wall 还包含 Yosys 和 runner
准备时间，因此仍不能直接与商业 PnR 墙钟相比。

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
