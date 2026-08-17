# GPA_NEXT_PLAN 验收证据

## P0

- checkpoint 等价：s1238 num_threads=1，`start(80)` 与
  `start(40)+advance(40)` placement.def 逐字节一致。
  md5 `8918bf9833c7c2726e4cc17606238556`。
- candidate 复现：同一 parent400 + longnet/active100/penalty0 跑两次，
  均 `incomparable`，记录 hpwl=5,811,234、overflow=0.107391，一致。
- 四设计 converged GP 结果均通过只读 LG oracle：

| design | lg_max_disp | lg_avg_disp | lg_hpwl | lg_success |
|---|---|---|---|---|
| s1238 | 3547 | 1071.44 | 6,117,295 | true |
| apb4_timer | 5012 | 1079.20 | 16,196,933 | true |
| picorv32 | 6050 | 1486.66 | 249,180,778 | true |
| aes | 5387 | 1248.62 | 692,987,095 | true |

- Harness 工具不返回 Innovus baseline：native six-entry 和 MCP 插件均无
  baselines/eval_def/full_compare。
- 失败回退：candidate 分支保留 parent checkpoint；local_run 在 accept 前
  先 restore，rollback 由工作目录 checkpoint 支持。

## P1

- 局部 GP 改善证据：apb4_timer fixed-longnet stage chain 最终 def HPWL
  15,595,418，优于同期 global 15,715,072（-0.76%）。
- 负结果/可复现：apb4 parent100 longnet candidate 多 seed
  (42/123/777) 全部 right_better，local 未在 parent100 单步获胜；
  s1238 parent400 longnet 两次复现 incomparable。
- dirty closure：`gp_verify_delta` 返回 moved cell 数量、top moved cells、
  affected net 数量、affected net HPWL delta 和 top affected nets。
- 局部动作记录：candidate / local_run 均写入 gp_experiments.jsonl 和
  checkpoint 文件。


## 跨设计 / 跨 PDK 验证现状

### 可执行矩阵

| PDK | 设计 | 直接 GP | 细粒度 chain | Innovus 参考 | 结论 |
|---|---|---|---|---|---|
| sky130 | s1238 | 5,957,257 | 5,982,121 (+0.42%) | 7,417,394 | direct 更好 |
| sky130 | apb4_timer | 15,715,072 | 15,595,418 (-0.76%) | 20,389,663 | chain 更好 |
| sky130 | picorv32 | 234,280,119 | 234,280,119 (0.00%) | 358,263,695 | 持平 |
| sky130 | aes | 665,002,127 | 689,140,722 (+3.63%) | 1,154,174,869 | direct 更好 |
| ihp130 | gcd | 620,662,411 | 631,022,147 (+1.67%) | 无 Innovus DEF | direct 更好 |

结论：细粒度 longnet chain 不是普遍优于直接 GP；只有 apb4_timer 改善。
四个 sky130 设计的直接 GP DEF HPWL 全部优于 Innovus 参考。

### 未能完成的验证与原因

- ics55：本机缺少 `N551P6M_ieda.lef` / `signalStorm55_lef.lef`；
- nangate45：本机无对应 foundry 物理库；
- asap7：本机无对应 foundry 物理库；
- ihp130 及以上 PDK：无 Innovus placement DEF，只有部分 timing 快照。

因此“所有 PDK 全验证”在当前机器上无法完成，需要补充 PDK 物理库和
Innovus/第三方参考结果。
