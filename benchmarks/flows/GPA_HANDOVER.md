# iEDA GP Agent 点工具交接文档

- 日期：2026-08-21
- 分支：feat/parity-gp-session
- 推送目标：personal（不要推 origin）
- 插件包：@ieda-ai/dsh-tool-ieda-gp
- 核心结论：点工具已稳定，剩余差距主要是 GP 算法/流程 QoR 与 agent 编排，不是插件崩溃。

---

## 1. 项目目标

让 DeepSeek Harness 里的 agent 通过一组可组合的 GP 点工具，
对 iEDA Nesterov 全局布局做观察、提议、运行、验证，
在同 evaluator 下和 raw iEDA GP、Innovus 比较：

```text
HPWL / density / RUDY congestion / setup-hold timing
```

目标：

```text
找到多个 PDK、多个设计上全面超过 baseline 和 Innovus 的 placement。
```

---

## 2. 总体架构

```text
DeepSeek Harness（Web / headless）
  -> @ieda-ai/dsh-tool-ieda-gp（native JS plugin）
  -> Python adapter（参数/文件/进程）
  -> Tcl script
  -> C++ iEDA binary
  -> placement.def / checkpoint / metrics JSON
```

五个入口工具：

```text
ieda_gp_observe   只读观察
ieda_gp_propose   只提议，不改变状态
ieda_gp_run       执行 GP 动作
ieda_gp_verify    同 evaluator 验证
ieda_gp_session   会话管理
```

---

## 3. 工具能力清单

### ieda_gp_observe

```text
designs                注册的 design/PDK
status                 当前 checkpoint 状态 + effective_config
checkpoints            checkpoint 列表
grid                   密度网格
hotspots               密度热点
longnets               最长 HPWL net
unstable               两个 checkpoint 间移动最多的 cell
trajectory             append-only batch 历史
congestion_hotspots    RUDY/LUT-RUDY 拥塞热点 + congestion nets
timing_paths           timing 最差路径 + scope_instances
```

### ieda_gp_propose

```text
regions                可执行 region
region_density         区域密度建议
freeze                 要冻结的 cell
longnet_instances      长 net instance 集合
gp_config              config/budget 候选
```

### ieda_gp_run

```text
full                   一次完整 GP + 自动同 evaluator metrics
start                  从 DEF 开始
advance                从 checkpoint 继续
candidate              local vs global 同预算对照
local_run              局部动作并自动 accept
apply_freeze           冻结区域
apply_region_density   区域密度目标
local_restart          candidate -> accept -> fresh global -> baseline 对照
apply_anchor           未实现，明确返回 unsupported
```

### ieda_gp_verify

```text
delta                  checkpoint 差值
lg                     LG oracle
metrics                HPWL/density/RUDY/timing 多 DEF 同 evaluator
                       raw_def + candidate_def + extra_defs
                       extra_defs 格式：label=path;label2=path2
```

### ieda_gp_session

```text
restore
accept
unfreeze
clear_density
```

---

## 4. 已完成的工作

### 4.1 点工具

- 5 个入口，kind 枚举收敛。
- 同 evaluator：
  - HPWL：def_hpwl_eval.py
  - density：run_density_eval
  - congestion：RUDY + LUT-RUDY
  - timing：run_timing_eval HPWL RC
- one-shot `full`：
  设计名 + workdir + iterations 就能跑完整 GP，
  自动比较 raw / candidate / Innovus。
- local GP：
  region / instances / hotspot / random / longnet / global
  halo_coeff / halo_hops / scope_density_target /
  scope_anneal_ratio / congestion_effort 0-3。
- 运行历史自动归档：
  `<workdir>/archive/<timestamp>/`
  保存 placement.def / checkpoint / metrics / experiments。
- 缺失 design / region 自动从 trace 推断。
- record 返回 scope_effect：
  active/halo/context/context_moved/max_displacement。
- 所有错误都是结构化 JSON，无 traceback。

### 4.2 C++ / solver 关键修复

- checkpoint terminal iter off-by-one。
- restore 使用 cur_position_list 而不是旧的 density coords。
- terminal accept 幂等。
- accept 不再允许同时传 checkpoint（防止回滚 child）。
- 旧 checkpoint fingerprint 兼容（congestion_effort_level 默认 1）。
- congestion_effort=2/3 的 RUDY 峰值惩罚。
- iSTA LUT 越界插值 clamp，修复 asap7 ps 单位 bug。
- scope 移动 mask：active=1 / halo=0..1 / context=0，
  context_moved 严格为 0。
- target_overflow override。

### 4.3 插件 bug 修复

