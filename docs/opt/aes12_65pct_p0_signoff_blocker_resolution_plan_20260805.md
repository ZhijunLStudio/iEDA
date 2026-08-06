# AES12 65% P0 签核硬阻塞解决方案

日期：2026-08-05
适用分支：`commercial-parity`
适用范围：`aes_sky130_*`, `aes_nangate45_*`, `aes_asap7_*`, `aes_ics55_*` 65% 利用率验证线
关联报告：

- `benchmarks/reports/aes12_65pct_opt_20260805_detailed_comparison.md`
- `docs/opt/aes12_65pct_optimization_execution_20260805.md`
- `docs/opt/aes12_65pct_module_quality_and_optimization_plan.md`
- `docs/ai/CRITICAL_BLOCKER_IRCX_ITF.md`
- `docs/ai/IRCX_SPEF_UNBLOCK_PLAN.md`

## 1. 目标和原则

当前 AES12 65% 流程已经能生成 post-route DEF/GDS，但 `quality_gate.json` 仍显示 signoff fail。P0 的目标不是继续扩大实验规模，而是把 5 个硬阻塞逐项变成可验证、可追踪、可回归的签核闭环：

| 阻塞项 | 当前症状 | P0 目标 |
|---|---|---|
| 真实 SPEF/RCX 缺失 | timing report 的 `path net delay = 0`，RCX coverage 显示 ITF/captab 缺失 | post-route STA 读取与当前 DEF 匹配的 SPEF，关键路径 net delay 非零 |
| SDC I/O 约束不足 | `constraints_loaded` fail，缺 I/O delay、driving/slew/load | 每个 design/PDK 有完整 SDC，unconstrained 与 missing slew 清零或显式 waiver |
| Power 无 VCD/SAIF | activity source 为 vectorless，switch power 为 0 | 使用真实 VCD/SAIF 或明确标注校准 proxy；可信模式下 switch power 非零 |
| IR-drop 无可信结果 | 无 worst/avg drop、超阈面积、map | 生成 PDN、电流模型、IR report/map，并进入 quality gate |
| DRC 非 clean | residual DRC 非零，主项为 PRL/min-area/metal_short | 每 PDK 至少 1 个 clean 或进入可签核 waiver；P1 再扩到 12/12 |

原则：

- `flow_success` 和 `signoff_success` 必须分离。GDS 存在只能说明流程贯通，不能说明签核通过。
- proxy 可以用于调试，但必须标记为 untrusted，不能让 gate pass。
- 每个修复项必须产出机器可读 evidence，并写入 `quality_gate.json` 或 `stage_observations`。
- 优先使用小样本 smoke 验证链路，再扩到 4-design A/B，最后扩到 12/12。

## 2. 总体执行顺序

| 阶段 | 周期 | 目标 | 退出条件 |
|---|---:|---|---|
| P0-A | 1-2 天 | 修复 SDC 模板和 gate 检查口径 | 4 个 PDK 的 `a` 样本 `constraints_loaded=pass` |
| P0-B | 2-5 天 | 接通 SPEF 生成或临时外部 SPEF 读取验证 | 1 个设计 `spef_backed_sta=pass`，net delay 非零 |
| P0-C | 2-4 天 | 接入 VCD/SAIF 或生成可审计 activity provenance | 1 个设计 activity trusted，switch power 非零 |
| P0-D | 3-7 天 | 跑通最小 PDN/IR report | 1 个设计 `ir_drop_analyzed=pass` |
| P0-E | 1-2 周 | DRC 主项专项闭环 | 每 PDK 至少 1 个 design residual DRC 显著下降，进入 P1 clean 计划 |

建议先固定 4 个 smoke 设计：

```text
aes_sky130_a
aes_nangate45_a
aes_asap7_a
aes_ics55_a
```

4-design 全部达到对应 gate 后，再扩展到 12/12。

## 3. SPEF/RCX 缺失解决方案

### 3.1 根因

