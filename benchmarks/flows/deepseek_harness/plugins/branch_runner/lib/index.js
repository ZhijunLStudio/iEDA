import z from "@deepseek-ai/schemastery";
import { defineTool } from "@deepseek-ai/dsh-tools";
import { execFile } from "node:child_process";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

const name = "tool-branch-runner";
const inject = ["tools"];

const Config = z.object({
  runnerScript: z.string().required(),
  python: z.string().default("python3"),
  timeoutMs: z.number().step(1).min(1e3).default(72e5),
});

function jsonContent(value) {
  return [{ type: "text", text: JSON.stringify(value, null, 2) }];
}
function commonResultSchema() {
  return { type: "json" };
}
// dsh-tools defineTool expects parameters as a plain map of {key: {type, required}}.
const p = (extra = {}) => ({ ...extra });
const out = () => ({ schema: commonResultSchema(), render: (_args, value) => jsonContent(value) });

async function runRunner(config, args) {
  try {
    const { stdout, stderr } = await execFileAsync(config.python, [config.runnerScript, ...args], {
      cwd: process.cwd(),
      timeout: config.timeoutMs,
      maxBuffer: 64 * 1024 * 1024,
    });
    try {
      return JSON.parse(stdout);
    } catch {
      return { ok: false, rc: 0, stdout_tail: String(stdout).slice(-4000), stderr_tail: String(stderr).slice(-2000) };
    }
  } catch (error) {
    const e = error;
    try {
      const parsed = JSON.parse(e.stdout ?? "");
      if (parsed && typeof parsed === "object") return parsed;
    } catch {}
    return { ok: false, stderr_tail: String(e.stderr ?? e.message).slice(-2000) };
  }
}

