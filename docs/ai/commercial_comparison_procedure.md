# iEDA 商业工具对照数据采集方案

> 文档版本：v1.0
> 日期：2026-07-30
> 目的：建立商业 EDA 工具对照数据采集的标准流程，为 G17（QoR打平）和 G21（性能打平）提供金标准数据

## 1. 概述

根据 `benchmarks/qor/parity_protocol.json` 冻结协议，商业对照数据采集必须满足"苹果对苹果"原则：
- 同一输入（netlist/库/约束/随机种子）
- 同一努力档位（standard effort）
- 同一报告点（post-place/post-cts/post-route/signoff-STA）
- 可追溯性（SHA-256 manifest）

## 2. 必需的商业工具清单

### 2.1 主对标方（P&R）

每个设计选择 **Innovus** 或 **ICC2** 之一作为主对标方（已在 protocol 中冻结为 Innovus）：

| 工具 | 版本要求 | 用途 |
|------|---------|------|
| **Cadence Innovus** | 21.1+ | 主对标方：floorplan/place/CTS/route/timing opt |
| Synopsys ICC2 | 2021.06+ | 备选对标方（本期未选用） |

### 2.2 签核工具（Signoff）

以下工具用于签核级指标采集，**不可替换**：

| 工具 | 版本要求 | 用途 |
|------|---------|------|
| **Synopsys PrimeTime** | 2021.06+ | 签核级 STA，用于 G7 时序相关度验证 |
| **Synopsys StarRC** | 2021.06+ | 签核级寄生提取，用于 G8 精度验证 |
| **Mentor Calibre** | 2021.2+ | 签核级 DRC/LVS，用于 G11 覆盖率验证 |
| Synopsys PrimeTime PX | 2021.06+ | 签核级功耗分析，用于 G9（可选，需 VCD/SAIF） |

### 2.3 PDK 与 Foundry 数据

确保商业工具使用与 iEDA **完全相同**的 PDK 文件：

| PDK | LEF/LIB路径 | Tech File | 约束文件 |
|-----|------------|-----------|----------|
| sky130 | `/home/lxq/AiEDA/Foundary/sky130/` | sky130.tf | 同一 SDC |
| nangate45 | `/home/lxq/AiEDA/Foundary/nangate45/` | NangateOpenCellLibrary.tf | 同一 SDC |
| asap7 | `/home/lxq/AiEDA/Foundary/asap7/` | asap7.tf | 同一 SDC |
| ics55 | `/home/lxq/AiEDA/Foundary/ics55/` | ics55.tf | 同一 SDC |

**SHA-256 校验**：在采集前对所有输入文件计算哈希，确保与 iEDA baseline 的 `input_sha256` 字段匹配。

## 3. 输入文件准备

### 3.1 Netlist 准备

使用与 iEDA 完全相同的门级 Verilog：

```bash
# 示例：aes_sky130_a 设计
INPUT_NETLIST=/home/lxq/AiEDA/iEDA.ai/benchmarks/designs/aes_sky130_a/netlist/aes_cipher_top.v

# 计算 SHA-256
sha256sum $INPUT_NETLIST
# 应与 quality_summary.json 中的 manifest.inputs[0].sha256 一致
```

### 3.2 约束文件准备

```bash
# SDC 文件
INPUT_SDC=/home/lxq/AiEDA/iEDA.ai/benchmarks/designs/aes_sky130_a/sdc/aes.sdc

# 验证约束覆盖
# - 时钟定义（create_clock）
# - 输入/输出延迟（set_input_delay / set_output_delay）
# - false path / multicycle path
# - 时序单位（set_units -time）
```

### 3.3 Floorplan 边界

根据 parity protocol §1bis，允许两种方式：

1. **指定相同 die/core 尺寸**（推荐）：
   ```tcl
   # Innovus floorplan example
   floorPlan -site unit -r 1.0 0.7 40.0 40.0 40.0 40.0
   # die: (0,0)-(580,580), core: (40,40)-(540,540)
   # 与 iEDA baseline 的 die_area/core_area 保持一致
   ```

