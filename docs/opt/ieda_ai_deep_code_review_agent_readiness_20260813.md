# iEDA.ai 全量源码深度审查与 IC Design Agent 适配性报告

审查时间：2026-08-13 11:40:59 CST (+0800)
审查对象：`/home/lxq/AiEDA/iEDA.ai`
审查范围：`src/` 全部自有代码、接口/脚本、平台层、工具模块、测试与构建配置；第三方目录仅做边界识别，不把第三方实现问题归因于 iEDA 自有代码。

## 1. 执行摘要

当前工作区的最新验证结果是：Release 增量全量构建通过，CTest 92/92 通过。说明当前这份工作区在既定构建树和测试数据下具备较好的编译与回归稳定性。

但“能编译、测试通过”不等价于“适合长期运行的 IC design agent”。静态审查发现，iEDA.ai 仍存在命令执行、进程级 fatal、全局单例生命周期、空指针、JSON/gzip 内存安全、日志路径泄露、产物删除/覆盖等高风险问题。另有 PBA 完整路径重算/CPPR、iPNP region 优化、真实 iTO 历史质量摘要、foundry DRC coverage、可信 RCX/SPEF/VCD/SAIF 等能力依赖外部输入或仍未完成；这些限制必须在 agent 的能力声明和质量门禁中显式标注。

综合判断：

| 维度 | 结论 | 等级 |
|---|---|---|
| 软件结构 | 模块分层清楚，但平台/工具/数据库间存在全局状态耦合 | 中等 |
| 代码风格与可维护性 | 命名和目录大体一致；裸指针、宏单例、重复 logger、未完成 API 较多 | 中等偏低 |
| 可靠性 | 正常输入路径可运行；异常输入和并发场景存在崩溃/状态污染风险 | 高风险 |
| 安全性 | MCP 写权限有显式开关，但其他脚本和 Hmetis 存在 shell 注入面 | 高风险 |
| 数据泄露 | 日志可能暴露绝对源码、工艺库、设计 workspace 路径 | 中高风险 |
| 编译稳定性 | 本次构建与 92 项 CTest 通过；脏工作区/生成物污染会增加复现风险 | 当前通过，治理不足 |
| Agent 调用 | 有 EngineContract、MCP、Tcl/Python 接口基础 | 可试点，尚不宜默认自治 |
| Agent 扩展 | 可通过 contract/manifest 增加工具阶段 | 需要 session 隔离、权限和 artifact 沙箱 |

## 2. 审查方法与证据边界

本次采用三类证据：

1. 静态代码审查：检查模块边界、生命周期、错误处理、命令执行、文件和日志行为、未完成实现及潜在死代码。
2. 定向安全扫描：扫描 `system()`、`shell=True`、`exit()`、`LOG_FATAL`、敏感 token 关键词和源码树内生成物。
3. 动态验证：在 `/tmp/ieda-ai-aes12-65pct-build` 上执行：

```text
cmake --build /tmp/ieda-ai-aes12-65pct-build --target all -j 12
ctest --test-dir /tmp/ieda-ai-aes12-65pct-build --output-on-failure -j 8
```

结果：

| 检查 | 时间 | 结果 |
|---|---|---|
| Release 全量目标增量构建 | 2026-08-13 11:39 左右 | 通过 |
| CTest | 2026-08-13 11:39-11:40 | 92/92 通过，0 失败，总耗时约 20.02 s |
| 静态风险扫描 | 2026-08-13 11:35-11:40 | 发现高/中风险项，详见第 4 节 |

限制：本次没有在报告阶段重新运行所有 PDK/AES 流程、ASAN/UBSAN/TSAN、foundry DRC、真实 RCX/SPEF 或 VCD/SAIF；因此“测试通过”只表示当前注册测试集通过，不能替代签核级验证。

## 3. 架构与模块边界审查

### 3.1 现有结构

源码目录体现出较完整的 EDA 分层：

```text
interface (Tcl/Python/MCP/GUI)
        |
platform (flow / tool_manager / data_manager / report / service)
        |
database + DesignState + file/artifact services
        |
operation (iFP/iPL/iCTS/iRT/iDRC/iSTA/iTO/... )
        |
solver / utility / parser / third_party
```

