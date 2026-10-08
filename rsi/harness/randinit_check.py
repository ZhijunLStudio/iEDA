"""Is the candidate pool solving the same problem as the plain flow?

stage1's candidates came from gp_agent.py start, whose argument defaults include
random_init=1 (start from a random placement). The plain command deliberately avoids
those defaults. If the two disagree on congestion, the pool is a different, harder task
than the flow the reference was produced by - and any comparison against the reference
must say which task it is on.
"""
import json, sys, time
from pathlib import Path
sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
from gp_metrics_compare import hpwl as ihpwl

DESIGNS = ["salsa20_nangate45_a", "s38584_nangate45_a", "s1238_nangate45_a",
           "s1238_sky130_a", "gcd_sky130_a"]
D = R.load_designs()
OUT = R.RUNS / "randinit"; OUT.mkdir(parents=True, exist_ok=True)
res = []
for d in DESIGNS:
    rec = D[d]; lef = R.lef_of(rec); row = {"design": d, "pdk": rec.get("pdk")}
    # plain: config defaults
    wd = OUT / (d + "_plain")
    r = R.gp_plain(d, rec, wd, seed=1000)
    t = R.truth_metrics(wd, rec, with_egr=True)
    row["plain"] = {"hpwl": ihpwl(wd/"placement.def", Path(lef)) if lef else None,
                    "union": t.get("egr_total_overflow_union"), "max": t.get("egr_max_overflow_union"),
                    "rc": r["rc"]}
    # start with random_init=0 and =1, same target density as the config
    cfg = json.load(open(rec["pl_config"])); pl = cfg.get("PL", cfg)
    td = pl.get("GP", {}).get("Density", {}).get("target_density", 0.8)
    for ri in (0, 1):
        wd2 = OUT / ("%s_ri%d" % (d, ri))
        rr = R.gp_candidate(d, rec, wd2, target_density=td, congestion_effort=0,
                            seed=1000, iterations=2000, legalize=True, extra=["--random-init", str(ri)])
        t2 = R.truth_metrics(wd2, rec, with_egr=True)
        row["ri%d" % ri] = {"hpwl": ihpwl(wd2/"placement.def", Path(lef)) if lef else None,
                            "union": t2.get("egr_total_overflow_union"), "max": t2.get("egr_max_overflow_union"),
                            "rc": rr["rc"]}
    res.append(row)
    print(json.dumps(row)); sys.stdout.flush()
(OUT / "randinit.json").write_text(json.dumps(res, indent=1))
print()
print("%-22s | %-24s | %-24s | %s" % ("design", "plain (config)", "start random_init=0", "start random_init=1"))
for r in res:
    def f(k):
        v = r.get(k) or {}
        return "hpwl=%-10s U=%-7s M=%-4s" % (v.get("hpwl"), v.get("union"), v.get("max"))
    print("%-22s | %-24s | %-24s | %s" % (r["design"], f("plain"), f("ri0"), f("ri1")))
