#!/usr/bin/env python3
"""Export GP agent traces into a training-friendly dataset.

Input:  one or more GP workdirs that contain gp_agent_trace.jsonl.
Output: JSONL where each line is one decision event:

  {
    "sample_id": "<workdir>#<seq>",
    "design": "s1238",
    "ts": 176...,
    "workdir": "...",
    "state": {
      "iteration": 400,
      "hpwl": 5760255,
      "overflow": 0.134998,
      "route_util": 1.716
    },
    "action": {
      "source": "ieda_gp_run",
      "args": {"kind": "local_restart", "scope": "longnet", ...}
    },
    "result": {
      "ok": true,
      "candidate_verdict": "left_better",
      "local_restart_hpwl": 5949564,
      "raw_gp_hpwl": 5957257,
      "local_restart_overflow": 0.0997,
      "local_restart_feasible": true
    },
    "outcome": {
      "hpwl_delta": -7693,
      "relative_hpwl_delta": -0.001292,
      "overflow_delta": ...
    }
  }

The exporter only aligns facts already persisted by the Harness plugin;
it does not invent labels.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def latest_state(workdir: Path):
    state_path = workdir / "gp_agent_state.json"
    if not state_path.exists():
        return {}
    try:
        data = json.loads(state_path.read_text())
    except Exception:
        return {}
    return {k: data.get(k) for k in
            ("last_iteration", "last_hpwl", "last_overflow", "last_route_util", "last_stop_reason")}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("workdirs", nargs="+")
    ap.add_argument("--out", required=True)
    args = ap.parse_args()
    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    total = 0
    with out.open("w") as fout:
        for workdir in args.workdirs:
            workdir = Path(workdir)
            trace = workdir / "gp_agent_trace.jsonl"
            if not trace.exists():
                continue
            seq = 0
            for line in trace.read_text(errors="ignore").splitlines():
                if not line.strip():
                    continue
                try:
                    event = json.loads(line)
                except Exception:
                    continue
                state = latest_state(workdir)
                result = event.get("result") or {}
                sample = {
                    "sample_id": f"{workdir}#{seq}",
                    "design": event.get("design") or workdir.parent.name,
                    "ts": event.get("ts"),
                    "workdir": str(workdir),
                    "state": state,
                    "action": {
                        "source": event.get("source"),
                        "args": event.get("args"),
                    },
                    "result": result,
                    "outcome": {},
                }
                if isinstance(result.get("local_restart_hpwl"), int) and isinstance(result.get("raw_gp_hpwl"), int):
                    delta = result["local_restart_hpwl"] - result["raw_gp_hpwl"]
                    sample["outcome"]["hpwl_delta"] = delta
                    sample["outcome"]["relative_hpwl_delta"] = delta / result["raw_gp_hpwl"]
                if "local_restart_overflow" in result:
                    sample["outcome"]["local_restart_overflow"] = result["local_restart_overflow"]
                if "local_restart_feasible" in result:
                    sample["outcome"]["local_restart_feasible"] = result["local_restart_feasible"]
                fout.write(json.dumps(sample) + "\n")
                total += 1
                seq += 1
    print(json.dumps({"ok": True, "out": str(out), "samples": total}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