优点：

- `src/platform/flow/tool_flow/EngineContract.hh:20-75` 已定义工具契约、依赖、产物、失败和 skip 语义，为 agent 观测与回滚提供了可扩展基础。
- `src/interface/contract/interface_inventory.py:134-161` 已有接口扫描和“静默成功/高风险 shell”模式识别，可作为 CI 静态门禁的起点。
- MCP 层 `src/interface/mcp-iEDA/src/mcp_ieda/server.py:21-53` 默认关闭写权限，并使用 argv 列表调用子进程，安全边界优于直接拼接 shell 命令。

主要结构问题：

- `DataManager`、`ToolManager`、`Flow` 均是无锁全局裸指针单例（`src/platform/data_manager/idm.h:52-64`、`src/platform/tool_manager/tool_manager.h:38-51`、`src/platform/flow/flow.h:40-61`），设计上下文、日志和工具状态容易跨任务共享。
- 接口层、平台层、工具内部仍大量直接调用全局对象和 `LOG_FATAL`，错误语义没有统一收敛到 `Result/Error` 或 session context。
- 同一套 logger 在 iRT/iDRC 等模块重复实现，资源和脱敏策略难以统一。
- 源码树内存在 `__pycache__`、Rust/CMake target 产物和对象文件，表明构建隔离和产物清理约束不够强；这会干扰审查、打包和可复现构建。

结构结论：模块目录划分合理，平台能力已经具备 agent contract 的雏形；但状态管理仍是“单进程单设计”思路，尚未达到多会话/多 agent 安全运行要求。

## 4. 严重度分级发现

### P0：必须在默认 agent 化前修复

| 编号 | 发现与证据 | 影响 | 建议 |
|---|---|---|---|
| P0-1 | Hmetis 通过拼接字符串调用 `system()`：`src/operation/iPL/source/solver/partition/Hmetis.cc:24-49`；路径和枚举参数来自 setter | 配置、脚本或 agent 输入可构造 shell 命令，形成任意命令执行；外部命令失败后仍读取旧 `.part.*` 文件（58-64），可能污染结果 | 改为 `fork+execv/posix_spawn` argv；对白名单校验枚举；每次使用唯一临时目录；失败时清空结果并校验结果行数等于 `vertex_num` |
| P0-2 | 库级 API 和 logger 用 `LOG_FATAL`/`exit()` 处理用户可触发错误：`src/operation/iSTA/api/TimingEngine.cc:156-159,197-204,270-272,430-489`；`src/operation/iRT/source/toolkit/logger/Logger.hpp:71-75`；`src/operation/iDRC/source/toolkit/logger/Logger.hpp:77-83` | 一个坏 pin/net/lib/RC 输入就能杀死整个 agent 进程，无法隔离任务、回滚或继续其他设计 | 库层返回结构化错误或抛受控异常；CLI/Tcl 层再决定退出；区分“用户输入错误”和“内部不变量”；增加负向测试确保 API 不退出进程 |
| P0-3 | 全局单例和生命周期无锁：`TimingEngine`/`Sta` 使用全局裸指针，`src/operation/iSTA/api/TimingEngine.cc:61-89`、`src/operation/iSTA/source/module/sta/Sta.cc:95-130`；iNO/iPNP 也有同类模式 | 并发 agent 可能跨设计污染、销毁中的 use-after-free、日志相互重初始化 | 引入 per-design/session context；无状态服务才保留单例；用 RAII/shared_ptr 管理生命周期；禁止任务运行中 destroy；用 TSAN 验证并发 init/destroy |

### P1：应在扩大 agent 权限前修复

