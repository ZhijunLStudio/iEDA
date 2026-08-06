# A1 Verdict — WP-RCX-01（SPEF flow）

> 审查对象：[A2 rcx](47c07241-662f-4f9d-8f0e-0aa4a92057f4)
> 日期：2026-07-30

## Verdict: **ACCEPT（flow 契约） / SPEF 真值仍 BLOCKED**

| 检查 | 结果 |
|---|---|
| routing→rcx→timing 顺序 | Pass |
| 缺 ITF 默认 soft-skip（零回归） | Pass |
| `--require-spef` 响亮失败 | Pass（契约正确） |
| `rcx_coverage.json` / C-SPEF RFC | Pass |
| prepare-only 生成 rcx_config + run_rcx.tcl | Pass（冒烟） |
| 真实 SPEF / net delay>0 | **Fail / Blocked** — 无 ITF/captab |
| fallback gcd.spef | 仅允许 `proxy`，**禁止** WNS `trusted` |

## 标签

| 产物 | 标签 |
|---|---|
| Flow RCX 接线 | done |
| SPEF 文件（当前环境） | **invalid / missing** |
| `--fallback-spef` | **proxy only** |
| STA WNS/Fmax | 仍 **invalid** 直至真实 SPEF |

## 协调板动作

- WP-RCX-01 → `done`（工程交付）
- 阻塞 **B-RCX-ITF** 保持 open（Foundary 合入 ITF/captab）
- C-SPEF → `accepted-draft`（契约可用；trusted 门禁未绿）
