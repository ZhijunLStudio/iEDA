# 72d GP 会话化工具交接文档（供后续专家接手）

- 日期：2026-08-15
- 分支：`feat/parity-gp-session`（已推送 `ZhijunLStudio/iEDA`，7 个提交：c5cee7e → aadc0a0 → 494cee7 → c6ad6a4 → b3e7680 → 32be005 → 803584c）
- 关联文档：`70-agent-native-ieda-system-design-final.md`（系统设计）、`72-gp-tool-first-stage-implementation-plan.md`（M1-M5 计划）、`72b-gp-cli-protocol.md`（CLI 协议）、`72c-gp-m1-implementation.md`（实现细节与全部实验数据）
- 本文件用途：**给下一位专家完整交接**——完成了什么、没完成什么、效果不好的地方、Agent 如何调用 GP 的预设计。

---

## 1. 目标与一句话现状

把 iEDA 的全局布局器（iPL Nesterov GP）从"一次跑到底的内部流程"改造成 **Agent 可调度的会话式工具**：可分段、可暂停、可恢复、可限定范围、可调参数。

**现状**：核心会话机制（M1/M2/M3）全部完成且经过位级等价验证；局部 GP（M4）机制完成但**实验裁决为不稳健、未作为默认功能暴露**；输入参数（seed、target_density）已做成 Agent 接口。整体判断：**工具化地基可信，Agent 决策层和规模化配套尚未开始。**

---

## 2. 已完成（带验证证据）

### 2.1 会话机制（M1）

- `placer_run_gp -mode {start|advance|resume|relinearize|close}`；无参数 = 遗留完整运行，行为不变。
- 迭代预算语义：`-iterations N` = N 次**已接受迭代**（内部回溯不计费）；暂停只发生在完整迭代边界。
- **验证（全部位级比对，gcd_sky130_a，单线程）**：
  - `start(10)+advance(10)` ≡ `start(20)`：坐标+逐迭代记录逐位一致；
  - 观察无干扰：批次间读指标/已发布布局不改变后续数值路径；
  - 遗留 `runGPResult()` ≡ 会话完整运行：逐位一致、零回归（1276 项回归测试）。

### 2.2 Checkpoint 持久化与恢复（M2）

- 每个预算批次结束自动保存 `<output>/pl/gp_session_checkpoint.json`（原子替换）；`-mode resume -checkpoint <file>` 跨进程恢复。
- Checkpoint 内容：求解器全量状态（坐标/梯度/步长/动量）、会话标量、逐实例密度坐标与 scale、net 权重、迭代记录、**配置指纹**、实例名拓扑指纹。
- **验证**：`40 ≡ 20+销毁会话+跨进程resume 20` 逐位一致；恢复保真（加载→恢复→重捕获）0 差异；拥塞模式（is_congestion_effort=1）同样逐位一致；num_threads=4 下运行间与恢复都逐位一致（比计划中的"容差回归"更强）；批次内自然收敛（kTargetReached）与发散（kInvalidMetric，进程存活、可复现）两条终止路径有测试。

### 2.3 失效与重建（M3）

- 会话记录 PlacerDB revision；外部工具（LG/DP）提交事务使 revision 变化 → `advance` 被拒绝（reason 提示 relinearize）。
- `-mode relinearize` = `start -random_init 0` 的别名：保留外部改过的坐标、重建全部求解状态；start 遇到**已失效**会话自动丢弃（GP→LG→GP 流程无需显式 close）。
- **验证**：start(10) → runLG → advance 被拒 → relinearize 从第 1 次迭代重启且坐标保留（Iter1 overflow 与全新随机起点不同）；Tcl 冒烟跑通完整流程。

### 2.4 局部 GP（M4）——机制完成，策略被实验否决

- 机制：每个可移动实例一个**移动系数**（1=Active 正常动；0~1=Halo 缩放；0=Context 冻结）。梯度域乘系数 + 坐标域冻结（防 Nesterov 动量拖拽 Context）。空列表 = 全局路径逐位不变。
- 范围构造器：`buildHotOverflowScope`（最热溢出 bin → Active + net 一跳 Halo）、`buildRandomScope`（同规模随机对照）、密度屏 `buildHotOverflowDensityTargets`（per-grid `density_target`，软引导不冻结）。
- **不变量已验证**：全 1 系数 ≡ 全局逐位一致；Context 实例 20 次迭代后坐标逐位不变。
- **实验裁决（3 PDK × 8 设计 × 多检查点）**：见 §3。

