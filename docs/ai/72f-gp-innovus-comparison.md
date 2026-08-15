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

## 3. Innovus 实测结果

运行脚本 `docs/ipl/pl_vis/cases/innovus_place_notiming.tcl`（已复制到 `/tmp/gp_innovus_s1238` 并修正 lib 路径）。

```text
placeDesign ... real=0:00:09.0
Total net bbox length = 7.457e+03 um
```

用 iEDA 共同评价器 `report_wirelength` 读 Innovus DEF：

```text
HPWL  7,452,006 DBU (avg 22,650)
FLUTE 8,701,992
EGR   8,567,000
```

## 4. iEDA GP 初步结果

同一物理 floorplan 的 1000-units placement DEF（`/tmp/pl_vis_1000/s1238.def`），
`placer_run_gp` legacy 完整 GP（配置 target_density=0.8, adaptive_bin）：

```text
Finished with Overflow: 0.099756
HPWL: 6,009,449 DBU
```

初步比值：

```text
iEDA GP HPWL / Innovus common-HPWL = 6,009,449 / 7,452,006 = 0.806
=> 本样例低约 19.4%
```

## 5. 正式结论前必须补的公平性

1. **网表来源**：当前 iEDA 跑法从转换后的 route DEF 建网（352 nets），Innovus 从 verilog 建网（329 nets）。虽然物理设计相同，但 net 命名/数量不一致，不能直接下结论。必须让 iEDA 从同一 `s1238_a_route.v` 建网，再读同一 floorplan。
2. **共同评价器**：Innovus DEF 可正常走 iEDA `report_wirelength`；iEDA GP DEF 含 postRoute 几何，直接评价会进 iRT 并在路由几何上失败。需要生成 **placement-only + 同网表 DEF**，或让 reportWL 支持跳过 EGR。
3. **目标密度**：iEDA 配置 target_density=0.8 后自动 clamp 到 0.8145；Innovus 使用 DEF floorplan 隐含利用率。正式协议要记录两边实际 utilization，确认一致。
4. **Seed/CPU**：两边固定 seed/threads 后再各跑 3 次，报告 min/median，避免单次噪声。

## 6. 下一步

- 建立 `benchmarks/flows/run_innovus_gp_compare.sh`，自动：
  - 准备 Innovus MMMC/lib/LEF
  - 跑 Innovus wirelength-only GP + `defOut -netlist`
  - 从同一 verilog + floorplan 生成 iEDA 输入
  - 跑 iEDA legacy GP
  - 输出统一 JSON：`{innovus_hpwl, ieda_hpwl, ratio, overflow, runtime}`
- 在 s1238/apb4_timer/picorv32 上先跑通，再决定是否上 aes。
