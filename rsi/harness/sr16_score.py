import json, os, re, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
os.environ["IEDA_BIN"] = str(W/"ieda/build/bin/iEDA-nosshim")
sys.path.insert(0, str(W/"ieda/rsi/harness")); sys.path.insert(0, str(W/"ieda/benchmarks/flows"))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
from gp_metrics_compare import hpwl as ihpwl
D = R.load_designs()
t = "sr16"; arm = "sr16"
p = W/"runs"/"srrej"/t
byKey = {}
for x in sorted(os.listdir(p)):
    m = re.match(r"^(.*)_(ctl|sr\d+)_s(\d+)$", x)
    if m: byKey.setdefault(m.group(1)+"_s"+m.group(3), {})[m.group(2)] = x
rows = []
for k, v in sorted(byKey.items()):
    if not (v.get("ctl") and v.get(arm)): continue
    wa, wb = p/v["ctl"], p/v[arm]
    if not ((wa/"placement.def").exists() and (wb/"placement.def").exists()): continue
    d = k.rsplit("_s", 1)[0]; rec = D[d]; lef = rec.get("lef")
    ref = W/"runs"/"standingB"/d/"ref"
    tr = R.truth_metrics(ref, rec, with_egr=True)
    ru, rm = tr.get("egr_total_overflow_union"), tr.get("egr_max_overflow_union")
    def sc(wd):
        tt = R.truth_metrics(wd, rec, with_egr=True)
        hp = ihpwl(wd/"placement.def", Path(lef)) if lef else None
        return hp, tt.get("egr_total_overflow_union"), tt.get("egr_max_overflow_union")
    ha, ua, ma = sc(wa); hb, ub, mb = sc(wb)
    def rr(x, y): return round(x/y, 4) if (x is not None and y) else None
    r = {"design": d, "seed": k.rsplit("_s",1)[1], "cu": ua, "tu": ub, "cm": ma, "tm": mb,
         "cru": rr(ua,ru), "tru": rr(ub,ru), "crm": rr(ma,rm), "trm": rr(mb,rm),
         "dhpwl": (round(hb/ha-1,4) if (ha and hb) else None)}
    rows.append(r)
    print("  %-16s s%s  union %s->%s (%s)  peak %s->%s (%s)  dHPWL %s" % (
        d, r["seed"], r["cru"], r["tru"], (r["tru"]-r["cru"]).__round__(3) if (r["tru"] and r["cru"]) else "-",
        r["crm"], r["trm"], (r["trm"]-r["crm"]).__round__(3) if (r["trm"] and r["crm"]) else "-", r["dhpwl"]), flush=True)
(W/"runs"/"srrej"/"sr16.json").write_text(json.dumps(rows, indent=1))
print("scored", len(rows))