当前 iRCX Tcl/API 链路存在，但配置要求 `itf_file` 与 `captab_file`。本地 Foundry 目录未找到这些文件，导致 iRCX 无法生成真实 SPEF。质量门禁因此显示：

- `rcx_coverage.ready=false`
- `spef_backed_sta=fail`
- timing report 中 `path net delay` 全为 0

### 3.2 分层方案

| 方案 | 用途 | 是否可让 signoff pass | 周期 | 风险 |
|---|---|---:|---:|---|
| A. 当前设计匹配的 iRCX SPEF | 正式方案 | 是 | 取决于 ITF/captab 获取 | 需要 PDK RC 文件 |
| B. OpenRCX/外部抽取 SPEF | 工程替代方案 | 可作为 trusted，但需标记 tool/source | 2-5 天 | 与 iRCX 精度口径不同 |
| C. Foundry 现有 sample SPEF | 解析 smoke | 否 | 0.5-1 天 | 设计/DEF 不匹配，只能验证 iSTA 读 SPEF |
| D. 人工简化 RC 模型 | 算法调试 | 否，除非校准 | 3-7 天 | 精度未知，容易产生错误 PPA 决策 |

### 3.3 推荐执行

第一步先做 SPEF inventory，把当前可用资源结构化：

```bash
find /home/lxq/AiEDA/Foundary -type f \( -name "*.itf" -o -name "*.captab" -o -name "*.spef" -o -name "rcx_patterns.rules" \) | sort
```

生成：

```text
benchmarks/flows/rcx/rcx_resource_inventory.json
```

字段：

```json
{
  "pdk": "nangate45",
  "itf_files": [],
  "captab_files": [],
  "spef_files": [],
  "openrcx_rules": [],
  "trusted_rcx_ready": false,
  "fallback_available": false
}
```

第二步接通正式 iRCX 配置模板。若某 PDK 有 ITF/captab，则生成：

```text
benchmarks/flows/rcx/<pdk>/rcx_config.json
benchmarks/flows/rcx/<pdk>/layer_mapping.txt
```

模板：

```json
{
  "output": "$RESULT_DIR/rcx",
  "mapping_file": "benchmarks/flows/rcx/<pdk>/layer_mapping.txt",
  "corners": [
    {
      "name": "typical",
      "itf_file": "<foundry>/<pdk>/rcx/<pdk>.itf",
      "captab_file": "<foundry>/<pdk>/rcx/<pdk>.captab"
    }
  ]
}
```

第三步把 RCX stage 固化到 flow：

```tcl
def_init -path $::env(RESULT_DIR)/iRT_result.def
init_rcx -config $::env(CONFIG_DIR)/rcx_config.json
run_rcx
report_rcx
```

第四步让 STA 强制读取 SPEF：

```tcl
read_spef $::env(RESULT_DIR)/rcx/<top>.spef
run_sta -output $::env(RESULT_DIR)/timing/
```

### 3.4 验收门禁

每个 design 必须满足：

| 检查 | 命令/证据 | 通过条件 |
|---|---|---|
| SPEF 文件存在 | `ls -lh result/rcx/*.spef` | 非空 |
| SPEF 与当前 DEF 匹配 | SPEF net 数、top name、DEF route net 数 | 明显不匹配则 fail |
| 单位可信 | SPEF header `*C_UNIT`, `*R_UNIT`, `*T_UNIT` | 与 iSTA 单位配置一致 |
| STA 实际读取 | timing log grep `read_spef` | 无 parser error |
| net delay 非零 | `quality_gate.timing_net_delay.nonzero_sample_count` | `> 0` |
| source 标记 | `rcx_coverage.json` | `trusted=true`, `source=ircx/openrcx/external` |

### 3.5 临时 fallback 规则

如果只有 sample SPEF 或错误设计 SPEF：

- 只能用于 `spef_parser_smoke`。
- `trusted=false`。
- `spef_backed_sta` 不允许 pass。
- 报告中必须写明 `design_mismatch=true` 或 `route_mismatch=true`。

