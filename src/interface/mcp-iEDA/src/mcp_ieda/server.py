#!/usr/bin/env python
# -*- encoding: utf-8 -*-
'''
@File : server.py
@Time : 2025/04/27 11:38:51
@Author : simin tao
@Version : 1.0
@Contact : taosm@pcl.ac.cn
@Desc : The mcp server for iEDA.
'''
import logging
import os
import json
import subprocess

from pathlib import Path
from typing import Any

current_dir = os.path.split(os.path.abspath(__file__))[0]

_TRUE_ENV_VALUES = {"1", "true", "yes", "on"}
DEFAULT_TIMEOUT_SEC = 3600


def env_flag(name: str, default: bool = False) -> bool:
    value = os.getenv(name)
    if value is None:
        return default
    return value.lower() in _TRUE_ENV_VALUES


def mcp_write_enabled() -> bool:
    return env_flag("MCP_IEDA_WRITE", False)


def require_mcp_write(tool_name: str) -> None:
    if not mcp_write_enabled():
        raise PermissionError(f"{tool_name} requires MCP_IEDA_WRITE=1")


def get_workspace_root() -> Path:
    workspace = os.getenv("MCP_IEDA_WORKSPACE")
    if not workspace:
        raise PermissionError("MCP_IEDA_WORKSPACE must name the approved workspace")

    try:
        root = Path(workspace).expanduser().resolve(strict=True)
    except FileNotFoundError as error:
        raise FileNotFoundError(
            f"MCP_IEDA_WORKSPACE does not exist: {workspace}"
        ) from error
    if not root.is_dir():
        raise NotADirectoryError(f"MCP_IEDA_WORKSPACE is not a directory: {root}")
    return root


def resolve_workspace_script(script_path: str | Path, workspace_root: Path) -> Path:
    raw_path = Path(script_path).expanduser()
    if ".." in raw_path.parts:
        raise PermissionError("iEDA script path must not contain '..'")
    candidate = raw_path if raw_path.is_absolute() else workspace_root / raw_path
    try:
        candidate = candidate.resolve(strict=True)
    except FileNotFoundError as error:
        raise FileNotFoundError(f"iEDA script not found: {script_path}") from error
    if not candidate.is_file():
        raise IsADirectoryError(f"iEDA script is not a file: {candidate}")
    if candidate.suffix.lower() != ".tcl":
        raise ValueError("iEDA script must use the .tcl extension")
    try:
        candidate.relative_to(workspace_root)
    except ValueError as error:
        raise PermissionError(
            f"iEDA script must be inside MCP_IEDA_WORKSPACE: {workspace_root}"
        ) from error
    return candidate


def get_run_timeout_sec() -> int:
    try:
        timeout_sec = int(os.getenv("MCP_IEDA_TIMEOUT_SECONDS", str(DEFAULT_TIMEOUT_SEC)))
    except ValueError as error:
        raise ValueError("MCP_IEDA_TIMEOUT_SECONDS must be a positive integer") from error
    if timeout_sec <= 0:
        raise ValueError("MCP_IEDA_TIMEOUT_SECONDS must be a positive integer")
    return timeout_sec


def _run_result(
    *,
    status: str,
    reason: str,
    returncode: int | None,
    ieda_path: Path,
    script_path: Path,
    workspace_root: Path,
    timeout_sec: int,
) -> dict[str, Any]:
    return {
        "schema_version": "ieda.mcp.run_result.v1",
        "status": status,
        "reason": reason,
        "returncode": returncode,
        "product_assertion": "not_asserted",
        "rankable": False,
        "comparable": False,
        "iEDA": str(ieda_path),
        "workspace_root": str(workspace_root),
        "script_path": str(script_path.relative_to(workspace_root)),
        "write_authorized": True,
        "timeout_sec": timeout_sec,
        "ok": status == "process_completed" and returncode == 0,
        "rc": returncode,
    }


