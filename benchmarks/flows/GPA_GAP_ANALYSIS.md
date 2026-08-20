# GP Agent 效果差距分析

问题：为什么 Agent 没有获得特别大的超越？

## 0. 当前结果摘要

### sky130

- HPWL：iEDA raw / agent 全部远好于 Innovus（-16% ~ -37%）。
- timing：iEDA 更好或接近。
- peak density：接近，Innovus 在 aes 更好。
- RUDY max：Innovus 更好。

### cross-PDK

同网表重跑 nangate45 后：

| nangate45_gcd | HPWL | peak density | RUDY max | RUDY total | WNS |
|---|---|---|---|---|---|
| raw | 5,850,034 | 0.839014 | 0.015860 | 4.843156 | -1.186 ns |
| agent | 5,813,974 | 0.839014 | 0.016195 | 4.834003 | -1.199 ns |
| Innovus | 3,264,413 | 0.771516 | 0.005812 | 5.534596 | -1.207 ns |

结论：cross-PDK 上不是 Agent 差，而是 iEDA raw GP 本身就在
HPWL / peak density / RUDY max 上落后 Innovus。

## 1. 问题分四层

### A. 点工具执行正确性问题

已发现，尚未全部修复：

1. `ieda_gp_session accept` 在 candidate 工作目录会写出输入 DEF；
2. `local_restart` 与 seed `start` 的 config fingerprint 不一致；
3. iSTA 对 ps 单位 liberty 的路径传播 bug，asap7 timing 不可用；
4. RUDY evaluator 只输出 demand density，不是 utilization / overflow；
5. `target_reached` 的 start 现在会保存 checkpoint，已修。

这些会直接浪费 Agent 调用，但不是 QoR 上限。

### B. 点工具太粗糙 / 方向信息不足

1. GP 目标只有 HPWL + density 约束：
   - 没有 congestion objective；
   - 没有 timing objective；
   - density 只是约束，不是软目标。

2. observe / propose 只能看到：
   - density 热点；
   - 长网；
   - 没有 RUDY 热点 proposal；
   - 没有 timing path proposal；
   - 没有 config proposal。

3. local_restart 是黑盒组合动作：
   - candidate + accept + restart 一次做完；
   - 中间失败时 Agent 拿不到 partial result；
   - 无法中途调整 budget / scope / config。

4. verify metrics 很贵，且只能对 DEF 事后比较，
   不能进入 GP 搜索循环。

### C. EDA 算法差距

关键证据：nangate45 同网表重跑。

```text
raw GP HPWL 5.85M，Innovus 3.26M
raw peak density 0.839，Innovus 0.772
raw RUDY max 0.0159，Innovus 0.0058
```

这不是局部动作能补回来的差距。
iEDA 当前 GP 在 cross-PDK 上的：
- wirelength 优化程度；
- density 展开程度；
- congestion 展开程度；
都不如 Innovus placeDesign。

最明显的证据是 AES：
- Agent 把 target_density 从默认改成 0.9 后，
  HPWL -13.7%，timing 大幅改善。
说明 solver config 是最大的杠杆，
而现在的 propose 工具根本不提供 config 搜索方向。

### D. Agent 编排问题

1. 没有跨会话记忆：
   - 已经验证过的 proposal 不会沉淀；
   - 每次重新尝试，结果不稳定。

2. 调用预算被工具错误消耗：
   - ihp130 曾出现数百次重复 ieda_gp_run；
   - nangate 曾大量调用 str_replace_editor 看文件。

3. Agent 只能做局部动作，不能系统做 config sweep：
   - 每个 start 很贵；
   - 没有 propose_config；
   - 没有动作结果数据库。

4. 但 Agent 本身有发现能力：
   - AES target_density 假设-验证-接受链是成功的；
   - 工具干净时，apb4 / asap7 局部改善稳定。

## 2. 根因排序

```text
第一位：GP solver 的 objective / config 没有针对
        HPWL-density-congestion 联合优化；
        cross-PDK raw 已经落后。

第二位：观察 / 提议工具缺少 congestion / timing / config 方向；
        Agent 看不到该往哪里调。

第三位：局部执行原语太粗；
        local_restart 黑盒 + 中间失败不可恢复。

第四位：工具执行正确性 bug 仍在浪费预算。

第五位：Agent 没有跨会话记忆和动作结果沉淀。
```

## 3. 建议下一步

```text
P0 修正确性：
   - accept DEF 导出
   - config fingerprint mismatch
   - iSTA ps 单位 bug
   - RUDY utilization/overflow 输出

P1 补方向信息：
   - observe 增加 rudy_hotspots / timing_paths / config_effect
   - propose 增加 propose_config / propose_congestion_region
   - local_restart 返回 partial result，失败也可诊断

P2 补 GP 能力：
   - 验证并暴露 wirelength / density / congestion 权重与 effort；
   - 对 7 设计做 target_density / congestion_effort sweep，
     建立 config 基线。

P3 补 Agent 能力：
   - 跨会话 frontier / 动作结果数据库；
   - config search 原语。

P4 再评估 Agent：
   - 工具与 config 基线修完后，
     让 Agent 在 HPWL / density / RUDY / timing 四维上优化。
```
