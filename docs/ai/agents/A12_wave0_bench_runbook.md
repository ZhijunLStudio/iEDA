# A12 Bench — Wave-0 复跑手册（待代码合入后执行）

> Owner: A12　状态：待命（等 A2/A3/A4/A5/A9 进入 review）

## Daily 子集

- `aes_sky130_a`
- `aes_nangate45_a`

## 建议命令（合入后由 A12 执行）

```bash
cd /home/lxq/AiEDA/iEDA.ai
# 按仓库实际 aes13_flow CLI 调整；示意：
python3 benchmarks/flows/aes13_flow.py \
  --designs aes_sky130_a,aes_nangate45_a \
  --output-dir benchmarks/results/wave0_baseline_$(date +%Y%m%d_%H%M) \
  --threads <parity_protocol>
```

跑完后收集：

| 产物 | 用途 |
|---|---|
| `*/result/rcx/*.spef` 或等价 | A1 R2 |
| `*/result/timing/` + coverage JSON | A1 STA |
| `*/result/power/` + activity_source | A1 Power |
| congestion JSON / report | A1 Cong |
| PDN / pg 相关 DEF | A1 PDN |
| DRC rpt | 观测，不因 residual 假 clean |

## 交付给 A1

`benchmarks/qor/wave0_baseline_manifest.json` 草稿字段：

```json
{
  "run_id": "",
  "binary_sha256": "",
  "input_manifest_sha256": "",
  "designs": ["aes_sky130_a", "aes_nangate45_a"],
  "labels": {
    "setup_wns": "invalid|trusted|proxy",
    "power": "invalid|trusted|proxy",
    "congestion": "invalid|trusted|proxy",
    "drc": "proxy",
    "ir": "invalid"
  },
  "artifact_roots": []
}
```

**在 A0 宣布 Wave-0 代码 ready 前，A12 不启动全量复跑。**
