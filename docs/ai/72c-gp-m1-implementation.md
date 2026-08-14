# 72c GP 工具化 M1/M2 实施计划（代码级）

- 依据：`72-gp-tool-first-stage-implementation-plan.md`（M1/M2）、`72b-gp-cli-protocol.md`（调用形态）
- 状态：**M1、M2 均已实现并通过全部验收（2026-08-14）**
- 原则：**旧路径位级等价优先**——重构不改变任何现有数值行为，用等价测试证明

---

## 1. 现状核实（对应 72 号文档 §2 的判断，已逐条对照到行）

| 72 号文档判断 | 代码事实 |
|---|---|
| `runGP()` 每次先随机初始化 | `PLAPI.cc:843` `RandomPlace(...).runRandomPlace()` 无条件执行；seed 固定 1000（`RandomPlace.cc:28-29`） |
| `NesterovPlace` 临时创建，调用结束状态消失 | `PLAPI.cc:844` 栈对象，析构删掉整个 `NesterovDatabase` |
| 完整迭代循环在 `NesterovSolve()` 内，收敛/最佳/扰动状态是局部变量 | `NesterovPlace.cc:1371-1749`；局部量清单见 §2 |
| 底层有 `runNextIter()` 但不能单独代表完整迭代 | `Nesterov.hh:69`；完整迭代 = runNextIter + 回溯循环 + 梯度/惩罚/收敛更新（`NesterovSolve` 循环体） |
| 发散可能直接退出进程 | 现有实现走 `finalizeResult` + `runNesterovPlace` 返回 false，由 `isNesterovHardFailure` 判定——**已不直接 exit**，M1 沿用 |

额外确认：

- 测试配置 `benchmarks/designs/aes_sky130_a/workspace/iEDA_config/pl_default_config.json` 的 `num_threads=1` → 单线程确定性，等价测试可直接位级比较。
- 调试宏 `PRINT_LONG_NET/RECORD_ITER_INFO/PRINT_COORDI/PRINT_DENSITY_MAP` 全为 0（`NesterovPlace.cc:51-55`），调试文件流无跨迭代状态问题；M2 若启用再处理。
- 测试样板：`src/operation/iPL/test/RunGPResultTest.cc`（idm 初始化 + `iPLAPIInst.runGPResult()` + 产物断言）；CMake 目标 `ipl_run_gp_result_test` 已在 ninja 图内。
- Tcl 入口：`placer_run_gp`（`CmdPlacerRunGP`）→ `iplf::PlacerIO::runGlobalPlacement()`（`ipl_io.cpp:191`）→ `PLAPI::runGPResult()`。

---

## 2. 会话状态清单（从 `NesterovSolve()` 局部量提升为成员）

求解器自身状态（`Nesterov` 对象，`NesterovDatabase._nesterov_solver`）已在对象内，天然跨调用存活：current/next 坐标、SLP 坐标、梯度、步长、parameter、current_iter。

需要提升为 `NesterovPlace` 成员的循环局部量：

| 局部量（原行号） | 成员名 | 说明 |
|---|---|---|
| `sum_overflow`（1387） | `_sum_overflow` | 当前溢出 |
| `prev_hpwl` / `hpwl`（1388） | `_prev_hpwl` / `_cur_hpwl` | 迭代前后 HPWL |
| `sum_overflow_threshold`（1395） | `_sum_overflow_threshold` | 发散判定阈值 |
| `hpwl_attach_sum_overflow`（1396） | `_hpwl_attach_sum_overflow` | 发散判定 |
| `max_phi_coef_record`（1397） | `_max_phi_coef_record` | phi 系数只降一次 |
| `cur_opt_overflow_step`（1403） | `_cur_opt_overflow_step` | 约束优化步 |
| `min_perturb_interval/last_perturb_iter`（1428-29） | `_last_perturb_iter`（常量保留） | 扰动间隔 |
| `is_add_quad_penalty/is_cal_phi`（1430-31） | `_is_add_quad_penalty` / `_is_cal_phi` | 二次惩罚/phi 模式 |
| `stop_placement`（1432） | `_stop_placement` | 停滞回退触发 |
| `best_position_list/cur_position_list`（1433-36） | `_best_position_list` / `_cur_position_list` | 最佳/当前坐标快照 |
| `best_density_scale_list/cur_density_scale_list`（1438-39） | 同名成员 | WP-PL-01 膨胀回滚 |
| `finished_iter`（1440） | `_finished_iter` | 实际完成迭代 |
| `final_step_length/gradient_norm/route_util`（1441-43） | 同名成员 | 尾态指标 |
| `iter_num`（1451） | `_current_iter` | 会话迭代号 |

