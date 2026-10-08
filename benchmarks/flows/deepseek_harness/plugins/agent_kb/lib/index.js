import z from "@deepseek-ai/schemastery";
import { defineTool } from "@deepseek-ai/dsh-tools";
import { execFile } from "node:child_process";
import { readFileSync, existsSync } from "node:fs";
import { join, resolve } from "node:path";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);
const name = "tool-agent-kb";
const inject = ["tools"];
const Config = z.object({
  iedaRoot: z.string().required(),
  python: z.string().default("python3"),
  timeoutMs: z.number().step(1).min(1e3).default(72e5)
});

function readDesigns(iedaRoot) {
  return JSON.parse(readFileSync(join(iedaRoot, "benchmarks/flows/deepseek_harness/designs.json"), "utf8"));
}
function tail(value, max = 12e3) { return value.length > max ? value.slice(-max) : value; }
async function runCli(iedaRoot, python, timeoutMs, script, args) {
  try {
    const { stdout, stderr } = await execFileAsync(python, [script, ...args], { cwd: iedaRoot, timeout: timeoutMs, maxBuffer: 32 * 1024 * 1024 });
    try { return JSON.parse(stdout); } catch { return { ok: false, rc: 0, stdout: tail(stdout), stderr_tail: tail(stderr) }; }
  } catch (error) {
    const e = error;
    try { const parsed = JSON.parse(e.stdout ?? ""); if (parsed && typeof parsed === "object") return parsed; } catch {}
    return { ok: false, rc: typeof e.code === "number" ? e.code : 1, error: e.message, stdout: tail(e.stdout ?? ""), stderr_tail: tail(e.stderr ?? "") };
  }
}
function jsonContent(value) { return [{ type: "text", text: JSON.stringify(value, null, 2) }]; }
function asJson(value) { return value; }
function inferDesignFromTrace(workdir) {
  try {
    const path = join(resolve(workdir), "gp_agent_trace.jsonl");
    if (!existsSync(path)) return null;
    const rows = readFileSync(path, "utf8").trim().split("\n").filter(Boolean);
    for (let i = rows.length - 1; i >= 0; i--) { try { const row = JSON.parse(rows[i]); if (row.design) return String(row.design); } catch {} }
  } catch {}
  return null;
}

