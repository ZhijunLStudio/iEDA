"""Verifier fidelity analysis (Stage 1).

Reads the cost ledger, restricts to one improver_id, and reports for every
cheap verifier rung:
  rho   Spearman vs each truth component (per design, then aggregated)
  disc  pairwise discordance rate
  regret  how much worse the rung-selected best candidate is, on the truth,
          than the truth-selected best candidate of the same pool
Also writes figures.

Truth components: legal_hpwl (independent legalized HPWL), egr_union, egr_max.
Composite truth: mean of per-component normalized-to-best values.
"""
import argparse
import json
import math
import os
import statistics as st
import sys
from collections import defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
HARNESS = HERE.parent / "harness"
sys.path.insert(0, str(HARNESS))
import rsi_lib as R

RUNGS = {
    "V0_gp_internal_hpwl": ("min", "hpwl"),
    "V0b_route_util": ("min", "congestion"),
    "V1u_unlegal_hpwl": ("min", "hpwl"),
    "V1_legal_hpwl": ("min", "hpwl"),
    "V2_fair_ruler": ("min", "composite"),
}
def _v1u(b, t):
    return b.get("V1u_def_hpwl_unlegal", b.get("V1_def_hpwl_record"))


SIGNAL = {
    "V0_gp_internal_hpwl": lambda b, t: b.get("V0_gp_internal_hpwl"),
    "V0b_route_util": lambda b, t: b.get("V0b_route_util"),
    "V1u_unlegal_hpwl": _v1u,
    "V1x_state_best_hpwl": lambda b, t: t.get("state_best_def_hpwl"),
    "V1_legal_hpwl": lambda b, t: b.get("V1_hpwl_indep"),
    "V2_fair_ruler": None,
}
TRUTHS = {
    "legal_hpwl": lambda b, t: b.get("V1_hpwl_indep"),
    "egr_union": lambda b, t: t.get("egr_total_overflow_union"),
    "egr_max": lambda b, t: t.get("egr_max_overflow_union"),
}


def ranks(v):
    n = len(v)
    order = sorted(range(n), key=lambda i: v[i])
    rk = [0.0] * n
    i = 0
    while i < n:
        j = i
        while j + 1 < n and v[order[j + 1]] == v[order[i]]:
            j += 1
        avg = (i + j) / 2.0 + 1
        for k in range(i, j + 1):
            rk[order[k]] = avg
        i = j + 1
    return rk


def spearman(x, y):
    if len(x) < 4:
        return None
    rx, ry = ranks(x), ranks(y)
    mx, my = st.mean(rx), st.mean(ry)
    num = sum((a - mx) * (b - my) for a, b in zip(rx, ry))
    dx = math.sqrt(sum((a - mx) ** 2 for a in rx))
    dy = math.sqrt(sum((b - my) ** 2 for b in ry))
    return num / (dx * dy) if dx and dy else None


def bootstrap_ci(vals, n=4000, alpha=0.05, seed=7):
    import random
    rnd = random.Random(seed)
    if len(vals) < 3:
        return (None, None)
    means = []
    for _ in range(n):
        s = [vals[rnd.randrange(len(vals))] for _ in range(len(vals))]
        means.append(st.mean(s))
    means.sort()
    return (means[int(alpha / 2 * n)], means[int((1 - alpha / 2) * n)])


def load(improver_id=None, root=None):
    if root is None:
        rows = R.ledger_rows()
    else:
        p = Path(root)
        if p.is_dir():
            p = p / "ledger.jsonl"
        rows = [json.loads(l) for l in p.read_text().splitlines() if l.strip()]
    rows = [r for r in rows if r.get("arm") == "stage1-pool"]
    by_id = {}
    for r in rows:
        by_id[r.get("run_id")] = r
    rows = list(by_id.values())
    if improver_id:
        rows = [r for r in rows if r.get("improver_id") == improver_id]
    else:
        cnt = defaultdict(int)
        for r in rows:
            cnt[r.get("improver_id")] += 1
        if cnt:
            improver_id = max(cnt.items(), key=lambda kv: kv[1])[0]
            rows = [r for r in rows if r.get("improver_id") == improver_id]
    return rows, improver_id


def extract(rows):
    pool = defaultdict(list)
    for r in rows:
        b, t = r.get("believed") or {}, r.get("true") or {}
        rec = {"design": r["design"], "cand": r.get("cand", {}), "note": r.get("note", "")}
        for k, f in SIGNAL.items():
            if f:
                rec[k] = f(b, t)
        for k, f in TRUTHS.items():
            rec[k] = f(b, t)
        if rec["legal_hpwl"] is None or rec["egr_union"] is None:
            continue
        pool[r["design"]].append(rec)
    return pool


def composite(rec, best):
    bh = max(float(best["legal_hpwl"]), 1.0)
    be = max(float(best["egr_union"]), 1.0)
    a = rec["legal_hpwl"] / bh
    b = rec["egr_union"] / be
    return 0.5 * (a + b)