2. **指定相同目标利用率**：
   - 商业工具根据 util=0.7 自动生成 die/core
   - **记录实际生成的面积差**，进入 G17 独立指标

### 3.4 随机种子控制

```tcl
# Innovus: 固定随机种子
set_db opt_fix_fanout_use_variable_buffers true
set_db place_global_uniform_density true
set_db place_global_max_density 0.7
set_global _enable_mmmc_by_default_flow      $CTE_DEFAULT_NO
set_db opt_seeding 42  ; # 与 parity_protocol.json 中的 fixed_seed 一致
```

```tcl
# ICC2: 关闭随机扰动或记录 seed
set_app_var place.coarse.seed 42
set_app_var route.common.seed 42
```

## 4. Innovus 运行脚本模板

### 4.1 基础流程脚本

```tcl
# innovus_aes_sky130_a.tcl
# 基于 parity protocol v1.1 的标准 Innovus 流程

# ========== 初始化 ==========
set_db design_process_node 130
set_db design_name aes_cipher_top
set_db / .report_power_enable_ppa_features true

# ========== 导入设计 ==========
read_physical -lef /home/lxq/AiEDA/Foundary/sky130/lef/sky130_fd_sc_hd.tlef
read_physical -lef /home/lxq/AiEDA/Foundary/sky130/lef/sky130_fd_sc_hd_merged.lef
read_netlist /home/lxq/AiEDA/iEDA.ai/benchmarks/designs/aes_sky130_a/netlist/aes_cipher_top.v
read_libs /home/lxq/AiEDA/Foundary/sky130/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

# ========== 约束 ==========
read_sdc /home/lxq/AiEDA/iEDA.ai/benchmarks/designs/aes_sky130_a/sdc/aes.sdc
# 验证约束覆盖
report_timing -unconstrained

# ========== Floorplan ==========
# 使用与 iEDA 相同的 die/core 尺寸
floorPlan -site unit -r 1.0 0.7 40.0 40.0 40.0 40.0
# die: (0,0)-(580,580), core: (40,40)-(540,540)

# 添加电源环（根据 PDK）
addRing -nets {VDD VSS} -type core_rings -follow core -layer {met4 met5} \
    -width {2.0 2.0} -spacing {1.0 1.0} -offset {1.0 1.0}

# ========== Placement ==========
# standard effort（protocol 要求）
place_design -concurrent_macros
# 报告点 1: post-place
report_timing -nworst 10 > reports/post_place_timing.rpt
report_power > reports/post_place_power.rpt

# ========== CTS ==========
# standard effort
ccopt_design
# 报告点 2: post-cts
report_timing -nworst 10 > reports/post_cts_timing.rpt
report_clock_timing -type skew > reports/post_cts_skew.rpt

# ========== Routing ==========
# standard effort
set_db route_design_with_timing_driven true
route_design
# 报告点 3: post-route
report_timing -nworst 10 > reports/post_route_timing.rpt
report_power > reports/post_route_power.rpt
report_drc > reports/post_route_drc.rpt

# ========== Post-route opt ==========
# standard effort
optDesign -postRoute
report_timing -nworst 10 > reports/post_opt_timing.rpt

# ========== 导出 DEF ==========
defOut -floorplan reports/innovus_result.def
streamOut reports/innovus_result.gds -mapFile /path/to/gds_map_file

# ========== 墙钟时间采集 ==========
# 在独占机器上运行，记录各阶段墙钟时间和峰值内存
```

### 4.2 数据提取脚本

