#!/usr/bin/env python3
"""The paired sequential comparison: SR-26 against the current tree, one flow at a time, same seeds.

This is the measurement the objective's acceptance rule asks for. Every earlier acceptance number in this
campaign was taken with several flows in flight, and round 86 showed a cell can flip between co-run
patterns, so the sequential table is the one that decides.

Reads runs/seedcells_seq_sr26 and runs/seedcells_seq_cur; prints the per-design table, the primary count
(designs passing on every seed) and the secondary count (passing design-seed cells), plus the per-cell
transitions that matter for the acceptance rule.

Usage: python3 paired_sequential_verdict.py [--designs a,b] [--seeds 1000,1001,1002,1003]
"""
import argparse
import json
import os
from pathlib import Path

W = Path(__file__).resolve().parents[3]
RUNS = W / "runs"
STANDING = W / "runs" / "standingB"


def load(sub, arm, design, seed):
    p = RUNS / sub / ("%s_%s_s%d.json" % (arm, design, seed))
    if not p.exists():
        return None
    try:
        c = json.loads(p.read_text())
    except Exception:
        return None
    return c if c.get("union") is not None else None


def main():
    global RUNS
    ap = argparse.ArgumentParser()
    ap.add_argument("--designs", default="")
    ap.add_argument("--seeds", default="1000,1001,1002,1003")
    ap.add_argument("--arms", default="", help="subset of cur,sr26,sr28 to print (default all)")
    ap.add_argument("--subject", default="", help="arm compared against cur for the verdict")
    ap.add_argument("--runs-root", type=Path, help="read paired records from this directory instead of the external workspace")
    args = ap.parse_args()

    if args.runs_root is not None:
        RUNS = args.runs_root.resolve()

    seeds = [int(x) for x in args.seeds.split(",") if x]
    if args.designs:
        designs = [x for x in args.designs.split(",") if x]
    elif args.runs_root is not None:
        # Frozen exports contain the design identities in each cell record and
        # do not need the machine-local standing directories.
        designs = sorted({json.loads(p.read_text())["design"]
                          for p in RUNS.glob("seedcells_seq_*/*.json")})
    else:
        designs = sorted(x for x in os.listdir(STANDING) if (STANDING / x).is_dir())

    ARMS = {"cur": "seedcells_seq_cur", "sr26": "seedcells_seq_sr26", "sr28": "seedcells_seq_sr28"}
    if args.arms:
        ARMS = {a: ARMS[a] for a in args.arms.split(",") if a in ARMS}
    print("%-22s | %s" % ("design", " | ".join("%-14s" % a for a in ARMS)))
    prim = {a: 0 for a in ARMS}
    sec = {a: 0 for a in ARMS}
    meas = {a: 0 for a in ARMS}
    per = {}
    for d in designs:
        row = {}
        for a, sub in ARMS.items():
            marks = []
            npass = 0
            nmeas = 0
            for s in seeds:
                c = load(sub, a, d, s)
                if not c:
                    marks.append("-")
                    continue
                nmeas += 1
                ok = bool(c.get("pass_"))
                npass += ok
                marks.append("P" if ok else ".")
            row[a] = ("".join(marks), npass, nmeas)
            sec[a] += npass
            meas[a] += nmeas
            if nmeas == len(seeds) and npass == len(seeds):
                prim[a] += 1
        per[d] = row
        print("%-22s | %s" % (d, " | ".join("%-14s" % ("%s %d/%d" % row[a]) for a in ARMS)))

    print()
    for a in ARMS:
        print("%-5s primary (passes on EVERY seed) %2d/%d   secondary %2d/%d measured"
              % (a, prim[a], len(designs), sec[a], meas[a]))

    # The comparison arm is whichever arm was asked for; "cur" is always the baseline.
    BASE = "cur"
    subject = args.subject if args.subject in ARMS and args.subject != BASE else None
    if subject is None:
        subject = next((a for a in ARMS if a != BASE), None)
    gains, regs = [], []
    if subject:
        for d in designs:
            for s in seeds:
                x = load(ARMS[BASE], BASE, d, s)
                y = load(ARMS[subject], subject, d, s)
                if not x or not y:
                    continue
                if y.get("pass_") and not x.get("pass_"):
                    gains.append("%s@%d" % (d, s))
                if x.get("pass_") and not y.get("pass_"):
                    regs.append("%s@%d" % (d, s))
    print()
    # The objective's rule is about DESIGNS, not cells: "pass count rises and no currently passing design
    # is turned into a failing one". A design counts as passing when it passes on every measured seed, so
    # the disqualifying event is a design-level regression - a design all-seed in one arm and not in the
    # other. Cell-level swaps are reported separately because they matter only when they flip a design;
    # treating every cell swap as disqualifying is stricter than the objective and would reject changes it
    # accepts (observed: 2 cell swaps that flip no design).
    def all_seed(arm, d):
        _, n, m = per[d][arm]
        return m == len(seeds) and n == len(seeds)
    design_regs = [d for d in designs if all_seed(BASE, d) and subject and not all_seed(subject, d)]
    design_gains = [d for d in designs if subject and all_seed(subject, d) and not all_seed(BASE, d)]
    print("cell-level gains   (%s passes, cur fails): %d  %s" % (subject, len(gains), ", ".join(gains) or "-"))
    print("cell-level swaps   (cur passes, %s fails): %d  %s" % (subject, len(regs), ", ".join(regs) or "-"))
    print("design-level gains (%s all-seed, cur not): %d  %s" % (subject, len(design_gains), ", ".join(design_gains) or "-"))
    print("design-level regressions (cur all-seed, %s not): %d  %s"
          % (subject, len(design_regs), ", ".join(design_regs) or "-"))
    # A verdict needs both arms measured over the same cells. Without this guard an empty arm reads as
    # zero passing designs and the comparison "0 -> 2" reports ACCEPT, which is meaningless and would
    # mislead a reader who did not notice the missing arm (observed at 43 of 44 SR-26 cells with the
    # current-tree arm at zero).
    both_measured = meas[BASE] > 0 and subject and meas[subject] > 0
    incomplete = [d for d in designs
                  if subject and per[d][BASE][2] != per[d][subject][2]]
    if not both_measured or incomplete:
        verdict = "INCOMPLETE - not a verdict"
    else:
        rises = prim[subject] > prim[BASE] or sec[subject] > sec[BASE]
        verdict = ("ACCEPT" if rises and not design_regs
                   else ("NOT ACCEPTED" if (not rises or design_regs) else "ACCEPT"))
    print()
    print("acceptance rule (pass count rises AND no currently passing design becomes failing): %s" % verdict)
    if not both_measured or incomplete:
        print("  reason: one arm has no cells, or arms differ in which cells are measured:")
        for d in incomplete:
            print("    %-22s %s %d/%d   %s %d/%d" % (d, BASE, per[d][BASE][2], len(seeds),
                                                      subject, per[d][subject][2], len(seeds)))
    print("  primary  %s %d -> %s %d" % (BASE, prim[BASE], subject, prim[subject]))
    print("  secondary %s %d -> %s %d" % (BASE, sec[BASE], subject, sec[subject]))


if __name__ == "__main__":
    main()
