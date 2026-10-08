# Research code map

This is a curated source snapshot, not a new placement algorithm or a claim that the papers are ready.

## Branch boundaries

| Branch | Source snapshot | Contents |
| --- | --- | --- |
| `feat/agent-pl-tools` | `ef2e2d6e` | Agent PL tools and the optional knowledge pipeline |
| `feat/parity-pl-rsi` | `04e26de9`, on top of Agent PL | RSI verification study and SR-28 placement refinement |

The base is iEDA.ai commit `f006087d64cf5de109050ac0a49017ec1c0f9276`, already an ancestor of the fork's `feat/parity-gp-session`. The fork's original iEDA `master` has unrelated history. New branches preserve the iEDA.ai development line; `master` is not changed.

## What runs

```text
DSH agent
  -> DSH plugins: placement / routing / evaluation
  -> Python CLI adapters in benchmarks/flows/
  -> Tcl placement session commands
  -> iEDA C++ placement interfaces and optimizer

Optional: observations -> knowledge distiller -> knowledge/prior storage
Optional: offline datasets -> small prediction model
RSI branch: experiment harness -> alternative solver source -> paired evaluation
```

| Layer | Current source | Role |
| --- | --- | --- |
| Stateful optimizer | `src/operation/iPL/api/GPContract.hh` | Start, advance, restore, local scopes and checkpoints |
| C++ tool adapter | `src/platform/tool_manager/tool_api/ipl_io/` | Placement tools exposed through Tcl |
| Python adapter | `benchmarks/flows/gp_agent.py`, `gp_toolbox.py` | Sessions and observations |
| Placement plugin | `plugins/ipl_tools/` in `benchmarks/flows/deepseek_harness/` | Agent-facing placement calls |
| Evaluation plugins | `plugins/irt_tools/`, `plugins/eval_metrics/` | Trial routing and metrics |
| Optional knowledge | `plugins/agent_kb/`, `plugins/knowledge_distiller/` | Priors, observations and distillation |
| Optional branch management | `plugins/branch_runner/` | Experiment branches and promotion/rollback |
| Optional offline training | `benchmarks/flows/knowledge_mining/` | Dataset generation and small-model training |

The complete existing C++ changes are retained, including shared database, platform, routing and timing support. They are broader than PL: this is **not yet a minimal PL-only port**. Removing domain support requires a separate dependency and build review. No optimizer behavior is intentionally changed by this packaging step.

## Excluded from the new commits

- Old MCP bridge, old monolithic native plugin and earlier DSH profiles.
- Session archives, knowledge dumps, batch logs and presentation material.
- Added benchmark workspaces, routed layouts, activity dumps and generated comparison reports.
- Build directories, solver binaries and installed `node_modules`.

The original worktrees and branches remain available. Exclusion means "outside the current package", not "proved useless". The snapshot manifest records imported and excluded paths. Historical data inherited from the base commit is not rewritten.

The retained `gp_egr_*.py` scripts are experimental congestion operators, **not registered DSH tools**. The knowledge-mining model is an offline component, not automatically called by the placement plugin.

## External inputs

Build iEDA separately. Plugins need `IEDA_ROOT`, a usable `IEDA_BIN`, and case/PDK files matching their design registry. `deepseek_harness/designs.json` retains the source machine's registry for provenance; configure its absolute paths on another machine. Commercial reference layouts, live run directories, trained models and API credentials are not provided by this snapshot.

The six Cordis patches now read `IEDA_ROOT` and `IEDA_PYTHON` from the environment. Use Python 3.10 or newer; this machine's unqualified `python3` can select an older Anaconda interpreter.

## Known limitations carried forward

- Placement `accept` may select the session's HPWL-best checkpoint despite an interface describing acceptance of the current state.
- Successful delivery is not strictly gated on successful legalization.
- Congestion proposals primarily use RUDY; final evaluation can use EGR. Independent EGR operators are not integrated into the plugin.
- A RUDY threshold of 2 is implemented as a hard gate without a demonstrated technology-independent physical guarantee.
- Several historical commercial-parity conclusions were later corrected. Earlier reports are evidence history, not current validated claims.

The RSI branch records its additional gate, rollback, cost and evaluation limitations in `rsi/README.md`. These issues are documented rather than silently changing the measured solver during organization.
