# iEDA.ai 深度优化实施记录

生成时间：2026-08-13 16:26:30 CST
依据审查：[ieda_ai_deep_code_review_20260813.md](ieda_ai_deep_code_review_20260813.md)
工作分支：`commercial-parity`
实施范围：安全 P0、可靠性 P0、构建/CTest 稳定性、MCP Agent 调用边界

## 1. 本轮结论

本轮已闭环审查报告中的 P0-1（hMetis 外部命令注入和旧结果污染）、P0-4（JSON/gzip 内存安全）以及 P0-3 中 iSTA 报告路径的空对象/缺边崩溃点；同时完成 MCP workspace 边界、源码树 `.env` 泄露、CTest 产物可见性整改，以及 P1-3 iDRC/iRT logger 生命周期整改。

最终验证在 `build-aes13` 完成：

| 验证项 | 结果 | 时间 |
|---|---:|---|
| `cmake --build build-aes13 --target all -j 8` | 通过 | 2026-08-13 12:39 CST |
| `ctest --test-dir build-aes13 --output-on-failure -j 4` | **99 / 99 通过** | 2026-08-13 16:28 CST |
| `ctest --test-dir build-aes13 -R '^(idrc_logger_exit_test\|irt_logger_failure_test)$' --output-on-failure` | **2 / 2 通过** | 2026-08-13 16:26 CST |
| `python3 -m unittest src/interface/mcp-iEDA/test/test_mcp.py` | **5 / 5 通过** | 2026-08-13 12:39 CST |
| `git diff --check`（本轮涉及源码/CMake） | 通过 | 2026-08-13 12:40 CST |

说明：工作树在本轮开始前已包含大量并行 QoR/PBA/功能改动和 `build-aes13` 生成物；本记录不将其作为本轮新增变更，也未清理或提交这些产物。

## 2. 已实施整改

| 审查项 | 实施结果 | 主要文件 | 回归覆盖 |
|---|---|---|---|
| P0-1：hMetis shell 注入 | 删除 `system()` 字符串拼接，改为 `posix_spawn` argv 调用和 `waitpid` 状态检查 | `src/operation/iPL/source/solver/partition/Hmetis.cc` | `ipl_hmetis_security_test` |
| P0-1：旧 partition 结果污染 | 每次运行使用 `mkdtemp` 私有目录；仅接受本轮常规文件；精确校验条目数和分区编号；结束时 RAII 清理 | `Hmetis.cc/.hh` | 空格路径、分号 payload、旧 `.part` 文件、产物清理 |
| P0-4：JSON/gzip 内存安全 | 文件流改为值语义；移除 `new` 返回引用；gzip 改为 RAII 流式 inflate；截断/损坏输入返回失败 | `src/utility/json/json_parser.h` | `json_parser_safety_test` |
| P0-4：配置读取健壮性 | JSON 路径逐层查找；缺键、null 和中间非对象返回显式默认值 | `json_parser.h` 及 9 个直接调用点 | 有效 gzip、截断 gzip、JSON 默认值、输入输出流 |
| P0-3：iSTA 报告崩溃 | YAML/JSON/wire/timing-data dump 检查空 vertex 和缺失 sink arc，仅记录 warning 并跳过 | `src/operation/iSTA/source/module/sta/StaReport.cc` | `sta_pba_report_test` + 全量 CTest |
| P1：MCP 任意 Tcl 执行面 | 写模式强制 `MCP_IEDA_WORKSPACE`；canonical 路径必须位于 workspace；只允许 `.tcl`；校验可执行位；限定工作目录与超时 | `src/interface/mcp-iEDA/src/mcp_ieda/server.py` | MCP 5 项 Python 单测 |
| P1：本机配置泄露 | 删除被跟踪的 MCP `.env`（含个人路径和内网地址），仓库级忽略 `.env` | `.gitignore`、`src/interface/mcp-iEDA/src/mcp_ieda/.env` | Git 跟踪检查 |
| P1：构建树污染/CTest 不稳定 | 运行时库、可执行文件和 Python 模块统一产出至 `${CMAKE_BINARY_DIR}/lib|bin`；取消 app/iPA/Python 的源码树输出覆盖 | `CMakeLists.txt`、`src/apps`、`src/operation/iPA`、`src/interface/python` | 构建树 RPATH、99/99 CTest |
| P1：已注册测试未构建 | 移除已 `add_test` 目标的 `EXCLUDE_FROM_ALL`，使 `--target all` 和 CTest 测试集合一致 | iDRC/iECO/iSTA/iTO/iRCX/platform CMake | 首轮 22 个 `Not Run` 消除，99/99 通过 |
| P1-3：logger 生命周期 | iDRC/iRT logger 改为 RAII `std::ofstream` 值成员；重复 open 会先关闭旧文件；close 后清除 stream 状态；iDRC logger 测试注册到 CTest | `src/operation/iDRC/source/toolkit/logger`、`src/operation/iRT/source/toolkit/logger` | `idrc_logger_exit_test`、`irt_logger_failure_test` |

