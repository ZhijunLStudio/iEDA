#!/usr/bin/env python3
"""
fit.py —— 拟合阈值/剂量（numpy 手写逻辑回归 + 岭回归，无 sklearn 依赖）

输入：output/dataset.jsonl（assemble_dataset.py 产出）
输出：output/knowledge_quant.json（学出的定量规则，回灌插件 K2/K3）

对每条决策轴拟合一个 logistic 分类器（决策边界 = 学出的阈值）+ 剂量回归。
所有数值来自训练集，prior_spec.json 里 null 字段由本文件填，无硬编码。
"""

from __future__ import annotations

import argparse
import json
import math
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import numpy as np

HERE = Path(__file__).resolve().parent
OUT_DIR = HERE / "output"
DATASET_PATH = OUT_DIR / "dataset.jsonl"
KNOWLEDGE_PATH = OUT_DIR / "knowledge_quant.json"

# 决策轴的「谁赢」判定：用哪个 label 定胜负
# H1: compress(压缩) vs evacuate(疏散)；H2: wirelength(线长) vs timing(时序)；H3: local(局部) vs global(全局)


def load_samples() -> List[Dict]:
    if not DATASET_PATH.exists():
        return []
    return [json.loads(l) for l in DATASET_PATH.read_text().splitlines() if l.strip()]


# ── 手写 logistic 回归（牛顿法，稳定）────────────────────────────
def logistic_fit(X: np.ndarray, y: np.ndarray, max_iter: int = 200, l2: float = 1.0) -> np.ndarray:
    """二分类 logistic，X 含 bias 列（第一列全 1）。返回权重向量 [bias, w1, ...]."""
    n, d = X.shape
    w = np.zeros(d)
    for _ in range(max_iter):
        z = X @ w
        p = 1.0 / (1.0 + np.exp(-np.clip(z, -30, 30)))
        g = X.T @ (p - y) / n + l2 * w / n
        # 牛顿法 Hessian：加权设计矩阵 X'WX（W=diag(p(1-p))）
        W = p * (1.0 - p)
        Xw = X * W[:, None]
        h = X.T @ Xw / n + l2 * np.eye(d) / n
        try:
            step = np.linalg.solve(h, g)
        except np.linalg.LinAlgError:
            step = g * 0.1
        w -= step
        if np.max(np.abs(step)) < 1e-8:
            break
    return w


def logistic_predict(X: np.ndarray, w: np.ndarray) -> np.ndarray:
    z = X @ w
    return 1.0 / (1.0 + np.exp(-np.clip(z, -30, 30)))


# ── 手写岭回归（闭式解）──────────────────────────────────────────
def ridge_fit(X: np.ndarray, y: np.ndarray, l2: float = 1.0) -> np.ndarray:
    n, d = X.shape
    A = X.T @ X + l2 * np.eye(d)
    b = X.T @ y
    return np.linalg.solve(A, b)


# ── 样本按轴聚成二分类对 ────────────────────────────────────────
def axis_pairs(samples: List[Dict], axis_id: str, split: str) -> Optional[Tuple[np.ndarray, np.ndarray, List[str], List[Dict]]]:
    """把样本聚成「该轴两个动作谁更优」的二分类样本。

    返回 (X_with_bias, y, feature_names, rows)。y=1 表示第一类动作赢（compress/wirelength/local）。
    胜负用 Pareto：先比 egr_union_rel（正=改善），再比 hpwl_rel。
    """
    from collections import defaultdict

    spec = json.loads((HERE / "prior_spec.json").read_text())
    ax = next((a for a in spec["axes"] if a["id"] == axis_id), None)
    if ax is None:
        return None

    name = ax["name"]
    # 动作类型 → 阵营
    if axis_id == "H1":
        pos_types = {"compress_td"}       # y=1 = 压缩赢
        neg_types = {"evacuate_region", "evacuate_instance"}  # y=0 = 疏散赢
        feats = ["net_bbox_span_p90", "fill_rate", "overflow_ratio", "hfanout_ratio", "vh_ratio", "rudy_egr_mismatch"]
    elif axis_id == "H2":
        pos_types = {"baseline"}          # wirelength 驱动（plain）
        neg_types = {"timing"}            # timing 驱动
        feats = ["fill_rate", "overflow_ratio", "hfanout_pin_share", "net_bbox_span_p90"]
    elif axis_id == "H3":
        pos_types = {"evacuate_region", "evacuate_instance"}   # local
        neg_types = {"compress_td", "congest_ce"}              # global
        feats = ["overflow_ratio", "fill_rate", "vh_ratio", "net_bbox_span_p90"]
    else:
        return None

    # 按 (design_key, seed) 分组，要求同时有 pos 和 neg 的样本才能定胜负
    from collections import defaultdict
    groups: Dict[Tuple, Dict[str, Dict]] = defaultdict(dict)
    for s in samples:
        if s.get("split") != split or s.get("run_status") != "ok":
            continue
        at = s["action"]["type"]
        key = (s["design_key"], s["seed"])
        if at in pos_types:
            groups[key]["pos"] = s
        elif at in neg_types:
            groups[key]["neg"] = s

    X_rows, y_rows, fnames, meta_rows = [], [], [], []
    for key, g in groups.items():
        if "pos" not in g or "neg" not in g:
            continue
        pos_s, neg_s = g["pos"], g["neg"]
        # 胜负：先比 egr_union_rel，再比 hpwl_rel；都 None 则跳过
        pos_egr = pos_s["labels"].get("egr_union_rel")
        neg_egr = neg_s["labels"].get("egr_union_rel")
        pos_hpwl = pos_s["labels"].get("hpwl_rel")
        neg_hpwl = neg_s["labels"].get("hpwl_rel")
        if pos_egr is None and neg_egr is None:
            continue
        pos_win = False
        if pos_egr is not None and neg_egr is not None:
            pos_win = pos_egr > neg_egr
        elif pos_hpwl is not None and neg_hpwl is not None:
            pos_win = pos_hpwl > neg_hpwl
        else:
            # 只有一个有 EGR：有 EGR 且为正的赢
            pos_win = (pos_egr or 0) > (neg_egr or 0)

        feat_vals = []
        f_ok = True
        for fn in feats:
            v = pos_s["features"].get(fn)
            if v is None:
                f_ok = False
                break
            feat_vals.append(float(v))
        if not f_ok:
            continue
        X_rows.append(feat_vals)
        y_rows.append(1 if pos_win else 0)
        fnames = feats
        meta_rows.append({"design_key": key[0], "seed": key[1],
                          "pos_type": pos_s["action"]["type"], "neg_type": neg_s["action"]["type"],
                          "pos_egr": pos_egr, "neg_egr": neg_egr,
                          "pos_hpwl": pos_hpwl, "neg_hpwl": neg_hpwl})

    if not X_rows:
        return None
    X = np.array(X_rows, dtype=float)
    # 标准化（避免量纲差异）
    mu = X.mean(axis=0, keepdims=True)
    sd = X.std(axis=0, keepdims=True)
    sd[sd == 0] = 1.0
    Xs = (X - mu) / sd
    Xb = np.hstack([np.ones((Xs.shape[0], 1)), Xs])
    return Xb, np.array(y_rows), fnames, meta_rows


