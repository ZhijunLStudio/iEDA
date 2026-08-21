import z from "@deepseek-ai/schemastery";
import { defineTool } from "@deepseek-ai/dsh-tools";
import { execFile } from "node:child_process";
import { appendFileSync, readFileSync, mkdirSync, existsSync, copyFileSync, statSync } from "node:fs";
import { join, resolve, dirname } from "node:path";
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
		try {
			const parsed = JSON.parse(err.stdout ?? "");
			if (parsed && typeof parsed === "object") return parsed;
		} catch {}
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
const GP_TOOL_VERSION = "4";
async function cachedRun(workdir, key, source, runner, budget) {
if (budget === undefined) budget = source === "ieda_gp_run" ? 128 : 4000;
const dir = resolve(workdir);
mkdirSync(dir, { recursive: true });
const cacheFile = join(dir, "gp_agent_cache.jsonl");
let rows = [];
try {
rows = readFileSync(cacheFile, "utf8").split("\n").filter(Boolean).map((line) => JSON.parse(line));
} catch (_) {}
const sourceRows = rows.filter((row) => row.source === source).length;
if (sourceRows >= budget) {
return asJson({ ok: false, reason: source === "ieda_gp_run" ? `gp run-action budget exhausted (${budget} unique actions) in ${dir}; reuse identical arguments to hit the cache, or start a fresh workdir` : `gp ${source} cache full (${budget} entries) in ${dir}`, cached: false });
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
function inferDesignFromTrace(workdir) {
try {
const path = join(resolve(workdir), "gp_agent_trace.jsonl");
if (!existsSync(path)) return null;
const rows = readFileSync(path, "utf8").trim().split("\n").filter(Boolean);
for (let i = rows.length - 1; i >= 0; i--) {
try { const row = JSON.parse(rows[i]); if (row.design) return String(row.design); } catch (_) {}
}
} catch (_) {}
return null;
}
function archiveRunArtifacts(workdir) {
const root = resolve(workdir);
const placement = join(root, "placement.def");
if (!existsSync(placement)) return null;
const stamp = new Date().toISOString().replace(/[:.]/g, "-");
const target = join(root, "archive", stamp);
try {
mkdirSync(target, { recursive: true });
for (const name of ["placement.def", "gp_agent_state.json", "gp_metrics_compare.json", "pl/gp_session_checkpoint.json", "pl/gp_experiments.jsonl", "pl/gp_grid_report.json"]) {
const src = join(root, name);
if (existsSync(src)) { const dest = join(target, name); mkdirSync(dirname(dest), { recursive: true }); copyFileSync(src, dest); }
}
return target;
} catch (_) { return null; }
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
		// Run actions are state-dependent: the same argument list on a
		// different starting placement/checkpoint produces a different
		// result. Fingerprint the starting state so the cache only serves
		// truly identical (action, state) pairs.
		const stateDependent = ["advance", "local_run", "candidate", "local_congestion", "accept"].includes(command);
		const cpIdx = rest.indexOf("--checkpoint");
		const cpPath = stateDependent ? (cpIdx >= 0 ? String(rest[cpIdx + 1]) : join(resolve(workdir), "pl/gp_session_checkpoint.json")) : null;
		const stamp = (p) => existsSync(p) ? statSync(p).mtimeMs : "missing";
		const stateFp = stateDependent
			? { checkpoint: cpPath, checkpointMtime: stamp(cpPath), placementMtime: stamp(join(resolve(workdir), "placement.def")) }
			: { inputDef: inputDef || record.input_def, inputDefMtime: stamp(inputDef || record.input_def) };
		const key = JSON.stringify({ design, command, args: rest, inputDef: inputDef || record.input_def, foundryDir: foundryDir || record.foundry_dir, stateFp });
		return cachedRun(workdir, key, "ieda_gp_run", async () => {
			const lef = record.lef || join(this.iedaRoot, "scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef");
			// Only start establishes the input_def/config context; every other
			// command must inherit the workdir's saved context, otherwise a
			// session started from an alternate DEF (e.g. Innovus DEF) breaks
			// on the next restore with a topology mismatch.
			const isStart = command === "start";
			const value = await runCli(this.iedaRoot, this.python, this.timeoutMs, this.script("gp_agent.py"), [
				command,
				"--workdir",
				resolve(workdir),
				"--case-root",
				String(record.case_root),
				...isStart ? ["--input-def", String(inputDef || record.input_def), "--config", String(record.pl_config)] : [],
				"--foundry-dir",
				String(foundryDir || record.foundry_dir || join(this.iedaRoot, "scripts/foundry/sky130")),
				"--lef",
				lef,
				...rest
			]);
			trace(workdir, { source: "ieda_gp_run", design, args, result: value });
			return value;
		});
	}
	async toolbox(args) {
		const wi = args.indexOf("--workdir");
		const workdir = wi >= 0 ? args[wi + 1] : null;
		const value = await runCli(this.iedaRoot, this.python, this.timeoutMs, this.script("gp_toolbox.py"), args);
		if (workdir) trace(workdir, { source: "ieda_gp_observe", args, result: value });
		return value;
	}
async congestionObserve(design, workdir, defPath, topN, bins, foundryDir, model) {
const record = readDesigns(this.iedaRoot)[design] || {};
const actualDef = defPath || join(resolve(workdir), "placement.def");
const defStamp = existsSync(actualDef) ? statSync(actualDef).mtimeMs : "missing";
const key = JSON.stringify({ design, workdir: resolve(workdir), defPath: actualDef, defStamp, topN, bins, model });
return cachedRun(workdir, key, "ieda_gp_observe", async () => {
const value = await runCli(this.iedaRoot, this.python, this.timeoutMs, this.script("gp_congestion_observe.py"), [
"--case-root", String(record.case_root),
"--def", actualDef,
"--foundry-dir", String(foundryDir || this.foundryDir(design)),
"--workdir", resolve(workdir),
"--bin-cnt-x", String(bins ?? 64),
"--bin-cnt-y", String(bins ?? 64),
"--top-n", String(topN ?? 8),
				"--lef", String(record.lef || join(this.iedaRoot, "scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef")),
"--model", String(model ?? "rudy")
]);
trace(workdir, { source: "ieda_gp_observe", args: { design, defPath, topN, bins, model }, result: value });
return value;
});
}
async timingObserve(design, workdir, defPath, maxPath, foundryDir) {
const record = readDesigns(this.iedaRoot)[design] || {};
const actualDef = defPath || join(resolve(workdir), "placement.def");
const defStamp = existsSync(actualDef) ? statSync(actualDef).mtimeMs : "missing";
const key = JSON.stringify({ design, workdir: resolve(workdir), defPath: actualDef, defStamp, maxPath });
return cachedRun(workdir, key, "ieda_gp_observe", async () => {
const value = await runCli(this.iedaRoot, this.python, this.timeoutMs, this.script("gp_timing_paths.py"), [
"--case-root", String(record.case_root),
"--def", actualDef,
"--foundry-dir", String(foundryDir || this.foundryDir(design)),
"--workdir", resolve(workdir),
"--max-path", String(maxPath ?? 3)
]);
trace(workdir, { source: "ieda_gp_observe", args: { design, defPath, maxPath }, result: value });
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
description: "Read EDA-side facts (no side effects). kind: designs (list registered design/PDK presets), status (current metrics with availability/units), checkpoints (all checkpoints), grid (raw top density bins), hotspots (density hotspots), longnets (highest-HPWL nets), unstable (most-moved cells between checkpoint_a and checkpoint_b), trajectory (append-only batch history), experiments (aggregated action->metric table + Pareto view from this workdir's trace and archives; pass workdirs as comma-separated paths to merge other sessions), congestion_hotspots (runs read-only RUDY evaluator on a DEF and returns overflow regions; same evaluator as verify metrics, cached per DEF mtime - use it as the cheap post-action congestion check), timing_paths (runs the SAME run_timing_eval HPWL evaluator used by verify metrics, and returns worst paths with scope_instances; cached per DEF mtime - use it as the cheap post-action timing check). Use top_n=0 for full grid/batch history.",
parameters: p({ workdir: { type: "string" }, workdirs: { type: "string" }, design: { type: "string" }, checkpoint: { type: "string" }, checkpoint_a: { type: "string" }, checkpoint_b: { type: "string" }, top_n: { type: "integer" }, def_path: { type: "string" }, region: { type: "string" }, bin_cnt: { type: "integer" }, congestion_model: { type: "string" } }),
output: out(),
execute: async (args) => {
if (args.kind === "designs") return asJson({ ok: true, designs: readDesigns(config.iedaRoot) });
if (!args.workdir) return asJson({ ok: false, reason: args.kind + " requires workdir (except kind=designs)" });
if (args.kind === "status") return toolbox(["status", "--workdir", resolve(args.workdir), ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
if (args.kind === "checkpoints") return toolbox(["checkpoints", "--workdir", resolve(args.workdir)]);
if (args.kind === "grid") return toolbox(["grid", "--workdir", resolve(args.workdir), "--top-n", String(args.top_n ?? 8), ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
if (args.kind === "hotspots") return toolbox(["hotspots", "--workdir", resolve(args.workdir), "--top-n", String(args.top_n ?? 5), ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
if (args.kind === "longnets") return toolbox(["longnets", "--workdir", resolve(args.workdir), "--top-n", String(args.top_n ?? 5), ...args.def_path ? ["--def-path", args.def_path] : [], ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
if (args.kind === "unstable") return toolbox(["unstable", "--workdir", resolve(args.workdir), "--checkpoint-a", args.checkpoint_a, "--checkpoint-b", args.checkpoint_b, "--top-n", String(args.top_n ?? 5)]);
if (args.kind === "trajectory") return toolbox(["trajectory", "--workdir", resolve(args.workdir), "--top-n", String(args.top_n ?? 0)]);
if (args.kind === "experiments") return toolbox(["experiments", "--workdir", resolve(args.workdir), "--top-n", String(args.top_n ?? 40), ...args.workdirs ? ["--workdirs", String(args.workdirs)] : []]);
if (args.kind === "congestion_hotspots") { const design = args.design || inferDesignFromTrace(args.workdir); if (!design) return asJson({ ok: false, reason: "congestion_hotspots requires design" }); return asJson(await runtime.congestionObserve(design, args.workdir, args.def_path, args.top_n, args.bin_cnt, args.foundry_dir, args.congestion_model)); }
if (args.kind === "timing_paths") { const design = args.design || inferDesignFromTrace(args.workdir); if (!design) return asJson({ ok: false, reason: "timing_paths requires design" }); return asJson(await runtime.timingObserve(design, args.workdir, args.def_path, args.top_n, args.foundry_dir)); }
throw new Error("ieda_gp_observe: kind must be designs|status|checkpoints|grid|hotspots|longnets|unstable|trajectory|experiments|congestion_hotspots|timing_paths");
}
}));

ctx.tools.register(defineTool({
name: "ieda_gp_propose",
description: "Propose GP actions without changing state. kind: regions (priority=density|longnet|congestion; every region carries executable_action and density_target_options), region_density (suggested density target options for a region), freeze (cells that would be frozen; carries the complement scope_instances), longnet_instances (concrete instance sets for the highest-HPWL nets, directly usable as scope=instances), timing (instance sets for the worst timing paths from the cached iSTA report; run observe kind=timing_paths first), gp_config (bounded config/budget candidates with executable start actions). prediction_status is unavailable until a predictor exists.",
parameters: p({ workdir: { type: "string", required: true }, checkpoint: { type: "string" }, priority: { type: "string" }, top_n: { type: "integer" }, min_cell_count: { type: "integer" }, max_cell_count: { type: "integer" }, def_path: { type: "string" }, region: { type: "string" } }),
output: out(),
execute: async (args) => {
if (args.kind === "regions") return toolbox(["propose_regions", "--workdir", resolve(args.workdir), "--priority", args.priority ?? "density", "--top-n", String(args.top_n ?? 5), "--min-cell-count", String(args.min_cell_count ?? 20), "--max-cell-count", String(args.max_cell_count ?? 200), ...args.def_path ? ["--def-path", args.def_path] : [], ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
if (args.kind === "region_density") { if (!args.region) return asJson({ ok: false, reason: "region_density requires region 'llx lly urx ury'" }); return toolbox(["propose_region_density", "--workdir", resolve(args.workdir), "--region", args.region, ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]); }
if (args.kind === "freeze") { if (!args.region) return asJson({ ok: false, reason: "freeze requires region 'llx lly urx ury'" }); return toolbox(["propose_freeze", "--workdir", resolve(args.workdir), "--region", args.region, ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]); }
if (args.kind === "longnet_instances") return toolbox(["propose_longnet_instances", "--workdir", resolve(args.workdir), "--top-n", String(args.top_n ?? 5), ...args.def_path ? ["--def-path", args.def_path] : [], ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
if (args.kind === "timing") return toolbox(["propose_timing", "--workdir", resolve(args.workdir), "--top-n", String(args.top_n ?? 3), ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
if (args.kind === "gp_config") return toolbox(["propose_config", "--workdir", resolve(args.workdir), ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
throw new Error("ieda_gp_propose: kind must be regions|region_density|freeze|longnet_instances|timing|gp_config");
}
}));

ctx.tools.register(defineTool({
name: "ieda_gp_run",
description: "Execute GP actions. kind: full (one-shot complete GP for a registered design, returns run record + same-evaluator metrics vs baseline), start, advance, candidate, local_run, local_congestion (picks the top overflow bins from the cached verify-RUDY map and runs scope=region evacuations; run observe kind=congestion_hotspots first to write the map), apply_freeze, apply_region_density, local_restart, apply_anchor. local_run restores the checkpoint, applies the scope for N iterations, then ACCEPTS the child and writes placement.def (no separate accept needed). local_restart runs one local/global candidate, accepts the local child (set force_local=1 to force it even when the instant verdict is not left_better), then starts a fresh random_init=0 global GP from that placement; it returns def HPWL for both the local restart and a same-budget raw-GP restart baseline. Every run record carries def_hpwl (DEF-level HPWL, same evaluator as verify metrics) alongside the solver-internal hpwl. timing=1 on start/full enables timing-driven GP (is_timing_effort=1 with opt_overflow_list [0.15,0.20,0.25,0.30]) and reports timing_weight_updates.",
parameters: p({ design: { type: "string" }, workdir: { type: "string", required: true }, input_def: { type: "string" }, foundry_dir: { type: "string" }, checkpoint: { type: "string" }, iterations: { type: "integer" }, seed: { type: "integer" }, random_init: { type: "integer" }, target_density: { type: "number" }, target_overflow: { type: "number" }, init_density_penalty: { type: "number" }, min_phi_coef: { type: "number" }, max_phi_coef: { type: "number" }, congestion_effort: { type: "integer" }, seed_anchor_strength: { type: "number" }, report_route_util: { type: "integer" }, timing: { type: "integer" }, bin_cnt: { type: "integer" }, rounds: { type: "integer" }, top_bins: { type: "integer" }, congestion_threshold: { type: "number" }, congestion_model: { type: "string" }, scope: { type: "string" }, scope_seed: { type: "integer" }, scope_active_ratio: { type: "number" }, scope_active_count: { type: "integer" }, scope_instances: { type: "string" }, scope_region: { type: "string" }, halo_coeff: { type: "number" }, halo_hops: { type: "integer" }, overflow_penalty: { type: "number" }, scope_density_target: { type: "number" }, scope_density_ratio: { type: "number" }, scope_anneal_ratio: { type: "number" }, candidate_iterations: { type: "integer" }, restart_iterations: { type: "integer" }, force_local: { type: "integer" }, region: { type: "string" }, strength: { type: "number" } }),
output: out(),
execute: async (args) => {
if (!args.design) { const inferred = inferDesignFromTrace(args.workdir); if (inferred) args = { ...args, design: inferred }; }
if (args.region && !args.scope_region) args = { ...args, scope_region: args.region };
const k = args.kind;
if (!args.design && k !== "apply_anchor" && k !== "unfreeze" && k !== "clear_density") return asJson({ ok: false, reason: k + " requires design (or a previous ieda_gp_run trace in workdir)" });
if (k === "full" || k === "start" || k === "local_run" || k === "candidate" || k === "local_congestion" || k === "apply_region_density" || k === "apply_freeze" || k === "local_restart") archiveRunArtifacts(args.workdir);
if (k === "start" || k === "full") { for (const key of ["target_density", "target_overflow"]) { const value = Number(args[key] ?? -1); if (value >= 0 && !(value > 0 && value < 1)) return asJson({ ok: false, reason: key + " must be in (0,1); use -1 to keep config default" }); } }
if (k === "start") return agent(args, ["start", "--iterations", String(args.iterations ?? 20), "--seed", String(args.seed ?? 1000), "--random-init", String(args.random_init ?? 1), "--seed-anchor-strength", String(args.seed_anchor_strength ?? 0), "--target-density", String(args.target_density ?? -1), "--target-overflow", String(args.target_overflow ?? -1), ...args.init_density_penalty != null ? ["--init-density-penalty", String(args.init_density_penalty)] : [], ...args.min_phi_coef != null ? ["--min-phi-coef", String(args.min_phi_coef)] : [], ...args.max_phi_coef != null ? ["--max-phi-coef", String(args.max_phi_coef)] : [], "--congestion-effort", String(args.congestion_effort ?? -1), "--timing", String(args.timing ?? 0), "--bin-cnt", String(args.bin_cnt ?? -1), "--overflow-penalty", String(args.overflow_penalty ?? 0), "--report-route-util", String(args.report_route_util ?? 1)]);
if (k === "full") { const design = args.design; if (!design) return asJson({ ok: false, reason: "full requires design" }); const info = readDesigns(config.iedaRoot)[design] || {}; const runResult = await agent(args, ["start", "--iterations", String(args.iterations ?? 200), "--seed", String(args.seed ?? 1000), "--random-init", String(args.random_init ?? 1), "--target-density", String(args.target_density ?? -1), "--target-overflow", String(args.target_overflow ?? -1), "--congestion-effort", String(args.congestion_effort ?? -1), "--timing", String(args.timing ?? 0), "--bin-cnt", String(args.bin_cnt ?? -1), "--report-route-util", String(args.report_route_util ?? 1)]); if (!runResult.ok) return asJson(runResult); mkdirSync(resolve(args.workdir), { recursive: true }); const outFile = join(resolve(args.workdir), "gp_full_metrics.json"); const candidateDef = join(resolve(args.workdir), "placement.def"); const baselineDef = info.gp_baseline_def; if (!baselineDef) return asJson({ ok: true, run: runResult, metrics: { ok: false, reason: "registry has no gp_baseline_def" } }); const cmd = [join(config.iedaRoot, "benchmarks/flows/gp_metrics_compare.py"), "--design", design, "--case-root", String(info.case_root), "--macro-lef", String(info.lef || join(config.iedaRoot, "scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef")), "--foundry-dir", String(runtime.foundryDir(design)), "--congestion-model", String(args.congestion_model ?? "rudy"), ...args.timing === 0 ? ["--no-timing"] : [], "--out", outFile, "raw=" + baselineDef, "candidate=" + candidateDef, ...info.innovus_def ? ["innovus=" + info.innovus_def] : []]; const metricRun = await runCli(config.iedaRoot, config.python, config.timeoutMs, cmd[0], cmd.slice(1)); try { const metrics = JSON.parse(readFileSync(outFile, "utf8")); return asJson({ ok: true, run: runResult, metrics }); } catch (_) { return asJson({ ok: false, reason: "full run finished but metrics parse failed", run: runResult, stdout_tail: metricRun.stdout ? String(metricRun.stdout).slice(-4000) : null }); } }
if (k === "advance") return agent(args, ["advance", "--iterations", String(args.iterations ?? 100), "--report-route-util", String(args.report_route_util ?? 1), ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
if (k === "candidate") return agent(args, ["candidate", "--iterations", String(args.iterations ?? 20), ...scopeArgs(args), ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
if (k === "local_run") return agent(args, ["local_run", "--iterations", String(args.iterations ?? 10), ...scopeArgs(args), ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]);
if (k === "local_restart") { const info = readDesigns(config.iedaRoot)[args.design] || {}; const cli = ["--design", args.design, "--workdir", resolve(args.workdir), ...args.checkpoint ? ["--checkpoint", args.checkpoint] : [], "--case-root", String(info.case_root), "--input-def", String(info.input_def), "--config", String(info.pl_config), "--foundry-dir", String(args.foundry_dir || runtime.foundryDir(args.design)), ...info.lef ? ["--lef", String(info.lef)] : [], ...info.gp_baseline_def ? ["--baseline-def", String(info.gp_baseline_def)] : [], "--scope", args.scope ?? "longnet", "--scope-active-count", String(args.scope_active_count ?? 100), "--scope-active-ratio", String(args.scope_active_ratio ?? 0.2), "--halo-hops", String(args.halo_hops ?? 2), "--halo-coeff", String(args.halo_coeff ?? 0.5), "--overflow-penalty", String(args.overflow_penalty ?? 0.005), "--scope-anneal-ratio", String(args.scope_anneal_ratio ?? 0), "--scope-density-target", String(args.scope_density_target ?? 1), "--candidate-iterations", String(args.candidate_iterations ?? 20), "--restart-iterations", String(args.restart_iterations ?? 600), "--seed", String(args.seed ?? 42), ...args.scope_seed != null ? ["--scope-seed", String(args.scope_seed)] : [], ...args.force_local == 1 ? ["--force-local"] : [], ...args.scope_region ? ["--scope-region", args.scope_region] : [], ...args.scope_instances ? ["--scope-instances", args.scope_instances] : []]; const key = JSON.stringify({ kind: "local_restart", design: args.design, checkpoint: args.checkpoint, scope: args.scope, scope_instances: args.scope_instances, scope_region: args.scope_region, scope_density_target: args.scope_density_target, scope_anneal_ratio: args.scope_anneal_ratio, overflow_penalty: args.overflow_penalty, force_local: args.force_local }); return asJson(await cachedRun(args.workdir, key, "ieda_gp_run", async () => await runCli(config.iedaRoot, config.python, config.timeoutMs, join(config.iedaRoot, "benchmarks/flows/gp_local_restart.py"), cli))); }
if (k === "apply_freeze") return freezeRun(args);
if (k === "apply_anchor") {
return asJson({ ok: false, unsupported: true, reason: "per-cell anchor is not implemented; use apply_freeze for strength=1 batch freeze" });
}
if (k === "apply_region_density") { if (!args.scope_region || !String(args.scope_region).trim()) return asJson({ ok: false, reason: "apply_region_density requires region 'llx lly urx ury'" }); return agent(args, ["local_run", "--iterations", String(args.iterations ?? 10), "--scope", "region", "--scope-region", args.scope_region, "--scope-density-target", String(args.scope_density_target ?? 1), "--scope-density-ratio", "1", "--halo-hops", String(args.halo_hops ?? 1), "--halo-coeff", String(args.halo_coeff ?? 0.5), ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]); }
if (k === "local_congestion") { const design = args.design; if (!design) return asJson({ ok: false, reason: "local_congestion requires design" }); const map = await runtime.congestionObserve(design, args.workdir, undefined, args.top_bins ?? 3, args.bin_cnt, args.foundry_dir, args.congestion_model); if (!map.ok) return asJson(map); return agent(args, ["local_congestion", "--iterations", String(args.iterations ?? 20), "--rounds", String(args.rounds ?? 2), "--top-bins", String(args.top_bins ?? 3), "--congestion-threshold", String(args.congestion_threshold ?? 1.0), "--density-target", String(args.scope_density_target ?? 0.5), "--halo-coeff", String(args.halo_coeff ?? 0.5), "--halo-hops", String(args.halo_hops ?? 1), "--scope", String(args.scope ?? "region"), ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []]); }
throw new Error("ieda_gp_run: kind must be full|start|advance|candidate|local_run|local_congestion|apply_freeze|apply_region_density|local_restart|apply_anchor");
}
}));

ctx.tools.register(defineTool({
name: "ieda_gp_verify",
description: "Verify GP results. kind: delta (metric delta between checkpoints), lg (read-only LG oracle), metrics (same-evaluator HPWL/density/RUDY/timing across raw DEF, candidate DEF and any number of extra DEFs). For metrics set timing=0 to skip timing on PDKs without the timing evaluator. extra_defs uses 'label=path;label2=path2' form (e.g. innovus=/tmp/innovus_placed.def). congestion_effort=2 enables the experimental LUT peak-bin penalty; congestion_effort=3 optimizes plain RUDY (same model as verify metrics default).",
parameters: p({ design: { type: "string" }, workdir: { type: "string", required: true }, checkpoint: { type: "string" }, checkpoint_a: { type: "string" }, checkpoint_b: { type: "string" }, def_path: { type: "string" }, raw_def: { type: "string" }, candidate_def: { type: "string" }, extra_defs: { type: "string" }, timing: { type: "integer" }, congestion_model: { type: "string" } }),
output: out(),
execute: async (args) => {
if (args.kind === "delta") return toolbox(["verify_delta", "--workdir", resolve(args.workdir), "--checkpoint-a", args.checkpoint_a, "--checkpoint-b", args.checkpoint_b, ...args.def_path ? ["--def-path", args.def_path] : []]);
if (args.kind === "lg") { const design = args.design || inferDesignFromTrace(args.workdir); if (!design) return asJson({ ok: false, reason: "lg requires design (or a previous ieda_gp_run trace in workdir)" }); return asJson(await runtime.agent(design, args.workdir, ["verify_lg", ...args.checkpoint ? ["--checkpoint", args.checkpoint] : []])); }
if (args.kind === "metrics") { if (!args.raw_def && !args.candidate_def && !String(args.extra_defs ?? "").trim()) return asJson({ ok: false, reason: "metrics requires raw_def, candidate_def or extra_defs" }); const design = args.design || inferDesignFromTrace(args.workdir); if (!design) return asJson({ ok: false, reason: "metrics requires design (or a previous ieda_gp_run trace in workdir)" }); const info = readDesigns(config.iedaRoot)[design] || {}; const extraDefs = String(args.extra_defs ?? "").split(";").map((s) => s.trim()).filter(Boolean); const defStamp = (spec) => { const eq = spec.indexOf("="); const label = eq >= 0 ? spec.slice(0, eq) : spec; const p = eq >= 0 ? spec.slice(eq + 1) : spec; return [label, !p ? "missing" : (existsSync(p) ? statSync(p).mtimeMs : "missing")]; }; const defs = []; if (args.raw_def) defs.push(["raw", ...defStamp(args.raw_def)]); if (args.candidate_def) defs.push(["candidate", ...defStamp(args.candidate_def)]); for (const s of extraDefs) defs.push(defStamp(s)); const model = String(args.congestion_model ?? "rudy"); const timing = args.timing === 0 ? 0 : 1; const key = JSON.stringify({ design, defs, model, timing }); return cachedRun(resolve(args.workdir), key, "ieda_gp_verify", async () => { mkdirSync(resolve(args.workdir), { recursive: true }); const outFile = join(resolve(args.workdir), "gp_metrics_compare.json"); const cmd = [join(config.iedaRoot, "benchmarks/flows/gp_metrics_compare.py"), "--design", design, "--case-root", String(info.case_root), "--macro-lef", String(info.lef || join(config.iedaRoot, "scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef")), "--foundry-dir", String(runtime.foundryDir(design)), "--congestion-model", model, ...timing === 0 ? ["--no-timing"] : [], "--out", outFile, ...args.raw_def ? ["raw=" + args.raw_def] : [], ...args.candidate_def ? ["candidate=" + args.candidate_def] : [], ...extraDefs]; const runResult = await runCli(config.iedaRoot, config.python, config.timeoutMs, cmd[0], cmd.slice(1)); try { const parsed = JSON.parse(readFileSync(outFile, "utf8")); return asJson({ ok: true, metrics_file: outFile, ...parsed }); } catch (error) { return asJson({ ok: false, reason: "metrics evaluator produced no valid JSON", metrics_file: outFile, stdout_tail: runResult.stdout ? String(runResult.stdout).slice(-4000) : null, stderr_tail: runResult.stderr_tail || null }); } }, 4000); }
throw new Error("ieda_gp_verify: kind must be delta|lg|metrics");
}
}));

ctx.tools.register(defineTool({
name: "ieda_gp_session",
description: "Manage the GP session state. kind: restore (point workdir at a checkpoint), accept (commit the CURRENT in-memory session and write placement.def; never pass checkpoint), unfreeze (batch-scoped freeze is already cleared), clear_density (batch-scoped density target is already cleared).",
parameters: p({ design: { type: "string" }, workdir: { type: "string", required: true }, checkpoint: { type: "string" } }),
output: out(),
execute: async (args) => {
if (args.kind === "restore") return restore(args);
if (args.kind === "accept") { if (args.checkpoint) return asJson({ ok: false, reason: "accept commits the current in-memory session; checkpoint is ignored. Restore first only if you intend to go back." }); const design = args.design || inferDesignFromTrace(args.workdir); if (!design) return asJson({ ok: false, reason: "accept requires design (or a previous ieda_gp_run trace in workdir)" }); return asJson(await runtime.agent(design, args.workdir, ["accept"])); }
if (args.kind === "unfreeze" || args.kind === "clear_density") return asJson({ ok: true, note: "batch-scoped state is already cleared", workdir: resolve(args.workdir), checkpoint: args.checkpoint ?? null });
throw new Error("ieda_gp_session: kind must be restore|accept|unfreeze|clear_density");
}
}));
}
export { Config, apply, inject, name };
// reload-marker-20260819-a
