"""Real v0.5 transaction checks. Fixtures here never count as agent results."""
import argparse,copy,json,os,shutil,time
from pathlib import Path
from common import ROOT,load,save,sha,desc
from pl_backend import PlacementSession

def run(kind,identifier):
    root=ROOT/'episodes'/identifier;root.mkdir(parents=True,exist_ok=False)
    b=dict(next(iter(load(ROOT/'paired-plan.json')['arms'].values()))['budget']);b.update(wall_seconds=900,physical_cpu_seconds=900)
    design='gcd_nangate45_a'if kind=='gcd'else'aes'
    save(root/'episode.json',{'design':design,'budget':b,'deadline_unix':time.time()+900})
    actor=PlacementSession(root);checks={};records=[]
    def call(op,**args):
        value=actor.handle({'op':op,'args':args});records.append({'op':op,'ok':value['ok']})
        save(root/'validation-progress.json',{'checks':checks,'last':records[-1]})
        if not value['ok']:raise RuntimeError(str(value))
        return value
    try:
        if kind=='gcd':
            node=call('start',**actor.baseline_recipe['start'])['snapshot']
            proposal=call('legalize',snapshot_id=node['id'],evaluation='defer')['proposal_id']
            checks['defer_does_not_run_STA']=actor.work.fresh_sta==0
            rejected=actor.handle({'op':'finish','args':{'candidate_id':proposal,'stop_reason':'targets_matched'}})
            checks['unmeasured_proposal_cannot_finish']=not rejected['ok']and not(root/'final.def').exists()
            measured=call('evaluate',proposal_id=proposal);parent=measured['candidate_id']
            checks['fresh_evaluation_produces_measured_candidate']=measured['metrics']['valid']and actor.work.fresh_sta==1
            again=call('evaluate',proposal_id=proposal)
            checks['same_fingerprint_cache_hit_no_STA']=again['cache_hit']and actor.work.fresh_sta==1 and again['candidate_id']==parent
            p=actor.proposals[proposal]['def']['path'];clone=root/'same-geometry.def';shutil.copy2(p,clone)
            a,context=actor.cache.fingerprint(actor.design,p);k,_=actor.cache.fingerprint(actor.design,clone)
            checks['same_DEF_different_proposal_path_same_fingerprint']=a==k
            sdc=root/'changed.sdc';shutil.copy2(actor.design['sdc'],sdc);variant={**actor.design,'sdc':str(sdc)}
            before,_=actor.cache.fingerprint(variant,p);sdc.write_text(sdc.read_text()+'\nset_load 0.123 [all_outputs]\n');after,_=actor.cache.fingerprint(variant,p)
            checks['measurement_input_content_change_invalidates_cache']=before!=after and actor.cache.get(after)is None
            checks['fingerprint_covers_code_kernel_libs_SDC']=all(str(Path(x).resolve())in context['assets']for x in [actor.design['sdc'],actor.design['pl_config'],actor.suite['solver']['path'],*actor.design['libs']])and any(x.endswith('/common.py')for x in context['assets'])
            value=call('refine',candidate_id=parent,action={'operator':'local_reorder','objective':'hpwl','scope':'global','protect_reported_timing':False,'max_selected_cells':8},evaluation='defer')
            checks['DP_selected_and_moved_bound_enforced']=value['proof']['selected_count']<=8 and value['proof']['changed_count']<=8 and value['proof']['outside_moved']==0
            sta=actor.work.fresh_sta;selected=call('evaluate',proposal_id=value['proposal_id'])
            checks['unchanged_DP_reuses_measured_candidate']=not value['no_change']or(selected['cache_hit']and actor.work.fresh_sta==sta)
            checks['cache_hit_delta_uses_current_proposal_parent']=selected['parent_candidate']==parent and all(selected['delta_from_parent'][k]==selected['metrics'][k]-measured['metrics'][k]for k in selected['delta_from_parent'])
            query=call('observe',candidate_id=parent,view='paths',analysis='setup',limit=1,node_limit=3)
            endpoint=query['items'][0]['endpoint'];full=actor.timing_observations[parent]['decision_paths_all'];expected=next(p for p in full if p['analysis']=='setup'and p['endpoint']==endpoint)
            page=call('observe',candidate_id=parent,view='paths',analysis='setup',endpoint=endpoint,limit=1,node_offset=3,node_limit=3)
            checks['path_nodes_are_addressable_without_STA']=query['items'][0]['nodes']==expected['nodes'][:3]and page['items'][0]['nodes']==expected['nodes'][3:6]and actor.work.fresh_sta==sta
            errors=load(Path(__file__).with_name('fixtures')/'historical-parameter-errors.json')['errors']
            outcomes=[]
            for row in errors:
                request=copy.deepcopy(row.get('request',row.get('tool_request')))
                if not request:raise ValueError('unknown historical error fixture shape '+str(list(row)))
                if request['op']=='refine':request['args']['candidate_id']=parent
                old=(actor.work.fresh_sta,actor.refinements,len(actor.proposals),actor.starts,actor.actual_steps)
                result=actor.handle(request);now=(actor.work.fresh_sta,actor.refinements,len(actor.proposals),actor.starts,actor.actual_steps)
                outcomes.append(not result['ok']and old==now)
            checks['all10_historical_errors_rejected_before_physics']=len(outcomes)==10 and all(outcomes)
            selected_parent=parent
            if not measured['assessment']['surplus']['qualified']:
                # Engineering recovery check, not a free incumbent or a
                # claim that new staging reproduces the historical DP ties.
                for density,effort in ((.5,3),(.6,4)):
                    n=call('start',steps=500,target_density=density,congestion_effort=effort)['snapshot']
                    candidate=call('legalize',snapshot_id=n['id'])
                    if candidate['assessment']['surplus']['qualified']:
                        selected_parent=candidate['candidate_id'];break
            frozen_sdc=actor.design['sdc'];actor.design={**actor.design,'sdc':str(sdc)}
            rejected_context=actor.handle({'op':'finish','args':{'candidate_id':selected_parent,'stop_reason':'evidence_stagnation'}})
            checks['changed_measurement_context_cannot_deliver_cached_candidate']=not rejected_context['ok']and not(root/'final.def').exists()
            actor.design={**actor.design,'sdc':frozen_sdc}
            delivered=call('finish',candidate_id=selected_parent,stop_reason='evidence_stagnation')
            checks['explicit_delivery_SHA_matches']=sha(root/'final.def')==delivered['def']['sha256']
        else:
            fixture_root=os.environ.get('IEDA_PL_FIXTURE_ROOT')
            if not fixture_root:raise ValueError('set IEDA_PL_FIXTURE_ROOT with aes/result.json and its original geometry/path evidence')
            fixture=load(Path(fixture_root)/'aes/result.json')
            fixture['id']='fixture';fixture['snapshot']='engineering-fixture';actor.legals['fixture']=fixture;actor._cache_legal_paths('fixture')
            original=sha(fixture['def']['path'])
            value=call('refine',candidate_id='fixture',action={'operator':'rudy_swap','objective':'rudy','scope':'global','protect_reported_timing':True,'wire_guard':'none','path_guard':'critical','max_moves':4,'neighbor_trials':4096},evaluation='defer')
            checks['swap_search_saves_atomic_prefixes']=len(value['prefix_proposal_ids'])==value['proof']['accepted_swaps']>=2
            checks['search_not_automatically_STA_evaluated']=actor.work.fresh_sta==0
            first=call('evaluate',proposal_id=value['prefix_proposal_ids'][0]);last=call('evaluate',proposal_id=value['proposal_id'])
            checks['first_prefix_qualified_final_batch_TNS_rejected']=first['assessment']['surplus']['qualified']and not last['assessment']['surplus']['qualified']and 'setup_tns_ns'in last['assessment']['surplus']['violations']
            checks['real_search_work_charged_once']=actor.work.neighbor_trials==value['proof']['neighbor_trials']
            checks['parent_and_prefix_immutable']=sha(fixture['def']['path'])==original and actor.legals[first['candidate_id']]['proof']['fresh_native_RUDY_check']['ok']
            bounded=call('refine',candidate_id=first['candidate_id'],action={'operator':'row_opt','objective':'timing','scope':'critical','protect_reported_timing':False,'max_selected_cells':64},evaluation='defer')
            checks['AES_DP_complement_frozen']=bounded['proof']['selected_count']<=64 and bounded['proof']['changed_count']<=64 and bounded['proof']['outside_moved']==0
            call('evaluate',proposal_id=bounded['proposal_id'])
        result={'ok':all(checks.values()),'kind':kind,'checks':checks,'calls':records,'budget':actor.work.view(),'purpose':'Engineering validation only; no free candidate for controller experiments'}
    except BaseException as exc:
        result={'ok':False,'kind':kind,'checks':checks,'error':type(exc).__name__+': '+str(exc),'budget':actor.work.view()}
        raise
    finally:
        actor.close_native();save(root/'validation-result.json',result);print(json.dumps({'id':identifier,**result}),flush=True)

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--kind',choices=['gcd','aes'],required=True);p.add_argument('--id',required=True);a=p.parse_args();run(a.kind,a.id)