export function apply(ctx, config) {
  const p = (extra = {}) => ({ ...extra });
  const out = () => ({ schema: { type: "json" }, render: (_a, v) => jsonContent(v) });
  const script = (n) => join(config.iedaRoot, "benchmarks/flows", n);

  ctx.tools.register(defineTool({
    name: "agent_prior",
    description: "Cross-case knowledge base. KNOWLEDGE = physical decision-layer rules: condition(pdk+size_bucket+bottleneck{metric,source,subclass}+observable 可测判定) + decision(do=工具无关物理动作 + mechanism 机理 + category/subclass) + tradeoff(egr/hpwl/timing 三维得失) + tool_mapping(ieda 实现,降级隔离) + falsify_if(证伪条件)。per-design facts are audit LOGS, NOT knowledge. kind=read returns rules + per-design facts. kind=update ops: --evidence hypothesis (add falsifiable rule,必须填 condition+decision+tradeoff三维+falsify_if, decision.do 必须是工具无关物理动作,否则是工具噪声不进 rules); --evidence confirm/falsify --rule-id (belief update; scope-out counterexamples auto-marked falsify_scope_out, not counted in confidence). 分类是事后索引不是菜单:诊断具体物理现象→决策→贴标签,新 subclass 可新增但须给定义。Per-design best_params/metrics go to notes (audit log) only.",
    parameters: p({ workdir: { type: "string", required: true }, kind: { type: "string" }, design: { type: "string" }, note: { type: "string" }, def_path: { type: "string" }, evidence: { type: "string" }, rule_id: { type: "string" }, scope_pdk: { type: "string" }, scope_cells: { type: "string" }, scope_bottleneck: { type: "string" }, scope_physical: { type: "string" }, scope_source: { type: "string" }, scope_subclass: { type: "string" }, observable: { type: "string" }, decision_do: { type: "string" }, decision_mechanism: { type: "string" }, action_category: { type: "string" }, action_subclass: { type: "string" }, tool_mapping: { type: "string" }, falsify_if: { type: "string" }, tradeoff_egr: { type: "string" }, tradeoff_hpwl: { type: "string" }, tradeoff_timing: { type: "string" }, action: { type: "string" }, effect_metric: { type: "string" }, effect_direction: { type: "string" }, effect_delta: { type: "string" }, cost_metric: { type: "string" }, cost_direction: { type: "string" }, cost_delta: { type: "string" }, prediction: { type: "string" }, guidance: { type: "string" } }),
    output: out(),
    execute: async (args) => {
      const design = args.design || inferDesignFromTrace(args.workdir) || "unknown";
      const record = readDesigns(config.iedaRoot)[design] || {};
      const cli = ["prior", "--workdir", resolve(args.workdir), ...(design ? ["--design", design] : []), "--kind", args.kind ?? "read", ...(args.note ? ["--note", String(args.note)] : []), ...(args.evidence ? ["--evidence", String(args.evidence)] : []), ...(args.rule_id ? ["--rule-id", String(args.rule_id)] : []), ...(args.scope_pdk ? ["--scope-pdk", String(args.scope_pdk)] : []), ...(args.scope_cells ? ["--scope-cells", String(args.scope_cells)] : []), ...(args.scope_bottleneck ? ["--scope-bottleneck", String(args.scope_bottleneck)] : []), ...(args.scope_physical ? ["--scope-physical", String(args.scope_physical)] : []), ...(args.scope_source ? ["--scope-source", String(args.scope_source)] : []), ...(args.scope_subclass ? ["--scope-subclass", String(args.scope_subclass)] : []), ...(args.observable ? ["--observable", String(args.observable)] : []), ...(args.decision_do ? ["--decision-do", String(args.decision_do)] : []), ...(args.decision_mechanism ? ["--decision-mechanism", String(args.decision_mechanism)] : []), ...(args.action_category ? ["--action-category", String(args.action_category)] : []), ...(args.action_subclass ? ["--action-subclass", String(args.action_subclass)] : []), ...(args.tool_mapping ? ["--tool-mapping", String(args.tool_mapping)] : []), ...(args.falsify_if ? ["--falsify-if", String(args.falsify_if)] : []), ...(args.tradeoff_egr ? ["--tradeoff-egr", String(args.tradeoff_egr)] : []), ...(args.tradeoff_hpwl ? ["--tradeoff-hpwl", String(args.tradeoff_hpwl)] : []), ...(args.tradeoff_timing ? ["--tradeoff-timing", String(args.tradeoff_timing)] : []), ...(args.action ? ["--action", String(args.action)] : []), ...(args.effect_metric ? ["--effect-metric", String(args.effect_metric)] : []), ...(args.effect_direction ? ["--effect-direction", String(args.effect_direction)] : []), ...(args.effect_delta ? ["--effect-delta=" + String(args.effect_delta)] : []), ...(args.cost_metric ? ["--cost-metric", String(args.cost_metric)] : []), ...(args.cost_direction ? ["--cost-direction", String(args.cost_direction)] : []), ...(args.cost_delta ? ["--cost-delta=" + String(args.cost_delta)] : []), ...(args.prediction ? ["--prediction", String(args.prediction)] : []), ...(args.guidance ? ["--guidance", String(args.guidance)] : []), "--case-root", String(record.case_root || ""), "--input-def", String(record.input_def || ""), "--foundry-dir", String(record.foundry_dir || (record.pdk ? join(config.iedaRoot, "scripts/foundry", record.pdk) : "") || "")];
      return asJson(await runCli(config.iedaRoot, config.python, config.timeoutMs, script("gp_agent.py"), cli));
    }
  }));
}
export { Config, inject, name };
