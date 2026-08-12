# 41 · interface commercial-parity TODO

事实源：`docs/ai/41-interface.md`。完成口径以 TCL/Python/MCP 三层命令契约、失败传播、产品断言和 silent-success inventory 同时存在为准。

## 当前结论

- 接口层是工具对用户的第一道门，silent success 必须清零。
- 现有问题不是“有没有命令”，而是命令是否事务化、返回值是否被吞、依赖是否显式。
- Python 和 MCP 不能各自分裂出一套语义。
- 已落地可重复 inventory：`docs/ai/interface-silent-success-inventory.{json,md}` 当前记录 491 个 Tcl/Python open finding、273 个 API candidate，其中 131 个尚未接入 interface。
- MCP critical shell/write 风险已清零：默认只读，执行 iEDA 需 `MCP_IEDA_WRITE=1`，结果返回 JSON schema/rc/product assertion。

## P0 - silent-success inventory

- [X] 扫描 `src/interface/tcl`、`python/py_*`、`mcp-iEDA`，列出 `return true`、吞 bool、吞 rc、空实现、默认成功的命令清单。
- [X] 清单写进 repo，包含 file:line、mode、tool、status、test。
- [X] 高风险命令优先：place/cts/route/to/sta/report_qor/init_*/read_*/write_*。
- [ ] 每个已知假成功命令必须有 fix owner 和 regression。
  - [X] inventory 已为每个 finding 生成稳定 regression 名称；逐项 fix owner 尚未分配。

## P0 - transactional command base

- [ ] 落地 `TclCmdTransactional` 或等价基类：allowed、dependency、products 三表。
- [ ] 成功定义为：API success + 产物存在 + schema valid + dep satisfied。
- [ ] 未知 option/key 必须 ERROR，不得吞掉进入默认路径。
- [ ] 命令失败必须传播到 Tcl/Python rc 或异常。
- [ ] 旧命令迁移期间，compat mode 要显式 opt-in。

## P1 - Python parity

- [ ] Python 绑定的成功/失败语义与 TCL 对齐。
- [ ] Python 不能悄悄比 TCL 多吞一次错误或返回默认值。
- [ ] 为关键命令补一组 Python/TCL 一致性测试。
- [X] `mcp.write`、`mcp.read`、`mcp.admin` 权限边界写成可审计配置。
  - [X] 当前 MCP write/execute 由 `MCP_IEDA_WRITE=1` 显式授权，默认只读。

## P1 - MCP boundary

- [X] MCP 默认只读；写 DB、优化、删除文件、任意 shell 都需显式授权。
- [X] 读报告/看指标允许，但不能代替命令执行成功判定。
- [X] MCP 只做明确的工具代理，不得偷偷重写平台契约。

## P2 - coverage and migration

- [ ] 先迁移最热命令，再迁移冷门命令。
- [ ] 每个命令增加产品断言、失败测试和文档映射。
- [ ] 旧接口兼容窗结束后，去掉默认成功的历史分支。

## 下一步执行顺序

1. **P0 base class**。
2. **P1 Python/TCL parity**。
3. **P2 hot command migration**。
4. **P2 remove compat default success**。

## 验证纪律

- 未入清单的命令，不得默认认为安全。
- Python/MCP 的 true 不等于平台成功，必须附产物和 rc。

## Source map

| File / module | 当前定位 | 具体待办 |
|---|---|---|
| `src/interface/tcl/*` | TCL 命令 | inventory 已覆盖；继续落 transactional base |
| `src/interface/python/*` | Python 绑定 | inventory 已覆盖；继续做 rc/exception 对齐、产品断言 |
| `mcp-iEDA/*` | MCP 面 | 已默认只读、write 授权、JSON rc/product assertion |
| `src/platform/tool_manager/tool_api/*` | 工具协议 | API candidate inventory 已覆盖；继续接 allowed/dependency/product 三表 |
| `src/platform/flow/*` | 平台消费者 | 命令顺序、abort chain、SUCCESS stamp |
