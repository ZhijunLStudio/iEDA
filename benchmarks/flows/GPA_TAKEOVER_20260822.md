# GPA 接管日志（2026-08-22，新会话接手 94e65722）

## 0. 接手背景

原会话 session-94e65722（GPA交接任务理解，36 turns / 804 steps）在 11:45:46
卡死于 `dev_reload_package("@ieda-ai/dsh-tool-ieda-gp")`：该调用与注入器文件
watcher 的自动重载同秒并发互踩（step 8 刚重建 lib 触发指纹变化），旧 fiber 被
dispose、新 fiber 未激活、结果事件永不到达，turn 永久 pending。用户决定弃用该
会话，由本会话接手继续。

## 1. 环境恢复（免重启）

- 卡死现场：ieda-gp `[disposed]`，super-injector `[failed]`，op 锁被永不
  resolve 的 promise 楔死（任何 dev_reload_package/dev_uninject_plugin 都会
  再挂——**禁用**）。
- 恢复手段：追加注释行 touch `~/.dsh/profiles/web/cordis.patch.yml`，include
  插件对账后重新装配 ieda-gp → `[active]`，5 个工具恢复可用。后续插件代码
  修改后同样用 patch-touch 重装配（watcher 已随 failed fiber 停止）。

## 2. 已提交的改动（feat/parity-gp-session → personal）

- ea467dc：`full` 的 baseline 回退 design `input_def`（无外部 GT 要求），
  Innovus 仅在 registry 提供时作第三路（接原会话被卡住未提交的修复）。
- d636275：
  - `observe kind=designs` 剥离 GT 标量列 `innovus_hpwl`/`ieda_best_hpwl`
    （迭代闭环不再能读到答案），路径字段保留。
  - `full` baseline 增加 existsSync 回退（gp_baseline_def 缺文件 → input_def，
    均无 → 明确报错）；innovus 路同样跳过缺失文件。

## 3. aes（sky130）攻坚实验记录

目标窗口（同 evaluator, rudy）：rudy_max < 1.682，rsum < 134.01，
HPWL < 914,210,691（raw 已 4/6：HPWL 665M / WNS / bins / freq 领先）。

| 实验 | 配方 | HPWL | rudy_max | bins | rsum |
|---|---|---|---|---|---|
| raw 基线 | p0_converged（td=0.8 收敛） | 665,002,127 | 2.023 | 540 | 186.63 |
| Innovus 参考 | — | 914,210,691 | 1.682 | 808 | 134.01 |
| gen-4 branch_a | td0.5 effort4 bin64 200it | 556.9M | 7.064 | 546 | 644.7 |
| gen-4 branch_b | td0.5 effort4 bin64 | 398.0M | 12.493 | 300 | 642.1 |
| gen-4 branch_c | td0.6 to0.1 | 647.0M | 2.702 | 542 | 192.7 |
| E1 | raw 起步 effort3 to0.10 397it | 655.7M | 5.284 | 546 | 215.7 |
| E2 | raw 起步 effort2 to0.10 419it | 651.9M | 7.513 | 583 | 241.7 |
| E3 | td0.95 to0.15 effort0 400it | 541.7M | 3.300 | 545 | 275.7 |
| E4/lc3 | **1 迭代即停（solver 内部 init）** | **101.6M** | **1.195** | **8** | **0.97** |

### 关键发现

1. `start` 的 input DEF 坐标**不参与初始布局**：random_init=0 时求解器仍会
   重新 linearize（barycenter init）。input DEF 坐标只通过
   `seed_anchor_strength>0` 的锚点混合参与，且锚点在 init 之后/早期迭代几乎
   无效果（1 迭代时 s=0 与 s=0.5 结果相同）。→ "从 raw DEF 起步"必须
   seed_anchor_strength>0 才成立，早期配方语义需要修正。
2. **求解器内部 init 布局（1 迭代）本身就是 aes 全维度最优**：HPWL 101.6M、
   RUDY 1.195/8/0.97、peak density 0.2277——但它是未收敛状态（密度 0.23，
   LG/DP 后会变），不能直接作为交付。
3. 任何收敛步骤（WL+density 目标）都会让 RUDY 峰值恶化 2-7×：密度装箱与
   WL 聚类在 aes 上把 init 的均匀需求压成热点。effort 1/2/3、td 0.5-0.95、
   to 0.10-0.15 的组合都没能守住 init 的拥塞优势。
4. 局部疏散（local_congestion region/net-cone）在 aes 上发散
   （overflow 0.145→2.9-3.5），net-cone 模式取到的 net 每 net 仅 1 个
   instance，工具在该设计上不可用。

### 待验证方向（下一轮）

