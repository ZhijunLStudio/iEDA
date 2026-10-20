"""Continuable legal DP transactions and compact, actionable physical evidence.

No reference coordinates are read. Every proposal has a legal parent, immutable
input, explicit objective, native activation proof and independent evaluation.
Weights are search heuristics, never claims of final congestion/timing benefit.
"""
import math
import re
from pathlib import Path
from common import load, save, sha, tq, init_commands, run_native
from physical_observation import coordinates


def component_blocks(text):
    section = re.search(r'\bCOMPONENTS\s+(\d+)\s*;(.*?)\bEND\s+COMPONENTS', text, re.S)
    if not section:
        raise ValueError('missing COMPONENTS')
    entries = {}
    for match in re.finditer(r'(?:^|\n)\s*-\s+(\S+)\s+(\S+)\s+(.*?);', section[2], re.S):
        pos = re.search(r'\+\s+(PLACED|FIXED|COVER)\s*\(\s*(-?\d+)\s+(-?\d+)\s*\)\s*(\S+)', match[3])
        if not pos:
            raise ValueError('all input components must already be placed')
        name = re.sub(r'\\(.)', r'\1', match[1])
        offset = section.start(2) + match.start(3)
        entries[name] = (offset + pos.start(), offset + pos.end())
    if len(entries) != int(section[1]):
        raise ValueError('component count mismatch')
    return entries


def rewrite(text, changes):
    # Repeated whole-DEF slicing costs O(len(text) * len(changes)). A full
    # row optimization can publish tens of thousands of edits after native
    # execution has stopped, so that cost can also overrun the CPU reserve.
    # Component spans are disjoint offsets in the original immutable DEF.
    import work_budget
    pieces = []
    cursor = 0
    for index, (begin, end, value) in enumerate(sorted(changes)):
        if work_budget.ACTIVE and index % 64 == 0:
            work_budget.ACTIVE.check()
        if not 0 <= cursor <= begin <= end <= len(text):
            raise ValueError('DEF replacement spans must be ordered, disjoint and within the original text')
        pieces.extend((text[cursor:begin], value))
        cursor = end
    pieces.append(text[cursor:])
    if work_budget.ACTIVE:
        work_budget.ACTIVE.check()
    return ''.join(pieces)


def net_geometry(path, macros, hp):
    text = Path(path).read_text()
    cells = coordinates(path)
    units = int(re.search(r'UNITS\s+DISTANCE\s+MICRONS\s+(\d+)', text)[1])
    ports = hp.parse_ports(text)
    section = re.search(r'(?:^|\n)NETS\s+\d+\s*;(.*?)\bEND NETS', text, re.S)
    if not section:
        raise ValueError('missing NETS')
    nets = []
    for match in re.finditer(r'(?:^|\n)\s*-\s+(\S+)\s+(.*?);', section[1], re.S):
        points, names = [], set()
        # Original frozen DEFs have unrouted connectivity. Stop at properties.
        body = match[2].split('+', 1)[0]
        for inst, pin in re.findall(r'\(\s*([^\s()]+)\s+([^\s()]+)\s*\)', body):
            inst, pin = hp.def_name(inst), hp.def_name(pin)
            if inst == 'PIN':
                point = ports.get(pin)
            else:
                c = cells[inst]; macro = macros[hp.def_name(c['master'])]
                px, py = macro['pins'][pin]
                qx, qy = hp.transform_pin(px, py, *macro['size'], c['orient'])
                point = (c['x'] + qx * units, c['y'] + qy * units)
                names.add(inst)
            if point is None:
                raise ValueError('missing physical pin')
            points.append(point)
        if len(points) < 2:
            continue
        xs, ys = zip(*points)
        bbox = [min(xs), min(ys), max(xs), max(ys)]
        nets.append({'name': hp.def_name(match[1]), 'cells': sorted(names),
                     'bbox_dbu': bbox, 'hpwl_dbu': bbox[2]-bbox[0]+bbox[3]-bbox[1],
                     'pins': len(points)})
    measured, _, missing, _ = hp.parse_def(Path(path), macros)
    if missing or abs(sum(n['hpwl_dbu'] for n in nets)-measured) > 1.01:
        raise ValueError('physical topology does not reproduce independent HPWL')
    return nets