| 编号 | 发现与证据 | 影响 | 建议 |
|---|---|---|---|
| P1-1 | Python 脚本直接执行字符串命令：`src/operation/iSTA/source/data/script/run_iEDA.py:36-37`，`subprocess.run(..., shell=True)`，且二进制路径硬编码 `/data/yexinyu/iEDA/bin/iSTA` | 路径注入、部署不可移植、无法可靠传递退出码/超时 | 使用 argv 列表、显式 `ieda` 参数、超时和资源限制；禁止从用户字符串拼接命令 |
| P1-2 | 明确空指针路径：`src/platform/tool_manager/tool_api/ista_io/ista_io.cpp:444-451` 在 `instance == nullptr` 时仍调用 `instance->getFullName()`；`pin` 为空时解引用 `(*pin)` | 异常拓扑、ECO 断连或 agent 错误对象名可触发崩溃 | 日志只打印原始输入名；对 optional/lookup 统一返回错误；增加断连 pin、缺失 arc 回归 |
| P1-3 | `StaReport` 对空 arc 解引用：`src/operation/iSTA/source/module/sta/StaReport.cc:1034-1038,1090-1094` | 缺失 sink arc 时报告阶段崩溃，影响长流程收尾 | `empty()` 时生成结构化缺边记录并跳过/失败，不调用 `nullptr->exec()` |
| P1-4 | JSON/gzip 工具存在泄漏、越界读和 UAF：`src/utility/json/json_parser.h:76-83,86-117,119-128` | 长时间服务稳定泄漏；损坏/恶意 gzip 输入可能越界读或返回已释放内存 | 返回值对象/`unique_ptr`；按 `bytes_read` 构造字符串；读失败直接返回错误；ASAN/UBSAN 覆盖空、截断和超大 gzip |
| P1-5 | logger 资源生命周期不安全：`src/operation/iRT/source/toolkit/logger/Logger.hpp:37-49`、iDRC 同类；close 后不置空，重复 open 覆盖旧指针 | 重复 open/close 或异常路径泄漏、二次 delete、悬空指针 | 使用 `std::unique_ptr<std::ofstream>` 或值成员；close 后置空；重复 open 先关闭旧文件；添加生命周期单测 |
| P1-6 | 产物目录存在非托管删除/覆盖：`src/operation/iSTA/source/module/sta/Sta.cc:3387-3395` 删除 `wire_paths` 下所有普通文件；`src/platform/flow/tool_flow/FlowScheduler.cpp:950-955` 发布 checkpoint 前先 remove 目标 | 配置错误或路径复用可能删除用户文件；rename 失败可能损坏已有结果 | 所有产物写入受控 artifact root；只删除 manifest 记录的自有文件；同目录临时文件 + 原子替换；覆盖前保留旧版本 |
| P1-7 | 日志暴露绝对路径和工艺库/设计信息：`src/operation/iRT/source/toolkit/logger/Logger.hpp:119-145`、`src/operation/iDRC/source/toolkit/logger/Logger.hpp:130-155`、`src/operation/iSTA/source/module/sta/Sta.cc:3371-3376` | 共享日志或 agent artifact 可能泄露客户 workspace、源代码路径、liberty 路径 | 增加 service/agent 日志模式；默认相对路径和脱敏；可配置日志根目录；崩溃 dump 限制权限并增加脱敏测试 |
| P1-8 | shell/exit/FATAL 扫描显示多处非测试路径仍直接终止：如 `src/operation/iTO/source/timing_engine/timing_engine_builder.cpp:141`、`src/operation/iPL/source/module/post_global_placer/PostGP.cc:258,365,559` | 长任务中单个坏对象变成整个进程失败，降低 agent 可恢复性 | 建立“进程终止调用白名单”；除 CLI 顶层外禁止 `exit()`；把工具失败转换为 contract failure |

### P2：质量与可维护性改进

