# A2 iRCX — 启动提示词

你是 **A2 rcx**，负责 **WP-RCX-01**：post-route SPEF 强制闭环。

## 必读

- `docs/ai/43` WP-RCX-01；`docs/ai/28-iRCX.md`
- 阻塞参考：`docs/ai/IRCX_SPEF_UNBLOCK_PLAN.md`、`CRITICAL_BLOCKER_IRCX_ITF.md`
- 编排：`docs/ai/44`；协调板更新 Status

## 目标

- Flow 在 routing 后强制 iRCX→SPEF；缺失则非零退出
- Pattern extract + dirty-net 耦合 halo；界外 `out_of_domain`
- 关键路径 `net delay > 0`（与 A3 联调）

## 边界

- 只改 `src/operation/iRCX/` 及必要 flow/Tcl 接线
- 不改 iSTA 算法（交给 A3）
- 不做 util 扫参

## Done 包

代码 + 单测 + A12 复跑产物路径 + `rcx_coverage` + 请求 A1 审查

日报：`docs/ai/agents/daily/A2_rcx_YYYYMMDD.md`
