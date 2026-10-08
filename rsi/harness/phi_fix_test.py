"""Can lowering max_phi_coef rescue the congestion-aware mode where it diverges?

placer_run_gp -congestion_effort 5 diverges on s1238_sky130_a with the default
max_phi_coef = 1.05, and the solver's own error message says to decrease it. This tries
1.02, 1.01 and 1.00 with the congestion mode on, against the plain baseline.
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import placement_shape as PS
import rsi_lib as R

sys.path.insert(0, str(R.FLOWS))
import gp_agent as G


def go(d, rec, ce, mphi, tag):
    wd = R.RUNS / "phifix" / ("%s_%s" % (d, tag))
    wd.mkdir(parents=True, exist_ok=True)
    cfg = json.loads(Path(rec["pl_config"]).read_text())
    pl = cfg.get("PL", cfg)
    td = float(pl.get("GP", {}).get("Density", {}).get("target_density", 0.8))
    mi = int(pl.get("GP", {}).get("Nesterov", {}).get("max_iter", 2000))
    gp = "placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed 1000 -report_route_util 1" % (mi, td)
    if ce:
        gp += " -congestion_effort %d" % ce
    if mphi is not None:
        gp += " -max_phi_coef %s" % mphi
    rc, out, err = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)),
                              Path(rec["pl_config"]), Path(rec["input_def"]),
                              [gp, "placer_run_gp -mode accept", "placer_run_lg", "placer_run_dp"],
                              def_save=True)
    Path("/tmp/phifix_%s.log" % tag).write_text((out or "") + "\n|STDERR|\n" + (err or ""))
    row = {"design": d, "tag": tag, "ce": ce, "max_phi_coef": mphi, "rc": rc}
    sh = PS.parse_placement(wd / "placement.def")
    row["gini"] = (sh or {}).get("gini")
    row["max_bin"] = (sh or {}).get("max_bin")
    lef = R.lef_of(rec)
    try:
        from gp_metrics_compare import hpwl as ihpwl
        if lef and (wd / "placement.def").exists():
            row["hpwl"] = ihpwl(wd / "placement.def", Path(lef))
    except Exception:
        pass
    t = R.truth_metrics(wd, rec, with_egr=True)
    row["egr_union"] = t.get("egr_total_overflow_union")
    row["egr_max"] = t.get("egr_max_overflow_union")
    return row


D = R.load_designs()
ds = [x for x in sys.argv[1].split(",") if x]
combos = [(0, None, "base")]
for a in sys.argv[2].split(";"):
    ce, mp = a.split(":"), None
combo_spec = sys.argv[2] if len(sys.argv) > 2 else "5:1.02;5:1.01;5:1.0"
for spec in combo_spec.split(";"):
    ce, mp = spec.split(":")
    combos.append((int(ce), float(mp), "ce%sm%s" % (ce, mp.replace(".", ""))))
out = []
for d in ds:
    rec = D.get(d)
    if not rec:
        continue
    for ce, mp, tag in combos:
        try:
            row = go(d, rec, ce, mp, tag)
        except Exception as ex:
            row = {"design": d, "tag": tag, "error": repr(ex)}
        out.append(row)
        print(json.dumps(row))
        sys.stdout.flush()
Path(R.RUNS, "phifix").mkdir(parents=True, exist_ok=True)
Path(R.RUNS, "phifix", "all.json").write_text(json.dumps(out, indent=1))
print("done")
