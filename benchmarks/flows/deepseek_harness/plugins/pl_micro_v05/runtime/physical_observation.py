"""Same-DEF timing path evidence and exact scoped movement checks."""
import re
from pathlib import Path
from common import load,save,sha,desc,init_commands,run_native,tq,timing_summary


def coordinates(path):
    text=Path(path).read_text()
    body=re.search(r'\bCOMPONENTS\s+\d+\s*;(.*?)\bEND\s+COMPONENTS',text,re.S).group(1)
    found={}
    for m in re.finditer(r'(?:^|\n)\s*-\s+(\S+)\s+(\S+)\s+(.*?);',body,re.S):
        pos=re.search(r'\+\s+(PLACED|FIXED|COVER)\s*\(\s*(-?\d+)\s+(-?\d+)\s*\)\s*(\S+)',m[3])
        if pos:found[re.sub(r'\\(.)',r'\1',m[1])]={'x':int(pos[2]),'y':int(pos[3]),'orient':pos[4],'status':pos[1],'master':m[2]}
    return found


def observe_timing(design,binary,node,work,timeout):
    work=Path(work);before=sha(node['raw_def'])
    command=f'run_timing_eval -routing_type HPWL -eval_output_path {tq(work)} -path_json {tq(work/"paths.json")} -max_path 64'
    terminal=run_native(binary,work,init_commands(design,work,Path(design['pl_config']),node['raw_def'])+[command],timeout=timeout)
    if not terminal['ok']:raise RuntimeError('timing observation failed; no path-protected action authorized')
    paths=load(work/'paths.json');summary=timing_summary(load(work/'timing_result.json'))
    if not summary['ok'] or not paths.get('hold_paths_available') or sha(node['raw_def'])!=before:
        raise RuntimeError('incomplete timing paths or source changed')
    return _path_observation(design,node,work,work/'paths.json',paths,summary,terminal,before)


def _path_observation(design,node,work,paths_file,paths,summary,terminal,before):
    protected=set();seen=set();minimum={};period=design['clock_period_ns'];decision_paths=[]
    for analysis,key in (('setup','paths'),('hold','hold_paths')):
        for path in paths.get(key,[]):
            slack=path['slack']
            nodes=[];previous=None
            for item in path.get('nodes',[]):
                pin=item['name'];name=pin.rsplit(':',1)[0] if ':'in pin else None
                if not name:continue
                arrival=item.get('arrive_time')
                nodes.append({'pin':pin,'instance':name,'net_name':item.get('net_name'),
                    'is_driver':item.get('is_driver'),'load_pf':item.get('load_pf'),
                    'slew_ns':item.get('slew_ns'),
                    'arrival_increment_ns':arrival-previous if isinstance(arrival,(int,float)) and previous is not None else None})
                if isinstance(arrival,(int,float)):previous=arrival
                seen.add(name);minimum[name]=min(minimum.get(name,float('inf')),slack)
                if slack<=max(0.01*period,0.001):protected.add(name)
            decision_paths.append({'analysis':analysis,'endpoint':path.get('endpoint'),'slack_ns':slack,
                                   'nodes':nodes})
    coords=coordinates(node['raw_def'])
    result={'ok':True,'source_snapshot':node['id'],'raw_def_sha256':before,'paths':desc(paths_file),
        'timing':summary,'reported_setup_paths':len(paths.get('paths',[])),
        'reported_hold_paths':len(paths.get('hold_paths',[])),
        'reported_cell_count':len(seen&coords.keys()),'total_placed_cell_count':len(coords),
        'protected_cell_count':len(protected&coords.keys()),'protected_cells':sorted(protected&coords.keys()),
        'unknown_cell_count':len(coords.keys()-seen),'terminal':terminal,
        'decision_paths_all':decision_paths,
        'decision_paths':[{**p,'nodes':p['nodes'][:8],'node_count':len(p['nodes'])}
                          for mode in ('setup','hold') for p in [q for q in decision_paths if q['analysis']==mode][:2]],
        'limitation':'Only reported paths are known. Unreported cells do not have certified timing slack. Final full-clock timing and envelope checks remain required.'}
    save(work/'observation.json',result);return result


def cached_timing(design,node,metrics,work):
    evidence=metrics.get('path_evidence') or {}
    expected=evidence.get('source_def_sha256')
    if not metrics.get('ok')or expected!=sha(node['raw_def']):raise ValueError('cached timing source does not match this legal DEF')
    paths_file=Path(evidence['path_json']['path'])
    if sha(paths_file)!=evidence['path_json']['sha256']:raise ValueError('immutable path evidence changed')
    paths=load(paths_file);summary=metrics['timing']
    if not summary['ok']or not paths.get('hold_paths_available'):raise ValueError('cached setup/hold paths incomplete')
    terminal={'ok':True,'cached':True,'wall_s':0,'no_native_execution':True,
              'source_evaluation_log':metrics['terminal']['log']}
    result=_path_observation(design,node,Path(work),paths_file,paths,summary,terminal,expected)
    result['captured_with_legal_evaluation']=True
    save(Path(work)/'observation.json',result)
    return result


def compact(observation):
    return {k:v for k,v in observation.items() if k not in ('protected_cells','terminal','decision_paths_all','paths')}


def protected_scope(node,observation,index,radius,max_cells=200):
    if observation['raw_def_sha256']!=sha(node['raw_def']):raise ValueError('timing observation is stale')
    hot=node['hotspots'][index];llx,lly,urx,ury=node['rudy_region'];nx,ny=node['rudy_grid']
    bounds=[llx+max(0,hot['bin_x']-radius)*(urx-llx)/nx,lly+max(0,hot['bin_y']-radius)*(ury-lly)/ny,
        llx+min(nx,hot['bin_x']+radius+1)*(urx-llx)/nx,lly+min(ny,hot['bin_y']+radius+1)*(ury-lly)/ny]
    coords=coordinates(node['raw_def']);blocked=set(observation['protected_cells']);cx,cy=hot['center_dbu']
    candidates=sorted((abs(c['x']-cx)+abs(c['y']-cy),name)for name,c in coords.items()
        if name not in blocked and c['status']=='PLACED' and bounds[0]<=c['x']<=bounds[2] and bounds[1]<=c['y']<=bounds[3])
    names=[name for _,name in candidates[:max_cells]]
    if not names:raise ValueError('no eligible cells in this hotspot; protected reported paths are excluded')
    return names,{'hotspot_index':index,'radius_bins':radius,'bounds_dbu':bounds,'target_count':len(names),
        'protected_reported_cells':len(blocked),'not_certified_timing_safe':True,'scope_preserve_global_charge':True}


def movement(parent,child,names,observation):
    a,b=coordinates(parent['raw_def']),coordinates(child['raw_def']);target=set(names)
    changed=[name for name in a if a[name]!=b.get(name)]
    outside=sorted(set(changed)-target);protected=sorted(set(changed)&set(observation['protected_cells']))
    return {'same_cell_names':a.keys()==b.keys(),'changed_count':len(changed),'target_changed_count':len(set(changed)&target),
        'outside_changed_count':len(outside),'protected_changed_count':len(protected),
        'outside_changed_sample':outside[:8],'protected_changed_sample':protected[:8],
        'ok':a.keys()==b.keys() and not outside and not protected,
        'note':'This checks raw GP writes only. Subsequent LG/DP can move other cells; final full timing is mandatory.'}
