#!/usr/bin/env python3
"""Drive the iEDA GP MCP plugin through the DeepSeek Harness Python SDK."""
from __future__ import annotations

import argparse
import os
import time
from pathlib import Path

from deepseek_harness import DeepSeekHarness

CONFIG = Path(__file__).with_name("gp_agent.cordis.yml").resolve()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("prompt")
    parser.add_argument("--workspace", type=Path, default=Path.cwd())
    parser.add_argument("--session-root", type=Path, default=Path(".dsh-sessions"))
    parser.add_argument("--session-id", default="gp-search-001")
    parser.add_argument("--provider", default="deepseek-official")
    parser.add_argument("--model", default=os.environ.get("DSH_MODEL", "deepseek-v4-flash"))
    parser.add_argument("--max-tokens", type=int)
    args = parser.parse_args()

    workspace = args.workspace.resolve()
    session_root = args.session_root.resolve()
    with DeepSeekHarness(
        provider=args.provider,
        model=args.model,
        max_tokens=args.max_tokens,
        cwd=str(workspace),
        session_root=str(session_root),
        cordis=str(CONFIG),
    ) as harness:
        harness.start()
        # mcp-client performs async stdio connect + tools/list discovery at
        # plugin activation. Wait for mcp__gp__* registration before the first
        # model request so the agent can see GP tools on turn one.
        warmup = float(os.environ.get("GP_MCP_WARMUP_SECONDS", "5"))
        if warmup > 0:
            time.sleep(warmup)
        result = harness.run(args.prompt, session_id=args.session_id)
    print(result.final_response)


if __name__ == "__main__":
    main()
