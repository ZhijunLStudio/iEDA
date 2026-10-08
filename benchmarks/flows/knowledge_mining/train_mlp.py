#!/usr/bin/env python3
"""
train_mlp.py —— MLP 代理模型（surrogate）：(特征, 动作) → 效果

非线性代理，替代线性公式拟合。映射：
    [10 个归一化特征] + [5 个动作 one-hot] + [1 个剂量] → [egr_union_rel, egr_max_rel, hpwl_rel]

训练只看 train split（逻辑设计切分），在 test/ood 上验证：
  1. 预测准确度：Spearman 秩相关 + R²（定量有效性）
  2. 策略改进：MLP 选动作 vs 基线，held-out 中位改善（定性+定量）

用法：
  python3 benchmarks/flows/knowledge_mining/train_mlp.py [--hidden 64,32] [--epochs 2000]
"""

from __future__ import annotations

import argparse
import json
import math
import sys
from collections import defaultdict
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import numpy as np
from sklearn.neural_network import MLPRegressor
from sklearn.preprocessing import StandardScaler
from scipy.stats import spearmanr
import joblib

HERE = Path(__file__).resolve().parent
OUT_DIR = HERE / "output"
DATASET_PATH = OUT_DIR / "dataset.jsonl"
MODEL_PATH = OUT_DIR / "surrogate_mlp.json"
MODEL_PKL = OUT_DIR / "surrogate_mlp.pkl"  # 可回灌的模型权重 + scaler

FEATURES = [
    "fill_rate", "hfanout_ratio", "hfanout_pin_share", "die_aspect",
    "cell_count_log", "net_bbox_span_p90", "vh_ratio", "overflow_ratio",
    "rudy_peak", "rudy_egr_mismatch",
]
ACTION_TYPES = ["compress_td", "congest_ce", "evacuate_region", "evacuate_instance", "timing"]
TARGETS = ["egr_union_rel", "egr_max_rel", "hpwl_rel"]
LABEL_CLIP = 3.0  # 效果裁剪到 [-3, 3]（±300%），防 ce 极端值主导训练


def load_samples() -> List[Dict]:
    if not DATASET_PATH.exists():
        return []
    return [json.loads(l) for l in DATASET_PATH.read_text().splitlines() if l.strip()]


def action_vec(action: Dict) -> np.ndarray:
    """动作 → [one-hot(5), dose(1)]。dose：td / ce/6 / density_target / 0。"""
    at = action.get("type", "")
    p = action.get("params", {}) or {}
    onehot = [1.0 if at == t else 0.0 for t in ACTION_TYPES]
    if at == "compress_td":
        dose = float(p.get("target_density", 0.0))
    elif at == "congest_ce":
        dose = float(p.get("congestion_effort", 0)) / 6.0
    elif at == "evacuate_region":
        dose = float(p.get("density_target", 0.0))
    else:
        dose = 0.0
    return np.array(onehot + [dose], dtype=float)


def build_xy(samples: List[Dict]) -> Optional[Tuple[np.ndarray, np.ndarray]]:
    """只取 ok 样本，构造 X（特征+动作）和 y（裁剪后的效果）。"""
    X_rows, y_rows = [], []
    for s in samples:
        if s.get("run_status") != "ok":
            continue
        feat = []
        ok = True
        for fn in FEATURES:
            v = s["features"].get(fn)
            if v is None:
                ok = False
                break
            feat.append(float(v))
        if not ok:
            continue
        act = action_vec(s["action"])
        label = []
        for tn in TARGETS:
            v = s["labels"].get(tn)
            if v is None:
                ok = False
                break
            label.append(float(np.clip(v, -LABEL_CLIP, LABEL_CLIP)))
        if not ok:
            continue
        X_rows.append(np.concatenate([feat, act]))
        y_rows.append(label)
    if not X_rows:
        return None
    return np.array(X_rows), np.array(y_rows)