- A. 锚定收敛：seed_anchor_strength 取 0.5-0.8 从 init 出发长跑，看能否在
  密度收敛到可用水平的同时保住 RUDY<1.68（锚点捕获时机见
  NesterovPlace.cc:1910）。
- B. init + LG/DP 直接成型：对 init 布局跑 LG（max_displacement 放宽），
  测合法化后的真实 HPWL/RUDY/WNS——若成立，比硬收敛便宜得多。
- C. 求解器层（dead session 定稿的下一 frontier）：NesterovPlace.cc:1632
  congestion-aware 分支，RUDY 力没有针对峰值 bin 的有效惩罚（plain rudy
  只压平均、LUT 峰值惩罚在 aes 上反向恶化），需要 density-congestion 联合
  目标重构。

## 4. 其他设计现状（来自 94e65722 定稿）

- nangate45_gcd / ihp130_gcd / picorv32：6/6 全胜 Innovus ✅
- s1238：5/6（rudy +1%、rsum +7%）
- asap7_aes：4/5（rudy +9%）
- apb4_timer：4/6（拥塞差 2%/24%）
- aes：本日志攻坚中

## 5. 2026-08-24 第二轮：按用户方向重构为「会话自主 + 事后对比」闭环

### 工具面（GT 彻底摘除）
- 8afad0f：observe designs 剥离 innovus_def 路径 + GT 种子 alt_input_defs
  （含 nangate/asap7/ihp130 的 innovus_die 起点），agent 只看到 iEDA 自历史
  gp_baseline_def；full 不再含 innovus 第三路，Innovus 对比只在会话结束后
  由我离线跑。verify 描述里的 innovus 示例改为 neutral extra。
- d21d81a：local_congestion 疏散默认参数放宽（density-target 0.5→0.8、
  halo 1→2 hop）；congestion_nets 选择弃 1-instance 纯 IO pin net，并给
  多实例 net 加权（score × (0.5+0.5·min(1,ic/8))）。依据：aes 上 net-cone
  模式取到 write_data/read_data 每 net 仅 1 个实例导致疏散发散。

### /tmp 清理后的 registry 修复（5a2efa5 + 042e487）
- sky130 四设计 gp_baseline_def 指向仓库内 ieda_gp.def；但该 DEF 是整流程
  产物含 filler（aes 4250 个 fill_1），timing eval 无 filler liberty 导致
  rc=-6（apb4 会话首轮即中招）。修复：生成剥离 filler 的
  ieda_gp_nofill.def（results 目录 gitignore，落盘保存），registry 改指
  nofill 版本；同 evaluator 复验 aes：665.2M / 2.164 / 536 / 180.58。
- nangate45/asap7 的 /tmp case 与 /mnt 外挂盘不可用，暂退出本轮战役。

### 长程会话（headless，GT-free prompt）
- DSH_HOME=/tmp/dsh-headless-gp 重建：profile headless bundles
  [dsh-base, dsh-headless, ieda-gp]，cordis.patch 禁用 bash/fs/web/subagent/
  goal 等全部非 GP 工具，agent 只持 5 个点工具；凭证走 .env 复制。
- 启动 3 场并行会话（nohup，pid 见 /tmp/hl_runs/run_*.log）：
  s1238（/tmp/agent_s1238）、apb4_timer（/tmp/agent_apb4，首轮因 timing
  filler 问题失败已重启）、aes（/tmp/agent_aes）。
- 会话提示词只给目标指标名，不含任何 GT 数值/路径；停止条件由 agent 自判。
- 会话结束后：读 session.jsonl.zstd 轨迹 → 取最终 placement.def → 我离线
  用同 evaluator 对 ieda_gp_nofill.def（baseline）+ innovus_placed.def
  （GT）做全维度对比（含 timing），按差距定位工具/求解器问题再迭代。

## 6. 求解器层突破：congestion_effort=5 联合密度-拥塞目标（3c2673a）

按 4.11 的定稿方向实现了「密度-拥塞联合目标重构」的第一版：不再给 WL 力加
拥塞惩罚（4.11 证明 in-loop 拥塞力破坏密度收敛），而是让拥塞影响**密度容量**——
每 5 个迭代把热 RUDY grid 的 density screen 调低最多 15%（floor 0.6），冷 grid
缓慢回 1.0，只在全局（无 scope）迭代生效；密度惩罚本身承载扩散力。

s1238 结果（seed=1000 确定性复现，GT-free：无 Innovus 种子/分数）：

