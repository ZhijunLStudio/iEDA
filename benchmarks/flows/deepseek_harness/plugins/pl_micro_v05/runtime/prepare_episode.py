#!/usr/bin/env python3
import argparse
import json
from pathlib import Path
import re
import shutil
import subprocess
import yaml
from common import ROOT, SUITE, desc, load, save

INSTALLED=Path.home()/'.npm-global/lib/node_modules/@deepseek-ai/dsh'


def prepare(identifier,design,model,controller='agent'):
    from study_contract import verify_study
    verify_study()
    declared=load(ROOT/'paired-plan.json')
    entry=next(e for e in declared['agent']+declared.get('repeats',[])if e['id']==identifier)
    if entry['design']!=design:raise ValueError('episode design differs from frozen plan')
    version=load(INSTALLED/'package.json')['version']
    if version!='0.2.1-rc.2':raise ValueError('DSH version differs from the frozen 0.2.1-rc.2 runtime')
    variant=entry.get('variant','autonomous')
    if variant not in ('autonomous','fixed_granularity','summary_only'):raise ValueError('unknown ablation variant')
    tests=entry.get('test_controls',{})
    if tests and declared.get('study_phase')!='technical':raise ValueError('fault injection is restricted to technical checks')
    if model!=declared.get('model','deepseek-flash') or declared.get('effort','max')!='max':
        raise ValueError('model/effort differs from fixed Flash/max plan')
    if declared.get('study_phase','formal')=='formal':
        gate=declared.get('gate_evidence')
        if declared.get('formal_gate')!='open' or not gate or desc(gate['path'])['sha256']!=gate['sha256'] or not load(gate['path']).get('ok'):
            raise ValueError('formal release gate is closed or its evidence is invalid')
    root=ROOT/'episodes'/identifier
    root.mkdir(parents=True,exist_ok=False)
    (root/'workspace').mkdir()
    profile=root/'dsh-home/profiles/research-pl'
    packages=profile/'node_modules/@ieda-ai'
    packages.mkdir(parents=True)
    plugin=root/'plugin'
    shutil.copytree(ROOT/'plugin',plugin,ignore=shutil.ignore_patterns('node_modules'))
    (plugin/'node_modules').symlink_to(INSTALLED/'node_modules',target_is_directory=True)
    (packages/'dsh-tool-pl-micro-v05').symlink_to(plugin,target_is_directory=True)
    save(profile/'package.json',{'name':'ieda-end-to-end-micro-study','private':True,
         'dsh':{'profile':{'bundles':['@deepseek-ai/dsh-base','@deepseek-ai/dsh-headless','@ieda-ai/dsh-tool-pl-micro-v05']}}})
    base=INSTALLED/'node_modules/@deepseek-ai/dsh-base/cordis.patch.yml'
    disabled=sorted(set(re.findall(r'^\s*- id: (tool-[\w-]+)\s*$',base.read_text(),re.M)))
    rows=[{'id':'llm-deepseek','config':{'baseURL':'http://127.0.0.1:1/v1','maxTokens':16384,'streamIdleTimeoutMs':180000,'retryPolicy':{'mode':'normal','maxRetries':0}}},
          {'id':'agent-default-model','config':{'provider':'deepseek-official','model':model,'reasoningEffort':'max'}},
          *[{'id':x,'disabled':True} for x in disabled],
          *[{'id':x,'disabled':True} for x in ('session-title-llm','llm-retry','plugin-manager','config-editor','settings','otel','plan-mode','goal-round-driver')],
          {'id':'approval','config':{'policy':'never'}},
          {'id':'permission','config':{'defaultPreset':'placement-domain','presets':{'placement-domain':{'sandbox':'workspace-write','approval':'never'}}}}]
    (profile/'cordis.patch.yml').write_text(yaml.safe_dump(rows,sort_keys=False))
    plan=load(ROOT/'paired-plan.json')
    arm=next(e['arm'] for e in plan['agent']+plan.get('repeats',[]) if e['id']==identifier)
    budget=dict(plan['arms'][arm]['budget'])
    prompt=f"""You are the autonomous end-to-end placement controller for {design}. From the ORIGINAL unplaced DEF generate an actual legal final DEF using only the eight PL domain tools. You control batches/parents/objectives/scopes/operators/rollback/evaluation and final selection. No shell, external geometry, source edits, EGR or hidden candidate pool. Fixed seed42 for every native start; model seed is uncontrolled.
Goal: balanced improvement of wirelength, RUDY64 peak/overflow and HPWL-RC setup/hold WNS/TNS, approaching numeric Inn targets. Begin with pl_observe(view="summary") to read state, same-prior experiment memory, the exact per-case baseline_reproduction_recipe and budgets. The tool density default0.6 differs from the original0.7 configuration for Nangate cases; original0.8 requests on other cases can be a legacy effective-density alias. Use the actual recipe to reproduce the original baseline. Memory contains verified prior recipes/metrics and failures, never geometry. Rerun any recipe from the original DEF and pay all physical costs. The rule comparator receives exactly this memory and all the same tools. Explicitly generate a deliverable safety incumbent early (use pl_observe.baseline_reproduction_recipe, including that case original requested density, timing and overflow, to convergence/its maximum iterations then LG+DP); verify its qualification and repair or try another shared recipe if staging/native ties produce an unqualified endpoint; there is no automatic fallback or hidden final choice. Known recipes are a starting point, not an obligation to repeat failed settings.
Mechanism: pl_start/pl_advance create immutable true GP checkpoints; each batch1..500 steps. pl_advance requires explicit congestion_effort0/3/4: scope selects cells and does NOT enable feedback. Modes3/4 use RUDY feedback heuristics, not the exact final metric gradient. Density floor can make different requests equivalent. Only can_advance=true snapshots can resume. pl_restore proves exact raw-DEF byte rollback with zero GP steps. Current raw_def_hpwl_um and RUDY measure the same geometry; native GP HPWL may be stale. Raw GP rank can invert after LG/DP: compare independent LEGAL measurements rather than discard promising checkpoints solely on raw scores.
pl_legalize(run_dp=false) makes LG-only; true adds DP. Immediate evaluation reports qualification, binding axes and Inn gaps; defer requires pl_evaluate first. LEGAL points are now CONTINUABLE: the legal evaluation also captures immutable same-DEF paths during its existing STA call. timing_evidence_ready=true allows immediate continuation. Optional pl_observe(candidate_id,timing_paths=true) inspects cached critical pin/net paths and hotspot topology without rerunning STA; pl_refine(candidate_id,action={{objective,operator,scope,...}}) runs the chosen legal optimization operator on that legal point. objective must be hpwl/rudy/timing/balanced; weighted HPWL is only a search heuristic. Hotspot scope follows crossing nets, critical scope follows reported path nets; global can move all eligible cells. protect_reported_timing=true excludes reported near-critical cells; false explicitly permits moving them, which may be needed to repair setup timing. Partial paths do not certify other cells. Physical transactions check frozen-complement writes; independent evaluation verifies all-cell legality, unchanged netlist/floorplan and all7 final metrics before delivery. DP checks native stage/objective activation; direct RUDY search checks native grid calibration before and after movement. A child, even if currently unqualified, can be observed and refined again to repair its remaining weak axes. Additional operator=rudy_swap with objective=rudy and scope=global (or omitted) directly scores native-calibrated RUDY64 rather than weighted HPWL. It chooses bbox-causing net endpoints and legal equal-size paired swaps. max_moves1..32 (default8) controls granularity; neighbor_trials256..32768(default4096) controls search. wire_guard=both(default)/cap/elmore/none constrains summed wire capacitance and/or wire-only Elmore mass. These are only RC proxies: no-op or timing regression remains possible. Action and evaluation are separate. Immediate evaluation is the default; deferred searches only create proposals. Cache hits consume no new STA; all attempted search, trials and CPU remain charged, including no-ops and failures. Reported timing guard also freezes incident net closure. path_guard=critical(default) covers near-critical reported paths; critical_and_hold adds all reported hold paths, useful when already-positive hold slack is a weak frozen axis; all_reported covers every reported setup/hold path. A stronger guard can produce no move. Unreported paths remain unknown. Current unqualified cost axes may improve through intermediate children; final qualification still uses original fixed bounds. Select configurations and guards from measured feedback; do not equate RUDY-only improvement with all-axis progress. Parents are immutable and remain selectable. Compare deltas and avoid identical/no-op proposals.
Frozen delivery envelope: original iEDA remains the fixed anchor. Spend at most90% of the original advantage on axes better than Inn; originally worse axes cannot deteriorate beyond epsilon. Already met timing cannot become negative. Cost epsilon1e-6 reported units, timing epsilon0.001ns, exact met-timing sign check. Only qualified endpoints can finish; raw failed tradeoffs remain recorded. Among qualified candidates minimize the worst positive normalized Inn gap, then sum. A scalar win is not all-axis dominance. Strong axes may trade within envelope to help weak axes. HPWL/peak gaps divide by reference, overflow by max(abs(reference),1), WNS loss by clock period, TNS by max(abs(reference),period). Tiny positive hold differences should not dominate effort.
Hard budget shared with rules: {budget['wall_seconds']} wall seconds including API/native/errors/measurement/final reply; {budget['physical_cpu_seconds']} physical CPU seconds; {budget['actual_gp_steps']} actual GP iterations; {budget['neighbor_trials']} actual neighboring-pair trials; {budget['fresh_sta']} fresh full STA attempts including failures; {budget['tool_calls']} tool calls; {budget['starts']} starts; {budget['model_requests']} model requests. Cache hits do not refund search, attempts or CPU. Default observations stay compact; request detail only when useful. Output cap16384; use concise public decision notes. Reserve{budget['finalization_reserve_s']} seconds and enough requests for explicit delivery. Stopping requires a successful pl_finish(candidate_id,stop_reason). Evidence applies only to tested parents/actions; fixed trial counts do not prove a physics floor. Continue useful hypotheses within budget; avoid repeating no-ops. Errors remain recorded within unchanged caps.
v0.5 adds pl_evaluate(proposal_id). pl_refine action fields belong in action={{operator,objective,...}}, with top-level candidate_id and evaluation=immediate/defer. Both refinement and legalization can defer seven-axis evaluation: proposals cannot finish until evaluated. Each accepted swap has a prefix proposal ID. DP max_selected_cells enforces actual scope size. Query cached paths with view=paths and endpoint/path/node pagination, hotspots/net_name, cells/cell_name, compare or proposals. Physical actions stop before the finalization reserve; keep API calls and time for an explicit finish. Read physical CPU, actual GP steps, actual neighbor trials and fresh STA counters; every attempted search remains charged. Use no_change/filter evidence rather than repeating identical actions. Choose useful experiments yourself. Finish with selected metrics, tradeoffs, what failed and why you stopped. These are placement proxies, not routed/signoff claims.
"""
    if variant=='fixed_granularity':prompt+='\nFrozen-grain ablation: every GP batch is100 requested steps, every swap batch accepts at most1, every DP selects at most64 cells, and actions evaluate immediately. The actor enforces these bounds and reports effective arguments. All other branch/objective/repair choices remain yours.\n'
    if variant=='summary_only':prompt+='\nSummary-observation ablation: compact candidate metrics, budgets and shared prior are available. Detailed paths, cells, hotspots and comparisons are hidden. Physical guards retain their normal internal evidence.\n'
    (root/'prompt.txt').write_text(prompt)
    sources=[desc(ROOT/p) for p in ('study_contract.py','policy_menu.py','legacy_backend.py','evaluation_cache.py','work_budget.py','common.py','process_supervisor.py','native_session.py','pl_backend.py','prepare_episode.py','episode_runner.py','surplus.py','physical_observation.py','legal_refinement.py','rudy_direct.py','rudy_adapter.py','experience.json','paired-plan.json')]
    save(root/'preparation.json',{'episode_id':identifier,'design':design,'controller':controller,'model':model,
         'effort':'max','variant':variant,'test_controls':tests,'dsh_version':version,'node_version':subprocess.check_output(['/usr/bin/node','--version'],text=True).strip(),'study_phase':declared.get('study_phase','formal'),'arm':arm,'plan':desc(ROOT/'paired-plan.json'),'budget':budget,'suite':desc(SUITE),'sources':sources,'prompt':desc(root/'prompt.txt'),
         'plugin_sources':[desc(p) for p in plugin.rglob('*') if p.is_file() and 'node_modules' not in p.parts],
         'native_or_API_runs_during_preparation':0,'reference_geometry_access':False,
         'source_snapshot_note':'Parent will lock and copy these exact execution modules before activation.'})
    print(json.dumps({'episode':str(root),'preparation':desc(root/'preparation.json')}))


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--id',required=True);p.add_argument('--design',required=True)
    p.add_argument('--model',default='deepseek-flash');p.add_argument('--controller',default='agent')
    a=p.parse_args();prepare(a.id,a.design,a.model,a.controller)
