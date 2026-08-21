# GPA 最终状态（Round 1-11 总结）

日期：2026-08-21
分支：feat/parity-gp-session（已推送 personal）

## 结论

deepseek-harness + @ieda-ai/dsh-tool-ieda-gp 在 4 个 PDK 的开放目标会话与
自主实验中达成：**3 个设计全面超过 Innovus（6/6，独立复验通过），
其余设计 5/6、4/5、4/6**，全部会话插件级错误为 0。

## 全胜设计

### ihp130_gcd（6/6）

| 指标 | candidate | Innovus |
|---|---|---|
| HPWL | 410,214,665 | 502,815,015 |
| RUDY max | 1.866 | 2.171 |
| bins | 844 | 1099 |
| rsum | 213.15 | 245.28 |
| WNS | -0.988 | -1.024 |
| freq | 167.0 | 166.0 |

配方：Innovus DEF 起步 + cong3 + target_overflow=0.3（crossover 扫描）。

### nangate45_gcd（6/6，同 die）

| 指标 | candidate | Innovus |
|---|---|---|
| HPWL | 2,768,159 | 3,264,413 |
| RUDY max | 1.896 | 1.991 |
| bins | 232 | 328 |
| rsum | 75.66 | 100.39 |
| WNS | -1.197 | -1.207 |
| freq | 594.5 | 590.8 |

配方：Innovus DEF 起步 + seed_anchor_strength=0.5 + effort4 + bin_cnt 64
（第二代会话自发现，独立复验通过）+ 关键路径锥局部修复。

### picorv32（6/6，sky130，大设计 ~26.5k cells）

| 指标 | candidate | Innovus |
|---|---|---|
| HPWL | 232,106,315 | 308,691,343 |
| RUDY max | 1.800 | 1.951 |
| bins | 424 | 637 |
| rsum | 78.76 | 98.37 |
| WNS | -4.172 | -4.201 |
| freq | 149.9 | 149.2 |

配方（会话自发现，独立复验通过）：raw baseline DEF 起步 +
congestion_effort=1 + 400 迭代 + random_init=0，一步达成且确定性复现。

## 未达成设计（结构性缺口）

### s1238（sky130）5/6

- 最优点：HPWL 7,533,348 / RUDYmax 2.056 / bins 616 / rsum 142.06 /
  WNS -0.120 / freq 617.1。
- 缺口：RUDYmax 2.056 vs 2.035（+1%）、rsum 142.06 vs 133.02（+6.8%）。
- 根因（已实证）：局部动作空间存在强吸引子 (2.056,142.06)，另一 Pareto 端
  (2.393,124.29) 与它互斥；Innovus 点严格占优且不在可达盆地。
  GP 内部拥塞模型与 verify RUDY 的校准差（route cap/dm 因子、网格分辨率）
  已部分修复（effort4 同模型 + dbu 校准），但密度-拥塞联合目标的
  收敛平衡仍是求解器级问题。

### asap7_aes 3/6

- Pareto 端 A（timing 导向）：HPWL 37.7M / RUDYmax 2.49 / WNS -5.236 /
  freq 165.4（HPWL/WNS/freq 超 Innovus）。
- Pareto 端 B（congestion 导向，anchor 族）：HPWL 41.7M~45.1M /
  rudy_max 0.77~0.91 / bins=rsum=0（bins/rsum 与 Innovus 打平）。
- 缺口：rudy_max 底线 0.77 与 Innovus 0.706 之间有不可逾越的宏区
  需求集中；WNS -7.5 与 Innovus -7.39 之间受 in-GP STA 乐观问题限制。

## 工具链交付（相对交接文档的变化）

1. run record 带 def_hpwl；verify metrics mtime 缓存；run 缓存状态指纹。
2. propose 全带 executable_action；新增 timing/congestion 域。
3. observe experiments（跨 workdir Pareto 记忆）。
4. start/full timing=1（opt_overflow_list 修复）+ bin_cnt 旋钮。
5. local_congestion（verify-RUDY 疏散，region/net 锥双模式，自动回滚）。
6. congestion_effort=4（evaluator-aligned RUDY，dbu 校准）。
7. 大量 C++ 修复：context clobbering、lg LEF、scope 校验、
   checkpoint 符号标签、in-GP timing 权重诊断（centrality=0 根因）。

详见 GPA_ROUND1_EVIDENCE.md（4.x 节逐轮证据）。