## 4. SDC I/O 约束不足解决方案

### 4.1 根因

当前 SDC 通常只有 clock 约束，缺少：

- `set_input_delay`
- `set_output_delay`
- `set_driving_cell` 或 `set_input_transition`
- `set_load`
- `set_clock_uncertainty`
- false/multicycle path 语义

这会导致 STA 对 I/O 和 slew/load 的假设不可信，quality gate 中 `constraints_loaded=fail`。

### 4.2 统一 SDC 模板

为每个 PDK 建一个 template：

```text
benchmarks/flows/sdc/templates/<pdk>_aes.sdc.in
```

示例：

```tcl
create_clock -name core_clock -period ${CLOCK_PERIOD_NS} [get_ports ${CLOCK_PORT}]
set_clock_uncertainty ${CLOCK_UNCERTAINTY_NS} [get_clocks core_clock]

set_input_delay ${INPUT_DELAY_NS} -clock core_clock [remove_from_collection [all_inputs] [get_ports ${CLOCK_PORT}]]
set_output_delay ${OUTPUT_DELAY_NS} -clock core_clock [all_outputs]

set_driving_cell -lib_cell ${DRIVING_CELL} [remove_from_collection [all_inputs] [get_ports ${CLOCK_PORT}]]
set_input_transition ${INPUT_TRANSITION_NS} [remove_from_collection [all_inputs] [get_ports ${CLOCK_PORT}]]
set_load ${OUTPUT_LOAD_PF} [all_outputs]

set_false_path -from [get_ports reset*]
```

每个 design 的实际 SDC 由脚本生成：

```bash
python3 benchmarks/flows/generate_sdc.py \
  --design aes_nangate45_a \
  --template benchmarks/flows/sdc/templates/nangate45_aes.sdc.in \
  --output benchmarks/designs/aes_nangate45_a/sdc/aes.sdc
```

### 4.3 参数来源

| 参数 | 默认策略 | 后续校准 |
|---|---|---|
| clock period | 沿用当前 design 配置 | SPEF-backed STA 后按 target Fmax 重新校准 |
| input delay | `0.2 * period` | 与系统接口时序约束对齐 |
| output delay | `0.2 * period` | 与系统接口时序约束对齐 |
| uncertainty | `0.05 * period` 或 PDK 默认 | CTS/SI 后更新 |
| driving cell | PDK 中中等驱动 buffer/inverter | 按输入 pin cap/slew 校准 |
| output load | PDK 典型 cell input cap 或明确负载 | 按外部接口负载校准 |

### 4.4 SDC lint

新增脚本：

```text
benchmarks/flows/lint_sdc.py
```

输出：

```text
result/timing/sdc_lint.json
```

检查项：

- 有 clock。
- 所有非 clock input 有 input delay。
- 所有 output 有 output delay。
- input 有 driving cell 或 input transition。
- output 有 load。
- unconstrained endpoint 数为 0，或 waiver 文件列明。

质量门禁改造：

```json
{
  "constraints_loaded": {
    "unconstrained_ports": 0,
    "missing_input_slew_pins": 0,
    "waiver_count": 0
  }
}
```

## 5. Power 无 VCD/SAIF 解决方案

### 5.1 根因

当前 power 使用 vectorless 默认 toggle，`activity_source.json` 标记：

```json
{
  "activity_source": "vectorless",
  "trusted": false
}
```

因此 switching power 为 0 或不可信，不能用于 PPA 或 IR。

### 5.2 正式方案：生成 RTL 或 gate-level activity

推荐先使用 RTL 仿真 VCD，再逐步升级 gate-level SAIF。

目录规划：

```text
benchmarks/activity/<design>/
  stimulus/
  sim/
  aes_cipher_top.vcd
  aes_cipher_top.saif
  activity_manifest.json
```

步骤：

1. 建最小 AES testbench，跑固定向量和随机向量。
2. 用仿真器生成 VCD。
3. 若 power 工具更适合 SAIF，则将 VCD 转 SAIF。
4. 在 flow 中传入：

