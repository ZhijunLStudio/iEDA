"""Frozen-parent guard/batch controls; all geometry is engineering-only."""
import argparse
import copy
import json
import os
import time
from pathlib import Path
from common import ROOT, load, save, sha
from pl_backend import PlacementSession

FIXTURES = ('aes', 'salsa20_sky130_a')


def run(design, identifier):
    root=ROOT/'episodes'/identifier; root.mkdir(parents=True,exist_ok=False)
    budget=dict(next(iter(load(ROOT/'paired-plan.json')['arms'].values()))['budget'])
    budget.update(wall_seconds=3600,physical_cpu_seconds=3000,fresh_sta=24,legalizations=24)
    save(root/'episode.json',{'design':design,'budget':budget,'deadline_unix':time.time()+3600})
    actor=PlacementSession(root);checks={};arms=[]
    def call(op,**args):
        value=actor.handle({'op':op,'args':args})
        if not value['ok']:raise RuntimeError(str(value))
        return value
    try:
        fixture_root=os.environ.get('IEDA_PL_FIXTURE_ROOT')
        if not fixture_root:raise ValueError('set IEDA_PL_FIXTURE_ROOT with <design>/result.json and its original geometry/path evidence')
        path=Path(fixture_root)/design/'result.json'
        parent=copy.deepcopy(load(path));parent.update(id='fixture',snapshot='engineering-only')
        actor.legals['fixture']=parent;actor._cache_legal_paths('fixture');original=sha(parent['def']['path'])
        for guard in ('both','none'):
            for size in (1,4):
                before_STA=actor.work.fresh_sta;before_trials=actor.work.neighbor_trials
                value=call('refine',candidate_id='fixture',action={'objective':'rudy','operator':'rudy_swap','scope':'global','protect_reported_timing':True,'path_guard':'critical','wire_guard':guard,'max_moves':size,'neighbor_trials':4096},evaluation='defer')
                prefixes=value['prefix_proposal_ids']
                checks['%s_%d_prefix_count' % (guard,size)]=len(prefixes)==value['proof']['accepted_swaps']
                checks['%s_%d_no_implicit_STA' % (guard,size)]=actor.work.fresh_sta==before_STA
                checks['%s_%d_real_trials_charged' % (guard,size)]=actor.work.neighbor_trials-before_trials==value['proof']['neighbor_trials']
                evaluated=[]
                for proposal in list(dict.fromkeys(([prefixes[0]]if prefixes else[])+[value['proposal_id']])):
                    m=call('evaluate',proposal_id=proposal);evaluated.append(m)
                    checks[proposal+'_valid_native_measurement']=m['metrics']['valid']and actor.legals[m['candidate_id']]['proof']['fresh_native_RUDY_check']['ok']
                filters=call('observe',view='filters',proposal_id=value['proposal_id'])
                checks['%s_%d_addressable_filters' % (guard,size)]='search'in filters and 'diagnostics'in filters['search']
                arms.append({'guard':guard,'max_moves':size,'accepted':value['proof']['accepted_swaps'],'prefixes':prefixes,'evaluations':evaluated,'filters':filters})
        checks['immutable_parent_preserved']=sha(parent['def']['path'])==original
        checks['at_least_one_multiswap_prefix_available']=any(a['accepted']>=2 for a in arms)
        result={'ok':all(checks.values()),'design':design,'checks':checks,'arms':arms,'work':actor.work.view(),'purpose':'Engineering only; fixture geometry is never supplied to controller episodes.'}
    except BaseException as exc:
        result={'ok':False,'design':design,'checks':checks,'arms':arms,'error':type(exc).__name__+': '+str(exc)}
        raise
    finally:
        actor.close_native();actor._persist();save(root/'prefix-controls-result.json',result);print(json.dumps({'design':design,'ok':result['ok'],'checks':checks,'error':result.get('error')}),flush=True)


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--design',choices=list(FIXTURES),required=True);parser.add_argument('--id',required=True)
    args=parser.parse_args();run(args.design,args.id)
