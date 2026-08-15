# 72f Innovus GP 对照：本机可用性与 s1238 初跑

- 日期：2026-08-15
- 状态：**可跑通；初步数据已取得；正式 apples-to-apples 尚差 iEDA 同网表重跑**

---

## 1. 本机 Innovus 状态

```text
/usr/local/bin/innovus -> /home/yangkang/cadence/INNOVUS201/bin/innovus
Innovus v20.10-p004_1 (64bit)
```

License：

```bash
export LM_LICENSE_FILE=/home/yangkang/cadence/INNOVUS201/license/cadence.dat
export CDS_LIC_FILE=/home/yangkang/cadence/INNOVUS201/license/cadence.dat
```

`innovus -version` 和 `placeDesign` 均已实测成功。

## 2. GP-only 对照协议（wirelength-only）

与 `docs/ai/commercial_comparison_procedure.md` 一致，GP 阶段先不看 timing/congestion：

| 项 | 设置 |
|---|---|
| Netlist | `/home/yangkang/project/Open3DBench-Harness/Harness-OpenROAD-3D/iDATA/s1238/route/s1238_a_route.v` |
| Tech LEF | 同上 iDATA `innovus/pdk/sky130_fd_sc_hd_innovus_tech.lef` |
| Cell LEF | `scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef` |
| Floorplan | `docs/ipl/pl_vis/cases/s1238/innovus_in.def`（所有 movable UNPLACED，同一 die/core/rows） |
| MMMC | 无 SDC 空约束（non-timing-driven） |
| Innovus effort | `setPlaceMode -place_global_cong_effort low -place_detail_wire_length_opt_effort none` |
| 输出 | `defOut -netlist innovus_placed_nets.def` |

## 3. 自动化脚本与结果（GP-only，wirelength-only）

脚本：`benchmarks/flows/run_innovus_gp_compare.sh`

```bash
benchmarks/flows/run_innovus_gp_compare.sh s1238
benchmarks/flows/run_innovus_gp_compare.sh apb4_timer
benchmarks/flows/run_innovus_gp_compare.sh picorv32
benchmarks/flows/run_innovus_gp_compare.sh aes
```

公平性处理：

1. Innovus 和 iEDA 使用同一 verilog netlist。
2. iEDA 输入 DEF 直接从 Innovus 输出 DEF 生成：只把 movable 组件改回 UNPLACED，保留同一 floorplan/rows/GCell/NETS，因此两边网表、die/core/rows 完全一致。
3. Innovus 关闭 refinePlace（`setPlaceMode -place_design_refine_place false`），输出的是未合法化的 GP 结果；iEDA 使用 `placer_run_gp` legacy 完整 GP，也不跑 LG/DP。
4. 共同评价器 `benchmarks/flows/def_hpwl_eval.py`：读同一 cell LEF 的 pin 偏移，对两个 DEF 算同一 HPWL，不跑 EGR。

实测（2026-08-15）：

| design | Innovus GP HPWL | iEDA GP HPWL | iEDA/Innovus | iEDA 降低 | iEDA GP overflow |
|---|---|---|---|---|---|
| s1238 | 8,053,041 | 5,982,950 | 0.743 | **25.7%** | 0.0991 |
| apb4_timer | 18,566,747 | 15,689,143 | 0.845 | **15.5%** | 0.0983 |
| picorv32 | 308,691,343 | 234,083,737 | 0.758 | **24.2%** | 0.0997 |
| aes | 914,210,691 | 665,233,032 | 0.728 | **27.2%** | 0.0990 |

## 4. 读数时的注意事项

- 这是 **GP-only 且 no-timing/no-congestion** 的对比；不含 Innovus refinePlace、LG/DP、CTS/route。
- 共同 HPWL 评价器使用 cell LEF pin 偏移，不包含 EGR/FLUTE；与 iEDA report 的 EGR 模型不同，但两边用同一实现。
- iEDA 的 GP solver log HPWL 与共同评价器有 1~2% 差（log 是 cell-center/pin 定义细节差），结论方向一致。
- Innovus placeDesign 内部仍可能做 pre-place opt/scanReorder；这属于其默认 GP 流程，未额外禁止。下一步若要比纯求解器，需要用 `place_opt -run_global_place` 或 `-noPrePlaceOpt` 进一步收口。

## 5. 结论

本机 Innovus 20.10 可以稳定作为 GP 对照。当前 4 个 sky130 设计上，iEDA 全局布局 HPWL 全面低于 Innovus GP-only，领先 15.5%~27.2%；同时 iEDA overflow 均收敛到目标 0.1 附近。

## 5bis. Congestion 探针（GP-only，修复后）

脚本：`benchmarks/flows/run_innovus_gp_congestion_sweep.sh <design>`

修复内容：移除 congestion 模式中的逐迭代 density-scale 正向膨胀。拥塞信息现在只通过 RUDY 加权线长力进入求解，不再通过密度膨胀正反馈破坏布局。

| design | iEDA WL HPWL | iEDA WL route_util | iEDA cong HPWL | iEDA cong route_util | 结论 |
|---|---|---|---|---|---|
| s1238 | 5,982,950 | 1.831 | 5,998,135 (+0.25%) | 1.658 (-9.4%) | 稳定，拥塞改善 |
| apb4_timer | 15,689,143 | 1.246 | 15,764,030 (+0.48%) | 1.133 (-9.1%) | 稳定，拥塞改善 |
| picorv32 | 234,083,737 | 2.178 | 237,164,266 (+1.32%) | 1.744 (-19.9%) | 稳定，拥塞明显改善 |
| aes | 665,233,032 | 2.540 | 669,242,685 (+0.60%) | 2.313 (-8.9%) | 稳定，拥塞改善 |

Innovus 对照（GP-only, native EGR overflow）：

| design | Innovus low HPWL / overflow | Innovus high HPWL / overflow |
|---|---|---|
| s1238 | 8,053,041 / H12.69 V3.24 | 8,210,338 / H11.27 V4.17 |
| apb4_timer | 18,566,747 / H2.95 V0.24 | 18,578,313 / H2.73 V0.47 |
| picorv32 | 308,691,343 / H9.50 V0.85 | 354,037,316 / H4.58 V1.11 |
| aes | 914,210,691 / H10.39 V0.57 | 986,592,557 / H7.48 V0.43 |

说明：

1. iEDA congestion mode 现在所有已测设计都稳定收敛到 target overflow，route util 下降 9~20%，HPWL 代价 0.25~1.32%。
2. Innovus high congestion 在 s1238/apb4 只改善 H，V 反而变差；picorv32 上 H 大幅下降但 HPWL 增加 14.7%。
3. 两边 congestion 指标不是同一模型（Innovus EGR vs iEDA RUDY），因此上表只做并排观察，不做直接谁优谁劣。

## 6. 下一步

- 加入 Innovus `place_opt -noPrePlaceOpt` / `place_design -noPrePlaceOpt` 对照，进一步剥离预放置优化。
- 在共同评价器中同时输出 STWL/FLUTE 与 bin 密度分布。
- 把 `local/candidate` 模式也纳入同一 harness：父 checkpoint -> local vs global -> 与 Innovus GP 对照。
- 固定 seed/threads 各跑 3 次，输出 min/median/max。
- 扩展到 superblue16（981k）前，先确认 Innovus 8 CPU license 上限与内存。