### 2.5 Agent 输入参数

- `-seed N`：随机初始布局种子（默认 1000，同 seed 复现、异 seed 分歧，已验证）。
- `-target_density N`：密度目标**请求**（见 §4 的钳制语义；显式 0.8 ≡ 配置默认逐位一致已验证）。

### 2.6 测试与数据基建

- `build/bin/ipl_gp_session_test --scenario <name>`，**31 个场景**全部 PASS；每场景独立进程，产物（真实坐标/记录/scope 统计）在 `/tmp/ipl_gp_session_test/<scenario>/`。
- 坐标 dump 读 iPL PlacerDB 层（idb 层在流程结束前不同步，读 idb 是空转的——这是个坑，见 §4）。
- `test/configs/def2placement_1000.py`：把 2000-units 的 Innovus DEF 转成 iEDA 可用的 1000-units 布局 DEF（strip 掉布线几何，T28 的电源网格不 strip 会让 iDB 单线程解析卡 10 分钟以上）。
- 测试配置：`test/configs/gp_{congestion,divergence,modified,multithread}_config.json`。
- 数据源（本机）：
  - `/tmp/pl_vis_1000/`（s1238 829 / apb4_timer 3.5k / picorv32 29k / aes 64k，sky130 HD，源：`~/work/pl_vis/cases/`）；
  - `/mnt/usb20t/PCL-155/home/huangzhipeng/ysyx_t28/`（asic_top 321k，TSMC 28nm，tlef+全部 VT 单元库在 `T28_lib/`）；
  - `/mnt/usb20t/PCL-155/home/chenshijian/test/superblue16/`（981k 单元、238 宏，45nm，lef/def 自含且 units 一致）。

---

## 3. 未完成 / 效果不好的（诚实清单）

### 3.1 局部 GP：不稳健，不做默认策略

| 实验（同 checkpoint 分叉，各 20 轮） | 结论 |
|---|---|
| 热点 bin 定位 vs 同规模随机 | **≈ 等价**（所有设计/阶段/PDK）→ 图定位不产生价值 |
| 冻结式局部 vs 全局 | 符号随设计/阶段翻转：后期+大设计有收益（picorv32@300 的 -5.1%、asic_top321k@60 的 -3.3% hpwl），早期铺开期变差（superblue16@30 的 +5.8%） |
| 密度屏（热点 bin 容量打折） | **被否决**：≥11k 单元设计上 hpwl 代价 +22%~+28% |

**结论**：局部 GP 的正确用法是"checkpoint 分叉的候选动作 + 与全局对照验收"，不是可信的默认模式。范围选择用随机/用户指定/廉价启发式即可，**不要投资热点图算法**。

### 3.2 规模化短板（大设计会先死的地方）

- `applyNetHaloClosure` 用 `std::map<int32_t, vector<int32_t>>` 做 net 闭包：10M 单元规模 = GB 级内存 + 分钟级耗时。**应改为排序数组双指针或空间膨胀。**
- `buildHotOverflowScope/...Targets` 对全部溢出 bin 全排序：应改 `nth_element` top-k。
- checkpoint 是 JSON 文本：10M 单元 ≈ 1GB 文本，dump/parse 分钟级。**应二进制化（或至少 float 数组直存）。**
- `BinGrid::_bin_inst_list` 在 init 时建立、求解中不更新——用它的任何代码都会拿到陈旧映射（潜在 bug 源）。
- 多线程只验到 4 线程；生产线程数的容差回归未做。

### 3.3 明确未验证 / 未完成

- **timing 开启时的数值等价**：`opt_overflow_list` 无 JSON 配置键（仅 C++ `add_opt_target_overflow` 可达），timing/max-wirelength 权重更新路径经配置不可达，net 权重持久化已覆盖但端到端等价无法验证。**若要支持 timing 模式，先把 opt_overflow_list 接进 Configurator。**
- relinearize 只验了单次 runLG 场景；CTS（拓扑变化）后的行为、连续多轮 GP→LG→GP 未压测。
- L3 试验循环只是实验 harness，**没有生产级 accept/reject API 和 ExperimentRecord 记录**。
- 72b 的 sessions/ lineage 目录布局、checkpoint schema_version、entropyInjection 的 seed 管线（仍硬编码 1000）未做。
- M4 的"fixed-集合"实现（复用宏/fixed 路径，把范围外实例当固定障碍物，比 per-cell 掩码数值更干净）只讨论未实现。

---