def physical_evidence(node, nets, timing=None):
    llx, lly, urx, ury = node['rudy_region']; nx, ny = node['rudy_grid']
    dx, dy = (urx-llx)/nx, (ury-lly)/ny
    regions = []
    for hot in node['hotspots']:
        x, y = hot['center_dbu']
        scored = []
        for net in nets:
            a,b,c,d = net['bbox_dbu']
            if a-dx/2 <= x <= c+dx/2 and b-dy/2 <= y <= d+dy/2:
                # Approximate bbox density, used for attribution only. Actual
                # RUDY64 remains the native evaluator's full measurement.
                score = net['hpwl_dbu']/max(c-a,dx)/max(d-b,dy)
                scored.append((score, net['name'], net))
        scored.sort(key=lambda v:(-v[0],v[1]))
        regions.append({**hot, 'contributor_proxy':'bbox HPWL / bin-clamped bbox area; not routed demand',
            'top_nets':[{'name':n['name'],'bbox_dbu':n['bbox_dbu'], 'pins':n['pins'],
                         'cells_sample':n['cells'][:3], 'cells_total':len(n['cells'])} for _,_,n in scored[:3]]})
    return {'hotspot_topology':regions[:2],
            'critical_paths':timing.get('decision_paths',[]) if timing else [],
            'topology_complete_for_hpwl':True}