def run_ieda(iEDA: Path, script_path: str | Path):
    """Run iEDA with the given script path."""

    require_mcp_write("iEDA_RUN")
    try:
        ieda_path = Path(iEDA).expanduser().resolve(strict=True)
    except FileNotFoundError as error:
        raise FileNotFoundError(f"iEDA binary not found: {iEDA}") from error
    if not ieda_path.is_file():
        raise FileNotFoundError(f"iEDA binary not found: {ieda_path}")
    if not os.access(ieda_path, os.X_OK):
        raise PermissionError(f"iEDA binary is not executable: {ieda_path}")
    workspace_root = get_workspace_root()
    tcl_path = resolve_workspace_script(script_path, workspace_root)
    timeout_sec = get_run_timeout_sec()

    command = [str(ieda_path), "-script", str(tcl_path)]
    logging.info("Run iEDA with argv: %s", command)
    try:
        process = subprocess.run(
            command,
            check=False,
            cwd=workspace_root,
            timeout=timeout_sec,
        )
    except subprocess.TimeoutExpired:
        return _run_result(
            status="timeout",
            reason="process_timeout",
            returncode=None,
            ieda_path=ieda_path,
            script_path=tcl_path,
            workspace_root=workspace_root,
            timeout_sec=timeout_sec,
        )
    if process.returncode != 0:
        return _run_result(
            status="process_failed",
            reason="nonzero_returncode",
            returncode=process.returncode,
            ieda_path=ieda_path,
            script_path=tcl_path,
            workspace_root=workspace_root,
            timeout_sec=timeout_sec,
        )
    return _run_result(
        status="process_completed",
        reason="process_rc_zero_product_not_asserted",
        returncode=process.returncode,
        ieda_path=ieda_path,
        script_path=tcl_path,
        workspace_root=workspace_root,
        timeout_sec=timeout_sec,
    )
    
    
def get_server_url() -> str:
    """
    Get the server bind address from environment variable or default to localhost.
    """
    return os.getenv("MCP_SERVER_URL", "127.0.0.1")

def get_server_port() -> int:
    """
    Get the server port from environment variable or default to 3002.
    """
    return int(os.getenv("MCP_SERVER_PORT", 3002))


def get_server_debug() -> bool:
    return env_flag("MCP_SERVER_DEBUG", False)
    
def serve(iEDA: Path, transport="stdio"):
    from enum import Enum

    from mcp.server import Server
    from mcp.server.stdio import stdio_server
    from mcp.types import (
        TextContent,
        Tool,
    )
    from pydantic import BaseModel

    class iEDARun(BaseModel):
        script_path: str

    class iEDARunExample(BaseModel):
        example_name: str

    class iEDAMcpTools(str, Enum):
        """
        iEDA MCP tools
        """

        iEDA_RUN = "iEDA_RUN"
        iEDA_RUN_EXAMPLE = "iEDA_RUN_EXAMPLE"

    logger = logging.getLogger(__name__)
    
    server = Server("mcp-iEDA")
    
    @server.list_tools()
    async def list_tools() -> list[Tool]:
        return [
            Tool(name=iEDAMcpTools.iEDA_RUN, description="Run iEDA with script", inputSchema=iEDARun.schema()),
            Tool(name=iEDAMcpTools.iEDA_RUN_EXAMPLE, description="Run iEDA example", inputSchema=iEDARunExample.schema())
        ]

    @server.call_tool()
    async def call_tool(tool: str, arguments: dict) -> list[TextContent]:
        if tool == iEDAMcpTools.iEDA_RUN:
            script_path = arguments.get("script_path")
            if not script_path:
                raise ValueError("Missing 'script_path' in arguments")
            logger.info(f"Run iEDA with script: {script_path}")
            result = run_ieda(iEDA, script_path)
            return [TextContent(type="text", text=json.dumps(result, sort_keys=True))]
        elif tool == iEDAMcpTools.iEDA_RUN_EXAMPLE:
            example_name = arguments.get("example_name")
            if not example_name:
                raise ValueError("Missing 'example_name' in arguments")
            logger.info(f"Run iEDA example: {example_name}")
            example_script_path = f"{current_dir}/./example/{example_name}/run_iEDA.tcl"
            if os.path.exists(example_script_path):
                result = run_ieda(iEDA, example_script_path)
                result["example_name"] = example_name
                return [TextContent(type="text", text=json.dumps(result, sort_keys=True))]
            raise FileNotFoundError(f"Example script not found: {example_script_path}")
        else:
            raise ValueError(f"Unknown tool: {tool}")

    options = server.create_initialization_options()
        
    if transport == "sse":
        from mcp.server.sse import SseServerTransport
        from starlette.applications import Starlette
        from starlette.routing import Mount, Route

        sse = SseServerTransport("/messages/")

        async def handle_sse(request):
            async with sse.connect_sse(
                request.scope, request.receive, request._send
            ) as streams:
                await server.run(
                    streams[0], streams[1], options
                )

        starlette_app = Starlette(
            debug=get_server_debug(),
            routes=[
                Route("/sse", endpoint=handle_sse),
                Mount("/messages/", app=sse.handle_post_message),
            ],
        )

        import uvicorn

        server_url = get_server_url()
        server_port = get_server_port()
        logger.info(f"Starting iEDA MCP server at {server_url}")
        uvicorn.run(starlette_app, host=server_url, port=server_port)
    else:
        import anyio
        async def arun():
            async with stdio_server() as (read_stream, write_stream):
                await server.run(read_stream, write_stream, options, raise_exceptions=True)
                
        anyio.run(arun)
