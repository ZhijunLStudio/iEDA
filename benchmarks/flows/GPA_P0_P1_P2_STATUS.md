# GP P0-P2 执行状态

日期：2026-08-16
分支：`feat/parity-gp-session`

## P0：timing 权重扫描 + hold-aware（已完成）

- 新增 `$.PL.GP.Nesterov.timing_hold_slack_guard`（默认 0.1ns）。
- 根因修复：timing 初始化不再把 clock net 标为 dont-care/weight=0。
- `opt_overflow_list` 扫描结论：默认 `[0.15,0.20,0.25,0.30]` 仍是最优。
- 修复后四个设计 hold WNS 全部回正；aes 从 -1.008ns -> +0.319ns。
- 详细数据见 `GPA_TIMING_COMPARISON.md`。

## P1：congestion 接入 / picorv32 divergence / 局部 GP 策略（已完成机制，策略部分有效）

1. `placer_run_gp -mode start` 新增 `-congestion_effort 0|1` start override；
   `gp_agent.py` 暴露 `--congestion-effort`；搜索脚本暴露 `--congestion`。
2. 四设计 congestion 搜索 60/60 全部跑通，结果在
   `benchmarks/results/gp_agent_search_cong/`。
   当前 congestion 推荐仍以 global 分支为主，local 未显著更优。
3. picorv32 full-netlist 在 overflow 约 0.117~0.120 会 plateau/divergence；
   solver 现在会接受 target_overflow*1.2 内的 best-rollback placement，
   不再丢弃事务。picorv32 600 次 WL run 已直接产生有效 DEF。
4. 局部 GP stage chain（fixed longnet）最终结果：
   - apb4_timer def HPWL 15,595,418，优于 global 15,715,072（-0.76%）；
   - s1238 def HPWL 5,982,121，比 global 5,957,257 差 +0.42%；
   - picorv32 与 global 完全一致；
   - aes def HPWL 689,140,722，比 global 665,002,127 差 +3.6%。
   per-stage multi-scope chain 结果类似（apb4 -0.37%，s1238 持平）。
   s1238 parent400 的 local 参数扫描（active=20..200、hop=1..3、
   hotspot ratio=0.05..0.4、penalty=0/2/5）全部 right_better/incomparable，
   说明 local GP 在收敛期没有优势；早期 local 可被接受，但对最终 HPWL
   影响很小。结论：当前 local GP 是安全候选，不是无条件提升，后续应
   从“梯度乘系数”升级为带局部密度目标/局部回退的二次优化。

## P2：大设计 + 全流程（进行中）

1. superblue16（981k instances，DEF/LEF 2000 units 一致）：
   - GP start 20 iterations 成功，内部 HPWL 54,420,887,545；
   - `candidate longnet` 20 iterations 成功，verdict=right_better，安全回退 global；
   - checkpoint 约 746MB，验证了当前 JSON checkpoint 能承载百万级设计。
2. asic_top T28（约 851k solver instances，含 filler）GP smoke 已跑通：
   - 工作绕开 iDB Specialnet 解析瓶颈，先剥离 DEF SPECIALNETS section
     （GP 不需要电源/地 special routing）；
   - `placer_run_gp -mode start -iterations 10` 成功，内部 HPWL 6,019,100,220；
   - 证明 T28/asic_top 也能进入 GP session，但完整 DEF 解析仍待 iDB 优化。
3. GP -> LG -> DP 全 iPL 放置四设计完成；timing-on 版本也四设计完成：

| design | iEDA full HPWL | Innovus noPrePlaceOpt | iEDA 优势 |
|---|---|---|---|
| s1238 | 5,799,199 | 7,417,394 | 21.8% |
| apb4_timer | 17,450,545 | 20,389,663 | 14.4% |
| picorv32 | 297,009,860 | 358,263,695 | 17.1% |
| aes | 1,048,273,641 | 1,154,174,869 | 9.2% |

   timing-driven GP -> LG -> DP：

| design | iEDA timing full HPWL | iEDA 优势 |
|---|---|---|
| s1238 | 5,745,273 | 22.5% |
| apb4_timer | 17,535,062 | 14.0% |
| picorv32 | 296,949,944 | 17.1% |
| aes | 1,048,174,208 | 9.2% |

4. s1238 路由对照（同一 iRT 脚本）：
   - iEDA GP+LG+DP：`residual_drc=3471`
   - iEDA +CTS：`routed_nets=354/354, residual_drc=3394`
   - iEDA timing GP+LG+DP：`routed_nets=352/352, residual_drc=3343`
   - Innovus noPrePlaceOpt DEF：`routed_nets=352/352, residual_drc=121`
   结论：iRT 能 clean 地路由 Innovus placement；iEDA placement 的
   metal_short / parallel_run_length_spacing 仍高一个量级。问题主要在
   iRT 对 iEDA DEF/placement 的 pin-access/DRC 兼容性，不在 GP 数值收敛。
   no-filler iEDA placement 路由结果同为 `residual_drc=3471`，已排除 filler。
5. CTS/TO/STA 全流程仍缺；DRC clean、路由后 timing/power 也未收口。
   当前 P2 完成度：superblue16 大设计 GP+local candidate 验证 ✅；
   asic_top T28 GP smoke ✅（strip specialnets 后）；
   GP+LG+DP 四设计 ✅；s1238 route smoke ✅（DRC 未清）。
