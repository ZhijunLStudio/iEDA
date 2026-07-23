# Repository Workflow

## Branch ownership

- `commercial-parity` and `*/parity-*` branches own deterministic EDA kernels, QoR, performance, and commercial-correlation work.
- `integration/agent-native` and `*/agent-*` branches own Agent contracts, runtime, state, gateway, observation, and orchestration work.
- `compat/*` branches own the smallest shared changes required by both lines.
- Do not commit directly to `main`.

## Commits

Use `./dev/branch_commit.sh` for every commit on the branches above. Prefer explicit paths:

```bash
./dev/branch_commit.sh -m "describe the change" -- path/to/file path/to/test
```

`--all` stages all changes owned by the current lane while excluding generated build trees. The script applies the `parity:`, `agent:`, or `compat:` prefix, validates the staged diff, runs the lane verification command when configured, and invokes Git commit.

Do not commit build directories, object files, static/shared libraries, CMake caches, or Ninja state. Use separate out-of-tree build directories for the commercial and Agent worktrees.

Shared integration branches must be merged, not rebased after publication. Short-lived feature branches may be rebased before review.
