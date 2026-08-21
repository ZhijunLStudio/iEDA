# GP 胜利产物归档（2026-08-21，feat/parity-gp-session）

gp_wins_artifacts.tar.gz 内含 staging/：

| 文件 | 内容 |
|---|---|
| ihp130_win.def | ihp130 6/6 全胜 Innovus 的 placement |
| ihp130_win_compare.json | 同 evaluator 对比（raw/candidate/innovus） |
| nangate_win.def | nangate 6/6 全胜 Innovus 的 placement（同 die） |
| nangate_win_compare.json | 同 evaluator 对比 |
| s1238_best_5of6.def | s1238 最优点（RUDYmax 2.056 差 1%、rsum 142 差 6.8%） |
| s1238_best_compare.json | 同 evaluator 对比 |
| asap7_best_timing.def | asap7 HPWL/WNS/freq 最优（37.7M/-5.236/165.4） |
| asap7_anchor_01.def | asap7 anchor 族（bins/rsum=0） |
| asap7_anchor_compare.json | anchor 族对比 |

## 复现配方（全部确定性，seed 固定）

### ihp130（6/6）

```bash
python3 benchmarks/flows/gp_agent.py start \
  --workdir /tmp/my_ihp130_to_0.3 \
  --case-root /home/lizhijun/work/iEDA/scripts/design/ihp130_gcd \
  --input-def /home/lizhijun/work/iEDA/scripts/design/ihp130_gcd/innovus_placed.def \
  --config /tmp/ihp130_gcd_pl_clean_config.json \
  --foundry-dir /home/lizhijun/work/iEDA/scripts/foundry/ihp130 \
  --lef /home/lizhijun/work/iEDA/scripts/foundry/ihp130/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_stdcell.lef \
  --iterations 600 --seed 42 --random-init 0 --congestion-effort 3 --target-overflow 0.3 --report-route-util 1
```

### nangate（6/6，同 die）

```bash
python3 benchmarks/flows/gp_agent.py start \
  --workdir /tmp/my_goal2_nangate \
  --case-root /tmp/nangate45_gcd \
  --input-def /tmp/nangate45_gcd/innovus_placed.def \
  --config /tmp/nangate45_gcd/pl_clean_config.json \
  --foundry-dir /mnt/usb20t/PCL-167/data3/taosimin/OpenROAD/test/Nangate45 \
  --lef /mnt/usb20t/PCL-167/data3/taosimin/OpenROAD/test/Nangate45/Nangate45_stdcell.lef \
  --iterations 150 --seed 1000 --random-init 0 --seed-anchor-strength 0.5 \
  --congestion-effort 4 --bin-cnt 64 --report-route-util 1
```
后续：local_run scope=instances 关键路径锥（top-3 路径 27 实例）修复 WNS。

详见 benchmarks/flows/GPA_ROUND1_EVIDENCE.md 与 GPA_FINAL_STATUS.md。
