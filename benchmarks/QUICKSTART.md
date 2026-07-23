# Quick Start Guide

## 快速查询设计

```bash
cd /home/lxq/AiEDA/iEDA.ai/benchmarks

# 查看所有设计统计
cat designs/REGISTRY.json | jq '{total: .total_designs, pdks: .pdks}'

# 按 PDK 筛选
cat designs/REGISTRY.json | jq '.designs[] | select(.pdk == "sky130") | .name'

# 按规模筛选（大型设计）
cat designs/REGISTRY.json | jq '.designs[] | select(.scale == "L") | {name, pdk, role}'

# 按类型筛选（加密相关）
cat designs/REGISTRY.json | jq '.designs[] | select(.role == "crypto") | .name'

# 查看某个设计的配置
cat designs/aes_sky130_a/design.json | jq .
```

## 设计命名规则

格式：`<design>_<pdk>_<strategy>`

- **design**: 设计名称 (aes, gcd, picorv32 等)
- **pdk**: 工艺库 (sky130, nangate45, asap7, ics55)
- **strategy**: 综合策略
  - `a` = area (面积优化)
  - `b` = balance (平衡优化)
  - `t` = timing (时序优化)

示例：
- `aes_sky130_a` - AES 在 sky130 PDK，面积优化
- `picorv32_nangate45_t` - PicoRV32 在 nangate45 PDK，时序优化

## 文件位置

每个设计目录包含：
```
designs/<design>_<pdk>_<strategy>/
├── design.json              # 配置文件
├── netlist/<design>.v       # Verilog 网表
├── sdc/<design>.sdc         # 时序约束
├── def/<design>_place.def   # 参考布局
└── results/                 # 输出目录（运行后生成）
```

## 使用设计配置

### Python 示例

```python
import json
from pathlib import Path

# 加载注册表
registry_path = Path('designs/REGISTRY.json')
with open(registry_path) as f:
    registry = json.load(f)

# 查找特定设计
design = next(d for d in registry['designs'] if d['name'] == 'aes_sky130_a')
print(f"Found: {design['name']}")

# 加载设计配置
config_path = Path(f"designs/{design['dir']}/design.json")
with open(config_path) as f:
    config = json.load(f)

# 打印关键信息
print(f"Top module: {config['top']}")
print(f"PDK: {config['pdk']}/{config['variant']}")
print(f"Clock: {config['clocks'][0]['port']} @ {config['clocks'][0]['period_ns']} ns")
print(f"Netlist: {config['inputs']['netlist']}")
print(f"Core utilization: {config['floorplan']['core_utilization']}")
```

### Bash 示例

```bash
# 设置环境变量
export DESIGN_NAME="aes_sky130_a"
export DESIGN_DIR="designs/$DESIGN_NAME"
export PDK_ROOT="/home/lxq/AiEDA/Foundary/sky130"

# 提取配置信息
TOP_MODULE=$(jq -r '.top' $DESIGN_DIR/design.json)
NETLIST=$(jq -r '.inputs.netlist' $DESIGN_DIR/design.json)
SDC=$(jq -r '.inputs.sdc' $DESIGN_DIR/design.json)

echo "Design: $DESIGN_NAME"
echo "Top: $TOP_MODULE"
echo "Netlist: $DESIGN_DIR/$NETLIST"
echo "SDC: $DESIGN_DIR/$SDC"
```

## 按需导入更多设计

```bash
# 导入特定设计和 PDK
python3 import_benchmarks.py \
  --designs aes gcd s9234 \
  --pdks sky130 nangate45 \
  --strategies a b

# 导入所有 ISCAS 电路
python3 import_benchmarks.py \
  --designs s44 s1238 s1488 s5378 s9234 s13207 s15850 s35932 s38417 s38584 \
  --pdks sky130 \
  --strategies a

# 只重新生成注册表
python3 import_benchmarks.py --registry-only
```

## 常用设计推荐

### 快速测试
- `gcd_sky130_a` - 最小设计，用于快速验证

### 时序评估
- `aes_sky130_t` - 中等规模，时序关键
- `s15850_nangate45_t` - ISCAS 基准测试

### 大规模评估
- `picorv32_sky130_b` - RISC-V 处理器
- `s38417_asap7_b` - 大型 ISCAS 电路

### 多 PDK 对比
选择同一个设计的不同 PDK 版本：
```bash
designs/aes_sky130_a     # 130nm
designs/aes_nangate45_a  # 45nm
designs/aes_asap7_a      # 7nm
designs/aes_ics55_a      # 55nm
```

## PDK 路径配置

每个 PDK 在 `/home/lxq/AiEDA/Foundary/` 下：

```bash
# sky130
export PDK=/home/lxq/AiEDA/Foundary/sky130
# design.json 中的 $PDK 会被替换为此路径

# nangate45
export PDK=/home/lxq/AiEDA/Foundary/nangate45

# asap7
export PDK=/home/lxq/AiEDA/Foundary/asap7

# ics55
export PDK=/home/lxq/AiEDA/Foundary/ics55
```

## 设计规模参考

| 规模 | 单元数 | 利用率 | 示例设计 |
|------|--------|--------|----------|
| S (Small) | < 5K | 0.55 | gcd, s1488, apb4_uart |
| M (Medium) | 5K-50K | 0.60 | aes, salsa20, s13207 |
| L (Large) | 50K-200K | 0.65 | picorv32, s38417 |
| XL (XLarge) | > 200K | 0.70 | (待添加) |

## 下一步

1. 选择一个设计：`cat designs/REGISTRY.json | jq '.designs[0:10]'`
2. 查看配置：`cat designs/<design_name>/design.json`
3. 准备运行 iEDA 物理设计流程
4. 查看结果：`ls designs/<design_name>/results/`

---

**更新日期**: 2026-07-22