每迭代临时量（`next_slp_*_grad_list`、`num_backtrack` 等）保持迭代内局部，不提升（无跨迭代依赖）。

`_nes_config` 内运行中变异（`set_max_phi_coef`，行 1618）随对象存活，天然持久。

---

## 3. `NesterovPlace` 方法拆分（位级等价约束）

```cpp
// 原样保留：runNesterovPlace() 构造、initNesterovPlace() 初始梯度/惩罚/solver 初始化
// NesterovSolve() 拆为：
void setupNesterovSolve(inst_list);                    // 原循环前准备（局部量→成员初始化）
GPAdvanceOutcome advanceNesterovIterations(inst_list, int32_t budget);
                                                       // 循环体逐字搬移；budget 耗尽且未终止 → kBudgetReached
void finishNesterovSolve(inst_list);                   // 原尾部：kMaxIter 收尾 + notify + writeBack
void publishPlacement();                               // notify + writeBack（每批次发布，不改求解器状态）
bool isSessionFinished() const;                        // _last_result.outcome != kNotRun

// 遗留兼容：
void NesterovSolve(inst_list) { setup; advance(INT32_MAX); finish; }   // 与旧行为位级一致
```

不变量：

1. `advance` 循环体与原 `for` 循环体**逐字相同**（含 break 路径）；唯一差异是循环上界 = `min(max_iter, _current_iter + budget)`。
2. `advance` 返回 `kBudgetReached` 时**不**执行 kMaxIter 收尾（原代码仅在循环自然耗尽时收尾）；terminal break 路径行为不变。
3. `publishPlacement()` = `notifyPLOverflowInfo + notifyPLPlaceDensity + writeBackPlacerDB`。`writeBackPlacerDB` 只读 NesInstance 坐标写回 PlacerDB，不触碰求解器状态 → 中间发布不影响后续迭代（由观察无干扰测试证明）。
4. 会话态重新 `start` 需重建对象（构造函数即初始化）；`relinearize` 属 M3，不在 M1。

---

## 4. PLAPI 会话 API（M1：内存会话，无 Checkpoint）

```cpp
enum class GPRunMode { kStart, kAdvance };
enum class GPStopReason { kNotRun, kBudgetReached, kTargetReached, kMaxIter,
                          kOverflowTargetMiss, kDiverged, kInvalidMetric };
struct GPRunRequest { GPRunMode mode; int32_t accepted_iterations = 20; bool random_init = true; };
struct GPRunResult { /* ok, session_active, stop_reason, start/end/requested/executed_iterations,
                        hpwl, overflow, step_length, density_penalty, reason, batch iteration_records */ };

GPRunResult gpRun(const GPRunRequest&);
bool gpSessionActive() const;
void gpCloseSession();   // 显式丢弃会话（对应 72b §5 lineage 不覆盖）
```

