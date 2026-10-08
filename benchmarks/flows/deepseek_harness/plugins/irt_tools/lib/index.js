import z from "@deepseek-ai/schemastery";
import { defineTool } from "@deepseek-ai/dsh-tools";
import { execFile } from "node:child_process";
import { readFileSync, writeFileSync, mkdirSync, existsSync, readdirSync } from "node:fs";
import { join, resolve } from "node:path";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);
const name = "tool-irt";
const inject = ["tools"];
const Config = z.object({
  iedaRoot: z.string().required(),
  python: z.string().default("python3"),
  timeoutMs: z.number().step(1).min(1e3).default(72e5)
});

function readDesigns(iedaRoot) {
  return JSON.parse(readFileSync(join(iedaRoot, "benchmarks/flows/deepseek_harness/designs.json"), "utf8"));
}
function resolveFoundryLeF(iedaRoot, design, record) {
  const foundry = record?.foundry_dir || (record?.pdk ? join(iedaRoot, "scripts/foundry", record.pdk) : null);
  let lef = record?.lef || null;
  if (!lef && foundry && existsSync(foundry)) {
    const walk = (dir, depth) => {
      if (depth < 0) return [];
      let out = [];
      let entries = [];
      try { entries = readdirSync(dir, { withFileTypes: true }); } catch { return []; }
      for (const ent of entries) {
        const p = join(dir, ent.name);
        if (ent.isDirectory()) out = out.concat(walk(p, depth - 1));
        else if (ent.name.endsWith(".lef")) out.push(p);
      }
      return out;
    };
    const all = walk(foundry, 12).filter((p) => p.split("/").pop().startsWith("._") === false);
    const nonTech = all.filter((p) => !/techLEF|prtech|\/tech[\/]/.test(p));
    lef = all.find((p) => p.includes("merged")) || nonTech.find((p) => /\/lef[\/\\]/.test(p)) || nonTech[0] || all[0] || null;
  }
  return { foundry, lef };
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

  ctx.tools.register(defineTool({
    name: "irt_egr",
    description: "Routing-domain authoritative EGR (iRT trial-route overflow) with the legalization gate. The cheap per-step congestion feedback: REAL router overflow (union + H/V), not the solver-internal route_util. Unlegalized DEFs are refused (overlapping cells fake a low EGR). def_path is OPTIONAL: omit it to evaluate <workdir>/placement.def automatically (the placement.def produced by ipl_run/ipl_session accept). Only pass def_path to evaluate a specific alternate DEF file.",
    parameters: p({ workdir: { type: "string", required: true }, def_path: { type: "string" }, design: { type: "string" } }),
    output: out(),
    execute: async (args) => {
      const design = args.design || inferDesignFromTrace(args.workdir);
      if (!design) return asJson({ ok: false, reason: "irt_egr requires design (or a previous run trace in workdir)" });
      // 预算硬限制：每个 workdir 最多 8 次真实 EGR 评估
      const dir = resolve(args.workdir);
      mkdirSync(dir, { recursive: true });
      const budgetF = join(dir, ".irt_egr_budget.json");
      let used = 0;
      try { used = JSON.parse(readFileSync(budgetF, "utf8")).count || 0; } catch {}
      if (used >= 8) return asJson({ ok: false, reason: "irt_egr budget exhausted (8 real evaluations per workdir)", budget_exhausted: true });
      writeFileSync(budgetF, JSON.stringify({ count: used + 1 }));
      const record = readDesigns(config.iedaRoot)[design] || {};
      const cli = ["--workdir", resolve(args.workdir), "--case-root", String(record.case_root), "--foundry-dir", String(record.foundry_dir || (record.pdk ? join(config.iedaRoot, "scripts/foundry", record.pdk) : "")), ...(args.def_path ? ["--def-path", resolve(args.def_path)] : [])];
      return asJson(await runCli(config.iedaRoot, config.python, config.timeoutMs, join(config.iedaRoot, "benchmarks/flows/irt_egr.py"), cli));
    }
  }));
}
export { Config, inject, name };
