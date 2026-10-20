#!/usr/bin/env python3
"""Independent fresh evaluation of delivered files; no feedback to controllers."""
import argparse
import concurrent.futures
import json
import math
import subprocess
import time
from common import ROOT,SUITE,load,save,sha,desc,measure
from pl_backend import scalar_metrics

def audit(identifier):
    episode=ROOT/'episodes'/identifier; result=load(episode/'result.json'); target=ROOT/'audits'/identifier
    target.mkdir(parents=True,exist_ok=False); started=time.monotonic();delivery=result.get('delivery')
    checks={'episode_passed':result['ok'],'owned_survivors_empty':not result.get('owned_survivors'),
            'ownership_errors_empty':not result.get('ownership_errors'), 'ownership_parse_errors_empty':not result.get('parse_errors')}
    measured=None;differences={}
    if delivery:
        selected=load(episode/'legal-candidates'/delivery['candidate_id']/'result.json')
        checks['selected_candidate_passed']=bool(selected['ok'])
        checks['delivery_matches_measured_candidate']=sha(episode/'final.def')==delivery['def']['sha256']==selected['def']['sha256']==sha(selected['def']['path'])
        measured=measure(load(SUITE)['designs'][result['design']],episode/'final.def',target/'evaluation',timeout=600)
        fresh=scalar_metrics(measured)
        checks['fresh_measurement_valid']=fresh['valid']
        for key,value in delivery['metrics'].items():
            if key=='valid':continue
            actual=fresh.get(key)
            if actual is None or not math.isclose(value,actual,rel_tol=1e-10,abs_tol=1e-6):
                differences[key]={'original':value,'fresh':actual}
        checks['fresh_metrics_reproduce']=not differences
    else:checks['actual_delivery']=False
    traces=episode/'traces/events.jsonl'
    if traces.exists():
        events=[json.loads(s)for s in traces.read_text().splitlines()if s.strip()]
        calls=[e for e in events if e.get('type')=='tool_call']
        checks['real_domain_calls_only']=all(e.get('tool','').startswith('pl_')for e in calls)
        checks['real_model_finish_called']=any(e.get('tool')=='pl_finish'for e in calls)
    value={'id':identifier,'ok':all(checks.values()),'checks':checks,'result':desc(episode/'result.json'),
           'fresh':measured,'metric_differences':differences,'audit_wall_s':time.monotonic()-started,
           'cost_note':'Independent post-delivery audit outside controller budget; never shown to model/search and cannot change delivered choice.'}
    save(target/'result.json',value);print(json.dumps({'id':identifier,'audit_ok':value['ok'],'checks':checks}),flush=True)

def watch(planfile):
    plan=load(planfile);entries=plan['agent']+(plan['rule']if not plan.get('reuse_rules_from')else[])+plan.get('stage_rule',[]);remaining={e['id']for e in entries};results={};active={}
    deadline=time.monotonic()+23400
    def worker(identifier):
        log=ROOT/'cohort-logs'/f'audit-{identifier}.log'
        with log.open('xb')as f:p=subprocess.run(['/usr/bin/python3',str(ROOT/'audit_cohort.py'),'--id',identifier],cwd=ROOT,stdout=f,stderr=subprocess.STDOUT)
        path=ROOT/'audits'/identifier/'result.json'
        return {'returncode':p.returncode,'ok':load(path)['ok']if path.exists()else False,'result':desc(path)if path.exists()else None,'log':desc(log)}
    with concurrent.futures.ThreadPoolExecutor(max_workers=4)as pool:
        while remaining or active:
            for identifier in sorted(remaining):
                if (ROOT/'episodes'/identifier/'result.json').exists():active[pool.submit(worker,identifier)]=identifier;remaining.remove(identifier)
            for future in list(active):
                if future.done():
                    identifier=active.pop(future);results[identifier]=future.result()
                    save(ROOT/'audit-cohort-progress.json',{'results':results,'waiting_for':sorted(remaining),'active':list(active.values()),'plan':desc(planfile)})
                    print(json.dumps({'id':identifier,**results[identifier]}),flush=True)
            if time.monotonic()>deadline:raise RuntimeError('audit watcher deadline; pending episodes retained')
            time.sleep(.5)

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--id');p.add_argument('--watch-plan');a=p.parse_args()
    if a.id:audit(a.id)
    elif a.watch_plan:watch(a.watch_plan)
    else:p.error('one of --id or --watch-plan required')
