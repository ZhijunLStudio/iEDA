# GP 点工具复盘（按用户开放目标形式验证）

## 测试方式

- 用 Web 用户的开放目标形式：
  只给大目标 + 工具约束，不限轮数，让 agent 自己拆解。
- 跑 4 个会话：
  ihp130_gcd、nangate45_gcd、asap7_aes、s1238（最新插件代码）。
- 会话统计（截至复盘时）：
  ihp130：117 calls，ok 103，fail 14
  nangate：106 calls，ok 91，fail 15
  asap7：88 calls，ok 68，fail 20
  s1238（最新代码）：27 calls，fail 7
- 最新代码 s1238 会话的 7 个失败全部是模型编排错误：
  空 workdir 调 status、metrics 缺 def、
  region 不 overlap、缺 region。
  没有插件级错误。

## 会话暴露并已修复的插件问题（点工具责任）

1. archive 使用 existsSync/copyFileSync 未 import，
   所有 run 崩溃。
2. archive 保存嵌套 pl/checkpoint 时目录不存在。
3. full 分支 design 变量未定义。
4. accept / verify lg / metrics 缺 design 时硬编码 s1238。
5. observe 缺 workdir 时 Node paths[0] undefined。
6. metrics 缺 raw/candidate/extra 时无前置校验。
7. propose freeze/region_density 缺 region 时 Python traceback。
8. Python rc!=0 时插件返回 Command failed 而不是结构化 JSON。
9. run 工具 schema 同时暴露 region 和 scope_region，
   apply_region_density 只认 region，导致 undefined。
10. candidate 局部分支 terminal（target_reached /
    overflow_target_miss）不输出 candidate_verdict/local/global，
    导致 candidate={} 和 local_restart stage=candidate 失败。
11. local/candidate 不返回 scope_effect，
    agent 无法判断 local scope 是否真的 engage。
12. 缺 design 的 run 动作没有从 trace 推断。
13. start/full 缺 target_density/target_overflow 值域校验。
14. gp_toolbox 未捕获异常时输出 traceback。

## 模型编排问题（不属于插件责任，仅记录）

- 空 workdir 先调 status/checkpoints/propose。
- metrics 缺 raw_def/candidate_def。
- checkpoint=cp1 等无效标签。
- region 坐标不在任何 GP bin 内。
- region_density/freeze 不传 region。
- 反复 accept terminal 会话。
- target_density 传 1。
- 所有 case 共用同一 workdir，早期覆盖历史（已由 archive 兜底）。

## 结论

- 点工具现在满足：结构化错误、缺失参数可推断、
  运行历史自动归档、scope 效果可见、terminal candidate 可被
  local_restart 消费。
- 最新代码开放目标会话中插件级错误为 0。
- 剩余失败均为 agent 编排/模型能力，不是插件问题。

## 会话最终统计（停止时）

- ihp130_gcd：117 calls，其中 verify metrics 28 次；
  最佳 HPWL candidate 242,844,371；
  最佳 rutil candidate 1.91393（HPWL 441,197,013）。
- nangate45_gcd：106 calls，其中 verify metrics 26 次；
  最佳 HPWL candidate 1,416,468；
  最佳 rutil candidate 2.929964（HPWL 2,493,578）。
- asap7_aes：88 calls，其中 verify metrics 12 次；
  最佳 HPWL candidate 26,392,043；
  最佳 rutil candidate 1.696979（HPWL 58,392,975）。
- s1238（最新插件代码）：27 calls，其中 verify metrics 8 次；
  最佳 HPWL candidate 3,046,808；
  最佳 rutil candidate 2.415218（HPWL 6,587,537）。
- 以上指标来自 session log 中成功返回的同 evaluator metrics。
  会话被主动停止以释放资源，完整 tool call log 保留在
  /tmp/dsh-headless-gp/sessions/ 的 session.jsonl.zstd。