开放目标会话中暴露并修复：

```text
1.  archive 未 import existsSync/copyFileSync
2.  archive 嵌套 checkpoint 目录不存在
3.  full 分支 design 变量未定义
4.  accept / verify lg / metrics 缺 design 硬编码 s1238
5.  observe 缺 workdir 报 Node paths[0] undefined
6.  metrics 无输入未前置校验
7.  propose freeze/region_density 缺 region 输出 traceback
8.  Python rc!=0 返回 Command failed 而非结构化 JSON
9.  region 和 scope_region 参数不一致导致 undefined
10. candidate terminal 不输出子 checkpoint，
    导致 local_restart stage=candidate 失败
11. local/candidate 不返回 scope_effect
12. run 缺 design 不从 trace 推断
13. start/full 缺 target_density/target_overflow 值域校验
14. gp_toolbox 未捕获异常输出 traceback
15. observe 缓存不随 workdir/DEF mtime 失效
```

### 4.4 验证

- `ipl_gp_session_test --scenario validate`：通过。
- `gp_tool_contract_test`：s1238 / nangate45 / ihp130 / asap7
  全部 ok=true。
- 分段等价：
  - 10x2 == 20，coords/records bitwise equal。
  - 20 + cross-process resume 20 == 40。
  - legacy runGPResult == session full。
  - all-active local scope == global。
- 20x5 == 100：
  checkpoint 坐标、内部 HPWL/overflow、placement.def md5 全部一致。
- 开放目标 headless 会话：
  ihp130 / nangate / asap7 / s1238 各数十到上百次工具调用，
  最新插件代码 s1238 会话插件级错误为 0。

---

## 5. 当前结果（2026-08-21）

同一 evaluator：timing=1，congestion_model=rudy。

### s1238 / sky130

| placement | HPWL | RUDY max | bins | rsum | WNS ns | freq MHz |
|---|---|---|---|---|---|---|
| raw | 5,957,257 | 2.768 | 654 | 208.65 | -0.0503 | 645.0 |
| candidate | 6,016,396 | 2.445 | 569 | 153.56 | -0.0420 | 648.5 |
| Innovus | 8,053,041 | 2.035 | 622 | 133.02 | -0.1341 | 612.0 |

### nangate45_gcd

| placement | HPWL | RUDY max | bins | rsum | WNS ns | freq MHz |
|---|---|---|---|---|---|---|
| raw | 5,850,034 | 5.149 | 289 | 330.65 | -1.186 | 598.3 |
| candidate | 2,775,743 | 3.084 | 259 | 144.58 | -1.184 | 599.0 |
| Innovus | 3,264,413 | 1.991 | 328 | 100.39 | -1.207 | 590.8 |

### ihp130_gcd

| placement | HPWL | RUDY max | bins | rsum | WNS ns | freq MHz |
|---|---|---|---|---|---|---|
| raw | 620,662,411 | 2.655 | 1728 | 784.41 | +0.459 | 220.2 |
| candidate | 440,705,485 | 1.738 | 976 | 199.71 | -1.394 | 156.4 |
| Innovus | 502,815,015 | 2.171 | 1099 | 245.28 | -1.024 | 166.0 |

### asap7_aes

| placement | HPWL | RUDY max | bins | rsum | WNS ns | freq MHz |
|---|---|---|---|---|---|---|
| raw | 58,392,975 | 1.697 | 16 | 4.47 | -5.374 | 161.7 |
| w1 | 65,249,354 | 1.992 | 10 | 4.49 | -5.205 | 166.2 |
| w4 | 57,047,237 | 2.322 | 53 | 21.27 | -5.094 | 169.4 |
| w6 | 32,374,366 | 3.940 | 43 | 31.03 | -5.486 | 158.8 |
| Innovus | 45,224,840 | 0.706 | 0 | 0 | -7.392 | 121.9 |

### 结论

```text
ihp130：HPWL + 全部 congestion 指标超过 Innovus，只差 timing。
nangate：HPWL / bins / timing 超过 Innovus，congestion 未超过。
s1238：HPWL / bins / timing 超过 Innovus，congestion 未超过。
asap7：w6 HPWL/timing 超过 Innovus，congestion 明显差。
没有任何设计在所有维度同时超过 Innovus。
```

---

## 6. 做得不好的地方

### 6.1 QoR

- congestion 是最大短板：
  nangate / s1238 / asap7 的 RUDY max 和 overflow sum
  都没有超过 Innovus。
- ihp130 timing 反而比 Innovus 差：
  WNS -1.394 vs -1.024，freq 156.4 vs 166.0。
