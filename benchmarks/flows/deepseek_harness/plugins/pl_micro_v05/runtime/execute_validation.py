"""Durable gated validation driver. No retries, model fallback or Git writes.

This driver only advances a phase after its evidence passes. All studies are
materialized from the same immutable package copy before any holdout policy
run. Failure records remain in place and close subsequent gates.
"""
import argparse
import ast
import copy
import concurrent.futures
import queue
import json
import math
import os
import signal
import subprocess
import sys
import time
from pathlib import Path
from common import ROOT, load, save, desc, sha, pid_identity
from release_gate import REQUIRED, CRITICAL, release


class Workflow:
    def __init__(self, master, package, run_name='workflow-v1', adopt_development=None,development_name='dev-v4',model_revalidation_name=None):
        self.master=Path(master).resolve();self.package=Path(package).resolve()
        self.deadline=load(self.master/'protocol/source-before.json')['deadline_unix']
        self.env={**os.environ,'PYTHONHASHSEED':'42'}
        self.receipts=self.master/run_name;self.receipts.mkdir(exist_ok=False)
        self.adopt_development=Path(adopt_development).resolve()if adopt_development else None
        self.development_name=development_name
        self.model_revalidation_name=model_revalidation_name
        self.package_lock={str(p.relative_to(self.package)):sha(p)for p in self.package.rglob('*')if p.is_file()and '__pycache__'not in p.parts}
        save(self.receipts/'started.json',{'identity':pid_identity(os.getpid()),'deadline_unix':self.deadline,'package':str(self.package),'source_hashes':self.package_lock})

    def state(self,phase,**extra):
        value={'phase':phase,'formal_gate':'open'if(self.master/'main-v1').exists()else'closed',
               'formal_episodes_started':len(list((self.master/'main-v1/episodes').glob('*/episode-started.json'))),
               'commits':0,'pushes':0,'updated_unix':time.time(),**extra}
        save(self.master/'WORK-STATE.json',value)
        with(self.receipts/'events.jsonl').open('a')as stream:stream.write(json.dumps(value)+'\n')
        print(json.dumps(value),flush=True)

    def wait_existing(self):
        self.state('waiting_for_retained_engineering_and_development_jobs')
        paths=[self.master/'qa-v4/technical-job-summary.json']
        if(self.master/'resource-v1').exists():paths.append(self.master/'resource-v1/cohort-result.json')
        while not all(p.exists()for p in paths):
            if time.time()>self.deadline:raise RuntimeError('two-week deadline reached before engineering jobs completed')
            time.sleep(5)
        resource=self.master/'resource-v1/cohort-result.json'
        if resource.exists()and not load(resource)['ok']:raise RuntimeError('AES resource-cutoff repair did not pass; formal gate remains closed')

    def command(self,name,args,cwd=None,study=None,native_cpu=None):
        log=self.receipts/(name+'.log')
        with log.open('xb')as stream:
            env={**self.env}
            if study:env['IEDA_STUDY_ROOT']=str(study)
            else:env.pop('IEDA_STUDY_ROOT',None)
            if native_cpu is not None:env['IEDA_NATIVE_CPU']=str(native_cpu)
            process=subprocess.Popen(args,cwd=cwd,env=env,stdout=stream,stderr=subprocess.STDOUT,start_new_session=True)
            save(self.receipts/(name+'-started.json'),{'command':args,'identity':pid_identity(process.pid),'log':str(log)})
            while process.poll()is None:
                if time.time()>self.deadline:
                    os.killpg(process.pid,signal.SIGTERM)
                    try:process.wait(timeout=5)
                    except subprocess.TimeoutExpired:os.killpg(process.pid,signal.SIGKILL);process.wait()
                    if study:
                        sys.path.insert(0,str(study));from run_policy_study import cleanup_episode
                        for root in(study/'episodes').glob('*'):cleanup_episode(root)
                    raise RuntimeError('two-week deadline; unfinished validation retained')
                time.sleep(2)
        result={'returncode':process.returncode,'log':desc(log)};save(self.receipts/(name+'-terminal.json'),result)
        if process.returncode:raise RuntimeError(name+' failed; see '+str(log))

    def materialize(self,name,plan):
        for leaf,expected in self.package_lock.items():
            if sha(self.package/leaf)!=expected:raise RuntimeError('immutable workflow package changed: '+leaf)
        planpath=self.receipts/(name+'-plan.json');save(planpath,plan)
        target=self.master/name
        args=['/usr/bin/python3',str(self.package/'materialize_study.py'),'--output',str(target),
              '--suite',str(self.master/'suite.json'),'--plan',str(planpath),
              '--experience',str(self.master/'experience.json'),'--helpers',str(self.master/'helpers'),
              '--references',str(self.master/'references')]
        self.command(name+'-materialize',args)
        return target

    def cohort(self,name,study,workers=4):
        self.command(name,['/usr/bin/python3',str(study/'run_policy_study.py'),'--workers',str(workers)],study=study)
        return load(study/'cohort-result.json')

    def engineering(self,study):
        # Recheck final contract and frontend after the final delivery guard.
        jobs=[('final-contract','verify_v05',"'gcd','gate-g0'"),('final-budget','verify_runtime_v05',"'rt-gate'"),
              ('final-gp-gcd','verify_gp_partitions_v05',"'gcd_nangate45_a','gate-gp0'"),('final-gp-salsa','verify_gp_partitions_v05',"'salsa20_sky130_a','gate-gp1'"),
              ('final-prefix-AES','verify_prefix_controls_v05',"'aes','gate-p00'"),('final-prefix-Salsa','verify_prefix_controls_v05',"'salsa20_sky130_a','gate-p01'"),
              ('final-processes','verify_process_supervisor',None),('final-queue','verify_queue_v05',None)]
        slots=queue.Queue()
        for cpu in sorted(os.sched_getaffinity(0))[:4]:slots.put(cpu)
        def execute(job):
            label,module,arguments=job;cpu=slots.get()
            code='import sys;sys.path.insert(0,sys.argv[1]);'
            code+=('from validation.'+module+' import run;run('+arguments+')')if arguments else'import validation.'+module
            try:self.command(label,['/usr/bin/python3','-c',code,str(study)],study=study,native_cpu=cpu)
            finally:slots.put(cpu)
        with concurrent.futures.ThreadPoolExecutor(max_workers=4)as pool:
            for future in concurrent.futures.as_completed([pool.submit(execute,job)for job in jobs]):future.result()
        node_modules=study/'plugin/node_modules'
        if not node_modules.exists():node_modules.symlink_to(Path.home()/'.npm-global/lib/node_modules/@deepseek-ai/dsh/node_modules',target_is_directory=True)
        self.command('final-frontend',['/usr/bin/node',str(study/'validation/verify_frontend_v05.js'),str(study/'plugin/lib/index.js'),str(self.master.parent/'pl-grain-v1/contracts/historical-parameter-errors.json')])
        result=self.cohort('final-model-and-resume',study)
        if not result['ok']:raise RuntimeError('final model or same-session resume check failed')

    def evidence(self,study,gate,models=None):
        models=models or study
        qa=self.master/'qa-v4';data={};files={}
        def record(name,checks,inputs):
            value={'ok':all(checks.values()),'checks':checks,'sources':[desc(p)for p in inputs]}
            path=self.receipts/('evidence-'+name+'.json');save(path,value);files[name]=desc(path);data[name]=value
        contract=load(gate/'episodes/gate-g0/validation-result.json')
        budget=load(gate/'technical/rt-gate/result.json')
        front=json.loads((self.receipts/'final-frontend.log').read_text())
        processes=json.loads((self.receipts/'final-processes.log').read_text())
        queue=json.loads((self.receipts/'final-queue.log').read_text())
        holdout=load(self.master/'audit/holdout-qualification.json')
        record('holdout_inputs',{'audit_passed':holdout.get('ok')is True},[self.master/'audit/holdout-qualification.json'])
        record('parameters_frontend',{'ten_rejected':front.get('ok')is True},[self.receipts/'final-frontend.log'])
        record('parameters_backend',{'historical_errors':contract['checks']['all10_historical_errors_rejected_before_physics'],'delivery_context_guard':contract['checks']['changed_measurement_context_cannot_deliver_cached_candidate']},[gate/'episodes/gate-g0/validation-result.json'])
        record('cache',{'cache_input_checks':budget['ok'],'hit':contract['checks']['same_fingerprint_cache_hit_no_STA'],'current_parent_delta':contract['checks']['cache_hit_delta_uses_current_proposal_parent']},[gate/'technical/rt-gate/result.json',gate/'episodes/gate-g0/validation-result.json'])
        record('DP_scope',{'enforced_bound':contract['checks']['DP_selected_and_moved_bound_enforced']},[gate/'episodes/gate-g0/validation-result.json'])
        for suffix,name in [('00','AES'),('01','Salsa')]:
            path=gate/'episodes'/('gate-p'+suffix)/'prefix-controls-result.json'
            record('prefix_'+name,{'passed':load(path)['ok']},[path])
        gp=[gate/'episodes'/identifier/'partition-result.json'for identifier in('gate-gp0','gate-gp1')]
        record('GP_partitions',{'both_passed':all(load(p)['ok']for p in gp)},gp)
        model=gate/'episodes/gate-a0/result.json';resume=gate/'episodes/gate-a1/result.json';r=load(resume)
        record('real_Flash',{'fresh_current_version_model_deliveries':all(load(models/'episodes'/e['id']/'result.json')['ok']for e in load(models/'paired-plan.json')['agent'])},[model,*[models/'episodes'/e['id']/'result.json'for e in load(models/'paired-plan.json')['agent']]])
        record('same_session_resume',{'passed':r['ok'],'actually_resumed':len(r['controller_turns'])>=2,'one_actor_session':len({t['session_id']for t in r['controller_turns']})==1,'injected_failure_retained':r['technical_fault_injection_count']==1},[resume])
        record('budget_cutoff',{'passed':budget['ok'],'CPU_with_cleanup':budget['checks']['CPU_including_cleanup_within_cap']},[gate/'technical/rt-gate/result.json'])
        record('owned_processes',{'passed':processes['ok'],'queue_accounting':queue['ok']},[self.receipts/'final-processes.log',self.receipts/'final-queue.log'])
        pairs=[];deterministic={}
        for k,mode in enumerate(('coarse','fine','adaptive')):
            paths=[study/'episodes'/('v1-r%d%d'%(k,rep))/'result.json'for rep in(0,1)]
            a,b=[load(p)for p in paths]
            keys=('actual_gp_steps','neighbor_trials_used','fresh_sta_used')
            deterministic[mode]=a['ok']and b['ok']and a['delivery']['def']['sha256']==b['delivery']['def']['sha256']and a['delivery']['metrics']==b['delivery']['metrics']and all(a['work'][key]==b['work'][key]for key in keys)
            pairs+=paths
        record('deterministic_controllers',deterministic,pairs)
        assert set(files)==set(REQUIRED)
        tested={name:sha(models/name)for name in CRITICAL};tested['plugin/lib/index.js']=sha(models/'plugin/lib/index.js')
        # Only the public cache-hit parent/delta response was corrected after
        # development. It is exercised by the fresh contract/model gate; the
        # physical transitions and deterministic rule implementation match.
        tested['pl_backend.py']=sha(gate/'pl_backend.py')
        manifest=self.receipts/'engineering-evidence.json';save(manifest,{'evidence':files,'tested_sources':tested,'baseline_diagnostics_retained':[str(self.master/'baseline-v1/baseline-summary.json'),str(self.master/'qa-v2/baseline-summary.json')]})
        return manifest

    def analyze(self,name,study):
        output=study/name
        self.command(study.name+'-'+name,['/usr/bin/python3',str(study/'analyze_policy_study.py'),'--output',str(output)],study=study)
        self.command(study.name+'-'+name+'-plots',['/usr/bin/python3',str(study/'plot_policy_study.py'),'--analysis',str(output)],study=study)
        return load(output/'decision.json')

    def post_main(self,main,decision):
        plan=load(main/'paired-plan.json');suite=load(main/'suite.json')
        winners=decision['catchup_required'];follow=copy.deepcopy(plan)
        follow.update(schema='v05-frozen-rule-extra-compute',agent=[],rule=[],execution_order=[],repeats=[])
        budget=follow['arms']['main']['budget']
        # Predeclared 25% extra allowance in every consumable physical/action
        # budget. Same policy and menu, original DEF, independent cache.
        for key in('physical_cpu_seconds','actual_gp_steps','requested_gp_steps','neighbor_trials','fresh_sta','legalizations','starts','tool_calls'):
            budget[key]=math.ceil(1.25*budget[key])
        for i,row in enumerate(winners):
            original=next(e for e in plan['rule']if e['id']==row['strongest_rule_episode'])
            entry={**original,'id':'cu%02d0'%i};follow['rule'].append(entry);follow['execution_order'].append(entry['id'])
        catchup=self.materialize('catchup-v1',follow);self.state('running_frozen_rule_compute_catchup',cases=len(winners))
        self.cohort('catchup-cohort',catchup)
        results=[]
        for entry,row in zip(follow['rule'],winners):
            agent=load(main/'episodes'/row['median_actual_episode']/'result.json')
            rule=load(catchup/'episodes'/entry['id']/'result.json')
            audit=load(catchup/'audits'/entry['id']/'result.json')if(catchup/'audits'/entry['id']/'result.json').exists()else{}
            from analyze_policy_study import rank,better,practical_gain
            target=__import__('pl_backend').scalar_metrics(load(main/'references'/entry['design']/'inn/attempt-1/result.json'))
            period=suite['designs'][entry['design']]['clock_period_ns']
            enough=rule.get('work',{}).get('physical_cpu_s',0)>=agent['work']['physical_cpu_s']
            won=bool(row['agent_win']and rule.get('ok')and audit.get('ok')and enough and better(rank(agent['delivery']['metrics'],target,period),rank(rule['delivery']['metrics'],target,period)))
            practical=False
            if rule.get('ok')and audit.get('ok')and enough:
                original=load(main/'episodes'/row['strongest_rule_episode']/'result.json')
                old_metrics=original['delivery']['metrics'];new_metrics=rule['delivery']['metrics']
                # Extra-budget scheduling need not visit a superset of the
                # original trajectories. Retain the stronger reference; never
                # manufacture a practical gain against a worse catchup run.
                oldrank,newrank=rank(old_metrics,target,period),rank(new_metrics,target,period)
                oldgain=practical_gain(agent['delivery']['metrics'],old_metrics,target,period)[0]
                newgain=practical_gain(agent['delivery']['metrics'],new_metrics,target,period)[0]
                practical=newgain if newrank<oldrank else oldgain if oldrank<newrank else oldgain and newgain
            results.append({**row,'catchup_episode':entry['id'],'CPU_caught_up':enough,'survived_catchup':won,'agent_work':agent['work'],'rule_work':rule.get('work'),
                            'practical_gain_after_catchup':practical,
                            'note':'All GP/trial/STA counts and API/wall costs retained; CPU catchup alone is not proof of LLM reasoning.'})
        n_challenge=sum(x['challenge']for x in decision['per_design'])
        passed=sum(x['survived_catchup']and x['challenge']for x in results)>=.6*n_challenge and sum(x['survived_catchup']and x['holdout']for x in results)>=3 and sum(x['practical_gain_after_catchup']and x['challenge']for x in results)>=3
        save(self.receipts/'catchup-decision.json',{'ok':passed,'results':results,'interpretation':'Failure to spend matched actual CPU is attribution incomplete, not a confirmed agent strategy win.'})
        if not passed:return 'stop_expanding_current_agent_QoR_claim_after_compute_audit'
        ablation=copy.deepcopy(plan);ablation.update(schema='v05-conditional-ablations',agent=[],rule=[],execution_order=[],repeats=[])
        for i,design in enumerate(('salsa20_sky130_a','aes')):
            for j,variant in enumerate(('fixed_granularity','summary_only')):
                for repeat in range(3):
                    entry={'id':'ab%d%d%d'%(i,j,repeat),'design':design,'arm':'main','variant':variant}
                    ablation['agent'].append(entry);ablation['execution_order'].append(entry['id'])
        root=self.materialize('ablations-v1',ablation);self.state('running_twelve_conditional_ablation_episodes')
        self.cohort('ablation-cohort',root)
        self.command('ablation-summary',['/usr/bin/python3',str(root/'summarize_ablations.py'),'--main',str(main),'--ablations',str(root),'--output',str(root/'analysis-v1')],study=root)
        save(self.receipts/'ablation-index.json',{'plan':desc(root/'paired-plan.json'),'results':[desc(p)for p in(root/'episodes').glob('*/result.json')],'scope':'All twelve actual deliveries and failures; no pooled best selection.'})
        return 'continue_with_larger_repeats_and_final_physical_validation'

    def run(self):
        try:
            self.wait_existing()
            # A new cold study supersedes unstarted dev-v2; it retains the final
            # floor/feedback fixes and final context-at-delivery guard.
            devplan=load(self.master/'protocol/development-final-plan.json')
            if self.adopt_development:
                development=self.adopt_development
                checks={name:sha(ROOT/name)==sha(development/name)for name in CRITICAL}
                if not checks['pl_backend.py']:
                    def physical_AST(path):
                        tree=ast.parse(Path(path).read_text())
                        for node in tree.body:
                            if isinstance(node,ast.ClassDef)and node.name=='PlacementSession':node.body=[n for n in node.body if not(isinstance(n,ast.FunctionDef)and n.name=='_evaluation_view')]
                        return ast.dump(tree,include_attributes=False)
                    checks['pl_backend.py']=physical_AST(ROOT/'pl_backend.py')==physical_AST(development/'pl_backend.py')
                    save(self.receipts/'metadata-response-correction.json',{'ok':checks['pl_backend.py'],'old':desc(development/'pl_backend.py'),'new':desc(ROOT/'pl_backend.py'),'only_changed_method':'_evaluation_view','reason':'A cache hit must report the current proposal parent and its actual delta, not the canonical candidate origin parent. Fresh contract and real model checks use the corrected response.'})
                if self.model_revalidation_name:
                    # Direct rule controllers use neither DSH preparation nor
                    # its wire serializer. Their complete physical/runtime
                    # sources must still match; all four model cases are run
                    # afresh with the current schema before release.
                    checks.pop('episode_runner.py',None);checks.pop('prepare_episode.py',None)
                else:checks['plugin']=sha(ROOT/'plugin/lib/index.js')==sha(development/'plugin/lib/index.js')
                save(self.receipts/'development-adoption.json',{'ok':all(checks.values()),'checks':checks,'same_ongoing_episodes':True,'budget_reset':False,'study':str(development),'plan':desc(development/'paired-plan.json')})
                if not all(checks.values()):raise RuntimeError('cannot adopt development with changed controller/runtime sources')
                self.state('adopting_same_live_development_without_budget_reset')
                while not(development/'cohort-result.json').exists():
                    expected=load(development/'paired-plan.json')
                    ids=[e['id']for e in expected['rule']+expected['agent']]
                    receipts=[development/'attempt-receipts'/(identifier+'.json')for identifier in ids]
                    if all(p.exists()for p in receipts):
                        # Recover only aggregation from the already completed
                        # independently audited attempts. No physics or model
                        # request is rerun and no per-episode result is edited.
                        rows={identifier:load(path)for identifier,path in zip(ids,receipts)}
                        recovered={'ok':all(r['ok']for r in rows.values()),'completed':len(rows),'total':len(ids),'results':rows,
                                   'recovery':'Aggregate result not yet available; summary rebuilt from all completed independent attempt receipts without rerunning any episode. Original receipts and logs remain authoritative.',
                                   'sources':[desc(p)for p in receipts]}
                        save(development/'cohort-recovered-v1.json',recovered)
                        break
                    if time.time()>self.deadline:raise RuntimeError('deadline while adopting ongoing development')
                    time.sleep(5)
                result=load(development/'cohort-result.json')if(development/'cohort-result.json').exists()else load(development/'cohort-recovered-v1.json')
            else:
                development=self.materialize(self.development_name,devplan)
                self.state('running_final_four_design_development_and_determinism')
                # The retained older development queue still owns up to2 slots.
                result=self.cohort('final-development',development,workers=4 if(self.master/'pilot-three-v1/cohort-result.json').exists()else 2)
            models=development
            if self.model_revalidation_name:
                old_plan=load(development/'paired-plan.json')
                rules_ok=all(result['results'][e['id']]['ok']for e in old_plan['rule'])
                save(self.receipts/'rule-only-adoption.json',{'ok':rules_ok,'source':str(development),'used_rule_ids':[e['id']for e in old_plan['rule']],'old_model_failures_retained':[k for k,v in result['results'].items()if not v['ok']],'reason':'Gateway wire-schema compatibility fix; rule/physical sources unchanged, new four-case actual model validation required.'})
                if not rules_ok:raise RuntimeError('rule development failed; formal gate remains closed')
                modelplan=copy.deepcopy(devplan);modelplan['rule']=[];modelplan['execution_order']=[e['id']for e in modelplan['agent']]
                models=self.materialize(self.model_revalidation_name,modelplan)
                self.state('revalidating_four_headless_models_with_gateway_compatible_schemas')
                result=self.cohort('model-schema-revalidation',models)
            if not result['ok']:raise RuntimeError('final development has failed episodes; formal gate remains closed')
            gateplan=copy.deepcopy(devplan);gateplan.update(study_phase='technical',rule=[],agent=[],execution_order=[])
            gateplan['arms']['pilot']['budget'].update(wall_seconds=1200,physical_cpu_seconds=900,fresh_sta=8,legalizations=8,model_requests=40)
            for index in(0,1):
                entry={'id':'gate-a%d'%index,'design':'gcd_nangate45_a','arm':'pilot'}
                if index:entry['test_controls']={'first_request_503':True}
                gateplan['agent'].append(entry);gateplan['execution_order'].append(entry['id'])
            gate=self.materialize('gate-v1',gateplan);self.engineering(gate)
            manifest=self.evidence(development,gate,models)
            evidence=self.receipts/'formal-release.json'
            # release() reads ROOT (this immutable driver), whose critical
            # modules must equal those exercised in the final development.
            released=release(manifest,self.master/'protocol/final-main-draft.json',evidence)
            if not released['ok']:raise RuntimeError('engineering gate did not pass')
            while not(self.master/'pilot-three-v1/cohort-result.json').exists():
                if time.time()>self.deadline:raise RuntimeError('older retained development did not finish before deadline')
                time.sleep(5)
            main=self.materialize('main-v1',load(self.receipts/'released-plan.json'))
            self.state('running_72_frozen_main_episodes')
            self.cohort('main-cohort',main)
            decision=self.analyze('analysis-v1',main)
            self.command('main-attribution',['/usr/bin/python3',str(main/'attribute_policy_study.py'),'--output',str(main/'attribution-v1')],study=main)
            if decision['continue_decision']=='validation_incomplete':raise RuntimeError('main episode results incomplete; no direction conclusion')
            conclusion=self.post_main(main,decision)if decision['main_quality_gate_passed']else'do_not_expand_agent_QoR_claim_use_remaining_work_for_attribution'
            save(self.receipts/'final-decision.json',{'validation_complete':True,'main_quality_gate':decision,'conclusion':conclusion,'scope':'RUDY/HPWL-RC placement proxies; no manuscript or routing claim.'})
            self.state('validation_complete',conclusion=conclusion)
        except BaseException as exc:
            self.state('validation_incomplete',error_class=type(exc).__name__,error=str(exc),direction_conclusion='none')
            raise


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--master',required=True);parser.add_argument('--package',required=True);parser.add_argument('--run-name',default='workflow-v1');parser.add_argument('--adopt-development');parser.add_argument('--development-name',default='dev-v4');parser.add_argument('--model-revalidation-name')
    args=parser.parse_args();Workflow(args.master,args.package,args.run_name,args.adopt_development,args.development_name,args.model_revalidation_name).run()