def fit_mlp(X: np.ndarray, y: np.ndarray, hidden: Tuple[int, ...], epochs: int) -> Tuple[MLPRegressor, StandardScaler]:
    scaler = StandardScaler().fit(X)
    Xs = scaler.transform(X)
    mlp = MLPRegressor(
        hidden_layer_sizes=hidden,
        activation="relu",
        solver="adam",
        max_iter=epochs,
        early_stopping=True,
        validation_fraction=0.15,
        random_state=42,
    )
    mlp.fit(Xs, y)
    return mlp, scaler


def predict(mlp: MLPRegressor, scaler: StandardScaler, X: np.ndarray) -> np.ndarray:
    return mlp.predict(scaler.transform(X))


def split_samples(samples: List[Dict]) -> Tuple[List[Dict], List[Dict], List[Dict]]:
    train = [s for s in samples if s.get("split") == "train"]
    test = [s for s in samples if s.get("split") == "test"]
    ood = [s for s in samples if s.get("split") == "ood"]
    return train, test, ood


def metrics_report(y_true: np.ndarray, y_pred: np.ndarray) -> Dict[str, float]:
    out = {}
    for i, tn in enumerate(TARGETS):
        a = y_true[:, i]
        b = y_pred[:, i]
        rho = spearmanr(a, b).correlation if len(a) > 2 and np.std(a) > 0 and np.std(b) > 0 else float("nan")
        ss_res = float(np.sum((a - b) ** 2))
        ss_tot = float(np.sum((a - np.mean(a)) ** 2))
        r2 = 1.0 - ss_res / ss_tot if ss_tot > 0 else float("nan")
        out[f"{tn}_spearman"] = round(float(rho), 4) if not math.isnan(rho) else None
        out[f"{tn}_r2"] = round(r2, 4) if not math.isnan(r2) else None
    return out