```bash
--activity-file benchmarks/activity/aes_nangate45_a/aes_cipher_top.vcd
--activity-source vcd
```

Tcl：

```tcl
run_power -vcd $::env(ACTIVITY_FILE) -output $::env(RESULT_DIR)/power/
```

### 5.3 activity provenance

必须输出：

```text
result/power/activity_source.json
```

字段：

```json
{
  "schema": "c-act/v1",
  "activity_source": "vcd",
  "trusted": true,
  "activity_file": ".../aes_cipher_top.vcd",
  "activity_sha256": "...",
  "time_window_ns": [0.0, 10000.0],
  "annotated_vertices": 39120,
  "total_vertices": 39719,
  "measured_coverage": 0.985,
  "defaulted_coverage": 0.015
}
```

### 5.4 验收门禁

| 检查 | 通过条件 |
|---|---|
| activity trusted | `trusted=true` |
| source 类型 | `vcd` 或 `saif` |
| coverage | `measured_coverage >= 0.80`，低于该值需 waiver |
| switch power | `switch_power_w > 0` |
| power report | internal/switch/leakage/total 都可解析 |
| IR 可用 | power 能输出 per-instance 或 per-net current proxy |

### 5.5 fallback 规则

如果短期没有仿真输入：

- 可以保留 vectorless，但 `trusted=false`。
- `activity_backed_power` 不允许 pass。
- 可以在 DOE 中使用 `power_proxy`，但不能影响默认签核策略。

## 6. IR-drop 无可信结果解决方案

### 6.1 根因

当前报告没有 worst/avg IR、超阈面积、IR map。PDN 可能已经有部分状态文件，但不能证明 IR 分析已运行。

### 6.2 最小 IR 闭环

分三层推进：

| 层级 | 目标 | 输出 |
|---|---|---|
| IR-0 PDN readiness | 确认 VDD/VSS special nets、stripe/ring、tap/source | `result/report/pdn_status.json` |
| IR-1 static proxy | 用 vectorless/默认功耗生成静态 IR smoke | `trusted=false` 的 `ir_drop_status.json` |
| IR-2 trusted IR | 用 VCD/SAIF activity 与 PDN 跑真实 IR | `trusted=true` 的 worst/avg/map |

### 6.3 PDN status schema

```json
{
  "schema": "c-pdn/v1",
  "pdn_ready": true,
  "special_nets_detected": true,
  "power_nets": ["VDD"],
  "ground_nets": ["VSS"],
  "stripe_count": 128,
  "via_count": 2048,
  "source_model": {
    "type": "pad_or_bump",
    "count": 16
  }
}
```

### 6.4 IR status schema

```json
{
  "schema": "c-ir/v1",
  "trusted": true,
  "activity_source": "vcd",
  "sample_count": 180000,
  "worst_drop_v": 0.032,
  "avg_drop_v": 0.006,
  "threshold_v": 0.05,
  "over_threshold_area_um2": 0.0,
  "map": "result/ir/ir_drop_map.csv",
  "report": "result/report/ir_drop.rpt"
}
```

### 6.5 实施步骤

1. 在 floorplan/PDN stage 后输出 `pdn_status.json`。
2. 在 power stage 后生成 instance current 或 net current proxy。
3. 在 IR stage 读取 DEF/GDS/PDN/power current。
4. 输出 IR report、CSV map、PNG heatmap。
5. quality gate 读取 `result/power/ir_drop_status.json` 或 `result/report/ir_drop_status.json`。

### 6.6 验收门禁

| 检查 | 通过条件 |
|---|---|
| PDN ready | `pdn_ready=true`, power/ground nets 非空 |
| IR run | `trusted=true`, `sample_count>0` |
| worst/avg | `worst_drop_v` 与 `avg_drop_v` 存在 |
| map | CSV 或 JSON map 非空 |
| threshold | `over_threshold_area_um2` 存在 |
| provenance | activity source 与 power report hash 可追踪 |

