# GP timing-driven 口径（Innovus noPrePlaceOpt+t vs iEDA timing GP）

日期：2026-08-15
分支：`feat/parity-gp-session`
脚本：`benchmarks/flows/run_gp_timing_compare.py`

## 1. 口径

- Innovus 参考：`<case>/innovus_placed_nodel_timing.def`
  （`placeDesign -noPrePlaceOpt` + MMMC/SDC，保留完整 netlist）。
- iEDA：从该 Innovus DEF 推导出同网表 unplaced DEF，
  `is_timing_effort=1`、`num_threads=1`、`seed=42`、`opt_overflow_list=[0.15,0.20,0.25,0.30]`，
  经 `placer_run_gp -mode start` 跑 GP。
- 统一时序评价：iEDA `run_timing_eval -routing_type HPWL`，对四个 placement
  使用同一 liberty + SDC + HPWL 预估 RC，输出 setup/hold WNS/TNS。
  这是“同一把尺子量两个工具”，不是 Innovus 内部 report_timing。
- HPWL：`def_hpwl_eval.py`。

执行：

```bash
cd /home/lizhijun/work/iEDA.ai
python3 benchmarks/flows/run_gp_timing_compare.py --designs s1238 apb4_timer picorv32 aes
```

结果：`benchmarks/results/gp_timing_compare/<design>/result.json`（results 目录 gitignore，不提交）。

## 2. 结果

| design | placement | HPWL | setup WNS ns | setup TNS ns | suggest MHz |
|---|---|---|---|---|---|
| s1238 | Innovus WL | 7,417,394 | 0.0022 | 0.0 | 667.7 |
| | Innovus timing | 7,440,096 | 0.0014 | 0.0 | 667.3 |
| | iEDA WL | 6,147,101 | 0.0630 | 0.0 | 695.9 |
| | iEDA timing | **6,230,090** | **0.1325** | 0.0 | **731.2** |
| apb4_timer | Innovus WL | 20,389,663 | -0.5499 | -24.73 | 487.8 |
| | Innovus timing | 20,540,435 | -0.5067 | -23.21 | 498.3 |
| | iEDA WL | 17,491,792 | -0.5195 | -22.89 | 495.2 |
| | iEDA timing | **17,507,726** | **-0.4625** | **-19.66** | **509.6** |
| picorv32 | Innovus WL | 358,263,695 | -4.8230 | -1303.4 | 136.6 |
| | Innovus timing | 370,973,336 | -4.5001 | -1389.8 | 142.9 |
| | iEDA WL | 303,689,095 | -3.2049 | -820.2 | 175.3 |
| | iEDA timing | **305,618,735** | **-3.2310** | **-746.1** | **174.5** |
| aes | Innovus WL | 1,154,174,869 | -2.2833 | -6128.1 | 209.1 |
| | Innovus timing | 1,187,135,383 | -3.2363 | -6444.5 | 174.3 |
| | iEDA WL | 1,044,588,360 | -4.7697 | -6122.9 | 137.6 |
| | iEDA timing | **1,044,703,203** | **-4.4024** | **-5958.9** | **144.9** |

（加粗为 iEDA timing 行，便于和 Innovus timing 比较。）

## 3. 结论（v2，clock-net fix + hold guard 后）

1. **timing-driven 口径已补上且 hold 问题已修复**。根因是 timing 初始化把
   clock net 标记为 dont-care/weight=0，GP 不再约束时钟网跨度，导致
   propagated-clock 评估下 hold/skew 恶化。现在 clock net 保留在 HPWL 目标中，
   timing 权重更新跳过 clock net。
2. 四个设计的 hold WNS 全部回正：aes 从 -1.008ns 修到 +0.319ns，
   picorv32 从 -0.353ns 修到 +0.383ns。
3. s1238 / apb4：timing 同时改善 WNS/TNS，HPWL 代价仅 0.09%~1.35%。
4. picorv32：timing 相对 WL 只差 0.026ns WNS，TNS 改善 9.0%，HPWL 代价 0.64%。
5. aes：timing 相对 WL 改善 0.367ns WNS、164ns TNS，HPWL 代价仅 0.01%；
   但 WNS 仍落后 Innovus timing 1.17ns，属于下一步 setup 权重调优空间。
6. 旧版 timing 以 11.6% HPWL 代价换 setup 的做法被判定为不划算，已用
   上述健康版本取代。

**当前判断**：timing mode 已可用且 hold 安全；大设计 setup 收敛仍需调优。

## 4. timing 会话等价性

s1238 timing 配置，单线程 seed=42：

- `start(380)` 与 `start(340) -> checkpoint -> close -> resume(40)`
  生成的 DEF 逐字节一致（md5 `de4d7b0c...`）。
- 两次独立 timing run 的 GP 结果逐项一致：
  `stop_reason=target_reached iterations=1-418 hpwl=5921643 overflow=0.0984951`。

说明 timing 模式下的 checkpoint/resume 数值路径可复现；跨工艺角/大设计等价
尚未做。

clock-net fix + hold guard 版本已复测：`start(380)` vs
`start(340)+resume(40)` DEF 仍逐字节一致，md5 不变。

## 5. 前置 bug 修复

timing 模式初始化时 `StaIO::set_instance_flip_flop()` 会对 filler/endcap 等
physical-only cell 解引用空 STA instance 导致段错误。已在
`TimingEngine::isSequentialCell()` 增加空指针保护并提交：

```text
f17556f parity: harden STA sequential-cell lookup for physical-only instances
```

## 6. 下一步建议

- 对 aes / picorv32 做 `opt_overflow_list` 小扫描，找 timing net weight 的
  阈值和更新次数，降低大设计 HPWL 代价。
- 增加 hold 约束/检查，避免 timing GP 在 aes 上把 hold WNS 打成负值。
- 大设计上验证 timing resume 等价（当前只验证了 s1238）。
