"""Prune heavy intermediates from finished candidate directories.

Keeps, per candidate: DONE.json, placement.def, gp_agent_state.json and the
small config/log files. Removes the pl/ checkpoint tree and other stage
intermediates. Only directories that already carry DONE.json are touched, so an
in-flight candidate is never disturbed.

Usage: /usr/bin/python3 prune_runs.py [--root runs/v2] [--dry-run]
"""
import argparse
import shutil
import sys
from pathlib import Path

KEEP_SUFFIX = (".json", ".def", ".tcl")
DROP_DIRS = ("pl", "logs", "result", "visualizations")


def prune(root, dry):
    root = Path(root)
    freed = 0
    n = 0
    for done in root.rglob("DONE.json"):
        wd = done.parent
        for d in DROP_DIRS:
            p = wd / d
            if p.is_dir():
                sz = sum(f.stat().st_size for f in p.rglob("*") if f.is_file())
                if not dry:
                    shutil.rmtree(p, ignore_errors=True)
                freed += sz
                n += 1
    return n, freed


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", action="append", default=None)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    roots = args.root or ["runs/v2/stage1", "runs/v2/stage2_candidates",
                          "runs/dev/stage2_candidates", "runs/t1", "runs/t2", "runs/t3",
                          "runs/smoke", "runs/timing", "runs/timing2", "runs/frontier",
                          "runs/diag", "runs/val"]
    tot_n = tot_b = 0
    for r in roots:
        p = Path("/home/lizhijun/work/ieda-rsi") / r
        if not p.exists():
            continue
        n, b = prune(p, args.dry_run)
        tot_n += n
        tot_b += b
        if n:
            print("%-40s %4d dirs %8.1f MB" % (r, n, b / 1e6))
    print("TOTAL %d dirs %.1f MB %s" % (tot_n, tot_b / 1e6, "(dry run)" if args.dry_run else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
