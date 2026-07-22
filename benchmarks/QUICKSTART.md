# 快速入门指南

## 立即开始

```bash
cd /home/lxq/AiEDA/iEDA.ai/benchmarks

# 查看所有设计
./scripts/summarize.sh

# 运行单个设计
./scripts/run_design.sh gcd

# 批量运行所有设计
./scripts/run_all.sh
```

## 文件位置速查

```
benchmarks/
├── designs/
│   ├── gcd/          小规模 (399行)
│   ├── aes/          中等规模 (16,978行)
│   └── picorv32/     大规模 (16,941行)
│
├── scripts/
│   ├── run_design.sh     # ./scripts/run_design.sh <design>
│   ├── run_all.sh        # ./scripts/run_all.sh
│   └── summarize.sh      # ./scripts/summarize.sh
│
├── README.md             # 完整文档
├── BUILD_REPORT.md       # 构建报告
└── MANIFEST.json         # 设计清单
```

## 设计配置

每个设计的配置文件：`designs/<design>/design.json`

```json
{
  "name": "gcd",
  "inputs": {
    "tech_lef": "$PDK/lef/sky130_fd_sc_hd.tlef",
    "cells_lef": "$PDK/lef/sky130_fd_sc_hd_merged.lef",
    "lib": "$PDK/lib/sky130_fd_sc_hd__tt_025C_1v80.lib",
    "netlist": "netlist/gcd.v",
    "sdc": "sdc/gcd.sdc"
  }
}
```

## PDK配置

- **位置**: `benchmarks/pdk` → `/home/lxq/AiEDA/Foundary/sky130`
- **标准单元**: sky130_fd_sc_hd (High Density)
- **工艺节点**: 130nm
- **工艺角**: TT (25°C, 1.8V)

## 下一步

1. **完善运行脚本**
   - 参考: `/home/lxq/AiEDA/iEDA.ai/scripts/design/sky130_gcd/run_iEDA.sh`
   - 创建 TCL 脚本调用 iEDA 工具链

2. **验证流程**
   - 在 gcd 上测试完整的 netlist→GDS 流程
   - 确保生成 PPA 指标

3. **对标商业工具**
   - 使用 skywater130 数据集中的 Innovus 参考结果
   - 比较 PPA 和运行时间

## 支持的工艺库

当前使用 sky130，也可以切换到：
- asap7 (7nm)
- ics55 (55nm)
- nangate45 (45nm)

只需修改 `design.json` 中的 PDK 路径和相关文件即可。

## 获取帮助

查看完整文档：
- `README.md` - 详细使用说明
- `BUILD_REPORT.md` - 构建过程和验证
- `docs/ai/00-ieda-commercial-parity-master-plan-v1.1.md` - 对标目标
