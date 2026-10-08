# Current DSH placement plugin suite

The maintained integration consists of six separate DSH packages. The earlier MCP bridge and monolithic native plugin are not active entry points in this snapshot.

| Package directory | Registered tools | Use |
| --- | --- | --- |
| `ipl_tools` | `ipl_observe`, `ipl_propose`, `ipl_run`, `ipl_parallel`, `ipl_session`, `agent_anneal` | Placement control |
| `irt_tools` | `irt_egr` | Trial-route congestion |
| `eval_metrics` | `eval_metrics` | Shared placement evaluation |
| `agent_kb` | `agent_prior` | Optional stored knowledge |
| `knowledge_distiller` | `agent_report`, `agent_observations` | Optional observations and triggered distillation |
| `branch_runner` | `branch_tree`, `branch_status`, `branch_apply`, `branch_promote`, `branch_rollback`, `branch_fork`, `branch_prune` | Optional experiment-tree management |

Each package has `package.json`, `cordis.patch.yml` and `lib/index.js`. The first three form the placement/evaluation integration; knowledge and branch management are additional components. There is no independently installable RSI plugin in the current source.

## Configuration and registration

Use an installed DSH version compatible with the package dependencies. Choose a profile with your own model configuration; credentials and the source machine's model profiles are not bundled.

```bash
export IEDA_ROOT=/absolute/path/to/this/checkout
export IEDA_BIN=/absolute/path/to/a/matching/iEDA/binary
export IEDA_PYTHON=/usr/bin/python3

dsh plugin --profile research-pl add "$IEDA_ROOT/benchmarks/flows/deepseek_harness/plugins/ipl_tools"
dsh plugin --profile research-pl add "$IEDA_ROOT/benchmarks/flows/deepseek_harness/plugins/irt_tools"
dsh plugin --profile research-pl add "$IEDA_ROOT/benchmarks/flows/deepseek_harness/plugins/eval_metrics"
```

Register optional packages with the same command and their directory names. Registration is a setup action; organization does not alter installed DSH profiles.

`designs.json` is a registry snapshot whose external case, DEF, placement-config and foundry paths must exist. Configure it before executing placement. `headless_prompt.txt` is an example prompt, not a complete model/profile configuration.

## Call chain

Plugins call `benchmarks/flows/gp_agent.py` and its sibling adapters; those invoke Tcl tools in a compiled iEDA. Installing JavaScript packages alone does not provide an EDA solver or PDK.

See [the research map](../../../docs/research/README.md) for branch boundaries, experimental scripts and known limitations. Offline model training lives in `../knowledge_mining/` and is not called by these tools.
