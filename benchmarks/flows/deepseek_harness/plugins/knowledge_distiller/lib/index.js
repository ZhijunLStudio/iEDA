import z from "@deepseek-ai/schemastery";
import { defineTool } from "@deepseek-ai/dsh-tools";
import { appendFileSync, readFileSync, writeFileSync, existsSync, mkdirSync } from "node:fs";
import { join, resolve } from "node:path";

const name = "tool-knowledge-distiller";
const inject = ["tools", "subagents"];

const Config = z.object({
  iedaRoot: z.string().required(),
  python: z.string().default("python3"),
  provider: z.string().default("spawn"),
  timeoutMs: z.number().step(1).min(1e3).default(72e5),
  // distiller 子 agent 的模型配置（缺省继承父 agent 模型）
  distillerProvider: z.string().default(""),
  distillerModel: z.string().default(""),
  // reasoning 模型思考占用 token，max_tokens 要给足：reasoning + content 都要有空间。
  // 实测 32000 时 reasoning≈29k 字、content≈600 字（完整 JSON）；16000 时 content 被挤空导致 parse_failed。
  distillerReasoningEffort: z.string().default(""),
  distillerMaxTokens: z.number().step(1).min(1).default(32000),
});

function jsonContent(value) {
  return [{ type: "text", text: JSON.stringify(value, null, 2) }];
}

// ── 观测仓库：append-only jsonl，一条观测一行 ──────────────────────────────
function obsDir(iedaRoot) {
  return join(iedaRoot, "benchmarks/flows/deepseek_harness/observations");
}
function obsFile(iedaRoot, design) {
  return join(obsDir(iedaRoot), `${design}.jsonl`);
}
function loadObservations(iedaRoot, design) {
  const f = obsFile(iedaRoot, design);
  if (!existsSync(f)) return [];
  try {
    return readFileSync(f, "utf8").trim().split("\n").filter(Boolean).map((l) => JSON.parse(l));
  } catch {
    return [];
  }
}
function appendObservation(iedaRoot, design, obs) {
  const dir = obsDir(iedaRoot);
  mkdirSync(dir, { recursive: true });
  appendFileSync(obsFile(iedaRoot, design), JSON.stringify(obs) + "\n");
}

// ── 触发判断 ──────────────────────────────────────────────────────────────
// 触发条件：同一 wave 里有 ≥2 个不同 action_type 的观测（正交动作对照同一现象）
// 或：同 action_type 的 delta 方向相反（矛盾）。
function shouldTrigger(iedaRoot, design, obs, allObs) {
  // 条件A：同 action_type 的 delta 方向相反（矛盾）
  const sameAction = allObs.filter((o) => o.action_type === obs.action_type && o.design === design);
  if (sameAction.length > 0) {
    const last = sameAction[sameAction.length - 1];
    const lastDir = signOf(last);
    const thisDir = signOf(obs);
    if (lastDir && thisDir && lastDir !== thisDir) return "conflict";
  }
  // 条件B：同一 wave 有 ≥2 个不同 action_type（正交动作对照，不是同动作参数扫描）
  const wave = obs.wave_id || "default";
  const waveObs = allObs.filter((o) => o.design === design && o.wave_id === wave);
  const actionTypes = new Set(waveObs.map((o) => o.action_type));
  if (actionTypes.size >= 2) return "orthogonal_contrast";
  return null;
}
function signOf(obs) {
  const d = obs.delta || {};
  const egr = d.egr_max || d.egr_total || d.egr;
  if (typeof egr === "string") return egr.startsWith("-") ? "down" : egr.startsWith("+") ? "up" : null;
  if (typeof egr === "number") return egr < 0 ? "down" : egr > 0 ? "up" : null;
  return null;
}