| 编号 | 发现 | 建议 |
|---|---|---|
| P2-1 | MCP 虽有 `MCP_IEDA_WRITE` 开关，但 `script_path` 只做存在性检查，未限制在允许 workspace；`iEDA_RUN_EXAMPLE` 通过字符串拼接例子路径（`server.py:105-120`） | 增加 realpath + allowlist workspace、symlink 检查、文件大小/扩展名限制、超时/CPU/内存配额 |
| P2-2 | `interface_inventory.py` 已识别 `shell=True`、literal success、empty implementation 等模式，但当前更多是报告，不是强制门禁 | 将 critical/high finding 接入 CI；新增 baseline 文件和豁免到期机制 |
| P2-3 | Rust 子模块仍有 `dead_code` 警告；源码树存在 `__pycache__` 和编译中间物 | 所有构建使用独立 out-of-tree 目录；将生成物加入 ignore；CI 运行 `-Werror` 子集、clang-tidy、cargo clippy |
| P2-4 | 接口返回值和产物 schema 并非所有路径都强制校验，容易出现“日志成功但产物缺失” | 所有工具通过 EngineContract 声明输入、输出、schema、hash、失败语义；默认启用 artifact existence/schema gate |

## 5. 可靠性与编译稳定性

### 5.1 当前动态结果

本次最新构建和测试通过，说明当前工作区在已有构建目录上是可工作的。但工作区同时包含大量已修改文件和构建产物（`git status --short` 可见 `build-*`、Rust target、Python 缓存等），因此复现时必须使用干净的 out-of-tree 构建目录。此前审查还观察到 PBA 头文件短暂缺失导致编译失败，随后文件重新出现；这类源文件完整性波动属于未提交改动/并行 agent 操作带来的稳定性风险，不应在 CI 中接受。

### 5.2 建议的编译门禁

1. 使用干净 checkout + 独立构建目录，禁止将对象、缓存和 `__pycache__` 写回 `src/`。
2. 分离“主程序构建”和“测试构建”，每个测试 target 必须显式声明公共 include、库和运行时依赖。
3. 启用 `-Wall -Wextra -Wpedantic` 的可落地子集；把未初始化、越界、use-after-free 类告警升为错误。
4. 每周至少一次 ASAN/UBSAN，每月一次 TSAN；对 JSON/gzip、ECO、报告导出、并发 lifecycle 做专项。
5. 将 `ctest` 结果、编译器版本、CMake cache 摘要、工具 hash 和 PDK manifest 写入实验 manifest。

## 6. 数据泄露与供应链边界

### 6.1 已确认的泄露面

- 日志中可能包含绝对源文件路径、设计 workspace、liberty 文件名和运行环境信息。
- MCP 返回结果中直接回显 `iEDA` 和 `script_path`（`server.py:46-52`），在多租户环境应避免返回真实绝对路径。
- `src/utility/notification/NotificationUtility.*` 支持从 `IEDA_ECOS_NOTIFICATION_SECRET` 读取 Bearer token；当前扫描未发现硬编码 token，但必须避免在日志中打印请求头或配置对象。
- 崩溃 dump 固定写入 `glog_dump.log` 的模式可能把调用栈和路径写入共享目录，需由运行时配置控制。

### 6.2 建议的数据边界

| 数据 | agent 默认策略 |
|---|---|
| RTL/LEF/DEF/Liberty/SPEF/VCD/SAIF 原文 | 只允许在 session workspace 内读取 |
| 绝对路径 | 返回脱敏 ID，不回显真实路径 |
| 工艺库与 PDK 名称 | 允许返回逻辑名称；物理路径需受控 |
| 日志/trace | 每 session 独立目录，默认 0600 |
| artifact | manifest + SHA256 + schema 校验后才可发布 |
| notification token | 仅从环境/secret store 注入，禁止进入日志和 JSON 报告 |

## 7. IC Design Agent 调用与扩展适配性

### 7.1 当前可复用能力

- EngineContract 已覆盖工具依赖、产物、失败和 skip 语义，可直接作为 agent action schema 的基础。
- MCP 默认写关闭，具备显式授权开关；适合先做只读观测工具，再逐步开放写动作。
- Tcl/Python 接口数量丰富，适合把既有流程封装为有限动作集合。
- DesignState/MoveTxn 提供事务概念，可作为 ECO/placement/routing 修改的回滚基础。

### 7.2 当前阻断项