- `kStart`：会话已存在 → `ok=false`（拒绝，不隐式丢弃）；事务 `beginStageTransaction("global_placement")` 由会话持有；`random_init=true` 时 `RandomPlace`；构造 `NesterovPlace` → `initialize` → `advance(budget)` → 批次发布；terminal 则映射 `_flow_status` 并 commit/rollback、关闭会话。
- `kAdvance`：无会话 → `ok=false`；`advance(budget)` → 发布；terminal 则同上收尾。
- **遗留 `runGPResult()` 不改为调用 `gpRun`**（避免双事务/状态映射差异），而是改为直接驱动同一批会话原语：`beginStageTransaction → RandomPlace → 构造会话 → initialize → advance(max_iter) → finish → 状态映射 → commit/rollback`。路径逐语句等价。
- 会话为 PLAPI 成员 `std::unique_ptr<NesterovPlace>`，析构自动释放。

---

## 5. Tcl 命令扩展

`placer_run_gp` 增加选项（`CmdPlacerRunGP` + `PlacerIO::runGlobalPlacementSession`）：

```text
placer_run_gp                          # 无参数：遗留完整运行（行为不变）
placer_run_gp -mode start  -iterations 20 -random_init 1
placer_run_gp -mode advance -iterations 20
placer_run_gp -mode close              # 丢弃会话
```

返回沿用 `placementTclResult` 风格，附 stop_reason/迭代区间打印。

---

## 6. 测试矩阵（GPSessionTest.cc，每场景独立进程，CTest 分注册）

| # | 场景 | 断言 |
|---|---|---|
| A | legacy 完整 `runGPResult()` | 与改动前基线一致（iw 用 `ipl_run_gp_result_test` 回归）+ 坐标快照输出 |
| B | `start(40)` ≡ `start(20)+advance(20)` | PlacerDB 全实例坐标逐位相等；iteration_records 逐字段相等；hpwl/overflow 相等 |
| C | 观察无干扰：`start(20) → 读 metrics+坐标 → advance(20)` vs 不观察 | 最终坐标逐位相等 |
| D | legacy 完整 ≡ `start(max_iter)` 会话完整跑完 | 坐标逐位相等、outcome 相同 |
| E | 参数校验：advance 无会话、start 已有会话、iterations≤0 | `ok=false`、reason 非空、不碰求解状态 |

实现：argv 场景分发（每场景新进程，规避 idm 进程内二次初始化）；坐标快照遍历 `PlacerDB` 实例中心坐标写入文件后 diff；单线程（配置 num_threads=1）。

---

## 7. 构建与验证命令

```bash
cmake --build build --target ipl_run_gp_result_test ipl_gp_session_test -j$(nproc)
build/bin/ipl_run_gp_result_test                      # 遗留回归
build/bin/ipl_gp_session_test --scenario B            # 等价性
build/bin/ipl_gp_session_test --scenario C
...
cmake --build build --target iEDA -j$(nproc)          # Tcl 集成编译
```

## 8. M1 明确不做（护栏）

- 不做 Checkpoint 持久化（M2）、不做 `relinearize`（M3）、不做局部 GP（M4）。
- 不接 `--seed`（RandomPlace 固定 1000；种子管线下放 M2 与 72b 一起）。
- 不改任何求解数学（不动 `runNextIter`/梯度/步长计算；不动 SLP 坐标写回语义）。
- 不新建 GPSessionManager（M1 会话由 PLAPI 单例持有，M2 再接 72 号文档 §5 的 Manager）。

---

## 9. 实现落点（已合入工作区）