// ── distiller 的 structured output schema（六段诊断链）──────────────────
const distillSchema = {
  type: "object",
  properties: {
    no_knowledge: { type: "boolean" },
    reason: { type: "string" },
    knowledge: {
      type: "object",
      properties: {
        phenomenon: { type: "string" },
        branch_metric: { type: "string" },
        branch_rule: { type: "string" },
        mechanism: { type: "string" },
        action: { type: "string" },
        effect: {
          type: "object",
          properties: { egr: { type: "string" }, hpwl: { type: "string" }, timing: { type: "string" } },
        },
        boundary: { type: "string" },
        tool_mapping: { type: "string" },
        non_common_sense_justification: { type: "string" },
      },
    },
  },
};

// ── distiller prompt ───────────────────────────────────────────────────────
function distillerPrompt(design, waveObs, existingKnowledge) {
  const obsText = JSON.stringify(waveObs, null, 2);
  const knowText = JSON.stringify(existingKnowledge, null, 2).slice(0, 2000);
  return `你是 EDA 布局知识提炼者（distiller）。你的任务：从一批实验观测里，提炼出「六段诊断链」知识。

## 输入：一批观测（同一设计同一轮，或冲突观测）
${obsText}

## 现有知识库（供对照，避免重复沉淀常识）
${knowText}

## 你的任务
从观测里找出「agent 先验没有的规律」（非常识），写成六段诊断链：
① phenomenon 现象（可测，不是形容词）
② branch_metric 分岔判据（再测哪个量，决定走哪条路）
③ branch_rule 分岔规则（该量的哪个取值走哪条路）
④ mechanism 机理（为什么这个判据决定这个动作——核心）
⑤ action 动作（针对机理指出的具体对象，做具体操作）
⑥ effect 三维效果（EGR/HPWL/timing，实测值）
⑦ boundary 边界（反例 + 为什么失效）

## 硬要求
- 必须是「非常识」：一个没看过这些观测的 EDA 专家，能凭教科书直接说出吗？能 = 常识，不要输出（用 no_knowledge）。
- 归因必须来自观测里的作用对象画像（cell 数 / 网 pin 数 / 密度），不是凭空猜。

## ★ 工具无关物理语言（主体只用物理语言，旋钮只进 tool_mapping）
主体（现象/判据/规则/机理/动作/效果/边界）只用：密度、网拓扑、pin数/扇出、溢出簇局部/弥散、路由需求、白空间、HV分布、时序裕量。禁止在主体出现 ce4/5/6/7、congestion_effort、target_density、逐bin屏、bin_cnt、iterations、LG+DP 等旋钮名（这些只写进 tool_mapping）。

## ★ 跨设计合并（重要，方向一致才合并，方向相反记反例）
对照「现有知识库」每条规则，判断你这条与它们的关系（三选一）：
1. **同一物理主题 且 结论方向一致**（机理同根因、动作方向相同，只是不同设计印证）→ 输出 merge_with = 那条现有规则的 id。
2. **同一物理主题 但 结论方向相反**（比如它说"低铺满该压缩"，你这条证据支持"低铺满该疏散"）→ 输出 counterexample_of = 那条现有规则的 id。这表示你这条是它的反例，会写进它的边界（falsify_if），而不是作为支持证据。
3. 无关 → 两个字段都留空字符串。
现有知识库每条规则都有 id 字段，用 id 精确引用。
判断方向时看「动作方向」：压缩/收拢/聚拢 是一类，疏散/摊开/放松密度 是另一类。方向相反绝不 merge。

## 输出方式
- 只输出一个 JSON 对象，不要 markdown 代码块、不要解释文字、不要前后缀。
- 每个字段一句话（≤60 字），机理可稍长但 ≤100 字。紧凑清晰，不堆砌。
- JSON 格式（字段必须齐全）：
{"no_knowledge":false,"merge_with":"","counterexample_of":"","knowledge":{"phenomenon":"","branch_metric":"","branch_rule":"","mechanism":"","action":"","effect":{"egr":"","hpwl":"","timing":""},"boundary":"","tool_mapping":"","non_common_sense_justification":""}}
- merge_with 只有同主题同方向时才填；counterexample_of 只有同主题反方向时才填；两者互斥，不能同时填。
- 若不足以提炼非常识，输出 {"no_knowledge":true,"reason":""}（reason ≤60 字）。`;
}