export function apply(ctx, config) {
  const run = (args) => runRunner(config, args);

  ctx.tools.register(defineTool({
    name: "branch_tree",
    description: "Read one worktree durable branch tree (eval primitive, no side effect). Returns nodes {id,parent,checkpoint_path,metrics_snapshot,decision_label,status} and the head pointer. Fact source for orchestration; never judges which branch to keep.",
    parameters: p({ workdir: { type: "string", required: true } }),
    output: out(),
    execute: async (args) => run(["tree", "--workdir", String(args.workdir)]),
  }));

  ctx.tools.register(defineTool({
    name: "branch_status",
    description: "Aggregate a snapshot of multiple worktrees branch trees. workdirs is comma-separated. Returns per-worktree {head, node_count, alive/promoted/pruned counts, orphan_fork_count, root_head_promoted, head_metrics, head_decision_label} - FACTS ONLY, no alive/dead/promising verdict and no pruning recommendation. orphan_fork_count is the number of alive branch roots never promoted (a shape fact, not a verdict); root_head_promoted says whether the current tree head was promoted (i.e. whether the scored root placement.def should reflect it). The agent reads these to plan; this layer decides nothing.",
    parameters: p({ workdirs: { type: "string", required: true } }),
    output: out(),
    execute: async (args) => {
      const dirs = String(args.workdirs).split(",").map((s) => s.trim()).filter(Boolean);
      const snapshots = [];
      for (const dir of dirs) {
        const r = await run(["tree", "--workdir", dir]);
        const t = (r && r.tree) || { nodes: {}, branches: [], head: null };
        const nodes = t.nodes || {};
        const values = Object.values(nodes);
        const headNode = nodes[t.head];
        const promoted = values.filter((n) => n.status === "promoted").length;
        // Orphan-fork fact: how many nodes were forked/created but never
        // promoted (alive and not the current head). This is a FACT about the
        // shape of the tree, NOT a recommendation - the agent reads it to know
        // whether its exploration left dead-end branches it may want to prune or
        // investigate, exactly the "don't fork blindly" signal.
        const orphanForkCount = values.filter((n) => n.decision_label && !n.parent && n.status === "alive" && n.id !== t.head).length;
        // Delivery fact: is the ROOT workdir's placement.def backed by the
        // promoted head? When a fork was promoted, the root should carry the
        // resulting placement.def. We report facts the scoring layer will read.
        const rootPromoted = values.some((n) => n.status === "promoted") && (headNode && headNode.status === "promoted");
        snapshots.push({
          workdir: dir,
          head: t.head,
          node_count: values.length,
          alive: values.filter((n) => n.status === "alive").length,
          promoted,
          pruned: values.filter((n) => n.status === "pruned").length,
          orphan_fork_count: orphanForkCount,
          root_head_promoted: rootPromoted,
          head_metrics: (headNode && headNode.metrics_snapshot) || (headNode && headNode.metrics) || null,
          head_decision_label: headNode ? headNode.decision_label : null,
        });
      }
      return { ok: true, worktrees: snapshots };
    },
  }));

  ctx.tools.register(defineTool({
    name: "branch_apply",
    description: "Apply a candidate batch WITHOUT committing (arch primitive apply). The runner runs N iterations and registers a new child node; branch head and placement.def are NOT changed. spec is a JSON object of domain parameters (e.g. {scope,scope_region,scope_instances,iterations,halo_coeff,overflow_penalty,halo_hops,scope_density_target,scope_anneal_ratio,density_target,congestion_threshold}); underscore keys are mechanically forwarded as --hyphen-flag value pairs to the EDA runner, which does not interpret their meaning. The runner's candidate mode requires a LOCAL scope, so spec should carry scope plus the matching scope_region/scope_instances/scope_active_ratio (a global scope is rejected by the runner). decision_label is a free-text hypothesis tag stored on the child node.",
    parameters: p({ workdir: { type: "string", required: true }, spec: { type: "string" }, decision_label: { type: "string" } }),
    output: out(),
    execute: async (args) => {
      // spec 是 runner_contract.json 定义的域参数 JSON（underscore key）。
      // 契约规定：编排层机械转发，不解释域语义——underscore key 转 --hyphen-flag
      // 是契约的一部分（runner CLI 用连字符），不是域知识 hack。
      const extra = [];
      if (args.spec) {
        let obj = {};
        try { obj = JSON.parse(args.spec); } catch {}
        for (const [k, v] of Object.entries(obj)) {
          const flag = "--" + k.replace(/_/g, "-");
          if (v === null || v === undefined) continue;
          extra.push(flag, String(v));
        }
      }
      return run(["apply", "--workdir", String(args.workdir), ...extra,
        ...(args.decision_label ? ["--decision-label", String(args.decision_label)] : [])]);
    },
  }));

  ctx.tools.register(defineTool({
    name: "branch_promote",
    description: "Promote a checkpoint as the branch head (arch primitive promote): writes placement.def and marks the node promoted. This is the commit step; apply alone never commits.",
    parameters: p({ workdir: { type: "string", required: true }, checkpoint: { type: "string" } }),
    output: out(),
    execute: async (args) => run(["promote", "--workdir", String(args.workdir),
      ...(args.checkpoint ? ["--checkpoint", String(args.checkpoint)] : [])]),
  }));

  ctx.tools.register(defineTool({
    name: "branch_rollback",
    description: "Point the branch head at ANY ancestor checkpoint (arch primitive rollback), not just one step back. No computation runs; only the head pointer is rewritten.",
    parameters: p({ workdir: { type: "string", required: true }, checkpoint: { type: "string", required: true } }),
    output: out(),
    execute: async (args) => run(["rollback", "--workdir", String(args.workdir), "--checkpoint", String(args.checkpoint)]),
  }));

  ctx.tools.register(defineTool({
    name: "branch_fork",
    description: "Fork a checkpoint into a NEW workdir as an independent branch root (arch primitive fork). fork_target must be a path that does NOT yet exist (or is empty); it cannot equal the source workdir. CRITICAL semantics: the fork copies a checkpoint, so the new workdir ALREADY has a session state — to test a fresh hypothesis use ipl_run kind=start (fresh GP from input_def) or kind=advance (continue from the forked checkpoint). Do NOT use kind=full in a forked workdir: full internally calls start which, seeing an existing checkpoint, restores it with 0 iterations and legalizes stale state (produces invalid evidence). decision_label tags the new branch root hypothesis.",
    parameters: p({ workdir: { type: "string", required: true }, fork_target: { type: "string", required: true }, checkpoint: { type: "string" }, decision_label: { type: "string" } }),
    output: out(),
    execute: async (args) => run(["fork", "--workdir", String(args.workdir),
      ...(args.checkpoint ? ["--checkpoint", String(args.checkpoint)] : []),
      "--fork-target", String(args.fork_target),
      ...(args.decision_label ? ["--decision-label", String(args.decision_label)] : [])]),
  }));

  ctx.tools.register(defineTool({
    name: "branch_prune",
    description: "Mark branch nodes dead (arch primitive prune). The workdir is kept for metrics audit; nodes are marked pruned. prune_node optional: when omitted, all alive nodes in the worktree are pruned.",
    parameters: p({ workdir: { type: "string", required: true }, prune_node: { type: "string" } }),
    output: out(),
    execute: async (args) => run(["prune", "--workdir", String(args.workdir),
      ...(args.prune_node ? ["--prune-node", String(args.prune_node)] : [])]),
  }));
}

export { Config, inject, name };
