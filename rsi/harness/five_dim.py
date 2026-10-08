"""The five-dimension claim, on the only designs where all five can be measured.

Timing is measurable only on sky130, and the valid (netlist-matched) sky130 designs are seven. This
runs the pruned three-candidate pool on those designs at three seeds, selects by the Pareto rule on
the two congestion metrics, and then runs the same timing rung on the shipped candidate and on the
chosen one, so wirelength, both congestion metrics and setup timing are all measured for both arms on
the same design and seed.
"""
import json
import sys
from pathlib import Path

W = Path("/home/lizhijun/work/ieda-rsi")
sys.path.insert(0, str(W / "ieda/rsi/harness"))
import rsi_lib as R
import timing_rung as T
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

CAND = {
    "lgdp": ["placer_run_lg", "placer_run_dp"],
    "lgdplgdp": ["placer_run_lg", "placer_run_dp", "placer_run_lg", "placer_run_dp"],
}
D = json.loads((W / "ieda/rsi/harness/designs.local.json").read_text())
ds = [x for x in sys.argv[1].split(",") if x]
seeds = [int(x) for x in (sys.argv[2].split(",") if len(sys.argv) > 2 else [1001, 1002, 1003])]
out = []
for d in ds:
    rec = D.get(d)
    if not rec:
        continue
    cfg = json.loads(Path(rec["pl_config"]).read_text())
    pl = cfg.get("PL", cfg)
    td = float(pl.get("GP", {}).get("Density", {}).get("target_density", 0.8))
    mi = int(pl.get("GP", {}).get("Nesterov", {}).get("max_iter", 2000))
    for seed in seeds:
        gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed %d"
              " -report_route_util 1" % (mi, td, seed))
        runs = {}
        for arm, tail in CAND.items():
            for tag, gpcmd in (("", gp), ("ce2", gp + " -congestion_effort 2")):
                key = arm if not tag else ("ce2" + arm)
                wd = W / "runs/five" / ("%s_%s_s%d" % (d, key, seed))
                wd.mkdir(parents=True, exist_ok=True)
                rc, o, e = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)),
                                      Path(rec["pl_config"]), Path(rec["input_def"]),
                                      [gpcmd, "placer_run_gp -mode accept"] + tail, def_save=True)
                row = {"design": d, "arm": key, "seed": seed, "rc": rc}
                lef = R.lef_of(rec)
                try:
                    from gp_metrics_compare import hpwl as ihpwl
                    if lef and (wd / "placement.def").exists():
                        row["hpwl"] = ihpwl(wd / "placement.def", Path(lef))
                except Exception:
                    pass
                t = R.truth_metrics(wd, rec, with_egr=True)
                row["union"] = t.get("egr_total_overflow_union")
                row["max"] = t.get("egr_max_overflow_union")
                row["wd"] = str(wd)
                runs[key] = row
                out.append(row)
                print(json.dumps({k: row[k] for k in ("design", "arm", "seed", "rc", "union", "max")}))
                sys.stdout.flush()
        # selection: Pareto-best of the four, preferring the shipped candidate on ties
        def dom(a, b):
            if a.get("union") is None or b.get("union") is None or a.get("max") is None or b.get("max") is None:
                return False
            return a["union"] <= b["union"] and a["max"] <= b["max"] and (a["union"] < b["union"] or a["max"] < b["max"])
        best = runs["lgdp"]
        for k, c in runs.items():
            if dom(c, best):
                best = c
        chosen = [k for k, c in runs.items() if c is best]
        chosen = chosen[0] if chosen else "lgdp"
        # timing on both arms
        for arm in {chosen, "lgdp"}:
            defp = Path(runs[arm]["wd"]) / "placement.def"
            try:
                ok, m = T.timing_of(defp, d, rec, W / "runs/five_t" / ("%s_%s_s%d" % (d, arm, seed)))
            except Exception as ex:
                ok, m = False, {"reason": repr(ex)[:60]}
            tout = {"design": d, "arm": arm, "seed": seed, "chosen": (arm == chosen), "ok": ok,
                    "setup_wns": m.get("setup_wns"), "setup_tns": m.get("setup_tns")}
            out.append(tout)
            print(json.dumps(tout))
            sys.stdout.flush()
Path(W / "runs/five").mkdir(parents=True, exist_ok=True)
Path(W / "runs/five", "all.json").write_text(json.dumps(out, indent=1))
print("done")
