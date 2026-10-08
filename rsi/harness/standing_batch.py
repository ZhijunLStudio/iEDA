"""The standing, rebuilt in a single batch with both arms.

Round 31 established that the pipeline is deterministic within a batch and not between batches, and that
the standing reported earlier legalised the reference in one batch and measured our placements in
another. This does both arms for every valid design inside one process, so the ratios are comparable by
construction. Every ratio is ours over the reference; below 1.00 is better.

Measurement only: one command sequence, no selection, no source change.
"""
import json, os, re, subprocess, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
sys.path.insert(0, str(W/"ieda/rsi/harness"))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G
from gp_metrics_compare import hpwl as ihpwl

D = R.load_designs()
os.environ["IEDA_BIN"] = str(R.IEDA_ROOT/"build/bin/iEDA-nosshim")
print("  binary md5 %s   thread %s" % (
    subprocess.run(["md5sum", os.environ["IEDA_BIN"]], capture_output=True).stdout.decode().split()[0][:8],
    os.environ.get("RSI_OMP_THREADS")), flush=True)

def netcount(p):
    if not p or not Path(p).exists(): return None
    r = subprocess.run(["grep","-m1","-E","^NETS ",p], capture_output=True)
    m = re.search(rb"NETS\s+(\d+)", r.stdout); return int(m.group(1)) if m else None

valid = [d for d in sorted(D)
         if netcount(D[d].get("input_def")) and netcount(D[d].get("innovus_def"))
         and abs(netcount(D[d]["innovus_def"]) - netcount(D[d]["input_def"])) <= 5]
only = [x for x in (sys.argv[1].split(",") if len(sys.argv) > 1 else []) if x]
if only:
    valid = [d for d in valid if d in only]
print("  valid designs: %d" % len(valid), flush=True)

def flow(rec, wd, cmds):
    G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)), Path(rec["pl_config"]),
               Path(rec["input_def"]), cmds, def_save=True)
    return wd/"placement.def"

out = []
for d in valid:
    rec = D[d]
    cfg = json.loads(Path(rec["pl_config"]).read_text()); pl = cfg.get("PL", cfg)
    td = float(pl.get("GP",{}).get("Density",{}).get("target_density",0.8))
    mi = int(pl.get("GP",{}).get("Nesterov",{}).get("max_iter",2000))
    gp = ("placer_run_gp -mode start -iterations %d -target_density %s -random_init 1 -seed 1000"
          " -report_route_util 1" % (mi, td))

    ours_wd = R.RUNS/"standingB"/d/"ours"; ours_wd.mkdir(parents=True, exist_ok=True)
    od = flow(rec, ours_wd, [gp, "placer_run_gp -mode accept", "placer_run_lg", "placer_run_dp"])
    to = R.truth_metrics(ours_wd, rec, with_egr=True)
    hp_o = ihpwl(od, Path(rec["lef"])) if rec.get("lef") and od.exists() else None

    ref_wd = R.RUNS/"standingB"/d/"ref"; ref_wd.mkdir(parents=True, exist_ok=True)
    G.run_ieda(ref_wd, Path(rec["case_root"]), Path(R.foundry_of(rec)), Path(rec["pl_config"]),
               Path(rec["innovus_def"]), ["placer_run_lg"], def_save=True)
    rd = ref_wd/"placement.def"
    tr = R.truth_metrics(ref_wd, rec, with_egr=True)
    hp_r = ihpwl(rd, Path(rec["lef"])) if rec.get("lef") and rd.exists() else None

    row = {"design": d, "pdk": rec.get("pdk"),
           "ours": {"hpwl": hp_o, "union": to.get("egr_total_overflow_union"), "max": to.get("egr_max_overflow_union")},
           "ref":  {"hpwl": hp_r, "union": tr.get("egr_total_overflow_union"), "max": tr.get("egr_max_overflow_union")}}
    def rt(a, b): return round(a/b, 4) if (a is not None and b not in (None, 0)) else None
    row["ratio"] = {"hpwl": rt(hp_o, hp_r), "union": rt(row["ours"]["union"], row["ref"]["union"]),
                    "max": rt(row["ours"]["max"], row["ref"]["max"])}
    out.append(row)
    print("  %-22s ours %s | ref %s | ratio %s" % (d, row["ours"], row["ref"], row["ratio"]), flush=True)

(R.RUNS/"standingB").mkdir(parents=True, exist_ok=True)
(R.RUNS/"standingB"/("%s.json" % (sys.argv[2] if len(sys.argv) > 2 else "all"))).write_text(json.dumps(out, indent=1))
print("done")
