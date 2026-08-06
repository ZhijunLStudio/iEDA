# A1 Quality Guard — Wave-0 红线检查清单

> Owner: A1　日期: 2026-07-30
> 用途：Wave-0 各 WP 进入 `review` 时逐项勾选；未冻结基线前 **禁止** 签发任何 ≥20% 成功。

## 全局红线（任一触碰 → REJECT）

| ID | 检查 | Pass 条件 |
|---|---|---|
| R1 | 假 success | DRC residual>0 时 stage/flow 不得 rc=0 宣称 clean |
| R2 | 假时序 | 无 SPEF 或关键 path `net delay==0` → WNS/Fmax 必须标 `invalid`，不得 `trusted` |
| R3 | 假功耗 | `switch_power==0` 且无 `activity_source` → Power `invalid` |
| R4 | 假 IR | 无 PDN/求解结果填 0 → REJECT；必须 `N/A` 或失败 |
| R5 | 假拥塞 | 汇总为 `-1`/`NaN` 当绿 → REJECT |
| R6 | 虚标基线 | 使用 2026-07-30 AES12 报告 WNS/Power 作优化基线 → REJECT |
| R7 | 扫参冒充算法 | 主 diff 仅为 util/padding/max_iter → REJECT（对照实验除外） |

## Wave-0 WP 验收表

| WP | 证据要求 | 期望标签 |
|---|---|---|
| WP-RCX-01 | 存在 `.spef`；flow 缺配置非零退出；daily 至少 1 PDK 跑通 | SPEF 产物 `trusted` 路径 |
| WP-STA-01 | 读 SPEF 后抽查 net delay>0；unconstrained 报告；缺失 slew 列表 | STA 可升 `trusted` 仅当 SPEF+约束绿 |
| WP-PA-01 | power JSON/报告含 `activity_source`；vectorless 显式标注 | Power=`proxy`（无 VCD）或 `trusted`（有 VCD） |
| WP-IRT-MAP-01 | congestion 汇总 ≠ -1；与 EGR CSV 一致的 avg/top1%/top5% JSON | Congestion=`trusted` |
| WP-PNP-00 | PDN DEF 或明确 stage；缺 PDN 时 IR 不得静默 | PDN 前置绿 |
| WP-PLT-01 | DirtySet/MoveTxn API 或明确里程碑补丁 + 单测 | 契约 draft→accepted 路径 |

## 基线冻结仪式（M-T0 出口）

1. A12 对 `aes_sky130_a` + `aes_nangate45_a` 全 stage 复跑
2. 填写 `benchmarks/qor/wave0_baseline_manifest.json`（run_id、binary sha、输入 hash、分项标签）
3. A1 在协调板写入 `Wave-0 baseline run_id`
4. 此后 ≥20% **只相对该 manifest**

## 当前 Verdict

| 指标 | 标签 | 备注 |
|---|---|---|
| Setup WNS / Fmax | **invalid** | net delay=0，待 WP-RCX/STA |
| Power | **invalid** | switch≈0，待 WP-PA |
| EGR WL | proxy | 有 EGR 数，但汇总 cong 无效 |
| DRC | proxy | 计数可用，非 clean |
| IR-drop | **invalid** | 未运行 |
| Congestion summary | **invalid** | -1 sentinel |

**结论：** Wave-0 完成前，不接受任何「指标提升 20%」宣传。
