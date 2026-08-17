#!/usr/bin/env python3
"""Install this iEDA GP plugin into a DeepSeek Harness checkout."""
from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path

FILES = ["gp_mcp_server.py", "designs.json", "gp_agent.cordis.yml", "run_gp_agent.py",
         "gp_agent_native.cordis.yml", "run_gp_agent_native.py", "README.md"]


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
    changed = False
    if "@deepseek-ai/dsh-mcp-client" not in data["dependencies"]:
        data["dependencies"]["@deepseek-ai/dsh-mcp-client"] = "workspace:^"
        changed = True
    if "@deepseek-ai/dsh-tool-ieda-gp" not in data["dependencies"]:
        data["dependencies"]["@deepseek-ai/dsh-tool-ieda-gp"] = "workspace:^"
        changed = True
    if changed:
        runtime_pkg.write_text(json.dumps(data, indent=2) + "\n")
        print(f"patched {runtime_pkg}")

    # Native first-party plugin: copy the source package into the workspace
    # tree and wire the host tsconfig / SDK runtime manifest.
    pkg_src = source / "native_plugin"
    pkg_dst = harness / "packages/ieda/tool-ieda-gp"
    if pkg_src.exists():
        if pkg_dst.exists():
            shutil.rmtree(pkg_dst)
        shutil.copytree(pkg_src, pkg_dst)
        tsconfig = harness / "tsconfig.host.json"
        text = tsconfig.read_text()
        needle = '"path": "./packages/core/tools"'
        if needle in text and "packages/ieda/tool-ieda-gp" not in text:
            text = text.replace(needle, needle + ',\n    { "path": "./packages/ieda/tool-ieda-gp" }')
            tsconfig.write_text(text)
            print(f"patched {tsconfig}")

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