| placement | HPWL | rudy_max | bins | rsum |
|---|---|---|---|---|
| 基线 ieda_gp_nofill | 5,982,950 | 2.560 | 611 | 220.02 |
| effort5 400it（to=0.10, bin64） | 6,467,975 | **2.029** | 649 | 166.22 |
| Innovus（事后参考） | 8,053,041 | 2.035 | 622 | 133.02 |
| 旧工具可达最优（Innovus-anchor） | 7,533,348 | 2.056 | 616 | 142.06 |

- rudy_max 首次**无 GT 低于 Innovus**（2.029 < 2.035），并低于旧 Innovus-
  anchor 吸引子（2.056）；HPWL 仍优于 Innovus 21%。rsum 166 仍高于 Innovus
  133，下一轮方向：rsum 需要更强的全局扩散（幅度/floor 扫描）+ 更长迭代。
- 调参证据：cut 0.25/floor 0.55/每 2 迭代 → 2.560/174.3（劣化）；
  cut 0.15/floor 0.6/每 5 迭代 → 2.029/166.2（当前最优，已固化）。
- aes 同配方：658.7M / 3.024 / 568 / 198.0（HPWL 微升、拥塞劣化）——大 bin
  设计需要不同参数或 bin_cnt 对齐（内部 grid 128 自适应 vs RUDY 64）。
- 已同步工具描述（effort 2-5 语义），headless 下一波会话即可使用 effort5。

## 7. 第一场自停会话的事后验证：apb4_timer 6/6 全维度超过 Innovus

apb4 headless 会话（GT-free 提示词、无任何 Innovus 数据）自主迭代 40+ 步后
自判收敛并给出最终报告（session-2eae302e，最终 placement.def 已归档
benchmarks/flows/gp_wins/staging/apb4_timer_final_gtfree.def）。
事后同 evaluator 验证（timing=1，congestion_model=rudy）：

| apb4_timer | HPWL | rudy_max | bins | rsum | WNS ns | freq MHz |
|---|---|---|---|---|---|---|
| baseline ieda_gp_nofill | 15,689,143 | 1.513 | 71 | 11.51 | -0.572 | 482.7 |
| agent 最终 | **15,422,494** | **1.321** | **48** | **5.70** | -0.594 | 477.5 |
| Innovus | 18,566,747 | 1.398 | 63 | 7.46 | -0.678 | 459.2 |

**6/6 全维度超过 Innovus**（WNS -0.594 > -0.678），成为第 4 个全胜设计
（前 3：nangate45_gcd / ihp130_gcd / picorv32）。且本场会话完全 GT-free：
agent 自建基线、自找 effort3→4 扩散配方、自判「历史最好 HPWL 来自未扩散
密集态不算数」并主动放弃，最终停在不可支配平衡点。

会话期工具问题（已修）：timing=1 的 GP 内时序模式因 SDC 文件名错配失败
（52e9e32 修复），agent 自行绕过（非时序 GP + 独立 iSTA 评估）。

备注：headless 进程在 turn/end 后不退出（僵尸挂起，需 kill），疑似 harness
关机路径问题，待查；s1238 第一波进程曾在调用中途无痕退出（原因待查，
已重启第三波）。

## 8. 会话运维：看门狗 + 事故记录

- 为长程会话加了 /tmp/hl_watchdog.py（setsid 常驻）：检测每设计的 dsh
  进程与会话文件；turn/end 后进程僵尸 → kill；中途死亡（无 turn/end）→
  自动重启（每设计上限 3 次）；自收敛 → 只记录 CONCLUDED 待我验证。
- 事故：v1 看门狗把「会话首行含提示词」误写成「首行匹配」（session 首行
  是 header），导致每 60s 对每个设计重复拉起会话（3 批 × 4 设计）；已杀
  净重复进程并修正（全文匹配 + 无运行进程才拉起 + 任一历史会话 turn/end
  即视为已收敛不再拉起）。
- 当前在跑：aes（942936）、s1238 第三波（1283615）、ihp130_gcd（1314394，
  registry 已修好 pl_default_config + iFP 输入，GT-free 提示词）。apb4 已
  收敛并验证完成，退出战役。

## 9. ihp130 基线修正 + 验证表预置

- iFP_result.def 是未布局输入（HPWL 0、RUDY 215），不能当基线；改指
  仓库内真实 iPL 布局结果 result/iPL_result.def（无 filler，timing 可用）。
- 预置事后验证基线（同 evaluator, timing=1）：
  iPL_result: 638.7M / 2.637 / 1810 / 836.1 / WNS +0.630 / 228.8MHz；
  Innovus:    502.8M / 2.171 / 1099 / 245.3 / WNS -1.024 / 166.0MHz。
- ihp130 会话初期的 full/start 失败经复测确认为看门狗重复进程竞写所致
  （干净 workdir 上 timing=1 + bin64 full 全部通过），非环境缺陷；agent
  会自愈，未干预。
