"""A/B between frozen binaries, with the pipeline held fixed.

Both arms use the project's own plain-flow entry point (R.gp_plain -> gp_agent.py plain), so
the command sequence, the configuration and the seed are identical; the only difference is
which frozen binary runs. That is what makes this an attribution of a source change rather
than of a configuration difference. The same binary may appear under several arm names, which
is how the determinism check is run.

Usage: python3 sr_ab.py design1,design2 armA,armB
"""
import json
import os
import sys
from pathlib import Path

sys.path.insert(0, "/home/lizhijun/work/ieda-rsi/ieda/rsi/harness")
import placement_shape as PS
import rsi_lib as R

BIN = {
    "base": R.IEDA_ROOT / "build/bin/iEDA-base",
    "base2": R.IEDA_ROOT / "build/bin/iEDA-base",
    "base3": R.IEDA_ROOT / "build/bin/iEDA-base",
    "sr1": R.IEDA_ROOT / "build/bin/iEDA-sr1",
    "sr2": R.IEDA_ROOT / "build/bin/iEDA-sr2",
    "rev": R.IEDA_ROOT / "build/bin/iEDA-sr2revert",
    "head": R.IEDA_ROOT / "build/bin/iEDA-head",
    "dpctl": R.IEDA_ROOT / "build/bin/iEDA-dpctl",
    "sr3": R.IEDA_ROOT / "build/bin/iEDA-sr3",
    "cap1": R.IEDA_ROOT / "build/bin/iEDA-cap1",
    "cap2": R.IEDA_ROOT / "build/bin/iEDA-cap2",
    "cap3": R.IEDA_ROOT / "build/bin/iEDA-cap3",
    "cap5": R.IEDA_ROOT / "build/bin/iEDA-cap5",
    "dpc7": R.IEDA_ROOT / "build/bin/iEDA-dpc7",
    "sr8": R.IEDA_ROOT / "build/bin/iEDA-sr8",
    "sr10": R.IEDA_ROOT / "build/bin/iEDA-sr10",
    "sr11": R.IEDA_ROOT / "build/bin/iEDA-sr11",
    "sr12": R.IEDA_ROOT / "build/bin/iEDA-sr12",
    "clean89": R.IEDA_ROOT / "build/bin/iEDA-clean89",
    "sr7": R.IEDA_ROOT / "build/bin/iEDA-sr7",
    "swctl": R.IEDA_ROOT / "build/bin/iEDA-swctl",
    "sr5": R.IEDA_ROOT / "build/bin/iEDA-sr5",
}


def run(d, rec, arm):
    wd = R.RUNS / "srab" / ("%s_%s" % (d, arm))
    wd.mkdir(parents=True, exist_ok=True)
    os.environ["IEDA_BIN"] = str(BIN[arm])
    r = R.gp_plain(d, rec, wd, seed=1000, timeout=7200)
    row = {"design": d, "arm": arm, "rc": r["rc"]}
    sh = PS.parse_placement(wd / "placement.def")
    row["gini"] = (sh or {}).get("gini")
    row["max_bin"] = (sh or {}).get("max_bin")
    lef = R.lef_of(rec)
    try:
        sys.path.insert(0, str(R.FLOWS))
        from gp_metrics_compare import hpwl as ihpwl
        if lef and (wd / "placement.def").exists():
            row["hpwl"] = ihpwl(wd / "placement.def", Path(lef))
    except Exception as ex:
        row["hpwl_err"] = repr(ex)
    t = R.truth_metrics(wd, rec, with_egr=True)
    row["egr_union"] = t.get("egr_total_overflow_union")
    row["egr_max"] = t.get("egr_max_overflow_union")
    return row


D = R.load_designs()
ds = [x for x in sys.argv[1].split(",") if x]
arms = [y for x in sys.argv[2:] for y in x.split(",") if y] or ["base", "sr2"]
out = []
for d in ds:
    rec = D.get(d)
    if not rec:
        continue
    for a in arms:
        try:
            row = run(d, rec, a)
        except Exception as ex:
            row = {"design": d, "arm": a, "error": repr(ex)}
        out.append(row)
        print(json.dumps(row))
        sys.stdout.flush()
Path(R.RUNS, "srab").mkdir(parents=True, exist_ok=True)
Path(R.RUNS, "srab", "all.json").write_text(json.dumps(out, indent=1))
print("done")