| 文件 | 改动 |
|---|---|
| `NesterovPlace.hh/.cc` | 循环局部量提升为成员（§2 清单）；`NesterovSolve` 拆为 `setupNesterovSolve` / `advanceAcceptedIterations(budget)` / `finishSession` / `publishPlacement`；新增 `initializeSession`；遗留 `NesterovSolve(inst_list)` 变为 setup+advance(INT32_MAX)+finish 驱动（位级等价） |
| `NesterovPlaceContract.hh` | 新增 `GPAdvanceOutcome`（kBudgetReached/kFinished/kAlreadyFinished/kNotInitialized） |
| `api/GPContract.hh`（新） | api 层契约：`GPRunMode`/`GPStopReason`/`GPRunRequest`/`GPRunResult`/`GPIterationRecord`（不依赖 module 内部头） |
| `api/PLAPI.hh/.cc` | `gpRun`/`gpSessionActive`/`gpCloseSession`；会话状态 pimpl `GPSessionState`（NesterovPlace + StageTransaction + record offset）；遗留 `runGPResult()` **未改动** |
| `ipl_io.h/.cpp` | `runGlobalPlacementSession(mode, iterations, random_init)`：镜像 `runGlobalPlacement` 的 DB bootstrap |
| `tcl_ipl.h/.cpp` | `placer_run_gp -mode {start\|advance\|close} -iterations N -random_init 0\|1`；无参数保持遗留行为 |
| `test/GPSessionTest.cc`（新）+ `test/CMakeLists.txt` | 6 场景（§6 矩阵），每场景独立进程 |
| `test/RunGPResultTest.cc` / `test/APIFailureInjectionTest.cc` | 本机修复：DEF 输入指向 `benchmarks/results/.../iFP_result.def`（原 `gcd_place.def` 只存在于 lxq 机器）；/tmp 输出目录加 `_lzj` 后缀（原目录被 lxq 占用） |

## 10. 验收结果（2026-08-14，gcd_sky130_a，num_threads=1）

| 场景 | 结果 |
|---|---|
| seg10x2（start 10 + advance 10）vs seg20（start 20） | **coords.txt 与 records.txt 逐位一致**；第二批次 start_iteration=11（未重新随机初始化） |
| observe（批次间读 metrics + 读已发布设计）vs seg20 | **逐位一致**（观察无干扰） |
| legacy `runGPResult()` 完整运行 vs 会话完整运行（start, max_iter） | **坐标逐位一致**；最终 Overflow 0.0988787 / HPWL 6294220 相同 |
| `ipl_run_gp_result_test`（遗留回归） | 全部 PASS |
| `ipl_api_failure_injection_test` / `ipl_nesterov_contract_test` / `ipl_nesterov_place_config_test` | 全部 PASS |
| Tcl 冒烟（`placer_run_gp -mode start 5` → `advance 5` → `close` → advance 应失败） | 通过；迭代数值与 C++ 测试路径一致（Iter 10: overflow 0.710647 / HPWL 5658029） |

## 11. 使用方式

```tcl
init_pl -config <pl_default_config.json>      # 与 run_placer 相同的初始化
placer_run_gp -mode start  -iterations 20     # 建会话 + 随机初始 + 20 次已接受迭代
placer_run_gp -mode advance -iterations 20    # 同一会话继续 20 次（不重新随机初始化）
placer_run_gp -mode start  -iterations 5 -random_init 0   # 保留当前坐标重建会话
placer_run_gp -mode close                     # 丢弃会话（回滚未提交事务）
placer_run_gp                                  # 无参数：遗留完整运行，行为不变
```

C++ API：`iPLAPIInst.gpRun(GPRunRequest{mode, accepted_iterations, random_init})` → `GPRunResult`（stop_reason/iteration 区间/本批次 records/metrics）。会话 active 时再次 start 会被拒绝（`kRejected`），close 后可重启。

## 12. M2 实现与验收（Checkpoint 持久化 + 跨进程数值等价）

### 12.1 实现落点

