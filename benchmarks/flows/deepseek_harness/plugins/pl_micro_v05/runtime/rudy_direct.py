"""Direct RUDY64 legal-swap research kernel, gated on native calibration.

Uses native exported pin coordinates, original track supply, and the actual
calRUDY overlap equations. All final quality remains independently measured.
"""
import math,re,sys
from pathlib import Path
import numpy as np
from common import ROOT,load,save,sha
from physical_observation import coordinates
sys.path.insert(0,str(ROOT/'helpers'))
import def_hpwl_eval as hp


def untransform(x,y,w,h,orient):
    return {'N':lambda:(x,y),'S':lambda:(w-x,h-y),'FN':lambda:(w-x,y),
            'FS':lambda:(x,h-y),'W':lambda:(y,h-x),'E':lambda:(w-y,x),
            'FW':lambda:(w-y,h-x),'FE':lambda:(y,x)}[orient]()


class RudyDirect:
    def __init__(self,design,parent,path_json,evaluation):
        self.design=design;self.parent=Path(parent);self.digest=sha(parent)
        self.text=self.parent.read_text();self.cells=coordinates(parent)
        self.units=int(re.search(r'UNITS\s+DISTANCE\s+MICRONS\s+(\d+)',self.text)[1])
        self.macros,_=hp.parse_lef(Path(design['macro_lef']))
        data=load(path_json);geometry=data['hpwl_rc_geometry']
        if geometry['micron_dbu']!=self.units:raise ValueError('native geometry units differ')
        summary=load(Path(evaluation)/'congestion_result.json')
        self.region=summary['region'];self.nx=summary['bin_cnt_x'];self.ny=summary['bin_cnt_y']
        if (self.nx,self.ny)!=(64,64):raise ValueError('RUDY64 required')
        lx,ly,ux,uy=self.region;self.dx=(ux-lx)/self.nx;self.dy=(uy-ly)/self.ny
        directions={}
        tech=Path(design['tech_lef']).read_text()
        for match in re.finditer(r'(?m)^\s*LAYER\s+(\S+)\s*\n(.*?)^\s*END\s+\1\s*$',tech,re.S):
            direction=re.search(r'DIRECTION\s+(HORIZONTAL|VERTICAL)',match[2])
            if direction and re.search(r'TYPE\s+ROUTING',match[2]):directions[match[1]]=direction[1]
        counts={}
        for match in re.finditer(r'TRACKS\s+([XY])\s+\S+\s+DO\s+(\d+)\s+STEP\s+\S+\s+LAYER\s+([^;]+);',self.text):
            for layer in match[3].split():
                if directions.get(layer)==('HORIZONTAL'if match[1]=='Y'else'VERTICAL'):counts[layer]=int(match[2])
        ch=sum(v for k,v in counts.items()if directions[k]=='HORIZONTAL')
        cv=sum(v for k,v in counts.items()if directions[k]=='VERTICAL')
        if min(ch,cv)<=0:raise ValueError('native preferred track supply unavailable')
        self.scales=((uy-ly)/ch*4,(ux-lx)/cv*4)
        self.nets=[];self.incident={};self.boxes=[]
        ports=hp.parse_ports(self.text)
        for record in geometry['nets']:
            if not record.get('complete')or record.get('driver_dbu')is None:raise ValueError('complete native pin geometry required')
            entries=[(record['driver'],record['driver_dbu'])]+[(p['name'],p['dbu'])for p in record['loads']]
            pins=[];rc_constants=[];idx=len(self.nets)
            for name,point in entries:
                instance=name.rsplit(':',1)[0]if ':'in name else None
                cell=self.cells.get(instance)
                rc_constants.append(None if cell else tuple(point))
                if cell:
                    macro=self.macros[hp.def_name(cell['master'])];w,h=(round(v*self.units)for v in macro['size'])
                    local=untransform(point[0]-cell['x'],point[1]-cell['y'],w,h,cell['orient'])
                    pins.append((instance,tuple(point),local,(w,h)))
                    self.incident.setdefault(instance,set()).add(idx)
                else:
                    # STA export uses IO placement origins; native RUDY uses
                    # physical IO shape averages. Restore the latter from DEF.
                    physical=ports.get(hp.def_name(name),point)
                    pins.append((None,tuple(round(v)for v in physical),None,None))
            self.nets.append({'name':record['name'],'pins':pins,'rc_constants':rc_constants,
                'cap_slope':record['wire_cap_pf_per_um'],'res_slope':record['wire_res_ohm_per_um']})
            self.boxes.append(self.bbox(pins,{}))
        self.h=np.zeros((64,64));self.v=np.zeros((64,64))
        for box in self.boxes:
            sl,h,v=self.contribution(box);self.h[sl]+=h;self.v[sl]+=v
        self.hpwl=sum((b[2]-b[0])+(b[3]-b[1])for b in self.boxes)/self.units
        self.original_hpwl=self.hpwl
        actual=np.loadtxt(Path(evaluation)/'rudy_util.csv',delimiter=',')[::-1]
        predicted=self.util()
        self.calibration={'max_abs_grid_error':float(np.max(np.abs(actual-predicted))),
            'peak_error':float(np.max(predicted)-summary['rudy_utilization_max']),
            'overflow_sum_error':float(np.maximum(predicted-1,0).sum()-summary['rudy_overflow_util_sum']),
            'native_pin_nets':len(self.nets),'track_capacity_H':ch,'track_capacity_V':cv}
        self.calibration['ok']=self.calibration['max_abs_grid_error']<=2e-6 and abs(self.calibration['overflow_sum_error'])<=2e-5

    def bbox(self,pins,moves):
        points=[]
        for instance,point,local,size in pins:
            if instance in moves:
                x,y,orient=moves[instance];px,py=hp.transform_pin(*local,*size,orient)
                points.append((round(x+px),round(y+py)))
            else:points.append(point)
        xs,ys=zip(*points);return min(xs),min(ys),max(xs),max(ys)

    def contribution(self,b):
        a,c,d,e=b;lx,ly,ux,uy=self.region
        ix0=max(0,min(63,int((a-lx)/self.dx)));ix1=max(0,min(63,int((d-lx)/self.dx)))
        iy0=max(0,min(63,int((c-ly)/self.dy)));iy1=max(0,min(63,int((e-ly)/self.dy)))
        xs=lx+np.arange(ix0,ix1+1)*self.dx;ys=ly+np.arange(iy0,iy1+1)*self.dy
        wx=np.minimum(d,xs+self.dx)-np.maximum(a,xs)
        wy=np.minimum(e,ys+self.dy)-np.maximum(c,ys)
        area=wy[:,None]*wx[None,:]
        area=np.where(wx[None,:]==0,wy[:,None],np.where(wy[:,None]==0,wx[None,:],area))
        hd=1. if e==c else 1./(e-c);vd=1. if d==a else 1./(d-a)
        sl=(slice(iy0,iy1+1),slice(ix0,ix1+1))
        return sl,area*hd/(self.dx*self.dy),area*vd/(self.dx*self.dy)

    def util(self):return np.maximum(self.h*self.scales[0],self.v*self.scales[1])

    def wire_mass(self,net,moves):
        points=[]
        for pin,constant in zip(net['pins'],net['rc_constants']):
            instance,point,local,size=pin
            if constant is not None:point=constant
            elif instance in moves:
                x,y,orient=moves[instance];px,py=hp.transform_pin(*local,*size,orient);point=(round(x+px),round(y+py))
            points.append(point)
        driver=points[0];lengths=[(abs(p[0]-driver[0])+abs(p[1]-driver[1]))/self.units for p in points[1:]]
        return net['cap_slope']*sum(lengths), .5*net['res_slope']*net['cap_slope']*sum(v*v for v in lengths)

    def evaluate(self,moves):
        indices=set().union(*(self.incident.get(n,set())for n in moves))
        changes=[];delta=0.;cap_delta=0.;delay_delta=0.
        for idx in indices:
            old=self.boxes[idx];new=self.bbox(self.nets[idx]['pins'],moves)
            cap0,delay0=self.wire_mass(self.nets[idx],{});cap1,delay1=self.wire_mass(self.nets[idx],moves)
            cap_delta+=cap1-cap0;delay_delta+=delay1-delay0
            sl,h,v=self.contribution(old);self.h[sl]-=h;self.v[sl]-=v
            sl2,h2,v2=self.contribution(new);self.h[sl2]+=h2;self.v[sl2]+=v2
            delta+=((new[2]-new[0]+new[3]-new[1])-(old[2]-old[0]+old[3]-old[1]))/self.units
            changes.append((idx,old,new,sl,h,v,sl2,h2,v2))
        util=self.util();metrics={'hpwl_um':self.hpwl+delta,'rudy_peak':float(np.max(util)),
                                'rudy_overflow_sum':float(np.maximum(util-1,0).sum()),'wire_cap_mass_delta_pf':cap_delta,'wire_delay_mass_delta_ps':delay_delta}
        for idx,old,new,sl,h,v,sl2,h2,v2 in reversed(changes):
            self.h[sl2]-=h2;self.v[sl2]-=v2;self.h[sl]+=h;self.v[sl]+=v
        return metrics,changes,delta

    def commit(self,moves,changes,delta):
        for idx,old,new,sl,h,v,sl2,h2,v2 in changes:
            self.h[sl]-=h;self.v[sl]-=v;self.h[sl2]+=h2;self.v[sl2]+=v2
            self.boxes[idx]=new
            pins=[]
            for instance,point,local,size in self.nets[idx]['pins']:
                if instance in moves:
                    x,y,orient=moves[instance];px,py=hp.transform_pin(*local,*size,orient)
                    point=(round(x+px),round(y+py))
                pins.append((instance,point,local,size))
            self.nets[idx]['pins']=pins
        for name,(x,y,orient)in moves.items():self.cells[name].update(x=x,y=y,orient=orient)
        self.hpwl+=delta

    def publish(self,path):
        original=coordinates(self.parent)
        section=re.search(r'\bCOMPONENTS\s+\d+\s*;(.*?)\bEND COMPONENTS',self.text,re.S)
        edits=[]
        for match in re.finditer(r'(?:^|\n)\s*-\s+(\S+)\s+(\S+)\s+(.*?);',section[1],re.S):
            name=hp.def_name(match[1]);cell=self.cells[name]
            if cell==original[name]:continue
            if original[name]['status']!='PLACED':raise ValueError('fixed cell would move')
            pos=re.search(r'\+\s+PLACED\s*\(\s*-?\d+\s+-?\d+\s*\)\s*\S+',match[3])
            if not pos:raise ValueError('movable placement field missing')
            offset=section.start(1)+match.start(3)
            edits.append((offset+pos.start(),offset+pos.end(),f"+ PLACED ( {cell['x']} {cell['y']} ) {cell['orient']}"))
        text=self.text
        for begin,end,replacement in sorted(edits,reverse=True):text=text[:begin]+replacement+text[end:]
        Path(path).parent.mkdir(parents=True,exist_ok=True);Path(path).write_text(text)
        if sha(self.parent)!=self.digest:raise RuntimeError('parent changed')
        return {'changed_cells':len(edits),'parent_sha256':self.digest,'candidate_sha256':sha(path)}

    def optimize(self,target,caps,protected,max_moves=20,max_trials=2000,max_wall_s=60,wire_guard='both',on_accept=None):
        import time
        if wire_guard not in ('none','cap','elmore','both'):raise ValueError('unknown wire guard')
        if not self.calibration['ok']:raise ValueError('native RUDY calibration failed; search disabled')
        sys.path.insert(0,str(ROOT/'helpers'))
        import placement_legality
        if not placement_legality.check_legalized(self.parent,Path(self.design['macro_lef']))['legalized']:
            raise ValueError('input must be a legal placement')
        protected=set(protected)
        # Block every load/driver sharing a net with a protected path cell.
        # This preserves reported-path net geometry, but does not certify all
        # unreported timing or prevent another path from becoming critical.
        touched=set().union(*(self.incident.get(n,set())for n in protected))
        blocked=protected|{p[0]for i in touched for p in self.nets[i]['pins']if p[0]}
        groups={};sizes={}
        for name,c in self.cells.items():
            if name in blocked or c['status']!='PLACED' or c['orient']not in ('N','S','FN','FS'):continue
            macro=self.macros[hp.def_name(c['master'])];size=tuple(round(v*self.units)for v in macro['size'])
            sizes[name]=size;groups.setdefault(size,[]).append(name)
        started=time.monotonic();trials=0;accepted=[];tested=set();counts={'feasible_trials':0,'RUDY_rank_improving_trials':0,'unchanged_RUDY_trials':0,'wire_guard_passed':0}
        def score(metrics):
            p=max(0.,metrics['rudy_peak']/target['rudy_peak']-1)
            s=max(0.,(metrics['rudy_overflow_sum']-target['rudy_overflow_sum'])/max(target['rudy_overflow_sum'],1))
            return (max(p,s),p+s,metrics['rudy_overflow_sum']/max(target['rudy_overflow_sum'],1),metrics['rudy_peak']/target['rudy_peak'])
        def location_util(name,util):
            c=self.cells[name];w,h=sizes[name]
            x=max(0,min(63,int((c['x']+w/2-self.region[0])/self.dx)))
            y=max(0,min(63,int((c['y']+h/2-self.region[1])/self.dy)))
            return float(util[y,x])
        while len(accepted)<max_moves and trials<max_trials and time.monotonic()-started<max_wall_s:
            util=self.util();current={'hpwl_um':self.hpwl,'rudy_peak':float(util.max()),'rudy_overflow_sum':float(np.maximum(util-1,0).sum())}
            best_score=score(current);best=None
            # RUDY is a net-bbox metric. A hot bin need not contain any cell
            # responsible for its demand. Attribute active directional demand
            # to the actual bbox-defining pins, including distant endpoints.
            attr={};h_active=self.h*self.scales[0]>=self.v*self.scales[1]
            pressure=np.maximum(util-1,0)+.1*(util>=util.max()-1e-5)
            for net,box in zip(self.nets,self.boxes):
                sl,h,v=self.contribution(box)
                influence=float(np.sum((h*self.scales[0]*h_active[sl]+v*self.scales[1]*(~h_active[sl]))*pressure[sl]))
                if influence<=0:continue
                boundaries={p[0]for p in net['pins']if p[0]in sizes and
                            (p[1][0]in (box[0],box[2])or p[1][1]in (box[1],box[3]))}
                for name in boundaries:attr[name]=attr.get(name,0)+influence/max(1,len(boundaries))
            eligible=sorted(attr,key=lambda n:(-attr[n],n))[:64]
            for name in eligible:
                a=self.cells[name]
                group=groups[sizes[name]]
                near=sorted(group,key=lambda n:(abs(self.cells[n]['x']-a['x'])/self.dx+abs(self.cells[n]['y']-a['y'])/self.dy,n))[:24]
                cool=sorted(group,key=lambda n:(location_util(n,util)+.02*(abs(self.cells[n]['x']-a['x'])/self.dx+abs(self.cells[n]['y']-a['y'])/self.dy),n))[:24]
                donors=list(dict.fromkeys(near+cool))
                for other in donors:
                    pair=tuple(sorted((name,other)))
                    if name==other or pair in tested:continue
                    tested.add(pair);b=self.cells[other]
                    if abs(a['x']-b['x'])>12*self.dx or abs(a['y']-b['y'])>12*self.dy:continue
                    moves={name:(b['x'],b['y'],b['orient']),other:(a['x'],a['y'],a['orient'])}
                    import work_budget
                    if work_budget.ACTIVE:
                        work_budget.ACTIVE.trial()
                    metrics,changes,delta=self.evaluate(moves);trials+=1
                    feasible=all(metrics[k]<=caps[k]+1e-7 for k in ('hpwl_um','rudy_peak','rudy_overflow_sum'))
                    guard_pass=(wire_guard=='none' or
                        (wire_guard not in ('cap','both') or metrics['wire_cap_mass_delta_pf']<=1e-10) and
                        (wire_guard not in ('elmore','both') or metrics['wire_delay_mass_delta_ps']<=1e-8))
                    feasible=feasible and guard_pass
                    counts['wire_guard_passed']+=guard_pass
                    candidate_score=score(metrics)
                    counts['feasible_trials']+=feasible
                    counts['RUDY_rank_improving_trials']+=candidate_score<score(current)
                    counts['unchanged_RUDY_trials']+=abs(metrics['rudy_peak']-current['rudy_peak'])<1e-9 and abs(metrics['rudy_overflow_sum']-current['rudy_overflow_sum'])<1e-9
                    if feasible and candidate_score<best_score and any(abs(x-y)>1e-10 for x,y in zip(candidate_score,best_score)):
                        best_score=candidate_score;best=(moves,metrics,changes,delta)
                    if trials>=max_trials or time.monotonic()-started>=max_wall_s:break
                if trials>=max_trials or time.monotonic()-started>=max_wall_s:break
            if best is None:break
            moves,metrics,changes,delta=best;self.commit(moves,changes,delta)
            accepted.append({'moves':moves,'predicted_metrics':metrics,'incident_nets':len(changes)})
            if on_accept:
                on_accept(self, len(accepted), accepted[-1])
            # Previously unhelpful swaps can become useful on the new geometry.
            tested=set()
        return {'ok':True,'accepted_moves':accepted,'accepted_count':len(accepted),'neighbor_trials':trials,
            'search_wall_s':time.monotonic()-started,'protected_cells':len(protected),'net_closure_blocked_cells':len(blocked),
            'eligible_cells':len(sizes),'wire_guard':wire_guard,'wire_guard_model':'Do not increase summed native affine wire capacitance or wire-only driver-star Elmore quadratic mass; a surrogate, not full STA/TNS.', 'model':'native-calibrated directional RUDY64, exact pin/bbox incremental search',
            'diagnostics':counts,'selection':'actual pressure-weighted bbox boundary pins, nearby and low-utilization equal-size donors',
            'limitation':'Equal-width/height swaps preserve row occupancy. Full native legality/identity/RUDY/timing evaluation is required. Net-closure protection covers reported paths only.'}
