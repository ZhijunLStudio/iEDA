# DeepSeek Harness plugin for iEDA GP

This directory packages the iEDA global-placement (GP) agent for
`deepseek-harness` in BOTH supported plugin forms:

- **native plugin (preferred)**: `@deepseek-ai/dsh-tool-ieda-gp` registers
  `ieda_gp_*` tools directly on `ctx.tools` through `defineTool`; no MCP
  subprocess is involved. Source lives in `native_plugin/`.
- **MCP bridge**: `gp_mcp_server.py` + `@deepseek-ai/dsh-mcp-client`, kept
  for deployments that already standardize on MCP.

## Files

| file | purpose |
|---|---|
| `gp_mcp_server.py` | stdio MCP server exposing `gp_baselines`, `gp_start`, `gp_candidate`, `gp_advance`, `gp_report`, `gp_eval_def`, `gp_full_compare` |
| `designs.json` | registered designs/PDKs and Innovus baselines (s1238, apb4_timer, picorv32, aes) |
| `gp_agent.cordis.yml` | MCP-bridge composition with only `mcp__gp__*` tools enabled |
| `gp_agent_native.cordis.yml` | **native-plugin composition** with only `ieda_gp_*` tools enabled |
| `run_gp_agent_native.py` | Python SDK entrypoint for the native composition |
| `native_plugin/` | source package for `@deepseek-ai/dsh-tool-ieda-gp` |
| `run_gp_agent.py` | Python SDK entrypoint |

## Run

```sh
export IEDA_ROOT=/path/to/iEDA
export DEEPSEEK_API_KEY=...
export DEEPSEEK_BASE_URL=...       # optional OpenAI-compatible proxy
export DSH_MODEL=deepseek-v4-flash

python3 benchmarks/flows/deepseek_harness/run_gp_agent.py \
  --workspace /tmp/gp_agent_workspace \
  --session-root /tmp/gp_agent_sessions \
  --session-id gp-search-001 \
  "Search s1238 GP configurations and beat the Innovus HPWL baseline. Use gp_candidate local-vs-global stages and keep the winning checkpoint."
```

The model sees only `mcp__gp__gp_*` tools, so every placement action goes
through the same CLIs used by the manual experiments.

## MCP tool contract

- `gp_baselines()`: list designs/PDKs, Innovus HPWL and best iEDA result.
- `gp_start(...)`: start a GP session (supports target density, congestion,
  timing/hold config and seed-anchor re-linearize).
- `gp_candidate(...)`: run one local-vs-global branch from a checkpoint and
  return the Pareto verdict plus both branch HPWL/overflow values.
- `gp_advance(...)`: continue the winning session toward its overflow target.
- `gp_report(...)`: inspect session state and ledger.
- `gp_eval_def(...)`: canonical DEF HPWL comparison vs Innovus.
- `gp_full_compare(...)`: run GP->LG->DP for one design.

## Verified integration

Tested against a checkout of `deepseek-ai/deepseek-harness` at
`47f9438` (`0.1.0-rc.5`):

- `gp_mcp_server.py` exposes 7 tools over clean stdio JSON-RPC;
- the runtime node carrier sees all 7 as `mcp__gp__gp_*` model tools;
- through the mounted tool, `gp_full_compare(s1238, timing=true)` returned
  iEDA HPWL 5,745,273 vs Innovus 7,417,394 (**-22.5%**), so the same call a
  DeepSeek agent makes produces a verified Innovus-beating placement on sky130;
- a mock DeepSeek endpoint drove one real tool call (`gp_baselines`) and the
  returned iEDA/Innovus baseline JSON was delivered back to the model turn.

The SDK runtime wheel does not include `@deepseek-ai/dsh-mcp-client` by
default. Apply `deepseek-harness-runtime-mcp.patch` in the harness checkout,
run `pnpm install --no-frozen-lockfile`, then
`pnpm exec tsx scripts/build-exe-for-python-sdk.ts` (or use the dev-only node
carrier with `DSH_RUNTIME_MODE=node`).

## Compatibility with the published SDK

`@deepseek-ai/dsh-mcp-client` is not part of the default SDK runtime closure.
For local development, add it to `python/sdk-runtime/package.json` in the
DeepSeek Harness checkout and rebuild with
`pnpm exec tsx scripts/build-exe-for-python-sdk.ts`. For a released SDK, ask
the DeepSeek Harness maintainers to include `@deepseek-ai/dsh-mcp-client` in
the runtime wheel, or run the harness in node-source mode with
`DSH_RUNTIME_MODE=node`.
