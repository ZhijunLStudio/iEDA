# GP Agent 真实调用链路审计

数据来源：`/tmp/dsh-headless-gp/sessions/--home-lizhijun--/*/session.jsonl.zstd`。
只记录真实模型调用，不做推测。

## 1. apb4_timer（较完整，符合假设-验证）

```text
01 ieda_gp_inspect status parent
02 ieda_gp_inspect checkpoints parent
03 ieda_gp_verify lg baseline DEF      <- 浪费，lg 不是 def_hpwl
04 ieda_gp_verify lg checkpoint        <- 浪费，同上
05 ieda_gp_diagnose longnets parent
06 ieda_gp_diagnose longnets 绝对路径 checkpoint
07 ieda_gp_diagnose longnets 另一个 checkpoint 路径
08 ieda_gp_propose longnet_instances top2
09 ieda_gp_run local_restart 选中的 instances
10 ieda_gp_run start random_init=0 新 parent
11 ieda_gp_inspect checkpoints parent1
12 ieda_gp_diagnose longnets parent1
13 ieda_gp_propose longnet_instances parent1
14 ieda_gp_run local_restart parent1
15 ieda_gp_run start 再建 parent2
```

结论：

```text
主体流程正确，但前 4 次调用里有 2 次把 LG oracle 当 HPWL 评测，
浪费了调用预算。
```

## 2. asap7_aes（暴露了 scope 参数错误）

```text
01 todo_write 计划
02 inspect status
03 inspect checkpoints
04 verify lg baseline DEF
05 diagnose hotspots
06 propose regions
07 propose region_density
08 local_restart scope=region_density    <- 无效，工具报错
09 local_restart scope=region            <- 模型自己重试修正
10 start random_init=0 parent1
11 inspect status parent1
12 diagnose hotspots parent1
13 propose regions parent1
14 local_restart region parent1
15 start parent2
```

结论：

```text
- `scope=region_density` 不在工具的合法 scope 枚举里；
- 模型靠报错自行重试，说明参数 schema 约束不够强。
```

## 3. nangate45_gcd（大量文件查看代替工具观察）

```text
01 todo_write
02 inspect status
03 inspect checkpoints
04 verify lg
05 verify lg
06-15 str_replace_editor 查看各种文件：
    placement.def
    gp_agent_state.json
    gp_experiments.jsonl
    grid_report.json
    place_summary.json
    ipl_stage_report.json
```

结论：

```text
模型把很多调用花在直接看文件上，而不是使用 diagnose/propose。
原因是 GP-only profile 没有禁用 str_replace_editor。
```

## 4. s1238（动作选择导致无改善）

```text
01 inspect status
02 inspect checkpoints
03 diagnose hotspots
04 propose regions
05 local_restart region-1
06 start parent1
07 inspect checkpoints parent1
08 diagnose hotspots parent1
09 propose regions parent1
10 inspect status parent1
11 inspect checkpoints restart workdir
12 inspect status restart workdir
13 diagnose hotspots local child
14 propose regions local child
15 local_restart region-2
```

结论：

```text
本轮模型一直选择 density region，
而之前能改善 s1238 的是 longnet instances。
说明 Agent 对不同可执行 proposal 的优劣没有可复用经验。
```

## 5. ihp130_gcd（最严重的浪费）

```text
01 inspect status
02 inspect checkpoints
03 verify lg baseline
04 diagnose trajectory
05 diagnose trajectory
06 verify lg checkpoint
07-15 str_replace_editor 查看大量文件
之后出现数百次 ieda_gp_run 重复调用。
```

结论：

```text
主要浪费来自：
- terminal checkpoint 缺失（已修）；
- 动作缓存旧版本未失效（已修）；
- 模型没有可参考的动作结果摘要。
```

## 6. picorv32

```text
01 inspect checkpoints
02 diagnose longnets
03 propose longnet_instances
04 local_restart top-net instances
```

结论：

```text
调用很简洁，但没有改善；
真正的问题不是调用链，而是该设计当前局部动作空间里没有可行改善动作。
```

## 需要继续改的

1. GP-only profile 禁用 str_replace_editor 和 todo_write 之外的文件工具；
2. ieda_gp_run.scope 用 enum 限制合法值；
3. ieda_gp_verify.lg 描述里明确“不是 DEF HPWL”；
4. 给模型提供“已尝试 proposal / 结果摘要”工具；
5. 让 local_restart 结果直接包含同 evaluator 的 density/RUDY，
   减少模型额外调用。
