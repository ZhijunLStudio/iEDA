import z from "@deepseek-ai/schemastery";
import { defineTool } from "@deepseek-ai/dsh-tools";
import { execFile } from "node:child_process";
import { appendFileSync, readFileSync, mkdirSync } from "node:fs";
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
// reload-marker v2
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
const GP_TOOL_VERSION = "2";
async function cachedRun(workdir, key, source, runner, budget = 128) {
const dir = resolve(workdir);
mkdirSync(dir, { recursive: true });
const cacheFile = join(dir, "gp_agent_cache.jsonl");
let rows = [];
try {
rows = readFileSync(cacheFile, "utf8").split("\n").filter(Boolean).map((line) => JSON.parse(line));
} catch (_) {}
if (rows.length >= budget) {
return asJson({ ok: false, reason: `gp action budget exhausted (${budget}) in ${dir}`, cached: false });
}
const hit = rows.find((row) => row.key === GP_TOOL_VERSION + ":" + key);
if (hit) {
return { ...hit.result, cached: true };
}
const result = await runner();
if (result && typeof result === "object" && result.ok !== undefined) {
rows.push({ ts: Date.now(), source, key: GP_TOOL_VERSION + ":" + key, result });
appendFileSync(cacheFile, JSON.stringify(rows[rows.length - 1]) + "\n");
}
return result;
}
function trace(workdir, entry) {
if (!workdir) return;
try {
mkdirSync(resolve(workdir), { recursive: true });
appendFileSync(join(resolve(workdir), "gp_agent_trace.jsonl"), JSON.stringify({ ts: Date.now(), ...entry }) + "\n");
} catch (_) {}
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
	foundryDir(design) {
		const record = readDesigns(this.iedaRoot)[design] || {};
		return record.foundry_dir || join(this.iedaRoot, "scripts/foundry/sky130");
	}
	async agent(design, workdir, args, inputDef, foundryDir) {
		const record = readDesigns(this.iedaRoot)[design];
		if (!record) throw new Error(`unknown design ${JSON.stringify(design)}; known designs: ${knownDesigns(this.iedaRoot).join(", ")}`);
		const [command, ...rest] = args;
		const key = JSON.stringify({ design, command, args: rest, inputDef: inputDef || record.input_def, foundryDir: foundryDir || record.foundry_dir });
		return cachedRun(workdir, key, "ieda_gp_run", async () => {
			const value = await runCli(this.iedaRoot, this.python, this.timeoutMs, this.script("gp_agent.py"), [
				command,
				"--workdir",
				resolve(workdir),
				"--case-root",
				String(record.case_root),
				"--input-def",
				String(inputDef || record.input_def),
				"--config",
				String(record.pl_config),
				"--foundry-dir",
				String(foundryDir || record.foundry_dir || join(this.iedaRoot, "scripts/foundry/sky130")),
				...rest
			]);
			trace(workdir, { source: "ieda_gp_run", design, args, result: value });
			return value;
		});
	}
	async toolbox(args) {
		const wi = args.indexOf("--workdir");
		const workdir = wi >= 0 ? args[wi + 1] : null;
		if (!workdir) return runCli(this.iedaRoot, this.python, this.timeoutMs, this.script("gp_toolbox.py"), args);
		const key = JSON.stringify({ args });
		return cachedRun(workdir, key, "ieda_gp_observe", async () => {
			const value = await runCli(this.iedaRoot, this.python, this.timeoutMs, this.script("gp_toolbox.py"), args);
			trace(workdir, { source: "ieda_gp_observe", args, result: value });
			return value;
		});
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
const p = (extra = {}) => ({ kind: { type: "string", required: true }, ...extra });
const out = () => ({ schema: commonResultSchema(), render: (_args, value) => jsonContent(value) });
const toolbox = async (args) => asJson(await runtime.toolbox(args));
const agent = async (args, cliArgs) => asJson(await runtime.agent(args.design, args.workdir, cliArgs, args.input_def, args.foundry_dir));
const restore = async (args) => asJson(await runCli(config.iedaRoot, config.python, config.timeoutMs, join(config.iedaRoot, "benchmarks/flows/gp_agent.py"), ["restore", "--workdir", resolve(args.workdir), ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]));
const scopeArgs = (args) => ["--scope", args.scope ?? "region", "--scope-active-ratio", String(args.scope_active_ratio ?? 0.2), "--scope-active-count", String(args.scope_active_count ?? 100), "--scope-instances", args.scope_instances ?? "", "--scope-region", args.scope_region ?? "", "--halo-coeff", String(args.halo_coeff ?? 0.5), "--halo-hops", String(args.halo_hops ?? 1), "--scope-density-target", String(args.scope_density_target ?? 1), "--scope-density-ratio", String(args.scope_density_ratio ?? 0), "--scope-anneal-ratio", String(args.scope_anneal_ratio ?? 0), "--overflow-penalty", String(args.overflow_penalty ?? 0)];
const freezeRun = async (args) => {
const fz = await runtime.toolbox(["freeze_instances", "--workdir", resolve(args.workdir), "--region", args.region, ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
if (!fz.ok) return asJson(fz);
return asJson(await runtime.agent(args.design, args.workdir, ["local_run", "--iterations", String(args.iterations ?? 10), "--scope", "instances", "--scope-instances", String(fz.scope_instances), "--halo-hops", String(args.halo_hops ?? 0), "--halo-coeff", String(args.halo_coeff ?? 0.5), ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]));
};

ctx.tools.register(defineTool({
name: "ieda_gp_observe",
description: "Read EDA-side facts (no side effects). kind: status (current metrics with availability/units), checkpoints (all checkpoints), grid (raw top density bins), hotspots (density hotspots), longnets (highest-HPWL nets), unstable (most-moved cells between checkpoint_a and checkpoint_b), trajectory (append-only batch history). Use top_n=0 for full grid/batch history.",
parameters: p({ workdir: { type: "string", required: true }, checkpoint: { type: "string" }, checkpoint_a: { type: "string" }, checkpoint_b: { type: "string" }, top_n: { type: "integer" }, def_path: { type: "string" }, region: { type: "string" } }),
output: out(),
execute: async (args) => {
if (args.kind === "status") return toolbox(["status", "--workdir", resolve(args.workdir), ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
if (args.kind === "checkpoints") return toolbox(["checkpoints", "--workdir", resolve(args.workdir)]);
if (args.kind === "grid") return toolbox(["grid", "--workdir", resolve(args.workdir), "--top-n", String(args.top_n ?? 8), ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
if (args.kind === "hotspots") return toolbox(["hotspots", "--workdir", resolve(args.workdir), "--top-n", String(args.top_n ?? 5), ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
if (args.kind === "longnets") return toolbox(["longnets", "--workdir", resolve(args.workdir), "--top-n", String(args.top_n ?? 5), ...args.def_path ? ["--def-path", args.def_path] : [], ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
if (args.kind === "unstable") return toolbox(["unstable", "--workdir", resolve(args.workdir), "--checkpoint-a", args.checkpoint_a, "--checkpoint-b", args.checkpoint_b, "--top-n", String(args.top_n ?? 5)]);
if (args.kind === "trajectory") return toolbox(["trajectory", "--workdir", resolve(args.workdir), "--top-n", String(args.top_n ?? 0)]);
throw new Error("ieda_gp_observe: kind must be status|checkpoints|grid|hotspots|longnets|unstable|trajectory");
}
}));

ctx.tools.register(defineTool({
name: "ieda_gp_propose",
description: "Propose GP actions without changing state. kind: regions (executable region rectangles), region_density (suggested density target for a region), freeze (cells that would be frozen), longnet_instances (concrete instance sets for the highest-HPWL nets, directly usable as scope=instances). prediction_status is unavailable until a predictor exists.",
parameters: p({ workdir: { type: "string", required: true }, checkpoint: { type: "string" }, priority: { type: "string" }, top_n: { type: "integer" }, min_cell_count: { type: "integer" }, max_cell_count: { type: "integer" }, def_path: { type: "string" }, region: { type: "string" } }),
output: out(),
execute: async (args) => {
if (args.kind === "regions") return toolbox(["propose_regions", "--workdir", resolve(args.workdir), "--priority", args.priority ?? "density", "--top-n", String(args.top_n ?? 5), "--min-cell-count", String(args.min_cell_count ?? 20), "--max-cell-count", String(args.max_cell_count ?? 200), ...args.def_path ? ["--def-path", args.def_path] : [], ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
if (args.kind === "region_density") return toolbox(["propose_region_density", "--workdir", resolve(args.workdir), "--region", args.region, ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
if (args.kind === "freeze") return toolbox(["propose_freeze", "--workdir", resolve(args.workdir), "--region", args.region, ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
if (args.kind === "longnet_instances") return toolbox(["propose_longnet_instances", "--workdir", resolve(args.workdir), "--top-n", String(args.top_n ?? 5), ...args.def_path ? ["--def-path", args.def_path] : [], ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
throw new Error("ieda_gp_propose: kind must be regions|region_density|freeze|longnet_instances");
}
}));

ctx.tools.register(defineTool({
name: "ieda_gp_run",
description: "Execute GP actions. kind: start, advance, candidate, local_run, apply_freeze, apply_region_density, local_restart, apply_anchor. local_restart runs one local/global candidate, accepts the local child (set force_local=1 to force it even when the instant verdict is not left_better), then starts a fresh random_init=0 global GP from that placement; it returns def HPWL for both the local restart and a same-budget raw-GP restart baseline.",
parameters: p({ design: { type: "string", required: true }, workdir: { type: "string", required: true }, input_def: { type: "string" }, foundry_dir: { type: "string" }, checkpoint: { type: "string" }, iterations: { type: "integer" }, seed: { type: "integer" }, random_init: { type: "integer" }, target_density: { type: "number" }, init_density_penalty: { type: "number" }, min_phi_coef: { type: "number" }, max_phi_coef: { type: "number" }, congestion_effort: { type: "integer" }, seed_anchor_strength: { type: "number" }, report_route_util: { type: "integer" }, scope: { type: "string" }, scope_seed: { type: "integer" }, scope_active_ratio: { type: "number" }, scope_active_count: { type: "integer" }, scope_instances: { type: "string" }, scope_region: { type: "string" }, halo_coeff: { type: "number" }, halo_hops: { type: "integer" }, overflow_penalty: { type: "number" }, scope_density_target: { type: "number" }, scope_density_ratio: { type: "number" }, scope_anneal_ratio: { type: "number" }, candidate_iterations: { type: "integer" }, restart_iterations: { type: "integer" }, force_local: { type: "integer" }, region: { type: "string" }, strength: { type: "number" } }),
output: out(),
execute: async (args) => {
const k = args.kind;
if (k === "start") return agent(args, ["start", "--iterations", String(args.iterations ?? 20), "--seed", String(args.seed ?? 1000), "--random-init", String(args.random_init ?? 1), "--seed-anchor-strength", String(args.seed_anchor_strength ?? 0), "--target-density", String(args.target_density ?? -1), ...args.init_density_penalty != null ? ["--init-density-penalty", String(args.init_density_penalty)] : [], ...args.min_phi_coef != null ? ["--min-phi-coef", String(args.min_phi_coef)] : [], ...args.max_phi_coef != null ? ["--max-phi-coef", String(args.max_phi_coef)] : [], "--congestion-effort", String(args.congestion_effort ?? -1), "--report-route-util", String(args.report_route_util ?? 1)]);
if (k === "advance") return agent(args, ["advance", "--iterations", String(args.iterations ?? 100), "--report-route-util", String(args.report_route_util ?? 1), ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
if (k === "candidate") return agent(args, ["candidate", "--iterations", String(args.iterations ?? 20), ...scopeArgs(args), ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
if (k === "local_run") return agent(args, ["local_run", "--iterations", String(args.iterations ?? 10), ...scopeArgs(args), ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
if (k === "local_restart") { const info = readDesigns(config.iedaRoot)[args.design] || {}; const cli = ["--design", args.design, "--workdir", resolve(args.workdir), ...args.checkpoint ? ["--checkpoint", args.checkpoint] : [], "--case-root", String(info.case_root), "--input-def", String(info.input_def), "--config", String(info.pl_config), "--foundry-dir", String(args.foundry_dir || runtime.foundryDir(args.design)), ...info.lef ? ["--lef", String(info.lef)] : [], ...info.gp_baseline_def ? ["--baseline-def", String(info.gp_baseline_def)] : [], "--scope", args.scope ?? "longnet", "--scope-active-count", String(args.scope_active_count ?? 100), "--scope-active-ratio", String(args.scope_active_ratio ?? 0.2), "--halo-hops", String(args.halo_hops ?? 2), "--halo-coeff", String(args.halo_coeff ?? 0.5), "--overflow-penalty", String(args.overflow_penalty ?? 0.005), "--scope-anneal-ratio", String(args.scope_anneal_ratio ?? 0), "--scope-density-target", String(args.scope_density_target ?? 1), "--candidate-iterations", String(args.candidate_iterations ?? 20), "--restart-iterations", String(args.restart_iterations ?? 600), "--seed", String(args.seed ?? 42), ...args.scope_seed != null ? ["--scope-seed", String(args.scope_seed)] : [], ...args.force_local == 1 ? ["--force-local"] : [], ...args.scope_region ? ["--scope-region", args.scope_region] : [], ...args.scope_instances ? ["--scope-instances", args.scope_instances] : []]; const key = JSON.stringify({ kind: "local_restart", design: args.design, checkpoint: args.checkpoint, scope: args.scope, scope_instances: args.scope_instances, scope_region: args.scope_region, scope_density_target: args.scope_density_target, scope_anneal_ratio: args.scope_anneal_ratio, overflow_penalty: args.overflow_penalty, force_local: args.force_local }); return asJson(await cachedRun(args.workdir, key, "ieda_gp_run", async () => await runCli(config.iedaRoot, config.python, config.timeoutMs, join(config.iedaRoot, "benchmarks/flows/gp_local_restart.py"), cli))); }
if (k === "apply_freeze") return freezeRun(args);
if (k === "apply_anchor") {
return asJson({ ok: false, unsupported: true, reason: "per-cell anchor is not implemented; use apply_freeze for strength=1 batch freeze" });
}
if (k === "apply_region_density") return agent(args, ["local_run", "--iterations", String(args.iterations ?? 10), "--scope", "region", "--scope-region", args.region, "--scope-density-target", String(args.scope_density_target ?? 1), "--scope-density-ratio", "1", "--halo-hops", String(args.halo_hops ?? 1), "--halo-coeff", String(args.halo_coeff ?? 0.5), ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
throw new Error("ieda_gp_run: kind must be start|advance|candidate|local_run|apply_freeze|apply_region_density|apply_anchor");
}
}));

ctx.tools.register(defineTool({
name: "ieda_gp_verify",
description: "Verify GP results. kind: delta (metric delta between checkpoints), lg (read-only LG oracle), metrics (same-evaluator HPWL/density/RUDY/timing across raw DEF and candidate DEF). For metrics set timing=0 to skip timing on PDKs without the timing evaluator.",
parameters: p({ design: { type: "string" }, workdir: { type: "string", required: true }, checkpoint: { type: "string" }, checkpoint_a: { type: "string" }, checkpoint_b: { type: "string" }, def_path: { type: "string" }, raw_def: { type: "string" }, candidate_def: { type: "string" }, timing: { type: "integer" } }),
output: out(),
execute: async (args) => {
if (args.kind === "delta") return toolbox(["verify_delta", "--workdir", resolve(args.workdir), "--checkpoint-a", args.checkpoint_a, "--checkpoint-b", args.checkpoint_b, ...args.def_path ? ["--def-path", args.def_path] : []]);
if (args.kind === "lg") return asJson(await runtime.agent(args.design ?? "s1238", args.workdir, ["verify_lg", ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]));
if (args.kind === "metrics") { const info = readDesigns(config.iedaRoot)[args.design] || {}; const cmd = [join(config.iedaRoot, "benchmarks/flows/gp_metrics_compare.py"), "--design", args.design, "--case-root", String(info.case_root), "--macro-lef", String(info.lef || join(config.iedaRoot, "scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef")), "--foundry-dir", String(runtime.foundryDir(args.design)), ...args.timing === 0 ? ["--no-timing"] : [], "--out", join(resolve(args.workdir), "gp_metrics_compare.json"), ...args.raw_def ? ["raw=" + args.raw_def] : [], ...args.candidate_def ? ["candidate=" + args.candidate_def] : []]; return asJson(await runCli(config.iedaRoot, config.python, config.timeoutMs, cmd[0], cmd.slice(1))); }
throw new Error("ieda_gp_verify: kind must be delta|lg|metrics");
}
}));

ctx.tools.register(defineTool({
name: "ieda_gp_session",
description: "Manage the GP session state. kind: restore (point workdir at a checkpoint), accept (commit winner and write placement.def), unfreeze (batch-scoped freeze is already cleared), clear_density (batch-scoped density target is already cleared).",
parameters: p({ design: { type: "string" }, workdir: { type: "string", required: true }, checkpoint: { type: "string" } }),
output: out(),
execute: async (args) => {
if (args.kind === "restore") return restore(args);
if (args.kind === "accept") return asJson(await runtime.agent(args.design ?? "s1238", args.workdir, ["accept", ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]));
if (args.kind === "unfreeze" || args.kind === "clear_density") return asJson({ ok: true, note: "batch-scoped state is already cleared", workdir: resolve(args.workdir), checkpoint: args.checkpoint ?? null });
throw new Error("ieda_gp_session: kind must be restore|accept|unfreeze|clear_density");
}
}));
}
export { Config, apply, inject, name };
// reload-marker-20260819-a
