#!/usr/bin/env python3
"""
predict_action.py —— 可回灌的推理接口：给定设计特征，预测每个动作的效果并选最优

这是知识沉淀的最终产物接口：DSH 插件（或 agent 决策层）加载 surrogate_mlp.pkl，
输入当前设计的归一化特征，输出「每个动作的预测 EGR/HPWL 效果 + 推荐动作」。

用法：
  python3 benchmarks/flows/knowledge_mining/predict_action.py \
      --fill_rate 0.25 --hfanout_ratio 0.03 --hfanout_pin_share 0.25 \
      --die_aspect 1.0 --cell_count 5000 --net_bbox_span_p90 0.4 \
      --vh_ratio 1.1 --overflow_ratio 0.05 --rudy_peak 2.5 --rudy_egr_mismatch 0.2 \
      [--objective hpwl|egr|balanced]
"""

from __future__ import annotations

import argparse
import json
import math
import sys
from pathlib import Path

import joblib
import numpy as np

HERE = Path(__file__).resolve().parent
MODEL_PKL = HERE / "output" / "surrogate_mlp.pkl"


def load_model():
    if not MODEL_PKL.exists():
        raise FileNotFoundError(f"未找到模型 {MODEL_PKL}；先跑 train_mlp.py")
    return joblib.load(MODEL_PKL)


def predict_actions(bundle, features: dict, objective: str = "balanced"):
    """给定特征 dict，返回每个动作的预测效果 + 推荐。

    objective: hpwl=只优化 HPWL, egr=只优化 EGR, balanced=综合
    """
    mlp = bundle["mlp"]
    scaler = bundle["scaler"]
    feat_names = bundle["features"]
    action_types = bundle["action_types"]

    # 构造特征向量
    feat_vec = []
    for fn in feat_names:
        v = features.get(fn)
        if v is None:
            raise ValueError(f"缺少特征 {fn}")
        feat_vec.append(float(v))

    # 动作候选（固定动作空间 + 剂量）
    # compress_td 档位、ce、疏散
    candidates = []
    for td in [0.80, 0.85, 0.90, 0.95]:
        candidates.append(("compress_td", {"target_density": td}))
    candidates.append(("evacuate_region", {"density_target": 0.8}))
    candidates.append(("baseline", {}))  # 不动作

    results = []
    for at, params in candidates:
        onehot = [1.0 if at == t else 0.0 for t in action_types]
        if at == "compress_td":
            dose = params["target_density"]
        elif at == "congest_ce":
            dose = params.get("congestion_effort", 0) / 6.0
        elif at == "evacuate_region":
            dose = params.get("density_target", 0.0)
        else:
            dose = 0.0
        x = np.concatenate([feat_vec, onehot, [dose]]).reshape(1, -1)
        yhat = mlp.predict(scaler.transform(x))[0]
        egr_union, egr_max, hpwl = yhat[0], yhat[1], yhat[2]
        score = {"hpwl": hpwl, "egr": egr_union, "balanced": 0.5 * egr_union + 0.5 * hpwl}[objective]
        results.append({
            "action": at, "params": params,
            "pred_egr_union_rel": round(float(egr_union), 4),
            "pred_egr_max_rel": round(float(egr_max), 4),
            "pred_hpwl_rel": round(float(hpwl), 4),
            "_score": score,
        })

    results.sort(key=lambda r: -r["_score"])
    best = results[0]
    return {
        "objective": objective,
        "recommended_action": best["action"],
        "recommended_params": best["params"],
        "predicted_effect": {
            "egr_union_rel": best["pred_egr_union_rel"],
            "egr_max_rel": best["pred_egr_max_rel"],
            "hpwl_rel": best["pred_hpwl_rel"],
        },
        "all_candidates": [{k: v for k, v in r.items() if k != "_score"} for r in results],
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--fill_rate", type=float, required=True)
    ap.add_argument("--hfanout_ratio", type=float, default=0.0)
    ap.add_argument("--hfanout_pin_share", type=float, default=0.0)
    ap.add_argument("--die_aspect", type=float, default=1.0)
    ap.add_argument("--cell_count", type=float, required=True)
    ap.add_argument("--net_bbox_span_p90", type=float, default=0.0)
    ap.add_argument("--vh_ratio", type=float, default=0.0)
    ap.add_argument("--overflow_ratio", type=float, default=0.0)
    ap.add_argument("--rudy_peak", type=float, default=0.0)
    ap.add_argument("--rudy_egr_mismatch", type=float, default=0.0)
    ap.add_argument("--objective", choices=["hpwl", "egr", "balanced"], default="balanced")
    args = ap.parse_args()

    bundle = load_model()
    features = {
        "fill_rate": args.fill_rate,
        "hfanout_ratio": args.hfanout_ratio,
        "hfanout_pin_share": args.hfanout_pin_share,
        "die_aspect": args.die_aspect,
        "cell_count_log": math.log(args.cell_count) if args.cell_count > 0 else 0.0,
        "net_bbox_span_p90": args.net_bbox_span_p90,
        "vh_ratio": args.vh_ratio,
        "overflow_ratio": args.overflow_ratio,
        "rudy_peak": args.rudy_peak,
        "rudy_egr_mismatch": args.rudy_egr_mismatch,
    }
    out = predict_actions(bundle, features, args.objective)
    print(json.dumps(out, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