## 4. 已知陷阱（代码级，接手必读）

1. **`Grid::fixed_area` 只初始化一次**：`initGridFixedArea()` 在 start 时写入，`clearAllOccupiedArea()` 不清它；resume 路径必须重建（已在 `restoreCheckpoint` 中修复）。漏它会表现为"坐标一致但数值路径分叉"。
2. **成员默认值缺失 = 未初始化垃圾**：`Grid::density_target` 曾因无 in-class 初始化，`vector::resize` 默认构造产生垃圾值导致运行间不确定。**任何新增 POD 成员必须带默认值，且 move 构造/赋值要拷贝。**
3. **`adaptTargetDensity()` 钳制**：目标密度是"请求"，低于设计物理利用率会被钳到 `利用率+0.001`（利用率<0.65 钳 0.60）。任何 target_density 覆盖必须走这条钳制路径，否则显式值与配置默认值不等价（退化等价测试会抓住）。
4. **writeBackPlacerDB 只写 iPL 层**：idb 层坐标在流程结束前不同步。测试/观测要读 `PlacerDBInst.get_design()` 的坐标，读 idb 得到的是初始 DEF 坐标。
5. **DEF/LEF units 不匹配**：iDB 只警告不换算（`def_read.cpp` 的 "DBU dismatch"），2000-units DEF + 1000-units LEF 会静默产生几何错误（单元半尺寸、filler 爆炸）。必须用转换器或保证 units 一致。
6. **迭代预算**：`accepted_iterations` 只计已接受迭代；`advanceAcceptedIterations` 的循环上界 = `min(max_iter, current+budget)`；提前收敛时 `executed < requested` 且 `stop_reason=kTargetReached`。
7. **发散不杀进程**：发散/非法度量走结构化返回（`ok=false` + `kDiverged/kInvalidMetric`），不留会话；测试配置 `gp_divergence_config.json`（min_phi=1e38/max_phi=3e38）可复现。
8. **批次记录切片**：`GPRunResult.iteration_records` 只含本批次；会话内部记录累计，切片靠 `record_offset`（resume 时从 checkpoint 记录数续切）。

---

## 5. Agent 如何调用 GP（预设计，供下一位实现决策层）

### 5.1 现有工具面（已实现，可直接用）

Tcl（Claude Code/脚本经 `bin/iEDA -script` 调用）：

```tcl
init_pl -config <pl_default_config.json>            # 与 run_placer 相同的初始化
placer_run_gp -mode start -iterations 20 -seed 42 -target_density 0.9
placer_run_gp -mode advance -iterations 20          # 同一会话继续
placer_run_gp -mode resume -checkpoint <file> -iterations 20
placer_run_gp -mode relinearize -iterations 20      # 外部改过坐标后重建
placer_run_gp -mode close
```

C++（PLAPI）：

```cpp
struct GPRunRequest {
  GPRunMode mode;                 // kStart | kAdvance | kResume
  int32_t accepted_iterations;    // 预算
  bool random_init;               // kStart：随机初始 vs 保留坐标
  int32_t seed;                   // 随机种子
  float target_density;           // -1 = 配置值（请求语义，见陷阱 3）
  std::string checkpoint_path;    // kResume
};
// 返回 GPRunResult：ok / session_active / stop_reason / 迭代区间 /
// hpwl / overflow / step_length / density_penalty / 本批次记录 / checkpoint_path
```

### 5.2 Agent 决策循环（推荐模式）

基于实验证据的候选-对照-验收模式，每一步都从 checkpoint 分叉：

```text
1. state：读 GPRunResult（stop_reason、overflow、hpwl、executed_iterations）+ checkpoint 路径
2. 判断阶段：overflow >> target（铺开期）/ 接近 target（收敛期）
3. 分叉候选（按 §5.3 优先级），每个候选 = resume/start 后跑固定预算（如 20）
4. 同预算、同起点、全芯片指标比较（hpwl/overflow，需要时可加下游 LG/DP/STA 评价）
5. 只接受严格更优者，否则回退（丢弃候选会话，保留父 checkpoint）
```

**验收硬规则**：①必须与"同 checkpoint 的全局 advance"对照；②不同阶段/不同预算的候选不可比；③全芯片指标，不看局部改善；④发散/失败候选只消耗预算，不污染父状态。

### 5.3 Agent 动作优先级（由实验证据排序）

