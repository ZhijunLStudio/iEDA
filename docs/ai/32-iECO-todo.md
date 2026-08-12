# 32 · iECO commercial-parity TODO

事实源：`docs/ai/32-iECO.md` rv2.2。完成口径以 request 状态、transaction rollback、产物断言、local/full oracle 和跨工具契约同时存在为准。

## 当前结论

- via request 的 unsupported 失败语义已有进展；legacy string `shape` 已 fail-closed，shape request report / local oracle / periodic full oracle gate / rollback proof 已有轻量契约闭环。
- timing ECO 门面已默认 gated/experimental，不早于 iTO/iRT/platform 事务原语开放真实改库。
- ECO 成功必须证明白名单外对象 hash 不变。

## P0 - via ECO request contract

- [x] `pattern` request 已明确 unsupported/fail，不再 silent init 或改 DB。
- [X] `shape` request 必须输出 changed shapes、via count、affected nets、local DRC before/after。
- [X] request 状态统一：accepted/rejected/unsupported/failed/rolled_back。
- [X] 未知 request token、缺 layer、缺 bbox、冻结层修改必须非零。
- [X] 输出 `eco_via_report.json`。

## P0 - transaction and rollback

- [ ] 建立 ECO transaction：candidate、preflight、commit、verify、rollback。
  - [X] via shape contract 已实现 candidate/preflight/verify/rollback report；真实 DB transaction 尚未完成。
- [ ] rollback 后 canonical hash 与 baseline 一致，白名单外 DB 全量不变。
  - [X] via shape contract 已验证 rollback_hash == baseline_hash；真实 DB 白名单外全量 hash 尚未完成。
- [X] freeze_layers / eco_layers 配置 schema 固定。
- [X] 中途失败、DRC 变差、connectivity 变差必须 rollback。

## P1 - local oracle and full oracle

- [X] local DRC / connectivity / route legality 三类 oracle 同时通过才可 commit。
- [ ] periodic full oracle：定期跑 iRT/iDRC/iSTA 全量检查防局部 oracle 漏判。
  - [X] via shape contract 已实现周期 full oracle gate 和 iRT/iDRC/iSTA 结果字段；真实全量工具编排尚未接入。
- [X] 修复目标必须报告改善量，不得以“执行过 ECO”当成功。
- [X] routeECO API 归 iRT/platform，iECO 不直接私改 routing 真源。

## P2 - timing ECO facade

- [X] `ecoTiming` 门面只在 iTO/iRT/platform 原语具备后开启。
- [X] timing ECO 成功判据：setup/hold/DRV guardband、area/power/congestion Pareto、合法性。
- [X] 与 PrimeTime/商业 ECO 对拍前保持 experimental。

## 下一步执行顺序

1. **P0 shape report**：先证明 shape ECO 真的改对。
2. **P0 rollback hash**：关闭污染风险。
3. **P1 oracle**：建立局部/全量验证。
4. **P2 timing facade**：等待依赖门禁。

## 验证纪律

- ECO 成功必须有 before/after diff、oracle 结果和 rollback proof。
- unsupported 不是 skipped success。

## Source map

| File / module | 当前定位 | 具体待办 |
|---|---|---|
| `api/ieco_api.{h,cpp}` | 门面 | 已暴露 gated `ecoTiming`；继续接真实 rc、事务、产品断言 |
| `source/ieco.{h,cpp}` | 工具主干 | 已传播 via/timing contract 状态；继续接真实 request 路由、阶段状态、失败传播 |
| `source/data/{ieco_data,ieco_data_via}.{h,cpp}` | 数据对象 | delta、hash、白名单对象不变性 |
| `source/data_manager/ieco_dm.{h,cpp}` | 数据管理 | transaction、rollback、object mapping |
| `source/eco_timing/{ieco_timing}.{h,cpp}` | timing ECO contract | 已覆盖 primitive gate、guardband、experimental；继续接 iTO/iRT/platform 原语 |
| `source/eco_via/{ieco_via,ieco_via_report,ieco_via_init,ieco_via_repair}.{h,cpp}` | via ECO 主内核 | legacy string 入口已 fail-closed；继续把 report contract 接入真实 DB transaction |
| `source/eco_via/tests/ECOViaRequestTest.cpp` | 语义测试 | 已覆盖 unsupported、rollback、product improvement、full oracle gate、routeECO owner；继续补真实 DB rollback |