def refinement(design, binary, parent, node, observation, nets, args, work, timeout):
    work = Path(work); work.mkdir(parents=True, exist_ok=False)
    original = Path(parent).read_text(); digest = sha(parent)
    cells = coordinates(parent); movable = {n for n,c in cells.items() if c['status']=='PLACED'}
    objective = args['objective']; scope = args.get('scope','hotspot')
    operator = args.get('operator','local_reorder'); strength = args.get('strength',4)
    protected = set(observation['protected_cells']) if args.get('protect_reported_timing',True) else set()
    critical_nets = {n['net_name'] for p in observation['decision_paths_all'] for n in p['nodes'] if n.get('net_name')}
    critical_cells = {n['instance'] for p in observation['decision_paths_all'] for n in p['nodes'] if n.get('instance')}
    if scope=='global':
        selected = movable - protected
        selected_nets = nets
    elif scope=='critical':
        selected_nets = [n for n in nets if n['name'] in critical_nets]
        selected = (critical_cells | {c for n in selected_nets for c in n['cells']}) & movable - protected
    else:
        hot = node['hotspots'][args.get('hotspot_index',0)]; radius=args.get('radius_bins',4)
        llx,lly,urx,ury=node['rudy_region'];nx,ny=node['rudy_grid']
        dx,dy=(urx-llx)/nx,(ury-lly)/ny;cx,cy=hot['center_dbu']
        box=[cx-(radius+.5)*dx,cy-(radius+.5)*dy,cx+(radius+.5)*dx,cy+(radius+.5)*dy]
        selected_nets=[n for n in nets if n['bbox_dbu'][0]<=box[2] and n['bbox_dbu'][2]>=box[0]
                       and n['bbox_dbu'][1]<=box[3] and n['bbox_dbu'][3]>=box[1]]
        # Connected nets and nearby cells, ranked by physical distance. Bound
        # scope size explicitly; never claim the whole connected net is movable.
        incident={c for n in selected_nets for c in n['cells']}
        eligible=(incident & movable)-protected
        selected=set(sorted(eligible,key=lambda n:(abs(cells[n]['x']-cx)+abs(cells[n]['y']-cy),n))[:400])
    if not selected:
        raise ValueError('no eligible legal cells; choose another region or explicit timing-risk policy')
    cap=args.get('max_selected_cells')
    if cap is not None:
        if isinstance(cap,bool) or not isinstance(cap,int) or cap<1 or cap>len(cells):
            raise ValueError('max_selected_cells must be a positive integer within the design cell count')
        if scope=='hotspot':
            rank=lambda n:(abs(cells[n]['x']-cx)+abs(cells[n]['y']-cy),n)
        else:
            # Stable order by the worst reported path; unknown cells last.
            slacks={}
            for path in observation['decision_paths_all']:
                for item in path['nodes']:
                    n=item.get('instance')
                    if n:slacks[n]=min(slacks.get(n,float('inf')),path['slack_ns'])
            rank=lambda n:(slacks.get(n,float('inf')),n)
        selected=set(sorted(selected,key=rank)[:cap])
    blocks=component_blocks(original)
    masked=rewrite(original,[(a,b,f"+ FIXED ( {cells[n]['x']} {cells[n]['y']} ) {cells[n]['orient']}")
                            for n,(a,b) in blocks.items() if n in movable-selected])
    (work/'masked.def').write_text(masked)
    config=load(design['pl_config']);config['PL']['num_threads']=1
    dp=config['PL']['DP']; dp['enable_networkflow']=0
    for key in ('row_opt','instance_swap','local_reorder','bin_opt'):dp['enable_'+key]=int(operator in (key,'all'))
    dp['local_reorder_max_window']=3;dp['local_reorder_budget']=5000
    save(work/'pl_config.json',config)
    weights={}
    if objective in ('rudy','balanced'):
        for net in selected_nets:
            a,b,c,d=net['bbox_dbu']; level=0.
            for hot in node['hotspots']:
                x,y=hot['center_dbu']
                if a<=x<=c and b<=y<=d:level=max(level,hot['utilization'])
            if level>1:weights[net['name']]=1+min(strength,max(1,math.ceil(strength*(level-1)/max(node['rudy_peak']-1,1e-9))))
    if objective in ('timing','balanced'):
        for n in critical_nets:weights[n]=max(weights.get(n,1),1+strength)
    command='placer_run_dp'
    if weights:
        save(work/'weights.json',{'schema_version':1,'net_weights':weights})
        command+=' -route_weights '+tq(work/'weights.json')
    terminal=run_native(binary,work/'native',init_commands(design,work/'native',work/'pl_config.json',work/'masked.def')+
                        [command,f'def_save -path {tq(work/"native.def")}'],timeout=timeout)
    if not terminal['ok']:raise RuntimeError('native legal DP transaction failed')
    stage=load(work/'native/pl/report/ipl_stage_report.json')
    detail=stage.get('detail_placement',{})
    if not all(detail.get(k)is True for k in ('completed','execution_success','legal')) or any(stage.get(k,{}).get('entered') for k in ('global_placement','legalization')):
        raise RuntimeError('DP-only legal activation proof missing')
    exhibits=[load_json(x) for x in detail.get('exhibit',[])]
    if weights and not any(x.get('operator')=='route_weighted_objective' and x.get('completed')is True and x.get('weighted_net_count')==len(weights) for x in exhibits):
        raise RuntimeError('requested net objective not activated')
    after=coordinates(work/'native.def')
    if cells.keys()!=after.keys() or any(cells[n]['master']!=after[n]['master'] for n in cells):raise RuntimeError('native changed component identity')
    outside=[n for n in cells.keys()-selected if any(cells[n][k]!=after[n][k] for k in ('x','y','orient'))]
    if outside:raise RuntimeError('native DP moved frozen complement')
    edits=[];changed=[]
    for n in sorted(selected):
        c=after[n]
        if c['status']!='PLACED':raise RuntimeError('native changed selected cell status')
        if any(cells[n][k]!=c[k] for k in ('x','y','orient')):
            a,b=blocks[n];edits.append((a,b,f"+ PLACED ( {c['x']} {c['y']} ) {c['orient']}"));changed.append(n)
    candidate=work/'placement.def';candidate.write_text(rewrite(original,edits))
    if sha(parent)!=digest:raise RuntimeError('immutable legal parent changed')
    proof={'ok':True,'parent_sha256':digest,'candidate_sha256':sha(candidate),'selected_cells':sorted(selected),
        'selected_count':len(selected),'changed_count':len(changed),'protected_count':len(protected),
        'outside_moved':0,'reported_protected_moved':len(set(changed)&protected),'operator':operator,
        'objective':objective,'weighted_net_count':len(weights),'native':terminal,'native_stage':detail,
        'semantics':'continuable legal DEF transaction; GP optimizer state is not reset or altered',
        'limitation':'Partial reported-path exclusion is not a timing certificate. Integer weighted HPWL is a search cost, not exact RUDY or STA.'}
    units=int(re.search(r'UNITS\s+DISTANCE\s+MICRONS\s+(\d+)',original)[1])
    proof['max_displacement_um']=max((abs(after[n]['x']-cells[n]['x'])+abs(after[n]['y']-cells[n]['y']))/units for n in changed) if changed else 0.0
    proof['max_selected_cells']=cap
    save(work/'proof.json',proof)
    return candidate,proof


def load_json(value):
    import json
    return json.loads(value) if isinstance(value,str) else value
