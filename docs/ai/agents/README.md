# AES12 QoR 多 Agent 工作区

| 文件 | 用途 |
|---|---|
| [`../44-aes12-qor-agent-team-orchestration.md`](../44-aes12-qor-agent-team-orchestration.md) | 团队架构、依赖、门禁、节奏 |
| [`../43-aes12-65pct-qor-optimization-roadmap.md`](../43-aes12-65pct-qor-optimization-roadmap.md) | 算法/WP 路线图（**rv1.1：C++ 主战场**） |
| [`COORDINATION_BOARD.md`](COORDINATION_BOARD.md) | **唯一进度真相源** |
| [`prompts/`](prompts/) | A0–A12 启动提示词（开新会话时整份粘贴） |
| `daily/` | 各 Agent 日报 |
| `rfc/` | 跨工具契约 RFC |

## 交付定义（rv1.1）

- **主战场**：`src/operation/<tool>/`（及必要 `src/platform/`）的 **C++ 算法改造**
- **主目标**：AES 12 项 @ **实测 65%** 下，WNS / Fmax / Power / EGR WL / DRC / IR-drop 相对可信基线 **≥20%**
- **不算 Done**：只改 flow / BEST_EFFORT / MAX_BOXES / util DOE / 软跳过

## 快速启动（rv1.1）

按下列顺序开会话，每个会话只贴对应 `prompts/A*.md`：

1. **A0** + **A1**（编排 + 质量，常驻；工单必须带 `src_paths=`）
2. Wave-0 真值并行：**A2 rcx / A3 sta / A4 pa / A9 pnp / A11 plat / A12 bench**
3. **Wave-1 DRC/WL 与 Wave-0 有限并行（rv1.1）**：**A5 rt → WP-RT-01**、**A6 drc**、**A7 pl**（DRC 门禁不依赖 SPEF；WNS/Power ≥20% 仍等 SPEF 绿）
4. Wave-2（SPEF 可信后）：**A8 tocts**
5. Wave-3：**A10 ir**（A9 进入 PNP-01）

旧计划 `docs/ai/agent_team_plan.md` / `agent-team-plan.md` 仅作历史参考。