- asap7 congestion 和 HPWL 之间 tradeoff 太大：
  HPWL 好的 w6 congestion 很差；
  congestion 好的 w1 HPWL 很差。
- RUDY 不是 EGR，不能直接等同于真实 early global route。

### 6.2 求解器能力

- local GP 是“全局梯度 + 局部移动 mask”，
  不是局部重新计算目标函数。
- local scope 对“net 穿线热点但区域内 cell 很少”的情况
  效果有限，必须切到 congestion net instances。
- nangate45 物理利用率接近 1，
  target_density 基本没有松弛空间。
- timing_effort 运行时 override 会 abort，
  已回滚；
  config-file timing_effort 即使初始化了，
  在 ihp130 上也没有改变结果。
- candidate terminal 分支在 C++ 层没有完整输出子 checkpoint，
  目前靠 Python fallback，后续最好把语义下沉到 C++。

### 6.3 插件

- 早期 error surface 太多：traceback / Command failed / undefined，
  已修复，但说明缺乏“错误出口”的统一设计。
- 缓存策略最初只按参数，导致 status 返回过期结果；
  现在动态 observe 不再缓存，congestion/timing 用 DEF mtime。
- archive 是运行时目录归档，不是真正的 experiment database；
  跨会话搜索历史仍需 agent 自己记录。

### 6.4 Agent 编排（模型能力，不是插件问题）

- 空 workdir 先调 status/checkpoints/propose。
- metrics 缺 raw_def/candidate_def。
- checkpoint=cp1 这类无效标签。
- region 坐标不 overlap 任何 GP bin。
- region_density/freeze 不传 region。
- target_density=1。
- 反复 accept terminal session。
- 开放目标下可能长时间不停止，需要提示词给停止条件。

---

## 7. 未完成

```text
1. 任何设计在全部维度超过 Innovus：未完成。
2. ihp130 timing 两项：未完成。
3. nangate/s1238/asap7 congestion 超过 Innovus：未完成。
4. EGR evaluator：未接。
5. runtime timing_effort：未实现（需要 initSTA 生命周期管理）。
6. config timing_effort 为什么无效：未定位。
7. experiment database / 跨会话 Pareto 记忆：未做。
8. 更多 PDK / 更大设计验证：只做了 7 个注册设计中的 4 个重点设计。
9. asap7 的高 HPWL / congestion 双目标平衡：未找到。
10. apply_anchor：未实现。
```

---

## 8. 怎么跑对比

### 8.1 最简单：headless one-shot

```bash
export PATH=/home/lizhijun/.npm-global/bin:$PATH
export DSH_HOME=/tmp/dsh-headless-gp
cd /home/lizhijun

dsh --profile headless \
"你只能调用 ieda_gp_run。调用 ieda_gp_run kind=full design=s1238 workdir=/tmp/handover_s1238 iterations=600 timing=1 congestion_model=rudy。报告 raw/candidate/innovus 的 HPWL、RUDY max、bins、rsum、setup WNS。"
```

### 8.2 Web 大目标形式

新 Web 对话直接发：

```text
我的目标是：对 s1238（sky130）做 GP 优化，
尽量全面超过 baseline 和 Innovus：
HPWL、RUDY utilization max、overflow bins、
overflow sum、setup WNS。

只允许使用：
ieda_gp_observe / ieda_gp_propose /
ieda_gp_run / ieda_gp_verify / ieda_gp_session。

工作目录用 /tmp/xxx。
不需要无限搜索；连续两次局部动作无改善就停止并说明理由。
最后给 raw / candidate / innovus 全维度对比表和工具调用摘要。
```

### 8.3 直接脚本对比（绕过模型）

```bash
cd /home/lizhijun/work/iEDA.ai

python3 benchmarks/flows/gp_metrics_compare.py \
  --design s1238 \
  --case-root /home/lizhijun/work/iEDA/docs/ipl/pl_vis/cases/s1238 \
  --macro-lef scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef \
  --foundry-dir scripts/foundry/sky130 \
  --out /tmp/compare_s1238.json \
  raw=/tmp/p0_converged/s1238/placement.def \
  candidate=/tmp/goal_test_s1238_final/placement.def \
  innovus=/home/lizhijun/work/iEDA.ai/benchmarks/results/innovus_gp_compare/s1238/innovus_placed.def
```

其他设计：

