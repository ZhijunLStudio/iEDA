#!/usr/bin/env python3
"""
assemble_dataset.py —— 特征计算 + 样本组装

读 gen_dataset.py 的 run_cache.jsonl（每 run 的权威 metrics），
计算 pre_pl / post_baseline 特征，组装成 output/dataset.jsonl 的结构化样本。

用法：
  python3 benchmarks/flows/knowledge_mining/assemble_dataset.py [--out-root <runs>]

样本只在 features + metrics 都齐全时写入；run_status != ok 的样本保留标记。
"""

from __future__ import annotations

import argparse
import json
import math
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

REPO_ROOT = Path(__file__).resolve().parents[3]
FLOWS = REPO_ROOT / "benchmarks" / "flows"
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(FLOWS))

import features as FEAT  # noqa: E402
from gen_dataset import (  # noqa: E402
    DATASET_PATH, OUT_DIR, collect_rudy, load_json, read_jsonl, append_jsonl,
    PYTHON, CONG_OBSERVE, run_json, run_cmd,
)


def relative(base: Optional[float], after: Optional[float]) -> Optional[float]:
    """(baseline - after)/baseline，正=改善；任一 None 或 base=0 返回 None。"""
    if base is None or after is None or base == 0:
        return None
    return (base - after) / base


def build_labels(base: Dict, after: Dict) -> Dict[str, Optional[float]]:
    be = base.get("egr") or {}
    ae = after.get("egr") or {}
    return {
        "egr_union_rel": relative(be.get("egr_total_overflow_union"), ae.get("egr_total_overflow_union")),
        "egr_max_rel": relative(be.get("egr_max_overflow_union"), ae.get("egr_max_overflow_union")),
        "egr_avg_rel": relative(be.get("egr_avg_overflow_union"), ae.get("egr_avg_overflow_union")),
        "hpwl_rel": relative(base.get("hpwl"), after.get("hpwl")),
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out-root", default=str(OUT_DIR / "runs"))
    ap.add_argument("--split", default="train,test,ood")
    ap.add_argument("--seed", default="1000,2000,3000")
    args = ap.parse_args()

    designs_reg = load_json(FLOWS / "deepseek_harness" / "designs.json")
    split_cfg = load_json(HERE / "split.json")

    want_splits = [s.strip() for s in args.split.split(",") if s.strip()]
    seeds = [int(s) for s in args.seed.split(",") if s.strip()]
    out_root = Path(args.out_root)

    # 载入缓存：key -> result
    cache: Dict[str, Dict] = {}
    for line in read_jsonl(OUT_DIR / "run_cache.jsonl"):
        if line.get("key"):
            cache[line["key"]] = line.get("result", {})

    # 预计算 pre_pl 特征（每设计一次，跨 seed 共享）
    pre_pl_cache: Dict[str, Dict] = {}
    for dk, rec in designs_reg.items():
        if not Path(rec.get("input_def", "")).exists():
            continue
        if not Path(rec.get("lef", "")).exists():
            continue
        try:
            pre_pl_cache[dk] = FEAT.pre_pl_features(rec["input_def"], rec["lef"])
        except Exception as e:  # noqa: BLE001
            print(f"[warn] pre_pl 特征失败 {dk}: {e}", file=sys.stderr)
            pre_pl_cache[dk] = {}

    n_written = 0
    n_skipped = 0
    for sp in want_splits:
        for e in split_cfg.get(sp, []):
            dk = e["design_key"]
            rec = designs_reg.get(dk)
            if not rec:
                continue
            foundry = rec.get("foundry_dir") or str(REPO_ROOT / "scripts" / "foundry" / rec["pdk"])
            logical = e["logical_design"]
            pp = pre_pl_cache.get(dk, {})

            for seed in seeds:
                # baseline metrics（post_baseline 特征的来源）
                base_key = f"{dk}|baseline|{seed}|"
                base_metrics = None
                for k, v in cache.items():
                    if k.startswith(base_key):
                        base_metrics = v
                        break
                if not base_metrics:
                    continue

                # post_baseline 特征：baseline placement.def + RUDY + baseline EGR
                base_def = out_root / dk / f"baseline_seed{seed}" / "placement.def"
                post = {}
                if base_def.exists():
                    # 优先复用 gen_dataset 阶段已写的 congestion_result.json（避免重跑 iEDA）
                    cj = out_root / dk / f"baseline_seed{seed}" / "congestion_result.json"
                    if cj.exists():
                        cd = json.loads(cj.read_text())
                        rudy = {
                            "bin_cnt": [cd.get("bin_cnt_x", 64), cd.get("bin_cnt_y", 64)],
                            "rudy_overflow_bin_count": cd.get("rudy_overflow_bin_count"),
                            "rudy_utilization_max": cd.get("rudy_utilization_max"),
                            "rudy_utilization_h_max": cd.get("rudy_utilization_h_max"),
                            "rudy_utilization_v_max": cd.get("rudy_utilization_v_max"),
                        }
                    else:
                        rudy = collect_rudy(rec, foundry, out_root / dk / f"baseline_seed{seed}", base_def)
                    egr = base_metrics.get("egr") or {}
                    try:
                        post = FEAT.post_baseline_features(str(base_def), rudy, egr)
                    except Exception as ex:  # noqa: BLE001
                        print(f"[warn] post_baseline 特征失败 {dk} seed{seed}: {ex}", file=sys.stderr)

                # 每个动作组装样本
                for k, metrics in cache.items():
                    if not k.startswith(f"{dk}|") or f"|{seed}|" not in k:
                        continue
                    action = k.split("|")[1]
                    if action == "baseline":
                        continue  # baseline 本身不算动作样本（它是参照）
                    # 拼接 sample_id / action type / params
                    act_type = action
                    params: Dict[str, Any] = {}
                    if action.startswith("compress_td"):
                        act_type = "compress_td"
                        params["target_density"] = float(action.split("td")[1])
                    elif action.startswith("congest_ce"):
                        act_type = "congest_ce"
                        params["congestion_effort"] = int(action.split("ce")[1])
                    elif action.startswith("evacuate_region"):
                        act_type = "evacuate_region"
                        # evacuate_region_g07 -> 0.7；旧 evacuate_region（无 _g）是 density 0.5
                        if "_g" in action:
                            params["density_target"] = float(action.split("_g")[1]) / 10.0
                        else:
                            params["density_target"] = 0.5
                    elif action.startswith("evacuate_instance"):
                        act_type = "evacuate_instance"
                    elif action == "timing":
                        act_type = "timing"

                    after_metrics = metrics
                    labels = build_labels(base_metrics, after_metrics) if base_metrics else {}

                    sample = {
                        "sample_id": f"{logical}__{action}__seed{seed}",
                        "logical_design": logical,
                        "design_key": dk,
                        "pdk": rec.get("pdk"),
                        "split": sp,
                        "seed": seed,
                        "action": {"type": act_type, "params": params},
                        "run_status": after_metrics.get("run_status", "unknown"),
                        "features": {**pp, **post,
                                     "cell_count_log": math.log(pp["cell_count"]) if pp.get("cell_count", 0) > 0 else None},
                        "metrics": {
                            "baseline": {"egr": base_metrics.get("egr", {}), "hpwl": base_metrics.get("hpwl")},
                            "after": {"egr": after_metrics.get("egr", {}), "hpwl": after_metrics.get("hpwl")},
                        },
                        "labels": labels,
                    }
                    append_jsonl(DATASET_PATH, sample)
                    n_written += 1

    print(f"[assemble] 写入 {n_written} 样本 → {DATASET_PATH}", file=sys.stderr)


if __name__ == "__main__":
    main()