## 7. DRC 非 clean 解决方案

### 7.1 当前主因

根据 20260805 报告和 smoke 结果，主导 residual DRC 是：

| PDK | 主因 |
|---|---|
| sky130 | parallel_run_length_spacing, metal_short, minimum_area |
| nangate45 | metal_short, parallel_run_length_spacing |
| asap7 | minimum_area, parallel_run_length_spacing, metal_short |
| ics55 | minimum_area, metal_short |

DRC 不能只靠增加 `IEDA_RT_MAX_ITERATIONS` 解决。必须建立按规则类型的修复闭环。

### 7.2 P1 专项路线

| 工作包 | 目标 | 实施点 | 验收 |
|---|---|---|---|
| DRC rule testcase | 每个 top rule 有最小可复现用例 | `src/operation/iRT/test/detailed_router`, `src/operation/iDRC/test` | 单测能证明修复前 fail、修复后 pass |
| PRL repair | 降低 sky130 PRL | PRL-aware cost、parallel segment shadow、局部 spacing penalty | sky130 PRL 降低 >= 20% |
| metal short repair | 降低 nangate45/asap7 short | conflict component split、short net reroute priority、via/segment rip-up | short 降低 >= 20% |
| min-area repair | 降低 asap7/ics55 min-area | final patch candidate ranking、patch 后 spacing/short 预检查 | min-area 降低 >= 20%，short 反弹 < 5% |
| convergence control | 避免无效加轮 | `iter_delta.json`, plateau, component escalate | DRC 单调或 Pareto 改善才保留预算 |

### 7.3 结构化 DRC 反馈

每轮 detailed routing 必须输出：

```text
result/rt/detailed_router/iter_dr_series.json
result/rt/detailed_router/iter_delta.json
result/rt/detailed_router/repair_actions.json
```

必须包含：

- residual DRC by type。
- fixed/new DRC by type。
- action type、candidate count、accepted count。
- runtime seconds。
- top residual components。
- plateau decision。

### 7.4 实验矩阵

先跑 4-design：

| Profile | DR iter | SR budget | final min-area | rule-aware | component escalate | 目的 |
|---|---:|---|---|---|---|---|
| E0 | 1 | 当前 | skip | off/on 对照 | off | 复现基线 |
| E1 | 2 | 当前 | cap32 | on | on | 验证 min-area patch 收益 |
| E2 | 3 | SR depth 2 | cap32 | on | on | 验证 SR 是否导致 short/PRL |
| E3 | 5 | SR depth 2 | cap64 | on | on | 验证高预算 Pareto 上限 |

晋级规则：

- DRC total 降低 >= 10%。
- top1 DRC type 降低 >= 15%。
- routing runtime 增长 <= 50%。
- 任一非目标 DRC type 反弹 < 8%。
- `flow_success=true` 且所有 required artifact 存在。

### 7.5 Clean 与 waiver

签核成功只有两种路径：

1. `residual_drc=0`。
2. `residual_drc>0`，但所有 residual rule 都有结构化 waiver。

waiver schema：

```json
{
  "schema": "c-drc-waiver/v1",
  "design": "aes_nangate45_a",
  "waivers": [
    {
      "rule": "minimum_area",
      "layer": "metal2",
      "bbox": [0, 0, 10, 10],
      "reason": "foundry-approved false positive",
      "approver": "...",
      "expires": "2026-12-31"
    }
  ]
}
```

没有 waiver 时，GDS 存在也不能 signoff pass。

## 8. Quality Gate 最终定义

P0 完成后，`quality_gate.json` 应满足：

```json
{
  "flow_success": true,
  "signoff_success": true,
  "gates": [
    {"name": "flow_completion", "status": "pass"},
    {"name": "layout_export", "status": "pass"},
    {"name": "drc_clean", "status": "pass"},
    {"name": "constraints_loaded", "status": "pass"},
    {"name": "spef_backed_sta", "status": "pass"},
    {"name": "activity_backed_power", "status": "pass"},
    {"name": "ir_drop_analyzed", "status": "pass"},
    {"name": "congestion_summary", "status": "pass"},
    {"name": "stage_observability", "status": "pass"}
  ]
}
```