| 文件 | 改动 |
|---|---|
| `solver/nesterov/Nesterov.hh/.cc` | `Nesterov::State`（全量向量）+ `captureState()/restoreState()` |
| `NesterovPlaceContract.hh` | `GPStateCheckpoint`（会话标量、记录历史、逐实例密度坐标/scale、best/cur 快照、`Nesterov::State`、拓扑指纹） |
| `NesterovPlace.hh/.cc` | `captureCheckpoint()/restoreCheckpoint()` + `saveGPCheckpointFile/loadGPCheckpointFile`（nlohmann JSON，原子替换写盘） |
| `api/GPContract.hh` | `GPRunMode::kResume`、`GPRunRequest::checkpoint_path`、`GPRunResult::checkpoint_path` |
| `api/PLAPI.cc` | `gpRunResume`（拓扑指纹校验 + 事务 + 恢复 + advance）；批次边界自动保存 checkpoint（checkpoint-per-call） |
| `ipl_io` + `tcl_ipl` | `placer_run_gp -mode resume -checkpoint <path>` |

### 12.2 关键设计决策

- **持久化清单**：坐标（current/next/SLP，int32）、梯度（current/next，float）、步长/parameter、惩罚系数（density_penalty、quad_penalty_coeff、wirelength_coef）、记录/历史列表、best/cur 快照、逐实例 density 坐标 + scale、`max_phi_coef`（唯一运行时变异的配置项）、拓扑指纹（placable 实例名有序列表）。
- **确定性重建，不落盘**：梯度 sum（每轮 `updatePenaltyGradient` 开头重算）、`_base_wirelength_coef`（`initBaseWirelengthCoef()` 重建）、WA 线长模型/密度势场（每轮全量重建）、拓扑节点位置（恢复后第一轮 backtrack 内 `updateTopologyManager` 自愈）。
- **浮点保真**：float→double→JSON 文本→double→float 往返精确（double 精确表示每个 float，JSON 文本往返无损失），等价测试以逐位比较验证。
- **调试中发现并修复的隐藏状态**：`Grid::fixed_area` 由 `initGridFixedArea()` 在 start 路径一次性写入、`clearAllOccupiedArea()` 不清它，而 `obtainGridOverflowArea()`/`obtainGridDensity()` 都依赖它。恢复路径缺它导致溢出偏小、密度梯度漂移（坐标一致但数值路径分叉）。restore 中已补 `initGridFixedArea()`。

### 12.3 验收结果（gcd_sky130_a，num_threads=1，位级比对）

| 场景 | 结果 |
|---|---|
| 跨进程恢复：`ckpt_save`（start 20 + 自动落盘）→ 新进程 `ckpt_resume`（resume 20） | **coords.txt 与 records.txt（iter 21-40）对 seg40 逐位一致** |
| 进程内销毁恢复：start 20 → close → resume 20 | 同上逐位一致 |
| 恢复保真（加载→恢复→立即重捕获） | JSON 逐字段 0 差异 |
| Tcl 跨进程冒烟：进程1 `-mode start -iterations 20` → 进程2 `-mode resume -checkpoint ... -iterations 20` | Iter 21-40 连续，数值与基线一致 |
| 校验：resume 缺路径 / 文件不存在 / 会话占用 | 全部 `kRejected`，求解状态不动 |
| M1 全部场景 + `ipl_run_gp_result_test`（1276 PASS） | 无回归 |

## 13. 使用方式（M1+M2）

```tcl
init_pl -config <pl_default_config.json>          # 与 run_placer 相同的初始化
placer_run_gp -mode start   -iterations 20        # 建会话 + 随机初始 + 20 次迭代；批次末自动存 checkpoint
placer_run_gp -mode advance -iterations 20        # 同一会话继续（不重新随机初始化）
placer_run_gp -mode resume  -checkpoint <file> -iterations 20   # 从 checkpoint 恢复（可跨进程）
placer_run_gp -mode start   -iterations 5 -random_init 0        # 保留当前坐标重建会话
placer_run_gp -mode close                         # 丢弃会话（回滚未提交事务）
placer_run_gp                                      # 无参数：遗留完整运行，行为不变
```

自动保存路径：`<output_dir>/pl/gp_session_checkpoint.json`（原子替换；每次预算批次后更新）。Checkpoint 内带 placable 实例名指纹，设计不匹配时拒绝恢复。72b 的 sessions/ lineage 目录布局与 seed 管线仍为后续项（见 §14）。

