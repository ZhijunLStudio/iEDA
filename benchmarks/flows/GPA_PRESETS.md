# GP 点工具可复现 presets（round 13 为止）

所有 start 使用 random_init=0、report_route_util=1，
input DEF 为对应 design 的已接受 parent placement.def。

## s1238 (sky130)

| preset | target_density | target_overflow | congestion_effort | HPWL | rutil | bins | rsum | WNS |
|---|---|---|---|---|---|---|---|---|
| raw | - | - | - | 5957257 | 2.768 | 654 | 208.65 | -0.0503 |
| A | 0.6 | 0.05 | 1 | 6148253 | 2.357 | 645 | 184.04 | -0.0338 |
| B | 0.5 | 0.10 | 1 | 6595040 | 2.344 | 577 | 156.91 | -0.0769 |
| C | 0.5 | 0.08 | 1 | 6666913 | 2.334 | 556 | 164.20 | - |
| cong2 | 0.5 | 0.10 | 2 | 6538020 | 2.650* | 650 | 176.40 | - |
| cong3 | 0.5 | 0.10 | 3 | 6569824 | 2.388 | 587 | 160.23 | - |
| innovus | - | - | - | 8053041 | 2.035 | 622 | 133.02 | -0.1341 |

* cong2 的 plain RUDY 峰值高于 solver 内部 LUT 峰值；仅供实验。

## nangate45_gcd

| preset | target_density | target_overflow | congestion_effort | HPWL | rutil | bins | WNS |
|---|---|---|---|---|---|---|---|
| raw | - | - | - | 5850034 | 5.149 | 289 | -1.186 |
| r13 | 0.5 | 0.10 | 1 | 7181173 | 4.468 | 379 | -1.163 |
| parent300 | - | - | - | 4472593 | 2.769 | 457 | - |
| innovus | - | - | - | 3264413 | 1.991 | 328 | -1.207 |

## ihp130_gcd

| preset | target_density | target_overflow | congestion_effort | HPWL | rutil | bins | WNS |
|---|---|---|---|---|---|---|---|
| raw | - | - | - | 620662411 | 2.655 | 1728 | 0.459 |
| r13 | 0.5 | 0.10 | 1 | 624455491 | 2.435 | 1681 | 0.428 |
| parent400 reaccept | - | - | - | 580534124 | 3.168 | 1551 | - |
| parent hotspot | - | - | - | 593333042 | 3.102 | 1623 | - |
| innovus | - | - | - | 502815015 | 2.171 | 1099 | -1.024 |

## 复现命令模板

```bash
python3 benchmarks/flows/gp_agent.py start \
  --workdir /tmp/gp_preset_<design>_<name> \
  --case-root <case_root> \
  --input-def <parent_or_accepted.def> \
  --config <pl_clean_config.json> \
  --foundry-dir <foundry_dir> \
  --iterations 600 --random-init 0 \
  --target-density <td> --target-overflow <to> \
  --congestion-effort <1|2|3> --report-route-util 1
```

```bash
python3 benchmarks/flows/gp_metrics_compare.py \
  --design <design> --case-root <case_root> \
  --macro-lef <lef> --foundry-dir <foundry_dir> \
  --congestion-model rudy --out /tmp/metrics.json \
  raw=<raw.def> innovus=<innovus_placed.def> cand=<workdir>/placement.def
```

## 已知结论

- 同一 evaluator 下，iEDA 在 sky130 s1238 上
  HPWL / timing / bins 已超过 Innovus；
  rutil max 和 rsum 尚未超过。
- nangate45 / ihp130 的 r13 preset 验证了点工具跨 PDK 可执行，
  但 HPWL 仍有差距，需要继续配置搜索。
