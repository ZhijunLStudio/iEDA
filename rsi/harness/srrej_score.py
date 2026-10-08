"""Score the SR-13 and SR-14 re-judgement pairs that are complete."""
import json, os, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
os.environ["IEDA_BIN"] = str(W/"ieda/build/bin/iEDA-nosshim")
sys.path.insert(0, str(W/"ieda/rsi/harness")); sys.path.insert(0, str(W/"ieda/benchmarks/flows"))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
from gp_metrics_compare import hpwl as ihpwl

D = R.load_designs()
rows = []
for t in ("sr13", "sr14", "sr16"):
    p = W/"runs"/"srrej"/t
    if not p.exists(): continue
    byKey = {}
    for x in sorted(os.listdir(p)):
        m = __import__("re").match(r"^(.*)_(ctl|sr\d+)_s(\d+)$", x)
        if m: byKey.setdefault(m.group(1)+"_s"+m.group(3), {})[m.group(2)] = x
    for k, v in sorted(byKey.items()):
        if not (v.get("ctl") and v.get(t)): continue
        wa, wb = p/v["ctl"], p/v[t]
        if not ((wa/"placement.def").exists() and (wb/"placement.def").exists()): continue
        d = k.rsplit("_s", 1)[0]
        rec = D[d]; lef = rec.get("lef")
        ref_wd = W/"runs"/"standingB"/d/"ref"
        tr = R.truth_metrics(ref_wd, rec, with_egr=True)
        ru, rm = tr.get("egr_total_overflow_union"), tr.get("egr_max_overflow_union")
        def sc(wd):
            tt = R.truth_metrics(wd, rec, with_egr=True)
            hp = ihpwl(wd/"placement.def", Path(lef)) if lef else None
            return hp, tt.get("egr_total_overflow_union"), tt.get("egr_max_overflow_union")
        ha, ua, ma = sc(wa); hb, ub, mb = sc(wb)
        def gp_ov(wd):
            f = wd/"pl/gp_experiments.jsonl"
            if not f.exists(): return None
            try:
                return json.loads(f.read_text().strip().splitlines()[-1]).get("overflow")
            except Exception:
                return None
        gpa, gpb = gp_ov(wa), gp_ov(wb)
        def rr(x, y): return round(x/y, 4) if (x is not None and y) else None
        rows.append({"test": t, "design": d, "seed": k.rsplit("_s", 1)[1], "ctl": {"u": ua, "m": ma},
                     "trt": {"u": ub, "m": mb}, "ratio_ctl": {"union": rr(ua,ru), "max": rr(ma,rm)},
                     "ratio_trt": {"union": rr(ub,ru), "max": rr(mb,rm)},
                     "dhpwl": (round(hb/ha - 1, 4) if (ha and hb) else None),
                     "gp_overflow_ctl": gpa, "gp_overflow_trt": gpb})
        r = rows[-1]
        print("  %-5s %-20s s%s  ctl %s/%s -> trt %s/%s   (ratio ctl %s/%s -> trt %s/%s)  dHPWL %s" % (
            t, d, r["seed"], ua, ma, ub, mb, r["ratio_ctl"]["union"], r["ratio_ctl"]["max"],
            r["ratio_trt"]["union"], r["ratio_trt"]["max"], r["dhpwl"]), flush=True)
(W/"runs"/"srrej").mkdir(parents=True, exist_ok=True)
(W/"runs"/"srrej"/"scored.json").write_text(json.dumps(rows, indent=1))
print("scored %d pairs" % len(rows))