| 优先级 | 动作 | 依据 | 适用阶段 |
|---|---|---|---|
| P0 | 全局 `advance`（基线） | 全局模式永远可信 | 任意 |
| P1 | `target_density` 上调（更密换线长） | 已验证：gcd 上 0.9 vs 0.8145 → hpwl -1.3%、overflow 更低；钳制保证可行域 | 收敛期（想压线长时） |
| P1 | `seed` 变化重开探索 | 同 seed 复现、异 seed 分歧，已验证 | 卡平台期时 |
| P2 | 冻结式局部（范围=随机或用户指定，**不必用热点图**） | 后期+大设计有 -2%~-5% 收益，但符号不稳定 → 必须对照验收 | 仅收敛期；铺开期禁用 |
| ✗ | 密度屏 | 被否决（大设计 hpwl +22~28%） | 不用 |
| ✗ | 热点图精确定位 | hot≈random，不产生价值 | 不投资 |

### 5.4 配置项分级（Agent 可调 vs 禁止）

| 分级 | 项 | 说明 |
|---|---|---|
| ✅ 可调 | `target_density` | 有效区间 [利用率,1.0)（利用率<0.65 时 [0.60,1.0)）；更松必须去改 iFP 核心区 |
| ✅ 可调 | `seed` | 探索多样性 |
| ✅ 可调 | `accepted_iterations` | 预算（20/40/…） |
| ⚠️ 谨慎 | `init_density_penalty` | 过大触发发散/回滚；有 clamp 与发散检测兜底 |
| ⚠️ 谨慎 | `max_phi_coef/min_phi_coef` | 发散测试配置证明它可被利用；正常范围 0.95~1.05 |
| ✗ 禁止中途改 | 所有求解参数 | 会话内改任何配置 = 数值路径污染；只能 start 新会话 |
| ✗ 禁止暴露 | 单次梯度/回溯/步长 | 迭代是原子边界（设计原则） |

### 5.5 观测面缺口（建议下一位补）

- 现有：GPRunResult 的标量指标 + 逐迭代记录。**缺 bin 级溢出分布导出**（Agent 判断热点/选择范围的最直接素材，`GridManager` 数据现成）。
- 缺：实验账本（父 checkpoint、动作、预算、结果、取舍的持久记录，对应 70 号文档的 ExperimentRecord）。
- 缺：生产级 accept/reject API（§5.2 的模式目前只在测试 harness 里）。

### 5.6 给下一位的优先级排序

1. **P0 规模化**：范围构建重写（排序数组/nth_element/空间膨胀）+ checkpoint 二进制化。否则大设计跑不了（§3.2）。
2. **P0 观测**：bin 溢出分布导出 + 实验账本。Agent 没有这两个等于盲调。
3. **P1 timing 模式**：opt_overflow_list 接进 Configurator → 补 timing 开启的 resume 等价验证。
4. **P1 更大规模验证**：找 1M+ 的布局 DEF（superblue16 已 981k），重跑 hot-vs-random 消融——不要外推小设计结论。
5. **P2 多线程容差回归**、**P2 72b 的 sessions/ 目录与 schema_version**。
6. **明确不做**：热点图定位算法、per-cell API 暴露、密度屏默认、代理模型训练。

---

## 6. 复现与验证命令

```bash
cd /home/lizhijun/work/iEDA.ai
cmake --build build --target ipl_gp_session_test ipl_run_gp_result_test iEDA -j$(nproc)
cp build/bin/iEDA bin/iEDA

# 全量等价性回归（31 场景，产物在 /tmp/ipl_gp_session_test/<scenario>/）
build/bin/ipl_gp_session_test --scenario <name>   # 列表见 test/CMakeLists.txt 的 add_test
build/bin/ipl_run_gp_result_test                  # 遗留回归（1276 PASS）

# 任意 PDK 大设计实验（参数化入口）
build/bin/ipl_gp_session_test --scenario local_scale \
  --case-dir <dir> --def-path <def> --tlef <tlef> \
  --lef <lef1,lef2,...> --config <pl.json> --start-iters 60
```

关键文件索引：`api/GPContract.hh`（请求/结果）、`api/PLAPI.cc`（会话状态机）、`global_placer/electrostatic_placer/NesterovPlace.{hh,cc}`（求解会话/checkpoint/局部机制）、`solver/nesterov/Nesterov.{hh,cc}`（状态捕获）、`grid_manager/GridManager.{hh,cc}`（Grid 容量/密度屏）、`test/GPSessionTest.cc`（31 场景）、`test/configs/`（测试配置与 DEF 转换器）。