1. 单例和全局数据库使多个 agent/session 难以隔离。
2. `LOG_FATAL`/`exit()` 破坏任务级错误恢复。
3. 命令执行和文件路径边界未统一，存在 shell 注入和越界写风险。
4. 产物质量仍可能停留在“流程完成”，没有统一 signoff gate。
5. PBA、region PNP、真实 iTO 历史质量和 foundry/RCX/activity 输入仍不完整，不能作为自动优化奖励的可信真值。

### 7.3 建议的 agent 能力分级

| 级别 | 允许能力 | 进入条件 |
|---|---|---|
| L0 只读观测 | 读取 metrics、阶段图、contract、artifact manifest | 默认可开 |
| L1 受限实验 | 修改白名单配置并在隔离 workspace 运行 | 完成路径沙箱、超时、资源配额 |
| L2 事务修改 | ECO/placement/route 修改，支持 commit/abort | 完成 session context、事务回滚和负向测试 |
| L3 默认自治 | 跨阶段自动搜索并晋升策略 | 完成质量 gate、holdout、审计日志和多设计并发验证 |

当前建议：最多开放 L0，经过 sandbox 和错误语义整改后开放 L1；暂不开放 L2/L3 默认自治。

## 8. 修复路线图

### P0（1-2 周）

- 消除 Hmetis 和脚本中的 shell 拼接，建立安全 subprocess helper。
- 将库层 `LOG_FATAL`/`exit()` 收敛到结构化错误；保留 CLI 顶层退出。
- 引入 per-session/per-design context，至少让 TimingEngine/Sta/DataManager 不共享可变设计状态。
- 修复 JSON/gzip 所有权和错误路径，开启 ASAN/UBSAN 回归。
- 建立 artifact root、manifest、原子发布和路径/symlink 防护。

### P1（2-4 周）

- 统一 logger 实现和生命周期；默认脱敏路径，禁止 token/绝对 workspace 泄露。
- 为缺 pin、缺 net、缺 arc、缺 liberty、损坏 SPEF/JSON 添加负向测试。
- 用 TSAN 验证并发 init/destroy、并发日志、并发只读查询。
- 将 `interface_inventory.py` critical/high 发现接入 CI 阻断。

### P2（4-8 周）

- 完成 PBA 真实路径提取、完整路径重算、CPPR 与 golden regression；在此之前对外标记 `unsupported`。
- 让 iPNP region 优化要么实现真实 region objective，要么显式返回 unsupported，不能静默 global fallback。
- 为 iTO 历史摘要接入真实 phase artifact；零值只能作为“无数据”而不能冒充质量结果。
- 接入可信 foundry DRC coverage、RCX 工艺表、SPEF 回标、VCD/SAIF 活动和 IR 电流模型。

## 9. 验收标准

| Gate | 通过标准 |
|---|---|
| Build | 干净 out-of-tree Release 构建，无关键未初始化/UB 告警 |
| Test | 注册 CTest 全部实际运行；ASAN/UBSAN/TSAN 专项通过 |
| Security | 无自有代码 `system()`/`shell=True`；路径 allowlist 和 symlink 测试通过 |
| Reliability | 缺失对象、坏输入、工具失败均返回结构化错误，不杀死宿主 agent |
| Isolation | 两个设计/两个 session 并发运行无状态、日志、artifact 交叉污染 |
| Data handling | 绝对路径、token、客户 workspace 默认脱敏 |
| Artifact | 所有产物有 manifest、schema、hash、owner；发布过程原子且不误删 |
| IC agent readiness | 至少达到 L1；L2/L3 需通过事务、回滚、holdout 和质量 gate |

## 10. 最终结论

iEDA.ai 已经具备较完整的物理实现工具链和 agent 接口雏形，当前工作区的构建和 92 项 CTest 均通过，适合继续做只读观测和受限实验编排。

但从长期运行、异常恢复、安全边界、数据隔离和可扩展自治的角度，仍不能把它当作默认可信的 IC design agent 执行内核。优先修复 P0 的 shell 注入、进程级 fatal、全局生命周期和文件/内存安全问题，再开放 L1 受限写操作；PBA/CPPR、真实 PNP region、真实 iTO 历史质量及 foundry/RCX/activity 输入完成后，才具备向更高自治级别演进的证据基础。
