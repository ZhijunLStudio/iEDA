"""Rebuild a sweep record from its log and work directories.

Why this exists: a sweep can die after printing results but before writing its JSON (a
stuck child, an externally killed process). The measurements themselves are not lost -
each design's placement.def and its log line survive - so the record can be rebuilt
instead of re-measured.

Provenance is recorded per field so a rebuilt record is never mistaken for a native one:
  hpwl, gini, max_bin, busiest1pct_share  recomputed from placement.def (deterministic)
  egr_union, egr_max, legalized           taken from the sweep log (an expensive trial
                                          route; deterministic given the same DEF and
                                          binary, but not recomputed here)

Usage: python3 reconstruct_sweep.py --tag baseV2
"""
import argparse
import json
import re
import statistics as st
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent / "harness"))
import placement_shape as PS
import rsi_lib as R

DIMS = ["hpwl", "egr_union", "egr_max", "gini", "max_bin", "setup_tns", "setup_wns"]
LINE = re.compile(r"^\s+(\S+)\s+hpwl=(\S+)\s+egr_union=(\S+)\s+egr_max=(\S+)\s+t=([\d.]+)s")
BINLINE = re.compile(r"^binary (\S+) -> (\S+) \(md5 ([0-9a-f]+)\)")


def parse_log(p):
    rows, md5, src = {}, None, None
    for line in Path(p).read_text().splitlines():
        m = BINLINE.match(line)
        if m:
            src, md5 = m.group(1), m.group(3)
            continue
        m = LINE.match(line)
        if m:
            d, h, u, x, t = m.groups()
            rows[d] = {"design": d, "hpwl_log": h, "egr_union": None if u == "None" else int(u),
                       "egr_max": None if x == "None" else int(x), "t_total": float(t)}
    return rows, src, md5


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tag", required=True)
    ap.add_argument("--log", default="")
    ap.add_argument("--root", default=str(R.RSI_ROOT / "runs"))
    args = ap.parse_args()
    root = Path(args.root)
    log = Path(args.log) if args.log else (root / ("srciter_%s.log" % args.tag))
    if not log.exists():
        print("no log at", log)
        return 1
    logged, src, md5 = parse_log(log)
    D = R.load_designs()
    rows = []
    for d, r in sorted(logged.items()):
        rec = D.get(d) or {}
        wd = root / "srciter" / "sweep" / args.tag / d
        row = {"design": d, "pdk": rec.get("pdk"), "workdir": str(wd),
               "egr_union": r["egr_union"], "egr_max": r["egr_max"], "t_total": r["t_total"],
               "binary_md5": md5}
        try:
            sys.path.insert(0, str(R.FLOWS))
            from gp_metrics_compare import hpwl as ihpwl
            lef = R.lef_of(rec) if rec else None
            defp = wd / "placement.def"
            if lef and defp.exists():
                row["hpwl"] = ihpwl(defp, Path(lef))
        except Exception as ex:
            row["hpwl_error"] = repr(ex)
        try:
            sh = PS.parse_placement(wd / "placement.def")
            if sh:
                row["gini"] = sh["gini"]
                row["max_bin"] = sh["max_bin"]
                row["busiest1pct_share"] = sh["busiest1pct_share"]
        except Exception as ex:
            row["shape_error"] = repr(ex)
        row["status"] = "ok" if (row.get("hpwl") is not None and row.get("egr_union") is not None) else "incomplete"
        rows.append(row)
    ok = [r for r in rows if r["status"] == "ok"]
    rec = {"tag": args.tag, "binary": src, "binary_md5": md5, "rows": rows, "n": len(rows),
           "n_ok": len(ok), "reconstructed_from": str(log),
           "provenance": {"hpwl": "recomputed from placement.def",
                          "gini/max_bin/busiest1pct_share": "recomputed from placement.def",
                          "egr_union/egr_max": "taken from the sweep log (trial route)"},
           "summary": {k: (st.median([r[k] for r in ok if r.get(k) is not None])
                           if any(r.get(k) is not None for r in ok) else None) for k in DIMS}}
    out = root / "srciter" / ("%s.json" % args.tag)
    # never downgrade a complete native record
    prev = None
    if out.exists():
        try:
            prev = json.loads(out.read_text())
        except Exception:
            prev = None
    if prev and prev.get("n", 0) > len(ok) and "reconstructed_from" not in prev:
        print("existing record has %d rows (native), not overwriting with %d" % (prev["n"], len(ok)))
    else:
        out.write_text(json.dumps(rec, indent=1))
        print("wrote %s: %d rows (%d ok)" % (out, len(rows), len(ok)))
    print("  binary md5 %s" % md5)
    print("  summary: " + json.dumps(rec["summary"]))
    missing = [r["design"] for r in rows if r["status"] != "ok"]
    if missing:
        print("  incomplete designs: %s" % missing)
    return 0


if __name__ == "__main__":
    sys.exit(main())
