import z from "@deepseek-ai/schemastery";
import { defineTool } from "@deepseek-ai/dsh-tools";
import { execFile } from "node:child_process";
import { createHash } from "node:crypto";
import { readFileSync, writeFileSync, mkdirSync, existsSync, readdirSync } from "node:fs";
import { join, resolve } from "node:path";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);
const name = "tool-eval-metrics";
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
const EVAL_VERSION = "1";
// 预算硬限制：每个 workdir 的真实 evaluator 调用次数（缓存命中不计数）
const EVAL_BUDGET = 6;
function budgetFile(workdir) { return join(resolve(workdir), ".eval_metrics_budget.json"); }
function budgetUsed(workdir) {
  try { return JSON.parse(readFileSync(budgetFile(workdir), "utf8")).count || 0; } catch { return 0; }
}
function budgetBump(workdir) {
  const f = budgetFile(workdir);
  const count = budgetUsed(workdir) + 1;
  try { writeFileSync(f, JSON.stringify({ count })); } catch {}
  return count;
}
async function cachedRun(workdir, key, runner) {
  const dir = resolve(workdir);
  mkdirSync(dir, { recursive: true });
  const cacheFile = join(dir, "eval_metrics_cache.jsonl");
  let rows = [];
  try { rows = readFileSync(cacheFile, "utf8").split("\n").filter(Boolean).map((l) => JSON.parse(l)); } catch {}
  const hit = rows.find((r) => r.key === EVAL_VERSION + ":" + key);
  if (hit) return { ...hit.result, cached: true };
  // 缓存未命中才消耗预算
  if (budgetUsed(dir) >= EVAL_BUDGET) {
    return { ok: false, reason: `eval_metrics budget exhausted (${EVAL_BUDGET} real evaluations per workdir); reuse identical args to hit cache, or accept the limit`, budget_exhausted: true };
  }
  const result = await runner();
  if (result && typeof result === "object" && result.ok !== undefined) {
    budgetBump(dir);
    const row = { ts: Date.now(), key: EVAL_VERSION + ":" + key, result };
    rows.push(row);
    try { readFileSync(cacheFile, "utf8"); } catch {}
    // append via a fresh read to avoid concurrent clobber (single-agent is fine)
    const fsMod = await import("node:fs");
    fsMod.appendFileSync(cacheFile, JSON.stringify(row) + "\n");
  }
  return result;
}

export function apply(ctx, config) {
  const p = (extra = {}) => ({ ...extra });
  const out = () => ({ schema: { type: "json" }, render: (_a, v) => jsonContent(v) });

  ctx.tools.register(defineTool({
    name: "eval_metrics",
    description: "Domain-agnostic fair ruler: same-evaluator HPWL + EGR (iRT trial-route overflow, union + H/V) + timing across any number of DEFs. raw_def is typically the Innovus/reference baseline. candidate_def is OPTIONAL: omit it to auto-use <workdir>/placement.def (your own placement result). extra_defs batches more candidates ('label=path;label2=path2'). egr is the authoritative congestion model (RUDY only for legacy). Unlegalized candidate DEFs are refused (overlapping cells fake a low EGR); the raw reference is not gated. This is THE authoritative metrics source - run-record route_util is NOT trustworthy.",
    parameters: p({ design: { type: "string" }, workdir: { type: "string", required: true }, raw_def: { type: "string" }, candidate_def: { type: "string" }, extra_defs: { type: "string" }, timing: { type: "integer" }, congestion_model: { type: "string" } }),
    output: out(),
    execute: async (args) => {
      const design = args.design || inferDesignFromTrace(args.workdir);
      if (!design) return asJson({ ok: false, reason: "eval_metrics requires design (or a previous run trace in workdir)" });
      if (!args.raw_def && !args.candidate_def && !String(args.extra_defs ?? "").trim())
        return asJson({ ok: false, reason: "eval_metrics requires raw_def, candidate_def or extra_defs" });
      const info = readDesigns(config.iedaRoot)[design] || {};
      const extraDefs = String(args.extra_defs ?? "").split(";").map((s) => s.trim()).filter(Boolean);
      const defStamp = (spec) => {
        const eq = spec.indexOf("=");
        const label = eq >= 0 ? spec.slice(0, eq) : spec;
        const pth = eq >= 0 ? spec.slice(eq + 1) : spec;
        if (!pth || !existsSync(pth)) return [label, "missing"];
        const buf = readFileSync(pth);
        return [label, createHash("sha256").update(buf).digest("hex").slice(0, 24) + ":" + buf.length];
      };
      const defs = [];
      if (args.raw_def) defs.push(["raw", ...defStamp(args.raw_def)]);
      // candidate_def 缺省时自动用 workdir/placement.def（agent 自己的布局结果），
      // 消除"该传哪个路径"的困惑。
      const defaultCand = join(resolve(args.workdir), "placement.def");
      const candPath = args.candidate_def || (existsSync(defaultCand) ? defaultCand : null);
      if (candPath) defs.push(["candidate", ...defStamp(candPath)]);
      for (const s of extraDefs) defs.push(defStamp(s));
      const model = String(args.congestion_model ?? "egr");
      const timing = args.timing === 0 ? 0 : 1;
      const key = JSON.stringify({ design, defs, model, timing });
      return cachedRun(resolve(args.workdir), key, async () => {
        mkdirSync(resolve(args.workdir), { recursive: true });
        const outFile = join(resolve(args.workdir), "eval_metrics.json");
        const { lef } = resolveFoundryLeF(config.iedaRoot, design, info);
        const cmd = [join(config.iedaRoot, "benchmarks/flows/gp_metrics_compare.py"), "--design", design, "--case-root", String(info.case_root), "--macro-lef", String(lef || ""), "--foundry-dir", String(info.foundry_dir || (info.pdk ? join(config.iedaRoot, "scripts/foundry", info.pdk) : "")), "--congestion-model", model, ...(timing === 0 ? ["--no-timing"] : []), "--out", outFile, ...(args.raw_def ? ["raw=" + args.raw_def] : []), ...(args.candidate_def ? ["candidate=" + args.candidate_def] : []), ...extraDefs];
        const runResult = await runCli(config.iedaRoot, config.python, config.timeoutMs, cmd[0], cmd.slice(1));
        try {
          const parsed = JSON.parse(readFileSync(outFile, "utf8"));
          return asJson({ ok: true, metrics_file: outFile, ...parsed });
        } catch (error) {
          return asJson({ ok: false, reason: "metrics evaluator produced no valid JSON", metrics_file: outFile, stdout_tail: runResult.stdout ? String(runResult.stdout).slice(-4000) : null, stderr_tail: runResult.stderr_tail || null });
        }
      });
    }
  }));
}
export { Config, inject, name };
