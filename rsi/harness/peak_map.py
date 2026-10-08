"""Where are the worst congestion cells, ours versus the reference?

The evaluator writes its per-cell overflow map on every run. Comparing the location and shape of the
worst cells between our placement and a legalised version of the reference's says whether we are losing
the peak in a place the reference is not, or merely by a little everywhere - different problems with
different fixes. The reference DEF is scored only after legalisation, so it is run through iEDA's
legalizer first, which is a measurement, not a change to it.
"""
import json, os, sys
from pathlib import Path
W = Path("/home/lizhijun/work/ieda-rsi")
sys.path.insert(0, str(W/"ieda/rsi/harness"))
import rsi_lib as R
sys.path.insert(0, str(R.FLOWS))
import gp_agent as G

D = R.load_designs()
os.environ["IEDA_BIN"] = str(R.IEDA_ROOT/"build/bin/iEDA")

def cells(p):
    rows = []
    for line in Path(p).read_text().strip().splitlines():
        rows.append([float(x) if x not in ("", "nan") else 0.0 for x in line.split(",")])
    return rows

def report(tag, csv):
    g = cells(csv)
    ny = len(g); nx = len(g[0]) if ny else 0
    flat = [(g[y][x], x, y) for y in range(ny) for x in range(nx)]
    flat.sort(reverse=True)
    over = sum(1 for v, _, _ in flat if v > 0)
    tot = sum(v for v, _, _ in flat)
    top = flat[:6]
    print("  %-28s grid %3dx%-3d  sum %9.0f  cells>0 %5d  (%4.1f%%)" % (tag, nx, ny, tot, over, 100.0*over/(nx*ny)))
    print("       worst cells (value, x, y) as %% of die: %s" % ", ".join(
        "%.0f@(%.0f%%,%.0f%%)" % (v, 100.0*x/max(nx-1,1), 100.0*y/max(ny-1,1)) for v, x, y in top))
    return dict(nx=nx, ny=ny, total=tot, over=over, worst=top[0][0] if top else 0.0)

for d in [x for x in sys.argv[1].split(",") if x]:
    rec = D[d]
    print("=== %s (%s) ===" % (d, rec.get("pdk")))
    ours = W/"runs/cesweep"/(d + "_ce0")/"egr_congestion_map/place_egr_union_overflow.csv"
    if ours.exists():
        report("ours (current flow)", ours)
    else:
        print("  ours: map missing")
    # legalise the reference and score it
    wd = R.RUNS/"reflegal"/d; wd.mkdir(parents=True, exist_ok=True)
    rc, o, e = G.run_ieda(wd, Path(rec["case_root"]), Path(R.foundry_of(rec)), Path(rec["pl_config"]),
                          Path(rec["innovus_def"]), ["placer_run_lg"], def_save=True)
    t = R.truth_metrics(wd, rec, with_egr=True)
    print("  reference legalised: rc=%d  union=%s  max=%s" % (rc, t.get("egr_total_overflow_union"),
                                                             t.get("egr_max_overflow_union")))
    ref = wd/"egr_congestion_map/place_egr_union_overflow.csv"
    if ref.exists():
        report("reference (legalised)", ref)
    sys.stdout.flush()
