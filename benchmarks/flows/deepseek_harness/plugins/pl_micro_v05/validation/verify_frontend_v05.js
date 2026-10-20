// Replay real historical malformed arguments through the installed DSH validator.
// No backend environment is configured: no physical or API call can be made.
import fs from 'node:fs';
import { pathToFileURL } from 'node:url';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
const [plugin, fixture] = process.argv.slice(2);
const episode=fs.mkdtempSync(join(tmpdir(),'pl-frontend-budget-'));
process.env.IEDA_EPISODE=episode;
fs.writeFileSync(join(episode,'episode.json'),JSON.stringify({budget:{tool_calls:10}}));
const definitions = new Map();
let guard;
const { apply } = await import(pathToFileURL(plugin));
apply({ tools: { guard(callback) { guard=callback; }, register(tool) { definitions.set(tool.name, tool); } } });
const rows = JSON.parse(fs.readFileSync(fixture, 'utf8')).errors;
const outcomes = [];
for (const row of rows) {
  const { op, args } = structuredClone(row.request);
  // Lift historical flat actions into the v0.5 conditional action object.
  let normalized = args;
  if (op === 'refine') {
    const { candidate_id, ...action } = args;
    normalized = { candidate_id, action };
  }
  let rejected = false;
  let reason;
  const admitted=guard({name:'pl_'+op,callId:'historical-'+outcomes.length})===undefined;
  try { await definitions.get('pl_' + op).execute(normalized, {}); }
  catch (error) { rejected = true; reason = String(error); }
  outcomes.push({ op, rejected_before_backend: rejected, charged_frontend_attempt:admitted, reason });
}
let restoredGuard;
apply({tools:{guard(callback){restoredGuard=callback;},register(){}}});
const resumedDenial=restoredGuard({name:'pl_observe',callId:'eleventh-call'});
const journal=fs.readFileSync(join(episode,'frontend-calls.jsonl'),'utf8').trim().split('\n').map(JSON.parse);
const budgetChecks={invalid_arguments_count_toward_budget:journal.length===11,
  same_episode_resume_keeps_counter:typeof resumedDenial==='string',
  over_cap_rejected_before_dispatch:journal.at(-1).blocked===true};
const result = { ok: definitions.size === 8 && outcomes.length === 10 && outcomes.every(x => x.rejected_before_backend&&x.charged_frontend_attempt)&&Object.values(budgetChecks).every(Boolean),
  budget_checks:budgetChecks,
  tool_count: definitions.size, outcomes, physical_executions: 0, API_requests: 0 };
console.log(JSON.stringify(result));
fs.rmSync(episode,{recursive:true});
if (!result.ok) process.exitCode = 1;