```bash
#!/bin/bash
# extract_innovus_metrics.sh

DESIGN=aes_sky130_a
RESULT_DIR=innovus_results/$DESIGN

# 解析 Innovus 报告，提取关键指标
python3 <<EOF
import re
import json

def parse_timing_report(rpt_path):
    """解析 Innovus timing report，提取 WNS/TNS"""
    with open(rpt_path) as f:
        content = f.read()

    wns_match = re.search(r'WNS\s+([-\d.]+)', content)
    tns_match = re.search(r'TNS\s+([-\d.]+)', content)

    return {
        'wns_ns': float(wns_match.group(1)) if wns_match else None,
        'tns_ns': float(tns_match.group(1)) if tns_match else None,
    }

def parse_power_report(rpt_path):
    """解析 Innovus power report"""
    with open(rpt_path) as f:
        content = f.read()

    total_match = re.search(r'Total\s+([\d.]+)\s+mW', content)

    return {
        'total_mw': float(total_match.group(1)) if total_match else None,
    }

# 提取指标
post_route_timing = parse_timing_report('$RESULT_DIR/reports/post_route_timing.rpt')
post_route_power = parse_power_report('$RESULT_DIR/reports/post_route_power.rpt')

# 生成商业对照 JSON
commercial_metrics = {
    'tool': 'innovus',
    'version': '21.1',  # 实际版本
    'design': '$DESIGN',
    'pdk': 'sky130',
    'timestamp': '$(date -Iseconds)',
    'effort': 'standard',
    'metrics': {
        'timing': post_route_timing,
        'power': post_route_power,
        # ... 其他指标
    }
}

with open('$RESULT_DIR/commercial_qor.json', 'w') as f:
    json.dump(commercial_metrics, f, indent=2)

print(f"Commercial metrics extracted to $RESULT_DIR/commercial_qor.json")
EOF
```

## 5. PrimeTime 签核 STA 脚本

```tcl
# pt_signoff_sta.tcl
# 使用 PrimeTime 对 iEDA 和 Innovus 的 DEF 进行签核级 STA

# ========== 导入设计 ==========
read_verilog /path/to/netlist.v
current_design aes_cipher_top
link_design

# ========== 读取寄生 ==========
read_parasitics -format spef /path/to/ieda_result.spef
# 或：read_parasitics -format spef /path/to/innovus_result.spef

# ========== 约束 ==========
read_sdc /path/to/aes.sdc

# ========== 时序分析 ==========
update_timing
report_timing -delay_type max -nworst 10 -path_type full_clock_expanded \
    > pt_setup_timing.rpt
report_timing -delay_type min -nworst 10 -path_type full_clock_expanded \
    > pt_hold_timing.rpt
report_constraint -all_violators > pt_violators.rpt

# ========== 提取 WNS/TNS ==========
# 使用 parse_pt_report.py 脚本解析 PT 报告
```

## 6. StarRC 寄生提取脚本

```tcl
# starrc_extraction.tcl

BLOCK: aes_cipher_top

COUPLED_RC_CORNER: typical
    C_REFERENCE_GROUND: VSS
    TEMPERATURE: 25
    EXTRACTION: RC
    COUPLING_ABS_THRESHOLD: 0.01
    COUPLING_REL_THRESHOLD: 0.1

MAPPING_FILE: /path/to/tech_mapping.map

EXTRACTION_SETUP:
    EXTRACT_VIA_CAPS: YES
    EXTRACT_FLOATING_NETS: YES
    REDUCTION_LEVEL: 0

OUTPUT_SPEF: starrc_result.spef
```

## 7. Calibre DRC 脚本

```tcl
# calibre_drc.rule
LAYOUT PATH /path/to/ieda_result.gds
LAYOUT PRIMARY aes_cipher_top
LAYOUT SYSTEM GDSII

DRC RESULTS DATABASE drc_results.db
DRC SUMMARY REPORT drc_summary.rpt
DRC MAXIMUM RESULTS ALL
DRC MAXIMUM VERTEX 4096

INCLUDE /home/lxq/AiEDA/Foundary/sky130/calibre/drc_rules.svrf
```

## 8. 性能采集方案（G21）

### 8.1 独占机器要求

根据 parity protocol，G21 性能对比必须在**独占机器**上进行：

- 关闭后台服务（cron/systemd-timers）
- 禁用 CPU 频率调节（固定最高频率）
- 清空文件系统缓存（`sync; echo 3 > /proc/sys/vm/drop_caches`）
- 每个设计运行 ≥5 次，取中位数

### 8.2 时间采集脚本

