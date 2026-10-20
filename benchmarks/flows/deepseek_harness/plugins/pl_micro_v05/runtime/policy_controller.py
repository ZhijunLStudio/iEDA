"""Three deterministic policies on the same domain actor, menu and frozen prior."""
import argparse,json,time
from pathlib import Path
from common import ROOT,load,save,desc,sha
from pl_backend import PlacementSession
from policy_menu import shared_menu

def run(identifier):
    plan=load(ROOT/'paired-plan.json');entry=next(e for e in plan['rule']if e['id']==identifier)
    if plan.get('study_phase','formal')=='formal':
        gate=plan.get('gate_evidence',{})
        if plan.get('formal_gate')!='open'or not gate or desc(gate['path'])['sha256']!=gate['sha256']or not load(gate['path']).get('ok'):raise RuntimeError('formal release gate closed')
    root=ROOT/'episodes'/identifier;root.mkdir(parents=True,exist_ok=False)
    budget=dict(plan['arms'][entry['arm']]['budget']);started=time.monotonic()
    save(root/'episode.json',{'design':entry['design'],'budget':budget,'deadline_unix':time.time()+budget['wall_seconds']})
    actor=PlacementSession(root);mode=entry['controller'];error=None;failures=[];events=[];baseline_node=None
    save(root/'episode-started.json',{'controller':mode,'model':None,'sources':[desc(p)for p in Path(__file__).parent.glob('*.py')],'suite':desc(ROOT/'suite.json'),'plan':desc(ROOT/'paired-plan.json')})
    def call(op,**args):
        value=actor.handle({'op':op,'args':args});events.append({'op':op,'ok':value['ok']})
        if not value['ok']:raise RuntimeError(value.get('message','domain failure'))
        return value
    def alive():
        b=actor._budget_view()
        return actor._remaining()>budget['finalization_reserve_s']+30 and b['physical_cpu_s']<budget['physical_cpu_seconds']-10 and b['fresh_sta_used']<budget['fresh_sta']and actor.calls<budget['tool_calls']-4
    def candidates(view,qualified=True):
        return sorted([c for c in view['legal_candidates']if c.get('valid')and c.get('inn_positive_gaps')and(not qualified or c.get('surplus',{}).get('qualified'))],key=lambda c:(c['inn_positive_gaps']['worst'],c['inn_positive_gaps']['sum'],c['id']))
    batch=8 if mode=='coarse'else 1;streak=0;guard_index=0;dp_index=0
    try:
        first=call('observe');menu=shared_menu(first['experiment_memory'],first['baseline_reproduction_recipe']);save(root/'shared-menu.json',menu)
        seen=set();floor=.4;early=None
        for recipe in menu['GP_portfolio']:
            if not alive()or actor.starts>=budget['starts']:break
            density=recipe['density'] if recipe.get('baseline')else max(recipe['density'],floor)
            key=(round(density,6),recipe['feedback'],recipe['timing'],recipe['overflow_target'])
            if key in seen:continue
            seen.add(key)
            try:
                steps=100 if mode=='fine'else 500
                node=call('start',steps=steps,target_density=density,target_overflow=recipe['overflow_target'],congestion_effort=recipe['feedback'],timing=recipe['timing'])['snapshot']
                # An ordinary high requested density is not a physical floor.
                # Raise the floor only when native utilization actually forces
                # the effective density above this request.
                if node['effective_density']>density+1e-6:floor=max(floor,node['effective_density'])
                seen.add((round(node['effective_density'],6),recipe['feedback'],recipe['timing'],recipe['overflow_target']))
                if recipe.get('baseline')and node['can_advance']:early=node
                while node['can_advance']and node['iteration']<recipe['checkpoint_iteration']and alive():
                    # Baseline has fixed termination semantics in all arms.
                    if mode=='adaptive'and not recipe.get('baseline'):
                        steps=100 if node['overflow']<=2*node['overflow_target']else 500
                    if mode=='fine'and not recipe.get('baseline'):
                        call('legalize',snapshot_id=node['id'],run_dp=recipe['run_dp'])
                        if not alive():break
                    node=call('advance',snapshot_id=node['id'],steps=steps,scope='global',congestion_effort=recipe['feedback'])['snapshot']
                    if recipe.get('baseline')and node['can_advance']:early=node
                call('legalize',snapshot_id=node['id'],run_dp=recipe['run_dp'])
                if recipe.get('baseline'):baseline_node=node
            except RuntimeError as exc:failures.append({'phase':'GP','error':str(exc)})
            view=call('observe')
            if any(c.get('Inn_targets_matched_within_engineering_epsilon')for c in candidates(view)):break
        view=call('observe')
        if not any(c.get('Inn_targets_matched_within_engineering_epsilon')for c in candidates(view)):
            prefix=baseline_node if baseline_node and baseline_node['can_advance']else early
            if prefix and prefix['can_advance']:
                late_seen=set()
                for action in menu['late_feedback']:
                    if not alive()or actor.work.fresh_sta>=min(10,budget['fresh_sta']):break
                    try:
                        action=dict(action)
                        if mode!='adaptive':action['steps']=500 if mode=='coarse'else 100
                        key=(action['steps'],action['congestion_effort'])
                        if key in late_seen:continue
                        late_seen.add(key)
                        node=call('advance',snapshot_id=prefix['id'],**action)['snapshot']
                        call('legalize',snapshot_id=node['id'],run_dp=True)
                    except RuntimeError as exc:failures.append({'phase':'late_feedback','error':str(exc)})
        tried=set()
        while alive():
            view=call('observe');valid=candidates(view)
            if not valid:break
            parent=valid[0]
            if parent.get('Inn_targets_matched_within_engineering_epsilon'):break
            # Same finite union menu in every rule. Grain changes independently.
            actions=menu['direct_actions']+menu['DP_actions']
            selected=None
            for index in range(len(actions)):
                k=(dp_index+index)%len(actions);action=dict(actions[k])
                if action['operator']=='rudy_swap':action['max_moves']=batch
                elif mode!='coarse':action['max_selected_cells']=64 if mode=='fine'else(64 if batch<4 else 256)
                signature=(parent['id'],json.dumps(action,sort_keys=True))
                if signature not in tried:selected=(k,action,signature);break
            if selected is None:break
            k,action,signature=selected;tried.add(signature);dp_index=(k+1)%len(actions)
            try:
                value=call('refine',candidate_id=parent['id'],action=action,evaluation='immediate')
                child=value['assessment'];qualified=child['surplus']['qualified']
                before=(parent['inn_positive_gaps']['worst'],parent['inn_positive_gaps']['sum'])
                after=(child['inn_positive_gaps']['worst'],child['inn_positive_gaps']['sum'])
                if mode=='adaptive':
                    streak=streak+1 if qualified and after<before else 0
                    if streak>=2:batch=min(8,batch*2);streak=0
                    if not qualified:batch=max(1,batch//2)
                    if value.get('no_change'):guard_index=(guard_index+1)%4;dp_index=guard_index
                if not qualified:
                    repair_parent=value['candidate_id']
                    for operator in ('row_opt','local_reorder'):
                        if not alive():break
                        repair={'operator':operator,'objective':'timing','scope':'critical','protect_reported_timing':False,'strength':4}
                        if mode!='coarse':repair['max_selected_cells']=64 if mode=='fine'else 256
                        repaired=call('refine',candidate_id=repair_parent,action=repair)
                        repair_parent=repaired['candidate_id']
                        if repaired['assessment']['surplus']['qualified']:break
            except RuntimeError as exc:failures.append({'phase':'refine','error':str(exc)})
        view=call('observe');valid=candidates(view)
        if not valid:raise RuntimeError('no measured qualified safety incumbent')
        reason='targets_matched'if valid[0].get('Inn_targets_matched_within_engineering_epsilon')else'time_reserve'if actor._remaining()<=budget['finalization_reserve_s']+30 else'quota_exhausted'if not alive()else'evidence_stagnation'
        call('finish',candidate_id=valid[0]['id'],stop_reason=reason)
    except Exception as exc:error=type(exc).__name__+': '+str(exc)
    finally:actor.close_native();actor._persist()
    survivors=[]
    for file in root.rglob('native-started.json'):
        identity=load(file).get('identity')
        if not identity:continue
        try:
            text=Path('/proc',str(identity['pid']),'stat').read_text();fields=text[text.rfind(')')+2:].split()
            if int(fields[19])==identity['start_ticks']and fields[0]!='Z':survivors.append(identity)
        except (OSError,ValueError,IndexError):pass
    delivery=load(root/'delivery.json')if(root/'delivery.json').exists()else None;work=actor.work.view()
    checks={'no_owned_survivors':not survivors,'actual_delivery':bool(delivery),'delivery_SHA_matches':bool(delivery and sha(root/'final.def')==delivery['def']['sha256']),'within_wall':time.monotonic()-started<=budget['wall_seconds'],'within_CPU':work['physical_cpu_s']<=budget['physical_cpu_seconds'],'within_STA':work['fresh_sta_used']<=budget['fresh_sta'],'within_neighbor_trials':work['neighbor_trials_used']<=budget['neighbor_trials'],'within_GP_steps':actor.actual_steps<=budget['actual_gp_steps']}
    result={'ok':error is None and all(checks.values()),'checks':checks,'episode_id':identifier,'design':entry['design'],'controller':mode,'model':None,'error':error,'delivery':delivery,'wall_s':time.monotonic()-started,'work':work,'branch_failures':failures,'tool_call_count':actor.calls,'tool_error_count':len(actor.errors),'model_request_count':0,'owned_survivors':survivors,'ownership_errors':[],'parse_errors':[]}
    save(root/'result.json',result);print(json.dumps({'id':identifier,'ok':result['ok'],'error':error,'wall_s':result['wall_s'],'work':work}),flush=True)
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--id',required=True);a=p.parse_args();run(a.id)