// ── 主逻辑 ──────────────────────────────────────────────────────────────────
export function apply(ctx, config) {
  const p = (extra = {}) => ({ ...extra });
  const out = () => ({ schema: { type: "json" }, render: (_a, v) => jsonContent(v) });

  function loadKnowledge() {
    const kp = join(config.iedaRoot, "benchmarks/flows/deepseek_harness/knowledge.json");
    try {
      const d = JSON.parse(readFileSync(kp, "utf8"));
      return d.rules || [];
    } catch {
      return [];
    }
  }
  function saveDistilled(knowledge, design, mergeWith, counterexampleOf) {
    const kp = join(config.iedaRoot, "benchmarks/flows/deepseek_harness/knowledge.json");
    let d = {};
    try { d = JSON.parse(readFileSync(kp, "utf8")); } catch {}
    d.rules = d.rules || [];

    // 工具无关性兜底：主体出现 iEDA 旋钮名则打标（但保留，人工 review）
    const forbidden = ["ce4", "ce5", "ce6", "ce7", "congestion_effort", "target_density", "constraint-first", "逐bin", "per-bin", "bin_cnt", "random_init", "ipl_run", "LG+DP", "legalize", "td0", "aniso"];
    const body = (knowledge.phenomenon || "") + (knowledge.branch_rule || "") + (knowledge.mechanism || "") + (knowledge.action || "");
    const leaked = forbidden.filter((t) => body.toLowerCase().includes(t.toLowerCase()));

    const now = new Date().toISOString();
    const newRule = {
      id: "distilled_" + Date.now(),
      status: "unverified",
      knowledge_value: "candidate",
      condition: {
        pdk: "sky130",
        bottleneck: { metric: "egr", source: knowledge.branch_rule || null },
        observable: knowledge.phenomenon || "",
      },
      decision: {
        do: knowledge.action || "",
        mechanism: knowledge.mechanism || "",
        subclass: knowledge.branch_rule || null,
      },
      tradeoff: {
        egr: { delta: knowledge.effect?.egr || "" },
        hpwl: { delta: knowledge.effect?.hpwl || "" },
        timing: { delta: knowledge.effect?.timing || "" },
      },
      tool_mapping: { ieda: knowledge.tool_mapping || "" },
      falsify_if: knowledge.boundary || "",
      non_common_sense_justification: knowledge.non_common_sense_justification || "",
      evidence: design ? [{ design, at: now }] : [],
      confidence: 0.0,
      tool_term_leak: leaked.length > 0 ? leaked : [],
      created_at: now,
      updated_at: now,
    };
    d.rules.push(newRule);
    writeFileSync(kp, JSON.stringify(d, null, 2));

    // 跨设计关系处理：merge_with（同方向印证）或 counterexample_of（反例）
    if (counterexampleOf) {
      try { addCounterexample(d, newRule, design, counterexampleOf); } catch {}
    } else if (mergeWith) {
      try { mergeWithDesignation(d, newRule, design, mergeWith); } catch {}
    }
    return newRule;
  }

  // 反例入库：把方向相反的规则写进 canonical 的 falsify_if（作为边界，而非支持证据）
  function addCounterexample(d, newRule, design, counterexampleOf) {
    if (!design || !counterexampleOf) return;
    const kp = join(config.iedaRoot, "benchmarks/flows/deepseek_harness/knowledge.json");
    const canonical = (d.rules || []).find((r) => r.id === counterexampleOf);
    if (!canonical) return;
    // 反例追加到 canonical 的 falsify_if 边界，并记录来源设计
    const counter = `【反例:${design}】${newRule.condition?.observable || ""} → 动作方向相反(${newRule.decision?.do || ""})。`;
    canonical.falsify_if = (canonical.falsify_if ? canonical.falsify_if + "\n" : "") + counter;
    canonical.counterexamples = canonical.counterexamples || [];
    canonical.counterexamples.push({ design, rule_id: newRule.id, at: new Date().toISOString() });
    canonical.updated_at = new Date().toISOString();
    // 新规则标记为 counterexample（保留独立，不 merged）
    newRule.status = "counterexample";
    newRule.counterexample_of = canonical.id;
    writeFileSync(kp, JSON.stringify(d, null, 2));
  }

  // 状态机：distiller 指定 merge_with（同主题同方向）→ evidence 归并 + ≥2 设计升级 confirmed
  function mergeWithDesignation(d, newRule, design, mergeWith) {
    if (!design || !mergeWith) return;
    const kp = join(config.iedaRoot, "benchmarks/flows/deepseek_harness/knowledge.json");
    const rules = d.rules || [];
    const canonical = rules.find((r) => r.id === mergeWith);
    if (!canonical) return;
    const allDesigns = new Set([...(canonical.evidence || []).map((e) => e.design)]);
    if (design) allDesigns.add(design);
    const mergedDesigns = [...allDesigns];
    canonical.evidence = mergedDesigns.map((dd) => ({
      design: dd,
      at: canonical.evidence?.find((e) => e.design === dd)?.at || new Date().toISOString(),
    }));
    if (mergedDesigns.length >= 2) {
      canonical.status = "confirmed";
      canonical.knowledge_value = "validated";
      canonical.confidence = 0.6 + Math.min(0.3, (mergedDesigns.length - 2) * 0.1);
      canonical.updated_at = new Date().toISOString();
      // 新规则并入 canonical 的 evidence 后，标记为已被合并（保留但不再独立）
      newRule.status = "merged";
      newRule.merged_into = canonical.id;
    }
    writeFileSync(kp, JSON.stringify(d, null, 2));
  }

  // report 工具：登记可归因观测
  ctx.tools.register(defineTool({
    name: "agent_report",
    description: "登记一次实验观测（可归因原始事实），不提炼。字段：design/action_type(物理动作:疏散/聚拢/放松密度/加拥塞惩罚/保持)/action_detail(具体操作+参数)/target_profile(作用对象画像:cell数+网清单pin/hpwl+热点密度)/delta(三维:egr/hpwl/timing)/baseline_metrics/after_metrics/controlled_variables(变量控制)/branch_id/wave_id/branch_done。触发条件满足时自动唤醒 distiller 提炼知识。",
    parameters: p({
      design: { type: "string", required: true },
      action_type: { type: "string", required: true },
      action_detail: { type: "string" },
      target_profile: { type: "string" },
      delta: { type: "string", required: true },
      baseline_metrics: { type: "string" },
      after_metrics: { type: "string" },
      controlled_variables: { type: "string" },
      branch_id: { type: "string" },
      wave_id: { type: "string" },
      branch_done: { type: "integer" },
    }),
    output: out(),
    execute: async (args, exec) => {
      const design = String(args.design);
      let delta, baseline, after, target;
      try { delta = JSON.parse(args.delta); } catch { delta = { raw: args.delta }; }
      try { baseline = args.baseline_metrics ? JSON.parse(args.baseline_metrics) : null; } catch { baseline = { raw: args.baseline_metrics }; }
      try { after = args.after_metrics ? JSON.parse(args.after_metrics) : null; } catch { after = { raw: args.after_metrics }; }
      try { target = args.target_profile ? JSON.parse(args.target_profile) : null; } catch { target = { raw: args.target_profile }; }

      const obs = {
        design,
        action_type: args.action_type,
        action_detail: args.action_detail || "",
        target_profile: target,
        delta,
        baseline_metrics: baseline,
        after_metrics: after,
        controlled_variables: args.controlled_variables || "",
        branch_id: args.branch_id || "",
        wave_id: args.wave_id || "default",
        branch_done: args.branch_done === 1,
        at: new Date().toISOString(),
      };
      appendObservation(config.iedaRoot, design, obs);

      const allObs = loadObservations(config.iedaRoot, design);
      const trigger = shouldTrigger(config.iedaRoot, design, obs, allObs);

      const result = { ok: true, observation_registered: true, design, trigger: trigger || null, distiller_started: false, distilled: null };

      if (trigger) {
        // 触发 distiller：同一轮观测（或全部观测）交给子 agent 提炼
        const waveObs = trigger === "conflict" ? allObs : allObs.filter((o) => o.wave_id === (obs.wave_id || "default"));
        const prompt = distillerPrompt(design, waveObs, loadKnowledge());
        try {
          const agentOptions = { maxTokens: config.distillerMaxTokens };
          if (config.distillerProvider) agentOptions.provider = config.distillerProvider;
          if (config.distillerModel) agentOptions.model = config.distillerModel;
          if (config.distillerReasoningEffort) agentOptions.reasoningEffort = config.distillerReasoningEffort;
          const run = await ctx.subagents.start(config.provider, {
            label: `distill-${design}-${trigger}`,
            prompt: [{ type: "text", text: prompt }],
            parent: exec.agent,
            signal: exec.signal,
            ...(Object.keys(agentOptions).length > 0 ? { agentOptions } : {}),
          });
          // run.result 是 Promise<{output, structured, stopReason}>；structured 是 schema 校验过的完整对象
          const runResult = await run.result;
          result.distiller_stop_reason = runResult?.stopReason;
          const text = extractText(runResult?.output);
          let parsed = null;
          if (text) {
            try {
              const m = text.match(/\{[\s\S]*\}/);
              if (m) parsed = JSON.parse(m[0]);
            } catch {}
          }
          if (parsed?.no_knowledge) {
            result.distilled = { no_knowledge: true, reason: (parsed.reason || "").slice(0, 100) };
          } else if (parsed?.knowledge) {
            const rule = saveDistilled(parsed.knowledge, design, parsed.merge_with || "", parsed.counterexample_of || "");
            // 返回精简，不带知识全文（防上下文爆炸）
            result.distilled = { rule_id: rule.id, merge_with: parsed.merge_with || null, counterexample_of: parsed.counterexample_of || null, action: (parsed.knowledge.action || "").slice(0, 80), mechanism: (parsed.knowledge.mechanism || "").slice(0, 80) };
          } else {
            result.distilled = { parse_failed: true, raw_text: text ? text.slice(0, 200) : null };
          }
          result.distiller_started = true;
        } catch (e) {
          result.distiller_error = String(e?.message || e).slice(0, 300);
        }
      }
      return result;
    },
  }));

  // read 工具：读观测 + 蒸馏知识（返回精简摘要，防上下文爆炸）
  ctx.tools.register(defineTool({
    name: "agent_observations",
    description: "读某设计的观测记录和蒸馏知识状态。kind=observations 返回本设计最近观测的精简摘要（每条只留 action_type/wave/delta 摘要）；kind=knowledge 返回蒸馏知识的精简摘要（每条只留 现象/动作/机理 各一句话）。",
    parameters: p({ design: { type: "string", required: true }, kind: { type: "string" } }),
    output: out(),
    execute: async (args) => {
      const design = String(args.design);
      if (args.kind === "observations") {
        const obs = loadObservations(config.iedaRoot, design);
        const brief = obs.slice(-30).map((o) => ({
          action_type: o.action_type,
          wave_id: o.wave_id,
          branch_id: o.branch_id,
          delta: (o.delta && (o.delta.egr || o.delta.raw || ""))?.toString?.().slice(0, 80) || JSON.stringify(o.delta || {}).slice(0, 80),
        }));
        return { ok: true, design, observation_count: obs.length, observations: brief };
      }
      const rules = loadKnowledge().filter((r) => r.id.startsWith("distilled_"));
      const brief = rules.slice(-20).map((r) => ({
        id: r.id,
        phenomenon: (r.condition?.observable || "").slice(0, 80),
        action: (r.decision?.do || "").slice(0, 80),
        mechanism: (r.decision?.mechanism || "").slice(0, 80),
      }));
      return { ok: true, distilled_count: rules.length, distilled_rules: brief };
    },
  }));
}

function extractText(output) {
  // output 是 text block 数组
  if (!output) return null;
  if (typeof output === "string") return output;
  if (Array.isArray(output)) {
    return output.map((v) => {
      if (v && typeof v === "object" && v.type === "text") return v.text;
      if (typeof v === "string") return v;
      return "";
    }).join("");
  }
  return null;
}

export { Config, inject, name };
