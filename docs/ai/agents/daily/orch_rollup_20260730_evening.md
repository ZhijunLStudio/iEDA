# A0 Rollup — 2026-07-30（晚间续）

## Done

- 6 个 Wave-0 子 Agent **全部 API limit 失败**，无独立交付；主会话接管。
- `aes13_flow.py`：RCX stage、`--require-spef/--skip-rcx/--fallback-spef`、SPEF 读入 Tcl、`activity_source.json`、`congestion.json`/`congestion_summary.json`、`pdn_status.json`。
- 对已有 AES12@65% `aes_sky130_a` 产物冒烟：cong valid、max_overflow=76；activity=vectorless。
- A11：确认 MoveTxn 已在平台代码中。

## Delta

- Congestion 测量面可可信化（EGR CSV）；**不**等于 DRC/WNS 已改善。
- SPEF：sky130 `ready=false`（无 ITF）。

## Blocked

- B-RCX-ITF：无工艺 ITF/captab → 无法发 STA `trusted`。
- B-AGENT-API：并行子 Agent 不可用。

## Next

1. 补 ITF 或明确 unsupported PDK 矩阵。
2. A1 review 四个 review 态 WP。
3. 勿开 Wave-1 外环，直至 M-T0 部分绿灯。
