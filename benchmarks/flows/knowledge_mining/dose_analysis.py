#!/usr/bin/env python3
"""
dose_analysis.py —— 剂量分析：从实测数据提炼「最优 target_density 随 fill_rate 的分段函数」

直接用实测 compress_td 的 5 档结果（比 MLP 预测更可靠），按 fill_rate 分桶，
每个桶内找 HPWL 改善最大（且 EGR 代价可接受）的 td，提炼 K2 剂量知识。

输出：output/dose_analysis.json + 打印分段函数
"""

from __future__ import annotations

import json
import sys
from collections import defaultdict
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent
OUT_DIR = HERE / "output"
DATASET_PATH = OUT_DIR / "dataset.jsonl"

# fill_rate 分桶边界（基于数据真实分布：sky130 大部分 fill 0.22-0.28，少数 gcd/s1238 fill 0.63-0.70）
FILL_BINS = [(0.0, 0.30, "low_fill(<0.30)"), (0.30, 1.0, "high_fill(>=0.30)")]


def load_samples() -> list:
    if not DATASET_PATH.exists():
        return []
    return [json.loads(l) for l in DATASET_PATH.read_text().splitlines() if l.strip()]


def main():
    samples = load_samples()
    # 只取 train split 的 compress_td ok 样本（避免 test/ood 泄漏）
    td_samples = [s for s in samples
                  if s["split"] == "train"
                  and s["run_status"] == "ok"
                  and s["action"]["type"] == "compress_td"
                  and s["labels"].get("hpwl_rel") is not None
                  and s["labels"].get("egr_union_rel") is not None]

    print(f"[dose_analysis] train compress_td 样本: {len(td_samples)}", file=sys.stderr)

    # 按 fill_rate 分桶
    bins = defaultdict(list)
    for s in td_samples:
        fr = s["features"]["fill_rate"]
        for lo, hi, name in FILL_BINS:
            if lo <= fr < hi:
                bins[name].append(s)
                break

    result = {"bins": []}
    print(f"\n{'fill 分桶':<12} {'n':>4} | {'td':>6} {'HPWL改善':>8} {'EGR代价':>8} | 结论")
    print("-" * 70)
    for lo, hi, name in FILL_BINS:
        ss = bins.get(name, [])
        if not ss:
            continue
        # 按 td 聚合，看每档 td 的中位 HPWL 改善和 EGR 代价
        by_td = defaultdict(list)
        for s in ss:
            td = s["action"]["params"]["target_density"]
            by_td[td].append(s)

        # 每档 td 的统计
        td_stats = {}
        for td, arr in sorted(by_td.items()):
            hpwl = np.median([s["labels"]["hpwl_rel"] for s in arr])
            egr = np.median([s["labels"]["egr_union_rel"] for s in arr])
            n = len(arr)
            td_stats[td] = {"n": n, "hpwl_rel": float(hpwl), "egr_rel": float(egr)}

        # 最优 td = HPWL 改善最大（EGR 代价作为约束参考）
        best_td = max(td_stats, key=lambda t: td_stats[t]["hpwl_rel"])
        best = td_stats[best_td]
        # 次优：EGR 代价最小的 td
        min_egr_td = max(td_stats, key=lambda t: td_stats[t]["egr_rel"])

        result["bins"].append({
            "fill_range": [lo, hi], "n": len(ss),
            "td_stats": td_stats,
            "best_td_for_hpwl": best_td,
            "best_hpwl_rel": best["hpwl_rel"],
            "best_hpwl_egr_cost": best["egr_rel"],
            "min_egr_td": min_egr_td,
        })

        print(f"{name:<12} {len(ss):>4} | "
              f"最优td={best_td:>4.2f} HPWL={best['hpwl_rel']:+.3f} EGR={best['egr_rel']:+.3f} | "
              f"各档: " + " ".join(f"td{t:.2f}→HPWL{v['hpwl_rel']:+.2f}/EGR{v['egr_rel']:+.2f}" for t, v in td_stats.items()))

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    (OUT_DIR / "dose_analysis.json").write_text(json.dumps(result, ensure_ascii=False, indent=2))
    print(f"\n[dose_analysis] 写 output/dose_analysis.json", file=sys.stderr)


if __name__ == "__main__":
    main()
