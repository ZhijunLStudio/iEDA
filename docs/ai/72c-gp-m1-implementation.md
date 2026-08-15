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

`ipl_gp_session_test` 27 场景全部 PASS（截至第三轮）；`ipl_run_gp_result_test` 1276 PASS 无回归。测试配置位于 `src/operation/iPL/test/configs/`（gp_congestion / gp_divergence / gp_modified / gp_multithread）。

## 16. M3：会话失效与 relinearize（2026-08-14 第三轮）

- **失效检测（最小实现）**：会话记录 `base_revision`（PlacerDB revision，外部工具 LG/DP 提交自己的事务时 +1）；`advance` 时 revision 不一致 → 拒绝，reason 提示 "invalidated ... relinearize"。零额外状态机。
- **relinearize = 保留外部改过的坐标重建会话**：实现即 `start + random_init=false`（initNesterovPlace 从当前 PlacerDB 坐标重建梯度/步长/动量，天然无旧状态）；Tcl 提供 `-mode relinearize` 别名。start 遇到**已失效**会话时自动丢弃（GP→LG→GP 流程无需显式 close）；健康会话仍拒绝 start（防误覆盖）。
- **验证**：
  - `invalidate`：start(10) → runLG（真实外部工具，提交事务）→ advance 被拒（reason 含 "invalidated"）→ 不显式 close 直接 start(keep) 成功、从第 1 次迭代重启。
  - `relinearize`：完整序列两进程重跑，坐标/记录逐位一致（确定性）。
  - Tcl 冒烟：`placer_run_gp -mode start 10` → `placer_run_lg` → `placer_run_gp -mode relinearize 10`：iter 从 1 重启，Iter 1 overflow 0.893394（对比全新随机起点 0.896213，证明保留了合法化后的坐标）。

## 17. M4：局部 GP 的实验结论（重要：不支持默认采用）

**实现（最小内核，不变量已验证）**：
- 移动系数 `setMovementCoeffs`（placable 顺序：1=Active / (0,1)=Halo / 0=Context）；梯度预条件后乘系数 + 坐标域冻结（Context 钉在批次起点，逐位不变）；空列表 = 全局路径逐位不变。
- 范围构建：`buildHotOverflowScope`（最热溢出 bin → Active，net 一跳邻居 → Halo）+ `buildRandomScope`（同规模随机对照，固定种子）。

**不变量验证**：
- 退化等价：全 1 系数 ≡ 全局 GP，**逐位一致**。
- Context 零写入：29 个 Context 实例跑 20 次迭代后坐标**逐位不变**。

**对照实验（gcd_sky130_a，同一 checkpoint 分叉，各 20 次迭代）**：

| checkpoint | global | hot-0.2 | random(同规模) | 结论 |
|---|---|---|---|---|
| iter 20 | ov 0.7002 / hpwl 5.666M | ov 0.6942 / hpwl 5.617M | ov 0.6901 / hpwl 5.618M | 局部好，但**随机 ≈ 热点** |
| iter 60 | ov 0.6959 / hpwl 5.648M | ov 0.6966 / hpwl 5.650M | ov 0.6961 / hpwl 5.649M | 局部**略差** |

- 比例扫描（0.05/0.2/0.5）与第二个随机种子结果一致。
- **结论**：① 热点 bin 图选择不比同规模随机范围好 → "怎么找局部"的图工程在当前 GP 粒度上**不产生价值**；② 局部与全局的优劣随求解状态翻转 → 收益不稳健。按 70 号文档 §13.3 的证伪框架，"graph-scoped intervention 有效"假设**未被支持**。局部细化应放在离散阶段（LG/DP），GP 层面默认不做局部。
- **因此不对外暴露** `-scope local`；范围机制保留为已验证的实验工具（`buildHotOverflowScope`/`buildRandomScope` + 移动系数），供未来按设计重新评估。

## 21. Agent 输入：target_density 覆盖（2026-08-15 第六轮）

`GPRunRequest.target_density`（-1 = 用配置值；Tcl `placer_run_gp -target_density N`，start 模式）。

**语义（重要）**：Agent 给的是"请求"，不是硬设定——`PlacerDB::adaptTargetDensity()` 会把不可行的请求钳制到可行域：
- 请求 < 设计物理利用率 → 钳到 `利用率 + 0.001`（低于利用率的密度目标在数学上永远无法收敛）；
- 利用率 < 0.65 → 钳到 0.60。

验证（gcd，利用率 0.8135）：
- 显式 0.8 ≡ 配置默认 → **逐位一致**（退化等价，走同一钳制路径）；
- 0.7 与 0.8 都被钳到 0.814478 → 结果相同（0.6873 overflow）；
- 0.9 高于利用率 → 允许更密 → hpwl -1.3%、overflow 0.6730（更低）。

即 Agent 的实际有效旋钮区间是 **[利用率, 1.0)**（或 0.60 下限）；低于利用率的请求被钳制而非报错。有效值进 checkpoint 配置指纹，resume 自动校验。

## 20. 多 PDK 规模验证（2026-08-14 第五轮）

数据源：`/mnt/usb20t/PCL-155/`（本机没有 iDATA；有完整 T28 与 superblue16 用例）。大 DEF 用 `test/configs/def2placement_1000.py` 的 strip 模式去除布线段（T28 的 SPECIALNETS 电源网格在 iDB 解析时单线程 >10 分钟，strip 后 12 秒）。

