#!/usr/bin/env python3
"""Install this iEDA GP plugin into a DeepSeek Harness checkout."""
from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path

FILES = ["gp_mcp_server.py", "designs.json", "gp_agent.cordis.yml", "run_gp_agent.py", "README.md"]


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--harness-root", type=Path, required=True)
    ap.add_argument("--ieda-root", type=Path, default=Path(__file__).resolve().parents[3])
    args = ap.parse_args()
    harness = args.harness_root.resolve()
    if not (harness / "package.json").exists():
        raise SystemExit(f"{harness} does not look like a deepseek-harness checkout")
    dest = harness / "examples/ieda-gp"
    dest.mkdir(parents=True, exist_ok=True)
    source = Path(__file__).resolve().parent
    for name in FILES:
        shutil.copy2(source / name, dest / name)

    # Runtime wheel dependency patch: add mcp-client once, idempotently.
    runtime_pkg = harness / "python/sdk-runtime/package.json"
    data = json.loads(runtime_pkg.read_text())
    if "@deepseek-ai/dsh-mcp-client" not in data["dependencies"]:
        data["dependencies"]["@deepseek-ai/dsh-mcp-client"] = "workspace:^"
        runtime_pkg.write_text(json.dumps(data, indent=2) + "\n")
        print(f"patched {runtime_pkg}")

    # Make the cordis paths follow the installed copy.
    cordis = dest / "gp_agent.cordis.yml"
    text = cordis.read_text()
    # Keep the MCP server in the iEDA checkout (single source of truth); the
    # composition points at <ieda_root>/benchmarks/flows/deepseek_harness/...
    text = text.replace("/home/lizhijun/work/iEDA.ai", str(args.ieda_root.resolve()))
    cordis.write_text(text)
    print(f"installed plugin into {dest}")
    print("next: cd {harness} && pnpm install --no-frozen-lockfile && pnpm exec tsx scripts/build-exe-for-python-sdk.ts")


if __name__ == "__main__":
    main()
