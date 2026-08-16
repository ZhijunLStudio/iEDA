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
4. 局部 GP stage chain：
   - apb4_timer longnet chain 最终 def HPWL 15,595,418，优于 global chain
     15,715,072（-0.76%）；
   - picorv32 chain 与 global 完全一致；
   - s1238 chain 比 global 略差；
   - aes chain 待最终汇总。
   结论：局部 GP 是可选候选，不是无条件提升；stage-adaptive 机制已可复现。

## P2：大设计 + 全流程（进行中）

1. superblue16（981k instances，DEF/LEF 2000 units 一致）：
   - GP start 20 iterations 成功，内部 HPWL 54,420,887,545；
   - `candidate longnet` 20 iterations 成功，verdict=right_better，安全回退 global；
   - checkpoint 约 746MB，验证了当前 JSON checkpoint 能承载百万级设计。
2. asic_top T28（约 321k instances）GP smoke 受阻：iDB 解析 DEF Specialnet 阶段
   超过 25 分钟未完成/进程退出，未产出 placement DEF。当前 P2 大设计验证
   以 superblue16 为可信证据，asic_top 待 iDB 解析优化后补做。
3. GP -> LG -> DP 全 iPL 放置四设计完成：

| design | iEDA full HPWL | Innovus noPrePlaceOpt | iEDA 优势 |
|---|---|---|---|
| s1238 | 5,799,199 | 7,417,394 | 21.8% |
| apb4_timer | 17,450,545 | 20,389,663 | 14.4% |
| picorv32 | 297,009,860 | 358,263,695 | 17.1% |
| aes | 1,048,273,641 | 1,154,174,869 | 9.2% |

4. s1238 已从 iEDA full placement 跑通 iRT 全局+详细布线（28.5 分钟），
   输出 `/tmp/irt_s1238/iRT_result.def`，但终端状态 `residual_drc=3471`，
   尚未 DRC clean。至少证明 GP->LG->DP->iRT 流程可跑通。
5. CTS/TO/STA 全流程仍缺；DRC clean、路由后 timing/power 也未收口。
   当前 P2 完成度：superblue16 大设计 GP+local candidate 验证 ✅；
   GP+LG+DP 四设计 ✅；s1238 route smoke ✅（DRC 未清）；asic_top ❌。