| 设计(单元数, PDK) | global | hot-freeze | hot-screen | random-freeze |
|---|---|---|---|---|
| gcd 273 (sky130 HD) | 5.666M/0.700 | 5.617M/0.694 | 5.69M/0.71 | 5.618M/0.690 |
| s1238 829 / apb4_timer 3.5k / picorv32 29k / aes 64k (sky130 HD) | 见 §19 | 微好/持平 | 差(大设计 +22~28% hpwl) | ≈hot |
| **asic_top 321k (tsmc 28nm, iter60)** | 3405.8M/0.9625 | 3335.8M(-2.0%)/0.9625 | 3513.6M(+3.2%)/0.9829 | 3292.5M(-3.3%)/0.9661 |
| **superblue16 981k (45nm, iter30)** | 173.7G/0.8832 | 183.8G(+5.8%)/0.9200 | 174.1G/0.8888 | 182.4G(+5.0%)/0.9188 |

**跨 PDK 结论**：
1. **四种 GP 模式在三个 PDK（sky130/tsmc28/superblue45）上全部机械可用**：start/checkpoint 落盘/恢复/global/local 分支都正常跑通（"是否奏效"的答案：机制可用）。
2. **冻结式局部更新的收益在 28nm 321k 设计上复现**（-2%~-3.3% hpwl），但 981k superblue16 上为负——原因明确：iter30 时 89% 的单元都落在"最热 20% bin"里（整个芯片还在铺开期），"局部"退化成"冻结 10% 的全局"，自然劣于全局。**局部 GP 只在热点真正局部化的阶段有意义**（picorv32@300、t28@60），早期铺开期不该用。
3. hot ≈ random、screen 差，跨 PDK 一致。

## 19. L1 密度屏 + L4 多设计规模实验（2026-08-14 第四轮，实验裁决）

**L1 实现（density screen）**：`Grid::density_target`（默认 1.0，逐位不变）；`setRegionDensityTargets(regions, factor)` / `clearRegionDensityTargets()` / `buildHotOverflowDensityTargets(top_ratio, factor)`（最热溢出 bin 打屏）。有效容量 = available_ratio × density_target × grid_area，factor<1 让区域"感觉"过满、密度场把 cell 推出去——软引导，不冻结任何东西。退化等价已验证（全 1 屏 ≡ 全局逐位一致）。

**L4 数据**：本机 `~/work/pl_vis/cases/`（Innovus 2000-units DEF，已用 `test/configs/def2placement_1000.py` 转为 1000-units 布局 DEF）。小/中/大：s1238(829) / apb4_timer(3.5k) / picorv32(29k) / aes(64k 可移动)，均为 sky130 HD。

| 设计(检查点) | global | hot-freeze | hot-screen(0.05,0.3) | random-freeze |
|---|---|---|---|---|
| gcd(iter20) | 5.666M/0.700 | 5.617M/0.694 | 5.692-5.763M/0.706-0.717 | 5.618M/0.690 |
| s1238(iter60) | 2.974M/0.893 | 2.964M/0.894 | 2.976M/0.895 | 2.964M/0.894 |
| apb4_timer(iter60) | 8.571M/0.889 | 8.561M/0.889 | 8.586M/0.894 | 8.594M/0.890 |
| picorv32(iter60) | 96.8M/0.926 | 97.7M/0.922 | 124.4M/0.842 | 97.2M/0.924 |
| picorv32(iter300) | 184.0M/0.485 | 179.6M/0.490 | 232.9M/0.485 | 174.7M/0.512 |
| aes(iter60) | 172.0M/0.974 | 180.8M/0.977 | 209.4M/0.967 | 161.7M/0.979 |

**实验结论（5 设计 × 2 阶段，每分支 20 次迭代、同 checkpoint 分叉）**：
1. **热点 bin 定位 ≈ 同规模随机**（全部设计/阶段一致）——"怎么找局部"的图工程不产生价值，与 gcd 小实验结论一致并外推成立。
2. **密度屏作为定向热点干预被数据否决**：≥11k cell 的设计上 hpwl 代价 +22%~+28%，只在 picorv32(iter60) 换到 -9% 溢出；作为"溢出换线长"的杠杆可用性存疑，不作为默认局部机制。
3. **冻结式局部更新是唯一有真实收益的机制**：后期阶段大设计上 hpwl -2.4%~-6%（picorv32@300 的 random-freeze -5.1%、aes -6%），但符号随设计/阶段翻转、溢出有小幅代价。
4. **结论落点**：局部 GP 的正确形态是 L3 试验循环（checkpoint 分叉 → 候选 vs 全局对照 → 全芯片验收 → 只留胜者），而不是可信的默认模式；冻结机制 + 简单范围（随机/用户指定/廉价启发式均可）即可，不投资热点图算法。

## 18. --seed 管线（2026-08-14 第三轮收尾）

- `GPRunRequest.seed`（默认 1000，遗留路径行为不变）→ `RandomPlace::runRandomPlace(seed)`；Tcl `placer_run_gp -seed N`。
- 验证 `seed_vary`：同 seed 两次运行坐标逐位一致；seed 42 vs 43 布局不同（候选分支实验的前提）。

**测试基建修正（重要）**：早期 coords.txt 从 idb 层 dump，而 GP 的写回只到 iPL PlacerDB 层（idb 仅流程结束时同步）→ 早前的坐标比对是空转的（恒等于初始 DEF）。已改为 dump PlacerDB 真实坐标；修复后全部等价对（分段/观察/legacy/跨进程/多线程/退化等价）在**真实坐标**上重新验证仍逐位一致（records 一直是求解器真值，此前的数值验证不受影响）。