def policy_improvement(samples: List[Dict], mlp: MLPRegressor, scaler: StandardScaler, w_egr: float = 1.0, w_hpwl: float = 0.5) -> Dict:
    """held-out 策略改进：对每个 (design, seed)，预测所有动作效果，选最优，比基线。"""
    # 按 (design_key, seed) 分组，收集该组的 ok 样本和 baseline 特征
    groups: Dict[tuple, List[Dict]] = defaultdict(list)
    for s in samples:
        if s.get("run_status") == "ok":
            groups[(s["design_key"], s["seed"])].append(s)

    picked_egr, picked_hpwl = [], []
    best_possible_egr, best_possible_hpwl = [], []
    # 单目标策略：分别按 EGR / HPWL / 综合 选动作
    picked_by_egr_hpwl = []  # 只优化 HPWL 时，实际拿到多少 HPWL
    picked_by_hpwl_egr = []  # 只优化 HPWL 时，实际 EGR 代价
    for key, gs in groups.items():
        # 预测该组所有动作的效果
        preds = []
        for s in gs:
            feat = []
            ok = True
            for fn in FEATURES:
                v = s["features"].get(fn)
                if v is None:
                    ok = False
                    break
                feat.append(float(v))
            if not ok:
                continue
            act = action_vec(s["action"])
            x = np.concatenate([feat, act]).reshape(1, -1)
            yhat = predict(mlp, scaler, x)[0]
            preds.append((s, yhat))
        if not preds:
            continue
        # 选预测综合分最高的动作（egr 改善 + hpwl 改善）
        best_s, _ = max(preds, key=lambda p: w_egr * p[1][0] + w_hpwl * p[1][2])
        picked_egr.append(best_s["labels"].get("egr_union_rel") or 0.0)
        picked_hpwl.append(best_s["labels"].get("hpwl_rel") or 0.0)
        # 上界：该组实际最好的 egr/hpwl
        best_possible_egr.append(max((s["labels"].get("egr_union_rel") or 0.0) for s, _ in preds))
        best_possible_hpwl.append(max((s["labels"].get("hpwl_rel") or 0.0) for s, _ in preds))
        # HPWL 单目标：选预测 hpwl 最高的动作
        hpwl_best, _ = max(preds, key=lambda p: p[1][2])
        picked_by_egr_hpwl.append(hpwl_best["labels"].get("hpwl_rel") or 0.0)
        picked_by_hpwl_egr.append(hpwl_best["labels"].get("egr_union_rel") or 0.0)

    return {
        "n_groups": len(picked_egr),
        "picked_egr_median": float(np.median(picked_egr)) if picked_egr else None,
        "picked_hpwl_median": float(np.median(picked_hpwl)) if picked_hpwl else None,
        "picked_egr_improve_rate": float(np.mean([1 if v > 0 else 0 for v in picked_egr])) if picked_egr else None,
        "picked_hpwl_improve_rate": float(np.mean([1 if v > 0 else 0 for v in picked_hpwl])) if picked_hpwl else None,
        "oracle_egr_median": float(np.median(best_possible_egr)) if best_possible_egr else None,
        "oracle_hpwl_median": float(np.median(best_possible_hpwl)) if best_possible_hpwl else None,
        # HPWL 单目标策略：MLP 选 HPWL 最优动作，实际拿到的 HPWL 改善 + EGR 代价
        "hpwl_only_picked_hpwl_median": float(np.median(picked_by_egr_hpwl)) if picked_by_egr_hpwl else None,
        "hpwl_only_picked_egr_median": float(np.median(picked_by_hpwl_egr)) if picked_by_hpwl_egr else None,
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--hidden", default="64,32")
    ap.add_argument("--epochs", type=int, default=2000)
    args = ap.parse_args()

    samples = load_samples()
    if not samples:
        print("[train_mlp] 无样本，先跑 gen_dataset + assemble_dataset", file=sys.stderr)
        return 1
    hidden = tuple(int(x) for x in args.hidden.split(",") if x.strip())

    train, test, ood = split_samples(samples)
    print(f"[train_mlp] 样本: train={len(train)} test={len(test)} ood={len(ood)}", file=sys.stderr)

    Xy = build_xy(train)
    if Xy is None or len(Xy[0]) < 20:
        print("[train_mlp] train 有效样本不足 20，无法训练", file=sys.stderr)
        return 1
    Xtr, ytr = Xy
    print(f"[train_mlp] train 有效对: {len(Xtr)}", file=sys.stderr)

    mlp, scaler = fit_mlp(Xtr, ytr, hidden, args.epochs)

    report = {
        "model": "MLPRegressor",
        "hidden": list(hidden),
        "features": FEATURES,
        "action_types": ACTION_TYPES,
        "targets": TARGETS,
        "label_clip": LABEL_CLIP,
        "train": {"n": len(Xtr), **metrics_report(ytr, predict(mlp, scaler, Xtr))},
    }

    for name, ss in [("test", test), ("ood", ood)]:
        Xy = build_xy(ss)
        if Xy is None or len(Xy[0]) == 0:
            report[name] = {"n": 0}
            continue
        Xs, ys = Xy
        report[name] = {"n": len(Xs), **metrics_report(ys, predict(mlp, scaler, Xs)),
                        "policy": policy_improvement(ss, mlp, scaler)}

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    MODEL_PATH.write_text(json.dumps(report, ensure_ascii=False, indent=2))
    # 保存可回灌的模型权重 + scaler（DSH 插件可加载推理）
    joblib.dump({"mlp": mlp, "scaler": scaler,
                 "features": FEATURES, "action_types": ACTION_TYPES,
                 "targets": TARGETS, "label_clip": LABEL_CLIP}, MODEL_PKL)
    print(f"[train_mlp] 写 {MODEL_PATH}", file=sys.stderr)
    print(f"[train_mlp] 写模型 {MODEL_PKL}（可回灌）", file=sys.stderr)
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
