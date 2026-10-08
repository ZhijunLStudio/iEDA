# @ieda-ai/dsh-tool-branch-runner

Domain-agnostic branch-tree orchestration tools (arch ability #4 of the GP
collaboration architecture).

## What it is

The orchestration layer between the Agent (which plans and decides) and an
EDA atomic-surface runner (which computes and stores immutable checkpoints).

It manages the BRANCH TREE: plan → parallel worktrees → evaluate → prune/fork/
rollback. It never decides for the agent and never imports any EDA domain.

## Atomic-surface contract

The runner (configured via `runnerScript`) implements six primitives:

| primitive | meaning | side effect |
|---|---|---|
| tree | read the durable branch tree | none |
| apply | run a candidate batch WITHOUT commit | new child node, head unchanged |
| promote | accept a checkpoint as branch head | writes placement.def |
| rollback | point head at ANY ancestor | head pointer only |
| fork | copy checkpoint to a new workdir | new branch root |
| prune | mark nodes dead | workdir kept for audit |

GP's runner today: `benchmarks/flows/gp_agent.py`. RT/STA/DRC runners provide
the same six-subcommand CLI later.

## Tools exposed to the agent

- `branch_tree` - read one worktree tree (facts)
- `branch_status` - aggregate snapshot across worktrees (facts: alive/promoted/
  pruned counts + head metrics; NO verdict, NO pruning recommendation)
- `branch_apply` - candidate batch without commit (spec JSON forwarded as flags)
- `branch_promote` - commit a checkpoint
- `branch_rollback` - back to any ancestor
- `branch_fork` - new independent worktree
- `branch_prune` - mark dead

## Iron rule

This layer is mechanism, not policy. It executes the agent's fork/promote/
rollback/prune choices and reports tree facts; it never plans, never
autonomously prunes, and never runs a daemon decision loop.