```bash
#!/bin/bash
# benchmark_innovus_perf.sh

DESIGN=aes_sky130_a
REPEATS=5

for i in $(seq 1 $REPEATS); do
    echo "=== Run $i/$REPEATS ==="

    # 冷缓存：清空缓存
    sync; sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'

    # 使用 GNU time 采集墙钟时间和内存
    /usr/bin/time -v innovus -64 -no_gui -files innovus_aes_sky130_a.tcl \
        2>&1 | tee run_${i}.log

    # 提取墙钟时间和峰值内存
    grep "Elapsed (wall clock) time" run_${i}.log
    grep "Maximum resident set size" run_${i}.log
done

# 计算统计量（median/MAD）
python3 calculate_perf_stats.py run_*.log > perf_summary.json
```

### 8.3 分阶段时间采集

在 Innovus 脚本中添加时间戳：

```tcl
# 在每个主要阶段后记录时间
proc log_stage_time {stage_name} {
    set elapsed [clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S]
    set mem_kb [exec ps -o rss= -p [pid]]
    puts "PERF_MARKER: $stage_name $elapsed $mem_kb"
}

# Placement 后
log_stage_time "post_place"
# CTS 后
log_stage_time "post_cts"
# Routing 后
log_stage_time "post_route"
```

然后解析 `PERF_MARKER` 计算各阶段耗时。

## 9. 数据整合与对比

### 9.1 数据汇总脚本

```python
# compare_qor.py
"""
对比 iEDA 和商业工具的 QoR 数据，生成 parity 报告
"""

import json
from pathlib import Path

def load_baseline():
    """加载 iEDA baseline"""
    with open('benchmarks/qor/baseline_35pct.json') as f:
        return json.load(f)

def load_commercial(design_name):
    """加载商业工具对照数据"""
    path = f'innovus_results/{design_name}/commercial_qor.json'
    with open(path) as f:
        return json.load(f)

def calculate_delta(ieda_value, commercial_value, tolerance):
    """计算 delta 和判定"""
    if ieda_value is None or commercial_value is None:
        return None, 'N/A'

    delta = (ieda_value - commercial_value) / commercial_value
    status = 'pass' if abs(delta) <= tolerance else 'fail'
    return delta, status

def main():
    baseline = load_baseline()

    for design in baseline['designs']:
        name = design['name']
        print(f"\n=== {name} ===")

        commercial = load_commercial(name)

        # 时序对比
        ieda_wns = design['metrics']['timing']['setup_wns_ns']
        comm_wns = commercial['metrics']['timing']['wns_ns']
        delta_wns, status_wns = calculate_delta(ieda_wns, comm_wns, 0.05)

        print(f"Setup WNS: iEDA={ieda_wns:.3f}ns, Innovus={comm_wns:.3f}ns, delta={delta_wns:.1%}, status={status_wns}")

        # ... 其他指标对比

if __name__ == '__main__':
    main()
```

### 9.2 G17 判定脚本

```python
# validate_g17.py
"""
根据 parity protocol 判定 G17 通过情况
"""

def check_g17_metric(metric_name, ieda_value, commercial_value, protocol):
    """检查单个指标是否满足 G17 要求"""
    tolerance = protocol['deltas'][metric_name]['relative_tolerance']
    abs_tol = protocol['deltas'][metric_name].get('absolute_tolerance_ps')

    if abs_tol and abs(ieda_value - commercial_value) <= abs_tol:
        return 'pass', f'within absolute tolerance {abs_tol}ps'

    delta = abs((ieda_value - commercial_value) / commercial_value)
    if delta <= tolerance:
        return 'pass', f'delta={delta:.1%} within {tolerance:.1%}'
    else:
        return 'fail', f'delta={delta:.1%} exceeds {tolerance:.1%}'

# 遍历所有设计和指标，生成 G17 报告
```

## 10. 采集清单（Checklist）

### 10.1 Phase 0 必需数据（门禁 G1b）

- [ ] 输入文件 SHA-256 manifest（与 iEDA 一致）
- [ ] 商业工具版本记录
- [ ] 随机种子配置
- [ ] 努力档位配置（standard effort）
- [ ] Floorplan 边界（die/core 尺寸或目标利用率）

### 10.2 QoR 对比数据（门禁 G17）

