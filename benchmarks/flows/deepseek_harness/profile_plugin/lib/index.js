import z from "@deepseek-ai/schemastery";
import { defineTool } from "@deepseek-ai/dsh-tools";
import { execFile } from "node:child_process";
import { readFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { promisify } from "node:util";
//#region lib/types/index.js
/**
* First-party native DeepSeek Harness tool plugin for the iEDA GP agent.
*
* This is the native-plugin form: it registers seven model-facing tools
* directly on `ctx.tools` through `defineTool` and executes the same iEDA
* Python CLIs that the manual GP experiments use. No MCP subprocess bridge is
* involved.
*
* @module @deepseek-ai/dsh-tool-ieda-gp
*/
const execFileAsync = promisify(execFile);
const name = "tool-ieda-gp";
const inject = ["tools"];
const Config = z.object({
	iedaRoot: z.string().required(),
	python: z.string().default("python3"),
	timeoutMs: z.number().step(1).min(1e3).default(72e5)
});
function readDesigns(iedaRoot) {
	const path = join(iedaRoot, "benchmarks/flows/deepseek_harness/designs.json");
	return JSON.parse(readFileSync(path, "utf8"));
}
function knownDesigns(iedaRoot) {
	return Object.keys(readDesigns(iedaRoot));
}
function tail(value, max = 12e3) {
	return value.length > max ? value.slice(-max) : value;
}
async function runCli(iedaRoot, python, timeoutMs, script, args) {
	try {
		const { stdout, stderr } = await execFileAsync(python, [script, ...args], {
			cwd: iedaRoot,
			timeout: timeoutMs,
			maxBuffer: 32 * 1024 * 1024
		});
		const text = tail(stdout);
		try {
			return JSON.parse(stdout);
		} catch {
			return {
				ok: false,
				rc: 0,
				stdout: text,
				stderr_tail: tail(stderr)
			};
		}
	} catch (error) {
		const err = error;
		return {
			ok: false,
			rc: typeof err.code === "number" ? err.code : 1,
			error: err.message,
			stdout: tail(err.stdout ?? ""),
			stderr_tail: tail(err.stderr ?? "")
		};
	}
}
function jsonContent(value) {
	return [{
		type: "text",
		text: JSON.stringify(value, null, 2)
	}];
}
function commonResultSchema() {
	return { type: "json" };
}
function asJson(value) {
	return value;
}
/** One shared execution context for every registered tool. */
var IedaGpRuntime = class {
	iedaRoot;
	python;
	timeoutMs;
	constructor(iedaRoot, python, timeoutMs) {
		this.iedaRoot = iedaRoot;
		this.python = python;
		this.timeoutMs = timeoutMs;
	}
	script(name) {
		return join(this.iedaRoot, "benchmarks/flows", name);
	}
	async agent(design, workdir, args) {
		const record = readDesigns(this.iedaRoot)[design];
		if (!record) throw new Error(`unknown design ${JSON.stringify(design)}; known designs: ${knownDesigns(this.iedaRoot).join(", ")}`);
		return runCli(this.iedaRoot, this.python, this.timeoutMs, this.script("gp_agent.py"), [
			"--workdir",
			resolve(workdir),
			"--case-root",
			String(record.case_root),
			"--input-def",
			String(record.input_def),
			"--config",
			String(record.pl_config),
			...args
		]);
	}
	async toolbox(args) {
		return runCli(this.iedaRoot, this.python, this.timeoutMs, this.script("gp_toolbox.py"), args);
	}
async fullCompare(design, resultRoot, timing) {
		if (!readDesigns(this.iedaRoot)[design]) throw new Error(`unknown design ${JSON.stringify(design)}; known designs: ${knownDesigns(this.iedaRoot).join(", ")}`);
		return runCli(this.iedaRoot, this.python, this.timeoutMs, this.script("run_ipl_full_compare.py"), [
			"--designs",
			design,
			"--result-root",
			resolve(resultRoot),
			...timing ? ["--timing"] : []
		]);
	}
};
function apply(ctx, config) {
	const runtime = new IedaGpRuntime(resolve(config.iedaRoot), config.python, config.timeoutMs);
const toolboxTool = (name, description, argsFn) => ctx.tools.register(defineTool({
name,
description,
parameters: {
workdir: { type: "string", required: true },
checkpoint: { type: "string" },
top_n: { type: "integer" },
priority: { type: "string" },
min_cell_count: { type: "integer" },
max_cell_count: { type: "integer" },
def_path: { type: "string" },
region: { type: "string" },
checkpoint_a: { type: "string" },
checkpoint_b: { type: "string" }
},
output: { schema: commonResultSchema(), render: (_args, value) => jsonContent(value) },
execute: async (args) => asJson(await runtime.toolbox(argsFn(args)))
}));
toolboxTool("ieda_gp_design_status", "Report current GP checkpoint metrics with availability and staleness fields.", a => ["status", "--workdir", resolve(a.workdir), ...a.checkpoint ? ["--checkpoint", a.checkpoint] : []]);
toolboxTool("ieda_gp_checkpoint_list", "List every GP checkpoint in the workdir.", a => ["checkpoints", "--workdir", resolve(a.workdir)]);
toolboxTool("ieda_gp_grid_report", "Return top density-overflow GP bins.", a => ["grid", "--workdir", resolve(a.workdir), "--top-n", String(a.top_n ?? 8), ...a.checkpoint ? ["--checkpoint", a.checkpoint] : []]);
toolboxTool("ieda_gp_diagnose_hotspots", "Diagnose density hotspots.", a => ["hotspots", "--workdir", resolve(a.workdir), "--top-n", String(a.top_n ?? 5), ...a.checkpoint ? ["--checkpoint", a.checkpoint] : []]);
toolboxTool("ieda_gp_diagnose_longnets", "Diagnose highest-HPWL nets.", a => ["longnets", "--workdir", resolve(a.workdir), "--top-n", String(a.top_n ?? 5), ...a.def_path ? ["--def-path", a.def_path] : [], ...a.checkpoint ? ["--checkpoint", a.checkpoint] : []]);
toolboxTool("ieda_gp_propose_regions", "Let iEDA propose concrete local-GP regions from priority and size bounds.", a => ["propose_regions", "--workdir", resolve(a.workdir), "--priority", a.priority ?? "density", "--top-n", String(a.top_n ?? 5), "--min-cell-count", String(a.min_cell_count ?? 20), "--max-cell-count", String(a.max_cell_count ?? 200), ...a.def_path ? ["--def-path", a.def_path] : [], ...a.checkpoint ? ["--checkpoint", a.checkpoint] : []]);
toolboxTool("ieda_gp_propose_region_density", "Propose a scoped density target for a rectangular GP region.", a => ["propose_region_density", "--workdir", resolve(a.workdir), "--region", a.region, ...a.checkpoint ? ["--checkpoint", a.checkpoint] : []]);
toolboxTool("ieda_gp_diagnose_unstable", "Compare two checkpoints and report the most-moved cells.", a => ["unstable", "--workdir", resolve(a.workdir), "--checkpoint-a", a.checkpoint_a, "--checkpoint-b", a.checkpoint_b, "--top-n", String(a.top_n ?? 5)]);
toolboxTool("ieda_gp_verify_delta", "Verify metric delta between two comparable checkpoints.", a => ["verify_delta", "--workdir", resolve(a.workdir), "--checkpoint-a", a.checkpoint_a, "--checkpoint-b", a.checkpoint_b]);
ctx.tools.register(defineTool({
name: "ieda_gp_local_run",
description: "Run local GP for a scoped cell set without a global control branch.",
parameters: {
design: { type: "string", required: true },
workdir: { type: "string", required: true },
checkpoint: { type: "string" },
iterations: { type: "integer" },
scope: { type: "string" },
scope_region: { type: "string" },
scope_active_count: { type: "integer" },
scope_active_ratio: { type: "number" },
halo_hops: { type: "integer" },
halo_coeff: { type: "number" },
scope_density_target: { type: "number" },
scope_density_ratio: { type: "number" }
},
output: { schema: commonResultSchema(), render: (_args, value) => jsonContent(value) },
execute: async (args) => asJson(await runtime.agent(args.design, args.workdir, ["local_run", "--iterations", String(args.iterations ?? 10), "--scope", args.scope ?? "region", "--scope-region", args.scope_region ?? "", "--scope-active-count", String(args.scope_active_count ?? 100), "--scope-active-ratio", String(args.scope_active_ratio ?? 0.2), "--halo-hops", String(args.halo_hops ?? 1), "--halo-coeff", String(args.halo_coeff ?? 0.5), "--scope-density-target", String(args.scope_density_target ?? 1), "--scope-density-ratio", String(args.scope_density_ratio ?? 0), ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]))
}));
toolboxTool("ieda_gp_propose_freeze", "Return the cell set that would be frozen inside a rectangular region for one batch.", a => ["propose_freeze", "--workdir", resolve(a.workdir), "--region", a.region, ...a.checkpoint ? ["--checkpoint", a.checkpoint] : []]);
ctx.tools.register(defineTool({
name: "ieda_gp_apply_freeze",
description: "Freeze the cells inside a region for one GP batch and move the complement. Batch-scoped: the freeze clears automatically when the batch ends.",
parameters: {
design: { type: "string", required: true },
workdir: { type: "string", required: true },
region: { type: "string", required: true, description: "llx lly urx ury" },
checkpoint: { type: "string" },
iterations: { type: "integer" },
halo_hops: { type: "integer" },
halo_coeff: { type: "number" }
},
output: { schema: commonResultSchema(), render: (_args, value) => jsonContent(value) },
execute: async (args) => {
const fz = await runtime.toolbox(["freeze_instances", "--workdir", resolve(args.workdir), "--region", args.region, ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
if (!fz.ok) return asJson(fz);
return asJson(await runtime.agent(args.design, args.workdir, ["local_run", "--iterations", String(args.iterations ?? 10), "--scope", "instances", "--scope-instances", String(fz.scope_instances), "--halo-hops", String(args.halo_hops ?? 0), "--halo-coeff", String(args.halo_coeff ?? 0.5), ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]));
}
}));
ctx.tools.register(defineTool({
name: "ieda_gp_unfreeze",
description: "Freeze is batch-scoped in the current GP implementation, so no persistent freeze state exists. Returns the current checkpoint for continuation.",
parameters: { workdir: { type: "string", required: true }, checkpoint: { type: "string" } },
output: { schema: commonResultSchema(), render: (_args, value) => jsonContent(value) },
execute: async (args) => asJson({ ok: true, note: "batch-scoped freeze already cleared", workdir: resolve(args.workdir), checkpoint: args.checkpoint ?? null })
}));
ctx.tools.register(defineTool({
name: "ieda_gp_clear_region_density",
description: "Region density targets are batch-scoped and clear automatically; this returns the current checkpoint for continuation.",
parameters: { workdir: { type: "string", required: true }, checkpoint: { type: "string" } },
output: { schema: commonResultSchema(), render: (_args, value) => jsonContent(value) },
execute: async (args) => asJson({ ok: true, note: "batch-scoped density target already cleared", workdir: resolve(args.workdir), checkpoint: args.checkpoint ?? null })
}));
	ctx.tools.register(defineTool({
		name: "ieda_gp_start",
		description: "Start a new iEDA global-placement session for a registered design. A fresh workdir is required for each independent search; use ieda_gp_candidate or ieda_gp_advance afterwards.",
		parameters: {
			design: {
				type: "string",
				required: true,
				description: "Registered design name, e.g. s1238."
			},
			workdir: {
				type: "string",
				required: true,
				description: "Absolute empty/new work directory for the GP session."
			},
			iterations: {
				type: "integer",
				description: "Iterations in the first batch."
			},
			random_init: {
				type: "integer",
				description: "1 = random initial placement (default), 0 = keep current coordinates."
			},
			seed: {
				type: "integer",
				description: "Random placement seed."
			},
			target_density: {
				type: "number",
				description: "Explicit GP target density in (0,1); -1 keeps config default."
			},
			congestion_effort: {
				type: "integer",
				description: "-1 config default, 0 off, 1 on."
			},
			seed_anchor_strength: {
				type: "number",
				description: "0..1; with random_init=0, blend each solver step toward start coordinates."
			},
			report_route_util: {
				type: "integer",
				description: "1 prints RUDY route utilization."
			}
		},
		output: {
			schema: commonResultSchema(),
			render: (_args, value) => jsonContent(value)
		},
		execute: async (args) => asJson(await runtime.agent(args.design, args.workdir, [
			"start",
			"--iterations",
			String(args.iterations ?? 20),
			"--seed",
			String(args.seed ?? 1e3),
			"--random-init",
			String(args.random_init ?? 1),
			"--seed-anchor-strength",
			String(args.seed_anchor_strength ?? 0),
			"--target-density",
			String(args.target_density ?? -1),
			"--congestion-effort",
			String(args.congestion_effort ?? -1),
			"--report-route-util",
			String(args.report_route_util ?? 1)
		]))
	}));
	ctx.tools.register(defineTool({
		name: "ieda_gp_candidate",
		description: "Run one local-vs-global GP candidate pair from a checkpoint. The returned verdict is a safe Pareto/score decision; keep the winning branch checkpoint for the next stage.",
		parameters: {
			design: {
				type: "string",
				required: true
			},
			workdir: {
				type: "string",
				required: true
			},
			iterations: {
				type: "integer",
				description: "Candidate branch budget, usually 20-80."
			},
			scope: {
				type: "string",
				description: "global, hotspot, random, instances, region, or longnet."
			},
			scope_active_ratio: {
				type: "number",
				description: "Hotspot top-bin ratio, e.g. 0.2."
			},
			scope_active_count: {
				type: "integer",
				description: "Active instance count for random/longnet."
			},
			scope_region: {
				type: "string",
				description: "Four integers \"llx lly urx ury\" for region scope."
			},
			halo_coeff: {
				type: "number",
				description: "Halo movement coefficient in [0,1]."
			},
			halo_hops: {
				type: "integer",
				description: "Net-hop radius of the halo."
			},
			overflow_penalty: {
				type: "number",
				description: "Score penalty for overflow when candidates do not dominate."
			},
			scope_density_target: {
				type: "number",
				description: "Scoped grid capacity factor in (0,1]."
			},
			scope_density_ratio: {
				type: "number",
				description: "Hotspot density-screen top ratio in [0,1]."
			},
			checkpoint: {
				type: "string",
				description: "Parent checkpoint; omit to use the workdir latest checkpoint."
			}
		},
		output: {
			schema: commonResultSchema(),
			render: (_args, value) => jsonContent(value)
		},
		execute: async (args) => asJson(await runtime.agent(args.design, args.workdir, [
			"candidate",
			"--iterations",
			String(args.iterations ?? 20),
			"--scope",
			args.scope ?? "longnet",
			"--scope-active-ratio",
			String(args.scope_active_ratio ?? .2),
			"--scope-active-count",
			String(args.scope_active_count ?? 100),
			"--scope-region",
			args.scope_region ?? "",
			"--halo-coeff",
			String(args.halo_coeff ?? .5),
			"--halo-hops",
			String(args.halo_hops ?? 2),
			"--overflow-penalty",
			String(args.overflow_penalty ?? 2),
			"--scope-density-target",
			String(args.scope_density_target ?? 1),
			"--scope-density-ratio",
			String(args.scope_density_ratio ?? 0),
			...args.checkpoint ? ["--checkpoint", args.checkpoint] : []
		]))
	}));
	ctx.tools.register(defineTool({
		name: "ieda_gp_advance",
		description: "Advance an existing iEDA GP session toward its overflow target.",
		parameters: {
			design: {
				type: "string",
				required: true
			},
			workdir: {
				type: "string",
				required: true
			},
			iterations: {
				type: "integer",
				description: "Iterations to run."
			},
			checkpoint: {
				type: "string",
				description: "Optional explicit checkpoint; omit for workdir latest."
			},
			report_route_util: {
				type: "integer",
				description: "1 prints RUDY route utilization."
			}
		},
		output: {
			schema: commonResultSchema(),
			render: (_args, value) => jsonContent(value)
		},
		execute: async (args) => asJson(await runtime.agent(args.design, args.workdir, [
			"advance",
			"--iterations",
			String(args.iterations ?? 100),
			"--report-route-util",
			String(args.report_route_util ?? 1),
			...args.checkpoint ? ["--checkpoint", args.checkpoint] : []
		]))
	}));
	ctx.tools.register(defineTool({
		name: "ieda_gp_verify_lg",
		description: "Run LG as a read-only oracle for a checkpoint: restores it in a throwaway workdir, runs placer_run_lg, and reports post-LG HPWL, max/avg displacement, and fidelity=lg.",
		parameters: {
			design: { type: "string", required: true },
			workdir: { type: "string", required: true },
			checkpoint: { type: "string" }
		},
		output: { schema: commonResultSchema(), render: (_args, value) => jsonContent(value) },
		execute: async (args) => asJson(await runtime.agent(args.design, args.workdir, ["verify_lg", ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]))
	}));
	ctx.tools.register(defineTool({
		name: "ieda_gp_accept",
		description: "Commit a GP checkpoint into the design and write placement.def under the workdir. Use this after a winning candidate or a converged advance to a placement DEF file.",
		parameters: {
			design: {
				type: "string",
				required: true
			},
			workdir: {
				type: "string",
				required: true
			},
			checkpoint: {
				type: "string",
				description: "Optional checkpoint to commit; omit for the workdir latest checkpoint."
			}
		},
		output: {
			schema: commonResultSchema(),
			render: (_args, value) => jsonContent(value)
		},
		execute: async (args) => {
			const result = await runtime.agent(args.design, args.workdir, [
				"accept",
				...args.checkpoint ? ["--checkpoint", args.checkpoint] : []
			]);
			return asJson({
				...result,
				placement_def: join(resolve(args.workdir), "placement.def")
			});
		}
	}));
	ctx.tools.register(defineTool({
		name: "ieda_gp_report",
		description: "Report the current iEDA GP session state, experiment ledger record, and latest checkpoint.",
		parameters: { workdir: {
			type: "string",
			required: true
		} },
		output: {
			schema: commonResultSchema(),
			render: (_args, value) => jsonContent(value)
		},
		execute: async (args) => {
			const workdir = resolve(args.workdir);
			const readJson = (file) => {
				try {
					return JSON.parse(readFileSync(join(workdir, file), "utf8"));
				} catch {
					return null;
				}
			};
			return asJson({
				state: readJson("gp_agent_state.json"),
				last_ledger: readJson("pl/gp_experiments.jsonl"),
				search: readJson("search.json")
			});
		}
	}));
}
//#endregion
export { Config, apply, inject, name };