C++ API：`iPLAPIInst.gpRun(GPRunRequest{mode, accepted_iterations, random_init, checkpoint_path})` → `GPRunResult`（stop_reason / 迭代区间 / 本批次 records / metrics / checkpoint_path）。

## 14. 剩余工作（M3 及以后）

- 本机测试输入依赖 `benchmarks/results/flow_20260814_gcd/.../iFP_result.def`（生成产物）；建议把 `gcd_place.def` 测试夹具固化进 `benchmarks/designs/gcd_sky130_a/`。
- M3：`relinearize`（外部坐标修改后的重建）；依赖 DesignRevision 语义，与 70 号文档阶段一同步。
- M4：局部 GP（Active/Halo/Context）。
- 72b CLI 的 sessions/ lineage 目录布局、`--seed` 管线、原子 `latest.json` 别名。

## 15. 完整性补强（2026-08-14 第二轮：缺口 1+2）

针对自审出的 resume 缺口补强，全部通过验收：

### 15.1 配置指纹

- checkpoint 新增 `config_fingerprint`：NesterovPlaceConfig 全部数值路径相关字段的规范化 JSON（max_phi_coef 除外——它是会话态，单独持久化）。
- `restoreCheckpoint` 在**触碰任何求解状态之前**校验指纹，不匹配直接拒绝。
- 测试 `mismatch`：修改版配置（target_overflow 0.1→0.15）resume 标准配置的 checkpoint → `kRejected`，reason 含 "fingerprint"，无残留会话。

### 15.2 可变状态持久化补全

- 新增 per-net `weight` + `delta_weight`（_nNet_list 顺序），恢复时逐网写回。
- **拥塞模式**：`gp_congestion_config.json`（is_congestion_effort=1）下 `seg40_cg` ≡ `ckpt_save_cg + ckpt_resume_cg` **逐位一致**（含 evalRouteCap/密度膨胀路径）。
- **timing/max-wirelength 权重**：`opt_overflow_list` 无 JSON 配置键（仅 C++ `add_opt_target_overflow` 可达）→ 经配置可达的路径中权重恒为 1.0；net 权重持久化已覆盖该可变状态，但 timing 开启时的数值等价在列表可配置前**无法端到端验证**（如实记录，未声称已验证）。

### 15.3 多线程容差回归（超出预期：逐位一致）

- `gp_multithread_config.json`（num_threads=4）：`seg40_mt` 重复运行**逐位一致**（固定线程数下 OpenMP 归约确定性）；`seg40_mt` ≡ `ckpt_save_mt + ckpt_resume_mt` **逐位一致**。
- 结论比 72 号文档 §12 预期的"固定线程数容差回归"更强：本设计+固定线程数下可直接逐位判定。

### 15.4 两条终止路径测试（72 号文档 M1 验收项）

| 场景 | 构造 | 断言结果 |
|---|---|---|
| `conv_mid`（批次内自然收敛） | start(20) + advance(1980)，收敛发生在批次中段 | `stop_reason=kTargetReached`、`executed < requested`、会话终结、最终坐标与 legacy 收敛布局**逐位一致** |
| `diverge`（发散/非法度量不杀进程） | `min_phi=1e38/max_phi=3e38` → 密度惩罚第 3 次迭代溢出 | `ok=false`、`stop_reason=kInvalidMetric`（reason "iteration density penalty must be finite…"）、无残留会话、同配置重跑结果可复现、随后 advance 被干净拒绝（Worker 存活） |

### 15.5 测试矩阵现状

`ipl_gp_session_test` 19 场景全部 PASS；`ipl_run_gp_result_test` 1276 PASS 无回归。测试配置位于 `src/operation/iPL/test/configs/`（gp_congestion / gp_divergence / gp_modified / gp_multithread）。