## 3. 安全与 Agent 调用边界

MCP 写操作现在必须同时满足：

1. `MCP_IEDA_WRITE=1`。
2. `MCP_IEDA_WORKSPACE` 指向存在的已批准工作目录。
3. Tcl 文件 canonical path 位于该 workspace 内，且扩展名为 `.tcl`。
4. iEDA 路径是可执行普通文件。
5. 子进程从 workspace 运行，并受 `MCP_IEDA_TIMEOUT_SECONDS`（默认 3600 秒）约束。

这使 Agent 可以获得受控的单 workspace 调用入口，但不等价于多 design session 隔离；底层全局单例仍是后续服务化阻塞项。

## 4. 构建稳定性整改效果

整改前，CMake 将大量测试可执行文件放入源码树 `bin/`；当共享库更新在构建树时，CTest 会执行旧二进制或无法解析新库。本轮将 CTest 实际命令固定到 `build-aes13/bin/*`，其 RPATH 指向 `build-aes13/lib`。

整改前后：

| 场景 | 整改前 | 整改后 |
|---|---|---|
| `cmake --build ... --target all` | 部分 CTest target 因 `EXCLUDE_FROM_ALL` 缺失 | 已注册 CTest target 随 all 构建 |
| 测试可执行文件位置 | 源码树 `bin/` 与 build tree 混用 | build tree `bin/` |
| 共享库加载 | 可见性依赖源码树旧产物 | 由 build-tree RPATH 闭环 |
| 完整 CTest | 首轮 23 项 `Not Run` | **99 / 99 pass** |

## 5. 未闭环风险

以下项目不应因本轮通过而被标记为已解决：

| 优先级 | 剩余项 | 原因与后续动作 |
|---|---|---|
| P0 | 库层 `LOG_FATAL`/`exit()` | 仍可能由单个错误设计或 Agent 输入终止进程；需按模块改为结构化 `Result/Error`，由 CLI/Tcl 映射退出码。 |
| P0 | 全局单例与多 Agent 会话隔离 | iSTA/iNO/iPNP 等仍缺少 `DesignSession/ToolContext`；需要显式持有 DB、logger、workspace、artifact index。 |
| P1 | artifact 发布/删除 ownership | 仍需 manifest-owned root、原子发布和 symlink/跨文件系统保护。 |
| P1 | CMake 依赖方向与全局 include | 本轮仅解决输出和测试编排；`tool_manager`/`idm` 依赖、全局 include/link directory 仍需分阶段 target-local 化。 |
| P1 | sanitizer/secret scan CI | 已增加负向回归，但尚未建立 ASAN/UBSAN/TSAN、fuzz、SBOM、gitleaks gate。 |
| 签核输入 | foundry DRC、可信 RCX 表、SPEF、VCD/SAIF | 仍需外部受控输入；没有这些输入时相应 QoR 必须保持 fallback/provenance 标识。 |
| 时序能力 | PBA 完整重算/CPPR | 本轮只保护报告路径；PBA/CPPR 算法闭环继续按已有专项任务推进。 |

## 6. 后续验收建议

1. 新增或修改 CTest 时，CI 必须执行 `cmake --build <build> --target all` 后再执行 `ctest`，禁止注册未构建 target。
2. 每晚以 out-of-tree Sanitizer 构建运行 JSON、iSTA 输入解析、外部执行器和 artifact publish 负向测试。
3. 将 MCP 的 workspace、超时、stdout/stderr artifact 和命令结果纳入统一 `CommandResult`/artifact manifest；再启动多 Agent 并发服务化改造。
4. 继续收敛库层 fatal/exit，并将 PBA/CPPR、RCX/SPEF、activity provenance 的能力状态暴露给 Agent。