def fit_dose(samples: List[Dict], axis_id: str, split: str) -> Optional[Dict]:
    """剂量回归：compress 赢的样本上拟合 target_density* = f(fill_rate)。"""
    if axis_id != "H1":
        return None
    xs, ys = [], []
    for s in samples:
        if s.get("split") != split or s.get("run_status") != "ok":
            continue
        if s["action"]["type"] != "compress_td":
            continue
        td = s["action"]["params"].get("target_density")
        fr = s["features"].get("fill_rate")
        # 只用「compress 确实改善」的样本学剂量（正样本）
        if td is None or fr is None:
            continue
        if (s["labels"].get("egr_union_rel") or 0) <= 0 and (s["labels"].get("hpwl_rel") or 0) <= 0:
            continue
        xs.append(float(fr))
        ys.append(float(td))
    if len(xs) < 3:
        return None
    X = np.array(xs).reshape(-1, 1)
    Xb = np.hstack([np.ones((X.shape[0], 1)), X])
    w = ridge_fit(Xb, np.array(ys), l2=1.0)
    return {"formula": "intercept + k*fill_rate", "intercept": float(w[0]), "k": float(w[1]),
            "n": len(xs)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--train-split", default="train")
    ap.add_argument("--l2", type=float, default=1.0)
    args = ap.parse_args()

    samples = load_samples()
    if not samples:
        print("[fit] 无样本；先跑 gen_dataset + assemble_dataset", file=sys.stderr)
        return 1

    spec = json.loads((HERE / "prior_spec.json").read_text())
    out = {"meta": {"version": 1, "fitted_from": str(DATASET_PATH),
                    "n_samples": len(samples), "train_split": args.train_split},
           "axes": []}

    for ax in spec["axes"]:
        aid = ax["id"]
        res = axis_pairs(samples, aid, args.train_split)
        if res is None:
            out["axes"].append({"id": aid, "status": "insufficient_samples"})
            continue
        Xb, y, fnames, meta = res
        if len(y) < 5 or len(set(y.tolist())) < 2:
            out["axes"].append({"id": aid, "status": "insufficient_variance", "n": len(y)})
            continue
        w = logistic_fit(Xb, y, l2=args.l2)
        p = logistic_predict(Xb, w)
        acc = float(np.mean((p >= 0.5) == y))

        # 报告学出的权重（标准化空间，符号 = 方向，量级 = 相对重要性）
        weights = {"bias": float(w[0])}
        for i, fn in enumerate(fnames):
            weights[fn] = float(w[i + 1])

        dose = fit_dose(samples, aid, args.train_split)

        out["axes"].append({
            "id": aid,
            "name": ax["name"],
            "status": "fitted",
            "model": "logistic",
            "features": fnames,
            "weights": weights,
            "train_accuracy": round(acc, 4),
            "n_pairs": len(y),
            "dose": dose,
        })

    KNOWLEDGE_PATH.parent.mkdir(parents=True, exist_ok=True)
    KNOWLEDGE_PATH.write_text(json.dumps(out, ensure_ascii=False, indent=2))
    print(f"[fit] 写 {KNOWLEDGE_PATH}", file=sys.stderr)
    print(json.dumps(out, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
