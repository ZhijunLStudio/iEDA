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
	ctx.tools.register(defineTool({
		name: "ieda_gp_baselines",
		description: "List registered iEDA designs/PDKs, Innovus baseline HPWL, and the best iEDA GP result committed so far. Call this first to select a design.",
		parameters: {},
		output: {
			schema: commonResultSchema(),
			render: (_args, value) => jsonContent(value)
		},
		isConcurrencySafe: () => true,
		execute: async () => {
			const designs = readDesigns(config.iedaRoot);
			const out = {};
			for (const [design, record] of Object.entries(designs)) {
				const hpwl = Number(record.innovus_hpwl);
				const best = Number(record.ieda_best_hpwl);
				out[design] = {
					pdk: record.pdk,
					innovus_hpwl: hpwl,
					ieda_best_hpwl: best,
					ieda_improvement_pct: hpwl > 0 ? Math.round((1 - best / hpwl) * 1e5) / 1e3 : 0,
					case_root: record.case_root,
					input_def: record.input_def,
					pl_config: record.pl_config,
					notes: record.notes
				};
			}
			return asJson(out);
		}
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
	ctx.tools.register(defineTool({
		name: "ieda_gp_eval_def",
		description: "Evaluate a placement DEF with the canonical HPWL script and compare it against the Innovus baseline.",
		parameters: {
			design: {
				type: "string",
				required: true
			},
			def_path: {
				type: "string",
				required: true,
				description: "Absolute path of the placement DEF."
			}
		},
		output: {
			schema: commonResultSchema(),
			render: (_args, value) => jsonContent(value)
		},
		execute: async (args) => {
			const record = readDesigns(config.iedaRoot)[args.design];
			if (!record) throw new Error(`unknown design ${JSON.stringify(args.design)}`);
			const lef = join(config.iedaRoot, "scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef");
			const result = await runCli(config.iedaRoot, config.python, config.timeoutMs, join(config.iedaRoot, "benchmarks/flows/def_hpwl_eval.py"), [lef, resolve(args.def_path)]);
			const match = /HPWL=(\d+)/.exec(String(result.stdout ?? ""));
			if (!match) return asJson({
				ok: false,
				error: "could not parse def_hpwl_eval HPWL",
				result
			});
			const hpwl = Number(match[1]);
			const innovus = Number(record.innovus_hpwl);
			return asJson({
				design: args.design,
				def: args.def_path,
				hpwl,
				innovus_hpwl: innovus,
				ratio: Math.round(hpwl / innovus * 1e6) / 1e6,
				improvement_pct_vs_innovus: Math.round((1 - hpwl / innovus) * 1e5) / 1e3
			});
		}
	}));
	ctx.tools.register(defineTool({
		name: "ieda_gp_full_compare",
		description: "Run the full iEDA GP->LG->DP placement flow for one design and compare against the Innovus noPrePlaceOpt DEF with the same HPWL script.",
		parameters: {
			design: {
				type: "string",
				required: true
			},
			result_root: {
				type: "string",
				required: true,
				description: "Absolute output directory for run_ipl_full_compare.py."
			},
			timing: {
				type: "boolean",
				description: "true enables timing-driven GP."
			}
		},
		output: {
			schema: commonResultSchema(),
			render: (_args, value) => jsonContent(value)
		},
		execute: async (args) => asJson(await runtime.fullCompare(args.design, args.result_root, args.timing ?? false))
	}));
}
//#endregion
export { Config, apply, inject, name };
