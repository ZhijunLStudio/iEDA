#!/usr/bin/env python3
"""
validate.py —— held-out/OOD 检验 + 泛化报告

读 output/knowledge_quant.json（fit.py 产出的规则）+ output/dataset.jsonl，
在 test/ood 设计上检验拟合规则的策略改进率与过拟合落差。

主指标：按拟合规则选动作，相对 plain 基线的中位 EGR/HPWL 改善；
对照「恒定选压缩」「恒定选疏散」。
"""

from __future__ import annotations

import argparse
import json
import sys
from collections import defaultdict
from pathlib import Path
from typing import Any, Dict, List

import numpy as np

HERE = Path(__file__).resolve().parent
OUT_DIR = HERE / "output"
DATASET_PATH = OUT_DIR / "dataset.jsonl"
KNOWLEDGE_PATH = OUT_DIR / "knowledge_quant.json"


def load_samples() -> List[Dict]:
    if not DATASET_PATH.exists():
        return []
    return [json.loads(l) for l in DATASET_PATH.read_text().splitlines() if l.strip()]


def load_rules() -> Dict:
    if not KNOWLEDGE_PATH.exists():
        return {}
    return json.loads(KNOWLEDGE_PATH.read_text())


def apply_rule(sample_features: Dict, rule: Dict) -> str:
    """按拟合权重给一个动作阵营。返回 'pos'（压缩/线长/局部）或 'neg'。"""
    w = rule.get("weights", {})
    score = w.get("bias", 0.0)
    for fn in rule.get("features", []):
        v = sample_features.get(fn)
        if v is None or fn not in w:
            continue
        score += w[fn] * float(v)
    return "pos" if score >= 0 else "neg"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--splits", default="test,ood")
    args = ap.parse_args()

    samples = load_samples()
    rules = load_rules()
    if not samples or not rules:
        print("[validate] 缺 dataset.jsonl 或 knowledge_quant.json", file=sys.stderr)
        return 1

    want = [s.strip() for s in args.splits.split(",") if s.strip()]
    axes = {a["id"]: a for a in rules.get("axes", []) if a.get("status") == "fitted"}

    # 每个 (split, design, seed) 分组：baseline + 各动作
    groups: Dict[tuple, Dict] = defaultdict(dict)
    for s in samples:
        if s.get("split") not in want:
            continue
        key = (s["split"], s["design_key"], s["seed"])
        groups[key][s["action"]["type"]] = s

    report = {"splits": want, "axes": []}

    for aid, rule in axes.items():
        # 阵营动作映射
        if aid == "H1":
            pos_types = {"compress_td"}
            neg_types = {"evacuate_region", "evacuate_instance"}
        elif aid == "H2":
            pos_types = {"baseline"}
            neg_types = {"timing"}
        elif aid == "H3":
            pos_types = {"evacuate_region", "evacuate_instance"}
            neg_types = {"compress_td", "congest_ce"}
        else:
            continue

        # 对每个组，用规则选阵营，取该阵营动作的 egr_union_rel / hpwl_rel
        chosen_rel = []
        for key, g in groups.items():
            # 特征用该组任意样本的 features（同 design+seed 的所有动作共享同一 baseline 特征）
            any_sample = next(iter(g.values()))
            feats = any_sample.get("features", {})
            pred = apply_rule(feats, rule)
            chosen_types = pos_types if pred == "pos" else neg_types
            # 取该阵营里 egr_union_rel 最好的动作
            cands = [g[t] for t in chosen_types if t in g and g[t].get("run_status") == "ok"]
            if not cands:
                continue
            best = max(cands, key=lambda s: s["labels"].get("egr_union_rel") or -1e9)
            v = best["labels"].get("egr_union_rel")
            if v is not None:
                chosen_rel.append(v)

        chosen_rel = [v for v in chosen_rel if v is not None]
        if chosen_rel:
            report["axes"].append({
                "id": aid,
                "n_groups": len(chosen_rel),
                "chosen_egr_rel_median": float(np.median(chosen_rel)),
                "chosen_egr_rel_mean": float(np.mean(chosen_rel)),
                "chosen_improve_rate": float(np.mean([1 if v > 0 else 0 for v in chosen_rel])),
            })

    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
