import { defineTool } from '@deepseek-ai/dsh-tools';
import { spawn } from 'node:child_process';
import { appendFileSync, existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
export const name='pl-micro-v05';
export const inject=['tools'];
const allowed=new Set(['pl_observe','pl_start','pl_advance','pl_restore','pl_legalize','pl_refine','pl_evaluate','pl_finish']);
const str=(values,required=false)=>({type:'string',...(values?{enum:values}:{}),...(required?{required:true}:{})});
const integer=(required=false)=>({type:'integer',...(required?{required:true}:{})});
const bool=()=>({type:'boolean'});
const literal=(value,required=false)=>({type:typeof value,const:value,...(required?{required:true}:{})});
function invoke(op,args){return new Promise(resolve=>{
  const episode=process.env.IEDA_EPISODE,backend=process.env.IEDA_MICRO_BACKEND;
  if(!episode||!backend)return resolve({ok:false,message:'Missing fixed episode/backend configuration'});
  const child=spawn('/usr/bin/python3',[backend,'call','--episode',episode],{stdio:['pipe','pipe','pipe']});let out='',err='';
  child.stdout.on('data',c=>out+=c);child.stderr.on('data',c=>err+=c);
  child.on('error',e=>resolve({ok:false,message:String(e)}));
  child.on('close',code=>{try{resolve(JSON.parse(JSON.stringify(JSON.parse(out))));}catch{resolve({ok:false,message:`Backend client failed (${code}): ${err.slice(-1000)}`});}});
  child.stdin.end(JSON.stringify({op,args}));
});}
const dp={type:'object',additionalProperties:false,properties:{operator:str(['row_opt','instance_swap','local_reorder','bin_opt','all'],true),objective:str(['hpwl','rudy','timing','balanced'],true),scope:str(['hotspot','critical','global']),protect_reported_timing:bool(),strength:integer(),hotspot_index:integer(),radius_bins:integer(),max_selected_cells:integer()}};
const direct={operator:literal('rudy_swap',true),objective:literal('rudy',true),scope:literal('global'),max_moves:integer(),neighbor_trials:integer(),wire_guard:str(['both','cap','elmore','none'])};
export function apply(ctx){
 const episode=process.env.IEDA_EPISODE;
 const journal=episode?join(episode,'frontend-calls.jsonl'):null;
 const seen=new Set(journal&&existsSync(journal)?readFileSync(journal,'utf8').trim().split('\n').filter(Boolean).map(s=>JSON.parse(s).callId):[]);
 ctx.tools.guard(call=>{
   if(!allowed.has(call.name))return 'Only eight versioned PL domain tools are allowed.';
   if(!episode)return 'Missing fixed episode configuration';
   const cap=JSON.parse(readFileSync(join(episode,'episode.json'),'utf8')).budget.tool_calls;
   if(!seen.has(call.callId)){
     seen.add(call.callId);
     appendFileSync(journal,JSON.stringify({callId:call.callId,name:call.name,index:seen.size,time_unix_ms:Date.now(),blocked:seen.size>cap})+'\n');
   }
   return seen.size>cap?'Episode tool-call budget exhausted; rejected before parameter validation or physics':undefined;
 });
 const reg=(name,op,description,parameters)=>{
   const tool=defineTool({name,description,parameters,output:{schema:{type:'json'},render:(_args,v)=>[{type:'text',text:JSON.stringify(v)}]},execute:args=>invoke(op,args)});
   const normalize=schema=>{
     if(!schema||typeof schema!=='object')return;
     if(schema.type==='object'){
       if(schema.required===undefined)schema.required=[];
       if(schema.additionalProperties===undefined)schema.additionalProperties=false;
     }
     for(const value of Object.values(schema)){
       if(Array.isArray(value))value.forEach(normalize);else normalize(value);
     }
   };
   // An absent required list is valid JSON Schema, but a gateway adapter can
   // turn a missing list into null. Emit explicit arrays without changing
   // which parameters are optional; reject unknown fields at both boundaries.
   normalize(tool.parameters);
   if(op==='observe'){
     const execute=tool.execute;
     tool.execute=(args,exec)=>execute(args&&typeof args==='object'&&!Array.isArray(args)?{view:'summary',...args}:args,exec);
   }
   ctx.tools.register(tool);
 };
 reg('pl_observe','observe','Read compact state with view=summary, exact baseline recipe, same-prior memory, immutable candidates and real work. Details are addressable: view=paths with candidate_id, analysis, endpoint and path/node pagination reads cached same-DEF paths without STA. Unknown paths/cells are not timing-safe. view=hotspots supports net_name; cells supports cell_name; compare needs two candidate IDs; proposals pages unmeasured proposals/prefixes; filters with proposal_id returns guard/trial rejection evidence. Full seven-axis qualification exists only after evaluation.',{view:str(['summary','memory','paths','hotspots','cells','compare','proposals','filters'],true),candidate_id:str(),snapshot_id:str(),proposal_id:str(),timing_paths:bool(),analysis:str(['setup','hold','both']),endpoint:str(),offset:integer(),limit:integer(),node_offset:integer(),node_limit:integer(),net_name:str(),cell_name:str(),other_candidate_id:str()});
 reg('pl_start','start','Start from ORIGINAL DEF with seed42, steps1..500, density0.4..0.8, overflow0.03..0.2, timing boolean. Feedback0=off,3/4=RUDY heuristics, not final64 gradient. Inspect effective density and current raw-DEF HPWL/RUDY. Returns immutable resumable GP checkpoint; no free baseline.',{steps:integer(true),target_density:{type:'number'},target_overflow:{type:'number'},congestion_effort:{type:'integer',enum:[0,3,4]},timing:bool()});
 reg('pl_advance','advance','Resume only a paused can_advance snapshot, steps1..500. Explicit feedback0/3/4; scope changes movable cells, not objective. Parent remains immutable. rudy_guarded requires same-snapshot path observation.',{snapshot_id:str(null,true),steps:integer(true),congestion_effort:{type:'integer',enum:[0,3,4],required:true},scope:str(['global','rudy_region','density_hotspot','rudy_guarded']),hotspot_index:integer(),radius_bins:integer()});
 reg('pl_restore','restore','Restore a GP checkpoint with zero extra GP iterations and verify byte-identical exported DEF. For legal branches select their immutable candidate IDs.',{snapshot_id:str(null,true)});
 reg('pl_legalize','legalize','Execute LG, optionally DP. evaluation=immediate(default) measures seven axes; defer returns an unmeasured proposal, which cannot finish. GP may be paused or terminated. Legalization/DP can change GP ranking.',{snapshot_id:str(null,true),run_dp:bool(),evaluation:str(['immediate','defer'])});
 reg('pl_refine','refine','Operate on a measured legal parent, including unqualified parents needing repair. DP strength1..8 is net-weight strength; max_selected_cells is a real frozen-complement bound. Direct rudy_swap uses max_moves1..32 and neighbor_trials256..32768; trial cap is separately charged. Captures each accepted-swap prefix as proposal IDs. RC/path guards are partial proxies; none may unlock useful moves but full STA remains necessary. evaluation=defer avoids automatically measuring the final batch, so selected prefixes can be evaluated instead. All unmeasured proposals are non-deliverable; parent unchanged.',{candidate_id:str(null,true),evaluation:str(['immediate','defer']),action:{oneOf:[dp,{type:'object',additionalProperties:false,properties:{...direct,protect_reported_timing:literal(true),path_guard:str(['critical','critical_and_hold','all_reported'])}},{type:'object',additionalProperties:false,properties:{...direct,protect_reported_timing:literal(false,true)}}],required:true}});
 reg('pl_evaluate','evaluate','Measure one proposal/prefix with independent legality/identity/HPWL/RUDY64/full setup/hold and cached paths. Creates a measured candidate; unqualified measured candidates may be repaired but cannot finish. Episode-local cache requires all measurement assets/code/loader fingerprints unchanged; searches/attempts are charged even on hits.',{proposal_id:str(null,true)});
 reg('pl_finish','finish','Explicitly select an evaluated qualified immutable candidate, verify SHA and deliver final.def. No hidden fallback or best-candidate override. Stop evidence is confined to tested states/actions, never proof of a global floor. Reserve delivery time; final seven-axis envelope remains fixed.',{candidate_id:str(null,true),stop_reason:str(['targets_matched','evidence_stagnation','quota_exhausted','time_reserve','no_eligible_scope'],true)});
}