`stage_observations` 至少包含：

- placement HPWL/legal/overflow。
- routing wirelength/congestion。
- DR iter delta。
- timing net delay samples。
- power activity source 与 switch/total power。
- IR worst/avg/map。

## 9. 建议目录与产物

建议新增或规范以下产物：

```text
benchmarks/flows/rcx/rcx_resource_inventory.json
benchmarks/flows/rcx/<pdk>/rcx_config.json
benchmarks/flows/sdc/templates/<pdk>_aes.sdc.in
benchmarks/flows/lint_sdc.py
benchmarks/activity/<design>/activity_manifest.json
benchmarks/results/<run>/<design>/workspace/result/rcx/rcx_coverage.json
benchmarks/results/<run>/<design>/workspace/result/timing/sdc_lint.json
benchmarks/results/<run>/<design>/workspace/result/power/activity_source.json
benchmarks/results/<run>/<design>/workspace/result/report/pdn_status.json
benchmarks/results/<run>/<design>/workspace/result/report/ir_drop_status.json
benchmarks/results/<run>/<design>/workspace/result/quality_gate.json
```

## 10. 里程碑验收表

| 里程碑 | 范围 | 必须通过 |
|---|---|---|
| M0.1 SDC smoke | 4-design | `constraints_loaded=pass` |
| M0.2 SPEF smoke | 1-design | `spef_backed_sta=pass`, net delay 非零 |
| M0.3 SPEF expand | 4-design | 4/4 SPEF trusted，STA 无全零 net delay |
| M0.4 activity smoke | 1-design | `activity_backed_power=pass`, switch power 非零 |
| M0.5 IR smoke | 1-design | `ir_drop_analyzed=pass`, worst/avg/map 存在 |
| M1.1 DRC A/B | 4-design | top DRC type 降低 >= 15%，runtime 增长 <= 50% |
| M1.2 PDK clean candidate | 4-design | 每 PDK 1 个 clean candidate 或 waiver-ready |
| M1.3 12/12 expand | 12-design | 12/12 flow pass，signoff fail 项只剩 DRC 或 waiver |

## 11. 风险与决策点

| 风险 | 影响 | 决策 |
|---|---|---|
| 无 ITF/captab | iRCX 无法产出正式 SPEF | 获取 PDK 文件，或允许 OpenRCX/external SPEF 作为 trusted source |
| 无真实 workload | Power/IR 无可信 activity | 提供 AES testbench/vector，或明确 vectorless 仅作 proxy |
| DRC 规则映射偏差 | 修复方向错误 | 建 iDRC rule testcase 和 PDK rule audit |
| 预算换质量 | runtime 失控 | 所有 DRC 改善必须附 runtime Pareto |
| waiver 滥用 | 假 signoff | waiver 需要 rule/layer/bbox/reason/approver/expiry |

## 12. 推荐下一步

1. 先实现 `lint_sdc.py` 和 4 个 PDK 的 SDC 模板，目标 1-2 天内让 4-design `constraints_loaded=pass`。
2. 同步做 RCX inventory，明确每个 PDK 是 iRCX、OpenRCX、external SPEF 还是 only-smoke fallback。
3. 为 `aes_nangate45_a` 或 `aes_sky130_a` 生成首个 trusted SPEF，跑到 `path net delay > 0`。
4. 建 AES activity 目录和最小 VCD，先让 1 个 design `activity_backed_power=pass`。
5. 启动 IR-0/IR-1，先输出 PDN/IR structured status，再接 trusted activity。
6. DRC 进入 P1：以 `iter_delta.json` 和 `repair_actions.json` 驱动 PRL/min-area/short 三个专项，不再只看总 DRC。