```bash
# nangate45
python3 benchmarks/flows/gp_metrics_compare.py \
  --design nangate45_gcd \
  --case-root /tmp/nangate45_gcd \
  --macro-lef /mnt/usb20t/PCL-167/data3/taosimin/OpenROAD/test/Nangate45/Nangate45_stdcell.lef \
  --foundry-dir /mnt/usb20t/PCL-167/data3/taosimin/OpenROAD/test/Nangate45 \
  --out /tmp/compare_nangate.json \
  raw=/tmp/gp_nangate45_direct/placement.def \
  candidate=/tmp/goal_test_nangate/placement.def \
  innovus=/tmp/nangate45_gcd/innovus_placed.def

# ihp130
python3 benchmarks/flows/gp_metrics_compare.py \
  --design ihp130_gcd \
  --case-root /home/lizhijun/work/iEDA/scripts/design/ihp130_gcd \
  --macro-lef /home/lizhijun/work/iEDA/scripts/foundry/ihp130/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_stdcell.lef \
  --foundry-dir /home/lizhijun/work/iEDA/scripts/foundry/ihp130 \
  --out /tmp/compare_ihp130.json \
  raw=/tmp/gp_ihp130_gcd/placement.def \
  candidate=/tmp/goal_test_ihp130/placement.def \
  innovus=/home/lizhijun/work/iEDA/scripts/design/ihp130_gcd/innovus_placed.def

# asap7
python3 benchmarks/flows/gp_metrics_compare.py \
  --design asap7_aes \
  --case-root /tmp/asap7_aes \
  --macro-lef /mnt/usb20t/PCL-155/home/dengqinyi/iFlow/foundry/asap7/lef/asap7sc7p5t_27_R_1x_201211.lef \
  --foundry-dir /mnt/usb20t/PCL-155/home/dengqinyi/iFlow/foundry/asap7 \
  --out /tmp/compare_asap7.json \
  raw=/tmp/gp_asap7/placement.def \
  candidate=/tmp/goal_test_asap7_w4/placement.def \
  w1=/tmp/goal_test_asap7_w1/placement.def \
  w6=/tmp/goal_test_asap7_w6/placement.def \
  innovus=/tmp/asap7_aes/innovus_placed.def
```

### 8.4 当前重点文件

```text
raw s1238：/tmp/p0_converged/s1238/placement.def
candidate s1238：/tmp/goal_test_s1238_final/placement.def

raw nangate：/tmp/gp_nangate45_direct/placement.def
candidate nangate：/tmp/goal_test_nangate/placement.def

raw ihp130：/tmp/gp_ihp130_gcd/placement.def
candidate ihp130：/tmp/goal_test_ihp130/placement.def

raw asap7：/tmp/gp_asap7/placement.def
asap7 候选：/tmp/goal_test_asap7_w1、_w4、_w6
```

---

## 9. 重要开发约束

```text
1. 分支：feat/parity-gp-session
2. 推送：personal
   GIT_SSH_COMMAND='ssh -o BatchMode=yes' git push personal feat/parity-gp-session
3. 提交命令：
   ./dev/branch_commit.sh -m "..." -- <paths>
4. 改 JS/插件后：
   dev_reload_package '@ieda-ai/dsh-tool-ieda-gp'
   不要 systemctl restart dsh-web.service
5. 改 Python：新进程自动生效，无需 reload。
6. 改 C++：
   ninja -C build iEDA
7. headless 环境：
   DSH_HOME=/tmp/dsh-headless-gp
   dsh --profile headless "..."
8. /tmp 数据不是永久存储，交付时要把关键 DEF 和 JSON
   复制到仓库或长期目录。
```

---

## 10. 交付清单

```text
GPA_HANDOVER.md            本文件
GPA_NEXT_PLAN.md           原始计划
GPA_TOOL_MANUAL.md         新手工具手册
GPA_TOOL_EXTREME_DESIGN.md 点工具设计目标
GPA_EDA_SIDE_INVENTORY.md  EDA 侧能力清单
GPA_PRESETS.md             可复现配置表
GPA_RESULTS_LATEST.md      较早结果
GPA_GAP_ANALYSIS.md        gap 分析
GPA_CALL_CHAIN_AUDIT.md    调用链审计
GPA_PLAN_EVIDENCE.md       逐轮证据日志
GPA_POINT_TOOL_REVIEW.md   点工具最终复盘
```

## 11. 建议接手顺序

```text
1. 先读 GPA_HANDOVER.md 和 GPA_POINT_TOOL_REVIEW.md。
2. 跑 8.3 的四条 compare 命令确认环境。
3. 先攻 ihp130 的 timing 两项，因为它只差 timing。
4. 再攻 nangate 的 RUDY max / overflow sum。
5. asap7 建议从 Innovus DEF 初始解方向继续。
6. 所有优化都用同 evaluator 表格记录，
   不要混用不同 congestion model。
