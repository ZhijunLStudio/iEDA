#!/usr/bin/env python3
"""Drive the native iEDA GP plugin through the DeepSeek Harness Python SDK."""
from __future__ import annotations

import argparse
import os
import time
from pathlib import Path

from deepseek_harness import DeepSeekHarness

CONFIG = Path(__file__).with_name("gp_agent_native.cordis.yml").resolve()


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

    with DeepSeekHarness(
        provider=args.provider,
        model=args.model,
        max_tokens=args.max_tokens,
        cwd=str(args.workspace.resolve()),
        session_root=str(args.session_root.resolve()),
        cordis=str(CONFIG),
    ) as harness:
        harness.start()
        # Native registration is synchronous; this brief pause only lets the
        # runtime settle, matching the MCP-composition runner's guard.
        warmup = float(os.environ.get("GP_TOOL_WARMUP_SECONDS", "1"))
        if warmup > 0:
            time.sleep(warmup)
        result = harness.run(args.prompt, session_id=args.session_id)
    print(result.final_response)


if __name__ == "__main__":
    main()
