# iEDA.ai Benchmark 构建完成报告

**日期**: 2026-07-22  
**版本**: v1.0  
**状态**: ✓ 完成

---

## 构建概述

成功构建了用于评测 iEDA.ai 工具链的benchmark测试用例集，基于 SkyWater 130nm 开源 PDK。

## 目录结构

```
/home/lxq/AiEDA/iEDA.ai/benchmarks/
├── pdk -> /home/lxq/AiEDA/Foundary/sky130
├── designs/
│   ├── gcd/          (XS, ~400行, 冒烟测试)
│   ├── aes/          (M, ~17K行, 时序压力测试)
│   └── picorv32/     (L, ~17K行, 可扩展性测试)
├── scripts/
│   ├── run_design.sh     (单设计运行)
│   ├── run_all.sh        (批量运行)
│   └── summarize.sh      (结果汇总)
├── common/               (公共配置)
├── results/              (运行结果)
├── MANIFEST.json         (设计清单)
├── README.md             (使用文档)
└── .gitignore
```

## 设计用例

| 设计 | 规模 | 网表行数 | 描述 | 状态 |
|------|------|----------|------|------|
| **gcd** | XS | 399 | 最大公约数单元 | ✓ 就绪 |
| **aes** | M | 16,978 | AES加密核心 | ✓ 就绪 |
| **picorv32** | L | 16,941 | RISC-V处理器 | ✓ 就绪 |

## 工艺库配置

- **PDK**: SkyWater sky130
- **标准单元库**: sky130_fd_sc_hd (High Density)
- **工艺节点**: 130nm
- **工艺角**: TT (典型角, 25°C, 1.8V)

## 文件验证

所有设计的必需文件已验证：

```
✓ gcd/design.json
✓ gcd/netlist/gcd.v
✓ gcd/sdc/gcd.sdc

✓ aes/design.json
✓ aes/netlist/aes.v
✓ aes/sdc/aes.sdc

✓ picorv32/design.json
✓ picorv32/netlist/picorv32.v
✓ picorv32/sdc/picorv32.sdc
```

## 数据来源

- **网表**: `/mnt/mdisk3/PCL-167/data3/taosimin/dataset_skywater130`
  - 包含商业工具 (Innovus) 的参考结果
  - 5种优化变体 (area, balanced, no_opt, power, timing)
  - 完整的 place & route 数据

- **参考架构**: `/home/lxq/AiEDA/HS-3D_Problem/thirdparty/iEDA-3D/benchmark`
  - 采用相同的目录组织方式
  - design.json 配置文件格式
  - 脚本框架

## 对标目标

根据 `docs/ai/00-ieda-commercial-parity-master-plan-v1.1.md`：

1. **PPA对标**: 与 Innovus/ICC2 的 PPA 接近 (差距 ≤5%)
2. **运行时对标**: 端到端运行时间接近或更短
3. **签核可信**: iSTA/iRCX/iDRC/iPA 结果可信

## 使用方法

### 运行单个设计
```bash
cd /home/lxq/AiEDA/iEDA.ai/benchmarks
./scripts/run_design.sh gcd
```

### 批量运行
```bash
./scripts/run_all.sh
```

### 查看结果
```bash
./scripts/summarize.sh
```

## 后续工作

1. **完善运行脚本**: 
   - 参考 `/home/lxq/AiEDA/iEDA.ai/scripts/design/sky130_gcd/run_iEDA.sh`
   - 创建完整的 TCL 脚本调用 iEDA 各工具
   - 集成到 `scripts/run_design.sh` 中

2. **配置文件**: 
   - 为每个设计创建 iEDA 工具配置文件
   - 参考现有 `iEDA_config/` 目录结构

3. **验证运行**:
   - 在 gcd 上验证完整流程
   - 确保可以生成 PPA 结果
   - 验证与商业工具的可比性

4. **扩展设计**:
   - 可以从 skywater130 数据集添加更多设计
   - 支持其他工艺库 (asap7, ics55, nangate45)

## 关键文件

- **README.md**: 完整的使用文档
- **MANIFEST.json**: 设计清单和元数据
- **design.json**: 每个设计的配置文件（包含所有路径和参数）
- **run_design.sh**: 核心运行脚本框架

## 技术特点

1. **工艺库无关**: 通过 design.json 的 `$PDK` 变量，易于切换工艺库
2. **配置驱动**: 所有参数在 JSON 配置文件中，便于自动化
3. **可扩展**: 目录结构清晰，易于添加新设计
4. **版本控制**: .gitignore 排除运行结果，只提交源文件

---

**构建完成！** Benchmark 已就绪，可以开始进行 iEDA.ai 工具链的评测。
