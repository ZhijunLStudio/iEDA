"""Connect the native-calibrated RUDY legal-swap kernel to PL transactions."""
from pathlib import Path
import numpy as np
from common import save,load,sha
from physical_observation import coordinates
from rudy_direct import RudyDirect
from surplus import assess


def direct_transaction(design,parent,node,observation,refs,args,work,remaining):
    work=Path(work);work.mkdir(parents=True,exist_ok=False)
    if args['objective']!='rudy':raise ValueError('rudy_swap objective must be rudy; RC guards are search constraints, not full timing optimization')
    if args.get('scope','global')!='global':raise ValueError('rudy_swap currently requires global scope; it selects bbox-causal endpoints, not a radius mask')
    guard=args.get('wire_guard','both')
    if guard not in ('none','cap','elmore','both'):raise ValueError('wire_guard must be none/cap/elmore/both')
    max_moves=args.get('max_moves',8);trials=args.get('neighbor_trials',4096)
    for value,lo,hi,name in [(max_moves,1,32,'max_moves'),(trials,256,32768,'neighbor_trials')]:
        if isinstance(value,bool)or not isinstance(value,int)or not lo<=value<=hi:raise ValueError(name+' outside declared integer bounds')
    if sha(parent['def']['path'])!=observation['raw_def_sha256']:raise ValueError('same-parent observation required')
    evaluation=Path(parent['metrics']['terminal']['log']['path']).parent
    model=RudyDirect(design,parent['def']['path'],observation['paths']['path'],evaluation)
    if not model.calibration['ok']:raise RuntimeError('same-parent native RUDY calibration failed; no swap executed')
    m=parent['metrics'];parent_hpwl=m['hpwl_um']
    ledger=assess(refs['ieda'],refs['ieda'],refs['inn'])['ledger']
    current={'hpwl_um':parent_hpwl,'rudy_peak':m['rudy']['rudy_utilization_max'],
             'rudy_overflow_sum':m['rudy']['rudy_overflow_util_sum']}
    # Unqualified legal parents may improve through intermediate children.
    # Their eventual delivery is still judged by the original frozen ledger.
    caps={k:max(ledger[k]['limit'],current[k])for k in current}
    bias=parent_hpwl-model.hpwl;caps['hpwl_um']-=bias
    path_guard=args.get('path_guard','critical')
    if path_guard not in ('critical','critical_and_hold','all_reported'):raise ValueError('invalid path_guard')
    protected=set(observation['protected_cells'])if args.get('protect_reported_timing',True)else set()
    if not args.get('protect_reported_timing',True) and 'path_guard'in args:raise ValueError('path_guard requires protect_reported_timing=true')
    if path_guard!='critical':
        for path_info in observation['decision_paths_all']:
            if path_guard=='all_reported' or path_info['analysis']=='hold':
                protected.update(n['instance']for n in path_info['nodes']if n.get('instance'))
    prefixes=[]
    def capture(model,index,move):
        target=work/'prefixes'/f'{index:03d}';target.mkdir(parents=True)
        publication=model.publish(target/'placement.def')
        np.save(target/'predicted_rudy.npy',model.util())
        prefixes.append({'index':index,'def_path':str(target/'placement.def'),
                         'transaction':str(target),'publication':publication,'move':move})
        save(work/'prefixes.json',prefixes)
    search=model.optimize(refs['inn'],caps,protected,max_moves=max_moves,max_trials=trials,
                          max_wall_s=max(.01,min(90,remaining-1)),wire_guard=guard,on_accept=capture)
    save(work/'prefixes.json',prefixes)
    path=work/'placement.def';publication=model.publish(path)
    np.save(work/'predicted_rudy.npy',model.util())
    before=coordinates(parent['def']['path']);after=coordinates(path)
    changed={n for n in before if before[n]!=after[n]}
    blocked=set(protected);nets=set().union(*(model.incident.get(n,set())for n in blocked))
    blocked|={p[0]for i in nets for p in model.nets[i]['pins']if p[0]}
    if changed&blocked:raise RuntimeError('reported timing net closure moved')
    proof={'ok':True,'parent_sha256':parent['def']['sha256'],'candidate_sha256':publication['candidate_sha256'],
        'selected_count':search['eligible_cells'],'changed_count':len(changed),'outside_moved':0,'reported_protected_moved':0,
        'path_guard':path_guard,'operator':'rudy_swap','objective':'native-calibrated RUDY64 balanced gap','wire_guard':guard,
        'accepted_swaps':search['accepted_count'],'neighbor_trials':search['neighbor_trials'],'search_wall_s':search['search_wall_s'],
        'native_parent_RUDY_calibration':model.calibration,'HPWL_native_pin_bias_to_independent_helper':bias,
        'semantics':'immutable legal DEF transaction, atomic equal-size paired swaps; GP checkpoints unchanged',
        'limitation':'RC mass guards and reported-path net closure are partial protection. Full fresh setup/hold measurement remains mandatory.'}
    save(work/'search.json',search);save(work/'proof.json',proof)
    return path,proof


def verify_native_grid(transaction,evaluation):
    predicted=np.load(Path(transaction)/'predicted_rudy.npy')
    actual=np.loadtxt(Path(evaluation)/'rudy_util.csv',delimiter=',')[::-1]
    error=float(np.max(np.abs(predicted-actual)))
    return {'ok':error<=2e-6,'max_abs_grid_error':error,'native_RUDY64_after_moves_reproduced':error<=2e-6}
