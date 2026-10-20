"""All-case original-DEF baseline reproduction under the v0.5 actor."""
import argparse,json,time
from common import ROOT,load,save,sha
from pl_backend import PlacementSession,scalar_metrics
from surplus import AXES

def run(design,identifier):
    root=ROOT/'episodes'/identifier;root.mkdir(parents=True,exist_ok=False)
    budget=dict(next(iter(load(ROOT/'paired-plan.json')['arms'].values()))['budget'])
    save(root/'episode.json',{'design':design,'budget':budget,'deadline_unix':time.time()+budget['wall_seconds']})
    actor=PlacementSession(root);result={'ok':False,'design':design};start=time.monotonic()
    def call(op,**args):
        value=actor.handle({'op':op,'args':args})
        if not value['ok']:raise RuntimeError(str(value))
        return value
    try:
        recipe=actor.baseline_recipe
        node=call('start',**recipe['start'])['snapshot']
        while node['can_advance']and node['iteration']<recipe['max_gp_iterations']:
            node=call('advance',snapshot_id=node['id'],**recipe['advance'])['snapshot']
        value=call('legalize',snapshot_id=node['id'],run_dp=True)
        expected=scalar_metrics(load(ROOT/'references'/design/'ieda/attempt-1/result.json'))
        differences={k:value['metrics'][k]-expected[k]for k in AXES}
        checks={'same_original_input':sha(actor.design['input_def'])==actor.decision_memory[design]['input_sha256'],'full_measurement_valid':value['metrics']['valid'],'all7_original_metrics_reproduced':all(abs(v)<=1e-6 for v in differences.values()),'paths_cached_in_same_STA':value['assessment']['timing_evidence_ready']and actor.work.fresh_sta==1}
        result={'ok':all(checks.values()),'design':design,'checks':checks,'differences':differences,'metrics':value['metrics'],'snapshot':node,'candidate_id':value['candidate_id'],'work':actor.work.view()}
    except Exception as exc:result['error']=type(exc).__name__+': '+str(exc)
    finally:
        actor.close_native();actor._persist();result['wall_s']=time.monotonic()-start;save(root/'baseline-result.json',result)
    print(json.dumps({'design':design,'ok':result['ok'],'wall_s':result['wall_s'],'error':result.get('error')}),flush=True)
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--design',required=True);p.add_argument('--id',required=True);a=p.parse_args();run(a.design,a.id)