def analyze(pool):
    out = {"rho": defaultdict(list), "disc": defaultdict(list), "regret": defaultdict(list),
           "selection": defaultdict(list), "per_design": {}}
    for design, cands in pool.items():
        if len(cands) < 5:
            continue
        bh = max(min(c["legal_hpwl"] for c in cands), 1)
        be = max(min(c["egr_union"] for c in cands), 1)
        for c in cands:
            c["truth_composite"] = composite(c, {"legal_hpwl": bh, "egr_union": be})
        best = min(cands, key=lambda c: c["truth_composite"])
        pd = {"n": len(cands), "best_cand": best["note"],
              "best_hpwl": best["legal_hpwl"], "best_egr": best["egr_union"]}
        for tname, tf in TRUTHS.items():
            for rname in list(SIGNAL.keys()) + ["V2_fair_ruler"]:
                xs, ys = [], []
                for c in cands:
                    sv = c["truth_composite"] if rname == "V2_fair_ruler" else c.get(rname)
                    tv = c[tname]
                    if sv is None or tv is None:
                        continue
                    xs.append(float(sv))
                    ys.append(float(tv))
                rho = spearman(xs, ys)
                if rho is not None:
                    out["rho"][(rname, tname)].append(rho)
                    pd.setdefault("rho", {})["%s|%s" % (rname, tname)] = round(rho, 3)
        for rname in list(SIGNAL.keys()) + ["V2_fair_ruler"]:
            key = lambda c: c["truth_composite"] if rname == "V2_fair_ruler" else c.get(rname)
            usable = [c for c in cands if key(c) is not None]
            if len(usable) < 5:
                continue
            sel = min(usable, key=key)
            out["selection"][rname].append(sel["note"])
            out["regret"][(rname, "hpwl")].append(sel["legal_hpwl"] / bh - 1.0)
            out["regret"][(rname, "egr")].append(sel["egr_union"] / be - 1.0)
            out["regret"][(rname, "composite")].append(sel["truth_composite"] - best["truth_composite"])
        out["per_design"][design] = pd
    return out


def fmt(vals):
    if not vals:
        return "n/a"
    lo, hi = bootstrap_ci(vals)
    s = "%+.3f" % st.median(vals)
    if lo is not None:
        s += " [%+.3f,%+.3f]" % (lo, hi)
    return s


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--improver-id", default=None)
    ap.add_argument("--root", default=None)
    ap.add_argument("--out", default=str(R.RSI / "analysis/out"))
    args = ap.parse_args()
    rows, iid = load(args.improver_id, args.root)
    pool = extract(rows)
    print("improver_id %s  rows %d  designs %d" % (iid, len(rows), len(pool)))
    res = analyze(pool)
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    lines = ["# Stage 1 - verifier fidelity", "", "improver_id: %s" % iid,
             "designs: %d  candidates: %d" % (len(pool), sum(len(v) for v in pool.values())), "",
             "## Spearman rho (median over designs, bootstrap 95%% CI)", "",
             "| rung | truth | rho |", "|---|---|---|"]
    for (rname, tname), v in sorted(res["rho"].items()):
        lines.append("| %s | %s | %s |" % (rname, tname, fmt(v)))
    lines += ["", "## Selection regret of the rung-selected best candidate", "",
              "(relative to the truth-selected best of the same pool; 0 = no cost)", "",
              "| rung | HPWL regret | EGR regret | composite regret |", "|---|---|---|---|"]
    for rname in list(SIGNAL.keys()) + ["V2_fair_ruler"]:
        lines.append("| %s | %s | %s | %s |" % (
            rname, fmt(res["regret"][(rname, "hpwl")]), fmt(res["regret"][(rname, "egr")]),
            fmt(res["regret"][(rname, "composite")])))
    lines += ["", "## Per-design detail", "", "| design | n | truth-best candidate | rho(V1_legal_hpwl,egr_union) | rho(V1u,legal_hpwl) |", "|---|---|---|---|"]
    for d, pd in sorted(res["per_design"].items()):
        rho = pd.get("rho", {})
        lines.append("| %s | %d | %s | %s | %s |" % (
            d, pd["n"], pd["best_cand"],
            rho.get("V1_legal_hpwl|egr_union", "n/a"), rho.get("V1u_unlegal_hpwl|legal_hpwl", "n/a")))
    (out / "stage1_fidelity.md").write_text("\n".join(lines) + "\n")
    ser = {"improver_id": iid, "regret": {"%s|%s" % k: v for k, v in res["regret"].items()},
           "rho": {"%s|%s" % k: v for k, v in res["rho"].items()},
           "per_design": res["per_design"]}
    (out / "stage1_fidelity.json").write_text(json.dumps(ser, indent=1))
    print("\n".join(lines[:60]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