- [ ] Post-place timing (WNS/TNS)
- [ ] Post-CTS timing + skew/latency
- [ ] Post-route timing (WNS/TNS)
- [ ] Post-route wirelength (HPWL/total)
- [ ] Post-route DRC count
- [ ] Post-route power (total/switch/leakage)

### 10.3 签核级数据（门禁 G7/G8/G11）

- [ ] PrimeTime 签核 STA 报告（同一 SPEF）
- [ ] StarRC 寄生提取（逐网 C/R 对比）
- [ ] Calibre DRC 报告（rule deck 覆盖率）

### 10.4 性能数据（门禁 G21）

- [ ] 独占机器环境准备
- [ ] 5次重复运行（冷缓存）
- [ ] 墙钟时间（median/MAD）
- [ ] 峰值内存（cgroup v2）
- [ ] 分阶段时间（placement/CTS/routing）

## 11. 常见问题

### Q1: 商业工具的 LEF/LIB 路径与 iEDA 不同怎么办？
A: 将商业工具的 PDK 符号链接到与 iEDA 相同的路径，或在输入 manifest 中记录实际路径并校验 SHA-256 一致。

### Q2: Innovus 和 ICC2 结果不一致，应该选哪个？
A: 按照 parity protocol，**每个设计只能选一个主对标方**。协议已冻结为 Innovus，全程不得更换。

### Q3: 如何确保性能对比的公平性？
A: 必须满足 G21 要求：
- 独占机器（no background tasks）
- 固定 CPU 频率（disable turbo boost）
- 清空缓存（cold cache）
- 5次重复取中位数（median）

### Q4: 商业工具没有某个 PDK 怎么办？
A: 该 PDK 对应的设计标记为 `commercial_not_available`，不计入 G17 分母。协议要求至少 3/5 个设计可比。

## 12. 输出物清单

完成采集后，应生成以下文件：

```
benchmarks/qor/
├── parity_protocol.json              # 冻结协议（已存在）
├── baseline_35pct.json                # iEDA baseline（已存在）
├── commercial/                         # 新增：商业对照数据
│   ├── innovus/
│   │   ├── aes_sky130_a/
│   │   │   ├── commercial_qor.json     # QoR 指标
│   │   │   ├── post_route_timing.rpt   # Innovus 原始报告
│   │   │   ├── post_route_drc.rpt
│   │   │   └── manifest.json           # 输入/产物 SHA-256
│   │   └── ...（其余 12 个设计）
│   ├── primeTime/
│   │   ├── aes_sky130_a/
│   │   │   ├── pt_ieda.rpt             # PT 读 iEDA SPEF
│   │   │   ├── pt_innovus.rpt          # PT 读 Innovus SPEF
│   │   │   └── correlation.json        # G7 相关度数据
│   │   └── ...
│   ├── starRC/
│   │   └── ...（G8 数据）
│   └── calibre/
│       └── ...（G11 数据）
└── comparison_report.json             # 最终对比报告
```

## 13. 时间估算

| 阶段 | 工作量（人天） | 说明 |
|------|--------------|------|
| 环境准备 | 1-2 | 安装商业工具，配置 license |
| 输入准备 | 1 | 复制输入文件，校验 SHA-256 |
| Innovus 13设计 | 3-5 | 编写脚本，运行 13 个配置 |
| PT/StarRC/Calibre | 2-3 | 签核级验证（3个工具 × 13设计） |
| 性能采集 | 2-3 | 独占机环境，5次重复 × 13设计 |
| 数据整合与对比 | 1-2 | 编写对比脚本，生成报告 |
| **总计** | **10-16** | 约 2-3 周（单人） |

## 14. 参考文档

- `docs/ai/00-ieda-commercial-parity-master-plan-v1.1.md` §1bis "苹果对苹果协议"
- `docs/ai/00-ieda-commercial-parity-master-plan-v1.1.md` §3.4 "商业 QoR / 性能打平"
- `benchmarks/qor/parity_protocol.json` 冻结协议
- `docs/ai/42-perf-parity.md` G21 性能验证细则

---

**版本历史**
- v1.0 (2026-07-30): 初版，基于 AES13 35% baseline 和冻结协议
